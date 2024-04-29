--------------------------------------------------------
--  DDL for Package INV_GENEALOGY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_GENEALOGY_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPVCGS.pls 120.4.12000000.1 2007/01/17 16:27:14 appldev ship $ */

-------------------------------------------------------------------------------
-- Global Constants for FND values used in initialization of parameters
-------------------------------------------------------------------------------

 gen_fnd_g_false                CONSTANT VARCHAR2(1)  := FND_API.G_FALSE;
 gen_fnd_valid_level_full       CONSTANT NUMBER       := FND_API.G_VALID_LEVEL_FULL;

-------------------------------------------------------------------------------
-- Global Constants: Genealogy Object Types
-------------------------------------------------------------------------------
GEN_OBJ_TYPE_LOT        CONSTANT NUMBER     := 1;
GEN_OBJ_TYPE_SERIAL     CONSTANT NUMBER     := 2;
GEN_OBJ_TYPE_EXTERNAL   CONSTANT NUMBER     := 3;
GEN_OBJ_TYPE_CONTAINER  CONSTANT NUMBER     := 4;
GEN_OBJ_TYPE_LOTJOB     CONSTANT NUMBER     := 5;

-------------------------------------------------------------------------------
-- Global Constants: Genealogy Origin
-------------------------------------------------------------------------------
GEN_ORIGIN_INV     CONSTANT NUMBER     := 1;
GEN_ORIGIN_WIP     CONSTANT NUMBER     := 2;

-------------------------------------------------------------------------------
-- Global Constants: Genealogy Types
-------------------------------------------------------------------------------
GEN_TYPE_ASSM_COMP          CONSTANT NUMBER     := 1;
GEN_TYPE_SUBLOT             CONSTANT NUMBER     := 4;
GEN_TYPE_EAM                CONSTANT NUMBER     := 5;


----------------------------------
-- table and record
----------------------------------

type object_id_rec_t IS RECORD(object_id NUMBER, start_date_active DATE, end_date_active DATE);
type object_id_tbl_t IS TABLE OF object_id_rec_t INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- Procedures and Functions
-------------------------------------------------------------------------------
-- Start of comments
--	API name 	: populate_genealogy
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Validates and creates a record in MTL_OBJECT_GENEALOGY
--                with the parameters passed.
--	Parameters	:
--	IN		:	p_api_version           IN        NUMBER          Required
--              p_init_msg_list         IN        VARCHAR2
--              p_commit                IN        VARCHAR2
--              p_validation_level      IN        NUMBER
--              p_object_type           IN        NUMBER          Required
--                                    Type of the object (1-Lot or 2-Serial)
--              p_parent_object_type    IN        NUMBER          Required
--                                    Type of the parent object
--                                     (1-Lot or 2-Serial)
--              p_object_id			    IN        NUMBER
--									  Genealogy object id.
--                      Either p_object_id or (p_object_number,
--                      p_inventory_item_id and p_org_id) is mandatory.
--              p_object_number         IN        VARCHAR2
--                                    Lot Number or Serial Number or the child
--              p_inventory_item_id     IN  NUMBER
--              					  Inventory Item id.
--              p_org_id                IN  NUMBER
--              					  Organization id.
--              p_parent_object_id	    IN        NUMBER
--                                    Genealogy object id.
--              p_parent_object_number  IN        VARCHAR2
--                                    Parent Lot Number or Parent Serial Number
--              p_parent_inventory_item_id  IN  NUMBER
--                                    Inventory Item id.
--              p_parent_org_id         IN  NUMBER
--                                    Organization id.
--              p_genealogy_origin      IN        NUMBER
--                                    The origin of the genealogy, could be
--                                    WIP or INV Transactions
--              p_genealogy_type        IN        NUMBER
--                                    Could be
--                                       1-  Assembly component
--                                       2-  Lot split
--                                       3-  Lot merge
--              p_origin_txn_id         IN        NUMBER          Required
--                                    If origin of the genealogy is passed then
--                                    this should have the id of the WIP or INV
--                                    transaction
--	OUT    :    x_return_status         OUT        VARCHAR2
--                                         Return Status
--              x_msg_count             OUT        NUMBER
--              x_msg_data              OUT        VARCHAR2
--
--	Version	: Current version	1.0
--			  Initial version 	1.0
--
-- End of comments
PROCEDURE insert_genealogy
(    p_api_version                   IN  NUMBER
 ,   p_init_msg_list	             IN  VARCHAR2 := gen_fnd_g_false
 ,   p_commit		             IN  VARCHAR2 := gen_fnd_g_false
 ,   p_validation_level	             IN  NUMBER   := gen_fnd_valid_level_full
 ,   p_object_type                   IN  NUMBER
 ,   p_parent_object_type            IN  NUMBER   := NULL
 ,   p_object_id		     IN  NUMBER   := NULL
 ,   p_object_number                 IN  VARCHAR2 := NULL
 ,   p_inventory_item_id	     IN  NUMBER   := NULL
 ,   p_org_id			     IN  NUMBER   := NULL
 ,   p_parent_object_id	             IN  NUMBER   := NULL
 ,   p_parent_object_number          IN  VARCHAR2 := NULL
 ,   p_parent_inventory_item_id	     IN  NUMBER   := NULL
 ,   p_parent_org_id		     IN  NUMBER   := NULL
 ,   p_genealogy_origin              IN  NUMBER   := NULL
 ,   p_genealogy_type                IN  NUMBER   := NULL
 ,   p_start_date_active             IN  DATE     := SYSDATE
 ,   p_end_date_active               IN  DATE     := NULL
 ,   p_origin_txn_id                 IN  NUMBER   := NULL
 ,   p_update_txn_id                 IN  NUMBER   := NULL
 ,   x_return_status                 OUT NOCOPY VARCHAR2
 ,   x_msg_count                     OUT NOCOPY NUMBER
 ,   x_msg_data                      OUT NOCOPY VARCHAR2
 ,   p_object_type2                  IN  NUMBER   := NULL    -- R12
 ,   p_object_id2                    IN  NUMBER   := NULL    -- R12
 ,   p_object_number2                IN  VARCHAR2 := NULL    -- R12
 ,   p_parent_object_type2           IN  NUMBER   := NULL    -- R12
 ,   p_parent_object_id2             IN  NUMBER   := NULL    -- R12
 ,   p_parent_object_number2         IN  VARCHAR2 := NULL    -- R12
 ,   p_child_lot_control_code        IN  NUMBER   := NULL    -- R12
 ,   p_parent_lot_control_code       IN  NUMBER   := NULL    -- R12
);

PROCEDURE update_genealogy
(    p_api_version                   IN  NUMBER
 ,   p_init_msg_list                 IN  VARCHAR2 := gen_fnd_g_false
 ,   p_commit                        IN  VARCHAR2 := gen_fnd_g_false
 ,   p_validation_level              IN  NUMBER   := gen_fnd_valid_level_full
 ,   p_object_type                   IN  NUMBER
 ,   p_object_id                     IN  NUMBER   := NULL
 ,   p_object_number                 IN  VARCHAR2 := NULL
 ,   p_inventory_item_id             IN  NUMBER   := NULL
 ,   p_org_id                        IN  NUMBER   := NULL
 ,   p_genealogy_origin              IN  NUMBER   := NULL
 ,   p_genealogy_type                IN  NUMBER   := NULL
 ,   p_end_date_active               IN  DATE     := NULL
 ,   p_update_txn_id                 IN  NUMBER   := NULL
 ,   x_return_status                 OUT NOCOPY VARCHAR2
 ,   x_msg_count                     OUT NOCOPY NUMBER
 ,   x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE insert_flow_genealogy
(    p_api_version		     IN NUMBER
 ,   p_init_msg_list		     IN VARCHAR2  := gen_fnd_g_false
 ,   p_commit			     IN VARCHAR2  := gen_fnd_g_false
 ,   p_validation_level		     IN NUMBER    := gen_fnd_valid_level_full
 ,   p_transaction_source_id	     IN NUMBER
 ,   p_completion_transaction_id     IN NUMBER
 ,   p_parent_object_id              IN  NUMBER   := NULL
 ,   p_parent_object_number          IN  VARCHAR2 := NULL
 ,   p_parent_inventory_item_id      IN  NUMBER   := NULL
 ,   p_parent_org_id                 IN  NUMBER   := NULL
 ,   p_genealogy_origin              IN  NUMBER   := NULL
 ,   p_genealogy_type                IN  NUMBER   := NULL
 ,   p_start_date_active             IN  DATE     := sysdate
 ,   p_end_date_active               IN  DATE     := NULL
 ,   p_origin_txn_id                 IN  NUMBER   := NULL
 ,   p_update_txn_id                 IN  NUMBER   := NULL
 ,   x_return_status                 OUT NOCOPY VARCHAR2
 ,   x_msg_count                     OUT NOCOPY NUMBER
 ,   x_msg_data                      OUT NOCOPY VARCHAR2
);



PROCEDURE DELETE_EAM_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := gen_fnd_g_false,
  P_COMMIT                       IN VARCHAR2 := gen_fnd_g_false,
  P_VALIDATION_LEVEL             IN NUMBER   := gen_fnd_valid_level_full,
  P_OBJECT_ID                    IN NUMBER,
  P_START_DATE_ACTIVE		 IN DATE,
  P_END_DATE_ACTIVE		 IN DATE,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2);

PROCEDURE update_genealogy(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := gen_fnd_g_false
  , p_commit                   IN            VARCHAR2 := gen_fnd_g_false
  , p_validation_level         IN            NUMBER   := gen_fnd_valid_level_full
  , p_object_type              IN            NUMBER
  , p_parent_object_type       IN            NUMBER   := NULL
  , p_object_id                IN            NUMBER   := NULL
  , p_object_number            IN            VARCHAR2 := NULL
  , p_inventory_item_id        IN            NUMBER   := NULL
  , p_organization_id          IN            NUMBER   := NULL
  , p_parent_object_id         IN            NUMBER   := NULL
  , p_parent_object_number     IN            VARCHAR2 := NULL
  , p_parent_inventory_item_id IN            NUMBER   := NULL
  , p_parent_org_id            IN            NUMBER   := NULL
  , p_genealogy_origin         IN            NUMBER   := NULL
  , p_genealogy_type           IN            NUMBER   := NULL
  , p_start_date_active        IN            DATE     := SYSDATE
  , p_end_date_active          IN            DATE     := NULL
  , p_origin_txn_id            IN            NUMBER   := NULL
  , p_update_txn_id            IN            NUMBER   := NULL
  , p_object_type2             IN            NUMBER   := NULL
  , p_object_id2               IN            NUMBER   := NULL
  , p_object_number2           IN            VARCHAR2 := NULL
  , p_parent_object_type2      IN            NUMBER   := NULL
  , p_parent_object_id2        IN            NUMBER   := NULL
  , p_parent_object_number2    IN            VARCHAR2 := NULL
  , p_child_lot_control_code   IN            NUMBER   := NULL
  , p_parent_lot_control_code  IN            NUMBER   := NULL
  , p_transaction_type         IN            VARCHAR2 := NULL    -- ASSEMBLY_RETURN, COMP_RETURN, NULL
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
);
-- 2/2/06: Bug: 4997221 : Added new parameter p_transaction_type

END INV_genealogy_PUB;

 

/
