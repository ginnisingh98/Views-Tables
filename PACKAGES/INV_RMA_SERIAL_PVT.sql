--------------------------------------------------------
--  DDL for Package INV_RMA_SERIAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RMA_SERIAL_PVT" AUTHID CURRENT_USER AS
/* $Header: INVRMASS.pls 115.1 2004/04/22 11:57:16 aapaul noship $ */

--------------------------------------------------------------------
--Name : populate_temp_table
--
--Desc : procedure to populate temp table inv_rma_serial_temp
--       based on the rma_line_id.
--I/P  : p_rma_line_id - the RMA line id
--       p_org_id - Organization id
--       p_item_id - Inventory Item id
-------------------------------------------------------------------
-- Added below global variable for bug 3572112
g_return_status VARCHAR2(1);
g_error_code NUMBER;
g_rma_line_id NUMBER;
procedure populate_temp_table(
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2 DEFAULT FND_API.G_FALSE ,
   p_commit                     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_validation_level           IN   NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT  NOCOPY VARCHAR2,
   x_msg_count                  OUT  NOCOPY NUMBER,
   x_msg_data                   OUT  NOCOPY VARCHAR2,
   x_errorcode                  OUT  NOCOPY NUMBER,

   p_rma_line_id                IN   NUMBER,
   p_org_id                     IN   NUMBER,
   p_item_id                    IN   NUMBER);
-- Added the below function for the bug 3572112
function validate_serial_required(p_rma_line_id   IN  NUMBER) return NUMBER;

END INV_RMA_SERIAL_PVT;

 

/
