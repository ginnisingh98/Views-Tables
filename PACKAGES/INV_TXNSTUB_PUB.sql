--------------------------------------------------------
--  DDL for Package INV_TXNSTUB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TXNSTUB_PUB" AUTHID CURRENT_USER AS
/* $Header: INVTPUBS.pls 120.2 2006/04/28 05:00:49 pannapra ship $ */

        /*Bug#5194809. The following variable is removed as the dynamic SQL is
	  modified to static one in the package body and as a result there is no
	  need of this vaialbe*/
	--g_ret_status varchar2(56); -- This variable to hold the return status
                             -- of the InstallBase Stub that is called
                             -- using dynamic SQL

  /**
   *  p_header_id         = TRANSACTION_HEADER_ID
   *  p_transaction_id    = TRANSACTION_ID
   *  x_return_status     = FND_API.G_RET_STS_*;
   *  in case of an error, the error should be put onto the message stake
   *  using fnd_message.set_name and fnd_msg_pub.add functions or similar
   *  functions in those packages. The caller would then retrieve the
   *  messages. If the return status is a normal (predicted) error or
   *  an unexpected error, then the transaction is aborted.
   */
  PROCEDURE postTransaction(p_header_id IN NUMBER,
                            p_transaction_id   IN NUMBER,
                            x_return_status OUT nocopy VARCHAR2);

END INV_TXNSTUB_PUB;

 

/
