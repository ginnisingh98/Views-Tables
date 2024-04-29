--------------------------------------------------------
--  DDL for Package Body BSC_AW_DBMS_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_DBMS_AW" AS
/*$Header: BSCAWDBB.pls 120.4 2006/04/20 11:51 vsurendr noship $*/

procedure execute(p_stmt varchar2) is
Begin
  if g_debug then
    bsc_aw_utility.log_s('@@ '||p_stmt);
    bsc_aw_utility.log_s(' (S:'||bsc_aw_utility.get_time);
  end if;
  dbms_aw.interp_silent(p_stmt);
  if g_debug then
    bsc_aw_utility.log(',E:'||bsc_aw_utility.get_time||')');
  end if;
Exception when others then
  if bsc_aw_utility.is_sqlerror(sqlcode,'ignore') then
    if g_debug then
      bsc_aw_utility.log('Exception '||sqlcode||' ignored');
    end if;
  else
    bsc_aw_utility.log('Exception in execute '||p_stmt||' '||sqlerrm);
    raise;
  end if;
End;

--execute...but ignore exception
procedure execute_ne(p_stmt varchar2) is
Begin
  execute(p_stmt);
Exception when others then
  if g_debug then
    bsc_aw_utility.log('This error can be ignored');
  end if;
End;

--if we need the output from aw of executing a command
function interp(p_stmt varchar2) return varchar2 is
l_clob clob;
l_output varchar2(10000);
l_length number;
Begin
  if g_debug then
    bsc_aw_utility.log_s('@@ '||p_stmt);
    bsc_aw_utility.log_s(' (S:'||bsc_aw_utility.get_time);
  end if;
  l_length:=10000;
  l_clob:=dbms_aw.interp(p_stmt);
  dbms_lob.read(l_clob,l_length,1,l_output);
  if g_debug then
    bsc_aw_utility.log(',E:'||bsc_aw_utility.get_time||'), output='||l_output);
  end if;
  l_output:=ltrim(rtrim(l_output));
  return l_output;
Exception when others then
  if bsc_aw_utility.is_sqlerror(sqlcode,'ignore') then
    if g_debug then
      bsc_aw_utility.log('Exception '||sqlcode||' ignored');
    end if;
  else
    bsc_aw_utility.log('Exception in interp '||p_stmt||' '||sqlerrm);
    raise;
  end if;
End;


procedure init_all is
Begin
  g_debug:=bsc_aw_utility.g_debug;
Exception when others then
  null;
End;

END BSC_AW_DBMS_AW;

/
