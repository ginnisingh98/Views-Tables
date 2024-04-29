--------------------------------------------------------
--  DDL for Package IGIDOSL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIDOSL" AUTHID CURRENT_USER AS
   -- $Header: igidosls.pls 120.8.12000000.6 2007/07/02 04:41:03 pshivara ship $
   --


   --
   -- Procedure
   --   Debug_log_string
   --
   -- Purpose
   --   This has been added as a part of fnd_log changes.
   --   This procedure is used to input debug message if
   --   debug log is enabled.
   --
   -- History
   --   19-DEC-2003 Rgopalan  Initial Version
   --

   Procedure Debug_log_string (P_level   IN NUMBER,
                               P_module  IN VARCHAR2,
                               P_Message IN VARCHAR2);


   --
   -- Procedure
   --   Debug_log_unexp_error
   -- Purpose
   --   puts enexpected error to log.
   -- History
   --   24-DEC-2003 Rgopalan Initial Version
   --

   Procedure Debug_log_unexp_error (P_module     IN VARCHAR2,
                                    P_error_type IN VARCHAR2);


   --
   -- Procedure
   --   Selector
   -- Purpose
   --   Chooses the process to run when the workflow is invoked
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE Selector( itemtype   IN  VARCHAR2,
                       itemkey    IN  VARCHAR2,
                       actid      IN  NUMBER,
                       funcmode   IN  VARCHAR2,
                       resultout  OUT NOCOPY VARCHAR2
                     );

   --
   -- Procedure
   --   StartUp
   -- Purpose
   --   Creates and starts an instance of the workflow.
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE Startup ( Wkf_Name                   VARCHAR2,
                       Dossier_Id                NUMBER,
                       Dossier_Num                 VARCHAR2,
                       Ledger_Id                NUMBER, -- Added for bug 6126275
                       Packet_Id                   NUMBER,
                       User_Name                VARCHAR2,
                       Dossier_Transaction_name    VARCHAR2,
                       Dossier_Description         VARCHAR2,
                       User_Id                     VARCHAR2,
                       Responsibility_Id           VARCHAR2,
                       Dossier_Transaction_Detail  VARCHAR2
                     );

   --
   -- Procedure
   --   SetRole
   -- Purpose
   --   Copies the selected authorizer to the role variable
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE SetRole ( itemtype      VARCHAR2,
                       itemkey       VARCHAR2,
                       actid         NUMBER,
                       funcmode      VARCHAR2,
                       result    OUT NOCOPY VARCHAR2
                     );

   --
   -- Procedure
   --   GetParentPosition
   -- Purpose
   --   Traverses through the Approval Hierarchies from bottom
   --   to top setting the context for validation.
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE GetParentPosition ( itemtype      VARCHAR2,
                                 itemkey       VARCHAR2,
                                 actid         NUMBER,
                                 funcmode      VARCHAR2,
                                 result    OUT NOCOPY VARCHAR2
                               );

   --
   -- Procedure
   --   Approve
   -- Purpose
   --   Set status of Dossier to 'Approved'
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE Approve ( itemtype      VARCHAR2,
                       itemkey       VARCHAR2,
                       actid         NUMBER,
                       funcmode      VARCHAR2,
                       result    OUT NOCOPY VARCHAR2
                     );

   --
   -- Procedure
   --   Reject
   -- Purpose
   --   Set status of Dossier to 'Rejected'
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE Reject ( itemtype      VARCHAR2,
                      itemkey       VARCHAR2,
                      actid         NUMBER,
                      funcmode      VARCHAR2,
                      result    OUT NOCOPY VARCHAR2
                    );

   --
   -- Procedure
   --   SendApproved
   -- Purpose
   --   Notifies the Creator of the Dossier that it has been
   --   approved.
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE SendApproved ( itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
                            result    OUT NOCOPY VARCHAR2
                          );

   --
   -- Procedure
   --   SendRejected
   -- Purpose
   --   Notifies the Creator of the Dossier that is has been
   --   rejected.
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE SendRejected ( itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
                            result    OUT NOCOPY VARCHAR2
                          );

   --
   -- Procedure
   --   CreateList
   -- Purpose
   --   Create User List For Parent Position
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE CreateList ( itemtype      VARCHAR2,
                          itemkey       VARCHAR2,
                          actid         NUMBER,
                          funcmode      VARCHAR2,
                          result    OUT NOCOPY VARCHAR2
                        );

   --
   -- Procedure
   --   CheckList
   -- Purpose
   --   Check Chosen Option was in List.
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE CheckList ( itemtype      VARCHAR2,
                         itemkey       VARCHAR2,
                         actid         NUMBER,
                         funcmode      VARCHAR2,
                         result    OUT NOCOPY VARCHAR2
                       );

   --
   -- Procedure
   --   UnreserveFunds
   -- Purpose
   --   Calls the procedure to unreserve encumbered funds
   --   for a dossier that has been rejected.
   -- History
   --   22-OCT-2001 L Silveira  Initial Version
   --
   PROCEDURE UnreserveFunds ( itemtype      VARCHAR2,
                              itemkey       VARCHAR2,
                              actid         NUMBER,
                              funcmode      VARCHAR2,
                              result    OUT NOCOPY VARCHAR2
                            );


   --
   -- Procedure
   --  FrameDosTable
   --
   -- Purpose
   --  This procedure frames an HTML table to display details
   --  in workflow notification.
   --
   -- History
   --   19-DEC-2003 Rgopalan  Initial Version
   --

   PROCEDURE FrameDosTable ( Document IN OUT NOCOPY CLOB);


   --
   -- Procedure
   --   AddTotalToTable
   --
   -- Purpose
   --   This Procedure will displaytotal for every destination
   --   in HTML table, this will be displayed in the
   --   workflow notification.
   --
   -- History
   --   24-DEC-2003 Rgopalan            115.8

   PROCEDURE AddTotalToTable ( Document IN OUT NOCOPY CLOB,
                               p_total  IN            VARCHAR2);


   --
   -- Procedure
   --   Dossier_Transaction_Detail
   --
   -- Purpose
   --   This Procedure will add source and deatination rows
   --   to the HTML table, this will be diaplyed in the
   --   workflow notification.
   --
   -- History
   --   11-JAN-2001 Sekhar Kappaganti   Initial Version
   --   19-DEC-2003 Rgopalan            115.8

   Procedure dossier_transaction_detail(document_id     in            VARCHAR2,
                                        display_type    in            VARCHAR2,
				        document        in out NOCOPY CLOB,
				        document_type   in out NOCOPY VARCHAR2);

   --
   -- Bug 2542174 Start(1)
   --
   --
   -- Procedure
   --   RewindInProcess
   -- Purpose
   --   Rewinds the 'In Process' status of the Dossier Transaction
   --   to 'Creating'
   -- History
   --   23-SEP-2002 L Silveira  Initial Version
   --
   PROCEDURE RewindInProcess( itemtype   IN  VARCHAR2,
                              itemkey    IN  VARCHAR2,
                              actid      IN  NUMBER,
                              funcmode   IN  VARCHAR2,
                              result     OUT NOCOPY VARCHAR2
                            );

   --
   -- Procedure
   --   IsEmployee
   -- Purpose
   --   Validates if dossier approval launcher is an employee.
   -- History
   --   23-SEP-2002 L Silveira  Initial Version
   --
   PROCEDURE IsEmployee( itemtype   IN  VARCHAR2,
                         itemkey    IN  VARCHAR2,
                         actid      IN  NUMBER,
                         funcmode   IN  VARCHAR2,
                         result     OUT NOCOPY VARCHAR2
                       );

   --
   -- Procedure
   --   HasPosition
   -- Purpose
   --   Validates if dossier approval launcher has a position
   --   assignment.
   -- History
   --   23-SEP-2002 L Silveira  Initial Version
   --
   PROCEDURE HasPosition( itemtype   IN  VARCHAR2,
                          itemkey    IN  VARCHAR2,
                          actid      IN  NUMBER,
                          funcmode   IN  VARCHAR2,
                          result     OUT NOCOPY VARCHAR2
                        );

   --
   -- Procedure
   --   PositionInHierarchy
   -- Purpose
   --   Validates if dossier approval launcher position is in the
   --   hierarchy attached to the dossier type.
   -- History
   --   23-SEP-2002 L Silveira  Initial Version
   --
   PROCEDURE PositionInHierarchy( itemtype   IN  VARCHAR2,
                                  itemkey    IN  VARCHAR2,
                                  actid      IN  NUMBER,
                                  funcmode   IN  VARCHAR2,
                                  result     OUT NOCOPY VARCHAR2
                                );
--
-- Bug 2542174 End(1)
--

END igidosl;

 

/
