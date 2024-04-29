--------------------------------------------------------
--  DDL for Package AMS_PARTY_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PARTY_MERGE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvprms.pls 115.20 2004/01/07 07:03:00 mayjain ship $ */

PROCEDURE REG_PARTY_MERGE
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


PROCEDURE OFFER_PARTY_MERGE
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

PROCEDURE ATN_PARTY_MERGE
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

PROCEDURE CHANNEL_PARTY_MERGE
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

PROCEDURE Party_src_Party_Merge
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

PROCEDURE Segment_Party_Merge
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

PROCEDURE Post_Cust_Party_Merge
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

PROCEDURE Post_Affl_Party_Merge
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

PROCEDURE Campaign_Partner_Merge
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

PROCEDURE Campaign_VAD_Merge
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

PROCEDURE Campaign_Contact_Merge
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

PROCEDURE Product_Comp_Party_Merge
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

PROCEDURE placement_site_party_merge
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

PROCEDURE Src_lines_Party_Merge
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

PROCEDURE List_entries_Party_Merge
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

PROCEDURE Listentries_Parent_Party_Merge
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

PROCEDURE Venues_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
) ;

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

PROCEDURE Resources_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT  NOCOPY NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT  NOCOPY VARCHAR2
) ;

PROCEDURE Agendas_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
) ;

PROCEDURE TCOP_CHANNEL_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
);

PROCEDURE TCOP_CONTACT_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
);

PROCEDURE TCOP_CONTACT_SUMM_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
);

PROCEDURE TCOP_PRVW_CONTACT_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
);

PROCEDURE TCOP_PRVW_FTG_DTL_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
);


END AMS_PARTY_MERGE_PVT;

 

/
