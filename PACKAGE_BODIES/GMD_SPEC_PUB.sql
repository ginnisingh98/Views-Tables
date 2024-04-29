--------------------------------------------------------
--  DDL for Package Body GMD_SPEC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPEC_PUB" AS
/*  $Header: GMDPSPCB.pls 120.1 2006/05/31 13:43:08 ragsriva noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | File Name          : GMDPSPCB.pls                                       |
 | Package Name       : GMD_Spec_PUB                                       |
 | Type               : PUBLIC                                             |
 |                                                                         |
 | Contents CREATE_SPEC                                                    |
 |          DELETE_SPEC                                                    |
 |          DELETE_SPEC_TESTS                                              |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public definitions for processing             |
 |     QC Specifications                                                   |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |                                                                         |
 |     HVerddin B2711643: Added call to set user_context                   |
 |                                                                         |
 |                                                                         |
 +=========================================================================+
  API Name  : GMD_Spec_PUB
  Type      : Public
  Function  : This package contains public procedures used to process
              specifications.
  Pre-reqs  : N/A
  Parameters: Per function


  Current Vers  : 2.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
  END of Notes */


/*  Global variables   */

G_PKG_NAME               CONSTANT  VARCHAR2(30):='GMD_SPEC_PUB';

/*
 +=========================================================================+
 | Name               : CREATE_SPEC                                        |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a single spec definition plus a table of spec_tests         |
 |     definitions.                                                        |
 |     The owning spec data must always be supplied.  If a spec_id is      |
 |     supplied, it will be assumed that the corresponding row already     |
 |     exists.  Where spec_id is NULL, an attempt will be made to insert   |
 |     the row.                                                            |
 |     An attempt will be made to validate and then insert each of the     |
 |     spec_tests supplied which must belong the the supplied owning spec. |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE CREATE_SPEC
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  VARCHAR2
, p_spec                 IN  GMD_SPECIFICATIONS%ROWTYPE
, p_spec_tests_tbl       IN  GMD_SPEC_PUB.spec_tests_tbl
, p_user_name            IN  VARCHAR2
, x_spec                 OUT NOCOPY GMD_SPECIFICATIONS%ROWTYPE
, x_spec_tests_tbl       OUT NOCOPY GMD_SPEC_PUB.spec_tests_tbl
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name             CONSTANT VARCHAR2 (30) := 'CREATE_SPEC';
  l_api_version          CONSTANT NUMBER        := 2.0;
  l_msg_count            NUMBER  :=0;
  l_msg_data             VARCHAR2(2000);
  l_return_status        VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec                 GMD_SPECIFICATIONS%ROWTYPE;
  l_spec_out             GMD_SPECIFICATIONS%ROWTYPE;
  l_spec_tests           GMD_SPEC_TESTS%ROWTYPE;
  l_spec_tests_out       GMD_SPEC_TESTS%ROWTYPE;
  l_spec_tests_tbl       GMD_SPEC_PUB.spec_tests_tbl;
  l_spec_id              NUMBER;
  l_rowid                ROWID;
  l_user_id              NUMBER(15);
  pp_spec_tests_tbl      GMD_SPEC_PUB.spec_tests_tbl ;

  CURSOR Cur_get_dtl_base (p_basespec_id NUMBER) IS
    SELECT *
    FROM   gmd_spec_tests
    WHERE  spec_id = p_basespec_id;
  TYPE detail_tab_base IS TABLE OF Cur_get_dtl_base%ROWTYPE INDEX BY BINARY_INTEGER;
  X_dtl_tbl_base detail_tab_base;

  X_row      	NUMBER := 1;
  Max_sequence  NUMBER := 0;

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Create_Spec;

  --  Standard call to check for call compatibility
  --  =============================================
  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate User Name Parameter
  -- ============================
  GMD_SPEC_GRP.Get_Who ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;

  ELSE
    -- Added below for BUG 2711643. Hverddin
    GMD_API_PUB.SET_USER_CONTEXT(p_user_id       => l_user_id,
                                 x_return_status => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  -- Create scenario -- may be creating
  --                    a) header plus childen (standalone header not allowed)
  --                    b) additional children for existing header
  -- =========================================================================
  l_spec := p_spec;

  -- Bug# 5251222
  -- Added code to nullify the following fields for monitoring specs
  IF p_spec.spec_type = 'M' THEN
     l_spec.inventory_item_id :=  NULL;
     l_spec.revision := NULL;
     l_spec.grade_code := NULL;
  END IF;

  -- If a spec_name is supplied  we must be creating a new spec
  -- ===========================================================
  IF l_spec.spec_name is NOT NULL
  THEN
    -- Ensure spec_id is null
    -- ======================
    l_spec.spec_id := NULL;

    -- Need to create the header (gmd_specifications) so validate the spec data
    -- ========================================================================
    GMD_SPEC_GRP.Validate_Spec_Header  (
           p_spec_header      => l_spec
         , p_called_from      => 'API'
         , p_operation        => 'INSERT'
         , x_return_status    => l_return_status
         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Set the  Who column definitions ahead of creating SPEC header
    -- =============================================================
    l_spec.created_by      := l_user_id;
    l_spec.last_updated_by := l_user_id;

    -- Insert SPEC
    -- ===========
    IF NOT GMD_Specifications_PVT.INSERT_ROW(p_spec => l_spec)
    THEN
      GMD_API_PUB.Log_Message('GMD_FAILED_TO_INSERT_ROW',
                              'l_table_name', 'GMD_SPECIFICATIONS',
                              'l_column_name', 'SPEC_ID',
                              'l_key_value', l_spec.spec_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- All test specs must conform to newly created spec_id
    -- ====================================================
    l_spec_id := l_spec.spec_id;
  ELSE
  -- SPEC create NOT required; we are adding spec_tests to an exisiting spec
  -- All spec_id's must relate to the same spec and therefore be the same
  -- =======================================================================
    l_spec_id := p_spec_tests_tbl(1).spec_id;
    IF l_spec_id is NULL
    THEN
      GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
      GMD_API_PUB.Log_Message('GMD_SPEC_TEST_REQUIRES_SPEC_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;


  -- ===================================================================================
  -- == Check if there is a Base Spec defined. If so, need to add
  -- == all those spec tests (Bug 3401368)
  -- ====================================================================================
  if (p_spec.base_spec_id is not NULL) then
	  FOR get_rec IN Cur_get_dtl_base(p_spec.base_spec_id) LOOP
 	    get_rec.spec_id := l_spec_id ;
	    get_rec.from_base_ind := 'Y' ;
	    get_rec.exclude_ind := NULL ;
	    get_rec.modified_ind := NULL ;
	    pp_spec_tests_tbl(X_row) := get_rec;

            if (max_sequence <  pp_spec_tests_tbl(x_row).seq) then
	    	    Max_sequence := pp_spec_tests_tbl(x_row).seq ;
	    end if ;
	    X_row := X_row + 1;
	  END LOOP;
  end if ;


  -- Need to add all the spec tests
  -- Make sure sequence does not duplicate
  FOR i in 1..p_spec_tests_tbl.COUNT LOOP
	    pp_spec_tests_tbl(X_row) := p_spec_tests_tbl(i);
	    pp_spec_tests_tbl(X_row).spec_id := l_spec_id ;
	    pp_spec_tests_tbl(X_row).from_base_ind := NULL ;
	    pp_spec_tests_tbl(X_row).exclude_ind := NULL ;
	    pp_spec_tests_tbl(X_row).modified_ind := NULL ;

	    /*Bug 3465014*/
	    pp_spec_tests_tbl(X_row).seq := p_spec_tests_tbl(i).seq +  Max_sequence ;

	    X_row := X_row + 1;
  END LOOP;


  -- Loop through the spec tests validating and creating
  -- ===================================================
  FOR i in 1..pp_spec_tests_tbl.COUNT LOOP

    l_spec_tests := pp_spec_tests_tbl(i);

    -- Validate that the spec_id's are all consistent.  Must all belong to the same header
    -- ===================================================================================
    IF ( NVL(l_spec_tests.spec_id, l_spec.spec_id ) <> l_spec_id)
    THEN
      GMD_API_PUB.Log_Message('GMD_INCONSISTENT_SPEC_ID',
                              'SPEC_ID', l_spec_tests.spec_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Ensure SPEC_ID is assigned
    -- ==========================
    l_spec_tests.spec_id := l_spec_id;

    -- Validate SPEC_TEST
    -- ==================
    GMD_SPEC_GRP.Validate_Spec_Test(
                        p_spec_test        => l_spec_tests
                      , p_called_from      => 'API'
                      , p_operation        => 'INSERT'
                      , x_spec_test        => l_spec_tests_out
                      , x_return_status    => l_return_status
                      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Message detailing cause of validation failure is already on
      -- the stack.  But ensure the precise record is identified
      -- ==========================================================
      GMD_API_PUB.Log_Message('GMD_API_RECORD_IDENTIFIER',
                              'l_table_name', 'GMD_SPEC_TESTS',
                              'l_column_name', 'TEST_ID',
                              'l_key_value', l_spec_tests.test_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_spec_tests := l_spec_tests_out;

    -- Set Who columns ahead of Insert Row
    -- ===================================
    l_spec_tests.created_by      := l_user_id;
    l_spec_tests.last_updated_by := l_user_id;

    IF NOT GMD_SPEC_TESTS_PVT.INSERT_ROW(p_spec_tests => l_spec_tests)
    THEN
      GMD_API_PUB.Log_Message('GMD_FAILED_TO_INSERT_ROW',
                              'l_table_name', 'GMD_SPEC_TESTS',
                              'l_column_name', 'TEST_ID',
                              'l_key_value', l_spec_tests.test_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update Return Parameter Tbl
    -- ===========================
    l_spec_tests_tbl(i) := l_spec_tests;

  END LOOP;


  -- Post insert validation:
  -- a) a spec must have at least one spec test
  -- b) expression based tests must have associated reference tests
  -- ==============================================================
  GMD_SPEC_GRP.Validate_After_Insert_All(
                        p_spec_id          => l_spec_id
                      , x_return_status    => l_return_status
                      );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    -- Message detailing cause of validation failure is already on
    -- the stack.  But ensure the precise record is identified
    -- ==========================================================
    GMD_API_PUB.Log_Message('GMD_API_RECORD_IDENTIFIER',
                              'l_table_name', 'GMD_SPECIFICATIONS',
                              'l_column_name', 'SPEC_NAME',
                              'l_key_value', l_spec.spec_name);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Standard Check of p_commit.
  -- ==========================
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;
  x_spec               := l_spec;
  x_spec_tests_tbl     := l_spec_tests_tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Spec;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Spec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                 );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Create_Spec;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_SPEC;

/*
 +=========================================================================+
 | Name               : DELETE_SPEC                                        |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a single specification definition.  Validates to ensure     |
 |     that there is a corresponding row which is not already              |
 |     delete marked.  Where validation is successful, a logical delete    |
 |     is performed setting delete_mark=1                                  |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |     02-MAY-2005  saikiran vankadari    As part of Convergence changes,  |
 |                    call to GMA_GLOBAL_GRP.get_who() is replaced with    |
 |                          GMD_SPEC_GRP.get_who() procedure               |
 |                                                                         |
 +=========================================================================+
*/
PROCEDURE DELETE_SPEC
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  VARCHAR2
, p_spec                 IN  GMD_SPECIFICATIONS%ROWTYPE
, p_user_name            IN  VARCHAR2
, x_deleted_rows         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'DELETE_SPEC';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_msg_count          NUMBER  :=0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec               GMD_SPECIFICATIONS%ROWTYPE;
  l_deleted_rows       NUMBER :=0;

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Delete_Spec;

  -- Standard call to check for call compatibility.
  -- ==============================================
  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate user_name
  -- ==================
  GMD_SPEC_GRP.Get_Who ( p_user_name => p_user_name
                          ,x_user_id   => l_spec.last_updated_by);

  IF NVL(l_spec.last_updated_by, -1) < 0
  THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Added below for BUG 2711643. Hverddin
    GMD_API_PUB.SET_USER_CONTEXT(p_user_id       => l_spec.last_updated_by,
                                 x_return_status => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  -- Validate to ensure spec is in a suitable state to delete mark
  -- ==============================================================
  GMD_SPEC_GRP.Validate_Before_Delete( p_spec_id          => p_spec.spec_id
                                     , x_return_status    => l_return_status
                                     , x_message_data     => l_msg_data
                                     );
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    -- Diagnostic messages already on stack from group level
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Lock the row ahead of delete marking
  -- ====================================
  IF  NOT GMD_Specifications_PVT.Lock_Row(p_spec.spec_id)
  THEN
    -- Report Failure to obtain locks
    -- ==============================
    GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                            'l_table_name', 'GMD_SPECIFICATIONS',
                            'l_column_name', 'SPEC_ID',
                            'l_key_value', p_spec.spec_id);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF NOT GMD_Specifications_PVT.Mark_for_Delete ( p_spec_id          => p_spec.spec_id
                                                 , p_last_update_date => sysdate
                                                 , p_last_updated_by  => l_spec.last_updated_by
                                                 )
  THEN
    GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                            'l_table_name', 'GMD_SPECIFICATIONS',
                            'l_column_name', 'SPEC_ID',
                            'l_key_value', p_spec.spec_id);
  ELSE -- Report one row successfully delete marked
    x_deleted_rows       := 1;
  END IF;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Spec;
      x_deleted_rows       := 0;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Spec;
      x_deleted_rows       := 0;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_deleted_rows       := 0;
      ROLLBACK TO Delete_Spec;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_SPEC;

/*
 +=========================================================================+
 | Name               : DELETE_SPEC_TESTS                                  |
 | Type               : PUBLIC                                             |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     Accepts a table of spec_tests definitions.                          |
 |     All the spec_tests must relate to a single specification (spec_id)  |
       For each spec_test supplied, validates to ensure that the           |
 |     designated row exists and then physically deletes it.               |
 |     In the case of any failure a rollback is instigated.                |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  K.Y.Hunt                                               |
 |                                                                         |
 +=========================================================================+
*/
PROCEDURE DELETE_SPEC_TESTS
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  VARCHAR2
, p_spec_tests_tbl       IN  GMD_SPEC_PUB.spec_tests_tbl
, x_deleted_rows         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'DELETE_SPEC_TESTS';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_msg_count          NUMBER  :=0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_spec_id            NUMBER  :=0;
  l_spec_tests         GMD_SPEC_TESTS%ROWTYPE;
  l_spec_tests_out     GMD_SPEC_TESTS%ROWTYPE;
  l_deleted_rows       NUMBER :=0;

BEGIN


  -- Standard Start OF API savepoint
  -- ===============================
  SAVEPOINT Delete_Spec_Tests;

  -- Standard call to check for call compatibility.
  -- ==============================================
  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.
  -- ======================================================
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return Parameters
  -- ================================
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Process each of the spec tests
  -- ===============================
  FOR i in 1..p_spec_tests_tbl.COUNT LOOP
    l_spec_tests := p_spec_tests_tbl(i);
    -- Ensure the owning spec_id is supplied
    -- =====================================
    IF ( l_spec_tests.spec_id IS NULL )
    THEN
    -- raise validation error
      GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- First loop only ,validate the owning SPEC
    -- ==========================================
    IF i=1
    THEN
      -- Validate to ensure spec is a)not delete marked b)has a status which permits updates
      -- ===================================================================================
      GMD_SPEC_GRP.Validate_Before_Delete(  p_spec_id          => l_spec_tests.spec_id
                                          , x_return_status    => l_return_status
                                          , x_message_data     => l_msg_data
                                          );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        -- Diagnostic messages already on stack from group level
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- All spec_tests processed, must relate to this spec_id
      -- =====================================================
      l_spec_id := l_spec_tests.spec_id;

      -- Lock the SPEC ahead of manipulating SPEC_TESTS
      -- ===============================================
      IF  NOT GMD_Specifications_PVT.Lock_Row(l_spec_tests.spec_id)
      THEN
        -- Report Failure to obtain locks
        -- ==============================
        GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_SPECIFICATIONS',
                              'l_column_name', 'SPEC_ID',
                              'l_key_value', l_spec_tests.spec_id);
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- All spec_tests must relate to the same owning spec
    -- ==================================================
    ELSIF l_spec_id <> l_spec_tests.spec_id
    THEN
      GMD_API_PUB.Log_Message('GMD_SUPPLY_CONSISTENT_SPEC_IDS',
                              'SPEC_ID1', l_spec_id,
                              'SPEC_ID2', l_spec_tests.spec_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;  -- end of spec validation

    -- Fetch to ensure spec_test exists
    -- ================================
    -- KYH 05/NOV/02 use separate params for fetch_row input and output
    IF NOT GMD_SPEC_TESTS_PVT.fetch_row ( l_spec_tests,l_spec_tests_out)
    THEN
      GMD_API_PUB.Log_Message('GMD_FAILED_TO_FETCH_ROW',
                              'l_table_name', 'GMD_SPEC_TESTS',
                              'l_column_name', 'TEST_ID',
                              'l_key_value', l_spec_tests.test_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_spec_tests := l_spec_tests_out;

    -- Lock the spec_test ahead of deleting
    -- ====================================
    IF  NOT GMD_SPEC_TESTS_PVT.Lock_Row(l_spec_tests.spec_id,l_spec_tests.test_id)
    THEN
      -- Report Failure to obtain locks
      -- ==============================
      GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_SPEC_TESTS',
                              'l_column_name', 'TEST_ID',
                              'l_key_value', l_spec_tests.test_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT GMD_SPEC_TESTS_PVT.Delete_Row (  p_spec_id          => l_spec_tests.spec_id
                                          , p_test_id          => l_spec_tests.test_id
                                          )
    THEN
      GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                              'l_table_name', 'GMD_SPEC_TESTS',
                              'l_column_name', 'TEST_ID',
                              'l_key_value', l_spec_tests.test_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Ensure that at least one test remains under the specification
    -- =============================================================
    GMD_SPEC_GRP.Validate_After_Delete_Test ( p_spec_id       => l_spec_tests.spec_id
                                            , x_return_status => l_return_status
                                            );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Diagnostic messages already on stack from group level
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  x_deleted_rows       := i;

  END LOOP;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status      := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Spec_Tests;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_deleted_rows  := 0;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Spec_Tests;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_deleted_rows  := 0;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_deleted_rows  := 0;
      ROLLBACK TO Delete_Spec_Tests;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_SPEC_TESTS;

END GMD_SPEC_PUB;

/
