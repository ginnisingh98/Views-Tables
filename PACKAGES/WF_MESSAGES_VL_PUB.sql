--------------------------------------------------------
--  DDL for Package WF_MESSAGES_VL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_MESSAGES_VL_PUB" AUTHID CURRENT_USER AS
/* $Header: wfdefs.pls 115.18 2002/12/03 01:12:21 dlam ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_messages_vl_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

============================================================================*/

/*===========================================================================

  PL*SQL TABLE NAME:     wf_messages_vl_tbl_type

  DESCRIPTION:          Stores a list of message definitions for
                        the selected item type.

============================================================================*/
TYPE wf_messages_vl_rec_type  IS RECORD
(
 ROW_ID                         ROWID,
 TYPE                           VARCHAR2(8),
 NAME                           VARCHAR2(30),
 PROTECT_LEVEL                  NUMBER,
 CUSTOM_LEVEL                   NUMBER,
 DEFAULT_PRIORITY               NUMBER,
 READ_ROLE                      VARCHAR2(320),
 WRITE_ROLE                     VARCHAR2(320),
 DISPLAY_NAME                   VARCHAR2(80),
 DESCRIPTION                    VARCHAR2(240),
 SUBJECT                        VARCHAR2(240),
 HTML_BODY                      VARCHAR2(4000),
 BODY                           VARCHAR2(4000));

 TYPE wf_messages_vl_tbl_type IS TABLE OF
    wf_messages_vl_pub.wf_messages_vl_rec_type
 INDEX BY BINARY_INTEGER;


/*===========================================================================

  PL*SQL TABLE NAME:    wf_message_attr_vl_tbl_type

  DESCRIPTION:          Stores a list of message attributes based on the
                        fetch_message_attributes cursor shown above.

============================================================================*/
TYPE wf_message_attr_vl_rec_type IS RECORD
(
 message_display_name            VARCHAR2(80),
 attr_default_display_name       VARCHAR2(80),
 lookup_type_display_name        VARCHAR2(80),
 lookup_code_display_name        VARCHAR2(80),
 row_id                          ROWID,
 message_type                    VARCHAR2(8),
 message_name                    VARCHAR2(30),
 name                            VARCHAR2(30),
 sequence                        NUMBER,
 type                            VARCHAR2(8),
 subtype                         VARCHAR2(8),
 attach                          VARCHAR2(1),
 value_type                      VARCHAR2(8),
 protect_level                   NUMBER,
 custom_level                    NUMBER,
 format                          VARCHAR2(240),
 text_default                    VARCHAR2(4000),
 number_default                  NUMBER,
 date_default                    DATE,
 display_name                    VARCHAR2(80),
 description                     VARCHAR2(240)
);

 TYPE wf_message_attr_vl_tbl_type IS TABLE OF
 wf_messages_vl_pub.wf_message_attr_vl_rec_type
 INDEX BY BINARY_INTEGER;


/*===========================================================================
  PROCEDURE NAME:       fetch_messages

  DESCRIPTION:          Fetches all the messages and each message
                        associate attributes for a given item type
                        into a p_wf_messages_vl_tbl table and a
                        p_wf_message_attr_vl_tbl table based on the
                        item type internal eight character name. This
                        function can retrieve a single message
                        definition if the internal name along with the
                        item type name is provided.  This is especially
                        useful if you wish to display the details for a
                        single message when it is referenced from some
                        drilldown mechanism.

                        The p_wf_messages_vl_tbl table and the
                        p_wf_message_attr_vl_tbl table are synchronized by
                        the select order of both queries.  The
                        draw_message_list and draw_message_details functions
                        take advantage of this ordering for performance reasons
                        so they can walk these lists in parallel.
                        When we find an attribute that matches
                        the current message, we copy that attribute to a temp
                        list until we find a new message in the attribute
                        list.  When this happens we write out the attribute
                        temp list and move to the next activity.


  PARAMETERS:

        p_item_type IN  Internal name of the item type

        p_name IN (optional)
                        Internal name of the message

        p_wf_messages_vl_tbl OUT
                        The pl*sql table with the detailed definition of
                        the messages for this item type

        p_wf_message_attr_vl_tbl OUT
                        The pl*sql table with the detailed definition of
                        the message attributes

============================================================================*/
 PROCEDURE fetch_messages
     (p_item_type          IN  VARCHAR2,
      p_name               IN  VARCHAR2,
      p_wf_messages_vl_tbl OUT NOCOPY wf_messages_vl_pub.wf_messages_vl_tbl_type,
      p_wf_message_attr_vl_tbl OUT NOCOPY wf_messages_vl_pub.wf_message_attr_vl_tbl_type);

/*===========================================================================
  PROCEDURE NAME:       draw_message_list

  DESCRIPTION:          Shows the display name of a message along with
                        any message attributes for that message that
                        have been passed in as a html view as a part of
                        a hierical summary list of an item type.
                        This function uses the htp to generate its html
                        output.

                        When we find an attribute that matches
                        the message activity, we copy that attribute and all
                        that follow for that message to a temp
                        list until we find a new activity in the attribute
                        list.  When this happens we write out the attributes
                        using the draw_message_attr_list.

  PARAMETERS:

        p_wf_messages_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the messages for this item type

        p_wf_message_attr_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the message attributes

        p_effective_date IN
                        The effective date that was requested.
                        This is required if you would like to create
                        hotlinks between a summary frame view and your
                        detail frame view.  Since the listing are usually
                        implemented as frames the links need to include
                        all the attributes that were used to generate those
                        frames.

        p_indent_level IN
                        How many spaces would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
 PROCEDURE draw_message_list
     (p_wf_messages_vl_tbl IN wf_messages_vl_pub.wf_messages_vl_tbl_type,
      p_wf_message_attr_vl_tbl IN wf_messages_vl_pub.wf_message_attr_vl_tbl_type,
      p_effective_date     IN DATE,
      p_indent_level       IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:       fetch_message_display

  DESCRIPTION:          fetch the messagedisplay name based on a item
                        type name and an internal item message name

  PARAMETERS:
        p_item_type IN
                        Internal name of the item type

        p_internal_name IN
                        Internal name of the message

        p_display_name IN
                        Display name  of the message
============================================================================*/
PROCEDURE fetch_message_display        (p_item_type     IN VARCHAR2,
                                        p_internal_name IN VARCHAR2,
                                        p_display_name  OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       draw_message_attr_list

  DESCRIPTION:          Shows the display names of message attributes for
                        a given message as a html view as a part of
                        a hierical summary list of an item type.
                        This function uses the htp to generate its html
                        output.

  PARAMETERS:

        p_wf_message_attr_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the message attributes

        p_effective_date IN
                        The effective date that was requested.
                        This is required if you would like to create
                        hotlinks between a summary frame view and your
                        detail frame view.  Since the listing are usually
                        implemented as frames the links need to include
                        all the attributes that were used to generate those
                        frames.

        p_indent_level IN
                        How many spaces would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
PROCEDURE draw_message_attr_list
     (p_wf_message_attr_vl_tbl IN wf_messages_vl_pub.wf_message_attr_vl_tbl_type,
      p_effective_date     IN DATE,
      p_indent_level       IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:       draw_message_details

  DESCRIPTION:          Shows all of the details for a list of messages
                        along with any message attribute details for that
                        message that have been passed in.  The listing is
                        shown as message detail and then corresponding
                        attributes and then another message and then its detail

                        When we find an attribute that matches
                        the current message, we copy that attribute and all
                        that follow for that message to a temp
                        list until we find a new message in the attribute
                        list.  When this happens we write out the attributes
                        using the draw_message_attr_details function.


  PARAMETERS:

        p_wf_messages_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the messages for this item type

        p_wf_message_attr_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the message attributes

        p_indent_level IN
                        How many spaces would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
PROCEDURE draw_message_details
     (p_wf_messages_vl_tbl IN wf_messages_vl_pub.wf_messages_vl_tbl_type,
      p_wf_message_attr_vl_tbl IN wf_messages_vl_pub.wf_message_attr_vl_tbl_type,
      p_indent_level       IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:       draw_message_attr_details

  DESCRIPTION:          Shows all of the details for a list of
                        message attributes for that have been passed
                        in.

  PARAMETERS:


        p_wf_message_attr_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the message attributes

        p_indent_level IN
                        How many spaces would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
 PROCEDURE draw_message_attr_details
     (p_wf_message_attr_vl_tbl IN wf_messages_vl_pub.wf_message_attr_vl_tbl_type,
      p_indent_level       IN NUMBER);

END wf_messages_vl_pub;

 

/
