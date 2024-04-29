--------------------------------------------------------
--  DDL for Package AHL_FMP_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_COMMON_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVFCMS.pls 120.0.12010000.3 2009/09/22 21:26:52 sikumar ship $ */

-- Start of Comments
-- Procedure name              : validate_lookup
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_lookup IN parameters:
--      p_lookup_type               VARCHAR2   Required
--      p_lookup_meaning            VARCHAR2   Default NULL
--
-- validate_lookup IN OUT parameters:
--      p_x_lookup_code             VARCHAR2
--
-- validate_lookup OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_lookup
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_lookup_type          IN            FND_LOOKUPS.lookup_type%TYPE,
  p_lookup_meaning       IN            FND_LOOKUPS.meaning%TYPE,
  p_x_lookup_code        IN OUT NOCOPY FND_LOOKUPS.lookup_code%TYPE
);

-- Start of Comments
-- Procedure name              : validate_item
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_item IN parameters:
--      p_item_number               VARCHAR2   Default NULL
--
-- validate_item IN OUT parameters:
--      p_x_inventory_item_id       NUMBER
--
-- validate_item OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_item
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_item_number          IN            MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.inventory_item_id%TYPE
);

-- Start of Comments
-- Procedure name              : validate_pc_node
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_pc_node IN parameters:
--      p_pc_node_name              VARCHAR2   Default NULL
--
-- validate_pc_node IN OUT parameters:
--      p_x_pc_node_id              NUMBER
--
-- validate_pc_node OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_pc_node
(
 x_return_status      OUT NOCOPY    VARCHAR2,
 x_msg_data           OUT NOCOPY    VARCHAR2,
 p_pc_node_name       IN            VARCHAR2 := NULL,
 p_x_pc_node_id       IN OUT NOCOPY NUMBER
);

-- Start of Comments
-- Procedure name              : validate_position
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_position IN parameters:
--      p_position_ref_meaning      VARCHAR2   Default NULL
--
-- validate_position IN OUT parameters:
--      p_x_relationship_id         NUMBER
--
-- validate_position OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_position
(
 x_return_status           OUT NOCOPY    VARCHAR2,
 x_msg_data                OUT NOCOPY    VARCHAR2,
 p_position_ref_meaning    IN            VARCHAR2 := NULL,
 p_x_relationship_id       IN OUT NOCOPY NUMBER
);

-- Start of Comments
-- Procedure name              : validate_position_item
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_position_item IN parameters:
--      p_relationship_id           NUMBER     Required
--      p_inventory_item_id         NUMBER     Required
--
-- validate_position_item IN OUT parameters:
--      None.
--
-- validate_position OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_position_item
(
 x_return_status           OUT NOCOPY    VARCHAR2,
 x_msg_data                OUT NOCOPY    VARCHAR2,
 p_inventory_item_id       IN            NUMBER,
 p_relationship_id         IN            NUMBER
);

-- Start of Comments
-- Procedure name              : validate_counter_template
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_counter_template IN parameters:
--      p_inventory_item_id         NUMBER     Default NULL
--      p_relationship_id           NUMBER     Default NULL
--      p_counter_name              VARCHAR2   Default NULL
--
-- validate_counter_template IN OUT parameters:
--      p_x_counter_id              NUMBER
--
-- validate_counter_template OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_counter_template
(
 x_return_status       OUT NOCOPY    VARCHAR2,
 x_msg_data            OUT NOCOPY    VARCHAR2,
 p_inventory_item_id   IN            NUMBER := NULL,
 p_relationship_id     IN            NUMBER := NULL,
 p_counter_name        IN            VARCHAR2 := NULL,
 p_x_counter_id        IN OUT NOCOPY NUMBER
);

-- Start of Comments
-- Procedure name              : validate_country
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_country IN parameters:
--      p_country_name              VARCHAR2   Default NULL
--
-- validate_country IN OUT parameters:
--      p_x_country_code            VARCHAR2
--
-- validate_country OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_country
(
 x_return_status        OUT NOCOPY    VARCHAR2,
 x_msg_data             OUT NOCOPY    VARCHAR2,
 p_country_name         IN            VARCHAR2 := NULL,
 p_x_country_code       IN OUT NOCOPY VARCHAR2
);

-- Start of Comments
-- Procedure name              : validate_manufacturer
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_manufacturer IN parameters:
--      p_inventory_item_id         NUMBER     Default NULL
--      p_relationship_id           NUMBER     Default NULL
--      p_manufacturer_name         VARCHAR2   Default NULL
--
-- validate_manufacturer IN OUT parameters:
--      p_x_manufacturer_id         NUMBER
--
-- validate_manufacturer OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_manufacturer
(
 x_return_status          OUT NOCOPY    VARCHAR2,
 x_msg_data               OUT NOCOPY    VARCHAR2,
 p_inventory_item_id      IN            NUMBER := NULL,
 p_relationship_id        IN            NUMBER := NULL,
 p_manufacturer_name      IN            VARCHAR2 := NULL,
 p_x_manufacturer_id      IN OUT NOCOPY NUMBER
);

-- Start of Comments
-- Procedure name              : validate_serial_numbers_range
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_manufacturer IN parameters:
--      p_serial_number_from        VARCHAR2   Required
--      p_serial_number_to          VARCHAR2   Required
--
-- validate_serial_numbers_range IN OUT parameters:
--      None.
--
-- validate_serial_numbers_range OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_serial_numbers_range
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_serial_number_from           IN  VARCHAR2,
 p_serial_number_to             IN  VARCHAR2
);

-- Start of Comments
-- Procedure name              : validate_mr_status
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_mr_status IN parameters:
--      p_mr_header_id              NUMBER     Required
--
-- validate_mr_status IN OUT parameters:
--      None.
--
-- validate_mr_status OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_mr_status
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_header_id                 IN  NUMBER
);

-- Start of Comments
-- Procedure name              : validate_mr_effectivity
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_mr_effectivity IN parameters:
--      p_mr_effectivity_id         NUMBER     Required
--      p_object_version_number     NUMBER     Default NULL
--
-- validate_mr_effectivity IN OUT parameters:
--      None.
--
-- validate_mr_effectivity OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_mr_effectivity
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_effectivity_id            IN  NUMBER,
 p_object_version_number        IN  NUMBER := NULL
);

-- Start of Comments
-- Procedure name              : validate_mr_threshold
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_mr_threshold IN parameters:
--      p_mr_header_id              NUMBER     Required
--      p_repetitive_flag           VARCHAR2   Required
--
-- validate_mr_threshold IN OUT parameters:
--      None.
--
-- validate_mr_threshold OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_mr_interval_threshold
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_header_id                 IN  NUMBER,
 p_repetitive_flag              IN  VARCHAR2
);


----------------------------------------------------------
-- Procedure to populate the AHL_APPLICABLE_MRS temporary --
-- table with the results of AHL_FMP_PUB.GET_APPLICABLE_MRS--
-- API.
-----------------------------------------------------------
PROCEDURE Populate_Appl_MRs
(
 p_csi_ii_id           IN            NUMBER,
 p_include_doNotImplmt IN            VARCHAR2 := 'Y',
 x_return_status       OUT  NOCOPY   VARCHAR2,
 x_msg_count           OUT  NOCOPY   NUMBER,
 x_msg_data            OUT  NOCOPY   VARCHAR2
 );

-- Start of Comments
-- Procedure name              : Mr_Title_Version_To_Id
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--
-- mr_title_version_to_id IN parameters:
--  	p_mr_title		IN 		VARCHAR2 Required
--  	p_mr_version_number	IN 		NUMBER	 Required
--
-- mr_title_version_to_id IN OUT parameters:
--      None.
--
-- mr_title_version_to_id OUT parameters:
--      x_mr_header_id	OUT NOCOPY	NUMBER
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE Mr_Title_Version_To_Id
(
  p_mr_title		IN 		VARCHAR2,
  p_mr_version_number	IN 		NUMBER,
  x_mr_header_id	OUT NOCOPY	NUMBER,
  x_return_status 	OUT NOCOPY	VARCHAR2
);

-- Start of Comments
-- Procedure name              : Mr_Effectivity_Name_To_Id
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status         VARCHAR2	Required
--
-- mr_title_version_to_id IN parameters:
-- 	p_mr_header_id		NUMBER		Required
-- 	p_mr_effectivity_name	VARCHAR2	Required
--
-- mr_title_version_to_id IN OUT parameters:
--      None.
--
-- mr_title_version_to_id OUT parameters:
--      x_mr_effectivity_id    	NUMBER		Required

--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE Mr_Effectivity_Name_To_Id
(
  p_mr_header_id	IN		NUMBER,
  p_mr_effectivity_name	IN  		VARCHAR2,
  x_mr_effectivity_id   OUT NOCOPY 	NUMBER,
  x_return_status 	OUT NOCOPY	VARCHAR2
);


-- Start of Comments
-- Procedure name              :
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    : check_mr_type
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
--
-- check_mr_type IN parameters:
--      p_mr_header_id              NUMBER     Required
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments


function check_mr_type(  p_mr_header_id    IN         NUMBER ) return varchar2;


-- Start of Comments
-- Procedure name              :
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    : check_mr_status
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
--
-- check_mr_type IN parameters:
--      p_mr_header_id              NUMBER     Required
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments


function check_mr_status(  p_mr_header_id    IN         NUMBER ) return varchar2;

-- Start of Comments
-- Procedure name              : validate_mr_type_program
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_mr_status IN parameters:
--      p_effectivity_id             NUMBER     Required
--      p_eff_obj_version            NUMBER     Required
--      p_mr_header_id			 NUMBER     Required
-- validate_mr_status IN OUT parameters:
--      None.
--
-- validate_mr_status OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments


PROCEDURE validate_mr_type_program
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_header_id                 IN  NUMBER,
 p_effectivity_id               IN  NUMBER,
 p_eff_obj_version              IN  NUMBER
);

-- Start of Comments
-- Procedure name              : validate_mr_type_activity
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_mr_status IN parameters:
--      p_effectivity_id             NUMBER     Required
--      p_eff_obj_version            NUMBER     Required
-- validate_mr_status IN OUT parameters:
--      None.
--
-- validate_mr_status OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_mr_type_activity
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_effectivity_id               IN  NUMBER,
 p_eff_obj_version              IN  NUMBER
);

-- Start of Comments
-- Procedure name              : validate_mr_pm_status
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_mr_status IN parameters:
--      p_mr_header_id              NUMBER     Required
--
-- validate_mr_status IN OUT parameters:
--      None.
--
-- validate_mr_status OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_mr_pm_status
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_header_id                 IN  NUMBER
);

-- Start of Comments
-- Procedure name              : validate_owner
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_owner IN parameters:
--      p_inventory_item_id         NUMBER     Default NULL
--      p_relationship_id           NUMBER     Default NULL
--       p_owner         VARCHAR2   Default NULL
--
-- validate_manufacturer IN OUT parameters:
--      p_x_owner_id         NUMBER
--
-- validate_manufacturer OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_owner
(
 x_return_status          OUT NOCOPY    VARCHAR2,
 x_msg_data               OUT NOCOPY    VARCHAR2,
 p_owner                  IN            VARCHAR2 := NULL,
 p_x_owner_id             IN OUT NOCOPY NUMBER
);

-- Start of Comments
-- Procedure name              : validate_location
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_country IN parameters:
--      p_location              VARCHAR2   Default NULL
--
-- validate_location IN OUT parameters:
--      p_x_location_type_code            VARCHAR2
--
-- validate_country OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_location
(
 x_return_status        OUT NOCOPY    VARCHAR2,
 x_msg_data             OUT NOCOPY    VARCHAR2,
 p_location         IN            VARCHAR2 := NULL,
 p_x_location_type_code       IN OUT NOCOPY VARCHAR2
);

-- Start of Comments
-- Procedure name              : validate_csi_ext_attribute
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_country IN parameters:
--      p_csi_attribute_name              VARCHAR2   Default NULL
--
-- validate_country IN OUT parameters:
--      p_x_csi_attribute_code            VARCHAR2
--
-- validate_csi_ext_attribute OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_csi_ext_attribute
(
 x_return_status        OUT NOCOPY    VARCHAR2,
 x_msg_data             OUT NOCOPY    VARCHAR2,
 p_csi_attribute_name         IN            VARCHAR2 := NULL,
 p_x_csi_attribute_code       IN OUT NOCOPY VARCHAR2
);


END AHL_FMP_COMMON_PVT;

/
