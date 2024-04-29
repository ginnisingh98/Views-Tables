--------------------------------------------------------
--  DDL for Package Body BEN_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CACHE" as
/* $Header: bencache.pkb 115.11 2002/12/24 15:43:59 bmanyam ship $ */
-- ---------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
History
        Date             Who        Version    What?
        -- --             ---        -------    -----
        19 Nov 98        mhoyes     115.0      created
        10 Nov 98        mhoyes     115.1      Split into separate packages
        09 Mar 99        G Perry    115.2      IS to AS.
        06 Jul 99        mhoyes     115.3      Added cache write routines.
        08 Jul 99        mhoyes     115.4    - Modified p_effective_date datatype
                                               from varchar2 to date on
                                               Write_BGP_Cache.
                                             - Added debug messages in
                                               Write_MastDet_Cache to be used
                                               for debugging the cache.
        01 Sep 99        mhoyes     115.5    - Modified Write_BGP_Cache to build
                                               an in rather than an exists within
                                               the lookup sub-query.
                                             - Added lookup subquery hint
                                               parameter.
                                             - Fixed hashing problems.
                                             - Added temporary debug messages.
        04 Oct 99        mhoyes     115.6    - Added context cache to avoid all
                                               selected instance query values
                                               being assigned to the instance
                                               cache.
        17 May 99        mhoyes     115.7    - Added p_lkup_query to Write_BGP_Cache.
                                             - PLSQL tuning. Removed g_package.
        22 May 00        mhoyes     115.8    - Added parameter p_lkup_query
                                               to Write_BGP_Cache.
        28 Jun 00        mhoyes     115.8    - Upgraded for multiple value hashing.
        13 Jul 00        mhoyes     115.9    - Upgraded for non mandatory hash values.
        19 Sep 01        mhoyes     115.10   - Added check_list_duplicate.
        24-Dec-02        bmanyam    115.4    NOCOPY Changes
*/
-- ------------------------------------------------------------------------------
  --
  -- Declare globals
  --
procedure Write_MastDet_Cache
  (p_mastercol_name    in     varchar2
  ,p_detailcol_name    in     varchar2
  ,p_masterfkcol_name  in     varchar2 default null
  ,p_masterfk1col_name in     varchar2 default null
  ,p_masterfk2col_name in     varchar2 default null
  ,p_masterfk3col_name in     varchar2 default null
  ,p_masterfk4col_name in     varchar2 default null
  ,p_masterfk5col_name in     varchar2 default null
  ,p_lkup_name         in     varchar2
  ,p_inst_name         in     varchar2
  ,p_lkup_query        in     varchar2
  ,p_inst_query        in     varchar2
  ,p_nonmand_hv        in     boolean  default false
  ,p_coninst_query     in     varchar2 default null
  ,p_conlkup_name      in     varchar2 default null
  ,p_dtconlkup_ccolnm  in     varchar2 default null
  ,p_dtconlkup_value   in     date     default null
  ,p_instcolnm_set     in     ben_cache.InstColNmType
                             default ben_cache.g_instcolnm_set
  ,p_curparm_set       in     ben_cache.CurParmType
                             default ben_cache.g_curparm_set
  )

is
  --
  l_proc varchar2(72) := 'Write_MastDet_Cache';
  --
  l_errcol_num           number;
  l_v2errcol_num         long;
  l_codeerrreg_str       long;
  --
  l_asgcolval_num        pls_integer;
  l_curparm_num          pls_integer;
  --
  l_plsql_str            long;
  l_asgcolval_str        long;
  l_colnum_errstr        long;
  l_lkpcurpmint_str      long;
  l_lkpcurpmcall_str     long;
  l_coninstcurpmint_str  long;
  l_coninstcurpmcall_str long;
  l_instcurpmint_str     long;
  l_instcurpmcall_str    long;
  l_lkcacpkcmp_str       long;
  l_lkup_curdecstr       long;
  l_coninst_curdecstr    long;
  l_inst_curdecstr       long;
  l_lkup_loopstr         long;
  l_coninst_loopstr      long;
  l_inst_loopstr         long;
  l_err_colnum           number;
  --
  l_todate_str           varchar2(200);
  l_dclvtodate_str       varchar2(1000);
  l_dclv_vardecstr       varchar2(1000);
  l_dclv_varassstr       varchar2(1000);
  l_lkcacass_str         varchar2(1000);
  l_sqlerrm              long;
  l_conhv                pls_integer;
  l_curparmval_str       varchar2(1000);
  l_coninst_curname      varchar2(1000);
  l_coninst_curref       varchar2(1000);
  l_lkuphv_str           long;
  l_insthv_str           long;
  --
begin
--  hr_utility.set_location (l_proc||' Entering ',10);
  --
  -- Set the context instance cursor name
  --
  if p_coninst_query is not null then
    --
    l_coninst_curname := ' c_coninst';
    l_coninst_curref  := ' objconinst';
    --
  else
    --
    l_coninst_curname := ' c_instance';
    l_coninst_curref  := ' objinst';
    --
  end if;
  --
  -- Build the parameterised cursor
  --
  if p_curparm_set.count > 0 then
    --
    l_lkpcurpmint_str      := '(';
    l_lkpcurpmcall_str     := '(';
    l_coninstcurpmint_str  := '(';
    l_coninstcurpmcall_str := '(';
    l_instcurpmint_str     := '(';
    l_instcurpmcall_str    := '(';
    --
  --  hr_utility.set_location (l_proc||' cursor parm loop ',20);
    --
    for l_curparm_num in p_curparm_set.first .. p_curparm_set.last loop
      --
      -- Build lookup cursor parameter interface string
      --
      if l_curparm_num = 0 then
        --
        l_lkpcurpmint_str := l_lkpcurpmint_str||p_curparm_set(l_curparm_num).name
                             ||'      '||p_curparm_set(l_curparm_num).datatype;
        --
      else
        --
        l_lkpcurpmint_str := l_lkpcurpmint_str||','||p_curparm_set(l_curparm_num).name
                             ||'      '||p_curparm_set(l_curparm_num).datatype;
        --
      end if;
      --
      -- Build lookup cursor call string
      --
      if l_curparm_num > 0 then
        --
        l_lkpcurpmcall_str := l_lkpcurpmcall_str||',';
        --
      end if;
      --
      if p_curparm_set(l_curparm_num).datatype = 'DATE' then
        --
        l_todate_str := ' to_date('||''''
                        ||fnd_date.date_to_canonical(p_curparm_set(l_curparm_num).dateval)
                        ||''''||', '||''''||fnd_date.canonical_DT_mask||''''||') ';
        --
        l_lkpcurpmcall_str := l_lkpcurpmcall_str||l_todate_str;
        --
      elsif p_curparm_set(l_curparm_num).datatype = 'NUMBER' then
        --
        -- Check for a null cursor parameter value
        --
        if p_curparm_set(l_curparm_num).numval is not null then
          --
          l_curparmval_str := p_curparm_set(l_curparm_num).numval;
          --
        else
          --
          l_curparmval_str := ' null ';
          --
        end if;
        --
        l_lkpcurpmcall_str := l_lkpcurpmcall_str||' '
                              ||l_curparmval_str;
        --
      elsif p_curparm_set(l_curparm_num).datatype = 'VARCHAR2' then
        --
        l_lkpcurpmcall_str := l_lkpcurpmcall_str||' '
                              ||''''||p_curparm_set(l_curparm_num).v2val||'''';
        --
      end if;
      --
      -- Build context instance cursor parameter interface string
      --
      if l_curparm_num = 0 then
        --
        l_coninstcurpmint_str := l_coninstcurpmint_str
                             ||p_curparm_set(l_curparm_num).name
                             ||'      '||p_curparm_set(l_curparm_num).datatype;
        --
      else
        --
        l_coninstcurpmint_str := l_coninstcurpmint_str
                             ||','||p_curparm_set(l_curparm_num).name
                             ||'      '||p_curparm_set(l_curparm_num).datatype;
        --
      end if;
      --
      -- Build instance cursor call string
      --
      if l_curparm_num > 0 then
        --
        l_coninstcurpmcall_str := l_coninstcurpmcall_str||',';
        --
      end if;
      --
      if p_curparm_set(l_curparm_num).datatype = 'DATE' then
        --
        l_todate_str := ' to_date('||''''
                        ||fnd_date.date_to_canonical(p_curparm_set(l_curparm_num).dateval)
                        ||''''||', '||''''||fnd_date.canonical_DT_mask||''''||') ';
        --
        l_coninstcurpmcall_str := l_coninstcurpmcall_str||l_todate_str;
        --
      elsif p_curparm_set(l_curparm_num).datatype = 'NUMBER' then
        --
        -- Check for a null cursor parameter value
        --
        if p_curparm_set(l_curparm_num).numval is not null then
          --
          l_curparmval_str := p_curparm_set(l_curparm_num).numval;
          --
        else
          --
          l_curparmval_str := ' null ';
          --
        end if;
        --
        l_coninstcurpmcall_str := l_coninstcurpmcall_str
                               ||' '||l_curparmval_str;
        --
      elsif p_curparm_set(l_curparm_num).datatype = 'VARCHAR2' then
        --
        l_coninstcurpmcall_str := l_coninstcurpmcall_str
                               ||' '||''''||p_curparm_set(l_curparm_num).v2val||'''';
        --
      end if;
      --
      -- Build instance cursor parameter interface string
      --
      if l_curparm_num = 0 then
        --
        l_instcurpmint_str := l_instcurpmint_str
                             ||p_curparm_set(l_curparm_num).name
                             ||'      '||p_curparm_set(l_curparm_num).datatype;
        --
      else
        --
        l_instcurpmint_str := l_instcurpmint_str
                             ||','||p_curparm_set(l_curparm_num).name
                             ||'      '||p_curparm_set(l_curparm_num).datatype;
        --
      end if;
      --
      -- Build instance cursor call string
      --
      if l_curparm_num > 0 then
        --
        l_instcurpmcall_str := l_instcurpmcall_str||',';
        --
      end if;
      --
      if p_curparm_set(l_curparm_num).datatype = 'DATE' then
        --
        l_todate_str := ' to_date('||''''
                        ||fnd_date.date_to_canonical(p_curparm_set(l_curparm_num).dateval)
                        ||''''||', '||''''||fnd_date.canonical_DT_mask||''''||') ';
        --
        l_instcurpmcall_str := l_instcurpmcall_str||l_todate_str;
        --
      elsif p_curparm_set(l_curparm_num).datatype = 'NUMBER' then
        --
        -- Check for a null cursor parameter value
        --
        if p_curparm_set(l_curparm_num).numval is not null then
          --
          l_curparmval_str := p_curparm_set(l_curparm_num).numval;
          --
        else
          --
          l_curparmval_str := ' null ';
          --
        end if;
        --
        l_instcurpmcall_str := l_instcurpmcall_str
                               ||' '||l_curparmval_str;
        --
      elsif p_curparm_set(l_curparm_num).datatype = 'VARCHAR2' then
        --
        l_instcurpmcall_str := l_instcurpmcall_str
                               ||' '||''''||p_curparm_set(l_curparm_num).v2val||'''';
        --
      end if;
      --
    end loop;
  --  hr_utility.set_location (l_proc||' Dn cursor parm loop ',20);
    --
    l_lkpcurpmint_str      := l_lkpcurpmint_str||') ';
    l_lkpcurpmcall_str     := l_lkpcurpmcall_str||') ';
    l_coninstcurpmint_str  := l_coninstcurpmint_str||')';
    l_coninstcurpmcall_str := l_coninstcurpmcall_str||') ';
    l_instcurpmint_str     := l_instcurpmint_str||')';
    l_instcurpmcall_str    := l_instcurpmcall_str||') ';
    --
  else
    --
    l_lkpcurpmint_str      := ' ';
    l_lkpcurpmcall_str     := ' ';
    l_coninstcurpmint_str  := ' ';
    l_coninstcurpmcall_str := ' ';
    l_instcurpmint_str     := ' ';
    l_instcurpmcall_str    := ' ';
    --
  end if;
--  hr_utility.set_location (l_proc||' Dn parm cursor ',20);
  --
  -- Build the instance column value assignment string
  --
  if p_instcolnm_set.count > 0 then
    --
    -- Assign specified column values in instance cache
    --
    l_asgcolval_str := null;
    --
    for l_asgcolval_num in p_instcolnm_set.first .. p_instcolnm_set.last loop
      --
      -- Check for alternative assignment column name
      --
      if p_instcolnm_set(l_asgcolval_num).asscol_name is not null then
        --
        l_asgcolval_str := l_asgcolval_str||'  '||p_inst_name||'(l_torrwnum).'
                           ||p_instcolnm_set(l_asgcolval_num).caccol_name
                           ||' := objinst.'
                           ||p_instcolnm_set(l_asgcolval_num).asscol_name||'; ';
        --
      else
        --
        l_asgcolval_str := l_asgcolval_str||'  '||p_inst_name||'(l_torrwnum).'
                           ||p_instcolnm_set(l_asgcolval_num).caccol_name
                           ||' := objinst.'
                           ||p_instcolnm_set(l_asgcolval_num).col_name||'; ';
        --
      end if;
      --
    end loop;
    --
  else
    --
    -- Assign all column values in instance cache
    --
    --   Check for a context instance cache
    --
    if p_coninst_query is not null then
      --
      -- Assign value to the instance cursor
      --
      l_asgcolval_str := '  fetch c_instance into '||p_inst_name||'(l_torrwnum); ';
      --
    else
      --
      l_asgcolval_str := '  '||p_inst_name||'(l_torrwnum) := objinst; ';
      --
    end if;
    --
  end if;
--  hr_utility.set_location (l_proc||' Dn instance assignment string ',30);
  --
  -- Build the date context lookup value str
  --
  if p_conlkup_name is not null then
    --
    -- Check context lookup details are set
    --
    if p_dtconlkup_value is null then
      --
      fnd_message.set_name('BEN','BEN_?????_CONDATELKVALNULL');
      fnd_message.raise_error;
      --
    end if;
    --
    if p_dtconlkup_ccolnm is null then
      --
      fnd_message.set_name('BEN','BEN_?????_CONDATELKCCNULL');
      fnd_message.raise_error;
      --
    end if;
    --
    -- Hash the date
    --
    l_conhv := p_dtconlkup_value-hr_api.g_sot;
    --
    -- Build the date context value conversion string
    --
    l_dclvtodate_str := ' to_date('||''''
                    ||fnd_date.date_to_canonical(p_dtconlkup_value)
                    ||''''||', '||''''||fnd_date.canonical_DT_mask||''''||') ';
    --
    -- Build the date context value declaration string
    --
    l_dclv_vardecstr := '  l_dtconlkup_value date; ';
    --
    -- Build the date context lookup value assignment string
    --
    l_dclv_varassstr := ' '||p_conlkup_name||'('||l_conhv||').'||p_dtconlkup_ccolnm
                        ||' := '||l_dclvtodate_str||'; ';
    --
    -- Build the lookup cache assignment string
    --
    l_lkcacass_str   := '    '||p_lkup_name||'(l_hv).'||p_dtconlkup_ccolnm
                        ||' := '||l_dclvtodate_str||';';
    --
    -- Build the lookup cache primary key comparison string
    --
    l_lkcacpkcmp_str := ' if '||p_lkup_name||'(l_hv).id <> '||l_coninst_curref||'.'||p_detailcol_name
                        ||' or ('||p_lkup_name||'(l_hv).id = '||l_coninst_curref||'.'||p_detailcol_name
                        ||'   and '||p_lkup_name||'(l_hv).datevalue_1 <> '||l_dclvtodate_str
                        ||'    ) '
                        ||' then ';
    --
  else
    --
    l_dclvtodate_str := ' ';
    l_dclv_vardecstr := ' ';
    l_dclv_varassstr := ' ';
    l_lkcacass_str   := ' ';
    l_lkcacpkcmp_str := ' if '||p_lkup_name||'(l_hv).id <> '||l_coninst_curref
                        ||'.'||p_detailcol_name;
    --
    -- Check if the fk col names are set
    --
    if p_masterfkcol_name is not null then
      --
      l_lkcacpkcmp_str := l_lkcacpkcmp_str||' or nvl('||p_lkup_name||'(l_hv).fk_id,-1) <> nvl('||l_coninst_curref
                          ||'.'||p_masterfkcol_name||',-1) ';
      --
    end if;
    --
    if p_masterfk1col_name is not null then
      --
      l_lkcacpkcmp_str := l_lkcacpkcmp_str||' or nvl('||p_lkup_name||'(l_hv).fk1_id,-1) <> nvl('||l_coninst_curref
                          ||'.'||p_masterfk1col_name||',-1) ';
      --
    end if;
    --
    if p_masterfk2col_name is not null then
      --
      l_lkcacpkcmp_str := l_lkcacpkcmp_str||' or nvl('||p_lkup_name||'(l_hv).fk2_id,-1) <> nvl('||l_coninst_curref
                          ||'.'||p_masterfk2col_name||',-1) ';
      --
    end if;
    --
    if p_masterfk3col_name is not null then
      --
      l_lkcacpkcmp_str := l_lkcacpkcmp_str||' or nvl('||p_lkup_name||'(l_hv).fk3_id,-1) <> nvl('||l_coninst_curref
                          ||'.'||p_masterfk3col_name||',-1) ';
      --
    end if;
    --
    if p_masterfk4col_name is not null then
      --
      l_lkcacpkcmp_str := l_lkcacpkcmp_str||' or nvl('||p_lkup_name||'(l_hv).fk4_id,-1) <> nvl('||l_coninst_curref
                          ||'.'||p_masterfk4col_name||',-1) ';
      --
    end if;
    --
    if p_masterfk5col_name is not null then
      --
      l_lkcacpkcmp_str := l_lkcacpkcmp_str||' or nvl('||p_lkup_name||'(l_hv).fk5_id,-1) <> nvl('||l_coninst_curref
                          ||'.'||p_masterfk5col_name||',-1) ';
      --
    end if;
    --
    l_lkcacpkcmp_str := l_lkcacpkcmp_str||' then ';
    --
  end if;
  --
  -- Check for foreign key lookup values
  --
  if p_masterfkcol_name is not null then
    --
    l_lkcacass_str := l_lkcacass_str||' '
                      ||p_lkup_name||'(l_hv).fk_id := objlook.'||p_masterfkcol_name||'; ';
    --
  end if;
  --
  if p_masterfk1col_name is not null then
    --
    l_lkcacass_str := l_lkcacass_str||' '
                      ||p_lkup_name||'(l_hv).fk1_id := objlook.'||p_masterfk1col_name||'; ';
    --
  end if;
  --
  if p_masterfk2col_name is not null then
    --
    l_lkcacass_str := l_lkcacass_str||' '
                      ||p_lkup_name||'(l_hv).fk2_id := objlook.'||p_masterfk2col_name||'; ';
    --
  end if;
  --
  if p_masterfk3col_name is not null then
    --
    l_lkcacass_str := l_lkcacass_str||' '
                      ||p_lkup_name||'(l_hv).fk3_id := objlook.'||p_masterfk3col_name||'; ';
    --
  end if;
  --
  if p_masterfk4col_name is not null then
    --
    l_lkcacass_str := l_lkcacass_str||' '
                      ||p_lkup_name||'(l_hv).fk4_id := objlook.'||p_masterfk4col_name||'; ';
    --
  end if;
  --
  if p_masterfk5col_name is not null then
    --
    l_lkcacass_str := l_lkcacass_str||' '
                      ||p_lkup_name||'(l_hv).fk5_id := objlook.'||p_masterfk5col_name||'; ';
    --
  end if;
  --
--  hr_utility.set_location (l_proc||' Start PLSQL block ',30);
  --
  -- Build cursor declaration strings
  --
  l_lkup_curdecstr := '  cursor c_lookup '
                      ||l_lkpcurpmint_str||' '
                      ||'  is '
                      ||p_lkup_query||' ';
  --
  l_inst_curdecstr := '  cursor c_instance '
                      ||l_instcurpmint_str||' '
                      ||'  is '
                      ||p_inst_query||' ';
  --
  if p_coninst_query is not null then
    --
    l_coninst_curdecstr :=  '  cursor c_coninst '
                            ||l_coninstcurpmint_str||' '
                            ||'  is '
                            ||p_coninst_query||' ';
    --
  else
    --
    l_coninst_curdecstr :=  '  ';
    --
  end if;
  --
  -- Build hash value strings
  --
  l_lkuphv_str := 'objlook.'||p_mastercol_name;
  --
  if p_masterfkcol_name is not null then
    --
    l_lkuphv_str := 'nvl('||l_lkuphv_str||',1)+nvl(objlook.'||p_masterfkcol_name||',1) ';
    --
  end if;
  --
  if p_masterfk1col_name is not null then
    --
    l_lkuphv_str := l_lkuphv_str||'+nvl(objlook.'||p_masterfk1col_name||',1) ';
    --
  end if;
  --
  if p_masterfk2col_name is not null then
    --
    l_lkuphv_str := l_lkuphv_str||'+nvl(objlook.'||p_masterfk2col_name||',1) ';
    --
  end if;
  --
  if p_masterfk3col_name is not null then
    --
    l_lkuphv_str := l_lkuphv_str||'+nvl(objlook.'||p_masterfk3col_name||',1) ';
    --
  end if;
  --
  if p_masterfk4col_name is not null then
    --
    l_lkuphv_str := l_lkuphv_str||'+nvl(objlook.'||p_masterfk4col_name||',1) ';
    --
  end if;
  --
  if p_masterfk5col_name is not null then
    --
    l_lkuphv_str := l_lkuphv_str||'+nvl(objlook.'||p_masterfk5col_name||',1) ';
    --
  end if;
  --
  l_lkuphv_str := '    l_hv := mod('||l_lkuphv_str||',ben_hash_utility.get_hash_key); ';
  --
  -- Instance
  --
  l_insthv_str := 'objinst.'||p_detailcol_name;
  --
  if p_masterfkcol_name is not null then
    --
    l_insthv_str := 'nvl('||l_insthv_str||',1)+nvl(objinst.'||p_masterfkcol_name||',1) ';
    --
  end if;
  --
  if p_masterfk1col_name is not null then
    --
    l_insthv_str := l_insthv_str||'+nvl(objinst.'||p_masterfk1col_name||',1) ';
    --
  end if;
  --
  if p_masterfk2col_name is not null then
    --
    l_insthv_str := l_insthv_str||'+nvl(objinst.'||p_masterfk2col_name||',1) ';
    --
  end if;
  --
  if p_masterfk3col_name is not null then
    --
    l_insthv_str := l_insthv_str||'+nvl(objinst.'||p_masterfk3col_name||',1) ';
    --
  end if;
  --
  if p_masterfk4col_name is not null then
    --
    l_insthv_str := l_insthv_str||'+nvl(objinst.'||p_masterfk4col_name||',1) ';
    --
  end if;
  --
  if p_masterfk5col_name is not null then
    --
    l_insthv_str := l_insthv_str||'+nvl(objinst.'||p_masterfk5col_name||',1) ';
    --
  end if;
  --
  l_insthv_str := '    l_hv := mod('||l_insthv_str||',ben_hash_utility.get_hash_key); ';
  --
  -- Build loop strings
  --
  --   Build lookup loop string
  --
  l_lkup_loopstr := '  for objlook in c_lookup '
                    ||l_lkpcurpmcall_str||' '
                    ||'  loop '
/*
                      --
                      -- Temporary: Debugging statements
                      --
                      ||'  hr_utility.set_location('||''''||'Lookup loop '||''''||',10); '
*/
                    ||l_lkuphv_str
                    ||'    if '||p_lkup_name||'.exists(l_hv) then'
                    ||'      l_not_hash_found := false;'
                    ||'      while not l_not_hash_found loop'
                    ||'        l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);'
                    ||'        if not '||p_lkup_name||'.exists(l_hv) then'
                    ||'          l_not_hash_found := true;'
                    ||'          exit;'
                    ||'        else'
                    ||'          l_not_hash_found := false;'
                    ||'        end if;'
                    ||'      end loop;'
                    ||'    end if;'
                    ||'    '||p_lkup_name||'(l_hv).id := objlook.'||p_mastercol_name||'; '
                    ||l_lkcacass_str||' '
/*
                      --
                      -- Temporary: Debugging statements
                      --
                      ||'  hr_utility.set_location('||''''||'objlook.'||p_mastercol_name||' '||''''
                      ||'||objlook.'||p_mastercol_name||',10); '
*/
                    ||'  end loop; ';

  --
  --   Build instance loop string
  --
  if p_coninst_query is not null then
    --
    l_inst_loopstr := '  l_torrwnum := 0; '
      ||'  l_prev_hv  := -1; '
      ||'  if '||p_lkup_name||'.count > 0 then '
      ||'  open c_instance '||l_instcurpmcall_str||'; '
      ||'  for objconinst in c_coninst '
      ||l_coninstcurpmcall_str||' '
      ||'  loop '
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  hr_utility.set_location('||''''||'Context Instance loop '||''''||',10); '
*/
      ||'    l_hv := mod(objconinst.'||p_detailcol_name
      ||',ben_hash_utility.get_hash_key); '
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  hr_utility.set_location('||''''||'objconinst.'||p_detailcol_name||' '||''''
                                 ||'||objconinst.'||p_detailcol_name||',10); '
*/

      ||'    if '||p_lkup_name||'.exists(l_hv) then'
      ||l_lkcacpkcmp_str||' '
      ||'        l_not_hash_found := false; '
      ||'        while not l_not_hash_found loop'
      ||'          l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv); '
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  hr_utility.set_location('||''''||' new l_hv: '||''''
                        ||'||l_hv,10); '
*/
      ||'          if '||p_lkup_name||'.exists(l_hv) then '
      ||l_lkcacpkcmp_str||' '
      ||'              l_not_hash_found := false; '
      ||'            else '
      ||'              l_not_hash_found := true; '
      ||'              exit; '
      ||'            end if; '
      ||'          end if; '
      ||'        end loop; '
      ||'      end if; '
      ||'    else '
      ||'      fnd_message.set_name('||''''||'BEN'||''''||','||''''
               ||'BEN_?????_MISS_HASH_LOOK'||''''||'); '
      ||'      fnd_message.raise_error; '
      ||'    end if; '
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  hr_utility.set_location('||''''||' l_prev_hv: '||''''
                        ||'||l_prev_hv,10); '
*/
      ||'    if l_prev_hv = -1 then '
      ||'    '||p_lkup_name||'(l_hv).starttorele_num := l_torrwnum; '
      ||'    elsif l_hv <> l_prev_hv then '
      ||'    '||p_lkup_name||'(l_prev_hv).endtorele_num := l_torrwnum-1; '
      ||'    '||p_lkup_name||'(l_hv).starttorele_num := l_torrwnum; '
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  hr_utility.set_location('||''''||' l_prev_hv: '||''''
                        ||'||l_prev_hv,10); '
*/
      ||'    end if; '
      ||'  '||l_asgcolval_str
      ||'  l_torrwnum := l_torrwnum+1; '
      ||'  l_prev_hv := l_hv; '
      ||'  end loop; '
      ||'  close c_instance; '
      ||'  '||p_lkup_name||'(l_prev_hv).endtorele_num := l_torrwnum-1; '
      ||'  end if; ';
    --
  else
    --
    l_inst_loopstr := '  l_torrwnum := 0; '
      ||'  l_prev_hv  := -1; '
      ||'  if '||p_lkup_name||'.count > 0 then '
      ||'  for objinst in c_instance '
      ||l_instcurpmcall_str||' '
      ||'  loop '
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  hr_utility.set_location('||''''||'Instance loop '||''''||',10); '
*/
      ||l_insthv_str
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  hr_utility.set_location('||''''||'objinst.'||p_detailcol_name||' '||''''
                                 ||'||objinst.'||p_detailcol_name||',10); '
*/
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  dbms_output.put_line('||''''||' l_hv: '||''''
                        ||'||l_hv); '
*/
      ||'    if '||p_lkup_name||'.exists(l_hv) then'
      ||l_lkcacpkcmp_str||' '
      ||'        l_not_hash_found := false; '
      ||'        while not l_not_hash_found loop'
      ||'          l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv); '
      ||'          if '||p_lkup_name||'.exists(l_hv) then '
      ||l_lkcacpkcmp_str||' '
      ||'              l_not_hash_found := false; '
      ||'            else '
      ||'              l_not_hash_found := true; '
      ||'              exit; '
      ||'            end if; '
      ||'          end if; '
      ||'        end loop; '
      ||'      end if; '
      ||'    else '
      ||'      fnd_message.set_name('||''''||'BEN'||''''||','||''''
               ||'BEN_?????_MISS_HASH_LOOK'||''''||'); '
      ||'      fnd_message.raise_error; '
      ||'    end if; '
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  dbms_output.put_line('||''''||' l_prev_hv: '||''''
                        ||'||l_prev_hv); '
*/
      ||'    if l_prev_hv = -1 then '
      ||'    '||p_lkup_name||'(l_hv).starttorele_num := l_torrwnum; '
      ||'    elsif l_hv <> l_prev_hv then '
      ||'    '||p_lkup_name||'(l_prev_hv).endtorele_num := l_torrwnum-1; '
      ||'    '||p_lkup_name||'(l_hv).starttorele_num := l_torrwnum; '
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  hr_utility.set_location('||''''||' l_prev_hv: '||''''
                        ||'||l_prev_hv,10); '
*/

      ||'    end if; '
      ||'  '||l_asgcolval_str
      ||'  l_torrwnum := l_torrwnum+1; '
      ||'  l_prev_hv := l_hv; '
      ||'  end loop; '
      ||'  '||p_lkup_name||'(l_prev_hv).endtorele_num := l_torrwnum-1; '
      ||'  end if; ';
    --
  end if;
  --
  l_plsql_str := 'DECLARE '
    ||'  e_num_val_err     exception; '
    ||'  PRAGMA EXCEPTION_INIT(e_num_val_err, -6502); '
    ||'  l_torrwnum        pls_integer; '
    ||'  l_prev_hv         pls_integer; '
    ||'  l_hv              pls_integer; '
    ||'  l_not_hash_found  boolean; '
    ||l_dclv_vardecstr||' '
    ||l_lkup_curdecstr
    ||l_coninst_curdecstr
    ||l_inst_curdecstr
    ||'begin '
    ||l_dclv_varassstr||' '
/*
      --
      -- Temporary: Debugging statements
      --
      ||'  hr_utility.set_location('||''''||'Entering BENCACHE PLSBLK '||''''||',10); '
*/
    ||l_lkup_loopstr
/*
      --
      -- Temporary: Debugging statements
      --
      ||'  hr_utility.set_location('||''''||'Dn Lookup loop '||''''||',10); '
*/
    ||l_inst_loopstr
/*
      --
      -- Temporary: Debugging statements
      --
      ||'  hr_utility.set_location ('||''''||'Write cache, '||p_lkup_name||'.count: '||''''
      ||'||'||p_lkup_name||'.count,10); '
      --
      ||'  hr_utility.set_location ('||''''||'Write cache, '||p_inst_name||'.count: '||''''
      ||'||'||p_lkup_name||'.count,10); '
      --
*/
    ||'  exception '
    ||'    when others then '
    ||'  hr_utility.set_location('||''''||' BENCACHE PLSBLK Others Exc: '||''''||',10); '
/*
        --
        -- Temporary: Debugging statements
        --
        ||'  dbms_output.put_line('||''''||' SQLERRM: '||''''
                        ||'||SQLERRM); '
*/
    ||'  raise; '
    ||'  end; ';
  --
--  hr_utility.set_location (l_proc||' Exe DSQL  ',90);
  --
  EXECUTE IMMEDIATE l_plsql_str;
  --
--  hr_utility.set_location (l_proc||' Leaving ',100);
exception
  when others then
    hr_utility.set_location (l_proc||' Others Exc ',100);
    raise;
end Write_MastDet_Cache;
--
procedure Write_BGP_Cache
  (p_mastertab_name    in     varchar2
  ,p_masterpkcol_name  in     varchar2
  ,p_masterfkcol_name  in     varchar2 default null
  ,p_masterfk1col_name in     varchar2 default null
  ,p_masterfk2col_name in     varchar2 default null
  ,p_masterfk3col_name in     varchar2 default null
  ,p_masterfk4col_name in     varchar2 default null
  ,p_masterfk5col_name in     varchar2 default null
  ,p_masid_set         in     ben_cache.IdType default ben_cache.g_id_set
  ,p_tabdet_set        in     ben_cache.TabDetType default ben_cache.g_tabdet_set
  ,p_table1_name       in     varchar2
  ,p_tab1jncol_name    in     varchar2 default null
  ,p_table2_name       in     varchar2 default null
  ,p_tab2jncol_name    in     varchar2 default null
  ,p_table3_name       in     varchar2 default null
  ,p_business_group_id in     number
  ,p_effective_date    in     date     default null
  ,p_context1_colname  in     varchar2 default null
  ,p_context1_id       in     number   default null
  ,p_nonmand_hv        in     boolean  default false
  ,p_lkup_name         in     varchar2
  ,p_inst_name         in     varchar2
  ,p_inst_frclause     in     varchar2 default null
  ,p_lkup_whclause     in     varchar2 default null
  ,p_inst_whclause     in     varchar2 default null
  ,p_inst_queryorby    in     varchar2 default null
  ,p_lkup_subqyhint    in     varchar2 default null
  ,p_lkup_query        in     varchar2 default null
  ,p_instcolnm_set     in     ben_cache.InstColNmType
                              default ben_cache.g_instcolnm_set
  ,p_curparm_set       in     ben_cache.CurParmType
                              default ben_cache.g_curparm_set
  )

is
  --
  l_proc varchar2(72) := 'Write_BGP_Cache';
  --
  l_tabdet_set          ben_cache.TabDetType;
  l_curparm_set         ben_cache.CurParmType;
  l_selinstcolnm_set    ben_cache.InstColNmType;
  l_selinstcol_num      pls_integer;
  l_instcolnm_num       pls_integer;
  --
  l_torrw_num           pls_integer;
  l_curparmele_num      pls_integer;
  l_restinstcolnm_count pls_integer;
  --
  l_lkup_selclause      long;
  l_lkup_query          long;
  l_lkup_subfromclause  long;
  l_lkup_subwhclause    long;
  l_lkup_subquery       long;
  l_inst_selclause      long;
  l_inst_query          long;
  l_lkup_fromclause     long;
  l_lkup_whereclause    long;
  l_lkup_queryorby      long;
  l_inst_fromclause     long;
  l_inst_whereclause    long;
  l_inst_queryorby      long;
  l_masid_whereclause   long;
  l_master_tabname      varchar2(100);
  l_master_tabalias     varchar2(100);
  --
  l_bgpcurpm_name       varchar2(100);
  l_effdatecurpm_name   varchar2(100);
  l_con1idcurpm_name    varchar2(100);
  --
begin
  --
  -- Define table details
  --
  if p_tabdet_set.count = 0 then
    --
    if p_table1_name is not null then
      --
      l_tabdet_set(0).tab_name    := p_table1_name;
      l_tabdet_set(0).tab_jncolnm := p_tab1jncol_name;
      --
    end if;
    --
    if p_table2_name is not null then
      --
      l_tabdet_set(1).tab_name    := p_table2_name;
      l_tabdet_set(1).tab_jncolnm := p_tab2jncol_name;
      --
    end if;
    --
    if p_table3_name is not null then
      --
      l_tabdet_set(2).tab_name    := p_table3_name;
      --
    end if;
    --
  else
    --
    l_tabdet_set := p_tabdet_set;
    --
  end if;
  --
  -- Define cursor parameters
  --
  l_bgpcurpm_name     := 'c_business_group_id';
  l_effdatecurpm_name := 'c_effective_date';
  l_con1idcurpm_name  := 'c_con1_id';
  --
  l_curparm_set.delete;
  l_curparmele_num := 0;
  --
  l_curparm_set(l_curparmele_num).name      := l_bgpcurpm_name;
  l_curparm_set(l_curparmele_num).datatype  := 'NUMBER';
  l_curparm_set(l_curparmele_num).numval    := p_business_group_id;
  l_curparmele_num := l_curparmele_num+1;
  --
  if p_effective_date is not null then
    --
    l_curparm_set(l_curparmele_num).name      := l_effdatecurpm_name;
    l_curparm_set(l_curparmele_num).datatype  := 'DATE';
    l_curparm_set(l_curparmele_num).dateval   := p_effective_date;
    l_curparmele_num := l_curparmele_num+1;
    --
  end if;
  --
  -- Check if the context value is set
  --
  if p_context1_id is not null then
    --
    l_curparm_set(l_curparmele_num).name      := l_con1idcurpm_name;
    l_curparm_set(l_curparmele_num).datatype  := 'NUMBER';
    l_curparm_set(l_curparmele_num).numval    := p_context1_id;
    l_curparmele_num := l_curparmele_num+1;
    --
  end if;
  --
  -- Build the lookup query
  --
  --   Select clause
  --
  l_lkup_selclause   := ' select master.'||p_masterpkcol_name||', '
                        ||'      master.business_group_id ';
  --
  --   Check for master fk col name
  --
  if p_masterfkcol_name is not null then
    --
    l_lkup_selclause   := l_lkup_selclause||', master.'||p_masterfkcol_name;
    --
  end if;
  --
  --   Check for master fk col 1 name
  --
  if p_masterfk1col_name is not null then
    --
    l_lkup_selclause   := l_lkup_selclause||', master.'||p_masterfk1col_name;
    --
  end if;
  --
  --   Check for master fk col 2 name
  --
  if p_masterfk2col_name is not null then
    --
    l_lkup_selclause   := l_lkup_selclause||', master.'||p_masterfk2col_name;
    --
  end if;
  --
  if p_masterfk3col_name is not null then
    --
    l_lkup_selclause   := l_lkup_selclause||', master.'||p_masterfk3col_name;
    --
  end if;
  --
  if p_masterfk4col_name is not null then
    --
    l_lkup_selclause   := l_lkup_selclause||', master.'||p_masterfk4col_name;
    --
  end if;
  --
  if p_masterfk5col_name is not null then
    --
    l_lkup_selclause   := l_lkup_selclause||', master.'||p_masterfk5col_name;
    --
  end if;
  --
  --   From clause
  --
  l_lkup_fromclause  := ' from   '||p_mastertab_name||' master ';
  --
  --   Where clause
  --
  l_lkup_whereclause := ' where master.business_group_id = '
                        ||l_bgpcurpm_name;
  --
  --     Append master id where clause
  --
  if l_masid_whereclause is not null then
    --
    l_lkup_whereclause := l_lkup_whereclause||' and  '||l_masid_whereclause;
    --
  end if;
  --
  if p_effective_date is not null then
    --
    l_lkup_whereclause := l_lkup_whereclause||' and  '||l_effdatecurpm_name
                          ||' between master.effective_start_date '
                          ||'   and     master.effective_end_date ';
    --
  end if;
  --
  -- Restrict by the sub context id
  --
  if p_context1_id is not null then
    --
    l_lkup_whereclause := l_lkup_whereclause||' and  '||p_context1_colname
                          ||' = '||l_con1idcurpm_name;
    --
  end if;
  --
  -- Check for a custom restriction for the lookup query
  --
  if p_lkup_whclause is not null then
    --
    l_lkup_whereclause := l_lkup_whereclause||' '||p_lkup_whclause;
    --
  end if;
  --
  if l_tabdet_set.count > 0 then
    --
    l_lkup_subfromclause := ' from ';
    l_lkup_subwhclause   := ' where table1.'
                            ||p_masterpkcol_name
                            ||' = master.'||p_masterpkcol_name;
    --
    l_inst_fromclause := ' from ';
    --
    -- Check for non mandatory hash values
    --
    if not p_nonmand_hv then
      --
      l_inst_whereclause := ' where table1.'||p_masterpkcol_name||' is not null '
                            ||' and table1.business_group_id = '||l_bgpcurpm_name;
      --
    else
      --
      l_inst_whereclause := ' where table1.business_group_id = '||l_bgpcurpm_name;
      --
    end if;
    --
    --     Append master id where clause
    --
    if l_masid_whereclause is not null then
      --
      l_inst_whereclause := l_inst_whereclause||' and  '||l_masid_whereclause;
      --
    end if;
    --
    -- Restrict by the sub context id
    --
    if p_context1_id is not null then
      --
      l_inst_whereclause := l_inst_whereclause||' and  '||p_context1_colname
                            ||' = '||l_con1idcurpm_name;
      --
    end if;
    --
    -- Check for a custom restriction for the instance query
    --
    if p_inst_whclause is not null then
      --
      l_inst_whereclause := l_inst_whereclause||' '||p_inst_whclause;
      --
    end if;
    --
    for l_torrw_num in l_tabdet_set.first .. l_tabdet_set.last loop
      --
      -- Build lookup sub from clause
      --
      if l_tabdet_set.first = l_torrw_num then
        --
        l_lkup_subfromclause := l_lkup_subfromclause||' '||l_tabdet_set(l_torrw_num).tab_name||' table'||to_char(l_torrw_num+1);
        --
      else
        --
        l_lkup_subfromclause := l_lkup_subfromclause||', '||l_tabdet_set(l_torrw_num).tab_name||' table'||to_char(l_torrw_num+1);
        --
      end if;
      --
      -- Build lookup sub where clause
      --
      if l_tabdet_set(l_torrw_num).tab_jncolnm is not null then
        --
        l_lkup_subwhclause := l_lkup_subwhclause||' and table'||to_char(l_torrw_num+1)||'.'
                              ||l_tabdet_set(l_torrw_num).tab_jncolnm
                              ||' = table'||to_char(l_torrw_num+2)
                              ||'.'||l_tabdet_set(l_torrw_num).tab_jncolnm;
        --
      end if;
      --
      -- Build lookup date restrictions
      --
      if p_effective_date is not null
        and l_tabdet_set(l_torrw_num).tab_datetype is null
      then
        --
        l_lkup_subwhclause := l_lkup_subwhclause||' and '||l_effdatecurpm_name
                              ||'     between table'||to_char(l_torrw_num+1)||'.effective_start_date '
                              ||'       and table'||to_char(l_torrw_num+1)||'.effective_end_date';
        --
      end if;
      --
      -- Build instance from clause
      --
      if l_tabdet_set.first = l_torrw_num then
        --
        l_inst_fromclause := l_inst_fromclause||' '||l_tabdet_set(l_torrw_num).tab_name||' table'||to_char(l_torrw_num+1);
        --
      else
        --
        l_inst_fromclause := l_inst_fromclause||', '||l_tabdet_set(l_torrw_num).tab_name||' table'||to_char(l_torrw_num+1);
        --
      end if;
      --
      -- Build instance join conditions
      --
      if l_tabdet_set(l_torrw_num).tab_jncolnm is not null then
        --
        l_inst_whereclause := l_inst_whereclause||' and table'||to_char(l_torrw_num+1)||'.'
                              ||l_tabdet_set(l_torrw_num).tab_jncolnm
                              ||' = table'||to_char(l_torrw_num+2)
                              ||'.'||l_tabdet_set(l_torrw_num).tab_jncolnm;
        --
      end if;
      --
      -- Build instance date restrictions
      --
      if p_effective_date is not null
        and l_tabdet_set(l_torrw_num).tab_datetype is null
      then
        --
        l_inst_whereclause := l_inst_whereclause
                              ||' and '||l_effdatecurpm_name
                              ||'     between table'||to_char(l_torrw_num+1)||'.effective_start_date '
                              ||'       and table'||to_char(l_torrw_num+1)||'.effective_end_date';
        --
      end if;
      --
    end loop;
    --
    -- Append custom instance from clause
    --
    if p_inst_frclause is not null then
      --
      l_inst_fromclause := l_inst_fromclause||', '||p_inst_frclause;
      --
    end if;
    --
    -- Build the lookup sub query
    --
    l_lkup_subquery      := ' and master.'||p_masterpkcol_name||' in(select ';
    --
    --   Append sub query hint
    --
    if p_lkup_subqyhint is not null then
      --
      l_lkup_subquery      := l_lkup_subquery
                              ||'/*+ '||p_lkup_subqyhint||' */ ';

      --
    end if;
    --
    --   Append sub query
    --
    l_lkup_subquery      := l_lkup_subquery||' table1.'
                            ||p_masterpkcol_name||' '
                            ||l_lkup_subfromclause||' '
                            ||l_lkup_subwhclause||')';
    --
  end if;
  --
  --   Build where clause
  --
  l_lkup_whereclause := l_lkup_whereclause||' '||l_lkup_subquery||' ';
  --
  --   Order by clause
  --
  l_lkup_queryorby   := 'order by master.'||p_masterpkcol_name||'; ';
  --
  -- Check if lookup query is set
  --
  if p_lkup_query is not null then
    --
    l_lkup_query := p_lkup_query;
    --
  else
    --
    l_lkup_query     := l_lkup_selclause
                        ||l_lkup_fromclause
                        ||l_lkup_whereclause
                        ||' '||l_lkup_queryorby;
    --
  end if;
  --
  -- Build the instance query
  --
  --   Select clause
  --
  if p_instcolnm_set.count > 0 then
    --
    l_inst_selclause := 'select ';
    --
    for l_torrw_num in p_instcolnm_set.first .. p_instcolnm_set.last loop
      --
      if l_torrw_num = 0 then
        --
        l_inst_selclause := l_inst_selclause
                            ||' '||p_instcolnm_set(0).col_alias
                            ||'.'||p_instcolnm_set(0).col_name;
        --
      else
        --
        l_inst_selclause := l_inst_selclause
                            ||', '||p_instcolnm_set(l_torrw_num).col_alias
                            ||'.'||p_instcolnm_set(l_torrw_num).col_name;
        --
      end if;
      --
    end loop;
    --
  else
    --
    l_inst_selclause := 'select * ';
    --
  end if;
  --
  -- Build the instance order by clause
  --
  if p_instcolnm_set.count > 0 then
    --
    l_inst_queryorby := ' order by ';
    l_selinstcol_num := 0;
    --
    for l_torrw_num in p_instcolnm_set.first .. p_instcolnm_set.last loop
      --
      if p_instcolnm_set(l_torrw_num).col_type = 'MASTER'
      then
        --
        l_inst_queryorby := l_inst_queryorby
                            ||' '||p_instcolnm_set(l_torrw_num).col_alias
                            ||'.'||p_instcolnm_set(l_torrw_num).col_name;
        --
      elsif p_instcolnm_set(l_torrw_num).col_type = 'RESTRICT'
      then
        --
        l_inst_queryorby := l_inst_queryorby
                            ||', '||p_instcolnm_set(l_torrw_num).col_alias
                            ||'.'||p_instcolnm_set(l_torrw_num).col_name;
        --
      elsif p_instcolnm_set(l_torrw_num).col_type = 'TABLE'
      then
        --
        null;
        --
      else
        --
        -- Populate selection instance column name set
        --
        l_selinstcolnm_set(l_selinstcol_num) := p_instcolnm_set(l_torrw_num);
        l_selinstcol_num := l_selinstcol_num+1;
        --
      end if;
      --
    end loop;
    --
    -- Append extra order by clause
    --
    if p_inst_queryorby is not null then
      --
      l_inst_queryorby := l_inst_queryorby||', '||p_inst_queryorby;
      --
    end if;
    --
    l_inst_queryorby := l_inst_queryorby||'; ';
    --
  end if;
  --
  l_inst_query := l_inst_selclause
                  ||' '||l_inst_fromclause
                  ||' '||l_inst_whereclause
                  ||' '||l_inst_queryorby;
  --
  ben_cache.Write_MastDet_Cache
    (p_mastercol_name    => p_masterpkcol_name
    ,p_detailcol_name    => p_masterpkcol_name
    ,p_masterfkcol_name  => p_masterfkcol_name
    ,p_masterfk1col_name => p_masterfk1col_name
    ,p_masterfk2col_name => p_masterfk2col_name
    ,p_masterfk3col_name => p_masterfk3col_name
    ,p_masterfk4col_name => p_masterfk4col_name
    ,p_masterfk5col_name => p_masterfk5col_name
    ,p_lkup_name         => p_lkup_name
    ,p_inst_name         => p_inst_name
    ,p_lkup_query        => l_lkup_query
    ,p_inst_query        => l_inst_query
    ,p_nonmand_hv        => p_nonmand_hv
    ,p_instcolnm_set     => p_instcolnm_set
    ,p_curparm_set       => l_curparm_set
    );
  --
end Write_BGP_Cache;
--
function check_list_duplicate
  (p_list in out nocopy ben_cache.IdType
  ,p_id   in     number
  )
return boolean
is

  l_hv          pls_integer;
  l_clash_count pls_integer;

begin
  --
  if p_id is null then
    --
    return true;
    --
  end if;
  --
  l_hv := mod(p_id,ben_hash_utility.get_hash_key);
  --
  if p_list.exists(l_hv)
  then
    --
    -- Validate that the ids match
    --
    if p_list(l_hv).id = p_id
    then
      --
      return true;
      --
    else
      --
      -- Clash found. Skip until correct value is found
      --
      l_hv := l_hv+ben_hash_utility.get_hash_jump;
      l_clash_count := 0;
      --
      loop
        --
        if p_list(l_hv).id = p_id
        then
          --
          return true;
          exit;
          --
        else
          --
          -- One in a billion case of different ids getting
          -- same hash value. Increment for 1000 skips
          --
          if l_clash_count < 1000 then
            --
            l_hv := l_hv+ben_hash_utility.get_hash_jump;
            l_clash_count := l_clash_count+1;
            --
          else
            --
            -- Value does not exist in list so assign to the next
            -- free hash value+jump element
            --
            l_hv := mod(p_id,ben_hash_utility.get_hash_key)+ben_hash_utility.get_hash_jump;
            --
            loop
              --
              if p_list.exists(l_hv) then
                --
                l_hv := l_hv+ben_hash_utility.get_hash_jump;
                --
              else
                --
                p_list(l_hv).id := p_id;
                return false;
                exit;
                --
              end if;
              --
            end loop;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  else
    --
    p_list(l_hv).id := p_id;
    return false;
    --
  end if;
  --
end;
--
end ben_cache;

/
