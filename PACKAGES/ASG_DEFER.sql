--------------------------------------------------------
--  DDL for Package ASG_DEFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_DEFER" AUTHID CURRENT_USER AS
/*$Header: asgdfrs.pls 120.2.12010000.2 2009/08/03 10:52:57 saradhak ship $*/

-- DESCRIPTION
--  This package supports deferred transactions.
--
--
-- HISTORY
--   13-jul-2009 saradhak   added commit flag to reapply_txn & discard_txn apis
--   15-sep-2004 ssabesan   Changes for delivery notification
--   28-nov-2002 ssabesan   Added NOCOPY in function definition
--   22-feb-2002 rsripada   Finalized api spec
--   19-feb-2002 rsripada   Created


  -- Defers a row. Returns FND_API.G_RET_STS_SUCCESS if the row was
  -- successfully deferred. FND_API.G_RET_STS_ERROR otherwise. Will
  -- commit any work done as part of this proceduer using autonomous
  -- transaction. sequence is a column in the inq that together with
  -- the user_name, tran_id, pub_item can uniquely identify a record
  -- in the inq.
  PROCEDURE defer_row(p_user_name IN VARCHAR2,
                      p_tranid   IN NUMBER,
                      p_pubitem  IN VARCHAR2,
                      p_sequence  IN NUMBER,
                      p_error_msg IN VARCHAR2,
                      x_return_status OUT NOCOPY VARCHAR2);

  -- Removes the deferred row from inq and removes references
  -- to it as a deferred row.
  PROCEDURE delete_deferred_row(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                p_pubitem  IN VARCHAR2,
                                p_sequence  IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2);

  -- Marks this records for delete in the client's Olite database.
  PROCEDURE reject_row(p_user_name IN VARCHAR2,
                       p_tranid   IN NUMBER,
                       p_pubitem  IN VARCHAR2,
                       p_sequence  IN NUMBER,
                       p_error_msg IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2);

  -- Returns FND_API.G_TRUE if the transaction is deferred
  FUNCTION is_deferred(p_user_name IN VARCHAR2,
                       p_tranid   IN NUMBER)
           RETURN VARCHAR2;

  -- Returns FND_API.G_TRUE if the record is deferred
  FUNCTION is_deferred(p_user_name IN VARCHAR2,
                       p_tranid   IN NUMBER,
                       p_pubitem  IN VARCHAR2,
                       p_sequence  IN NUMBER)
           RETURN VARCHAR2;

  -- Set transaction status to discarded
  PROCEDURE discard_transaction(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2);

  -- Discard the specified deferred row
  PROCEDURE discard_transaction(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                p_pubitem  IN VARCHAR2,
                                p_sequence  IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_commit_flag IN BOOLEAN DEFAULT TRUE);

  -- Reapply the given transaction
  PROCEDURE reapply_transaction(p_user_name IN VARCHAR2,
                                p_tranid IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_commit_flag IN BOOLEAN DEFAULT TRUE);

  -- Purge all the inq entries
  PROCEDURE purge_transaction(p_user_name IN VARCHAR2,
                              p_tranid IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2);

  function raise_row_deferred(p_user_name IN VARCHAR2,
                              p_tranid  IN NUMBER,
                              p_pubitem IN VARCHAR2,
                              p_sequence  IN NUMBER,
                              p_error_msg IN VARCHAR2)
          return boolean;

  -- Delete rows in asg_deferred_traninfo/asg_users_inqinfo with no data in INQ.
  PROCEDURE delete_deferred(p_status OUT NOCOPY VARCHAR2,
                            p_message OUT NOCOPY VARCHAR2);

END asg_defer;

/
