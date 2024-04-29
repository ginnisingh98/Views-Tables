--------------------------------------------------------
--  DDL for Package BIS_DELEGATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DELEGATION_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPDLGS.pls 120.0 2005/07/21 23:19:31 appldev noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.0=120.0):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVPARS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This is the Delegation API Pkg. for PMV.                          |
REM |                                                                       |
REM | HISTORY                                                               |
REM | jrhyde   06/25/05    Created   Enh 4325431                            |
REM |                                                                       |
REM +=======================================================================+
*/

  PROCEDURE grant_delegation
    ( p_delegate_type                IN VARCHAR2
     ,p_grantee_key                  IN VARCHAR2
     ,p_instance_pk1_value           IN VARCHAR2
     ,p_instance_pk2_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk3_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk4_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk5_value           IN VARCHAR2 DEFAULT NULL
     ,p_start_date                   IN DATE DEFAULT NULL
     ,p_end_date                     IN DATE DEFAULT NULL
     ,p_menu_name                    IN VARCHAR2
     ,x_grant_guid                   OUT NOCOPY RAW /*fnd_grants pk*/
     ,x_success                      OUT NOCOPY VARCHAR /* Boolean */
     ,x_errorcode                    OUT NOCOPY VARCHAR2
    );
 -- Start of comments
    -- API name  : Grant_Delegate_Function
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Grant delegate access to function
    --             Validates all parameters
    --             If a row already exists attempts to update the row with the
    --             new date range
    --
    -- Exceptions:
    --
    --  INVALID_DATES
    --             Date Rules are:
    --             1. - Start Date <= End Date
    --             2. - Start Date and hence End Date >= TRUNC(sysdate)
    --             NOTE:
    --             - Start Date Defaulted to NULL evaluates to TRUNC(SYSDATE)
    --             - End Date defaulted to NULL evaluates to "End of Time"
    --             also see notes on parameters p_start_date and p_end_date
    --
    -- INVALID_DELEGATE_TYPE
    --             see notes on parameter p_delegate_type below
    --
    -- INVALID_FND_OBJECT
    --             fnd_object record associated with delegate type does not
    --             exist
    --             or the object defined in fnd_objects used to do validate
    --             the grantee parameter does not function
    --
    -- INVALID_GRANTEE
    --             see notes on parameter p_grantee_key below
    --
    -- INVALID_INSTANCE
    --             see notes on parameter p_instance_pk[1..5]_value below
    --
    -- INVALID_MENU_NAME
    --             see notes on parameter p_menu_name below
    --
    -- Parameters:
    --     IN    : p_delegate_type      IN  VARCHAR2 (required)
    --             Determines the type of delegation
    --             Defines:
    --                    GRANTEE_TYPE
    --                    OBJECT_TYPE
    --                    OBJECT_ID
    --                    INSTANCE_TYPE
    --             Currently supported type:
    --                     HRI_PER_USRDR_H -> Manager delegation
    --
    --             p_grantee_key         IN  VARCHAR2 (required)
    --                 User or group that gets the grant,
    --                 from FND_USER or another table that the view
    --                 WF_ROLES is based on.
    --
    --             p_instance_pk[1..5]_value       IN  NUMBER (optional)
    --                 These are the primary keys of the object instance
    --                 granted.  The order of the PKs must match the order
    --                 they were defined in FND_OBJECTS.  NULLs should
    --                 be passed for the higher numbered args with no PKs.
    --
    --             p_start_date (Defaulted to sysdate)
    --                  Start date of grant must be >= sysdate
    --
    --             p_end_date (Defaulted to NULL -> End of time)
    --                  End date of grant must be > sysdate
    --
    --             p_menu_name        IN  VARCHAR2 (required)
    --                 menu to be granted
    --
    --
    --     OUT  :
    --             x_grant_guid  OUT NOCOPY RAW
    --                If x_sucess = 'T' then this will return the
    --                fnd_grant row PK -> grant_guid
    --
    --             X_success    OUT VARCHAR(1)
    --               'T' if everything worked correctly
    --               'F' if there was a failure.  If FALSE
    --                is returned, there will either be an error
    --                message on the FND_MESSAGE stack which
    --                can be retrieved with FND_MESSAGE.GET_ENCODED(),
    --                or there will be a PL/SQL exception raised.
    --
    --             X_ErrorCode        OUT VARCHAR2(200)
    --                RETURN value OF the errorcode
    --                check only if x_success = F.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  PROCEDURE revoke_delegation
    ( p_delegate_type                IN VARCHAR2
     ,p_grantee_key                  IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk1_value           IN VARCHAR2
     ,p_instance_pk2_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk3_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk4_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk5_value           IN VARCHAR2 DEFAULT NULL
     ,p_start_date                   IN DATE DEFAULT NULL
     ,p_end_date                     IN DATE DEFAULT NULL
     ,p_menu_name                    IN VARCHAR2 DEFAULT NULL
     ,x_success                      OUT NOCOPY VARCHAR /* Boolean */
     ,x_errorcode                    OUT NOCOPY VARCHAR2
    );
 -- Start OF comments
    -- API name  : Revoke_Delegate_Function
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Revokes delegations that start and/or end in the window
    --             defined by the parameters:
    --                 - p_start_date
    --                 - p_end_date
    --             Revoke means:
    --                End Dating the delegation record if the record has
    --                 commenced prior to the window.
    --                Deleted if the delegation record starts within the window
    --             By default window starts on Sysdate and Ends at EOT
    --             Start Date is the date used to end date the records.
    --             Many parameters can be left undefined as 'wild cards'.
    --             If a parameter is undefined all values for that parameter
    --             will revoked that match the remaining paramaters
    --
    -- Exceptions:
    --
    --  INVALID_DATES
    --             Date Rules are:
    --             1. - Start Date <= End Date
    --             2. - Start Date and hence End Date >= TRUNC(sysdate)
    --             NOTE:
    --             - Start Date can be NULL to mean revoke "as of now" evaluated
    --               as SYSDATE in validations
    --             - End Date can be NULL to mean revoke everything from start
    --               date to "end of time", evaluated in validations as
    --               "End of Time"
    --             also see notes on parameters p_start_date and p_end_date
    --
    -- INVALID_DELEGATE_TYPE
    --             see notes on parameter p_delegate_type below
    --
    -- INVALID_FND_OBJECT
    --             fnd_object record associated with delegate type does not
    --             exist
    --             or the object defined in fnd_objects used to do validate
    --             the grantee parameter does not function
    --
    -- INVALID_GRANTEE
    --             see notes on parameter p_grantee_key below
    --
    -- INVALID_INSTANCE
    --             see notes on parameter p_instance_pk[1..5]_value below
    --
    -- INVALID_MENU_NAME
    --             see notes on parameter p_menu_name below
    --
    -- Parameters:
    --     IN    : p_delegate_type      IN  VARCHAR2 (required)
    --             Determines the type of delegation
    --             Defines:
    --                    GRANTEE_TYPE
    --                    OBJECT_TYPE
    --                    OBJECT_ID
    --                    INSTANCE_TYPE
    --             Currently supported type:
    --                     HRI_PER_USRDR_H -> Manager delegation
    --
    --             p_grantee_key         IN  VARCHAR2 (required)
    --                 User or group that gets the grant,
    --                 from FND_USER or another table that the view
    --                 WF_ROLES is based on.
    --                 If not defined all grantees for the combination will be
    --                 revoked
    --
    --             p_instance_pk[1..5]_value       IN  VARCHAR2 (optional)
    --                 These are the primary keys of the object instance
    --                 granted.  The order of the PKs must match the order
    --                 they were defined in FND_OBJECTS.  NULLs should
    --                 be passed for the higher numbered args with no PKs.
    --                 These must match the object corresponding to the
    --                 delegate_type.
    --                 If not defined all instances for the combination will be
    --                 revoked.
    --
    --             p_start_date             IN DATE (optional)
    --                 Default = TRUNC(SYSDATE)
    --                 Start date used to define start date of window within
    --                 which grants will revoked.
    --                 Defines the date to which records are truncated.
    --
    --             p_end_date             IN DATE (optional)
    --                 Default = End of time
    --                 End date used to define end date of window within which
    --                 grants will be revoked.
    --
    --             p_menu_name        IN  VARCHAR2 (optional)
    --                 menu to be revoked
    --                 If not defined all menus for the combination will be
    --                 revoked
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
    --             X_ErrorCode        OUT VARCHAR(200)
    --                RETURN value OF the errorcode
    --                check only if x_success = F.
    --
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
END BIS_DELEGATION_PUB; -- Package spec

 

/
