--------------------------------------------------------
--  DDL for Package Body OZF_FUND_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_EXTENSION_PVT" AS
/* $Header: ozfvfexb.pls 115.10 2004/05/13 07:06:17 kdass noship $*/
   g_pkg_name     CONSTANT VARCHAR2(30) := 'OZF_Fund_Extension_Pvt';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

---------------------------------------------------------------------
-- PROCEDURE
---   get_object_info
--
-- PURPOSE
--    private api to get object owner, name
-- HISTORY
--    02/20/02  yzhao  Created.
--
-- PARAMETERS
-- p_fund_rec: the fund record.
-- p_mode: the mode for create, and delete.
---------------------------------------------------------------------

PROCEDURE get_object_info(
    p_object_id          IN       NUMBER
  , p_object_type        IN       VARCHAR2
  , p_actbudget_status   IN       VARCHAR2
  , x_object_owner       OUT NOCOPY      VARCHAR2
  , x_object_name        OUT NOCOPY      VARCHAR2
  , x_deletable_flag     OUT NOCOPY      VARCHAR2
) IS
  l_owner_id             NUMBER;
  l_budget_offer_yn      VARCHAR2(30);
  l_object_owner         VARCHAR2(240) := '-';
  l_object_name          VARCHAR2(240) := '-';
  l_object_status        VARCHAR2(30) := NULL;
  l_deletable_flag       VARCHAR2(1) := 'D';

  CURSOR c_resource(p_owner_id NUMBER) IS
        SELECT  full_name
        FROM ams_jtf_rs_emp_v
        WHERE resource_id = p_owner_id;

  CURSOR c_offer IS
         SELECT ofr.owner_id, qp.description, ofr.status_code, ofr.budget_offer_yn
           FROM ozf_offers ofr, qp_list_headers qp
          WHERE ofr.qp_list_header_id = qp.list_header_id
            AND ofr.qp_list_header_id = p_object_id;

  CURSOR c_campaign IS
         SELECT owner_user_id, campaign_name, status_code
           FROM ams_campaigns_vl
          WHERE campaign_id = p_object_id;

  CURSOR c_campaign_schl IS
         SELECT owner_user_id, schedule_name, status_code
           FROM ams_campaign_schedules_vl
          WHERE schedule_id = p_object_id;

  CURSOR c_eheader IS
         SELECT owner_user_id, event_header_name, system_status_code
           FROM ams_event_headers_vl
          WHERE event_header_id = p_object_id;

  CURSOR c_eoffer IS
         SELECT owner_user_id, event_offer_name, system_status_code
           FROM ams_event_offers_vl
          WHERE event_offer_id = p_object_id;

  CURSOR c_deliverable IS
         SELECT owner_user_id, deliverable_name, status_code
           FROM ams_deliverables_vl
          WHERE deliverable_id = p_object_id;

  CURSOR c_fund IS
         SELECT owner, short_name, status_code
           FROM ozf_funds_all_vl
          WHERE fund_id = p_object_id;

BEGIN
  x_object_owner := '-';
  x_object_name := '-';
  x_deletable_flag := 'D';

  -- Offer
  IF p_object_type = 'OFFR' THEN
     OPEN c_offer;
     FETCH c_offer INTO l_owner_id, l_object_name, l_object_status,l_budget_offer_yn;
     CLOSE c_offer;
     -- do not check offer status if it fully accrual budget's offer
    IF NVL(l_budget_offer_yn, 'N') = 'N' THEN
     IF l_object_status IS NOT NULL AND l_object_status <> 'ARCHIVED' AND
        p_actbudget_status IN ('PENDING', 'APPROVED') THEN
        l_deletable_flag := 'N';
     END IF;
    END IF;
  -- Campaign
  ELSIF p_object_type = 'CAMP' THEN
     OPEN c_campaign;
     FETCH c_campaign INTO l_owner_id, l_object_name, l_object_status;
     CLOSE c_campaign;
     IF l_object_status IS NOT NULL AND l_object_status <> 'ARCHIVED' AND
        p_actbudget_status IN ('PENDING', 'APPROVED') THEN
        l_deletable_flag := 'N';
     END IF;
  -- Campaign Schdules
  ELSIF p_object_type = 'CSCH' THEN
     OPEN c_campaign_schl;
     FETCH c_campaign_schl INTO l_owner_id, l_object_name, l_object_status;
     CLOSE c_campaign_schl;
  -- Event Header/Rollup Event
  ELSIF p_object_type = 'EVEH' THEN
     OPEN c_eheader;
     FETCH c_eheader INTO l_owner_id, l_object_name, l_object_status;
     CLOSE c_eheader;
     IF l_object_status IS NOT NULL AND l_object_status <> 'ARCHIVED' AND
        p_actbudget_status IN ('PENDING', 'APPROVED') THEN
        l_deletable_flag := 'N';
     END IF;
  -- Event Offer/Execution Event
  ELSIF p_object_type IN ('EONE','EVEO') THEN
     OPEN c_eoffer;
     FETCH c_eoffer INTO l_owner_id, l_object_name, l_object_status;
     CLOSE c_eoffer;
     IF l_object_status IS NOT NULL AND l_object_status <> 'ARCHIVED' AND
        p_actbudget_status IN ('PENDING', 'APPROVED') THEN
        l_deletable_flag := 'N';
     END IF;
  -- Deliverable
  ELSIF p_object_type = 'DELV' THEN
     OPEN c_deliverable;
     FETCH c_deliverable INTO l_owner_id, l_object_name, l_object_status;
     CLOSE c_deliverable;
     IF l_object_status IS NOT NULL AND l_object_status <> 'ARCHIVED' AND
        p_actbudget_status IN ('PENDING', 'APPROVED') THEN
        l_deletable_flag := 'N';
     END IF;
  -- Fund
  ELSIF p_object_type = 'FUND' THEN
     OPEN c_fund;
     FETCH c_fund INTO l_owner_id, l_object_name, l_object_status;
     CLOSE c_fund;
     -- the transaction is non-deletable
     --   if pending/approved transfer/request budget is not in 'DRAFT', 'REJECTED', 'ARCHIVED' status
     IF l_object_status IS NOT NULL AND
        l_object_status NOT IN ('DRAFT', 'REJECTED', 'ARCHIVED') AND
        p_actbudget_status IN ('PENDING', 'APPROVED') THEN
        l_deletable_flag := 'N';
     END IF;
  ELSE
     l_owner_id := -1;
     l_object_owner := ' ';
     l_object_name := ' ';
  END IF;

  IF l_owner_id IS NOT NULL AND l_owner_id <> -1 THEN
     OPEN c_resource(l_owner_id);
     FETCH c_resource INTO l_object_owner;
     CLOSE c_resource;
  END IF;

  x_object_owner := l_object_owner;
  x_object_name := l_object_name;
  x_deletable_flag := l_deletable_flag;

EXCEPTION
  WHEN OTHERS THEN
    -- ignore exceptions
    NULL;
END get_object_info;


---------------------------------------------------------------------
-- PROCEDURE
--   get_actbudgets
--
-- PURPOSE
--    private api called by validate_delete_fund() and get_child_funds()
--    Get an archived fund's transaction records.
--       only archived fund may have transactions. draft or rejected fund does not.
--
-- HISTORY
--    09/03/02  yzhao  Created. Fix bug 2538082: check object's status
--
-- PARAMETERS
--
---------------------------------------------------------------------
PROCEDURE get_actbudgets(
    p_object_id          IN       NUMBER
  , p_parent_fund_id     IN       NUMBER          := NULL  -- set if it is called from child fund
  , x_non_del_flag       OUT NOCOPY      BOOLEAN
  , x_actbudget_tbl      OUT NOCOPY      ams_utility_pvt.dependent_objects_tbl_type
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  l_api_name             CONSTANT VARCHAR2(30) := 'get_actbudgets';
  I                      NUMBER;
  l_include_rec          BOOLEAN := TRUE;
  l_child_fund_id        NUMBER;
  l_actbudget_tbl        ams_utility_pvt.dependent_objects_tbl_type;

  CURSOR c_get_actbudget_usedby IS
    SELECT arc_act_budget_used_by, act_budget_used_by_id, status_code
    FROM   ozf_act_budgets
    WHERE  budget_source_type = 'FUND'
    AND    budget_source_id = p_object_id
    AND    transfer_type IN ('TRANSFER', 'REQUEST', 'UTILIZED');

  CURSOR c_get_actbudget_source IS
    SELECT budget_source_type, budget_source_id, status_code
    FROM   ozf_act_budgets
    WHERE  arc_act_budget_used_by = 'FUND'
    AND    act_budget_used_by_id = p_object_id
    AND    transfer_type IN ('TRANSFER', 'REQUEST', 'UTILIZED');

  CURSOR c_get_fund_child(p_child_fund_id NUMBER) IS
    SELECT fund_id
    FROM   ozf_funds_all_b
    WHERE  parent_fund_id = p_object_id
    AND    fund_id = p_child_fund_id;

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  x_non_del_flag := false;
  I := 1;

  FOR actbudget_rec IN c_get_actbudget_usedby LOOP
      l_include_rec := TRUE;
      IF p_parent_fund_id IS NOT NULL AND
         actbudget_rec.arc_act_budget_used_by = 'FUND' THEN
         -- do not display fund transfers between parent and children, since we check child funds seperately
         IF actbudget_rec.act_budget_used_by_id = p_parent_fund_id THEN
            l_include_rec := FALSE;
         ELSE
            l_child_fund_id := NULL;
            OPEN c_get_fund_child(actbudget_rec.act_budget_used_by_id);
            FETCH c_get_fund_child INTO l_child_fund_id;
            CLOSE c_get_fund_child;
            IF l_child_fund_id IS NULL THEN
               l_include_rec := TRUE;
            ELSE
               -- the transaction is for parent-child fund transfer, do not display
               l_include_rec := FALSE;
            END IF;
         END IF;
      END IF;

      IF l_include_rec THEN
          l_actbudget_tbl(I).TYPE := ozf_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER', actbudget_rec.arc_act_budget_used_by);
          l_actbudget_tbl(I).status := actbudget_rec.status_code;
          get_object_info( actbudget_rec.act_budget_used_by_id
                         , actbudget_rec.arc_act_budget_used_by
                         , actbudget_rec.status_code
                         , l_actbudget_tbl(I).owner
                         , l_actbudget_tbl(I).name
                         , l_actbudget_tbl(I).deletable_flag
                         );
    /*          dbms_output.put_line('actbudget ' || I || ': used by' || actbudget_rec.arc_act_budget_used_by
                           || ' id=' || actbudget_rec.act_budget_used_by_id
                           || ' status=' || actbudget_rec.status_code
                           || ' owner=' || l_actbudget_tbl(I).owner
                           || ' name=' || l_actbudget_tbl(I).name
                           );
                           */
          IF l_actbudget_tbl(I).deletable_flag = 'N' THEN
             x_non_del_flag := true;
          END IF;
          I := I + 1;
      END IF;
  END LOOP;

  FOR actbudget_rec IN c_get_actbudget_source LOOP
      l_include_rec := TRUE;
      IF p_parent_fund_id IS NOT NULL AND
         actbudget_rec.budget_source_type = 'FUND' THEN
         -- do not display fund transfers between parent and children, since we check child funds seperately
         IF actbudget_rec.budget_source_id = p_parent_fund_id THEN
            l_include_rec := FALSE;
         ELSE
            l_child_fund_id := NULL;
            OPEN c_get_fund_child(actbudget_rec.budget_source_id);
            FETCH c_get_fund_child INTO l_child_fund_id;
            CLOSE c_get_fund_child;
            IF l_child_fund_id IS NULL THEN
               l_include_rec := TRUE;
            ELSE
               -- the transaction is for parent-child fund transfer, do not display
               l_include_rec := FALSE;
            END IF;
         END IF;
      END IF;

      IF l_include_rec THEN
          l_actbudget_tbl(I).TYPE := ozf_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER', actbudget_rec.budget_source_type);
          l_actbudget_tbl(I).status := actbudget_rec.status_code;
          get_object_info( actbudget_rec.budget_source_id
                         , actbudget_rec.budget_source_type
                         , actbudget_rec.status_code
                         , l_actbudget_tbl(I).owner
                         , l_actbudget_tbl(I).name
                         , l_actbudget_tbl(I).deletable_flag
                         );
                         /*
          dbms_output.put_line('actbudget ' || I || ': used by' || actbudget_rec.budget_source_type
                           || ' id=' || actbudget_rec.budget_source_id
                           || ' status=' || actbudget_rec.status_code
                           || ' owner=' || l_actbudget_tbl(I).owner
                           || ' name=' || l_actbudget_tbl(I).name
                           );
                           */
          IF l_actbudget_tbl(I).deletable_flag = 'N' THEN
             x_non_del_flag := true;
          END IF;
          I := I + 1;
      END IF;
  END LOOP;

  x_actbudget_tbl := l_actbudget_tbl;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END get_actbudgets;


---------------------------------------------------------------------
-- PROCEDURE
--   get_child_funds
--
-- PURPOSE
--    private api called by validate_delete_fund()
--    Get children and grandchildren funds information
--
-- HISTORY
--    02/20/02  yzhao  Created.
--
-- PARAMETERS
--
---------------------------------------------------------------------
PROCEDURE get_child_funds(
    p_object_id          IN       NUMBER
  , x_non_del_flag       OUT NOCOPY      BOOLEAN
  , x_child_fund_tbl     OUT NOCOPY      ams_utility_pvt.dependent_objects_tbl_type
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  l_api_name             CONSTANT VARCHAR2(30) := 'get_child_funds';
  l_object_type          VARCHAR2(30);
  l_non_del_flag         BOOLEAN;
  l_actbudget_tbl        ams_utility_pvt.dependent_objects_tbl_type;
  l_child_fund_tbl       ams_utility_pvt.dependent_objects_tbl_type;
  l_grandchild_fund_tbl  ams_utility_pvt.dependent_objects_tbl_type;
  I                      NUMBER;

  CURSOR c_get_child_funds IS
    SELECT fund_id, short_name, status_code, owner,
           decode(status_code, 'DRAFT', 'Y', 'REJECTED', 'Y', 'ARCHIVED', 'Y', 'N') deletable_flag
    FROM   ozf_funds_all_vl
    WHERE  parent_fund_id = p_object_id;

  CURSOR c_resource(p_owner_id NUMBER) IS
        SELECT  full_name
        FROM ams_jtf_rs_emp_v
        WHERE resource_id = p_owner_id;

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  x_non_del_flag := false;
  I := 1;

  l_object_type := ozf_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER', 'FUND');
  FOR child_fund_rec IN c_get_child_funds LOOP
      l_child_fund_tbl(I).name := child_fund_rec.short_name;
      l_child_fund_tbl(I).type := l_object_type;
      l_child_fund_tbl(I).status := child_fund_rec.status_code;
      -- draft, rejected or archived child fund is deletable.
      l_child_fund_tbl(I).deletable_flag := child_fund_rec.deletable_flag;
      IF child_fund_rec.deletable_flag = 'N' THEN
         x_non_del_flag := true;
      END IF;
      l_child_fund_tbl(I).owner := '-';
      OPEN c_resource(child_fund_rec.owner);
      FETCH c_resource INTO l_child_fund_tbl(I).owner;
      CLOSE c_resource;
      /*
      dbms_output.put_line('child fund ' || I || ': ' || child_fund_rec.short_name
                           || ' status=' || child_fund_rec.status_code
                           || ' owner=' || l_child_fund_tbl(I).owner
                           );
      */
      I := I + 1;

      -- 09/03/2002 fix bug 2538082: check archived child fund's transaction records
      IF child_fund_rec.status_code = 'ARCHIVED' THEN
         -- only archived fund may have transactions. draft or rejected fund does not.
         get_actbudgets(p_object_id          => child_fund_rec.fund_id
                      , p_parent_fund_id     => p_object_id
                      , x_non_del_flag       => l_non_del_flag
                      , x_actbudget_tbl      => l_actbudget_tbl
                      , x_return_status      => x_return_status
                      , x_msg_count          => x_msg_count
                      , x_msg_data           => x_msg_data
                        );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         FOR J IN NVL(l_actbudget_tbl.FIRST, 1) .. NVL(l_actbudget_tbl.LAST, 0) LOOP
            l_child_fund_tbl(I).name := l_actbudget_tbl(J).name;
            l_child_fund_tbl(I).TYPE := l_actbudget_tbl(J).TYPE;
            l_child_fund_tbl(I).status := l_actbudget_tbl(J).status;
            l_child_fund_tbl(I).deletable_flag := l_actbudget_tbl(J).deletable_flag;
            l_child_fund_tbl(I).owner := l_actbudget_tbl(J).owner;
            I := I + 1;
         END LOOP;
         IF l_non_del_flag THEN
            x_non_del_flag := TRUE;
         END IF;
      END IF;
      -- 09/03/2002 checking child fund's transaction records ends

      get_child_funds( p_object_id       => child_fund_rec.fund_id
                     , x_non_del_flag    => l_non_del_flag
                     , x_child_fund_tbl  => l_grandchild_fund_tbl
                     , x_return_status   => x_return_status
                     , x_msg_count       => x_msg_count
                     , x_msg_data        => x_msg_data
                     );
      IF l_grandchild_fund_tbl IS NOT NULL THEN
         FOR J IN NVL(l_grandchild_fund_tbl.FIRST, 1) .. NVL(l_grandchild_fund_tbl.LAST, 0) LOOP
            l_child_fund_tbl(I).name := l_grandchild_fund_tbl(J).name;
            l_child_fund_tbl(I).TYPE := l_grandchild_fund_tbl(J).TYPE;
            l_child_fund_tbl(I).status := l_grandchild_fund_tbl(J).status;
            l_child_fund_tbl(I).deletable_flag := l_grandchild_fund_tbl(J).deletable_flag;
            l_child_fund_tbl(I).owner := l_grandchild_fund_tbl(J).owner;
            I := I + 1;
         END LOOP;
         IF l_non_del_flag THEN
            x_non_del_flag := TRUE;
         END IF;
      END IF;
  END LOOP;
  x_child_fund_tbl := l_child_fund_tbl;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

END get_child_funds;


---------------------------------------------------------------------
-- PROCEDURE
---   validate_delete_fund
--
-- PURPOSE
--    Validate whether a fund can be deleted. Called by 'Delete Objects' framework
--    Only 'draft', 'rejected', 'archived' fund are allowed to be deleted
--    1) identify and provide details of dependent objects that cannot be deleted.
--    2) if all dependent objects can be deleted, identify and provide details of
--       these dependent objects and relationships that can be disassociated.
--
-- HISTORY
--    02/20/02  yzhao  Created.
--
-- PARAMETERS
--
---------------------------------------------------------------------

PROCEDURE validate_delete_fund(
    p_api_version_number IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  , p_commit             IN       VARCHAR2 := fnd_api.g_false
  , p_object_id          IN       NUMBER
  , p_object_version_number IN    NUMBER
  , x_dependent_object_tbl  OUT NOCOPY   ams_utility_pvt.dependent_objects_tbl_type
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  l_api_name        CONSTANT VARCHAR2(30) := 'validate_delete_fund';
  l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_depend_obj_tbl  ams_utility_pvt.dependent_objects_tbl_type;
  l_actbudget_tbl   ams_utility_pvt.dependent_objects_tbl_type;
  l_fund_status     VARCHAR2(30);
  l_non_del_flag    BOOLEAN := FALSE;
  I                 NUMBER := 1;

  CURSOR c_get_fund_info IS
    SELECT status_code
    FROM   ozf_funds_all_b
    WHERE  fund_id = p_object_id;

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  OPEN c_get_fund_info;
  FETCH c_get_fund_info INTO l_fund_status;
  CLOSE c_get_fund_info;
  -- dbms_output.put_line('Enter validate_delete_fund fund_id=' || p_object_id || '  status=' || l_fund_status);

  get_child_funds( p_object_id          => p_object_id
                 , x_non_del_flag       => l_non_del_flag
                 , x_child_fund_tbl     => l_depend_obj_tbl
                 , x_return_status      => x_return_status
                 , x_msg_count          => x_msg_count
                 , x_msg_data           => x_msg_data
                 );
  IF x_return_status <> fnd_api.g_ret_sts_success THEN
     raise fnd_api.g_exc_unexpected_error;
  END IF;

  IF l_non_del_flag THEN
     -- return. There are non-deletable objects.
     x_dependent_object_tbl := l_depend_obj_tbl;
     x_return_status := fnd_api.g_ret_sts_success;
     RETURN;
  END IF;

  I := NVL(l_depend_obj_tbl.LAST, 0) + 1;
  IF l_fund_status = 'ARCHIVED' THEN
     -- only archived fund may have transactions. draft or rejected fund does not.
     get_actbudgets(p_object_id          => p_object_id
                  , p_parent_fund_id     => NULL
                  , x_non_del_flag       => l_non_del_flag
                  , x_actbudget_tbl      => l_actbudget_tbl
                  , x_return_status      => x_return_status
                  , x_msg_count          => x_msg_count
                  , x_msg_data           => x_msg_data
                    );
     IF x_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_unexpected_error;
     END IF;

     FOR J IN NVL(l_actbudget_tbl.FIRST, 1) .. NVL(l_actbudget_tbl.LAST, 0) LOOP
        l_depend_obj_tbl(I).name := l_actbudget_tbl(J).name;
        l_depend_obj_tbl(I).TYPE := l_actbudget_tbl(J).TYPE;
        l_depend_obj_tbl(I).status := l_actbudget_tbl(J).status;
        l_depend_obj_tbl(I).deletable_flag := l_actbudget_tbl(J).deletable_flag;
        l_depend_obj_tbl(I).owner := l_actbudget_tbl(J).owner;
        I := I + 1;
     END LOOP;
  END IF;

  x_dependent_object_tbl := l_depend_obj_tbl;
  -- dbms_output.put_line('Validate_delete_fund successfully ends');

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

END validate_delete_fund;

---------------------------------------------------------------------
-- PROCEDURE
--       terminate_accrual_offer
--
-- PURPOSE
--    This API does the following transactions
--    1) Terminates an offer when its associated budget is deleted.
-- HISTORY
--    23/06/2003  Navin Kumar Create.
-- NOTES
---------------------------------------------------------------------

PROCEDURE terminate_accrual_offer
(
 p_fund_id IN NUMBER,
 x_msg_count       OUT NOCOPY      NUMBER,
 x_msg_data        OUT NOCOPY      VARCHAR2,
 x_return_status   OUT NOCOPY      VARCHAR2
)
IS

l_fund_id          VARCHAR2(30) := p_fund_id;
l_user_status_id   VARCHAR2(30);
l_full_name   VARCHAR2(30);

l_status_type      VARCHAR2(30) := 'OZF_OFFER_STATUS';
l_offer_id          NUMBER;
l_qp_list_header_id    NUMBER;
l_offer_obj_ver_num      NUMBER;
l_offer_type   VARCHAR2(30);
l_error_location         NUMBER;

l_offer_hdr_rec     ozf_offer_pvt.modifier_list_rec_type;
l_offer_line_tbl         ozf_offer_pvt.modifier_line_tbl_type;
l_return_status          VARCHAR2(1)        := fnd_api.g_ret_sts_success;

CURSOR c_get_offers(p_qp_list_header_id IN NUMBER)
 IS
 SELECT offer_id, object_version_number, offer_type
 FROM ozf_offers
 WHERE qp_list_header_id =  p_qp_list_header_id;

CURSOR c_qp_list_header_id
 IS
 SELECT plan_id
 FROM ozf_funds_all_b
 WHERE fund_id =  l_fund_id;

BEGIN

 SAVEPOINT terminate_accrual_offer;
 IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name       ||
                                    ': terminate_accrual_offer');
  END IF;
      x_return_status := fnd_api.g_ret_sts_success;


 IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('l_qp_list_header_id =>' ||
                                       l_qp_list_header_id);
 END IF;

 OPEN c_qp_list_header_id;
 FETCH c_qp_list_header_id INTO l_qp_list_header_id;
 CLOSE c_qp_list_header_id;

 OPEN c_get_offers(l_qp_list_header_id);
 FETCH c_get_offers INTO l_offer_id, l_offer_obj_ver_num,l_offer_type;
 CLOSE c_get_offers;


         l_offer_hdr_rec.qp_list_header_id :=  l_qp_list_header_id;
         l_offer_hdr_rec.offer_id :=   l_offer_id;
         l_offer_hdr_rec.object_version_number :=  l_offer_obj_ver_num;
         l_offer_hdr_rec.offer_type := l_offer_type;
         l_offer_hdr_rec.offer_operation := 'UPDATE';
         l_offer_hdr_rec.modifier_operation := 'UPDATE';

         --kdass bug 3612350 - changed offer status from TERMINATED to CANCELLED
	 l_offer_hdr_rec.user_status_id := ozf_utility_pvt.get_default_user_status(l_status_type,'CANCELLED');
         l_offer_hdr_rec.status_code := 'CANCELLED';
	 --l_offer_hdr_rec.user_status_id := ozf_utility_pvt.get_default_user_status(l_status_type,'TERMINATED');
         --l_offer_hdr_rec.status_code := 'TERMINATED';

         ozf_offer_pvt.process_modifiers(
         p_init_msg_list=> fnd_api.g_false,
         p_api_version=> 1.0,
         p_commit=> fnd_api.g_false,
         x_return_status=> l_return_status,
         x_msg_count=> x_msg_count,
         x_msg_data=> x_msg_data,
         p_modifier_list_rec=> l_offer_hdr_rec,
         p_modifier_line_tbl=> l_offer_line_tbl,
         p_offer_type=> l_offer_hdr_rec.offer_type,
         x_qp_list_header_id=> l_qp_list_header_id,
         x_error_location=> l_error_location);

         IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(
         'l_return_status' ||
         l_return_status   ||
         '-'               ||
         l_error_location  ||
         x_msg_data);
         END IF;

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('OZF_OFFR_QP_FAILURE ' ||
                                       l_error_location      ||
                                       x_msg_data);
         END IF;


         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;


END terminate_accrual_offer;

---------------------------------------------------------------------
-- PROCEDURE
--    delete_fund_schema
--
-- PURPOSE
--    private api called by delete_fund()
--    p_top_del_budget_id: the top budget id to be deleted.
--
-- HISTORY
--    02/20/02  yzhao  Created.
--    06/23/03  nkumar Modified.
--
-- PARAMETERS
---------------------------------------------------------------------

PROCEDURE delete_fund_schema(
    p_api_version_number IN       NUMBER
  , p_object_id          IN       NUMBER
  , p_object_version_number IN    NUMBER
  , p_top_del_budget_id  IN       NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  l_api_name             CONSTANT VARCHAR2(30) := 'delete_fund_schema';
  l_fund_rec             ozf_funds_pvt.fund_rec_type;
  l_msg_text             VARCHAR2(4000);
  l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count            NUMBER;
  l_msg_data            VARCHAR2(4000);


  CURSOR c_get_child_funds IS
    SELECT fund_id, object_version_number
    FROM   ozf_funds_all_b
    WHERE  parent_fund_id = p_object_id;

  CURSOR c_get_fund_info IS
    SELECT fund_id
         , owner
         , short_name
         , parent_fund_id
         , -rollup_original_budget
         , -rollup_transfered_in_amt
         , -rollup_transfered_out_amt
         , -rollup_holdback_amt
         , -rollup_planned_amt
         , -rollup_committed_amt
         , -rollup_utilized_amt      -- yzhao: 12/02/2003 11.5.10 added
         , -rollup_earned_amt
         , -rollup_paid_amt
         , -rollup_recal_committed
	 , status_code
	 , fund_type

    FROM   ozf_funds_all_vl
    WHERE  fund_id = p_object_id
    AND    object_version_number = p_object_version_number;

  CURSOR c_get_utilization IS
    SELECT utilization_id
    FROM   ozf_funds_utilized_all_b
    WHERE  fund_id = p_object_id
    OR     (object_id = p_object_id  AND  object_type = 'FUND')
    OR     (component_id = p_object_id  AND component_type = 'FUND');

  CURSOR  c_get_metrics IS
    SELECT activity_metric_id
      from ozf_act_metrics_all
     where act_metric_used_by_id = p_object_id
       and arc_act_metric_used_by = 'FUND';

  CURSOR c_fund_access IS
    SELECT activity_access_id
         , object_version_number
    FROM   ams_act_access
    WHERE  act_access_to_object_id = p_object_id
    AND    arc_act_access_to_object = 'FUND';

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   FOR child_rec IN c_get_child_funds LOOP
       delete_fund_schema(p_api_version_number    => p_api_version_number
                 , p_object_id             => child_rec.fund_id
                 , p_object_version_number => child_rec.object_version_number
                 , p_top_del_budget_id     => p_top_del_budget_id
                 , x_return_status         => l_return_status
                 , x_msg_count             => x_msg_count
                 , x_msg_data              => x_msg_data
                 );
       IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
       END IF;
   END LOOP;

   -- ??? how to delete note? no JTF_NOTEs_PUB.delete

   l_fund_rec := NULL;
   OPEN c_get_fund_info;
   FETCH c_get_fund_info
   INTO l_fund_rec.fund_id
     ,  l_fund_rec.owner
     ,  l_fund_rec.short_name
     ,  l_fund_rec.parent_fund_id
     ,  l_fund_rec.rollup_original_budget
     ,  l_fund_rec.rollup_transfered_in_amt
     ,  l_fund_rec.rollup_transfered_out_amt
     ,  l_fund_rec.rollup_holdback_amt
     ,  l_fund_rec.rollup_planned_amt
     ,  l_fund_rec.rollup_committed_amt
     ,  l_fund_rec.rollup_utilized_amt      -- yzhao: 12/02/2003 11.5.10 added
     ,  l_fund_rec.rollup_earned_amt
     ,  l_fund_rec.rollup_paid_amt
     ,  l_fund_rec.rollup_recal_committed
     ,  l_fund_rec.status_code
     ,  l_fund_rec.fund_type;

   l_fund_rec.object_version_number := p_object_version_number;
   CLOSE c_get_fund_info;
   -- dbms_output.put_line(' Enter delete_fund_schema ' || p_object_id || ' name=' || l_fund_rec.short_name || ' parent_fund_id=' || l_fund_rec.parent_fund_id);

   -- update ancestors rollup amount and access only if this is the top delete budget
   IF l_fund_rec.parent_fund_id IS NOT NULL
   AND p_top_del_budget_id = p_object_id THEN
      -- update its ancestors' rollup amount
      ozf_funds_pvt.update_rollup_amount(
             p_api_version      => p_api_version_number
            ,p_init_msg_list    => fnd_api.g_false
            ,p_commit           => fnd_api.g_false
            ,p_validation_level => fnd_api.G_VALID_LEVEL_NONE
            ,x_return_status    => l_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data
            ,p_fund_rec         => l_fund_rec
            );
      -- dbms_output.put_line('update_rollup_amount for budget ' || l_fund_rec.short_name || ' returns ' || x_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         -- l_msg_text := 'Update ancestor''s rollup amount for budget ' || l_fund_rec.short_name;
         fnd_message.set_name ('OZF', 'OZF_ERR_UPD_FUND_ROLLUP');
         fnd_message.set_token ('BUDGET_NAME', l_fund_rec.short_name);
         ozf_utility_pvt.create_log(
            x_return_status     => l_return_status
          , p_arc_log_used_by   => 'FUND'
          , p_log_used_by_id    => p_top_del_budget_id
          , p_msg_data          => fnd_message.get
          , p_msg_type          => 'ERROR'
          );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- remove its ancestors' access to the budget
      ozf_funds_pvt.update_funds_access(
             p_api_version      => p_api_version_number
            ,p_init_msg_list    => fnd_api.g_false
            ,p_commit           => fnd_api.g_false
            ,p_validation_level => fnd_api.G_VALID_LEVEL_NONE
            ,x_return_status    => l_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data
            ,p_fund_rec         => l_fund_rec
            ,p_mode             => 'DELETE'
            );
      -- dbms_output.put_line('update_funds_access for budget ' || l_fund_rec.short_name || ' returns ' || x_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         -- l_msg_text := 'Remove ancestor''s access to budget ' || l_fund_rec.short_name;
         fnd_message.set_name ('OZF', 'OZF_ERR_UPD_FUND_ACCESS');
         fnd_message.set_token ('BUDGET_NAME', l_fund_rec.short_name);
         ozf_utility_pvt.create_log(
            x_return_status     => l_return_status
          , p_arc_log_used_by   => 'FUND'
          , p_log_used_by_id    => p_top_del_budget_id
          , p_msg_data          => fnd_message.get
          , p_msg_type          => 'ERROR'
          );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   END IF;  -- update ancestor

   -- Terminate the associated offer on accrual budget deletion whos status is DRAFT/REJECT

      IF l_fund_rec.status_code IN ('DRAFT','REJECTED') AND l_fund_rec.fund_type IN ('FULLY_ACCRUED') THEN
       terminate_accrual_offer(
            p_fund_id => p_top_del_budget_id
	   ,x_return_status    => l_return_status
	   ,x_msg_count   => x_msg_count
           ,x_msg_data  => x_msg_data
           );

     IF l_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

     -- End Terminate offer

   BEGIN

     -- delete allocation data
     FOR metric_rec IN c_get_metrics
     LOOP
         -- dbms_output.put_line('Delete allocation alloc_id=' || metric_rec.activity_metric_id);

         DELETE FROM OZF_ACT_METRIC_FACTS_ALL
          WHERE ACTIVITY_METRIC_ID = metric_rec.activity_metric_id
           AND ARC_ACT_METRIC_USED_BY = 'FUND';

         DELETE FROM  ozf_act_metric_form_ent
          WHERE formula_id IN ( SELECT FORMULA_ID
                                  FROM OZF_ACT_METRIC_FORMULAS
                                 WHERE ACTIVITY_METRIC_ID = metric_rec.activity_metric_id);

         DELETE FROM  ozf_act_metric_formulas
          WHERE ACTIVITY_METRIC_ID = metric_rec.activity_metric_id;

         DELETE from ozf_act_metrics_all
          WHERE ACTIVITY_METRIC_ID = metric_rec.activity_metric_id;
     END LOOP;

     -- delete transaction data
     DELETE FROM ozf_act_budgets
     WHERE  (budget_source_type = 'FUND'
     AND     budget_source_id = p_object_id
     OR      arc_act_budget_used_by = 'FUND'
     AND     act_budget_used_by_id = p_object_id
            )
     AND    transfer_type IN ('TRANSFER', 'REQUEST', 'UTILIZATION', 'RESERVE');
     -- dbms_output.put_line('Remove ' || SQL%ROWCOUNT || ' transaction records with budget ' || l_fund_rec.short_name);
     IF SQL%ROWCOUNT > 0 THEN
        -- l_msg_text := 'Remove transactions associated with budget ' || l_fund_rec.short_name;
        fnd_message.set_name ('OZF', 'OZF_DEL_FUND_TRANSACTION');
        fnd_message.set_token ('BUDGET_NAME', l_fund_rec.short_name);
        ozf_utility_pvt.create_log(
            x_return_status     => l_return_status
          , p_arc_log_used_by   => 'FUND'
          , p_log_used_by_id    => p_top_del_budget_id
          , p_msg_data          => fnd_message.get
          , p_msg_type          => 'MILESTONE'
          );
     END IF;

     -- delete product data
     DELETE FROM ams_act_products
     WHERE  arc_act_product_used_by = 'FUND'
     AND    act_product_used_by_id = p_object_id;
     -- dbms_output.put_line('Remove ' || SQL%ROWCOUNT || ' product records with budget ' || l_fund_rec.short_name);
     IF SQL%ROWCOUNT > 0 THEN
        --l_msg_text := 'Remove products associated with budget ' || l_fund_rec.short_name;
        fnd_message.set_name ('OZF', 'OZF_DEL_FUND_PRODUCT');
        fnd_message.set_token ('BUDGET_NAME', l_fund_rec.short_name);
        ozf_utility_pvt.create_log(
            x_return_status     => l_return_status
          , p_arc_log_used_by   => 'FUND'
          , p_log_used_by_id    => p_top_del_budget_id
          , p_msg_data          => fnd_message.get
          , p_msg_type          => 'MILESTONE'
          );
     END IF;

     -- delete market segment data
     DELETE FROM ams_act_market_segments
     WHERE  arc_act_market_segment_used_by = 'FUND'
     AND    act_market_segment_used_by_id = p_object_id;
     -- dbms_output.put_line('Remove ' || SQL%ROWCOUNT || ' market segment records with budget ' || l_fund_rec.short_name);
     IF SQL%ROWCOUNT > 0 THEN
        --l_msg_text := 'Remove market eligibilities associated with budget ' || l_fund_rec.short_name;
        fnd_message.set_name ('OZF', 'OZF_DEL_FUND_MARKET');
        fnd_message.set_token ('BUDGET_NAME', l_fund_rec.short_name);
        ozf_utility_pvt.create_log(
            x_return_status     => l_return_status
          , p_arc_log_used_by   => 'FUND'
          , p_log_used_by_id    => p_top_del_budget_id
          , p_msg_data          => fnd_message.get
          , p_msg_type          => 'MILESTONE'
          );
     END IF;

     -- delete utilization data
     FOR util_rec in c_get_utilization LOOP
        DELETE FROM ozf_funds_utilized_all_b
        WHERE  utilization_id = util_rec.utilization_id;
        DELETE FROM ozf_funds_utilized_all_tl
        WHERE  utilization_id = util_rec.utilization_id;
     END LOOP;
     -- dbms_output.put_line('Remove ' || SQL%ROWCOUNT || ' utilization records with budget ' || l_fund_rec.short_name);
   EXCEPTION
     -- ignore these trival errors
     WHEN OTHERS THEN
       -- dbms_output.put_line('exception in delete tables. IGNORE');
       NULL;
   END;

   -- remove every one's access to this budget
   FOR fund_access_rec IN c_fund_access LOOP
      ams_access_pvt.delete_access(
                  p_api_version      => p_api_version_number
                 ,p_init_msg_list    => fnd_api.g_false
                 ,p_validation_level => fnd_api.G_VALID_LEVEL_NONE
                 ,x_return_status    => l_return_status
                 ,x_msg_count        => x_msg_count
                 ,x_msg_data         => x_msg_data
                 ,p_commit           => fnd_api.g_false
                 ,p_access_id        => fund_access_rec.activity_access_id
                 ,p_object_version   => fund_access_rec.object_version_number);
      -- dbms_output.put_line('delete access to fund returns ' || l_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         fnd_message.set_name ('OZF', 'OZF_ERR_UPD_FUND_ACCESS');
         fnd_message.set_token ('BUDGET_NAME', l_fund_rec.short_name);
         ozf_utility_pvt.create_log(
            x_return_status     => l_return_status
          , p_arc_log_used_by   => 'FUND'
          , p_log_used_by_id    => p_top_del_budget_id
          , p_msg_data          => fnd_message.get
          , p_msg_type          => 'MILESTONE'
         );
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END LOOP;

   DELETE FROM ozf_funds_all_b
   WHERE  fund_id = p_object_id
   AND    object_version_number = p_object_version_number;
   -- dbms_output.put_line('Remove ' || SQL%ROWCOUNT || ' ozf_funds_all_b records with budget ' || l_fund_rec.short_name);
   IF SQL%ROWCOUNT > 0 THEN
      -- l_msg_text := 'Remove table record of budget ' || l_fund_rec.short_name;
      fnd_message.set_name ('OZF', 'OZF_DEL_FUND_RECORD');
      fnd_message.set_token ('BUDGET_NAME', l_fund_rec.short_name);
      ozf_utility_pvt.create_log(
            x_return_status     => l_return_status
          , p_arc_log_used_by   => 'FUND'
          , p_log_used_by_id    => p_top_del_budget_id
          , p_msg_data          => fnd_message.get
          , p_msg_type          => 'MILESTONE'
          );
   END IF;

   DELETE FROM ozf_funds_all_tl
   WHERE  fund_id = p_object_id;
   -- dbms_output.put_line('Remove ' || SQL%ROWCOUNT || ' ozf_funds_all_tl records with budget ' || l_fund_rec.short_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      -- dbms_output.put_line('delete_fund_schema exception expected error');
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      -- dbms_output.put_line('delete_fund_schema exception unexpected error');
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN OTHERS THEN
      -- dbms_output.put_line('delete_fund_schema exception other error');
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END delete_fund_schema;


---------------------------------------------------------------------
-- PROCEDURE
---   delete_fund
--
-- PURPOSE
--    api alled by 'Delete Objects' framework to do hard table delete
--
-- HISTORY
--    02/20/02  yzhao  Created.
--
-- PARAMETERS
---------------------------------------------------------------------

PROCEDURE delete_fund(
    p_api_version_number IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  , p_commit             IN       VARCHAR2 := fnd_api.g_false
  , p_object_id          IN       NUMBER
  , p_object_version_number IN    NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  l_api_name             CONSTANT VARCHAR2(30) := 'delete_fund';
BEGIN
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean (p_init_msg_list) THEN
     fnd_msg_pub.initialize;
  END IF;

  delete_fund_schema(
      p_api_version_number    => p_api_version_number
    , p_object_id             => p_object_id
    , p_object_version_number => p_object_version_number
    , p_top_del_budget_id     => p_object_id
    , x_return_status         => x_return_status
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
  );
  -- dbms_output.put_line('delete_fund_schema returns ' || x_return_status);

  IF p_commit = fnd_api.g_true THEN
     commit;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      -- dbms_output.put_line('delete_fund exception other error');
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END delete_fund;

END OZF_Fund_Extension_Pvt;


/
