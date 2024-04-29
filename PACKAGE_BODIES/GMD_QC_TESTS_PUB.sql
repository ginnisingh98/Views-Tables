--------------------------------------------------------
--  DDL for Package Body GMD_QC_TESTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_TESTS_PUB" AS
/*  $Header: GMDPTSTB.pls 115.13 2004/05/05 09:51:17 rboddu noship $
 *****************************************************************
 *                                                               *
 * Package  GMD_QC_TESTS_PUB                                     *
 *                                                               *
 * Contents CREATE_TESTS                                         *
 *          DELETE_TEST_HEADERS                                  *
 *          DELETE_TEST_VALUES                                   *
 *          DELETE_CUSTOMER_TESTS                                *
 *                                                               *
 * Use      This is the public layer for the QC TESTS API        *
 *                                                               *
 * History                                                       *
 *         Written by H Verdding, OPM Development (EMEA)         *
 *                                                               *
 *         HVerddin B2711643: Added call to set user_context     *
 *                                                               *
 *                                                               *
 *****************************************************************
*/

/*  Global variables   */

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GMD_QC_TESTS_PUB';

G_PROCESS_TESTS      BOOLEAN := FALSE;
G_PROCESS_VALUES     BOOLEAN := FALSE;
G_PROCESS_CUSTOMERS  BOOLEAN := FALSE;

/*  Private Routines */

PROCEDURE VALIDATE_INPUT_PARAMS
(
 p_qc_cust_tests_tbl   IN  GMD_QC_TESTS_PUB.qc_cust_tests_tbl,
 p_qc_test_values_tbl   IN  GMD_QC_TESTS_PUB.qc_test_values_tbl

)
IS

BEGIN

  IF p_qc_test_values_tbl.COUNT <> 0 THEN
    G_PROCESS_VALUES  := TRUE;
  ELSE   /* BUG 3506233 - Added following ELSE condition */
    G_PROCESS_VALUES  := FALSE;
  END IF;

  IF p_qc_cust_tests_tbl.COUNT <> 0  THEN
    G_PROCESS_CUSTOMERS := TRUE;
  ELSE   /* BUG 3506233 - Added following ELSE condition */
    G_PROCESS_CUSTOMERS := FALSE;
  END IF;



END VALIDATE_INPUT_PARAMS;



PROCEDURE CREATE_TESTS
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  NUMBER
, p_qc_tests_rec         IN  GMD_QC_TESTS%ROWTYPE
, p_qc_test_values_tbl   IN  GMD_QC_TESTS_PUB.qc_test_values_tbl
, p_qc_cust_tests_tbl    IN  GMD_QC_TESTS_PUB.qc_cust_tests_tbl
, p_user_name            IN  VARCHAR2
, x_qc_tests_rec         OUT NOCOPY  GMD_QC_TESTS%ROWTYPE
, x_qc_test_values_tbl   OUT NOCOPY  GMD_QC_TESTS_PUB.qc_test_values_tbl
, x_qc_cust_tests_tbl    OUT NOCOPY  GMD_QC_TESTS_PUB.qc_cust_tests_tbl
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY  NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
l_api_name              CONSTANT VARCHAR2 (30) := 'CREATE_TESTS';
l_api_version           CONSTANT NUMBER        := 1.0;
l_msg_count             NUMBER  :=0;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
l_qc_tests_rec          GMD_QC_TESTS%ROWTYPE;
l_qc_tests_rec_in       GMD_QC_TESTS%ROWTYPE;
l_qc_cust_tests_rec     GMD_CUSTOMER_TESTS%ROWTYPE;
l_qc_test_values_rec_in GMD_QC_TEST_VALUES%ROWTYPE;
l_qc_test_values_rec    GMD_QC_TEST_VALUES%ROWTYPE;
l_qc_test_values_tbl    GMD_QC_TESTS_PUB.qc_test_values_tbl;
l_qc_cust_tests_tbl     GMD_QC_TESTS_PUB.qc_cust_tests_tbl;
l_rowid                 ROWID;
l_user_id               NUMBER(15);

BEGIN


  -- Standard Start OF API savepoint

  SAVEPOINT Create_Tests;

  /*  Standard call to check for call compatibility.  */

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_int_msg_list is set TRUE.   */
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --   Initialize API return Parameters

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate User Name Parameter

  GMA_GLOBAL_GRP.Get_Who ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME','l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Added below for BUG 2711643. Hverddin
    GMD_API_PUB.SET_USER_CONTEXT(p_user_id       => l_user_id,
                                 x_return_status => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  IF ( p_qc_tests_rec.test_code IS NOT NULL ) THEN
       G_PROCESS_TESTS := TRUE;
  END IF;

  /*  Try And detemine Exactly Attributes Required For Creation */

   VALIDATE_INPUT_PARAMS
   (
     p_qc_cust_tests_tbl    => p_qc_cust_tests_tbl,
     p_qc_test_values_tbl   => p_qc_test_values_tbl
   );


  IF ( NOT G_PROCESS_TESTS ) AND ( NOT G_PROCESS_VALUES )
     AND ( NOT G_PROCESS_CUSTOMERS)  THEN

    -- Raise Error No Validate Parameters Defined
    GMD_API_PUB.LOG_MESSAGE('GMD_API_NO_ACTION_REQUIRED');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Process Test Record If Present

  IF G_PROCESS_TESTS THEN

     -- test record is populated - Now Process This Record

     l_qc_tests_rec_in := p_qc_tests_rec;

    -- Adding the following validation to check if the test group order passed is unique or not.
    -- Ravi Boddu Test Groups Enhancement Bug no: 3447472
    IF (p_qc_tests_rec.test_class IS NOT NULL and p_qc_tests_rec.test_group_order IS NOT NULL) THEN
       IF gmd_qc_tests_grp.test_group_order_exist(
           p_init_msg_list,
           p_qc_tests_rec.test_class,
           p_qc_tests_rec.test_group_order) THEN
          GMD_API_PUB.log_message('SY_WFDUPLICATE');
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     GMD_QC_TESTS_GRP.VALIDATE_BEFORE_INSERT(
           p_gmd_qc_tests_rec => l_qc_tests_rec_in,
           x_gmd_qc_tests_rec => l_qc_tests_rec,
           x_return_status    => l_return_status,
           x_message_data     => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Insert Test Record Into Table.
      -- Set the  Who column definitions
      -- And set test_id to NULL;
      l_qc_tests_rec.created_by      := l_user_id;
      l_qc_tests_rec.last_updated_by := l_user_id;
      l_qc_tests_rec.test_id         := NULL;

      IF NOT GMD_QC_TESTS_PVT.INSERT_ROW(
            p_qc_tests_rec  => l_qc_tests_rec) THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Call Validate After Insert

      GMD_QC_TESTS_GRP.PROCESS_AFTER_INSERT(
           p_init_msg_list    => p_init_msg_list,
           p_gmd_qc_tests_rec => l_qc_tests_rec,
           x_return_status    => x_return_status,
           x_message_data     => x_msg_data
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

  /* Process Values Tbl If Present */

  IF G_PROCESS_VALUES THEN

     -- First Check If We have Processed A Test Record

     IF NOT G_PROCESS_TESTS THEN
        -- Only Processing Values

        -- Get The Test Record For The Values Specified
        IF  ( p_qc_test_values_tbl(1).test_id IS  NULL )  THEN
             GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
             RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_qc_tests_rec_in.test_id := p_qc_test_values_tbl(1).test_id;

        IF NOT GMD_QC_TESTS_PVT.fetch_row
            ( p_gmd_qc_tests => l_qc_tests_rec_in,
              x_gmd_qc_tests => l_qc_tests_rec) THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;

     END IF;

     -- Validate Test Type For Test Record

     IF  l_qc_tests_rec.test_type in ('U','N','E') THEN
           -- GIVE AN ERROR No Test Values Allowed For These Test Types
           GMD_API_PUB.log_message('GMD_INVALID_TEST_TYPE',
                                 'TEST_TYPE',l_qc_tests_rec.test_type); /* Bug 350233 - Use of rec variable rather than l_test_type local variable*/
           RAISE FND_API.G_EXC_ERROR;
     END IF;


     FOR i in 1..p_qc_test_values_tbl.COUNT LOOP

          l_qc_test_values_rec_in:= p_qc_test_values_tbl(i);

          IF G_PROCESS_TESTS THEN
              -- Assign the test_id to the Value record
              l_qc_test_values_rec_in.test_id := l_qc_tests_rec.test_id;
          END IF;

          IF l_qc_test_values_rec_in.test_id IS NULL THEN
              GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           -- Validate that the test_id's are all the same, we can only
           -- process values for the same test.

           IF l_qc_test_values_rec_in.test_id <> l_qc_tests_rec.test_id THEN
              -- Set error message
              GMD_API_PUB.log_message('GMD_INVALID_VALUES_TEST', 'TEST_CODE',
              l_qc_tests_rec.test_code );
              RAISE FND_API.G_EXC_ERROR;
           END IF;


            -- Validate Values definition

            GMD_QC_TEST_VALUES_GRP.VALIDATE_BEFORE_INSERT(
                p_qc_test_values_rec => l_qc_test_values_rec_in,
                x_qc_test_values_rec => l_qc_test_values_rec,
                x_return_status      => l_return_status,
                x_message_data       => l_msg_data
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- Insert Values PVT Routine.

           -- Set the  Who column definitions
           l_qc_test_values_rec.created_by      := l_user_id;
           l_qc_test_values_rec.last_updated_by := l_user_id;
           l_qc_test_values_rec.test_value_id   := NULL;

            IF NOT GMD_QC_TEST_VALUES_PVT.INSERT_ROW(
                p_qc_test_values_rec => l_qc_test_values_rec) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            --  set Return Parameter Tbl

            l_qc_test_values_tbl(i) := l_qc_test_values_rec;

      END LOOP;

     -- Now we have valid Test Record Call Validate after Insert.

     GMD_QC_TEST_VALUES_GRP.VALIDATE_AFTER_INSERT_ALL(
        p_gmd_qc_tests_rec => l_qc_tests_rec,
        x_gmd_qc_tests_rec => l_qc_tests_rec_in,
        x_return_status    => l_return_status,
        x_message_data     => l_msg_data);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

   END IF;

  /* Process Customer Values Tbl If Present */

  IF G_PROCESS_CUSTOMERS THEN
     -- First Check If We have Processed A Test Record

     IF NOT G_PROCESS_TESTS THEN

         -- Get The Test Record For The Values Specified
         IF  ( p_qc_cust_tests_tbl(1).test_id IS  NULL )  THEN
              -- Error Message No Test Id Specified for Values Rec
              GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
              RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_qc_tests_rec_in.test_id := p_qc_cust_tests_tbl(1).test_id;

         IF NOT GMD_QC_TESTS_PVT.fetch_row
             (
               p_gmd_qc_tests => l_qc_tests_rec_in,
               x_gmd_qc_tests => l_qc_tests_rec
              ) THEN

            RAISE FND_API.G_EXC_ERROR;

          END IF;

     END IF;

       FOR i in 1..p_qc_cust_tests_tbl.COUNT LOOP

           l_qc_cust_tests_rec := p_qc_cust_tests_tbl(i);

           IF  ( l_qc_cust_tests_rec.cust_id IS  NULL )  THEN
                  GMD_API_PUB.log_message('GMD_API_CUST_ID_NULL');
                  RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF G_PROCESS_TESTS THEN
              l_qc_cust_tests_rec.test_id := l_qc_tests_rec.test_id;
           END IF;

           IF l_qc_cust_tests_rec.test_id IS NULL THEN
              GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           -- Validate that the test_id's are all the same,
           -- we can only update values for the same test.

           IF l_qc_cust_tests_rec.test_id <> l_qc_tests_rec.test_id THEN
              GMD_API_PUB.log_message('GMD_INVALID_VALUES_TEST', 'TEST_CODE',
              l_qc_tests_rec.test_code );
              RAISE FND_API.G_EXC_ERROR;

           END IF;

            -- Validate Values definition

           GMD_CUSTOMER_TESTS_GRP.VALIDATE_BEFORE_INSERT(
              p_init_msg_list      => p_init_msg_list,
              p_customer_tests_rec => l_qc_cust_tests_rec,
              x_return_status      => l_return_status,
              x_message_data       => l_msg_data);


           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

            -- Insert Values PVT Routine.
           -- Set the  Who column definitions
           l_qc_cust_tests_rec.created_by      := l_user_id;
           l_qc_cust_tests_rec.last_updated_by := l_user_id;

            IF NOT GMD_CUSTOMER_TESTS_PVT.INSERT_ROW(
                p_customer_tests_rec => l_qc_cust_tests_rec ) THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

            --  set Return Paremeter Tbl

            l_qc_cust_tests_tbl(i) := l_qc_cust_tests_rec;

      END LOOP;

   END IF;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;


  x_return_status      := l_return_status;
  x_qc_tests_rec       := l_qc_tests_rec;
  x_qc_test_values_tbl := l_qc_test_values_tbl;
  x_qc_cust_tests_tbl  := l_qc_cust_tests_tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Tests;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Tests;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Create_Tests;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_TESTS;

PROCEDURE DELETE_TEST_HEADERS
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  NUMBER
, p_qc_tests_rec         IN  GMD_QC_TESTS%ROWTYPE
, p_user_name            IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'DELETE_TEST_HEADERS';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_msg_count          NUMBER  :=0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_qc_tests_rec_in    GMD_QC_TESTS%ROWTYPE;
  l_qc_tests_rec       GMD_QC_TESTS%ROWTYPE;
  l_rowid              VARCHAR2(10);
  l_test_id            NUMBER(10);
  l_user_id            NUMBER(15);

BEGIN


  -- Standard Start OF API savepoint

  SAVEPOINT DELETE_TEST_HEADERS;

  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message list if p_int_msg_list is set TRUE.
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --  Initialize API return Parameters

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  l_qc_tests_rec_in := p_qc_tests_rec;

  -- Validate User Name Parameter

  GMA_GLOBAL_GRP.Get_Who ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME','l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  ELSE

    -- Added below for BUG 2711643. Hverddin
    GMD_API_PUB.SET_USER_CONTEXT(p_user_id       => l_user_id,
                                 x_return_status => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  -- Check  Required Fields  Present

  IF ( l_qc_tests_rec_in.test_code IS NULL ) AND
     ( l_qc_tests_rec_in.test_id IS NULL )  THEN
     GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Fetch the Test Header Row.

  IF NOT GMD_QC_TESTS_PVT.fetch_row (
      p_gmd_qc_tests => l_qc_tests_rec_in,
      x_gmd_qc_tests => l_qc_tests_rec) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate that the Test Header is Not Already Marked For Purge

  IF l_qc_tests_rec.delete_mark = 1 THEN
     GMD_API_PUB.Log_Message('GMD_RECORD_DELETE_MARKED',
                              'l_table_name', 'GMD_QC_TESTS',
                              'l_column_name', 'TEST_ID',
                              'l_key_value', l_qc_tests_rec.test_id);

      RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- LOCK Header Row

  IF NOT GMD_QC_TESTS_PVT.lock_row
     ( p_test_id   => l_qc_tests_rec.test_id,
       p_test_code => l_qc_tests_rec.test_code
     ) THEN
     GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_QC_TESTS',
                              'l_column_name','TEST_ID',
                              'l_key_value', l_qc_tests_rec.test_id);

      RAISE FND_API.G_EXC_ERROR;
  ELSE

      -- Mark this record for Purge
      IF NOT GMD_QC_TESTS_PVT.mark_for_delete(
         p_test_id           => l_qc_tests_rec.test_id,
         p_test_code         => l_qc_tests_rec.test_code,
         p_last_update_date  => SYSDATE,
         p_last_updated_by   => l_user_id,
         p_last_update_login => l_qc_tests_rec.last_update_login
         ) THEN
          GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                              'l_table_name', 'GMD_QC_TESTS',
                              'l_column_name','TEST_ID',
                              'l_key_value', l_qc_tests_rec.test_id);


          RAISE FND_API.G_EXC_ERROR;

       END IF;
  END IF;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;


  x_return_status      := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_TEST_HEADERS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_TEST_HEADERS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO DELETE_TEST_HEADERS;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_TEST_HEADERS;


PROCEDURE DELETE_TEST_VALUES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  NUMBER
, p_qc_test_values_tbl   IN  GMD_QC_TESTS_PUB.qc_test_values_tbl
, x_deleted_rows         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'DELETE_TEST_VALUES';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_msg_count          NUMBER  :=0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_qc_tests_rec       GMD_QC_TESTS%ROWTYPE;
  l_qc_tests_rec_in    GMD_QC_TESTS%ROWTYPE;
  l_qc_test_values_rec GMD_QC_TEST_VALUES%ROWTYPE;
  l_qc_test_values_tbl GMD_QC_TESTS_PUB.qc_test_values_tbl;
  l_deleted_rows       NUMBER(10);
  l_test_id            NUMBER(10);

BEGIN


  -- Standard Start OF API savepoint

  SAVEPOINT DELETE_TEST_VALUES;

  --  Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.

  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --  Initialize API return Parameters

  l_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Check That input Table is Populated

  IF p_qc_test_values_tbl.COUNT  = 0 THEN
     GMD_API_PUB.LOG_MESSAGE('GMD_API_NO_ACTION_REQUIRED');
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Since we can only delete values associated to one test
  -- Get the test record based on first value record.

  IF p_qc_test_values_tbl(1).test_id IS NULL THEN
     GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     l_qc_tests_rec_in.test_id := p_qc_test_values_tbl(1).test_id;
  END IF;

  -- Fetch test Header Row.

  IF NOT GMD_QC_TESTS_PVT.fetch_row(
         p_gmd_qc_tests => l_qc_tests_rec_in,
         x_gmd_qc_tests => l_qc_tests_rec) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- NOW LOCK THIS HEADER ROW !!!!!

  IF NOT GMD_QC_TESTS_PVT.lock_row(
     p_test_id   => l_qc_tests_rec.test_id,
     p_test_code => l_qc_tests_rec.test_code) THEN
     GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                             'l_table_name', 'GMD_QC_TESTS',
                              'l_column_name','TEST_ID',
                              'l_key_value', l_qc_tests_rec.test_id);

     RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Loop Through Values Tbl Validate input and Process.

  FOR i in 1..p_qc_test_values_tbl.COUNT LOOP

     l_qc_test_values_rec := p_qc_test_values_tbl(i);

     IF l_qc_test_values_rec.test_value_id is NULL THEN
        -- Raise Error No Validate Parameters Defined
        GMD_API_PUB.log_message('GMD_TEST_VALUE_ID_REQ');
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_qc_test_values_rec.test_id is NULL THEN
        -- Raise Error No Validate Parameters Defined
        GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check that the test_id's being processed are consistant
     IF l_qc_tests_rec.test_id <> l_qc_test_values_rec.test_id THEN
        GMD_API_PUB.log_message('GMD_INVALID_VALUES_TEST', 'TEST_CODE',
        l_qc_tests_rec.test_code );
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Call Validate Routine to validate Header

     GMD_QC_TEST_VALUES_GRP.VALIDATE_BEFORE_DELETE(
       p_test_value_id   => l_qc_test_values_rec.test_value_id,
       x_return_status   => l_return_status,
       x_message_data    => l_msg_data);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Lock the Value Row.

      IF NOT GMD_QC_TEST_VALUES_PVT.LOCK_ROW(
        p_test_value_id     => l_qc_test_values_rec.test_value_id) THEN
        GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_QC_TEST_VALUES',
                              'l_column_name','TEST_VALUE_ID',
                              'l_key_value', l_qc_test_values_rec.test_value_id);

        RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Delete the Value Row.

      IF NOT GMD_QC_TEST_VALUES_PVT.DELETE_ROW(
         p_test_value_id     => l_qc_test_values_rec.test_value_id) THEN
         GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                            'l_table_name', 'GMD_QC_TEST_VALUES',
                            'l_column_name', 'TEST_VALUE_ID',
                            'l_key_value', l_qc_test_values_rec.test_value_id);


         RAISE FND_API.G_EXC_ERROR;
      END IF;

      --  set Return Paremeter Tbl
      l_deleted_rows := l_deleted_rows + i;

   END LOOP;

   -- Now Process All VAlues After Deletion

   GMD_QC_TEST_VALUES_GRP.VALIDATE_AFTER_DELETE_ALL(
    p_gmd_qc_tests_rec => l_qc_tests_rec,
    x_gmd_qc_tests_rec => l_qc_tests_rec_in,
    x_return_status    => l_return_status,
    x_message_data     => l_msg_data);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;



  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;


  x_return_status      := l_return_status;
  x_deleted_rows       := l_deleted_rows;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_TEST_VALUES;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_TEST_VALUES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO DELETE_TEST_VALUES;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_TEST_VALUES;

PROCEDURE DELETE_CUSTOMER_TESTS
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  NUMBER
, p_qc_cust_tests_tbl    IN  GMD_QC_TESTS_PUB.qc_cust_tests_tbl
, x_deleted_rows         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'DELETE_CUSTOMER_TESTS';
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_msg_count          NUMBER  :=0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_qc_tests_rec       GMD_QC_TESTS%ROWTYPE;
  l_qc_tests_rec_in    GMD_QC_TESTS%ROWTYPE;
  l_qc_cust_tests_rec  GMD_CUSTOMER_TESTS%ROWTYPE;
  l_deleted_rows       NUMBER;
  l_test_id            NUMBER(10);

BEGIN


  -- Standard Start OF API savepoint

  SAVEPOINT DELETE_CUSTOMER_TESTS;

  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_int_msg_list is set TRUE.

  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --  Initialize API return Parameters

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Since we can only delete customer values associated to one test
  -- Get the test record based on first customer value record.

  IF p_qc_cust_tests_tbl(1).test_id IS NULL THEN
     GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     l_qc_tests_rec_in.test_id := p_qc_cust_tests_tbl(1).test_id;
  END IF;

  -- Fetch test Header Row.

  IF NOT GMD_QC_TESTS_PVT.fetch_row(
         p_gmd_qc_tests => l_qc_tests_rec_in,
         x_gmd_qc_tests => l_qc_tests_rec) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- NOW LOCK THIS HEADER ROW !!!!!

  IF NOT GMD_QC_TESTS_PVT.lock_row(
     p_test_id   => l_qc_tests_rec.test_id,
     p_test_code => l_qc_tests_rec.test_code) THEN
     GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                             'l_table_name', 'GMD_QC_TESTS',
                              'l_column_name','TEST_ID',
                              'l_key_value', l_qc_tests_rec.test_id);

     RAISE FND_API.G_EXC_ERROR;
  END IF;


  FOR i in 1..p_qc_cust_tests_tbl.COUNT LOOP

     l_qc_cust_tests_rec := p_qc_cust_tests_tbl(i);

     IF l_qc_cust_tests_rec.test_id is NULL THEN
        GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_qc_cust_tests_rec.cust_id is NULL THEN
        GMD_API_PUB.log_message('GMD_API_CUST_ID_NULL');
        RAISE FND_API.G_EXC_ERROR;
     END IF;

      -- Check that the test_id's being processed are consistant

      IF l_qc_tests_rec.test_id <> l_qc_cust_tests_rec.test_id THEN
        GMD_API_PUB.log_message('GMD_INVALID_VALUES_TEST', 'TEST_CODE',
        l_qc_tests_rec.test_code );
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Call Validate Routine to validate Header

      GMD_CUSTOMER_TESTS_GRP.VALIDATE_BEFORE_DELETE(
          p_init_msg_list   => p_init_msg_list,
          p_test_id         => l_qc_cust_tests_rec.test_id,
          p_cust_id         => l_qc_cust_tests_rec.cust_id,
          x_return_status   => l_return_status,
          x_message_data    => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- LOCK THE ROW

      IF NOT GMD_CUSTOMER_TESTS_PVT.LOCK_ROW(
         p_test_id      => l_qc_cust_tests_rec.test_id,
         p_cust_id      => l_qc_cust_tests_rec.cust_id) THEN
         GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                              'l_table_name', 'GMD_CUSTOMER_TESTS',
                              'l_column_name','CUST_ID',
                              'l_key_value', l_qc_cust_tests_rec.cust_id);
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Now Delete Row

      IF NOT GMD_CUSTOMER_TESTS_PVT.DELETE_ROW(
         p_test_id      => l_qc_cust_tests_rec.test_id,
         p_cust_id      => l_qc_cust_tests_rec.cust_id) THEN

         GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                              'l_table_name', 'GMD_CUSTOMER_TESTS',
                              'l_column_name','CUST_ID',
                              'l_key_value', l_qc_cust_tests_rec.cust_id);

         RAISE FND_API.G_EXC_ERROR;
      END IF;


      --  set Return Paremeter Tbl
      l_deleted_rows := l_deleted_rows + i;

  END LOOP;


  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;


  x_return_status      := l_return_status;
  x_deleted_rows       := l_deleted_rows;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_CUSTOMER_TESTS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_CUSTOMER_TESTS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO DELETE_CUSTOMER_TESTS;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END delete_customer_tests;

END gmd_qc_tests_pub;

/
