--------------------------------------------------------
--  DDL for Package INV_ATTACHMENTS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ATTACHMENTS_UTILS" AUTHID CURRENT_USER AS
/* $Header: INVATCHS.pls 120.1 2005/06/15 11:44:27 appldev  $ */

/*
** -------------------------------------------------------------------------
** Procedure:   get_item_and_catgy_attachments
** Description:
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
**      x_attachments_number
**              number of category and item attachments for given item
**      x_concat_attachment
**              concatenated string of attachments for given item
** Input:
**      p_inventory_item_id
**              item whose attachment is required
**      p_organization_id
**              organization of item whose attachment is required
**      p_document_category
**              document category of attached document. this
**              maps to a Mobile Applications functionality
**              1 - 'To Mobile Receiver'
**              2 - 'To Mobile Putaway'
**              3 - 'To Mobile Picker'
**      p_transaction_temp_id
**              unique identifier of the transaction and is null by default.
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure get_item_and_catgy_attachments(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, x_attachments_number          OUT NOCOPY NUMBER
, x_concat_attachment           OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN         NUMBER
, p_organization_id             IN         NUMBER
, p_document_category           IN         NUMBER
, p_transaction_temp_id         IN         NUMBER default NULL);

end inv_attachments_utils;

 

/
