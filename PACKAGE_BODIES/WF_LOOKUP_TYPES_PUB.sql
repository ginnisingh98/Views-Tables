--------------------------------------------------------
--  DDL for Package Body WF_LOOKUP_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_LOOKUP_TYPES_PUB" AS
/* $Header: wfdefb.pls 120.1 2005/07/02 03:43:48 appldev ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_lookup_types_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

============================================================================*/

/*===========================================================================
  PROCEDURE NAME:       fetch_lookup_type

  DESCRIPTION:          Fetches all the lookup types for a given item type
                        into a p_wf_lookup_types_vl_tbl table based on the
                        item type internal eight character name.  This function
                        can also retrieve a single lookup type definition if
                        the internal name along with the item type name is
                        provided.  This is especially useful if you wish to
                        display the details for a single lookup type when it
                        is referenced from some drilldown mechanism.

============================================================================*/
PROCEDURE fetch_lookup_types
     (p_item_type       IN  VARCHAR2,
      p_lookup_type     IN  VARCHAR2,
      p_wf_lookup_types_tbl  OUT NOCOPY wf_lookup_types_pub.wf_lookup_types_tbl_type,
      p_wf_lookups_tbl       OUT NOCOPY wf_lookup_types_pub.wf_lookups_tbl_type) IS

CURSOR fetch_lookup_types (c_item_type IN VARCHAR2) IS
SELECT  row_id,
        lookup_type,
        item_type,
        protect_level,
        custom_level,
        display_name,
        description
FROM   wf_lookup_types
WHERE  item_type = c_item_type
ORDER  BY display_name;

/*===========================================================================

  CURSOR NAME:          fetch_lookups

  DESCRIPTION:          Fetches all lookups for the given item_type.

                        You'll notice that the select orders the
                        results by lookup type display name, and then
                        by lookup meaning.  The criteria is based
                        on the requirement to synchronize the
                        lookup list with the lookup type list.  The
                        lookup type list is ordered by display name.
                        When we list the lookup tyoes and their
                        corresponding lookups we walk these lists
                        in parallel.  When we find a lookup that matches
                        the lookup type, we copy that lookup to a temp
                        list until we find a new lookup type in the lookup
                        list.  When this happens we write out the lookup
                        temp list and move to the next lookup type.
                        Thus the need for the special order criteria.

  PARAMETERS:

        c_item_type IN  Internal name of the item type

============================================================================*/
CURSOR fetch_lookups (c_item_type IN VARCHAR2) IS
 SELECT
 wlt.display_name lookup_type_display_name,
 wlt.item_type,
 wl.row_id,
 wl.lookup_type,
 wl.lookup_code,
 wl.protect_level,
 wl.custom_level,
 wl.meaning,
 wl.description
 FROM   wf_lookups wl, wf_lookup_types wlt
 WHERE  wlt.item_type = c_item_type
 AND    wlt.lookup_type = wl.lookup_type
 ORDER  BY wlt.display_name, wl.meaning;

/*===========================================================================

  CURSOR NAME:          fetch_lookups_for_type

  DESCRIPTION:          Fetches lookups for the given item_type
                        and lookup type.

  PARAMETERS:

        c_item_type IN  Internal name of the item type

        c_lookup_type
                    IN  Internal name of the lookup type
============================================================================*/
CURSOR fetch_lookups_for_type (c_item_type IN VARCHAR2,
                               c_lookup_type IN VARCHAR2) IS
 SELECT
 wlt.display_name lookup_type_display_name,
 wlt.item_type,
 wl.row_id,
 wl.lookup_type,
 wl.lookup_code,
 wl.protect_level,
 wl.custom_level,
 wl.meaning,
 wl.description
 FROM   wf_lookups wl, wf_lookup_types wlt
 WHERE  wlt.item_type = c_item_type
 AND    wlt.lookup_type = c_lookup_type
 AND    wlt.lookup_type = wl.lookup_type
 ORDER  BY wlt.display_name, wl.meaning;

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
   IF (p_lookup_type IS NOT NULL) THEN

       SELECT row_id,
              lookup_type,
              item_type,
              protect_level,
              custom_level,
              display_name,
              description
       INTO   p_wf_lookup_types_tbl(1)
       FROM   wf_lookup_types
       WHERE  item_type   = p_item_type
       AND    lookup_type = p_lookup_type;

       l_record_num := 0;

       OPEN fetch_lookups_for_type (p_item_type, p_lookup_type);

       /*
       ** Loop through all the lookup_code rows for the given lookup_type
       ** filling in the p_wf_lookups_tbl
       */
       LOOP

           l_record_num := l_record_num + 1;

           FETCH fetch_lookups_for_type INTO p_wf_lookups_tbl(l_record_num);

           EXIT WHEN fetch_lookups_for_type%NOTFOUND;

       END LOOP;

       CLOSE fetch_lookups_for_type;

    ELSE

       OPEN fetch_lookup_types (p_item_type);

       /*
       ** Loop through all the lookup_code rows for the given lookup_type
       ** filling in the p_wf_lookups_tbl
       */
       LOOP

           l_record_num := l_record_num + 1;

           FETCH fetch_lookup_types INTO p_wf_lookup_types_tbl(l_record_num);

           EXIT WHEN fetch_lookup_types%NOTFOUND;

       END LOOP;

       CLOSE fetch_lookup_types;

       l_record_num := 0;

       OPEN fetch_lookups (p_item_type);

       /*
       ** Loop through all the lookup_code rows for the given lookup_type
       ** filling in the p_wf_lookups_tbl
       */
       LOOP

           l_record_num := l_record_num + 1;

           FETCH fetch_lookups INTO p_wf_lookups_tbl(l_record_num);

           EXIT WHEN fetch_lookups%NOTFOUND;

       END LOOP;

       CLOSE fetch_lookups;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('wf_lookup_types_pub',
          'fetch_lookup_types',
          p_item_type,
          p_lookup_type);

       wf_item_definition.Error;

END  fetch_lookup_types;

/*===========================================================================
  PROCEDURE NAME:       fetch_lookup_display

  DESCRIPTION:          fetch the lookup type display name and the lookup code
                        display name based on a lookup type internal name and
                        lookup code internal name

============================================================================*/
PROCEDURE fetch_lookup_display (p_type_internal_name IN VARCHAR2,
                                p_code_internal_name IN VARCHAR2,
                                p_type_display_name  OUT NOCOPY VARCHAR2,
                                p_code_display_name  OUT NOCOPY VARCHAR2) IS

l_type_display_name VARCHAR2(80);
l_code_display_name VARCHAR2(80);

BEGIN

   /*
   ** Only try to fetch the lookup type if the internal name is passed in
   */
   IF (p_type_internal_name IS NOT NULL) THEN

      /*
      ** Get the display name based on the internal name.
      ** Use a max() so you don't need a exception for no data found
      */
      SELECT MAX(display_name)
      INTO   l_type_display_name
      FROM   wf_lookup_types
      WHERE  lookup_type = p_type_internal_name;

      /*
      ** If no value is found then set the display name to the
      ** internal name + ' is undefined' message so user can see
      ** missing reference
      */
      IF (l_type_display_name IS NULL) THEN

         l_type_display_name := p_type_internal_name||' '||
            '<B> -- '||UPPER(wf_core.translate ('WFITD_UNDEFINED'))||'</B>';

      END IF;

   ELSE

      /*
      ** No internal name was passed so set the display name to null
      */
      l_type_display_name := NULL;

   END IF;

   /*
   ** Set the outbound lookup code display name
   */
   p_type_display_name := l_type_display_name;

   /*
   ** Only try to fetch the lookup code if both internal names are passed in
   */
   IF (p_type_internal_name IS NOT NULL AND p_code_internal_name IS NOT NULL) THEN

      /*
      ** Get the display name based on the internal name.
      ** Use a max() so you don't need a exception for no data found
      */
      SELECT MAX(meaning)
      INTO   l_code_display_name
      FROM   wf_lookups
      WHERE  lookup_type = p_type_internal_name
      AND    lookup_code = p_code_internal_name;

      /*
      ** If no value is found then set the display name to the
      ** internal name + ' is undefined' message so user can see
      ** missing reference
      */
      IF (l_code_display_name IS NULL) THEN

         l_code_display_name := p_code_internal_name||' '||
            '<B> -- '||UPPER(wf_core.translate ('WFITD_UNDEFINED'))||'</B>';

      END IF;

   ELSE

      /*
      ** No internal name was passed so set the display name to null
      */
      l_code_display_name := NULL;

   END IF;

   /*
   ** Set the outbound lookup code display name
   */
   p_code_display_name := l_code_display_name;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_lookup_types_pub',
         'fetch_lookup_display',
         p_type_internal_name,
         p_code_internal_name);

END fetch_lookup_display;

/*===========================================================================
  PROCEDURE NAME:       draw_lookup_type_list

  DESCRIPTION:          Shows the display name of lookup type as a
                        html view as a part of a hierical summary list of
                        an item type.  This function uses the htp to
                        generate its html output.

============================================================================*/
PROCEDURE draw_lookup_type_list
     (p_wf_lookup_types_tbl IN wf_lookup_types_pub.wf_lookup_types_tbl_type,
      p_wf_lookups_tbl      IN wf_lookup_types_pub.wf_lookups_tbl_type,
      p_effective_date            IN DATE,
      p_indent_level              IN NUMBER) IS

l_lookup_type_record_num     NUMBER;
l_lookup_record_num          NUMBER  := 1;
ii                           NUMBER  := 0;
l_cur_lookup_record_num      NUMBER  := 1;
l_wf_lookups_tbl             wf_lookup_types_pub.wf_lookups_tbl_type;


BEGIN

  /*
  ** Create the the attributes title.  Indent it to the level specified
  */
  wf_item_definition_util_pub.draw_summary_section_title(
       wf_core.translate('WFITD_LOOKUP_TYPES'),
       p_indent_level);

  /*
  **  Print out all lookup type display names in the pl*sql table
  */
  FOR l_lookup_type_record_num IN 1..p_wf_lookup_types_tbl.count LOOP

      /*
      ** The creation of the anchor from the summary frame to the detail
      ** frame was very complex so I've extracted the function into its
      ** own routine.
      */
      wf_item_definition_util_pub.create_hotlink_to_details (
            p_wf_lookup_types_tbl(l_lookup_type_record_num).item_type,
            p_effective_date,
            'LOOKUP_TYPE',
            p_wf_lookup_types_tbl(l_lookup_type_record_num).lookup_type,
            p_wf_lookup_types_tbl(l_lookup_type_record_num).display_name,
            NULL,
            p_indent_level+1);

      /*
      ** Here we look for all the lookup types that are related to the
      ** current lookup type.  The p_wf_lookups_vl_tbl is ordered by display
      ** name and then by lookup type display name.  As long as we stay
      ** in sync we should be able to correctly create the temp attribute list
      ** for the current lookup type.  We could create a cursor here for the child
      ** attributes but that would break the rule of separating the UI layer
      ** and the data layer
      */
      l_wf_lookups_tbl.delete;
      l_cur_lookup_record_num := 1;

      /*
      ** Make sure there is at least on record in the lookup
      ** list.  If there is not then the l_lookup_record_num index of 1
      ** will cause a 6502-PL*SQL numeric or value error exception.
      */
      WHILE (
         l_lookup_record_num <=  p_wf_lookups_tbl.count AND
         p_wf_lookup_types_tbl(l_lookup_type_record_num).display_name =
            p_wf_lookups_tbl(l_lookup_record_num).lookup_type_display_name
         ) LOOP

         /*
         ** We have found an attribute for the current lookup type.  Copy the
         ** contents of that list to a temp attr list and then pass the
         ** temp list to the lookupsibute display function to display
         ** the results.
         */
         l_wf_lookups_tbl(l_cur_lookup_record_num) :=
             p_wf_lookups_tbl(l_lookup_record_num);

         l_lookup_record_num := l_lookup_record_num + 1;
         l_cur_lookup_record_num := l_cur_lookup_record_num + 1;

      END LOOP;

      /*
      ** If the l_cur_attr_record_num is greater than 1 then you
      ** must have found an attribute for this lookup type.  Copy that
      ** set of attributes to a temporary pl*sql table and then
      ** print it out.
      */
      IF (l_cur_lookup_record_num > 1) THEN

        /*
        ** List all the lookup type details for this lookup type that
        ** we found above.  Add two to the current indent level so it
        ** is pushed in past the start of the lookup type list.
        */
        wf_lookup_types_pub.draw_lookup_list (
           l_wf_lookups_tbl,
           p_effective_date,
           p_indent_level + 2);

      END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_lookup_types_pub', 'draw_lookup_type_list');
      wf_item_definition.Error;

END draw_lookup_type_list;

/*===========================================================================
  PROCEDURE NAME:       draw_lookup_list

  DESCRIPTION:          Shows the display names of message attributes for
                        a given message as a html view as a part of
                        a hierical summary list of an item type.
                        This function uses the htp to generate its html
                        output.

============================================================================*/
 PROCEDURE draw_lookup_list
     (p_wf_lookups_tbl      IN wf_lookup_types_pub.wf_lookups_tbl_type,
      p_effective_date      IN DATE,
      p_indent_level        IN NUMBER) IS

l_record_num              NUMBER;
ii                        NUMBER  := 0;

BEGIN

  /*
  ** Create the the lookups title.  Indent it to the level specified
  */
  wf_item_definition_util_pub.draw_summary_section_title(
       wf_core.translate('WFITD_LOOKUP_CODES'),
       p_indent_level);

  /*
  **  Print out all lookup display names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_lookups_tbl.count LOOP

      /*
      ** The creation of the anchor from the summary frame to the detail
      ** frame was very complex so I've extracted the function into its
      ** own routine.
      */
      wf_item_definition_util_pub.create_hotlink_to_details (
         p_wf_lookups_tbl(l_record_num).item_type,
         p_effective_date,
         'LOOKUP',
         p_wf_lookups_tbl(l_record_num).lookup_type||':'||
         p_wf_lookups_tbl(l_record_num).lookup_code,
         p_wf_lookups_tbl(l_record_num).meaning,
         NULL,
         p_indent_level+1);

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_lookup_types_vl_pub', 'draw_lookup_list');
      wf_item_definition.Error;

END draw_lookup_list;

/*===========================================================================
  PROCEDURE NAME:       draw_lookup_type_details

  DESCRIPTION:          Shows all the details of an lookup type as a
                        html view.  This function uses the htp to
                        generate its html output.

  MODIFICATION LOG:
   06-JUN-2001 JWSMITH BUG 1819232 - added summary attr for table tag for ADA
============================================================================*/
PROCEDURE draw_lookup_type_details
     (p_wf_lookup_types_tbl IN wf_lookup_types_pub.wf_lookup_types_tbl_type,
      p_wf_lookups_tbl      IN wf_lookup_types_pub.wf_lookups_tbl_type,
      p_indent_level              IN NUMBER) IS

l_lookup_type_record_num           NUMBER;
ii                 NUMBER  := 0;
l_lookup_record_num        NUMBER  := 1;
l_cur_lookup_record_num    NUMBER  := 1;
l_wf_lookups_tbl           wf_lookup_types_pub.wf_lookups_tbl_type;

BEGIN

  /*
  ** Draw the section title for the lookup type detail section
  */
  wf_item_definition_util_pub.draw_detail_section_title (
     wf_core.translate('WFITD_LOOKUP_TYPE_DETAILS'),
     0);

  /*
  **  Print out all item attribute display names in the pl*sql table
  */
  FOR l_lookup_type_record_num IN 1..p_wf_lookup_types_tbl.count LOOP

      /*
      ** Open a new table for each attribute so you can control the spacing
      ** between each attribute
      */
      htp.tableOpen(cattributes=>'border=0 cellpadding=2 cellspacing=0
          summary=""');

      /*
      ** Create the target for the hotlink from the summary view. Also
      ** create the first row in the table which is always the display
      ** name for the object.
      */
      wf_item_definition_util_pub.create_details_hotlink_target (
         'LOOKUP_TYPE',
         p_wf_lookup_types_tbl(l_lookup_type_record_num).lookup_type,
         p_wf_lookup_types_tbl(l_lookup_type_record_num).display_name,
         wf_core.translate('WFITD_LOOKUP_TYPE_NAME'),
         0);

      /*
      ** Create the internal name row in the table.  Also lay down the
      ** destination for the anchor based on the row id.
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_INTERNAL_NAME'),
         p_wf_lookup_types_tbl(l_lookup_type_record_num).lookup_type);

      /*
      ** Create the description row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('DESCRIPTION'),
         p_wf_lookup_types_tbl(l_lookup_type_record_num).description);

      /*
      ** Call function to print the customization/protection levels
      */
      wf_item_definition_util_pub.draw_custom_protect_details(
         p_wf_lookup_types_tbl(l_lookup_type_record_num).custom_level,
         p_wf_lookup_types_tbl(l_lookup_type_record_num).protect_level);

      /*
      ** Table is created so close it out
      */
      htp.tableClose;

      /*
      ** Here we look for all the lookups that are related to the  current
      ** lookup type.  The p_wf_lookups_tbl is ordered by display
      ** name and then by lookup meaning.  As long as we stay
      ** in sync we should be able to correctly create the temp lookup list
      ** for the current lookup type.  We could create a cursor here for
      ** the child lookups but that would break the rule of separating
      ** the UI layer and the data layer
      */
      l_wf_lookups_tbl.delete;
      l_cur_lookup_record_num := 1;

      /*
      ** Make sure there is at least on record in the lookups
      ** list.  If there is not then the l_lookup_record_num index of 1
      ** will cause a 6502-PL*SQL numeric or value error exception.
      */
      WHILE (
          l_lookup_record_num <=  p_wf_lookups_tbl.count AND
          p_wf_lookup_types_tbl(l_lookup_type_record_num).display_name =
             p_wf_lookups_tbl(l_lookup_record_num).lookup_type_display_name
          ) LOOP

         /*
         ** We have found a lookup for the lookup type.  Copy the
         ** contents of that list to a temp lookup list  and then pass the
         ** temp list to the lookup display function to display
         ** the results.
         */
         l_wf_lookups_tbl(l_cur_lookup_record_num) :=
             p_wf_lookups_tbl(l_lookup_record_num);

         l_lookup_record_num := l_lookup_record_num + 1;
         l_cur_lookup_record_num := l_cur_lookup_record_num + 1;

      END LOOP;

      /*
      ** If the l_cur_lookup_record_num is greater than 1 then you
      ** must have found a lookup for this lookup type.  Copy that
      ** set of lookups to a temporary pl*sql table and then
      ** print it out.
      */
      IF (l_cur_lookup_record_num > 1) THEN

        /*
        ** Put in a couple of blank lines between the current lookup type
        ** and its lookups
        */
        htp.p('<BR><BR>');

        /*
        ** List all the lookup details for this lookup typethat
        ** we found above.
        */
        wf_lookup_types_pub.draw_lookup_details (
           l_wf_lookups_tbl,
           1);

        /*
        ** If you still have more lookup types to process then put in a
        ** few blank lines and put in another Lookup Type Details Header
        */
        IF (l_lookup_type_record_num < p_wf_lookup_types_tbl.count) THEN

           /*
           ** Put in a couple of blank lines between the current message
           ** attributes and the next message
           */
           htp.p('<BR><BR>');

           /*
           ** Draw the section title for the Lookup Type detail section
           */
           wf_item_definition_util_pub.draw_detail_section_title (
              wf_core.translate('WFITD_LOOKUP_TYPE_DETAILS'),
              0);

        END IF;

     END IF;

     /*
     ** Draw a line between each message definition
     ** if this is not the last item in the list and if there
     ** are no attributes in the attribute list for this message.
     */
     IF (l_lookup_type_record_num < p_wf_lookup_types_tbl.count AND
         l_cur_lookup_record_num = 1) THEN

         htp.p ('<HR noshade size="1">');

     END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_lookup_types_pub', 'draw_lookup_type_details');
      wf_item_definition.Error;

END draw_lookup_type_details;

/*===========================================================================
  PROCEDURE NAME:       draw_lookup_details

  DESCRIPTION:          Shows all of the details for a list of
                        lookups that have been passed in.

  MODIFICATION LOG:
   06-JUN-2001 JWSMITH BUG 1819232 - added summary attr for table tag for ADA
============================================================================*/
PROCEDURE draw_lookup_details
     (p_wf_lookups_tbl IN wf_lookup_types_pub.wf_lookups_tbl_type,
      p_indent_level   IN NUMBER) IS

l_record_num       NUMBER;
ii                 NUMBER  := 0;

BEGIN

  /*
  ** Draw the section title for the lookup detail section
  */
  wf_item_definition_util_pub.draw_detail_section_title (
     wf_core.translate('WFITD_LOOKUP_DETAILS'),
     0);

  /*
  **  Print out all meesage attribute display names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_lookups_tbl.count LOOP

      /*
      ** Open a new table for each lookup so you can control the spacing
      ** between each attribute
      */
      htp.tableOpen(cattributes=>'border=0 cellpadding=2 cellspacing=0
               summary=""');

      /*
      ** Create the target for the hotlink from the summary view. Also
      ** create the first row in the table which is always the display
      ** name for the object.
      */
      wf_item_definition_util_pub.create_details_hotlink_target (
        'LOOKUP',
        p_wf_lookups_tbl(l_record_num).lookup_type||':'||
             p_wf_lookups_tbl(l_record_num).lookup_code,
        p_wf_lookups_tbl(l_record_num).meaning,
        wf_core.translate('WFITD_LOOKUP_CODE_NAME'),
        0);

      /*
      ** Create the internal name row in the table.
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_INTERNAL_NAME'),
         p_wf_lookups_tbl(l_record_num).lookup_code);

      /*
      ** Create the lookup type display name row in the table.
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_LOOKUP_TYPE_NAME'),
         p_wf_lookups_tbl(l_record_num).lookup_type_display_name);

      /*
      ** Create the description row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('DESCRIPTION'),
         p_wf_lookups_tbl(l_record_num).description);

      /*
      ** Table is created so close it out
      */
      htp.tableClose;

      /*
      ** Draw a line between each lookup definition
      ** if this is not the last item in the list
      */
      IF (l_record_num <> p_wf_lookups_tbl.count) THEN

         htp.p ('<HR noshade size="1">');

      END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_lookup_types_vl_pub', 'draw_lookup_details');
      wf_item_definition.Error;

END draw_lookup_details;

END wf_lookup_types_pub;

/
