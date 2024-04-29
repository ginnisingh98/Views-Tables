--------------------------------------------------------
--  DDL for Package Body QPR_POLICY_EVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_POLICY_EVAL" AS
/* $Header: QPRUPOLB.pls 120.4 2008/01/04 13:29:46 bhuchand noship $ */

procedure log_debug(text varchar2) is
begin
	fnd_file.put_line( fnd_file.log, text);
end;

procedure get_policy_details(
                            i_instance_id in number,
                            i_psg_id in number,
                            i_policy_id in number,
                            i_time_level_value in date,
                            i_vlb_level_value in varchar2,
                            i_policy_meas_type in varchar2,
                            i_policy_type in varchar2 default null,
                            o_policy_det out nocopy policy_det_rec_type) is
l_policy_id number;
l_ctr number := 0;
l_prev_pol_type qpr_policy_lines.POLICY_TYPE_CODE%type := '';
l_prev_pol_meas qpr_policy_lines.POLICY_MEASURE_TYPE_CODE%type := '';

cursor c_pol(p_policy_id number) is
    select policy_line_id, policy_id,
    policy_type_code, policy_measure_type_code,
    limit_value_type_code, ref_limit_value,
    effective_date_from, effective_date_to
    from qpr_policy_lines
    where policy_id = p_policy_id
    and policy_measure_type_code = nvl(i_policy_meas_type,
                                  policy_measure_type_code)
    and policy_type_code = nvl(i_policy_type, policy_type_code)
    and i_time_level_value between
        nvl(effective_date_from, i_time_level_value)
    and nvl(effective_date_to, i_time_level_value)
    and (vlb_level_value is null or
    vlb_level_value = i_vlb_level_value)
    order by policy_measure_type_code, policy_type_code, vlb_level_value;
begin

  if i_policy_id is null then
    if i_psg_id = qpr_sr_util.get_null_pk then
      l_policy_id := fnd_profile.value('QPR_DEFAULT_POLICY');
    else
      select DEFAULT_POLICY_ID into l_policy_id
      from qpr_pr_segments_b
      where PR_SEGMENT_ID = i_psg_id;
    end if;
  else
    l_policy_id := i_policy_id;
  end if;

  -- for a given policy_type_code, policy_measure_type_code
  -- and date there can be 2 policies one with vlb and
  -- another w/o vlb. Loop thro to fetch appr. values
  -- cursor ordered by policy_measure_type_code, policy_type and vlb_level_val
  -- So in a given policy_type_code, measure_type record with vlb will be first
  -- if one is found- otherwise we take null record.

  for r_pol in c_pol(l_policy_id) loop
    if (nvl(l_prev_pol_type, '*') <> r_pol.POLICY_TYPE_CODE or
       nvl(l_prev_pol_meas, '*') <> r_pol.POLICY_MEASURE_TYPE_CODE) then
      if o_policy_det is null then
        o_policy_det := policy_det_rec_type();
      end if;
      o_policy_det.extend;
      l_ctr := l_ctr + 1;
      o_policy_det(l_ctr).POLICY_LINE_ID := r_pol.POLICY_LINE_ID;
      o_policy_det(l_ctr).POLICY_ID := r_pol.POLICY_ID;
      o_policy_det(l_ctr).POLICY_TYPE_CODE := r_pol.POLICY_TYPE_CODE;
      o_policy_det(l_ctr).POLICY_MEASURE_TYPE_CODE :=
                                        r_pol.POLICY_MEASURE_TYPE_CODE;
      o_policy_det(l_ctr).LIMIT_VALUE_TYPE_CODE := r_pol.LIMIT_VALUE_TYPE_CODE;
      o_policy_det(l_ctr).REF_LIMIT_VALUE := r_pol.REF_LIMIT_VALUE;
      o_policy_det(l_ctr).EFFECTIVE_DATE_FROM := r_pol.EFFECTIVE_DATE_FROM;
      o_policy_det(l_ctr).EFFECTIVE_DATE_TO := r_pol.EFFECTIVE_DATE_TO;

      l_prev_pol_type := r_pol.POLICY_TYPE_CODE;
      l_prev_pol_meas := r_pol.POLICY_MEASURE_TYPE_CODE;
    end if;
  end loop;
exception
  when NO_DATA_FOUND then
    o_policy_det := null;
end get_policy_details;

procedure get_pricing_segment_id(
                            i_instance_id in number,
                            i_ord_level_value in varchar2,
                            i_time_level_value in date,
                            i_prd_level_value in varchar2,
                            i_geo_level_value in varchar2,
                            i_cus_level_value in varchar2,
                            i_org_level_value in varchar2,
                            i_rep_level_value in varchar2,
                            i_chn_level_value in varchar2,
                            i_vlb_level_value in varchar2,
                            o_pr_segment_id out nocopy number,
                            o_pol_importance_code out nocopy varchar2) is

begin
  select p.pr_segment_id, p.policy_importance_code
  into o_pr_segment_id, o_pol_importance_code
  from
      (select default_policy_id, pr_segment_id, policy_importance_code
       from qpr_pr_segments_b
       where (pr_segment_id in (
              select a.parent_id
              from qpr_scopes a,
                (select s.parent_id, s.dim_code
                from qpr_dimension_values dv,qpr_scopes s,
                qpr_hierarchies h, qpr_hier_levels l,
                qpr_pr_segments_b psg
                where  s.parent_entity_type = 'PRICINGSEGMENT'
                and s.parent_id = psg.pr_segment_id
                and psg.instance_id = i_instance_id
                and s.DIM_CODE = dv.DIM_CODE
                and s.HIERARCHY_ID = h.HIERARCHY_ID
                and s.LEVEL_ID = L.HIERARCHY_LEVEL_ID
                and h.HIERARCHY_PPA_CODE = dv.HIERARCHY_CODE
                and s.SCOPE_VALUE = decode(l.LEVEL_SEQ_NUM,
                                            1, dv.LEVEL1_VALUE,
                                            2, dv.LEVEL2_VALUE,
                                            3, dv.LEVEL3_VALUE,
                                            4, dv.LEVEL4_VALUE,
                                            5, dv.LEVEL5_VALUE,
                                            6, dv.LEVEL6_VALUE,
                                            7, dv.LEVEL7_VALUE,
                                            8, dv.LEVEL8_VALUE)
                and dv.LEVEL1_VALUE = decode(s.DIM_CODE,
                                        'PRD',nvl(i_prd_level_value, '*') ,
                                        'CUS', nvl(i_cus_level_value, '*'),
                                        'ORD', nvl(i_ord_level_value, '*'),
                                        'GEO', nvl(i_geo_level_value,'*'),
                                        'ORG',nvl(i_org_level_value, '*') ,
                                        'REP',nvl(i_rep_level_value,'*') ,
                                        'CHN',nvl(i_chn_level_value, '*') )
                and dv.INSTANCE_ID = i_instance_id) b
            where a.parent_id = b.parent_id(+)
            and a.dim_code = b.dim_code(+)
            and a.parent_entity_type = 'PRICINGSEGMENT'
            group by a.parent_id
            having count(distinct a.dim_code) = count(distinct b.dim_code)
            )
       or pr_segment_id not in (select distinct parent_id from qpr_scopes
          where parent_entity_type = 'PRICINGSEGMENT'))
       and instance_id = i_instance_id
       order by policy_precedence
    ) p
  where rownum < 2;

exception
  when NO_DATA_FOUND then
    o_pr_segment_id := qpr_sr_util.get_null_pk;
    o_pol_importance_code := null;
  when OTHERS then
    o_pr_segment_id := null;
    o_pol_importance_code := null;
end get_pricing_segment_id;


procedure copy_policy(p_policy_id in number,
                      p_new_policy_name in out nocopy varchar2,
                      p_new_pol_id out nocopy number,
                      retcode out nocopy number,
                      errbuf out nocopy varchar2) is

l_new_pol_id qpr_policies_b.POLICY_ID%type;
l_active_flag qpr_policies_b.ACTIVE_FLAG%type;
l_pol_name qpr_policies_tl.NAME%type;

cursor c_pol_tl is
  select language,source_lang, name, description
  from qpr_policies_tl
  where policy_id = p_policy_id;

cursor c_pol_line is
  select policy_type_code,policy_measure_type_code,
  limit_value_type_code,ref_limit_value,
  effective_date_from,effective_date_to,
  vlb_level_value,vlb_level_value_desc
  from qpr_policy_lines
  where policy_id = p_policy_id;

begin

  select active_flag into l_active_flag
  from qpr_policies_b
  where policy_id = p_policy_id
  and rownum < 2;

  insert into qpr_policies_b(policy_id,
                            active_flag,
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by,
                            last_update_login)
  values(qpr_policies_s.nextval, 'N',
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id)
  returning POLICY_ID into l_new_pol_id;

  for rec_pol in c_pol_tl loop
    if p_new_policy_name is not null then
      l_pol_name := p_new_policy_name;
    else
      fnd_message.set_name('QPR', 'QPR_COPY_OF');
      fnd_message.set_token('OBJECT_NAME', rec_pol.name);
      l_pol_name := fnd_message.get;
    end if;

    insert into qpr_policies_tl(policy_id,
                                language,
                                source_lang,
                                name,
                                description,
                                creation_date,
                                created_by,
                                last_update_date,
                                last_updated_by,
                                last_update_login)
     values(l_new_pol_id,
            rec_pol.language,
            rec_pol.source_lang,
            l_pol_name,
            rec_pol.description,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id);
  end loop;

  for rec_line in c_pol_line loop
    insert into qpr_policy_lines(policy_line_id,
                                 policy_id,
                                 policy_type_code,
                                 policy_measure_type_code,
                                 limit_value_type_code,
                                 ref_limit_value,
                                 effective_date_from,
                                 effective_date_to,
                                 vlb_level_value,
                                 vlb_level_value_desc,
                                creation_date,
                                created_by,
                                last_update_date,
                                last_updated_by,
                                last_update_login)
    values(qpr_policy_lines_s.nextval,
           l_new_pol_id,
           rec_line.policy_type_code,
           rec_line.policy_measure_type_code,
           rec_line.limit_value_type_code,
           rec_line.ref_limit_value,
           rec_line.effective_date_from,
           rec_line.effective_date_to,
           rec_line.vlb_level_value,
           rec_line.vlb_level_value_desc,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id);
  end loop;

  p_new_pol_id := l_new_pol_id;
  p_new_policy_name := l_pol_name;

exception
  when others then
    retcode := 2;
    errbuf := sqlerrm;
    p_new_pol_id := null;
end copy_policy;


procedure process(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id 	  number,
			p_from_date 	varchar2,
			p_to_date	varchar2) is

c_meas_data_rec measure_rec_type;
c_policy_data_rec policy_rec_type;
date_from date := FND_DATE.canonical_to_date(p_from_date);
date_to date := FND_DATE.canonical_to_date(p_to_date);
l_rows natural :=1000;
l_policy_counter number:=1;
l_policy_value qpr_measure_data.measure1_number%TYPE;
I number;
l_pric_at_pol_limit number;
l_med_sev_thre number;
l_high_sev_thre number;
l_sev_thre_perc number;

cursor c_measures is
SELECT
instance_id,
ord_level_value, prd_level_value, geo_level_value, cus_level_value,
org_level_value, rep_level_value, chn_level_value, vlb_level_value,
dsb_level_value, time_level_value,
(measure1_number*measure3_number - measure2_number),
measure13_number, measure3_number, measure1_number, measure2_number
FROM qpr_measure_data
WHERE instance_id = p_instance_id
and measure_type_code = 'SALESDATA'
and time_level_value between date_from and date_to;


l_pr_segment_id number;
t_pol_det_rec POLICY_DET_REC_TYPE;

l_policy_id number;
l_limit_value_type_code varchar2(30);
l_ref_limit_value number;
l_importance_rank qpr_pr_segments_b.policy_importance_code%TYPE;


procedure insert_pol_measures is
begin
  log_debug('Policy eval count'|| c_policy_data_rec.ord_sr_level_value_pk.count);
  if c_policy_data_rec.ord_sr_level_value_pk.count>0 then
    begin
      log_debug('Policy eval deleting');
      forall I in 1..c_policy_data_rec.ord_sr_level_value_pk.count
        delete qpr_measure_data
        where instance_id=p_instance_id
        and measure_type_code = decode(c_policy_data_rec.policy_type_code(I),
				'CEILING', 'QPR_CEILING_POLICY_MEASURES',
				'CORPORATE', 'QPR_CORPORATE_POLICY_MEASURES',
				'FIELD', 'QPR_FIELD_USER_POLICY_MEASURES',
				'GSA', 'QPR_GSA_POLICY_MEASURES',
				'REGIONAL', 'QPR_REGIONAL_POLICY_MEASURES',
				'TARGET', 'QPR_TARGET_POLICY_MEASURES')
        and ord_level_value=c_policy_data_rec.ord_sr_level_value_pk(I);
        log_debug('Deleted '|| sql%rowcount ||' records');
    exception
      when others then
	  log_debug('RETCODE = ' || RETCODE);
      null;
    end;
    begin
      log_debug('Policy eval inserting');
      forall I in 1..c_policy_data_rec.ord_sr_level_value_pk.count
        insert into QPR_MEASURE_DATA(
        MEASURE_VALUE_ID,
        MEASURE_TYPE_CODE,
        INSTANCE_ID,
        ORD_LEVEL_VALUE,
        PRD_LEVEL_VALUE,
        GEO_LEVEL_VALUE,
        CUS_LEVEL_VALUE,
        ORG_LEVEL_VALUE,
        REP_LEVEL_VALUE,
        CHN_LEVEL_VALUE,
        VLB_LEVEL_VALUE,
        DSB_LEVEL_VALUE,
        TIME_LEVEL_VALUE,
        MEASURE1_NUMBER ,
        MEASURE2_NUMBER ,
        MEASURE3_NUMBER ,
        MEASURE4_NUMBER ,
        MEASURE5_NUMBER ,
        MEASURE6_NUMBER ,
        MEASURE7_NUMBER ,
        MEASURE8_NUMBER ,
        MEASURE9_NUMBER ,
        MEASURE10_NUMBER ,
        MEASURE11_NUMBER ,
        MEASURE12_NUMBER ,
        MEASURE13_NUMBER ,
        CREATION_DATE ,
        CREATED_BY ,
        LAST_UPDATE_DATE ,
        LAST_UPDATED_BY ,
        LAST_UPDATE_LOGIN ,
        REQUEST_ID) values
        (QPR_MEASURE_DATA_S.nextval,
        decode(c_policy_data_rec.policy_type_code(I),
		'CEILING', 'QPR_CEILING_POLICY_MEASURES',
		'CORPORATE', 'QPR_CORPORATE_POLICY_MEASURES',
		'FIELD', 'QPR_FIELD_USER_POLICY_MEASURES',
		'GSA', 'QPR_GSA_POLICY_MEASURES',
		'REGIONAL', 'QPR_REGIONAL_POLICY_MEASURES',
		'TARGET', 'QPR_TARGET_POLICY_MEASURES',
		null),
        c_policy_data_rec.instance(I),
        c_policy_data_rec.ord_sr_level_value_pk(I),
        c_policy_data_rec.prd_sr_level_value_pk(I),
        c_policy_data_rec.geo_sr_level_value_pk(I),
        c_policy_data_rec.cus_sr_level_value_pk(I),
        c_policy_data_rec.org_sr_level_value_pk(I),
        c_policy_data_rec.rep_sr_level_value_pk(I),
        c_policy_data_rec.chn_sr_level_value_pk(I),
        c_policy_data_rec.vlb_sr_level_value_pk(I),
        c_policy_data_rec.dsb_sr_level_value_pk(I),
        c_policy_data_rec.tim_sr_level_value_pk(I),
        c_policy_data_rec.rev_at_pol_limit(I),
        c_policy_data_rec.pass_exceptions(I),
        c_policy_data_rec.fail_exceptions(I),
        c_policy_data_rec.na_exceptions(I),
        c_policy_data_rec.gross_rev_comp(I),
        c_policy_data_rec.gross_rev_non_comp(I),
        c_policy_data_rec.hi_sever_thre(I),
        c_policy_data_rec.me_sever_thre(I),
        c_policy_data_rec.lo_sever_thre(I),
        c_policy_data_rec.hi_pol_imp_rank(I),
        c_policy_data_rec.me_pol_imp_rank(I),
        c_policy_data_rec.lo_pol_imp_rank(I),
        c_policy_data_rec.rev_at_lis_price(I),
        sysdate,
        FND_GLOBAL.USER_ID,
        sysdate,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.LOGIN_ID,
        FND_GLOBAL.CONC_REQUEST_ID);
      log_debug('Inserted '|| sql%rowcount ||' records');
    exception
      when others then
        errbuf := substr(SQLERRM,1,150);
        retcode := -1;
        log_debug(substr(SQLERRM, 1, 1000));
    end;
    commit;
  end if; --c.policy_data.rec.ord_sr_level_value_pk.count>0 then
end; --procedure insert_pol_measures

procedure clean_meas_data is
begin
c_meas_data_rec.instance.delete;
c_meas_data_rec.prd_sr_level_value_pk.delete;
c_meas_data_rec.geo_sr_level_value_pk.delete;
c_meas_data_rec.cus_sr_level_value_pk.delete;
c_meas_data_rec.ord_sr_level_value_pk.delete;
c_meas_data_rec.org_sr_level_value_pk.delete;
c_meas_data_rec.chn_sr_level_value_pk.delete;
c_meas_data_rec.rep_sr_level_value_pk.delete;
c_meas_data_rec.tim_sr_level_value_pk.delete;
c_meas_data_rec.vlb_sr_level_value_pk.delete;
c_meas_data_rec.dsb_sr_level_value_pk.delete;
c_meas_data_rec.DISC_AMOUNT.delete;
c_meas_data_rec.DISC_PERC.delete;
c_meas_data_rec.LIST_PRICE.delete;
c_meas_data_rec.QUANTITY.delete;
c_meas_data_rec.GROSS_REVENUE.delete;
end clean_meas_data;

procedure clean_policy_data is
begin
c_policy_data_rec.instance.delete;
c_policy_data_rec.prd_sr_level_value_pk.delete;
c_policy_data_rec.geo_sr_level_value_pk.delete;
c_policy_data_rec.cus_sr_level_value_pk.delete;
c_policy_data_rec.ord_sr_level_value_pk.delete;
c_policy_data_rec.org_sr_level_value_pk.delete;
c_policy_data_rec.chn_sr_level_value_pk.delete;
c_policy_data_rec.rep_sr_level_value_pk.delete;
c_policy_data_rec.tim_sr_level_value_pk.delete;
c_policy_data_rec.vlb_sr_level_value_pk.delete;
c_policy_data_rec.dsb_sr_level_value_pk.delete;
c_policy_data_rec.rev_at_pol_limit.delete;
c_policy_data_rec.pass_exceptions.delete;
c_policy_data_rec.fail_exceptions.delete;
c_policy_data_rec.na_exceptions.delete;
c_policy_data_rec.gross_rev_comp.delete;
c_policy_data_rec.gross_rev_non_comp.delete;
c_policy_data_rec.hi_sever_thre.delete;
c_policy_data_rec.me_sever_thre.delete;
c_policy_data_rec.lo_sever_thre.delete;
c_policy_data_rec.hi_pol_imp_rank.delete;
c_policy_data_rec.me_pol_imp_rank.delete;
c_policy_data_rec.lo_pol_imp_rank.delete;
c_policy_data_rec.rev_at_lis_price.delete;
end clean_policy_data;

begin
  log_debug('Start.. ');
  l_med_sev_thre := to_number(nvl(qpr_sr_util.read_parameter(
                                            'QPR_DEVIATION_SEVERE_MED'),0));
  l_high_sev_thre := to_number(nvl(qpr_sr_util.read_parameter(
                                            'QPR_DEVIATION_SEVERE_HIGH'),0));
  open c_measures;
  loop
    clean_meas_data;
    l_policy_counter:=0;
    fetch c_measures bulk collect into
          c_meas_data_rec.instance,
          c_meas_data_rec.ord_sr_level_value_pk,
          c_meas_data_rec.prd_sr_level_value_pk,
          c_meas_data_rec.geo_sr_level_value_pk,
          c_meas_data_rec.cus_sr_level_value_pk,
          c_meas_data_rec.org_sr_level_value_pk,
          c_meas_data_rec.rep_sr_level_value_pk,
          c_meas_data_rec.chn_sr_level_value_pk,
          c_meas_data_rec.vlb_sr_level_value_pk,
          c_meas_data_rec.dsb_sr_level_value_pk,
          c_meas_data_rec.tim_sr_level_value_pk,
          c_meas_data_rec.DISC_AMOUNT,
          c_meas_data_rec.DISC_PERC,
          c_meas_data_rec.LIST_PRICE,
          c_meas_data_rec.QUANTITY,
          c_meas_data_rec.GROSS_REVENUE
    limit l_rows;
    exit when c_meas_data_rec.ord_sr_level_value_pk.count = 0;

--    log_debug('Populated arrays');
    for I in 1..c_meas_data_rec.ord_sr_level_value_pk.count  loop
      get_pricing_segment_id(
	    p_instance_id,
            c_meas_data_rec.ord_sr_level_value_pk(i),
            c_meas_data_rec.tim_sr_level_value_pk(i),
            c_meas_data_rec.prd_sr_level_value_pk(i),
            c_meas_data_rec.geo_sr_level_value_pk(i),
            c_meas_data_rec.cus_sr_level_value_pk(i),
            c_meas_data_rec.org_sr_level_value_pk(i),
            c_meas_data_rec.rep_sr_level_value_pk(i),
            c_meas_data_rec.chn_sr_level_value_pk(i),
            c_meas_data_rec.vlb_sr_level_value_pk(i),
	    l_pr_segment_id,
            l_importance_rank);

      get_policy_details(
	    p_instance_id,
	    l_pr_segment_id,
	    null,
            c_meas_data_rec.tim_sr_level_value_pk(i),
            c_meas_data_rec.vlb_sr_level_value_pk(i),
            'ONINVOICE',
	    null,
            t_pol_det_rec);

     if l_pr_segment_id is not null then
     for J in 1..t_pol_det_rec.count loop
      l_policy_counter:=l_policy_counter+1;

      l_policy_id := t_pol_det_rec(J).policy_id;
      l_ref_limit_value := t_pol_det_rec(J).ref_limit_value;
      l_limit_value_type_code := t_pol_det_rec(J).limit_value_type_code;

      log_debug('Policy counter:'||l_policy_counter);
      log_debug('Policy..'|| c_meas_data_rec.ord_sr_level_value_pk(I)||' - '||l_policy_id);
      log_debug('Limit value Type..'|| l_limit_value_type_code);

      c_policy_data_rec.instance(l_policy_counter) :=
                                                  c_meas_data_rec.instance(I);
      c_policy_data_rec.ord_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.ord_sr_level_value_pk(I);
      c_policy_data_rec.prd_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.prd_sr_level_value_pk(I);
      c_policy_data_rec.geo_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.geo_sr_level_value_pk(I);
      c_policy_data_rec.cus_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.cus_sr_level_value_pk(I);
      c_policy_data_rec.org_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.org_sr_level_value_pk(I);
      c_policy_data_rec.rep_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.rep_sr_level_value_pk(I);
      c_policy_data_rec.chn_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.chn_sr_level_value_pk(I);
      c_policy_data_rec.vlb_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.vlb_sr_level_value_pk(I);
      c_policy_data_rec.dsb_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.dsb_sr_level_value_pk(I);
      c_policy_data_rec.tim_sr_level_value_pk(l_policy_counter) :=
                                      c_meas_data_rec.tim_sr_level_value_pk(I);

      c_policy_data_rec.policy_type_code(l_policy_counter) := t_pol_det_rec(J).policy_type_code;

      if l_policy_id is null or c_meas_data_rec.list_price(I) = 0 then
        log_debug('Policy is null ');
        c_policy_data_rec.pass_exceptions(l_policy_counter):=0;
        c_policy_data_rec.fail_exceptions(l_policy_counter):=0;
        c_policy_data_rec.na_exceptions(l_policy_counter):=1;
        c_policy_data_rec.hi_sever_thre(l_policy_counter):=0;
        c_policy_data_rec.me_sever_thre(l_policy_counter):=0;
        c_policy_data_rec.lo_sever_thre(l_policy_counter):=0;
        c_policy_data_rec.hi_pol_imp_rank(l_policy_counter):=0;
        c_policy_data_rec.me_pol_imp_rank(l_policy_counter):=0;
        c_policy_data_rec.lo_pol_imp_rank(l_policy_counter):=0;
        c_policy_data_rec.gross_rev_comp(l_policy_counter):=
                                  c_meas_data_rec.gross_revenue(I);
        c_policy_data_rec.gross_rev_non_comp(l_policy_counter):=0;
        c_policy_data_rec.rev_at_lis_price(l_policy_counter):=0;
        c_policy_data_rec.rev_at_pol_limit(l_policy_counter):=0;
      else
        if l_limit_value_type_code = 'AMOUNT' then
          log_debug('Policy limit type is amount ');
          l_policy_value := nvl(c_meas_data_rec.disc_amount(I),0);
          l_pric_at_pol_limit := c_meas_data_rec.list_price(I)-
                                                     nvl(l_ref_limit_value, 0);
        else
          log_debug('Policy limit type is percent ');
          l_policy_value := nvl(c_meas_data_rec.disc_perc(I),0);
          l_pric_at_pol_limit := c_meas_data_rec.list_price(I)-
                                  (c_meas_data_rec.list_price(I) *
                                               nvl(l_ref_limit_value, 0)/100);
        end if;
        c_policy_data_rec.rev_at_lis_price(l_policy_counter):=
                                  c_meas_data_rec.quantity(I)*
                                           c_meas_data_rec.list_price(I);
        c_policy_data_rec.rev_at_pol_limit(l_policy_counter) :=
                              c_meas_data_rec.quantity(I)* l_pric_at_pol_limit;
        if l_policy_value <= l_ref_limit_value then
          log_debug('Policy pass ');
          c_policy_data_rec.pass_exceptions(l_policy_counter):=1;
          c_policy_data_rec.fail_exceptions(l_policy_counter):=0;
          c_policy_data_rec.na_exceptions(l_policy_counter):=0;
          c_policy_data_rec.hi_sever_thre(l_policy_counter):=0;
          c_policy_data_rec.me_sever_thre(l_policy_counter):=0;
          c_policy_data_rec.lo_sever_thre(l_policy_counter):=0;
          c_policy_data_rec.hi_pol_imp_rank(l_policy_counter):=0;
          c_policy_data_rec.me_pol_imp_rank(l_policy_counter):=0;
          c_policy_data_rec.lo_pol_imp_rank(l_policy_counter):=0;
          c_policy_data_rec.gross_rev_comp(l_policy_counter):=
                                              c_meas_data_rec.gross_revenue(I);
          c_policy_data_rec.gross_rev_non_comp(l_policy_counter):=0;
        else
          log_debug('Policy failed ');
          c_policy_data_rec.pass_exceptions(l_policy_counter):=0;
          c_policy_data_rec.fail_exceptions(l_policy_counter):=1;
          c_policy_data_rec.na_exceptions(l_policy_counter):=0;

          if l_ref_limit_value  >  0 then
            l_sev_thre_perc := 100 * (l_policy_value - l_ref_limit_value)/
                                                        l_ref_limit_value  ;
          else
          -- this case might not come if the exception is handled in UI
          -- this is for other source uploads only.
            l_sev_thre_perc := 100;
          end if;

          if l_sev_thre_perc <= l_med_sev_thre then
            c_policy_data_rec.hi_sever_thre(l_policy_counter):=0;
            c_policy_data_rec.me_sever_thre(l_policy_counter):=0;
            c_policy_data_rec.lo_sever_thre(l_policy_counter):=1;
          elsif l_sev_thre_perc <= l_high_sev_thre then
            c_policy_data_rec.hi_sever_thre(l_policy_counter):=0;
            c_policy_data_rec.me_sever_thre(l_policy_counter):=1;
            c_policy_data_rec.lo_sever_thre(l_policy_counter):=0;
          elsif l_sev_thre_perc > l_high_sev_thre then
            c_policy_data_rec.hi_sever_thre(l_policy_counter):=1;
            c_policy_data_rec.me_sever_thre(l_policy_counter):=0;
            c_policy_data_rec.lo_sever_thre(l_policy_counter):=0;
          end if; --medium,hi

          if l_importance_rank = 'LOW' then
            c_policy_data_rec.hi_pol_imp_rank(l_policy_counter):=0;
            c_policy_data_rec.me_pol_imp_rank(l_policy_counter):=0;
            c_policy_data_rec.lo_pol_imp_rank(l_policy_counter):=1;
          elsif l_importance_rank = 'MEDIUM' then
            c_policy_data_rec.hi_pol_imp_rank(l_policy_counter):=0;
            c_policy_data_rec.me_pol_imp_rank(l_policy_counter):=1;
            c_policy_data_rec.lo_pol_imp_rank(l_policy_counter):=0;
          elsif l_importance_rank = 'HIGH' then
            c_policy_data_rec.hi_pol_imp_rank(l_policy_counter):=1;
            c_policy_data_rec.me_pol_imp_rank(l_policy_counter):=0;
            c_policy_data_rec.lo_pol_imp_rank(l_policy_counter):=0;
          end if;
          c_policy_data_rec.gross_rev_non_comp(l_policy_counter):=
                                            c_meas_data_rec.gross_revenue(I);
          c_policy_data_rec.gross_rev_comp(l_policy_counter):=0;
        end if; --l_policy_value <= l_low_limit_value
      end if; --policy_id is null
      end loop; -- loop through t_pol_det_rec
      end if; -- l_pr_segment_id is not null
    end loop; --c_measure_data_rec
   if c_policy_data_rec.ord_sr_level_value_pk.count <> 0 then
    insert_pol_measures;
    clean_policy_data;
   end if; -- check for c_policy_data_rec.ord_sr_level_value_pk.count <> 0
    commit;
  end loop; --c_measures

  close c_measures;
exception
 WHEN NO_DATA_FOUND THEN
    retcode := 2;
    errbuf  := FND_MESSAGE.GET;
    log_debug('Unexpected error '||substr(sqlerrm,1200));
end;

end; --package

/
