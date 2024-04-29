--------------------------------------------------------
--  DDL for Package GL_BC_PACKETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BC_PACKETS_PKG" AUTHID CURRENT_USER AS
/* $Header: glibcpas.pls 120.6 2005/07/29 16:58:05 djogg ship $ */
--
-- Package
--   gl_bc_packets_pkg
-- Purpose
--   To contain validation and insertion routines for gl_bc_packets
-- History
--   12-31-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique packet id
  -- History
  --   12-30-93  D. J. Ogg    Created
  -- Arguments
  --   none
  -- Example
  --   pid := gl_bc_packets_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Procedure
  --   insert_je_packet
  -- Purpose
  --   Selects data from gl_je_lines, and inserts the complete packet
  --   into gl_bc_packets
  -- History
  --   01-11-94  D. J. Ogg    Created
  -- Arguments
  --   batch_id		ID of batch to be funds checked/reserved
  --   mode_code 	R - Reserve Funds, C - Check Funds
  --   user_id          ID of the current user
  --   x_session_id     Session ID
  --   x_serial_id      Serial_Id
  -- Returns
  --   The ID of the newly inserted packet
  -- Example
  --   pkt_id := gl_bc_packets_pkg.insert_je_packet(1001, 'R', 1002, 5, 10);
  -- Notes
  --
  FUNCTION insert_je_packet(batch_id NUMBER,
                            lgr_id NUMBER,
			    mode_code VARCHAR2,
			    user_id NUMBER,
                            x_session_id NUMBER,
                            x_serial_id NUMBER) RETURN NUMBER;

  --
  -- Procedure
  --   exists_packet
  -- Purpose
  --   Checks to see if rows exist in gl_bc_packets with the given
  --   packet id.  Returns TRUE if they do, or FALSE otherwise.
  -- History
  --   03-24-94  D. J. Ogg    Created
  -- Arguments
  --   xpacket_id	packet id to check for
  -- Example
  --   IF (gl_bc_packets_pkg.exists_packet(1001))
  -- Notes
  --
  FUNCTION exists_packet(xpacket_id NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   get_ledger_id
  -- Purpose
  --   Gets the ledger_id of the rows for this packet
  -- History
  --   03-23-04  D. J. Ogg    Created
  -- Arguments
  --   xpacket_id	packet id to check for
  -- Example
  --   IF (gl_bc_packets_pkg.get_ledger_id(1001) = 1)
  -- Notes
  --
  FUNCTION get_ledger_id(xpacket_id NUMBER) RETURN NUMBER;

  --
  -- Procedure
  --   Insert_Budget_Transfer_Row
  -- Purpose
  --   Inserts two new rows in gl_bc_packets for the budget transfer
  -- History
  --   04-01-94   D. J. Ogg		Created
  -- Arguments
  --   X_From_Rowid		    The place to store the Row ID of the
  --                                from row
  --   X_To_Rowid		    The place to store the Row ID of the
  --                                to row
  --   X_Status_Code		    The status of the new rows
  --   X_Packet_Id		    The packet ID of the new rows
  --   X_Ledger_Id	            The ledger ID of the new rows
  --   X_Je_Source_Name	    	    The source of the new rows (Transfer)
  --   X_Je_Category_Name	    The category of the new rows (Budget)
  --   X_Budget_Version_Id	    The budget containing the transfered amts
  --   X_Je_Batch_Name		    The batch name of the new rows
  --   X_Currency_Code		    The currency of the transfered amts
  --   X_From_Code_Combination_Id   The code combination of the from row
  --   X_To_Code_Combination_Id     The code combination of the to row
  --   X_Combination_Number	    The ID indicating the group of transfers
  --                                containing the new rows
  --   X_Period_Name                The period of the transfer
  --   X_Period_Year		    The period year of the transfer
  --   X_Period_Num		    The period number of the transfer
  --   X_Quarter_Num		    The quarter number of the transfer
  --   X_From_Entered_Dr	    The Debit amount transfered from the from
  --   X_From_Entered_Cr	    The Credit amount transfered from the from
  --   X_To_Entered_Dr		    The Debit amount transfered to the to
  --   X_To_Entered_Cr		    The Credit amount transfered to the to
  --   X_Last_Update_Date	    The date on which the new rows were
  --			  	    created
  --   X_Last_Updated_By	    The user id of the person who created the
  --				    new rows
  --   X_Session_Id                 Session Id
  --   X_Serial_Id                  Serial Id
  --
  PROCEDURE Insert_Budget_Transfer_Row(
		     X_From_Rowid                   IN OUT NOCOPY VARCHAR2,
		     X_To_Rowid                     IN OUT NOCOPY VARCHAR2,
		     X_Status_Code			   VARCHAR2,
                     X_Packet_Id                           NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
		     X_Period_Year			   NUMBER,
		     X_Period_Num			   NUMBER,
		     X_Quarter_Num			   NUMBER,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
                     X_To_Entered_Dr                       NUMBER,
                     X_To_Entered_Cr                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Session_Id                          NUMBER,
                     X_Serial_Id                           NUMBER);

  --
  -- Procedure
  --   Update_Budget_Transfer_Row
  -- Purpose
  --   Updates the two rows in gl_bc_packets for the budget transfer
  -- History
  --   04-01-94   D. J. Ogg		Created
  -- Arguments
  --   X_From_Rowid		    The Row ID of the from row
  --   X_To_Rowid		    The Row ID of the to row
  --   X_Status_Code		    The status of the rows
  --   X_Packet_Id		    The packet ID of the rows
  --   X_Ledger_Id      	    The ledger ID of the rows
  --   X_Je_Source_Name	    	    The source of the rows (Transfer)
  --   X_Je_Category_Name	    The category of the rows (Budget)
  --   X_Budget_Version_Id	    The budget containing the transfered amts
  --   X_Je_Batch_Name		    The batch name of the rows
  --   X_Currency_Code		    The currency of the transfered amts
  --   X_From_Code_Combination_Id   The code combination of the from row
  --   X_To_Code_Combination_Id     The code combination of the to row
  --   X_Combination_Number	    The ID indicating the group of transfers
  --                                containing the rows
  --   X_Period_Name                The period of the transfer
  --   X_Period_Year		    The period year of the transfer
  --   X_Period_Num		    The period number of the transfer
  --   X_Quarter_Num		    The quarter number of the transfer
  --   X_From_Entered_Dr	    The Debit amount transfered from the from
  --   X_From_Entered_Cr	    The Credit amount transfered from the from
  --   X_To_Entered_Dr		    The Debit amount transfered to the to
  --   X_To_Entered_Cr		    The Credit amount transfered to the to
  --   X_Last_Update_Date	    The date on which the rows were
  --			  	    last changed
  --   X_Last_Updated_By	    The user id of the person who last
  --				    changed the rows
  --
  PROCEDURE Update_Budget_Transfer_Row(
		     X_From_Rowid                          VARCHAR2,
		     X_To_Rowid                            VARCHAR2,
		     X_Status_Code			   VARCHAR2,
                     X_Packet_Id                           NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
		     X_Period_Year			   NUMBER,
		     X_Period_Num			   NUMBER,
		     X_Quarter_Num			   NUMBER,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
                     X_To_Entered_Dr                       NUMBER,
                     X_To_Entered_Cr                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER);

  --
  -- Procedure
  --   Lock_Budget_Transfer_Row
  -- Purpose
  --   Locks the two rows in gl_bc_packets for the budget transfer
  -- History
  --   04-01-94   D. J. Ogg		Created
  -- Arguments
  --   X_From_Rowid		    The Row ID of the from row
  --   X_To_Rowid		    The Row ID of the to row
  --   X_Status_Code		    The status of the two rows
  --   X_Packet_Id		    The packet ID of the rows
  --   X_Ledger_Id	            The ledger ID of the rows
  --   X_Je_Source_Name	    	    The source of the rows (Transfer)
  --   X_Je_Category_Name	    The category of the rows (Budget)
  --   X_Budget_Version_Id	    The budget containing the transfered amts
  --   X_Je_Batch_Name		    The batch name of the rows
  --   X_Currency_Code		    The currency of the transfered amts
  --   X_From_Code_Combination_Id   The code combination of the from row
  --   X_To_Code_Combination_Id     The code combination of the to row
  --   X_Combination_Number	    The ID indicating the group of transfers
  --                                containing the rows
  --   X_Period_Name                The period of the transfer
  --   X_Period_Year		    The period year of the transfer
  --   X_Period_Num		    The period number of the transfer
  --   X_Quarter_Num		    The quarter number of the transfer
  --   X_From_Entered_Dr	    The Debit amount transfered from the from
  --   X_From_Entered_Cr	    The Credit amount transfered from the from
  --   X_To_Entered_Dr		    The Debit amount transfered to the to
  --   X_To_Entered_Cr		    The Credit amount transfered to the to
  --
  PROCEDURE Lock_Budget_Transfer_Row(
		     X_From_Rowid                          VARCHAR2,
		     X_To_Rowid                            VARCHAR2,
		     X_Status_Code			   VARCHAR2,
                     X_Packet_Id                           NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
		     X_Period_Year			   NUMBER,
		     X_Period_Num			   NUMBER,
		     X_Quarter_Num			   NUMBER,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
                     X_To_Entered_Dr                       NUMBER,
                     X_To_Entered_Cr                       NUMBER);

  --
  -- Procedure
  --   Delete_Budget_Transfer_Row
  -- Purpose
  --   Deletes the two rows in gl_bc_packets for the budget transfer
  -- History
  --   04-01-94   D. J. Ogg		Created
  -- Arguments
  --   X_From_Rowid		    The Row ID of the from row
  --   X_To_Rowid		    The Row ID of the to row
  --
  PROCEDURE Delete_Budget_Transfer_Row(
		     X_From_Rowid                          VARCHAR2,
		     X_To_Rowid                            VARCHAR2);

  --
  -- Procedure
  --   Delete_Packet
  -- Purpose
  --   Deletes the packet with the given packet_id.  If a value
  --   is provided for reference1, only deletes the rows with
  --   this value
  -- History
  --   06-02-94   D. J. Ogg		Created
  -- Arguments
  --   Packet_Id		ID of the packet to be deleted
  --   Reference1		Reference of the rows to be deleted
  --
  PROCEDURE Delete_Packet(Packet_Id   NUMBER,
			  Reference1  NUMBER DEFAULT NULL);

  --
  -- Procedure
  --   copy_packet
  -- Purpose
  --   Inserts a new packet that is the same as the old packet
  -- History
  --   06-02-94  D. J. Ogg    Created
  -- Arguments
  --   packet_id	ID of the packet_id to be duplicated
  --   mode_code 	R - Reserve Funds, C - Check Funds
  --   user_id          ID of the current user
  --   x_session_id     Session Id
  --   x_serial_id      Serial Id
  -- Returns
  --   The ID of the newly inserted packet
  -- Example
  --   pkt_id := gl_bc_packets_pkg.copy_packet(1001, 'R', 1002);
  -- Notes
  --
  FUNCTION copy_packet(packet_id NUMBER,
		       mode_code VARCHAR2,
		       user_id NUMBER,
                       x_session_id NUMBER,
                       x_serial_id NUMBER) RETURN NUMBER;

  --
  -- Procedure
  --   view_bc_results_setup
  -- Purpose
  --   Does the necessary setup for view_bc_results
  -- History
  --   22-JUL-2005  D J Ogg	Created
  -- Arguments
  --   packet_id	ID of the packet_id to be viewed
  --   ledger_id	Ledger Id used in the packet
  -- Returns
  --   The new sequence id to be passed to the function execution
  -- Example
  --   seq_id := gl_bc_packets_pkg.view_bc_results_setup(1001, 1);
  -- Notes
  --
  FUNCTION view_bc_results_setup(packet_id NUMBER,
                                 ledger_id NUMBER) RETURN NUMBER;
END gl_bc_packets_pkg;

 

/
