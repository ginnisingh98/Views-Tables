--------------------------------------------------------
--  DDL for Package INV_STANDALONE_SYNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_STANDALONE_SYNC_PUB" AUTHID CURRENT_USER as
/* $Header: INVSLSPS.pls 120.0.12010000.2 2009/04/13 21:27:18 yssingh noship $*/

-- This API updates receipt confirmation extracted flag in RT.
FUNCTION Update_RC_Extracted (
             p_api_version          IN         NUMBER
           , p_init_msg_list        IN         VARCHAR2  := FND_API.G_FALSE
           , p_commit               IN         VARCHAR2  := FND_API.G_FALSE
           , x_return_status        OUT NOCOPY VARCHAR2
           , x_msg_count            OUT NOCOPY NUMBER
           , x_msg_data             OUT NOCOPY VARCHAR2
           , p_start_date           IN         VARCHAR2
           , p_end_date             IN         VARCHAR2
           , p_category             IN         VARCHAR2 DEFAULT NULL
           , p_warehouse            IN         VARCHAR2
           , p_document_num         IN         VARCHAR2 DEFAULT NULL
           , p_receipt_num          IN         VARCHAR2
           , p_inventory_item       IN         VARCHAR2 DEFAULT NULL
           , p_rc_extracted         IN         VARCHAR2
           , p_transaction_id       IN         NUMBER   DEFAULT NULL
          ) RETURN VARCHAR2;

FUNCTION sync_adjustment_transactions(
           p_api_version                IN         NUMBER
         , p_init_msg_list              IN         VARCHAR2     := FND_API.G_FALSE
         , p_commit                     IN         VARCHAR2     := FND_API.G_FALSE
         , x_return_status              OUT NOCOPY VARCHAR2
         , x_msg_count                  OUT NOCOPY NUMBER
         , x_msg_data                   OUT NOCOPY VARCHAR2
         , p_from_date                  IN         DATE
         , p_to_date                    IN         DATE
         , p_organization_name          IN         VARCHAR2
         , p_category_name              IN         VARCHAR2
         , p_inventory_item             IN         VARCHAR2     DEFAULT NULL
         , p_transaction_type           IN         VARCHAR2     DEFAULT NULL
         , p_transaction_source         IN         VARCHAR2     DEFAULT NULL
         , p_transaction_id             IN         NUMBER       DEFAULT NULL
         , p_extract_flag               IN         VARCHAR2

     ) RETURN VARCHAR2;

PROCEDURE sync_adjustment_transactions2(
       p_api_version                IN         NUMBER
     , p_init_msg_list              IN         VARCHAR2     := FND_API.G_FALSE
     , p_commit                     IN         VARCHAR2     := FND_API.G_FALSE
     , x_return_status              OUT NOCOPY VARCHAR2
     , x_msg_count                  OUT NOCOPY NUMBER
     , x_msg_data                   OUT NOCOPY VARCHAR2
     , p_from_date                  IN         DATE
     , p_to_date                    IN         DATE
     , p_organization_id            IN         NUMBER
     , p_category_name              IN         VARCHAR2
     , p_inventory_item_id          IN         NUMBER       DEFAULT NULL
     , p_transaction_type_id        IN         NUMBER       DEFAULT NULL
     , p_transaction_source         IN         VARCHAR2     DEFAULT NULL
     , p_transaction_id             IN         NUMBER       DEFAULT NULL
     , p_extract_flag               IN         VARCHAR2
     );

END inv_standalone_sync_pub;

/
