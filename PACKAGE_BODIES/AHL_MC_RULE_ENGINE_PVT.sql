--------------------------------------------------------
--  DDL for Package Body AHL_MC_RULE_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_RULE_ENGINE_PVT" AS
/* $Header: AHLVRUEB.pls 120.4 2007/12/21 13:37:18 sathapli ship $ */
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'Ahl_MC_Rule_Engine_Pvt';

--
PROCEDURE Evaluate_Rule_Stmt (
    p_item_instance_id   IN 	       NUMBER,
    p_rule_stmt_id		  IN 		NUMBER,
    x_eval_result	  OUT  NOCOPY	 VARCHAR2,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2);

------------------------
-- Declare Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : Check_Rules_For_Unit
--  Type        : Private
--  Function    : Checks rule completeness for unit
--  Pre-reqs    :
--  Parameters  :
--
--  Check_Rules_For_Unit Parameters:
--	 p_unit_header_id	      IN    NUMBER Required.
--	 p_check_subconfig_flag	      IN    VARCHAR2, T/F whether to check
--					  subconfig rules
--
--  End of Comments.

PROCEDURE Check_Rules_For_Unit (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_unit_header_id	  IN 	       NUMBER,
    p_rule_type           IN            VARCHAR2,
    p_check_subconfig_flag IN 		VARCHAR2 := FND_API.G_TRUE,
    x_evaluation_status	  OUT  NOCOPY	 VARCHAR2)
IS
--
CURSOR get_rules_for_unit_csr(p_uc_header_id IN NUMBER, p_rtype IN VARCHAR2) IS
SELECT DISTINCT rules.rule_id, uc.csi_item_instance_id
 FROM  AHL_MC_RULES_B rules, AHL_UNIT_CONFIG_HEADERS uc
WHERE rules.mc_header_id = uc.master_config_id
  AND uc.unit_config_header_id = p_uc_header_id
  AND TRUNC(nvl(uc.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
  AND TRUNC(nvl(uc.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
  AND rules.rule_type_code = p_rtype
  AND TRUNC(nvl(rules.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
  AND TRUNC(nvl(rules.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);
--
CURSOR get_all_subunits_csr(p_uc_header_id IN NUMBER) IS
SELECT uc.unit_config_header_id
 FROM  AHL_UNIT_CONFIG_HEADERS uc
START WITH  uc.unit_config_header_id = p_uc_header_id
  AND TRUNC(nvl(uc.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
  AND TRUNC(nvl(uc.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
CONNECT BY PRIOR uc.unit_config_header_id = uc.PARENT_UC_HEADER_ID
  AND TRUNC(nvl(uc.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
  AND TRUNC(nvl(uc.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Check_Rules_For_Unit';
l_csi_ii_id        NUMBER;
l_rule_id          NUMBER;
l_eval_result      VARCHAR2(1);
l_all_true_flag        BOOLEAN;
l_uc_header_id      NUMBER;

--
BEGIN

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  x_evaluation_status := 'U';
  l_all_true_flag   := True;

  --If NOT check sub configs
  IF (p_check_subconfig_flag <> FND_API.G_TRUE) THEN
     OPEN get_rules_for_unit_csr(p_unit_header_id, p_rule_type);
     LOOP
       FETCH get_rules_for_unit_csr into l_rule_id, l_csi_ii_id;
       EXIT WHEN get_rules_for_unit_csr%NOTFOUND;

       --Call rule evaluation
       Evaluate_Rule (p_api_version   	    => 1.0,
    		      p_init_msg_list       => p_init_msg_list,
		      p_validation_level    => p_validation_level,
		      p_item_instance_id    => l_csi_ii_id,
		      p_rule_id	      	    => l_rule_id,
		      x_eval_result	    => l_eval_result,
		      x_return_status       => x_return_status,
       		      x_msg_count           => x_msg_count,
       		      x_msg_data            => x_msg_data);

        IF (l_eval_result <> 'T') THEN
	   l_all_true_flag := False;
        END IF;
	IF (l_eval_result ='F') THEN
	  x_evaluation_status := 'F';
	  EXIT;   --Quit after the 1st false
	END IF;
      END LOOP;
      CLOSE get_rules_for_unit_csr;

  ELSE  --Evaluate subconfig rules as well.

     OPEN get_all_subunits_csr(p_unit_header_id);
     LOOP
       FETCH get_all_subunits_csr into l_uc_header_id;
       EXIT WHEN get_all_subunits_csr%NOTFOUND;
       EXIT WHEN x_evaluation_status = 'F';

       OPEN get_rules_for_unit_csr(l_uc_header_id, p_rule_type);
       LOOP
         FETCH get_rules_for_unit_csr into l_rule_id, l_csi_ii_id;
         EXIT WHEN get_rules_for_unit_csr%NOTFOUND;

         --Call rule evaluation
         Evaluate_Rule (p_api_version   	    => 1.0,
    		      p_init_msg_list       => p_init_msg_list,
		      p_validation_level    => p_validation_level,
		      p_item_instance_id    => l_csi_ii_id,
		      p_rule_id	      	    => l_rule_id,
		      x_eval_result	    => l_eval_result,
		      x_return_status       => x_return_status,
       		      x_msg_count           => x_msg_count,
       		      x_msg_data            => x_msg_data);

         IF (l_eval_result <> 'T') THEN
	     l_all_true_flag := False;
         END IF;
	 IF (l_eval_result ='F') THEN
	    x_evaluation_status := 'F';
	    EXIT;
	 END IF;
	END LOOP;
        CLOSE get_rules_for_unit_csr;
      END LOOP;
      CLOSE get_all_subunits_csr;
  END IF;

  --If every rule evaluates to True.
  IF (l_all_true_flag ) THEN
	x_evaluation_status := 'T';
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
       p_data  => x_msg_data,
       p_encoded => fnd_api.g_false
     );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Check_Rules_For_Unit;

------------------------
-- Start of Comments --
--  Procedure name    : Validate_Rules_For_Unit
--  Type        : Private
--  Function    : Validate all rule completeness for unit
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Rules_For_Unit Parameters:
--	 p_unit_header_id	      IN    NUMBER Required.
--	 p_check_subconfig_flag	      IN    VARCHAR2, T/F whether to check
--					  subconfig rules
--
--  End of Comments.

PROCEDURE Validate_Rules_For_Unit (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_unit_header_id	  IN 	       NUMBER,
    p_rule_type           IN            VARCHAR2,
    p_check_subconfig_flag IN 		VARCHAR2 := FND_API.G_TRUE,
    p_x_error_tbl	  IN OUT NOCOPY  AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
    x_evaluation_status	  OUT  NOCOPY	 VARCHAR2)
IS
--
CURSOR get_rules_for_unit_csr(p_uc_header_id IN NUMBER, p_rtype IN VARCHAR2) IS
SELECT DISTINCT rules.rule_id, rules.rule_name, uc.csi_item_instance_id, uc.name
 FROM  AHL_MC_RULES_B rules, AHL_UNIT_CONFIG_HEADERS uc
WHERE rules.mc_header_id = uc.master_config_id
  AND uc.unit_config_header_id = p_uc_header_id
  AND TRUNC(nvl(uc.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
  AND TRUNC(nvl(uc.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
  AND rules.rule_type_code = p_rtype
  AND TRUNC(nvl(rules.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
  AND TRUNC(nvl(rules.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);
--
CURSOR get_all_subunits_csr(p_uc_header_id IN NUMBER) IS
SELECT uc.unit_config_header_id
 FROM  AHL_UNIT_CONFIG_HEADERS uc
START WITH  uc.unit_config_header_id = p_uc_header_id
  AND TRUNC(nvl(uc.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
  AND TRUNC(nvl(uc.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
CONNECT BY PRIOR uc.unit_config_header_id = uc.PARENT_UC_HEADER_ID
  AND TRUNC(nvl(uc.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
  AND TRUNC(nvl(uc.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Validate_Rules_For_Unit';
l_csi_ii_id        NUMBER;
l_rule_id          NUMBER;
l_rule_name	   AHL_MC_RULES_B.RULE_NAME%TYPE;
l_uc_name	   AHL_UNIT_CONFIG_HEADERS.NAME%TYPE;
l_eval_result      VARCHAR2(1);
l_all_true_flag        BOOLEAN;
l_uc_header_id     NUMBER;
--
BEGIN

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'At the start of the procedure');
  END IF;

  x_evaluation_status := 'U';
  l_all_true_flag   := True;

  --If NOT check sub configs
  IF (p_check_subconfig_flag <> FND_API.G_TRUE) THEN
     OPEN get_rules_for_unit_csr(p_unit_header_id, p_rule_type);
     LOOP
       FETCH get_rules_for_unit_csr into l_rule_id, l_rule_name, l_csi_ii_id, l_uc_name;
       EXIT WHEN get_rules_for_unit_csr%NOTFOUND;

       --Call rule evaluation
       Evaluate_Rule (p_api_version   	    => 1.0,
    		      p_init_msg_list       => p_init_msg_list,
		      p_validation_level    => p_validation_level,
		      p_item_instance_id    => l_csi_ii_id,
		      p_rule_id	      	    => l_rule_id,
		      x_eval_result	    => l_eval_result,
		      x_return_status       => x_return_status,
       		      x_msg_count           => x_msg_count,
       		      x_msg_data            => x_msg_data);

        --Rule failed, add error message
	IF (l_eval_result ='F') THEN
	   FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_FAILED');
      	   FND_MESSAGE.Set_Token('RULE_NAME',l_rule_name);
           FND_MESSAGE.Set_Token('UNIT_NAME',l_uc_name);
	   IF (p_x_error_tbl.COUNT >0) THEN
             p_x_error_tbl(p_x_error_tbl.LAST+1) := FND_MESSAGE.get;
           ELSE
             p_x_error_tbl(0) := FND_MESSAGE.get;
           END IF;
	   x_evaluation_status := 'F';
        END IF;
        IF (l_eval_result <> 'T') THEN
	   l_all_true_flag := False;
        END IF;
      END LOOP;
      CLOSE get_rules_for_unit_csr;

  ELSE  --Evaluate subconfig rules as well.

     OPEN get_all_subunits_csr(p_unit_header_id);
     LOOP
       FETCH get_all_subunits_csr into l_uc_header_id;
       EXIT WHEN get_all_subunits_csr%NOTFOUND;
       OPEN get_rules_for_unit_csr(l_uc_header_id, p_rule_type);
       LOOP
         FETCH get_rules_for_unit_csr into l_rule_id, l_rule_name, l_csi_ii_id, l_uc_name;
         EXIT WHEN get_rules_for_unit_csr%NOTFOUND;

         --Call rule evaluation
         Evaluate_Rule (p_api_version   	    => 1.0,
    		      p_init_msg_list       => p_init_msg_list,
		      p_validation_level    => p_validation_level,
		      p_item_instance_id    => l_csi_ii_id,
		      p_rule_id	      	    => l_rule_id,
		      x_eval_result	    => l_eval_result,
		      x_return_status       => x_return_status,
       		      x_msg_count           => x_msg_count,
       		      x_msg_data            => x_msg_data);

         IF (l_eval_result ='F') THEN
	   FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_FAILED');
      	   FND_MESSAGE.Set_Token('RULE_NAME',l_rule_name);
           FND_MESSAGE.Set_Token('UNIT_NAME',l_uc_name);
	   IF (p_x_error_tbl.COUNT >0) THEN
             p_x_error_tbl(p_x_error_tbl.LAST+1) := FND_MESSAGE.get;
           ELSE
             p_x_error_tbl(0) := FND_MESSAGE.get;
           END IF;
	   x_evaluation_status := 'F';
	 END IF;
         IF (l_eval_result <> 'T') THEN
	   l_all_true_flag := False;
         END IF;
       END LOOP;
       CLOSE get_rules_for_unit_csr;
      END LOOP;
      CLOSE get_all_subunits_csr;
  END IF;

  --If every rule evaluates to True.
  IF (l_all_true_flag ) THEN
	x_evaluation_status := 'T';
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ' p_x_error_tbl.COUNT => '||p_x_error_tbl.COUNT);
  END IF;

  IF (p_x_error_tbl.COUNT > 0) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i IN p_x_error_tbl.FIRST..p_x_error_tbl.LAST LOOP
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ' p_x_error_tbl(i) => '||p_x_error_tbl(i));
      END LOOP;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'At the end of the procedure');
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
       p_data  => x_msg_data,
       p_encoded => fnd_api.g_false
     );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Validate_Rules_For_Unit;

------------------------
-- Start of Comments --
--  Procedure name    : Validate_Rules_For_Position
--  Type        : Private
--  Function    : Validate rules for one position
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Rules_For_Position Parameters:
--	 p_item_instance_id	      IN    NUMBER Required.
--
--  End of Comments.

PROCEDURE Validate_Rules_For_Position (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_item_instance_id   IN 	       NUMBER,
    p_rule_type           IN            VARCHAR2,
    p_x_error_tbl	  IN OUT NOCOPY  AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
    x_evaluation_status	  OUT  NOCOPY	 VARCHAR2)
IS
--
-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
-- Relationship start date check should include SYSDATE too.
CURSOR get_csi_ids_csr (p_csi_instance_id IN NUMBER) IS
SELECT csi_ii.subject_id
  FROM csi_ii_relationships csi_ii
  START WITH csi_ii.object_id = p_csi_instance_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate-1)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
  CONNECT BY PRIOR csi_ii.subject_id =  csi_ii.object_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND trunc(nvl(CSI_II.ACTIVE_START_DATE, sysdate-1)) <= trunc(sysdate)
    AND trunc(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > trunc(sysdate);

--
CURSOR get_rules_for_position_csr(p_rule_type IN VARCHAR2) IS
SELECT distinct rul.rule_id, rul.rule_name, rul.mc_header_id
FROM AHL_MC_RULES_VL rul, AHL_MC_RULE_STATEMENTS rst,
     AHL_APPLICABLE_INSTANCES ap
 WHERE  rst.rule_id = rul.rule_id
   AND rul.rule_type_code = p_rule_type
   AND ((rst.subject_type = 'POSITION'
         AND  rst.subject_id =  ap.position_id )
       OR ((rst.object_type = 'ITEM_AS_POSITION' OR
            rst.object_type = 'CONFIG_AS_POSITION')
           AND rst.object_id = ap.position_id));
--
--Find matching instances given instance id and header_id
--instance is either top node or a subnode, matching mc_header_id
CURSOR get_uc_header_csr (p_csi_instance_id IN NUMBER,
			  p_mc_header_id IN NUMBER) IS
SELECT uch.csi_item_instance_id
 FROM ahl_unit_config_headers uch
 WHERE uch.master_config_id = p_mc_header_id
 AND uch.csi_item_instance_id = p_csi_instance_id
UNION ALL
SELECT csi_ii.object_id
  FROM csi_ii_relationships csi_ii
  WHERE csi_ii.object_id IN
  (SELECT csi_item_instance_id
     FROM ahl_unit_config_headers
    --mpothuku added '='
    WHERE trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
    --mpothuku End
          AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
          AND master_config_id = p_mc_header_id)

  -- SATHAPLI::Bug# 6351371, 21-Aug-2007
  -- relationship start date check should include SYSDATE too
  START WITH csi_ii.subject_id = p_csi_instance_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
  --  AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
  CONNECT BY csi_ii.subject_id = PRIOR csi_ii.object_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
  --  AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);
--
CURSOR get_uc_header_det_csr(p_csi_instance_id IN NUMBER) IS
SELECT uch.name
 FROM ahl_unit_config_headers uch
 WHERE uch.csi_item_instance_id = p_csi_instance_id;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
-- Cursor to fetch the parent instance id for a given instance id.
CURSOR get_parent_instance_csr(p_csi_instance_id IN NUMBER) IS
SELECT object_id
  FROM csi_ii_relationships
 WHERE subject_id = p_csi_instance_id
   AND TRUNC(nvl(ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
   AND TRUNC(nvl(ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);

--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Validate_Rules_For_Position';
l_rule_id          NUMBER;
l_rule_name	   AHL_MC_RULES_B.RULE_NAME%TYPE;
l_uc_name	   AHL_UNIT_CONFIG_HEADERS.NAME%TYPE;
l_mc_header_id     NUMBER;
l_csi_ii_id        NUMBER;
l_eval_result      VARCHAR2(1);
l_all_true_flag        BOOLEAN;
l_csi_id           NUMBER;
l_msg_count        NUMBER;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
l_parent_instance_id NUMBER;
l_item_instance_id   NUMBER;

--
BEGIN


  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'At the start of the procedure');
  END IF;

  x_evaluation_status := 'U';
  l_all_true_flag   := True;

  -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
  -- Since the Position Quantity Rule is defined only at the parent level for a given position, executing the rules
  -- at the position and below it will not lead to the evaluation of the quantity rule, even if defined.
  -- So its decided on executing the rules from the parent position, instead of the position where installation is being done.
  -- For this, fetch the parent instance id for p_item_instance_id, and then use it instead for further validations.
  OPEN get_parent_instance_csr(p_item_instance_id);
  FETCH get_parent_instance_csr INTO l_parent_instance_id;
  CLOSE get_parent_instance_csr;

  IF(l_parent_instance_id is not null) THEN
    l_item_instance_id := l_parent_instance_id;
  ELSE
    l_item_instance_id := p_item_instance_id;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                  ' l_item_instance_id => '||l_item_instance_id||', l_parent_instance_id => '||l_parent_instance_id);
  END IF;

  EXECUTE IMMEDIATE 'DELETE FROM AHL_APPLICABLE_INSTANCES';

  -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
  -- Modify the reference of p_item_instance_id to l_item_instance_id.
  AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Positions
	             (p_api_version   	    => 1.0,
    		      p_init_msg_list       => p_init_msg_list,
		      p_validation_level    => p_validation_level,
		      p_csi_item_instance_id => l_item_instance_id,
		      x_return_status       => x_return_status,
       		      x_msg_count           => x_msg_count,
       		      x_msg_data            => x_msg_data);

   -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
  -- Modify the reference of p_item_instance_id to l_item_instance_id.
  OPEN get_csi_ids_csr(l_item_instance_id);
  LOOP
     FETCH get_csi_ids_csr into l_csi_id;
     EXIT WHEN get_csi_ids_csr%NOTFOUND;
     AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Positions
	             (p_api_version   	    => 1.0,
    		      p_init_msg_list       => p_init_msg_list,
		      p_validation_level    => p_validation_level,
		      p_csi_item_instance_id => l_csi_id,
		      x_return_status       => x_return_status,
       		      x_msg_count           => x_msg_count,
       		      x_msg_data            => x_msg_data);
  -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  END LOOP;
  CLOSE get_csi_ids_csr;

  --Fetch rules matching given position
  OPEN get_rules_for_position_csr(p_rule_type);
  LOOP
       FETCH get_rules_for_position_csr into l_rule_id, l_rule_name, l_mc_header_id;
       EXIT WHEN get_rules_for_position_csr%NOTFOUND;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                        ' p_item_instance_id => '||p_item_instance_id||
                        ' l_mc_header_id => '||l_mc_header_id);
       END IF;

       -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
       -- Modify the reference of p_item_instance_id to l_item_instance_id.
       OPEN get_uc_header_csr(l_item_instance_id, l_mc_header_id);
       FETCH get_uc_header_csr INTO l_csi_ii_id;

       IF (get_uc_header_csr%FOUND) THEN

         --Call rule evaluation
         Evaluate_Rule (p_api_version   	    => 1.0,
    		      p_init_msg_list       => p_init_msg_list,
		      p_validation_level    => p_validation_level,
		      p_item_instance_id    => l_csi_ii_id,
		      p_rule_id	      	    => l_rule_id,
		      x_eval_result	    => l_eval_result,
		      x_return_status       => x_return_status,
       		      x_msg_count           => x_msg_count,
       		      x_msg_data            => x_msg_data);

          --Rule failed, add error message
	  IF (l_eval_result ='F') THEN

	     OPEN get_uc_header_det_csr (l_csi_ii_id);
	     FETCH get_uc_header_det_csr INTO l_uc_name;
	     CLOSE get_uc_header_det_csr;
	     FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_FAILED');
      	     FND_MESSAGE.Set_Token('RULE_NAME',l_rule_name);
             FND_MESSAGE.Set_Token('UNIT_NAME',l_uc_name);
	     IF (p_x_error_tbl.COUNT >0) THEN
               p_x_error_tbl(p_x_error_tbl.LAST+1) := FND_MESSAGE.get;
             ELSE
               p_x_error_tbl(0) := FND_MESSAGE.get;
             END IF;
	     x_evaluation_status := 'F';
          END IF;
          IF (l_eval_result <> 'T') THEN
	     l_all_true_flag := False;
          END IF;

        END IF; --get_uc_header_csr%FOUND
        CLOSE get_uc_header_csr;

   END LOOP;
   CLOSE get_rules_for_position_csr;

  --If every rule evaluates to True.
  IF (l_all_true_flag) THEN
	x_evaluation_status := 'T';
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ' p_x_error_tbl.COUNT => '||p_x_error_tbl.COUNT);
  END IF;

  IF (p_x_error_tbl.COUNT > 0) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i IN p_x_error_tbl.FIRST..p_x_error_tbl.LAST LOOP
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ' p_x_error_tbl(i) => '||p_x_error_tbl(i));
      END LOOP;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ' At the end of the procedure');
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
       p_data  => x_msg_data,
       p_encoded => fnd_api.g_false
     );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Validate_Rules_For_Position;

------------------------
-- Start of Comments --
--  Procedure name    : Evaluate_Rule
--  Type        : Private
--  Function    : Evaluate 1 rule against 1 starting position
--  Pre-reqs    :
--  Parameters  :
--
--  Evaludate_Rule Parameters:
--	 p_item_instance_id	      IN    NUMBER Required.
--	 p_rule_id		      IN    NUMBER Required. Rule to eval.
--  End of Comments.

PROCEDURE Evaluate_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_item_instance_id   IN 	       NUMBER,
    p_rule_id		  IN 		NUMBER,
    x_eval_result	  OUT  NOCOPY	 VARCHAR2)
IS
--
CURSOR get_rule_stmt_id_csr(p_rule_id IN NUMBER) IS
SELECT rule_statement_id
 FROM  AHL_MC_RULE_STATEMENTS
WHERE rule_id = p_rule_id
   AND top_rule_stmt_flag = 'T';
--
l_rule_stmt_id NUMBER;
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Evaluate_Rule';
--
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ' At the start of the procedure');
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  OPEN get_rule_stmt_id_csr(p_rule_id);
  FETCH get_rule_stmt_id_csr into l_rule_stmt_id;
  IF (get_rule_stmt_id_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_ID_INV');
       FND_MESSAGE.Set_Token('RULE_ID',p_rule_id);
       FND_MSG_PUB.ADD;
       CLOSE get_rule_stmt_id_csr;
       Raise FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_rule_stmt_id_csr;

  --Call recursive rule evaluation
  Evaluate_Rule_Stmt(p_item_instance_id    => p_item_instance_id,
  		     p_rule_stmt_id 	      => l_rule_stmt_id,
		     x_eval_result         => x_eval_result,
		     x_return_status       => x_return_status,
       		     x_msg_count           => x_msg_count,
       		     x_msg_data            => x_msg_data);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ' At the end of the procedure');
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
       p_data  => x_msg_data,
       p_encoded => fnd_api.g_false
     );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Evaluate_Rule;


PROCEDURE Evaluate_Rule_Stmt (
    p_item_instance_id   IN 	       NUMBER,
    p_rule_stmt_id		  IN 		NUMBER,
    x_eval_result	  OUT  NOCOPY	 VARCHAR2,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2)
IS
--
CURSOR get_rule_stmt_csr(p_rulestmt_id IN NUMBER) IS
SELECT *
  FROM ahl_mc_rule_statements
 WHERE rule_statement_id = p_rulestmt_id;
--
CURSOR get_inventory_item_csr (p_csi_ii_id IN NUMBER) IS
SELECT inventory_item_id
  FROM CSI_ITEM_INSTANCES
 WHERE instance_id = p_csi_ii_id;
--
CURSOR get_mc_ids_csr (p_csi_ii_id IN NUMBER) IS
SELECT hd.mc_id, hd.version_number
FROM   AHL_MC_HEADERS_B hd, AHL_UNIT_CONFIG_HEADERS uc
WHERE  hd.mc_header_id = uc.master_config_id
AND   uc.csi_item_instance_id = p_csi_ii_id;
--
CURSOR check_same_inventory_item_csr (p_csi_ii_id1 IN NUMBER,
			       p_csi_ii_id2 IN NUMBER) IS
SELECT csi1.inventory_item_id
  FROM CSI_ITEM_INSTANCES csi1, CSI_ITEM_INSTANCES csi2
 WHERE csi1.instance_id = p_csi_ii_id1
   AND csi2.instance_id = p_csi_ii_id2
   AND csi1.inventory_item_id = csi2.inventory_item_id;
--
CURSOR check_same_mc_header_csr (p_csi_ii_id1 IN NUMBER,
			         p_csi_ii_id2 IN NUMBER) IS
SELECT uc1.master_config_id
  FROM AHL_UNIT_CONFIG_HEADERS uc1, AHL_UNIT_CONFIG_HEADERS uc2
 WHERE uc1.csi_item_instance_id = p_csi_ii_id1
   AND uc2.csi_item_instance_id = p_csi_ii_id2
   AND uc1.master_config_id = uc2.master_config_id;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
-- Defined the following new cursors: -

-- Cursor to get the distinct UOM count of all the non-extra children of an instance.
CURSOR check_child_inst_uoms_csr(p_csi_instance_id IN NUMBER) IS
SELECT count(distinct unit_of_measure)
  FROM csi_ii_relationships csi_ii,
       csi_item_instances csi
 WHERE csi_ii.object_id = p_csi_instance_id
   AND csi_ii.subject_id = csi.instance_id
   AND csi_ii.position_reference is not null
   AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
   AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
   AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);

-- Cursor to get the sum of quantities of all the non-extra children of an instance.
CURSOR get_tot_child_quant_csr(p_csi_instance_id IN NUMBER) IS
SELECT nvl(sum(quantity),0) quantity
  FROM csi_ii_relationships csi_ii,
       csi_item_instances csi
 WHERE csi_ii.object_id = p_csi_instance_id
   AND csi_ii.subject_id = csi.instance_id
   AND csi_ii.position_reference is not null
   AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
   AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
   AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);

-- Cursor to get the instance number for a given instance id.
 CURSOR get_instance_number_csr(p_csi_instance_id IN NUMBER) IS
 SELECT instance_number from csi_item_instances
  WHERE instance_id = p_csi_instance_id;

--
l_rstmt_rec 	   get_rule_stmt_csr%ROWTYPE;
l_subj_result      VARCHAR2(1);
l_obj_result       VARCHAR2(1);
l_mapping_status   VARCHAR2(30);
l_dummy_id         NUMBER;
l_instance_id      NUMBER;
l_msg_count        NUMBER;
l_inv_item_id      NUMBER;
l_mc_id            NUMBER;
l_version_number   NUMBER;
l_subj_instance_id NUMBER;
l_obj_instance_id  NUMBER;
l_junk		   NUMBER;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
l_tot_child_quant  NUMBER;
l_uom_count        NUMBER;
l_instance_number  CSI_ITEM_INSTANCES.INSTANCE_NUMBER%TYPE;
--
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.Evaluate_Rule_Stmt',
                   ' At the start of the procedure');
  END IF;

  --Fetch rule statement information
  OPEN get_rule_stmt_csr(p_rule_stmt_id);
  FETCH get_rule_stmt_csr into l_rstmt_rec;
  IF (get_rule_stmt_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_ID_INV');
      FND_MESSAGE.Set_Token('RULE_STMT_ID',p_rule_stmt_id);
      FND_MSG_PUB.ADD;
      CLOSE get_rule_stmt_csr;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_rule_stmt_csr;

  --Check the join operators
  IF ((l_rstmt_rec.operator = 'OR') OR
      (l_rstmt_rec.operator = 'AND') OR
      (l_rstmt_rec.operator = 'IMPLIES') OR
      (l_rstmt_rec.operator = 'REQUIRES'))
  THEN
     --Evaluate the subject_id rule statements
    Evaluate_Rule_Stmt(p_item_instance_id => p_item_instance_id,
  			p_rule_stmt_id => l_rstmt_rec.subject_id,
			x_eval_result  => l_subj_result,
			x_return_status       => x_return_status,
       			x_msg_count           => x_msg_count,
       			x_msg_data            => x_msg_data);

     --Saves object_id evaluation in certain situations
     IF (l_rstmt_rec.operator = 'OR'
          AND l_subj_result = 'T') THEN
	x_eval_result := 'T';
     ELSIF (l_rstmt_rec.operator = 'AND'
            AND l_subj_result = 'F') THEN
        x_eval_result := 'F';
     ELSIF (l_rstmt_rec.operator = 'REQUIRES'
            AND l_subj_result = 'U') THEN
        x_eval_result := 'U';
     ELSIF (l_rstmt_rec.operator = 'IMPLIES'
            AND l_subj_result = 'F') THEN
        x_eval_result := 'T';
     ELSE

      --Evaluate the object_id rule statements
      Evaluate_Rule_Stmt(p_item_instance_id => p_item_instance_id,
  			p_rule_stmt_id => l_rstmt_rec.object_id,
			x_eval_result  => l_obj_result,
			x_return_status       => x_return_status,
       			x_msg_count           => x_msg_count,
       			x_msg_data            => x_msg_data);

      --logical eval results
      IF (l_rstmt_rec.operator = 'OR') THEN
          IF (l_subj_result = 'T' OR l_obj_result ='T') THEN
		x_eval_result := 'T';
  	  ELSIF (l_subj_result = 'F' AND l_obj_result='F') THEN
		x_eval_result := 'F';
	  ELSE
		x_eval_result := 'U';
	  END IF;
      ELSIF (l_rstmt_rec.operator = 'AND') THEN
          IF (l_subj_result = 'F' OR l_obj_result ='F') THEN
		x_eval_result := 'F';
  	  ELSIF (l_subj_result = 'T' AND l_obj_result='T') THEN
		x_eval_result := 'T';
	  ELSE
		x_eval_result := 'U';
	  END IF;
      ELSIF (l_rstmt_rec.operator = 'REQUIRES') THEN
	  IF (l_subj_result = 'U' OR l_obj_result ='U') THEN
		x_eval_result := 'U';
  	  ELSIF (l_subj_result = l_obj_result) THEN
		x_eval_result := 'T';
	  ELSE
		x_eval_result := 'F';
	  END IF;
      ELSIF (l_rstmt_rec.operator = 'IMPLIES') THEN
 	  IF (l_subj_result = 'F' OR l_obj_result = 'T' ) THEN
		x_eval_result := 'T';
  	  ELSIF (l_subj_result='T' AND  l_obj_result ='F') THEN
		x_eval_result := 'F';
	  ELSE
		x_eval_result := 'U';
	  END IF;
      END IF;
    END IF; --Did not have to evaluate object code
   --Now for the leaf rule statements
  ELSE
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'ahl.plsql.'||G_PKG_NAME||'.Evaluate_Rule_Stmt',
                     ' evaluating leaf rule');
    END IF;

    AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance (
        p_api_version   	=> 1.0,
        p_position_id	       => l_rstmt_rec.subject_id,
        p_csi_item_instance_id  => p_item_instance_id,
        x_item_instance_id     => l_instance_id,
 	x_lowest_uc_csi_id    => l_dummy_id,
        x_mapping_status      => l_mapping_status,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'ahl.plsql.'||G_PKG_NAME||'.Evaluate_Rule_Stmt',
                     ' After calling AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance: '||
                     ' p_position_id => '||l_rstmt_rec.subject_id||', p_item_instance_id => '||p_item_instance_id||
                     ', x_item_instance_id => '||l_instance_id||', x_lowest_uc_csi_id => '||l_dummy_id);
    END IF;

      -- Check return status.
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Reset the instance id when there is not a matched instance.
    IF (l_mapping_status <> 'MATCH') THEN
       l_instance_id:=null;
    END IF;

     --If Installed, Either exists or not
     IF (l_rstmt_rec.operator = 'INSTALLED') THEN
	  IF (l_instance_id IS NOT NULL) THEN
	    x_eval_result := 'T';
     	ELSE
            x_eval_result := 'F';
     	END IF;

     --If Have, must check existance of item or config for instance.
     ELSIF (l_rstmt_rec.operator = 'HAVE' OR
	    l_rstmt_rec.operator = 'MUST_HAVE' ) THEN
        --If no installed instances
        IF (l_instance_id IS NULL) THEN
	    IF (l_rstmt_rec.operator = 'MUST_HAVE') THEN
	         x_eval_result := 'F';
	    ELSE
		 x_eval_result := 'U';
	    END IF;
     	ELSE
          l_subj_instance_id :=l_instance_id;
          --1 installed instance
          IF (l_rstmt_rec.object_type ='ITEM') THEN
            OPEN get_inventory_item_csr(l_subj_instance_id);
            FETCH get_inventory_item_csr into l_inv_item_id;
	    CLOSE get_inventory_item_csr;
	    IF (l_inv_item_id = l_rstmt_rec.object_id) THEN
    		 x_eval_result := 'T';
	    ELSE
		 x_eval_result := 'F';
	    END IF;
          ELSIF (l_rstmt_rec.object_type = 'CONFIGURATION') THEN
	    OPEN get_mc_ids_csr(l_subj_instance_id);
            FETCH get_mc_ids_csr into l_mc_id, l_version_number;
	    CLOSE get_mc_ids_csr;
	    IF (l_rstmt_rec.object_attribute1 IS NULL) THEN
    		 IF (l_mc_id = l_rstmt_rec.object_id) THEN
		   x_eval_result := 'T';
	         ELSE
		   x_eval_result := 'F';
	         END IF;
            ELSE
		 IF (l_mc_id = l_rstmt_rec.object_id AND
		     l_version_number=TO_NUMBER(l_rstmt_rec.object_attribute1))
 		 THEN
		   x_eval_result := 'T';
	         ELSE
		   x_eval_result := 'F';
	         END IF;
	    END IF; --IF object_attribute1

          -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
          -- Evaluate for the object_type TOT_CHILD_QUANTITY
          ELSIF (l_rstmt_rec.object_type = 'TOT_CHILD_QUANTITY') THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'ahl.plsql.'||G_PKG_NAME||'.Evaluate_Rule_Stmt',
                             ' evaluating position quantity rule for the instance: ' || l_subj_instance_id);
            END IF;

            -- Check that all the child instances have the same UOM
            l_uom_count := 0;
            OPEN check_child_inst_uoms_csr(l_subj_instance_id);
            FETCH check_child_inst_uoms_csr into l_uom_count;
            IF (l_uom_count > 1) THEN
            -- This would mean there are more than one UOM corresponding to the child instances
              x_eval_result := 'F';
              OPEN get_instance_number_csr(l_subj_instance_id);
              FETCH get_instance_number_csr into l_instance_number;
              CLOSE get_instance_number_csr;

              FND_MESSAGE.Set_Name('AHL', 'AHL_UC_QRUL_INST_UOM_DIF');
              FND_MESSAGE.Set_Token('INST_NUM',l_instance_number);
              FND_MSG_PUB.ADD;
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                               'ahl.plsql.'||G_PKG_NAME||'.Evaluate_Rule_Stmt',
                               ' UOMs of the children of the instance: ' ||l_subj_instance_id || ' do not match');
              END IF;
              CLOSE check_child_inst_uoms_csr;
              x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;

            END IF;
            CLOSE check_child_inst_uoms_csr;

            -- Validate the rule quantity against the total child quantity
            l_tot_child_quant := 0;
            OPEN get_tot_child_quant_csr(l_subj_instance_id);
            FETCH get_tot_child_quant_csr into l_tot_child_quant;
            CLOSE get_tot_child_quant_csr;
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'ahl.plsql.'||G_PKG_NAME||'.Evaluate_Rule_Stmt',
                             ' computed total quantity of children ->' ||l_tot_child_quant || ' and rule quantity is ->' ||
                             l_rstmt_rec.object_attribute1);
            END IF;

            IF(l_tot_child_quant = NVL(TO_NUMBER(l_rstmt_rec.object_attribute1),-1)) THEN
              x_eval_result := 'T';
            ELSE
              x_eval_result := 'F';
            END IF;
          END IF; -- If ITEM or CONFIGURATION or TOT_CHILD_QUANTITY
        END IF;  --If instance id is not null

    --Same operator. Must store instance id as subject id
    --Evaluate object path position and compare the 2 instance ids
    ELSIF (l_rstmt_rec.operator = 'SAME') THEN

      IF (l_instance_id IS NULL) THEN
	  x_eval_result := 'U';
      ELSE
        l_subj_instance_id :=l_instance_id;

        AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance (
      	     	p_api_version   	=> 1.0,
        	p_position_id	       => l_rstmt_rec.object_id,
        	p_csi_item_instance_id  => p_item_instance_id,
        	x_item_instance_id     => l_instance_id,
                x_lowest_uc_csi_id    => l_dummy_id,
                x_mapping_status      => l_mapping_status,
        	x_return_status       => x_return_status,
        	x_msg_count           => x_msg_count,
        	x_msg_data            => x_msg_data);

     -- Check return status.
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

      --Reset the instance id when there is not a matched instance.
     IF (l_mapping_status <> 'MATCH') THEN
       l_instance_id:=null;
     END IF;
     --Check object instance id
     IF (l_instance_id IS NULL) THEN
       x_eval_result := 'U';
     ELSE
          l_obj_instance_id :=l_instance_id;

          IF (l_rstmt_rec.object_type = 'ITEM_AS_POSITION') THEN
            OPEN check_same_inventory_item_csr(l_subj_instance_id,
					       l_obj_instance_id);
            FETCH check_same_inventory_item_csr into l_junk;
	    IF (check_same_inventory_item_csr%NOTFOUND) THEN
 		  x_eval_result := 'F';
	    ELSE
		  x_eval_result := 'T';
	    END IF;
	    CLOSE check_same_inventory_item_csr;
          ELSIF (l_rstmt_rec.object_type = 'CONFIG_AS_POSITION') THEN
	    OPEN check_same_mc_header_csr(l_subj_instance_id,
					       l_obj_instance_id);
            FETCH check_same_mc_header_csr into l_junk;
	    IF (check_same_mc_header_csr%NOTFOUND) THEN
 		  x_eval_result := 'F';
	    ELSE
		  x_eval_result := 'T';
	    END IF;
	    CLOSE check_same_mc_header_csr;
          END IF;
        END IF; --obj count =1
      END IF;  --subj count =1
     END IF;  --Leaf Operators

     --Invert logical status based on negation_flag
     IF (l_rstmt_rec.negation_flag = 'T') THEN
	 IF (x_eval_result = 'T') THEN
	    x_eval_result := 'F';
         ELSIF (x_eval_result = 'F') THEN
            x_eval_result := 'T';
	 END IF;
     END IF;

  END IF; --Leaf/non-leafoperators
  --dbms_output.put_line('rule_id' || to_char(p_rule_stmt_id) ||'->'||x_eval_result);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.Evaluate_Rule_Stmt',
                   ' At the end of the procedure');
  END IF;

END Evaluate_Rule_Stmt;


End AHL_MC_RULE_ENGINE_PVT;

/
