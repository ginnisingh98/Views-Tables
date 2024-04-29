--------------------------------------------------------
--  DDL for Package Body AR_REVENUE_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_REVENUE_ADJUSTMENT_PVT" AS
/*$Header: ARXVRADB.pls 120.38.12010000.16 2009/03/11 18:06:20 mraymond ship $*/

/*=======================================================================+
 |  Global Constants
 +=======================================================================*/
  g_ra_empty_dist_tbl           RA_Dist_Tbl_Type;
  g_ra_dist_tbl                 RA_Dist_Tbl_Type;
  g_dist_count                  NUMBER;
  g_rev_mgt_installed           VARCHAR2(1); -- Bug 2650708
  g_period_set_name             VARCHAR(15);
  g_base_precision              NUMBER;
  g_bmau                        NUMBER;
  g_org_id                      NUMBER;
  g_sob_id                      NUMBER;

  g_warehouse_id                NUMBER;
  g_memo_line_id                NUMBER;
  g_inventory_item_id           NUMBER;
  g_line_id                     NUMBER;

  G_PKG_NAME           CONSTANT VARCHAR2(30):= 'AR_Revenue_Adjustment_PVT';

-----------------------------------------------------------------------
--	API name 	: Unearn_Revenue
--	Type		: Private
--	Function	: Transfers a specified amount of revenue from
--                        earned to unearned revenue account
--	Pre-reqs	: Sufficient earned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--
-----------------------------------------------------------------------
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Unearn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2
     ,p_commit	              IN   VARCHAR2
     ,p_validation_level      IN   NUMBER
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2)
  IS
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Unearn_Revenue';
    l_api_version           	CONSTANT NUMBER 	:= 2.0;
    l_rev_adj_rec               AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Unearn_Revenue()+');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT	Unearn_Revenue_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Unearn_Revenue: ' || '.Unexpected error '||sqlerrm||
                     ' at AR_Revenue_Adjustment_PVT.Unearn_Revenue()+');
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

    l_rev_adj_rec := p_rev_adj_rec;

    /*Bug 6731185 JVARKEY Making sure GL date has no timestamp*/
    l_rev_adj_rec.gl_date := trunc(p_rev_adj_rec.gl_date);

    l_rev_adj_rec.adjustment_type := 'UN';
    AR_Revenue_Adjustment_PVT.earn_or_unearn
             (p_rev_adj_rec          => l_rev_adj_rec
             ,p_validation_level     => p_validation_level
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,x_adjustment_id        => x_adjustment_id
             ,x_adjustment_number    => x_adjustment_number);
    IF x_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Unearn_Revenue()-');
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Unearn_Revenue_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Unearn_Revenue: ' || 'Unexpected error '||sqlerrm||
                             ' at AR_Revenue_Adjustment_PVT.Unearn_Revenue()+');
                END IF;
		ROLLBACK TO Unearn_Revenue_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Unearn_Revenue: ' || '20001 error '||
                             ' at AR_Revenue_Adjustment_PVT.Unearn_Revenue()+');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Unearn_Revenue: ' || 'Unexpected error '||sqlerrm||
                             ' at AR_Revenue_Adjustment_PVT.Unearn_Revenue()+');
                  END IF;
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		  IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		  END IF;
		END IF;
	  	ROLLBACK TO Unearn_Revenue_PVT;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  END Unearn_Revenue;

-----------------------------------------------------------------------
--	API name 	: Earn_Revenue
--	Type		: Private
--	Function	: Transfers a specified amount of revenue from
--                        unearned to earned revenue account.
--	Pre-reqs	: Sufficient unearned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--
-----------------------------------------------------------------------
  PROCEDURE Earn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2
     ,p_commit	              IN   VARCHAR2
     ,p_validation_level      IN   NUMBER
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2)
  IS
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Earn_Revenue';
    l_api_version           	CONSTANT NUMBER 	:= 2.0;
    l_rev_adj_rec               AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Earn_Revenue()+');
       arp_util.debug('  p_rev_adj_rec.sales_credit_type = ' ||
                         p_rev_adj_rec.sales_credit_type);
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT	Earn_Revenue_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Earn_Revenue: ' || 'Unexpected error '||sqlerrm||
                               ' at AR_Revenue_Adjustment_PVT.Earn_Revenue()+');
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

    l_rev_adj_rec := p_rev_adj_rec;

    /*Bug 6731185 JVARKEY Making sure GL date has no timestamp*/
    l_rev_adj_rec.gl_date := trunc(p_rev_adj_rec.gl_date);

    l_rev_adj_rec.adjustment_type := 'EA';
    AR_Revenue_Adjustment_PVT.earn_or_unearn
             (p_rev_adj_rec          => l_rev_adj_rec
             ,p_validation_level     => p_validation_level
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,x_adjustment_id        => x_adjustment_id
             ,x_adjustment_number    => x_adjustment_number);
    IF x_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Earn_Revenue()-');
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Earn_Revenue_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Earn_Revenue: ' || 'Unexpected error '||sqlerrm||
                               ' at AR_Revenue_Adjustment_PVT.Earn_Revenue()+');
                END IF;
		ROLLBACK TO Earn_Revenue_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Earn_Revenue: ' || '20001 error '||
                             ' at AR_Revenue_Adjustment_PVT.Earn_Revenue()+');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Earn_Revenue: ' || 'Unexpected error '||sqlerrm||
                               ' at AR_Revenue_Adjustment_PVT.Earn_Revenue()+');
                  END IF;
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		  IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		  END IF;
		END IF;
	  	ROLLBACK TO Earn_Revenue_PVT;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  END Earn_Revenue;

-----------------------------------------------------------------------
--	API name 	: Earn_Revenue (OVERLOADED)
--	Type		: Private
--	Function	: Transfers a specified amount of revenue from
--                        unearned to earned revenue account. This is an
--                        overlaid version of the previous procedure that
--                        returns the new distributions in a pl/sql table
--                        rather than writing them to ra_cust_trx_line_gl_dist
--	Pre-reqs	: Sufficient unearned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--                        x_dist_count            NUMBER
--                        x_ra_dist_tbl           RA_Dist_Tbl_Type
--
--	Version	: Current version	2.0
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--                        This procedure is an overlay of the standard Unearn_Revenue
--                        API which does not write out NOCOPY a revenue adjustment record or
--                        entries into ra_cust_trx_line_gl_dist. Instead it outputs
--                        the distributions to a pl/sql table which is passed out NOCOPY to
--                        the calling routine
-----------------------------------------------------------------------
  PROCEDURE Earn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2
     ,p_commit	              IN   VARCHAR2
     ,p_validation_level      IN   NUMBER
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2
     ,x_dist_count            OUT NOCOPY  NUMBER
     ,x_ra_dist_tbl           OUT  NOCOPY RA_Dist_Tbl_Type)
  IS

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.(OVERLOADED)Earn_Revenue()+');
    END IF;

   --initialize the global gl distributions table
     g_ra_dist_tbl := g_ra_empty_dist_tbl ;
     g_dist_count  := 0;

   --This flag tells the API not to create any distributions or revenue
   --adjustment records but to insert distributions into a pl/sql table
     g_update_db_flag := 'N';

     Earn_Revenue
      (   p_api_version           => 2.0
         ,p_init_msg_list        => FND_API.G_TRUE
         ,p_commit               => FND_API.G_FALSE
         ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_rev_adj_rec           => p_rev_adj_rec
         ,x_adjustment_id         => x_adjustment_id
         ,x_adjustment_number     => x_adjustment_number);

   --Now set the table output parameter and the count of rows in it
     x_ra_dist_tbl := g_ra_dist_tbl;
     x_dist_count  := g_dist_count;

   --Set the g_update_db_flag variable to 'Y' which is the default option
   --for all other calls to the API
     g_update_db_flag := 'Y';

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.(OVERLOADED)Earn_Revenue()-');
    END IF;
  END Earn_Revenue;

  PROCEDURE earn_or_unearn
     (p_rev_adj_rec           IN  Rev_Adj_Rec_Type
     ,p_validation_level      IN  NUMBER
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
     ,x_adjustment_id         OUT NOCOPY NUMBER
     ,x_adjustment_number     OUT NOCOPY VARCHAR2)
   IS
     l_rev_adj_rec            AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type;
     l_line_id                NUMBER;
     l_line_amount            NUMBER;
     l_line_acctd_amount      NUMBER;
     l_cm_line_amount         NUMBER;
     l_net_line_amount        NUMBER;
     l_line_total             NUMBER;
     l_line_count             NUMBER;
     l_no_of_lines            NUMBER;
     l_total_adjusted         NUMBER;
     l_line_rev_total         NUMBER;
     l_line_rsc_total         NUMBER;
     l_line_rsc_amount        NUMBER;
     l_adj_inv_total          NUMBER;
     l_line_adjustable        NUMBER;
     l_adjustable_amount      NUMBER;
     l_revenue_amount         NUMBER;
     l_revenue_amount_prorata NUMBER;
     l_type_code              VARCHAR2(2);
     l_gl_date_valid          DATE;   -- Bug 2146970
     l_scenario                NUMBER; -- Bug 2560048
     l_first_adjustment_number NUMBER; -- Bug 2560048
     l_last_adjustment_number  NUMBER; -- Bug 2560048
     l_override_flag           VARCHAR2(1);
     l_user_generated_flag     VARCHAR2(1);
     l_sr_count                NUMBER; -- 5021530
     x_line_count_out          NUMBER; -- 6223281
     x_acctd_amount_out        NUMBER; -- 6223281
     l_rev_dist_count          NUMBER; -- 7569247
     l_xla_call_req_flag       boolean := FALSE;--BUG 7130380
     l_xla_event               arp_xla_events.xla_events_type;

     -- Bug 3431815: credit memos included
     -- Bug 3536944: c_line cursor broken up into 3 different queries to
     -- improve performance: c_line, c_line_amount and c_cm_line_amount.

     CURSOR c_line IS
     SELECT l.customer_trx_line_id
           ,l.memo_line_id
           ,l.inventory_item_id
           ,l.accounting_rule_id
           ,l.accounting_rule_duration     -- Bug 2168875
           ,NVL(l.override_auto_accounting_flag,'N')
              override_auto_accounting_flag -- Bug 3879222
           ,l.rule_start_date
           ,l.customer_trx_id
           ,NVL(r.deferred_revenue_flag,'N') deferred_revenue_flag
           ,l.extended_amount               -- 7569247
     FROM   mtl_item_categories mic
           ,ra_customer_trx_lines l
           ,ra_rules r
     WHERE  l.line_type = 'LINE'
     AND    l.autorule_complete_flag IS NULL
     AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
     AND    l.customer_trx_line_id =
          NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,l.customer_trx_line_id)
     AND    l.accounting_rule_id = r.rule_id (+)
     AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
     AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                 DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
     AND   ((AR_RAAPI_UTIL.g_from_salesrep_id IS NULL AND
             AR_RAAPI_UTIL.g_from_salesgroup_id IS NULL)
            OR  EXISTS
            (SELECT 'X'
             FROM   ra_cust_trx_line_salesreps ls
             WHERE  ls.customer_trx_line_id = l.customer_trx_line_id
             AND    ls.salesrep_id =
                     NVL(AR_RAAPI_UTIL.g_from_salesrep_id,ls.salesrep_id)
	     AND    NVL(ls.revenue_salesgroup_id, -9999) =
		     NVL(AR_RAAPI_UTIL.g_from_salesgroup_id,
                         NVL(ls.revenue_salesgroup_id, -9999))
             GROUP  BY ls.salesrep_id
             HAVING SUM(NVL(ls.revenue_percent_split,0)) <> 0));


   BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.earn_or_unearn()+');
        arp_util.debug('  p_rev_adj_rec.sales_credit_type = ' ||
                          p_rev_adj_rec.sales_credit_type);
     END IF;
     l_rev_adj_rec := p_rev_adj_rec;

     /*Bug 6731185 JVARKEY Making sure GL date has no timestamp*/
     l_rev_adj_rec.gl_date := trunc(p_rev_adj_rec.gl_date);

     AR_RAAPI_UTIL.Constant_System_Values;
     AR_RAAPI_UTIL.Initialize_Globals;
     AR_RAAPI_UTIL.Validate_Parameters (p_init_msg_list    => FND_API.G_FALSE
                                       ,p_rev_adj_rec      => l_rev_adj_rec
                                       ,p_validation_level => p_validation_level
                                       ,x_return_status    => x_return_status
                                       ,x_msg_count        => x_msg_count
                                       ,x_msg_data         => x_msg_data);
     IF x_return_status = FND_API.G_RET_STS_SUCCESS
     THEN
       l_total_adjusted := 0;

       AR_RAAPI_UTIL.Validate_Amount
       (p_init_msg_list         => FND_API.G_FALSE
       ,p_customer_trx_line_id  => AR_RAAPI_UTIL.g_from_cust_trx_line_id
       ,p_adjustment_type       => p_rev_adj_rec.adjustment_type
       ,p_amount_mode           => p_rev_adj_rec.amount_mode
       ,p_customer_trx_id       => AR_RAAPI_UTIL.g_customer_trx_id
       ,p_salesrep_id           => AR_RAAPI_UTIL.g_from_salesrep_id
       ,p_salesgroup_id         => AR_RAAPI_UTIL.g_from_salesgroup_id
       ,p_sales_credit_type     => p_rev_adj_rec.sales_credit_type
       ,p_item_id               => AR_RAAPI_UTIL.g_from_inventory_item_id
       ,p_category_id           => AR_RAAPI_UTIL.g_from_category_id
       ,p_revenue_amount_in     => p_rev_adj_rec.amount
       ,p_revenue_percent       => p_rev_adj_rec.percent
       ,p_revenue_amount_out    => l_revenue_amount
       ,p_adjustable_amount_out => l_adj_inv_total
       ,p_line_count_out        => l_no_of_lines
       ,x_return_status         => x_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data);
     END IF;

     IF x_return_status = FND_API.G_RET_STS_SUCCESS
     THEN
       l_rev_adj_rec.amount := l_revenue_amount;
       l_line_count := 0;

       /* Bug 2146970 - validate the GL date passed in */
       l_gl_date_valid := AR_RAAPI_UTIL.bump_gl_date_if_closed
                       (p_gl_date => l_rev_adj_rec.gl_date);

       IF PG_DEBUG in ('Y','C')
       THEN
          arp_util.debug('original gl_date = ' || l_rev_adj_rec.gl_date);
          arp_util.debug('new gl_date      = ' || l_gl_date_valid);
       END IF;

       IF l_gl_date_valid IS NULL
       THEN
         FND_MESSAGE.set_name('AR','AR_VAL_GL_DATE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       /* 7314406 - at this point, l_rev_adj_rec.gl_date is the
          originally supplied gl_date.  l_gl_date_valid is
          the bumped or modified gl_date.  */

       IF g_update_db_flag = 'Y'
       THEN
         create_adjustment
         (p_rev_adj_rec           => l_rev_adj_rec
         ,x_adjustment_id         => x_adjustment_id
         ,x_adjustment_number    => x_adjustment_number);
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('revenue_adjustment_id : '||x_adjustment_id);
            arp_util.debug('revenue_adjustment_number : '||x_adjustment_number);
            arp_util.debug('g_rev_mgt_installed : '||g_rev_mgt_installed);
            arp_util.debug('p_rev_adj_rec.source : '||p_rev_adj_rec.source);
         END IF;
         /* Bug 2560048 RAM-C - if api call not from collectibility engine
            then the transaction must be recorded as manually overridden */
         /* Bug 2650708 - cater for null source value, and only call if
            rev mgt installed and transaction is monitored by rev mgt */
         IF (g_rev_mgt_installed = 'Y' AND
             NVL(p_rev_adj_rec.source,-99) <>
                ar_revenue_management_pvt.c_revenue_management_source AND
             ar_revenue_management_pvt.acceptance_allowed
                   (p_rev_adj_rec.customer_trx_id,
                    p_rev_adj_rec.from_cust_trx_line_id) <>
                ar_revenue_management_pvt.c_transaction_not_monitored)
         THEN
           ar_revenue_management_pvt.revenue_synchronizer(
                  p_mode                 =>
                         ar_revenue_management_pvt.c_manual_override_mode
                , p_customer_trx_id      => p_rev_adj_rec.customer_trx_id
                , p_customer_trx_line_id => p_rev_adj_rec.from_cust_trx_line_id
                , p_gl_date              => l_rev_adj_rec.gl_date -- 7556149
                , p_comments             => NULL
                , p_ram_desc_flexfield   => NULL
                , x_scenario 		 => l_scenario
                , x_first_adjustment_number => l_first_adjustment_number
                , x_last_adjustment_number  => l_last_adjustment_number
                , x_return_status           => x_return_status
                , x_msg_count               => x_msg_count
                , x_msg_data                => x_msg_data);
         END IF;
       ELSE
         x_adjustment_id         := NULL;
         x_adjustment_number     := NULL;
       END IF;
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('x_return_status : '||x_return_status);
       END IF;
       /* Bug 2651996 - a null return status is being passed back from revenue
          synchronizer - assume successful */
       IF x_return_status IS NULL
       THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('x_return_status : '||x_return_status);
       END IF;

       IF p_rev_adj_rec.adjustment_type = 'EA'
       THEN
          l_revenue_amount := l_revenue_amount * -1;
       END IF;

       /* Bug 4304865: set flag for later storage on ra_cust_trx_line_gl_dist
          if earn/unearn not called from revenue management package */
       IF NVL(p_rev_adj_rec.source, -99999) <>
           ar_revenue_management_pvt.c_revenue_management_source
       THEN
          l_user_generated_flag := 'Y';
       ELSE
          l_user_generated_flag := NULL;
       END IF;

       FOR c1 IN c_line LOOP
         l_line_id := c1.customer_trx_line_id;

         /* 6223281 - fetch the maximum amount allowable for the adjustment
            based on the given parameters */
         l_line_adjustable := AR_RAAPI_UTIL.Adjustable_Revenue
             (p_customer_trx_line_id  => l_line_id
             ,p_adjustment_type       => p_rev_adj_rec.adjustment_type
             ,p_customer_trx_id       => AR_RAAPI_UTIL.g_customer_trx_id
             ,p_salesrep_id           => AR_RAAPI_UTIL.g_from_salesrep_id
             ,p_salesgroup_id         => AR_RAAPI_UTIL.g_from_salesgroup_id
             ,p_sales_credit_type     => p_rev_adj_rec.sales_credit_type
             ,p_item_id               => AR_RAAPI_UTIL.g_from_inventory_item_id
             ,p_category_id           => AR_RAAPI_UTIL.g_from_category_id
             ,p_revenue_adjustment_id => NULL -- intentionally null
             ,p_line_count_out        => x_line_count_out
             ,p_acctd_amount_out      => x_acctd_amount_out);

         /* 7569247 - Original logic would never create dists if
            l_line_adjustable was zero.  Modified to create distributions
            only the first time revenue is earned for a zero line
            so COGS will pick up those lines.  This also required
            some minor changes inside each of the distribution routines
            called below. */
         IF l_line_adjustable = 0
         AND c1.extended_amount = 0
         THEN
            IF l_rev_adj_rec.adjustment_type = 'EA'
            THEN

               /* 7454302 - check for dists, continue only if there are none
                   Returns TRUE if there are zero lines with no REV */
               IF NOT AR_RAAPI_UTIL.unearned_zero_lines(
                    p_customer_trx_id      => c1.customer_trx_id,
                    p_customer_trx_line_id => c1.customer_trx_line_id,
                    p_check_line_amt       => 'N')
               THEN
                  /* skip processing as REV dists already exist
                     for this line */

                  /* CONTINUE is new to 11G, and will not
                     compile in prior rdbms versions.  Using
                     goto for now and can revert to CONTINUE
                     once 11G becomes the norm. */
                  --CONTINUE;`
                  GOTO continue_loop;
               END IF;
            ELSE
               /* its not earn, so skip dists for this line */
               --CONTINUE;
               GOTO continue_loop;
            END IF;
         END IF;

           /* 7569247 - set l_revenue_amount_prorata to zero
                if remaining unallocated funds is zero */
           IF l_adj_inv_total = 0
           THEN
              l_revenue_amount_prorata := 0;
           ELSE
              l_revenue_amount_prorata := ROUND(l_revenue_amount *
                 l_line_adjustable / l_adj_inv_total,AR_RAAPI_UTIL.g_trx_precision);
           END IF;

           /* Check for salesreps for use later */
           SELECT count(*)
           INTO   l_sr_count
           FROM   ra_cust_trx_line_salesreps
           WHERE  customer_trx_line_id = l_line_id
           AND    NVL(revenue_percent_split,0) <> 0
           AND    customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id;

           IF c1.accounting_rule_id IS NOT NULL
           THEN
             /* 6325023 - previous logic differentiated between
                override_auto_accounting_flag, sr_count, etc.
                Due to problems with rounding of acctd_amount,
                we decided to remove reference/use of debit_credit
                entirely and just consolidate on use of
                dists_by_model and the centralized rounding logic. */

                /* Set the override flag so we round this trx later */
                l_override_flag := 'Y';

                /* The API/wizard takes all amounts as positive values
                   and code above changes some of them (EA) to negative.
                   This code assumes REV to be positive and UE as negative
                   so we have to switch the signs.*/
                l_revenue_amount_prorata := l_revenue_amount_prorata * -1;

                /* 7208384 - passing both the bumped and original
                   gl_dates.  That way, we can determine which
                   to use in dists_by_model.
                   FYI:
                     l_gl_date_valid       = bumped gl_date (open)
                     l_rev_adj_rec.gl_date = original gl_date
                */

                /* New Logic for proration without salesreps */
                dists_by_model(c1.customer_trx_id
                              ,c1.customer_trx_line_id
                              ,l_revenue_amount_prorata
                              ,x_adjustment_id
			      ,l_user_generated_flag
                              ,l_gl_date_valid -- 7314406
                              ,l_rev_adj_rec.gl_date -- 7208384
                              ,c1.rule_start_date
                              ,c1.deferred_revenue_flag);

		IF l_xla_call_req_flag <> TRUE THEN
		  l_xla_call_req_flag := true;
		END IF;

                /* Store adjustment info in AR_LINE_REV_ADJ_GT
                   so we can round the adjustment dists later */
                INSERT INTO AR_LINE_REV_ADJ_GT(
                   CUSTOMER_TRX_ID,
                   CUSTOMER_TRX_LINE_ID,
                   REVENUE_ADJUSTMENT_ID,
                   AMOUNT,
                   PERCENT)
                 VALUES
                   (p_rev_adj_rec.customer_trx_id,
                    c1.customer_trx_line_id,
                    x_adjustment_id,
                    l_revenue_amount_prorata,
                    p_rev_adj_rec.percent);

           ELSE
             /* 5021530 call new logic (no_sr) conditionally */
             IF c1.override_auto_accounting_flag = 'Y' OR
                l_sr_count = 0
             THEN
                /* new non-SR logic */
                /* Set the override flag so we round this trx later */
                l_override_flag := 'Y';

                /* The API/wizard takes all amounts as positive values
                   and code above changes some of them (EA) to negative.
                   This code assumes REV to be positive and UE as negative
                   so we have to switch the signs.*/
                l_revenue_amount_prorata := l_revenue_amount_prorata * -1;

                IF (PG_DEBUG IN ('Y','C'))
                THEN
                   arp_debug.debug('l_revenue_amount_prorata = ' ||
                        l_revenue_amount_prorata);
                END IF;

                no_rule_debit_credit_no_sr(c1.customer_trx_line_id
                                         ,AR_RAAPI_UTIL.g_customer_trx_id
                                         ,AR_RAAPI_UTIL.g_from_salesrep_id
                                         ,l_revenue_amount_prorata
                                         ,l_gl_date_valid -- bug 2146970
                                         ,NULL
                                         ,c1.inventory_item_id
                                         ,c1.memo_line_id
                                         ,x_adjustment_id
					 ,l_user_generated_flag);

                /* Store adjustment info in AR_LINE_REV_ADJ_GT
                   so we can round the adjustment dists later */
                INSERT INTO AR_LINE_REV_ADJ_GT(
                   CUSTOMER_TRX_ID,
                   CUSTOMER_TRX_LINE_ID,
                   REVENUE_ADJUSTMENT_ID,
                   AMOUNT,
                   PERCENT)
                VALUES
                   (p_rev_adj_rec.customer_trx_id,
                    c1.customer_trx_line_id,
                    x_adjustment_id,
                    l_revenue_amount_prorata,
                    p_rev_adj_rec.percent);

             ELSE
                /* Original SR-based logic */
                no_rule_debit_credit    (c1.customer_trx_line_id
                                         ,AR_RAAPI_UTIL.g_customer_trx_id
                                         ,AR_RAAPI_UTIL.g_from_salesrep_id
                                         ,l_revenue_amount_prorata
                                         ,l_gl_date_valid -- bug 2146970
                                         ,NULL
                                         ,c1.inventory_item_id
                                         ,c1.memo_line_id
                                         ,x_adjustment_id
					 ,l_user_generated_flag);
             END IF;
           END IF;
       <<continue_loop>>
       NULL;
       END LOOP;  -- c_line loop

	IF l_xla_call_req_flag THEN
	  IF AR_RAAPI_UTIL.g_customer_trx_id is NOT NULL THEN
	    l_xla_event.xla_from_doc_id  := AR_RAAPI_UTIL.g_customer_trx_id;
	    l_xla_event.xla_to_doc_id    := AR_RAAPI_UTIL.g_customer_trx_id;
	    l_xla_event.xla_req_id       := NULL;
	    l_xla_event.xla_dist_id      := NULL;
	    l_xla_event.xla_doc_table    := 'CT';
	    l_xla_event.xla_doc_event    := NULL;
	    l_xla_event.xla_mode         := 'O';
	    l_xla_event.xla_call         := 'B';

	    ARP_XLA_EVENTS.CREATE_EVENTS(p_xla_ev_rec => l_xla_event );
	  END IF;
	END IF;

       /* Bug 3879222 */
       /* Call the rounding logic for overridden adjustments
          if the flag is set.  Note that the adjustments to
          be rounded are stored in a global temporary table
          and that table is used by the rounding code to
          determine the lines targeted for rounding.  */
       IF (l_override_flag = 'Y')
       THEN
          /* This call will round each adjustment that has be
             previously recorded in ar_rev_line_adj_gt */
          IF (arp_rounding.correct_rev_adj_by_line = 0)
          THEN
             arp_util.debug('ERROR:  arp_rounding.correct_rev_adj_by_line');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

     END IF;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.earn_or_unearn()-');
     END IF;

   EXCEPTION

     WHEN OTHERS then
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
              ('20001 error at AR_Revenue_Adjustment_PVT.earn_or_unearn');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('earn_or_unearn: ' || 'Unexpected error '||sqlerrm||
                          ' at AR_Revenue_Adjustment_PVT.earn_or_unearn()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
   END earn_or_unearn;

-----------------------------------------------------------------------
--	API name 	: Transfer_Sales_Credits
--	Type		: Private
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
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--
-----------------------------------------------------------------------
  PROCEDURE Transfer_Sales_Credits
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2
     ,p_commit	              IN   VARCHAR2
     ,p_validation_level      IN   NUMBER
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2)
  IS
    l_api_name          CONSTANT VARCHAR2(30) := 'Transfer_Sales_Credits';
    l_api_version       CONSTANT NUMBER 	:= 2.0;
    l_rev_adj_rec                AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type;

    l_trx_total                  NUMBER := 0;
    l_line_count                 NUMBER := 0;
    l_salesrep_count             NUMBER := 0;
    l_nr_salesrep_count          NUMBER := 0;
    l_no_of_lines                NUMBER := 0;
    l_no_of_salesreps            NUMBER := 0;
    l_nr_no_of_salesreps         NUMBER := 0;
    l_total_adjusted             NUMBER := 0;
    l_line_adjusted              NUMBER := 0;
    l_line_adjusted_acctd        NUMBER := 0;
    l_line_percent_adjusted      NUMBER := 0;
    l_nr_line_adjusted           NUMBER := 0;
    l_nr_line_pct_adjusted       NUMBER := 0;
    l_nonrev_trx_total           NUMBER := 0;
    l_nonrev_line_count          NUMBER := 0;
    l_no_of_nonrev_lines         NUMBER := 0;
    l_total_nonrev_adjusted      NUMBER := 0;
    l_adj_trx_total              NUMBER := 0;
    l_line_rsc_total             NUMBER := 0;
    l_line_rsc_amount            NUMBER := 0;
    l_line_revenue_total         NUMBER := 0;
    l_cm_line_revenue_total      NUMBER := 0;
    l_net_line_revenue_total     NUMBER := 0;
    l_line_nonrev_total          NUMBER := 0;
    l_line_adjustable            NUMBER := 0;
    l_adjustable_amount          NUMBER := 0;
    l_trx_line_salesrep_id       NUMBER;
    l_revenue_amount_split       NUMBER := 0;
    l_revenue_percent_split      NUMBER := 0;
    l_revenue_amount             NUMBER := 0;
    l_line_amount                NUMBER := 0;
    l_line_amount_acctd          NUMBER := 0;
    l_line_percent	         NUMBER := 0;
    l_line_nonrev_amount         NUMBER := 0;
    l_line_nonrev_percent        NUMBER := 0;
    l_nonrev_amount_split        NUMBER := 0;
    l_nonrev_percent_split       NUMBER := 0;
    l_nonrev_amount              NUMBER := 0;
    l_amount_prorata             NUMBER := 0;
    l_amount_prorata_acctd       NUMBER := 0;
    l_percent_prorata	         NUMBER := 0;
    l_nonrev_amount_prorata      NUMBER := 0;
    l_nonrev_percent_prorata     NUMBER := 0;

    l_revenue_amount_split_new   NUMBER := 0;
    l_revenue_percent_split_new  NUMBER := 0;
    l_nonrev_amount_split_new    NUMBER := 0;
    l_nonrev_percent_split_new   NUMBER := 0;
    l_transferable_amount        NUMBER := 0;
    l_cust_trx_line_id	         NUMBER;
    l_line_number                NUMBER;
    l_last_revenue_dist_id       NUMBER := 0;
    l_next_rev_dist_id	         NUMBER := 0;
    l_credit_ccid	         NUMBER := 0;
    l_debit_ccid	         NUMBER := 0;
    l_concat_segments	         VARCHAR2(2000);
    l_fail_count	         NUMBER := 0;
    l_dist_acctd_amount          NUMBER := 0;
    l_debit_sales_credit_id      NUMBER;
    l_credit_sales_credit_id     NUMBER;
    l_total_sc_percent           NUMBER;
    l_neg_sc_limit               NUMBER;
    l_new_salesrep_name          ra_salesreps.name%TYPE;
    l_max_percent                NUMBER;

    l_warehouse_id               NUMBER; -- Bug 1930302.
    l_gl_date_valid              DATE;   -- Bug 2146970
    l_last_salesrep_flag         VARCHAR2(1); -- Bug 2477881

    invalid_sc_total             EXCEPTION;
--  invalid_percent              EXCEPTION;
    invalid_amount               EXCEPTION;
    invalid_zero                 EXCEPTION;
    invalid_ccid                 EXCEPTION;

    CURSOR c_trx_total IS
    SELECT SUM(NVL(s.revenue_amount_split,0))
    FROM   ra_cust_trx_line_salesreps s
          ,mtl_item_categories mic
          ,ra_customer_trx_lines l
    WHERE  s.customer_trx_line_id = l.customer_trx_line_id
    AND    l.line_type = 'LINE'
    AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
    AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,
                                        l.customer_trx_line_id)
    AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
    AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
    AND    l.inventory_item_id = mic.inventory_item_id(+)
    AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
    AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
    AND    EXISTS
              (SELECT s1.salesrep_id
               FROM   ra_cust_trx_line_salesreps s1
               WHERE  s1.customer_trx_line_id = l.customer_trx_line_id
               AND    s1.salesrep_id =
                         NVL(AR_RAAPI_UTIL.g_from_salesrep_id,s1.salesrep_id)
	       AND DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s1.non_revenue_salesgroup_id, -9999), NVL(s1.revenue_salesgroup_id, -9999)) =
	       		 NVL(AR_RAAPI_UTIL.g_from_salesgroup_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s1.non_revenue_salesgroup_id, -9999), NVL(s1.revenue_salesgroup_id, -9999)))
               GROUP BY s1.salesrep_id
               HAVING DECODE(p_rev_adj_rec.sales_credit_type,'N',
                                  SUM(NVL(s1.non_revenue_percent_split,0)),
                                  SUM(NVL(s1.revenue_percent_split,0))) <> 0);

    CURSOR c_rev_total IS
    SELECT NVL(SUM(d.amount),0)
    FROM   ra_cust_trx_line_gl_dist d
          ,mtl_item_categories mic
          ,ra_customer_trx_lines l
    WHERE  d.customer_trx_line_id = l.customer_trx_line_id
    AND    d.account_class = 'REV'
    AND    l.line_type = 'LINE'
    AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
    AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,
                                        l.customer_trx_line_id)
    AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
    AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
    AND    l.inventory_item_id = mic.inventory_item_id(+)
    AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
    AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
    AND    EXISTS
              (SELECT s.salesrep_id
               FROM   ra_cust_trx_line_salesreps s
               WHERE  s.customer_trx_line_id = l.customer_trx_line_id
               AND    s.salesrep_id =
                      NVL(AR_RAAPI_UTIL.g_from_salesrep_id,s.salesrep_id)
	       AND DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)) =
	       		 NVL(AR_RAAPI_UTIL.g_from_salesgroup_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)))
               GROUP BY s.salesrep_id
               HAVING DECODE(p_rev_adj_rec.sales_credit_type,'N',
                                  SUM(NVL(s.non_revenue_percent_split,0)),
                                  SUM(NVL(s.revenue_percent_split,0))) <> 0);

    CURSOR c_nonrev_trx_total IS
    SELECT SUM(NVL(s.non_revenue_amount_split,0))
    FROM   ra_customer_trx_lines l
          ,mtl_item_categories mic
          ,ra_cust_trx_line_salesreps s
    WHERE  l.customer_trx_line_id = s.customer_trx_line_id
    AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,
                                        l.customer_trx_line_id)
    AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
    AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
    AND    l.inventory_item_id = mic.inventory_item_id(+)
    AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
    AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
    AND    NVL(s.non_revenue_percent_split,0) <> 0
    AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
    AND    s.salesrep_id = NVL(AR_RAAPI_UTIL.g_from_salesrep_id,s.salesrep_id)
    AND	   NVL(s.non_revenue_salesgroup_id,-9999) = NVL(AR_RAAPI_UTIL.g_from_salesgroup_id,NVL(s.non_revenue_salesgroup_id,-9999));

    CURSOR c_nonrev_line_count IS
    SELECT COUNT(*)
    FROM   mtl_item_categories mic
          ,ra_customer_trx_lines l
    WHERE  l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,
                                      l.customer_trx_line_id)
    AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
    AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
    AND    l.inventory_item_id = mic.inventory_item_id(+)
    AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
    AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
    AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
    AND    EXISTS
              (SELECT s.salesrep_id
               FROM   ra_cust_trx_line_salesreps s
               WHERE  s.customer_trx_line_id = l.customer_trx_line_id
               AND    NVL(s.non_revenue_percent_split,0) <> 0
               AND    s.salesrep_id =
                      NVL(AR_RAAPI_UTIL.g_from_salesrep_id,s.salesrep_id)
    	       AND    NVL(s.non_revenue_salesgroup_id,-9999) =
		      NVL(AR_RAAPI_UTIL.g_from_salesgroup_id,NVL(s.non_revenue_salesgroup_id,-9999))
               GROUP BY s.customer_trx_line_id
               HAVING SUM(NVL(s.non_revenue_percent_split,0)) <> 0);

    CURSOR c_line IS
    SELECT SUM (s.revenue_amount_split) amount
          ,l.customer_trx_line_id
          ,l.accounting_rule_id
          ,l.accounting_rule_duration
          ,l.inventory_item_id
          ,l.memo_line_id
	  ,l.warehouse_id
          ,l.line_number
    FROM   ra_cust_trx_line_salesreps s
          ,mtl_item_categories mic
          ,ra_customer_trx_lines l
    WHERE  l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
    AND    l.customer_trx_line_id = s.customer_trx_line_id
    AND    l.customer_trx_line_id =
             NVL (AR_RAAPI_UTIL.g_from_cust_trx_line_id, l.customer_trx_line_id)
    AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
    AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
    AND    l.inventory_item_id = mic.inventory_item_id(+)
    AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
    AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
    AND    l.line_type = 'LINE'
    AND    EXISTS
              (SELECT s1.salesrep_id
               FROM   ra_cust_trx_line_salesreps s1
               WHERE  s1.customer_trx_line_id = l.customer_trx_line_id
               AND    s1.salesrep_id =
                      NVL(AR_RAAPI_UTIL.g_from_salesrep_id,s1.salesrep_id)
               AND DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s1.non_revenue_salesgroup_id, -9999), NVL(s1.revenue_salesgroup_id, -9999)) =
                         NVL(AR_RAAPI_UTIL.g_from_salesgroup_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s1.non_revenue_salesgroup_id, -9999), NVL(s1.revenue_salesgroup_id, -9999)))
               GROUP BY s1.salesrep_id
               HAVING DECODE(p_rev_adj_rec.sales_credit_type,'N',
                                   SUM(NVL(s1.non_revenue_percent_split,0)),
                                   SUM(NVL(s1.revenue_percent_split,0))) <> 0)
    GROUP BY l.customer_trx_line_id
            ,l.accounting_rule_id
            ,l.accounting_rule_duration
            ,l.inventory_item_id
            ,l.memo_line_id
	    ,l.warehouse_id
            /* Bug 2130207 - changed from l_warehouse_id */
            ,l.line_number
    HAVING SUM(s.revenue_amount_split) <> 0;

    CURSOR c_line_rsc_amount IS
    SELECT NVL(SUM(revenue_amount_split),0)
    FROM   ra_cust_trx_line_salesreps
    WHERE  customer_trx_line_id = l_cust_trx_line_id
    and    NVL(revenue_percent_split,0) <> 0
    AND    customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
    and    salesrep_id = NVL(AR_RAAPI_UTIL.g_from_salesrep_id,salesrep_id)
    and    NVL(revenue_salesgroup_id, -9999) = NVL(AR_RAAPI_UTIL.g_from_salesgroup_id,NVL(revenue_salesgroup_id, -9999));

    -- Bug 3431815: Credit Memos included
    -- Bug 3536944: cursor split into separate queries for invoice and CMs
    -- Bug 3676923: cater for null amounts and removed check on autorule
    -- complete flag for credit memos

    CURSOR c_line_revenue_total IS
    SELECT NVL(SUM(d.amount),0)
    FROM   ra_cust_trx_line_gl_dist d
    WHERE  d.customer_trx_line_id = l_cust_trx_line_id
    AND    d.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
    AND    d.account_set_flag = 'N'
    AND    d.account_class = 'REV';

    CURSOR c_cm_line_revenue_total IS
    SELECT NVL(SUM(d.amount),0)
    FROM   ra_cust_trx_line_gl_dist d,
	   ra_customer_trx_lines l
    WHERE  d.customer_trx_line_id = l.customer_trx_line_id
    AND    d.customer_trx_id = l.customer_trx_id
    AND    l.previous_customer_trx_line_id = l_cust_trx_line_id
    AND    l.previous_customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
    AND    d.account_set_flag = 'N'
    AND    d.account_class = 'REV';

    CURSOR c_line_nonrev_total IS
    SELECT SUM(NVL(s.non_revenue_amount_split,0))
    FROM   ra_cust_trx_line_salesreps s
    WHERE  s.customer_trx_line_id = l_cust_trx_line_id
    AND    s.salesrep_id = NVL(AR_RAAPI_UTIL.g_from_salesrep_id,s.salesrep_id)
    and    NVL(s.non_revenue_salesgroup_id, -9999) = NVL(AR_RAAPI_UTIL.g_from_salesgroup_id,NVL(s.non_revenue_salesgroup_id, -9999));

    CURSOR get_salesrep_lines_old is
    SELECT SUM(NVL(s.revenue_amount_split,0)) revenue_amount_split,
           SUM(NVL(s.revenue_percent_split,0)) revenue_percent_split,
           SUM(NVL(s.non_revenue_amount_split,0)) nonrev_amount_split,
           SUM(NVL(s.non_revenue_percent_split,0)) nonrev_percent_split
    FROM   ra_cust_trx_line_salesreps s,
           ra_customer_trx_lines l
    WHERE  s.customer_trx_line_id = l_cust_trx_line_id
    AND    s.salesrep_id = NVL(AR_RAAPI_UTIL.g_from_salesrep_id,s.salesrep_id)
    AND	   DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)) =
		NVL(AR_RAAPI_UTIL.g_from_salesgroup_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)))
    AND    l.line_type = 'LINE'
    AND    l.customer_trx_line_id = s.customer_trx_line_id
    AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id;

    CURSOR get_salesrep_lines_new is
    SELECT NVL(SUM(s.revenue_amount_split),0),
           NVL(SUM(s.revenue_percent_split),0),
           NVL(SUM(s.non_revenue_amount_split),0),
           NVL(SUM(s.non_revenue_percent_split),0)
    FROM   ra_cust_trx_line_salesreps s,
           ra_customer_trx_lines l
    WHERE  s.customer_trx_line_id = l_cust_trx_line_id
    AND    s.salesrep_id = AR_RAAPI_UTIL.g_to_salesrep_id
    AND	   DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)) =
		NVL(AR_RAAPI_UTIL.g_to_salesgroup_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)))
    AND    l.line_type = 'LINE'
    AND    l.customer_trx_line_id = s.customer_trx_line_id
    AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id;

    CURSOR c_get_from_salesreps IS
    SELECT s.salesrep_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', s.non_revenue_salesgroup_id, s.revenue_salesgroup_id) salesgroup_id,
           SUM(s.revenue_amount_split) revenue_amount_split,
           SUM(s.revenue_percent_split) revenue_percent_split,
           SUM(s.non_revenue_amount_split) nonrev_amount_split,
           SUM(s.non_revenue_percent_split) nonrev_percent_split
    FROM   ra_cust_trx_line_salesreps s
    WHERE  s.customer_trx_line_id = l_cust_trx_line_id
    AND    s.salesrep_id = NVL(AR_RAAPI_UTIL.g_from_salesrep_id,s.salesrep_id)
    AND	   DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)) =
		NVL(AR_RAAPI_UTIL.g_from_salesgroup_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)))
    AND    NVL(s.revenue_adjustment_id,-99) <> x_adjustment_id  -- bug 2543675
    GROUP BY s.salesrep_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', s.non_revenue_salesgroup_id,s.revenue_salesgroup_id);

    CURSOR c_new_salesrep_name IS
    SELECT name
    FROM   ra_salesreps
    WHERE  salesrep_id = AR_RAAPI_UTIL.g_to_salesrep_id;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits()+');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT	Transfer_Sales_Credits_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Transfer_Sales_Credits: ' || 'Unexpected error '||sqlerrm||
                     ' at AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits()+');
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

    l_rev_adj_rec := p_rev_adj_rec;

    /*Bug 6731185 JVARKEY Making sure GL date has no timestamp*/
    l_rev_adj_rec.gl_date := trunc(p_rev_adj_rec.gl_date);

    l_rev_adj_rec.adjustment_type := 'SA';

    AR_RAAPI_UTIL.Constant_System_Values;
    AR_RAAPI_UTIL.Initialize_Globals;
    AR_RAAPI_UTIL.Validate_Parameters (p_init_msg_list    => FND_API.G_FALSE
                                      ,p_rev_adj_rec      => l_rev_adj_rec
                                      ,p_validation_level => p_validation_level
                                      ,x_return_status    => x_return_status
                                      ,x_msg_count        => x_msg_count
                                      ,x_msg_data         => x_msg_data);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- Inner PL/SQL Block to optimize error handling
    --
    BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits(2)+');
    END IF;

     l_revenue_amount := 0;
     l_nonrev_amount := 0;
     l_adj_trx_total := 0;
     l_line_count := 0;
     l_nonrev_line_count := 0;
     l_salesrep_count := 0;
     l_nr_salesrep_count := 0;
     l_total_adjusted := 0;
     l_total_nonrev_adjusted := 0;
     l_line_adjusted := 0;
     l_line_adjusted_acctd := 0;           /* Bug 2143925 */
     l_line_percent_adjusted := 0;
     l_nr_line_adjusted :=0;
     l_nr_line_pct_adjusted :=0;

     OPEN c_trx_total;
     FETCH c_trx_total INTO l_trx_total;
     CLOSE c_trx_total;

     OPEN c_new_salesrep_name;
     FETCH c_new_salesrep_name INTO l_new_salesrep_name;
     CLOSE c_new_salesrep_name;

     --
     -- Determine revenue amount to be transferred
     --
     IF p_rev_adj_rec.sales_credit_type IN ('R','B')
     THEN
       AR_RAAPI_UTIL.Validate_Amount
       (p_init_msg_list         => FND_API.G_FALSE
       ,p_customer_trx_line_id  => AR_RAAPI_UTIL.g_from_cust_trx_line_id
       ,p_adjustment_type       => 'SA'
       ,p_amount_mode           => p_rev_adj_rec.amount_mode
       ,p_customer_trx_id       => AR_RAAPI_UTIL.g_customer_trx_id
       ,p_salesrep_id           => AR_RAAPI_UTIL.g_from_salesrep_id
       ,p_salesgroup_id         => AR_RAAPI_UTIL.g_from_salesgroup_id
       ,p_sales_credit_type     => p_rev_adj_rec.sales_credit_type
       ,p_item_id               => AR_RAAPI_UTIL.g_from_inventory_item_id
       ,p_category_id           => AR_RAAPI_UTIL.g_from_category_id
       ,p_revenue_amount_in     => p_rev_adj_rec.amount
       ,p_revenue_percent       => p_rev_adj_rec.percent
       ,p_revenue_amount_out    => l_revenue_amount
       ,p_adjustable_amount_out => l_adj_trx_total
       ,p_line_count_out        => l_no_of_lines
       ,x_return_status         => x_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data);
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR
       THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       l_rev_adj_rec.amount := l_revenue_amount;
       /* Bug 2146970 - validate the GL date passed in */
       l_gl_date_valid := AR_RAAPI_UTIL.bump_gl_date_if_closed
                   (p_gl_date => l_rev_adj_rec.gl_date);
       IF l_gl_date_valid IS NULL
       THEN
         FND_MESSAGE.set_name('AR','AR_VAL_GL_DATE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
     --
     -- Determine non revenue amount to be transferred
     --
     IF p_rev_adj_rec.sales_credit_type in ('N','B')
     THEN
       OPEN c_nonrev_trx_total;
       FETCH c_nonrev_trx_total INTO l_nonrev_trx_total;
       CLOSE c_nonrev_trx_total;
       OPEN c_nonrev_line_count;
       FETCH c_nonrev_line_count INTO l_no_of_nonrev_lines;
       CLOSE c_nonrev_line_count;
       IF p_rev_adj_rec.amount_mode = 'A'
       THEN
         IF (p_rev_adj_rec.amount > 0 AND
             p_rev_adj_rec.amount > l_nonrev_trx_total) OR
            (p_rev_adj_rec.amount < 0 AND
             p_rev_adj_rec.amount < l_nonrev_trx_total)
         THEN
           RAISE invalid_amount;
         ELSE
           l_nonrev_amount := p_rev_adj_rec.amount;
         END IF;
       ELSIF p_rev_adj_rec.amount_mode = 'P'
       THEN
         l_nonrev_amount := ROUND(l_trx_total * p_rev_adj_rec.percent
                                       / 100, AR_RAAPI_UTIL.g_trx_precision);
       ELSE
         l_nonrev_amount := l_nonrev_trx_total;
       END IF;

       IF l_nonrev_amount = 0
       THEN
         RAISE invalid_zero;
       END IF;

       IF (l_nonrev_amount > 0 AND
           l_nonrev_amount > l_nonrev_trx_total) OR
          (l_nonrev_amount < 0 AND
           l_nonrev_amount < l_nonrev_trx_total)
       THEN
         RAISE invalid_amount;
       END IF;
       IF p_rev_adj_rec.sales_credit_type = 'N'
       THEN
         l_rev_adj_rec.amount := l_nonrev_amount;
       END IF;
     END IF;

     --
     -- Create revenue adjustment record
     --
     create_adjustment
     (p_rev_adj_rec           => l_rev_adj_rec
     ,x_adjustment_id         => x_adjustment_id
     ,x_adjustment_number     => x_adjustment_number);

     --
     -- Now transfer the amount on each line pro rata
     --
     FOR c1 IN c_line LOOP

       l_cust_trx_line_id := c1.customer_trx_line_id;
       l_line_number := c1.line_number;
       l_line_amount := 0;
       l_line_amount_acctd := 0;           /* Bug 2143925 */
       l_line_percent := 0;
       l_salesrep_count := 0;
       l_nr_salesrep_count := 0;
       l_line_nonrev_amount := 0;
       l_line_nonrev_percent := 0;

       -- Bug 3536944: first the revenue on the invoice line is retrieved,
       -- then the revenue for any credit memo lines is added to get net amount
       OPEN c_line_revenue_total;
       FETCH c_line_revenue_total INTO l_line_revenue_total;
       CLOSE c_line_revenue_total;

       OPEN c_cm_line_revenue_total;
       FETCH c_cm_line_revenue_total INTO l_cm_line_revenue_total;
       CLOSE c_cm_line_revenue_total;

       l_net_line_revenue_total := l_line_revenue_total + l_cm_line_revenue_total;

       OPEN get_salesrep_lines_old;
       FETCH get_salesrep_lines_old INTO l_revenue_amount_split,
                                         l_revenue_percent_split,
                                         l_nonrev_amount_split,
                                         l_nonrev_percent_split;
       CLOSE get_salesrep_lines_old;

       OPEN get_salesrep_lines_new;
       FETCH get_salesrep_lines_new INTO l_revenue_amount_split_new,
                                         l_revenue_percent_split_new,
                                         l_nonrev_amount_split_new,
                                         l_nonrev_percent_split_new;
       CLOSE get_salesrep_lines_new;

       IF p_rev_adj_rec.sales_credit_type IN ('R','B') AND
          l_revenue_percent_split <> 0
       THEN
         IF l_net_line_revenue_total > 0
         THEN
           l_line_adjustable :=
                    LEAST(l_net_line_revenue_total,l_revenue_amount_split);
         ELSIF l_net_line_revenue_total < 0
         THEN
           l_line_adjustable :=
                    GREATEST(l_net_line_revenue_total,l_revenue_amount_split);
         ELSE
           l_line_adjustable := 0;
         END IF;
         l_line_amount := ROUND(l_revenue_amount * l_line_adjustable
                         / l_adj_trx_total , AR_RAAPI_UTIL.g_trx_precision);
         IF l_line_amount <> 0
         THEN
           l_line_count := l_line_count + 1;
           l_total_adjusted := l_total_adjusted + l_line_amount;
           IF  l_line_count = l_no_of_lines AND
               l_total_adjusted <> l_revenue_amount
           THEN
             l_line_amount := l_line_amount + l_revenue_amount
                                             - l_total_adjusted;
           END IF;
         END IF;
         /* Bug 2143925 - get the line amount in SOB currency */
         l_line_amount_acctd :=
           /* Bug 4675438: MOAC/SSA */
  	    ARPCURR.functional_amount(
		  amount	=> l_line_amount
                , currency_code	=> arp_global.functional_currency
                , exchange_rate	=> AR_RAAPI_UTIL.g_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
         l_line_percent := ROUND(l_line_amount / c1.amount * 100, 4);
       END IF;
       IF p_rev_adj_rec.sales_credit_type IN ('N','B') AND
          l_nonrev_percent_split <> 0
       THEN
         OPEN c_line_nonrev_total;
         FETCH c_line_nonrev_total INTO l_line_nonrev_total;
         CLOSE c_line_nonrev_total;
         l_line_nonrev_amount := ROUND(l_nonrev_amount * l_line_nonrev_total
                          / l_nonrev_trx_total, AR_RAAPI_UTIL.g_trx_precision);
         IF l_line_nonrev_amount <> 0
         THEN
           l_nonrev_line_count := l_nonrev_line_count + 1;
           l_total_nonrev_adjusted := l_total_nonrev_adjusted +
                                      l_line_nonrev_amount;
           IF l_nonrev_line_count = l_no_of_nonrev_lines AND
              l_total_nonrev_adjusted <> l_nonrev_amount
           THEN
             l_line_nonrev_amount := l_line_nonrev_amount +
                         l_nonrev_amount - l_total_nonrev_adjusted;
           END IF;
           IF p_rev_adj_rec.amount_mode = 'P'
           THEN
             l_line_nonrev_percent := p_rev_adj_rec.percent;
           ELSIF p_rev_adj_rec.amount_mode = 'A'
           THEN
             l_line_nonrev_percent := ROUND(l_line_nonrev_amount
                                      / c1.amount * 100, 4);
           ELSE   -- amount mode = 'T'
             l_line_nonrev_percent := l_nonrev_percent_split;
           END IF;
         END IF;
       END IF;

       /* 7365097 - This validation was raising an improperly
          handled exception in cases where the percent did not
          exactly equal 100.  In internal case, it was 100.0013.
          However, percent is not always going to equal 100 due
          to obscure rounding corrections, so such minor differences
          should be allowed to process successfully. */
       IF p_rev_adj_rec.sales_credit_type in ('R','B') AND l_line_amount <> 0
          AND l_revenue_percent_split <> 0 AND
          (l_line_percent + l_revenue_percent_split_new > 100 OR
           l_line_percent + l_revenue_percent_split_new < -100)
       THEN
          IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('pseudo-EXCEPTION:  Percent <> 100');
            arp_util.debug('  l_line_amount = ' || l_line_amount);
            arp_util.debug('  l_revenue_percent_split = ' ||
                              l_revenue_percent_split);
            arp_util.debug('  l_line_percent = ' || l_line_percent);
            arp_util.debug('  l_revenue_percent_split_new = ' ||
                              l_revenue_percent_split_new);
          END IF;
          -- RAISE invalid_percent;
       END IF;

       --
       -- Check if total rev/non rev percent on new salesrep exceeds limit
       --
       l_total_sc_percent := l_line_percent + l_revenue_percent_split_new +
                             l_line_nonrev_percent + l_nonrev_percent_split_new;
       IF l_total_sc_percent < 0
       THEN
         IF arp_global.sysparam.sales_credit_pct_limit IS NULL
         THEN
           l_neg_sc_limit := NULL;
         ELSE
           l_neg_sc_limit := arp_global.sysparam.sales_credit_pct_limit * -1;
         END IF;
       END IF;
       IF (l_total_sc_percent > 0 AND l_total_sc_percent >
             NVL(arp_global.sysparam.sales_credit_pct_limit,l_total_sc_percent)) OR
          (l_total_sc_percent < 0 and l_total_sc_percent <
                          NVL(l_neg_sc_limit,l_total_sc_percent))
       THEN
         RAISE invalid_sc_total;
       END IF;

       l_no_of_salesreps := 0;
       l_nr_no_of_salesreps := 0;

       --
       -- We loop thru the from salesreps twice, firstly to find the number of
       -- valid salesreps, and secondly to process the actual transfer
       --
       FOR srrec in c_get_from_salesreps LOOP
         IF l_line_amount <> 0 AND
            p_rev_adj_rec.sales_credit_type IN ('R','B') AND
            l_revenue_percent_split <> 0
         THEN
           l_amount_prorata := ROUND(l_line_amount * srrec.revenue_percent_split
                      / l_revenue_percent_split, AR_RAAPI_UTIL.g_trx_precision);
           IF l_amount_prorata <> 0
           THEN
             l_no_of_salesreps := l_no_of_salesreps + 1;
           END IF;
         END IF;
         IF p_rev_adj_rec.sales_credit_type in ('N','B') AND
            l_line_nonrev_amount <> 0 AND l_nonrev_percent_split <> 0
         THEN
           l_nonrev_amount_prorata := ROUND(l_line_nonrev_amount *
                  srrec.nonrev_percent_split / l_nonrev_percent_split,
                     AR_RAAPI_UTIL.g_trx_precision);
           IF l_nonrev_amount_prorata <> 0
           THEN
             l_nr_no_of_salesreps := l_nr_no_of_salesreps + 1;
           END IF;
         END IF;
       END LOOP;  -- c_get_from_salesreps loop(1)

       /* Bug 2543675 - insert target sales credit and get the credit ccid
       before debiting the source sales reps */
       IF l_line_amount <> 0 AND
          p_rev_adj_rec.sales_credit_type IN ('R','B') AND
          l_revenue_percent_split <> 0
       THEN
         insert_sales_credit(  AR_RAAPI_UTIL.g_customer_trx_id,
                               AR_RAAPI_UTIL.g_to_salesrep_id,
                               AR_RAAPI_UTIL.g_to_salesgroup_id,
                               l_cust_trx_line_id,
                               l_line_amount,
                               l_line_percent,
                               'R',
                               l_credit_sales_credit_id,
                               x_adjustment_id,
                               l_rev_adj_rec.gl_date);

         --
         -- Initiate auto accounting procedure to find ccid to credit
         --
	 -- Bug 1930302 : Added warehouse_id as 16th parameter.

         ARP_AUTO_ACCOUNTING.do_autoaccounting('G'
                                              ,'REV'
                                              ,AR_RAAPI_UTIL.g_customer_trx_id
                                              ,l_cust_trx_line_id
                                              ,NULL
                                              ,NULL
                                              ,l_rev_adj_rec.gl_date
                                              ,NULL
                                              ,l_line_amount
                                              ,NULL
                                              ,NULL
                                              ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                              ,AR_RAAPI_UTIL.g_to_salesrep_id
                                              ,c1.inventory_item_id
                                              ,c1.memo_line_id
					      ,c1.warehouse_id
                                              ,l_credit_ccid
                                              ,l_concat_segments
                                              ,l_fail_count);
         IF l_credit_ccid IS NULL
         THEN
            l_credit_ccid := FND_FLEX_EXT.GET_CCID
                                 ('SQLGL'
                                 ,'GL#'
                                 ,arp_global.chart_of_accounts_id
                                 ,TO_CHAR(l_rev_adj_rec.gl_date,'DD-MON-YYYY')
                                 ,l_concat_segments);
         END IF;

         IF l_credit_ccid = -1 OR
            l_credit_ccid = 0 OR
            l_fail_count > 0
         THEN
           RAISE invalid_ccid;
         END IF;

       END IF;

       FOR c2 IN c_get_from_salesreps LOOP

         IF l_line_amount <> 0 AND
            p_rev_adj_rec.sales_credit_type IN ('R','B') AND
            l_revenue_percent_split <> 0
         THEN
           /* Bug 6932079 - Added the NVL for c2.revenue_percent_split */
           l_amount_prorata := ROUND(l_line_amount * NVL(c2.revenue_percent_split, 0)
                      / l_revenue_percent_split, AR_RAAPI_UTIL.g_trx_precision);
           /* Bug 2143925 - get the pro rata amount in SOB currency */
           /* Bug 4675438: MOAC/SSA */
           l_amount_prorata_acctd :=
  	    ARPCURR.functional_amount(
		  amount	=> l_amount_prorata
                , currency_code	=> arp_global.functional_currency
                , exchange_rate	=> AR_RAAPI_UTIL.g_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
           l_percent_prorata :=
                       ROUND((l_amount_prorata / c1.amount) * 100,4);
    /* Added these debug messages as part of bug 6932079 */
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('l_amount_prorata = ' || l_amount_prorata);
       arp_util.debug('l_percent_prorata = ' || l_percent_prorata);
    END IF;

           IF l_amount_prorata <> 0
           THEN
             l_salesrep_count := l_salesrep_count + 1;
             l_line_adjusted := l_line_adjusted + l_amount_prorata;
             /* Bug 2143925 */
             l_line_adjusted_acctd := l_line_adjusted_acctd +
                                                       l_amount_prorata_acctd;
             l_line_percent_adjusted := l_line_percent_adjusted +
                                         l_percent_prorata;
             IF l_salesrep_count = l_no_of_salesreps
             THEN
               l_last_salesrep_flag := 'Y'; -- Bug 2477881
               IF l_line_adjusted <> l_line_amount
               THEN
                 l_amount_prorata := l_amount_prorata + l_line_amount
                                                     - l_line_adjusted;
               END IF;
               /* Bug 2143925 */
               IF l_line_adjusted_acctd <> l_line_amount_acctd
               THEN
                 l_amount_prorata_acctd := l_amount_prorata_acctd
                               + l_line_amount_acctd - l_line_adjusted_acctd;
               END IF;
               IF l_line_percent_adjusted <> l_line_percent
               THEN
                 l_percent_prorata := l_percent_prorata + l_line_percent
                                          - l_line_percent_adjusted;
               END IF;
             ELSE
               l_last_salesrep_flag := 'N'; -- Bug 2477881
             END IF;
             insert_sales_credit(AR_RAAPI_UTIL.g_customer_trx_id,
                                 c2.salesrep_id,
                                 c2.salesgroup_id,
                                 l_cust_trx_line_id,
                                 l_amount_prorata * -1,
                                 l_percent_prorata * -1,
                                 'R',
                                 l_debit_sales_credit_id,
                                 x_adjustment_id,
                                 l_rev_adj_rec.gl_date);
             --
             -- Initiate auto accounting procedure to find ccid to debit
             --
             -- Bug 1930302 : Added warehouse_id as 16th parameter.

             ARP_AUTO_ACCOUNTING.do_autoaccounting
                                              ('G'
                                              ,'REV'
                                              ,AR_RAAPI_UTIL.g_customer_trx_id
                                              ,l_cust_trx_line_id
                                              ,NULL
                                              ,NULL
                                              ,l_rev_adj_rec.gl_date
                                              ,NULL
                                              ,l_amount_prorata
                                              ,NULL
                                              ,NULL
                                              ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                              ,c2.salesrep_id
                                              ,c1.inventory_item_id
                                              ,c1.memo_line_id
					      ,c1.warehouse_id
                                              ,l_debit_ccid
                                              ,l_concat_segments
                                              ,l_fail_count);
             IF l_debit_ccid IS NULL
             THEN
                l_debit_ccid :=
                          FND_FLEX_EXT.GET_CCID
                                   ('SQLGL'
                                   ,'GL#'
                                   ,arp_global.chart_of_accounts_id
                                   ,TO_CHAR(l_rev_adj_rec.gl_date,'DD-MON-YYYY')
                                   ,l_concat_segments);
             END IF;
             IF l_debit_ccid = -1 OR
                l_debit_ccid = 0 OR
                l_fail_count > 0
             THEN
               RAISE invalid_ccid;
             END IF;

             IF c1.accounting_rule_id IS NOT NULL
             THEN
               transfer_salesrep_revenue
                   (c1.customer_trx_line_id
                   ,AR_RAAPI_UTIL.g_customer_trx_id
                   ,l_debit_sales_credit_id
                   ,l_amount_prorata * -1
                   ,l_amount_prorata_acctd * -1 -- Bug 2143925
                   ,l_rev_adj_rec.gl_date
                   ,l_debit_ccid
                   ,l_last_salesrep_flag        -- Bug 2477881
                   ,l_line_amount * -1          -- Bug 2477881
                   ,l_line_amount_acctd * -1    -- Bug 2477881
                   ,x_adjustment_id);
               /* Bug 2543675 - insert 1 credit for every debit */
               transfer_salesrep_revenue
                   (c1.customer_trx_line_id
                   ,AR_RAAPI_UTIL.g_customer_trx_id
                   ,l_credit_sales_credit_id
                   ,l_amount_prorata
                   ,l_amount_prorata_acctd
                   ,l_rev_adj_rec.gl_date
                   ,l_credit_ccid
                   ,l_last_salesrep_flag        -- Bug 2477881
                   ,l_line_amount               -- Bug 2477881
                   ,l_line_amount_acctd         -- Bug 2477881
                   ,x_adjustment_id);
             ELSE
               insert_distribution(l_cust_trx_line_id,
                                   l_debit_ccid,
                                   l_percent_prorata * -1,
                                   l_amount_prorata_acctd * -1, -- Bug 2143925
                                   l_gl_date_valid, -- Bug 2146970
                                   l_rev_adj_rec.gl_date,
                                   'REV',
                                   l_amount_prorata * -1,
                                   l_debit_sales_credit_id,
                                   AR_RAAPI_UTIL.g_customer_trx_id,
                                   x_adjustment_id);
               /* Bug 2543675 - insert 1 credit for every debit */
               insert_distribution(l_cust_trx_line_id,
                                   l_credit_ccid,
                                   l_percent_prorata ,
                                   l_amount_prorata_acctd,
                                   l_gl_date_valid,
                                   l_rev_adj_rec.gl_date,
                                   'REV',
                                   l_amount_prorata,
                                   l_credit_sales_credit_id,
                                   AR_RAAPI_UTIL.g_customer_trx_id,
                                   x_adjustment_id);

             END IF;
           END IF;
         END IF;

         IF p_rev_adj_rec.sales_credit_type in ('N','B') AND
            l_line_nonrev_amount <> 0 AND l_nonrev_percent_split <> 0
         THEN
           l_nonrev_amount_prorata := ROUND(l_line_nonrev_amount *
                  c2.nonrev_percent_split / l_nonrev_percent_split,
                     AR_RAAPI_UTIL.g_trx_precision);
           l_nonrev_percent_prorata :=
               ROUND((l_nonrev_amount_prorata / c1.amount) * 100,4);

           IF l_nonrev_percent_prorata <> 0
           THEN
             l_nr_salesrep_count := l_nr_salesrep_count + 1;
             l_nr_line_adjusted := l_nr_line_adjusted + l_nonrev_amount_prorata;
             l_nr_line_pct_adjusted := l_nr_line_pct_adjusted +
                                         l_nonrev_percent_prorata;
             IF l_nr_salesrep_count = l_nr_no_of_salesreps
             THEN
               IF l_nr_line_adjusted <> l_line_nonrev_amount
               THEN
                 l_nonrev_amount_prorata := l_nonrev_amount_prorata
                             + l_line_nonrev_amount - l_nr_line_adjusted;
               END IF;
               IF l_nr_line_pct_adjusted <> l_line_nonrev_percent
               THEN
                 l_nonrev_percent_prorata := l_nonrev_percent_prorata +
                               l_line_nonrev_percent - l_nr_line_pct_adjusted;
               END IF;
             END IF;
             insert_sales_credit(AR_RAAPI_UTIL.g_customer_trx_id,
                                 c2.salesrep_id,
                                 c2.salesgroup_id,
                                 l_cust_trx_line_id,
                                 l_nonrev_amount_prorata * -1,
                                 l_nonrev_percent_prorata * -1,
                                 'N',
                                 l_debit_sales_credit_id,
                                 x_adjustment_id,
                                 NULL);
           END IF;
         END IF;

       END LOOP;  -- c_get_from_salesreps loop (2)

       l_line_adjusted := 0;
       l_line_adjusted_acctd := 0; -- Bug 2143925
       l_line_percent_adjusted := 0;
       l_nr_line_adjusted := 0;
       l_nr_line_pct_adjusted := 0;

       IF p_rev_adj_rec.sales_credit_type in ('N','B') AND
          l_line_nonrev_amount <> 0 AND l_nonrev_percent_split <> 0
       THEN
         insert_sales_credit(  AR_RAAPI_UTIL.g_customer_trx_id,
                               AR_RAAPI_UTIL.g_to_salesrep_id,
                               AR_RAAPI_UTIL.g_to_salesgroup_id,
                               l_cust_trx_line_id,
                               l_line_nonrev_amount,
                               l_line_nonrev_percent,
                               'N',
                               l_credit_sales_credit_id,
                               x_adjustment_id,
                               NULL);
       END IF;

     END LOOP;  --  c_line loop

    EXCEPTION
     WHEN invalid_sc_total THEN
        /* Bug 2191739 - call to message API for degovtized message */
        FND_MESSAGE.set_name (
                       application => 'AR',
                       name => gl_public_sector.get_message_name
                               (p_message_name => 'AR_RA_SALES_CREDIT_LIMIT',
                                p_app_short_name => 'AR'));
       FND_MESSAGE.set_token('SALES_CREDIT_LIMIT',
                     arp_global.sysparam.sales_credit_pct_limit);
       FND_MESSAGE.set_token('SALESREP_NAME',l_new_salesrep_name);
       FND_MESSAGE.set_token('LINE_NUMBER',l_line_number);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;

     WHEN invalid_amount THEN
      IF p_rev_adj_rec.amount_mode = 'P'
      THEN
        l_max_percent := ROUND(l_nonrev_trx_total / l_trx_total * 100,2);
        FND_MESSAGE.set_name
          (application => 'AR', name => 'AR_RA_PCT_EXCEEDS_AVAIL_PCT');
        FND_MESSAGE.set_token('TOT_AVAIL_PCT',l_max_percent);
      ELSE
       FND_MESSAGE.SET_NAME
        (application => 'AR', name => 'AR_RA_AMT_EXCEEDS_AVAIL_REV');
       FND_MESSAGE.set_token('TOT_AVAIL_REV',
                            AR_RAAPI_UTIL.g_trx_currency||' '||l_adj_trx_total);
       END IF;
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    WHEN invalid_zero THEN
       FND_MESSAGE.set_name
          (application => 'AR', name => 'AR_RA_ZERO_AMOUNT');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN invalid_ccid THEN
       FND_MSG_PUB.Add;
       FND_MESSAGE.SET_NAME(application => 'AR',
                            name => 'AR_RA_INVALID_CODE_COMB');
       FND_MESSAGE.SET_TOKEN('CODE_COMBINATION',l_concat_segments);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS then
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
          ('20001 error at AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Transfer_Sales_Credits: ' || 'Unexpected error '||sqlerrm||
                     ' at AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END;
    --
    -- End of Inner Block
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits()-');
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Transfer_Sales_Credits_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Transfer_Sales_Credits: ' || 'Unexpected error '||sqlerrm||
                    ' at AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits()+');
                END IF;
		ROLLBACK TO Transfer_Sales_Credits_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Transfer_Sales_Credits: ' || '20001 error '||
                     ' at AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits()+');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Transfer_Sales_Credits: ' || 'Unexpected error '||sqlerrm||
                     ' at AR_Revenue_Adjustment_PVT.Transfer_Sales_Credits()+');
                  END IF;
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		  IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		  END IF;
		END IF;
		ROLLBACK TO Transfer_Sales_Credits_PVT;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);

  END Transfer_Sales_Credits;

-----------------------------------------------------------------------
--	API name 	: Add_Non_Revenue_Sales_Credits
--	Type		: Private
--	Function	: Adds non revenue sales credits to the specified
--                        salesrep subject to any maximum limit of revenue
--                        and non revenue salsescredit per salesrep per line
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
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		:
--
  PROCEDURE Add_Non_Revenue_Sales_Credits
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2
     ,p_commit	              IN   VARCHAR2
     ,p_validation_level      IN   NUMBER
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2)
  IS
    l_api_name            CONSTANT VARCHAR2(30) :=
                                                'Add_Non_Revenue_Sales_Credits';
    l_api_version         CONSTANT NUMBER 	:= 2.0;
    l_rev_adj_rec                  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type;

    l_trx_total                    NUMBER;
    l_line_count                   NUMBER;
    l_no_of_lines                  NUMBER;
    l_total_adjusted               NUMBER;
    l_line_adjusted                NUMBER;
    l_amount                       NUMBER;
    l_line_amount                  NUMBER;
    l_line_percent	           NUMBER;
    l_sales_credit_id              NUMBER;

    l_revenue_amount_split_new     NUMBER;
    l_revenue_percent_split_new    NUMBER;
    l_nonrev_amount_split_new      NUMBER;
    l_nonrev_percent_split_new     NUMBER;
    l_transferable_amount          NUMBER;
    l_cust_trx_line_id	           NUMBER;
    l_line_number	           NUMBER;
    l_total_sc_percent             NUMBER;
    l_neg_sc_limit                 NUMBER;
    l_new_salesrep_name            ra_salesreps.name%TYPE;

    invalid_sc_total               EXCEPTION;
    invalid_amount                 EXCEPTION;

    CURSOR c_trx_total IS
      SELECT SUM(NVL(s.revenue_amount_split,0))
      FROM   ra_cust_trx_line_salesreps s
            ,mtl_item_categories mic
            ,ra_customer_trx_lines l
      WHERE  s.customer_trx_line_id = l.customer_trx_line_id
      AND    l.line_type = 'LINE'
      AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
      AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,
                                          l.customer_trx_line_id)
      AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
      AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
      AND    l.inventory_item_id = mic.inventory_item_id(+)
      AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                 DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
      AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id;

    CURSOR c_line_count IS
      SELECT COUNT(*)
      FROM   mtl_item_categories mic
            ,ra_customer_trx_lines l
      WHERE  l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
      AND    l.line_type = 'LINE'
      AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,
                                          l.customer_trx_line_id)
      AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
      AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
      AND    l.inventory_item_id = mic.inventory_item_id(+)
      AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                 DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
      AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id;

    CURSOR c_line IS
      SELECT l.customer_trx_line_id
            ,l.line_number
            ,SUM(NVL(s.revenue_amount_split,0)) amount
      FROM   mtl_item_categories mic
            ,ra_cust_trx_line_salesreps s
            ,ra_customer_trx_lines l
      WHERE  l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
      AND    l.customer_trx_line_id = s.customer_trx_line_id
      AND    l.customer_trx_line_id =
             NVL (AR_RAAPI_UTIL.g_from_cust_trx_line_id, l.customer_trx_line_id)
      AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
      AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
      AND    l.inventory_item_id = mic.inventory_item_id(+)
      AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                 DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
      AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
      AND    l.line_type = 'LINE'
      GROUP BY l.customer_trx_line_id
              ,l.line_number;

    CURSOR get_salesrep_lines_new is
      SELECT NVL(SUM(s.revenue_amount_split),0),
             NVL(SUM(s.revenue_percent_split),0),
             NVL(SUM(s.non_revenue_amount_split),0),
             NVL(SUM(s.non_revenue_percent_split),0)
      FROM   ra_cust_trx_line_salesreps s,
             ra_customer_trx_lines l
      WHERE  s.customer_trx_line_id = l_cust_trx_line_id
      AND    s.salesrep_id = AR_RAAPI_UTIL.g_to_salesrep_id
      AND DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)) =
             	NVL(AR_RAAPI_UTIL.g_to_salesgroup_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)))
      AND    l.line_type = 'LINE'
      AND    l.customer_trx_line_id = s.customer_trx_line_id
      AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id;

    CURSOR c_new_salesrep_name IS
      SELECT name
      FROM   ra_salesreps
      WHERE  salesrep_id = AR_RAAPI_UTIL.g_to_salesrep_id;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits()+');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT Add_Non_Rev_Sales_Credits_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Add_Non_Revenue_Sales_Credits: ' || 'Unexpected error '||sqlerrm||
              ' at AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits()+');
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

    l_rev_adj_rec := p_rev_adj_rec;

    /*Bug 6731185 JVARKEY Making sure GL date has no timestamp*/
    l_rev_adj_rec.gl_date := trunc(p_rev_adj_rec.gl_date);

    l_rev_adj_rec.adjustment_type := 'NR';

    AR_RAAPI_UTIL.Constant_System_Values;
    AR_RAAPI_UTIL.Initialize_Globals;
    AR_RAAPI_UTIL.Validate_Parameters (p_init_msg_list    => FND_API.G_FALSE
                                      ,p_rev_adj_rec      => l_rev_adj_rec
                                      ,p_validation_level => p_validation_level
                                      ,x_return_status    => x_return_status
                                      ,x_msg_count        => x_msg_count
                                      ,x_msg_data         => x_msg_data);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

     --
     -- Inner PL/SQL block to ensure consistent error handling
     --
     BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits(2)+');
     END IF;
     l_amount := 0;
     l_line_count := 0;
     l_total_adjusted := 0;
     l_line_adjusted :=0;

     OPEN c_trx_total;
     FETCH c_trx_total INTO l_trx_total;
     CLOSE c_trx_total;

     OPEN c_new_salesrep_name;
     FETCH c_new_salesrep_name INTO l_new_salesrep_name;
     CLOSE c_new_salesrep_name;
     --
     -- Determine amount to be added
     --
     OPEN c_line_count;
     FETCH c_line_count INTO l_no_of_lines;
     CLOSE c_line_count;

     IF p_rev_adj_rec.amount_mode = 'A'
     THEN
       l_amount := p_rev_adj_rec.amount;
     ELSIF p_rev_adj_rec.amount_mode = 'P'
     THEN
       l_amount := ROUND(l_trx_total * p_rev_adj_rec.percent / 100,
                                AR_RAAPI_UTIL.g_trx_precision);
     END IF;
     IF l_amount = 0
     THEN
       RAISE invalid_amount;
     END IF;

     create_adjustment
     (p_rev_adj_rec           => l_rev_adj_rec
     ,x_adjustment_id         => x_adjustment_id
     ,x_adjustment_number     => x_adjustment_number);

     --
     -- Now add the amount to each line pro rata
     --
     FOR c1 IN c_line LOOP

       l_cust_trx_line_id := c1.customer_trx_line_id;
       l_line_number := c1.line_number;
       l_line_amount := 0;
       l_line_percent := 0;

       l_line_amount := ROUND(l_amount * c1.amount
                              / l_trx_total , AR_RAAPI_UTIL.g_trx_precision);

       IF l_line_amount <> 0
       THEN
         l_line_count := l_line_count + 1;
         l_total_adjusted := l_total_adjusted + l_line_amount;
         IF l_line_count = l_no_of_lines AND l_total_adjusted <> l_amount
         THEN
           l_line_amount := l_line_amount + l_amount - l_total_adjusted;
         END IF;
         IF p_rev_adj_rec.amount_mode = 'P'
         THEN
           l_line_percent := p_rev_adj_rec.percent;
         ELSE
           l_line_percent := ROUND(l_line_amount / c1.amount * 100, 4);
         END IF;
       END IF;

       OPEN get_salesrep_lines_new;
       FETCH get_salesrep_lines_new INTO l_revenue_amount_split_new,
                                         l_revenue_percent_split_new,
                                         l_nonrev_amount_split_new,
                                         l_nonrev_percent_split_new;
       CLOSE get_salesrep_lines_new;

       --
       -- Check if total rev/non rev percent on new salesrep exceeds limit
       --
       l_total_sc_percent := l_line_percent + l_revenue_percent_split_new +
                             l_nonrev_percent_split_new;
       IF l_total_sc_percent < 0
       THEN
         IF arp_global.sysparam.sales_credit_pct_limit IS NULL
         THEN
           l_neg_sc_limit := NULL;
         ELSE
           l_neg_sc_limit := arp_global.sysparam.sales_credit_pct_limit * -1;
         END IF;
       END IF;
       IF (l_total_sc_percent > 0 AND l_total_sc_percent >
             NVL(arp_global.sysparam.sales_credit_pct_limit,l_total_sc_percent)) OR
          (l_total_sc_percent < 0 and l_total_sc_percent <
                          NVL(l_neg_sc_limit,l_total_sc_percent))
       THEN
         RAISE invalid_sc_total;
       END IF;

       insert_sales_credit(  AR_RAAPI_UTIL.g_customer_trx_id,
                             AR_RAAPI_UTIL.g_to_salesrep_id,
                             AR_RAAPI_UTIL.g_to_salesgroup_id,
                             l_cust_trx_line_id,
                             l_line_amount,
                             l_line_percent,
                             'N',
                             l_sales_credit_id,
                             x_adjustment_id,
                             NULL);

     END LOOP;  --  c_line LOOP

   EXCEPTION
     WHEN invalid_sc_total THEN
       /* Bug 2191739 - call to message API for degovtized message */
       FND_MESSAGE.set_name (
                       application => 'AR',
                       name => gl_public_sector.get_message_name
                               (p_message_name => 'AR_RA_SALES_CREDIT_LIMIT',
                                p_app_short_name => 'AR'));
       FND_MESSAGE.set_token('SALES_CREDIT_LIMIT',
                             arp_global.sysparam.sales_credit_pct_limit);
       FND_MESSAGE.set_token('SALESREP_NAME',l_new_salesrep_name);
       FND_MESSAGE.set_token('LINE_NUMBER',l_line_number);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN invalid_amount THEN
       FND_MESSAGE.SET_NAME
        (application => 'AR', name => 'AR_RA_AMT_EXCEEDS_AVAIL_REV');
       FND_MESSAGE.set_token('TOT_AVAIL_REV',
                             AR_RAAPI_UTIL.g_trx_currency||' '||'0');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS then
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
   ('20001 error at AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Add_Non_Revenue_Sales_Credits: ' || 'Unexpected error '||sqlerrm||
              ' at AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END;
    --
    -- End of Inner Block
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits()-');
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Add_Non_Rev_Sales_Credits_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Add_Non_Revenue_Sales_Credits: ' || 'Unexpected error '||sqlerrm||
              ' at AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits()+');
                END IF;
		ROLLBACK TO Add_Non_Rev_Sales_Credits_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Add_Non_Revenue_Sales_Credits: ' || '20001 error '||
              ' at AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits()+');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Add_Non_Revenue_Sales_Credits: ' || 'Unexpected error '||sqlerrm||
              ' at AR_Revenue_Adjustment_PVT.Add_Non_Revenue_Sales_Credits()+');
                  END IF;
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		  IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		  END IF;
		END IF;
		ROLLBACK TO Add_Non_Rev_Sales_Credits_PVT;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  END Add_Non_Revenue_Sales_Credits;

  PROCEDURE transfer_salesrep_revenue
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_sales_credit_id       IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_revenue_acctd_amount  IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_ccid                  IN NUMBER
     ,p_last_salesrep_flag    IN VARCHAR2   -- Bug 2477881
     ,p_line_amount           IN NUMBER     -- Bug 2477881
     ,p_line_amount_acctd     IN NUMBER     -- Bug 2477881
     ,p_adjustment_id         IN NUMBER)
  IS
     l_user_id                NUMBER := 0;
     l_line_id                NUMBER := 0;
     l_dist_amount            NUMBER := 0;
     l_dist_acctd_amount      NUMBER := 0;
     l_dist_percent           NUMBER := 0;
     l_no_of_assignments      NUMBER := 0;
     l_assignment_count       NUMBER := 0;
     l_assignment_total       NUMBER := 0;
     l_dist_tot               NUMBER := 0;
     l_dist_acctd_tot         NUMBER := 0;
     l_dist_pct_tot           NUMBER := 0; -- Bug 2477881
     l_revenue_percent        NUMBER := 0; -- Bug 2477881
     l_ext_amount	      NUMBER := 0;
     l_acc_rule_duration      NUMBER := 0;
     l_rule_start_date        DATE;
     l_deferred_revenue_flag  VARCHAR2(1);
     l_deferred_days          NUMBER := 0;
     l_gl_date                DATE;
     l_gl_date_valid          DATE; -- Bug 2146970
     l_cr_account_class       ra_cust_trx_line_gl_dist.account_class%TYPE;
     l_revenue_type           VARCHAR2(10);
     l_gl_date_total          NUMBER;     -- Bug 2477881
     l_gl_date_acctd_total    NUMBER;     -- Bug 2477881
     l_gl_date_pct_total      NUMBER;     -- Bug 2477881
     l_correct_gl_date_amt    NUMBER;     -- Bug 2477881
     l_correct_gl_date_acctd_amt  NUMBER; -- Bug 2477881
     l_correct_gl_date_pct    NUMBER;     -- Bug 2477881

     l_round_acctd_amount     NUMBER;
     l_acctd_round_flag       boolean := FALSE;

     CURSOR c_assignment_count IS
     SELECT SUM(ar.amount), count(*)
     FROM   ar_revenue_assignments ar,
            gl_sets_of_books sob
     WHERE  customer_trx_line_id = p_customer_trx_line_id
     AND    sob.set_of_books_id = arp_global.sysparam.set_of_books_id
     AND    ar.period_set_name = sob.period_set_name
     AND    ar.account_class = 'REV';

     CURSOR c_revenue_assignment IS
     SELECT (ar.gl_date + l_deferred_days) gl_date,
            SUM(ar.amount) amount
     FROM   ar_revenue_assignments ar,
            gl_sets_of_books sob
     WHERE  ar.customer_trx_line_id = p_customer_trx_line_id
     AND    sob.set_of_books_id = arp_global.sysparam.set_of_books_id
     AND    ar.period_set_name = sob.period_set_name
     AND    ar.account_class = 'REV'
     GROUP BY ar.gl_date
     ORDER BY (ar.gl_date + l_deferred_days);
   -- Bug 6640822 , added order by clause in the above query

     CURSOR c_line IS
     SELECT l.customer_trx_line_id,
            l.extended_amount,
            l.accounting_rule_duration,
            r.deferred_revenue_flag,
            l.rule_start_date
     FROM   ra_customer_trx_lines l,
            ra_rules r
     WHERE  l.accounting_rule_id = r.rule_id
     AND    l.customer_trx_line_id = p_customer_trx_line_id
     AND    l.customer_trx_id = p_customer_trx_id
     AND    l.line_type = 'LINE';

  BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.transfer_salesrep_revenue()+');
        arp_util.debug('  p_customer_trx_line_id = ' || p_customer_trx_line_id);
        arp_util.debug('  p_customer_trx_id      = ' || p_customer_trx_id);
        arp_util.debug('  p_sales_credit_id      = ' || p_sales_credit_id);
        arp_util.debug('  p_revenue_amount       = ' || p_revenue_amount);
        arp_util.debug('  p_revenue_acctd_amount = ' || p_revenue_acctd_amount);
        arp_util.debug('  p_line_amount          = ' || p_line_amount);
        arp_util.debug('  p_line_amount_acctd    = ' || p_line_amount_acctd);
     END IF;

     FND_PROFILE.get('USER_ID',l_user_id);
     IF l_user_id IS NULL
     THEN
       l_user_id := 0;
     ELSE
       l_user_id := FND_GLOBAL.USER_ID;
     END IF;

     l_dist_tot := 0;
     l_dist_pct_tot := 0; -- Bug 2477881
     l_dist_acctd_tot := 0; -- Bug 2143925

     OPEN c_line;
     FETCH c_line INTO l_line_id,
                       l_ext_amount,
                       l_acc_rule_duration,
                       l_deferred_revenue_flag,
                       l_rule_start_date;
     CLOSE c_line;

     /* Bug 2477881 - find overall percent to check pct rounding errors */
     IF (p_revenue_amount = l_ext_amount OR l_ext_amount = 0)
     THEN
        l_revenue_percent := 100;
     ELSE
        l_revenue_percent := ROUND(((p_revenue_amount / l_ext_amount) * 100),4);
     END IF;

     IF l_deferred_revenue_flag = 'Y'
     THEN
       l_deferred_days := TRUNC(p_gl_date) - TRUNC(l_rule_start_date);
     ELSE
       l_deferred_days := 0;
     END IF;

     OPEN c_assignment_count;
     FETCH c_assignment_count INTO l_assignment_total,
                                   l_no_of_assignments;
     CLOSE c_assignment_count;

     FOR c1 in c_revenue_assignment LOOP

       l_assignment_count := l_assignment_count + 1;

       /* Bug 2143925 - calculate acctd distribution amount */
       /* Bug 2477881 - To correct rounding errors for multi salesrep transfers,
          calculate the correct overall revenue amount to be debited */
       /* Bug 4675438: MOAC/SSA */
       IF l_assignment_total = 0
       THEN
           l_dist_amount := arpcurr.currround(p_revenue_amount / l_no_of_assignments , AR_RAAPI_UTIL.g_trx_currency);
           l_dist_acctd_amount := arpcurr.currround(p_revenue_acctd_amount / l_no_of_assignments ,AR_RAAPI_UTIL.g_trx_currency);
           l_correct_gl_date_amt := arpcurr.currround(p_line_amount / l_no_of_assignments ,AR_RAAPI_UTIL.g_trx_currency);
           l_correct_gl_date_acctd_amt := arpcurr.currround(p_line_amount_acctd / l_no_of_assignments ,AR_RAAPI_UTIL.g_trx_currency);
       ELSE
           l_dist_amount := arpcurr.currround(p_revenue_amount * c1.amount / l_assignment_total , AR_RAAPI_UTIL.g_trx_currency);
           l_dist_acctd_amount := arpcurr.currround(p_revenue_acctd_amount * c1.amount / l_assignment_total , AR_RAAPI_UTIL.g_trx_currency);
           l_correct_gl_date_amt := arpcurr.currround(p_line_amount * c1.amount / l_assignment_total ,AR_RAAPI_UTIL.g_trx_currency);
           l_correct_gl_date_acctd_amt := arpcurr.currround(p_line_amount_acctd * c1.amount / l_assignment_total ,AR_RAAPI_UTIL.g_trx_currency);
       END IF;

       IF l_ext_amount = 0
       THEN
         l_dist_percent := ROUND (100 / l_no_of_assignments , 4);
       ELSE
         l_dist_percent := ROUND (l_dist_amount / l_ext_amount * 100, 4);
       END IF;

       l_dist_tot := l_dist_tot + l_dist_amount;
       /* Bug 2143925 */
       l_dist_acctd_tot := l_dist_acctd_tot + l_dist_acctd_amount;
       l_dist_pct_tot := l_dist_pct_tot + l_dist_percent;
       IF l_assignment_count = l_no_of_assignments AND
          l_dist_tot <> p_revenue_amount
       THEN
         l_dist_amount := l_dist_amount + (p_revenue_amount - l_dist_tot);
       END IF;
       /* Bug 2143925 - load any rounding difference onto last distribution */
       IF l_assignment_count = l_no_of_assignments AND
          l_dist_acctd_tot <> p_revenue_acctd_amount
       THEN
         l_dist_acctd_amount := l_dist_acctd_amount +
                                  (p_revenue_acctd_amount - l_dist_acctd_tot);
         /* 6325023 - check resulting sign of acctd_amount and prepare to
            split the distributions */
         IF SIGN(l_dist_amount) <> SIGN(l_dist_acctd_amount)
         AND SIGN(l_dist_amount) <> 0
         THEN
            l_acctd_round_flag := TRUE;
            /* back out the rounding correction */
            l_dist_acctd_amount := l_dist_acctd_amount -
                                  (p_revenue_acctd_amount - l_dist_acctd_tot);
            /* set local variable for second insert */
            l_round_acctd_amount := p_revenue_acctd_amount - l_dist_acctd_tot;
         ELSE
            l_acctd_round_flag := FALSE;
            l_round_acctd_amount := 0;
         END IF;
       END IF;

       /* Bug 2477881 - load pct rounding difference onto last distribution */
       IF l_assignment_count = l_no_of_assignments AND
          l_dist_pct_tot <> l_revenue_percent
       THEN
         l_dist_percent := l_dist_percent +
                                     (l_revenue_percent - l_dist_pct_tot);
       END IF;

       IF ((l_dist_percent > -0.01 AND l_dist_percent < 0.01) OR
            l_dist_percent > 999 OR
            l_dist_percent < -999)
       THEN
         l_dist_percent := ROUND (100 / l_no_of_assignments, 4)
                                                 * SIGN(l_dist_percent);
       END IF;
       IF NVL(l_acc_rule_duration,0) > 1
       THEN
         l_gl_date := GREATEST(p_gl_date, c1.gl_date);
       ELSE
         l_gl_date := p_gl_date;
       END IF;

       /* Bug 2146970 - validate the GL date passed in */
       l_gl_date_valid := AR_RAAPI_UTIL.bump_gl_date_if_closed       	                        (p_gl_date => l_gl_date);
       IF l_gl_date_valid IS NULL
       THEN
         FND_MESSAGE.set_name('AR','AR_RA_NO_OPEN_PERIODS');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
	 l_gl_date := l_gl_date_valid;
       END IF;

       insert_distribution (     p_customer_trx_line_id,
                                 p_ccid,
                                 l_dist_percent,
                                 l_dist_acctd_amount,
                                 l_gl_date,
                                 c1.gl_date,
                                 'REV',
                                 l_dist_amount,
                                 p_sales_credit_id,
                                 p_customer_trx_id,
                                 p_adjustment_id);

       IF l_acctd_round_flag
       THEN
          /* 6325023 - Need to insert a second dist for the acctd correction */
          insert_distribution (     p_customer_trx_line_id,
                                    p_ccid,
                                    0,
                                    l_round_acctd_amount,
                                    l_gl_date,
                                    c1.gl_date,
                                    'REV',
                                    0,
                                    p_sales_credit_id,
                                    p_customer_trx_id,
                                    p_adjustment_id,
                                    'Y');


       END IF;

     END LOOP;    -- assignments loop
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.transfer_salesrep_revenue()-');
     END IF;

  EXCEPTION

     WHEN OTHERS then
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
       ('20001 error at AR_Revenue_Adjustment_PVT.transfer_salesrep_revenue()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('transfer_salesrep_revenue: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_Revenue_Adjustment_PVT.transfer_salesrep_revenue()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

  END transfer_salesrep_revenue;

  /* Bug 3879222 - new procedure for prorations that are not
     based on salesrep.  This code is triggered when the line has
     override_auto_accounting_flag = Y */

  /* 6862351 - added p_gl_date.  This will be used to override
      the gl_date of the distributions if the rule has
      only one period.  For multiperiod schedules, the dates
      will be based on ar_revenue_assignments returns */
  PROCEDURE dists_by_model
     (p_customer_trx_id       IN NUMBER
     ,p_customer_trx_line_id  IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_adjustment_id         IN NUMBER
     ,p_user_generated_flag   IN VARCHAR2
     ,p_gl_date               IN DATE
     ,p_original_gl_date      IN DATE
     ,p_rule_start_date       IN DATE
     ,p_deferred_revenue_flag IN VARCHAR2)
  IS
     /* Locals */

     CURSOR c_psn IS
       SELECT
    	      period_set_name,
              precision,
              minimum_accountable_unit,
              asp.org_id,
              asp.set_of_books_id
       FROM
              fnd_currencies fc,
	      gl_sets_of_books gsb,
              ar_system_parameters asp
       WHERE
	      gsb.set_of_books_id = asp.set_of_books_id
       AND    fc.currency_code    = gsb.currency_code;

     rows    NUMBER;

  BEGIN
    IF PG_DEBUG in ('Y', 'C')
    THEN
      arp_util.debug('AR_Revenue_Adjustment_PVT.dists_by_model()+');
      arp_util.debug('  p_adjustment_id = ' || p_adjustment_id);
    END IF;

    /* Initialize globals for this package */
    IF g_period_set_name IS NULL
    THEN
       OPEN  c_psn;
       FETCH c_psn INTO
             g_period_set_name,
             g_base_precision,
             g_bmau,
             g_org_id,
             g_sob_id;
       CLOSE c_psn;
    END IF;

    /* 7208384 - check if rule is deferred and gl_date is passed.
       If so, we have to store the old rule_start_date, override it
       (temporarily) with the new date, and restore the old date
       after the insert. */

    /* 7556149 - Decided to disable this code for now and revisit
       if someone confirms that it works and when we have time
       to more closely examine it
    <start disabled code>
    IF p_gl_date IS NOT NULL AND
       p_deferred_revenue_flag = 'Y' AND
       p_original_gl_date <> p_rule_start_date
    THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Setting RSD from ' || p_rule_start_date ||
             ' to ' || p_original_gl_date);
       END IF;
       /+ update ra_customer_trx_lines to set RSD to override +/
       UPDATE ra_customer_trx_lines
       SET    rule_start_date = p_original_gl_date
       WHERE  customer_trx_line_id = p_customer_trx_line_id;
    END IF;
    <end disabled code>  */

    /* Insert using statement similar to one in
       arp_auto_rule.create_assignments.  Main diff is
       that this one is by line rather than trx.  */

   INSERT INTO ra_cust_trx_line_gl_dist
          (
            customer_trx_line_id,
            customer_trx_id,
            code_combination_id,
            set_of_books_id,
            account_class,
            account_set_flag,
            percent,
            amount,
            acctd_amount,
            gl_date,
            cust_trx_line_salesrep_id,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            posting_control_id,
            original_gl_date,
            cust_trx_line_gl_dist_id,
            revenue_adjustment_id,
            user_generated_flag,
            org_id
          )
   SELECT /*+ ORDERED push_pred(ra.lgd) index(dist ra_cust_trx_line_gl_dist_n1)*/
            ra.customer_trx_line_id,                /* customer_trx_line_id */
            l.customer_trx_id,                  /* customer_trx_id */
            dist.code_combination_id,               /* code_combination_id */
            arp_standard.sysparm.set_of_books_id,   /* set_of_books_id */
            ra.account_class,                       /* account_class */
            'N',                                    /* account_set_flag */
            DECODE(l.extended_amount, 0, 100,
                 ROUND((((ra.amount *  dist.percent
                               *  p_revenue_amount)
                               /  l.extended_amount)
                               /  l.extended_amount),4)), /* percent */
            DECODE(l.extended_amount, 0, 0,
               DECODE(fc.minimum_accountable_unit,
                   NULL, ROUND(((ra.amount * (dist.percent/100)
                                           *  p_revenue_amount)
                                           /  l.extended_amount),
                               fc.precision),
                         ROUND((((ra.amount * (dist.percent/100)
                                            *  p_revenue_amount)
                                            /  l.extended_amount)
                                      /  fc.minimum_accountable_unit)
                                      *  fc.minimum_accountable_unit))), /* Amount */
            DECODE(l.extended_amount, 0, 0,
                DECODE(g_bmau,
                   NULL, ROUND((((ra.amount * (dist.percent/100)
                                            *  p_revenue_amount)
                                            /  l.extended_amount)
                                            *  NVL(h.exchange_rate,1)),
                               g_base_precision),
                         ROUND(((((ra.amount * (dist.percent/100)
                                             *  p_revenue_amount)
                                             /  l.extended_amount)
                                             *  NVL(h.exchange_rate,1))
                                      /  g_bmau)
                                      *  g_bmau))), /* Acctd_amount */
	    DECODE(l.accounting_rule_duration, 1, p_gl_date,
               arp_auto_rule.assign_gl_date(ra.gl_date)),/* Derived gl_date */
            dist.cust_trx_line_salesrep_id,        /* Srep ID */
            arp_standard.profile.request_id,
            arp_standard.application_id,
            arp_standard.profile.program_id,
            sysdate,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            -3,
            ra.gl_date,                          /* original_gl_date */
            ra_cust_trx_line_gl_dist_s.NEXTVAL,  /* cust_trx_line_gl_dist_id */
            p_adjustment_id,
	    p_user_generated_flag,
            arp_standard.sysparm.org_id
   FROM
            ra_customer_trx_lines l,
            ra_customer_trx h,
            fnd_currencies fc,
            ra_cust_trx_line_gl_dist dist,
            ar_revenue_assignments ra
   WHERE
            l.customer_trx_line_id   = p_customer_trx_line_id
   AND      fc.currency_code         = h.invoice_currency_code
   AND      l.customer_trx_id        = h.customer_trx_id
   AND      ra.customer_trx_line_id  = l.customer_trx_line_id
   AND      ra.period_set_name       = g_period_set_name
   AND      dist.customer_trx_line_id= ra.customer_trx_line_id
   AND      dist.account_class       = ra.account_class
   AND      dist.account_set_flag    = 'Y'; /* model accounts */

   rows := sql%rowcount;

   /* 7208384 - now set rule_start_date back to original */

   /* 7556149 - Disabled this code until we get more time
      to test it thoroughly

   <start disabled code>
   IF p_gl_date IS NOT NULL AND
      p_deferred_revenue_flag = 'Y' AND
      p_original_gl_date <> p_rule_start_date
   THEN
     IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Setting RSD back from ' || p_original_gl_date ||
                ' to ' || p_rule_start_date);
     END IF;
     /+ update ra_customer_trx_lines to return RSD to original +/
     UPDATE ra_customer_trx_lines
     SET    rule_start_date = p_rule_start_date
     WHERE  customer_trx_line_id = p_customer_trx_line_id;
   END IF;
   <end disabled code> */

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Total lines inserted: ' || rows);
      arp_util.debug('AR_Revenue_Adjustment_PVT.dists_by_model()+');
   END IF;

   /* Note:  rounding will be handled at the transaction level
      in a call to arp_rounding.correct_rev_adj_by_line */

  END dists_by_model;

  /* end */

  PROCEDURE debit_credit
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_credit_ccid           IN NUMBER
     ,p_inventory_item_id     IN NUMBER
     ,p_memo_line_id          IN NUMBER
     ,p_adjustment_id         IN NUMBER
     ,p_user_generated_flag   IN VARCHAR2)
  IS
     l_user_id                NUMBER := 0;
     l_last_salescredit_id    NUMBER := 0;
     l_cust_trx_line_salesrep_id NUMBER := 0;
     l_latest_percent_split   NUMBER := 0;
     l_salesrep_percent       NUMBER := 0;  -- Bug 2555736
     l_debit_ccid             NUMBER := 0;
     l_credit_ccid            NUMBER := 0;
     l_line_id                NUMBER := 0;
     l_line_number            NUMBER := 0;
     l_dist_amount            NUMBER := 0;
     l_dist_acctd_amount      NUMBER := 0;
     l_dist_percent           NUMBER := 0;
     l_no_of_assignments      NUMBER := 0;
     l_assignment_count       NUMBER := 0;
     l_assignment_total       NUMBER := 0;
     l_salesrep_count         NUMBER := 0;
     l_no_of_salesreps        NUMBER := 0;
     l_dist_tot               NUMBER := 0;
     l_dist_pct_tot           NUMBER := 0;  -- Bug 2487901
     l_revenue_percent        NUMBER := 0;  -- Bug 2487901
     l_concat_segments        VARCHAR2(2000);
     l_debit_concat_segments  VARCHAR2(2000);
     l_credit_concat_segments VARCHAR2(2000);
     l_fail_count             NUMBER := 0;
     l_ext_amount	      NUMBER := 0;
     l_acc_rule_duration      NUMBER := 0;
     l_rule_start_date        DATE;
     l_deferred_revenue_flag  VARCHAR2(1);
     l_gl_date                DATE;
     l_gl_date_valid          DATE;
     l_cr_account_class       ra_cust_trx_line_gl_dist.account_class%TYPE;
     l_revenue_type           VARCHAR2(10);
     l_default_rule           VARCHAR2(80);
     l_err_mesg               VARCHAR2(2000);

     l_warehouse_id               NUMBER; -- Bug 1930302.

     invalid_salesrep         EXCEPTION;
     invalid_ccid             EXCEPTION;

     CURSOR c_assignment_count IS
     SELECT SUM(ar.amount), count(*)
     FROM   ar_revenue_assignments ar,
            gl_sets_of_books sob
     WHERE  customer_trx_line_id = p_customer_trx_line_id
     AND    sob.set_of_books_id = arp_global.sysparam.set_of_books_id
     AND    ar.period_set_name = sob.period_set_name
     AND    ar.account_class = 'REV';

     CURSOR c_revenue_assignment IS
     SELECT ar.gl_date
          , SUM(ar.amount) amount
     FROM   ar_revenue_assignments ar,
            gl_sets_of_books sob
     WHERE  ar.customer_trx_line_id = p_customer_trx_line_id
     AND    sob.set_of_books_id = arp_global.sysparam.set_of_books_id
     AND    ar.period_set_name = sob.period_set_name
     AND    ar.account_class = 'REV'
     GROUP BY ar.gl_date
     ORDER BY gl_date ASC;

     CURSOR c_salesrep_count IS
     SELECT COUNT(*)
     FROM   ra_salesreps
     WHERE  salesrep_id IN
       (SELECT salesrep_id
        FROM   ra_cust_trx_line_salesreps
        WHERE  customer_trx_line_id = p_customer_trx_line_id
        AND    NVL(revenue_percent_split,0) <> 0
        GROUP  by salesrep_id
        HAVING SUM(NVL(revenue_percent_split,0)) <> 0)
     AND    salesrep_id = NVL(p_salesrep_id,salesrep_id);

     CURSOR c_salesrep IS
     SELECT salesrep_id,
            SUM(NVL(revenue_percent_split,0)) revenue_percent_split,
            MAX(cust_trx_line_salesrep_id) max_id
     FROM   ra_cust_trx_line_salesreps
     WHERE  customer_trx_line_id = p_customer_trx_line_id
     AND    salesrep_id = NVL(p_salesrep_id,salesrep_id)
     AND    NVL(revenue_percent_split,0) <> 0
     GROUP  by salesrep_id
     HAVING SUM(NVL(revenue_percent_split,0)) <> 0;

     CURSOR c_last_salescredit IS
     SELECT NVL(revenue_percent_split,0)
     FROM   ra_cust_trx_line_salesreps
     WHERE  customer_trx_line_id = p_customer_trx_line_id
     AND    cust_trx_line_salesrep_id = l_last_salescredit_id;

     CURSOR c_line IS
     SELECT l.customer_trx_line_id,
            l.line_number,
            l.extended_amount,
            l.accounting_rule_duration,
            r.deferred_revenue_flag,
	    l.warehouse_id,
            l.rule_start_date
     FROM   ra_customer_trx_lines l,
            ra_rules r
     WHERE  l.accounting_rule_id = r.rule_id
     AND    l.customer_trx_line_id = p_customer_trx_line_id
     AND    l.customer_trx_id = p_customer_trx_id
     AND    l.line_type = 'LINE';

  BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.debit_credit()+');
        arp_util.debug('  p_customer_trx_id      = ' || p_customer_trx_id);
        arp_util.debug('  p_customer_trx_line_id = ' || p_customer_trx_line_id);
        arp_util.debug('  p_salesrep_id          = ' || p_salesrep_id);
        arp_util.debug('  p_revenue_amount       = ' || p_revenue_amount);
        arp_util.debug('  p_adjustment_id        = ' || p_adjustment_id);
     END IF;
     FND_PROFILE.get('USER_ID',l_user_id);
     IF l_user_id IS NULL
     THEN
       l_user_id := 0;
     ELSE
       l_user_id := FND_GLOBAL.USER_ID;
     END IF;

     l_debit_ccid := -1;
     l_credit_ccid := -1;
     l_dist_tot := 0;
     l_dist_pct_tot := 0; -- Bug 2487901

     OPEN c_line;

     -- Bug 1930302

     FETCH c_line INTO l_line_id,
                       l_line_number,
                       l_ext_amount,
                       l_acc_rule_duration,
                       l_deferred_revenue_flag,
		       l_warehouse_id,
                       l_rule_start_date;
     CLOSE c_line;

     /* Bug 2487901 - find overall percent to check pct rounding errors */
     IF (p_revenue_amount = l_ext_amount OR l_ext_amount = 0)
     THEN
        l_revenue_percent := 100;
     ELSE
        l_revenue_percent := ROUND(((p_revenue_amount / l_ext_amount) * 100),4);
     END IF;

     OPEN c_assignment_count;
     FETCH c_assignment_count INTO l_assignment_total,
                                   l_no_of_assignments;
     CLOSE c_assignment_count;

     OPEN c_salesrep_count;
     FETCH c_salesrep_count INTO l_no_of_salesreps;
     CLOSE c_salesrep_count;

     IF l_no_of_salesreps = 0
     THEN
       RAISE invalid_salesrep;
     END IF;
     l_salesrep_count := 0;

     FOR c2 in c_salesrep LOOP

       l_last_salescredit_id := c2.max_id;
       OPEN c_last_salescredit;
       FETCH c_last_salescredit INTO l_latest_percent_split;
       CLOSE c_last_salescredit;

       /* 6223281 - removed revenue_percent_split comparison
          as it was mismatching and resulting in null salesreps
          on UNEARN actions after SC xfer ones had occurred. */
       l_cust_trx_line_salesrep_id := c2.max_id;

       l_salesrep_count := l_salesrep_count + 1;

       /* Bug 2555736 - if salesrep specified salesrep percent is always 100
          otherwise use current salesrep in cursor percent */
       IF p_salesrep_id IS NOT NULL
       THEN
         l_salesrep_percent := 100;
       ELSE
         l_salesrep_percent := c2.revenue_percent_split;
       END IF;

       --
       -- Initiate auto accounting procedure to find ccid to debit
       --
       -- Bug 1930302 : Added warehouse_id as 16th parameter.

       ARP_AUTO_ACCOUNTING.do_autoaccounting
                                            ('G'
                                            ,'REV'
                                            ,p_customer_trx_id
                                            ,p_customer_trx_line_id
                                            ,NULL
                                            ,NULL
                                            ,NULL
                                            ,NULL
                                            ,NULL  --l_dist_amount
                                            ,NULL
                                            ,null
                                            ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                            ,c2.salesrep_id
                                            ,p_inventory_item_id
                                            ,p_memo_line_id
                                            ,l_warehouse_id
                                            ,l_debit_ccid
                                            ,l_debit_concat_segments
                                            ,l_fail_count);
       IF l_debit_ccid IS NULL
       THEN
          l_debit_ccid := FND_FLEX_EXT.GET_CCID
                                        ('SQLGL',
                                         'GL#',
                                         arp_global.chart_of_accounts_id,
                                         to_char(TRUNC(SYSDATE),'DD-MON-YYYY'),
                                         l_debit_concat_segments);
       END IF;
       IF (l_debit_ccid < 1 OR l_fail_count > 0)
       THEN
         l_concat_segments := l_debit_concat_segments;
         RAISE invalid_ccid;
       END IF;

       IF p_credit_ccid IS NULL
       THEN
         --
         -- Initiate auto accounting procedure
         --
  --Bug 1930302 : Added warehouse_id as 16th parameter.

         ARP_AUTO_ACCOUNTING.do_autoaccounting
                                              ('G'
                                              ,'UNEARN'
                                              ,p_customer_trx_id
                                              ,p_customer_trx_line_id
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL  --l_dist_tot
                                              ,NULL
                                              ,NULL
                                              ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                              ,c2.salesrep_id
                                              ,p_inventory_item_id
                                              ,p_memo_line_id
					      ,l_warehouse_id
                                              ,l_credit_ccid
                                              ,l_credit_concat_segments
                                              ,l_fail_count);
         l_revenue_type := 'UNEARN';
         IF l_credit_ccid IS NULL
         THEN
            l_credit_ccid :=
               FND_FLEX_EXT.GET_CCID('SQLGL',
                                   'GL#',
                                   arp_global.chart_of_accounts_id,
                                   TO_CHAR(TRUNC(SYSDATE),'DD-MON-YYYY') ,
                                   l_credit_concat_segments);
         END IF;
         IF (l_credit_ccid < 1 OR l_fail_count > 0)
         THEN
           l_concat_segments := l_credit_concat_segments;
           RAISE invalid_ccid;
         END IF;

       ELSE -- clearing account provided
         l_credit_ccid := p_credit_ccid;
         l_revenue_type := 'SUSPENSE';

       END IF;

       /* Bug 2487901 -  Since assignment loop was moved inside salescredit loop
          the assignment count must be initialized here */
       l_assignment_count := 0;

       FOR c1 in c_revenue_assignment LOOP

         l_assignment_count := l_assignment_count + 1;
         -- If revenue is deferred, get the deferred GL date
         IF NVL(l_deferred_revenue_flag,'N') = 'Y'
         THEN
           l_gl_date := AR_RAAPI_UTIL.Deferred_GL_Date
	                   (p_start_date    => p_gl_date,
	                    p_period_seq_no => l_assignment_count);


        /*--------------------------------------------------------
         | Bug # 2817503
         |
         | User passsed GL Date should override rule start date
         | if the line has an immediate rule.
         |
         | ORASHID 25-FEB-2003
         +-------------------------------------------------------*/

         ELSIF (l_acc_rule_duration = 1) THEN
           l_gl_date := NVL(p_gl_date, c1.gl_date);
         ELSE
           l_gl_date := c1.gl_date;
         END IF;

         /* Bug 2555736 - use derived salesrep percent */
         /* Bug 4675438: MOAC/SSA */
         IF l_assignment_total = 0
         THEN
           l_dist_amount := arpcurr.currround(
             p_revenue_amount * l_salesrep_percent
                   / 100 / l_no_of_assignments , AR_RAAPI_UTIL.g_trx_currency);
         ELSE
           l_dist_amount := arpcurr.currround(p_revenue_amount * l_salesrep_percent / 100 * c1.amount / l_assignment_total , AR_RAAPI_UTIL.g_trx_currency);
         END IF;
         l_dist_tot := l_dist_tot + l_dist_amount;
         IF l_salesrep_count = l_no_of_salesreps AND
            l_assignment_count = l_no_of_assignments AND
            l_dist_tot <> p_revenue_amount
         THEN
           l_dist_amount := l_dist_amount + (p_revenue_amount - l_dist_tot);
         END IF;
         IF l_ext_amount = 0
         THEN
           l_dist_percent := ROUND ((100 / l_no_of_assignments /
                                            l_no_of_salesreps), 4);
         ELSE
           l_dist_percent := ROUND (((l_dist_amount / l_ext_amount) * 100), 4);
         END IF;
         IF ((l_dist_percent > -0.01 AND l_dist_percent < 0.01) OR
              l_dist_percent > 999 OR
              l_dist_percent < -999)
         THEN
           l_dist_percent := ROUND ((100 / l_no_of_assignments /
                               l_no_of_salesreps), 4) * SIGN(l_dist_percent);
         END IF;

         /* Bug 2487901 - keep running pct total and load rounding difference
         onto last distribution */
         l_dist_pct_tot := l_dist_pct_tot + l_dist_percent;
         IF l_salesrep_count = l_no_of_salesreps AND
            l_assignment_count = l_no_of_assignments AND
            l_dist_pct_tot <> l_revenue_percent
         THEN
           l_dist_percent := l_dist_percent +
                               (l_revenue_percent - l_dist_pct_tot);
         END IF;

         /* Bug 4675438: MOAC/SSA */
         l_dist_acctd_amount :=
  	      ARPCURR.functional_amount(
		  amount	=> l_dist_amount
                , currency_code	=> arp_global.functional_currency
                , exchange_rate	=> AR_RAAPI_UTIL.g_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
	 /* Bug 2146970 - validate the GL date for all lines regardless
	    of duration  */
	 l_gl_date_valid := AR_RAAPI_UTIL.bump_gl_date_if_closed
	                        (p_gl_date        => l_gl_date);
	 IF l_gl_date_valid IS NULL
         THEN
           FND_MESSAGE.set_name('AR','AR_RA_NO_OPEN_PERIODS');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         --
         -- Step 1: Debit earned revenue account
         --
         insert_distribution (   p_customer_trx_line_id,
                                 l_debit_ccid,
                                 l_dist_percent * -1,
                                 l_dist_acctd_amount * -1,
                                 l_gl_date_valid,
                                 c1.gl_date,
                                 'REV',
                                 l_dist_amount * -1,
                                 l_cust_trx_line_salesrep_id,
                                 p_customer_trx_id,
                                 p_adjustment_id,
				 p_user_generated_flag);

         --
         -- Step 2: Credit unearned or line revenue transfer clearing account
         --

         insert_distribution (   p_customer_trx_line_id,
                                 l_credit_ccid,
                                 l_dist_percent,
                                 l_dist_acctd_amount,
                                 l_gl_date_valid,
                                 c1.gl_date,
                                 l_revenue_type,
                                 l_dist_amount,
                                 l_cust_trx_line_salesrep_id,
                                 p_customer_trx_id,
                                 p_adjustment_id,
				 p_user_generated_flag);

       END LOOP;    -- assignments loop

     END LOOP;    -- sales credit loop
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.debit_credit()-');
     END IF;

  EXCEPTION

     WHEN invalid_salesrep THEN
       FND_MESSAGE.SET_NAME(application => 'AR',
                            name => 'AR_RA_NO_REV_SALES_CREDIT');
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_number);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN invalid_ccid THEN
       FND_MSG_PUB.Add;
       FND_MESSAGE.SET_NAME(application => 'AR',
                            name => 'AR_RA_INVALID_CODE_COMB');
       FND_MESSAGE.SET_TOKEN('CODE_COMBINATION',l_concat_segments);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS then
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
           ('20001 error at AR_Revenue_Adjustment_PVT.debit_credit()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('debit_credit: ' || 'Unexpected error '||sqlerrm||
                           ' at AR_Revenue_Adjustment_PVT.debit_credit()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

  END debit_credit;

  /* 5021530 - This logic handles no-rules cases
        where sreps exist. (old logic that is dependent on SRs) */
  PROCEDURE no_rule_debit_credit
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_credit_ccid           IN NUMBER
     ,p_inventory_item_id     IN NUMBER
     ,p_memo_line_id          IN NUMBER
     ,p_adjustment_id         IN NUMBER
     ,p_user_generated_flag   IN VARCHAR2)
  IS
     l_user_id                NUMBER := 0;
     l_last_salescredit_id    NUMBER := 0;
     l_cust_trx_line_salesrep_id NUMBER := 0;
     l_latest_percent_split   NUMBER := 0;
     l_debit_ccid             NUMBER := 0;
     l_credit_ccid            NUMBER := 0;
     l_line_id                NUMBER := 0;
     l_line_number            NUMBER := 0;
     l_dist_amount            NUMBER := 0;
     l_dist_acctd_amount      NUMBER := 0;
     l_dist_percent           NUMBER := 0;
     l_salesrep_count         NUMBER := 0;
     l_no_of_salesreps        NUMBER := 0;
     l_salesrep_percent       NUMBER := 0;  -- Bug 2555736
     l_dist_tot               NUMBER := 0;
     l_concat_segments        VARCHAR2(2000);
     l_new_concat_segments    VARCHAR2(2000);
     l_fail_count             NUMBER := 0;
     l_ext_amount	      NUMBER := 0;
     l_acc_rule_duration      NUMBER := 0;
     l_gl_date                DATE;
     l_cr_account_class       ra_cust_trx_line_gl_dist.account_class%TYPE;
     l_revenue_type           VARCHAR2(10);

     l_warehouse_id               NUMBER; -- Bug 1930302.

     invalid_salesrep         EXCEPTION;
     invalid_ccid             EXCEPTION;
     invalid_other            EXCEPTION;

     CURSOR c_salesrep_count IS
     SELECT COUNT(*)
     FROM   ra_salesreps
     WHERE  salesrep_id IN
       (SELECT salesrep_id
        FROM   ra_cust_trx_line_salesreps
        WHERE  customer_trx_line_id = p_customer_trx_line_id
        AND    NVL(revenue_percent_split,0) <> 0
        GROUP  by salesrep_id
        HAVING SUM(NVL(revenue_percent_split,0)) <> 0)
     AND    salesrep_id = NVL(p_salesrep_id,salesrep_id);

     CURSOR c_salesrep IS
     SELECT salesrep_id,
            SUM(NVL(revenue_percent_split,0)) revenue_percent_split,
            MAX(cust_trx_line_salesrep_id) max_id
     FROM   ra_cust_trx_line_salesreps
     WHERE  customer_trx_line_id = p_customer_trx_line_id
     AND    salesrep_id = NVL(p_salesrep_id,salesrep_id)
     AND    NVL(revenue_percent_split,0) <> 0
     GROUP  by salesrep_id
     HAVING SUM(NVL(revenue_percent_split,0)) <> 0;

     CURSOR c_last_salescredit IS
     SELECT NVL(revenue_percent_split,0)
     FROM   ra_cust_trx_line_salesreps
     WHERE  customer_trx_line_id = p_customer_trx_line_id
     AND    cust_trx_line_salesrep_id = l_last_salescredit_id;

     -- Bug 1930302

     CURSOR c_line IS
     SELECT customer_trx_line_id,
            line_number,
            extended_amount,
	    warehouse_id,
            accounting_rule_duration
     FROM   ra_customer_trx_lines
     WHERE  customer_trx_line_id = p_customer_trx_line_id
     AND    customer_trx_id = p_customer_trx_id
     AND    line_type = 'LINE';

   BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.no_rule_debit_credit()+');
        arp_util.debug('  p_customer_trx_id      = ' || p_customer_trx_id);
        arp_util.debug('  p_customer_trx_line_id = ' || p_customer_trx_line_id);
        arp_util.debug('  p_salesrep_id          = ' || p_salesrep_id);
        arp_util.debug('  p_revenue_amount       = ' || p_revenue_amount);
        arp_util.debug('  p_adjustment_id        = ' || p_adjustment_id);
     END IF;
     FND_PROFILE.get('USER_ID',l_user_id);
     IF l_user_id IS NULL
     THEN
       l_user_id := 0;
     ELSE
       l_user_id := FND_GLOBAL.USER_ID;
     END IF;

     l_debit_ccid := -1;
     l_credit_ccid := -1;
     l_dist_tot := 0;

     -- Bug 1930302

     OPEN c_line;
     FETCH c_line INTO l_line_id,
                       l_line_number,
                       l_ext_amount,
		       l_warehouse_id,
                       l_acc_rule_duration;
     CLOSE c_line;

     OPEN c_salesrep_count;
     FETCH c_salesrep_count INTO l_no_of_salesreps;
     CLOSE c_salesrep_count;


     l_salesrep_count := 0;

     FOR c1 in c_salesrep LOOP

       l_last_salescredit_id := c1.max_id;
       OPEN c_last_salescredit;
       FETCH c_last_salescredit INTO l_latest_percent_split;
       CLOSE c_last_salescredit;

       /* 6223281 - Removed revenue_percent_split comparison
          as it does not match when SC xfers and adjustments
          occurr on the same invoice line. */
       l_cust_trx_line_salesrep_id := c1.max_id;

       /* Bug 2555736 - if salesrep specified salesrep percent is always 100
          otherwise use current salesrep in cursor percent */
       IF p_salesrep_id IS NOT NULL
       THEN
         l_salesrep_percent := 100;
       ELSE
         l_salesrep_percent := c1.revenue_percent_split;
       END IF;

       /* Bug 4675438: MOAC/SSA */
       l_dist_amount := arpcurr.currround(p_revenue_amount * l_salesrep_percent / 100 , AR_RAAPI_UTIL.g_trx_currency);
       l_dist_tot := l_dist_tot + l_dist_amount;
       l_salesrep_count := l_salesrep_count + 1;
       IF l_salesrep_count = l_no_of_salesreps AND
          l_dist_tot <> p_revenue_amount
       THEN
         l_dist_amount := l_dist_amount + (p_revenue_amount - l_dist_tot);
       END IF;
       IF l_ext_amount = 0
       THEN
         IF l_no_of_salesreps = 0
         THEN
            l_dist_percent := -100;
         ELSE
            l_dist_percent := -1 * ROUND ((100 / l_no_of_salesreps) ,4);
         END IF;
       ELSE
         l_dist_percent := ROUND (((l_dist_amount / l_ext_amount) * 100), 4);
       END IF;
       IF ((l_dist_percent > -0.01 AND l_dist_percent < 0.01) OR
            l_dist_percent > 999 OR
            l_dist_percent < -999)
       THEN
         l_dist_percent := ROUND ((100 / l_no_of_salesreps), 4)
                                        * SIGN(l_dist_percent);
       END IF;
       /* Bug 4675438: MOAC/SSA */
       l_dist_acctd_amount :=
    	      ARPCURR.functional_amount(
		  amount	=> l_dist_amount
                , currency_code	=> arp_global.functional_currency
                , exchange_rate	=> AR_RAAPI_UTIL.g_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
       --
       -- Step 1: Debit earned revenue
       --

       --
       -- Initiate auto accounting procedure to find ccid to debit
       --
       -- Bug 1930302 : Added warehouse_id as 16th parameter.

       ARP_AUTO_ACCOUNTING.do_autoaccounting('G'
                                            ,'REV'
                                             ,p_customer_trx_id
                                             ,p_customer_trx_line_id
                                             ,NULL
                                             ,NULL
                                             ,NULL
                                             ,NULL
                                             ,l_dist_amount
                                             ,NULL
                                             ,NULL
                                             ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                             ,c1.salesrep_id
                                             ,p_inventory_item_id
                                             ,p_memo_line_id
					     ,l_warehouse_id
                                             ,l_debit_ccid
                                             ,l_concat_segments
                                             ,l_fail_count);
       IF l_debit_ccid IS NULL
       THEN
          l_debit_ccid := FND_FLEX_EXT.GET_CCID
                                          ('SQLGL',
                                           'GL#',
                                           arp_global.chart_of_accounts_id,
                                           to_char(p_gl_date,'DD-MON-YYYY') ,
                                           l_concat_segments);
       END IF;

       IF l_debit_ccid = -1 OR
          l_debit_ccid = 0 OR
          l_fail_count > 0
       THEN
         RAISE invalid_ccid;
       END IF;

       insert_distribution (   p_customer_trx_line_id,
                               l_debit_ccid,
                               l_dist_percent * -1,
                               l_dist_acctd_amount * -1,
                               p_gl_date,
                               p_gl_date,
                               'REV',
                               l_dist_amount * -1,
                               l_cust_trx_line_salesrep_id,
                               p_customer_trx_id,
                               p_adjustment_id,
			       p_user_generated_flag);

       --
       -- Step 2: Credit unearned revenue or line transfer clearing account
       --
       IF p_credit_ccid IS NULL
       THEN
         --
         -- Initiate auto accounting procedure
         --
	 -- Bug 1930302 : Added warehouse_id as 16th parameter.

         ARP_AUTO_ACCOUNTING.do_autoaccounting('G'
                                              ,'UNEARN'
                                              ,p_customer_trx_id
                                              ,p_customer_trx_line_id
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,l_dist_tot
                                              ,NULL
                                              ,NULL
                                              ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                              ,c1.salesrep_id
                                              ,p_inventory_item_id
                                              ,p_memo_line_id
					      ,l_warehouse_id
                                              ,l_credit_ccid
                                              ,l_concat_segments
                                              ,l_fail_count);

         IF l_credit_ccid IS NULL
         THEN
            l_credit_ccid :=
                   FND_FLEX_EXT.GET_CCID ('SQLGL',
                                          'GL#',
                                          arp_global.chart_of_accounts_id,
                                          TO_CHAR(p_gl_date,'DD-MON-YYYY') ,
                                          l_concat_segments);
         END IF;

         IF l_credit_ccid = -1 OR
            l_credit_ccid = 0 OR
            l_fail_count > 0
         THEN
           RAISE invalid_ccid;
         END IF;
         l_revenue_type := 'UNEARN';

       ELSE -- i.e. transferring revenue between lines
         l_credit_ccid := p_credit_ccid;
         l_revenue_type := 'SUSPENSE';
       END IF;

       insert_distribution (   p_customer_trx_line_id,
                               l_credit_ccid,
                               l_dist_percent,
                               l_dist_acctd_amount,
                               p_gl_date,
                               p_gl_date,
                               l_revenue_type,
                               l_dist_amount,
                               l_cust_trx_line_salesrep_id,
                               p_customer_trx_id,
                               p_adjustment_id,
			       p_user_generated_flag);

     END LOOP;    -- sales credit loop

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.no_rule_debit_credit()-');
     END IF;

  EXCEPTION

     WHEN invalid_salesrep THEN
       FND_MESSAGE.SET_NAME(application => 'AR',
                            name => 'AR_RA_NO_REV_SALES_CREDIT');
       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_number);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN invalid_ccid THEN
       FND_MSG_PUB.Add;
       FND_MESSAGE.SET_NAME(application => 'AR',
                            name => 'AR_RA_INVALID_CODE_COMB');
       FND_MESSAGE.SET_TOKEN('CODE_COMBINATION',l_concat_segments);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS then
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
           ('20001 error at AR_Revenue_Adjustment_PVT.no_rule_debit_credit()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('no_rule_debit_credit: ' || 'Unexpected error '||sqlerrm||
                       ' at AR_Revenue_Adjustment_PVT.no_rule_debit_credit()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

  END no_rule_debit_credit;

/* 5021530 - this routine handles no-rules cases where no salesreps
    exist (new logic - does not require salesreps)

*/
  PROCEDURE no_rule_debit_credit_no_sr
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_credit_ccid           IN NUMBER
     ,p_inventory_item_id     IN NUMBER
     ,p_memo_line_id          IN NUMBER
     ,p_adjustment_id         IN NUMBER
     ,p_user_generated_flag   IN VARCHAR2)
  IS
     l_user_id                NUMBER := 0;
     l_last_salescredit_id    NUMBER := 0;
     l_cust_trx_line_salesrep_id NUMBER := 0;
     l_latest_percent_split   NUMBER := 0;
     l_debit_ccid             NUMBER := 0;
     l_credit_ccid            NUMBER := 0;
     l_dist_amount            NUMBER := 0;
     l_dist_acctd_amount      NUMBER := 0;
     l_dist_percent           NUMBER := 0;
     l_concat_segments        VARCHAR2(2000);
     l_new_concat_segments    VARCHAR2(2000);
     l_fail_count             NUMBER := 0;
     l_revenue_type           VARCHAR2(10);

     invalid_ccid             EXCEPTION;
     invalid_other            EXCEPTION;

     /* 5021530 - cursor based off non-rev_adj dists
        in REV account class

        Just check for ccid in returned row(s) and if null,
        call autoaccounting
     */
     /* 5644810 - Added NVL to sum(gl.amount), sum(gl.acctd_amount) and sum(gl.percent) in SELECT ststement */
     CURSOR c_dist IS
     SELECT l.customer_trx_line_id,
            l.line_number,
            l.extended_amount,
            l.warehouse_id,
            l.accounting_rule_duration,
            gl.code_combination_id,
            NVL(sum(gl.amount),0)       amount,
            NVL(sum(gl.acctd_amount),0) acctd_amount,
            NVL(sum(gl.percent),0)      percent
     FROM   ra_customer_trx_lines l,
            ra_cust_trx_line_gl_dist gl
     WHERE  l.customer_trx_line_id = p_customer_trx_line_id
     AND    l.customer_trx_id = p_customer_trx_id
     AND    l.line_type = 'LINE'
     AND    l.customer_trx_line_id = gl.customer_trx_line_id (+)
     AND    gl.account_class (+) = 'REV'
     AND    gl.revenue_adjustment_id (+) IS NULL
     GROUP BY l.customer_trx_line_id, l.line_number, l.extended_amount,
              l.warehouse_id, l.accounting_rule_duration,
              gl.code_combination_id;

   BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.no_rule_debit_credit_no_sr()+');
     END IF;
     FND_PROFILE.get('USER_ID',l_user_id);
     IF l_user_id IS NULL
     THEN
       l_user_id := 0;
     ELSE
       l_user_id := FND_GLOBAL.USER_ID;
     END IF;

     l_debit_ccid := -1;
     l_credit_ccid := -1;

     FOR gld in c_dist LOOP

       /* set amounts for adjustment */ /* bug 5644810 added IF condition */
       IF gld.code_combination_id IS NULL THEN
            l_dist_amount := arpcurr.currround(p_revenue_amount ,AR_RAAPI_UTIL.g_trx_currency);
       ELSE
            l_dist_amount := arpcurr.currround(p_revenue_amount * gld.percent / 100,
            AR_RAAPI_UTIL.g_trx_currency);
       END IF;

       IF gld.extended_amount = 0
       THEN
          l_dist_percent := 100;
       ELSE
          l_dist_percent := ROUND (((l_dist_amount / gld.extended_amount)
                 * 100), 4);
       END IF;

       l_dist_acctd_amount :=
    	      ARPCURR.functional_amount(
		  amount	=> l_dist_amount
                , currency_code	=> arp_global.functional_currency
                , exchange_rate	=> AR_RAAPI_UTIL.g_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
       --
       -- Step 1: Debit earned revenue
       --

       IF gld.code_combination_id IS NULL
       THEN
           /* No REV distributions to work from,
              call autoaccounting to get one  */
           ARP_AUTO_ACCOUNTING.do_autoaccounting('G'
                                            ,'REV'
                                             ,p_customer_trx_id
                                             ,p_customer_trx_line_id
                                             ,NULL
                                             ,NULL
                                             ,NULL
                                             ,NULL
                                             ,l_dist_amount
                                             ,NULL
                                             ,NULL
                                             ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                             ,NULL -- srep id
                                             ,p_inventory_item_id
                                             ,p_memo_line_id
					     ,gld.warehouse_id
                                             ,l_debit_ccid
                                             ,l_concat_segments
                                             ,l_fail_count);
          IF l_debit_ccid IS NULL
          THEN
             l_debit_ccid := FND_FLEX_EXT.GET_CCID
                                          ('SQLGL',
                                           'GL#',
                                           arp_global.chart_of_accounts_id,
                                           to_char(p_gl_date,'DD-MON-YYYY') ,
                                           l_concat_segments);
          END IF;

          IF l_debit_ccid = -1 OR
             l_debit_ccid = 0 OR
             l_fail_count > 0
          THEN
            RAISE invalid_ccid;
          END IF;

       ELSE
          /* We retrieved at least one REV account, use it */
          l_debit_ccid := gld.code_combination_id;
       END IF;

       insert_distribution (   p_customer_trx_line_id,
                               l_debit_ccid,
                               l_dist_percent,
                               l_dist_acctd_amount,
                               p_gl_date,
                               p_gl_date,
                               'REV',
                               l_dist_amount,
                               NULL,  -- srep dist id
                               p_customer_trx_id,
                               p_adjustment_id,
			       p_user_generated_flag);

       --
       -- Step 2: Credit unearned revenue or line transfer clearing account
       --
       /* 5021530 - always call autoaccounting for UNEARN as there
           is no guarantee that there will be a balance or that
           the percent will be useful.

           It is also very unusual to actually override UNEARN
           accounts manually. */
       IF p_credit_ccid IS NULL
       THEN
         --
         -- Initiate auto accounting procedure
         --
	 -- Bug 1930302 : Added warehouse_id as 16th parameter.

         ARP_AUTO_ACCOUNTING.do_autoaccounting('G'
                                              ,'UNEARN'
                                              ,p_customer_trx_id
                                              ,p_customer_trx_line_id
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,l_dist_amount
                                              ,NULL
                                              ,NULL
                                              ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                              ,NULL -- srep_Id
                                              ,p_inventory_item_id
                                              ,p_memo_line_id
					      ,gld.warehouse_id
                                              ,l_credit_ccid
                                              ,l_concat_segments
                                              ,l_fail_count);

         IF l_credit_ccid IS NULL
         THEN
            l_credit_ccid :=
                   FND_FLEX_EXT.GET_CCID ('SQLGL',
                                          'GL#',
                                          arp_global.chart_of_accounts_id,
                                          TO_CHAR(p_gl_date,'DD-MON-YYYY') ,
                                          l_concat_segments);
         END IF;

         IF l_credit_ccid = -1 OR
            l_credit_ccid = 0 OR
            l_fail_count > 0
         THEN
           RAISE invalid_ccid;
         END IF;
         l_revenue_type := 'UNEARN';

       ELSE -- i.e. transferring revenue between lines
         l_credit_ccid := p_credit_ccid;
         l_revenue_type := 'SUSPENSE';
       END IF;

       insert_distribution (   p_customer_trx_line_id,
                               l_credit_ccid,
                               l_dist_percent * -1,
                               l_dist_acctd_amount * -1,
                               p_gl_date,
                               p_gl_date,
                               l_revenue_type,
                               l_dist_amount * -1,
                               NULL, -- srep_dist_id
                               p_customer_trx_id,
                               p_adjustment_id,
			       p_user_generated_flag);


     END LOOP;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.no_rule_debit_credit_no_sr()-');
     END IF;

  EXCEPTION
     WHEN invalid_ccid THEN
       FND_MSG_PUB.Add;
       FND_MESSAGE.SET_NAME(application => 'AR',
                            name => 'AR_RA_INVALID_CODE_COMB');
       FND_MESSAGE.SET_TOKEN('CODE_COMBINATION',l_concat_segments);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS then
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
           ('20001 error at AR_Revenue_Adjustment_PVT.no_rule_debit_credit_no_sr()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('no_rule_debit_credit_no_sr: ' || 'Unexpected error '||sqlerrm||
                       ' at AR_Revenue_Adjustment_PVT.no_rule_debit_credit()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

  END no_rule_debit_credit_no_sr;


-----------------------------------------------------------------------
--	API name 	: Transfer_Revenue_Between_Lines
--	Type		: Private
--	Function	: Transfers a specified amount of revenue between
--                        specified transaction lines via a clearing account
--	Pre-reqs	: Sufficient earned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--				.
--				.
--	Version	: Current version	2.0
--				IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for revenue debits and credits
--

-----------------------------------------------------------------------
  PROCEDURE Transfer_Revenue_Between_Lines
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2
     ,p_commit	              IN   VARCHAR2
     ,p_validation_level      IN   NUMBER
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2)
  IS
    l_api_name			CONSTANT VARCHAR2(30)
                                    := 'Transfer_Revenue_Between_Lines';
    l_api_version           	CONSTANT NUMBER 	:= 2.0;
    l_rev_adj_rec               AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type;
    l_tax_rate_count                     NUMBER := 0;
    l_lines_from_total                   NUMBER := 0;
    l_line_from_count                    NUMBER := 0;
    l_no_of_lines_from                   NUMBER := 0;
    l_line_adjustable                    NUMBER;
    l_total_adjusted                     NUMBER := 0;
    l_line_id                            NUMBER;
    l_line_number                        NUMBER;
    l_line_salesrep_amount               NUMBER;
    l_line_rev_total                     NUMBER;
    l_adj_inv_total                      NUMBER;
    l_lines_to_total                     NUMBER := 0;
    l_line_to_count                      NUMBER := 0;
    l_no_of_lines_to                     NUMBER := 0;
    l_revenue_amount                     NUMBER := 0;
    l_revenue_amount_prorata             NUMBER := 0;
    l_credit_ccid                        NUMBER;

    l_warehouse_id              NUMBER; -- Bug 1930302.
    l_gl_date_valid             DATE;   -- 7314406

     invalid_tax              EXCEPTION;
     invalid_same_lines       EXCEPTION;
     invalid_lines            EXCEPTION;

     CURSOR c_lines_from_total IS
     SELECT NVL(SUM(d.amount),0)
     FROM   ra_cust_trx_line_gl_dist d
           ,mtl_item_categories mic
           ,ra_customer_trx_lines l
     WHERE  d.customer_trx_line_id = l.customer_trx_line_id
     AND    d.account_class = 'REV'
     AND    l.line_type = 'LINE'
     AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
     AND    d.account_class IN ('REV','UNEARN','UNBILL')
     AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,
                                         l.customer_trx_line_id)
     AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
     AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                 DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
     AND    DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,
              DECODE(AR_RAAPI_UTIL.g_from_inventory_item_id,NULL,
                DECODE(AR_RAAPI_UTIL.g_from_cust_trx_line_id,NULL,
                  NVL(l.accounting_rule_duration,0),0),0),0) <= 1;

     CURSOR c_lines_from IS
     SELECT l.line_number
           ,l.customer_trx_line_id
           ,l.memo_line_id
           ,l.inventory_item_id
           ,l.accounting_rule_id
           ,NVL(SUM(d.amount),0) amount
     FROM   ra_cust_trx_line_gl_dist d
           ,mtl_item_categories mic
           ,ra_customer_trx_lines l
     WHERE  d.customer_trx_line_id = l.customer_trx_line_id
     AND    d.account_class = 'REV'
     AND    l.line_type = 'LINE'
     AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
     AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,
                                         l.customer_trx_line_id)
     AND    NVL(l.inventory_item_id,0) =
          NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(l.inventory_item_id,0))
     AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
                 DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
     AND    DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,
              DECODE(AR_RAAPI_UTIL.g_from_inventory_item_id,NULL,
                DECODE(AR_RAAPI_UTIL.g_from_cust_trx_line_id,NULL,
                  NVL(l.accounting_rule_duration,0),0),0),0) <= 1
     GROUP BY l.line_number
             ,l.customer_trx_line_id
             ,l.memo_line_id
             ,l.inventory_item_id
             ,l.accounting_rule_id;

     CURSOR c_line_salesrep_amount IS
     SELECT SUM(NVL(revenue_amount_split,0))
     FROM   ra_cust_trx_line_salesreps
     WHERE  customer_trx_line_id = l_line_id
     AND    customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
     AND    salesrep_id = NVL(AR_RAAPI_UTIL.g_from_salesrep_id,salesrep_id)
     AND    NVL(revenue_salesgroup_id, -9999) = NVL(AR_RAAPI_UTIL.g_from_salesgroup_id,NVL(revenue_salesgroup_id, -9999));

     CURSOR c_tax_rate_count IS
       SELECT NVL(COUNT(DISTINCT tax.item_exception_rate_id||
              tax.tax_exemption_id|| tax.vat_tax_id||
              tax.sales_tax_id|| tax.tax_rate|| tax.tax_precedence),0)
       FROM   ra_customer_trx_lines line
             ,mtl_item_categories mic
             ,ra_customer_trx_lines tax
       WHERE  line.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
       AND    tax.line_type = 'TAX'
       AND    line.customer_trx_line_id = tax.link_to_cust_trx_line_id
       AND    line.customer_trx_line_id IN
         (NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id, line.customer_trx_line_id),
            NVL(AR_RAAPI_UTIL.g_to_cust_trx_line_id, line.customer_trx_line_id))
       AND    NVL(line.inventory_item_id,0) IN
     (NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,NVL(line.inventory_item_id,0)),
        NVL(AR_RAAPI_UTIL.g_to_inventory_item_id,NVL(line.inventory_item_id,0)))
       AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
       AND    line.inventory_item_id = mic.inventory_item_id(+)
       AND    (NVL(AR_RAAPI_UTIL.g_from_category_id,0) =
              DECODE(AR_RAAPI_UTIL.g_from_category_id,NULL,0,mic.category_id) OR
               NVL(AR_RAAPI_UTIL.g_to_category_id,0) =
               DECODE(AR_RAAPI_UTIL.g_to_category_id,NULL,0,mic.category_id))
       AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id;

     CURSOR c_lines_to_total IS
     SELECT NVL(SUM(d.amount),0) amount
     FROM   ra_cust_trx_line_gl_dist d
           ,mtl_item_categories mic
           ,ra_customer_trx_lines l
     WHERE  d.customer_trx_line_id = l.customer_trx_line_id
     AND    d.account_class = 'REV'
     AND    l.line_type = 'LINE'
     AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
     AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_to_cust_trx_line_id,
                                         l.customer_trx_line_id)
     AND    NVL(l.inventory_item_id,0) =
            NVL(AR_RAAPI_UTIL.g_to_inventory_item_id,NVL(l.inventory_item_id,0))
     AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(AR_RAAPI_UTIL.g_to_category_id,0) =
                 DECODE(AR_RAAPI_UTIL.g_to_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
     AND    DECODE(AR_RAAPI_UTIL.g_to_category_id,NULL,
              DECODE(AR_RAAPI_UTIL.g_to_inventory_item_id,NULL,
                DECODE(AR_RAAPI_UTIL.g_to_cust_trx_line_id,NULL,
                  NVL(l.accounting_rule_duration,0),2),2),2) > 1;

     CURSOR c_line_to_count IS
     SELECT COUNT(*)
     FROM   mtl_item_categories mic
           ,ra_customer_trx_lines l
     WHERE  l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
     AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_to_cust_trx_line_id,
                                         l.customer_trx_line_id)
     AND    NVL(l.inventory_item_id,0) =
            NVL(AR_RAAPI_UTIL.g_to_inventory_item_id,NVL(l.inventory_item_id,0))
     AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(AR_RAAPI_UTIL.g_to_category_id,0) =
                 DECODE(AR_RAAPI_UTIL.g_to_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
     AND    l.line_type = 'LINE'
     AND    DECODE(AR_RAAPI_UTIL.g_to_category_id,NULL,
              DECODE(AR_RAAPI_UTIL.g_to_inventory_item_id,NULL,
                DECODE(AR_RAAPI_UTIL.g_to_cust_trx_line_id,NULL,
                  NVL(l.accounting_rule_duration,0),2),2),2) > 1;

     CURSOR c_lines_to IS
     SELECT l.line_number
           ,l.customer_trx_line_id
           ,l.memo_line_id
           ,l.inventory_item_id
           ,l.accounting_rule_id
           ,l.accounting_rule_duration
           ,SUM(d.amount) amount
     FROM   ra_cust_trx_line_gl_dist d
           ,mtl_item_categories mic
           ,ra_customer_trx_lines l
     WHERE  d.customer_trx_line_id = l.customer_trx_line_id
     AND    d.account_class = 'REV'
     AND    l.line_type = 'LINE'
     AND    l.customer_trx_id = AR_RAAPI_UTIL.g_customer_trx_id
     AND    l.customer_trx_line_id = NVL(AR_RAAPI_UTIL.g_to_cust_trx_line_id,
                                         l.customer_trx_line_id)
     AND    NVL(l.inventory_item_id,0) =
            NVL(AR_RAAPI_UTIL.g_to_inventory_item_id,NVL(l.inventory_item_id,0))
     AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(AR_RAAPI_UTIL.g_to_category_id,0) =
                 DECODE(AR_RAAPI_UTIL.g_to_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
     AND    DECODE(AR_RAAPI_UTIL.g_to_category_id,NULL,
              DECODE(AR_RAAPI_UTIL.g_to_inventory_item_id,NULL,
                DECODE(AR_RAAPI_UTIL.g_to_cust_trx_line_id,NULL,
                  NVL(l.accounting_rule_duration,0),2),2),2) > 1
     GROUP BY l.line_number
             ,l.customer_trx_line_id
             ,l.memo_line_id
             ,l.inventory_item_id
             ,l.accounting_rule_id
             ,l.accounting_rule_duration;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Transfer_Revenue_Between_Lines()+');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT	Transfer_Rev_Between_Lines_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Transfer_Revenue_Between_Lines: ' || 'Unexpected error '||sqlerrm||
             ' at AR_Revenue_Adjustment_PVT.Transfer_Revenue_Between_Lines()+');
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

    BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.Transfer_Revenue_Between_Lines(2)+');
     END IF;

     l_rev_adj_rec := p_rev_adj_rec;

     /*Bug 6731185 JVARKEY Making sure GL date has no timestamp*/
     l_rev_adj_rec.gl_date := trunc(p_rev_adj_rec.gl_date);

     l_rev_adj_rec.adjustment_type := 'LL';

     AR_RAAPI_UTIL.Constant_System_Values;
     AR_RAAPI_UTIL.Initialize_Globals;
     AR_RAAPI_UTIL.Validate_Parameters (p_init_msg_list    => FND_API.G_FALSE
                                       ,p_rev_adj_rec      => l_rev_adj_rec
                                       ,p_validation_level => p_validation_level
                                       ,x_return_status    => x_return_status
                                       ,x_msg_count        => x_msg_count
                                       ,x_msg_data         => x_msg_data);
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF NVL(AR_RAAPI_UTIL.g_from_cust_trx_line_id,-100) =
                    NVL(AR_RAAPI_UTIL.g_to_cust_trx_line_id,-200)
     THEN
       FND_MESSAGE.SET_NAME (application => 'AR',
                                    name => 'AR_RA_SAME_FROM_AND_TO_LINES');
       RAISE invalid_same_lines;
     END IF;
     IF NVL(AR_RAAPI_UTIL.g_from_category_id,-100) =
                NVL(AR_RAAPI_UTIL.g_to_category_id,-200)
     THEN
       FND_MESSAGE.SET_NAME (application => 'AR',
                                    name => 'AR_RA_SAME_FROM_AND_TO_CATS');
       RAISE invalid_same_lines;
     END IF;
     IF NVL(AR_RAAPI_UTIL.g_from_inventory_item_id,-100) =
        NVL(AR_RAAPI_UTIL.g_to_inventory_item_id,-200)
     THEN
       FND_MESSAGE.SET_NAME (application => 'AR',
                                    name => 'AR_RA_SAME_FROM_AND_TO_ITEMS');
       RAISE invalid_same_lines;
     END IF;

     OPEN c_tax_rate_count;
     FETCH c_tax_rate_count INTO l_tax_rate_count;
     CLOSE c_tax_rate_count;

     IF l_tax_rate_count > 1
     THEN
       RAISE invalid_tax;
     END IF;

     OPEN c_lines_from_total;
     FETCH c_lines_from_total INTO l_lines_from_total;
     CLOSE c_lines_from_total;

     AR_RAAPI_UTIL.Validate_Amount
     (p_init_msg_list         => FND_API.G_FALSE
     ,p_customer_trx_line_id  => AR_RAAPI_UTIL.g_from_cust_trx_line_id
     ,p_adjustment_type       => 'LL'
     ,p_amount_mode           => p_rev_adj_rec.amount_mode
     ,p_customer_trx_id       => AR_RAAPI_UTIL.g_customer_trx_id
     ,p_salesrep_id           => AR_RAAPI_UTIL.g_from_salesrep_id
     ,p_salesgroup_id         => AR_RAAPI_UTIL.g_from_salesgroup_id
     ,p_sales_credit_type     => p_rev_adj_rec.sales_credit_type
     ,p_item_id               => AR_RAAPI_UTIL.g_from_inventory_item_id
     ,p_category_id           => AR_RAAPI_UTIL.g_from_category_id
     ,p_revenue_amount_in     => p_rev_adj_rec.amount
     ,p_revenue_percent       => p_rev_adj_rec.percent
     ,p_revenue_amount_out    => l_revenue_amount
     ,p_adjustable_amount_out => l_adj_inv_total
     ,p_line_count_out        => l_no_of_lines_from
     ,x_return_status         => x_return_status
     ,x_msg_count             => x_msg_count
     ,x_msg_data              => x_msg_data);
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR
     THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     l_rev_adj_rec.amount := l_revenue_amount;

     OPEN c_lines_to_total;
     FETCH c_lines_to_total INTO l_lines_to_total;
     CLOSE c_lines_to_total;

     OPEN c_line_to_count;
     FETCH c_line_to_count INTO l_no_of_lines_to;
     CLOSE c_line_to_count;

     IF (l_no_of_lines_from = 0 OR l_no_of_lines_to = 0) AND
         AR_RAAPI_UTIL.g_from_cust_trx_line_id IS NULL AND
         AR_RAAPI_UTIL.g_to_cust_trx_line_id IS NULL
     THEN
       RAISE invalid_lines;
     END IF;

     --
     -- Create revenue adjustment record
     --
     create_adjustment
     (p_rev_adj_rec           => l_rev_adj_rec
     ,x_adjustment_id         => x_adjustment_id
     ,x_adjustment_number     => x_adjustment_number);

       FOR c1 IN c_lines_from LOOP
         l_line_id := c1.customer_trx_line_id;
         OPEN c_line_salesrep_amount;
         FETCH c_line_salesrep_amount INTO l_line_salesrep_amount;
         CLOSE c_line_salesrep_amount;

         IF c1.amount > 0
         THEN
           l_line_adjustable := LEAST(c1.amount,l_line_salesrep_amount);
         ELSIF c1.amount < 0
         THEN
           l_line_adjustable := GREATEST(c1.amount,l_line_salesrep_amount);
         ELSE
           l_line_adjustable := 0;
         END IF;
         IF l_line_adjustable <> 0
         THEN
           l_revenue_amount_prorata := ROUND(l_revenue_amount *
             l_line_adjustable / l_adj_inv_total,AR_RAAPI_UTIL.g_trx_precision);
           l_line_from_count := l_line_from_count + 1;
           l_total_adjusted := l_total_adjusted + l_revenue_amount_prorata;

           IF l_line_from_count = l_no_of_lines_from AND
              l_total_adjusted <> l_revenue_amount
           THEN
              l_revenue_amount_prorata := l_revenue_amount_prorata +
                                          l_revenue_amount - l_total_adjusted;
           END IF;
           IF c1.accounting_rule_id IS NOT NULL
           THEN
             debit_credit   (c1.customer_trx_line_id
                            ,AR_RAAPI_UTIL.g_customer_trx_id
                            ,AR_RAAPI_UTIL.g_from_salesrep_id
                            ,l_revenue_amount_prorata
                            ,l_rev_adj_rec.gl_date -- 7314406 (raw gl_date)
                            ,arp_global.sysparam.rev_transfer_clear_ccid
                            ,c1.inventory_item_id
                            ,c1.memo_line_id
                            ,x_adjustment_id);
           ELSE

             /* 7314406 - need to bump/validate gl_date */
	     l_gl_date_valid := AR_RAAPI_UTIL.bump_gl_date_if_closed
	                        (p_gl_date   => l_rev_adj_rec.gl_date);

             no_rule_debit_credit      (c1.customer_trx_line_id
                                        ,AR_RAAPI_UTIL.g_customer_trx_id
                                        ,AR_RAAPI_UTIL.g_from_salesrep_id
                                        ,l_revenue_amount_prorata
                                        ,l_gl_date_valid -- 7314406
                                        ,arp_global.sysparam.rev_transfer_clear_ccid
                                        ,c1.inventory_item_id
                                        ,c1.memo_line_id
                                        ,x_adjustment_id);
           END IF;
         END IF;

       END LOOP;  -- c_lines_from loop

       l_total_adjusted := 0;

       FOR c1 IN c_lines_to LOOP
         IF l_lines_to_total = 0
         THEN
           l_revenue_amount_prorata :=
           ROUND(l_revenue_amount / l_no_of_lines_to,
                  AR_RAAPI_UTIL.g_trx_precision);
         ELSE
           l_revenue_amount_prorata := ROUND(l_revenue_amount * c1.amount /
                               l_lines_to_total, AR_RAAPI_UTIL.g_trx_precision);
         END IF;
         l_line_to_count := l_line_to_count + 1;
         l_total_adjusted := l_total_adjusted + l_revenue_amount_prorata;
         IF l_line_to_count = l_no_of_lines_to AND
            l_total_adjusted <> l_revenue_amount
         THEN
            l_revenue_amount_prorata := l_revenue_amount_prorata
                                        + l_revenue_amount - l_total_adjusted;
         END IF;

         IF c1.accounting_rule_id IS NOT NULL
         THEN
           IF NVL(c1.accounting_rule_duration,0) > 1
           THEN
             cr_target_line_unearned(c1.customer_trx_line_id
                                    ,AR_RAAPI_UTIL.g_customer_trx_id
                                    ,l_revenue_amount_prorata
                                    ,l_rev_adj_rec.gl_date
                                    ,c1.inventory_item_id
                                    ,c1.memo_line_id
                                    ,x_adjustment_id);
             l_credit_ccid := NULL;
           ELSE
             l_credit_ccid := arp_global.sysparam.rev_transfer_clear_ccid;
           END IF;

           debit_credit     (c1.customer_trx_line_id
                            ,AR_RAAPI_UTIL.g_customer_trx_id
                            ,NULL
                            ,l_revenue_amount_prorata * -1
                            ,l_rev_adj_rec.gl_date
                            ,l_credit_ccid
                            ,c1.inventory_item_id
                            ,c1.memo_line_id
                            ,x_adjustment_id);
         ELSE
             /* 7314406 - need to bump/validate gl_date */
	     l_gl_date_valid := AR_RAAPI_UTIL.bump_gl_date_if_closed
	                        (p_gl_date   => l_rev_adj_rec.gl_date);

             no_rule_debit_credit(c1.customer_trx_line_id
                                        ,AR_RAAPI_UTIL.g_customer_trx_id
                                        ,NULL
                                        ,l_revenue_amount_prorata * -1
                                        ,l_gl_date_valid -- 7314406
                                        ,arp_global.sysparam.rev_transfer_clear_ccid
                                        ,c1.inventory_item_id
                                        ,c1.memo_line_id
                                        ,x_adjustment_id);
         END IF;
         reset_dist_percent( c1.customer_trx_line_id);

       END LOOP;  -- c_lines_to loop

   EXCEPTION
     WHEN invalid_same_lines THEN
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN invalid_lines THEN
       FND_MESSAGE.SET_NAME (application => 'AR',
                                    name => 'AR_RA_NO_TSFR_LINES_AVAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN invalid_tax THEN
       FND_MESSAGE.SET_NAME (application => 'AR',
                                    name => 'AR_RA_TAX_TREATMENTS_VARY');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS then
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
  ('20001 error at AR_Revenue_Adjustment_PVT.Transfer_Revenue_Between_Lines()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Transfer_Revenue_Between_Lines: ' || 'Unexpected error '||sqlerrm||
             ' at AR_Revenue_Adjustment_PVT.Transfer_Revenue_Between_Lines()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
   END;
    --
    -- End of Inner Block
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
        	 p_data    => x_msg_data);
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.Transfer_Revenue_Between_Lines()-');
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Transfer_Rev_Between_Lines_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Transfer_Revenue_Between_Lines: ' || 'Unexpected error '||sqlerrm||
             ' at AR_Revenue_Adjustment_PVT.Transfer_Revenue_Between_Lines()+');
                END IF;
		ROLLBACK TO Transfer_Rev_Between_Lines_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Transfer_Revenue_Between_Lines: ' || '20001 error '||
             ' at AR_Revenue_Adjustment_PVT.Transfer_Revenue_Between_Lines()+');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Transfer_Revenue_Between_Lines: ' || 'Unexpected error '||sqlerrm||
             ' at AR_Revenue_Adjustment_PVT.Transfer_Revenue_Between_Lines()+');
                  END IF;
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		  IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		  END IF;
		END IF;
		ROLLBACK TO Transfer_Rev_Between_Lines_PVT;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);

  END Transfer_Revenue_Between_Lines;

  PROCEDURE reset_dist_percent
     (p_customer_trx_line_id IN NUMBER)
  IS
    l_no_of_lines         NUMBER;
    l_total               NUMBER;
    l_counter             NUMBER;
    l_percent             NUMBER;
    l_percent_total       NUMBER;

    CURSOR c_total IS
      SELECT NVL(SUM(amount),0)
      FROM   ra_cust_trx_line_gl_dist
      WHERE  customer_trx_line_id = p_customer_trx_line_id
      AND    account_set_flag = 'N'
      AND    account_class IN ('REV','UNEARN')
      AND    NVL(amount,0) <> 0;

    CURSOR c_count IS
      SELECT COUNT(*)
      FROM   ra_cust_trx_line_gl_dist
      WHERE  customer_trx_line_id = p_customer_trx_line_id
      AND    account_set_flag = 'N'
      AND    NVL(amount,0) <> 0;

    CURSOR c_dist_lines IS
      SELECT rowid, amount
      FROM   ra_cust_trx_line_gl_dist
      WHERE  customer_trx_line_id = p_customer_trx_line_id
      AND    account_set_flag = 'N'
      AND    NVL(amount,0) <> 0;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.reset_dist_percent()+');
    END IF;
    OPEN c_total;
    FETCH c_total into l_total;
    CLOSE c_total;
    OPEN c_count;
    FETCH c_count into l_no_of_lines;
    CLOSE c_count;
    l_counter := 0;
    l_percent_total := 0;
    FOR c1 IN c_dist_lines LOOP
      l_counter := l_counter + 1;
      IF l_counter = l_no_of_lines
      THEN
        l_percent := 100 - l_percent_total;
      ELSE
        l_percent := ROUND(c1.amount / l_total * 100,4);
        l_percent_total := l_percent_total + l_percent;
      END IF;
      UPDATE ra_cust_trx_line_gl_dist
      SET    percent = l_percent
      WHERE  rowid = c1.rowid;
    END LOOP;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.reset_dist_percent()-');
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
            ('20001 error at AR_Revenue_Adjustment_PVT.reset_dist_percent()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('reset_dist_percent: ' || 'Unexpected error '||sqlerrm||
                       ' at AR_Revenue_Adjustment_PVT.reset_dist_percent()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
  END reset_dist_percent;

  PROCEDURE create_adjustment
     (p_rev_adj_rec           IN Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY NUMBER
     ,x_adjustment_number     OUT NOCOPY VARCHAR2)
  IS
     l_adjustment_number      VARCHAR2(20);

     CURSOR c_adjustment_id IS
     SELECT ar_revenue_adjustments_s1.NEXTVAL
     FROM   dual;

     CURSOR c_adjustment_number IS
     SELECT ar_revenue_adjustments_s2.NEXTVAL
     FROM   dual;

  BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.create_adjustment()+');
     END IF;

     OPEN c_adjustment_id;
     FETCH c_adjustment_id INTO x_adjustment_id;
     CLOSE c_adjustment_id;

     OPEN c_adjustment_number;
     FETCH c_adjustment_number INTO x_adjustment_number;
     CLOSE c_adjustment_number;

     INSERT INTO ar_revenue_adjustments
                (revenue_adjustment_id
                ,revenue_adjustment_number
                ,customer_trx_id
                ,application_date
                ,from_salesrep_id
                ,to_salesrep_id
                ,from_salesgroup_id
                ,to_salesgroup_id
                ,type
                ,sales_credit_type
                ,amount_mode
                ,amount
                ,percent
                ,line_selection_mode
                ,from_category_id
                ,to_category_id
                ,from_inventory_item_id
                ,to_inventory_item_id
                ,from_cust_trx_line_id
                ,to_cust_trx_line_id
                ,gl_date
                ,reason_code
                ,comments
                ,attribute_category
                ,attribute1
                ,attribute2
                ,attribute3
                ,attribute4
                ,attribute5
                ,attribute6
                ,attribute7
                ,attribute8
                ,attribute9
                ,attribute10
                ,attribute11
                ,attribute12
                ,attribute13
                ,attribute14
                ,attribute15
                ,status
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
		,org_id ) -- Bug 4607673
     VALUES
                (x_adjustment_id
                ,x_adjustment_number
                ,AR_RAAPI_UTIL.g_customer_trx_id
                ,SYSDATE
                ,AR_RAAPI_UTIL.g_from_salesrep_id
                ,AR_RAAPI_UTIL.g_to_salesrep_id
                ,AR_RAAPI_UTIL.g_from_salesgroup_id
                ,AR_RAAPI_UTIL.g_to_salesgroup_id
                ,p_rev_adj_rec.adjustment_type
                ,p_rev_adj_rec.sales_credit_type
                ,p_rev_adj_rec.amount_mode
                ,p_rev_adj_rec.amount
                ,p_rev_adj_rec.percent
                ,p_rev_adj_rec.line_selection_mode
                ,AR_RAAPI_UTIL.g_from_category_id
                ,AR_RAAPI_UTIL.g_to_category_id
                ,AR_RAAPI_UTIL.g_from_inventory_item_id
                ,AR_RAAPI_UTIL.g_to_inventory_item_id
                ,AR_RAAPI_UTIL.g_from_cust_trx_line_id
                ,AR_RAAPI_UTIL.g_to_cust_trx_line_id
     /*Bug 6731185 JVARKEY Making sure GL date has no timestamp*/
                ,trunc(p_rev_adj_rec.gl_date)
                /*,p_rev_adj_rec.gl_date*/
                ,p_rev_adj_rec.reason_code
                ,p_rev_adj_rec.comments
                ,p_rev_adj_rec.attribute_category
                ,p_rev_adj_rec.attribute1
                ,p_rev_adj_rec.attribute2
                ,p_rev_adj_rec.attribute3
                ,p_rev_adj_rec.attribute4
                ,p_rev_adj_rec.attribute5
                ,p_rev_adj_rec.attribute6
                ,p_rev_adj_rec.attribute7
                ,p_rev_adj_rec.attribute8
                ,p_rev_adj_rec.attribute9
                ,p_rev_adj_rec.attribute10
                ,p_rev_adj_rec.attribute11
                ,p_rev_adj_rec.attribute12
                ,p_rev_adj_rec.attribute13
                ,p_rev_adj_rec.attribute14
                ,p_rev_adj_rec.attribute15
                ,'A'
                ,SYSDATE
                ,FND_GLOBAL.user_id
                ,SYSDATE
                ,FND_GLOBAL.user_id
		,arp_standard.sysparm.org_id ); -- Bug 4607673
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.create_adjustment()-');
     END IF;

  EXCEPTION
     WHEN OTHERS THEN
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
            ('20001 error at AR_Revenue_Adjustment_PVT.create_adjustment()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('create_adjustment: ' || 'Unexpected error '||sqlerrm||
                       ' at AR_Revenue_Adjustment_PVT.create_adjustment()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
  END create_adjustment;

  PROCEDURE cr_target_line_unearned
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_inventory_item_id     IN NUMBER
     ,p_memo_line_id          IN NUMBER
     ,p_adjustment_id         IN NUMBER)
  IS
     l_user_id                NUMBER := 0;
     l_debit_ccid             NUMBER := 0;
     l_credit_ccid            NUMBER := 0;
     l_dist_amount            NUMBER := 0;
     l_dist_acctd_amount      NUMBER := 0;
     l_dist_percent           NUMBER := 0;
     l_salesrep_count         NUMBER := 0;
     l_no_of_salesreps        NUMBER := 0;
     l_dist_tot               NUMBER := 0;
     l_concat_segments        VARCHAR2(2000);
     l_fail_count             NUMBER := 0;
     l_ext_amount	      NUMBER := 0;
     l_acc_rule_duration      NUMBER := 0;
     l_revenue_type           VARCHAR2(10);

     l_warehouse_id           NUMBER;

     invalid_ccid             EXCEPTION;

     CURSOR c_salesrep_count IS
     SELECT COUNT(*)
     FROM   ra_salesreps
     WHERE  salesrep_id IN
       (SELECT salesrep_id
        FROM   ra_cust_trx_line_salesreps
        WHERE  customer_trx_line_id = p_customer_trx_line_id
        AND    NVL(revenue_percent_split,0) <> 0
        GROUP  by salesrep_id
        HAVING SUM(NVL(revenue_percent_split,0)) <> 0);

     CURSOR c_line IS
     SELECT extended_amount, warehouse_id
     FROM   ra_customer_trx_lines
     WHERE  customer_trx_line_id = p_customer_trx_line_id;

     CURSOR c_salesrep IS
     SELECT salesrep_id,
            SUM(NVL(revenue_percent_split,0)) revenue_percent_split,
            MAX(cust_trx_line_salesrep_id) max_id
     FROM   ra_cust_trx_line_salesreps
     WHERE  customer_trx_line_id = p_customer_trx_line_id
     AND    NVL(revenue_percent_split,0) <> 0
     GROUP  by salesrep_id
     HAVING SUM(NVL(revenue_percent_split,0)) <> 0;

   BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.cr_target_line_unearned()+');
     END IF;
     FND_PROFILE.get('USER_ID',l_user_id);
     IF l_user_id IS NULL
     THEN
       l_user_id := 0;
     ELSE
       l_user_id := FND_GLOBAL.USER_ID;
     END IF;

     l_debit_ccid := -1;
     l_credit_ccid := -1;
     l_dist_tot := 0;
     l_salesrep_count := 0;

     OPEN c_salesrep_count;
     FETCH c_salesrep_count INTO l_no_of_salesreps;
     CLOSE c_salesrep_count;

     OPEN c_line;
     FETCH c_line INTO l_ext_amount, l_warehouse_id;
     CLOSE c_line;

     FOR c1 in c_salesrep LOOP

       l_dist_amount := arpcurr.currround(p_revenue_amount * c1.revenue_percent_split / 100 , AR_RAAPI_UTIL.g_trx_currency);
       l_dist_tot := l_dist_tot + l_dist_amount;
       l_salesrep_count := l_salesrep_count + 1;
       IF l_salesrep_count = l_no_of_salesreps AND
          l_dist_tot <> p_revenue_amount
       THEN
         l_dist_amount := l_dist_amount + (p_revenue_amount - l_dist_tot);
       END IF;
       IF l_ext_amount = 0
       THEN
         l_dist_percent := ROUND ((100 / l_no_of_salesreps), 4);
       ELSE
         l_dist_percent := ROUND (((l_dist_amount / l_ext_amount) * 100), 4);
       END IF;
       IF ((l_dist_percent > -0.01 AND l_dist_percent < 0.01) OR
            l_dist_percent > 999 OR
            l_dist_percent < -999)
       THEN
         l_dist_percent := ROUND ((100 / l_no_of_salesreps), 4)
                                        * SIGN(l_dist_percent);
       END IF;
       l_dist_acctd_amount :=
    	      ARPCURR.functional_amount(
		  amount	=> l_dist_amount
                , currency_code	=> arp_global.functional_currency
                , exchange_rate	=> AR_RAAPI_UTIL.g_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
       --
       -- Initiate auto accounting procedure
       --
       -- Bug 1930302 : Added warehouse_id as 16th parameter.

       ARP_AUTO_ACCOUNTING.do_autoaccounting('G'
                                            ,'UNEARN'
                                            ,p_customer_trx_id
                                            ,p_customer_trx_line_id
                                            ,NULL
                                            ,NULL
                                            ,NULL
                                            ,NULL
                                            ,l_dist_tot
                                            ,NULL
                                            ,NULL
                                            ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                            ,c1.salesrep_id
                                            ,p_inventory_item_id
                                            ,p_memo_line_id
					    ,l_warehouse_id
                                            ,l_credit_ccid
                                            ,l_concat_segments
                                            ,l_fail_count);

       IF l_credit_ccid IS NULL
       THEN
          l_credit_ccid := FND_FLEX_EXT.GET_CCID
                                          ('SQLGL',
                                           'GL#',
                                           arp_global.chart_of_accounts_id,
                                           TO_CHAR(p_gl_date,'DD-MON-YYYY'),
                                           l_concat_segments);
       END IF;

       IF l_credit_ccid = -1 OR
          l_credit_ccid = 0 OR
          l_fail_count > 0
       THEN
         RAISE invalid_ccid;
       END IF;

       insert_distribution (   p_customer_trx_line_id,
                               l_credit_ccid,
                               l_dist_percent,
                               l_dist_acctd_amount,
                               p_gl_date,
                               p_gl_date,
                               'UNEARN',
                               l_dist_amount,
                               NULL,
                               p_customer_trx_id,
                               p_adjustment_id);

       l_debit_ccid := arp_global.sysparam.rev_transfer_clear_ccid;

       insert_distribution (   p_customer_trx_line_id,
                               l_debit_ccid,
                               l_dist_percent * -1,
                               l_dist_acctd_amount * -1,
                               p_gl_date,
                               p_gl_date,
                               'SUSPENSE',
                               l_dist_amount * -1,
                               NULL,
                               p_customer_trx_id,
                               p_adjustment_id);

     END LOOP;    -- sales credit loop
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.cr_target_line_unearned()-');
     END IF;

   EXCEPTION

     WHEN invalid_ccid THEN
       FND_MSG_PUB.Add;
       FND_MESSAGE.SET_NAME(application => 'AR',
                            name => 'AR_RA_INVALID_CODE_COMB');
       FND_MESSAGE.SET_TOKEN('CODE_COMBINATION',l_concat_segments);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
         ('20001 error at AR_Revenue_Adjustment_PVT.cr_target_line_unearned()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('cr_target_line_unearned: ' || 'Unexpected error '||sqlerrm||
                    ' at AR_Revenue_Adjustment_PVT.cr_target_line_unearned()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

   END cr_target_line_unearned;

   PROCEDURE insert_distribution(p_customer_trx_line_id      IN NUMBER,
                                 p_ccid                      IN NUMBER,
                                 p_percent                   IN NUMBER,
                                 p_acctd_amount              IN NUMBER,
                                 p_gl_date                   IN DATE,
                                 p_orig_gl_date              IN DATE,
                                 p_account_class             IN VARCHAR2,
                                 p_amount                    IN NUMBER,
                                 p_cust_trx_line_salesrep_id IN NUMBER,
                                 p_customer_trx_id           IN NUMBER,
                                 p_adjustment_id             IN NUMBER,
				 p_user_generated_flag       IN VARCHAR2,
                                 p_rounding_flag             IN VARCHAR2
                                                             DEFAULT NULL)
  IS

   l_dist_id                    NUMBER;
   l_user_id                    NUMBER;

CURSOR cu_trx IS
SELECT customer_trx_id
FROM ra_customer_trx_lines
WHERE customer_trx_line_id = p_customer_trx_line_id;

l_trx_id        NUMBER;
l_xla_event      arp_xla_events.xla_events_type;

  BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.insert_distribution()+');
        arp_util.debug('  p_customer_trx_line_id = ' || p_customer_trx_line_id);
        arp_util.debug('  p_amount = ' || p_amount);
        arp_util.debug('  p_acctd_amount = ' || p_acctd_amount);
        arp_util.debug('  p_cust_trx_line_salesrep_id = ' || p_cust_trx_line_salesrep_id);
        arp_util.debug('  p_adjustment_id = ' || p_adjustment_id);
        arp_util.debug('  g_update_db_flag = ' || g_update_db_flag);
        arp_util.debug('  p_rounding_flag = ' || p_rounding_flag);
     END IF;

       FND_PROFILE.get('USER_ID',l_user_id);
       IF l_user_id IS NULL
       THEN
         l_user_id := 0;
       ELSE
         l_user_id := FND_GLOBAL.USER_ID;
       END IF;

       IF g_update_db_flag = 'Y'
       THEN
         SELECT ra_cust_trx_line_gl_dist_s.NEXTVAL
         INTO   l_dist_id
         FROM   dual;

         INSERT INTO ra_cust_trx_line_gl_dist
                 (cust_trx_line_gl_dist_id
                 ,customer_trx_line_id
                 ,code_combination_id
                 ,set_of_books_id
                 ,last_update_date
                 ,last_updated_by
                 ,creation_date
                 ,created_by
                 ,percent
                 ,amount
                 ,gl_date
                 ,original_gl_date
                 ,cust_trx_line_salesrep_id
                 ,account_class
                 ,customer_trx_id
                 ,account_set_flag
                 ,acctd_amount
                 ,posting_control_id
                 ,revenue_adjustment_id
                 ,user_generated_flag
                 ,org_id  -- Bug 4607673
                 ,rounding_correction_flag
                 ) VALUES
                 (l_dist_id
                  ,p_customer_trx_line_id
                  ,p_ccid
                  ,arp_global.sysparam.set_of_books_id
                  ,SYSDATE
                  ,l_user_id
                  ,SYSDATE
                  ,l_user_id
                  ,p_percent
                  ,p_amount
              /*Bug 6731185 JVARKEY Making sure GL date has no timestamp*/
                  ,trunc(p_gl_date)
                  /*,p_gl_date*/
                  ,p_orig_gl_date
                  ,p_cust_trx_line_salesrep_id
                  ,p_account_class
                  ,p_customer_trx_id
                  ,'N'
                  ,p_acctd_amount
                  ,-3
                  ,p_adjustment_id
                  ,p_user_generated_flag
		  ,arp_standard.sysparm.org_id
                  ,p_rounding_flag);  -- Bug 4607673

--{BUG#5064609 call XLA event
OPEN cu_trx;
FETCH cu_trx INTO l_trx_id;
IF cu_trx%FOUND THEN
    l_xla_event.xla_from_doc_id  := l_trx_id;
    l_xla_event.xla_to_doc_id    := l_trx_id;
    l_xla_event.xla_req_id       := NULL;
    l_xla_event.xla_dist_id      := NULL;
    l_xla_event.xla_doc_table    := 'CT';
    l_xla_event.xla_doc_event    := NULL;
    l_xla_event.xla_mode         := 'O';
    l_xla_event.xla_call         := 'B';

    ARP_XLA_EVENTS.CREATE_EVENTS(p_xla_ev_rec => l_xla_event );
END IF;
CLOSE cu_trx;
--}

       ELSE
         g_dist_count := g_dist_count + 1;
         g_ra_dist_tbl(g_dist_count).customer_trx_line_id := p_customer_trx_line_id;
         g_ra_dist_tbl(g_dist_count).code_combination_id := p_ccid;
         g_ra_dist_tbl(g_dist_count).set_of_books_id := arp_global.sysparam.set_of_books_id;
         g_ra_dist_tbl(g_dist_count).last_update_date := SYSDATE;
         g_ra_dist_tbl(g_dist_count).last_updated_by := l_user_id;
         g_ra_dist_tbl(g_dist_count).creation_date := SYSDATE;
         g_ra_dist_tbl(g_dist_count).created_by := l_user_id;
         g_ra_dist_tbl(g_dist_count).percent := p_percent;
         g_ra_dist_tbl(g_dist_count).amount := p_amount;
         /*Bug 6731185 JVARKEY Making sure GL date has no timestamp*/
         g_ra_dist_tbl(g_dist_count).gl_date := trunc(p_gl_date);
         /*g_ra_dist_tbl(g_dist_count).gl_date := p_gl_date;*/
         g_ra_dist_tbl(g_dist_count).cust_trx_line_salesrep_id := p_cust_trx_line_salesrep_id;
         g_ra_dist_tbl(g_dist_count).account_class := p_account_class;
         g_ra_dist_tbl(g_dist_count).customer_trx_id := p_customer_trx_id;
         g_ra_dist_tbl(g_dist_count).account_set_flag := 'N';
         g_ra_dist_tbl(g_dist_count).acctd_amount := p_acctd_amount;
         g_ra_dist_tbl(g_dist_count).posting_control_id := -3;
       END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.insert_distribution()-');
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
         ('20001 error at AR_Revenue_Adjustment_PVT.insert_distribution()');
         END IF;
         RAISE;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('insert_distribution: ' || 'Unexpected error '||sqlerrm||
                        ' at AR_Revenue_Adjustment_PVT.insert_distribution()+');
         END IF;
         RAISE;
       END IF;
  END insert_distribution;

  /* 6615118 - insert model distributions if the srep is revenue
      and the transaction has rules */

  PROCEDURE insert_sales_credit (p_customer_trx_id   IN NUMBER,
                                  p_salesrep_id       IN NUMBER,
                                  p_salesgroup_id     IN NUMBER,
                                  p_cust_trx_line_id  IN NUMBER,
                                  p_amount            IN NUMBER,
                                  p_percent           IN NUMBER,
                                  p_type              IN VARCHAR2,
                                  p_sales_credit_id   IN OUT NOCOPY NUMBER,
                                  p_adjustment_id     IN NUMBER,
                                  p_gl_date           IN DATE)
  IS

   CURSOR get_salesrep_line_id IS
   SELECT ra_cust_trx_line_salesreps_s.NEXTVAL
   FROM   dual;

   CURSOR get_gldist_line_id IS
   SELECT ra_cust_trx_line_gl_dist_s.NEXTVAL
   FROM   dual;

   l_user_id         NUMBER;
   l_account_class   ra_cust_trx_line_gl_dist_all.account_class%TYPE;
   l_gl_dist_id      ra_cust_trx_line_gl_dist_all.cust_trx_line_gl_dist_id%TYPE;
   l_ccid            ra_cust_trx_line_gl_dist_all.code_combination_id%TYPE;
   l_concat_segments VARCHAR2(2000);
   l_fail_count	     NUMBER := 0;

   invalid_ccid                 EXCEPTION;

  BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.insert_sales_credit()+');
        arp_util.debug('  p_customer_trx_id = ' || p_customer_trx_id);
        arp_util.debug('  p_cust_trx_line_id = ' || p_cust_trx_line_id);
        arp_util.debug('  p_salesrep_id = ' || p_salesrep_id);
        arp_util.debug('  p_salesgroup_id = ' || p_salesgroup_id);
        arp_util.debug('  p_type = ' || p_type);
        arp_util.debug('  p_amount = ' || p_amount);
        arp_util.debug('  p_percent = ' || p_percent);
     END IF;
     OPEN get_salesrep_line_id;
     FETCH get_salesrep_line_id INTO p_sales_credit_id;
     CLOSE get_salesrep_line_id;

     FND_PROFILE.get('USER_ID',l_user_id);
     IF l_user_id IS NULL
     THEN
       l_user_id := 0;
     ELSE
       l_user_id := FND_GLOBAL.USER_ID;
     END IF;

     INSERT INTO ra_cust_trx_line_salesreps
		   		  (cust_trx_line_salesrep_id
				  ,last_update_date
				  ,last_updated_by
				  ,creation_date
				  ,created_by
				  ,customer_trx_id
				  ,salesrep_id
				  ,revenue_salesgroup_id
				  ,non_revenue_salesgroup_id
				  ,customer_trx_line_id
				  ,revenue_amount_split
				  ,non_revenue_amount_split
				  ,revenue_percent_split
				  ,non_revenue_percent_split
                                  ,revenue_adjustment_id
				  ,org_id)
          VALUES                  (p_sales_credit_id
		   		  ,SYSDATE
				  ,l_user_id
				  ,SYSDATE
				  ,l_user_id
				  ,p_customer_trx_id
				  ,p_salesrep_id
				  ,DECODE(p_type,'R',p_salesgroup_id,NULL)
				  ,DECODE(p_type,'N',p_salesgroup_id,NULL)
				  ,p_cust_trx_line_id
				  ,DECODE(p_type,'R',p_amount,NULL)
				  ,DECODE(p_type,'N',p_amount,NULL)
				  ,DECODE(p_type,'R',p_percent,NULL)
				  ,DECODE(p_type,'N',p_percent,NULL)
                                  ,p_adjustment_id
				  ,arp_standard.sysparm.org_id);

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('  Inserted salescredit row w/ ID = ' ||
            p_sales_credit_id);
     END IF;

     /* 6615118 - create model distribution if srep is revenue type
          and transaction has rules */
     IF p_type = 'R' AND
        AR_RAAPI_UTIL.g_invoicing_rule_id IS NOT NULL
     THEN
         /* fetch these values for autoaccounting */

       IF NVL(g_line_id, -99) = p_cust_trx_line_id
       THEN
          /* already fetched these values, no nothing */
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('  cached values = ' || g_inventory_item_id ||
                     ':' || g_memo_line_id || ':' || g_warehouse_id);
          END IF;
       ELSE
         /* fetch warehouse, etc for this line */
         SELECT inventory_item_id, memo_line_id, warehouse_id
         INTO   g_inventory_item_id, g_memo_line_id, g_warehouse_id
         FROM   RA_CUSTOMER_TRX_LINES
         WHERE  customer_trx_line_id = p_cust_trx_line_id;

         g_line_id := p_cust_trx_line_id;

         IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('  retrieved values = ' || g_inventory_item_id ||
                    ':' || g_memo_line_id || ':' || g_warehouse_id);
         END IF;
       END IF;

       /* 6615118 - using a loop to run through this
            process twice.. once for REV and second for UNEARN */
       FOR i IN 1..2 LOOP
         IF i = 1
         THEN
           l_account_class := 'REV';
         ELSE
           l_account_class := 'UNEARN';
         END IF;

         ARP_AUTO_ACCOUNTING.do_autoaccounting('G'
                                              ,l_account_class
                                              ,p_customer_trx_id
                                              ,p_cust_trx_line_id
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,p_amount
                                              ,NULL
                                              ,NULL
                                              ,AR_RAAPI_UTIL.g_cust_trx_type_id
                                              ,p_salesrep_id
                                              ,g_inventory_item_id
                                              ,g_memo_line_id
					      ,g_warehouse_id
                                              ,l_ccid
                                              ,l_concat_segments
                                              ,l_fail_count);
         IF l_ccid IS NULL
         THEN
            l_ccid := FND_FLEX_EXT.GET_CCID
                                 ('SQLGL'
                                 ,'GL#'
                                 ,arp_global.chart_of_accounts_id
                                 ,TO_CHAR(p_gl_date,'DD-MON-YYYY')
                                 ,l_concat_segments);
         END IF;

         IF l_ccid = -1 OR
            l_ccid = 0 OR
            l_fail_count > 0
         THEN
           RAISE invalid_ccid;
         END IF;

        OPEN get_gldist_line_id;
        FETCH get_gldist_line_id INTO l_gl_dist_id;
        CLOSE get_gldist_line_id;

        INSERT INTO ra_cust_trx_line_gl_dist
          (
            customer_trx_line_id,
            customer_trx_id,
            code_combination_id,
            set_of_books_id,
            account_class,
            account_set_flag,
            percent,
            amount,
            acctd_amount,
            gl_date,
            cust_trx_line_salesrep_id,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            posting_control_id,
            original_gl_date,
            cust_trx_line_gl_dist_id,
            revenue_adjustment_id,
            user_generated_flag,
            org_id
          )
        VALUES
          ( p_cust_trx_line_id,
            p_customer_trx_id,
            l_ccid,
            arp_standard.sysparm.set_of_books_id,
            l_account_class,
            'Y',
            p_percent,
            NULL,
            NULL,
            NULL,
            p_sales_credit_id,
            arp_standard.profile.request_id,
            arp_standard.application_id,
            arp_standard.profile.program_id,
            sysdate,
            sysdate,
            l_user_id,
            sysdate,
            l_user_id,
            -3,
            NULL,
            l_gl_dist_id,
            p_adjustment_id,
            'Y',
            arp_standard.sysparm.org_id
           );

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('  Inserted ' || l_account_class ||
                     ' model dist with gl_dist_id = ' || l_gl_dist_id ||
                     ' ccid = ' || l_ccid);
         END IF;
       END LOOP;
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_Revenue_Adjustment_PVT.insert_sales_credit()-');
     END IF;

  EXCEPTION
     WHEN invalid_ccid THEN
       FND_MSG_PUB.Add;
       FND_MESSAGE.SET_NAME(application => 'AR',
                            name => 'AR_RA_INVALID_CODE_COMB');
       FND_MESSAGE.SET_TOKEN('CODE_COMBINATION',l_concat_segments);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
         ('20001 error at AR_Revenue_Adjustment_PVT.insert_sales_credit()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('insert_sales_credit: ' || 'Unexpected error '||sqlerrm||
                        ' at AR_Revenue_Adjustment_PVT.insert_sales_credit()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

  END insert_sales_credit;

  FUNCTION category_set_id
  RETURN VARCHAR2 IS
  BEGIN
    RETURN AR_RAAPI_UTIL.g_category_set_id;
  END category_set_id;

  FUNCTION inv_org_id
  RETURN VARCHAR2 IS
  BEGIN
    RETURN AR_RAAPI_UTIL.g_inv_org_id;
  END inv_org_id;

-----------------------------------------------------------------------
--	API name 	: Record_Acceptance
--	Type		: Private
--	Function	: Calls collectibility engine to determine if revenue
--                        is to be scheduled/unscheduled for each line.
--	Pre-reqs	:
--	Parameters	:
--	IN		:
--	OUT NOCOPY		:
--
--
--	Notes		:
  PROCEDURE Record_Acceptance
        (p_customer_trx_id      IN  ra_customer_trx.customer_trx_id%TYPE,
         p_category_id          IN  mtl_categories.category_id%TYPE,
         p_inventory_item_id    IN  mtl_system_items.inventory_item_id%TYPE,
         p_customer_trx_line_id IN  ra_customer_trx_lines.customer_trx_line_id%TYPE,
         p_gl_date              IN  ra_cust_trx_line_gl_dist.gl_date%TYPE,
         p_comments             IN  ar_revenue_adjustments.comments%TYPE,
         p_ram_desc_flexfield   IN  ar_revenue_management_pvt.desc_flexfield,
         x_scenario             OUT NOCOPY NUMBER,
         x_first_rev_adj_id     OUT NOCOPY ar_revenue_adjustments.revenue_adjustment_id%TYPE,
         x_last_rev_adj_id      OUT NOCOPY ar_revenue_adjustments.revenue_adjustment_id%TYPE,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2)
  IS
    l_scenario                NUMBER;
    l_first_adj_num           NUMBER;
    l_last_adj_num            NUMBER;
    l_real_last_adj_num       NUMBER;
    l_not_recognized_flag     VARCHAR2(1) := 'N';
    l_partially_recognized_flag VARCHAR2(1) := 'N';
    l_fully_recognized_flag   VARCHAR2(1) := 'N';

    CURSOR c_line IS
     SELECT l.customer_trx_line_id
     FROM   mtl_item_categories mic
           ,ra_rules r
           ,ra_customer_trx_lines l
     WHERE  l.customer_trx_id = p_customer_trx_id
     AND    l.accounting_rule_id = r.rule_id(+)
     AND    NVL(l.inventory_item_id,0) =
            NVL(p_inventory_item_id,NVL(l.inventory_item_id,0))
     AND    mic.organization_id(+) = AR_RAAPI_UTIL.g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(p_category_id,0) =
                 DECODE(p_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = AR_RAAPI_UTIL.g_category_set_id
     AND    l.line_type = 'LINE'
     AND    NVL(r.deferred_revenue_flag,'N') <> 'Y';

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_Revenue_Adjustment_PVT.record_acceptance()+');
    END IF;
    AR_RAAPI_UTIL.Constant_System_Values;
    AR_RAAPI_UTIL.Initialize_Globals;
    x_first_rev_adj_id := NULL;
    x_last_rev_adj_id := NULL;
    l_first_adj_num := NULL;
    l_last_adj_num := NULL;
    l_real_last_adj_num := NULL;
    IF (p_category_id IS NOT NULL or p_inventory_item_id IS NOT NULL)
    THEN
      FOR c1 IN c_line LOOP
        ar_revenue_management_pvt.revenue_synchronizer(
           p_mode => ar_revenue_management_pvt.c_acceptance_obtained_mode,
           p_customer_trx_id   	       =>  p_customer_trx_id,
           p_customer_trx_line_id      =>  c1.customer_trx_line_id,
           p_gl_date                   =>  p_gl_date,
           p_comments                  =>  p_comments,
           p_ram_desc_flexfield        =>  p_ram_desc_flexfield,
           x_scenario 		       =>  l_scenario,
           x_first_adjustment_number   =>  l_first_adj_num,
           x_last_adjustment_number    =>  l_last_adj_num,
           x_return_status             =>  x_return_status,
           x_msg_count                 =>  x_msg_count,
           x_msg_data                  =>  x_msg_data);
        IF l_scenario = ar_revenue_management_pvt.c_not_recognized
        THEN
          l_not_recognized_flag := 'Y';
        ELSIF l_scenario = ar_revenue_management_pvt.c_partially_recognized
        THEN
          l_partially_recognized_flag := 'Y';
        ELSIF l_scenario = ar_revenue_management_pvt.c_fully_recognized
        THEN
          l_fully_recognized_flag := 'Y';
        END IF;
        IF (x_first_rev_adj_id IS NULL AND l_first_adj_num IS NOT NULL)
        THEN
          select revenue_adjustment_id into x_first_rev_adj_id
          FROM ar_revenue_adjustments
          WHERE revenue_adjustment_number = l_first_adj_num;
        END IF;
        IF l_last_adj_num IS NOT NULL
        THEN
           l_real_last_adj_num := l_last_adj_num;
        END IF;
      END LOOP;
      IF (l_not_recognized_flag = 'Y' AND
          l_partially_recognized_flag = 'N' AND
          l_fully_recognized_flag = 'N')
      THEN
          x_scenario := 0;
      ELSIF (l_not_recognized_flag = 'N' AND
          l_partially_recognized_flag = 'N' AND
          l_fully_recognized_flag = 'Y')
      THEN
          x_scenario := 2;
      ELSE
        x_scenario := 1;
      END IF;
      IF l_real_last_adj_num IS NOT NULL
      THEN
        select revenue_adjustment_id into x_last_rev_adj_id
        FROM ar_revenue_adjustments
        WHERE revenue_adjustment_number = l_real_last_adj_num;
      ELSE
        x_last_rev_adj_id := x_first_rev_adj_id;
      END IF;
    ELSE
      ar_revenue_management_pvt.revenue_synchronizer(
         p_mode => ar_revenue_management_pvt.c_acceptance_obtained_mode,
         p_customer_trx_id   	     =>  p_customer_trx_id,
         p_customer_trx_line_id      =>  p_customer_trx_line_id,
         p_gl_date                   =>  p_gl_date,
         p_comments                  =>  p_comments,
         p_ram_desc_flexfield        =>  p_ram_desc_flexfield,
         x_scenario 		     =>  l_scenario,
         x_first_adjustment_number   =>  l_first_adj_num,
         x_last_adjustment_number    =>  l_last_adj_num,
         x_return_status             =>  x_return_status,
         x_msg_count                 =>  x_msg_count,
         x_msg_data                  =>  x_msg_data);

      IF l_scenario = ar_revenue_management_pvt.c_not_recognized
      THEN
        x_scenario := 0;
      ELSIF l_scenario = ar_revenue_management_pvt.c_partially_recognized
      THEN
        x_scenario := 1;
      ELSIF l_scenario = ar_revenue_management_pvt.c_fully_recognized
      THEN
        x_scenario := 2;
      END IF;

      IF l_first_adj_num IS NOT NULL
      THEN
        select revenue_adjustment_id into x_first_rev_adj_id
        FROM ar_revenue_adjustments
        WHERE revenue_adjustment_number = l_first_adj_num;
      END IF;
    END IF;
    IF l_last_adj_num IS NOT NULL
    THEN
      select revenue_adjustment_id into x_last_rev_adj_id
      FROM ar_revenue_adjustments
      WHERE revenue_adjustment_number = l_last_adj_num;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Record_Acceptance: ' || 'l_first_adj_num = '||l_first_adj_num);
       arp_util.debug('Record_Acceptance: ' || 'l_last_adj_num = '||l_last_adj_num);
       arp_util.debug('Record_Acceptance: ' || 'x_first_rev_adj_id = '||x_first_rev_adj_id);
       arp_util.debug('Record_Acceptance: ' || 'x_last_rev_adj_id = '||x_last_rev_adj_id);
       arp_util.debug('AR_Revenue_Adjustment_PVT.record_acceptance()-');
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
       IF (SQLCODE = -20001)
       THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug
         ('20001 error at AR_Revenue_Adjustment_PVT.record_acceptance()');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Record_Acceptance: ' || 'Unexpected error '||sqlerrm||
                        ' at AR_Revenue_Adjustment_PVT.record_acceptance()+');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
  END Record_Acceptance;

/* Initialization section */
BEGIN
    /* Bug 2650708: check if revenue management is installed */
    IF ar_revenue_management_pvt.revenue_management_enabled
    THEN
      g_rev_mgt_installed := 'Y';
    ELSE
      g_rev_mgt_installed := 'N';
    END IF;

END AR_Revenue_Adjustment_PVT;

/
