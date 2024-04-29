--------------------------------------------------------
--  DDL for Package IGI_EXPWORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXPWORKFLOW" AUTHID CURRENT_USER AS
  -- $Header: igiwfacs.pls 115.6 2002/11/19 04:37:17 panaraya ship $
  --
  -- Procedure
  --   Selector
  -- Purpose
  --   Calls the required runnable process.
  -- History
  --   09-JUN-99  G. Celand Initial Revision
  -- Notes
 PROCEDURE Selector( itemtype   IN VARCHAR2,
                     itemkey    IN VARCHAR2,
                     actid      IN NUMBER,
                     funcmode   IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2) ;


  -- Procedure
  --   StartUp
  -- Purpose
  --   Creates and starts an instance of the workflow.
  -- History
  --   May 24, 1999 Ashik KESSARIA    Creation
  -- Notes
  PROCEDURE Startup ( Wkf_Name       VARCHAR2,
                      Trans_Unit_Id  NUMBER,
                      Trans_Unit_Num VARCHAR2,
                      Wkf_Id         NUMBER,
                      Flow_Id        NUMBER,
                      User_Name      VARCHAR2);


  -- Procedure
  --   LegalNumbering
  -- Purpose
  --   Generates Legal Numbering for TU and DU
  -- History
  --   May 24, 1999 Ashik KESSARIA    Creation
  -- Notes
  PROCEDURE LegalNumbering ( itemtype   VARCHAR2,
                             itemkey    VARCHAR2,
                             actid      NUMBER,
                             funcmode   VARCHAR2,
                             result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   SetRole
  -- Purpose
  --   Sets up a role for a notification to use
  -- History
  --   May 24, 1999 Ashik KESSARIA    Creation
  -- Notes
  PROCEDURE SetRole ( itemtype   VARCHAR2,
                      itemkey    VARCHAR2,
                      actid      NUMBER,
                      funcmode   VARCHAR2,
                      result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   GetParentPosition
  -- Purpose
  --   Traverses through the Approval Hierarchies from bottom
  --   to top setting the context for validation.
  -- History
  --   May 24, 1999 Ashik KESSARIA    Creation
  -- Notes
  PROCEDURE GetParentPosition ( itemtype   VARCHAR2,
                                itemkey    VARCHAR2,
                                actid      NUMBER,
                                funcmode   VARCHAR2,
                                result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   Terminate
  -- Purpose
  --   Set status of TU to Terminated -TER
  -- History
  --   May 24, 1999 G. Celand Creation
  -- Notes
  PROCEDURE Terminate ( itemtype   VARCHAR2,
                        itemkey    VARCHAR2,
                        actid      NUMBER,
                        funcmode   VARCHAR2,
                        result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   BreakLink
  -- Purpose
  --   Break the link between a TU and DU
  -- History
  --   May 24, 1999 Ashik KESSARIA    Creation
  -- Notes
  PROCEDURE BreakLink( itemtype   VARCHAR2,
                       itemkey    VARCHAR2,
                       actid      NUMBER,
                       funcmode   VARCHAR2,
                       result OUT NOCOPY VARCHAR2);



  -- Procedure
  --   CreateList
  -- Purpose
  --   Create User List For Parent Position
  -- History
  --   May 24, 1999 Ashik KESSARIA    Creation
  -- Notes
  PROCEDURE CreateList ( itemtype   VARCHAR2,
                         itemkey    VARCHAR2,
                         actid      NUMBER,
                         funcmode   VARCHAR2,
                         result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   CheckList
  -- Purpose
  --   Checks Chosen Option was in List.
  -- History
  --   May 24, 1999 Ashik KESSARIA    Creation
  -- Notes
  PROCEDURE CheckList ( itemtype   VARCHAR2,
                        itemkey    VARCHAR2,
                        actid      NUMBER,
                        funcmode   VARCHAR2,
                        result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   Cancel
  -- Purpose
  --   To Call the Cancel Routine to cancel all successfully
  --   validated documents in a Transmission Unit.
  -- History
  --   16-JUN-1999 GWCeland    Creation
  -- Notes
  PROCEDURE Cancel ( itemtype   VARCHAR2,
                     itemkey    VARCHAR2,
                     actid      NUMBER,
                     funcmode   VARCHAR2,
                     result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   HoldApprove
  -- Purpose
  --   Stub.
  -- History
  --   16-JUN-1999 GWCeland    Creation
  -- Notes
  PROCEDURE HoldApprove ( itemtype   VARCHAR2,
                          itemkey    VARCHAR2,
                          actid      NUMBER,
                          funcmode   VARCHAR2,
                          result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   Complete_AR
  -- Purpose
  --   To  complete all AR documents contained within a dialogue unit
  -- History
  --   23-Sep-1999 GWCeland    Creation
  -- Notes
  PROCEDURE Complete_AR ( itemtype   VARCHAR2,
                          itemkey    VARCHAR2,
                          actid      NUMBER,
                          funcmode   VARCHAR2,
                          result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   ValidateGLDate
  -- Purpose
  --   To to check that the GL date will be updated to a valid date.
  -- History
  --   02-Dec-1999 GWCeland    Creation
  -- Notes
  PROCEDURE ValidateGLDate ( itemtype   VARCHAR2,
                             itemkey    VARCHAR2,
                             actid      NUMBER,
                             funcmode   VARCHAR2,
                             result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   MainAuthRequired
  -- Purpose
  --   To to check if any dialog need requisitioning.
  -- History
  --   22-Dec-1999 GWCeland    Creation
  -- Notes
  PROCEDURE MainAuthRequired ( itemtype   VARCHAR2,
                               itemkey    VARCHAR2,
                               actid      NUMBER,
                               funcmode   VARCHAR2,
                               result OUT NOCOPY VARCHAR2);

  -- Procedure
  --   ResetDUStatus
  -- Purpose
  --   Reset Dialog Unit status for next authorizer.
  -- History
  --   11-Jan-2000 GWCeland    Creation
  -- Notes
  PROCEDURE ResetDUStatus ( itemtype   VARCHAR2,
                            itemkey    VARCHAR2,
                            actid      NUMBER,
                            funcmode   VARCHAR2,
                            result OUT NOCOPY VARCHAR2);

  -- Procedure
  --   ContinueValidating
  -- Purpose
  --   Determines if all dialog units have been rejected and if so avoids acceptance.
  -- History
  --   11-Jan-2000 GWCeland    Creation
  -- Notes
  PROCEDURE ContinueValidating ( itemtype   VARCHAR2,
                                 itemkey    VARCHAR2,
                                 actid      NUMBER,
                                 funcmode   VARCHAR2,
                                 result OUT NOCOPY VARCHAR2);


  -- Procedure
  --   AllDUsRejected
  -- Purpose
  --   Determines if all dialog units have been rejected and if so avoids point of acceptance.
  -- History
  --   19-Jan-2000 GWCeland    Creation
  -- Notes
  PROCEDURE AllDUsRejected ( itemtype   VARCHAR2,
                             itemkey    VARCHAR2,
                             actid      NUMBER,
                             funcmode   VARCHAR2,
                             result OUT NOCOPY VARCHAR2);



  PROCEDURE control_buttons( itemtype   IN VARCHAR2,
                             itemkey    IN VARCHAR2,
                             actid      IN NUMBER,
                             funcmode   IN VARCHAR2,
                             resultout  OUT NOCOPY VARCHAR2) ;



  PROCEDURE control_forwarding( itemtype   IN VARCHAR2,
                                itemkey    IN VARCHAR2,
                                actid      IN NUMBER,
                                funcmode   IN VARCHAR2,
                                resultout  OUT NOCOPY VARCHAR2) ;



   -- global variable to hold user id
   g_userid NUMBER ;

END igi_expworkflow ;

 

/
