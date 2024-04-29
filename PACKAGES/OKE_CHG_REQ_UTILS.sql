--------------------------------------------------------
--  DDL for Package OKE_CHG_REQ_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_CHG_REQ_UTILS" AUTHID CURRENT_USER AS
/* $Header: OKECRQUS.pls 115.14 2002/11/21 22:48:01 ybchen ship $ */
--
--  Name          : Status_Change
--  Pre-reqs      : None
--  Function      : This procedure performs utility functions during
--                  a change request status change.
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : None
--

PROCEDURE Status_Change
( P_Calling_Mode         IN  VARCHAR2
, P_K_Header_ID          IN  NUMBER
, P_Chg_Request_ID       IN  NUMBER
, P_Chg_Request_Num      IN  VARCHAR2
, P_Requested_By         IN  NUMBER
, P_Effective_Date       IN  DATE
, P_Old_Status_Code      IN  VARCHAR2
, P_New_Status_Code      IN  VARCHAR2
, P_Chg_Type_Code        IN  VARCHAR2
, P_Chg_Reason_Code      IN  VARCHAR2
, P_Impact_Funding_flag  IN  VARCHAR2
, P_Description          IN  VARCHAR2
, P_Chg_Text             IN  VARCHAR2
, P_Updated_By           IN  NUMBER
, P_Update_Date          IN  DATE
, P_Login_ID             IN  NUMBER
, X_Chg_Log_ID           IN OUT NOCOPY NUMBER
, X_Approve_Date         IN OUT NOCOPY DATE
, X_Implement_Date       IN OUT NOCOPY DATE
);


--
--  Name          : Get_Process_Status
--  Pre-reqs      : None
--  Function      : This procedure returns the Workflow status of
--                  a status change as stored in the history.
--
--
--  Parameters    :
--  IN            : P_CHG_LOG_ID     NUMBER
--  OUT           : X_STATUS         VARCHAR2
--                  X_RESULT         VARCHAR2
--
--  Returns       : None
--
PROCEDURE Get_Process_Status
( P_Chg_Log_ID       IN  NUMBER
, X_Status           OUT NOCOPY VARCHAR2
, X_Result           OUT NOCOPY VARCHAR2
);


--
--  Name          : Update_Process
--  Pre-reqs      : None
--  Function      : This procedure suspend/resume/abort an existing
--                  workflow process
--
--
--  Parameters    :
--  IN            : P_CHG_LOG_ID     NUMBER
--                  P_MODE           VARCHAR2
--                                   - SUSPEND
--                                   - RESUME
--                                   - ABORT
--  OUT           : None
--
--  Returns       : None
--
PROCEDURE Update_Process
( P_Chg_Log_ID       IN  NUMBER
, P_Mode             IN  VARCHAR2
);


--
--  Name          : OK_To_Implement
--  Pre-reqs      : None
--  Function      : This function checks whether there is another
--                  approved change request currently in progress
--                  or unapproved change request with an earlier
--                  effective date
--
--
--  Parameters    :
--  IN            : X_K_HEADER_ID     NUMBER
--                : X_CHG_REQUEST_ID  NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--                   Y - OK to implement
--                   W - give user warning message
--                   N - Cannot proceed
--
FUNCTION OK_To_Implement
( X_Chg_Request_ID   IN  NUMBER
) RETURN VARCHAR2;

--
--  Name          : OK_To_Undo
--  Pre-reqs      : None
--  Function      : This function checks whether there is another
--                  completed or in progress change request with a
--                  later effective date
--
--
--  Parameters    :
--  IN            : X_K_HEADER_ID     NUMBER
--                : X_CHG_REQUEST_ID  NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--                   Y - OK to undo
--                   W - give user warning message
--                   N - Cannot proceed
--
FUNCTION OK_To_Undo
( X_Chg_Request_ID   IN  NUMBER
) RETURN VARCHAR2;


--
--  Name          : Get_Chg_Request
--  Pre-reqs      : None
--  Function      : This function returns the related Change Request
--                  Number and Change Status for the given contract
--		    either for the current version or a specific
--		    major version.
--
--
--  Parameters    :
--  IN            : X_K_Header_ID           NUMBER
--                  X_Major_Version         NUMBER
--                  X_History_Use           VARCHAR2 DEFAULT N
--  OUT           : X_Change_Request	    VARCHAR2
--		    X_Change_Status	    VARCHAR2
--

PROCEDURE Get_Chg_Request
( X_K_Header_ID           IN     NUMBER
, X_Major_Version         IN     NUMBER   DEFAULT NULL
, X_Change_Request	  OUT NOCOPY    VARCHAR2
, X_Change_Status	  OUT NOCOPY    VARCHAR2
, X_History_Use           IN     VARCHAR2 DEFAULT 'N'
);

END OKE_CHG_REQ_UTILS;

 

/
