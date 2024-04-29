--------------------------------------------------------
--  DDL for Package Body WF_ITEM_ATTRIBUTES_VL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ITEM_ATTRIBUTES_VL_PUB" AS
/* $Header: wfdefb.pls 120.1 2005/07/02 03:43:48 appldev ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_item_attributes_vl_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

============================================================================*/

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

============================================================================*/
PROCEDURE fetch_item_attributes
     (p_item_type       IN  VARCHAR2,
      p_name            IN  VARCHAR2,
      p_wf_item_attributes_vl_tbl
              OUT NOCOPY wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type) IS

/*===========================================================================

  CURSOR NAME:          c_fetch_item_attributes

  DESCRIPTION:          Fetches all attributes for the given item_type

                        You'll notice that we are selecting the attribute
                        display name twice.  The second occurrence is simply a
                        placeholder in the record so that I can fill in that column
                        with the lookup type display name if this attribute is
                        validated based on a lookup type.

  PARAMETERS:

        c_item_type IN  Internal name of the item type

============================================================================*/
CURSOR c_fetch_item_attributes (c_item_type IN VARCHAR2) IS
SELECT
 row_id,
 item_type,
 name,
 sequence,
 type,
 protect_level,
 custom_level,
 subtype,
 format,
 display_name lookup_type_display_name,
 display_name lookup_code_display_name,
 text_default,
 number_default,
 date_default,
 display_name,
 description
FROM   wf_item_attributes_vl
WHERE  item_type = c_item_type
ORDER  BY sequence;

l_record_num               NUMBER  := 0;

BEGIN

   /*
   ** Make sure all the required parameters are set
   */
   IF (p_item_type IS NULL) THEN

      return;

   END IF;

   /*
   ** Check if the caller has passed a specific attribute_name to search for.
   ** If so then just get the row corresponding to that item_type and
   ** attribute_name.  If not then get all rows for that item_type.
   */
   IF (p_name IS NOT NULL) THEN

       BEGIN
          SELECT  row_id,
                  item_type,
                  name,
                  sequence,
                  type,
                  protect_level,
                  custom_level,
                  subtype,
                  format,
                  display_name lookup_type_display_name,
                  display_name lookup_code_display_name,
                  text_default,
                  number_default,
                  date_default,
                  display_name,
                  description
          INTO   p_wf_item_attributes_vl_tbl(1)
          FROM   wf_item_attributes_vl
          WHERE  item_type = p_item_type
          AND    name      = p_name;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
        WHEN OTHERS THEN
           RAISE;
        END;

    ELSE

       OPEN c_fetch_item_attributes (p_item_type);

       /*
       ** Loop through all the lookup_code rows for the given lookup_type
       ** filling in the p_wf_lookups_tbl
       */
       LOOP

           l_record_num := l_record_num + 1;

           FETCH c_fetch_item_attributes INTO
               p_wf_item_attributes_vl_tbl(l_record_num);

           EXIT WHEN c_fetch_item_attributes%NOTFOUND;

           /*
           ** If the validation for this attribute is a lookup then go get the
           ** display name for that lookup and put it in the
           ** lookup_type_display_name record element
           */
           IF (p_wf_item_attributes_vl_tbl(l_record_num).type = 'LOOKUP') THEN

               wf_lookup_types_pub.fetch_lookup_display(
                  p_wf_item_attributes_vl_tbl(l_record_num).format,
                  p_wf_item_attributes_vl_tbl(l_record_num).text_default,
                  p_wf_item_attributes_vl_tbl(l_record_num).lookup_type_display_name,
                  p_wf_item_attributes_vl_tbl(l_record_num).lookup_code_display_name);
          END IF;

       END LOOP;

       CLOSE c_fetch_item_attributes;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('wf_item_attributes_vl_pub',
          'fetch_item_attributes',
          p_item_type,
          p_name);

       wf_item_definition.Error;

END  fetch_item_attributes;

/*===========================================================================
  PROCEDURE NAME:       fetch_item_attribute_display

  DESCRIPTION:          fetch the item attribute display name based on a item
                        type name and an internal item attribute name

============================================================================*/
PROCEDURE fetch_item_attribute_display (p_item_type     IN VARCHAR2,
                                        p_internal_name IN VARCHAR2,
                                        p_display_name  OUT NOCOPY VARCHAR2) IS

l_display_name VARCHAR2(80);
l_wf_item_attributes_vl_tbl
   wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type;

BEGIN

  /*
  ** Fetch the item attribute record associated with this internal name
  */
  fetch_item_attributes (p_item_type,
     p_internal_name,
     l_wf_item_attributes_vl_tbl);

   /*
   ** See if you found a row.  If not, proide the user with feedback
   */
   IF (l_wf_item_attributes_vl_tbl.count < 1) THEN

      l_display_name := p_internal_name||' '||
         '<B> -- '||wf_core.translate ('WFITD_UNDEFINED')||'</B>';

   ELSE

      l_display_name := l_wf_item_attributes_vl_tbl(1).display_name;

   END IF;

   p_display_name := l_display_name;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_item_attributes_pub',
         'fetch_item_attribute_display',
         p_internal_name);

END fetch_item_attribute_display;

/*===========================================================================
  PROCEDURE NAME:       draw_item_attribute_list

  DESCRIPTION:          Shows the display name of an item attribute as a
                        html view as a part of a hierical summary list of
                        an item type.  This function uses the htp to
                        generate its html output.

============================================================================*/
PROCEDURE draw_item_attribute_list
     (p_wf_item_attributes_vl_tbl
           IN wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type,
      p_effective_date            IN DATE,
      p_indent_level              IN NUMBER) IS

l_record_num       NUMBER;
ii                 NUMBER  := 0;

BEGIN

  /*
  ** Create the the attributes title.  Indent it to the level specified
  */
  wf_item_definition_util_pub.draw_summary_section_title(
       wf_core.translate('WFITD_ATTRIBUTES'),
       p_indent_level);

  /*
  **  Print out all item attribute display names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_item_attributes_vl_tbl.count LOOP

      /*
      ** The creation of the anchor from the summary frame to the detail
      ** frame was very complex so I've extracted the function into its
      ** own routine.
      */
      wf_item_definition_util_pub.create_hotlink_to_details (
            p_wf_item_attributes_vl_tbl(l_record_num).item_type,
            p_effective_date,
            'ATTRIBUTE',
            p_wf_item_attributes_vl_tbl(l_record_num).name,
            p_wf_item_attributes_vl_tbl(l_record_num).display_name,
            NULL,
            p_indent_level+1);

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_item_attributes_vl_pub', 'draw_item_attribute_list');
      wf_item_definition.Error;

END draw_item_attribute_list;


/*===========================================================================
  PROCEDURE NAME:       draw_item_attribute_details

  DESCRIPTION:          Shows all the details of an item attrribute as a
                        html view.  This function uses the htp to
                        generate its html output.
  MODIFICATION LOG:
   06-JUN-2001 JWSMITH BUG 1819232 - added summary attr for table tag for ADA

============================================================================*/
PROCEDURE draw_item_attribute_details
     (p_wf_item_attributes_vl_tbl IN wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type,
      p_indent_level              IN NUMBER) IS

l_record_num       NUMBER;
ii                 NUMBER  := 0;

BEGIN

  /*
  ** Draw the section title for the item type detail section
  */
  wf_item_definition_util_pub.draw_detail_section_title (
     wf_core.translate('WFITD_ATTRIBUTE_DETAILS'),
     0);

  /*
  **  Print out all item attribute display names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_item_attributes_vl_tbl.count LOOP

      /*
      ** Open a new table for each attribute so you can control the spacing
      ** between each attribute
      */
      htp.tableOpen(cattributes=>'border=0 cellpadding=2 cellspacing=0
            summary= "' || wf_core.translate('WFITD_ATTRIBUTE_DETAILS') || '"');

      /*
      ** Create the target for the hotlink from the summary view. Also
      ** create the first row in the table which is always the display
      ** name for the object.
      */
      wf_item_definition_util_pub.create_details_hotlink_target (
         'ATTRIBUTE',
         p_wf_item_attributes_vl_tbl(l_record_num).name,
         p_wf_item_attributes_vl_tbl(l_record_num).display_name,
         wf_core.translate('WFITD_ATTRIBUTE_NAME'),
         0);

      /*
      ** Create the internal name row in the table.
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_INTERNAL_NAME'),
         p_wf_item_attributes_vl_tbl(l_record_num).name);

      /*
      ** Create the description row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('DESCRIPTION'),
         p_wf_item_attributes_vl_tbl(l_record_num).description);

      /*
      ** Create the attribute type row in the table.  I've named the
      ** translated resource so that all I have to do is add
      ** WFITD_ATTR_TYPE_ to the type of resource and I get the
      ** translated string.
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_ATTRIBUTE_TYPE'),
         wf_core.translate('WFITD_ATTR_TYPE_'||
         p_wf_item_attributes_vl_tbl(l_record_num).type));

      /*
      ** Create the length/format/lookup type row in the table.
      ** If the type is VARCHAR2 then show a length prompt
      ** If the type is NUMBER/DATE then show format prompt
      ** If the type is LOOKUP then show lookup type prompt
      ** If it is any other type then don't show the row at all
      */
      IF (p_wf_item_attributes_vl_tbl(l_record_num).type = 'VARCHAR2') THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('LENGTH'),
            p_wf_item_attributes_vl_tbl(l_record_num).format);

      ELSIF (p_wf_item_attributes_vl_tbl(l_record_num).type IN ('NUMBER', 'DATE')) THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('FORMAT'),
            p_wf_item_attributes_vl_tbl(l_record_num).format);

      ELSIF (p_wf_item_attributes_vl_tbl(l_record_num).type IN ('URL','DOCUMENT')) THEN
         /*
         ** If it is URL or DOCUMENT, indicate where the resulting page should be displayed
         */
         IF (NVL(p_wf_item_attributes_vl_tbl(l_record_num).format, '_top') = '_top') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_TOP'));
         ELSIF (p_wf_item_attributes_vl_tbl(l_record_num).format = '_blank') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_BLANK'));
         ELSIF (p_wf_item_attributes_vl_tbl(l_record_num).format = '_self') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_SELF'));
         ELSIF (p_wf_item_attributes_vl_tbl(l_record_num).format = '_parent') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_PARENT'));
         END IF;

      ELSIF (p_wf_item_attributes_vl_tbl(l_record_num).type = 'LOOKUP') THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('LOOKUP'),
            p_wf_item_attributes_vl_tbl(l_record_num).lookup_type_display_name);

      END IF;

      /*
      ** Create the default value row in the table.  If the attribute type is based on
      ** a lookup then the default value must be one of the lookup codes.  If so print
      ** the lookup code that was fetch,  If this is any other attribute type then
      ** nvl on text value.  If there is no text value then try the number
      ** default.  If there is no number default then try the date.
      */
      IF (p_wf_item_attributes_vl_tbl(l_record_num).type = 'LOOKUP') THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_DEFAULT_VALUE'),
            p_wf_item_attributes_vl_tbl(l_record_num).lookup_code_display_name);

      ELSE

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_DEFAULT_VALUE'),
            NVL(p_wf_item_attributes_vl_tbl(l_record_num).text_default,
               NVL(TO_CHAR(p_wf_item_attributes_vl_tbl(l_record_num).number_default),
                  TO_CHAR(p_wf_item_attributes_vl_tbl(l_record_num).date_default))));

      END IF;
      htp.tableRowClose;

      /*
      ** Call function to print the customization/protection levels
      */
      wf_item_definition_util_pub.draw_custom_protect_details(
         p_wf_item_attributes_vl_tbl(l_record_num).custom_level,
         p_wf_item_attributes_vl_tbl(l_record_num).protect_level);

      /*
      ** Table is created so close it out
      */
      htp.tableClose;

      /*
      ** Draw a line between each attribute definition
      ** if this is not the last item in the list
      */
      IF (l_record_num <> p_wf_item_attributes_vl_tbl.count) THEN

         htp.p ('<HR noshade size="1">');

      END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_item_attributes_vl_pub', 'draw_item_attribute_details');
      wf_item_definition.Error;

END draw_item_attribute_details;


END wf_item_attributes_vl_pub;

/
