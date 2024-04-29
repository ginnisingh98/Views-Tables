--------------------------------------------------------
--  DDL for Package Body AHL_MC_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_RULE_PVT" AS
/* $Header: AHLVMCRB.pls 120.0 2005/05/26 01:16:13 appldev noship $ */
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'Ahl_MC_Rule_Pvt';


------------------------
-- Declare Procedures --
------------------------

--Helper Procedure used to build the rules table
PROCEDURE Build_UI_Rule_Stmt_Tbl (
    p_rule_stmt_id       IN           NUMBER,
    x_rule_stmt_tbl      OUT NOCOPY AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type);

PROCEDURE Build_Rule_Stmt_Tbl (
    p_start_index       IN           NUMBER,
    p_end_index         IN           NUMBER,
    p_rule_id           IN           NUMBER,
    p_ui_stmt_tbl       IN 	     AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    x_rule_stmt_tbl     OUT NOCOPY   AHL_MC_RULE_PVT.Rule_Stmt_Tbl_Type,
    x_rule_stmt_id      OUT NOCOPY   NUMBER);

-----------------
-- Start of Comments --
--  Procedure name    : Load_Rule
--  Type        : Private
--  Function    : Builds the rule record and ui rule table for display purposes
--  Pre-reqs    :
--  Parameters  :
--
--  Load_Rule Parameters:
--       p_rule_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Load_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_id		  IN 	       NUMBER,
    x_rule_stmt_tbl       OUT NOCOPY   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type)
IS
--
 CURSOR  ahl_rule_stmt_csr (p_rule_id IN NUMBER) IS
    SELECT  rule_statement_id
     FROM    ahl_mc_rule_statements stmt
    WHERE   rule_id = p_rule_id
      AND   top_rule_stmt_flag = 'T';
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Load_Rule';
l_rule_stmt_id     NUMBER;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Load_Rule_pvt;

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

  OPEN ahl_rule_stmt_csr(p_rule_id);
  FETCH ahl_rule_stmt_csr INTO l_rule_stmt_id;

  IF (ahl_rule_stmt_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_ID_INV');
       FND_MESSAGE.Set_Token('RULE_STMT_ID',l_rule_stmt_id);
       FND_MSG_PUB.ADD;
       CLOSE ahl_rule_stmt_csr;
       RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE ahl_rule_stmt_csr;

  --Call the API to build the rule table
  Build_UI_Rule_Stmt_Tbl (
       p_rule_stmt_id => l_rule_stmt_id,
       x_rule_stmt_tbl => x_rule_stmt_tbl);

  --Set the sequence number
  FOR i IN x_rule_stmt_tbl.FIRST..x_rule_stmt_tbl.LAST  LOOP
	x_rule_stmt_tbl(i).sequence_num := i*10;
   END LOOP;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Load_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Load_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Load_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

END Load_Rule;

---

-------------------------------
-- Start of Comments --
--  Procedure name    : Build_UI_Rule_Stmt_Tbl
--  Type        : Private
--  Function    : Helper method which builds the rule_stmt table based on rule_stmts.
--  Pre-reqs    :
--  Parameters  :
--
--  End of Comments.

PROCEDURE Build_UI_Rule_Stmt_Tbl (
    p_rule_stmt_id       IN           NUMBER,
    x_rule_stmt_tbl      OUT NOCOPY AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type)
IS
--
CURSOR Check_rule_operator_csr (p_rulestmt_id IN NUMBER) IS
  SELECT rs.operator, rs.subject_id, rs.object_id,
	 fnd.meaning, rs.object_version_number
    FROM ahl_mc_rule_statements rs, fnd_lookups fnd
   WHERE rs.rule_statement_id = p_rulestmt_id
    AND rs.operator = fnd.lookup_code
    AND fnd.lookup_type = 'AHL_MC_RULE_ALL_OPERATORS';
--
CURSOR Rule_stmt_csr (p_rulestmt_id IN NUMBER) IS
 SELECT rs.RULE_STATEMENT_ID,
	rs.subject_ID POSITION_ID,
        AHL_MC_PATH_POSITION_PVT.get_posref_by_id(rs.subject_id, FND_API.G_FALSE) POSITION_MEANING,
	rs.negation_flag,
        rs.operator,
        rs.object_version_number,
	fnd.meaning operator_meaning,
        rs.OBJECT_ID		,
	rs.OBJECT_TYPE		,
	rs.OBJECT_ATTRIBUTE1	,
	rs.OBJECT_ATTRIBUTE2	,
	rs.OBJECT_ATTRIBUTE3	,
	rs.OBJECT_ATTRIBUTE4	,
	rs.OBJECT_ATTRIBUTE5	,
        rs.ATTRIBUTE_CATEGORY   ,
        rs.ATTRIBUTE1           ,
        rs.ATTRIBUTE2           ,
        rs.ATTRIBUTE3           ,
        rs.ATTRIBUTE4           ,
        rs.ATTRIBUTE5           ,
        rs.ATTRIBUTE6    ,
        rs.ATTRIBUTE7            ,
        rs.ATTRIBUTE8            ,
        rs.ATTRIBUTE9            ,
        rs.ATTRIBUTE10           ,
        rs.ATTRIBUTE11           ,
        rs.ATTRIBUTE12           ,
        rs.ATTRIBUTE13           ,
        rs.ATTRIBUTE14           ,
        rs.ATTRIBUTE15
    FROM ahl_mc_rule_statements rs, fnd_lookups fnd
   WHERE rs.rule_statement_id = p_rulestmt_id
    AND fnd.lookup_code = decode (rs.negation_flag, 'T', rs.operator||'_NOT', rs.operator)
    AND fnd.lookup_type = 'AHL_MC_RULE_ALL_OPERATORS';
--
CURSOR get_object_type_csr (p_object_type IN VARCHAR2) IS
SELECT meaning
FROM fnd_lookups
WHERE lookup_code = p_object_type
AND lookup_type = 'AHL_MC_RULE_OBJECT_TYPES';
--
CURSOR get_part_number_csr(p_inv_item_id IN NUMBER) IS
SELECT distinct concatenated_segments
FROM MTL_SYSTEM_ITEMS_KFV
WHERE INVENTORY_ITEM_ID = p_inv_item_id;
--
CURSOR get_position_ref_meaning_csr(p_position_id IN NUMBER) IS
SELECT AHL_MC_PATH_POSITION_PVT.get_posref_by_id(p_position_id)
FROM DUAL;
--
CURSOR get_mc_name_csr (p_mc_id IN NUMBER) IS
SELECT distinct name
FROM ahl_mc_headers_b
WHERE mc_id = p_mc_id;
--
l_operator      AHL_MC_RULE_STATEMENTS.OPERATOR%TYPE;
l_obj_ver_num   NUMBER;
l_oper_meaning  VARCHAR2(80);
l_subject_id    AHL_MC_RULE_STATEMENTS.SUBJECT_ID%TYPE;
l_object_id     AHL_MC_RULE_STATEMENTS.OBJECT_ID%TYPE;
l_subject_tbl   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type;
l_object_tbl    AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type;
l_max           NUMBER;

l_stmt_rec Rule_Stmt_Csr%ROWTYPE;
l_ui_stmt_rec  AHL_MC_RULE_PVT.UI_Rule_Stmt_Rec_Type;
--
BEGIN

   OPEN check_rule_operator_csr(p_rule_stmt_id);
   FETCH check_rule_operator_csr INTO l_operator, l_subject_id,
	l_object_id, l_oper_meaning, l_obj_ver_num;

  --The rule statement has to exist
  IF (check_rule_operator_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_ID_INV');
       FND_MESSAGE.Set_Token('RULE_STMT_ID',p_rule_stmt_id);
       FND_MSG_PUB.ADD;
       CLOSE check_rule_operator_csr;
       RAISE  FND_API.G_EXC_ERROR;
  ELSE

    CLOSE check_rule_operator_csr;
     --Evaluate the subject and object ids
   IF((l_operator = 'OR') OR
	 (l_operator = 'AND') OR
	 (l_operator = 'IMPLIES') OR
	 (l_operator = 'REQUIRES'))
   THEN
     --1) Build the subject table
     Build_UI_Rule_Stmt_Tbl (
       p_rule_stmt_id => l_subject_id,
       x_rule_stmt_tbl => l_subject_tbl);
     --Update the parens.
     IF (l_subject_tbl.COUNT >1) THEN
       l_subject_tbl(l_subject_tbl.FIRST).left_paren :=
		l_subject_tbl(l_subject_tbl.FIRST).left_paren || '(';
       l_subject_tbl(l_subject_tbl.LAST).right_paren :=
		l_subject_tbl(l_subject_tbl.LAST).right_paren || ')';
     END IF;
     --Copy into x_rule_stmt table and update the operator
     FOR i IN l_subject_tbl.FIRST..l_subject_tbl.LAST  LOOP
	x_rule_stmt_tbl(i) := l_subject_tbl(i);
     END LOOP;

     --2) Set the operator
     l_max := x_rule_stmt_tbl.LAST;
     x_rule_stmt_tbl(l_max).rule_operator := l_operator;
     x_rule_stmt_tbl(l_max).rule_operator_meaning := l_oper_meaning;
     x_rule_stmt_tbl(l_max).rule_oper_stmt_id := p_rule_stmt_id;
     x_rule_stmt_tbl(l_max).rule_oper_stmt_obj_ver_num := l_obj_ver_num;

     --3) Build the object table
     Build_UI_Rule_Stmt_Tbl (
       p_rule_stmt_id => l_object_id,
       x_rule_stmt_tbl => l_object_tbl);
     --Update parens and copy for the object table
     IF (l_object_tbl.COUNT >1) THEN
       l_object_tbl(l_object_tbl.FIRST).left_paren :=
		l_object_tbl(l_object_tbl.FIRST).left_paren || '(';
       l_object_tbl(l_object_tbl.LAST).right_paren :=
		l_object_tbl(l_object_tbl.LAST).right_paren || ')';
     END IF;

     --Copy into x_rule_stmt table
     FOR i IN l_object_tbl.FIRST..l_object_tbl.LAST  LOOP
	x_rule_stmt_tbl(l_max+i) := l_object_tbl(i);
     END LOOP;

   ELSE
      --Regular statement query.
      OPEN rule_stmt_csr(p_rule_stmt_id);
      FETCH rule_stmt_csr INTO l_stmt_rec;

      l_ui_stmt_rec.rule_statement_id:= l_stmt_rec.rule_statement_id;
      l_ui_stmt_rec.position_id := l_stmt_rec.position_id;
      l_ui_stmt_rec.position_meaning := l_stmt_rec.position_meaning;

      --Fetch the operator
      IF (l_stmt_rec.negation_flag IS NOT NULL AND
	  l_stmt_rec.negation_flag = 'T') THEN
        l_ui_stmt_rec.operator := l_stmt_rec.operator || '_NOT';
      ELSE
        l_ui_stmt_rec.operator := l_stmt_rec.operator;
      END IF;
      l_ui_stmt_rec.operator_meaning := l_stmt_rec.operator_meaning;

      l_ui_stmt_rec.object_id := l_stmt_rec.object_id;
      l_ui_stmt_rec.object_type := l_stmt_rec.object_type;

      IF (l_stmt_rec.object_type IS NOT NULL) THEN
        OPEN get_object_type_csr(l_stmt_rec.object_type);
        FETCH get_object_type_csr INTO l_ui_stmt_rec.object_type_meaning;
	CLOSE get_object_type_csr;
        IF (l_stmt_rec.object_type = 'ITEM') THEN
          OPEN get_part_number_csr(l_stmt_rec.object_id);
          FETCH get_part_number_csr INTO l_ui_stmt_rec.object_meaning;
	  CLOSE get_part_number_csr;
        ELSIF (l_stmt_rec.object_type = 'CONFIGURATION') THEN
          OPEN get_mc_name_csr(l_stmt_rec.object_id);
          FETCH get_mc_name_csr INTO l_ui_stmt_rec.object_meaning;
   	  CLOSE get_mc_name_csr;
        ELSIF (l_stmt_rec.object_type = 'ITEM_AS_POSITION' OR
               l_stmt_rec.object_type = 'CONFIG_AS_POSITION') THEN
          OPEN get_position_ref_meaning_csr(l_stmt_rec.object_id);
          FETCH get_position_ref_meaning_csr INTO l_ui_stmt_rec.object_meaning;
 	  CLOSE get_position_ref_meaning_csr;
        END IF;
      END IF;
      l_ui_stmt_rec.rule_stmt_obj_ver_num :=l_stmt_rec.OBJECT_VERSION_NUMBER;
      l_ui_stmt_rec.OBJECT_ATTRIBUTE1:=l_stmt_rec.OBJECT_ATTRIBUTE1;
      l_ui_stmt_rec.OBJECT_ATTRIBUTE2	:=l_stmt_rec.OBJECT_ATTRIBUTE2;
      l_ui_stmt_rec.OBJECT_ATTRIBUTE3	:=l_stmt_rec.OBJECT_ATTRIBUTE3;
      l_ui_stmt_rec.OBJECT_ATTRIBUTE4	:=l_stmt_rec.OBJECT_ATTRIBUTE4;
      l_ui_stmt_rec.OBJECT_ATTRIBUTE5	:=l_stmt_rec.OBJECT_ATTRIBUTE5;
      l_ui_stmt_rec.ATTRIBUTE_CATEGORY := l_stmt_rec.ATTRIBUTE_CATEGORY;
      l_ui_stmt_rec.ATTRIBUTE1:= l_stmt_rec.ATTRIBUTE1;
      l_ui_stmt_rec.ATTRIBUTE2:= l_stmt_rec.ATTRIBUTE2;
      l_ui_stmt_rec.ATTRIBUTE3:= l_stmt_rec.ATTRIBUTE3;
      l_ui_stmt_rec.ATTRIBUTE4:= l_stmt_rec.ATTRIBUTE4;
      l_ui_stmt_rec.ATTRIBUTE5:= l_stmt_rec.ATTRIBUTE5;
      l_ui_stmt_rec.ATTRIBUTE6:= l_stmt_rec.ATTRIBUTE6;
      l_ui_stmt_rec.ATTRIBUTE7:= l_stmt_rec.ATTRIBUTE7;
      l_ui_stmt_rec.ATTRIBUTE8:= l_stmt_rec.ATTRIBUTE8;
      l_ui_stmt_rec.ATTRIBUTE9 := l_stmt_rec.ATTRIBUTE9;
      l_ui_stmt_rec.ATTRIBUTE10:= l_stmt_rec.ATTRIBUTE10 ;
      l_ui_stmt_rec.ATTRIBUTE11:= l_stmt_rec.ATTRIBUTE11 ;
      l_ui_stmt_rec.ATTRIBUTE12:= l_stmt_rec.ATTRIBUTE12 ;
      l_ui_stmt_rec.ATTRIBUTE13:= l_stmt_rec.ATTRIBUTE13;
      l_ui_stmt_rec.ATTRIBUTE14:= l_stmt_rec.ATTRIBUTE14;
      l_ui_stmt_rec.ATTRIBUTE15:= l_stmt_rec.ATTRIBUTE15;

      x_rule_stmt_tbl(1) :=l_ui_stmt_rec;

      CLOSE rule_stmt_csr;
   END IF;

  END IF;

END Build_UI_Rule_Stmt_Tbl;


-------------------------------
-- Start of Comments --
--  Procedure name    : Build_Rule_Tree
--  Type        : Private
--  Function    : Helper method which builds the rule tree from the ui
-- 		  rule table.
--  Assumptions : 1) Table is densely populated. 2) Table is sorted by sequence.
--  Pre-reqs    :
--  Parameters  :
--
--  End of Comments.

PROCEDURE Build_Rule_Tree (
	p_rule_id        IN NUMBER,
        p_rule_stmt_tbl  IN  AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
	x_rule_stmt_tbl  OUT NOCOPY AHL_MC_RULE_PVT.Rule_Stmt_Tbl_Type)
IS
--
l_ui_stmt_tbl  AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type;
l_ui_stmt_rec  AHL_MC_RULE_PVT.UI_Rule_Stmt_Rec_Type;
l_depth_count  NUMBER;
l_rule_stmt_id NUMBER;
l_msg_count     NUMBER;
--
BEGIN
   IF (p_rule_stmt_tbl.COUNT<1)  THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_NULL');
       FND_MSG_PUB.ADD;
       RAISE  FND_API.G_EXC_ERROR;
   END IF;

   l_depth_count :=0;

   --Do initial preprocess
   FOR i IN p_rule_stmt_tbl.FIRST..p_rule_stmt_tbl.LAST  LOOP
       l_ui_stmt_rec := p_rule_stmt_tbl(i);

       --Check that the parens are only valid characters
       IF (ltrim(l_ui_stmt_rec.left_paren, '(' ) IS NOT NULL OR
	   ltrim(l_ui_stmt_rec.right_paren, ')' ) IS NOT NULL) THEN
   	  FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_PAREN_INV');
          FND_MSG_PUB.ADD;
       END IF;

       --Check that the left parens>0 and right_paren>0 is an error
       IF (length(l_ui_stmt_rec.left_paren) > 0 AND
	   length(l_ui_stmt_rec.right_paren) > 0 ) THEN
   	  FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_PAREN_DUP');
          FND_MSG_PUB.ADD;
       END IF;

       --Calculate the depth and assign to statement
       l_depth_count:=l_depth_count+nvl(length(l_ui_stmt_rec.left_paren),0);
       l_ui_stmt_rec.rule_stmt_depth := l_depth_count;
       l_depth_count:=l_depth_count-nvl(length(l_ui_stmt_rec.right_paren),0);
       l_ui_stmt_rec.rule_oper_stmt_depth := l_depth_count;

       IF (l_depth_count < 0 )  THEN
         FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_PAREN_UNMATCH');
         FND_MSG_PUB.ADD;
       END IF;

       l_ui_stmt_tbl(i) := l_ui_stmt_rec;
   END LOOP;


   --Check that the left parens>1 and right_paren>1
   IF (l_depth_count <>0)  THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_PAREN_UNMATCH');
       FND_MSG_PUB.ADD;
   END IF;

   -- Check Error Message stack.
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   Build_Rule_Stmt_Tbl(
	p_start_index   => l_ui_stmt_tbl.FIRST,
	p_end_index     => l_ui_stmt_tbl.LAST,
        p_rule_id       => p_rule_id,
	p_ui_stmt_tbl   => l_ui_stmt_tbl,
	x_rule_stmt_tbl => x_rule_stmt_tbl,
	x_rule_stmt_id  => l_rule_stmt_id);

  --Set the last rule as the top rule statement
  x_rule_stmt_tbl(x_rule_stmt_tbl.LAST).top_rule_stmt_flag := 'T';

END Build_Rule_Tree;
-------------------------------
-- Start of Comments --
--  Procedure name    : Build_Rule_Stmt_Tbl
--  Type        : Private
--  Function    : Helper method which builds the rule_stmt tree based on ui_rule_stmts.
--  Pre-reqs    :
--  Parameters  :
--
--  End of Comments.

PROCEDURE Build_Rule_Stmt_Tbl (
    p_start_index       IN           NUMBER,
    p_end_index         IN           NUMBER,
    p_rule_id           IN           NUMBER,
    p_ui_stmt_tbl       IN 	     AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    x_rule_stmt_tbl     OUT NOCOPY   AHL_MC_RULE_PVT.Rule_Stmt_Tbl_Type,
    x_rule_stmt_id      OUT NOCOPY   NUMBER)
IS
--
CURSOR next_rule_stmt_id_csr IS
SELECT ahl_mc_rule_statements_s.nextval FROM DUAL;

--
l_stmt_rec         AHL_MC_RULE_PVT.Rule_Stmt_Rec_Type;
l_ui_stmt_rec      AHL_MC_RULE_PVT.UI_Rule_Stmt_Rec_Type;
l_subject_stmt_tbl AHL_MC_RULE_PVT.Rule_Stmt_Tbl_Type;
l_object_stmt_tbl  AHL_MC_RULE_PVT.Rule_Stmt_Tbl_Type;
l_subject_id       NUMBER;            --subject stmt id
l_object_id        NUMBER;            --object stmt id
l_operator         VARCHAR2(30);      --rule operator
l_operation_flag   VARCHAR2(1);
l_max              NUMBER;
l_min_depth_index  NUMBER;
l_min_depth        NUMBER;
l_rstmt_obj_ver_num NUMBER;
--
BEGIN

   --Convert if only 1 record
   IF (p_start_index = p_end_index)
   THEN
      l_ui_stmt_rec := p_ui_stmt_tbl(p_start_index);
      IF (l_ui_stmt_rec.rule_statement_id IS NOT NULL)
      THEN
         x_rule_stmt_id:=l_ui_stmt_rec.rule_statement_id;
         l_rstmt_obj_ver_num :=l_ui_stmt_rec.rule_stmt_obj_ver_num;
	 l_operation_flag := 'U';
      ELSE
         OPEN next_rule_stmt_id_csr;
         FETCH next_rule_stmt_id_csr INTO x_rule_stmt_id;
	 CLOSE next_rule_stmt_id_csr;
         l_rstmt_obj_ver_num :=1;
         l_operation_flag := 'I';
      END IF;

      --Convert operator to negation_flag
      IF (INSTR(l_ui_stmt_rec.operator, '_NOT') >0)
      THEN
        l_stmt_rec.NEGATION_FLAG := 'T';
        l_stmt_rec.OPERATOR      := RTRIM(l_ui_stmt_rec.operator,'_NOT');
      ELSE
        l_stmt_rec.NEGATION_FLAG := NULL;
        l_stmt_rec.OPERATOR      := l_ui_stmt_rec.operator;
      END IF;

      l_stmt_rec.rule_statement_id:= x_rule_stmt_id;
      l_stmt_rec.RULE_ID := p_rule_id;
      l_stmt_rec.TOP_RULE_STMT_FLAG := NULL;
      l_stmt_rec.OBJECT_VERSION_NUMBER := l_rstmt_obj_ver_num;
      l_stmt_rec.SUBJECT_ID    := l_ui_stmt_rec.POSITION_ID;
      l_stmt_rec.SUBJECT_TYPE  := 'POSITION';
      l_stmt_rec.OBJECT_TYPE   := l_ui_stmt_rec.OBJECT_TYPE;
      IF (l_ui_stmt_rec.OBJECT_TYPE IS NULL) THEN
         l_stmt_rec.OBJECT_ID     := null;
      ELSE
         l_stmt_rec.OBJECT_ID     := l_ui_stmt_rec.OBJECT_ID;
      END IF;
      l_stmt_rec.OBJECT_ATTRIBUTE1:=l_ui_stmt_rec.OBJECT_ATTRIBUTE1;
      l_stmt_rec.OBJECT_ATTRIBUTE2:=l_ui_stmt_rec.OBJECT_ATTRIBUTE2;
      l_stmt_rec.OBJECT_ATTRIBUTE3:=l_ui_stmt_rec.OBJECT_ATTRIBUTE3;
      l_stmt_rec.OBJECT_ATTRIBUTE4:=l_ui_stmt_rec.OBJECT_ATTRIBUTE4;
      l_stmt_rec.OBJECT_ATTRIBUTE5:=l_ui_stmt_rec.OBJECT_ATTRIBUTE5;
      l_stmt_rec.ATTRIBUTE_CATEGORY:= l_ui_stmt_rec.ATTRIBUTE_CATEGORY;
      l_stmt_rec.ATTRIBUTE1:= l_ui_stmt_rec.ATTRIBUTE1;
      l_stmt_rec.ATTRIBUTE2:= l_ui_stmt_rec.ATTRIBUTE2;
      l_stmt_rec.ATTRIBUTE3:= l_ui_stmt_rec.ATTRIBUTE3;
      l_stmt_rec.ATTRIBUTE4:= l_ui_stmt_rec.ATTRIBUTE4;
      l_stmt_rec.ATTRIBUTE5:= l_ui_stmt_rec.ATTRIBUTE5;
      l_stmt_rec.ATTRIBUTE6:= l_ui_stmt_rec.ATTRIBUTE6;
      l_stmt_rec.ATTRIBUTE7:= l_ui_stmt_rec.ATTRIBUTE7;
      l_stmt_rec.ATTRIBUTE8:= l_ui_stmt_rec.ATTRIBUTE8;
      l_stmt_rec.ATTRIBUTE9 := l_ui_stmt_rec.ATTRIBUTE9;
      l_stmt_rec.ATTRIBUTE10:= l_ui_stmt_rec.ATTRIBUTE10 ;
      l_stmt_rec.ATTRIBUTE11:= l_ui_stmt_rec.ATTRIBUTE11 ;
      l_stmt_rec.ATTRIBUTE12:= l_ui_stmt_rec.ATTRIBUTE12 ;
      l_stmt_rec.ATTRIBUTE13:= l_ui_stmt_rec.ATTRIBUTE13;
      l_stmt_rec.ATTRIBUTE14:= l_ui_stmt_rec.ATTRIBUTE14;
      l_stmt_rec.ATTRIBUTE15:= l_ui_stmt_rec.ATTRIBUTE15;
      l_stmt_rec.operation_flag := l_operation_flag;
      x_rule_stmt_tbl(1) := l_stmt_rec;

   ELSE
      --Recursive rule parsing portion
      l_min_depth  := p_ui_stmt_tbl.COUNT;
      l_min_depth_index := -1;

      --Find minimum depth index
      FOR i IN p_start_index..p_end_index-1  LOOP
        IF (p_ui_stmt_tbl(i).rule_oper_stmt_depth < l_min_depth)
	THEN
            l_min_depth := p_ui_stmt_tbl(i).rule_oper_stmt_depth;
	    l_min_depth_index := i;
        END IF;
      END LOOP;

      --If we did not find the min depth, then throw an error.
      IF (l_min_depth_index = -1)  THEN
         FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_MIN_INV');
         FND_MSG_PUB.ADD;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

      --Determine the operator and the operations flag
      l_operator := p_ui_stmt_tbl(l_min_depth_index).rule_operator;
      IF (p_ui_stmt_tbl(l_min_depth_index).rule_oper_stmt_id IS NOT NULL)
      THEN
         x_rule_stmt_id:=p_ui_stmt_tbl(l_min_depth_index).rule_oper_stmt_id;
    	 l_rstmt_obj_ver_num :=l_ui_stmt_rec.rule_oper_stmt_obj_ver_num;
	 l_operation_flag := 'U';
      ELSE
         OPEN next_rule_stmt_id_csr;
         FETCH next_rule_stmt_id_csr INTO x_rule_stmt_id;
	 CLOSE next_rule_stmt_id_csr;
         l_rstmt_obj_ver_num :=1;
	 l_operation_flag := 'I';
      END IF;

      --If the operator is null, then throw error.
      IF (l_operator IS NULL)  THEN
         FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_OPER_NULL');
         FND_MSG_PUB.ADD;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;


      --1) Build the subject table
      Build_Rule_Stmt_Tbl(
	p_start_index   => p_start_index,
	p_end_index     => l_min_depth_index,
	p_rule_id       => p_rule_id,
	p_ui_stmt_tbl   => p_ui_stmt_tbl,
	x_rule_stmt_tbl => l_subject_stmt_tbl,
	x_rule_stmt_id  => l_subject_id);

      --2) Build the object table
      Build_Rule_Stmt_Tbl(
	p_start_index   => l_min_depth_index+1,
	p_end_index     => p_end_index,
	p_rule_id       => p_rule_id,
	p_ui_stmt_tbl   => p_ui_stmt_tbl,
	x_rule_stmt_tbl => l_object_stmt_tbl,
	x_rule_stmt_id  => l_object_id
	);

      --3)Copy into x_rule_stmt table and update the operator
      FOR i IN l_subject_stmt_tbl.FIRST..l_subject_stmt_tbl.LAST  LOOP
 	 x_rule_stmt_tbl(i) := l_subject_stmt_tbl(i);
      END LOOP;

      --4) Copy the object stmt table into x_rule_stmt table
      l_max := x_rule_stmt_tbl.LAST;
      FOR i IN l_object_stmt_tbl.FIRST..l_object_stmt_tbl.LAST  LOOP
	 x_rule_stmt_tbl(l_max+i) := l_object_stmt_tbl(i);
      END LOOP;

      --5) Insert the join statement
      l_max := x_rule_stmt_tbl.LAST;
      l_stmt_rec.rule_statement_id:= x_rule_stmt_id;
      l_stmt_rec.RULE_ID  := p_rule_id;
      l_stmt_rec.OBJECT_VERSION_NUMBER :=l_rstmt_obj_ver_num;
      l_stmt_rec.NEGATION_FLAG := NULL;
      l_stmt_rec.TOP_RULE_STMT_FLAG := NULL;
      l_stmt_rec.SUBJECT_ID    := l_subject_id;
      l_stmt_rec.SUBJECT_TYPE  := 'RULE_STMT';
      l_stmt_rec.OPERATOR      := l_operator;
      l_stmt_rec.OBJECT_ID     := l_object_id;
      l_stmt_rec.OBJECT_TYPE   := 'RULE_STMT';
      l_stmt_rec.OBJECT_ATTRIBUTE1  := NULL;
      l_stmt_rec.OBJECT_ATTRIBUTE2  := NULL;
      l_stmt_rec.OBJECT_ATTRIBUTE3  := NULL;
      l_stmt_rec.OBJECT_ATTRIBUTE4  := NULL;
      l_stmt_rec.OBJECT_ATTRIBUTE5  := NULL;
      l_stmt_rec.ATTRIBUTE_CATEGORY := NULL;
      l_stmt_rec.ATTRIBUTE1:= NULL;
      l_stmt_rec.ATTRIBUTE2:= NULL;
      l_stmt_rec.ATTRIBUTE3:= NULL;
      l_stmt_rec.ATTRIBUTE4:= NULL;
      l_stmt_rec.ATTRIBUTE5:= NULL;
      l_stmt_rec.ATTRIBUTE6:= NULL;
      l_stmt_rec.ATTRIBUTE7:= NULL;
      l_stmt_rec.ATTRIBUTE8:= NULL;
      l_stmt_rec.ATTRIBUTE9 := NULL;
      l_stmt_rec.ATTRIBUTE10:= NULL;
      l_stmt_rec.ATTRIBUTE11:= NULL;
      l_stmt_rec.ATTRIBUTE12:= NULL;
      l_stmt_rec.ATTRIBUTE13:= NULL;
      l_stmt_rec.ATTRIBUTE14:= NULL;
      l_stmt_rec.ATTRIBUTE15:= NULL;
      l_stmt_rec.operation_flag := l_operation_flag;

      x_rule_stmt_tbl(l_max+1) :=l_stmt_rec;

  END IF;


END Build_Rule_Stmt_Tbl;


--------------------------------
-- Start of Comments --
--  Procedure name    : Insert_Rule
--  Type        : Private
--  Function    : Writes to DB the rule record and ui rule table
--  Pre-reqs    :
--  Parameters  :
--
--  Insert_Rule Parameters:
--       p_x_rule_rec      IN OUT NOCOPY AHL_MC_RULE_PVT.Rule_Rec_Type Required
--	 p_rule_stmt_tbl IN   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type Required
--
--  End of Comments.

PROCEDURE Insert_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module		  IN           VARCHAR2 := 'JSP',
    p_rule_stmt_tbl       IN 	   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    p_x_rule_rec 	  IN OUT NOCOPY  AHL_MC_RULE_PVT.Rule_Rec_Type)
IS
--
CURSOR check_mc_status_csr (p_header_id  IN  NUMBER) IS
   SELECT  config_status_code, config_status_meaning
     FROM    ahl_mc_headers_v header
     WHERE  header.mc_header_id = p_header_id;
--
CURSOR Check_rule_type_csr (p_type IN VARCHAR2) IS
SELECT 'X'
 FROM  FND_LOOKUPS
WHERE lookup_code = p_type
  AND lookup_type = 'AHL_MC_RULE_TYPES';
--
CURSOR Check_rule_name_csr (p_name IN VARCHAR2, p_mc_header_id IN NUMBER) IS
SELECT 'X'
 FROM  AHL_MC_RULES_B
WHERE mc_header_id = p_mc_header_id
  AND rule_name = p_name;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Insert_Rule';
l_junk 		   VARCHAR2(1);
l_status_code      VARCHAR2(30);
l_status           VARCHAR2(80);
l_rule_stmt_tbl    AHL_MC_RULE_PVT.Rule_Stmt_Tbl_Type;
l_row_id	   VARCHAR2(30);
--
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Insert_Rule_pvt;
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
  OPEN check_mc_status_csr(p_x_rule_rec.mc_header_id);
  FETCH check_mc_status_csr INTO l_status_code, l_status;
  IF (check_mc_status_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_HEADER_ID_INVALID');
       FND_MESSAGE.Set_Token('NAME','');
       FND_MESSAGE.Set_Token('MC_HEADER_ID',p_x_rule_rec.mc_header_id);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  ELSIF ( l_status_code <> 'DRAFT' AND
	  l_status_code <> 'APPROVAL_REJECTED') THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_EDIT_INV_MC');
       FND_MESSAGE.Set_Token('STATUS', l_status);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_mc_status_csr;

  IF (p_module = 'JSP') THEN

    IF (p_x_rule_rec.DESCRIPTION = FND_API.G_MISS_CHAR) THEN
        p_x_rule_rec.DESCRIPTION := null;
    END IF;

    IF (p_x_rule_rec.RULE_NAME = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.RULE_NAME := null;
    END IF;
    IF (p_x_rule_rec.RULE_TYPE_CODE = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.RULE_TYPE_CODE := null;
    END IF;
    IF (p_x_rule_rec.ACTIVE_START_DATE = FND_API.G_MISS_DATE) THEN
        p_x_rule_rec.ACTIVE_START_DATE := null;
    END IF;
    IF (p_x_rule_rec.ACTIVE_END_DATE = FND_API.G_MISS_DATE) THEN
        p_x_rule_rec.ACTIVE_END_DATE := null;
    END IF;
    IF (p_x_rule_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE_CATEGORY := null;
    END IF;
    IF (p_x_rule_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
        p_x_rule_rec.ATTRIBUTE1 := null;
    END IF;
    IF (p_x_rule_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
        p_x_rule_rec.ATTRIBUTE2 := null;
    END IF;

    IF (p_x_rule_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
        p_x_rule_rec.ATTRIBUTE3 := null;
    END IF;
    IF (p_x_rule_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
        p_x_rule_rec.ATTRIBUTE4 := null;
    END IF;
    IF (p_x_rule_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
        p_x_rule_rec.ATTRIBUTE5 := null;
    END IF;
    IF (p_x_rule_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE6 := null;
    END IF;

    IF (p_x_rule_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE7 := null;
    END IF;
    IF (p_x_rule_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE8 := null;
    END IF;
    IF (p_x_rule_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE9 := null;
    END IF;
      IF (p_x_rule_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE10 := null;
    END IF;
      IF (p_x_rule_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE11 := null;
   END IF;
      IF (p_x_rule_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE12 := null;
   END IF;
     IF (p_x_rule_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE13 := null;
   END IF;
   IF (p_x_rule_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE14 := null;
   END IF;
   IF (p_x_rule_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
       p_x_rule_rec.ATTRIBUTE15 := null;
   END IF;
  END IF;

  --Check Rule Name is not null
  IF (p_x_rule_rec.rule_name IS NULL) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_NAME_NULL');
       FND_MSG_PUB.ADD;
  END IF;

  --Check Rule Type is valid
  OPEN check_rule_type_csr(p_x_rule_rec.rule_type_code);
  FETCH check_rule_type_csr INTO l_junk;
  IF (check_rule_type_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_TYPE_INV');
       FND_MESSAGE.Set_Token('RULE_TYPE',p_x_rule_rec.rule_type_code);
       FND_MSG_PUB.ADD;
  END IF;
  CLOSE check_rule_type_csr;

  --Check start date is less than end date
  IF (p_x_rule_rec.active_start_date IS NOT NULL AND
      p_x_rule_rec.active_end_date IS NOT NULL AND
      p_x_rule_rec.active_start_date >= p_x_rule_rec.active_end_date) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_DATE_INVALID');
       FND_MESSAGE.Set_Token('SDATE',p_x_rule_rec.active_start_date);
       FND_MESSAGE.Set_Token('EDATE',p_x_rule_rec.active_end_date);
       FND_MSG_PUB.ADD;
  END IF;

  --Check Rule name is unique
  OPEN check_rule_name_csr(p_x_rule_rec.rule_name, p_x_rule_rec.mc_header_id);
  FETCH check_rule_name_csr INTO l_junk;
  IF (check_rule_name_csr%FOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_NAME_INV');
       FND_MESSAGE.Set_Token('RULE_NAME', p_x_rule_rec.rule_name);
       FND_MSG_PUB.ADD;
  END IF;
  CLOSE check_rule_name_csr;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  SELECT AHL_MC_RULES_B_S.nextval
       INTO p_x_rule_rec.rule_id
       FROM dual;

  --Convert the flat structure into a rule tree.
  Build_rule_tree( p_rule_id => p_x_rule_rec.rule_id,
	 	   p_rule_stmt_tbl=> p_rule_stmt_tbl,
		   x_rule_stmt_tbl=> l_rule_stmt_tbl);

  --Insert the Rule Record
  AHL_MC_RULES_PKG.INSERT_ROW (
    X_ROWID =>   l_row_id,
    X_RULE_ID => p_x_rule_rec.rule_id,
    X_OBJECT_VERSION_NUMBER => 1,
    X_RULE_NAME => p_x_rule_rec.rule_name,
    X_MC_HEADER_ID => p_x_rule_rec.mc_header_id,
    X_RULE_TYPE_CODE => p_x_rule_rec.rule_type_code,
    X_ACTIVE_START_DATE => p_x_rule_rec.active_start_date,
    X_ACTIVE_END_DATE => p_x_rule_rec.active_end_date,
    X_ATTRIBUTE_CATEGORY => p_x_rule_rec.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1 => p_x_rule_rec.ATTRIBUTE1,
    X_ATTRIBUTE2 => p_x_rule_rec.ATTRIBUTE2,
    X_ATTRIBUTE3 => p_x_rule_rec.ATTRIBUTE3,
    X_ATTRIBUTE4 => p_x_rule_rec.ATTRIBUTE4,
    X_ATTRIBUTE5 => p_x_rule_rec.ATTRIBUTE5,
    X_ATTRIBUTE6 => p_x_rule_rec.ATTRIBUTE6,
    X_ATTRIBUTE7 => p_x_rule_rec.ATTRIBUTE7,
    X_ATTRIBUTE8 => p_x_rule_rec.ATTRIBUTE8,
    X_ATTRIBUTE9 => p_x_rule_rec.ATTRIBUTE9,
    X_ATTRIBUTE10 => p_x_rule_rec.ATTRIBUTE10,
    X_ATTRIBUTE11 => p_x_rule_rec.ATTRIBUTE11,
    X_ATTRIBUTE12 => p_x_rule_rec.ATTRIBUTE12,
    X_ATTRIBUTE13 => p_x_rule_rec.ATTRIBUTE13,
    X_ATTRIBUTE14 => p_x_rule_rec.ATTRIBUTE14,
    X_ATTRIBUTE15 => p_x_rule_rec.ATTRIBUTE15,
     X_DESCRIPTION => p_x_rule_rec.description,
     X_CREATION_DATE         => SYSDATE,
     X_CREATED_BY            => Fnd_Global.USER_ID,
     X_LAST_UPDATE_DATE      => SYSDATE,
     X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
     X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID);

  --Insert the Rule statement Records
  FOR i IN l_rule_stmt_tbl.FIRST..l_rule_stmt_tbl.LAST LOOP
      AHL_MC_RULE_STMT_PVT.Insert_Rule_Stmt (
    		p_api_version  => 1.0,
    	        p_commit       => FND_API.G_FALSE,
                p_module       =>  p_module,
       	        p_x_rule_stmt_rec     => l_rule_stmt_tbl(i),
	        x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);

      -- Check Error Message stack.
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count > 0 THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;
  END LOOP;

  --Update the status to Draft if approval rejected
  IF (l_status_code = 'APPROVAL_REJECTED')
  THEN
	UPDATE ahl_mc_headers_b
	SET config_status_code = 'DRAFT'
	WHERE mc_header_id = p_x_rule_rec.mc_header_id;
  END IF;

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
   Rollback to Insert_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Insert_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Insert_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

END Insert_Rule;

--------------------------------
-- Start of Comments --
--  Procedure name    : Update_Rule
--  Type        : Private
--  Function    : Writes to DB the rule record and ui rule table
--  Pre-reqs    :
--  Parameters  :
--
--  Update_Rule Parameters:
--       p_rule_rec      IN   AHL_MC_RULE_PVT.Rule_Rec_Type Required
--	 p_rule_stmt_tbl IN   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type Required
--
--  End of Comments.

PROCEDURE Update_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module		  IN           VARCHAR2  := 'JSP',
    p_rule_rec 	  	  IN       AHL_MC_RULE_PVT.Rule_Rec_Type,
    p_rule_stmt_tbl       IN 	   AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type)
IS
--
CURSOR get_rule_rec_csr (p_rule_id IN NUMBER) IS
SELECT *
 FROM  AHL_MC_RULES_VL
WHERE rule_id = p_rule_id;
--
CURSOR Check_rule_type_csr (p_type IN VARCHAR2) IS
SELECT 'X'
 FROM  FND_LOOKUPS
WHERE lookup_code = p_type
  AND lookup_type = 'AHL_MC_RULE_TYPES';
--
CURSOR Check_rule_name_csr (p_name IN VARCHAR2,
			    p_mc_header_id IN NUMBER,
		            p_rule_id IN NUMBER) IS
SELECT 'X'
 FROM  AHL_MC_RULES_B
WHERE mc_header_id = p_mc_header_id
  AND rule_name = p_name
  AND rule_id <> p_rule_id;
--
--This cursor fetches all rule statements for given rule_id
CURSOR get_rule_stmt_ids_csr (p_rule_id  IN  NUMBER) IS
   SELECT rule_statement_id
      FROM    ahl_mc_rule_statements
     WHERE rule_id = p_rule_id;
--
CURSOR check_mc_status_csr (p_rule_id  IN  NUMBER) IS
  SELECT  config_status_code, config_status_meaning
     FROM    ahl_mc_rules_b rule, ahl_mc_headers_v header
     WHERE  rule.mc_header_id = header.mc_header_id
     AND    rule.rule_id = p_rule_id;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Update_Rule';
l_junk 		   VARCHAR2(1);
l_status_code      VARCHAR2(30);
l_status           VARCHAR2(80);
l_rule_stmt_tbl    AHL_MC_RULE_PVT.Rule_Stmt_Tbl_Type;
l_rule_rec         AHL_MC_RULE_PVT.Rule_Rec_Type;
l_old_rule_rec     Get_rule_rec_csr%ROWTYPE;
l_rule_stmt_id     NUMBER;
l_match_flag       BOOLEAN;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Update_Rule_pvt;
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
  OPEN check_mc_status_csr(p_rule_rec.rule_id);
  FETCH check_mc_status_csr INTO l_status_code, l_status;
  IF (check_mc_status_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_ID_INV');
       FND_MESSAGE.Set_Token('RULE_ID',p_rule_rec.rule_id);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  ELSIF ( l_status_code <> 'DRAFT' AND
	  l_status_code <> 'APPROVAL_REJECTED') THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_EDIT_INV_MC');
       FND_MESSAGE.Set_Token('STATUS', l_status);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_mc_status_csr;


  --Check Rule ID is valid
  OPEN get_rule_rec_csr(p_rule_rec.rule_id);
  FETCH get_rule_rec_csr INTO l_old_rule_rec;
  IF (get_rule_rec_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_ID_INV');
       FND_MESSAGE.Set_Token('RULE_ID', p_rule_rec.rule_id);
       FND_MSG_PUB.ADD;
  END IF;
  CLOSE get_rule_rec_csr;

  --Assign to local Var
  l_rule_rec := p_rule_rec;
   -- Check Object version number.
  IF (l_rule_rec.object_version_number IS NOT NULL AND
      l_old_rule_rec.object_version_number<>l_rule_rec.object_version_number)
  THEN
      FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Convert NULL/G_MISS types
  IF (p_module = 'JSP') THEN
   IF (l_rule_rec.DESCRIPTION IS NULL) THEN
     l_rule_rec.DESCRIPTION := l_old_rule_rec.DESCRIPTION;
   ELSIF (l_rule_rec.DESCRIPTION = FND_API.G_MISS_CHAR) THEN
      l_rule_rec.DESCRIPTION := NULL;
   END IF;
   IF (l_rule_rec.RULE_NAME IS NULL) THEN
     l_rule_rec.RULE_NAME := l_old_rule_rec.RULE_NAME;
   ELSIF (l_rule_rec.RULE_NAME = FND_API.G_MISS_CHAR) THEN
      l_rule_rec.RULE_NAME := NULL;
   END IF;
   IF (l_rule_rec.RULE_TYPE_CODE IS NULL) THEN
     l_rule_rec.RULE_TYPE_CODE := l_old_rule_rec.RULE_TYPE_CODE;
   ELSIF (l_rule_rec.RULE_TYPE_CODE = FND_API.G_MISS_CHAR) THEN
      l_rule_rec.RULE_TYPE_CODE := NULL;
   END IF;
   IF (l_rule_rec.ACTIVE_START_DATE IS NULL) THEN
     l_rule_rec.ACTIVE_START_DATE := l_old_rule_rec.ACTIVE_START_DATE;
   ELSIF (l_rule_rec.ACTIVE_START_DATE = FND_API.G_MISS_DATE) THEN
      l_rule_rec.ACTIVE_START_DATE := NULL;
   END IF;
   IF (l_rule_rec.ACTIVE_END_DATE IS NULL) THEN
     l_rule_rec.ACTIVE_END_DATE := l_old_rule_rec.ACTIVE_END_DATE;
   ELSIF (l_rule_rec.ACTIVE_END_DATE = FND_API.G_MISS_DATE) THEN
      l_rule_rec.ACTIVE_END_DATE := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE_CATEGORY IS NULL) THEN
     l_rule_rec.ATTRIBUTE_CATEGORY := l_old_rule_rec.ATTRIBUTE_CATEGORY;
   ELSIF (l_rule_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
      l_rule_rec.ATTRIBUTE_CATEGORY := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE1 IS NULL) THEN
       l_rule_rec.ATTRIBUTE1 := l_old_rule_rec.ATTRIBUTE1;
   ELSIF (l_rule_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE1 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE2 IS NULL) THEN
       l_rule_rec.ATTRIBUTE2 := l_old_rule_rec.ATTRIBUTE2;
   ELSIF (l_rule_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE2 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE3 IS NULL) THEN
       l_rule_rec.ATTRIBUTE3 := l_old_rule_rec.ATTRIBUTE3;
   ELSIF (l_rule_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE3 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE4 IS NULL) THEN
       l_rule_rec.ATTRIBUTE4 := l_old_rule_rec.ATTRIBUTE4;
   ELSIF (l_rule_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE4 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE5 IS NULL) THEN
       l_rule_rec.ATTRIBUTE5 := l_old_rule_rec.ATTRIBUTE5;
   ELSIF (l_rule_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE5 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE6 IS NULL) THEN
       l_rule_rec.ATTRIBUTE6 := l_old_rule_rec.ATTRIBUTE6;
   ELSIF (l_rule_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE6 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE7 IS NULL) THEN
       l_rule_rec.ATTRIBUTE7 := l_old_rule_rec.ATTRIBUTE7;
   ELSIF (l_rule_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE7 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE8 IS NULL) THEN
       l_rule_rec.ATTRIBUTE8 := l_old_rule_rec.ATTRIBUTE8;
   ELSIF (l_rule_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE8 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE9 IS NULL) THEN
       l_rule_rec.ATTRIBUTE9 := l_old_rule_rec.ATTRIBUTE9;
   ELSIF (l_rule_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE9 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE10 IS NULL) THEN
       l_rule_rec.ATTRIBUTE10 := l_old_rule_rec.ATTRIBUTE10;
   ELSIF (l_rule_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE10 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE11 IS NULL) THEN
       l_rule_rec.ATTRIBUTE11 := l_old_rule_rec.ATTRIBUTE11;
   ELSIF (l_rule_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE11 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE12 IS NULL) THEN
       l_rule_rec.ATTRIBUTE12 := l_old_rule_rec.ATTRIBUTE12;
   ELSIF (l_rule_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE12 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE13 IS NULL) THEN
       l_rule_rec.ATTRIBUTE13 := l_old_rule_rec.ATTRIBUTE13;
   ELSIF (l_rule_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE13 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE14 IS NULL) THEN
       l_rule_rec.ATTRIBUTE14 := l_old_rule_rec.ATTRIBUTE14;
   ELSIF (l_rule_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE14 := NULL;
   END IF;
   IF (l_rule_rec.ATTRIBUTE15 IS NULL) THEN
       l_rule_rec.ATTRIBUTE15 := l_old_rule_rec.ATTRIBUTE15;
   ELSIF (l_rule_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
       l_rule_rec.ATTRIBUTE15 := NULL;
   END IF;

  END IF;


  --Check Rule Name is not null
  IF (l_rule_rec.rule_name IS NULL) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_NAME_NULL');
       FND_MSG_PUB.ADD;
  END IF;

  --Check Rule Type is valid
  OPEN check_rule_type_csr(l_rule_rec.rule_type_code);
  FETCH check_rule_type_csr INTO l_junk;
  IF (check_rule_type_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_TYPE_INV');
       FND_MESSAGE.Set_Token('RULE_TYPE',l_rule_rec.rule_type_code);
       FND_MSG_PUB.ADD;
  END IF;
  CLOSE check_rule_type_csr;

  --Check Rule name is unique
  OPEN check_rule_name_csr(l_rule_rec.rule_name,
			   l_rule_rec.mc_header_id,
			   l_rule_rec.rule_id);
  FETCH check_rule_name_csr INTO l_junk;
  IF (check_rule_name_csr%FOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_NAME_INV');
       FND_MESSAGE.Set_Token('RULE_NAME',l_rule_rec.rule_name);
       FND_MSG_PUB.ADD;
  END IF;
  CLOSE check_rule_name_csr;

  --Check start date is less than end date
  IF (l_rule_rec.active_start_date IS NOT NULL AND
      l_rule_rec.active_end_date IS NOT NULL AND
      l_rule_rec.active_start_date >= l_rule_rec.active_end_date) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_DATE_INVALID');
       FND_MESSAGE.Set_Token('SDATE',l_rule_rec.active_start_date);
       FND_MESSAGE.Set_Token('EDATE',l_rule_rec.active_end_date);
       FND_MSG_PUB.ADD;
  END IF;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Convert the flat structure into a rule tree.
  Build_rule_tree( p_rule_id => l_rule_rec.rule_id,
		   p_rule_stmt_tbl=> p_rule_stmt_tbl,
		   x_rule_stmt_tbl=> l_rule_stmt_tbl);

  --Update the Rule Record
  AHL_MC_RULES_PKG.UPDATE_ROW (
     X_RULE_ID => l_rule_rec.rule_id,
     X_OBJECT_VERSION_NUMBER => l_rule_rec.object_version_number +1,
     X_MC_HEADER_ID => l_rule_rec.mc_header_id,
     X_RULE_NAME => l_rule_rec.rule_name,
     X_RULE_TYPE_CODE => l_rule_rec.rule_type_code,
     X_ACTIVE_START_DATE => l_rule_rec.active_start_date,
     X_ACTIVE_END_DATE => l_rule_rec.active_end_date,
     X_ATTRIBUTE_CATEGORY => l_rule_rec.ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1 => l_rule_rec.ATTRIBUTE1,
     X_ATTRIBUTE2 => l_rule_rec.ATTRIBUTE2,
     X_ATTRIBUTE3 => l_rule_rec.ATTRIBUTE3,
     X_ATTRIBUTE4 => l_rule_rec.ATTRIBUTE4,
     X_ATTRIBUTE5 => l_rule_rec.ATTRIBUTE5,
     X_ATTRIBUTE6 => l_rule_rec.ATTRIBUTE6,
     X_ATTRIBUTE7 => l_rule_rec.ATTRIBUTE7,
     X_ATTRIBUTE8 => l_rule_rec.ATTRIBUTE8,
     X_ATTRIBUTE9 => l_rule_rec.ATTRIBUTE9,
     X_ATTRIBUTE10 => l_rule_rec.ATTRIBUTE10,
     X_ATTRIBUTE11 => l_rule_rec.ATTRIBUTE11,
     X_ATTRIBUTE12 => l_rule_rec.ATTRIBUTE12,
     X_ATTRIBUTE13 => l_rule_rec.ATTRIBUTE13,
     X_ATTRIBUTE14 => l_rule_rec.ATTRIBUTE14,
     X_ATTRIBUTE15 => l_rule_rec.ATTRIBUTE15,
     X_DESCRIPTION => l_rule_rec.description,
     X_LAST_UPDATE_DATE      => SYSDATE,
     X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
     X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID);

  --Delete all the extra Rule statement Records
  OPEN get_rule_stmt_ids_csr(l_rule_rec.rule_id);
  LOOP
     FETCH get_rule_stmt_ids_csr INTO l_rule_stmt_id;
     EXIT WHEN get_rule_stmt_ids_csr%NOTFOUND;

     l_match_flag := FALSE;

     <<l_match_loop>>
     --Check for any which matching rule statements
     FOR i IN l_rule_stmt_tbl.FIRST..l_rule_stmt_tbl.LAST LOOP
       IF (l_rule_stmt_tbl(i).rule_statement_id = l_rule_stmt_id) THEN
 	  l_match_flag := TRUE;
          EXIT l_match_loop;
       END IF;
     END LOOP;

     --If no match, then delete the rule statement
     IF (NOT(l_match_flag)) THEN
       DELETE FROM AHL_MC_RULE_STATEMENTS
       WHERE rule_statement_id = l_rule_stmt_id;
     END IF;
  END LOOP;

  --Now insert or update all the existing rule statements
  FOR i IN l_rule_stmt_tbl.FIRST..l_rule_stmt_tbl.LAST LOOP
     IF (l_rule_stmt_tbl(i).operation_flag = 'I') THEN
        AHL_MC_RULE_STMT_PVT.Insert_Rule_Stmt (
    		p_api_version  => 1.0,
    	        p_commit       => FND_API.G_FALSE,
       	        p_x_rule_stmt_rec     => l_rule_stmt_tbl(i),
	        x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);

     ELSIF (l_rule_stmt_tbl(i).operation_flag = 'U') THEN
       AHL_MC_RULE_STMT_PVT.Update_Rule_Stmt (
    		p_api_version  => 1.0,
    	        p_commit       => FND_API.G_FALSE,
       	        p_rule_stmt_rec     => l_rule_stmt_tbl(i),
	        x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);
     END IF;

      -- Check Error Message stack.
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count > 0 THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;
  END LOOP;

  --Update the status to Draft if approval rejected
  IF (l_status_code = 'APPROVAL_REJECTED')
  THEN
	UPDATE ahl_mc_headers_b
	SET config_status_code = 'DRAFT'
	WHERE mc_header_id = l_rule_rec.mc_header_id;
  END IF;

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
   Rollback to Update_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Update_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Update_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Update_Rule;

-----------------------------
-- Start of Comments --
--  Procedure name    : Delete_Rule
--  Type        : Private
--  Function    : Deletes the Rule corresponding to p_rule_rec
--  Pre-reqs    :
--  Parameters  :
--
--  Delete_Rule Parameters:
--       p_rule_rec.rule_id      IN  NUMBER  Required
--       p_rule_rec.object_version_number      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Delete_Rule (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_rule_rec		  IN 	       RULE_REC_TYPE)
IS
--
CURSOR check_obj_ver_csr (p_rule_id  IN  NUMBER, p_obj_ver IN NUMBER) IS
   SELECT  'X'
     FROM    ahl_mc_rules_b rule
     WHERE  rule.object_version_number = p_obj_ver
     AND    rule.rule_id = p_rule_id;
--
CURSOR check_mc_status_csr (p_rule_id  IN  NUMBER) IS
 SELECT  config_status_code, config_status_meaning, header.mc_header_id
     FROM    ahl_mc_rules_b rule, ahl_mc_headers_v header
     WHERE  rule.mc_header_id = header.mc_header_id
     AND    rule.rule_id = p_rule_id;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Delete_Rule';
l_mc_header_id     NUMBER;
l_junk             VARCHAR2(1);
l_status_code      VARCHAR2(30);
l_status           VARCHAR2(80);
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Delete_Rule_pvt;
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

   -- Check Object version number.
  OPEN check_obj_ver_csr(p_rule_rec.rule_id, p_rule_rec.object_version_number);
  FETCH check_obj_ver_csr INTO l_junk;
  IF (check_obj_ver_csr%NOTFOUND) THEN
      CLOSE check_obj_ver_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE check_obj_ver_csr;

  --Check Status of MC allows for editing
  OPEN check_mc_status_csr(p_rule_rec.rule_id);
 FETCH check_mc_status_csr INTO l_status_code, l_status, l_mc_header_id;
  IF (check_mc_status_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_ID_INV');
       FND_MESSAGE.Set_Token('RULE_ID',p_rule_rec.rule_id);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  ELSIF ( l_status_code <> 'DRAFT' AND
	  l_status_code <> 'APPROVAL_REJECTED') THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_EDIT_INV_MC');
       FND_MESSAGE.Set_Token('STATUS', l_status);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_mc_status_csr;

  --Delete the rule statements first.
  AHL_MC_RULE_STMT_PVT.Delete_Rule_Stmts (
			p_api_version         => 1.0,
    			p_commit              => FND_API.G_FALSE,
                        p_rule_id             => p_rule_rec.rule_id,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Delete the row record
  AHL_MC_RULES_PKG.DELETE_ROW ( X_RULE_ID => p_rule_rec.rule_id);


 --Update the status to Draft if approval rejected
  IF (l_status_code = 'APPROVAL_REJECTED')
  THEN
	UPDATE ahl_mc_headers_b
	SET config_status_code = 'DRAFT'
	WHERE mc_header_id = l_mc_header_id;
  END IF;

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
   Rollback to Delete_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Delete_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Delete_Rule_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
  FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Delete_Rule;

-----------------------------
-- Start of Comments --
--  Procedure name    : Copy_Rules_For_MC
--  Type        : Private
--  Function    : Copies all Rules for 1 MC to another MC
--  Pre-reqs    :
--  Parameters  :
--
--  Copy_Rule_For_MC Parameters:
--       p_from_mc_header_id      IN  NUMBER  Required
--	 p_to_mc_header_id	  IN NUMBER   Required
--
--  End of Comments.

PROCEDURE Copy_Rules_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_from_mc_header_id		  IN 	       NUMBER,
    p_to_mc_header_id		  IN 	       NUMBER  )
IS
--
CURSOR get_rule_rec_csr (p_mc_header_id IN NUMBER) IS
SELECT *
FROM  AHL_MC_RULES_VL
WHERE MC_HEADER_ID = p_mc_header_id;
--
CURSOR get_rule_stmt_id_csr (p_rule_id IN NUMBER) IS
SELECT rule_statement_id
FROM AHL_MC_RULE_STATEMENTS
WHERE rule_id = p_rule_id
 AND  top_rule_stmt_flag = 'T';
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Copy_Rules_For_Mc';
l_rule_rec 	   get_rule_rec_csr%ROWTYPE;
l_row_id           VARCHAR2(30);
l_new_rule_id      NUMBER;
l_stmt_id          NUMBER;
l_new_stmt_id          NUMBER;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Copy_Rules_For_Mc_pvt;

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

  --For each rule for given mc, copy the rule
  OPEN get_rule_rec_csr(p_from_mc_header_id);
  LOOP
     FETCH get_rule_rec_csr INTO l_rule_rec;
     EXIT WHEN get_rule_rec_csr%NOTFOUND;

    SAVEPOINT copy_rule_pvt;

    SELECT AHL_MC_RULES_B_S.nextval
       INTO l_new_rule_id
       FROM dual;

     --Copy the Rule Record
     AHL_MC_RULES_PKG.INSERT_ROW (
       X_ROWID =>   l_row_id,
       X_RULE_ID => l_new_rule_id,
       X_OBJECT_VERSION_NUMBER => 1,
       X_RULE_NAME => l_rule_rec.rule_name,
       X_MC_HEADER_ID => p_to_mc_header_id,
       X_RULE_TYPE_CODE => l_rule_rec.rule_type_code,
       X_ACTIVE_START_DATE => l_rule_rec.active_start_date,
       X_ACTIVE_END_DATE => l_rule_rec.active_end_date,
       X_ATTRIBUTE_CATEGORY => l_rule_rec.ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1 => l_rule_rec.ATTRIBUTE1,
       X_ATTRIBUTE2 => l_rule_rec.ATTRIBUTE2,
       X_ATTRIBUTE3 => l_rule_rec.ATTRIBUTE3,
       X_ATTRIBUTE4 => l_rule_rec.ATTRIBUTE4,
       X_ATTRIBUTE5 => l_rule_rec.ATTRIBUTE5,
       X_ATTRIBUTE6 => l_rule_rec.ATTRIBUTE6,
       X_ATTRIBUTE7 => l_rule_rec.ATTRIBUTE7,
       X_ATTRIBUTE8 => l_rule_rec.ATTRIBUTE8,
       X_ATTRIBUTE9 => l_rule_rec.ATTRIBUTE9,
       X_ATTRIBUTE10 => l_rule_rec.ATTRIBUTE10,
       X_ATTRIBUTE11 => l_rule_rec.ATTRIBUTE11,
       X_ATTRIBUTE12 => l_rule_rec.ATTRIBUTE12,
       X_ATTRIBUTE13 => l_rule_rec.ATTRIBUTE13,
       X_ATTRIBUTE14 => l_rule_rec.ATTRIBUTE14,
       X_ATTRIBUTE15 => l_rule_rec.ATTRIBUTE15,
       X_DESCRIPTION => l_rule_rec.description,
       X_CREATION_DATE         => SYSDATE,
       X_CREATED_BY            => Fnd_Global.USER_ID,
       X_LAST_UPDATE_DATE      => SYSDATE,
       X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
       X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID);

       OPEN get_rule_stmt_id_csr(l_rule_rec.rule_id);
       FETCH get_rule_stmt_id_csr INTO l_stmt_id;
       CLOSE get_rule_stmt_id_csr;

       --Calls copy rule statement with top stmt, which will recursively
       -- copy the rule statements.
       AHL_MC_RULE_STMT_PVT.Copy_Rule_Stmt (
		     p_api_version         => 1.0,
    		     p_commit              => FND_API.G_FALSE,
                     p_rule_stmt_id        => l_stmt_id,
		     p_to_rule_id	   => l_new_rule_id,
		     p_to_mc_header_id     => p_to_mc_header_id,
 		     x_rule_stmt_id        => l_new_stmt_id,
                     x_return_status       => x_return_status,
                     x_msg_count           => x_msg_count,
                     x_msg_data            => x_msg_data);


       --Verify that the rule stmt if null, means can not be copied
       IF (l_new_stmt_id is NULL AND
	 x_return_Status = fnd_api.g_ret_sts_success) THEN
	 ROLLBACK TO copy_rule_pvt;
       ELSE
         --No errors in creating rule
         -- Check Error Message stack.
         x_msg_count := FND_MSG_PUB.count_msg;
         IF x_msg_count > 0 THEN
            CLOSE get_rule_rec_csr;
	   RAISE  FND_API.G_EXC_ERROR;
         END IF;

         --Set the rule id for the new top statement. Special case
         -- can not be included in recursive code.
         UPDATE AHL_MC_RULE_STATEMENTS
	    SET top_rule_stmt_flag = 'T'
          WHERE rule_statement_id = l_new_stmt_id;

       END IF;
  END LOOP;
  CLOSE get_rule_rec_csr;

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
   Rollback to Copy_Rules_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Copy_Rules_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Copy_Rules_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Copy_Rules_For_MC;

-----------------------------
-- Start of Comments --
--  Procedure name    : Delete_Rules_For_MC
--  Type        : Private
--  Function    : Deletes the Rule corresponding to 1 MC
--  Pre-reqs    :
--  Parameters  :
--
--  Delete_Rules_For_MC Parameters:
--       p_mc_header_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Delete_Rules_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_mc_header_id	  IN 	       NUMBER)
IS
--
CURSOR get_rule_ids_csr (p_mc_header_id IN NUMBER) IS
SELECT rule_id, object_version_number
FROM  AHL_MC_RULES_B
WHERE MC_HEADER_ID = p_mc_header_id;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Delete_Rules_For_Mc';
l_rule_rec 	   RULE_REC_TYPE;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Delete_Rules_For_Mc_pvt;

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

  --For each rule for given mc, delete the rule
  OPEN get_rule_ids_csr(p_mc_header_id);
  LOOP
     FETCH get_rule_ids_csr INTO l_rule_rec.rule_id,
				 l_rule_rec.object_version_number;
     EXIT WHEN get_rule_ids_csr%NOTFOUND;

     AHL_MC_RULE_PVT.Delete_Rule (
			p_api_version         => 1.0,
    			p_commit              => FND_API.G_FALSE,
                        p_rule_rec             => l_rule_rec,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);

      -- Check Error Message stack.
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count > 0 THEN
         CLOSE get_rule_ids_csr;
	 RAISE  FND_API.G_EXC_ERROR;
      END IF;
  END LOOP;
  CLOSE get_rule_ids_csr;

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
   Rollback to Delete_Rules_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Delete_Rules_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Delete_Rules_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Delete_Rules_For_MC;


-----------------------------
-- Start of Comments --
--  Procedure name    : Get_Rules_For_Position
--  Type        : Private
--  Function    : Returns all the rules that belong to a position
--  Pre-reqs    :
--  Parameters  :
--	 p_encoded_path is the position path of the node.
--       x_rule_tbl is a list of all applicable rules for position path
--
--  End of Comments.

PROCEDURE Get_Rules_For_Position (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_mc_header_id        IN           NUMBER,
    p_encoded_path	  IN 	       VARCHAR2,
    x_rule_tbl		  OUT NOCOPY     Rule_Tbl_Type)
IS
--
--Fetches the relevant fields for the rule vo
CURSOR get_rule_vo_csr (p_mc_header_id IN NUMBER,
			p_encoded_path IN VARCHAR2,
			p_size IN NUMBER) IS
SELECT rul.rule_id,
       rul.object_version_number,
       rul.mc_header_id,
       rul.rule_name,
       rul.rule_type_code,
       lookup.meaning rule_type_meaning,
       rul.active_start_date,
       rul.active_end_date,
       rul.description,
       rul.attribute_category,
       rul.attribute1,
       rul.attribute2,
       rul.attribute3,
       rul.attribute4,
       rul.attribute5,
       rul.attribute6,
       rul.attribute7,
       rul.attribute8,
       rul.attribute9,
       rul.attribute10,
       rul.attribute11,
       rul.attribute12,
       rul.attribute13,
       rul.attribute14,
       rul.attribute15
FROM AHL_MC_RULES_VL rul, FND_LOOKUPS lookup
WHERE rul.rule_type_code = lookup.lookup_code
AND lookup.lookup_type = 'AHL_MC_RULE_TYPES'
AND rul.mc_header_id = p_mc_header_id
AND rul.rule_id IN (
 SELECT rst.rule_id
 FROM AHL_MC_RULE_STATEMENTS rst, AHL_MC_PATH_POSITIONS pst
 WHERE rst.subject_type = 'POSITION'
  AND  rst.subject_id = pst.path_position_id
  AND  p_encoded_path LIKE  pst.encoded_path_position
  AND  p_size = (select COUNT(path_position_node_id) FROM
      AHL_MC_PATH_POSITION_NODES where path_position_id=pst.path_position_id)
  UNION ALL
 SELECT rst.rule_id
 FROM AHL_MC_RULE_STATEMENTS rst, AHL_MC_PATH_POSITIONS pst
 WHERE (rst.object_type = 'ITEM_AS_POSITION'
     OR rst.object_type = 'CONFIG_AS_POSITION')
  AND rst.object_id = pst.path_position_id
  AND p_encoded_path LIKE  pst.encoded_path_position
  AND p_size = (select COUNT(path_position_node_id) FROM
     AHL_MC_PATH_POSITION_NODES where path_position_id=pst.path_position_id));
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Get_Rules_For_Position';
l_get_rule_rec 	   get_rule_vo_csr%ROWTYPE;
l_index            NUMBER;
l_rule_rec         RULE_REC_TYPE;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Get_Rules_For_Position_pvt;

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


  l_index :=0;

  --For each rule for given position, fetch the rule
  --Calculates the depth of the path by # of / + 1
  OPEN get_rule_vo_csr(p_mc_header_id, p_encoded_path,
     length(p_encoded_path) - length(replace(p_encoded_path,'/'))+1);
  LOOP
     FETCH get_rule_vo_csr INTO l_get_rule_rec;
     EXIT WHEN get_rule_vo_csr%NOTFOUND;

      l_rule_rec.rule_id :=l_get_rule_rec.rule_id;
      l_rule_rec.rule_name	:=l_get_rule_rec.rule_name;
      l_rule_rec.mc_header_id	:=l_get_rule_rec.mc_header_id;
      l_rule_rec.rule_type_code	:=l_get_rule_rec.rule_type_code;
      l_rule_rec.rule_type_meaning :=l_get_rule_rec.rule_type_meaning;
      l_rule_rec.active_start_date :=l_get_rule_rec.active_start_date;
      l_rule_rec.active_end_date   :=l_get_rule_rec.active_end_date;
      l_rule_rec.object_version_number :=l_get_rule_rec.object_version_number;
      l_rule_rec.description :=l_get_rule_rec.description;
      l_rule_rec.ATTRIBUTE_CATEGORY := l_get_rule_rec.ATTRIBUTE_CATEGORY;
      l_rule_rec.ATTRIBUTE1:= l_get_rule_rec.ATTRIBUTE1;
      l_rule_rec.ATTRIBUTE2:= l_get_rule_rec.ATTRIBUTE2;
      l_rule_rec.ATTRIBUTE3:= l_get_rule_rec.ATTRIBUTE3;
      l_rule_rec.ATTRIBUTE4:= l_get_rule_rec.ATTRIBUTE4;
      l_rule_rec.ATTRIBUTE5:= l_get_rule_rec.ATTRIBUTE5;
      l_rule_rec.ATTRIBUTE6:= l_get_rule_rec.ATTRIBUTE6;
      l_rule_rec.ATTRIBUTE7:= l_get_rule_rec.ATTRIBUTE7;
      l_rule_rec.ATTRIBUTE8:= l_get_rule_rec.ATTRIBUTE8;
      l_rule_rec.ATTRIBUTE9 := l_get_rule_rec.ATTRIBUTE9;
      l_rule_rec.ATTRIBUTE10:= l_get_rule_rec.ATTRIBUTE10 ;
      l_rule_rec.ATTRIBUTE11:= l_get_rule_rec.ATTRIBUTE11 ;
      l_rule_rec.ATTRIBUTE12:= l_get_rule_rec.ATTRIBUTE12 ;
      l_rule_rec.ATTRIBUTE13:= l_get_rule_rec.ATTRIBUTE13;
      l_rule_rec.ATTRIBUTE14:= l_get_rule_rec.ATTRIBUTE14;
      l_rule_rec.ATTRIBUTE15:= l_get_rule_rec.ATTRIBUTE15;
      x_rule_tbl(l_index) := l_rule_rec;
      l_index := l_index +1;
  END LOOP;
  CLOSE get_rule_vo_csr;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Get_Rules_For_Position_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Get_Rules_For_Position_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Get_Rules_For_Position_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
--
END Get_Rules_For_Position;

End AHL_MC_RULE_PVT;

/
