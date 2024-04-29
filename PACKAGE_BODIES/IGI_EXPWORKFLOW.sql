--------------------------------------------------------
--  DDL for Package Body IGI_EXPWORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXPWORKFLOW" AS
  -- $Header: igiwfacb.pls 115.19 2003/08/09 11:54:12 rgopalan ship $
  --
  -- PRIVATE ROUTINES
  --
  -- Procedure
  --       Debug_Info
  -- Description
  --       Writes debug info from the package routines to a debug table.
  --

 PROCEDURE Debug_Info ( info varchar2 )
 IS
BEGIN
NULL;
END debug_info ;

  --
  --
  -- PUBLIC ROUTINES
  --
  --

 PROCEDURE Selector( itemtype   IN VARCHAR2,
                     itemkey    IN VARCHAR2,
                     actid      IN NUMBER,
                     funcmode   IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2)
 IS
BEGIN
NULL;
END Selector ;


 PROCEDURE Startup ( Wkf_Name       VARCHAR2,
                     Trans_Unit_Id  NUMBER,
                     Trans_Unit_Num VARCHAR2,
                     Wkf_Id         NUMBER,
                     Flow_Id        NUMBER,
                     User_Name      VARCHAR2)
IS
BEGIN
NULL;
END Startup;


-- Procedure
--       LegalNumbering
-- Description
--       Obtains the legal numbers for a transmission unit and for
--       approved dialogue units in the transmission unit.
-- History
--        14-JUN-1999   GWCeland procedure created
-- IN
--    itemtype  - A valid item type from (WF_ITEM_TYPES table)
--    itemkey   - A string generated from the application objects pk
--    actid     - An instance of the function activity (instance id)
--    funcmode  - Run/Cancel/Timeout
--
-- OUT NOCOPY
--    resultout - Procedure status
--
--

 PROCEDURE LegalNumbering ( itemtype    VARCHAR2,
                            itemkey     VARCHAR2,
                            actid       NUMBER,
                            funcmode    VARCHAR2,
                            result OUT NOCOPY  VARCHAR2)
 IS
BEGIN
NULL;
END LegalNumbering;


 PROCEDURE ContinueValidating( itemtype   VARCHAR2,
                               itemkey    VARCHAR2,
                               actid      NUMBER,
                               funcmode   VARCHAR2,
                               result OUT NOCOPY VARCHAR2)
 IS
BEGIN
NULL;
END ContinueValidating ;

 PROCEDURE SetRole ( itemtype   VARCHAR2,
                      itemkey    VARCHAR2,
                      actid      NUMBER,
                      funcmode   VARCHAR2,
                      result OUT NOCOPY VARCHAR2)

 -- This procedure is called when a new authorizer in the hierarchy has been
 -- selected to receive a notification. The attribute 'ROLE_NAME' is set to
 -- equal the authorizer name. This attribute is used by the notification system
 -- to determine where to send the notice.
 IS
BEGIN
NULL;
END SetRole;


 PROCEDURE GetParentPosition ( itemtype   VARCHAR2,
                               itemkey    VARCHAR2,
                               actid      NUMBER,
                               funcmode   VARCHAR2,
                               result OUT NOCOPY VARCHAR2)
 -- This procedure controls access to the approval hierarchies and sets
 -- the required context for each authorizer. It detects when approval
 -- moves to the account office hierarchy and accordingly saves the
 -- positions of the main authorizer and account officer so that the
 -- approval notifications can be sent to these positions.
 IS
BEGIN
NULL;
END GetParentPosition;

 PROCEDURE SendDu ( itemtype   VARCHAR2,
                    itemkey    VARCHAR2,
                    actid      NUMBER,
                    funcmode   VARCHAR2,
                    p_message VARCHAR2)
 IS
BEGIN
NULL;
END SendDu ;

 PROCEDURE Terminate ( itemtype   VARCHAR2,
                       itemkey    VARCHAR2,
                       actid      NUMBER,
                       funcmode   VARCHAR2,
                       result OUT NOCOPY VARCHAR2)
  -- Sets status to 'Terminated' indicating that the transmission unit
  -- has exited the workflow.
 IS
BEGIN
NULL;
END Terminate;

 PROCEDURE ValidateGLDate( itemtype  IN VARCHAR2,
                           itemkey   IN VARCHAR2,
                           actid     IN NUMBER,
                           funcmode  IN VARCHAR2,
                           result   OUT NOCOPY VARCHAR2)
 -- Checks to see if the current date is valid. This date is used as
 -- the gl date for all documents that are successfully approved or
 -- completed in the transmission unit.
 IS
BEGIN
NULL;
END ValidateGLDate ;

 PROCEDURE BreakLink( itemtype   VARCHAR2,
                      itemkey    VARCHAR2,
                      actid      NUMBER,
                      funcmode   VARCHAR2,
                      result OUT NOCOPY VARCHAR2)
 -- This procedure removes the link (dialog_unit_id) from AP/AR
 -- documents that have been rejected by authorizer departments
 -- so that the documents can be reused in other dialog units.
 IS
BEGIN
NULL;
END BreakLink;


 PROCEDURE CreateList ( itemtype   VARCHAR2,
                        itemkey    VARCHAR2,
                        actid      NUMBER,
                        funcmode   VARCHAR2,
                        result OUT NOCOPY VARCHAR2)

 -- Creates a list of the people in the next position to receive the
 -- transmission unit saving the list in a global workflow attribute.
 IS
BEGIN
NULL;
END CreateList;


 PROCEDURE CheckList ( itemtype   VARCHAR2,
                       itemkey    VARCHAR2,
                       actid      NUMBER,
                       funcmode   VARCHAR2,
                       result OUT NOCOPY VARCHAR2)
 -- Checks that a user has selected a person from the list of people
 -- in the next position. If not the notification is recent.
 IS

BEGIN
NULL;
END CheckList;


 PROCEDURE Cancel ( itemtype   VARCHAR2,
                    itemkey    VARCHAR2,
                    actid      NUMBER,
                    funcmode   VARCHAR2,
                    result OUT NOCOPY VARCHAR2)

 -- If the accounts office do not want to take responsibility for certain
 -- dialog units they can send the transmission unit back to the main authorizer.
 -- If the main authorizer rejects any AP documents then they are cancelled.
 IS
BEGIN
NULL;
END Cancel ;


 PROCEDURE HoldApprove ( itemtype   VARCHAR2,
                         itemkey    VARCHAR2,
                         actid      NUMBER,
                         funcmode   VARCHAR2,
                         result OUT NOCOPY VARCHAR2)

 -- Updates the gl date, removes the EXP hold and approves AP
 -- documents contained in successfully validated dialog units.
 IS
BEGIN
NULL;
END HoldApprove ;


 PROCEDURE DocumentPayment ( itemtype  IN VARCHAR2,
                             itemkey   IN VARCHAR2,
                             actid     IN NUMBER,
                             funcmode  IN VARCHAR2,
                             result   OUT NOCOPY VARCHAR2)
 IS
BEGIN
NULL;
END DocumentPayment ;


 PROCEDURE Complete_AR ( itemtype   VARCHAR2,
                         itemkey    VARCHAR2,
                         actid      NUMBER,
                         funcmode   VARCHAR2,
                         result OUT NOCOPY VARCHAR2)
 -- Updates the gl date and changes the status of AR documents to
 -- completed in successfully validated dialog units.
 IS
BEGIN
NULL;
END Complete_AR ;



 PROCEDURE MainAuthRequired ( itemtype  IN VARCHAR2,
                              itemkey   IN VARCHAR2,
                              actid     IN NUMBER,
                              funcmode  IN VARCHAR2,
                              result   OUT NOCOPY VARCHAR2)
 -- Determines if the main authorizer needs to validate any dialog units.
 IS

BEGIN
NULL;
END  MainAuthRequired;

 PROCEDURE ResetDUStatus ( itemtype  IN VARCHAR2,
                           itemkey   IN VARCHAR2,
                           actid     IN NUMBER,
                           funcmode  IN VARCHAR2,
                           result   OUT NOCOPY VARCHAR2)

 -- when a user has validated a transmission unit the status of dialog
 -- units that have passed validation are rest to transmitted for the
 -- next user.
 IS
BEGIN
NULL;
END ResetDUStatus ;

 PROCEDURE AllDUsRejected ( itemtype  IN VARCHAR2,
                            itemkey   IN VARCHAR2,
                            actid     IN NUMBER,
                            funcmode  IN VARCHAR2,
                            result   OUT NOCOPY VARCHAR2)

 -- Determines if all the dialog units in the transmission unit have been rejected.

 IS
BEGIN
NULL;
END AllDUsRejected ;


 PROCEDURE Control_Buttons( itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2)
 IS
BEGIN
NULL;
END control_buttons ;

 PROCEDURE control_forwarding( itemtype   IN VARCHAR2,
                               itemkey    IN VARCHAR2,
                               actid      IN NUMBER,
                               funcmode   IN VARCHAR2,
                               resultout  OUT NOCOPY VARCHAR2)
 IS

BEGIN
NULL;
END  control_forwarding;

END igi_expworkflow ;

/
