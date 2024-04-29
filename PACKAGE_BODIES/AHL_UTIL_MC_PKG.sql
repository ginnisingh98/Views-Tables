--------------------------------------------------------
--  DDL for Package Body AHL_UTIL_MC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UTIL_MC_PKG" AS
/* $Header: AHLUMCB.pls 120.0 2005/05/26 11:00:32 appldev noship $ */

G_TRUNC_DATE 	CONSTANT 	DATE 		:= TRUNC(SYSDATE);

----------------------------------------------------
-- Function to validate existence of lookup code  --
----------------------------------------------------
Function Validate_Lookup_Code
(
	p_lookup_type  IN  VARCHAR2,
	p_lookup_code  IN  VARCHAR2
)
RETURN BOOLEAN
IS

	CURSOR fnd_lookup_csr
	(
		p_lookup_type IN VARCHAR2,
		p_lookup_code  IN  VARCHAR2
	)
	IS
	SELECT 	'x'
	FROM 	FND_LOOKUPS
	WHERE 	lookup_type = p_lookup_type AND
		lookup_code = p_lookup_code AND
		G_TRUNC_DATE between TRUNC(NVL(start_date_active, SYSDATE)) AND TRUNC(NVL(end_date_active, SYSDATE+1));

	l_dummy  VARCHAR2(1);
	l_return_val BOOLEAN DEFAULT TRUE;

BEGIN

	OPEN fnd_lookup_csr (p_lookup_type, p_lookup_code);
	FETCH fnd_lookup_csr INTO l_dummy;
	IF (fnd_lookup_csr%NOTFOUND)
	THEN
		l_return_val := FALSE;
	END IF;
	CLOSE fnd_lookup_csr;

	RETURN l_return_val;

END Validate_LOOKUP_Code;

-------------------------------------------------------
-- Procedure to return lookup code given the meaning --
-------------------------------------------------------
PROCEDURE Convert_To_LookupCode
(
	p_lookup_type     IN   VARCHAR2,
	p_lookup_meaning  IN   VARCHAR2,
	x_lookup_code     OUT  NOCOPY VARCHAR2,
	x_return_val      OUT  NOCOPY BOOLEAN
)
IS

	CURSOR fnd_lookup_csr
	(
		p_lookup_type     IN  VARCHAR2,
		p_lookup_meaning  IN  VARCHAR2
	)
	IS
	SELECT 	lookup_code
	FROM 	fnd_lookups
	WHERE 	lookup_type = p_lookup_type AND
		upper(meaning) = upper(p_lookup_meaning) AND
		G_TRUNC_DATE between TRUNC(NVL(start_date_active, SYSDATE)) AND TRUNC(NVL(end_date_active, SYSDATE+1));

	l_lookup_code   	fnd_lookups.lookup_code%TYPE DEFAULT NULL;
	l_dummy_code   		fnd_lookups.lookup_code%TYPE DEFAULT NULL;
	l_return_val    	BOOLEAN  DEFAULT  TRUE;

BEGIN

	OPEN fnd_lookup_csr (p_lookup_type, p_lookup_meaning);
	FETCH  fnd_lookup_csr INTO l_lookup_code;
	-- Compare upper(lookup_meaning) with upper(user keyed-in text)
	-- If more than one found, then force user to navigate through LOV
	-- Else If only one found, then use the same
	IF (fnd_lookup_csr%NOTFOUND)
	THEN
		l_return_val := FALSE;
		l_lookup_code := NULL;
	ELSE
		FETCH fnd_lookup_csr INTO l_dummy_code;
		IF (fnd_lookup_csr%FOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL', 'AHL_COM_TOO_MANY_LOOKUP');
			FND_MESSAGE.Set_Token('FIELD', p_lookup_meaning);
			FND_MSG_PUB.ADD;
			CLOSE fnd_lookup_csr;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;
	CLOSE fnd_lookup_csr;

	x_lookup_code := l_lookup_code;
	x_return_val  := l_return_val;

END Convert_To_LookupCode;

--------------------------------------------------------
-- Procedure to return lookup meaning given the code --
--------------------------------------------------------
PROCEDURE Convert_To_LookupMeaning
(
	p_lookup_type     IN   VARCHAR2,
	p_lookup_code     IN   VARCHAR2,
	x_lookup_meaning  OUT  NOCOPY VARCHAR2,
	x_return_val      OUT  NOCOPY BOOLEAN
)
IS

	CURSOR fnd_lookup_csr
	(
		p_lookup_type     IN  VARCHAR2,
		p_lookup_code     IN  VARCHAR2
	)
	IS
	SELECT 	meaning
	FROM 	fnd_lookups
	WHERE 	lookup_type = p_lookup_type AND
		lookup_code = p_lookup_code AND
		G_TRUNC_DATE between TRUNC(NVL(start_date_active, SYSDATE)) AND TRUNC(NVL(end_date_active, SYSDATE+1));

	l_lookup_meaning	fnd_lookups.meaning%TYPE DEFAULT NULL;
	l_return_val      	BOOLEAN  DEFAULT  TRUE;

BEGIN

	OPEN fnd_lookup_csr(p_lookup_type, p_lookup_code);
	FETCH fnd_lookup_csr INTO l_lookup_meaning;
	IF (fnd_lookup_csr%NOTFOUND)
	THEN
		l_return_val := FALSE;
		l_lookup_meaning := NULL;
	END IF;
	CLOSE fnd_lookup_csr;
	x_lookup_meaning := l_lookup_meaning;
	x_return_val  := l_return_val;

END  Convert_To_LookupMeaning;

--------------------------------------
-- Procedure to validate Item group --
--------------------------------------
PROCEDURE Validate_Item_Group
(
	p_item_group_id  IN  NUMBER,
	x_return_val     OUT NOCOPY BOOLEAN
)
IS

	CURSOR Item_group_csr
	(
		p_item_group_id IN VARCHAR2
	)
	IS
	SELECT 	'x'
	FROM 	ahl_item_groups_b
	WHERE 	item_group_id = p_item_group_id;

	l_dummy   	VARCHAR2(1);
	l_return_val  	BOOLEAN DEFAULT TRUE;

BEGIN

	OPEN Item_group_csr(p_item_group_id);
	FETCH Item_group_csr INTO l_dummy;
	IF (Item_group_csr%NOTFOUND)
	THEN
		l_return_val := FALSE;
		FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_INVALID');
		FND_MESSAGE.Set_Token('ITEM_GRP',p_item_group_id);
		FND_MSG_PUB.ADD;
	END IF;
	CLOSE Item_group_csr;
	x_return_val := l_return_val;

END Validate_Item_Group;

----------------------------------------------------
-- Procedure to check existence of a relationship --
-- and if found, returns the position_ref_code    --
----------------------------------------------------
Procedure Validate_Relationship
(
	p_relationship_id   IN   NUMBER,
	x_position_ref_code OUT NOCOPY VARCHAR2,
	x_return_val        OUT NOCOPY BOOLEAN
)
IS

	CURSOR l_ahl_relationship_csr
	(
		p_relationship_id IN NUMBER
	)
	IS
	SELECT 	position_ref_code
	FROM   	ahl_mc_relationships
	WHERE 	relationship_id = p_relationship_id AND
		-- Since positions with active_start_date > sysdate are also displayed in the MC tree, no need to check for active_start_date
		-- G_TRUNC_DATE between TRUNC(NVL(active_start_date, SYSDATE)) AND TRUNC(NVL(active_end_date, SYSDATE+1));
		G_TRUNC_DATE <= TRUNC(NVL(active_end_date, SYSDATE+1));

	l_position_ref_code  	ahl_mc_relationships.position_ref_code%TYPE DEFAULT NULL;
	l_return_val  		BOOLEAN DEFAULT TRUE;

BEGIN

	OPEN l_ahl_relationship_csr(p_relationship_id);
	FETCH l_ahl_relationship_csr INTO l_position_ref_code;
	IF (l_ahl_relationship_csr%NOTFOUND)
	THEN
		l_return_val := FALSE;
		x_position_ref_code := NULL;
	ELSE
		x_position_ref_code := l_position_ref_code;
	END IF;
	CLOSE l_ahl_relationship_csr;
	x_return_val := l_return_val;

END Validate_Relationship;

-----------------------------------------------------
-- Procedure to validate existence of relationship --
-----------------------------------------------------
Procedure Validate_Relationship
(
	p_relationship_id   IN   NUMBER,
	x_return_val        OUT NOCOPY BOOLEAN
)
IS

	CURSOR l_ahl_relationship_csr
	(
		p_relationship_id IN NUMBER
	)
	IS
	SELECT 	'x'
	FROM   	ahl_mc_relationships
	WHERE 	relationship_id = p_relationship_id AND
		-- Since positions with active_start_date > sysdate are also displayed in the MC tree, no need to check for active_start_date
		-- G_TRUNC_DATE between TRUNC(NVL(active_end_date, SYSDATE)) AND TRUNC(NVL(active_end_date, SYSDATE+1));
		G_TRUNC_DATE <= TRUNC(NVL(active_end_date, SYSDATE+1));

	l_dummy                VARCHAR2(1);
	l_return_val          BOOLEAN DEFAULT TRUE;

BEGIN

	OPEN l_ahl_relationship_csr(p_relationship_id);
	FETCH l_ahl_relationship_csr INTO l_dummy;
	IF (l_ahl_relationship_csr%NOTFOUND)
	THEN
		l_return_val := FALSE;
	END IF;
	CLOSE l_ahl_relationship_csr;
	x_return_val := l_return_val;

END Validate_Relationship;

END AHL_UTIL_MC_PKG;

/
