--------------------------------------------------------
--  DDL for Package AHL_MC_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_APPROVALS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMWFS.pls 115.0 2003/07/31 14:05:51 tamdas noship $ */

    ---------------------------------------------------------------------
    -- PROCEDURE
    --   SET_ACTIVITY_DETAILS
    --
    --
    -- PURPOSE
    --   This Procedure will set all the item attribute details
    --
    --
    -- Used By Activities
    --
    -- NOTES
    --
    --
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    -- End of Comments
    --------------------------------------------------------------------
    PROCEDURE SET_ACTIVITY_DETAILS
    (
         itemtype    IN       VARCHAR2
        ,itemkey     IN       VARCHAR2
        ,actid       IN       NUMBER
        ,funcmode    IN       VARCHAR2
        ,resultout   OUT   NOCOPY   VARCHAR2
    );

    --------------------------------------------------------------------------
    -- PROCEDURE
    --   NTF_FORWARD_FYI
    --
    -- PURPOSE
    --   Generate the FYI Document for display in messages, either text or html
    --
    -- IN
    --   document_id   - Item Key
    --   display_type  - either 'text/plain' or 'text/html'
    --   document      - document buffer
    --   document_type - type of document buffer created, either 'text/plain'
    --                   or 'text/html'
    -- OUT
    --
    -- USED BY
    --   Oracle ASO Apporval
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    --------------------------------------------------------------------------

    PROCEDURE NTF_FORWARD_FYI
    (
        document_id     IN       VARCHAR2
        ,display_type    IN       VARCHAR2
        ,document        IN OUT  NOCOPY VARCHAR2
        ,document_type   IN OUT  NOCOPY VARCHAR2
    );

    --------------------------------------------------------------------------
    -- PROCEDURE
    --   NTF_APPROVED_FYI
    --
    -- PURPOSE
    --   Generate the FYI Document for display in messages, either text or html
    --
    -- IN
    --   document_id   - Item Key
    --   display_type  - either 'text/plain' or 'text/html'
    --   document      - document buffer
    --   document_type - type of document buffer created, either 'text/plain'
    --                   or 'text/html'
    -- OUT
    --
    -- USED BY
    --   Oracle ASO Apporval
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    --------------------------------------------------------------------------
    PROCEDURE NTF_APPROVED_FYI
    (
        document_id     IN       VARCHAR2
        ,display_type    IN       VARCHAR2
        ,document        IN OUT  NOCOPY VARCHAR2
        ,document_type   IN OUT  NOCOPY VARCHAR2
    );

    --------------------------------------------------------------------------
    -- PROCEDURE
    --   NTF_FINAL_APPROVAL_FYI
    --
    -- PURPOSE
    --   Generate the FYI Document for display in messages, either text or html
    --
    -- IN
    --   document_id   - Item Key
    --   display_type  - either 'text/plain' or 'text/html'
    --   document      - document buffer
    --   document_type - type of document buffer created, either 'text/plain'
    --                   or 'text/html'
    -- OUT
    --
    -- USED BY
    --   Oracle ASO Apporval
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    --------------------------------------------------------------------------
    PROCEDURE NTF_FINAL_APPROVAL_FYI
    (
        document_id     IN       VARCHAR2
        ,display_type    IN       VARCHAR2
        ,document        IN OUT  NOCOPY VARCHAR2
        ,document_type   IN OUT  NOCOPY VARCHAR2
    );

    --------------------------------------------------------------------------
    -- PROCEDURE
    --   NTF_REJECTED_FYI
    --
    -- PURPOSE
    --   Generate the FYI Document for display in messages, either text or html
    --
    -- IN
    --   document_id   - Item Key
    --   display_type  - either 'text/plain' or 'text/html'
    --   document      - document buffer
    --   document_type - type of document buffer created, either 'text/plain'
    --                   or 'text/html'
    -- OUT
    --
    -- USED BY
    --   Oracle ASO Apporval
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    --------------------------------------------------------------------------
    PROCEDURE NTF_REJECTED_FYI
    (
        document_id     IN       VARCHAR2
        ,display_type    IN       VARCHAR2
        ,document        IN OUT  NOCOPY VARCHAR2
        ,document_type   IN OUT  NOCOPY VARCHAR2
    );


    --------------------------------------------------------------------------
    -- PROCEDURE
    --   NTF_APPROVAL
    --
    -- PURPOSE
    --   Generate the Document to ask for approval, either text or html
    --
    -- IN
    --   document_id   - Item Key
    --   display_type  - either 'text/plain' or 'text/html'
    --   document      - document buffer
    --   document_type - type of document buffer created, either 'text/plain'
    --                   or 'text/html'
    -- OUT
    --
    -- USED BY
    --   Oracle ASO Apporval
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    --------------------------------------------------------------------------
    PROCEDURE NTF_APPROVAL
    (
        document_id     IN       VARCHAR2
        ,display_type    IN       VARCHAR2
        ,document        IN OUT  NOCOPY VARCHAR2
        ,document_type   IN OUT  NOCOPY VARCHAR2
    );

    --------------------------------------------------------------------------
    -- PROCEDURE
    --   NTF_APPROVAL_REMINDER
    --
    -- PURPOSE
    --   Generate the Reminder Document for display in messages, either text or html
    --
    -- IN
    --   document_id   - Item Key
    --   display_type  - either 'text/plain' or 'text/html'
    --   document      - document buffer
    --   document_type - type of document buffer created, either 'text/plain'
    --                   or 'text/html'
    -- OUT
    --
    -- USED BY
    --   Oracle ASO Apporval
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    --------------------------------------------------------------------------
    PROCEDURE NTF_APPROVAL_REMINDER
    (
        document_id     IN       VARCHAR2
        ,display_type    IN       VARCHAR2
        ,document        IN OUT  NOCOPY VARCHAR2
        ,document_type   IN OUT  NOCOPY VARCHAR2
    );


    --------------------------------------------------------------------------
    -- PROCEDURE
    --   NTF_ERROR_ACT
    --
    -- PURPOSE
    --   Generate the Document to request action to handle error, either text or html
    --
    -- IN
    --   document_id   - Item Key
    --   display_type  - either 'text/plain' or 'text/html'
    --   document      - document buffer
    --   document_type - type of document buffer created, either 'text/plain'
    --                   or 'text/html'
    -- OUT
    --
    -- USED BY
    --   Oracle ASO Apporval
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    --------------------------------------------------------------------------
    PROCEDURE NTF_ERROR_ACT
    (
        document_id     IN       VARCHAR2
        ,display_type    IN       VARCHAR2
        ,document        IN OUT  NOCOPY VARCHAR2
        ,document_type   IN OUT  NOCOPY VARCHAR2
    );

    ---------------------------------------------------------------------
    -- PROCEDURE
    --  UPDATE_STATUS
    --
    -- PURPOSE
    --   This Procedure will update the status
    --
    -- IN
    --
    -- OUT
    --
    -- USED BY
    --   Oracle ASO Apporval
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    --------------------------------------------------------------------------
    PROCEDURE UPDATE_STATUS
    (
        itemtype    IN        VARCHAR2
        ,itemkey     IN       VARCHAR2
        ,actid       IN       NUMBER
        ,funcmode    IN       VARCHAR2
        ,resultout   OUT   NOCOPY    VARCHAR2
    );

    ---------------------------------------------------------------------
    -- PROCEDURE
    --  Revert_Status
    --
    -- PURPOSE
    --   This Procedure will revert the status in the case of an error
    --
    -- IN
    --
    -- OUT
    --
    -- USED BY
    --   Oracle ASO Apporval
    --
    -- HISTORY
    --   22/04/2002        VIAGRAWA        CREATED
    --------------------------------------------------------------------------
    PROCEDURE REVERT_STATUS
    (
        itemtype    IN       VARCHAR2
        ,itemkey     IN       VARCHAR2
        ,actid       IN       NUMBER
        ,funcmode    IN       VARCHAR2
        ,resultout   OUT   NOCOPY   VARCHAR2
    );

End AHL_MC_Approvals_PVT;

 

/
