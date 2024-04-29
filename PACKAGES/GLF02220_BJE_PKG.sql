--------------------------------------------------------
--  DDL for Package GLF02220_BJE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GLF02220_BJE_PKG" AUTHID CURRENT_USER AS
/* $Header: glfbdejs.pls 120.5 2005/07/29 16:57:23 djogg ship $ */
--
-- Package
--   glf02220_bje_pkg
-- Purpose
--   Form package for Enter Budget Journals form
-- History
--   08/19/94		R Ng		Created
--

  --
  -- Function
  --   bje_trans_exists
  -- Purpose
  --   Determines whether there are any non-zero budget
  --   journals going to be created based on records present
  --   in GL_BUDGET_RANGE_INTERIM.
  -- History
  --   08/19/94	 	R Ng		Created
  -- Arguments
  --   X_status_number		Status number (for this bje session)
  --   X_ledger_id           	Ledger ID
  --   X_period_year		Budget period year
  --   X_start_period_num	Start period number
  --   X_end_period_num		End period number
  -- Example
  -- Notes
  --
  FUNCTION bje_trans_exists( X_status_number	IN NUMBER,
			     X_ledger_id	IN NUMBER,
                             X_period_year	IN NUMBER,
                             X_start_period_num IN NUMBER,
                             X_end_period_num	IN NUMBER ) RETURN BOOLEAN;

  --
  -- Procedure
  --   insert_bc_packet
  -- Purpose
  --   Inserts transactions into GL_BC_PACKETS for funds check/reservation
  --   based on records present in GL_BUDGET_RANGE_INTERIM.
  --   Retrieves packet_id and returns packet_id to calling form upon exit.
  -- History
  --   08/19/94	 	R Ng		Created
  -- Arguments
  --   X_packet_id		Packet ID
  --   X_status_number		Status number (for this bje session)
  --   X_ledger_id           	Ledger ID
  --   X_je_category_name	JE category name
  --   X_fc_mode		Funds check mode (C/R)
  --   X_je_batch_name		BJE batch name
  --   X_period_year		Budget period year
  --   X_start_period_num	Start period number
  --   X_end_period_num		End period number
  --   X_session_Id             Session Id
  --   X_serial_Id              Serial Id
  -- Example
  -- Notes
  --
  PROCEDURE insert_bc_packet( X_packet_id		IN OUT NOCOPY NUMBER,
			      X_status_number		IN NUMBER,
			      X_ledger_id		IN NUMBER,
			      X_je_category_name	IN VARCHAR2,
			      X_fc_mode			IN VARCHAR2,
			      X_je_batch_name		IN VARCHAR2,
                              X_period_year		IN NUMBER,
                              X_start_period_num 	IN NUMBER,
                              X_end_period_num		IN NUMBER,
                              X_session_id              IN NUMBER,
                              X_serial_id               IN NUMBER);

  --
  -- Procedure
  --   insert_interface_rows
  -- Purpose
  --   Inserts transactions into GL_INTERFACE for current BJE forms session
  --   based on records present in GL_BUDGET_RANGE_INTERIM.
  --   Retrieves group_id and returns group_id to calling form upon exit.
  -- History
  --   08/24/94	 	R Ng		Created
  -- Arguments
  --   X_group_id		Journal Import Group ID
  --   X_status_number		Status number (for this bje session)
  --   X_ledger_id           	Ledger ID
  --   X_user_je_category_name	User JE category name
  --   X_je_batch_name		BJE batch name
  --   X_period_year		Budget period year
  --   X_start_period_num	Start period number
  --   X_end_period_num		End period number
  -- Example
  -- Notes
  --
  PROCEDURE insert_interface_rows( X_group_id			IN OUT NOCOPY NUMBER,
			      	   X_status_number		IN NUMBER,
			     	   X_ledger_id			IN NUMBER,
			      	   X_user_je_category_name	IN VARCHAR2,
			      	   X_je_batch_name		IN VARCHAR2,
                              	   X_period_year		IN NUMBER,
                              	   X_start_period_num 		IN NUMBER,
                              	   X_end_period_num		IN NUMBER );

  --
  -- Procedure
  --   delete_range_interim_records
  -- Purpose
  --   Delete records from GL_BUDGET_RANGE_INTERIM after submitting
  --   Create Journals program (BC on) or Journal Import (BC off)
  -- History
  --   08/19/94	 	R Ng		Created
  -- Arguments
  --   X_status_number		Status number (for this bje session)
  -- Example
  -- Notes
  --
  PROCEDURE delete_range_interim_records( X_status_number  IN NUMBER );

END glf02220_bje_pkg;

 

/
