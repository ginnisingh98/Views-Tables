--------------------------------------------------------
--  DDL for Package INV_MWB_SERIAL_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_SERIAL_TREE" AUTHID CURRENT_USER AS
/* $Header: INVMWSES.pls 120.1 2005/06/21 05:41:21 aalex noship $ */

   PROCEDURE event (
             x_node_value IN OUT NOCOPY NUMBER
           , x_node_tbl   IN OUT NOCOPY fnd_apptree.node_tbl_type
           , x_tbl_index  IN OUT NOCOPY NUMBER
           );

END INV_MWB_SERIAL_TREE;

 

/
