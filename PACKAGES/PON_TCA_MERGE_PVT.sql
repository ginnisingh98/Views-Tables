--------------------------------------------------------
--  DDL for Package PON_TCA_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_TCA_MERGE_PVT" AUTHID CURRENT_USER as
/* $Header: PONTCMGS.pls 120.3 2005/11/28 09:42:17 sapandey noship $ */

G_BUYER              CONSTANT VARCHAR2(20) := 'BUYER';
G_SELLER             CONSTANT VARCHAR2(20) := 'SELLER';
G_INCOMPATIBLE CONSTANT VARCHAR2(20) := 'INCOMPATIBLE';
G_IRRELEVANT     CONSTANT VARCHAR2(20)  := 'IRRELEVANT';


/*PROCEDURE PARTY_MERGE(p_Entity_name        IN VARCHAR2,
                      p_from_id            IN NUMBER,
                      p_to_id              IN OUT NOCOPY NUMBER ,
                      p_From_FK_id         IN NUMBER,
                      p_To_FK_id           IN NUMBER,
                      p_Parent_Entity_name IN VARCHAR2,
                      p_batch_id           IN NUMBER,
                      p_Batch_Party_id     IN NUMBER,
                      p_return_status      IN OUT NOCOPY VARCHAR2 );*/

-- Start of comments
--      API name : VETO_ENTERPRISE_PARTY_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given trading_partner_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the Trading Partner Id
--                        merge for Sourcing Buyer entities thus it will simply veto the
--                        accidental merge without checking any thing.
--
--                        So, DO NOT attach this procedure to any other Party Merge
--                        scenario apart from the Enterprise Buyer Party merge case
--                        for which it is designed
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE VETO_ENTERPRISE_PARTY_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );


-- Start of comments
--      API name : NEG_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_HEADERS_ALL entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_HEADERS_ALL records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_TPC_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : NEG_DRFT_LCK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given draft_locked_by_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the DRAFT_LOCKED_BY_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_HEADERS_ALL entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_HEADERS_ALL records
--                        having DRAFT_LOCKED_BY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DRFT_LCK_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : NEG_DRFT_UNLCK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given draft_unlocked_by_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the DRAFT_UNLOCKED_BY_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_HEADERS_ALL entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_HEADERS_ALL records
--                        having DRAFT_UNLOCKED_BY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DRFT_UNLCK_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : NEG_SCORE_LCK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given scoring_lock_tp_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SCORING_LOCK_TP_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_HEADERS_ALL entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_HEADERS_ALL records
--                        having SCORING_LOCK_TP_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_SCORE_LCK_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );


-- Start of comments
--      API name : NEG_EVENT_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation Event with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_EVENTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_EVENTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_EVENT_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : BIDDER_LST_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Bidders List with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_BIDDERS_LISTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_BIDDERS_LISTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE BIDDER_LST_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : NEG_ATTR_LST_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Attributes List with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_ATTRIBUTE_LISTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_ATTRIBUTE_LISTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_ATTR_LST_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : RES_SURROG_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given surrog_bid_created_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SURROG_BID_CREATED_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having SURROG_BID_CREATED_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_SURROG_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : RES_SCORE_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given score_override_tp_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SCORE_OVERRIDE_TP_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having SCORE_OVERRIDE_TP_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_SCORE_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : RES_SHRT_LIST_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given shortlist_tpc_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SHORTLIST_TPC_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having SHORTLIST_TPC_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_SHRT_LIST_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : NEG_CONTRCT_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotitions with the given authoring_party_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the AUTHORING_PARTY_CONTACT_ID
--                        merge for Sourcing PON_CONTRACTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_CONTRACTS records
--                        having AUTHORING_PARTY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_CONTRCT_MERGE   (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : NEG_DISC_THR_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Discussion Messages with the given owner_party_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the OWNER_PARTY_ID
--                        merge for Sourcing PON_THREADS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--                               OR
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_THREADS records
--                        having OWNER_PARTY_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DISC_THR_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );


-- Start of comments
--      API name : NEG_DISC_THR_ENTRY_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Discussion Message Entries with the given from_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the FROM_ID
--                        merge for Sourcing PON_THREAD_ENTRIES entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--                               OR
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_THREAD_ENTRIES records
--                        having FROM_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DISC_THR_ENTRY_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : NEG_COMP_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Trading Partner ID entries with the given from_company_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_ID (p_From_FK_id)
--                        merge for different Sourcing entities (like PON_THREAD_ENTRIES etc.).
--
--                        It will veto Party Merge if -
--                               p_From_FK_id or p_To_FK_id is/are Buyer company party
--                               OR
--                               p_From_FK_id is Seller but p_To_FK_id is not Buyer or Seller party
--                               OR
--                               p_To_FK_id is Seller but p_From_FK_id is not Buyer or Seller party
--
--                        This will check the merge possibility for the entities
--                        having TRADING_PARTNER_ID equals to p_From_FK_id
--                        to TRADING_PARTNER_ID having value (p_To_FK_id). This will raise veto
--                        if the merge is not possible.
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_COMP_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );



-- Start of comments
--      API name : NEG_DISC_TE_RCP_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Discussion Message Thread Entries with the given to_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TO_ID
--                        merge for Sourcing PON_TE_RECIPIENTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--                               OR
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_TE_RECIPIENTS records
--                        having TO_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DISC_TE_RCP_MERGE   (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : RES_SURR_ACK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given surrog_bid_ack_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SURROG_BID_ACK_CONTACT_ID
--                        merge for Sourcing PON_ACKNOWLEDGEMENTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_ACKNOWLEDGEMENTS records
--                        having SURROG_BID_ACK_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_SURR_ACK_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );


-- Start of comments
--      API name : NEG_SUPP_ACC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Supplier Access Lock entries with the given buyer_tp_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the BUYER_TP_CONTACT_ID
--                        merge for Sourcing PON_SUPPLIER_ACCESS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_SUPPLIER_ACCESS records
--                        having BUYER_TP_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_SUPP_ACC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );


-- Start of comments
--      API name : BID_PARTY_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Invitation List entries with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_BIDDING_PARTIES entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_BIDDING_PARTIES records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE BID_PARTY_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : BID_PARTY_ACK_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Invitation List entries with the given ack_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the ACK_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_BIDDING_PARTIES entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_BIDDING_PARTIES records
--                        having ACK_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE BID_PARTY_ACK_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : RES_UNLCK_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given draft_unlocked_by_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the DRAFT_UNLOCKED_BY_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having DRAFT_UNLOCKED_BY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_UNLCK_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : RES_LCK_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given draft_locked_by_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the DRAFT_LOCKED_BY_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having DRAFT_LOCKED_BY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_LCK_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : RES_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : OPTMZ_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Optimization Scenario with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_OPTIMIZE_CONSTRAINTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_OPTIMIZE_CONSTRAINTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE OPTMZ_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : RES_ACK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Invitation Response  with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_ACKNOWLEDGEMENTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_ACKNOWLEDGEMENTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_ACK_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );


-- Start of comments
--      API name : AUC_SUMM_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Award Summary records with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_SUMMARY entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_AUCTION_SUMMARY records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE AUC_SUMM_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );

-- Start of comments
--      API name : SUP_ACT_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Supplier Activity records with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_SUPPLIER_ACTIVITIES entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_SUPPLIER_ACTIVITIES records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE SUP_ACT_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 );




END PON_TCA_MERGE_PVT;

 

/
