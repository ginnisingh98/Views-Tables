--------------------------------------------------------
--  DDL for Package Body GMD_QC_TESTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_TESTS_GRP" as
/* $Header: GMDGTSTB.pls 120.1 2006/03/22 23:07:10 rlnagara noship $*/

/*===========================================================================
  FUNCTION  NAME:	check_test_exist

  DESCRIPTION:		This procedure checks whether the test_code/test_id
  			already exists or not.

  PARAMETERS:		In : p_init_msg_list - Valid values are 'T' and 'F'
			     p_test_code/p_test_id to validate

			Out: x_test_exist returns TRUE if test exist else FALSE.

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
             Ravi Boddu 29-APR-2004 Added the function test_group_order_exist Bug: 3447472
===========================================================================*/
FUNCTION CHECK_TEST_EXIST(
		    p_init_msg_list      IN   VARCHAR2 ,
		    p_test_code          IN   VARCHAR2 ,
         	    p_test_id		 IN   NUMBER   )
RETURN BOOLEAN IS

l_progress  VARCHAR2(3);
l_exists    VARCHAR2(1);
BEGIN
	l_progress := '010';

     	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

	IF p_test_id IS NULL AND p_test_code IS NULL THEN
	    FND_MESSAGE.SET_NAME('GMD','GMD_TEST_ID_CODE_NULL');
            FND_MSG_PUB.ADD;
            RETURN FALSE;
	END IF;

	l_progress := '020';

	BEGIN
	     IF p_test_id IS NOT NULL THEN
	        SELECT 'X' INTO l_exists
             	FROM GMD_QC_TESTS_B
             	WHERE  test_id = p_test_id ;
             ELSE
                SELECT 'X' INTO l_exists
	        FROM GMD_QC_TESTS_B
                WHERE  test_code = p_test_code ;
             END IF;

             RETURN TRUE;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN FALSE;
        END;

EXCEPTION WHEN OTHERS
THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.CHECK_TEST_EXIST' );
      FND_MESSAGE.Set_Token('ERROR', SUBSTR(SQLERRM,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      RETURN FALSE;
END CHECK_TEST_EXIST;


/*===========================================================================

  FUNCTION NAME:	test_exist_in_spec

===========================================================================*/

FUNCTION test_exist_in_spec(
		    p_init_msg_list   IN   VARCHAR2 ,
		    p_test_id	      IN   NUMBER)  RETURN BOOLEAN IS

CURSOR cr_test_exist IS
  SELECT  'Y' FROM GMD_SPEC_TESTS_B gst ,GMD_SPECIFICATIONS_B gs
  WHERE  gst.test_id = p_test_id
  AND gst.spec_id = gs.spec_id
  AND gs.delete_mark = 0 ;

l_progress  VARCHAR2(3);
l_temp	VARCHAR2(1);

BEGIN
	l_progress := '010';

     	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

	IF p_test_id IS NULL THEN
	   FND_MESSAGE.Set_Name('GMD','GMD_TEST_ID_CODE_NULL');
           FND_MSG_PUB.ADD;
           RETURN FALSE;
        END IF;

        l_progress := '020';

	OPEN  cr_test_exist;
	FETCH cr_test_exist into l_temp;
	IF cr_test_exist%FOUND THEN
	   CLOSE cr_test_exist;
	   RETURN TRUE;
	ELSE
	   CLOSE cr_test_exist;
	   RETURN FALSE;
        END IF;


EXCEPTION WHEN OTHERS
THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.TEST_EXIST_IN_SPEC' );
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      RETURN FALSE;
END TEST_EXIST_IN_SPEC;

/*===========================================================================
  FUNCTION  NAME:	get_test_id_tab

  DESCRIPTION:		This procedure returns table of type EXP_TEST_ID_TAB_TYPE

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/

FUNCTION GET_TEST_ID_TAB RETURN exp_test_id_tab_type IS
l_test_id_tab  EXP_TEST_ID_TAB_TYPE;
BEGIN
    return(l_test_id_tab);
END;

/*===========================================================================

  PROCEDURE NAME:	validate_expression

===========================================================================*/
PROCEDURE validate_expression(
		    p_init_msg_list   IN   VARCHAR2 ,
         	    p_expression      IN   VARCHAR2,
         	    x_test_tab        OUT  NOCOPY exp_test_id_tab_type,
         	    x_return_status   OUT  NOCOPY VARCHAR2,
         	    x_message_data    OUT NOCOPY VARCHAR2)  IS

l_progress     VARCHAR2(3);
l_exptab       GMD_UTILITY_PKG.exptab ;
l_test_in_rec  GMD_QC_TESTS%ROWTYPE ;
l_test_rec     GMD_QC_TESTS%ROWTYPE ;
BEGIN
	l_progress := '010';

     	x_return_status := FND_API.G_RET_STS_SUCCESS ;
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

	IF p_expression IS NULL THEN
	   FND_MESSAGE.Set_Name('GMD','GMD_NO_EXPRESSION');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;

        l_progress := '020';

        GMD_UTILITY_PKG.parse(x_exp   		=> p_expression,
                   	      x_exptab 		=> l_exptab,
                   	      x_return_status   => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
           RETURN;
        END IF;

        l_progress := '030';

        FOR i IN 1..l_exptab.COUNT
        LOOP
             IF l_exptab(i).pvalue_type = 'O' THEN
             	  l_test_in_rec.test_code := l_exptab(i).poperand ;
             	  l_test_in_rec.test_id   := NULL;

             	  IF NOT ( GMD_QC_TESTS_PVT.Fetch_Row(
                    p_gmd_qc_tests => l_test_in_rec,
                    x_gmd_qc_tests => l_test_rec)) THEN
                      FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_TEST_EXP');
		      FND_MESSAGE.SET_TOKEN('TEST',l_exptab(i).poperand);
                      FND_MSG_PUB.ADD;
 	              RAISE FND_API.G_EXC_ERROR ;
                  ELSIF l_test_rec.delete_mark = 1 OR l_test_rec.test_type IN ('U','V','T','E') THEN
		      FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_TEST_EXP');
		      FND_MESSAGE.SET_TOKEN('TEST',l_exptab(i).poperand);
                      FND_MSG_PUB.ADD;
 	              RAISE FND_API.G_EXC_ERROR ;
                  END IF;

                  -- valid test

                  IF x_test_tab.EXISTS(l_test_rec.test_id) THEN
                      NULL; -- if test already exist don't add again
                  ELSE
                      x_test_tab(l_test_rec.test_id):= l_test_rec.test_id ;
                  END IF;
              END IF;
        END LOOP ;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.VALIDATE_EXPRESSION' );
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END VALIDATE_EXPRESSION;



/*===========================================================================

  PROCEDURE NAME:	insert_exp_test_values

===========================================================================*/
PROCEDURE insert_exp_test_values(
		    p_init_msg_list   IN   VARCHAR2 ,
		    p_test_id	      IN   NUMBER,
         	    p_test_id_tab     IN   exp_test_id_tab_type,
         	    x_return_status   OUT  NOCOPY VARCHAR2,
         	    x_message_data    OUT NOCOPY VARCHAR2)  IS

l_progress      VARCHAR2(3);
i		BINARY_INTEGER;
l_rowid		ROWID;
l_test_value_id NUMBER;

BEGIN
	l_progress := '010';

     	x_return_status := FND_API.G_RET_STS_SUCCESS ;
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

	IF p_test_id IS NULL THEN
	   FND_MESSAGE.Set_Name('GMD','GMD_TEST_ID_CODE_NULL');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;

	l_progress := '020';

	DELETE from GMD_QC_TEST_VALUES_TL
	WHERE test_value_id IN
	  (SELECT test_value_id FROM gmd_qc_test_values_b
	   WHERE test_id = p_test_id );

	DELETE from GMD_QC_TEST_VALUES_B
	WHERE test_id = p_test_id;

	l_progress := '030';

	IF p_test_id_tab.COUNT > 0 THEN
	   i := p_test_id_tab.FIRST;
	   WHILE i IS NOT NULL
	   LOOP
	        l_test_value_id := NULL;
		GMD_QC_TEST_VALUES_PVT.INSERT_ROW(
    			X_ROWID => l_rowid,
    			X_TEST_ID => p_test_id,
    			X_TEST_VALUE_ID => l_test_value_id,
    			X_EXPRESSION_REF_TEST_ID => p_test_id_tab(i),
    			X_DISPLAY_LABEL_NUMERIC_RANGE => 'EXPRESSION');

		i := p_test_id_tab.NEXT(i);
	   END LOOP ;
	END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.INSERT_EXP_TEST_VALUES' );
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END insert_exp_test_values;


/*===========================================================================

  PROCEDURE NAME:	DISPLAY_REPORT_PRECISION
  Parameters
  p_validation_level - DISPLAY_PRECISION to validate DISPLAY_PRECISION from FORM only
                     - REPORT_PRECISION to validate REPORT_PRECISION from FORM only
                     - FULL to validate both display and test precision columns
  p_test_method_id   - Test method associated with the Test.
  p_test_id	     - Test id

===========================================================================*/

PROCEDURE DISPLAY_REPORT_PRECISION
		   (p_validation_level       IN   VARCHAR2,
		    p_init_msg_list          IN   VARCHAR2 ,
		    p_test_method_id         IN NUMBER,
		    p_test_id		     IN NUMBER,
		    p_new_display_precision  IN OUT NOCOPY NUMBER,
       	    	    p_new_report_precision   IN OUT NOCOPY NUMBER,
       	    	    x_return_status          OUT  NOCOPY VARCHAR2,
       	    	    x_message_data           OUT  NOCOPY VARCHAR2)  IS

l_progress  	   	VARCHAR2(3);
l_test_method_precision NUMBER(2);
l_test_in_rec 		GMD_QC_TESTS%ROWTYPE ;
l_test_rec   		GMD_QC_TESTS%ROWTYPE ;
l_old_display_precision NUMBER(2);
l_old_report_precision  NUMBER(2);

BEGIN
	l_progress := '010';

   	x_return_status := FND_API.G_RET_STS_SUCCESS ;
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

	IF  (p_new_report_precision IS NOT NULL AND p_new_report_precision not between 0 and 9)
	THEN
	   FND_MESSAGE.Set_Name('GMD','GMD_INVALID_PRECISION');
	   FND_MESSAGE.Set_Token('PRECISION',p_new_report_precision);
           FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF  (p_new_display_precision IS NOT NULL AND p_new_display_precision not between 0 and 9)
	THEN
	   FND_MESSAGE.Set_Name('GMD','GMD_INVALID_PRECISION');
	   FND_MESSAGE.Set_Token('PRECISION',p_new_display_precision);
           FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (p_validation_level = 'DISPLAY_PRECISION') AND (p_new_display_precision IS NULL) THEN
	    RETURN;
	END IF;

	IF (p_validation_level = 'REPORT_PRECISION')  AND (p_new_report_precision IS NULL)  THEN
	    RETURN;
	END IF;


	l_progress := '020';

	IF p_test_method_id IS NOT NULL THEN
	BEGIN
	   SELECT display_precision INTO l_test_method_precision
	   FROM  GMD_TEST_METHODS_B
	   WHERE test_method_id = p_test_method_id ;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   FND_MESSAGE.Set_Name('GMD','GMD_INVALID_TEST_METHOD');
           FND_MESSAGE.Set_Token('TEST_METHOD',to_char(p_test_method_id));
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END ;
        END IF;

        l_progress := '030';

        IF p_test_id IS NOT NULL THEN
           l_test_in_rec.test_id := p_test_id ;

           IF (GMD_QC_TESTS_PVT.Fetch_Row(p_gmd_qc_tests => l_test_in_rec,
                                          x_gmd_qc_tests => l_test_rec)) THEN
                l_old_display_precision := l_test_rec.display_precision;
                l_old_report_precision  := l_test_rec.report_precision;

                IF l_old_display_precision IS NULL OR l_old_report_precision IS NULL THEN
                    FND_MESSAGE.Set_Name('GMD','GMD_INVALID_PRECISION');
            	    FND_MSG_PUB.ADD;
           	    RAISE FND_API.G_EXC_ERROR;
                END IF;
           ELSE
               FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_TEST');
	       FND_MESSAGE.SET_TOKEN('TEST',to_char(p_test_id));
               FND_MSG_PUB.ADD;
 	       RAISE FND_API.G_EXC_ERROR;
           END IF;
	END IF;

	l_progress := '040';

	IF (p_validation_level = 'FULL') AND (p_new_display_precision IS NULL) AND (p_new_report_precision IS NULL) THEN
	    p_new_display_precision := NVL(l_test_method_precision,9);
	    p_new_report_precision  := p_new_display_precision;
	    RETURN;
	END IF ;

	l_progress := '050';

	IF p_validation_level IN ('FULL','DISPLAY_PRECISION') THEN
	   IF l_test_method_precision IS NOT NULL AND p_new_display_precision > l_test_method_precision THEN
	       FND_MESSAGE.Set_Name('GMD','GMD_TST_PRCSN_GRTR_TSTMTHD');
               FND_MESSAGE.Set_Token('TEST_METHOD_PRECISION',TO_CHAR(l_test_method_precision));
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF p_new_report_precision > p_new_display_precision THEN
              FND_MESSAGE.Set_Name('GMD','GMD_REP_GRTR_DIS_PRCSN');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

        END IF;

        l_progress := '060';

       IF p_test_id IS NOT NULL THEN
	   IF gmd_qc_tests_grp.test_exist_in_spec(p_test_id	=> p_test_id) THEN
	        IF p_validation_level IN ('FULL','REPORT_PRECISION') THEN
	              IF p_new_report_precision < l_old_report_precision THEN
	                   FND_MESSAGE.Set_Name('GMD','GMD_NEW_PRCSN_LESS_OLD');
	                   FND_MESSAGE.Set_Token('OLD_PRECISION',to_char(l_old_report_precision));
	                   FND_MSG_PUB.ADD;
	                   RAISE FND_API.G_EXC_ERROR;
	              END IF;
	        END IF;

	        IF p_validation_level IN ('FULL','DISPLAY_PRECISION') THEN
	              IF p_new_display_precision < l_old_display_precision THEN
	                  FND_MESSAGE.Set_Name('GMD','GMD_NEW_PRCSN_LESS_OLD');
	                  FND_MESSAGE.Set_Token('OLD_PRECISION',to_char(l_old_display_precision));
	                  FND_MSG_PUB.ADD;
	                  RAISE FND_API.G_EXC_ERROR;
	              END IF;
	       END IF;
	   END IF;
       END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
WHEN OTHERS THEN
   FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
   FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.DISPLAY_REPORT_PRECISION' );
   FND_MESSAGE.Set_Token('ERROR', SUBSTR(SQLERRM,1,100));
   FND_MESSAGE.Set_Token('POSITION',l_progress );
   FND_MSG_PUB.ADD;
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END DISPLAY_REPORT_PRECISION;


PROCEDURE MIN_MAX_VALUE_NUM(
		    p_init_msg_list       IN   VARCHAR2 ,
		    p_test_type		  IN   VARCHAR2,
		    p_min_value_num       IN   NUMBER,
         	    p_max_value_num       IN   NUMBER,
         	    x_return_status       OUT  NOCOPY VARCHAR2,
         	    x_message_data        OUT  NOCOPY VARCHAR2)  IS

l_progress  	   VARCHAR2(3);

BEGIN
        l_progress := '010';

        IF p_test_type NOT IN ('N','E') THEN
		RETURN;
	END IF;

     	x_return_status := FND_API.G_RET_STS_SUCCESS ;
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

	l_progress := '020';

	IF p_min_value_num IS NOT NULL AND p_max_value_num IS NOT NULL THEN
           IF p_min_value_num > p_max_value_num THEN
	       FND_MESSAGE.Set_Name('GMD','QC_MIN_MAX_SPEC');
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
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.MIN_MAX_VALUE_NUM');
      FND_MESSAGE.Set_Token('ERROR', SUBSTR(SQLERRM,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END MIN_MAX_VALUE_NUM ;

/*===========================================================================

  PROCEDURE NAME:	validate_experimental_error

===========================================================================*/
PROCEDURE validate_experimental_error(
		    p_validation_level      IN VARCHAR2 ,
		    p_init_msg_list         IN VARCHAR2 ,
	      	    p_exp_error_type        IN VARCHAR2,
		    p_spec_value            IN NUMBER ,
		    p_action_code 	    IN VARCHAR2 ,
		    p_test_min              IN NUMBER,
		    p_test_max              IN NUMBER,
         	    x_return_status         OUT NOCOPY VARCHAR2,
         	    x_message_data          OUT NOCOPY VARCHAR2)  IS

l_progress  VARCHAR2(3);

BEGIN
	l_progress := '010';

	x_return_status := FND_API.G_RET_STS_SUCCESS ;
	IF (p_test_min IS NULL OR p_test_max IS NULL ) AND (p_validation_level = 'SPEC')
	 AND (p_exp_error_type = 'N') THEN
	   RETURN;
	END IF;

     	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

	IF p_exp_error_type IS NOT NULL AND p_exp_error_type NOT IN ('N','P') THEN
           FND_MESSAGE.Set_Name('GMD','GMD_EXP_ERROR_TYPE_REQ');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

	l_progress := '020';

	IF p_exp_error_type IS NOT NULL AND p_spec_value is NOT NULL AND p_validation_level IN ('SPEC','FULL') THEN
	   IF p_exp_error_type = 'N' AND p_test_min IS NOT NULL AND p_test_max IS NOT NULL THEN
              IF ABS(p_spec_value) > ABS(p_test_max - p_test_min) THEN
                 FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_SPEC_VAL_NUM');
                 FND_MESSAGE.SET_TOKEN('MAX_VAL',to_char(ABS(p_test_max - p_test_min)));
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           ELSE
              IF ABS(p_spec_value) > 100 THEN
                 FND_MESSAGE.Set_Name('GMD','GMD_INVALID_SPEC_VAL_NUM');
                 FND_MESSAGE.SET_TOKEN('MAX_VAL',100);
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           END IF;
        END IF;

        IF p_action_code IS NOT NULL and p_spec_value IS NULL AND
	 p_validation_level IN ('ACTION','FULL') THEN
	    FND_MESSAGE.Set_Name('GMD','GMD_EXP_ERR_VAL_REQ_ACTION');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.validate_experimental_error');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END validate_experimental_error;

--+========================================================================+
--| API Name    : validate_all_exp_error				   |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for experimental error region      |
--|               for all the four action codes and spec value             |
--| HISTORY                                                                |
--|                                                                        |
--+========================================================================+

PROCEDURE validate_all_exp_error(
		    p_validation_level      IN VARCHAR2 ,
		    p_init_msg_list         IN VARCHAR2 ,
	      	    p_exp_error_type        IN VARCHAR2,
		    p_below_spec_min        IN NUMBER ,
		    p_below_min_action_code IN VARCHAR2,
		    p_above_spec_min        IN NUMBER ,
		    p_above_min_action_code IN VARCHAR2 ,
		    p_below_spec_max        IN NUMBER ,
		    p_below_max_action_code IN VARCHAR2 ,
		    p_above_spec_max        IN NUMBER ,
		    p_above_max_action_code IN VARCHAR2 ,
		    p_test_min              IN NUMBER,
		    p_test_max              IN NUMBER,
         	    x_return_status         OUT NOCOPY VARCHAR2,
         	    x_message_data          OUT NOCOPY VARCHAR2)  IS

l_progress  VARCHAR2(3);

BEGIN
	l_progress := '010';

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

     	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

	IF p_exp_error_type IS NOT NULL AND p_exp_error_type NOT IN ('N','P') THEN
           FND_MESSAGE.Set_Name('GMD','GMD_EXP_ERROR_TYPE_REQ');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

	l_progress := '020';

        validate_experimental_error(
        	    p_validation_level => p_validation_level,
		    p_exp_error_type   => p_exp_error_type,
		    p_spec_value       => p_below_spec_min,
		    p_action_code      => p_below_min_action_code,
		    p_test_min         => p_test_min,
		    p_test_max         => p_test_max,
         	    x_return_status    => x_return_status,
        	    x_message_data     => x_message_data );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN;
        END IF;

        l_progress := '030';

        validate_experimental_error(
        	    p_validation_level => p_validation_level,
		    p_exp_error_type   => p_exp_error_type,
		    p_spec_value       => p_above_spec_min,
		    p_action_code      => p_above_min_action_code,
		    p_test_min         => p_test_min,
		    p_test_max         => p_test_max,
         	    x_return_status    => x_return_status,
        	    x_message_data     => x_message_data );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN;
         END IF;

         l_progress := '030';

         validate_experimental_error(
        	    p_validation_level => p_validation_level,
		    p_exp_error_type   => p_exp_error_type,
		    p_spec_value       => p_below_spec_max,
		    p_action_code      => p_below_max_action_code,
		    p_test_min         => p_test_min,
		    p_test_max         => p_test_max,
         	    x_return_status    => x_return_status,
        	    x_message_data     => x_message_data );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN;
         END IF;

         l_progress := '040';

         validate_experimental_error(
        	    p_validation_level => p_validation_level,
		    p_exp_error_type   => p_exp_error_type,
		    p_spec_value       => p_above_spec_max,
		    p_action_code      => p_above_max_action_code,
		    p_test_min         => p_test_min,
		    p_test_max         => p_test_max,
         	    x_return_status    => x_return_status,
        	    x_message_data     => x_message_data );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN;
         END IF;

EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   x_message_data  := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.validate_all_exp_error');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END validate_all_exp_error;


/*===========================================================================

  FUNCTION NAME:	validate_test_priority
  DESCRIPTION:		This function returns TRUE if test priority is VALID
  			else it returns FALSE.
===========================================================================*/

FUNCTION validate_test_priority(p_test_priority	IN VARCHAR2) RETURN BOOLEAN
IS
l_temp	VARCHAR2(1);
BEGIN
    IF p_test_priority IS NULL THEN
    	RETURN FALSE;
    END IF;

    SELECT 'X' INTO l_temp
    FROM  fnd_lookup_values
    WHERE lookup_type = 'GMD_QC_TEST_PRIORITY'
    AND	  lookup_code = p_test_priority
    AND	  language = userenv('LANG') ;

    RETURN TRUE;

EXCEPTION WHEN OTHERS THEN
   RETURN FALSE;

END validate_test_priority;



--+========================================================================+
--| API Name    : check_for_null_and_fks				   |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for NULL and Foreign Key           |
--|               constraints for the required filed in the Test           |
--|               Header record.                                           |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise return  error      |
--|                                                                        |
--| HISTORY                                                                |
--|      Rameshwar  14-APR-2004   BUG#3545701                                |
--|                 Commented the code for non-validated tests             |
--+========================================================================+


PROCEDURE CHECK_FOR_NULL_AND_FKS(
	p_gmd_qc_tests_rec IN  GMD_QC_TESTS%ROWTYPE,
        x_gmd_qc_tests_rec OUT NOCOPY GMD_QC_TESTS%ROWTYPE,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

CURSOR cr_check_valid_test_method(p_test_method_id NUMBER) IS
SELECT 'x' FROM GMD_TEST_METHODS_B
    	WHERE test_method_id = p_test_method_id
    	AND   delete_mark = 0;

CURSOR cr_check_valid_test_class(p_test_class VARCHAR2) IS
SELECT 'x' FROM GMD_TEST_CLASSES_B
    	WHERE test_class = p_test_class
    	AND   delete_mark = 0;


CURSOR cr_check_valid_test_unit(p_qcunit_code VARCHAR2) IS
SELECT 'x' FROM GMD_UNITS_B
    	WHERE qcunit_code = p_qcunit_code
    	AND   delete_mark = 0;

CURSOR cr_check_valid_action_code(p_action_code VARCHAR2) IS
SELECT 'x' FROM GMD_ACTIONS_B
    	WHERE action_code = p_action_code
    	AND   delete_mark = 0;


l_progress  VARCHAR2(3);
l_temp	    VARCHAR2(1);
BEGIN

    l_progress := '010';

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    x_gmd_qc_tests_rec := p_gmd_qc_tests_rec ;

-- Test Code

    IF (LTRIM(RTRIM(x_gmd_qc_tests_rec.test_code)) IS NULL) THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_TEST_ID_CODE_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Test Description

    IF (LTRIM(RTRIM(x_gmd_qc_tests_rec.test_desc)) IS NULL) THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_TEST_DESC_REQD');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Test Method

    IF x_gmd_qc_tests_rec.test_method_id IS NULL THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_TEST_METHOD_REQD');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
    	OPEN  cr_check_valid_test_method(x_gmd_qc_tests_rec.test_method_id);
    	FETCH cr_check_valid_test_method INTO l_temp;
    	IF cr_check_valid_test_method%NOTFOUND THEN
    	    CLOSE cr_check_valid_test_method;
    	    FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_TEST_METHOD');
            FND_MESSAGE.SET_TOKEN('TEST_METHOD', TO_CHAR(x_gmd_qc_tests_rec.test_method_id));
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_check_valid_test_method ;

    END IF;

        l_progress := '020';
    -- Test Data Type

    IF x_gmd_qc_tests_rec.test_type IS NULL THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_TEST_TYPE_REQD');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_gmd_qc_tests_rec.test_type NOT IN ('U','N','E','L','V','T') THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_TEST_TYPE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Test Priority
    IF x_gmd_qc_tests_rec.priority IS NULL THEN
        x_gmd_qc_tests_rec.priority := '5N';

    ELSIF (NOT validate_test_priority(p_test_priority => x_gmd_qc_tests_rec.priority)) THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_TEST_PRIORITY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_gmd_qc_tests_rec.delete_mark := 0;

    IF x_gmd_qc_tests_rec.test_type NOT IN ('N','E') THEN
    	IF (x_gmd_qc_tests_rec.min_value_num IS NOT NULL OR x_gmd_qc_tests_rec.max_value_num IS NOT NULL) THEN
    		FND_MESSAGE.SET_NAME('GMD','GMD_TEST_RANGE_NOT_REQD');
        	FND_MSG_PUB.ADD;
        	RAISE FND_API.G_EXC_ERROR;
    	END IF;

    ELSE
        IF (x_gmd_qc_tests_rec.min_value_num IS NULL OR x_gmd_qc_tests_rec.max_value_num IS NULL) THEN
            FND_MESSAGE.SET_NAME('GMD', 'GMD_TEST_RANGE_REQ');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    IF x_gmd_qc_tests_rec.test_type = 'E' THEN
        IF x_gmd_qc_tests_rec.expression IS NULL THEN
            FND_MESSAGE.SET_NAME('GMD', 'GMD_EXPRESSION_REQD');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSIF x_gmd_qc_tests_rec.expression IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('GMD','GMD_EXPRESSION_NOT_REQD');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_gmd_qc_tests_rec.test_type IN ('U','T','V') THEN
      --BEGIN BUG#3545701
      --Commented the code for Non-validated tests.
      /* IF x_gmd_qc_tests_rec.test_type = 'U' and x_gmd_qc_tests_rec.test_unit IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_TEST_UNIT_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF; */
      --END BUG#3545701
       IF (x_gmd_qc_tests_rec.display_precision IS NOT NULL OR x_gmd_qc_tests_rec.report_precision IS NOT NULL) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_PRECISION_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF x_gmd_qc_tests_rec.exp_error_type IS NOT NULL THEN
            FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_EXP_ERROR_TYPE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_gmd_qc_tests_rec.below_spec_min IS NOT NULL OR  x_gmd_qc_tests_rec.below_min_action_code IS NOT NULL )
        OR (x_gmd_qc_tests_rec.above_spec_min IS NOT NULL OR  x_gmd_qc_tests_rec.above_min_action_code IS NOT NULL )
        OR (x_gmd_qc_tests_rec.below_spec_max IS NOT NULL OR  x_gmd_qc_tests_rec.below_max_action_code IS NOT NULL )
        OR (x_gmd_qc_tests_rec.above_spec_max IS NOT NULL OR  x_gmd_qc_tests_rec.above_max_action_code IS NOT NULL ) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_EXP_ERROR_NOT_REQD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSE
       IF x_gmd_qc_tests_rec.test_unit IS NULL THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_TEST_UNIT_REQD');
           FND_MESSAGE.SET_TOKEN('TEST',x_gmd_qc_tests_rec.test_code);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_gmd_qc_tests_rec.display_precision IS NULL OR x_gmd_qc_tests_rec.report_precision IS NULL ) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_PRECISION_REQD');
           FND_MESSAGE.SET_TOKEN('TEST',x_gmd_qc_tests_rec.test_code);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF ((x_gmd_qc_tests_rec.exp_error_type IN ('N','P')) OR (x_gmd_qc_tests_rec.exp_error_type IS NULL)) THEN
    	   NULL ;
        ELSE
           FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_EXP_ERROR_TYPE');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    l_progress := '030';

    IF x_gmd_qc_tests_rec.exp_error_type IS NULL AND
      (x_gmd_qc_tests_rec.below_spec_min IS NOT NULL OR x_gmd_qc_tests_rec.above_spec_min IS NOT NULL
       OR x_gmd_qc_tests_rec.below_spec_max IS NOT NULL OR x_gmd_qc_tests_rec.above_spec_max IS NOT NULL)
    THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_EXP_ERROR_TYPE_REQ');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_gmd_qc_tests_rec.exp_error_type IS NOT NULL AND
      (x_gmd_qc_tests_rec.below_spec_min IS NULL AND x_gmd_qc_tests_rec.above_spec_min IS NULL
       AND x_gmd_qc_tests_rec.below_spec_max IS NULL AND x_gmd_qc_tests_rec.above_spec_max IS NULL)
    THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_EXP_ERR_TYPE_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_gmd_qc_tests_rec.TEST_UNIT IS NOT NULL THEN
        OPEN  cr_check_valid_test_unit(x_gmd_qc_tests_rec.test_unit);
    	FETCH cr_check_valid_test_unit INTO l_temp;
    	IF cr_check_valid_test_unit%NOTFOUND THEN
    	    CLOSE cr_check_valid_test_unit;
    	    FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_TEST_UNIT');
            FND_MESSAGE.SET_TOKEN('TEST_UNIT',x_gmd_qc_tests_rec.test_unit);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_check_valid_test_unit ;
    END IF;

    IF x_gmd_qc_tests_rec.TEST_CLASS IS NOT NULL THEN
        OPEN  cr_check_valid_test_class(x_gmd_qc_tests_rec.test_class);
    	FETCH cr_check_valid_test_class INTO l_temp;
    	IF cr_check_valid_test_class%NOTFOUND THEN
    	    CLOSE cr_check_valid_test_class;
    	    FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_TEST_CLASS');
            FND_MESSAGE.SET_TOKEN('TEST_CLASS', x_gmd_qc_tests_rec.test_class);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_check_valid_test_class ;
    END IF;

    l_progress := '040';

    IF x_gmd_qc_tests_rec.BELOW_MIN_ACTION_CODE IS NOT NULL THEN
        OPEN  cr_check_valid_action_code(x_gmd_qc_tests_rec.below_min_action_code);
    	FETCH cr_check_valid_action_code INTO l_temp;
    	IF cr_check_valid_action_code%NOTFOUND THEN
    	    CLOSE cr_check_valid_action_code;
    	    FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ACTION_CODE');
            FND_MESSAGE.SET_TOKEN('ACTION', x_gmd_qc_tests_rec.below_min_action_code);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_check_valid_action_code ;
    END IF;

    IF x_gmd_qc_tests_rec.ABOVE_MIN_ACTION_CODE IS NOT NULL THEN
        OPEN  cr_check_valid_action_code(x_gmd_qc_tests_rec.above_min_action_code);
    	FETCH cr_check_valid_action_code INTO l_temp;
    	IF cr_check_valid_action_code%NOTFOUND THEN
    	    CLOSE cr_check_valid_action_code;
    	    FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ACTION_CODE');
            FND_MESSAGE.SET_TOKEN('ACTION', x_gmd_qc_tests_rec.above_min_action_code);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_check_valid_action_code ;
    END IF;

    IF x_gmd_qc_tests_rec.BELOW_MAX_ACTION_CODE IS NOT NULL THEN
        OPEN  cr_check_valid_action_code(x_gmd_qc_tests_rec.below_max_action_code);
    	FETCH cr_check_valid_action_code INTO l_temp;
    	IF cr_check_valid_action_code%NOTFOUND THEN
    	    CLOSE cr_check_valid_action_code;
    	    FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ACTION_CODE');
            FND_MESSAGE.SET_TOKEN('ACTION', x_gmd_qc_tests_rec.below_max_action_code);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_check_valid_action_code ;
    END IF;

    IF x_gmd_qc_tests_rec.ABOVE_MAX_ACTION_CODE IS NOT NULL THEN
        OPEN  cr_check_valid_action_code(x_gmd_qc_tests_rec.above_max_action_code);
    	FETCH cr_check_valid_action_code INTO l_temp;
    	IF cr_check_valid_action_code%NOTFOUND THEN
    	    CLOSE cr_check_valid_action_code;
    	    FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ACTION_CODE');
            FND_MESSAGE.SET_TOKEN('ACTION', x_gmd_qc_tests_rec.above_max_action_code);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE cr_check_valid_action_code ;
    END IF;

    -- make test_id null. generate test id with sequence.
    x_gmd_qc_tests_rec.test_id := NULL;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

  WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.check_for_null_and_fks');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END check_for_null_and_fks;


PROCEDURE VALIDATE_BEFORE_INSERT(
	p_gmd_qc_tests_rec IN 	GMD_QC_TESTS%ROWTYPE,
        x_gmd_qc_tests_rec OUT 	NOCOPY GMD_QC_TESTS%ROWTYPE,
	x_return_status    OUT  NOCOPY VARCHAR2,
        x_message_data     OUT 	NOCOPY VARCHAR2) IS

l_progress  VARCHAR2(3);
l_exp_test_id_tab  exp_test_id_tab_type;

BEGIN
	l_progress := '010';

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	CHECK_FOR_NULL_AND_FKS(
		p_gmd_qc_tests_rec => p_gmd_qc_tests_rec,
        	x_gmd_qc_tests_rec => x_gmd_qc_tests_rec,
		x_return_status => x_return_status,
        	x_message_data  => x_message_data );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;

        -- check for duplicate test_code.
        IF CHECK_TEST_EXIST(p_test_code => x_gmd_qc_tests_rec.test_code) THEN
            FND_MESSAGE.SET_NAME('GMD','SY_WFDUPLICATE');
            FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF x_gmd_qc_tests_rec.test_type = 'E' THEN
            validate_expression(
            	  p_expression => x_gmd_qc_tests_rec.expression,
         	  x_test_tab   => l_exp_test_id_tab,
         	  x_return_status => x_return_status,
        	  x_message_data  => x_message_data );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RETURN;
             END IF;
        END IF;

        IF x_gmd_qc_tests_rec.test_type in ('N','L','E') THEN
            DISPLAY_REPORT_PRECISION
		   (p_validation_level => 'FULL',
		    p_test_method_id   => x_gmd_qc_tests_rec.test_method_id,
		    p_test_id	       => null,
		    p_new_display_precision => x_gmd_qc_tests_rec.display_precision,
       	    	    p_new_report_precision  => x_gmd_qc_tests_rec.report_precision,
       	    	    x_return_status => x_return_status,
        	    x_message_data  => x_message_data );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RETURN;
            END IF;
         END IF;

         -- In case of numeric range with label,min_value_num and max_value_num is derived
         -- after test values are insert. so do this validation after insertion of test values.

         IF x_gmd_qc_tests_rec.test_type in ('N','L','E') THEN

             x_gmd_qc_tests_rec.min_value_num := ROUND(x_gmd_qc_tests_rec.min_value_num,x_gmd_qc_tests_rec.display_precision);
             x_gmd_qc_tests_rec.max_value_num := ROUND(x_gmd_qc_tests_rec.max_value_num,x_gmd_qc_tests_rec.display_precision);


             MIN_MAX_VALUE_NUM(
		    p_test_type	     => x_gmd_qc_tests_rec.test_type,
		    p_min_value_num  => x_gmd_qc_tests_rec.min_value_num,
         	    p_max_value_num  => x_gmd_qc_tests_rec.max_value_num,
         	    x_return_status => x_return_status,
        	    x_message_data  => x_message_data );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RETURN;
             END IF;

             IF x_gmd_qc_tests_rec.exp_error_type IS NOT NULL THEN
                IF x_gmd_qc_tests_rec.exp_error_type = 'N' THEN
             	    x_gmd_qc_tests_rec.below_spec_min := ROUND(x_gmd_qc_tests_rec.below_spec_min,x_gmd_qc_tests_rec.display_precision);
             	    x_gmd_qc_tests_rec.above_spec_min := ROUND(x_gmd_qc_tests_rec.above_spec_min,x_gmd_qc_tests_rec.display_precision);
             	    x_gmd_qc_tests_rec.below_spec_max := ROUND(x_gmd_qc_tests_rec.below_spec_max,x_gmd_qc_tests_rec.display_precision);
             	    x_gmd_qc_tests_rec.above_spec_max := ROUND(x_gmd_qc_tests_rec.above_spec_max,x_gmd_qc_tests_rec.display_precision);
             	END IF;

                validate_all_exp_error(
		    p_exp_error_type  		=> x_gmd_qc_tests_rec.exp_error_type,
		    p_below_spec_min            => x_gmd_qc_tests_rec.below_spec_min,
		    p_below_min_action_code     => x_gmd_qc_tests_rec.below_min_action_code,
		    p_above_spec_min            => x_gmd_qc_tests_rec.above_spec_min,
		    p_above_min_action_code     => x_gmd_qc_tests_rec.above_min_action_code,
		    p_below_spec_max            => x_gmd_qc_tests_rec.below_spec_max,
		    p_below_max_action_code     => x_gmd_qc_tests_rec.below_max_action_code,
		    p_above_spec_max            => x_gmd_qc_tests_rec.above_spec_max,
		    p_above_max_action_code     => x_gmd_qc_tests_rec.above_max_action_code,
		    p_test_min        		=> x_gmd_qc_tests_rec.min_value_num,
		    p_test_max        		=> x_gmd_qc_tests_rec.max_value_num,
         	    x_return_status 		=> x_return_status,
        	    x_message_data  		=> x_message_data );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RETURN;
                END IF;

             END IF;

          END IF; -- IF x_gmd_qc_tests_rec.test_type in ('N','L','E') THEN

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.validate_before_insert');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END validate_before_insert ;

/*===========================================================================

  PROCEDURE NAME:	process_after_insert
  DESCRIPTION:		This procedure inserts records into test values for expression
                        test data type.
===========================================================================*/

PROCEDURE PROCESS_AFTER_INSERT (
	p_init_msg_list    IN  VARCHAR2 ,
        p_gmd_qc_tests_rec IN  GMD_QC_TESTS%ROWTYPE,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress  VARCHAR2(3);
l_exp_test_id_tab  exp_test_id_tab_type;

BEGIN
	l_progress := '010';

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
	END IF;

	IF p_gmd_qc_tests_rec.test_id IS NULL THEN
	     FND_MESSAGE.SET_NAME('GMD','GMD_TEST_ID_CODE_NULL');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF p_gmd_qc_tests_rec.test_type = 'E' THEN
	    validate_expression(
            	  p_expression => p_gmd_qc_tests_rec.expression,
         	  x_test_tab   => l_exp_test_id_tab,
         	  x_return_status => x_return_status,
        	  x_message_data  => x_message_data );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RETURN;
             END IF;

             IF l_exp_test_id_tab.COUNT > 0 THEN
                GMD_QC_TESTS_GRP.INSERT_EXP_TEST_VALUES(
			p_test_id => p_gmd_qc_tests_rec.test_id,
 		        p_test_id_tab => l_exp_test_id_tab,
  		        x_return_status => x_return_status,
		        x_message_data  => x_message_data);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RETURN;
                END IF;
             END IF;

	 END IF;  -- IF p_gmd_qc_tests_rec.test_type = 'E' THEN

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.process_after_insert');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END process_after_insert ;

/*===========================================================================
  FUNCTION NAME:	test_group_order_exist
  DESCRIPTION:		This function checks if there is already an existing test group order
          present, matching the given test group order, for a given test class.
          Added as part of Test Groups Enh Bug: 3447472
===========================================================================*/
FUNCTION test_group_order_exist(
                    p_init_msg_list      IN   VARCHAR2 ,
                    p_test_class         IN   VARCHAR2 ,
                    p_test_group_order     IN   NUMBER   )
RETURN BOOLEAN IS
l_progress  VARCHAR2(3);
l_exists    VARCHAR2(1);
BEGIN
        l_progress := '010';

        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;    -- clear the message stack.
        END IF;


        l_progress := '020';

        BEGIN
          IF p_test_class IS NOT NULL AND
             p_test_group_order IS NOT NULL THEN
             SELECT 'X' INTO l_exists
             FROM GMD_QC_TESTS_B
             WHERE  test_class = p_test_class
             AND    test_group_order = p_test_group_order
             AND rownum =1 ;
               RETURN TRUE;
          END IF;
            RETURN FALSE;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN FALSE;
        END;
EXCEPTION WHEN OTHERS
THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.test_group_order_exist' );
      FND_MESSAGE.Set_Token('ERROR', SUBSTR(SQLERRM,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      RETURN FALSE;
END test_group_order_exist;

/*===========================================================================
  FUNCTION NAME:        POPULATE_TEST_GRP_GT
  Change History
  Manish Gupta Created 05-04-2004
          Added as part of Test Groups Enh Bug: 3447472
  RLNAGARA B5099998 23-Mar-2006 Added the order by clause in the insert statement so that the
                                tests are inserted in the table according to the given order.
===========================================================================*/
PROCEDURE POPULATE_TEST_GRP_GT(p_test_class IN varchar2,
                               p_spec_id    IN NUMBER default NULL,
                               p_sample_id  IN NUMBER default NULL,
                               x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_get_spec_id(p_sample_id NUMBER) IS
select c.spec_id
from   gmd_samples a,
       gmd_sampling_events b,
       gmd_event_spec_disp c
where  a.sample_id = p_sample_id
and    a.sampling_event_id = b.sampling_event_id
and    a.sampling_event_id = c.sampling_event_id
and    nvl(c.spec_used_for_lot_attrib_ind,'N') ='Y';

CURSOR c_get_test_id IS
select test_id
from   gmd_test_group_gt;


l_spec_id  NUMBER;
l_test_qty_uom VARCHAR2(80);
l_test_qty NUMBER;

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

   delete gmd_test_group_gt;
   INSERT INTO GMD_TEST_GROUP_GT
     (TEST_GROUP_ORDER,
      TEST_CODE,
      TEST_ID,
      TEST_DESC,
      TEST_TYPE,
      TEST_QTY,
      TEST_QTY_UOM, --rconv
      USED_IN_SPEC,
      INCLUDE)
    SELECT a.TEST_GROUP_ORDER test_group_order,
         a.TEST_CODE test_code,
          a.TEST_ID,
          a.TEST_DESC test_desc,
          b.meaning test_type,
          c.test_qty,
          c.test_qty_uom,  --rconv
          'N',
          'Y'
   FROM GMD_QC_TESTS a, gem_lookups b , gmd_test_methods c
where a.test_class = p_test_class
   AND  b.lookup_type = 'GMD_QC_TEST_TYPE'
   AND  a.test_type = b.lookup_code
   AND a.test_method_id = c.test_method_id
   ORDER BY test_group_order;                      --RLNAGARA B5099998 Added this ORDER BY Clause.

  IF (p_spec_id IS NOT NULL) THEN
     UPDATE gmd_test_group_gt
     SET    used_in_spec = 'Y', include = 'N'
     WHERE  test_id IN (SELECT test_id
                       FROM gmd_spec_tests
                       WHERE spec_id = p_spec_id);
    ELSIF (p_sample_id IS NOT NULL) THEN
      OPEN c_get_spec_id(p_sample_id);
      FETCH c_get_spec_id INTO l_spec_id;
      CLOSE c_get_spec_id;

        FOR l_test_id IN c_get_test_id LOOP
        BEGIN
           SELECT nvl(a.test_qty_uom, c.test_qty_uom) test_qty_uom,
                  nvl(a.test_qty, c.test_qty) test_qty
           INTO   l_test_qty_uom, l_test_qty
           FROM   gmd_spec_tests a,
                  gmd_qc_tests b,
                  gmd_test_methods_b c
           WHERE  a.spec_id = l_spec_id
           AND    a.test_id = b.test_id
           AND    b.test_id = l_test_id.test_id
           AND    b.test_method_id = c.test_method_id;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             SELECT a.test_qty_uom, a.test_qty
             INTO   l_test_qty_uom, l_test_qty
             FROM   gmd_test_methods_b a, gmd_qc_tests b
             WHERE  b.test_id = l_test_id.test_id
             AND    a.test_method_id = b.test_method_id;
          END;



           IF (l_test_qty_uom is NOT NULL) THEN
             UPDATE gmd_test_group_gt
             SET    test_qty = l_test_qty,
                    test_qty_uom = l_test_qty_uom
             WHERE  test_id = l_test_id.test_id;
           END IF;
      END LOOP; --for all the test in temp table
    END IF; --If sample id is not null
    COMMIT;
EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_QC_TESTS_GRP.POPULATE_TEST_GRP_GT' );
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END POPULATE_TEST_GRP_GT;

/*===========================================================================
  FUNCTION  NAME:       update_test_grp
  DESCRIPTION:          This procedure updates the Include flag in the Global
                        temporary table for a given test_id
  PARAMETERS:           In : p_test_id, p_include
  CHANGE HISTORY:       Created         24-MAY-04       RBODDU
===========================================================================*/

PROCEDURE update_test_grp(
                          p_test_id IN NUMBER ,
                          p_include IN VARCHAR2,
                          p_test_qty IN NUMBER,
                          p_test_uom IN VARCHAR2) IS
BEGIN
  UPDATE gmd_test_group_gt SET
   include = p_include,
   test_qty = p_test_qty,
   test_qty_uom = p_test_uom
  WHERE  test_id = p_test_id;
  COMMIT;
END update_test_grp;

END gmd_qc_tests_grp ;

/
