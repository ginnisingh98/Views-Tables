--------------------------------------------------------
--  DDL for Package FND_GRANTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_GRANTS_PKG" AUTHID CURRENT_USER as
/* $Header: AFSCGNTS.pls 115.23 2003/12/16 02:49:37 tmorrow ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_GRANT_GUID in RAW,
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_ID in NUMBER,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_ID in NUMBER,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PARAMETER1 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER2 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER3 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER4 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER5 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER6 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER7 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER8 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER9 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER10 IN VARCHAR2 DEFAULT NULL,
  X_CTX_SECGRP_ID in NUMBER default -1,
  X_CTX_RESP_ID in NUMBER default -1,
  X_CTX_RESP_APPL_ID in NUMBER default -1,
  X_CTX_ORG_ID in NUMBER default -1,
  X_NAME IN VARCHAR2 DEFAULT NULL,
  X_DESCRIPTION IN VARCHAR2 DEFAULT NULL
);

procedure LOCK_ROW (
  X_GRANT_GUID in RAW,
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_ID in NUMBER,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_ID in NUMBER,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_PARAMETER1 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER2 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER3 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER4 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER5 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER6 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER7 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER8 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER9 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER10 IN VARCHAR2 DEFAULT NULL,
  X_CTX_SECGRP_ID in NUMBER default -1,
  X_CTX_RESP_ID in NUMBER default -1,
  X_CTX_RESP_APPL_ID in NUMBER default -1,
  X_CTX_ORG_ID in NUMBER default -1,
  X_NAME IN VARCHAR2 DEFAULT NULL,
  X_DESCRIPTION IN VARCHAR2 DEFAULT NULL
);

procedure UPDATE_ROW (
  X_GRANT_GUID in RAW,
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_ID in NUMBER,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_ID in NUMBER,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PARAMETER1 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER2 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER3 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER4 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER5 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER6 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER7 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER8 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER9 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER10 IN VARCHAR2 DEFAULT NULL,
  X_CTX_SECGRP_ID in NUMBER default -1,
  X_CTX_RESP_ID in NUMBER default -1,
  X_CTX_RESP_APPL_ID in NUMBER default -1,
  X_CTX_ORG_ID in NUMBER default -1,
  X_NAME IN VARCHAR2 DEFAULT '*NOTPASSED*',      /* If you pass name, */
  X_DESCRIPTION IN VARCHAR2 DEFAULT '*NOTPASSED*'/* must pass description*/

);

/* This version is obsolete.  Use overloaded version below */
procedure LOAD_ROW (
  X_GRANT_GUID in VARCHAR2,
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_NAME in VARCHAR2,
  X_START_DATE in VARCHAR2,
  X_END_DATE in VARCHAR2,
  X_OBJ_NAME in VARCHAR2,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_NAME in VARCHAR2,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);

procedure DELETE_ROW (
  X_GRANT_GUID in RAW
);


PROCEDURE grant_function
  (
   p_api_version     IN  NUMBER,
   p_menu_name       IN  VARCHAR2,
   p_object_name     IN  VARCHAR2,
   p_instance_type   IN  VARCHAR2,
   p_instance_set_id     IN  NUMBER   DEFAULT NULL,
   p_instance_pk1_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_grantee_type   IN  VARCHAR2 DEFAULT 'USER',
   p_grantee_key    IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   p_program_name   IN  VARCHAR2 DEFAULT NULL,
   p_program_tag    IN  VARCHAR2 DEFAULT NULL,
   x_grant_guid     OUT NOCOPY RAW,
   x_success        OUT NOCOPY VARCHAR, /* Boolean */
   x_errorcode      OUT NOCOPY NUMBER,
   p_parameter1     IN  VARCHAR2 DEFAULT NULL,
   p_parameter2     IN  VARCHAR2 DEFAULT NULL,
   p_parameter3     IN  VARCHAR2 DEFAULT NULL,
   p_parameter4     IN  VARCHAR2 DEFAULT NULL,
   p_parameter5     IN  VARCHAR2 DEFAULT NULL,
   p_parameter6     IN  VARCHAR2 DEFAULT NULL,
   p_parameter7     IN  VARCHAR2 DEFAULT NULL,
   p_parameter8     IN  VARCHAR2 DEFAULT NULL,
   p_parameter9     IN  VARCHAR2 DEFAULT NULL,
   p_parameter10    IN  VARCHAR2 DEFAULT NULL,
   p_ctx_secgrp_id    IN NUMBER default -1,
   p_ctx_resp_id      IN NUMBER default -1,
   p_ctx_resp_appl_id IN NUMBER default -1,
   p_ctx_org_id       IN NUMBER default -1,
   p_name             IN VARCHAR2 DEFAULT NULL,
   p_description      IN VARCHAR2 DEFAULT NULL

  );
    -- Start OF comments
    -- API name  : Grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Grant a Menu of functions on object instances to a Party.
    --             If this operation fails then the grant is not
    --             done and error code is returned. Nothing ever commits.
    --             Note: the name of this routine should probably be
    --             grant_menu() but it is left as is for legacy reasons.
    --
    -- For a more thorough discussion of the grants table and what the
    -- various columns mean, see the internal oracle document
    -- http://www-apps.us.oracle.com/atg/plans/r115x/datasec.txt
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure (currently 1.0)
    --
    --             p_menu_name        IN  VARCHAR2 (required)
    --             menu to be granted
    --
    --             p_object_name      IN  VARCHAR2 (required)
    --             object on which the menu is granted
    --             from fnd_objects table.
    --
    --             p_instance_type  IN  VARCHAR2 (required)
    --             instance type in grants table-
    --               'INSTANCE' or 'SET'
    --
    --             p_instance_set_id IN VARCHAR2 (optional)
    --                This must be filled in if p_instance_type='SET'.
    --                NULL should be passed  if p_instance_type='INSTANCE'.
    --                This is a FK to the FND_OBJECT_INSTANCE_SETS table
    --                and indicates which instance set is granted.
    --
    --             p_instance_pk[1..5]_value       IN  NUMBER (optional)
    --                Must be filled in if p_instance_type = 'INSTANCE'
    --                NULL should be passed if p_instance_type='SET'.
    --                 These are the primary keys of the object instance
    --                 granted.  The order of the PKs must match the order
    --                 they were defined in FND_OBJECTS.  NULLs should
    --                 be passed for the higher numbered args with no PKs.
    --
    --             p_grantee_type         IN  VARCHAR2 (optional)
    --                 grantee type for which the menu is granted.
    --                 'USER', 'GROUP', 'GLOBAL'
    --
    --             p_grantee_key         IN  VARCHAR2 (required)
    --                 User or group that gets the grant,
    --                 from FND_USER or another table that the view
    --                 WF_ROLES is based on.
    --
    --             p_program_name  IN  VARCHAR2 (optional)
    --                 name of the program that handles grant.  This is used
    --                 So that each product that has UIs over grants will
    --                 know which grants it is responsible for.
    --
    --             p_program_tag  IN  VARCHAR2 (optional)
    --                 tag used by the program that handles grant.  This can
    --                 be used at the discretion of the program that creates
    --                 the grant.
    --
    --             p_parameter[1-10]    IN  NUMBER (optional)
    --                Should be filled in if p_instance_type = 'SET'
    --                and the predicate of the instance set pointed to by
    --                p_instance_set_name references the parameter as
    --                G.PARAMETER[1-10].
    --                NULL should be passed otherwise.
    --                These are parameters for the instance set.  For
    --                example you might have an instance set
    --                "Profiles by Category" whose predicate is
    --                "X.CATEGORY = G.PARAMETER1".  Then if you put "ADMIN"
    --                in to P_PARAMETER1, the instance set would cover
    --                profiles whose CATEGORY is "ADMIN".
    --
    --             p_ctx_secgrp_id IN NUMBER (optional)
    --                 if grant applies to all security groups, pass -1
    --                 if grant applies to only a particular secgrp, pass id.
    --
    --             p_ctx_resp_id IN NUMBER (optional)
    --                 if grant applies to all responsibilities, pass -1
    --                 if grant applies to only a particular resp, pass id.
    --
    --             p_ctx_resp_appl_id IN NUMBER (optional)
    --                 if grant applies to all responsibilities, pass -1
    --                 if grant applies to only a particular resp, pass
    --                    application id of that resp.
    --
    --             p_ctx_org_id IN NUMBER (optional)
    --                 if grant applies to all organizations, pass -1
    --                 if grant applies to only a particular org, pass org id.
    --
    --             p_name in varchar2 (optional)
    --                 User-friendly name of grant.  To be used in UIs.
    --
    --             p_description in varchar2 (optional)
    --                 User-friendly description of grant.  To be used in UIs.
    --
    --     OUT  :  x_grant_guid OUT RAW
    --                returns the guid of the grant that was created (or found)
    --
    --             X_success    OUT VARCHAR(1)
    --               'T' if everything worked correctly
    --               'F' if there was a failure.  If 'F'
    --                is returned, there will either be an error
    --                message on the FND_MESSAGE stack which
    --                can be retrieved with FND_MESSAGE.GET_ENCODED(),
    --                or there will be a PL/SQL exception raised.
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the errorcode
    --                check only if x_success = F.
    --                Positive error codes are "expected"
    --                Negative error codes are "unexpected".
    --
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ---------------------------------------------------------------

  ---------------------------------------------------------------
  PROCEDURE revoke_grant
  (
   p_api_version    IN  NUMBER,
   p_grant_guid       IN  raw,
   x_success        OUT NOCOPY VARCHAR2, /* Boolean */
   x_errorcode      OUT NOCOPY NUMBER
  );

 -- Start OF comments
    -- API name  : Revoke_Grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Revoke a Party's function on object instances.
    --             If this operation fails then the revoke is not
    --             done and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure (currently 1.0)
    --
    --             p_grant_guid       IN  RAW
    --
    --
    --     OUT  :
    --             X_success    OUT VARCHAR(1)
    --               'T' if everything worked correctly
    --               'F' if there was a failure.  If FALSE
    --                is returned, there will either be an error
    --                message on the FND_MESSAGE stack which
    --                can be retrieved with FND_MESSAGE.GET_ENCODED(),
    --                or there will be a PL/SQL exception raised.
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the errorcode
    --                check only if x_success = F.
    --                Positive error codes are "expected"
    --                Negative error codes are "unexpected".
    --
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

   ----------------------------------------------------------------


  /* This version of update_grant is obsoleted. */
  /* Please use overloaded update_grant below which takes name and desc.*/
  PROCEDURE update_grant  /* ***OBSOLETED for backward compatibility only */
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  raw,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_success        OUT NOCOPY VARCHAR2
  );


  /* This is the overloaded version of update_grant that should be used in */
  /* new code. */
  PROCEDURE update_grant
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  raw,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   p_name           IN VARCHAR2,
   p_description    IN VARCHAR2,
   x_success        OUT NOCOPY VARCHAR2
  );
-- Start OF comments
  -- API name : UPDATE_GRANT
  -- TYPE : Public
  -- Pre-reqs : None
  -- FUNCTION :
  --
  -- Parameters:
  --     IN    : p_api_version      IN  NUMBER (required)
  --             API Version of this procedure (currently 1.0)
  --
  --             p_grant_guid       IN  RAW (required)
  --             grant guid
  --
  --             p_start_date       IN  DATE  (required)
  --             start date for the  grant identified by grant id.
  --
  --             p_end_date       IN  DATE  (required)
  --             end date for the  grant identified by grant id.
  --
  --             p_name in varchar2 (optional)
  --                 User-friendly name of grant.  To be used in UIs.
  --
  --             p_description in varchar2 (optional)
  --                 User-friendly description of grant.  To be used in UIs.
  --
  --     OUT  :
  --             X_success    OUT VARCHAR(1)
  --               'T' if everything worked correctly
  --               'F' if there was a failure.  If FALSE
  --                is returned, there will either be an error
  --                message on the FND_MESSAGE stack which
  --                can be retrieved with FND_MESSAGE.GET_ENCODED()
  --                or there will be a PL/SQL exception raised.
  --
  --
  -- Version: Current Version 1.0
  -- Previous Version : None
  -- Notes :
  --
  -- END OF comments

  ------------------------------------------------------------------
PROCEDURE lock_grant
  (
   p_grant_guid       IN  raw,
   p_menu_id        IN  NUMBER,
   p_object_id      IN  number,
   p_instance_type IN  varchar2,
   p_instance_set_id in number,
   p_instance_pk1_value   IN  VARCHAR2,
   p_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_grantee_type    in varchar2 default 'USER',
   p_grantee_key       IN  varchar2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   p_program_name   IN  VARCHAR2,
   p_program_tag    IN  VARCHAR2,
   p_parameter1     IN  VARCHAR2 DEFAULT NULL,
   p_parameter2     IN  VARCHAR2 DEFAULT NULL,
   p_parameter3     IN  VARCHAR2 DEFAULT NULL,
   p_parameter4     IN  VARCHAR2 DEFAULT NULL,
   p_parameter5     IN  VARCHAR2 DEFAULT NULL,
   p_parameter6     IN  VARCHAR2 DEFAULT NULL,
   p_parameter7     IN  VARCHAR2 DEFAULT NULL,
   p_parameter8     IN  VARCHAR2 DEFAULT NULL,
   p_parameter9     IN  VARCHAR2 DEFAULT NULL,
   p_parameter10    IN  VARCHAR2 DEFAULT NULL,
   p_ctx_secgrp_id    IN NUMBER default -1,
   p_ctx_resp_id      IN NUMBER default -1,
   p_ctx_resp_appl_id IN NUMBER default -1,
   p_ctx_org_id       IN NUMBER default -1,
   p_name             IN VARCHAR2 default NULL,
   p_description      IN VARCHAR2 default NULL
  ) ;
-- Start OF comments
  -- API name : LOCK_GRANT
  -- TYPE : Public
  -- Pre-reqs : None
  -- FUNCTION :
  --
  -- Parameters:
  --     IN    : p_api_version      IN  NUMBER (required)
  --             API Version of this procedure (currently 1.0)
  --
  --             p_grant_guid       IN  RAW (required)
  --             grant guid
  --             p_menu_id          IN  NUMBER (required)
  --             menu id
  --             p_object_id        IN  NUMBER(required)
  --             object id
  --             p_instance_type  IN  VARCHAR2 (required)
  --             instance type in grants table- 'INSTANCE' or 'SET'
  --             p_instance_set_id  IN  VARCHAR2 (required)
  --             instance set if instance_type='SET'
  --             p_instance_pk[1..5]_value    IN  VARCHAR(required)
  --             key columns of grant to lock, if instance_type='INSTANCE'
  --             p_grantee_type         IN  VARCHAR2 (optional)
  --             grantee type: 'GROUP', 'USER', 'GLOBAL'
  --             p_grantee_key         IN  NUMBER (required)
  --             grantee key (FK to wf_roles.name).
  --             p_start_date       IN  DATE  (required)
  --             start date for the  grant
  --             p_end_date       IN  DATE  (required)
  --             end date for the  grant
  --             p_program_name  IN  VARCHAR2 (required)
  --             name of the program that handles grant
  --             p_program_tag  IN  VARCHAR2 (required)
  --             tag used by the program that handles grant
  --             p_ctx_... columns IN VARCHAR2 (optional)
  --             see ctx column descriptions in GRANT_FUNCTION.
  --             p_name IN VARCHAR2 (optional)
  --             user friendly name
  --             p_description IN VARCHAR2 (optional)
  --             user friendly description
------------------------------------------------------------------

 -- fill_in_orig_columns
 --    This routine is mostly for AOL internal use by this loader itself;
 --    it fills in the columns grantee_orig_system and
 --    grantee_orig_system_id from the grantee_key.
 procedure fill_in_orig_columns(p_grant_guid IN  raw);

 -- fill_in_missing_orig_columns
 --    This routine is mostly for AOL internal use by this loader itself;
 --    it fills in the columns grantee_orig_system and
 --    grantee_orig_system_id from the grantee_key for all grants that
 --    are missing them.
 procedure fill_in_missing_orig_columns;

/* This is the newest version.  Use instead of overloaded version above */
procedure LOAD_ROW (
  X_GRANT_GUID in VARCHAR2, /* For new guid: select sys_guid() from dual */
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_NAME in VARCHAR2,
  X_START_DATE in VARCHAR2,
  X_END_DATE in VARCHAR2,
  X_OBJ_NAME in VARCHAR2,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_NAME in VARCHAR2,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_PARAMETER1 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER2 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER3 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER4 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER5 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER6 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER7 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER8 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER9 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER10 IN VARCHAR2 DEFAULT NULL,
  X_CTX_SECURITY_GROUP_KEY in VARCHAR2 default '*GLOBAL*',
  X_CTX_RESP_KEY in VARCHAR2 default '*GLOBAL*',
  X_CTX_RESP_APP_SHORT_NAME in VARCHAR2 default '*GLOBAL*',
  X_CTX_ORGANIZATION in VARCHAR2 default '*GLOBAL*',
  X_NAME IN VARCHAR2 DEFAULT '*NOTPASSED*',
  X_DESCRIPTION IN VARCHAR2 DEFAULT '*NOTPASSED*'
);

PROCEDURE delete_grant(
                       p_grantee_type        IN VARCHAR2 DEFAULT NULL,
                       p_grantee_key         IN VARCHAR2 DEFAULT NULL,
                       p_object_name         IN VARCHAR2 DEFAULT NULL,
                       p_instance_type       IN VARCHAR2 DEFAULT NULL,
                       p_instance_set_id     IN NUMBER   DEFAULT NULL,
                       p_instance_pk1_value  IN VARCHAR2 DEFAULT NULL,
                       p_instance_pk2_value  IN VARCHAR2 DEFAULT NULL,
                       p_instance_pk3_value  IN VARCHAR2 DEFAULT NULL,
                       p_instance_pk4_value  IN VARCHAR2 DEFAULT NULL,
                       p_instance_pk5_value  IN VARCHAR2 DEFAULT NULL,
                       p_menu_name           IN VARCHAR2 DEFAULT NULL,
                       p_program_name        IN VARCHAR2 DEFAULT NULL,
                       p_program_tag         IN VARCHAR2 DEFAULT NULL,
                       x_success             OUT NOCOPY VARCHAR,
                       x_errcode             OUT NOCOPY NUMBER);
 -- Start of comments:
 -- API Name : Delete_Grant
 -- Type: Public
 -- Pre-reqs: None
 -- Function: Delete the grants on object instances based on the parameters
 --           passed in.
 -- Parameters:
 --      Passing NULL to any parameter means "all":
 --        "don't consider this value when deciding which rows to delete"
 --      Passing a specific value means you want to delete only rows
 --        with that specific value.
 --      Passing '*NULL*' means you want to delete rows where the value
 --        is actually NULL.
 --
 --      If the caller passes NULL for all values, to delete all
 --      the records in FND_GRANTS, this procedure will raise an exception,
 --      not delete anything, and pass out a failure status.
 --
 --      p_grantee_type     IN VARCHAR2 (optional)
 --        The grantee type, either 'USER', 'GROUP', or 'GLOBAL'
 --        See above for meaning of NULL and '*NULL*'
 --
 --      p_grantee_key      IN VARCHAR2 (optional)
 --        User or group that is granted to.
 --        Pass NULL (meaning all) if grantee_key is 'GLOBAL'
 --        See above for meaning of NULL and '*NULL*'
 --        This is required (NULL not allowed except for GLOBAL)
 --        if p_grantee_type is passed.
 --
 --      p_object_name      IN VARCHAR2 (optional)
 --        Object of the grant.
 --        See above for meaning of NULL and '*NULL*'
 --        Required (not NULL or '*NULL*') if p_instance_type is passed.
 --
 --      p_instance_type    IN VARCHAR2 (optional)
 --        Instance type, either 'INSTANCE' or 'SET'
 --        See above for meaning of NULL and '*NULL*'
 --
 --      p_instance_set_id  IN NUMBER (optional)
 --        A FK to FND_OBJECT_INSTANCE_SETS which indicates the instance
 --        set to be deleted.
 --        This value is required (NULL or '*NULL*' not allowed)
 --        if p_instance_type is 'SET'.
 --        See above for meaning of NULL and '*NULL*'
 --
 --      p_instance_pk[1...5]_value IN VARCHAR2 (optional)
 --        If p_instance_type is 'INSTANCE' then
 --        these values indicate the instance PK values to match.
 --        See above for meaning of NULL and '*NULL*'
 --
 --      p_menu_name IN VARCHAR2 (optional)
 --        Menu to be deleted.
 --        See above for meaning of NULL and '*NULL*'
 --
 --      p_program_name  IN VARCHAR2 (optional)
 --        Name of the program.
 --        See above for meaning of NULL and '*NULL*'
 --
 --      p_program_tag   IN VARCHAR2 (optional)
 --        Tag used by the program that processes the grant.
 --        See above for meaning of NULL and '*NULL*'
 --
 --      x_success       OUT VARCHAR (required)
 --        Returns 'T' if successful, else 'F'.
 --        If FALSE
 --        is returned, there will either be an error
 --        message on the FND_MESSAGE stack which
 --        can be retrieved with FND_MESSAGE.GET_ENCODED(),
 --        or there will be a PL/SQL exception raised.
 --
 --      X_ErrorCode        OUT NUMBER
 --        check only if x_success = F.
 --        Positive error codes are "expected"
 --        Negative error codes are "unexpected".
 --
 --      x_errcode       OUT VARCHAR (required)
 --
 -- Examples:
 --
 -- 1. Delete all grants for a specific responsibility.
 --
 --        FND_GRANTS_DELETE_PKG.delete_grant(
 --              p_grantee_type          => 'GROUP',
 --              p_grantee_key           => 'FND_RESP101:50234',
 --              x_success               => l_success,
 --              x_errcode               => l_errcode
 --             );
 --
 -- 2. Delete all grants for a specific responsibility and menu function for
 --    all object instances having only 2 primary key values, one value being
 --    '1' and the other NULL.
 --
 --        FND_GRANTS_DELETE_PKG.delete_grant(
 --              p_grantee_type          => 'GROUP',
 --              p_grantee_key           => 'FND_RESP101:50234',
 --              p_object_name           => 'FSG_ROW_SET',
 --              p_instance_type         => 'INSTANCE',
 --              p_instance_pk1_value    => '1',
 --              p_instance_pk2_value    => '*NULL*',
 --              p_menu_name             => 'FSG_ROW_SET_V',
 --              p_program_name          => NULL,
 --              p_program_tag           => NULL,
 --              x_success               => l_success,
 --              x_errcode               => l_errcode
 --             );
 --
 --
 --  This routine is created and maintained by GL.
 --  Created 07/09/02 by chunyan.ma@oracle.com.
 --  GL Contacts: chunyan.ma@oracle.com, kalpana.vora@oracle.com
 --  Reviewed by Tom Morrow.
 --
 --

/* CONVERT_NULLS- For install time use only, not a */
/* runtime routine.  This routine will convert NULL to '*NULL*' in the */
/* columns INSTANCE_PKX_VALUE in the table FND_GRANTS. */
/* The reason for this routine is that we decided to have those columns be */
/* non-NULL in order to speed up queries that go against different numbers */
/* of pk columns.  This should be run once at patch application time and */
/* should never need to be run again.  This will be included in the ATG */
/* data security patch. */
/* Returns the number of rows converted. */
function CONVERT_NULLS return NUMBER;


end FND_GRANTS_PKG;

 

/
