--------------------------------------------------------
--  DDL for Package WF_ACTIVITIES_VL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ACTIVITIES_VL_PUB" AUTHID CURRENT_USER AS
/* $Header: wfdefs.pls 115.18 2002/12/03 01:12:21 dlam ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_activities_vl_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

============================================================================*/

/*===========================================================================

  PL*SQL TABLE NAME:     wf_activities_vl_tbl_type

  DESCRIPTION:          Stores a list of activity definitions for
                        the selected item type.

============================================================================*/

TYPE  wf_activities_vl_rec_type IS RECORD
(
 row_id                          ROWID,
 item_type                       VARCHAR2(8),
 name                            VARCHAR2(30),
 version                         NUMBER,
 type                            VARCHAR2(8),
 rerun                           VARCHAR2(8),
 expand_role                     VARCHAR2(1),
 protect_level                   NUMBER,
 custom_level                    NUMBER,
 begin_date                      DATE,
 end_date                        DATE,
 function                        VARCHAR2(240),
 function_type                   VARCHAR2(30),
 result_type                     VARCHAR2(30),
 cost                            NUMBER,
 read_role                       VARCHAR2(320),
 write_role                      VARCHAR2(320),
 execute_role                    VARCHAR2(320),
 icon_name                       VARCHAR2(30),
 message                         VARCHAR2(30),
 error_process                   VARCHAR2(30),
 runnable_flag                   VARCHAR2(1),
 error_item_type                 VARCHAR2(8),
 event_name                      VARCHAR2(240),
 direction                       VARCHAR2(30),
 display_name                    VARCHAR2(80),
 result_type_display_name        VARCHAR2(80),
 message_display_name            VARCHAR2(80),
 description                     VARCHAR2(240)
);

 TYPE wf_activities_vl_tbl_type IS TABLE OF
 wf_activities_vl_pub.wf_activities_vl_rec_type
 INDEX BY BINARY_INTEGER;



/*===========================================================================

  PL*SQL TABLE NAME:    wf_activity_attr_vl_tbl_type

  DESCRIPTION:          Stores a list of activity attributes based on the
                        fetch_activity_attributes cursor shown above.

============================================================================*/
TYPE wf_activity_attr_vl_rec_type IS RECORD
(
 activity_type                   VARCHAR2(8),
 activity_display_name           VARCHAR2(80),
 attr_default_display_name       VARCHAR2(80),
 lookup_type_display_name        VARCHAR2(80),
 lookup_code_display_name        VARCHAR2(80),
 row_id                          ROWID,
 activity_item_type              VARCHAR2(8),
 activity_name                   VARCHAR2(30),
 activity_version                NUMBER,
 name                            VARCHAR2(30),
 sequence                        NUMBER,
 type                            VARCHAR2(8),
 value_type                      VARCHAR2(8),
 protect_level                   NUMBER,
 custom_level                    NUMBER,
 subtype                         VARCHAR2(8),
 format                          VARCHAR2(240),
 text_default                    VARCHAR2(4000),
 number_default                  NUMBER,
 date_default                    DATE,
 display_name                    VARCHAR2(80),
 description                     VARCHAR2(240)
);

 TYPE wf_activity_attr_vl_tbl_type IS TABLE OF
 wf_activities_vl_pub.wf_activity_attr_vl_rec_type
 INDEX BY BINARY_INTEGER;


/*===========================================================================
  PROCEDURE NAME:       fetch_activities

  DESCRIPTION:          Fetches all the activities and each activities
                        associate attributes for a given item type
                        into a p_wf_activities_vl_tbl table and a
                        p_wf_activity_attr_vl_tbl table based on the
                        item type internal eight character name and the
                        effective_date for the activities.  This function
                        can retrieve just one type of activity list like only
                        the processes or notification or it can retrieve
                        all the activity types for a given item type. This
                        function can also retrieve a single activity
                        definition if the internal name along with the
                        item type name is provided.  This is especially
                        useful if you wish to display the details for a
                        single activity when it is referenced from some
                        drilldown mechanism.

                        The p_wf_activities_vl_tbl table and the
                        p_wf_activity_attr_vl_tbl table are synchronized by
                        the select order of both queries.  The
                        draw_activity_list and draw_activity_details functions
                        take advantage of this ordering for performance reasons
                        so they can walk these lists in parallel.
                        When we find an attribute that matches
                        the current activity, we copy that attribute to a temp
                        list until we find a new activity in the attribute
                        list.  When this happens we write out the attribute
                        temp list and move to the next activity.


  PARAMETERS:

        p_item_type IN  Internal name of the item type

        p_activity_type IN (optional)
                        The type of activity you would like to retrieve.
                        Values: PROCESS, NOTICE, FUNCTION

        p_effective_date IN
                        The requested effective date.  Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.

        p_name IN (optional)
                        Internal name of the activity

        p_wf_activities_vl_tbl OUT
                        The pl*sql table with the detailed definition of
                        the activities for this item type

        p_wf_activity_attr_vl_tbl OUT
                        The pl*sql table with the detailed definition of
                        the activity attributes

============================================================================*/
 PROCEDURE fetch_activities
     (p_item_type       IN  VARCHAR2,
      p_activity_type   IN  VARCHAR2,
      p_effective_date  IN  DATE,
      p_name            IN  VARCHAR2,
      p_wf_activities_vl_tbl   OUT NOCOPY wf_activities_vl_pub.wf_activities_vl_tbl_type,
      p_wf_activity_attr_vl_tbl   OUT NOCOPY wf_activities_vl_pub.wf_activity_attr_vl_tbl_type);

/*===========================================================================
  PROCEDURE NAME:       fetch_draw_activity_details

  DESCRIPTION:          Fetches and draws a single activity for a
                        given item type.  This function is basically
                        a cover for the fetch_activities and
                        draw_activity_details routines.
  PARAMETERS:

        p_item_type IN  Internal name of the item type

        p_activity_type IN
                        The type of activity you would like to retrieve.
                        Values: PROCESS, NOTICE, FUNCTION

        p_effective_date IN
                        The requested effective date.  Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.

        p_name IN
                        Internal name of the activity

============================================================================*/
 PROCEDURE fetch_draw_activity_details
     (p_item_type       IN  VARCHAR2,
      p_activity_type   IN  VARCHAR2,
      p_effective_date  IN  VARCHAR2,
      p_name            IN  VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       draw_activity_list

  DESCRIPTION:          Shows the display name of an activity along with
                        any activity attributes for that activity that
                        have been passed in as a html view as a part of
                        a hierical summary list of an item type.
                        This function uses the htp to generate its html
                        output.

                        When we find an attribute that matches
                        the current activity, we copy that attribute and all
                        that follow for that activity to a temp
                        list until we find a new activity in the attribute
                        list.  When this happens we write out the attributes
                        using the draw_activity_attr_list.

  PARAMETERS:

        p_wf_activities_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the activities for this item type

        p_wf_activity_attr_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the activity attributes

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
PROCEDURE draw_activity_list
     (p_wf_activities_vl_tbl IN wf_activities_vl_pub.wf_activities_vl_tbl_type,
      p_wf_activity_attr_vl_tbl IN wf_activities_vl_pub.wf_activity_attr_vl_tbl_type,
      p_effective_date       IN DATE,
      p_indent_level         IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:       draw_activity_attr_list

  DESCRIPTION:          Shows the display names of activity attributes for
                        a given activity as a html view as a part of
                        a hierical summary list of an item type.
                        This function uses the htp to generate its html
                        output.

  PARAMETERS:

        p_wf_activity_attr_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the activity attributes

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
PROCEDURE draw_activity_attr_list
     (p_wf_activity_attr_vl_tbl IN wf_activities_vl_pub.wf_activity_attr_vl_tbl_type,
      p_effective_date       IN DATE,
      p_indent_level         IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:       draw_activity_details

  DESCRIPTION:          Shows all of the details for a list of activities
                        along with any activity attribute details for that
                        activity that have been passed in.  The listing is
                        shown as activity detail and then corresponding
                        attributes and then another activity and then its

                        When we find an attribute that matches
                        the current activity, we copy that attribute and all
                        that follow for that activity to a temp
                        list until we find a new activity in the attribute
                        list.  When this happens we write out the attributes
                        using the draw_activity_attr_details function.


  PARAMETERS:

        p_wf_activities_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the activities for this item type

        p_wf_activity_attr_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the activity attributes

        p_effective_date IN
                        The effective date that was requested.
                        This is required if you would like to create
                        hotlinks between the notification details and the
                        corresponding message details.  I'm investigating
                        whenther the full parameter list is required for
                        a link within the same frame since the notification
                        and message details would be in the same frame.

        p_indent_level IN
                        How many spaces would you like to indent this
                        listing from the left border of the screen.

        p_create_child_links IN
                        Tells the function whether to create the hot link
                        between an activity and any child object related to
                        that activity.  For example you may wish to link
                        a notification message name with its corresponding
                        details.  If you have no intention of listing those
                        message details then you want to pass FALSE for the
                        p_create_child_links parameter.  Otherwise you would
                        pass TRUE.


        p_print_skipped_titles IN
                        Tells the function whether to print titles for activity
                        types that have been skipped.  This is useful when
                        you're calling this function to draw a single activity in
                        which case you would pass FALSE.
                        If you're listing all activities for a given item type
                        then you probably do want to list all activity type titles
                        so you probably want to pass TRUE
============================================================================*/
PROCEDURE draw_activity_details
     (p_wf_activities_vl_tbl IN wf_activities_vl_pub.wf_activities_vl_tbl_type,
      p_wf_activity_attr_vl_tbl IN wf_activities_vl_pub.wf_activity_attr_vl_tbl_type,
      p_effective_date       IN DATE,
      p_indent_level         IN NUMBER,
      p_create_child_links   IN BOOLEAN,
      p_print_skipped_titles IN BOOLEAN);

/*===========================================================================
  PROCEDURE NAME:       draw_activity_attr_details

  DESCRIPTION:          Shows all of the details for a list of
                        activity attributes for that have been passed
                        in.

  PARAMETERS:


        p_wf_activity_attr_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the activity attributes

        p_indent_level IN
                        How many spaces would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
PROCEDURE draw_activity_attr_details
     (p_wf_activity_attr_vl_tbl IN wf_activities_vl_pub.wf_activity_attr_vl_tbl_type,
      p_indent_level              IN NUMBER);

END wf_activities_vl_pub;

 

/
