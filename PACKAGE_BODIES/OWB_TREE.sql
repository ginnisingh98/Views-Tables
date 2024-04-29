--------------------------------------------------------
--  DDL for Package Body OWB_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OWB_TREE" AS
/* $Header: MRPOSTRB.pls 115.35 2002/12/02 21:10:50 dsting ship $ */

/*
PROCEDURE extend( p_nodes IN OUT NoCopy noderec, extend_amount NUMBER );
PROCEDURE extend( p_nodes IN OUT NoCopy nodedata, extend_amount NUMBER );
PROCEDURE get_next_level_nodes(p_end_pegging_id    NUMBER,
			       p_session_id        NUMBER,
			       p_nodes         OUT NoCopy NodeData,
			       p_expand_level      NUMBER,
			       p_current_pegging_id NUMBER);
PROCEDURE get_node
  ( p_tree_type    NUMBER,
    p_parent       NUMBER,
    p_nodes IN OUT NoCopy noderec,
    p_lookup_code    NUMBER ,
    p_state        NUMBER ,
    p_depth        NUMBER,
    p_icon         VARCHAR2);
*/

PROCEDURE getstructure
  (p_session_id NUMBER,
   p_mode       NUMBER,
   p_nodes      OUT NoCopy nodeRec) IS
BEGIN
	MSC_OWB_TREE.getstructure(p_session_id, p_mode, p_nodes);
END getstructure;

/*
PROCEDURE extend( p_nodes IN OUT NoCopy noderec, extend_amount NUMBER ) IS
BEGIN
	MSC_OWB_TREE.extend(p_nodes, extend_amount);
END extend;

PROCEDURE extend( p_nodes IN OUT NoCopy nodedata, extend_amount NUMBER ) IS
BEGIN
	MSC_OWB_TREE.extend(p_nodes, extend_amount);
END extend;

PROCEDURE get_node
  ( p_tree_type    NUMBER,
    p_parent       NUMBER,
    p_nodes IN OUT NoCopy noderec,
    p_lookup_code    NUMBER ,
    p_state        NUMBER ,
    p_depth        NUMBER,
    p_icon         VARCHAR2)
  IS
BEGIN
	MSC_OWB_TREE.get_node(
		p_tree_type,
    		p_parent,
    		p_nodes,
    		p_lookup_code,
    		p_state,
    		p_depth,
    		p_icon);
END get_node;
*/

FUNCTION get_excp_count( p_session_id NUMBER, col_num NUMBER ) RETURN INTEGER IS
BEGIN
   RETURN MSC_OWB_TREE.get_excp_count(p_session_id, col_num);
END get_excp_count;

PROCEDURE get_lookups IS
BEGIN
	MSC_OWB_TREE.get_lookups();
END get_lookups;

PROCEDURE get_Sourcing_Nodes(p_end_pegging_id    NUMBER,
			     p_session_id        NUMBER,
			     p_nodes OUT         NoCopy NodeData,
			     p_expand_level      NUMBER,
			     p_current_node_data NUMBER,
                             p_checkbox          BOOLEAN DEFAULT FALSE) IS
BEGIN
	MSC_OWB_TREE.get_Sourcing_Nodes(
		p_end_pegging_id,
                p_session_id,
                p_nodes,
                p_expand_level,
                p_current_node_data,
                p_checkbox);
END get_sourcing_nodes;

FUNCTION get_cust_hier_string
         (dmd_class in VARCHAR2) return VARCHAR2 IS
BEGIN
  return MSC_OWB_TREE.get_cust_hier_string(dmd_class);
END get_cust_hier_string;


/*
PROCEDURE get_next_level_nodes(p_end_pegging_id    NUMBER,
			       p_session_id        NUMBER,
			       p_nodes         OUT NoCopy NodeData,
			       p_expand_level      NUMBER,
			       p_current_pegging_id NUMBER)
  IS
BEGIN
	MSC_OWB_TREE.get_next_level_nodes(
		p_end_pegging_id,
                p_session_id,
                p_nodes,
                p_expand_level,
                p_current_pegging_id);
END get_next_level_nodes;
*/

END OWB_TREE;

/
