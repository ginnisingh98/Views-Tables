--------------------------------------------------------
--  DDL for Package CS_CHARGE_CREATE_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHARGE_CREATE_ORDER_PVT" AUTHID CURRENT_USER as
/* $Header: csxvchos.pls 120.0.12010000.1 2008/07/24 18:46:38 appldev ship $ */
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Order
--   Type    :  Public
--   Purpose :  This API is for submitting an order.
--              It is intended for use by the owning module only; contrast to published API.
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
--       p_submit_source	     IN	     VARCHAR2   Optional
--       p_submit_from_system    IN	     VARCHAR2   Optional
--   OUT:
--       x_return_status         OUT    NOCOPY     VARCHAR2
--       x_msg_count             OUT    NOCOPY     NUMBER
--       x_msg_data              OUT    NOCOPY     VARCHAR2
--   Version : Current version 1.0
--   End of Comments
--
PROCEDURE Submit_Order(
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2,
    p_commit                IN      VARCHAR2,
    p_validation_level      IN      NUMBER,
    p_incident_id           IN      NUMBER,
    p_party_id              IN      NUMBER,
    p_account_id            IN      NUMBER,
    p_book_order_flag       IN      VARCHAR2 := FND_API.G_MISS_CHAR, --new
    p_submit_source	        IN	    VARCHAR2 := FND_API.G_MISS_CHAR, --new
    p_submit_from_system    IN	    VARCHAR2 := FND_API.G_MISS_CHAR, --new
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
);


-- The Update_Estimate_Details is copied from csxchors.pls file -version 115.8
-- Added new parameters for 11.5.10 : p_submit_error_message and p_submit_from_system

PROCEDURE Update_Estimate_Details (
    p_Estimate_Detail_Id    IN      NUMBER,
    p_order_header_Id       IN      NUMBER,
    p_order_line_Id         IN      NUMBER,
    p_line_submitted        IN	    VARCHAR2,
    p_submit_restriction_message IN	VARCHAR2,-- new
    p_submit_error_message	 IN	VARCHAR2,-- new
    p_submit_from_system 	 IN	VARCHAR2 -- new
);

End CS_Charge_Create_Order_PVT;

/
