--------------------------------------------------------
--  DDL for Package GMI_PICK_CONFIRM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_PICK_CONFIRM_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMIPCAPS.pls 120.0 2005/05/25 16:14:43 appldev noship $ */
/*#
 * This is the public interface for Pick COnfirm OPM Orders API.
 * It contains the API to pick confirm, or stage the inventory for, a Process
 * Move Order Line or a Delivery detail Line, depending on whether a
 * delivery detail line id or a move order line id is passed as a parameter.
 * @rep:scope public
 * @rep:product GMI
 * @rep:displayname GMI Pick Confirm OPM Orders API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMI_PICK_CONFIRM_PUB
*/

/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPPWCS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Pick  Confirmation                                                  |
 |                                                                         |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     20-NOV-2002  nchekuri        Created                                |
 |
 +=========================================================================+
  API Name  : GMI_PICK_CONFIRM_PUB
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

/*#
 * Pick Confirm OPM Orders API
 * This API pick confirms, or stages the inventory for, a Process
 * Move Order Line or a Delivery detail Line, depending on whether a
 * delivery detail line id or a move order line id is passed as a parameter.
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list (default 'F')
 * @param p_commit Flag for commiting the data or not (default 'F')
 * @param p_mo_line_id id of the transaction request record (open and move order type 3) in table.
Length 10 (default 0)
 * @param p_delivery_detail_id id of the delivery detail record (S-released) in table
Length 10 (default 0)
 * @param p_bk_ordr_if_no_alloc flag to enable bypass allocations
exist check in Public layer of pick confirm API (default 'Y')
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname GMI Pick Confirm OPM Orders API
*/
PROCEDURE Pick_Confirm (
     p_api_version               IN  NUMBER
   , p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_line_id                IN  NUMBER   DEFAULT NULL
   , p_delivery_detail_id        IN  NUMBER   DEFAULT NULL
   -- Bug 3274586 - Added parameter p_bk_ordr_if_no_alloc to enable bypass
   --               allocations exist check in Public layer of pick confirm API
   , p_bk_ordr_if_no_alloc       IN  VARCHAR2 DEFAULT 'Y'
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   );

PROCEDURE PrintMsg (
     p_msg                 IN  VARCHAR2
   , p_file_name           IN  VARCHAR2 DEFAULT '0');

END GMI_PICK_CONFIRM_PUB;

 

/
