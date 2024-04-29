--------------------------------------------------------
--  DDL for Package CTO_CUSTOM_SUPPLY_CHECK_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CUSTOM_SUPPLY_CHECK_PK" AUTHID CURRENT_USER as
/* $Header: CTOCUSCS.pls 120.1 2005/06/02 13:51:31 appldev  $*/

/*----------------------------------------------------------------------------+
| Copyright (c) 2003 Oracle Corporation    redwood shores, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOCUSCS.pls
|
|DESCRIPTION : This package is a customization hook to get an input           |
|              regarding the ownership of creating supply                     |
|
|              This prcoedure should return                                    |
|                 Y, if CTO can recommend creation of Supply .                |
|                 N, if CTO is not supposed to recommend creation of supply
|                    (planning will recommend creation of supply)             |
|               							      |
|              If 'N' is returned CTO will not recommend creation of supply
|              and leave the decision to planning                             |
|
|              If 'Y' is returned CTO will perform its OWN intelligence and   |
|              decide if it can recommend the supply or leave the decision to
|              planning
|                                                                             |
|              Input parameters
|               1.invetory_item_id of the item for which supply needs to be
|                created
|               2. Current organization(ship from organization) id  in which  |
|                  supply is desired                                          |
|
|              Output parameters
|                'Y' or 'N'
|                                                                             |
|									      |
| HISTORY :    09/05/2003   Kiran Konada         			      |
|									      |
|              06/01/2005   Renga Kannan				      |
|                           Added NOCOPY hint to all OUT parameters.
|									      |
*============================================================================*/


TYPE in_params_rec_type IS RECORD
(
CONFIG_ITEM_ID          number,
Org_id            	number
);

TYPE out_params_rec_type IS RECORD
(
 can_cto_create_supply     Varchar2(1)
);


/*---------------------------------------------------------------------------+
    This prcoedure should return
                 Y, if CTO can recommend creation of Supply .
                 N, if CTO is not supposed to recommend creation of supply
                    (planning will recommend creation of supply)


----------------------------------------------------------------------------*/


PROCEDURE Check_Supply(
                         P_in_params_rec        IN          CTO_CUSTOM_SUPPLY_CHECK_PK.in_params_rec_type,
			 X_out_params_rec       OUT NOCOPY  CTO_CUSTOM_SUPPLY_CHECK_PK.out_params_rec_type,
			 X_return_status    OUT NOCOPY varchar2,
			 X_msg_count        OUT NOCOPY number,
			 X_msg_data         OUT NOCOPY varchar2

			);

end CTO_CUSTOM_SUPPLY_CHECK_PK;

 

/
