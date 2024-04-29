--------------------------------------------------------
--  DDL for Package Body INV_AUTODETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_AUTODETAIL" AS
/* $Header: INVRSV4B.pls 120.2 2006/02/17 14:48:23 rambrose noship $ */
--
-- Global constant holding package name
g_pkg_name constant varchar2(50) := 'INV_AUTODETAIL';
--
-- Package Globals
--
TYPE g_pp_temp_rec_type IS RECORD
  (
   transaction_quantity         NUMBER,
   transaction_uom              VARCHAR2(3),
   primary_quantity             NUMBER,
   primary_uom                  VARCHAR2(3),
   from_subinventory_code       VARCHAR2(10),
   from_locator_id              NUMBER,
   revision                     VARCHAR2(3),
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   lot_number                   VARCHAR2(80),
   to_subinventory_code         VARCHAR2(10),
   to_locator_id                NUMBER,
   lot_expiration_date          DATE,
   reservation_id               NUMBER,
   from_cost_group_id		NUMBER,
   to_cost_group_id		NUMBER
   );
--
TYPE g_pp_temp_tbl_type IS TABLE OF g_pp_temp_rec_type INDEX BY BINARY_INTEGER;
--
-- sql statement built for detailing
g_stmt long;
--
g_tree_id NUMBER;

-- Globals added for pick release performance changes
g_inventory_item_id NUMBER;
g_organization_id NUMBER;
g_rule_id NUMBER;
--
-- a constant that stores the \n that works in different natural languages
g_line_feed VARCHAR2(1) := '
';

--whether pjm is enabled or not
g_unit_eff_enabled VARCHAR2(1) := NULL;
--
-- Functions and Procedures
--
-- --------------------------------------------------------------------------
-- What does it do:
-- Fetches picking rule. First from mtl_system_items. If absent there, tries
-- mtl_parameters.
-- --------------------------------------------------------------------------
PROCEDURE get_pick_rule
  ( p_organization_id     IN      NUMBER
   ,p_inventory_item_id   IN      NUMBER
   ,x_rule_id             OUT     NOCOPY NUMBER
   ,x_return_status       OUT     NOCOPY VARCHAR2
   ,x_msg_count           OUT     NOCOPY NUMBER
   ,x_msg_data            OUT     NOCOPY VARCHAR2
   )
  IS
     -- constants
     l_api_name    CONSTANT VARCHAR(30) := 'get_pick_rule';
     --
     l_rule_id  NUMBER;
BEGIN

   x_return_status := fnd_api.g_ret_sts_success ;
   -- find rule from mtl_system_items
   IF ((nvl(g_inventory_item_id,-9999) <> p_inventory_item_id)  OR
         (nvl(g_organization_id,-9999) <> p_organization_id))  THEN
       IF inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) THEN
            g_rule_id := inv_cache.item_rec.picking_rule_id;
       ELSE
            g_rule_id := NULL;
       END IF;
       -- if failed, find rule from mtl_org_parameters
       IF g_rule_id IS NULL THEN
           IF inv_cache.set_org_rec(p_organization_id) THEN
                 g_rule_id := inv_cache.org_rec.default_picking_rule_id;
           ELSE
                 g_rule_id := NULL;
           END IF;
       END IF;
       g_inventory_item_id := p_inventory_item_id;
       g_organization_id := p_organization_id;
   END IF;
   x_rule_id := g_rule_id;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF (fnd_msg_pub.check_msg_level
          (fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      --
END get_pick_rule ;
--
--
-- --------------------------------------------------------------------------
-- What does it do:
-- Determines final location control based on location controls defined at
-- organization, subinventory and item level.
-- --------------------------------------------------------------------------
--
FUNCTION loc_control
  ( p_org_control      IN    NUMBER
   ,p_sub_control      IN    NUMBER
   ,p_item_control     IN    NUMBER DEFAULT NULL
   ,x_return_status    OUT   NOCOPY VARCHAR2
   ,x_msg_count        OUT   NOCOPY NUMBER
   ,x_msg_data         OUT   NOCOPY VARCHAR2
   ) RETURN NUMBER
  IS
      --
      -- constants
      l_api_name        CONSTANT VARCHAR(30) := 'loc_control';
      --
      -- return variable
      l_locator_control NUMBER;
      --
      -- exception
      invalid_loc_control_exception EXCEPTION;
      --
BEGIN
   IF (p_org_control = 1) THEN
       l_locator_control := 1;
    ELSIF (p_org_control = 2) THEN
       l_locator_control := 2;
    ELSIF (p_org_control = 3) THEN
       l_locator_control := 2 ;
    ELSIF (p_org_control = 4) THEN
      IF (p_sub_control = 1) THEN
         l_locator_control := 1;
      ELSIF (p_sub_control = 2) THEN
         l_locator_control := 2;
      ELSIF (p_sub_control = 3) THEN
         l_locator_control := 2;
      ELSIF (p_sub_control = 5) THEN
        IF (p_item_control = 1) THEN
           l_locator_control := 1;
        ELSIF (p_item_control = 2) THEN
           l_locator_control := 2;
        ELSIF (p_item_control = 3) THEN
           l_locator_control := 2;
        ELSIF (p_item_control IS NULL) THEN
           l_locator_control := p_sub_control;
        ELSE
          RAISE invalid_loc_control_exception;
        END IF;
      ELSE
          RAISE invalid_loc_control_exception;
      END IF;
    ELSE
          RAISE invalid_loc_control_exception;
    END IF;
    --
    x_return_status := fnd_api.g_ret_sts_success;
    RETURN l_locator_control;
EXCEPTION
   WHEN invalid_loc_control_exception THEN
      fnd_message.set_name('INV','INV_INVALID_LOC_CONTROL');
      fnd_msg_pub.ADD;
      --
      x_return_status := fnd_api.g_ret_sts_error ;
      l_locator_control := -1 ;
      RETURN l_locator_control ;
      --
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
      l_locator_control := -1 ;
      RETURN l_locator_control ;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        l_locator_control := -1 ;
        RETURN l_locator_control ;
        --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      --
      l_locator_control := -1 ;
      RETURN l_locator_control ;
      --
END loc_control;
--
--
-- --------------------------------------------------------------------------
-- What does it do:
-- Fetches default putaway sub/locations. If the input sub/loc are not null,
-- they are retained as putaway sub/locations
-- --------------------------------------------------------------------------
--
PROCEDURE get_putaway_defaults
  ( p_organization_id           IN  NUMBER,
    p_inventory_item_id         IN  NUMBER,
    p_to_subinventory_code      IN  VARCHAR2,
    p_to_locator_id             IN  NUMBER,
    p_to_cost_group_id		IN  NUMBER,
    p_org_locator_control_code  IN  NUMBER,
    p_item_locator_control_code IN  NUMBER,
    p_transaction_type_id	IN  NUMBER,
    x_putaway_sub          	OUT NOCOPY VARCHAR2,
    x_putaway_loc          	OUT NOCOPY NUMBER,
    x_putaway_cost_group_id    	OUT NOCOPY NUMBER,
    x_return_status        	OUT NOCOPY VARCHAR2,
    x_msg_count            	OUT NOCOPY NUMBER,
    x_msg_data             	OUT NOCOPY VARCHAR2
   )
  IS
     -- constants
     l_api_name          CONSTANT VARCHAR(30) := 'get_putaway_defaults';
     l_return_status     VARCHAR2(1) :=  fnd_api.g_ret_sts_success;
     --
     -- variable
     l_sub_loc_control   NUMBER;
     l_loc_control       NUMBER;
     l_putaway_sub       VARCHAR2(30);
     l_putaway_loc       NUMBER;
     l_putaway_cg	 NUMBER := NULL;
     l_putaway_cg_org	 NUMBER;
     l_inventory_item_id NUMBER;
     l_organization_id   NUMBER;
     l_sub_status	 NUMBER;
     l_loc_status	 NUMBER;
     l_allowed		 VARCHAR2(1);
     l_primary_cost_method NUMBER;
     l_sub_found	 BOOLEAN;
     --
     CURSOR l_subinventory_code_csr IS
        SELECT  subinventory_code
          FROM  mtl_item_sub_defaults
          WHERE inventory_item_id = l_inventory_item_id
            AND organization_id   = l_organization_id
            AND default_type      = 3;  -- default transfer order sub
     --
/*     CURSOR l_sub_status_csr IS
        SELECT  status_id
          FROM  mtl_secondary_inventories
          WHERE secondary_inventory_name = l_putaway_sub
            AND organization_id  = l_organization_id ;
     --
     CURSOR l_locator_type_csr IS
        SELECT  locator_type
          FROM  mtl_secondary_inventories
          WHERE secondary_inventory_name = l_putaway_sub
            AND organization_id  = l_organization_id ;
*/     --
     CURSOR l_locator_status_csr IS
        SELECT  status_id
          FROM  mtl_item_locations
          WHERE inventory_location_id = l_putaway_loc
            AND organization_id  = l_organization_id ;
     --
     CURSOR l_locator_csr IS
        SELECT  locator_id
          FROM  mtl_item_loc_defaults mtld,
                mtl_item_locations mil
          WHERE mtld.locator_id        = mil.inventory_location_id
            AND mtld.organization_id   = mil.organization_id
            AND mtld.inventory_item_id = l_inventory_item_id
            AND mtld.organization_id   = l_organization_id
            AND mtld.subinventory_code = l_putaway_sub
            AND mtld.default_type      = 3
            AND nvl(mil.disable_date,sysdate + 1) > sysdate;

/*     CURSOR l_cost_method IS
	SELECT primary_cost_method
              ,default_cost_group_id
	  FROM mtl_parameters mp
	 WHERE mp.organization_id = p_organization_id;

     CURSOR l_cost_group_csr IS
	SELECT default_cost_group_id
	  FROM mtl_secondary_inventories msi
	 WHERE msi.secondary_inventory_name = l_putaway_sub
           AND msi.organization_id = p_organization_id;
*/

BEGIN
   l_organization_id := p_organization_id;
   l_inventory_item_id := p_inventory_item_id;
   -- search for default sub if to_sub in input row is null
   IF p_to_subinventory_code IS NULL THEN
      OPEN l_subinventory_code_csr;
      FETCH l_subinventory_code_csr INTO l_putaway_sub;
      IF l_subinventory_code_csr%notfound OR
	l_putaway_sub IS NULL  THEN
	 CLOSE l_subinventory_code_csr;
         fnd_message.set_name('INV','INV_NO_DEFAULT_SUB');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE l_subinventory_code_csr;

    ELSE
      l_putaway_sub := p_to_subinventory_code ;
   END IF;

   l_sub_found := INV_CACHE.set_tosub_rec(l_organization_id, l_putaway_sub);
   IF inv_install.adv_inv_installed(NULL) THEN

      IF l_sub_found THEN
	 l_sub_status := INV_CACHE.tosub_rec.status_id;
      ELSE
         l_sub_status := NULL;
      END IF;

      --Bug Number :3457530(cheking for a transaction_type_id also)

      IF l_sub_status IS NOT NULL  AND  p_transaction_type_id <> 64 THEN
         l_allowed := inv_material_status_grp.is_trx_allowed(
		 p_status_id 		=> l_sub_status
		,p_transaction_type_id 	=> p_transaction_type_id
		,x_return_status	=> l_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data);
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error ;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF l_allowed <> 'Y' THEN
	   fnd_message.set_name('INV', 'INV_DETAIL_SUB_STATUS');
	   fnd_msg_pub.add;
	   raise fnd_api.g_exc_error;
         END IF;
      END IF;
   END IF;
   --
   -- now get the locator control and then determine if
   -- default locator needs to be selected from item defaults
   --
   IF NOT l_sub_found THEN
      fnd_message.set_name('INV','INV_NO_SUB_LOC_CONTROL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END if;

   l_sub_loc_control := INV_CACHE.tosub_rec.locator_type;

   -- find out the real locator control
   l_loc_control := loc_control
     ( p_org_locator_control_code
      ,l_sub_loc_control
      ,p_item_locator_control_code
      ,l_return_status
      ,x_msg_count
      ,x_msg_data);
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error ;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   IF l_loc_control = 2 THEN -- has locator control
      -- if no to_loc was supplied then get from defaults
      IF p_to_locator_id IS NULL THEN
         OPEN l_locator_csr;
         FETCH l_locator_csr INTO l_putaway_loc;
         IF l_locator_csr%notfound OR l_putaway_loc IS NULL THEN
            CLOSE l_locator_csr;
            fnd_message.set_name('INV','INV_NO_DEFAULT_LOC');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
       ELSE
         l_putaway_loc := p_to_locator_id ;
      END IF;

      IF inv_install.adv_inv_installed(NULL) THEN

         OPEN l_locator_status_csr;
         FETCH l_locator_status_csr INTO l_loc_status;
         IF l_locator_status_csr%NOTFOUND THEN
            l_loc_status := NULL;
         END IF;
         CLOSE l_locator_status_csr;

         --Bug Number :3457530(cheking for a transaction_type_id also for locator)

         IF l_loc_status IS NOT NULL AND  p_transaction_type_id <> 64 THEN
            l_allowed := inv_material_status_grp.is_trx_allowed(
		                                     p_status_id 		=> l_loc_status
		                                    ,p_transaction_type_id 	=> p_transaction_type_id
	                                       ,x_return_status	=> l_return_status
	                                       ,x_msg_count		=> x_msg_count
	                                       ,x_msg_data		=> x_msg_data);

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error ;
             ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

          IF l_allowed <> 'Y' THEN
	        fnd_message.set_name('INV', 'INV_DETAIL_LOC_STATUS');
	        fnd_msg_pub.add;
	        raise fnd_api.g_exc_error;
          END IF;
         END IF;

       END IF;
   END IF;

   -- Now get the cost group.  If the to_cost_group is specified
   -- on the move order, then use that.  If not, query the default
   -- cost group for the subinventory if in a standard costing org.
   -- If not defined there, or if avg. costing org
   -- try to get the default cost group from the organization
   IF p_to_cost_group_id IS NULL THEN
      IF INV_CACHE.set_org_rec(l_organization_id) THEN
         l_primary_cost_method := INV_CACHE.org_rec.primary_cost_method;
         l_putaway_cg_org := INV_CACHE.org_rec.default_cost_group_id;
      ELSE
	 l_primary_cost_method := 2;
	 l_putaway_cg_org := NULL;
      End If;

      If l_primary_cost_method = 1 Then
	 IF l_sub_found THEN
	    l_putaway_cg := INV_CACHE.tosub_rec.default_cost_group_id;
         ELSE
	    l_putaway_cg := NULL;
         end if;
      End If;

      If l_putaway_cg IS NULL Then
         l_putaway_cg := l_putaway_cg_org;
	 if l_putaway_cg IS NULL then
            fnd_message.set_name('INV','INV_NO_DEFAULT_COST_GROUP');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	 end if;
      End If;
    ELSE
      l_putaway_cg := p_to_cost_group_id;
   END IF;



   x_putaway_sub := l_putaway_sub;
   x_putaway_loc := l_putaway_loc;
   x_putaway_cost_group_id := l_putaway_cg;
   x_return_status := l_return_status;
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error ;
        x_putaway_loc   := NULL;
        x_putaway_sub   := NULL;
        x_putaway_cost_group_id := NULL;
        --
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        x_putaway_loc   := NULL;
        x_putaway_sub   := NULL;
        x_putaway_cost_group_id := NULL;
        --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
        x_putaway_loc   := NULL;
        x_putaway_sub   := NULL;
        x_putaway_cost_group_id := NULL;
        --
        IF (fnd_msg_pub.check_msg_level
            (fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
           fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
--
END get_putaway_defaults ;
--
-- --------------------------------------------------------------------------
-- What does it do:
-- Builds string to filter passed project/task.
-- --------------------------------------------------------------------------
--
PROCEDURE project_where
  ( p_project_id        IN    NUMBER
   ,p_task_id           IN    NUMBER
   ,x_where_clause      OUT   NOCOPY long
   ,x_return_status     OUT   NOCOPY VARCHAR2
   ,x_msg_count         OUT   NOCOPY NUMBER
   ,x_msg_data          OUT   NOCOPY VARCHAR2
   ,p_end_assembly_pegging_code	IN    NUMBER
  ) IS
     --
     -- constants
     l_api_name    CONSTANT VARCHAR(30) := 'project_where';
     --
     l_identifier  VARCHAR2(80);
     l_id2         VARCHAR2(80);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success ;
   --
   --soft pegged always allocates common; hard pegged items allocate
   -- project/task
   IF p_project_id IS NULL AND p_task_id IS NULL
      THEN
      --
      -- no project or task referenced, pick from common inventory only
      --
      x_where_clause := ' AND '||
        ' ((base.locator_id IS NULL) OR '              || g_line_feed ||
        ' (base.locator_id IS NOT NULL AND (EXISTS ( ' || g_line_feed ||
        ' SELECT inventory_location_id '               || g_line_feed ||
        '  FROM  mtl_item_locations '                  || g_line_feed ||
        ' WHERE inventory_location_id = base.locator_id'|| g_line_feed ||
        '   AND organization_id = base.organization_id' || g_line_feed ||
        '    AND project_id IS NULL '                  || g_line_feed ||
        '    AND task_id IS NULL)))) ';
      --
    ELSIF p_end_assembly_pegging_code = 1 THEN
      --
      -- soft pegged item can also pick from common inventory
      --
      IF p_task_id IS NULL THEN
        l_identifier := inv_sql_binding_pvt.initbindvar(p_project_id);
        x_where_clause :=' AND '||
          ' ((base.locator_id IS NOT NULL) AND (EXISTS ( ' || g_line_feed ||
          '  SELECT inventory_location_id '                || g_line_feed ||
          '    FROM mtl_item_locations '                   || g_line_feed ||
          '   WHERE inventory_location_id = base.locator_id ' || g_line_feed ||
          '     AND organization_id = base.organization_id '  || g_line_feed ||
          '     AND nvl(project_id,' || l_identifier  || ') = ' || g_line_feed ||
          l_identifier                                     || g_line_feed ||
          '     AND task_id IS NULL))) ';
      ELSE
        -- referencing project and task, pick only from those locators or common inventory
        --
        l_identifier := inv_sql_binding_pvt.initbindvar(p_project_id);
        l_id2 := inv_sql_binding_pvt.initbindvar(p_task_id);
        x_where_clause :=' AND '||
          ' ((base.locator_id IS NOT NULL) AND (EXISTS ( '|| g_line_feed ||
          '  SELECT inventory_location_id '               || g_line_feed ||
          '  FROM mtl_item_locations '                    || g_line_feed ||
          '  WHERE inventory_location_id = base.locator_id ' || g_line_feed ||
          '  AND organization_id = base.organization_id '    || g_line_feed ||
          '  AND ((project_id = '                           || g_line_feed ||
          l_identifier                                    || g_line_feed ||
          '  AND task_id = '                              || g_line_feed ||
          l_id2                                           || g_line_feed ||
          ') OR (project_id IS NULL '                     || g_line_feed ||
          '  AND task_id IS NUL))'                        || g_line_feed ||
          '))) ';
      END IF;

    ELSIF p_task_id IS NULL THEN
      --
      -- no task referenced, pick from inventory corresponding to this
      -- project only
      --
      l_identifier := inv_sql_binding_pvt.initbindvar(p_project_id);
      x_where_clause :=' AND '||
        ' ((base.locator_id IS NOT NULL) AND (EXISTS ( ' || g_line_feed ||
        '  SELECT inventory_location_id '                || g_line_feed ||
        '    FROM mtl_item_locations '                   || g_line_feed ||
        '   WHERE inventory_location_id = base.locator_id ' || g_line_feed ||
        '     AND organization_id = base.organization_id '  || g_line_feed ||
        '     AND project_id = '                         || g_line_feed ||
        l_identifier                                     || g_line_feed ||
        '     AND task_id IS NULL))) ';
      --
    ELSE
      -- referencing project and task, pick only from those locators
      --
      l_identifier := inv_sql_binding_pvt.initbindvar(p_project_id);
      l_id2 := inv_sql_binding_pvt.initbindvar(p_task_id);
      x_where_clause :=' AND '||
        ' ((base.locator_id IS NOT NULL) AND (EXISTS ( '|| g_line_feed ||
        '  SELECT inventory_location_id '               || g_line_feed ||
        '  FROM mtl_item_locations '                    || g_line_feed ||
        '  WHERE inventory_location_id = base.locator_id ' || g_line_feed ||
        '  AND organization_id = base.organization_id '    || g_line_feed ||
        '  AND project_id = '                           || g_line_feed ||
        l_identifier                                    || g_line_feed ||
        '  AND task_id = '                              || g_line_feed ||
        l_id2                                           || g_line_feed ||
        '))) ';

    END IF;
    --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
      x_where_clause  := NULL;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      x_where_clause  := NULL;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      x_where_clause  := NULL;
      --
      IF (fnd_msg_pub.check_msg_level
          (fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      --
END project_where;
--
--
-- --------------------------------------------------------------------------
-- What does it do:
-- Intelligently builds SQL based on picking rule.
-- --------------------------------------------------------------------------
--
PROCEDURE get_sql_for_rule
  (
   p_rule_id          IN  NUMBER,
   p_pp_temp_rec      IN  g_pp_temp_rec_type,
   p_request_context  IN  inv_detail_util_pvt.g_request_context_rec_type,
   p_request_line_rec IN  inv_detail_util_pvt.g_request_line_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
   )
  IS
     --
     -- constants
     l_api_name       CONSTANT VARCHAR(30) := 'get_sql_for_rule';
     --
     -- Variables
     l_rev_rule       NUMBER ;
     l_lot_rule       NUMBER ;
     l_sub_rule       NUMBER ;
     l_loc_rule       NUMBER ;
     l_is_lot_control BOOLEAN;
     --
     l_return_status  VARCHAR2(1) := fnd_api.g_ret_sts_success;
     --
     l_sub_select     VARCHAR2(3000);
     l_loc_select     VARCHAR2(3000);
     l_rev_where      VARCHAR2(3000);
     l_lot_where      VARCHAR2(3000);
     l_sub_where      VARCHAR2(3000);
     l_loc_where      VARCHAR2(3000);
     l_cg_where       VARCHAR2(3000);
     l_stat_where     VARCHAR2(3000);
     l_rev_group      VARCHAR2(3000);
     l_lot_group      VARCHAR2(3000);
     l_sub_group      VARCHAR2(3000);
     l_loc_group      VARCHAR2(3000);
     l_project_where  long;
     l_from           VARCHAR2(3000);
     l_where          long;
     l_tmp1           VARCHAR2(30);
     l_tmp2           VARCHAR2(30);
     l_tmp3           VARCHAR2(30);
     l_identifier     VARCHAR2(80);
     l_group_by       VARCHAR2(1000);
     l_order_by       VARCHAR2(1000);
     l_pos            NUMBER;
     --bug3094709
     l_pjm_org        NUMBER;
     --
     CURSOR l_rule_csr IS
        SELECT
          revision_rule
          ,lot_rule
          ,subinventory_rule
          ,locator_rule
          FROM mtl_picking_rules
          WHERE picking_rule_id = p_rule_id ;
     --
     l_temp1 long;
     l_temp2 long;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success ;
   l_rev_where := ' ';
   l_lot_where := ' ';
   l_sub_where := ' ';
   l_loc_where := ' ';
   l_cg_where  := ' ';
   l_stat_where:= ' ';
   l_from      := ' ';
   inv_sql_binding_pvt.initbindtables;
   --
   IF p_rule_id IS NOT NULL THEN
     OPEN l_rule_csr;
     FETCH l_rule_csr INTO l_rev_rule, l_lot_rule, l_sub_rule, l_loc_rule;
     IF l_rule_csr%notfound THEN
        CLOSE l_rule_csr;
        fnd_message.set_name('INV','INV_INVALID_PICKING_RULE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
     END IF;
     CLOSE l_rule_csr;
     --
     IF l_rev_rule IS NULL OR l_lot_rule IS NULL  OR
        l_sub_rule IS NULL OR l_loc_rule IS NULL THEN
        fnd_message.set_name('INV','INV_RULE_DEFINITION_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
     END IF;
   ELSE
	l_rev_rule := 0;
	l_lot_rule := 0;
	l_sub_rule := 0;
	l_loc_rule := 0;
   END IF;
   --
   -- Fix for bug #1063622
   -- Items which were under lot control were not being processed correctly,
   -- because this code was formerly comparing the item_revision_control to 2
/*   l_is_lot_control := (p_request_context.item_lot_control_code = 2);
   --
   inv_quantity_tree_pvt.build_sql
     (
       x_return_status       => l_return_status
      ,p_mode                => inv_quantity_tree_pvt.g_transaction_mode
      ,p_is_lot_control      => l_is_lot_control
      ,p_asset_sub_only      => FALSE
      ,p_include_suggestion  => TRUE
      ,p_lot_expiration_date => NULL
      ,x_sql_statement       => g_stmt
      );
*/

   inv_detail_util_pvt.build_sql
     (
       x_return_status => l_return_status
      ,x_sql_statement => g_stmt);
   --
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error ;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   -- replace some hardcoded bind variables
   -- Bug 1384720 - performance improvements
   -- the demand source info no longer in qty tree
   l_identifier := inv_sql_binding_pvt.initbindvar
     (p_request_line_rec.organization_id);
   g_stmt := REPLACE(g_stmt,':organization_id', l_identifier);
   --
   l_identifier := inv_sql_binding_pvt.initbindvar
     (p_request_line_rec.inventory_item_id);
   g_stmt := REPLACE(g_stmt,':inventory_item_id', l_identifier);
   --
   --demand source line id is in sql only if pjm is enabled
   -- (see inv_quantity_tree_pvt.build_cursor)
   /*IF g_unit_eff_enabled IS NULL THEN
      g_unit_eff_enabled := pjm_unit_eff.enabled;
   END IF;
   IF g_unit_eff_enabled = 'Y' THEN
      l_identifier := Inv_sql_binding_pvt.initbindvar
        (p_request_context.txn_line_id);
      g_stmt := REPLACE(g_stmt,':demand_source_line_id', l_identifier);
   END IF;
   --
   */
/*
   l_identifier := inv_sql_binding_pvt.initbindvar
     (p_request_context.transaction_source_type_id);
   g_stmt := REPLACE(g_stmt,':demand_source_type_id', l_identifier);
   --
   l_identifier := inv_sql_binding_pvt.initbindvar
     (p_request_context.txn_header_id);
   g_stmt := REPLACE(g_stmt,':demand_source_header_id',l_identifier);
   --
   l_identifier := Inv_sql_binding_pvt.initbindvar
     (p_request_context.txn_line_detail);
   g_stmt := REPLACE(g_stmt,':demand_source_delivery', l_identifier);
   --
   g_stmt := REPLACE(g_stmt,':demand_source_name', 'NULL');
   --
*/
   IF p_request_context.item_revision_control = 2 THEN
      -- if revision is passed, include it
      IF p_pp_temp_rec.revision IS NOT NULL THEN
         l_identifier := inv_sql_binding_pvt.initbindvar
           (p_pp_temp_rec.revision);
         l_rev_where := g_line_feed
           || ' AND base.revision = '||l_identifier;
      END IF;
   END IF;
   --
   IF p_request_context.item_lot_control_code = 2 THEN
      IF p_pp_temp_rec.lot_number IS NOT NULL THEN
         l_identifier := inv_sql_binding_pvt.initbindvar
           (p_pp_temp_rec.lot_number);
         l_lot_where := l_lot_where
           || g_line_feed || ' AND base.lot_number = '||l_identifier;
      END IF;
      IF p_pp_temp_rec.lot_expiration_date IS NOT NULL THEN
         l_identifier :=
           inv_sql_binding_pvt.initbindvar
           (p_pp_temp_rec.lot_expiration_date);
         l_lot_where := l_lot_where || g_line_feed
           || ' AND (base.lot_expiration_date >= '
           ||l_identifier
           ||' OR base.lot_expiration_date IS NULL ';
      END IF;
   END IF;
   --
   IF p_pp_temp_rec.from_subinventory_code IS NOT NULL THEN
      l_identifier :=
        inv_sql_binding_pvt.initbindvar
        (p_pp_temp_rec.from_subinventory_code);
      l_sub_where := g_line_feed || ' AND base.subinventory_code = '
        ||l_identifier;
   ELSE
      --if sub is null and item is reservable,
      -- we need to make sure that we don't detail from
      -- a nonreservable sub
      if p_request_context.item_reservable_type = 1 then
         l_sub_where:= l_sub_where || g_line_feed ||
		' AND NVL(base.reservable_type,2) = 1';
      end if;
   END IF;
   IF p_pp_temp_rec.from_locator_id IS NOT NULL THEN
      l_identifier := inv_sql_binding_pvt.initbindvar
        (p_pp_temp_rec.from_locator_id);
      l_loc_where := g_line_feed ||' AND base.locator_id = '||l_identifier;
   END IF;
   --
   IF p_pp_temp_rec.from_cost_group_id IS NOT NULL THEN
      l_identifier := inv_sql_binding_pvt.initbindvar
        (p_pp_temp_rec.from_cost_group_id);
      l_cg_where := g_line_feed ||' AND base.cost_group_id = '||l_identifier;
   END IF;
   --
   /* Bug# 3094709: If the move order is of type Issue to Project and the org.
    * is a non-pjm org then pass NULL as project_id and task_id
    */
   select project_reference_enabled
   into l_pjm_org
   from mtl_parameters
   where organization_id = p_request_line_rec.organization_id;

   if(l_pjm_org = 2) then

    project_where
     (
       NULL
      ,NULL
      ,l_project_where
      ,l_return_status
      ,x_msg_count
      ,x_msg_data
      ,p_request_context.end_assembly_pegging_code
      );

   else
    project_where
     (
       p_request_line_rec.project_id
      ,p_request_line_rec.task_id
      ,l_project_where
      ,l_return_status
      ,x_msg_count
      ,x_msg_data
      ,p_request_context.end_assembly_pegging_code
      );
   end if;
   --
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error ;
     ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error ;
   END IF;
   --

   --check status of lot, locator, subinventory if Advanced Inventory
   -- Removed for performance reasons. This check will be done in detail_xfer_or_pick
   -- on each line returned
/*   IF inv_install.adv_inv_installed(NULL) THEN
     l_stat_where:= l_stat_where
       || 'AND inv_detail_util_pvt.is_sub_loc_lot_trx_allowed('
       || p_request_line_rec.transaction_type_id
       || ', base.organization_id, base.inventory_item_id, base.subinventory_code'
       || ', base.locator_id, base.lot_number) = ''Y''';
   END IF;
*/

   -- --------------------------------------------------------
   -- Now make use of the picking rules and sort appropriately
   -- --------------------------------------------------------
   -- Begin: Building SQL based on picking rule
   -- --------------------------------------------------------
   -- First, picking rule pertaining to revision
   -- --------------------------------------------------------
   l_group_by := ' ';
   l_order_by := ' ';
   IF p_request_context.item_revision_control = 2 THEN    -- Revision Controlled
      IF l_rev_rule  = 2 THEN   -- Revision rule
        l_order_by := l_order_by || ',base.revision DESC';
      END IF;
      --
      IF l_rev_rule = 1 THEN  -- Revision or Effective date
         --
         l_from := l_from || ', mtl_item_revisions mir';
         l_rev_where := l_rev_where
           || g_line_feed ||' AND base.inventory_item_id = mir.inventory_item_id '
           || g_line_feed ||' AND base.organization_id   = mir.organization_id '
           || g_line_feed ||' AND base.revision          = mir.revision ';
    --     l_group_by := l_group_by || ',mir.effectivity_date';
         l_order_by := l_order_by || ',mir.effectivity_date';
      END IF;
   END IF;
   -- ---------------------------------------
   -- Second, picking rule pertaining to lot
   -- ---------------------------------------
   IF p_request_context.item_lot_control_code = 2 THEN -- Lot Controlled
      IF l_lot_rule = 1 THEN    -- Expiration date
         l_order_by := l_order_by || ',base.lot_expiration_date asc'; -- lot_expiration_date
      END IF;
      IF l_lot_rule = 2 THEN    -- Receipt Date
         l_order_by := l_order_by || ',base.date_received'; -- date_received
      END IF;
      IF l_lot_rule = 3 THEN    -- Lot Number
         l_order_by := l_order_by || ',base.lot_number '; -- lot_number
      END IF;
   END IF;
   -- ----------------------------------------------
   -- Third, picking rule pertaining to subinventory
   -- ----------------------------------------------
   IF l_sub_rule = 2 THEN    -- Subinventory Picking Order
      l_from := l_from || ',mtl_secondary_inventories msi';
      l_sub_where := l_sub_where
        || g_line_feed
        || ' AND base.subinventory_code = msi.secondary_inventory_name '
        || g_line_feed
        || ' AND base.organization_id   = msi.organization_id';
      --l_group_by := l_group_by || ',msi.picking_order ';
      l_sub_select := ' ,msi.picking_order';
      l_order_by := l_order_by || ',msi.picking_order '; -- msi.picking_order
   END IF;
   IF l_sub_rule = 3 THEN  -- Earliest receipt date
      l_pos := Instr(l_order_by,'base.date_received');
      IF l_pos = 0 THEN
         l_order_by := l_order_by || ',base.date_received'; -- date_received
      END IF;
   END IF;
   -- -------------------------------------------
   -- Fourth, picking rule pertaining to locator
   -- -------------------------------------------
   IF l_loc_rule = 2 THEN     -- Locator Picking Order
      l_from := l_from || ',mtl_item_locations mil';
      l_loc_where := l_loc_where
        || g_line_feed || ' AND base.locator_id      = mil.inventory_location_id(+) '
        || g_line_feed || ' AND base.organization_id = mil.organization_id (+) ';
      l_loc_select := ' , mil.picking_order';
   --   l_group_by := l_group_by || ',mil.picking_order ';
      l_order_by := l_order_by || ',mil.picking_order ';
   END IF;
   IF l_loc_rule = 3 THEN  -- Locator Pick Order/Earliest rcpt.date
      l_pos := Instr(l_order_by,'base.date_received');
      IF l_pos = 0 THEN
         l_order_by := l_order_by || ',base.date_received'; -- date_received
      END IF;
   END IF;
   --
   -- Finalize
   --
   IF l_rev_where = ' ' AND
     l_lot_where = ' ' AND
     l_sub_where = ' ' AND
     l_loc_where = ' ' AND
     l_cg_where  = ' ' AND
     l_stat_where = ' ' AND
     l_project_where = ' ' THEN
      l_tmp1 := ' ';
    ELSE
      l_tmp1 := ' where 1=1 ';
   END IF;
   IF l_order_by = ' ' THEN
      l_tmp3 := ' ';
    ELSE
      l_tmp3 := ' order by ';
      l_order_by := Substr(l_order_by,3); -- skip the first space and the , symbol
   END IF;
   --
    --jaysingh bug #2735447
      l_pos := Instr(l_order_by,'base.date_received');
      IF l_pos = 0 THEN
         IF l_order_by = ' ' THEN
	 	l_order_by := l_order_by || ' order by base.date_received'; -- date_received
	 ELSE
	 	 l_order_by := l_order_by || ' ,base.date_received'; -- date_received
	 END IF;
      END IF;
   --jaysingh

   l_temp1 :=
     ' SELECT base.revision
             ,base.lot_number
             ,base.lot_expiration_date
	     ,base.subinventory_code
             ,base.locator_id
	     ,base.cost_group_id '
     || g_line_feed || ', base.date_received '
     || g_line_feed || ', base.primary_quantity'
     || g_line_feed || l_sub_select || l_loc_select
     || g_line_feed || ' FROM ('||g_stmt||') base '
     || g_line_feed || l_from ;
   --
   l_temp2 := l_tmp1
     || l_rev_where || l_lot_where || l_sub_where || l_loc_where || l_cg_where
     || g_line_feed || l_stat_where  || l_project_where
/*     || g_line_feed || ' HAVING SUM(Decode(x.quantity_type,2,-1,1)*x.primary_quantity) > 0 '
     || g_line_feed || ' GROUP BY x.revision '
     || g_line_feed || '        ,x.lot_number '
     || g_line_feed || '        ,x.lot_expiration_date '
     || g_line_feed || '        ,x.subinventory_code  '
     || g_line_feed || '        ,x.locator_id '
     || g_line_feed || '        ,x.cost_group_id '
     || g_line_feed || '        ,x.date_received '
     || l_group_by */
     || l_tmp3 || l_order_by;
   --
   g_stmt := l_temp1 || l_temp2;
   --   inv_sql_binding_pvt.showsql('>>'||l_temp1);
   --   inv_sql_binding_pvt.showsql('>>'||l_temp2);
   --   inv_sql_binding_pvt.showsql(g_stmt);
   --inv_pp_debug.send_long_to_pipe(g_stmt);
   --
   x_return_status := l_return_status;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF (fnd_msg_pub.check_msg_level
          (fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      --
END get_sql_for_rule ;
--
--
PROCEDURE init_qty_tree
  (x_return_status      OUT NOCOPY VARCHAR2,
   p_request_context    IN  inv_detail_util_pvt.g_request_context_rec_type,
   p_request_line_rec   IN  inv_detail_util_pvt.g_request_line_rec_type,
   x_tree_id            OUT NOCOPY NUMBER,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
   )
  IS
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_api_name VARCHAR2(30) := 'init_qty_tree';
     l_rev_flag BOOLEAN;
     l_lot_flag BOOLEAN;
     l_tree_id  NUMBER;
BEGIN
  -- convert revision/lot control indicators into boolean
  IF p_request_context.item_revision_control = 2 THEN
        l_rev_flag := TRUE;
  ELSE
        l_rev_flag := FALSE;
  END IF;
  --
  IF p_request_context.item_lot_control_code = 2 THEN
        l_lot_flag := TRUE;
  ELSE
        l_lot_flag := FALSE;
  END IF;
  --
  -- create tree
  -- Bug 1890424 - Pass sysdate to create_tree so
  -- expired lots don't appear as available

  inv_quantity_tree_pvt.create_tree
    (
      p_api_version_number        => 1.0
     ,p_init_msg_lst              => fnd_api.g_false
     ,x_return_status             => l_return_status
     ,x_msg_count                 => x_msg_count
     ,x_msg_data                  => x_msg_data
     ,p_organization_id           => p_request_line_rec.organization_id
     ,p_inventory_item_id         => p_request_line_rec.inventory_item_id
     ,p_tree_mode                 => inv_quantity_tree_pvt.g_transaction_mode
     ,p_is_revision_control       => l_rev_flag
     ,p_is_lot_control            => l_lot_flag
     ,p_is_serial_control         => FALSE
     ,p_asset_sub_only            => FALSE
     ,p_include_suggestion        => FALSE
     ,p_demand_source_type_id     => p_request_context.transaction_source_type_id
     ,p_demand_source_header_id   => p_request_context.txn_header_id
     ,p_demand_source_line_id     => p_request_context.txn_line_id
     ,p_demand_source_delivery    => p_request_context.txn_line_detail
     ,p_demand_source_name        => NULL
     ,p_lot_expiration_date       => sysdate
     ,x_tree_id                   => l_tree_id
     ,p_exclusive		  => inv_quantity_tree_pvt.g_exclusive
     ,p_pick_release		  => inv_quantity_tree_pvt.g_pick_release_yes
  );
  --
  IF l_return_status = fnd_api.g_ret_sts_error THEN
    RAISE fnd_api.g_exc_error ;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;
  --
  x_tree_id := l_tree_id;
  x_return_status := l_return_status;
END init_qty_tree;
--
PROCEDURE free_qty_tree (p_tree_id IN NUMBER,x_return_status OUT NOCOPY VARCHAR2)
  IS
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data  VARCHAR2(240);
BEGIN
   -- If tree already exists, free it. This may occur if procedure is
   -- called on multiple occassions within the same session.
   IF 0 > 0 THEN
      inv_quantity_tree_pvt.free_tree
	(
         p_api_version_number  => 1.0
	 ,p_init_msg_lst        => fnd_api.g_false
	 ,x_return_status       => l_return_status
	 ,x_msg_count           => l_msg_count
	 ,x_msg_data            => l_msg_data
	 ,p_tree_id             => 0
	 );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error ;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   --
   x_return_status := l_return_status;
END free_qty_tree;
--
-- --------------------------------------------------------------------------
-- What does it do:
-- Detail a transfer or picking only request record using given pick rule,
-- and save outputs by calling inv_detail_util_pvt.add_output
-- --------------------------------------------------------------------------
--
PROCEDURE detail_xfer_or_pick
  (p_pp_temp_rec      IN   g_pp_temp_rec_type,
   p_request_context  IN   inv_detail_util_pvt.g_request_context_rec_type,
   p_request_line_rec IN   inv_detail_util_pvt.g_request_line_rec_type,
   p_rule_id          IN   NUMBER,
   p_tree_id          IN   NUMBER,
   x_return_status    OUT  NOCOPY VARCHAR2,
   x_msg_count        OUT  NOCOPY NUMBER,
   x_msg_data         OUT  NOCOPY VARCHAR2
   )
  IS
     --
     -- constants
     l_api_name         CONSTANT VARCHAR(30) := 'detail_xfer_or_pick';
     --
     -- Variables
     l_cursor           INTEGER;
     --
     l_revision                 VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number               VARCHAR2(80);
     l_lot_expiration_date      DATE;
     l_from_subinventory        VARCHAR2(10);
     l_from_locator_id          NUMBER;
     l_to_subinventory          VARCHAR2(10);
     l_to_locator_id            NUMBER ;
     l_from_cost_group_id	NUMBER;
     l_to_cost_group_id		NUMBER;
     --
     l_discard                  INTEGER;
     --
     l_index                    NUMBER;
     l_serial_index             NUMBER;
     l_qty_to_detail            NUMBER;
     l_required_sl_qty          NUMBER;
     l_qty_to_update            NUMBER;
     --
     l_tree_id                  INTEGER ;
     l_qoh                      NUMBER ;
     l_rqoh                     NUMBER;
     l_qr                       NUMBER;
     l_qs                       NUMBER;
     l_att                      NUMBER;
     l_atr                      NUMBER;
     --
     l_putaway_sub              VARCHAR2(30);
     l_putaway_loc              NUMBER ;
     l_putaway_cg               NUMBER ;
     --
     use_this_row               BOOLEAN;
     --
     l_rev_flag                 BOOLEAN;
     l_lot_flag                 BOOLEAN;
     --
     l_output_serial_rows       INV_DETAIL_UTIL_PVT.g_serial_row_table;
     l_output_process_rec       inv_detail_util_pvt.g_output_process_rec_type;
     --
     l_serial_number            VARCHAR2(30);

     l_from_sub_rec		MTL_SECONDARY_INVENTORIES%ROWTYPE;
     l_to_sub_rec		MTL_SECONDARY_INVENTORIES%ROWTYPE;
     l_org_rec			MTL_PARAMETERS%ROWTYPE;
     l_item_rec			MTL_SYSTEM_ITEMS%ROWTYPE;
     l_ret_value		NUMBER;
     l_move_order_type		NUMBER;
     --Bug Number 3449739
     l_indivisible_flag         VARCHAR2(10) := 'N';
      l_att_om_indivisible       NUMBER;

/*     CURSOR l_from_sub_cursor IS
	SELECT *
	  FROM MTL_SECONDARY_INVENTORIES
	 WHERE secondary_inventory_name = l_from_subinventory
	   AND organization_id = p_request_line_rec.organization_id;

     CURSOR l_to_sub_cursor IS
	SELECT *
	  FROM MTL_SECONDARY_INVENTORIES
	 WHERE secondary_inventory_name = l_to_subinventory
	   AND organization_id = p_request_line_rec.organization_id;

     CURSOR l_org_cursor IS
	SELECT *
	  FROM MTL_PARAMETERS
	 WHERE organization_id = p_request_line_rec.organization_id;

     CURSOR l_item_cursor IS
	SELECT *
	  FROM MTL_SYSTEM_ITEMS
	 WHERE inventory_item_id = p_request_line_rec.inventory_item_id
	   AND organization_id = p_request_line_rec.organization_id;

     CURSOR c_move_order_type IS
        SELECT move_order_type
	  FROM mtl_txn_request_headers
	 WHERE header_id = p_request_line_rec.header_id;
*/

BEGIN
  x_return_status := fnd_api.g_ret_sts_success ;
  --
  --inv_sql_binding_pvt.showsql(g_stmt);
  l_cursor := dbms_sql.open_cursor ;
  dbms_sql.parse(l_cursor, g_stmt, dbms_sql.v7);
  -- bind input variables
  inv_sql_binding_pvt.bindvars(l_cursor);
  -- now define the output variables
  dbms_sql.define_column(l_cursor, 1, l_revision, 3);
  dbms_sql.define_column(l_cursor, 2, l_lot_number, 30);
  dbms_sql.define_column(l_cursor, 3, l_lot_expiration_date);
  dbms_sql.define_column(l_cursor, 4, l_from_subinventory, 10);
  dbms_sql.define_column(l_cursor, 5, l_from_locator_id);
  dbms_sql.define_column(l_cursor, 6, l_from_cost_group_id);
  --
  l_discard := dbms_sql.execute(l_cursor);
  --
  -- set the qty that has to be detailed
  l_qty_to_detail := p_pp_temp_rec.primary_quantity ;
  --
  IF p_request_context.transfer_flag THEN
    get_putaway_defaults ( p_request_line_rec.organization_id,
			   p_request_line_rec.inventory_item_id,
			   p_pp_temp_rec.to_subinventory_code,
			   p_pp_temp_rec.to_locator_id,
			   p_pp_temp_rec.to_cost_group_id,
			   p_request_context.org_locator_control_code,
			   p_request_context.item_locator_control_code,
			   p_request_line_rec.transaction_type_id,
			   l_putaway_sub ,
			   l_putaway_loc,
			   l_putaway_cg,
			   x_return_status,
			   x_msg_count,
			   x_msg_data
			   );
    --
    IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error ;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;
  --
  l_to_subinventory := l_putaway_sub;
  l_to_locator_id   := l_putaway_loc;
  l_to_cost_group_id:= l_putaway_cg;

  /* Use cached record instead of c_move_order_type cursor */
  IF inv_cache.set_mtrh_rec(p_request_line_rec.header_id) THEN
     l_move_order_type := NVL(inv_cache.mtrh_rec.move_order_type, 1);
  ELSE
     l_move_order_type := 1;
  END IF;

  --
  --Bug 3449739

  IF l_move_order_type = 3 THEN   --Pick Wave move orders

     IF ( inv_cache.set_item_rec(p_request_line_rec.organization_id, p_request_line_rec.inventory_item_id) ) THEN
         l_indivisible_flag := nvl(inv_cache.item_rec.indivisible_flag,'N');
     END IF;
     IF (l_indivisible_flag = 'Y') THEN
         l_qty_to_detail := floor(l_qty_to_detail);
         --inv_pick_wave_pick_confirm_pub.tracelog('l_qty_to_detail = '||l_qty_to_detail, 'INVRSV4B');
     END IF;
  END IF;

  LOOP
     -- when no more rows to fetch, then exit
     --
     IF dbms_sql.fetch_rows(l_cursor) = 0 THEN
        EXIT ;
     END IF;
     --
     -- now retrieve the rows one at a time
     --
     dbms_sql.column_value(l_cursor, 1, l_revision);
     dbms_sql.column_value(l_cursor, 2, l_lot_number);
     dbms_sql.column_value(l_cursor, 3, l_lot_expiration_date);
     dbms_sql.column_value(l_cursor, 4, l_from_subinventory);
     dbms_sql.column_value(l_cursor, 5, l_from_locator_id);
     dbms_sql.column_value(l_cursor, 6, l_from_cost_group_id);
     --
     -- Some initializations
     --
     use_this_row      := true;
     --
     -- Check to determine if this transaction is allowed for lot and locator
     IF inv_detail_util_pvt.is_sub_loc_lot_trx_allowed(p_request_line_rec.transaction_type_id, p_request_line_rec.organization_id, p_request_line_rec.inventory_item_id, l_from_subinventory, l_from_locator_id, l_lot_number) <> 'Y' THEN
 	use_this_row := FALSE;
     END IF;

     -- make sure that if this is a non-pick wave move order, that
     -- we don't pick from the destination sub
     IF  l_move_order_type <> 3 AND
          p_request_context.transfer_flag AND
         l_from_subinventory = l_to_subinventory AND
        (l_from_locator_id = l_to_locator_id OR
 	l_from_locator_id IS NULL AND
 	l_to_locator_id IS NULL)  AND
        use_this_row THEN
 	use_this_row := FALSE;
     END IF;

     -- Check to make sure transfer is allowed between from sub and to sub
     --  calls validation API's, which checks whether the from sub is
     --- asset or expense, and if expense to asset transfers are allowed.
     IF p_request_context.transfer_flag AND use_this_row THEN

      -- First, get the line for from sub and to sub
        IF NOT (inv_cache.set_fromsub_rec(p_request_line_rec.organization_id, l_from_subinventory)) THEN
           fnd_message.set_name('INV', 'INV_VALIDATE_SUB_FAILED');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF NOT (inv_cache.set_tosub_rec(p_request_line_rec.organization_id, l_to_subinventory)) THEN
           fnd_message.set_name('INV', 'INV_VALIDATE_SUB_FAILED');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF NOT (inv_cache.set_org_rec(p_request_line_rec.organization_id)) THEN
           fnd_message.set_name('INV', 'INV_VALIDATE_SUB_FAILED');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        IF NOT (inv_cache.set_item_rec(p_request_line_rec.organization_id, p_request_line_rec.inventory_item_id)) THEN
           fnd_message.set_name('INV', 'INV_VALIDATE_SUB_FAILED');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- then, call api
        l_ret_value := INV_VALIDATE.To_Subinventory(
                 p_sub          => inv_cache.tosub_rec
                ,p_org          => inv_cache.org_rec
                ,p_item         => inv_cache.item_rec
                ,p_from_sub     => inv_cache.fromsub_rec
                ,p_acct_txn     => 0);
        -- If return 0, don't use the from sub
        IF l_ret_value = 0 THEN
                use_this_row := FALSE;
        END IF;

     END IF;
     --
     IF use_this_row THEN
        -- now call quantity tree to validate that there is enough quantity
        -- at this SKU
        --
        -- Query Tree
	-- Bug 1349981 - no longer passing in cost group when querying
	-- the quantity tree.  It works out okay, since only one cg per
  	-- subinventory
        inv_quantity_tree_pvt.query_tree
          (
            p_api_version_number  => 1.0
           ,p_init_msg_lst        => NULL
           ,x_return_status       => x_return_status
           ,x_msg_count           => x_msg_count
           ,x_msg_data            => x_msg_data
           ,p_tree_id             => p_tree_id
           ,p_revision            => l_revision
           ,p_lot_number          => l_lot_number
           ,p_subinventory_code   => l_from_subinventory
           ,p_locator_id          => l_from_locator_id
           ,x_qoh                 => l_qoh
           ,x_rqoh                => l_rqoh
           ,x_qr                  => l_qr
           ,x_qs                  => l_qs
           ,x_att                 => l_att
           ,x_atr                 => l_atr
	   ,p_transfer_subinventory_code => NULL
	   ,p_cost_group_id	  => NULL
           );
        IF x_return_status = fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error ;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        --
        --
        -- now compare the available qty against the needed qty and
        -- decrement the needed qty appropriately. then update the tree
        --
        IF l_att > 0 THEN
	   IF l_att >= l_qty_to_detail THEN
	      l_qty_to_update := l_qty_to_detail;
      ELSE
       --Bug Number 3449739
	     IF (l_move_order_type = 3 and l_indivisible_flag = 'Y') THEN
         l_att_om_indivisible := floor(l_att);
         l_qty_to_update      := l_att_om_indivisible;
         --inv_pick_wave_pick_confirm_pub.tracelog('l_att_om_indivisible = '||l_att_om_indivisible, 'INVRSV4B');
        ELSE
          l_qty_to_update := l_att;
        END IF;
	   END IF;
	   l_required_sl_qty  := l_qty_to_update;

           --
           -- If serial controlled, fetch serial nos
           -- for the autodetailed row. They are loaded into g_output_serial_rows.
           -- Changed 7/12/00 so all validation for calling this function
           -- is in INVVDEUB.pls
	   l_serial_index := NULL;

           IF p_request_context.detail_serial THEN
              inv_detail_util_pvt.get_serial_numbers (
                p_inventory_item_id       => p_request_line_rec.inventory_item_id
              , p_organization_id         => p_request_line_rec.organization_id
              , p_revision                => l_revision
              , p_lot_number              => l_lot_number
              , p_subinventory_code       => l_from_subinventory
              , p_locator_id              => l_from_locator_id
              , p_required_sl_qty         => l_required_sl_qty
              , p_from_range              => p_request_line_rec.serial_number_start
              , p_to_range                => p_request_line_rec.serial_number_end
  		        , p_unit_number	            => p_request_line_rec.unit_number
		          , p_detail_any_serial       => p_request_context.detail_any_serial
		          , p_cost_group_id           => l_from_cost_group_id
		          , p_transaction_type_id     => p_request_line_rec.transaction_type_id
              , x_available_sl_qty        => l_qty_to_update
              , x_serial_index            => l_serial_index
              , x_return_status           => x_return_status
              , x_msg_count               => x_msg_count
              , x_msg_data                => x_msg_data
              , p_demand_source_type_id   => p_request_line_rec.transaction_source_type_id
              , p_demand_source_header_id => p_request_line_rec.transaction_header_id
              , p_demand_source_line_id   => p_request_line_rec.txn_source_line_id );

              IF x_return_status = fnd_api.g_ret_sts_error THEN
                 RAISE fnd_api.g_exc_error ;
               ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

	   END IF;
	   IF l_qty_to_update > 0 THEN
	      inv_quantity_tree_pvt.update_quantities
		(
		 p_api_version_number => 1
		 ,p_init_msg_lst       => fnd_api.g_false
		 ,x_return_status      => x_return_status
		 ,x_msg_count          => x_msg_count
		 ,x_msg_data           => x_msg_data
		 ,p_tree_id            => p_tree_id
		 ,p_revision           => l_revision
		 ,p_lot_number         => l_lot_number
		 ,p_subinventory_code  => l_from_subinventory
		 ,p_locator_id         => l_from_locator_id
		 ,p_primary_quantity   => l_qty_to_update
		 ,p_quantity_type      => inv_quantity_tree_pvt.g_qs_txn
		 ,x_qoh                => l_qoh
		 ,x_rqoh               => l_rqoh
		 ,x_qr                 => l_qr
		 ,x_qs                 => l_qs
		 ,x_att                => l_att
		 ,x_atr                => l_atr
	         ,p_cost_group_id      => l_from_cost_group_id
		 ) ;
	      --
	      IF x_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error ;
	       ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	      -- ok, lets add to the output process table for output
	      -- generation later
	      l_output_process_rec.revision := l_revision;
	      l_output_process_rec.from_subinventory_code := l_from_subinventory;
	      l_output_process_rec.from_locator_id := l_from_locator_id;
	      l_output_process_rec.to_subinventory_code := l_to_subinventory;
	      l_output_process_rec.to_locator_id := l_to_locator_id;
	      l_output_process_rec.from_cost_group_id := l_from_cost_group_id;
	      l_output_process_rec.to_cost_group_id := l_to_cost_group_id;
	      l_output_process_rec.lot_number := l_lot_number;
	      l_output_process_rec.lot_expiration_date := l_lot_expiration_date;
	      l_output_process_rec.pick_rule_id := p_rule_id;
	      l_output_process_rec.put_away_rule_id := NULL;
	      l_output_process_rec.reservation_id := p_pp_temp_rec.reservation_id;
	      IF  l_serial_index IS NOT NULL THEN -- has serial numbers detailed
                    l_output_process_rec.primary_quantity := 1;
                    l_output_process_rec.transaction_quantity :=
                      inv_convert.inv_um_convert
                      (
                       p_request_line_rec.inventory_item_id,
                       NULL,
                       1,
                       p_request_context.primary_uom_code,
                       p_request_context.transaction_uom_code,
                       NULL,
                       NULL);
		    FOR l_loop_index IN 1..l_qty_to_update LOOP
		       l_serial_number :=
			 inv_detail_util_pvt.g_output_serial_rows
			 (l_loop_index+l_serial_index-1).serial_number;
		       l_output_process_rec.serial_number_start := l_serial_number;
		       l_output_process_rec.serial_number_end := l_serial_number;
		       -- add it to the output process table for processing later
		       inv_detail_util_pvt.add_output(l_output_process_rec);
		    END LOOP;
	       ELSE
		 l_output_process_rec.primary_quantity := l_qty_to_update;
		 l_output_process_rec.transaction_quantity :=
		   inv_convert.inv_um_convert
		   (
		    p_request_line_rec.inventory_item_id,
		    NULL,
		    l_qty_to_update,
		    p_request_context.primary_uom_code,
		    p_request_context.transaction_uom_code,
		    NULL,
		    NULL);
		 l_output_process_rec.serial_number_start := NULL;
		 l_output_process_rec.serial_number_end := NULL;
		 inv_detail_util_pvt.add_output(l_output_process_rec);
	      END IF;
	      -- update the quantity remained to detail
	      l_qty_to_detail := l_qty_to_detail - l_qty_to_update;
	      --
	   END IF;         -- (l_qty_to_update > 0) --
	END IF;            -- (l_att > 0 )          --
     END IF;               -- (use_this_rowu)       --
     EXIT WHEN l_qty_to_detail = 0;
  END LOOP;
  --
  -- close cursor now
  dbms_sql.close_cursor(l_cursor);
  --
  --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error ;
        DBMS_SQL.CLOSE_CURSOR(l_cursor);
        --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
      --
   WHEN OTHERS THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF (fnd_msg_pub.check_msg_level
          (fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      --
END detail_xfer_or_pick;
--
PROCEDURE detail_putaway_only
  (p_request_line_rec inv_detail_util_pvt.g_request_line_rec_type,
   p_request_context  IN inv_detail_util_pvt.g_request_context_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER ,
   x_msg_data         OUT NOCOPY VARCHAR2
   )
  IS
     l_api_name         CONSTANT VARCHAR(30) := 'detail_subtransfer';
     l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_putaway_sub      VARCHAR2(30);
     l_putaway_loc      NUMBER;
     l_putaway_cg      NUMBER;
     l_output_process_rec inv_detail_util_pvt.g_output_process_rec_type;
BEGIN
   get_putaway_defaults ( p_request_line_rec.organization_id,
			  p_request_line_rec.inventory_item_id,
			  p_request_line_rec.to_subinventory_code,
			  p_request_line_rec.to_locator_id,
			  p_request_line_rec.to_cost_group_id,
			  p_request_context.org_locator_control_code,
			  p_request_context.item_locator_control_code,
			  p_request_line_rec.transaction_type_id,
			  l_putaway_sub ,
			  l_putaway_loc,
			  l_putaway_cg,
			  l_return_status,
			  x_msg_count,
			  x_msg_data
			  );
    --
    IF l_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error ;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    --
    l_output_process_rec.revision := p_request_line_rec.revision;
    l_output_process_rec.to_subinventory_code := l_putaway_sub;
    l_output_process_rec.to_locator_id := l_putaway_loc;
    l_output_process_rec.to_cost_group_id := l_putaway_cg;
    l_output_process_rec.lot_number := p_request_line_rec.lot_number;
    l_output_process_rec.lot_expiration_date :=
      p_request_context.lot_expiration_date;
    l_output_process_rec.serial_number_start :=
      p_request_line_rec.serial_number_start;
    l_output_process_rec.serial_number_end :=
      p_request_line_rec.serial_number_end;
    l_output_process_rec.primary_quantity :=
      p_request_line_rec.primary_quantity;
    l_output_process_rec.transaction_quantity :=
      p_request_line_rec.quantity - p_request_line_rec.quantity_detailed;
    l_output_process_rec.pick_rule_id := NULL;
    l_output_process_rec.put_away_rule_id := NULL;
    l_output_process_rec.reservation_id := NULL;
    -- add it to the output process table for processing later
    inv_detail_util_pvt.add_output(l_output_process_rec);
    --
    x_return_status := l_return_status;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      --
END detail_putaway_only;

--
-- --------------------------------------------------------------------------
-- What does it do:
-- detailing picking and put away locations and generate output into
-- transactions temporary tables (mtl_material_transactions_temp, etc.)
-- --------------------------------------------------------------------------
--
PROCEDURE detail_request
  (p_request_context  IN inv_detail_util_pvt.g_request_context_rec_type,
   p_request_line_rec IN inv_detail_util_pvt.g_request_line_rec_type,
   p_reservations     IN inv_reservation_global.mtl_reservation_tbl_type,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER ,
   x_msg_data         OUT NOCOPY VARCHAR2
  ) IS
     l_api_name         CONSTANT VARCHAR(30) := 'detail_subtransfer';
     l_rule_id          NUMBER;
     l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_pp_temp_tbl      g_pp_temp_tbl_type;
     l_pp_temp_tbl_size NUMBER;
     l_detail_level_tbl inv_detail_util_pvt.g_detail_level_tbl_type;
     l_detail_level_tbl_size NUMBER;
     l_tree_id          NUMBER;
     l_remaining_quantity NUMBER;
BEGIN
   -- init the output process table
   inv_detail_util_pvt.init_output_process_tbl;
   IF p_request_context.transfer_flag OR
     p_request_context.type_code = 2 THEN -- pick only or transfer
      inv_detail_util_pvt.compute_pick_detail_level
	(l_return_status         ,
	 p_request_line_rec      ,
	 p_request_context       ,
	 p_reservations          ,
	 l_detail_level_tbl      ,
	 l_detail_level_tbl_size ,
         l_remaining_quantity
	 );
      -- copy the revision, lot, etc., to the temporary table
      -- to be worked on later
      FOR l_index IN 1..l_detail_level_tbl_size LOOP
	 l_pp_temp_tbl(l_index).revision :=
	   l_detail_level_tbl(l_index).revision;
	 l_pp_temp_tbl(l_index).lot_number :=
	   l_detail_level_tbl(l_index).lot_number;
	 l_pp_temp_tbl(l_index).from_subinventory_code :=
	   l_detail_level_tbl(l_index).subinventory_code;
	 l_pp_temp_tbl(l_index).from_locator_id :=
	   l_detail_level_tbl(l_index).locator_id;
	 l_pp_temp_tbl(l_index).to_subinventory_code :=
	   p_request_line_rec.to_subinventory_code;
	 l_pp_temp_tbl(l_index).to_locator_id :=
	   p_request_line_rec.to_locator_id;
	 l_pp_temp_tbl(l_index).primary_quantity :=
	   l_detail_level_tbl(l_index).primary_quantity;
	 l_pp_temp_tbl(l_index).transaction_quantity :=
	   l_detail_level_tbl(l_index).transaction_quantity;
	 l_pp_temp_tbl(l_index).reservation_id :=
	   l_detail_level_tbl(l_index).reservation_id;
	 l_pp_temp_tbl(l_index).from_cost_group_id :=
	   p_request_line_rec.from_cost_group_id;
	 l_pp_temp_tbl(l_index).to_cost_group_id :=
	   p_request_line_rec.to_cost_group_id;
      END LOOP;
      l_pp_temp_tbl_size := l_detail_level_tbl_size;
      --
      -- get the pick rule at item or org level
      --
      get_pick_rule (p_request_line_rec.organization_id,
		     p_request_line_rec.inventory_item_id,
		     l_rule_id,
		     l_return_status    ,
		     x_msg_count        ,
		     x_msg_data
		     );
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error ;
       ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error ;
      END IF;
      init_qty_tree(l_return_status,
		    p_request_context,
		    p_request_line_rec,
		    l_tree_id,
		    x_msg_count,
		    x_msg_data
		    );
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error ;
       ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error ;
      END IF;
      -- detail individual records
      FOR l_index IN 1..l_pp_temp_tbl_size LOOP
	 --
	 -- Using the picking rules, build the SQL dynamically
	 --
	 get_sql_for_rule(l_rule_id,
			  l_pp_temp_tbl(l_index) ,
			  p_request_context,
			  p_request_line_rec,
			  l_return_status,
			  x_msg_count,
			  x_msg_data
		       );
	 --
	 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	    RAISE fnd_api.g_exc_unexpected_error ;
	  ELSIF  l_return_status = fnd_api.g_ret_sts_error THEN
	    RAISE fnd_api.g_exc_error ;
	 END IF;
	 --
	 -- detailing by execute the picking sql to find pick location
	 -- and find out put away locations for transfer
	 --
	 detail_xfer_or_pick( l_pp_temp_tbl(l_index),
			      p_request_context,
			      p_request_line_rec,
			      l_rule_id,
			      l_tree_id,
			      l_return_status,
			      x_msg_count,
			      x_msg_data
			      );
	 IF l_return_status = fnd_api.g_ret_sts_error THEN
	    RAISE fnd_api.g_exc_error ;
	  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      END LOOP;
      -- free the quantity tree after inserting output records
      -- Bug 1384720  - performance improvements
      -- No need to free tree; save it for other queries
/*
      inv_quantity_tree_pvt.free_tree
	(
         p_api_version_number  => 1.0
	 ,p_init_msg_lst        => fnd_api.g_false
	 ,x_return_status       => l_return_status
	 ,x_msg_count           => x_msg_count
	 ,x_msg_data            => x_msg_data
	 ,p_tree_id             => l_tree_id
	 );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error ;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/
    ELSE
     detail_putaway_only (p_request_line_rec ,
			  p_request_context,
			  l_return_status ,
			  x_msg_count ,
			  x_msg_data
			  );
   END IF;
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error ;
    ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
      raise fnd_api.g_exc_error ;
   END IF;
   -- if no locations has been found, lets report error
   IF inv_detail_util_pvt.g_output_process_tbl.COUNT = 0 THEN
      --edited out called to fnd_message by jcearley, 12/2/99
      --fnd_message.set_name('INV','INV_SUGGESTION_FAILED');
      -- Suggestions not or only partially created through applying strategy
      --fnd_msg_pub.add;
      --RAISE fnd_api.g_exc_error;
      RETURN; -- do not raise exeception since it is not an error if can't find qty
   END IF;
   -- now we can generate records into transactions temp tables
   inv_detail_util_pvt.process_output(l_return_status,
				      p_request_line_rec,
				      p_request_context
				      );
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error ;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   x_return_status := l_return_status;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      --
END detail_request;
--
-- Description
--   Create transaction suggestions api based on rules in mtl_picking_rules.
--
--   The output of this procedure is records in mtl_material_transactions_temp
--   , mtl_transaction_lots_temp, and mtl_serial_numbers_temp.
--
-- Notes
--   1. Integration with reservations
--      If table p_reservations passed by the calling is not empty, the
--      engine will detailing based on a combination of the info in the
--      move order line (the record that represents detailing request),
--      and the info in p_reservations. For example, a sales order line
--      can have two reservations, one for revision A in quantity of 10,
--      and one for revision B in quantity of 5, and the line quantity
--      can be 15; so when the pick release api calls the engine
--      p_reservations will have two records of the reservations. So
--      if the move order line based on the sales order line does not
--      specify a revision, the engine will merge the information from
--      move order line and p_reservations to create the input for
--      detailing as two records, one for revision A, and one for revision
--      B. Please see documentation for the pick release API for more
--      details.
--
--  2.  Serial Number Detailing in Picking
--      Currently the serial number detailing is quite simple. If the caller
--      gives a range (start, and end) serial numbers in the move order line
--      and pass p_suggest_serial as fnd_api.true, the engine will filter
--      the locations found from a rule, and suggest unused serial numbers
--      in the locator. If p_suggest_serial is passed as fnd_api.g_false
--      (default), the engine will not give serial numbers in the output.
--
-- Input Parameters
--   p_api_version_number   standard input parameter
--   p_init_msg_lst         standard input parameter
--   p_commit               standard input parameter
--   p_validation_level     standard input parameter
--   p_transaction_temp_id  equals to the move order line id
--                          for the detailing request
--   p_reservations         reservations for the demand source
--                          as the transaction source
--                          in the move order line.
--   p_suggest_serial       whether or not the engine should suggest
--                          serial numbers in the detailing
--
-- Output Parameters
--   x_return_status        standard output parameters
--   x_msg_count            standard output parameters
--   x_msg_data             standard output parameters
--
PROCEDURE create_suggestions
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_validation_level      IN  NUMBER   DEFAULT fnd_api.g_valid_level_none,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_transaction_temp_id   IN  NUMBER,
   p_reservations          IN  inv_reservation_global.mtl_reservation_tbl_type,
   p_suggest_serial        IN  VARCHAR2 DEFAULT fnd_api.g_false
   ) IS
      --
      -- constants
      l_api_name              CONSTANT VARCHAR(30) := 'create_suggestions';
      c_api_version_number    CONSTANT NUMBER      := 1.0;
      l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success ;
      l_request_context       inv_detail_util_pvt.g_request_context_rec_type;
      l_request_line_rec      inv_detail_util_pvt.g_request_line_rec_type;
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT create_suggestions_sa;
   --
   --Standard compatibility check
   IF NOT fnd_api.compatible_api_call(
                                      c_api_version_number
                                      , p_api_version
                                      , l_api_name
                                      , g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   -- Initialize message list
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;
   --
   x_return_status := fnd_api.g_ret_sts_success ;
   --
   -- validate input and initialize
   inv_detail_util_pvt.validate_and_init
     (l_return_status       ,
      p_transaction_temp_id ,
      p_suggest_serial      ,
      l_request_line_rec    ,
      l_request_context
      );
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --don't detail serial numbers for items that are serial controlled only
   -- at sales order issue
   IF l_request_context.item_serial_control_code = 6 THEN
     l_request_context.item_serial_control_code := 1;
   END IF;
   --
   detail_request (l_request_context  ,
		   l_request_line_rec,
		   p_reservations    ,
		   l_return_status   ,
		   x_msg_count       ,
		   x_msg_data
		   );
   IF  (l_return_status = fnd_api.g_ret_sts_unexp_error ) THEN
      RAISE fnd_api.g_exc_unexpected_error ;
    ELSIF ( l_return_status = fnd_api.g_ret_sts_error ) THEN
      RAISE fnd_api.g_exc_error ;
   END IF;
   --
   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   --
   --
   x_return_status := l_return_status;
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      ROLLBACK TO create_suggestions_sa;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.Count_And_Get
        ( p_count => x_msg_count
         ,p_data => x_msg_data);
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      ROLLBACK TO create_suggestions_sa;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.Count_And_Get
        ( p_count => x_msg_count
         ,p_data => x_msg_data);
      --
   WHEN OTHERS THEN
      --
      -- debugging section
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
         -- Note: in debug mode, later call to fnd_msg_pub.get will not get
         -- the message retrieved here since it is no longer on the stack
         inv_pp_debug.set_last_error_message(Sqlerrm);
         inv_pp_debug.send_message_to_pipe('exception in '||l_api_name);
         inv_pp_debug.send_last_error_message;
      END IF;
      -- end of debugging section
      --
      ROLLBACK TO create_suggestions_sa;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.Add_Exc_Msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
        ( p_count => x_msg_count
         ,p_data => x_msg_data);
END create_suggestions;
END INV_AUTODETAIL;

/
