--------------------------------------------------------
--  DDL for Package PQH_RBC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RBC_UTILITY" AUTHID CURRENT_USER AS
/* $Header: pqrbcutl.pkh 120.25 2006/03/10 09:29 srajakum noship $ */
function allow_criteria_delete(p_eligy_criteria_id in number) return varchar2;
function get_matrix_disable_date(p_pl_id in number,p_effective_date in date) return Date;

function allow_hgrid_add(p_copy_entity_txn_id in number,p_max_allowed in number) return varchar2;
function allow_hgrid_reorder(p_copy_entity_txn_id in number) return varchar2;

procedure delete_matrix_nodes(p_copy_entity_txn_id in number,
                            p_pl_id     in number,
                            p_level     in number,
                            p_short_code in varchar2,
                            p_mode      in varchar2
                            );

procedure delete_matrix_rates(p_copy_entity_txn_id in number,
                            p_rate_matrix_node_id   in number,
                            p_mode      in varchar2
                            );

procedure delete_matrix_values(p_copy_entity_txn_id in number,
                            p_rate_matrix_node_id   in number,
                            p_mode      in varchar2
                            );

procedure create_update_criteria(p_mode               in varchar2,
                                 p_eligy_criteria_id  in number,
                                 p_business_area      in varchar2,
                                 p_business_group_id  in number,
                                 p_effective_date     in date,
                                 p_criteria_type      in varchar2,
                                 p_copy_entity_txn_id in  out nocopy number,
                                 p_copy_entity_result_id  out nocopy number,
                                 p_copy_entity_result_ovn out nocopy number);
procedure stage_to_criteria(p_copy_entity_txn_id in number,
                            p_effective_date     in date,
                            p_eligy_criteria_id     out nocopy number);

FUNCTION check_criteria_rate_under_use(p_criteria_rate_defn_id NUMBER) RETURN varchar2;
PROCEDURE insert_rate_defn_tl(rateid  in number,
                                  ratename in varchar2,
                                  lang     in varchar2,
                                  slang    in varchar2,
                                  cdate    in date,
                                  cperson  in number);
PROCEDURE sync_rate_factors_tables(critId in varchar2,
                                              parentId in varchar2);
FUNCTION is_used_in_matrix(p_selected_rate_matrix NUMBER, p_criteria_rate_defn_id NUMBER) RETURN varchar2;
FUNCTION get_rate_factor_name(p_criteria_rate_factor_id NUMBER) RETURN varchar2;
PROCEDURE is_crit_rate_short_name_uniq(sname      in varchar2,
                                       rateId     in number,
                                       bgId       in number,
                                       isValid    out nocopy varchar2);
PROCEDURE is_crit_rate_name_uniq(cname      in varchar2,
                                 rateId     in number,
                                 bgId       in number,
                                 isValid    out nocopy varchar2);
PROCEDURE cascade_rate_factors_table(rateTypeId in varchar2);
procedure cancel_rate_matrix_txn(p_copy_entity_txn_id in number,p_status out nocopy varchar2);
function is_lowest_level(p_copy_entity_txn_id    number,
                          p_copy_entity_result_id number,
                          p_level_number          number) return varchar2;
--
procedure delete_rate_values
        (p_copy_entity_txn_id       in number,
         p_copy_entity_result_id    in number
        );

--
Procedure add_crd_to_rate_matrix
         (p_business_group_id     in number,
          p_criteria_rate_defn_id in number,
          p_copy_entity_txn_id    in number,
          p_define_min_flag       in varchar2,
          p_define_mid_flag       in varchar2,
          p_define_max_flag       in varchar2,
          p_define_std_flag       in varchar2,
          p_currency_code         in varchar2,
          p_uom                   in varchar2,
          p_rate_calc_cd          in varchar2,
          p_display_computed_values in varchar2,
          p_name                  in varchar2
          );
--
Procedure remove_crd_from_rate_matrix
         (p_business_group_id     in number,
          p_criteria_rate_defn_id in number,
          p_copy_entity_txn_id    in number,
          p_removed_crd_name     out nocopy varchar2,
          p_removed_dep_crd      out nocopy varchar2);
--
Procedure rebuild_rbr_rows
         (p_business_group_id     in number,
          p_copy_entity_txn_id    in number
          ) ;

/**
procedure load_criteria_seed_row(p_owner in varchar2
                        ,p_short_code in varchar2
                        ,p_name in varchar2
                        ,p_description in varchar2
                        ,p_crit_col1_val_type_cd in varchar2
                        ,p_crit_col1_datatype in varchar2
                        ,p_col1_lookup_type in varchar2
                        ,p_col1_value_set_name in varchar2
                        ,p_access_table_name1 in varchar2
                        ,p_access_column_name1 in varchar2
                        ,p_crit_col2_val_type_cd in varchar2
                        ,p_crit_col2_datatype in varchar2
                        ,p_col2_lookup_type in varchar2
                        ,p_col2_value_set_name in varchar2
                        ,p_access_table_name2 in varchar2
                        ,p_access_column_name2 in varchar2
                        ,p_allow_range_validation_flag in varchar2
                        ,p_allow_range_validation_flag2 in varchar2
                        ,p_user_defined_flag in varchar2
                        ,p_business_group_id in varchar2
                        ,p_legislation_code in varchar2
                        );
**/
procedure rate_columns_in_sync(critId      in number,
                            pMaxFlag    in varchar2,
                            pMinFlag    in varchar2,
                            pMidFlag    in varchar2,
                            pDflFlag    in varchar2,
                            pOutValue   out nocopy varchar2);
FUNCTION get_currency_name(p_currency_code varchar2) RETURN varchar2;

FUNCTION get_formula_name(p_formula_id varchar2) RETURN varchar2;

Function get_vset_datatype(p_value_set_id in number) return varchar2;

end pqh_rbc_utility;

 

/
