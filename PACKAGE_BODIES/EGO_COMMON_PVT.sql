--------------------------------------------------------
--  DDL for Package Body EGO_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_COMMON_PVT" AS
/* $Header: EGOAPCCB.pls 120.13 2007/03/23 10:09:17 dsakalle ship $ */


G_PKG_NAME                               CONSTANT VARCHAR2(30) := 'EGO_COMMON_PVT';


FUNCTION Is_EGO_Installed (
        p_api_version  IN NUMBER
        ,p_release_version IN VARCHAR2
) RETURN VARCHAR2 IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Is_APC_Installed';

  l_ego_installed        VARCHAR2(1);
  l_status               VARCHAR2(1);
BEGIN

   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Bug 4958641
   -- Removed the 'EGO_INSTALLED_PVT' package existance check for R12
   -- R12 release is single APPS delivery
   -- So all the package objects are expected to be available in the install

   SELECT STATUS
   INTO l_status
   FROM FND_PRODUCT_INSTALLATIONS
   WHERE APPLICATION_ID = '431';

   IF l_status = 'I' THEN
      RETURN('T');
   ELSE
     RETURN('F');
   END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN('F');
   WHEN OTHERS THEN
        RETURN('F');

END Is_EGO_Installed;


--------------------------------------------------------------------------------
-- This function takes a product name and returns its associated schema name. --
--------------------------------------------------------------------------------

FUNCTION Get_Prod_Schema (
  p_prod_name            IN  VARCHAR2
) RETURN VARCHAR2 IS

  l_installed                BOOLEAN;
  l_status                   VARCHAR2(1);
  l_industry                 VARCHAR2(1);
  l_schema                   VARCHAR2(30);

BEGIN

  l_installed := FND_INSTALLATION.Get_App_Info (p_prod_name, l_status, l_industry, l_schema);
  RETURN l_schema;

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END Get_Prod_Schema;

/*#
*------------------------------------------------------------------------*
* This procedure updates the profile value EGO_USER_ORGANIZATION_CONTEXT *
* for the current user. Returns S is successful.                         *
* If any other profile id is passed, this API returns U.                 *
* @param P_PROFILE_OPTION_ID: Profile Id                                 *
* @param P_PROFILE_OPTION_VALUE: Profile Value                           *
* @return X_RETURN_STATUS: Return Status. U- Unsuccessful. S- Success    *
* @return X_MSG_DATA: Message indicating wat went wrong incase of U      *
*------------------------------------------------------------------------*
*/
PROCEDURE SAVE_USR_ORG_CTX_PROF_VAL (
  P_PROFILE_OPTION_ID       IN NUMBER
 ,P_PROFILE_OPTION_VALUE    IN VARCHAR2
 ,P_MODE                    IN VARCHAR2
 ,X_RETURN_STATUS   OUT NOCOPY VARCHAR2
 ,X_MSG_DATA        OUT NOCOPY VARCHAR2
)
IS
  L_PROFILE_OPTION_NAME        VARCHAR2(80);
  L_FND_RETURN_STATUS          BOOLEAN;
BEGIN

  X_RETURN_STATUS := 'S';

  --first get the profile option name given the profile option id
  SELECT PROFILE_OPTION_NAME INTO L_PROFILE_OPTION_NAME
    FROM FND_PROFILE_OPTIONS
   WHERE PROFILE_OPTION_ID = P_PROFILE_OPTION_ID;


  IF(P_MODE = 'delete') THEN
    X_RETURN_STATUS := 'U';
    FND_MESSAGE.SET_NAME('EGO', 'EGO_PROF_DELETE_NOT_SUP');
    X_MSG_DATA := FND_MESSAGE.GET;
    RETURN;
  END IF;

  --check if the profile option passed in is EGO_USER_ORGANIZATION_CONTEXT
  --If not, set return_status to U and message stating update of the passed in
  --profile option is not allowed.
  IF(L_PROFILE_OPTION_NAME <> 'EGO_USER_ORGANIZATION_CONTEXT') THEN
    X_RETURN_STATUS := 'U';
    IF(P_MODE = 'update') THEN
      FND_MESSAGE.SET_NAME('EGO', 'EGO_PROF_UPDATE_NOT_SUP');
      FND_MESSAGE.SET_TOKEN('PROFILE_NAME', L_PROFILE_OPTION_NAME);
      X_MSG_DATA := FND_MESSAGE.GET;
    END IF;
    IF(P_MODE = 'insert') THEN
      FND_MESSAGE.SET_NAME('EGO', 'EGO_PROF_INSERT_NOT_SUP');
      FND_MESSAGE.SET_TOKEN('PROFILE_NAME', L_PROFILE_OPTION_NAME);
      X_MSG_DATA := FND_MESSAGE.GET;
    END IF;
    RETURN;
  END IF;

  --now this is the profile we need to update. so call FND API to do that.
  L_FND_RETURN_STATUS := FALSE;
  L_FND_RETURN_STATUS := FND_PROFILE.SAVE_USER( L_PROFILE_OPTION_NAME
                                               ,P_PROFILE_OPTION_VALUE
                                              );
  IF(L_FND_RETURN_STATUS) THEN
    X_RETURN_STATUS := 'S';
  ELSE
    X_RETURN_STATUS := 'U';
    FND_MESSAGE.SET_NAME('EGO', 'EGO_PROFILE_UPDATE_FAILED');
    FND_MESSAGE.SET_TOKEN('PROFILE_NAME', L_PROFILE_OPTION_NAME);
    X_MSG_DATA := FND_MESSAGE.GET;
  END IF;

END SAVE_USR_ORG_CTX_PROF_VAL;

/*#
*------------------------------------------------------------------------*
* This procedure calls Change Management procedure to cancel any NIR     *
* associated with an item being deleted. It is called from               *
* BOM_DELETE_GROUPS_API.INVOKE_EVENTS.                                   *
* @param P_INVENTORY_ITEM_ID: Id of the item being deleted.              *
* @param P_ORGANIZATION_ID: Organization Id from which the item is being *
*                           deleted.Profile Value                        *
* @param P_ITEM_NUMBER: Item Number of the item being deleted.           *
*------------------------------------------------------------------------*
*/
  PROCEDURE CANCEL_NIR_FOR_DELETE_ITEM (
     P_INVENTORY_ITEM_ID IN NUMBER
    ,P_ORGANIZATION_ID   IN NUMBER
    ,P_ITEM_NUMBER       IN VARCHAR2
    )
  IS
    l_nir_cancel_status VARCHAR2(10);
    l_cancel_comment    VARCHAR2(2000);
  BEGIN

    IF(P_INVENTORY_ITEM_ID IS NOT NULL AND P_INVENTORY_ITEM_ID IS NOT NULL) THEN

      FND_MESSAGE.SET_NAME('EGO', 'EGO_CANCELLED_BY_DELETE');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME', P_ITEM_NUMBER);
      l_cancel_comment := FND_MESSAGE.GET;

      EXECUTE IMMEDIATE
        'BEGIN                                             ' ||
        'ENG_NIR_UTIL_PKG.CANCEL_NIR_FOR_ITEM              ' ||
        ' (                                                ' ||
        '   p_item_id           => :P_INVENTORY_ITEM_ID ,  ' ||
        '   p_org_id            => :P_ORGANIZATION_ID ,    ' ||
        '   p_auto_commit       => FND_API.G_FALSE ,       ' ||
        '   p_wf_user_id        => FND_GLOBAL.user_id ,    ' ||
        '   p_fnd_user_id       => FND_GLOBAL.login_id ,   ' ||
        '   p_cancel_comments   => :l_cancel_comment,      ' ||
        '   p_check_security    => FALSE,                  ' ||
        '   x_nir_cancel_status => :l_nir_cancel_status    ' ||
        ' );                                               ' ||
        ' END;                                             '
      USING IN P_INVENTORY_ITEM_ID, IN P_ORGANIZATION_ID, IN l_cancel_comment, OUT l_nir_cancel_status;

    END IF; --IF(P_INVENTORY_ITEM_ID IS NOT NULL AND P_INVENTORY_ITEM_ID IS NOT NULL)

    EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END CANCEL_NIR_FOR_DELETE_ITEM;

/*#
    *--------------------------------------------------------------------*
    * R12C new Function for getting the defaulting options.              *
    * This function takes in the option_code as an input and returns the *
    * correspondin option value.                                         *
    * @param OPTION_CODE_IN : option code for which the value is seeked  *
    *--------------------------------------------------------------------*
*/
  FUNCTION GET_OPTION_VALUE(OPTION_CODE_IN IN VARCHAR2) RETURN VARCHAR2 IS

  return_value VARCHAR2(30);

  BEGIN

   SELECT OPTION_VALUE
   INTO RETURN_VALUE
   FROM EGO_DEFAULT_OPTIONS
   WHERE OPTION_CODE = OPTION_CODE_IN;

   RETURN return_value;

  EXCEPTION
  WHEN others THEN
    RETURN null;

  END GET_OPTION_VALUE;

  /*
  * This procedure is used to write the debug messages into FND_LOG
  * If this is called from within a concurrent program, the request_id
  * will be prepended in the message.
  * @param p_log_level: log level, a constant from FND_LOG.
  *                     If passed null, then FND_LOG.LEVEL_STATEMENT
  *                     will be used for logging.
  * @param p_module: Name of the calling module
  *                  for eg. EGO_IMPORT_PVT.Resolve_Child_Entities
  * @param p_message: Message text
  */
  PROCEDURE WRITE_DIAGNOSTIC(p_log_level NUMBER DEFAULT NULL,
                             p_module    VARCHAR2,
                             p_message   VARCHAR2)
  IS
    l_request_id        NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_log_level         NUMBER := NVL(p_log_level, FND_LOG.LEVEL_STATEMENT);
    l_message           VARCHAR2(32000);
  BEGIN
    IF l_request_id IS NOT NULL AND l_request_id > 0 THEN
      l_message := '[Request ID=' || l_request_id || ']- ' || p_message;
    ELSE
      l_message := p_message;
    END IF;

    IF ( l_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING( l_log_level, p_module, l_message );
    END IF;
  END WRITE_DIAGNOSTIC;


END EGO_COMMON_PVT;


/
