--------------------------------------------------------
--  DDL for Package AMW_SIGNIFICANT_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_SIGNIFICANT_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: amwvsigs.pls 120.0 2005/05/31 23:13:29 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_SIGNIFICANT_ELEMENTS_PKG
-- Purpose
--
-- History
-- 		  	12/18/2003    tsho     Creates
-- ===============================================================



-- ===============================================================
-- Function name
--          ELEMENT_PRESENT
-- Purpose
-- 		  	return 'Y' if there's element for the specified object_id;
--          return 'N' otherwise.
-- ===============================================================
FUNCTION ELEMENT_PRESENT (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_ELEMENT_CODE IN VARCHAR2
) RETURN VARCHAR2;


-- ===============================================================
-- Procedure name
--          PROCESS_ELEMENTS
-- Purpose
-- 		  	update the elements for specified object_id
-- Notes
--          OBJECT_TYPE = 'PROCESS' with PK1 = PROCESS_REV_ID
--          OBJECT_TYPE = 'PROCESS_ORG' with PK1 = PROCESS_ORGANIZATION_ID
-- ===============================================================
PROCEDURE PROCESS_ELEMENTS (
    p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
    p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
    p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
    p_select_flag         IN         VARCHAR2,
    p_object_id           IN         NUMBER,
    p_object_type         IN         VARCHAR2,
    p_element_code        IN         VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
);

-- ===============================================================
-- Function name
--          ELEMENT_PRESENT_IN_LATEST
-- Purpose
--          return 'Y' if there's element for the specified object_id;
--          return 'N' otherwise.
-- Created  nirmakum
-- Reason   AMW.D, for knowing if there is a latest association of a significant element
--                 to a process
-- ===============================================================

FUNCTION ELEMENT_PRESENT_IN_LATEST (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_ELEMENT_CODE IN VARCHAR2
    ) RETURN VARCHAR2;
-- ----------------------------------------------------------------------
-- ===============================================================
-- Function name
--          ELEMENT_PRESENT_IN_REVISION
-- Purpose
--          return 'Y' if there's element for the specified object_id;
--          return 'N' otherwise.
-- Created  kosriniv
-- Reason   AMW.D, for knowing if there is an association of a significant element
--                 to a process revision
-- ===============================================================
FUNCTION ELEMENT_PRESENT_IN_REVISION (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_ELEMENT_CODE IN VARCHAR2
    ) RETURN VARCHAR2;
-- --------------------------------------------------------------------------------
END  AMW_SIGNIFICANT_ELEMENTS_PKG;

 

/
