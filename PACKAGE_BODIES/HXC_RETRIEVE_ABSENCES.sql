--------------------------------------------------------
--  DDL for Package Body HXC_RETRIEVE_ABSENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RETRIEVE_ABSENCES" AS
/* $Header: hxcretabs.pkb 120.0.12010000.46 2010/03/19 13:35:17 bbayragi noship $ */

g_debug BOOLEAN := hr_utility.debug_enabled;


TYPE ALIAS_TAB IS TABLE OF VARCHAR2(400) INDEX BY BINARY_INTEGER;
TYPE NUMTABLE IS TABLE OF NUMBER;
TYPE VARCHARTABLE IS TABLE OF VARCHAR2(500);
g_alias_tab      ALIAS_TAB;
g_pref_table     hxc_preference_evaluation.t_pref_table;
g_dummy_bbit     NUMBER;
g_alias_bbit     NUMBER;
g_layout_bbit    NUMBER;
g_pending_appr   BOOLEAN := FALSE;
g_pending_delete BOOLEAN := FALSE;
-- Bug 8995913
-- Added the following flag.
g_pending_conf   BOOLEAN := FALSE;




PROCEDURE retrieve_absences( p_person_id   IN NUMBER,
                             p_start_date  IN DATE,
                             p_end_date    IN DATE,
                             p_abs_tab     IN OUT NOCOPY hxc_retrieve_absences.abs_tab)
AS


     l_abs_org_tab hr_person_absence_api.abs_data;
     l_abs_inv     hr_person_absence_api.abs_data_inv;



     l_abs_att_id      NUMBER;
     l_abs_type_id     NUMBER;
     l_days            NUMBER;
     l_hours           NUMBER;
     l_start           DATE;
     l_end             DATE;
     l_element_type_id NUMBER;
     l_start_time      DATE;
     l_stop_time       DATE;

     l_abs_tab         ABS_TAB;
     l_ind             BINARY_INTEGER;

BEGIN

    l_ind := 1;
    -- Bug 8864418
    g_pending_appr := FALSE;
    g_pending_delete := FALSE;
    -- Bug 8995913
    g_pending_conf   := FALSE;

    hr_person_absence_api.get_absence_data(p_person_id=>p_person_id,
                                           p_start_date => p_start_date,
                                           p_end_date => p_end_date,
                                           absence_records => l_abs_org_tab,
                			   absence_records_inv => l_abs_inv );


    IF l_abs_org_tab.COUNT > 0
    THEN
       FOR i in l_abs_org_tab.FIRST..l_abs_org_tab.LAST
       LOOP
          << CONTINUE_TO_NEXT >>
          LOOP

          IF g_debug
          THEN
              hr_utility.trace('ABS : l_abs_org_tab(i).absence_type_id '||l_abs_org_tab(i).absence_type_id);
              hr_utility.trace('ABS : l_abs_org_tab(i).abs_startdate '||l_abs_org_tab(i).abs_startdate);
              hr_utility.trace('ABS : l_abs_org_tab(i).abs_enddate '||l_abs_org_tab(i).abs_enddate);
              hr_utility.trace('ABS : l_abs_org_tab(i).rec_start_date '||l_abs_org_tab(i).rec_start_date);
              hr_utility.trace('ABS : l_abs_org_tab(i).rec_end_date '||l_abs_org_tab(i).rec_end_date);
              hr_utility.trace('ABS : l_abs_org_tab(i).confirmed_flag '||l_abs_org_tab(i).confirmed_flag);
          END IF;
          IF TRUNC(fnd_date.canonical_to_date(l_abs_org_tab(i).abs_startdate)) > TRUNC(p_end_date)
            OR TRUNC(fnd_date.canonical_to_date(l_abs_org_tab(i).abs_startdate)) < TRUNC(p_start_date)
          THEN
             IF g_debug
             THEN
                 hr_utility.trace('ABS : Spans outside the timecard ');
             END IF;
             EXIT CONTINUE_TO_NEXT;
          END IF;


          p_abs_tab(l_ind).abs_type_id         :=l_abs_org_tab(i).absence_type_id ;
          p_abs_tab(l_ind).abs_date            :=TRUNC(fnd_date.canonical_to_date(l_abs_org_tab(i).abs_startdate)) ;
          p_abs_tab(l_ind).element_type_id     := l_abs_org_tab(i).element_type_ID ;
          p_abs_tab(l_ind).abs_attendance_id   := l_abs_org_tab(i).absence_attendance_id ;
          p_abs_tab(l_ind).prg_appl_id         := l_abs_org_tab(i).program_application_id ;
          p_abs_tab(l_ind).rec_start_date      := l_abs_org_tab(i).rec_start_date ;
          p_abs_tab(l_ind).rec_end_date        := l_abs_org_tab(i).rec_end_date ;

          -- Bug 8995913
          -- Added the following to pick up confirmed or not flag.
          p_abs_tab(l_ind).confirmed_flag      := l_abs_org_tab(i).confirmed_flag ;

          IF p_abs_tab(l_ind).confirmed_flag = 'N'
          THEN
              g_pending_conf := TRUE;
          END IF;


          IF l_abs_org_tab(i).days_or_hours = 'D'
          THEN
              p_abs_tab(l_ind).uom := 'D' ;
              p_abs_tab(l_ind).duration := 1 ;
          ELSE
              p_abs_tab(l_ind).uom := 'H';
              p_abs_tab(l_ind).duration := NVL(l_abs_org_tab(i).rec_duration,
                                               (fnd_date.canonical_to_date(l_abs_org_tab(i).abs_enddate) -
                                                fnd_date.canonical_to_date(l_abs_org_tab(i).abs_startdate)
                                               )*24);
          END IF;

          IF l_abs_org_tab(i).days_or_hours = 'H'
          THEN
              p_abs_tab(l_ind).abs_start := fnd_date.canonical_to_date(l_abs_org_tab(i).abs_startdate) ;
              p_abs_tab(l_ind).abs_end   := fnd_date.canonical_to_date(l_abs_org_tab(i).abs_enddate) ;
          END IF;



          IF l_abs_org_tab(i).transactionid IS NOT NULL
          THEN
              IF g_debug
              THEN
                 hr_utility.trace('ABS : This is an SSHR transaction ');
              END IF;
              p_abs_tab(l_ind).transaction_id := l_abs_org_tab(i).transactionid;
              p_abs_tab(l_ind).modetype := l_abs_org_tab(i).modetype;
              IF p_abs_tab(l_ind).modetype = 'DeleteMode'
              THEN
                 g_pending_delete := TRUE;
              END IF;
              g_pending_appr := TRUE;
          END IF;
          l_ind := l_ind + 1;
          EXIT CONTINUE_TO_NEXT;
          END LOOP CONTINUE_TO_NEXT;
       END LOOP;   -- FOR i in l_abs_org_tab.FIRST..l_abs_org_tab.LAST
    END IF;

    IF g_pref_table.COUNT > 0
    THEN
        FOR i IN g_pref_table.FIRST..g_pref_table.LAST
        LOOP
            IF g_pref_table(i).preference_code = 'TS_ABS_PREFERENCES'
            THEN
                IF g_pending_appr = TRUE
                THEN
                    IF g_pending_delete = TRUE
                    THEN
                        hxc_timecard_message_helper.addErrorToCollection
                                                   ( g_messages
                                                    ,'HXC_ABS_PEND_APPR_DELETE'
                                                    ,hxc_timecard.c_error
                                                    ,NULL
            					       ,NULL
            					       ,hxc_timecard.c_hxc
            					       ,NULL
            					       ,NULL
            					       ,NULL
            					       ,NULL
            					        );
                         hr_utility.trace('ABS : This is a DELETE pending in SSHR ');
                         g_message_string := 'HXC_ABS_PEND_APPR_DELETE';
                         EXIT;
                     END IF; -- Pending Delete = TRUE

                     IF g_pref_table(i).attribute3 = 'ERROR'
                     THEN
                        hr_utility.trace('ABS : This is pending APPROVAL in SSHR -- ERROR');
                        hxc_timecard_message_helper.addErrorToCollection
                                                    (g_messages
                                                    ,'HXC_ABS_PEND_APPR_ERROR'
                                                    ,hxc_timecard.c_error
            					       ,NULL
            					       ,NULL
            					       ,hxc_timecard.c_hxc
            					       ,NULL
            					       ,NULL
            					       ,NULL
            					       ,NULL
            					        );
                        hr_utility.trace('ABS : A pending approval error added ');
                        g_message_string := 'HXC_ABS_PEND_APPR_ERROR';
                     END IF; -- Attribute3 = ERROR
                     EXIT;

                END IF;    -- PENDING APPR = TRUE

                -- Bug 8995913
                -- Added the below construct to block the timecard if
                -- absences pending confirmation are not allowed.

                IF g_pending_conf = TRUE
                THEN
                   IF g_pref_table(i).attribute7 = 'ERROR'
                   THEN
                        hr_utility.trace('ABS : This is pending Confirmation in SSHR -- ERROR');
                        hxc_timecard_message_helper.addErrorToCollection
                                                    (g_messages
                                                    ,'HXC_ABS_PEND_CONF_ERROR'
                                                    ,hxc_timecard.c_error
            					       ,NULL
            					       ,NULL
            					       ,hxc_timecard.c_hxc
            					       ,NULL
            					       ,NULL
            					       ,NULL
            					       ,NULL
            					        );
                        hr_utility.trace('ABS : A pending Confirmation error added ');
                        g_message_string := 'HXC_ABS_PEND_CONF_ERROR';
                    END IF;
                 END IF; -- PENDING CONF = TRUE
                EXIT;
            END IF;	    -- PREF CODE = TS_ABS_PREFERENCES
        END LOOP;
    END IF;

    -- Bug 8855103
    -- Added the below construct to clear off invalid transactions.
    IF l_abs_inv.COUNT > 0
    THEN
        l_ind := l_abs_inv.FIRST;
        LOOP
           BEGIN
                hr_person_absence_swi.delete_absences_in_tt(l_abs_inv(l_ind).transactionid);
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      NULL;
           END;
           l_ind := l_abs_inv.NEXT(l_ind);
           EXIT WHEN NOT l_abs_inv.EXISTS(l_ind);
        END LOOP;
    END IF;


END retrieve_absences;


FUNCTION get_alias_for_detail     ( p_bb_id            IN NUMBER,
                                    p_bb_ovn  	       IN NUMBER,
                                    p_element_type_id  IN NUMBER,
                                    p_attribute_id     IN NUMBER)
RETURN HXC_ATTRIBUTE_TYPE
IS

l_attribute_type  HXC_ATTRIBUTE_TYPE;

BEGIN

    l_attribute_type := HXC_ATTRIBUTE_TYPE(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               			           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               			       	   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


    l_attribute_type.time_attribute_id       := p_attribute_id;
    l_attribute_type.attribute_category      := 'ALTERNATE NAME IDENTIFIERS';
    l_attribute_type.attribute1              := g_alias_tab(p_element_type_id);
    l_attribute_type.bld_blk_info_type_id    := g_alias_bbit;
    l_attribute_type.bld_blk_info_type       := 'ALTERNATE NAME IDENTIFIERS';
    l_attribute_type.BUILDING_BLOCK_ID       := p_bb_id;
    l_attribute_type.BUILDING_BLOCK_OVN      := p_bb_ovn;
    l_attribute_type.OBJECT_VERSION_NUMBER   := 1;

    RETURN l_attribute_type;


END get_alias_for_detail;




PROCEDURE gen_alt_ids   ( p_person_id           IN NUMBER,
                          p_start_time          IN DATE,
                          p_stop_time           IN DATE,
                          p_mode                IN VARCHAR2)
IS

l_ind         BINARY_INTEGER;
l_alias_list  VARCHAR2(500);

l_alias_sql VARCHAR2(5000) :=
'SELECT hav.attribute1,hav.attribute2
   FROM hxc_alias_definitions had,
        hxc_alias_values hav
  WHERE had.alias_definition_id IN ALIASLIST
    AND hav.alias_definition_id = had.alias_definition_id
    AND hav.attribute_category = ''PAYROLL_ELEMENTS''
    AND hav.attribute2 IS NOT NULL
   ORDER BY hav.alias_definition_id,hav.alias_value_id DESC' ;

 l_ref_cursor      SYS_REFCURSOR;
 l_element_tab     NUMTABLE;
 l_id_tab          NUMTABLE;

BEGIN
     IF g_debug
     THEN
         hr_utility.trace('Getting alt name identifier s');
     END IF;

     hxc_preference_evaluation.resource_preferences(p_person_id,
                                                    p_start_time,
                                                    p_stop_time,
                                                    g_pref_table);

     IF g_pref_table.COUNT > 0
     THEN
         l_ind := g_pref_table.FIRST;
         LOOP
            IF p_mode = 'SS'
            THEN
            IF g_pref_table(l_ind).preference_code = 'TC_W_TCRD_ALIASES'
            THEN
               l_alias_list := '('||g_pref_table(l_ind).attribute1||
                               ','||g_pref_table(l_ind).attribute2||
                               ','||g_pref_table(l_ind).attribute3||
                               ','||g_pref_table(l_ind).attribute4||
                               ','||g_pref_table(l_ind).attribute5||
                               ','||g_pref_table(l_ind).attribute6||
                               ','||g_pref_table(l_ind).attribute7||
                               ','||g_pref_table(l_ind).attribute8||
                               ','||g_pref_table(l_ind).attribute8||
                               ','||g_pref_table(l_ind).attribute10;
               l_alias_list := RTRIM(l_alias_list,',');
               -- Bug 8880941
               -- Added the following statement to replace multiple commas
               -- with a single one.
               l_alias_list := REGEXP_REPLACE(l_alias_list,'(,){2,}',',');
               l_alias_list  := l_alias_list||')';
               EXIT;
             END IF;
            ELSIF p_mode = 'TK'
            THEN
            IF g_pref_table(l_ind).preference_code = 'TK_TCARD_ATTRIBUTES_DEFINITION'
            THEN
               l_alias_list := '('||g_pref_table(l_ind).attribute1||
                               ','||g_pref_table(l_ind).attribute2||
                               ','||g_pref_table(l_ind).attribute3||
                               ','||g_pref_table(l_ind).attribute4||
                               ','||g_pref_table(l_ind).attribute5||
                               ','||g_pref_table(l_ind).attribute6||
                               ','||g_pref_table(l_ind).attribute7||
                               ','||g_pref_table(l_ind).attribute8||
                               ','||g_pref_table(l_ind).attribute8||
                               ','||g_pref_table(l_ind).attribute10;
               l_alias_list := RTRIM(l_alias_list,',');
               -- Bug 8880941
               -- Added the following statement to replace multiple commas
               -- with a single one.
               l_alias_list := REGEXP_REPLACE(l_alias_list,'(,){2,}',',');
               l_alias_list  := l_alias_list||')';
               EXIT;
             END IF;
            END IF;
             l_ind := g_pref_table.NEXT(l_ind);
             EXIT WHEN NOT g_pref_table.EXISTS(l_ind);
          END LOOP;

          IF l_alias_list <> '()'
          THEN
             l_alias_sql := REPLACE(l_alias_sql,'ALIASLIST',l_alias_list);
             IF g_debug
             THEN
                 hr_utility.trace(l_alias_sql);
             END IF;
             OPEN l_ref_cursor FOR l_alias_sql;
             FETCH l_ref_cursor BULK COLLECT INTO l_element_tab,
                                                  l_id_tab;
             CLOSE l_ref_cursor;

             IF l_element_tab.COUNT > 0
             THEN
                FOR i IN l_element_tab.FIRST..l_element_tab.LAST
                LOOP
                   g_alias_tab(l_element_tab(i)) := l_id_tab(i);
                   IF g_debug
                   THEN
                       hr_utility.trace('Element Id is'||g_alias_tab(l_element_tab(i)));
                       hr_utility.trace('Alt Id is '||l_id_tab(i));
                   END IF;
                END LOOP;
             END IF;

          END IF;
     END IF;

     SELECT bld_blk_info_type_id
       INTO g_dummy_bbit
       FROM hxc_bld_blk_info_types
      WHERE bld_blk_info_type = 'Dummy Element Context';

     SELECT bld_blk_info_type_id
       INTO g_alias_bbit
       FROM hxc_bld_blk_info_types
      WHERE bld_blk_info_type = 'ALTERNATE NAME IDENTIFIERS';

     -- Bug 8911152
     -- Added this query to pull up layout attribute's bbit.
     SELECT bld_blk_info_type_id
       INTO g_layout_bbit
       FROM hxc_bld_blk_info_types
      WHERE bld_blk_info_type = 'LAYOUT';


END   gen_alt_ids;


  -- overloaded proc for TK

  PROCEDURE create_tc_with_abs  ( p_person_id          IN            NUMBER,
                                  p_start_date         IN            DATE,
                                  p_end_date           IN            DATE,
                                  p_approval_style_id  IN            NUMBER,
                                  p_lock_rowid         IN            VARCHAR2,
                                  p_source             IN            VARCHAR2,
                                  p_timekeeper_id      IN            NUMBER,
                                  p_iteration_count    IN            NUMBER,
                                  p_block_array        IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                  p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE )
  IS

  l_abs_tab  abs_tab;
  l_block_ind  NUMBER;

  l_current_date  DATE;
  l_day_id   NUMBER;
  l_det_id  NUMBER;
  l_att_id  NUMBER;
  l_att_ind NUMBER;
  l_messages HXC_MESSAGE_TABLE_TYPE;
  l_UOM     VARCHAR2(5);


  l_tbb_id_reference_table hxc_alias_utility.t_tbb_id_reference;

  BEGIN

     g_messages := HXC_MESSAGE_TABLE_TYPE();

     --p_end_date:=trunc(p_end_date); --


     retrieve_absences( p_person_id,
                        p_start_date,
                        p_end_date,
                        l_abs_tab );



     IF l_abs_tab.COUNT > 0
     THEN

        p_block_array := HXC_BLOCK_TABLE_TYPE();
        p_block_array.EXTEND(1);
        l_block_ind := p_block_array.first;
        p_block_array(l_block_ind):=  HXC_BLOCK_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                     NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                     NULL,NULL,NULL,NULL,NULL,NULL,NULL);
        --p_block_array(l_block_ind).TIME_BUILDING_BLOCK_ID    	:= -2; original code
        p_block_array(l_block_ind).TIME_BUILDING_BLOCK_ID    	:= (-3 - (p_iteration_count*30000)); -- SVG added
        p_block_array(l_block_ind).TYPE                      	:= 'RANGE';
        p_block_array(l_block_ind).MEASURE                   	:= NULL;
        p_block_array(l_block_ind).UNIT_OF_MEASURE           	:= 'HOURS';
        p_block_array(l_block_ind).START_TIME                	:= FND_DATE.DATE_TO_CANONICAL(p_start_date);
        p_block_array(l_block_ind).STOP_TIME                 	:= TO_CHAR(p_end_date,'YYYY/MM/DD ')||'23:59:59';
        p_block_array(l_block_ind).PARENT_BUILDING_BLOCK_ID  	:= NULL;
        p_block_array(l_block_ind).PARENT_IS_NEW             	:= NULL;
        p_block_array(l_block_ind).SCOPE                     	:= 'TIMECARD';
        p_block_array(l_block_ind).OBJECT_VERSION_NUMBER     	:= 1;
        p_block_array(l_block_ind).APPROVAL_STATUS           	:= NULL;
        p_block_array(l_block_ind).RESOURCE_ID               	:= p_person_id;
        p_block_array(l_block_ind).RESOURCE_TYPE             	:= 'PERSON';
        p_block_array(l_block_ind).APPROVAL_STYLE_ID         	:= NULL;
        p_block_array(l_block_ind).DATE_FROM                 	:= FND_DATE.DATE_TO_CANONICAL(SYSDATE);
        p_block_array(l_block_ind).DATE_TO                   	 := FND_DATE.DATE_TO_CANONICAL(hr_general.end_of_time);
        p_block_array(l_block_ind).COMMENT_TEXT              	 := NULL;
        p_block_array(l_block_ind).PARENT_BUILDING_BLOCK_OVN 	 := NULL;
        p_block_array(l_block_ind).NEW                       	 := 'Y';
        p_block_array(l_block_ind).CHANGED                   	 := 'Y';
        p_block_array(l_block_ind).PROCESS                   	 := NULL;
        p_block_array(l_block_ind).APPLICATION_SET_ID        	 := NULL;
        p_block_array(l_block_ind).TRANSLATION_DISPLAY_KEY   	 := NULL;

        l_block_ind := l_block_ind + 1;
        -- l_day_id := -2;  original
        l_day_id := (-4 - (p_iteration_count*30000));  -- SVG changed
        l_current_date := TRUNC(p_start_date);
        WHILE l_current_date <= trunc(p_end_date)
        LOOP
           p_block_array.EXTEND(1);
        	 l_day_id := l_day_id -1;
        	 g_day_tab(TO_CHAR(l_current_date,'YYYYMMDD')) := l_day_id;
        	 p_block_array(l_block_ind) := get_day_block(l_current_date,
        	                                             p_person_id,
        	                                             p_approval_style_id,
        	                                             -- -2,  -- Original
        	                                             (-3 - (p_iteration_count*30000)), -- svg changed
        	                                             l_day_id );
        	 l_current_date := l_current_date + 1 ;
        	 l_block_ind := l_block_ind + 1;
        END LOOP;
        l_det_id := l_day_id;
        l_att_id  := -1;
        l_att_ind := 1;
        p_attribute_array := HXC_ATTRIBUTE_TABLE_TYPE();
        l_att_ind := -1;
        FOR i IN l_abs_tab.FIRST..l_abs_tab.LAST
        LOOP
           <<CONTINUE_TO_NEXT>>
           LOOP
              IF NOT l_abs_tab.EXISTS(i)
              THEN
                  EXIT CONTINUE_TO_NEXT;
              END IF;
              l_det_id := l_det_id -1;
        	 l_att_id := l_att_id -1;
        	 p_attribute_array.EXTEND(1);
        	 IF l_att_ind = -1
        	 THEN
                 l_att_ind := p_attribute_array.FIRST;
              END IF;
              p_block_array.EXTEND(1);
              p_block_array(l_block_ind) := get_detail_block(l_abs_tab(i).abs_start,
                                                             l_abs_tab(i).abs_end,
                                                          	l_abs_tab(i).duration,
                                                          	p_person_id,
                                                          	p_approval_style_id,
                                                          	g_day_tab(TO_CHAR(l_abs_tab(i).abs_date,'YYYYMMDD')),
                                                          	l_det_id,
                                                          	1,
                                                          	trunc(hr_general.end_of_time));
              p_attribute_array(l_att_ind) := get_attribute_for_detail(l_det_id,
                                                                       1,
                                                                       l_abs_tab(i).element_type_id,
                                                                       l_abs_tab(i).abs_attendance_id,
                                                                       l_att_id );

              IF g_alias_tab.EXISTS(l_abs_tab(i).element_type_id)
              THEN
                 l_att_ind := l_att_ind + 1;
                 p_attribute_array.EXTEND(1);
                 l_att_id := l_att_id -1 ;
                 p_attribute_array(l_att_ind) := get_alias_for_detail(l_det_id,
                                                                      1,
                                                                       l_abs_tab(i).element_type_id,
                                                                       l_att_id );
              END IF;


              IF l_abs_tab(i).abs_start IS NULL
      	      THEN
      	          l_UOM := 'D';
      	      ELSE
      	         l_uom := 'H';
      	      END IF;
      	      /*
      	      record_carried_over_absences(l_det_id,
      	                                   1,
      	                                   l_abs_tab(i).abs_type_id,
      	                                   l_abs_tab(i).abs_attendance_id,
      	                                   l_abs_tab(i).element_type_id,
      	                                   NVL(l_abs_tab(i).abs_start,l_abs_tab(i).abs_date),
      	                                   NVL(l_abs_tab(i).abs_end,l_abs_tab(i).abs_date),
      	                                   l_uom,
      	                                   l_abs_tab(i).duration,
      	                                   'PREP',
      	                                   p_person_id,
      	                                   p_start_date,
      	                                   p_end_date,
      	                                   p_lock_rowid);
      	          */

              IF l_abs_tab(i).transaction_id IS NULL
	      THEN
	         -- Bug 8995913
	         -- Added confirmed flag in parameters.
	         record_carried_over_absences(l_det_id,
	                                   1,
	                                   l_abs_tab(i).abs_type_id,
	                                   l_abs_tab(i).abs_attendance_id,
	                                   l_abs_tab(i).element_type_id,
	                                   NVL(l_abs_tab(i).abs_start,l_abs_tab(i).abs_date),
	                                   NVL(l_abs_tab(i).abs_end,l_abs_tab(i).abs_date),
	                                   l_uom,
	                                   l_abs_tab(i).duration,
	                                   'PREP',
	                                   p_person_id,
	                                   p_start_date,
	                                   trunc(p_end_date),
	                                   p_lock_rowid,
                                           NULL,
                                           NULL,
                                           l_abs_tab(i).confirmed_flag);
	      ELSE
	         -- Bug 8941273
	         -- Added abs_attendance Id also.
	         -- Bug 8995913
	         -- Added confirmed flag in parameters.
	         record_carried_over_absences(l_det_id,
	                                   1,
	                                   l_abs_tab(i).abs_type_id,
	                                   l_abs_tab(i).abs_attendance_id,
	                                   l_abs_tab(i).element_type_id,
	                                   NVL(l_abs_tab(i).abs_start,l_abs_tab(i).abs_date),
	                                   NVL(l_abs_tab(i).abs_end,l_abs_tab(i).abs_date),
	                                   l_uom,
	                                   l_abs_tab(i).duration,
	                                   'PREP-SS',
	                                   p_person_id,
	                                   p_start_date,
	                                   trunc(p_end_date),
	                                   p_lock_rowid,
	                                   l_abs_tab(i).transaction_id,
	                                   l_abs_tab(i).modetype,
                                     l_abs_tab(i).confirmed_flag );
              END IF;



              l_block_ind := l_block_ind + 1;
              l_att_ind := l_att_ind + 1;
              EXIT CONTINUE_TO_NEXT;
           END LOOP CONTINUE_TO_NEXT;
        END LOOP;


        if p_source = 'TK' then  -- added SVG


              HXC_ALIAS_TRANSLATOR.do_retrieval_translation(  p_attributes  	=> p_attribute_array
  	                  				    ,p_blocks		=> p_block_array
  	                  				    ,p_start_time  	=> p_start_date
  	                  				    ,p_stop_time   	=> p_end_date
  	                  				    ,p_resource_id 	=> p_timekeeper_id
  	                  				    ,p_processing_mode => hxc_alias_utility.c_tk_processing
     						    	    ,p_messages		=> l_messages   );


           else

             HXC_ALIAS_TRANSLATOR.do_retrieval_translation(  p_attributes  	=> p_attribute_array
  	            				           ,p_blocks		=> p_block_array
  	            					   ,p_start_time  	=> p_start_date
  	            					   ,p_stop_time   	=> p_end_date
  	            				           ,p_resource_id 	=> p_person_id
           						  ,p_messages		=> l_messages   );
           end if;

    END IF;


  END create_tc_with_abs;  -- Overloaded proc create_tc_with_abs



PROCEDURE create_tc_with_abs  ( p_person_id          IN            NUMBER,
                                p_start_date         IN            DATE,
                                p_end_date           IN            DATE,
                                p_approval_style_id  IN            NUMBER,
                                p_lock_rowid         IN            VARCHAR2,
                                p_block_array        IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE )
IS

l_abs_tab       ABS_TAB;
l_block_ind     NUMBER;

l_current_date  DATE;
l_day_id        NUMBER;
l_det_id        NUMBER;
l_att_id        NUMBER;
l_att_ind       NUMBER;
l_messages      HXC_MESSAGE_TABLE_TYPE;
l_UOM           VARCHAR2(5);

l_tbb_id_reference_table hxc_alias_utility.t_tbb_id_reference;

i  BINARY_INTEGER;

BEGIN

    g_messages := HXC_MESSAGE_TABLE_TYPE();

    retrieve_absences( p_person_id,
                       p_start_date,
                       p_end_date,
                       l_abs_tab );
    IF g_pending_appr
     AND g_messages.COUNT >0
    THEN
       RETURN;
    END IF;



    IF l_abs_tab.COUNT > 0
    THEN

       p_block_array := HXC_BLOCK_TABLE_TYPE();
       p_block_array.EXTEND(1);
       l_block_ind := p_block_array.first;
       p_block_array(l_block_ind):=  HXC_BLOCK_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                    NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                    NULL,NULL,NULL,NULL,NULL,NULL,NULL);
       p_block_array(l_block_ind).TIME_BUILDING_BLOCK_ID    	:= -2;
       p_block_array(l_block_ind).TYPE                      	:= 'RANGE';
       p_block_array(l_block_ind).MEASURE                   	:= NULL;
       p_block_array(l_block_ind).UNIT_OF_MEASURE           	:= 'HOURS';
       p_block_array(l_block_ind).START_TIME                	:= FND_DATE.DATE_TO_CANONICAL(p_start_date);
       p_block_array(l_block_ind).STOP_TIME                 	:= TO_CHAR(p_end_date,'YYYY/MM/DD ')||'23:59:59';
       p_block_array(l_block_ind).PARENT_BUILDING_BLOCK_ID  	:= NULL;
       p_block_array(l_block_ind).PARENT_IS_NEW             	:= NULL;
       p_block_array(l_block_ind).SCOPE                     	:= 'TIMECARD';
       p_block_array(l_block_ind).OBJECT_VERSION_NUMBER     	:= 1;
       p_block_array(l_block_ind).APPROVAL_STATUS           	:= NULL;
       p_block_array(l_block_ind).RESOURCE_ID               	:= p_person_id;
       p_block_array(l_block_ind).RESOURCE_TYPE             	:= 'PERSON';
       p_block_array(l_block_ind).APPROVAL_STYLE_ID         	:= NULL;
       p_block_array(l_block_ind).DATE_FROM                 	:= FND_DATE.DATE_TO_CANONICAL(SYSDATE);
       p_block_array(l_block_ind).DATE_TO                   	 := FND_DATE.DATE_TO_CANONICAL(hr_general.end_of_time);
       p_block_array(l_block_ind).COMMENT_TEXT              	 := NULL;
       p_block_array(l_block_ind).PARENT_BUILDING_BLOCK_OVN 	 := NULL;
       p_block_array(l_block_ind).NEW                       	 := 'Y';
       p_block_array(l_block_ind).CHANGED                   	 := 'Y';
       p_block_array(l_block_ind).PROCESS                   	 := NULL;
       p_block_array(l_block_ind).APPLICATION_SET_ID        	 := NULL;
       p_block_array(l_block_ind).TRANSLATION_DISPLAY_KEY   	 := NULL;


       -- Bug 8911152
       -- Adding call to create layout attribute.
       p_attribute_array := HXC_ATTRIBUTE_TABLE_TYPE();
       p_attribute_array.EXTEND(1);
       l_att_ind := p_attribute_array.FIRST;
       l_att_id  := -1;

       p_attribute_array(l_att_ind) := get_layout_attribute(-2,
                                                             1,
                                                             l_att_id);

       IF g_debug
       THEN
           hr_utility.trace('ABS: Created timecard and layout attribute ');
       END IF;

       l_block_ind := l_block_ind + 1;
       l_day_id := -2;
       l_current_date := TRUNC(p_start_date);

       WHILE l_current_date <= trunc(p_end_date)
       LOOP
          p_block_array.EXTEND(1);
      	 l_day_id := l_day_id -1;
      	 g_day_tab(TO_CHAR(l_current_date,'YYYYMMDD')) := l_day_id;
      	 p_block_array(l_block_ind) := get_day_block(l_current_date,
      	                                             p_person_id,
      	                                             p_approval_style_id,
      	                                             -2,
      	                                             l_day_id );
      	 l_current_date := l_current_date + 1 ;
      	 l_block_ind := l_block_ind + 1;
       END LOOP;
       l_det_id := l_day_id;
       -- Bug 8911152
       -- No longer need this initialization cos we are creating
       -- the layout attribute above.
       --l_att_id  := -1;
       --l_att_ind := 1;
       --p_attribute_array := HXC_ATTRIBUTE_TABLE_TYPE();
       l_att_ind := l_att_ind +1;
       FOR i IN l_abs_tab.FIRST..l_abs_tab.LAST
       LOOP
           << CONTINUE_TO_NEXT>>
           LOOP
              hr_utility.trace('ABS : i'||i);
              IF NOT l_abs_tab.EXISTS(i)
              THEN
                  EXIT CONTINUE_TO_NEXT;
              END IF;
              l_det_id := l_det_id -1;
      	      l_att_id := l_att_id -1;
      	      p_attribute_array.EXTEND(1);
      	      IF l_att_ind = -1
      	      THEN
                  l_att_ind := p_attribute_array.FIRST;
              END IF;
              p_block_array.EXTEND(1);
              IF g_debug
              THEN
                  hr_utility.trace('ABS: l_abs_tab(i).abs_start'||l_abs_tab(i).abs_start);
                  hr_utility.trace('ABS: l_abs_tab(i).abs_end'||l_abs_tab(i).abs_end);
                  hr_utility.trace('ABS: l_abs_tab(i).duration'||l_abs_tab(i).duration);
                  hr_utility.trace('ABS: g_day_tab(TO_CHAR(l_abs_tab(i).abs_date,YYYYMMDD))'||
                    g_day_tab(TO_CHAR(l_abs_tab(i).abs_date,'YYYYMMDD')));
                  hr_utility.trace('ABS: l_abs_tab(i).abs_start'||l_abs_tab(i).abs_start);
                  hr_utility.trace('ABS: l_abs_tab(i).abs_start'||l_abs_tab(i).abs_start);
              END IF;
              p_block_array(l_block_ind) := get_detail_block(l_abs_tab(i).abs_start,
                                                             l_abs_tab(i).abs_end,
                                                          	 l_abs_tab(i).duration,
                                                          	 p_person_id,
                                                          	 p_approval_style_id,
                                                          	 g_day_tab(TO_CHAR(l_abs_tab(i).abs_date,'YYYYMMDD')),
                                                          	 l_det_id,
                                                          	 1,
                                                          	 TRUNC(hr_general.end_of_time));
              p_attribute_array(l_att_ind) := get_attribute_for_detail(l_det_id,
                                                                       1,
                                                                       l_abs_tab(i).element_type_id,
                                                                       l_abs_tab(i).abs_attendance_id,
                                                                       l_att_id );

              IF g_alias_tab.EXISTS(l_abs_tab(i).element_type_id)
              THEN
                 l_att_ind := l_att_ind + 1;
                 p_attribute_array.EXTEND(1);
                 l_att_id := l_att_id -1 ;
                 p_attribute_array(l_att_ind) := get_alias_for_detail(l_det_id,
                                                                      1,
                                                                       l_abs_tab(i).element_type_id,
                                                                       l_att_id );
              END IF;

              IF l_abs_tab(i).abs_start IS NULL
    	      THEN
    	          l_UOM := 'D';
    	      ELSE
    	         l_uom := 'H';
    	      END IF;
              IF l_abs_tab(i).transaction_id IS NULL
              THEN
                  -- Bug 8995913
                  -- Added confirmed flag in parameters.
                  record_carried_over_absences(l_det_id,
    	                                       1,
    	                                       l_abs_tab(i).abs_type_id,
    	                                       l_abs_tab(i).abs_attendance_id,
    	                                       l_abs_tab(i).element_type_id,
    	                                       NVL(l_abs_tab(i).abs_start,l_abs_tab(i).abs_date),
    	                                       NVL(l_abs_tab(i).abs_end,l_abs_tab(i).abs_date),
    	                                       l_uom,
    	                                       l_abs_tab(i).duration,
    	                                       'PREP',
    	                                       p_person_id,
    	                                       p_start_date,
    	                                       p_end_date,
    	                                       p_lock_rowid,
                                               NULL,
                                               NULL,
                                               l_abs_tab(i).confirmed_flag);
              ELSE
                  -- Bug 8941273
	          -- Added abs_attendance Id also.
	          -- Bug 8995913
	          -- Added confirmed flag in parameters.
                  record_carried_over_absences(l_det_id,
    	                                       1,
    	                                       l_abs_tab(i).abs_type_id,
    	                                       l_abs_tab(i).abs_attendance_id,
    	                                       l_abs_tab(i).element_type_id,
    	                                       NVL(l_abs_tab(i).abs_start,l_abs_tab(i).abs_date),
    	                                       NVL(l_abs_tab(i).abs_end,l_abs_tab(i).abs_date),
    	                                       l_uom,
    	                                       l_abs_tab(i).duration,
    	                                       'PREP-SS',
    	                                       p_person_id,
    	                                       p_start_date,
    	                                       p_end_date,
    	                                       p_lock_rowid,
    	                                       l_abs_tab(i).transaction_id,
    	                                       l_abs_tab(i).modetype ,
                                               l_abs_tab(i).confirmed_flag);
              END IF;
              l_block_ind := l_block_ind + 1;
              l_att_ind := l_att_ind + 1;
              EXIT CONTINUE_TO_NEXT;
          END LOOP CONTINUE_TO_NEXT;
       END LOOP;

      HXC_ALIAS_TRANSLATOR.do_retrieval_translation(  p_attributes  	=> p_attribute_array
   						  ,p_blocks		=> p_block_array
   						  ,p_start_time  	=> p_start_date
   						  ,p_stop_time   	=> p_end_date
   						  ,p_resource_id 	=> p_person_id
   						  ,p_messages		=> l_messages   );

      IF g_debug
      THEN
        i := p_block_array.FIRST;
         LOOP
            hr_utility.trace('p_block_array(i).time_building_block_id '||p_block_array(i).time_building_block_id);
            hr_utility.trace('p_block_array(i).object_version_number '||p_block_array(i).object_version_number);
            hr_utility.trace('p_block_array(i).scope '||p_block_array(i).scope);
            hr_utility.trace('p_block_array(i).start_time '||p_block_array(i).start_time);
            hr_utility.trace('p_block_array(i).stop_time '||p_block_array(i).stop_time);
            hr_utility.trace('p_block_array(i).measure '||p_block_array(i).measure);
            hr_utility.trace('p_block_array(i).date_to '||p_block_array(i).date_to);
            i:= p_block_array.NEXT(i);
            EXIT WHEN NOT p_block_array.EXISTS(i);
         END LOOP;

         i:= p_attribute_array.FIRST;
         LOOP
            hr_utility.trace('p_attribute_array(i).building_block_id '||p_attribute_array(i).building_block_id);
            hr_utility.trace('p_attribute_array(i).building_block_ovn '||p_attribute_array(i).building_block_ovn);
            hr_utility.trace('p_attribute_array(i).attribute_category '||p_attribute_array(i).attribute_category);
            hr_utility.trace('p_attribute_array(i).bld_blk_info_type '||p_attribute_array(i).bld_blk_info_type);
            hr_utility.trace('p_attribute_array(i).attribute1 '||p_attribute_array(i).attribute1);
            hr_utility.trace('p_attribute_array(i).attribute1 '||p_attribute_array(i).attribute2);
            hr_utility.trace('p_attribute_array(i).attribute1 '||p_attribute_array(i).attribute3);
            i:= p_attribute_array.NEXT(i);
            EXIT WHEN NOT p_block_array.EXISTS(i);
         END LOOP;

      END IF;

    END IF;


END create_tc_with_abs ;


FUNCTION get_day_block ( p_date   IN  DATE,
                         p_person_id  IN NUMBER,
                         p_approval_style_id  IN NUMBER,
                         p_timecard_id  IN NUMBER,
                         p_bb_id      IN NUMBER)
RETURN hxc_block_type
IS

l_block_type  HXC_BLOCK_TYPE;

BEGIN

    l_block_type :=  HXC_BLOCK_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                    NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                    NULL,NULL,NULL,NULL,NULL,NULL,NULL);

    l_block_type.TIME_BUILDING_BLOCK_ID    	:= p_bb_id;
    l_block_type.TYPE                      	:= 'RANGE';
    l_block_type.UNIT_OF_MEASURE           	:= 'HOURS';
    l_block_type.START_TIME                	:= FND_DATE.DATE_TO_CANONICAL(p_date);
    l_block_type.STOP_TIME                 	:= TO_CHAR(p_date,'YYYY/MM/DD ')||'23:59:59';
    l_block_type.PARENT_BUILDING_BLOCK_ID  	:= p_timecard_id;
    l_block_type.SCOPE                     	:= 'DAY';
    l_block_type.OBJECT_VERSION_NUMBER     	:= 1;
    l_block_type.RESOURCE_ID               	:= p_person_id;
    l_block_type.RESOURCE_TYPE             	:= 'PERSON';
    l_block_type.APPROVAL_STYLE_ID         	:= p_approval_style_id;
    l_block_type.DATE_FROM                 	:= FND_DATE.DATE_TO_CANONICAL(SYSDATE);
    l_block_type.DATE_TO                   	:= FND_DATE.DATE_TO_CANONICAL(hr_general.end_of_time);
    l_block_type.PARENT_BUILDING_BLOCK_OVN 	:= 1;
    l_block_type.NEW                       	:= 'Y';
    l_block_type.CHANGED                   	:= 'Y';
    l_block_type.PROCESS                   	:= NULL;
    l_block_type.APPLICATION_SET_ID        	:= NULL;
    l_block_type.TRANSLATION_DISPLAY_KEY   	:= NULL;
    l_block_type.MEASURE                   	:= NULL;
    l_block_type.PARENT_IS_NEW             	:= NULL;
    l_block_type.APPROVAL_STATUS           	:= NULL;
    l_block_type.COMMENT_TEXT              	:= NULL;

    RETURN l_block_type;

END get_day_block;

FUNCTION get_detail_block ( p_start_time   IN  DATE,
                            p_stop_time    IN DATE,
                            p_measure      IN NUMBER,
                            p_person_id  IN NUMBER,
                            p_approval_style_id  IN NUMBER,
                            p_day_id     IN NUMBER,
                            p_bb_id      IN NUMBER,
                            p_bb_ovn     IN NUMBER,
                            p_date_to    IN DATE)
RETURN hxc_block_type
IS
l_block_type HXC_BLOCK_TYPE;

BEGIN



    l_block_type :=HXC_BLOCK_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                  NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                  NULL,NULL,NULL,NULL,NULL,NULL,NULL);


    l_block_type.TIME_BUILDING_BLOCK_ID    	:= p_bb_id;
    l_block_type.UNIT_OF_MEASURE           	:= 'HOURS';
    l_block_type.PARENT_BUILDING_BLOCK_ID  	:= p_day_id;
    l_block_type.SCOPE                     	:= 'DETAIL';
    l_block_type.OBJECT_VERSION_NUMBER     	:= p_bb_ovn;
    l_block_type.RESOURCE_ID               	:= p_person_id;
    l_block_type.RESOURCE_TYPE             	:= 'PERSON';
    l_block_type.APPROVAL_STYLE_ID         	:= p_approval_style_id;
    l_block_type.DATE_FROM                 	:= FND_DATE.DATE_TO_CANONICAL(SYSDATE);
    l_block_type.DATE_TO                   	:= FND_DATE.DATE_TO_CANONICAL(p_date_to);
    l_block_type.PARENT_BUILDING_BLOCK_OVN 	:= 1;
    l_block_type.NEW                       	:= 'Y';
    l_block_type.CHANGED                   	:= 'Y';
    l_block_type.PROCESS                   	:= NULL;
    l_block_type.APPLICATION_SET_ID        	:= NULL;
    l_block_type.TRANSLATION_DISPLAY_KEY   	:= NULL;
    l_block_type.PARENT_IS_NEW               	:= NULL;
    l_block_type.APPROVAL_STATUS           	:= NULL;
    l_block_type.COMMENT_TEXT              	:= NULL;

    IF p_start_time IS NOT NULL
    THEN
       l_block_type.TYPE                      	:= 'RANGE';
       l_block_type.MEASURE                   	:= NULL;
       l_block_type.START_TIME                	:= FND_DATE.DATE_TO_CANONICAL(p_start_time);
       l_block_type.STOP_TIME                 	:= FND_DATE.DATE_TO_CANONICAL(p_stop_time);
    ELSE
       l_block_type.TYPE                      	:= 'MEASURE';
       l_block_type.MEASURE                   	:= p_measure;
       l_block_type.START_TIME                	:= NULL;
       l_block_type.STOP_TIME                 	:= NULL;
    END IF;

    RETURN l_block_type;

END get_detail_block;


FUNCTION get_attribute_for_detail ( p_bb_id   IN NUMBER,
                                    p_bb_ovn   IN NUMBER,
                                    p_element_type_id  IN NUMBER,
                                    p_abs_att_id   IN NUMBER,
                                    p_attribute_id  IN NUMBER
                                    )
RETURN hxc_attribute_type
IS
l_attribute_type  HXC_ATTRIBUTE_TYPE;

BEGIN

    l_attribute_type := HXC_ATTRIBUTE_TYPE(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               			       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               			       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


    l_attribute_type.time_attribute_id := p_attribute_id;
    l_attribute_type.attribute_category := 'ELEMENT - '||p_element_type_id;
    l_attribute_type.attribute25 := p_abs_att_id ;
    l_attribute_type.bld_blk_info_type_id := 1;
    l_attribute_type.bld_blk_info_type := 'Dummy Element Context';
    l_attribute_type.BUILDING_BLOCK_ID := p_bb_id;
    l_attribute_type.BUILDING_BLOCK_OVN := p_bb_ovn;
    l_attribute_type.OBJECT_VERSION_NUMBER := 1;

    RETURN l_attribute_type;

END get_attribute_for_detail;




PROCEDURE get_abs_statuses ( p_person_id  IN NUMBER,
                             p_start_date IN DATE,
                             p_end_date   IN DATE,
                             p_abs_status_rec OUT NOCOPY ABS_STATUS_TAB)
IS

    CURSOR get_alias_value ( p_alias_id  IN NUMBER,
                             p_element_id IN NUMBER )
        IS SELECT havtl.name
             FROM per_absence_attendance_types hav,
                  per_abs_attendance_types_tl havtl
            WHERE hav.absence_attendance_type_id = havtl.absence_attendance_type_id
              AND hav.absence_attendance_type_id = p_element_id
              AND language                       = userenv('LANG');

 l_measure             NUMBER;
 l_element   	       NUMBER;
 l_start     	       DATE;
 l_end       	       DATE;

 l_alias_value         VARCHAR2(400);
 l_alias_definition_id NUMBER;

 l_index               BINARY_INTEGER := 0;

 l_abs_status_org_tab  ABS_STATUS_TAB;

 p_abs_tab             abs_tab;
 i_ind                 BINARY_INTEGER:= 0;


l_abs_status_tab  abs_status_tab;

TYPE NUMBERTABLE IS TABLE OF VARCHAR2(5) INDEX BY BINARY_INTEGER;

TYPE hrrec IS RECORD
( id   NUMBER,
  start_date DATE,
  stop_date  DATE
);

TYPE HRTABLE IS TABLE OF HRREC INDEX BY BINARY_INTEGER;
l_sshr_tab HRTABLE;
l_core_tab HRTABLE;

l_trans_tab  NUMBERTABLE;
l_atten_tab  NUMBERTABLE;
i BINARY_INTEGER;
l_temp_id    NUMBER;


BEGIN

     retrieve_absences( p_person_id   ,
                        p_start_date,
                        p_end_date,
                        p_abs_tab     );

     IF p_abs_tab.COUNT >0
     THEN
         i_ind := p_abs_tab.FIRST;
         LOOP
            << CONTINUE_TO_NEXT >>
          	 LOOP
          	    OPEN get_alias_value( l_alias_definition_id,
          	                          p_abs_tab(i_ind).abs_type_id );

          	    FETCH get_alias_value INTO l_alias_value;


          	    CLOSE get_alias_value;

          	    IF p_abs_tab(i_ind).uom = 'H'
          	    THEN

          	       -- Bug 8853984
          	       -- Calcuation of earliest start and latest end for
          	       -- Hour based absences.
          	       IF  l_atten_tab.EXISTS(p_abs_tab(i_ind).abs_attendance_id)
                       THEN
                          -- Get the absence attendance id
                          l_temp_id := p_abs_tab(i_ind).abs_attendance_id;
                          -- Check if the incoming value is lesser than the
                          -- stored value. If yes store it.
                          IF p_abs_tab(i_ind).abs_start < l_core_tab(l_temp_id).start_date
                          THEN
                             l_abs_status_tab(l_core_tab(l_temp_id).id).abs_start
                                         := TO_CHAR(p_abs_tab(i_ind).abs_start,
                                                    FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')||' HH24:MI');
                             l_core_tab(l_temp_id).start_date := p_abs_tab(i_ind).abs_start;
                          END IF;
                          --Check if the incoming value is greater than the
                          -- stored value. If yes, store it.
                          IF p_abs_tab(i_ind).abs_end > l_core_tab(l_temp_id).stop_date
                          THEN
                            l_abs_status_tab(l_core_tab(l_temp_id).id).abs_end
                                          := TO_CHAR(p_abs_tab(i_ind).abs_end,
                                                     FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')||' HH24:MI');
                            l_core_tab(l_temp_id).stop_date := p_abs_tab(i_ind).abs_end;
                          END IF;
                       END IF;

          	       -- Bug 8853984
          	       -- Calcuation of earliest start and latest end for
          	       -- Hour based absences.
          	       IF  l_trans_tab.EXISTS( p_abs_tab(i_ind).transaction_id)
                       THEN
                          l_temp_id := p_abs_tab(i_ind).transaction_id;
                          IF p_abs_tab(i_ind).abs_start < l_sshr_tab(l_temp_id).start_date
                          THEN
                              l_abs_status_tab(l_sshr_tab(l_temp_id).id).abs_start
                                            := TO_CHAR(p_abs_tab(i_ind).abs_start,
                                                       FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')||' HH24:MI');
                              l_sshr_tab(l_temp_id).start_date := p_abs_tab(i_ind).abs_start;
                           END IF;
                           IF p_abs_tab(i_ind).abs_end > l_sshr_tab(l_temp_id).stop_date
                           THEN
                               l_abs_status_tab(l_sshr_tab(l_temp_id).id).abs_end
                                             := TO_CHAR(p_abs_tab(i_ind).abs_end,
                                                        FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')||' HH24:MI');
                               l_sshr_tab(l_temp_id).stop_date := p_abs_tab(i_ind).abs_end;
                            END IF;
                       END IF;


                    END IF;

          	    IF  l_trans_tab.EXISTS( p_abs_tab(i_ind).transaction_id)
          	     OR l_atten_tab.EXISTS(p_abs_tab(i_ind).abs_attendance_id)
          	    THEN
          	        EXIT CONTINUE_TO_NEXT;
          	    END IF;

          	    l_index := l_index + 1;
          	    l_abs_status_tab(l_index).abs_type := l_alias_value;

          	    IF p_abs_tab(i_ind).uom = 'D'
          	    THEN
          	       l_abs_status_tab(l_index).UOM       := get_lookup_value('NAME_TRANSLATIONS','DAYS');
          	       l_abs_status_tab(l_index).abs_start := TO_CHAR(NVL(p_abs_tab(i_ind).rec_start_date,
          	                                                          p_abs_tab(i_ind).abs_date
          	                                                         ),
          	                                                      FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'));
          	       l_abs_status_tab(l_index).abs_end   := TO_CHAR(NVL(p_abs_tab(i_ind).rec_end_date,
          	                                                          p_abs_tab(i_ind).abs_date
          	                                                         ),
          	                                                      FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'));
          	       -- Bug 8859597
     	               -- Removing Duration.
          	       --l_abs_status_tab(l_index).measure   := TO_CHAR(p_abs_tab(i_ind).rec_end_date-p_abs_tab(i_ind).rec_start_date +1);
          	    ELSIF p_abs_tab(i_ind).uom = 'H'
          	    THEN
          	       l_abs_status_tab(l_index).UOM        := get_lookup_value('NAME_TRANSLATIONS','HOURS');

          	       -- Bug 8853984
          	       -- Calculation of start and end changed.
          	       l_abs_status_tab(l_index).abs_start  := TO_CHAR(p_abs_tab(i_ind).abs_start,
          	                                                        FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')||' HH24:MI');
          	       l_abs_status_tab(l_index).abs_end    := TO_CHAR(p_abs_tab(i_ind).abs_end,
          	                                                        FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')||' HH24:MI');

          	       -- Bug 8859597
     	               -- Removing Duration.
          	       /*
          	       IF TRUNC(p_abs_tab(i_ind).rec_start_date) <> TRUNC(p_abs_tab(i_ind).rec_end_date)
                       THEN
                           l_abs_status_tab(l_index).measure    := p_abs_tab(i_ind).duration*
                                (( TRUNC(p_abs_tab(i_ind).rec_end_date) - TRUNC(p_abs_tab(i_ind).rec_start_date))+1) ;
                       ELSE
                           l_abs_status_tab(l_index).measure    := p_abs_tab(i_ind).duration;
                       END IF;
                       */
          	    END IF;

          	    IF p_abs_tab(i_ind).prg_appl_id = 800
          	    THEN
          	        l_abs_status_tab(l_index).source := get_lookup_value('HXC_ABS_PROG_APPLICATIONS','CHR');
          	    ELSE
          	        l_abs_status_tab(l_index).source := get_lookup_value('HXC_ABS_PROG_APPLICATIONS','OTL');
          	    END IF;

          	    IF p_abs_tab(i_ind).abs_attendance_id IS NOT NULL
          	    THEN
          	       l_atten_tab(p_abs_tab(i_ind).abs_attendance_id) := 'Y';
          	       -- Bug 8853984
          	       -- Store the values in the cache table.
                       l_core_tab(p_abs_tab(i_ind).abs_attendance_id).id := l_index;
                       l_core_tab(p_abs_tab(i_ind).abs_attendance_id).start_date := p_abs_tab(i_ind).abs_start;
                       l_core_tab(p_abs_tab(i_ind).abs_attendance_id).stop_date := p_abs_tab(i_ind).abs_end;
          	    END IF;

          	    IF p_abs_tab(i_ind).transaction_id IS NOT NULL
          	    THEN
          	       l_trans_tab(p_abs_tab(i_ind).transaction_id) := 'Y';
          	       l_abs_status_tab(l_index).status := get_lookup_value('LEAVE_STATUS','PA');
          	       -- Bug 8853984
          	       -- Store the values in the cache table.
                       l_sshr_tab(p_abs_tab(i_ind).transaction_id).id := l_index;
                       l_sshr_tab(p_abs_tab(i_ind).transaction_id).start_date := p_abs_tab(i_ind).abs_start;
                       l_sshr_tab(p_abs_tab(i_ind).transaction_id).stop_date := p_abs_tab(i_ind).abs_end;
          	    ELSIF p_abs_tab(i_ind).transaction_id IS NULL
          	    THEN
          	       l_abs_status_tab(l_index).status := get_lookup_value('LEAVE_STATUS','A');
          	    END IF;

          	    EXIT CONTINUE_TO_NEXT;
            END LOOP CONTINUE_TO_NEXT ;
         i_ind := p_abs_tab.NEXT(i_ind);
         EXIT WHEN NOT p_abs_tab.EXISTS(i_ind);

         END LOOP;

     END IF;

     IF g_debug
     THEN
         IF l_abs_status_tab.COUNT >0
     	 THEN
     	     FOR i IN l_abs_status_tab.FIRST..l_abs_status_tab.LAST
     	     LOOP
     	        hr_utility.trace('ABS: l_abs_status_tab(i).abs_type '||l_abs_status_tab(i).abs_type);
     	        hr_utility.trace('ABS: l_abs_status_tab(i).status '||l_abs_status_tab(i).status);
     	        hr_utility.trace('ABS: l_abs_status_tab(i).uom '||l_abs_status_tab(i).uom);
     	        hr_utility.trace('ABS: l_abs_status_tab(i).source '||l_abs_status_tab(i).source);
     	        hr_utility.trace('ABS: l_abs_status_tab(i).abs_start '||l_abs_status_tab(i).abs_start);
     	        hr_utility.trace('ABS: l_abs_status_tab(i).abs_end '||l_abs_status_tab(i).abs_end);
     	        -- Bug 8859597
     	        -- Removing Duration.
     	        --hr_utility.trace('ABS: l_abs_status_tab(i).measure '||l_abs_status_tab(i).measure);
     	     END LOOP;
     	 END IF;
     END IF;
     p_abs_status_rec := l_abs_status_tab;

END get_abs_statuses;




PROCEDURE get_abs_statuses ( p_person_id      IN         NUMBER,
                             p_start_date     IN 	 VARCHAR2,
                             p_end_date       IN 	 VARCHAR2,
                             p_abs_status_tab OUT NOCOPY HXC_ABS_STATUS_TABLE)
IS

l_abs_status_rec  HXC_ABS_STATUS_TYPE;
l_abs_status_tab  ABS_STATUS_TAB;
l_ind             BINARY_INTEGER := 1;

BEGIN

     get_abs_statuses( p_person_id,
                       fnd_date.canonical_to_date(p_start_date), --TO_DATE(p_start_date,'yyyy/mm/dd'),
                       fnd_date.canonical_to_date(p_end_date), --TO_DATE(p_end_date,'yyyy/mm/dd'),
                       l_abs_status_tab);

     p_abs_status_tab := HXC_ABS_STATUS_TABLE();

     IF l_abs_status_tab.COUNT > 0 THEN

       FOR i IN l_abs_status_tab.FIRST..l_abs_status_tab.LAST
       LOOP
          p_abs_status_tab.EXTEND(1);
          -- Bug 8859597
     	  -- Removing Duration.
          p_abs_status_tab(l_ind) := HXC_ABS_STATUS_TYPE(NULL,NULL,NULL,NULL,NULL,NULL);
          p_abs_status_tab(l_ind).abs_type := l_abs_status_tab(i).abs_type;
          p_abs_status_tab(l_ind).abs_start := l_abs_status_tab(i).abs_start;
          p_abs_status_tab(l_ind).abs_end := l_abs_status_tab(i).abs_end;
          -- Bug 8859597
     	  -- Removing Duration.
          --p_abs_status_tab(l_ind).measure := l_abs_status_tab(i).measure;
          p_abs_status_tab(l_ind).status := l_abs_status_tab(i).status;
          p_abs_status_tab(l_ind).UOM := l_abs_status_tab(i).uom;
          p_abs_status_tab(l_ind).source := l_abs_status_tab(i).source;
          l_ind := l_ind + 1;
       END LOOP;

     END IF;

    RETURN;

END get_abs_statuses;


-- SVG added overloaded procedure add_absence_types


PROCEDURE add_absence_types ( p_person_id          IN            NUMBER,
                                p_start_date  	     IN 	   DATE,
                                p_end_date    	     IN 	   DATE,
                                p_approval_style_id  IN            NUMBER,
                                p_lock_rowid         IN            VARCHAR2,
                                p_source             IN            VARCHAR2 ,
                                p_timekeeper_id      IN            NUMBER,
                                p_iteration_count    IN            NUMBER,
                                p_block_array 	     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE )
IS

l_index  BINARY_INTEGER;

BEGIN

     -- Bug 8829088
     -- Added this init so that we avoid the ORA-6531 in case of
     -- absence of setup.

     g_messages := HXC_MESSAGE_TABLE_TYPE();



IF NVL(FND_PROFILE.VALUE('HR_ABS_OTL_INTEGRATION'),'N') = 'N'
THEN
   RETURN;
END IF;

if g_debug then

hr_utility.trace('Entered add_absence_types');
hr_utility.trace('Before clear_prev_sessions');

end if;


/*
delete_other_sessions(p_person_id,
                      p_start_date,
                      p_end_date,
                      p_lock_rowid);
*/
clear_prev_sessions(p_person_id,
                      p_start_date,
                      p_end_date,
                      p_lock_rowid);

if g_debug then

hr_utility.trace('After clear_prev_sessions');

end if;


gen_alt_ids(p_person_id,
            p_start_date,
            p_end_date,
            'TK');

if g_debug then

hr_utility.trace('After gen_alt_ids');

end if;


IF g_pref_table.COUNT >0
THEN
    l_index := g_pref_table.FIRST;
    LOOP
        IF g_pref_table(l_index).preference_code = 'TS_ABS_PREFERENCES'
        THEN
           IF g_pref_table(l_index).attribute1 <> 'Y'
           THEN
               IF g_debug
               THEN
                   hr_utility.trace('ABS : Integration not enabled for this employee ');
               END IF;
               RETURN;
           ELSE
               EXIT;
           END IF;
        END IF;
        l_index := g_pref_table.NEXT(l_index);
        EXIT WHEN NOT g_pref_table.EXISTS(l_index);
     END LOOP;
END IF;



    IF p_block_array.COUNT = 0
    THEN

    if p_source = 'TK' then

           create_tc_with_abs ( p_person_id => p_person_id,
	                        p_start_date => p_start_date,
	                        p_end_date   => p_end_date,
	                        p_block_array => p_block_array,
	                        p_approval_style_id => p_approval_style_id,
	                        p_attribute_array => p_attribute_array,
	                        p_lock_rowid => p_lock_rowid,
	                        p_source => p_source,
                                p_timekeeper_id => p_timekeeper_id,
                                p_iteration_count => p_iteration_count);

     else

       create_tc_with_abs ( p_person_id => p_person_id,
                            p_start_date => p_start_date,
                            p_end_date   => p_end_date,
                            p_block_array => p_block_array,
                            p_approval_style_id => p_approval_style_id,
                            p_attribute_array => p_attribute_array,
                            p_lock_rowid => p_lock_rowid );

      end if;

    ELSE
            add_abs_to_tc ( p_person_id => p_person_id,
                            p_start_date => p_start_date,
                            p_end_date   => p_end_date,
                            p_block_array => p_block_array,
                            p_approval_style_id => p_approval_style_id,
                            p_attribute_array => p_attribute_array,
                            p_lock_rowid => p_lock_rowid );
    END IF;

    RETURN;

END ; --  overloaded proc add_absence_types


-- Change end


PROCEDURE add_absence_types ( p_person_id          IN            NUMBER,
                                p_start_date  	     IN 	   DATE,
                                p_end_date    	     IN 	   DATE,
                                p_approval_style_id  IN            NUMBER,
                                p_lock_rowid         IN            VARCHAR2,
                                p_block_array 	     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE )
IS

l_index  BINARY_INTEGER;

BEGIN

     -- Bug 8829088
     -- Added this init so that we avoid the ORA-6531 in case of
     -- absence of setup.

     g_messages := HXC_MESSAGE_TABLE_TYPE();

     IF NVL(FND_PROFILE.VALUE('HR_ABS_OTL_INTEGRATION'),'N') = 'N'
     THEN
        RETURN;
     END IF;


     delete_other_sessions(p_person_id,
                           p_start_date,
                           p_end_date,
                           p_lock_rowid);

     gen_alt_ids(p_person_id,
                 p_start_date,
                 p_end_date,
                 'SS');


     IF g_pref_table.COUNT >0
     THEN
         l_index := g_pref_table.FIRST;
         LOOP
             IF g_pref_table(l_index).preference_code = 'TS_ABS_PREFERENCES'
             THEN
                IF g_pref_table(l_index).attribute1 <> 'Y'
                THEN
                    IF g_debug
                    THEN
                        hr_utility.trace('ABS : Integration not enabled for this employee ');
                    END IF;
                    RETURN;
                ELSE
                    EXIT;
                END IF;
             END IF;
             l_index := g_pref_table.NEXT(l_index);
             EXIT WHEN NOT g_pref_table.EXISTS(l_index);
          END LOOP;
     END IF;



    IF p_block_array.COUNT = 0
    THEN
       create_tc_with_abs ( p_person_id => p_person_id,
                            p_start_date => p_start_date,
                            p_end_date   => p_end_date,
                            p_block_array => p_block_array,
                            p_approval_style_id => p_approval_style_id,
                            p_attribute_array => p_attribute_array,
                            p_lock_rowid => p_lock_rowid );
    ELSE
            add_abs_to_tc ( p_person_id => p_person_id,
                            p_start_date => p_start_date,
                            p_end_date   => p_end_date,
                            p_block_array => p_block_array,
                            p_approval_style_id => p_approval_style_id,
                            p_attribute_array => p_attribute_array,
                            p_lock_rowid => p_lock_rowid );
    END IF;

    RETURN;

END add_absence_types;




PROCEDURE tc_api_add_absence_types ( p_person_id   IN NUMBER,
                                     p_start_date  IN DATE,
                                     p_end_date    IN DATE,
			             p_blocks            IN OUT NOCOPY  hxc_self_service_time_deposit.timecard_info,
                                     p_app_attributes    IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
															)
IS

l_index  	      BINARY_INTEGER;
l_app_attribute_index BINARY_INTEGER;

l_attribute_array     hxc_attribute_table_type;
l_block_array	      hxc_block_table_type;

l_approval_style_id   hxc_time_building_blocks.approval_style_id%type;
l_lock_rowid          VARCHAR2(100) := '0';
l_timecard_exists     varchar2(1)   := 'N';

BEGIN

  l_attribute_array := hxc_attribute_table_type ();
  l_block_array			:= hxc_block_table_type();

  BEGIN

    SELECT 'Y'
    INTO  l_timecard_exists
    FROM  hxc_timecard_summary
    WHERE resource_id = p_person_id
    AND   trunc(start_time) = trunc(p_start_date)
    AND   trunc(stop_time)  = trunc(p_end_date);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_timecard_exists := 'N';
  END;


  IF l_timecard_exists = 'Y' THEN
    RETURN; -- DO NOTHING
  ELSE
    delete_other_sessions(p_person_id,
                          p_start_date,
                          p_end_date,
                          l_lock_rowid);

    -- convert the app_attributes_info into hxc_attribute_table_type
    hxc_timestore_deposit_util.convert_app_attributes_to_type (p_attributes          => l_attribute_array,
                                    			       p_app_attributes      => p_app_attributes
                                   			      );
    -- conver the timecard_block_info into hxc_block_table_type
    l_block_array := hxc_timestore_deposit_util.convert_tbb_to_type(p_blocks);

    l_index := l_block_array.first;
        LOOP
      EXIT WHEN NOT l_block_array.exists(l_index);
	IF l_block_array(l_index).scope = 'TIMECARD' THEN
	  l_approval_style_id := l_block_array(l_index).approval_style_id;
	  EXIT;
	END IF;
    l_index := l_block_array.next(l_index);
        END LOOP;

    IF l_block_array.COUNT = 0
    THEN
       create_tc_with_abs ( p_person_id 	=> p_person_id,
                            p_start_date 	=> p_start_date,
                            p_end_date   	=> p_end_date,
                            p_block_array 	=> l_block_array,
			    p_approval_style_id => l_approval_style_id,
			    p_attribute_array 	=> l_attribute_array,
			    p_lock_rowid 	=> l_lock_rowid
			  );
    ELSE
        add_abs_to_tc ( p_person_id 		=> p_person_id,
                        p_start_date 		=> p_start_date,
                        p_end_date   		=> p_end_date,
                        p_block_array 		=> l_block_array,
			p_approval_style_id     => l_approval_style_id,
			p_attribute_array 	=> l_attribute_array,
			p_lock_rowid 		=> l_lock_rowid
		      );
    END IF;

     l_index := l_attribute_array.first;
        LOOP
      EXIT WHEN NOT l_attribute_array.exists(l_index);

  	IF l_attribute_array(l_index).ATTRIBUTE_CATEGORY like 'ELEMENT%' THEN

  	  l_app_attribute_index := NVL (p_app_attributes.LAST, 0) + 1;

  	  p_app_attributes(l_app_attribute_index).time_attribute_id     :=  l_attribute_array(l_index).TIME_ATTRIBUTE_ID;
          p_app_attributes(l_app_attribute_index).building_block_id 	:=  l_attribute_array(l_index).BUILDING_BLOCK_ID;
          p_app_attributes(l_app_attribute_index).attribute_name    	:=  'Dummy Element Context';
          p_app_attributes(l_app_attribute_index).attribute_value   	:=  l_attribute_array(l_index).ATTRIBUTE_CATEGORY;
          p_app_attributes(l_app_attribute_index).segment       	:=  'ATTRIBUTE_CATEGORY';
          p_app_attributes(l_app_attribute_index).bld_blk_info_type 	:=  'Dummy Element Context';
          p_app_attributes(l_app_attribute_index).CATEGORY              :=  'Dummy Element Context';
          p_app_attributes(l_app_attribute_index).updated               :=  l_attribute_array(l_index).CHANGED;
          p_app_attributes(l_app_attribute_index).changed           	:=  l_attribute_array(l_index).CHANGED;
          p_app_attributes(l_app_attribute_index).process               :=  l_attribute_array(l_index).PROCESS;

  		  END IF;

     l_index := l_attribute_array.next(l_index);
          END LOOP;

  	 p_blocks.delete;

     l_index := l_block_array.first;
        LOOP
      EXIT WHEN NOT l_block_array.exists(l_index);
  	p_blocks(l_index).TIME_BUILDING_BLOCK_ID     := l_block_array(l_index).TIME_BUILDING_BLOCK_ID;
  	p_blocks(l_index).TYPE                       := l_block_array(l_index).TYPE;
        p_blocks(l_index).measure                    := l_block_array(l_index).measure;
        p_blocks(l_index).unit_of_measure            := l_block_array(l_index).unit_of_measure;
        p_blocks(l_index).start_time                 := fnd_date.canonical_to_date(l_block_array(l_index).start_time);
        p_blocks(l_index).stop_time                  := fnd_date.canonical_to_date(l_block_array(l_index).stop_time);
        p_blocks(l_index).parent_building_block_id   := l_block_array(l_index).parent_building_block_id;
        p_blocks(l_index).parent_is_new              := l_block_array(l_index).parent_is_new;
        p_blocks(l_index).SCOPE                      := l_block_array(l_index).SCOPE;
        p_blocks(l_index).object_version_number      := l_block_array(l_index).object_version_number;
        p_blocks(l_index).approval_status            := l_block_array(l_index).approval_status;
        p_blocks(l_index).resource_id                := l_block_array(l_index).resource_id;
        p_blocks(l_index).resource_type              := l_block_array(l_index).resource_type;
        p_blocks(l_index).approval_style_id          := l_block_array(l_index).approval_style_id;
        p_blocks(l_index).date_from                  := fnd_date.canonical_to_date(l_block_array(l_index).date_from);
        p_blocks(l_index).date_to                    := fnd_date.canonical_to_date(l_block_array(l_index).date_to);
        p_blocks(l_index).comment_text               := l_block_array(l_index).comment_text;
        p_blocks(l_index).parent_building_block_ovn  := l_block_array(l_index).parent_building_block_ovn;
        p_blocks(l_index).NEW                        := l_block_array(l_index).NEW;
        p_blocks(l_index).changed                    := l_block_array(l_index).changed;
        p_blocks(l_index).process                    := l_block_array(l_index).process;
        p_blocks(l_index).application_set_id         := l_block_array(l_index).application_set_id;
        p_blocks(l_index).translation_display_key    := l_block_array(l_index).translation_display_key;

     l_index := l_block_array.next(l_index);
        END LOOP;

  END IF; --IF l_timecard_exists = 'Y' THEN

END tc_api_add_absence_types;

PROCEDURE tc_api_add_absence_types ( p_blocks           IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
				     p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
				   )

IS

l_index  		      BINARY_INTEGER;
l_app_attribute_index 	      BINARY_INTEGER;
l_attribute_array             hxc_attribute_table_type;
l_block_array		      hxc_block_table_type;

l_person_id		      hxc_time_building_blocks.resource_id%type;
l_approval_style_id           hxc_time_building_blocks.approval_style_id%type;

l_start_date DATE;
l_end_date   DATE;

l_lock_rowid  VARCHAR2(100)   := '0';
l_timecard_exists varchar2(1) := 'N';

BEGIN

  l_attribute_array := hxc_attribute_table_type ();
  l_block_array	    := hxc_block_table_type();

  -- get person id, timecard start time and timecard stop time
  l_index := p_blocks.first;
      LOOP
    EXIT WHEN NOT p_blocks.exists(l_index);
      IF p_blocks(l_index).scope = 'TIMECARD' THEN
	l_approval_style_id := p_blocks(l_index).approval_style_id;
	l_person_id         := p_blocks(l_index).resource_id;
	l_start_date	    := rtrim(p_blocks(l_index).start_time);
	l_end_date	    := rtrim(p_blocks(l_index).stop_time);
	EXIT;
      END IF;
  l_index := p_blocks.next(l_index);
      END LOOP;

  BEGIN

    SELECT 'Y'
    INTO  l_timecard_exists
    FROM  hxc_timecard_summary
    WHERE resource_id = l_person_id
    AND   trunc(start_time) = trunc(l_start_date)
    AND   trunc(stop_time)  = trunc(l_end_date);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_timecard_exists := 'N';
  END;

  IF l_timecard_exists = 'Y' THEN
    RETURN; -- DO NOTHING
  ELSE

    delete_other_sessions(l_person_id,
                          l_start_date,
                          l_end_date,
                          l_lock_rowid);

    -- convert the app_attributes_info into hxc_attribute_table_type
    hxc_timestore_deposit_util.convert_app_attributes_to_type
                                   (p_attributes          => l_attribute_array,
                                    p_app_attributes      => p_app_attributes
                                   );
    -- conver the timecard_block_info into hxc_block_table_type
    l_block_array := hxc_timestore_deposit_util.convert_tbb_to_type(p_blocks);

    IF l_block_array.COUNT = 0
    THEN
       create_tc_with_abs ( p_person_id => l_person_id,
                            p_start_date => l_start_date,
                            p_end_date   => l_end_date,
                            p_block_array => l_block_array,
			    p_approval_style_id => l_approval_style_id,
			    p_attribute_array => l_attribute_array,
		            p_lock_rowid => l_lock_rowid
			  );
    ELSE
        add_abs_to_tc ( p_person_id => l_person_id,
                        p_start_date => l_start_date,
                        p_end_date   => l_end_date,
                        p_block_array => l_block_array,
                        p_approval_style_id => l_approval_style_id,
			p_attribute_array => l_attribute_array,
			p_lock_rowid => l_lock_rowid
		      );
    END IF;

    l_index := l_attribute_array.first;
        LOOP
      EXIT WHEN NOT l_attribute_array.exists(l_index);

        IF l_attribute_array(l_index).ATTRIBUTE_CATEGORY like 'ELEMENT%' THEN

	  l_app_attribute_index := NVL (p_app_attributes.LAST, 0) + 1;

	  p_app_attributes(l_app_attribute_index).time_attribute_id     :=  l_attribute_array(l_index).TIME_ATTRIBUTE_ID;
          p_app_attributes(l_app_attribute_index).building_block_id 	:=  l_attribute_array(l_index).BUILDING_BLOCK_ID;
          p_app_attributes(l_app_attribute_index).attribute_name    	:=  'Dummy Element Context';
          p_app_attributes(l_app_attribute_index).attribute_value   	:=  l_attribute_array(l_index).ATTRIBUTE_CATEGORY;
          p_app_attributes(l_app_attribute_index).segment       	:=  'ATTRIBUTE_CATEGORY';
          p_app_attributes(l_app_attribute_index).bld_blk_info_type 	:=  'Dummy Element Context';
          p_app_attributes(l_app_attribute_index).CATEGORY              :=  'Dummy Element Context';
          p_app_attributes(l_app_attribute_index).updated               :=  l_attribute_array(l_index).CHANGED;
          p_app_attributes(l_app_attribute_index).changed           	:=  l_attribute_array(l_index).CHANGED;
          p_app_attributes(l_app_attribute_index).process               :=  l_attribute_array(l_index).PROCESS;

        END IF;

    l_index := l_attribute_array.next(l_index);
        END LOOP;

    p_blocks.delete;

    l_index := l_block_array.first;
        LOOP
      EXIT WHEN NOT l_block_array.exists(l_index);
  	p_blocks(l_index).TIME_BUILDING_BLOCK_ID     := l_block_array(l_index).TIME_BUILDING_BLOCK_ID;
  	p_blocks(l_index).TYPE                       := l_block_array(l_index).TYPE;
        p_blocks(l_index).measure                    := l_block_array(l_index).measure;
        p_blocks(l_index).unit_of_measure            := l_block_array(l_index).unit_of_measure;
        p_blocks(l_index).start_time                 := fnd_date.canonical_to_date(l_block_array(l_index).start_time);
        p_blocks(l_index).stop_time                  := fnd_date.canonical_to_date(l_block_array(l_index).stop_time);
        p_blocks(l_index).parent_building_block_id   := l_block_array(l_index).parent_building_block_id;
        p_blocks(l_index).parent_is_new              := l_block_array(l_index).parent_is_new;
        p_blocks(l_index).SCOPE                      := l_block_array(l_index).SCOPE;
        p_blocks(l_index).object_version_number      := l_block_array(l_index).object_version_number;
        p_blocks(l_index).approval_status            := l_block_array(l_index).approval_status;
        p_blocks(l_index).resource_id                := l_block_array(l_index).resource_id;
        p_blocks(l_index).resource_type              := l_block_array(l_index).resource_type;
        p_blocks(l_index).approval_style_id          := l_block_array(l_index).approval_style_id;
        p_blocks(l_index).date_from                  := fnd_date.canonical_to_date(l_block_array(l_index).date_from);
        p_blocks(l_index).date_to                    := fnd_date.canonical_to_date(l_block_array(l_index).date_to);
        p_blocks(l_index).comment_text               := l_block_array(l_index).comment_text;
        p_blocks(l_index).parent_building_block_ovn  := l_block_array(l_index).parent_building_block_ovn;
        p_blocks(l_index).NEW                        := l_block_array(l_index).NEW;
        p_blocks(l_index).changed                    := l_block_array(l_index).changed;
        p_blocks(l_index).process                    := l_block_array(l_index).process;
        p_blocks(l_index).application_set_id         := l_block_array(l_index).application_set_id;
        p_blocks(l_index).translation_display_key    := l_block_array(l_index).translation_display_key;

    l_index := l_block_array.next(l_index);
        END LOOP;

  END IF; --IF l_timecard_exists = 'Y' THEN

END tc_api_add_absence_types;


  PROCEDURE add_abs_to_tc    (  p_person_id          IN     NUMBER,
                                p_start_date  	     IN     DATE,
                                p_end_date    	     IN     DATE,
                                p_approval_style_id  IN     NUMBER,
                                p_block_array 	     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
                                p_attribute_array    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE ,
                                p_lock_rowid         IN VARCHAR2 )
IS

l_index  BINARY_INTEGER;
l_block_ind BINARY_INTEGER;
l_att_ind   BINARY_INTEGER;

l_messages HXC_MESSAGE_TABLE_TYPE;

l_timecard_id   NUMBER := 0;
l_timecard_ovn  NUMBER := 0;

l_day_id_tab    NUMTAB;
l_day_ovn_tab   NUMTAB;

offset          NUMBER;
IS_NEG          BOOLEAN := NULL;
TC_FOUND        BOOLEAN ;

INCONSISTENT_IDS  EXCEPTION;
NO_DAY_FOUND      EXCEPTION;
NO_TIMECARD_FOUND EXCEPTION;

l_abs_tab      ABS_TAB;

l_det_id         NUMBER := 0;
l_att_id         NUMBER := 0;

l_UOM     VARCHAR2(5);

BEGIN

    l_index := p_block_array.FIRST;
    LOOP
       <<TO_CONTINUE_TO_NEXT_BLOCK>>
       LOOP
          IF ABS(p_block_array(l_index).time_building_block_id) > l_det_id
          THEN
             l_det_id := ABS(p_block_array(l_index).time_building_block_id);
          END IF;
          IF p_block_array(l_index).time_building_block_id < 0
          THEN
             IF IS_NEG IS NULL
             THEN
                IS_NEG := TRUE;
                offset := -1;
             ELSIF NOT IS_NEG
             THEN
                RAISE INCONSISTENT_IDS;
             END IF;
          ELSE
             IF IS_NEG IS NULL
             THEN
                IS_NEG := FALSE;
                offset := 1;
             ELSIF IS_NEG
             THEN
                RAISE INCONSISTENT_IDS;
             END IF;
          END IF;

          IF p_block_array(l_index).SCOPE = 'TIMECARD'
          THEN
             TC_FOUND := TRUE;
             EXIT TO_CONTINUE_TO_NEXT_BLOCK;
          END IF;

          IF p_block_array(l_index).SCOPE = 'DAY'
          THEN
             l_day_id_tab(p_block_array(l_index).start_time) := p_block_array(l_index).time_building_block_id;
             l_day_ovn_tab(p_block_array(l_index).start_time) := p_block_array(l_index).object_version_number;
             EXIT TO_CONTINUE_TO_NEXT_BLOCK;
          END IF;
          EXIT TO_CONTINUE_TO_NEXT_BLOCK;
       END LOOP TO_CONTINUE_TO_NEXT_BLOCK;
       l_index := p_block_array.NEXT(l_index);
       EXIT WHEN NOT p_block_array.EXISTS(l_index);
    END LOOP;

    IF l_day_id_tab.COUNT <> (TRUNC(p_end_date) - TRUNC(p_start_date))+1
      OR l_day_ovn_tab.COUNT <> (TRUNC(p_end_date) - TRUNC(p_start_date))+1
    THEN
       RAISE NO_DAY_FOUND;
    END IF;

    IF NOT TC_FOUND
    THEN
       RAISE NO_TIMECARD_FOUND;
    END IF;

    IF p_attribute_array.COUNT > 0
    THEN
    l_index := p_attribute_array.FIRST;
    LOOP
       IF ABS(p_attribute_array(l_index).time_attribute_id) > l_att_id
       THEN
          l_att_id := p_attribute_array(l_index).time_attribute_id;
       END IF;
       l_index := p_attribute_array.NEXT(l_index);
       EXIT WHEN NOT p_attribute_array.EXISTS(l_index);
    END LOOP;
    ELSE
       l_att_id := 0;
    END IF;


    g_messages := HXC_MESSAGE_TABLE_TYPE();

    retrieve_absences( p_person_id,
                       p_start_date,
                       p_end_date,
                       l_abs_tab );

    -- Bug 8854684
    -- Added this construct to NULL out blocks and attribute table
    -- and return if there was an error in processing abs.
    IF g_pending_appr
     AND g_messages.COUNT >0
    THEN
       p_block_array := HXC_BLOCK_TABLE_TYPE();
       p_attribute_array := HXC_ATTRIBUTE_TABLE_TYPE();
       RETURN;
    END IF;


    l_att_id := l_att_id * offset + offset;
    l_det_id := l_det_id * offset + offset;


    IF l_abs_tab.COUNT > 0
    THEN
       FOR l_index IN l_abs_tab.FIRST..l_abs_tab.LAST
       LOOP
          << CONTINUE_TO_NEXT>>
          LOOP
             IF NOT l_abs_tab.EXISTS(l_index)
             THEN
                EXIT CONTINUE_TO_NEXT;
             END IF;
             p_attribute_array.EXTEND(1);
             p_block_array.EXTEND(1);
             l_block_ind := p_block_array.LAST;
             l_att_ind   := p_attribute_array.LAST;
             p_block_array(l_block_ind) := get_detail_block(l_abs_tab(l_index).abs_start,
                                                                l_abs_tab(l_index).abs_end,
                                                             	l_abs_tab(l_index).duration,
                                                             	p_person_id,
                                                             	p_approval_style_id,
                                                             	l_day_id_tab(FND_DATE.DATE_TO_CANONICAL(l_abs_tab(l_index).abs_date)),
                                                             	l_det_id,
                                                             	1,
                                                             	TRUNC(hr_general.end_of_time));
             p_attribute_array(l_att_ind) := get_attribute_for_detail(l_det_id,
                                                                          1,
                                                                          l_abs_tab(l_index).element_type_id,
                                                                          l_abs_tab(l_index).abs_attendance_id,
                                                                          l_att_id );

             IF l_abs_tab(l_index).abs_start IS NULL
             THEN
                 l_UOM := 'D';
             ELSE
                l_uom := 'H';
             END IF;

             -- Bug 8854684
             -- Corrected this call to record_co_absences.
             IF l_abs_tab(l_index).transaction_id IS NULL
             THEN
                 -- Bug 8995913
                 -- Added confirmed flag in parameters.
                 record_carried_over_absences(l_det_id,
    	                                      1,
    	                                      l_abs_tab(l_index).abs_type_id,
    	                                      l_abs_tab(l_index).abs_attendance_id,
    	                                      l_abs_tab(l_index).element_type_id,
    	                                      NVL(l_abs_tab(l_index).abs_start,l_abs_tab(l_index).abs_date),
    	                                      NVL(l_abs_tab(l_index).abs_end,l_abs_tab(l_index).abs_date),
    	                                      l_uom,
    	                                      l_abs_tab(l_index).duration,
    	                                      'PREP',
    	                                      p_person_id,
    	                                      p_start_date,
    	                                      p_end_date,
    	                                      p_lock_rowid,
                                              NULL,
                                              NULL,
                                              l_abs_tab(l_index).confirmed_flag );
             ELSE
                 -- Bug 8941273
	         -- Added abs_attendance Id also.
	         -- Bug 8995913
	         -- Added confirmed flag in parameters.
                 record_carried_over_absences(l_det_id,
    	                                      1,
    	                                      l_abs_tab(l_index).abs_type_id,
    	                                      l_abs_tab(l_index).abs_attendance_id,
    	                                      l_abs_tab(l_index).element_type_id,
    	                                      NVL(l_abs_tab(l_index).abs_start,l_abs_tab(l_index).abs_date),
    	                                      NVL(l_abs_tab(l_index).abs_end,l_abs_tab(l_index).abs_date),
    	                                      l_uom,
    	                                      l_abs_tab(l_index).duration,
    	                                      'PREP-SS',
    	                                      p_person_id,
    	                                      p_start_date,
    	                                      p_end_date,
    	                                      p_lock_rowid,
    	                                      l_abs_tab(l_index).transaction_id,
    	                                      l_abs_tab(l_index).modetype,
                                              l_abs_tab(l_index).confirmed_flag );
             END IF;

             l_block_ind := l_block_ind + 1;
             l_att_ind := l_att_ind + 1;
             l_att_id := l_att_id + offset;
             l_det_id := l_det_id + offset;

	     EXIT CONTINUE_TO_NEXT;
	  END LOOP CONTINUE_TO_NEXT;
       END LOOP;

       HXC_ALIAS_TRANSLATOR.do_retrieval_translation(  p_attributes  	=> p_attribute_array
    						  ,p_blocks		=> p_block_array
    						  ,p_start_time  	=> p_start_date
    						  ,p_stop_time   	=> p_end_date
    						  ,p_resource_id 	=> p_person_id
    						  ,p_messages		=> l_messages   );
    END IF;

END add_abs_to_tc;


-- Bug 8995913
-- Added confirmed flag as p_conf

PROCEDURE record_carried_over_absences( p_bb_id   IN NUMBER,
                                        p_bb_ovn  IN NUMBER,
                                        p_abs_id  IN NUMBER,
                                        p_abs_att_id IN NUMBER,
                                        p_element  IN NUMBER,
                                        p_start_date IN DATE,
                                        p_end_date   IN DATE,
                                        p_uom      IN VARCHAR2,
                                        p_measure  IN NUMBER,
                                        p_stage    IN VARCHAR2,
                                        p_resource_id IN NUMBER,
                                        p_tc_start IN DATE,
                                        p_tc_stop IN DATE,
                                        p_lock_rowid  IN VARCHAR2,
                                        p_transaction_id IN NUMBER DEFAULT NULL,
                                        p_action         IN VARCHAR2 DEFAULT NULL,
                                        p_conf           IN VARCHAR2 DEFAULT 'Y' )
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN


   INSERT INTO hxc_abs_co_details
              ( time_building_block_id   ,
                object_version_number  ,
                absence_type_id        ,
                absence_attendance_id  ,
  		element_type_id        ,
  		uom                    ,
  		measure                ,
  		start_date             ,
  		end_date               ,
  		stage                  ,
  		sessionid              ,
  		co_date                ,
  		lock_rowid ,
  		resource_id,
                start_time,
		stop_time,
		transaction_id,
		action,
    confirmed_flag )
       VALUES ( p_bb_id    ,
                p_bb_ovn   ,
                p_abs_id   ,
		p_abs_att_id  ,
		p_element   ,
		p_uom       ,
		p_measure   ,
		p_start_date  ,
		p_end_date    ,
		p_stage ,
		USERENV('SESSIONID'),
		SYSDATE,
		p_lock_rowid,
		p_resource_id,
		p_tc_start,
		p_tc_stop,
		p_transaction_id,
		p_action,
                p_conf );

   COMMIT;

END record_carried_over_absences;



PROCEDURE update_co_absences(p_old_bb_id  IN NUMBER,
                             p_new_bb_id  IN NUMBER,
                             p_start_time IN DATE,
                             p_stop_time  IN DATE,
                             p_element_id IN NUMBER)
IS

l_rowid          VARCHAR2(50);
l_start   	 NUMBER;
l_stop    	 NUMBER;
l_element 	 NUMBER;
l_transaction_id NUMBER;

BEGIN

     IF g_debug
     THEN
         hr_utility.trace('g_lock_rowid '||g_lock_row_id);
	 hr_utility.trace('g_person_id '||g_person_id);
	 hr_utility.trace('g_start_time '||g_start_time);
	 hr_utility.trace('g_stop_time '||g_stop_time);
	 hr_utility.trace('p_old_bb_id '||p_old_bb_id);
     END IF;

     -- Bug 8859290
     -- Removed lock_rowid condition.

     SELECT ROWIDTOCHAR(ROWID),
            TO_CHAR(start_date,'hh24miss'),
            TO_CHAR(end_date,'hh24miss'),
            element_type_id,
            transaction_id
       INTO l_rowid,
            l_start,
            l_stop,
            l_element,
            l_transaction_id
       FROM hxc_abs_co_details
      WHERE time_building_block_id = p_old_bb_id
        AND resource_id            = g_person_id
        AND start_time             = g_start_time
        AND stage                  IN ('PREP','DEP','PREP-SS')
        AND TRUNC(stop_time)       = TRUNC(g_stop_time);

      UPDATE hxc_abs_co_details
         SET time_building_block_id = p_new_bb_id,
             stage = 'DEP'
       WHERE ROWID = CHARTOROWID(l_rowid);

      -- Bug 8859290
      -- Put correct date format parameter below.
      IF l_start <> 0
       OR l_stop <> 0
      THEN
         IF l_start <> TO_CHAR(p_start_time,'hh24miss')
          OR l_stop <> TO_CHAR(p_stop_time,'hh24miss')
         THEN
            IF g_debug
            THEN
               hr_utility.trace('ABS : l_start '||l_start);
               hr_utility.trace('ABS : l_stop '||l_stop);
            END IF;
            RETURN;
         END IF;
      END IF;

      IF l_element <> p_element_id
      THEN
          RETURN;
      END IF;

      IF l_transaction_id IS NOT NULL
      THEN
          RETURN;
      END IF;

      g_detail_trans_tab(p_new_bb_id) := 1;

   EXCEPTION
      WHEN NO_DATA_FOUND
       THEN  NULL;

END update_co_absences;


PROCEDURE update_co_absences_ovn(p_old_bb_id  IN hxc_time_building_blocks.time_building_block_id%type,
                                 p_new_ovn    IN NUMBER,
                                 p_start_time IN DATE,
                                 p_stop_time  IN DATE,
                                 p_element_id IN NUMBER )
IS

l_rowid   VARCHAR2(50);
l_start   NUMBER;
l_stop    NUMBER;
l_element NUMBER;
l_action  VARCHAR2(50);


BEGIN

     IF g_debug
     THEN
         hr_utility.trace('g_lock_rowid '||g_lock_row_id);
	 hr_utility.trace('g_person_id '||g_person_id);
	 hr_utility.trace('g_start_time '||g_start_time);
	 hr_utility.trace('g_stop_time '||g_stop_time);
	 hr_utility.trace('p_old_bb_id '||p_old_bb_id);
     END IF;

     SELECT ROWIDTOCHAR(ROWID),
            TO_CHAR(start_date,'hh24miss'),
            TO_CHAR(end_date,'hh24miss'),
            element_type_id,
            action
       INTO l_rowid,
            l_start,
            l_stop,
            l_element,
            l_action
       FROM hxc_abs_co_details
      WHERE time_building_block_id = p_old_bb_id
        AND stage IN ('PREP','DEP');


      UPDATE hxc_abs_co_details
         SET object_version_number = p_new_ovn,
             stage = 'DEP'
       WHERE ROWID = chartorowid(l_rowid);

      IF l_start <> 0
       OR l_stop <> 0
      THEN
         IF l_start <> TO_CHAR(p_start_time,'hh24miss')
          OR l_stop <> TO_CHAR(p_stop_time,'hh24miss')
         THEN
            RETURN;
         END IF;
      END IF;

      IF l_element <> p_element_id
      THEN
          RETURN;
      END IF;

      IF l_action IS NOT NULL
      THEN
         RETURN;
      END IF;

      g_detail_trans_tab(p_old_bb_id) := p_new_ovn;

   EXCEPTION
      WHEN NO_DATA_FOUND
       THEN  NULL;

END update_co_absences_ovn;


PROCEDURE delete_other_sessions ( p_resource_id  IN NUMBER,
                                  p_start_time   IN DATE,
                                  p_stop_time    IN DATE,
                                  p_lock_rowid   IN VARCHAR2)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    /*

    DELETE FROM hxc_abs_co_details
          WHERE resource_id = p_resource_id
            AND stage IN ( 'PREP','PREP-SS');
    */

    DELETE FROM hxc_abs_co_details
          WHERE resource_id = p_resource_id
            AND start_time = p_start_time
            AND TRUNC(stop_time) = TRUNC(p_stop_time);



  COMMIT;

END delete_other_sessions ;


PROCEDURE insert_audit_header  ( p_resource_id  IN NUMBER,
                                 p_start_time   IN DATE,
                                 p_stop_time    IN DATE,
                                 p_transaction_id IN OUT NOCOPY NUMBER)
IS

l_transaction_id        NUMBER;
l_retrieval_process_id  NUMBER;

CURSOR c_transaction_sequence
    IS SELECT hxc_transactions_s.NEXTVAL
         FROM DUAL;

BEGIN

     SELECT RETRIEVAL_PROCESS_ID
       INTO l_RETRIEVAL_PROCESS_ID
       FROM hxc_retrieval_processes
      WHERE name = 'BEE Retrieval Process';

      OPEN c_transaction_sequence;
     FETCH c_transaction_sequence INTO l_transaction_id;
     CLOSE c_transaction_sequence;


     INSERT INTO hxc_transactions
       (transaction_id
       ,transaction_date
       ,type
       ,transaction_process_id
       ,created_by
       ,creation_date
       ,last_updated_by
       ,last_update_date
       ,last_update_login
       ,status
       ,exception_description
     ) VALUES
       (l_transaction_id
       ,SYSDATE
       ,'RETRIEVAL'
       ,l_RETRIEVAL_PROCESS_ID
       ,NULL
       ,SYSDATE
       ,NULL
       ,SYSDATE
       ,NULL
       ,'SUCCESS'
       ,'This prepopulated transaction is already present in HR'
     );

     p_transaction_id := l_transaction_id;


END insert_audit_header;




PROCEDURE insert_audit_details  ( p_resource_id  IN NUMBER,
                                  p_detail_bb_id  IN NUMBER,
                                  p_detail_ovn    IN NUMBER,
                                  p_header_id    IN NUMBER)
IS

l_index NUMBER;

CURSOR c_transaction_detail_sequence
    IS SELECT hxc_transaction_details_s.NEXTVAL
         FROM DUAL;

l_transaction_detail_id hxc_transaction_details.transaction_detail_id%TYPE;

Begin

     l_index := g_detail_trans_tab.first;

     LOOP
        EXIT WHEN NOT g_detail_trans_tab.exists(l_index);


      	OPEN c_transaction_detail_sequence;
      	FETCH c_transaction_detail_sequence into l_transaction_detail_id;
      	CLOSE c_transaction_detail_sequence;

      	INSERT INTO hxc_transaction_details
      	  (transaction_detail_id
      	  ,time_building_block_id
      	  ,transaction_id
      	  ,created_by
      	  ,creation_date
      	  ,last_updated_by
      	  ,last_update_date
      	  ,last_update_login
      	  ,time_building_block_ovn
      	  ,status
      	  ,exception_description
      	) VALUES
      	  (l_transaction_detail_id
      	  ,l_index
      	  ,p_header_id
      	  ,NULL
      	  ,SYSDATE
      	  ,NULL
      	  ,SYSDATE
      	  ,NULL
      	  ,g_detail_trans_tab(l_index)
      	  ,'SUCCESS'
      	  ,'This is a prepopulated record and is already present in HR'
      	);

      	l_index := g_detail_trans_tab.next(l_index);

     END LOOP;

END insert_audit_details;



PROCEDURE manage_retrieval_audit (p_resource_id   IN NUMBER,
                                  p_start_time    IN DATE,
                                  p_stop_time     IN DATE)

IS

l_transaction_id  NUMBER;

   PROCEDURE clear_pending_notifications(p_resource_id   IN NUMBER,
                                         p_start_time    IN DATE,
                                         p_stop_time     IN DATE)
   IS

     CURSOR get_notifications
         IS SELECT transaction_id,
                   ROWIDTOCHAR(abs.ROWID)
              FROM hxc_abs_co_details abs
             WHERE resource_id = p_resource_id
               AND start_time  = p_start_time
               AND stop_time   = p_stop_time
               AND transaction_id IS NOT NULL;

      l_trans_tab NUMTABLE;
      l_rowid_tab VARCHARTABLE;

   BEGIN
        OPEN get_notifications;
        FETCH get_notifications BULK COLLECT INTO l_trans_tab,
                                                  l_rowid_tab;
        CLOSE get_notifications;

        IF l_trans_tab.COUNT > 0
        THEN
            l_trans_tab := SET(l_trans_tab);
            FOR i IN l_trans_tab.FIRST..l_trans_tab.LAST
            LOOP
                BEGIN
                      IF g_debug
                      THEN
                         hr_utility.trace('ABS : Calling delete_absences_in_tt ');
                         hr_utility.trace('ABS: Deleting trans '||l_trans_tab(i));
                      END IF;

                      hr_person_absence_swi.delete_absences_in_tt(l_trans_tab(i));

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                              NULL;
                END;
            END LOOP;

            FORALL i IN l_rowid_tab.FIRST..l_rowid_tab.LAST
              UPDATE hxc_abs_co_details
                 SET transaction_id = NULL
                WHERE ROWID = CHARTOROWID(l_rowid_tab(i));

         END IF;

    END clear_pending_notifications;

BEGIN
    IF g_detail_trans_tab.COUNT > 0
    THEN
       insert_audit_header(p_resource_id,
                           p_start_time,
                           p_stop_time,
                           l_transaction_id);

       insert_audit_details ( p_resource_id  => p_resource_id,
                              p_detail_bb_id   => 1,
                              p_detail_ovn     => 1,
                              p_header_id     => l_transaction_id);

    END IF;
    clear_pending_notifications(p_resource_id => p_resource_id,
                                p_start_time  => p_start_time,
                                p_stop_time   => p_stop_time);
END manage_retrieval_audit;


PROCEDURE verify_view_only_absences( p_blocks     IN            HXC_BLOCK_TABLE_TYPE,
                                     p_attributes IN            HXC_ATTRIBUTE_TABLE_TYPE,
                                     p_lock_rowid IN            VARCHAR2,
                                     p_messages   IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE)
IS

  CURSOR get_edit_status(p_element_type  IN NUMBER)
      IS SELECT edit_flag,uom
   	  FROM  hxc_absence_type_elements
   	 WHERE element_type_id = p_element_type;


  -- Bug 8829122
  -- Added condition for Stage in the below
  -- cursor to avoid RET records.
  CURSOR get_abs_data(p_lock_rowid  IN VARCHAR2,
                      p_start_time  IN DATE,
                      p_stop_time   IN DATE,
                      p_resource_id IN NUMBER )
      IS
        SELECT time_building_block_id,
               element_type_id,
	       DECODE(uom,'D',measure,NULL) measure,
	       DECODE(uom,'H',fnd_date.date_to_canonical(start_date),NULL) start_time,
	       DECODE(uom,'H',fnd_date.date_to_canonical(end_date),NULL)   stop_time,
               TRUNC(start_date) abs_date,
               'N' validated
          FROM hxc_abs_co_details
         WHERE start_time        = p_start_time
           AND resource_id       = p_resource_id
           AND TRUNC(stop_time)  = TRUNC(p_stop_time)
           AND stage IN ( 'PREP-SS', 'PREP','DEP');


  -- Bug 8886949
  -- Replaced lock rowid with resource id to avoid lock rowid issues.
  CURSOR get_pending_absences(p_resource_id IN NUMBER,
                              p_start_time  IN DATE,
                              p_stop_time   IN DATE)
      IS SELECT time_building_block_id,
                action
           FROM hxc_abs_co_details
          WHERE resource_id        = p_resource_id
            AND start_time        = p_start_time
            AND TRUNC(stop_time)  = TRUNC(p_stop_time)
            AND stage             = 'PREP-SS';


  -- Bug 8995913
  -- Added the below cursor for picking up absences pending
  -- confirmation.
  -- Bug 9018288
  -- Added conditions to check in PER table and remove
  -- SSHR related transactions.

  CURSOR get_pending_conf(p_resource_id   IN NUMBER,
                          p_start_time    IN DATE,
                          p_stop_time     IN DATE)
      IS SELECT /*+ LEADING(hxc) */
                time_building_block_id
           FROM hxc_abs_co_details hxc,
                per_absence_attendances per
          WHERE resource_id        = p_resource_id
            AND start_time         = p_start_time
            AND TRUNC(stop_time)   = TRUNC(p_stop_time)
            AND stage             IN ( 'PREP-SS','PREP', 'DEP')
            AND confirmed_flag     = 'N'
            AND transaction_id IS NULL
            AND action         IS NULL
            AND per.absence_attendance_id = NVL(hxc.absence_attendance_id,0)
            AND per.date_start IS NULL
            AND per.date_end   IS NULL ;


     CURSOR get_pending_absence_validation(p_resource_id IN NUMBER,
                              p_start_time  IN DATE,
                              p_stop_time   IN DATE)
         IS SELECT time_building_block_id,
               element_type_id,
	       DECODE(uom,'D',measure,NULL) measure,
	       DECODE(uom,'H',fnd_date.date_to_canonical(start_date),NULL) start_time,
	       DECODE(uom,'H',fnd_date.date_to_canonical(end_date),NULL)   stop_time,
               TRUNC(start_date) abs_date,
               'N' validated
              FROM hxc_abs_co_details
             WHERE resource_id = p_resource_id
               AND start_time = p_start_time
               AND TRUNC(stop_time) = TRUNC(p_stop_time)
               AND stage in ('DEP','PREP-SS')
               AND absence_attendance_id IS NULL;


TYPE ABSTAB IS TABLE OF get_abs_data%ROWTYPE INDEX BY BINARY_INTEGER;
l_usertab  ABSTAB;
l_cotab    ABSTAB;
l_valtab   ABSTAB;
l_pend_tab ABSTAB;
l_abs_tot_tab ABSTAB; -- Added for Bug 8888601

TYPE DAYTAB IS TABLE OF DATE INDEX BY BINARY_INTEGER;
l_daytab DAYTAB;


TYPE YESNOTAB IS TABLE OF VARCHAR2(5) INDEX BY BINARY_INTEGER;
l_edit_tab    YESNOTAB;
l_uom_tab     YESNOTAB;
l_element     VARCHAR2(5);
l_uom         VARCHAR2(5);
l_bb_id       NUMBER;
l_bb_ovn      NUMBER;
l_start_time  DATE;
l_stop_time   DATE;
l_resource_id NUMBER;
l_measure     NUMBER;
l_exists      NUMBER;
l_date_to     DATE;


i             NUMBER;
j   	      NUMBER;
bb_index      BINARY_INTEGER;
l_edit_prep   VARCHAR2(5);

l_pref_table  hxc_preference_evaluation.t_pref_table;
l_message     VARCHAR2(50);


l_validation_error  BOOLEAN := FALSE;
l_pa_abs            NUMBER := 0;
l_edit_pa           VARCHAR2(50);
l_bb_tab            NUMTABLE;
l_act_tab           VARCHARTABLE;


l_hr_val_action     VARCHAR2(500);
l_val_level         VARCHAR2(500);

l_pend_conf_action  VARCHAR2(50);

l_abs_name_tab      ALIAS_TAB;

--- ADDED FOR OTL Absence Integration 8888902
-- OTL-ABS START
l_precision             varchar2(4);
l_rounding_rule         varchar2(80);
l_pref_eval_date	date;
l_emp_hire_date		date;

l_abs_days          NUMBER;
l_abs_hours         NUMBER;

cursor emp_hire_info(p_resource_id hxc_time_building_blocks.resource_id%TYPE) IS
select date_start from per_periods_of_service where person_id=p_resource_id order by date_start desc;

-- OTL-ABS START

-- Bug 9019114
-- Added the below type and variables to
-- hold the OVN and Element type id for each building block
-- in p_blocks array.
TYPE NUMBERTAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_ovn_tab  NUMBERTAB;
l_ele_tab  NUMBERTAB;


   -- Bug 8855103
   -- Added the below function to return name of absence for the
   -- error token.

   FUNCTION get_abs_name(p_abs_id   IN NUMBER)
   RETURN VARCHAR2
   IS

     l_name VARCHAR2(500) := 'ERROR';
     CURSOR get_name (p_abs_id   IN NUMBER)
         IS SELECT name
              FROM per_abs_attendance_types_tl
             WHERE absence_attendance_type_id = p_abs_id
               AND language = USERENV('LANG');


   BEGIN
        IF l_abs_name_tab.EXISTS(p_abs_id)
        THEN
           RETURN l_abs_name_tab(p_abs_id);
        ELSE
           OPEN get_name(p_abs_id);
           FETCH get_name INTO l_name;
           CLOSE get_name;
           l_abs_name_tab(p_abs_id) := l_name;
           RETURN l_name;
        END IF;

   END get_abs_name;


   PROCEDURE add_error_to_tc( p_messages     IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE,
                              p_error_code   IN VARCHAR2,
                              p_bb_id        IN NUMBER,
                              p_error_level  IN VARCHAR2  DEFAULT hxc_timecard.c_error,
                              p_token        IN VARCHAR2 DEFAULT NULL)
   IS

   BEGIN
             hxc_timecard_message_helper.addErrorToCollection
                (p_messages
                ,p_error_code
               ,p_error_level
               ,null
               ,p_token
               ,hxc_timecard.c_hxc
               ,p_bb_id
               ,1
               ,null
               ,null
                );
          -- Bug 8945924
          -- Corrected the below condition to '='
          -- so that the flag is set only if there was an error.
          IF p_error_level = hxc_timecard.c_error
          THEN
             l_validation_error := TRUE;
          END IF;
   END add_error_to_tc;


   -- Bug 9019114
   -- Added this new procedure to pick restrict switching of
   -- Hours type for an already retrieved detail.
   PROCEDURE restrict_attribute_switch
   IS

     l_ind   BINARY_INTEGER;
     l_retrieved NUMBER;
     l_attribute NUMBER;


     CURSOR get_transactions( p_bb_id   IN NUMBER,
                              p_bb_ovn  IN NUMBER)
         IS SELECT htd.time_building_block_ovn
              FROM hxc_transaction_details htd,
                   hxc_transactions ht
             WHERE htd.time_building_block_id   = p_bb_id
               AND htd.time_building_block_ovn <= p_bb_ovn
               AND htd.transaction_id           = ht.transaction_id
               AND ht.type                      = 'RETRIEVAL'
               AND ht.transaction_process_id    = g_bee_retrieval
               AND htd.status                   = 'SUCCESS'
              ORDER BY time_building_block_id DESC;

     CURSOR pick_old_attribute(p_bb_id   IN NUMBER,
                               p_bb_ovn  IN NUMBER)
         IS SELECT REPLACE(hta.attribute_category,'ELEMENT - ')
              FROM hxc_time_attribute_usages hau,
                   hxc_time_attributes hta
             WHERE hau.time_building_block_id  = p_bb_id
               AND hau.time_building_block_ovn = p_bb_ovn
               AND hta.time_attribute_id       = hau.time_attribute_id
               AND hta.bld_blk_info_type_id    = g_bld_blk_info;

      l_old_exists BOOLEAN;
      l_new_exists BOOLEAN;
      l_count NUMBER;

     CURSOR pick_abs_type(p_element IN NUMBER)
         IS SELECT 1
              FROM hxc_absence_type_elements
             WHERE element_type_id = p_element;


   BEGIN
        l_ind := l_ovn_tab.FIRST;
        LOOP
           EXIT WHEN NOT l_ovn_tab.EXISTS(l_ind);
           OPEN get_transactions(l_ind,l_ovn_tab(l_ind));
           FETCH get_transactions
            INTO l_retrieved;
           IF get_transactions%FOUND
           THEN
              OPEN pick_old_attribute(l_ind,l_retrieved);
              FETCH pick_old_attribute
               INTO l_attribute;
              CLOSE pick_old_attribute;
              IF l_attribute <> l_ele_tab(l_ind)
              THEN
                  OPEN pick_abs_type(l_attribute);
                  FETCH pick_abs_type
                   INTO l_count;
                  IF pick_abs_type%FOUND
                  THEN
                     l_old_exists := TRUE;
                  ELSE
                     l_old_exists := FALSE;
                  END IF;
                  CLOSE pick_abs_type;

                  OPEN pick_abs_type(l_ele_tab(l_ind));
                  FETCH pick_abs_type
                   INTO l_count;
                  IF pick_abs_type%FOUND
                  THEN
                     l_new_exists := TRUE;
                  ELSE
                     l_new_exists := FALSE;
                  END IF;
                  CLOSE pick_abs_type;
                  IF ( l_new_exists = TRUE AND l_old_exists = FALSE)
                    OR (l_new_exists = FALSE AND l_old_exists = TRUE )
                  THEN
                      add_error_to_tc(p_messages,
                                     'HXC_ABS_NO_ATTRIBUTE_CHANGE',
                                      l_ind);
                  END IF;
              END IF;
           END IF;
           CLOSE get_transactions;
           l_ind := l_ovn_tab.NEXT(l_ind);
        END LOOP;

   END restrict_attribute_switch;





   -- Bug 8855103
   -- Added the below functions to do recipient update validations.

   PROCEDURE validate_overlap_absences( p_messages   IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE,
                                        p_usertab    IN ABSTAB,
                                        p_resource_id IN NUMBER,
                                        p_start_time IN DATE,
                                        p_stop_time  IN DATE,
                                        p_val_level  IN VARCHAR2)
   IS

     TYPE DATETAB IS TABLE OF DATE ;
     abs_datetab  DATETAB;
     sshr_datetab DATETAB;
     l_starttab   DATETAB;
     l_endtab     DATETAB;
     l_total      NUMBER;
     i  BINARY_INTEGER;
     l_valid      BOOLEAN := FALSE;

     CURSOR get_absences
         IS SELECT NVL(date_start,date_projected_start),
                   NVL(date_end,date_projected_end)
              FROM per_absence_attendances
             WHERE person_id = p_resource_id
               AND NVL(date_start,date_projected_start) <= p_stop_time
               AND NVL(date_end,date_projected_end) >= p_start_time;

     CURSOR get_pending_abs
         IS SELECT distinct TRUNC(start_date)
              FROM hxc_abs_co_details
             WHERE resource_id = p_resource_id
               AND start_time = p_start_time
               AND TRUNC(stop_time) = TRUNC(p_stop_time)
               AND stage in ('DEP','PREP-SS')
               AND absence_attendance_id IS NULL;


   BEGIN

        IF g_debug
        THEN
           i := p_usertab.FIRST;
       	   LOOP
                   hr_utility.trace('User bbid is '||i);
       	           hr_utility.trace('User Element '||p_usertab(i).element_type_id);
       	           hr_utility.trace('User measure '||p_usertab(i).measure);
       	           hr_utility.trace('User Start_time '||p_usertab(i).start_time);
             i := p_usertab.NEXT(i);
             EXIT WHEN NOT p_usertab.EXISTS(i);
           END LOOP;
        END IF;

        abs_datetab := DATETAB();
        i := p_usertab.FIRST;
        LOOP
            abs_datetab.EXTEND(1);
            j := abs_datetab.LAST;
            abs_datetab(j) := p_usertab(i).abs_date;
            i := p_usertab.NEXT(i);
            EXIT WHEN NOT p_usertab.EXISTS(i);
        END LOOP;

        OPEN get_pending_abs;
        FETCH get_pending_abs BULK COLLECT INTO sshr_datetab;
        CLOSE get_pending_abs;
        IF sshr_datetab IS NOT EMPTY
        THEN
            abs_datetab := abs_datetab MULTISET UNION sshr_datetab;
        END IF;

        IF abs_datetab IS NOT A SET
        THEN
            hr_utility.trace('ABS:Its not equal -- there is a detail overlap ');
            add_error_to_tc(p_messages,
                            'HXC_ABS_DET_OVERLAP',
                            NULL,
                              p_val_level);
        END IF;

        l_total := abs_datetab.COUNT;

        IF g_debug
        THEN
           FOR j IN abs_datetab.FIRST..abs_datetab.LAST
           LOOP
               hr_utility.trace('ABS:orig -'||abs_datetab(j));
           END LOOP;
        END IF;
        abs_datetab := SET(abs_datetab);

        IF g_debug
        THEN
           FOR j IN abs_datetab.FIRST..abs_datetab.LAST
           LOOP
               hr_utility.trace('ABS:Changed -'||abs_datetab(j));
           END LOOP;
        END IF;


        OPEN get_absences;
        FETCH get_absences BULK COLLECT INTO l_starttab,
                                             l_endtab;
        CLOSE get_absences;

        IF l_starttab IS NOT EMPTY
        THEN
            FOR i in l_starttab.FIRST..l_starttab.LAST
            LOOP
                FOR j in abs_datetab.FIRST..abs_datetab.LAST
              	LOOP
              	   IF abs_datetab(j) BETWEEN l_starttab(i)
              	                         AND l_endtab(i)
              	   THEN
              	           hr_utility.trace('ABS:There is a problem -- Overlap with HR');
              	           add_error_to_tc(p_messages,
              	                           'HXC_ABS_HR_OVERLAP',
              	                            NULL,
              	                           p_val_level);
              	           l_valid := TRUE;
              	           EXIT;
              	    END IF;
              	END LOOP;
                IF l_valid
                THEN
                   EXIT;
                END IF;
            END LOOP   ;
        END IF;


   END validate_overlap_absences;



   PROCEDURE validate_run_totals_and_pto (  p_messages   IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE,
                                        p_usertab    IN ABSTAB,
                                        p_pendtab    IN ABSTAB,
                                        p_resource_id IN NUMBER,
                                        p_start_time IN DATE,
                                        p_stop_time  IN DATE,
                                        p_val_level  IN VARCHAR2)
   IS

   l_abs_type_id  NUMBER;
   TYPE TOTTABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_tottab  TOTTABLE;
   l_asg     NUMBER;
   l_bal     NUMBER;

   -- Bug 9359368
   -- New array to hold Abs Inc or Dec balance type
   TYPE RUNTABLE IS TABLE OF VARCHAR2(5) INDEX BY BINARY_INTEGER;
   l_runtab  RUNTABLE;

   BEGIN

        l_asg := get_assignment_id(p_resource_id,
                                   p_start_time);

        hr_utility.trace('ABS:l_asg '||l_asg);

        IF TO_CHAR(p_start_time,'yyyy') = TO_CHAR(p_stop_time,'yyyy')
        THEN


            i := p_usertab.FIRST;
            LOOP
               EXIT WHEN NOT p_usertab.EXISTS(i);
               IF NOT l_tottab.EXISTS(get_absence_id(p_usertab(i).element_type_id))
               THEN
                  l_tottab(get_absence_id(p_usertab(i).element_type_id))
                       := NVL(p_usertab(i).measure,(FND_DATE.canonical_to_date(p_usertab(i).stop_time)
                                      -FND_DATE.canonical_to_date(p_usertab(i).start_time))*24);
               ELSE
                  l_tottab(get_absence_id(p_usertab(i).element_type_id))
                       :=  l_tottab(get_absence_id(p_usertab(i).element_type_id)) +
                        NVL(p_usertab(i).measure,(FND_DATE.canonical_to_date(p_usertab(i).stop_time
                                                                              )
                                               -   FND_DATE.canonical_to_date(p_usertab(i).start_time
                                                                              )
                                                   )*24
                            );

               END IF;
               -- Bug 9359368
               -- Find out Inc or Dec balance type
               IF NOT l_runtab.EXISTS(get_absence_id(p_usertab(i).element_type_id))
               THEN
                  l_runtab(get_absence_id(p_usertab(i).element_type_id)) :=
                         get_abs_running(p_usertab(i).element_type_id);
               END IF;
              i := p_usertab.NEXT(i);
            END LOOP;



            i := p_pendtab.FIRST;
            LOOP
               EXIT WHEN NOT p_pendtab.EXISTS(i);
               IF NOT l_tottab.EXISTS(get_absence_id(p_pendtab(i).element_type_id))
               THEN
                  l_tottab(get_absence_id(p_pendtab(i).element_type_id))
                       := NVL(p_pendtab(i).measure,(FND_DATE.canonical_to_date(p_pendtab(i).stop_time)
                                      -FND_DATE.canonical_to_date(p_pendtab(i).start_time))*24);
               ELSE
                  l_tottab(get_absence_id(p_pendtab(i).element_type_id))
                       :=  l_tottab(get_absence_id(p_pendtab(i).element_type_id)) +
                        NVL(p_pendtab(i).measure,(FND_DATE.canonical_to_date(p_pendtab(i).stop_time
                                                                              )
                                               -   FND_DATE.canonical_to_date(p_pendtab(i).start_time
                                                                              )
                                                   )*24
                            );

               END IF;
               -- Bug 9359368
               -- Find out Inc or Dec balance type
               IF NOT l_runtab.EXISTS(get_absence_id(p_pendtab(i).element_type_id))
               THEN
                  l_runtab(get_absence_id(p_pendtab(i).element_type_id)) :=
                         get_abs_running(p_pendtab(i).element_type_id);
               END IF;

              i := p_pendtab.NEXT(i);
            END LOOP;




            i := l_tottab.FIRST;
            LOOP
               EXIT WHEN NOT l_tottab.EXISTS(i);
               IF g_debug
               THEN
                  hr_utility.trace(' l_total for '||i);
               END IF;
               l_bal := per_absence_attendances_pkg.get_annual_balance(p_start_time,
                                                                      i,
                                                                      l_asg);
               IF g_debug
               THEN
                   hr_utility.trace(' l_balance '||l_bal);
                   hr_utility.trace(' l_tottab(i) '||l_tottab(i));
               END IF;
               IF l_bal < l_tottab(i)
                AND l_runtab(i) = 'D' -- Bug 9359368
               THEN
                   hr_utility.trace('ABS:There is a problem with running total ');
                   add_error_to_tc(p_messages,
                                  'HXC_ABS_RUN_TOTAL',
                                   NULL,
                                   p_val_level,
                                  'ABS&'||get_abs_name(i));
               END IF;


               IF NOT per_absence_attendances_pkg.is_emp_entitled (i,
                                                               l_asg,
                                                               p_start_time,
                                                               l_tottab(i),
                                                               l_tottab(i))
               THEN
                   hr_utility.trace('There is a problem with pto ');
                   add_error_to_tc(p_messages,
                                  'HXC_ABS_PTO_NOT_ENTITLED',
                                   NULL,
                                   p_val_level,
                                   'ABS&'||get_abs_name(i));
               END IF;


               i := l_tottab.NEXT(i);
            END LOOP;



        ELSE
            hr_utility.trace('ABS : Year crossing over in the timecard period ');

            i := p_usertab.FIRST;
            LOOP
               EXIT WHEN NOT p_usertab.EXISTS(i);
               IF TO_CHAR(p_usertab(i).abs_date,'YYYY') = TO_CHAR(p_start_time,'YYYY')
               THEN
                   IF NOT l_tottab.EXISTS(get_absence_id(p_usertab(i).element_type_id))
               	   THEN
               	      l_tottab(get_absence_id(p_usertab(i).element_type_id))
               	           := NVL(p_usertab(i).measure,(FND_DATE.canonical_to_date(p_usertab(i).stop_time)
               	                          -FND_DATE.canonical_to_date(p_usertab(i).start_time))*24);
               	   ELSE
               	      l_tottab(get_absence_id(p_usertab(i).element_type_id))
               	           :=  l_tottab(get_absence_id(p_usertab(i).element_type_id)) +
               	            NVL(p_usertab(i).measure,(FND_DATE.canonical_to_date(p_usertab(i).stop_time
               	                                                                  )
               	                                   -   FND_DATE.canonical_to_date(p_usertab(i).start_time
               	                                                                  )
               	                                       )*24
               	                );

               	   END IF;
               END IF;
              i := p_usertab.NEXT(i);
           END LOOP;

           i := p_pendtab.FIRST;
           LOOP
              EXIT WHEN NOT p_pendtab.EXISTS(i);
               IF TO_CHAR(p_pendtab(i).abs_date,'YYYY') = TO_CHAR(p_start_time,'YYYY')
               THEN

                  IF NOT l_tottab.EXISTS(get_absence_id(p_pendtab(i).element_type_id))
              	  THEN
              	     l_tottab(get_absence_id(p_pendtab(i).element_type_id))
              	          := NVL(p_pendtab(i).measure,(FND_DATE.canonical_to_date(p_pendtab(i).stop_time)
              	                         -FND_DATE.canonical_to_date(p_pendtab(i).start_time))*24);
              	  ELSE
              	     l_tottab(get_absence_id(p_pendtab(i).element_type_id))
              	          :=  l_tottab(get_absence_id(p_pendtab(i).element_type_id)) +
              	           NVL(p_pendtab(i).measure,(FND_DATE.canonical_to_date(p_pendtab(i).stop_time
              	                                                                 )
              	                                  -   FND_DATE.canonical_to_date(p_pendtab(i).start_time
              	                                                                 )
              	                                      )*24
              	               );

              	  END IF;
               END IF;
             i := p_pendtab.NEXT(i);
           END LOOP;

            i := l_tottab.FIRST;
            LOOP
               EXIT WHEN NOT l_tottab.EXISTS(i);
               IF g_debug
               THEN
                  hr_utility.trace(' l_total for '||i);
               END IF;
               l_bal := per_absence_attendances_pkg.get_annual_balance(p_start_time,
                                                                      i,
                                                                      l_asg);
               IF g_debug
               THEN
                   hr_utility.trace(' l_balance '||l_bal);
                   hr_utility.trace(' l_tottab(i) '||l_tottab(i));
               END IF;
               IF l_bal < l_tottab(i)
                AND l_runtab(i) = 'D'     -- Bug 9359368
               THEN
                   hr_utility.trace('ABS:There is a problem with running total ');
                   add_error_to_tc(p_messages,
                                  'HXC_ABS_RUN_TOTAL',
                                   NULL,
                                   p_val_level,
                                  'ABS&'||get_abs_name(i));
               END IF;


               IF NOT per_absence_attendances_pkg.is_emp_entitled (i,
                                                               l_asg,
                                                               p_start_time,
                                                               l_tottab(i),
                                                               l_tottab(i))
               THEN
                   hr_utility.trace('There is a problem with pto ');
                   add_error_to_tc(p_messages,
                                  'HXC_ABS_PTO_NOT_ENTITLED',
                                   NULL,
                                   p_val_level,
                                   'ABS&'||get_abs_name(i));
               END IF;


               i := l_tottab.NEXT(i);
            END LOOP;

            l_tottab.DELETE;

            i := p_usertab.FIRST;
            LOOP
               EXIT WHEN NOT p_usertab.EXISTS(i);
               IF TO_CHAR(p_usertab(i).abs_date,'YYYY') = TO_CHAR(p_stop_time,'YYYY')
               THEN
                   IF NOT l_tottab.EXISTS(get_absence_id(p_usertab(i).element_type_id))
               	   THEN
               	      l_tottab(get_absence_id(p_usertab(i).element_type_id))
               	           := NVL(p_usertab(i).measure,(FND_DATE.canonical_to_date(p_usertab(i).stop_time)
               	                          -FND_DATE.canonical_to_date(p_usertab(i).start_time))*24);
               	   ELSE
               	      l_tottab(get_absence_id(p_usertab(i).element_type_id))
               	           :=  l_tottab(get_absence_id(p_usertab(i).element_type_id)) +
               	            NVL(p_usertab(i).measure,(FND_DATE.canonical_to_date(p_usertab(i).stop_time
               	                                                                  )
               	                                   -   FND_DATE.canonical_to_date(p_usertab(i).start_time
               	                                                                  )
               	                                       )*24
               	                );

               	   END IF;
               END IF;
              i := p_usertab.NEXT(i);
           END LOOP;

           i := p_pendtab.FIRST;
           LOOP
              EXIT WHEN NOT p_pendtab.EXISTS(i);
               IF TO_CHAR(p_pendtab(i).abs_date,'YYYY') = TO_CHAR(p_stop_time,'YYYY')
               THEN

                  IF NOT l_tottab.EXISTS(get_absence_id(p_pendtab(i).element_type_id))
              	  THEN
              	     l_tottab(get_absence_id(p_pendtab(i).element_type_id))
              	          := NVL(p_pendtab(i).measure,(FND_DATE.canonical_to_date(p_pendtab(i).stop_time)
              	                         -FND_DATE.canonical_to_date(p_pendtab(i).start_time))*24);
              	  ELSE
              	     l_tottab(get_absence_id(p_pendtab(i).element_type_id))
              	          :=  l_tottab(get_absence_id(p_pendtab(i).element_type_id)) +
              	           NVL(p_pendtab(i).measure,(FND_DATE.canonical_to_date(p_pendtab(i).stop_time
              	                                                                 )
              	                                  -   FND_DATE.canonical_to_date(p_pendtab(i).start_time
              	                                                                 )
              	                                      )*24
              	               );

              	  END IF;
              END IF;
             i := p_pendtab.NEXT(i);
           END LOOP;

           i := l_tottab.FIRST;
           LOOP
              EXIT WHEN NOT l_tottab.EXISTS(i);
              IF g_debug
              THEN
                 hr_utility.trace(' l_total for '||i);
              END IF;
              l_bal := per_absence_attendances_pkg.get_annual_balance(p_stop_time,
                                                                     i,
                                                                     l_asg);
              IF g_debug
              THEN
                  hr_utility.trace(' l_balance '||l_bal);
                  hr_utility.trace(' l_tottab(i) '||l_tottab(i));
              END IF;
              IF l_bal < l_tottab(i)
                AND l_runtab(i) = 'D'         -- Bug 9359368
              THEN
                  hr_utility.trace('ABS:There is a problem with running total ');
                  add_error_to_tc(p_messages,
                                 'HXC_ABS_RUN_TOTAL',
                                  NULL,
                                  p_val_level,
                                 'ABS&'||get_abs_name(i));
              END IF;


              IF NOT per_absence_attendances_pkg.is_emp_entitled (i,
                                                              l_asg,
                                                              p_stop_time,
                                                              l_tottab(i),
                                                              l_tottab(i))
              THEN
                  hr_utility.trace('There is a problem with pto ');
                  add_error_to_tc(p_messages,
                                 'HXC_ABS_PTO_NOT_ENTITLED',
                                  NULL,
                                  p_val_level,
                                  'ABS&'||get_abs_name(i));
              END IF;


              i := l_tottab.NEXT(i);
           END LOOP;




      END IF;




   END validate_run_totals_and_pto;







BEGIN

    IF p_attributes.COUNT = 0
    THEN
       RETURN ;
    END IF;



    IF g_debug
    THEN
        hr_utility.trace('p_lock_rowid '||p_lock_rowid);
        i := p_blocks.FIRST;
         LOOP
            hr_utility.trace('p_blocks(i).time_building_block_id '||p_blocks(i).time_building_block_id);
            hr_utility.trace('p_blocks(i).object_version_number '||p_blocks(i).object_version_number);
            hr_utility.trace('p_blocks(i).scope '||p_blocks(i).scope);
            hr_utility.trace('p_blocks(i).start_time '||p_blocks(i).start_time);
            hr_utility.trace('p_blocks(i).stop_time '||p_blocks(i).stop_time);
            hr_utility.trace('p_blocks(i).measure '||p_blocks(i).measure);
            hr_utility.trace('p_blocks(i).date_to '||p_blocks(i).date_to);
            i:= p_blocks.NEXT(i);
            EXIT WHEN NOT p_blocks.EXISTS(i);
         END LOOP;

         i:= p_attributes.FIRST;
         LOOP
            hr_utility.trace('p_attributes(i).building_block_id '||p_attributes(i).building_block_id);
            hr_utility.trace('p_attributes(i).building_block_ovn '||p_attributes(i).building_block_ovn);
            hr_utility.trace('p_attributes(i).attribute_category '||p_attributes(i).attribute_category);
            hr_utility.trace('p_attributes(i).bld_blk_info_type '||p_attributes(i).bld_blk_info_type);
            i:= p_attributes.NEXT(i);
            EXIT WHEN NOT p_blocks.EXISTS(i);
         END LOOP;

     END IF;

     IF l_usertab.COUNT >0
     THEN
        l_usertab.DELETE;
     END IF;


      -- gather absence types from p_blocks

      i := p_blocks.FIRST;
      LOOP
      << TO_CONTINUE_TO_NEXT_BLOCK >>
      LOOP
         IF p_blocks(i).scope = 'TIMECARD'
          -- Bug 8858587
          -- Dont do any of these in case the timecard is going to be deleted.
          AND FND_DATE.canonical_to_date(p_blocks(i).DATE_TO) = hr_general.end_of_time
         THEN
            hxc_preference_evaluation.resource_preferences(p_blocks(i).resource_id,
                                                           FND_DATE.canonical_to_date(p_blocks(i).start_time),
                                                           FND_DATE.canonical_to_date(p_blocks(i).start_time),
                                                           l_pref_table);
            l_start_time := FND_DATE.canonical_to_date(p_blocks(i).start_time);
            l_stop_time  := FND_DATE.canonical_to_date(p_blocks(i).stop_time);
            l_resource_id := p_blocks(i).resource_id;
            EXIT TO_CONTINUE_TO_NEXT_BLOCK;
         END IF;
         IF g_debug
         THEN
            hr_utility.trace('p_blocks(i).time_building_block_id '||p_blocks(i).time_building_block_id);
            hr_utility.trace('p_blocks(i).date_to '||p_blocks(i).date_to);
            hr_utility.trace('p_blocks(i).scope '||p_blocks(i).scope);
         END IF;

         IF p_blocks(i).scope = 'DAY'
         THEN
            l_daytab(p_blocks(i).time_building_block_id) := TRUNC(fnd_date.canonical_to_date(p_blocks(i).start_time));
            EXIT TO_CONTINUE_TO_NEXT_BLOCK;
         END IF;

         IF p_blocks(i).SCOPE <> 'DETAIL'
           OR FND_DATE.canonical_to_date(p_blocks(i).DATE_TO) <> hr_general.end_of_time
         THEN
            EXIT TO_CONTINUE_TO_NEXT_BLOCK;
         END IF;
         bb_index := p_blocks(i).time_building_block_id;
         l_usertab(bb_index).time_building_block_id := bb_index;
         l_usertab(bb_index).measure := p_blocks(i).measure;
         l_usertab(bb_index).start_time := p_blocks(i).start_time;
         l_usertab(bb_index).stop_time := p_blocks(i).stop_time;
         l_usertab(bb_index).abs_date := l_daytab(p_blocks(i).parent_building_block_id);
         l_usertab(bb_index).validated := 'N';
         -- Bug 9019114
         l_ovn_tab(bb_index) := p_blocks(i).object_version_number;
         EXIT  TO_CONTINUE_TO_NEXT_BLOCK;
      END LOOP TO_CONTINUE_TO_NEXT_BLOCK;
      i := p_blocks.NEXT(i);
      EXIT WHEN NOT p_blocks.EXISTS(i);
      END LOOP;


      IF l_pref_table.COUNT = 0
      THEN
         hr_utility.trace('ABS Either no preferences or this is a template. Return');
         RETURN;
      END IF;

       i := l_pref_table.FIRST;
       LOOP
          IF l_pref_table(i).preference_code = 'TS_ABS_PREFERENCES'
          THEN
              l_edit_prep := l_pref_table(i).attribute2;
              l_edit_pa   := l_pref_table(i).attribute3;
              l_hr_val_action := l_pref_table(i).attribute6;
              l_pend_conf_action := l_pref_table(i).attribute7;
              IF l_pref_table(i).attribute1 <> 'Y'
              THEN
                 IF g_debug
                 THEN
                    hr_utility.trace('Abs Integration disabled for this employee ');
                 END IF;
                 -- Bug 8886949
                 -- Need to return when integration preference is set to NO.
                 RETURN;
              END IF;
              EXIT;
          END IF;
          i := l_pref_table.NEXT(i);
          EXIT WHEN NOT l_pref_table.EXISTS(i);
        END LOOP;


     -- Bug 8886949
     -- Replaced lock rowid with resource id so that querying happens fine.
     OPEN get_pending_absences(l_resource_id,
                               l_start_time,
                               l_stop_time);

     FETCH get_pending_absences BULK COLLECT INTO l_bb_tab,l_act_tab;
     CLOSE get_pending_absences;

     IF l_bb_tab.COUNT > 0
     THEN
        FOR i IN l_bb_tab.FIRST..l_bb_tab.LAST
        LOOP
           IF l_edit_pa = 'ERROR'
           THEN
               add_error_to_tc(p_messages,
                               'HXC_ABS_PEND_APPR_ERROR',
                               l_bb_tab(i));
            ELSE
               add_error_to_tc(p_messages,
                               'HXC_ABS_PEND_APPR_WARNING',
                               NULL,
                               hxc_timecard.c_warning);
              EXIT;
             END IF;
        END LOOP;

     END IF;

     -- Bug 8995913
     -- Added validation for absences pending Confirmation..

     OPEN get_pending_conf(l_resource_id,
                           l_start_time,
                           l_stop_time);

     FETCH get_pending_conf BULK COLLECT INTO l_bb_tab;
     CLOSE get_pending_conf;

     IF l_bb_tab.COUNT > 0
     THEN
        FOR i IN l_bb_tab.FIRST..l_bb_tab.LAST
        LOOP
           IF l_pend_conf_action = 'ERROR'
           THEN
               add_error_to_tc(p_messages,
                               'HXC_ABS_PEND_CONF_ERROR',
                               l_bb_tab(i));
           ELSE
               add_error_to_tc(p_messages,
                               'HXC_ABS_PEND_CONF_WARNING',
                               NULL,
                               hxc_timecard.c_warning);
              EXIT;
           END IF;
        END LOOP;

     END IF;



     i := p_attributes.FIRST;
     LOOP
        << TO_CONTINUE_TO_NEXT_ATTRIBUTE >>
      	LOOP
      	   IF p_attributes(i).bld_blk_info_type <> 'Dummy Element Context'
      	   THEN
      	      EXIT TO_CONTINUE_TO_NEXT_ATTRIBUTE;
      	   END IF;

           -- Bug 9019114
           -- Added the below construct to copy the element type id
           -- of a bb-id, OVN combo, which is of OVN > 1.
           IF l_ovn_tab.EXISTS(p_attributes(i).building_block_id)
           THEN
              l_ele_tab(p_attributes(i).building_block_id) := REPLACE(p_attributes(i).attribute_category,'ELEMENT - ');
           END IF;

      	   IF NOT l_edit_tab.EXISTS(REPLACE(p_attributes(i).attribute_category,'ELEMENT - '))
      	    THEN
      	       OPEN get_edit_status(REPLACE(p_attributes(i).attribute_category,'ELEMENT - '));
      	       FETCH get_edit_status INTO l_element,l_uom;
      	       IF get_edit_status%NOTFOUND
      	       THEN
      	           CLOSE get_edit_status;
      	           l_usertab.DELETE(p_attributes(i).building_block_id);
      	           EXIT TO_CONTINUE_TO_NEXT_ATTRIBUTE;
      	       END IF;
      	       CLOSE get_edit_status;
      	       l_edit_tab(REPLACE(p_attributes(i).attribute_category,'ELEMENT - ')) := l_element;
      	       l_uom_tab(REPLACE(p_attributes(i).attribute_category,'ELEMENT - ')) := l_uom;
      	    END IF;
      	    IF l_usertab.EXISTS(p_attributes(i).building_block_id)
      	    THEN
      	       l_usertab(p_attributes(i).building_block_id).element_type_id :=
      	                REPLACE(p_attributes(i).attribute_category,'ELEMENT - ');
      	    END IF;
      	    EXIT TO_CONTINUE_TO_NEXT_ATTRIBUTE;
        END LOOP TO_CONTINUE_TO_NEXT_ATTRIBUTE;
        i := p_attributes.NEXT(i);
        EXIT WHEN NOT p_attributes.EXISTS(i);
     END LOOP;

     -- Bug 9019114
     -- Calling the below procedures to populate global variables
     -- and limit switching of hours type in case the details are
     -- already retrieved.
     populate_globals;
     restrict_attribute_switch;


       IF g_debug
       THEN
           hr_utility.trace('l_start_time '||l_start_time);
           hr_utility.trace('p_lock_rowid '||p_lock_rowid);
           hr_utility.trace('l_stop_time '||TO_CHAR(l_stop_time,'dd-mon-yyyy hh:mi:ss'));
       END IF;

       IF l_cotab.COUNT >0
       THEN
          l_cotab.DELETE;
       END IF;

       OPEN get_abs_data(p_lock_rowid,
                         l_start_time,
                         l_stop_time,
                         l_resource_id);
       FETCH get_abs_data BULK COLLECT INTO l_cotab;
       CLOSE get_abs_data;


       -- Bug 8910881
       -- Added the below construct to work out
       -- situations where the only one row is deleted.
       IF l_cotab.COUNT >0
         AND l_usertab.COUNT = 0
         AND l_edit_prep = 'Y'
       THEN
          IF g_debug
          THEN
             hr_utility.trace('ABS: There is a validation prob');
          END IF;
          j := l_cotab.FIRST;
          LOOP
             IF NOT l_edit_tab.EXISTS(l_cotab(j).element_type_id)
       	     THEN
       		 OPEN get_edit_status(l_cotab(j).element_type_id);
       		 FETCH get_edit_status INTO l_element,l_uom;
       		 CLOSE get_edit_status;
       		 l_edit_tab(l_cotab(j).element_type_id) := l_element;
       		 l_uom_tab(l_cotab(j).element_type_id) := l_uom;
       	      END IF;
              IF l_element = 'N'
              THEN
                 IF g_debug
          	 THEN
          	    hr_utility.trace('ABS: There is an error added');
          	 END IF;
                 add_error_to_tc(p_messages,
                                'HXC_ABS_VIEW_ONLY_NO_DELETE',
                                 l_cotab(j).time_building_block_id);
              END IF;
              j := l_cotab.NEXT(j);
              EXIT WHEN NOT l_cotab.EXISTS(j);
          END LOOP;
       END IF;


       -- Bug 8858587
       -- Added the condition to check if there are any
       -- prepop rows and pref to edit these is set to NO.

       IF l_usertab.COUNT = 0
       THEN
          IF l_cotab.COUNT > 0
            AND l_edit_prep = 'N'
          THEN
             add_error_to_tc(p_messages,
                            'HXC_ABS_NO_EDIT_PREP',
                             NULL);
          END IF;

          IF g_debug
          THEN
              hr_utility.trace('No active details in this timecard, Return ');
          END IF;
          RETURN;
       END IF;

       IF l_edit_tab.COUNT = 0
       THEN
          IF g_debug
          THEN
              hr_utility.trace('No abs elements in this timecard, Return ');
          END IF;
          RETURN ;
       END IF;


       IF g_debug
       THEN
          i := l_edit_tab.FIRST;
       	  LOOP
       	     IF g_debug
             THEN
                 hr_utility.trace('Element is '||i);
       	         hr_utility.trace('Edit is '||l_edit_tab(i));
             END IF;
       	     i := l_edit_tab.NEXT(i);
       	     EXIT WHEN NOT l_edit_tab.EXISTS(i);
       	  END LOOP;

       	  i := l_usertab.FIRST;
       	  LOOP
       	     IF g_debug
             THEN
                 hr_utility.trace('User bbid is '||i);
       	         hr_utility.trace('User Element '||l_usertab(i).element_type_id);
       	         hr_utility.trace('User measure '||l_usertab(i).measure);
       	         hr_utility.trace('User Start_time '||l_usertab(i).start_time);
             END IF;

       	     i := l_usertab.NEXT(i);
       	     EXIT WHEN NOT l_usertab.EXISTS(i);
       	  END LOOP;
          IF g_debug
          THEN
             IF l_cotab.COUNT > 0
             THEN
       	     i := l_cotab.FIRST;
       	        LOOP
       	     	   hr_utility.trace('Co bbid is '||i);
             	   hr_utility.trace('CoElement '||l_cotab(i).element_type_id);
       	     	   hr_utility.trace('Comeasure '||l_cotab(i).measure);
       	     	   hr_utility.trace('CoStart_time '||l_cotab(i).start_time);
             	   hr_utility.trace('Co time bb id '||l_cotab(i).time_building_block_id);
       	     	   hr_utility.trace('Co Start_time '||l_cotab(i).start_time);
             	   i := l_cotab.NEXT(i);
       	     	   EXIT WHEN NOT l_cotab.EXISTS(i);
       	     	END LOOP;
             END IF;
          END IF;

       END IF;

       -- Bug 8945994
       -- Added the below construct to avoid a later exception.
       -- If there are no attributes, raise an error and return.
       IF l_usertab.COUNT > 0
       THEN
           i := l_usertab.FIRST;
           LOOP
              IF l_usertab(i).element_type_id IS NULL
              THEN
                  add_error_to_tc (p_messages
       	                          ,'HXC_DEP_VAL_NO_ATTR'
                                  ,l_usertab(i).time_building_block_id);
              END IF;
              i:= l_usertab.NEXT(i);
              EXIT WHEN NOT l_usertab.EXISTS(i);
           END LOOP;
       END IF;

       IF l_validation_error
       THEN
          RETURN;
       END IF;


       l_valtab      := l_usertab;
       l_abs_tot_tab := l_usertab; -- Added for Bug 8888601


       IF g_debug
       THEN
          hr_utility.trace('l_edit_prep is set to '||l_edit_prep);
       END IF;

       IF l_cotab.COUNT > 0
       THEN
          j := l_cotab.FIRST;
       	  LOOP
           << CONTINUE_TO_NEXT >>
       		  LOOP
       	             IF g_debug
                     THEN
                         hr_utility.trace('CoElement '||l_cotab(j).element_type_id);
       	                 hr_utility.trace('Comeasure '||l_cotab(j).measure);
       	                 hr_utility.trace('CoStart_time '||l_cotab(j).start_time);
                         hr_utility.trace('Co time bb id '||l_cotab(j).time_building_block_id);
                     END IF;

       		     IF NOT l_edit_tab.EXISTS(l_cotab(j).element_type_id)
       		     THEN

       		        OPEN get_edit_status(l_cotab(j).element_type_id);
       		        FETCH get_edit_status INTO l_element,l_uom;
       		        CLOSE get_edit_status;
       		        l_edit_tab(l_cotab(j).element_type_id) := l_element;
       		        l_uom_tab(l_cotab(j).element_type_id) := l_uom;
       		     END IF;

                     IF l_valtab.EXISTS(l_cotab(j).time_building_block_id)
                     THEN
                        l_valtab.DELETE(l_cotab(j).time_building_block_id);
                     END IF;

       		     IF ( l_edit_prep = 'N'
       		          OR l_edit_tab(l_cotab(j).element_type_id) = 'N')
       		     THEN
       		        IF NOT l_usertab.EXISTS(l_cotab(j).time_building_block_id)
       		        THEN
       		           IF l_edit_prep = 'N'
       		           THEN
       		               l_message := 'HXC_ABS_NO_EDIT_PREP';
       		           ELSE
       		               l_message := 'HXC_ABS_VIEW_ONLY_NO_DELETE';
       		           END IF;
       		           -- Bug 8888488
       		           -- Passing NULL for building block id so that
       		           -- timekeeper has no issues in showing up the error.
       		           add_error_to_tc (p_messages
       		                            ,l_message
                                            ,NULL);
       		           EXIT CONTINUE_TO_NEXT;
                        END IF;
       		        IF     NVL(l_cotab(j).measure,0)    <> NVL(l_usertab(l_cotab(j).time_building_block_id).measure,0)
       		            OR NVL(l_cotab(j).start_time,TRUNC(sysdate)) <> NVL(l_usertab(l_cotab(j).time_building_block_id).start_time,TRUNC(SYSDATE))
       		            OR NVL(l_cotab(j).stop_time,TRUNC(SYSDATE))  <> NVL(l_usertab(l_cotab(j).time_building_block_id).stop_time,TRUNC(SYSDATE))
       		            -- Bug 8864161
       		            -- Added this condition to restrict hours type change also.
       		            OR NVL(l_cotab(j).element_type_id,0)  <> NVL(l_usertab(l_cotab(j).time_building_block_id).element_type_id,0)
       		        THEN
                           IF g_debug
                           THEN
                               hr_utility.trace( 'There is a mismatch in prepopulated ');
                           END IF;
       		           IF l_edit_prep = 'N'
       		           THEN
       		               l_message := 'HXC_ABS_NO_EDIT_PREP';
       		           ELSE
       		               l_message := 'HXC_ABS_VIEW_ONLY';
       		           END IF;
                           add_error_to_tc (p_messages
       		                           ,l_message
       		                           ,l_cotab(j).time_building_block_id);
       		           l_usertab.DELETE(l_cotab(j).time_building_block_id);
       		           EXIT CONTINUE_TO_NEXT;
       		        ELSE
                           IF g_debug
                           THEN
                              hr_utility.trace( 'There is no mismatch, this is just like prepopulated ');
                           END IF;
       		           l_usertab.DELETE(l_cotab(j).time_building_block_id);
       		           EXIT CONTINUE_TO_NEXT;
       		        END IF;
       		     END IF;
       		     EXIT CONTINUE_TO_NEXT;
       		  END LOOP CONTINUE_TO_NEXT;
       	     j := l_cotab.NEXT(j);
       	     EXIT WHEN NOT l_cotab.EXISTS(j);
       	  END LOOP;

       END IF;

        IF l_usertab.COUNT > 0
        THEN
           j := l_usertab.FIRST;
           LOOP
              IF l_edit_tab(l_usertab(j).element_type_id) = 'N'
              THEN
                  add_error_to_tc ( p_messages
                                   ,'HXC_ABS_VIEW_ONLY'
                                   ,l_usertab(j).time_building_block_id );
               ELSIF l_uom_tab(l_usertab(j).element_type_id) = 'HOURS'
                   AND (    l_usertab(j).start_time IS NULL
                         OR l_usertab(j).stop_time IS NULL
                         OR l_usertab(j).measure IS NOT NULL )
               THEN
                    add_error_to_tc (p_messages
                                   ,'HXC_ABS_HOUR_FORMAT'
                                   ,l_usertab(j).time_building_block_id );
               ELSIF l_uom_tab(l_usertab(j).element_type_id) = 'DAYS'
                   AND (    l_usertab(j).start_time IS NOT NULL
                         OR l_usertab(j).stop_time IS NOT NULL
                         OR l_usertab(j).measure <> 1 )
               THEN
                       add_error_to_tc (p_messages
                                      ,'HXC_ABS_DAY_FORMAT'
                                      ,l_usertab(j).time_building_block_id );
               END IF;
               j := l_usertab.NEXT(j);
               EXIT WHEN NOT l_usertab.EXISTS(j);
           END LOOP;
        END IF;

       IF l_validation_error
       THEN
           RETURN;
       END IF;

       -- Bug 8855103
       -- Below code added for recipient update validation.
       OPEN get_pending_absence_validation(l_resource_id,
                                           l_start_time,
                                           l_stop_time);

       FETCH get_pending_absence_validation BULK COLLECT INTO l_pend_tab;
       CLOSE get_pending_absence_validation;


       IF l_hr_val_action = 'ERROR'
       THEN
          l_val_level := hxc_timecard.c_error;
       ELSIF l_hr_val_action = 'WARNING'
       THEN
          l_val_level := hxc_timecard.c_warning;
       END IF;


       IF l_usertab.COUNT > 0
         -- Bug 8945994
         -- Added below check.
         AND l_valtab.COUNT > 0
         AND l_hr_val_action <> 'IGNORE'
       THEN


           validate_overlap_absences(p_messages,
       	                             l_valtab,
       	                             l_resource_id,
       	                             l_start_time,
       	                             l_stop_time,
       	                             l_val_level);

       	   validate_run_totals_and_pto(p_messages,
       	                           l_valtab,
       	                           l_pend_tab,
       	                           l_resource_id,
       	                           l_start_time,
       	                           l_stop_time,
       	                           l_val_level);
       END IF;

  -- Added for OTL ABS Integration 8888902
  -- OTL-ABS START

  OPEN  emp_hire_info (l_resource_id);
  FETCH emp_hire_info INTO l_emp_hire_date;
  CLOSE emp_hire_info;

  IF trunc(l_emp_hire_date) >= trunc(l_start_time)
  AND trunc(l_emp_hire_date) <= trunc(l_stop_time)
  THEN
  	l_pref_eval_date := trunc(l_emp_hire_date);
  ELSE
  	l_pref_eval_date := trunc(l_start_time);
  END IF;

  l_precision := hxc_preference_evaluation.resource_preferences
                                                (l_resource_id,
                                                 'TC_W_TCRD_UOM',
                                                 3,
                                                 l_pref_eval_date);


  l_rounding_rule := hxc_preference_evaluation.resource_preferences
                                                (l_resource_id,
                                                 'TC_W_TCRD_UOM',
                                                 4,
                                                 l_pref_eval_date);
  IF l_precision IS NULL
  THEN
  l_precision := '2';
  END IF;

  IF l_rounding_rule IS NULL
  THEN
  l_rounding_rule := 'ROUND_TO_NEAREST';
  END IF;

  IF g_debug THEN
    hr_utility.trace('ABS> In hxc_retrieve_absences.verify_view_only_absences');
    hr_utility.trace('ABS> invoke logic to calculate absence hours and absence days');
    hr_utility.trace('ABS> l_precision     ::'||l_precision);
    hr_utility.trace('ABS> l_rounding_rule ::'||l_rounding_rule);
    hr_utility.trace('ABS> l_abs_days      ::'||l_abs_days);
    hr_utility.trace('ABS> l_abs_hours     ::'||l_abs_hours);
    hr_utility.trace('ABS> l_abs_tot_tab.COUNT     ::'||l_abs_tot_tab.COUNT);
    hr_utility.trace('ABS> p_messages.COUNT     ::'||p_messages.COUNT);
  END IF;

  l_abs_days  := 0;
  l_abs_hours := 0;

    IF l_abs_tot_tab.COUNT > 0
    THEN
      j := l_abs_tot_tab.FIRST;
        LOOP

	  IF g_debug THEN
	    hr_utility.trace('ABS> In LOOP OF l_abs_tot_tab INDEX ::'||j);
	    hr_utility.trace('ABS> l_uom_tab(l_abs_tot_tab(j).element_type_id) ::'
	                             ||l_uom_tab(l_abs_tot_tab(j).element_type_id));
	  END IF;

    	  IF l_uom_tab(l_abs_tot_tab(j).element_type_id) = 'DAYS'
          THEN

	    IF g_debug THEN
	      hr_utility.trace('ABS> l_uom_tab(l_abs_tot_tab(j).element_type_id) ::'
				       ||l_uom_tab(l_abs_tot_tab(j).element_type_id));
	      hr_utility.trace('ABS> l_abs_tot_tab(j).measure ::'||l_abs_tot_tab(j).measure);
            END IF;

            l_abs_days := l_abs_days +
                              hxc_find_notify_aprs_pkg.apply_round_rule(
                                                    l_rounding_rule,
                              		            l_precision,
                                                    nvl(l_abs_tot_tab(j).measure,0)
                              		            );
          ELSIF l_uom_tab(l_abs_tot_tab(j).element_type_id) = 'HOURS'
          THEN
    	    IF g_debug THEN
	      hr_utility.trace('ABS> l_uom_tab(l_abs_tot_tab(j).element_type_id) ::'
				       ||l_uom_tab(l_abs_tot_tab(j).element_type_id));
      	      hr_utility.trace('ABS> l_abs_tot_tab(j).stop_time ::'||l_abs_tot_tab(j).stop_time);
      	      hr_utility.trace('ABS> l_abs_tot_tab(j).start_time ::'||l_abs_tot_tab(j).start_time);
      	      hr_utility.trace('ABS> FND_DATE.CANONICAL_TO_DATE(l_abs_tot_tab(j).stop_time) ::'
                                    ||FND_DATE.CANONICAL_TO_DATE(l_abs_tot_tab(j).stop_time));
      	      hr_utility.trace('ABS> FND_DATE.CANONICAL_TO_DATE(l_abs_tot_tab(j).start_time ::'
                                    ||FND_DATE.CANONICAL_TO_DATE(l_abs_tot_tab(j).start_time));
	    END IF;

            l_abs_hours := l_abs_hours +
                                hxc_find_notify_aprs_pkg.apply_round_rule(
                                          l_rounding_rule,
				          l_precision,
                                          nvl((FND_DATE.CANONICAL_TO_DATE(l_abs_tot_tab(j).stop_time) -
                                                FND_DATE.CANONICAL_TO_DATE(l_abs_tot_tab(j).start_time))*24,0)
					  );
          END IF;

          j := l_abs_tot_tab.NEXT(j);
          EXIT WHEN NOT l_abs_tot_tab.EXISTS(j);

        END LOOP;
    END IF;

    IF g_debug THEN
      hr_utility.trace('ABS> In hxc_retrieve_absences.verify_view_only_absences');
      hr_utility.trace('ABS> final values of absence hours and absence days');
      hr_utility.trace('ABS> l_resource_id ::'||l_resource_id);
      hr_utility.trace('ABS> l_start_time ::'||l_start_time);
      hr_utility.trace('ABS> l_stop_time ::'||l_stop_time);
      hr_utility.trace('ABS> l_abs_days ::'||l_abs_days);
      hr_utility.trace('ABS> l_abs_hours ::'||l_abs_hours);
      hr_utility.trace('ABS> now invoke update_absence_summary_row');
    END IF;

    update_absence_summary_row(l_resource_id,
                               l_start_time,
                               l_stop_time,
                               l_abs_days,
                               l_abs_hours
                              );

  -- End of Code for Bug 8888902

    RETURN;

  END verify_view_only_absences;


PROCEDURE clear_prev_sessions(p_resource_id   IN NUMBER,
                              p_tc_start      IN DATE,
                              p_tc_stop       IN DATE,
                              p_lock_rowid    IN VARCHAR2)
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

   DELETE FROM hxc_abs_co_details
         WHERE resource_id = p_resource_id
           AND start_time = p_tc_start
           AND TRUNC(stop_time) = TRUNC(p_tc_stop);


   COMMIT;

  END clear_prev_sessions;

-- Added for OTL ABS Integration 8888902
-- OTL-ABS START

PROCEDURE insert_absence_summary_row
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_abs_record_exist  VARCHAR2(1) := 'Y';
  BEGIN

    SELECT 'Y'
      INTO l_abs_record_exist
      FROM hxc_absence_summary_temp
     WHERE resource_id = hxc_retrieve_absences.g_person_id
       AND start_time  = hxc_retrieve_absences.g_start_time
       AND stop_time   = hxc_retrieve_absences.g_stop_time;

    IF l_abs_record_exist = 'Y' THEN
     -- DO NOTHING
     return;

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      INSERT INTO hxc_absence_summary_temp
      (resource_id
      ,start_time
      ,stop_time
      )
      VALUES
      (hxc_retrieve_absences.g_person_id
      ,hxc_retrieve_absences.g_start_time
      ,hxc_retrieve_absences.g_stop_time
      );

      COMMIT;
   END insert_absence_summary_row;


PROCEDURE update_absence_summary_row(p_resource_id   IN NUMBER,
                              	     p_tc_start      IN DATE,
                                     p_tc_stop       IN DATE,
                                     p_abs_days      IN NUMBER,
																		 p_abs_hours     IN NUMBER
                                     )
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    UPDATE hxc_absence_summary_temp
       SET absence_days = p_abs_days,
           absence_hours = p_abs_hours
     WHERE resource_id = p_resource_id
       AND start_time  = p_tc_start
       AND stop_time   = p_tc_stop;

    COMMIT;
  END update_absence_summary_row;


PROCEDURE clear_absence_summary_rows
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    DELETE FROM hxc_absence_summary_temp;
    COMMIT;

  END clear_absence_summary_rows;

-- OTL-ABS END

-- Returns Lookup Meaning for a given lookup type and code
FUNCTION get_lookup_value( p_lookup_type    IN VARCHAR2,
                           p_lookup_code    IN VARCHAR2)
RETURN VARCHAR2
IS

    CURSOR get_meaning(p_lookup_type  IN VARCHAR2,
                       p_lookup_code  IN VARCHAR2)
        IS SELECT meaning
	     FROM FND_LOOKUP_VALUES
            WHERE lookup_type  = p_lookup_type
    	      AND language     = USERENV('LANG')
              AND enabled_flag = 'Y'
              AND lookup_code  = p_lookup_code;

     l_meaning  VARCHAR2(200);

BEGIN

     OPEN get_meaning(p_lookup_type,
                      p_lookup_code);

     FETCH get_meaning INTO l_meaning;

     CLOSE get_meaning;

     IF l_meaning IS NULL
     THEN
        l_meaning := 'LOOKUP ERROR';
     END IF;

     RETURN l_meaning;

END get_lookup_value;


-- Bug 8911152
-- Added this new function to create layout attributes.

FUNCTION get_layout_attribute  ( p_bb_id            IN NUMBER,
                                 p_bb_ovn  	    IN NUMBER,
                                 p_attribute_id     IN NUMBER)
RETURN HXC_ATTRIBUTE_TYPE
IS


l_attribute_type  HXC_ATTRIBUTE_TYPE;
l_attribute1  NUMBER;
l_attribute2  NUMBER;
l_attribute3  NUMBER;

BEGIN

    l_attribute_type := HXC_ATTRIBUTE_TYPE(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               			           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               			       	   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    IF g_pref_table.COUNT >0
    THEN
        FOR i IN g_pref_table.FIRST..g_pref_table.LAST
        LOOP
           IF g_pref_table(i).preference_code = 'TC_W_TCRD_LAYOUT'
           THEN
               l_attribute1 := g_pref_table(i).attribute1;
               l_attribute2 := g_pref_table(i).attribute2;
               l_attribute3 := g_pref_table(i).attribute3;
               IF g_debug
               THEN
                  hr_utility.trace('ABS : Time entry layout '||l_attribute1);
                  hr_utility.trace('ABS : Review layout '||l_attribute2);
                  hr_utility.trace('ABS : Confirmation layout '||l_attribute3);
               END IF;
               EXIT;
            END IF;
        END LOOP;
    END IF;

    l_attribute_type.time_attribute_id       := p_attribute_id;
    l_attribute_type.attribute_category      := 'LAYOUT';
    l_attribute_type.attribute1              := l_attribute1;
    l_attribute_type.attribute2              := l_attribute2;
    l_attribute_type.attribute3              := l_attribute3;
    l_attribute_type.bld_blk_info_type_id    := g_layout_bbit;
    l_attribute_type.bld_blk_info_type       := 'LAYOUT';
    l_attribute_type.BUILDING_BLOCK_ID       := p_bb_id;
    l_attribute_type.BUILDING_BLOCK_OVN      := p_bb_ovn;
    l_attribute_type.OBJECT_VERSION_NUMBER   := 1;

    RETURN l_attribute_type;
END get_layout_attribute;





-- Bug 8855103
-- Added the below code to handle multiple requests
-- with respect to validations.

FUNCTION get_absence_details (p_element_type_id   IN NUMBER)
RETURN NUMBER
IS

l_abs_type_id NUMBER;
l_inc_dec     VARCHAR2(2);
l_name        VARCHAR2(500);
l_uom         VARCHAR2(5);

BEGIN
    IF g_abs_id_tab.EXISTS(p_element_type_id)
    THEN
        RETURN g_abs_id_tab(p_element_type_id).abs_id;
    END IF;

    SELECT hxc.absence_attendance_type_id,
           per.increasing_or_decreasing_flag,
           pertl.name,
           per.hours_or_days
      INTO l_abs_type_id,
           l_inc_dec,
           l_name,
           l_uom
      FROM hxc_absence_type_elements hxc,
           per_absence_attendance_types per,
           per_abs_attendance_types_tl pertl
     WHERE hxc.element_type_id = p_element_type_id
       AND hxc.absence_attendance_type_id = per.absence_attendance_type_id
       AND per.absence_attendance_type_id = pertl.absence_attendance_type_id
       AND pertl.language = USERENV('LANG');

    g_abs_id_tab(p_element_type_id).abs_id := l_abs_type_id;
    g_abs_id_tab(p_element_type_id).abs_name := l_name;
    g_abs_id_tab(p_element_type_id).run_total := l_inc_dec;
    g_abs_id_tab(p_element_type_id).uom := l_uom;
    RETURN l_abs_type_id;

END get_absence_details;



FUNCTION get_absence_id(p_element_type_id  IN NUMBER)
RETURN NUMBER
IS

BEGIN
    IF g_abs_id_tab.EXISTS(p_element_type_id)
    THEN
        RETURN g_abs_id_tab(p_element_type_id).abs_id;
    ELSE
        RETURN get_absence_details(p_element_type_id);
    END IF;

END get_absence_id;



FUNCTION get_abs_running(p_element_type_id IN NUMBER)
RETURN VARCHAR2
IS

l_id   NUMBER;

BEGIN
    IF g_abs_id_tab.EXISTS(p_element_type_id)
    THEN
        RETURN g_abs_id_tab(p_element_type_id).run_total;
    ELSE
        l_id := get_absence_details(p_element_type_id);
        RETURN g_abs_id_tab(p_element_type_id).run_total;
    END IF;

END get_abs_running;




FUNCTION get_absence_name(p_element_type_id IN NUMBER)
RETURN VARCHAR2
IS

l_id   NUMBER;

BEGIN
    IF g_abs_id_tab.EXISTS(p_element_type_id)
    THEN
        RETURN g_abs_id_tab(p_element_type_id).abs_name;
    ELSE
        l_id := get_absence_details(p_element_type_id);
        RETURN g_abs_id_tab(p_element_type_id).abs_name;
    END IF;
END get_absence_name;



FUNCTION get_absence_uom(p_element_type_id IN NUMBER)
RETURN VARCHAR2
IS

l_id   NUMBER;

BEGIN
    IF g_abs_id_tab.EXISTS(p_element_type_id)
    THEN
        RETURN g_abs_id_tab(p_element_type_id).uom;
    ELSE
        l_id := get_absence_details(p_element_type_id);
        RETURN g_abs_id_tab(p_element_type_id).uom;
    END IF;
END get_absence_uom;




FUNCTION get_assignment_id (p_person_id   IN NUMBER,
                            p_start_time  IN DATE)
RETURN NUMBER
IS

  l_asg_id  NUMBER;

  CURSOR get_asg
      IS SELECT assignment_id
           FROM per_all_assignments_f
          WHERE person_id = p_person_id
            AND p_start_time BETWEEN effective_start_date
                                 AND effective_end_date;

BEGIN
       IF g_asgtab.EXISTS(p_person_id)
       THEN
          RETURN g_asgtab(p_person_id);
       ELSE
          OPEN get_asg;
          FETCH get_asg INTO l_asg_id;
          CLOSE get_asg;
          g_asgtab(p_person_id) := l_asg_id;
          RETURN l_asg_id;
       END IF;
END get_assignment_id;


-- Bug 9019114
-- New function added to populate these global
-- variables for validation.
PROCEDURE populate_globals
IS

BEGIN
     SELECT bld_blk_info_type_id
       INTO g_bld_blk_info
       FROM hxc_bld_blk_info_types
      WHERE bld_blk_info_type = 'Dummy Element Context';

     SELECT retrieval_process_id
       INTO g_bee_retrieval
       FROM hxc_retrieval_processes
     WHERE name = 'BEE Retrieval Process';

END populate_globals;

PROCEDURE is_absence_element(p_alias_value_id IN NUMBER,
                                                         p_absence_element_flag OUT NOCOPY VARCHAR2)
IS

BEGIN
  IF g_debug THEN
    hr_utility.trace('ABS> In hxc_retrieve_absences.is_absence_element');
    hr_utility.trace('ABS> p_alias_value_id ::'||p_alias_value_id);
  END IF;

  SELECT 'Y'
    INTO p_absence_element_flag
    FROM hxc_absence_type_elements
   WHERE element_type_id in ( SELECT attribute1
                                FROM hxc_alias_values
                               WHERE alias_value_id = p_alias_value_id);
  IF g_debug THEN
    hr_utility.trace('ABS> p_absence_element_flag ::'||p_absence_element_flag);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_absence_element_flag := 'N';
    IF g_debug THEN
      hr_utility.trace('ABS> In hxc_retrieve_absences.is_absence_element -- exception NO_DATA_FOUND');
      hr_utility.trace('ABS> p_absence_element_flag ::'||p_absence_element_flag);
    END IF;
  WHEN TOO_MANY_ROWS THEN
    p_absence_element_flag := 'Y';
    IF g_debug THEN
      hr_utility.trace('ABS> In hxc_retrieve_absences.is_absence_element -- exception TOO_MANY_ROWS');
      hr_utility.trace('ABS> p_absence_element_flag ::'||p_absence_element_flag);
    END IF;

END is_absence_element;


END HXC_RETRIEVE_ABSENCES;



/
