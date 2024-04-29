--------------------------------------------------------
--  DDL for Package Body GMD_SPEC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPEC_GRP" AS
--$Header: GMDGSPCB.pls 120.3 2006/05/31 14:50:07 ragsriva noship $ */

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_Spec_GRP';
   --Bug 3222090, magupta removed call to FND_PROFILE.VALUE('AFLOG_ENABLED')
   --forward decl.
   function set_debug_flag return varchar2;
   --l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGSPCB.pls                                        |
--| Package Name       : GMD_Spec_GRP                                        |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Entity       |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	26-Jul-2002	Created.                             |
--|    Rameshwar        13-APR-2004     BUG#3545701                          |
--|                     Commented the code for non-validated test            |
--|                     in the check_for_null_and_fks_in_stst procedure      |
--+==========================================================================+
-- End of comments



--Start of comments
--+========================================================================+
--| API Name    : check_for_null_and_fks_in_spec                           |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for NULL and Foreign Key           |
--|               constraints for the required filed in the Spec           |
--|               Header record.                                           |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                                   |
--|                                                                        |
--| Saikiran Vankadari 07-Feb-2005  Changed as part of Convergence         |
--| RLNAGARA           10-Oct-2005  Bug # 4546546 - Included revision in the inbound criteria |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE check_for_null_and_fks_in_spec
( p_spec_header   IN  gmd_specifications%ROWTYPE
, x_item_number       OUT NOCOPY VARCHAR2
, x_owner         OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
) IS

  -- Bug# 5251612
  -- Added additional where clause to check process_quality_enabled_flag
  CURSOR c_item(p_inventory_item_id NUMBER, p_organization_id NUMBER) IS
  SELECT concatenated_segments,grade_control_flag
  FROM   mtl_system_items_kfv
  WHERE  inventory_item_id = p_inventory_item_id
  AND    organization_id   = p_organization_id
  AND    process_quality_enabled_flag = 'Y';

--RLNAGARA Bug # 4548546 For Revision
  CURSOR c_rev_ctrl(p_inventory_item_id NUMBER, p_organization_id NUMBER) IS
  SELECT revision_qty_control_code
  FROM mtl_system_items_b
  WHERE inventory_item_id = p_inventory_item_id
  AND organization_id = p_organization_id;

  CURSOR c_revision(p_inventory_item_id NUMBER, p_organization_id NUMBER,p_revision VARCHAR2) IS
  SELECT 1
  FROM mtl_item_revisions
  WHERE inventory_item_id = p_inventory_item_id
  AND organization_id = p_organization_id
  AND revision = p_revision;
--RLNAGARA Bug # 4548546 For Revision

  CURSOR c_grade(p_grade VARCHAR2) IS
  SELECT 1
  FROM   mtl_grades_b
  WHERE  grade_code = p_grade
  AND disable_flag = 'N';


  CURSOR c_status (p_spec_status NUMBER) IS
  SELECT 1
  FROM   gmd_qc_status
  WHERE  status_code = p_spec_status
  AND    delete_mark = 0
  and    entity_type = 'S';

  CURSOR c_orgn (p_organization_id NUMBER) IS
  SELECT 1
  FROM   mtl_parameters
  WHERE  organization_id = p_Organization_id;


  CURSOR c_owner(p_owner_id NUMBER) IS
  SELECT user_name
  FROM   fnd_user
  WHERE  user_id                 = p_owner_id
  AND    start_date             <= SYSDATE
  AND    nvl(end_date, SYSDATE + 1) >= SYSDATE;


  -- Check for Approved Base Spec (Bug 3401368)
  CURSOR c_spec (p_spec_id NUMBER) IS
  SELECT 1
  FROM   gmd_specifications_b
  WHERE  spec_id = p_spec_id
  AND    spec_status = 700 ;


  dummy               NUMBER;
  l_grade_ctl	      VARCHAR2(1);

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Spec Name
  IF (ltrim(rtrim(p_spec_header.spec_name)) IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_NAME_REQD');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Spec Vers
  IF (p_spec_header.spec_vers IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VERS_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_spec_header.spec_vers < 0) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VERS_INVALID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Spec Type (Bug 3451973)
  IF (p_spec_header.spec_type in ('M', 'I')) THEN
	null ;
  else
    GMD_API_PUB.Log_Message('GMD_SPEC_TYPE_NOT_FOUND');
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Item ID
  IF (p_spec_header.inventory_item_id IS NULL)
    and (p_spec_header.spec_type = 'I')   -- Bug 3401368: this is only for item specs
    THEN
     GMD_API_PUB.Log_Message('GMD_SPEC_ITEM_REQD');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Get the Item No
    OPEN c_item(p_spec_header.inventory_item_id, p_spec_header.owner_organization_id);
    FETCH c_item INTO x_item_number,l_grade_ctl;
    IF (c_item%NOTFOUND)  and (p_spec_header.spec_type = 'I')  -- Bug 3401368: this is only for item specs
     THEN
      CLOSE c_item;
      GMD_API_PUB.Log_Message('GMD_SPEC_ITEM_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_item;
  END IF;

-- Start RLNAGARA  Bug # 4548546
--For Revision
 IF (p_spec_header.revision IS NOT NULL) THEN
   --Check whether it is a revision controlled item in MTL_SYSTEM_ITEMS_B
   OPEN c_rev_ctrl(p_spec_header.inventory_item_id, p_spec_header.owner_organization_id);
   FETCH c_rev_ctrl into dummy;
   IF dummy = 2 THEN  --The item is a revision controlled item
     -- Check that Revision exist in MTL_ITEM_REVISIONS
     OPEN c_revision(p_spec_header.inventory_item_id, p_spec_header.owner_organization_id,p_spec_header.revision);
     FETCH c_revision INTO dummy;
     IF c_revision%NOTFOUND THEN
       CLOSE c_revision;
       CLOSE c_rev_ctrl;
       GMD_API_PUB.Log_Message('GMD_SPEC_REVISION_NOT_FOUND',
                               'REVISION', p_spec_header.revision);
       RAISE FND_API.G_EXC_ERROR;
     END IF; --c_revision%NOTFOUND
     CLOSE c_revision;
   ELSIF dummy = 1 THEN  --The item is not a revision controlled item
     CLOSE c_rev_ctrl;
     GMD_API_PUB.Log_Message('GMD_SPEC_NOT_REVISION_CTRL');
     RAISE FND_API.G_EXC_ERROR;
   END IF; --dummy = 2
   CLOSE c_rev_ctrl;
 END IF; --(p_spec_header.revision IS NOT NULL)
-- End RLNAGARA Bug # 4548546

  -- Grade
  IF l_grade_ctl = 'N' and p_spec_header.grade_code IS NOT NULL THEN
      GMD_API_PUB.Log_Message('GMD_GRADE_NOT_REQD');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_spec_header.grade_code IS NOT NULL) THEN
    -- Check that Grade exist in QC_GRAD_MST
    OPEN c_grade(p_spec_header.grade_code);
    FETCH c_grade INTO dummy;
    IF c_grade%NOTFOUND THEN
      CLOSE c_grade;
      GMD_API_PUB.Log_Message('GMD_SPEC_GRADE_NOT_FOUND',
                              'GRADE', p_spec_header.grade_code);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_grade;
  END IF;

  -- Spec Status
  IF (p_spec_header.spec_status IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_STATUS_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Check that Status exist in GMD_QM_STATUS
    OPEN c_status(p_spec_header.spec_status);
    FETCH c_status INTO dummy;
    IF c_status%NOTFOUND THEN
      CLOSE c_status;
      GMD_API_PUB.Log_Message('GMD_SPEC_STATUS_NOT_FOUND',
                              'STATUS', p_spec_header.spec_status);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_status;
  END IF;

  -- Owner Orgn Code
  IF (p_spec_header.owner_organization_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_ORGN_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Check that Owner Organization id exist in MTL_PARAMETERS
    OPEN c_orgn(p_spec_header.owner_organization_id);
    FETCH c_orgn INTO dummy;
    IF c_orgn%NOTFOUND THEN
      CLOSE c_orgn;
      GMD_API_PUB.Log_Message('GMD_SPEC_ORGN_ID_NOT_FOUND',
                              'ORGNID', p_spec_header.owner_organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_orgn;
  END IF;

  -- Owner ID
  IF (p_spec_header.owner_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_OWNER_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Get the Owner Name
    OPEN c_owner(p_spec_header.owner_id);
    FETCH c_owner INTO x_owner;
    IF c_owner%NOTFOUND THEN
      CLOSE c_owner;
      GMD_API_PUB.Log_Message('GMD_SPEC_OWNER_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_owner;
  END IF;


  -- Overlay Ind (Bug 3452015)
  if (nvl(p_spec_header.OVERLAY_IND,'Y') <>  'Y') then
	      GMD_API_PUB.Log_Message('GMD_OVERLAY_NOT_VALID');
	      RAISE FND_API.G_EXC_ERROR;
  end if ;

  IF (p_spec_header.OVERLAY_IND is NULL) THEN
      IF (p_spec_header.BASE_SPEC_ID IS NOT NULL) THEN
	      GMD_API_PUB.Log_Message('GMD_OVERLAY_NOT_VALID');
	      RAISE FND_API.G_EXC_ERROR;
      end if;
  end if;

  IF (p_spec_header.OVERLAY_IND = 'Y') THEN
      IF (p_spec_header.BASE_SPEC_ID IS NULL) THEN
	      GMD_API_PUB.Log_Message('GMD_BASE_SPEC_NOT_FOUND',
                              'BASE_SPEC_ID', p_spec_header.base_spec_id);
	      RAISE FND_API.G_EXC_ERROR;
      end if;
  end if;


  -- Base Spec ID (Bug 3401368)
  IF (p_spec_header.BASE_SPEC_ID IS NOT NULL) THEN
   -- Check to make sure that the base spec is valid
    OPEN c_spec(p_spec_header.base_spec_id);
    FETCH c_spec INTO dummy;
    IF c_spec%NOTFOUND THEN
      CLOSE c_spec;
      GMD_API_PUB.Log_Message('GMD_BASE_SPEC_NOT_FOUND',
                              'BASE_SPEC_ID', p_spec_header.base_spec_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_spec;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR','PACKAGE','gmd_spec_grp.check_for_null_and_fks_in_spec',
    	'ERROR',substr(sqlerrm,1,100),'POSITION','010');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END check_for_null_and_fks_in_spec;


--Start of comments
--+========================================================================+
--| API Name    : check_for_null_and_fks_in_stst                           |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for NULL and Foreign Key           |
--|               constraints for the required filed in the Spec           |
--|               Test record.                                             |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Mahesh Chandak	14-Nov-2002	Created.                           |
--|    Rameshwar        12-APR-2004     BUG#3545701                        |
--|                 Commented the code for non-validated tests             |
--|                                                                        |
--| Saikiran Vankadari 07-Feb-2005  Changed as part of Convergence         |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE check_for_null_and_fks_in_stst
(
  p_spec_tests    IN  gmd_spec_tests%ROWTYPE
, x_spec_tests    OUT NOCOPY gmd_spec_tests%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
) IS


  CURSOR cr_test(p_test_id NUMBER) IS
  SELECT test_code,test_method_id,test_type,min_value_num,max_value_num,priority
  FROM   gmd_qc_tests_b
  WHERE  test_id = p_test_id
  AND    delete_mark = 0 ;

  CURSOR cr_test_method_valid(p_test_method_id NUMBER) IS
  SELECT test_method_id,test_replicate
  FROM   gmd_test_methods_b
  WHERE  test_method_id = p_test_method_id
  AND    delete_mark = 0 ;

  CURSOR cr_action_code(p_action_code VARCHAR2) IS
  SELECT 'x' FROM MTL_ACTIONS_B
  WHERE action_code = p_action_code
  AND   disable_flag = 'N';


  l_temp              VARCHAR2(1);
  l_grade_ctl	      NUMBER(1);
  l_test_type	      VARCHAR2(1);
  l_test_code	      GMD_QC_TESTS_B.TEST_CODE%TYPE;
  l_test_min_value_num     NUMBER;
  l_test_max_value_num     NUMBER;
  l_test_method_id    NUMBER;
  l_test_priority     GMD_SPEC_TESTS_B.TEST_PRIORITY%TYPE;
  l_test_method_replicate   NUMBER;

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_spec_tests := p_spec_tests;
  -- Test
  IF x_spec_tests.test_id IS NULL  THEN
     GMD_API_PUB.Log_Message('GMD_TEST_ID_CODE_NULL');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
      OPEN  cr_test(x_spec_tests.test_id);
      FETCH cr_test INTO l_test_code,l_test_method_id,l_test_type,l_test_min_value_num,
      	l_test_max_value_num,l_test_priority;
      IF cr_test%NOTFOUND THEN
    	 CLOSE cr_test;
    	 GMD_API_PUB.Log_Message('GMD_INVALID_TEST','TEST',x_spec_tests.test_id);
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE cr_test ;
  END IF;

  -- test method
  IF x_spec_tests.test_method_id IS NULL THEN
     x_spec_tests.test_method_id := l_test_method_id;
  ELSIF x_spec_tests.test_method_id <> l_test_method_id THEN
     GMD_API_PUB.Log_Message('GMD_SPEC_TST_MTHD_INVALID');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN  cr_test_method_valid(l_test_method_id);
  FETCH cr_test_method_valid INTO l_test_method_id,l_test_method_replicate;
  IF cr_test_method_valid%NOTFOUND THEN
     CLOSE cr_test_method_valid;
     GMD_API_PUB.Log_Message('GMD_TEST_METHOD_DELETED');
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE cr_test_method_valid ;

  -- test sequence
  IF x_spec_tests.seq IS NULL THEN
     GMD_API_PUB.Log_Message('GMD_SPEC_TEST_SEQ_REQD');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     IF x_spec_tests.seq <> trunc(x_spec_tests.seq) THEN
        GMD_API_PUB.Log_Message('GMD_SPEC_TEST_SEQ_NO');
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  IF l_test_type IN ('U','T','V') THEN

       IF (x_spec_tests.display_precision IS NOT NULL OR x_spec_tests.report_precision IS NOT NULL) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_PRECISION_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_spec_tests.min_value_num IS NOT NULL OR x_spec_tests.max_value_num IS NOT NULL) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_TEST_NUM_RANGE_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF x_spec_tests.target_value_num IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_TEST_NUM_TARGET_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       --BEGIN BUG#3545701
       --Commented the code for Non-validated tests.
       /* IF l_test_type = 'U' and x_spec_tests.target_value_char IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_TEST_CHAR_TARGET_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR; */
       --END BUG#3545701
       IF l_test_type = 'V' and x_spec_tests.target_value_char IS NULL THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_TEST_CHAR_TARGET_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (l_test_type = 'T') THEN
           IF (x_spec_tests.min_value_char IS NULL OR x_spec_tests.max_value_char IS NULL) THEN
               FND_MESSAGE.SET_NAME('GMD','GMD_TEST_RANGE_REQ');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
       ELSE
          IF (x_spec_tests.min_value_char IS NOT NULL OR x_spec_tests.max_value_char IS NOT NULL) THEN
             FND_MESSAGE.SET_NAME('GMD','GMD_TEST_CHAR_RANGE_NOT_REQD');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

      --BEGIN BUG#3545701
      --Commented the code for Non-validated tests.
      /*  IF l_test_type = 'U' and x_spec_tests.out_of_spec_action IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_ACTION_CODE_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF; */
      --END BUG#3545701

       IF x_spec_tests.exp_error_type IS NOT NULL THEN
            FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_EXP_ERROR_TYPE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_spec_tests.below_spec_min IS NOT NULL OR  x_spec_tests.below_min_action_code IS NOT NULL )
        OR (x_spec_tests.above_spec_min IS NOT NULL OR  x_spec_tests.above_min_action_code IS NOT NULL )
        OR (x_spec_tests.below_spec_max IS NOT NULL OR  x_spec_tests.below_max_action_code IS NOT NULL )
        OR (x_spec_tests.above_spec_max IS NOT NULL OR  x_spec_tests.above_max_action_code IS NOT NULL ) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_EXP_ERROR_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
   ELSE
       IF (x_spec_tests.display_precision IS NULL OR x_spec_tests.report_precision IS NULL ) THEN
           GMD_API_PUB.Log_Message('GMD_PRECISION_REQD','TEST',l_test_code);
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_spec_tests.display_precision not between 0 and 9) THEN
           GMD_API_PUB.Log_Message('GMD_INVALID_PRECISION','PRECISION',x_spec_tests.display_precision);
	   RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_spec_tests.report_precision not between 0 and 9) THEN
           GMD_API_PUB.Log_Message('GMD_INVALID_PRECISION','PRECISION',x_spec_tests.report_precision);
	   RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_spec_tests.min_value_num IS NULL AND x_spec_tests.max_value_num IS NULL) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_MIN_MAX_REQ');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF ((x_spec_tests.min_value_num IS NULL AND l_test_min_value_num IS NOT NULL)
          OR (x_spec_tests.max_value_num IS NULL AND l_test_max_value_num IS NOT NULL)) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_TEST_RANGE_REQ');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_spec_tests.min_value_char IS NOT NULL OR x_spec_tests.max_value_char IS NOT NULL) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_TEST_CHAR_RANGE_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF x_spec_tests.target_value_char IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_TEST_CHAR_TARGET_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF ((x_spec_tests.exp_error_type IN ('N','P')) OR (x_spec_tests.exp_error_type IS NULL)) THEN
    	   NULL ;
       ELSE
           FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_EXP_ERROR_TYPE');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF x_spec_tests.exp_error_type IS NULL AND
        (x_spec_tests.below_spec_min IS NOT NULL OR x_spec_tests.above_spec_min IS NOT NULL
        OR x_spec_tests.below_spec_max IS NOT NULL OR x_spec_tests.above_spec_max IS NOT NULL)
       THEN
       	   FND_MESSAGE.SET_NAME('GMD', 'GMD_EXP_ERROR_TYPE_REQ');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF x_spec_tests.exp_error_type IS NOT NULL AND
        (x_spec_tests.below_spec_min IS NULL AND x_spec_tests.above_spec_min IS NULL
        AND x_spec_tests.below_spec_max IS NULL AND x_spec_tests.above_spec_max IS NULL)
       THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_EXP_ERR_TYPE_NULL');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    -- test UOM and Quantity.
    IF (l_test_type = 'E') THEN
       IF (x_spec_tests.test_qty_uom IS NOT NULL OR x_spec_tests.test_qty IS NOT NULL) THEN
           GMD_API_PUB.Log_Message('GMD_TEST_UOM_QTY_NOT_REQD');
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSE
       IF x_spec_tests.test_qty <= 0 THEN
          GMD_API_PUB.Log_Message('GMD_TEST_QTY_NEG');
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_spec_tests.test_qty_uom IS NOT NULL AND x_spec_tests.test_qty IS NULL) OR
          (x_spec_tests.test_qty_uom IS NULL AND x_spec_tests.test_qty IS NOT NULL) THEN
           GMD_API_PUB.Log_Message('GMD_TEST_UOM_QTY_REQD');
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF x_spec_tests.test_priority IS NULL THEN
        x_spec_tests.test_priority := l_test_priority;

    ELSIF (NOT GMD_QC_TESTS_GRP.validate_test_priority(p_test_priority => x_spec_tests.test_priority)) THEN
        GMD_API_PUB.Log_Message('GMD_INVALID_TEST_PRIORITY');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Replicate Validation
    IF x_spec_tests.test_replicate IS NULL THEN
       GMD_API_PUB.Log_Message('GMD_TEST_REP_REQD');
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_test_type = 'E' and x_spec_tests.test_replicate <> 1) THEN
        GMD_API_PUB.Log_Message('SPEC_TEST_REPLICATE_ONE');
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_spec_tests.test_replicate < l_test_method_replicate) THEN
        GMD_API_PUB.Log_Message('SPEC_TEST_REPLICATE_ERROR',
                            'SPEC_TEST', l_test_code);
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Bug 3437091
    -- Check on CALC_UOM_CONV_IND
    IF (x_spec_tests.CALC_UOM_CONV_IND IS NULL) or
	(x_spec_tests.CALC_UOM_CONV_IND = 'Y')     then
	null;
    else
        GMD_API_PUB.Log_Message('GMD_UOM_CONV_IND');
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- action code foreign key validation.
    IF x_spec_tests.BELOW_MIN_ACTION_CODE IS NOT NULL THEN
        OPEN  cr_action_code(x_spec_tests.below_min_action_code);
    	FETCH cr_action_code INTO l_temp;
    	IF cr_action_code%NOTFOUND THEN
    	    CLOSE cr_action_code;
    	    GMD_API_PUB.Log_Message('GMD_INVALID_ACTION_CODE','ACTION',x_spec_tests.below_min_action_code);
    	    RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_action_code ;
    END IF;

    IF x_spec_tests.ABOVE_MIN_ACTION_CODE IS NOT NULL THEN
        OPEN  cr_action_code(x_spec_tests.above_min_action_code);
    	FETCH cr_action_code INTO l_temp;
    	IF cr_action_code%NOTFOUND THEN
    	    CLOSE cr_action_code;
    	    GMD_API_PUB.Log_Message('GMD_INVALID_ACTION_CODE','ACTION',x_spec_tests.above_min_action_code);
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_action_code ;
    END IF;

    IF x_spec_tests.BELOW_MAX_ACTION_CODE IS NOT NULL THEN
        OPEN  cr_action_code(x_spec_tests.below_max_action_code);
    	FETCH cr_action_code INTO l_temp;
    	IF cr_action_code%NOTFOUND THEN
    	    CLOSE cr_action_code;
    	    GMD_API_PUB.Log_Message('GMD_INVALID_ACTION_CODE','ACTION',x_spec_tests.below_max_action_code);
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_action_code ;
    END IF;

    IF x_spec_tests.ABOVE_MAX_ACTION_CODE IS NOT NULL THEN
        OPEN  cr_action_code(x_spec_tests.above_max_action_code);
    	FETCH cr_action_code INTO l_temp;
    	IF cr_action_code%NOTFOUND THEN
    	    CLOSE cr_action_code;
    	    GMD_API_PUB.Log_Message('GMD_INVALID_ACTION_CODE','ACTION',x_spec_tests.above_max_action_code);
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_action_code ;
    END IF;

    IF x_spec_tests.out_of_spec_action IS NOT NULL THEN
        OPEN  cr_action_code(x_spec_tests.out_of_spec_action);
    	FETCH cr_action_code INTO l_temp;
    	IF cr_action_code%NOTFOUND THEN
    	    CLOSE cr_action_code;
    	    GMD_API_PUB.Log_Message('GMD_INVALID_ACTION_CODE','ACTION',x_spec_tests.out_of_spec_action);
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_action_code ;
    END IF;

    IF x_spec_tests.use_to_control_step IS NULL OR x_spec_tests.use_to_control_step IN ('N','Y') THEN
    	NULL ;
    ELSE
        GMD_API_PUB.Log_Message('GMD_SPEC_INVALID_IND','COLUMN','USE_TO_CONTROL_STEP');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF x_spec_tests.use_to_control_step = 'N' THEN
       x_spec_tests.use_to_control_step:=  NULL;
    END IF;

    IF x_spec_tests.optional_ind IS NULL OR x_spec_tests.optional_ind IN ('N','Y') THEN
    	NULL ;
    ELSE
        GMD_API_PUB.Log_Message('GMD_SPEC_INVALID_IND','COLUMN','OPTIONAL_IND');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF x_spec_tests.optional_ind = 'N' THEN
       x_spec_tests.optional_ind:=  NULL;
    END IF;

    IF x_spec_tests.print_spec_ind IS NULL OR x_spec_tests.print_spec_ind IN ('N','Y') THEN
    	NULL ;
    ELSE
        GMD_API_PUB.Log_Message('GMD_SPEC_INVALID_IND','COLUMN','PRINT_SPEC_IND');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF x_spec_tests.print_spec_ind = 'N' THEN
       x_spec_tests.print_spec_ind:=  NULL;
    END IF;

    IF x_spec_tests.print_result_ind IS NULL OR x_spec_tests.print_result_ind IN ('N','Y') THEN
    	NULL ;
    ELSE
        GMD_API_PUB.Log_Message('GMD_SPEC_INVALID_IND','COLUMN','PRINT_RESULT_IND');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF x_spec_tests.print_result_ind = 'N' THEN
       x_spec_tests.print_result_ind:=  NULL;
    END IF;

    IF x_spec_tests.retest_lot_expiry_ind IS NULL OR x_spec_tests.retest_lot_expiry_ind IN ('N','Y') THEN
    	NULL ;
    ELSE
        GMD_API_PUB.Log_Message('GMD_SPEC_INVALID_IND','COLUMN','RETEST_LOT_EXPIRY_IND');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF x_spec_tests.retest_lot_expiry_ind = 'N' THEN
       x_spec_tests.retest_lot_expiry_ind:=  NULL;
    END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR','PACKAGE','gmd_spec_grp.check_for_null_and_fks_in_stst',
    	'ERROR',substr(sqlerrm,1,100),'POSITION','010');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END check_for_null_and_fks_in_stst;

--Start of comments
--+========================================================================+
--| API Name    : validate_spec_header                                     |
--| TYPE        : Group                                                    |
--| Notes       : This procedure validates all the fields of               |
--|               specification header. This procedure can be              |
--|               called from FORM or API and the caller need              |
--|               to specify this in p_called_from parameter               |
--|               while calling this procedure. Based on where             |
--|               it is called from certain validations will               |
--|               either be performed or skipped.                          |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                                   |
--|                                                                        |
--|                                                                        |
--| Saikiran Vankadari 07-Feb-2005  Changed as part of Convergence         |
--|                                                                        |                                                            |
--+========================================================================+
-- End of comments

PROCEDURE validate_spec_header
(
  p_spec_header   IN  gmd_specifications%ROWTYPE
, p_called_from   IN  VARCHAR2
, p_operation     IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
) IS

  -- Local Variables
  l_item_number                  VARCHAR2(80);
  l_owner                        VARCHAR2(30);
  l_return_status                VARCHAR2(1);
  l_owner_organization_code      VARCHAR2(3);

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_called_from = 'API') THEN
    -- Check for NULLs and Valid Foreign Keys in the input parameter
    GMD_Spec_GRP.check_for_null_and_fks_in_spec
      (
        p_spec_header   => p_spec_header
      , x_item_number   => l_item_number
      , x_owner         => l_owner
      , x_return_status => l_return_status
      );
    -- No need if called from FORM since it is already
    -- done in the form

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      -- Message is alrady logged by check_for_null procedure
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      -- Message is alrady logged by check_for_null procedure
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Verify that spec_name and spec_vers are unique
  IF (p_operation = 'INSERT' AND spec_vers_exist(p_spec_header.spec_name, p_spec_header.spec_vers)) THEN
    -- Ah...Ha, Spec and Version combination is already used
    GMD_API_PUB.Log_Message('GMD_SPEC_VERS_EXIST',
                            'SPEC', p_spec_header.spec_name,
                            'VERS', p_spec_header.spec_vers);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Verify that owner_id has access to owner_orgn_code
  IF NOT spec_owner_orgn_valid(fnd_global.resp_id,
                               p_spec_header.owner_organization_id) THEN
    -- Peep...Peep...Security Alert. User does not have access to Owner Organization
    SELECT organization_code INTO l_owner_organization_code
    FROM mtl_parameters
    WHERE organization_id = p_spec_header.owner_organization_id;
    GMD_API_PUB.Log_Message('GMD_USER_ORGN_NO_ACCESS',
                            'OWNER', l_owner,
                            'ORGN', l_owner_organization_code);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- All systems GO...

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
     GMD_API_PUB.Log_Message('GMD_API_ERROR','PACKAGE','gmd_spec_grp.validate_spec_header',
    	'ERROR',substr(sqlerrm,1,100),'POSITION','010');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END validate_spec_header;


--Start of comments
--+========================================================================+
--| API Name    : spec_vers_exist                                          |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the Spec and Spec Version  |
--|               combination already exist in the database, FALSE         |
--|               otherwise.                                               |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION spec_vers_exist(p_spec_name VARCHAR2, p_spec_vers NUMBER)
RETURN BOOLEAN IS

  CURSOR c_spec (p_spec_name VARCHAR2, p_spec_vers NUMBER) IS
  SELECT 1
  FROM   gmd_specifications_b
  WHERE  spec_name = p_spec_name
  AND    spec_vers  = p_spec_vers;

  dummy PLS_INTEGER;

BEGIN

  OPEN c_spec(p_spec_name, p_spec_vers);
  FETCH c_spec INTO dummy;
  IF c_spec%FOUND THEN
    CLOSE c_spec;
    RETURN TRUE;
  ELSE
    CLOSE c_spec;
    RETURN FALSE;
  END IF;

EXCEPTION
  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    RETURN TRUE;

END spec_vers_exist;




--Start of comments
--+========================================================================+
--| API Name    : spec_owner_orgn_valid                                    |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the Owner has access       |
--|               to the Organization specified, FALSE otherwise.          |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                                   |
--|                                                                        |
--| Saikiran Vankadari  07-Feb-2005     Changed as part of Convergence.    |
--|                 Taking responsibility_id as input parameter instead of |
--|		    Owner id and also changed the validation logic	               |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION spec_owner_orgn_valid(p_responsibility_id NUMBER,
                               p_owner_organization_id NUMBER)
RETURN BOOLEAN IS


  CURSOR c_user_orgn (p_responsibility_id NUMBER,
                      p_owner_organization_id NUMBER) IS
  SELECT 1
  FROM   org_access_view
  WHERE  responsibility_id   = p_responsibility_id
  AND    organization_id =     p_owner_organization_id;

  dummy PLS_INTEGER;

BEGIN

  OPEN c_user_orgn(p_responsibility_id, p_owner_organization_id);
  FETCH c_user_orgn INTO dummy;
  IF c_user_orgn%FOUND THEN
    CLOSE c_user_orgn;
    RETURN TRUE;
  ELSE
    CLOSE c_user_orgn;
    RETURN FALSE;
  END IF;

EXCEPTION
  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    RETURN FALSE;

END spec_owner_orgn_valid;

-- KYH BUG 2904004 BEGIN
--Start of comments
--+========================================================================+
--| API Name    : uom_class_combo_exist                                    |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the                        |
--|               to UOM class already exists on another                   |
--|               test line belonging to the spec                          |
--|               Otherwise returns FALSE                                  |
--|                                                                        |
--| HISTORY                                                                |
--|    KYH       16-APR-200       KYH Created for BUG 2904004              |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION uom_class_combo_exist(p_spec_id NUMBER, p_test_id NUMBER, p_to_uom VARCHAR2)
RETURN BOOLEAN IS

  CURSOR c_class_combo (p_spec_name VARCHAR2, p_spec_vers NUMBER, p_to_uom VARCHAR2) IS
  SELECT 1
  FROM   gmd_spec_tests_b st, mtl_units_of_measure um
  WHERE  st.spec_id =  p_spec_id
  AND    st.test_id <> p_test_id
  AND    st.to_qty_uom  =  um.uom_code
  AND    um.uom_class =
         (select uom_class from mtl_units_of_measure where uom_code = p_to_uom);

  dummy PLS_INTEGER;

BEGIN

  OPEN c_class_combo(p_spec_id, p_test_id, p_to_uom);
  FETCH c_class_combo INTO dummy;
  IF c_class_combo%FOUND THEN
    CLOSE c_class_combo;
    RETURN TRUE;
  ELSE
    CLOSE c_class_combo;
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN TRUE;

END uom_class_combo_exist;
-- KYH BUG 2904004 END

--Start of comments
--+========================================================================+
--| API Name    : validate_spec_test                                       |
--| TYPE        : Group                                                    |
--| Notes       : This procedure validates all the fields of               |
--|               Specification Test. This procedure can be                |
--|               called from FORM or API and the caller need              |
--|               to specify this in p_called_from parameter               |
--|               while calling this procedure. Based on where             |
--|               it is called from certain validations will               |
--|               either be performed or skipped.                          |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments
PROCEDURE validate_spec_test
(
  p_spec_test     IN  gmd_spec_tests%ROWTYPE
, p_called_from   IN  VARCHAR2
, p_operation     IN  VARCHAR2
, x_spec_test     OUT NOCOPY gmd_spec_tests%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
) IS

  CURSOR c_spec (p_spec_name VARCHAR2, p_spec_vers NUMBER) IS
  SELECT 1
  FROM   gmd_specifications_b
  WHERE  spec_name = p_spec_name
  AND    spec_vers  = p_spec_vers;

  CURSOR c_test_value (p_test_id NUMBER, p_value_char VARCHAR2) IS
  SELECT text_range_seq
  FROM   gmd_qc_test_values_b
  WHERE  test_id    = p_test_id
  AND    value_char = p_value_char  ;

  CURSOR c_spec_type (p_spec_id NUMBER) IS
  SELECT spec_type
  FROM   gmd_specifications_b
  WHERE  spec_id = p_spec_id ;

  -- Local Variables
  l_dummy                          NUMBER;
  l_item_number                  VARCHAR2(80);
  l_owner                        VARCHAR2(30);
  l_return_status                VARCHAR2(1);

  l_st_min                       NUMBER;
  l_st_target                    NUMBER;
  l_st_max                       NUMBER;


  l_specification                GMD_SPECIFICATIONS%ROWTYPE;
  l_specification_out            GMD_SPECIFICATIONS%ROWTYPE;
  l_test                         GMD_QC_TESTS%ROWTYPE;
  l_test_out                     GMD_QC_TESTS%ROWTYPE;
  l_item                         MTL_SYSTEM_ITEMS_KFV%ROWTYPE;
  -- Bug 3401368
  x_viability_time               NUMBER;
  x_viability_status             varchar2(100);

  -- Exceptions
  e_spec_fetch_error             EXCEPTION;
  e_test_fetch_error             EXCEPTION;
  e_test_method_fetch_error      EXCEPTION;
  error_fetch_item               EXCEPTION;
  x_spec_type varchar2(10);

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Fetch Specification Record. Spec must exists for Spec Test.
  l_specification.spec_id := p_spec_test.spec_id;
  -- Introduce l_specification_out as part of NOCOPY changes.
  IF NOT ( GMD_Specifications_PVT.Fetch_Row(
                    p_specifications => l_specification,
                    x_specifications => l_specification_out)
         ) THEN
    -- Fetch Error
    RAISE e_spec_fetch_error;
  END IF;
  l_specification := l_specification_out ;

  IF (p_called_from = 'API') THEN
    -- Check for NULLs and Valid Foreign Keys in the input parameter
    -- No need if called from FORM since it is already
    -- done in the form

    GMD_Spec_GRP.check_for_null_and_fks_in_stst
      (
        p_spec_tests     => p_spec_test
      , x_spec_tests     => x_spec_test
      , x_return_status => l_return_status
      );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      -- Message is alrady logged by check_for_null procedure
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      -- Message is alrady logged by check_for_null procedure
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  -- Fetch Test Record.
  l_test.test_id := x_spec_test.test_id;
  IF NOT ( GMD_QC_TESTS_PVT.Fetch_Row(
                    p_gmd_qc_tests => l_test,
                    x_gmd_qc_tests => l_test_out)
         ) THEN
    -- Fetch Error
    RAISE e_test_fetch_error;
  END IF;

  l_test := l_test_out ;


    -- Verify that Seq is unique
  IF (spec_test_seq_exist(x_spec_test.spec_id,x_spec_test.seq) )
   THEN
    -- Seq is already used
    GMD_API_PUB.Log_Message('GMD_SPEC_TEST_SEQ_EXIST', 'SEQ', x_spec_test.seq);
    RAISE FND_API.G_EXC_ERROR;
  end if ;


  -- Verify that Test is unique  (added by KYH 01/OCT/02)
  IF spec_test_exist(x_spec_test.spec_id,x_spec_test.test_id) THEN
    -- Test is already used
    GMD_API_PUB.Log_Message('GMD_SPEC_TEST_EXIST', 'TEST_ID', x_spec_test.test_id);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

   open c_spec_type(x_spec_test.spec_id);
   fetch c_spec_type into x_spec_type ;
   close c_spec_type ;

  -- Test UOM must be convertible to Item's UOM
  IF (x_spec_test.test_qty_uom IS NOT NULL)  and
     (x_spec_type = 'I') THEN
      BEGIN

      -- bug 4924529 sql id 14686748
      -- fields needed from mtl_system_items_kfv
      -- are l_item.primary_uom_code, l_item.lot_control_code and l_item.concatenated_segments.
      -- 155714 memory reduced
      -- cost is 3

  --   SELECT * INTO l_item
  --      FROM mtl_system_items_kfv
  --      WHERE organization_id = l_specification.owner_organization_id
  --      AND inventory_item_id = l_specification.inventory_item_id;

         SELECT primary_uom_code,
                lot_control_code,
                concatenated_segments
         INTO l_item.primary_uom_code,
              l_item.lot_control_code,
              l_item.concatenated_segments
        FROM mtl_system_items_kfv
        WHERE organization_id = l_specification.owner_organization_id
        AND inventory_item_id = l_specification.inventory_item_id;
      EXCEPTION WHEN OTHERS
      THEN
        RAISE error_fetch_item;
      END;

    -- GMD_API_PUB.Log_Message('GMD_SPEC_TEST_EXIST', 'TEST_ID', x_spec_test.test_id);
     --RAISE FND_API.G_EXC_ERROR;


      BEGIN
          /*GMICUOM.icuomcv(pitem_id => l_item_mst.item_id,
                  plot_id  => 0,
                  pcur_qty => 1,
                  pcur_uom => x_spec_test.test_uom,
                  pnew_uom => l_item_mst.item_um,
                  onew_qty => dummy);*/
       --As part of Convergence, call to GMICUOM.icuomcv() is replaced with call to inv_convert.inv_um_conversion()
          inv_convert.inv_um_conversion (
	          from_unit    =>  x_spec_test.test_qty_uom,
       	      to_unit      =>  l_item.primary_uom_code,
    	      item_id      =>  l_specification.inventory_item_id,
	          lot_number   =>  NULL,
    	      organization_id  => l_specification.owner_organization_id,
    	      uom_rate    => l_dummy );

      EXCEPTION WHEN OTHERS
      THEN
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END ;
  END IF;


  -- Target, Min and Max validation
  IF (l_test.test_type NOT IN ('U')) THEN

    -- Validate min,target and max for character based tests.

   IF x_spec_test.min_value_char IS NOT NULL THEN
      OPEN c_test_value(l_test.test_id, x_spec_test.min_value_char);
      FETCH c_test_value INTO  x_spec_test.min_value_num;
      IF c_test_value%NOTFOUND THEN
        CLOSE c_test_value;
        GMD_API_PUB.Log_Message('TEST_VALUES_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_test_value;
   END IF;

   IF x_spec_test.target_value_char IS NOT NULL THEN

      OPEN c_test_value(l_test.test_id, x_spec_test.target_value_char);
      FETCH c_test_value INTO  x_spec_test.target_value_num;
      IF c_test_value%NOTFOUND THEN
        CLOSE c_test_value;
        GMD_API_PUB.Log_Message('TEST_VALUES_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_test_value;
   END IF;

   IF x_spec_test.max_value_char IS NOT NULL THEN
      OPEN c_test_value(l_test.test_id, x_spec_test.max_value_char);
      FETCH c_test_value INTO  x_spec_test.max_value_num;
      IF c_test_value%NOTFOUND THEN
        CLOSE c_test_value;
        GMD_API_PUB.Log_Message('TEST_VALUES_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_test_value;
   END IF;


   IF (l_test.test_type NOT IN ('V')) THEN

      IF l_test.test_type IN ('L','E','N') THEN

         x_spec_test.min_value_num := ROUND(x_spec_test.min_value_num,x_spec_test.display_precision);
         x_spec_test.max_value_num := ROUND(x_spec_test.max_value_num,x_spec_test.display_precision);
         x_spec_test.target_value_num := ROUND(x_spec_test.target_value_num,x_spec_test.display_precision);
      END IF;

      l_st_min    := x_spec_test.min_value_num;
      l_st_target := x_spec_test.target_value_num;
      l_st_max    := x_spec_test.max_value_num;

    -- Now we all the min, max,and target values in NUMERIC format.
      IF NOT (spec_test_min_target_max_valid
              (p_validation_level => 'FULL'
              ,p_test_id   => l_test.test_id
              ,p_test_type => l_test.test_type
              ,p_st_min    => l_st_min
              ,p_st_target => l_st_target
              ,p_st_max    => l_st_max
              ,p_t_min     => l_test.min_value_num
              ,p_t_max     => l_test.max_value_num)
           ) THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF; -- l_test.test_type NOT IN ('V')

 END IF; -- l_test.test_type NOT IN ('U')


  -- Lot Retest Indicator
  IF ( x_spec_test.retest_lot_expiry_ind = 'Y' and l_item.lot_control_code = 1) THEN
    GMD_API_PUB.Log_Message('SPEC_TEST_RETEST_IND_ERROR',
                            'SPEC_TEST', l_test.test_code,
                            'SPEC_TEST', l_item.concatenated_segments);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Experimental Error Min and Max validation
  IF (l_test.test_type IN ('N', 'L', 'E') AND x_spec_test.exp_error_type IS NOT NULL ) THEN
    IF x_spec_test.exp_error_type = 'N' THEN
         x_spec_test.below_spec_min := ROUND(x_spec_test.below_spec_min,x_spec_test.display_precision);
         x_spec_test.above_spec_min := ROUND(x_spec_test.above_spec_min,x_spec_test.display_precision);
         x_spec_test.below_spec_max := ROUND(x_spec_test.below_spec_max,x_spec_test.display_precision);
         x_spec_test.above_spec_max := ROUND(x_spec_test.above_spec_max,x_spec_test.display_precision);
    END IF;
    IF NOT spec_test_exp_error_region_val
               (p_validation_level => 'FULL',
                p_exp_error_type   => x_spec_test.exp_error_type,
                p_test_min         => l_test.min_value_num,
                p_below_spec_min   => x_spec_test.below_spec_min,
                p_spec_test_min    => x_spec_test.min_value_num,
                p_above_spec_min   => x_spec_test.above_spec_min,
                p_spec_test_target => x_spec_test.target_value_num,
                p_below_spec_max   => p_spec_test.below_spec_max,
                p_spec_test_max    => x_spec_test.max_value_num,
                p_above_spec_max   => x_spec_test.above_spec_max,
                p_test_max         => l_test.max_value_num) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_spec_test.below_min_action_code IS NOT NULL and x_spec_test.below_spec_min IS NULL THEN
        GMD_API_PUB.Log_Message('GMD_EXP_ERR_VAL_REQ_ACTION');
       	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_spec_test.above_min_action_code IS NOT NULL and x_spec_test.above_spec_min IS NULL THEN
        GMD_API_PUB.Log_Message('GMD_EXP_ERR_VAL_REQ_ACTION');
       	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_spec_test.below_max_action_code IS NOT NULL and x_spec_test.below_spec_max IS NULL THEN
        GMD_API_PUB.Log_Message('GMD_EXP_ERR_VAL_REQ_ACTION');
       	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_spec_test.above_max_action_code IS NOT NULL and x_spec_test.above_spec_max IS NULL THEN
        GMD_API_PUB.Log_Message('GMD_EXP_ERR_VAL_REQ_ACTION');
       	RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  IF NOT spec_test_precisions_valid(
  	 	 p_spec_display_precision => x_spec_test.display_precision,
		 p_spec_report_precision => x_spec_test.report_precision,
		 p_test_display_precision => l_test.display_precision,
		 p_test_report_precision  => l_test.display_precision ) THEN
    -- Messages are already logged.
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 --Update the Viability Period ( Bug 3401368)
  if (x_spec_test.days is not null) OR
	(x_spec_test.hours is not null) OR
	(x_spec_test.minutes is not null) OR
	(x_spec_test.seconds is not null) THEN

	GMD_TEST_METHODS_GRP.GET_TEST_DURATION(
		P_DAYS => x_spec_test.DAYS,
		P_HOURS => x_spec_test.HOURS,
		P_MINS =>  x_spec_test.MINUTES,
		P_SECS => x_spec_test.SECONDS,
		X_DURATION_SECS => x_viability_time,
		X_RETURN_STATUS => x_viability_status );

	if (x_viability_status = 'S') then
		x_spec_test.VIABILITY_DURATION := x_viability_time;
        end if ;

  end if ;


  -- All systems GO...

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR','PACKAGE','gmd_spec_grp.validate_spec_test',
    	'ERROR',substr(sqlerrm,1,100),'POSITION','010');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END validate_spec_test;

/*===========================================================================

  PROCEDURE NAME:	validate_after_insert_all
  DESCRIPTION:		This procedure validates that atleast one test
  			should be attached to the spec.
  			It

===========================================================================*/

PROCEDURE validate_after_insert_all(
	p_spec_id   	   IN  NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2) IS

CURSOR cr_expression_tests IS
  SELECT a.test_id,a.seq
  FROM   GMD_SPEC_TESTS_B a , GMD_QC_TESTS_B b
  WHERE
 	a.spec_id = p_spec_id
   AND  a.test_id = b.test_id
   AND  b.test_type = 'E' ;

l_test_count  BINARY_INTEGER;
l_test_id	NUMBER;
l_test_seq	BINARY_INTEGER;


BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF p_spec_id IS NULL THEN
	     GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
	     RAISE FND_API.G_EXC_ERROR;
	END IF;

-- atleast one test should be present in the spec.
	SELECT NVL(COUNT(1),0) INTO l_test_count
        FROM GMD_SPEC_TESTS_B
        WHERE spec_id = p_spec_id ;

        IF l_test_count = 0 THEN
	    FND_MESSAGE.SET_NAME('GMD','GMD_SPEC_NO_TEST');
            FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
        END IF;

-- validate expression based tests.
-- all the reference tests must be present.

        OPEN  cr_expression_tests;
	LOOP
   	   FETCH cr_expression_tests INTO l_test_id,l_test_seq;
	   IF cr_expression_tests%NOTFOUND THEN
	       EXIT;
	   END IF;
	   IF NOT GMD_SPEC_GRP.spec_reference_tests_exist(
			p_spec_id => p_spec_id,
			p_exp_test_seq => l_test_seq,
			p_exp_test_id => l_test_id ) THEN
		CLOSE cr_expression_tests ;
		GMD_API_PUB.Log_Message('GMD_SOME_REF_TESTS_MISSING');
		RAISE FND_API.G_EXC_ERROR;
	   END IF;
	END LOOP;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN OTHERS THEN
      GMD_API_PUB.Log_Message('GMD_API_ERROR','PACKAGE','gmd_spec_grp.validate_after_insert_all',
    	 'ERROR',substr(sqlerrm,1,100),'POSITION','010');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END validate_after_insert_all;

/*===========================================================================
  PROCEDURE  NAME:	validate_before_delete

  DESCRIPTION:		This procedure validates GMD_SPECIFICATIONS:
                        a) Primary key supplied
                        b) Spec is not already delete_marked
                        c) Status permits update

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	KYH
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_DELETE(
	p_spec_id          IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress   VARCHAR2(3);
l_temp       VARCHAR2(1);
l_spec       GMD_SPECIFICATIONS%ROWTYPE;
l_spec_out   GMD_SPECIFICATIONS%ROWTYPE;

BEGIN
	l_progress := '010';
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

        -- validate for primary key
        -- ========================
	IF p_spec_id IS NULL THEN
	     FND_MESSAGE.SET_NAME('GMD','GMD_SPEC_ID_REQUIRED'); -- New Message
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_spec.spec_id := p_spec_id;
	END IF;

        -- Fetch the row
        -- =============
        IF  NOT GMD_Specifications_PVT.Fetch_Row(l_spec,l_spec_out)
        THEN
          fnd_message.set_name('GMD','GMD_FAILED_TO_FETCH_ROW');
          fnd_message.set_token('L_TABLE_NAME','GMD_SPECIFICATIONS');
          fnd_message.set_token('L_COLUMN_NAME','SPEC_ID');
          fnd_message.set_token('L_KEY_VALUE',l_spec.spec_id);
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_spec := l_spec_out ;

        -- Terminate if the row is already delete marked
        -- =============================================
        IF l_spec.delete_mark <> 0
        THEN
          fnd_message.set_name('GMD','GMD_RECORD_DELETE_MARKED');
          fnd_message.set_token('L_TABLE_NAME','GMD_SPECIFICATIONS');
          fnd_message.set_token('L_COLUMN_NAME','SPEC_ID');
          fnd_message.set_token('L_KEY_VALUE',l_spec.spec_id);
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- BUG 2698311
        -- Block deletes if the status is 400 (Approved for Lab Use) or
        -- ============================== 700 (Approved for General Use)
        -- ============================================================
        IF l_spec.spec_status in (400,700)
        THEN
          fnd_message.set_name('GMD','GMD_SPEC_STATUS_BLOCKS_DELETE');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Ensure that the status permits updates
        -- ======================================
        IF  NOT GMD_SPEC_GRP.Record_Updateable_With_Status(l_spec.spec_status)
        THEN
          fnd_message.set_name('GMD','GMD_SPEC_STATUS_BLOCKS_UPDATE');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_SPEC_GRP.VALIDATE_BEFORE_DELETE');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE_BEFORE_DELETE ;

/*===========================================================================
  PROCEDURE  NAME:	validate_before_delete

  DESCRIPTION:		This procedure validates GMD_SPEC_TEST:
                        a) Primary key supplied
                        b) Spec is not already delete_marked

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	KYH
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_DELETE(
	p_spec_id          IN NUMBER,
	p_test_id          IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress   		VARCHAR2(3);
l_temp       		VARCHAR2(1);
l_spec_tests 		GMD_SPEC_TESTS%ROWTYPE;
l_spec_tests_out	GMD_SPEC_TESTS%ROWTYPE;
l_spec_delete_mark	BINARY_INTEGER;

BEGIN
	l_progress := '010';
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	-- validate for primary key
        -- ========================
	IF p_spec_id IS NULL THEN
	     FND_MESSAGE.SET_NAME('GMD','GMD_SPEC_ID_REQUIRED');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_spec_tests.spec_id := p_spec_id;
	END IF;

	IF p_test_id IS NULL THEN
	     FND_MESSAGE.SET_NAME('GMD','GMD_TEST_ID_CODE_NULL');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_spec_tests.test_id := p_test_id;
	END IF;

        -- Fetch the row
        -- =============
        IF  NOT GMD_Spec_Tests_PVT.Fetch_Row(l_spec_tests,l_spec_tests_out)
        THEN
          fnd_message.set_name('GMD','GMD_FAILED_TO_FETCH_ROW');
          fnd_message.set_token('L_TABLE_NAME','GMD_SPEC_TESTS');
          fnd_message.set_token('L_COLUMN_NAME','TEST_ID');
          fnd_message.set_token('L_KEY_VALUE',l_spec_tests.test_id);
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_spec_tests := l_spec_tests_out ;

        SELECT delete_mark into l_spec_delete_mark
        FROM GMD_SPECIFICATIONS_B
        WHERE spec_id = p_spec_id ;

        IF l_spec_delete_mark <> 0
        THEN
          fnd_message.set_name('GMD','GMD_RECORD_DELETE_MARKED');
          fnd_message.set_token('L_TABLE_NAME','GMD_SPECIFICATIONS');
          fnd_message.set_token('L_COLUMN_NAME','SPEC_ID');
          fnd_message.set_token('L_KEY_VALUE',p_spec_id);
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_SPEC_GRP.VALIDATE_BEFORE_DELETE');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE_BEFORE_DELETE ;

PROCEDURE validate_after_delete_test(
	p_spec_id   	   IN  NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2) IS

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS ;

     validate_after_insert_all(
     	p_spec_id   	   => p_spec_id,
	x_return_status    => x_return_status) ;

END validate_after_delete_test;

--Start of comments
--+========================================================================+
--| API Name    : spec_test_seq_exist                                      |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the Spec Test Seq          |
--|               already exist in the database, FALSE                     |
--|               otherwise.                                               |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION spec_test_seq_exist(p_spec_id 		IN NUMBER ,
	 	             p_seq     		IN NUMBER ,
	 	             p_exclude_test_id  IN NUMBER )
RETURN BOOLEAN IS

dummy PLS_INTEGER;

BEGIN

  IF p_exclude_test_id IS NULL THEN
     SELECT 1 INTO dummy
     FROM GMD_SPEC_TESTS_B
     WHERE  spec_id = p_spec_id
     AND    seq = p_seq ;
  ELSE
     SELECT 1 INTO dummy
     FROM GMD_SPEC_TESTS_B
     WHERE  spec_id = p_spec_id
     AND    seq = p_seq
     AND    test_id <> p_exclude_test_id ;
  END IF;
  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN FALSE;

  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    RETURN TRUE;

END spec_test_seq_exist;

--Start of comments
--+========================================================================+
--| API Name    : spec_test_exist                                          |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the test_id already        |
--|               exists against the owning spec, otherwise it returns     |
--|               FALSE.                                                   |
--|                                                                        |
--| HISTORY                                                                |
--|    Karen Y. Hunt 01-OCT-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION spec_test_exist(p_spec_id 		IN NUMBER ,
	 	         p_test_id 		IN NUMBER )
RETURN BOOLEAN IS

dummy PLS_INTEGER;

BEGIN

  SELECT 1 INTO dummy
    FROM GMD_SPEC_TESTS_B
    WHERE  spec_id = p_spec_id
    AND    test_id = p_test_id;

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN FALSE;

  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    RETURN TRUE;

END spec_test_exist;


--Start of comments
--+========================================================================+
--| API Name    : spec_reference_tests_exist                               |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if all the reference tests    |
--|               which are part of the current expression are already     |
--|               entered on the specification, FALSE otherwise.           |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION spec_reference_tests_exist(p_spec_id NUMBER, p_exp_test_seq NUMBER, p_exp_test_id NUMBER)
RETURN BOOLEAN IS

  CURSOR c_test_values (p_exp_test_id NUMBER) IS
  SELECT EXPRESSION_REF_TEST_ID
  FROM   gmd_qc_test_values_b
  WHERE  test_id = p_exp_test_id;

  CURSOR c_spec_test (p_spec_id NUMBER, p_exp_test_seq NUMBER, p_ref_test_id NUMBER) IS
  SELECT 1
  FROM   GMD_SPEC_TESTS_B
  WHERE  spec_id = p_spec_id
  AND    test_id = p_ref_test_id
  AND    seq < p_exp_test_seq;

  -- Local Variables
  dummy PLS_INTEGER;

  -- Exceptions
  e_ref_test_missing            EXCEPTION;

BEGIN

  -- Get all the reference tests for the expression test
  FOR i in c_test_values(p_exp_test_id)
  LOOP
    -- See if the reference test is part of the spec
    -- with sequence lower then that of expression test.
    OPEN c_spec_test(p_spec_id, p_exp_test_seq, i.EXPRESSION_REF_TEST_ID);
    FETCH c_spec_test INTO dummy;
    IF c_spec_test%NOTFOUND THEN
      RAISE e_ref_test_missing;
    END IF;
    CLOSE c_spec_test;
  END LOOP;

  RETURN TRUE;

EXCEPTION
  WHEN e_ref_test_missing THEN
    IF c_spec_test%ISOPEN THEN CLOSE c_spec_test; END IF;
    IF c_test_values%ISOPEN THEN CLOSE c_test_values; END IF;
    RETURN FALSE;

  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    RETURN FALSE;

END spec_reference_tests_exist;

--Start of comments
--+========================================================================+
--| API Name    : value_in_num_range_display                               |
--| TYPE        : Group                                                    |
--| Notes       : This function checks if the given value                  |
--|               is between the test range or not.If the value is between |
--|               the test range ,it returns TRUE else it returns FALSE    |
--|                                                                        |
--| HISTORY                                                                |
--|    Mahesh Chandak	09-Oct-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION value_in_num_range_display(p_test_id  		IN NUMBER,
				    p_value   		IN NUMBER,
				    x_return_status	OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS

CURSOR cr_test_values IS
SELECT '1'
FROM   gmd_qc_test_values_b
WHERE  test_id = p_test_id
AND    p_value >= nvl(min_num,p_value)
AND    p_value <= nvl(max_num,p_value);

l_position		VARCHAR2(3);
l_temp			VARCHAR2(1);
REQ_FIELDS_MISSING 	EXCEPTION;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FND_MSG_PUB.initialize;
   l_position := '010';

   IF p_test_id IS NULL OR p_value IS NULL THEN
      RAISE REQ_FIELDS_MISSING;
   END IF;

   OPEN   cr_test_values;
   FETCH  cr_test_values INTO l_temp;
   IF  cr_test_values%FOUND THEN
       CLOSE cr_test_values;
       RETURN TRUE;
   END IF;
   CLOSE cr_test_values;
   gmd_api_pub.log_message('GMD_VAL_MISSING_NUM_LABEL_TEST','VALUE',p_value);
   RETURN FALSE;

EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_GRP.VALUE_IN_NUM_RANGE_DISPLAY');
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_GRP.VALUE_IN_NUM_RANGE_DISPLAY','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END value_in_num_range_display ;

--Start of comments
--+========================================================================+
--| API Name    : spec_test_min_target_max_valid                           |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the Spec Test Min, Target, |
--|               and Max values are alphanumrecically in correct order,   |
--|               FALSE otherwise.                                         |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--+========================================================================+
-- End of comments

FUNCTION spec_test_min_target_max_valid(p_test_id	   IN   NUMBER,
					p_test_type 	   IN	VARCHAR2,
					p_validation_level IN	VARCHAR2,
					p_st_min    	   IN	NUMBER,
                                        p_st_target 	   IN 	NUMBER,
                                        p_st_max    	   IN	NUMBER,
                                        p_t_min     	   IN	NUMBER,
                                        p_t_max     	   IN	NUMBER)
RETURN BOOLEAN IS

e_min_error 		EXCEPTION;
e_max_error 		EXCEPTION;
e_target_error 		EXCEPTION;
l_position		VARCHAR2(3);
l_return_status 	VARCHAR2(1);
e_num_range_label_hole	EXCEPTION;
REQ_FIELDS_MISSING 	EXCEPTION;
l_val_missing		NUMBER;

BEGIN

   FND_MSG_PUB.initialize;
   l_position := '010';


   IF p_test_id IS NULL OR p_test_type IS NULL OR p_test_type IN ('U','V') THEN
      RAISE REQ_FIELDS_MISSING;
   END IF;

  -- check spec min is >= target and <= spec max. Also spec min is between test min and test max.
  IF p_validation_level IN ('ST_MIN','FULL') THEN
     IF p_st_min IS NOT NULL THEN
       	IF (p_st_min > p_st_target OR p_st_min > p_st_max OR p_st_min < p_t_min OR p_st_min > p_t_max) THEN
        	RAISE e_min_error;
     	END IF;

    --  num range with display can have holes in the subranges
    --  check that the value does not fall into one of those holes
     	IF p_test_type = 'L' THEN
           IF NOT value_in_num_range_display(p_test_id  	=> p_test_id,
					    p_value   		=> p_st_min,
					    x_return_status	=> l_return_status) THEN
	       RETURN FALSE;
	   END IF;
        END IF;
     END IF; -- IF p_st_min IS NOT NULL
  END IF;

  l_position := '020';

  IF p_validation_level IN ('ST_TARGET','FULL') THEN
     IF p_st_target IS NOT NULL THEN
     	IF (p_st_min > p_st_target OR p_st_target > p_st_max OR p_st_target < p_t_min OR p_st_target > p_t_max) THEN
             RAISE e_target_error;
     	END IF;

     	IF p_test_type = 'L' THEN
           IF NOT value_in_num_range_display(p_test_id  	=> p_test_id,
					    p_value   		=> p_st_target,
					    x_return_status	=> l_return_status) THEN
	  	RETURN FALSE;
	   END IF;
        END IF;
     END IF; -- IF p_st_target IS NOT NULL THEN
  END IF;

  l_position := '030';

  IF p_validation_level IN ('ST_MAX','FULL') THEN
     IF p_st_max IS NOT NULL THEN
     	IF (p_st_min > p_st_max OR p_st_target > p_st_max OR p_st_max < p_t_min OR p_st_max > p_t_max) THEN
        	RAISE e_max_error;
     	END IF;
        IF p_test_type = 'L' THEN
           IF NOT value_in_num_range_display(p_test_id  	=> p_test_id,
					    p_value   		=> p_st_max,
					    x_return_status	=> l_return_status) THEN
	  	RETURN FALSE;
	   END IF;
        END IF;
     END IF; -- IF p_st_max IS NOT NULL THEN
  END IF;

  RETURN TRUE;

EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_GRP.SPEC_TEST_MIN_TARGET_MAX_VALID');
   RETURN FALSE;
WHEN e_min_error THEN
   gmd_api_pub.log_message('GMD_SPEC_TEST_MIN_ERROR','SPEC_TEST_MIN',to_char(p_st_min),'SPEC_TEST_MAX',
   	to_char(p_st_max),'SPEC_TEST_TARGET',to_char(p_st_target),'TEST_MIN',to_char(p_t_min),'TEST_MAX',to_char(p_t_max));
   RETURN FALSE;
WHEN e_max_error THEN
   gmd_api_pub.log_message('GMD_SPEC_TEST_MAX_ERROR','SPEC_TEST_MIN',to_char(p_st_min),'SPEC_TEST_MAX',
   	to_char(p_st_max),'SPEC_TEST_TARGET',to_char(p_st_target),'TEST_MIN',to_char(p_t_min),'TEST_MAX',to_char(p_t_max));
   RETURN FALSE;
WHEN e_target_error THEN
   gmd_api_pub.log_message('GMD_SPEC_TEST_TARGET_ERROR','SPEC_TEST_MIN',to_char(p_st_min),'SPEC_TEST_MAX',
   	to_char(p_st_max),'SPEC_TEST_TARGET',to_char(p_st_target),'TEST_MIN',to_char(p_t_min),'TEST_MAX',to_char(p_t_max));
   RETURN FALSE;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_GRP.SPEC_TEST_MIN_TARGET_MAX_VALID','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   RETURN FALSE;
END spec_test_min_target_max_valid;


--Start of comments
--+========================================================================+
--| API Name    : SPEC_TEST_EXP_ERROR_REGION_VAL                           |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the Spec Test experimental |
--|               errors values for  Below Min, Above Min, Below Max, and  |
--|               Above Max are alphanumrecically in correct order,        |
--|               FALSE otherwise.                                         |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments


FUNCTION SPEC_TEST_EXP_ERROR_REGION_VAL(   p_validation_level VARCHAR2,
				       p_exp_error_type VARCHAR2,
				       p_test_min NUMBER,
                                       p_below_spec_min NUMBER,
                                       p_spec_test_min NUMBER,
                                       p_above_spec_min NUMBER,
                                       p_spec_test_target NUMBER,
                                       p_below_spec_max NUMBER,
                                       p_spec_test_max NUMBER,
                                       p_above_spec_max NUMBER,
                                       p_test_max NUMBER)
RETURN BOOLEAN IS

e_range_error 	EXCEPTION;
l_spec_num	NUMBER;
l_max_value     NUMBER;
l_position      NUMBER;
BEGIN
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF p_exp_error_type IS NULL THEN
     RETURN TRUE;
  END IF;

  IF p_exp_error_type NOT IN ( 'N','P') THEN
      GMD_API_PUB.Log_Message('GMD_INVALID_EXP_ERROR_TYPE');
      RETURN FALSE;
  END IF;

  IF p_validation_level IN ('FULL','BELOW_SPEC_MIN') THEN

     IF p_below_spec_min = 0 OR p_below_spec_min IS NULL THEN
        RETURN TRUE;
     END IF;

     IF p_below_spec_min IS NOT NULL AND (p_spec_test_min = p_test_min OR p_test_max = p_test_min) THEN
        GMD_API_PUB.Log_Message('GMD_SPEC_ERROR_REG_NOT_APPL');
        RETURN FALSE;
     END IF;

     IF (p_below_spec_min IS NOT NULL AND p_spec_test_min IS NOT NULL and p_test_min IS NOT NULL ) THEN
        IF p_exp_error_type = 'N' THEN
           l_spec_num := p_below_spec_min ;
        ELSE
           l_spec_num := ( p_below_spec_min * ( p_test_max - p_test_min )) /100 ;
        END IF;

        IF ABS(l_spec_num) > ( p_spec_test_min - p_test_min) THEN
           IF p_exp_error_type = 'N' THEN
              l_max_value := ABS(p_spec_test_min - p_test_min);
           ELSE
              l_max_value := (ABS(p_spec_test_min - p_test_min) * 100)/(p_test_max - p_test_min);
           END IF;
           GMD_API_PUB.Log_Message('GMD_INVALID_SPEC_VAL_NUM','MAX_VAL',to_char(l_max_value));
      	   RETURN FALSE;
        END IF;
     END IF;
  END IF;

  l_position := '020';

  IF p_validation_level IN ('FULL','ABOVE_SPEC_MAX') THEN

     IF p_above_spec_max = 0 OR p_above_spec_max IS NULL THEN
        RETURN TRUE;
     END IF;

     IF p_above_spec_max IS NOT NULL AND (p_spec_test_max = p_test_max OR p_test_max = p_test_min) THEN
        GMD_API_PUB.Log_Message('GMD_SPEC_ERROR_REG_NOT_APPL');
        RETURN FALSE;
     END IF;

     IF (p_above_spec_max IS NOT NULL AND p_spec_test_max IS NOT NULL and p_test_max IS NOT NULL ) THEN
        IF p_exp_error_type = 'N' THEN
           l_spec_num := p_above_spec_max ;
        ELSE
           l_spec_num := ( p_above_spec_max * ( p_test_max - p_test_min )) /100 ;
        END IF;

        IF ABS(l_spec_num) > ( p_test_max - p_spec_test_max) THEN
           IF p_exp_error_type = 'N' THEN
              l_max_value := ABS(p_test_max - p_spec_test_max);
           ELSE
              l_max_value := (ABS(p_test_max - p_spec_test_max) * 100)/(p_test_max - p_test_min);
           END IF;
           GMD_API_PUB.Log_Message('GMD_INVALID_SPEC_VAL_NUM','MAX_VAL',to_char(l_max_value));
      	   RETURN FALSE;
        END IF;
     END IF;
  END IF;

  l_position := '030';

  IF p_validation_level IN ('FULL','ABOVE_SPEC_MIN') THEN

     IF p_above_spec_min = 0 OR p_above_spec_min IS NULL THEN
        RETURN TRUE;
     END IF;

     IF p_above_spec_min IS NOT NULL AND (p_spec_test_target = p_test_min OR p_test_max = p_test_min) THEN
        GMD_API_PUB.Log_Message('GMD_SPEC_ERROR_REG_NOT_APPL');
        RETURN FALSE;
     END IF;

     IF (p_above_spec_min IS NOT NULL AND p_spec_test_min IS NOT NULL and p_spec_test_target IS NOT NULL ) THEN
        IF p_exp_error_type = 'N' THEN
           l_spec_num := p_above_spec_min ;
        ELSE
           l_spec_num := ( p_above_spec_min * ( p_test_max - p_test_min )) /100 ;
        END IF;

        IF ABS(l_spec_num) > ( p_spec_test_target - p_spec_test_min) THEN
           IF p_exp_error_type = 'N' THEN
              l_max_value := ABS(p_spec_test_target - p_spec_test_min);
           ELSE
              l_max_value := (ABS(p_spec_test_target - p_spec_test_min) * 100)/(p_test_max - p_test_min);
           END IF;
           GMD_API_PUB.Log_Message('GMD_INVALID_SPEC_VAL_NUM','MAX_VAL',to_char(l_max_value));
      	   RETURN FALSE;
        END IF;
     END IF;
  END IF;

  l_position := '040';

  IF p_validation_level IN ('FULL','BELOW_SPEC_MAX') THEN

     IF p_below_spec_max = 0 OR p_below_spec_max IS NULL THEN
        RETURN TRUE;
     END IF;

     IF p_below_spec_max IS NOT NULL AND (p_spec_test_max = p_spec_test_target OR p_test_max = p_test_min) THEN
        GMD_API_PUB.Log_Message('GMD_SPEC_ERROR_REG_NOT_APPL');
        RETURN FALSE;
     END IF;

     IF (p_below_spec_max IS NOT NULL AND p_spec_test_max IS NOT NULL and p_spec_test_target IS NOT NULL ) THEN
        IF p_exp_error_type = 'N' THEN
           l_spec_num := p_below_spec_max ;
        ELSE
           l_spec_num := ( p_below_spec_max * ( p_test_max - p_test_min )) /100 ;
        END IF;

        IF ABS(l_spec_num) > (p_spec_test_max - p_spec_test_target ) THEN
           IF p_exp_error_type = 'N' THEN
              l_max_value := ABS(p_spec_test_max - p_spec_test_target);
           ELSE
              l_max_value := (ABS(p_spec_test_max - p_spec_test_target) * 100)/(p_test_max - p_test_min);
           END IF;
           GMD_API_PUB.Log_Message('GMD_INVALID_SPEC_VAL_NUM','MAX_VAL',to_char(l_max_value));
      	   RETURN FALSE;
        END IF;
     END IF;
  END IF;

  RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
    gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_GRP.SPEC_TEST_EXP_ERROR_REGION_VAL','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
    RETURN FALSE;
END SPEC_TEST_EXP_ERROR_REGION_VAL;



--Start of comments
--+========================================================================+
--| API Name    : spec_test_precisions_valid                               |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the Spec Test Display and  |
--|               Report precisions are valid, FALSE otherwise.            |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION spec_test_precisions_valid(p_spec_display_precision IN NUMBER,
		 		    p_spec_report_precision  IN NUMBER,
				    p_test_display_precision  IN NUMBER,
				    p_test_report_precision  IN NUMBER)
RETURN BOOLEAN IS

  e_range_error EXCEPTION;

BEGIN

  IF (p_spec_report_precision  > p_spec_display_precision) THEN
    GMD_API_PUB.Log_Message('GMD_REP_GRTR_DIS_PRCSN');

    RETURN FALSE;
  ELSIF (p_spec_display_precision > p_test_display_precision) THEN
    GMD_API_PUB.Log_Message('SPEC_TEST_DISPLAY_PREC_ERROR');

    RETURN FALSE;
  ELSIF (p_spec_report_precision  > p_test_report_precision) THEN
    GMD_API_PUB.Log_Message('SPEC_TEST_REPORT_PREC_ERROR');

    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    RETURN FALSE;

END spec_test_precisions_valid;



--Start of comments
--+========================================================================+
--| API Name    : status_record_updateable                                 |
--| TYPE        : Group                                                    |
--| Notes       : This function returns FALSE if the transaction record    |
--|               with the supplied status can not be updated, else TRUE.   |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION record_updateable_with_status(p_status NUMBER)
RETURN BOOLEAN IS

  CURSOR c_status (p_status_code NUMBER) IS
    SELECT a.updateable
    FROM   gmd_qc_status a
    WHERE  a.status_type =
      (SELECT status_type
       FROM   gmd_qc_status b
       WHERE  b.status_code = p_status_code
       and    b.entity_type = 'S')
    and    a.entity_type = 'S'
    ;

  -- Local Variables
  upd_flag                 VARCHAR2(1);

BEGIN
  OPEN c_status(p_status);
  FETCH c_status INTO upd_flag;
  IF c_status%NOTFOUND THEN
     upd_flag:= 'N';
  END IF;
  CLOSE c_status ;
  IF upd_flag = 'N' THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;

END record_updateable_with_status;

--Start of comments
--+========================================================================+
--| API Name    : spec_used_in_sample                                      |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the specification is used  |
--|               in any sample else FALSE                                           |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION spec_used_in_sample(p_spec_id NUMBER) RETURN BOOLEAN IS

-- perf  bug 4924529  sql id 14687024  (FTS and MJC)

CURSOR cr_spec_exist_in_sample IS
/*
 SELECT '1' FROM GMD_SAMPLING_EVENTS a , GMD_ALL_SPEC_VRS b
 WHERE
     b.spec_id = p_spec_id
 AND b.SPEC_VR_ID = a.ORIGINAL_SPEC_VR_ID ; */

SELECT '1' FROM GMD_SAMPLING_EVENTS a , GMD_INVENTORY_SPEC_VRS b,
gmd_qc_status_tl t
 WHERE
     b.spec_id = p_spec_id
 AND b.SPEC_VR_ID = a.ORIGINAL_SPEC_VR_ID
 AND b.spec_vr_status = t.status_code AND t.entity_type = 'S'
UNION
SELECT '1' FROM GMD_SAMPLING_EVENTS a , GMD_WIP_SPEC_VRS b,
gmd_qc_status_tl t
 WHERE
     b.spec_id = p_spec_id
 AND b.SPEC_VR_ID = a.ORIGINAL_SPEC_VR_ID
 AND b.spec_vr_status = t.status_code AND t.entity_type = 'S'
UNION
SELECT '1' FROM GMD_SAMPLING_EVENTS a , GMD_CUSTOMER_SPEC_VRS b,
gmd_qc_status_tl t
 WHERE
     b.spec_id = p_spec_id
 AND b.SPEC_VR_ID = a.ORIGINAL_SPEC_VR_ID
 AND b.spec_vr_status = t.status_code AND t.entity_type = 'S'
UNION
SELECT '1' FROM GMD_SAMPLING_EVENTS a , GMD_SUPPLIER_SPEC_VRS b,
gmd_qc_status_tl t
 WHERE
     b.spec_id = p_spec_id
 AND b.SPEC_VR_ID = a.ORIGINAL_SPEC_VR_ID
 AND b.spec_vr_status = t.status_code AND t.entity_type = 'S'
UNION
SELECT '1' FROM GMD_SAMPLING_EVENTS a , GMD_MONITORING_SPEC_VRS b,
gmd_qc_status_tl t
 WHERE
     b.spec_id = p_spec_id
 AND b.SPEC_VR_ID = a.ORIGINAL_SPEC_VR_ID
 AND b.spec_vr_status = t.status_code AND t.entity_type = 'S'
UNION
SELECT '1' FROM GMD_SAMPLING_EVENTS a , GMD_STABILITY_SPEC_VRS b,
gmd_qc_status_tl t
 WHERE
     b.spec_id = p_spec_id
 AND b.SPEC_VR_ID = a.ORIGINAL_SPEC_VR_ID
 AND b.spec_vr_status = t.status_code AND t.entity_type = 'S';

/*SELECT '1' FROM GMD_SAMPLING_EVENTS a , GMD_COM_SPEC_VRS_VL b,
gmd_qc_status_tl t
 WHERE
     b.spec_id = p_spec_id
 AND b.SPEC_VR_ID = a.ORIGINAL_SPEC_VR_ID
 AND b.spec_vr_status = t.status_code AND t.entity_type = 'S'; */


 dummy VARCHAR2(1);
BEGIN
    IF p_spec_id IS NULL THEN
        RETURN FALSE;
    END IF;

    OPEN  cr_spec_exist_in_sample;
    FETCH cr_spec_exist_in_sample INTO dummy;
    IF cr_spec_exist_in_sample%FOUND THEN
    	CLOSE cr_spec_exist_in_sample ;
    	RETURN TRUE;
    END IF;
    CLOSE cr_spec_exist_in_sample;
    RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN TRUE;

END spec_used_in_sample ;

FUNCTION VERSION_CONTROL_STATE(p_entity VARCHAR2, p_entity_id NUMBER)
RETURN VARCHAR2 IS
   l_state            VARCHAR2(32) := 'N';
   l_version_enabled  VARCHAR2(1) := 'N';

   TYPE Status_ref_cur IS REF CURSOR;
   Status_cur   Status_ref_cur;

BEGIN

    -- Check for status that allow the version control
    -- e.g normally version control is set beyond
    -- status = 'Approved for gen use'
    -- p_entity = FND_PROFILE.VALUE('GMD_SPEC_VERSION_CONTROL')

    IF (p_entity IS NULL OR p_entity = 'N') THEN
        return 'N';
    END IF;

    OPEN Status_cur FOR
         Select     b.version_enabled
         From       gmd_specifications_b a, gmd_qc_status b
         Where      a.spec_id = p_entity_id
         And        a.spec_status = b.status_code
         and        b.entity_type = 'S';
    FETCH Status_cur INTO l_version_enabled;
    ClOSE Status_cur;

    IF ((p_entity = 'Y') AND (l_version_enabled = 'Y')) THEN
        l_state := 'Y';
    ELSIF ((p_entity = 'O') AND (l_version_enabled = 'Y')) THEN
        l_state := 'O';
    ELSE
        l_state := 'N';
    END IF;

    return l_state;

EXCEPTION WHEN OTHERS THEN
    return 'N';
END VERSION_CONTROL_STATE;

/*======================================================================
--  PROCEDURE :
--   create_specification
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new specification while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    create_specification(P_spec_id, X_spec_id);
--
-- HVERDDIN - Added References to new columns in SPEC HDR and SPEC TESTS
--
-- Saikiran Vankadari 07-Feb-2005  Pvt API calls changed as part of Convergence
--
--===================================================================== */

PROCEDURE create_specification(p_spec_id IN  NUMBER,
			       x_spec_id OUT NOCOPY NUMBER,
			       x_return_status OUT NOCOPY VARCHAR2) IS
  X_spec_vers	NUMBER;
  X_row      	NUMBER := 0;
  l_rowid	ROWID;


  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   gmd_specifications
    WHERE  spec_id = p_spec_id ;
  X_hdr_rec       Cur_get_hdr%ROWTYPE;

  CURSOR Cur_get_dtl IS
    SELECT *
    FROM   gmd_spec_tests
    WHERE  spec_id = p_spec_id;
  TYPE detail_tab IS TABLE OF Cur_get_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
  X_dtl_tbl detail_tab;


-- perf  bug 4924529  sql id 14686617
  CURSOR Cur_spec_id IS
   -- SELECT GMD_QC_SPEC_ID_S.NEXTVAL FROM   FND_DUAL;
   SELECT GMD_QC_SPEC_ID_S.NEXTVAL FROM sys.dual;


  CURSOR Cur_spec_vers IS
    SELECT MAX(spec_vers) + 1
    FROM   gmd_specifications_b
    WHERE  spec_name = X_hdr_rec.spec_name;

    l_progress   VARCHAR2(3);

BEGIN


--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.initialize;    -- clear the message stack.

  l_progress := '010';

  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr INTO X_hdr_rec;
  CLOSE Cur_get_hdr;

  FOR get_rec IN Cur_get_dtl LOOP
    X_row := X_row + 1;
    X_dtl_tbl(X_row) := get_rec;
  END LOOP;


-- this will rollback the update made in the form for the current spec
-- ( for which we are creating a new version)
  ROLLBACK;

  l_progress := '015';

  OPEN Cur_spec_vers;
  FETCH Cur_spec_vers INTO X_spec_vers;
  CLOSE Cur_spec_vers;

  OPEN Cur_spec_id;
  FETCH Cur_spec_id INTO x_spec_id;
  CLOSE Cur_spec_id;

  l_progress := '020';
  /* Insert spec header record */

      GMD_SPECIFICATIONS_PVT.INSERT_ROW(
    X_ROWID => l_rowid,
    X_SPEC_ID => x_spec_id,
    X_SPEC_NAME => X_hdr_rec.SPEC_NAME,
    X_SPEC_VERS => x_spec_vers,
    X_SPEC_TYPE => x_hdr_rec.SPEC_TYPE,
    X_OVERLAY_IND => x_hdr_rec.OVERLAY_IND,
    X_BASE_SPEC_ID => x_hdr_rec.base_spec_id,
    X_INVENTORY_ITEM_ID => X_hdr_rec.INVENTORY_ITEM_ID,
    X_REVISION => X_hdr_rec.REVISION,
    X_GRADE_CODE => X_hdr_rec.GRADE_CODE,
    X_SPEC_STATUS => 100,
    X_OWNER_ORGANIZATION_ID => X_hdr_rec.OWNER_ORGANIZATION_ID,
    X_OWNER_ID => X_hdr_rec.OWNER_ID,
    X_SAMPLE_INV_TRANS_IND => X_hdr_rec.SAMPLE_INV_TRANS_IND,
    X_DELETE_MARK => X_hdr_rec.DELETE_MARK,
    X_TEXT_CODE => X_hdr_rec.TEXT_CODE,
    X_ATTRIBUTE_CATEGORY => X_hdr_rec.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1 => X_hdr_rec.ATTRIBUTE1,
    X_ATTRIBUTE2 => X_hdr_rec.ATTRIBUTE2,
    X_ATTRIBUTE3 => X_hdr_rec.ATTRIBUTE3,
    X_ATTRIBUTE4 => X_hdr_rec.ATTRIBUTE4,
    X_ATTRIBUTE5 => X_hdr_rec.ATTRIBUTE5,
    X_ATTRIBUTE6 => X_hdr_rec.ATTRIBUTE6,
    X_ATTRIBUTE7 => X_hdr_rec.ATTRIBUTE7,
    X_ATTRIBUTE8 => X_hdr_rec.ATTRIBUTE8,
    X_ATTRIBUTE9 => X_hdr_rec.ATTRIBUTE9,
    X_ATTRIBUTE10 => X_hdr_rec.ATTRIBUTE10,
    X_ATTRIBUTE11 => X_hdr_rec.ATTRIBUTE11,
    X_ATTRIBUTE12 => X_hdr_rec.ATTRIBUTE12,
    X_ATTRIBUTE13 => X_hdr_rec.ATTRIBUTE13,
    X_ATTRIBUTE14 => X_hdr_rec.ATTRIBUTE14,
    X_ATTRIBUTE15 => X_hdr_rec.ATTRIBUTE15,
    X_ATTRIBUTE16 => X_hdr_rec.ATTRIBUTE16,
    X_ATTRIBUTE17 => X_hdr_rec.ATTRIBUTE17,
    X_ATTRIBUTE18 => X_hdr_rec.ATTRIBUTE18,
    X_ATTRIBUTE19 => X_hdr_rec.ATTRIBUTE19,
    X_ATTRIBUTE20 => X_hdr_rec.ATTRIBUTE20,
    X_ATTRIBUTE21 => X_hdr_rec.ATTRIBUTE21,
    X_ATTRIBUTE22 => X_hdr_rec.ATTRIBUTE22,
    X_ATTRIBUTE23 => X_hdr_rec.ATTRIBUTE23,
    X_ATTRIBUTE24 => X_hdr_rec.ATTRIBUTE24,
    X_ATTRIBUTE25 => X_hdr_rec.ATTRIBUTE25,
    X_ATTRIBUTE26 => X_hdr_rec.ATTRIBUTE26,
    X_ATTRIBUTE27 => X_hdr_rec.ATTRIBUTE27,
    X_ATTRIBUTE28 => X_hdr_rec.ATTRIBUTE28,
    X_ATTRIBUTE29 => X_hdr_rec.ATTRIBUTE29,
    X_ATTRIBUTE30 => X_hdr_rec.ATTRIBUTE30,
    X_SPEC_DESC => X_hdr_rec.SPEC_DESC,
    X_CREATION_DATE => SYSDATE,
    X_CREATED_BY => FND_GLOBAL.USER_ID,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
    X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);

   l_progress := '030';

  FOR i IN 1..X_dtl_tbl.count LOOP
   GMD_SPEC_TESTS_PVT.INSERT_ROW(
    X_ROWID => l_rowid,
    X_SPEC_ID => x_spec_id,
    X_FROM_BASE_IND => x_dtl_tbl(i).FROM_BASE_IND,
    X_EXCLUDE_IND => x_dtl_tbl(i).EXCLUDE_IND,
    X_MODIFIED_IND => x_dtl_tbl(i).MODIFIED_IND,
    X_TEST_ID => X_dtl_tbl(i).TEST_ID,
    X_ATTRIBUTE1 => X_dtl_tbl(i).ATTRIBUTE1,
    X_ATTRIBUTE2 => X_dtl_tbl(i).ATTRIBUTE2,
    X_MIN_VALUE_CHAR => X_dtl_tbl(i).MIN_VALUE_CHAR,
    X_TEST_METHOD_ID => X_dtl_tbl(i).TEST_METHOD_ID,
    X_SEQ => X_dtl_tbl(i).SEQ,
    X_TEST_QTY => X_dtl_tbl(i).TEST_QTY,
    X_TEST_QTY_UOM => X_dtl_tbl(i).TEST_QTY_UOM,
    X_MIN_VALUE_NUM => X_dtl_tbl(i).MIN_VALUE_NUM,
    X_TARGET_VALUE_NUM => X_dtl_tbl(i).TARGET_VALUE_NUM,
    X_MAX_VALUE_NUM => X_dtl_tbl(i).MAX_VALUE_NUM,
    X_ATTRIBUTE5 => X_dtl_tbl(i).ATTRIBUTE5,
    X_ATTRIBUTE6 => X_dtl_tbl(i).ATTRIBUTE6,
    X_ATTRIBUTE7 => X_dtl_tbl(i).ATTRIBUTE7,
    X_ATTRIBUTE8 => X_dtl_tbl(i).ATTRIBUTE8,
    X_ATTRIBUTE9 => X_dtl_tbl(i).ATTRIBUTE9,
    X_ATTRIBUTE10 => X_dtl_tbl(i).ATTRIBUTE10,
    X_ATTRIBUTE11 => X_dtl_tbl(i).ATTRIBUTE11,
    X_ATTRIBUTE12 => X_dtl_tbl(i).ATTRIBUTE12,
    X_ATTRIBUTE13 => X_dtl_tbl(i).ATTRIBUTE13,
    X_ATTRIBUTE14 => X_dtl_tbl(i).ATTRIBUTE14,
    X_ATTRIBUTE15 => X_dtl_tbl(i).ATTRIBUTE15,
    X_ATTRIBUTE16 => X_dtl_tbl(i).ATTRIBUTE16,
    X_ATTRIBUTE17 => X_dtl_tbl(i).ATTRIBUTE17,
    X_ATTRIBUTE18 => X_dtl_tbl(i).ATTRIBUTE18,
    X_USE_TO_CONTROL_STEP => X_dtl_tbl(i).USE_TO_CONTROL_STEP,
    X_PRINT_SPEC_IND => X_dtl_tbl(i).PRINT_SPEC_IND,
    X_PRINT_RESULT_IND => X_dtl_tbl(i).PRINT_RESULT_IND,
    X_TEXT_CODE => X_dtl_tbl(i).TEXT_CODE,
    X_ATTRIBUTE_CATEGORY => X_dtl_tbl(i).ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE3 => X_dtl_tbl(i).ATTRIBUTE3,
    X_RETEST_LOT_EXPIRY_IND => X_dtl_tbl(i).RETEST_LOT_EXPIRY_IND,
    X_ATTRIBUTE19 => X_dtl_tbl(i).ATTRIBUTE19,
    X_ATTRIBUTE20 => X_dtl_tbl(i).ATTRIBUTE20,
    X_MAX_VALUE_CHAR => X_dtl_tbl(i).MAX_VALUE_CHAR,
    X_TEST_REPLICATE => X_dtl_tbl(i).TEST_REPLICATE,
    X_CHECK_RESULT_INTERVAL => X_dtl_tbl(i).CHECK_RESULT_INTERVAL,
    X_OUT_OF_SPEC_ACTION => X_dtl_tbl(i).OUT_OF_SPEC_ACTION,
    X_EXP_ERROR_TYPE => X_dtl_tbl(i).EXP_ERROR_TYPE,
    X_BELOW_SPEC_MIN => X_dtl_tbl(i).BELOW_SPEC_MIN,
    X_ABOVE_SPEC_MIN => X_dtl_tbl(i).ABOVE_SPEC_MIN,
    X_BELOW_SPEC_MAX => X_dtl_tbl(i).BELOW_SPEC_MAX,
    X_ABOVE_SPEC_MAX => X_dtl_tbl(i).ABOVE_SPEC_MAX,
    X_BELOW_MIN_ACTION_CODE => X_dtl_tbl(i).BELOW_MIN_ACTION_CODE,
    X_ABOVE_MIN_ACTION_CODE => X_dtl_tbl(i).ABOVE_MIN_ACTION_CODE,
    X_BELOW_MAX_ACTION_CODE => X_dtl_tbl(i).BELOW_MAX_ACTION_CODE,
    X_ABOVE_MAX_ACTION_CODE => X_dtl_tbl(i).ABOVE_MAX_ACTION_CODE,
    X_OPTIONAL_IND => X_dtl_tbl(i).OPTIONAL_IND,
    X_DISPLAY_PRECISION => X_dtl_tbl(i).DISPLAY_PRECISION,
    X_REPORT_PRECISION => X_dtl_tbl(i).REPORT_PRECISION,
    X_TEST_PRIORITY => X_dtl_tbl(i).TEST_PRIORITY,
    X_PRINT_ON_COA_IND => X_dtl_tbl(i).PRINT_ON_COA_IND,
    X_TARGET_VALUE_CHAR => X_dtl_tbl(i).TARGET_VALUE_CHAR,
    X_ATTRIBUTE4 => X_dtl_tbl(i).ATTRIBUTE4,
    X_ATTRIBUTE21 => X_dtl_tbl(i).ATTRIBUTE21,
    X_ATTRIBUTE22 => X_dtl_tbl(i).ATTRIBUTE22,
    X_ATTRIBUTE23 => X_dtl_tbl(i).ATTRIBUTE23,
    X_ATTRIBUTE24 => X_dtl_tbl(i).ATTRIBUTE24,
    X_ATTRIBUTE25 => X_dtl_tbl(i).ATTRIBUTE25,
    X_ATTRIBUTE26 => X_dtl_tbl(i).ATTRIBUTE26,
    X_ATTRIBUTE27 => X_dtl_tbl(i).ATTRIBUTE27,
    X_ATTRIBUTE28 => X_dtl_tbl(i).ATTRIBUTE28,
    X_ATTRIBUTE29 => X_dtl_tbl(i).ATTRIBUTE29,
    X_ATTRIBUTE30 => X_dtl_tbl(i).ATTRIBUTE30,
    X_TEST_DISPLAY => X_dtl_tbl(i).TEST_DISPLAY,
    X_CREATION_DATE => SYSDATE,
    X_CREATED_BY => FND_GLOBAL.USER_ID,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
    X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID,
    X_VIABILITY_DURATION => X_dtl_tbl(i).VIABILITY_DURATION,
    X_TEST_EXPIRATION_DAYS => X_dtl_tbl(i).DAYS,
    X_TEST_EXPIRATION_HOURS => X_dtl_tbl(i).HOURS,
    X_TEST_EXPIRATION_MINUTES => X_dtl_tbl(i).MINUTES,
    X_TEST_EXPIRATION_SECONDS => X_dtl_tbl(i).SECONDS,
    X_CALC_UOM_CONV_IND       => X_dtl_tbl(i).CALC_UOM_CONV_IND,
    X_TO_QTY_UOM                  => X_dtl_tbl(i).TO_QTY_UOM
);

  END LOOP ;

l_progress := '040';

EXCEPTION
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
   FND_MESSAGE.Set_Token('PACKAGE','GMD_SPEC_GRP.CREATE_SPECIFICATION');
   FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
   FND_MESSAGE.Set_Token('POSITION',l_progress );
   FND_MSG_PUB.ADD;
END create_specification ;





--Start of comments
--+========================================================================+
--| API Name    : change_status                                            |
--| TYPE        : Group                                                    |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	05-Oct-2002	Created.                           |
--|    Mahesh Chandak   16-apr-2003     Modified to support stability study|
--|    Chetan Nagar     06-May-2003     B2943737 SQL Bind Variable Project.|
--+========================================================================+
-- End of comments

PROCEDURE change_status
(
  p_table_name    IN  VARCHAR2
, p_id            IN  NUMBER
, p_source_status IN  NUMBER
, p_target_status IN  NUMBER
, p_mode          IN  VARCHAR2
, p_entity_type   IN  VARCHAR2 DEFAULT 'S'
, x_return_status OUT NOCOPY VARCHAR2
, x_message       OUT NOCOPY VARCHAR2
) IS

  -- Cursors
  CURSOR c_all_status (p_mode VARCHAR2,
                       p_current_status NUMBER,
                       p_target_status NUMBER) IS
  SELECT decode(p_mode, 'S', current_status,
                        'P', pending_status,
                        'R', rework_status,
                        'A', target_status)
  FROM   gmd_qc_status_next
  WHERE  current_status = p_current_status
  AND    target_status = p_target_status
  AND    entity_type = p_entity_type
  ;

  -- Local Variables
  l_status              NUMBER;
  l_sql_stmt            VARCHAR2(1000);

BEGIN


  IF (l_debug = 'Y') THEN
    NULL;
--Commented because of GSCC violation
 /*     dbms_output.put_line('Entering Procedure CHANGE_STATUS');
     dbms_output.put_line('Input Parameters.');
     dbms_output.put_line('p_table_name: '|| p_table_name ||
                     'p_id: '|| p_id ||
                     'p_source_status: '|| p_source_status ||
                     'p_target_status: '|| p_target_status ||
                     'p_mode: '|| p_mode); */
  END IF;

  -- Set Success status
  x_return_status := 'S';

  -- Validate Input Parameters for NULLs
  IF (p_table_name IS NULL OR p_id IS NULL OR p_source_status IS NULL OR
      p_target_status IS NULL OR p_mode IS NULL) THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_PARAMETERS');
    x_message := FND_MESSAGE.GET;
    RETURN;
  END IF;


  IF NOT (p_mode in ('P', 'R', 'A', 'S')) THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_PARAMETERS');
    x_message := FND_MESSAGE.GET;
    RETURN;
  END IF;

  IF (l_debug = 'Y') THEN
    NULL;
--Commented because of GSCC violation
 /*      dbms_output.put_line('Input parameters are valid.'); */
  END IF;


  -- Get the status to be updated
  OPEN c_all_status(p_mode, p_source_status, p_target_status);
  FETCH c_all_status INTO l_status;
  IF c_all_status%NOTFOUND THEN
    CLOSE c_all_status;
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_STATUS_NOT_FOUND');
    x_message := FND_MESSAGE.GET;
    RETURN;
  END IF;
  CLOSE c_all_status;

  IF (l_debug = 'Y') THEN
    NULL;
--Commented because of GSCC violation
 /*      dbms_output.put_line('Set the status to: '|| l_status); */
  END IF;

  -- Now construct the SQL Stmt.
  -- B2943737 SQL Bind Variable Project.
  IF (upper(p_table_name) = 'GMD_SPECIFICATIONS_B' ) THEN
    l_sql_stmt := 'UPDATE GMD_SPECIFICATIONS_B' ||
                  ' SET    spec_status = :l_status' ||
                  ' WHERE  spec_id = :p_id';
  -- added by mahesh to support stability study
  ELSIF (upper(p_table_name) = 'GMD_STABILITY_STUDIES_B' ) THEN
    l_sql_stmt := 'UPDATE GMD_STABILITY_STUDIES_B' ||
                  ' SET    status = :l_status' ||
                  ' WHERE  ss_id = :p_id';
  ELSE
    l_sql_stmt := 'UPDATE ' || p_table_name ||
                  ' SET    spec_vr_status = :l_status' ||
                  ' WHERE  spec_vr_id = :p_id';
  END IF;

  IF (l_debug = 'Y') THEN
    NULL;
--Commented because of GSCC violation
 /*      dbms_output.put_line('SQL Statement: ' || l_sql_stmt); */
  END IF;


  EXECUTE IMMEDIATE l_sql_stmt USING l_status, p_id;


  IF (l_debug = 'Y') THEN
    NULL;
--Commented because of GSCC violation
 /*  dbms_output.put_line('SQL Statement executed.');
     dbms_output.put_line('Leaving Procedure CHANGE_STATUS'); */
  END IF;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('GMD', 'GMD_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PACKAGE','GMD_SPEC_GRP.change_status');
    FND_MESSAGE.SET_TOKEN('ERROR', SUBSTR(SQLERRM,1,100));
    x_message := FND_MESSAGE.GET;
    x_return_status := 'E';
    RETURN;

END change_status;

--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_Who                                                              |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve WHO information                                     |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve the who field information         |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_user_name   IN  VARCHAR2     - User name                           |
--|    x_user_id     OUT NUMBER       - user id of the user                 |
--|                                                                         |
--| HISTORY                                                                 |
--|  Saikiran Vankadari   02-May-2005 Created as part of Convergence changes
--+=========================================================================+
PROCEDURE Get_Who
( p_user_name    IN  fnd_user.user_name%TYPE
, x_user_id      OUT NOCOPY fnd_user.user_id%TYPE
)
IS
CURSOR fnd_user_c1 IS
SELECT
  user_id
FROM
  fnd_user
WHERE
user_name = p_user_name;

BEGIN

  OPEN fnd_user_c1;

  FETCH fnd_user_c1 INTO x_user_id;

  -- TKW B2476518 7/23/2002
  -- If user not found, return -1 instead of 0.
  IF (fnd_user_c1%NOTFOUND)
  THEN
    x_user_id := -1;
  END IF;

  CLOSE fnd_user_c1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_Who;

END GMD_SPEC_GRP;

/
