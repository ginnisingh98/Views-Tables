--------------------------------------------------------
--  DDL for Package Body QPR_COPY_PRICE_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_COPY_PRICE_PLAN" AS
/* $Header: QPRUCPPB.pls 120.1 2007/11/06 11:15:29 bhuchand noship $ */

  NO_PPLAN_ID exception;
  NO_PPLAN_DATA exception;
  PRAGMA EXCEPTION_INIT(NO_PPLAN_DATA, -100);
  ERR_IN_DEFN exception;

  g_request_id number;
  g_src_pplan_id number := 0;
  g_new_pp_id number := 0;
  g_sys_date date;
  g_user_id number;
  g_login_id number;
  g_prg_appl_id number;
  g_prg_id number;
  g_copy_det_frm_tmpl varchar2(1);

  type char1_type is table of varchar2(1) index by PLS_INTEGER;
  type char30_type is table of varchar2(30) index by PLS_INTEGER;
  type char60_type is table of varchar2(50) index by PLS_INTEGER;
  type char240_type is table of varchar2(240) index by PLS_INTEGER;
  type char1000_type is table of varchar2(1000) index by PLS_INTEGER;
  type num_type is table of number index by PLS_INTEGER;
  type char_type is table of varchar2(50) index by varchar2(30);

  type val_out_type is record (ID num_type, PPA_CODE char60_type);

  type dim_rec_type is record(SRC_PRICE_PLAN_DIM_ID num_type,
                              TMPL_PRICE_PLAN_DIM_ID num_type,
                              DIM_CODE char60_type,
                              DIM_PPA_CODE char30_type,
                              DIM_SEQ_NUM num_type,
                              MAND_DIM_FLAG char1_type,
                              TIME_DIM_FLAG char1_type,
                              LOB_ENABLED_FLAG char1_type,
                              DIM_SHORT_NAME char30_type,
                              DIM_LONG_NAME char240_type,
                              DIM_PLURAL_NAME char240_type,
                              NATIVE_KEY_FLAG char1_type,
                              MEASURE_DIM_FLAG char1_type,
                              SPARSE_FLAG char1_type,
                              LOWEST_LVL char30_type,
                              LIST_PP_FLAG char1_type);

  type dim_attr_rec_type is record(DIM_ATTR_ID num_type,
                                   ATTR_PPA_CODE char30_type,
                                   ATTR_SHORT_NAME char30_type,
                                   ATTR_LONG_NAME char240_type,
                                   ATTR_PLURAL_NAME char240_type,
                                   ATTR_CLASSIFICATION char240_type,
                                   ATTR_DATA_TYPE char30_type,
                                   DEFAULT_ORDER_FLAG char1_type);

  type dim_hier_type is record(HIERARCHY_ID num_type,
                               HIERARCHY_PPA_CODE char30_type,
                               HIER_SHORT_NAME char30_type,
                               HIER_LONG_NAME char240_type,
                               HIER_PLURAL_NAME char240_type,
                               HIER_TYPE_CODE char30_type,
                               HIER_DEFAULT_ORDER char240_type,
                               DEFAULT_FLAG char1_type,
                               CALENDAR_CODE char30_type);

  type hier_lvl_type is record(HIERARCHY_LEVEL_ID num_type,
                               LEVEL_PPA_CODE char30_type,
                               LEVEL_SEQ_NUM num_type,
                               LVL_SHORT_NAME char30_type,
                               LVL_LONG_NAME char240_type,
                               LVL_PLURAL_NAME char240_type,
                               MAPPING_VIEW_NAME char30_type,
                               MAP_COLUMN char30_type,
                               USER_MAPPING_VIEW_NAME char30_type,
                               USER_MAP_COLUMN char30_type);

  type lvl_attr_type is record(LEVEL_ATTR_ID num_type,
                               HIERARCHY_LEVEL_ID num_type,
                               DIM_ATTR_ID num_type,
                               MAPPING_VIEW_NAME char30_type,
                               MAP_COLUMN char30_type,
                               USER_MAPPING_VIEW_NAME char30_type,
                               USER_MAP_COLUMN char30_type);

  type cub_rec_type is record(SRC_CUBE_ID num_type,
                              TMPL_CUBE_ID num_type,
                              CUBE_PPA_CODE char30_type,
                              CUBE_CODE char60_type,
                              CUBE_SHORT_NAME char30_type,
                              CUBE_LONG_NAME char240_type,
                              CUBE_PLURAL_NAME char240_type,
                              CUBE_AUTO_SOLVE_FLAG char1_type,
                              DEFAULT_DATA_TYPE char30_type,
                              PARTITION_HIER char30_type,
                              PARTITION_LEVEL char30_type,
                              SPARSE_TYPE_CODE char30_type,
                              USE_GLOBAL_INDEX_FLAG char1_type,
                              AGGMAP_NAME char30_type,
                              AGGMAP_CACHE_STORE char30_type,
                              AGGMAP_CACHE_NA char30_type);

  type cub_meas_type is record(MEASURE_ID num_type,
                               MEASURE_PPA_CODE char30_type,
                               MEAS_CREATION_SEQ_NUM num_type,
                               MEAS_SHORT_NAME char30_type,
                               MEAS_LONG_NAME char240_type,
                               MEAS_PLURAL_NAME char240_type,
                               MEAS_TYPE char30_type,
                               MEAS_DATA_TYPE char30_type,
                               MEAS_AUTO_SOLVE char30_type,
                               CAL_MEAS_EXPRESSION_TEXT char1000_type,
                               MAPPING_VIEW_NAME char30_type,
                               MAP_COLUMN char30_type,
                               USER_MAPPING_VIEW_NAME char30_type,
                               USER_MAP_COLUMN char30_type,
                               AGGMAP_NAME char30_type,
                               MEAS_FOLD_SHORT_NAME char30_type,
                               MEAS_FOLD_LONG_NAME char240_type,
                               MEAS_FOLD_PLURAL_NAME char240_type);

  type cub_dims_type is record(CUBE_DIM_ID num_type, PRICE_PLAN_DIM_ID num_type,
                               AGGMAP_NAME char30_type,
                               DIM_OPCODE char30_type, DIM_SEQ_NUM num_type,
                               MAPPING_VIEW_NAME char30_type,
                               MAP_COLUMN char30_type,
                               USER_MAPPING_VIEW_NAME char30_type,
                               USER_MAP_COLUMN char30_type,
                               SET_LEVEL_FLAG char1_type,
                               DIM_EXPRESSION char240_type,
                               DIM_EXPRESSION_TYPE char30_type,
                               WEIGHTED_MEASURE_FLAG char1_type,
                               WEIGHT_MEASURE_NAME char30_type,
                               WNAFILL char30_type,
                               DIVIDE_BY_ZERO_FLAG char1_type,
                               DECIMAL_OVERFLOW_FLAG char1_type,
                               NASKIP_FLAG char1_type);

  type cub_meas_aggr_type is record(MEASURE_ID num_type,
                                    CUBE_DIM_ID num_type,
                                    AGGMAP_NAME char30_type,
                                    AGGMAP_CACHE_STORE char30_type,
                                    AGGMAP_CACHE_NA char30_type,
                                    DIM_OPCODE char30_type,
                                    SET_LEVEL_FLAG char1_type,
                                    OVERRIDE_FLAG char1_type,
                                    DIM_EXPRESSION char240_type,
                                    DIM_EXPRESSION_TYPE char30_type,
                                    WEIGHTED_MEASURE_FLAG char1_type,
                                    WEIGHT_MEASURE_NAME char30_type,
                                    WNAFILL char30_type,
                                    DIVIDE_BY_ZERO_FLAG char1_type,
                                    DECIMAL_OVERFLOW_FLAG char1_type,
                                    NASKIP_FLAG char1_type);

  type cub_set_lvl_type is record(CUBE_DIM_ID num_type,
                                  MEASURE_ID num_type,
                                  LEVEL_SHORT_NAME char30_type,
                                  DIM_EXPRESSION_TYPE char30_type,
                                  AGGMAP_NAME char30_type,
                                  SET_LEVEL_FLAG char1_type);
-- The following are records that hold data for individual PP tables for given
-- src price plan id.
  r_dim_val dim_rec_type;
  r_dim_attr_val dim_attr_rec_type;
  r_dim_hier_val dim_hier_type;
  r_hier_lvl_val hier_lvl_type;
  r_lvl_attr_val lvl_attr_type;
  r_cub_val cub_rec_type;
  r_cub_meas_val cub_meas_type;
  r_cub_dims_val cub_dims_type;
  r_cub_meas_aggr cub_meas_aggr_type;
  r_cub_int_maggr cub_meas_aggr_type;
  r_cub_set_lvl cub_set_lvl_type;
  r_int_set_lvl cub_set_lvl_type;

function insert_dim_values return val_out_type is
  rec_dim_out val_out_type;
begin
  forall i in r_dim_val.SRC_PRICE_PLAN_DIM_ID.first..
                                    r_dim_val.SRC_PRICE_PLAN_DIM_ID.last
    insert into qpr_dimensions(PRICE_PLAN_DIM_ID, PRICE_PLAN_ID,
                               DIM_CODE, DIM_PPA_CODE,
                               DIM_SEQ_NUM,  MAND_DIM_FLAG,
                               TIME_DIM_FLAG , LOB_ENABLED_FLAG ,
                               DIM_SHORT_NAME , DIM_LONG_NAME ,
                               DIM_PLURAL_NAME , NATIVE_KEY_FLAG ,
                               MEASURE_DIM_FLAG , SPARSE_FLAG ,
                               LOWEST_LVL , LIST_PRICE_PLAN_FLAG ,
			       TEMPLATE_FLAG, INCLUDE_FLAG,
                               CREATION_DATE, CREATED_BY,
                               LAST_UPDATE_DATE, LAST_UPDATED_BY,
                               LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID,
                               PROGRAM_ID, REQUEST_ID)
                values(qpr_dimensions_s.nextval, g_new_pp_id,
                       r_dim_val.DIM_PPA_CODE(i) ||
                        to_char(g_new_pp_id)|| '_D',
                       r_dim_val.DIM_PPA_CODE(i),
                       r_dim_val.DIM_SEQ_NUM(i),
                       r_dim_val.MAND_DIM_FLAG(i),
                       r_dim_val.TIME_DIM_FLAG(i),
                       r_dim_val.LOB_ENABLED_FLAG(i),
                       r_dim_val.DIM_SHORT_NAME(i),
                       r_dim_val.DIM_LONG_NAME(i),
                       r_dim_val.DIM_PLURAL_NAME(i),
                       r_dim_val.NATIVE_KEY_FLAG(i),
                       r_dim_val.MEASURE_DIM_FLAG(i),
                       r_dim_val.SPARSE_FLAG(i),
                       r_dim_val.LOWEST_LVL(i),
                       r_dim_val.LIST_PP_FLAG(i),
                       'N', 'Y',
                       g_sys_date, g_user_id, g_sys_date, g_user_id,
                       g_login_id, g_prg_appl_id,
                       g_prg_id, g_request_id)
    returning PRICE_PLAN_DIM_ID, DIM_CODE bulk collect into rec_dim_out;

  return(rec_dim_out);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING DIMENSIONS...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_dim_values;

function insert_dim_attr_values(p_ppdim_id in number)
                                                  return num_type is
    l_dim_attr_id number;
    t_old_new_dim_attr num_type;
    rec_dim_attr_val val_out_type;
begin
    forall i in r_dim_attr_val.ATTR_PPA_CODE.first..
                                              r_dim_attr_val.ATTR_PPA_CODE.last
      insert into qpr_dim_attributes(DIM_ATTR_ID, PRICE_PLAN_DIM_ID,
                                        PRICE_PLAN_ID,
                                        ATTR_PPA_CODE, ATTR_SHORT_NAME,
                                        ATTR_LONG_NAME,	ATTR_PLURAL_NAME,
                                        ATTR_CLASSIFICATION, ATTR_DATA_TYPE,
                                        DEFAULT_ORDER_FLAG,TEMPLATE_FLAG,
                                        CREATION_DATE, CREATED_BY,
                                        LAST_UPDATE_DATE, LAST_UPDATED_BY,
                                        LAST_UPDATE_LOGIN,
                                        PROGRAM_APPLICATION_ID, PROGRAM_ID,
                                        REQUEST_ID)
                  values(qpr_dim_attributes_s.nextval, p_ppdim_id,
                        g_new_pp_id, r_dim_attr_val.ATTR_PPA_CODE(i),
                        r_dim_attr_val.ATTR_SHORT_NAME(i),
                        r_dim_attr_val.ATTR_LONG_NAME(i),
                        r_dim_attr_val.ATTR_PLURAL_NAME(i),
                        r_dim_attr_val.ATTR_CLASSIFICATION(i),
                        r_dim_attr_val.ATTR_DATA_TYPE(i),
                        r_dim_attr_val.DEFAULT_ORDER_FLAG(i), 'N',
                        g_sys_date, g_user_id, g_sys_date, g_user_id,
                        g_login_id, g_prg_appl_id, g_prg_id, g_request_id)
    returning DIM_ATTR_ID, ATTR_PPA_CODE bulk collect into rec_dim_attr_val;

    for i in r_dim_attr_val.ATTR_PPA_CODE.first..
                                          r_dim_attr_val.ATTR_PPA_CODE.last loop
      l_dim_attr_id := r_dim_attr_val.DIM_ATTR_ID(i);
      t_old_new_dim_attr(l_dim_attr_id) := rec_dim_attr_val.ID(i);
    end loop;

    return(t_old_new_dim_attr);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING DIMENSION ATTRIBUTES..');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_dim_attr_values;

function insert_hier_values(p_ppdim_id in number) return val_out_type is
  rec_hier_out val_out_type;
begin
  forall i in r_dim_hier_val.HIERARCHY_PPA_CODE.first..
                                        r_dim_hier_val.HIERARCHY_PPA_CODE.last
    insert into qpr_hierarchies(HIERARCHY_ID, PRICE_PLAN_DIM_ID,
                                   HIERARCHY_PPA_CODE, PRICE_PLAN_ID,
                                   HIER_SHORT_NAME, HIER_LONG_NAME,
                                   HIER_PLURAL_NAME, HIER_TYPE_CODE,
                                   HIER_DEFAULT_ORDER, DEFAULT_FLAG,
                                   CALENDAR_CODE,TEMPLATE_FLAG,
                                   CREATION_DATE,
                                   CREATED_BY, LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                                   PROGRAM_APPLICATION_ID, PROGRAM_ID,
                                   REQUEST_ID)
                values(qpr_hierarchies_s.nextval, p_ppdim_id,
                      r_dim_hier_val.HIERARCHY_PPA_CODE(i),
                      g_new_pp_id, r_dim_hier_val.HIER_SHORT_NAME(i),
                      r_dim_hier_val.HIER_LONG_NAME(i),
                      r_dim_hier_val.HIER_PLURAL_NAME(i),
                      r_dim_hier_val.HIER_TYPE_CODE(i),
                      r_dim_hier_val.HIER_DEFAULT_ORDER(i),
                      r_dim_hier_val.DEFAULT_FLAG(i),
                      r_dim_hier_val.CALENDAR_CODE(i),'N',
                      g_sys_date, g_user_id, g_sys_date, g_user_id,
                      g_login_id, g_prg_appl_id, g_prg_id, g_request_id)
    returning HIERARCHY_ID, HIERARCHY_PPA_CODE bulk collect into rec_hier_out;

    return(rec_hier_out);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING HIERARCHIES...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_hier_values;

function insert_hier_lvl_val(p_hier_id in number) return num_type is
    rec_lvl_out val_out_type;
    t_old_new_lvl num_type;
begin
    forall i in r_hier_lvl_val.HIERARCHY_LEVEL_ID.first..
                                        r_hier_lvl_val.HIERARCHY_LEVEL_ID.last
      insert into qpr_hier_levels(HIERARCHY_LEVEL_ID, HIERARCHY_ID,
                                     LEVEL_PPA_CODE, LEVEL_SEQ_NUM,
                                     PRICE_PLAN_ID, LVL_SHORT_NAME,
                                     LVL_LONG_NAME, LVL_PLURAL_NAME,
                                     MAPPING_VIEW_NAME, MAP_COLUMN,
                                     USER_MAPPING_VIEW_NAME,
                                     USER_MAP_COLUMN, TEMPLATE_FLAG,
                                     INCLUDE_FLAG,CREATION_DATE,
                                     CREATED_BY, LAST_UPDATE_DATE,
                                     LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                                     PROGRAM_APPLICATION_ID, PROGRAM_ID,
                                     REQUEST_ID)
                  values(qpr_hier_levels_s.nextval, p_hier_id,
                         r_hier_lvl_val.LEVEL_PPA_CODE(i),
                         r_hier_lvl_val.LEVEL_SEQ_NUM(i),
                         g_new_pp_id, r_hier_lvl_val.LVL_SHORT_NAME(i),
                         r_hier_lvl_val.LVL_LONG_NAME(i),
                         r_hier_lvl_val.LVL_PLURAL_NAME(i),
                         r_hier_lvl_val.MAPPING_VIEW_NAME(i),
                         r_hier_lvl_val.MAP_COLUMN(i),
                         r_hier_lvl_val.USER_MAPPING_VIEW_NAME(i),
                         r_hier_lvl_val.USER_MAP_COLUMN(i),'N','Y',
                         g_sys_date, g_user_id, g_sys_date, g_user_id,
                         g_login_id, g_prg_appl_id, g_prg_id, g_request_id)
      returning HIERARCHY_LEVEL_ID, LEVEL_PPA_CODE bulk collect into rec_lvl_out;

      for i in r_hier_lvl_val.HIERARCHY_LEVEL_ID.first..
                                    r_hier_lvl_val.HIERARCHY_LEVEL_ID.last loop
        t_old_new_lvl(r_hier_lvl_val.HIERARCHY_LEVEL_ID(i)) :=
                                                            rec_lvl_out.ID(i);
      end loop;
      return(t_old_new_lvl);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING HIERARCHY LEVELS...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_hier_lvl_val;

procedure insert_lvl_attributes is
begin
  forall i in r_lvl_attr_val.LEVEL_ATTR_ID.first..
                                          r_lvl_attr_val.LEVEL_ATTR_ID.last
    insert into qpr_lvl_attributes(LEVEL_ATTR_ID, HIERARCHY_LEVEL_ID,
                                      DIM_ATTR_ID,
                                      PRICE_PLAN_ID, MAPPING_VIEW_NAME,
                                      MAP_COLUMN, USER_MAPPING_VIEW_NAME,
                                      USER_MAP_COLUMN, TEMPLATE_FLAG,
                                      INCLUDED_FLAG,CREATION_DATE,
                                      CREATED_BY, LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                                      PROGRAM_APPLICATION_ID, PROGRAM_ID,
                                      REQUEST_ID)
               values(qpr_lvl_attributes_s.nextval,
                      r_lvl_attr_val.HIERARCHY_LEVEL_ID(i),
                      r_lvl_attr_val.DIM_ATTR_ID(i),
                      g_new_pp_id,
                      r_lvl_attr_val.MAPPING_VIEW_NAME(i),
                      r_lvl_attr_val.MAP_COLUMN(i),
                      r_lvl_attr_val.USER_MAPPING_VIEW_NAME(i),
                      r_lvl_attr_val.USER_MAP_COLUMN(i),'N','Y',
                      g_sys_date,
                      g_user_id, g_sys_date, g_user_id,g_login_id, g_prg_appl_id,
                      g_prg_id, g_request_id);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING LEVEL ATTRIBUTES...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_lvl_attributes;

function insert_cube_data return val_out_type is
  r_cub_val_out val_out_type;
begin
  forall i in r_cub_val.CUBE_CODE.first..r_cub_val.CUBE_CODE.last
    insert into qpr_cubes(CUBE_ID, CUBE_CODE, CUBE_PPA_CODE, PRICE_PLAN_ID,
                             CUBE_SHORT_NAME, CUBE_LONG_NAME,CUBE_PLURAL_NAME,
                             CUBE_AUTO_SOLVE_FLAG, DEFAULT_DATA_TYPE,
                             PARTITION_HIER,PARTITION_LEVEL, SPARSE_TYPE_CODE,
                             USE_GLOBAL_INDEX_FLAG, AGGMAP_NAME,
                             AGGMAP_CACHE_STORE, AGGMAP_CACHE_NA,
                             TEMPLATE_FLAG,
                             CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
                             LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                             PROGRAM_APPLICATION_ID, PROGRAM_ID,
                             REQUEST_ID)
               values(qpr_cubes_s.nextval,
              --        'QPR_'||r_cub_val.CUBE_PPA_CODE(i) || to_char(g_new_pp_id)
                --            || '_CUBE',
		      r_cub_val.CUBE_CODE(i),
                      r_cub_val.CUBE_PPA_CODE(i), g_new_pp_id,
                      r_cub_val.CUBE_SHORT_NAME(i),
                      r_cub_val.CUBE_LONG_NAME(i),
                      r_cub_val.CUBE_PLURAL_NAME(i),
                      r_cub_val.CUBE_AUTO_SOLVE_FLAG(i),
                      r_cub_val.DEFAULT_DATA_TYPE(i),
                      r_cub_val.PARTITION_HIER(i),
                      r_cub_val.PARTITION_LEVEL(i),
                      r_cub_val.SPARSE_TYPE_CODE(i),
                      r_cub_val.USE_GLOBAL_INDEX_FLAG(i),
                      r_cub_val.AGGMAP_NAME(i), r_cub_val.AGGMAP_CACHE_STORE(i),
                      r_cub_val.AGGMAP_CACHE_NA(i),'N',
                       g_sys_date, g_user_id, g_sys_date, g_user_id,
                      g_login_id, g_prg_appl_id, g_prg_id, g_request_id)
    returning CUBE_ID, CUBE_CODE bulk collect into r_cub_val_out;

    return(r_cub_val_out);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING CUBE DATA...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_cube_data;

function substitute_cube_code(p_calc_exp in varchar2) return varchar2 is
s_new_expression varchar2(1000);
s_final_expression varchar2(1000);
s_old_expression varchar2(1000);
s_cube_code varchar2(30);
l_oper_pos number;
l_plus_oper number;
l_minus_oper number;
l_div_oper number;
l_mult_oper number;
l_ctr number:= 0;
begin
  s_old_expression := p_calc_exp;
  s_final_expression := '';
  loop
    l_oper_pos := 0;

    l_plus_oper := instrb(s_old_expression, '+', 1);
    l_minus_oper := instrb(s_old_expression, '-', 1);
    l_mult_oper := instrb(s_old_expression, '*', 1);
    l_div_oper := instrb(s_old_expression, '/', 1);

    if (l_plus_oper = 0) and (l_minus_oper = 0) and (l_mult_oper = 0 )
        and (l_div_oper = 0) then
      l_oper_pos := -1;
    else
      l_oper_pos := l_plus_oper;

      if l_minus_oper > 0 and (l_oper_pos > l_minus_oper or l_oper_pos = 0) then
        l_oper_pos := l_minus_oper;
      end if;

      if l_mult_oper > 0 and (l_oper_pos > l_mult_oper or l_oper_pos = 0) then
        l_oper_pos := l_mult_oper;
      end if;

      if l_div_oper > 0 and (l_oper_pos > l_div_oper or l_oper_pos = 0) then
        l_oper_pos := l_div_oper;
      end if;
    end if;

    if l_oper_pos = -1 then
      s_new_expression := s_old_expression;
    else
      s_new_expression := substr(s_old_expression, 1, l_oper_pos);
    end if;

    if instrb(s_new_expression, '.', 1) > 0 then
      for j in r_cub_val.CUBE_PPA_CODE.first..r_cub_val.CUBE_PPA_CODE.last loop
        s_cube_code := substr(r_cub_val.CUBE_CODE(j), 1,
                        instrb(r_cub_val.CUBE_CODE(j), g_new_pp_id || '_C') -1);
        if trim(substr(s_new_expression, 1, instrb(s_new_expression, '.')-1)) =
           s_cube_code then
          s_final_expression := s_final_expression || r_cub_val.CUBE_CODE(j) ;
          s_final_expression := s_final_expression || substr(s_new_expression,
                                instrb(s_new_expression, '.', 1));
          exit;
        end if;
      end loop;
    else
      s_final_expression := s_final_expression || s_new_expression;
    end if;

    exit when (l_oper_pos = -1);

    s_old_expression := substr(s_old_expression, l_oper_pos+1);
  end loop;
  fnd_file.put_line(fnd_file.log,s_final_expression);
  return(s_final_expression);
end substitute_cube_code;

function insert_cub_meas(p_cube_id in number,p_from_pp_id in number,
                         p_cube_code in varchar2)
                      			return num_type is
  t_meas_old_new_ids num_type;
  r_meas_val_out val_out_type;
  s_calc_exp varchar2(1000);
  s_folder_name varchar2(30) := substrb(p_cube_code, 1,
                                    Instrb(p_cube_code, '_C')-1);
begin
  for i in r_cub_meas_val.MEASURE_ID.first..r_cub_meas_val.MEASURE_ID.last loop
    s_calc_exp := r_cub_meas_val.CAL_MEAS_EXPRESSION_TEXT(i);
    if g_copy_det_frm_tmpl = 'Y' then
--      for j in r_cub_val.CUBE_PPA_CODE.first..r_cub_val.CUBE_PPA_CODE.last loop
  --      s_calc_exp := replace(s_calc_exp,
--	              substrb(r_cub_val.CUBE_CODE(j), 1,
--		      (Instrb(r_cub_val.CUBE_CODE(j),s_srch_str)-1)),
--		      r_cub_val.CUBE_CODE(j));
--      end loop;
        if s_calc_exp is not null then
          s_calc_exp := substitute_cube_code(s_calc_exp);
        end if;
    else
        if s_calc_exp is not null then
          s_calc_exp := replace(s_calc_exp, p_from_pp_id, g_new_pp_id);
        end if;
    end if;
    r_cub_meas_val.CAL_MEAS_EXPRESSION_TEXT(i) := s_calc_exp;
  end loop;

  forall i in r_cub_meas_val.MEASURE_ID.first..r_cub_meas_val.MEASURE_ID.last
    insert into qpr_measures(MEASURE_ID, CUBE_ID, PRICE_PLAN_ID,
                              MEASURE_PPA_CODE, MEAS_CREATION_SEQ_NUM,
                              MEAS_SHORT_NAME, MEAS_LONG_NAME,
                              MEAS_PLURAL_NAME, MEAS_TYPE, MEAS_DATA_TYPE,
                              MEAS_AUTO_SOLVE, CAL_MEAS_EXPRESSION_TEXT,
                              MAPPING_VIEW_NAME, MAP_COLUMN,
                              USER_MAPPING_VIEW_NAME, USER_MAP_COLUMN,
                              AGGMAP_NAME,
                              MEAS_FOLD_SHORT_NAME, MEAS_FOLD_LONG_NAME,
                              MEAS_FOLD_PLURAL_NAME,TEMPLATE_FLAG,
			      INCLUDE_FLAG,
                              CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
                              LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                              PROGRAM_APPLICATION_ID, PROGRAM_ID,
                              REQUEST_ID)
          values(qpr_measures_s.nextval, p_cube_id, g_new_pp_id,
                 r_cub_meas_val.MEASURE_PPA_CODE(i),
                 r_cub_meas_val.MEAS_CREATION_SEQ_NUM(i),
                 r_cub_meas_val.MEAS_SHORT_NAME(i),
                 r_cub_meas_val.MEAS_LONG_NAME(i),
                 r_cub_meas_val.MEAS_PLURAL_NAME(i),
                 r_cub_meas_val.MEAS_TYPE(i),
                 r_cub_meas_val.MEAS_DATA_TYPE(i),
                 r_cub_meas_val.MEAS_AUTO_SOLVE(i),
                 r_cub_meas_val.CAL_MEAS_EXPRESSION_TEXT(i),
                 r_cub_meas_val.MAPPING_VIEW_NAME(i),
                 r_cub_meas_val.MAP_COLUMN(i),
                 r_cub_meas_val.USER_MAPPING_VIEW_NAME(i),
                 r_cub_meas_val.USER_MAP_COLUMN(i),
                 r_cub_meas_val.AGGMAP_NAME(i),
                 s_folder_name,
                 s_folder_name,
                 s_folder_name, 'N', 'Y',
                  g_sys_date, g_user_id, g_sys_date, g_user_id,
                 g_login_id, g_prg_appl_id, g_prg_id, g_request_id)
    returning MEASURE_ID, MEASURE_PPA_CODE bulk collect into r_meas_val_out;

  for i in r_cub_meas_val.MEASURE_ID.first..r_cub_meas_val.MEASURE_ID.last loop
    t_meas_old_new_ids(r_cub_meas_val.MEASURE_ID(i)) := r_meas_val_out.ID(i);
  end loop;
  return t_meas_old_new_ids;
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING CUBE MEASURES...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_cub_meas;

function insert_cub_dims(p_cube_id in number,
                         p_old_new_dimid in num_type,p_cube_def_agg in varchar2)
                         return num_type is
  l_old_dim_id number;
  t_old_new_cub_dim num_type;
  t_new_cub_dims num_type;
begin
  for i in r_cub_dims_val.CUBE_DIM_ID.first..r_cub_dims_val.CUBE_DIM_ID.last
  loop
    l_old_dim_id := r_cub_dims_val.PRICE_PLAN_DIM_ID(i);
    r_cub_dims_val.PRICE_PLAN_DIM_ID(i) := p_old_new_dimid(l_old_dim_id);
  end loop;

  forall i in r_cub_dims_val.CUBE_DIM_ID.first..r_cub_dims_val.CUBE_DIM_ID.last
    insert into qpr_cube_dims(CUBE_DIM_ID, CUBE_ID,
                                 PRICE_PLAN_ID, PRICE_PLAN_DIM_ID,
                                 AGGMAP_NAME,	DIM_OPCODE,
                                 DIM_SEQ_NUM,
                                 MAPPING_VIEW_NAME, MAP_COLUMN,
                                 USER_MAPPING_VIEW_NAME, USER_MAP_COLUMN,
                                 SET_LEVEL_FLAG, DIM_EXPRESSION,
                                 DIM_EXPRESSION_TYPE, WEIGHTED_MEASURE_FLAG,
                                 WEIGHT_MEASURE_NAME, WNAFILL,
                                 DIVIDE_BY_ZERO_FLAG, DECIMAL_OVERFLOW_FLAG,
                                 NASKIP_FLAG,TEMPLATE_FLAG,CREATION_DATE,
                                 CREATED_BY, LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                                 PROGRAM_APPLICATION_ID, PROGRAM_ID,
                                 REQUEST_ID)
              values(qpr_cube_dims_s.nextval, p_cube_id, g_new_pp_id,
                     r_cub_dims_val.PRICE_PLAN_DIM_ID(i),
                     nvl(r_cub_dims_val.AGGMAP_NAME(i), p_cube_def_agg),
                     r_cub_dims_val.DIM_OPCODE(i),
                     r_cub_dims_val.DIM_SEQ_NUM(i),
                     r_cub_dims_val.MAPPING_VIEW_NAME(i),
                     r_cub_dims_val.MAP_COLUMN(i),
                     r_cub_dims_val.USER_MAPPING_VIEW_NAME(i),
                     r_cub_dims_val.USER_MAP_COLUMN(i),
                     r_cub_dims_val.SET_LEVEL_FLAG(i),
                     r_cub_dims_val.DIM_EXPRESSION(i),
                     r_cub_dims_val.DIM_EXPRESSION_TYPE(i),
                     r_cub_dims_val.WEIGHTED_MEASURE_FLAG(i),
                     r_cub_dims_val.WEIGHT_MEASURE_NAME(i),
                     r_cub_dims_val.WNAFILL(i),
                     r_cub_dims_val.DIVIDE_BY_ZERO_FLAG(i),
                     r_cub_dims_val.DECIMAL_OVERFLOW_FLAG(i),
                     r_cub_dims_val.NASKIP_FLAG(i),'N',
                      g_sys_date, g_user_id, g_sys_date, g_user_id,
                     g_login_id, g_prg_appl_id, g_prg_id, g_request_id)
  returning CUBE_DIM_ID bulk collect into t_new_cub_dims;

  for i in r_cub_dims_val.CUBE_DIM_ID.first..
                                          r_cub_dims_val.CUBE_DIM_ID.last loop
    t_old_new_cub_dim(r_cub_dims_val.CUBE_DIM_ID(i)) := t_new_cub_dims(i);
  end loop;
  return(t_old_new_cub_dim);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING CUBE DIMENSIONS...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_cub_dims;

function insert_meas_aggr(p_old_new_cub_dim in num_type,
                           p_old_new_meas in num_type ) return val_out_type is
  l_old_meas_id number;
  l_old_dim_id number;
  l_ctr number := 0;
  l_rec_ctr number := 0;
  j pls_integer;
  r_meas_set_lvl val_out_type;
begin
  if g_copy_det_frm_tmpl = 'N' then
    for i in r_cub_meas_aggr.MEASURE_ID.first..r_cub_meas_aggr.MEASURE_ID.last
    loop
      l_old_meas_id := r_cub_meas_aggr.MEASURE_ID(i);
      r_cub_meas_aggr.MEASURE_ID(i):= p_old_new_meas(l_old_meas_id);
      l_old_dim_id := r_cub_meas_aggr.CUBE_DIM_ID(i);
      r_cub_meas_aggr.CUBE_DIM_ID(i) := p_old_new_cub_dim(l_old_dim_id);
      -- this array is needed to insert values in set_levels
      if r_cub_meas_aggr.SET_LEVEL_FLAG(i) = 'Y' then
        l_ctr := l_ctr + 1;
        -- t_meas_set_lvl(l_ctr) :=  r_cub_meas_aggr.MEASURE_ID(i);
	r_meas_set_lvl.ID(l_ctr) := r_cub_meas_aggr.MEASURE_ID(i);
	r_meas_set_lvl.PPA_CODE(l_ctr) := r_cub_meas_aggr.AGGMAP_NAME(i);
      end if;
    end loop;
  else
    -- loop thro all dimensions of the cube
    -- and insert the no. of recs from measure agg for cube for all cube dims;
    for i in r_cub_int_maggr.MEASURE_ID.first..r_cub_int_maggr.MEASURE_ID.last
    loop
      l_old_meas_id := r_cub_int_maggr.MEASURE_ID(i);
      if r_cub_int_maggr.SET_LEVEL_FLAG(i) = 'Y' then
        l_ctr := l_ctr + 1;
        --t_meas_set_lvl(l_ctr) :=  p_old_new_meas(l_old_meas_id);
	r_meas_set_lvl.ID(l_ctr) := p_old_new_meas(l_old_meas_id);
	r_meas_set_lvl.PPA_CODE(l_ctr) := r_cub_int_maggr.AGGMAP_NAME(i);
      end if;
      j := p_old_new_cub_dim.first;
      loop
        exit when j is null;
        l_rec_ctr := l_rec_ctr + 1;
        r_cub_meas_aggr.MEASURE_ID(l_rec_ctr) := p_old_new_meas(l_old_meas_id);
        r_cub_meas_aggr.CUBE_DIM_ID(l_rec_ctr) := p_old_new_cub_dim(j);
        r_cub_meas_aggr.AGGMAP_NAME(l_rec_ctr) := r_cub_int_maggr.AGGMAP_NAME(i);
        r_cub_meas_aggr.AGGMAP_CACHE_STORE(l_rec_ctr) :=
                                          r_cub_int_maggr.AGGMAP_CACHE_STORE(i);
        r_cub_meas_aggr.AGGMAP_CACHE_NA(l_rec_ctr) :=
                                            r_cub_int_maggr.AGGMAP_CACHE_NA(i);
        r_cub_meas_aggr.DIM_OPCODE(l_rec_ctr) := r_cub_int_maggr.DIM_OPCODE(i);
        r_cub_meas_aggr.SET_LEVEL_FLAG(l_rec_ctr) :=
                                              r_cub_int_maggr.SET_LEVEL_FLAG(i);
        r_cub_meas_aggr.OVERRIDE_FLAG(l_rec_ctr) :=
                                              r_cub_int_maggr.OVERRIDE_FLAG(i);
        r_cub_meas_aggr.DIM_EXPRESSION(l_rec_ctr) :=
                                              r_cub_int_maggr.DIM_EXPRESSION(i);
        r_cub_meas_aggr.DIM_EXPRESSION_TYPE(l_rec_ctr):=
                                        r_cub_int_maggr.DIM_EXPRESSION_TYPE(i);
        r_cub_meas_aggr.WEIGHTED_MEASURE_FLAG(l_rec_ctr):=
                                      r_cub_int_maggr.WEIGHTED_MEASURE_FLAG(i);
        r_cub_meas_aggr.WEIGHT_MEASURE_NAME(l_rec_ctr):=
                                        r_cub_int_maggr.WEIGHT_MEASURE_NAME(i);
        r_cub_meas_aggr.WNAFILL(l_rec_ctr) :=
                                        r_cub_int_maggr.WNAFILL(i);
        r_cub_meas_aggr.DIVIDE_BY_ZERO_FLAG(l_rec_ctr) :=
                                      r_cub_int_maggr.DIVIDE_BY_ZERO_FLAG(i);
        r_cub_meas_aggr.DECIMAL_OVERFLOW_FLAG(l_rec_ctr) :=
                                      r_cub_int_maggr.DECIMAL_OVERFLOW_FLAG(i);
        r_cub_meas_aggr.NASKIP_FLAG(l_rec_ctr) :=
                                        r_cub_int_maggr.NASKIP_FLAG(i);
        j := p_old_new_cub_dim.next(j);
      end loop;
    end loop;
  end if;

  forall i in r_cub_meas_aggr.MEASURE_ID.first..r_cub_meas_aggr.MEASURE_ID.last
    insert into qpr_meas_aggrs(MEAS_AGG_ID, MEASURE_ID, PRICE_PLAN_ID,
                                  CUBE_DIM_ID, AGGMAP_NAME, AGGMAP_CACHE_STORE,
                                  AGGMAP_CACHE_NA, DIM_OPCODE,
                                  SET_LEVEL_FLAG, OVERRIDE_FLAG,
                                  DIM_EXPRESSION, DIM_EXPRESSION_TYPE,
                                  WEIGHTED_MEASURE_FLAG, WEIGHT_MEASURE_NAME,
                                  WNAFILL, DIVIDE_BY_ZERO_FLAG,
                                  DECIMAL_OVERFLOW_FLAG, NASKIP_FLAG,
                                  TEMPLATE_FLAG,CREATION_DATE,CREATED_BY,
                                  LAST_UPDATE_DATE,LAST_UPDATED_BY,
                                  LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID,
                                  PROGRAM_ID, REQUEST_ID)
                values(qpr_meas_aggrs_s.nextval,
                       r_cub_meas_aggr.MEASURE_ID(i), g_new_pp_id,
                       r_cub_meas_aggr.CUBE_DIM_ID(i),
                       r_cub_meas_aggr.AGGMAP_NAME(i),
                       r_cub_meas_aggr.AGGMAP_CACHE_STORE(i),
                       r_cub_meas_aggr.AGGMAP_CACHE_NA(i),
                       r_cub_meas_aggr.DIM_OPCODE(i),
                       r_cub_meas_aggr.SET_LEVEL_FLAG(i),
                       r_cub_meas_aggr.OVERRIDE_FLAG(i),
                       r_cub_meas_aggr.DIM_EXPRESSION(i),
                       r_cub_meas_aggr.DIM_EXPRESSION_TYPE(i),
                       r_cub_meas_aggr.WEIGHTED_MEASURE_FLAG(i),
                       r_cub_meas_aggr.WEIGHT_MEASURE_NAME(i),
                       r_cub_meas_aggr.WNAFILL(i),
                       r_cub_meas_aggr.DIVIDE_BY_ZERO_FLAG(i),
                       r_cub_meas_aggr.DECIMAL_OVERFLOW_FLAG(i),
                       r_cub_meas_aggr.NASKIP_FLAG(i), 'N',
                        g_sys_date, g_user_id, g_sys_date, g_user_id,
                       g_login_id, g_prg_appl_id, g_prg_id, g_request_id);

    return(r_meas_set_lvl);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING MEASURE AGGREGATION...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_meas_aggr;

procedure insert_set_level(p_old_new_cub_dim in num_type,
                           p_old_new_meas in num_type,
                           p_r_meas_set_lvl in val_out_type) is
  l_old_dim_id number;
  l_old_meas_id number;
  l_rec_ctr number := 0;
begin
  if g_copy_det_frm_tmpl = 'N' then
    for i in r_cub_set_lvl.CUBE_DIM_ID.first..r_cub_set_lvl.CUBE_DIM_ID.last
    loop
      l_old_dim_id := r_cub_set_lvl.CUBE_DIM_ID(i);
      r_cub_set_lvl.CUBE_DIM_ID(i) := p_old_new_cub_dim(l_old_dim_id);
      l_old_meas_id := r_cub_set_lvl.MEASURE_ID(i);
      if l_old_meas_id is not null then
        r_cub_set_lvl.MEASURE_ID(i) := p_old_new_meas(l_old_meas_id);
      else
        r_cub_set_lvl.MEASURE_ID(i) := null;
      end if;
    end loop;
  else
    for i in r_int_set_lvl.CUBE_DIM_ID.first..r_int_set_lvl.CUBE_DIM_ID.last
    loop
      if r_int_set_lvl.SET_LEVEL_FLAG(i) = 'Y' then
        l_rec_ctr := l_rec_ctr + 1;
        l_old_dim_id := r_int_set_lvl.CUBE_DIM_ID(i);
        r_cub_set_lvl.CUBE_DIM_ID(l_rec_ctr) := p_old_new_cub_dim(l_old_dim_id);
        r_cub_set_lvl.MEASURE_ID(l_rec_ctr) := null;
        r_cub_set_lvl.LEVEL_SHORT_NAME(l_rec_ctr) :=
                                    r_int_set_lvl.LEVEL_SHORT_NAME(i);
        r_cub_set_lvl.DIM_EXPRESSION_TYPE(l_rec_ctr) :=
                                        r_int_set_lvl.DIM_EXPRESSION_TYPE(i);
        r_cub_set_lvl.AGGMAP_NAME(l_rec_ctr) :=
                                       r_int_set_lvl.AGGMAP_NAME(i);
      end if;
    end loop;
    if p_r_meas_set_lvl.ID.count > 0 then
      for i in p_r_meas_set_lvl.ID.first..p_r_meas_set_lvl.ID.last loop
        for j in r_int_set_lvl.CUBE_DIM_ID.first..r_int_set_lvl.CUBE_DIM_ID.last
        loop
          l_rec_ctr := l_rec_ctr + 1;
          l_old_dim_id := r_int_set_lvl.CUBE_DIM_ID(j);
          r_cub_set_lvl.CUBE_DIM_ID(l_rec_ctr) := p_old_new_cub_dim(l_old_dim_id);
          r_cub_set_lvl.MEASURE_ID(l_rec_ctr) := p_r_meas_set_lvl.ID(i);
          r_cub_set_lvl.LEVEL_SHORT_NAME(l_rec_ctr) :=
                                      r_int_set_lvl.LEVEL_SHORT_NAME(j);
          r_cub_set_lvl.DIM_EXPRESSION_TYPE(l_rec_ctr) :=
                                          r_int_set_lvl.DIM_EXPRESSION_TYPE(j);
          r_cub_set_lvl.AGGMAP_NAME(l_rec_ctr) :=
                                         p_r_meas_set_lvl.PPA_CODE(i);
        end loop;
      end loop;
    end if;
  end if;
  forall i in r_cub_set_lvl.MEASURE_ID.first..r_cub_set_lvl.MEASURE_ID.last
    insert into qpr_set_levels(SET_DIM_LEVEL_ID, CUBE_DIM_ID, MEASURE_ID,
                                  PRICE_PLAN_ID,
                                  LEVEL_SHORT_NAME, DIM_EXPRESSION_TYPE,
                                  AGGMAP_NAME,TEMPLATE_FLAG,CREATION_DATE,
                                  CREATED_BY, LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                                  PROGRAM_APPLICATION_ID, PROGRAM_ID,
                                  REQUEST_ID)
                values(qpr_set_levels_s.nextval,
                       r_cub_set_lvl.CUBE_DIM_ID(i),
                       r_cub_set_lvl.MEASURE_ID(i), g_new_pp_id,
                       r_cub_set_lvl.LEVEL_SHORT_NAME(i),
                       r_cub_set_lvl.DIM_EXPRESSION_TYPE(i),
                       r_cub_set_lvl.AGGMAP_NAME(i), 'N',
                        g_sys_date, g_user_id, g_sys_date, g_user_id,
                       g_login_id, g_prg_appl_id, g_prg_id, g_request_id);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING CUBE SET LEVEL... ');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_set_level;

procedure clean_dimattrval is
begin
  r_dim_attr_val.DIM_ATTR_ID.delete;
  r_dim_attr_val.ATTR_PPA_CODE.delete;
  r_dim_attr_val.ATTR_SHORT_NAME.delete;
  r_dim_attr_val.ATTR_LONG_NAME.delete;
  r_dim_attr_val.ATTR_PLURAL_NAME.delete;
  r_dim_attr_val.ATTR_CLASSIFICATION.delete;
  r_dim_attr_val.ATTR_DATA_TYPE.delete;
  r_dim_attr_val.DEFAULT_ORDER_FLAG.delete;
end clean_dimattrval;

procedure clean_hierlvlval is
begin
  r_hier_lvl_val.HIERARCHY_LEVEL_ID.delete;
  r_hier_lvl_val.LEVEL_PPA_CODE.delete;
  r_hier_lvl_val.LEVEL_SEQ_NUM.delete;
  r_hier_lvl_val.LVL_SHORT_NAME.delete;
  r_hier_lvl_val.LVL_LONG_NAME.delete;
  r_hier_lvl_val.LVL_PLURAL_NAME.delete;
  r_hier_lvl_val.MAPPING_VIEW_NAME.delete;
  r_hier_lvl_val.MAP_COLUMN.delete;
  r_hier_lvl_val.USER_MAPPING_VIEW_NAME.delete;
  r_hier_lvl_val.USER_MAP_COLUMN.delete;
end clean_hierlvlval;

procedure clean_lvlattrval is
begin
  r_lvl_attr_val.LEVEL_ATTR_ID.delete;
  r_lvl_attr_val.HIERARCHY_LEVEL_ID.delete;
  r_lvl_attr_val.DIM_ATTR_ID.delete;
  r_lvl_attr_val.MAPPING_VIEW_NAME.delete;
  r_lvl_attr_val.MAP_COLUMN.delete;
  r_lvl_attr_val.USER_MAPPING_VIEW_NAME.delete;
  r_lvl_attr_val.USER_MAP_COLUMN.delete;
end clean_lvlattrval;

procedure clean_hierval is
begin
  r_dim_hier_val.HIERARCHY_ID.delete;
  r_dim_hier_val.HIERARCHY_PPA_CODE.delete;
  r_dim_hier_val.HIER_SHORT_NAME.delete;
  r_dim_hier_val.HIER_LONG_NAME.delete;
  r_dim_hier_val.HIER_PLURAL_NAME.delete;
  r_dim_hier_val.HIER_TYPE_CODE.delete;
  r_dim_hier_val.HIER_DEFAULT_ORDER.delete;
  r_dim_hier_val.DEFAULT_FLAG.delete;
  r_dim_hier_val.CALENDAR_CODE.delete;
end clean_hierval;

procedure clean_dimval is
begin
  r_dim_val.SRC_PRICE_PLAN_DIM_ID.delete;
  r_dim_val.TMPL_PRICE_PLAN_DIM_ID.delete;
  r_dim_val.DIM_CODE.delete;
  r_dim_val.DIM_PPA_CODE.delete;
  r_dim_val.DIM_SEQ_NUM.delete;
  r_dim_val.DIM_SHORT_NAME.delete;
  r_dim_val.DIM_LONG_NAME.delete;
  r_dim_val.DIM_PLURAL_NAME.delete;
  r_dim_val.TIME_DIM_FLAG.delete;
  r_dim_val.NATIVE_KEY_FLAG.delete;
  r_dim_val.MEASURE_DIM_FLAG.delete;
  r_dim_val.SPARSE_FLAG.delete;
  r_dim_val.MAND_DIM_FLAG.delete;
  r_dim_val.LOB_ENABLED_FLAG.delete;
  r_dim_val.LOWEST_LVL.delete;
  r_dim_val.LIST_PP_FLAG.delete;
end clean_dimval;

procedure clean_cubmeasval is
begin
  r_cub_meas_val.MEASURE_ID.delete;
  r_cub_meas_val.MEASURE_PPA_CODE.delete;
  r_cub_meas_val.MEAS_CREATION_SEQ_NUM.delete;
  r_cub_meas_val.MEAS_SHORT_NAME.delete;
  r_cub_meas_val.MEAS_LONG_NAME.delete;
  r_cub_meas_val.MEAS_PLURAL_NAME.delete;
  r_cub_meas_val.MEAS_TYPE.delete;
  r_cub_meas_val.MEAS_DATA_TYPE.delete;
  r_cub_meas_val.MEAS_AUTO_SOLVE.delete;
  r_cub_meas_val.CAL_MEAS_EXPRESSION_TEXT.delete;
  r_cub_meas_val.MAPPING_VIEW_NAME.delete;
  r_cub_meas_val.MAP_COLUMN.delete;
  r_cub_meas_val.USER_MAPPING_VIEW_NAME.delete;
  r_cub_meas_val.USER_MAP_COLUMN.delete;
  r_cub_meas_val.AGGMAP_NAME.delete;
  r_cub_meas_val.MEAS_FOLD_SHORT_NAME.delete;
  r_cub_meas_val.MEAS_FOLD_LONG_NAME.delete;
  r_cub_meas_val.MEAS_FOLD_PLURAL_NAME.delete;
end clean_cubmeasval;


procedure clean_cubdimsval is
begin
  r_cub_dims_val.CUBE_DIM_ID.delete;
  r_cub_dims_val.PRICE_PLAN_DIM_ID.delete;
  r_cub_dims_val.AGGMAP_NAME.delete;
  r_cub_dims_val.DIM_OPCODE.delete;
  r_cub_dims_val.DIM_SEQ_NUM.delete;
  r_cub_dims_val.MAPPING_VIEW_NAME.delete;
  r_cub_dims_val.MAP_COLUMN.delete;
  r_cub_dims_val.USER_MAPPING_VIEW_NAME.delete;
  r_cub_dims_val.USER_MAP_COLUMN.delete;
  r_cub_dims_val.SET_LEVEL_FLAG.delete;
  r_cub_dims_val.DIM_EXPRESSION.delete;
  r_cub_dims_val.DIM_EXPRESSION_TYPE.delete;
  r_cub_dims_val.WEIGHTED_MEASURE_FLAG.delete;
  r_cub_dims_val.WEIGHT_MEASURE_NAME.delete;
  r_cub_dims_val.WNAFILL.delete;
  r_cub_dims_val.DIVIDE_BY_ZERO_FLAG.delete;
  r_cub_dims_val.DECIMAL_OVERFLOW_FLAG.delete;
  r_cub_dims_val.NASKIP_FLAG.delete;
end clean_cubdimsval;

procedure clean_measaggr is
begin
  r_cub_meas_aggr.MEASURE_ID.delete;
  r_cub_meas_aggr.CUBE_DIM_ID.delete;
  r_cub_meas_aggr.AGGMAP_NAME.delete;
  r_cub_meas_aggr.AGGMAP_CACHE_STORE.delete;
  r_cub_meas_aggr.AGGMAP_CACHE_NA.delete;
  r_cub_meas_aggr.DIM_OPCODE.delete;
  r_cub_meas_aggr.SET_LEVEL_FLAG.delete;
  r_cub_meas_aggr.OVERRIDE_FLAG.delete;
  r_cub_meas_aggr.DIM_EXPRESSION.delete;
  r_cub_meas_aggr.DIM_EXPRESSION_TYPE.delete;
  r_cub_meas_aggr.WEIGHTED_MEASURE_FLAG.delete;
  r_cub_meas_aggr.WEIGHT_MEASURE_NAME.delete;
  r_cub_meas_aggr.WNAFILL.delete;
  r_cub_meas_aggr.DIVIDE_BY_ZERO_FLAG.delete;
  r_cub_meas_aggr.DECIMAL_OVERFLOW_FLAG.delete;
  r_cub_meas_aggr.NASKIP_FLAG.delete;


  r_cub_int_maggr.MEASURE_ID.delete;
  r_cub_int_maggr.CUBE_DIM_ID.delete;
  r_cub_int_maggr.AGGMAP_NAME.delete;
  r_cub_int_maggr.AGGMAP_CACHE_STORE.delete;
  r_cub_int_maggr.AGGMAP_CACHE_NA.delete;
  r_cub_int_maggr.DIM_OPCODE.delete;
  r_cub_int_maggr.SET_LEVEL_FLAG.delete;
  r_cub_int_maggr.OVERRIDE_FLAG.delete;
  r_cub_int_maggr.DIM_EXPRESSION.delete;
  r_cub_int_maggr.DIM_EXPRESSION_TYPE.delete;
  r_cub_int_maggr.WEIGHTED_MEASURE_FLAG.delete;
  r_cub_int_maggr.WEIGHT_MEASURE_NAME.delete;
  r_cub_int_maggr.WNAFILL.delete;
  r_cub_int_maggr.DIVIDE_BY_ZERO_FLAG.delete;
  r_cub_int_maggr.DECIMAL_OVERFLOW_FLAG.delete;
  r_cub_int_maggr.NASKIP_FLAG.delete;
end clean_measaggr;

procedure clean_setlvl is
begin
  r_cub_set_lvl.CUBE_DIM_ID.delete;
  r_cub_set_lvl.MEASURE_ID.delete;
  r_cub_set_lvl.LEVEL_SHORT_NAME.delete;
  r_cub_set_lvl.DIM_EXPRESSION_TYPE.delete;
  r_cub_set_lvl.AGGMAP_NAME.delete;
  r_cub_set_lvl.SET_LEVEL_FLAG.delete;

  r_int_set_lvl.CUBE_DIM_ID.delete;
  r_int_set_lvl.MEASURE_ID.delete;
  r_int_set_lvl.LEVEL_SHORT_NAME.delete;
  r_int_set_lvl.DIM_EXPRESSION_TYPE.delete;
  r_int_set_lvl.AGGMAP_NAME.delete;
  r_int_set_lvl.SET_LEVEL_FLAG.delete;
end clean_setlvl;

procedure clean_cubval is
begin
  r_cub_val.SRC_CUBE_ID.delete;
  r_cub_val.TMPL_CUBE_ID.delete;
  r_cub_val.CUBE_PPA_CODE.delete;
  r_cub_val.CUBE_CODE.delete;
  r_cub_val.CUBE_SHORT_NAME.delete;
  r_cub_val.CUBE_LONG_NAME.delete;
  r_cub_val.CUBE_PLURAL_NAME.delete;
  r_cub_val.CUBE_AUTO_SOLVE_FLAG.delete;
  r_cub_val.DEFAULT_DATA_TYPE.delete;
  r_cub_val.PARTITION_HIER.delete;
  r_cub_val.PARTITION_LEVEL.delete;
  r_cub_val.SPARSE_TYPE_CODE.delete;
  r_cub_val.USE_GLOBAL_INDEX_FLAG.delete;
  r_cub_val.AGGMAP_NAME.delete;
  r_cub_val.AGGMAP_CACHE_STORE.delete;
  r_cub_val.AGGMAP_CACHE_NA.delete;
end clean_cubval;

function copy_dim_data(p_from_pp_id in number,
                        p_t_old_new_dim out nocopy num_type) return number is
  l_ctr PLS_INTEGER;
  l_old_lvlid number;
  l_old_dim_attr number;
  l_ret number := 0;
  l_pplan_dim_id number;
  s_lvl_sql varchar2(5000);
  s_temp_sql varchar2(10000);
  s_sql varchar2(30000);

  c_get_lvl_attr SYS_REFCURSOR;

--  the following table types/records stores the newly inserted values into
-- each of the qpr_ tables. They are 2 types: 1. Contains the unique id
-- generated as key and PPA_code as the values.
-- 2.Contains the old unique id and corresponding new id of the inserted recs
  rec_dim_ids val_out_type;
  rec_hier_ids val_out_type;
  t_old_new_dim_attr num_type;
  t_old_new_lvl num_type;
begin
  fnd_file.put_line(fnd_file.log, 'Copying dimensions...');

  if g_copy_det_frm_tmpl = 'Y' then
    select src.PRICE_PLAN_DIM_ID, tmpl.PRICE_PLAN_DIM_ID, tmpl.DIM_CODE,
           tmpl.DIM_PPA_CODE, tmpl.DIM_SEQ_NUM, tmpl.MAND_DIM_FLAG,
           tmpl.TIME_DIM_FLAG, tmpl.LOB_ENABLED_FLAG, tmpl.DIM_SHORT_NAME,
           tmpl.DIM_LONG_NAME, tmpl.DIM_PLURAL_NAME,
           tmpl.NATIVE_KEY_FLAG,
           tmpl.MEASURE_DIM_FLAG, tmpl.SPARSE_FLAG , tmpl.LOWEST_LVL,
           tmpl.LIST_PRICE_PLAN_FLAG
    bulk collect into r_dim_val
    from qpr_dimensions src, qpr_dimensions tmpl
    where src.PRICE_PLAN_ID = p_from_pp_id
    and tmpl.PRICE_PLAN_ID = g_src_pplan_id
    and src.DIM_PPA_CODE = tmpl.DIM_PPA_CODE
    and nvl(tmpl.INCLUDE_FLAG, 'Y') = 'Y';
  else
    select PRICE_PLAN_DIM_ID, null, DIM_CODE, DIM_PPA_CODE, DIM_SEQ_NUM,
           MAND_DIM_FLAG, TIME_DIM_FLAG, LOB_ENABLED_FLAG, DIM_SHORT_NAME,
           DIM_LONG_NAME, DIM_PLURAL_NAME, NATIVE_KEY_FLAG,
           MEASURE_DIM_FLAG, SPARSE_FLAG , LOWEST_LVL, LIST_PRICE_PLAN_FLAG
    bulk collect into r_dim_val
    from qpr_dimensions
    where PRICE_PLAN_ID = g_src_pplan_id
    and nvl(INCLUDE_FLAG, 'Y') = 'Y';
  end if;

  s_sql := '';

  if r_dim_val.DIM_CODE.count = 0 then
    fnd_file.put_line(fnd_file.log, 'No dimensions to copy..');
    return(-2);
  end if;

  rec_dim_ids := insert_dim_values;

  s_lvl_sql := 'select LEVEL_ATTR_ID, HIERARCHY_LEVEL_ID,DIM_ATTR_ID,';
  s_lvl_sql := s_lvl_sql || ' MAPPING_VIEW_NAME, MAP_COLUMN, ';
  s_lvl_sql := s_lvl_sql || ' USER_MAPPING_VIEW_NAME, USER_MAP_COLUMN ';
  s_lvl_sql := s_lvl_sql || 'from qpr_lvl_attributes where PRICE_PLAN_ID=:1';
  s_lvl_sql := s_lvl_sql || ' and nvl(INCLUDED_FLAG, ''Y'') = ''Y''' ;
  s_lvl_sql := s_lvl_sql || ' and HIERARCHY_LEVEL_ID IN (' ;

  for i in rec_dim_ids.ID.first..rec_dim_ids.ID.last loop
    if g_copy_det_frm_tmpl = 'Y' then
      p_t_old_new_dim(r_dim_val.TMPL_PRICE_PLAN_DIM_ID(i)) := rec_dim_ids.ID(i);
    else
      p_t_old_new_dim(r_dim_val.SRC_PRICE_PLAN_DIM_ID(i)) := rec_dim_ids.ID(i);
    end if;

    fnd_file.put_line(fnd_file.log,
                'Copying dimension attributes for ' || rec_dim_ids.PPA_CODE(i));
--  Note: when details are not copied from template then tmpl_price_plan_dim_id
--  will be null.
    l_pplan_dim_id := nvl(r_dim_val.TMPL_PRICE_PLAN_DIM_ID(i) ,
                          r_dim_val.SRC_PRICE_PLAN_DIM_ID(i)) ;
    select DIM_ATTR_ID, ATTR_PPA_CODE, ATTR_SHORT_NAME, ATTR_LONG_NAME,
          ATTR_PLURAL_NAME, ATTR_CLASSIFICATION, ATTR_DATA_TYPE,
          DEFAULT_ORDER_FLAG
    bulk collect into r_dim_attr_val
    from qpr_dim_attributes
    where PRICE_PLAN_ID = g_src_pplan_id
    and PRICE_PLAN_DIM_ID = l_pplan_dim_id;

    if r_dim_attr_val.DIM_ATTR_ID.count > 0 then
      t_old_new_dim_attr := insert_dim_attr_values(rec_dim_ids.ID(i));
    else
      fnd_file.put_line(fnd_file.log, 'No dimension attributes to copy..');
    end if;

    clean_dimattrval;

    fnd_file.put_line(fnd_file.log,
                        'Copying hierarchies for ' || rec_dim_ids.PPA_CODE(i));

    select HIERARCHY_ID,HIERARCHY_PPA_CODE,HIER_SHORT_NAME, HIER_LONG_NAME,
        HIER_PLURAL_NAME, HIER_TYPE_CODE, HIER_DEFAULT_ORDER,DEFAULT_FLAG,
        CALENDAR_CODE
    bulk collect into r_dim_hier_val
    from qpr_hierarchies
    where PRICE_PLAN_ID = g_src_pplan_id
    and PRICE_PLAN_DIM_ID =  l_pplan_dim_id;

    if r_dim_hier_val.HIERARCHY_ID.count > 0 then
      rec_hier_ids := insert_hier_values(rec_dim_ids.ID(i));
      for j in rec_hier_ids.ID.first..rec_hier_ids.ID.last loop
        fnd_file.put_line(fnd_file.log,
                  'Copying levels for hierarchy ' || rec_hier_ids.PPA_CODE(j));

        select HIERARCHY_LEVEL_ID, LEVEL_PPA_CODE, LEVEL_SEQ_NUM,
                LVL_SHORT_NAME, LVL_LONG_NAME, LVL_PLURAL_NAME,
                MAPPING_VIEW_NAME, MAP_COLUMN , USER_MAPPING_VIEW_NAME,
                USER_MAP_COLUMN
        bulk collect into r_hier_lvl_val
        from qpr_hier_levels
        where PRICE_PLAN_ID = g_src_pplan_id
        and HIERARCHY_ID = r_dim_hier_val.HIERARCHY_ID(j)
        and nvl(INCLUDE_FLAG, 'Y') = 'Y';

        if r_hier_lvl_val.HIERARCHY_LEVEL_ID.count = 0 then
           fnd_file.put_line(fnd_file.log,
              'No level to copy for hierarchy...' );
           l_ret := -1;
        else
           t_old_new_lvl := insert_hier_lvl_val(rec_hier_ids.ID(j));
        end if;

        clean_hierlvlval;

        if t_old_new_lvl.count > 0 then
-- NOTE: here we can't use the for loop since the index is a number and indicates
-- level id that might not be consecutive. So when for loop is used then all ids
-- within the given range is taken and hence we will have more ids than intended.
          l_ctr := t_old_new_lvl.first;
          s_temp_sql := '';
          loop
            exit when l_ctr is null;
            s_temp_sql := s_temp_sql || l_ctr ;
            if l_ctr <> t_old_new_lvl.last then
              s_temp_sql := s_temp_sql || ',';
            end if;
            l_ctr := t_old_new_lvl.next(l_ctr);
          end loop;

          s_sql := s_lvl_sql || s_temp_sql || ')' ;

          fnd_file.put_line(fnd_file.log, 'Copying attributes for all levels...');

          open c_get_lvl_attr for s_sql using g_src_pplan_id;
          fetch c_get_lvl_attr bulk collect into r_lvl_attr_val;
          close c_get_lvl_attr;

          if r_lvl_attr_val.LEVEL_ATTR_ID.count > 0 then
            for k in r_lvl_attr_val.LEVEL_ATTR_ID.first..
                                      r_lvl_attr_val.LEVEL_ATTR_ID.last loop
              l_old_lvlid := r_lvl_attr_val.HIERARCHY_LEVEL_ID(k);
              l_old_dim_attr := r_lvl_attr_val.DIM_ATTR_ID(k);
              r_lvl_attr_val.HIERARCHY_LEVEL_ID(k) := t_old_new_lvl(l_old_lvlid);
              r_lvl_attr_val.DIM_ATTR_ID(k) := t_old_new_dim_attr(l_old_dim_attr);
            end loop;
            insert_lvl_attributes;
          else
            fnd_file.put_line(fnd_file.log, 'No level attributes to copy..');
          end if;

          clean_lvlattrval;
        end if;
        t_old_new_lvl.delete;
      end loop;
      t_old_new_dim_attr.delete;
    else
      fnd_file.put_line(fnd_file.log, 'No Hierarchies to copy...');
      l_ret := -1;
    end if;
    clean_hierval;
    rec_hier_ids.ID.delete;
    rec_hier_ids.PPA_CODE.delete;
  end loop;
  clean_dimval;
  rec_dim_ids.id.delete;
  rec_dim_ids.PPA_CODE.delete;
  return(l_ret);
exception
    when OTHERS then
      fnd_file.put_line(fnd_file.log,'ERROR COPYING DIMENSION RELATED DATA...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
      return(-1);
end copy_dim_data;

function get_cube_meas_aggrs_sql return varchar2 is
  s_sql varchar2(5000);
begin
  s_sql := 'select MEASURE_ID, CUBE_DIM_ID,AGGMAP_NAME, AGGMAP_CACHE_STORE,';
  s_sql := s_sql || ' AGGMAP_CACHE_NA, DIM_OPCODE,';
  s_sql := s_sql || ' SET_LEVEL_FLAG, OVERRIDE_FLAG, DIM_EXPRESSION, ';
  s_sql := s_sql || 'DIM_EXPRESSION_TYPE,WEIGHTED_MEASURE_FLAG, ';
  s_sql := s_sql || 'WEIGHT_MEASURE_NAME, WNAFILL,DIVIDE_BY_ZERO_FLAG, ';
  s_sql := s_sql || ' DECIMAL_OVERFLOW_FLAG, NASKIP_FLAG ';
  s_sql := s_sql || ' from qpr_meas_aggrs where PRICE_PLAN_ID = :1 ';

  return(s_sql);
end get_cube_meas_aggrs_sql;

function get_cube_set_lvl_sql return varchar2 is
  s_sql varchar2(5000);
begin
  if g_copy_det_frm_tmpl = 'N' then
    s_sql := ' select a.CUBE_DIM_ID,a.MEASURE_ID, a.LEVEL_SHORT_NAME ,' ;
    s_sql := s_sql || ' a.DIM_EXPRESSION_TYPE,a.AGGMAP_NAME, null';
    s_sql := s_sql || ' from qpr_set_levels a';
    s_sql := s_sql || ' where a.PRICE_PLAN_ID = :1 ';
  else
    s_sql := ' select b.CUBE_DIM_ID, a.MEASURE_ID, ' ;
    s_sql := s_sql || 'a.LEVEL_SHORT_NAME,a.DIM_EXPRESSION_TYPE,a.AGGMAP_NAME,';
    s_sql := s_sql || 'b.SET_LEVEL_FLAG from qpr_set_levels a, ' ;
    s_sql := s_sql || ' qpr_cube_dims b where a.PRICE_PLAN_ID = :1 ';
    s_sql := s_sql || ' and b.PRICE_PLAN_ID = a.PRICE_PLAN_ID ' ;
    s_sql := s_sql || ' and b.CUBE_DIM_ID = a.CUBE_DIM_ID ';
  end if;

  return(s_sql);
end get_cube_set_lvl_sql;

function copy_cube_data(p_from_pp_id in number,
                        p_t_old_new_dim in num_type) return number is
  l_ctr pls_integer;
  l_ret number := 0;
  l_ref_cub_id number;
  s_sql varchar2(30000);
  s_meas_sql varchar2(5000);
  s_cub_dims_sql varchar2(5000);
  s_get_cmagg_sql varchar2(5000);
  s_get_set_lvl_sql varchar2(5000);

  rec_cub_ids val_out_type;
  t_old_new_meas num_type;
  t_old_new_cub_dim num_type;
  ---t_meas_set_lvl num_type;
  r_meas_set_lvl val_out_type;

  c_get_cub_meas_agg SYS_REFCURSOR;
  c_get_set_level SYS_REFCURSOR;
begin
  fnd_file.put_line(fnd_file.log, 'Copying cube data...');

  if g_copy_det_frm_tmpl = 'Y' then
      select src.CUBE_ID, tmpl.CUBE_ID , src.CUBE_PPA_CODE,
             tmpl.CUBE_CODE || g_new_pp_id || '_C' ,
             tmpl.CUBE_SHORT_NAME, tmpl.CUBE_LONG_NAME, tmpl.CUBE_PLURAL_NAME,
             tmpl.CUBE_AUTO_SOLVE_FLAG, tmpl.DEFAULT_DATA_TYPE, tmpl.PARTITION_HIER,
             tmpl.PARTITION_LEVEL,tmpl.SPARSE_TYPE_CODE, tmpl.USE_GLOBAL_INDEX_FLAG,
             tmpl.AGGMAP_NAME, tmpl.AGGMAP_CACHE_STORE, tmpl.AGGMAP_CACHE_NA
      bulk collect into r_cub_val
      from qpr_cubes src, qpr_cubes tmpl
      where src.PRICE_PLAN_ID = p_from_pp_id
      and tmpl.PRICE_PLAN_ID = g_src_pplan_id and
      src.CUBE_PPA_CODE = tmpl.CUBE_PPA_CODE
      order by tmpl.cube_id;
  else
    select CUBE_ID, null , CUBE_PPA_CODE,
           replace(CUBE_CODE, p_from_pp_id, g_new_pp_id), CUBE_SHORT_NAME,
           CUBE_LONG_NAME, CUBE_PLURAL_NAME, CUBE_AUTO_SOLVE_FLAG,
           DEFAULT_DATA_TYPE, PARTITION_HIER,PARTITION_LEVEL,SPARSE_TYPE_CODE,
           USE_GLOBAL_INDEX_FLAG,AGGMAP_NAME,AGGMAP_CACHE_STORE,AGGMAP_CACHE_NA
    bulk collect into r_cub_val
    from qpr_cubes where PRICE_PLAN_ID = p_from_pp_id
    order by cube_id;
  end if;
  if r_cub_val.src_cube_id.count = 0 then
    fnd_file.put_line(fnd_file.log, 'No cube to copy ...');
    return(-1);
  else
    rec_cub_ids := insert_cube_data;
  end if;

  s_get_cmagg_sql := get_cube_meas_aggrs_sql;
  s_get_set_lvl_sql := get_cube_set_lvl_sql;

  for i in rec_cub_ids.ID.first..rec_cub_ids.ID.last loop
    fnd_file.put_line(fnd_file.log,
                    'Copying data for cube ' || rec_cub_ids.PPA_CODE(i));
    if g_copy_det_frm_tmpl = 'Y' then
      l_ref_cub_id := r_cub_val.TMPL_CUBE_ID(i);
    else
      l_ref_cub_id := r_cub_val.SRC_CUBE_ID(i);
    end if;
--    ****** COPYING CUBE MEASURES ***********
    fnd_file.put_line(fnd_file.log, 'Copying cube measures... ' );

    select MEASURE_ID, MEASURE_PPA_CODE, MEAS_CREATION_SEQ_NUM,
        MEAS_SHORT_NAME, MEAS_LONG_NAME, MEAS_PLURAL_NAME, MEAS_TYPE,
        MEAS_DATA_TYPE, MEAS_AUTO_SOLVE,
        CAL_MEAS_EXPRESSION_TEXT,
        MAPPING_VIEW_NAME, MAP_COLUMN, USER_MAPPING_VIEW_NAME,
        USER_MAP_COLUMN, AGGMAP_NAME,MEAS_FOLD_SHORT_NAME,
        MEAS_FOLD_LONG_NAME, MEAS_FOLD_PLURAL_NAME
    bulk collect into r_cub_meas_val
    from qpr_measures
    where PRICE_PLAN_ID  = g_src_pplan_id
    and CUBE_ID = l_ref_cub_id
    and nvl(INCLUDE_FLAG, 'Y') = 'Y';

    if r_cub_meas_val.MEASURE_ID.count = 0 then
      fnd_file.put_line(fnd_file.log, 'No Measures to copy');
      l_ret := -1;
    else
      t_old_new_meas := insert_cub_meas( rec_cub_ids.ID(i),p_from_pp_id,
                              		rec_cub_ids.PPA_CODE(i));
    end if;
    clean_cubmeasval;

--  The cube measure ids are concatenated to be used in querying the measure
--   aggregation values for this cube.
    s_meas_sql := '';
    l_ctr := t_old_new_meas.first;
    loop
      exit when l_ctr is null;
      s_meas_sql := s_meas_sql || l_ctr ;
      if l_ctr <> t_old_new_meas.last then
        s_meas_sql := s_meas_sql || ',' ;
      end if;
      l_ctr := t_old_new_meas.next(l_ctr);
    end loop;

--    ********* COPYING CUBE DIMENSIONS *********
    fnd_file.put_line(fnd_file.log, 'Copying cube dimensions...');

    select CUBE_DIM_ID, PRICE_PLAN_DIM_ID, AGGMAP_NAME,
           DIM_OPCODE, DIM_SEQ_NUM,MAPPING_VIEW_NAME,MAP_COLUMN,
           USER_MAPPING_VIEW_NAME,USER_MAP_COLUMN,SET_LEVEL_FLAG,
          DIM_EXPRESSION,DIM_EXPRESSION_TYPE,WEIGHTED_MEASURE_FLAG,
          WEIGHT_MEASURE_NAME, WNAFILL,DIVIDE_BY_ZERO_FLAG,
          DECIMAL_OVERFLOW_FLAG,NASKIP_FLAG
    bulk collect into r_cub_dims_val
    from qpr_cube_dims
    where PRICE_PLAN_ID  = g_src_pplan_id
    and CUBE_ID = l_ref_cub_id;

    if r_cub_dims_val.CUBE_DIM_ID.count = 0 then
      fnd_file.put_line(fnd_file.log, 'No Cube dimensions to copy...');
      l_ret := 0;
    else
      t_old_new_cub_dim := insert_cub_dims(rec_cub_ids.ID(i),
                                          p_t_old_new_dim,
                                       r_cub_val.AGGMAP_NAME(i));
    end if;

    clean_cubdimsval;
    -- the cube dims value are concatenated for querying
    -- values in set_levels
    s_cub_dims_sql := '';
    l_ctr := t_old_new_cub_dim.first;
    loop
      exit when l_ctr is null;
      s_cub_dims_sql := s_cub_dims_sql || l_ctr ;
      if l_ctr <> t_old_new_cub_dim.last then
        s_cub_dims_sql := s_cub_dims_sql || ',' ;
      end if;
      l_ctr := t_old_new_cub_dim.next(l_ctr);
    end loop;

    if t_old_new_meas.count > 0 and t_old_new_cub_dim.count > 0 then
--    ******** Copying measure aggregation *******
      s_sql := s_get_cmagg_sql;
      s_sql := s_sql || ' and MEASURE_ID in (' || s_meas_sql || ')';

   -- Note: when reading from template we collect to a different rec.
   -- since template does not contain entry for all dimensions. We must
   -- loop thro to insert all dimension & measure combinations
      if g_copy_det_frm_tmpl = 'Y' then
        open c_get_cub_meas_agg for s_sql using g_src_pplan_id;
        fetch c_get_cub_meas_agg bulk collect into r_cub_int_maggr;
        close c_get_cub_meas_agg;
      else
        open c_get_cub_meas_agg for s_sql using g_src_pplan_id;
        fetch c_get_cub_meas_agg bulk collect into r_cub_meas_aggr;
        close c_get_cub_meas_agg;
      end if;

      if r_cub_meas_aggr.MEASURE_ID.count > 0
      or r_cub_int_maggr.MEASURE_ID.count > 0 then
        fnd_file.put_line(fnd_file.log, 'Copying cube measure aggregation...');
        r_meas_set_lvl := insert_meas_aggr(t_old_new_cub_dim,t_old_new_meas);
      else
        fnd_file.put_line(fnd_file.log,
                      'No specific measure aggregation defined for this cube');
      end if;
      clean_measaggr;

--    ************ COPYING SET LEVEL ***********

      s_sql := s_get_set_lvl_sql;
      s_sql := s_sql || ' and a.CUBE_DIM_ID in (' || s_cub_dims_sql || ')';

      if g_copy_det_frm_tmpl = 'Y' then
        open c_get_set_level for s_sql using g_src_pplan_id;
        fetch c_get_set_level bulk collect into r_int_set_lvl;
        close c_get_set_level;
      else
        open c_get_set_level for s_sql using g_src_pplan_id;
        fetch c_get_set_level bulk collect into r_cub_set_lvl;
        close c_get_set_level;
      end if;

      if r_cub_set_lvl.CUBE_DIM_ID.count > 0
      or r_int_set_lvl.CUBE_DIM_ID.count > 0 then
        fnd_file.put_line(fnd_file.log, 'Copying cube set level...');
        insert_set_level(t_old_new_cub_dim, t_old_new_meas,
                       r_meas_set_lvl);
      else
        fnd_file.put_line(fnd_file.log,
                        'No levels set for this cube dimensions/measures');
      end if;
      clean_setlvl;
    end if;
    r_meas_set_lvl.ID.delete;
    r_meas_set_lvl.PPA_CODE.delete;
    t_old_new_meas.delete;
    t_old_new_cub_dim.delete;
  end loop;
  clean_cubval;

  rec_cub_ids.ID.delete;
  rec_cub_ids.PPA_CODE.delete;
  return(l_ret);
exception
  when OTHERS then
    fnd_file.put_line(fnd_file.log, 'ERROR COPYING CUBE RELATED DATA...');
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    raise;
    return(-1);
end copy_cube_data;

procedure copy_price_plan( errbuf out nocopy varchar2,
                          retcode out nocopy varchar2,
                          p_from_pp_id in number,
                          p_new_aw_name in varchar2,
                          p_copy_det_frm_tmpl in varchar2) is
  bfound boolean := false;
  l_start_time number;
  l_end_time number;
  l_ret_dim number;
  l_ret_cube number;
  l_tmpl_plan_id number;

  t_old_new_dim num_type;

  cursor c_get_price_plan(pp_id number) is
        select INSTANCE_ID, AW_TYPE_CODE, AW_CODE, AW_STATUS_CODE, START_DATE,
              END_DATE,BASE_UOM_CODE,
              CURRENCY_CODE
        from qpr_price_plans_b
        where PRICE_PLAN_ID = pp_id
        and rownum = 1;

  cursor c_get_price_plan_tl(pp_id number) is
         select LANGUAGE,SOURCE_LANG, NAME, DESCRIPTION
         from qpr_price_plans_tl
         where PRICE_PLAN_ID = pp_id;

  cursor c_scopes is
    select DIM_CODE,HIERARCHY_ID,LEVEL_ID,OPERATOR,SCOPE_VALUE,
            SCOPE_VALUE_DESC
    from qpr_scopes
    where parent_entity_type = 'DATAMART'
    and parent_id = p_from_pp_id;

begin
  fnd_file.put_line(fnd_file.log, 'Starting to copy...');
  select hsecs into l_start_time from v$timer;
  fnd_file.put_line(fnd_file.log, 'Start time :'||
                                      to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));
  fnd_profile.get('CONC_REQUEST_ID', g_request_id);
  g_sys_date := sysdate;
  g_user_id := fnd_global.user_id;
  g_login_id := fnd_global.conc_login_id;
  g_prg_appl_id := fnd_global.prog_appl_id;
  g_prg_id := fnd_global.conc_program_id;

  g_src_pplan_id := p_from_pp_id;
  g_copy_det_frm_tmpl := p_copy_det_frm_tmpl;

  if g_src_pplan_id = 0 or g_src_pplan_id is null then
    raise NO_PPLAN_ID;
  end if;

  for rec_price_plan in c_get_price_plan(p_from_pp_id) loop
    bfound := true;
    if p_copy_det_frm_tmpl = 'Y' then
      l_tmpl_plan_id := qpr_sr_util.g_datamart_tmpl_id;
      g_src_pplan_id := l_tmpl_plan_id;
    end if;

    fnd_file.put_line(fnd_file.log,'Copying from price plan id:' || g_src_pplan_id);

    insert into QPR_PRICE_PLANS_B(PRICE_PLAN_ID, INSTANCE_ID, AW_TYPE_CODE,
                              AW_STATUS_CODE, AW_CODE, AW_CREATED_FLAG,
                              START_DATE, END_DATE,BASE_UOM_CODE,
                              CURRENCY_CODE, AW_XML,
                              TEMPLATE_FLAG,CREATION_DATE,
                              CREATED_BY, LAST_UPDATE_DATE,LAST_UPDATED_BY,
                              LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID,
                              PROGRAM_ID, REQUEST_ID)
                values(qpr_price_plans_s.nextval,
                       rec_price_plan.INSTANCE_ID,
                       rec_price_plan.AW_TYPE_CODE,
                       null,
                       'QPR' || to_char(qpr_price_plans_s.currval),
                       'N', rec_price_plan.START_DATE, rec_price_plan.END_DATE,
                       rec_price_plan.BASE_UOM_CODE,
                       rec_price_plan.CURRENCY_CODE,
                       empty_clob(), 'N',
                       g_sys_date,g_user_id, g_sys_date,
                       g_user_id, g_login_id, g_prg_appl_id, g_prg_id,
                       g_request_id)
                returning PRICE_PLAN_ID into g_new_pp_id;

    for rec_pp_tl in c_get_price_plan_tl(p_from_pp_id) loop
      insert into QPR_PRICE_PLANS_TL(PRICE_PLAN_ID, LANGUAGE, SOURCE_LANG,
                                     NAME, DESCRIPTION, CREATION_DATE,
                              CREATED_BY, LAST_UPDATE_DATE,LAST_UPDATED_BY,
                              LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID,
                              PROGRAM_ID, REQUEST_ID)
                  values(g_new_pp_id, rec_pp_tl.LANGUAGE, rec_pp_tl.SOURCE_LANG,
                         p_new_aw_name, p_new_aw_name, g_sys_date,
                         g_user_id, g_sys_date, g_user_id, g_login_id,
                         g_prg_appl_id, g_prg_id, g_request_id);
    end loop;

    for rec_scope in c_scopes loop
      insert into QPR_SCOPES(SCOPE_ID,PARENT_ENTITY_TYPE, PARENT_ID,
                            DIM_CODE, HIERARCHY_ID, LEVEL_ID,
                            OPERATOR, SCOPE_VALUE, SCOPE_VALUE_DESC,
                            CREATION_DATE,
                            CREATED_BY, LAST_UPDATE_DATE,LAST_UPDATED_BY,
                            LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID,
                            PROGRAM_ID, REQUEST_ID)
      values(qpr_scopes_s.nextval, 'DATAMART', g_new_pp_id,
            rec_scope.dim_code, rec_scope.hierarchy_id, rec_scope.level_id,
            rec_scope.operator, rec_scope.scope_value,
            rec_scope.scope_value_desc, g_sys_date,
                         g_user_id, g_sys_date, g_user_id, g_login_id,
                         g_prg_appl_id, g_prg_id, g_request_id);
    end loop;
  end loop;

  if bfound=false then
    raise NO_PPLAN_DATA;
  end if;

  fnd_file.put_line(fnd_file.log, 'Created new price plan:' || g_new_pp_id);

  l_ret_dim := copy_dim_data(p_from_pp_id,t_old_new_dim);

  if l_ret_dim <> -2 then
  	l_ret_cube := copy_cube_data(p_from_pp_id,t_old_new_dim);
  end if;

  commit;
  select hsecs into l_end_time from v$timer;
  fnd_file.put_line(fnd_file.log, 'End time :'|| to_char(sysdate,
                                                      'MM/DD/YYYY:HH:MM:SS'));
  fnd_file.put_line(fnd_file.log, 'Time taken for loading(sec):' ||
                                              (l_end_time - l_start_time)/100);
  if l_ret_dim = -1 or l_ret_cube = -1 then
    raise ERR_IN_DEFN;
  end if;
exception
  when NO_PPLAN_DATA then
    retcode := 2;
    errbuf  := 'ERROR: ' || substr(SQLERRM,1,1000) ;
    fnd_file.put_line(fnd_file.log, 'SOURCE PRICEPLAN/DATAMART DATA NOT FOUND');
    rollback;
  when NO_PPLAN_ID then
    retcode := 2;
    errbuf  := 'ERROR: SOURCE PRICE PLAN ID NOT MENTIONED';
    fnd_file.put_line(fnd_file.log,
	'UNABLE TO COPY PRICEPLAN/DATMART DEFINITION');
    rollback;
  when ERR_IN_DEFN then
    retcode := 1;
    fnd_file.put_line(fnd_file.log,
    'New priceplan/datamart definition is malformed.' ||
    'Check the log and source priceplan/datamart definition');
  when OTHERS then
    retcode := 1;
    errbuf  := 'ERROR: ' || substr(SQLERRM,1,1000);
    fnd_file.put_line(fnd_file.log,
	'UNABLE TO COPY PRICEPLAN/DATMART DEFINITION');
    fnd_file.put_line(fnd_file.log, 'ERROR: ' || substr(SQLERRM,1,1000));
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    rollback;
end copy_price_plan;

END;


/
