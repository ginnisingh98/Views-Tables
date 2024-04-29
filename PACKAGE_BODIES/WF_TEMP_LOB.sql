--------------------------------------------------------
--  DDL for Package Body WF_TEMP_LOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_TEMP_LOB" as
/* $Header: wflobb.pls 115.1 2003/09/10 12:16:24 vshanmug noship $ */

function GetLob(p_lob_tab in out nocopy wf_temp_lob_table_type)
return pls_integer
is
  m pls_integer;
begin
  -- search for a free lob
  for i in 1..p_lob_tab.COUNT loop
    if (p_lob_tab(i).free) then
      p_lob_tab(i).free := false;
      return(i);
    end if;
  end loop;

  -- if we reach here, there is no temp lob available, create one.
  m := p_lob_tab.COUNT+1;
  p_lob_tab(m).temp_lob := null;
  dbms_lob.createtemporary(p_lob_tab(m).temp_lob,true,DBMS_LOB.SESSION);
  p_lob_tab(m).free := false;

  return(m);

exception
  when OTHERS then
    wf_core.context('WF_TEMP_LOB','GetLob');
    raise;
end GetLob;

procedure ReleaseLob(
  p_lob_tab in out nocopy wf_temp_lob_table_type,
  loc in pls_integer)
is
begin
  if (loc > 0 and loc <= p_lob_tab.COUNT) then
    if (not p_lob_tab(loc).free) then
      dbms_lob.trim(p_lob_tab(loc).temp_lob,0);
      p_lob_tab(loc).free := true;
    end if;
  end if;

exception
  when OTHERS then
    wf_core.context('WF_TEMP_LOB','ReleaseLob');
    raise;
end ReleaseLob;

procedure ShowLob(p_lob_tab in out nocopy wf_temp_lob_table_type)
is
  buf varchar2(200);
  amt binary_integer := 200;
  len integer;
begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_TEMP_LOB.ShowLOB.Begin',
                      'Count: '||to_char(p_lob_tab.COUNT));
  end if;

  for i in 1..p_lob_tab.COUNT loop
    len := dbms_lob.getlength(p_lob_tab(i).temp_lob);

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_TEMP_LOB.ShowLOB.allocate',
                        'p_lob_tab('||to_char(i)||').temp_lob length:'||to_char(len));
    end if;

    if (p_lob_tab(i).free) then
       if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement,
                           'wf.plsql.WF_TEMP_LOB.ShowLOB.free',
                           'p_lob_tab('||to_char(i)||').temp_lob is free.');
       end if;
    else
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_TEMP_LOB.ShowLOB.used',
                          'p_lob_tab('||to_char(i)||').temp_lob is in use.');
      end if;

      if (len = 0) then
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_TEMP_LOB.ShowLOB.empty',
                            'lob content: empty');
        end if;
      else
        dbms_lob.read(p_lob_tab(i).temp_lob,amt,1,buf);
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_TEMP_LOB.ShowLOB.content',
                            'lob content: '||buf);
        end if;
      end if;
    end if;
  end loop;

exception
  when OTHERS then
    wf_core.context('WF_TEMP_LOB','ShowLob');
    raise;
end ShowLob;

END WF_TEMP_LOB;

/
