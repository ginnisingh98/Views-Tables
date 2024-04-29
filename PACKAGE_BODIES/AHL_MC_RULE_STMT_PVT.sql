--------------------------------------------------------
--  DDL for Package Body AHL_MC_RULE_STMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_RULE_STMT_PVT" AS
/* $Header: AHLVRSTB.pls 120.1 2007/12/21 13:34:54 sathapli ship $ */
G_PKG_NAME      CONSTANT VARCHAR2(30)  := 'Ahl_MC_Rule_Stmt_Pvt';
G_LOG_PREFIX    CONSTANT VARCHAR2(100) := 'ahl.plsql.'||G_PKG_NAME;

--
--Local function used to fetch the rule operator
--
FUNCTION get_rule_oper(p_rule_oper IN VARCHAR2,
				p_neg_flag IN VARCHAR2)
RETURN VARCHAR2;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 03-Dec-2007
-- New APIs declared: -
FUNCTION get_fnd_lkup_meaning(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE validate_pos_quantity_rule(p_rule_stmt_rec IN AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type);

--
------------------------
-- Declare Procedures --
------------------------
--------------------------------
-- Start of Comments --
--  Procedure name    : Validate_Rule_Stmt
--  Type        : Private
--  Function    : Validates the rule statement for statement errors.
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Rule_Stmt Parameters:
--       p_rule_stmt_rec      IN   AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type Required
--
--  End of Comments.

PROCEDURE Validate_Rule_Stmt (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_stmt_rec 	  IN       AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type)
IS
--
CURSOR Check_rule_type_csr (p_rule_id IN NUMBER) IS
  SELECT rule_type_code FROM ahl_mc_rules_b
   WHERE rule_id = p_rule_id;
--
CURSOR Check_rule_statement_csr (p_rule_stmt_id IN NUMBER)  IS
    SELECT  'X'
     FROM   ahl_mc_rule_statements
    WHERE   rule_statement_id = p_rule_stmt_id;

--Checks that position_id is valid and that position_id maps to the rule's mc
-- by checking mc_id and version are the same.
CURSOR Check_position_id_csr (p_rule_id IN NUMBER, p_position_id IN NUMBER) IS
  SELECT 'X'
   FROM AHL_MC_HEADERS_B header,
	AHL_MC_PATH_POSITION_NODES pnodes, AHL_MC_RULES_B rule
  WHERE pnodes.path_position_id = p_position_id
    AND rule.rule_id = p_rule_id
    AND rule.mc_header_id = header.mc_header_id
    AND pnodes.sequence = 0
    AND pnodes.mc_id = header.mc_id
    AND nvl(pnodes.version_number,header.version_number) = header.version_number;

--Checks the inventory_item_id. Ignoring all org_id
CURSOR Check_item_id_csr (p_inventory_item_id IN NUMBER) IS
  SELECT 'X'
   FROM  MTL_SYSTEM_ITEMS_KFV
   WHERE inventory_item_id = p_inventory_item_id;
--
--Check that mc_id plus version number is valid configuration
CURSOR Check_mc_id_csr (p_mc_id      IN NUMBER,
		        p_ver_number IN NUMBER) IS
  SELECT 'X'
    FROM  AHL_MC_HEADERS_B
   WHERE mc_id = p_mc_id
     AND version_number = nvl(p_ver_number, version_number);

--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Validate_Rule_Stmt';
l_junk            VARCHAR2(1);
l_rule_type       AHL_MC_RULES_B.RULE_TYPE_CODE%TYPE;
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

  --Check Rule subject id  is not null
  IF (p_rule_stmt_rec.subject_id IS NULL) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_SUBJ_NULL');
       FND_MSG_PUB.ADD;
  END IF;

  --Check Rule operator  is not null
  IF (p_rule_stmt_rec.operator IS NULL) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_OPER_NULL');
       FND_MSG_PUB.ADD;
  END IF;

  --Validate join operators
  IF ( (p_rule_stmt_rec.operator = 'OR') OR
	(p_rule_stmt_rec.operator = 'AND') OR
	(p_rule_stmt_rec.operator = 'IMPLIES') OR
	(p_rule_stmt_rec.operator = 'REQUIRES'))
  THEN
    --Check negation flag and subj/obj types
    IF ((p_rule_stmt_rec.subject_type <> 'RULE_STMT') OR
	(p_rule_stmt_rec.object_type <> 'RULE_STMT') OR
	(p_rule_stmt_rec.negation_flag IS NOT NULL))
    THEN
  	FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_INV');
      	FND_MESSAGE.Set_Token('OPERATOR',get_rule_oper(p_rule_stmt_rec.operator, p_rule_stmt_rec.negation_flag));
        FND_MSG_PUB.ADD;
    END IF;

    --Check both rule_ids are valid rule statements.
    OPEN check_rule_statement_csr(p_rule_stmt_rec.subject_id);
    FETCH check_rule_statement_csr INTO l_junk;
    IF (check_rule_statement_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_ID_INV');
       FND_MESSAGE.Set_Token('RULE_STMT_ID',p_rule_stmt_rec.subject_id);
       FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_rule_statement_csr;

    OPEN check_rule_statement_csr(p_rule_stmt_rec.object_id);
    FETCH check_rule_statement_csr INTO l_junk;
    IF (check_rule_statement_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_ID_INV');
       FND_MESSAGE.Set_Token('RULE_STMT_ID',p_rule_stmt_rec.object_id);
       FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_rule_statement_csr;
  END IF;

  --Check Mandatory type and position is valid
  IF ((p_rule_stmt_rec.operator = 'INSTALLED') OR
      (p_rule_stmt_rec.operator = 'HAVE') OR
      (p_rule_stmt_rec.operator = 'MUST_HAVE') OR
      (p_rule_stmt_rec.operator = 'SAME') )
  THEN
    --Check MANDATORY Type
    OPEN check_rule_type_csr(p_rule_stmt_rec.rule_id);
    FETCH check_rule_type_csr INTO l_rule_type;
    IF (l_rule_type <> 'MANDATORY' AND l_rule_type <> 'FLEET') THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_TYPE_INV');
       FND_MESSAGE.Set_Token('RULE_TYPE',l_rule_type);
       FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_rule_type_csr;

    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 03-Dec-2007
    -- Check that the fleet type rules are not created with the object type "total quantity of children"
    IF(p_rule_stmt_rec.object_type = 'TOT_CHILD_QUANTITY' AND l_rule_type = 'FLEET') THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_QRUL_TYP_OBJTY_INV');
        FND_MESSAGE.Set_Token('OPERATOR',get_rule_oper(p_rule_stmt_rec.operator, p_rule_stmt_rec.negation_flag));
        FND_MESSAGE.Set_Token('RULE_TYPE',get_fnd_lkup_meaning('AHL_MC_RULE_TYPES', l_rule_type));
        FND_MESSAGE.Set_Token('OBJ_TYPE',get_fnd_lkup_meaning('AHL_MC_RULE_OBJECT_TYPES', p_rule_stmt_rec.object_type));
        FND_MSG_PUB.ADD;
    END IF;

    --Check Valid Position
    OPEN check_position_id_csr(p_rule_stmt_rec.rule_id, p_rule_stmt_rec.subject_id);
    FETCH check_position_id_csr INTO l_junk;
    IF (check_position_id_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_PATH_POS_ID_INV');
       FND_MESSAGE.Set_Token('POSITION_ID',p_rule_stmt_rec.subject_id);
       FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_position_id_csr;
  END IF;

  -----------Install statement type--------------
  IF (p_rule_stmt_rec.operator = 'INSTALLED')
  THEN
    --Check subj_type is position and object info are null
    IF ((p_rule_stmt_rec.subject_type <> 'POSITION') OR
	(p_rule_stmt_rec.object_type IS NOT NULL) OR
	(p_rule_stmt_rec.object_id IS NOT NULL))
    THEN
  	FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_INV');
        FND_MESSAGE.Set_Token('OPERATOR',get_rule_oper(p_rule_stmt_rec.operator, p_rule_stmt_rec.negation_flag));
        FND_MSG_PUB.ADD;
    END IF;

  -----------Have statement type--------------
  ELSIF ((p_rule_stmt_rec.operator = 'HAVE') OR
         (p_rule_stmt_rec.operator = 'MUST_HAVE'))
  THEN
    --Check subj_type is position and object info are null
    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 03-Dec-2007
    -- Modified the following check as the new rule is compatible only for the operator - object_type
    -- combination of MUST_HAVE - TOT_CHILD_QUANTITY

    -- Therefore for operator as HAVE or MUST_HAVE, the invalid rule statement error should be thrown if: -
    -- 1) subject_type is not POSITION
    -- OR
    -- 2) object_type is not among ITEM, CONFIGURATION and TOT_CHILD_QUANTITY
    -- OR
    -- 3) (operator - object_type) combination is (HAVE - TOT_CHILD_QUANTITY) or (Must Not Have - TOT_CHILD_QUANTITY)
    IF ((p_rule_stmt_rec.subject_type <> 'POSITION')
        OR
        ((p_rule_stmt_rec.object_type <> 'ITEM') AND
         (p_rule_stmt_rec.object_type <> 'CONFIGURATION') AND
         (p_rule_stmt_rec.object_type <> 'TOT_CHILD_QUANTITY'))
        OR
        ((p_rule_stmt_rec.operator <> 'MUST_HAVE' OR (p_rule_stmt_rec.operator = 'MUST_HAVE' AND NVL(p_rule_stmt_rec.negation_flag,'F') = 'T')) AND
         (p_rule_stmt_rec.object_type = 'TOT_CHILD_QUANTITY'))
       )
    THEN
  	FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_INV');
        FND_MESSAGE.Set_Token('OPERATOR',get_rule_oper(p_rule_stmt_rec.operator, p_rule_stmt_rec.negation_flag));
        FND_MSG_PUB.ADD;
    END IF;

    IF (p_rule_stmt_rec.object_type = 'ITEM') THEN
     OPEN check_item_id_csr(p_rule_stmt_rec.object_id);
     FETCH check_item_id_csr INTO l_junk;
      IF (check_item_id_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
        FND_MESSAGE.Set_Token('INV_ITEM',p_rule_stmt_rec.object_id);
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE check_item_id_csr;
    ELSIF (p_rule_stmt_rec.object_type = 'CONFIGURATION') THEN
     OPEN check_mc_id_csr(p_rule_stmt_rec.object_id, p_rule_stmt_rec.object_attribute1);
     FETCH check_mc_id_csr INTO l_junk;
     IF (check_mc_id_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_MC_ID_INV');
       FND_MESSAGE.Set_Token('MC_ID',p_rule_stmt_rec.object_id);
       FND_MESSAGE.Set_Token('VER',p_rule_stmt_rec.object_attribute1);
       FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_mc_id_csr;

    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 03-Dec-2007
    -- If the new rule is being created, then validate the various parameters by calling the
    -- new API validate_pos_quantity_rule.
    ELSIF((p_rule_stmt_rec.operator = 'MUST_HAVE') AND
          (NVL(p_rule_stmt_rec.negation_flag,'F') = 'F') AND
          (p_rule_stmt_rec.object_type = 'TOT_CHILD_QUANTITY')) THEN
      validate_pos_quantity_rule(p_rule_stmt_rec);
    END IF;

  -------SAME Statements-------------
  ELSIF (p_rule_stmt_rec.operator = 'SAME')
  THEN
    --Check subj_type is position and object info are null
    IF ((p_rule_stmt_rec.subject_type <> 'POSITION') OR
	((p_rule_stmt_rec.object_type <> 'ITEM_AS_POSITION') AND
	 (p_rule_stmt_rec.object_type <> 'CONFIG_AS_POSITION')))
    THEN
  	FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_INV');
        FND_MESSAGE.Set_Token('OPERATOR',get_rule_oper(p_rule_stmt_rec.operator, p_rule_stmt_rec.negation_flag));
        FND_MSG_PUB.ADD;
    END IF;

    --Check Valid Position for object_id
    OPEN check_position_id_csr(p_rule_stmt_rec.rule_id, p_rule_stmt_rec.object_id);
    FETCH check_position_id_csr INTO l_junk;
    IF (check_position_id_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_PATH_POS_ID_INV');
       FND_MESSAGE.Set_Token('POSITION_ID',p_rule_stmt_rec.object_id);
       FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_position_id_csr;

  END IF;

   --Check Fleet Rule Statements
  IF ((p_rule_stmt_rec.operator = 'FLEET_QTY_GT') OR
      (p_rule_stmt_rec.operator = 'FLEET_QTY_EQ') OR
      (p_rule_stmt_rec.operator = 'FLEET_QTY_LT') OR
      (p_rule_stmt_rec.operator = 'FLEET_PCTG_GT') OR
      (p_rule_stmt_rec.operator = 'FLEET_PCTG_LT') OR
      (p_rule_stmt_rec.operator = 'FLEET_PCTG_EQ') )
  THEN
    --Check FLEET Type
    OPEN check_rule_type_csr(p_rule_stmt_rec.rule_id);
    FETCH check_rule_type_csr INTO l_rule_type;
    IF (l_rule_type <> 'FLEET') THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_TYPE_INV');
       FND_MESSAGE.Set_Token('RULE_TYPE',l_rule_type);
       FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_rule_type_csr;

    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 03-Dec-2007
    -- Check that the fleet type rules are not created with the object type "total quantity of children"
    IF(p_rule_stmt_rec.object_type = 'TOT_CHILD_QUANTITY') THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_QRUL_TYP_OBJTY_INV');
        FND_MESSAGE.Set_Token('OPERATOR',get_rule_oper(p_rule_stmt_rec.operator, p_rule_stmt_rec.negation_flag));
        FND_MESSAGE.Set_Token('RULE_TYPE',get_fnd_lkup_meaning('AHL_MC_RULE_TYPES', l_rule_type));
        FND_MESSAGE.Set_Token('OBJ_TYPE',get_fnd_lkup_meaning('AHL_MC_RULE_OBJECT_TYPES', p_rule_stmt_rec.object_type));
        FND_MSG_PUB.ADD;
    END IF;

    --Check Valid Position
    OPEN check_position_id_csr(p_rule_stmt_rec.rule_id, p_rule_stmt_rec.subject_id);
    FETCH check_position_id_csr INTO l_junk;
    IF (check_position_id_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_PATH_POS_ID_INV');
       FND_MESSAGE.Set_Token('POSITION_ID',p_rule_stmt_rec.subject_id);
       FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_position_id_csr;

    --Make sure object type is item
    IF (p_rule_stmt_rec.object_type <> 'ITEM') THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_INV');
        FND_MESSAGE.Set_Token('OPERATOR',get_rule_oper(p_rule_stmt_rec.operator, p_rule_stmt_rec.negation_flag));
        FND_MSG_PUB.ADD;
    END IF;

    --Make sure item id is valid
    OPEN check_item_id_csr(p_rule_stmt_rec.object_id);
    FETCH check_item_id_csr INTO l_junk;
    IF (check_item_id_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
        FND_MESSAGE.Set_Token('INV_ITEM',p_rule_stmt_rec.object_id);
        FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_item_id_csr;

    --Check quantity >= 0
    IF ((p_rule_stmt_rec.operator = 'FLEET_QTY_GT') OR
      (p_rule_stmt_rec.operator = 'FLEET_QTY_EQ') OR
      (p_rule_stmt_rec.operator = 'FLEET_QTY_LT'))  THEN
      IF (TO_NUMBER(p_rule_stmt_rec.object_attribute1) < 0) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_FLT_ATTR_INV');
        FND_MESSAGE.Set_Token('ATTR_VAL',p_rule_stmt_rec.object_attribute1);
        FND_MSG_PUB.ADD;
      END IF;
    END IF;

    IF ((p_rule_stmt_rec.operator = 'FLEET_PCTG_GT') OR
      (p_rule_stmt_rec.operator = 'FLEET_PCTG_EQ') OR
      (p_rule_stmt_rec.operator = 'FLEET_PCTG_LT'))   THEN
      IF (TO_NUMBER(p_rule_stmt_rec.object_attribute1) < 0 OR
	  TO_NUMBER(p_rule_stmt_rec.object_attribute1) > 100) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_FLT_ATTR_INV');
        FND_MESSAGE.Set_Token('ATTR_VAL',p_rule_stmt_rec.object_attribute1);
        FND_MSG_PUB.ADD;
      END IF;
    END IF;
  END IF;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
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
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
  FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

END Validate_Rule_Stmt;

--------------------------------
-- Start of Comments --
--  Procedure name    : Insert_Rule_Stmt
--  Type        : Private
--  Function    : Writes to DB the rule stmt
--  Pre-reqs    :
--  Parameters  :
--
--  Insert_Rule_Stmt Parameters:
--       p_x_rule_stmt_rec      IN OUT NOCOPY AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type Required
--
--  End of Comments.

PROCEDURE Insert_Rule_Stmt (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module		  IN 	       VARCHAR2  := 'JSP',
    p_x_rule_stmt_rec 	  IN OUT NOCOPY  AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type)
IS
--
CURSOR next_rule_stmt_id_csr IS
SELECT ahl_mc_rule_statements_s.nextval FROM DUAL;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Insert_Rule_Stmt';
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Insert_Rule_Stmt_pvt;
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

   --Check Status of MC allows for editing
  /*IF NOT(check_mc_status(p_x_rule_stmt_rec.rule_id)) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_INVALID_MC_STATUS');
       FND_MSG_PUB.ADD;
       Raise FND_API.G_EXC_ERROR;
  END IF;  */

  IF (p_module = 'JSP') THEN
   IF (p_x_rule_stmt_rec.OBJECT_ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.OBJECT_ATTRIBUTE1 := null;
   END IF;
      IF (p_x_rule_stmt_rec.OBJECT_ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.OBJECT_ATTRIBUTE2 := null;
   END IF;
      IF (p_x_rule_stmt_rec.OBJECT_ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.OBJECT_ATTRIBUTE3 := null;
   END IF;
      IF (p_x_rule_stmt_rec.OBJECT_ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.OBJECT_ATTRIBUTE4 := null;
   END IF;
      IF (p_x_rule_stmt_rec.OBJECT_ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.OBJECT_ATTRIBUTE5 := null;
   END IF;
   IF (p_x_rule_stmt_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
      p_x_rule_stmt_rec.ATTRIBUTE_CATEGORY := null;
   END IF;
   IF (p_x_rule_stmt_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE1 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE2 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE3 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE4 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE5 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE6 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE7 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE8 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE9 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE10 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE11 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE12 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE13 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE14 := null;
   END IF;
      IF (p_x_rule_stmt_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_stmt_rec.ATTRIBUTE15 := null;
   END IF;
  END IF;

  --Validate Rule Statement;
  Validate_Rule_Stmt(   p_api_version         => 1.0,
                        p_rule_stmt_rec       => p_x_rule_stmt_rec,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);

  -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_x_rule_stmt_rec.rule_statement_id IS NULL) THEN
     OPEN next_rule_stmt_id_csr;
     FETCH next_rule_stmt_id_csr INTO p_x_rule_stmt_rec.rule_statement_id;
     CLOSE next_rule_stmt_id_csr;
  END IF;

  INSERT INTO ahl_mc_rule_statements(
        RULE_STATEMENT_ID,
	OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
 	RULE_ID                 ,
	TOP_RULE_STMT_FLAG      ,
	NEGATION_FLAG           ,
	SUBJECT_ID   		,
	SUBJECT_TYPE		,
	OPERATOR		,
	OBJECT_ID		,
	OBJECT_TYPE		,
	OBJECT_ATTRIBUTE1	,
	OBJECT_ATTRIBUTE2	,
	OBJECT_ATTRIBUTE3	,
	OBJECT_ATTRIBUTE4	,
	OBJECT_ATTRIBUTE5	,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15
        )
  VALUES (
        p_x_rule_stmt_rec.rule_statement_id,
	1,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
     	p_x_rule_stmt_rec.RULE_ID                 ,
     	p_x_rule_stmt_rec.TOP_RULE_STMT_FLAG      ,
	p_x_rule_stmt_rec.NEGATION_FLAG           ,
	p_x_rule_stmt_rec.SUBJECT_ID   		,
	p_x_rule_stmt_rec.SUBJECT_TYPE		,
	p_x_rule_stmt_rec.OPERATOR		,
	p_x_rule_stmt_rec.OBJECT_ID		,
	p_x_rule_stmt_rec.OBJECT_TYPE		,
	p_x_rule_stmt_rec.OBJECT_ATTRIBUTE1	,
	p_x_rule_stmt_rec.OBJECT_ATTRIBUTE2	,
	p_x_rule_stmt_rec.OBJECT_ATTRIBUTE3	,
	p_x_rule_stmt_rec.OBJECT_ATTRIBUTE4	,
	p_x_rule_stmt_rec.OBJECT_ATTRIBUTE5	,
        p_x_rule_stmt_rec.ATTRIBUTE_CATEGORY,
        p_x_rule_stmt_rec.ATTRIBUTE1,
        p_x_rule_stmt_rec.ATTRIBUTE2,
        p_x_rule_stmt_rec.ATTRIBUTE3,
        p_x_rule_stmt_rec.ATTRIBUTE4,
        p_x_rule_stmt_rec.ATTRIBUTE5,
        p_x_rule_stmt_rec.ATTRIBUTE6,
        p_x_rule_stmt_rec.ATTRIBUTE7,
        p_x_rule_stmt_rec.ATTRIBUTE8,
        p_x_rule_stmt_rec.ATTRIBUTE9,
        p_x_rule_stmt_rec.ATTRIBUTE10,
        p_x_rule_stmt_rec.ATTRIBUTE11,
        p_x_rule_stmt_rec.ATTRIBUTE12,
        p_x_rule_stmt_rec.ATTRIBUTE13,
        p_x_rule_stmt_rec.ATTRIBUTE14,
        p_x_rule_stmt_rec.ATTRIBUTE15
       )
      RETURNING object_version_number INTO p_x_rule_stmt_rec.object_version_number;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Insert_Rule_Stmt_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Insert_Rule_Stmt_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Insert_Rule_Stmt_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Insert_Rule_Stmt;


--------------------------------
-- Start of Comments --
--  Procedure name    : Update_Rule_Stmt
--  Type        : Private
--  Function    : Writes to DB the rule stmt
--  Pre-reqs    :
--  Parameters  :
--
--  Update_Rule_Stmt Parameters:
--       p_x_rule_stmt_rec      IN OUT NOCOPY AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type Required
--
--  End of Comments.

PROCEDURE Update_Rule_Stmt (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module		  IN 	       VARCHAR2  := 'JSP',
    p_rule_stmt_rec 	  IN           AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type)
IS
--
CURSOR ahl_mc_rule_stmt_csr (p_rstmt_id IN NUMBER)  IS
SELECT *
FROM AHL_MC_RULE_STATEMENTS
WHERE rule_statement_id = p_rstmt_id;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Update_Rule_Stmt';
l_old_rstmt_rec    ahl_mc_rule_stmt_csr%ROWTYPE;
l_rule_stmt_rec    AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Update_Rule_Stmt_pvt;
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

  --Check that rule_statement_id is valid
  OPEN ahl_mc_rule_stmt_csr(p_rule_stmt_rec.rule_statement_id);
  FETCH ahl_mc_rule_stmt_csr INTO l_old_rstmt_rec;
  IF (ahl_mc_rule_stmt_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_ID_INV');
       FND_MESSAGE.Set_Token('RULE_STMT_ID',p_rule_stmt_rec.rule_statement_id);
       FND_MSG_PUB.ADD;
       CLOSE ahl_mc_rule_stmt_csr;
       Raise FND_API.G_EXC_ERROR;
  END IF;
  CLOSE ahl_mc_rule_stmt_csr;

  --Check Status of MC allows for editing
  /*IF NOT(check_mc_status(p_rule_stmt_rec.rule_id)) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_INVALID_MC_STATUS');
       FND_MSG_PUB.ADD;
       Raise FND_API.G_EXC_ERROR;
  END IF; */

  l_rule_stmt_rec := p_rule_stmt_rec;

  -- Check Object version number.
  IF (l_old_rstmt_rec.object_version_number <> l_rule_stmt_rec.object_version_number) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Do NULL/G_MISS conversion
  IF (p_module = 'JSP') THEN

   IF (l_rule_stmt_rec.OBJECT_ATTRIBUTE1 IS NULL) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE1 := l_old_rstmt_rec.OBJECT_ATTRIBUTE1;
   ELSIF (l_rule_stmt_rec.OBJECT_ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE1 := NULL;
   END IF;
   IF (l_rule_stmt_rec.OBJECT_ATTRIBUTE2 IS NULL) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE2 := l_old_rstmt_rec.OBJECT_ATTRIBUTE2;
   ELSIF (l_rule_stmt_rec.OBJECT_ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE2 := NULL;
   END IF;
   IF (l_rule_stmt_rec.OBJECT_ATTRIBUTE3 IS NULL) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE3 := l_old_rstmt_rec.OBJECT_ATTRIBUTE3;
   ELSIF (l_rule_stmt_rec.OBJECT_ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE3 := NULL;
   END IF;
   IF (l_rule_stmt_rec.OBJECT_ATTRIBUTE4 IS NULL) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE4 := l_old_rstmt_rec.OBJECT_ATTRIBUTE4;
   ELSIF (l_rule_stmt_rec.OBJECT_ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE4 := NULL;
   END IF;
   IF (l_rule_stmt_rec.OBJECT_ATTRIBUTE5 IS NULL) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE5 := l_old_rstmt_rec.OBJECT_ATTRIBUTE5;
   ELSIF (l_rule_stmt_rec.OBJECT_ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.OBJECT_ATTRIBUTE5 := NULL;
   END IF;

   IF (l_rule_stmt_rec.ATTRIBUTE_CATEGORY IS NULL) THEN
     l_rule_stmt_rec.ATTRIBUTE_CATEGORY := l_old_rstmt_rec.ATTRIBUTE_CATEGORY;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
      l_rule_stmt_rec.ATTRIBUTE_CATEGORY := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE1 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE1 := l_old_rstmt_rec.ATTRIBUTE1;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE1 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE2 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE2 := l_old_rstmt_rec.ATTRIBUTE2;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE2 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE3 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE3 := l_old_rstmt_rec.ATTRIBUTE3;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE3 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE4 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE4 := l_old_rstmt_rec.ATTRIBUTE4;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE4 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE5 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE5 := l_old_rstmt_rec.ATTRIBUTE5;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE5 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE6 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE6 := l_old_rstmt_rec.ATTRIBUTE6;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE6 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE7 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE7 := l_old_rstmt_rec.ATTRIBUTE7;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE7 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE8 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE8 := l_old_rstmt_rec.ATTRIBUTE8;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE8 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE9 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE9 := l_old_rstmt_rec.ATTRIBUTE9;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE9 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE10 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE10 := l_old_rstmt_rec.ATTRIBUTE10;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE10 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE11 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE11 := l_old_rstmt_rec.ATTRIBUTE11;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE11 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE12 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE12 := l_old_rstmt_rec.ATTRIBUTE12;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE12 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE13 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE13 := l_old_rstmt_rec.ATTRIBUTE13;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE13 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE14 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE14 := l_old_rstmt_rec.ATTRIBUTE14;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE14 := NULL;
   END IF;
   IF (l_rule_stmt_rec.ATTRIBUTE15 IS NULL) THEN
       l_rule_stmt_rec.ATTRIBUTE15 := l_old_rstmt_rec.ATTRIBUTE15;
   ELSIF (l_rule_stmt_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
       l_rule_stmt_rec.ATTRIBUTE15 := NULL;
   END IF;

  END IF;

  --Validate Rule Statement;
  Validate_Rule_Stmt(   p_api_version         => 1.0,
                        p_rule_stmt_rec       => l_rule_stmt_rec,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);

   -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  UPDATE ahl_mc_rule_statements SET
	OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
        LAST_UPDATE_DATE      = sysdate,
        LAST_UPDATED_BY       = fnd_global.USER_ID,
        LAST_UPDATE_LOGIN     = fnd_global.LOGIN_ID,
 	RULE_ID             = l_rule_stmt_rec.RULE_ID,
 	TOP_RULE_STMT_FLAG  = l_rule_stmt_rec.TOP_RULE_STMT_FLAG,
	NEGATION_FLAG      =l_rule_stmt_rec.NEGATION_FLAG     ,
	SUBJECT_ID   	   =l_rule_stmt_rec.SUBJECT_ID   ,
	SUBJECT_TYPE	   =l_rule_stmt_rec.SUBJECT_TYPE,
	OPERATOR	   =l_rule_stmt_rec.OPERATOR	,
	OBJECT_ID	   =l_rule_stmt_rec.OBJECT_ID	,
	OBJECT_TYPE	   =l_rule_stmt_rec.OBJECT_TYPE,
	OBJECT_ATTRIBUTE1	=l_rule_stmt_rec.OBJECT_ATTRIBUTE1,
	OBJECT_ATTRIBUTE2	=l_rule_stmt_rec.OBJECT_ATTRIBUTE2,
	OBJECT_ATTRIBUTE3	=l_rule_stmt_rec.OBJECT_ATTRIBUTE3,
	OBJECT_ATTRIBUTE4	=l_rule_stmt_rec.OBJECT_ATTRIBUTE4,
	OBJECT_ATTRIBUTE5	=l_rule_stmt_rec.OBJECT_ATTRIBUTE5,
        ATTRIBUTE_CATEGORY = l_rule_stmt_rec.ATTRIBUTE_CATEGORY,
        ATTRIBUTE1   = l_rule_stmt_rec.ATTRIBUTE1,
        ATTRIBUTE2 = l_rule_stmt_rec.ATTRIBUTE2,
        ATTRIBUTE3 = l_rule_stmt_rec.ATTRIBUTE3,
        ATTRIBUTE4 = l_rule_stmt_rec.ATTRIBUTE4,
        ATTRIBUTE5 = l_rule_stmt_rec.ATTRIBUTE5,
        ATTRIBUTE6 = l_rule_stmt_rec.ATTRIBUTE6,
        ATTRIBUTE7 = l_rule_stmt_rec.ATTRIBUTE7,
        ATTRIBUTE8 = l_rule_stmt_rec.ATTRIBUTE8,
        ATTRIBUTE9 = l_rule_stmt_rec.ATTRIBUTE9,
        ATTRIBUTE10 = l_rule_stmt_rec.ATTRIBUTE10,
        ATTRIBUTE11 = l_rule_stmt_rec.ATTRIBUTE11,
        ATTRIBUTE12 = l_rule_stmt_rec.ATTRIBUTE12,
        ATTRIBUTE13 = l_rule_stmt_rec.ATTRIBUTE13,
        ATTRIBUTE14 = l_rule_stmt_rec.ATTRIBUTE14,
        ATTRIBUTE15 = l_rule_stmt_rec.ATTRIBUTE15
    WHERE RULE_STATEMENT_ID =  l_rule_stmt_rec.rule_statement_id;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Update_Rule_Stmt_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Update_Rule_Stmt_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Update_Rule_Stmt_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Update_Rule_Stmt;

--------------------------------
-- Start of Comments --
--  Procedure name    : Copy_Rule_Stmt
--  Type        : Private
--  Function    : Writes to DB the rule stmt by copying the rule stmt
--  Pre-reqs    :
--  Parameters  :
--
--  Copy_Rule_Stmt Parameters:
--	 p_rule_stmt_id	      IN    NUMBER Required. rule stmt to copy
--       p_to_rule_id            IN    NUMBER  Required rule_id for insert purpose
--       p_to_mc_header_id    IN NUMBER Requred. mc_header_id to copy to
--       x_rule_stmt_id       OUT NOCOPY NUMBER   the new rule_stmt_id
--
--  End of Comments.

PROCEDURE Copy_Rule_Stmt (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_stmt_id	  IN 	       NUMBER,
    p_to_rule_id          IN           NUMBER,
    p_to_mc_header_id     IN 		NUMBER,
    x_rule_stmt_id        OUT  NOCOPY   NUMBER) IS
--
CURSOR get_rule_stmt_csr (p_rulestmt_id IN NUMBER) IS
 SELECT *
    FROM ahl_mc_rule_statements rs
   WHERE rs.rule_statement_id = p_rulestmt_id;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Copy_Rule_Stmt';
l_stmt_rec         get_rule_stmt_csr%ROWTYPE;
l_rstmt_rec         AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type;
l_new_subject_id    NUMBER;
l_new_object_id     NUMBER;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Copy_Rule_Stmt_pvt;
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

  OPEN get_rule_stmt_csr(p_rule_stmt_id);
  FETCH get_rule_stmt_csr INTO l_stmt_rec;

  IF((l_stmt_rec.operator = 'OR') OR
     (l_stmt_rec.operator = 'AND') OR
     (l_stmt_rec.operator = 'IMPLIES') OR
     (l_stmt_rec.operator = 'REQUIRES'))
   THEN
     --1) Copy the subject table
     Copy_Rule_Stmt (p_api_version         => 1.0,
    		     p_commit              => FND_API.G_FALSE,
                     p_rule_stmt_id        => l_stmt_rec.subject_id,
		     p_to_rule_id		   => p_to_rule_id,
		     p_to_mc_header_id     => p_to_mc_header_id,
 		     x_rule_stmt_id        => l_new_subject_id,
                     x_return_status       => x_return_status,
                     x_msg_count           => x_msg_count,
                     x_msg_data            => x_msg_data);

     --Verify that the rule stmt is null
      IF (l_new_subject_id is NULL AND
	 x_return_Status = fnd_api.g_ret_sts_success) THEN
	 x_rule_stmt_id := null;
	 RETURN;
     END IF;

   -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


     --2) Build the object table
     Copy_Rule_Stmt (p_api_version         => 1.0,
    		     p_commit              => FND_API.G_FALSE,
                     p_rule_stmt_id        => l_stmt_rec.object_id,
		     p_to_rule_id	    => p_to_rule_id,
		     p_to_mc_header_id     => p_to_mc_header_id,
 		     x_rule_stmt_id        => l_new_object_id,
                     x_return_status       => x_return_status,
                     x_msg_count           => x_msg_count,
                     x_msg_data            => x_msg_data);

    IF (l_new_object_id is NULL AND
	 x_return_Status = fnd_api.g_ret_sts_success) THEN
	 x_rule_stmt_id := null;
	 RETURN;
    END IF;

    -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

     --3) Change the rule stmt record and insert
     l_rstmt_rec.subject_id := l_new_subject_id;
     l_rstmt_rec.object_id := l_new_object_id;
     l_rstmt_rec.rule_id := p_to_rule_id;

      l_rstmt_rec.top_rule_stmt_flag := l_stmt_rec.top_rule_stmt_flag;
      l_rstmt_rec.negation_flag := l_stmt_rec.negation_flag;
      l_rstmt_rec.subject_type := l_stmt_rec.subject_type;
      l_rstmt_rec.operator := l_stmt_rec.operator;
      l_rstmt_rec.object_type := l_stmt_rec.object_type;
      l_rstmt_rec.OBJECT_ATTRIBUTE1:=l_stmt_rec.OBJECT_ATTRIBUTE1;
      l_rstmt_rec.OBJECT_ATTRIBUTE2:=l_stmt_rec.OBJECT_ATTRIBUTE2;
      l_rstmt_rec.OBJECT_ATTRIBUTE3:=l_stmt_rec.OBJECT_ATTRIBUTE3;
      l_rstmt_rec.OBJECT_ATTRIBUTE4:=l_stmt_rec.OBJECT_ATTRIBUTE4;
      l_rstmt_rec.OBJECT_ATTRIBUTE5:=l_stmt_rec.OBJECT_ATTRIBUTE5;
      l_rstmt_rec.ATTRIBUTE_CATEGORY := l_stmt_rec.ATTRIBUTE_CATEGORY;
      l_rstmt_rec.ATTRIBUTE1:= l_stmt_rec.ATTRIBUTE1;
      l_rstmt_rec.ATTRIBUTE2:= l_stmt_rec.ATTRIBUTE2;
      l_rstmt_rec.ATTRIBUTE3:= l_stmt_rec.ATTRIBUTE3;
      l_rstmt_rec.ATTRIBUTE4:= l_stmt_rec.ATTRIBUTE4;
      l_rstmt_rec.ATTRIBUTE5:= l_stmt_rec.ATTRIBUTE5;
      l_rstmt_rec.ATTRIBUTE6:= l_stmt_rec.ATTRIBUTE6;
      l_rstmt_rec.ATTRIBUTE7:= l_stmt_rec.ATTRIBUTE7;
      l_rstmt_rec.ATTRIBUTE8:= l_stmt_rec.ATTRIBUTE8;
      l_rstmt_rec.ATTRIBUTE9 := l_stmt_rec.ATTRIBUTE9;
      l_rstmt_rec.ATTRIBUTE10:= l_stmt_rec.ATTRIBUTE10 ;
      l_rstmt_rec.ATTRIBUTE11:= l_stmt_rec.ATTRIBUTE11 ;
      l_rstmt_rec.ATTRIBUTE12:= l_stmt_rec.ATTRIBUTE12 ;
      l_rstmt_rec.ATTRIBUTE13:= l_stmt_rec.ATTRIBUTE13;
      l_rstmt_rec.ATTRIBUTE14:= l_stmt_rec.ATTRIBUTE14;
      l_rstmt_rec.ATTRIBUTE15:= l_stmt_rec.ATTRIBUTE15;

     Insert_Rule_Stmt (p_api_version         => 1.0,
    		     p_commit              => FND_API.G_FALSE,
		     p_module              => 'PLSQL',
		     p_x_rule_stmt_rec     => l_rstmt_rec,
                     x_return_status       => x_return_status,
                     x_msg_count           => x_msg_count,
                     x_msg_data            => x_msg_data);
      x_rule_stmt_id := l_rstmt_rec.rule_statement_id;

   ELSE
      --Convert for positions
     IF (l_stmt_rec.subject_type = 'POSITION') THEN
	 AHL_MC_PATH_POSITION_PVT.Copy_Position (
    		p_api_version       => 1.0,
		p_commit            => FND_API.G_FALSE,
  	    	p_position_id       =>   l_stmt_rec.subject_id,
    		p_to_mc_header_id   => p_to_mc_header_id,
    		x_position_id       => l_rstmt_rec.subject_id,
 		x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);

       --If position can not be copied, return and not copy the rule.
       IF (l_rstmt_rec.subject_id is NULL AND
	   x_return_Status = fnd_api.g_ret_sts_success) THEN
	 x_rule_stmt_id := null;
	 RETURN;
       END IF;

    -- Check return status.
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     ELSE
	 l_rstmt_rec.subject_id := l_stmt_rec.subject_id;
     END IF;

     IF (l_stmt_rec.object_type = 'ITEM_AS_POSITION' OR
	 l_stmt_rec.object_type = 'CONFIG_AS_POSITION') THEN
          AHL_MC_PATH_POSITION_PVT.Copy_Position (
     		p_api_version       => 1.0,
		p_commit            => FND_API.G_FALSE,
  	    	p_position_id       => l_stmt_rec.object_id,
    		p_to_mc_header_id   => p_to_mc_header_id,
    		x_position_id       => l_rstmt_rec.object_id,
 		x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);

       --If position can not be copied, return and not copy the rule.
        IF (l_rstmt_rec.object_id is NULL AND
	   x_return_Status = fnd_api.g_ret_sts_success) THEN
	   x_rule_stmt_id := null;
	   RETURN;
       END IF;

     -- Check return status.
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     ELSE
	   l_rstmt_rec.object_id := l_stmt_rec.object_id;
     END IF;

      l_rstmt_rec.rule_id := p_to_rule_id;
      l_rstmt_rec.top_rule_stmt_flag := l_stmt_rec.top_rule_stmt_flag;
      l_rstmt_rec.negation_flag := l_stmt_rec.negation_flag;
      l_rstmt_rec.subject_type := l_stmt_rec.subject_type;
      l_rstmt_rec.operator := l_stmt_rec.operator;
      l_rstmt_rec.object_type := l_stmt_rec.object_type;
      l_rstmt_rec.OBJECT_ATTRIBUTE1:=l_stmt_rec.OBJECT_ATTRIBUTE1;
      l_rstmt_rec.OBJECT_ATTRIBUTE2:=l_stmt_rec.OBJECT_ATTRIBUTE2;
      l_rstmt_rec.OBJECT_ATTRIBUTE3:=l_stmt_rec.OBJECT_ATTRIBUTE3;
      l_rstmt_rec.OBJECT_ATTRIBUTE4:=l_stmt_rec.OBJECT_ATTRIBUTE4;
      l_rstmt_rec.OBJECT_ATTRIBUTE5:=l_stmt_rec.OBJECT_ATTRIBUTE5;
      l_rstmt_rec.ATTRIBUTE_CATEGORY := l_stmt_rec.ATTRIBUTE_CATEGORY;
      l_rstmt_rec.ATTRIBUTE1:= l_stmt_rec.ATTRIBUTE1;
      l_rstmt_rec.ATTRIBUTE2:= l_stmt_rec.ATTRIBUTE2;
      l_rstmt_rec.ATTRIBUTE3:= l_stmt_rec.ATTRIBUTE3;
      l_rstmt_rec.ATTRIBUTE4:= l_stmt_rec.ATTRIBUTE4;
      l_rstmt_rec.ATTRIBUTE5:= l_stmt_rec.ATTRIBUTE5;
      l_rstmt_rec.ATTRIBUTE6:= l_stmt_rec.ATTRIBUTE6;
      l_rstmt_rec.ATTRIBUTE7:= l_stmt_rec.ATTRIBUTE7;
      l_rstmt_rec.ATTRIBUTE8:= l_stmt_rec.ATTRIBUTE8;
      l_rstmt_rec.ATTRIBUTE9 := l_stmt_rec.ATTRIBUTE9;
      l_rstmt_rec.ATTRIBUTE10:= l_stmt_rec.ATTRIBUTE10 ;
      l_rstmt_rec.ATTRIBUTE11:= l_stmt_rec.ATTRIBUTE11 ;
      l_rstmt_rec.ATTRIBUTE12:= l_stmt_rec.ATTRIBUTE12 ;
      l_rstmt_rec.ATTRIBUTE13:= l_stmt_rec.ATTRIBUTE13;
      l_rstmt_rec.ATTRIBUTE14:= l_stmt_rec.ATTRIBUTE14;
      l_rstmt_rec.ATTRIBUTE15:= l_stmt_rec.ATTRIBUTE15;

      Insert_Rule_Stmt (p_api_version         => 1.0,
    		     p_commit              => FND_API.G_FALSE,
		     p_module              => 'PLSQL',
		     p_x_rule_stmt_rec     => l_rstmt_rec,
                     x_return_status       => x_return_status,
                     x_msg_count           => x_msg_count,
                     x_msg_data            => x_msg_data);

      x_rule_stmt_id := l_rstmt_rec.rule_statement_id;
  END IF;
  CLOSE get_rule_stmt_csr;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Copy_Rule_Stmt_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Copy_Rule_Stmt_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Copy_Rule_Stmt_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Copy_Rule_Stmt;

-----------------------------
-- Start of Comments --
--  Procedure name    : Delete_Rule_Stmts
--  Type        : Private
--  Function    : Deletes all the Rule statements corresponding to a rule
--  Pre-reqs    :
--  Parameters  :
--
--  Delete_Rule Parameters:
--       p_rule_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Delete_Rule_Stmts (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_id		  IN 	       NUMBER)
IS
--
 CURSOR  ahl_rule_stmts_csr (p_rule_id IN NUMBER) IS
    SELECT  rule_statement_id
     FROM    ahl_mc_rule_statements stmt
    WHERE   rule_id = p_rule_id;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Delete_Rule_Stmts';
l_stmt_id        NUMBER;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Delete_Rule_Stmts_pvt;
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

  --Check Status of MC allows for editing
  /*IF NOT(check_mc_status(p_rule_id)) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_INVALID_MC_STATUS');
       FND_MSG_PUB.ADD;
       Raise FND_API.G_EXC_ERROR;
  END IF; */

  --Delete the rule statments corresponding to rule
  OPEN ahl_rule_stmts_csr(p_rule_id);
  LOOP
     FETCH ahl_rule_stmts_csr INTO l_stmt_id;
     EXIT WHEN ahl_rule_stmts_csr%NOTFOUND;

     IF (ahl_rule_stmts_csr%FOUND) THEN
        DELETE FROM AHL_MC_RULE_STATEMENTS
        WHERE rule_statement_id = l_stmt_id;
     END IF;

  END LOOP;
  CLOSE ahl_rule_stmts_csr;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Delete_Rule_Stmts_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Delete_Rule_Stmts_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Delete_Rule_Stmts_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
End Delete_Rule_Stmts;

-----------------------------
-- Start of Comments --
--  Procedure name    : validate_pos_quantity_rule
--  Type        : Private
--  Function    : Validates the position quantity related rule
--  Pre-reqs    :
--  Parameters  :
--
--  validate_pos_quantity_rule Parameters:
--       p_rule_stmt_rec      IN  AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type  Required
--
--  API added for FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 03-Dec-2007
--
--  End of Comments.

PROCEDURE validate_pos_quantity_rule (p_rule_stmt_rec IN AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type)
IS
--
/*
The following cursor retrieves all the relationships, corresponding to the path_position_id for which the rule is defined.
If the version number is populated, which would mean that the rule is version dependent, we will get only one record,
else we will get as many records as the versions of the MC, unless the user deleted the relation in one of the versions.
*/
CURSOR get_relationships_csr (p_position_id IN NUMBER) IS
  SELECT header.mc_header_id, header.name, header.revision, rels.position_key, rels.relationship_id
   FROM AHL_MC_HEADERS_B header,
        AHL_MC_PATH_POSITION_NODES pnodes,
        AHL_MC_RELATIONSHIPS rels
  WHERE pnodes.path_position_id = p_position_id
    AND pnodes.sequence = (select max(sequence) from AHL_MC_PATH_POSITION_NODES where path_position_id = p_position_id)
    AND pnodes.mc_id = header.mc_id
    AND nvl(pnodes.version_number,header.version_number) = header.version_number
    AND rels.mc_header_id = header.mc_header_id
    AND rels.position_key = pnodes.position_key;

CURSOR get_child_rels_csr(p_relationship_id IN NUMBER) IS
  SELECT relationship_id
    FROM AHL_MC_RELATIONSHIPS
   WHERE parent_relationship_id = p_relationship_id;

CURSOR is_rel_nonleaf_node(p_relationship_id IN NUMBER) IS
  SELECT 1
    FROM AHL_MC_RELATIONSHIPS
   WHERE parent_relationship_id = p_relationship_id
     AND rownum = 1;

CURSOR is_rel_subconfig_csr(p_relationship_id IN NUMBER) IS
  SELECT relationship_id
    FROM ahl_mc_config_relations
   WHERE relationship_id = p_relationship_id
     AND rownum = 1;

--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'validate_pos_quantity_rule';
l_stmt_id          NUMBER;
l_rels_rec         get_relationships_csr%ROWTYPE;
L_DEBUG_KEY        CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_pos_quantity_rule';
l_child_rel_id     NUMBER;
l_child_count      NUMBER;
l_dummy            NUMBER;
l_oper_meaning     FND_LOOKUPS.MEANING%TYPE;
l_obj_typ_meaning  FND_LOOKUPS.MEANING%TYPE;
--
BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,L_DEBUG_KEY||'.begin','At the start of PLSQL procedure');
    END IF;

    l_oper_meaning := get_rule_oper(p_rule_stmt_rec.operator, p_rule_stmt_rec.negation_flag);
    l_obj_typ_meaning := get_fnd_lkup_meaning('AHL_MC_RULE_OBJECT_TYPES', p_rule_stmt_rec.object_type);

    OPEN get_relationships_csr(p_rule_stmt_rec.subject_id);
    LOOP
      FETCH get_relationships_csr INTO l_rels_rec;
      EXIT WHEN get_relationships_csr%NOTFOUND;
      --get the child relationship ids. At least one should be present
      --Initialize the child count to zero for every relationship (node).
      l_child_count := 0;
      OPEN get_child_rels_csr(l_rels_rec.relationship_id);
      LOOP
        FETCH get_child_rels_csr INTO l_child_rel_id;
        EXIT WHEN get_child_rels_csr%NOTFOUND;
        l_child_count := l_child_count + 1;

        --If we reached here, it means that there is atleast one child for the node corr. to the passed path position.
        --Now each of the children should be a leaf node.
        OPEN is_rel_nonleaf_node(l_child_rel_id);
        FETCH is_rel_nonleaf_node INTO l_dummy;
        IF(is_rel_nonleaf_node%FOUND) THEN
        --This would mean that the child node is not a leaf node. Throw an error.
          FND_MESSAGE.Set_Name('AHL', 'AHL_MC_QRUL_CHD_LF_NOD');
          FND_MESSAGE.Set_Token('OPERATOR',l_oper_meaning);
          FND_MESSAGE.Set_Token('OBJ_TYPE',l_obj_typ_meaning);
          FND_MESSAGE.Set_Token('MC_NAME',l_rels_rec.name);
          FND_MESSAGE.Set_Token('MC_REV',l_rels_rec.revision);
          FND_MSG_PUB.ADD;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_child_rel_id: ' || l_child_rel_id || 'has children');
          END IF;
        END IF;--IF(is_rel_nonleaf_node%FOUND) THEN
        CLOSE is_rel_nonleaf_node;

        --validate that none of the child nodes are sub-configs
        OPEN is_rel_subconfig_csr(l_child_rel_id);
        FETCH is_rel_subconfig_csr INTO l_dummy;
        IF(is_rel_subconfig_csr%FOUND) THEN
        --This would mean that the child node is a sub-config. Throw an error.
          FND_MESSAGE.Set_Name('AHL', 'AHL_MC_QRUL_CHD_SBC_NOD');
          FND_MESSAGE.Set_Token('OPERATOR',l_oper_meaning);
          FND_MESSAGE.Set_Token('OBJ_TYPE',l_obj_typ_meaning);
          FND_MESSAGE.Set_Token('MC_NAME',l_rels_rec.name);
          FND_MESSAGE.Set_Token('MC_REV',l_rels_rec.revision);
          FND_MSG_PUB.ADD;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_child_rel_id: ' || l_child_rel_id || 'is a sub-configuration');
          END IF;
        END IF;--IF(is_rel_subconfig_csr%FOUND) THEN
        CLOSE is_rel_subconfig_csr;

      END LOOP;--Loop for get_child_rels_csr(l_rels_rec.relationship_id)
      CLOSE get_child_rels_csr;

      IF(l_child_count = 0) THEN
        --This would mean that the relationship node is a leaf node. We cannot define the position quantity rule for a leaf node.
        FND_MESSAGE.Set_Name('AHL', 'AHL_MC_QRUL_CN_LF_NOD');
        FND_MESSAGE.Set_Token('OPERATOR',l_oper_meaning);
        FND_MESSAGE.Set_Token('OBJ_TYPE',l_obj_typ_meaning);
        FND_MESSAGE.Set_Token('MC_NAME',l_rels_rec.name);
        FND_MESSAGE.Set_Token('MC_REV',l_rels_rec.revision);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'l_rels_rec.relationship_id: ' || l_rels_rec.relationship_id || 'does not have children');
        END IF;
      END IF;
    END LOOP;--Loop for get_relationships_csr(p_rule_stmt_rec.subject_id);
    CLOSE get_relationships_csr;

    --object_id has to be NULL
    IF(p_rule_stmt_rec.object_id is not null) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_MC_QRUL_OBJ_NNLL');
        FND_MESSAGE.Set_Token('OPERATOR',l_oper_meaning);
        FND_MESSAGE.Set_Token('OBJ_TYPE',l_obj_typ_meaning);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'p_rule_stmt_rec.object_id: ' || p_rule_stmt_rec.object_id || 'is not null');
        END IF;
    END IF;

    --object_attribute1 is to be non null and should be a positive integer.
    IF(p_rule_stmt_rec.object_attribute1 is NULL) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_MC_QRUL_QUANT_NLL');
        FND_MESSAGE.Set_Token('OPERATOR',l_oper_meaning);
        FND_MESSAGE.Set_Token('OBJ_TYPE',l_obj_typ_meaning);
        FND_MSG_PUB.ADD;
    ELSE
      BEGIN
        IF(MOD(TO_NUMBER(p_rule_stmt_rec.object_attribute1),1) <> 0 OR TO_NUMBER(p_rule_stmt_rec.object_attribute1) <= 0) THEN
          FND_MESSAGE.Set_Name('AHL', 'AHL_MC_QRUL_QUANT_NPOSI');
          FND_MESSAGE.Set_Token('OPERATOR',l_oper_meaning);
          FND_MESSAGE.Set_Token('OBJ_TYPE',l_obj_typ_meaning);
          FND_MSG_PUB.ADD;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.Set_Name('AHL', 'AHL_MC_QRUL_QUANT_NPOSI');
          FND_MESSAGE.Set_Token('OPERATOR',l_oper_meaning);
          FND_MESSAGE.Set_Token('OBJ_TYPE',l_obj_typ_meaning);
          FND_MSG_PUB.ADD;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                           'p_rule_stmt_rec.object_attribute1: ' ||p_rule_stmt_rec.object_attribute1 || 'is not a number');
          END IF;
      END;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,L_DEBUG_KEY||'.end','At the end of PLSQL procedure');
    END IF;

End validate_pos_quantity_rule;

-----------------------------
-- Start of Comments --
--  Procedure name    : validate_quantity_rules_for_mc
--  Type        : Private
--  Function    : Validates the position quantity related rules for MC
--  Pre-reqs    :
--  Parameters  :
--
--  validate_quantity_rules_for_mc Parameters:
--       p_mc_header_id      IN  NUMBER  Required
--
--  API added for FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 03-Dec-2007
--  It is called from AHL_MC_MasterConfig_PVT.Check_MC_Complete
--
--  End of Comments.
PROCEDURE validate_quantity_rules_for_mc(
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_mc_header_id        IN           NUMBER,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2)

IS
--
  --Get the rule statements that are quantity based.
  CURSOR get_quantity_rule_stmt_csr (c_mc_header_id IN NUMBER) IS
   SELECT ruls.subject_id,
          ruls.object_id,
          ruls.rule_statement_id,
          ruls.rule_id,
          ruls.top_rule_stmt_flag,
          ruls.negation_flag,
          ruls.subject_type,
          ruls.operator,
          ruls.object_type,
          ruls.OBJECT_ATTRIBUTE1
     FROM ahl_mc_rules_b rul, ahl_mc_rule_statements ruls
    WHERE rul.rule_id = ruls.rule_id
      AND rul.mc_header_id = p_mc_header_id
      AND ruls.object_type = 'TOT_CHILD_QUANTITY'
      AND TRUNC(nvl(rul.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
      AND TRUNC(nvl(rul.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);

--
l_api_version     CONSTANT NUMBER        := 1.0;
l_api_name        CONSTANT VARCHAR2(30)  := 'validate_quantity_rules_for_mc';
L_DEBUG_KEY       CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.validate_quantity_rules_for_mc';
l_quant_stmt_rec  get_quantity_rule_stmt_csr%ROWTYPE;
l_rstmt_rec       AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type;

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

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,L_DEBUG_KEY||'.begin','At the start of PLSQL procedure');
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_mc_header_id: ' || p_mc_header_id );
  END IF;

  IF(p_mc_header_id is NULL) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_COM_REQD_PARAM_MISSING');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Validate the position quantity rules.
  OPEN get_quantity_rule_stmt_csr (p_mc_header_id);
  LOOP
      FETCH get_quantity_rule_stmt_csr INTO l_quant_stmt_rec;
      EXIT WHEN get_quantity_rule_stmt_csr%NOTFOUND;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                       '  l_quant_stmt_rec.rule_statement_id: ' || l_quant_stmt_rec.rule_statement_id ||
                       ', l_quant_stmt_rec.subject_id: ' || l_quant_stmt_rec.subject_id ||
                       ', l_quant_stmt_rec.object_id: ' || l_quant_stmt_rec.object_id ||
                       ', l_quant_stmt_rec.operator: ' || l_quant_stmt_rec.operator ||
                       ', l_quant_stmt_rec.subject_type: ' || l_quant_stmt_rec.subject_type ||
                       ', l_quant_stmt_rec.object_type: ' || l_quant_stmt_rec.object_type ||
                       ', l_quant_stmt_rec.OBJECT_ATTRIBUTE1: ' || l_quant_stmt_rec.OBJECT_ATTRIBUTE1 );
      END IF;

      l_rstmt_rec.subject_id := l_quant_stmt_rec.subject_id;
      l_rstmt_rec.object_id := l_quant_stmt_rec.object_id;
      l_rstmt_rec.rule_id := l_quant_stmt_rec.rule_id;
      l_rstmt_rec.negation_flag := l_quant_stmt_rec.negation_flag;
      l_rstmt_rec.subject_type := l_quant_stmt_rec.subject_type;
      l_rstmt_rec.operator := l_quant_stmt_rec.operator;
      l_rstmt_rec.object_type := l_quant_stmt_rec.object_type;
      l_rstmt_rec.OBJECT_ATTRIBUTE1:=l_quant_stmt_rec.OBJECT_ATTRIBUTE1;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before calling the validate_pos_quantity_rule ' );
      END IF;
      --calling validate_pos_quantity_rule to validate the rule statement.
      validate_pos_quantity_rule(l_rstmt_rec);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'After calling the validate_pos_quantity_rule ' );
      END IF;

  END LOOP;
  CLOSE get_quantity_rule_stmt_csr;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'x_msg_count: ' ||x_msg_count);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,L_DEBUG_KEY||'.end','At the end of PLSQL procedure');
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
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
  FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

END validate_quantity_rules_for_mc;

--
--Simple function that fetches the translated operator name
--
FUNCTION get_rule_oper(p_rule_oper IN VARCHAR2,
				p_neg_flag IN VARCHAR2)
RETURN VARCHAR2
IS
--
CURSOR get_rule_oper_csr(p_oper IN VARCHAR2, p_neg IN VARCHAR2) IS
SELECT fnd.meaning
  FROM fnd_lookups fnd
   WHERE fnd.lookup_code = decode (p_neg, 'T', p_oper||'_NOT', p_oper)
    AND fnd.lookup_type = 'AHL_MC_RULE_ALL_OPERATORS';
--
l_operator FND_LOOKUPS.MEANING%TYPE;
--
BEGIN
  OPEN get_rule_oper_csr(p_rule_oper, p_neg_flag);
  FETCH get_rule_oper_csr INTO l_operator;
  CLOSE get_rule_oper_csr;
  RETURN l_operator;
END get_rule_oper;

--
-- API added for FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 03-Dec-2007
--
-- Simple function that fetches the translated lookup meaning, given a lookup type and code.
--
FUNCTION get_fnd_lkup_meaning(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
RETURN VARCHAR2
IS
--
CURSOR get_fnd_lkup_meaning_csr(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2) IS
SELECT fnd.meaning
  FROM fnd_lookups fnd
 WHERE fnd.lookup_code = p_lookup_code
   AND fnd.lookup_type = p_lookup_type;
--
l_lkup_meaning FND_LOOKUPS.MEANING%TYPE;
--
BEGIN
  OPEN get_fnd_lkup_meaning_csr(p_lookup_type, p_lookup_code );
  FETCH get_fnd_lkup_meaning_csr INTO l_lkup_meaning;
  CLOSE get_fnd_lkup_meaning_csr;
  RETURN l_lkup_meaning;

END get_fnd_lkup_meaning;

-----------------
End AHL_MC_RULE_STMT_PVT;

/
