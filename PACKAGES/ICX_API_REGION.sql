--------------------------------------------------------
--  DDL for Package ICX_API_REGION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_API_REGION" AUTHID CURRENT_USER as
/* $Header: ICXREGS.pls 115.2 1999/12/09 22:54:07 pkm ship      $ */

   /**
    * ICX_API_REGION - Create/Edit/Delete Regions for pages
    *
    * This package contains procedures to create, edit
    * and delete regions for pages. It also contains
    * procedures to modify the attributes of a region.
    *
    * @Scope    Internal
    *
    */


    REGION_NOT_SPLIT                constant number  := -1;
    REGION_HORIZONTAL_SPLIT         constant number  :=  1;
    REGION_VERTICAL_SPLIT           constant number  :=  0;
    MAIN_REGION                     constant integer :=  0;
    REGION_HORIZONTAL_PORTLETFLOW   constant integer :=  1;
    REGION_VERTICAL_PORTLETFLOW     constant integer :=  0;
    REGION_STACKED_PORTLETFLOW      constant integer :=  2;
    REGION_LEFT_ALIGN               constant integer :=  0;
    REGION_RIGHT_ALIGN              constant integer :=  1;
    REGION_CENTER_ALIGN             constant integer :=  2;
    REGION_THIN_RESTRICT            constant integer :=  0;
    REGION_WIDE_RESTRICT            constant integer :=  1;

    REGION_VALIDATION_EXCEPTION exception;
    REGION_EXECUTION_EXCEPTION exception;
    REGION_SECURITY_EXCEPTION exception;
    REGION_NOT_FOUND_EXCEPTION exception;

    type region_record is record
    (
        region_id           icx_regions.region_id%type,
        parent_region_id    icx_regions.parent_region_id%type,
        split_mode          icx_regions.split_mode%type,
        portlet_alignment   icx_regions.portlet_alignment%type,
        height              icx_regions.height%type,
        width               icx_regions.width%type,
        width_restrict      icx_regions.width_restrict%type,
        portlet_flow        icx_regions.portlet_flow%type,
        navwidget_id        icx_regions.navwidget_id%type,
        border              icx_regions.border%type
    );

    type region_table is table of region_record index by binary_integer;

    type array is table of varchar2(2000) index by binary_integer;
    empty array;

   /**
    * Create Main Region
    *
    * This module creates the main (first) region for a layout.
    * This is the region with parentid set to MAIN_REGION.
    *
    * Returns the region id
    *
    */

    function create_main_region return number;


   /**
    * Split Region
    *
    * This module splits a region either horizontally or vertically
    *
    * This module splits a region
    * Horizontal => 0
    * Vertical   => 1
    *
    * A horizontal split results in a region being split into 2 rows
    * by creating 2 new regions whose parent is the region that is being
    * split
    *
    * A vertical split results in a region being split into 2 columns
    * by creating 2 new regions whose parent is the region that is being
    * split
    *
    */

    procedure split_region (
        p_region_id     in integer
    ,   p_split_mode    in number
    );

   /**
    * Delete Region
    *
    * This module deletes a region
    *
    */

    procedure delete_region (
        p_region_id     in integer
    );

   /**
    * Get a Region
    *
    * This module returns a region record
    * given the id of the region.
    *
    */


    function get_region (
        p_region_id     in integer
    ) return region_record;


   /**
    * Add a Region
    *
    * This module adds a region record to the region table
    *
    * Returns the id of the region created.
    *
    */

    function add_region (
        p_region        in region_record
    ) return integer;


   /**
    * Edit Region
    *
    * This module edits a region record
    *
    */

    procedure edit_region (
        p_region      in region_record
    );


   /**
    *
    * Get Child Regions
    *
    * This module returns a list of all child regions
    * for a given region
    *
    */

    function get_child_region_list (
        p_region_id     in integer
    ) return region_table;


   /**
    * Delete Regions
    *
    * This module deletes all regions associated with a layout
    *
    */

    procedure delete_regions (
        p_layout_id     in integer
    );

    procedure copy_region_plugs (p_from_region_id in number,
                                 p_to_region_id  in number,
                                 p_to_page_id     in number);

   /**
    * Copy Child Regions
    *
    * This module copies child regions for a layout.
    *
    */
    procedure copy_child_regions (
        p_from_region_id  in number
    ,   p_to_region_id    in number
    ,   p_to_page_id      in number
    );


    /*
    *
    * Get Main Region
    *
    * This module returns the main region record (with parentid set to 0)
    * for a given page.
    *
    */

    function get_main_region_record (
        p_region_id     in integer
    ) return icx_api_region.region_record;

end ICX_API_REGION;

 

/
