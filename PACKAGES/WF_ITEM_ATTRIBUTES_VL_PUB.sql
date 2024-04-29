--------------------------------------------------------
--  DDL for Package WF_ITEM_ATTRIBUTES_VL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ITEM_ATTRIBUTES_VL_PUB" AUTHID CURRENT_USER AS
/* $Header: wfdefs.pls 115.18 2002/12/03 01:12:21 dlam ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_item_attributes_vl_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

============================================================================*/


/*===========================================================================

  PL*SQL TABLE NAME:    wf_item_attributes_vl_tbl_type

  DESCRIPTION:          Stores a list of item attribute definitions for
                        the selected item type.

============================================================================*/
TYPE wf_item_attributes_vl_rec_type IS RECORD
(
 row_id                          ROWID,
 item_type                       VARCHAR2(8),
 name                            VARCHAR2(30),
 sequence                        NUMBER,
 type                            VARCHAR2(8),
 protect_level                   NUMBER,
 custom_level                    NUMBER,
 subtype                         VARCHAR2(8),
 format                          VARCHAR2(240),
 lookup_type_display_name        VARCHAR2(80),
 lookup_code_display_name        VARCHAR2(80),
 text_default                    VARCHAR2(4000),
 number_default                  NUMBER,
 date_default                    DATE,
 display_name                    VARCHAR2(80),
 description                     VARCHAR2(240)
);

 TYPE wf_item_attributes_vl_tbl_type IS TABLE OF
 wf_item_attributes_vl_pub.wf_item_attributes_vl_rec_type
 INDEX BY BINARY_INTEGER;

/*===========================================================================
  PROCEDURE NAME:       fetch_item_attributes

  DESCRIPTION:          Fetches all the attributes for a given item type
                        into a p_wf_item_attributes_vl_tbl table based on the
                        item type internal eight character name.  This function
                        can also retrieve a single item attribute definition if
                        the internal name along with the item type name is
                        provided.  This is especially useful if you wish to
                        display the details for a single attribute when it
                        is referenced from some drilldown mechanism.

  PARAMETERS:

        p_item_type IN  Internal name of the item type

        p_name IN (optional)
                        Internal name of the item attribute

        p_wf_item_attributes_vl_tbl OUT
                        The pl*sql table with the detailed definition of
                        the item attributes

============================================================================*/
 PROCEDURE fetch_item_attributes
     (p_item_type       IN  VARCHAR2,
      p_name            IN  VARCHAR2,
      p_wf_item_attributes_vl_tbl   OUT NOCOPY wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type);

/*===========================================================================
  PROCEDURE NAME:       fetch_item_attribute_display

  DESCRIPTION:          fetch the item attribute display name based on an item
                        type and an item attribute internal name

  PARAMETERS:
        p_item_type IN
                        Internal name of the item type

        p_internal_name IN
                        Internal name of the item attribute

        p_display_name IN
                        Display name  of the item attribute
============================================================================*/
PROCEDURE fetch_item_attribute_display (p_item_type     IN VARCHAR2,
                                        p_internal_name IN VARCHAR2,
                                        p_display_name  OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       draw_item_attribute_list

  DESCRIPTION:          Shows the display name of an item attribute as a
                        html view as a part of a hierical summary list of
                        an item type.  This function uses the htp to
                        generate its html output.

  PARAMETERS:

        p_wf_item_attributes_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the item attributes

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
 PROCEDURE draw_item_attribute_list
     (p_wf_item_attributes_vl_tbl IN wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type,
      p_effective_date            IN DATE,
      p_indent_level        IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:       draw_item_attribute_details

  DESCRIPTION:          Shows all the details of an item attrribute as a
                        html view.  This function uses the htp to
                        generate its html output.

  PARAMETERS:

        p_wf_item_attributes_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the item attributes

        p_indent_level IN
                        How many space would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
 PROCEDURE draw_item_attribute_details
     (p_wf_item_attributes_vl_tbl IN wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type,
      p_indent_level        IN NUMBER);

END wf_item_attributes_vl_pub;

 

/
