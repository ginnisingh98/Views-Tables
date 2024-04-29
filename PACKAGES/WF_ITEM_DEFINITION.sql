--------------------------------------------------------
--  DDL for Package WF_ITEM_DEFINITION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ITEM_DEFINITION" AUTHID CURRENT_USER AS
/* $Header: wfdefs.pls 115.18 2002/12/03 01:12:21 dlam ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_item_definition

  DESCRIPTION:

  OWNER:                GKELLNER

============================================================================*/

/*===========================================================================
  PROCEDURE NAME:       find_item_type

  DESCRIPTION:
                        Main Find View drawing routine.  This is the
                        main entry point into the Item Type
                        Definition View.  This view has two attributes: The
                        Item Type List shows all the Items Types that
                        are currently stored in the Workflow database
                        repository.  The effective date allows you to
                        chose which date you would like the view to be
                        effective for.   Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.
                        Once the user clicks on the Find buttton from
                        this view, the draw_item_type function takes over to
                        create the Item Type Definition.

  PARAMETERS:

============================================================================*/
 PROCEDURE find_item_type;

/*===========================================================================
  PROCEDURE NAME:       draw_item_type

  DESCRIPTION:          Main routine that will create a three framed
                        view that shows the complete definition of an
                        item type.  The top frame is the view header.
                        It show the title of the view along with
                        controls to return to the find window, return
                        to the main menu or exit the system.  It then
                        displays the Item Type Summary and Item Type
                        Details in two separate frame below the header frame.
                        The left frame consists of the hierarchical summary
                        of the Item Type Definition showing all display
                        names for attributes, processes, notifications,
                        functions, etc.  The right frame consists of
                        a complete listing of all the objects and their
                        associated properties for the given item type.


                        The frames are constructed in the following manner:
                         ______________________
                        |                     |
                        |       HEADER        |
                        |---------------------|
                        |          |          |
                        |          |          |
                        | SUMMARY  |  DETAILS |
                        |          |          |
                        |          |          |
                        |---------------------|


  PARAMETERS:

        p_item_type IN  Internal name of the item type that was selected
                        in the find window.

        p_effective_date IN
                        The requested effective date.  Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.

============================================================================*/
 PROCEDURE draw_item_type(
  p_item_type           VARCHAR2 DEFAULT NULL,
  p_effective_date      VARCHAR2 DEFAULT NULL);



/*===========================================================================
  PROCEDURE NAME:       draw_item_summary

  DESCRIPTION:          Draws a hierarchical summary of the Item
                        Type Definition showing all display names for
                        attributes, processes, notifications, functions,
                        etc.  The following is an example of the output:

Workflow Requisition Approval Demonstration
      Attributes
            Forward From Display Name
            Forward From Username
            Forward To Display Name
            Forward To Username
      Processes
            Notify Approver
            Requisition Approval
      Notifications
            Notifify Requestor of Approval
            Notify Requestor No Approver Available
            Reminder-Approval Needed
      Functions
            Approve Requisition
            Verify Authority
      Messages
            Requisition Approval Required
                  Message Attributes
                        Requisition Amount
                        Action
etc...

  PARAMETERS:

        p_item_type IN  Internal name of the item type that was selected
                        in the find window.

        p_effective_date IN
                        The requested effective date.  Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.

============================================================================*/
 PROCEDURE draw_item_summary(
  p_item_type           VARCHAR2 DEFAULT NULL,
  p_effective_date      VARCHAR2 DEFAULT NULL);


/*===========================================================================
  PROCEDURE NAME:       draw_item_details

  DESCRIPTION:          Draws a complete listing of all the objects and their
                        associated properties for the given item type.
                        The following is an example of the output:


Item Type Details
----------------------------------------------------------------------------
     Item Type Name Workflow Requisition Approval Demonstration
      Internal Name WFREQAPP
        Description
           Selector WF_REQDEMO.SELECTOR
          Read Role
         Write Role
       Execute Role
Customization Level 0
   Protection Level 100

Attribute Details
----------------------------------------------------------------------------
     Attribute Name Forward From Display Name
      Internal Name FORWARD_FROM_DISPLAY_NAME
        Description Name of the person that the requisition is forwarded
                    from
     Attribute Type VARCHAR2
             Format
            Default
Customization Level 0
   Protection Level 100
etc...

  PARAMETERS:

        p_item_type IN  Internal name of the item type that was selected
                        in the find window.

        p_effective_date IN
                        The requested effective date.  Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.

============================================================================*/
 PROCEDURE draw_item_details(
  p_item_type           VARCHAR2 DEFAULT NULL,
  p_effective_date      VARCHAR2 DEFAULT NULL);

/*===========================================================================
  PROCEDURE NAME:       draw_header

  DESCRIPTION:
                        Draws the top frame of the Item Definition View.
                        It show the title of the view along with
                        controls to return to the find window, return
                        to the main menu or exit the system.

  PARAMETERS:

        p_item_type IN  Internal name of the item type that was selected
                        in the find window.

        p_effective_date IN
                        The requested effective date.  Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.

        p_caller IN     Tells the procedure which title to display (FIND, DISPLAY)


============================================================================*/
 PROCEDURE draw_header (
  p_item_type           VARCHAR2 DEFAULT NULL,
  p_effective_date      VARCHAR2 DEFAULT NULL,
  p_caller              VARCHAR2 DEFAULT NULL);


/*===========================================================================
  PROCEDURE NAME:       error

  DESCRIPTION:
                        Print a page with an error message.
                        Errors are retrieved from these sources in order:
                             1. wf_core errors
                             2. Oracle errors
                             3. Unspecified INTERNAL error

  PARAMETERS:


============================================================================*/
 PROCEDURE error;

/*===========================================================================
  PROCEDURE NAME:       draw_error

  DESCRIPTION:          Draws the bottom frame for the error message if an
                        invalid date has been entered

  PARAMETERS:
        p_effective_date IN
                        Invalid date user entered

        pexpected_format IN
                        Format that the window expects
============================================================================*/
PROCEDURE draw_error (p_effective_date  IN      VARCHAR2 DEFAULT NULL,
                      p_expected_format IN      VARCHAR2 DEFAULT NULL);


/*===========================================================================
  PROCEDURE NAME:       fetch_item_definition_url

  DESCRIPTION:          Fetches the url address to initiate the
                        Item Definition View

  PARAMETERS:
        p_item_definition_url OUT
                        Returns the name of the url to initiate the
                        Item Definition View

============================================================================*/
PROCEDURE fetch_item_definition_url (p_item_definition_url OUT NOCOPY VARCHAR2);



END wf_item_definition;

 

/
