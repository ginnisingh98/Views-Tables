--------------------------------------------------------
--  DDL for Package INV_MWB_LOCATION_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_LOCATION_TREE" AUTHID CURRENT_USER AS
/* $Header: INVMWLES.pls 120.6 2008/01/10 23:41:29 musinha ship $ */

   PROCEDURE event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           );

   PROCEDURE make_common_query_onhand(p_flag VARCHAR2); -- Bug 6060233

END inv_mwb_location_tree;

/
