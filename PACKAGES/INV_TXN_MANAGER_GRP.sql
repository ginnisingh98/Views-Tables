--------------------------------------------------------
--  DDL for Package INV_TXN_MANAGER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TXN_MANAGER_GRP" AUTHID CURRENT_USER AS
/* $Header: INVTXGGS.pls 120.4.12010000.1 2008/07/24 01:50:07 appldev ship $ */


   -----------------------------------------------------------------------
   -- Global Constants for Transaction Processing Mode
   -- There are the values the column TRANSACTION_MODE in MTI/MMTT/MMT
   -- could have and their meanings. The columns determines 2 things
   --   1) the source of the transaction record (MTI or MMTT)
   --   2) mode of processing (Online, Asyncronous, Background)
   -----------------------------------------------------------------------
   PROC_MODE_MMTT_ONLINE    CONSTANT NUMBER :=  1 ;
   PROC_MODE_MMTT_ASYNC     CONSTANT NUMBER :=  2 ;
   PROC_MODE_MMTT_BGRND     CONSTANT NUMBER :=  3 ;
   PROC_MODE_MTI            CONSTANT NUMBER :=  8 ;

   -----------------------------------------------------------------------
   -- Please note that other constants used in the Transaction Manager are
   -- defined in package INV_GLOBALS  and TrxTypes.java
   -----------------------------------------------------------------------
   ---------------------------------------------------------------
   --- added this variable here to it can used in the public api.
   gi_flow_schedule NUMBER := 0 ;
   ---------------------------------------------------------------

  ----------------------------------------------------------------------------------------
  -- Added this type for holding Serial Attributes for Serialized Lot Items
  --
  TYPE lot_sel_index_attr_tbl_type is TABLE OF INV_LOT_SEL_ATTR.LOT_SEL_ATTRIBUTES_REC_TYPE
  INDEX BY  VARCHAR2(50);
  -----------------------------------------------------------------------------------------

   -----------------------------------------------------------------------
   -- Name : validate_group
   -- Desc : Validate a group of MTI records in a batch together.
   --          This is called from process_transaction() when TrxMngr processes
   --          a batch of records
   -- I/P params :
   --     p_header_id : transaction_header_id
   -----------------------------------------------------------------------
   PROCEDURE validate_group(p_header_id NUMBER
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_count OUT NOCOPY NUMBER
                                ,x_msg_data OUT NOCOPY VARCHAR2
                                ,p_userid NUMBER DEFAULT -1
			        ,p_loginid NUMBER DEFAULT -1
			        ,p_validation_level NUMBER:= fnd_api.g_valid_level_full );


   -----------------------------------------------------------------------
   -- Name : validate_lines (wrapper)
   -- Desc : Validate each record of a batch in MTI .
   --        This procedure acts as a wrapper and calls the inner validate_lines.
   --
   -- I/P params :
   --     p_header_id : transaction_header_id
   --     p_validation_level : Validation level
   -----------------------------------------------------------------------
   PROCEDURE validate_lines(p_header_id NUMBER,
                           p_commit VARCHAR2 := fnd_api.g_false     ,
                           p_validation_level NUMBER  := fnd_api.g_valid_level_full  ,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2,
                           p_userid NUMBER DEFAULT -1,
                           p_loginid NUMBER DEFAULT -1,
                           p_applid NUMBER DEFAULT NULL,
                           p_progid NUMBER DEFAULT NULL);


   -----------------------------------------------------------------------
   -- Name : validate_lines (inner)
   -- Desc : Validate a record in MTI .
   --        This procedure is called from process_transaction() when TrxMngr
   --        processes a batch of records in MTI
   --
   -- I/P params :
   --     p_line_Rec_Type : MTI record type
   -----------------------------------------------------------------------
   PROCEDURE validate_lines(p_line_Rec_Type inv_txn_manager_pub.line_Rec_type,
                           p_commit VARCHAR2 := fnd_api.g_false     ,
                           p_validation_level NUMBER  := fnd_api.g_valid_level_full  ,
                           p_error_flag OUT NOCOPY VARCHAR2,
                           p_userid NUMBER DEFAULT -1,
                           p_loginid NUMBER DEFAULT -1,
                           p_applid NUMBER DEFAULT NULL,
                           p_progid NUMBER DEFAULT NULL);


   -----------------------------------------------------------------------
   -- Name : get_open_period
   -- Desc : Determine Account PeriodId based on organization and transaction-date
   --        This procedure is called from validate_lines()
   --
   -- I/P params :
   --     p_org_id     : Org Id
   --     p_trans_date : Transaction Date
   -----------------------------------------------------------------------
   FUNCTION get_open_period(p_org_id NUMBER
                                 ,p_trans_date DATE
                                 ,p_chk_date NUMBER) RETURN NUMBER;

   /******************************************************************
   -- Procedure
   --   getitemid
   -- Description
   --   find the item_id using the flex field segments
   -- Output Parameters
   --   x_item_id   locator or null if error occurred
   ******************************************************************/
     FUNCTION getitemid(x_itemid out NOCOPY NUMBER, p_orgid NUMBER, p_rowid VARCHAR2)
     RETURN BOOLEAN;

   /******************************************************************
   -- Procedure
   --   getacctid
   -- Description
   --   find the acct_id using the flex field segments
   -- Output Parameters
   --   x_acct_id
   ******************************************************************/
   FUNCTION getacctid(x_acctid OUT NOCOPY NUMBER, p_orgid IN NUMBER, p_rowid IN VARCHAR2)
     RETURN BOOLEAN;
   /******************************************************************
-- Function
--   getlocid
-- Description
--   find the locator using the flex field segments
--   Calls private function getLoc to do the work
-- Output Parameters
--   x_locator   locator or null if error occurred
 ******************************************************************/
   FUNCTION getlocid(x_locid OUT NOCOPY NUMBER, p_org_id NUMBER, p_subinv
		     VARCHAR2, p_rowid VARCHAR2, p_locctrl NUMBER) return
   BOOLEAN ;


 /******************************************************************
 -- Procedure
 --   getsrcid
 -- Description
 --   find the Source ID using the flex field segments
 -- Output Parameters
 --   x_trxsrc   transaction source id or null if error occurred
 ******************************************************************/
FUNCTION getsrcid(x_trxsrc OUT NOCOPY NUMBER, p_srctype IN NUMBER, p_orgid IN NUMBER, p_rowid IN VARCHAR2)
RETURN BOOLEAN;


   -----------------------------------------------------------------------
   -- Name : Validate_Transactions
   -- Desc : This procedure is used to validate record inserted in MYI
   --through desktop forms AND moved TO mmtt. it does NOT call the
   --  transaction manager TO process the transactions.
   --        It is called to validate a batch of transaction_records .
   --
   -- I/P Params :
   --     p_header_id  : Transaction Header Id
   -- O/P Params :
   --     x_trans_count : count of transaction records validate
   --History
   --  Jalaj Srivastava Bug 5155661
   --    Add new parameter p_free_tree
   -----------------------------------------------------------------------
   FUNCTION Validate_Transactions(
          p_api_version         IN     NUMBER            ,
          p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false     ,
	  p_validation_level    IN      NUMBER  := fnd_api.g_valid_level_full  ,
          p_header_id           IN      NUMBER ,
	  x_return_status       OUT     NOCOPY VARCHAR2                        ,
          x_msg_count           OUT     NOCOPY NUMBER                          ,
          x_msg_data            OUT     NOCOPY VARCHAR2                        ,
          x_trans_count         OUT     NOCOPY NUMBER                          ,
          p_free_tree           IN      VARCHAR2 := fnd_api.g_true     )
      RETURN NUMBER;


   -----------------------------------------------------------------------
   -- Name : tmpinsert
   -- Desc : Move a transaction record from MTI to MMTT
   --        This procedure is called from process_transaction()
   --
   -- I/P params :
   --     p_rowid     : rowid of record in MTI Id
   --
   -----------------------------------------------------------------------
   FUNCTION tmpinsert(p_header_id IN NUMBER,
		      p_validation_level IN NUMBER  := fnd_api.g_valid_level_full )
     RETURN BOOLEAN;


   -----------------------------------------------------------------------
   -- Name : tmpinsert2
   -- Desc : Move a transaction record from (MTI, MSNI) to (MMTT, MSNT)
   --        specifically for lot transactions(Split/Merge/Translate).
   --        This procedure is called from process_transaction()
   --
   -- I/P params :
   --     p_header_id     : header_id of the record in MTI.
   --
   -----------------------------------------------------------------------

   PROCEDURE tmpinsert2 (
    x_return_status       OUT NOCOPY      VARCHAR2
  , x_msg_count           OUT NOCOPY      NUMBER
  , x_msg_data            OUT NOCOPY      VARCHAR2
  , x_validation_status   OUT NOCOPY      VARCHAR2
  , p_header_id           IN   NUMBER
  , p_validation_level    IN   NUMBER := fnd_api.g_valid_level_full
  );

-----------------------------------------------------------------------
-- Name : Validate_Additional_Attr
-- Desc : This procedure is used to validate additonal lot
--        opm attributes added part of invconv project
-- I/P Params :
--     All the relevant transaction details :
--        - organization id
--        - item_id
--        - lot
--
-- O/P Params :
--     see below ..
-- RETURN VALUE :
--   TRUE : IF all the attributes are validated correctly
--   FALSE : IF one attributes check fails
--
-----------------------------------------------------------------------
FUNCTION Validate_Additional_Attr(
       p_api_version         	IN     NUMBER
     , p_init_msg_list       	IN      VARCHAR2 := fnd_api.g_false
	 , p_validation_level    	IN      NUMBER  := fnd_api.g_valid_level_full
	 , p_intid 					IN     NUMBER
	 , p_rowid                  IN     VARCHAR2
     , p_inventory_item_id      IN     NUMBER
     , p_organization_id        IN     NUMBER
     , p_lot_number             IN     VARCHAR2
     , p_grade_code             IN OUT NOCOPY     VARCHAR2
     , p_retest_date            IN OUT NOCOPY    DATE
     , p_maturity_date          IN OUT NOCOPY    DATE
     , p_parent_lot_number      IN OUT NOCOPY   VARCHAR2
     , p_origination_date       IN OUT NOCOPY     DATE
     , p_origination_type       IN OUT NOCOPY     NUMBER
     , p_expiration_action_code IN OUT NOCOPY     VARCHAR2
     , p_expiration_action_date IN OUT NOCOPY      DATE
     , p_expiration_date        IN OUT NOCOPY     DATE
     , p_hold_date	            IN OUT NOCOPY     DATE
	 , p_reason_id              IN OUT NOCOPY     NUMBER
	 , p_copy_lot_attribute_flag IN   VARCHAR2
	 , x_return_status       OUT NOCOPY VARCHAR2
	 , x_msg_count           OUT NOCOPY NUMBER
	 , x_msg_data            OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

--
--     Name: GET_SERIAL_DIFF_WRP
--     Desc: This is a wrapper call to inv_serial_number_pub.get_serial_diff.
--           This function returns serial count as 0, if invalid range is passed.
--
--     Input parameters:
--       p_fm_serial          'from' Serial Number
--       p_to_serial          'to'   Serial Number
--
--      Output parameters:
--       return_status       quantity between passed serial numbers,
--                           0 if pased serial numbers are invalid.
--
FUNCTION get_serial_diff_wrp(p_fm_serial IN VARCHAR2, p_to_serial IN VARCHAR2)
RETURN NUMBER;

END INV_TXN_MANAGER_GRP;

/
