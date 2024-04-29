--------------------------------------------------------
--  DDL for Package PQH_GSP_BEN_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_BEN_VALIDATIONS" AUTHID CURRENT_USER as
/* $Header: pqgspben.pkh 120.0.12010000.1 2008/07/28 12:57:26 appldev ship $ */

procedure pgm_validations(p_pgm_id                      in Number,
                          p_dml_operation               in Varchar2,
                          p_effective_date              in Date,
                          p_business_group_id           in Number        Default hr_general.GET_BUSINESS_GROUP_ID,
                          p_short_name                  in Varchar2      Default NULL,
                          p_short_code                  in Varchar2      Default NULL,
                          p_Dflt_Pgm_Flag               in Varchar2      Default 'N',
                          p_Pgm_Typ_Cd                  in Varchar2      Default NULL,
                          p_pgm_Stat_cd                 in Varchar2      Default 'I',
                          p_Use_Prog_Points_Flag        in Varchar2      Default 'N',
                          p_Acty_Ref_Perd_Cd            In Varchar2      Default NULL,
                          p_Pgm_Uom                     In Varchar2      Default NULL);


procedure pl_validations(p_pl_id              In number,
                         p_effective_date     In date,
                         p_Business_Group_Id  In Number     Default hr_general.GET_BUSINESS_GROUP_ID,
                         p_dml_operation      In varchar2,
                         p_pl_Typ_Id          In Number         Default NULL,
                         p_Mapping_Table_PK_ID     In Number    Default NULL,
                         p_pl_stat_cd              IN Varchar2  Default 'I');



procedure plip_validations(p_plip_id           In Number,
                           p_effective_date    In Date,
                           p_dml_operation     In Varchar2,
                           p_business_group_id In Number    Default hr_general.GET_BUSINESS_GROUP_ID,
                           p_Plip_Stat_Cd        In Varchar Default 'I');


procedure opt_validations(p_opt_id            in number,
                          p_effective_date    in date,
                          p_dml_operation     in varchar2,
                          p_Business_Group_Id in Number   Default hr_general.GET_BUSINESS_GROUP_ID,
                          p_mapping_table_pk_id in Number Default NULL);


procedure oipl_validations(p_oipl_id           in number,
                           p_dml_operation     in varchar2,
                           p_effective_date    in date,
                           p_Business_Group_Id in Number   Default hr_general.GET_BUSINESS_GROUP_ID,
                           p_oipl_stat_cd      in Varchar2 Default 'I');


procedure abr_validations(p_abr_id            in number,
                          p_dml_operation     in varchar2,
                          p_effective_date    in date,
                          p_business_group_id IN Number          Default hr_general.GET_BUSINESS_GROUP_ID,
                          p_pl_id             In Number          Default NULL,
                          p_opt_id            In Number          Default NULL,
                          p_acty_typ_cd       In Varchar2        Default NULL,
                          p_Acty_Base_RT_Stat_Cd   In Varchar2       Default 'I');


Function is_pgm_type_gsp(p_Pgm_Id            in Number,
                            p_Business_Group_Id in Number Default hr_general.GET_BUSINESS_GROUP_ID,
                            p_Effective_Date    in Date
                           )
Return Varchar2;

end pqh_gsp_ben_validations;

/
