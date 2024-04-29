--------------------------------------------------------
--  DDL for Package WMS_ASN_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ASN_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: WMSASNIS.pls 120.1 2005/05/25 17:10:59 appldev  $ */


/*
** -------------------------------------------------------------------------
** Function:    process
** Description: Processes ASN information out of WMS_LPN_CONTENTS_INTERFACE
**		into WMS_LPN_CONTENTS
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_interface_transaction_id
**        Interface Transaction Id of record in RCV_TRANSACTIONS_INTERFACE
**        whose ASN information is being processed by Receiving Transactions
**        Manager's pre-processor. process API will work on all records
**	  in WMS_LPN_CONTENTS_INTERFACE that have this interface_transaction_id.
** Returns:
**	None
** --------------------------------------------------------------------------
*/

procedure process (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_interface_transaction_id    IN  NUMBER );

end WMS_ASN_INTERFACE;

 

/
