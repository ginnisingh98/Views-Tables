--------------------------------------------------------
--  DDL for Package PQH_RBC_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RBC_STAGE" AUTHID CURRENT_USER AS
/* $Header: pqrbcstg.pkh 120.1 2005/10/31 10:25 srajakum noship $ */
function build_rate_node_name(p_rate_matrix_node_id in number,
                              p_business_group_id   in number,
                              p_node_short_code     in varchar2 default null,
                              p_effective_date     in date
) return varchar2 ;
procedure cre_matrix(p_business_group_id  in number,
                     p_effective_date     in date,
                     p_copy_entity_txn_id out nocopy number);
procedure upd_matrix(p_rate_matrix_id     in number,
                     p_effective_date     in date,
                     p_business_group_id  in number,
                     p_mode               in varchar2 default 'NORMAL',
                     p_matrix_loaded          out nocopy varchar2,
                     p_copy_entity_txn_id     out nocopy number);
procedure build_rate_matx(p_cet_id in number,
                          p_effective_date in date);
procedure rbr_writeback(p_cet_id         in number,
                        p_effective_date in date);
procedure rbr_writeback(p_rbr_cer_id     in number,
                        p_effective_date in date);
procedure recalc_rate_matx(p_cet_id in number,
                           p_effective_date in date);
function get_annual_factor(p_freq_cd in varchar2) return number;
--
end pqh_rbc_stage;

 

/
