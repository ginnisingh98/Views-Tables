--------------------------------------------------------
--  DDL for Package Body JTF_DPF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DPF" as
  /* $Header: jtfdpfb.pls 120.1 2005/07/02 00:40:14 appldev ship $ */
  procedure get_dpf_tbl(p_lang varchar2, asn varchar2,
    dpf out NOCOPY dpf_tbl) is
    ddindx binary_integer := 1;
    t_head_log_asn fnd_application.application_short_name%type;
    t_head_log_name jtf_dpf_logical_pages_b.logical_page_name%type;
    t_rtn_log_asn fnd_application.application_short_name%type;
    t_rtn_log_name jtf_dpf_logical_pages_b.logical_page_name%type;
    t_log_descr jtf_dpf_logical_flows_tl.logical_flow_description%type;

    cursor c1 (pp_asn varchar2) is
      select
        lf.logical_flow_id,
        lf.logical_flow_name,
	lf.logical_flow_head_id,
	lf.return_to_page_id,
	lf.flow_finalizer_class,
        -- lf.logical_flow_description,
        lf.validate_flag,
	lf.secure_flow_flag,
	lf.enabled_clone_flag,
	lf.last_updated_by -- was: base_flow_flag
      from jtf_dpf_logical_flows_b lf
        where lf.application_id =
          (select application_id from fnd_application fa2
              where fa2.application_short_name = pp_asn);
  begin
    for c1_rec in c1(asn) loop
      select logical_flow_description into t_log_descr
        from jtf_dpf_logical_flows_tl lftl
	where lftl.logical_flow_id = c1_rec.logical_flow_id
	and lftl.language = p_lang;

      select application_short_name
        into t_head_log_asn
	from fnd_application fa where fa.application_id =
	  (select lp.application_id from jtf_dpf_logical_pages_b lp
	    where lp.logical_page_id = c1_rec.logical_flow_head_id);

      select lp2.logical_page_name
        into t_head_log_name
        from jtf_dpf_logical_pages_b lp2
	where lp2.logical_page_id = c1_rec.logical_flow_head_id;

      select application_short_name
        into t_rtn_log_asn
	from fnd_application fa where fa.application_id =
	  (select lp.application_id from jtf_dpf_logical_pages_b lp
	    where lp.logical_page_id = c1_rec.return_to_page_id);

      select lp2.logical_page_name
        into t_rtn_log_name
        from jtf_dpf_logical_pages_b lp2
	where lp2.logical_page_id = c1_rec.return_to_page_id;

      -- create the new record at index ddindx
      dpf(ddindx).dpf_id := c1_rec.logical_flow_id;
      dpf(ddindx).dpf_name := c1_rec.logical_flow_name;
      dpf(ddindx).head_logical_asn := t_head_log_asn;
      dpf(ddindx).head_logical_name := t_head_log_name;
      dpf(ddindx).rtn_to_page_logical_asn := t_rtn_log_asn;
      dpf(ddindx).rtn_to_page_logical_name := t_rtn_log_name;
      dpf(ddindx).flow_finalizer_class := c1_rec.flow_finalizer_class;
      dpf(ddindx).logical_flow_description := t_log_descr;
      dpf(ddindx).validate_flag := c1_rec.validate_flag;
      dpf(ddindx).secure_flow_flag := c1_rec.secure_flow_flag;
      dpf(ddindx).active_flag := c1_rec.enabled_clone_flag;

--      if c1_rec.base_flow_flag = 'T'
      if c1_rec.last_updated_by = 1
        then dpf(ddindx).editable_flag := 'F';
        else dpf(ddindx).editable_flag := 'T';
      end if;

      -- increment ddindx
      ddindx := ddindx + 1;
    end loop;
  end;
  procedure get_logical_tbl(p_lang varchar2, asn varchar2,
    log out NOCOPY logical_tbl) is
    cursor c1 (pp_asn varchar2) is
      select
        lp.logical_page_name,
        lp.logical_page_type,
        -- lp.logical_page_description,
        lp.page_controller_class,
        lp.page_permission_name,
	lp.logical_page_id
      from jtf_dpf_logical_pages_b lp
        where lp.application_id =
          (select application_id from fnd_application fa2
              where fa2.application_short_name = pp_asn);
    t_asn fnd_application.application_short_name%type;
    t_def_phys_id jtf_dpf_lgcl_phy_rules.physical_page_id%type;
    t_phys_page_name jtf_dpf_physical_pages_b.physical_page_name%type;
    ddindx binary_integer := 1;
    t_log_page_descr jtf_dpf_logical_pages_tl.logical_page_description%type;
  begin
    for c1_rec in c1(asn) loop
      select application_short_name
        into t_asn
        from fnd_application fa
        where fa.application_id =
	  (select pp.application_id
	    from jtf_dpf_physical_pages_b pp
	    where pp.physical_page_id =
	      (select lpr.physical_page_id from jtf_dpf_lgcl_phy_rules lpr
		where lpr.logical_page_id = c1_rec.logical_page_id and
		  lpr.default_page_flag='T'));

      select logical_page_description into t_log_page_descr
        from jtf_dpf_logical_pages_tl o
        where o.logical_page_id = c1_rec.logical_page_id and
          o.language = p_lang;

      select lpr.physical_page_id
	into t_def_phys_id
	from jtf_dpf_lgcl_phy_rules lpr
	where lpr.logical_page_id = c1_rec.logical_page_id and
	  lpr.default_page_flag = 'T';

      select pp.physical_page_name
	into t_phys_page_name
	from jtf_dpf_physical_pages_b pp
	where pp.physical_page_id =
	  (select lpr.physical_page_id from jtf_dpf_lgcl_phy_rules lpr
	    where lpr.logical_page_id = c1_rec.logical_page_id and
	      lpr.default_page_flag = 'T');

      -- create the new record
      log(ddindx).logical_page_id := c1_rec.logical_page_id;
      log(ddindx).logical_page_name := c1_rec.logical_page_name;
      log(ddindx).logical_page_type := c1_rec.logical_page_type;
      log(ddindx).logical_page_description := t_log_page_descr;
--      log(ddindx).secure_page_flag := c1_rec.secure_page_flag;
      log(ddindx).page_controller_class := c1_rec.page_controller_class;
      log(ddindx).page_permission_name := c1_rec.page_permission_name;
      log(ddindx).def_phys_asn := t_asn;
      log(ddindx).def_phys_id := t_def_phys_id;
      log(ddindx).def_phys_name := t_phys_page_name;

      -- increment ddindx
      ddindx := ddindx+1;
    end loop;
    null;
  end;
  procedure get_physical_tbl(p_lang varchar2, asn varchar2,
    log out NOCOPY physical_tbl) is
    cursor c1 (pp_asn varchar2) is
      select
        pp.physical_page_id,
        pp.physical_page_name
        -- pp.physical_page_description
      from jtf_dpf_physical_pages_b pp
        where pp.application_id =
          (select fa.application_id from fnd_application fa
            where fa.application_short_name = pp_asn);
    ddindx binary_integer := 1;
    t_phys_page_descr jtf_dpf_physical_pages_tl.physical_page_description%type;
  begin
    for c1_rec in c1(asn) loop
      select physical_page_description into t_phys_page_descr
	from jtf_dpf_physical_pages_tl ptl
	where  ptl.physical_page_id = c1_rec.physical_page_id and
	  ptl.language = p_lang;
      -- create the new record
      log(ddindx).id := c1_rec.physical_page_id;
      log(ddindx).name := c1_rec.physical_page_name;
      log(ddindx).descr := t_phys_page_descr;

      -- increment the index
      ddindx := ddindx + 1;
    end loop;
  end;
  procedure get_physical_non_default_tbl(asn varchar2,
      retval out NOCOPY physical_non_default_tbl) is
    ddindx binary_integer := 1;
    q2_c1 jtf_dpf_physical_pages_b.physical_page_name%type;
    q2_c2 fnd_application.application_short_name%type;
    q3_c1 jtf_dpf_rules_b.rule_name%type;
    q3_c2 fnd_application.application_short_name%type;
    cursor c1(pp_asn varchar2) is
      select unique
        lp.logical_page_name,
        lpr.rule_eval_sequence,
        lpr.physical_page_id,
        lpr.rule_id
      from jtf_dpf_logical_pages_b lp, jtf_dpf_lgcl_phy_rules lpr
      where
        lp.logical_page_id = lpr.logical_page_id and
        lp.application_id =
          (select application_id from fnd_application fa where
	    fa.application_short_name = pp_asn) and
        lpr.default_page_flag = 'F'
      order by lp.logical_page_name, lpr.rule_eval_sequence;
    q2_c2_temp fnd_application.application_id%type;
    q3_c2_temp fnd_application.application_id%type;
  begin
    for c1_rec in c1(asn) loop
      select pp.physical_page_name,
        pp.application_id
--        (select application_short_name from fnd_application fa2
--        where fa2.application_id = pp.application_id)
      into q2_c1, q2_c2_temp
      from jtf_dpf_physical_pages_b pp
      where pp.physical_page_id = c1_rec.physical_page_id;

      select application_short_name
        into q2_c2
        from fnd_application fa2 where fa2.application_id = q2_c2_temp;

      select
        r.rule_name,
	r.application_id
--        (select application_short_name from fnd_application fa
--          where fa.application_id = r.application_id)
      into q3_c1, q3_c2_temp
      from jtf_dpf_rules_b r
      where r.rule_id = c1_rec.rule_id;

      select application_short_name into q3_c2 from fnd_application
        where fnd_application.application_id = q3_c2_temp;

      -- write contents of the record in retval(ddindx)
      retval(ddindx).logical_name := c1_rec.logical_page_name;
      retval(ddindx).rule_eval_sequence := c1_rec.rule_eval_sequence;
      retval(ddindx).rule_asn := q3_c2;
      retval(ddindx).rule_name := q3_c1;
      retval(ddindx).phys_asn := q2_c2;
      retval(ddindx).phys_id := c1_rec.physical_page_id;
      retval(ddindx).phys_name := q2_c1;

      -- increment ddindx
      ddindx := ddindx+1;
    end loop;
  end;
  procedure get_rule_tbl(p_lang varchar2, asn varchar2, retval out NOCOPY rule_tbl) is
    cursor c1(pp_asn varchar2) is
      select
        r.rule_id,
        r.rule_name,
        -- r.rule_description,
	rp.rule_param_name,
	rp.rule_param_value,
	rp.rule_param_condition
      from jtf_dpf_rules_b r, jtf_dpf_rule_params rp
        where
	  r.rule_id = rp.rule_id and
	  r.application_id =
          (select application_id from fnd_application fa
            where fa.application_short_name = pp_asn)
        order by rp.rule_param_sequence;
    ddindx binary_integer := 1;
    t_rules_descr jtf_dpf_rules_tl.rule_description%type;
  begin
    for c1_rec in c1(asn) loop
      -- create a new record
      select rule_description into t_rules_descr
        from jtf_dpf_rules_tl jrtl
	where jrtl.rule_id = c1_rec.rule_id and
	   jrtl.language = p_lang;

      retval(ddindx).rule_id := c1_rec.rule_id;
      retval(ddindx).rule_name := c1_rec.rule_name;
      retval(ddindx).rule_description := t_rules_descr;
      retval(ddindx).rule_param_name := c1_rec.rule_param_name;
      retval(ddindx).rule_param_value := c1_rec.rule_param_value;
      retval(ddindx).rule_param_condition := c1_rec.rule_param_condition;

      -- increment ddindx
      ddindx := ddindx + 1;
    end loop;
  end;
  procedure get_next_logical_default_tbl(asn varchar2,
      retval out NOCOPY next_logical_default_tbl) is
    cursor q1 (pp_asn varchar2) is
      select logical_flow_name, logical_flow_id
        from jtf_dpf_logical_flows_b lf
        where lf.application_id =
          (select application_id from fnd_application fa
            where fa.application_short_name = pp_asn);

    cursor q2 (pp_q1_c2 number) is
      select logical_page_id, logical_next_page_id
        from jtf_dpf_lgcl_next_rules lnr
        where lnr.logical_flow_id = pp_q1_c2 and
          lnr.default_next_flag='T';
    ddindx binary_integer := 1;
    q3_c1 fnd_application.application_short_name%type;
    q3_c2 jtf_dpf_logical_pages_b.logical_page_name%type;
    q4_c1 fnd_application.application_short_name%type;
    q4_c2 jtf_dpf_logical_pages_b.logical_page_name%type;
    q3_c1_temp fnd_application.application_id%type;
    q4_c1_temp fnd_application.application_id%type;
  begin
    for q1_rec in q1(asn) loop
      for q2_rec in q2(q1_rec.logical_flow_id) loop
        select
	  lp.application_id,
--	  (select application_short_name from fnd_application fa
--	    where fa.application_id = lp.application_id),
	  lp.logical_page_name
	into q3_c1_temp, q3_c2
	from jtf_dpf_logical_pages_b lp
	where lp.logical_page_id = q2_rec.logical_page_id;

	select application_short_name into q3_c1
	  from fnd_application where application_id = q3_c1_temp;

        select
	  lp.application_id,
--	  (select application_short_name from fnd_application fa
--	    where fa.application_id = lp.application_id),
	  lp.logical_page_name
	into q4_c1_temp, q4_c2
	from jtf_dpf_logical_pages_b lp
	where lp.logical_page_id = q2_rec.logical_next_page_id;

	select application_short_name into q4_c1
	  from fnd_application where application_id = q4_c1_temp;

        -- write the data into a new record
	retval(ddindx).dpf_name := q1_rec.logical_flow_name;
	retval(ddindx).dpf_id := q1_rec.logical_flow_id;
	retval(ddindx).key_log_asn := q3_c1;
	retval(ddindx).key_log_name := q3_c2;
	retval(ddindx).result_log_asn := q4_c1;
	retval(ddindx).result_log_name := q4_c2;

        -- increment the record index
	ddindx := ddindx+1;
      end loop;
    end loop;
  end;
  procedure get_next_logical_non_def_tbl(asn varchar2,
    retval out NOCOPY next_logical_non_default_tbl) is
    cursor q1 (pp_asn varchar2) is
      select logical_flow_name, logical_flow_id
        from jtf_dpf_logical_flows_b lf
        where lf.application_id =
          (select application_id from fnd_application fa
            where fa.application_short_name = pp_asn);

    cursor q2 (pp_q1_c2 number) is
      select
        logical_page_id,
        logical_next_page_id,
        rule_eval_seq,
        rule_id
      from jtf_dpf_lgcl_next_rules lnr
      where lnr.logical_flow_id = pp_q1_c2 and
        lnr.default_next_flag='F'
      order by lnr.rule_eval_seq;
    ddindx binary_integer := 1;
    q3_c1 fnd_application.application_short_name%type;
    q3_c2 jtf_dpf_rules_b.rule_name%type;
    q4_c1 fnd_application.application_short_name%type;
    q4_c2 jtf_dpf_logical_pages_b.logical_page_name%type;
    q5_c1 fnd_application.application_short_name%type;
    q5_c2 jtf_dpf_logical_pages_b.logical_page_name%type;
    q3_c1_temp fnd_application.application_id%type;
    q4_c1_temp fnd_application.application_id%type;
    q5_c1_temp fnd_application.application_id%type;
  begin
    for q1_rec in q1(asn) loop
      for q2_rec in q2(q1_rec.logical_flow_id) loop
        select
	  r.application_id,
--	  (select application_short_name from fnd_application fa
--	    where fa.application_id = r.application_id),
	  r.rule_name
	into q3_c1_temp, q3_c2
	from jtf_dpf_rules_b r
	where r.rule_id = q2_rec.rule_id;

        select application_short_name
	  into q3_c1
	  from fnd_application
          where application_id = q3_c1_temp;

	select
	  lp.application_id,
--	  (select application_short_name from fnd_application fa
--	    where fa.application_id = lp.application_id),
	  lp.logical_page_name
	into q4_c1_temp, q4_c2
	from jtf_dpf_logical_pages_b lp
	where lp.logical_page_id = q2_rec.logical_page_id;

        select application_short_name
	  into q4_c1
	  from fnd_application
          where application_id = q4_c1_temp;

	select
	  lp.application_id,
--	  (select application_short_name from fnd_application fa
--	    where fa.application_id = lp.application_id),
	  lp.logical_page_name
	into q5_c1_temp, q5_c2
	from jtf_dpf_logical_pages_b lp
	where lp.logical_page_id = q2_rec.logical_next_page_id;

        select application_short_name
	  into q5_c1
	  from fnd_application
          where application_id = q5_c1_temp;

        -- insert a new record into the table
	retval(ddindx).dpf_name := q1_rec.logical_flow_name;
	retval(ddindx).dpf_id := q1_rec.logical_flow_id;
	retval(ddindx).rule_asn := q3_c1;
	retval(ddindx).rule_name := q3_c2;
	retval(ddindx).key_log_asn := q4_c1;
	retval(ddindx).key_log_name := q4_c2;
	retval(ddindx).result_log_asn := q5_c1;
	retval(ddindx).result_log_name := q5_c2;

        -- increment the index
	ddindx := ddindx+1;
      end loop;
    end loop;
  end;

  procedure get_physical_attribs_tbl(asn varchar2,
    retval out NOCOPY physical_attribs_tbl) is
    cursor c1 (pp_asn varchar2) is
      select pp.physical_page_id
      from jtf_dpf_physical_pages_b pp
        where pp.application_id =
          (select fa.application_id from fnd_application fa
            where fa.application_short_name = pp_asn);
    ddindx binary_integer := 1;
  begin
    for c1_rec in c1(asn) loop
      -- for any phy_attribs with c1_rec.physical_page_id...
      for c2_rec in (select
	  pa.PHYSICAL_PAGE_ID, pa.PAGE_ATTRIBUTE_NAME,pa.PAGE_ATTRIBUTE_VALUE
	  from jtf_dpf_phy_attribs pa
	  where pa.physical_page_id = c1_rec.physical_page_id) loop
        -- add a new record
        retval(ddindx).id := c2_rec.physical_page_id;
        retval(ddindx).name := c2_rec.page_attribute_name;
        retval(ddindx).value := c2_rec.page_attribute_value;

	-- incr the index
        ddindx := ddindx + 1;
      end loop;
    end loop;
  end;

  procedure get (asn varchar2,
   p_lang in out NOCOPY varchar2,
   descrs_only boolean,
   dpf out NOCOPY dpf_tbl,
   log out NOCOPY logical_tbl,
   phys out NOCOPY physical_tbl,
   phys_non_def out NOCOPY physical_non_default_tbl,
   rule out NOCOPY rule_tbl,
   next_log_def out NOCOPY next_logical_default_tbl,
   next_log_non_def out NOCOPY next_logical_non_default_tbl,
   phys_atts out NOCOPY physical_attribs_tbl) is
  l_lang_use fnd_languages.language_code%type;
  l_lang_ret fnd_languages.language_code%type;
  begin
    select userenv('LANG') into l_lang_ret from dual;
    if p_lang is null then
      l_lang_use := l_lang_ret;
    else
      l_lang_use := p_lang;
    end if;

    get_dpf_tbl(l_lang_use, asn, dpf);
    get_logical_tbl(l_lang_use, asn, log);
    get_physical_tbl(l_lang_use, asn, phys);
    if not descrs_only then
      get_physical_non_default_tbl(asn, phys_non_def);
    end if;
    get_rule_tbl(l_lang_use, asn, rule);
    if not descrs_only then
      get_next_logical_default_tbl(asn, next_log_def);
    end if;
    if not descrs_only then
      get_next_logical_non_def_tbl(asn, next_log_non_def);
    end if;
    if not descrs_only then
      get_physical_attribs_tbl(asn, phys_atts);
    end if;

    p_lang := l_lang_ret;
  end;

  -- rule editing procedures
  -- removes the rule and any rule_params that were stored under it.  Has
  -- no effect if the rule doesn't exist
  procedure rule_delete(p_rule_id number) is
  begin
    delete from jtf_dpf_rule_params where rule_id = p_rule_id;
    delete from jtf_dpf_rules_b where rule_id=p_rule_id;
    delete from jtf_dpf_rules_tl where rule_id=p_rule_id;
--    commit;
  end;

  -- change the rule specified by rule_id so that it is of the specified
  -- application, name, and description.  Has no effect
  -- if there's no such rule p_rule_id
  function rule_update(p_rule_id number,
    upd rule_update_rec) return number is
      t_appid number;
      existential number;
  begin
    if upd.p_new_name is null or 0 = length(upd.p_new_name) then
      return 3;
    end if;

    select application_id into t_appid
      from fnd_application where application_short_name = upd.p_new_asn;

    -- is the proposed new name already taken?  count the number
    -- of rows which already have this name and appid, but which have a
    -- different logical_flow_id
    select count(*) into existential
      from jtf_dpf_rules_b
      where rule_id <> p_rule_id and
	rule_name = upd.p_new_name and
	application_id = t_appid;

    if existential > 0 then return 2; end if;

    update jtf_dpf_rules_b
      set
        application_id=t_appid,
        rule_name = upd.p_new_name,
	-- rule_description = p_new_descr,
		object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
      where rule_id = p_rule_id;

    if upd.p_new_descr is null or fnd_api.g_miss_char <> upd.p_new_descr then
      update jtf_dpf_rules_tl
        set rule_description = upd.p_new_descr,
		-- object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
      where rule_id = p_rule_id and language = userenv('LANG');
    end if;
    return 1;
  end;

  function rule_new(p_asn varchar2, p_name varchar2, p_descr varchar2,
      rules new_rule_param_tbl) return number is
    counter number;
    t_appid number;
    t_ruleid number;
    existential number;
    t_rowid rowid;
  begin
    if p_name is null or 0 = length(p_name) then return 3; end if;

    select application_id into t_appid
      from fnd_application
      where application_short_name = p_asn;

    select count(*) into existential from jtf_dpf_rules_b
      where rule_name = p_name and
	application_id = t_appid;

    if existential <> 0 then return 2; end if;

    -- create a new rule
    select jtf_dpf_rules_s.nextval into t_ruleid from dual;

    JTF_DPF_RULES_PKG.INSERT_ROW(
      X_ROWID                      => t_rowid,
      X_RULE_ID                    => t_ruleid,
      X_APPLICATION_ID             => t_appid,
      X_OBJECT_VERSION_NUMBER      => 1,
      X_RULE_NAME                  => p_name,
      X_RULE_DESCRIPTION           => p_descr,
      X_CREATION_DATE              => SYSDATE,
      X_CREATED_BY                 => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_DATE           => SYSDATE,
      X_LAST_UPDATED_BY            => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_LOGIN          =>  FND_GLOBAL.CONC_LOGIN_ID);


--    insert into jtf_dpf_rules_b(
--	rule_id,
--	application_id, rule_name, -- rule_description,
--		OBJECT_VERSION_NUMBER,
--		CREATED_BY,
--		CREATION_DATE,
--		LAST_UPDATE_DATE,
--		LAST_UPDATED_BY,
--		LAST_UPDATE_LOGIN)
--    values(t_ruleid, t_appid, p_name, -- p_descr,
--		1,
--		FND_GLOBAL.USER_ID,
--		SYSDATE,
--		SYSDATE,
--		FND_GLOBAL.USER_ID,
--		FND_GLOBAL.CONC_LOGIN_ID);
--
--    insert into jtf_dpf_rules_tl(
--	RULE_ID,
--	LANGUAGE,
--	SOURCE_LANG,
--	RULE_DESCRIPTION,
--		OBJECT_VERSION_NUMBER,
--		CREATED_BY,
--		CREATION_DATE,
--		LAST_UPDATE_DATE,
--		LAST_UPDATED_BY,
--		LAST_UPDATE_LOGIN)
--    values (
--	t_ruleid,
--	userenv('LANG'),
--	userenv('LANG'),
--	p_descr,
--		1,
--		FND_GLOBAL.USER_ID,
--		SYSDATE,
--		SYSDATE,
--		FND_GLOBAL.USER_ID,
--		FND_GLOBAL.CONC_LOGIN_ID);


    rule_set_params(t_ruleid, rules);
--    commit;
    return 1;

  end;

  -- Sets the params of a rule rule_id.  If there's no such rule,
  -- then it has no effect.  Removes the old rule_params efore
  -- adding these.
  -- it is not allowed to call this procedure with an empty or null
  -- 'rules'.
  procedure rule_set_params(p_rule_id number,
      rules new_rule_param_tbl) is
    idx binary_integer;
  begin
    delete from jtf_dpf_rule_params where rule_id = p_rule_id;
    idx := rules.first;
    while true loop
      insert into jtf_dpf_rule_params(
	rule_param_sequence,
        rule_id,
        rule_param_condition,
        rule_param_name,
        rule_param_value,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
      values (
	idx,
        p_rule_id,
        rules(idx).condition,
        rules(idx).param_name,
        rules(idx).param_value,
		1,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID);

      if idx = rules.last then exit; end if;
      idx := rules.next(idx);
    end loop;
--    commit;
  end;

  -- Physical editing procedures
  -- remove the physical denoted by ppid.  If there's no such physical,
  -- then this has no effect.
  procedure phys_delete(p_ppid number) is
  begin
    delete from jtf_dpf_physical_pages_b where physical_page_id=p_ppid;
    delete from jtf_dpf_physical_pages_tl where physical_page_id=p_ppid;
--    commit;
  end;

  function phys_update(p_ppid number,
      upd phys_update_rec) return number is
      t_appid number;
      existential number;
  begin
    if upd.p_name is null or 0 = length(upd.p_name) then return 3; end if;

    select application_id into t_appid
      from fnd_application where application_short_name = upd.p_new_asn;

  -- why was this ever here!? wird; I don't remember ever thinking
  -- that this was the right rule for physicals...
--    -- if there already exists a physical with this name and asn,
--    -- (other than the one we're being asked to update) then just
--    -- return '2' without touching the data
--    select count(*) into existential
--      from jtf_dpf_physical_pages_b
--      where physical_page_id <> p_ppid and
--        physical_page_name = upd.p_name and
--	application_id = t_appid;
--    if existential > 0 then return 2; end if;

    update jtf_dpf_physical_pages_b
      set
        application_id = t_appid,
        physical_page_name = upd.p_name,
        -- physical_page_description = p_descr,
		object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
      where physical_page_id = p_ppid;

    if upd.p_descr is null or fnd_api.g_miss_char <> upd.p_descr then
      update jtf_dpf_physical_pages_tl
        set
          physical_page_description = upd.p_descr,
		-- object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
	where physical_page_id = p_ppid and
	  language=userenv('LANG');
    end if;
--    commit;
    return 1;
  end;

  procedure phys_attribs_update(p_ppid number,
    p_new_ones new_phys_attribs_tbl) is
      idx binary_integer;
  begin
    -- remove any old ones
    delete from jtf_dpf_phy_attribs where physical_page_id = p_ppid;

    -- add the new ones, if any
    if p_new_ones is not null and p_new_ones.count <> 0 then
      idx := p_new_ones.first;
      while true loop
        insert into jtf_dpf_phy_attribs(
		physical_page_id,
		page_attribute_name,
		page_attribute_value,
			OBJECT_VERSION_NUMBER,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN)
	values (
	  p_ppid,
	  p_new_ones(idx).name,
	  p_new_ones(idx).value,
		1,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID);
        if idx = p_new_ones.last then exit; end if;
        idx := p_new_ones.next(idx);
      end loop;
    end if;
--    commit;
  end;

  function phys_new (p_asn varchar2, p_name varchar2, p_descr varchar2)
    return number is
      t_appid number;
      existential number;
      t_phys_id jtf_dpf_physical_pages_b.physical_page_id%type;
      t_rowid rowid;
  begin
    if p_name is null or 0 = length(p_name) then return 3; end if;

    select application_id into t_appid
      from fnd_application where application_short_name = p_asn;

-- why was this here!? we do allow more than one physical
-- with the same name!
--    -- if there already exists a physical with this name and asn,
--    -- then just return '2' without touching the data
--    select count(*) into existential
--      from jtf_dpf_physical_pages_b
--      where application_id = t_appid and
--        physical_page_name = p_name;
--    if existential > 0 then return 2; end if;

    select jtf_dpf_physical_pages_s.nextval into t_phys_id from dual;

    JTF_DPF_PHYSICAL_PAGES_PKG.insert_row(
      X_ROWID                      => t_rowid,
      X_PHYSICAL_PAGE_ID            => t_phys_id,
      X_PHYSICAL_PAGE_NAME         => p_name,
      X_APPLICATION_ID             => t_appid,
      X_OBJECT_VERSION_NUMBER      => 1,
      X_PHYSICAL_PAGE_DESCRIPTION => p_descr,
      X_CREATION_DATE              => SYSDATE,
      X_CREATED_BY                 => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_DATE           => SYSDATE,
      X_LAST_UPDATED_BY            => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_LOGIN          =>  FND_GLOBAL.CONC_LOGIN_ID);

--    insert into jtf_dpf_physical_pages_b(
--	physical_page_id,
--	physical_page_name,
--	-- physical_page_description,
--	application_id,
--		OBJECT_VERSION_NUMBER,
--		CREATED_BY,
--		CREATION_DATE,
--		LAST_UPDATE_DATE,
--		LAST_UPDATED_BY,
--		LAST_UPDATE_LOGIN)
--    values (
--	t_phys_id,
--	p_name,
--	-- p_descr,
--        t_appid,
--		1,
--		FND_GLOBAL.USER_ID,
--		SYSDATE,
--		SYSDATE,
--		FND_GLOBAL.USER_ID,
--		FND_GLOBAL.CONC_LOGIN_ID);
--
--    insert into jtf_dpf_physical_pages_tl(
--	PHYSICAL_PAGE_ID,
--	LANGUAGE,
--	SOURCE_LANG,
--	PHYSICAL_PAGE_DESCRIPTION,
--		OBJECT_VERSION_NUMBER,
--		CREATED_BY,
--		CREATION_DATE,
--		LAST_UPDATE_DATE,
--		LAST_UPDATED_BY,
--		LAST_UPDATE_LOGIN)
--    values (
--	t_phys_id,
--	userenv('LANG'),
--	userenv('LANG'),
--	p_descr,
--		1,
--		FND_GLOBAL.USER_ID,
--		SYSDATE,
--		SYSDATE,
--		FND_GLOBAL.USER_ID,
--		FND_GLOBAL.CONC_LOGIN_ID);

--    commit;
    return 1;
  end;

  -- dpf editing procedures
  -- delete_flow.  Removes all rows with logical_page_flow from tables:
  -- - jtf_dpf_lgcl_flow_params
  -- - jtf_dpf_logical_flows
  -- - jtf_dpf_lgcl_next_rules
  procedure flow_delete(p_logical_flow_id number) is
  begin
    delete from jtf_dpf_lgcl_flow_params
      where logical_flow_id = p_logical_flow_id;
    delete from jtf_dpf_logical_flows_b
      where logical_flow_id = p_logical_flow_id;
    delete from jtf_dpf_logical_flows_tl
      where logical_flow_id = p_logical_flow_id;
    delete from jtf_dpf_lgcl_next_rules
      where logical_flow_id = p_logical_flow_id;
--    commit;
  end;

  function flow_update(p_logical_flow_id number,
    upd flow_update_rec) return number is
      t_appid number;
      existential number;
      current_name jtf_dpf_logical_flows_b.logical_flow_name%type;
  begin
    if upd.p_new_name is null or 0 = length(upd.p_new_name) then
      return 3;
    end if;

    -- is either logical_page_id bad?  The logical_page_id variables are
    -- p_new_header_logical_page_id and p_rtn_to_logical_page_id.  One of these
    -- is 'bad' if it's not G_MISS_NUM and it doesn't point at a logical in
    -- the jtf_dpf_logical_pages_b table.
    --
    -- if either is bad, then return 4.

    if upd.p_new_header_logical_page_id is null or
	upd.p_rtn_to_logical_page_id is null then
      return 4;
    end if;

    if fnd_api.g_miss_num <> upd.p_new_header_logical_page_id then
      select count(*) into existential
        from jtf_dpf_logical_pages_b
        where logical_page_id = upd.p_new_header_logical_page_id;
      if existential = 0 then return 4; end if;
    end if;

    if fnd_api.g_miss_num <> upd.p_rtn_to_logical_page_id then
      select count(*) into existential
        from jtf_dpf_logical_pages_b
        where logical_page_id = upd.p_rtn_to_logical_page_id;
      if existential = 0 then return 4; end if;
    end if;

    select application_id into t_appid
      from fnd_application where application_short_name = upd.p_new_asn;

    -- is the proposed new name different from the current name, and yet
    -- already taken?  count the number of rows which already have this
    -- name, but which have a different logical_flow_id
    select logical_flow_name into current_name
      from jtf_dpf_logical_flows_b
      where logical_flow_id = p_logical_flow_id;

    if current_name <> upd.p_new_name then
      select count(*) into existential
        from jtf_dpf_logical_flows_b
        where logical_flow_id <> p_logical_flow_id and
          logical_flow_name = upd.p_new_name and
	  application_id = t_appid;

      if existential > 0 then return 2; end if;
    end if;

    update jtf_dpf_logical_flows_b
      set
	logical_flow_name = upd.p_new_name,
	flow_finalizer_class = upd.p_new_flow_finalizer_class,
	-- logical_flow_description = p_new_descr,
	validate_flag = upd.p_new_validate_flag,
	secure_flow_flag = upd.p_new_secure_flow_flag,
	application_id = t_appid,
		object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
      where logical_flow_id = p_logical_flow_id;

    if upd.p_new_descr is null or fnd_api.g_miss_char <> upd.p_new_descr then
      update jtf_dpf_logical_flows_tl
        set
          logical_flow_description = upd.p_new_descr,
		-- object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
        where logical_flow_id = p_logical_flow_id and
	  language=userenv('LANG');
    end if;

    -- update logical_flow_head_id, unless the given is G_MISS_NUM
    if fnd_api.g_miss_num <> upd.p_new_header_logical_page_id then
      update jtf_dpf_logical_flows_b
        set logical_flow_head_id = upd.p_new_header_logical_page_id
      where logical_flow_id = p_logical_flow_id;
    end if;

    -- update return_to_page_id, unless the given is G_MISS_NUM
    if fnd_api.g_miss_num <> upd.p_rtn_to_logical_page_id then
      update jtf_dpf_logical_flows_b
        set return_to_page_id = upd.p_rtn_to_logical_page_id
      where logical_flow_id = p_logical_flow_id;
    end if;

--    commit;
    return 1;
  end;

  function flow_new(
    p_new_asn varchar2,
    p_new_name varchar2,
    p_new_flow_finalizer_class varchar2,
    p_new_descr varchar2,
    p_new_validate_flag varchar2,
    p_new_secure_flow_flag varchar2,
    p_new_header_logical_page_id number,
    p_rtn_to_logical_page_id number) return number is
      t_appid number;
      existential number;
      log_id jtf_dpf_logical_flows_b.logical_flow_id%type;
      t_rowid rowid;
  begin
    if p_new_name is null or 0 = length(p_new_name) then return 3; end if;

    -- if there's no such logical_page_id as either
    -- p_new_header_logical_page_id or p_rtn_to_logical_page_id,
    -- then return 4
    if p_new_header_logical_page_id is null or
         p_rtn_to_logical_page_id is null then
      return 4;
    end if;
    select count(*) into existential
      from jtf_dpf_logical_pages_b
      where logical_page_id = p_new_header_logical_page_id;
    if existential = 0 then return 4; end if;
    select count(*) into existential
      from jtf_dpf_logical_pages_b
      where logical_page_id = p_rtn_to_logical_page_id;
    if existential = 0 then return 4; end if;

    select application_id into t_appid
      from fnd_application where application_short_name = p_new_asn;

    select count(*) into existential
      from jtf_dpf_logical_flows_b
      where application_id = t_appid and
	logical_flow_name = p_new_name;

    if existential <> 0 then return 2; end if;

    select jtf_dpf_logical_flows_s.nextval into log_id from dual;

    jtf_dpf_logical_flows_pkg.INSERT_ROW(
      X_ROWID                      => t_rowid,
      X_LOGICAL_FLOW_ID            => log_id,
      X_LOGICAL_FLOW_HEAD_ID       => p_new_header_logical_page_id,
      X_LOGICAL_FLOW_NAME          => p_new_name,
      X_SECURE_FLOW_FLAG           => p_new_secure_flow_flag,
      X_VALIDATE_FLAG              => p_new_validate_flag,
      X_APPLICATION_ID             => t_appid,
      X_FLOW_FINALIZER_CLASS       => p_new_flow_finalizer_class,
      X_RETURN_TO_PAGE_ID          => p_rtn_to_logical_page_id,
      X_BASE_FLOW_FLAG             => 'F',
--      X_ENABLED_CLONE_FLAG         => 'T',
      X_OBJECT_VERSION_NUMBER      => 1,
      X_LOGICAL_FLOW_DESCRIPTION   => P_NEW_DESCR,
      X_CREATION_DATE              => SYSDATE,
      X_CREATED_BY                 => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_DATE           => SYSDATE,
      X_LAST_UPDATED_BY            => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_LOGIN          =>  FND_GLOBAL.CONC_LOGIN_ID);

--    insert into jtf_dpf_logical_flows_b(
--	logical_flow_id,
--        logical_flow_head_id,
--        return_to_page_id,
--	logical_flow_name,
--	-- logical_flow_description,
--	validate_flag,
--        secure_flow_flag,
--	application_id,
--	flow_finalizer_class,
--	enabled_clone_flag,
--	base_flow_flag,
--		OBJECT_VERSION_NUMBER,
--		CREATED_BY,
--		CREATION_DATE,
--		LAST_UPDATE_DATE,
--		LAST_UPDATED_BY,
--		LAST_UPDATE_LOGIN)
--    values (
--	log_id,
--	p_new_header_logical_page_id,
--	p_rtn_to_logical_page_id,
--	p_new_name,
--	-- p_new_descr,
--	p_new_validate_flag,
--        p_new_secure_flow_flag,
--	t_appid,
--	p_new_flow_finalizer_class,
--	'T',
--	'F',
--		1,
--		FND_GLOBAL.USER_ID,
--		SYSDATE,
--		SYSDATE,
--		FND_GLOBAL.USER_ID,
--		FND_GLOBAL.CONC_LOGIN_ID);
--
--    insert into jtf_dpf_logical_flows_tl(
--	logical_flow_id,
--	language,
--	source_lang,
--	logical_flow_description,
--		OBJECT_VERSION_NUMBER,
--		CREATED_BY,
--		CREATION_DATE,
--		LAST_UPDATE_DATE,
--		LAST_UPDATED_BY,
--		LAST_UPDATE_LOGIN)
--    values (
--	log_id,
--	userenv('LANG'),
--	userenv('LANG'),
--	p_new_descr,
--		1,
--		FND_GLOBAL.USER_ID,
--		SYSDATE,
--		SYSDATE,
--		FND_GLOBAL.USER_ID,
--		FND_GLOBAL.CONC_LOGIN_ID);

--    commit;
    return 1;
  end;

  function flow_copy(p_flow_id number, p_new_flow_id out NOCOPY number)
      return number is
    existential number;
    new_flow_id number;
  begin
    select count(*) into existential
      from jtf_dpf_logical_flows_b
      where logical_flow_id = p_flow_id;

    if existential <> 1 then return 2; end if;

    -- insert a single row into jtf_dpf_logical_flows_b and the
    -- same number of rows that're already in jtf_dpf_logical_flows_tl
    -- for the old p_flow_id.

    select jtf_dpf_logical_flows_s.nextval into new_flow_id from dual;

    p_new_flow_id := new_flow_id;

    insert into jtf_dpf_logical_flows_b(
	LOGICAL_FLOW_ID,
	LOGICAL_FLOW_HEAD_ID,
	LOGICAL_FLOW_NAME,
	-- LOGICAL_FLOW_DESCRIPTION,
	SECURE_FLOW_FLAG,
	VALIDATE_FLAG,
	APPLICATION_ID,
	FLOW_FINALIZER_CLASS,
	RETURN_TO_PAGE_ID,
	ENABLED_CLONE_FLAG,
	BASE_FLOW_FLAG,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
      select
	new_flow_id,
	o.LOGICAL_FLOW_HEAD_ID,
	o.LOGICAL_FLOW_NAME,
	-- o.LOGICAL_FLOW_DESCRIPTION,
	o.SECURE_FLOW_FLAG,
	o.VALIDATE_FLAG,
	o.APPLICATION_ID,
	o.FLOW_FINALIZER_CLASS,
	o.RETURN_TO_PAGE_ID,
	'F',
	'F',
	1,
	FND_GLOBAL.USER_ID,
	SYSDATE,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	FND_GLOBAL.CONC_LOGIN_ID
      from jtf_dpf_logical_flows_b o
	where o.logical_flow_id = p_flow_id;

    insert into jtf_dpf_logical_flows_tl(
	logical_flow_id,
	language,
	source_lang,
	logical_flow_description,
		-- OBJECT_VERSION_NUMBER,
		CREATED_BY,
		-- CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
    select
	new_flow_id,
	o.language,
	o.source_lang,
	o.logical_flow_description,
		-- 1,
		FND_GLOBAL.USER_ID,
		-- SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID
	from jtf_dpf_logical_flows_tl o
	where o.logical_flow_id = p_flow_id;

    -- insert N new rows into table jtf_dpf_lgcl_next_rules with
    -- flow_id = new_flow_id, one for each row that's currently present for
    -- p_flow_id

    insert into jtf_dpf_lgcl_next_rules(
	LOGICAL_NEXT_RULE_ID ,
	LOGICAL_PAGE_ID      ,
	LOGICAL_NEXT_PAGE_ID ,
	DEFAULT_NEXT_FLAG    ,
	RULE_EVAL_SEQ        ,
	LOGICAL_FLOW_ID      ,
	RULE_ID              ,
		OBJECT_VERSION_NUMBER,
		CREATED_BY           ,
		CREATION_DATE        ,
		LAST_UPDATE_DATE     ,
		LAST_UPDATED_BY      ,
		LAST_UPDATE_LOGIN)
      select
	  jtf_dpf_lgcl_nxt_rules_s.nextval,
	  o.LOGICAL_PAGE_ID      ,
	  o.LOGICAL_NEXT_PAGE_ID ,
	  o.DEFAULT_NEXT_FLAG    ,
	  o.RULE_EVAL_SEQ        ,
	  new_flow_id,
	  o.RULE_ID              ,
		1,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID
      from jtf_dpf_lgcl_next_rules o
	where o.logical_flow_id = p_flow_id;

    return 1;
  end;

  function flow_activate(p_flow_id number) return number is
    existential number;
    l_app_id number;
    l_flow_name jtf_dpf_logical_flows_b.logical_flow_name%type;
  begin
    select count(*) into existential
      from jtf_dpf_logical_flows_b
      where logical_flow_id = p_flow_id;

    if existential <> 1 then return 2; end if;

    select application_id, logical_flow_name
      into l_app_id, l_flow_name
      from jtf_dpf_logical_flows_b
      where logical_flow_id = p_flow_id;


    -- deactivate all flows with the same appid and name as this one
    update jtf_dpf_logical_flows_b
      set enabled_clone_flag = 'F',
		object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
      where application_id = l_app_id and logical_flow_name = l_flow_name;

    -- activate this one
    update jtf_dpf_logical_flows_b
      set enabled_clone_flag = 'T',
		object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
      where logical_flow_id = p_flow_id;

    return 1;
  end;

  -- logical editing procedures:
  -- removes any instances with logical_page_id from tables:
  -- - jtf_dpf_logical_pages
  -- - jtf_dpf_lgcl_next_rules
  -- - jtf_dpf_lgcl_phy_rules
  -- removes the logical from JTF_DPF_LOGICAL_PAGES.  Also removes
  -- any jtf_dpf_lgcl_phy_rules with the same logical_page_id
  procedure logical_delete(p_logical_page_id number) is
  begin
    delete from jtf_dpf_logical_pages_b
      where logical_page_id=p_logical_page_id;
    delete from jtf_dpf_logical_pages_tl
      where logical_page_id=p_logical_page_id;
    delete from jtf_dpf_lgcl_next_rules
      where logical_page_id=p_logical_page_id;
    delete from jtf_dpf_lgcl_phy_rules
      where logical_page_id=p_logical_page_id;
--    commit;
  end;

  function logical_update(p_logical_page_id number,
    upd logical_update_rec) return number is
      t_appid number;
      existential number;
  begin
    if upd.p_new_name is null or 0 = length(upd.p_new_name) then
      return 3;
    end if;

    -- if there's no such phyiscal_id, then return 4
    if fnd_api.g_miss_num <> upd.p_default_physical_id then
      select count(*) into existential
          from jtf_dpf_physical_pages_b
        where physical_page_id = upd.p_default_physical_id;

      if existential = 0 then return 4; end if;
    end if;

    select application_id into t_appid
      from fnd_application where application_short_name = upd.p_new_asn;

    -- is the proposed new name already taken?  count the number
    -- of rows which already have this name, but which have a different
    -- logical_flow_id
    select count(*) into existential
      from jtf_dpf_logical_pages_b
      where logical_page_id <> p_logical_page_id and
        logical_page_name = upd.p_new_name and
	application_id = t_appid;

    if existential > 0 then return 2; end if;

    update jtf_dpf_logical_pages_b set
	logical_page_name = upd.p_new_name,
	logical_page_type = upd.p_new_type,
	application_id = t_appid,
	-- logical_page_description = upd.p_new_descr,
	page_controller_class = upd.p_new_page_controller_class,
	page_permission_name = upd.p_new_page_permission_name,
		object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
      where logical_page_id = p_logical_page_id;

    if upd.p_new_descr is null or fnd_api.g_miss_char <> upd.p_new_descr then
      update jtf_dpf_logical_pages_tl set
	logical_page_description = upd.p_new_descr,
		-- object_version_number = OBJECT_VERSION_NUMBER+1,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		LAST_UPDATE_LOGIN =  FND_GLOBAL.CONC_LOGIN_ID
        where logical_page_id = p_logical_page_id and
	  language = userenv('LANG');
    end if;

    if fnd_api.g_miss_num <> upd.p_default_physical_id then
      delete from jtf_dpf_lgcl_phy_rules where
        default_page_flag = 'T' and
        logical_page_id = p_logical_page_id;

      insert into jtf_dpf_lgcl_phy_rules (
	logical_physical_id,
	logical_page_id,
	default_page_flag,
	physical_page_id,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
      values (
	jtf_dpf_lgcl_phy_rules_s.nextval,
	p_logical_page_id,
	'T',
	upd.p_default_physical_id,
		1,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID);

    end if;
--    commit;
    return 1;
  end;

  function logical_new(
    p_new_asn varchar2,
    p_new_name varchar2,
    p_new_type varchar2,
    p_new_descr varchar2,
    p_new_page_controller_class varchar2,
    p_new_page_permission_name varchar2,
    p_default_physical_id JTF_DPF_PHYSICAL_PAGES_B.PHYSICAL_PAGE_ID%type)
    return number is
      t_appid number;
      t_new_logical_page_id number;
      t_rowid rowid;
      existential number;
  begin
    if p_new_name is null or 0 = length(p_new_name) then return 3; end if;

    -- if there's no such phyiscal_id, then return 4
    select count(*) into existential
        from jtf_dpf_physical_pages_b
      where physical_page_id = p_default_physical_id;

    if existential = 0 then return 4; end if;

    select application_id into t_appid
      from fnd_application where application_short_name = p_new_asn;

    -- if a logical with this name and appid already exist, then return 2
    select count(*) into existential
      from jtf_dpf_logical_pages_b
      where application_id = t_appid and
	logical_page_name = p_new_name;

    if existential <> 0 then return 2; end if;

    select jtf_dpf_logical_pages_s.nextval into t_new_logical_page_id
      from dual;

    JTF_DPF_LOGICAL_PAGES_PKG.INSERT_ROW(
      X_ROWID                      => t_rowid,
      X_LOGICAL_PAGE_ID            => t_new_logical_page_id,
      X_LOGICAL_PAGE_NAME          => p_new_name,
      X_LOGICAL_PAGE_TYPE          => p_new_type,
      X_APPLICATION_ID             => t_appid,
      X_ENABLED_FLAG               => 'T',
      X_PAGE_CONTROLLER_CLASS      => p_new_page_controller_class,
      X_PAGE_PERMISSION_NAME       =>  p_new_page_permission_name,
      X_OBJECT_VERSION_NUMBER      => 1,
      X_LOGICAL_PAGE_DESCRIPTION   => p_new_descr,
      X_CREATION_DATE              => SYSDATE,
      X_CREATED_BY                 => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_DATE           => SYSDATE,
      X_LAST_UPDATED_BY            => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_LOGIN          =>  FND_GLOBAL.CONC_LOGIN_ID);

--    insert into jtf_dpf_logical_pages_b(
--	enabled_flag,
--	logical_page_id,
--	logical_page_name,
--	logical_page_type,
--	application_id,
--	-- logical_page_description,
--	page_controller_class,
--	page_permission_name,
--		OBJECT_VERSION_NUMBER,
--		CREATED_BY,
--		CREATION_DATE,
--		LAST_UPDATE_DATE,
--		LAST_UPDATED_BY,
--		LAST_UPDATE_LOGIN)
--    values (
--	'T',
--	jtf_dpf_logical_pages_s.nextval,
--	p_new_name,
--	p_new_type,
--	t_appid,
--	-- p_new_descr,
--	p_new_page_controller_class,
--	p_new_page_permission_name,
--		1,
--		FND_GLOBAL.USER_ID,
--		SYSDATE,
--		SYSDATE,
--		FND_GLOBAL.USER_ID,
--		FND_GLOBAL.CONC_LOGIN_ID)
--    returning logical_page_id into t_new_logical_page_id;
--
--    insert into jtf_dpf_logical_pages_tl(
--	logical_page_id,
--	language,
--	source_lang,
--	logical_page_description,
--		OBJECT_VERSION_NUMBER,
--		CREATED_BY,
--		CREATION_DATE,
--		LAST_UPDATE_DATE,
--		LAST_UPDATED_BY,
--		LAST_UPDATE_LOGIN)
--      values (
--	t_new_logical_page_id,
--	userenv('LANG'),
--	userenv('LANG'),
--	p_new_descr,
--		1,
--		FND_GLOBAL.USER_ID,
--		SYSDATE,
--		SYSDATE,
--		FND_GLOBAL.USER_ID,
--		FND_GLOBAL.CONC_LOGIN_ID);

    insert into jtf_dpf_lgcl_phy_rules (
	logical_physical_id,
	logical_page_id,
	default_page_flag,
	physical_page_id,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
    values (
	jtf_dpf_lgcl_phy_rules_s.nextval,
	t_new_logical_page_id,
	'T',
	p_default_physical_id,
		1,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID);

--    commit;
    return 1;
  end;

  -- updates table JTF_DPF_LGCL_PHY_RULES, so that the default_next_flag='F'
  -- rows which it contains for this logical_page_id are the rules and
  -- results specified by p_new_ones.  It first throws out any old
  -- rows in the table.
  --
  -- This has the effect of removing the non-default rules if p_new_ones
  -- is either null or empty
  procedure logical_set_non_default_phys(p_logical_page_id number,
    p_new_ones new_phys_non_def_tbl) is
    idx binary_integer;
  begin
    delete from jtf_dpf_lgcl_phy_rules where
      logical_page_id = p_logical_page_id and
      default_page_flag='F';

    if p_new_ones is not null and p_new_ones.count <> 0 then
      idx := p_new_ones.first;
      while true loop
        insert into jtf_dpf_lgcl_phy_rules (
	  logical_physical_id,
	  logical_page_id,
	  default_page_flag,
	  rule_eval_sequence,
	  physical_page_id,
	  rule_id,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
        values(
	  jtf_dpf_lgcl_phy_rules_s.nextval,
	  p_logical_page_id,
	  'F',
	  idx,
          p_new_ones(idx).physical_page_id,
          p_new_ones(idx).rule_id,
		1,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID);

        if idx = p_new_ones.last then exit; end if;
        idx := p_new_ones.next(idx);
      end loop;
    end if;
--    commit;
  end;

  -- set next_logicals
  -- sets the default next logical of (flow_id, log_page_id) to
  -- next_log_page_id.  This might either update an existing
  -- row in JTF_DPF_LGCL_NEXT_RULES or insert a new one
  -- if the new 'next' is null, it means there is no more next_logical
  -- for the given one.
  function next_logical_set_default(
    p_flow_id jtf_dpf_lgcl_next_rules.logical_flow_id%type,
    p_log_page_id jtf_dpf_lgcl_next_rules.logical_page_id%type,
    p_next_log_page_id jtf_dpf_lgcl_next_rules.logical_next_page_id%type)
      return number is
    existential number;
  begin

    -- see if this is an error case; return '2' if either p_log_page_id
    -- isn't there, or if p_next_log_page_id is both not null and not there
    select count(*) into existential
      from jtf_dpf_logical_pages_b
      where logical_page_id = p_log_page_id;

    if existential = 0 then return 2; end if;

    if p_next_log_page_id is not null then
      select count(*) into existential
        from jtf_dpf_logical_pages_b
        where logical_page_id = p_next_log_page_id;

      if existential = 0 then return 2; end if;
    end if;

    -- not the error case! just do the update, then...
    if p_next_log_page_id is null then
      delete from jtf_dpf_lgcl_next_rules
        where logical_page_id = p_log_page_id and
          logical_flow_id = p_flow_id;
    else
      delete from jtf_dpf_lgcl_next_rules
        where default_next_flag = 'T' and
	  logical_page_id = p_log_page_id and
	  logical_flow_id = p_flow_id;
      insert into jtf_dpf_lgcl_next_rules (
	  logical_next_rule_id,
	  logical_page_id,
	  logical_next_page_id,
	  default_next_flag,
	  logical_flow_id,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
      values (
	  jtf_dpf_lgcl_nxt_rules_s.nextval,
	  p_log_page_id,
	  p_next_log_page_id,
	  'T',
	  p_flow_id,
		1,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID);

    end if;
--    commit;
    return 1;
  end;

  -- sets up the non-default next logical rules for (flow_id, log_page_id).
  -- if there were already non-default rules for it, it removes them first
  procedure next_logical_set_non_default(
    p_flow_id jtf_dpf_lgcl_next_rules.logical_flow_id%type,
    p_log_page_id jtf_dpf_lgcl_next_rules.logical_page_id%type,
    p_new_ones new_next_log_non_def_tbl) is
    idx binary_integer;
  begin
    delete from jtf_dpf_lgcl_next_rules
      where default_next_flag = 'F' and
        logical_page_id = p_log_page_id and
	logical_flow_id = p_flow_id;

    if p_new_ones is not null and p_new_ones.count <> 0 then
      idx := p_new_ones.first;
      while true loop
        insert into jtf_dpf_lgcl_next_rules(
	  logical_next_rule_id,
	  logical_page_id,
	  logical_next_page_id,
	  default_next_flag,
	  rule_eval_seq,
	  logical_flow_id,
	  rule_id,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
	values (
	  jtf_dpf_lgcl_nxt_rules_s.nextval,
	  p_log_page_id,
	  p_new_ones(idx).logical_page_id,
	  'F',
	  idx,
	  p_flow_id,
	  p_new_ones(idx).rule_id,
		1,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID);

        if idx = p_new_ones.last then exit; end if;
        idx := p_new_ones.next(idx);
      end loop;
    end if;
--    commit;
  end;
end;

/
