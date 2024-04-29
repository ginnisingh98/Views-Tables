--------------------------------------------------------
--  DDL for Package Body ASO_ORDER_FEEDBACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_ORDER_FEEDBACK_UTIL" AS
/* $Header: asouomfb.pls 115.3 2002/05/21 17:02:03 pkm ship      $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'ASO_ORDER_FEEDBACK_UTIL';
G_USER CONSTANT VARCHAR2(30) := FND_GLOBAL.USER_ID;


-- ---------------------------------------------------------
-- Define Procedures
-- ---------------------------------------------------------

PROCEDURE Check_LookupCode
(
   p_lookup_type     IN VARCHAR2,
   p_lookup_code        IN VARCHAR2,
   p_param_name      IN VARCHAR2,
   p_api_name     IN VARCHAR2
) IS

   l_dummy           VARCHAR2(1);
   CURSOR c1 IS
   SELECT 'x'
   FROM aso_lookups
   WHERE lookup_type = p_lookup_type
   AND   lookup_code = p_lookup_code
   AND enabled_flag = 'Y';
-- AND Trunc(Sysdate) BETWEEN Trunc(Nvl(start_date_active, Sysdate))
--    AND Trunc(Nvl(end_date_active, nvl(start_date_active,Sysdate)));


BEGIN
   OPEN c1;
   FETCH c1 INTO l_dummy;
   IF c1%NOTFOUND THEN
      CLOSE c1;
      FND_MESSAGE.SET_NAME('ASO','ASO_API_ALL_LOOKUP_FAILURE');
      FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
      FND_MESSAGE.SET_TOKEN('LOOKUP_CODE',p_lookup_code);
      FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE',p_lookup_type);
      FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
END Check_LookupCode;

PROCEDURE Check_Reqd_Param
(
   p_var1      IN NUMBER,
   p_param_name   IN VARCHAR2,
   p_api_name  IN VARCHAR2
) IS
BEGIN
   IF (NVL(p_var1,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.SET_NAME('ASO','ASO_API_ALL_MISSING_PARAM');
      FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
      FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
END Check_Reqd_Param;


PROCEDURE Check_Reqd_Param
(
   p_var1      IN VARCHAR2,
   p_param_name   IN VARCHAR2,
   p_api_name  IN VARCHAR2
) IS
BEGIN
   IF (NVL(p_var1,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) THEN
    FND_MESSAGE.SET_NAME('ASO','ASO_API_ALL_MISSING_PARAM');
    FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
    FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
   END IF;
END Check_Reqd_Param;

PROCEDURE Check_Reqd_Param
(
   p_var1      IN DATE,
   p_param_name   IN VARCHAR2,
   p_api_name  IN VARCHAR2
) IS
BEGIN
   IF (NVL(p_var1,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE) THEN
      FND_MESSAGE.SET_NAME('ASO','ASO_API_ALL_MISSING_PARAM');
      FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
      FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
END Check_Reqd_Param;


END ASO_ORDER_FEEDBACK_UTIL;

/
