--------------------------------------------------------
--  DDL for Package INV_MWB_GRADE_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_GRADE_TREE" AUTHID CURRENT_USER AS
/* $Header: INVMWGRS.pls 120.2 2005/06/22 04:46:09 aalex noship $ */
   PROCEDURE event  (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           );
END INV_MWB_GRADE_TREE;

 

/
