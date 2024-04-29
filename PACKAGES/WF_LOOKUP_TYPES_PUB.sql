--------------------------------------------------------
--  DDL for Package WF_LOOKUP_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_LOOKUP_TYPES_PUB" AUTHID CURRENT_USER AS
/* $Header: wfdefs.pls 115.18 2002/12/03 01:12:21 dlam ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_lookup_types_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

============================================================================*/

/*===========================================================================

  PL*SQL TABLE NAME:     wf_lookup_types_tbl_type

  DESCRIPTION:          Stores a list of lookup type definitions for
                        the selected item type.

============================================================================*/
TYPE wf_lookup_types_rec_type  IS RECORD
(
 ROW_ID                         ROWID,
 LOOKUP_TYPE                    VARCHAR2(30),
 ITEM_TYPE                      VARCHAR2(8),
 PROTECT_LEVEL                  NUMBER,
 CUSTOM_LEVEL                   NUMBER,
 DISPLAY_NAME                   VARCHAR2(80),
 DESCRIPTION                    VARCHAR2(240)
);

 TYPE wf_lookup_types_tbl_type IS TABLE OF
    wf_lookup_types_pub.wf_lookup_types_rec_type
 INDEX BY BINARY_INTEGER;


/*===========================================================================

  PL*SQL TABLE NAME:    wf_lookups_tbl_type

  DESCRIPTION:          Stores a list of lookups based on the
                        fetch_lookups cursor shown above.

============================================================================*/
TYPE wf_lookups_rec_type  IS RECORD
(
 lookup_type_display_name        VARCHAR2(80),
 item_type                       VARCHAR2(8),
 row_id                          ROWID,
 lookup_type                     VARCHAR2(30),
 lookup_code                     VARCHAR2(30),
 protect_level                   NUMBER,
 custom_level                    NUMBER,
 meaning                         VARCHAR2(80),
 description                     VARCHAR2(240)
);

 TYPE wf_lookups_tbl_type IS TABLE OF
 wf_lookup_types_pub.wf_lookups_rec_type
 INDEX BY BINARY_INTEGER;

/*===========================================================================
  PROCEDURE NAME:       fetch_lookup_types

  DESCRIPTION:          Fetches all the lookup types for a given item type
                        into a p_wf_lookup_types_vl_tbl table based on the
                        item type internal eight character name.  This function
                        can also retrieve a single lookup type definition if
                        the internal name along with the item type name is
                        provided.  This is especially useful if you wish to
                        display the details for a single lookup type when it
                        is referenced from some drilldown mechanism.

  PARAMETERS:

        p_item_type IN  Internal name of the item type

        p_name IN (optional)
                        Internal name of the lookup type

        p_wf_lookup_types_tbl OUT
                        The pl*sql table with the detailed definition of
                        the lookup types

        p_wf_lookups_tbl OUT
                        The pl*sql table with the detailed definition of
                        the lookups

============================================================================*/
 PROCEDURE fetch_lookup_types
     (p_item_type       IN  VARCHAR2,
      p_lookup_type     IN  VARCHAR2,
      p_wf_lookup_types_tbl   OUT NOCOPY wf_lookup_types_pub.wf_lookup_types_tbl_type,
      p_wf_lookups_tbl        OUT NOCOPY wf_lookup_types_pub.wf_lookups_tbl_type);

/*===========================================================================
  PROCEDURE NAME:       fetch_lookup_display

  DESCRIPTION:          fetch the lookup type display name and the lookup code
                        display name based on a lookup type internal name and
                        lookup code internal name

  PARAMETERS:

        p_type_internal_name IN
                        Internal name of the lookup type

        p_type_internal_code IN
                        Internal name of the lookup code

        p_type_display_name IN
                        Display name of the lookup type

        p_code_display_name IN
                        Display name of the lookup code
============================================================================*/
PROCEDURE fetch_lookup_display (p_type_internal_name IN VARCHAR2,
                                p_code_internal_name IN VARCHAR2,
                                p_type_display_name  OUT NOCOPY VARCHAR2,
                                p_code_display_name  OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       draw_lookup_type_list

  DESCRIPTION:          Shows the display name of lookup type as a
                        html view as a part of a hierical summary list of
                        an item type.  This function uses the htp to
                        generate its html output.

  PARAMETERS:

        p_wf_lookup_types_tbl IN
                        The pl*sql table with the detailed definition of
                        the lookup types

        p_wf_lookups_tbl IN
                        The pl*sql table with the detailed definition of
                        the lookups

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
 PROCEDURE draw_lookup_type_list
     (p_wf_lookup_types_tbl IN wf_lookup_types_pub.wf_lookup_types_tbl_type,
      p_wf_lookups_tbl      IN wf_lookup_types_pub.wf_lookups_tbl_type,
      p_effective_date      IN DATE,
      p_indent_level        IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:       draw_lookup_list

  DESCRIPTION:          Shows the display name of lookups as a
                        html view as a part of a hierical summary list of
                        an item type.  This function uses the htp to
                        generate its html output.

  PARAMETERS:

        p_wf_lookups_tbl IN
                        The pl*sql table with the detailed definition of
                        the lookups

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
 PROCEDURE draw_lookup_list
     (p_wf_lookups_tbl      IN wf_lookup_types_pub.wf_lookups_tbl_type,
      p_effective_date      IN DATE,
      p_indent_level        IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:       draw_lookup_type_details

  DESCRIPTION:          Shows all the details of an lookup type as a
                        html view.  This function uses the htp to
                        generate its html output.

  PARAMETERS:

        p_wf_lookup_type_tbl IN
                        The pl*sql table with the detailed definition of
                        the lookup type

        p_wf_lookups_tbl IN
                        The pl*sql table with the detailed definition of
                        the lookups

        p_indent_level IN
                        How many space would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
 PROCEDURE draw_lookup_type_details
     (p_wf_lookup_types_tbl IN wf_lookup_types_pub.wf_lookup_types_tbl_type,
      p_wf_lookups_tbl      IN wf_lookup_types_pub.wf_lookups_tbl_type,
      p_indent_level        IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:       draw_lookup_details

  DESCRIPTION:          Shows all the details of a lookup as a
                        html view.  This function uses the htp to
                        generate its html output.

  PARAMETERS:

        p_wf_lookups_tbl IN
                        The pl*sql table with the detailed definition of
                        the lookups

        p_indent_level IN
                        How many space would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
 PROCEDURE draw_lookup_details
     (p_wf_lookups_tbl      IN wf_lookup_types_pub.wf_lookups_tbl_type,
      p_indent_level        IN NUMBER);

END wf_lookup_types_pub;

 

/
