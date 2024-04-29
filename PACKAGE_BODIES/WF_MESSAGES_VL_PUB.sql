--------------------------------------------------------
--  DDL for Package Body WF_MESSAGES_VL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_MESSAGES_VL_PUB" AS
/* $Header: wfdefb.pls 120.1 2005/07/02 03:43:48 appldev ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_messages_vl_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

============================================================================*/

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

============================================================================*/
PROCEDURE fetch_messages
     (p_item_type          IN  VARCHAR2,
      p_name               IN  VARCHAR2,
      p_wf_messages_vl_tbl OUT NOCOPY wf_messages_vl_pub.wf_messages_vl_tbl_type,
      p_wf_message_attr_vl_tbl OUT NOCOPY wf_messages_vl_pub.wf_message_attr_vl_tbl_type) IS

CURSOR fetch_messages (c_item_type IN VARCHAR2) IS
SELECT row_id,
       type,
       name,
       protect_level,
       custom_level,
       default_priority,
       read_role,
       write_role,
       display_name,
       description,
       subject,
       html_body,
       body
FROM   wf_messages_vl
WHERE  type = c_item_type
ORDER  BY display_name;

/*===========================================================================

  CURSOR NAME:          fetch_message_attributes

  DESCRIPTION:          Fetches all message attributes for the given
                        item_type.

                        You'll notice that the select orders the
                        results by message display name, and then
                        by attribute sequence.  The criteria is based
                        on the requirement to synchronize the
                        attribute list with the message list.  The
                        message list is ordered by display name.
                        When we list the messages and their
                        corresponding attributes we walk these lists
                        in parallel.  When we find an attribute that matches
                        the current message, we copy that attribute to a temp
                        list until we find a new message in the attribute
                        list.  When this happens we write out the attribute
                        temp list and move to the next message.  Thus the need
                        for the special order criteria.

                        You might also notice that we are selecting the message
                        display name four times.  The second is a placeholder
                        used when the default value is based on an
                        item attribute. The third occurrence is a
                        placeholder in the record so that I can fill in that column
                        with the lookup type display name if this attribute is
                        validated based on a lookup type.  The fourth occurence
                        is later populated with the lookup code display name
                        if the default value is based on a lookup type.

  PARAMETERS:

        c_item_type IN  Internal name of the item type

============================================================================*/
CURSOR fetch_message_attributes (c_item_type IN VARCHAR2) IS
 SELECT
 wm.display_name message_display_name,
 wm.display_name attr_default_display_name,
 wm.display_name lookup_type_display_name,
 wm.display_name lookup_code_display_name,
 wma.row_id,
 wma.message_type,
 wma.message_name,
 wma.name,
 wma.sequence,
 wma.type,
 wma.subtype,
 wma.attach,
 wma.value_type,
 wma.protect_level,
 wma.custom_level,
 wma.format,
 wma.text_default,
 wma.number_default,
 wma.date_default,
 wma.display_name,
 wma.description
 FROM   wf_message_attributes_vl wma, wf_messages_vl wm
 WHERE  wma.message_type = c_item_type
 AND    wm.type = c_item_type
 AND    wm.name = wma.message_name
 ORDER  BY wm.display_name, wma.sequence;

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

       SELECT row_id,
              type,
              name,
              protect_level,
              custom_level,
              default_priority,
              read_role,
              write_role,
              display_name,
              description,
              subject,
              html_body,
              body
       INTO   p_wf_messages_vl_tbl(1)
       FROM   wf_messages_vl
       WHERE  type = p_item_type
       AND    name = p_name;

    ELSE

       OPEN fetch_messages (p_item_type);

       /*
       ** Loop through all the lookup_code rows for the given message
       ** filling in the p_wf_messages_vl_tbl
       */
       LOOP

           l_record_num := l_record_num + 1;

           FETCH fetch_messages INTO p_wf_messages_vl_tbl(l_record_num);

           EXIT WHEN fetch_messages%NOTFOUND;

       END LOOP;

       CLOSE   fetch_messages;

       l_record_num := 0;

       OPEN fetch_message_attributes (p_item_type);

       LOOP

          l_record_num := l_record_num + 1;

          FETCH fetch_message_attributes INTO p_wf_message_attr_vl_tbl(
             l_record_num);

          EXIT WHEN fetch_message_attributes%NOTFOUND;

           /*
           ** If the validation for this attribute is a lookup then go get the
           ** display name for that lookup and put it in the
           ** lookup_type_display_name record element
           */
           IF (p_wf_message_attr_vl_tbl(l_record_num).type = 'LOOKUP') THEN

               wf_lookup_types_pub.fetch_lookup_display(
                  p_wf_message_attr_vl_tbl(l_record_num).format,
                  p_wf_message_attr_vl_tbl(l_record_num).text_default,
                  p_wf_message_attr_vl_tbl(l_record_num).lookup_type_display_name,
                  p_wf_message_attr_vl_tbl(l_record_num).lookup_code_display_name);

          END IF;

          /*
          ** If the default value for this attribute is an item attribute then
          ** populate the attr_default_display_name with the item attribute display
          ** name
          */
          IF (p_wf_message_attr_vl_tbl(l_record_num).value_type = 'ITEMATTR') THEN

               wf_item_attributes_vl_pub.fetch_item_attribute_display(
                  p_wf_message_attr_vl_tbl(l_record_num).message_type,
                  p_wf_message_attr_vl_tbl(l_record_num).text_default,
                  p_wf_message_attr_vl_tbl(l_record_num).attr_default_display_name);

          END IF;

       END LOOP;

       CLOSE fetch_message_attributes;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('wf_messages_vl_pub',
           'fetch_messages',
           p_item_type,
           p_name);

       wf_item_definition.Error;

END  fetch_messages;

/*===========================================================================
  PROCEDURE NAME:       fetch_message_display

  DESCRIPTION:          fetch the messagedisplay name based on a item
                        type name and an internal item message name

============================================================================*/
PROCEDURE fetch_message_display        (p_item_type     IN VARCHAR2,
                                        p_internal_name IN VARCHAR2,
                                        p_display_name  OUT NOCOPY VARCHAR2) IS

l_display_name           VARCHAR2(80);
l_wf_messages_vl_tbl     wf_messages_vl_pub.wf_messages_vl_tbl_type;
l_wf_message_attr_vl_tbl wf_messages_vl_pub.wf_message_attr_vl_tbl_type;

BEGIN

  /*
  ** Fetch the message record associated with this internal name
  */
  fetch_messages (p_item_type,
     p_internal_name,
     l_wf_messages_vl_tbl,
     l_wf_message_attr_vl_tbl);

   /*
   ** See if you found a row.  If not, proide the user with feedback
   */
   IF (l_wf_messages_vl_tbl.count < 1) THEN

      l_display_name := p_internal_name||' '||
         '<B> -- '||UPPER(wf_core.translate ('WFITD_UNDEFINED'))||'</B>';

   ELSE

      l_display_name := l_wf_messages_vl_tbl(1).display_name;

   END IF;

   p_display_name := l_display_name;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_messages_pub',
         'fetch_message_display',
         p_internal_name);

END fetch_message_display;

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

============================================================================*/
PROCEDURE draw_message_list
     (p_wf_messages_vl_tbl IN wf_messages_vl_pub.wf_messages_vl_tbl_type,
      p_wf_message_attr_vl_tbl IN wf_messages_vl_pub.wf_message_attr_vl_tbl_type,
      p_effective_date     IN DATE,
      p_indent_level       IN NUMBER) IS

l_message_record_num         NUMBER;
l_attr_record_num            NUMBER  := 1;
ii                           NUMBER  := 0;
l_cur_attr_record_num        NUMBER  := 1;
l_wf_message_attr_vl_tbl     wf_messages_vl_pub.wf_message_attr_vl_tbl_type;

BEGIN

  /*
  ** Create the the messages title.  Indent it to the level specified
  */
  wf_item_definition_util_pub.draw_summary_section_title(
       wf_core.translate('WFITD_MESSAGES'),
       p_indent_level);

  /*
  **  Print out all message display names in the pl*sql table
  */
  FOR l_message_record_num IN 1..p_wf_messages_vl_tbl.count LOOP

      /*
      ** The creation of the anchor from the summary frame to the detail
      ** frame was very complex so I've extracted the function into its
      ** own routine.
      */
      wf_item_definition_util_pub.create_hotlink_to_details (
            p_wf_messages_vl_tbl(l_message_record_num).type,
            p_effective_date,
            'MESSAGE',
            p_wf_messages_vl_tbl(l_message_record_num).name,
            p_wf_messages_vl_tbl(l_message_record_num).display_name,
            NULL,
            p_indent_level+1);

      /*
      ** Here we look for all the message attributes that are related to the
      ** current message.  The p_wf_message_attr_vl_tbl is ordered by display
      ** name and then by message attribute display name.  As long as we stay
      ** in sync we should be able to correctly create the temp attribute list
      ** for the current message.  We could create a cursor here for the child
      ** attributes but that would break the rule of separating the UI layer
      ** and the data layer
      */
      l_wf_message_attr_vl_tbl.delete;
      l_cur_attr_record_num := 1;

      /*
      ** Make sure there is at least on record in the message attribute
      ** list.  If there is not then the l_attr_record_num index of 1
      ** will cause a 6502-PL*SQL numeric or value error exception.
      */
      WHILE (
         l_attr_record_num <=  p_wf_message_attr_vl_tbl.count AND
         p_wf_messages_vl_tbl(l_message_record_num).display_name =
            p_wf_message_attr_vl_tbl(l_attr_record_num).message_display_name
         ) LOOP

         /*
         ** We have found an attribute for the current message.  Copy the
         ** contents of that list to a temp attr list and then pass the
         ** temp list to the message_attribute display function to display
         ** the results.
         */
         l_wf_message_attr_vl_tbl(l_cur_attr_record_num) :=
             p_wf_message_attr_vl_tbl(l_attr_record_num);

         l_attr_record_num := l_attr_record_num + 1;
         l_cur_attr_record_num := l_cur_attr_record_num + 1;

      END LOOP;

      /*
      ** If the l_cur_attr_record_num is greater than 1 then you
      ** must have found an attribute for this message.  Copy that
      ** set of attributes to a temporary pl*sql table and then
      ** print it out.
      */
      IF (l_cur_attr_record_num > 1) THEN

        /*
        ** List all the message attribute details for this message that
        ** we found above.  Add two to the current indent level so it
        ** is pushed in past the start of the message list.
        */
        wf_messages_vl_pub.draw_message_attr_list (
           l_wf_message_attr_vl_tbl,
           p_effective_date,
           p_indent_level + 2);

      END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_messages_vl_pub', 'draw_message_list');
      wf_item_definition.Error;

END draw_message_list;

/*===========================================================================
  PROCEDURE NAME:       draw_message_attr_list

  DESCRIPTION:          Shows the display names of message attributes for
                        a given message as a html view as a part of
                        a hierical summary list of an item type.
                        This function uses the htp to generate its html
                        output.

============================================================================*/
PROCEDURE draw_message_attr_list
     (p_wf_message_attr_vl_tbl IN wf_messages_vl_pub.wf_message_attr_vl_tbl_type,
      p_effective_date     IN DATE,
      p_indent_level       IN NUMBER) IS

l_record_num              NUMBER;
ii                        NUMBER  := 0;

BEGIN

  /*
  ** Create the the messages title.  Indent it to the level specified
  */
  wf_item_definition_util_pub.draw_summary_section_title(
       wf_core.translate('WFITD_MESSAGE_ATTRS'),
       p_indent_level);

  /*
  **  Print out all message display names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_message_attr_vl_tbl.count LOOP

      /*
      ** The creation of the anchor from the summary frame to the detail
      ** frame was very complex so I've extracted the function into its
      ** own routine.
      */
      IF (p_wf_message_attr_vl_tbl(l_record_num).name <> 'RESULT') THEN

         wf_item_definition_util_pub.create_hotlink_to_details (
            p_wf_message_attr_vl_tbl(l_record_num).message_type,
            p_effective_date,
            'MESSAGE_ATTR',
            p_wf_message_attr_vl_tbl(l_record_num).message_name||':'||
            p_wf_message_attr_vl_tbl(l_record_num).name,
            p_wf_message_attr_vl_tbl(l_record_num).display_name,
            NULL,
            p_indent_level+1);

      END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_messages_vl_pub', 'draw_message_attr_list');
      wf_item_definition.Error;

END draw_message_attr_list;

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

  MODIFICATION LOG:
   06-JUN-2001 JWSMITH BUG 1819232 - added summary attr for table tag for ADA
============================================================================*/
PROCEDURE draw_message_details
     (p_wf_messages_vl_tbl IN wf_messages_vl_pub.wf_messages_vl_tbl_type,
      p_wf_message_attr_vl_tbl IN wf_messages_vl_pub.wf_message_attr_vl_tbl_type,
      p_indent_level       IN NUMBER) IS

l_message_record_num       NUMBER  := 1;
l_attr_record_num          NUMBER  := 1;
l_attr_marker              NUMBER  := 1;
l_cur_attr_record_num      NUMBER  := 1;
ii                         NUMBER  := 0;
pri                        VARCHAR2(80) := NULL;
l_wf_message_attr_vl_tbl     wf_messages_vl_pub.wf_message_attr_vl_tbl_type;

BEGIN

  /*
  ** Draw the section title for the Message detail section
  */
  wf_item_definition_util_pub.draw_detail_section_title (
     wf_core.translate('WFITD_MESSAGE_DETAILS'),
     0);

  /*
  **  Print out all item attribute display names in the pl*sql table
  */
  FOR l_message_record_num IN 1..p_wf_messages_vl_tbl.count LOOP

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
        'MESSAGE',
        p_wf_messages_vl_tbl(l_message_record_num).name,
        p_wf_messages_vl_tbl(l_message_record_num).display_name,
        wf_core.translate('WFITD_MESSAGE_NAME'),
        0);

      /*
      ** Create the internal name row in the table.
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_INTERNAL_NAME'),
         p_wf_messages_vl_tbl(l_message_record_num).name);

      /*
      ** Create the description row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('DESCRIPTION'),
         p_wf_messages_vl_tbl(l_message_record_num).description);


      IF (p_wf_messages_vl_tbl(l_message_record_num).default_priority < 34) THEN
          pri := wf_core.translate('HIGH');

      ELSIF (p_wf_messages_vl_tbl(l_message_record_num).default_priority > 66) THEN
          pri := wf_core.translate('LOW');

      ELSE

          pri := wf_core.translate('MEDIUM');

      END IF;

      /*
      ** Create the priority row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('PRIORITY'), pri);

      /*
      ** Create the Subject row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('SUBJECT'),
         p_wf_messages_vl_tbl(l_message_record_num).subject);

      /*
      ** Create the html body row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_HTML_BODY'),
         p_wf_messages_vl_tbl(l_message_record_num).html_body);

      /*
      ** Create the text body row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_TEXT_BODY'),
         p_wf_messages_vl_tbl(l_message_record_num).body);

      /*
      ** Call function to print the read/write/execute roles
      */
      wf_item_definition_util_pub.draw_read_write_exe_details(
         p_wf_messages_vl_tbl(l_message_record_num).read_role,
         p_wf_messages_vl_tbl(l_message_record_num).write_role,
         null,
         FALSE);

      /*
      ** Call function to print the customization/protection levels
      */
      wf_item_definition_util_pub.draw_custom_protect_details(
         p_wf_messages_vl_tbl(l_message_record_num).custom_level,
         p_wf_messages_vl_tbl(l_message_record_num).protect_level);


      /*
      ** Go find  the result attribute in the list of attributes
      ** for this message
      */
      l_wf_message_attr_vl_tbl.delete;
      l_cur_attr_record_num := 1;
      l_attr_marker :=  l_attr_record_num;

      /*
      ** Make sure there is at least on record in the message attribute
      ** list.  If there is not then the l_attr_record_num index of 1
      ** will cause a 6502-PL*SQL numeric or value error exception.
      ** There is only ever 1 result attribute so once l_cur_attr_record_num
      ** incremented then exit the loop.
      */
      WHILE (
          l_cur_attr_record_num  = 1 AND
          l_attr_marker  <=  p_wf_message_attr_vl_tbl.count AND
          p_wf_messages_vl_tbl(l_message_record_num).display_name =
             p_wf_message_attr_vl_tbl(l_attr_marker).message_display_name
          ) LOOP

         /*
         ** We have found an attribute for the current message.  Check to
         ** see if this is the RESULT attribute.  If it is then copy the
         ** contents of that list to a temp attr list and then pass the
         ** temp list to the message_attribute display function to display
         ** the result.
         */
         IF (p_wf_message_attr_vl_tbl(l_attr_marker).name = 'RESULT') THEN


            l_wf_message_attr_vl_tbl(l_cur_attr_record_num) :=
                p_wf_message_attr_vl_tbl(l_attr_marker);

            l_cur_attr_record_num := l_cur_attr_record_num + 1;

            l_attr_marker := l_attr_marker + 1;

         END IF;

         l_attr_marker := l_attr_marker + 1;

      END LOOP;

      /*
      ** If you've found a result attribute then display it.  We pass a
      ** special value for the p_indent_level to tell it to not show
      ** certain pieces of the attribute
      */
      IF (l_cur_attr_record_num > 1) THEN

          wf_messages_vl_pub.draw_message_attr_details (
             l_wf_message_attr_vl_tbl,
             -1);

      END IF;

      /*
      ** Table is created so close it out
      */
      htp.tableClose;

      /*
      ** Here we look for all the message attributes that are related to the
      ** current message.  The p_wf_message_attr_vl_tbl is ordered by display
      ** name and then by message attribute display name.  As long as we stay
      ** in sync we should be able to correctly create the temp attribute list
      ** for the current message.  We could create a cursor here for the child
      ** attributes but that would break the rule of separating the UI layer
      ** and the data layer
      */
      l_wf_message_attr_vl_tbl.delete;
      l_cur_attr_record_num := 1;

      /*
      ** Make sure there is at least on record in the message attribute
      ** list.  If there is not then the l_attr_record_num index of 1
      ** will cause a 6502-PL*SQL numeric or value error exception.
      */
      WHILE (
          l_attr_record_num <=  p_wf_message_attr_vl_tbl.count AND
          p_wf_messages_vl_tbl(l_message_record_num).display_name =
             p_wf_message_attr_vl_tbl(l_attr_record_num).message_display_name
          ) LOOP

         /*
         ** We have found an attribute for the current message.  Copy the
         ** contents of that list to a temp attr list and then pass the
         ** temp list to the message_attribute display function to display
         ** the results.  If the message attribute is named RESULT then
         ** Skip it since it will be displayed as part of the message
         ** definition
         */
         IF (p_wf_message_attr_vl_tbl(l_attr_record_num).name <> 'RESULT') THEN

            l_wf_message_attr_vl_tbl(l_cur_attr_record_num) :=
                p_wf_message_attr_vl_tbl(l_attr_record_num);
            l_cur_attr_record_num := l_cur_attr_record_num + 1;

         END IF;

         l_attr_record_num := l_attr_record_num + 1;

      END LOOP;

      /*
      ** If the l_cur_attr_record_num is greater than 1 then you
      ** must have found an attribute for this message.  Copy that
      ** set of attributes to a temporary pl*sql table and then
      ** print it out.
      */
      IF (l_cur_attr_record_num > 1) THEN

        /*
        ** Put in a couple of blank lines between the current message
        ** and its attributes
        */
        htp.p('<BR><BR>');

        /*
        ** List all the message attribute details for this message that
        ** we found above.
        */
        wf_messages_vl_pub.draw_message_attr_details (
           l_wf_message_attr_vl_tbl,
           1);

        /*
        ** If you still have more messages to process then put in a
        ** few blank lines and put in another Message Details Header
        */
        IF (l_message_record_num < p_wf_messages_vl_tbl.count) THEN

           /*
           ** Put in a couple of blank lines between the current message
           ** attributes and the next message
           */
           htp.p('<BR><BR>');

           /*
           ** Draw the section title for the Message detail section
           */
           wf_item_definition_util_pub.draw_detail_section_title (
              wf_core.translate('WFITD_MESSAGE_DETAILS'),
              0);

        END IF;

     END IF;


     /*
     ** Draw a line between each message definition
     ** if this is not the last item in the list and if there
     ** are no attributes in the attribute list for this message.
     */
     IF (l_message_record_num < p_wf_messages_vl_tbl.count AND
         l_cur_attr_record_num = 1) THEN

         htp.p ('<HR noshade size="1">');

     END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_messages_vl_pub', 'draw_message_details');
      wf_item_definition.Error;

END draw_message_details;

/*===========================================================================
  PROCEDURE NAME:       draw_message_attr_details

  DESCRIPTION:          Shows all of the details for a list of
                        message attributes for that have been passed
                        in.

  MODIFICATION LOG:
   06-JUN-2001 JWSMITH BUG 1819232 - added summary attr for table tag for ADA
============================================================================*/
PROCEDURE draw_message_attr_details
     (p_wf_message_attr_vl_tbl IN wf_messages_vl_pub.wf_message_attr_vl_tbl_type,
      p_indent_level              IN NUMBER) IS

l_record_num       NUMBER;
ii                 NUMBER  := 0;

BEGIN

  /*
  ** Draw the section title for the message attribute detail section
  ** If p_indent_level is = -1 then you are printing some special component
  ** of the parent object that is stored as an attribute but really is
  ** shown as part of the parent item in the builder
  */
  IF (p_indent_level <> -1) THEN

     wf_item_definition_util_pub.draw_detail_section_title (
        wf_core.translate('WFITD_MESSAGE_ATTR_DETAILS'),
        0);

  END IF;

  /*
  **  Print out all meesage attribute display names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_message_attr_vl_tbl.count LOOP

      IF (p_indent_level <> -1) THEN

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
           'MESSAGE_ATTR',
           p_wf_message_attr_vl_tbl(l_record_num).message_name||':'||
                p_wf_message_attr_vl_tbl(l_record_num).name,
           p_wf_message_attr_vl_tbl(l_record_num).display_name,
           wf_core.translate('WFITD_MESSAGE_ATTR_NAME'),
           0);

         /*
         ** Create the internal name row in the table.
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_INTERNAL_NAME'),
            p_wf_message_attr_vl_tbl(l_record_num).name);

         /*
         ** Create the message display name row in the table.
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_MESSAGE_NAME'),
            p_wf_message_attr_vl_tbl(l_record_num).message_display_name);

      ELSE

         /*
         ** Create the attribute display name row in the table.
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_RESULT_DISPLAY_NAME'),
            p_wf_message_attr_vl_tbl(l_record_num).display_name);

      END IF;

      /*
      ** Create the description row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('DESCRIPTION'),
         p_wf_message_attr_vl_tbl(l_record_num).description);

      /*
      ** Create the attribute type row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_ATTRIBUTE_TYPE'),
            wf_core.translate('WFITD_ATTR_TYPE_'||
            p_wf_message_attr_vl_tbl(l_record_num).type));

      /*
      ** Create the length/format/lookup type row in the table.
      ** If the type is VARCHAR2 then show a length prompt
      ** If the type is NUMBER/DATE then show format prompt
      ** If the type is LOOKUP then show lookup type prompt
      ** If it is any other type then don't show the row at all
      */
      IF (p_wf_message_attr_vl_tbl(l_record_num).type = 'VARCHAR2') THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('LENGTH'),
            p_wf_message_attr_vl_tbl(l_record_num).format);

      ELSIF (p_wf_message_attr_vl_tbl(l_record_num).type IN ('NUMBER', 'DATE')) THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('FORMAT'),
            p_wf_message_attr_vl_tbl(l_record_num).format);

      ELSIF (p_wf_message_attr_vl_tbl(l_record_num).type = 'LOOKUP') THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('LOOKUP'),
            p_wf_message_attr_vl_tbl(l_record_num).lookup_type_display_name);

      ELSIF (p_wf_message_attr_vl_tbl(l_record_num).type IN ('URL','DOCUMENT')) THEN
         /*
         ** If it is URL or DOCUMENT, indicate where the resulting page should be displayed
         */
         IF (NVL(p_wf_message_attr_vl_tbl(l_record_num).format, '_top') = '_top') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_TOP'));
         ELSIF (p_wf_message_attr_vl_tbl(l_record_num).format = '_blank') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_BLANK'));
         ELSIF (p_wf_message_attr_vl_tbl(l_record_num).format = '_self') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_SELF'));
         ELSIF (p_wf_message_attr_vl_tbl(l_record_num).format = '_parent') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_PARENT'));
         END IF;

         /*
         ** If the message attribute is a send, then display the attachment
         ** preference.
         */
         IF p_wf_message_attr_vl_tbl(l_record_num).subtype = 'SEND' THEN
            IF NVL(p_wf_message_attr_vl_tbl(l_record_num).attach, 'N') = 'Y' THEN
               wf_item_definition_util_pub.draw_detail_prompt_value_pair (
                  wf_core.translate('WFITD_ATTACH'),
                  wf_core.translate('WFITD_YES'));
            ELSE
               wf_item_definition_util_pub.draw_detail_prompt_value_pair (
                  wf_core.translate('WFITD_ATTACH'),
                  wf_core.translate('WFITD_NO'));
            END iF;

         END IF;
      END IF;

      /*
      ** Create the source row in the table
      */
      IF (p_indent_level <> -1) THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_SOURCE'),
            wf_core.translate('WFITD_MSG_SOURCE_TYPE_'||
               p_wf_message_attr_vl_tbl(l_record_num).subtype));

      END IF;

      /*
      ** Create the default type row
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_DEFAULT_TYPE'),
         wf_core.translate('WFITD_DEFAULT_TYPE_'||
            p_wf_message_attr_vl_tbl(l_record_num).value_type));

      /*
      ** If the default value is a constant then show the default value type
      ** that is not null. If the default value is based on an item attribute
      ** then show the attr_default_display_name.
      */
      IF (p_wf_message_attr_vl_tbl(l_record_num).value_type = 'ITEMATTR') THEN

         /*
         ** Create the default item attribute row in the table. This is based on the
         ** p_wf_message_attr_vl_tbl(l_record_num).attr_default_display_name
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_DEFAULT_VALUE'),
            p_wf_message_attr_vl_tbl(l_record_num).attr_default_display_name);


      /*
      ** Create the default value row in the table.   If the attribute type is based on
      ** a lookup then the default value must be one of the lookup codes.  If so print
      ** the lookup code that was fetch.
      */
      ELSIF (p_wf_message_attr_vl_tbl(l_record_num).type = 'LOOKUP') THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_DEFAULT_VALUE'),
            p_wf_message_attr_vl_tbl(l_record_num).lookup_code_display_name);

      /*
      ** If this is any other attribute type then
      ** nvl on text value.  If there is no text value then try the number
      ** default.  If there is no number default then try the date.
      */
      ELSE

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_DEFAULT_VALUE'),
            NVL(p_wf_message_attr_vl_tbl(l_record_num).text_default,
               NVL(TO_CHAR(p_wf_message_attr_vl_tbl(l_record_num).number_default),
                  TO_CHAR(p_wf_message_attr_vl_tbl(l_record_num).date_default))));

      END IF;
      /*
      ** Table is created so close it out
      */
      htp.tableClose;

      /*
      ** Draw a line between each message attribute definition
      ** if this is not the last item in the list
      */
      IF (l_record_num <> p_wf_message_attr_vl_tbl.count AND
          p_indent_level <> -1) THEN

         htp.p ('<HR noshade size="1">');

      END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_messages_vl_pub', 'draw_message_attr_details');
      wf_item_definition.Error;

END draw_message_attr_details;

END wf_messages_vl_pub;

/
