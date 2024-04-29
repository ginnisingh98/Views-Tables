--------------------------------------------------------
--  DDL for Package INV_MWB_STATUS_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_STATUS_TREE" AUTHID CURRENT_USER AS
/* $Header: INVMWSTS.pls 120.2.12000000.1 2007/01/17 16:23:50 appldev ship $ */
   PROCEDURE event  (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           );
END INV_MWB_STATUS_TREE;

 

/
