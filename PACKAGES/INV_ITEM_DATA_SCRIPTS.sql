--------------------------------------------------------
--  DDL for Package INV_ITEM_DATA_SCRIPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_DATA_SCRIPTS" AUTHID CURRENT_USER AS
/* $Header: INVIDSES.pls 120.0.12010000.2 2010/03/23 15:18:41 kjonnala noship $ */

/* Main procedure that gets called from the concurrent program
  'Items Data Scripts Execution' (INVIDSEP)*/
PROCEDURE run_data_scripts(
              errbuf  OUT NOCOPY VARCHAR2,
              retcode OUT NOCOPY NUMBER);


/* Procedure to modify internal_ordered_flag, internal_order_enabled flag and shippable flag.
   This datafix was originally given through bug 7572178 (datafix) and was necessiated
   due to the functional change introduced through bug 5533216 */
PROCEDURE proc_io_shippable_flags(
              errbuf  OUT NOCOPY VARCHAR2,
              retcode OUT NOCOPY NUMBER);

END INV_ITEM_DATA_SCRIPTS;

/
