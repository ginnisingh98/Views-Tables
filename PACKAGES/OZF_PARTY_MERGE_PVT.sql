--------------------------------------------------------
--  DDL for Package OZF_PARTY_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PARTY_MERGE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvprms.pls 120.1 2005/07/18 16:06:54 appldev ship $ */

PROCEDURE OFFER_BUY_GROUP_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);


PROCEDURE Trade_Profile_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE Claim_Broker_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE Claim_Contact_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE Claim_History_Broker_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE Claim_History_Contact_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE Budget_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE Budget_Vendor_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);


PROCEDURE Offer_Denorm_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE Claim_Line_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Claim_Line_Hist_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Code_Conversion_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Batch_Prtn_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Batch_Prtn_Cnt_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Int_Ship_Frm_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Int_Sold_Frm_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Int_Bill_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Int_Bill_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Int_Ship_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Int_Ship_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Int_End_Cust_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Int_End_Cust_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Head_Bill_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Head_Bill_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Head_Ship_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Head_Ship_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Line_Ship_Frm_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Line_Sold_Frm_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Line_Bill_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Line_Bill_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Line_Ship_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Line_Ship_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Line_End_Cust_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Resale_Line_End_Cust_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Request_Head_End_Cust_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Request_Head_Reseller_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Acct_Alloc_Parent_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE Acct_Alloc_Rollup_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Offer_Autopay_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

PROCEDURE Request_Head_Partner_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) ;

END OZF_PARTY_MERGE_PVT;

 

/
