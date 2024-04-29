--------------------------------------------------------
--  DDL for Package Body GMD_TEST_METHODS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_TEST_METHODS_GRP" AS
/* $Header: GMDGMTPB.pls 120.1 2005/07/15 07:06:42 svankada noship $ */

FUNCTION test_method_exist(ptest_method IN VARCHAR2) RETURN BOOLEAN IS
    CURSOR Cur_get_test_mthd(ptest_mthd VARCHAR2) IS
      SELECT test_method_code
       FROM  gmd_test_methods
      WHERE test_method_code = ptest_mthd;
      l_test_method gmd_test_methods.test_method_code%TYPE;
  BEGIN
    IF (ptest_method IS NOT NULL) THEN
      OPEN Cur_get_test_mthd(ptest_method);
      FETCH Cur_get_test_mthd INTO l_test_method;
      IF (Cur_get_test_mthd%FOUND) THEN
        CLOSE Cur_get_test_mthd;
        RETURN TRUE;
      ELSE
        CLOSE Cur_get_test_mthd;
        RETURN FALSE;
      END IF;
    END IF;
  END test_method_exist;

  PROCEDURE Validate_Test_Method_Rec(ptestmthd_rec   IN gmd_test_methods%rowtype,
  				     X_return_status OUT NOCOPY VARCHAR2) IS
  INVALID_TEST_QTY_UOM      EXCEPTION;
  INVALID_DISPLAY_PRECISION EXCEPTION;
  INVALID_REPLICATE_VALUE   EXCEPTION;
  BEGIN
    X_return_Status := FND_API.G_RET_STS_SUCCESS;

    -- Check if test qty or test uom are missing. If one is entered other should exist.

    IF ((ptestmthd_rec.test_qty IS NOT NULL AND ptestmthd_rec.test_qty_uom IS NULL)
         OR (ptestmthd_rec.test_qty IS NULL AND ptestmthd_rec.test_qty_uom IS NOT NULL)) THEN
      RAISE INVALID_TEST_QTY_UOM;
    END IF;

    -- display precision value should be between 0 and 9.

    IF (ptestmthd_rec.display_precision NOT BETWEEN 0 AND 9) THEN
      RAISE INVALID_DISPLAY_PRECISION;
    END IF;

    -- Check if replicate is negative
    IF (ptestmthd_rec.test_replicate < 0) THEN
    	RAISE INVALID_REPLICATE_VALUE;
    END IF;

  EXCEPTION
    WHEN INVALID_TEST_QTY_UOM THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_TEST_QTY_UOM');
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN INVALID_DISPLAY_PRECISION THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_PRECISION');
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;

    WHEN INVALID_REPLICATE_VALUE THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_REPLICATE');
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.G_RET_STS_ERROR;
  END Validate_Test_Method_Rec;


PROCEDURE GET_TEST_DURATION
( p_days          IN  NUMBER,
  p_hours         IN  NUMBER,
  p_mins          IN  NUMBER,
  p_secs          IN  NUMBER,
  x_duration_secs OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2
)
IS

l_duration_secs  NUMBER;
l_return_Status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN


IF p_days IS NULL  AND
   p_hours IS NULL AND
   p_mins IS NULL  AND
   p_secs IS NULL THEN

   l_duration_secs := 0;

 ELSE

   l_duration_secs := 0;

    IF p_days is NOT NULL THEN
       l_duration_secs := l_duration_secs + ( p_days * G_DAYS_SECS) ;
    END IF;

    IF p_hours is NOT NULL THEN
       l_duration_secs := l_duration_secs + ( p_hours * G_HOURS_SECS);
    END IF;

    IF p_mins is NOT NULL THEN
       l_duration_secs := l_duration_secs + ( p_mins * G_MINUTES_SECS );
    END IF;

    IF p_secs is NOT NULL THEN
       l_duration_secs := l_duration_secs + p_secs;
    END IF;

 END IF;

 -- Set Return Parameters

 x_duration_secs := l_duration_secs;
 x_return_status := l_return_status;

EXCEPTION

 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END GET_TEST_DURATION;



END GMD_TEST_METHODS_GRP;

/
