--------------------------------------------------------
--  DDL for Package OE_INC_ITEMS_FREEZE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INC_ITEMS_FREEZE_CONC" AUTHID CURRENT_USER AS
/* $Header: OEXCFIIS.pls 120.1 2005/06/11 23:54:15 appldev  $ */


PROCEDURE Request
( ERRBUF                 OUT  NOCOPY VARCHAR2
 ,RETCODE                OUT  NOCOPY VARCHAR2
 -- Moac
 ,p_org_id               IN          NUMBER
 ,p_order_num_low        IN          NUMBER
 ,p_order_num_high       IN          NUMBER
 ,p_inventory_item_id    IN          NUMBER
 ,p_schedule_date_low    IN          VARCHAR2
 ,p_schedule_date_high   IN          VARCHAR2
 ,p_num_of_days          IN          NUMBER
 ,p_ship_set_id          IN          NUMBER
);

END OE_INC_ITEMS_FREEZE_CONC;

 

/
