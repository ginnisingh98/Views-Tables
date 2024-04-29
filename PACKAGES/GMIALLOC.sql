--------------------------------------------------------
--  DDL for Package GMIALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIALLOC" AUTHID CURRENT_USER as
-- $Header: gmialocs.pls 115.3 2004/03/15 20:10:52 jsrivast noship $

/* ===========================================================
   This package is only for the use of Inventory module
   and will be used for validating/updating the pending
   transactions which will be drawing from the inventory when
   there is a mass move immediate or move immediate
   Jalaj Srivastava Bug 3282770
     Modified signatures of procedures update_pending_allocations
     and CHECK_ALLOC_QTY.
     Added procedure VALIDATE_MOVEALLOC_FORMASSMOVE.
   =========================================================== */

procedure update_pending_allocations
  ( p_api_version          IN               NUMBER
   ,p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT NOCOPY       VARCHAR2
   ,x_msg_count            OUT NOCOPY       NUMBER
   ,x_msg_data             OUT NOCOPY       VARCHAR2
   ,pdoc_id                IN               NUMBER
   ,pto_whse_code          IN               VARCHAR2
   ,pto_location           IN               VARCHAR2
  );

procedure CHECK_ALLOC_QTY
  ( p_api_version          IN               NUMBER
   ,p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT NOCOPY       VARCHAR2
   ,x_msg_count            OUT NOCOPY       NUMBER
   ,x_msg_data             OUT NOCOPY       VARCHAR2
   ,pfrom_whse_code        IN               VARCHAR2
   ,pfrom_location         IN               VARCHAR2
   ,plot_id                IN               NUMBER
   ,pitem_id               IN               NUMBER
   ,pmove_qty              IN               NUMBER
   ,pto_whse_code          IN               VARCHAR2
   ,x_move_allocations     OUT NOCOPY       VARCHAR2
  );

PROCEDURE VALIDATE_MOVEALLOC_FORMASSMOVE
  ( p_api_version          IN               NUMBER
   ,p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
   ,p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT NOCOPY       VARCHAR2
   ,x_msg_count            OUT NOCOPY       NUMBER
   ,x_msg_data             OUT NOCOPY       VARCHAR2
   ,pfrom_whse_code        IN               VARCHAR2
   ,pto_whse_code          IN               VARCHAR2
   ,pjournal_id            IN               NUMBER
  );


END GMIALLOC;

 

/
