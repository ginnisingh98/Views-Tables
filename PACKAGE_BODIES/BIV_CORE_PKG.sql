--------------------------------------------------------
--  DDL for Package Body BIV_CORE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_CORE_PKG" as
/* $Header: bivcoreb.pls 115.45 2004/04/06 06:20:10 nbhamidi ship $ */
function  get_lookup_meaning(p_lookup_code varchar2) return varchar2 is
   l_meaning fnd_lookups.meaning % type;
begin
   select meaning into l_meaning from fnd_lookups
    where lookup_type  = 'BIV_LABELS'
      and lookup_code = p_lookup_code;
   return l_meaning;
   exception
     when others then return p_lookup_code;
end;
--------------------------------------------------------------------------
procedure get_parameter_values_all(p_param_values in out nocopy g_parameter_array,
                               p_total_values in out nocopy number,
                               p_param_str  varchar2,
                               p_param_name varchar2) is
   l_value_count number;
   l_value_str   varchar2(500);
   i             number;
begin
   l_value_str := biv_core_pkg.get_parameter_value(p_param_str,
                                               p_param_name,
                                               g_param_sep,
                                               g_value_sep);

/*
   biv_core_pkg.biv_debug('Param:'||p_param_str,g_report_id);
   biv_core_pkg.biv_debug( 'Values String for Param:'||p_param_name ||
                              '---->' || nvl(l_value_str,'NULL'),g_report_id);
   commit;
*/
   if (nvl(l_value_str,'NOT_FOUND') <> 'NOT_FOUND' ) then
       p_total_values := jtfb_dcf.get_multiselect_count(l_value_str,
                                                    g_multi_value_sep);
  /***
       biv_core_pkg.biv_debug('Total Value for :'||p_param_name ||
                              ' : ' ||to_char(p_total_values),g_report_id);
****/
       if (p_total_values > 100) then
          --dbms_output.put_line('Two Many Values for :'|| p_param_name);
         if (g_debug = 'Y') then
           biv_core_pkg.biv_debug('Too many values for :'||p_param_name ||
                              ' : ' ||to_char(p_total_values),g_report_id);
         end if;
       else
       for i in 1..p_total_values loop
           p_param_values(i) := jtfb_dcf.get_multiselect_value(
                                              l_value_str,
                                              i,
                                              g_multi_value_sep);
       end loop;
       end if;
   else
      p_total_values := 0;
   end if;
end;
------------------------------------------------------------------------------
/***********************
procedure get_parameter_values_all_73001(p_param_values in out nocopy g_parameter_array,
                               p_total_values in out nocopy number,
                               p_param_str  varchar2,
                               p_param_name varchar2,
                               p_param_sep  varchar2 default g_param_sep,
                               p_value_sep  varchar2 default g_value_sep)  as
  i number;
  x_start_pos number;
  x_end_pos   number;
  x_param_value varchar2(80);
begin
   i := 0;
   p_total_values := 0;
   x_start_pos := 1;
   loop
      x_param_value := get_parameter_value(p_param_str  ,
                                p_param_name ,
                                x_end_pos    ,
                                x_start_pos  ,
                                p_param_sep  ,
                                p_value_sep  );
      if ( x_param_value is null ) then exit; end if;
      i := i + 1;
      --dbms_output.put_line('From all proc, value:'|| x_param_value ||
      --                    to_char(x_end_pos));
      p_param_values(i) := x_param_value;
      x_start_pos := x_end_pos;
   end loop;
   p_total_values := i;
end;
************************************/
procedure prt_parameter_values(p_param_values in out nocopy g_parameter_array,
                               p_total_values in out nocopy number) as
  i number;
  l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
  i := 0;
  loop
      i := i + 1;
      if ( i > p_total_values) then exit; end if;
       /*
      dbms_output.put_line('Parameter value at index:'||
                            to_char(i) || ' is:'||
                            p_param_values(i)
                          );
       */
      if (l_debug = 'Y') then
         biv_core_pkg.biv_debug ('Parameter value at index:'||
                               to_char(i) || ' is:'||
                               p_param_values(i), g_report_id
                             );
      end if;
  end loop;
end;
  procedure biv_debug(p_msg varchar2,
                      p_report varchar2) is
    l_msg varchar2(4000);
    q_msg varchar2(6000);
  begin
    --if (nvl(g_debug,'N') = 'Y' ) then
       q_msg := replace(p_msg,g_local_chr,'<BR>');
       l_msg := substr(q_msg,1,4000);
       insert into biv_debug(report_id,message,creation_date,session_id,seq_no)
                      values(p_report,l_msg,sysdate,get_session_id, g_srl_no);
       g_srl_no := g_srl_no + 1;
       if (length(q_msg) > 4000) then
          l_msg := substr(q_msg,4001,4000);
          insert into biv_debug(report_id,message,creation_date,
                                session_id,seq_no)
                      values(p_report,l_msg,sysdate,get_session_id, g_srl_no);
          g_srl_no := g_srl_no + 1;
       end if;
       if (length(q_msg) > 8000) then
          l_msg := substr(q_msg,8001,4000);
          insert into biv_debug(report_id,message,creation_date,
                                session_id,seq_no)
                      values(p_report,l_msg,sysdate,get_session_id, g_srl_no);
          g_srl_no := g_srl_no + 1;
       end if;
       commit;
   -- end if;
  end biv_debug;
  -------------------------
  function  get_parameter_value(p_param_str  varchar2,
                                p_param_name varchar2,
                                p_param_end_pos in out nocopy number,
                                p_start_pos  number /*default 1*/,
                                p_param_sep  varchar2 /*default g_param_sep*/,
                                p_value_sep  varchar2 /*default g_value_sep*/)
                   return varchar2 is
     x_name_end  number;
     x_value_end number;
     x_param_str_len number;
     x_value_sep_len number;
     x_param_sep_len number;
     x_start_pos     number;
     x_param_name    varchar2(80);
     x_param_val     varchar2(80);
  begin
     x_param_str_len := length(p_param_str);
     x_value_sep_len := length(p_value_sep);
     x_param_sep_len := length(p_param_sep);
     x_param_val  := null;
     x_start_pos  := p_start_pos;
     loop
       p_param_end_pos := 0;
       --dbms_output.put_line('Start Loop');
       --dbms_output.put_line('String Length:'||to_char(x_param_str_len));
       --dbms_output.put_line('Parameter Name:'||p_param_name);
       --dbms_output.put_line('Starting Pos:'||to_char(x_start_pos));
       if ( x_start_pos < x_param_str_len ) then
          x_name_end := instr(p_param_str,p_value_sep,x_start_pos);
          if (x_name_end = 0) then return null; --'NOVALSEP';
          end if;
          x_param_name := substr(p_param_str,x_start_pos,
                                              x_name_end-x_start_pos);
          x_value_end := instr(p_param_str,p_param_sep,
                                              x_name_end+x_value_sep_len);
       --dbms_output.put_line('name end:'||to_char(x_name_end));
       --dbms_output.put_line('value end:'||to_char(x_value_end));
          if (x_value_end = 0) then
             --  return 'NOPARAMSEP';
             return null;
          end if;
          if ( x_param_name = p_param_name) then
             x_param_val := substr(p_param_str,x_name_end+x_value_sep_len,
                                   x_value_end-x_name_end-x_value_sep_len);
             p_param_end_pos := x_value_end+x_param_sep_len;
             return(x_param_val);
          end if;
          x_start_pos := x_value_end + x_param_sep_len;
          --dbms_output.put_line('Parameter Name :'||x_param_name);
          --dbms_output.put_line('Parameter Value:'||x_param_val);
          --dbms_output.put_line('Start and End Pos:'||to_char(x_start_pos));
          --dbms_output.put_line('x_name_end:'||to_char(x_name_end));
          --dbms_output.put_line('----------');
          --p_end_pos := x_value_end + x_param_sep_len;
       else
          --p_end_pos := -1;
          exit;
       end if;
     end loop;
       --dbms_output.put_line('Parameter Name :'||p_param_name);
       --dbms_output.put_line('Parameter Value:'||x_param_val);
       --dbms_output.put_line('Start and End Pos:'||to_char(x_start_pos));
       --dbms_output.put_line('x_name_end:'||to_char(x_name_end));
       --dbms_output.put_line('----------');
     return(null);
  end get_parameter_value;
  function  get_parameter_value(p_param_str  varchar2,
                                p_param_name varchar2,
                                p_param_sep  varchar2 /*default g_param_sep*/,
                                p_value_sep  varchar2 /*default g_value_sep*/)
                   return varchar2 as
     x_param_end_pos number;
     l_val varchar2(400);
  begin
     l_val := jtfb_dcf.get_parameter_value(p_param_str,
                                           p_param_name,
                                           g_param_sep,
                                           g_value_sep);
    /***********************************************
     dbms_output.put_line('Lval:'||p_param_str || '-' ||
                              p_param_name || ':' ||l_val);
     ***********************************************/
     if (l_val = 'NOT_FOUND') then return null;
     elsif ltrim(l_val) is null then return null;
     else  return l_val;
     end if;
  /*****************************
     return( get_parameter_value(p_param_str,
                                p_param_name,
                                x_param_end_pos,
                                1,
                                p_param_sep,
                                p_value_sep)
           );
  **********************/
  end;
  procedure yesterday(x_start_date in out nocopy date,
                      x_end_date   in out nocopy date) is
     x_date date;
  begin
    x_date := sysdate -1;
    x_start_date := to_date(to_char(x_date,'dd-mon-yyyy') || ' 00:00:00',
                            'dd-mon-yyyy hh24:mi:ss');
    x_end_date   := to_date(to_char(x_date,'dd-mon-yyyy') || ' 23:59:59',
                            'dd-mon-yyyy hh24:mi:ss');
  end;
  procedure last_year(x_start_date in out nocopy date,
                      x_end_date   in out nocopy date) as
     x_date date;
  begin
     x_date := add_months(sysdate,-12);
    x_start_date := to_date('01-jan-' ||to_char(x_date,'yyyy') || ' 00:00:00',
                            'dd-mon-yyyy hh24:mi:ss');
    x_end_date   := to_date('31-dec-' ||to_char(x_date,'yyyy') || ' 23:59:59',
                            'dd-mon-yyyy hh24:mi:ss');
  end;
  procedure last_month(x_start_date in out nocopy date,
                       x_end_date   in out nocopy date) as
    x_date date;
  begin
    x_date := to_date('01-' || to_char(add_months(sysdate,-1),'mon-yyyy'),
                        'dd-mon-yyyy');

    x_start_date := to_date(to_char(x_date,'dd-mon-yyyy') || ' 00:00:00',
                            'dd-mon-yyyy hh24:mi:ss');
    x_date := add_months(x_date,1) -1;
    x_end_date   := to_date(to_char(x_date,'dd-mon-yyyy') || ' 23:59:59',
                            'dd-mon-yyyy hh24:mi:ss');
  end;
  procedure last_week (x_start_date in out nocopy date,
                       x_end_date   in out nocopy date) as
    x_date date;
    l_sat  varchar2(80);
  begin
    l_sat := to_char(to_date('01/01/2000','dd/mm/yyyy'),'dy');
    if (g_debug = 'Y') then
       biv_core_pkg.biv_debug('Saturday in nls Lang:' || l_sat, g_report_id);
    end if;
    x_date := next_day(sysdate,l_sat) - 13;
    x_start_date := to_date(to_char(x_date,'dd-mon-yyyy') || ' 00:00:00',
                            'dd-mon-yyyy hh24:mi:ss');
    x_date := x_date +6;
    x_end_date   := to_date(to_char(x_date,'dd-mon-yyyy') || ' 23:59:59',
                            'dd-mon-yyyy hh24:mi:ss');
  end;
  procedure last_13weeks(x_start_date in out nocopy date,
                         x_end_date   in out nocopy date) as
     x_date date;
  begin
     last_week(x_start_date,x_end_date);
     x_start_date := x_start_date - 12* 7;
  end;
  procedure get_dates   (p_period_type       varchar2,
                         x_start_date in out nocopy date,
                         x_end_date   in out nocopy date) as
  begin
    if (p_period_type = 'YDAY') then
       yesterday(x_start_date, x_end_date);
    elsif (p_period_type = 'LY') then
       last_year(x_start_date, x_end_date);
    elsif (p_period_type = 'LM') then
       last_month(x_start_date, x_end_date);
    elsif (p_period_type = 'LW') then
       last_week(x_start_date, x_end_date);
    elsif (p_period_type = 'L13W') then
       last_13weeks(x_start_date, x_end_date);
    end if;
    -- truncate x_end_date because time component 23:59:59 is taken care of in
    -- sql query. such as sr.incident_date < (g_cr_end + 1)
    x_end_date := trunc(x_end_date);
  end;
-- This procedure extracts all possible parameters from parameter string
-- and sets global varibale for respective parameter.
procedure get_report_parameters(p_param_str varchar2) as
  l_dt     varchar2(30);
  l_dt_fmt varchar2(30) := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
begin
  g_debug := fnd_profile.value('BIV:DEBUG');
  g_cust_id_cnt     := 0;
  g_cntr_id_cnt     := 0;
  g_ogrp_cnt        := 0;
  g_agrp_cnt        := 0;
  g_prd_id_cnt      := 0;
  g_sev_cnt         := 0;
  g_esc_lvl_cnt     := 0;
  g_prd_ver_cnt     := 0;
  g_comp_id_cnt     := 0;
  g_subcomp_id_cnt  := 0;
  g_platform_id_cnt := 0;
  g_sts_id_cnt      := 0;
  g_debug := fnd_profile.value('BIV:DEBUG');
  --g_srl_no          := 1;
  biv_core_pkg.get_parameter_values_all(g_cust_id            ,
                           g_cust_id_cnt        ,
                           p_param_str              ,
                           'P_CUST_ID');
  biv_core_pkg.get_parameter_values_all(g_cntr_id            ,
                           g_cntr_id_cnt        ,
                           p_param_str              ,
                           'P_CNTR_ID');
  biv_core_pkg.get_parameter_values_all(g_ogrp     ,
                           g_ogrp_cnt ,
                           p_param_str              ,
                           'P_OGRP');
  biv_core_pkg.get_parameter_values_all(g_agrp       ,
                           g_agrp_cnt   ,
                           p_param_str              ,
                           'P_AGRP');
  biv_core_pkg.get_parameter_values_all(g_prd_id                ,
                           g_prd_id_cnt            ,
                           p_param_str              ,
                           'P_PRD_ID');
  biv_core_pkg.get_parameter_values_all(g_sev      ,
                           g_sev_cnt  ,
                           p_param_str              ,
                           'P_SEV');
  biv_core_pkg.get_parameter_values_all(g_esc_lvl ,
                           g_esc_lvl_cnt          ,
                           p_param_str              ,
                           'P_ESC_LVL');
  biv_core_pkg.get_parameter_values_all(g_prd_ver ,
                           g_prd_ver_cnt          ,
                           p_param_str              ,
                           'P_PRD_VER');
  biv_core_pkg.get_parameter_values_all(g_comp_id ,
                           g_comp_id_cnt          ,
                           p_param_str              ,
                           'P_COMP_ID');
  biv_core_pkg.get_parameter_values_all(g_subcomp_id ,
                           g_subcomp_id_cnt          ,
                           p_param_str              ,
                           'P_SUBCOMP_ID');
  biv_core_pkg.get_parameter_values_all(g_platform_id ,
                           g_platform_id_cnt          ,
                           p_param_str              ,
                           'P_PLATFORM_ID');
  biv_core_pkg.get_parameter_values_all(g_sts_id ,
                           g_sts_id_cnt          ,
                           p_param_str              ,
                           'P_STS_ID');
  biv_core_pkg.get_parameter_values_all(g_mgr_id ,
                           g_mgr_id_cnt          ,
                           p_param_str              ,
                           'P_MGR_ID');
  biv_core_pkg.get_parameter_values_all(g_site_id ,
                           g_site_id_cnt          ,
                           p_param_str              ,
                           'P_SITE_ID');

  -- get all parameters which return single value
  g_rsc        := biv_core_pkg.get_parameter_value(p_param_str, 'P_RSC');
  g_blog       := biv_core_pkg.get_parameter_value(p_param_str, 'P_BLOG');
  g_other_blog := biv_core_pkg.get_parameter_value(p_param_str, 'P_OTHER_BLOG');
  g_chnl       := biv_core_pkg.get_parameter_value(p_param_str, 'P_CHNL');
  -- Change for bug 3093779 starts
  g_ua         := biv_core_pkg.get_parameter_value(p_param_str,'P_UA');

  if (g_ua is null) then
      g_ua := 'Y';
  end if;

  g_pr         := biv_core_pkg.get_parameter_value(p_param_str,'P_PREVR');

  if(g_pr is null) then
      g_pr := 'N';
  end if;

  -- Change for bug 3093779 ends

  -- Change for enh 2914005 starts
  g_total      := biv_core_pkg.get_parameter_value(p_param_str,'P_TOTAL');

  if (g_total is null) then
       g_total := 'N';
  end if;

  -- Change for enh 2914005 ends

  if (g_chnl = 'ALL') then
      g_chnl := null;
  end if;
  g_resl_code  := biv_core_pkg.get_parameter_value(p_param_str, 'P_RESL_CODE');
  g_arvl_tm    := biv_core_pkg.get_parameter_value(p_param_str, 'P_ARVL_TM');
  g_close_sr   := biv_core_pkg.get_parameter_value(p_param_str, 'P_CLOSE_SR');
  g_oblog      := biv_core_pkg.get_parameter_value(p_param_str, 'P_OBLOG');
  g_eblog      := biv_core_pkg.get_parameter_value(p_param_str, 'P_EBLOG');
  g_reopen     := biv_core_pkg.get_parameter_value(p_param_str, 'P_REOPEN');
  g_reclose    := biv_core_pkg.get_parameter_value(p_param_str, 'P_RECLOSE');
  g_new_sr     := biv_core_pkg.get_parameter_value(p_param_str, 'P_NEW_SR');
  g_agent_id   := biv_core_pkg.get_parameter_value(p_param_str, 'P_AGENT_ID');
  g_today_only := biv_core_pkg.get_parameter_value(p_param_str, 'P_TODAY_ONLY');
  g_tm_zn      := biv_core_pkg.get_parameter_value(p_param_str, 'P_TM_ZN');
  g_ott        := biv_core_pkg.get_parameter_value(p_param_str, 'P_OTT');
  g_unown      := biv_core_pkg.get_parameter_value(p_param_str, 'P_UNOWN');
  g_esc_sr     := biv_core_pkg.get_parameter_value(p_param_str, 'P_ESC_SR');
  l_dt         := biv_core_pkg.get_parameter_value(p_param_str, 'P_ST_DATE');
  g_st_date    := to_date(l_dt,l_dt_fmt);
  l_dt         := biv_core_pkg.get_parameter_value(p_param_str, 'P_END_DATE');
  g_end_date   := to_date(l_dt,l_dt_fmt);
  l_dt         := biv_core_pkg.get_parameter_value(p_param_str, 'P_CR_ST');
  g_cr_st      := to_date(l_dt,l_dt_fmt);
  l_dt         := biv_core_pkg.get_parameter_value(p_param_str, 'P_CR_END');
  g_cr_end     := to_date(l_dt,l_dt_fmt);
  l_dt         := biv_core_pkg.get_parameter_value(p_param_str, 'P_CL_ST');
  g_cl_st      := to_date(l_dt,l_dt_fmt);
  l_dt         := biv_core_pkg.get_parameter_value(p_param_str, 'P_CL_END');
  g_cl_end     := to_date(l_dt,l_dt_fmt);
  l_dt         := biv_core_pkg.get_parameter_value(p_param_str, 'P_ESC_ST');
  g_esc_st      := to_date(l_dt,l_dt_fmt);
  l_dt         := biv_core_pkg.get_parameter_value(p_param_str, 'P_ESC_END');
  g_esc_end     := to_date(l_dt,l_dt_fmt);

  g_lvl  := biv_core_pkg.get_parameter_value(p_param_str, 'P_LVL');
  g_agrp_lvl  := biv_core_pkg.get_parameter_value(p_param_str, 'P_AGRP_LVL');
  g_ogrp_lvl  := biv_core_pkg.get_parameter_value(p_param_str, 'P_OGRP_LVL');
  g_srt_by   := biv_core_pkg.get_parameter_value(p_param_str,'P_SRT_BY');
  if (g_srt_by is null) then
      g_srt_by := '2';
  end if;
  g_view_by    := biv_core_pkg.get_parameter_value(p_param_str,'P_VIEW_BY');
  if (g_view_by is null ) then
     if (g_report_id in ('BIV_RT_MANAGER_REPORT',
                         'BIV_RT_BACKLOG_BY_STATUS','BIV_HS_SR_ACTIVITY',
                         'BIV_RT_ESC_SR',
                         'BIV_HS_SR_ESCALATION', 'BIV_RT_TASK_ACTIVITY')
        )then
        g_view_by := 'MGR';
     elsif (g_debug = 'Y') then
        biv_core_pkg.biv_debug('No default view by for the report '||
                               g_report_id, g_report_id);
     end if;
  end if;
  if (g_debug = 'Y') then
     biv_core_pkg.biv_debug('Report Id:'||g_report_id,g_report_id);
  end if;
  g_disp    := biv_core_pkg.get_parameter_value(p_param_str,'P_DISP');
  if (g_disp is null) then
     g_disp := 10;
  elsif (upper(g_disp) = 'ALL') then
     g_disp := '5000';
/*
  else
     g_display := substr(g_display,2);
***/
  end if;
  g_time_frame := biv_core_pkg.get_parameter_value(p_param_str,'P_TIME_FRAME');
  g_cr_tm_prd  :=
    biv_core_pkg.get_parameter_value(p_param_str,'P_CR_TM_PRD');
  g_cl_tm_prd  :=
    biv_core_pkg.get_parameter_value(p_param_str,'P_CL_TM_PRD');
  g_esc_tm_prd  :=
    biv_core_pkg.get_parameter_value(p_param_str,'P_ESC_TM_PRD');

  -- get base column for query
  if (   g_view_by  ='AGRP') then
     g_base_column := 'adnorm.parent_group_id';
  elsif (g_view_by  ='OGRP') then
     g_base_column := 'odnorm.parent_group_id';
  elsif (g_view_by  = 'MGR') then
     g_base_column := 'rsc.source_mgr_id';
  elsif (g_view_by  = 'CUST') then
     g_base_column := 'sr.customer_id';
  elsif (g_view_by  = 'PRD') then
     g_base_column := 'sr.inventory_item_id ';
     g_prd_org := fnd_profile.value('CS_INV_VALIDATION_ORG');
                                    --ASO_PRODUCT_ORGANIZATION_ID');
  elsif (g_view_by  = 'CNTRCT') then
     g_base_column := 'sr.contract_number';
  elsif (g_view_by  = 'ESCONR') then
     g_base_column := 'srs.esc_owner_id';
  elsif (g_view_by  = 'SSITE') then
     g_base_column := 'sr.site_id';
  elsif (g_view_by  = 'AGENT') then
     g_base_column := 'sr.incident_owner_id';
  else
     g_base_column := null;
  end if;

  -- set start and end dates based on time frame
  if (g_time_frame is not null and
        (g_st_date is null or g_end_date is null)) then
     biv_core_pkg.get_dates(g_time_frame, g_st_date, g_end_date);
  end if;
  if (g_cr_tm_prd is not null and
       (g_cr_st is null or g_cr_end is null) ) then
     biv_core_pkg.get_dates(g_cr_tm_prd,
                            g_cr_st, g_cr_end);
  end if;
  if (g_cl_tm_prd is not null  and
       (g_cl_st is null or g_cl_end is null)) then
     biv_core_pkg.get_dates(g_cl_tm_prd,
                            g_cl_st, g_cl_end);
  end if;
  if (g_esc_tm_prd is not null  and
       (g_esc_st is null or g_esc_end is null)) then
     biv_core_pkg.get_dates(g_esc_tm_prd, g_esc_st, g_esc_end);
     g_esc_st  := trunc(g_esc_st );
     g_esc_end := trunc(g_esc_end);
  end if;
  exception
     when others then
       if (g_debug = 'Y' ) then
          biv_debug('Error:'||substr(sqlerrm,1,200), g_report_id);
       end if;
end;
------------------------------------------------------------
procedure add_a_bind(p_cursor number,
                     p_param_array         biv_core_pkg.g_parameter_array,
                     p_param_array_size    number,
                     p_prefix              varchar2,
                     p_column_name         varchar2) is
  l_bind_var_name varchar2(80);
  l_indx number := 1;
begin
  /************************************
  dbms_output.put_line('Parameter:'||p_column_name ||
                       ',Count:'||to_char(p_param_array_size));
  ***********************************************/
  l_bind_var_name := ':'||p_prefix||'_'||p_column_name;
  if (p_param_array_size = 1) then
     if (p_param_array(1) <> biv_core_pkg.g_null) then
        dbms_sql.bind_variable(p_cursor,l_bind_var_name,p_param_array(l_indx));
     end if;
  else
     loop
        if (l_indx > nvl(p_param_array_size,0)) then exit; end if;
        dbms_sql.bind_variable(p_cursor,l_bind_var_name||to_char(l_indx),
                                                  p_param_array(l_indx));
        l_indx := l_indx + 1;
     end loop;
  end if;
end;
------------------------------------------------------------
procedure bind_all_variables (p_cursor number) is
  l_stat varchar2(20);
begin
   add_a_bind(p_cursor              ,
              g_cust_id         ,
              g_cust_id_cnt     ,
              'sr'                  ,
              'customer_id'         );
   add_a_bind(p_cursor              ,
              g_cntr_id         ,
              g_cntr_id_cnt     ,
              'sr'                  ,
              'contract_number'         );
   add_a_bind(p_cursor              ,
              g_ogrp   ,
              g_ogrp_cnt ,
              'odnorm1'                  ,
              'parent_group_id');
   add_a_bind(p_cursor              ,
              g_agrp   ,
              g_agrp_cnt ,
              'adnorm1'                  ,
              'parent_group_id');
   add_a_bind(p_cursor              ,
              g_prd_id    ,
              g_prd_id_cnt ,
              'sr'                  ,
              'inventory_item_id');
   if (g_report_type = 'RT') then
       add_a_bind(p_cursor              ,
                  g_esc_lvl    ,
                  g_esc_lvl_cnt ,
                  'task'                  ,
                  'escalation_level');
   else
       add_a_bind(p_cursor              ,
                  g_esc_lvl    ,
                  g_esc_lvl_cnt ,
                  'srs'                  ,
                  'escalation_level');
   end if;
   add_a_bind(p_cursor              ,
              g_sev   ,
              g_sev_cnt ,
              'sr'                  ,
              'incident_severity_id');
   add_a_bind(p_cursor              ,
              g_prd_ver   ,
              g_prd_ver_cnt ,
              'sr'                  ,
              'product_revision');
   add_a_bind(p_cursor              ,
              g_comp_id   ,
              g_comp_id_cnt ,
              'sr'                  ,
              'cp_component_id');
   add_a_bind(p_cursor              ,
              g_subcomp_id   ,
              g_subcomp_id_cnt ,
              'sr'                  ,
              'cp_subcomponent_id');
   add_a_bind(p_cursor              ,
              g_platform_id   ,
              g_platform_id_cnt ,
              'sr'                  ,
              'platform_id');
   add_a_bind(p_cursor              ,
              g_sts_id   ,
              g_sts_id_cnt ,
              'sr'                  ,
              'incident_status_id');
   add_a_bind(p_cursor              ,
              g_mgr_id   ,
              g_mgr_id_cnt ,
              'rsc'                  ,
              'source_mgr_id');
   add_a_bind(p_cursor              ,
              g_site_id   ,
              g_site_id_cnt ,
              'sr'                  ,
              'site_id');
   if (nvl(g_agent_id,g_null) <> g_null) then
      dbms_sql.bind_variable(p_cursor,':incident_owner_id',g_agent_id);
   end if;
   if (g_chnl is not null) then
      dbms_sql.bind_variable(p_cursor,':sr_creation_channel',g_chnl);
   end if;
   if (nvl(g_resl_code,biv_core_pkg.g_null) <> biv_core_pkg.g_null) then
      dbms_sql.bind_variable(p_cursor,':resolution_code',g_resl_code);
   end if;
   if (g_arvl_tm is not null) then
      dbms_sql.bind_variable(p_cursor,':arrival_time',g_arvl_tm);
   end if;

   -- date parameter binding
   if (g_st_date is not null and
       (nvl(g_reopen,'N') = 'Y' or nvl(g_reclose,'N') = 'Y' or
        nvl(g_oblog,'N') = 'Y')) then
      dbms_sql.bind_variable(p_cursor,':start_date',g_st_date);
   end if;
   if (g_end_date is not null and
       (nvl(g_reopen,'N') = 'Y' or nvl(g_reclose,'N') = 'Y' or
        nvl(g_eblog,'N') = 'Y')) then
      dbms_sql.bind_variable(p_cursor,':end_date',g_end_date);
   end if;

   /**************
   if (nvl(g_reopen,'N') = 'Y') then
      dbms_sql.bind_variable(p_cursor,':reopen_st' ,g_st_date );
      dbms_sql.bind_variable(p_cursor,':reopen_end',g_end_date);
   end if;
   **********************/
   if (g_cr_st is not null) then
      dbms_sql.bind_variable(p_cursor,':created_start_date',g_cr_st);
   end if;
   if (g_cr_end is not null) then
      dbms_sql.bind_variable(p_cursor,':created_end_date',g_cr_end);
   end if;

   if (g_cl_st is not null) then
      dbms_sql.bind_variable(p_cursor,':closed_start_date',g_cl_st);
   end if;
   if (g_cl_end is not null) then
      dbms_sql.bind_variable(p_cursor,':closed_end_date',g_cl_end);
   end if;
   if (g_esc_st is not null) then
      dbms_sql.bind_variable(p_cursor,':esc_st',g_esc_st);
   end if;
   if (g_esc_end is not null) then
      dbms_sql.bind_variable(p_cursor,':esc_end',g_esc_end);
   end if;

   if (nvl(g_other_blog,'N')='Y') then
      l_stat := fnd_profile.value('BIV:INC_STATUS_1');
      dbms_sql.bind_variable(p_cursor,':stat1',l_stat);

      l_stat := fnd_profile.value('BIV:INC_STATUS_2');
      dbms_sql.bind_variable(p_cursor,':stat2',l_stat);

      l_stat := fnd_profile.value('BIV:INC_STATUS_3');
      dbms_sql.bind_variable(p_cursor,':stat3',l_stat);
   end if;
   if (g_view_by in ('AGRP', 'OGRP') or g_agrp_lvl is not null or
       g_ogrp_lvl is not null) then
      dbms_sql.bind_variable(p_cursor,':g_lvl',g_lvl);
   end if;
end;
------------------------------------------------------------
procedure add_a_condition(p_param_array         biv_core_pkg.g_parameter_array,
                          p_param_array_size    number,
                          p_prefix              varchar2,
                          p_column_name         varchar2,
                          p_table               varchar2,
                          p_where_clause in out nocopy varchar2,
                          p_outer_cond          varchar2 /*default 'N'*/) is
   l_indx number;
   l_outer_suffx varchar2(20);
begin
   if (p_outer_cond = 'Y') then
      l_outer_suffx := '(+)';
   else
      l_outer_suffx := ' ';
   end if;
   if (p_param_array_size = 1) then
      if (p_param_array(1) = biv_core_pkg.g_null) then
         p_where_clause := p_where_clause || '
           and ' || p_prefix || '.' || p_column_name || l_outer_suffx ||
               ' is null ';
      else
         p_where_clause := p_where_clause || '
           and ' || p_prefix || '.' ||p_column_name || l_outer_suffx
               || ' = :' || p_prefix || '_' ||p_column_name;
      end if;
   elsif (p_param_array_size > 1) then
      p_where_clause := p_where_clause || '
           and ' || p_prefix || '.' || p_column_name || ' in ( ';
      l_indx := 1;
      loop
         p_where_clause := p_where_clause || ':'||p_prefix || '_' ||
                                     p_column_name|| to_char(l_indx);
         if (l_indx = p_param_array_size) then exit; end if;
         l_indx := l_indx + 1;
         p_where_clause := p_where_clause || ',
                            ';
      end loop;
      p_where_clause := p_where_clause || ')';
   end if;
end;
------------------------------------------------------------
procedure get_where_clause(p_from_clause  in out nocopy varchar2,
                             p_where_clause in out nocopy varchar2) as
begin
   if (g_base_column is null) then
      p_where_clause := ' where 1 = 1';
   else
      p_where_clause := ' where 1 = 1';
      -- 4/29/02
      -- this is put in comment so that null values too can ne displayed.
      --p_where_clause := ' where ' || g_base_column || ' is not null';
   end if;
   add_a_condition(g_cust_id,
                   g_cust_id_cnt,
                   'sr','customer_id',
                   null,
                   p_where_clause   );
   add_a_condition(g_cntr_id,
                   g_cntr_id_cnt,
                   'sr','contract_number',
                   null,
                   p_where_clause   );
   add_a_condition(g_ogrp,
                   g_ogrp_cnt,
                   'odnorm1','parent_group_id',
                   null,
                   p_where_clause   );
   add_a_condition(g_agrp,
                   g_agrp_cnt,
                   'adnorm1','parent_group_id',
                   null,
                   p_where_clause   );
   add_a_condition(g_prd_id,
                   g_prd_id_cnt,
                   'sr','inventory_item_id',
                   null,
                   p_where_clause   );
   add_a_condition(g_sev,
                   g_sev_cnt,
                   'sr','incident_severity_id',
                   null,
                   p_where_clause   );
   if (g_report_type = 'RT') then
      add_a_condition(g_esc_lvl,
                      g_esc_lvl_cnt,
                      'task','escalation_level',
                      null,
                      p_where_clause   );
   else
      add_a_condition(g_esc_lvl,
                      g_esc_lvl_cnt,
                      'srs','escalation_level',
                      null,
                      p_where_clause   );
   end if;
   add_a_condition(g_prd_ver,
                   g_prd_ver_cnt,
                   'sr','product_revision',
                   null,
                   p_where_clause   );
   add_a_condition(g_comp_id,
                   g_comp_id_cnt,
                   'sr','cp_component_id',
                   null,
                   p_where_clause   );
   add_a_condition(g_subcomp_id,
                   g_subcomp_id_cnt,
                   'sr','cp_subcomponent_id',
                   null,
                   p_where_clause   );
   add_a_condition(g_platform_id,
                   g_platform_id_cnt,
                   'srs','platform_id',
                   null,
                   p_where_clause   );
   add_a_condition(g_sts_id,
                   g_sts_id_cnt,
                   'sr','incident_status_id',
                   null,
                   p_where_clause   );
   add_a_condition(g_mgr_id,
                   g_mgr_id_cnt,
                   'rsc','source_mgr_id',
                   null,
                   p_where_clause   );
   add_a_condition(g_site_id,
                   g_site_id_cnt,
                   'sr','site_id',
                   null,
                   p_where_clause   );
   if (nvl(g_blog,'N') =  'Y' ) then
      p_where_clause := p_where_clause || '
                         and nvl(stat.close_flag,''N'') <> ''Y''';
      if (instr(upper(p_from_clause),'CS_INCIDENT_STATUSES_B') = 0) then
         p_from_clause := p_from_clause || ',
                           cs_incident_statuses_b stat';
         p_where_clause := p_where_clause || '
                      and sr.incident_status_id = stat.incident_status_id';
      end if;
   end if;
   if (nvl(g_other_blog,'N') =  'Y' ) then
      p_where_clause := p_where_clause || '
                          and nvl(stat.close_flag,''N'') <> ''Y''
                            and sr.incident_status_id <> :stat1
                            and sr.incident_status_id <> :stat2
                            and sr.incident_status_id <> :stat3';
      if (instr(upper(p_from_clause),'CS_INCIDENT_STATUSES_B') = 0) then
         p_from_clause := p_from_clause || ',
                           cs_incident_statuses_b stat';
         p_where_clause := p_where_clause || '
                  and sr.incident_status_id = stat.incident_status_id';
      end if;
   end if;
   if ( g_ott is not null) then
      if (instr(upper(p_from_clause),'CS_INCIDENT_STATUSES_B') = 0) then
         p_from_clause := p_from_clause || ',
                           cs_incident_statuses_b stat';
         p_where_clause := p_where_clause || '
                  and sr.incident_status_id = stat.incident_status_id';
      end if;
      p_where_clause := p_where_clause || '
              and nvl(stat.close_flag,''N'') <> ''Y''
              and exists ( select 1 from jtf_tasks_b t,
                                         jtf_task_statuses_b s
                            where t.source_object_type_code = ''SR''
                              and t.source_object_id        = sr.incident_id
                              and t.task_status_id          = s.task_status_id
                              and nvl(s.closed_flag,''N'') <> ''Y''
                         ) ';
   end if;
   if (g_unown is not null) then
      p_where_clause := p_where_clause || '
                  and (nvl(sr.resource_type,''X'') <> ''RS_EMPLOYEE''
                       or sr.incident_owner_id is null)';
   end if;
   if (g_agent_id is not null) then
      if (g_agent_id = g_null) then
         p_where_clause := p_where_clause || '
                and sr.incident_owner_id is null';
      else
         p_where_clause := p_where_clause || '
                and sr.incident_owner_id = :incident_owner_id';
      end if;
   end if;
   if (g_today_only='Y') then
      p_where_clause := p_where_clause || '
                            and sr.incident_date >= trunc(sysdate)
                            and sr.incident_date <  trunc(sysdate+1)';
   end if;
   if (g_chnl is not null) then
      /* 4/30/02 no channel is in cs_incident_all_b table itself.
      if (instr(upper(p_from_clause),'CS_INCIDENTS_ALL_TL') = 0) then
         p_from_clause := p_from_clause || ',
                           cs_incidents_all_tl srl';
         p_where_clause := p_where_clause || '
                            and srl.incident_id = sr.incident_id
                            and srl.language = userenv(''LANG'') ';
      end if;
      */
      p_where_clause := p_where_clause || '
                and upper(sr.sr_creation_channel) = :sr_creation_channel';
   end if;
   if (g_resl_code is not null) then
      if (g_resl_code = biv_core_pkg.g_null) then
         p_where_clause := p_where_clause || '
                   and sr.resolution_code is null';
      else
         p_where_clause := p_where_clause || '
                and sr.resolution_code = :resolution_code';
      end if;
   end if;
   if (nvl(g_close_sr,'N') = 'Y') then
      p_where_clause := p_where_clause || '
                            and nvl(stat.close_flag,''N'') = ''Y''';
      if (instr(upper(p_from_clause),'CS_INCIDENT_STATUSES_B') = 0) then
         p_from_clause := p_from_clause || ',
                           cs_incident_statuses_b stat';
         p_where_clause := p_where_clause || '
                     and sr.incident_status_id = stat.incident_status_id';
      end if;
   end if;
   if (nvl(g_new_sr,'N') = 'Y') then
      p_where_clause := p_where_clause || '
                            and sr.incident_date >= trunc(sysdate)
                            and sr.incident_date <  trunc(sysdate+1)';
      if (instr(upper(p_from_clause),'CS_INCIDENT_STATUSES_B') = 0) then
         p_from_clause := p_from_clause || ',
                           cs_incident_statuses_b stat';
         p_where_clause := p_where_clause || '
                     and sr.incident_status_id = stat.incident_status_id';
      end if;
   end if;
   if (nvl(g_reopen ,'N') = 'Y' or
       nvl(g_reclose,'N') = 'Y') then
      if (instr(upper(p_from_clause),'BIV_SR_SUMMARY') = 0) then
         p_from_clause := p_from_clause || ',
                            biv_sr_summary srs';
         p_where_clause := p_where_clause || '
                  and srs.incident_id=sr.incident_id';
      end if;
   end if;
   if (nvl(g_reopen,'N') = 'Y') then
      p_where_clause := p_where_clause || '
                         and srs.reopen_date is not null
                         and srs.reopen_date between :start_date
                                                 and :end_date ';
   end if;
   if (nvl(g_reclose,'N') = 'Y') then
      p_where_clause := p_where_clause || '
                         and srs.reclose_date is not null
                         and srs.reclose_date between :start_date
                                                  and :end_date ';
   end if;
   if (nvl(g_oblog,'N') = 'Y') then
      p_where_clause := p_where_clause || '
              and sr.incident_date < :start_date
              and nvl(stat.close_flag,''N'') <> ''Y''';
           /* above line replaces these lines. it is better to check
              close flag as cllose_date is not very reliable
              due to this, added from clause too.
              and (sr.close_date is null or
                   sr.close_date >= :start_date) ';
            5/9/2 */
      if (instr(upper(p_from_clause),'CS_INCIDENT_STATUSES_B') = 0) then
         p_from_clause := p_from_clause || ',
                           cs_incident_statuses_b stat';
         p_where_clause := p_where_clause || '
                      and sr.incident_status_id = stat.incident_status_id';
      end if;
   end if;
   if (nvl(g_eblog,'N') = 'Y') then
      p_where_clause := p_where_clause || '
              and sr.incident_date < :end_date
              and nvl(stat.close_flag,''N'') <> ''Y''';
      if (instr(upper(p_from_clause),'CS_INCIDENT_STATUSES_B') = 0) then
         p_from_clause := p_from_clause || ',
                           cs_incident_statuses_b stat';
         p_where_clause := p_where_clause || '
                      and sr.incident_status_id = stat.incident_status_id';
      end if;
   end if;
   if ( nvl(g_rsc,'X') = 'WEB') then
     p_from_clause := p_from_clause || ',
                  jtf_rs_res_availability avl ';
     p_where_clause := p_where_clause || '
                  and avl.resource_id = sr.incident_owner_id';
   end if;
/*
   if (g_time_frame is not null) then
      p_where_clause := p_where_clause || '
            and sr.incident_date between ' || ':start_date and :end_date ';
   end if;
   if (g_cr_tm_prd is not null) then
      p_where_clause := p_where_clause || '
          and sr.incident_date between ' ||
                       ':created_start_date and :created_end_date ';
   end if;
   if (g_cl_tm_prd is not null) then
      p_where_clause := p_where_clause || '
           and sr.close_date between ' ||
                       ':closed_start_date and :closed_end_date ';
   end if;
*/
   if (g_cr_st is not null) then
      p_where_clause := p_where_clause || '
          and sr.incident_date >= :created_start_date ';
   end if;
   if (g_cr_end is not null) then
      p_where_clause := p_where_clause || '
          and sr.incident_date < (:created_end_date+1) ';
   end if;
   if (g_cl_st is not null) then
      p_where_clause := p_where_clause || '
          and sr.close_date >= :closed_start_date ';
   end if;
   if (g_cl_end is not null) then
      p_where_clause := p_where_clause || '
          and sr.close_date < (:closed_end_date+1) ';
   end if;
   if (g_esc_st is not null ) then
      if (instr(upper(p_from_clause),'BIV_SR_SUMMARY') = 0) then
         p_from_clause := p_from_clause || ',
                            biv_sr_summary srs';
         p_where_clause := p_where_clause || '
                  and srs.incident_id=sr.incident_id';
      end if;
      p_where_clause := p_where_clause || '
          and srs.escalation_date >= :esc_st ';
   end if;
   if (g_esc_end is not null ) then
      if (instr(upper(p_from_clause),'BIV_SR_SUMMARY') = 0) then
         p_from_clause := p_from_clause || ',
                            biv_sr_summary srs';
         p_where_clause := p_where_clause || '
                  and srs.incident_id=sr.incident_id';
      end if;
      p_where_clause := p_where_clause || '
          and srs.escalation_date < (:esc_end+1) ';
   end if;


   if (g_esc_lvl_cnt > 0 or g_esc_sr is not null) then
      if (g_report_type = 'RT') then
         if (instr(upper(p_from_clause),'JTF_TASKS_B') = 0) then
            p_from_clause := p_from_clause || ',
                               jtf_tasks_b task,
                               jtf_task_references_b ref';
            p_where_clause := p_where_clause || '
                                and ref.object_type_code = ''SR''
                                and ref.object_id = sr.incident_id
                                and ref.reference_code = ''ESC''
                                and ref.task_id = task.task_id
                                and task.task_type_id = 22 ';
         end if;
      else
         if (instr(upper(p_from_clause),'BIV_SR_SUMMARY') = 0) then
            p_from_clause := p_from_clause || ',
                            biv_sr_summary srs';
            p_where_clause := p_where_clause || '
                  and srs.incident_id=sr.incident_id';
         end if;
      end if;
   end if;
   if (g_esc_sr is not null) then
      if (g_report_type = 'RT') then
         p_where_clause := p_where_clause || '
                          and task.escalation_level is not null ';
      else
         p_where_clause := p_where_clause || '
                          and srs.escalation_level is not null ';
      end if;
   end if;
   --
   if (g_arvl_tm is not null) then
      if (instr(upper(p_from_clause),'BIV_SR_SUMMRY') = 0) then
         p_from_clause := p_from_clause || ',
            biv_sr_summary srs';
         p_where_clause := p_where_clause || '
            and srs.incident_id=sr.incident_id';
      end if;
      p_where_clause := p_where_clause || '
        and srs.arrival_time = :arrival_time';
   end if;

   if (g_mgr_id_cnt <> 0) then
     if (instr(upper(p_from_clause), 'JTF_RS_RESOURCE_EXTNS RSC') = 0) then
        p_from_clause := p_from_clause || ',
                           jtf_rs_resource_extns rsc';
        p_where_clause:= p_where_clause || '
                   and (sr.incident_owner_id = rsc.resource_id(+) /* or
                        sr.incident_owner_id = mgr.resource_id */) ';
     end if;
     /*
     if (instr(upper(p_from_clause), 'JTF_RS_RESOURCE_EXTNS MGR') = 0) then
        p_from_clause := p_from_clause || ',
                           jtf_rs_resource_extns mgr';
        p_where_clause:= p_where_clause || '
                   and mgr.source_id = rsc.source_mgr_id ';
     end if;
     */
     --Change for Bug 3093779 begins
   else
     if (g_pr = 'BIV_RT_BACKLOG_BY_STATUS' and g_ua <> 'N' and g_report_id = 'BIV_SERVICE_REQUEST' ) then
        if (instr(upper(p_from_clause),'JTF_RS_RESOURCE_EXTNS RSC') = 0) then
          p_from_clause := p_from_clause ||',
                                jtf_rs_resource_extns rsc';
          p_where_clause := p_where_clause ||' and
                                (sr.incident_owner_id = rsc.resource_id(+)) and
                                rsc.source_mgr_id is null';
       end if;
      -- Change for Big 3093779 ends
    end if;
  end if;

  -- Change for enh 2914005 begins
  if(g_pr = 'BIV_DASH_SR_BIN' and g_total = 'Y' and g_report_id = 'BIV_SERVICE_REQUEST') then
        p_from_clause := p_from_clause || ', cs_incident_statuses_b stat';
        p_where_clause := p_where_clause || '
                 and sr.incident_status_id = stat.incident_status_id
                 and stat.incident_subtype = ''INC''
                 and nvl(stat.close_flag,''N'') != ''Y''
          ';
  end if;
  -- Change for enh 2914005 ends

  -- Change for Bug 3188504 begins
  if (g_pr = 'BIV_HS_SR_ACTIVITY' and g_report_id ='BIV_SERVICE_REQUEST' ) then
      /*if(g_reclose is null and g_reopen is null) then
       p_from_clause := p_from_clause || ',biv_sr_summary srs';
       p_where_clause := p_where_clause || ' and (sr.incident_id = srs.incident_id)';
       end if;*/
       if(g_st_date is not null and g_reopen is null) then
          p_where_clause:= replace(p_where_clause,'and nvl(stat.close_flag,''N'') <> ''Y''',
          'and (nvl(stat.close_flag,''N'')<> ''Y'' or nvl(sr.close_date,sysdate-1000) > :start_date)');
       else
          if(g_end_date is not null and g_reclose is null) then
             p_where_clause:= replace(p_where_clause,'and nvl(stat.close_flag,''N'') <> ''Y''',
             'and (nvl(stat.close_flag,''N'')<> ''Y'' or nvl(sr.close_date,sysdate-1000) > :end_date)');
          end if;
       end if;
       -- Change for Bug 2948411
       if(instr(upper(p_from_clause),'BIV_SR_SUMMARY') =0) then
          p_from_clause := p_from_clause ||',
                                    biv_sr_summary srs';
          p_where_clause := p_where_clause ||' and (sr.incident_id =
                           srs.incident_id)';
       end if;
   end if;
   -- Change for Bug 3188504 ends

   -- Change for Bug 2948411
   if(g_pr = 'BIV_HS_SR_ARRIVAL_TM' and g_report_id='BIV_SERVICE_REQUEST') then
      if(instr(upper(p_from_clause),'BIV_SR_SUMMARY')=0) then
         p_from_clause := p_from_clause || ' ,biv_sr_summary srs';
         p_where_clause := p_where_clause ||  ' and (sr.incident_id =
                                        srs.incident_id)';
      end if;
   end if;
   -- usage is not added here because group is known. It added in case of
   -- view_by = OGRP or AGRP only because there we need groups of particular
   -- level with desired usage

   /*
   if (g_ogrp_cnt > 0 or
       g_view_by = 'OGRP' ) then
      p_from_clause := p_from_clause || ',
                            jtf_rs_groups_denorm odnorm,
                            jtf_rs_group_members gmmbr';
      p_where_clause := p_where_clause || '
             and gmmbr.group_id = odnorm.group_id
             and sr.incident_owner_id = gmmbr.resource_id';
   end if;
   if (g_agrp_cnt > 0 or
       g_view_by = 'AGRP' ) then
      p_from_clause := p_from_clause || ',
                            jtf_rs_groups_denorm adnorm,
                            jtf_rs_groups_denorm adnorm1';
      p_where_clause := p_where_clause || '
                       and sr.owner_group_id = adnorm.group_id
                       and adnorm.parent_group_id = adnorm1.group_id';
   end if;
   */

   -- condition for view by parameter
   if (g_view_by = 'OGRP' or g_ogrp_lvl is not null) then
      p_from_clause := p_from_clause || ',
                            jtf_rs_groups_denorm odnorm,
                            jtf_rs_group_members gmmbr,
                            biv_resource_groups biv_rg';
      p_where_clause:= p_where_clause || '
             and gmmbr.group_id = odnorm.group_id
             and sr.incident_owner_id = gmmbr.resource_id
             and nvl(gmmbr.delete_flag,''N'') <> ''Y''
                        and biv_rg.group_id = odnorm.parent_group_id
                        and biv_rg.usage = ''METRICS''
                        and biv_rg.group_level = nvl(:g_lvl,''1'')';
   elsif (g_view_by = 'AGRP' or g_agrp_lvl is not null) then
      p_from_clause := p_from_clause || ',
                            jtf_rs_groups_denorm adnorm,
                            biv_resource_groups biv_rg';
      p_where_clause:= p_where_clause || '
                       and sr.owner_group_id = adnorm.group_id (+)
                        and biv_rg.group_id = adnorm.parent_group_id' ||
                      ' and biv_rg.usage = ''SUPPORT'' ' ||
                      ' and biv_rg.group_level = nvl(:g_lvl,''1'')';
   elsif (g_view_by = 'MGR') then
     if (instr(upper(p_from_clause), 'JTF_RS_RESOURCE_EXTNS RSC') = 0) then
        p_from_clause := p_from_clause || ',
                           jtf_rs_resource_extns rsc';
        p_where_clause:= p_where_clause || '
                            and (sr.incident_owner_id = rsc.resource_id(+) /*or
                                 sr.incident_owner_id = mgr.resource_id */) ';
     end if;
     /*
     if (instr(upper(p_from_clause), 'JTF_RS_RESOURCE_EXTNS MGR') = 0) then
        p_from_clause := p_from_clause || ',
                           jtf_rs_resource_extns mgr';
        p_where_clause:= p_where_clause || '
                   and mgr.source_id = rsc.source_mgr_id ';
     end if;
     */
   end if;
   if (g_agrp_cnt > 0 ) then
      p_from_clause := p_from_clause || ',
          jtf_rs_groups_denorm adnorm1';
      if (nvl(g_view_by,'X') <> 'AGRP' and g_agrp_lvl is null) then
        p_where_clause := p_where_clause || '
          and sr.owner_group_id = adnorm1.group_id';
      else
        p_where_clause := p_where_clause || '
          and adnorm.parent_group_id = adnorm1.group_id';
      end if;
   end if;
   -------------------
/*
   if (g_ogrp_cnt > 0 or
       g_view_by = 'OGRP' ) then
      p_from_clause := p_from_clause || ',
                            jtf_rs_groups_denorm odnorm,
                            jtf_rs_group_members gmmbr';
      p_where_clause := p_where_clause || '
             and gmmbr.group_id = odnorm.group_id
             and sr.incident_owner_id = gmmbr.resource_id';
   end if;
*/
   -------------------
   if (g_ogrp_cnt > 0) then
      p_from_clause := p_from_clause || ',
          jtf_rs_groups_denorm odnorm1';
      if (nvl(g_view_by,'X') <> 'OGRP' and g_ogrp_lvl is null) then
        p_from_clause := p_from_clause || ',
                            jtf_rs_group_members gmmbr';
        p_where_clause := p_where_clause || '
             and gmmbr.group_id = odnorm1.group_id
             and nvl(gmmbr.delete_flag,''N'') <> ''Y''
             and sr.incident_owner_id = gmmbr.resource_id';
      else
        p_where_clause := p_where_clause || '
          and odnorm.parent_group_id = odnorm1.group_id';
      end if;
   end if;

/***
   --
   if (length(p_where_clause) > 15 ) then
      p_where_clause := '
                       where ' ||
                           substr(p_where_clause,instr(p_where_clause,'and')+4);
   end if;
*****/
end get_where_clause;
function param_for_base_col return varchar2 is
begin
   if (g_view_by = 'MGR') then
      return('P_MGR_ID');
   elsif (g_view_by = 'OGRP') then
      return('P_OGRP');
   elsif (g_view_by = 'AGRP') then
      return('P_AGRP');
   elsif (g_view_by = 'PRD') then
      return('P_PRD_ID');
   elsif (g_view_by = 'MGR') then
      return('P_MGR_ID');
   elsif (g_view_by = 'SSITE') then
      return('P_SITE_ID');
   elsif (g_view_by = 'CUST') then
      return('P_CUST_ID');
   else return('P_AGENT_ID');
   end if;
end;
procedure update_base_col_desc(p_tbl_name varchar2 /*default null*/) is
  l_tbl varchar2(30);
  l_sql varchar2(500);
  l_err varchar2(250);
  l_session_id biv_tmp_rt2.session_id % type;
  l_null_desc fnd_lookups.meaning % type;
begin
   l_session_id := biv_core_pkg.get_session_id;
   l_tbl := nvl(p_tbl_name,'jtfb_temp_report');
   l_sql := null;
   if (g_view_by = 'AGRP' or g_view_by='OGRP') then
      l_sql := 'update ' || l_tbl || ' rep
         set col2 = (select substr(group_name,1,50)
                    from jtf_rs_groups_vl grp
                   where grp.group_id = nvl(rep.col1,rep.id))
        where session_id = :session_id' ;
  elsif (g_view_by = 'PRD') then
      l_sql := 'update ' || l_tbl || ' rep
         set col2 = (select substr(description,1,50) from mtl_system_items_vl
                      where inventory_item_id = nvl(rep.col1,rep.id)
                        and organization_id = ' ||g_prd_org || ')
        where session_id = :session_id';
  elsif (g_view_by = 'MGR') then
      l_sql := 'update ' || l_tbl || ' rep
         set col2 = (select substr(full_name,1,50) from per_people_f
                      where person_id = nvl(rep.col1,rep.id)
                        and sysdate between
                             nvl(effective_start_date,sysdate-1) and
                             nvl(effective_end_date,sysdate+2)
                    )
        where session_id = :session_id';
  elsif (g_view_by = 'SSITE') then
      l_sql := 'update ' || l_tbl || ' rep
         set col2 = (select substr(party_site_name,1,50) from hz_party_sites
                      where party_site_id = nvl(rep.col1,rep.id))
        where session_id = :session_id';
  elsif (g_view_by = 'CUST') then
      l_sql := 'update ' || l_tbl || ' rep
         set col2 = (select substr(party_name,1,50) from hz_parties
                      where party_id = nvl(rep.col1,rep.id))
        where session_id = :session_id';
  elsif (g_report_id = 'BIV_RT_AGENT_REPORT' or g_view_by = 'AGENT' or
         g_view_by = 'ESCONR') then
      l_sql := 'update ' || l_tbl || ' rep
         set col2 = (select substr(source_name,1,50) from jtf_rs_resource_extns
                      where resource_id = rep.col1)
        where session_id = :session_id';
  else
      l_sql := 'update ' || l_tbl || ' rep
         set col2 = col1
        where session_id = :session_id' ;
  end if;
  if (g_debug = 'Y') then
    biv_core_pkg.biv_debug('SQL for updating Description:'||l_sql, g_report_id);
  end if;
  commit;
  if (l_sql is null) then
     if (g_debug = 'Y') then
        biv_core_pkg.biv_debug('Invalid Value for P_VIEW parameter:'||g_view_by,
                               g_report_id);
     end if;
  else
     execute immediate l_sql using l_session_id;
  end if;
  l_null_desc := get_lookup_meaning('NA');
  l_sql := 'update ' || l_tbl || '
              set col2 = :null_desc
            where col2 is null
              and session_id = :session_id';
  if (g_debug = 'Y') then
    biv_core_pkg.biv_debug('SQL for NULLL Description:'||l_sql, g_report_id);
  end if;
  execute immediate l_sql using l_null_desc, l_session_id;

  exception
    when others then
     if (g_debug = 'Y') then
        l_err := 'Err in update_base_col:' ||substr(sqlerrm,1,200);
        biv_core_pkg.biv_debug(l_err,g_report_id);
        biv_core_pkg.biv_debug(l_sql,g_report_id);
     end if;
end;
procedure update_description(p_id_type  varchar2,
                             p_id_col   varchar2,
                             p_desc_col varchar2,
                             p_tbl_name varchar2 /*default null*/) as
   l_sql_sttmnt varchar2(2000);
   l_id_type    varchar2(100);
   l_tbl        varchar2(50);
   l_err varchar2(250);
   l_null_desc fnd_lookups.meaning % type;
begin
   l_id_type := upper(p_id_type);
   l_tbl := nvl(p_tbl_name,'jtfb_temp_report');
   if (l_id_type = 'P_AGRP' or l_id_type='P_OGRP') then
      l_sql_sttmnt := '
        update ' || l_tbl || '  rep
         set '|| p_desc_col || ' = (select substr(group_name,1,50)
                    from jtf_rs_groups_vl grp
                   where grp.group_id = rep.' || p_id_col || ')
        where session_id = :session_id' ;
  elsif (l_id_type = 'P_PRD_ID') then
      l_sql_sttmnt := '
        update ' || l_tbl || '  rep
         set ' || p_desc_col || ' = (select substr(description,1,50) from mtl_system_items_vl
                      where inventory_item_id = rep.' || p_id_col || '
                        and organization_id = '|| g_prd_org || ')
        where session_id = :session_id';
  elsif (l_id_type = 'P_MGR_ID') then
      l_sql_sttmnt := '
        update ' || l_tbl || '  rep
         set ' || p_desc_col || ' = (select substr(full_name,1,50) from per_people_f
                      where person_id = rep.' || p_id_col || '
                        and sysdate between
                             nvl(effective_start_date,sysdate-1) and
                             nvl(effective_end_date,sysdate+2)
                    )
        where session_id = :session_id';
  elsif (l_id_type = 'P_SSITE_ID') then
      l_sql_sttmnt := '
        update ' || l_tbl || '  rep
         set ' || p_desc_col || ' = (select substr(party_site_name,1,50) from hz_party_sites
                      where party_site_id = rep.' || p_id_col || ')
        where session_id = :session_id';
  elsif (l_id_type = 'P_CUST_ID') then
      l_sql_sttmnt := '
        update ' || l_tbl || '  rep
         set ' || p_desc_col || ' = (select substr(party_name,1,50) from hz_parties
                      where party_id = rep.' || p_id_col || ')
        where session_id = :session_id';
  elsif (l_id_type = 'P_AGENT_ID') then
      l_sql_sttmnt := '
        update ' || l_tbl || '  rep
         set ' || p_desc_col || ' = (select substr(source_name,1,50)
                                       from jtf_rs_resource_extns
                             where resource_id = rep.' || p_id_col || ')
        where session_id = :session_id';
  end if;

  if (g_debug = 'Y') then
     biv_core_pkg.biv_debug('SQL for updating Description:'||l_sql_sttmnt,
                            g_report_id);
  end if;
  execute immediate l_sql_sttmnt using biv_core_pkg.get_session_id;

  if (upper(p_desc_col) = 'COL2') then
     l_null_desc := get_lookup_meaning('NA');
     l_sql_sttmnt := 'update ' || l_tbl || '
                         set col2 = :nul_desc
                      where col2 is null and session_id = :session_id';
     if (g_debug = 'Y') then
        biv_core_pkg.biv_debug('SQL for updating NULL Description:'||
                               l_sql_sttmnt, g_report_id);
     end if;
     execute immediate l_sql_sttmnt using l_null_desc,
                       biv_core_pkg.get_session_id;
  end if;
  exception
    when others then
     if (g_debug = 'Y') then
        l_err := 'Err in update_description:' ||substr(sqlerrm,1,200);
        biv_core_pkg.biv_debug(l_err,g_report_id);
        biv_core_pkg.biv_debug(l_sql_sttmnt,g_report_id);
     end if;
end;
function  are_all_parameters_null return number is
begin
if ( nvl(g_cust_id_cnt     ,0) = 0 and
     nvl(g_cntr_id_cnt     ,0) = 0 and
     nvl(g_ogrp_cnt        ,0) = 0 and
     nvl(g_agrp_cnt        ,0) = 0 and
     nvl(g_prd_id_cnt      ,0) = 0 and
     nvl(g_sev_cnt         ,0) = 0 and
     nvl(g_esc_lvl_cnt     ,0) = 0 and
     nvl(g_prd_ver_cnt     ,0) = 0 and
     nvl(g_comp_id_cnt     ,0) = 0 and
     nvl(g_subcomp_id_cnt  ,0) = 0 and
     nvl(g_platform_id_cnt ,0) = 0 and
     nvl(g_sts_id_cnt      ,0) = 0 and

     g_time_frame     is null and
     g_base_column    is null and
     g_view_by        is null and
     g_lvl            is null and
     g_st_date        is null and
     g_end_date       is null and
     g_srt_by         is null and
     g_cr_tm_prd      is null and
     g_cl_tm_prd      is null and
     g_cl_st          is null and
     g_cl_end         is null and
     g_esc_st         is null and
     g_esc_end        is null and
     g_cr_st          is null and
     g_cr_end         is null and
     g_disp           is null and

     g_blog           is null and
     g_other_blog     is null and
     g_agent_id       is null and
     g_close_sr       is null and
     g_today_only     is null and
     g_chnl           is null
   ) then
     return 1;
  else
     return 0;
end if;
end;
procedure concatenate_date_param (p_param_value date,
                                  p_param_name  varchar2,
                                  p_param_str   in out nocopy varchar2) is
  l_dt_fmt varchar2(30) := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
begin
  if (p_param_value is not null) then
     p_param_str := p_param_str || p_param_name  || g_value_sep ||
                    to_char( p_param_value,l_dt_fmt) ||g_param_sep;

  end if;
end;
procedure concatenate_single_val_param(p_param_value varchar2,
                                       p_param_name  varchar2,
                                       p_param_str   in out nocopy varchar2) is
begin
  if (p_param_value is not null) then
     p_param_str := p_param_str || p_param_name  || g_value_sep ||
                                   p_param_value ||g_param_sep;

  end if;
end;
procedure concatenate_multi_val_param(p_param_values g_parameter_array,
                                  p_value_count  number,
                                  p_param_str    in out nocopy varchar2,
                                  p_param_name   varchar2) is
  i number;
begin
  if (nvl(p_value_count,0) <> 0) then
     p_param_str := p_param_str || p_param_name || g_value_sep;
     for i in 1..p_value_count loop
        p_param_str := p_param_str || p_param_values(i);
        if (i<> p_value_count) then
          p_param_str := p_param_str || g_multi_value_sep;
        end if;
     end loop;
     p_param_str := p_param_str || g_param_sep;
  end if;
end;
function reconstruct_param_str return varchar2 is
  p_param_str varchar2(2000);
begin
  p_param_str := null;
  concatenate_multi_val_param(g_cust_id            ,
                           g_cust_id_cnt        ,
                           p_param_str              ,
                           'P_CUST_ID');
  concatenate_multi_val_param(g_cntr_id            ,
                           g_cntr_id_cnt        ,
                           p_param_str              ,
                           'P_CNTR_ID');
  concatenate_multi_val_param(g_ogrp     ,
                           g_ogrp_cnt ,
                           p_param_str              ,
                           'P_OGRP');
  concatenate_multi_val_param(g_agrp       ,
                           g_agrp_cnt   ,
                           p_param_str              ,
                           'P_AGRP');
  concatenate_multi_val_param(g_prd_id                ,
                           g_prd_id_cnt            ,
                           p_param_str              ,
                           'P_PRD_ID');
  concatenate_multi_val_param(g_sev      ,
                           g_sev_cnt  ,
                           p_param_str              ,
                           'P_SEV');
  concatenate_multi_val_param(g_esc_lvl ,
                           g_esc_lvl_cnt          ,
                           p_param_str              ,
                           'P_ESC_LVL');
  concatenate_multi_val_param(g_prd_ver ,
                           g_prd_ver_cnt          ,
                           p_param_str              ,
                           'P_PRD_VER');
  concatenate_multi_val_param(g_comp_id ,
                           g_comp_id_cnt          ,
                           p_param_str              ,
                           'P_COMP_ID');
  concatenate_multi_val_param(g_subcomp_id ,
                           g_subcomp_id_cnt          ,
                           p_param_str              ,
                           'P_SUBCOMP_ID');
  concatenate_multi_val_param(g_platform_id ,
                           g_platform_id_cnt          ,
                           p_param_str              ,
                           'P_PLATFORM_ID');
  concatenate_multi_val_param(g_sts_id ,
                           g_sts_id_cnt          ,
                           p_param_str              ,
                           'P_STS_ID');
  concatenate_multi_val_param(g_mgr_id   ,
                              g_mgr_id_cnt,
                              p_param_str ,
                              'P_MGR_ID'   );
  concatenate_multi_val_param(g_site_id   ,
                              g_site_id_cnt,
                              p_param_str ,
                              'P_SITE_ID'   );
  concatenate_single_val_param(g_agent_id   , 'P_AGENT_ID'   , p_param_str   );
  concatenate_single_val_param(g_blog       , 'P_BLOG'       , p_param_str   );
  concatenate_single_val_param(g_eblog      , 'P_EBLOG'      , p_param_str   );
  concatenate_single_val_param(g_oblog      , 'P_OBLOG'      , p_param_str   );
  concatenate_single_val_param(g_other_blog , 'P_OTHER_BLOG' , p_param_str   );
  concatenate_single_val_param(g_chnl       , 'P_CHNL'       , p_param_str   );
  concatenate_single_val_param(g_close_sr   , 'P_CLOSE_SR'   , p_param_str   );
  concatenate_single_val_param(g_new_sr     , 'P_NEW_SR'     , p_param_str   );
  concatenate_single_val_param(g_reopen     , 'P_REOPEN'     , p_param_str   );
  concatenate_single_val_param(g_reclose    , 'P_RECLOSE'    , p_param_str   );
  concatenate_single_val_param(g_time_frame , 'P_TIME_FRAME' , p_param_str   );
  concatenate_single_val_param(g_lvl        , 'P_LVL'        , p_param_str   );
  concatenate_single_val_param(g_ogrp_lvl   , 'P_OGRP_LVL'   , p_param_str   );
  concatenate_single_val_param(g_agrp_lvl   , 'P_AGRP_LVL'   , p_param_str   );

  concatenate_single_val_param(g_unown      , 'P_UNOWN'      , p_param_str   );
  concatenate_single_val_param(g_esc_sr     , 'P_ESC_SR'     , p_param_str   );

  concatenate_date_param(g_st_date    , 'P_ST_DATE'    , p_param_str   );
  concatenate_date_param(g_end_date   , 'P_END_DATE'   , p_param_str   );
  concatenate_date_param(g_cl_st      , 'P_CL_ST'      , p_param_str   );
  concatenate_date_param(g_cl_end     , 'P_CL_END'     , p_param_str   );
  concatenate_date_param(g_esc_st     , 'P_ESC_ST'     , p_param_str   );
  concatenate_date_param(g_esc_end    , 'P_ESC_END'    , p_param_str   );
  concatenate_date_param(g_cr_st      , 'P_CR_ST'      , p_param_str   );
  concatenate_date_param(g_cr_end     , 'P_CR_END'     , p_param_str   );

  return p_param_str;
end;
procedure reset_view_by_param is
begin
  if (   g_view_by  ='AGRP') then
     g_agrp_cnt := 0;
  elsif (g_view_by  ='OGRP') then
     g_ogrp_cnt := 0;
  elsif (g_view_by  = 'MGR') then
     g_mgr_id_cnt := 0;
  elsif (g_view_by  = 'PRD') then
     g_prd_id_cnt := 0;
  elsif (g_view_by  = 'SSITE') then
     g_site_id_cnt := 0;
  end if;
end;

function get_session_id return number is
begin
  return icx_sec.g_session_id;
end get_session_id;

procedure clean_dcf_table(p_code varchar2) is
l_session_id NUMBER;
l_code varchar2(50);
begin
        l_code := upper(p_code);
        l_session_id := biv_core_pkg.get_session_id;
        if l_code = 'BIV_TMP_BIN' then
                execute immediate 'delete from BIV_TMP_BIN where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
        elsif (l_code = 'BIV_TMP_RT1') then
                execute immediate 'delete from BIV_TMP_RT1 where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
        elsif (l_code = 'BIV_TMP_RT2') then
                execute immediate 'delete from BIV_TMP_RT2 where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
        elsif (l_code = 'BIV_TMP_HS1') then
                execute immediate 'delete from BIV_TMP_HS1 where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
        elsif (l_code = 'BIV_TMP_HS2') then
                execute immediate 'delete from BIV_TMP_HS2 where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
        elsif (l_code = 'BIV_TMP_SR_ARRVL') then
                execute immediate 'delete from BIV_TMP_SR_ARRVL where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
        else
                execute immediate 'delete from BIV_TMP_BIN where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
                execute immediate 'delete from BIV_TMP_RT1 where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
                execute immediate 'delete from BIV_TMP_RT2 where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
                execute immediate 'delete from BIV_TMP_HS2 where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
                execute immediate 'delete from BIV_TMP_SR_ARRVL where
                        session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
        end if;
        g_debug := fnd_profile.value('BIV:DEBUG');
        if (g_debug = 'Y') then
           execute immediate 'delete from biv_debug where session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
        end if;
        biv_core_pkg.g_srl_no := 0;
        if (g_debug = 'Y') then
           biv_core_pkg.biv_debug('Code:'||l_code,biv_core_pkg.g_report_id);
        end if;
        --   biv_core_pkg.biv_debug('Code:'||l_code,biv_core_pkg.g_report_id);
        --   biv_core_pkg.biv_debug('Debug:'||g_debug,biv_core_pkg.g_report_id);
        commit;
    exception when others then
        rollback;
        if (g_debug = 'Y') then
           biv_core_pkg.biv_debug('Error:'||substr(sqlerrm,1,200),
                                            biv_core_pkg.g_report_id);
        end if;

end clean_dcf_table;

procedure clean_region_table(p_region varchar2) is
l_session_id NUMBER;
begin
        l_session_id := biv_core_pkg.get_session_id;
        if p_region IN ('BIV_BIN_SR',
                        'BIV_BIN_SR_ESCALATION',
                   'BIV_BIN_RESOURCE') then
                execute immediate 'delete from BIV_TMP_BIN where
                        session_id = :l_session_id ' using l_session_id;
        elsif (p_region IN ('BIV_RT_CUS_BLOG',
                                                          'BIV_RT_SR_SUM_MONITOR',
                                                          'BIV_RT_SR_SEV',
                                                          'BIV_RT_ESC_SR',
                       'BIV_RT_CUS_BLOG_DD')) then
                execute immediate 'delete from BIV_TMP_RT1 where
                        session_id = :l_session_id ' using l_session_id;
        elsif (p_region IN ('BIV_RT_AGENT_REPORT',
                                                     'BIV_RT_MANAGER_REPORT',
                                                     'BIV_RT_BACKLOG_BY_STATUS',
                                                     'BIV_RT_TASK_ACTIVITY',
                                                     'BIV_TASK_SUMMARY',
                                                    'BIV_RELATED_TASK',
                                                     'BIV_SERVICE_REQUEST')) then
                execute immediate 'delete from BIV_TMP_RT2 where
                        session_id = :l_session_id ' using l_session_id;
        elsif (p_region IN ('BIV_HS_PROB_AVOID',
                                      'BIV_HS_PROB_AVOID_RES')) then
                execute immediate 'delete from BIV_TMP_HS1 where
                        session_id = :l_session_id ' using l_session_id;
        elsif (p_region IN ('BIV_HS_SR_ESCALATION',
                                       'BIV_HS_SR_ACTIVITY',
                                       'BIV_HS_EACALATION_VIEW',
                       'BIV_SERVICE_REQUEST',
                                      'BIV_RT_SR_AGE_REPORT')) then
                execute immediate 'delete from BIV_TMP_HS2 where
                        session_id = :l_session_id ' using l_session_id;
        elsif (p_region IN ('BIV_TMP_SR_ARRVL',
                            'BIV_HS_SR_ARRIVAL_TM',
                       'BIV_HS_SR_ARRIVAL_PRD')) then
                execute immediate 'delete from BIV_TMP_SR_ARRVL where
                        session_id = :l_session_id ' using l_session_id;
        else
            delete from biv_tmp_rt1 where session_id = l_session_id;
            delete from biv_tmp_rt2 where session_id = l_session_id;
            delete from biv_tmp_hs1 where session_id = l_session_id;
            delete from biv_tmp_hs2 where session_id = l_session_id;
            delete from biv_tmp_bin where session_id = l_session_id;
        end if;
        if (g_debug = 'Y') then
           execute immediate 'delete from biv_debug where session_id = :l_session_id  or creation_date < sysdate -1 ' using l_session_id;
        end if;
        commit;
end clean_region_table;
-----------------------
function base_column_description(p_param_str varchar2) return varchar2 is
     l_view_by varchar2(80);
     l_meaning varchar2(80);
begin
    if (g_debug = 'Y') then
      biv_core_pkg.biv_debug('AA' ||p_param_str,biv_core_pkg.g_report_id);
      commit;
    end if;
    l_view_by := biv_core_pkg.get_parameter_value(p_param_str,'P_VIEW_BY');
    if (g_debug = 'Y') then
       biv_core_pkg.biv_debug('Param:'||p_param_str,'g_report_id');
       commit;
    end if;
    select meaning into l_meaning
      from fnd_lookups
     where lookup_type = 'BIV_VIEW_BY'
       and lookup_code = nvl(l_view_by,'MGR');
    --dbms_output.put_line(l_meaning);
    return(nvl(l_meaning,'Base Column'));
    exception
      when others then
         --return(nvl(l_view_by,p_param_str||'AA'));
         return(nvl(l_view_by,'Base Column'));
end;

end;

/
