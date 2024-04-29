--------------------------------------------------------
--  DDL for Package Body AHL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UTIL_PKG" AS
/* $Header: AHLUTILB.pls 120.0.12010000.5 2009/06/12 09:39:32 jkjain ship $ */


------------------------------------------
-- Convert messages on stack into table --
------------------------------------------
Procedure ERR_MESG_TO_TABLE (
    x_err_table  OUT NOCOPY  Err_Tbl_Type )  IS

l_msg_count      NUMBER;
l_msg_index_out  NUMBER;
l_msg_data       VARCHAR2(2000);
l_err_rec        Err_Rec_Type;

BEGIN

 -- Standard call to get message count.
l_msg_count := FND_MSG_PUB.Count_Msg;

FOR i IN 1..l_msg_count LOOP
  FND_MSG_PUB.get (
      p_msg_index      => i,
      p_encoded        => FND_API.G_FALSE,
      p_data           => l_msg_data,
      p_msg_index_out  => l_msg_index_out );
  l_err_rec.msg_index := l_msg_index_out;
  l_err_rec.msg_data  := l_msg_data;

  x_err_table(i) := l_err_rec;
END LOOP;

END;

FUNCTION is_pm_installed RETURN VARCHAR2 IS

l_pm_install_flag       VARCHAR2(1);
l_appln_usage_defined   VARCHAR2(30);
l_return_status         VARCHAR2(1) ;

BEGIN

  Get_Appln_Usage(l_appln_usage_defined,l_return_status );

  IF ( l_appln_usage_defined = 'PM')
  THEN
  l_pm_install_flag := 'Y';
  ELSE
  l_pm_install_flag := 'N';
  END IF ;

  RETURN l_pm_install_flag  ;

END is_pm_installed;

-----------------------------------------------
PROCEDURE  Get_Appln_Usage(x_appln_code OUT NOCOPY VARCHAR2,x_return_status OUT NOCOPY VARCHAR2)
AS
BEGIN

  x_appln_code:= rtrim(ltrim(FND_PROFILE.value( 'AHL_APPLN_USAGE' )));
  IF ( x_appln_code IS NULL ) THEN
       Fnd_Message.set_name('AHL', 'AHL_COM_APP_PROF_UI');
       Fnd_Msg_Pub.ADD;
       x_return_status:=FND_API.G_RET_STS_ERROR;
  ELSE
       x_return_status:=FND_API.G_RET_STS_SUCCESS;
  END IF;

END Get_Appln_Usage;

-- pdoki added
-- Start of Comments --
-- Function name : Get_User_Role
--
-- Parameters :
-- p_fnd_function_name Input FND function name.
--
-- Description : This function is used to retrieve the role associated with the current user
FUNCTION Get_User_Role(
   p_function_key   IN    VARCHAR2 := NULL
) RETURN VARCHAR2

IS
l_user_role VARCHAR2(30);

BEGIN

AHL_DEBUG_PUB.debug( 'entering Get_User_Role' );

IF ( upper(p_function_key) = 'AHL_DI_VIEW') THEN
IF (FND_FUNCTION.TEST('AHL_DI_VIEW')) THEN
-- Document Index: View Only User
l_user_role := 'AHL_DI_VIEW';
END IF;
END IF;

IF ( upper(p_function_key) = 'AHL_RM_OPERATIONS_VIEW') THEN
IF (FND_FUNCTION.TEST('AHL_RM_OPERATIONS_VIEW')) THEN
-- Route Management: Operations View Only User
l_user_role := 'AHL_RM_OPERATIONS_VIEW';
END IF;
END IF;

IF ( upper(p_function_key) = 'AHL_RM_ROUTES_VIEW') THEN
IF (FND_FUNCTION.TEST('AHL_RM_ROUTES_VIEW')) THEN
-- Route Management: Routes View Only User
l_user_role := 'AHL_RM_ROUTES_VIEW';
END IF;
END IF;

IF ( upper(p_function_key) = 'AHL_FMP_VIEW') THEN
IF (FND_FUNCTION.TEST('AHL_FMP_VIEW')) THEN
-- Fleet Maintenance Program: View Only User
l_user_role := 'AHL_FMP_VIEW';
END IF;
END IF;

--JKJain starts
IF ( upper(p_function_key) = 'AHL_ALLOW_CREATE_NR_FROM_NR') THEN
IF (FND_FUNCTION.TEST('AHL_ALLOW_CREATE_NR_FROM_NR')) THEN
-- Allow user to create a Non-Routine from the context of another Non-Routine workorder.
l_user_role := 'AHL_ALLOW_CREATE_NR_FROM_NR';
END IF;
END IF;
--JKJain ends

AHL_DEBUG_PUB.debug( l_user_role );

RETURN l_user_role;

EXCEPTION
WHEN OTHERS THEN
IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
fnd_msg_pub.add_exc_msg(p_pkg_name => 'AHL_UTIL_PKG',
p_procedure_name => 'Get_User_Role',
p_error_text => SUBSTR(SQLERRM,1,240));
END IF;
RETURN NULL;

END Get_User_Role;
--pdoki ends

-- JKJain added
-- Start of Comments --
-- Function name : Get_Wip_Eam_Class_Type
-- Description : This function is used to retrieve Class_Type of EAM stored in WIP_CONSTANTS.
--               It will return valuse '6' , for Maintenance Calss Type.

FUNCTION Get_Wip_Eam_Class_Type RETURN NUMBER IS
BEGIN
RETURN  WIP_CONSTANTS.EAM;
END Get_Wip_Eam_Class_Type ;


END AHL_UTIL_PKG;

/
