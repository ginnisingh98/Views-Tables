--------------------------------------------------------
--  DDL for Package Body WF_ACTIVITIES_VL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ACTIVITIES_VL_PUB" AS
/* $Header: wfdefb.pls 120.1 2005/07/02 03:43:48 appldev ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_activities_vl_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

============================================================================*/

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

============================================================================*/
PROCEDURE fetch_activities
     (p_item_type       IN  VARCHAR2,
      p_activity_type   IN  VARCHAR2,
      p_effective_date  IN  DATE,
      p_name            IN  VARCHAR2,
      p_wf_activities_vl_tbl   OUT NOCOPY wf_activities_vl_pub.wf_activities_vl_tbl_type,
      p_wf_activity_attr_vl_tbl   OUT NOCOPY wf_activities_vl_pub.wf_activity_attr_vl_tbl_type) IS

/*===========================================================================

  CURSOR NAME:          fetch_typed_activities

  DESCRIPTION:          Fetches all activities of a certain type for a given
                        item_type and effective date for the activities.

                        You'll notice we are selecting the activity
                        display name three times.  The second is a placeholder
                        used when the result type display name.
                        The third occurrence is a placeholder in the
                        record so that I can fill in that column
                        with the message display name if this activity is
                        a notification.

  PARAMETERS:

        c_item_type IN  Internal name of the item type

        c_type      IN  Type of activity you would like to fetch
                        (PROCESS, NOTICE, FUNCTION)

        c_effective_date IN
                        The requested effective date.  Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.

============================================================================*/
CURSOR fetch_typed_activities (c_item_type      IN VARCHAR2,
                               c_type           IN VARCHAR2,
                               c_effective_date IN DATE) IS
SELECT  row_id,
 item_type,
 name,
 version,
 type,
 rerun,
 expand_role,
 protect_level,
 custom_level,
 begin_date,
 end_date,
 function,
 function_type,
 result_type,
 cost,
 read_role,
 write_role,
 execute_role,
 icon_name,
 message,
 error_process,
 runnable_flag,
 error_item_type,
 event_name,
 direction,
 display_name,
 display_name result_type_display_name,
 display_name message_display_name,
 description
FROM   wf_activities_vl
WHERE  item_type = c_item_type
AND    type      = c_type
AND    begin_date <= c_effective_date
AND   (end_date is null or
       end_date > c_effective_date)
ORDER  BY display_name;

/*===========================================================================

  CURSOR NAME:          fetch_typed_activities

  DESCRIPTION:          Fetches all activities for a given
                        item_type and effective date for the activities.

                        You'll notice we are selecting the activity
                        display name three times.  The second is a placeholder
                        used when the result type display name.
                        The third occurrence is a placeholder in the
                        record so that I can fill in that column
                        with the message display name if this activity is
                        a notification.

  PARAMETERS:

        c_item_type IN  Internal name of the item type

        c_effective_date IN
                        The requested effective date.  Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.

============================================================================*/
CURSOR fetch_all_activities (c_item_type      IN VARCHAR2,
                             c_effective_date IN DATE) IS
SELECT  row_id,
 item_type,
 name,
 version,
 type,
 rerun,
 expand_role,
 protect_level,
 custom_level,
 begin_date,
 end_date,
 function,
 function_type,
 result_type,
 cost,
 read_role,
 write_role,
 execute_role,
 icon_name,
 message,
 error_process,
 runnable_flag,
 error_item_type,
 event_name,
 direction,
 display_name,
 display_name result_type_display_name,
 display_name message_display_name,
 description
FROM   wf_activities_vl
WHERE  item_type = c_item_type
AND    begin_date <= c_effective_date
AND   (end_date is null or
       end_date > c_effective_date)
ORDER  BY DECODE(type, 'PROCESS', 1, 'NOTICE', 2, 'FUNCTION', 3, 'EVENT', 4,
       5),
       display_name;


/*===========================================================================

  CURSOR NAME:          fetch_activity_attributes

  DESCRIPTION:          Fetches all activity attributes for the given
                        item_type and effective date for the activity.

                        You'll notice that the select orders the
                        results by activity type, activity display
                        name, and then by attribute sequence.  The first two
                        order criteria are based on the requirement to
                        synchronize the attribute list with the activity list.
                        The activity list is ordered by activity type and
                        activity display name.  When we list the activities
                        and their corresponding attributes we walk these lists
                        in parallel.  When we find an attribute that matches
                        the current activity, we copy that attribute to a temp
                        list until we find a new activity in the attribute
                        list.  When this happens we write out the attribute
                        temp list and move to the next activity.  Thus the need
                        for the special order criteria.

                        You might also notice that we are selecting the activity
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

        c_effective_date IN
                        The requested effective date.  Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.

============================================================================*/
CURSOR fetch_activity_attributes (c_item_type IN VARCHAR2,
                                  c_effective_date IN VARCHAR2) IS
 SELECT
 wact.type activity_type,
 wact.display_name activity_display_name,
 wact.display_name attr_default_display_name,
 wact.display_name lookup_type_display_name,
 wact.display_name lookup_code_display_name,
 waa.row_id,
 waa.activity_item_type,
 waa.activity_name,
 waa.activity_version,
 waa.name,
 waa.sequence,
 waa.type,
 waa.value_type,
 waa.protect_level,
 waa.custom_level,
 waa.subtype,
 waa.format,
 waa.text_default,
 waa.number_default,
 waa.date_default,
 waa.display_name,
 waa.description
FROM    wf_activity_attributes_vl waa,
        wf_activities_vl wact
WHERE   waa.activity_item_type = c_item_type
AND     wact.item_type = c_item_type
AND     wact.name = waa.activity_name
AND     wact.version = waa.activity_version
AND     wact.begin_date <= c_effective_date
AND     (wact.end_date is null OR
          wact.end_date > c_effective_date)
ORDER  BY DECODE(wact.type, 'PROCESS', 1, 'NOTICE', 2, 'FUNCTION', 3,
          'EVENT', 4, 5),
          wact.display_name, waa.sequence;

l_record_num               NUMBER  := 0;
l_throwaway                VARCHAR2(1);

BEGIN

   /*
   ** Make sure all the required parameters are set
   */
   IF (p_item_type IS NULL) THEN

      return;

   END IF;

   /*
   ** Check if the caller has passed a specific activity_name to search for.
   ** If so then just get the row corresponding to that item_type and
   ** activity_name.  If not then get all rows for that item_type.  You
   ** also have the option of selecting activities of a certain type into
   ** the pl*sql table or all activities for the given item type
   */
   IF (p_name IS NOT NULL AND p_activity_type IS NOT NULL) THEN

      SELECT  row_id,
              item_type,
              name,
              version,
              type,
              rerun,
              expand_role,
              protect_level,
              custom_level,
              begin_date,
              end_date,
              function,
              function_type,
              result_type,
              cost,
              read_role,
              write_role,
              execute_role,
              icon_name,
              message,
              error_process,
              runnable_flag,
              error_item_type,
              event_name,
              direction,
              display_name,
              display_name result_type_display_name,
              display_name message_display_name,
              description
       INTO   p_wf_activities_vl_tbl(1)
       FROM   wf_activities_vl
       WHERE  item_type = p_item_type
       AND    type      = p_activity_type
       AND    name      = p_name
       AND    begin_date <= p_effective_date
       AND   (end_date is null or
              end_date > p_effective_date);


       /*
       ** Get the display name for the result type for this activity and
       ** put it in the result_type_display_name field
       */
       IF (NVL(p_wf_activities_vl_tbl(1).result_type,
          '*') <> '*') THEN

          wf_lookup_types_pub.fetch_lookup_display(
              p_wf_activities_vl_tbl(1).result_type,
              null,
              p_wf_activities_vl_tbl(1).result_type_display_name,
              l_throwaway);

       END IF;

       /*
       ** If this is a notification activity and the message is populated
       ** then go get the display name for the message and put it in
       ** message_display_name
       */
       IF (p_wf_activities_vl_tbl(1).message IS NOT NULL) THEN

          wf_messages_vl_pub.fetch_message_display (
              p_wf_activities_vl_tbl(1).item_type,
              p_wf_activities_vl_tbl(1).message,
              p_wf_activities_vl_tbl(1).message_display_name);

       END IF;

    /*
    ** If you pass in an item_type and an activity type then get all
    ** activities relating to the given
    */
    ELSIF (p_name IS NULL AND p_activity_type IS NOT NULL) THEN

       OPEN fetch_typed_activities (p_item_type,
                                    p_activity_type,
                                    p_effective_date);

       /*
       ** Loop through the specific type of activity row
       ** for the given item_type filling in the p_wf_activities_vl_tbl
       */
       LOOP

           l_record_num := l_record_num + 1;

           FETCH fetch_typed_activities INTO p_wf_activities_vl_tbl(l_record_num);

           EXIT WHEN fetch_typed_activities%NOTFOUND;

           /*
           ** Get the display name for the result type for this activity and
           ** put it in the result_type_display_name field
           */
           IF (NVL(p_wf_activities_vl_tbl(l_record_num).result_type,
              '*') <> '*') THEN

              wf_lookup_types_pub.fetch_lookup_display(
                  p_wf_activities_vl_tbl(l_record_num).result_type,
                  null,
                  p_wf_activities_vl_tbl(l_record_num).result_type_display_name,
                  l_throwaway);

            END IF;

            /*
            ** If this is a notification activity and the message is populated
            ** then go get the display name for the message and put it in
            ** message_display_name
            */
            IF (p_wf_activities_vl_tbl(l_record_num).message IS NOT NULL) THEN

               wf_messages_vl_pub.fetch_message_display (
                  p_wf_activities_vl_tbl(l_record_num).item_type,
                  p_wf_activities_vl_tbl(l_record_num).message,
                  p_wf_activities_vl_tbl(l_record_num).message_display_name);

            END IF;

       END LOOP;

       CLOSE fetch_typed_activities;

    ELSIF (p_name IS NULL AND p_activity_type IS NULL) THEN

       OPEN fetch_all_activities (p_item_type,
                                  p_effective_date);

       /*
       ** Loop through all the activitiy rows for the given item_type
       ** filling in the p_wf_activities_vl_tbl
       */
       LOOP

           l_record_num := l_record_num + 1;

           FETCH fetch_all_activities INTO p_wf_activities_vl_tbl(l_record_num);
           EXIT WHEN fetch_all_activities%NOTFOUND;

           /*
           ** Get the display name for the result type for this activity and
           ** put it in the result_type_display_name field
           */
           IF (NVL(p_wf_activities_vl_tbl(l_record_num).result_type,
              '*') <> '*') THEN

              wf_lookup_types_pub.fetch_lookup_display(
                  p_wf_activities_vl_tbl(l_record_num).result_type,
                  null,
                  p_wf_activities_vl_tbl(l_record_num).result_type_display_name,
                  l_throwaway);

           END IF;

           /*
           ** If this is a notification activity and the message is populated
           ** then go get the display name for the message and put it in
           ** message_display_name
           */
           IF (p_wf_activities_vl_tbl(l_record_num).message IS NOT NULL) THEN

              wf_messages_vl_pub.fetch_message_display (
                 p_wf_activities_vl_tbl(l_record_num).item_type,
                 p_wf_activities_vl_tbl(l_record_num).message,
                 p_wf_activities_vl_tbl(l_record_num).message_display_name);

           END IF;

       END LOOP;

       CLOSE fetch_all_activities;

       OPEN fetch_activity_attributes (p_item_type,
                                       p_effective_date);

       l_record_num := 0;

       /*
       ** Loop through all the activitiy rows for the given item_type
       ** filling in the p_wf_activities_vl_tbl
       */
       LOOP

           l_record_num := l_record_num + 1;

           FETCH fetch_activity_attributes INTO
              p_wf_activity_attr_vl_tbl(l_record_num);

           EXIT WHEN fetch_activity_attributes%NOTFOUND;

           /*
           ** If the validation for this attribute is a lookup then go get the
           ** display name for that lookup and put it in the
           ** lookup_type_display_name record element
           */
           IF (p_wf_activity_attr_vl_tbl(l_record_num).type = 'LOOKUP') THEN

               wf_lookup_types_pub.fetch_lookup_display(
                  p_wf_activity_attr_vl_tbl(l_record_num).format,
                  p_wf_activity_attr_vl_tbl(l_record_num).text_default,
                  p_wf_activity_attr_vl_tbl(l_record_num).lookup_type_display_name,
                  p_wf_activity_attr_vl_tbl(l_record_num).lookup_code_display_name);

          END IF;

          /*
          ** If the default value for this attribute is an item attribute then
          ** populate the attr_default_display_name with the item attribute display
          ** name
          */
          IF (p_wf_activity_attr_vl_tbl(l_record_num).value_type = 'ITEMATTR') THEN

               wf_item_attributes_vl_pub.fetch_item_attribute_display(
                  p_wf_activity_attr_vl_tbl(l_record_num).activity_item_type,
                  p_wf_activity_attr_vl_tbl(l_record_num).text_default,
                  p_wf_activity_attr_vl_tbl(l_record_num).attr_default_display_name);

          END IF;

       END LOOP;

       CLOSE fetch_activity_attributes;

    END IF;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_activities_vl_pub',
         'fetch_activities',
          p_item_type,
          p_activity_type,
          TO_CHAR(p_effective_date),
          p_name);

      wf_item_definition.Error;

END  fetch_activities;


/*===========================================================================
  PROCEDURE NAME:       fetch_draw_activity_details

  DESCRIPTION:          Fetches and draws a single activity for a
                        given item type.  This function is basically
                        a cover for the fetch_activities and
                        draw_activity_details routines.

============================================================================*/
PROCEDURE fetch_draw_activity_details
     (p_item_type       IN  VARCHAR2,
      p_activity_type   IN  VARCHAR2,
      p_effective_date  IN  VARCHAR2,
      p_name            IN  VARCHAR2) IS

l_username                   varchar2(320);   -- Username to query
l_wf_activities_vl_tbl       wf_activities_vl_pub.wf_activities_vl_tbl_type;
l_wf_activity_attr_vl_tbl    wf_activities_vl_pub.wf_activity_attr_vl_tbl_type;
l_effective_date             DATE;
l_date_date                  DATE;
l_valid_date                 BOOLEAN;
l_print_date                 VARCHAR2(80);
l_expected_format            VARCHAR2(80);

BEGIN

  -- Check session and current user
  wfa_sec.GetSession(l_username);

  /*
  ** Get the NLS Date format that is currently set.  All to_char of
  ** date values should use the l_expected_format
  */
  wf_item_definition_util_pub.validate_date (
     TO_CHAR(sysdate, 'DD-MON-RRRR HH24:MI:SS'),
     l_date_date,
     l_valid_date,
     l_expected_format);

   l_effective_date := TO_DATE(p_effective_date, 'YYYY/MM/DD HH24:MI:SS');
   l_print_date := TO_CHAR(l_effective_date, l_expected_format);

   /*
   ** Create a standard title page with the item_type display name as the title
   */
   wf_item_definition.draw_header(
      p_item_type,
      l_print_date,
      'DISPLAY');


   /*
   ** Give me a blank line if this is a process activity
   ** Any other type of activity is handled correctly by
   ** the draw skipped activity headers function
   */
   IF (p_activity_type = 'PROCESS') THEN

      htp.p('<BR><BR>');

   END IF;

   /*
   ** Get the activity definition
   */
   wf_activities_vl_pub.fetch_activities
     (p_item_type,
      p_activity_type,
      l_effective_date,
      p_name,
      l_wf_activities_vl_tbl,
      l_wf_activity_attr_vl_tbl);

   /*
   ** Draw the activity definition details
   */
   wf_activities_vl_pub.draw_activity_details
     (l_wf_activities_vl_tbl,
      l_wf_activity_attr_vl_tbl,
      l_effective_date,
      0,
      FALSE,
      FALSE);

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_activities_vl_pub',
         'fetch_draw_activity_details',
          p_item_type,
          p_activity_type,
          p_effective_date,
          p_name);

      wf_item_definition.Error;

END  fetch_draw_activity_details;

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

============================================================================*/
PROCEDURE draw_activity_list
     (p_wf_activities_vl_tbl      IN wf_activities_vl_pub.wf_activities_vl_tbl_type,
      p_wf_activity_attr_vl_tbl   IN wf_activities_vl_pub.wf_activity_attr_vl_tbl_type,
      p_effective_date       IN DATE,
      p_indent_level         IN NUMBER) IS

l_activity_record_num            NUMBER := 1;
l_attr_record_num                NUMBER := 1;
l_cur_attr_record_num            NUMBER := 1;
l_highest_activity       NUMBER  := 1;
ii                       NUMBER  := 0;
l_activity_type          VARCHAR2(8);
l_summary_section_title  VARCHAR2(240);
l_wf_activity_attr_vl_tbl wf_activities_vl_pub.wf_activity_attr_vl_tbl_type;

BEGIN

  l_activity_type := 'UNSET';

  /*
  **  Print out all item attribute display names in the pl*sql table
  */
  FOR l_activity_record_num IN 1..p_wf_activities_vl_tbl.count LOOP

      /*
      ** Check to see if the activity type has changed since the last
      ** that you printed.  If so then create the title.  If this is a \
      ** special type of activity like a folder then
      ** don't reset your context
      */
      IF (l_activity_type <> p_wf_activities_vl_tbl(l_activity_record_num).type AND
          p_wf_activities_vl_tbl(l_activity_record_num).type <> 'FOLDER') THEN

         /*
         ** Reset the activity type to the local name
         */
         l_activity_type := p_wf_activities_vl_tbl(l_activity_record_num).type;

         /*
         ** The type has changed so print the proper title
         */
         IF (l_activity_type = 'PROCESS') THEN

            /*
            ** Set the the processes title.
            */
            l_summary_section_title := wf_core.translate('PROCESSES');

            /*
            ** Set the indicator for the highest activity found.  This is
            ** used later to print any missing headers.
            */
            l_highest_activity := 2;

         ELSIF (l_activity_type = 'NOTICE') THEN

            /*
            ** Set the the notifications title.
            */
            l_summary_section_title := wf_core.translate('WFITD_NOTIFICATIONS');

            /*
            ** Check to see if you skipped the processes section in case
            ** there weren't any.  If so print out the header for the processes
            ** here.
            */
            wf_item_definition_util_pub.activity_titles_list (
               l_highest_activity,
               2,
               p_indent_level);

            /*
            ** Set the indicator for the highest activity found.  This is
            ** used later to print any missing headers.
            */
            l_highest_activity := 3;


         ELSIF (l_activity_type = 'FUNCTION') THEN

            /*
            ** Set the functions title.
            */
            l_summary_section_title := wf_core.translate('WFITD_FUNCTIONS');

            /*
            ** Check to see if you skipped the processes and or Notifications
            ** section in case there weren't any.  If so print out the
            ** header for the processes and/or notificaitons here.
            */
            wf_item_definition_util_pub.activity_titles_list (
               l_highest_activity,
               3,
               p_indent_level);

            /*
            ** Set the indicator for the highest activity found.  This is
            ** used later to print any missing headers.
            */
            l_highest_activity := 4;

         ELSIF (l_activity_type = 'EVENT') THEN

            /*
            ** Set the functions title.
            */
            l_summary_section_title := wf_core.translate('WFITD_EVENTS');

            /*
            ** Check to see if you skipped the processes and or Notifications
            ** section in case there weren't any.  If so print out the
            ** header for the processes and/or notificaitons here.
            */
            wf_item_definition_util_pub.activity_titles_list (
               l_highest_activity,
               4,
               p_indent_level);

            /*
            ** Set the indicator for the highest activity found.  This is
            ** used later to print any missing headers.
            */
            l_highest_activity := 5;

         END IF;

         /*
         ** Create the the activity type summary title.
         ** Indent it to the level specified
         */
         wf_item_definition_util_pub.draw_summary_section_title(
             l_summary_section_title,
             p_indent_level);

      END IF;

      /*
      ** If this is a special type of activity like a folder then
      ** don't show it in the list
      */
      IF (p_wf_activities_vl_tbl(l_activity_record_num).type <> 'FOLDER') THEN

         /*
         ** The creation of the anchor from the summary frame to the detail
         ** frame was very complex so I've extracted the function into its
         ** own routine.
         */
         wf_item_definition_util_pub.create_hotlink_to_details (
            p_wf_activities_vl_tbl(l_activity_record_num).item_type,
            p_effective_date,
            l_activity_type,
            p_wf_activities_vl_tbl(l_activity_record_num).name,
            p_wf_activities_vl_tbl(l_activity_record_num).display_name,
            NULL,
            p_indent_level+1);

         /*
         ** Here we look for all the activity attributes that are related
         ** to the current activity.  The p_wf_activity_attr_vl_tbl is
         ** ordered by activity type, activity display name and then
         ** by activity attribute display name.  As long as we stay
         ** in sync we should be able to correctly create the temp
         ** attribute list for the current activity.
         ** We could create a cursor here for the child
         ** attributes but that would break the rule of separating the UI layer
         ** and the data layer
         */
         l_wf_activity_attr_vl_tbl.delete;
         l_cur_attr_record_num := 1;

         /*
         ** Make sure there the l_attr_record_num is less than or equal to
         ** p_wf_activity_attr_vl_tbl.count.  If there is not then the
         ** l_attr_record_num index of 1
         ** will cause a 6502-PL*SQL numeric or value error exception.
         */
         WHILE (
            l_attr_record_num <=  p_wf_activity_attr_vl_tbl.count AND
            p_wf_activities_vl_tbl(l_activity_record_num).type =
               p_wf_activity_attr_vl_tbl(l_attr_record_num).activity_type
            AND p_wf_activities_vl_tbl(l_activity_record_num).display_name =
               p_wf_activity_attr_vl_tbl(l_attr_record_num).activity_display_name
            ) LOOP

            /*
            ** We have found an attribute for the current activity.  Copy the
            ** contents of that list to a temp attr list and then pass the
            ** temp list to the activity attribute display function to display
            ** the results.
            */
            l_wf_activity_attr_vl_tbl(l_cur_attr_record_num) :=
                p_wf_activity_attr_vl_tbl(l_attr_record_num);

            l_attr_record_num := l_attr_record_num + 1;
            l_cur_attr_record_num := l_cur_attr_record_num + 1;


         END LOOP;

         /*
         ** If the l_cur_attr_record_num is greater than 1 then you
         ** must have found an attribute for this activity.  Copy that
         ** set of attributes to a temporary pl*sql table and then
         ** print it out.
         */
         IF (l_cur_attr_record_num > 1) THEN

            /*
            ** List all the activity attribute details for this message that
            ** we found above.  Add two to the current indent level so it
            ** is pushed in past the start of the message list.
            */
            wf_activities_vl_pub.draw_activity_attr_list (
               l_wf_activity_attr_vl_tbl,
               p_effective_date,
               p_indent_level + 2);

         END IF;

      END IF;

  END LOOP;

  /*
  ** Check to see if you skipped the processes section in case
  ** there weren't any.  If so print out the header for the processes
  ** here.
  */
  wf_item_definition_util_pub.activity_titles_list (
     l_highest_activity,
     4,
     p_indent_level);

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_activities_vl_pub', 'draw_activity_list');
      wf_item_definition.Error;

END draw_activity_list;


/*===========================================================================
  PROCEDURE NAME:       draw_activity_attr_list

  DESCRIPTION:          Shows the display names of activity attributes for
                        a given activity as a html view as a part of
                        a hierical summary list of an item type.
                        This function uses the htp to generate its html
                        output.

============================================================================*/
PROCEDURE draw_activity_attr_list
     (p_wf_activity_attr_vl_tbl IN wf_activities_vl_pub.wf_activity_attr_vl_tbl_type,
      p_effective_date     IN DATE,
      p_indent_level       IN NUMBER) IS

l_record_num              NUMBER;
ii                        NUMBER  := 0;

BEGIN

  /*
  ** Create the the activity attributes title.
  ** I'm using the first record to determine the type since all
  ** attributes in this list are for the same activity of a specfic
  ** type
  */
  IF (p_wf_activity_attr_vl_tbl(1).activity_type = 'PROCESS') THEN

     wf_item_definition_util_pub.draw_summary_section_title(
          wf_core.translate('WFITD_PROCESS_ATTRS'),
          p_indent_level);

  ELSIF (p_wf_activity_attr_vl_tbl(1).activity_type = 'NOTICE') THEN

     wf_item_definition_util_pub.draw_summary_section_title(
          wf_core.translate('WFITD_NOTIFICATION_ATTRS'),
          p_indent_level);

  ELSE

     wf_item_definition_util_pub.draw_summary_section_title(
          wf_core.translate('WFITD_FUNCTION_ATTRS'),
          p_indent_level);

  END IF;

  /*
  **  Print out all activity attribute display names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_activity_attr_vl_tbl.count LOOP

      /*
      ** The creation of the anchor from the summary frame to the detail
      ** frame was very complex so I've extracted the function into its
      ** own routine.  The target name is especially complex.  It is the
      ** combination of the activity_type, the activity_name, and the
      ** activity_attribute_name.  This will ensure uniqueness.  ie
      ** #ACTIVITY_ATTR:FUNCTION:CHECK_FUNDS:FUNDS_AVAILABLE
      */
      wf_item_definition_util_pub.create_hotlink_to_details (
         p_wf_activity_attr_vl_tbl(l_record_num).activity_item_type,
         p_effective_date,
         'ACTIVITY_ATTR',
         p_wf_activity_attr_vl_tbl(l_record_num).activity_type||':'||
         p_wf_activity_attr_vl_tbl(l_record_num).activity_name||':'||
         p_wf_activity_attr_vl_tbl(l_record_num).name,
         p_wf_activity_attr_vl_tbl(l_record_num).display_name,
         NULL,
         p_indent_level+1);

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_activities_vl_pub', 'draw_activity_attr_list');
      wf_item_definition.Error;

END draw_activity_attr_list;

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

  MODIFICATION LOG:
   06-JUN-2001 JWSMITH BUG 1819232 - added summary attr for table tag for ADA
============================================================================*/
PROCEDURE draw_activity_details
     (p_wf_activities_vl_tbl IN wf_activities_vl_pub.wf_activities_vl_tbl_type,
      p_wf_activity_attr_vl_tbl IN wf_activities_vl_pub.wf_activity_attr_vl_tbl_type,
      p_effective_date       IN DATE,
      p_indent_level         IN NUMBER,
      p_create_child_links   IN BOOLEAN,
      p_print_skipped_titles IN BOOLEAN) IS

l_username      varchar2(320);   -- Username to query
l_activity_record_num             NUMBER := 1;
l_attr_record_num                 NUMBER := 1;
l_cur_attr_record_num             NUMBER := 1;
l_highest_activity        NUMBER  := 1;
ii                        NUMBER := 0;
l_timeout_minutes         NUMBER := 0;
l_timeout_hours           NUMBER := 0;
l_timeout_days            NUMBER := 0;
l_runnable_process        NUMBER := 0;
l_date_date               DATE;
l_valid_date              BOOLEAN;
l_expected_format         VARCHAR2(80);
l_activity_type           VARCHAR2(8);
l_end_date                VARCHAR2(80);
l_activity_name_prompt    VARCHAR2(80);
l_activity_section_title  VARCHAR2(240);
l_wf_activity_attr_vl_tbl wf_activities_vl_pub.wf_activity_attr_vl_tbl_type;

BEGIN

  -- Check session and current user
  wfa_sec.GetSession(l_username);

  l_activity_type := 'UNSET';

  /*
  **  Print out all item attribute display names in the pl*sql table
  */
  FOR l_activity_record_num IN 1..p_wf_activities_vl_tbl.count LOOP

      /*
      ** Check to see if the activity type has changed since the last
      ** that you printed.  If so then create the title.  If this is a
      ** special type of activity like a folder then
      ** don't reset your context
      */
      IF (l_activity_type <> p_wf_activities_vl_tbl(l_activity_record_num).type AND
          p_wf_activities_vl_tbl(l_activity_record_num).type <> 'FOLDER') THEN

         /*
         ** Reset the activity type to the local name
         */
         l_activity_type := p_wf_activities_vl_tbl(l_activity_record_num).type;

         /*
         ** The type has changed so print the proper title for the region
         **
         ** Also set the appropriate prompt for the internal name for the
         ** activity prompt
         */
         IF (l_activity_type = 'PROCESS') THEN

            /*
            ** Put on the the processes title.
            */
            l_activity_section_title := wf_core.translate('WFITD_PROCESS_DETAILS');
            l_activity_name_prompt := wf_core.translate('WFITD_PROCESS_NAME');

            /*
            ** Set the indicator for the highest activity found.  This is
            ** used later to print any missing headers.
            */
            l_highest_activity := 2;

         ELSIF (l_activity_type = 'NOTICE') THEN

            /*
            ** Put on the the processes title.
            */
            l_activity_section_title := wf_core.translate('WFITD_NOTIFICATION_DETAILS');
            l_activity_name_prompt := wf_core.translate('WFITD_NOTIFICATION_NAME');

            /*
            ** Check to see if you skipped the processes section in case
            ** there weren't any.  If so print out the header for the processes
            ** here.
            */
            IF (p_print_skipped_titles = TRUE) THEN

               wf_item_definition_util_pub.activity_titles_details (
                  l_highest_activity,
                  2);

             END IF;

            /*
            ** Set the indicator for the highest activity found.  This is
            ** used later to print any missing headers.
            */
            l_highest_activity := 3;

         ELSIF (l_activity_type = 'FUNCTION') THEN

            /*
            ** Put on the the processes title.
            */
            l_activity_section_title := wf_core.translate('WFITD_FUNCTION_DETAILS');
            l_activity_name_prompt := wf_core.translate('WFITD_FUNCTION_NAME');

            /*
            ** Check to see if you skipped the processes and or Notifications
            ** section in case there weren't any.  If so print out the
            ** header for the processes and/or notificaitons here.
            */
            IF (p_print_skipped_titles = TRUE) THEN

               wf_item_definition_util_pub.activity_titles_details (
                  l_highest_activity,
                  3);

            END IF;

            /*
            ** Set the indicator for the highest activity found.  This is
            ** used later to print any missing headers.
            */
            l_highest_activity := 4;

         ELSIF (l_activity_type = 'EVENT') THEN

            /*
            ** Put on the the event title.
            */
            l_activity_section_title := wf_core.translate('WFITD_EVENT_DETAILS');
            l_activity_name_prompt := wf_core.translate('WFITD_EVENT_NAME');

            /*
            ** Check to see if you skipped the events, processes
            ** and or Notifications section in case there weren't
            ** any.  If so print out the header for the processes
            ** and/or notificaitons here.
            */
            IF (p_print_skipped_titles = TRUE) THEN

               wf_item_definition_util_pub.activity_titles_details (
                  l_highest_activity,
                  4);

            END IF;

            /*
            ** Set the indicator for the highest activity found.  This is
            ** used later to print any missing headers.
            */
            l_highest_activity := 5;

         END IF;

         /*
         ** If you are creating the Notification of Function detail
         ** list then skip a couple of rows since you don't have an
         ** interrupt from the parent to perform this function
         */
         IF (l_activity_type IN ('NOTICE', 'FUNCTION', 'EVENT')) THEN

            htp.p ('<BR><BR>');

         END IF;

         /*
         ** Draw the section title for the activity detail section
         */
         wf_item_definition_util_pub.draw_detail_section_title (
            l_activity_section_title,
            0);

      END IF;

      /*
      ** If this is a special type of activity like a folder then
      ** don't print it
      */
      IF (p_wf_activities_vl_tbl(l_activity_record_num).type <> 'FOLDER') THEN

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
            p_wf_activities_vl_tbl(l_activity_record_num).type,
            p_wf_activities_vl_tbl(l_activity_record_num).name,
            p_wf_activities_vl_tbl(l_activity_record_num).display_name,
            l_activity_name_prompt,
            0);

         /*
         ** Create the internal name row in the table.
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_INTERNAL_NAME'),
            p_wf_activities_vl_tbl(l_activity_record_num).name);

         /*
         ** Create the description row in the table
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('DESCRIPTION'),
            p_wf_activities_vl_tbl(l_activity_record_num).description);

         /*
         ** If this is a process or notification activity, only show the function row
         ** if the function field is populate.  If this is a function activity then
         ** always create the function row
         */
         IF ((p_wf_activities_vl_tbl(l_activity_record_num).type = 'PROCESS' AND
             p_wf_activities_vl_tbl(l_activity_record_num).function IS NOT NULL) OR
              p_wf_activities_vl_tbl(l_activity_record_num).type IN ('NOTICE', 'FUNCTION')) THEN


            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFITD_FUNCTION'),
               p_wf_activities_vl_tbl(l_activity_record_num).function);

            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFITD_FUNCTION_TYPE'),
               NVL(p_wf_activities_vl_tbl(l_activity_record_num).function_type, 'PL/SQL'));

         END IF;

         /*
         ** Create the result type row in the table
         ** Do not show the result type field if it is equal to * which
         ** occurs when a notification is FYI and doesn't expect a response
         */
         IF (NVL(p_wf_activities_vl_tbl(l_activity_record_num).result_type,
             '*') <> '*') THEN

            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFITD_RESULT_TYPE'),
               p_wf_activities_vl_tbl(l_activity_record_num).result_type_display_name);

         END IF;

         /*
         ** There are a number of activity attributes that are tied to the
         ** type of activity you are printing.  Encapsulated here are most
         ** of those differences since they are usually at the bottom of the
         ** main dialog in the Builder.
         */
         IF (l_activity_type = 'PROCESS') THEN

            /*
            ** Select whether this process is runnable or not.  This is
            ** the most optimal method of getting this info rather than
            ** doing this in the view since you would have to do an
            ** outer join on the WF_RUNNABLE_PROCESSES_V view and that
            ** will cause a full table scan on activities.
            */
            SELECT count(*)
            INTO   l_runnable_process
            FROM   WF_RUNNABLE_PROCESSES_V
            WHERE  item_type = p_wf_activities_vl_tbl(l_activity_record_num).item_type
            AND    process_name = p_wf_activities_vl_tbl(l_activity_record_num).name;

            IF (l_runnable_process > 0) THEN

               /*
               ** Create the runnable row in the table
               */
               wf_item_definition_util_pub.draw_detail_prompt_value_pair (
                  wf_core.translate('WFITD_RUNNABLE'),
                  wf_core.translate('WFITD_YES'));

            ELSE

              /*
              ** Create the runnable row in the table
              */
              wf_item_definition_util_pub.draw_detail_prompt_value_pair (
                 wf_core.translate('WFITD_RUNNABLE'),
                 wf_core.translate('WFITD_NO'));

            END IF;

         ELSIF (l_activity_type = 'NOTICE') THEN

            /*
            ** Create the message name row in the table
            ** Only create a link to the message details if you are
            ** drawing the message details.  IN ( 'm not going to use
            ** the create_hotlink_to_details here.  IN ( could
            */
            IF (p_create_child_links = TRUE) THEN

               wf_item_definition_util_pub.create_hotlink_to_details(
                  p_wf_activities_vl_tbl(l_activity_record_num).item_type,
                  p_effective_date,
                  'MESSAGE',
                  p_wf_activities_vl_tbl(l_activity_record_num).message,
                  p_wf_activities_vl_tbl(l_activity_record_num).message_display_name,
                  wf_core.translate('MESSAGE_NAME'),
                  0);

            ELSE

               wf_item_definition_util_pub.draw_detail_prompt_value_pair (
                  wf_core.translate('MESSAGE_NAME'),
                  p_wf_activities_vl_tbl(l_activity_record_num).message_display_name);

            END IF;

            /*
            ** Create the expand roles in the table
            */
            IF (p_wf_activities_vl_tbl(l_activity_record_num).expand_role = 'Y') THEN

               wf_item_definition_util_pub.draw_detail_prompt_value_pair (
                  wf_core.translate('WFITD_EXPAND_ROLES'),
                  wf_core.translate('WFITD_YES'));

            ELSE

               wf_item_definition_util_pub.draw_detail_prompt_value_pair (
                  wf_core.translate('WFITD_EXPAND_ROLES'),
                  wf_core.translate('WFITD_NO'));

            END IF;

         ELSIF (l_activity_type = 'FUNCTION') THEN

            /*
            ** Create the cost row in the table
            */
            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFMON_COST'),
               TO_CHAR((p_wf_activities_vl_tbl(l_activity_record_num).cost/100)));

         ELSIF (l_activity_type = 'EVENT') THEN

            /*
            ** Create the event name and direction rows in the table
            */
            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFITD_EVENT'),
               p_wf_activities_vl_tbl(l_activity_record_num).event_name);
            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFITD_DIRECTION'),
               p_wf_activities_vl_tbl(l_activity_record_num).direction);

         END IF;

         /*
         ** Create the icon name in the table
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_ICON'),
            p_wf_activities_vl_tbl(l_activity_record_num).icon_name);

         /*
         ** Create the error item type name in the table
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFMON_ERROR_TYPE'),
            p_wf_activities_vl_tbl(l_activity_record_num).error_item_type);

         /*
         ** Create the error process name in the table
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFMON_ERROR_PROCESS'),
            p_wf_activities_vl_tbl(l_activity_record_num).error_process);


         /*
         ** Get the expected format for the date.  You'll notice that I've
         ** added a time element to sysdate.  That ensures the time format
         ** will be included in l_expected_format.  You don't care about the
         ** validation stuff
         */
         wf_item_definition_util_pub.validate_date (
            TO_CHAR(sysdate, 'DD-MON-YY')||' 00:00:00',
            l_date_date,
            l_valid_date,
            l_expected_format);

         /*
         ** Only populate the l_end_date for the continuation of the effective
         ** date if there is an end date otherwise leave it null.
         */
         IF (p_wf_activities_vl_tbl(l_activity_record_num).end_date IS NOT NULL) THEN

             l_end_date := ' - ' ||
                TO_CHAR(p_wf_activities_vl_tbl(l_activity_record_num).end_date,
                   l_expected_format);

         ELSE

             l_end_date := '';

         END IF;

         /*
         ** Create the effective date range in the table
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_EFFECTIVE'),
             TO_CHAR(p_wf_activities_vl_tbl(l_activity_record_num).begin_date,
                 l_expected_format)|| l_end_date);

         /*
         ** Create the loop reset description
         */
         IF (p_wf_activities_vl_tbl(l_activity_record_num).rerun =  'RESET') THEN

            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFITD_LOOP_RESET'),
                wf_core.translate('WFITD_LOOP_RESET_VALUE'));

         ELSIF (p_wf_activities_vl_tbl(l_activity_record_num).rerun =  'LOOP') THEN

            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFITD_LOOP_RESET'),
                wf_core.translate('WFITD_LOOP_RESET_LOOP'));

         ELSE

            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFITD_LOOP_RESET'),
                wf_core.translate('WFITD_LOOP_RESET_IGNORE'));

         END IF;

         /*
         ** Create the version row in the table
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_VERSION'),
            p_wf_activities_vl_tbl(l_activity_record_num).version);

         /*
         ** Call function to print the read/write/execute roles
         */
         wf_item_definition_util_pub.draw_read_write_exe_details(
            p_wf_activities_vl_tbl(l_activity_record_num).read_role,
            p_wf_activities_vl_tbl(l_activity_record_num).write_role,
            p_wf_activities_vl_tbl(l_activity_record_num).execute_role,
            TRUE);

         /*
         ** Call function to print the customization/protection levels
         */
         wf_item_definition_util_pub.draw_custom_protect_details(
            p_wf_activities_vl_tbl(l_activity_record_num).custom_level,
            p_wf_activities_vl_tbl(l_activity_record_num).protect_level);

         /*
         ** Table is created so close it out
         */
         htp.tableClose;

         /*
         ** Here we look for all the activity attributes that are related to
         ** the current activity.  The p_wf_activity_attr_vl_tbl is
         ** ordered by activty type (PROCESS, NOTICE, FUNCTION) then by
         ** display name and then by activity attribute
         ** display name.  As long as we stay in sync we should be
         ** able to correctly create the temp attribute list
         ** for the current activity.  We could create a cursor
         ** here for the child  attributes but that would break
         ** the rule of separating the UI layer and the data layer
         */
         l_wf_activity_attr_vl_tbl.delete;
         l_cur_attr_record_num := 1;

         /*
         ** Make sure there is at least on record in the activity attribute
         ** list.  If there is not then the l_attr_record_num index of 1
         ** will cause a 6502-PL*SQL numeric or value error exception.
         */
         WHILE (
            l_attr_record_num <=  p_wf_activity_attr_vl_tbl.count AND
            p_wf_activities_vl_tbl(l_activity_record_num).type =
               p_wf_activity_attr_vl_tbl(l_attr_record_num).activity_type
            AND p_wf_activities_vl_tbl(l_activity_record_num).display_name =
               p_wf_activity_attr_vl_tbl(l_attr_record_num).activity_display_name
            ) LOOP

            /*
            ** We have found an attribute for the current activity.  Copy the
            ** contents of that list to a temp attr list and then pass the
            ** temp list to the activity_attribute display function to display
            ** the results.
            */
            l_wf_activity_attr_vl_tbl(l_cur_attr_record_num) :=
                p_wf_activity_attr_vl_tbl(l_attr_record_num);

            l_attr_record_num := l_attr_record_num + 1;
            l_cur_attr_record_num := l_cur_attr_record_num + 1;

         END LOOP;

         /*
         ** If the l_cur_attr_record_num is greater than 1 then you
         ** must have found an attribute for this activity.  Copy that
         ** set of attributes to a temporary pl*sql table and then
         ** print it out.
         */
         IF (l_cur_attr_record_num > 1) THEN

           /*
           ** Put in a couple of blank lines between the current activity
           ** and its attributes
           */
           htp.p('<BR><BR>');

           /*
           ** List all the activity attribute details for this activity that
           ** we found above.
           */
           wf_activities_vl_pub.draw_activity_attr_details (
              l_wf_activity_attr_vl_tbl,
              1);

           /*
           ** If you still have more activities to process and the next activity is
           ** the same type as the current one then put in a
           ** few blank lines and put in another Activity Details Header
           */
           IF (l_activity_record_num < p_wf_activities_vl_tbl.count AND
               l_activity_type = p_wf_activities_vl_tbl(l_activity_record_num + 1).type) THEN

              /*
              ** Put in a couple of blank lines between the current activity
              ** attributes and the next activity
              */
              htp.p('<BR><BR>');

              /*
              ** Draw the section title for the Activity detail section
              */
              wf_item_definition_util_pub.draw_detail_section_title (
                 l_activity_section_title,
                 0);

           END IF;

         END IF;


         /*
         ** Draw a line between each activity definition
         ** if this is not the last item in the list and if there
         ** are no attributes in the attribute list for this activity and
         ** there are more activities of the same type
         */
         IF (l_activity_record_num < p_wf_activities_vl_tbl.count AND
             l_cur_attr_record_num = 1 AND
             l_activity_type = p_wf_activities_vl_tbl(l_activity_record_num + 1).type) THEN

               htp.p ('<HR noshade size="1">');

         END IF;

      END IF;

  END LOOP;

  /*
  ** Check to see if you skipped the processes section in case
  ** there weren't any.  If so print out the header for the processes
  ** here.
  */
  IF (p_print_skipped_titles = TRUE) THEN

     wf_item_definition_util_pub.activity_titles_details (
        l_highest_activity,
        4);

  END IF;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_activities_vl_pub', 'draw_activity_details');
      wf_item_definition.Error;

END draw_activity_details;

/*===========================================================================
  PROCEDURE NAME:       draw_activity_attr_details

  DESCRIPTION:          Shows all of the details for a list of
                        activity attributes for that have been passed
                        in.

  MODIFICATION LOG:
   06-JUN-2001 JWSMITH BUG 1819232 - added summary attr for table tag for ADA
============================================================================*/
PROCEDURE draw_activity_attr_details
     (p_wf_activity_attr_vl_tbl IN wf_activities_vl_pub.wf_activity_attr_vl_tbl_type,
      p_indent_level              IN NUMBER) IS

l_record_num       NUMBER;
ii                 NUMBER  := 0;
l_activity_name_prompt    VARCHAR2(80);
l_activity_attr_name_prompt    VARCHAR2(80);
l_activity_section_title  VARCHAR2(240);

BEGIN

  /*
  ** Create the the activity attributes title.
  ** I'm using the first record to determine the type since all
  ** attributes in this list are for the same activity of a specfic
  ** type
  */
  IF (p_wf_activity_attr_vl_tbl(1).activity_type = 'PROCESS') THEN

     /*
     ** Put on the the processes title.
     */
     l_activity_section_title := wf_core.translate('WFITD_PROCESS_ATTR_DETAILS');
     l_activity_name_prompt := wf_core.translate('WFITD_PROCESS_NAME');
     l_activity_attr_name_prompt := wf_core.translate('WFITD_PROCESS_ATTR_NAME');

  ELSIF (p_wf_activity_attr_vl_tbl(1).activity_type = 'NOTICE') THEN

     /*
     ** Put on the the notification title.
     */
     l_activity_section_title := wf_core.translate('WFITD_NOTIFICATION_ATTR_DETAIL');
     l_activity_name_prompt := wf_core.translate('WFITD_NOTIFICATION_NAME');
     l_activity_attr_name_prompt := wf_core.translate('WFITD_NOTIFICATION_ATTR_NAME');

  ELSIF (p_wf_activity_attr_vl_tbl(1).activity_type = 'FUNCTION') THEN

     /*
     ** Put on the the function title.
     */
     l_activity_section_title := wf_core.translate('WFITD_FUNCTION_ATTR_DETAILS');
     l_activity_name_prompt := wf_core.translate('WFITD_FUNCTION_NAME');
     l_activity_attr_name_prompt := wf_core.translate('WFITD_FUNCTION_ATTR_NAME');

  END IF;


  /*
  ** Draw the section title for the activity attribute detail section
  */
  wf_item_definition_util_pub.draw_detail_section_title (
     l_activity_section_title,
     0);

  /*
  **  Print out all meesage attribute display names in the pl*sql table
  */
  FOR l_record_num IN 1..p_wf_activity_attr_vl_tbl.count LOOP

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
         'ACTIVITY_ATTR',
         p_wf_activity_attr_vl_tbl(l_record_num).activity_type||':'||
         p_wf_activity_attr_vl_tbl(l_record_num).activity_name||':'||
         p_wf_activity_attr_vl_tbl(l_record_num).name,
         p_wf_activity_attr_vl_tbl(l_record_num).display_name,
         l_activity_attr_name_prompt,
        0);

      /*
      ** Create the internal name row in the table.
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_INTERNAL_NAME'),
         p_wf_activity_attr_vl_tbl(l_record_num).name);

      /*
      ** Create the activity display name row in the table.
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         l_activity_name_prompt,
         p_wf_activity_attr_vl_tbl(l_record_num).activity_display_name);

      /*
      ** Create the description row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('DESCRIPTION'),
         p_wf_activity_attr_vl_tbl(l_record_num).description);

      /*
      ** Create the attribute type row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_ATTRIBUTE_TYPE'),
         wf_core.translate('WFITD_ATTR_TYPE_'||
         p_wf_activity_attr_vl_tbl(l_record_num).type));

      /*
      ** Create the length/format/lookup type row in the table.
      ** If the type is VARCHAR2 then show a length prompt
      ** If the type is NUMBER/DATE then show format prompt
      ** If the type is LOOKUP then show lookup type prompt
      ** If it is any other type then don't show the row at all
      */
      IF (p_wf_activity_attr_vl_tbl(l_record_num).type = 'VARCHAR2') THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('LENGTH'),
            p_wf_activity_attr_vl_tbl(l_record_num).format);

      ELSIF (p_wf_activity_attr_vl_tbl(l_record_num).type IN ('DATE', 'NUMBER')) THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('FORMAT'),
            p_wf_activity_attr_vl_tbl(l_record_num).format);

      ELSIF (p_wf_activity_attr_vl_tbl(l_record_num).type = 'LOOKUP') THEN

         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('LOOKUP'),
            p_wf_activity_attr_vl_tbl(l_record_num).lookup_type_display_name);

      ELSIF (p_wf_activity_attr_vl_tbl(l_record_num).type IN ('URL','DOCUMENT')) THEN
         /*
         ** If it is URL or DOCUMENT, indicate where the resulting page should be displayed
         */
         IF (NVL(p_wf_activity_attr_vl_tbl(l_record_num).format, '_top') = '_top') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_TOP'));
         ELSIF (p_wf_activity_attr_vl_tbl(l_record_num).format = '_blank') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_BLANK'));
         ELSIF (p_wf_activity_attr_vl_tbl(l_record_num).format = '_self') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_SELF'));
         ELSIF (p_wf_activity_attr_vl_tbl(l_record_num).format = '_parent') THEN
            wf_item_definition_util_pub.draw_detail_prompt_value_pair
                   (wf_core.translate('WFITD_FRAME_TARGET'), wf_core.translate('WFITD_PARENT'));
         END IF;


      END IF;

      /*
      ** Create the default type row
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_DEFAULT_TYPE'),
         wf_core.translate('WFITD_DEFAULT_TYPE_'||
            p_wf_activity_attr_vl_tbl(l_record_num).value_type));


      /*
      ** If the default value is a constant then show the default value type
      ** that is not null. If the default value is based on an item attribute
      ** then show the attr_default_display_name.
      */
      IF (p_wf_activity_attr_vl_tbl(l_record_num).value_type = 'ITEMATTR') THEN

         /*
         ** Create the default item attribute row in the table. This is based on the
         ** p_wf_activity_attr_vl_tbl(l_record_num).attr_default_display_name
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_DEFAULT_VALUE'),
            p_wf_activity_attr_vl_tbl(l_record_num).attr_default_display_name);

      /*
      ** Create the default value row in the table.  If the attribute type is based on
      ** a lookup then the default value must be one of the lookup codes.  If so print
      ** the lookup code that was fetch.
      */
      ELSIF (p_wf_activity_attr_vl_tbl(l_record_num).type = 'LOOKUP') THEN

            wf_item_definition_util_pub.draw_detail_prompt_value_pair (
               wf_core.translate('WFITD_DEFAULT_VALUE'),
               p_wf_activity_attr_vl_tbl(l_record_num).lookup_code_display_name);

      /*
      ** If this is any other attribute type then
      ** nvl on text value.  If there is no text value then try the number
      ** default.  If there is no number default then try the date.
      */
      ELSE

        wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_DEFAULT_VALUE'),
            NVL(p_wf_activity_attr_vl_tbl(l_record_num).text_default,
               NVL(TO_CHAR(p_wf_activity_attr_vl_tbl(l_record_num).number_default),
                  TO_CHAR(p_wf_activity_attr_vl_tbl(l_record_num).date_default))));

      END IF;

      /*
      ** Table is created so close it out
      */
      htp.tableClose;

      /*
      ** Draw a line between each activity attribute definition
      ** if this is not the last item in the list
      */
      IF (l_record_num <> p_wf_activity_attr_vl_tbl.count) THEN

         htp.p ('<HR noshade size="1">');

      END IF;

  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('wf_activities_vl_pub', 'draw_activity_attr_details');
      wf_item_definition.Error;

END draw_activity_attr_details;

END wf_activities_vl_pub;

/
