--------------------------------------------------------
--  DDL for Package AHL_UTIL_MC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UTIL_MC_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLUMCS.pls 115.6 2003/07/31 14:07:41 tamdas noship $ */

----------------------------------------------------
-- Function to validate existence of lookup code  --
----------------------------------------------------
Function  Validate_Lookup_Code
(
	p_lookup_type  IN  VARCHAR2,
	p_lookup_code  IN  VARCHAR2
)
RETURN BOOLEAN;

-------------------------------------------------------
-- Procedure to return lookup meaning given the code --
-------------------------------------------------------
PROCEDURE Convert_To_LookupMeaning
(
	p_lookup_type     IN   VARCHAR2,
	p_lookup_code     IN   VARCHAR2,
	x_lookup_meaning  OUT  NOCOPY VARCHAR2,
	x_return_val      OUT  NOCOPY BOOLEAN
);

--------------------------------------------------------
-- Procedure to return lookup code  given the meaning --
--------------------------------------------------------
PROCEDURE Convert_To_LookupCode
(
	p_lookup_type     IN   VARCHAR2,
	p_lookup_meaning  IN   VARCHAR2,
	x_lookup_code     OUT  NOCOPY VARCHAR2,
	x_return_val      OUT  NOCOPY BOOLEAN
);

-----------------------------------------------------
-- Procedure to validate existence of relationship --
-----------------------------------------------------
Procedure Validate_Relationship
(
	p_relationship_id IN   NUMBER,
	x_return_val      OUT  NOCOPY BOOLEAN
);

----------------------------------------------------
-- Procedure to check existence of a relationship --
-- and if found, returns the position_ref_code    --
----------------------------------------------------
Procedure Validate_Relationship
(
	p_relationship_id    IN   NUMBER,
	x_position_ref_code  OUT  NOCOPY VARCHAR2,
	x_return_val         OUT  NOCOPY BOOLEAN
);

--------------------------------------
-- Procedure to validate Item group --
--------------------------------------
PROCEDURE Validate_Item_Group
(
	p_item_group_id  IN  NUMBER,
	x_return_val     OUT NOCOPY BOOLEAN
);

END AHL_UTIL_MC_PKG;

 

/
