--------------------------------------------------------
--  DDL for Package Body AMW_ASSESSMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_ASSESSMENTS_PVT" as
/* $Header: amwtassb.pls 120.0 2005/05/31 20:08:30 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_ASSESSMENTS_PVT
-- Purpose
-- 		  	for handling Assessments and the related
-- History
-- 		  	12/28/2003    tsho     Creates
-- ===============================================================


G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'AMW_ASSESSMENTS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) 	:= 'amwtassb.pls';


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
) IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Procedure_Related';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

BEGIN
  -- create savepoint if p_commit is true
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT Delete_Procedure_Related;
  END IF;

  x_return_status := G_RET_STS_SUCCESS;

  IF (p_assess_procedure_id IS NOT NULL) THEN
    delete from AMW_ASSESS_PROCEDURE_STEPS_TL
    where ASSESS_PROCEDURE_STEP_ID IN (
        select ASSESS_PROCEDURE_STEP_ID
        from AMW_ASSESS_PROCEDURE_STEPS_B
        where ASSESS_PROCEDURE_ID = p_assess_procedure_id
    );

    delete from AMW_ASSESS_PROCEDURE_STEPS_B
    where ASSESS_PROCEDURE_ID = p_assess_procedure_id;

    delete from AMW_ASSESS_PROCEDURES_TL
    where ASSESS_PROCEDURE_ID = p_assess_procedure_id;

    delete from AMW_ASSESS_PROCEDURES_B
    where ASSESS_PROCEDURE_ID = p_assess_procedure_id;

  END IF; -- end of if: p_assess_procedure_id IS NOT NULL

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Delete_Procedure_Related;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                  p_data    =>   x_msg_data);
  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Delete_Procedure_Related;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_ASSESSMENTS_PVT',
                               p_procedure_name =>    'Delete_Procedure_Related',
                               p_error_text     =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                 p_data    =>   x_msg_data);

END Delete_Procedure_Related;




-- ===============================================================
-- Procedure name
--          Delete_Assessment_Related
-- Purpose
-- 		  	Delete any others related to this assessment,
--          ie. AssessmentProcedure Assoc, Survey, Context, Component
-- ===============================================================
PROCEDURE Delete_Assessment_Related(
    p_assessment_id              IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2   := FND_API.G_FALSE,
    p_validate_only              IN  VARCHAR2   := FND_API.G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
) IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Procedure_Related';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

BEGIN
  -- create savepoint if p_commit is true
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT Delete_Procedure_Related;
  END IF;

  x_return_status := G_RET_STS_SUCCESS;

  IF (p_assessment_id IS NOT NULL) THEN
    -- Assessment Procedure Association
    DELETE FROM AMW_ASSESS_PROCEDURE_ASSOCS WHERE OBJECT_TYPE='ASSESSMENT' AND PK1=p_assessment_id;

    -- Context
    DELETE FROM AMW_ASSESSMENT_CONTEXTS WHERE ASSESSMENT_ID = p_assessment_id;

    -- Survey Association
    DELETE FROM AMW_SURVEY_ASSOCS WHERE OBJECT_TYPE='ASSESSMENT' AND OBJECT_ID=p_assessment_id;

    -- Assessment Component
    DELETE FROM AMW_ASSESSMENT_COMPONENTS WHERE OBJECT_TYPE='ASSESSMENT' AND OBJECT_ID=p_assessment_id;

    -- Attachment
    FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments('AMW_ASSESSMENT',
                                                   p_assessment_id,
                                                   null,
                                                   null,
                                                   null,
                                                   null,
                                                   'N',
                                                   null);
  END IF; -- end of if: p_assessment_id IS NOT NULL

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Delete_Assessment_Related;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                  p_data    =>   x_msg_data);
  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Delete_Assessment_Related;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_ASSESSMENTS_PVT',
                               p_procedure_name =>    'Delete_Assessment_Related',
                               p_error_text     =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count   =>   x_msg_count,
                                 p_data    =>   x_msg_data);

END Delete_Assessment_Related;


-- ----------------------------------------------------------------------
END AMW_ASSESSMENTS_PVT;

/
