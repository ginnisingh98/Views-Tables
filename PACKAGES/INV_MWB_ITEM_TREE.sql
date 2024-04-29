--------------------------------------------------------
--  DDL for Package INV_MWB_ITEM_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_ITEM_TREE" AUTHID CURRENT_USER AS
/* $Header: INVMWITS.pls 120.3 2008/01/10 22:59:36 musinha ship $ */
   PROCEDURE event  (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           );

   PROCEDURE make_common_queries(p_flag VARCHAR2); -- Bug 6060233

END INV_MWB_ITEM_TREE;

/
