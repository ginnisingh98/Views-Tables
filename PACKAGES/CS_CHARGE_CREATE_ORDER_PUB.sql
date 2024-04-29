--------------------------------------------------------
--  DDL for Package CS_CHARGE_CREATE_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHARGE_CREATE_ORDER_PUB" AUTHID CURRENT_USER as
/* $Header: csxpchos.pls 120.9 2006/09/07 01:43:47 jngeorge ship $ */
/*#
 * Submits all eligible charge lines in a service request to Oracle Order Management and creates new
 * orders and lines. For details on the parameters, please refer to the document on Metalink
 * from the URL provided above
 *
 * @rep:scope public
 * @rep:product CS
 * @rep:displayname Charge Transformation into Orders
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CS_SERVICE_CHARGE
 * @rep:metalink 390503.1 Oracle Teleservice Implementation Guide Release 12.0
 */
/**** Above text has been added to enable the integration repository to extract the data from
      the source code file and populate the integration repository schema so that the interfaces
      defined in this package appears in the integration repository.
****/


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Order
--   Type    :  Public
--   Purpose :  This API is for submitting an order and a wrapper on
--              CS_Charge_Create_Order_PVT.Submit_Order procedure.
--              It is intended for use by all applications; contrast to Private API.
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version           IN      NUMBER     Required
--       p_init_msg_list         IN      VARCHAR2   Optional
--       p_commit                IN      VARCHAR2   Optional
--       p_validation_level      IN      NUMBER     Optional
--       p_incident_id           IN      NUMBER     Required
--       p_party_id              IN      NUMBER     Required
--       p_account_id            IN      NUMBER     Optional see bug#2447927, changed p_account_id to optional param.
--       p_book_order_flag       IN      VARCHAR2   Optional
--	     p_submit_source	     IN	     VARCHAR2	Optional
--	     p_submit_from_system	 IN  	 VARCHAR2	Optional
--   OUT:
--       x_return_status         OUT    NOCOPY     VARCHAR2
--       x_msg_count             OUT    NOCOPY     NUMBER
--       x_msg_data              OUT    NOCOPY     VARCHAR2
--   Version : Current version 1.0
--   End of Comments
--

/*#
 * Submit Order, can be used to transform all eligible charge lines under a given
 * service request to orders and order lines. This submission process either creates new orders or adds
 * lines to existing orders.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Submit Charges and Create Orders
 * @rep:primaryinstance
 * @rep:businessevent oracle.apps.cs.chg.Charges.submitted
 * @rep:metalink 390503.1 Oracle Teleservice Implementation Guide Release 12.0
*/

/**** Above text has been added to enable the integration repository to extract the data from
      the source code file and populate the integration repository schema so that Submit_Order
      API appears in the integration repository.
****/

PROCEDURE Submit_Order(
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2,
    p_commit                IN      VARCHAR2,
    p_validation_level      IN      NUMBER,
    p_incident_id           IN      NUMBER,
    p_party_id              IN      NUMBER,
    p_account_id            IN      NUMBER,
    p_book_order_flag       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_submit_source	        IN	    VARCHAR2 := FND_API.G_MISS_CHAR,
    p_submit_from_system    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
);

End CS_Charge_Create_Order_PUB;

 

/
