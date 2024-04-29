--------------------------------------------------------
--  DDL for Package Body GL_CI_DATA_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CI_DATA_TRANSFER_PKG" as
/* $Header: glucitrb.pls 120.11.12010000.2 2010/03/12 09:40:26 sommukhe ship $ */
  own CONSTANT varchar2(30)       := 'GL';
  appSchema CONSTANT varchar2(30) := 'APPS';
  EMAIL_CONTACT_NOT_SET number    := -5;
  CONTACT_INFO_NOT_FOUND Number   := -4;
  nl CONSTANT varchar2(1)         := fnd_global.local_chr(10);
  j_import_menu_name varchar2(30) := 'GL_SU_J_IMPORT';
  j_post_menu_name varchar2(30)   := 'GL_SU_JOURNAL';
  i_parallel_name varchar2(30)    := 'GL_CONS_INTERFACE_';
  TYPE t_RefCur                   IS REF CURSOR;
  GLOBAL_ERROR                    exception;  --+something is wrong - general handler
  --+ Tell me what's wrong
  global_retcode                  number;
  global_errbuf                   varchar2(2000);
  section_number                  number(5);        --+where did I go wrong?
  applSysSchema                   varchar2(30);     --+bug#2630145, get applsys schema name
                                                    --+don't hardcoded the apps schema name
  domainName                      varchar2(150);    --+ bug fix for bug#2712006
  --+ a place to keep COA attributes
  chart                           gl_ci_remote_invoke_pkg.coa_table;    --+ holds coa attributes
  remote_chart                    gl_ci_remote_invoke_pkg.coa_table;    --+ holds coa attributes
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ Debug/Diagnostic routine
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure debug_message (
    message_string in varchar2               ,
    verbose_mode   in boolean   default FALSE,
    line_size      in number    default 255  ,
    which_file     in varchar2  default FND_FILE.log
  ) is
    msg_text       varchar2(10000);
    new_line       number;
  begin
    msg_text := substr(message_string, 1, 32000);
    new_line := 0;
    if verbose_mode then
      if message_string = fnd_global.local_chr(10) then
        FND_FILE.put(which_file, message_string);
      else
        while msg_text is not null loop
          new_line := instr(msg_text, fnd_global.local_chr(10));
          if new_line = 0            then new_line := line_size;
          elsif new_line > line_size then new_line := line_size;
          end if;
          --DBMS_OUTPUT.put_line( substr(msg_text, 1, new_line-1) );
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
  --+ send log messages to log file routine
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure log_message (
    message_string in varchar2               ,
    verbose_mode   in boolean   default FALSE,
    line_size      in number    default 255  ,
    which_file     in varchar2  default FND_FILE.log
  ) is
    msg_text       varchar2(10000);
    new_line       number;
  begin
    msg_text := substr(message_string, 1, 32000);
    new_line := 0;
    if verbose_mode then
      if message_string = fnd_global.local_chr(10) then
        FND_FILE.put(which_file, message_string);
      else
        while msg_text is not null loop
          new_line := instr(msg_text, fnd_global.local_chr(10));
          if new_line = 0            then new_line := line_size;
          elsif new_line > line_size then new_line := line_size;
          end if;
          --DBMS_OUTPUT.put_line( substr(msg_text, 1, new_line-1) );
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
  end log_message;
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
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ to fix bug#2630145, do not hardcoded the apps schema name
  --+ it could be anything at customer's site
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  PROCEDURE Get_Schema_Name (l_dblink  IN varchar2)
  is
    dummy1            varchar2(30);
    dummy2            varchar2(30);
    result            varchar2(150);
    v_SQL             varchar2(500);
    l_flag        varchar2(1);
    l_oracle_id   number;
    l_return          BOOLEAN; -- for some reason, this can't be boolean when
                               -- it is a returned value from native dynamic SQL
    l_apps_short_name varchar2(30);
    --FND_INSTALLATION.GET_APP_INFO returns a boolean, which is not a SQL type.
    --I can't compile the code if l-return is declared as a boolean
    --I can't execute the code if i omit the returned value.
    --I can't execute the code if I declare the l_return as varchar2(n) either.
    --I have to go back to use my original method of getting the schema name.
BEGIN
--    l_apps_short_name := 'FND';
--    v_SQL := 'BEGIN ' || ':rcode := fnd_installation.get_app_info@' || l_dblink ||
--                    '(:1, :2, :3, :4);' || ' END;';
--    EXECUTE IMMEDIATE v_SQL USING OUT l_return,IN l_apps_short_name, OUT dummy1, OUT dummy2, OUT applSysSchema;
    l_oracle_id := 900;
    l_flag := 'U';
    v_SQL := 'select oracle_username from fnd_oracle_userid@' || l_dblink ||
              ' where read_only_flag = :flag' ||
              ' and oracle_id = :or_id';
    EXECUTE IMMEDIATE v_SQL INTO applSysSchema USING l_flag, l_oracle_id;
    IF (applSysSchema IS NULL) THEN
      RAISE GLOBAL_ERROR;
    END IF;
    exception
    when GLOBAL_ERROR then
    rollback;
    result := SUBSTR(SQLERRM, 1, 200);
    FND_MESSAGE.set_name('SQLGL', 'gl_us_ci_others_fail');
    FND_MESSAGE.set_token('RESULT', result);
    app_exception.raise_exception;
END Get_Schema_Name;
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+bug#2712006, cannot use hardcoded domain name, get doamin name here.
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE Get_Domain_Name (l_dblink  IN varchar2)
is
   result            varchar2(500);
   v_SQL             varchar2(500);
BEGIN
   v_SQL := 'select domain_name ' ||
            'from rg_database_links ' ||
            'where name = :pd';

   EXECUTE IMMEDIATE v_SQL INTO domainName USING l_dblink;
   IF (domainName IS NULL) THEN
      RAISE GLOBAL_ERROR;
   END IF;
   exception
   when GLOBAL_ERROR then
      rollback;
      result := SUBSTR(SQLERRM, 1, 200);
      FND_MESSAGE.set_name('SQLGL', 'gl_us_ci_others_fail');
      FND_MESSAGE.set_token('RESULT', result);
      app_exception.raise_exception;
END Get_Domain_Name;
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ this function is called in the GLXCORUN.fmb to get the remote instance
  --+ data for a specific mapping rule from gl_consolidation_history table
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure Remote_Data_Map(
    p_name               IN varchar2,
    p_resp_name          IN OUT NOCOPY varchar2,
    p_user_name          IN OUT NOCOPY varchar2,
    p_db_name            IN OUT NOCOPY varchar2
  ) IS
  -- We get the information for the last consolidation run only
  CURSOR C IS
      SELECT h.*
      FROM   gl_consolidation_history h,
             gl_consolidation c
      WHERE  h.consolidation_id = c.consolidation_id
        AND  c.name = p_name
      ORDER BY h.last_update_date DESC;
  v_Cons        gl_consolidation_history%ROWTYPE;
  begin
    OPEN C;
    FETCH C INTO v_Cons;
    if (C%FOUND) then
      p_resp_name := v_Cons.Target_resp_name;
      p_user_name := v_Cons.Target_user_name;
      p_db_name := v_Cons.Target_database_name;
    else
      p_resp_name := null;
      p_user_name := null;
      p_db_name := null;
    end if;
    CLOSE C;
  end Remote_Data_Map;
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ this function is called in GLXCORST.fmb to get the remote instance data
  --+ for a specific mapping set from gl_consolidation_history table
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure Remote_Data_Map_Set(
    p_name               IN varchar2,
    p_resp_name          IN OUT NOCOPY varchar2,
    p_user_name          IN OUT NOCOPY varchar2,
    p_db_name            IN OUT NOCOPY varchar2
  ) IS
  -- We get the information for the last consolidation set run only
  CURSOR C IS
      SELECT h.*
      FROM   gl_consolidation_history h,
             gl_consolidation_sets c
      WHERE  h.consolidation_set_id = c.consolidation_set_id
        AND  c.name = p_name
      ORDER BY h.last_update_date DESC;
  v_Cons        gl_consolidation_history%ROWTYPE;
  begin
    OPEN C;
    FETCH C INTO v_Cons;
    if (C%FOUND) then
      p_resp_name := v_Cons.Target_resp_name;
      p_user_name := v_Cons.Target_user_name;
      p_db_name := v_Cons.Target_database_name;
    else
      p_resp_name := null;
      p_user_name := null;
      p_db_name := null;
    end if;
    CLOSE C;
  end Remote_Data_Map_Set;
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ this function is called to get the ledger id from the target db
  --+ access rights are also checked at this point.
  --+ If the ledger is not granted read/write access right, then the returned
  --+ ledger id is -1. An error message will be written to the log file.
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  function Get_Ledger_ID(
    user_id              IN number,
    resp_id              IN number,
    app_id               IN number,
    dblink               IN varchar2,
    access_set_id        OUT NOCOPY number,
    access_set           OUT NOCOPY varchar2,
    access_code          OUT NOCOPY varchar2,
    l_to_ledger_name     IN VARCHAR2
  ) return number
  IS
  ledger_id              number;
  test                   VARCHAR2(1);
  v_SQL                  varchar2(500);
  l_temp_db              varchar2(30);
  begin
     --still needs to get the apps schema name here, because this function
     --can be called from many places.
     l_temp_db := dblink || '.' || domainName;
     Get_Schema_name(L_TEMP_DB);    --+bug#2630145
     --Use Native Dynamic SQL
     v_SQL := 'BEGIN '||' :a := ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Get_Ledger_ID@' || l_temp_db
            || '(:user_id, :resp_id, :app_id, :id, :access_set, :code, :name)' ||';'||' END;';
     EXECUTE IMMEDIATE v_SQL USING OUT ledger_id, IN user_id,
                                   IN resp_id, IN app_id, OUT access_set_id, OUT access_set, OUT access_code, IN l_to_ledger_name;
     return ledger_id;
  end Get_Ledger_ID;
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ this function is called to get the Budget Version id from the target db
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  function Get_Budget_Version_ID(
    user_id              IN number,
    resp_id              IN number,
    app_id               IN number,
    dblink               IN varchar2,
    budget_name          IN varchar2
  ) return number
  IS
  budget_version_id      number;
  test                   VARCHAR2(1);
  v_SQL                  varchar2(500);
  begin
     --Get_Schema_name(dblink);    --+bug#2630145
     --Use Native Dynamic SQL
     v_SQL := 'BEGIN '||' :a := ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Get_Budget_Version_ID@' || dblink
              || '(:user_id, :resp_id, :app_id, :budget_name)' ||';'||' END;';
     EXECUTE IMMEDIATE v_SQL USING OUT budget_version_id, IN user_id, IN resp_id, IN app_id, IN budget_name;
     return budget_version_id;
  end Get_Budget_Version_ID;
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ this function is called to move consolidation data from source to target db
  --+ ORA-06512: at "GL_FND_REQUEST_PKG", line 205
  --+ need to commit from the source not at target database
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  FUNCTION Remote_Data_transfer(
  actual_flag            IN varchar2,
  user_id                IN number,
  resp_id                IN number,
  app_id                 IN number,
  dblink                 IN varchar2,
  source_ledger_id       IN number,
  pd_name                IN varchar2,
  budget_name            IN varchar2,
  group_id               IN number,
  request_id             IN number,
  p_dblink               IN varchar2,
  p_target_ledger_id     IN number,
  avg_flag               IN OUT NOCOPY varchar2,
  balanced_flag          IN OUT NOCOPY varchar2,
  errbuf                 IN OUT NOCOPY varchar2
  ) RETURN NUMBER
  IS
   l_source_ledger_id    number;
   l_group_id            number;
   v_InsertSQL           VARCHAR2(10000);
   l_out_table_name      varchar2(30);
   l_in_table_name       varchar2(30);
   l_pd_name             gl_interface.period_name%TYPE;
   v_BlockSQL            varchar2(300);
   v_SQL                 varchar2(1000);
   l_target_ledger_id    number;
   l_request_id          number;
   n                     number;
   l_count               number;
   l_cons_status         varchar2(50);
   l_entered_dr          number;
   l_entered_cr          number;
   l_db_username         varchar2(30);
   l_target_budget_version_id    number;
   l_budget_count        number;
   l_user_je_source_name  varchar2(25);
   l_adb_je_source        varchar2(25);
   l_je_source            varchar2(25);
   l_access_set_name      varchar2(30);
   l_r_adb_je_source      varchar2(25);
   l_r_je_source          varchar2(25);
   l_target_je_source      varchar2(25);
   l_temp_db        varchar2(30);
  begin
     l_adb_je_source := 'Average Consolidation';
     l_je_source := 'Consolidation';
     l_pd_name := pd_name;
     l_source_ledger_id := source_ledger_id;
     l_target_ledger_id := p_target_ledger_id;
     --+for debug from SQL Navigator, run consolidation from the Oracle Applications without
     --+Journal Import, use its group ID and consolidation concurrent request id to run this
     --+procedure, make sure you get source data from gl_interface table
     --+l_in_table_name := 'GL_INTERFACE';
     --Get_Domain_Name(dblink);
     --l_temp_db := dblink || '.' || domainName;
     initialize_over_dblink(user_id, resp_id, app_id, dblink);
     l_request_id := request_id;
     l_in_table_name := i_parallel_name || group_id;
     v_SQL := 'BEGIN '||' :l_group_id := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_Group_ID@' || dblink||';'||' END;';
     EXECUTE IMMEDIATE v_SQL USING OUT l_group_id;
     COMMIT;
     FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_GROUP_ID');
     FND_MESSAGE.set_token('GROUP', l_group_id);
     log_message('==>' || FND_MESSAGE.get, TRUE);
     v_SQL := 'select apps_username ' ||
              'from rg_database_links ' ||
              'where name = :pd';
     EXECUTE IMMEDIATE v_SQL INTO l_db_username USING p_dblink;
     v_BlockSQL := 'BEGIN '|| applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Create_Interface_Table@' || dblink||'(:l_group_id, :l_db_username);'||' END;';
     EXECUTE IMMEDIATE v_BlockSQL USING IN l_group_id,l_db_username;
     commit;
     --+dbms_output.put_line('after table is created in the target  ');
     FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_INTERFACE');
     FND_MESSAGE.set_token('GROUP', l_group_id);
     log_message('==>' || FND_MESSAGE.get, TRUE);
     l_out_table_name := i_parallel_name || l_group_id;
     if actual_flag = 'B' then
        l_target_budget_version_id := Get_Budget_Version_id(user_id, resp_id, app_id, dblink,budget_name);
        --bug fix #3095741, returns a meaningful error message when no matching budget is found in target
        if l_target_budget_version_id = -100 then
           errbuf := 'FAILED';
           return -1;
        end if;
     end if;
     --+ debug_message('Get target ledger id again' || l_target_ledger_id,TRUE);
     --+check if the journal entry is balanced
     v_SQL := 'select sum(round(entered_dr, 2)), sum(round(entered_cr, 2)) ' ||
             'from ' || l_in_table_name;
     EXECUTE IMMEDIATE v_SQL INTO l_entered_dr, l_entered_cr;
    --bug fix#3095489, return balanced_flag is Y when there is no data found
    --in the interface table. Need to take care of no data found properly.
     v_SQL := 'select count(*) ' ||
             'from ' || l_in_table_name;
    EXECUTE IMMEDIATE v_SQL INTO l_budget_count;
    if l_budget_count > 0 then
       if (l_entered_dr = l_entered_cr) then
          balanced_flag := 'Y';
       else
          balanced_flag := 'N';
       end if;
    else
       errbuf := 'NO_DATA_FOUND';
       return -1;
    end if;
    --+add this piece of code to decide if this is a ADB transfer or Balance transfer
     v_SQL := 'select user_je_source_name from gl_je_sources ' ||
                  'WHERE je_source_name = :s_name';
     EXECUTE IMMEDIATE v_SQL INTO l_user_je_source_name USING l_je_source;
     v_SQL := 'select count(*) from '|| l_in_table_name ||
                    ' where period_name = :pd_name' ||
                    ' and request_id = :rq_id' ||
                    ' and actual_flag = :flag' ||
                    ' and user_je_source_name = :s_name';
     EXECUTE IMMEDIATE v_SQL INTO l_count USING l_pd_name, l_request_id,
                                     actual_flag, l_user_je_source_name;
     --+dbms_output.put_line('select count form gl_cons_interface table ');
     --+Bug#3433592, unable to get data when trying to do Journal Import in
     --+the target db, because the user_je_source_name is different from the
     --+one in the source db.
     --+get the je source name from the target db. Insert this name
     --+into the gl_cons_interface table for the target.
     v_BlockSQL := 'BEGIN '|| applSysSchema ||
     '.GL_CI_REMOTE_INVOKE_PKG.Get_Target_Je_source_Name@' || dblink||
     '(:l_adb, :l_source);'||' END;';
     EXECUTE IMMEDIATE v_BlockSQL USING OUT l_r_adb_je_source, OUT l_r_je_source;
     if l_count > 0 then
        avg_flag := 'N';
        l_target_je_source := l_r_je_source;
     else
        v_SQL := 'select user_je_source_name from gl_je_sources ' ||
                  'WHERE je_source_name = :s_name';
        EXECUTE IMMEDIATE v_SQL INTO l_user_je_source_name USING l_adb_je_source;
        avg_flag := 'Y';
        l_target_je_source := l_r_adb_je_source;
     end if;
     --+dbms_output.put_line('what is this avg flag set? ' || avg_flag);
     v_InsertSQL := 'INSERT INTO ' || applSysSchema || '.' ||l_out_table_name ||'@' || dblink ||
                    ' (status, ledger_id,accounting_date,' ||
                    ' currency_code, date_created, created_by,' ||
                    ' actual_flag, user_je_category_name, user_je_source_name,' ||
                    ' currency_conversion_date, encumbrance_type_id,' ||
                    ' budget_version_id, user_currency_conversion_type,' ||
                    ' currency_conversion_rate, segment1, segment2,' ||
                    ' segment3, segment4, segment5, segment6,' ||
                    ' segment7, segment8, segment9, segment10,' ||
                    ' segment11, segment12, segment13,' ||
                    ' segment14, segment15, segment16,' ||
                    ' segment17, segment18, segment19,' ||
                    ' segment20, segment21, segment22,' ||
                    ' segment23, segment24, segment25,' ||
                    ' segment26, segment27, segment28,' ||
                    ' segment29, segment30, entered_dr,' ||
                    ' entered_cr, accounted_dr, accounted_cr,' ||
                    ' transaction_date, reference1, reference2,' ||
                    ' reference3, reference4, reference5,' ||
                    ' reference6, reference7, reference8,' ||
                    ' reference9, reference10, reference11,' ||
                    ' reference12, reference13, reference14,' ||
                    ' reference15, reference16, reference17,' ||
                    ' reference18, reference19, reference20,' ||
                    ' reference21, reference22, reference23,' ||
                    ' reference24, reference25, reference26,' ||
                    ' reference27, reference28, reference29,' ||
                    ' reference30, je_batch_id, period_name,' ||
                    ' je_header_id, je_line_num, chart_of_accounts_id,' ||
                    ' functional_currency_code,' ||
                    ' code_combination_id, date_created_in_gl,' ||
                    ' warning_code, status_description,' ||
                    ' stat_amount, group_id, request_id,' ||
                    ' subledger_doc_sequence_id, subledger_doc_sequence_value,' ||
                    ' attribute1, attribute2, attribute3,' ||
                    ' attribute4, attribute5, attribute6,' ||
                    ' attribute7, attribute8, attribute9,' ||
                    ' attribute10, attribute11, attribute12,' ||
                    ' attribute13, attribute14, attribute15,' ||
                    ' attribute16, attribute17, attribute18,' ||
                    ' attribute19, attribute20, context,' ||
                    ' context2, invoice_date, tax_code,' ||
                    ' invoice_identifier, invoice_amount,' ||
                    ' context3, ussgl_transaction_code,' ||
                    ' descr_flex_error_message, jgzz_recon_ref,' ||
                    ' average_journal_flag, originating_bal_seg_value,' ||
                    ' gl_sl_link_id, gl_sl_link_table,' ||
                    ' reference_date, balancing_segment_value, management_segment_value)' ||
                    ' SELECT' ||
                    ' status, :l_target_ledger_id, accounting_date,' ||
                    ' currency_code, date_created, created_by,' ||
                    ' actual_flag, user_je_category_name, :l_user_je_source_name,' ||
                    ' currency_conversion_date, encumbrance_type_id,' ||
                    ' :l_target_budget_version_id, user_currency_conversion_type,' ||
                    ' currency_conversion_rate, segment1, segment2,' ||
                    ' segment3, segment4, segment5, segment6,' ||
                    ' segment7, segment8, segment9, segment10,' ||
                    ' segment11, segment12, segment13,' ||
                    ' segment14, segment15, segment16,' ||
                    ' segment17, segment18, segment19,' ||
                    ' segment20, segment21, segment22,' ||
                    ' segment23, segment24, segment25,' ||
                    ' segment26, segment27, segment28,' ||
                    ' segment29, segment30, entered_dr,' ||
                    ' entered_cr, accounted_dr, accounted_cr,' ||
                    ' transaction_date, reference1, reference2,' ||
                    ' reference3, reference4, reference5,' ||
                    ' reference6, reference7, reference8,' ||
                    ' reference9, reference10, reference11,' ||
                    ' reference12, reference13, reference14,' ||
                    ' reference15, reference16, reference17,' ||
                    ' reference18, reference19, reference20,' ||
                    ' reference21, reference22, reference23,' ||
                    ' reference24, reference25, reference26,' ||
                    ' reference27, reference28, reference29,' ||
                    ' reference30, je_batch_id, period_name,' ||
                    ' je_header_id, je_line_num, chart_of_accounts_id,' ||
                    ' functional_currency_code,' ||
                    ' code_combination_id, date_created_in_gl,' ||
                    ' warning_code, status_description,' ||
                    ' stat_amount, group_id, request_id,' ||
                    ' subledger_doc_sequence_id, subledger_doc_sequence_value,' ||
                    ' attribute1, attribute2, attribute3,' ||
                    ' attribute4, attribute5, attribute6,' ||
                    ' attribute7, attribute8, attribute9,' ||
                    ' attribute10, attribute11, attribute12,' ||
                    ' attribute13, attribute14, attribute15,' ||
                    ' attribute16, attribute17, attribute18,' ||
                    ' attribute19, attribute20, context,' ||
                    ' context2, invoice_date, tax_code,' ||
                    ' invoice_identifier, invoice_amount,' ||
                    ' context3, ussgl_transaction_code,' ||
                    ' descr_flex_error_message, jgzz_recon_ref,' ||
                    ' average_journal_flag, originating_bal_seg_value,' ||
                    ' gl_sl_link_id, gl_sl_link_table,' ||
                    ' reference_date, balancing_segment_value, management_segment_value' ||
                    ' FROM ' ||l_in_table_name ||
                    ' where period_name = :pd_name' ||
                    ' and request_id = :rq_id' ||
                    ' and actual_flag = :flag' ||
                    ' and user_je_source_name = :je_source';
   EXECUTE IMMEDIATE v_InsertSQL USING l_target_ledger_id, l_target_je_source,
                    l_target_budget_version_id,l_pd_name, l_request_id,
                    actual_flag, l_user_je_source_name;
   COMMIT;
   RETURN l_group_id;
   --+Don't forget to drop the gl_cons_interface_n table from the source db
   exception
      when OTHERS then
       errbuf := SUBSTR(SQLCODE || ' ; ' || SQLERRM, 1, 150);
       RETURN -1;
END Remote_Data_transfer;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+check if the responsibility has access right to Journal Import and
--+Journal Post menu on the target database.
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FUNCTION Verify_Menu_Access(
   user_id          IN number,
   resp_id          IN number,
   app_id           IN number,
   p_dblink         IN varchar2,
   p_j_import       IN varchar2,
   p_j_post         IN varchar2
) RETURN VARCHAR2
IS
   v_SQL            varchar2(1000);
   dblink           varchar2(100);
   l_count          number;
   l_one            number;
   l_two            number;
   l_three          number;
   l_four           number;
   l_test           VARCHAR2(30);
   func_name        varchar2(30);
BEGIN
   l_count := 0;
   dblink := p_dblink ||'.' || domainName;
   v_SQL := 'BEGIN ' || ':test := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Menu_Validation@' ||dblink ||
                 '(:user_id, :resp_id, :app_id, :JI, :JP); ' || 'END;';
   EXECUTE IMMEDIATE v_SQL USING OUT l_test, IN user_id, IN resp_id, IN app_id, IN p_j_import, IN p_j_post;
   return l_test;
END Verify_Menu_Access;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+      Verify_Period
--+ verify if the source and the target has the same start_date, end_date,
--+ quarter_date and year_date for a specific ledger and period name.
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FUNCTION Verify_Period(
   p_pd_name          IN varchar2,
   user_id            IN number,
   resp_id            IN number,
   app_id             IN number,
   p_dblink           IN varchar2,
   p_ledger           IN number,
   p_r_ledger_id      IN number
) RETURN VARCHAR2
IS
   v_PDSQL            varchar2(300);
   dblink             varchar2(100);
   l_count            number;
   l_start_date       DATE;
   l_end_date         DATE;
   l_quarter_date     DATE;
   l_year_date        DATE;
   l_r_start_date     DATE;
   l_r_end_date       DATE;
   l_r_quarter_date   DATE;
   l_r_year_date      DATE;
   l_access_set_name  varchar2(30);
BEGIN
   dblink := p_dblink ||'.' || domainName;
   --input: target ledger id, period name
   v_PDSQL := 'BEGIN '||' :a := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Period_Exists@' || dblink
              || '(:ledger_id, :period_name)' ||';'||' END;';
   EXECUTE IMMEDIATE v_PDSQL USING OUT l_count, IN p_r_ledger_id, p_pd_name;
   if l_count = 1 then
      v_PDSQL := 'BEGIN ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Get_Period_Info@' || dblink ||
                    '(:1, :2, :3, :4, :5, :6);' || ' END;';
      EXECUTE IMMEDIATE v_PDSQL USING IN p_r_ledger_id, IN p_pd_name,
      OUT l_r_start_date, OUT l_r_end_date, OUT l_r_quarter_date, OUT l_r_year_date;
      v_PDSQL := 'select p.start_date, p.end_date, p.quarter_start_date, ' ||
                 'p.year_start_date from gl_periods' ||
                 ' p, gl_ledgers b ' ||
                 'where p.period_set_name = b.period_set_name ' ||
                 'and p.period_type = b.accounted_period_type ' ||
                 'and b.ledger_id = :s ' ||
                 'and p.period_name = :pd';
      EXECUTE IMMEDIATE v_PDSQL INTO l_start_date, l_end_date,
        l_quarter_date, l_year_date USING p_ledger, p_pd_name;
      if (l_r_start_date = l_start_date) AND
         (l_r_end_date = l_end_date) AND
         (l_r_quarter_date = l_quarter_date) AND
         (l_r_year_date = l_year_date) THEN
            return 'SUCCESS';
      ELSE
         return 'FAILURE';
      END IF;
   end if;
   return 'FAILURE';
END Verify_Period;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+   Verify_Ledger
--+verify the average daily balances flag is the same in both ledgers
--+verify the consolidation ledger flag is the same in both ledgers
--+validate primary currency code in the source ledger vs. the target
--+ledger
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FUNCTION Verify_Ledger(
   user_id          IN number,
   resp_id          IN number,
   app_id           IN number,
   p_dblink         IN varchar2,
   p_ledger         IN number,
   p_r_ledger_id    IN number) RETURN VARCHAR2
IS
   l_ledger_id         number;
   v_ledgerSQL         varchar2(300);
   v_R_ledgerSQL       varchar2(300);
   dblink           varchar2(100);
   l_daily_bal      varchar2(1);
   l_r_daily_bal    varchar2(1);
   l_cons_ledger       varchar2(1);
   l_r_cons_ledger     varchar2(1);
   l_cur_code          varchar2(15);
   l_r_cur_code        varchar2(15);
   l_access_set_name   varchar2(30);
BEGIN
   dblink := p_dblink ||'.' || domainName;
   l_ledger_id := p_ledger;
   v_ledgerSQL := 'select enable_average_balances_flag from gl_ledgers ' ||
               'where ledger_id = :ledger_id';
   EXECUTE IMMEDIATE v_ledgerSQL INTO l_daily_bal USING l_ledger_id;
   --+input: target ledger id
   v_R_ledgerSQL := 'BEGIN '||' :a := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_Daily_Balance_Flag@' || dblink
              || '(:ledger_id)' ||';'||' END;';
   EXECUTE IMMEDIATE v_R_ledgerSQL USING OUT l_r_daily_bal, IN p_r_ledger_id;
  --+dbms_output.put_line('what is the ledger id? ' || p_r_ledger_id);
   if l_daily_bal <> l_r_daily_bal then
      return 'FAILURE1';
   end if;
   v_ledgerSQL := 'select consolidation_ledger_flag from gl_ledgers ' ||
               'where ledger_id = :ledger_id';
   EXECUTE IMMEDIATE v_ledgerSQL INTO l_cons_ledger USING l_ledger_id;
   --+dbms_output.put_line('what is the source cons flag? ' || l_cons_ledger);
   v_R_ledgerSQL := 'BEGIN '||' :a := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_Cons_ledger_Flag@' || dblink
              || '(:ledger_id)' ||';'||' END;';
   EXECUTE IMMEDIATE v_R_ledgerSQL USING OUT l_r_cons_ledger, IN p_r_ledger_id;
   --+dbms_output.put_line('what is the target cons flag? ' || l_r_cons_ledger);
   if l_cons_ledger <> l_r_cons_ledger then
      return 'FAILURE1';
   end if;
   v_ledgerSQL := 'SELECT CURRENCY_CODE FROM GL_ledgers ' ||
               'WHERE ledger_id = :ledger_id';
   EXECUTE IMMEDIATE v_ledgerSQL INTO l_cur_code USING l_ledger_id;
   --+dbms_output.put_line('what is source currency ' || l_cur_code);
   v_R_ledgerSQL := 'BEGIN '||' :a := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_Currency_Code@' || dblink
              || '(:ledger_id)' ||';'||' END;';
   EXECUTE IMMEDIATE v_R_ledgerSQL USING OUT l_r_cur_code, IN p_r_ledger_id;
   --+dbms_output.put_line('what is target currency ' || l_r_cur_code);
   if l_cur_code <> l_r_cur_code then
      return 'FAILURE2';
   end if;
   return 'SUCCESS';
END Verify_Ledger;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+check if the chart of accounts structure in the source and target
--+database are the same
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FUNCTION Verify_COA(user_id IN number, resp_id IN number, app_id IN number,
                    p_dblink IN varchar2, p_ledger IN number,
                    p_r_ledger_id IN number) RETURN VARCHAR2
IS
   v_COACursor        t_RefCur;
   v_R_COACursor      t_RefCur;
   v_SQL              varchar2(2000);
   v_R_SQL            varchar2(3000);
   l_ledger_id        number;
   l_coa_id           number;
   v_ledgerSQL        varchar2(300);
   l_r_ledger_id      number;
   l_r_coa_id         number;
   v_R_ledgerSQL      varchar2(300);
   l_index            number;
   l_r_index          number;
   p_count            number;
   l_segment_num      FND_ID_FLEX_SEGMENTS.SEGMENT_NUM%TYPE;
   l_column_name      FND_ID_FLEX_SEGMENTS.APPLICATION_COLUMN_NAME%TYPE;
   l_display_size     FND_ID_FLEX_SEGMENTS.DISPLAY_SIZE%TYPE;
   l_r_segment_num    FND_ID_FLEX_SEGMENTS.SEGMENT_NUM%TYPE;
   l_r_column_name    FND_ID_FLEX_SEGMENTS.APPLICATION_COLUMN_NAME%TYPE;
   l_r_display_size   FND_ID_FLEX_SEGMENTS.DISPLAY_SIZE%TYPE;
   l_app_id           FND_ID_FLEX_SEGMENTS.APPLICATION_ID%TYPE;
   l_gl_short_name    FND_ID_FLEX_SEGMENTS.ID_FLEX_CODE%TYPE;
   result             varchar2(100);
   dblink             varchar2(100);
   l_access_set_name  varchar2(30);
BEGIN
   l_index := 1;
   l_r_index := 1;
   p_count := 1;
   dblink := p_dblink ||'.' || domainName;
   l_app_id := 101;
   l_gl_short_name := 'GL#';
   l_r_ledger_id := p_r_ledger_id;
   l_ledger_id := p_ledger;
   v_ledgerSQL := 'select chart_of_accounts_id from gl_ledgers ' ||
               'where ledger_id = :ledger_id';
   EXECUTE IMMEDIATE v_ledgerSQL INTO l_coa_id USING l_ledger_id;
   chart.DELETE;
   --+get coa information from the fnd table in the source database
   v_SQL := 'SELECT s.SEGMENT_NUM, ' ||
            's.APPLICATION_COLUMN_NAME, ' ||
            's.DISPLAY_SIZE ' ||
            'FROM FND_FLEX_VALUE_SETS vs, ' ||
            'FND_ID_FLEX_SEGMENTS s ' ||
            'WHERE vs.flex_value_set_id = s.flex_value_set_id ' ||
            'AND s.ID_FLEX_NUM = :coa_id ' ||
            'AND s.application_id = :app_id ' ||
            'AND s.id_flex_code = :gl' ||
            ' order by segment_num';
   OPEN v_COACursor FOR v_SQL USING l_coa_id, l_app_id, l_gl_short_name;
   LOOP
      FETCH v_COACursor INTO l_segment_num, l_column_name, l_display_size;
      EXIT WHEN v_COACursor%NOTFOUND;
      chart(l_index).segment_num := l_segment_num;
      chart(l_index).application_column_name := l_column_name;
      chart(l_index).display_size := l_display_size;
      --+dbms_output.put_line('Seg '||chart(l_index).segment_num ||
      --+      ' is '||chart(l_index).application_column_name||
      --+      ' size='||chart(l_index).display_size);
      l_index := l_index + 1;
   END LOOP;
   CLOSE v_COACursor;
   remote_chart.DELETE;
   v_R_ledgerSQL := 'BEGIN '||' :a := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_COA_Id@' || dblink
              || '(:ledger_id)' ||';'||' END;';
   EXECUTE IMMEDIATE v_R_ledgerSQL USING OUT l_r_coa_id, IN l_r_ledger_id;
   --+get coa information from the fnd table in the target database
   v_R_SQL := 'BEGIN '||applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.coa_info@' || dblink
              || '(:coa_id, :cnt)' ||';'||' END;';
   EXECUTE IMMEDIATE v_R_SQL USING IN l_r_coa_id, IN OUT l_r_index;
   if l_index <> l_r_index then
      result := 'COA Not matched';
      return result;
   end if;
   while p_count < l_index loop
      v_R_SQL := 'BEGIN '||applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_Detail_coa_info@' || dblink
              || '(:coa_id, :cnt, :1, :2)' ||';'||' END;';
      EXECUTE IMMEDIATE v_R_SQL USING IN l_r_coa_id, IN p_count, IN OUT l_r_column_name,
                        IN OUT l_r_display_size;
      if chart(p_count).display_size <> l_r_display_size then
         result := 'COA Not matched';
         return result;
      end if;
      if chart(p_count).application_column_name <> l_r_column_name then
         result := 'COA Not matched';
         return result;
      end if;
      p_count := p_count +1;
   end loop;
   return 'SUCCESS';
END Verify_COA;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+verify the remote login information, chart of accounts structure and
--+ledger characteristics, period specifics in the calendar
--+and Journal Import and Post menu access right
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FUNCTION Remote_Data_Validation(
   dblink           IN varchar2,
   p_resp_name      IN varchar2,
   p_pd_name        IN varchar2,
   p_ledger         IN number,
   p_j_import       IN varchar2,
   p_j_post         IN varchar2
) RETURN varchar2
IS

   test             varchar2(100);
   v_SQL1           varchar2(1000);
   v_SQL2           varchar2(1000);
   v_SelectSQL      varchar2(300);
   v_SelectSQL2     varchar2(300);
   v_SelectSQL3     varchar2(300);
   v_BlockSQL       varchar2(500);
   l_count          number;
   result           varchar2(200);
   return_result    varchar2(200);
   result_ledger    varchar2(200);
   result_period    varchar2(200);
   result_menu      varchar2(100);
   l_user_id        number;
   l_resp_id        number;
   l_app_id         number;
   l_temp_db        varchar2(30);
   l_error_code     number;
   l_user_name      varchar2(150);
   dummy1           varchar2(30);
   dummy2           varchar2(30);
   l_r_ledger_id    number;  -- target ledger_id
   l_access_set     varchar2(30);
   l_access_code    varchar2(1);
   l_access_set_id  number;
   t_ledger_name    varchar2(300);
   --l_temp_db        varchar2(30);
BEGIN
   SELECT name INTO t_ledger_name FROM gl_ledgers WHERE ledger_id = p_ledger;
   l_count := 0;
   --make sure db link exists
   v_SelectSQL := 'select count(*) from rg_database_links ' ||
                  'where name = :dblink';
   EXECUTE IMMEDIATE v_SelectSQL INTO l_count USING dblink;
   if l_count = 0 then
      result := 'GL_US_CI_VALID_FAIL_DB';
      return result;
   end if;
     Get_Domain_Name(dblink);
     l_temp_db := dblink || '.' || domainName;

   Get_Schema_Name(l_temp_db);   --bug#2630145
   --make sure this responsibility exists in the target db
   v_SQL1 := 'BEGIN ' || ':num := ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Validate_Resp@' ||l_temp_db ||
                 '(:resp_name); ' || 'END;';
   EXECUTE IMMEDIATE v_SQL1 USING OUT l_error_code, IN p_resp_name;
   if l_error_code = 2 then
      result := 'GL_US_CI_VALID_FAIL_RESP';
      return result;
   elsif l_error_code = 0 then
      result := 'SUCCESS';
   end if;
   --make sure the same user exists in the target db
   l_app_id := 101;
   --l_user_name := 'LEDGER';
   l_user_name := fnd_global.USER_NAME;   --bug#2543150, remove username from input
   v_SQL1 := 'BEGIN ' || ':num := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_Login_Ids@' || l_temp_db ||
                    '(:1, :2, :3, :4);' || ' END;';
   EXECUTE IMMEDIATE v_SQL1 USING OUT l_error_code, IN l_user_name, IN p_resp_name, OUT l_user_id, OUT l_resp_id;

     initialize_over_dblink(l_user_id, l_resp_id, l_app_id,l_temp_db);
   if l_error_code = 1 then
      result := 'GL_US_CI_VALID_FAIL_USER';
      return result;
   elsif l_error_code = 0 then
      result := 'SUCCESS';
   end if;
   --get the target ledger id
   l_r_ledger_id := Get_Ledger_id(l_user_id, l_resp_id, l_app_id,dblink, l_access_set_id, l_access_set, l_access_code,t_ledger_name);
   if l_r_ledger_id < 0 then
      result := 'GL_US_CI_NO_DEFAULT_LEDGER';
      return result;
   end if;
   if l_r_ledger_id >= 0 then
      if l_access_code <> 'B' then
         result := 'GL_US_CI_NO_ACCESS_RIGHTS';
         return result;
      end if;
   end if;
   return_result := Verify_COA(l_user_id, l_resp_id, l_app_id,
                    dblink, p_ledger, l_r_ledger_id);
   if return_result = 'SUCCESS' then
      result_ledger := Verify_Ledger(l_user_id, l_resp_id, l_app_id,
                       dblink, p_ledger, l_r_ledger_id);
      if result_ledger = 'SUCCESS' then
         result_period := Verify_Period(p_pd_name,l_user_id, l_resp_id,
                          l_app_id, dblink, p_ledger, l_r_ledger_id);
         if result_period = 'SUCCESS' then
            result:= 'SUCCESS';
         else
            result := 'GL_US_CI_VALIDATION_PERIOD';
            return result;
         end if;
      else
         if result_ledger = 'FAILURE1' then
            result := 'GL_US_CI_VALIDATION_LEDGER';
         elsif result_ledger = 'FAILURE2' then
            result := 'GL_US_CI_CURRENCY_CHECK';
         end if;
         return result;
      end if;
   else
      result := 'GL_US_CI_VALIDATION_COA';
      return result;
   end if;
   /** NEW_ADDED_START **/

   result_menu := Verify_Menu_Access(l_user_id, l_resp_id,l_app_id,dblink,p_j_import,p_j_post);
   if result_menu = 'IMPORT FAIL' then
      result := 'GL_US_CI_NO_IMPORT';
      return result;
   elsif result_menu = 'POST FAIL' then
      result := 'GL_US_CI_NO_POSTING';
      return result;
   else
      result := 'SUCCESS';
   end if;

  -- result := 'SUCCESS';
/** NEW_ADDED_END **/
   if result = 'SUCCESS' then
      result := 'GL_US_CI_VALIDATION_OK';
   end if;
   RETURN result;
exception
  WHEN OTHERS THEN
    rollback;
    result := SUBSTR(SQLERRM, 1, 200);
    FND_MESSAGE.set_name('SQLGL', 'gl_us_ci_others_fail');
    FND_MESSAGE.set_token('RESULT', result);
    app_exception.raise_exception;
    return result;
END Remote_Data_Validation;
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
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Compose_Import_message(
   l_reqJI_id                IN number,
   dblink                    IN varchar2,
   l_import_message_body     OUT NOCOPY varchar2
) IS
   v_SelectSQL               varchar2(500);
   v_ReturnCursor            t_RefCur;
   v_Batches                 gl_je_batches%ROWTYPE;
   l_batch_name              varchar2(100);
   l_batch_id                number;
   l_first_one               boolean;
BEGIN
   l_first_one := TRUE;
--   Get_Schema_Name(dblink);    --=bug#2630145
   v_SelectSQL := 'select * from ' || applSysSchema ||'.gl_je_batches@' || dblink ||
                  ' where name like ''%' || TO_CHAR(l_reqJI_id) || '%''';
   OPEN v_ReturnCursor FOR v_SelectSQL;
   LOOP  --+for every batch in this transfer
      FETCH v_ReturnCursor INTO v_Batches;
      EXIT WHEN v_ReturnCursor%NOTFOUND;
         l_batch_id := v_Batches.je_batch_id;
         v_SelectSQL := 'select name from ' || applSysSchema ||'.gl_je_batches@' || dblink ||
                        ' WHERE je_batch_id = :b_id';
         EXECUTE IMMEDIATE v_SelectSQL INTO l_batch_name USING l_batch_id;
         COMMIT;
         if l_first_one then
            l_import_message_body := l_import_message_body || l_batch_name;
            l_first_one := FALSE;
         else
            l_import_message_body := l_import_message_body ||', ' || l_batch_name;
         end if;
   END LOOP;
   CLOSE v_ReturnCursor;
END Compose_Import_Message;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+    Main Entry procedure for Cross Instance Consolidation Data Transfer
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure run_CI_transfer(
   errbuf                in out NOCOPY varchar2,
   retcode               in out NOCOPY varchar2,
   p_resp_name           IN varchar2,
   p_user_name           IN varchar2,
   p_dblink              IN varchar2,
   from_group_id         IN number,
   from_ledger_id        IN number,
   p_pd_name             IN varchar2,
   p_budget_name         IN varchar2,
   p_j_import            IN VARCHAR2,
   p_j_post              IN varchar2,
   p_actual_flag         IN varchar2,
   p_request_id          IN number,
   p_csj_flag            IN VARCHAR2,
   p_debug               IN varchar2
)
IS

   dblink                varchar2(30);
   l_inter_run_id        number;
   l_reqJI_id            number;
   l_reqPost_id          number;
   l_pd_name             gl_interface.period_name%TYPE;
   l_to_ledger_id        number;
   l_user_id             number;
   l_resp_id             number;
   l_app_id              number;
   l_to_group_id         number;
   v_SQL                 varchar2(500);
   v_WaitSQL             varchar2(500);
   v_TSQL                varchar2(1000);
   v_SelectSQL           varchar2(500);
   l_result              varchar2(100);
   l_verify              varchar2(100);
   l_postable_rows       number;
   l_batch_name          varchar2(100);
   l_batch_id            number;
   v_SQL1                varchar2(1000);
   v_SQL2                varchar2(2000);
   v_ReturnCursor        t_RefCur;
   v_Batches             gl_je_batches%ROWTYPE;
   l_posted_rows         number;
   l_status              varchar2(1);
   l_target_ledger_name  varchar2(30);
   l_post_run_id         number;
   l_return_code         number;
   l_import_message_body varchar2(4000);
   l_first_one           boolean;
   l_post_request_id     varchar2(3000);
   l_src_table_name      varchar2(30);
   l_avg_flag            varchar2(1);
   l_balanced_flag       varchar2(1);
   l_suspense_flag       varchar2(1);
   l_user_name           varchar2(150);
   --get debug mode from GL: Debug Mode profile option
   l_dmode_profile       fnd_profile_option_values.profile_option_value%TYPE;
   l_debug               varchar2(1);
   --+the data access set name, it is used in a error messsage.
   l_access_set_name     varchar2(30);
   l_access_code         varchar2(1);
   l_access_set_id       number;
   l_temp_db        varchar2(30);

   l_tgt_ld_name varchar2(30);


   CURSOR c_remote_ledger_name (cp_source_group_id gl_consolidation_history.group_id%TYPE) IS
    SELECT gc.to_ledger_name
    FROM gl_consolidation_v gc, gl_consolidation_history gch
    WHERE gc.consolidation_id = gch.consolidation_id
    AND gch.group_id = cp_source_group_id;

begin

   OPEN c_remote_ledger_name(from_group_id);
   FETCH c_remote_ledger_name INTO l_tgt_ld_name;
   CLOSE c_remote_ledger_name;

   section_number := 0;
   l_inter_run_id := 0;
   l_first_one := TRUE;
   l_import_message_body := NULL;
   l_post_request_id := NULL;
   l_pd_name := p_pd_name;
   --+bug#2712006, cannot use hardcoded domain name
   Get_Domain_Name(p_dblink);
   dblink := p_dblink || '.' || domainName;
   Get_Schema_Name(dblink);    --+bug#2630145, don't hardcoded apps schema name
   --added for 11ix. use debug profile option to determine the debug setting
   FND_PROFILE.GET('GL_DEBUG_MODE', l_dmode_profile);
   -- Determine if process will be run in debug mode
   IF (NVL(p_Debug, 'N') <> 'N') OR (l_dmode_profile = 'Y') THEN
     l_Debug := 'Y';
   ELSE
     l_Debug := 'N';
   END IF;
   if l_debug = 'Y' then
      debug_message('Running Cross Instance Data Transfer in debug mode',TRUE);
      debug_message('Section number is ' || section_number,TRUE);
      -- Turn trace on if process is run in debug mode
      EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';
   end if;
    --l_user_name := 'LEDGER';


   l_user_name := fnd_global.USER_NAME;  --bug#2543150, remove username
                                         --from Remote Option form
   v_SQL1 := 'BEGIN '||' :a := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_User_ID@' || dblink
              || '(:user_name)' ||';'||' END;';
   EXECUTE IMMEDIATE v_SQL1 USING OUT l_user_id, IN l_user_name;
   v_SQL1 := 'BEGIN '||' :a := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_Resp_ID@' || dblink
              || '(:resp_name)' ||';'||' END;';
   EXECUTE IMMEDIATE v_SQL1 USING OUT l_resp_id, IN p_resp_name;
   if l_debug = 'Y' then
      debug_message('User ID is ' || l_user_id || ' and Responsibility ID is ' || l_resp_id,TRUE);
   end if;
   section_number := 1;
   l_app_id := 101;
   --+get the target ledger id based on data access set in the target db
   --+ledger_id = -1, when no default ledger can be found for this data access set
   initialize_over_dblink(l_user_id, l_resp_id, l_app_id,dblink);
   l_to_ledger_id := Get_Ledger_id(l_user_id, l_resp_id,
                     l_app_id, p_dblink, l_access_set_id, l_access_set_name, l_access_code,l_tgt_ld_name);
   if l_to_ledger_id = -1 then
      FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_NO_DEFAULT_LEDGER');
      FND_MESSAGE.set_token('ACCESS_SET', l_access_set_name);
      log_message('==>' || FND_MESSAGE.get, TRUE);
      global_retcode := 1;
      raise GLOBAL_ERROR;
   end if;
   if l_to_ledger_id >= 0 then
      v_SQL1 := 'BEGIN '||' :a := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_Ledger_Name@' || dblink
              || '(:ledger_id)' ||';'||' END;';
      EXECUTE IMMEDIATE v_SQL1 USING OUT l_target_ledger_name, IN l_to_ledger_id;
      if l_debug = 'Y' then
         debug_message('Target ledger id is ' || l_to_ledger_id,TRUE);
         debug_message('Target ledger name is ' || l_target_ledger_name,TRUE);
      end if;
      if l_access_code <> 'B' then
         FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_NO_ACCESS_RIGHTS');
         FND_MESSAGE.set_token('LEDGER_NAME', l_target_ledger_name);
         log_message('==>' || FND_MESSAGE.get, TRUE);
         global_retcode := 1;
         raise GLOBAL_ERROR;
      end if;
   end if;
   --+check if the suspense posting is allowed for this ledger on the target instance
   v_SQL1 := 'BEGIN '||' :a := ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Get_Suspense_Flag@' || dblink
              || '(:ledger_id)' ||';'||' END;';
   EXECUTE IMMEDIATE v_SQL1 USING OUT l_suspense_flag, IN l_to_ledger_id;
   FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_ENTER_CI');
   log_message('==>' || FND_MESSAGE.get, TRUE);
   errbuf := FND_MESSAGE.get;
   global_errbuf := FND_MESSAGE.get;
   --+Add l_balanced_flag to check if total debits equal to total credits. if not, output warning message
   --+to log file.
   l_to_group_id := Remote_Data_transfer(p_actual_flag,l_user_id, l_resp_id, l_app_id,
                    dblink, from_ledger_id,l_pd_name, p_budget_name, from_group_id,
                    p_request_id, p_dblink, l_to_ledger_id,
                    l_avg_flag, l_balanced_flag, global_errbuf);
   --bug fix#3095741, return a meaningful error message when budget name is no found in the target db
   if (l_to_group_id = -1) and (global_errbuf = 'FAILED') then
      FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_NO_BUDGET');
      log_message('==>' || FND_MESSAGE.get, TRUE);
      global_errbuf := FND_MESSAGE.get;
      global_retcode := 2;
      raise GLOBAL_ERROR;
   end if;
   if (l_to_group_id = -1) and (global_errbuf = 'NO_DATA_FOUND') then
      FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_NO_DATA_FOUND');
      log_message('==>' || FND_MESSAGE.get, TRUE);
      global_errbuf := FND_MESSAGE.get;
      global_retcode := 1;
      raise GLOBAL_ERROR;
   end if;
   if l_to_group_id < 0 then
      FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_TRANSFER_FAIL');
      log_message('==>' || FND_MESSAGE.get, TRUE);
      global_errbuf := global_errbuf || ' ' || FND_MESSAGE.get;
      if l_debug = 'Y' then
         debug_message('Invalid Target group ID in section number ' || section_number,TRUE);
      end if;
      global_retcode := 1;
      raise GLOBAL_ERROR;
   else
      if (l_balanced_flag = 'Y') then
         FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_TRANSFER_OK');
         FND_MESSAGE.set_token('GROUP_ID', l_to_group_id);
         log_message('==>' || FND_MESSAGE.get, TRUE);
         errbuf := errbuf || ' ' || FND_MESSAGE.get;
      else
         FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_TRANSFER_OK');
         FND_MESSAGE.set_token('GROUP_ID', l_to_group_id);
         log_message('==>' || FND_MESSAGE.get, TRUE);
         errbuf := errbuf || ' ' || FND_MESSAGE.get;
         FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_IMBALANCED_OTHER');
         log_message('==>' || FND_MESSAGE.get, TRUE);
         errbuf := errbuf || ' ' || FND_MESSAGE.get;
      end if;
      IF (p_j_import = 'N') THEN
         --+populates the gl_interface_control table and gl_cons_interface_to_group_id table
         --+add an average flag to indicate whether this is a adb balances transfer or not
         v_SQL := 'BEGIN '||' :l_id := ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Apps_Initialize@' || dblink ||
           '(:usr_id, :rsp_id, :ap_id, :sb_id, :gp_id, :pd_name, :flag, :avg);'||' END;';
         EXECUTE IMMEDIATE v_SQL USING OUT l_inter_run_id, IN l_user_id, IN l_resp_id, IN l_app_id, IN l_to_ledger_id,
                  IN l_to_group_id, IN l_pd_name, IN p_actual_flag, IN l_avg_flag;
         commit;
      end if;
   end if;  --+if l_to_group_id < 0 then
   --+drop the gl_cons_interface_groupid table in the source db no matter what
   l_src_table_name := i_parallel_name || from_group_id;
   gl_journal_import_pkg.drop_table(l_src_table_name);
   if l_debug = 'Y' then
      debug_message('Data has been moved to Target database, target group ID is ' || l_to_group_id,TRUE);
   end if;
  IF (p_j_import = 'Y') THEN
     --+get the target ledger id
     section_number := 2;
     if l_debug = 'Y' then
        debug_message('Populates the gl_interface_control table on Target database',TRUE);
        debug_message('Updates the gl_cons_interface_' || l_to_group_id || ' on target database',TRUE);
     end if;
     --+populates the gl_interface_control table and gl_cons_interface_to_group_id table
     v_SQL := 'BEGIN '||' :l_id := ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Apps_Initialize@' || dblink ||
           '(:usr_id, :rsp_id, :ap_id, :sb_id, :gp_id, :pd_name, :flag, :avg);'||' END;';
     EXECUTE IMMEDIATE v_SQL USING OUT l_inter_run_id, IN l_user_id, IN l_resp_id, IN l_app_id, IN l_to_ledger_id,
                  IN l_to_group_id, IN l_pd_name, IN p_actual_flag, IN l_avg_flag;
     commit;
     --+dbms_output.put_line('interface run id is ' || l_inter_run_id);
     if l_debug = 'Y' then
        debug_message('Start Journal Import on Target database',TRUE);
     end if;
     --+Journal Import
     v_SQL := 'BEGIN' || ' :r_id := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Run_Journal_Import@' || dblink ||
           '(:usr_id, :rsp_id, :ap_id, :run_id, :sb_id, :csj_flag);' || ' END;';
     EXECUTE IMMEDIATE v_SQL USING OUT l_reqJI_id, IN l_user_id, IN l_resp_id, IN l_app_id,
                    IN l_inter_run_id, IN l_to_ledger_id, IN p_csj_flag;
     commit;
     if l_debug = 'Y' then
        debug_message('Journal Import has been submitted on Target database, the request ID is ' || l_reqJI_id,TRUE);
     end if;
     --+dbms_output.put_line('import sql is ' || v_SQL);
     if (l_reqJI_id <> 0) then
        --+Wait for Journal Import completes
        v_WaitSQL := 'BEGIN ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.wait_for_request@' || dblink ||
               '(:r_id, :result);' || ' END;';
        EXECUTE IMMEDIATE v_WaitSQL USING IN l_reqJI_id, OUT l_result;
        --COMMIT;
        if l_debug = 'Y' then
           debug_message('Section number is ' || section_number,TRUE);
           debug_message('Journal Import has completed, status is ' || l_result,TRUE);
        end if;
        if l_result = 'COMPLETE:PASS' then
           v_SQL2 := 'BEGIN ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Verify_Journal_Import@' || dblink ||
            '(:gp_id, :result);' || ' END;';
           EXECUTE IMMEDIATE v_SQL2 USING IN l_to_group_id, OUT l_verify;
           --commit;
           if l_debug = 'Y' then
              debug_message('The status after verifying journal import is ' || l_verify,TRUE);
           end if;
           if l_verify = 'SUCCESS' then
              FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_IMPORT_OK');
              FND_MESSAGE.set_token('RID', l_reqJI_id);
              log_message('==>' || FND_MESSAGE.get, TRUE);
              global_errbuf  := FND_MESSAGE.get;
              errbuf := errbuf || ' ' || FND_MESSAGE.get;
              --+dbms_output.put_line('Journal Import is successful  ' || l_reqJI_id || '  ' || l_to_group_id);
              if (p_j_post = 'Y') then
                 --+Journal Post
                 section_number := 3;
                 --+dbms_output.put_line('j post flag  is ' || p_j_post);
                 v_SelectSQL := 'select * from ' || applSysSchema || '.gl_je_batches@' || dblink ||
                  ' where name like ''%' || TO_CHAR(l_reqJI_id) || '%''';
                 OPEN v_ReturnCursor FOR v_SelectSQL;
                 LOOP  --+for every batch in this transfer
                    FETCH v_ReturnCursor INTO v_Batches;
                    EXIT WHEN v_ReturnCursor%NOTFOUND;
                    l_batch_id := v_Batches.je_batch_id;
                    l_status := 'U';
                    v_SQL2 := 'BEGIN ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Get_Postable_Rows@' || dblink ||
                                         '(:1, :2, :3, :4, :5, :6, :7);' || ' END;';
                    --+dbms_output.put_line('Get postable rows sql is ' || v_SQL2);
                    EXECUTE IMMEDIATE v_SQL2 USING IN l_to_ledger_id, IN l_pd_name,
                       IN l_batch_id, IN l_status, IN p_actual_flag, IN l_avg_flag, OUT l_postable_rows;
                    --commit;
                    if l_debug = 'Y' then
                       debug_message('After Journal Import, the number of postable rows is ' || l_postable_rows,TRUE);
                    end if;
                    --+dbms_output.put_line('Get postable rows  is ' || l_postable_rows);
                    v_SQL2 := 'BEGIN ' || applSysSchema || '.GL_CI_REMOTE_INVOKE_PKG.Run_Journal_Post@' || dblink ||
                    '(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12);' || ' END;';
                    --+dbms_output.put_line('sql is ' || v_SQL2);
                    EXECUTE IMMEDIATE v_SQL2 USING IN l_user_id, IN l_resp_id, IN l_app_id,
                       IN l_to_ledger_id, IN l_pd_name, IN l_to_group_id, IN l_reqJI_id,
                       IN l_batch_id, IN p_actual_flag, IN l_access_set_id, OUT l_post_run_id, OUT l_reqPost_id;
                    commit;
                    if l_debug = 'Y' then
                       debug_message('Section number is ' || section_number,TRUE);
                       debug_message('Journal Post has been submitted, the request ID is ' || l_reqPost_id,TRUE);
                    end if;
                    if (l_reqPost_id <> 0) then
                       --+Wait for Journal Posting completes
                       v_WaitSQL := 'BEGIN ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.wait_for_request@' || dblink ||
                       ' (:r_id, :result);' || ' END;';
                       EXECUTE IMMEDIATE v_WaitSQL USING IN l_reqPost_id, OUT l_result;
                       --COMMIT;
                       if l_debug = 'Y' then
                          debug_message('Journal Post is complete. The status is ' || l_result,TRUE);
                       end if;
                       if l_result = 'COMPLETE:PASS' then
                          --+dbms_output.put_line('Journal post complete');
                          v_SQL2 := 'BEGIN ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Verify_Journal_Post@' || dblink ||
                          '(:pd_name, :r, :ledger_id, :bid, :flag, :avg, :result);' || ' END;';
                          EXECUTE IMMEDIATE v_SQL2 USING IN l_pd_name, IN l_postable_rows,
                          IN l_to_ledger_id, IN l_batch_id, IN p_actual_flag, IN l_avg_flag, OUT l_verify;
                          --COMMIT;
                          --+dbms_output.put_line('After verify Journal post');
                          v_SQL2 := 'select name from ' || applSysSchema ||'.gl_je_batches@' || dblink ||
                                         ' WHERE je_batch_id = :b_id';
                          EXECUTE IMMEDIATE v_SQL2 INTO l_batch_name USING l_batch_id;
                          --COMMIT;
                          --+dbms_output.put_line('The name of the batch is' || l_batch_name);
                          --+dbms_output.put_line('The status of Verify Journal Post is ' || l_verify);
                          if l_debug = 'Y' then
                             debug_message('The status of Verify Journal Post is ' || l_verify,TRUE);
                          end if;
                          if l_verify = 'SUCCESS' then
                             FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_POSTING_OK');
                             FND_MESSAGE.set_token('RID', l_reqPost_id);
                             log_message('==>' || FND_MESSAGE.get, TRUE);
                             global_errbuf  := FND_MESSAGE.get;
                             errbuf := errbuf || ' ' || FND_MESSAGE.get;
                             --+ dbms_output.put_line('Journal Post is successful   ' ||l_reqPost_id);
                             if l_first_one then
                                l_import_message_body := l_import_message_body || l_batch_name;
                                l_post_request_id := l_post_request_id || l_reqPost_id;
                                l_first_one := FALSE;
                             else
                                l_import_message_body := l_import_message_body ||', ' || l_batch_name;
                                l_post_request_id := l_post_request_id || ', ' || l_reqPost_id;
                             end if;
                          else  --+ posting verify failed
                             if (l_balanced_flag = 'Y') then
                                FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_POSTING_FAIL');
                                FND_MESSAGE.set_token('RID', l_reqPost_id);
                                log_message('==>' || FND_MESSAGE.get, TRUE);
                                global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
                                global_retcode := 2;
                                raise GLOBAL_ERROR;
                             else
                                if (l_suspense_flag = 'N') then
                                   FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_IMBALANCED_OTHER');
                                   log_message('==>' || FND_MESSAGE.get, TRUE);
                                   global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
                                else
                                   FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_IMBALANCED_SUS');
                                   FND_MESSAGE.set_token('RID', l_reqPost_id);
                                   log_message('==>' || FND_MESSAGE.get, TRUE);
                                   global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
                                   errbuf := errbuf || ' ' || FND_MESSAGE.get;
                                end if;
                                FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_POSTING_FAIL');
                                FND_MESSAGE.set_token('RID', l_reqPost_id);
                                log_message('==>' || FND_MESSAGE.get, TRUE);
                                global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
                                global_retcode := 2;
                                raise GLOBAL_ERROR;
                             end if;
                          end if;
                       else  --+ posting status is COMPLETE:FAIL
                          FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_POSTING_FAIL');
                          FND_MESSAGE.set_token('RID', l_reqPost_id);
                          log_message('==>' || FND_MESSAGE.get, TRUE);
                          global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
                          global_retcode := 1;
                          raise GLOBAL_ERROR;
                       end if;  --+end of if wait for journal post is successful
                    else  --+For some reason, Journal Posting request id is zero
                       FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_POSTING_FAIL');
                       FND_MESSAGE.set_token('RID', l_reqPost_id);
                       log_message('==>' || FND_MESSAGE.get, TRUE);
                       global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
                       global_retcode := 1;
                       raise GLOBAL_ERROR;
                    end if;  --+ end of if Journal is Posted
                 END LOOP;
                 CLOSE v_ReturnCursor;
                 --+send one email for all posting
                 gl_ci_workflow_pkg.send_cit_wf_ntf(
                       p_request_id, 'JOURNAL_POSTED', p_dblink, l_batch_name,  --100 CHARS
                       ' ', l_target_ledger_name, ' ', l_inter_run_id, l_post_run_id, l_reqPost_id,
                       0, ' ', ' ', 'JOURNAL_POSTED', ' ', from_ledger_id, l_import_message_body,l_post_request_id, l_return_code);
                 --+bug#2750898, add more user friendly error message when
                 --+user email address is not set
                 if (l_return_code = EMAIL_CONTACT_NOT_SET) OR
                    (l_return_code = CONTACT_INFO_NOT_FOUND) then
                    FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_EMAIL_USER');
                    log_message('==>' || FND_MESSAGE.get, TRUE);
                 end if;
              ELSE --+do not post, so send email at this point
                 Compose_Import_message(l_reqJI_id, dblink,l_import_message_body);
                 gl_ci_workflow_pkg.send_cit_wf_ntf(
                        p_cons_request_id => p_request_id,
                        p_Action => 'JOURNAL_IMPORTED',
                        p_dblink => p_dblink,
                        p_batch_name => ' ',  --100 CHARS
                        p_source_database_name => ' ',
                        p_target_ledger_name => l_target_ledger_name,
                        p_interface_table_name => ' ',
                        p_interface_run_id => l_inter_run_id,
                        p_posting_run_id => 0,
                        p_request_id => l_reqJI_id,
                        p_group_id => 0,
                        p_send_to => ' ',
                        p_sender_name => ' ',
                        p_message_name =>'JOURNAL_IMPORTED',
                        p_send_from => ' ',
                        p_source_ledger_id => from_ledger_id,
                        p_import_message_body => l_import_message_body,
                        p_post_request_id => l_post_request_id,
                        p_Return_Code => l_return_code);
                 --+bug#2750898, add more user friendly error message when
                 --+user email address is not set
                 if (l_return_code = EMAIL_CONTACT_NOT_SET) OR
                    (l_return_code = CONTACT_INFO_NOT_FOUND) then
                    FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_EMAIL_USER');
                    log_message('==>' || FND_MESSAGE.get, TRUE);
                 end if;
              end if;  --+end of if Journal Post flag is on
           else  --+JI not verified
              FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_IMPORT_FAIL');
              FND_MESSAGE.set_token('RID', l_reqJI_id);
              log_message('==>' || FND_MESSAGE.get, TRUE);
              global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
              global_retcode := 2;
              raise GLOBAL_ERROR;
           end if;  --+end of if Journal Import is verified
        else  --+ JI status is COMPLETE:FAIL
           if (l_balanced_flag = 'Y') then
              FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_IMPORT_FAIL');
              FND_MESSAGE.set_token('RID', l_reqJI_id);
              log_message('==>' || FND_MESSAGE.get, TRUE);
              global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
              global_retcode := 1;
              raise GLOBAL_ERROR;
           else
              FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_IMPORT_FAIL');
              FND_MESSAGE.set_token('RID', l_reqJI_id);
              log_message('==>' || FND_MESSAGE.get, TRUE);
              global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
              if (l_suspense_flag = 'N') then
                 FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_IMBALANCED_NOSUS');
                 FND_MESSAGE.set_token('RID', l_reqji_id);
                 log_message('==>' || FND_MESSAGE.get, TRUE);
                 global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
                 global_retcode := 1;
                 raise GLOBAL_ERROR;
              else
                 FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_IMBALANCED_OTHER');
                 log_message('==>' || FND_MESSAGE.get, TRUE);
                 global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
                 global_retcode := 1;
                 raise GLOBAL_ERROR;
              end if;
           end if;
        end if;  --+end of if wait for journal import is successful
     else  --+JI request id is zero, for some reason, the concurrent request failed
        FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_JOURNAL_IMPORT_FAIL');
        FND_MESSAGE.set_token('RID', l_reqJI_id);
        log_message('==>' || FND_MESSAGE.get, TRUE);
        global_errbuf  := global_errbuf || ' ' || FND_MESSAGE.get;
        global_retcode := 1;
        raise GLOBAL_ERROR;
     end if;  --+end of if journal is imported
  ELSE  --+data transfer only
     gl_ci_workflow_pkg.send_cit_wf_ntf(
           p_cons_request_id => p_request_id,
           p_Action => 'DATA_TRANSFER_DONE',
           p_dblink => p_dblink,
           p_batch_name => ' ',  --100 CHARS
           p_source_database_name => ' ',
           p_target_ledger_name => l_target_ledger_name,
           p_interface_table_name => 'gl_cons_interface_' || l_to_group_id,
           p_interface_run_id => l_inter_run_id,
           p_posting_run_id => 0,
           p_request_id => 0,
           p_group_id => l_to_group_id,
           p_send_to => ' ',
           p_sender_name => ' ',
           p_message_name =>'DATA_TRANSFER_DONE',
           p_send_from => ' ',
           p_source_ledger_id => from_ledger_id,
           p_import_message_body => l_import_message_body,
           p_post_request_id => l_post_request_id,
           p_Return_Code => l_return_code);
      --+dbms_output.put_line('The end ');
      --+bug#2750898, add more user friendly error message when
      --+user email address is not set
      if (l_return_code = EMAIL_CONTACT_NOT_SET) OR
         (l_return_code = CONTACT_INFO_NOT_FOUND) then
         FND_MESSAGE.set_name('SQLGL', 'GL_US_CI_EMAIL_USER');
         log_message('==>' || FND_MESSAGE.get, TRUE);
      end if;
  end if;  --+end of if journal import flag is on
exception
  when GLOBAL_ERROR then
    rollback;
    retcode := global_retcode;
    errbuf := global_errbuf || SUBSTR(SQLERRM,1,200);
  when OTHERS then
    rollback;
    retcode := global_retcode;
    errbuf := SUBSTR(SQLERRM,1,255);
    FND_MESSAGE.set_name('SQLGL', 'gl_us_ci_others_fail');
    FND_MESSAGE.set_token('RESULT', errbuf);
    log_message('==>' || FND_MESSAGE.get, TRUE);
END Run_CI_transfer;

procedure initialize_over_dblink(
    user_id           IN NUMBER,
    resp_id           IN NUMBER,
    app_id            IN NUMBER,
    v_temp_db         IN VARCHAR2)
IS
  v_sql                 varchar2(1000);
  l_user_id NUMBER;
  l_resp_id NUMBER;
  l_apps_id NUMBER;
  v_sql_user_id      VARCHAR2(1000);
  v_sql_resp_id      VARCHAR2(1000);
  v_sql_app_id       VARCHAR2(1000);

BEGIN
   --fnd_global.Apps_Initialize(user_id, resp_id, resp_appl_id);
   v_sql := 'BEGIN ' || 'fnd_global.apps_initialize@' || v_temp_db||  '(:1, :2, :3);' || ' END;';
   v_sql_user_id := 'BEGIN ' || ':usr_id := fnd_global.user_id@' || v_temp_db|| ';   END;';
   v_sql_resp_id := 'BEGIN ' || ':rsp_id := fnd_global.resp_id@' || v_temp_db|| ';   END;';
   v_sql_app_id  := 'BEGIN ' || ':appl_id := fnd_global.resp_appl_id@' || v_temp_db|| ';  END;';
   EXECUTE IMMEDIATE v_sql_user_id USING OUT l_user_id;
   EXECUTE IMMEDIATE v_sql_resp_id USING OUT l_resp_id;
   EXECUTE IMMEDIATE v_sql_app_id USING OUT l_apps_id;

   IF l_user_id <> user_id OR l_resp_id <> resp_id OR l_apps_id <>  app_id THEN
     EXECUTE IMMEDIATE v_SQL USING IN user_id, IN resp_id,IN app_id;
   ELSE
     NULL;
   END IF;

END initialize_over_dblink;

end gl_ci_data_transfer_pkg;
--+ End of DDL script for GL_TEST_FND_REQUEST_PKG
--+ End of DDL script for GL_TEST_FND_REQUEST_PKG

/
