--------------------------------------------------------
--  DDL for Package Body GMD_CUSTOMER_TESTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_CUSTOMER_TESTS_GRP" as
/* $Header: GMDGTCUB.pls 115.4 2004/04/07 16:31:44 pupakare noship $*/

/*===========================================================================
  PROCEDURE  NAME:      Check_exists

  DESCRIPTION:          This Functions Detemines if Unqiue Record Exists.


  CHANGE HISTORY:       Created         29-SEP-02       HVERDDIN
===========================================================================*/
FUNCTION CHECK_EXISTS( p_test_id             IN   NUMBER,
                       p_cust_id             IN   NUMBER)
RETURN BOOLEAN IS

l_progress  VARCHAR2(3);
l_exists    VARCHAR2(1);
BEGIN
        l_progress := '010';

        IF p_test_id IS NULL THEN
            GMD_API_PUB.log_message('GMD','GMD_TEST_ID_CODE_NULL');
            RETURN FALSE;
        END IF;

        IF p_cust_id is NULL THEN
           GMD_API_PUB.log_message('GMD_API_CUST_ID_NULL');
           RETURN FALSE;
        END IF;

        l_progress := '020';

        BEGIN
                SELECT 'X' INTO l_exists
                FROM GMD_CUSTOMER_TESTS
                WHERE  test_id = p_test_id
                AND    cust_id = p_cust_id;

             RETURN TRUE;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN FALSE;
        END;

EXCEPTION
  WHEN OTHERS THEN
      RETURN FALSE;
END CHECK_EXISTS;


/*===========================================================================
  PROCEDURE  NAME:      validate_before_insert

  DESCRIPTION:		This procedure validates customer values before insert.


  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/
PROCEDURE VALIDATE_BEFORE_INSERT(
		    p_init_msg_list      IN   VARCHAR2 ,
                    p_customer_tests_rec IN  GMD_CUSTOMER_TESTS%ROWTYPE,
		    x_return_status      OUT NOCOPY VARCHAR2,
         	    x_message_data       OUT NOCOPY VARCHAR2) IS

l_progress          VARCHAR2(3);
l_dummy             NUMBER;
l_delete_mark       NUMBER;
l_display_precision NUMBER;
l_test_type         VARCHAR2(1);

CURSOR c_check_test (p_test_id IN NUMBER)
IS
SELECT display_precision,test_type ,delete_mark
FROM   GMD_QC_TESTS
WHERE  test_id = p_test_id
AND    delete_mark = 0;

CURSOR c_check_cust ( p_cust_id IN NUMBER)
IS
SELECT 1
FROM  hz_cust_accounts_all a,
      hz_parties p,
      hz_cust_acct_sites_all  s,
      gl_plcy_mst g
WHERE a.cust_account_id  =  s.cust_account_id
AND   p.party_id         = a.party_id
AND   g.org_id           =  s.org_id
AND   a.cust_account_id  = p_cust_id;


BEGIN
        l_progress := '010';

        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
        END IF;

        -- Validate that required Fields are populated.

        IF p_customer_tests_rec.test_id is NULL THEN
             GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
             RAISE FND_API.G_EXC_ERROR;
        ELSE
           -- Check Test is Valid
           OPEN c_check_test (p_customer_tests_rec.test_id);
              FETCH c_check_test INTO l_display_precision,
                                      l_test_type,l_delete_mark;
              IF c_check_test%NOTFOUND THEN
                 CLOSE c_check_test;
                 GMD_API_PUB.log_message('GMD_INVALID_TEST_ID',
                                      'TEST_ID',p_customer_tests_rec.test_id);
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
            CLOSE c_check_test;
        END IF;


        IF p_customer_tests_rec.cust_id is NULL THEN
           GMD_API_PUB.log_message('GMD_API_CUST_ID_NULL');
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           -- Check Customer is Valid
           OPEN c_check_cust (p_customer_tests_rec.cust_id);
              FETCH c_check_cust INTO l_dummy;
              IF c_check_cust%NOTFOUND THEN
                 CLOSE c_check_cust;
                 GMD_API_PUB.log_message('GMD_INVALID_CUST_ID',
                                      'CUST_ID',p_customer_tests_rec.cust_id);
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
            CLOSE c_check_cust;
        END IF;


       -- Validate that header record is not delete Marked.

       IF l_delete_mark = 1 THEN
             GMD_API_PUB.log_message('GMD_TEST_DELETED',
                                      'TEST',p_customer_tests_rec.test_id);
             RAISE FND_API.G_EXC_ERROR;
       END IF;

        -- Validate that record does not exist

       l_progress := '020';

       IF CHECK_EXISTS ( p_test_id => p_customer_tests_rec.test_id,
                         p_cust_id => p_customer_tests_rec.cust_id) THEN

           GMD_API_PUB.log_message('GMD_CUST_TESTS_EXISTS',
                                   'CUST_ID',p_customer_tests_rec.cust_id,
                                   'TEST_ID',p_customer_tests_rec.test_id);
           RAISE FND_API.G_EXC_ERROR;
       END IF;


     -- Validate Report Precison and Display

     IF p_customer_tests_rec.cust_test_display IS NULL AND
        p_customer_tests_rec.report_precision  IS NULL THEN
        GMD_API_PUB.log_message('GMD','GMD_CUST_TEST_REQ');
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_progress := '030';

     -- Validate Business Rules For Precision and Display

     IF l_test_type in ('L','N','E') THEN

        IF p_customer_tests_rec.report_precision is NOT NULL AND
           p_customer_tests_rec.report_precision > l_display_precision THEN
           GMD_API_PUB.log_message('GMD_REP_GRTR_DIS_PRCSN',
                                   'DISPLAY_PRECISION', l_display_precision);
           RAISE FND_API.G_EXC_ERROR;

        END IF;
     ELSE

        IF p_customer_tests_rec.report_precision is NOT NULL THEN
           GMD_API_PUB.log_message('GMD_REP_PRCSN_INVALID',
                                   'TEST_TYPE',l_test_type);
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_customer_tests_rec.cust_test_display IS NULL THEN
           GMD_API_PUB.log_message('GMD_CUST_DISPLAY_REQ');
           RAISE FND_API.G_EXC_ERROR;
        END IF;

     END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS  THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     GMD_API_PUB.log_message('GMD_API_ERROR',
                             'PACKAGE'   , 'GMD_CUSTOMER_TESTS_GRP',
                             'ERROR'     , substr(sqlerrm,1,100),
                             'POSITION'  , l_progress);

END VALIDATE_BEFORE_INSERT;

PROCEDURE VALIDATE_BEFORE_DELETE(
		    p_init_msg_list      IN   VARCHAR2 ,
                    p_test_id            IN   NUMBER,
                    p_cust_id            IN   NUMBER,
		    x_return_status      OUT  NOCOPY VARCHAR2,
         	    x_message_data       OUT NOCOPY VARCHAR2) IS

l_progress      VARCHAR2(3);
l_delete_mark   NUMBER;

CURSOR c_check_deleted ( p_test_id NUMBER)
IS
SELECT delete_mark
FROM   GMD_QC_TESTS
WHERE  test_id = p_test_id;

BEGIN
	l_progress := '010';

     	x_return_status := FND_API.G_RET_STS_SUCCESS ;
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

       -- Validate that test_id and cust_id are populated.

        IF p_test_id is NULL THEN
             GMD_API_PUB.log_message('GMD_TEST_ID_CODE_NULL');
             RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_cust_id is NULL THEN
           GMD_API_PUB.log_message('GMD_API_CUST_ID_NULL');
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Validate that record Exists

       IF NOT CHECK_EXISTS ( p_test_id => p_test_id,
                             p_cust_id => p_cust_id) THEN

           GMD_API_PUB.log_message('GMD_CUST_TESTS_NOTEXISTS',
                                   'CUST_ID',p_cust_id,
                                   'TEST_ID',p_test_id);
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_progress := '020';

       -- Validate that the test_header row has been marked for Purge.

       OPEN c_check_deleted (p_test_id);
          FETCH c_check_deleted into l_delete_mark;
       CLOSE c_check_deleted;

       -- BUG 3554590 Check if the TEST is already deleted!
       IF l_delete_mark = 1 THEN
             GMD_API_PUB.log_message('GMD_TEST_DELETED',
                                      'TEST',p_test_id);
             RAISE FND_API.G_EXC_ERROR;
       END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      GMD_API_PUB.log_message('GMD_API_ERROR',
                             'PACKAGE'   , 'GMD_CUSTOMER_TESTS_GRP',
                             'ERROR'     , substr(sqlerrm,1,100),
                             'POSITION'  , l_progress);

END VALIDATE_BEFORE_DELETE;

END GMD_CUSTOMER_TESTS_GRP ;

/
