--------------------------------------------------------
--  DDL for Package EGO_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_COMMON_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOAPCCS.pls 120.8 2007/03/23 10:08:26 dsakalle ship $ */


FUNCTION Is_EGO_Installed (
        p_api_version  IN NUMBER
       ,p_release_version IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Prod_Schema (
        p_prod_name       IN  VARCHAR2
) RETURN VARCHAR2;


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
) ;

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
  P_INVENTORY_ITEM_ID IN NUMBER,
  P_ORGANIZATION_ID   IN NUMBER,
  P_ITEM_NUMBER       IN VARCHAR2
);

/*#
    *--------------------------------------------------------------------*
    * R12C new Function for getting the defaulting options.              *
    * This function takes in the option_code as an input and returns the *
    * correspondin option value.                                         *
    * @param OPTION_CODE_IN : option code for which the value is seeked  *
    *--------------------------------------------------------------------*
*/
 FUNCTION GET_OPTION_VALUE (
   OPTION_CODE_IN   IN  VARCHAR2
 )RETURN VARCHAR2;


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
                           p_message   VARCHAR2);

END EGO_COMMON_PVT;


/
