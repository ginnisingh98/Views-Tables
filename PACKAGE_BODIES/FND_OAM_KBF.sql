--------------------------------------------------------
--  DDL for Package Body FND_OAM_KBF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_KBF" AS
/* $Header: AFOAMBFB.pls 120.3 2005/11/16 21:46:28 ppradhan noship $ */

-------------------------------------------------------------------------------
-- Exceptions Related
-------------------------------------------------------------------------------
  --
  -- Name
  --   get_sysalcnt
  --
  -- Purpose
  --   Returns the count of System Alerts across various severities and
  --   acknowledged states by querying the fnd_log_unique_exceptions table
  --
  -- Input Arguments
  --   p_category - category for which to return the counts. Null by
  --                by default.
  -- Output Arguments
  --   critical_n - count of new alerts which are of CRITICAL severity
  --   error_n    - count of new alerts which are of ERROR severity
  --   warning_n  - count of new alerts which are of WARNING severity
  --   critical_o - count of open alerts which are of CRITICAL severity
  --   error_o    - count of open alerts which are of ERROR severity
  --   warning_o  - count of open alerts which are of WARNING severity
  --   critical_c - count of closed alerts which are of CRITICAL severity
  --   error_c    - count of closed alerts which are of ERROR severity
  --   warning_c  - count of closed alerts which are of WARNING severity
  --
  -- Notes:
  --
  --
  PROCEDURE get_sysal_cnt
    (critical_n OUT NOCOPY number,
     error_n OUT NOCOPY number,
     warning_n OUT NOCOPY number,
     critical_o OUT NOCOPY number,
     error_o OUT NOCOPY number,
     warning_o OUT NOCOPY number,
     p_category in varchar2 default null)
  IS

  BEGIN
    if p_category is null then
        select count(*) into critical_n from fnd_log_unique_exceptions where
                severity='CRITICAL' and status='N';
        select count(*) into error_n from fnd_log_unique_exceptions where
                severity='ERROR' and status='N';
        select count(*) into warning_n from fnd_log_unique_exceptions where
                severity='WARNING' and status='N';
        select count(*) into critical_o from fnd_log_unique_exceptions where
                severity='CRITICAL' and status='O';
        select count(*) into error_o from fnd_log_unique_exceptions where
                severity='ERROR' and status='O';
        select count(*) into warning_o from fnd_log_unique_exceptions where
                severity='WARNING' and status='O';
/*
        select count(*) into critical_c from fnd_log_unique_exceptions where
                severity='CRITICAL' and status='C';
        select count(*) into error_c from fnd_log_unique_exceptions where
                severity='ERROR' and status='C';
        select count(*) into warning_c from fnd_log_unique_exceptions where
                severity='WARNING' and status='C';
*/
    else
        select count(*) into critical_n from fnd_log_unique_exceptions where
                severity='CRITICAL' and status='N' and category=p_category;
        select count(*) into error_n from fnd_log_unique_exceptions where
                severity='ERROR' and status='N' and category=p_category;
        select count(*) into warning_n from fnd_log_unique_exceptions where
                severity='WARNING' and status='N' and category=p_category;
        select count(*) into critical_o from fnd_log_unique_exceptions where
                severity='CRITICAL' and status='O' and category=p_category;
        select count(*) into error_o from fnd_log_unique_exceptions where
                severity='ERROR' and status='O' and category=p_category;
        select count(*) into warning_o from fnd_log_unique_exceptions where
                severity='WARNING' and status='O' and category=p_category;
/*
        select count(*) into critical_c from fnd_log_unique_exceptions where
                severity='CRITICAL' and status='C' and category=p_category;
        select count(*) into error_c from fnd_log_unique_exceptions where
                severity='ERROR' and status='C' and category=p_category;
        select count(*) into warning_c from fnd_log_unique_exceptions where
                severity='WARNING' and status='C' and category=p_category;
*/
    end if;
  END get_sysal_cnt;


  --
  -- Name
  --   get_occ_cnt
  --
  -- Purpose
  --   Returns the count of Occurrances of alerts across various severities
  --   and acknowledged states by querying
  --   the fnd_log_exceptions table.
  --
  -- Input Arguments
  --   p_category - category for which to return the counts. Null by
  --                by default.
  -- Output Arguments
  --   critical_n - count of new occurrances which are of CRITICAL severity
  --   error_n    - count of new occurrances which are of ERROR severity
  --   warning_n  - count of new occurrances which are of WARNING severity
  --   critical_o - count of open occurrances which are of CRITICAL severity
  --   error_o    - count of open occurrances which are of ERROR severity
  --   warning_o  - count of open occurrances which are of WARNING severity
  --   critical_c - count of closed occurrances which are of CRITICAL severity
  --   error_c    - count of closed occurrances which are of ERROR severity
  --   warning_c  - count of closed occrrances which are of WARNING severity
  --
  -- Notes:
  --
  --
  PROCEDURE get_occ_cnt
    (critical_n OUT NOCOPY number,
     error_n OUT NOCOPY number,
     warning_n OUT NOCOPY number,
     critical_o OUT NOCOPY number,
     error_o OUT NOCOPY number,
     warning_o OUT NOCOPY number,
     p_category in varchar2 default null)
  IS

  BEGIN
    -- Added an optimization for getting occurence count using the sum of
    -- count columns instead of joining with fnd_log_exceptions for
    -- bug 4653173
    if p_category is null then
        select sum(count) into critical_n
                from fnd_log_unique_exceptions flue
                where flue.severity = 'CRITICAL' and flue.status='N';
        select sum(count) into error_n
                from fnd_log_unique_exceptions flue
                where flue.severity = 'ERROR' and flue.status='N';
        select sum(count) into warning_n
                from fnd_log_unique_exceptions flue
                where flue.severity = 'WARNING' and flue.status='N';
        select sum(count) into critical_o
                from fnd_log_unique_exceptions flue
                where flue.severity = 'CRITICAL' and flue.status='O';
        select sum(count) into error_o
                from fnd_log_unique_exceptions flue
                where flue.severity = 'ERROR' and flue.status='O';
        select sum(count) into warning_o
                from fnd_log_unique_exceptions flue
                where flue.severity = 'WARNING' and flue.status='O';
/*
        select sum(count) into critical_c
                from fnd_log_unique_exceptions flue
                where flue.severity = 'CRITICAL' and flue.status='C';
        select sum(count) into error_c
                from fnd_log_unique_exceptions flue
                where flue.severity = 'ERROR' and flue.status='C';
        select sum(count) into warning_c
                from fnd_log_unique_exceptions flue
                where flue.severity = 'WARNING' and flue.status='C';
*/
     else
        select sum(count) into critical_n
                from fnd_log_unique_exceptions flue
                where flue.severity = 'CRITICAL' and flue.status='N'
                and flue.category = p_category;
        select sum(count) into error_n
                from fnd_log_unique_exceptions flue
                where flue.severity = 'ERROR' and flue.status='N'
                and flue.category = p_category;
        select sum(count) into warning_n
                from fnd_log_unique_exceptions flue
                where flue.severity = 'WARNING' and flue.status='N'
                and flue.category = p_category;
        select sum(count) into critical_o
                from fnd_log_unique_exceptions flue
                where flue.severity = 'CRITICAL' and flue.status='O'
                and flue.category = p_category;
        select sum(count) into error_o
                from fnd_log_unique_exceptions flue
                where flue.severity = 'ERROR' and flue.status='O'
                and flue.category = p_category;
        select sum(count) into warning_o
                from fnd_log_unique_exceptions flue
                where flue.severity = 'WARNING' and flue.status='O'
                and flue.category = p_category;
/*
        select sum(count) into critical_c
                from fnd_log_unique_exceptions flue
                where flue.severity = 'CRITICAL' and flue.status='C'
                and flue.category = p_category;
        select sum(count) into error_c
                from fnd_log_unique_exceptions flue
                where flue.severity = 'ERROR' and flue.status='C'
                and flue.category = p_category;
        select sum(count) into warning_c
                from fnd_log_unique_exceptions flue
                where flue.severity = 'WARNING' and flue.status='C'
                and flue.category = p_category;
*/
     end if;
  END get_occ_cnt;

  --
  -- Name
  --   change_state
  --
  -- Purpose
  --   To change the state of a set of system alerts to 'O' - Open or 'C'
  --   to close the alert. Newly generated alerts have the state 'N'. This
  --   procedure will also insert a row into fnd_exception_notes to indicate
  --   that the alert's state has been changed by the given user.
  --
  -- Input Arguments
  --   p_logidset - a single logid or a set of ',' delimited log ids. e.g.
  --             '1234' or '1234,1235,1236'. The log IDs need to be the
  --             unique_exception_id
  --   p_newstate - 'O' for Open or 'C' for Closed.
  --   p_username - user name of the apps user who is changing the state.
  --
  -- Notes:
  --   The purpose for this procedure is so that users can move the state
  --   of system alerts from the OAM UI.
  --
  PROCEDURE change_state
    (p_logidset IN varchar2,
     p_newstate IN varchar2,
     p_username IN varchar2)
  IS
        e_invalid_state exception;
        v_idset varchar2(3500) := p_logidset;
        delim constant varchar2(1) := ',';
        v_userid number;
        nl varchar2(2) := '
';
  BEGIN
    -- make sure new state is valid.
        if p_newstate <> 'O' and p_newstate <> 'C' then
                raise e_invalid_state;
        end if;

    -- first strip off any redundant delimitors at the beginning and end

        if instr(v_idset, delim, 1) = 1 then
                v_idset := substr(v_idset, 2);
        end if;
        if instr(v_idset, delim, length(v_idset)) > 0 then
                v_idset := substr(v_idset, 1, length(v_idset) - 1);
        end if;

    -- now need to insert a line into fnd_exception_notes for each exceptions
    -- so, retrieve user id

        select user_id into v_userid
                from fnd_user where upper(user_name) = upper(p_username);

    declare
      v_curr_index number := 1;
      v_curr_id varchar2(100);
      v_ack_phrase varchar2(100);
      v_newstate_disp varchar2(50);
    begin
      -- This should probably eventually come from a lookup
      if p_newstate = 'O' then
        v_newstate_disp := 'Open';
      elsif p_newstate = 'C' then
        v_newstate_disp := 'Closed';
      else
        v_newstate_disp := p_newstate;
      end if;

      v_ack_phrase := '*** Changed state to ' || v_newstate_disp || ' by '
        || upper(p_username) || ' at '
        || to_char(sysdate, 'mm/dd/yy HH12:MI:SS AM') || ' ***' || nl;
      v_idset := v_idset || delim; -- putting delim at end so all processing
                                   -- happens within loop
      while instr(v_idset, delim, v_curr_index) > 0 loop
        v_curr_id := substr(v_idset, v_curr_index,
          instr(v_idset, delim, v_curr_index) - v_curr_index);

        -- Update the status
        update fnd_log_unique_exceptions
                set status = p_newstate,
                last_updated_by = v_userid,
                last_update_date = sysdate
                where unique_exception_id = to_number(v_curr_id);

        -- Now insert a note to keep track of the state change.
        declare
                v_notes CLOB;
        begin
                select notes into v_notes
                        from fnd_exception_notes
                        where unique_exception_id = to_number(v_curr_id)
                        for update;

                dbms_lob.writeappend(v_notes, length(v_ack_phrase),
                        v_ack_phrase);
        exception
                when no_data_found then
                        insert into fnd_exception_notes (
                                notes, creation_date, created_by,
                                last_update_date, last_updated_by,
                                last_update_login,
                                log_sequence,
                                unique_exception_id) values
                        (v_ack_phrase, sysdate, v_userid, sysdate,
                         v_userid, 0, -1,
                         to_number(v_curr_id));
        end;

        v_curr_index := instr(v_idset, delim, v_curr_index) + 1;
      end loop;
   end;
   commit;

  EXCEPTION
        when others then
          rollback;
          raise;
  END change_state;

END fnd_oam_kbf;



/
