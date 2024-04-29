--------------------------------------------------------
--  DDL for Package Body EAM_EXECUTION_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_EXECUTION_JSP" AS
/* $Header: EAMEXUJB.pls 115.6 2002/11/22 12:02:09 anmahesh ship $ */
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'EAM_EXECUTION_JSP';
g_debug_sqlerrm VARCHAR2(250);

-- ==========================================================================
-- = FUNCTION  GetOrgId
-- ==========================================================================

  FUNCTION  GetOrgId ( X_org_name  IN VARCHAR2 ) RETURN NUMBER
  IS
    X_org_id     NUMBER;
  BEGIN
    SELECT
            organization_id
      INTO
            X_org_id
      FROM
            hr_organization_units o
     WHERE  name = X_org_name;

    RETURN ( X_org_id );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END  GetOrgId;

-- ==========================================================================
-- = FUNCTION  GetOrgName
-- ==========================================================================

  FUNCTION  GetOrgName ( X_org_id  IN NUMBER ) RETURN VARCHAR2
  IS
    X_org_name    VARCHAR2(240);
  BEGIN
    SELECT
            name
      INTO
            X_org_name
      FROM
            hr_organization_units o
     WHERE
            organization_id = X_org_id;

    RETURN ( X_org_name );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END GetOrgName;

-- format date to string, temperory
  FUNCTION to_time_string( date1 IN DATE) RETURN VARCHAR2
  IS
    -- return if job has mandatory meter reading, wrapper function
    ret VARCHAR2(250);
  BEGIN
    select to_char(date1, 'YYYY-MM-DD HH24:MI:SS')
    into ret
    from dual;

    return ret;
  END to_time_string;

---------------------------------------------------------------
-- Procedure : Get_Encoded_Msg
--    This procedure serves as a wrapper to the function
--    FND_MSG_PUB.Get.  It is needed to access the call from
--    client FORMS.
---------------------------------------------------------------
Procedure Get_Encoded_Msg(p_index	IN   	NUMBER,
			  p_msg_out	IN OUT NOCOPY  VARCHAR2 ) IS
  l_message	VARCHAR2(2000);
BEGIN
  p_msg_out := fnd_msg_pub.get(p_msg_index => p_index,
			       p_encoded   => FND_API.G_FALSE);

END Get_Encoded_Msg;


---------------------------------------------------------------
-- Procedure : Add_Message
--    This procedure serves as a wrapper to the FND_MEG_PUB
--    procedures to add the specified message onto the message
--    stack.
---------------------------------------------------------------
Procedure Add_Message( p_app_short_name	IN	VARCHAR2,
		       p_msg_name	IN	VARCHAR2,
		       p_token1		IN	VARCHAR2 DEFAULT NULL,
		       p_value1		IN	VARCHAR2 DEFAULT NULL,
		       p_token2		IN	VARCHAR2 DEFAULT NULL,
		       p_value2		IN	VARCHAR2 DEFAULT NULL,
		       p_token3		IN	VARCHAR2 DEFAULT NULL,
		       p_value3		IN	VARCHAR2 DEFAULT NULL,
		       p_token4		IN	VARCHAR2 DEFAULT NULL,
		       p_value4		IN	VARCHAR2 DEFAULT NULL,
		       p_token5		IN	VARCHAR2 DEFAULT NULL,
		       p_value5		IN	VARCHAR2 DEFAULT NULL ) IS

BEGIN

  FND_MESSAGE.Set_Name(p_app_short_name, p_msg_name);
  IF (p_token1 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token1, p_value1);
  END IF;
  IF (p_token2 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token2, p_value2);
  END IF;
  IF (p_token3 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token3, p_value3);
  END IF;
  IF (p_token4 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token4, p_value4);
  END IF;
  IF (p_token5 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token5, p_value5);
  END IF;

  FND_MSG_PUB.Add;

END Add_Message;

------------------------------------------------------------------
PROCEDURE Get_Messages
(p_encoded        IN VARCHAR2 := FND_API.G_FALSE,
 p_msg_index      IN NUMBER   := NULL,
 p_msg_count      IN NUMBER   := 0,
 p_msg_data       IN VARCHAR2 := NULL,
 p_data           OUT NOCOPY VARCHAR2,
 p_msg_index_out  OUT NOCOPY NUMBER
)  IS

--l_encoded     BOOLEAN;
l_data        VARCHAR2(2000);
l_msg_index   NUMBER;

BEGIN

  IF p_msg_index IS  NULL THEN
     l_msg_index := FND_MSG_PUB.G_NEXT;
  ELSE
     l_msg_index := p_msg_index;
  END IF;

  IF p_msg_count = 1 THEN
     FND_MESSAGE.SET_ENCODED (p_msg_data);
     p_data := FND_MESSAGE.GET;
  ELSE
    FND_MSG_PUB.get (
    p_msg_index      => l_msg_index,
    p_encoded        => p_encoded,
    p_data           => p_data,
    p_msg_index_out  => p_msg_index_out );
 END IF;

END Get_Messages;

END eam_execution_jsp;

/
