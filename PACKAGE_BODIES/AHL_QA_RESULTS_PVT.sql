--------------------------------------------------------
--  DDL for Package Body AHL_QA_RESULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_QA_RESULTS_PVT" AS
/* $Header: AHLVQARB.pls 120.5.12010000.2 2009/04/21 01:23:40 sikumar ship $ */

G_PKG_NAME   VARCHAR2(30) := 'AHL_QA_RESULTS_PVT';
G_DEBUG      VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

-- Added by Arvind for 11.5.10
G_MR_TXN_NO  NUMBER  := TO_NUMBER( FND_PROFILE.value( 'AHL_MR_QA_TXN_NO' ) );
G_JOB_TXN_NO NUMBER  := 2001;
G_OP_TXN_NO  NUMBER  := 2002;
G_MRB_TXN_NO NUMBER  := 2004;

FUNCTION validate_gqp_inputs
(
 p_organization_id      IN   NUMBER,
 p_transaction_number   IN   NUMBER,
 p_col_trigger_value    IN   VARCHAR2
) RETURN VARCHAR2
IS
BEGIN
  IF ( p_organization_id IS NULL OR
       p_organization_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ORG_ID_NULL' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_transaction_number IS NULL OR
       p_transaction_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_TXN_NO_NULL' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_col_trigger_value IS NULL OR
       p_col_trigger_value = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INSPECTION_TYPE_NULL' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

END validate_gqp_inputs;

FUNCTION validate_sqar_inputs
(
p_plan_id               IN     NUMBER,
p_organization_id       IN     NUMBER,
p_transaction_no        IN     NUMBER,
p_specification_id      IN     NUMBER,
p_results_tbl           IN     qa_results_tbl_type,
p_hidden_results_tbl    IN     qa_results_tbl_type,
p_context_tbl           IN     qa_context_tbl_type,
p_result_commit_flag    IN     NUMBER,
p_collection_id         IN     NUMBER
) RETURN VARCHAR2
IS

TYPE chars_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_plan_chars            chars_tbl_type;
l_organization_id       NUMBER;
l_element_count         NUMBER := 1;
l_match_found           BOOLEAN := FALSE;
l_mr_title               VARCHAR2(80);
--rroy
-- ACL Changes
l_return_status          VARCHAR2(1);
l_workorder_id           NUMBER;
l_unit_effectivity_id			NUMBER;
l_workorder_operation_id  NUMBER;
l_wo_name    						VARCHAR2(80);
--rroy
-- ACL Changes

CURSOR  get_plan_from_results( c_collection_id NUMBER )
IS
SELECT  plan_id
FROM    QA_RESULTS
WHERE   collection_id = c_collection_id;

CURSOR  get_chars_for_plan( c_plan_id NUMBER )
IS
SELECT  char_id
FROM    QA_PLAN_CHARS
WHERE   plan_id = c_plan_id;

--rroy
-- ACL Changes
CURSOR get_wo_from_ue(c_ue_id NUMBER)
IS
SELECT workorder_id,
job_number
FROM AHL_SEARCH_WORKORDERS_V
WHERE UNIT_EFFECTIVITY_ID = c_ue_id;

CURSOR get_wo_from_op(c_op_id NUMBER)
IS
SELECT workorder_id
FROM AHL_WORKORDER_OPERATIONS
WHERE WORKORDER_OPERATION_ID = c_op_id;
--rroy
-- ACL Changes

  --Changes by nsikka for Bug 5324101
  --Cursor added to fetch UE Title to be passed as token

CURSOR ue_title_csr( p_unit_effectivity_id IN NUMBER )
IS
SELECT  title
FROM    ahl_unit_effectivities_v
WHERE UNIT_EFFECTIVITY_ID = p_unit_effectivity_id;


BEGIN

  IF ( p_plan_id IS NULL OR
       p_plan_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_PLAN_ID_NULL' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_organization_id IS NULL OR
       p_organization_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ORG_ID_NULL' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_results_tbl.COUNT = 0 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ONE_RESULT_REQD' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  BEGIN
    SELECT  organization_id
    INTO    l_organization_id
    FROM    QA_PLANS
    WHERE   plan_id = p_plan_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_PLAN_NOT_FOUND' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
  END;

		-- rroy
		-- ACL Changes
		FOR i IN 1..p_context_tbl.COUNT LOOP
		  IF(p_context_tbl(i).name = 'workorder_id') THEN
						l_workorder_id := p_context_tbl(i).value;
				ELSIF(p_context_tbl(i).name = 'unit_effectivity_id') THEN
						l_unit_effectivity_id := p_context_tbl(i).value;
				ELSIF(p_context_tbl(i).name = 'operation_id') THEN
						l_workorder_operation_id := p_context_tbl(i).value;
				END IF;
		END LOOP;

		IF p_transaction_no = G_MR_TXN_NO THEN
				OPEN get_wo_from_ue(l_unit_effectivity_id);
				FETCH get_wo_from_ue INTO l_workorder_id, l_wo_name;
				CLOSE get_wo_from_ue;

				l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_workorder_id,																																																																								p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);



	--nsikka
	--Changes made for Bug 5324101 .
	--tokens passed changed to MR_TITLE

				IF l_return_status = FND_API.G_TRUE THEN
				                OPEN ue_title_csr(l_unit_effectivity_id);
           	    				FETCH ue_title_csr INTO l_mr_title;
                				CLOSE ue_title_csr;
						FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_QA_UNTLCKD');
						FND_MESSAGE.Set_Token('MR_TITLE', l_mr_title);
						FND_MSG_PUB.ADD;
						RETURN FND_API.G_RET_STS_ERROR;
				END IF;
		ELSIF p_transaction_no = G_JOB_TXN_NO THEN
				l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_workorder_id,																																																																								p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);
				IF l_return_status = FND_API.G_TRUE THEN
						FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_WO_QA_UNTLCKD');
						FND_MSG_PUB.ADD;
						RETURN FND_API.G_RET_STS_ERROR;
				END IF;
 	ELSIF p_transaction_no = G_OP_TXN_NO THEN
				OPEN get_wo_from_op(l_workorder_operation_id);
				FETCH get_wo_from_op INTO l_workorder_id;
				CLOSE get_wo_From_op;

				l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_workorder_id,																																																																								p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);
				IF l_return_status = FND_API.G_TRUE THEN
						FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_OP_QA_UNTLCKD');
						FND_MSG_PUB.ADD;
						RETURN FND_API.G_RET_STS_ERROR;
 			END IF;
		END IF;



  IF ( l_organization_id <> p_organization_id ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ORG_MISMATCH' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_collection_id IS NOT NULL AND
       p_collection_id <> FND_API.G_MISS_NUM ) THEN
    FOR results_cursor IN get_plan_from_results( p_collection_id ) LOOP
      IF ( results_cursor.plan_id <> p_plan_id ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_COLL_MANY_PLANS' );
        FND_MSG_PUB.add;
        CLOSE get_plan_from_results;
        RETURN FND_API.G_RET_STS_ERROR;
      END IF;

      l_element_count := l_element_count + 1;
    END LOOP;

    IF ( l_element_count = 1 ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_COLL_NOT_FOUND' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  l_element_count := 1;

  FOR chars_cursor IN get_chars_for_plan( p_plan_id ) LOOP
    l_plan_chars( l_element_count ) := chars_cursor.char_id;
    l_element_count := l_element_count + 1;
  END LOOP;

  FOR i IN 1..p_results_tbl.COUNT LOOP

    FOR j IN 1..l_plan_chars.COUNT LOOP
      IF ( l_plan_chars(j) = p_results_tbl(i).char_id ) THEN
        l_match_found := TRUE;
        --EXIT;
      END IF;
    END LOOP;

    IF ( l_match_found = FALSE ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_RESULTS_NO_PLAN_CHAR' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

    l_match_found := FALSE;

  END LOOP;

  FOR i IN 1..p_hidden_results_tbl.COUNT LOOP

    FOR j IN 1..l_plan_chars.COUNT LOOP
      IF ( l_plan_chars(j) = p_hidden_results_tbl(i).char_id ) THEN
        l_match_found := TRUE;
        --EXIT;
      END IF;
    END LOOP;

    IF ( l_match_found = FALSE ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_HIDDEN_NO_PLAN_CHAR' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

    l_match_found := FALSE;

  END LOOP;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_sqar_inputs;

FUNCTION fire_ahl_actions
(
  x_return_status      OUT NOCOPY    VARCHAR2,
  x_msg_count          OUT NOCOPY    NUMBER,
  x_msg_data           OUT NOCOPY    VARCHAR2,
  p_plan_id            IN            NUMBER,
  p_transaction_no     IN            NUMBER,
  p_results_tbl        IN            qa_results_tbl_type,
  p_context_tbl        IN            qa_context_tbl_type,
  p_collection_id      IN            NUMBER
) RETURN VARCHAR2
IS
 l_msg_data               VARCHAR2(2000);
 l_return_status          VARCHAR2(1);
 l_msg_count              NUMBER;
 l_unit_effectivity_id    NUMBER := NULL;
 l_workorder_id           NUMBER := NULL;
 l_object_version_number  NUMBER := NULL;
 l_workorder_operation_id NUMBER := NULL;

BEGIN

  FOR i IN 1..p_context_tbl.COUNT LOOP
    IF ( p_context_tbl(i).name = 'workorder_id' ) THEN
      l_workorder_id := p_context_tbl(i).value;
    ELSIF ( p_context_tbl(i).name = 'unit_effectivity_id' ) THEN
      l_unit_effectivity_id := p_context_tbl(i).value;
    ELSIF ( p_context_tbl(i).name = 'operation_id' ) THEN
      l_workorder_operation_id := p_context_tbl(i).value;
    ELSIF ( p_context_tbl(i).name = 'object_version_no' ) THEN
      l_object_version_number := p_context_tbl(i).value;
    END IF;
  END LOOP;

  -- Added by Arvind for 11.5.10
  IF ( p_transaction_no = G_MR_TXN_NO ) THEN

    IF ( l_unit_effectivity_id IS NULL OR
         l_object_version_number IS NULL ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_UE_INPUTS' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

    -- Change to call capture_mr_updates
    UPDATE AHL_UNIT_EFFECTIVITIES_B
    SET    qa_collection_id = p_collection_id,
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
    WHERE  unit_effectivity_id = l_unit_effectivity_id
    AND    object_version_number = l_object_version_number;

    IF ( SQL%ROWCOUNT = 0 ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_UE_NOT_FOUND' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

  ELSIF ( p_transaction_no = G_JOB_TXN_NO ) THEN

    IF ( l_workorder_id IS NULL OR
         l_object_version_number IS NULL ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_WO_INPUTS' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

    UPDATE AHL_WORKORDERS
    SET    collection_id = p_collection_id,
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
    WHERE  workorder_id = l_workorder_id
    AND    object_version_number = l_object_version_number;

    IF ( SQL%ROWCOUNT = 0 ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_NOT_FOUND' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

  ELSIF ( p_transaction_no = G_OP_TXN_NO ) THEN

    IF ( l_workorder_operation_id IS NULL OR
         l_object_version_number IS NULL ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_COP_INPUTS' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

    UPDATE AHL_WORKORDER_OPERATIONS
    SET    collection_id = p_collection_id,
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
    WHERE  workorder_operation_id = l_workorder_operation_id
    AND    object_version_number = l_object_version_number;

    IF ( SQL%ROWCOUNT = 0 ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_OP_NOT_FOUND' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

  ELSIF ( p_transaction_no = G_MRB_TXN_NO ) THEN
    NULL;
  ELSE
    NULL;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;

END fire_ahl_actions;

FUNCTION form_hidden_qa_result_string
(
p_hidden_results_tbl   IN     qa_results_tbl_type,
p_results_tbl          IN     qa_results_tbl_type,
p_search_end_index     IN     NUMBER,
p_id_or_value          IN     VARCHAR2,
x_result_string        OUT NOCOPY    VARCHAR2
) RETURN VARCHAR2
IS

l_end_index            NUMBER;
l_skip_element         BOOLEAN := FALSE;

BEGIN

  l_end_index := p_hidden_results_tbl.COUNT;

  FOR i IN 1..l_end_index LOOP
    FOR j IN 1..p_search_end_index LOOP
      IF ( p_hidden_results_tbl(i).char_id = p_results_tbl(j).char_id ) THEN
        l_skip_element := TRUE;
        EXIT;
      END IF;
    END LOOP;

    IF ( l_skip_element = FALSE ) THEN
      IF ( p_id_or_value = 'ID' ) THEN
        x_result_string := x_result_string || p_hidden_results_tbl(i).char_id || '=' || p_hidden_results_tbl(i).result_id;
      ELSE
        x_result_string := x_result_string || p_hidden_results_tbl(i).char_id || '=' || p_hidden_results_tbl(i).result_value;
      END IF;

      IF ( i < l_end_index ) THEN
        x_result_string := x_result_string || '@';
      END IF;
    ELSE
      l_skip_element := FALSE;
    END IF;

  END LOOP;

  RETURN FND_API.G_RET_STS_SUCCESS;
END form_hidden_qa_result_string;

FUNCTION form_qa_result_string
(
p_results_tbl          IN     qa_results_tbl_type,
p_start_index          IN     NUMBER,
p_end_index            IN     NUMBER,
p_id_or_value          IN     VARCHAR2,
x_result_string        OUT NOCOPY    VARCHAR2
) RETURN VARCHAR2
IS

BEGIN

  FOR i IN p_start_index..p_end_index LOOP
    IF ( p_id_or_value = 'ID' ) THEN
      x_result_string := x_result_string || p_results_tbl(i).char_id || '=' || p_results_tbl(i).result_id;
    ELSE
      x_result_string := x_result_string || p_results_tbl(i).char_id || '=' || p_results_tbl(i).result_value;
    END IF;

    IF ( i < p_end_index ) THEN
      x_result_string := x_result_string || '@';
    END IF;

  END LOOP;

  RETURN FND_API.G_RET_STS_SUCCESS;
END form_qa_result_string;

PROCEDURE submit_qa_results
(
 p_api_version        IN            NUMBER     := 1.0,
 p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default            IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type        IN            VARCHAR2   := NULL,
 x_return_status      OUT NOCOPY    VARCHAR2,
 x_msg_count          OUT NOCOPY    NUMBER,
 x_msg_data           OUT NOCOPY    VARCHAR2,
 p_plan_id            IN            NUMBER,
 p_organization_id    IN            NUMBER,
 p_transaction_no     IN            NUMBER,
 p_specification_id   IN            NUMBER     := NULL,
 p_results_tbl        IN            qa_results_tbl_type,
 p_hidden_results_tbl IN            qa_results_tbl_type,
 p_context_tbl        IN            qa_context_tbl_type,
 p_result_commit_flag IN            NUMBER,
 p_id_or_value        IN            VARCHAR2 := 'VALUE',
 p_x_collection_id    IN OUT NOCOPY NUMBER,
 p_x_occurrence_tbl   IN OUT NOCOPY occurrence_tbl_type
)
IS
  l_api_name             VARCHAR2(30) := 'submit_qa_results';
  l_msg_data             VARCHAR2(2000);
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_occurrence           NUMBER := NULL;
  l_qa_post_result       INTEGER := -1;
  l_result_string        VARCHAR2(5000) := NULL;
  l_hidden_result_string VARCHAR2(5000) := NULL;
  l_enabled              NUMBER;
  l_committed            NUMBER;
  l_start_index          NUMBER := 1;
  l_transaction_no       NUMBER;
BEGIN
  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT submit_qa_results_PVT;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_return_status :=
  validate_sqar_inputs
  (
    p_plan_id              => p_plan_id,
    p_organization_id      => p_organization_id,
    p_transaction_no       => p_transaction_no,
    p_specification_id     => p_specification_id,
    p_results_tbl          => p_results_tbl,
    p_hidden_results_tbl   => p_hidden_results_tbl,
    p_context_tbl          => p_context_tbl,
    p_result_commit_flag   => p_result_commit_flag,
    p_collection_id        => p_x_collection_id
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : After validating Inputs ' );
  END IF;

  IF ( p_x_collection_id IS NULL ) THEN
    SELECT QA_COLLECTION_ID_S.NEXTVAL INTO p_x_collection_id FROM DUAL;

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : After Getting Collection ID ' );
    END IF;

  END IF;

  IF ( p_result_commit_flag = 1 ) THEN
    l_enabled := 2;
    l_committed := 1;
  ELSE
    l_enabled := 1;
    l_committed := 2;
  END IF;

  l_return_status :=
  form_hidden_qa_result_string
  (
    p_hidden_results_tbl => p_hidden_results_tbl,
    p_results_tbl        => p_results_tbl,
    p_search_end_index   => p_x_occurrence_tbl(1).element_count,
    p_id_or_value        => p_id_or_value,
    x_result_string      => l_hidden_result_string
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : After Forming Hidden Result String : ' || l_hidden_result_string );
  END IF;

  FOR i IN 1..p_x_occurrence_tbl.COUNT LOOP

    l_return_status :=
    form_qa_result_string
    (
      p_results_tbl   => p_results_tbl,
      p_start_index   => l_start_index,
      p_end_index     => l_start_index + p_x_occurrence_tbl(i).element_count -1,
      p_id_or_value   => p_id_or_value,
      x_result_string => l_result_string
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : After Forming Result String : ' || l_result_string || ' for row : ' || i );
    END IF;

    l_start_index := l_start_index + p_x_occurrence_tbl(i).element_count;

    IF ( l_hidden_result_string IS NOT NULL ) THEN
      l_result_string := l_result_string || '@' || l_hidden_result_string;
    END IF;

    IF ( p_transaction_no IS NULL OR
         p_transaction_no = FND_API.G_MISS_NUM ) THEN
      l_qa_post_result :=
      QA_SS_RESULTS.nontxn_post_result
      (
        x_occurrence           => l_occurrence,
        x_org_id               => p_organization_id,
        x_plan_id              => p_plan_id,
        x_spec_id              => p_specification_id,
        x_collection_id        => p_x_collection_id,
        x_result               => NULL,
        x_result1              => l_result_string,
        x_result2              => NULL,
        x_enabled              => l_enabled,
        x_committed            => l_committed,
        x_messages             => l_msg_data
      );

      IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : After Invoking nontxnt_post_result ' );
      END IF;
      IF(l_msg_data IS NOT NULL)THEN
         x_msg_data := l_msg_data || x_msg_data;
         x_msg_count := 1;
      END IF;

    ELSE
      -- Added by Arvind for 11.5.10
      -- Remove once MR Txn is provided by QA
      IF ( p_transaction_no = G_MR_TXN_NO ) THEN
        l_transaction_no := G_JOB_TXN_NO;
      ELSE
        l_transaction_no := p_transaction_no;
      END IF;

      l_qa_post_result :=
      QA_SS_RESULTS.post_result
      (
        x_occurrence           => l_occurrence,
        x_org_id               => p_organization_id,
        x_plan_id              => p_plan_id,
        x_spec_id              => p_specification_id,
        x_collection_id        => p_x_collection_id,
        x_result               => l_result_string,
        x_result1              => NULL,
        x_result2              => NULL,
        x_enabled              => l_enabled,
        x_committed            => l_committed,
        x_transaction_number   => l_transaction_no,
        x_messages             => l_msg_data
      );

      IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : After Invoking post_result ' || l_msg_data);
      END IF;
      IF(l_msg_data IS NOT NULL)THEN
         x_msg_data := l_msg_data || x_msg_data;
         x_msg_count := 1;
      END IF;
    END IF;

    IF ( l_qa_post_result = -1 ) THEN

      IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Post Result Failed ' );
      END IF;

      IF ( l_msg_data IS NULL ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_QA_POST_UNEXP_ERROR' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := l_msg_data;
        x_msg_count := 1;
        RETURN;
      END IF;
    END IF;

    p_x_occurrence_tbl(i).occurrence := l_occurrence;
    l_occurrence := NULL;
    l_result_string := NULL;

    IF ( l_committed = 1 ) THEN
      -- Reset Save Point because a Commit Occurs
      SAVEPOINT submit_qa_results_PVT;
    END IF;

  END LOOP;

  IF ( p_transaction_no IS NOT NULL ) THEN
    l_return_status :=
    fire_ahl_actions
    (
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      p_plan_id            => p_plan_id,
      p_transaction_no     => p_transaction_no,
      p_results_tbl        => p_results_tbl,
      p_context_tbl        => p_context_tbl,
      p_collection_id      => p_x_collection_id
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      IF ( l_msg_data IS NOT NULL ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := l_msg_data;
        x_msg_count := 1;
        RETURN;
      ELSE
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : After Firing AHL Actions ' );
    END IF;
  END IF;

  -- Fix for bug# 5501482.
  --IF ( l_committed = 1 ) THEN
  IF ( l_committed = 2  ) THEN
  --IF ( l_committed = 2 AND FND_API.to_boolean( p_commit ) ) THEN
    QA_SEQUENCE_API.generate_seq_for_Txn
    (
      p_collection_id       => p_x_collection_id,
      p_return_status       => l_return_status
    );
    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    QA_SS_RESULTS.wrapper_fire_action
    (
      q_collection_id       => p_x_collection_id,
      q_return_status       => l_return_status,
      q_msg_count           => l_msg_count,
      q_msg_data            => l_msg_data
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      IF ( l_msg_data IS NULL ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_QA_ACTION_UNEXP_ERROR' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := l_msg_data;
        x_msg_count := 1;
        RETURN;
      END IF;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : After Firing QA Actions ' || l_msg_data );
    END IF;
  END IF;
  -- Fix for bug#5501482

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : returned message: ' || x_msg_data );
  END IF;

  -- Perform the Commit (if requested)
  IF ( FND_API.to_boolean( p_commit ) ) THEN
    COMMIT WORK;
  END IF;


  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO submit_qa_results_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO submit_qa_results_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO submit_qa_results_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END submit_qa_results;

PROCEDURE get_char_lov_sql
(
 p_api_version          IN   NUMBER     := 1.0,
 p_init_msg_list        IN   VARCHAR2   := FND_API.G_TRUE,
 p_commit               IN   VARCHAR2   := FND_API.G_FALSE,
 p_validation_level     IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default              IN   VARCHAR2   := FND_API.G_FALSE,
 p_module_type          IN   VARCHAR2   := NULL,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2,
 p_plan_id              IN   NUMBER,
 p_char_id              IN   NUMBER,
 p_organization_id      IN   NUMBER,
 p_user_id              IN   NUMBER := NULL,
 p_depen1               IN   VARCHAR2 := NULL,
 p_depen2               IN   VARCHAR2 := NULL,
 p_depen3               IN   VARCHAR2 := NULL,
 p_value                IN   VARCHAR2 := NULL,
 x_char_lov_sql         OUT NOCOPY  VARCHAR2
)
IS
  l_api_name             VARCHAR2(30) := 'get_char_lov_sql';
BEGIN

  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_char_lov_sql :=
  QA_SS_LOV_API.get_lov_sql
  (
    plan_id         => p_plan_id,
    char_id         => p_char_id,
    org_id          => p_organization_id,
    user_id         => p_user_id,
    depen1          => p_depen1,
    depen2          => p_depen2,
    depen3          => p_depen3,
    value           => p_value
  )  || '::' ||
  QA_SS_LOV_API.get_lov_bind_values
  (
    plan_id         => p_plan_id,
    char_id         => p_char_id,
    org_id          => p_organization_id,
    user_id         => p_user_id,
    depen1          => p_depen1,
    depen2          => p_depen2,
    depen3          => p_depen3,
    value           => p_value
  );

  -- Error handling code added by balaji for bug # 4091726
  IF FND_MSG_PUB.count_msg > 0 THEN
 	RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ( x_char_lov_sql IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_QA_CHAR_LOV_NULL' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;
END get_char_lov_sql;

PROCEDURE get_qa_plan
(
 p_api_version          IN   NUMBER     := 1.0,
 p_init_msg_list        IN   VARCHAR2   := FND_API.G_TRUE,
 p_commit               IN   VARCHAR2   := FND_API.G_FALSE,
 p_validation_level     IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default              IN   VARCHAR2   := FND_API.G_FALSE,
 p_module_type          IN   VARCHAR2   := NULL,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2,
 p_organization_id      IN   NUMBER,
 p_transaction_number   IN   NUMBER,
 p_col_trigger_value    IN   VARCHAR2,
 x_plan_id              OUT NOCOPY  NUMBER
)
IS
  l_api_name             VARCHAR2(30) := 'get_qa_plan';
BEGIN

  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  BEGIN

    SELECT   QP.plan_id
    INTO     x_plan_id
    FROM     QA_PLANS_VAL_V QP,
             QA_PLAN_TRANSACTIONS QPT,
             QA_PLAN_COLLECTION_TRIGGERS QPCT
    WHERE    QP.plan_id = QPT.plan_id
    AND      QPT.plan_transaction_id = QPCT.plan_transaction_id
    AND      QP.organization_id = p_organization_id
    AND      QPT.transaction_number = p_transaction_number
    AND      QPCT.collection_trigger_id = 87
    AND      QPCT.low_value = p_col_trigger_value;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_plan_id := NULL;
      IF ( p_module_type = 'JSP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_QA_PLAN_NOT_FOUND' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        RETURN;
      END IF;
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;
END get_qa_plan;

END AHL_QA_RESULTS_PVT;

/
