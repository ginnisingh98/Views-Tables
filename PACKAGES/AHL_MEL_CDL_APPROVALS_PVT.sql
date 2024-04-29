--------------------------------------------------------
--  DDL for Package AHL_MEL_CDL_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MEL_CDL_APPROVALS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMAPS.pls 120.1 2008/02/29 07:55:25 sracha ship $ */

G_APP_NAME  CONSTANT    VARCHAR2(3)     := 'AHL';                       -- Use for all FND_MESSAGE.SET_NAME calls
G_PKG_NAME  CONSTANT    VARCHAR2(30)    := 'AHL_MEL_CDL_APPROVALS_PVT'; -- Use for all debug messages, FND_API.COMPATIBLE_API_CALL, etc

G_APPR_OBJ  CONSTANT    VARCHAR2(30)    := 'MEL_CDL';
G_APPR_TYPE CONSTANT    VARCHAR2(30)    := 'CONCEPT';

-- object used for non-routine approval.
G_NR_APPR_OBJ  CONSTANT    VARCHAR2(30)    := 'NR_MEL_CDL';

--  Start of Comments  --
--
--  Procedure name      : SET_ACTIVITY_DETAILS
--  Type                : Private
--  Description         : This procedure sets all item attribute details for the approval rule
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE SET_ACTIVITY_DETAILS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : NTF_FORWARD_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for forwarded workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NTF_FORWARD_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : NTF_APPROVED_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for approved workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NTF_APPROVED_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : NTF_FINAL_APPROVAL_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for final approval workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NTF_FINAL_APPROVAL_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : NTF_REJECTED_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for rejected workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NTF_REJECTED_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : NTF_APPROVAL
--  Type                : Private
--  Description         : This procedure generates the document for sending to-approve notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NTF_APPROVAL
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : NTF_APPROVAL_REMINDER
--  Type                : Private
--  Description         : This procedure generates the document for sending reminders
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NTF_APPROVAL_REMINDER
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : NTF_ERROR_ACT
--  Type                : Private
--  Description         : This procedure generates the document for requesting action on error
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NTF_ERROR_ACT
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : UPDATE_STATUS
--  Type                : Private
--  Description         : This procedure handles the final complete step of the workflow process
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE UPDATE_STATUS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : REVERT_STATUS
--  Type                : Private
--  Description         : This procedure handles revert of the workflow process on any error
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE REVERT_STATUS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
);

-- Procedures used by Non-Routine MEL/CDl approval --
-----------------------------------------------------


--  Start of Comments  --
--
--  Procedure name      : NR_SET_ACTIVITY_DETAILS
--  Type                : Private
--  Description         : This procedure sets all item attribute details for the NR approval rule
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_SET_ACTIVITY_DETAILS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name      : NR_NTF_FORWARD_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for forwarded workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_FORWARD_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);


--  Start of Comments  --
--
--  Procedure name      : NR_NTF_APPROVED_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for approved workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_APPROVED_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);


--  Start of Comments  --
--
--  Procedure name      : NR_NTF_FINAL_APPROVAL_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for final approval workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_FINAL_APPROVAL_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);


--  Start of Comments  --
--
--  Procedure name      : NR_NTF_REJECTED_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for rejected workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_REJECTED_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);


--  Start of Comments  --
--
--  Procedure name      : NR_NTF_APPROVAL
--  Type                : Private
--  Description         : This procedure generates the document for sending to-approve notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_APPROVAL
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);


--  Start of Comments  --
--
--  Procedure name      : NR_NTF_APPROVAL_REMINDER
--  Type                : Private
--  Description         : This procedure generates the document for sending reminders
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_APPROVAL_REMINDER
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);


--  Start of Comments  --
--
--  Procedure name      : NR_NTF_ERROR_ACT
--  Type                : Private
--  Description         : This procedure generates the document for requesting action on error
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_ERROR_ACT
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
);


--  Start of Comments  --
--
--  Procedure name      : NR_UPDATE_STATUS
--  Type                : Private
--  Description         : This procedure handles the final complete step of the workflow process
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_UPDATE_STATUS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
);


--  Start of Comments  --
--
--  Procedure name      : NR_REVERT_STATUS
--  Type                : Private
--  Description         : This procedure handles revert of the workflow process on any error
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_REVERT_STATUS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
);


End AHL_MEL_CDL_APPROVALS_PVT;

/
