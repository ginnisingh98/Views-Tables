--------------------------------------------------------
--  DDL for Package INV_COMINGLING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_COMINGLING_UTILS" AUTHID CURRENT_USER AS
/* $Header: INVCOMUS.pls 120.0 2005/05/25 05:28:10 appldev noship $ */

/*
** -------------------------------------------------------------------------
** Procedure:   comingle_check
** Description:
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
**      x_comingling_occurs
**              Y: Co-mingling occurs as a result of transaction
**              N: Co-mingling does not occur as a result of transaction
** 	x_count
**		Minimum Number of co-mingling instances for given data
** Input:
**      p_organization_id  number
**              Organization where cost group assignment/transaction occurs
**		For receipts, this will be the source organization,
**		For subinventory and staging transfers, this will be the source organization.
**		(Source Organization = Destination Organization)
**		For inter-organization transfers, this will be transfer organization
**		(Source Organization  <> Destination Organization)
** 	p_inventory_item_id	 number
**		Identifier of item involved in cost group assignment/transaction
** 	p_revision	 varchar2
**		Revision of item involved
**	p_lot_number	 varchar2
**		Lot number of item
**	p_subinventory_code	 varchar2
**		Subinventory where the transaction occurs
**		For receipts, this will be source subinventory
**		For subinventory, staging and inter-organization transfers,
**		this will be transfer subinventory
**	p_locator_id	 number
**		Locator where the transaction occurs
**		For receipts, this will be source locator
**		For subinventory, staging and inter-organization transfers,
**		this will be transfer locator
**	p_lpn_id	 number
**		LPN into which material is packed
** 	p_cost_group_id	 number
**		identifier of cost group that is used in the transaction
**
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure comingle_check(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, x_comingling_occurs           OUT NOCOPY VARCHAR2
, x_count                       OUT NOCOPY NUMBER
, p_organization_id             IN  NUMBER
, p_inventory_item_id           IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_lot_number                  IN  VARCHAR2
, p_subinventory_code           IN  VARCHAR2
, p_locator_id                  IN  NUMBER
, p_lpn_id                      IN  NUMBER
, p_cost_group_id               IN  NUMBER);

procedure comingle_check
  (x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , x_comingling_occurs           OUT NOCOPY VARCHAR2
   , p_transaction_temp_id         IN  NUMBER);

procedure comingle_check
  (x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                   OUT NOCOPY NUMBER
   ,x_msg_data                    OUT NOCOPY VARCHAR2
   ,x_comingling_occurs           OUT NOCOPY VARCHAR2
   ,p_mmtt_rec                    IN  mtl_material_transactions_temp%ROWTYPE);

end inv_comingling_utils;

 

/
