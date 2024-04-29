--------------------------------------------------------
--  DDL for Package INV_RSV_TRIGGER_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RSV_TRIGGER_GLOBAL" AUTHID CURRENT_USER AS
/* $Header: INVRSVTS.pls 120.0 2005/05/25 05:17:32 appldev noship $ */

 /*
 ** To keep reservation data in MTL_DEMAND and MTL_RESERVATIONS synchronised,
 ** triggers/procedures are employed on either tables.
 ** (MTL_DEMAND - Trigger; MTL_RESERVATIONS - Procedures;)
 **
 ** To prevent unwanted firing of the triggers the global variable will be set
 ** to true.
 */

 g_from_trigger             BOOLEAN := FALSE ;

end inv_rsv_trigger_global;

 

/
