--------------------------------------------------------
--  DDL for Package OE_VALIDATE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_WF" AUTHID CURRENT_USER AS
/* $Header: OEXVVWFS.pls 120.1.12000000.1 2007/01/16 22:13:06 appldev ship $ */

/*----------------------------------------------------------------
Global variables used in the context of validating flows
------------------------------------------------------------------*/
--  Variable_name                        VARIABLE_DATATYPE := <DEFAULT>;

--  Activities Record type
TYPE Activities_Rec_Type IS RECORD
( activity_name                 VARCHAR2(30)
, process_name                  VARCHAR2(30)
, activity_item_type            VARCHAR2(8)
, instance_id                   NUMBER
, type                          VARCHAR2(8)
, function                      VARCHAR2(240)
, instance_label                VARCHAR2(30)
, start_end                     VARCHAR2(8)
);

TYPE Activities_Tbl_Type IS TABLE OF Activities_Rec_Type
     INDEX BY BINARY_INTEGER;

-- G_loop_tbl is a package global that stores all process
-- activities during one non-recursive call to in_loop()
TYPE NumberTable IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;

/*
--  Transaction Record type
TYPE Transaction_Rec_Type IS RECORD
(   sales_document_type_code      VARCHAR2(30)
,   transaction_type_id           NUMBER
,   transaction_type_code         VARCHAR2(30)
,   order_category_code           VARCHAR2(30)
,   start_date_active             DATE
,   end_date_active               DATE
);

TYPE Transaction_Tbl_Type IS TABLE OF Transaction_Rec_Type
     INDEX BY BINARY_INTEGER;
*/
-- Not required as the same has been handled at 'Validate' procedure level itself.

/*----------------------------------------------------------------
  Function Display_Name
  A function returning Display name of a process name.
------------------------------------------------------------------*/
FUNCTION Display_Name
( P_process                        IN OUT NOCOPY VARCHAR2
, P_item_type                      IN VARCHAR2
)
RETURN VARCHAR2;

/*----------------------------------------------------------------
  Function In_Loop
  A function returning Boolean.
------------------------------------------------------------------*/
FUNCTION In_Loop
( activity1                                     IN NUMBER
, activity2                                     IN NUMBER
)
RETURN BOOLEAN;

/*----------------------------------------------------------------
  Function Has_Activity
  Determines whether a workflow process contains a particular
  activity (or subprocess) at any level. A function returning
  Boolean.
------------------------------------------------------------------*/
FUNCTION Has_Activity
(  P_process                                    IN VARCHAR2
,  P_process_item_type                          IN VARCHAR2
,  P_activity                                   IN VARCHAR2
,  P_activity_item_type                         IN VARCHAR2
)
RETURN BOOLEAN;

/*----------------------------------------------------------------
  Procedure Get_Activities
  Determines all the activities or a particular activity in a
  workflow process (and subprocess) at any level.
------------------------------------------------------------------*/
PROCEDURE Get_Activities
(  P_process              IN VARCHAR2
,  P_process_item_type    IN VARCHAR2
,  P_instance_label       IN VARCHAR2 DEFAULT NULL
,  P_activity_item_type   IN VARCHAR2 DEFAULT NULL
--,  G_all_activity_tab  OUT NOCOPY OE_VALIDATE_WF.Activities_Tbl_Type
);

/*----------------------------------------------------------------
  Procedure Wait_And_Loops
  Determines whether a workflow process contains a particular
  activity (or subprocess) at any level. A function returning
  Boolean.
------------------------------------------------------------------*/
PROCEDURE Wait_And_Loops
(  P_process                                    IN VARCHAR2
,  P_process_item_type	                        IN VARCHAR2
,  P_activity_id                                IN NUMBER
,  P_activity_label                             IN VARCHAR2
,  P_api                                        IN VARCHAR2
,  X_return_status                              OUT NOCOPY VARCHAR2
);

/*------------------------------------------------------------------
  Procedure Line_Flow_Assignment
  Checks if a particular seeded workflow is incompatible with the OM item
  type to which it is assigned. If so, returns error and puts a message on
  the error stack. Determines  if a customized flow might be incompatible
  with the OM item type to which it is assigned. If yes, returns a warning
  message and puts it on the message stack.
------------------------------------------------------------------*/

PROCEDURE Line_Flow_Assignment
(  P_name                                      IN VARCHAR2
,  P_item_type                                 IN VARCHAR2
,  X_return_status                             OUT NOCOPY VARCHAR2
,  X_msg_count                                 OUT NOCOPY NUMBER
);

/*----------------------------------------------------------------
  Procedure Check_Sync
  Checks if continue/wait p_activity in OEOH/OEOL  process p_process
  has a corresponding wait/continue activity in the OEOL/OEOH
  flow(s) assigned to p_order_type.
------------------------------------------------------------------*/
PROCEDURE Check_Sync
(  P_process                                    IN VARCHAR2
,  P_process_item_type                          IN VARCHAR2
,  P_order_type_id                              IN NUMBER
,  P_order_flow                                 IN VARCHAR2 DEFAULT NULL
,  P_instance_label                             IN VARCHAR2
,  P_act_item_type                              IN VARCHAR2
,  P_function                                   IN VARCHAR2 --Vaibhav
,  P_type                                       IN VARCHAR2 --Vaibhav
,  P_instance_id                                IN NUMBER --Vaibhav
,  X_return_status                              OUT NOCOPY VARCHAR2
);

/*----------------------------------------------------------------
  Procedure Out_Transitions
  Looks for any activity or subprocess in process p_name that has
  no OUT transition defined. If any are found, error status is
  returned and appropriate error messages logged.
------------------------------------------------------------------*/
PROCEDURE Out_Transitions
(  P_name                                       IN VARCHAR2
,  P_type                                       IN VARCHAR2
,  X_return_status                              OUT NOCOPY VARCHAR2
);

/*----------------------------------------------------------------
  Procedure Validate_Line_Flow
------------------------------------------------------------------*/
PROCEDURE Validate_Line_Flow
(  P_name                                        IN VARCHAR2
,  P_order_flow                                  IN VARCHAR2
,  p_quick_val                                   IN BOOLEAN DEFAULT TRUE
,  X_return_status                               OUT NOCOPY VARCHAR2
,  X_msg_count                                   OUT NOCOPY NUMBER
,  X_msg_data                                    OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Line_Flow  /* Bug # 4908592 */
(  P_name                                        IN VARCHAR2
,  P_order_flow                                  IN VARCHAR2
,  p_quick_val                                   IN BOOLEAN DEFAULT TRUE
,  X_return_status                               OUT NOCOPY VARCHAR2
,  X_msg_count                                   OUT NOCOPY NUMBER
,  X_msg_data                                    OUT NOCOPY VARCHAR2
,  p_item_type                                   IN VARCHAR2
);


/*----------------------------------------------------------------
  Procedure Validate_Order_flow
------------------------------------------------------------------*/
PROCEDURE Validate_Order_flow
(  P_name                                        IN VARCHAR2
,  P_order_type_id                               IN NUMBER DEFAULT NULL
,  P_type                                        IN VARCHAR2
,  p_quick_val                                 IN BOOLEAN DEFAULT TRUE
,  X_return_status                               OUT NOCOPY VARCHAR2
,  X_msg_count                                   OUT NOCOPY NUMBER
,  X_msg_data                                    OUT NOCOPY VARCHAR2
);

/*----------------------------------------------------------------
  Procedure Validate
  Validates all order/blanket header, negotiation and line workflow
  processes assigned to order type p_order_type_id. If
  p_order_type_id is NULL, runs the validation for all active order
  types.
------------------------------------------------------------------*/
PROCEDURE Validate
(  Errbuf	                       OUT NOCOPY VARCHAR2  -- AOL standard
,  retcode	                       OUT NOCOPY VARCHAR2  -- AOL standard
,  P_order_type_id                     IN NUMBER DEFAULT NULL
);

END OE_VALIDATE_WF;

 

/
