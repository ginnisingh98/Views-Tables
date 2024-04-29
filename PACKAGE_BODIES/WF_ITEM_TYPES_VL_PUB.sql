--------------------------------------------------------
--  DDL for Package Body WF_ITEM_TYPES_VL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ITEM_TYPES_VL_PUB" AS
/* $Header: wfdefb.pls 120.1 2005/07/02 03:43:48 appldev ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_item_types_vl_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

  MODIFICATION LOG:
   06 JUN 2001  JWSMITH  BUG 1819232 ADA Enhancement
                -  Added ID attr for TD tags
                -  Added summary for table tags
                -  Added labels for input tags
   01 JAN 2002  JWSMITH BUG 2001012 - Increase l_username,l_admin_role
                to varchar2(320)

============================================================================*/

/*===========================================================================
  PROCEDURE NAME:       fetch_item_type

  DESCRIPTION:          Fetches all the properties of a given item type
                        into a wf_item_types_vl_tbl_type table based on the
                        item type internal eight character name.

============================================================================*/
PROCEDURE fetch_item_type
     (p_name                   IN  VARCHAR2,
      p_wf_item_types_vl_tbl   OUT NOCOPY wf_item_types_vl_pub.wf_item_types_vl_tbl_type) IS

l_record_num               NUMBER  := 0;

BEGIN

   /*
   ** Make sure all the required parameters are set
   */
   IF (p_name IS NULL) THEN

      return;

   END IF;

   /*
   ** Get the item type definition
   */
   SELECT rowid,
          name,
          protect_level,
          custom_level,
          wf_selector,
          read_role,
          write_role,
          execute_role,
          display_name,
          description
   INTO   p_wf_item_types_vl_tbl(1)
   FROM   wf_item_types_vl
   WHERE  name = p_name;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_item_types_vl_pub', 'fetch_item_type', p_name);
      wf_item_definition.Error;

END  fetch_item_type;

/*===========================================================================
  PROCEDURE NAME:       draw_item_type_list

  DESCRIPTION:          Shows the display name of an item type as a
                        html view as a part of a hierical summary list of
                        an item type.  This function uses the htp to
                        generate its html output.

============================================================================*/
PROCEDURE draw_item_type_list
     (p_wf_item_types_vl_tbl
           IN wf_item_types_vl_pub.wf_item_types_vl_tbl_type,
      p_effective_date            IN DATE,
      p_indent_level              IN NUMBER) IS

l_record_num       NUMBER;
ii                 NUMBER  := 0;

BEGIN

  /*
  **  Print out all item type names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_item_types_vl_tbl.count LOOP

      /*
      ** The creation of the anchor from the summary frame to the detail
      ** frame was very complex so I've extracted the function into its
      ** own routine.
      */
      wf_item_definition_util_pub.create_hotlink_to_details (
            p_wf_item_types_vl_tbl(l_record_num).name,
            p_effective_date,
            'ITEM_TYPE',
            p_wf_item_types_vl_tbl(l_record_num).name,
            p_wf_item_types_vl_tbl(l_record_num).display_name,
            NULL,
            p_indent_level);

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_item_types_vl_pub', 'draw_item_type_list');
      wf_item_definition.Error;

END draw_item_type_list;

/*===========================================================================
  PROCEDURE NAME:       draw_item_type_details

  DESCRIPTION:          Shows all the details of an item type as a
                        html view.  This function uses the htp to
                        generate its html output.

  MODIFICATION LOG:
    06-JUN-2001 JWSMITH BUG 1819232 - added summary attr for table tag for ADA

============================================================================*/
PROCEDURE draw_item_type_details
     (p_wf_item_types_vl_tbl   IN wf_item_types_vl_pub.wf_item_types_vl_tbl_type,
      p_indent_level              IN NUMBER) IS

l_record_num       NUMBER;
ii                 NUMBER  := 0;

BEGIN

  /*
  ** Draw the section title for the item type detail section
  */
  wf_item_definition_util_pub.draw_detail_section_title (
     wf_core.translate('WFITD_ITEM_TYPE_DETAILS'),
     0);

  /*
  **  Print out all item attribute display names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_item_types_vl_tbl.count LOOP

      /*
      ** Open a new table for each item_type so you can control the spacing
      ** between each attribute
      */
      htp.tableOpen(cattributes=>'border=0 cellpadding=2 cellspacing=0
          summary="' || wf_core.translate('WFITD_ITEM_TYPE_DETAILS') || '"');

      /*
      ** Create the target for the hotlink from the summary view. Also
      ** create the first row in the table which is always the display
      ** name for the object.
      */
      wf_item_definition_util_pub.create_details_hotlink_target (
        'ITEM_TYPE',
        p_wf_item_types_vl_tbl(l_record_num).name,
        p_wf_item_types_vl_tbl(l_record_num).display_name,
        wf_core.translate('WFITD_ITEM_TYPE_NAME'),
        0);

      /*
      ** Create the internal name row in the table.
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_INTERNAL_NAME'),
         p_wf_item_types_vl_tbl(l_record_num).name);

      /*
      ** Create the description row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('DESCRIPTION'),
         p_wf_item_types_vl_tbl(l_record_num).description);

      /*
      ** Create the selector row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_SELECTOR'),
         p_wf_item_types_vl_tbl(l_record_num).wf_selector);

      /*
      ** Call function to print the read/write/execute roles
      */
      wf_item_definition_util_pub.draw_read_write_exe_details(
         p_wf_item_types_vl_tbl(l_record_num).read_role,
         p_wf_item_types_vl_tbl(l_record_num).write_role,
         p_wf_item_types_vl_tbl(l_record_num).execute_role,
         TRUE);

      /*
      ** Call function to print the customization/protection levels
      */
      wf_item_definition_util_pub.draw_custom_protect_details(
         p_wf_item_types_vl_tbl(l_record_num).custom_level,
         p_wf_item_types_vl_tbl(l_record_num).protect_level);

      /*
      ** Table is created so close it out
      */
      htp.tableClose;

      /*
      ** Draw a line between each attribute definition
      ** if this is not the last item in the list
      */
      IF (l_record_num <> p_wf_item_types_vl_tbl.count) THEN

         htp.p ('<HR noshade size="1">');

      END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_item_types_vl_pub', 'draw_item_type_details');
      wf_item_definition.Error;

END draw_item_type_details;

END wf_item_types_vl_pub;

/
