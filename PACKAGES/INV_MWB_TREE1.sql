--------------------------------------------------------
--  DDL for Package INV_MWB_TREE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_TREE1" AUTHID CURRENT_USER AS
/* $Header: INVMWTRS.pls 120.0.12000000.2 2007/10/16 11:52:48 athammin ship $ */


  PROCEDURE add_document_numbers(
            x_node_value IN OUT NOCOPY NUMBER
           ,x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY NUMBER
           );

  PROCEDURE add_orgs(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_statuses(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_subs(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_locs(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_cgs(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_lpns(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_items(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_revs(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_lots(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_serials(
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE add_grades (
            x_node_value IN OUT NOCOPY  NUMBER
           ,x_node_tbl   IN OUT NOCOPY  fnd_apptree.node_tbl_type
           ,x_tbl_index  IN OUT NOCOPY  NUMBER
           );

  PROCEDURE get_mln_attributes_structure(
            x_attributes        IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
           ,x_attributes_count     OUT NOCOPY NUMBER
           ,x_return_status        OUT NOCOPY VARCHAR2
           ,x_msg_count            OUT NOCOPY NUMBER
           ,x_msg_data             OUT NOCOPY NUMBER
           );

  PROCEDURE get_mln_attributes(
            x_attribute_values   IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
           ,x_attribute_prompts  IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
           ,x_attributes_count      OUT NOCOPY NUMBER
           ,x_return_status         OUT NOCOPY VARCHAR2
           ,x_msg_count             OUT NOCOPY NUMBER
           ,x_msg_data              OUT NOCOPY NUMBER
           );

  PROCEDURE get_msn_attributes_structure(
            x_attributes        IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
           ,x_attributes_count     OUT NOCOPY NUMBER
           ,x_return_status        OUT NOCOPY VARCHAR2
           ,x_msg_count            OUT NOCOPY NUMBER
           ,x_msg_data             OUT NOCOPY NUMBER
           );

  PROCEDURE get_msn_attributes(
            x_attribute_values   IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
           ,x_attribute_prompts  IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
           ,x_attributes_count      OUT NOCOPY NUMBER
           ,x_return_status         OUT NOCOPY VARCHAR2
           ,x_msg_count             OUT NOCOPY NUMBER
           ,x_msg_data              OUT NOCOPY NUMBER
           );

  FUNCTION GET_ITEM(									-- Bug 6350236 Starting
	    P_ITEM_ID	IN	NUMBER	DEFAULT NULL
	   ,P_ORG_ID	IN	NUMBER	DEFAULT NULL
	   ) RETURN VARCHAR2;								-- Bug 6350236 Ending

END inv_mwb_tree1;

 

/
