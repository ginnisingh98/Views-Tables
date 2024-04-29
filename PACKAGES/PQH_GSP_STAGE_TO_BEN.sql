--------------------------------------------------------
--  DDL for Package PQH_GSP_STAGE_TO_BEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_STAGE_TO_BEN" AUTHID CURRENT_USER as
/* $Header: pqgspsbe.pkh 120.1 2005/12/14 03:35 hmehta noship $ */
function get_ovn(p_table_name       in varchar2,
                 p_key_column_name  in varchar2,
                 p_key_column_value in number,
                 p_effective_date   in date default null) return number;
function get_update_mode(p_table_name varchar2,
                         p_key_column_name varchar2,
                         p_key_column_value number,
                         p_effective_date in date) return varchar2;
procedure stage_to_ben(p_copy_entity_txn_id in number,
                       p_effective_date     in date,
                       p_business_group_id  in number,
                       p_datetrack_mode     in varchar2,
                       p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure stage_to_opt(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_pl_typ_id         in number,
                       p_datetrack_mode     in varchar2);
Procedure stage_to_plan(p_copy_entity_txn_id in number,
                        p_business_group_id in number,
                        p_effective_date    in date,
                       p_pl_typ_id         in number,
                       p_datetrack_mode     in varchar2);
procedure stage_to_oipl(p_copy_entity_txn_id in number,
                        p_business_group_id  in number,
                        p_effective_date     in date,
                       p_datetrack_mode     in varchar2);
procedure stage_to_pgm(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_pl_typ_id         in number,
                       p_datetrack_mode     in varchar2);
Procedure stage_to_elp(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_datetrack_mode     in varchar2);
procedure stage_to_abr(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_datetrack_mode     in varchar2);
procedure stage_to_vpf(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_datetrack_mode     in varchar2);
procedure stage_to_plip(p_copy_entity_txn_id in number,
                        p_business_group_id  in number,
                        p_effective_date     in date,
                        p_datetrack_mode     in varchar2,
                        p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure stage_to_cep(p_copy_entity_txn_id in number,
                       p_business_group_id  in number,
                       p_effective_date     in date,
                       p_datetrack_mode     in varchar2);
procedure stage_to_epa(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_datetrack_mode     in varchar2);
PROCEDURE create_pgm_le (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      NUMBER,
      p_effective_date      IN              VARCHAR2,
      p_business_group_id   IN              VARCHAR2,
      p_pgm_id              IN              NUMBER DEFAULT NULL
   );
procedure cre_update_elig_prfl(
        p_copy_entity_txn_id in number
       ,p_effective_date     in date
       ,p_business_group_id  in number
       ,p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');

end pqh_gsp_stage_to_ben;

 

/
