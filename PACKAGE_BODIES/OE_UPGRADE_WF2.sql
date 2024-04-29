--------------------------------------------------------
--  DDL for Package Body OE_UPGRADE_WF2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UPGRADE_WF2" as
/* $Header: OEXIUWUB.pls 120.0 2005/06/01 01:02:04 appldev noship $ */

PROCEDURE Get_Pre_Activity
(
    p_action_id	          IN     NUMBER,
    p_sequence_id             IN     NUMBER,
v_pre_activity OUT NOCOPY VARCHAR2,

v_pre_result OUT NOCOPY VARCHAR2

)

IS

BEGIN
    IF (p_sequence_id > 1) THEN

	  SELECT activity_name,activity_result
	  INTO   v_pre_activity,
		    v_pre_result
	  FROM   oe_upgrade_wf_act_map
	  WHERE  activity_seq = p_sequence_id - 1
	  AND    action_id = p_action_id;
    END IF;

END Get_Pre_Activity;


FUNCTION Get_Post_Activity
(
    p_action_id               IN     NUMBER,
    p_sequence_id             IN     NUMBER
)
RETURN VARCHAR2

IS
   r_post_activity_name   VARCHAR2(30) := NULL;

BEGIN
	 SELECT activity_name
	 INTO   r_post_activity_name
	 FROM   oe_upgrade_wf_act_map
	 WHERE  activity_seq = p_sequence_id + 1
	 AND    action_id = p_action_id;

      RETURN (r_post_activity_name);
END;

FUNCTION get_instance_id
(
    p_process_name      IN   VARCHAR2,
    p_activity_name     IN   VARCHAR2,
    p_instance_label    IN   VARCHAR2
)
RETURN number

IS

  r_instance_id    NUMBER;

BEGIN
      SELECT nvl(instance_id, -1)
      INTO   r_instance_id
      FROM   wf_process_activities
      WHERE  process_name = p_process_name
      AND    activity_name = p_activity_name
      AND    instance_label = p_instance_label
      AND    process_version = (SELECT max(process_version)
                                FROM wf_process_activities
                                WHERE process_name = p_process_name
                                AND    activity_name = p_activity_name
                                AND    instance_label = p_instance_label);

      RETURN  (r_instance_id);

END;

PROCEDURE Insert_Into_Wf_Table
(
    p_from_instance_id  IN      NUMBER,
    p_to_instance_id    IN      NUMBER,
    p_result_code       IN      VARCHAR2,
p_level_error OUT NOCOPY NUMBER

)

IS

BEGIN
    wf_core.session_level := 20;

     /* Insert into table wf_activity_transitions */
	   BEGIN

           SELECT  'x'
           INTO   v_dummy
           FROM   wf_activity_transitions
           WHERE  from_process_activity = p_from_instance_id
           AND    result_code = p_result_code
           AND    to_process_activity = p_to_instance_id;

     EXCEPTION
	       WHEN NO_DATA_FOUND THEN
               wf_load.upload_activity_transition (
                   x_from_process_activity => p_from_instance_id,
                   x_result_code           => p_result_code,
                   x_to_process_activity   => p_to_instance_id,
                   x_protect_level         => 20,
                   x_custom_level          => 20,
                   x_arrow_geometry        => '1;0;0;0;0.30000;0,0:0,0:',
                   x_level_error           => p_level_error
                   );
     END;
END Insert_Into_Wf_Table;

PROCEDURE Get_Icon_X_value
(
    p_icon_geometry    IN  VARCHAR2,
p_x_value OUT NOCOPY NUMBER

)

IS

  flength     NUMBER := 0;
  cnt         NUMBER := 0;
  j           NUMBER := 0;
  rtn         NUMBER := 0;
  cont        VARCHAR2(1);

BEGIN

   cont := 'Y';
   flength := length(p_icon_geometry);

   WHILE cont = 'Y' AND cnt < flength + 1 LOOP

      IF substr(p_icon_geometry, cnt, 1) = ',' THEN
           j := cnt - 1;
           cont := 'N';
      END IF;

	 cnt := cnt + 1;
   END LOOP;

   IF cont = 'Y' THEN
	  j := flength;
   END IF;

   rtn := to_number(substr(p_icon_geometry, 1, j));
   p_x_value := rtn;

EXCEPTION
   WHEN others THEN
     p_x_value := 0;
End Get_Icon_X_value;

PROCEDURE Create_Process_Name
(
     p_item_type   IN   VARCHAR2,
     p_line_type   IN   VARCHAR2,
     p_cycle_id    IN   NUMBER
)

IS
     v_version         NUMBER :=1;
     v_display_name    VARCHAR2(80);
     v_process_name    VARCHAR2(80);

BEGIN

     wf_core.session_level := 20;

    BEGIN

         SELECT 'x' INTO v_dummy
         FROM   wf_activities
         WHERE  item_type = p_item_type
         AND    version   = 1
         AND    name      = 'UPG_PN_'||p_item_type||'_'||p_line_type||'_'||to_char(p_cycle_id);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            v_error_level := 2001;

            SELECT
                 'UPG_PN_'||p_item_type||'_'||p_line_type||'_'||to_char(cycle_id),
                 'UPG_PN_'||p_item_type||'_'||p_line_type||'_'||rtrim(name)
            INTO  v_process_name,
                  v_display_name
            FROM
                  so_cycles
            WHERE cycle_id = p_cycle_id
            AND   p_item_type in ('OEOH', 'OEOL');


            /* check if already inserted */

            begin
                  select 'x' into v_dummy
                  from wf_activities
                  where item_Type = P_ITEM_TYPE
                  AND   NAME = v_process_name
                  and   version = v_version;
             exception
                  when no_data_found then
                        /* Insert data into WF_ACTIVITIES */
                             wf_load.upload_activity (
                             x_item_type       =>  p_item_type,
                             x_name            =>  v_process_name,
                             x_display_name    =>  v_display_name,
                             x_description     =>  NULL,
                             x_type            =>  'PROCESS',
                             x_rerun           =>  'RESET',
                             x_protect_level   =>  20,
                             x_custom_level    =>  20,
                             x_effective_date  =>  sysdate - 1,
                             x_function        =>  null,
                             x_function_type   =>  null,
                             x_result_type     =>  '*',
                             x_cost            =>  0,
                             x_read_role       =>  null,
                             x_write_role      =>  null,
                             x_execute_role    =>  null,
                             x_icon_name       =>  'PROCESS.ICO',
                             x_message         =>  null,
                             x_error_process   =>  'RETRY_ONLY',
                             x_expand_role     =>  'N',
                             x_error_item_type =>  'WFERROR',
                             x_runnable_flag   =>  'Y',
                             x_version         =>  v_version,
                             x_level_error     =>  v_api_error_code
                               );
             end;
   END;

   V_ERROR_FLAG := 'N';
EXCEPTION
             WHEN OTHERS THEN
                 v_error_flag := 'Y';
		       v_error_code := sqlcode;
		       v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
	                                ||', Type:'||p_item_type
		                           ||' during creation of Process Name...'
			                      ||' Oracle error:'||to_char(v_error_code);

END Create_Process_Name;

/*  Description:  Inserts Lookup types using the WF API. One lookup type is
                  created per custom action.
*/

PROCEDURE Create_Lookup_Type
(
     p_item_type   IN   VARCHAR2
)
IS

	CURSOR  c1 IS
     SELECT
             'UPG_RT_'||to_char(M.action_id) lookup_type,
             ltrim(rtrim('UPG_RT_'||substr(M.name,1,26)))  display_name,
             decode(M.result_table,'SO_HEADERS','OEOH','SO_LINES','OEOL','ERROR') item_type,
             20 protect_level,
             20 custom_level,
             M.description  description
     FROM
             so_actions M,
             oe_upgrade_wf_act_map U
     WHERE  decode(M.result_table,'SO_HEADERS','OEOH',
                            'SO_LINES','OEOL','ERROR') = p_item_type
     AND    M.action_id not in
            ( SELECT name from oe_upgrade_wf_obs_codes
              WHERE  type = 'ACTION'  )
     AND    M.action_id = U.action_id(+)
     AND    U.action_id is null;

     v_lookup_type    VARCHAR2(80);

BEGIN
     -- dbms_output.enable(999999999999);
     wf_core.session_level := 20;

     FOR c2 IN c1 LOOP
          v_api_error_code := 0;

          BEGIN
	          SELECT  'x' INTO v_dummy
               FROM    wf_lookup_types
	          WHERE   lookup_type = c2.lookup_type
               OR      display_name = c2.display_name;

          EXCEPTION
               WHEN NO_DATA_FOUND THEN

                v_error_level := 2011;

                /* Insert data into WF_LOOKUP_TYPES_TL */
                wf_load.upload_lookup_type (
                   x_lookup_type    =>   c2.lookup_type,
                   x_display_name   =>   c2.display_name,
                   x_description    =>   c2.description,
                   x_protect_level  =>   c2.protect_level,
                   x_custom_level   =>   c2.custom_level,
                   x_item_type      =>   c2.item_type,
                   x_level_error    =>   v_api_error_code
               );
		END;

          v_lookup_type := c2.lookup_type;
          -- dbms_output.put_line('Completed.. '||v_lookup_type
          --                      ||' Error : '||to_char(v_api_error_code));
     END LOOP;

     V_ERROR_FLAG := 'N';
EXCEPTION
          WHEN OTHERS THEN

		    v_error_flag := 'Y';
              v_error_code := sqlcode;
              v_error_message := 'Error occured in creation of Lookup Type:'||v_lookup_type
                                 ||'... Oracle error:'||to_char(v_error_code);

END Create_Lookup_Type;



/*   Create (Result) Lookup codes for Custom Actions
     ontupg24.sql
*/

PROCEDURE Create_Lookup_Code
(
     p_item_type   IN   VARCHAR2
)
IS
     CURSOR c1 IS
     SELECT
          'UPG_RT_'||to_char(SA.action_id)  lookup_type,
          'UPG_RC_'||to_char(SR.result_id)  lookup_code,
          max(SR.name)                      meaning,
          max(20)                           protect_level,
          max(20)                           custom_level,
          max(SR.Description)               description
     FROM
          so_actions SA,
          so_action_results SAR,
          so_results SR,
          oe_upgrade_wf_act_map U
     WHERE  decode(SA.result_table,'SO_HEADERS','OEOH',
                 'SO_LINES','OEOL','ERROR') = p_item_type
     AND    SA.action_id  = SAR.action_id
     AND    SAR.result_id = SR.result_id
     AND    SR.result_id not in
             (  SELECT name from oe_upgrade_wf_obs_codes
                WHERE type = 'RESULT'    )
     AND    SA.action_id = U.action_id (+)
     AND    U.action_id is null
     GROUP BY
          'UPG_RT_'||to_char(SA.action_id),
          'UPG_RC_'||to_char(SR.result_id);

     v_lookup_type  VARCHAR2(80);
     v_lookup_code  VARCHAR2(80);

BEGIN
     -- dbms_output.enable(999999999999);
     v_api_error_code := 0;
     wf_core.session_level := 20;

     -- dbms_output.put_line('Just entered...');
     FOR  c2 IN c1   LOOP
           -- dbms_output.put_line('Entering loop..');
           v_lookup_type := c2.lookup_type;
           v_lookup_code := c2.lookup_code;

        BEGIN
           SELECT  'x' INTO v_dummy
           FROM    wf_lookups
           WHERE (   lookup_type = c2.lookup_type AND
                     lookup_code = c2.lookup_code)
           OR    (   lookup_type = c2.lookup_type AND
                     meaning     = c2.meaning);

        EXCEPTION
           WHEN NO_DATA_FOUND THEN

           v_error_level := 2021;

           /* Insert data into WF_LOOKUPS_TL */
           wf_load.upload_lookup
           (
                x_lookup_type   =>  c2.lookup_type,
                x_lookup_code   =>  c2.lookup_code,
                x_meaning       =>  c2.meaning,
                x_description   =>  c2.description,
                x_protect_level =>  c2.protect_level,
                x_custom_level  =>  c2.custom_level,
                x_level_error   =>  v_api_error_code
           );
        END;

        -- dbms_output.put_line('Completed .. '||v_lookup_type||' -- '
        --                     ||v_lookup_code||'.. Error:'||to_char(v_api_error_code));
     END LOOP;

   V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN OTHERS THEN

		  v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in creation of Lookup Type: '||v_lookup_code
                                ||'... Oracle error:'||to_char(v_error_code);

END Create_Lookup_Code;


/*===================================================================*/
-- for non seeded (custom) actions
/*===================================================================*/

PROCEDURE Create_Activity_Name
(
     p_item_type   IN   VARCHAR2
)

IS
     CURSOR c1 IS
     SELECT
          decode(result_table,'SO_HEADERS','OEOH',
                        'SO_LINES','OEOL','ERROR')           item_type,
          'UPG_AN_'||to_Char(SA.action_id)                   activity_name,
          SA.Name                                            display_name,
          1                                                  version,
          decode(sa.action_approval,'Y','NOTICE','FUNCTION') type,
          'LOOP'                                            rerun,
          'N'                                                expand_role,
          sysdate - 1                                        BEGIN_date,
          null                                               end_date,
          decode(sa.action_approval,'Y','',
              'OE_WF_UPGRADE_UTIL.UPGRADE_CUSTOM_ACTIVITY_BLOCK') function,
          'UPG_RT_'||to_Char(SA.action_id)                   result_Type,
          decode(sa.action_approval,'Y', 60, null)           cost,
          null                                               read_role,
          null                                               write_role,
          null                                               execute_role,
          decode(sa.action_approval,'Y','NOTIFY.ICO','FUNCTION.ICO') icon_name,
          decode(sa.action_approval,'Y',
                     'UPG_AN_'||to_char(sa.action_id), NULL) message,
          'RETRY_ONLY'                                       error_process,
          'WFERROR'                                          error_item_type,
          'N'                                                runnable_flag,
          null                                               function_type,
          result_column                                      result_column,
          sa.action_id                                       action_id
     FROM
          so_actions SA,
          oe_upgrade_wf_act_map U
     WHERE      SA.action_id = U.action_id(+)
     AND        U.action_id is null
     AND        SA.action_id  not in
                    (  SELECT name from oe_upgrade_wf_obs_codes
				   WHERE type = 'ACTION'    )
     AND        decode(result_table,'SO_HEADERS','OEOH',
                'SO_LINES','OEOL','ERROR')  = p_item_type
     AND        sa.action_id in (select action_id  from so_cycle_actions);

     v_message varchar2(80);
     v_name    VARCHAR2(80);
     v_version NUMBER;
     v_short_name varchar2(80);
     v_fyi_flag varchar2(1);
     v_result_type varchar2(30);

BEGIN
     -- dbms_output.enable('999999999');
     v_api_error_code      := 0;
     wf_core.session_level := 20;

     FOR c2 IN c1 LOOP

	    v_error_level := 2031;

         v_fyi_flag := 'N';
         begin
             select 'N' into v_fyi_flag from so_action_results
             where action_id = c2.action_id
             and  rownum = 1;
         exception
             when no_data_found then
                 v_fyi_flag := 'Y';
         end;

         v_name := c2.activity_name;

         if c2.item_type = 'OEOH' then
            v_short_name := 'HDR_SHORT_DESCRIPTOR';
         elsif c2.item_type = 'OEOL' then
            v_short_name := 'LIN_SHORT_DESCRIPTOR';
         end if;

         -- dbms_output.put_line('Starting : '||v_name);

         BEGIN
            SELECT 'x' INTO v_dummy
            FROM   wf_activities
            WHERE  item_type = p_item_type
            AND    version = 1
            AND    name    = c2.activity_name;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

               if v_fyi_flag = 'Y' then
                     v_result_type := '*';
               else
                     v_result_type := c2.result_Type;
               end if;

               v_error_level := 2032;
               /* Insert data into WF_ACITVITIES */
               WF_LOAD.UPLOAD_ACTIVITY  (
                     x_item_type       =>  c2.item_type,
                     x_name            =>  c2.activity_name,
                     x_display_name    =>  c2.display_name,
                     x_description     =>  c2.activity_name,
                     x_type            =>  c2.type,
                     x_rerun           =>  c2.rerun,
                     x_protect_level   =>  20,
                     x_custom_level    =>  20,
                     x_effective_date  =>  c2.BEGIN_date,
                     x_function        =>  c2.function,
                     x_function_type   =>  c2.function_type,
                     x_result_type     =>  v_result_type,
                     x_cost            =>  c2.cost,
                     x_read_role       =>  c2.read_role,
                     x_write_role      =>  c2.write_role,
                     x_execute_role    =>  c2.execute_role,
                     x_icon_name       =>  c2.icon_name,
                     x_message         =>  c2.message,
                     x_error_process   =>  c2.error_process,
                     x_expand_role     =>  c2.expand_role,
                     x_error_item_type =>  c2.error_item_type,
                     x_runnable_flag   =>  c2.runnable_flag,
                     x_version         =>  v_version,
                     x_level_error     =>  v_api_error_code
                                         );
--sam
               if c2.type <> 'NOTICE' then
                    WF_LOAD.UPLOAD_ACTIVITY_ATTRIBUTE (
                            x_activity_item_type  =>  c2.item_type,
                            x_activity_name       =>  c2.activity_name,
                            x_activity_version    =>  v_version,
                            x_name                =>  'S_COLUMN',
                            x_display_name        =>  c2.display_name||'-S_COLUMN',
                            x_description         =>  c2.display_name||'-S_COLUMN',
                            x_sequence            =>  0,
                            x_type                =>  'VARCHAR2',
                            x_protect_level       =>  20,
                            x_custom_level        =>  20,
                            x_subtype             =>  'SEND',
                            x_format              =>  '',
                            x_default             =>  c2.activity_name,
                            x_value_type          =>  'CONSTANT',
                            x_level_error         =>  v_api_error_code
                          ) ;
               else
                          Wf_Load.UPLOAD_MESSAGE (
                               x_type=>             c2.item_type,
                               x_name=>             c2.activity_name,
                               x_display_name=>     v_name,
                               x_description=>      v_name,
                               x_subject=>          c2.display_name,
                               x_body=>             '&'||v_short_name,
                               x_html_body=>        null,
                               x_protect_level=>    20,
                               x_custom_level=>     20,
                               x_default_priority=> 50,
                               x_read_role=>        null,
                               x_write_role=>       null,
                               x_level_error=>      v_api_error_code
                             );

                          Wf_Load.UPLOAD_MESSAGE_ATTRIBUTE(
                               x_message_type=>     c2.item_Type,
                               x_message_name=>     c2.activity_name,
                               x_name=>             v_short_name,
                               x_display_name=>     v_short_name,
                               x_description=>      v_short_name,
                               x_sequence=>         0,
                               x_type=>             'DOCUMENT',
                               x_subtype=>          'SEND',
                               x_protect_level=>    20,
                               x_custom_level=>     20,
                               x_format=>           '_top',
                               x_default=>          v_short_name,
                               x_value_type=>       'ITEMATTR',
                               x_attach=>           'N',
                               x_level_error=>      v_api_error_code
                             );

                         if v_fyi_flag = 'N' then
                               Wf_Load.UPLOAD_MESSAGE_ATTRIBUTE(
                                     x_message_type=>     c2.item_Type,
                                     x_message_name=>     c2.activity_name,
                                     x_name=>             'RESULT',
                                     x_display_name=>     'RESULT',
                                     x_description=>      'RESULT',
                                     x_sequence=>         1,
                                     x_type=>             'LOOKUP',
                                     x_subtype=>          'RESPOND',
                                     x_protect_level=>    20,
                                     x_custom_level=>     20,
                                     x_format=>           c2.result_Type,
                                     x_default=>          NULL,
                                     x_value_type=>       'CONSTANT',
                                     x_attach=>           'N',
                                     x_level_error=>      v_api_error_code
                                   );
                         end if;
               end if;
          END;

         -- dbms_output.put_line('Completed : '||v_name||' Error : '
	    --					||to_char(v_api_error_code)||'---'
	    --					||to_char(wf_core.session_level));
	END LOOP;

     V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN OTHERS THEN

		  v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in creation of Activity Name:'||v_name
                               ||'... Oracle error:'||to_char(v_error_code);

END Create_Activity_Name;


/*===================================================================*/
-- Create processes
-- for both seeded and custom activities
/*===================================================================*/

PROCEDURE Create_Process_Activity
(
     p_item_type              IN   VARCHAR2,
     p_cycle_id               IN   NUMBER,
     p_line_type              IN   VARCHAR2
)
IS
    CURSOR c1 IS
    SELECT
         p_item_type                                      process_item_type,
         'UPG_PN_'||p_item_type||'_'
	             ||p_line_type||'_'||to_char(p_cycle_id) process_name,
         1                                                process_version,
         nvl(oemap.activity_item_type,p_item_type)        activity_item_type,
         nvl(oemap.activity_name,
              'UPG_AN_'||to_char(soac.action_id))         activity_name,
         wf_process_activities_s.nextval                  instance_id,
         nvl(oemap.activity_name,
              'UPG_ILN_'||to_char(sca.cycle_action_id))        instance_label,

         decode(nvl(oemap.activity_name,
               'UPG_AN_'||to_char(soac.action_id)),
               'START','START','END','END',NULL)          start_end,
         decode(soac.action_approval,'Y','ITEMATTR','CONSTANT')         perform_role_type,
         decode(soac.action_approval,'Y','NOTIFICATION_APPROVER','')     perform_role,
         soac.result_column                               result_column,
         soac.action_approval                             approval
     FROM
           so_cycle_actions      sca,
           so_actions            soac,
           oe_upgrade_wf_act_map oemap
     WHERE    sca.cycle_id     = p_cycle_id
     AND      sca.action_id    = soac.action_id
     AND      sca.action_id    = oemap.action_id (+)
     AND  (  (soac.action_id in (SELECT action_id FROM oe_upgrade_wf_act_map
                           WHERE line_type in ( p_line_type , 'BOTH')) )
          OR (soac.action_id not in (SELECT action_id FROM oe_upgrade_wf_act_map )))
     AND      SOAC.action_id not in
                (  SELECT name FROM oe_upgrade_wf_obs_codes
	              WHERE type = 'ACTION'    )
     AND     (   sca.action_id in (SELECT action_id from so_action_pre_reqs)
		    OR sca.cycle_action_id in (SELECT cycle_action_id from so_action_pre_reqs))
     AND      decode(soac.result_table,'SO_HEADERS','OEOH',
                'SO_LINES','OEOL','ERROR') = p_item_type;

     v_process_name  VARCHAR2(80);
     v_activity_name VARCHAR2(80);
     v_check_duplicate_flag VARCHAR2(1);
     v_instance_label    VARCHAR2(80);
     v_instance_id NUMBER;
     v_booked_count NUMBER;
BEGIN
     -- dbms_output.enable('999999999');
     wf_core.session_level := 20;
     FOR c2 in c1  LOOP
          /*  We want to add UPG_BOOK_PROCESS_ASYNCH only if the original cycle has
              an action with a pre-req of Enter -Booked (1-1) */
          IF c2.activity_name = 'UPG_BOOK_PROCESS_ASYNCH' THEN
               SELECT count(1)
               INTO   v_booked_count
               FROM   so_action_pre_reqs
               WHERE  action_id = 1
               AND    cycle_action_id in (SELECT cycle_action_id
                                          FROM   so_cycle_actions
                                          WHERE  cycle_id = p_cycle_id)
               AND    result_id = 1;

               IF v_booked_count = 0 THEN
                    GOTO end_of_loop;
               END IF;
          END IF;
          /* end of fix */


          v_error_level := 2041;
          v_api_error_code := 0;
          v_process_name := c2.process_name;
          v_activity_name := c2.activity_name;
          -- dbms_output.put_line('Starting ..'||v_process_name ||'---'||v_activity_name);

          BEGIN
              v_check_duplicate_flag := 'N';

              SELECT 'Y' INTO v_check_duplicate_flag
              FROM wf_process_activities
              WHERE process_item_type = c2.process_item_Type
              AND   process_name      = c2.process_name
              AND   process_version   = c2.process_version
              AND   instance_label    = c2.instance_label;
          EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                  v_check_duplicate_flag := 'Y';
              WHEN NO_DATA_FOUND THEN
                  v_check_duplicate_flag := 'N';
          END;

          IF v_check_duplicate_flag = 'N' THEN

               v_error_level := 2042;
               -- dbms_output.put_line('attempting to insert:= '||c2.process_name||'**'||c2.activity_name);
               wf_load.upload_process_activity
                (
                   x_process_item_type    =>   c2.process_item_type,
                   x_process_name         =>   c2.process_name,
                   x_process_version      =>   c2.process_version,
                   x_activity_item_type   =>   c2.activity_item_type,
                   x_activity_name        =>   c2.activity_name,
                   x_instance_id          =>   c2.instance_id,
                   x_instance_label       =>   c2.instance_label,
                   x_protect_level        =>   20,
                   x_custom_level         =>   20,
                   x_start_end            =>   c2.start_end,
                   x_default_result       =>   NULL,
                   x_icon_geometry        =>   '0,0',
                   x_perform_role         =>   c2.perform_role,
                   x_perform_role_type    =>   c2.perform_role_type,
                   x_user_comment         =>   NULL,
                   x_level_error          =>   v_api_error_code
                );
               -- dbms_output.put_line('inserted := '||c2.process_name||'**'||c2.activity_name);


                if  nvl(c2.approval,'-') <> 'Y' then
                    WF_LOAD.UPLOAD_ACTIVITY_ATTR_VALUE (
                          x_process_activity_id  =>  c2.instance_id,
                          x_name                 =>  'S_COLUMN',
                          x_protect_level        =>  20,
                          x_custom_level         =>  20,
                          x_value                =>  c2.result_column,
                          x_value_type           =>  'CONSTANT',
                          x_effective_date       =>  sysdate - 1,
                          x_level_error          =>  v_api_error_code
                        );
                end if;

          ELSE
                -- dbms_output.put_line('Spared(duplicate)..'||v_process_name ||'---'||v_activity_name);
			 NULL;
          END IF;

          -- dbms_output.put_line('Complted ..'||v_process_name
          -- ||'---'||v_activity_name
          --    ||' Error code:'||to_Char(v_api_error_code));
      <<end_of_loop>>
          null;
     END LOOP;

     IF (p_item_type = 'OEOL') THEN
     BEGIN
	         SELECT 'x' INTO v_dummy
	         FROM   wf_process_activities
	         WHERE  process_name = 'UPG_PN_OEOL_'||p_line_type||'_'||to_char(p_cycle_id)
	         AND    activity_name = 'START';
     EXCEPTION
	    WHEN TOO_MANY_ROWS THEN
			null;
	    WHEN NO_DATA_FOUND THEN
                 SELECT  wf_process_activities_s.nextval
	            INTO    v_instance_id
                 FROM    dual;

	            -- dbms_output.put_line('will be loading the Pr.Act.  ');
                 v_error_level := 2142;
                 WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                      x_process_item_type   =>  p_item_type,
                      x_process_name        =>  'UPG_PN_OEOL_'||p_line_type||'_'||to_char(p_cycle_id),
                      x_process_version     =>  1,
                      x_activity_item_type  =>  'WFSTD',
                      x_activity_name       =>  'START',
                      x_instance_id         =>  v_instance_id,
                      x_instance_label      =>  'START',
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  'START',
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_code);

	             -- dbms_output.put_line('loaded the Pr.Act.  ');
     END;
     END IF;

     V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN OTHERS THEN

		  v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||', Type:'||p_item_type
                               ||' during creation of Process Activities ...'
                               ||' Oracle error:'||to_char(v_error_code);

End Create_Process_Activity;


/*
     To populate the local table oe_action_pre_reqs from so_action_pre_reqs
     This takes care of the putting an AND activitiy in the appropriate place.
*/

PROCEDURE Create_Activity_And
(
      p_item_type        IN   VARCHAR2,
	 p_line_type        IN   VARCHAR2,
	 p_cycle_id         IN   NUMBER
)
IS
     CURSOR  c1 IS
     SELECT
           spr.cycle_action_id,
           spr.action_id,
           spr.result_id,
           spr.group_number
     FROM  so_action_pre_reqs spr,
           so_cycle_actions sca,
           so_actions sa,
           so_actions sa2
     WHERE spr.cycle_action_id = sca.cycle_action_id
     AND   sca.cycle_id = p_cycle_id
     AND   spr.action_id = sa.action_id
     AND   sca.action_id = sa2.action_id
     AND   decode(sa2.result_table,'SO_HEADERS','OEOH','SO_LINES','OEOL','ERROR')=p_item_type
	AND   spr.action_id IN
		 (SELECT action_id
            FROM so_cycle_actions
		  WHERE cycle_id = p_cycle_id)
     AND   spr.cycle_action_id IN
          (SELECT cycle_action_id
           FROM so_Cycle_actions
           WHERE cycle_id = p_cycle_id)
     AND   decode(sa.result_table,'SO_HEADERS','OEOH','SO_LINES','OEOL','ERROR')=p_item_type
     AND  spr.result_id  NOT IN
          ( SELECT result_id FROM so_results, oe_upgrade_wf_obs_codes
            WHERE type ='RESULT'
            AND so_results.result_id = oe_upgrade_wf_obs_codes.name )
     AND  spr.action_id NOT IN
          ( SELECT action_id FROM so_actions a, oe_upgrade_wf_obs_codes b
            WHERE type = 'ACTION'
            AND  a.action_id = b.name )
	/*  Transition from Pick Release and Backorder Release obsoleted */
     AND  spr.action_id NOT IN (2,4)
     AND  (sa.action_id <> 3
            /* Transition from Ship confirm to Inv. Intfce. obsoleted */
		  OR (sa.action_id = 3 and sa2.action_id <> 11))
     AND  ( SPR.ACTION_ID NOT IN (2,3,4,11,16)  or
             (spr.action_id in (2,3,4,11,16) and sca.action_id not in (2,3,4,11,16)) )
     AND  (  (sa.action_id in (SELECT action_id FROM oe_upgrade_wf_act_map
                           WHERE line_type in ( p_line_type , 'BOTH')) )
          OR (sa.action_id not in (SELECT action_id FROM oe_upgrade_wf_act_map )))
     AND  (  (sa2.action_id in (SELECT action_id FROM oe_upgrade_wf_act_map
                           WHERE line_type in ( p_line_type , 'BOTH')) )
          OR (sa2.action_id not in (SELECT action_id FROM oe_upgrade_wf_act_map )))
     ORDER BY spr.cycle_action_id, spr.group_number;

     v_cycle_action_id      NUMBER;
     v_cycle_id             NUMBER;
     v_action_id            NUMBER;
     v_group_number         NUMBER;
     v_last_OR_inst_id      NUMBER;
     v_cyc_act_inst_id      NUMBER;
     v_act_inst_id          NUMBER;
     v_last_instance_id     NUMBER;
     v_process_name         VARCHAR2(30);
     v_instance_label       VARCHAR2(30);
     v_mul_rec_grp_flag     VARCHAR2(1);
     v_api_error_level      NUMBER;

BEGIN
     -- dbms_output.enable('999999999');
     -- dbms_output.put_line('Entered program');
     wf_core.session_level := 20;
     v_cycle_action_id := 0;

     FOR c2 IN c1 LOOP

         v_error_level := 2051;
         -- dbms_output.put_line('In the CURSOR..fetched grp #:'||to_char(c2.group_number));
         IF  c2.cycle_action_id  <>  v_cycle_action_id THEN
             v_cycle_action_id  := c2.cycle_action_id;

               SELECT
                   cycle_id,
                   action_id
               INTO
                   v_cycle_id,
                   v_action_id
               FROM so_cycle_actions
               WHERE cycle_action_id = v_cycle_Action_id;

               v_process_name := 'UPG_PN_'||p_item_type||'_'
							 ||p_line_type||'_'||to_char(v_cycle_id);
               v_group_number := null;

               -- dbms_output.put_line('In the stage1..process_name: '||v_process_name);
         END IF;

         BEGIN
                 -- dbms_output.put_line('In the stage 2..');

                  v_mul_rec_grp_flag := null;

                  SELECT 'Y' INTO  v_mul_rec_grp_flag
                  FROM   oe_upgrade_wf_mulgrp_v
                  WHERE  cycle_action_id = c2.cycle_action_id
                  AND    action_id       = c2.action_id;
         EXCEPTION
                  WHEN no_data_found  THEN
                       -- dbms_output.put_line('In the stage 3..');
                       v_mul_rec_grp_flag := 'N';
                  WHEN too_many_rows  THEN
                       -- dbms_output.put_line('In the stage 3.1..');
                       v_mul_rec_grp_flag := 'Y';
         END;

         IF v_mul_rec_grp_flag = 'N' THEN

               v_error_level := 2052;
               -- dbms_output.put_line('In the stage 4..');
               INSERT INTO   oe_action_pre_reqs
               (
                    cycle_action_id,
                    action_id,
                    result_id,
                    group_number,
                    cycle_id,
                    type,
                    line_type,
                    instance_label,
                    instance_id
               )
               VALUES
               (
                    c2.cycle_action_id,
                    c2.action_id,
                    c2.result_id,
                    c2.group_number,
                    v_cycle_id,
                    p_item_type,
                    p_line_type,
                    null,
                    null
               );
         ELSE

               v_error_level := 2053;
               -- dbms_output.put_line('In the stage 5..');
               IF  c2.group_number = v_group_number THEN

                     v_error_level := 2054;
                     -- dbms_output.put_line('In the stage 6..');
                     INSERT INTO oe_action_pre_reqs
                     (
                          cycle_action_id,
                          action_id,
                          result_id,
                          group_number,
                          cycle_id,
                          type,
                          line_type,
                          instance_label,
                          instance_id
                      )
                     VALUES
                     (
                          null,
                          c2.action_id,
                          c2.result_id,
                          c2.group_number,
                          v_cycle_id,
                          p_item_type,
                          p_line_type,
                          v_instance_label,
                          v_last_instance_id
                      );
               ELSE
                      v_error_level := 2055;
                      -- dbms_output.put_line('In the stage 7..');
                      v_group_number  := c2.group_number;
                      v_instance_label := 'AND_'||to_Char(v_cycle_action_id)||'_'||
                                           to_Char(v_group_number);

                      SELECT  wf_process_activities_s.nextval
                      INTO    v_last_instance_id
                      FROM    dual;

                      -- dbms_output.put_line('In the stage 7.1..');
                      -- dbms_output.put_line(v_process_name||'- 1 '||v_instance_label
			       --			||'- '||to_char(v_last_instance_id));

                      /* Insert data into WF_PROCESS_ACTIVITIES */
                      WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                           x_process_item_type   =>  p_item_type,
                           x_process_name        =>  v_process_name,
                           x_process_version     =>  1,
                           x_activity_item_type  =>  'WFSTD',
                           x_activity_name       =>  'AND',
                           x_instance_id         =>  v_last_instance_id,
                           x_instance_label      =>  v_instance_label,
                           x_protect_level       =>  20,
                           x_custom_level        =>  20,
                           x_start_end           =>  null,
                           x_default_result      =>  null,
                           x_icon_geometry       =>  '0,0',
                           x_perform_role        =>  null,
                           x_perform_role_type   =>  'CONSTANT',
                           x_user_comment        =>  null,
                           x_level_error         =>  v_api_error_level
                      );

                      -- dbms_output.put_line('In the stage 7.2  error:'
                      --           ||to_char(v_api_error_level));

                      v_error_level := 2056;
                      INSERT INTO oe_action_pre_reqs
                      (
                           cycle_action_id,
                           action_id,
                           result_id,
                           group_number,
                           cycle_id,
                           type,
                           line_type,
                           instance_label,
                           instance_id
                      )
                      values
                      (
                           c2.cycle_action_id,
                           null,
                           null,
                           c2.group_number,
                           v_cycle_id,
                           p_item_type,
                           p_line_type,
                           v_instance_label,
                           v_last_instance_id
                      );

                      v_error_level := 2057;
                      INSERT INTO oe_action_pre_reqs
                      (
                           cycle_action_id,
                           action_id,
                           result_id,
                           group_number,
                           cycle_id,
                           type,
                           line_type,
                           instance_label,
                           instance_id
                      )
                      VALUES
                      (
                           null,
                           c2.action_id,
                           c2.result_id,
                           c2.group_number,
                           v_cycle_id,
                           p_item_type,
                           p_line_type,
                           v_instance_label,
                           v_last_instance_id
                      );
               END IF;
         END IF;
         -- dbms_output.put_line('In the stage 8..');
     END LOOP;
     -- dbms_output.put_line('In the end..');

     V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN OTHERS THEN

            v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||', Type:'||p_item_type
                               ||' during creation of Activity AND...'
                               ||' Oracle error:'||to_char(v_error_code);

END Create_Activity_And;


/*============================================================================
     to create CONTINUEFLOW and WAITFORFLOW for inter type dependencies
============================================================================*/

PROCEDURE Create_Header_Line_Dependency
(
    p_cycle_id          IN    NUMBER,
    p_line_type         IN    VARCHAR2
)

IS
     v_result_table         VARCHAR2(30);
     v_action_id            NUMBER;
     v_cycle_id             NUMBER;
     v_cycle_action_id      NUMBER;
     v_hdr_process_name     VARCHAR2(80);
     v_lin_process_name     VARCHAR2(80);
     v_hdr_activity_name    VARCHAR2(80);
     v_lin_activity_name    VARCHAR2(80);
     v_api_error_code       NUMBER;
     v_check_duplicate_flag VARCHAR2(1);
     v_instance_id          NUMBER;
     v_hdr_act_instance_id  NUMBER;
     v_lin_act_instance_id  NUMBER;
     v_version              NUMBER;
     v_book_flag            VARCHAR2(1);
     v_result_id            NUMBER;
     v_start_instance_id    NUMBER;

     CURSOR c1 IS
     SELECT
            b.cycle_id,
            b.action_id lin_action_id,
            a.cycle_action_id,
            a.result_id,
            a.action_id hdr_action_id,
            a.group_number
     FROM   so_action_pre_reqs a, so_Cycle_actions b
     WHERE  b.cycle_id = p_cycle_id
     AND    ((a.action_id IN (SELECT action_id
                              FROM   oe_upgrade_wf_act_map
                              WHERE  line_type IN ( p_line_type , 'BOTH')) )
            OR (a.action_id NOT IN (SELECT action_id
                                    FROM oe_upgrade_wf_act_map )))
     AND    ((b.action_id IN (SELECT action_id
                              FROM   oe_upgrade_wf_act_map
                              WHERE  line_type IN ( p_line_type , 'BOTH')) )
            OR (b.action_id NOT IN (SELECT action_id
                                    FROM   oe_upgrade_wf_act_map )))
     AND    a.action_id IN
                  (SELECT action_id
                   FROM   so_actions
                   WHERE result_table = 'SO_HEADERS'
                   AND   (action_id = 1 or action_id not in (select action_id from oe_upgrade_wf_act_map)))
     AND    a.cycle_action_id IN
                  (SELECT cycle_action_id
                   FROM   so_cycle_actions
                   WHERE action_id in
                             (SELECT action_id
                                 FROM   so_actions
                                 WHERE  result_table = 'SO_LINES'))
     AND    a.cycle_action_id = b.cycle_action_id
     AND    a.cycle_action_id IN
                  (SELECT cycle_action_id
                   FROM   so_Cycle_actions
                   WHERE  cycle_id = p_cycle_id);

     CURSOR c3 IS
     SELECT
           pr.instance_id,
           pr.instance_label,
           pr.rowid
     FROM  oe_action_pre_reqs pr
     WHERE pr.cycle_id = v_cycle_id
     AND   pr.action_id = v_action_id
     and   pr.line_type = p_line_type   -- included 3/24/00
     FOR   UPDATE;

     CURSOR c5 IS
     SELECT
           pr.instance_id,
           pr.rowid
     FROM  oe_action_pre_reqs pr
     WHERE pr.cycle_id = v_cycle_id
     AND   pr.cycle_action_id = v_cycle_action_id
     AND   pr.line_type = p_line_type  -- included 3/24/00
     FOR   UPDATE;

BEGIN
      -- dbms_output.enable('9999999999');
      -- dbms_output.put_line('Starting Program');
     wf_core.session_level := 20;
     v_book_flag := 'N';
     FOR c2 IN c1 LOOP
          v_error_level := 2061;
           -- dbms_output.put_line('Entering INTO C2 loop');
          v_hdr_process_name     := 'UPG_PN_OEOH_REG_' || to_Char(c2.cycle_id);
          v_lin_process_name     := 'UPG_PN_OEOL_'||p_line_type||'_'||to_Char(c2.cycle_id);
          v_cycle_id             := c2.cycle_id;
          v_cycle_action_id      := c2.cycle_action_id;

          -- dbms_output.put_line('Stage D1');

          IF c2.hdr_action_id = 1 AND c2.result_id = 1 THEN
               v_hdr_activity_name := 'BOOK_CONT_L';
               v_lin_activity_name := 'BOOK_WAIT_FOR_H';
               v_book_flag := 'Y';
                -- dbms_output.put_line('Stage D2');
          ELSE
               v_hdr_activity_name := 'UPG_AN_OEOH_'||to_Char(c2.hdr_action_id)
                                       ||'_CONT_L';
               v_lin_activity_name := 'UPG_AN_OEOL_'||to_Char(c2.hdr_action_id)
                                       ||'_WAIT_FOR_H';
               v_book_flag := 'N';
                -- dbms_output.put_line('Stage D3');
          END IF;

          if c2.hdr_action_id <> 1 then  /* for custom actions only */
                 --dbms_output.put_line('Cycle: ' || to_char(p_cycle_id));
                 --dbms_output.put_line('Stage D4 - hdr action_id ' || to_char(c2.hdr_action_id));
               /*  For incoporating a new activity at Header Flow */

               IF v_book_flag = 'N' THEN
                 BEGIN
                    SELECT 0 INTO v_error_level
                    FROM WF_ACTIVITIES
                    WHERE NAME = v_hdr_activity_name
                    AND   ITEM_TYPE = 'OEOH'
                    AND   VERSION = 1;
                 EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    v_error_level := 2062;
                    -- dbms_output.put_line('Stage D5');
                    wf_load.upload_activity  (
                            x_item_type       =>  'OEOH',
                            x_name            =>  v_hdr_activity_name,
                            x_display_name    =>  v_hdr_activity_name,
                            x_description     =>  NULL,
                            x_type            =>  'FUNCTION',
                            x_rerun           =>  'RESET',
                            x_protect_level   =>  20,
                            x_custom_level    =>  20,
                            x_effective_date  =>  sysdate - 1,
                            x_function        =>  'WF_STANDARD.CONTINUEFLOW',
                            x_function_type   =>  null,
                            x_result_type     =>  '*',
                            x_cost            =>  0,
                            x_read_role       =>  null,
                            x_write_role      =>  null,
                            x_execute_role    =>  null,
                            x_icon_name       =>  'FUNCTION.ICO',
                            x_message         =>  null,
                            x_error_process   =>  'RETRY_ONLY',
                            x_expand_role     =>  'N',
                            x_error_item_type =>  'WFERROR',
                            x_runnable_flag   =>  'N',
                            x_version         =>  v_version,
                            x_level_error     =>  v_api_error_code
                                             );

                    -- dbms_output.put_line('Stage D6');

                    -- dbms_output.put_line('Activity inserted--'||v_hdr_activity_name);

                    v_error_level := 2063;
                    WF_LOAD.UPLOAD_ACTIVITY_ATTRIBUTE (
                            x_activity_item_type  =>  'OEOH',
                            x_activity_name       =>  v_hdr_activity_name,
                            x_activity_version    =>  1,
                            x_name                =>  'WAITING_ACTIVITY',
                            x_display_name        =>  v_hdr_activity_name||'-WAITING_ACTIVITY',
                            x_description         =>  v_hdr_activity_name||'-WAITING_ACTIVITY',
                            x_sequence            =>  0,
                            x_type                =>  'VARCHAR2',
                            x_protect_level       =>  20,
                            x_custom_level        =>  20,
                            x_subtype             =>  'SEND',
                            x_format              =>  '',
                            x_default             =>  v_lin_activity_name,
                            x_value_type          =>  'CONSTANT',
                            x_level_error         =>  v_api_error_code
                          ) ;

                     -- dbms_output.put_line('Stage D7');
                     -- dbms_output.put_line('api error attr: ' || to_char(v_api_error_code));
                     -- dbms_output.put_line('Attribute inserted-1-'||v_hdr_activity_name||'-WAITING_ACTIVITY');
                    -- dbms_output.put_line('attempting insert-'||v_hdr_activity_name||'-WAITING_FLOW');

                    WF_LOAD.UPLOAD_ACTIVITY_ATTRIBUTE (
                            x_activity_item_type  =>  'OEOH',
                            x_activity_name       =>  v_hdr_activity_name,
                            x_activity_version    =>  1,
                            x_name                =>  'WAITING_FLOW',
                            x_display_name        =>  v_hdr_activity_name||'-WAITING_FLOW',
                            x_description         =>  v_hdr_activity_name||'-WAITING_FLOW',
                            x_sequence            =>  1,
                            x_type                =>  'LOOKUP',
                            x_protect_level       =>  20,
                            x_custom_level        =>  20,
                            x_subtype             =>  'SEND',
                            x_format              =>  'WFSTD_MASTER_DETAIL',
                            x_default             =>  'DETAIL',
                            x_value_type          =>  'CONSTANT',
                            x_level_error         =>  v_api_error_code
                         ) ;
                                 -- dbms_output.put_line('api error2: ' || to_char(v_api_error_code));

                    -- dbms_output.put_line('Stage D9');
                    -- dbms_output.put_line('Attribute inserted-2-'||v_hdr_activity_name);
                  END;
               END IF;  /*  for v_book_flag */

               BEGIN
                            v_error_level := 2065;
                            -- dbms_output.put_line('Stage D10');
                            v_check_duplicate_flag := 'N';

                            SELECT 'Y',instance_id
                            INTO
                                v_check_duplicate_flag,
                                v_instance_id
                            FROM wf_process_activities
                            WHERE process_item_type = 'OEOH'
                            AND   process_name      = v_hdr_process_name
                            AND   process_version   = 1
                            AND   activity_item_type= 'OEOH'
                            AND   activity_name     = v_hdr_activity_name;

                            -- dbms_output.put_line('Flag = Y');
                            -- dbms_output.put_line('Stage D11');
               EXCEPTION
                            WHEN TOO_MANY_ROWS THEN
                                -- dbms_output.put_line('Stage D12');
                                v_check_duplicate_flag := 'Y';
                            WHEN NO_DATA_FOUND THEN
                                v_check_duplicate_flag := 'N';
                                -- dbms_output.put_line('Stage D13');
               END;

               IF v_check_duplicate_flag = 'N' THEN

                          v_error_level := 2066;
                           -- dbms_output.put_line('Stage D15 Flag = N');
                          SELECT
                                wf_process_activities_s.nextval
                          INTO
                                v_instance_id
                          FROM dual;

                           -- dbms_output.put_line('seq okay');

                          wf_load.upload_process_activity
                          (
                             x_process_item_type    =>   'OEOH',
                             x_process_name         =>   v_hdr_process_name,
                             x_process_version      =>   1,
                             x_activity_item_type   =>   'OEOH',
                             x_activity_name        =>   v_hdr_activity_name,
                             x_instance_id          =>   v_instance_id,
                             x_instance_label       =>   v_hdr_activity_name,
                             x_protect_level        =>   20,
                             x_custom_level         =>   20,
                             x_start_end            =>   null,
                             x_default_result       =>   NULL,
                             x_icon_geometry        =>   '0,0',
                             x_perform_role         =>   NULL,
                             x_perform_role_type    =>   'CONSTANT',
                             x_user_comment         =>   NULL,
                             x_level_error          =>   v_api_error_code
                          );
                          -- dbms_output.put_line('Stage D15 -- Process Activity  inserted--'
                          --        ||v_hdr_activity_name);
               ELSE
                           -- dbms_output.put_line('Spared(duplicate)..'
                           --       ||v_hdr_process_name ||'---'||v_hdr_activity_name);
				      NULL;
               END IF;

                 -- dbms_output.put_line('Stage D17');

               v_error_level := 2067;
               WF_LOAD.UPLOAD_ACTIVITY_ATTR_VALUE (
                          x_process_activity_id  =>  v_instance_id,
                          x_name                 =>  'WAITING_ACTIVITY',
                          x_protect_level        =>  20,
                          x_custom_level         =>  20,
                          x_value                =>  v_lin_activity_name,
                          x_value_type           =>  'CONSTANT',
                          x_effective_date       =>  sysdate - 1,
                          x_level_error          =>  v_api_error_code
                        );
                -- dbms_output.put_line('Activity Attr Value inserted-1-'
                --                     ||to_char(v_instance_id));
                -- dbms_output.put_line('api error value1: ' || to_char(v_api_error_code));

               v_error_level := 2068;
               WF_LOAD.UPLOAD_ACTIVITY_ATTR_VALUE (
                          x_process_activity_id  =>  v_instance_id,
                          x_name                 =>  'WAITING_FLOW',
                          x_protect_level        =>  20,
                          x_custom_level         =>  20,
                          x_value                =>  'DETAIL',
                          x_value_type           =>  'CONSTANT',
                          x_effective_date       =>  sysdate - 1,
                          x_level_error          =>  v_api_error_code
                        );

               -- dbms_output.put_line('api error value2: ' || to_char(v_api_error_code));
               -- dbms_output.put_line('Activity Attr Value inserted-2-'||to_char(v_instance_id));
               -- dbms_output.put_line('Action Pre Req Stage 1 ');

               v_action_id    := c2.hdr_action_id;
               v_result_table := 'SO_HEADERS';

               FOR c4 IN c3 LOOP
                         v_error_level := 2069;
                          -- dbms_output.put_line('Stage D18');

                         IF c4.instance_id IS null THEN
                              -- dbms_output.put_line('Stage D19');
                              UPDATE oe_action_pre_reqs
                              SET
                                   action_id = null,
                                   result_id = null,
                                   instance_label = 'Interdependecy-Hdr',
                                   instance_id    = v_instance_id
                              WHERE rowid = c4.rowid;
                         ELSE
                              -- dbms_output.put_line('Stage D20');
                              UPDATE oe_action_pre_reqs
                              SET
                                   instance_id2 = c4.instance_id,
                                   instance_label2 = c4.instance_label,
                                   instance_id= v_instance_id,
                                   instance_label = 'Interdependecy-Hdr'
                              WHERE rowid = c4.rowid;
                         END IF;

                         -- dbms_output.put_line('Action Pre Req Stage 2 ');

               END LOOP;

               -- dbms_output.put_line('Stage D21');

               v_error_level := 2070;
               INSERT INTO oe_action_pre_reqs
               (
                    cycle_action_id,
                    action_id,
                    result_id,
                    group_number,
                    cycle_id,
                    type,
                    line_type,
                    instance_label,
                    instance_id
               )
               VALUES
               (
                    null,
                    c2.hdr_action_id,
                    c2.result_id,
                    c2.group_number,
                    c2.cycle_id,
                    'OEOH',
                    'REG',
                    'Interdependecy-Hdr',
                    v_instance_id
               );

                -- dbms_output.put_line('Stage D22');

               /*  For incoporating a new activity at Line Flow */

               IF v_book_flag = 'N' THEN
                 BEGIN
                  SELECT 0 INTO v_error_level
                  FROM WF_ACTIVITIES
                  WHERE NAME = v_lin_activity_name
                  AND   ITEM_TYPE = 'OEOL'
                  AND   VERSION = 1;
                 EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    v_error_level := 2071;
                    -- dbms_output.put_line('Stage D23');
                    wf_load.upload_activity  (
                            x_item_type       =>  'OEOL',
                            x_name            =>  v_lin_activity_name,
                            x_display_name    =>  v_lin_activity_name,
                            x_description     =>  NULL,
                            x_type            =>  'FUNCTION',
                            x_rerun           =>  'RESET',
                            x_protect_level   =>  20,
                            x_custom_level    =>  20,
                            x_effective_date  =>  sysdate - 1,
                            x_function        =>  'WF_STANDARD.WAITFORFLOW',
                            x_function_type   =>  null,
                            x_result_type     =>  '*',
                            x_cost            =>  0,
                            x_read_role       =>  null,
                            x_write_role      =>  null,
                            x_execute_role    =>  null,
                            x_icon_name       =>  'FUNCTION.ICO',
                            x_message         =>  null,
                            x_error_process   =>  'RETRY_ONLY',
                            x_expand_role     =>  'N',
                            x_error_item_type =>  'WFERROR',
                            x_runnable_flag   =>  'N',
                            x_version         =>  v_version,
                            x_level_error     =>  v_api_error_code
                    );

                    -- dbms_output.put_line('Activity Inserted --'||v_lin_activity_name);

                    v_error_level := 2072;
                    WF_LOAD.UPLOAD_ACTIVITY_ATTRIBUTE (
                            x_activity_item_type  =>  'OEOL',
                            x_activity_name       =>  v_lin_activity_name,
                            x_activity_version    =>  1,
                            x_name                =>  'CONTINUATION_ACTIVITY',
                            x_display_name        =>  v_lin_activity_name||'-CONTINUATION_ACTIVITY',
                            x_description         =>  v_lin_activity_name||'-CONTINUATION_ACTIVITY',
                            x_sequence            =>  0,
                            x_type                =>  'VARCHAR2',
                            x_protect_level       =>  20,
                            x_custom_level        =>  20,
                            x_subtype             =>  'SEND',
                            x_format              =>  '',
                            x_default             =>  v_hdr_activity_name,
                            x_value_type          =>  'CONSTANT',
                            x_level_error         =>  v_api_error_code
                          ) ;

                    -- dbms_output.put_line('Activity Attr Inserted -1-'||v_lin_activity_name);

                    v_error_level := 2073;
                    WF_LOAD.UPLOAD_ACTIVITY_ATTRIBUTE (
                            x_activity_item_type  =>  'OEOL',
                            x_activity_name       =>  v_lin_activity_name,
                            x_activity_version    =>  1,
                            x_name                =>  'CONTINUATION_FLOW',
                            x_display_name        =>  v_lin_activity_name||'-CONTINUATION_FLOW',
                            x_description         =>  v_lin_activity_name||'-CONTINUATION_FLOW',
                            x_sequence            =>  1,
                            x_type                =>  'LOOKUP',
                            x_protect_level       =>  20,
                            x_custom_level        =>  20,
                            x_subtype             =>  'SEND',
                            x_format              =>  'WFSTD_MASTER_DETAIL',
                            x_default             =>  'MASTER',
                            x_value_type          =>  'CONSTANT',
                            x_level_error         =>  v_api_error_code) ;

                    -- dbms_output.put_line('Activity Attr Inserted -2-'||v_lin_activity_name);
                   END; -- sam
               end IF;

               BEGIN
                       v_error_level := 2074;
                        -- dbms_output.put_line('Check duplicate -  002');
                       v_check_duplicate_flag := 'N';

                       SELECT 'Y',instance_id INTO v_check_duplicate_flag, v_instance_id
                       FROM wf_process_activities
                       WHERE process_item_type = 'OEOL'
                       AND   process_name      = v_lin_process_name
                       AND   process_version   = 1
                       AND   activity_item_type= 'OEOL'
                       AND   activity_name     = v_lin_activity_name;
               EXCEPTION
                       WHEN too_many_rows THEN
                           v_check_duplicate_flag := 'Y';
                       WHEN no_data_found THEN
                           v_check_duplicate_flag := 'N';
               END;

               IF v_check_duplicate_flag = 'N' THEN
                     v_error_level := 2075;
                     -- dbms_output.put_line('duplicate -  002');

                     SELECT wf_process_activities_s.nextval INTO v_instance_id FROM dual;

                     -- dbms_output.put_line('before insertion of activity:='
                     --            ||v_lin_process_name||'=='||v_lin_activity_name);

                     wf_load.upload_process_activity
                     (
                        x_process_item_type    =>   'OEOL',
                        x_process_name         =>   v_lin_process_name,
                        x_process_version      =>   1,
                        x_activity_item_type   =>   'OEOL',
                        x_activity_name        =>   v_lin_activity_name,
                        x_instance_id          =>   v_instance_id,
                        x_instance_label       =>   v_lin_activity_name,
                        x_protect_level        =>   20,
                        x_custom_level         =>   20,
                        x_start_end            =>   null,
                        x_default_result       =>   NULL,
                        x_icon_geometry        =>   '0,0',
                        x_perform_role         =>   NULL,
                        x_perform_role_type    =>   'CONSTANT',
                        x_user_comment         =>   NULL,
                        x_level_error          =>   v_api_error_code
                     );

                     -- dbms_output.put_line('Process Activity Inserted -'||to_char(v_instance_id));
               ELSE
                     -- dbms_output.put_line('Spared(duplicate)..'||v_lin_process_name
                     --                ||'---'||v_lin_activity_name);
			      NULL;
               END IF;

               v_error_level := 2076;
               WF_LOAD.UPLOAD_ACTIVITY_ATTR_VALUE (
                     x_process_activity_id  =>  v_instance_id,
                     x_name                 =>  'CONTINUATION_ACTIVITY',
                     x_protect_level        =>  20,
                     x_custom_level         =>  20,
                     x_value                =>  v_hdr_activity_name,
                     x_value_type           =>  'CONSTANT',
                     x_effective_date       =>  sysdate - 1,
                     x_level_error          =>  v_api_error_code
                   );

               -- dbms_output.put_line('Activity Attr value Inserted -1-'||v_lin_activity_name);

               v_error_level := 2077;
               WF_LOAD.UPLOAD_ACTIVITY_ATTR_VALUE (
                     x_process_activity_id  =>  v_instance_id,
                     x_name                 =>  'CONTINUATION_FLOW',
                     x_protect_level        =>  20,
                     x_custom_level         =>  20,
                     x_value                =>  'MASTER',
                     x_value_type           =>  'CONSTANT',
                     x_effective_date       =>  sysdate - 1,
                     x_level_error          =>  v_api_error_code
               );

               -- dbms_output.put_line('Activity Attr value Inserted -2-'||v_lin_activity_name);

               -- dbms_output.put_line('Pre Req stage 5 ');

               v_action_id    := c2.lin_action_id;
               v_result_table := 'SO_LINES';

               INSERT INTO oe_action_pre_reqs
               (
                    group_number,
                    cycle_id,
                    type,
                    line_type,
                    action_id,
                    instance_label,
                    instance_id
               )
               VALUES
               (
                    c2.group_number,
                    c2.cycle_id,
                    'OEOL',
                    p_line_type,
                    '-3',
                    'Interdependecy-Line',
                    v_instance_id
               );


               INSERT INTO oe_action_pre_reqs
               (
                    cycle_action_id,
                    action_id,
                    result_id,
                    group_number,
                    cycle_id,
                    type,
                    line_type,
                    instance_label,
                    instance_id
               )
               VALUES
               (
                    c2.cycle_action_id,
                    '',
                    '',
                    c2.group_number,
                    c2.cycle_id,
                    'OEOL',
                    p_line_type,
                    'Interdependecy-Line',
                    v_instance_id
               );

                -- dbms_output.put_line('Stage D28');

          else
               -- dbms_output.put_line('Handling Enter: ' || p_line_type);
               -- Create Enter activity in the line level
               -- The c2.cycle_action_ids are the Line actions, for which we need to create ENTER
               -- in the line level, and create transitions from ENTER to those line actions.
             v_result_id    := c2.result_id;
             v_action_id    := c2.lin_action_id;
             v_cycle_action_id := c2.cycle_action_id;
             IF v_result_id = 1 THEN
		begin
                    select instance_id into v_instance_id
                    from wf_process_activities
                    where process_item_type = 'OEOL'
                    and   process_version =1
                    and   process_name = v_lin_process_name
                    and   instance_label = 'ENTER';
                exception
                    when no_data_found then
                         SELECT wf_process_activities_s.nextval INTO v_instance_id FROM dual;
                         wf_load.upload_process_activity
                         (
                                  x_process_item_type    =>   'OEOL',
                                  x_process_name         =>   v_lin_process_name,
                                  x_process_version      =>   1,
                                  x_activity_item_type   =>   'OEOL',
                                  x_activity_name        =>   'ENTER',
                                  x_instance_id          =>   v_instance_id,
                                  x_instance_label       =>   'ENTER',
                                  x_protect_level        =>   20,
                                  x_custom_level         =>   20,
                                  x_start_end            =>   null,
                                  x_default_result       =>   NULL,
                                  x_icon_geometry        =>   '0,0',
                                  x_perform_role         =>   NULL,
                                  x_perform_role_type    =>   'CONSTANT',
                                  x_user_comment         =>   NULL,
                                  x_level_error          =>   v_api_error_code
                         );
                   when others then
                       null;
               end;
/*
               FOR  c6 in c5  LOOP
                    v_error_level := 2078;
                    -- dbms_output.put_line('Stage N24');

                    IF c6.instance_id IS null THEN
                         -- dbms_output.put_line('Stage N25');
                         UPDATE oe_action_pre_reqs
                         SET
                              cycle_action_id = null,
                              instance_label = 'ENTER',
                              instance_id    = v_instance_id
                         WHERE rowid = c6.rowid;
                    ELSE
                         -- dbms_output.put_line('Stage N26');
                         UPDATE oe_action_pre_reqs
                         SET
                              cycle_action_id = null,
                              instance_id2 = v_instance_id,
                              instance_label2 = 'ENTER'
                         WHERE rowid = c6.rowid;
                    END IF;

                    -- dbms_output.put_line('Pre Req stage 6 (Enter)');

               END LOOP;

               -- dbms_output.put_line('Stage N21');

               v_error_level := 3070;

               INSERT INTO oe_action_pre_reqs
               (
                    cycle_action_id,
                    action_id,
                    result_id,
                    group_number,
                    cycle_id,
                    type,
                    line_type,
                    instance_label,
                    instance_id
               )
               VALUES
               (
                    c2.cycle_action_id,
                    '',
                    '',
                    c2.group_number,
                    c2.cycle_id,
                    'OEOL',
                    p_line_Type,
                    'ENTER',
                    v_instance_id
               );
*/
--sam
               INSERT INTO oe_action_pre_reqs
               (
                    cycle_action_id,
                    action_id,
                    result_id,
                    group_number,
                    cycle_id,
                    type,
                    line_type,
                    instance_label,
                    instance_id
               )
               VALUES
               (
                    c2.cycle_action_id,
                    '',
                    '',
                    c2.group_number,
                    c2.cycle_id,
                    'OEOL',
                    p_line_Type,
                    'ENTER',
                    v_instance_id
               );


             END IF;
          end if;
     END LOOP; /* main c2 loop*/
     V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN OTHERS THEN

		  v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||' during creation of Header Line Dependency...'
                               ||' Oracle error:'||to_char(v_error_code);

END Create_Header_Line_Dependency;


/*  To incorporate ORs in the pre-requisites */

PROCEDURE Create_Activity_Or
(
	  p_item_type         IN     VARCHAR2,
	  p_line_type         IN     VARCHAR2,
	  p_cycle_id          IN     NUMBER
)

IS
     CURSOR c1 IS
     SELECT cycle_action_id, action_id, result_id, group_number, rowid
     FROM   oe_action_pre_reqs
     WHERE  cycle_action_id IS NOT null
     AND    type = p_item_type
     AND    line_type = p_line_type
     AND    cycle_action_id in
               (SELECT cycle_action_id
                FROM   oe_action_pre_reqs
                WHERE  cycle_action_id is not null
                AND    cycle_id = p_cycle_id
                GROUP BY cycle_action_id
                HAVING count(*) > 1)
     ORDER BY cycle_action_id
     FOR UPDATE;

     v_cycle_action_id  NUMBER;
     v_api_error_level  NUMBER;
     v_process_name     VARCHAR2(30);
     v_last_instance_id NUMBER;
     v_instance_label   VARCHAR2(30);
     v_cycle_id         NUMBER;
     v_count            NUMBER;
     v_activity         VARCHAR2(30);

BEGIN
     wf_core.session_level := 20;
     v_cycle_action_id  := 0;

     FOR c2 IN c1 LOOP
           v_error_level := 2081;
           -- dbms_output.put_line('Stage 1');
           BEGIN
            SELECT count(distinct group_number)
            INTO   v_count
            FROM   oe_action_pre_reqs
            WHERE  cycle_action_id = c2.cycle_action_id;
           EXCEPTION
             WHEN OTHERS THEN
                null;
           END;

           IF c2.cycle_action_id <> v_cycle_action_id  THEN   /* cycle_action_id break */

                 -- dbms_output.put_line('Stage 1');
                 v_cycle_action_id := c2.cycle_action_id;

                 SELECT
                       'UPG_PN_'||p_item_type||'_'||p_line_type||'_'||to_char(cycle_id) ,
                       decode(v_count, 1, 'AND_'||to_char(c2.cycle_action_id), 'OR_'||to_char(c2.cycle_action_id)),
                       cycle_id
                 INTO
                       v_process_name,
                       v_instance_label,
                       v_cycle_id
                 FROM  so_cycle_actions
                 WHERE cycle_action_id = c2.cycle_action_id;

                 SELECT wf_process_activities_s.nextval
                 INTO   v_last_instance_id
                 FROM   dual;

                 v_api_error_level := 0;

                 -- dbms_output.put_line('Stage 2');
                 IF v_count > 1 THEN
                     v_activity := 'OR';
                 ELSE
                     v_activity := 'AND';
                 END IF;

                 v_error_level := 2082;
                 WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                      x_process_item_type   =>  p_item_type,
                      x_process_name        =>  v_process_name,
                      x_process_version     =>  1,
                      x_activity_item_type  =>  'WFSTD',
                      x_activity_name       =>  v_activity,
                      x_instance_id         =>  v_last_instance_id,
                      x_instance_label      =>  v_instance_label,
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  null,
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_level
                 );

                 -- dbms_output.put_line('Stage 3  error: '||to_char(v_api_error_level));

                 v_error_level := 2083;
                 INSERT INTO oe_action_pre_reqs
                 (
                      cycle_action_id,
                      action_id,
                      result_id,
                      group_number,
                      cycle_id,
                      type,
                      line_type,
                      instance_label,
                      instance_id,
                      instance_label2,
                      instance_id2
                 )
                 VALUES
                 (
                      c2.cycle_action_id,
                      null,
                      null,
                      c2.group_number,
                      v_cycle_id,
                      p_item_type,
                      p_line_type,
                      v_instance_label,
                      v_last_instance_id,
                      null,
                      null
                 );

           END IF;

           UPDATE oe_action_pre_reqs
           SET cycle_action_id = null,
               instance_label2 = v_instance_label,
               instance_id2    = v_last_instance_id
           WHERE rowid = c2.rowid;
           -- dbms_output.put_line('Stage 4');
     END LOOP;
     -- dbms_output.put_line('Stage End');

     V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN OTHERS THEN

            v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||', Type:'||p_item_type
                               ||' during creation of Activity OR...'
                               ||' Oracle error:'||to_char(v_error_code);

END Create_Activity_Or;


/*=============================================================
-- Based on table oe_action_pre_reqs, link all the activities
-- into wf_activity_transition table
==============================================================*/

PROCEDURE Create_Activity_Transition
(
    p_item_type        IN   VARCHAR2,
    p_cycle_id         IN   NUMBER,
    p_line_type        IN   VARCHAR2
)

IS
    CURSOR c1 IS
	    SELECT
	          cycle_action_id,
	          action_id,
	          decode(result_id,null,'*','UPG_RC_'||to_char(result_id)) result_code,
	          cycle_id,
	          instance_id,
	          instance_id2
	    FROM  oe_action_pre_reqs
	    WHERE type = p_item_type
	    AND   cycle_id = p_cycle_id
	    AND   line_type = p_line_type;

    v_from_instance_id  NUMBER;
    v_to_instance_id    NUMBER;
    v_result_code       VARCHAR2(30);
    v_pre_result        VARCHAR2(30);
    v_pre_activity      VARCHAR2(30);
    v_post_activity     VARCHAR2(30);
    v_max_seq           NUMBER := 0;
    v_level_error       NUMBER := 0;

BEGIN
   -- dbms_output.enable('999999999999');
   FOR c2 in c1 LOOP
           -- dbms_output.put_line('Just entered INTO the C2 loop');
           -- dbms_output.put_line('c2.cycle_action_id : '||to_char(c2.cycle_action_id));
           DECLARE
              CURSOR c3 IS
              SELECT
                     a.action_id                              action_id_c3,
                     nvl(m.activity_name,'UPG_AN_'
                                ||to_char(a.action_id))       act_name_t,
                     'UPG_PN_'||p_item_type||'_'
                      ||p_line_type||'_'||to_char(p_cycle_id) proc_name,
                     nvl(m.activity_name,
                     'UPG_ILN_'||to_char(ca.cycle_action_id))        instance_label,
                     nvl(m.activity_seq, 0)                   act_seq
              FROM   so_actions a,
                     so_cycle_actions ca,
                     oe_upgrade_wf_act_map m
              WHERE  ca.cycle_id = p_cycle_id
              AND    ca.action_id = a.action_id
              AND    ca.cycle_action_id = c2.cycle_action_id
              AND    a.action_id = m.action_id(+)
              ORDER BY act_seq;

              CURSOR c5 IS
              SELECT a.action_id                           action_id_c5,
                     nvl(m.activity_name,'UPG_AN_'
                                ||to_char(a.action_id))    act_name_f,
                     nvl(m.activity_seq, 0)                act_seq,
                     nvl(m.activity_name,
                     'UPG_ILN_'||to_char(ca.cycle_action_id))     instance_label,
                     nvl(m.activity_result,c2.result_code) act_result
              FROM   so_actions a,
                     so_cycle_actions ca,
                     oe_upgrade_wf_act_map m
              WHERE  a.action_id = c2.action_id
              AND    a.action_id = ca.action_id
              AND    ca.cycle_id = p_cycle_id
              AND    a.action_id = m.action_id(+)
              ORDER BY act_seq desc;

         BEGIN
             v_error_level := 2091;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
             IF (c2.cycle_action_id is null) AND (c2.action_id is null) THEN

                   v_from_instance_id := c2.instance_id;
                   v_to_instance_id   := c2.instance_id2;
                   v_result_code      := '*';

                   v_error_level := 2092;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
                   /* Insert INTO table wf_activity_transitions */
                   oe_upgrade_wf2.insert_into_wf_table
                      ( v_from_instance_id,
                        v_to_instance_id,
                        v_result_code,
                        v_level_error
                      );
             END IF;

             v_error_level := 2093;

		   -- dbms_output.put_line('======================='||to_char(v_error_level));
		   IF (c2.cycle_action_id is not null) AND (c2.action_id is null) THEN
                   FOR c4 in c3 LOOP
                         v_error_level := 2093;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
		   -- dbms_output.put_line('#######################'||c4.act_name_t);
                         v_to_instance_id := oe_upgrade_wf2.get_instance_id
                                                  ('UPG_PN_'||p_item_type||'_'||p_line_type
                                                       ||'_'||to_char(c2.cycle_id),
                                                    c4.act_name_t,
                                                    c4.instance_label);

                         /* this activity is the first one in 'to' side on mapping table */
      	                  IF (c4.act_seq = 0 OR c4.act_seq =1) THEN
                            v_from_instance_id := c2.instance_id;
                            v_result_code := '*';
                            v_error_level := 2094;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
                         ELSE
                            v_error_level := 2095;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
		   -- dbms_output.put_line('#######################'||c4.act_seq);
                            oe_upgrade_wf2.get_pre_activity(c4.action_id_c3,c4.act_seq,
                                                           v_pre_activity,v_pre_result);

                            v_error_level := 2096;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
		   -- dbms_output.put_line('#######################'||v_pre_activity);
                            v_from_instance_id := oe_upgrade_wf2.get_instance_id
                                ('UPG_PN_'||p_item_type||'_'||p_line_type||'_'||to_char(c2.cycle_id),
                                  v_pre_activity,
                                  v_pre_activity);
					      v_result_code := v_pre_result;
                         END IF; /* get 'from_instance_id' */


                        /* Insert into table wf_activity_transitions */
                        v_error_level := 2097;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
                        -- dbms_output.put_line('************* 1 **************');
     	                 oe_upgrade_wf2.insert_into_wf_table
                            (
                                v_from_instance_id,
                                v_to_instance_id,
                                v_result_code,
                                v_level_error
                             );
                   END LOOP;
             END IF; /* cycle_action_id is null and action_id is not null */

             v_error_level := 2098;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
             IF (c2.cycle_action_id is null) AND (c2.action_id is not null) THEN
                v_error_level := 2099;
		--dbms_output.put_line('======================='||to_char(v_error_level));
                FOR c6 IN c5 LOOP
                     v_error_level := 2100;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
                     IF c6.act_seq <> 0 THEN
                        SELECT max(activity_seq)
                        INTO   v_max_seq
                        FROM   oe_upgrade_wf_act_map
                        WHERE  action_id = c6.action_id_c5;
                     END IF;

                     v_error_level := 2101;
		   -- dbms_output.put_line('======================='||to_char(v_error_level));
                   --   dbms_output.put_line('*************** = '||c2.cycle_id||'__'||c6.act_name_f || 'label:'||c6.instance_label || ' ' || p_item_type || p_line_type || to_char(c2.cycle_id));
                     v_from_instance_id := oe_upgrade_wf2.get_instance_id
			                            (  'UPG_PN_'||p_item_type||'_'||p_line_type||'_'
                                                    ||to_char(c2.cycle_id),
                                                    c6.act_name_f,
                                                    c6.instance_label
                                                    );

			         /* this activity is the last one in 'from' side on mapping table */
                     IF (c6.act_seq = 0 or c6.act_seq = v_max_seq) THEN
                           v_error_level := 2102;
		     --dbms_output.put_line('======================='||to_char(v_error_level));
                           v_to_instance_id := nvl(c2.instance_id, c2.instance_id2);
                     ELSE
                           v_error_level := 2103;
                     -- dbms_output.put_line('======================='||to_char(v_error_level));
                     -- dbms_output.put_line('*************** = '||c6.act_seq);
						v_post_activity := oe_upgrade_wf2.get_post_activity
							  (
							   c6.action_id_c5,
							   c6.act_seq
							   );

                           v_error_level := 2104;
                     -- dbms_output.put_line('======================='||to_char(v_error_level));
                     -- dbms_output.put_line('*************** = '||v_post_activity);
                           v_to_instance_id := oe_upgrade_wf2.get_instance_id
                                                           (
                                                             'UPG_PN_'||p_item_type||'_'
                                                             ||p_line_type||'_'
                                                             ||to_char(c2.cycle_id),
                                                             v_post_activity,
                                                             v_post_activity
                                                            );
                     END IF;

                     /* Insert into table wf_activity_transitions */
                     -- dbms_output.put_line('************* 2 **************');

                     v_error_level := 2105;
		     -- dbms_output.put_line('======================='||to_char(v_error_level));
				    v_result_code := c6.act_result;
				    IF (c6.act_result = c2.result_code) AND
					  (c6.act_result <> '*') THEN
					   BEGIN
                                              SELECT 'x' INTO v_dummy
                                              FROM   wf_lookups
                                              WHERE  lookup_type = 'UPG_RT_'||to_char(c6.action_id_c5)
                                              AND    lookup_code = c6.act_result;
                                           EXCEPTION
                                              WHEN NO_DATA_FOUND THEN
                                                v_result_code := '*';
                                           END;
				    END IF;

     	              oe_upgrade_wf2.insert_into_wf_table
                         (
                           v_from_instance_id,
                           v_to_instance_id,
                           v_result_code,
                           v_level_error
                         );
                END LOOP; /* for c6 in c5 ... */
             END IF; /* cycle_action_id is null and action_id is not null */

             IF (c2.cycle_action_id is not null) AND (c2.action_id is not null) THEN
               v_error_level := 2106;
               -- dbms_output.put_line('======================='||to_char(v_error_level));
               FOR c4 IN c3 LOOP
                    v_error_level := 2107;
                    -- dbms_output.put_line('======================='||to_char(v_error_level));
                    -- dbms_output.put_line('************* ????? **************'||c4.act_seq);
                       /* it's the first activity on 'to' side OR it is the custom activity */
                       IF (c4.act_seq = 0 OR c4.act_seq =1) THEN
                          v_error_level := 2108;
                          -- dbms_output.put_line('======================='||to_char(v_error_level));
                          FOR c6 IN c5 LOOP
                               IF c6.act_seq <> 0 THEN
                                    SELECT max(activity_seq)
                                    INTO   v_max_seq
                                    FROM   oe_upgrade_wf_act_map
                                    WHERE  action_id = c6.action_id_c5;
                               END IF;

                               v_error_level := 2109;
                               -- dbms_output.put_line('======================='||to_char(v_error_level));
                               -- dbms_output.put_line('======================='||c6.act_name_f);
                               v_from_instance_id := oe_upgrade_wf2.get_instance_id
                                                           (
                                                             c4.proc_name,
                                                             c6.act_name_f,
                                                             c6.instance_label
                                                            );

                               -- dbms_output.put_line('************* ????? *****'||v_from_instance_id
                               --    ||'   '||c6.act_seq);

                               v_error_level := 2110;
		               -- dbms_output.put_line('======================='||to_char(v_error_level));
                               /* it's the last activity on 'from' side */
                               IF (c6.act_seq = 0 OR c6.act_seq = v_max_seq) THEN
                                     v_error_level := 2111;
                                     -- dbms_output.put_line('======================='||to_char(v_error_level));
                                     -- dbms_output.put_line('======================='||c4.act_name_t);
                                     v_to_instance_id := oe_upgrade_wf2.get_instance_id
                                                             (
                                                               c4.proc_name,
                                                               c4.act_name_t,
                                                               c4.instance_label
                                                               );
                                     -- dbms_output.put_line('**********  last one*'||v_to_instance_id);
                               ELSE
                                     --dbms_output.put_line('c6.act_seq:' || to_char(c6.act_seq) || to_char(v_max_seq));
                                     --dbms_output.put_line('xxxx ' || c6.action_id_c5 || 'and c4 ' || c4.act_name_t);
                                     v_error_level := 2111;
		                     --dbms_output.put_line('======================='||to_char(v_error_level));
                                     v_post_activity := oe_upgrade_wf2.get_post_activity
												  (
												    c6.action_id_c5,
												    c6.act_seq
                                                               );

                                     v_error_level := 2112;
		                     --dbms_output.put_line('======================='||to_char(v_error_level));
                                     v_to_instance_id := oe_upgrade_wf2.get_instance_id
                                                            (
                                                              c4.proc_name,
                                                              v_post_activity,
                                                              v_post_activity
                                                              );

                               END IF;

                               /* Insert into table wf_activity_transitions */
                               -- dbms_output.put_line('************* 9 **************'|| to_char(c2.action_id));

                               v_error_level := 2113;
                               v_result_code := c6.act_result;
                               --dbms_output.put_line('sam: c6 result: ' || c6.act_result || '  c2 result: ' || c2.result_code);

                               IF (c6.act_result = c2.result_code) AND (c6.act_result <> '*') THEN
                                  BEGIN
                                     SELECT 'x' INTO v_dummy
                                     FROM   wf_lookups
                                     WHERE  lookup_type = 'UPG_RT_'||to_char(c6.action_id_c5)
                                     AND    lookup_code = c6.act_result;
                                  EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                         v_result_code := '*';
                                  END;
                               END IF;
                               --  dbms_output.put_line('from: ' || v_from_instance_id || 'to: ' || v_to_instance_id || ' result: ' || v_result_code);
                               oe_upgrade_wf2.insert_into_wf_table
                                               (
                                                 v_from_instance_id,
                                                 v_to_instance_id,
                                                 v_result_code,
                                                 v_level_error
                                                 );
                               --dbms_output.put_line('sam: inserted ' || to_char(v_from_instance_id) || ' to ' || v_to_instance_id || ' result ' || v_result_code);
                               --dbms_output.put_line('-------   level_error'||v_level_error);
                          END LOOP; /* for c6 in c5 ... */
                          IF (c2.action_id = -1) THEN
                              v_from_instance_id := oe_upgrade_wf2.get_instance_id
                                                    ( 'UPG_PN_'||p_item_type||'_'
                                                      || p_line_type||'_'
                                                      || to_char(c2.cycle_id),
                                                      'START',
                                                      'START'
                                                    );
                              v_to_instance_id :=  oe_upgrade_wf2.get_instance_id
                                                   (
                                                    c4.proc_name,
                                                    c4.act_name_t,
                                                    c4.instance_label
                                                   );
                              /* Insert into table wf_activity_transitions */
                              -- dbms_output.put_line('************* 5 **************');
                              v_level_error := 21133;
                              oe_upgrade_wf2.insert_into_wf_table
                                           (
                                             v_from_instance_id,
                                             v_to_instance_id,
                                             '*',
                                             v_level_error
                                            );
                          END IF;
                     ELSE
                          v_error_level := 2114;
                          /* it's not first activity on 'to' side */
			              oe_upgrade_wf2.get_pre_activity
                                            (
                                               c4.action_id_c3,
                                               c4.act_seq,
                                               v_pre_activity,
                                               v_pre_result
                                             );

                           v_error_level := 2115;
                           v_from_instance_id := oe_upgrade_wf2.get_instance_id
                                          (
                                             'UPG_PN_'||p_item_type||'_'
                                             ||p_line_type||'_'
                                             ||to_char(c2.cycle_id),
                                             v_pre_activity,
                                             v_pre_activity
                                          );

                           v_error_level := 2116;
                           v_result_code := v_pre_result;
                           v_to_instance_id := oe_upgrade_wf2.get_instance_id
                                         (
                                            c4.proc_name,
                                            c4.act_name_t,
                                            c4.instance_label
                                         );

                           v_error_level := 2117;

                           /* Insert into table wf_activity_transitions */
                           -- dbms_output.put_line('************* 5 **************');
                           oe_upgrade_wf2.insert_into_wf_table
                                           (
                                             v_from_instance_id,
                                             v_to_instance_id,
                                             v_result_code,
                                             v_level_error
                                            );


                     END IF;
	          END LOOP; /* for c4 in c3 ... */
          END IF;
      END;
   END LOOP; /* for c2 in c1 .... */

   V_ERROR_FLAG := 'N';
   --dbms_output.put_line('sam: leaving transitions');
EXCEPTION
        WHEN OTHERS THEN
            v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||', Type:'||p_item_type
                               ||' during creation of Activity Transition...'
                               ||' Oracle error:'||to_char(v_error_code);
END Create_Activity_Transition;


/* ***********************************************************************
--  If the SHIP_CONFIRM
--  If the SHIP CONFIRM(action_id = 3) exists in SO cycles,
--  The Receivables Interface(action_id = 7) will transform to
--  WF ==> UPG_FULFILLMENT_SUB and UPG_LINE_INVOICE_INTERFACE_SUB
--  Otherwise the  Receivables Interface will only become
--  WF ==> UPG_LINE_INVOICE_INTERFACE_SUB
*************************************************************************/

PROCEDURE Ship_Confirm_Adjusting
(
     p_cycle_id    IN   NUMBER,
     p_line_type   IN   VARCHAR2
)
IS

      v_instance_id          number := 0;
      v_from_instance_id     number;
      v_result_code          VARCHAR2(30);
      v_to_instance_id       number;
      v_api_error_code       number := 0;
      v_level_error          number := 0;

      cursor c1 is
      select cycle_id from so_cycles
      where cycle_id in (select cycle_id from so_cycle_actions
                         where action_id = 7)
      and   cycle_id not in (select cycle_id from so_cycle_actions
                         where action_id in (3, 13))
      and   cycle_id = p_cycle_id;

      cursor c3 is
      select from_process_activity, result_code
      from   wf_activity_transitions
      where  to_process_activity = v_instance_id;

BEGIN
      wf_core.session_level := 20;
      for c2 in c1 loop

          -- find out the instance_id for activity "UPG_FULFILLMENT_SUB"
          select instance_id into v_instance_id
          from   wf_process_activities
          where  process_name =
              'UPG_PN_OEOL_'||p_line_type||'_'||to_char(p_cycle_id)
          and    activity_name = 'UPG_FULFILLMENT_SUB'
          and    rownum = 1
          order by process_version desc;


          -- find out the post activity instance_id
          -- we know there is only 1 transition coming out of fulfillment
          -- fulfillment is a seeded upgrade activity
          select to_process_activity into v_to_instance_id
          from   wf_activity_transitions
          where  from_process_activity = v_instance_id
          and    rownum = 1;


          -- For the previous activity(s) , add the new transition
          For c4 in c3 loop

             oe_upgrade_wf2.insert_into_wf_table
             (
                c4.from_process_activity,
                v_to_instance_id,
                c4.result_code,
                v_level_error
             );
          End loop;

          -- delete from wf_process_activities
          -- the api will also delete from wf_activity_transition
         WF_LOAD.Delete_Process_Activity
         (
               p_step => v_instance_id
         );

      end loop;
      V_ERROR_FLAG := 'N';
EXCEPTION
      WHEN NO_DATA_FOUND THEN
            --dbms_output.put_line('no data found at ship confirm adjust');
            null;
      WHEN OTHERS THEN
            --dbms_output.put_line('others exception ship confirm');
            v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||' during SHIP CONFIRM adjusting ....'
                               ||' Oracle error:'||to_char(v_error_code);
END Ship_Confirm_Adjusting;


PROCEDURE ATO_Adjusting
(
     p_cycle_id    IN   NUMBER
)
IS

      v_instance_id          number := 0;
      v_from_instance_id     number;
      v_api_error_code       number := 0;
      v_level_error          number := 0;
      v_new_instance_id      number;
      v_mfg_shipping_instance_id number;
      v_cfg_shipping_instance_id number;
      v_mfg_instance_id      number;

      cursor c1 is
      select cycle_id from so_cycles
      where cycle_id in (select cycle_id from so_cycle_actions
                         where action_id = 15);
      cursor c3 is
      select to_process_activity
      from   wf_activity_transitions
      where  from_process_activity = v_instance_id;

      cursor c5 is
      select from_process_activity, result_code
      from   wf_activity_transitions
      where  to_process_activity = v_instance_id;


BEGIN
      wf_core.session_level := 20;
      for c2 in c1 loop

          -- find out the instance_id for activity "UPG_MODEL_MFG_RELEASE"
          select instance_id into v_mfg_instance_id
          from   wf_process_activities
          where  process_name =  'UPG_PN_OEOL_REG_'||to_char(p_cycle_id)
          and    activity_name = 'UPG_MODEL_MFG_RELEASE'
          and    rownum = 1
          order by process_version desc;

          -- find out the instance_id for activity "UPG_MODEL_MFG_RELEASE"
          select instance_id into v_instance_id
          from   wf_process_activities
          where  process_name =  'UPG_PN_OEOL_CFG_'||to_char(p_cycle_id)
          and    activity_name = 'UPG_MODEL_MFG_RELEASE'
          and    rownum = 1
          order by process_version desc;

          -- find out the previous activity instance_id


          -- find instance_id for shipping activity
          SELECT instance_id into v_cfg_shipping_instance_id
          from   wf_process_activities
          where  process_name =  'UPG_PN_OEOL_CFG_'||to_char(p_cycle_id)
          and    activity_name = 'UPG_SHIPPING_SUB'
          and    rownum = 1
          order by process_version desc;

          -- find instance_id for shipping activity
          SELECT instance_id into v_mfg_shipping_instance_id
          from   wf_process_activities
          where  process_name =  'UPG_PN_OEOL_REG_'||to_char(p_cycle_id)
          and    activity_name = 'UPG_SHIPPING_SUB'
          and    rownum = 1
          order by process_version desc;

          -- upload the configuration_line subprocess

          select wf_process_activities_s.nextval
          into v_new_instance_id
          from dual;

          WF_LOAD.UPLOAD_PROCESS_ACTIVITY ( x_process_item_type   =>  'OEOL',
                      x_process_name        =>  'UPG_PN_OEOL_CFG_'||to_char(p_cycle_id),
                      x_process_version     =>  1,
                      x_activity_item_type  =>  'OEOL',
                      x_activity_name       =>  'UPG_CONFIGURATION_LINE',
                      x_instance_id         =>  v_new_instance_id,
                      x_instance_label      =>  'UPG_CONFIGURATION_LINE',
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  null,
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_code
                 );

          for c6 in c5 loop
            -- insert new transition to wf_activity_transition table
            oe_upgrade_wf2.insert_into_wf_table
            (
                c6.from_process_activity,
                v_new_instance_id,
                c6.result_code,
                v_level_error
            );
          end loop;

          -- insert transition from shipping to mfg release
          oe_upgrade_wf2.insert_into_wf_table
          (
                v_mfg_shipping_instance_id,
                v_mfg_instance_id,
                'UNRESERVE',
                v_level_error
          );

          -- insert transition from shipping to config line activity
          oe_upgrade_wf2.insert_into_wf_table
          (
                v_cfg_shipping_instance_id,
                v_new_instance_id,
                'UNRESERVE',
                v_level_error
          );


          -- it may go out to multiple destinations while it should only come from 1
          -- place, as there are AND's and OR's for the inbound transition
          for c4 in c3 loop
              oe_upgrade_wf2.insert_into_wf_table
              (
                    v_new_instance_id,
                    c4.to_process_activity,
                    '*',
                    v_level_error
              );
          end loop;

          -- delete from wf_process_activities
          -- the api will also delete from wf_activity_transition
         WF_LOAD.Delete_Process_Activity
         (
               p_step => v_instance_id
         );

      end loop;

      V_ERROR_FLAG := 'N';
EXCEPTION
      WHEN NO_DATA_FOUND THEN
            null;
      WHEN OTHERS THEN
            v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||' during SHIP CONFIRM adjusting ....'
                               ||' Oracle error:'||to_char(v_error_code);
END ATO_Adjusting;


/* Generic Flow Adjusting */

PROCEDURE Generic_Flow_Adjusting
(
        p_item_type   IN VARCHAR2,
        p_cycle_id    IN NUMBER,
        p_line_type   IN VARCHAR2
)
IS
v_shipping_instance_id NUMBER;
v_rma_instance_id NUMBER;
v_and_instance_id1 NUMBER;
v_and_instance_id2 NUMBER;
v_api_error_level NUMBER:=0;
v_get_category_instance_id NUMBER;
v_start_instance_id NUMBER;
v_from_instance_id NUMBER;
v_level_error NUMBER:=0;



Cursor c1 is
select  cycle_id from so_cycles
where cycle_id in (select cycle_id from so_cycle_actions
                   where action_id in (2,3,4,11,16))
and   cycle_id in (select cycle_id from so_cycle_actions
                   where action_id = 13)
and   cycle_id = p_cycle_id;

cursor c3 is
-- find out the previous activity instance_id
 select from_process_activity, result_code
 from   wf_activity_transitions
 where  to_process_activity = v_shipping_instance_id;

-- find out the previous activity instance_id
cursor c5 is
 select from_process_activity, result_code
 from   wf_activity_transitions
 where  to_process_activity = v_rma_instance_id;

BEGIN
    wf_core.session_level := 20;
    for c2 in c1 loop

          -- find out the instance_id for activity "UPG_SHIPPING_SUB"
          select instance_id into v_shipping_instance_id
          from   wf_process_activities
          where  process_name =
              'UPG_PN_OEOL_'||p_line_type||'_'||to_char(p_cycle_id)
          and    activity_name = 'UPG_SHIPPING_SUB'
          and    rownum = 1
          order by process_version desc;



          SELECT wf_process_activities_s.nextval
          INTO   v_and_instance_id1
          FROM   dual;

          WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                      x_process_item_type   =>  'OEOL',
                      x_process_name        =>  'UPG_PN_'||p_item_type||'_'||p_line_type ||'_'||to_char(p_cycle_id),
                      x_process_version     =>  1,
                      x_activity_item_type  =>  'WFSTD',
                      x_activity_name       =>  'AND',
                      x_instance_id         =>  v_and_instance_id1,
                      x_instance_label      =>  'AND-1',
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  '',
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_level
                 );

         for c4 in c3 loop
               -- transit from previous act to AND
               oe_upgrade_wf2.insert_into_wf_table
                      ( c4.from_process_activity,
                        v_and_instance_id1,
                        c4.result_code,
                        v_level_error
                      );
               delete from wf_activity_transitions
			where from_process_activity = c4.from_process_activity
			and   to_process_activity = v_shipping_instance_id;

         end loop;

         -- transit from AND to UPG_SHIPPING_SUB
         oe_upgrade_wf2.insert_into_wf_table
                      ( v_and_instance_id1,
                        v_shipping_instance_id,
                        '*',
                        v_level_error
                      );


         -- now for the UPG_RMA_RECEIVING_SUB handling

         -- find out the instance_id for activity "UPG_RMA_RECEIVING_SUB"
          select instance_id into v_rma_instance_id
          from   wf_process_activities
          where  process_name =
              'UPG_PN_OEOL_'||p_line_type||'_'||to_char(p_cycle_id)
          and    activity_name = 'UPG_RMA_RECEIVING_SUB'
          and    rownum = 1
          order by process_version desc;



          SELECT wf_process_activities_s.nextval
          INTO   v_and_instance_id2
          FROM   dual;

          WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                      x_process_item_type   =>  'OEOL',
                      x_process_name        =>  'UPG_PN_'||p_item_type||'_'||p_line_type ||'_'||to_char(p_cycle_id),
                      x_process_version     =>  1,
                      x_activity_item_type  =>  'WFSTD',
                      x_activity_name       =>  'AND',
                      x_instance_id         =>  v_and_instance_id2,
                      x_instance_label      =>  'AND-2',
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  '',
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_level
                 );
         for c6 in c5 loop
             -- transit from previous act to AND
             oe_upgrade_wf2.insert_into_wf_table
                      ( c6.from_process_activity,
                        v_and_instance_id2,
                        c6.result_code,
                        v_level_error
                      );
             delete from wf_activity_transitions
             where from_process_activity =c6.from_process_activity
	        and   to_process_activity = v_rma_instance_id;
         end loop;

         -- transit from AND to UPG_RMA_RECEIVING_SUB
         oe_upgrade_wf2.insert_into_wf_table
                      ( v_and_instance_id2,
                        v_rma_instance_id,
                        '*',
                        v_level_error
                      );


         -- now for the util_get_line_cateogry check activity
         -- find out the instance_id for the START activity
         select instance_id into v_start_instance_id
         from   wf_process_activities
         where  process_name = 'UPG_PN_OEOL_'||p_line_type||'_'||
                               to_char(p_cycle_id)
         and    activity_name = 'START'
         and    rownum = 1
         order by process_version desc;

         SELECT wf_process_activities_s.nextval
         INTO   v_get_category_instance_id
         FROM   dual;

         WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                      x_process_item_type   =>  'OEOL',
                      x_process_name        =>  'UPG_PN_'||p_item_type||'_'||p_line_type ||'_'||to_char(p_cycle_id),
                      x_process_version     =>  1,
                      x_activity_item_type  =>  'OEOL',
                      x_activity_name       =>  'UTIL_GET_LINE_CATEGORY',
                      x_instance_id         =>  v_get_category_instance_id,
                      x_instance_label      =>  'UTIL_GET_LINE_CATEGORY',
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  '',
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_level
                 );
          -- transit from START to new activity
          oe_upgrade_wf2.insert_into_wf_table
                      ( v_start_instance_id,
                        v_get_category_instance_id,
                        '*',
                        v_level_error
                      );
          -- transit from new activity to the 2 ANDs created earlier in procedure
          oe_upgrade_wf2.insert_into_wf_table
                      ( v_get_category_instance_id,
                        v_and_instance_id1,
                        'ORDER',
                        v_level_error
                      );
          oe_upgrade_wf2.insert_into_wf_table
                      ( v_get_category_instance_id,
                        v_and_instance_id2,
                        'RETURN',
                        v_level_error
                      );
     end Loop;
EXCEPTION
WHEN NO_DATA_FOUND THEN
          null;
WHEN OTHERS THEN
          v_error_flag := 'Y';
          v_error_code := sqlcode;
          v_error_message := 'Error occured in cycle: '
                               ||', Type:'||p_item_type
                               ||' during adjusting of generic flows'
                               ||' Oracle error:'||to_char(v_error_code);
END Generic_Flow_Adjusting;


/* Create default transition to itself if there is result code that has no transition - for Custom activity  */

PROCEDURE Create_Default_Transition
(
	 p_item_type         IN    VARCHAR2,
	 p_line_type         IN    VARCHAR2,
	 p_cycle_id          IN    NUMBER
)

IS
-- cursor c1 selects those activities do not have a default transition
      CURSOR c1 IS
      SELECT b.process_item_type,b.process_name,b.activity_name, t.from_process_activity
      FROM   wf_activity_transitions t, wf_process_activities  b
      WHERE  b.process_name = 'UPG_PN_'||p_item_type||'_'||p_line_type||'_'||to_char(p_cycle_id)
      AND    t.from_process_activity = b.instance_id
      AND    b.activity_name like 'UPG_AN%'
      AND    b.activity_name not like 'UPG_AN%WAIT_FOR_H'
      AND    b.activity_name not like 'UPG_AN%CONT_L'
      AND    b.process_version = (select max(c.process_version) from wf_process_activities c
                            where c.process_name = b.process_name
                            and   c.activity_name = b.activity_name )
      AND    t.from_process_activity not in
                 (
                  SELECT from_process_activity
                  FROM   wf_activity_transitions
                  WHERE  result_code = '*'
		  )
      GROUP BY b.process_item_type,b.process_name, b.activity_name,t.from_process_activity;

      v_lookup_count    NUMBER;
      v_transitions     NUMBER;
      v_level_error     NUMBER := 0;
      v_and_upg_close_instance_id NUMBER;
      v_api_error_code NUMBER;
      v_instance_id    NUMBER;

BEGIN
      wf_core.session_level := 20;
	 FOR c2 in c1 LOOP
                v_error_level := 2131;
                /* Insert into transtion table */
                SELECT count(distinct result_code)
			 INTO v_transitions
                FROM wf_activity_transitions
                WHERE from_process_activity = c2.from_process_activity;

                IF v_transitions = 0 THEN -- no transitions exists, take it to the 'AND' b4 close
                      SELECT t.from_process_activity
                      INTO v_and_upg_close_instance_id
                      FROM  wf_activity_transitions t, wf_process_activities  b
                      WHERE b.process_name = 'UPG_PN_'||p_item_type||'_'||p_line_type||'_'
                                             ||to_char(p_cycle_id)
                      AND b.activity_name = 'UPG_CLOSE_' || decode(p_item_type, 'OEOH',
                                             'HEADER', 'OEOL', 'LINE', '') || '_PROCESS'
                      AND b.process_version = (select max(c.process_version)
                                               from wf_process_activities c
                                               where c.process_name = b.process_name
                                               and   c.activity_name = b.activity_name )
                      AND t.to_process_activity = b.instance_id;


                      oe_upgrade_wf2.insert_into_wf_table
                       (
                                  c2.from_process_activity,
                                  v_and_upg_close_instance_id,
                                  '*',
                                  v_level_error
                        );
                 ELSE
                     SELECT count(*)
                     INTO v_lookup_count
                     FROM wf_lookups
                     WHERE lookup_type =  (SELECT result_type
                                     FROM wf_activities
                                     WHERE name = c2.activity_name
                                     AND item_type = p_item_type
                                     AND rownum = 1);


                     IF v_transitions < v_lookup_count THEN -- some transitions are missing
                        SELECT wf_process_activities_s.nextval
                        INTO v_instance_id
                        FROM dual;

                        wf_load.upload_process_activity
                          (
                             x_process_item_type    =>   p_item_type,
                             x_process_name         =>   'UPG_PN_' || p_item_type || '_' || p_line_type || '_' || to_char(p_cycle_id),
                             x_process_version      =>   1,
                             x_activity_item_type   =>   'WFSTD',
                             x_activity_name        =>   'WAIT',
                             x_instance_id          =>   v_instance_id,
                             x_instance_label       =>   'WAIT_'||to_char(v_instance_id),
                             x_protect_level        =>   20,
                             x_custom_level         =>   20,
                             x_start_end            =>   NULL,
                             x_default_result       =>   NULL,
                             x_icon_geometry        =>   '0,0',
                             x_perform_role         =>   NULL,
                             x_perform_role_type    =>   'CONSTANT',
                             x_user_comment         =>   NULL,
                             x_level_error          =>   v_api_error_code
                          );
                         wf_load.upload_activity_attr_value
                          (
                             x_process_activity_id  =>  v_instance_id,
                             x_name                 =>  'WAIT_MODE',
                             x_protect_level        =>  20,
                             x_custom_level         =>  20,
                             x_value                =>  'RELATIVE',
                             x_value_type           =>  'CONSTANT',
                             x_effective_date       =>  sysdate - 1,
                             x_level_error          =>  v_api_error_code
                          );
                         wf_load.upload_activity_attr_value
                          (
                             x_process_activity_id  =>  v_instance_id,
                             x_name                 =>  'WAIT_RELATIVE_TIME',
                             x_protect_level        =>  20,
                             x_custom_level         =>  20,
                             x_value                =>  1,
                             x_value_type           =>  'CONSTANT',
                             x_effective_date       =>  sysdate - 1,
                             x_level_error          =>  v_api_error_code
                          );

                        oe_upgrade_wf2.insert_into_wf_table
                        (
                                  c2.from_process_activity,
                                  v_instance_id,
                                  '*',
                                  v_level_error
                        );
                        oe_upgrade_wf2.insert_into_wf_table
                        (
                                  v_instance_id,
                                  c2.from_process_activity,
                                  '*',
                                  v_level_error
                        );
                     END IF;
                 END IF;
      END LOOP;

      V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN

          v_error_flag := 'Y';
          v_error_code := sqlcode;
          v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||', Type:'||p_item_type
                               ||' during creation of Default Transition...'
                               ||' Oracle error:'||to_char(v_error_code);
END Create_Default_Transition;


/* connect  'START' to all 'open start' in line level only*/

PROCEDURE Create_Line_Start
(
    p_cycle_id     IN     NUMBER,
    p_line_type    IN     VARCHAR2
)

IS
      CURSOR c1 IS
            SELECT distinct from_process_activity
            FROM   wf_activity_transitions
            WHERE  from_process_activity IN
                     (
                      SELECT instance_id
                      FROM   wf_process_activities
                      WHERE  process_name = 'UPG_PN_OEOL_'||p_line_type
					||'_'||to_char(p_cycle_id)
                      AND    activity_name <> 'START'
                     )
            AND   from_process_activity NOT IN
                     (
                      SELECT to_process_activity
                      FROM   wf_activity_transitions a,
                             wf_process_activities b
                      WHERE  a.to_process_activity = b.instance_id
                      AND    b.process_name  = 'UPG_PN_OEOL_'||p_line_type
									   ||'_'||to_char(p_cycle_id)
                      AND a.from_process_activity <> a.to_process_activity
                     );


            v_instance_id     NUMBER := 0;
            v_level_error     NUMBER := 0;

BEGIN
	 -- dbms_output.enable('9999999999');

      wf_core.session_level := 20;
	 -- dbms_output.put_line('Entered program');

      v_instance_id := oe_upgrade_wf2.get_instance_id
                                                  ('UPG_PN_OEOL'||'_'||p_line_type
                                                       ||'_'||to_char(p_cycle_id),
                                                    'START',
                                                    'START');
      FOR c2 in c1 LOOP

	    v_error_level := 2143;
         /* Insert into transtion table  */
         oe_upgrade_wf2.insert_into_wf_table
               (
		  v_instance_id,
                 c2.from_process_activity,
                 '*',
                 v_level_error
               );

	    -- dbms_output.put_line('inserted trans');
      END LOOP;

      V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN OTHERS THEN

            v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||' during creation of Open Line Start...'
                               ||' Oracle error:'||to_char(v_error_code);
END Create_Line_Start;

PROCEDURE Wait_Flow_Adjusting
(
   p_item_type IN VARCHAR2,
   p_cycle_id  IN NUMBER,
   p_line_type IN VARCHAR2
)
IS

v_delete_wait_instance   NUMBER;
v_continue_line_flow_label  VARCHAR2(30);
v_cont_act_instance_id   NUMBER;
v_tmp                    NUMBER;

Cursor c1 is
  SELECT a.instance_id, a.instance_label, attr_value1.text_value
  FROM wf_process_activities a, wf_process_activities b,
       wf_activity_attr_values attr_value1, wf_activity_attr_values attr_value2
  WHERE a.process_name = 'UPG_PN_'||p_item_type||'_'||p_line_type||'_'||to_char(p_cycle_id)
  AND   a.process_name = b.process_name
  AND   a.activity_name like 'UPG_AN_OEOL_%WAIT_FOR_H'
  AND   b.activity_name like 'UPG_AN_OEOL_%WAIT_FOR_H'
  AND   a.instance_id <> b.instance_id
  AND   attr_value1.name = 'CONTINUATION_ACTIVITY'
  AND   attr_value1.process_activity_id = a.instance_id
  AND   attr_value2.name = 'CONTINUATION_ACTIVITY'
  AND   attr_value2.process_activity_id = b.instance_id
  AND   attr_value1.text_value = attr_value2.text_value;

Cursor c3 is
  SELECT from_process_activity, result_code
  FROM wf_activity_transitions
  WHERE to_process_activity = v_delete_wait_instance;

Cursor c5 is
  SELECT to_process_activity, result_code
  FROM wf_activity_transitions
  WHERE from_process_activity = v_delete_wait_instance;



BEGIN
   for c2 in c1 loop
       -- dbms_output.put_line('In wait_flow_adjusting:  '  || c2.text_value);
        SELECT attr_value.text_value
        INTO   v_continue_line_flow_label
        FROM   wf_process_activities a, wf_activity_attr_values attr_value
        WHERE  a.instance_label = c2.text_value
        AND    a.process_name = 'UPG_PN_OEOH_REG_'||to_char(p_cycle_id)
        AND    attr_value.process_activity_id = a.instance_id
        AND    attr_value.name = 'WAITING_ACTIVITY';


        IF c2.instance_label <> v_continue_line_flow_label THEN -- adjust
             SELECT instance_id
             INTO   v_cont_act_instance_id
             FROM   wf_process_activities
             WHERE  instance_label=v_continue_line_flow_label
             AND    process_name = 'UPG_PN_'||p_item_type||'_'||p_line_type||'_'||to_char(p_cycle_id);

             v_delete_wait_instance := c2.instance_id;
             -- adjust all incoming transitions to point to the AND before the central WAIT activity
             for c4 in c3 loop
               BEGIN
                 SELECT  1
                 INTO    v_tmp
                 FROM    wf_activity_transitions
                 WHERE   from_process_activity = c4.from_process_activity
                 AND     to_process_activity = v_cont_act_instance_id
                 AND     result_code = c4.result_code;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   update wf_activity_transitions
                   set    to_process_activity = v_cont_act_instance_id
                   where  from_process_activity = c4.from_process_activity
                   and    to_process_activity = v_delete_wait_instance;
               END;
             end loop;
             -- adjust all the outgoing transitions to originate from the central WAIT activity
             -- dbms_output.put_line('in wait_flow_adjusting3');
             for c6 in c5 loop
               BEGIN
                 SELECT  1
                 INTO    v_tmp
                 FROM    wf_activity_transitions
                 WHERE   from_process_activity = v_cont_act_instance_id
                 AND     to_process_activity = c6.to_process_activity
                 AND     result_code = c6.result_code;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   update wf_activity_transitions
                   set    from_process_activity = v_cont_act_instance_id
                   where  from_process_activity = v_delete_wait_instance
                   and    to_process_activity = c6.to_process_activity;
               END;
             end loop;
             -- delete the extra WAIT
             WF_LOAD.Delete_Process_Activity(p_step=> v_delete_wait_instance);
         END IF;
    end loop;
END Wait_Flow_Adjusting;


/* Fix Geometry coordinates */

PROCEDURE Adjust_Arrow_Geometry
(
	 p_item_type           IN      VARCHAR2,
	 p_line_type           IN      VARCHAR2,
	 p_cycle_id            IN      NUMBER
)

IS

	 CURSOR c1 IS
	 SELECT max(wpa2.icon_geometry)  icon,
		   wpa.instance_id          id
	 FROM   wf_activity_transitions  wat,
             wf_process_activities    wpa,
		   wf_process_activities    wpa2
      WHERE  wat.to_process_activity = wpa.instance_id
      AND    wpa.process_name = 'UPG_PN_'||p_item_type||'_'
						   ||p_line_type||'_'||to_char(p_cycle_id)
	 AND    wpa.icon_geometry = '0,0'
	 AND    wat.from_process_activity = wpa2.instance_id
	 AND    wpa2.icon_geometry <> '0,0'
      GROUP BY wpa.instance_id;

	 CURSOR c3 IS
	 SELECT icon_geometry icon
	 FROM   wf_process_activities
      WHERE  process_name = 'UPG_PN_'||p_item_type||'_'
					    ||p_line_type||'_'||to_char(p_cycle_id)
	 GROUP BY icon_geometry
	 HAVING count(icon_geometry) > 1;

      CURSOR c7 IS
      SELECT a.icon_geometry icon_from,
		   a.instance_id   from_id,
		   b.icon_geometry icon_to,
		   b.instance_id   to_id
      FROM   wf_process_activities a,
             wf_process_activities b,
             wf_activity_transitions c
      WHERE  a.instance_id = c.from_process_activity
      AND    b.instance_id = c.to_process_activity
      AND    a.process_name = 'UPG_PN_'||p_item_type||'_'
                               ||p_line_type||'_'||to_char(p_cycle_id);

      v_icon_row       NUMBER;
      v_icon_row_char  VARCHAR2(80);
      v_flag           VARCHAR2(1) := 'Y';
      v_icon_x_value   NUMBER;


BEGIN
     -- dbms_output.enable('999999999');

     UPDATE wf_process_activities
     SET    icon_geometry = '-312,0'
     WHERE  activity_name = 'START'
     and    process_name like 'UPG_PN%'
     and    icon_geometry = '0,0';

     BEGIN
         wf_core.session_level := 20;
         -- dbms_output.put_line('Entered into c1');

         v_error_level := 2151;
         WHILE  v_flag = 'Y' LOOP
             v_flag := 'N';
             -- dbms_output.put_line('Before going into c2 loop..');

             FOR c2 IN c1 LOOP
                 v_error_level := 2152;
                 v_flag := 'Y';
                 oe_upgrade_wf2.get_icon_x_value
                                 (
                                   c2.icon,
                                   v_icon_row
                                 );

                 -- dbms_output.put_line('v_icon_row = '||to_char(v_icon_row));

			  v_error_level := 2153;
		       UPDATE wf_process_activities
		       SET    icon_geometry = to_char(v_icon_row+110)||',0'
		       WHERE  instance_id = c2.id;
	   	   END LOOP;
	    END LOOP;

      FOR c4 IN c3 LOOP
		  v_error_level := 2154;
            -- dbms_output.put_line('In c4 loop..');
	       DECLARE
		       CURSOR c5 IS
		       SELECT instance_id id
		       FROM   wf_process_activities
			  WHERE  process_name = 'UPG_PN_'||p_item_type||'_'
								||p_line_type||'_'||to_char(p_cycle_id)
		       AND    icon_geometry = c4.icon;

                 v_icon_col      NUMBER;
            BEGIN
			  v_error_level := 2155;
                 v_icon_col    := 0;
		       FOR c6 in c5 LOOP
				  v_error_level := 2156;
				  v_icon_x_value := 0;
                      oe_upgrade_wf2.get_icon_x_value
							   (
								c4.icon,
								v_icon_x_value
							   );

                      v_error_level := 2157;
                      UPDATE wf_process_activities
			       SET    icon_geometry = to_char(v_icon_x_value)||','
										   ||to_char(v_icon_col)
			       WHERE  instance_id = c6.id;

                      v_icon_col := v_icon_col + 100;
		       END LOOP;
	       END;
	    END LOOP;
      -- dbms_output.put_line('Out of c1 loop..');
     END;

     FOR c8 in c7 LOOP
        v_error_level := 2157;
	   UPDATE wf_activity_transitions
	   SET    arrow_geometry = '1;0;0;0;0.30000;'||c8.icon_from||':'||c8.icon_to||':'
	   WHERE  from_process_activity = c8.from_id
	   AND    to_process_activity   = c8.to_id;
     END LOOP;

     V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN OTHERS THEN

		  v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||', Type:'||p_item_type
                               ||' during Adjusting Arrow Geometry ...'
                               ||' Oracle error:'||to_char(v_error_code);

END Adjust_Arrow_Geometry;


/*=======================================================================
   To close the open end flows  and take them to AND before CLOSE
   To be run once, intended for both OEOH and OEOH  (Headers and Lines)
            Is rerunnable.
========================================================================*/

PROCEDURE Close_Open_End
(
	p_cycle_id            IN     NUMBER,
	p_line_type           IN     VARCHAR2,
	p_item_type           IN     VARCHAR2
)

IS
     v_end_found_flag  VARCHAR2(1);
     v_end_activity_id NUMBER;
     v_and_activity_id NUMBER;
     v_api_error_level NUMBER;

     CURSOR c1 IS
     SELECT
          to_process_activity ,
          process_name,
          process_item_type
     FROM
          wf_activity_transitions WAT,
          wf_process_activities
     WHERE
		process_name = 'UPG_PN_'||p_item_type||'_'
					 ||p_line_type||'_'||to_char(p_cycle_id)
	AND  wat.to_process_activity NOT IN
             (
			SELECT from_process_activity
			FROM   wf_activity_transitions
		   )
     AND   instance_id = to_process_activity
     AND   to_process_activity IN
             (
			SELECT instance_id
			FROM   wf_process_activities  wpa2
               WHERE  wpa2.activity_name <> 'END'
               AND    wpa2.process_name = 'UPG_PN_'||p_item_type||'_'||p_line_type
                                           ||'_'||to_char(p_cycle_id));
BEGIN
     wf_core.session_level := 20;
     FOR c2 in c1 LOOP
		  v_error_level := 2161;
            v_end_found_flag := 'N';
            BEGIN
                 SELECT
                        'Y',
                        instance_id
                 INTO
                         v_end_found_flag,
                         v_end_activity_id
                 FROM    wf_process_activities
                 WHERE   process_name = c2.process_name
                 AND     instance_label = 'AND'
                 AND     activity_name  = 'AND';
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      v_end_found_flag := 'N';
                 when TOO_MANY_ROWS THEN
                      v_end_found_flag := 'Y';
            END;

            IF v_end_found_flag = 'N' THEN
			  v_error_level := 2162;
                 SELECT wf_process_activities_s.nextval
			  INTO   v_and_activity_id
			  FROM   dual;

			  v_error_level := 2163;
                 WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                      x_process_item_type   =>  c2.process_item_type,
                      x_process_name        =>  c2.process_name,
                      x_process_version     =>  1,
                      x_activity_item_type  =>  'WFSTD',
                      x_activity_name       =>  'AND',
                      x_instance_id         =>  v_and_activity_id,
                      x_instance_label      =>  'AND',
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  '',
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_level
                 );

			  /* Create END activity */
                 WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                      x_process_item_type   =>  c2.process_item_type,
                      x_process_name        =>  c2.process_name,
                      x_process_version     =>  1,
                      x_activity_item_type  =>  'WFSTD',
                      x_activity_name       =>  'END',
                      x_instance_id         =>  v_end_activity_id,
                      x_instance_label      =>  c2.process_name||'_END',
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  'END',
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_level
                 );

		  /* Establish the relation between 'AND' and 'END'*/
            WF_LOAD.UPLOAD_ACTIVITY_TRANSITION (
                    x_from_process_activity  => v_and_activity_id,
                    x_result_code            => '*',
                    x_to_process_activity    => v_end_activity_id,
                    x_protect_level          => 20,
                    x_custom_level           => 20,
                    x_arrow_geometry         => '1;0;0;0;0.30000;0,0:0,0:',
                    x_level_error            => v_api_error_level
                 );

            END IF;

            v_error_level := 2164;
            WF_LOAD.UPLOAD_ACTIVITY_TRANSITION (
                    x_from_process_activity  => c2.to_process_activity,
                    x_result_code            => '*',
                    x_to_process_activity    => v_end_activity_id,
                    x_protect_level          => 20,
                    x_custom_level           => 20,
                    x_arrow_geometry         => '1;0;0;0;0.30000;0,0:0,0:',
                    x_level_error            => v_api_error_level
                 );
     END LOOP;

     V_ERROR_FLAG := 'N';
EXCEPTION
        WHEN OTHERS THEN

		  v_error_flag := 'Y';
            v_error_code := sqlcode;
            v_error_message := 'Error occured in cycle: ' ||to_char(p_cycle_id)
                               ||', Type:'||p_item_type
                               ||' during creation of Close Open End...'
                               ||' Oracle error:'||to_char(v_error_code);
END Close_Open_END;

PROCEDURE Upgrade_Workflow

IS

/* CURSOR c1 will filter out nocopy the unsupported order cycles

   including (in order):
1. Filter out nocopy Cycles that have NO Ship Confirm but have Inventory Interface

2. Filter out nocopy cycles have both RMA interface and Purchase release

3. Filter out nocopy cycles already processed

4. Filter out nocopy cycles that have no line actions in them

5. Filter out nocopy Cycles that have no header actions in them

6.Filter out nocopy cycles that have cancel_order(5) in them

7.Filter out nocopy cycles that have cancel_line (6)in them

THIS IS NOW DONE IN THE NEW SCRIPT
*/

    CURSOR c1 IS
    SELECT sc.cycle_id
    FROM   so_cycles sc
    WHERE    sc.cycle_id NOT IN
                (select cycle_id
                 from oe_upgrade_log
                 where (module='NU'
                 and cycle_id is not null)
			  or    (module is null
			  and cycle_id is not null))
    AND (exists (select 1
			 from so_headers_all sh
			 where sh.cycle_id = sc.cycle_id
			 and   open_flag = 'Y')
         OR exists (select 1
                from so_lines_all sl
                where sl.cycle_id = sc.cycle_id
                and   open_flag = 'Y'));

    cursor c3 is
    select cycle_id from so_cycles;

    v_error_code   NUMBER;
    v_cfg_item VARCHAR2(1) := 'N';
BEGIN
     V_ERROR_FLAG := 'N';
      --dbms_output.enable('999999999999');

      -- dbms_output.put_line('************* FLAG1 = '||v_error_flag);
	IF V_ERROR_FLAG = 'N' THEN
        OE_UPGRADE_WF2.Create_Lookup_Type('OEOH');
        COMMIT;
     END IF;

     -- dbms_output.put_line('************* FLAG2 = '||v_error_flag);
     IF V_ERROR_FLAG = 'N' THEN
        OE_UPGRADE_WF2.Create_Lookup_Type('OEOL');
        COMMIT;
     END IF;

     -- dbms_output.put_line('************* FLAG3 = '||v_error_flag);
     IF V_ERROR_FLAG = 'N' THEN
        OE_UPGRADE_WF2.Create_Lookup_Code('OEOH');
        COMMIT;
     END IF;

     -- dbms_output.put_line('************* FLAG4 = '||v_error_flag);
     IF V_ERROR_FLAG = 'N' THEN
        OE_UPGRADE_WF2.Create_Lookup_Code('OEOL');
        COMMIT;
     END IF;

     -- dbms_output.put_line('************* FLAG5 = '||v_error_flag);
     IF V_ERROR_FLAG = 'N' THEN
         OE_UPGRADE_WF2.Create_activity_name('OEOH');
         COMMIT;
     END IF;

     -- dbms_output.put_line('************* FLAG6 = '||v_error_flag);
     IF V_ERROR_FLAG = 'N' THEN
         OE_UPGRADE_WF2.Create_activity_name('OEOL');
         COMMIT;
     END IF;

     for c4 in c3 loop
        --dbms_output.put_line('************* FLAG10 = '||v_error_flag);
        IF V_ERROR_FLAG = 'N' THEN
             OE_UPGRADE_WF2.Create_process_name ('OEOH','REG',c4.cycle_id);
        END IF;

        --dbms_output.put_line('************* FLAG11 = '||v_error_flag);
        IF V_ERROR_FLAG = 'N' THEN
             OE_UPGRADE_WF2.Create_process_name ('OEOL','REG',c4.cycle_id);
        END IF;
        --create an additional CFG flow for ATO config item
        --action 15 is manufacturing release
        BEGIN
           SELECT 'Y'
           INTO v_cfg_item
           FROM so_cycle_actions
           WHERE action_id = 15
           AND cycle_id = c4.cycle_id;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
             v_cfg_item := 'N';
           WHEN OTHERS THEN
             v_error_flag :='Y';
             v_error_code := sqlcode;
             v_error_message := 'Error occured in cycle: ' ||to_char(c4.cycle_id)
               ||' Checking for Config line. Oracle error:'||to_char(v_error_code);
        END;
        IF v_cfg_item = 'Y' THEN
             OE_UPGRADE_WF2.Create_process_name ('OEOL','CFG',c4.cycle_id);
        END IF;
        v_cfg_item := 'N';

     end loop;

     -- MAIN LOOP STARTS

     FOR c2 IN c1 LOOP
          V_ERROR_FLAG   := 'N';
           -- dbms_output.put_line('************* FLAG11 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
               OE_UPGRADE_WF2.Create_process_activity ('OEOH',c2.cycle_id,'REG');
          END IF;

          -- dbms_output.put_line('************* FLAG12 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
               OE_UPGRADE_WF2.Create_activity_and ('OEOH','REG',c2.cycle_id);
          END IF;

          BEGIN
                    SELECT 'Y'
                    INTO v_cfg_item
                    FROM so_cycle_actions
                    WHERE action_id = 15
                    AND cycle_id = c2.cycle_id;
          EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       v_cfg_item := 'N';
                    WHEN OTHERS THEN
                       v_error_flag :='Y';
                       v_error_code := sqlcode;
                       v_error_message := 'Error occured in cycle: ' ||to_char(c2.cycle_id)
                       ||' Checking for Config line. Oracle error:'||to_char(v_error_code);
          END;
          -- dbms_output.put_line('************* FLAG14 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                   OE_UPGRADE_WF2.Create_process_activity ('OEOL',c2.cycle_id,'REG');
                   IF v_cfg_item = 'Y' THEN
                       -- dbms_output.put_line('create process activity for cfg');
                       OE_UPGRADE_WF2.Create_process_activity ('OEOL',c2.cycle_id,'CFG');
                   END IF;

          END IF;

	           -- dbms_output.put_line('************* FLAG15 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                   OE_UPGRADE_WF2.Create_activity_and ('OEOL','REG',c2.cycle_id);
                   IF v_cfg_item = 'Y' THEN
                       -- dbms_output.put_line('create activity and for cfg ' || to_char(c2.cycle_id));
                       OE_UPGRADE_WF2.Create_activity_and ('OEOL','CFG',c2.cycle_id);
                   END IF;
          END IF;

          -- -2 is for ENTERED/PARTIAL for the line action
          update oe_action_pre_reqs
          set action_id = -2
          where action_id = 1
          and   type = 'OEOL'
          and   result_id in (5, 15);

	     -- dbms_output.put_line('************* FLAG16 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
               -- dbms_output.put_line('going in dependency');
              OE_UPGRADE_WF2.Create_header_line_dependency (c2.cycle_id,'REG');
              IF v_cfg_item = 'Y' THEN
                   -- dbms_output.put_line('create dependency for cfg ' || to_char(c2.cycle_id));
                   OE_UPGRADE_WF2.Create_header_line_dependency (c2.cycle_id,'CFG');
              END IF;
          END IF;

          -- dbms_output.put_line('************* FLAG17 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
              OE_UPGRADE_WF2.Create_activity_or ('OEOH','REG',c2.cycle_id);
          END IF;

          -- dbms_output.put_line('************* FLAG18 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
             -- -1 is for ENTERED/PARTIAL for the header action
             update oe_action_pre_reqs
             set action_id = -1
             where action_id = 1
             and   type = 'OEOH'
             and   result_id in (5, 15);

             OE_UPGRADE_WF2.Create_activity_transition ('OEOH',c2.cycle_id,'REG');
          END IF;

          IF V_ERROR_FLAG = 'N' THEN
                OE_UPGRADE_WF2.Create_notification (c2.cycle_id,'REG','OEOH');
          END IF;

          -- dbms_output.put_line('************* FLAG19 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                OE_UPGRADE_WF2.Create_default_transition ('OEOH','REG',c2.cycle_id);
          END IF;

          -- dbms_output.put_line('************* FLAG20 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                OE_UPGRADE_WF2.Close_Open_End (c2.cycle_id,'REG','OEOH');
          END IF;

          -- dbms_output.put_line('************* FLAG21 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                OE_UPGRADE_WF2.Adjust_arrow_geometry ('OEOH','REG',c2.cycle_id);
          END IF;

          -- dbms_output.put_line('************* FLAG22 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                 OE_UPGRADE_WF2.Create_activity_or ('OEOL','REG',c2.cycle_id);
                 IF v_cfg_item = 'Y' THEN
                    --dbms_output.put_line('create activity or  for cfg');
                    OE_UPGRADE_WF2.Create_activity_or ('OEOL','CFG',c2.cycle_id);
                  END IF;
          END IF;



            -- dbms_output.put_line('************* FLAG23 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                 OE_UPGRADE_WF2.Create_activity_transition ('OEOL',c2.cycle_id,'REG');
                 IF v_cfg_item = 'Y' THEN
                    -- dbms_output.put_line('create activity transition  for cfg');
                    OE_UPGRADE_WF2.Create_activity_transition ('OEOL',c2.cycle_id,'CFG');
                  END IF;
          END IF;



          --dbms_output.put_line('************* FLAG23+ = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                 OE_UPGRADE_WF2.Create_notification (c2.cycle_id,'REG','OEOL');
                 IF v_cfg_item = 'Y' THEN
                     --dbms_output.put_line('create notification  for cfg');
                     OE_UPGRADE_WF2.Create_notification (c2.cycle_id,'CFG','OEOL');
                   END IF;
          END IF;

          -- dbms_output.put_line('************* FLAG24 = '||v_error_flag|| ' cycle_id:' || to_char(c2.cycle_id));
          IF V_ERROR_FLAG = 'N' THEN
                 OE_UPGRADE_WF2.Create_default_transition ('OEOL','REG',c2.cycle_id);
                 IF v_cfg_item = 'Y' THEN
                     -- dbms_output.put_line('create default end for cfg');
                     OE_UPGRADE_WF2.Create_default_transition ('OEOL','CFG',c2.cycle_id);
                   END IF;
          END IF;

          --dbms_output.put_line('************* FLAG25 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                 OE_UPGRADE_WF2.Create_line_start (c2.cycle_id,'REG');
                 IF v_cfg_item = 'Y' THEN
                     OE_UPGRADE_WF2.Create_line_start (c2.cycle_id,'CFG');
                 END IF;
          END IF;

          -- dbms_output.put_line('************* FLAG26 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                 OE_UPGRADE_WF2.Close_Open_End (c2.cycle_id,'REG','OEOL');
                 IF v_cfg_item = 'Y' THEN
                     OE_UPGRADE_WF2.Close_Open_End (c2.cycle_id,'CFG','OEOL');
                 END IF;
          END IF;

          -- dbms_output.put_line('************* FLAG26+ = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                 OE_UPGRADE_WF2.Ship_Confirm_Adjusting (c2.cycle_id,'REG');
                 IF v_cfg_item = 'Y' THEN
                     -- dbms_output.put_line('adjust ship confirm for cfg');
                     OE_UPGRADE_WF2.Ship_Confirm_Adjusting (c2.cycle_id,'CFG');
                   END IF;
          END IF;

          -- dbms_output.put_line('************* FLAG26++ = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
               IF v_cfg_item = 'Y' THEN
                 --dbms_output.put_line('adjust ato for cfg');
                 OE_UPGRADE_WF2.ATO_Adjusting (c2.cycle_id);
               END IF;
          END IF;

          -- dbms_output.put_line('************* FLAG27 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
               OE_UPGRADE_WF2.Generic_Flow_Adjusting ('OEOL', c2.cycle_id,'REG');
               IF v_cfg_item = 'Y' THEN
                 -- dbms_output.put_line('adjust ato for cfg');
                 OE_UPGRADE_WF2.Generic_Flow_Adjusting ('OEOL', c2.cycle_id,'CFG');
               END IF;
          END IF;

          -- dbms_output.put_line('************* FLAG28 = '||v_error_flag);
          -- adjust for multiple waits
          IF V_ERROR_FLAG = 'N' THEN
               OE_UPGRADE_WF2.Wait_Flow_Adjusting ('OEOL', c2.cycle_id,'REG');
               IF v_cfg_item = 'Y' THEN
                 --dbms_output.put_line('adjust ato for cfg');
                 OE_UPGRADE_WF2.Wait_Flow_Adjusting ('OEOL', c2.cycle_id,'CFG');
               END IF;
          END IF;

          -- dbms_output.put_line('************* FLAG29 = '||v_error_flag);
          IF V_ERROR_FLAG = 'N' THEN
                 OE_UPGRADE_WF2.Adjust_arrow_geometry ('OEOL','REG',c2.cycle_id);
                 IF v_cfg_item = 'Y' THEN
                     OE_UPGRADE_WF2.Adjust_arrow_geometry ('OEOL','CFG',c2.cycle_id);
                 END IF;
          END IF;



          IF V_ERROR_FLAG = 'Y' THEN
             -- dbms_output.put_line('************* FLAG30 = '||v_error_flag);
             ROLLBACK;
             INSERT INTO oe_upgrade_errors
                  (module,error_level,comments,creation_date)
             VALUES
                  ('WF',v_error_level,v_error_message,sysdate - 1);
             COMMIT;
          ELSE
             INSERT INTO oe_upgrade_log ( creation_date,cycle_id)
             VALUES (sysdate,c2.cycle_id);
             COMMIT;
          END IF;
          v_cfg_item :='N';
     END LOOP;

END Upgrade_Workflow;

Procedure Create_Notification
(
     P_cycle_id  IN Number,
     P_line_type IN varchar2,
     P_item_type IN varchar2
)
IS
     cursor c1 is
     select
          instance_id,
          wa.name,
          wa.result_type
     from
          wf_process_activities wpa,
          wf_activities wa
     where  wpa.activity_name = wa.name
     and    wpa.process_name  = 'UPG_PN_'||p_item_type||'_'||p_line_type||'_'||to_char(p_cycle_id)
     and    wa.type = 'NOTICE';

     v_notn_instance_id  number;

     cursor c3 is
     select to_process_activity, result_code
     from wf_activity_transitions
     where  from_process_activity = v_notn_instance_id;

     cursor c5 is
     select from_process_activity, result_code
     from wf_activity_transitions
     where to_process_activity = v_notn_instance_id;

     v_activity_name       varchar2(50);
     v_process_name        varchar2(50);
     v_version             number;
     v_api_error_code      number;
     v_lookup_type         varchar2(30);
     v_instance_id         number;
     v_from_instance_id    number;
     v_to_instance_id      number;
     v_or_instance_id2     number;
     v_or_instance_id      number;
     v_result_code         varchar2(30);
     v_level_error         NUMBER := 0;
     v_result_column       varchar2(30);
     v_fyi_flag            varchar2(1);
     v_action_id           number;
     v_result_code2        varchar2(30);
     v_result_type         varchar2(30);

Begin

     -- dbms_output.enable('99999999999');
     v_error_flag := 'N';
     v_process_name :=  'UPG_PN_'||p_item_type||'_'||p_line_type||'_'||to_char(p_cycle_id);
     -- dbms_output.put_line('..1');
	for c2 in c1 loop
                 -- dbms_output.put_line('..2');
                 v_notn_instance_id := c2.instance_id;

                 v_activity_name := 'UPG_AN_PNOT_'||to_char(c2.instance_id);

                 begin
                      select
                            result_column,
                            action_id,
                            'UPG_RT_'||to_char(sa.action_id)
                      into
                            v_result_column,
                            v_action_id,
                            v_result_Type
                      from
                            so_actions  sa
                      where sa.action_id = to_number(substr(c2.name,8,10))
                      and   substr(c2.name,8,10) between '0000000000' and '9999999999';
                 exception
                      when others then
                           v_result_column := NULL;
                           v_action_id     := NULL;
                 end;

                 begin
                      select 'N' into v_fyi_Flag from so_action_results
                      where action_id = v_action_id
                      and   rownum = 1;
                 exception
                      when no_data_found then
                            v_fyi_flag := 'Y';
                 end;

                 -- dbms_output.put_line('..3');

                 wf_load.upload_activity  (
                       x_item_type       =>  P_item_type,
                       x_name            =>  v_activity_name,
                       x_display_name    =>  v_activity_name,
                       x_description     =>  NULL,
                       x_type            =>  'FUNCTION',
                       x_rerun           =>  'RESET',
                       x_protect_level   =>  20,
                       x_custom_level    =>  20,
                       x_effective_date  =>  sysdate,
                       x_function        =>  'OE_WF_UPGRADE_UTIL.UPGRADE_PRE_APPROVAL',
                       x_function_type   =>  null,
                       x_result_type     =>  v_result_type,
                       x_cost            =>  0,
                       x_read_role       =>  null,
                       x_write_role      =>  null,
                       x_execute_role    =>  null,
                       x_icon_name       =>  'FUNCTION.ICO',
                       x_message         =>  null,
                       x_error_process   =>  'RETRY_ONLY',
                       x_expand_role     =>  'N',
                       x_error_item_type =>  'WFERROR',
                       x_runnable_flag   =>  'N',
                       x_version         =>  v_version,
                       x_level_error     =>  v_api_error_code
                                           );

                 -- dbms_output.put_line('013');
                 WF_LOAD.UPLOAD_ACTIVITY_ATTRIBUTE (
                       x_activity_item_type  =>  P_item_type,
                       x_activity_name       =>  v_activity_name,
                       x_activity_version    =>  1,
                       x_name                =>  'S_COLUMN',
                       x_display_name        =>  v_activity_name,
                       x_description         =>  v_activity_name,
                       x_sequence            =>  0,
                       x_type                =>  'VARCHAR2',
                       x_protect_level       =>  20,
                       x_custom_level        =>  20,
                       x_subtype             =>  'SEND',
                       x_format              =>  '',
                       x_default             =>  v_result_column,
                       x_value_type          =>  'CONSTANT',
                       x_level_error         =>  v_api_error_code
                     ) ;

                -- dbms_output.put_line('023');
                wf_load.upload_lookup
                 (
                      x_lookup_type   =>  v_result_type,
                      x_lookup_code   =>  'NOT_PROCESSED',
                      x_meaning       =>  'NOT_PROCESSED_NOTN_'||c2.name,
                      x_description   =>  'Not processed - for Notification',
                      x_protect_level =>  20,
                      x_custom_level  =>  20,
                      x_level_error   =>  v_api_error_code
                 );

                 -- dbms_output.put_line('033');
                 select
                        wf_process_activities_s.nextval into v_instance_id
                 from   dual;

                 -- dbms_output.put_line('043');
                 v_api_error_code := 0;

                 -- dbms_output.put_line('Stage 2');

                 WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                      x_process_item_type   =>  p_item_type,
                      x_process_name        =>  v_process_name,
                      x_process_version     =>  1,
                      x_activity_item_type  =>  p_item_type,
                      x_activity_name       =>  v_activity_name,
                      x_instance_id         =>  v_instance_id,
                      x_instance_label      =>  v_activity_name,
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  null,
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_code
                 );


                 -- dbms_output.put_line('053');
                 WF_LOAD.UPLOAD_ACTIVITY_ATTR_VALUE (
                     x_process_activity_id  =>  v_instance_id,
                     x_name                 =>  'S_COLUMN',
                     x_protect_level        =>  20,
                     x_custom_level         =>  20,
                     x_value                =>  v_result_column,
                     x_value_type           =>  'CONSTANT',
                     x_effective_date       =>  sysdate,
                     x_level_error          =>  v_api_error_code
                   );


                 -- dbms_output.put_line('063');
                 /* Insert process activity OR -  */

                 select
                        wf_process_activities_s.nextval into v_or_instance_id
                 from   dual;

                 -- dbms_output.put_line('073');
                 v_activity_name := 'OR';

                 -- dbms_output.put_line('Stage 2');

                 WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                      x_process_item_type   =>  p_item_type,
                      x_process_name        =>  v_process_name,
                      x_process_version     =>  1,
                      x_activity_item_type  =>  'WFSTD',
                      x_activity_name       =>  v_activity_name,
                      x_instance_id         =>  v_or_instance_id,
                      x_instance_label      =>  v_activity_name||'_'||to_char(v_or_instance_id),
                      x_protect_level       =>  20,
                      x_custom_level        =>  20,
                      x_start_end           =>  null,
                      x_default_result      =>  null,
                      x_icon_geometry       =>  '0,0',
                      x_perform_role        =>  null,
                      x_perform_role_type   =>  'CONSTANT',
                      x_user_comment        =>  null,
                      x_level_error         =>  v_api_error_code
                 );



                 -- dbms_output.put_line('083');
                 /*  Bring from instance id, Result code from transitions        */
                 /*                                  where to = notn.instance id */

                 for c6 in c5 loop
                   -- dbms_output.put_line('093');
                   /*  Create transition between A to PreNotfn. */
                   oe_upgrade_wf2.insert_into_wf_table
                   (
                       c6.from_process_activity,
                       v_instance_id,
                       c6.result_code,
                       v_level_error
                   );

                   /*  Delete the transition between A and Notfn. */

                   wf_load.delete_transition (
                      p_previous_step => c6.from_process_activity,
                      p_next_step     => c2.instance_id,
                      p_result_code   => v_result_code
                   );
                 end loop;


                 for c4 in c3 loop
                     /* for the same result_code from the PreNot and the Not, go to the OR-n */
                        select wf_process_activities_s.nextval into v_or_instance_id2
                        from dual;

                        v_activity_name := 'OR';

                        WF_LOAD.UPLOAD_PROCESS_ACTIVITY (
                          x_process_item_type   =>  p_item_type,
                          x_process_name        =>  v_process_name,
                          x_process_version     =>  1,
                          x_activity_item_type  =>  'WFSTD',
                          x_activity_name       =>  v_activity_name,
                          x_instance_id         =>  v_or_instance_id2,
                          x_instance_label      =>  v_activity_name||'_'||to_char(v_or_instance_id2),
                          x_protect_level       =>  20,
                          x_custom_level        =>  20,
                          x_start_end           =>  null,
                          x_default_result      =>  null,
                          x_icon_geometry       =>  '0,0',
                          x_perform_role        =>  null,
                          x_perform_role_type   =>  'CONSTANT',
                          x_user_comment        =>  null,
                          x_level_error         =>  v_api_error_code
                        );
                      /* update notification to point to the OR just created */
                        update wf_activity_transitions
                        set to_process_activity = v_or_instance_id2
                        where from_process_activity = v_notn_instance_id
                        and   to_process_activity = c4.to_process_activity;

                      /* point the PreNotification to this Or as well */
                        oe_upgrade_wf2.insert_into_wf_table
                        (
                            v_instance_id,
                            v_or_instance_id2,
                            c4.result_code,
                            v_level_error
                        );

                      /* From Or-2 to B(s) */
                        oe_upgrade_wf2.insert_into_wf_table
                        (
                            v_or_instance_id2,
                            c4.to_process_activity,
                            '*',
                            v_level_error
                        );

                 -- dbms_output.put_line('163');
                 end loop;
                 -- dbms_output.put_line('113');
                 /*  Create transition between Pre Notfn. to Or  */

                 oe_upgrade_wf2.insert_into_wf_table
                 (
                       v_instance_id,
                       v_or_instance_id,
                       '*',
                       v_level_error
                 );


                 -- dbms_output.put_line('123');
                 /*  Create transition between OR to Notification */

                 oe_upgrade_wf2.insert_into_wf_table
                 (
                       v_or_instance_id,
                       c2.instance_id,
                       '*',
                       v_level_error
                 );


                 -- dbms_output.put_line('133');
                 /*  Create transition between Notification to OR for Not-processed code */

                 if v_fyi_Flag = 'N' then
                      oe_upgrade_wf2.insert_into_wf_table
                      (
                            c2.instance_id,
                            v_or_instance_id,
                            'NOT_PROCESSED',
                            v_level_error
                      );
                 end if;


                 -- dbms_output.put_line('143');
              /*  Bring TO instance id from transitions where From = Notification instance id */
              /* For each record, Create transition from Pre-Notfn. to TO brought */

     end loop;

     -- dbms_output.put_line('173');
   Exception
        when others then
           --dbms_output.put_line('create_notification exception');
           v_error_flag := 'Y';
End Create_Notification;

END OE_UPGRADE_WF2;

/
