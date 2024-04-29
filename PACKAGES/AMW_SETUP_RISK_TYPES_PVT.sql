--------------------------------------------------------
--  DDL for Package AMW_SETUP_RISK_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_SETUP_RISK_TYPES_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvrtps.pls 120.0 2005/05/31 22:02:25 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_SETUP_RISK_TYPES_PVT
-- Purpose
-- 		  	for handling setup risk type actions
--
-- History
-- 		  	07/14/2004    tsho     Creates
-- ===============================================================


TYPE G_NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


-- ===============================================================
-- Procedure name
--          Reassign_Risk_Type
-- Purpose
-- 		  	Reassign specified risk type to other parent risk type.
-- ===============================================================
PROCEDURE Reassign_Risk_Type(
    p_setup_risk_type_id         IN   NUMBER,
    p_parent_setup_risk_type_id  IN   NUMBER
    );


-- ===============================================================
-- Procedure name
--          Delete_Risk_Types
-- Purpose
-- 		  	Delete specified risk type and its descendant.
--          Delete associations records in AMW_COMPLIANCE_ENV_ASSOCS
--          for the specified risk type and its descendant.
-- ===============================================================
PROCEDURE Delete_Risk_Types(
    p_setup_risk_type_id  IN         NUMBER,
    p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
    p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
    p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
    );

-- ===============================================================
-- Procedure name
--          InValidate_Risk_Types
-- Purpose
-- 		  	InValidate(End-Date) specified risk type and its descendant.
-- ===============================================================
PROCEDURE InValidate_Risk_Types(
    p_setup_risk_type_id  IN         NUMBER,
    p_end_date            IN         DATE,
    p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
    p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
    p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
    );


-- ===============================================================
-- Function name
--          RISK_TYPE_PRESENT
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          selected(associated) Setup Risk Type to specified RiskRevId
-- ===============================================================
FUNCTION RISK_TYPE_PRESENT (
    p_risk_rev_id         IN         NUMBER,
    p_risk_type_code      IN         VARCHAR2
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          RISK_TYPE_PRESENT_MEAN
-- Purpose
-- 		    return translated meaning (Yes/No) to indicate the
--          selected(associated) Setup Risk Type to specified RiskRevId
-- ===============================================================
FUNCTION RISK_TYPE_PRESENT_MEAN (
    p_risk_rev_id         IN         NUMBER,
    p_risk_type_code      IN         VARCHAR2
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          IS_DESCENDANT_ASSOC_TO_RISK
-- Purpose
-- 		    return non translated character (Y/N) to indicate if the
--          Setup Risk Type or at least one of its descendants are
--          associated to specified RiskRevId under specified compliance
-- ===============================================================
FUNCTION IS_DESCENDANT_ASSOC_TO_RISK (
    p_risk_rev_id         IN         NUMBER,
    p_setup_risk_type_id  IN         NUMBER,
    p_compliance_env_id   IN         NUMBER
) RETURN VARCHAR2;


-- ===============================================================
-- Procedure name
--          PROCESS_RISK_TYPE_ASSOCS
-- Purpose
-- 		    Update the risk-riskTypes associations(store in table AMW_RISK_TYPE)
--          depending on the specified p_select_flag .
-- ===============================================================
PROCEDURE PROCESS_RISK_TYPE_ASSOCS (
                   p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
                   p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_select_flag         IN         VARCHAR2,
                   p_risk_rev_id         IN         NUMBER,
                   p_risk_type_code      IN         VARCHAR2,
                   x_return_status       OUT NOCOPY VARCHAR2,
                   x_msg_count           OUT NOCOPY NUMBER,
                   x_msg_data            OUT NOCOPY VARCHAR2
);

-- ===============================================================
-- Function name
--          GET_ALL_DESCENDANTS
-- Purpose
-- 		    to get all the descendants of specified risk type
-- ===============================================================
FUNCTION GET_ALL_DESCENDANTS (
    p_setup_risk_type_id         IN         NUMBER
) RETURN G_NUMBER_TABLE;


-- ===============================================================
-- Function name
--          IS_DESCENDANT
-- Purpose
-- 		    return 'Y' if the passed-in p_target_setup_risk_type is the descendants
--          of specified risk type (p_setup_risk_type_id)
-- ===============================================================
FUNCTION IS_DESCENDANT (
    p_target_setup_risk_type_id  IN         NUMBER,
    p_setup_risk_type_id         IN         NUMBER
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          IS_PARENT
-- Purpose
-- 		    return 'Y' if the passed-in p_target_setup_risk_type is the direct parent
--          of specified risk type (p_setup_risk_type_id)
-- ===============================================================
FUNCTION IS_PARENT (
    p_target_setup_risk_type_id  IN         NUMBER,
    p_setup_risk_type_id         IN         NUMBER
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          CAN_HAVE_CHILD
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          specified parent_setup_risk_type can have target setup_risk_type as child.
-- ===============================================================
FUNCTION CAN_HAVE_CHILD (
    p_target_setup_risk_type_id   IN         NUMBER,
    p_parent_setup_risk_type_id   IN         NUMBER
) RETURN VARCHAR2;


-- ===============================================================
-- Procedure name
--          IS_ASSOC_TO_RISK
-- Purpose
-- 		    return 'Y' if the passed-in p_setup_risk_type and its descendants
--          are currently associated with the specified risk (p_risk_rev_id)
-- ===============================================================
PROCEDURE IS_ASSOC_TO_RISK (
    p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
    p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
    p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
    p_setup_risk_type_id  IN         NUMBER,
    x_is_assoc_to_risk    OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
);


-- ----------------------------------------------------------------------
END AMW_SETUP_RISK_TYPES_PVT;

 

/
