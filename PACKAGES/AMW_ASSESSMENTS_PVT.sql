--------------------------------------------------------
--  DDL for Package AMW_ASSESSMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_ASSESSMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: amwtasss.pls 120.0 2005/05/31 19:14:13 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_ASSESSMENTS_PVT
-- Purpose
-- 		  	for handling Assessments and the related
-- History
-- 		  	12/28/2003    tsho     Creates
-- ===============================================================


-- FND_API global constant
G_FALSE    		  		   CONSTANT VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE 					   CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_VALID_LEVEL_FULL 		   CONSTANT NUMBER 		:= FND_API.G_VALID_LEVEL_FULL;
G_RET_STS_SUCCESS 		   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR			   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR 	   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;



-- ===============================================================
-- Procedure name
--          Delete_Procedure_Related
-- Purpose
-- 		  	Delete any others related to this assessment procedure,
--          ie. assessProcedure, assessProcedureStep
-- ===============================================================
PROCEDURE Delete_Procedure_Related(
    p_assess_procedure_id        IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validate_only              IN   VARCHAR2   := FND_API.G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
);



-- ===============================================================
-- Procedure name
--          Delete_Assessment_Related
-- Purpose
-- 		  	Delete any others related to this assessment,
--          ie. AssessmentProcedure, Survey, Context, Component
-- ===============================================================
PROCEDURE Delete_Assessment_Related(
    p_assessment_id              IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2   := FND_API.G_FALSE,
    p_validate_only              IN  VARCHAR2   := FND_API.G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
);


-- ----------------------------------------------------------------------
END AMW_ASSESSMENTS_PVT;

 

/
