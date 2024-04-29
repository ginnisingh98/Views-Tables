--------------------------------------------------------
--  DDL for Package Body GL_CI_PRE_CROSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CI_PRE_CROSS_PKG" as
/* $Header: gluciprb.pls 120.3 2005/12/08 10:31:56 mikeward noship $ */


  own CONSTANT varchar2(30)       := 'GL';
  appSchema CONSTANT varchar2(30) := 'APPS';

  TYPE t_RefCur                   IS REF CURSOR;
  GLOBAL_ERROR                    exception;  --+something is wrong - general handler
  --+ Tell me what's wrong
  global_retcode                  number;
  global_errbuf                   varchar2(2000);
  section_number                  number(5);        --+where did I go wrong?

  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ Debug/Diagnostic routine
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure debug_message (
    message_string in varchar2               ,
    verbose_mode   in boolean   default FALSE,
    line_size      in number    default 255  ,
    which_file     in varchar2  default FND_FILE.log
  ) is
    msg_text       varchar2(10000) := substr(message_string, 1, 32000);
    new_line       number          := 0;
  begin
    if verbose_mode then
      if message_string = fnd_global.local_chr(10) then
        FND_FILE.put(which_file, message_string);
      else
        while msg_text is not null loop
          new_line := instr(msg_text, fnd_global.local_chr(10));
          if new_line = 0            then new_line := line_size;
          elsif new_line > line_size then new_line := line_size;
          end if;
          FND_FILE.put_line(which_file, substr(msg_text, 1, new_line-1));
          msg_text := substr(msg_text, new_line+1);
        end loop;
      end if;
    end if;
  exception
    when OTHERS then
      if SQLCODE = 1 then
        --+ Raised if you call FND_FILE from a SQL*Plus session
        --+ without initializing user_id, resp_id, login_resp_id.
       --+ dbms_output.enable(1000000);
        while msg_text is not null loop
--+can not use chr(10) any more, can not use dbms_output any more
          new_line := instr(msg_text, fnd_global.local_chr(10));
          if new_line = 0            then new_line := line_size;
          elsif new_line > line_size then new_line := line_size;
          end if;
          raise_application_error(-20000, substr(msg_text, 1, new_line-1));
          --+DBMS_OUTPUT.put_line( substr(msg_text, 1, new_line-1) );
          msg_text := substr(msg_text, new_line+1);
        end loop;
      else
        RAISE;
      end if;
  end debug_message;

  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ Debug/Diagnostic routine
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure DD (
    message_string in varchar2,
    mode_override  in boolean  default TRUE,
    line_size      in number   default 255,
    which_file     in varchar2 default FND_FILE.log
  ) is
  begin
    if mode_override then
       debug_message(message_string, TRUE, line_size, which_file);
    end if;
  end DD;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+get the group ID from the source dtaabase after the consolidation data
--+has been transfered into gl_interface table
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Source_Group_ID(
   cons_id                 IN number,
   cons_run_id             IN number
)  return number
IS
   v_SQL                   varchar2(500);
   l_group_id              number;
BEGIN
   v_SQL := 'select group_id from gl_consolidation_history ' ||
               'where consolidation_id = :cons_id ' ||
               'and consolidation_run_id = :cons_run_id';
   EXECUTE IMMEDIATE v_SQL INTO l_group_id USING cons_id, cons_run_id;
   l_group_id := l_group_id;
   return l_group_id;
END Get_Source_Group_id;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+this is the concurrent program that will be submitted right after
--+consolidation program is submitted. It will wait for consolidation to complete
--+then launches the Cross Instance Data Transfer program.
--+the maximum time it waits is 10 hours.
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure pre_run_CI_transfer(
   errbuf                 in out NOCOPY varchar2,
   retcode                in out NOCOPY varchar2,
   p_resp_name            IN varchar2,
   p_cons_request_id      IN number,
   consolidation_id       IN number,
   run_id                 IN number,
   to_period_token        IN varchar2,
   to_sob_id              IN number,
   p_user_name            IN varchar2,
   p_dblink               IN varchar2,
   from_group_id          IN number,
   from_sob_id            IN number,
   p_pd_name              IN varchar2,
   p_budget_name          IN varchar2,
   p_j_import             IN VARCHAR2,
   p_j_post               IN varchar2,
   p_actual_flag          IN varchar2,
   p_request_id           IN number,
   p_csj_flag             IN VARCHAR2,
   p_debug                IN varchar2)

IS
   dblink                varchar2(30);
   l_result              varchar2(100);
   v_WaitSQL             varchar2(1000);
   l_source_group_id     number;
   l_ci_request_id       number;
   section_number        number;
   phase                 varchar2(80);
   status                varchar2(80);
   dev_phase             varchar2(30);
   dev_status            varchar2(30);
   message               varchar2(240);
   success               boolean;
   l_user_id             number;
   l_resp_id             number;
   l_count               number := 0;
   l_domainName          varchar2(150);
BEGIN
   section_number := 1;
      --+bug#2712006, cannot use hardcoded domain name
   v_WaitSQL := 'select domain_name ' ||
              'from rg_database_links ' ||
              'where name = :pd';
   EXECUTE IMMEDIATE v_WaitSQL INTO l_domainName USING p_dblink;
   dblink := p_dblink || '.' || l_domainName;

   --dblink := p_dblink || '.WORLD';
   --+Wait for Consolidation program to complete, the most is 10 hours
   if (p_cons_request_id <> 0) then
      success := fnd_concurrent.wait_for_request(p_cons_request_id,
                  30, 36000, phase, status, dev_phase, dev_status,
                  message);
      If dev_phase = 'COMPLETE' AND
         dev_status In ('NORMAL','WARNING' ) Then
         l_result := 'COMPLETE:PASS';
      Else
         l_result := 'COMPLETE:FAIL';
      End If;

      if p_debug = 'Y' then
         debug_message('Section number is ' || section_number,TRUE);
         debug_message('Pre run CI transfer has started, status is ' || l_result,TRUE);
      end if;
      --+debug_message('Pre run CI transfer has started, status is ' || l_result,TRUE);
      if l_result = 'COMPLETE:PASS' then
         --+debug_message('status is complete:pass',TRUE);
            l_source_group_id := Get_source_Group_id(consolidation_id, run_id);
         --+debug_message('source group id is ' || l_source_group_id,TRUE);

            l_ci_request_id := fnd_request.submit_request(
            'SQLGL',
            'GLCCIT',
            '',
            '',
            FALSE,
            p_Resp_Name,
            p_User_Name,
            p_dblink,
            l_source_group_id,
            from_sob_id,   --bug#2602596, to make sure subsidiary set of books name is in email
            To_Period_token,
            p_budget_name,
            p_j_import,
            p_j_post,
            p_Actual_Flag,
            p_Request_Id,
            p_csj_flag,
            'N',
            chr(0),'','','','','','','','','','',  -- 24 arguments so far
            '','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','',  -- 16 in a row
            '','','','','','','','','','','','');

            IF l_ci_request_Id <> 0 THEN
               --+cross instance data transfer program is submitted okay
               FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_ENTER_PRE');
               FND_MESSAGE.set_token('REQUEST', l_ci_request_id, FALSE);
               debug_message('==>' || FND_MESSAGE.get, TRUE);
            ELSE
               --+Cross instance data transfer program fails to start
               FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_FAIL_STARTCI');
               FND_MESSAGE.set_token('RESULT', SUBSTR(SQLERRM,1,200), FALSE);
               debug_message('==>' || FND_MESSAGE.get, TRUE);
            END IF;
      ELSE
         --+consolidation program fails for any reason.
         FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_PRE_FAIL');
         debug_message('==>' || FND_MESSAGE.get, TRUE);
      END IF; --+ end if complete:pass
   END IF; --+End if p_cons_request_id is not zero
END pre_run_CI_transfer;

end gl_ci_pre_cross_pkg;


--+ End of DDL script for GL_TEST_FND_REQUEST_PKG


--+ End of DDL script for GL_TEST_FND_REQUEST_PKG

/
