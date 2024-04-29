--------------------------------------------------------
--  DDL for Package Body OZF_QUOTA_ALLOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_QUOTA_ALLOCATIONS_PVT" AS
/* $Header: ozfvqalb.pls 115.15 2004/06/11 19:55:29 kvattiku noship $*/
   g_pkg_name     CONSTANT VARCHAR2(30) := 'OZF_Quota_allocations_Pvt';

---------------------------------------------------------------------
-- FUNCTION
---   is_root_or_leaf
--
-- PURPOSE
--    This function returns is the quota a leaf/Root quota or otherwise.
--    used to render link to Account allocation page
--
-- HISTORY
--	Tue Dec 02 2003:4/56 PM    RSSHARMA  Created.
--	Tue Dec 16 2003:8/36 PM RSSHARMA Changed function is_root_or_leaf and now the functionality is_leaf only

-- PARAMETERS
--      p_quota_id NUMBER
---------------------------------------------------------------------
FUNCTION is_root_or_leaf(p_quota_id IN NUMBER)
RETURN VARCHAR2
IS

CURSOR c_leaf(p_quota_id NUMBER) IS
SELECT 'Y' from dual
WHERE exists(SELECT 1 FROM ozf_funds_all_b WHERE parent_fund_id IS NOT NULL AND fund_id = p_quota_id)
AND NOT EXISTS(select 1 FROM ozf_funds_all_b WHERE parent_fund_id = p_quota_id);

CURSOR c_acct_Spread_OR_Selection(p_quota_start_date DATE) IS
SELECT decode(greatest(p_quota_start_date, sysdate), sysdate,'SPR','SEL')
FROM dual;

CURSOR c_quota_start_date(p_quota_id NUMBER) IS
SELECT start_date_active
FROM ozf_funds_all_b
WHERE fund_id = p_quota_id;

l_return VARCHAR2(1) := 'N';
l_quota_start_date DATE;
l_acct_icon VARCHAR2(3) := 'N';

BEGIN
 open c_leaf(p_quota_id);
     fetch c_leaf into l_return;
 close c_leaf;

 --kvattiku Feb 23, 04 modified code to ensure proper icons are displayed on the Quota Overview page columns
 IF l_return = 'Y' THEN

  open c_quota_start_date(p_quota_id);
     fetch c_quota_start_date into l_quota_start_date;
  close c_quota_start_date;

  open c_acct_Spread_OR_Selection(l_quota_start_date);
     fetch c_acct_Spread_OR_Selection into l_acct_icon;
  close c_acct_Spread_OR_Selection;

 END IF;


 return l_acct_icon;
END;




FUNCTION get_unallocated_amount(p_quota_id IN NUMBER)
RETURN NUMBER
IS

CURSOR c_leaf(p_quota_id NUMBER) IS
SELECT 'Y' from dual
WHERE exists(SELECT 1 FROM ozf_funds_all_b WHERE parent_fund_id IS NOT NULL AND fund_id = p_quota_id)
AND NOT EXISTS(select 1 FROM ozf_funds_all_b WHERE parent_fund_id = p_quota_id);

CURSOR c_unallocated_amt_leaf(p_quota_id NUMBER) IS
SELECT TARGET Unallocated_Fund
FROM OZF_ACCOUNT_ALLOCATIONS
WHERE ALLOCATION_FOR = 'FUND'
AND ALLOCATION_FOR_ID = p_quota_id
AND PARENT_PARTY_ID = -9999;

CURSOR c_unallocated_amt_non_leaf(p_quota_id NUMBER) IS
SELECT	((NVL(FF.ORIGINAL_BUDGET,0) + NVL(FF.TRANSFERED_IN_AMT,0)) - NVL(FF.TRANSFERED_OUT_AMT,0)) UNALLOCATED_AMT
FROM OZF_FUNDS_ALL_VL FF
WHERE FF.FUND_ID = p_quota_id;

l_return VARCHAR2(1) := 'N';
l_quota_start_date DATE;
l_quota_unallocated_amt NUMBER;

BEGIN
 open c_leaf(p_quota_id);
     fetch c_leaf into l_return;
 close c_leaf;

 IF l_return = 'Y' THEN
  open c_unallocated_amt_leaf(p_quota_id);
     fetch c_unallocated_amt_leaf into l_quota_unallocated_amt;
  close c_unallocated_amt_leaf;
 ELSE
  open c_unallocated_amt_non_leaf(p_quota_id);
     fetch c_unallocated_amt_non_leaf into l_quota_unallocated_amt;
  close c_unallocated_amt_non_leaf;
 END IF;

 return l_quota_unallocated_amt;
END;


FUNCTION get_threshold_name(p_threshold_id IN NUMBER )RETURN VARCHAR2 IS
CURSOR c_threshold_name (p_id NUMBER) IS
SELECT NAME FROM  ozf_thresholds_all_vl  WHERE threshold_id = p_id;
l_threshold_name ozf_thresholds_all_vl.NAME%TYPE;
BEGIN
OPEN c_threshold_name(p_threshold_id);
FETCH c_threshold_name INTO l_threshold_name;
CLOSE c_threshold_name;

return l_threshold_name;

END;


PROCEDURE generate_product_spread(
    p_api_version        IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2
  , p_commit             IN       VARCHAR2
  , p_alloc_id           IN       NUMBER
  , p_mode                IN     VARCHAR2
  , p_context             IN     VARCHAR2
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
)
IS
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'generate_product_spread';
--l_fact_id ozf_act_metric_facts_all.activity_metric_fact_id%type;

CURSOR c_fact_id (p_alloc_id NUMBER)IS
SELECT activity_metric_fact_id , activity_metric_id FROM ozf_act_metric_facts_all
WHERE activity_metric_id =  p_alloc_id;

l_fact_id c_fact_id%rowtype;
BEGIN

  SAVEPOINT generate_product_spread_sp;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

for l_fact_id in c_fact_id(p_alloc_id)
loop
ozf_allocation_engine_pvt.setup_product_spread
 (
    p_api_version        =>1.0,
    p_init_msg_list      => FND_API.G_FALSE,
    p_commit             => FND_API.G_FALSE,
    p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
    x_return_status      => x_return_status,
    x_error_number       => x_msg_count,
    x_error_message      => x_msg_data,
    p_mode               => p_mode,
    p_obj_id             => l_fact_id.activity_metric_fact_id,
    p_context            => p_context
 );
end loop;

IF x_return_status = fnd_api.g_ret_sts_error THEN
    RAISE fnd_api.g_exc_error;
ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE fnd_api.g_exc_unexpected_error;
END IF;

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO generate_product_spread_sp;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO generate_product_spread_sp;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO generate_product_spread_sp;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END generate_product_spread;
---------------------------------------------------------------------
-- PROCEDURE
---   create_quota_alloc_hierarchy
--
-- PURPOSE
--    Create allocation worksheet hierarchy for Trade Planning Quota.
--
-- HISTORY
--    Wed Nov 12 2003:6/26 PM   RSSHARMA  Created.
--
-- PARAMETERS
---------------------------------------------------------------------
PROCEDURE create_quota_alloc_hierarchy(
    p_api_version        IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2
  , p_commit             IN       VARCHAR2
  , p_alloc_id           IN       NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'generate_product_spread';
BEGIN
  SAVEPOINT create_quota_alloc_hier_sp;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

OZF_Fund_allocations_Pvt.create_alloc_hierarchy(
    p_api_version        => p_api_version
  , p_init_msg_list      => p_init_msg_list
  , p_commit             => p_commit
  , p_alloc_id           => p_alloc_id
  , x_return_status      => x_return_status
  , x_msg_count          => x_msg_count
  , x_msg_data           => x_msg_data
);

IF x_return_status = fnd_api.g_ret_sts_error THEN
RAISE fnd_api.g_exc_error;
ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
RAISE fnd_api.g_exc_unexpected_error;
END IF;

generate_product_spread(
    p_api_version        => p_api_version
  , p_init_msg_list      => p_init_msg_list
  , p_commit             => p_commit
  , p_alloc_id           => p_alloc_id
  , p_mode               => 'CREATE'
  , p_context            => 'FACT'
  , x_return_status      => x_return_status
  , x_msg_count          => x_msg_count
  , x_msg_data           => x_msg_count
);

IF x_return_status = fnd_api.g_ret_sts_error THEN
RAISE fnd_api.g_exc_error;
ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
RAISE fnd_api.g_exc_unexpected_error;
END IF;

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO create_quota_alloc_hier_sp;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO create_quota_alloc_hier_sp;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO create_quota_alloc_hier_sp;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END create_quota_alloc_hierarchy;


PROCEDURE update_fund_with_extra_fields(
                              p_api_version         IN     NUMBER    DEFAULT 1.0
                            , p_init_msg_list       IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_commit              IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_validation_level    IN     NUMBER    DEFAULT FND_API.g_valid_level_full
                            , p_alloc_id            IN     NUMBER
                            , x_return_status      OUT NOCOPY      VARCHAR2
                            , x_msg_count          OUT NOCOPY      NUMBER
                            , x_msg_data           OUT NOCOPY      VARCHAR2
                            )
IS
l_api_version    CONSTANT NUMBER       := 1.0;
l_api_name       CONSTANT VARCHAR2(30) := 'allocate_target';
CURSOR c_fact_id (p_alloc_id NUMBER)IS
SELECT activity_metric_fact_id ,  act_metric_used_by_id FROM ozf_act_metric_facts_all
WHERE activity_metric_id =  p_alloc_id;
l_fact_id c_fact_id%rowtype;

CURSOR C_extra_fields (p_alloc_id NUMBER)
IS
SELECT start_period_name, end_period_name, product_spread_time_id FROM ozf_act_metrics_all
WHERE activity_metric_id = p_alloc_id;

l_start_period_name VARCHAR2(30);
l_end_period_name VARCHAR2(30);
l_spread_time_id NUMBER;
BEGIN

  SAVEPOINT update_fund_sp;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN C_extra_fields(p_alloc_id);
    FETCH C_extra_fields  into l_start_period_name, l_end_period_name, l_spread_time_id;
CLOSE C_extra_fields;

for l_fact_id in c_fact_id(p_alloc_id)
loop
    UPDATE ozf_funds_all_b
    SET start_period_name = l_start_period_name,
	end_period_name = l_end_period_name,
	product_spread_time_id = l_spread_time_id
    WHERE fund_id = l_fact_id.act_metric_used_by_id;
end loop;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO update_fund_sp;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END update_fund_with_extra_fields;

PROCEDURE allocate_target  (
                              p_api_version         IN     NUMBER    DEFAULT 1.0
                            , p_init_msg_list       IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_commit              IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_validation_level    IN     NUMBER    DEFAULT FND_API.g_valid_level_full
                            , p_mode                IN     VARCHAR2
                            , p_alloc_id            IN     NUMBER
                            , x_return_status      OUT NOCOPY      VARCHAR2
                            , x_msg_count          OUT NOCOPY      NUMBER
                            , x_msg_data           OUT NOCOPY      VARCHAR2
                            )
IS
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'allocate_target';

CURSOR c_fact_id (p_alloc_id NUMBER)IS
SELECT activity_metric_fact_id ,  act_metric_used_by_id FROM ozf_act_metric_facts_all
WHERE activity_metric_id =  p_alloc_id;

--Added by kvattiku Mar 15, 04
--Will be used to ensure that the ozf_allocation_engine_pvt.allocate_target is called only for leaf quota nodes

CURSOR c_leaf(p_quota_id NUMBER) IS
SELECT 'Y' from dual
WHERE exists(
	SELECT 1 FROM ozf_funds_all_b
	WHERE parent_fund_id IS NOT NULL
	AND fund_id = p_quota_id)
AND NOT EXISTS(
	select 1 FROM ozf_funds_all_b
	WHERE parent_fund_id = p_quota_id);

l_return VARCHAR2(1) := 'N';

l_fact_id c_fact_id%rowtype;

BEGIN
  SAVEPOINT allocate_target_sp;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

for l_fact_id in c_fact_id(p_alloc_id)
loop
	--Added by kvattiku Mar 15, 04
	open c_leaf(l_fact_id.act_metric_used_by_id);
	fetch c_leaf into l_return;
	close c_leaf;

	--call the allocate_target api for leaf quota nodes only
	IF l_return = 'Y' THEN
		ozf_allocation_engine_pvt.allocate_target
		(
		p_api_version        => p_api_version
		, p_init_msg_list      => p_init_msg_list
		, p_commit             => p_commit
		, p_validation_level   => p_validation_level
		, x_return_status      =>x_return_status
		, x_error_number       => x_msg_count
		, x_error_message      => x_msg_data
		, p_mode               => p_mode--'FIRSTTIME',
		, p_fund_id            => l_fact_id.act_metric_used_by_id
		, p_old_start_date     => null
		, p_new_end_date       => null
		, p_addon_fact_id      => null
		, p_addon_amount       => null
		);
	END IF;

end loop;

IF x_return_status = fnd_api.g_ret_sts_error THEN
    RAISE fnd_api.g_exc_error;
ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE fnd_api.g_exc_unexpected_error;
END IF;

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO allocate_target_sp;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO allocate_target_sp;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO allocate_target_sp;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END allocate_target;

PROCEDURE publish_allocation( p_api_version         IN     NUMBER    DEFAULT 1.0
                            , p_init_msg_list       IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_commit              IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_validation_level    IN     NUMBER    DEFAULT FND_API.g_valid_level_full
                            , p_alloc_id            IN     NUMBER
                            , x_return_status       OUT NOCOPY    VARCHAR2
                            , x_msg_count           OUT NOCOPY    NUMBER
                            , x_msg_data            OUT NOCOPY    VARCHAR2
                            )
IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'publish_allocation';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

CURSOR c_facts (p_alloc_id NUMBER) IS
SELECT activity_metric_fact_id , activity_metric_id FROM ozf_act_metric_facts_all
WHERE activity_metric_id = p_alloc_id;

CURSOR c_alloc_dtls(p_alloc_id NUMBER) IS
SELECT status_code,object_version_number FROM ozf_act_metrics_all
    WHERE activity_metric_id = p_alloc_id;

l_alloc_dtls c_alloc_dtls%rowtype;
l_facts c_facts%rowtype;
BEGIN

  SAVEPOINT publish_allocation_sp;

  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

/*  IF NOT Fnd_Api.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
  THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;
*/
  x_return_status := Fnd_Api.g_ret_sts_success;


open c_alloc_dtls(p_alloc_id);
fetch c_alloc_dtls into l_alloc_dtls;
close c_alloc_dtls;
-- Publish funds
/* commented out by kvattiku
ozf_utility_pvt.debug_message('@Calling Publish Allocation');

OZF_FUND_ALLOCATIONS_PVT.publish_allocation(p_api_version         => p_api_version
                                            , p_init_msg_list       => p_init_msg_list
                                            , p_commit              => p_commit
                                            , p_validation_level    => p_validation_level
                                            , p_alloc_id            => p_alloc_id
                                            , p_alloc_status        => l_alloc_dtls.status_code
                                            , p_alloc_obj_ver       => l_alloc_dtls.object_version_number
                                            , x_return_status       => x_return_status
                                            , x_msg_count           => x_msg_count
                                            , x_msg_data            => x_msg_data
                                            );
IF x_return_status = fnd_api.g_ret_sts_error THEN
    RAISE fnd_api.g_exc_error;
ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE fnd_api.g_exc_unexpected_error;
END IF;
ozf_utility_pvt.debug_message('@Done Calling Publish Allocation: Return :'||x_return_status);
-- update generated funds with the time spread of the allocation
*/
ozf_utility_pvt.debug_message('@Calling Update Fund With Time Spread');

update_fund_with_extra_fields(
                            p_api_version         => p_api_version
                            , p_init_msg_list       => p_init_msg_list
                            , p_commit              => p_commit
                            , p_validation_level    => p_validation_level
                            , p_alloc_id            => p_alloc_id
                            , x_return_status       => x_return_status
                            , x_msg_count           => x_msg_count
                            , x_msg_data            => x_msg_data
                            ); -- dont update directly instead call budget api
-- generate product spread for the newly created funds
IF x_return_status = fnd_api.g_ret_sts_error THEN
    RAISE fnd_api.g_exc_error;
ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE fnd_api.g_exc_unexpected_error;
END IF;
ozf_utility_pvt.debug_message('@Done Calling Update Fund With Time Spread: Return :'||x_return_status);
ozf_utility_pvt.debug_message('@Calling generate product spread');

generate_product_spread(
                            p_api_version        => p_api_version
                          , p_init_msg_list      => p_init_msg_list
                          , p_commit             => p_commit
                          , p_alloc_id           => p_alloc_id
                          , p_mode               => 'PUBLISH'
                          , p_context            => 'FACT'
                          , x_return_status      => x_return_status
                          , x_msg_count          => x_msg_count
                          , x_msg_data           => x_msg_count
                        );

-- generate time allocations for the newly generated funds
IF x_return_status = fnd_api.g_ret_sts_error THEN
    RAISE fnd_api.g_exc_error;
ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE fnd_api.g_exc_unexpected_error;
END IF;

ozf_utility_pvt.debug_message('@Done Calling generate product spread: Return:'||x_return_status);
ozf_utility_pvt.debug_message('@Calling allocate target');

allocate_target(
		p_api_version         => p_api_version
		, p_init_msg_list       => p_init_msg_list
                , p_commit              => p_commit
                , p_validation_level    => p_validation_level
                , p_mode                => 'FIRSTTIME'
                , p_alloc_id            => p_alloc_id
                , x_return_status      => x_return_status
                , x_msg_count          => x_msg_count
                , x_msg_data           => x_msg_data
		);

IF x_return_status = fnd_api.g_ret_sts_error THEN
    RAISE fnd_api.g_exc_error;
ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE fnd_api.g_exc_unexpected_error;
END IF;

ozf_utility_pvt.debug_message('@Done Calling allocate target : return :'||x_return_status);

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO publish_allocation_sp;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO publish_allocation_sp;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO publish_allocation_sp;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END;



PROCEDURE cancel_alloc_hfq(
    p_api_version        IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2
  , p_commit             IN       VARCHAR2
  , p_quota_id           IN       NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
)
IS
l_api_version    CONSTANT NUMBER       := 1.0;
l_api_name       CONSTANT VARCHAR2(30) := 'cancel_alloc_hfq';

CURSOR c_alloc_header_ids(p_quota_id NUMBER) IS
select activity_metric_id
from ozf_act_metrics_all
where arc_act_metric_used_by = 'FUND'
and act_metric_used_by_id = p_quota_id;

CURSOR c_alloc_metric_used_by_id(p_alloc_id NUMBER) IS
select act_metric_used_by_id
from ozf_act_metric_facts_all
where arc_act_metric_used_by = 'FUND'
and activity_metric_id = p_alloc_id;

CURSOR c_user_status_id IS
SELECT user_status_id
FROM ams_user_statuses_vl
WHERE system_status_type = 'OZF_FUND_STATUS'
AND system_status_code = 'CANCELLED';

l_alloc_metric_used_by_id NUMBER;
l_user_status_id NUMBER;

BEGIN

SAVEPOINT cancel_alloc_hfq_sp;
x_return_status := FND_API.G_RET_STS_SUCCESS;

--Get all the allocation header records for the fund_id and update the status_code to CANCELLED
update ozf_act_metrics_all
set status_code = 'CANCELLED'
where arc_act_metric_used_by = 'FUND'
and act_metric_used_by_id = p_quota_id;

open c_user_status_id;
fetch c_user_status_id into l_user_status_id;
close c_user_status_id;

for l_alloc_id in c_alloc_header_ids(p_quota_id)
loop

--Get all the allocation fact records for a given allocation id and update their status_code to cancelled
update ozf_act_metric_facts_all
set status_code = 'CANCELLED'
where arc_act_metric_used_by = 'FUND'
and activity_metric_id = l_alloc_id.activity_metric_id;

open c_alloc_metric_used_by_id(l_alloc_id.activity_metric_id);
fetch c_alloc_metric_used_by_id into l_alloc_metric_used_by_id;
close c_alloc_metric_used_by_id;

IF(l_alloc_metric_used_by_id <> p_quota_id) THEN

--Change the status of child quotas to cancelled (happens if the allocation is published)
update ozf_funds_all_b
set status_code = 'CANCELLED',
user_status_id = l_user_status_id
where fund_id in
(
select act_metric_used_by_id from ozf_act_metric_facts_all
where arc_act_metric_used_by = 'FUND'
and activity_metric_id = l_alloc_id.activity_metric_id
);

END IF;


end loop;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO cancel_alloc_hfq_sp;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END cancel_alloc_hfq;








END OZF_Quota_allocations_Pvt;


/
