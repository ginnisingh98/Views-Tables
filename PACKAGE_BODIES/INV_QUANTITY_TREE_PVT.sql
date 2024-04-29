--------------------------------------------------------
--  DDL for Package Body INV_QUANTITY_TREE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_QUANTITY_TREE_PVT" as
/* $Header: INVVQTTB.pls 120.27.12010000.23 2010/02/25 13:31:46 mporecha ship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_Quantity_Tree_PVT';
g_is_lot_control  BOOLEAN := FALSE;

--
-- synonyms used in this program
--     qoh          quantity on hand
--     rqoh         reservable quantity on hand
--     qr           quantity reserved
--     att          available to transact
--     atr          available to reserve

--    sqoh          secondary quantity on hand
--    srqoh         secondary reservable quantity on hand
--    sqr           secondary quantity reserved
--    satt          secondary available to transact
--    satr          secondary available to reserve
--------------------------------------------------
-- Data Types Definition
--------------------------------------------------
-- rootinfo_rec_type is the record type for a
-- record that points to a tree
TYPE rootinfo_rec_type IS RECORD
  (   organization_id          NUMBER
   ,  inventory_item_id        NUMBER
   ,  is_DUOM_control          BOOLEAN
   ,  is_revision_control      BOOLEAN
   ,  is_lot_control           BOOLEAN
   ,  is_serial_control        BOOLEAN
   ,  is_lot_status_enabled    BOOLEAN
   ,  neg_inv_allowed          BOOLEAN
   ,  tree_mode                NUMBER
   ,  include_suggestion       BOOLEAN
   ,  asset_sub_only           BOOLEAN
   ,  demand_source_type_id    NUMBER
   ,  demand_source_header_id  NUMBER
   ,  demand_source_line_id    NUMBER
   ,  demand_source_name       VARCHAR2(30)
   ,  demand_source_delivery   NUMBER
   ,  asset_inventory_only     BOOLEAN
   ,  lot_expiration_date      DATE
   ,  grade_code               VARCHAR2(150)
   ,  need_refresh             BOOLEAN
   ,  item_node_index          INTEGER
   ,  onhand_source            NUMBER
   ,  pick_release             NUMBER
   ,  hash_string              VARCHAR2(1000)
   ,  unit_effective           NUMBER
   ,  onhand_status_enabled    BOOLEAN              -- Bug 9150005
   );
--
TYPE rootinfo_tbl_type IS TABLE OF rootinfo_rec_type
  INDEX BY BINARY_INTEGER;
--
-- tree level constants
g_item_level       CONSTANT INTEGER := 1;
g_revision_level   CONSTANT INTEGER := 2;
g_lot_level        CONSTANT INTEGER := 3;
g_sub_level        CONSTANT INTEGER := 4;
g_locator_level    CONSTANT INTEGER := 5;
g_lpn_level        CONSTANT INTEGER := 6;
g_cost_group_level CONSTANT INTEGER := 7;
--

-- node_rec_type is the record type for
-- a tree node. It contains a superset of
-- attributes for revision,
-- invConv change : is_reservable_sub is NOW used as reservable flag for
--            each subinv, locator, lot, serial.
-- invConv note : this rec_type is not used anymore.
TYPE node_rec_type IS RECORD
  (   node_level          INTEGER      -- qualifies the type of the node
   ,  revision            VARCHAR2(3)  -- valid if the node is a revision node
   ,  lot_number          VARCHAR2(80) -- valid if the node is a lot node     (size)
   ,  subinventory_code   VARCHAR2(10) -- valid if the node is a sub node
   ,  is_reservable_sub   BOOLEAN      -- valid if the node is reservable    (comment)
   ,  locator_id          NUMBER       -- valid if the node is a locator node
   ,  qoh                 NUMBER
   ,  rqoh                NUMBER
   ,  qr                  NUMBER
   ,  qs                  NUMBER
   ,  att                 NUMBER
   ,  atr                 NUMBER
   ,  pqoh                NUMBER     -- packed quantity on hand
   ,  sqoh                NUMBER
   ,  srqoh               NUMBER
   ,  sqr                 NUMBER
   ,  sqs                 NUMBER
   ,  satt                NUMBER
   ,  satr                NUMBER
   ,  spqoh               NUMBER
   ,  check_mark          BOOLEAN
   ,  next_sibling_index  INTEGER
   ,  first_child_index   INTEGER
   ,  last_child_index    INTEGER
   ,  parent_index        INTEGER
   ,  lpn_id              NUMBER
   ,  cost_group_id       NUMBER     -- valid if the node is a cost group node
   ,  next_hash_record    NUMBER
   ,  hash_string         VARCHAR2(300)
   ,  node_index          INTEGER    --used by backup/restore tree
   ,  qs_adj1             NUMBER     --Bug 4294336
   ,  sqs_adj1            NUMBER     --Bug 4294336
   );
--
TYPE node_tbl_type IS TABLE OF node_rec_type
  INDEX BY BINARY_INTEGER;

--
--Bug 1384720 - performance improvement
-- record keeps track of demand info only
-- Now, each transaction which queries the quantity tree has a
--  different demand record.  But the underlying tree (root_id)
--  might be the same for all the demand records.  Multiple
--  demand records can reference the same tree (represented by root_id).
--
TYPE demandinfo_rec_type IS RECORD
  (   root_id                  INTEGER
   ,  tree_mode                NUMBER
   ,  pick_release             NUMBER
   ,  demand_source_type_id    NUMBER
   ,  demand_source_header_id  NUMBER
   ,  demand_source_line_id    NUMBER
   ,  demand_source_name       VARCHAR2(30)
   ,  demand_source_delivery   NUMBER
   );
--
TYPE demand_tbl_type IS TABLE OF demandinfo_rec_type
   INDEX BY BINARY_INTEGER;
--
--Bug 1384720 - performance improvement,
--  This record holds information about the reservations for a transaction.
TYPE rsvinfo_rec_type IS RECORD
  (   revision            VARCHAR2(3)
   ,  lot_number          VARCHAR2(80)
   ,  subinventory_code   VARCHAR2(10)
   ,  locator_id          NUMBER
   ,  lpn_id              NUMBER
   ,  quantity            NUMBER
   ,  secondary_quantity  NUMBER
   );
--
TYPE rsvinfo_tbl_type IS TABLE OF rsvinfo_rec_type
   INDEX BY BINARY_INTEGER;

TYPE all_root_rec_type IS RECORD
   (  root_id    NUMBER
    , next_root  NUMBER
    , last_root  NUMBER
   );

TYPE all_root_tbl_type IS TABLE OF all_root_rec_type
   INDEX BY BINARY_INTEGER;

TYPE backup_tree_rec_type IS RECORD
   (  root_id    NUMBER
    , first_node NUMBER
    , last_node  NUMBER
   );

TYPE backup_tree_tbl_type IS TABLE of backup_tree_rec_type
   INDEX BY BINARY_INTEGER;

TYPE item_reservable_rec_type IS RECORD
   (  value   BOOLEAN
    , org_id  NUMBER
   );

-- Bug 5535030: PICK RELEASE PERFORMANCE ISSUES
TYPE sub_reservable_rec_type IS RECORD
   (  reservable_type   NUMBER
    , org_id            VARCHAR2(100)
    , subinventory_code VARCHAR2(10)
   );

TYPE bulk_num_tbl_type IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
TYPE bulk_date_tbl_type IS TABLE OF DATE
   INDEX BY BINARY_INTEGER;
TYPE bulk_varchar_3_tbl_type IS TABLE OF VARCHAR2(3)
   INDEX BY BINARY_INTEGER;
TYPE bulk_varchar_10_tbl_type IS TABLE OF VARCHAR2(10)
   INDEX BY BINARY_INTEGER;
TYPE bulk_varchar_30_tbl_type IS TABLE OF VARCHAR2(30)
   INDEX BY BINARY_INTEGER;
TYPE item_reservable_type IS TABLE OF item_reservable_rec_type
   INDEX BY BINARY_INTEGER;
TYPE bulk_varchar_80_tbl_type IS TABLE OF VARCHAR2(80)
   INDEX BY BINARY_INTEGER;
-- bug 8593965
TYPE bulk_varchar_150_tbl_type IS TABLE OF VARCHAR2(150)
   INDEX BY BINARY_INTEGER;

-- Bug 5535030: PICK RELEASE PERFORMANCE ISSUES
TYPE sub_reservable_type IS TABLE OF sub_reservable_rec_type
   INDEX BY BINARY_INTEGER;

--------------------------------------------------
-- Global Variables
--------------------------------------------------
--
-- rootinfo array, counter and tree node array and counter
g_rootinfos                   rootinfo_tbl_type;      -- rootinfo array
g_nodes                       node_tbl_type;          -- tree node array
g_rootinfo_counter            INTEGER := 0;           -- size of rootinfo arry
g_org_item_trees              bulk_num_tbl_type;
g_all_roots                   all_root_tbl_type;
g_all_roots_counter           NUMBER := 0;
g_max_hash_rec                NUMBER := 0;
g_saveroots                   rootinfo_tbl_type;      -- savepoint rootinfos
g_savenodes                   node_tbl_type;          -- savepoint tree nodes

g_save_rsv_tree_id            INTEGER :=0;            -- savepoint rsv tree id -- bug 6683013
g_save_rsv_counter            NUMBER := 0;            -- savepoint rsv counter -- bug 6683013
g_saversvnode                 rsvinfo_tbl_type;       -- savepoint rsv nodes   -- bug 6683013


g_backup_trees                backup_tree_tbl_type;   --used by new backup_tree procedure
g_backup_nodes                node_tbl_type;          --used by new backup_tree procedure

g_demand_info                 demand_tbl_type;
g_demand_counter              INTEGER := 0;
g_rsv_info                    rsvinfo_tbl_type;       -- all rsvs which are currently applied to the tree
g_rsv_counter                 INTEGER :=0;
g_rsv_tree_id                 INTEGER :=0;            -- tree for which rsv_info corresponds

g_backup_tree_counter         INTEGER := 0;           --used by new backup_tree procedure
g_backup_node_counter         INTEGER := 0;           --used by new backup_tree procedure

g_rsv_qty_counter             INTEGER := 0;
g_rsv_qty_node_level          bulk_num_tbl_type;
g_rsv_qty_revision            bulk_varchar_3_tbl_type;
g_rsv_qty_lot_number          bulk_varchar_80_tbl_type;
--bug 8593965
g_rsv_qty_grade_code          bulk_varchar_150_tbl_type;

g_rsv_qty_subinventory_code   bulk_varchar_10_tbl_type;
g_rsv_qty_locator_id          bulk_num_tbl_type;
g_rsv_qty_lpn_id              bulk_num_tbl_type;
g_rsv_qty_cost_group_id       bulk_num_tbl_type;
g_rsv_qty_qoh                 bulk_num_tbl_type;
g_rsv_qty_atr                 bulk_num_tbl_type;
g_rsv_qty_sqoh                bulk_num_tbl_type;
g_rsv_qty_satr                bulk_num_tbl_type;
--
-- pjm support
--BENCHMARK - added unit effective info to tree node
g_unit_eff_enabled            VARCHAR(1) := NULL;

--holds the Packed Quantity on hand for the last node queried using query_tree
g_pqoh                        NUMBER := NULL;
g_spqoh                       NUMBER := NULL;

-- dummy lpn_id for Loose quantities
g_loose_lpn_id                NUMBER := -99999;

g_organization_id             NUMBER := NULL;
g_lock_timeout                NUMBER := NULL;

g_hash_string                 VARCHAR2(1000) := NULL;
g_empty_root_index            NUMBER := NULL;

--Variable indicating whether debugging is turned on
g_debug                       NUMBER := NULL;

--Performance improvement, check whether it is a pick release session
g_is_pickrelease              BOOLEAN := FALSE;

-- Added to improve performance of check_is_item_reservable procedure
g_is_item_reservable          item_reservable_type;

-- Bug 5535030: PICK RELEASE PERFORMANCE ISSUES
g_is_sub_reservable           sub_reservable_type;

-- SRSRIRAN Bug# 4666553
-- Added p_level parameter with default as 14
PROCEDURE print_debug(p_message IN VARCHAR2, p_level IN NUMBER DEFAULT 14) IS
BEGIN
   IF g_debug IS NULL THEN
      g_debug :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   IF (g_debug = 1) THEN
      inv_log_util.trace(p_message, 'INV_QUANTITY_TREE_PVT', p_level);
   END IF;
END;

--------------------------------------------------
-- Private Procedures and Functions
--------------------------------------------------

-- Function
--   demand_source_equals
-- Description
--   Compare whether two demand sources are the same.
-- Notes
--   The following condition is checked for equality
--   Point 1 is required, and if point 2 or 3 or 4 is true, the
--   answer is yes
--   1. p_demand_source_header_id1 and p_demand_source_header_id2
--      are equal and both not null
--   2. for demand_source_type_id of oe (2) or internal order (8)
--      , p_demand_source_header_id and demand_source_header_id are equal
---     both not null, and p_demand_source_line_id and demand_source_line_id
--      are equal and both not null and p_demand_source_delivery and
--      demand_source_delivery are equals and both not null
--      and p_demand_source_name and demand_source_name are equal
--      or both null
--   or
--   3. for demand_source_type_id other than oe and internal order,
--      p_demand_source_header_id and demand_source_header_id are both null
--      and p_demand_source_name and demand_source_name are equal and both
--      not null
--   or
--   4. for demand_source_type_id other than oe and internal order,
--      p_demand_source_header_id and demand_source_header_id are equal
--      and both not null and p_demand_source_line_id are equal or both null
--      and p_demand_source_name and demand_source_name are equal or both
--      null
-- Return Value
--   'Y' if the two demand sources are the same; 'N' otherwise
Function demand_source_equals
  (  p_demand_source_type_id1   NUMBER
    ,p_demand_source_header_id1 NUMBER
    ,p_demand_source_line_id1   NUMBER
    ,p_demand_source_delivery1  NUMBER
    ,p_demand_source_name1      VARCHAR2
    ,p_demand_source_type_id2   NUMBER
    ,p_demand_source_header_id2 NUMBER
    ,p_demand_source_line_id2   NUMBER
    ,p_demand_source_delivery2  NUMBER
    ,p_demand_source_name2      VARCHAR2
  ) RETURN VARCHAR2 IS
     l_true  VARCHAR2(1) := 'Y';
     l_false VARCHAR2(1) := 'F';
BEGIN
   -- first check source type
   IF   p_demand_source_type_id1 <> p_demand_source_type_id2
     OR p_demand_source_type_id1 IS NOT NULL AND p_demand_source_type_id2 IS NULL
     OR p_demand_source_type_id1 IS NULL     AND p_demand_source_type_id2 IS NOT NULL THEN
      RETURN l_false;
   END IF;
   -- so here we have the same source type
   -- check the rest
   IF    p_demand_source_type_id1 IN (2,8)
     AND p_demand_source_header_id1 = p_demand_source_header_id2
     AND p_demand_source_line_id1 = p_demand_source_line_id2
     AND p_demand_source_delivery1 = p_demand_source_delivery2
     AND (p_demand_source_name1 = p_demand_source_name2
          OR p_demand_source_name1 IS NULL
          AND p_demand_source_name2 IS NULL) THEN
      RETURN l_true;
   ELSIF p_demand_source_header_id1 IS NULL
     AND p_demand_source_header_id2 IS NULL
     AND p_demand_source_name1 = p_demand_source_name2 THEN
      RETURN l_true;
   ELSIF p_demand_source_header_id1 = p_demand_source_header_id2
     AND (p_demand_source_line_id1 = p_demand_source_line_id2
          OR p_demand_source_line_id1 IS NULL
          AND p_demand_source_line_id2 IS NULL)
     AND (p_demand_source_name1 = p_demand_source_name2
          OR p_demand_source_name1 IS NULL
          AND p_demand_source_name2 IS NULL) THEN
      RETURN l_true;
   END IF;
   --
   RETURN l_false;
END;
--

-- Procedure
--   print_tree_node
-- Description
--   print the data in a tree node specified by the input
PROCEDURE print_tree_node
  (p_node_index IN INTEGER
   ) IS
   l_node_level         INTEGER;
   l_node_index         INTEGER;

   l_found              BOOLEAN;
   l_root_id            NUMBER;
   l_return_status      VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_reservable         VARCHAR2(10);
   b_reservable         BOOLEAN;
   l_status_id          NUMBER;
   l_zone_control       NUMBER;
   l_location_control   NUMBER;

   z_node               VARCHAR2(200);
   zz_node              VARCHAR2(200);
   z_reservable         VARCHAR2(200);
   z_check              VARCHAR2(200);
   z_lot                VARCHAR2(200);
   z_sub                VARCHAR2(200);
   z_loc                VARCHAR2(200);
   z_rev                VARCHAR2(200);
   z_qoh                VARCHAR2(200);
   z_rqoh               VARCHAR2(200);
   z_qr                 VARCHAR2(200);
   z_qs                 VARCHAR2(200);
   z_att                VARCHAR2(200);
   z_atr                VARCHAR2(200);
   z_sqr                VARCHAR2(200);
   z_sqs                VARCHAR2(200);
   z_satt               VARCHAR2(200);
   z_satr               VARCHAR2(200);
   z_qs_adj1            VARCHAR2(200);
   z_lpn                VARCHAR2(200);
BEGIN

   IF g_debug IS NULL THEN
      g_debug :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   -- Bug 6332112 : Removed if g_debug and indented the complete procedure
   l_reservable  := 'Y';
   IF p_node_index <> 0 THEN
       l_node_level := g_nodes(p_node_index).node_level;

       IF l_node_level = g_item_level THEN
          z_node := rpad('Item', 5);
          zz_node := 'Item';

       ELSIF l_node_level = g_revision_level THEN
          z_node := rpad('Rev', 5);
          zz_node := 'Revision';

       ELSIF l_node_level = g_lot_level THEN
          z_node := rpad('Lot', 5);
          zz_node := 'Lot';

       ELSIF l_node_level = g_sub_level THEN
          z_node := rpad('Sub', 5);
          zz_node := 'SubInventory';

       ELSIF l_node_level = g_locator_level THEN
          z_node := rpad('Loc', 5);
          zz_node := 'Locator';

       END IF;   -- l_node_level

       b_reservable := g_nodes(p_node_index).is_reservable_sub;

       IF b_reservable THEN
           l_reservable := ' Y';
       ELSE
           l_reservable := ' N';
       END IF;


       z_rev        := rpad(NVL(g_nodes(p_node_index).revision, '...'), 5);
       z_lot        := rpad(NVL(g_nodes(p_node_index).lot_number, '...'), 10);
       z_sub        := rpad(NVL(g_nodes(p_node_index).subinventory_code, '...'), 10);
       z_loc        := rpad(NVL(to_char(g_nodes(p_node_index).locator_id), '...'), 7);
       z_lpn        := rpad(NVL(to_char(g_nodes(p_node_index).lpn_id), '...'), 7);
       z_qoh        := lpad(to_char(g_nodes(p_node_index).qoh), 7);
       z_rqoh       := lpad(to_char(g_nodes(p_node_index).rqoh), 7);
       z_qr         := lpad(to_char(g_nodes(p_node_index).qr), 7);
       z_qs         := lpad(to_char(g_nodes(p_node_index).qs), 7);
       z_att        := lpad(to_char(g_nodes(p_node_index).att), 7);
       z_atr        := lpad(to_char(g_nodes(p_node_index).atr), 7);
       z_qs_adj1    := lpad(to_char(g_nodes(p_node_index).qs_adj1), 8);
       z_reservable := rpad( l_reservable, 4);

       IF g_nodes(p_node_index).check_mark THEN
          z_check := rpad('TRUE', 6);
       ELSE
          z_check := rpad('FALSE', 6);
       END IF;

       print_debug('     '||z_node||z_rev||z_lot||z_sub||z_loc||z_lpn||z_qoh||z_rqoh||z_qr||z_qs||z_att||z_atr||z_qs_adj1||z_reservable||z_check,12);
       print_debug('    -'||RPad('-',105,'-'),12);

       l_node_index := g_nodes(p_node_index).first_child_index;
--
       WHILE l_node_index <> 0 LOOP
            print_tree_node(l_node_index);
            l_node_index := g_nodes(l_node_index).next_sibling_index;
       END LOOP;
   END IF;
END print_tree_node;

PROCEDURE print_tree
  (p_tree_id IN INTEGER
   ) IS

   l_root_id INTEGER;
BEGIN

--   IF p_tree_id > g_rootinfo_counter THEN
--      RETURN;
--   END IF;
   IF g_debug IS NULL THEN
      g_debug :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   IF (g_debug = 1) THEN
      l_root_id := g_demand_info(p_tree_id).root_id;
      print_debug(' ',12);
      print_debug('  print tree: number='||To_char(p_tree_id)||' id='||l_root_id
             ||' for item='||g_rootinfos(l_root_id).inventory_item_id||' org='||g_rootinfos(l_root_id).organization_id,12);
      IF g_rootinfos(l_root_id).organization_id IS NOT NULL THEN
         print_debug('  _____start of tree '|| To_char(l_root_id),12);

         print_debug('     '||rpad('Node',5)||rpad('Rev',5)||rpad('Lot',10)||rpad('Sub',10)||rpad('Loc',7)||rpad('Lpn',7)||
                     lpad('qoh',7)||lpad('rqoh',7)||lpad('qr',7)||lpad('qs',7)||lpad('att',7)||lpad('atr',7)||
                     lpad('qs_adj1',8)||rpad(' Rsv',4)||rpad(' Marked',7) ,12);

         print_debug('    -'||RPad('-',105,'-'),12);
         print_tree_node(g_rootinfos(l_root_id).item_node_index);
         print_debug('  _____end of tree '||To_char(l_root_id),12);
       ELSE
         print_debug ('Error: tree '||To_char(l_root_id) || ' does not exist',12);
      END IF;
   END IF;

END print_tree;

-- Function
--  get_ancestor_sub
-- Description
--  Finds the ancestor sub node for the node passed in to the function
-- Returns
--  node_index of ancestor sub
FUNCTION get_ancestor_sub
   (p_node_index IN NUMBER) RETURN NUMBER IS

   l_cur_node NUMBER;
BEGIN
   l_cur_node := p_node_index;
   LOOP
      print_debug('in get_ancestor_sub, new loop... cur_node='||l_cur_node||', level='||g_nodes(l_cur_node).node_level);
      if l_cur_node IS NULL THEN
         print_debug('in get_ancestor_sub, cur_node=NULL');
         l_cur_node := -1;
         EXIT;
      elsif (g_nodes(l_cur_node).node_level = g_sub_level) THEN
         print_debug('in get_ancestor_sub, node_level='||g_nodes(l_cur_node).node_level||' = sub_level, parent_index='||g_nodes(l_cur_node).parent_index);
         EXIT;
      elsif (g_nodes(l_cur_node).node_level = g_item_level) THEN
         print_debug('in get_ancestor_sub, node_level='||g_nodes(l_cur_node).node_level||' = item_level, parent_index='||g_nodes(l_cur_node).parent_index);
         l_cur_node := -1;
         EXIT;
      elsif (g_nodes.exists(l_cur_node) = FALSE) THEN
         print_debug('in get_ancestor_sub, g_nodes.exists= FALSE, node_level='||g_nodes(l_cur_node).node_level);
         l_cur_node := -1;
         EXIT;
      end if;
      l_cur_node := g_nodes(l_cur_node).parent_index;
   END LOOP;

   print_debug('in get_ancestor_sub, returning='||l_cur_node);
   RETURN l_cur_node;
END get_ancestor_sub;

-- Procedure
--  check_is_reservable_sub
-- Description
--  check from db tables whether the sub specified in
--  the input is a reservable sub or not.
-- invConv comment : this procedure check_is_reservable_sub is included in check_is_reservable
--                   and used when g_is_mat_status_used =  NO ( == 2)
-- end of invConv comment.
PROCEDURE check_is_reservable_sub
  (   x_return_status       OUT NOCOPY VARCHAR2
    , p_organization_id     IN  VARCHAR2
    , p_subinventory_code   IN  VARCHAR2
    , x_is_reservable_sub   OUT NOCOPY BOOLEAN
      ) IS
         l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
         l_reservable_type  NUMBER := 2;
         l_hash_value       NUMBER;
BEGIN
   --Bug 4699159. The query is throwing a no data found exception when
   --p_subinventory_code is being passed as null.
   IF(p_subinventory_code IS NOT NULL) THEN
      l_hash_value := DBMS_UTILITY.get_hash_value
                      ( NAME      => p_organization_id ||'-'|| p_subinventory_code
                      , base      => 1
                      , hash_size => POWER(2, 25)
                      );
      IF g_is_sub_reservable.EXISTS(l_hash_value) AND
         g_is_sub_reservable(l_hash_value).org_id = p_organization_id AND
         g_is_sub_reservable(l_hash_value).subinventory_code = p_subinventory_code
      THEN
         l_reservable_type := g_is_sub_reservable(l_hash_value).reservable_type;
      ELSE
         SELECT reservable_type INTO l_reservable_type
           FROM mtl_secondary_inventories
          WHERE organization_id = p_organization_id
            AND secondary_inventory_name = p_subinventory_code;
         g_is_sub_reservable(l_hash_value).reservable_type := l_reservable_type;
         g_is_sub_reservable(l_hash_value).org_id := p_organization_id;
         g_is_sub_reservable(l_hash_value).subinventory_code := p_subinventory_code;
      END IF;
   END IF;
   IF (l_reservable_type = 1) THEN
      x_is_reservable_sub := TRUE;
   ELSE
      x_is_reservable_sub := FALSE;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
            (  g_pkg_name
             , 'Check_Is_Reservable_SUB'
            );
      END IF;

END check_is_reservable_sub;

--Bug 3424532 fix
-- Procedure
--  check_is_reservable_item
-- Description
--  check from db tables whether the item specified in
--  the input is a reservable or not.
PROCEDURE check_is_reservable_item
  (   x_return_status       OUT NOCOPY VARCHAR2
    , p_organization_id     IN  NUMBER
    , p_inventory_item_id   IN  NUMBER
    , x_is_reservable_item  OUT NOCOPY BOOLEAN
      ) IS
         l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
         l_reservable_type  NUMBER;
         l_no_info          BOOLEAN := FALSE;
BEGIN
   IF NOT g_is_item_reservable.exists(p_inventory_item_id) THEN
      l_no_info := TRUE;
   ELSE
      IF g_is_item_reservable(p_inventory_item_id).org_id <> p_organization_id THEN
        l_no_info := TRUE;
      END IF;
   END IF;

   IF l_no_info THEN
      SELECT Nvl(reservable_type,2) INTO l_reservable_type
        FROM mtl_system_items
        WHERE organization_id = p_organization_id
        AND inventory_item_id = p_inventory_item_id;
      g_is_item_reservable(p_inventory_item_id).org_id := p_organization_id;
      IF (l_reservable_type = 1) THEN
         g_is_item_reservable(p_inventory_item_id).value := TRUE;
       ELSE
         g_is_item_reservable(p_inventory_item_id).value := FALSE;
      END IF;
   END IF;

   x_is_reservable_item := g_is_item_reservable(p_inventory_item_id).value;

   x_return_status := l_return_status;

EXCEPTION

     WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'Check_Is_Reservable_item'
              );
        END IF;

END check_is_reservable_item;

-- Procedure
--  check_is_reservable
-- Description
--  check from db tables whether the sub specified in
--  the input is a reservable sub or not.
PROCEDURE check_is_reservable
  (   x_return_status        OUT NOCOPY VARCHAR2
    , p_node_level           IN  INTEGER    DEFAULT NULL
    , p_inventory_item_id    IN  NUMBER
    , p_organization_id      IN  NUMBER
    , p_subinventory_code    IN  VARCHAR2
    , p_locator_id           IN  NUMBER
    , p_lot_number           IN  VARCHAR2
    , p_root_id              IN  NUMBER
    , x_is_reservable        OUT NOCOPY BOOLEAN
    , p_lpn_id               IN  NUMBER     DEFAULT NULL -- Onhand Material Status Support
      ) IS

l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_reservable_type  NUMBER;
l_default_onhand_status_id   NUMBER; -- Onhand Material Status Support

/* Bug 6719389 */
l_reservable_type_sub  NUMBER := 1;
l_reservable_type_loc  NUMBER := 1;
l_reservable_type_lot  NUMBER := 1;

CURSOR is_RSV_subInv( org_id IN NUMBER
                    , subinv IN VARCHAR2) IS
   SELECT NVL(msinv.reservable_type, 1)
   FROM mtl_secondary_inventories msinv
   WHERE msinv.organization_id = org_id
   AND msinv.secondary_inventory_name = subinv;


CURSOR is_RSV_loct( org_id IN NUMBER
                  , loct_id IN NUMBER) IS
   SELECT NVL(mil.reservable_type, 1)
   FROM mtl_item_locations mil
   WHERE mil.organization_id = org_id
   AND mil.inventory_location_id = loct_id;


CURSOR is_RSV_lot( org_id IN NUMBER
                 , item_id IN NUMBER
                 , lot IN VARCHAR2) IS
   SELECT NVL(mln.reservable_type, 1)
   FROM mtl_lot_numbers mln
   WHERE mln.inventory_item_id = item_id
   AND mln.organization_id = org_id
   AND mln.lot_number = lot;


/* ONHAND MATERIAL STATUS SUPPORT */
CURSOR is_RSV_onhand( org_id IN NUMBER
                   , item_id IN NUMBER
                   , subinv  IN VARCHAR2
                   , loct_id IN NUMBER
                   , lot     IN VARCHAR2
                   , lpn_id  IN NUMBER) IS
   SELECT NVL(mms.reservable_type, 1)
   FROM mtl_onhand_quantities_detail moqd, mtl_material_statuses mms
   WHERE moqd.status_id = mms.status_id
   and moqd.status_id is not null
   AND moqd.inventory_item_id = item_id
   AND moqd.organization_id = org_id
   AND moqd.subinventory_code = subinv
   and nvl(moqd.locator_id, -9999) = nvl(loct_id, -9999)
   AND nvl(moqd.lot_number, '@@@@') = nvl(lot, '@@@@')
   AND nvl(moqd.lpn_id, -9999) = nvl(lpn_id, -9999)
   AND rownum = 1;

BEGIN
   print_debug('In check_is_reservable. node_level='||p_node_level||', subinv='
      ||p_subinventory_code||', loct='||p_locator_id||', lot='||p_lot_number);

   -- item
   IF ( NVL(p_node_level,0) = g_item_level ) THEN
       check_is_reservable_item
       (  x_return_status      => x_return_status
        , p_organization_id    => p_organization_id
        , p_inventory_item_id  => p_inventory_item_id
        , x_is_reservable_item => x_is_reservable);

   -- revision
   ELSIF ( NVL(p_node_level,0) = g_revision_level) THEN
      x_is_reservable := g_nodes(g_rootinfos(p_root_id).item_node_index).is_reservable_sub;
      x_return_status := l_return_status;

   ELSE

       IF (inv_quantity_tree_pvt.g_is_mat_status_used = 2) THEN
          --Bug 4587505. The value returned from here is used to set the is_reservable_sub property of the node
          --and for any node that is higher than subinventory(for example LOT node), the is_reservable_sub should
          --be set to TRUE, when INV_MATERIAL_STATUS profile is set to 2
          IF(p_subinventory_code IS NULL) THEN
             --bug 9380420
             print_debug('....p_subinventory_code is null.setting x_is_reservable to based on items reservable flag.');
             x_is_reservable := g_nodes(g_rootinfos(p_root_id).item_node_index).is_reservable_sub;
             x_return_status := l_return_status;
          ELSE
             print_debug('.... check_is_reservable is calling check_is_reservable_sub...');
             check_is_reservable_sub( x_return_status       => x_return_status
                                    , p_organization_id     => p_organization_id
                                    , p_subinventory_code   => p_subinventory_code
                                    , x_is_reservable_sub   => x_is_reservable);
          END IF;

       ELSE

          IF ( g_rootinfos(p_root_id).onhand_status_enabled = FALSE ) THEN -- Onhand Material Status Support
             print_debug('in check_is_rsv, default org status id is NULL for org id = '||p_organization_id);

             /*Bug #6719389 Changes done for honouring material status */
             /*IF (g_rootinfos(p_root_id).is_lot_status_enabled = FALSE)
             THEN
                -- Always reservable...
                l_reservable_type := 1;
             */

             IF (p_lot_number IS NOT NULL) THEN
                IF (g_rootinfos(p_root_id).is_lot_status_enabled = FALSE) THEN
                   l_reservable_type_lot := 1;
                ELSE
                   OPEN is_RSV_lot( p_organization_id, p_inventory_item_id, p_lot_number);
                   FETCH is_RSV_lot
                   INTO l_reservable_type_lot;
                   IF (is_RSV_lot%NOTFOUND) THEN
                      -- bug 3977807 : By default, the reservable flag is set to 1= reservable.
                      l_reservable_type_lot := 1;
                   END IF;
                   CLOSE is_RSV_lot;
                   print_debug('New in RSV reservable='||l_reservable_type_lot||', for lot='||p_lot_number);
                END IF;
             END IF;

             IF (p_subinventory_code IS NOT NULL) THEN
                OPEN is_RSV_subInv( p_organization_id, p_subinventory_code);
                FETCH is_RSV_subInv
                INTO l_reservable_type_sub;
                IF (is_RSV_subInv%NOTFOUND) THEN
                   -- bug 3977807 : By default, the reservable flag is set to 1= reservable.
                   l_reservable_type_sub := 1;
                END IF;
                CLOSE is_RSV_subInv;
                print_debug('New in RSV reservable='||l_reservable_type_sub||', for subInv='||p_subinventory_code);
             END IF;

             IF (p_locator_id IS NOT NULL) THEN
                OPEN is_RSV_loct( p_organization_id, p_locator_id);
                FETCH is_RSV_loct
                INTO l_reservable_type_loc;
                IF (is_RSV_loct%NOTFOUND) THEN
                   -- bug 3977807 : By default, the reservable flag is set to 1= reservable.
                   l_reservable_type_loc := 1;
                END IF;
                CLOSE is_RSV_loct;
                print_debug('New in RSV reservable='||l_reservable_type_loc||', for locator='||p_locator_id);
             END IF;

             IF (l_reservable_type_sub = 1 and l_reservable_type_loc = 1 and l_reservable_type_lot = 1) THEN
                l_reservable_type := 1;
                print_debug('New in RSV reservable=TRUE');
             ELSE
                l_reservable_type := 2;
                print_debug('New in RSV reservable=FALSE');
             END IF;
          ELSE
             print_debug('in check_is_rsv, default org status id is NOT NULL for org id = '||p_organization_id);

             OPEN is_RSV_onhand( p_organization_id, p_inventory_item_id, p_subinventory_code, p_locator_id, p_lot_number, p_lpn_id);
             FETCH is_RSV_onhand
                INTO l_reservable_type;
             IF (is_RSV_onhand%NOTFOUND) THEN
                -- bug 3977807 : By default, the reservable flag is set to 1= reservable.
                l_reservable_type := 1;
                print_debug('in RSV reservable, onhand record not found');
             END IF;
             CLOSE is_RSV_onhand;
             print_debug('in RSV reservable='||l_reservable_type||', for onhand record');
          END IF; -- Onhand Material Status Support End

          /* Bug 6719389 */
          IF l_reservable_type = 1 THEN
             x_is_reservable := TRUE;
             print_debug('in RSV reservable=TRUE');
          ELSE
             x_is_reservable := FALSE;
             print_debug('in RSV reservable=FALSE');
          END IF;

          x_return_status := l_return_status;
       END IF; --- g_is_mat_status_used.
    END IF;

EXCEPTION

   WHEN OTHERS THEN
      print_debug('in check_is_reservable, OTHERS Error='||SQLERRM, 9);
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'Check_Is_Reservable'
              );
      END IF;

END check_is_reservable;

PROCEDURE zero_tree_node
  (x_return_status   OUT NOCOPY VARCHAR2
   , p_node_index    IN  INTEGER
   ) IS
   l_return_status     VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_node_index        INTEGER;
BEGIN
   l_node_index := p_node_index;
   IF l_node_index <>0 THEN
      g_nodes(l_node_index).qoh   := 0;
      g_nodes(l_node_index).rqoh  := 0;
      g_nodes(l_node_index).qs    := 0;
      g_nodes(l_node_index).qr    := 0;
      g_nodes(l_node_index).atr   := 0;
      g_nodes(l_node_index).att   := 0;
      g_nodes(l_node_index).pqoh  := 0;

      g_nodes(l_node_index).sqoh  := 0;
      g_nodes(l_node_index).srqoh := 0;
      g_nodes(l_node_index).sqs   := 0;
      g_nodes(l_node_index).sqr   := 0;
      g_nodes(l_node_index).satr  := 0;
      g_nodes(l_node_index).satt  := 0;
      g_nodes(l_node_index).spqoh := 0;

      g_nodes(l_node_index).qs_adj1  := 0; -- Bug 8919216
      g_nodes(l_node_index).sqs_adj1  := 0; -- Bug 8919216

      l_node_index := g_nodes(l_node_index).first_child_index;
      WHILE l_node_index<>0 LOOP
         zero_tree_node(l_return_status, l_node_index);

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         End IF ;

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         End IF;

         l_node_index := g_nodes(l_node_index).next_sibling_index;
      END LOOP;
   END IF;
   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Zero_Tree_Node'
              );
      END IF;
END zero_tree_node;


-- Procedure
--   new_tree_node
-- Description
--   create a new tree node and initialize the all attributes.
--   This is the constrcutor for all kinds of tree nodes:
--   item, revision, lot, sub, and locator. The actual type of the
--   node is qualified by input p_node_level. The pointers to
--   and from the parent node and sibling nodes are also set up here.
PROCEDURE new_tree_node
  (   x_return_status       OUT NOCOPY VARCHAR2
   ,  p_node_level          IN  INTEGER
   ,  p_tree_id             IN  INTEGER
   ,  p_revision            IN  VARCHAR2 DEFAULT NULL
   ,  p_lot_number          IN  VARCHAR2 DEFAULT NULL
   ,  p_subinventory_code   IN  VARCHAR2 DEFAULT NULL
   ,  p_is_reservable_sub   IN  BOOLEAN  DEFAULT NULL
   ,  p_locator_id          IN  NUMBER   DEFAULT NULL
   ,  p_lpn_id              IN  NUMBER   DEFAULT NULL
   ,  p_cost_group_id       IN  NUMBER   DEFAULT NULL
   ,  p_node_index          IN  INTEGER
   ,  p_hash_string         IN  VARCHAR2 DEFAULT NULL
   ) IS
      l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_new_node_index      INTEGER;
      l_org_id              NUMBER;
      l_parent_index        INTEGER;
      l_last_child_index    INTEGER;
      l_is_reservable_sub   BOOLEAN;
BEGIN
   print_debug('      Creating node at level '|| p_node_level || ' with ' || NVL(p_hash_string,p_tree_id||'::::::'), 12);
   -- increment the index for the array
   l_new_node_index := p_node_index;

   --initialize the node
   g_nodes(l_new_node_index).node_level         := p_node_level;
   g_nodes(l_new_node_index).revision           := p_revision;
   g_nodes(l_new_node_index).lot_number         := p_lot_number;
   g_nodes(l_new_node_index).subinventory_code  := p_subinventory_code;
   g_nodes(l_new_node_index).locator_id         := p_locator_id;
   g_nodes(l_new_node_index).qoh                := 0;
   g_nodes(l_new_node_index).rqoh               := 0;
   g_nodes(l_new_node_index).qr                 := 0;
   g_nodes(l_new_node_index).qs                 := 0;
   g_nodes(l_new_node_index).att                := 0;
   g_nodes(l_new_node_index).atr                := 0;
   g_nodes(l_new_node_index).pqoh               := 0;

   g_nodes(l_new_node_index).sqoh               := 0;
   g_nodes(l_new_node_index).srqoh              := 0;
   g_nodes(l_new_node_index).sqr                := 0;
   g_nodes(l_new_node_index).sqs                := 0;
   g_nodes(l_new_node_index).satt               := 0;
   g_nodes(l_new_node_index).satr               := 0;
   g_nodes(l_new_node_index).spqoh              := 0;

   g_nodes(l_new_node_index).next_sibling_index := 0;
   g_nodes(l_new_node_index).first_child_index  := 0;
   g_nodes(l_new_node_index).last_child_index   := 0;
   g_nodes(l_new_node_index).parent_index       := 0;
   g_nodes(l_new_node_index).check_mark         := FALSE;
   g_nodes(l_new_node_index).lpn_id             := p_lpn_id;
   g_nodes(l_new_node_index).cost_group_id      := p_cost_group_id;
   g_nodes(l_new_node_index).hash_string        := p_hash_string;
   g_nodes(l_new_node_index).next_hash_record   := 0;
   --Bug 4294336
   g_nodes(l_new_node_index).qs_adj1            := 0;
   g_nodes(l_new_node_index).sqs_adj1           := 0;

   --bug 9380420, set the is_reservable_sub while creating the node.
   --       All the calls to check_is_reservable should be replaced
   --       by checking the node's is_reservable_sub flag
   --Bug 9131745: passing p_node_level
   IF p_is_reservable_sub IS NULL THEN
      check_is_reservable
        ( x_return_status       => l_return_status
        , p_node_level          => p_node_level
        , p_inventory_item_id   => g_rootinfos(p_tree_id).inventory_item_id
        , p_organization_id     => g_rootinfos(p_tree_id).organization_id
        , p_subinventory_code   => p_subinventory_code
        , p_locator_id          => p_locator_id
        , p_lot_number          => p_lot_number
        , p_root_id             => p_tree_id
        , x_is_reservable       => l_is_reservable_sub
        , p_lpn_id              => p_lpn_id); -- Onhand Material Status Support

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      End IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;


      g_nodes(l_new_node_index).is_reservable_sub := l_is_reservable_sub;
   ELSE
      g_nodes(l_new_node_index).is_reservable_sub := p_is_reservable_sub;
   END IF;

   x_return_status := l_return_status;
   print_debug('... normal end of new_tree_node');

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'New_Tree_Node'
              );
      END IF;

END new_tree_node;


FUNCTION build_hash_string (
      x_return_status             OUT NOCOPY VARCHAR2
   ,  p_organization_id           IN  NUMBER
   ,  p_inventory_item_id         IN  NUMBER
   ,  p_tree_mode                 IN  INTEGER
   ,  p_is_revision_control       IN  BOOLEAN
   ,  p_is_lot_control            IN  BOOLEAN
   ,  p_asset_sub_only            IN  BOOLEAN
   ,  p_demand_source_type_id     IN  NUMBER
   ,  p_demand_source_header_id   IN  NUMBER
   ,  p_demand_source_line_id     IN  NUMBER
   ,  p_demand_source_name        IN  VARCHAR2
   ,  p_lot_expiration_date       IN  DATE
   ,  p_onhand_source        IN  NUMBER
   ) RETURN VARCHAR2 IS

   l_hash_string VARCHAR2(1000);
   l_pjm_enabled VARCHAR2(1);

BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   -- Bug 1918356
   -- If PJM unit effectivity is enabled, we need to create
   -- a new tree for each different sales order line id
   -- Bug 2363739 - now call unit_effective_item
   l_pjm_enabled := pjm_unit_eff.unit_effective_item(
        x_item_id          => p_inventory_item_id
      , x_organization_id  => p_organization_id);
   IF l_pjm_enabled IS NULL THEN
     l_pjm_enabled := 'N';
   END IF;
   l_hash_string := p_organization_id || ':' || p_inventory_item_id;
   IF p_tree_mode IN (1,2) AND l_pjm_enabled <> 'Y' THEN
      l_hash_string := l_hash_string || ':1';
      -- add place holders for demand info
      l_hash_string := l_hash_string || '::::';
   ELSE
      l_hash_string := l_hash_string || ':' || p_tree_mode;
      l_hash_string := l_hash_string
        || ':' || p_demand_source_type_id
        || ':' || p_demand_source_header_id
        || ':' || p_demand_source_line_id
        || ':' || p_demand_source_name;
   END IF;

   IF p_is_revision_control THEN
      l_hash_string := l_hash_string || ':2';
   ELSE
      l_hash_string := l_hash_string || ':1';
   END IF;

   IF p_is_lot_control THEN
      l_hash_string := l_hash_string || ':2';
   ELSE
      l_hash_string := l_hash_string || ':1';
   END IF;

   IF p_asset_sub_only THEN
      l_hash_string := l_hash_string || ':2';
   ELSE
      l_hash_string := l_hash_string || ':1';
   END IF;

   IF p_lot_expiration_date IS NOT NULL THEN
      l_hash_string := l_hash_string || ':' || p_lot_expiration_date;
   END IF;

   l_hash_string := l_hash_string || ':' || p_onhand_source;

   RETURN l_hash_string;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Build_Hash_String'
              );
      END IF;

END build_hash_string;


--bug 8593965, moved new_tree after check_is_reservable
-- Procedure
--   new_tree
-- Description
--   Create a new tree.
--   1. create and init a rootinfo
--   2. find out negative quantity is allowed for the item and org
PROCEDURE new_tree
  (   x_return_status             OUT NOCOPY VARCHAR2
   ,  p_organization_id           IN  NUMBER
   ,  p_inventory_item_id         IN  NUMBER
   ,  p_tree_mode                 IN  INTEGER
   ,  p_is_revision_control       IN  BOOLEAN
   ,  p_is_lot_control            IN  BOOLEAN
   ,  p_is_serial_control         IN  BOOLEAN
   ,  p_asset_sub_only            IN  BOOLEAN
   ,  p_include_suggestion        IN  BOOLEAN
   ,  p_demand_source_type_id     IN  NUMBER
   ,  p_demand_source_header_id   IN  NUMBER
   ,  p_demand_source_line_id     IN  NUMBER
   ,  p_demand_source_name        IN  VARCHAR2
   ,  p_demand_source_delivery    IN  NUMBER
   ,  p_lot_expiration_date       IN  DATE
   ,  p_onhand_source             IN  NUMBER
   ,  p_pick_release              IN  NUMBER
   ,  p_grade_code                IN  VARCHAR2  DEFAULT NULL
   ,  x_tree_id                   OUT NOCOPY INTEGER
   ) IS
      l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_item_node_index           INTEGER;
      l_negative_inv_receipt_code NUMBER;
      l_disable_flag              NUMBER;

      l_hash_string               VARCHAR2(1000);
      l_hash_base                 NUMBER;
      l_hash_size                 NUMBER;
      l_tree_index                NUMBER;
      l_org_item_index            NUMBER;
      l_first_tree_index          NUMBER;
      l_last_tree_index           NUMBER;
      l_original_tree_index       NUMBER;
      l_original_hash_string      VARCHAR2(1000);

      l_unit_effective            NUMBER;
      l_return_value              BOOLEAN;
      --bug 8593965
      l_is_reservable_item        BOOLEAN;
      l_default_org_status_id     NUMBER;  --Bug 9150005

BEGIN
   print_debug('in new_tree, grade='||p_grade_code);

   l_hash_base := 1;
   l_hash_size := power(2, 20);
   IF g_hash_string IS NOT NULL THEN
     --if not null, we already found hash string in find_rootinfo and don't need to find it again
     l_hash_string := g_hash_string;
     g_hash_string := NULL;
   ELSE
     l_hash_string := build_hash_string (
        l_return_status
      , p_organization_id
      , p_inventory_item_id
      , p_tree_mode
      , p_is_revision_control
      , p_is_lot_control
      , p_asset_sub_only
      , p_demand_source_type_id
      , p_demand_source_header_id
      , p_demand_source_line_id
      , p_demand_source_name
      , p_lot_expiration_date
      , p_onhand_source);
   END IF;

   l_original_hash_string := l_hash_string;
   -- Bug 2092207 - hash procedure returning duplicate indices;
   --   doubling length of name to try to decrease probability of getting duplicate values
   IF g_empty_root_index IS NOT NULL THEN
      --if not null, we found an empty slot in find_rootinfo and don't need to look for it again
      l_tree_index := g_empty_root_index;
      g_empty_root_index := NULL;
   ELSE
      l_tree_index := dbms_utility.get_hash_value(
                          name       => l_hash_string || l_hash_string
                        , base       => l_hash_base
                        , hash_size  => l_hash_size);

      l_original_tree_index := l_tree_index;

      -- Bug 2092207 - catch duplicate tree indices.  Find next empty tree index
      WHILE g_rootinfos.exists(l_tree_index) LOOP
         l_tree_index := l_tree_index + 1;
         IF l_tree_index >= power(2,20) THEN
            l_tree_index := 1;
         END IF;
         -- if this ever true, we've used all the possible indices. Raise an exception.
         IF l_tree_index = l_original_tree_index THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END LOOP;
   END IF;

   -- increment the index for the array
   --g_rootinfo_counter := g_rootinfo_counter + 1;
   g_all_roots_counter := g_all_roots_counter + 1;
   g_all_roots(g_all_roots_counter).root_id   := l_tree_index;
   g_all_roots(g_all_roots_counter).next_root := 0;
   g_all_roots(g_all_roots_counter).last_root := g_all_roots_counter;

   --set values for org/item combo
   l_hash_string := p_organization_id || ':' || p_inventory_item_id;
   l_org_item_index := dbms_utility.get_hash_value(
                         name       => l_hash_string
                       , base       => l_hash_base
                       , hash_size  => l_hash_size);
   IF g_org_item_trees.exists(l_org_item_index) THEN
      l_first_tree_index                        := g_org_item_trees(l_org_item_index);
      l_last_tree_index                         := g_all_roots(l_first_tree_Index).last_root;
      g_all_roots(l_last_tree_index).next_root  := g_all_roots_counter;
      g_all_roots(l_first_tree_index).last_root := g_all_roots_counter;
   ELSE
      g_org_item_trees(l_org_item_index)        := g_all_roots_counter;
   END IF;

   -- initialize the rootinfo record
   g_rootinfos(l_tree_index).organization_id      := p_organization_id;
   g_rootinfos(l_tree_index).inventory_item_id    := p_inventory_item_id;
   g_rootinfos(l_tree_index).tree_mode            := p_tree_mode;
   g_rootinfos(l_tree_index).is_revision_control  := p_is_revision_control;
   g_rootinfos(l_tree_index).is_serial_control    := p_is_serial_control;
   g_rootinfos(l_tree_index).is_lot_control       := p_is_lot_control;
   g_rootinfos(l_tree_index).asset_sub_only       := p_asset_sub_only    ;
   g_rootinfos(l_tree_index).include_suggestion   := p_include_suggestion;
   g_rootinfos(l_tree_index).lot_expiration_date  := p_lot_expiration_date;
   g_rootinfos(l_tree_index).grade_code           := p_grade_code;

   print_debug('in new_tree org_id ='||g_rootinfos(l_tree_index).organization_id
      ||', item='||p_inventory_item_id||', tree_index='||l_tree_index);
   print_debug('in new_tree... grade_code='||p_grade_code);

   --only store demand info in tree for loose only mode - otherwise, it's stored in g_demand_info
   IF p_tree_mode = g_loose_only_mode THEN
      g_rootinfos(l_tree_index).demand_source_type_id   := p_demand_source_type_id;
      g_rootinfos(l_tree_index).demand_source_header_id := p_demand_source_header_id;
      g_rootinfos(l_tree_index).demand_source_line_id   := p_demand_source_line_id;
      g_rootinfos(l_tree_index).demand_source_name      := p_demand_source_name;
      g_rootinfos(l_tree_index).demand_source_delivery  := p_demand_source_delivery;
   END IF;
   g_rootinfos(l_tree_index).onhand_source             := p_onhand_source;
   g_rootinfos(l_tree_index).pick_release              := p_pick_release;
   g_rootinfos(l_tree_index).need_refresh              := TRUE;
   g_rootinfos(l_tree_index).hash_string               := l_original_hash_string;

   -- determine index for item node.  Rather than call the dbms hash utility,
   -- we'll just use the value for g_max_hash_rec. If this is the first tree
   -- to be created for this session, g_max_hash_rec will not have been
   -- initialized.  In that case, we'll use an index of 1.
   IF g_max_hash_rec <> 0 THEN
      g_max_hash_rec    := g_max_hash_rec + 1;
      l_item_node_index := g_max_hash_rec;
   ELSE
    /* Bug 2901076 : Setting l_item_node_index for the case where the first record
    has no onhand and availability */
      g_max_hash_rec := power(2,29) + 1;
      l_item_node_index := g_max_hash_rec;
   END IF;
   -- create the corresponding item tree node
   --bug 9380420, passing l_tree_index
   new_tree_node
     (  x_return_status => l_return_status
      , p_node_level    => g_item_level
      , p_tree_id       => l_tree_index
      , p_node_index    => l_item_node_index
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   g_rootinfos(l_tree_index).item_node_index := l_item_node_index;
   --bug 9380420, commenting the code below as new_tree_node will take care of it.
   /*
   --bug 8593965, calling check_is_reservable_item
   --             to set value of g_nodes(l_item_node_index).is_reservable_sub
   check_is_reservable_item
   (  x_return_status      => l_return_status
    , p_organization_id    => p_organization_id
    , p_inventory_item_id  => p_inventory_item_id
    , x_is_reservable_item => l_is_reservable_item);

   g_nodes(l_item_node_index).is_reservable_sub := l_is_reservable_item;
   */

   l_return_value := INV_CACHE.set_org_rec(p_organization_id);
   IF NOT l_return_value THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   l_negative_inv_receipt_code := INV_CACHE.org_rec.negative_inv_receipt_code;
   l_default_org_status_id     := INV_CACHE.org_rec.default_status_id;   --Bug 9150005

   print_debug('In new_tree l_negative_inv_receipt_code: '||l_negative_inv_receipt_code ||' l_default_org_status_id: ' ||l_default_org_status_id);

   IF (l_negative_inv_receipt_code = 1) THEN
      g_rootinfos(l_tree_index).neg_inv_allowed := TRUE;
   ELSE
      g_rootinfos(l_tree_index).neg_inv_allowed := FALSE;
   END IF;
   --  Bug 9150005 Start
   IF (l_default_org_status_id IS NULL) THEN
      g_rootinfos(l_tree_index).onhand_status_enabled := FALSE;
   ELSE
      g_rootinfos(l_tree_index).onhand_status_enabled := TRUE;
   END IF;
   --  Bug 9150005 End

   --BENCHMARK
   --check whether item is unit effective controlled
   /* Check item cache instead of PJM function
    l_unit_effective := pjm_unit_eff.unit_effective_item(
         x_item_id => p_inventory_item_id
        ,x_organization_id => p_organization_id);
   */
   l_return_value := INV_CACHE.set_item_rec(p_organization_id, p_inventory_item_id);
   IF NOT l_return_value THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   l_unit_effective := INV_CACHE.item_rec.effectivity_control;

   /*Bug#5352407. All EAM asset group items are unit effective. Though they are unit
     effective, unit number is not required to perform transactions. So,
     they should be treated as non-unit effective otherwise the quantity
     tree would return the available qty as 0 even though there is qty
     available (Since it calls PJM API for getting onhand qty for
     unit effective items and the PJM API returns 0 if the item is of EAM asset group
     type).*/
   IF  l_unit_effective = 2 THEN
      IF INV_CACHE.item_rec.eam_item_type = 1 THEN
         l_unit_effective := 1;
      END IF;
   END IF;


   --2 is model/unit effective, which is what we care about
   IF l_unit_effective = 2 THEN
      g_rootinfos(l_tree_index).unit_effective := 1;
   ELSE
      g_rootinfos(l_tree_index).unit_effective := 2;
   END IF;

   --Bug 1384720 -performance
   -- Populate the demand table.  The index of this record is what
   --  is returned to the user as the tree_id.
   g_demand_counter := g_demand_counter + 1;
   g_demand_info(g_demand_counter).root_id                  := l_tree_index;
   g_demand_info(g_demand_counter).tree_mode                := p_tree_mode;
   g_demand_info(g_demand_counter).pick_release             := p_pick_release;
   g_demand_info(g_demand_counter).demand_source_type_id    := p_demand_source_type_id;
   g_demand_info(g_demand_counter).demand_source_header_id  := p_demand_source_header_id;
   g_demand_info(g_demand_counter).demand_source_line_id    := p_demand_source_line_id;
   g_demand_info(g_demand_counter).demand_source_name       := p_demand_source_name;
   g_demand_info(g_demand_counter).demand_source_delivery   := p_demand_source_delivery;
   -- return the tree id
   x_tree_id         := g_demand_counter;
   x_return_status   := l_return_status;

   print_debug('in new_tree org_id ='||g_rootinfos(l_tree_index).organization_id);

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'New_Tree'
              );
      END IF;

END new_tree;


-- Procedure
--   get_lock_handle
-- Description
--   Helper function which gets the lock handle for a given item/org.
--   Allocate_unique executes a commit, so this function is
--   autonomous to prevent commit of the session's other data.
FUNCTION get_lock_handle (
    p_organization_id   IN NUMBER
      ,p_inventory_item_id IN NUMBER) RETURN VARCHAR2 IS

   PRAGMA AUTONOMOUS_TRANSACTION;
   l_lock_handle VARCHAR2(128);
   l_lock_name   VARCHAR2(30);
BEGIN

   l_lock_name := 'INV_QT_' || p_organization_id || '_' || p_inventory_item_id;
   dbms_lock.allocate_unique(
        lockname   => l_lock_name
      , lockhandle => l_lock_handle);
   return l_lock_handle;
END get_lock_handle;


-- Procedure
--   lock_tree
-- Description
--   this function places a user lock on an item/organization
--   combination.  Once this lock is placed, no other sessions
--   can lock the same item/org combo.  Users who call lock_tree
--   do not always have to call release_lock explicitly.  The lock is
--   released automatically at commit, rollback, or session loss.

PROCEDURE lock_tree(
     p_api_version_number   IN  NUMBER
   , p_init_msg_lst         IN  VARCHAR2
   , x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , p_organization_id      IN  NUMBER
   , p_inventory_item_id    IN  NUMBER)

IS
   l_api_version_number    CONSTANT NUMBER       := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'Lock_Tree';
   l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_lock_handle           VARCHAR2(128);
   l_status                INTEGER;

BEGIN
   print_debug('... in lock_tree... will create a dbms_lock...');
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(  l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   --validate organization and inventory item
   IF (p_organization_id IS NULL OR p_inventory_item_id IS NULL) THEN
      --raise error condition
      fnd_message.set_name('INV','INV_LOCK_MISSING_ARGS');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF g_lock_timeout IS NULL THEN
      g_lock_timeout := nvl(to_number(fnd_profile.value('INV_QTY_TREE_TIMEOUT')),dbms_lock.maxwait);
   END IF;
   --get lock handle by calling helper function
   l_lock_handle := get_lock_handle(
        p_organization_id   => p_organization_id
      , p_inventory_item_id => p_inventory_item_id);

   --request lock
   l_status := dbms_lock.request(
        lockhandle        => l_lock_handle
      , lockmode          => dbms_lock.x_mode
      , timeout           => nvl(g_lock_timeout,dbms_lock.maxwait)
      , release_on_commit => TRUE);

   --check for error cases
   IF (l_status NOT IN (0,4)) THEN
      if (l_status = 1) then -- timeout
         fnd_message.set_name('INV','INV_LOCK_TREE_TIMEOUT');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      elsif (l_status = 2) then -- deadlock
         fnd_message.set_name('INV','INV_LOCK_TREE_DEADLOCK');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      else -- internal error - not fault of user
         fnd_message.set_name('INV','INV_LOCK_TREE_ERROR');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      end if;
   END IF;

   print_debug('QTY TREE LOCK ACQUIRED '||l_lock_handle, 9);

   x_return_status := l_return_status;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'Lock_Tree'
              );
        END IF;

END lock_tree;

-- Procedure
--   release_lock
-- Description
--   this function releases the user lock on an item/organization
--   combination created by this session.  Users who call lock_tree
--   do not always have to call release_lock explicitly.  The lock is
--   released automatically at commit, rollback, or session loss.

PROCEDURE release_lock(
     p_api_version_number   IN  NUMBER
   , p_init_msg_lst         IN  VARCHAR2
   , x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , p_organization_id      IN  NUMBER
   , p_inventory_item_id    IN  NUMBER)

IS
   l_api_version_number   CONSTANT NUMBER       := 1.0;
   l_api_name             CONSTANT VARCHAR2(30) := 'Release_Lock';
   l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_lock_handle VARCHAR2(128);
   l_status INTEGER;
BEGIN
   print_debug('... in release_lock ...');
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   --validate organization and inventory item
   IF (p_organization_id IS NULL OR
       p_inventory_item_id IS NULL) THEN
   --raise error condition
         fnd_message.set_name('INV','INV_LOCK_RELEASE_MISSING_ARGS');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
   END IF;


   --get lock handle by calling helper function
   l_lock_handle := get_lock_handle(
         p_organization_id   => p_organization_id
       , p_inventory_item_id => p_inventory_item_id);


   l_status := dbms_lock.release(l_lock_handle);

   --if success (status = 0) or session does not own lock (status=4), do nothing
   --if parameter error or illegal lock handle (internal error)
   if l_status IN (3,5) THEN
      fnd_message.set_name('INV','INV_LOCK_RELEASE_ERROR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;

   print_debug('... Normal end of release_lock ...');
   x_return_status := l_return_status;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      print_debug('... release_lock EXP_ERROR='||SQLERRM, 9);
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      print_debug('... release_lock UNEXP_ERROR='||SQLERRM, 9);
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      print_debug('... release_lock others='||SQLERRM, 9);
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
     THEN
        fnd_msg_pub.add_exc_msg
          (  g_pkg_name
           , 'Release_Lock'
           );
     END IF;

END release_lock;


FUNCTION is_tree_valid
  (
   p_tree_id IN INTEGER
   ) RETURN BOOLEAN IS
BEGIN
   IF p_tree_id IS NULL THEN
      RETURN FALSE;
   END IF;

   IF p_tree_id <= 0
--   OR p_tree_id > g_rootinfo_counter
   THEN
      RETURN FALSE;
   END IF;

   IF g_rootinfos.exists(p_tree_id) = FALSE THEN
      RETURN FALSE;
   END IF;

   IF g_rootinfos(p_tree_id).inventory_item_id IS NULL THEN
      RETURN FALSE;
   END IF;

   RETURN TRUE;
END is_tree_valid;

FUNCTION is_saved_tree_valid
  (
   p_tree_id IN INTEGER
   ) RETURN BOOLEAN IS
BEGIN
   IF p_tree_id IS NULL THEN
      RETURN FALSE;
   END IF;

   IF g_saveroots.exists(p_tree_id) = FALSE THEN
      RETURN FALSE;
   END IF;

   IF g_saveroots(p_tree_id).inventory_item_id IS NULL THEN
      RETURN FALSE;
   END IF;

   RETURN TRUE;
END is_saved_tree_valid;

PROCEDURE invalidate_tree
  (
   p_tree_id IN INTEGER
   ) IS
BEGIN
   IF is_tree_valid(p_tree_id) THEN
      g_rootinfos(p_tree_id).inventory_item_id := NULL;
      g_rootinfos(p_tree_id).organization_id := NULL;
      g_rootinfos(p_tree_id).need_refresh := TRUE;
   END IF;

   IF is_saved_tree_valid(p_tree_id) THEN
      g_saveroots(p_tree_id).inventory_item_id := NULL;
      g_saveroots(p_tree_id).organization_id := NULL;
   END IF;


END invalidate_tree;


-- Function
--    find_rootinfo
-- Description
--    find a rootinfo record based on input parameters
--  Return
--    0                          if rootinfo not found
--    >0                         index for the rootinfo in the rootinfo array
FUNCTION find_rootinfo
  (   x_return_status            OUT NOCOPY VARCHAR2
   ,  p_organization_id          IN  NUMBER
   ,  p_inventory_item_id        IN  NUMBER
   ,  p_tree_mode                IN  INTEGER
   ,  p_is_revision_control      IN  BOOLEAN
   ,  p_is_lot_control           IN  BOOLEAN
   ,  p_is_serial_control        IN  BOOLEAN
   ,  p_asset_sub_only           IN  BOOLEAN
   ,  p_include_suggestion       IN  BOOLEAN
   ,  p_demand_source_type_id    IN  NUMBER
   ,  p_demand_source_header_id  IN  NUMBER
   ,  p_demand_source_line_id    IN  NUMBER
   ,  p_demand_source_name       IN  VARCHAR2
   ,  p_demand_source_delivery   IN  NUMBER
   ,  p_lot_expiration_date      IN  DATE
   ,  p_onhand_source            IN  NUMBER
   ,  p_pick_release             IN  NUMBER
   ) RETURN INTEGER
  IS

     l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_rootinfo_index           INTEGER;
     l_hash_base                NUMBER;
     l_hash_size                NUMBER;
     l_hash_string              VARCHAR2(1000);
     l_tree_index               NUMBER;
     l_original_tree_index      NUMBER;

BEGIN
   l_rootinfo_index := 1;

   print_debug('    Entering find_rootinfo for :');
   print_debug(    ' org ' || p_organization_id
                || ' item ' || p_inventory_item_id
                || ' mode ' || p_tree_mode
                || ' dsrc ' || p_demand_source_type_id
                || ' dhdr ' || p_demand_source_header_id
                || ' dlin ' || p_demand_source_line_id
                || ' dnme ' || p_demand_source_name
                || ' ddel ' || p_demand_source_delivery
                || ' exp ' || p_lot_expiration_date
                || ' onh ' || p_onhand_source
                || ' rel ' || p_pick_release);
   IF   p_is_lot_control THEN
      print_debug('lot_control=TRUE');
   ELSE
      print_debug('lot_control=FALSE');
   END IF;


   l_hash_base := 1;
   l_hash_size := power(2, 20);
   l_hash_string := build_hash_string (
        l_return_status
      , p_organization_id
      , p_inventory_item_id
      , p_tree_mode
      , p_is_revision_control
      , p_is_lot_control
      , p_asset_sub_only
      , p_demand_source_type_id
      , p_demand_source_header_id
      , p_demand_source_line_id
      , p_demand_source_name
      , p_lot_expiration_date
      , p_onhand_source);

   print_debug('in find_rootinfo: hashString_1='||l_hash_string);
   g_hash_string := l_hash_string;
   -- Bug 2092207 - hash procedure returning duplicate indices;
   --   doubling length of name to try to decrease probability of
   --   getting duplicate values
   l_tree_index := dbms_utility.get_hash_value(
               name       => l_hash_string || l_hash_string
             , base       => l_hash_base
             , hash_size  => l_hash_size);

   --Bug 5241485 fix
   l_original_tree_index := l_tree_index;

   print_debug('in find_rootinfo: tree_index='||l_tree_index);

   -- Bug 2092207 - catch duplicate tree indices. If hash string
   -- does not match the hash string of the found tree index,
   -- the get_hash_value procedure is returning duplicate tree indices
   -- for different hash strings.  In that case, increment the index and
   -- check to see if the tree with the matching hash string is at that value.
   -- Exit loop when correct root is found, or when empty root is found

   IF g_rootinfos.exists(l_tree_index) THEN
      WHILE g_rootinfos(l_tree_index).hash_string <> l_hash_string LOOP
         print_debug('in find_rootinfo: saved_HashString='||g_rootinfos(l_tree_index).hash_string);

         l_tree_index := l_tree_index + 1;
         -- if empty root is found, then the tree does not exist yet
         If NOT g_rootinfos.exists(l_tree_index) THEN
            g_empty_root_index := l_tree_index;
            EXIT;
         End If;
         -- if we reach the end of the possible index values, loop back to 1.
         If l_tree_index >= power(2,20) Then
            l_tree_index := 1;
         End If;
         -- if this ever true, we've used all the possible indices. Raise
         -- an exception.
         If l_tree_index = l_original_tree_index Then
            RAISE fnd_api.g_exc_unexpected_error;
         End If;
      END LOOP;
      --Bug 5241485 fix. This one causing no data found exception
      print_debug('in find_rootinfo: AFTER LOOP l_tree_index:'||l_tree_index);
   END IF;


   x_return_status := l_return_status;

   IF g_rootinfos.exists(l_tree_index) THEN
      --Bug 1384720 - performance improvements
      -- Every time this procedure is called, insert a new record
      --  in demand_info table.  Return the index for that record as the tree_id
      g_demand_counter := g_demand_counter + 1;
      g_demand_info(g_demand_counter).root_id                  := l_tree_index;
      g_demand_info(g_demand_counter).tree_mode                := p_tree_mode;
      g_demand_info(g_demand_counter).pick_release             := p_pick_release;
      g_demand_info(g_demand_counter).demand_source_type_id    := p_demand_source_type_id;
      g_demand_info(g_demand_counter).demand_source_header_id  := p_demand_source_header_id;
      g_demand_info(g_demand_counter).demand_source_line_id    := p_demand_source_line_id;
      g_demand_info(g_demand_counter).demand_source_name       := p_demand_source_name;
      g_demand_info(g_demand_counter).demand_source_delivery   := p_demand_source_delivery;
      l_rootinfo_index := g_demand_counter;
      print_debug('odab in find_rootinfo Normal End with index='||l_rootinfo_index||', return='||x_return_status);
      RETURN l_rootinfo_index; -- rootinfo node found
   ELSE
      print_debug('odab in find_rootinfo Normal End With index=0, NOT FOUND, return='||x_return_status);
      RETURN 0;                -- rootinfo node not found
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      print_debug('odab in find_rootinfo OTHERS='||SQLERRM, 9);
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Find_Rootinfo'
              );
      END IF;
      RETURN 0;

END find_rootinfo;

-- Function
--   find_child_node
-- Description
--   search the child linked list of a parent node
--   for a child node that has the value specified in the input
--   and if no such child node, create it. So it should always
--   return true, unlese there is exception occurred
FUNCTION find_child_node
  (  x_return_status        OUT NOCOPY VARCHAR2
   , p_node_level           IN  INTEGER
   , p_tree_id              IN  INTEGER
   , p_revision             IN  VARCHAR2  DEFAULT NULL
   , p_lot_number           IN  VARCHAR2  DEFAULT NULL
   , p_subinventory_code    IN  VARCHAR2  DEFAULT NULL
   , p_is_reservable_sub    IN  BOOLEAN   DEFAULT NULL
   , p_locator_id           IN  NUMBER    DEFAULT NULL
   , p_lpn_id               IN  NUMBER    DEFAULT NULL
   , p_cost_group_id        IN  NUMBER    DEFAULT NULL
   , x_child_index          OUT NOCOPY INTEGER
   ) RETURN BOOLEAN IS
      l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_node_index          INTEGER;
      l_hash_string         VARCHAR2(300);
      l_hash_size           NUMBER;
      l_hash_base           NUMBER := 1;
      l_prev_node_index     NUMBER;

BEGIN
   IF p_revision IS NULL
      AND p_lot_number IS NULL
      AND p_subinventory_code IS NULL
      AND p_locator_id IS NULL
      AND p_lpn_id IS NULL
      AND p_cost_group_id IS NULL
        THEN
      fnd_message.set_name('INV','INV-Cannot find node');
      fnd_message.set_token('ROUTINE', 'Find_Child_Node');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;


   print_debug('... in find_child_node, building the hash string...');
   --build hash string
   l_hash_size := power(2,29);
   IF g_max_hash_rec = 0 then
      g_max_hash_rec := l_hash_size + 1;
   END IF;
   l_hash_string := p_tree_id || ':' || p_revision || ':' ||
       p_lot_number || ':' || p_subinventory_code || ':' ||
       p_locator_id || ':' || p_lpn_id || ':' ||
       p_cost_group_id;

   --get hash value using dbms_utility package
   l_node_index := dbms_utility.get_hash_value(
                     name       => l_hash_string
                    ,base       => l_hash_base
                    ,hash_size  => l_hash_size);

   print_debug('... in find_child_node,  after dbms_utility.get_hash_value');

   IF g_nodes.exists(l_node_index) THEN
      WHILE g_nodes(l_node_index).hash_string <> l_hash_string LOOP
         l_prev_node_index := l_node_index;
         l_node_index := g_nodes(l_node_index).next_hash_record;
         IF l_node_index = 0 THEN
            g_max_hash_rec := g_max_hash_rec + 1;
            l_node_index := g_max_hash_rec;
            g_nodes(l_prev_node_index).next_hash_record := l_node_index;
            EXIT; --exit loop
         End IF;
      END LOOP;
   END IF;

   IF not g_nodes.exists(l_node_index) THEN
      new_tree_node(
           x_return_status       => l_return_status
         , p_node_level          => p_node_level
         , p_tree_id             => p_tree_id
         , p_revision            => p_revision
         , p_lot_number          => p_lot_number
         , p_subinventory_code   => p_subinventory_code
         , p_is_reservable_sub   => p_is_reservable_sub
         , p_locator_id          => p_locator_id
         , p_lpn_id              => p_lpn_id
         , p_cost_group_id       => p_cost_group_id
         , p_node_index          => l_node_index
         , p_hash_string         => l_hash_string);

   END IF;

   x_child_index := l_node_index;
   x_return_status := l_return_status;

   RETURN TRUE;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        -- For performance reasons during pick release only do this ifdebug is on
        IF ((NOT g_is_pickrelease) OR nvl(g_debug,2) = 1) THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
             fnd_msg_pub.add_exc_msg
               (  g_pkg_name
                , 'Find_Child_Node'
                );
          END IF;
        END IF;

END find_child_node;

-- Function
--   find_tree_node
-- Description
--   find the tree node based on values of the input. If
--   the node and its ancestors do not exist in the tree
--   , create them
FUNCTION find_tree_node
  (   x_return_status        OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_is_reservable_sub    IN  BOOLEAN
   ,  p_locator_id           IN  NUMBER
   ,  x_node_index           OUT NOCOPY INTEGER
   ,  p_lpn_id               IN  NUMBER
   ,  p_cost_group_id        IN  NUMBER
   ) RETURN BOOLEAN IS
      l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_current_node_index   INTEGER;
      l_child_node_index     INTEGER;
      l_found                BOOLEAN;
      l_last_child        INTEGER;
      l_item_node      INTEGER;

BEGIN
   x_node_index := 0;
   l_child_node_index := 0;
   l_current_node_index := 0;
   IF p_lpn_id IS NOT NULL THEN
      -- search for the lpn node
      l_found := find_child_node(
                          x_return_status      => l_return_status
                        , p_node_level         => g_lpn_level
                        , p_tree_id            => p_tree_id
                        , p_revision           => p_revision
                        , p_lot_number         => p_lot_number
                        , p_subinventory_code  => p_subinventory_code
                        , p_is_reservable_sub  => p_is_reservable_sub
                        , p_locator_id         => p_locator_id
                        , p_lpn_id             => p_lpn_id
                        , p_cost_group_id      => NULL
                        , x_child_index        => l_current_node_index
                        );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      End IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      IF l_found = FALSE THEN
         fnd_message.set_name('INV','INV-Cannot find node');
         fnd_message.set_token('ROUTINE', 'Find_Tree_Node');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      IF l_child_node_index <> 0 THEN
         IF g_nodes(l_current_node_index).first_child_index = 0 THEN
           g_nodes(l_current_node_index).first_child_index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         ELSE
           l_last_child := g_nodes(l_current_node_index).last_child_index;
           g_nodes(l_last_child).next_sibling_Index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         END IF;
         g_nodes(l_child_node_index).parent_index := l_current_node_index;
      END IF;
      l_child_node_index := l_current_node_index;
      IF x_node_index = 0 THEN
        x_node_index := l_current_node_index;
      End IF;
      IF g_nodes(l_current_node_index).parent_index <> 0 THEN
          x_return_status := l_return_status;
          print_debug('---End of find_tree_node... x_node_index='||x_node_index||', current_node_index='||l_current_node_index||'.');
          RETURN TRUE;
      END IF;
   END IF;

   IF p_locator_id IS NOT NULL THEN
      -- search for the locator node
      print_debug('... entering find_child_node for loct='||p_locator_id||', lot='||substr(p_lot_number, 1,10) );
      l_found := find_child_node(
                          x_return_status      => l_return_status
                        , p_node_level         => g_locator_level
                        , p_tree_id            => p_tree_id
                        , p_revision           => p_revision
                        , p_lot_number         => p_lot_number
                        , p_subinventory_code  => p_subinventory_code
                        , p_is_reservable_sub  => p_is_reservable_sub
                        , p_locator_id         => p_locator_id
                        , p_lpn_id             => NULL
                        , p_cost_group_id      => NULL
                        , x_child_index        => l_current_node_index
                        );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      End IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      IF l_found = FALSE THEN
         fnd_message.set_name('INV','INV-Cannot find node');
         fnd_message.set_token('ROUTINE', 'Find_Tree_Node');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      If l_child_node_index <> 0 Then
         if g_nodes(l_current_node_index).first_child_index = 0 then
           g_nodes(l_current_node_index).first_child_index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         else
           l_last_child := g_nodes(l_current_node_index).last_child_index;
           g_nodes(l_last_child).next_sibling_Index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         end if;
         g_nodes(l_child_node_index).parent_index := l_current_node_index;
      End If;
      l_child_node_index := l_current_node_index;
      If x_node_index = 0 Then
        x_node_index := l_current_node_index;
      End If;
      IF g_nodes(l_current_node_index).parent_index <> 0 THEN
         x_return_status := l_return_status;
         print_debug('--End of find_tree_node... x_node_index='||x_node_index||', current_node_index='||l_current_node_index||'.');
         RETURN TRUE;
      END IF;
   END IF;

   IF p_subinventory_code IS NOT NULL THEN
      -- search for the subinventory node
      l_found := find_child_node(
                          x_return_status      => l_return_status
                        , p_node_level         => g_sub_level
                        , p_tree_id            => p_tree_id
                        , p_revision           => p_revision
                        , p_lot_number         => p_lot_number
                        , p_subinventory_code  => p_subinventory_code
                        , p_is_reservable_sub  => p_is_reservable_sub
                        , p_locator_id         => NULL
                        , p_lpn_id             => NULL
                        , p_cost_group_id      => NULL
                        , x_child_index        => l_current_node_index
                        );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      End IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      IF l_found = FALSE THEN
         fnd_message.set_name('INV','INV-Cannot find node');
         fnd_message.set_token('ROUTINE', 'Find_Tree_Node');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      If l_child_node_index <> 0 Then
         if g_nodes(l_current_node_index).first_child_index = 0 then
           g_nodes(l_current_node_index).first_child_index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         else
           l_last_child := g_nodes(l_current_node_index).last_child_index;
           g_nodes(l_last_child).next_sibling_Index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         end if;
         g_nodes(l_child_node_index).parent_index := l_current_node_index;
      End If;
      l_child_node_index := l_current_node_index;
      If x_node_index = 0 Then
        x_node_index := l_current_node_index;
      End If;
      IF g_nodes(l_current_node_index).parent_index <> 0 THEN
         x_return_status := l_return_status;
         print_debug('-End of find_tree_node... x_node_index='||x_node_index||', current_node_index='||l_current_node_index||'.');
         RETURN TRUE;
      END IF;
   END IF;

   IF p_lot_number IS NOT NULL THEN
      -- search for the lot node
      l_found := find_child_node(
                          x_return_status      => l_return_status
                        , p_node_level         => g_lot_level
                        , p_tree_id            => p_tree_id
                        , p_revision           => p_revision
                        , p_lot_number         => p_lot_number
                        , p_subinventory_code  => NULL
                        , p_is_reservable_sub  => NULL
                        , p_locator_id         => NULL
                        , p_lpn_id             => NULL
                        , p_cost_group_id      => NULL
                        , x_child_index        => l_current_node_index
                        );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      End IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      IF l_found = FALSE THEN
         fnd_message.set_name('INV','INV-Cannot find node');
         fnd_message.set_token('ROUTINE', 'Find_Tree_Node');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      If l_child_node_index <> 0 Then
         if g_nodes(l_current_node_index).first_child_index = 0 then
           g_nodes(l_current_node_index).first_child_index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         else
           l_last_child := g_nodes(l_current_node_index).last_child_index;
           g_nodes(l_last_child).next_sibling_Index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         end if;
         g_nodes(l_child_node_index).parent_index := l_current_node_index;
      End If;
      l_child_node_index := l_current_node_index;
      If x_node_index = 0 Then
        x_node_index := l_current_node_index;
      End If;
      IF g_nodes(l_current_node_index).parent_index <> 0 THEN
         x_return_status := l_return_status;
         print_debug('+++End of find_tree_node... x_node_index='||x_node_index||', current_node_index='||l_current_node_index||'.');
         RETURN TRUE;
      END IF;
   END IF;

   IF p_revision IS NOT NULL THEN
      -- search for the revision node
      l_found := find_child_node(
                          x_return_status      => l_return_status
                        , p_node_level         => g_revision_level
                        , p_tree_id            => p_tree_id
                        , p_revision           => p_revision
                        , p_lot_number         => NULL
                        , p_subinventory_code  => NULL
                        , p_is_reservable_sub  => NULL
                        , p_locator_id         => NULL
                        , p_lpn_id             => NULL
                        , p_cost_group_id      => NULL
                        , x_child_index        => l_current_node_index
                        );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      End IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      IF l_found = FALSE THEN
         fnd_message.set_name('INV','INV-Cannot find node');
         fnd_message.set_token('ROUTINE', 'Find_Tree_Node');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

      If l_child_node_index <> 0 Then
         if g_nodes(l_current_node_index).first_child_index = 0 then
           g_nodes(l_current_node_index).first_child_index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         else
           l_last_child := g_nodes(l_current_node_index).last_child_index;
           g_nodes(l_last_child).next_sibling_Index := l_child_node_index;
           g_nodes(l_current_node_index).last_child_index := l_child_node_index;
         end if;
         g_nodes(l_child_node_index).parent_index := l_current_node_index;
      End If;
      l_child_node_index := l_current_node_index;
      If x_node_index = 0 Then
        x_node_index := l_current_node_index;
      End If;
      IF g_nodes(l_current_node_index).parent_index <> 0 THEN
         x_return_status := l_return_status;
         print_debug('++End of find_tree_node... x_node_index='||x_node_index||', current_node_index='||l_current_node_index||'.');
         RETURN TRUE;
      END IF;
   END IF;

   l_item_node := g_rootinfos(p_tree_id).item_node_index;
   IF l_current_node_index = 0 THEN
      x_node_index := l_item_node;
      x_return_status := l_return_status;
      print_debug('+End of find_tree_node... x_node_index='||x_node_index||', l_item_node='||l_item_node||', current_node_index='||l_current_node_index||'.');
      RETURN TRUE;
   END IF;
   IF g_nodes(l_item_node).first_child_index = 0 THEN
     g_nodes(l_item_node).first_child_index := l_current_node_index;
     g_nodes(l_item_node).last_child_index := l_current_node_index;
   ELSE
     l_last_child := g_nodes(l_item_node).last_child_index;
     g_nodes(l_last_child).next_sibling_index := l_current_node_index;
     g_nodes(l_item_node).last_child_index := l_current_node_index;
   END IF;

   g_nodes(l_current_node_index).parent_index := l_item_node;

   --bug 8593965, copy item's is_reservable_sub into revision's is_reservable_sub
   IF p_revision IS NOT NULL THEN
     g_nodes(l_current_node_index).is_reservable_sub := g_nodes(l_item_node).is_reservable_sub;
   END IF;

   print_debug('End of  find_tree_node... x_node_index='||x_node_index||', l_item_node='
      ||l_item_node||', current_node_index='||l_current_node_index||'.');
   print_debug('... parent_node='||l_item_node||', next_sibling='||g_nodes(l_current_node_index).next_sibling_index
      ||', last_child='||g_nodes(l_current_node_index).last_child_index||'.');

   x_return_status := l_return_status;
   RETURN TRUE;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
   RETURN FALSE;
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
   RETURN FALSE;

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF ((NOT g_is_pickrelease) OR nvl(g_debug,2) = 1) THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
             fnd_msg_pub.add_exc_msg
               (  g_pkg_name
                , 'Find_Tree_Node'
                );
          END IF;
        END IF;
        RETURN FALSE;
END find_tree_node;

-- Procedure
--   add_quantities
-- Description
--   add quantities to the tree based on the input
-- Input Parameters
--   p_tree_id               tree id
--   p_revision              item revision
--   p_lot_number            lot number
--   p_subinventory_code     subinventory code
--   p_is_reservable_sub     whether the sub is a reservable.
--                           this is needed to create the corresponding
--                           sub node
--                           if it has not been created
--   p_locator_id            locator id
--   p_primary_quantity      quantity to add in primary uom
--   p_secondary_quantity    quantity to add in secondary uom
--   p_quantity_type
--   p_set_check_mark        whether to set do_check mark to the appropriate
--                           nodes
-- Output Parameters
--   x_return_status         Standard Output Parameters

-- Bug 2486318. The do check does not work. Trasactions get committed
-- even if there is a node violation. Added p_check_mark_node_only to mark
-- the nodes.

PROCEDURE add_quantities
  (  x_return_status              OUT NOCOPY VARCHAR2
   , p_tree_id                    IN  INTEGER
   , p_revision                   IN  VARCHAR2
   , p_lot_number                 IN  VARCHAR2
   , p_subinventory_code          IN  VARCHAR2
   , p_is_reservable_sub          IN  BOOLEAN
   , p_locator_id                 IN  NUMBER
   , p_primary_quantity           IN  NUMBER
   , p_secondary_quantity         IN  NUMBER  DEFAULT NULL
   , p_quantity_type              IN  INTEGER
   , p_set_check_mark             IN  BOOLEAN
   , p_cost_group_id              IN  NUMBER
   , p_lpn_id                     IN  NUMBER
   , p_check_mark_node_only       IN  VARCHAR2 DEFAULT fnd_api.g_false
     --Bug 4294336 --Additional Parameters
   , p_transaction_action_id      IN  NUMBER   DEFAULT NULL
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_transfer_locator_id        IN  NUMBER   DEFAULT NULL
   , p_expiration_date            IN  DATE     DEFAULT NULL -- Bug 7628989
   , p_is_reservable_lot          IN  NUMBER   DEFAULT NULL -- Bug 8713821
   ) IS
      l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_node_index               INTEGER;
      l_found                    BOOLEAN;
      l_is_reservable_sub        BOOLEAN;
      ll_is_reservable_sub       BOOLEAN;
      l_loop_index               INTEGER;
      l_sub_index                NUMBER;
      l_tree_mode                NUMBER;
      l_old_factor               NUMBER;
      l_old_factor2              NUMBER;
      l_new_factor               NUMBER;
      l_new_factor2              NUMBER;
      l_update_quantity          NUMBER;
      l_update_quantity2         NUMBER;
      l_root_id                  INTEGER;
      l_org_item_index           NUMBER;
      l_tree_index               NUMBER;
      l_hash_string              VARCHAR2(1000);
      l_hash_base                NUMBER;
      l_hash_size                NUMBER;
      l_lpn_id                   NUMBER;
      l_is_reservable_xfer_sub   BOOLEAN := FALSE;
      l_debug_line               VARCHAR2(300);
      l_api_name                 VARCHAR2(30) := 'ADD_QUANTITIES';
BEGIN
   IF g_debug = 1 THEN
      print_debug('    '||l_api_name || ' Entered',9);
   END IF;

   IF p_is_reservable_sub THEN
      print_debug('... with p_is_reservable=TRUE');
   ELSIF p_is_reservable_sub = FALSE THEN
      print_debug('... with p_is_reservable=FALSE');
   ELSE
      print_debug('... with p_is_reservable=other');
   END IF;

   -- validate quantity type
   IF p_quantity_type <> g_qoh
     AND p_quantity_type <> g_qr_same_demand
     AND p_quantity_type <> g_qr_other_demand
     AND p_quantity_type <> g_qs_txn THEN
      -- invalid p_quantity_type. the caller's fault
      print_debug('... error=INVALID_QUANTITY_TYPE');
      fnd_message.set_name('INV', 'INV-INVALID_QUANTITY_TYPE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_hash_base := 1;
   l_hash_size := power(2, 20);

   l_found := find_tree_node(
                      x_return_status      => l_return_status
                    , p_tree_id            => p_tree_id
                    , p_revision           => p_revision
                    , p_lot_number         => p_lot_number
                    , p_subinventory_code  => p_subinventory_code
                    , p_is_reservable_sub  => p_is_reservable_sub
                    , p_locator_id         => p_locator_id
                    , x_node_index         => l_node_index
                    , p_cost_group_id      => p_cost_group_id
                    , p_lpn_id             => p_lpn_id
                    );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF  l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF l_found = FALSE THEN
      fnd_message.set_name('INV','INV-Cannot find node');
         fnd_message.set_token('ROUTINE', 'Add_Quantities');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   -- get tree mode
   -- only use this value to see if mode is loose or not
   --  rsv and txn mode are processed the same in this procedure
   l_tree_mode := g_rootinfos(p_tree_id).tree_mode;

   IF g_debug = 1 THEN
      l_debug_line := '      '||'for node: rev='||p_revision||' lot='||RPAD(p_lot_number,10)||' sub='||RPAD(p_subinventory_code,10)
         ||' loc='||RPAD(p_locator_id,6)||' lpn='||RPAD(p_lpn_id,6)||'..with qty type='||p_quantity_type||' qty='||RPAD(p_primary_quantity,6);
      print_debug(l_debug_line||' action='||p_transaction_action_id||' xfrsub='||p_transfer_subinventory_code||' xfrloc='||p_transfer_locator_id,9);
   END IF;

   -- process qoh
   print_debug('in add_qty, node_index='||l_node_index||', qtyType='||p_quantity_type||', g_qoh='||g_qoh
      ||', node_level='||g_nodes(l_node_index).node_level||'...');
   IF p_quantity_type = g_qoh THEN
      IF g_nodes(l_node_index).node_level <> g_locator_level
        AND g_nodes(l_node_index).node_level <> g_cost_group_level
        AND g_nodes(l_node_index).node_level <> g_sub_level
        AND g_nodes(l_node_index).node_level <> g_lpn_level
        THEN
         print_debug('... error=INV-WRONG_LEVEL');
         fnd_message.set_name('INV', 'INV-WRONG_LEVEL');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      End IF;

      --bug 9380420, commenting the code below, as is_reservable_sub should be checked from g_nodes.
      /*
      l_sub_index := get_ancestor_sub(l_node_index);
      print_debug('after get_ancestor_sub... node_index='||l_node_index||', l_sub_index='||l_sub_index||', level='||g_nodes(l_sub_index).node_level);

      IF (INV_QUANTITY_TREE_PVT.g_is_mat_status_used = 2) AND p_is_reservable_sub IS NOT NULL THEN
         print_debug('in add_qty, p_is_reservable_sub=NOT NULL');
         l_is_reservable_sub := p_is_reservable_sub;
      ELSE
         print_debug('in add_qty, p_is_reservable_sub=NULL');

         print_debug('in add_qty, tree_id='||p_tree_id);
         print_debug('in add_qty, Calling check_is_reservable. item_id='||g_rootinfos(p_tree_id).inventory_item_id||', org='||g_rootinfos(p_tree_id).organization_id||', sub='||p_subinventory_code);
         check_is_reservable
              ( x_return_status       => l_return_status
              , p_inventory_item_id   => g_rootinfos(p_tree_id).inventory_item_id
              , p_organization_id     => g_rootinfos(p_tree_id).organization_id
              , p_subinventory_code   => p_subinventory_code
              , p_locator_id          => p_locator_id
              , p_lot_number          => p_lot_number
              , p_root_id             => p_tree_id
              , x_is_reservable       => l_is_reservable_sub
              , p_lpn_id              => p_lpn_id); -- Onhand Material Status Support
         print_debug('in add_qty, after check_is_reservable. return_status='||l_return_status);

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         End IF ;

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         End IF;
      END IF;  -- p_is_reservable_sub = NULL


      g_nodes(l_sub_index).is_reservable_sub := l_is_reservable_sub;
      */
      l_is_reservable_sub := g_nodes(l_node_index).is_reservable_sub;

      l_loop_index := l_node_index;
      LOOP
         IF g_debug = 1 THEN
            l_debug_line := '      '||'Old: Node: '||g_nodes(l_loop_index).node_level||' :'||lpad(l_loop_index,10)||':'||lpad(g_nodes(l_loop_index).qoh,8)||':'||lpad(g_nodes(l_loop_index).rqoh,8);
            print_debug(l_debug_line||':'||lpad(g_nodes(l_loop_index).qr,8)||':'||lpad(g_nodes(l_loop_index).qs,8)||':'||lpad(g_nodes(l_loop_index).att,8)||':'||lpad(g_nodes(l_loop_index).atr,8),12);
         END IF;

         print_debug('loop1, node_level='||g_nodes(l_loop_index).node_level);
         print_debug('loop1, node_index='||l_loop_index||' qoh='||g_nodes(l_loop_index).qoh||' rqoh='||g_nodes(l_loop_index).rqoh
           ||' qr='||g_nodes(l_loop_index).qr||' qs='||g_nodes(l_loop_index).qs);
         print_debug(' ... att='||g_nodes(l_loop_index).att||' atr='||g_nodes(l_loop_index).atr);
         print_debug('.. sqoh='||g_nodes(l_loop_index).sqoh||' srqoh='||g_nodes(l_loop_index).srqoh||' sqr='||g_nodes(l_loop_index).sqr
           ||' sqs='||g_nodes(l_loop_index).sqs);
         print_debug(' .... satt='||g_nodes(l_loop_index).satt||' satr='||g_nodes(l_loop_index).satr);

         -- update qoh
         g_nodes(l_loop_index).qoh := g_nodes(l_loop_index).qoh + p_primary_quantity;
         g_nodes(l_loop_index).sqoh := NVL(g_nodes(l_loop_index).sqoh, 0) + p_secondary_quantity;

         -- Bug 7211383, 7628989, 8713821, 9150005
         IF l_is_reservable_sub = TRUE AND (p_expiration_date IS NULL OR
                  g_rootinfos(p_tree_id).lot_expiration_date IS NULL OR
                  p_expiration_date > g_rootinfos(p_tree_id).lot_expiration_date)THEN

            IF ((g_rootinfos(p_tree_id).onhand_status_enabled) OR
                  ( (g_is_mat_status_used = 2) OR
                    (g_is_mat_status_used = 1 AND p_is_reservable_lot = 1 ) OR
                    (g_is_mat_status_used = 1 AND p_is_reservable_lot is null)))
            THEN
               print_debug('in add_qty,0 reservable_flag=TRUE');
               -- update rqoh
               g_nodes(l_loop_index).rqoh := g_nodes(l_loop_index).rqoh + p_primary_quantity;
               g_nodes(l_loop_index).srqoh := NVL(g_nodes(l_loop_index).srqoh, 0) + p_secondary_quantity;
            END IF;
         ELSE
            print_debug('in add_qty,0 reservable_flag=FALSE');
         END IF;

         --update att/atr for containerized items;
         --track packed quantity on hand only in loose only mode;
         --see design document for detailed info on how att/atr is
         -- calculated in loose only mode;
         IF l_tree_mode = g_loose_only_mode AND p_lpn_id IS NOT NULL  THEN

            --l_old factor = QS+QR-PQOH
            l_old_factor := g_nodes(l_loop_index).qs + g_nodes(l_loop_index).qr - g_nodes(l_loop_index).pqoh;
            l_old_factor2 := g_nodes(l_loop_index).sqs + g_nodes(l_loop_index).sqr - g_nodes(l_loop_index).spqoh;

            --l_new factor = QS+QR-(PQOH+(change in PQOH))
            l_new_factor := l_old_factor - p_primary_quantity;
            l_new_factor2 := NVL(l_old_factor2, 0) - p_secondary_quantity;


            -- update_quantity is amount to update att/atr by
            -- Base calculation is update_quantity =
            --    max(old_factor, 0) - max(new_factor, 0)
            -- We have to deal with four possible cases:
            --  1. old_factor and new_factor >0
            --  2. old_factor >0 and new_factor <0
            --  3. old_factor <0 and new_factor >0
            --  4. old_factor and new_factor <0
            -- for these four cases, the att and atr are updated differently
            IF l_old_factor > 0 THEN
               IF l_new_factor > 0 THEN
                  --old_factor - new_factor
                  l_update_quantity:= p_primary_quantity;
                  l_update_quantity2 := p_secondary_quantity;

               ELSE  -- old factor > 0, new factor <= 0
                  --old_factor - 0  (max(new_factor, 0) = 0)
                  l_update_quantity := l_old_factor;
                  l_update_quantity2 := l_old_factor2;
               END IF;
            ELSE -- l_old_factor <=0
               IF l_new_factor > 0 THEN
                  -- -new_factor  (max(old_factor, 0) = 0)
                  l_update_quantity:= 0.0 - l_new_factor;
                  l_update_quantity2 := 0.0 - l_new_factor2;
               ELSE  -- old factor < 0, new factor <= 0
                  -- 0-0
                  l_update_quantity:= 0;
                  l_update_quantity2 := 0;
               END IF;
            END IF;

            --update pqoh
            g_nodes(l_loop_index).pqoh := g_nodes(l_loop_index).pqoh + p_primary_quantity;
            g_nodes(l_loop_index).spqoh := NVL(g_nodes(l_loop_index).spqoh, 0) + p_secondary_quantity;

            --update att
            g_nodes(l_loop_index).att := g_nodes(l_loop_index).att + l_update_quantity;
            g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) + l_update_quantity2;


            -- Bug 7211383, 7628989, 8713821, 9150005
            IF l_is_reservable_sub = TRUE AND (p_expiration_date IS NULL OR
                  g_rootinfos(p_tree_id).lot_expiration_date IS NULL OR
                  p_expiration_date > g_rootinfos(p_tree_id).lot_expiration_date)THEN

               IF ((g_rootinfos(p_tree_id).onhand_status_enabled) OR
                  ( (g_is_mat_status_used = 2) OR
                    (g_is_mat_status_used = 1 AND p_is_reservable_lot = 1 ) OR
                    (g_is_mat_status_used = 1 AND p_is_reservable_lot is null)))
               THEN
                  print_debug('in add_qty,1 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||l_update_quantity);
                  --update atr
                  g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr + l_update_quantity;
                  g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) + l_update_quantity2;
               END IF ;
            ELSE
               print_debug('in add_qty,1 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
            END IF;
         ELSE -- not in loose items only mode, or quantity not containerized
            --update att
            g_nodes(l_loop_index).att := g_nodes(l_loop_index).att + p_primary_quantity;
            g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) + p_secondary_quantity;

            -- Bug 7211383, 7628989, 8713821, 9150005
            IF l_is_reservable_sub = TRUE AND (p_expiration_date IS NULL OR
                     g_rootinfos(p_tree_id).lot_expiration_date IS NULL OR
                     p_expiration_date > g_rootinfos(p_tree_id).lot_expiration_date)THEN

               IF ((g_rootinfos(p_tree_id).onhand_status_enabled) OR
                  ( (g_is_mat_status_used = 2) OR
                    (g_is_mat_status_used = 1 AND p_is_reservable_lot = 1 ) OR
                    (g_is_mat_status_used = 1 AND p_is_reservable_lot is null)))
               THEN
                  print_debug('in add_qty,2 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||p_primary_quantity);
                  --update atr
                  g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr + p_primary_quantity;
                  g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) + p_secondary_quantity;
               END IF ;
            ELSE
               print_debug('in add_qty,2 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
            END IF;
         END IF;
         -- set check mark

         -- Bug 2486318. The do check does not work. Trasactions get committed
         -- even if there is a node violation. Added p_check_mark_node_only to mark the nodes.

         IF (p_set_check_mark = TRUE or
             p_check_mark_node_only = fnd_api.g_true AND
             p_primary_quantity < 0 )THEN
            g_nodes(l_loop_index).check_mark := TRUE;
         END IF;

         IF g_debug = 1 THEN
            l_debug_line := '      '||'New: Node: '||g_nodes(l_loop_index).node_level||' :'||lpad(l_loop_index,10)||':'||lpad(g_nodes(l_loop_index).qoh,8)||':'||lpad(g_nodes(l_loop_index).rqoh,8);
            print_debug(l_debug_line||':'||lpad(g_nodes(l_loop_index).qr,8)||':'||lpad(g_nodes(l_loop_index).qs,8)||':'||lpad(g_nodes(l_loop_index).att,8)||':'||lpad(g_nodes(l_loop_index).atr,8),12);
         END IF;

         IF (g_nodes(l_loop_index).node_level = g_item_level) THEN
            EXIT;
         END IF;

         l_loop_index := g_nodes(l_loop_index).parent_index;
      END LOOP;


    --process reservations
    ELSIF p_quantity_type = g_qr_same_demand
      OR p_quantity_type = g_qr_other_demand THEN
      print_debug('in add_qty, process reservation');

      l_loop_index := l_node_index;
      LOOP
         IF g_debug = 1 THEN
            l_debug_line := '      '||'Old: Node: '||g_nodes(l_loop_index).node_level||' :'||lpad(l_loop_index,10)||':'||lpad(g_nodes(l_loop_index).qoh,8)||':'||lpad(g_nodes(l_loop_index).rqoh,8);
            print_debug(l_debug_line||':'||lpad(g_nodes(l_loop_index).qr,8)||':'||lpad(g_nodes(l_loop_index).qs,8)||':'||lpad(g_nodes(l_loop_index).att,8)||':'||lpad(g_nodes(l_loop_index).atr,8),12);
         END IF;

         print_debug('loop2, node_index='||l_loop_index||' qoh='||g_nodes(l_loop_index).qoh||' rqoh='||g_nodes(l_loop_index).rqoh||' qr='||g_nodes(l_loop_index).qr||' qs='||g_nodes(l_loop_index).qs);
         print_debug(' ... att='||g_nodes(l_loop_index).att||' atr='||g_nodes(l_loop_index).atr);
         print_debug('.. sqoh='||g_nodes(l_loop_index).sqoh||' srqoh='||g_nodes(l_loop_index).srqoh||' sqr='||g_nodes(l_loop_index).sqr||' sqs='||g_nodes(l_loop_index).sqs);
         print_debug(' .... satt='||g_nodes(l_loop_index).satt||' satr='||g_nodes(l_loop_index).satr);
         print_debug(' .... pqoh='||g_nodes(l_loop_index).pqoh);

         --update att/atr for containerized items
         IF l_tree_mode = g_loose_only_mode THEN
            --old factor = QS+QR-PQOH
            l_old_factor := g_nodes(l_loop_index).qs + g_nodes(l_loop_index).qr - g_nodes(l_loop_index).pqoh;
            l_old_factor2 := g_nodes(l_loop_index).sqs + g_nodes(l_loop_index).sqr - g_nodes(l_loop_index).spqoh;

            --new factor = QS+QR+(change to QR)-PQOH
            l_new_factor := l_old_factor + p_primary_quantity;
            l_new_factor2 := NVL(l_old_factor2, 0) + p_secondary_quantity;

            if l_old_factor > 0 then
               IF l_new_factor > 0 THEN
                  l_update_quantity:= 0.0 - p_primary_quantity;
                  l_update_quantity2:= 0.0 - p_secondary_quantity;

               ELSE  -- old factor > 0, new factor <= 0
                  l_update_quantity := l_old_factor;
                  l_update_quantity2 := l_old_factor2;
               END IF;
            else -- l_old_factor <=0
               IF l_new_factor > 0 THEN
                  l_update_quantity:= 0.0 - l_new_factor;
                  l_update_quantity2:= 0.0 - l_new_factor2;
               ELSE  -- old factor < 0, new factor <= 0
                  l_update_quantity:= 0;
                  l_update_quantity2:= 0;
               END IF;
            end if;

            -- update qr
            g_nodes(l_loop_index).qr := g_nodes(l_loop_index).qr + p_primary_quantity;
            g_nodes(l_loop_index).sqr := NVL(g_nodes(l_loop_index).sqr, 0) + p_secondary_quantity;

            --update atr
            if g_nodes(l_loop_index).is_reservable_sub then
               print_debug('in add_qty,X rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||l_update_quantity);
            else
               print_debug('in add_qty,X rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + '||l_update_quantity);
            end if;

            g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr + l_update_quantity;
            g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) + l_update_quantity2;

            IF p_quantity_type = g_qr_other_demand
               -- we should also update att if the reservation qty is negative
               OR p_primary_quantity < 0 THEN
               -- update att
               g_nodes(l_loop_index).att := g_nodes(l_loop_index).att + l_update_quantity;
               g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) + l_update_quantity2;
            END IF;
         ELSE -- not in loose items only mode
            -- update qr
            g_nodes(l_loop_index).qr := g_nodes(l_loop_index).qr + p_primary_quantity;
            g_nodes(l_loop_index).sqr := NVL(g_nodes(l_loop_index).sqr, 0) + p_secondary_quantity;

            --update atr
            if g_nodes(l_loop_index).is_reservable_sub then
               print_debug('in add_qty,Y rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||p_primary_quantity);
            else
               print_debug('in add_qty,Y rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + '||p_primary_quantity);
            end if;
            g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr - p_primary_quantity;
            g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) - p_secondary_quantity;

            IF p_quantity_type = g_qr_other_demand
            -- we should also update att if the reservation qty is negative
               OR p_primary_quantity < 0 THEN
               -- update att
               g_nodes(l_loop_index).att := g_nodes(l_loop_index).att - p_primary_quantity;
               g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) - p_secondary_quantity;
            END IF;
         END IF;

         -- only set do check mark if we are reserving materials

         -- Bug 2486318. The do check does not work. Trasactions get committed
         -- even if there is a node violation. Added p_check_mark_node_only to mark the nodes.

         IF (p_set_check_mark = TRUE or
             p_check_mark_node_only = fnd_api.g_true AND p_primary_quantity >0) THEN
            g_nodes(l_loop_index).check_mark := TRUE;
         END IF;

         IF g_debug = 1 THEN
            l_debug_line := '      '||'New: Node: '||g_nodes(l_loop_index).node_level||' :'||lpad(l_loop_index,10)||':'||lpad(g_nodes(l_loop_index).qoh,8)||':'||lpad(g_nodes(l_loop_index).rqoh,8);
            print_debug(l_debug_line||':'||lpad(g_nodes(l_loop_index).qr,8)||':'||lpad(g_nodes(l_loop_index).qs,8)||':'||lpad(g_nodes(l_loop_index).att,8)||':'||lpad(g_nodes(l_loop_index).atr,8),12);
         END IF;

         EXIT WHEN g_nodes(l_loop_index).node_level = g_item_level;

         l_loop_index := g_nodes(l_loop_index).parent_index;
      END LOOP;


   --process suggestions
   ELSIF p_quantity_type = g_qs_txn THEN
      IF g_nodes(l_node_index).node_level <> g_locator_level
        AND g_nodes(l_node_index).node_level <> g_cost_group_level
        AND g_nodes(l_node_index).node_level <> g_sub_level
        AND g_nodes(l_node_index).node_level <> g_lpn_level
        THEN
         fnd_message.set_name('INV', 'INV-WRONG_LEVEL');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      End IF;

      -- need to find out whether the sub is reservable or not
      -- in order to compute atr
      -- we need to look at is_reservable_sub from the sub node
      -- since it is possible that p_is_reservable_sub is null
      -- and is_reservable_sub at the sub node is not null

      --bug 9380420, commenting the code below, as is_reservable_sub should be checked from g_nodes.
      /*
      print_debug('in add_qty, process suggestion');
      l_sub_index := get_ancestor_sub(l_node_index);
      print_debug('..after get_ancestor_sub... node_index='||l_node_index||', l_sub_index='||l_sub_index||', level='||g_nodes(l_sub_index).node_level);
      l_is_reservable_sub := g_nodes(l_sub_index).is_reservable_sub;

      IF l_is_reservable_sub IS NULL THEN
         IF p_is_reservable_sub IS NOT NULL THEN
            -- we did not know whether the sub is reservable
            -- when we created the node last time
            -- but we know now from p_is_reservable_sub
            l_is_reservable_sub := p_is_reservable_sub;
         ELSE
            check_is_reservable
              ( x_return_status       => l_return_status
              , p_inventory_item_id   => g_rootinfos(p_tree_id).inventory_item_id
              , p_organization_id     => g_rootinfos(p_tree_id).organization_id
              , p_subinventory_code   => p_subinventory_code
              , p_locator_id          => p_locator_id
              , p_lot_number          => p_lot_number
              , p_root_id             => p_tree_id
              , x_is_reservable       => l_is_reservable_sub
              , p_lpn_id              => p_lpn_id); -- Onhand Material Status Support

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            End IF ;

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            End IF;
         END IF;

         g_nodes(l_sub_index).is_reservable_sub := l_is_reservable_sub;

      END IF;
      */
      l_is_reservable_sub := g_nodes(l_node_index).is_reservable_sub;

      --Bug 4294336
      IF NVL(p_transaction_action_id,-1 ) = 2  THEN
         l_is_reservable_xfer_sub := FALSE;
         IF p_transfer_subinventory_code IS NULL THEN
            print_debug('add_quantities, transaction_action_id = 2 with NULL transfer subinventory ',9);
            RAISE fnd_api.g_exc_error;
         END IF;
         --bug 9380420, we should be calling check_is_reservable to account for transfer locator as well.
         /*
         check_is_reservable_sub
           (
              x_return_status     => l_return_status
            , p_organization_id   => g_rootinfos(p_tree_id).organization_id
            , p_subinventory_code => p_transfer_subinventory_code
            , x_is_reservable_sub => l_is_reservable_xfer_sub
            );
         */

         check_is_reservable
           ( x_return_status       => l_return_status
           , p_inventory_item_id   => g_rootinfos(p_tree_id).inventory_item_id
           , p_organization_id     => g_rootinfos(p_tree_id).organization_id
           , p_subinventory_code   => p_transfer_subinventory_code
           , p_locator_id          => p_transfer_locator_id
           , p_lot_number          => p_lot_number
           , p_root_id             => p_tree_id
           , x_is_reservable       => l_is_reservable_xfer_sub
           , p_lpn_id              => p_lpn_id); -- Onhand Material Status Support

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         End IF ;

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         End IF;

      END IF;
      --Bug 4294336

      l_loop_index := l_node_index;
      LOOP
         if g_debug = 1 then
            l_debug_line := '      '||'Old: Node: '||g_nodes(l_loop_index).node_level||' :'||lpad(l_loop_index,10)||':'||lpad(g_nodes(l_loop_index).qoh,8)||':'||lpad(g_nodes(l_loop_index).rqoh,8);
            print_debug(l_debug_line||':'||lpad(g_nodes(l_loop_index).qr,8)||':'||lpad(g_nodes(l_loop_index).qs,8)||':'||lpad(g_nodes(l_loop_index).att,8)||':'||lpad(g_nodes(l_loop_index).atr,8),12);
         end if;

         print_debug('loop3, node_index='||l_loop_index||' qoh='||g_nodes(l_loop_index).qoh||' rqoh='||g_nodes(l_loop_index).rqoh||' qr='||g_nodes(l_loop_index).qr||' qs='||g_nodes(l_loop_index).qs);
         print_debug(' ... att='||g_nodes(l_loop_index).att||' atr='||g_nodes(l_loop_index).atr);
         print_debug('.. sqoh='||g_nodes(l_loop_index).sqoh||' srqoh='||g_nodes(l_loop_index).srqoh||' sqr='||g_nodes(l_loop_index).sqr||' sqs='||g_nodes(l_loop_index).sqs);
         print_debug(' .... satt='||g_nodes(l_loop_index).satt||' satr='||g_nodes(l_loop_index).satr);

         --update att/atr for loose only mode
         IF l_tree_mode = g_loose_only_mode THEN
            print_debug('... in add_qty,3... mode=loose_only');
            --old factor = QS+QR-PQOH
            l_old_factor := g_nodes(l_loop_index).qs + g_nodes(l_loop_index).qr - g_nodes(l_loop_index).pqoh;
            l_old_factor2 := g_nodes(l_loop_index).sqs + g_nodes(l_loop_index).sqr - g_nodes(l_loop_index).spqoh;

            --new factor = QS+ (change to QS) +QR-PQOH
            l_new_factor := l_old_factor + p_primary_quantity;
            l_new_factor2 := NVL(l_old_factor2, 0) + p_secondary_quantity;


            if l_old_factor > 0 then
               IF l_new_factor > 0 THEN
                  l_update_quantity:= 0.0 - p_primary_quantity;
                  l_update_quantity2:= 0.0 - p_secondary_quantity;
               ELSE  -- old factor > 0, new factor <= 0
                  l_update_quantity := l_old_factor;
                  l_update_quantity2 := l_old_factor2;
               END IF;
            else -- l_old_factor <=0
               IF l_new_factor > 0 THEN
                  l_update_quantity:= 0.0 - l_new_factor;
                  l_update_quantity2:= 0.0 - l_new_factor2;

               ELSE  -- old factor < 0, new factor <= 0
                  l_update_quantity:= 0;
                  l_update_quantity2:= 0;
               END IF;
            end if;

            -- Start of fix for the Bug 4294336
            IF NVL(p_transaction_action_id,-1 ) = 2  THEN
               IF  g_nodes(l_loop_index).node_level = g_locator_level THEN
                  IF  NVL(g_nodes(l_loop_index).locator_id,-99) <> NVL(p_transfer_locator_id,-999) THEN
                       -- update qs
                       print_debug('... in add_qty,3... updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                       g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                       g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                       --update att
                       g_nodes(l_loop_index).att := g_nodes(l_loop_index).att + l_update_quantity;
                       g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) + l_update_quantity2;

                       if l_is_reservable_sub then
                          print_debug('in add_qty,3 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||l_update_quantity);
                          --update atr
                          g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr + l_update_quantity;
                          g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) + l_update_quantity2;
                       else
                          print_debug('in add_qty,3 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                       end if;

                  END IF;
               ELSIF g_nodes(l_loop_index).node_level = g_sub_level  THEN
                  IF g_nodes(l_loop_index).subinventory_code <> p_transfer_subinventory_code THEN
                       -- update qs
                       print_debug('... in add_qty,3... updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                       g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                       g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                       --update att
                       g_nodes(l_loop_index).att := g_nodes(l_loop_index).att + l_update_quantity;
                       g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) + l_update_quantity2;

                       if l_is_reservable_sub then
                          print_debug('in add_qty,3 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||l_update_quantity);
                          --update atr
                          g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr + l_update_quantity;
                          g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) + l_update_quantity2;
                       else
                          print_debug('in add_qty,3 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                       end if;
                  END IF;
               ELSIF g_nodes(l_loop_index).node_level = g_lot_level THEN
                  IF NVL(g_nodes(l_loop_index).lot_number,'@#$') =  NVL(p_lot_number,'$#@') THEN
                       -- update qs
                       print_debug('... in add_qty,3... updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                       g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                       g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                       --update att
                       g_nodes(l_loop_index).att := g_nodes(l_loop_index).att + l_update_quantity;
                       g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) + l_update_quantity2;

                       if l_is_reservable_sub then
                          print_debug('in add_qty,3 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||l_update_quantity);
                          --update atr
                          g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr + l_update_quantity;
                          g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) + l_update_quantity2;
                       else
                          print_debug('in add_qty,3 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                       end if;
                  END IF;
               ELSIF  g_nodes(l_loop_index).node_level = g_revision_level THEN
                  IF NVL(g_nodes(l_loop_index).revision,'@#$') =  NVL(p_revision,'$#@') THEN
                       -- update qs
                       print_debug('... in add_qty,3... updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                       g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                       g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                       --update att
                       g_nodes(l_loop_index).att := g_nodes(l_loop_index).att + l_update_quantity;
                       g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) + l_update_quantity2;

                       if l_is_reservable_sub then
                          print_debug('in add_qty,3 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||l_update_quantity);
                          --update atr
                          g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr + l_update_quantity;
                          g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) + l_update_quantity2;
                       else
                          print_debug('in add_qty,3 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                       end if;
                  END IF;
               ELSIF g_nodes(l_loop_index).node_level = g_item_level THEN
                  NULL;
               ELSE
                  -- update qs
                  print_debug('... in add_qty,3... updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                  g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                  g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                  --update att
                  g_nodes(l_loop_index).att := g_nodes(l_loop_index).att + l_update_quantity;
                  g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) + l_update_quantity2;

                  if l_is_reservable_sub then
                     print_debug('in add_qty,3 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||l_update_quantity);
                     --update atr
                     g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr + l_update_quantity;
                     g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) + l_update_quantity2;
                  else
                     print_debug('in add_qty,3 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                  end if;
               END IF;  --Node Level Check
               /*
                IF g_nodes(l_loop_index).node_level = g_item_level AND l_qty_chk_flag THEN
                  g_nodes(l_loop_index).qs_adj := g_nodes(l_loop_index).qs_adj + p_primary_quantity;
                  l_qty_chk_flag := FALSE;
                END IF;
               */
               IF g_nodes(l_loop_index).node_level IN ( g_lot_level , g_revision_level , g_item_level)
                 AND p_transfer_subinventory_code IS NOT NULL
                 AND NOT l_is_reservable_xfer_sub THEN
                  g_nodes(l_loop_index).qs_adj1 := g_nodes(l_loop_index).qs_adj1 + p_primary_quantity;
                  g_nodes(l_loop_index).sqs_adj1 := g_nodes(l_loop_index).sqs_adj1 + p_secondary_quantity;
                   /* Added for bug 7323112 */
                  IF p_subinventory_code IS NOT NULL AND NOT l_is_reservable_sub THEN
                     g_nodes(l_loop_index).qs_adj1 := g_nodes(l_loop_index).qs_adj1 - p_primary_quantity;
                     g_nodes(l_loop_index).sqs_adj1 := g_nodes(l_loop_index).sqs_adj1 - p_secondary_quantity;
                  END IF;
                   /* End of changes for bug 7323112 */
               END IF;

            ELSE
               -- update qs
               print_debug('... in add_qty,3... updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
               g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
               g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

               --update att
               g_nodes(l_loop_index).att := g_nodes(l_loop_index).att + l_update_quantity;
               g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) + l_update_quantity2;

               if l_is_reservable_sub then
                 print_debug('in add_qty,3 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||l_update_quantity);
                 --update atr
                 g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr + l_update_quantity;
                 g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) + l_update_quantity2;
               else
                  print_debug('in add_qty,3 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
               end if;

            END IF;

         ELSE -- not in loose items only mode
            -- Start of fix for the Bug 4294336
            IF NVL(p_transaction_action_id,-1 ) = 2  THEN
               IF  g_nodes(l_loop_index).node_level = g_locator_level THEN
                  IF  NVL(g_nodes(l_loop_index).locator_id,-99) <> NVL(p_transfer_locator_id,-999) THEN
                     print_debug('... in add_qty,3... NOT loose mode, updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                     -- update qs
                     g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                     g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                     --update att
                     g_nodes(l_loop_index).att := g_nodes(l_loop_index).att - p_primary_quantity;
                     g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) - p_secondary_quantity;

                     if l_is_reservable_sub then
                        print_debug('in add_qty,4 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||p_primary_quantity);
                        --update atr
                        g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr - p_primary_quantity;
                        g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) - p_secondary_quantity;
                     else
                        print_debug('in add_qty,4 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                     end if;
                  END IF;
               ELSIF g_nodes(l_loop_index).node_level = g_sub_level  THEN
                  IF g_nodes(l_loop_index).subinventory_code <> p_transfer_subinventory_code THEN
                     print_debug('... in add_qty,3... NOT loose mode, updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                     -- update qs
                     g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                     g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                     --update att
                     g_nodes(l_loop_index).att := g_nodes(l_loop_index).att - p_primary_quantity;
                     g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) - p_secondary_quantity;

                     if l_is_reservable_sub then
                        print_debug('in add_qty,4 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||p_primary_quantity);
                        --update atr
                        g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr - p_primary_quantity;
                        g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) - p_secondary_quantity;
                     else
                        print_debug('in add_qty,4 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                     end if;
                     -- l_qty_chk_flag := TRUE;
                  END IF;
               ELSIF g_nodes(l_loop_index).node_level = g_lot_level THEN
                  IF NVL(g_nodes(l_loop_index).lot_number,'@#$') =  NVL(p_lot_number,'$#@') THEN
                     print_debug('... in add_qty,3... NOT loose mode, updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                     -- update qs
                     g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                     g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                     --update att
                     g_nodes(l_loop_index).att := g_nodes(l_loop_index).att - p_primary_quantity;
                     g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) - p_secondary_quantity;

                     if l_is_reservable_sub then
                        print_debug('in add_qty,4 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||p_primary_quantity);
                        --update atr
                        g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr - p_primary_quantity;
                        g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) - p_secondary_quantity;
                     else
                        print_debug('in add_qty,4 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                     end if;
                     -- l_qty_chk_flag := TRUE;
                  END IF;
               ELSIF  g_nodes(l_loop_index).node_level = g_revision_level THEN
                  IF NVL(g_nodes(l_loop_index).revision,'@#$') = NVL(p_revision,'$#@') THEN
                     print_debug('... in add_qty,3... NOT loose mode, updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                     -- update qs
                     g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                     g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                     --update att
                     g_nodes(l_loop_index).att := g_nodes(l_loop_index).att - p_primary_quantity;
                     g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) - p_secondary_quantity;

                     if l_is_reservable_sub then
                        print_debug('in add_qty,4 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||p_primary_quantity);
                        --update atr
                        g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr - p_primary_quantity;
                        g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) - p_secondary_quantity;
                     else
                        print_debug('in add_qty,4 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                     end if;
                     --   l_qty_chk_flag := TRUE;
                  END IF;
               ELSIF g_nodes(l_loop_index).node_level = g_item_level THEN
                  NULL;
               ELSE
                  print_debug('... in add_qty,3... NOT loose mode, updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
                  -- update qs
                  g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
                  g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

                  --update att
                  g_nodes(l_loop_index).att := g_nodes(l_loop_index).att - p_primary_quantity;
                  g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) - p_secondary_quantity;

                  if l_is_reservable_sub then
                     print_debug('in add_qty,4 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||p_primary_quantity);
                     --update atr
                     g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr - p_primary_quantity;
                     g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) - p_secondary_quantity;
                  else
                     print_debug('in add_qty,4 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
                  end if;
                  -- l_qty_chk_flag := TRUE;
               END IF;  --Node Level Check
               /*
               IF g_nodes(l_loop_index).node_level = g_item_level AND l_qty_chk_flag THEN
                  g_nodes(l_loop_index).qs_adj := g_nodes(l_loop_index).qs_adj + p_primary_quantity;
                  l_qty_chk_flag := FALSE;
               END IF;
                */
               IF g_nodes(l_loop_index).node_level IN ( g_lot_level , g_revision_level , g_item_level)
                  AND p_transfer_subinventory_code IS NOT NULL
                  AND NOT l_is_reservable_xfer_sub THEN
                  g_nodes(l_loop_index).qs_adj1 := g_nodes(l_loop_index).qs_adj1 + p_primary_quantity;
                  g_nodes(l_loop_index).sqs_adj1 := g_nodes(l_loop_index).sqs_adj1 + p_secondary_quantity;
                   /* Added for bug 7323112 */
                  IF p_subinventory_code IS NOT NULL AND NOT l_is_reservable_sub THEN
                     g_nodes(l_loop_index).qs_adj1 := g_nodes(l_loop_index).qs_adj1 - p_primary_quantity;
                     g_nodes(l_loop_index).sqs_adj1 := g_nodes(l_loop_index).sqs_adj1 - p_secondary_quantity;
                  END IF;
                  /* End of changes for bug 7323112 */

               END IF;

            ELSE
               print_debug('... in add_qty,3... NOT loose mode, updating qs with trx_qty...qs='||g_nodes(l_loop_index).qs||', trx_qty='||p_primary_quantity);
               -- update qs
               g_nodes(l_loop_index).qs := g_nodes(l_loop_index).qs + p_primary_quantity;
               g_nodes(l_loop_index).sqs := NVL(g_nodes(l_loop_index).sqs, 0) + p_secondary_quantity;

               --update att
               g_nodes(l_loop_index).att := g_nodes(l_loop_index).att - p_primary_quantity;
               g_nodes(l_loop_index).satt := NVL(g_nodes(l_loop_index).satt, 0) - p_secondary_quantity;

               if l_is_reservable_sub then
                  print_debug('in add_qty,4 rsv=TRUE, newATR='||g_nodes(l_loop_index).atr||' + '||p_primary_quantity);
                  --update atr
                  g_nodes(l_loop_index).atr := g_nodes(l_loop_index).atr - p_primary_quantity;
                  g_nodes(l_loop_index).satr := NVL(g_nodes(l_loop_index).satr, 0) - p_secondary_quantity;
               else
                  print_debug('in add_qty,4 rsv=FALSE, newATR='||g_nodes(l_loop_index).atr||' + 0');
               end if;
               -- l_qty_chk_flag := TRUE;
            END IF; --Action Id 2 check

         END IF;

         -- set check mark

         -- Bug 2486318. The do check does not work. Trasactions get committed
         -- even if there is a node violation. Added p_check_mark_node_only to mark the nodes.

         IF (p_set_check_mark = TRUE or
           p_check_mark_node_only = fnd_api.g_true AND p_primary_quantity < 0 )THEN
               g_nodes(l_loop_index).check_mark := TRUE;
         END IF;

         IF g_debug = 1 THEN
            l_debug_line := '      '||'New: Node: '||g_nodes(l_loop_index).node_level||' :'||lpad(l_loop_index,10)||':'||lpad(g_nodes(l_loop_index).qoh,8)||':'||lpad(g_nodes(l_loop_index).rqoh,8);
            print_debug(l_debug_line||':'||lpad(g_nodes(l_loop_index).qr,8)||':'||lpad(g_nodes(l_loop_index).qs,8)||':'||lpad(g_nodes(l_loop_index).att,8)||':'||lpad(g_nodes(l_loop_index).atr,8),12);
         END IF;

         IF (g_nodes(l_loop_index).node_level = g_item_level) THEN
            EXIT;
         END IF;

         l_loop_index := g_nodes(l_loop_index).parent_index;
      END LOOP;


   END IF;

   IF p_set_check_mark = TRUE THEN
      -- we will mark other trees with the same org and item id
      -- as need refresh since the update may render
      -- those trees as outdated
      /* Performance - don't loop through all trees
      FOR l_rootinfo_index IN 1..g_all_roots_counter LOOP
         l_root_id := g_all_roots(l_rootinfo_index);
         IF p_tree_id <> l_root_id
            AND (g_rootinfos(l_root_id).organization_id = g_rootinfos(p_tree_id).organization_id
             AND g_rootinfos(l_root_id).inventory_item_id = g_rootinfos(p_tree_id).inventory_item_id)
         THEN
            g_rootinfos(l_root_id).need_refresh := TRUE;
         END IF;
      END LOOP;
      */

      l_hash_string := g_rootinfos(p_tree_id).organization_id
        || ':' || g_rootinfos(p_tree_id).inventory_item_id;
      l_org_item_index := dbms_utility.get_hash_value(
                        name       => l_hash_string
                       ,base       => l_hash_base
                       ,hash_size  => l_hash_size);
      If g_org_item_trees.exists(l_org_item_index) Then
         l_tree_index  := g_org_item_trees(l_org_item_index);
         LOOP
            EXIT WHEN l_tree_index = 0;
            l_root_id := g_all_roots(l_tree_index).root_id;
            if l_root_id <> p_tree_id then
               g_rootinfos(l_root_id).need_refresh := TRUE;
            end if;
            l_tree_index := g_all_roots(l_tree_index).next_root;
         END LOOP;
      End If;
   END IF;

   print_debug('Normal end of add_quantities...');
   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      print_debug('in add_quantities... EXP_ERROR sql='||SQLERRM,9);
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      print_debug('in add_quantities... UNEXP_ERROR sql='||SQLERRM,9);
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      print_debug('in add_quantities... OTHERS ERROR sql='||SQLERRM,9);
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'Add_Quantities'
              ,9);
      END IF;
END add_quantities;

-- Procedure
--   build_tree
-- Description
--   build the tree by querying the database tables and compute quantities
PROCEDURE build_tree
  (  x_return_status         OUT NOCOPY VARCHAR2
     , p_tree_id             IN  INTEGER
    ) IS
   l_api_name                    VARCHAR2(30) := 'BUILD_TREE';
   l_return_status               VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_is_reservable_sub           BOOLEAN;
   l_cursor                      NUMBER;
   l_dummy                       INTEGER;
   l_index_start                 NUMBER := 0;
   l_num_recs_fetch              NUMBER := 100;
   l_cur_num_rows                NUMBER := 0;
   l_tot_num_rows                NUMBER := 0;
   l_index                       NUMBER := 0;

   l_revision_control            NUMBER;
   l_no_lpn_reservations         NUMBER;
   l_tree_mode                   NUMBER;
   l_demand_source_type_id       NUMBER;
   l_demand_source_header_id     NUMBER;
   l_demand_source_line_id       NUMBER;
   l_demand_source_name          VARCHAR2(30);
   l_demand_source_delivery      NUMBER;
   l_organization_id             NUMBER;
   l_inventory_item_id           NUMBER;
   l_subinventory_code           VARCHAR2(30);
   l_locator_id                  NUMBER;
   l_lot_number                  VARCHAR2(80);
   l_primary_quantity            NUMBER;
   l_asset_subs_only             NUMBER;
   l_onhand_source               NUMBER;
   l_lot_expiration_control      NUMBER;
   l_lot_expiration_date         DATE;
   lot_control_code               NUMBER;   -- Bug 7628989
   l_grade_code                  VARCHAR2(150);

   v_revision                    bulk_varchar_3_tbl_type;
   v_lot_number                  bulk_varchar_80_tbl_type;
   v_subinventory_code           bulk_varchar_10_tbl_type;
   v_lot_expiration_date         bulk_date_tbl_type;
   v_reservable_type             bulk_num_tbl_type;
   v_primary_quantity            bulk_num_tbl_type;
   v_secondary_quantity          bulk_num_tbl_type;
   v_quantity_type               bulk_num_tbl_type;
   v_locator_id                  bulk_num_tbl_type;
   v_inventory_item_id           bulk_num_tbl_type;
   v_organization_id             bulk_num_tbl_type;
   v_cost_group_id               bulk_num_tbl_type;
   v_lpn_id                      bulk_num_tbl_type;

   v_transaction_action_id       bulk_num_tbl_type;
   v_transfer_subinventory_code  bulk_varchar_10_tbl_type;
   v_transfer_locator_id         bulk_num_tbl_type;

   v_status_id                   bulk_num_tbl_type; -- Onhand Material Status Support
   v_is_reservable_lot           bulk_num_tbl_type;   --Bug#8713821

-- Onhand Material Status Support: Modified the queries to check for availability_type
-- and atpable_type from MOQD's status if the status is tracked at the onhand level.

     CURSOR c_plain IS
     SELECT
          x.organization_id               organization_id
        , x.inventory_item_id             inventory_item_id
        , x.revision                      revision
        , NULL                            lot_number
        , NULL                            lot_expiration_date
        , x.subinventory_code             subinventory_code
        , sub.reservable_type             reservable_type
        , x.locator_id                    locator_id
        , SUM(x.primary_quantity)         primary_quantity
        , SUM(x.secondary_quantity)       secondary_quantity
        , x.quantity_type                 quantity_type
        , x.cost_group_id                 cost_group_id
        , x.lpn_id                        lpn_id
        , x.transaction_action_id         transaction_action_id
        , x.transfer_subinventory_code    transfer_subinventory_code
        , x.transfer_locator_id           transfer_locator_id
        , NULL                          is_reservable_lot       --Bug#8713821
     FROM (
       SELECT
           x.organization_id                                organization_id
         , x.inventory_item_id                              inventory_item_id
         , decode(l_revision_control, 2, NULL, x.revision)  revision
         , NULL                                             lot_number
         , x.subinventory_code                              subinventory_code
         , x.locator_id                                     locator_id
         , SUM(x.primary_quantity)                          primary_quantity
         , SUM(x.secondary_quantity)                        secondary_quantity
         , x.quantity_type                                  quantity_type
         , x.cost_group_id                                  cost_group_id
         , x.lpn_id                                         lpn_id
         , x.transaction_action_id                          transaction_action_id
         , x.transfer_subinventory_code                     transfer_subinventory_code
         , x.transfer_locator_id                            transfer_locator_id
        FROM (
          -- reservations
          SELECT
             mr.organization_id                                                        organization_id
           , mr.inventory_item_id                                                      inventory_item_id
           , mr.revision                                                               revision
           , mr.lot_number                                                             lot_number
           , mr.subinventory_code                                                      subinventory_code
           , mr.locator_id                                                             locator_id
           , mr.primary_reservation_quantity - Nvl(mr.detailed_quantity,0)             primary_quantity
           , mr.secondary_reservation_quantity - Nvl(mr.secondary_detailed_quantity,0) secondary_quantity
           , 3                                                                         quantity_type
           , to_number(NULL)                                                           cost_group_id
           , lpn_id                                                                    lpn_id
           , to_number(NULL)                                                           transaction_action_id
           , to_char(NULL)                                                             transfer_subinventory_code
           , to_number(NULL)                                                           transfer_locator_id
        FROM mtl_reservations mr
        WHERE
             Nvl(mr.supply_source_type_id, 13) = 13
         AND mr.primary_reservation_quantity > Nvl(mr.detailed_quantity,0)
         AND ((l_no_lpn_reservations <>1) OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
         AND (l_tree_mode <> 3 OR
                (l_tree_mode = 3
                 AND NOT (    l_demand_source_type_id = mr.demand_source_type_id
                          AND l_demand_source_header_id = mr.demand_source_header_id
                          AND Nvl(l_demand_source_line_id, -9999) = Nvl(mr.demand_source_line_id,-9999)
                          AND Nvl(l_demand_source_name, '@@@###@@#') = Nvl(mr.demand_source_name,'@@@###@@#')
                          AND Nvl(l_demand_source_delivery,-9999) = Nvl(mr.demand_source_delivery,-9999)
                         )
                )
             )
        UNION ALL
          -- onhand quantities
          SELECT
             moq.organization_id                   organization_id
           , moq.inventory_item_id                 inventory_item_id
           , moq.revision                          revision
           , moq.lot_number                        lot_number
           , moq.subinventory_code                 subinventory_code
           , moq.locator_id                        locator_id
           , moq.primary_transaction_quantity
           , moq.secondary_transaction_quantity
           , 1                                     quantity_type
           , moq.cost_group_id                     cost_group_id
           , moq.lpn_id                            lpn_id
           , to_number(NULL)                       transaction_action_id
           , to_char(NULL)                         transfer_subinventory_code
           , to_number(NULL)                       transfer_locator_id
          FROM
             mtl_onhand_quantities_detail       moq

        UNION ALL
          -- pending transactions in mmtt
          SELECT
               mmtt.organization_id                                                                organization_id
             , mmtt.inventory_item_id                                                              inventory_item_id
             , mmtt.revision                                                                       revision
             , NULL                                                                                lot_number
             , mmtt.subinventory_code                                                              subinventory_code
             , mmtt.locator_id                                                                     locator_id
             --Bug 4185621
             --, Decode(mmtt.transaction_status, 2, 1,
             , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status)
                      , 2, 1, Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,Sign(mmtt.primary_quantity)))
               * round(Abs(mmtt.primary_quantity),5)
             --Bug 4185621
             --, Decode(mmtt.transaction_status, 2, 1,
             , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status)
                      , 2, 1, Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,Sign(mmtt.secondary_transaction_quantity)))
               * round(Abs(mmtt.secondary_transaction_quantity),5)
             --Bug 4185621
             --, Decode(mmtt.transaction_status, 2, 5, 1)  quantity_type
             , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)   quantity_type
             , mmtt.cost_group_id                                                                  cost_group_id
             , NVL(mmtt.allocated_lpn_id,NVL(mmtt.content_lpn_id, mmtt.lpn_id))                    lpn_id
             , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL))    transaction_action_id
             , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL))      transfer_subinventory_code
             , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))     transfer_locator_id
          FROM
               mtl_material_transactions_temp mmtt
          WHERE
               mmtt.posting_flag = 'Y'
           AND mmtt.subinventory_code IS NOT NULL
           AND (Nvl(mmtt.transaction_status,0) <> 2 OR
                Nvl(mmtt.transaction_status,0) = 2 AND mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34))
           -- dont look at scrap and costing txns
           -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
           AND mmtt.transaction_action_id NOT IN (5,6,24,30)

        UNION ALL
          -- receiving side of transfers
          -- added 5/23/00
          -- if quantity is in an lpn, then it is containerized
          -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
          SELECT
               Decode(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)   organization_id
             , mmtt.inventory_item_id                                                                    inventory_item_id
             , mmtt.revision                                                                             revision
             , NULL                                                                                      lot_number
             , mmtt.transfer_subinventory                                                                subinventory_code
             , mmtt.transfer_to_location                                                                 locator_id
             , round(Abs(mmtt.primary_quantity),5)
             , round(Abs(mmtt.secondary_transaction_quantity),5)
             , 1                                                                                         quantity_type
             , mmtt.transfer_cost_group_id                                                               cost_group_id
             , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id)                                             lpn_id
             , to_number(NULL)                                                                           transaction_action_id
             , to_char(NULL)                                                                             transfer_subinventory_code
             , to_number(NULL)                                                                           transfer_locator_id
          FROM
               mtl_material_transactions_temp mmtt
          WHERE
               mmtt.posting_flag = 'Y'
           AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
           AND mmtt.transaction_action_id IN (2,28,3)

           --bug 3581133
           AND mmtt.wip_supply_type IS NULL
             ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number, x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id
             ) x
             , mtl_secondary_inventories sub
  WHERE
        x.organization_id    = sub.organization_id          (+)
    AND x.subinventory_code  = sub.secondary_inventory_name (+)
    AND (l_asset_subs_only = 2 OR NVL(sub.asset_inventory,1) = 1)
    AND (  (l_onhand_source = 1 AND Nvl(sub.inventory_atp_code, 1) = 1)
        OR (l_onhand_source = 2 AND Nvl(sub.availability_type, 1) = 1 )
        OR l_onhand_source =3
        OR (l_onhand_source = 4 AND (nvl(sub.inventory_atp_code,1) = 1 AND nvl(sub.availability_type,1)=1))
        )
    GROUP BY
          x.organization_id
        , x.inventory_item_id
        , x.revision
        , NULL
        , NULL
        , sub.reservable_type
        , x.subinventory_code
        , NULL
        , x.locator_id
        , x.quantity_type
        , x.cost_group_id
        , x.lpn_id
        , x.transaction_action_id
        , x.transfer_subinventory_code
        , x.transfer_locator_id;

     -- invConv changes begin : c_plain with MMS about ATP/Nettable...
     CURSOR c_plain_MMS IS
     SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
   , NULL           lot_number
        , NULL              lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , SUM(x.primary_quantity)     primary_quantity
        , SUM(x.secondary_quantity)   secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , x.status_id
        , NULL                         is_reservable_lot       --Bug#8713821
     FROM (
       SELECT
           x.organization_id                                organization_id
         , x.inventory_item_id                              inventory_item_id
         , decode(l_revision_control, 2, NULL, x.revision)  revision
         , NULL                                             lot_number
         , x.subinventory_code                              subinventory_code
         , x.locator_id                                     locator_id
         , SUM(x.primary_quantity)                          primary_quantity
         , SUM(x.secondary_quantity)                        secondary_quantity
         , x.quantity_type                                  quantity_type
         , x.cost_group_id                                  cost_group_id
         , x.lpn_id                                         lpn_id
         , x.transaction_action_id                          transaction_action_id
         , x.transfer_subinventory_code                     transfer_subinventory_code
         , x.transfer_locator_id                            transfer_locator_id
         , x.status_id
        FROM (
       -- reservations
       SELECT
          mr.organization_id                                                        organization_id
        , mr.inventory_item_id                                                      inventory_item_id
        , mr.revision                                                               revision
        , mr.lot_number                                                             lot_number
        , mr.subinventory_code                                                      subinventory_code
        , mr.locator_id                                                             locator_id
        , mr.primary_reservation_quantity - Nvl(mr.detailed_quantity,0)             primary_quantity
        , mr.secondary_reservation_quantity - Nvl(mr.secondary_detailed_quantity,0) secondary_quantity
        , 3                                                                         quantity_type
        , to_number(NULL)                                                           cost_group_id
        , lpn_id                                                                    lpn_id
        , to_number(NULL)                                                           transaction_action_id
        , to_char(NULL)                                                             transfer_subinventory_code
        , to_number(NULL)                                                           transfer_locator_id
        , to_number(NULL)                                                           status_id -- Onhand Material Status Support
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity >
      Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
      AND NOT (l_demand_source_type_id = mr.demand_source_type_id
                AND l_demand_source_header_id = mr.demand_source_header_id
            AND Nvl(l_demand_source_line_id, -9999) =
         Nvl(mr.demand_source_line_id,-9999)
            AND Nvl(l_demand_source_name, '@@@###@@#') =
         Nvl(mr.demand_source_name,'@@@###@@#')
                AND Nvl(l_demand_source_delivery,-9999) =
         Nvl(mr.demand_source_delivery,-9999)
                   )
        ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , moq.primary_transaction_quantity
        , moq.secondary_transaction_quantity
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
        , moq.status_id                     -- Onhand Material Status Support
       FROM
          mtl_onhand_quantities_detail       moq
     UNION ALL
       -- pending transactions in mmtt
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , NULL              lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
     --, Decode(mmtt.transaction_status, 2, 1,
     , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
            Sign(mmtt.primary_quantity)))
         * round(Abs(mmtt.primary_quantity),5)
     --Bug 4185621
     --, Decode(mmtt.transaction_status, 2, 1,
     , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
            Sign(mmtt.secondary_transaction_quantity)))
         * round(Abs(mmtt.secondary_transaction_quantity),5)
     --Bug 4185621
     --, Decode(mmtt.transaction_status, 2, 5, 1)  quantity_type
     , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
          ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
          , inv_material_status_grp.get_default_status(mmtt.organization_id
                                          ,mmtt.inventory_item_id
                                          ,mmtt.subinventory_code
                                          ,mmtt.locator_id
                                          ,null -- lot_number
                                          ,NVL(mmtt.allocated_lpn_id,
                                 NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                          ) status_id -- Onhand Material Status Support
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
              mmtt.posting_flag = 'Y'
       AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
         Nvl(mmtt.transaction_status,0) = 2 AND
         mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
        )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
       UNION ALL
       -- receiving side of transfers
       -- added 5/23/00
       -- if quantity is in an lpn, then it is containerized
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , NULL                         lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs(mmtt.primary_quantity),5)
          , round(Abs(mmtt.secondary_transaction_quantity),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
          , inv_material_status_grp.get_default_status(Decode(mmtt.transaction_action_id
                                               , 3, mmtt.transfer_organization
                                               , mmtt.organization_id)
                                          ,mmtt.inventory_item_id
                                          ,mmtt.transfer_subinventory
                                          ,mmtt.transfer_to_location
                                          ,null -- lot_number
                                          ,NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id)
                                          ,mmtt.transaction_action_id
                                          ,inv_material_status_grp.get_default_status(mmtt.organization_id
                                                  ,mmtt.inventory_item_id
                                                  ,mmtt.subinventory_code
                                                  ,mmtt.locator_id
                                                  ,null -- lot_number
                                                  ,NVL(mmtt.allocated_lpn_id,
                                        NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                                  )
                                          ) status_id -- Onhand Material Status Support
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
         AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
         AND mmtt.transaction_action_id IN (2,28,3)
     --bug 3581133
       AND mmtt.wip_supply_type IS NULL
      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number,x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id, x.status_id -- Onhand Material Status Support
   ) x
    , mtl_secondary_inventories sub
    , mtl_item_locations loc
    , mtl_parameters mp -- Onhand Material Status Support
    , mtl_material_statuses_b mms -- Onhand Material Status Support
  WHERE
        x.organization_id = loc.organization_id  (+)
    AND x.locator_id = loc.inventory_location_id (+)
    AND x.organization_id    = sub.organization_id         (+)
    AND x.subinventory_code = sub.secondary_inventory_name (+)
    AND x.organization_id    = mp.organization_id (+) -- Onhand Material Status Support
    AND x.status_id = mms.status_id (+) -- Onhand Material Status Support
    AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
    AND (
         (mp.default_status_id is null and
          ( (l_onhand_source =1 AND
             Nvl(sub.inventory_atp_code, 1) = 1
             AND Nvl(loc.inventory_atp_code, 1) = 1
       )
            OR (l_onhand_source = 2 AND
       Nvl(sub.availability_type, 1) = 1
                 AND Nvl(loc.availability_type, 1) = 1
          )
       OR l_onhand_source =3
            OR (l_onhand_source = 4 AND
           (nvl(sub.inventory_atp_code,1) = 1
                 AND Nvl(loc.inventory_atp_code, 1) = 1
                 AND Nvl(loc.availability_type, 1) = 1
                 AND nvl(sub.availability_type,1)=1
                )
               )
          )
         )
         OR
         (
          mp.default_status_id is not null and
           ( (l_onhand_source =1 AND
               Nvl(mms.inventory_atp_code, 1) = 1
             )
             OR (l_onhand_source = 2 AND
                 Nvl(mms.availability_type, 1) = 1
           )
        OR l_onhand_source =3
             OR (l_onhand_source = 4 AND
             (nvl(mms.inventory_atp_code,1) = 1
              AND nvl(mms.availability_type,1)=1
                  )
                )
           )
         )
    )
    GROUP BY
          x.organization_id
        , x.inventory_item_id
        , x.revision
        , NULL
        , NULL
        , x.subinventory_code
        , sub.reservable_type
        , x.locator_id
        , x.quantity_type
        , x.cost_group_id
        , x.lpn_id
        , x.transaction_action_id
        , x.transfer_subinventory_code
        , x.transfer_locator_id
        , x.status_id; -- Onhand Material Status Support
     -- invConv changes end : c_plain with MMS about ATP/Nettable...

   --Bug#7628989,add new cursor c_no_lot
   CURSOR c_no_lot IS
      SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
        , NULL        lot_number
        , lot.expiration_date     lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , lot.reservable_type     lot_reservable_type       --Bug#8713821 to check reservable type
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id
         , decode(l_revision_control, 2, NULL, x.revision) revision
         , x.lot_number            lot_number
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
         , x.lpn_id        lpn_id
         , x.transaction_action_id       transaction_action_id
         , x.transfer_subinventory_code  transfer_subinventory_code
         , x.transfer_locator_id         transfer_locator_id
        FROM (
       -- reservations
       SELECT
          mr.organization_id       organization_id
        , mr.inventory_item_id     inventory_item_id
        , mr.revision              revision
        , mr.lot_number            lot_number
        , mr.subinventory_code     subinventory_code
        , mr.locator_id            locator_id
        , mr.primary_reservation_quantity
           - Nvl(mr.detailed_quantity,0)    primary_quantity
        , mr.secondary_reservation_quantity
           - Nvl(mr.secondary_detailed_quantity,0)    secondary_quantity
        , 3                        quantity_type
        , to_number(NULL)      cost_group_id
        , lpn_id           lpn_id
        , to_number(NULL)                      transaction_action_id
        , to_char(NULL)                        transfer_subinventory_code
        , to_number(NULL)                      transfer_locator_id
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity >
        Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
       AND NOT
            ( l_demand_source_type_id = mr.demand_source_type_id
            AND l_demand_source_header_id =  mr.demand_source_header_id
            AND Nvl(l_demand_source_line_id, -9999) =
        Nvl(mr.demand_source_line_id,-9999)
        AND Nvl(l_demand_source_name, '@@@###@@#') =
        Nvl(mr.demand_source_name,'@@@###@@#')
        AND Nvl(l_demand_source_delivery,-9999) =
        Nvl(mr.demand_source_delivery,-9999)
              )
    ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , moq.primary_transaction_quantity
        , moq.secondary_transaction_quantity
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
       FROM
          mtl_onhand_quantities_detail       moq
     UNION ALL
       -- pending transactions in mmtt, lot in MMTT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mmtt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
      --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
        Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
            Sign(mmtt.primary_quantity)))
            * round(Abs(mmtt.primary_quantity),5)
      --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
        Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
            Sign(mmtt.secondary_transaction_quantity)))
            * round(Abs(mmtt.secondary_transaction_quantity),5)
      --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id      cost_group_id
      ,NVL(mmtt.allocated_lpn_id,
        NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
            mmtt.posting_flag = 'Y'
     AND mmtt.lot_number IS NOT NULL
     AND mmtt.subinventory_code IS NOT NULL
     AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
            mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
         )
       -- dont look at scrap and costing txns
       -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
    UNION ALL
       --MMTT records, lot in MTLT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mtlt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
      --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
        Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
        Sign(mmtt.primary_quantity)))
        * round(Abs( mtlt.primary_quantity ),5)
      --Bug 4185621
      --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
        Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
        Sign(mmtt.secondary_transaction_quantity)))
        * round(Abs( mtlt.secondary_quantity ),5)
      --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id      cost_group_id
      ,NVL(mmtt.allocated_lpn_id,
        NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
           mtl_material_transactions_temp mmtt,
       mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
         AND mmtt.lot_number IS NULL
     AND mmtt.subinventory_code IS NOT NULL
     AND (Nvl(mmtt.transaction_status,0) <> 2 OR
          Nvl(mmtt.transaction_status,0) = 2 AND
         mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
       )
       -- dont look at scrap and costing txns
       -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
      --bug 9241240: MMTT with no MTLT
      --             Fix for incorrect ATT/ATR shown in WIP comp issue (MMTT inserted without lot number)
    UNION ALL
       --MMTT records, no lot in MTLT or MMTT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mmtt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
          , round(mmtt.primary_quantity,5)
          , round(mmtt.secondary_transaction_quantity,5)             -- invConv change
          , 1  quantity_type
          , mmtt.cost_group_id      cost_group_id
          , NVL(mmtt.allocated_lpn_id, NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , to_number(NULL)         transaction_action_id
          , to_char(NULL)           transfer_subinventory_code
          , to_number(NULL)         transfer_locator_id
       FROM  mtl_material_transactions_temp mmtt
      WHERE  mmtt.posting_flag = 'Y'
        AND  mmtt.lot_number IS NULL
        AND  mmtt.subinventory_code IS NOT NULL
        AND  mmtt.transaction_status IS NULL
        AND  mmtt.transaction_action_id = 1
        AND  mmtt.transaction_source_type_id = 5
        AND  mmtt.wip_entity_type NOT IN (9,10)
        AND  NOT EXISTS (SELECT 1 FROM mtl_transaction_lots_temp mtlt
                         WHERE mmtt.transaction_temp_id = mtlt.transaction_temp_id)
    UNION ALL
       -- receiving side of transfers, lot in MMTT
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mmtt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mmtt.primary_quantity),5)
          , round(Abs( mmtt.secondary_transaction_quantity),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
      AND mmtt.lot_number IS NOT NULL
      AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
      AND mmtt.transaction_action_id IN (2,28,3)

  UNION ALL
       -- receiving side of transfers, lot in MTLT
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mtlt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mtlt.primary_quantity ),5)
          , round(Abs( mtlt.secondary_quantity ),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt,
        mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NULL
          AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
      AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)

      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number,x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id
   ) x
    , mtl_secondary_inventories sub
    , mtl_lot_numbers lot
 WHERE
   x.organization_id    = sub.organization_id          (+)
   AND x.subinventory_code = sub.secondary_inventory_name (+)
   AND x.organization_id   = lot.organization_id   (+)
   AND x.inventory_item_id = lot.inventory_item_id (+)
   AND x.lot_number        = lot.lot_number        (+)
   AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
   AND ((l_onhand_source = 1 AND
     Nvl(sub.inventory_atp_code, 1) = 1
    ) OR
        (l_onhand_source = 2 AND
         Nvl(sub.availability_type, 1) = 1
    ) OR
    l_onhand_source =3
    OR
    (l_onhand_source = 4 AND
     Nvl(sub.inventory_atp_code, 1) = 1 AND
     Nvl(sub.availability_type, 1) = 1)
      )
   ;

CURSOR c_unit_no_lot IS
   SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
        , NULL        lot_number
        , lot.expiration_date     lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , lot.reservable_type     lot_reservable_type       --Bug#8713821 to check reservable type
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id
         , decode(l_revision_control, 2, NULL
            , x.revision)       revision
         , x.lot_number             lot_number
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
         , x.lpn_id        lpn_id
         , x.transaction_action_id       transaction_action_id
         , x.transfer_subinventory_code  transfer_subinventory_code
         , x.transfer_locator_id         transfer_locator_id
        FROM (
       -- reservations
       SELECT
          mr.organization_id       organization_id
        , mr.inventory_item_id     inventory_item_id
        , mr.revision              revision
        , mr.lot_number            lot_number
        , mr.subinventory_code     subinventory_code
        , mr.locator_id            locator_id
        , mr.primary_reservation_quantity
           - Nvl(mr.detailed_quantity,0)    primary_quantity
        , mr.secondary_reservation_quantity
           - Nvl(mr.secondary_detailed_quantity,0)    secondary_quantity
        , 3                        quantity_type
        , to_number(NULL)         cost_group_id
        , lpn_id           lpn_id
        , to_number(NULL)                      transaction_action_id
        , to_char(NULL)                        transfer_subinventory_code
        , to_number(NULL)                      transfer_locator_id
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity >
        Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
       AND NOT (l_demand_source_type_id = mr.demand_source_type_id
        AND l_demand_source_header_id = mr.demand_source_header_id
        AND Nvl(l_demand_source_line_id, -9999) =
            Nvl(mr.demand_source_line_id,-9999)
        AND Nvl(l_demand_source_name, '@@@###@@#') =
            Nvl(mr.demand_source_name,'@@@###@@#')
        AND Nvl(l_demand_source_delivery,-9999) =
            Nvl(mr.demand_source_delivery,-9999)
              )
      ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , decode(l_demand_source_line_id,
            NULL, sum(moq.primary_transaction_quantity),
            pjm_ueff_onhand.onhand_quantity(
                 l_demand_source_line_id
                ,moq.inventory_item_id
                ,moq.organization_id
                ,moq.revision
                ,moq.subinventory_code
                ,moq.locator_id
                ,moq.lot_number
                ,moq.lpn_id
                ,moq.cost_group_id)
          )
        , decode(l_demand_source_line_id,
            NULL, sum(moq.secondary_transaction_quantity),
            pjm_ueff_onhand.onhand_quantity(
                 l_demand_source_line_id
                ,moq.inventory_item_id
                ,moq.organization_id
                ,moq.revision
                ,moq.subinventory_code
                ,moq.locator_id
                ,moq.lot_number
                ,moq.lpn_id
                ,moq.cost_group_id)
          )
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
       FROM
          mtl_onhand_quantities_detail moq
       GROUP BY moq.organization_id,moq.inventory_item_id,moq.revision,
            moq.subinventory_code,moq.locator_id,moq.lot_number,
            moq.lpn_id,moq.cost_group_id
     UNION ALL
       -- pending transactions in mmtt, lot in MMTT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mmtt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
      --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
        Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
            Sign(mmtt.primary_quantity))) *
        round(Abs(decode(l_demand_source_line_id,
            NULL, mmtt.primary_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                     l_demand_source_line_id
                ,mmtt.transaction_temp_id
                ,mmtt.lot_number
                    ,'Y'
                ,mmtt.inventory_item_id
                ,mmtt.organization_id
                ,mmtt.transaction_source_type_id
                ,mmtt.transaction_source_id
                ,mmtt.rcv_transaction_id
                    ,sign(mmtt.primary_quantity)
                   ),mmtt.primary_quantity
            )
        )),5)
      --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
        Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
            Sign(mmtt.secondary_transaction_quantity))) *
        round(Abs(decode(l_demand_source_line_id,
            NULL, mmtt.secondary_transaction_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                     l_demand_source_line_id
                ,mmtt.transaction_temp_id
                ,mmtt.lot_number
                    ,'Y'
                ,mmtt.inventory_item_id
                ,mmtt.organization_id
                ,mmtt.transaction_source_type_id
                ,mmtt.transaction_source_id
                ,mmtt.rcv_transaction_id
                    ,sign(mmtt.secondary_transaction_quantity)
                   ),mmtt.secondary_transaction_quantity
            )
        )),5)
    --Bug 4185621
        --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
        , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
        , mmtt.cost_group_id        cost_group_id
    ,NVL(mmtt.allocated_lpn_id,
        NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
            mmtt.posting_flag = 'Y'
     AND mmtt.lot_number IS NOT NULL
     AND mmtt.subinventory_code IS NOT NULL
     AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
        mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
         )
       -- dont look at scrap and costing txns
       -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6, 24,30)
    UNION ALL
        --MMTT records, lot in MTLT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mtlt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
      --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
        Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
            Sign(mmtt.primary_quantity))) *
        round(Abs(decode(l_demand_source_line_id,
            NULL, mtlt.primary_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                     l_demand_source_line_id
                ,mmtt.transaction_temp_id
                ,mtlt.lot_number
                    ,'Y'
                ,mmtt.inventory_item_id
                ,mmtt.organization_id
                ,mmtt.transaction_source_type_id
                ,mmtt.transaction_source_id
                ,mmtt.rcv_transaction_id
                    ,sign(mmtt.primary_quantity)
                   ),mtlt.primary_quantity)
        )),5)
      --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
        Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
            Sign(mmtt.secondary_transaction_quantity))) *
        round(Abs(decode(l_demand_source_line_id,
            NULL, mtlt.secondary_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                     l_demand_source_line_id
                ,mmtt.transaction_temp_id
                ,mtlt.lot_number
                    ,'Y'
                ,mmtt.inventory_item_id
                ,mmtt.organization_id
                ,mmtt.transaction_source_type_id
                ,mmtt.transaction_source_id
                ,mmtt.rcv_transaction_id
                    ,sign(mmtt.secondary_transaction_quantity)
                   ),mtlt.secondary_quantity)
        )),5)
     --Bug 4185621
         --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
         , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id      cost_group_id
      ,NVL(mmtt.allocated_lpn_id,
        NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt,
       mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
         AND mmtt.lot_number IS NULL
     AND mmtt.subinventory_code IS NOT NULL
     AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
            mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
         )
       -- dont look at scrap and costing txns
       -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6, 24,30)
       --bug 9241240: MMTT with no MTLT
       --             Fix for incorrect ATT/ATR shown in WIP comp issue (MMTT inserted without lot number)
       UNION ALL
         --MMTT records, no lot in MTLT or MMTT
         SELECT
              mmtt.organization_id    organization_id
            , mmtt.inventory_item_id  inventory_item_id
            , mmtt.revision           revision
            , mmtt.lot_number         lot_number
            , mmtt.subinventory_code  subinventory_code
            , mmtt.locator_id         locator_id
            , -1 * round(Abs(decode (l_demand_source_line_id,
                                         NULL, mmtt.primary_quantity,
                                         Nvl(pjm_ueff_onhand.txn_quantity
                                              (l_demand_source_line_id
                                              ,mmtt.transaction_temp_id
                                              ,mmtt.lot_number
                                              ,'Y'
                                              ,mmtt.inventory_item_id
                                              ,mmtt.organization_id
                                              ,mmtt.transaction_source_type_id
                                              ,mmtt.transaction_source_id
                                              ,mmtt.rcv_transaction_id
                                              ,sign(mmtt.primary_quantity)
                                              )
                                            ,mmtt.primary_quantity)
                                    )
                            ),5
                        )
            , -1 * round(Abs(decode (l_demand_source_line_id,
                                         NULL, mmtt.secondary_transaction_quantity,
                                         Nvl(pjm_ueff_onhand.txn_quantity
                                              (l_demand_source_line_id
                                              ,mmtt.transaction_temp_id
                                              ,mmtt.lot_number
                                              ,'Y'
                                              ,mmtt.inventory_item_id
                                              ,mmtt.organization_id
                                              ,mmtt.transaction_source_type_id
                                              ,mmtt.transaction_source_id
                                              ,mmtt.rcv_transaction_id
                                              ,sign(mmtt.secondary_transaction_quantity)
                                              )
                                           ,mmtt.secondary_transaction_quantity)
                                    )
                            ),5
                        )                                             -- invConv change
            , 1  quantity_type
            , mmtt.cost_group_id        cost_group_id
            , NVL(mmtt.allocated_lpn_id, NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
            , to_number(NULL)           transaction_action_id --5698945
            , to_char(NULL)             transfer_subinventory_code --5698945
            , to_number(NULL)           transfer_locator_id --5698945
         FROM   mtl_material_transactions_temp mmtt
         WHERE  mmtt.posting_flag = 'Y'
           AND  mmtt.lot_number IS NULL
           AND  mmtt.subinventory_code IS NOT NULL
           AND  mmtt.transaction_status IS NULL
           AND  mmtt.transaction_action_id = 1
           AND  mmtt.transaction_source_type_id = 5
           AND  mmtt.wip_entity_type NOT IN (9,10)
           AND  NOT EXISTS (SELECT 1 FROM mtl_transaction_lots_temp mtlt
                            WHERE mmtt.transaction_temp_id = mtlt.transaction_temp_id)
       UNION ALL
       -- receiving side of transfers lot in MMTT
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mmtt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
      , round(Abs(decode(l_demand_source_line_id,
            NULL, mmtt.primary_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                     l_demand_source_line_id
                ,mmtt.transaction_temp_id
                ,mmtt.lot_number
                    ,'Y'
                ,mmtt.inventory_item_id
                ,mmtt.organization_id
                ,mmtt.transaction_source_type_id
                ,mmtt.transaction_source_id
                ,mmtt.rcv_transaction_id
                    ,sign(mmtt.primary_quantity)
                   ),mmtt.primary_quantity)
          )),5)
      , round(Abs(decode(l_demand_source_line_id,
            NULL, mmtt.secondary_transaction_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                     l_demand_source_line_id
                ,mmtt.transaction_temp_id
                ,mmtt.lot_number
                    ,'Y'
                ,mmtt.inventory_item_id
                ,mmtt.organization_id
                ,mmtt.transaction_source_type_id
                ,mmtt.transaction_source_id
                ,mmtt.rcv_transaction_id
                    ,sign(mmtt.secondary_transaction_quantity)
                   ),mmtt.secondary_transaction_quantity)
          )),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id)  lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
     AND mmtt.lot_number IS NOT NULL
     AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
     AND mmtt.transaction_action_id IN (2,28,3)

 UNION ALL
    -- receiving side of transfers  lot in MTLT
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mtlt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
      , round(Abs(decode(l_demand_source_line_id,
            NULL, mtlt.primary_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                     l_demand_source_line_id
                ,mmtt.transaction_temp_id
                ,mtlt.lot_number
                    ,'Y'
                ,mmtt.inventory_item_id
                ,mmtt.organization_id
                ,mmtt.transaction_source_type_id
                ,mmtt.transaction_source_id
                ,mmtt.rcv_transaction_id
                    ,sign(mmtt.primary_quantity)
                   ),mtlt.primary_quantity)
        )),5)
      , round(Abs(decode(l_demand_source_line_id,
            NULL, mtlt.secondary_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                     l_demand_source_line_id
                ,mmtt.transaction_temp_id
                ,mtlt.lot_number
                    ,'Y'
                ,mmtt.inventory_item_id
                ,mmtt.organization_id
                ,mmtt.transaction_source_type_id
                ,mmtt.transaction_source_id
                ,mmtt.rcv_transaction_id
                    ,sign(mmtt.secondary_transaction_quantity)
                   ),mtlt.secondary_quantity)
        )),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       ,mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NULL
          AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
      AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)

      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number,x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id
   ) x
    , mtl_secondary_inventories sub
    , mtl_lot_numbers lot
 WHERE
   x.organization_id    = sub.organization_id          (+)
   AND x.subinventory_code = sub.secondary_inventory_name (+)
   AND x.organization_id   = lot.organization_id   (+)
   AND x.inventory_item_id = lot.inventory_item_id (+)
   AND x.lot_number        = lot.lot_number        (+)
   AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
   AND ((l_onhand_source = 1 AND
        Nvl(sub.inventory_atp_code, 1) = 1
     ) OR
        (l_onhand_source = 2 AND
         Nvl(sub.availability_type, 1) = 1
     ) OR
     l_onhand_source =3
       OR
     (l_onhand_source = 4 AND
        Nvl(sub.inventory_atp_code, 1) = 1 AND
                Nvl(sub.availability_type, 1) = 1
     )
      )
    ;
      --Lot Controlled and Not Unit Effective
      -- invConv change : grade_code filter is in cursor c_lot_grade.
      -- invConv ... no chage here, go and see c_lot_grade
      -- invConv ... no MMS specific change here ... see c_lot_MMS and c_lot_grade_MMS

      CURSOR c_lot IS
      SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
        , x.lot_number       lot_number
        , lot.expiration_date     lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , lot.reservable_type     lot_reservable_type       --Bug#8713821 to check reservable type
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id
         , decode(l_revision_control, 2, NULL, x.revision) revision
         , x.lot_number            lot_number
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
         , x.lpn_id        lpn_id
         , x.transaction_action_id       transaction_action_id
         , x.transfer_subinventory_code  transfer_subinventory_code
         , x.transfer_locator_id         transfer_locator_id
        FROM (
       -- reservations
       SELECT
          mr.organization_id       organization_id
        , mr.inventory_item_id     inventory_item_id
        , mr.revision              revision
        , mr.lot_number            lot_number
        , mr.subinventory_code     subinventory_code
        , mr.locator_id            locator_id
        , mr.primary_reservation_quantity
           - Nvl(mr.detailed_quantity,0)    primary_quantity
        , mr.secondary_reservation_quantity
           - Nvl(mr.secondary_detailed_quantity,0)    secondary_quantity
        , 3                        quantity_type
        , to_number(NULL)     cost_group_id
        , lpn_id        lpn_id
        , to_number(NULL)                      transaction_action_id
        , to_char(NULL)                        transfer_subinventory_code
        , to_number(NULL)                      transfer_locator_id
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity >
       Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
      AND NOT
             ( l_demand_source_type_id = mr.demand_source_type_id
            AND l_demand_source_header_id =  mr.demand_source_header_id
            AND Nvl(l_demand_source_line_id, -9999) =
      Nvl(mr.demand_source_line_id,-9999)
          AND Nvl(l_demand_source_name, '@@@###@@#') =
      Nvl(mr.demand_source_name,'@@@###@@#')
       AND Nvl(l_demand_source_delivery,-9999) =
      Nvl(mr.demand_source_delivery,-9999)
              )
   ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , moq.primary_transaction_quantity
        , moq.secondary_transaction_quantity
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
       FROM
          mtl_onhand_quantities_detail       moq
     UNION ALL
       -- pending transactions in mmtt, lot in MMTT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mmtt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.primary_quantity)))
         * round(Abs(mmtt.primary_quantity),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.secondary_transaction_quantity)))
         * round(Abs(mmtt.secondary_transaction_quantity),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
            mmtt.posting_flag = 'Y'
    AND mmtt.lot_number IS NOT NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
            mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
        )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
    UNION ALL
       --MMTT records, lot in MTLT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mtlt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
      Sign(mmtt.primary_quantity)))
       * round(Abs( mtlt.primary_quantity ),5)
     --Bug 4185621
     --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
      Sign(mmtt.secondary_transaction_quantity)))
       * round(Abs( mtlt.secondary_quantity ),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
           mtl_material_transactions_temp mmtt,
      mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
         AND mmtt.lot_number IS NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
         Nvl(mmtt.transaction_status,0) = 2 AND
        mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
      )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
       UNION ALL
       -- receiving side of transfers, lot in MMTT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mmtt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mmtt.primary_quantity),5)
          , round(Abs( mmtt.secondary_transaction_quantity),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
     AND mmtt.lot_number IS NOT NULL
     AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
      AND mmtt.transaction_action_id IN (2,28,3)

  UNION ALL
       -- receiving side of transfers, lot in MTLT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mtlt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mtlt.primary_quantity ),5)
          , round(Abs( mtlt.secondary_quantity ),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt,
       mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NULL
          AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
          AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)
      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number,x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id
   ) x
    , mtl_secondary_inventories sub
    , mtl_lot_numbers lot
 WHERE
   x.organization_id    = sub.organization_id          (+)
   AND x.subinventory_code = sub.secondary_inventory_name (+)
   AND x.organization_id   = lot.organization_id   (+)
   AND x.inventory_item_id = lot.inventory_item_id (+)
   AND x.lot_number        = lot.lot_number        (+)
   AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
   AND ((l_onhand_source = 1 AND
    Nvl(sub.inventory_atp_code, 1) = 1
      ) OR
        (l_onhand_source = 2 AND
       Nvl(sub.availability_type, 1) = 1
   ) OR
   l_onhand_source =3
   OR
   (l_onhand_source = 4 AND
    Nvl(sub.inventory_atp_code, 1) = 1 AND
    Nvl(sub.availability_type, 1) = 1)
      )
   ;

     CURSOR c_lot_MMS IS
      SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
        , x.lot_number       lot_number
        , lot.expiration_date     lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , x.status_id -- Onhand Material Status Support
        , lot.reservable_type     lot_reservable_type       --Bug#8713821 to check reservable type
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id
         , decode(l_revision_control, 2, NULL, x.revision) revision
         , x.lot_number            lot_number
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
         , x.lpn_id        lpn_id
         , x.transaction_action_id       transaction_action_id
         , x.transfer_subinventory_code  transfer_subinventory_code
         , x.transfer_locator_id         transfer_locator_id
         , x.status_id -- Onhand Material Status Support
        FROM (
       -- reservations
       SELECT
          mr.organization_id       organization_id
        , mr.inventory_item_id     inventory_item_id
        , mr.revision              revision
        , mr.lot_number            lot_number
        , mr.subinventory_code     subinventory_code
        , mr.locator_id            locator_id
        , mr.primary_reservation_quantity
           - Nvl(mr.detailed_quantity,0)    primary_quantity
        , mr.secondary_reservation_quantity
           - Nvl(mr.secondary_detailed_quantity,0)    secondary_quantity
        , 3                        quantity_type
        , to_number(NULL)     cost_group_id
        , lpn_id        lpn_id
        , to_number(NULL)                      transaction_action_id
        , to_char(NULL)                        transfer_subinventory_code
        , to_number(NULL)                      transfer_locator_id
        , to_number(NULL)                      status_id -- Onhand Material Status Support
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity >
       Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
      AND NOT
             ( l_demand_source_type_id = mr.demand_source_type_id
            AND l_demand_source_header_id =  mr.demand_source_header_id
            AND Nvl(l_demand_source_line_id, -9999) =
      Nvl(mr.demand_source_line_id,-9999)
          AND Nvl(l_demand_source_name, '@@@###@@#') =
      Nvl(mr.demand_source_name,'@@@###@@#')
       AND Nvl(l_demand_source_delivery,-9999) =
      Nvl(mr.demand_source_delivery,-9999)
              )
   ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , moq.primary_transaction_quantity
        , moq.secondary_transaction_quantity
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
        , moq.status_id                     -- Onhand Material Status Support
       FROM
          mtl_onhand_quantities_detail       moq
     UNION ALL
       -- pending transactions in mmtt, lot in MMTT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mmtt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.primary_quantity)))
         * round(Abs(mmtt.primary_quantity),5)
      --Bug 4185621
           --, Decode(mmtt.transaction_status, 2, 1,
           , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.secondary_transaction_quantity)))
         * round(Abs(mmtt.secondary_transaction_quantity),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
          , inv_material_status_grp.get_default_status(mmtt.organization_id
                                          ,mmtt.inventory_item_id
                                          ,mmtt.subinventory_code
                                          ,mmtt.locator_id
                                          ,mmtt.lot_number -- lot_number
                                          ,NVL(mmtt.allocated_lpn_id,
                                 NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                          ) status_id -- Onhand Material Status Support
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
            mmtt.posting_flag = 'Y'
-- invConv bug 4074394   removed the fix in v115.141, because it only works
--       when the ingredient item has no inventory.
         AND mmtt.lot_number IS NOT NULL
         AND mmtt.subinventory_code IS NOT NULL
         AND (Nvl(mmtt.transaction_status,0) <> 2 OR
              Nvl(mmtt.transaction_status,0) = 2 AND
              mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
              )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
    UNION ALL
       --MMTT records, lot in MTLT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mtlt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
      Sign(mmtt.primary_quantity)))
       * round(Abs( mtlt.primary_quantity ),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
      Sign(mmtt.secondary_transaction_quantity)))
       * round(Abs( mtlt.secondary_quantity ),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
          , inv_material_status_grp.get_default_status(mmtt.organization_id
                                          ,mmtt.inventory_item_id
                                          ,mmtt.subinventory_code
                                          ,mmtt.locator_id
                                          ,mtlt.lot_number -- lot_number in MTLT
                                          ,NVL(mmtt.allocated_lpn_id,
                                 NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                          ) status_id -- Onhand Material Status Support
       FROM
           mtl_material_transactions_temp mmtt,
           mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
         AND mmtt.lot_number IS NULL
         AND mmtt.subinventory_code IS NOT NULL
         AND (Nvl(mmtt.transaction_status,0) <> 2 OR
              Nvl(mmtt.transaction_status,0) = 2 AND
              mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
              )
          -- dont look at scrap and costing txns
          -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
       --bug 9241240: MMTT with no MTLT
       --             Fix for incorrect ATT/ATR shown in WIP comp issue (MMTT inserted without lot number)
      UNION ALL
         -- pending transactions in mmtt, no lot in MMTT and no MTLT
       SELECT
               mmtt.organization_id    organization_id
             , mmtt.inventory_item_id  inventory_item_id
             , mmtt.revision           revision
             , mmtt.lot_number         lot_number
             , mmtt.subinventory_code  subinventory_code
             , mmtt.locator_id         locator_id
             , round(mmtt.primary_quantity,5)
             , round(mmtt.secondary_transaction_quantity,5)             -- invConv change
             , 1                       quantity_type
             , mmtt.cost_group_id      cost_group_id
             , NVL(mmtt.allocated_lpn_id, NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
             , to_number(NULL)         transaction_action_id
             , to_char(NULL)           transfer_subinventory_code
             , to_number(NULL)         transfer_locator_id
             , inv_material_status_grp.get_default_status(mmtt.organization_id
                                          ,mmtt.inventory_item_id
                                          ,mmtt.subinventory_code
                                          ,mmtt.locator_id
                                          ,NULL --lot number
                                          ,NVL(mmtt.allocated_lpn_id,NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                          ) status_id -- Onhand Material Status Support
       FROM
            mtl_material_transactions_temp mmtt
       WHERE mmtt.posting_flag = 'Y'
         AND mmtt.lot_number IS NULL
         AND mmtt.subinventory_code IS NOT NULL
         AND mmtt.transaction_status IS NULL
         AND mmtt.transaction_action_id = 1
         AND mmtt.transaction_source_type_id = 5
         AND mmtt.wip_entity_type NOT IN (9,10)
         AND NOT EXISTS (SELECT 1 FROM mtl_transaction_lots_temp mtlt
                         WHERE transaction_temp_id = mmtt.transaction_temp_id)
       UNION ALL
       -- receiving side of transfers, lot in MMTT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mmtt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mmtt.primary_quantity),5)
          , round(Abs( mmtt.secondary_transaction_quantity),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
          , inv_material_status_grp.get_default_status(Decode(mmtt.transaction_action_id
                                               , 3, mmtt.transfer_organization
                                               , mmtt.organization_id)
                                          ,mmtt.inventory_item_id
                                          ,mmtt.transfer_subinventory
                                          ,mmtt.transfer_to_location
                                          ,mmtt.lot_number -- lot_number
                                          ,NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id)
                                          ,mmtt.transaction_action_id
                                          ,inv_material_status_grp.get_default_status(mmtt.organization_id
                                                  ,mmtt.inventory_item_id
                                                  ,mmtt.subinventory_code
                                                  ,mmtt.locator_id
                                                  ,mmtt.lot_number -- lot_number
                                                  ,NVL(mmtt.allocated_lpn_id,
                                        NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                                  )
                                          ) status_id -- Onhand Material Status Support
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
     AND mmtt.lot_number IS NOT NULL
     AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
     AND mmtt.transaction_action_id IN (2,28,3)
  UNION ALL
       -- receiving side of transfers, lot in MTLT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mtlt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mtlt.primary_quantity ),5)
          , round(Abs( mtlt.secondary_quantity ),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
          , inv_material_status_grp.get_default_status(Decode(mmtt.transaction_action_id
                                               , 3, mmtt.transfer_organization
                                               , mmtt.organization_id)
                                          ,mmtt.inventory_item_id
                                          ,mmtt.transfer_subinventory
                                          ,mmtt.transfer_to_location
                                          ,mtlt.lot_number -- lot_number
                                          ,NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id)
                                          ,mmtt.transaction_action_id
                                          ,inv_material_status_grp.get_default_status(mmtt.organization_id
                                                  ,mmtt.inventory_item_id
                                                  ,mmtt.subinventory_code
                                                  ,mmtt.locator_id
                                                  ,mtlt.lot_number -- lot_number
                                                  ,NVL(mmtt.allocated_lpn_id,
                                        NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                                  )
                                          ) status_id -- Onhand Material Status Support
       FROM
            mtl_material_transactions_temp mmtt,
       mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NULL
          AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
          AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)
      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number,x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id, x.status_id -- Onhand Material Status Support
   ) x
    , mtl_secondary_inventories sub
    , mtl_item_locations loc
    , mtl_lot_numbers lot
    , mtl_parameters mp -- Onhand Material Status Support
    , mtl_material_statuses_b mms -- Onhand Material Status Support
 WHERE
       x.inventory_item_id = lot.inventory_item_id        (+)
   AND x.organization_id = lot.organization_id            (+)
   AND x.lot_number = lot.lot_number                      (+)
   AND x.organization_id = loc.organization_id            (+)
   AND x.locator_id = loc.inventory_location_id           (+)
   AND x.organization_id    = sub.organization_id         (+)
   AND x.subinventory_code = sub.secondary_inventory_name (+)
   AND x.organization_id   = lot.organization_id   (+)
   AND x.inventory_item_id = lot.inventory_item_id (+)
   AND x.lot_number        = lot.lot_number        (+)
   AND x.organization_id    = mp.organization_id   (+) -- Onhand Material Status Support
   AND x.status_id = mms.status_id                 (+) -- Onhand Material Status Support
   AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
   AND (
        (mp.default_status_id is null and
        ((l_onhand_source = 1 AND
              Nvl(sub.inventory_atp_code, 1) = 1
          AND Nvl(loc.inventory_atp_code, 1) = 1
          AND Nvl(lot.inventory_atp_code, 1) = 1
      ) OR
        (l_onhand_source = 2 AND
                     Nvl(sub.availability_type, 1) = 1
                 AND Nvl(loc.availability_type, 1) = 1
                 AND Nvl(lot.availability_type, 1) = 1
   ) OR
   l_onhand_source =3
   OR
   (l_onhand_source = 4 AND
              Nvl(sub.inventory_atp_code, 1) = 1
          AND Nvl(loc.inventory_atp_code, 1) = 1
          AND Nvl(lot.inventory_atp_code, 1) = 1
          AND Nvl(loc.availability_type, 1) = 1
          AND Nvl(lot.availability_type, 1) = 1
     AND Nvl(sub.availability_type, 1) = 1
        )
      )
      )
      or
      (
        mp.default_status_id is not null and
           ((l_onhand_source =1 AND
               Nvl(mms.inventory_atp_code, 1) = 1
             )
          OR (l_onhand_source = 2 AND
         Nvl(mms.availability_type, 1) = 1
        )
     OR l_onhand_source =3
          OR (l_onhand_source = 4 AND
         (nvl(mms.inventory_atp_code,1) = 1
         AND nvl(mms.availability_type,1)=1
              )
             )
           )
       )
      )
   ;
      -- invConv changes end : c_lot with MMS about ATP/Nettable...

      -- invConv change : grade_code filter is here
      -- invConv .... no MMS specific change, please see c_lot_grade_MMS

      CURSOR c_lot_grade IS
      SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
        , x.lot_number       lot_number
        , lot.expiration_date     lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , lot.reservable_type     lot_reservable_type       --Bug#8713821 to check reservable type
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id
         , decode(l_revision_control, 2, NULL, x.revision) revision
         , x.lot_number            lot_number
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
         , x.lpn_id        lpn_id
         , x.transaction_action_id       transaction_action_id
         , x.transfer_subinventory_code  transfer_subinventory_code
         , x.transfer_locator_id         transfer_locator_id
        FROM (
       -- reservations
       SELECT
          mr.organization_id       organization_id
        , mr.inventory_item_id     inventory_item_id
        , mr.revision              revision
        , mr.lot_number            lot_number
        , mr.subinventory_code     subinventory_code
        , mr.locator_id            locator_id
        , mr.primary_reservation_quantity
           - Nvl(mr.detailed_quantity,0)    primary_quantity
        , mr.secondary_reservation_quantity
           - Nvl(mr.secondary_detailed_quantity,0)    secondary_quantity
        , 3                        quantity_type
        , to_number(NULL)     cost_group_id
        , lpn_id        lpn_id
        , to_number(NULL)                      transaction_action_id
        , to_char(NULL)                        transfer_subinventory_code
        , to_number(NULL)                      transfer_locator_id
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity >
       Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
      AND NOT
             ( l_demand_source_type_id = mr.demand_source_type_id
            AND l_demand_source_header_id =  mr.demand_source_header_id
            AND Nvl(l_demand_source_line_id, -9999) =
      Nvl(mr.demand_source_line_id,-9999)
          AND Nvl(l_demand_source_name, '@@@###@@#') =
      Nvl(mr.demand_source_name,'@@@###@@#')
       AND Nvl(l_demand_source_delivery,-9999) =
      Nvl(mr.demand_source_delivery,-9999)
              )
   ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , moq.primary_transaction_quantity
        , moq.secondary_transaction_quantity
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
       FROM
          mtl_onhand_quantities_detail       moq
     UNION ALL
       -- pending transactions in mmtt, lot in MMTT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mmtt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.primary_quantity)))
         * round(Abs(mmtt.primary_quantity),5)
      --Bug 4185621
           --, Decode(mmtt.transaction_status, 2, 1,
           , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.secondary_transaction_quantity)))
         * round(Abs(mmtt.secondary_transaction_quantity),5)
            --Bug 4185621
            --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
            , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
            mmtt.posting_flag = 'Y'
    AND mmtt.lot_number IS NOT NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
            mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
        )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
    UNION ALL
       --MMTT records, lot in MTLT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mtlt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
      Sign(mmtt.primary_quantity)))
       * round(Abs( mtlt.primary_quantity ),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
      Sign(mmtt.secondary_transaction_quantity)))
       * round(Abs( mtlt.secondary_quantity ),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
           mtl_material_transactions_temp mmtt,
      mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
         AND mmtt.lot_number IS NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
         Nvl(mmtt.transaction_status,0) = 2 AND
        mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
      )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
       UNION ALL
       -- receiving side of transfers, lot in MMTT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mmtt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mmtt.primary_quantity),5)
          , round(Abs( mmtt.secondary_transaction_quantity),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NOT NULL
          AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)
       UNION ALL
       -- receiving side of transfers, lot in MTLT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mtlt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mtlt.primary_quantity ),5)
          , round(Abs( mtlt.secondary_quantity ),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt,
       mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NULL
          AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
          AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)
      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number,x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id
   ) x
    , mtl_secondary_inventories sub
    , mtl_lot_numbers lot
 WHERE
   x.organization_id    = sub.organization_id          (+)
   AND x.subinventory_code = sub.secondary_inventory_name (+)
   AND x.organization_id   = lot.organization_id   (+)
   AND x.inventory_item_id = lot.inventory_item_id (+)
   AND x.lot_number        = lot.lot_number        (+)
   AND l_grade_code = lot.grade_code
   AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
   AND ((l_onhand_source = 1 AND
    Nvl(sub.inventory_atp_code, 1) = 1
      ) OR
        (l_onhand_source = 2 AND
       Nvl(sub.availability_type, 1) = 1
   ) OR
   l_onhand_source =3
   OR
   (l_onhand_source = 4 AND
    Nvl(sub.inventory_atp_code, 1) = 1 AND
    Nvl(sub.availability_type, 1) = 1)
      )
   ;

     CURSOR c_lot_grade_MMS IS
      SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
        , x.lot_number       lot_number
        , lot.expiration_date     lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , x.status_id -- Onhand Material Status Support
        , lot.reservable_type     lot_reservable_type       --Bug#8713821 to check reservable type
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id
         , decode(l_revision_control, 2, NULL, x.revision) revision
         , x.lot_number            lot_number
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
         , x.lpn_id        lpn_id
         , x.transaction_action_id       transaction_action_id
         , x.transfer_subinventory_code  transfer_subinventory_code
         , x.transfer_locator_id         transfer_locator_id
         , x.status_id -- Onhand Material Status Support
        FROM (
       -- reservations
       SELECT
          mr.organization_id       organization_id
        , mr.inventory_item_id     inventory_item_id
        , mr.revision              revision
        , mr.lot_number            lot_number
        , mr.subinventory_code     subinventory_code
        , mr.locator_id            locator_id
        , mr.primary_reservation_quantity
           - Nvl(mr.detailed_quantity,0)    primary_quantity
        , mr.secondary_reservation_quantity
           - Nvl(mr.secondary_detailed_quantity,0)    secondary_quantity
        , 3                        quantity_type
        , to_number(NULL)     cost_group_id
        , lpn_id        lpn_id
        , to_number(NULL)                      transaction_action_id
        , to_char(NULL)                        transfer_subinventory_code
        , to_number(NULL)                      transfer_locator_id
        , to_number(NULL)                      status_id -- Onhand Material Status Support
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity >
       Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
      AND NOT
             ( l_demand_source_type_id = mr.demand_source_type_id
            AND l_demand_source_header_id =  mr.demand_source_header_id
            AND Nvl(l_demand_source_line_id, -9999) =
      Nvl(mr.demand_source_line_id,-9999)
          AND Nvl(l_demand_source_name, '@@@###@@#') =
      Nvl(mr.demand_source_name,'@@@###@@#')
       AND Nvl(l_demand_source_delivery,-9999) =
      Nvl(mr.demand_source_delivery,-9999)
              )
   ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , moq.primary_transaction_quantity
        , moq.secondary_transaction_quantity
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
        , moq.status_id                     -- Onhand Material Status Support
       FROM
          mtl_onhand_quantities_detail       moq
     UNION ALL
       -- pending transactions in mmtt, lot in MMTT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mmtt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.primary_quantity)))
         * round(Abs(mmtt.primary_quantity),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.secondary_transaction_quantity)))
         * round(Abs(mmtt.secondary_transaction_quantity),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
          , inv_material_status_grp.get_default_status(mmtt.organization_id
                                          ,mmtt.inventory_item_id
                                          ,mmtt.subinventory_code
                                          ,mmtt.locator_id
                                          ,mmtt.lot_number -- lot_number
                                          ,NVL(mmtt.allocated_lpn_id,
                                 NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                          ) status_id -- Onhand Material Status Support
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
            mmtt.posting_flag = 'Y'
    AND mmtt.lot_number IS NOT NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
            mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
        )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
    UNION ALL
       --MMTT records, lot in MTLT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mtlt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
      Sign(mmtt.primary_quantity)))
       * round(Abs( mtlt.primary_quantity ),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
      Sign(mmtt.secondary_transaction_quantity)))
       * round(Abs( mtlt.secondary_quantity ),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
          , inv_material_status_grp.get_default_status(mmtt.organization_id
                                          ,mmtt.inventory_item_id
                                          ,mmtt.subinventory_code
                                          ,mmtt.locator_id
                                          ,mtlt.lot_number -- lot_number in MTLT
                                          ,NVL(mmtt.allocated_lpn_id,
                                 NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                          ) status_id -- Onhand Material Status Support
       FROM
           mtl_material_transactions_temp mmtt,
      mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
         AND mmtt.lot_number IS NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
         Nvl(mmtt.transaction_status,0) = 2 AND
        mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
      )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6,24,30)
       UNION ALL
       -- receiving side of transfers, lot in MMTT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mmtt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mmtt.primary_quantity),5)
          , round(Abs( mmtt.secondary_transaction_quantity),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
          , inv_material_status_grp.get_default_status(Decode(mmtt.transaction_action_id
                                               , 3, mmtt.transfer_organization
                                               , mmtt.organization_id)
                                          ,mmtt.inventory_item_id
                                          ,mmtt.transfer_subinventory
                                          ,mmtt.transfer_to_location
                                          ,mmtt.lot_number -- lot_number
                                          ,NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id)
                                          ,mmtt.transaction_action_id
                                          ,inv_material_status_grp.get_default_status(mmtt.organization_id
                                                  ,mmtt.inventory_item_id
                                                  ,mmtt.subinventory_code
                                                  ,mmtt.locator_id
                                                  ,mmtt.lot_number -- lot_number
                                                  ,NVL(mmtt.allocated_lpn_id,
                                        NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                                  )
                                          ) status_id -- Onhand Material Status Support
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NOT NULL
          AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)
        UNION ALL
       -- receiving side of transfers, lot in MTLT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mtlt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
          , round(Abs( mtlt.primary_quantity ),5)
          , round(Abs( mtlt.secondary_quantity ),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
          , inv_material_status_grp.get_default_status(Decode(mmtt.transaction_action_id
                                               , 3, mmtt.transfer_organization
                                               , mmtt.organization_id)
                                          ,mmtt.inventory_item_id
                                          ,mmtt.transfer_subinventory
                                          ,mmtt.transfer_to_location
                                          ,mtlt.lot_number -- lot_number
                                          ,NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id)
                                          ,mmtt.transaction_action_id
                                          ,inv_material_status_grp.get_default_status(mmtt.organization_id
                                                  ,mmtt.inventory_item_id
                                                  ,mmtt.subinventory_code
                                                  ,mmtt.locator_id
                                                  ,mtlt.lot_number -- lot_number
                                                  ,NVL(mmtt.allocated_lpn_id,
                                        NVL(mmtt.content_lpn_id, mmtt.lpn_id))
                                                  )
                                          ) status_id -- Onhand Material Status Support
       FROM
            mtl_material_transactions_temp mmtt,
       mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NULL
          AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
          AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)
      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number,x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id, x.status_id -- Onhand Material Status Support
   ) x
    , mtl_secondary_inventories sub
    , mtl_item_locations loc
    , mtl_lot_numbers lot
    , mtl_parameters mp -- Onhand Material Status Support
    , mtl_material_statuses_b mms -- Onhand Material Status Support
 WHERE
       x.inventory_item_id = lot.inventory_item_id        (+)
   AND x.organization_id = lot.organization_id            (+)
   AND x.lot_number = lot.lot_number                      (+)
   AND x.organization_id = loc.organization_id            (+)
   AND x.locator_id = loc.inventory_location_id           (+)
   AND x.organization_id    = sub.organization_id         (+)
   AND x.subinventory_code = sub.secondary_inventory_name (+)
   AND x.organization_id   = lot.organization_id   (+)
   AND x.inventory_item_id = lot.inventory_item_id (+)
   AND x.lot_number        = lot.lot_number        (+)
   AND x.organization_id    = mp.organization_id   (+) -- Onhand Material Status Support
   AND x.status_id = mms.status_id                 (+) -- Onhand Material Status Support
   AND l_grade_code = lot.grade_code
   AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
   AND
   (
     (mp.default_status_id is null and
       ((l_onhand_source = 1 AND
                 Nvl(sub.inventory_atp_code, 1) = 1
             AND Nvl(loc.inventory_atp_code, 1) = 1
             AND Nvl(lot.inventory_atp_code, 1) = 1
      ) OR
        (l_onhand_source = 2 AND
       Nvl(sub.availability_type, 1) = 1
             AND Nvl(loc.availability_type, 1) = 1
             AND Nvl(lot.availability_type, 1) = 1
   ) OR
   l_onhand_source =3
   OR
   (l_onhand_source = 4 AND
              Nvl(sub.inventory_atp_code, 1) = 1
          AND Nvl(loc.inventory_atp_code, 1) = 1
          AND Nvl(lot.inventory_atp_code, 1) = 1
          AND Nvl(loc.availability_type, 1) = 1
          AND Nvl(lot.availability_type, 1) = 1
          AND Nvl(sub.availability_type, 1) = 1)
      )
     )
     OR -- Onhand Material Status Support
     (
       mp.default_status_id is not null and
           ((l_onhand_source =1 AND
               Nvl(mms.inventory_atp_code, 1) = 1
             )
          OR (l_onhand_source = 2 AND
         Nvl(mms.availability_type, 1) = 1
        )
     OR l_onhand_source =3
          OR (l_onhand_source = 4 AND
         (nvl(mms.inventory_atp_code,1) = 1
         AND nvl(mms.availability_type,1)=1
              )
             )
           )
     )
   )
   ;
     -- invConv changes end : c_lot_grade with MMS about ATP/Nettable...

     CURSOR c_unit IS
     SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
        , NULL           lot_number
        , NULL         lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , NULL                     is_reservable_lot       --Bug#8713821
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id
         , decode(l_revision_control, 2, NULL
      , x.revision)       revision
         , NULL                      lot_number
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
         , x.lpn_id        lpn_id
         , x.transaction_action_id       transaction_action_id
         , x.transfer_subinventory_code  transfer_subinventory_code
         , x.transfer_locator_id         transfer_locator_id
        FROM (
       -- reservations
       SELECT
          mr.organization_id       organization_id
        , mr.inventory_item_id     inventory_item_id
        , mr.revision              revision
        , mr.lot_number            lot_number
        , mr.subinventory_code     subinventory_code
        , mr.locator_id            locator_id
        , mr.primary_reservation_quantity
           - Nvl(mr.detailed_quantity,0)    primary_quantity
        , mr.secondary_reservation_quantity
           - Nvl(mr.secondary_detailed_quantity,0)    secondary_quantity
        , 3                        quantity_type
        , to_number(NULL)     cost_group_id
      , lpn_id       lpn_id
        , to_number(NULL)                      transaction_action_id
        , to_char(NULL)                        transfer_subinventory_code
        , to_number(NULL)                      transfer_locator_id
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity > Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
      AND NOT (l_demand_source_type_id = mr.demand_source_type_id
               AND  l_demand_source_header_id = mr.demand_source_header_id
               AND  Nvl(l_demand_source_line_id, -9999) =
         Nvl(mr.demand_source_line_id,-9999)
               AND  Nvl(l_demand_source_name, '@@@###@@#') =
         Nvl(mr.demand_source_name,'@@@###@@#')
          AND Nvl(l_demand_source_delivery,-9999) =
         Nvl(mr.demand_source_delivery,-9999)
      )
          ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , decode(l_demand_source_line_id,
      NULL, sum(moq.primary_transaction_quantity),
           pjm_ueff_onhand.onhand_quantity(
             l_demand_source_line_id
             ,moq.inventory_item_id
             ,moq.organization_id
             ,moq.revision
             ,moq.subinventory_code
             ,moq.locator_id
             ,moq.lot_number
             ,moq.lpn_id
             ,moq.cost_group_id)
          )
        , decode(l_demand_source_line_id,
      NULL, sum(moq.secondary_transaction_quantity),
           pjm_ueff_onhand.onhand_quantity(
             l_demand_source_line_id
             ,moq.inventory_item_id
             ,moq.organization_id
             ,moq.revision
             ,moq.subinventory_code
             ,moq.locator_id
             ,moq.lot_number
             ,moq.lpn_id
             ,moq.cost_group_id)
          )
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
       FROM
          mtl_onhand_quantities_detail       moq
       GROUP BY moq.organization_id,moq.inventory_item_id,moq.revision,
           moq.subinventory_code,moq.locator_id,moq.lot_number,
           moq.lpn_id,moq.cost_group_id
     UNION ALL
       -- pending transactions in mmtt
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , NULL                 lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
             Sign(mmtt.primary_quantity))) *
           round(Abs(decode(l_demand_source_line_id,
                  NULL, mmtt.primary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.primary_quantity)
                  ),mmtt.primary_quantity
            )
      )),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
             Sign(mmtt.secondary_transaction_quantity))) *
           round(Abs(decode(l_demand_source_line_id,
                  NULL, mmtt.secondary_transaction_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.secondary_transaction_quantity)
                  ),mmtt.secondary_transaction_quantity
            )
      )),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
          , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
         Nvl(mmtt.transaction_status,0) = 2 AND
         mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
        )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6, 24,30)
       UNION ALL
       -- receiving side of transfers
       -- added 5/23/00
       -- if quantity is in an lpn, then it is containerized
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , NULL                         lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
     , round(Abs(decode(l_demand_source_line_id,
            NULL, mmtt.primary_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                   l_demand_source_line_id
               ,mmtt.transaction_temp_id
               ,mmtt.lot_number
                  ,'Y'
               ,mmtt.inventory_item_id
               ,mmtt.organization_id
               ,mmtt.transaction_source_type_id
               ,mmtt.transaction_source_id
               ,mmtt.rcv_transaction_id
                  ,sign(mmtt.primary_quantity)
                     ),mmtt.primary_quantity
            )
      )),5)
     , round(Abs(decode(l_demand_source_line_id,
            NULL, mmtt.secondary_transaction_quantity,
            Nvl(pjm_ueff_onhand.txn_quantity(
                   l_demand_source_line_id
               ,mmtt.transaction_temp_id
               ,mmtt.lot_number
                  ,'Y'
               ,mmtt.inventory_item_id
               ,mmtt.organization_id
               ,mmtt.transaction_source_type_id
               ,mmtt.transaction_source_id
               ,mmtt.rcv_transaction_id
                  ,sign(mmtt.secondary_transaction_quantity)
                     ),mmtt.secondary_transaction_quantity
            )
      )),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
          AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)
      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number, x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id
   ) x
    , mtl_secondary_inventories sub
 WHERE
   x.organization_id    = sub.organization_id          (+)
   AND x.subinventory_code = sub.secondary_inventory_name (+)
   AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
   AND ((l_onhand_source = 1 AND
   Nvl(sub.inventory_atp_code, 1) = 1
        ) OR
        (l_onhand_source = 2 AND
       Nvl(sub.availability_type, 1) = 1
   ) OR
    l_onhand_source =3
   OR
   (l_onhand_source = 4 AND
    Nvl(sub.inventory_atp_code, 1) = 1 AND
     Nvl(sub.availability_type, 1) = 1)
      );

  --Lot Controlled and Unit Effective
  -- invConv change : grade_code filter is in cursor c_lot_unit_grade.
  -- invConv : no change here... see c_lot_unit_grade
  CURSOR c_lot_unit IS
   SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
        , x.lot_number       lot_number
        , lot.expiration_date     lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , lot.reservable_type     lot_reservable_type       --Bug#8713821 to check reservable type
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id
         , decode(l_revision_control, 2, NULL
         , x.revision)       revision
         , x.lot_number             lot_number
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
         , x.lpn_id        lpn_id
         , x.transaction_action_id       transaction_action_id
         , x.transfer_subinventory_code  transfer_subinventory_code
         , x.transfer_locator_id         transfer_locator_id
        FROM (
       -- reservations
       SELECT
          mr.organization_id       organization_id
        , mr.inventory_item_id     inventory_item_id
        , mr.revision              revision
        , mr.lot_number            lot_number
        , mr.subinventory_code     subinventory_code
        , mr.locator_id            locator_id
        , mr.primary_reservation_quantity
           - Nvl(mr.detailed_quantity,0)    primary_quantity
        , mr.secondary_reservation_quantity
           - Nvl(mr.secondary_detailed_quantity,0)    secondary_quantity
        , 3                        quantity_type
        , to_number(NULL)       cost_group_id
        , lpn_id        lpn_id
        , to_number(NULL)                      transaction_action_id
        , to_char(NULL)                        transfer_subinventory_code
        , to_number(NULL)                      transfer_locator_id
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity >
      Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
      AND NOT (l_demand_source_type_id = mr.demand_source_type_id
         AND l_demand_source_header_id = mr.demand_source_header_id
         AND Nvl(l_demand_source_line_id, -9999) =
         Nvl(mr.demand_source_line_id,-9999)
         AND Nvl(l_demand_source_name, '@@@###@@#') =
         Nvl(mr.demand_source_name,'@@@###@@#')
      AND Nvl(l_demand_source_delivery,-9999) =
         Nvl(mr.demand_source_delivery,-9999)
              )
     ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , decode(l_demand_source_line_id,
         NULL, sum(moq.primary_transaction_quantity),
         pjm_ueff_onhand.onhand_quantity(
             l_demand_source_line_id
            ,moq.inventory_item_id
            ,moq.organization_id
            ,moq.revision
            ,moq.subinventory_code
            ,moq.locator_id
            ,moq.lot_number
            ,moq.lpn_id
            ,moq.cost_group_id)
          )
        , decode(l_demand_source_line_id,
         NULL, sum(moq.secondary_transaction_quantity),
         pjm_ueff_onhand.onhand_quantity(
             l_demand_source_line_id
            ,moq.inventory_item_id
            ,moq.organization_id
            ,moq.revision
            ,moq.subinventory_code
            ,moq.locator_id
            ,moq.lot_number
            ,moq.lpn_id
            ,moq.cost_group_id)
          )
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
       FROM
          mtl_onhand_quantities_detail moq
       GROUP BY moq.organization_id,moq.inventory_item_id,moq.revision,
           moq.subinventory_code,moq.locator_id,moq.lot_number,
           moq.lpn_id,moq.cost_group_id
     UNION ALL
       -- pending transactions in mmtt, lot in MMTT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mmtt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.primary_quantity))) *
      round(Abs(decode(l_demand_source_line_id,
         NULL, mmtt.primary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.primary_quantity)
               ),mmtt.primary_quantity
         )
      )),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.secondary_transaction_quantity))) *
      round(Abs(decode(l_demand_source_line_id,
         NULL, mmtt.secondary_transaction_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.secondary_transaction_quantity)
               ),mmtt.secondary_transaction_quantity
         )
      )),5)
   --Bug 4185621
        --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
        , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
        , mmtt.cost_group_id      cost_group_id
   ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
            mmtt.posting_flag = 'Y'
    AND mmtt.lot_number IS NOT NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
         mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
        )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6, 24,30)
    UNION ALL
       --MMTT records, lot in MTLT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mtlt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.primary_quantity))) *
      round(Abs(decode(l_demand_source_line_id,
         NULL, mtlt.primary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mtlt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.primary_quantity)
               ),mtlt.primary_quantity)
      )),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.secondary_transaction_quantity))) *
      round(Abs(decode(l_demand_source_line_id,
         NULL, mtlt.secondary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mtlt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.secondary_transaction_quantity)
               ),mtlt.secondary_quantity)
      )),5)
    --Bug 4185621
         --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
         , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt,
      mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
         AND mmtt.lot_number IS NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
            mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
        )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6, 24,30)
       UNION ALL
       -- receiving side of transfers lot in MMTT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mmtt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
     , round(Abs(decode(l_demand_source_line_id,
         NULL, mmtt.primary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
               ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.primary_quantity)
               ),mmtt.primary_quantity)
         )),5)
     , round(Abs(decode(l_demand_source_line_id,
         NULL, mmtt.secondary_transaction_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
               ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.secondary_transaction_quantity)
               ),mmtt.secondary_transaction_quantity)
         )),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id)  lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.lot_number IS NOT NULL
         AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
         AND mmtt.transaction_action_id IN (2,28,3)
        UNION ALL
        -- receiving side of transfers  lot in MTLT
        -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mtlt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
     , round(Abs(decode(l_demand_source_line_id,
         NULL, mtlt.primary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mtlt.lot_number
               ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.primary_quantity)
               ),mtlt.primary_quantity)
      )),5)
     , round(Abs(decode(l_demand_source_line_id,
         NULL, mtlt.secondary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mtlt.lot_number
               ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.secondary_transaction_quantity)
               ),mtlt.secondary_quantity)
      )),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
      ,mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NULL
          AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
          AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)
      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number,x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id
   ) x
    , mtl_secondary_inventories sub
    , mtl_lot_numbers lot
 WHERE
   x.organization_id    = sub.organization_id          (+)
   AND x.subinventory_code = sub.secondary_inventory_name (+)
   AND x.organization_id   = lot.organization_id   (+)
   AND x.inventory_item_id = lot.inventory_item_id (+)
   AND x.lot_number        = lot.lot_number        (+)
   AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
   AND ((l_onhand_source = 1 AND
      Nvl(sub.inventory_atp_code, 1) = 1
    ) OR
        (l_onhand_source = 2 AND
       Nvl(sub.availability_type, 1) = 1
    ) OR
    l_onhand_source =3
      OR
    (l_onhand_source = 4 AND
      Nvl(sub.inventory_atp_code, 1) = 1 AND
                Nvl(sub.availability_type, 1) = 1
    )
      )
   ;

  -- invConv change : grade_code filter is in here
  CURSOR c_lot_unit_grade IS
   SELECT
          x.organization_id       organization_id
        , x.inventory_item_id     inventory_item_id
        , x.revision              revision
        , x.lot_number       lot_number
        , lot.expiration_date     lot_expiration_date
        , x.subinventory_code     subinventory_code
        , sub.reservable_type     reservable_type
        , x.locator_id            locator_id
        , x.primary_quantity      primary_quantity
        , x.secondary_quantity    secondary_quantity
        , x.quantity_type         quantity_type
        , x.cost_group_id         cost_group_id
        , x.lpn_id        lpn_id
        , x.transaction_action_id       transaction_action_id
        , x.transfer_subinventory_code  transfer_subinventory_code
        , x.transfer_locator_id         transfer_locator_id
        , lot.reservable_type     lot_reservable_type       --Bug#8713821 to check reservable type
     FROM (
       SELECT
           x.organization_id       organization_id
         , x.inventory_item_id     inventory_item_id
         , decode(l_revision_control, 2, NULL
         , x.revision)       revision
         , x.lot_number             lot_number
         , x.subinventory_code     subinventory_code
         , x.locator_id            locator_id
         , SUM(x.primary_quantity) primary_quantity
         , SUM(x.secondary_quantity) secondary_quantity
         , x.quantity_type         quantity_type
         , x.cost_group_id         cost_group_id
         , x.lpn_id        lpn_id
         , x.transaction_action_id       transaction_action_id
         , x.transfer_subinventory_code  transfer_subinventory_code
         , x.transfer_locator_id         transfer_locator_id
        FROM (
       -- reservations
       SELECT
          mr.organization_id       organization_id
        , mr.inventory_item_id     inventory_item_id
        , mr.revision              revision
        , mr.lot_number            lot_number
        , mr.subinventory_code     subinventory_code
        , mr.locator_id            locator_id
        , mr.primary_reservation_quantity
           - Nvl(mr.detailed_quantity,0)    primary_quantity
        , mr.secondary_reservation_quantity
           - Nvl(mr.secondary_detailed_quantity,0)    secondary_quantity
        , 3                        quantity_type
        , to_number(NULL)       cost_group_id
        , lpn_id        lpn_id
        , to_number(NULL)                      transaction_action_id
        , to_char(NULL)                        transfer_subinventory_code
        , to_number(NULL)                      transfer_locator_id
     FROM mtl_reservations mr
     WHERE
          Nvl(mr.supply_source_type_id, 13) = 13
      AND mr.primary_reservation_quantity >
      Nvl(mr.detailed_quantity,0)
      AND ((l_no_lpn_reservations <>1)
           OR (l_no_lpn_reservations = 1 AND mr.lpn_id IS NULL))
      AND (l_tree_mode <> 3 OR
          (l_tree_mode = 3
      AND NOT (l_demand_source_type_id = mr.demand_source_type_id
         AND l_demand_source_header_id = mr.demand_source_header_id
         AND Nvl(l_demand_source_line_id, -9999) =
         Nvl(mr.demand_source_line_id,-9999)
         AND Nvl(l_demand_source_name, '@@@###@@#') =
         Nvl(mr.demand_source_name,'@@@###@@#')
      AND Nvl(l_demand_source_delivery,-9999) =
         Nvl(mr.demand_source_delivery,-9999)
              )
     ))
     UNION ALL
       -- onhand quantities
       SELECT
          moq.organization_id               organization_id
        , moq.inventory_item_id             inventory_item_id
        , moq.revision                      revision
        , moq.lot_number                    lot_number
        , moq.subinventory_code             subinventory_code
        , moq.locator_id                    locator_id
        , decode(l_demand_source_line_id,
         NULL, sum(moq.primary_transaction_quantity),
         pjm_ueff_onhand.onhand_quantity(
             l_demand_source_line_id
            ,moq.inventory_item_id
            ,moq.organization_id
            ,moq.revision
            ,moq.subinventory_code
            ,moq.locator_id
            ,moq.lot_number
            ,moq.lpn_id
            ,moq.cost_group_id)
          )
        , decode(l_demand_source_line_id,
         NULL, sum(moq.secondary_transaction_quantity),
         pjm_ueff_onhand.onhand_quantity(
             l_demand_source_line_id
            ,moq.inventory_item_id
            ,moq.organization_id
            ,moq.revision
            ,moq.subinventory_code
            ,moq.locator_id
            ,moq.lot_number
            ,moq.lpn_id
            ,moq.cost_group_id)
          )
        , 1                                 quantity_type
        , moq.cost_group_id                 cost_group_id
        , moq.lpn_id                        lpn_id
        , to_number(NULL)                   transaction_action_id
        , to_char(NULL)                     transfer_subinventory_code
        , to_number(NULL)                   transfer_locator_id
       FROM
          mtl_onhand_quantities_detail moq
       GROUP BY moq.organization_id,moq.inventory_item_id,moq.revision,
           moq.subinventory_code,moq.locator_id,moq.lot_number,
           moq.lpn_id,moq.cost_group_id
     UNION ALL
       -- pending transactions in mmtt, lot in MMTT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mmtt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.primary_quantity))) *
      round(Abs(decode(l_demand_source_line_id,
         NULL, mmtt.primary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.primary_quantity)
               ),mmtt.primary_quantity
         )
      )),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.secondary_transaction_quantity))) *
      round(Abs(decode(l_demand_source_line_id,
         NULL, mmtt.secondary_transaction_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.secondary_transaction_quantity)
               ),mmtt.secondary_transaction_quantity
         )
      )),5)
   --Bug 4185621
        --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
        , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
        , mmtt.cost_group_id      cost_group_id
   ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
            mmtt.posting_flag = 'Y'
    AND mmtt.lot_number IS NOT NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
         mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
        )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6, 24,30)
    UNION ALL
       --MMTT records, lot in MTLT
       SELECT
            mmtt.organization_id    organization_id
          , mmtt.inventory_item_id  inventory_item_id
          , mmtt.revision           revision
          , mtlt.lot_number         lot_number
          , mmtt.subinventory_code  subinventory_code
          , mmtt.locator_id         locator_id
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.primary_quantity))) *
      round(Abs(decode(l_demand_source_line_id,
         NULL, mtlt.primary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mtlt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.primary_quantity)
               ),mtlt.primary_quantity)
      )),5)
     --Bug 4185621
          --, Decode(mmtt.transaction_status, 2, 1,
          , Decode(Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,-1,2), mmtt.transaction_status), 2, 1,
      Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
         Sign(mmtt.secondary_transaction_quantity))) *
      round(Abs(decode(l_demand_source_line_id,
         NULL, mtlt.secondary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mtlt.lot_number
                  ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.secondary_transaction_quantity)
               ),mtlt.secondary_quantity)
      )),5)
    --Bug 4185621
         --, Decode(mmtt.transaction_status, 2, 5, 1) quantity_type
         , Decode(mmtt.transaction_status, 2, decode(nvl(mmtt.wms_task_status,-1),4,1,5), 1)  quantity_type
          , mmtt.cost_group_id       cost_group_id
     ,NVL(mmtt.allocated_lpn_id,
      NVL(mmtt.content_lpn_id, mmtt.lpn_id)) lpn_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transaction_action_id, to_number(NULL)) transaction_action_id
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_subinventory, to_char(NULL)) transfer_subinventory_code
          , Decode(mmtt.transaction_status, 2 , mmtt.transfer_to_location, to_number(NULL))  transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt,
      mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
         AND mmtt.lot_number IS NULL
    AND mmtt.subinventory_code IS NOT NULL
    AND (Nvl(mmtt.transaction_status,0) <> 2 OR
            Nvl(mmtt.transaction_status,0) = 2 AND
            mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
        )
      -- dont look at scrap and costing txns
      -- Bug 3396558 fix. Ignore ownership xfr,planning xfr transactions
         AND mmtt.transaction_action_id NOT IN (5,6, 24,30)
       UNION ALL
       -- receiving side of transfers lot in MMTT
       -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mmtt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
     , round(Abs(decode(l_demand_source_line_id,
         NULL, mmtt.primary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
               ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.primary_quantity)
               ),mmtt.primary_quantity)
         )),5)
     , round(Abs(decode(l_demand_source_line_id,
         NULL, mmtt.secondary_transaction_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mmtt.lot_number
               ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.secondary_transaction_quantity)
               ),mmtt.secondary_transaction_quantity)
         )),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id)  lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
       WHERE
             mmtt.posting_flag = 'Y'
         AND mmtt.lot_number IS NOT NULL
         AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
         AND mmtt.transaction_action_id IN (2,28,3)
       UNION ALL
   -- receiving side of transfers  lot in MTLT
   -- Bug 7658493, If wms task is in loaded status, consider allocation like pending transaction.
       SELECT
            Decode(mmtt.transaction_action_id
               , 3, mmtt.transfer_organization
               , mmtt.organization_id)   organization_id
          , mmtt.inventory_item_id       inventory_item_id
          , mmtt.revision                revision
          , mtlt.lot_number              lot_number
          , mmtt.transfer_subinventory   subinventory_code
          , mmtt.transfer_to_location    locator_id
     , round(Abs(decode(l_demand_source_line_id,
         NULL, mtlt.primary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mtlt.lot_number
               ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.primary_quantity)
               ),mtlt.primary_quantity)
      )),5)
     , round(Abs(decode(l_demand_source_line_id,
         NULL, mtlt.secondary_quantity,
         Nvl(pjm_ueff_onhand.txn_quantity(
                l_demand_source_line_id
            ,mmtt.transaction_temp_id
            ,mtlt.lot_number
               ,'Y'
            ,mmtt.inventory_item_id
            ,mmtt.organization_id
            ,mmtt.transaction_source_type_id
            ,mmtt.transaction_source_id
            ,mmtt.rcv_transaction_id
               ,sign(mmtt.secondary_transaction_quantity)
               ),mtlt.secondary_quantity)
      )),5)
          , 1                            quantity_type
          , mmtt.transfer_cost_group_id  cost_group_id
          , NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) lpn_id
          , to_number(NULL)                      transaction_action_id
          , to_char(NULL)                        transfer_subinventory_code
          , to_number(NULL)                      transfer_locator_id
       FROM
            mtl_material_transactions_temp mmtt
           ,mtl_transaction_lots_temp mtlt
       WHERE
             mmtt.posting_flag = 'Y'
          AND mmtt.lot_number IS NULL
          AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
          AND Decode( Nvl(mmtt.transaction_status,0),
                       2, decode(nvl(mmtt.wms_task_status,-1), 4, 1, 2),
                       1 ) <> 2
          AND mmtt.transaction_action_id IN (2,28,3)
      ) x
      WHERE x.organization_id    = l_organization_id
        AND x.inventory_item_id  = l_inventory_item_id
      GROUP BY
           x.organization_id, x.inventory_item_id, x.revision
          , x.lot_number,x.subinventory_code, x.locator_id
          , x.quantity_type, x.cost_group_id, x.lpn_id
          , x.transaction_action_id, x.transfer_subinventory_code
          , x.transfer_locator_id
   ) x
    , mtl_secondary_inventories sub
    , mtl_lot_numbers lot
 WHERE
   x.organization_id    = sub.organization_id          (+)
   AND x.subinventory_code = sub.secondary_inventory_name (+)
   AND x.organization_id   = lot.organization_id   (+)
   AND x.inventory_item_id = lot.inventory_item_id (+)
   AND x.lot_number        = lot.lot_number        (+)
   AND l_grade_code = lot.grade_code
   AND (l_asset_subs_only = 2 OR
         NVL(sub.asset_inventory,1) = 1)
   AND ((l_onhand_source = 1 AND
      Nvl(sub.inventory_atp_code, 1) = 1
    ) OR
        (l_onhand_source = 2 AND
       Nvl(sub.availability_type, 1) = 1
    ) OR
    l_onhand_source =3
      OR
    (l_onhand_source = 4 AND
      Nvl(sub.inventory_atp_code, 1) = 1 AND
                Nvl(sub.availability_type, 1) = 1
    )
      )
   ;

BEGIN
   IF g_debug = 1 THEN
      print_debug('  ' || l_api_name || ' Entered',9);
   END IF;

   -- invConv change (for display)
   print_debug('odab entering build_tree grade_code='||g_rootinfos(p_tree_id).grade_code);
   if (g_is_lot_control = TRUE)
   then
              print_debug('In build_tree.   g_is_lot_control=TRUE');
   else
              print_debug('In build_tree.   g_is_lot_control=FALSE');
   end if;

   zero_tree_node(l_return_status, g_rootinfos(p_tree_id).item_node_index);
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   --bug 2668448
   --quantity tree returned wrong values if the tree is rebuilt
   --but the information stored in g_rsv_info is not deleted.
   --This resulted in the tree displaying too little quantity being available.
   IF g_rsv_tree_id <> 0 AND
      g_demand_info.exists(g_rsv_tree_id) THEN

      If g_demand_info(g_rsv_tree_id).root_id = p_tree_id Then
         g_rsv_tree_id := 0;
         g_rsv_counter := 0;
         g_rsv_info.DELETE;
      End If;
   END IF;


   l_organization_id          := g_rootinfos(p_tree_id).organization_id;
   l_inventory_item_id        := g_rootinfos(p_tree_id).inventory_item_id;
   l_demand_source_type_id    := g_rootinfos(p_tree_id).demand_source_type_id;
   l_demand_source_header_id  := g_rootinfos(p_tree_id).demand_source_header_id;
   l_demand_source_line_id    := g_rootinfos(p_tree_id).demand_source_line_id;
   l_demand_source_name       := g_rootinfos(p_tree_id).demand_source_name;
   l_demand_source_delivery   := g_rootinfos(p_tree_id).demand_source_delivery;
   l_tree_mode                := g_rootinfos(p_tree_id).tree_mode;
   l_lot_expiration_date      := g_rootinfos(p_tree_id).lot_expiration_date;
   l_onhand_source            := g_rootinfos(p_tree_id).onhand_source;
   l_grade_code               := g_rootinfos(p_tree_id).grade_code;

   IF g_rootinfos(p_tree_id).is_revision_control THEN
      l_revision_control := 1;
   ELSE
      l_revision_control := 2;
   END IF;
   IF g_rootinfos(p_tree_id).asset_sub_only THEN
      l_asset_subs_only := 1;
   ELSE
      l_asset_subs_only := 2;
   END IF;
   IF l_tree_mode = g_no_lpn_rsvs_mode THEN
      l_no_lpn_reservations := 1;
   ELSE
      l_no_lpn_reservations := 2;
   END IF;

   print_debug('build_tree: l_revision_control='||l_revision_control);
   print_debug('build_tree: l_asset_subs_only='||l_asset_subs_only);
   print_debug('build_tree: l_no_lpn_reservations='||l_no_lpn_reservations);
   print_debug('build_tree: l_onhand_source='||l_onhand_source);
   print_debug('build_tree: l_grade_code='||l_grade_code);
   print_debug('build_tree: l_lot_expiration_date='||l_lot_expiration_date);

   -- invConv changes begin : Material Status CTL = need to build the QT with lotCTL
   --     Even in the Header Misc UI, BUT the tree is created as prior Convergence :
   --     without lot_number (but using the c_lot% cursors)
   -- IF g_rootinfos(p_tree_id).is_lot_control THEN
   IF g_is_lot_control OR g_rootinfos(p_tree_id).is_lot_control
   THEN

      l_lot_expiration_control := 1;
      IF g_rootinfos(p_tree_id).unit_effective = 1 THEN
         --item is lot controlled and unit effective
         IF l_grade_code IS NULL
         THEN
            print_debug('build_tree: open c_lot_unit');
            OPEN c_lot_unit;
            FETCH c_lot_unit BULK COLLECT INTO
                   v_organization_id
                  ,v_inventory_item_id
                  ,v_revision
                  ,v_lot_number
                  ,v_lot_expiration_date
                  ,v_subinventory_code
                  ,v_reservable_type
                  ,v_locator_id
                  ,v_primary_quantity
                  ,v_secondary_quantity
                  ,v_quantity_type
                  ,v_cost_group_id
                  ,v_lpn_id
                  ,v_transaction_action_id
                  ,v_transfer_subinventory_code
                  ,v_transfer_locator_id
                  ,v_is_reservable_lot    --Bug#8713821
            ;
            CLOSE c_lot_unit;
            -- invConv changes begin : adding grade where clause in a separate cursor
         ELSE
            print_debug('build_tree: open c_lot_unit_grade');
            OPEN c_lot_unit_grade;
            FETCH c_lot_unit_grade BULK COLLECT INTO
                    v_organization_id
                   ,v_inventory_item_id
                   ,v_revision
                   ,v_lot_number
                   ,v_lot_expiration_date
                   ,v_subinventory_code
                   ,v_reservable_type
                   ,v_locator_id
                   ,v_primary_quantity
                   ,v_secondary_quantity
                   ,v_quantity_type
                   ,v_cost_group_id
                   ,v_lpn_id
                   ,v_transaction_action_id
                   ,v_transfer_subinventory_code
                   ,v_transfer_locator_id
                   ,v_is_reservable_lot    --Bug#8713821
               ;
            CLOSE c_lot_unit_grade;
         END IF;

      ELSE
         --item is lot controlled
         IF l_grade_code IS NULL
         THEN
            IF (g_is_lot_control = FALSE)
            THEN
               print_debug('build_tree: open c_lot');
               OPEN c_lot;
               FETCH c_lot BULK COLLECT INTO
                      v_organization_id
                     ,v_inventory_item_id
                     ,v_revision
                     ,v_lot_number
                     ,v_lot_expiration_date
                     ,v_subinventory_code
                     ,v_reservable_type
                     ,v_locator_id
                     ,v_primary_quantity
                     ,v_secondary_quantity
                     ,v_quantity_type
                     ,v_cost_group_id
                     ,v_lpn_id
                     ,v_transaction_action_id
                     ,v_transfer_subinventory_code
                     ,v_transfer_locator_id
                     ,v_is_reservable_lot    --Bug#8713821
               ;
               CLOSE c_lot;
            ELSE
               print_debug('build_tree: open c_lot_MMS');
               OPEN c_lot_MMS;
               FETCH c_lot_MMS BULK COLLECT INTO
                      v_organization_id
                     ,v_inventory_item_id
                     ,v_revision
                     ,v_lot_number
                     ,v_lot_expiration_date
                     ,v_subinventory_code
                     ,v_reservable_type
                     ,v_locator_id
                     ,v_primary_quantity
                     ,v_secondary_quantity
                     ,v_quantity_type
                     ,v_cost_group_id
                     ,v_lpn_id
                     ,v_transaction_action_id
                     ,v_transfer_subinventory_code
                     ,v_transfer_locator_id
                     ,v_status_id            -- Onhand Material Status Support
                     ,v_is_reservable_lot    --Bug#8713821
               ;
               CLOSE c_lot_MMS;
            END IF;     -- (g_is_lot_control = FALSE)
            -- invConv changes begin : adding grade where clause in a separate cursor
         ELSE
            IF (g_is_lot_control = FALSE)
            THEN
               print_debug('build_tree: open c_lot_grade');
               OPEN c_lot_grade;
               FETCH c_lot_grade BULK COLLECT INTO
                      v_organization_id
                     ,v_inventory_item_id
                     ,v_revision
                     ,v_lot_number
                     ,v_lot_expiration_date
                     ,v_subinventory_code
                     ,v_reservable_type
                     ,v_locator_id
                     ,v_primary_quantity
                     ,v_secondary_quantity
                     ,v_quantity_type
                     ,v_cost_group_id
                     ,v_lpn_id
                     ,v_transaction_action_id
                     ,v_transfer_subinventory_code
                     ,v_transfer_locator_id
                     ,v_is_reservable_lot    --Bug#8713821
               ;
               CLOSE c_lot_grade;
            ELSE
               print_debug('build_tree: open c_lot_grade_MMS');
               OPEN c_lot_grade_MMS;
               FETCH c_lot_grade_MMS BULK COLLECT INTO
                      v_organization_id
                     ,v_inventory_item_id
                     ,v_revision
                     ,v_lot_number
                     ,v_lot_expiration_date
                     ,v_subinventory_code
                     ,v_reservable_type
                     ,v_locator_id
                     ,v_primary_quantity
                     ,v_secondary_quantity
                     ,v_quantity_type
                     ,v_cost_group_id
                     ,v_lpn_id
                     ,v_transaction_action_id
                     ,v_transfer_subinventory_code
                     ,v_transfer_locator_id
                     ,v_status_id            -- Onhand Material Status Support
                     ,v_is_reservable_lot    --Bug#8713821
               ;
               CLOSE c_lot_grade_MMS;
            END IF;    -- (g_is_lot_control = FALSE)
         END IF;  -- l_grade_code

      END IF;
   ELSE
   --Bug7628989
        SELECT lot_control_code
        INTO   lot_control_code
        FROM   mtl_system_items_b
        WHERE inventory_item_id = l_inventory_item_id
        AND   organization_id = l_organization_id;

        IF lot_control_code = 2 THEN
           l_lot_expiration_control := 1;
        ELSE
          l_lot_expiration_control := 2;
          END IF;

      IF g_rootinfos(p_tree_id).unit_effective = 1 THEN
         IF l_lot_expiration_control = 1 THEN
         print_debug('build_tree: open c_unit_no_lot');
         --item is unit effective
         OPEN c_unit_no_lot;
         FETCH c_unit_no_lot BULK COLLECT INTO
                   v_organization_id
                  ,v_inventory_item_id
                  ,v_revision
                  ,v_lot_number
                  ,v_lot_expiration_date
                  ,v_subinventory_code
                  ,v_reservable_type
                  ,v_locator_id
                  ,v_primary_quantity
                  ,v_secondary_quantity
                  ,v_quantity_type
                  ,v_cost_group_id
                  ,v_lpn_id
                  ,v_transaction_action_id
                  ,v_transfer_subinventory_code
                  ,v_transfer_locator_id
                  , v_is_reservable_lot    --Bug#8713821
         ;
         CLOSE c_unit_no_lot;
         ELSE
                   --item is unit effective
                   OPEN c_unit;
                   FETCH c_unit BULK COLLECT INTO
             v_organization_id
            ,v_inventory_item_id
            ,v_revision
            ,v_lot_number
            ,v_lot_expiration_date
            ,v_subinventory_code
            ,v_reservable_type
            ,v_locator_id
            ,v_primary_quantity
            ,v_secondary_quantity
            ,v_quantity_type
            ,v_cost_group_id
            ,v_lpn_id
            ,v_transaction_action_id
            ,v_transfer_subinventory_code
            ,v_transfer_locator_id
            ,v_is_reservable_lot    --Bug#8713821
                ;
                   CLOSE c_unit;
         END IF;
      ELSE
         IF l_lot_expiration_control = 1 THEN
             OPEN c_no_lot;
             print_debug('  Opening Cursor c_no_lot');
             FETCH c_no_lot BULK COLLECT INTO
                v_organization_id
               ,v_inventory_item_id
               ,v_revision
               ,v_lot_number
               ,v_lot_expiration_date
               ,v_subinventory_code
               ,v_reservable_type
               ,v_locator_id
               ,v_primary_quantity
               ,v_secondary_quantity
               ,v_quantity_type
               ,v_cost_group_id
               ,v_lpn_id
               ,v_transaction_action_id
               ,v_transfer_subinventory_code
               ,v_transfer_locator_id
               ,v_is_reservable_lot    --Bug#8713821
              ;
             CLOSE c_no_lot;
         ELSE
         IF (g_is_lot_control = FALSE)
           THEN
              IF (inv_quantity_tree_pvt.g_is_mat_status_used = 2) /* Bug 7158174 */
              THEN
                 print_debug('build_tree: open c_plain');
                 --item is not lot controlled or unit effective
                 OPEN c_plain;
                 FETCH c_plain BULK COLLECT INTO
                   v_organization_id
                  ,v_inventory_item_id
                  ,v_revision
                  ,v_lot_number
                  ,v_lot_expiration_date
                  ,v_subinventory_code
                  ,v_reservable_type
                  ,v_locator_id
                  ,v_primary_quantity
                  ,v_secondary_quantity
                  ,v_quantity_type
                  ,v_cost_group_id
                  ,v_lpn_id
                  ,v_transaction_action_id
                  ,v_transfer_subinventory_code
                  ,v_transfer_locator_id
                  ,v_is_reservable_lot    --Bug#8713821
                  ;
                  CLOSE c_plain;
             ELSE
                  print_debug('build_tree: open c_plain_MMS');
            --item is not lot controlled or unit effective
            OPEN c_plain_MMS;
            FETCH c_plain_MMS BULK COLLECT INTO
                   v_organization_id
                  ,v_inventory_item_id
                  ,v_revision
                  ,v_lot_number
                  ,v_lot_expiration_date
                  ,v_subinventory_code
                  ,v_reservable_type
                  ,v_locator_id
                  ,v_primary_quantity
                  ,v_secondary_quantity
                  ,v_quantity_type
                  ,v_cost_group_id
                  ,v_lpn_id
                  ,v_transaction_action_id
                  ,v_transfer_subinventory_code
                  ,v_transfer_locator_id
                  ,v_status_id            -- Onhand Material Status Support
                  ,v_is_reservable_lot    --Bug#8713821
            ;
            CLOSE c_plain_MMS;
            END IF;
         END IF;    -- (g_is_lot_control = FALSE)
      END IF;
   END IF;
END IF;
   print_debug('build_tree: l_lot_expiration_control='||l_lot_expiration_control);

   --WHILE (l_index < l_tot_num_rows) LOOP
   l_index := v_organization_id.FIRST;
   LOOP
      print_debug('build_tree: loop index='||l_index||'.');
      EXIT WHEN l_index IS NULL;
      IF (l_tree_mode = g_loose_only_mode
          AND v_quantity_type(l_index) = g_qr_same_demand) THEN
         -- the record should not be used to build the tree
         -- as it is a reservation for the same demand
         NULL;
         print_debug('... QT not build because mode=looose_only and qty_type=qr_same_demand...');
      ELSE
         IF v_reservable_type(l_index) IS NOT NULL THEN
            IF v_reservable_type(l_index) = 1 THEN
               l_is_reservable_sub := TRUE;
             ELSIF v_reservable_type(l_index) = 2 THEN
               l_is_reservable_sub := FALSE;
             ELSE
               l_is_reservable_sub := NULL;
            END IF;
         ELSE
            l_is_reservable_sub := NULL;
         END IF;

         --bug 9380420, now we need not call check_is_reservable from here, as logic is shifted to new_tree_node.
         --             It will get called from add_quantities -> find_tree_node -> find_child_node.
         /*
         print_debug('org='||l_organization_id||', item='||l_inventory_item_id||', sub='||v_subinventory_code(l_index)||', loc='||v_locator_id(l_index)||', lot='||substr(v_lot_number(l_index), 1, 10)||', priqty='||v_primary_quantity(l_index));
         check_is_reservable
              ( x_return_status     => l_return_status
              , p_inventory_item_id => l_inventory_item_id
              , p_organization_id   => l_organization_id
              , p_subinventory_code => v_subinventory_code(l_index)
              , p_locator_id        => v_locator_id(l_index)
              , p_lot_number        => v_lot_number(l_index)
              , p_root_id           => p_tree_id
              , x_is_reservable     => l_is_reservable_sub
              , p_lpn_id            => v_lpn_id(l_index)); -- Onhand Material Status Support

         if l_is_reservable_sub then
             print_debug('after check_is_reservable, rsv=TRUE');
         else
             print_debug('after check_is_reservable, rsv=FALSE');
         end if;
         */

         -- invConv changes begin : Only with mat_stat CTL, Create the tree with lotCTL FALSE :
         if g_is_lot_control AND g_rootinfos(p_tree_id).is_lot_control = FALSE
         then
            print_debug(' Calling add_quantities  for summary node ...');
            --bug 9380420, passing NULL instead of l_is_reservable_sub to p_is_reservable_sub.
            add_quantities
              (
                 x_return_status     => l_return_status
               , p_tree_id           => p_tree_id
               , p_revision          => v_revision(l_index)
               , p_lot_number        => NULL
               , p_subinventory_code => v_subinventory_code(l_index)
               , p_is_reservable_sub => NULL
               , p_locator_id        => v_locator_id(l_index)
               , p_primary_quantity  => v_primary_quantity(l_index)
               , p_secondary_quantity=> v_secondary_quantity(l_index)
               , p_quantity_type     => v_quantity_type (l_index)
               , p_set_check_mark    => FALSE
               , p_cost_group_id     => v_cost_group_id(l_index)
               , p_lpn_id         => v_lpn_id(l_index)
               --Bug 4294336
               , p_transaction_action_id => v_transaction_action_id(l_index)
               , p_transfer_subinventory_code => v_transfer_subinventory_code(l_index)
               , p_transfer_locator_id   =>   v_transfer_locator_id(l_index)
               , p_expiration_date   => v_lot_expiration_date(l_index) -- Bug 7628989
               , p_is_reservable_lot   => v_is_reservable_lot(l_index) --Bug#8713821
                 );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            End IF ;

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            End IF;
         ELSE
            print_debug(' Calling add_quantities for qty1='||v_primary_quantity(l_index)||', qty2='||v_secondary_quantity(l_index)||'...');
            --bug 9380420, passing NULL instead of l_is_reservable_sub to p_is_reservable_sub.
            add_quantities
              (
                 x_return_status     => l_return_status
               , p_tree_id           => p_tree_id
               , p_revision          => v_revision(l_index)
               , p_lot_number        => v_lot_number(l_index)
               , p_subinventory_code => v_subinventory_code(l_index)
               , p_is_reservable_sub => NULL
               , p_locator_id        => v_locator_id(l_index)
               , p_primary_quantity  => v_primary_quantity(l_index)
               , p_secondary_quantity=> v_secondary_quantity(l_index)
               , p_quantity_type     => v_quantity_type (l_index)
               , p_set_check_mark    => FALSE
               , p_cost_group_id     => v_cost_group_id(l_index)
               , p_lpn_id            => v_lpn_id(l_index)
               --Bug 4294336
               , p_transaction_action_id => v_transaction_action_id(l_index)
               , p_transfer_subinventory_code => v_transfer_subinventory_code(l_index)
               , p_transfer_locator_id   =>   v_transfer_locator_id(l_index)
               , p_expiration_date   => v_lot_expiration_date(l_index) -- Bug 7628989
               , p_is_reservable_lot   => v_is_reservable_lot(l_index) --Bug#8713821
                 );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            End IF ;

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            End IF;
            -- invConv changes begin : Closing test on g_is_lot_ctl
         END IF;
      END IF;

      EXIT WHEN l_index = v_organization_id.LAST;
      l_index := v_organization_id.NEXT(l_index);
   END LOOP;

   print_debug('... end of build_tree loop...');

   -- close cursor
   --dbms_sql.CLOSE_cursor(l_cursor);
   g_rootinfos(p_tree_id).need_refresh := FALSE;
   x_return_status := l_return_status;

   IF g_debug = 1 THEN
      print_debug('  '||l_api_name || ' Exited with status = '||l_return_status,9);
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        print_debug('build_tree: exc_err='||sqlerrm,9);
        x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
        print_debug('build_tree: unexp_err='||sqlerrm,9);
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

    WHEN OTHERS THEN
        print_debug('build_tree: others='||sqlerrm,9);
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'Build_Tree'
              );
        END IF;

END build_tree;

-- Function
--   check_node_violation
-- Description
--   return false if there is violation, true otherwise
FUNCTION check_node_violation
  (  x_return_status      OUT NOCOPY VARCHAR2
   , p_node_index         IN  INTEGER
   , p_tree_mode          IN  INTEGER
   , p_negative_allowed   IN  BOOLEAN
   , p_item_node_index    IN  INTEGER
   ) RETURN BOOLEAN
  IS
   l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_child_index          INTEGER;
   l_no_violation         BOOLEAN;
   l_node_index           INTEGER;
BEGIN
   print_debug('Entering check_node_violation...');

   -- check this node
   print_debug('mode='||p_tree_mode||', att='||g_nodes(p_node_index).att||', qr='||g_nodes(p_item_node_index).qr||' AND atr='||g_nodes(p_item_node_index).atr);
   print_debug('Secondaries: satt='||g_nodes(p_node_index).satt||', sqr='||g_nodes(p_item_node_index).sqr||' AND satr='||g_nodes(p_item_node_index).satr);
   IF p_tree_mode IN (g_transaction_mode, g_loose_only_mode)
     AND g_nodes(p_node_index).check_mark
     AND g_nodes(p_node_index).att < 0
     AND (p_negative_allowed = FALSE
     OR (g_nodes(p_item_node_index).qr > 0 AND g_nodes(p_item_node_index).atr < 0 )) THEN
      --OR g_nodes(p_item_node_index).atr < 0 ) THEN
      --Bug 3383756 fix, redoing bug 3078863 fix made in 115.121, but
      --missing in this version
      print_debug('... return=FALSE, with status='||l_return_status||' ... because :');
      print_debug('mode='||p_tree_mode||', check_mark=TRUE, att='||g_nodes(p_node_index).att||', (negative_allowed=FALSE OR {qr='||g_nodes(p_item_node_index).qr||' >0 AND atr='||g_nodes(p_item_node_index).atr||' <0}');
      RETURN FALSE;
   END IF;

   IF p_tree_mode = g_reservation_mode
     AND g_nodes(p_node_index).check_mark
     AND g_nodes(p_node_index).atr < 0 THEN
      print_debug('... return=FALSE, with status='||l_return_status||' ... because :');
      print_debug('mode='||p_tree_mode||', check_mark=TRUE, atr='||g_nodes(p_node_index).atr||' <0.');
      RETURN FALSE;
   END IF;

   -- check child nodes
   l_child_index := g_nodes(p_node_index).first_child_index;
   l_no_violation := TRUE;
   WHILE (l_child_index <> 0) LOOP
      l_no_violation := check_node_violation(
           x_return_status    => l_return_status
         , p_node_index       => l_child_index
         , p_tree_mode        => p_tree_mode
         , p_negative_allowed => p_negative_allowed
         , p_item_node_index  => p_item_node_index
         );

      IF l_no_violation = FALSE THEN
         print_debug('... exiting the loop with return=FALSE');
         EXIT;
      END IF;

      l_child_index := g_nodes(l_child_index).next_sibling_index;
   END LOOP;

   x_return_status := l_return_status;

   IF l_no_violation
   THEN
      print_debug('Normal end of check_node_violation. status='||l_return_status||', no_violation=TRUE');
   ELSE
      print_debug('Normal end of check_node_violation. status='||l_return_status||', no_violation=FALSE');
   END IF;
   RETURN l_no_violation;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Check_Node_Violation'
              );
      END IF;
      RETURN FALSE;

END check_node_violation;

--add_demand_qty
-- When in transaction_mode, this procedure will fix
-- the quantity tree to reflect the correct available quantities.
-- To do this, it queries the mtl_reservations table to find
-- reservations which correspond to the demand info.  For each
-- reservation, it calls add_quantities to subtract those reservations
-- from the quantity tree (since that quantity should be available
-- for this transaction).  We call add_quantities with a negative
-- quantity so that QR is decreased, and ATT is increased.
-- We also add the reservation data to the rsv_info plsql table.
-- Saving the data keeps us from having to query the table again.
-- After this, querying the tree will
-- reflect the actual ATT.

-- Bug 4194323 While cosidering Reservations against demand information
-- specified we should consider supply type reservations of Inventory only

PROCEDURE add_demand_qty(
    x_return_status  OUT NOCOPY VARCHAR2
        ,p_tree_id     IN  INTEGER
 ) IS

  l_root_id    INTEGER;
  l_revision    VARCHAR2(3);
  l_lot_number  VARCHAR2(80);
  l_subinventory_code VARCHAR2(10);
  l_locator_id  NUMBER;
  l_lpn_id  NUMBER;
  l_quantity    NUMBER;
  l_quantity2    NUMBER;
  l_mult NUMBER := -1;


  --We need 6 possible queries to improve performance and make best
  -- use of the indices on mtl_reservations, while avoid dynamic sql.

  -- demand line is not NULL, not pick release
  -- Bug 4494038: exclude crossdock reservations
  CURSOR c_demand_dl IS
  SELECT   revision
         , lot_number
         , subinventory_code
         , locator_id
         , lpn_id
         , primary_reservation_quantity - NVL(detailed_quantity, 0)
         , NVL(secondary_reservation_quantity, 0) - NVL(secondary_detailed_quantity, 0)
  FROM mtl_reservations
  WHERE organization_id                      = g_rootinfos(l_root_id).organization_id
    AND inventory_item_id                    = g_rootinfos(l_root_id).inventory_item_id
    AND demand_source_type_id                = g_demand_info(p_tree_id).demand_source_type_id
    AND demand_source_header_id              = g_demand_info(p_tree_id).demand_source_header_id
    AND demand_source_line_id                = g_demand_info(p_tree_id).demand_source_line_id
    AND NVL(demand_source_name, '@@@###@@#') = NVL(g_demand_info(p_tree_id).demand_source_name, '@@@###@@#')
    AND NVL(demand_source_delivery, -99999)  = NVL(g_demand_info(p_tree_id).demand_source_delivery, -99999)
    AND demand_source_line_detail IS NULL
    AND nvl(supply_source_type_id,13) = 13 ;                -- Bug 4194323

  -- demand name is not null, not pick release
  -- Bug 4494038: exclude crossdock reservations
  CURSOR c_demand_dn IS
  SELECT  revision
         ,lot_number
         ,subinventory_code
         ,locator_id
         ,lpn_id
         ,primary_reservation_quantity - NVL(detailed_quantity, 0)
         ,NVL(secondary_reservation_quantity, 0) - NVL(secondary_detailed_quantity, 0)
   FROM mtl_reservations
  WHERE organization_id                      = g_rootinfos(l_root_id).organization_id
    AND inventory_item_id                    = g_rootinfos(l_root_id).inventory_item_id
    AND demand_source_type_id                = g_demand_info(p_tree_id).demand_source_type_id
    AND demand_source_header_id              = g_demand_info(p_tree_id).demand_source_header_id
    AND demand_source_name                   = g_demand_info(p_tree_id).demand_source_name
    AND demand_source_line_id IS NULL
    AND NVL(demand_source_delivery, -99999)  = NVL(g_demand_info(p_tree_id).demand_source_delivery, -99999)
    AND demand_source_line_detail IS NULL
    AND nvl(supply_source_type_id,13) = 13 ;                -- Bug 4194323

  -- query based on org and item
  -- Bug 4494038: exclude crossdock reservations
  CURSOR c_demand IS
  SELECT  revision
         ,lot_number
         ,subinventory_code
         ,locator_id
         ,lpn_id
         ,primary_reservation_quantity - NVL(detailed_quantity, 0)
         ,NVL(secondary_reservation_quantity, 0) - NVL(secondary_detailed_quantity, 0)
   FROM mtl_reservations
  WHERE organization_id                      = g_rootinfos(l_root_id).organization_id
    AND inventory_item_id                    = g_rootinfos(l_root_id).inventory_item_id
    AND demand_source_type_id                = g_demand_info(p_tree_id).demand_source_type_id
    AND demand_source_header_id              = g_demand_info(p_tree_id).demand_source_header_id
    AND demand_source_line_id IS NULL
    AND demand_source_name IS NULL
    AND NVL(demand_source_delivery, -99999)  = NVL(g_demand_info(p_tree_id).demand_source_delivery, -99999)
    AND demand_source_line_detail IS NULL
    AND nvl(supply_source_type_id,13) = 13 ;                -- Bug 4194323

    -- pick release, query based on demand_source_line_id
  -- Bug 4494038: exclude crossdock reservations
  CURSOR c_demand_stage_dl IS
  SELECT  revision
         ,lot_number
         ,subinventory_code
         ,locator_id
         ,lpn_id
         ,primary_reservation_quantity - NVL(detailed_quantity, 0)
         ,NVL(secondary_reservation_quantity, 0) - NVL(secondary_detailed_quantity, 0)
   FROM mtl_reservations
   WHERE demand_source_line_id               = g_demand_info(p_tree_id).demand_source_line_id
    AND NVL(organization_id, 0)              = g_rootinfos(l_root_id).organization_id
    AND NVL(inventory_item_id,0)             = g_rootinfos(l_root_id).inventory_item_id
    AND demand_source_type_id                = g_demand_info(p_tree_id).demand_source_type_id
    AND demand_source_header_id              = g_demand_info(p_tree_id).demand_source_header_id
    AND NVL(demand_source_name, '@@@###@@#') = NVL(g_demand_info(p_tree_id).demand_source_name, '@@@###@@#')
    AND NVL(demand_source_delivery, -99999)  = NVL(g_demand_info(p_tree_id).demand_source_delivery, -99999)
    AND NVL(staged_flag, 'N') = 'N'
    AND demand_source_line_detail IS NULL
    AND nvl(supply_source_type_id,13) = 13 ;                -- Bug 4194323

  -- pick release, query based on demand_source_name
  -- Bug 4494038: exclude crossdock reservations
  CURSOR c_demand_stage_dn IS
  SELECT  revision
         ,lot_number
         ,subinventory_code
         ,locator_id
         ,lpn_id
         ,primary_reservation_quantity - NVL(detailed_quantity, 0)
         ,NVL(secondary_reservation_quantity, 0) - NVL(secondary_detailed_quantity, 0)
   FROM mtl_reservations
  WHERE organization_id                      = g_rootinfos(l_root_id).organization_id
    AND inventory_item_id                    = g_rootinfos(l_root_id).inventory_item_id
    AND demand_source_type_id                = g_demand_info(p_tree_id).demand_source_type_id
    AND demand_source_header_id              = g_demand_info(p_tree_id).demand_source_header_id
    AND demand_source_name                   = g_demand_info(p_tree_id).demand_source_name
    AND demand_source_line_id IS NULL
    AND NVL(demand_source_delivery, -99999)  = NVL(g_demand_info(p_tree_id).demand_source_delivery, -99999)
    AND NVL(staged_flag, 'N') = 'N'
    AND demand_source_line_detail IS NULL
    AND nvl(supply_source_type_id,13) = 13 ;                -- Bug 4194323

  -- pick release, query based on org and item
  -- Bug 4494038: exclude crossdock reservations
  CURSOR c_demand_stage IS
  SELECT  revision
         ,lot_number
         ,subinventory_code
         ,locator_id
         ,lpn_id
         ,primary_reservation_quantity - NVL(detailed_quantity, 0)
         ,NVL(secondary_reservation_quantity, 0) - NVL(secondary_detailed_quantity, 0)
   FROM mtl_reservations
  WHERE organization_id                      = g_rootinfos(l_root_id).organization_id
    AND inventory_item_id                    = g_rootinfos(l_root_id).inventory_item_id
    AND demand_source_type_id                = g_demand_info(p_tree_id).demand_source_type_id
    AND demand_source_header_id              = g_demand_info(p_tree_id).demand_source_header_id
    AND demand_source_line_id IS NULL
    AND demand_source_name = NULL
    AND NVL(demand_source_delivery, -99999)  = NVL(g_demand_info(p_tree_id).demand_source_delivery, -99999)
    AND NVL(staged_flag, 'N') = 'N'
    AND demand_source_line_detail IS NULL
    AND nvl(supply_source_type_id,13) = 13 ;                -- Bug 4194323
  is_lot_control Boolean :=false; -- Bug 4194323
BEGIN

   x_return_status := fnd_api.g_ret_sts_success;
   g_rsv_info.DELETE;
   g_rsv_counter := 0;
   l_root_id := g_demand_info(p_tree_id).root_id;
   is_lot_control:=g_rootinfos(l_root_id).is_lot_control;
   print_debug('in add_demand_qty, tree='||p_tree_id||', root='||l_root_id||', pick_release:'||g_demand_info(p_tree_id).pick_release||' ?= pick_release_yes:'||g_pick_release_yes);
   print_debug('demand_source__line_id='||g_demand_info(p_tree_id).demand_source_line_id);
   IF g_demand_info(p_tree_id).pick_release = g_pick_release_yes THEN

      -- have to make sure we don't picking from staging location
      if g_demand_info(p_tree_id).demand_source_line_id IS NOT NULL THEN
         OPEN c_demand_stage_dl;
         LOOP
            FETCH c_demand_stage_dl INTO
                  l_revision
                 ,l_lot_number
                 ,l_subinventory_code
                 ,l_locator_id
                 ,l_lpn_id
                 ,l_quantity
                 ,l_quantity2;

            EXIT WHEN c_demand_stage_dl%NOTFOUND;

            print_debug('in add_demand_qty, calling add_quantities, lot='||substr(l_lot_number,1,10)||', subinv='||l_subinventory_code||', loct_id='||l_locator_id||', qty1='||(l_mult * l_quantity)||', qty2='||(l_mult * l_quantity2)||'.');
            add_quantities(
                 x_return_status     => x_return_status
               , p_tree_id           => l_root_id
               , p_revision          => l_revision
               , p_lot_number        => l_lot_number
               , p_subinventory_code => l_subinventory_code
               , p_is_reservable_sub => TRUE
               , p_locator_id        => l_locator_id
               , p_primary_quantity  => l_mult * l_quantity
               , p_secondary_quantity=> l_mult * l_quantity2
               , p_quantity_type     => g_qr_other_demand
               , p_set_check_mark    => FALSE
               , p_cost_group_id     => NULL
               , p_lpn_id            => l_lpn_id
                 );

            print_debug('... after add_quantities... x_return_status='||x_return_status||', qty='||l_quantity||', qty2='||l_quantity2);
            IF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            g_rsv_counter := g_rsv_counter + 1;
            g_rsv_info(g_rsv_counter).revision := l_revision;
            g_rsv_info(g_rsv_counter).lot_number := l_lot_number;
            g_rsv_info(g_rsv_counter).subinventory_code := l_subinventory_code;
            g_rsv_info(g_rsv_counter).locator_id := l_locator_id;
            g_rsv_info(g_rsv_counter).lpn_id := l_lpn_id;
            g_rsv_info(g_rsv_counter).quantity := l_quantity;
            g_rsv_info(g_rsv_counter).secondary_quantity := l_quantity2;
         END LOOP;
         CLOSE c_demand_stage_dl;
      ELSIF g_demand_info(p_tree_id).demand_source_name IS NOT NULL then
         OPEN c_demand_stage_dn;
         LOOP
            FETCH c_demand_stage_dn INTO
                  l_revision
                 ,l_lot_number
                 ,l_subinventory_code
                 ,l_locator_id
                 ,l_lpn_id
                 ,l_quantity
                 ,l_quantity2;

            EXIT WHEN c_demand_stage_dn%NOTFOUND;

            print_debug('in add_demand_qty, calling add_quantities 2, lot='||substr(l_lot_number,1,10)||', subinv='||l_subinventory_code||', loct_id='||l_locator_id||', qty1='||(l_mult * l_quantity)||', qty2='||(l_mult * l_quantity2)||'.');
            add_quantities(
                 x_return_status     => x_return_status
               , p_tree_id           => l_root_id
               , p_revision          => l_revision
               , p_lot_number        => l_lot_number
               , p_subinventory_code => l_subinventory_code
               , p_is_reservable_sub => TRUE
               , p_locator_id        => l_locator_id
               , p_primary_quantity  => l_mult * l_quantity
               , p_secondary_quantity=> l_mult * l_quantity2
               , p_quantity_type     => g_qr_other_demand
               , p_set_check_mark    => FALSE
               , p_cost_group_id     => NULL
               , p_lpn_id      => l_lpn_id
                 );

            print_debug('... after add_quantities 2... x_return_status='||x_return_status||', qty='||l_quantity||', qty2='||l_quantity2);

            IF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            g_rsv_counter := g_rsv_counter + 1;
            g_rsv_info(g_rsv_counter).revision := l_revision;
            g_rsv_info(g_rsv_counter).lot_number := l_lot_number;
            g_rsv_info(g_rsv_counter).subinventory_code := l_subinventory_code;
            g_rsv_info(g_rsv_counter).locator_id := l_locator_id;
            g_rsv_info(g_rsv_counter).lpn_id := l_lpn_id;
            g_rsv_info(g_rsv_counter).quantity := l_quantity;
            g_rsv_info(g_rsv_counter).secondary_quantity := l_quantity2;
         END LOOP;
         CLOSE c_demand_stage_dn;
      else
         OPEN c_demand_stage;
         LOOP
            FETCH c_demand_stage INTO
                  l_revision
                 ,l_lot_number
                 ,l_subinventory_code
                 ,l_locator_id
                 ,l_lpn_id
                 ,l_quantity
                 ,l_quantity2;

            EXIT WHEN c_demand_stage%NOTFOUND;

            print_debug('in add_demand_qty, calling add_quantities 3, lot='||substr(l_lot_number,1,10)||', subinv='||l_subinventory_code||', loct_id='||l_locator_id||', qty1='||(l_mult * l_quantity)||', qty2='||(l_mult * l_quantity2)||'.');
            add_quantities(
                 x_return_status     => x_return_status
               , p_tree_id           => l_root_id
               , p_revision          => l_revision
               , p_lot_number        => l_lot_number
               , p_subinventory_code => l_subinventory_code
               , p_is_reservable_sub => TRUE
               , p_locator_id        => l_locator_id
               , p_primary_quantity  => l_mult * l_quantity
               , p_secondary_quantity=> l_mult * l_quantity2
               , p_quantity_type     => g_qr_other_demand
               , p_set_check_mark    => FALSE
               , p_cost_group_id     => NULL
               , p_lpn_id            => l_lpn_id
                 );

            print_debug('... after add_quantities 3... x_return_status='||x_return_status||', qty='||l_quantity||', qty2='||l_quantity2);

            IF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            g_rsv_counter := g_rsv_counter + 1;
            g_rsv_info(g_rsv_counter).revision := l_revision;
            g_rsv_info(g_rsv_counter).lot_number := l_lot_number;
            g_rsv_info(g_rsv_counter).subinventory_code := l_subinventory_code;
            g_rsv_info(g_rsv_counter).locator_id := l_locator_id;
            g_rsv_info(g_rsv_counter).lpn_id := l_lpn_id;
            g_rsv_info(g_rsv_counter).quantity := l_quantity;
            g_rsv_info(g_rsv_counter).secondary_quantity := l_quantity2;
         END LOOP;
         CLOSE c_demand_stage;
      end if;
   ELSE
      if g_demand_info(p_tree_id).demand_source_line_id IS NOT NULL THEN
         OPEN c_demand_dl;
         LOOP
            FETCH c_demand_dl INTO
                  l_revision
                 ,l_lot_number
                 ,l_subinventory_code
                 ,l_locator_id
                 ,l_lpn_id
                 ,l_quantity
                 ,l_quantity2;

            if NOT is_lot_control then  -- Bug 4194323
               l_lot_number:=null;
            end if;

            EXIT WHEN c_demand_dl%NOTFOUND;

            print_debug('in add_demand_qty, calling add_quantities 4, lot='||substr(l_lot_number,1,10)||', subinv='||l_subinventory_code||', loct_id='||l_locator_id||', qty1='||(l_mult * l_quantity)||', qty2='||(l_mult * l_quantity2)||'.');
            add_quantities(
                 x_return_status     => x_return_status
               , p_tree_id           => l_root_id
               , p_revision          => l_revision
               , p_lot_number        => l_lot_number
               , p_subinventory_code => l_subinventory_code
               , p_is_reservable_sub => TRUE
               , p_locator_id        => l_locator_id
               , p_primary_quantity  => l_mult * l_quantity
               , p_secondary_quantity=> l_mult * l_quantity2
               , p_quantity_type     => g_qr_other_demand
               , p_set_check_mark    => FALSE
               , p_cost_group_id     => NULL
               , p_lpn_id            => l_lpn_id
                 );

            print_debug('... after add_quantities 4... x_return_status='||x_return_status||', qty='||l_quantity||', qty2='||l_quantity2);

            IF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            g_rsv_counter := g_rsv_counter + 1;
            g_rsv_info(g_rsv_counter).revision := l_revision;
            g_rsv_info(g_rsv_counter).lot_number := l_lot_number;
            g_rsv_info(g_rsv_counter).subinventory_code := l_subinventory_code;
            g_rsv_info(g_rsv_counter).locator_id := l_locator_id;
            g_rsv_info(g_rsv_counter).lpn_id := l_lpn_id;
            g_rsv_info(g_rsv_counter).quantity := l_quantity;
            g_rsv_info(g_rsv_counter).secondary_quantity := l_quantity2;

        END LOOP;
        CLOSE c_demand_dl;
     elsif g_demand_info(p_tree_id).demand_source_name IS NOT NULL THEN
        OPEN c_demand_dn;
        LOOP
           FETCH c_demand_dn INTO
                  l_revision
                 ,l_lot_number
                 ,l_subinventory_code
                 ,l_locator_id
                 ,l_lpn_id
                 ,l_quantity
                 ,l_quantity2;

            EXIT WHEN c_demand_dn%NOTFOUND;

            print_debug('in add_demand_qty, calling add_quantities 5, lot='||substr(l_lot_number,1,10)||', subinv='||l_subinventory_code||', loct_id='||l_locator_id||', qty1='||(l_mult * l_quantity)||', qty2='||(l_mult * l_quantity2)||'.');
            add_quantities(
                 x_return_status     => x_return_status
               , p_tree_id           => l_root_id
               , p_revision          => l_revision
               , p_lot_number        => l_lot_number
               , p_subinventory_code => l_subinventory_code
               , p_is_reservable_sub => TRUE
               , p_locator_id        => l_locator_id
               , p_primary_quantity  => l_mult * l_quantity
               , p_secondary_quantity=> l_mult * l_quantity2
               , p_quantity_type     => g_qr_other_demand
               , p_set_check_mark    => FALSE
               , p_cost_group_id     => NULL
               , p_lpn_id            => l_lpn_id
                 );

            print_debug('... after add_quantities 5... x_return_status='||x_return_status||', qty='||l_quantity||', qty2='||l_quantity2);

            IF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            g_rsv_counter := g_rsv_counter + 1;
            g_rsv_info(g_rsv_counter).revision := l_revision;
            g_rsv_info(g_rsv_counter).lot_number := l_lot_number;
            g_rsv_info(g_rsv_counter).subinventory_code := l_subinventory_code;
            g_rsv_info(g_rsv_counter).locator_id := l_locator_id;
            g_rsv_info(g_rsv_counter).lpn_id := l_lpn_id;
            g_rsv_info(g_rsv_counter).quantity := l_quantity;
            g_rsv_info(g_rsv_counter).secondary_quantity := l_quantity2;

        END LOOP;
        CLOSE c_demand_dn;
     else
        OPEN c_demand;
        LOOP
            FETCH  c_demand INTO
                  l_revision
                 ,l_lot_number
                 ,l_subinventory_code
                 ,l_locator_id
                 ,l_lpn_id
                 ,l_quantity
                 ,l_quantity2;

            EXIT WHEN c_demand%NOTFOUND;

            print_debug('in add_demand_qty, calling add_quantities 6, lot='||substr(l_lot_number,1,10)||', subinv='||l_subinventory_code||', loct_id='||l_locator_id||', qty1='||(l_mult * l_quantity)||', qty2='||(l_mult * l_quantity2)||'.');
            add_quantities(
                 x_return_status     => x_return_status
               , p_tree_id           => l_root_id
               , p_revision          => l_revision
               , p_lot_number        => l_lot_number
               , p_subinventory_code => l_subinventory_code
               , p_is_reservable_sub => TRUE
               , p_locator_id        => l_locator_id
               , p_primary_quantity  => l_mult * l_quantity
               , p_secondary_quantity=> l_mult * l_quantity2
               , p_quantity_type     => g_qr_other_demand
               , p_set_check_mark    => FALSE
               , p_cost_group_id     => NULL
               , p_lpn_id            => l_lpn_id
                 );

            print_debug('... after add_quantities 6... x_return_status='||x_return_status||', qty='||l_quantity||', qty2='||l_quantity2);

            IF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            g_rsv_counter := g_rsv_counter + 1;
            g_rsv_info(g_rsv_counter).revision := l_revision;
            g_rsv_info(g_rsv_counter).lot_number := l_lot_number;
            g_rsv_info(g_rsv_counter).subinventory_code := l_subinventory_code;
            g_rsv_info(g_rsv_counter).locator_id := l_locator_id;
            g_rsv_info(g_rsv_counter).lpn_id := l_lpn_id;
            g_rsv_info(g_rsv_counter).quantity := l_quantity;
            g_rsv_info(g_rsv_counter).secondary_quantity := l_quantity2;

        END LOOP;
        CLOSE c_demand;
     end if;
   END IF;
   print_debug('... ending add_demand_qty');

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              ,'Add_Demand_Qty'
              );
      END IF;
END add_demand_qty;


--subtract_demand_qty
-- This counteracts the actions of add_demand_qty.
-- For each record in the rsv_info table, add_quantities is called,
-- which increases QR and decrease ATT.
PROCEDURE subtract_demand_qty(
    x_return_status  OUT NOCOPY VARCHAR2
        ,p_tree_id     IN  INTEGER
 ) IS

  l_root_id    INTEGER;

BEGIN
   print_debug('... entering subtract_demand_qty');

   x_return_status := fnd_api.g_ret_sts_success;

   l_root_id := g_demand_info(p_tree_id).root_id;

   FOR i in 1..g_rsv_counter LOOP
      print_debug('in subtract_demand_qty, calling add_quantities, qty1='||g_rsv_info(i).quantity||', qty2='||g_rsv_info(i).secondary_quantity||';');

      add_quantities(
              x_return_status     => x_return_status
            , p_tree_id           => l_root_id
            , p_revision          => g_rsv_info(i).revision
            , p_lot_number        => g_rsv_info(i).lot_number
            , p_subinventory_code => g_rsv_info(i).subinventory_code
            , p_is_reservable_sub => TRUE
            , p_locator_id        => g_rsv_info(i).locator_id
            , p_primary_quantity  => g_rsv_info(i).quantity
            , p_secondary_quantity=> g_rsv_info(i).secondary_quantity
            , p_quantity_type     => g_qr_other_demand
            , p_set_check_mark    => FALSE
            , p_cost_group_id     => NULL
            , p_lpn_id            => g_rsv_info(i).lpn_id
              );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   END LOOP;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              ,'Subtract_Demand_Qty'
              );
      END IF;
END subtract_demand_qty;

--check_demand_trees
--    Returns TRUE if two entries in the demand info
-- plsql table are equivalent.  Used to determine if the
-- demand info needs to be subtracted from the qty tree.
FUNCTION check_demand_trees(
         p_rsv_tree    IN  INTEGER
   ,p_new_tree   IN  INTEGER
 ) RETURN BOOLEAN IS

BEGIN

  IF (g_demand_info(p_rsv_tree).root_id = g_demand_info(p_new_tree).root_id)
    AND
     (g_demand_info(p_rsv_tree).demand_source_type_id = g_demand_info(p_new_tree).demand_source_type_id)
    AND
     ((g_demand_info(p_rsv_tree).demand_source_header_id IS NULL AND
       g_demand_info(p_new_tree).demand_source_header_id IS NULL) OR
      (g_demand_info(p_rsv_tree).demand_source_header_id = g_demand_info(p_new_tree).demand_source_header_id))
    AND
     ((g_demand_info(p_rsv_tree).demand_source_line_id IS NULL AND
       g_demand_info(p_new_tree).demand_source_line_id IS NULL) OR
      (g_demand_info(p_rsv_tree).demand_source_line_id = g_demand_info(p_new_tree).demand_source_line_id))
    AND
     ((g_demand_info(p_rsv_tree).demand_source_name IS NULL AND
       g_demand_info(p_new_tree).demand_source_name IS NULL) OR
      (g_demand_info(p_rsv_tree).demand_source_name = g_demand_info(p_new_tree).demand_source_name))
    AND
     ((g_demand_info(p_rsv_tree).demand_source_delivery IS NULL AND
       g_demand_info(p_new_tree).demand_source_delivery IS NULL) OR
      (g_demand_info(p_rsv_tree).demand_source_delivery = g_demand_info(p_new_tree).demand_source_delivery))
    AND
     ((g_demand_info(p_rsv_tree).pick_release IS NULL AND
       g_demand_info(p_new_tree).pick_release IS NULL) OR
      (g_demand_info(p_rsv_tree).pick_release = g_demand_info(p_new_tree).pick_release))
  THEN
     return TRUE;
  ELSE
     return FALSE;
  END IF;
END check_demand_trees;

-- Public Functions and Procedures

PROCEDURE clear_quantity_cache IS
BEGIN
   g_rootinfos.DELETE;
   g_nodes.DELETE;
   g_rootinfo_counter :=0;
   g_org_item_trees.DELETE;
   g_all_roots.DELETE;
   g_all_roots_counter := 0;
   g_saveroots.DELETE;
   g_nodes.DELETE;
   g_demand_info.DELETE;
   g_demand_counter := 0;
   g_rsv_info.DELETE;
   g_rsv_counter := 0;
   g_rsv_tree_id := 0;
   g_max_hash_rec := 0;
   print_debug('All Quantity Trees distroyed',9);
END clear_quantity_cache;

-- Procedure
--   query tree
--
--  Version
--   Current version       1.0
--   Initial version       1.0
--
-- Input parameters:
--   p_api_version_number   standard input parameter
--   p_init_msg_lst         standard input parameter
--   p_tree_id              tree_id
--   p_revision             revision
--   p_lot_number           lot_number
--   p_subinventory_code    subinventory code
--   p_locator_id           locator_id
--
-- Output parameters:
--   x_return_status       standard output parameter
--   x_msg_count           standard output parameter
--   x_msg_data            standard output parameter
--   x_qoh                 qoh
--   x_rqoh                rqoh
--   x_qr                  qr
--   x_qs                  qs
--   x_att                 att
--   x_atr                 atr
--
PROCEDURE query_tree
  (   p_api_version_number   IN  NUMBER
   ,  p_init_msg_lst         IN  VARCHAR2
   ,  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  x_qoh                  OUT NOCOPY NUMBER
   ,  x_rqoh                 OUT NOCOPY NUMBER
   ,  x_qr                   OUT NOCOPY NUMBER
   ,  x_qs                   OUT NOCOPY NUMBER
   ,  x_att                  OUT NOCOPY NUMBER
   ,  x_atr                  OUT NOCOPY NUMBER
   ,  p_transfer_subinventory_code IN  VARCHAR2
   ,  p_cost_group_id        IN  NUMBER
   ,  p_lpn_id               IN  NUMBER
   ,  p_transfer_locator_id  IN  NUMBER
   ) IS

   l_sqoh    NUMBER;
   l_srqoh   NUMBER;
   l_sqr     NUMBER;
   l_sqs     NUMBER;
   l_satt    NUMBER;
   l_satr    NUMBER;

BEGIN
   query_tree(
      p_api_version_number  =>  p_api_version_number
   ,  p_init_msg_lst        =>  p_init_msg_lst
   ,  x_return_status       =>  x_return_status
   ,  x_msg_count           =>  x_msg_count
   ,  x_msg_data            =>  x_msg_data
   ,  p_tree_id             =>  p_tree_id
   ,  p_revision            =>  p_revision
   ,  p_lot_number          =>  p_lot_number
   ,  p_subinventory_code   =>  p_subinventory_code
   ,  p_locator_id          =>  p_locator_id
   ,  x_qoh                 =>  x_qoh
   ,  x_rqoh                =>  x_rqoh
   ,  x_qr                  =>  x_qr
   ,  x_qs                  =>  x_qs
   ,  x_att                 =>  x_att
   ,  x_atr                 =>  x_atr
   ,  x_sqoh                =>  l_sqoh
   ,  x_srqoh               =>  l_srqoh
   ,  x_sqr                 =>  l_sqr
   ,  x_sqs                 =>  l_sqs
   ,  x_satt                =>  l_satt
   ,  x_satr                =>  l_satr
   ,  p_transfer_subinventory_code => p_transfer_subinventory_code
   ,  p_cost_group_id       =>  p_cost_group_id
   ,  p_lpn_id              =>  p_lpn_id
   ,  p_transfer_locator_id =>  p_transfer_locator_id
   );

   -- Calling the new signature API.

END query_tree;

PROCEDURE query_tree
  (   p_api_version_number   IN  NUMBER
   ,  p_init_msg_lst         IN  VARCHAR2
   ,  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  x_qoh                  OUT NOCOPY NUMBER
   ,  x_rqoh                 OUT NOCOPY NUMBER
   ,  x_qr                   OUT NOCOPY NUMBER
   ,  x_qs                   OUT NOCOPY NUMBER
   ,  x_att                  OUT NOCOPY NUMBER
   ,  x_atr                  OUT NOCOPY NUMBER
   ,  x_sqoh                 OUT NOCOPY NUMBER
   ,  x_srqoh                OUT NOCOPY NUMBER
   ,  x_sqr                  OUT NOCOPY NUMBER
   ,  x_sqs                  OUT NOCOPY NUMBER
   ,  x_satt                 OUT NOCOPY NUMBER
   ,  x_satr                 OUT NOCOPY NUMBER
   ,  p_transfer_subinventory_code IN  VARCHAR2
   ,  p_cost_group_id        IN  NUMBER
   ,  p_lpn_id               IN  NUMBER
   ,  p_transfer_locator_id  IN  NUMBER
   ) IS
      l_api_version_number   CONSTANT NUMBER       := 1.0;
      l_api_name             CONSTANT VARCHAR2(30) := 'QUERY_TREE';
      l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_node_index           INTEGER;
      l_atr                  NUMBER;
      l_att                  NUMBER;
      l_satr                 NUMBER;
      l_satt                 NUMBER;
      l_tree_id              NUMBER;
      l_is_reservable_sub    BOOLEAN;
      l_is_reservable_transfer_sub BOOLEAN;
      l_found                BOOLEAN;
      l_loop_index           INTEGER;
      l_sub_index            NUMBER;
      l_root_id              INTEGER;
      l_lpn_id               NUMBER;
      l_is_reservable_item   BOOLEAN;
      --Bug 4294336
      l_atr2                 NUMBER;
      l_satr2                NUMBER;
      l_debug_line           VARCHAR2(300);

BEGIN
   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_root_id := g_demand_info(p_tree_id).root_id;
   -- check if tree id is valid
   IF is_tree_valid(l_root_id) = FALSE THEN
      fnd_message.set_name('INV', 'INV-Qtyroot not found');
      fnd_message.set_token('ROUTINE', 'Query_Tree');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   print_debug('>>> In query_tree : mode='||g_demand_info(p_tree_id).tree_mode||', tree_id='||p_tree_id
      ||'..for item='||g_rootinfos(l_root_id).inventory_item_id||' rev='||p_revision||' lot='||p_lot_number
      ||' sub='||p_subinventory_code||' loc='||p_locator_id||' lpn='||p_lpn_id
      ||'   xfrsub='||p_transfer_subinventory_code||' xfrloc='||p_transfer_locator_id,9);

   --subtract out reservations added when tree was queried in txn mode
   IF g_demand_info(p_tree_id).tree_mode = g_reservation_mode THEN
      if g_rsv_tree_id <> 0 then
         print_debug('  Reservation Mode, calling subtract_demand_qty with rsv_tree_id='||g_rsv_tree_id, 12);
         subtract_demand_qty(
              x_return_status => l_return_status
            , p_tree_id       => g_rsv_tree_id
         );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
         g_rsv_tree_id := 0;
         g_rsv_counter := 0;
         g_rsv_info.DELETE;
      ELSE
         print_debug('  Reservation Mode, tree_id=0', 12);
      end if;
   ELSIF g_demand_info(p_tree_id).tree_mode = g_transaction_mode THEN
      --subtract out rsv info if the tree is currently for a diff demand source
      if g_rsv_tree_id <> 0 AND check_demand_trees(g_rsv_tree_id, p_tree_id) = FALSE then
         print_debug('  Transaction Mode, calling subtract_demand_qty with rsv_tree_id='||g_rsv_tree_id, 12);

         subtract_demand_qty(
              x_return_status => l_return_status
            , p_tree_id       => g_rsv_tree_id
         );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
         g_rsv_tree_id := 0;
         g_rsv_counter := 0;
         g_rsv_info.DELETE;
      end if;

      if g_rsv_tree_id = 0 then
         print_debug('  Transaction Mode, rsv_tree_id=0, calling add_demand_qty', 12);
         add_demand_qty(
               x_return_status => l_return_status
             , p_tree_id       => p_tree_id
             );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
         g_rsv_tree_id := p_tree_id;
      ELSE
         print_debug('  Transaction Mode, rsv_tree_id='||g_rsv_tree_id, 12);
      end if;
   END IF;   -- tree_mode

   print_debug('QT, calling find_tree_node, tree_id='||l_root_id||', p_tree_id='||p_tree_id);
   l_found := find_tree_node(
                      x_return_status      => l_return_status
                    , p_tree_id            => l_root_id
                    , p_revision           => p_revision
                    , p_lot_number         => p_lot_number
                    , p_subinventory_code  => p_subinventory_code
                    , p_is_reservable_sub  => NULL
                    , p_locator_id         => p_locator_id
                    , x_node_index         => l_node_index
                    , p_lpn_id             => p_lpn_id
                    , p_cost_group_id      => p_cost_group_id
                    );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   IF l_found = FALSE THEN
      fnd_message.set_name('INV','INV-Cannot find node');
      fnd_message.set_token('ROUTINE', 'Query_Tree');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   x_qoh  := g_nodes(l_node_index).qoh;
   x_rqoh := g_nodes(l_node_index).rqoh;
   x_qr   := g_nodes(l_node_index).qr;
   x_qs   := g_nodes(l_node_index).qs;
   x_sqoh  := g_nodes(l_node_index).sqoh;
   x_srqoh := g_nodes(l_node_index).srqoh;
   x_sqr   := g_nodes(l_node_index).sqr;
   x_sqs   := g_nodes(l_node_index).sqs;

   g_pqoh := g_nodes(l_node_index).pqoh;
   g_spqoh := g_nodes(l_node_index).spqoh;

  /*********************************************************************
   * Logic for finding ATT and ATR:
   *  (Secondary quantities follow the same computation)
   * If Node is at Sub level or below
   *    Get reservable for From Sub and To Sub
   *    If From Sub is not reservable
   *       ATT = ATT of node; ATR = 0
   *    If From Sub = To Sub
   *       ATT = min(ATT of node, ATR of ancestor nodes below sub)
   *       ATR = min(ATR of node, ATR of ancestor nodes below sub)
   *         (don't need to look at upper reservations, since all reservations
   *          except those at Locator and lpn level are not affected by move)
   *    If To Sub is Reservable
   *       ATT = min(ATT of node, ATR of ancestor nodes up to sub)
   *       ATR = min(ATR of node, ATR of ancestor nodes up to sub)
   *          (don't need to look at upper reservations, since
   *           all reservations
   *           above Sub level are not affected by move)
   *    Else (From Sub is reservable and To Sub is not Reservable)
   *       ATT = min (ATT of node, ATR of all ancestor nodes)
   *       ATR = min (ATR of node, ATR of all ancestor nodes)
   * Else (node above sub level)
   *    ATR = min (ATR at node, ATR of all ancestor nodes)
   *    ATT = min (ATT at node, ATT of all ancestor nodes)
   *********************************************************************/


   -- find out reservable_type if sub code is not null
   IF (p_subinventory_code IS NOT NULL) THEN

      --bug 9380420, commenting the code below, as is_reservable_sub should be checked from g_nodes.
      /*
      l_sub_index := get_ancestor_sub(l_node_index);
      print_debug('--after get_ancestor_sub... node_index='||l_node_index||', l_sub_index='||l_sub_index||', level='||g_nodes(l_sub_index).node_level);
      l_is_reservable_sub:=g_nodes(l_sub_index).is_reservable_sub;

      IF l_is_reservable_sub = TRUE
      THEN
          print_debug('.... is reservable_sub=TRUE');
      ELSIF l_is_reservable_sub = FALSE
      THEN
          print_debug('.... is reservable_sub=FALSES');
      ELSE
          print_debug('.... is reservable_sub=other value');
      END IF;

      -- get that info from db table if not in the node
      --     why: because, if reservable_sub=FALSE, everything below will be NON-reservable.
      --                   if reservable_sub=TRUE, must check the other level.
      IF (l_is_reservable_sub IS NULL OR l_is_reservable_sub = TRUE)
      THEN
         check_is_reservable
              ( x_return_status     => l_return_status
              , p_inventory_item_id => g_rootinfos(l_root_id).inventory_item_id
              , p_organization_id   => g_rootinfos(l_root_id).organization_id
              , p_subinventory_code => p_subinventory_code
              , p_locator_id        => p_locator_id
              , p_lot_number        => p_lot_number
              , p_root_id           => l_root_id
              , x_is_reservable     => l_is_reservable_sub
              , p_lpn_id            => p_lpn_id); -- Onhand Material Status Support

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         End IF ;

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         End IF;

      END IF;   -- l_is_reservable_sub
      */
      l_is_reservable_sub := g_nodes(l_node_index).is_reservable_sub;


      IF l_is_reservable_sub = TRUE THEN
          l_debug_line := '  Sub '||p_subinventory_code||' is reservable';
      ELSIF l_is_reservable_sub = FALSE THEN
          l_debug_line := '  Sub '||p_subinventory_code||' is not reservable';
      END IF;

      --get reservable type for to sub
      IF (p_transfer_subinventory_code IS NOT NULL) THEN
         check_is_reservable
              ( x_return_status     => l_return_status
              , p_inventory_item_id => g_rootinfos(l_root_id).inventory_item_id
              , p_organization_id   => g_rootinfos(l_root_id).organization_id
              , p_subinventory_code => p_transfer_subinventory_code
              , p_locator_id        => p_transfer_locator_id
              , p_lot_number        => p_lot_number
              , p_root_id           => l_root_id
              , x_is_reservable     => l_is_reservable_transfer_sub
              , p_lpn_id            => p_lpn_id); -- Onhand Material Status Support

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         End IF ;

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         End IF;

         IF l_is_reservable_transfer_sub = TRUE THEN
            l_debug_line := l_debug_line||'  Xfr Sub '||p_transfer_subinventory_code||' is reservable';
         ELSIF l_is_reservable_transfer_sub = FALSE THEN
            l_debug_line := l_debug_line||'  Xfr Sub '||p_transfer_subinventory_code||' is not reservable';
         END IF;

      ELSE
         l_is_reservable_transfer_sub := FALSE;
      END IF;     -- p_transfer_subinventory_code

      print_debug(l_debug_line, 12);
      l_debug_line := '';

      --From sub is not reservable
      IF l_is_reservable_sub = FALSE THEN
          l_atr := 0;
          l_att := g_nodes(l_node_index).att;
          l_satr := 0;
          l_satt := g_nodes(l_node_index).satt;

      --From Loc = To Loc (LPN unpack)
      ELSIF (p_transfer_locator_id IS NOT NULL AND p_transfer_locator_id = p_locator_id) THEN
          l_atr := g_nodes(l_node_index).atr;
          l_att := g_nodes(l_node_index).att;
          l_satr := g_nodes(l_node_index).satr;
          l_satt := g_nodes(l_node_index).satt;
          print_debug('    Node = '||g_nodes(l_node_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);
          l_loop_index := g_nodes(l_node_index).parent_index;
          LOOP
             EXIT WHEN g_nodes(l_loop_index).node_level <= g_locator_level;
             IF l_atr > g_nodes(l_loop_index).atr THEN
                l_atr := g_nodes(l_loop_index).atr;
                l_satr := g_nodes(l_loop_index).satr;
             END IF;
             -- bug 9379407
             /*
             IF l_att > g_nodes(l_loop_index).atr THEN
                l_att := g_nodes(l_loop_index).atr;
                l_satt := g_nodes(l_loop_index).satr;
             END IF;
             */
             IF l_att > g_nodes(l_loop_index).att THEN
                l_att := g_nodes(l_loop_index).att;
                l_satt := g_nodes(l_loop_index).satt;
             END IF;
             print_debug('    Node = '||g_nodes(l_loop_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);
             l_loop_index :=  g_nodes(l_loop_index).parent_index;
          END LOOP;
      --From Sub = To Sub
      ELSIF (p_transfer_subinventory_code IS NOT NULL AND p_transfer_subinventory_code = p_subinventory_code) THEN
          l_atr := g_nodes(l_node_index).atr;
          l_att := g_nodes(l_node_index).att;
          l_satr := g_nodes(l_node_index).satr;
          l_satt := g_nodes(l_node_index).satt;
          print_debug('    Node = '||g_nodes(l_node_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);
          l_loop_index := g_nodes(l_node_index).parent_index;
          LOOP
             EXIT WHEN g_nodes(l_loop_index).node_level <= g_sub_level;
             IF l_atr > g_nodes(l_loop_index).atr THEN
                l_atr := g_nodes(l_loop_index).atr;
                l_satr := g_nodes(l_loop_index).satr;
             END IF;
             -- bug 9379407
             /*
             IF l_att > g_nodes(l_loop_index).atr THEN
                l_att := g_nodes(l_loop_index).atr;
                l_satt := g_nodes(l_loop_index).satr;
             END IF;
             */
             IF l_att > g_nodes(l_loop_index).att THEN
                l_att := g_nodes(l_loop_index).att;
                l_satt := g_nodes(l_loop_index).satt;
             END IF;

             print_debug('    Node = '||g_nodes(l_loop_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);
             l_loop_index :=  g_nodes(l_loop_index).parent_index;
          END LOOP;
      -- To Sub is Reservable (FALSE if To Sub is NULL)
      ELSIF (l_is_reservable_transfer_sub) THEN
          l_atr := g_nodes(l_node_index).atr;
          l_att := g_nodes(l_node_index).att;
          l_satr := g_nodes(l_node_index).satr;
          l_satt := g_nodes(l_node_index).satt;
          print_debug('    Node = '||g_nodes(l_node_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);
          l_loop_index := g_nodes(l_node_index).parent_index;
          LOOP
             EXIT WHEN g_nodes(l_loop_index).node_level < g_sub_level;
             IF l_atr > g_nodes(l_loop_index).atr THEN
                l_atr := g_nodes(l_loop_index).atr;
                l_satr := g_nodes(l_loop_index).satr;
             END IF;
             --bug 9379407
             /*
             IF l_att > g_nodes(l_loop_index).atr THEN
                l_att := g_nodes(l_loop_index).atr;
                l_satt := g_nodes(l_loop_index).satr;
             END IF;
             */
             IF l_att > g_nodes(l_loop_index).att THEN
                l_att := g_nodes(l_loop_index).att;
                l_satt := g_nodes(l_loop_index).satt;
             END IF;

             print_debug('    Node = '||g_nodes(l_loop_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);
             l_loop_index :=  g_nodes(l_loop_index).parent_index;
          END LOOP;

      -- From Sub is reservable and To Sub is Null or Not Reservable
      ELSE
          l_atr := g_nodes(l_node_index).atr;
          l_att := g_nodes(l_node_index).att;
          l_satr := g_nodes(l_node_index).satr;
          l_satt := g_nodes(l_node_index).satt;
          print_debug('    Node = '||g_nodes(l_node_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);
          l_loop_index := g_nodes(l_node_index).parent_index;
          LOOP
             IF l_atr > g_nodes(l_loop_index).atr THEN
                l_atr := g_nodes(l_loop_index).atr;
                l_satr := g_nodes(l_loop_index).satr;
             END IF;

             -- bug 9379407
             /*
             IF (l_att > g_nodes(l_loop_index).atr) THEN
               l_att  := g_nodes(l_loop_index).atr;
               l_satt := g_nodes(l_loop_index).satr;
             END IF;
             */
             IF (l_att > g_nodes(l_loop_index).att) THEN
               l_att  := g_nodes(l_loop_index).att;
               l_satt := g_nodes(l_loop_index).satt;
             END IF;
             print_debug('    Node = '||g_nodes(l_loop_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);

             EXIT WHEN g_nodes(l_loop_index).node_level = g_item_level;
             l_loop_index :=  g_nodes(l_loop_index).parent_index;
          END LOOP;
      END IF;
   --Node level above sub level (Item, Revision, Lot)
   ELSE
      -- p_subinventory_code IS NULL:
      print_debug('QT, p_subinventory_code(null?)='||p_subinventory_code);
      l_atr := g_nodes(l_node_index).atr;
      l_att := g_nodes(l_node_index).att;
      l_satr := g_nodes(l_node_index).satr;
      l_satt := g_nodes(l_node_index).satt;

      --Bug 4294336
      IF g_nodes(l_node_index).node_level = g_item_level THEN
        l_atr := g_nodes(l_node_index).atr - g_nodes(l_node_index).qs_adj1 ;
        l_satr := g_nodes(l_node_index).satr - g_nodes(l_node_index).sqs_adj1 ;
      END IF;
      print_debug('    Node = '||g_nodes(l_node_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);

      IF g_nodes(l_node_index).node_level <> g_item_level THEN
          l_loop_index := g_nodes(l_node_index).parent_index;
          LOOP
             --Bug 4294336
             l_atr2 := g_nodes(l_loop_index).atr - g_nodes(l_loop_index).qs_adj1 ;
             l_satr2 := g_nodes(l_loop_index).satr - g_nodes(l_loop_index).sqs_adj1 ;

             IF l_atr > l_atr2 THEN
                l_atr := l_atr2 ;
                l_satr := l_satr2;
             END IF;

             IF l_att > g_nodes(l_loop_index).att THEN
                l_att := g_nodes(l_loop_index).att;
                l_satt := g_nodes(l_loop_index).satt;
             END IF;
             print_debug('    Node = '||g_nodes(l_loop_index).node_level||'   ATT = '||LPAD(l_att, 10)||' ATR = '||LPAD(l_atr,10), 12);
             EXIT WHEN g_nodes(l_loop_index).node_level = g_item_level;
             l_loop_index :=  g_nodes(l_loop_index).parent_index;
          END LOOP;
      END IF;
   END IF;     -- p_subinventory_code

   --bug 9380420, checking the is_reservable flag from g_nodes.
   /*
   --Bug 3424532 atr should be returned as 0 for non reservable items
   check_is_reservable_item
       (  x_return_status      => l_return_status
        , p_organization_id    => g_rootinfos(l_root_id).organization_id
        , p_inventory_item_id  => g_rootinfos(l_root_id).inventory_item_id
        , x_is_reservable_item => l_is_reservable_item
       );
   */
   l_is_reservable_item := g_nodes(g_rootinfos(l_root_id).item_node_index).is_reservable_sub;
   IF l_is_reservable_item THEN
      print_debug('  Item_reservable = YES');
      x_atr := l_atr;
      x_satr := l_satr;
   ELSE
      print_debug('  Item_reservable = NO');
      x_atr := 0;
      x_satr := 0;
   END IF;
   x_att := l_att;
   x_satt := l_satt;

   -- Check whether the item is DUOM
   IF (g_rootinfos(l_root_id).is_DUOM_control = FALSE)
   THEN
      print_debug(' root_id='||l_root_id||', DUOM_control=FALSE');
      x_sqoh  := NULL;
      x_srqoh := NULL;
      x_sqr   := NULL;
      x_sqs   := NULL;
      g_spqoh := NULL;
      x_satr  := NULL;
      x_satt  := NULL;
   ELSE
      print_debug(' root_id='||l_root_id||', DUOM_control=TRUE');
   END IF;

   x_return_status := l_return_status;

   IF g_debug = 1 THEN
      print_tree(p_tree_id);
      print_debug(l_api_name || ' Exited with status = '||l_return_status||', Qty : '
                    || LPad(x_qoh,8)||':'||LPad(x_rqoh,8)||':'||LPad(x_qr,8)||':'||LPad(x_qs,8)||':'
                    || LPad(x_att,8)||':'||LPad(x_atr, 8)||':'||LPad(g_pqoh,8),9);
      print_debug('>> qoh2='||x_sqoh||', rqoh2='||x_srqoh||', qr2='||x_sqr||', qs2='||x_sqs||', pqoh2='||g_spqoh||', atr2='||x_satr||', att2='||x_satt);
      print_debug(' ',9);
   END IF;
EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        print_debug('QT: ending... g_exc_error'||SQLERRM,9);
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        print_debug('QT: ending... g_exc_unexpected_error '||SQLERRM,9);
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        print_debug('QT: ending... OTHERS.'||SQLERRM,9);
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
END query_tree;

PROCEDURE query_tree
  (   p_api_version_number   IN  NUMBER
   ,  p_init_msg_lst         IN  VARCHAR2
   ,  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  x_qoh                  OUT NOCOPY NUMBER
   ,  x_rqoh                 OUT NOCOPY NUMBER
   ,  x_pqoh                 OUT NOCOPY NUMBER
   ,  x_qr                   OUT NOCOPY NUMBER
   ,  x_qs                   OUT NOCOPY NUMBER
   ,  x_att                  OUT NOCOPY NUMBER
   ,  x_atr                  OUT NOCOPY NUMBER
   ,  p_transfer_subinventory_code IN  VARCHAR2
   ,  p_cost_group_id        IN  NUMBER
   ,  p_lpn_id               IN  NUMBER
   ,  p_transfer_locator_id  IN  NUMBER
   ) IS

l_sqoh    NUMBER;
l_srqoh   NUMBER;
l_sqr     NUMBER;
l_sqs     NUMBER;
l_satt    NUMBER;
l_satr    NUMBER;

BEGIN
query_tree(
      p_api_version_number  =>  p_api_version_number
   ,  p_init_msg_lst        =>  p_init_msg_lst
   ,  x_return_status       =>  x_return_status
   ,  x_msg_count           =>  x_msg_count
   ,  x_msg_data            =>  x_msg_data
   ,  p_tree_id             =>  p_tree_id
   ,  p_revision            =>  p_revision
   ,  p_lot_number          =>  p_lot_number
   ,  p_subinventory_code   =>  p_subinventory_code
   ,  p_locator_id          =>  p_locator_id
   ,  x_qoh                 =>  x_qoh
   ,  x_rqoh                =>  x_rqoh
   ,  x_qr                  =>  x_qr
   ,  x_qs                  =>  x_qs
   ,  x_att                 =>  x_att
   ,  x_atr                 =>  x_atr
   ,  x_sqoh                =>  l_sqoh
   ,  x_srqoh               =>  l_srqoh
   ,  x_sqr                 =>  l_sqr
   ,  x_sqs                 =>  l_sqs
   ,  x_satt                =>  l_satt
   ,  x_satr                =>  l_satr
   ,  p_transfer_subinventory_code => p_transfer_subinventory_code
   ,  p_cost_group_id       =>  p_cost_group_id
   ,  p_lpn_id              =>  p_lpn_id
   ,  p_transfer_locator_id =>  p_transfer_locator_id
);

   x_pqoh := g_pqoh;

END query_tree;

-- invConv changes begin : overloaded(2)
PROCEDURE query_tree
  (   p_api_version_number   IN  NUMBER
   ,  p_init_msg_lst         IN  VARCHAR2
   ,  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  x_qoh                  OUT NOCOPY NUMBER
   ,  x_rqoh                 OUT NOCOPY NUMBER
   ,  x_pqoh                 OUT NOCOPY NUMBER
   ,  x_qr                   OUT NOCOPY NUMBER
   ,  x_qs                   OUT NOCOPY NUMBER
   ,  x_att                  OUT NOCOPY NUMBER
   ,  x_atr                  OUT NOCOPY NUMBER
   ,  x_sqoh                 OUT NOCOPY NUMBER
   ,  x_srqoh                OUT NOCOPY NUMBER
   ,  x_spqoh                OUT NOCOPY NUMBER
   ,  x_sqr                  OUT NOCOPY NUMBER
   ,  x_sqs                  OUT NOCOPY NUMBER
   ,  x_satt                 OUT NOCOPY NUMBER
   ,  x_satr                 OUT NOCOPY NUMBER
   ,  p_transfer_subinventory_code IN  VARCHAR2
   ,  p_cost_group_id        IN  NUMBER
   ,  p_lpn_id               IN  NUMBER
   ,  p_transfer_locator_id  IN  NUMBER
   ) IS

    l_api_name             CONSTANT VARCHAR2(30) := 'Query_Tree';


BEGIN

    print_debug('  >>>>>>>>>  In query_tree2');

    query_tree(
          p_api_version_number  =>  p_api_version_number
       ,  p_init_msg_lst        =>  p_init_msg_lst
       ,  x_return_status       =>  x_return_status
       ,  x_msg_count           =>  x_msg_count
       ,  x_msg_data            =>  x_msg_data
       ,  p_tree_id             =>  p_tree_id
       ,  p_revision            =>  p_revision
       ,  p_lot_number          =>  p_lot_number
       ,  p_subinventory_code   =>  p_subinventory_code
       ,  p_locator_id          =>  p_locator_id
       ,  x_qoh                 =>  x_qoh
       ,  x_rqoh                =>  x_rqoh
       ,  x_qr                  =>  x_qr
       ,  x_qs                  =>  x_qs
       ,  x_att                 =>  x_att
       ,  x_atr                 =>  x_atr
       ,  x_sqoh                =>  x_sqoh
       ,  x_srqoh               =>  x_srqoh
       ,  x_sqr                 =>  x_sqr
       ,  x_sqs                 =>  x_sqs
       ,  x_satt                =>  x_satt
       ,  x_satr                =>  x_satr
       ,  p_transfer_subinventory_code => p_transfer_subinventory_code
       ,  p_cost_group_id       =>  p_cost_group_id
       ,  p_lpn_id              =>  p_lpn_id
       ,  p_transfer_locator_id =>  p_transfer_locator_id
    );

    x_pqoh := g_pqoh;
    x_spqoh := g_spqoh;

    print_debug('  End of  query_tree2');

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
END query_tree;

--
-- Procedure
--   create_tree
-- Description
--   Create a quantity tree
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--   p_organization_id         organzation id
--   p_inventory_item_id       inventory_item_id
--   p_tree_mode               tree mode, either g_reservation_mode
--                             or g_transaction_mode
--   p_is_revision_control
--   p_is_lot_control
--   p_is_serial_control
--   p_asset_sub_only
--   p_include_suggestion      should be true only for pick/put engine
--   p_demand_source_type_id   demand_source_type_id
--   p_demand_source_header_id demand_source_header_id
--   p_demand_source_line_id   demand_source_line_id
--   p_demand_source_name      demand_source_name
--   p_demand_source_delivery  demand_source_delivery
--   p_pick_release            whether qty tree called from pick release
--                             process or not
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--   x_tree_id                 used later to refer to the same tree
--
PROCEDURE create_tree
  (   p_api_version_number       IN  NUMBER
   ,  p_init_msg_lst             IN  VARCHAR2
   ,  x_return_status            OUT NOCOPY VARCHAR2
   ,  x_msg_count                OUT NOCOPY NUMBER
   ,  x_msg_data                 OUT NOCOPY VARCHAR2
   ,  p_organization_id          IN  NUMBER
   ,  p_inventory_item_id        IN  NUMBER
   ,  p_tree_mode                IN  INTEGER
   ,  p_is_revision_control      IN  BOOLEAN
   ,  p_is_lot_control           IN  BOOLEAN
   ,  p_is_serial_control        IN  BOOLEAN
   ,  p_asset_sub_only           IN  BOOLEAN
   ,  p_include_suggestion       IN  BOOLEAN
   ,  p_demand_source_type_id    IN  NUMBER
   ,  p_demand_source_header_id  IN  NUMBER
   ,  p_demand_source_line_id    IN  NUMBER
   ,  p_demand_source_name       IN  VARCHAR2
   ,  p_demand_source_delivery   IN  NUMBER
   ,  p_lot_expiration_date      IN  DATE
   ,  x_tree_id                  OUT NOCOPY INTEGER
   ,  p_onhand_source            IN  NUMBER
   ,  p_exclusive                IN  NUMBER
   ,  p_pick_release             IN  NUMBER

  ) IS

l_grade_code          VARCHAR2(150);

BEGIN
create_tree
  (   p_api_version_number       => p_api_version_number
   ,  p_init_msg_lst             => p_init_msg_lst
   ,  x_return_status            => x_return_status
   ,  x_msg_count                => x_msg_count
   ,  x_msg_data                 => x_msg_data
   ,  p_organization_id          => p_organization_id
   ,  p_inventory_item_id        => p_inventory_item_id
   ,  p_tree_mode                => p_tree_mode
   ,  p_is_revision_control      => p_is_revision_control
   ,  p_is_lot_control           => p_is_lot_control
   ,  p_is_serial_control        => p_is_serial_control
   ,  p_grade_code               => l_grade_code
   ,  p_asset_sub_only           => p_asset_sub_only
   ,  p_include_suggestion       => p_include_suggestion
   ,  p_demand_source_type_id    => p_demand_source_type_id
   ,  p_demand_source_header_id  => p_demand_source_header_id
   ,  p_demand_source_line_id    => p_demand_source_line_id
   ,  p_demand_source_name       => p_demand_source_name
   ,  p_demand_source_delivery   => p_demand_source_delivery
   ,  p_lot_expiration_date      => p_lot_expiration_date
   ,  x_tree_id                  => x_tree_id
   ,  p_onhand_source            => p_onhand_source
   ,  p_exclusive                => p_exclusive
   ,  p_pick_release             => p_pick_release
  );


END create_tree;

-- invConv changes begin : overload:
PROCEDURE create_tree
  (   p_api_version_number       IN  NUMBER
   ,  p_init_msg_lst             IN  VARCHAR2
   ,  x_return_status            OUT NOCOPY VARCHAR2
   ,  x_msg_count                OUT NOCOPY NUMBER
   ,  x_msg_data                 OUT NOCOPY VARCHAR2
   ,  p_organization_id          IN  NUMBER
   ,  p_inventory_item_id        IN  NUMBER
   ,  p_tree_mode                IN  INTEGER
   ,  p_is_revision_control      IN  BOOLEAN
   ,  p_is_lot_control           IN  BOOLEAN
   ,  p_is_serial_control        IN  BOOLEAN
   ,  p_grade_code               IN  VARCHAR2
   ,  p_asset_sub_only           IN  BOOLEAN
   ,  p_include_suggestion       IN  BOOLEAN
   ,  p_demand_source_type_id    IN  NUMBER
   ,  p_demand_source_header_id  IN  NUMBER
   ,  p_demand_source_line_id    IN  NUMBER
   ,  p_demand_source_name       IN  VARCHAR2
   ,  p_demand_source_delivery   IN  NUMBER
   ,  p_lot_expiration_date      IN  DATE
   ,  x_tree_id                  OUT NOCOPY INTEGER
   ,  p_onhand_source            IN  NUMBER
   ,  p_exclusive                IN  NUMBER
   ,  p_pick_release             IN  NUMBER

  ) IS
      l_api_version_number       CONSTANT NUMBER       := 1.0;
      l_api_name                 CONSTANT VARCHAR2(30) := 'CREATE_TREE';
      l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_rootinfo_index           INTEGER;
      l_demand_source_type_id    NUMBER;
      l_demand_source_header_id  NUMBER;
      l_demand_source_line_id    NUMBER;
      l_demand_source_name       VARCHAR2(30);
      l_demand_source_delivery   NUMBER;
      l_tree_id                  INTEGER;
      l_lot_expiration_date      DATE;

      l_lot_control            NUMBER;
      l_grade_control          VARCHAR2(1);
      l_grade_code             VARCHAR2(150);
      l_DUOM_control           VARCHAR2(3) := 'P';      -- Value = P for primary only
                                                        -- Value = PS for primary and secondary
      l_lot_status_enabled     VARCHAR2(2);
      l_debug_line             VARCHAR2(300);

      CURSOR get_item_details( org_id IN NUMBER, item_id IN NUMBER) IS
         SELECT  NVL(grade_control_flag, 'N')
               , NVL(lot_control_code, 1)
               , tracking_quantity_ind
               , lot_status_enabled
         FROM mtl_system_items
         WHERE inventory_item_id = item_id
         AND organization_id = org_id;

BEGIN
   IF g_debug IS NULL THEN
      g_debug :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   IF g_is_mat_status_used IS NULL THEN
      g_is_mat_status_used := NVL(FND_PROFILE.VALUE('INV_MATERIAL_STATUS'), 2);
   END IF;

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);

      l_debug_line := '>>> In create_tree : mode='||p_tree_mode||':'||p_organization_id||':'||p_inventory_item_id||': item ctrl: ';
      if (p_is_revision_control = TRUE)
      THEN
         l_debug_line := l_debug_line||'TRUE ';
      else
         l_debug_line := l_debug_line||'FASLE';
      end if;
      if (p_is_lot_control = TRUE)
      then
         l_debug_line := l_debug_line||':TRUE ';
      else
         l_debug_line := l_debug_line||':FALSE';
      end if;
      if (p_is_serial_control = TRUE)
      then
         l_debug_line := l_debug_line||':TRUE ';
      else
         l_debug_line := l_debug_line||':FALSE';
      end if;
      print_debug(l_debug_line || ': demand: '||p_demand_source_type_id||':'||p_demand_source_header_id||':'||p_demand_source_line_id
                    ||'  Profile: Material Status =' || g_is_mat_status_used ,12);
   END IF;


   if (p_is_revision_control = TRUE)
   THEN
   print_debug('  >>>>>>>>>  In create_tree. mode='||p_tree_mode||', grade='||p_grade_code||', rev_ctl=TRUE. mat_stat='||INV_QUANTITY_TREE_PVT.g_is_mat_status_used);
   else
   print_debug('  >>>>>>>>>  In create_tree. mode='||p_tree_mode||', grade='||p_grade_code||', rev_ctl=FALSE. mat_stat='||INV_QUANTITY_TREE_PVT.g_is_mat_status_used);
   end if;

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   g_is_pickrelease := nvl(inv_cache.is_pickrelease,FALSE);

   g_empty_root_index := NULL;
   g_hash_string := NULL;

   -- validate demand source info
   IF p_tree_mode IN (g_transaction_mode, g_loose_only_mode) THEN
      IF p_demand_source_type_id IS NULL THEN
         fnd_message.set_name('INV', 'INV-MISSING DEMAND SOURCE TYPE');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_demand_source_header_id IS NULL THEN
         IF p_demand_source_name IS NULL THEN
            fnd_message.set_name('INV', 'INV-MISSING DEMAND SRC HEADER');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF p_demand_source_header_id IS NULL
        AND p_demand_source_line_id IS NOT NULL THEN
         fnd_message.set_name('INV', 'INV-MISSING DEMAND SRC HEADER');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   -- Material Status : Need to know whether the item is lot_control : MANDATORY.
   -- Get Item Details:
   OPEN get_item_details(p_organization_id, p_inventory_item_id);
   FETCH get_item_details
    INTO l_grade_control
       , l_lot_control
       , l_DUOM_control
       , l_lot_status_enabled;

   print_debug('DUOM control='||l_DUOM_control);
   IF (get_item_details%NOTFOUND)
   THEN
      print_debug(' get_item_details NOTFOUND for org='||p_organization_id||', item='||p_inventory_item_id);
      CLOSE get_item_details;
      -- The item doesn't exist under this organization.
      FND_MESSAGE.SET_NAME('INV', 'ITEM_NOTFOUND');
      FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inventory_item_id);
      FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_organization_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- invConv comment : g_is_mat_status_used = 1 == Material Status is USED
   IF (inv_quantity_tree_pvt.g_is_mat_status_used = 1 AND l_lot_control = 2)
   THEN
      g_is_lot_control := TRUE;
   ELSE
      g_is_lot_control := FALSE;
   END IF;
   -- invConv note : the using of is_DUOM_control is made later in the procedure
   CLOSE get_item_details;

   IF (p_exclusive = g_exclusive) THEN
      lock_tree(
              p_api_version_number  => 1.0
            , p_init_msg_lst        => fnd_api.g_false
            , x_return_status       => l_return_status
            , x_msg_count           => x_msg_count
            , x_msg_data            => x_msg_data
            , p_organization_id     => p_organization_id
            , p_inventory_item_id   => p_inventory_item_id
            );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

   IF p_lot_expiration_date IS NOT NULL THEN
      l_lot_expiration_date := trunc(p_lot_expiration_date + 1) - 0.00001;
   END IF;

   -- find the rootinfo record
   l_rootinfo_index := find_rootinfo(
                     x_return_status           => l_return_status
                   , p_organization_id         => p_organization_id
                   , p_inventory_item_id       => p_inventory_item_id
                   , p_tree_mode               => p_tree_mode
                   , p_is_revision_control     => p_is_revision_control
                   , p_is_lot_control          => p_is_lot_control
                   , p_is_serial_control       => p_is_serial_control
                   , p_asset_sub_only          => p_asset_sub_only
                   , p_include_suggestion      => p_include_suggestion
                   , p_demand_source_type_id   => p_demand_source_type_id
                   , p_demand_source_header_id => p_demand_source_header_id
                   , p_demand_source_line_id   => p_demand_source_line_id
                   , p_demand_source_name      => p_demand_source_name
                   , p_demand_source_delivery  => p_demand_source_delivery
                   , p_lot_expiration_date     => l_lot_expiration_date
                   , p_onhand_source        => p_onhand_source
                   , p_pick_release         => p_pick_release
                   -- odab temp removed  , p_grade_code            => p_grade_code
                   );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;
   -- create the tree if the rootinfo can not be found
   IF (l_rootinfo_index = 0) THEN
      new_tree(
                 x_return_status           => l_return_status
               , p_organization_id         => p_organization_id
               , p_inventory_item_id       => p_inventory_item_id
               , p_tree_mode               => p_tree_mode
               , p_is_revision_control     => p_is_revision_control
               , p_is_lot_control          => p_is_lot_control
               , p_is_serial_control       => p_is_serial_control
               , p_asset_sub_only          => p_asset_sub_only
               , p_include_suggestion      => p_include_suggestion
               , p_demand_source_type_id   => p_demand_source_type_id
               , p_demand_source_header_id => p_demand_source_header_id
               , p_demand_source_line_id   => p_demand_source_line_id
               , p_demand_source_name      => p_demand_source_name
               , p_demand_source_delivery  => p_demand_source_delivery
               , p_lot_expiration_date     => l_lot_expiration_date
               , p_onhand_source           => p_onhand_source
               , p_pick_release            => p_pick_release
               , p_grade_code              => p_grade_code
               , x_tree_id                 => l_rootinfo_index
               );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   END IF;

   print_debug(' l_tree_id='||l_rootinfo_index||', l_rootinfo_index='||g_demand_info(l_rootinfo_index).root_id);
   l_tree_id := l_rootinfo_index;
   l_rootinfo_index := g_demand_info(l_tree_id).root_id;

   -- set the DUOM indicator
   IF (l_DUOM_control = 'P')
   THEN
      print_debug('DUOM control='||l_DUOM_control||', then FALSE');
      g_rootinfos(l_rootinfo_index).is_DUOM_control := FALSE;
   ELSE
      print_debug('DUOM control='||l_DUOM_control||', then TRUE');
      g_rootinfos(l_rootinfo_index).is_DUOM_control := TRUE;
   END IF;

   IF (l_lot_status_enabled = 'Y')
   THEN
      g_rootinfos(l_rootinfo_index).is_lot_status_enabled := TRUE;
   ELSE
      g_rootinfos(l_rootinfo_index).is_lot_status_enabled := FALSE;
   END IF;

   -- (re)build the tree if necessary
   IF (g_rootinfos(l_rootinfo_index).need_refresh) THEN
      --made change so that invalidated trees are rebuilt if
      -- create_tree is called for the same tree
      IF g_rootinfos(l_rootinfo_index).inventory_item_id IS NULL THEN
         g_rootinfos(l_rootinfo_index).inventory_item_id := p_inventory_item_id;
         g_rootinfos(l_rootinfo_index).organization_id := p_organization_id;
      END IF;
      build_tree(l_return_status, l_rootinfo_index);
      IF (l_return_status = fnd_api.g_ret_sts_error OR l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         -- if build_tree failed
         -- invalidate the rootinfo record and the index to the record
         invalidate_tree(l_rootinfo_index);
         l_tree_id := 0;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      End IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

   END IF;

   x_tree_id := l_tree_id;
   x_return_status := l_return_status;

   IF g_debug = 1 THEN
      print_tree(l_tree_id);
      print_debug(l_api_name || ' Exited with status = '||l_return_status,9);
      print_debug(' ',9);
   END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        print_debug(' CreateTree ending with g_exc_error.'||SQLERRM,9);
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        print_debug(' CreateTree ending with g_exc_unexpected_error.'||SQLERRM,9);
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        print_debug(' CreateTree ending with OTHERS.'||SQLERRM,9);
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END create_tree;

--Traverse
--  Used by prepare_reservation_quantities to
-- quickly traverse the trees and copy all the node information
-- into the tables to be later used for bulk insert.
-- For quantity calculations in reservations mode, the ATR of a node
-- is the smallest ATR for that node and all of that node's ancestors.
-- Instead of looking at every ancestor for every node to determine
-- ATR, this procedure takes advantage of its recursive, downward working
-- nature.  By taking in the ATR of the parent node, the procedure
-- no longer needs to look at every ancestor. It can just compare the
-- current node's value to that of its parent, which had already been
-- compared to its parent's ATR, and so on.
-- A parent node calls traverse only on its first child node. That child
-- will call traverse on each of its siblings, and also on its own children.

PROCEDURE traverse(
         p_node_index      INTEGER
       , p_parent_atr      NUMBER
       , p_parent_satr     NUMBER
   ) IS

   l_atr  NUMBER;
   l_satr NUMBER;
BEGIN
   IF p_node_index = 0 THEN
      return;
   END IF;
   -- ATR = min(current node's ATR, parent node's ATR)
   IF p_parent_atr IS NOT NULL AND p_parent_atr < g_nodes(p_node_index).atr THEN
     l_atr   := p_parent_atr;
      l_satr  := p_parent_satr;
   ELSE
      l_atr   := g_nodes(p_node_index).atr;
      l_satr  := g_nodes(p_node_index).satr;
   END IF;

   -- nodes with ATR <= 0 are not inserted into the table
   -- bug 1643186: We should insert records with ATR = 0
   --   if there is onhand qty
   -- bug 1990180 - we should always call traverse on the sibling nodes;
   --     before, we were only calling traverse on sibling node if
   --     qoh was greater than 0
   -- bug 2206138 - the onhand quantity should be the reservable quantity onhand
   print_debug('in traverse, ATR='||l_atr||', rqoh='||g_nodes(p_node_index).rqoh,9);
   print_debug(' node level='||g_nodes(p_node_index).node_level,9);
   IF g_nodes(p_node_index).is_reservable_sub
   THEN
      print_debug('in traverse, sub='||g_nodes(p_node_index).subinventory_code||', loct='||g_nodes(p_node_index).locator_id||', lot='||substr(g_nodes(p_node_index).lot_number,1,10)||', rsv=TRUE');
   ELSE
      print_debug('in traverse, sub='||g_nodes(p_node_index).subinventory_code||', loct='||g_nodes(p_node_index).locator_id||', lot='||substr(g_nodes(p_node_index).lot_number,1,10)||', rsv=FALSE');
   END IF;


   IF l_atr > 0 OR g_nodes(p_node_index).rqoh >0 THEN

      IF (g_nodes(p_node_index).is_reservable_sub = TRUE)
      THEN
         g_rsv_qty_counter := g_rsv_qty_counter +1;
         g_rsv_qty_revision(g_rsv_qty_counter)           := g_nodes(p_node_index).revision;
         g_rsv_qty_lot_number(g_rsv_qty_counter)         := g_nodes(p_node_index).lot_number;
         g_rsv_qty_subinventory_code(g_rsv_qty_counter)  := g_nodes(p_node_index).subinventory_code;
         g_rsv_qty_locator_id(g_rsv_qty_counter)         := g_nodes(p_node_index).locator_id;
         g_rsv_qty_cost_group_id(g_rsv_qty_counter)      := g_nodes(p_node_index).cost_group_id;
         g_rsv_qty_lpn_id(g_rsv_qty_counter)             := g_nodes(p_node_index).lpn_id;
         g_rsv_qty_node_level(g_rsv_qty_counter)         := g_nodes(p_node_index).node_level;
         g_rsv_qty_qoh(g_rsv_qty_counter)                := g_nodes(p_node_index).rqoh;
         g_rsv_qty_sqoh(g_rsv_qty_counter)               := g_nodes(p_node_index).srqoh;
         g_rsv_qty_atr(g_rsv_qty_counter)                := l_atr;
         g_rsv_qty_satr(g_rsv_qty_counter)               := l_satr;
         -- invConv change : note that grade_code is hold under rootinfo
      END IF;

      -- call traverse on children
      -- invConv change : added 3rd parameter
      traverse (g_nodes(p_node_index).first_child_index, l_atr, l_satr);
   END IF;

   --call traverse on siblings
   -- invConv change : added 3rd parameter
   traverse (g_nodes(p_node_index).next_sibling_index, p_parent_atr, p_parent_satr);

END traverse;


-- Procedure
--   prepare_reservation_quantities
-- Description
--      This procedure is called from the reservation form to
-- initialize the table used for the LOVs in that form.
--
-- This procedure inserts one record for every node in the tree
-- which has ATR > 0.  The table mtl_rsv_quantities_temp
-- is a session specific global temp table which serves as the
-- basis for the LOVs in the Reservations form.
--
PROCEDURE prepare_reservation_quantities(
     x_return_status        OUT NOCOPY VARCHAR2
   , p_tree_id              IN  NUMBER
)
IS

   l_root_id      INTEGER;
   l_item_node    INTEGER;
   i              INTEGER;
   l_grade_code   VARCHAR2(150) := NULL;

   CURSOR Get_Grade_From_Lot( org_id  IN NUMBER
                            , item_id IN NUMBER
                            , lot     IN VARCHAR2) IS
      SELECT grade_code
      FROM mtl_lot_numbers
      WHERE organization_id = org_id
      AND inventory_item_id = item_id
      AND lot_number = lot;

   l_api_name             CONSTANT VARCHAR2(60) := 'PREPARE_RESERVATION_QUANTITIES';
   -- Bug 8593965
   l_prev_lot_number       VARCHAR2(80);
   l_prev_grade_code       VARCHAR2(150);
BEGIN

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   -- clear out temp table
   DELETE FROM MTL_RSV_QUANTITIES_TEMP;

   -- find root node
   l_root_id := g_demand_info(p_tree_id).root_id;

   -- find appropriate child node
   l_item_node := g_rootinfos(l_root_id).item_node_index;

   -- initialize table for bulk insert
   g_rsv_qty_node_level.delete;
   g_rsv_qty_revision.delete;
   g_rsv_qty_lot_number.delete;
   g_rsv_qty_subinventory_code.delete;
   g_rsv_qty_locator_id.delete;
   g_rsv_qty_cost_group_id.delete;
   g_rsv_qty_lpn_id.delete;
   g_rsv_qty_qoh.delete;
   g_rsv_qty_atr.delete;
   g_rsv_qty_sqoh.delete;
   g_rsv_qty_satr.delete;
   g_rsv_qty_counter := 0;
   -- call recursive function on current node
   -- invConv change : added 3rd parameter
   traverse(l_item_node, NULL, NULL);

   -- Bug 8593965: Using bulk insert to test the performance
   if g_debug = 1 then
      print_debug('insert into mtl_rsv_quantities_temp, item='||g_rootinfos(l_root_id).inventory_item_id);
   end if;

   l_prev_lot_number := '@@@@';
   l_prev_grade_code := '@@@@';

   FOR i in 1..g_rsv_qty_counter
   LOOP
      IF (g_rsv_qty_lot_number(i) IS NOT NULL) THEN
        IF (l_prev_lot_number <> g_rsv_qty_lot_number(i) ) then
          OPEN Get_Grade_From_Lot( g_rootinfos(l_root_id).organization_id
                                , g_rootinfos(l_root_id).inventory_item_id
                                , g_rsv_qty_lot_number(i));
          FETCH Get_Grade_From_Lot
          -- Bug 8498256, Commented the below line as we can not keep overwriting
          -- the global variable which is used later in the build_tree procedure */
          -- INTO g_rootinfos(l_root_id).grade_code;
          INTO g_rsv_qty_grade_code(i); --l_grade_code;

          l_prev_grade_code := g_rsv_qty_grade_code(i);
           l_prev_lot_number := g_rsv_qty_lot_number(i);
          CLOSE Get_Grade_From_Lot;
        ELSE
          g_rsv_qty_grade_code(i) := l_prev_grade_code;
        END IF;
      ELSE
        g_rsv_qty_grade_code(i) := NULL;
      END IF;
   END LOOP;

   --insert into table
   FORALL i in 1..g_rsv_qty_counter
     INSERT INTO MTL_RSV_QUANTITIES_TEMP (
          organization_id
         ,inventory_item_id
         ,node_level
         ,revision
         ,lot_number
         ,subinventory_code
         ,locator_id
         ,grade_code
         ,cost_group_id
         ,lpn_id
         ,qoh
         ,atr
         ,sqoh
         ,satr
   ) VALUES (
          g_rootinfos(l_root_id).organization_id
         ,g_rootinfos(l_root_id).inventory_item_id
         ,g_rsv_qty_node_level(i)
         ,g_rsv_qty_revision(i)
         ,g_rsv_qty_lot_number(i)
         ,g_rsv_qty_subinventory_code(i)
         ,g_rsv_qty_locator_id(i)
         ,g_rsv_qty_grade_code(i) -- l_grade_code   --g_rootinfos(l_root_id).grade_code
         ,g_rsv_qty_cost_group_id(i)
         ,g_rsv_qty_lpn_id(i)
         ,g_rsv_qty_qoh(i)
         ,g_rsv_qty_atr(i)
         ,g_rsv_qty_sqoh(i)
         ,g_rsv_qty_satr(i)
   );
   --END LOOP;

   -- return status
   x_return_status := fnd_api.g_ret_sts_success;
   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Exited with status = '||x_return_status,9);
      print_debug(' ',9);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if g_debug = 1 then
        print_debug('prepare_rsv_qty error msg: '||SQLERRM,9);
      end if;
END prepare_reservation_quantities;

-- Get_Total_QOH
--   This API returns the TQOH, or total quantity on hand.
--   This value reflects any negative balances for this
--   item in the organization.  The Total QOH is the minimum
--   of the current node's QOH and all ancestor nodes' QOH.
--   For example,
--   Consider 2 locators in the EACH subinventory:
--   E.1.1 has 10 onhand
--   E.1.2 has -20 onhand
--   Thus, the subinventory Each has -10 onhand.
--
--   Where calling query_tree, qoh for E.1.1 = 10.
--   However, when calling get_total_qoh, the TQOH
--   for E.1.1 = -10, reflecting the value at the subinventory level.
--
--   This procedure is used by the inventory transaction forms.

PROCEDURE get_total_qoh
   (  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  p_cost_group_id        IN  NUMBER
   ,  x_tqoh                 OUT NOCOPY NUMBER
   ,  p_lpn_id               IN  NUMBER
   ) IS

l_stqoh NUMBER;

BEGIN

inv_quantity_tree_pvt.get_total_qoh
           ( x_return_status     => x_return_status
           , x_msg_count         => x_msg_count
           , x_msg_data          => x_msg_data
           , p_tree_id           => p_tree_id
           , p_revision          => p_revision
           , p_lot_number        => p_lot_number
           , p_subinventory_code => p_subinventory_code
           , p_locator_id        => p_locator_id
           , p_cost_group_id     => p_cost_group_id
           , x_tqoh              => x_tqoh
           , x_stqoh             => l_stqoh
           , p_lpn_id            => p_lpn_id) ;

END get_total_qoh;

PROCEDURE get_total_qoh
   (  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  p_cost_group_id        IN  NUMBER
   ,  x_tqoh                 OUT NOCOPY NUMBER
   ,  x_stqoh                OUT NOCOPY NUMBER
   ,  p_lpn_id               IN  NUMBER
   ) IS

   l_found BOOLEAN;
   l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_node_index NUMBER;
   l_tqoh NUMBER;
   l_stqoh NUMBER;
   l_loop_index NUMBER;
   l_root_id NUMBER;
   l_is_reservable_sub BOOLEAN;
   l_lpn_id NUMBER;
   l_sub_index NUMBER := NULL;
   l_api_name VARCHAR2(30) := 'GET_TOTAL_QOH';

BEGIN

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   l_root_id := g_demand_info(p_tree_id).root_id;
   print_debug(' in get_total_qoh, tree='||p_tree_id||', root_id='||l_root_id);
   print_debug(' ... org_id='||g_rootinfos(l_root_id).organization_id||', item_id='||g_rootinfos(l_root_id).inventory_item_id||'.');
   print_debug(' ... lot='||substr(p_lot_number,1,10)||', subInv='||p_subinventory_code||', loct='||p_locator_id||'.');

   -- find the node indicated by the parameters
   l_found := find_tree_node(
                      x_return_status      => l_return_status
                    , p_tree_id            => l_root_id
                    , p_revision           => p_revision
                    , p_lot_number         => p_lot_number
                    , p_subinventory_code  => p_subinventory_code
                    , p_is_reservable_sub  => NULL
                    , p_locator_id         => p_locator_id
                    , x_node_index         => l_node_index
                    , p_cost_group_id      => p_cost_group_id
                    , p_lpn_id             => p_lpn_id
                    );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;


   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;


   IF l_found = FALSE THEN
      fnd_message.set_name('INV','INV-Cannot find node');
      fnd_message.set_token('ROUTINE', 'Find_Tree_Node');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   print_debug('get_total_qoh: node found... node_index='||l_node_index||' level='||g_nodes(l_node_index).node_level||'<>'||g_item_level);

   --Bug 3943215.
   --   The logic added here is synchronous with computation logic of runtine att in query_tree.
   --   The value returned by this procedure is compared to the runtime att in INVMTXFH.pld

   /*********************************************************************
   * Logic for finding TQOH:
   *
   * If Node is at Sub level or below
   *    Get reservable for Sub
   *    If Sub is not reservable
   *       TQOH = QOH of node;
   *    else
   *       TQOH = min(QOH of node, RQOH of ancestor nodes)
   * Else (node above sub level)
   *    TQOH = min(QOH of node, QOH of ancestor nodes)
   *********************************************************************/

   IF g_nodes(l_node_index).node_level IN (g_sub_level, g_locator_level,g_lpn_level, g_cost_group_level)
     AND (p_subinventory_code IS NOT NULL) THEN

      l_sub_index := get_ancestor_sub(l_node_index);
      l_is_reservable_sub := g_nodes(l_sub_index).is_reservable_sub;

      IF NOT l_is_reservable_sub THEN
         l_tqoh :=  g_nodes(l_node_index).qoh;
         l_stqoh :=  g_nodes(l_node_index).sqoh;
      ELSE
         -- loop through all ancestors, setting l_tqoh to the minimum rqoh
         l_tqoh := g_nodes(l_node_index).qoh;
         l_stqoh :=  g_nodes(l_node_index).sqoh;
         IF g_nodes(l_node_index).node_level <> g_item_level THEN
            l_loop_index := g_nodes(l_node_index).parent_index;
            LOOP
               IF l_tqoh > g_nodes(l_loop_index).rqoh Then
                  l_tqoh := g_nodes(l_loop_index).rqoh;
                  l_stqoh := g_nodes(l_loop_index).srqoh;
               END IF;
               EXIT WHEN g_nodes(l_loop_index).node_level = g_item_level;
               l_loop_index :=  g_nodes(l_loop_index).parent_index;
            END LOOP;
         END IF;
      END IF;
   ELSE
      --org, item or lot level
      l_tqoh := g_nodes(l_node_index).qoh;
      l_stqoh := g_nodes(l_node_index).sqoh;
      IF g_nodes(l_node_index).node_level <> g_item_level THEN
         l_loop_index := g_nodes(l_node_index).parent_index;
         LOOP
            IF l_tqoh > g_nodes(l_loop_index).qoh Then
               l_tqoh := g_nodes(l_loop_index).qoh;
               l_stqoh := g_nodes(l_node_index).sqoh;
            END IF;
            EXIT WHEN g_nodes(l_loop_index).node_level = g_item_level;
            l_loop_index :=  g_nodes(l_loop_index).parent_index;
         END LOOP;
      END IF;
   END IF;

   x_tqoh  := l_tqoh;

   -- check whether the item is DUOM
   IF (g_rootinfos(l_root_id).is_DUOM_control = FALSE)
   THEN
      print_debug(' root_id='||l_root_id||', tree_id='||p_tree_id||', DUOM_control=FALSE tqoh='||x_tqoh);
      x_stqoh := NULL;
   ELSE
      print_debug(' root_id='||l_root_id||', tree_id='||p_tree_id||', DUOM_control=TRUE tqoh='||x_tqoh||', stqoh='||l_stqoh);
      x_stqoh := l_stqoh;
   END IF;

   x_return_status := l_return_status;

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Exited with status = '||l_return_status||' tqoh='||l_tqoh,9);
      print_debug(' ',9);
   END IF;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
         ( p_count => x_msg_count
         , p_data  => x_msg_data);

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
         ( p_count  => x_msg_count
         , p_data   => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;


      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           ( g_pkg_name
           , 'get_total_qoh');
      END IF;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data);
END get_total_qoh;

--
-- Procedure
--   do_check_pvt
-- Description
--   Check quantity violation for a given base tree
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--   p_tree_id                 tree id
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--   x_no_violation            true if no violation, false otherwise
--
PROCEDURE do_check_pvt
  (    p_api_version_number  IN  NUMBER
     , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status       OUT NOCOPY VARCHAR2
     , x_msg_count           OUT NOCOPY NUMBER
     , x_msg_data            OUT NOCOPY VARCHAR2
     , p_tree_id             IN  INTEGER
     , x_no_violation        OUT NOCOPY BOOLEAN
     ) IS
   l_api_version_number    CONSTANT NUMBER       := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'Do_Check_Pvt';
   l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_no_violation          BOOLEAN;
BEGIN
  print_debug('Entering do_check_pvt. tree_id='||p_tree_id);

  --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- check if tree id is valid
   IF is_tree_valid(p_tree_id) = FALSE THEN
      fnd_message.set_name('INV', 'INV-Qtyroot not found');
      fnd_message.set_token('ROUTINE', 'Do_Check');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;


   zero_tree_node(l_return_status, g_rootinfos(p_tree_id).item_node_index);
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   --lock the tree - do_check must acquire tree lock before building tree
   print_debug('in do_check_pvt, calling lock_tree ');
   lock_tree(
              p_api_version_number  => 1.0
            , p_init_msg_lst        => fnd_api.g_false
            , x_return_status       => l_return_status
            , x_msg_count           => x_msg_count
            , x_msg_data            => x_msg_data
       , p_organization_id     => g_rootinfos(p_tree_id).organization_id
       , p_inventory_item_id   => g_rootinfos(p_tree_id).inventory_item_id
     );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   print_debug('in do_check_pvt, calling build_tree for tree_id='||p_tree_id);
   build_tree(l_return_status, p_tree_id);
   print_debug('in do_check_pvt, after build_tree... return='||l_return_status);
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   if g_rootinfos(p_tree_id).neg_inv_allowed
   then
      print_debug('in do_check_pvt, calling check_node_violation for item_node_index='||g_rootinfos(p_tree_id).item_node_index
         ||', tree_mode='||g_rootinfos(p_tree_id).tree_mode||', neg_inv_allowed=TRUE');
   else
      print_debug('in do_check_pvt, calling check_node_violation for item_node_index='||g_rootinfos(p_tree_id).item_node_index
         ||', tree_mode='||g_rootinfos(p_tree_id).tree_mode||', neg_inv_allowed=FALSE');
   end if;

   l_no_violation :=check_node_violation(
       x_return_status     => l_return_status
      , p_node_index       => g_rootinfos(p_tree_id).item_node_index
      , p_tree_mode        => g_rootinfos(p_tree_id).tree_mode
      , p_negative_allowed => g_rootinfos(p_tree_id).neg_inv_allowed
      , p_item_node_index  => g_rootinfos(p_tree_id).item_node_index
      );

   print_debug('in do_check_pvt, after check_node_violation... return='||l_return_status);
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_no_violation := l_no_violation;
   x_return_status := l_return_status;

   print_debug('Normal end of do_check_pvt');
EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END do_check_pvt;


--
-- Procedure
--   do_check
-- Description
--   Check quantity violation
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--   x_no_violation            true if no violation, false otherwise
--
PROCEDURE do_check
  (    p_api_version_number  IN  NUMBER
     , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status       OUT NOCOPY VARCHAR2
     , x_msg_count           OUT NOCOPY NUMBER
     , x_msg_data            OUT NOCOPY VARCHAR2
     , p_tree_id             IN  INTEGER
     , x_no_violation        OUT NOCOPY BOOLEAN
     ) IS
   l_api_version_number    CONSTANT NUMBER       := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'DO_CHECK';
   l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_no_violation          BOOLEAN;
   l_root_id         INTEGER;
BEGIN
   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   print_debug('Entering do_check, tree_id='||p_tree_id, 9);

  --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   --call do_check on the base tree
   l_root_id := g_demand_info(p_tree_id).root_id;

   do_check_pvt(
              p_api_version_number  => 1.0
            , p_init_msg_lst        => fnd_api.g_false
            , x_return_status       => l_return_status
            , x_msg_count           => x_msg_count
            , x_msg_data            => x_msg_data
            , p_tree_id             => l_root_id
            , x_no_violation        => l_no_violation
            );
   print_debug('In do_check, after do_check_pvt, return='||l_return_status);
   IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Bug 7340567, printing the tree to verify node violation
   print_tree(p_tree_id);

   x_no_violation := l_no_violation;
   x_return_status := l_return_status;

   IF g_debug = 1 THEN
     if l_no_violation then
       print_debug(l_api_name || ' Exited with no violation detected',9);
     else
       print_debug(l_api_name || ' Exited with violation detected',9);
     end if;
     print_debug(' ',9);
   END IF;
EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END do_check;


--
-- Procedure
--   do_check
-- Description
--   Check quantity violation
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--   x_no_violation            true if no violation, false otherwise
--
PROCEDURE do_check
  (    p_api_version_number  IN  NUMBER
     , p_init_msg_lst        IN  VARCHAR2
     , x_return_status       OUT NOCOPY VARCHAR2
     , x_msg_count           OUT NOCOPY NUMBER
     , x_msg_data            OUT NOCOPY VARCHAR2
     , x_no_violation        OUT NOCOPY BOOLEAN
     ) IS
   l_api_version_number    CONSTANT NUMBER       := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'DO_CHECK_ALL';
   l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_no_violation          BOOLEAN;
   l_root_id         NUMBER;
   l_org_id       NUMBER;
   l_item_id         NUMBER;
   l_lot_ctrl        NUMBER;
   l_line_id         NUMBER;
   l_root_id_tmp           NUMBER;

   CURSOR C1 is
   SELECT root_id
   FROM   mtl_do_check_temp
   ORDER BY organization_id, inventory_item_id;
BEGIN

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   for l_loop_index IN 1..g_all_roots_counter LOOP
      l_root_id := g_all_roots(l_loop_index).root_id;
      l_org_id := g_rootinfos(l_root_id).organization_id;
      l_item_id := g_rootinfos(l_root_id).inventory_item_id;
      if (g_rootinfos(l_root_id).is_lot_control) THEN
         l_lot_ctrl := 2;
      else
         l_lot_ctrl := 1;
      end if;
      l_line_id := g_rootinfos(l_root_id).demand_source_line_id;

      --Now insert into temp table;
      insert into mtl_do_check_temp
         (   ROOT_ID
            ,ORGANIZATION_ID
            ,INVENTORY_ITEM_ID
            ,LOT_CONTROL
            ,LINE_ID)
         values
         (   l_root_id
            ,l_org_id
            ,l_item_id
            ,l_lot_ctrl
            ,l_line_id);
   end loop;

   open c1;
   loop
      fetch c1 into l_root_id_tmp;
      EXIT WHEN c1%NOTFOUND;

      IF is_tree_valid(l_root_id_tmp) THEN
         do_check_pvt( p_api_version_number  => 1.0
                      ,p_init_msg_lst        => fnd_api.g_false
                      ,x_return_status       => l_return_status
                      ,x_msg_count           => x_msg_count
                      ,x_msg_data            => x_msg_data
                      ,p_tree_id             => l_root_id_tmp
                      ,x_no_violation        => l_no_violation);
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF ;

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF l_no_violation = FALSE THEN
            --utl_debug1('do_check_pvt returns false to do_check');
            EXIT;
         END IF;
      END IF;
   END LOOP;

   x_no_violation := l_no_violation;
   x_return_status := l_return_status;

   IF g_debug = 1 THEN
     IF l_no_violation THEN
       print_debug(l_api_name || ' Exited with no violation detected',9);
     ELSE
       print_debug(l_api_name || ' Exited with violation detected',9);
     END IF;
     print_debug(' ',9);
   END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END do_check;

--
-- Procedure
--   free_tree_pvt
-- Description
--   free the tree when it is no longer needed
--   This takes the base tree id
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--   p_tree_id                 tree id
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--
PROCEDURE free_tree_pvt
  (    p_api_version_number  IN  NUMBER
     , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status       OUT NOCOPY VARCHAR2
     , x_msg_count           OUT NOCOPY NUMBER
     , x_msg_data            OUT NOCOPY VARCHAR2
     , p_tree_id             IN  INTEGER
     ) IS
   l_api_version_number    CONSTANT NUMBER       := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'Free_Tree_Pvt';
   l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
BEGIN

  --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;
   invalidate_tree(p_tree_id);

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

    WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END free_tree_pvt;


--
-- Procedure
--   free_tree
-- Description
--   free all the trees
--   This takes the demand info id
--     (tree_id returned by create_tree)
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--
PROCEDURE free_tree
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   , p_tree_id             IN  INTEGER
   )
IS

   l_api_version_number    CONSTANT NUMBER       := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'FREE_TREE';
   l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_root_id               INTEGER;

BEGIN

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   --call free_tree on base_tree
   l_root_id := g_demand_info(p_tree_id).root_id;

   free_tree_pvt(
            p_api_version_number => l_api_version_number
          , p_init_msg_lst       => fnd_api.g_false
          , x_return_status      => l_return_status
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          , p_tree_id            => l_root_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;


   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

    WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END free_tree;


--
-- Procedure
--   free_all
-- Description
--   free all the trees
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--
PROCEDURE free_all
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   )
IS

   l_api_version_number    CONSTANT NUMBER       := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'Free_All';
   l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_root_id         NUMBER;

BEGIN

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   FOR l_loop_index IN 1..g_all_roots_counter LOOP
      l_root_id := g_all_roots(l_loop_index).root_id;
      free_tree_pvt(
           p_api_version_number => l_api_version_number
          ,p_init_msg_lst      => fnd_api.g_false
          ,x_return_status => l_return_status
     ,x_msg_count    => x_msg_count
          ,x_msg_data      => x_msg_data
          ,p_tree_id    => l_root_id
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      End IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      End IF;

  END LOOP;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END free_all;

--
-- Procedure
--   mark_all_for_refresh
-- Description
--   marks all existing trees as needing to be rebuilt. Unlike
--   free_tree and clear_quantity_cache, no quantity trees are deleted.
--
--   This API is needed so that the do_check_for_commit procedure in
--   INVRSV3B.pls will still work.  That procedure stores tree_ids in a
--   temp table. When clear_quantity_cache is called, these tree_ids are
--   no longer valid. When this is called instead of clear_quantity_cache,
--   the tree_ids are still valid to be passed to do_check.
--
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--
PROCEDURE mark_all_for_refresh
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   ) IS

   l_api_version_number    CONSTANT NUMBER       := 1.0;
   l_api_name              CONSTANT VARCHAR2(30) := 'Mark_All_For_Refresh';
   l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_root_id               NUMBER;

BEGIN

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   FOR l_loop_index IN 1..g_all_roots_counter LOOP
      l_root_id := g_all_roots(l_loop_index).root_id;
      If is_tree_valid(l_root_id) THEN
        g_rootinfos(l_root_id).need_refresh := TRUE;
      End If;
   END LOOP;


EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END mark_all_for_refresh;

-- Procedure
--   update_quantities
-- Description
--   Create a quantity tree
--
--  Version
--   Current version        1.0
--   Initial version        1.0
--
-- Input parameters:
--   p_api_version_number   standard input parameter
--   p_init_msg_lst         standard input parameter
--   p_tree_id              tree_id
--   p_revision             revision
--   p_lot_number           lot_number
--   p_subinventory_code    subinventory_code
--   p_locator_id           locator_id
--   p_primary_quantity     primary_quantity
--   p_quantity_type
--
-- Output parameters:
--   x_return_status       standard output parameter
--   x_msg_count           standard output parameter
--   x_msg_data            standard output parameter
--   x_tree_id             used later to refer to the same tree
--   x_qoh                 qoh   after the update
--   x_rqoh                rqoh  after the update
--   x_qr                  qr    after the update
--   x_qs                  qs    after the update
--   x_att                 att   after the update
--   x_atr                 atr   after the update
PROCEDURE update_quantities
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2
   , p_lot_number            IN  VARCHAR2
   , p_subinventory_code     IN  VARCHAR2
   , p_locator_id            IN  NUMBER
   , p_primary_quantity      IN  NUMBER
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2
   , p_cost_group_id         IN  NUMBER
   , p_containerized         IN  NUMBER
   , p_lpn_id                IN  NUMBER
   , p_transfer_locator_id   IN  NUMBER
     ) IS

l_secondary_quantity  NUMBER;
l_sqoh    NUMBER;
l_srqoh   NUMBER;
l_sqr     NUMBER;
l_sqs     NUMBER;
l_satt    NUMBER;
l_satr    NUMBER;
BEGIN

inv_quantity_tree_pvt.update_quantities
  (  p_api_version_number    => p_api_version_number
   , p_init_msg_lst          => p_init_msg_lst
   , x_return_status         => x_return_status
   , x_msg_count             => x_msg_count
   , x_msg_data              => x_msg_data
   , p_tree_id               => p_tree_id
   , p_revision              => p_revision
   , p_lot_number            => p_lot_number
   , p_subinventory_code     => p_subinventory_code
   , p_locator_id            => p_locator_id
   , p_primary_quantity      => p_primary_quantity
   , p_secondary_quantity    => l_secondary_quantity
   , p_quantity_type         => p_quantity_type
   , x_qoh                   => x_qoh
   , x_rqoh                  => x_rqoh
   , x_qr                    => x_qr
   , x_qs                    => x_qs
   , x_att                   => x_att
   , x_atr                   => x_atr
   , x_sqoh                  => l_sqoh
   , x_srqoh                 => l_srqoh
   , x_sqr                   => l_sqr
   , x_sqs                   => l_sqs
   , x_satt                  => l_satt
   , x_satr                  => l_satr
   , p_transfer_subinventory_code => p_transfer_subinventory_code
   , p_cost_group_id         => p_cost_group_id
   , p_containerized         => p_containerized
   , p_lpn_id                => p_lpn_id
   , p_transfer_locator_id   => p_transfer_locator_id);

END update_quantities;

PROCEDURE update_quantities
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2
   , p_lot_number            IN  VARCHAR2
   , p_subinventory_code     IN  VARCHAR2
   , p_locator_id            IN  NUMBER
   , p_primary_quantity      IN  NUMBER
   , p_secondary_quantity    IN  NUMBER
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , x_sqoh                  OUT NOCOPY NUMBER
   , x_srqoh                 OUT NOCOPY NUMBER
   , x_sqr                   OUT NOCOPY NUMBER
   , x_sqs                   OUT NOCOPY NUMBER
   , x_satt                  OUT NOCOPY NUMBER
   , x_satr                  OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2
   , p_cost_group_id         IN  NUMBER
   , p_containerized         IN  NUMBER
   , p_lpn_id                IN  NUMBER
   , p_transfer_locator_id   IN  NUMBER
     ) IS
      l_api_version_number   CONSTANT NUMBER       := 1.0;
      l_api_name             CONSTANT VARCHAR2(30) := 'UPDATE_QUANTITIES';
      l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_root_id        INTEGER;
BEGIN
   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   print_debug('Entering update_quantities. primQty='||p_primary_quantity||', secQty='||p_secondary_quantity);

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_root_id := g_demand_info(p_tree_id).root_id;
   -- check if tree id is valid
   IF is_tree_valid(l_root_id) = FALSE THEN
      fnd_message.set_name('INV', 'INV-Qtyroot not found');
      fnd_message.set_token('ROUTINE', 'Update_Quantities');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   print_debug('in update_quantities, calling add_quantities qty1='||p_primary_quantity||', qty2='||p_secondary_quantity||'.');
   add_quantities(
        x_return_status     => l_return_status
      , p_tree_id           => l_root_id
      , p_revision          => p_revision
      , p_lot_number        => p_lot_number
      , p_subinventory_code => p_subinventory_code
      , p_is_reservable_sub => NULL
      , p_locator_id        => p_locator_id
      , p_primary_quantity  => p_primary_quantity
      , p_secondary_quantity=> p_secondary_quantity
      , p_quantity_type     => p_quantity_type
      , p_set_check_mark    => TRUE
      , p_cost_group_id     => p_cost_group_id
      , p_lpn_id            => p_lpn_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   -- query the quantities after the update
   query_tree
     (
        p_api_version_number => 1.0
      , p_init_msg_lst       => fnd_api.g_false
      , x_return_status      => l_return_status
      , x_msg_count          => x_msg_count
      , x_msg_data           => x_msg_data
      , p_tree_id            => p_tree_id
      , p_revision           => p_revision
      , p_lot_number         => p_lot_number
      , p_subinventory_code  => p_subinventory_code
      , p_locator_id         => p_locator_id
      , x_qoh                => x_qoh
      , x_rqoh               => x_rqoh
      , x_qr                 => x_qr
      , x_qs                 => x_qs
      , x_att                => x_att
      , x_atr                => x_atr
      , x_sqoh               => x_sqoh
      , x_srqoh              => x_srqoh
      , x_sqr                => x_sqr
      , x_sqs                => x_sqs
      , x_satt               => x_satt
      , x_satr               => x_satr
      , p_transfer_subinventory_code => p_transfer_subinventory_code
      , p_cost_group_id      => p_cost_group_id
      , p_lpn_id             => p_lpn_id
      , p_transfer_locator_id => p_transfer_locator_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   x_return_status := l_return_status;

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Exited with status = '||l_return_status,9);
      print_debug(' ',9);
   END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END update_quantities;


-- Bug 2486318. The do check does not work. Trasactions get committed
-- even if there is a node violation. Added p_check_mark_node_only to mark
-- the nodes. A new procedure update quantities for form was added and
-- called from inldqc.ppc

--
-- Procedure
--   update_quantities_for_form
-- Description
--   Create a quantity tree
--
--  Version
--   Current version        1.0
--   Initial version        1.0
--
-- Input parameters:
--   p_api_version_number   standard input parameter
--   p_init_msg_lst         standard input parameter
--   p_tree_id              tree_id
--   p_revision             revision
--   p_lot_number           lot_number
--   p_subinventory_code    subinventory_code
--   p_locator_id           locator_id
--   p_primary_quantity     primary_quantity
--   p_quantity_type
--   p_call_for_form        to check if the call is from form
--
-- Output parameters:
--   x_return_status       standard output parameter
--   x_msg_count           standard output parameter
--   x_msg_data            standard output parameter
--   x_tree_id             used later to refer to the same tree
--   x_qoh                 qoh   after the update
--   x_rqoh                rqoh  after the update
--   x_qr                  qr    after the update
--   x_qs                  qs    after the update
--   x_att                 att   after the update
--   x_atr                 atr   after the update
PROCEDURE update_quantities_for_form
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2
   , p_lot_number            IN  VARCHAR2
   , p_subinventory_code     IN  VARCHAR2
   , p_locator_id            IN  NUMBER
   , p_primary_quantity      IN  NUMBER
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN VARCHAR2
   , p_cost_group_id         IN  NUMBER
   , p_containerized         IN  NUMBER
   , p_call_for_form         IN  VARCHAR2
   , p_lpn_id                IN NUMBER DEFAULT NULL  --added for bug7038890
     ) IS

l_secondary_quantity  NUMBER := NULL;
l_sqoh    NUMBER;
l_srqoh   NUMBER;
l_sqr     NUMBER;
l_sqs     NUMBER;
l_satt    NUMBER;
l_satr    NUMBER;

BEGIN

inv_quantity_tree_pvt.update_quantities_for_form
  (  p_api_version_number    => p_api_version_number
   , p_init_msg_lst          => p_init_msg_lst
   , x_return_status         => x_return_status
   , x_msg_count             => x_msg_count
   , x_msg_data              => x_msg_data
   , p_tree_id               => p_tree_id
   , p_revision              => p_revision
   , p_lot_number            => p_lot_number
   , p_subinventory_code     => p_subinventory_code
   , p_locator_id            => p_locator_id
   , p_primary_quantity      => p_primary_quantity
   , p_secondary_quantity    => l_secondary_quantity
   , p_quantity_type         => p_quantity_type
   , x_qoh                   => x_qoh
   , x_rqoh                  => x_rqoh
   , x_qr                    => x_qr
   , x_qs                    => x_qs
   , x_att                   => x_att
   , x_atr                   => x_atr
   , x_sqoh                  => l_sqoh
   , x_srqoh                 => l_srqoh
   , x_sqr                   => l_sqr
   , x_sqs                   => l_sqs
   , x_satt                  => l_satt
   , x_satr                  => l_satr
   , p_transfer_subinventory_code => p_transfer_subinventory_code
   , p_cost_group_id         => p_cost_group_id
   , p_containerized         => p_containerized
   , p_call_for_form         => p_call_for_form
   , p_lpn_id                => p_lpn_id); --added for bug7038890


END update_quantities_for_form;

PROCEDURE update_quantities_for_form
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2
   , p_lot_number            IN  VARCHAR2
   , p_subinventory_code     IN  VARCHAR2
   , p_locator_id            IN  NUMBER
   , p_primary_quantity      IN  NUMBER
   , p_secondary_quantity    IN  NUMBER
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , x_sqoh                  OUT NOCOPY NUMBER
   , x_srqoh                 OUT NOCOPY NUMBER
   , x_sqr                   OUT NOCOPY NUMBER
   , x_sqs                   OUT NOCOPY NUMBER
   , x_satt                  OUT NOCOPY NUMBER
   , x_satr                  OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN VARCHAR2
   , p_cost_group_id         IN  NUMBER
   , p_containerized         IN  NUMBER
   , p_call_for_form         IN  VARCHAR2
   , p_lpn_id               IN NUMBER DEFAULT NULL  --added for bug7038890
     ) IS
      l_api_version_number   CONSTANT NUMBER       := 1.0;
      l_api_name             CONSTANT VARCHAR2(30) := 'UPDATE_QUANTITIES_FOR_FORM';
      l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_root_id        INTEGER;
      l_is_for_form         BOOLEAN;
BEGIN

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_root_id := g_demand_info(p_tree_id).root_id;

   -- check if tree id is valid
   IF is_tree_valid(l_root_id) = FALSE THEN
      fnd_message.set_name('INV', 'INV-Qtyroot not found');
      fnd_message.set_token('ROUTINE', 'Update_Quantities');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF p_call_for_form = fnd_api.g_true THEN
      l_is_for_form := FALSE;
   ELSE
      l_is_for_form := TRUE;
   END IF;

   print_debug('Before calling add_quantities. qty1='||p_primary_quantity||', qty2='||p_secondary_quantity||', qtyType='||p_quantity_type);
   add_quantities(
        x_return_status     => l_return_status
      , p_tree_id           => l_root_id
      , p_revision          => p_revision
      , p_lot_number        => p_lot_number
      , p_subinventory_code => p_subinventory_code
      , p_is_reservable_sub => NULL
      , p_locator_id        => p_locator_id
      , p_primary_quantity  => p_primary_quantity
      , p_secondary_quantity=> p_secondary_quantity
      , p_quantity_type     => p_quantity_type
      , p_set_check_mark    => l_is_for_form
      , p_cost_group_id     => p_cost_group_id
      , p_lpn_id     => p_lpn_id                  --replaced null value with p_lpn_id bug7038890
      , p_check_mark_node_only     => fnd_api.g_true
      );
      print_debug('After calling add_quantities. return_status='||l_return_status);

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;
   print_debug('Before calling Query_Tree');
   -- query the quantities after the update
   query_tree(
        p_api_version_number => 1.0
      , p_init_msg_lst       => fnd_api.g_false
      , x_return_status      => l_return_status
      , x_msg_count          => x_msg_count
      , x_msg_data           => x_msg_data
      , p_tree_id            => p_tree_id
      , p_revision           => p_revision
      , p_lot_number         => p_lot_number
      , p_subinventory_code  => p_subinventory_code
      , p_locator_id         => p_locator_id
      , x_qoh                => x_qoh
      , x_rqoh               => x_rqoh
      , x_qr                 => x_qr
      , x_qs                 => x_qs
      , x_att                => x_att
      , x_atr                => x_atr
      , x_sqoh               => x_sqoh
      , x_srqoh              => x_srqoh
      , x_sqr                => x_sqr
      , x_sqs                => x_sqs
      , x_satt               => x_satt
      , x_satr               => x_satr
      , p_transfer_subinventory_code => p_transfer_subinventory_code
      , p_cost_group_id      => p_cost_group_id
      , p_lpn_id             => p_lpn_id  --added for bug7038890
      );
   print_debug('After calling Query_Tree return_status='||l_return_status);

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;

   x_return_status := l_return_status;

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Exited with status = '||l_return_status,9);
      print_debug(' ',9);
   END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END update_quantities_for_form;

-- save a node and its children into the backup tables
PROCEDURE save_node
  (p_node_index IN INTEGER)
  IS
     l_node_index INTEGER;
BEGIN
   g_savenodes(p_node_index) := g_nodes(p_node_index);
   l_node_index := g_nodes(p_node_index).first_child_index;
   WHILE l_node_index <> 0 LOOP
      save_node(l_node_index);
      l_node_index := g_nodes(l_node_index).next_sibling_index;
   END LOOP;
END save_node;

-- save a rootinfo and its tree nodes into the backup tables
PROCEDURE save_rootinfo
  (p_tree_id IN INTEGER )
  IS
     l_item_index INTEGER;
BEGIN
   g_saveroots(p_tree_id) := g_rootinfos(p_tree_id);
   l_item_index := g_rootinfos(p_tree_id).item_node_index;
   -- save the item node and all children nodes below
   save_node(l_item_index);
END save_rootinfo;

-- Procedure
--   backup_tree
-- Description
--   backup the current state of a tree
-- Note
--   This is only a one level backup. Calling it twice will
--   overwrite the previous backup
PROCEDURE backup_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_root_id INTEGER;
      l_api_name        VARCHAR2(30) := 'BACKUP_TREE';
BEGIN
   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;
   l_root_id := g_demand_info(p_tree_id).root_id;
   IF is_tree_valid(l_root_id) = FALSE THEN
      fnd_message.set_name('INV', 'INV-Qtyroot not found');
      fnd_message.set_token('ROUTINE', 'Backup_Tree');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   save_rootinfo(l_root_id);
   -- bug 6683013, backing up rsv_tree
   g_save_rsv_tree_id := g_rsv_tree_id;
    g_save_rsv_counter := g_rsv_counter;
    g_saversvnode.DELETE;

    print_debug('backup: rsv_tree_id = ' || g_rsv_tree_id || ' rsv_counter = ' || g_rsv_counter, 11);

    if g_save_rsv_tree_id <> 0 then
       --backup rsv_nodes into g_saversvnode.
       FOR counter in 1..g_rsv_counter LOOP
          g_saversvnode(counter) := g_rsv_info(counter);
       END LOOP;
    end if;

   x_return_status := l_return_status;

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Exited with status = '||l_return_status,9);
      print_debug(' ',9);
   END IF;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;


   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

END backup_tree;

-- restore a node and its children using the backup tables
PROCEDURE restore_node
  (p_node_index IN INTEGER)
  IS
     l_node_index INTEGER;
BEGIN
   g_nodes(p_node_index) := g_savenodes(p_node_index);
   l_node_index := g_savenodes(p_node_index).first_child_index;
   WHILE l_node_index <> 0 LOOP
      restore_node(l_node_index);
      l_node_index := g_savenodes(l_node_index).next_sibling_index;
   END LOOP;
END restore_node;

-- restore a rootinfo and its tree nodes using the backup tables
PROCEDURE restore_rootinfo
  (p_tree_id IN INTEGER )
  IS
     l_item_index INTEGER;
BEGIN
   g_rootinfos(p_tree_id) := g_saveroots(p_tree_id);
   l_item_index := g_saveroots(p_tree_id).item_node_index;
   -- restore the item node and all children nodes below
   restore_node(l_item_index);
END restore_rootinfo;

-- Procedure
--   restore_tree
-- Description
--   restore the current state of a tree to the state
--   at the last time when savepoint_tree is called
-- Note
--   This is only a one level restore. Calling it more than once
--   has the same effect as calling it once.
PROCEDURE restore_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_root_id      INTEGER;
      l_api_name        VARCHAR2(30) := 'RESTORE_TREE';
BEGIN
   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   l_root_id := g_demand_info(p_tree_id).root_id;
   IF is_saved_tree_valid(l_root_id) = FALSE THEN
      fnd_message.set_name('INV', 'INV-Qtyroot not found');
      fnd_message.set_token('ROUTINE', 'Restore_Tree');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   restore_rootinfo(l_root_id);
   -- bug 6683013, restoring back rsv_tree
    g_rsv_tree_id := g_save_rsv_tree_id;
    g_rsv_counter := g_save_rsv_counter;
    g_rsv_info.DELETE;
    print_debug('restore: rsv_tree_id = ' || g_rsv_tree_id || ' rsv_counter = ' || g_rsv_counter, 11);

    if g_save_rsv_tree_id <> 0 then
       --restore rsv_nodes from g_saversvnode.
       FOR counter in 1..g_rsv_counter LOOP
          g_rsv_info(counter) := g_saversvnode(counter);
       END LOOP;
    end if;

   x_return_status := l_return_status;

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Exited with status = '||l_return_status,9);
      print_debug(' ',9);
   END IF;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;


   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

END restore_tree;


-- **NEW BACKUP/RESTORE PROCEDURES**
-- Bug 2788807
--    We now need to support multi-level backup and restore capability
-- for the quantity tree.  We'll overload the existing procedures.

-- Backup_Node
-- recursive function to copy current node, its children, and its siblings
-- to the backup node table
PROCEDURE backup_node
  (p_node_index IN INTEGER)
  IS
     l_node_index INTEGER;
BEGIN
   g_backup_node_counter := g_backup_node_counter + 1;
   g_backup_nodes(g_backup_node_counter) := g_nodes(p_node_index);
   g_backup_nodes(g_backup_node_counter).node_index := p_node_index;

   l_node_index := g_nodes(p_node_index).first_child_index;
   WHILE l_node_index <> 0 LOOP
      backup_node(l_node_index);
      l_node_index := g_nodes(l_node_index).next_sibling_index;
   END LOOP;
END backup_node;

-- Procedure
--   backup_tree
-- Description
--   backup the current state of a tree.  This procedure returns a backup_id
--   which needs to be passed to restore_tree in order to restore the correct
--   version of the quantity tree.  Unlike the older version of backup_tree,
--   this can be called multiple times without overwriting previous backups.
--   The backups dissappear when clear_quantity_cache is called.
--
PROCEDURE backup_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   , x_backup_id     OUT NOCOPY NUMBER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_root_id INTEGER;
      l_backup_id NUMBER;
      l_api_name        VARCHAR2(30) := 'BACKUP_TREE';
BEGIN
   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   l_root_id := g_demand_info(p_tree_id).root_id;
   IF is_tree_valid(l_root_id) = FALSE THEN
      fnd_message.set_name('INV', 'INV-Qtyroot not found');
      fnd_message.set_token('ROUTINE', 'Backup_Tree');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   g_backup_tree_counter := g_backup_tree_counter + 1;
   l_backup_id := g_backup_tree_counter;

   --populate parent table - g_backup_trees
   g_backup_trees(l_backup_id).root_id := l_root_id;
   g_backup_trees(l_backup_id).first_node := g_backup_node_counter + 1;

   --populate child table - g_backup_nodes - by calling recursive function
   backup_node(g_rootinfos(l_root_id).item_node_index);

   --store id of last record of current tree
   g_backup_trees(l_backup_id).last_node := g_backup_node_counter;

   x_return_status := l_return_status;
   x_backup_id := l_backup_id;

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Exited with status = '||l_return_status,9);
      print_debug(' ',9);
   END IF;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

END backup_tree;

-- Procedure
--   restore_tree
-- Description
--   Restores the quantity tree to the point indicated by the backup_id.
--   Tree_id is not strictly needed here, but is kept for overloading and
--   error checking purposes.  Restore_tree can be called multiple times for
--   the same backup_id - a saved quantity tree is not deleted until
--   clear_quantity_cache is called.
PROCEDURE restore_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   , p_backup_id     IN  NUMBER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_root_id         INTEGER;
      l_loop_index   NUMBER;
      l_node_index   NUMBER;
      l_api_name    VARCHAR2(30) := 'RESTORE_TREE';
BEGIN
   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Entered',9);
   END IF;

   IF NOT g_demand_info.exists(p_tree_id) THEN
   raise fnd_api.g_exc_unexpected_error;
   END IF;
   IF NOT g_backup_trees.exists(p_backup_id) THEN
   raise fnd_api.g_exc_unexpected_error;
   END IF;

   l_root_id := g_demand_info(p_tree_id).root_id;

   IF l_root_id <> g_backup_trees(p_backup_id).root_id THEN
        raise fnd_api.g_exc_unexpected_error;
   END IF;

   l_loop_index := g_backup_trees(p_backup_id).first_node;

   LOOP
     EXIT when l_loop_index > g_backup_trees(p_backup_id).last_node;
     l_node_index := g_backup_nodes(l_loop_index).node_index;
     g_nodes(l_node_index) :=g_backup_nodes(l_loop_index);
     l_loop_index := l_loop_index + 1;
   END LOOP;

   x_return_status := l_return_status;

   IF g_debug = 1 THEN
      print_debug(l_api_name || ' Exited with status = '||l_return_status,9);
      print_debug(' ',9);
   END IF;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;


   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

END restore_tree;


function do_check_release_locks return boolean IS
cursor C1 is select organization_id,inventory_item_id
               from mtl_do_check_temp;
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(2000);
l_api_number number := 1.0;

begin
  for c1_rec in C1 loop
      INV_QUANTITY_TREE_PVT.release_lock(
         l_api_number,
         fnd_api.g_false,
         l_return_status,
         l_msg_count,
         l_msg_data,
         c1_rec.organization_id,
         c1_rec.inventory_item_id);
  if l_return_status = fnd_api.g_ret_sts_error then
    Return FALSE;
  End if;
  end loop;
return TRUE;
end;

-------------------------------------------------------------------------------
-- Coding standard used in this program
-- 1. PLSQL business object api coding standard
-- 2. Oracle application developer's guide
-- Note:
-- 1. Data types are not initialized to fnd_api.g_miss_???
-- 2. Procedures or functions not exposed to user do not have the following parameters:
--    p_api_version, p_msg_count, p_msg_data. x_return_status is optional.
-- 3. identation and character case uses plsql mode of emacs
-------------------------------------------------------------------------------
END inv_quantity_tree_pvt;

/
