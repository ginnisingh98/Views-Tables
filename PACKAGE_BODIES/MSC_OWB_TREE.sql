--------------------------------------------------------
--  DDL for Package Body MSC_OWB_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_OWB_TREE" AS
/* $Header: MSCOSTRB.pls 120.5 2006/08/04 23:27:15 cnazarma noship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

/*

PROCEDURE extend( p_nodes IN OUT NoCopy owb_tree.noderec, extend_amount NUMBER );
PROCEDURE extend( p_nodes IN OUT NoCopy owb_tree.nodedata, extend_amount NUMBER );
*/
PROCEDURE get_next_level_nodes(p_end_pegging_id    NUMBER,
			       p_session_id        NUMBER,
			       p_nodes         OUT NoCopy owb_tree.NodeData,
			       p_expand_level      NUMBER,
			       p_current_pegging_id NUMBER);

PROCEDURE get_supply_only_nodes(p_end_pegging_id    NUMBER,
                                p_session_id        NUMBER,
                                p_nodes         OUT NoCopy owb_tree.NodeData,
                                p_expand_level      NUMBER,
                                p_current_pegging_id NUMBER);

PROCEDURE extend( p_nodes IN OUT NoCopy owb_tree.noderec, extend_amount NUMBER ) IS
BEGIN
   p_nodes.tree_type.extend(extend_amount);
   p_nodes.parent_node_type.extend(extend_amount);
   p_nodes.state.extend( extend_amount );
   p_nodes.depth.extend( extend_amount );
   p_nodes.label.extend( extend_amount );
   p_nodes.icon.extend( extend_amount );
   p_nodes.data.extend( extend_amount );
END extend;


PROCEDURE extend( p_nodes IN OUT NoCopy owb_tree.nodedata, extend_amount NUMBER ) IS
BEGIN
   p_nodes.state.extend( extend_amount );
   p_nodes.depth.extend( extend_amount );
   p_nodes.label.extend( extend_amount );
   p_nodes.icon.extend( extend_amount );
   p_nodes.data.extend( extend_amount );
END extend;

PROCEDURE get_node
  ( p_tree_type    NUMBER,
    p_parent       NUMBER,
    p_nodes IN OUT NoCopy owb_tree.noderec,
    p_lookup_code    NUMBER ,
    p_state        NUMBER ,
    p_depth        NUMBER,
    p_icon         VARCHAR2);

PROCEDURE getstructure
  (p_session_id NUMBER,
   p_mode       NUMBER,
   p_nodes      OUT NoCopy owb_tree.nodeRec) IS
     l_current_node_depth NUMBER;

     total_excp NUMBER;

BEGIN
   record_count := 1;

   IF p_mode = 2 OR p_mode = 4 THEN
      -- OE view results or SC ATP
      extend( p_nodes, nodes_in_orders_tree);
    ELSIF p_mode = 1 THEN
      -- backlog mode
      extend( p_nodes, 1+nodes_in_orders_tree+nodes_in_items_tree);
   END IF;


   l_current_node_depth := 1;
   get_node( orders_tree, 0 ,p_nodes, sales_orders, 1, l_current_node_depth, ICON_FOLDER);

   l_current_node_depth := 1;    -- These nodes will be relative to parent node. Hence 1
   get_node( 0, sales_orders_n ,p_nodes, indep_lines, 0, l_current_node_depth, ICON_FOLDER);
   get_node( 0, sales_orders_n ,p_nodes, ship_sets, 1, l_current_node_depth, ICON_FOLDER);
   get_node( 0, sales_orders_n ,p_nodes, arrival_sets, 1, l_current_node_depth, ICON_FOLDER);
   get_node( orders_tree, ship_sets_n ,p_nodes, sources, 1, l_current_node_depth,ICON_FOLDER );
   -- 0 implies that the hierarchy is common to all trees

   IF p_mode = 1 THEN
      l_current_node_depth := 1;
      get_node( excp_tree, 0 , p_nodes, exceptions, 1, l_current_node_depth, ICON_FOLDER);

      l_current_node_depth := 2;

      total_excp := get_excp_count(p_session_id, 1);
      IF total_excp > 0 THEN
	 extend(p_nodes,1);
	 get_node( excp_tree, exceptions, p_nodes, shortage, 1, l_current_node_depth,ICON_FOLDER );
	 p_nodes.label(record_count-1) := p_nodes.label(record_count-1)||' ('||total_excp||')';
      END IF;
      total_excp := get_excp_count(p_session_id, 2);
      IF  total_excp > 0 THEN
	 extend(p_nodes,1);
	 get_node( excp_tree, exceptions,p_nodes, later_than_old_schedule_date, 1, l_current_node_depth, ICON_FOLDER);
	 p_nodes.label(record_count-1) := p_nodes.label(record_count-1)||' ('||total_excp||')';
      END IF;
      total_excp := get_excp_count(p_session_id, 3);
      IF total_excp > 0 THEN
	 extend(p_nodes,1);
	 get_node( excp_tree, exceptions,p_nodes, later_than_promise_date , 1, l_current_node_depth, ICON_FOLDER);
	 p_nodes.label(record_count-1) := p_nodes.label(record_count-1)||' ('||total_excp||')';
      END IF;
      total_excp := get_excp_count(p_session_id, 4);
      IF total_excp > 0 THEN
	 extend(p_nodes,1);
	 get_node( excp_tree, exceptions,p_nodes, later_than_request_date , 1, l_current_node_depth,ICON_FOLDER );
	 p_nodes.label(record_count-1) := p_nodes.label(record_count-1)||' ('||total_excp||')';
      END IF;
      total_excp := get_excp_count(p_session_id, 5);
      IF total_excp > 0 THEN
	 extend(p_nodes,1);
	 get_node( excp_tree, exceptions,p_nodes, insufficient_margin , 1, l_current_node_depth, ICON_FOLDER);
	 p_nodes.label(record_count-1) := p_nodes.label(record_count-1)||' ('||total_excp||')';
      END IF;
      total_excp := get_excp_count(p_session_id, 6);
      IF total_excp > 0 THEN
	 extend(p_nodes,1);
	 get_node( excp_tree, exceptions,p_nodes, modified_source, 1, l_current_node_depth, ICON_FOLDER);
	 p_nodes.label(record_count-1) := p_nodes.label(record_count-1)||' ('||total_excp||')';
      END IF;
      total_excp := get_excp_count(p_session_id, 7);
      IF total_excp > 0 THEN
	 extend(p_nodes,1);
	 get_node( excp_tree, exceptions,p_nodes, errors, 1, l_current_node_depth, ICON_FOLDER);
	 p_nodes.label(record_count-1) := p_nodes.label(record_count-1)||' ('||total_excp||')';
      END IF;

      l_current_node_depth := 1;
      get_node( items_tree, 0 , p_nodes, organizations, 1, l_current_node_depth, ICON_FOLDER);

      get_node( items_tree, organizations_n ,p_nodes, product_families , 1,l_current_node_depth, ICON_FOLDER);
      get_node( items_tree, organizations_n , p_nodes, categories,  1, l_current_node_depth, ICON_FOLDER);
      get_node( items_tree, categories_n , p_nodes, items,  1, l_current_node_depth, ICON_FOLDER);
      get_node( items_tree, product_families_n , p_nodes, items,  1, l_current_node_depth, ICON_FOLDER);
      get_node( items_tree, items, p_nodes, items_n,  1, l_current_node_depth, ICON_FOLDER);
      get_node( items_tree, items_n ,p_nodes, sales_orders, 1, l_current_node_depth, ICON_FOLDER);
   END IF;

END getstructure;

PROCEDURE get_node
  ( p_tree_type    NUMBER,
    p_parent       NUMBER,
    p_nodes IN OUT NoCopy owb_tree.noderec,
    p_lookup_code    NUMBER ,
    p_state        NUMBER ,
    p_depth        NUMBER,
    p_icon         VARCHAR2)
  IS

     CURSOR l1(p_lookup_code NUMBER, p_state NUMBER, p_depth NUMBER, p_icon VARCHAR2 ) IS
	SELECT
	  p_state,
	  p_depth,
	  Meaning,
	  p_icon,
	  To_char(lookup_code)   -- mfg_lookups still has it as a number
	  FROM mfg_lookups
	  WHERE LOOKUP_TYPE = 'MRP_NODE_TYPE'
	  AND LOOKUP_CODE  = To_char(p_lookup_code);

BEGIN
   OPEN l1(p_lookup_code, p_state, p_depth, p_icon);

   FETCH l1 INTO
     p_nodes.state(record_count),
     p_nodes.depth(record_count),
     p_nodes.label(record_count),
     p_nodes.icon(record_count),
     p_nodes.data(record_count);
   CLOSE l1;
   p_nodes.tree_type(record_count) := p_tree_type;
   p_nodes.parent_node_type(record_count) := p_parent;
   record_count := record_count + 1;
END get_node;

FUNCTION get_demand_class ( p_pegging_id IN NUMBER, p_session_id IN NUMBER)
        return VARCHAR2  IS

v_demand_class varchar2(40):= NULL;

BEGIN

   select CHAR1 into v_demand_class
   from mrp_atp_details_temp
   where record_type = 3
   and pegging_id = p_pegging_id
   and session_id = p_session_id;

   RETURN v_demand_class;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RETURN NULL;

END get_demand_class;


FUNCTION get_excp_count( p_session_id NUMBER, col_num NUMBER ) RETURN INTEGER IS
   excp_count NUMBER := 0;
   stmt VARCHAR2(200);
BEGIN
   stmt :=
   '   SELECT count(1) '||
   '   FROM mrp_atp_schedule_temp mast '||
   '   WHERE mast.session_id = :p_session_id '||
   '   AND exception'||col_num||' = 1';

   execute immediate stmt INTO excp_count using p_session_id;
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_excp_count: ' || ' Exception'||col_num||' count '||excp_count);
   END IF;

   RETURN excp_count;
EXCEPTION
   WHEN no_data_found THEN
      RETURN 0;
END get_excp_count;

PROCEDURE get_lookups IS
BEGIN
   IF NOT owb_tree.lookups.exists(1) THEN
      SELECT
	Decode(lookup_code,
	       0, Substr(meaning, 1,4),
	       1, Substr(meaning, 1,13),
	       2, Substr(meaning, 1,10),
	       3, Substr(meaning, 1,4),
	       10, Substr(meaning, 1,6),
	       15, Substr(meaning, 1,11),
	       30, Substr(meaning, 1,4),
	       35, Substr(meaning, 1,5),
	       40, Substr(meaning, 1,6),
	       45, Substr(meaning, 1,3),
	       50, Substr(meaning, 1,4),
	       60, Substr(meaning, 1,3),
	       70, Substr(meaning, 1,16),
	       75, Substr(meaning, 1,16),
	       80, Substr(meaning, 1,10),
	       85, Substr(meaning, 1,10),
	       90, Substr(meaning, 1,11),
	       100,Substr(meaning, 1,6),
               110,Substr(meaning, 1,16),
               111,Substr(meaning, 1,24), -- Material Constraint
               112,Substr(meaning, 1,30), -- PTF constraint
               113, Substr(meaning, 1,40), -- Manufacturing Constraint
               114, Substr(meaning,1,36),  -- Purchasing Constraint
               115, Substr(meaning,1,34), -- Transfer Constraint
               116, Substr(meaning,1,24),  -- Resource  Constraint
               117, Substr(meaning,1,24),   -- Calendar Constraint
               119, Substr(meaning,1,40)   -- Product Family Demand Spread
                )
	bulk collect INTO owb_tree.lookups
	FROM mfg_lookups
	WHERE
	(lookup_type = 'MRP_SOURCE_TYPE' AND lookup_code IN ( 0, 1, 2, 3))
	OR (lookup_type = 'MRP_ATP_FORM_TYPE' AND  lookup_code IN
	    (10, 15, 30, 35, 40, 45, 50, 60, 70, 75, 80, 85, 90, 100, 111,110,112,113,114,115,116, 117,119))
	ORDER BY lookup_code;
      -- 1.  ATP               0        4
      -- 2.  Transfer          1        1
      -- 3.  Make At           2        2
      -- 4.  Buy               3        3
      -- 5.  Item              10       16
      -- 6.  Resource          15       17
      -- 7.  Res               30       5
      -- 8.  Dept              35       6
      -- 9.  From              40       7
      -- 10. To                45       8
      -- 11. Qty               50       9
      -- 12. To                60       10
      -- 13. Total supply      70       11
      -- 14. Total demand      75       12
      -- 15. Net ATP           80       13
      -- 16. Cum ATP           85       14
      -- 17. Supplier          90       15
      -- 18. Line              100
      -- 19. Substitute        110
      -- 20,
      FOR j IN 1..owb_tree.LOOKUPS_COUNT LOOP
	 msc_sch_wb.atp_debug(' lookups '||j||' '||owb_tree.lookups(j));
      END LOOP;

   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Excp in get_lookups '||Substr(Sqlerrm, 1,100));
      END IF;
END get_lookups;

PROCEDURE get_Sourcing_Nodes(p_end_pegging_id    NUMBER,
			     p_session_id        NUMBER,
			     p_nodes OUT         NoCopy owb_tree.NodeData,
			     p_expand_level      NUMBER,
			     p_current_node_data NUMBER,
                             p_checkbox   BOOLEAN DEFAULT FALSE)  IS
BEGIN
   get_lookups;

-- ATP Pegging


 IF NOT p_checkbox THEN
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('get_Sourcing_Nodes: ' || '  Checkbox is False, so calling regular tree');
END IF;
   IF p_current_node_data IS NULL THEN
      -- There is no ref node, and we have to populate the first levels
      -- When initializing we only need the first level rows with no expansion
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('get_Sourcing_Nodes: ' || '  p_current_node_data IS NULL  ');
      END IF;
      get_next_level_nodes(p_end_pegging_id, p_session_id,
			   p_nodes, next_level, NULL);
    ELSE
      IF p_expand_level = NEXT_LEVEL THEN
	 IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('get_Sourcing_Nodes: ' || p_end_pegging_id||' '||p_current_node_data);
	 END IF;

	 get_next_level_nodes(p_end_pegging_id, p_session_id,
			      p_nodes, NEXT_LEVEL, p_current_node_data);
       ELSIF p_expand_level = ALL_LEVELS THEN
	 get_next_level_nodes(p_end_pegging_id, p_session_id,
			      p_nodes, ALL_LEVELS, p_current_node_data);

       ELSIF p_expand_level = CONSTRAINT_LEVEL THEN
         get_next_level_nodes(p_end_pegging_id, p_session_id,
                                p_nodes, CONSTRAINT_LEVEL,p_current_node_data);


      END IF;
   END IF;

/*   IF p_current_node_data IS NOT NULL THEN
      p_nodes.DELETE(1);
   END IF; */
-- ATP PEgging
 ELSE
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('get_Sourcing_Nodes: ' || '  Calling only get_supply_only_nodes ' );
END IF;
    IF p_current_node_data IS NULL THEN
      -- There is no ref node, and we have to populate the first levels
      -- When initializing we only need the first level rows with no expansion
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('get_Sourcing_Nodes: ' || '  p_current_node_data IS NULL  ');
      END IF;
      get_supply_only_nodes(p_end_pegging_id, p_session_id,
                           p_nodes, next_level, NULL);
    ELSE
      IF p_expand_level = NEXT_LEVEL THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('get_Sourcing_Nodes: ' || p_end_pegging_id||' '||p_current_node_data);
         END IF;
-- ATP Pegging
         get_supply_only_nodes(p_end_pegging_id, p_session_id,
                              p_nodes, NEXT_LEVEL, p_current_node_data);
       ELSIF p_expand_level = ALL_LEVELS THEN
         get_supply_only_nodes(p_end_pegging_id, p_session_id,
                              p_nodes, ALL_LEVELS, p_current_node_data);

     ELSIF p_expand_level = CONSTRAINT_LEVEL THEN
         get_supply_only_nodes(p_end_pegging_id, p_session_id,
                                p_nodes, CONSTRAINT_LEVEL,p_current_node_data);


      END IF;
   END IF;
  END IF;

   IF p_nodes.state.COUNT = 0 THEN
      extend(p_nodes,1);
      fnd_message.set_name('MRP','MRP_ATP_NO_PEGGING');
      p_nodes.label(1) := Substr(fnd_message.get, 1, 240);
      p_nodes.state(1) := LEAF_NODE;
      p_nodes.depth(1) := 1;
      p_nodes.icon(1) := ICON_NO_PEGGING;
      p_nodes.data(1) := 0;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Excp in get_sourcing_nodes '||Substr(Sqlerrm, 1,100));
      END IF;
END get_sourcing_nodes;

FUNCTION get_cust_hier_string
         (dmd_class in VARCHAR2) return VARCHAR2 IS

pos1 number;
pos2 number;
v_class VARCHAR2(500);

v_dmd_string VARCHAR2(1000);

v_partner_id number;
v_partner_site_id number;
v_partner_name varchar2(100);
v_partner_site_name varchar2(240);
delim     constant varchar2(1) := fnd_global.local_chr(13);

BEGIN
      pos1 := instr(dmd_class,delim,1,1);
      pos2 := instr(dmd_class,delim,1,2);

      if pos1 = 0 then
         if dmd_class = '-1' then
            v_class := 'OTHER';
         else
            v_class := dmd_class;
         end if;

         v_dmd_string := v_class;

      elsif pos1 <> 0 and pos2 = 0 then
         v_class := substr(dmd_class,1,pos1-1);
         v_partner_id := substr(dmd_class,pos1+1);
         if v_partner_id = -1 then
            v_partner_name := 'OTHER';
         else
            v_partner_name := msc_get_name.customer(v_partner_id);
         end if;

         if v_class = '-1' then
            v_class := 'OTHER';
         end if;
         v_dmd_string := v_class||' -  '||v_partner_name;

      elsif pos1 <> 0 and pos2 <> 0 then
         v_class           := substr(dmd_class,1,pos1-1);
         v_partner_id      := substr(dmd_class,pos1+1,pos2-pos1-1);
         v_partner_site_id := substr(dmd_class,pos2+1);
         if v_partner_id = -1 then
            v_partner_name := 'OTHER';
         else
            v_partner_name := msc_get_name.customer(v_partner_id);
         end if;
         if v_partner_site_id = -1 then
            v_partner_site_name := 'OTHER';
         else
            v_partner_site_name := msc_get_name.customer_site(v_partner_site_id);
         end if;
         if v_class = '-1' then
            v_class := 'OTHER';
         end if;

         v_dmd_string := v_class||' - '||v_partner_name||' - '||v_partner_site_name;

      end if;

  return v_dmd_string;

END get_cust_hier_string;


PROCEDURE get_next_level_nodes(p_end_pegging_id    NUMBER,
			       p_session_id        NUMBER,
			       p_nodes         OUT NoCopy owb_tree.NodeData,
			       p_expand_level      NUMBER,
			       p_current_pegging_id NUMBER)
  IS
     counter NUMBER;
BEGIN
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('get_next_level_nodes: ' || 'Cholpon check of p_expand_level' || p_expand_level);
END IF;
   SELECT
     Decode(inventory_item_name, NULL,
	    Decode(department_code, NULL,leaf_node,
		   Decode(supply_demand_type,1,
			  Decode(p_expand_level, next_level, collapsed,
				                 all_levels, expanded,
                                                 constraint_level, decode(constrained_path, NULL, collapsed, expanded)
                                    )
			  ,leaf_node)),
	    -- Only TR, source are 1st lev
	    Decode(supply_demand_type,1,
		   Decode(p_expand_level, next_level, collapsed, all_levels, expanded,
                           constraint_level,decode(constrained_path, NULL, collapsed, expanded)),
		   Decode(source_type, NULL, leaf_node, 0, leaf_node, 3,
			  Decode(p_expand_level, next_level, collapsed, all_levels, expanded,
                                 constraint_level, decode(constrained_path, NULL, collapsed, expanded)),
			  -- It will be collapsed if it is not a source_type node
			  -- (i.e. make etc)
			  -- It will be collapsed if it is a BUY from source
			  -- It will also be leaf_node for null or ATP
			  Decode(p_expand_level, next_level, collapsed,
				 all_levels, expanded,
                                 constraint_level, decode(constrained_path, NULL, collapsed, expanded))))),
     LEVEL-1,
     Decode(inventory_item_name, NULL,
	    -- when it is null
	    Decode(department_code, NULL,
		   (ship_method||' - '||ROUND(supply_demand_quantity,6)||' '||uom_code||' - '
		    ||from_organization_code
		    ||Decode(from_location_code, NULL, '', '('||from_location_code||')')
		    ||' '||owb_tree.lookups(10)||' '
		    ||to_organization_code
		    ||Decode(to_location_code, NULL, '', '('||to_location_code||')')),
		   -- dept is not null
		   Decode(resource_code, NULL,
			  -- Line
			  owb_tree.lookups(18)||'-'||department_code,
			  -- Resource
			  owb_tree.lookups(8)||'-'||department_code||':'||owb_tree.lookups(7)||'-'||resource_code)
		   ||' '||owb_tree.lookups(11)||' '||ROUND(supply_demand_quantity,6)||' '||uom_code||' '||owb_tree.lookups(12)||' '||fnd_date.date_to_displaydate(supply_demand_date)),
	    -- when item_name is not null
		   inventory_item_name ||' -'||Decode(number1,1, owb_tree.lookups(19)||' ',' ')
	    ||Decode(source_type, 1, owb_tree.lookups(2),2, owb_tree.lookups(3), 3, owb_tree.lookups(4),
		     0, owb_tree.lookups(1))
	    ||' '||Decode(source_type, 3, supplier_name, nvl(supplier_name,organization_code)) ||
            ' '||supplier_site_name||
	    ' '||owb_tree.lookups(11)||' '||ROUND(supply_demand_quantity,6)||' '||owb_tree.lookups(12)||' '
	    ||fnd_date.date_to_displaydate(supply_demand_date)
               ) || ' '
                   ||decode(constraint_type,null,null,
                                            1, '{'||owb_tree.lookups(20)||'}',
                                            2, '{'||owb_tree.lookups(21)||' '||fnd_date.date_to_displaydate(constraint_date)||'}',
                                            3, '{'||owb_tree.lookups(22)||' ' ||fnd_date.date_to_displaydate(constraint_date)||'}',
                                            4, '{'||owb_tree.lookups(23)||' '||fnd_date.date_to_displaydate(constraint_date)||'}',
                                            5, '{'||owb_tree.lookups(24)||' ' || fnd_date.date_to_displaydate(constraint_date)||'}',
                                            6, '{'||owb_tree.lookups(25)||'}',
                                            7 , '{'||owb_tree.lookups(26)||'}')
             ||decode(char1,null, null, ' ('||get_cust_hier_string(char1)||')'),
     decode(supply_demand_type,1, ICON_DEMAND,
	    decode(inventory_item_name, NULL,
		   decode(constraint_type,NULL,ICON_RESOURCE_CAP,   -- Dept Res
			  ICON_RESOURCE_CAP_CRIT),
                   decode(source_type,0,
		           decode(constraint_type, NULL,ICON_RESOURCE_CAP,
                             ICON_RESOURCE_CAP_CRIT),
                        decode(constrained_path,NULL,ICON_RESOURCE_CAP,
                                          ICON_RESOURCE_CAP_CRIT))
		   )
	    ),
     pegging_id data
     bulk collect INTO
     p_nodes.state,
     p_nodes.depth,
     p_nodes.label,
     p_nodes.icon,
     p_nodes.data
     FROM mrp_atp_details_temp
     where nonatp_flag is NULL
     start WITH
     session_id = p_session_id
     AND record_type = 3
     AND end_pegging_id = p_end_pegging_id
     AND nvl(p_current_pegging_id, Nvl(parent_pegging_id, -1))
         = Decode(p_current_pegging_id,NULL, -1, pegging_id)
     connect by
     PRIOR session_id = session_id
     AND PRIOR record_type = record_type
     AND PRIOR pegging_id = parent_pegging_id
     AND PRIOR end_pegging_id = end_pegging_id
     AND Decode(p_expand_level, NEXT_LEVEL, Nvl(p_current_pegging_id,-1),ALL_LEVELS, 1, CONSTRAINT_LEVEL,2)
          = Decode(p_expand_level, NEXT_LEVEL, Nvl(parent_pegging_id, -1), ALL_LEVELS, 1,CONSTRAINT_LEVEL,2)
   ORDER BY pegging_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug(' get_next_level_nodes EPI '||p_end_pegging_id||' exp '||p_expand_level||' PId '||p_current_pegging_id);
   END IF;

/*      for j in 1..p_nodes.state.count loop
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_next_level_nodes: ' || ' s '||p_nodes.state(j)	||' d '||p_nodes.depth(j)||' l '||p_nodes.label(j)||' i '||p_nodes.icon(j)||' d '||p_nodes.data(j));
   END IF;	end loop;
*/

     EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug(' Exception in get_next_level_nodes '||Substr(Sqlerrm, 1, 100));
      END IF;
END get_next_level_nodes;

PROCEDURE get_supply_only_nodes (p_end_pegging_id    NUMBER,
                                            p_session_id        NUMBER,
                                            p_nodes         OUT NoCopy owb_tree.NodeData,
                                            p_expand_level      NUMBER,
                                            p_current_pegging_id NUMBER)
  IS
     counter NUMBER;
BEGIN
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('get_supply_only_nodes: ' || 'Cholpon check ' || owb_tree.lookups(21));
END IF;
   SELECT
     Decode(inventory_item_name, NULL,
            Decode(department_code, NULL,leaf_node,
                   Decode(supply_demand_type,1,
                        Decode(p_expand_level, next_level, collapsed,
                                 all_levels, expanded,
                                 constraint_level,
                                 decode(constrained_path, NULL, collapsed, expanded))
                          ,leaf_node)),
            -- Only TR, source are 1st lev
            Decode(supply_demand_type,1,
                   Decode(p_expand_level, next_level, collapsed, all_levels, expanded,constraint_level,decode(constrained_path, NULL, collapsed, expanded)),
                   Decode(source_type, NULL, leaf_node, 0, leaf_node, 3,
                          Decode(p_expand_level, next_level, collapsed, all_levels, expanded,
                                  constraint_level,
                                   decode(constrained_path, NULL, collapsed, expanded)),
                          -- It will be collapsed if it is not a source_type node
                          -- (i.e. make etc)
                          -- It will be collapsed if it is a BUY from source
                          -- It will also be leaf_node for null or ATP
                          Decode(p_expand_level, next_level, collapsed,
                                 all_levels, expanded,
                                 constraint_level,
                                     decode(constrained_path,NULL,collapsed, expanded))))),
     DECODE(LEVEL, 1, 0, LEVEL/2),
     Decode(inventory_item_name, NULL,
            -- when it is null
            Decode(department_code, NULL,
                   (ship_method||' - '||ROUND(supply_demand_quantity,6)||' '||uom_code||' - '
                    ||from_organization_code
                    ||Decode(from_location_code, NULL, '', '('||from_location_code||')')
                    ||' '||owb_tree.lookups(10)||' '
                    ||to_organization_code
                    ||Decode(to_location_code, NULL, '', '('||to_location_code||')')),
                        -- dept is not null
                  Decode(resource_code, NULL,
                          -- Line
                          owb_tree.lookups(18)||'-'||department_code,
                          -- Resource
           owb_tree.lookups(8)||'-'||department_code||':'||owb_tree.lookups(7)||'-'||resource_code)
                   ||' '||owb_tree.lookups(11)||' '||ROUND(supply_demand_quantity,6)||' '||uom_code||' '||owb_tree.lookups(12)||' '||fnd_date.date_to_displaydate(supply_demand_date)),
            -- when item_name is not null
                   inventory_item_name ||' -'||Decode(number1,1, owb_tree.lookups(19)||' ',' ')
            ||Decode(source_type, 1, owb_tree.lookups(2),2, owb_tree.lookups(3), 3, owb_tree.lookups(4),
                     0, owb_tree.lookups(1))
            ||' '||Decode(source_type, 3, supplier_name, nvl(supplier_name,organization_code))||
            ' '||supplier_site_name||
            ' '||owb_tree.lookups(11)||' '||ROUND(supply_demand_quantity,6)||' '||owb_tree.lookups(12)||' '
            ||fnd_date.date_to_displaydate(supply_demand_date)
               ) ||
                    ' ' ||decode(constraint_type,null,null,
                                  1 , '{'||owb_tree.lookups(20)||' '||fnd_date.date_to_displaydate(constraint_date) ||'}',
                                  2,  '{'||owb_tree.lookups(21)||' ' ||fnd_date.date_to_displaydate(constraint_date)||'}',                                   3,  '{'||owb_tree.lookups(22)||' ' ||fnd_date.date_to_displaydate(constraint_date)||'}',
                                  4,  '{'||owb_tree.lookups(23)||' ' ||fnd_date.date_to_displaydate(constraint_date)||'}',
                                  5,  '{'||owb_tree.lookups(24)||' '||fnd_date.date_to_displaydate(constraint_date) ||'}',
                                  6,  '{'||owb_tree.lookups(25) || '}',
                                   7 , '{'||owb_tree.lookups(26)||'}')
             ||decode(char1,null, null, ' ('||get_cust_hier_string(char1)||')'),
         decode(supply_demand_type,1, ICON_DEMAND,
            decode(inventory_item_name, NULL,
                   decode(constraint_type,NULL,ICON_RESOURCE_CAP,   -- Dept Res
                          ICON_RESOURCE_CAP_CRIT),
                   decode(source_type,0,
                           decode(constraint_type, NULL,ICON_RESOURCE_CAP,
                             ICON_RESOURCE_CAP_CRIT),
                        decode(constrained_path,NULL,ICON_RESOURCE_CAP,
                                          ICON_RESOURCE_CAP_CRIT))
                   )
            ),
     pegging_id data
     bulk collect INTO
     p_nodes.state,
     p_nodes.depth,
     p_nodes.label,
     p_nodes.icon,
     p_nodes.data
    FROM mrp_atp_details_temp
    where supply_demand_type = Decode(parent_pegging_id, NULL, 1,2)
    /*and   decode(p_current_pegging_id, NULL, -1 , atp_level) = decode(p_current_pegging_id , NULL, -1, dummy)*/
     start WITH
     session_id = p_session_id
     AND record_type = 3
     AND end_pegging_id = p_end_pegging_id
     AND nvl(p_current_pegging_id, Nvl(parent_pegging_id, -1)) = Decode(p_current_pegging_id,NULL, -1, pegging_id)
     connect by
     PRIOR session_id = session_id
     AND PRIOR record_type = record_type
     AND PRIOR pegging_id = parent_pegging_id
     AND PRIOR end_pegging_id = end_pegging_id
   /*  AND Decode(p_expand_level, NEXT_LEVEL, decode(p_current_pegging_id,NULL,-1,-2),ALL_LEVELS, 1,CONSTRAINT_LEVEL,2) = Decode(p_expand_level,
 NEXT_LEVEL, decode(parent_pegging_id,NULL, -1, -2), ALL_LEVELS, 1,CONSTRAINT_LEVEL,2)*/
  /*   AND Decode(p_expand_level, NEXT_LEVEL, Nvl(p_current_pegging_id,-1),ALL_LEVELS, 1) = Decode(p_expand_level, NEXT_LEVEL, Nvl(parent_pegging_id, -1), ALL_LEVELS, 1)*/
     ORDER BY pegging_id;


   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_supply_only_nodes: ' || ' get_next_level_nodes EPI '||p_end_pegging_id||' exp '||p_expand_level||' PId '||p_current_pegging_id);
   END IF;

/*      for j in 1..p_nodes.state.count loop
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_supply_only_nodes: ' || ' s '||p_nodes.state(j) ||' d '||p_nodes.depth(j)||' l '||p_nodes.label(j)||' i '||p_nodes.icon(j)||' d '||p_nodes.data(j));
   END IF;    end loop
;
*/


 EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('get_supply_only_nodes: ' || ' Exception in get_next_level_nodes '||Substr(Sqlerrm, 1, 100));
      END IF;
END get_supply_only_nodes;




END MSC_OWB_TREE;

/
