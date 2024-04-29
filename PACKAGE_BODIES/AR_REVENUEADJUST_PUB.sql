--------------------------------------------------------
--  DDL for Package Body AR_REVENUEADJUST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_REVENUEADJUST_PUB" AS
/*$Header: ARXPRADB.pls 120.7.12000000.2 2008/08/28 20:03:25 mraymond ship $*/

  G_PKG_NAME          CONSTANT VARCHAR2(30):= 'AR_RevenueAdjust_PUB';
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'),'N');


-----------------------------------------------------------------------
--   The following subroutine group_compatible is local procedure
--   introdcued for the Sales Group project.  This subroutine checks
--   for backward compatibility.  If the API user passes 'B' for
--   sales_credit_type indicating both Revenue and Non-Revenue then
--   from_salesgroup_id  or to_salesgroup_id can not be populated.
--   if they are then we raise an error.
------------------------------------------------------------------------

FUNCTION group_compatible (
  p_rev_adj_rec ar_revenue_adjustment_pvt.rev_adj_rec_type)
  RETURN BOOLEAN IS

BEGIN

  IF p_rev_adj_rec.sales_credit_type = 'B' THEN
    IF (p_rev_adj_rec.from_salesgroup_id IS NOT NULL OR
        p_rev_adj_rec.to_salesgroup_id IS NOT NULL) THEN
      RETURN FALSE;
    END IF;
  END IF;

  RETURN TRUE;

END group_compatible;

-----------------------------------------------------------------------
--	API name 	: Unearn_Revenue
--	Type		: Public
--	Function	: Transfers a specified amount of revenue from
--                        earned to unearned revenue account
--	Pre-reqs	: Sufficient earned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				Initial version created 31-MAY-2000
--			  Initial version 	1.0
--
--	Notes		:
--
-----------------------------------------------------------------------

PROCEDURE Unearn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2)
  IS
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Unearn_Revenue';
    l_api_version           	CONSTANT NUMBER 	:= 2.0;
    l_org_return_status VARCHAR2(1);
    l_org_id                           NUMBER;
  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('AR_RevenueAdjust_PUB.Unearn_Revenue()+');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT	Unearn_Revenue_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('Unearn_Revenue: ' || '.Unexpected EXCEPTION '||sqlerrm||
                     ' at AR_RevenueAdjust_PUB.Unearn_Revenue()+');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE
    -- Introduced for the Sales Group Project.
    -- ORASHID 11-AUG-2003
    --
    IF NOT group_compatible(p_rev_adj_rec) THEN
      fnd_message.set_name('AR','AR_INCOMPATIBLE_CREDIT_TYPE');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    AR_Revenue_Adjustment_PVT.Unearn_Revenue
          (   p_api_version          => 2.0
             ,p_init_msg_list        => p_init_msg_list
             ,p_commit	             => p_commit
             ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,p_rev_adj_rec          => p_rev_adj_rec
             ,x_adjustment_id        => x_adjustment_id
             ,x_adjustment_number    => x_adjustment_number);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
 END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Unearn_Revenue_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Unearn_Revenue: ' || 'Unexpected EXCEPTION '||sqlerrm||
                             ' at AR_RevenueAdjust_PUB.Unearn_Revenue()+');
                END IF;
		ROLLBACK TO Unearn_Revenue_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Unearn_Revenue: ' || 'Unexpected EXCEPTION '||sqlerrm||
                             ' at AR_RevenueAdjust_PUB.Unearn_Revenue()+');
                END IF;
		ROLLBACK TO Unearn_Revenue_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  END Unearn_Revenue;

-----------------------------------------------------------------------
--	API name 	: Earn_Revenue
--	Type		: Public
--	Function	: Transfers a specified amount of revenue from
--                        unearned to earned revenue account
--	Pre-reqs	: Sufficient unearned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Optional
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				Initial version created 31-MAY-2000
--			  Initial version 	1.0
--
--	Notes		:
--
-----------------------------------------------------------------------
  PROCEDURE Earn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2)
  IS
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Earn_Revenue';
    l_api_version           	CONSTANT NUMBER 	:= 2.0;
    l_org_return_status VARCHAR2(1);
    l_org_id                           NUMBER;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Earn_Revenue_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('Earn_Revenue: ' || 'Unexpected EXCEPTION '||sqlerrm||
                               ' at AR_RevenueAdjust_PUB.Earn_Revenue()+');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE
    -- Introduced for the Sales Group Project.
    -- ORASHID 11-AUG-2003
    --
    IF NOT group_compatible(p_rev_adj_rec) THEN
      fnd_message.set_name('AR','AR_INCOMPATIBLE_CREDIT_TYPE');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    AR_Revenue_Adjustment_PVT.Earn_Revenue
          (   p_api_version          => 2.0
             ,p_init_msg_list        => p_init_msg_list
             ,p_commit	             => p_commit
             ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,p_rev_adj_rec          => p_rev_adj_rec
             ,x_adjustment_id        => x_adjustment_id
             ,x_adjustment_number    => x_adjustment_number);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
 END IF;
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Earn_Revenue_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Earn_Revenue: ' || 'Unexpected EXCEPTION '||sqlerrm||
                               ' at AR_RevenueAdjust_PUB.Earn_Revenue()+');
                END IF;
		ROLLBACK TO Earn_Revenue_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Earn_Revenue: ' || 'Unexpected EXCEPTION '||sqlerrm||
                               ' at AR_RevenueAdjust_PUB.Earn_Revenue()+');
                END IF;
		ROLLBACK TO Earn_Revenue_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  END Earn_Revenue;

-----------------------------------------------------------------------
--	API name 	: Transfer_Sales_Credits
--	Type		: Public
--	Function	: Transfers revenue and/or non revenue sales credits
--                        between the specified salesreps. The associated
--                        earned revenue is transferred with revenue sales
--                        credits
--	Pre-reqs	: Sufficient earned revenue must exist for the salesrep
--                        from whom sales credits are being transferred.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Optional
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				Initial version created 31-MAY-2000
--			  Initial version 	1.0
--
--	Notes		:
--
-----------------------------------------------------------------------
  PROCEDURE Transfer_Sales_Credits
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2)
  IS
    l_api_name            CONSTANT VARCHAR2(30) := 'Transfer_Sales_Credits';
    l_api_version         CONSTANT NUMBER 	:= 2.0;
    l_org_return_status VARCHAR2(1);
    l_org_id                           NUMBER;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('AR_RevenueAdjust_PUB.Transfer_Sales_Credits()+');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT	Transfer_Sales_Credits_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('Transfer_Sales_Credits: ' || 'Unexpected EXCEPTION '||sqlerrm||
                     ' at AR_RevenueAdjust_PUB.Transfer_Sales_Credits()+');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;



/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE
    -- Introduced for the Sales Group Project.
    -- ORASHID 11-AUG-2003
    --
    IF NOT group_compatible(p_rev_adj_rec) THEN
      fnd_message.set_name('AR','AR_INCOMPATIBLE_CREDIT_TYPE');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits
          (   p_api_version          => 2.0
             ,p_init_msg_list        => p_init_msg_list
             ,p_commit	             => p_commit
             ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,p_rev_adj_rec          => p_rev_adj_rec
             ,x_adjustment_id        => x_adjustment_id
             ,x_adjustment_number    => x_adjustment_number);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
 END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Transfer_Sales_Credits_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Transfer_Sales_Credits: ' || 'Unexpected EXCEPTION '||sqlerrm||
                    ' at AR_RevenueAdjust_PUB.Transfer_Sales_Credits()+');
                END IF;
		ROLLBACK TO Transfer_Sales_Credits_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Transfer_Sales_Credits: ' || 'Unexpected EXCEPTION '||sqlerrm||
                     ' at AR_RevenueAdjust_PUB.Transfer_Sales_Credits()+');
                END IF;
		ROLLBACK TO Transfer_Sales_Credits_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);

  END Transfer_Sales_Credits;

-----------------------------------------------------------------------
--	API name 	: Add_Non_Revenue_Sales_Credits
--	Type		: Public
--	Function	: Adds non revenue sales credits to the specified
--                        salesrep subject to any maximum limit of revenue
--                        and non revenue sales credit per salesrep per line
--                        as defined in the sales credit percent limit in
--                        system options.
--	Pre-reqs	: None
--
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Optional
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				Initial version created 31-MAY-2000
--			  Initial version 	1.0
--
--	Notes		:
--
  PROCEDURE Add_Non_Revenue_Sales_Credits
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2)
  IS
    l_api_name            CONSTANT VARCHAR2(30) :=
                                                'Add_Non_Revenue_Sales_Credits';
    l_api_version         CONSTANT NUMBER 	:= 2.0;
    l_org_return_status VARCHAR2(1);
    l_org_id                           NUMBER;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('AR_RevenueAdjust_PUB.Add_Non_Revenue_Sales_Credits()+');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT Add_Non_Rev_Sales_Credits_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('Add_Non_Revenue_Sales_Credits: ' || 'Unexpected EXCEPTION '||sqlerrm||
              ' at AR_RevenueAdjust_PUB.Add_Non_Revenue_Sales_Credits()+');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE
    -- Introduced for the Sales Group Project.
    -- ORASHID 11-AUG-2003
    --
    IF NOT group_compatible(p_rev_adj_rec) THEN
      fnd_message.set_name('AR','AR_INCOMPATIBLE_CREDIT_TYPE');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits
          (   p_api_version          => 2.0
             ,p_init_msg_list        => p_init_msg_list
             ,p_commit	             => p_commit
             ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,p_rev_adj_rec          => p_rev_adj_rec
             ,x_adjustment_id        => x_adjustment_id
             ,x_adjustment_number    => x_adjustment_number);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
 END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Add_Non_Rev_Sales_Credits_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Add_Non_Revenue_Sales_Credits: ' || 'Unexpected EXCEPTION '||sqlerrm||
              ' at AR_RevenueAdjust_PUB.Add_Non_Revenue_Sales_Credits()+');
                END IF;
		ROLLBACK TO Add_Non_Rev_Sales_Credits_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Add_Non_Revenue_Sales_Credits: ' || 'Unexpected EXCEPTION '||sqlerrm||
              ' at AR_RevenueAdjust_PUB.Add_Non_Revenue_Sales_Credits()+');
                END IF;
		ROLLBACK TO Add_Non_Rev_Sales_Credits_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
   END Add_Non_Revenue_Sales_Credits;

-----------------------------------------------------------------------
--	API name 	: Record_Customer_Acceptance
--	Type		: Public
--	Function	: Identifies customer_acceptance contingencies
--                        for the specified transaction or line and
--                        clears them.  Also recognizes revenue if
--                        the customer_acceptance contingency was the
--                        last issue for the line.
--	Pre-reqs	: None
--
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Optional
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--
--	Version	: Current version	2.0
--		Initial version created 26-JUN-2006
--	        Initial version 	2.0
--
--	Notes		:
--
  PROCEDURE Record_Customer_Acceptance
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL)
  IS
    l_api_name            CONSTANT VARCHAR2(30) :=
                                                'Record_Customer_Acceptance';
    l_api_version         CONSTANT NUMBER 	:= 2.0;
    l_org_return_status   VARCHAR2(1);
    l_org_id              NUMBER;
    li_desc_flexfield     ar_revenue_management_pvt.desc_flexfield;
    lo_scenario           NUMBER;
    lo_first_rev_adj_id   NUMBER;
    lo_last_rev_adj_id    NUMBER;
    l_scenario            VARCHAR2(128);
  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('AR_RevenueAdjust_PUB.Record_Customer_Acceptance()+');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT Record_Customer_Acceptance_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('Unexpected EXCEPTION '||sqlerrm||
              ' at AR_RevenueAdjust_PUB.Record_Customer_Acceptance()+');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE
    /* Copy desc flexfield data */
    li_desc_flexfield.attribute_category := p_rev_adj_rec.attribute_category;
    li_desc_flexfield.attribute1 := p_rev_adj_rec.attribute1;
    li_desc_flexfield.attribute2 := p_rev_adj_rec.attribute2;
    li_desc_flexfield.attribute3 := p_rev_adj_rec.attribute3;
    li_desc_flexfield.attribute4 := p_rev_adj_rec.attribute4;
    li_desc_flexfield.attribute5 := p_rev_adj_rec.attribute5;
    li_desc_flexfield.attribute6 := p_rev_adj_rec.attribute6;
    li_desc_flexfield.attribute7 := p_rev_adj_rec.attribute7;
    li_desc_flexfield.attribute8 := p_rev_adj_rec.attribute8;
    li_desc_flexfield.attribute9 := p_rev_adj_rec.attribute9;
    li_desc_flexfield.attribute10 := p_rev_adj_rec.attribute10;
    li_desc_flexfield.attribute11 := p_rev_adj_rec.attribute11;
    li_desc_flexfield.attribute12 := p_rev_adj_rec.attribute12;
    li_desc_flexfield.attribute13 := p_rev_adj_rec.attribute13;
    li_desc_flexfield.attribute14 := p_rev_adj_rec.attribute14;
    li_desc_flexfield.attribute15 := p_rev_adj_rec.attribute15;

    /* Call internal procedure to record acceptance */
    AR_Revenue_Adjustment_PVT.Record_Acceptance
          (   p_customer_trx_id      => p_rev_adj_rec.customer_trx_id
             ,p_category_id          => p_rev_adj_rec.from_category_id
             ,p_inventory_item_id    => p_rev_adj_rec.from_inventory_item_id
             ,p_customer_trx_line_id => p_rev_adj_rec.from_cust_trx_line_id
             ,p_gl_date              => p_rev_adj_rec.gl_date
             ,p_comments             => p_rev_adj_rec.comments
             ,p_ram_desc_flexfield   => li_desc_flexfield
             ,x_scenario             => lo_scenario
             ,x_first_rev_adj_id     => lo_first_rev_adj_id
             ,x_last_rev_adj_id      => lo_last_rev_adj_id
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data);

    /* Document results in debug log */
    IF PG_DEBUG in ('Y', 'C') THEN
         IF lo_scenario = 0
         THEN
            l_scenario := 'Transaction revenue NOT recognized';
         ELSIF lo_scenario = 1
         THEN
            l_scenario := 'Transaction revenue PARTIALLY recognized';
         ELSIF lo_scenario = 2
         THEN
            l_scenario := 'Transaction revenue FULLY recognized';
         ELSE
            l_scenario := 'UNKNOWN RESULT';
         END IF;

         arp_debug.debug('first rev_adj_id = ' || lo_first_rev_adj_id);
         arp_debug.debug('last rev_adj_id  = ' || lo_last_rev_adj_id);
         arp_debug.debug('result (scenario)= ' || l_scenario);
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
 END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Add_Non_Rev_Sales_Credits_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Unexpected EXCEPTION '||sqlerrm||
              ' at AR_RevenueAdjust_PUB.Record_Customer_Acceptance()+');
                END IF;
		ROLLBACK TO Record_Customer_Acceptance_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Unexpected EXCEPTION '||sqlerrm||
              ' at AR_RevenueAdjust_PUB.Record_Customer_Acceptance()+');
                END IF;
		ROLLBACK TO Record_Customer_Acceptance_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
   END Record_Customer_Acceptance;

-----------------------------------------------------------------------
--	API name 	: Update_Contingency_Expirations
--	Type		: Public
--	Function	: Update contingency expiration_date(s)
--                        for a transaction or line.
--                        Also recognizes revenue if
--                        the contingency has expired.
--	Pre-reqs	: None
--
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_customer_trx_id       NUMBER       Required
--                        p_customer_trx_line_id  NUMBER       Optional
--                        p_contingency_id        NUMBER       Optional
--                        p_expiration_date       DATE         Optional
--                        p_expiration_days       NUMBER       Optional
-- NOTE:  Must pass either date or days
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--
--	Version	: Current version	2.0
--		Initial version created 26-JUN-2006
--	        Initial version 	2.0
--
--	Notes		:
/*    27-AUG-2008      MRAYMOND  7311553   added line_id to
                                     revenue_synchronizer call.
*/
  PROCEDURE Update_Contingency_Expirations
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,p_customer_trx_id       IN  ra_customer_trx.customer_trx_id%type
     ,p_customer_trx_line_id  IN  ra_customer_trx_lines.customer_trx_line_id%type DEFAULT NULL
     ,p_contingency_id        IN  ar_line_conts.contingency_id%type DEFAULT NULL
     ,p_expiration_date       IN  ar_line_conts.expiration_date%type DEFAULT NULL
     ,p_expiration_days       IN  ar_line_conts.expiration_days%type DEFAULT NULL)
  IS
    l_api_name            CONSTANT VARCHAR2(30) :=
                                                'Update_Contingency_Expirations';
    l_api_version         CONSTANT NUMBER 	:= 2.0;
    l_org_return_status   VARCHAR2(1);
    l_org_id              NUMBER;
    lo_scenario           NUMBER;
    lo_first_adj_number   NUMBER;
    lo_last_adj_number    NUMBER;
    l_scenario            VARCHAR2(128);
    l_expiration_date     DATE;
    l_expiration_days     NUMBER;

    CURSOR c_conts IS
       select lc.customer_trx_line_id  customer_trx_line_id,
              lc.contingency_id        contingency_id,
              NVL(lc.expiration_event_date,
                decode(dr.expiration_event_code,
                  'TRANSACTION_DATE', trunc(t.trx_date),
                  'SHIP_CONFIRM_DATE', trunc(t.ship_date_actual), NULL))
              expiration_event_date
       from   ra_customer_trx t,
              ra_customer_trx_lines tl,
              ar_line_conts lc,
              ar_deferral_reasons dr
       where  t.customer_trx_id = p_customer_trx_id
       and    t.customer_trx_id = tl.customer_trx_id
       and    tl.customer_trx_line_id = nvl(p_customer_trx_line_id,
                                            tl.customer_trx_line_id)
       and    tl.line_type = 'LINE'
       and    tl.customer_trx_line_id = lc.customer_trx_line_id
       and    lc.contingency_id = nvl(p_contingency_id, lc.contingency_id)
       and    lc.contingency_id = dr.contingency_id
       and    lc.completed_flag = 'N'
       and    dr.revrec_event_code = 'CONTINGENCY_EXPIRATION';

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('AR_RevenueAdjust_PUB.Update_Contingency_Expirations()+');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT Update_Contingency_Expires_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('Unexpected EXCEPTION '||sqlerrm||
              ' at AR_RevenueAdjust_PUB.Update_Contingency_Expirations()+');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE
    /* Make sure we have either an expiration_date or
        an expiration_days passed in */
    IF  p_expiration_days IS NULL and
        p_expiration_date IS NULL
    THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('AR','AR_RVMG_EXPIR_DATE_CONFL');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    /* Loop thru eligible contingencies and update */
    FOR cont IN c_conts LOOP

      /* Determine new expiration date */
      IF p_expiration_date IS NOT NULL
      THEN
         l_expiration_date := TRUNC(p_expiration_date);
         l_expiration_days := l_expiration_date - cont.expiration_event_date;
      ELSE
         /* days */
         l_expiration_days := p_expiration_days;
         l_expiration_date := TRUNC(cont.expiration_event_date +
                                      l_expiration_days);
      END IF;

      IF PG_DEBUG IN ('Y', 'C')
      THEN
         arp_debug.debug('updating line:' || cont.customer_trx_line_id ||
                         '  cont_id:' || cont.contingency_id ||
                         '  expiration_date:' || l_expiration_date);
      END IF;

      ar_revenue_management_pvt.update_line_conts(
	 p_customer_trx_line_id  => cont.customer_trx_line_id
	,p_contingency_id	 => cont.contingency_id
	,p_expiration_date	 => l_expiration_date
	,p_expiration_event_date => cont.expiration_event_date
	,p_expiration_days	 => l_expiration_days
	,p_completed_flag	 => NULL
	,p_reason_removal_date	 => NULL);

    END LOOP;

    /* Now synch up the revenue for any expired contingencies */
    ar_revenue_management_pvt.revenue_synchronizer(
              p_mode                 => 3
            , p_customer_trx_id      => p_customer_trx_id
            , p_customer_trx_line_id => p_customer_trx_line_id
            , p_gl_date              => NULL
            , p_comments             => NULL
            , p_ram_desc_flexfield   => NULL
            , x_scenario 		=> lo_scenario
            , x_first_adjustment_number => lo_first_adj_number
            , x_last_adjustment_number  => lo_last_adj_number
            , x_return_status           => x_return_status
            , x_msg_count               => x_msg_count
            , x_msg_data                => x_msg_data);

    /* Document results in debug log */
    IF PG_DEBUG in ('Y', 'C') THEN
         IF lo_scenario = 0
         THEN
            l_scenario := 'Transaction revenue NOT recognized';
         ELSIF lo_scenario = 1
         THEN
            l_scenario := 'Transaction revenue PARTIALLY recognized';
         ELSIF lo_scenario = 2
         THEN
            l_scenario := 'Transaction revenue FULLY recognized';
         ELSE
            l_scenario := 'UNKNOWN RESULT';
         END IF;

         arp_debug.debug('first rev_adj_id = ' || lo_first_adj_number);
         arp_debug.debug('last rev_adj_id  = ' || lo_last_adj_number);
         arp_debug.debug('result (scenario)= ' || l_scenario);
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
 END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Add_Non_Rev_Sales_Credits_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Unexpected EXCEPTION '||sqlerrm||
              ' at AR_RevenueAdjust_PUB.Update_Contingency_Expirations()');
                END IF;
		ROLLBACK TO Record_Customer_Acceptance_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_debug.debug('Unexpected EXCEPTION '||sqlerrm||
              ' at AR_RevenueAdjust_PUB.Update_Contingency_Expirations()');
                END IF;
		ROLLBACK TO Record_Customer_Acceptance_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
   END Update_Contingency_Expirations;

END AR_RevenueAdjust_PUB;

/
