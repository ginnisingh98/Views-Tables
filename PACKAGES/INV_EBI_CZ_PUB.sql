--------------------------------------------------------
--  DDL for Package INV_EBI_CZ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EBI_CZ_PUB" AUTHID CURRENT_USER AS
/* $Header: INVEIPCZS.pls 120.0.12010000.1 2009/07/08 08:18:24 smukka noship $ */

PROCEDURE process_init_msg(
   p_profile_name        IN           VARCHAR2
  ,p_inventory_item_id   IN           NUMBER
  ,p_organization_id     IN           NUMBER
  ,x_profile_value       OUT NOCOPY   VARCHAR2
  ,x_database_id         OUT NOCOPY   VARCHAR2
  ,x_system_id           OUT NOCOPY   VARCHAR2
  ,x_return_status       OUT NOCOPY   VARCHAR2
  ,x_msg_count           OUT NOCOPY   NUMBER
  ,x_msg_data            OUT NOCOPY   VARCHAR2

 );

END INV_EBI_CZ_PUB;


/
