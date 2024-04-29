--------------------------------------------------------
--  DDL for Package Body GMD_QC_TEST_VALUES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_TEST_VALUES_GRP" as
/* $Header: GMDGTVLB.pls 115.9 2002/11/21 18:34:22 mchandak noship $*/

/*===========================================================================
  PROCEDURE  NAME:	check_range_overlap

  DESCRIPTION:		This procedure checks for test type 'L' - numeric
  			range with label whether the subrange overlaps
  			with any other subrange within a test.
  			This procedure should be called after insert/update
  			of GMD_QC_TEST_VALUES_TL for test type 'L' but BEFORE
  			COMMIT.

  PARAMETERS:		In  : p_test_id
  			OUT : x_min_range - minimum value of the whole range.
  			      x_max_range - maximum value of the whole range.

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/
PROCEDURE CHECK_RANGE_OVERLAP(
		    p_test_id		 IN   VARCHAR2,
		    x_min_range		 OUT NOCOPY  NUMBER,
		    x_max_range          OUT NOCOPY  NUMBER,
		    x_return_status      OUT NOCOPY  VARCHAR2,
         	    x_message_data       OUT NOCOPY VARCHAR2) IS

l_progress  VARCHAR2(3);
l_exists    VARCHAR2(1);
l_min	    NUMBER;
l_max	    NUMBER;
l_counter   NUMBER(4):= 0;
l_prev_max  NUMBER;

CURSOR CR_TEST_VALUES IS
SELECT min_num,max_num
FROM   gmd_qc_test_values_b
WHERE  test_id = p_test_id
ORDER BY NVL(min_num, -999999999.999999999) ;

BEGIN
	l_progress := '010';

     	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF p_test_id IS NULL THEN
	    FND_MESSAGE.SET_NAME('GMD','GMD_TEST_ID_CODE_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
	END IF;

	l_progress := '020';

-- this cursor also takes care of multiple NULLS in min_num AND multiple NULLS in max_num in addition
-- to checking whether  a subrange overlaps with other subrange.
-- Selects each record ordered by min values and compares the min value in the current record to the
-- max value in the previous record.If they are the same, gives error.

	OPEN  CR_TEST_VALUES;
        LOOP
            FETCH CR_TEST_VALUES INTO l_min,l_max;
            IF CR_TEST_VALUES%NOTFOUND THEN
                CLOSE CR_TEST_VALUES ;
            	EXIT;
            END IF;
            l_counter := l_counter + 1 ;
            x_max_range := l_max ;
            IF l_counter > 1 THEN
                IF NVL(l_min,-999999999.999999999) <= NVL(l_prev_max,999999999.999999999) THEN
                    CLOSE CR_TEST_VALUES ;
          	    FND_MESSAGE.SET_NAME('GMD','GMD_RANGES_MAY_NOT_OVERLAP');
          	    FND_MSG_PUB.ADD;
            	    RAISE FND_API.G_EXC_ERROR;
         	END IF;
       	    ELSIF l_counter = 1 THEN
              x_min_range := l_min;
            END IF;
            l_prev_max := l_max;
        END LOOP;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
WHEN OTHERS
THEN
      IF CR_TEST_VALUES%ISOPEN THEN
      	  CLOSE CR_TEST_VALUES ;
      END IF;
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TEST_VALUES_GRP.CHECK_RANGE_OVERLAP' );
      FND_MESSAGE.Set_Token('ERROR', SUBSTR(SQLERRM,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END CHECK_RANGE_OVERLAP;


FUNCTION get_test_value_desc (
		    p_test_id	      IN   NUMBER,
		    p_test_value_num  IN   NUMBER ,
		    p_test_value_char IN   VARCHAR2 ) RETURN VARCHAR2 IS

l_test_value_desc  VARCHAR2(240) ;
l_test_type	   VARCHAR2(1);
BEGIN

	IF p_test_id IS NULL OR ( p_test_value_num IS NULL AND p_test_value_char IS NULL) THEN
	    return(null);
	END IF;

	SELECT test_type INTO l_test_type
	FROM GMD_QC_TESTS_B
	WHERE test_id = p_test_id ;

	IF l_test_type = 'L' THEN
	   SELECT DISPLAY_LABEL_NUMERIC_RANGE INTO l_test_value_desc
	   FROM  GMD_QC_TEST_VALUES
	   WHERE test_id = p_test_id
	   AND    p_test_value_num >= nvl(min_num,p_test_value_num)
	   AND    p_test_value_num <= nvl(max_num,p_test_value_num);
	ELSIF l_test_type = 'T' THEN
	   IF p_test_value_num IS NOT NULL THEN
	      SELECT test_value_desc INTO l_test_value_desc
	      FROM  GMD_QC_TEST_VALUES
	      WHERE test_id = p_test_id
	      AND   text_range_seq = p_test_value_num ;
	   ELSE
	      SELECT test_value_desc INTO l_test_value_desc
	      FROM  GMD_QC_TEST_VALUES
	      WHERE test_id = p_test_id
	      AND   value_char = p_test_value_char ;
	   END IF;
	ELSIF l_test_type = 'V' THEN
	   SELECT test_value_desc INTO l_test_value_desc
	   FROM  GMD_QC_TEST_VALUES
	   WHERE test_id = p_test_id
	   AND   value_char = p_test_value_char ;

	END IF;

	RETURN(l_test_value_desc);

EXCEPTION
WHEN OTHERS THEN
    RETURN(NULL);
END GET_TEST_VALUE_DESC;

/*===========================================================================
  PROCEDURE  NAME:	check_valid_test

  DESCRIPTION:		This procedure checks whether the test is valid or
  			not before inserting/deleting into test values table.

  PARAMETERS:		In  : p_test_id
  			OUT : test_type   - test type
  			      display_precision - display precision of the test.

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/

PROCEDURE CHECK_VALID_TEST(
	p_test_id	     IN  NUMBER,
	x_test_type	     OUT NOCOPY VARCHAR2,
	x_display_precision  OUT NOCOPY NUMBER,
        x_return_status      OUT NOCOPY VARCHAR2,
        x_message_data       OUT NOCOPY VARCHAR2) IS

l_progress  VARCHAR2(3);
l_delete_mark  NUMBER(5);

CURSOR cr_get_test_type(l_test_id NUMBER) IS
SELECT test_type,display_precision,delete_mark FROM GMD_QC_TESTS_B
WHERE test_id = p_test_id ;


BEGIN
	l_progress := '010';

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF p_test_id IS NULL THEN
	     FND_MESSAGE.SET_NAME('GMD','TEST_ID_CODE_NULL');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN  cr_get_test_type(p_test_id);
    	FETCH cr_get_test_type INTO x_test_type,x_display_precision,l_delete_mark;
    	IF cr_get_test_type%NOTFOUND THEN
    	     CLOSE cr_get_test_type;
    	     FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_TEST');
             FND_MESSAGE.SET_TOKEN('TEST', TO_CHAR(p_test_id));
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_get_test_type ;

    	l_progress := '020';

    	IF l_delete_mark = 1 THEN
    	     FND_MESSAGE.SET_NAME('GMD','GMD_TEST_DELETED');
             FND_MESSAGE.SET_TOKEN('TEST',TO_CHAR(p_test_id));
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	IF GMD_QC_TESTS_GRP.test_exist_in_spec(p_test_id => p_test_id) THEN
    	     FND_MESSAGE.SET_NAME('GMD','GMD_TEST_USED_IN_SPEC');
             FND_MESSAGE.SET_TOKEN('TEST',TO_CHAR(p_test_id));
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
    	END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TEST_VALUES_GRP.CHECK_VALID_TEST');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END CHECK_VALID_TEST;


PROCEDURE CHECK_FOR_NULL_AND_FKS(
	p_test_type	     IN VARCHAR,
	p_display_precision  IN NUMBER,
        p_qc_test_values_rec IN GMD_QC_TEST_VALUES%ROWTYPE,
        x_qc_test_values_rec OUT NOCOPY GMD_QC_TEST_VALUES%ROWTYPE,
	x_return_status      OUT NOCOPY  VARCHAR2,
        x_message_data       OUT NOCOPY VARCHAR2) IS

l_progress  VARCHAR2(3);

BEGIN
	l_progress := '010';

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	x_qc_test_values_rec := p_qc_test_values_rec ;

-- There should be no test values for p_test_type IN ('U','N','E').. Do that validation in PUBLIC API's

        IF x_qc_test_values_rec.EXPRESSION_REF_TEST_ID IS NOT NULL THEN
               FND_MESSAGE.SET_NAME('GMD','GMD_EXP_TEST_ID_NOT_REQD');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_test_type = 'L' THEN -- numeric range with label.
	    IF x_qc_test_values_rec.min_num  IS NULL  AND x_qc_test_values_rec.max_num  IS NULL
	    THEN
		    FND_MESSAGE.SET_NAME('GMD', 'GMD_MIN_MAX_REQ');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	    END IF;

	    IF LTRIM(RTRIM(x_qc_test_values_rec.display_label_numeric_range)) IS NULL THEN
		    FND_MESSAGE.SET_NAME('GMD', 'GMD_DISPLAY_LABEL_REQ');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	    END IF;

	    IF x_qc_test_values_rec.value_char IS NOT NULL THEN
	       FND_MESSAGE.SET_NAME('GMD','GMD_TEST_VALUE_CHAR_NOT_REQD');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

	    IF x_qc_test_values_rec.test_value_desc IS NOT NULL THEN
	       FND_MESSAGE.SET_NAME('GMD','GMD_TEST_VALUE_DESC_NOT_REQD');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

	    x_qc_test_values_rec.min_num := ROUND(x_qc_test_values_rec.min_num,p_display_precision);
	    x_qc_test_values_rec.max_num := ROUND(x_qc_test_values_rec.max_num,p_display_precision);

	    IF x_qc_test_values_rec.min_num IS NOT NULL  AND x_qc_test_values_rec.max_num IS NOT NULL
	    THEN
	         IF x_qc_test_values_rec.min_num > x_qc_test_values_rec.max_num THEN
		    FND_MESSAGE.SET_NAME('GMD','GMD_TEST_MIN_MAX_ERROR');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	         END IF;
	    END IF;
	ELSE
	    IF x_qc_test_values_rec.min_num IS NOT NULL OR x_qc_test_values_rec.max_num IS NOT NULL THEN
	       FND_MESSAGE.SET_NAME('GMD','GMD_TEST_RANGE_NOT_REQD');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF x_qc_test_values_rec.display_label_numeric_range IS NOT NULL THEN
	       FND_MESSAGE.SET_NAME('GMD', 'GMD_DISPLAY_LABEL_NOT_REQD');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	END IF;

	IF p_test_type = 'V' THEN  -- List Of Values
	    IF LTRIM(RTRIM(x_qc_test_values_rec.value_char)) IS NULL THEN
		    FND_MESSAGE.SET_NAME('GMD', 'GMD_VALUE_CHAR_REQ');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	    END IF;

	    IF LTRIM(RTRIM(x_qc_test_values_rec.test_value_desc)) IS NULL THEN
		    FND_MESSAGE.SET_NAME('GMD', 'GMD_TEST_VALUE_DESC_REQ');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END IF;

	 IF p_test_type = 'T' THEN  -- Text Range
	    IF LTRIM(RTRIM(x_qc_test_values_rec.value_char)) IS NULL THEN
		    FND_MESSAGE.SET_NAME('GMD', 'GMD_VALUE_CHAR_REQ');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	    END IF;

	    IF LTRIM(RTRIM(x_qc_test_values_rec.test_value_desc)) IS NULL THEN
		    FND_MESSAGE.SET_NAME('GMD', 'GMD_TEST_VALUE_DESC_REQ');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	    END IF;

	    SELECT NVL(MAX(text_range_seq),0) + 1 INTO x_qc_test_values_rec.text_range_seq
	    FROM   GMD_QC_TEST_VALUES_B
	    WHERE  test_id = x_qc_test_values_rec.test_id ;

	 ELSE

	    IF x_qc_test_values_rec.text_range_seq IS NOT NULL THEN
	       FND_MESSAGE.SET_NAME('GMD', 'GMD_SEQ_NOT_REQD');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TEST_VALUES_GRP.CHECK_FOR_NULL_AND_FKS');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END CHECK_FOR_NULL_AND_FKS;


/*===========================================================================
  PROCEDURE  NAME:	validate_before_insert

  DESCRIPTION:		This procedure validates test values before insert.

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_INSERT(
	p_qc_test_values_rec IN GMD_QC_TEST_VALUES%ROWTYPE,
	x_qc_test_values_rec OUT NOCOPY GMD_QC_TEST_VALUES%ROWTYPE,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress  		VARCHAR2(3);
l_temp      		VARCHAR2(1);
l_test_type 		VARCHAR2(1);
l_display_precision	NUMBER(1);

CURSOR cr_test_value_exist IS
  SELECT 'x'  FROM GMD_QC_TEST_VALUES_B
  WHERE test_id = p_qc_test_values_rec.test_id
  AND   value_char = p_qc_test_values_rec.value_char ;

BEGIN
	l_progress := '010';

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF p_qc_test_values_rec.test_id IS NULL THEN
	     FND_MESSAGE.SET_NAME('GMD','GMD_TEST_ID_REQ');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	END IF;

	check_valid_test(p_test_id	   => p_qc_test_values_rec.test_id,
			 x_test_type	   => l_test_type,
			 x_display_precision  => l_display_precision,
        		 x_return_status   => x_return_status,
        		 x_message_data    => x_message_data );

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    	   RETURN;
    	END IF;

    	IF l_test_type IN ('N','E','U') THEN
    	    FND_MESSAGE.SET_NAME('GMD','GMD_TEST_VALUE_REC_NOT_REQ');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
    	END IF;

	CHECK_FOR_NULL_AND_FKS(
                p_test_type	=> l_test_type,
                p_display_precision => l_display_precision,
        	p_qc_test_values_rec => p_qc_test_values_rec,
        	x_qc_test_values_rec => x_qc_test_values_rec,
		x_return_status => x_return_status,
        	x_message_data  => x_message_data );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;

	-- check for duplicate test values.
	IF l_test_type IN ('V','T') THEN
	    OPEN  cr_test_value_exist;
	    FETCH cr_test_value_exist INTO l_temp;
	    IF cr_test_value_exist%FOUND THEN
	        CLOSE cr_test_value_exist;
	        FND_MESSAGE.SET_NAME('GMD','GMD_DUP_TEST_VALUE');
   	        FND_MESSAGE.SET_TOKEN('TEST',to_char(x_qc_test_values_rec.test_id));
	        FND_MSG_PUB.ADD;
	        RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    CLOSE cr_test_value_exist;
	END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TEST_VALUES_GRP.VALIDATE_BEFORE_INSERT');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END validate_before_insert;

/*===========================================================================

  PROCEDURE NAME:	validate_after_insert_all
  DESCRIPTION:		This procedure updates min_value_num and max_value_num
  		        in test header table and also validates if the range
  		        doesnt overlap.
  		        NOTE : Call after all test values are inserted.

===========================================================================*/

PROCEDURE VALIDATE_AFTER_INSERT_ALL(
	p_gmd_qc_tests_rec IN  GMD_QC_TESTS%ROWTYPE,
	x_gmd_qc_tests_rec OUT NOCOPY  GMD_QC_TESTS%ROWTYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS


l_progress  VARCHAR2(3);
l_test_values_count  BINARY_INTEGER;
l_min_range	NUMBER;
l_max_range	NUMBER;

BEGIN
	l_progress := '010';

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	x_gmd_qc_tests_rec := p_gmd_qc_tests_rec;


	IF x_gmd_qc_tests_rec.test_id IS NULL THEN
	     FND_MESSAGE.SET_NAME('GMD','GMD_TEST_ID_CODE_NULL');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	END IF;

-- atleast one test value record must be there.
	IF x_gmd_qc_tests_rec.test_type in ('V','T','L') THEN
            SELECT NVL(COUNT(1),0) INTO l_test_values_count
            FROM GMD_QC_TEST_VALUES_B
            WHERE test_id = x_gmd_qc_tests_rec.test_id ;

            IF l_test_values_count = 0 THEN
	       FND_MESSAGE.SET_NAME('GMD','GMD_NO_TEST_VALUES');
               FND_MESSAGE.SET_TOKEN('TEST',x_gmd_qc_tests_rec.test_code);
               FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        l_progress := '020';

        IF x_gmd_qc_tests_rec.test_type = 'L' THEN
      	    GMD_QC_TEST_VALUES_GRP.CHECK_RANGE_OVERLAP(
		    p_test_id	    => x_gmd_qc_tests_rec.test_id,
		    x_min_range	    => l_min_range,
		    x_max_range     => l_max_range,
		    x_return_status => x_return_status,
		    x_message_data  => x_message_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RETURN;
            END IF;

	    IF x_gmd_qc_tests_rec.exp_error_type = 'N' AND l_min_range IS NOT NULL AND l_max_range IS NOT NULL THEN
      	        gmd_qc_tests_grp.validate_all_exp_error(
      	    	    p_validation_level		=> 'SPEC',
		    p_exp_error_type  		=> x_gmd_qc_tests_rec.exp_error_type,
		    p_below_spec_min            => x_gmd_qc_tests_rec.below_spec_min,
		    p_below_min_action_code     => x_gmd_qc_tests_rec.below_min_action_code,
		    p_above_spec_min            => x_gmd_qc_tests_rec.above_spec_min,
		    p_above_min_action_code     => x_gmd_qc_tests_rec.above_min_action_code,
		    p_below_spec_max            => x_gmd_qc_tests_rec.below_spec_max,
		    p_below_max_action_code     => x_gmd_qc_tests_rec.below_max_action_code,
		    p_above_spec_max            => x_gmd_qc_tests_rec.above_spec_max,
		    p_above_max_action_code     => x_gmd_qc_tests_rec.above_max_action_code,
		    p_test_min        		=> l_min_range,
		    p_test_max        		=> l_max_range,
         	    x_return_status 		=> x_return_status,
        	    x_message_data  		=> x_message_data );

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     RETURN;
                 END IF;
             END IF;

  	     UPDATE GMD_QC_TESTS_B
	     SET min_value_num = l_min_range,
  	         max_value_num = l_max_range
             WHERE
	         test_id = x_gmd_qc_tests_rec.test_id ;

  	     x_gmd_qc_tests_rec.min_value_num := l_min_range;
	     x_gmd_qc_tests_rec.max_value_num := l_max_range;

        END IF; -- :gmd_qc_tests.test_type = 'L'

	l_progress := '030';

        IF x_gmd_qc_tests_rec.test_type = 'T' THEN
 	    SELECT MIN(text_range_seq),MAX(text_range_seq)
	    INTO   l_min_range,l_max_range
	    FROM   GMD_QC_TEST_VALUES_B
	    WHERE  test_id = x_gmd_qc_tests_rec.test_id;

	    UPDATE GMD_QC_TESTS_B
	    SET min_value_num = l_min_range,
  	        max_value_num = l_max_range
            WHERE
	        test_id = x_gmd_qc_tests_rec.test_id ;

	    x_gmd_qc_tests_rec.min_value_num := l_min_range;
	    x_gmd_qc_tests_rec.max_value_num := l_max_range;

        END IF; -- end of :gmd_qc_tests.test_type = 'T'

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TEST_VALUES_GRP.VALIDATE_AFTER_INSERT_ALL');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END validate_after_insert_all;

/*===========================================================================
  PROCEDURE  NAME:	validate_before_delete

  DESCRIPTION:		This procedure checks whether test header is not marked
  			for purge.

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_DELETE(
	p_test_value_id	   IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress  VARCHAR2(3);
l_temp      VARCHAR2(1);
l_test_type VARCHAR2(1);
l_test_id   NUMBER;
l_display_precision	NUMBER(1);

CURSOR cr_get_test_id IS
  SELECT test_id  FROM GMD_QC_TEST_VALUES_B
  WHERE test_value_id = p_test_value_id ;

BEGIN
	l_progress := '010';
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF p_test_value_id IS NULL THEN
	     FND_MESSAGE.SET_NAME('GMD','GMD_TEST_VALUE_ID_REQ');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN  cr_get_test_id;
	FETCH cr_get_test_id INTO l_test_id;
	IF cr_get_test_id%NOTFOUND THEN
	   CLOSE cr_get_test_id;
	   FND_MESSAGE.SET_NAME('GMD','GMD_TEST_VALUE_INVALID');
	   FND_MESSAGE.SET_TOKEN('TEST_VALUE',to_char(p_test_value_id));
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE cr_get_test_id;

	check_valid_test(p_test_id	   => l_test_id,
			 x_test_type	   => l_test_type,
			 x_display_precision  => l_display_precision,
        		 x_return_status   => x_return_status,
        		 x_message_data    => x_message_data );

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    	   RETURN;
    	END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TEST_VALUES_GRP.VALIDATE_BEFORE_DELETE');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE_BEFORE_DELETE ;


PROCEDURE VALIDATE_AFTER_DELETE_ALL(
	p_gmd_qc_tests_rec IN  GMD_QC_TESTS%ROWTYPE,
	x_gmd_qc_tests_rec OUT NOCOPY  GMD_QC_TESTS%ROWTYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress  VARCHAR2(3);

BEGIN
	VALIDATE_AFTER_INSERT_ALL(
		p_gmd_qc_tests_rec => p_gmd_qc_tests_rec,
		x_gmd_qc_tests_rec => x_gmd_qc_tests_rec,
        	x_return_status  => x_return_status,
        	x_message_data   => x_message_data ) ;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TEST_VALUES_GRP.VALIDATE_AFTER_DELETE_ALL');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE_AFTER_DELETE_ALL ;

FUNCTION text_range_char_to_seq ( p_test_id IN NUMBER,
				  p_value_char IN VARCHAR2)

RETURN NUMBER IS
l_seq   BINARY_INTEGER;
BEGIN

  SELECT text_range_seq INTO l_seq
  FROM   GMD_QC_TEST_VALUES_B
  WHERE  test_id 	= p_test_id
  AND    value_char	= p_value_char ;

  RETURN (l_seq);

EXCEPTION WHEN OTHERS THEN
   FND_MESSAGE.Set_Name('GMD','GMD_TEXT_RANGE_SEQ_INVALID');
   FND_MESSAGE.Set_Token('TEST',to_char(p_test_id));
   FND_MESSAGE.Set_Token('VALUE',p_value_char);
   FND_MSG_PUB.ADD;
   RETURN(-1);
END text_range_char_to_seq;

END GMD_QC_TEST_VALUES_GRP ;

/
