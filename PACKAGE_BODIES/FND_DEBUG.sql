--------------------------------------------------------
--  DDL for Package Body FND_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DEBUG" as
/* $Header: AFCPDWBB.pls 120.2 2005/09/30 10:42:13 rckalyan ship $ */

  --
  -- PUBLIC VARIABLES
  --
  TYPE rules_rec_type is record
          (debug_option     varchar2(30),
           -- option_value     varchar2(80),
           disable_routine  varchar2(500));

  TYPE rules_tab_type is table of rules_rec_type
         index by binary_integer;

  P_RULES rules_tab_type;
  RULEC   number := 0;

  TYPE rule_select_rec is record
  ( enable_routine      FND_DEBUG_OPTION_VALUES.enable_routine%TYPE,
    disable_routine     FND_DEBUG_OPTION_VALUES.disable_routine%TYPE,
    debug_option_name   FND_DEBUG_RULE_OPTIONS.debug_option_name%TYPE,
    debug_option_value  FND_DEBUG_RULE_OPTIONS.debug_option_value%TYPE,
    debug_rule_id       FND_DEBUG_RULES.debug_rule_id%TYPE,
    repeation_counter   FND_DEBUG_RULES.repeation_counter%TYPE,
    start_time          FND_DEBUG_RULES.start_time%TYPE,
    end_time            FND_DEBUG_RULES.end_time%TYPE,
    user_id             FND_DEBUG_RULES.user_id%TYPE,
    responsibility_id   FND_DEBUG_RULES.responsibility_id%TYPE,
    resp_appl_id        FND_DEBUG_RULES.resp_appl_id%TYPE,
    component_type      FND_DEBUG_RULES.component_type%TYPE,
    component_name      FND_DEBUG_RULES.component_name%TYPE,
    component_id        FND_DEBUG_RULES.component_id%TYPE,
    component_appl_id   FND_DEBUG_RULES.component_appl_id%TYPE,
    trace_file_routine  FND_DEBUG_OPTION_VALUES.trace_file_routine%TYPE,
    trace_file_node     FND_DEBUG_OPTION_VALUES.trace_file_node%TYPE,
    comments            FND_DEBUG_RULES.comments%TYPE,
    reqid               FND_DEBUG_RULES.request_id%TYPE
   );

  -- Exceptions

  -- Exception Pragmas

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   enable_db_rules
  -- Purpose
  --   Based on debug rules currently active for the user / responsibility
  --   it will execute the matching rules accordingly
  --   return string which will contain the debug string for the
  --   component instance to use.
  --
  -- return true if atleast one rule is executed in this call
  --        other wise returns false (if no rule is executed)
  /*
    some examples to call this API
    1. To execute all rules associated with this component having different debug options
        enable_db_rules(FND_DEBUG.FORM, 'FNDRSRUN');

    2. To execute all rules associated with this component id and component application id
        having different debug options (one of the component name or comp id and  comp appl id is required)
        enable_db_rules(FND_DEBUG.REPORT, null, 1,2);

    3. To execute rules specific to a request id having different debug options
        enable_db_rules(FND_DEBUG.REPORT, 'FNDSCURS', null, null, 12345);

  */
  FUNCTION enable_db_rules (comp_type       in varchar2,
                            comp_name       in varchar2,
                            comp_appl_id    in number default null,
                            comp_id         in number default null,
                            req_id          in number default null
                            ) RETURN BOOLEAN IS

      PRAGMA AUTONOMOUS_TRANSACTION;
      CURSOR DRC_REQ (ctype varchar2, cname varchar2, capplid number,
            cid number, userid number, respid number,
            respapplid number, reqid number) is
            select enable_routine, disable_routine, DRO.debug_option_name,
             DRO.debug_option_value, DR.debug_rule_id, repeation_counter, start_time,
             end_time, user_id, responsibility_id, resp_appl_id, component_type,
             component_name, component_id, component_appl_id,
             trace_file_routine, trace_file_node, comments, nvl(request_id,0) reqid
        from fnd_debug_options DO,
             fnd_debug_rules DR,
             fnd_debug_option_values DOV,
             fnd_debug_rule_options DRO
       where ( DR.user_id = userid
              OR (DR.responsibility_id = respid
                 and DR.Resp_appl_id  = respapplid )
              OR (DR.user_id is null and DR.Responsibility_ID is null) )
             AND (( sysdate >= DR.Start_time and sysdate <= DR.end_time)
                 or DR.repeation_counter > 0 )
             AND ( DR.Component_Name = cname
                 or (DR.Component_id = cid
                       AND DR.component_appl_id = capplid ) )
             AND DR.Component_type = ctype
             AND DRO.debug_option_name = DOV.debug_option_name
             AND DRO.debug_option_value = DOV.debug_option_value
             AND DRO.debug_option_name = DO.debug_option_name
             AND DO.type = 'D'
             AND DO.enabled_flag = 'Y'
             AND ((DR.request_id is not null AND reqid = DR.request_id) OR (DR.request_id is null) )
             AND DR.debug_rule_id = DRO.debug_rule_id
             AND DR.debug_rule_id=(SELECT min(debug_rule_id) FROM fnd_debug_rules IDR
                                   WHERE (IDR.user_id = userid
                                                 OR (IDR.responsibility_id = respid
                                                    AND IDR.Resp_appl_id  = respapplid )
                                                 OR (IDR.user_id IS NULL AND IDR.Responsibility_ID IS NULL) )
                                                AND (( sysdate >= IDR.Start_time and sysdate <= IDR.end_time)
                                                    OR IDR.repeation_counter > 0 )
                                                AND ( IDR.Component_Name = cname
                                                    OR (IDR.Component_id = cid
                                                    AND IDR.component_appl_id = capplid ) )
                                                AND IDR.Component_type = ctype
								                AND ((IDR.request_id IS NOT NULL
												    AND reqid = IDR.request_id) OR (IDR.request_id IS NULL) )


								  )  -- Fix for Bug 3960063,Earliest rule is selected
       order by reqid desc, DR.creation_date, DR.debug_rule_id
       /* sorted by oldest rule based on creation such that same rule id are contiguous*/;

      CURSOR DRC_NON_REQ (ctype varchar2, cname varchar2, capplid number,
             cid number, userid number, respid number,
             respapplid number) is
      select enable_routine, disable_routine, DRO.debug_option_name,
             DRO.debug_option_value, DR.debug_rule_id, repeation_counter, start_time,
             end_time, user_id, responsibility_id, resp_appl_id, component_type,
             component_name, component_id, component_appl_id,
             trace_file_routine, trace_file_node, comments, nvl(request_id,0) reqid
       from fnd_debug_options DO,
             fnd_debug_rules DR,
             fnd_debug_option_values DOV,
             fnd_debug_rule_options DRO
       where ( DR.user_id = userid
              OR (DR.responsibility_id = respid
                 and DR.Resp_appl_id  = respapplid )
              OR (DR.user_id is null and DR.Responsibility_ID is null) )
              AND (( sysdate >= DR.Start_time and sysdate <= DR.end_time)
                 or DR.repeation_counter > 0 )
              AND DR.Component_Name = cname
              AND DR.Component_type = ctype
              AND DRO.debug_option_name = DOV.debug_option_name
              AND DRO.debug_option_value = DOV.debug_option_value
              AND DRO.debug_option_name = DO.debug_option_name
              AND DO.type = 'D'
              AND DO.enabled_flag = 'Y'
              AND DR.request_id is null
              AND DR.debug_rule_id = DRO.debug_rule_id
             AND DR.debug_rule_id=(SELECT min(debug_rule_id) FROM fnd_debug_rules IDR
                                   WHERE (IDR.user_id = userid
                                                 OR (IDR.responsibility_id = respid
                                                    AND IDR.Resp_appl_id  = respapplid )
                                                 OR (IDR.user_id IS NULL AND IDR.Responsibility_ID IS NULL) )
                                                AND (( sysdate >= IDR.Start_time and sysdate <= IDR.end_time)
                                                    OR IDR.repeation_counter > 0 )
                                                AND  IDR.Component_Name = cname
                                                AND IDR.Component_type = ctype
								                AND IDR.request_id IS NULL

								  )  -- Fix for Bug 3960063,Earliest rule is selected
       order by reqid desc, DR.creation_date , DR.debug_rule_id
           /* sorted by oldest rule based on creation such that same rule id are contiguous */;


      i                 number;
      -- duplicate         boolean := FALSE;
      empty_drules      rules_tab_type;
      sql_str           varchar2(512);
      trans_id          number;
      log_file          varchar2(512);
      node_name         varchar2(512);
      left_iterations   number;
      is_rule_processed boolean := FALSE; -- turned on if any rule is executed
      userid            number;
      respid            number;
      respapplid        number;
      loginid           number;
      dr_rec            rule_select_rec;
      last_rule_id      number;
      repetition_counter FND_DEBUG_RULES.repeation_counter%TYPE := 0; -- repetition_counter is the number of actual occurances for a rule
  begin

      RULEC := 0;
      P_RULES := empty_drules;
      userid  := FND_GLOBAL.user_id;
      respid  := FND_GLOBAL.resp_id;
      respapplid  := FND_GLOBAL.resp_appl_id;
      loginid := FND_GLOBAL.login_id;
      last_rule_id := 0;

      -- find any debug rules available for this component instance.
      -- if request_id is passed then use DRC_REQ else DRC_NON_REQ cursor.
      if ( req_id is null ) then
        OPEN DRC_NON_REQ(comp_type, comp_name, comp_appl_id, comp_id, userid,
			respid, respapplid);
      else
        OPEN DRC_REQ(comp_type, comp_name, comp_appl_id, comp_id, userid,
			respid, respapplid, req_id);
      end if;

      LOOP

        if ( req_id is null ) then
           FETCH DRC_NON_REQ INTO dr_rec;
           EXIT when DRC_NON_REQ%NOTFOUND;
        else
           FETCH DRC_REQ INTO dr_rec;
           EXIT when DRC_REQ%NOTFOUND;
        end if;

        -- check if this call to enable_db_rule is request id based
        -- and also the fetched rule has the same request id
        -- If fnd_debug_rule has a request_id that means rule is associated
        -- to a specific request_id. If we find even one request_id based
	    -- rule for the current request then, we will execute that one only.
        -- Not other non-request_id based rules.

        if ( req_id is not null and dr_rec.reqid <> req_id
		 and dr_rec.reqid <> 0 ) then
          goto end_loop;
        end if;

        /*
        -- check this debug option with value already processed or not.
        -- this condition is to avoid executing the same debug optiontwice.
        -- if yes then ignore it.

        ** no need to check the duplicate as we will be processing only one
        debug rule with all of its debug options **
          for i in 1..RULEC loop
            if ( dr_rec.debug_option_name = P_RULES(i).debug_option ) then
              duplicate := TRUE;
            end if;
          end loop;
        */
        -- execute all the rules with same rule id.. for the first time
        -- last_rule_id will be 0 and be initialized to the first rule id
        if ((dr_rec.enable_routine is not null) AND
            (last_rule_id = 0 OR last_rule_id = dr_rec.debug_rule_id) ) then

            -- last_rule_id := dr_rec.debug_rule_id;
            is_rule_processed := TRUE;
            -- Store this debug option with value in global to use in
            -- disable_db_rules.
            RULEC := RULEC + 1;
            P_RULES(RULEC).debug_option := dr_rec.debug_option_name;
            -- P_RULES(RULEC).option_value := dr_rec.debug_option_value;
            P_RULES(RULEC).disable_routine := dr_rec.disable_routine;

            -- Run the enable routine to enable the debugging.
            sql_str := 'begin ' || dr_rec.enable_routine || '; end;';

            execute immediate sql_str;

            -- insert row about execution in fnd_debug_rule_executions
            trans_id := get_transaction_id(FALSE);

            log_file := get_ret_value(dr_rec.trace_file_routine);

            node_name := get_ret_value(dr_rec.trace_file_node);

         -- added repetition_counter as a fix for bug 3787995
         -- repetition_counter is the number of actual occurances for this rule
         SELECT NVL(MAX(DRO.repeation_counter),0) INTO repetition_counter
         FROM  fnd_debug_rule_executions DRO,
               fnd_debug_option_values DOV
         WHERE DRO.debug_option_name=DOV.debug_option_name
            AND DRO.debug_option_value=DOV.debug_option_value
            AND DOV.debug_option_name=dr_rec.debug_option_name
            AND DOV.debug_option_value=dr_rec.debug_option_value
            AND DRO.rule_id=dr_rec.debug_rule_id;

          insert into fnd_debug_rule_executions
                    (transaction_id, rule_id, component_type, component_name,
                     component_id, component_appl_id, start_time, end_time,
                     repeation_counter, debug_log_file, log_file_node_name,
                     user_id, responsibility_id, resp_appl_id,
                     debug_option_name, debug_option_value, creation_date,
                     created_by, last_update_date, last_updated_by,
                     last_update_login, comments, request_id)
            values (trans_id, dr_rec.debug_rule_id, dr_rec.component_type,
                     dr_rec.component_name, dr_rec.component_id,
                     dr_rec.component_appl_id, dr_rec.start_time,
                     dr_rec.end_time, repetition_counter+1, log_file,  -- fix for bug 3787995
                     node_name, dr_rec.user_Id, dr_rec.responsibility_id,
                     dr_rec.resp_appl_id, dr_rec.debug_option_name,
                     dr_rec.debug_option_value, sysdate, userid,
                     sysdate, userid, loginid,
                     dr_rec.comments, req_id); --Added for Bug 3788285.For showing request_id


           -- decrement repeation_counter if there are some more to run
           -- else delete the row from fnd_debug_rules
           -- If it is time based then repeation_counter will be null.
           IF (last_rule_id <> dr_rec.debug_rule_id) THEN
            BEGIN
             left_iterations := NVL(dr_rec.repeation_counter, 0) - 1;
             IF ( left_iterations >= 1 ) THEN
                UPDATE fnd_debug_rules
                SET repeation_counter = repeation_counter -1,
                       last_update_date = sysdate
                WHERE debug_rule_id = dr_rec.debug_rule_id;
             ELSIF (left_iterations = 0 ) THEN
                BEGIN
                 UPDATE fnd_debug_rules
                 SET repeation_counter = 0,
                      last_update_date = sysdate
                 WHERE debug_rule_id = dr_rec.debug_rule_id;
                END;
             END IF;
            END;
           END IF;

              last_rule_id := dr_rec.debug_rule_id;
        end if;
        <<end_loop>>
        null;
      END LOOP;

      if ( req_id is null ) then
          CLOSE DRC_NON_REQ;
      else
          CLOSE DRC_REQ;
      end if;

      -- delete any old rules as a fix for bug 3787995
      DELETE FROM fnd_debug_rule_options WHERE debug_rule_id IN
      (SELECT debug_rule_id FROM fnd_debug_rules
       WHERE (start_time IS NOT NULL AND end_time < sysdate)
          OR (repeation_counter = 0)
       );

      DELETE FROM fnd_debug_rules
      WHERE (start_time IS NOT NULL AND end_time < sysdate)
         OR (repeation_counter = 0);

      commit;

      return(is_rule_processed);

      exception
         when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token ('ROUTINE', 'FND_DEBUG.ENABLE_DB_RULES', FALSE);
            IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) THEN
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                            'fnd.plsql.FND_DEBUG.ENABLE_DB_RULES.others',
			    FALSE);
            END IF;
            if ( req_id is null ) then
                CLOSE DRC_NON_REQ;
            else
                CLOSE DRC_REQ;
            end if;

            commit;
            return (FALSE);

  end;

  --
  -- Name
  --   disable_db_rules
  -- Purpose
  --   Based on all debug rules currently active for the user / responsibility
  --   it will disable the rules in the database session.
  --
  -- return true if atleast one rule is disabled
  --        other wise returns false (if no rule is disabled)
  function disable_db_rules return boolean is
    sql_str varchar2(512);
    is_rule_processed boolean := FALSE;
  begin

      -- database disable rules always executed in the same session
      -- where ever they enabled.
      for i in 1..RULEC loop
        if (P_RULES(i).disable_routine is not null) then
            is_rule_processed := TRUE;
            -- Run the diable routine to disable debugging.
            sql_str := 'begin ' || P_RULES(i).disable_routine || '; end;';

            execute immediate sql_str;
        end if;
      end loop;

      return is_rule_processed;

      exception
         when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token ('ROUTINE', 'FND_DEBUG.DISABLE_DB_RULES', FALSE);
            IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) THEN
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                            'fnd.plsql.FND_DEBUG.DISABLE_DB_RULES.others',
			    FALSE);
            END IF;
            return (FALSE);

  end;


  --
  -- Name
  --    get_os_rules
  -- Purpose
  --    Based on debug rules currently active for the user / responsibility
  --    it will return debug string which contains debug string for the component
  --    to use before running the component.
  --    this will execute one and only one rule at a call
  --    in case multiple rules are matching, the oldest rule will be picked
  --
  --  return string containing debug string for matched rule
  /*
    some examples to call this API
    1. To execute rule associated with this component for a specific user
        get_os_rules(FND_DEBUG.REPORT, 'FNDSCURS', null, null, 12345, 0, 20450,1);


  */
  function get_os_rules ( comp_type          in varchar2,
                          comp_name          in varchar2,
                          comp_appl_id       in number default null,
                          comp_id            in number default null,
                          comp_inst_id       in number default null,  /* request id */
                          user_id            in number,
                          resp_appl_id       in number,
                          resp_id            in number
                        ) RETURN VARCHAR2 IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      -- avoid using the same debug option twice, will take old one.
      CURSOR DRC (ctype varchar2, cname varchar2,
                  capplid number, cid number,
                  uid number, respapplid number, respid number,
                  reqid number) is
      select * from (
        select DRO.debug_option_name, DRO.debug_option_value, separator,
               trace_file_token, DR.debug_rule_id, repeation_counter, start_time,
               end_time, user_id, responsibility_id, resp_appl_id,
	       component_type, component_name, component_id, component_appl_id,
	       trace_file_routine, trace_file_node, comments,
	       nvl(request_id,0) reqid
          from fnd_debug_options DO,
               fnd_debug_rules DR,
               fnd_debug_option_values DOV,
               fnd_debug_rule_options DRO
         where ( DR.user_id = uid
                  OR (DR.responsibility_id = respid
                     and DR.Resp_appl_id  = respapplid )
                  OR (DR.user_id is null and DR.Responsibility_ID is null))
               AND (( sysdate >= DR.Start_time and sysdate <= DR.end_time  )
                   or DR.repeation_counter > 0 )
               AND ( DR.Component_Name = cname
                   or (DR.Component_id = cid
                         AND DR.component_appl_id = capplid ) )
               AND DR.Component_type = ctype
               AND DRO.debug_option_name = DOV.debug_option_name
               AND DRO.debug_option_value = DOV.debug_option_value
               AND DRO.debug_option_name = DO.debug_option_name
               AND DO.type = 'O'
               AND DO.enabled_flag = 'Y'
               AND ((DR.request_id is not null AND reqid = DR.request_id) OR (DR.request_id is null) )
               AND DR.debug_rule_id = DRO.debug_rule_id
               order by reqid desc, DR.creation_date )
               where rownum =1;

       t_ftoken           varchar(80);
       debug_str          varchar2(500);
       trace_file         varchar2(250);
       trace_file_str     varchar2(250);
       trc_option_nmval   varchar2(250);
       left_iterations    number;
       trans_id           number;
       log_file           varchar2(250);
       node_name          varchar2(250);
       db_rule_enabled varchar2(1);
       repetition_counter FND_DEBUG_RULES.repeation_counter%TYPE := 0;

  begin
      debug_str := '';
      -- find any debug rules available for this component instance.
      FOR dr_rec in drc(comp_type, comp_name, comp_appl_id, comp_id,
      user_id, resp_appl_id, resp_id, comp_inst_id) LOOP

        -- construct debug string
        if ( dr_rec.trace_file_token is not null ) then

          -- get trace file name;
          trace_file := get_ret_value(dr_rec.trace_file_routine);
          trace_file_str :=   NVL(dr_rec.separator,' ') ||
          dr_rec.trace_file_token || '=' || trace_file;
        else
           -- check this debug option might have any trace file name
           -- at option values.
         begin
            select debug_option_value
              into t_ftoken
              from fnd_debug_option_values
              where debug_option_name = dr_rec.debug_option_name
              and is_file_token = 'Y';

            trace_file := get_ret_value(dr_rec.trace_file_routine);
            trace_file_str :=  NVL(dr_rec.separator, ' ') || t_ftoken ||
                              '=' || trace_file ;

            exception
               when no_data_found then
                  null;
         end;
        end if;

        trc_option_nmval := ' ';

        if ( dr_rec.debug_option_value = 'BLANK' ) then
           trc_option_nmval := dr_rec.debug_option_name;
        else
           trc_option_nmval := dr_rec.debug_option_name || '=' ||
				dr_rec.debug_option_value;
        end if;

        debug_str := debug_str || ' ' || trc_option_nmval ||
                      NVL(dr_rec.separator,' ') || trace_file_str || ' ';

        -- insert row about execution in fnd_debug_rule_executions
        trans_id := get_transaction_id(TRUE, comp_type, comp_inst_id,
                  comp_appl_id, user_id, resp_id, resp_appl_id);
        log_file := trace_file;
        node_name := get_ret_value(dr_rec.trace_file_node);

        -- added repetition_counter as a fix for bug 3787995
        -- repetition_counter is the number of actual occurances for this rule
        SELECT NVL(MAX(DRO.repeation_counter),0) INTO repetition_counter
        FROM  fnd_debug_rule_executions DRO,
              fnd_debug_option_values DOV
        WHERE DRO.debug_option_name=DOV.debug_option_name
           AND DRO.debug_option_value=DOV.debug_option_value
           AND DOV.debug_option_name=dr_rec.debug_option_name
           AND DOV.debug_option_value=dr_rec.debug_option_value
           AND DRO.rule_id=dr_rec.debug_rule_id;

        insert into fnd_debug_rule_executions
              (transaction_id, rule_id, component_type, component_name,
	       component_id, component_appl_id, start_time, end_time,
               repeation_counter, debug_log_file, log_file_node_name,
               user_id, responsibility_id, resp_appl_id,
               debug_option_name, debug_option_value, creation_date,
               created_by, last_update_date, last_updated_by,
               last_update_login, comments, request_id)
        values (trans_id, dr_rec.debug_rule_id, dr_rec.component_type,
		dr_rec.component_name, dr_rec.component_id,
		dr_rec.component_appl_id, dr_rec.start_time,
                dr_rec.end_time, repetition_counter+1, log_file, -- fix for bug 3787995
                node_name, dr_rec.user_Id, dr_rec.responsibility_id,
                dr_rec.resp_appl_id, dr_rec.debug_option_name,
                dr_rec.debug_option_value, sysdate, fnd_global.user_id,
                  sysdate, fnd_global.user_id, fnd_global.login_id,
                  dr_rec.comments, comp_inst_id); --Added for Bug 3788285.For showing request_id


        -- added db_rule_enabled  as a fix for bug 3787995
        BEGIN --check whether any of the db rule is enabled or not
        SELECT 'T' INTO db_rule_enabled
        FROM	 DUAL
        WHERE EXISTS(
               SELECT *
               FROM fnd_debug_rule_options DRO,
                   fnd_debug_options DO
               WHERE DRO.debug_option_name=DO.debug_option_name
                  AND DO.type='D'
                  AND dr_rec.debug_rule_id=DRO.debug_rule_id);
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           db_rule_enabled:='F';
        END;  --check whether any of the db rule is enabled or not

        -- decrement repeation_counter if no db rules are enabled and
        -- if there are some more to run
        -- else delete the row from fnd_debug_rules
        -- If it is time based then repeation_counter will be null.
     	-- added the check as a fix for bug 3787995
        IF (db_rule_enabled='F') THEN --if none of db rules are enabled
         BEGIN
          left_iterations := nvl(dr_rec.repeation_counter,0) - 1;
          IF ( left_iterations >= 1 ) THEN
            UPDATE fnd_debug_rules
            SET repeation_counter = repeation_counter -1,
              last_update_date = sysdate
            WHERE debug_rule_id = dr_rec.debug_rule_id;
          ELSIF (left_iterations = 0 ) THEN
                 BEGIN
                  UPDATE fnd_debug_rules
                   SET repeation_counter = 0,
                       last_update_date = sysdate
                   WHERE debug_rule_id = dr_rec.debug_rule_id;
                 END;
          END IF;
         END;
        END IF;	   --if none of db rules are enabled


      END LOOP;


      -- delete any old rules as a fix for bug 3787995
      DELETE FROM fnd_debug_rule_options WHERE debug_rule_id IN
      (SELECT debug_rule_id
       FROM fnd_debug_rules
       WHERE (start_time IS NOT NULL AND end_time < sysdate)
          OR (repeation_counter = 0)
       );

      DELETE FROM fnd_debug_rules
      WHERE (start_time IS NOT NULL AND end_time < sysdate)
         OR (repeation_counter = 0);



      commit;

      return ltrim(rtrim(debug_str));

      exception
         when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token (
                             'ROUTINE', 'FND_DEBUG.GET_OS_RULES', FALSE);
            IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) THEN
             fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                            'fnd.plsql.FND_DEBUG.GET_OS_RULES.others', FALSE);
            END IF;
            commit;
            return ltrim(rtrim(debug_str));
  end;

  --
  -- Name
  --    get_transaction_id
  -- Purpose
  --    Returns the transaction context id by calling
  --    fnd_log_repository.init_trans_int_with_context api.

  function get_transaction_id(force               boolean   default FALSE,
                              comp_type           varchar2  default null,
                              comp_inst_id        number    default null,
                              comp_inst_appl_id   number    default null,
                              user_id             number    default null,
                              resp_id             number    default null,
                              resp_appl_id        number    default null
                            ) RETURN NUMBER IS
      transaction_id  number;
      conc_request_id number;
      form_id         number;
      form_appl_id    number;
      conc_process_id number;
      conc_queue_id   number;
      icx_session_id  number;

  begin
      -- if force is true then it will always gets the new transaction context
      -- information, otherwise checks context already exitsts or not if
      -- exists then use that one else create new one.
      -- force is used in spawned concurrent request case.
      if ( force ) then
         if (comp_type in (FND_DEBUG.SQLPLUS_CP, FND_DEBUG.PLSQL_CP,
			   FND_DEBUG.JAVA_CP, FND_DEBUG.REPORTS )  ) then
            conc_request_id := comp_inst_id;
         end if;

         transaction_id := fnd_log_repository.init_trans_int_with_context
			      (conc_request_id,
              form_id,
              form_appl_id,
              conc_process_id,
              conc_queue_id,
              icx_session_id,
              user_id,
              resp_appl_id,
              resp_id,
              fnd_global.security_group_id
              );

      else
        if ( fnd_log.g_transaction_context_id is null ) then
         transaction_id := fnd_log_repository.init_trans_int_with_context
                              (fnd_global.conc_request_id,
                               fnd_global.form_id,
                               fnd_global.form_appl_id,
                               fnd_global.conc_process_id,
                               fnd_global.conc_queue_id,
                               fnd_global.queue_appl_id,
                               icx_sec.g_session_id,
                               fnd_global.user_id,
                               fnd_global.resp_appl_id,
                               fnd_global.resp_id,
                               fnd_global.security_group_id
                              );
        else
         transaction_id := fnd_log.g_transaction_context_id;
        end if;
       end if;

       return transaction_id;

  end;


  --
  -- Name
  --    get_ret_value
  -- Purpose
  --    A utility function to execute the passed routine as string
  --
  --  returns string containing the result of execution of passes string.
  function get_ret_value(t_routine varchar2) return varchar2 is
    ret_val varchar2(500);
    sql_str varchar2(512);
  begin
     if ( t_routine is null ) then
        ret_val := '';
     else
        sql_str := 'begin :1 := ' || t_routine || '; end;';

        execute immediate sql_str using out ret_val;

     end if;

     return ret_val;
  end;

  --
  -- Name
  --    assign_request
  -- Purpose
  --    It will assign specified request_id to the debug_rule_execution.
  --    In case of PL SQL Profiling we have to submit a request to get the
  --    output of trace information.
  -- Arguments:
  --    Transaction_id : transaction_id for which we need to assign the
  --                     request_id
  --    request_id     : Request_id value we need to assign.
  procedure assign_request(transaction_id  IN number,
			   request_id      IN number) is
   PRAGMA AUTONOMOUS_TRANSACTION;
  begin
      update fnd_debug_rule_executions
         set log_request_id = assign_request.request_id
       where transaction_id = assign_request.transaction_id
         and debug_option_value = 'PLSQL_PROFILER';

      commit;

    exception
      when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token (
                             'ROUTINE', 'FND_DEBUG.ASSIGN_REQUEST', FALSE);
            IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) THEN
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                            'fnd.plsql.FND_DEBUG.ASSIGN_REQUEST.others', FALSE);
            END IF;
            commit;


  end;
 end FND_DEBUG;

/
