--------------------------------------------------------
--  DDL for Package MTL_ONLINE_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_ONLINE_TRANSACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: INVTXNS.pls 120.1 2005/06/17 17:48:50 appldev  $ */
--
--  FUNCTION process_online
--
--    Description:
--
--    This function process transaction records in
--    MTL_TRANSACTIONS_INTERFACE table with the specified
--    transaction header id.
--
--    This function provides a mechanism for users to process their
--    transactions synchronously.
--
--    Note: The current implementation prevents users from rollback
--    after this function is called (and returned successfully). As
--    a result, a user should only call this function when he/she
--    is ready to commit.
--
--    Input Parameters:
--      p_transaction_header_id       header id of the records
--                                    to be processed
--      p_timeout                     maximum number of seconds
--                                    to wait before returning
--                                    from the funcation
--	p_error_code		      error code stored in
--			              mtl_transactions_interface table
--				      if there is some errors
--      p_error_explanation	      error description for the specified
--			              header id
--    Return:
--      a boolean                     TRUE if succeed, FALSE otherwise
--
--
--    Usage:
--
--    To use this function, a user who wants to process a single
--    transaction record would go through the following steps:
--
--    1. get the next value of the mtl_transactions_sequence and
--       use it as the transaction header id
--    2. insert a record into mtl_transactions_interface table,
--       and a record into mtl_serial_numbers_interface table if
--       the item is under serial control, and a record into
--       mtl_transaction_lot_interface table if the item is under
--       lot control, according to the material transaction open
--       interface manual. The record(s) inserted should be
--       populated with the transaction header id obtained from step 1
--    3. set the process_flag of the record(s) to 1 (ready)
--    4. call this function with the transaction_header_id, and the
--       timeout in seconds as input parameters. timeout is the maximum time
--       in seconds the user would wait for the function to execute before
--       aborting the execution
--    5. check return boolean to see whether the function is executed
--       successfully.
--    6. check message stack using fnd_message package for warnings and/or
--       errors
--
--   The possible outcome of the function call can be:
--
--   a. function call returns TRUE, no error message, transaction
--      record process succeeded
--   or
--   b. function call returns TRUE, with warning messages, transaction
--      record process succeeded
--   or
--   c. function call returns FALSE, with error message as timeout, or
--      validation error, or other transaction errors such as onhand
--      quantity is not enough to transact.
--
--   If the outcome is a or b, the process_flag column in the corresponding
--   records in the interface tables is set to 7 (succeeded) by
--   the function; otherwise, the process_flag is set to 3 (error), and
--   the error_code column and error_explaination column are populated
--   accordingly. See open interface manual for more details on these flags.
--
--   User might also want to use methods in package fnd_message, such as
--   fnd_message.get, to retrieve error messages in the message stack.
--   See Oracle(R) Applications Developer's Guide Release 11 for more
--   details on message dictionary api.
--
--   Users can also call this method process to process multiple transaction
--   records by using the same transaction header id in the records.
--
--   The transaction records will not be removed from the interface
--   tables by this function regardless whether the records are processed
--   successfully or not.
--
--   Sample Code: (!!!TO BE TESTED!!!!!)
--
--   WHENEVER ERROR ROLLBACK;
--   DECLARE
--
--     m_txn_header_id NUMBER;
--     m_timeout       NUMBER;
--     m_outcome       BOOLEAN;
--
--   BEGIN
--
--     m_txn_header_id := mtl_transactions_sequence.nextval;
--
--     INSERT into mtl_transactions_interface
--       (...,  -- to fill in columns in mtl_transactions_interface table
--       transaction_header_id)
--     VALUES
--       (...,  -- user specify values
--       m_txn_header_id);
--
--     m_timeout := 100;
--     m_outcome := mtl_online_transaction_pub.process_online(
--                                                              m_txn_header_id
--                                                            , m_timeout
--                                                           )
--     IF (m_outcome == FALSE) THEN
--        RAISE EXCEPTION;
--     END IF;
--
--     dbms_output.put_line('Transaction with header id '||
--                           TO_CHAR(m_txn_header_id) ||
--                          ' has been processed successfully');
--   EXCEPTION
--
--       dbms_output.put_line('Failed to process the transaction');
--       dbms_output.put_line('Error message: '||fnd_message.get);
--
--   END;
--

FUNCTION process_online(
                        p_transaction_header_id IN NUMBER,
                        p_timeout in number default NULL,
			p_error_code out NOCOPY varchar2,
			p_error_explanation out NOCOPY varchar2
                        )
  RETURN BOOLEAN;
END;

 

/
