--------------------------------------------------------
--  DDL for Package WF_ITEM_TYPES_VL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ITEM_TYPES_VL_PUB" AUTHID CURRENT_USER AS
/* $Header: wfdefs.pls 115.18 2002/12/03 01:12:21 dlam ship $  */


/*===========================================================================
  PACKAGE NAME:         wf_item_types_vl_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

  MODIFICATION LOG: 01/2002 JWSMITH BUG 2001012 - Increase read_role,
                    write_role, execute_role to varchar2(320)

============================================================================*/

/*===========================================================================

  PL*SQL TABLE NAME:    wf_item_types_vl_tbl_type

  DESCRIPTION:          Stores a list of item types or workflow definitions.
                        Typically you will only ever have one row in
                        this table as it is the master for all the objects
                        within this workflow definition.

============================================================================*/

TYPE wf_item_types_vl_rec_type IS RECORD
(
 ROW_ID                          ROWID,
 NAME                            VARCHAR2(8),
 PROTECT_LEVEL                   NUMBER,
 CUSTOM_LEVEL                    NUMBER,
 WF_SELECTOR                     VARCHAR2(240),
 READ_ROLE                       VARCHAR2(320),
 WRITE_ROLE                      VARCHAR2(320),
 EXECUTE_ROLE                    VARCHAR2(320),
 DISPLAY_NAME                    VARCHAR2(80),
 DESCRIPTION                     VARCHAR2(240)
);

 TYPE wf_item_types_vl_tbl_type IS TABLE OF
    wf_item_types_vl_pub.wf_item_types_vl_rec_type
 INDEX BY BINARY_INTEGER;


/*===========================================================================
  PROCEDURE NAME:       fetch_item_type

  DESCRIPTION:          Fetches all the properties of a given item type
                        into a wf_item_types_vl_tbl_type table based on the
                        item type internal eight character name.

  PARAMETERS:

        p_name IN       Internal name of the item type

        p_wf_item_types_vl_tbl OUT
                        The pl*sql table with the detailed definition of
                        the item type

============================================================================*/
 PROCEDURE fetch_item_type
     (p_name                   IN  VARCHAR2,
      p_wf_item_types_vl_tbl   OUT NOCOPY wf_item_types_vl_pub.wf_item_types_vl_tbl_type);

/*===========================================================================
  PROCEDURE NAME:       draw_item_type_list

  DESCRIPTION:          Shows the display name of an item type as a
                        html view as a part of a hierical summary list of
                        an item type.  This function uses the htp to
                        generate its html output.

  PARAMETERS:

        p_wf_item_types_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the item type

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
 PROCEDURE draw_item_type_list
     (p_wf_item_types_vl_tbl
           IN wf_item_types_vl_pub.wf_item_types_vl_tbl_type,
      p_effective_date            IN DATE,
      p_indent_level              IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:       draw_item_type_details

  DESCRIPTION:          Shows all the details of an item type as a
                        html view.  This function uses the htp to
                        generate its html output.

  PARAMETERS:

        p_wf_item_types_vl_tbl IN
                        The pl*sql table with the detailed definition of
                        the item type

        p_indent_level IN
                        How many space would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
 PROCEDURE draw_item_type_details
     (p_wf_item_types_vl_tbl   IN wf_item_types_vl_pub.wf_item_types_vl_tbl_type,
      p_indent_level        IN NUMBER);


END wf_item_types_vl_pub;

 

/
