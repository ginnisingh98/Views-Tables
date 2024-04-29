--------------------------------------------------------
--  DDL for Package BEN_PD_COPY_TO_BEN_ONE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PD_COPY_TO_BEN_ONE" AUTHID CURRENT_USER as
/* $Header: bepdccp1.pkh 120.3 2006/03/08 02:43:19 rgajula noship $ */
--
TYPE g_pk_rec_type Is RECORD(
    pk_id_column    varchar2(80)
    -- pk_id_column    number(15)
   ,old_value       number(15)
   ,new_value       number(15)
   ,copy_reuse_type varchar2(30)
   ,table_route_id  number(15)
   );
--
g_pk_rec  g_pk_rec_type ;
TYPE pk_table is table of g_pk_rec_type index by binary_integer ;
g_pk_tbl                    pk_table ;
g_count                     number := 1 ;
g_mapping_done              boolean default true ;

--
-- Start Log additions
--
TYPE g_log_rec_type Is RECORD(
    pk_id     number(15)
   ,new_name  varchar2(1000)
   );
--
TYPE log_table is table of g_log_rec_type index by binary_integer ;
--
g_pgm_tbl_copied            log_table ;
g_pgm_tbl_reused            log_table ;
g_pgm_tbl_copied_count      number := 0 ;
g_pgm_tbl_reused_count      number := 0 ;

g_pln_tbl_copied            log_table ;
g_pln_tbl_reused            log_table ;
g_pln_tbl_copied_count      number := 0 ;
g_pln_tbl_reused_count      number := 0 ;

g_opt_tbl_copied            log_table ;
g_opt_tbl_reused            log_table ;
g_opt_tbl_copied_count      number := 0 ;
g_opt_tbl_reused_count      number := 0 ;

g_ptp_tbl_copied            log_table ;
g_ptp_tbl_reused            log_table ;
g_ptp_tbl_copied_count      number := 0 ;
g_ptp_tbl_reused_count      number := 0 ;

g_eat_tbl_copied            log_table ;
g_eat_tbl_reused            log_table ;
g_eat_tbl_copied_count      number := 0 ;
g_eat_tbl_reused_count      number := 0 ;

g_bnb_tbl_copied            log_table ;
g_bnb_tbl_reused            log_table ;
g_bnb_tbl_copied_count      number := 0 ;
g_bnb_tbl_reused_count      number := 0 ;

g_clf_tbl_copied            log_table ;
g_clf_tbl_reused            log_table ;
g_clf_tbl_copied_count      number := 0 ;
g_clf_tbl_reused_count      number := 0 ;

g_hwf_tbl_copied            log_table ;
g_hwf_tbl_reused            log_table ;
g_hwf_tbl_copied_count      number := 0 ;
g_hwf_tbl_reused_count      number := 0 ;

g_agf_tbl_copied            log_table ;
g_agf_tbl_reused            log_table ;
g_agf_tbl_copied_count      number := 0 ;
g_agf_tbl_reused_count      number := 0 ;

g_lsf_tbl_copied            log_table ;
g_lsf_tbl_reused            log_table ;
g_lsf_tbl_copied_count      number := 0 ;
g_lsf_tbl_reused_count      number := 0 ;

g_pff_tbl_copied            log_table ;
g_pff_tbl_reused            log_table ;
g_pff_tbl_copied_count      number := 0 ;
g_pff_tbl_reused_count      number := 0 ;

g_cla_tbl_copied            log_table ;
g_cla_tbl_reused            log_table ;
g_cla_tbl_copied_count      number := 0 ;
g_cla_tbl_reused_count      number := 0 ;

g_reg_tbl_copied            log_table ;
g_reg_tbl_reused            log_table ;
g_reg_tbl_copied_count      number := 0 ;
g_reg_tbl_reused_count      number := 0 ;

g_bnr_tbl_copied            log_table ;
g_bnr_tbl_reused            log_table ;
g_bnr_tbl_copied_count      number := 0 ;
g_bnr_tbl_reused_count      number := 0 ;

g_bpp_tbl_copied            log_table ;
g_bpp_tbl_reused            log_table ;
g_bpp_tbl_copied_count      number := 0 ;
g_bpp_tbl_reused_count      number := 0 ;

g_ler_tbl_copied            log_table ;
g_ler_tbl_reused            log_table ;
g_ler_tbl_copied_count      number := 0 ;
g_ler_tbl_reused_count      number := 0 ;

g_psl_tbl_copied            log_table ;
g_psl_tbl_reused            log_table ;
g_psl_tbl_copied_count      number := 0 ;
g_psl_tbl_reused_count      number := 0 ;

g_elp_tbl_copied            log_table ;
g_elp_tbl_reused            log_table ;
g_elp_tbl_copied_count      number := 0 ;
g_elp_tbl_reused_count      number := 0 ;

g_dce_tbl_copied            log_table ;
g_dce_tbl_reused            log_table ;
g_dce_tbl_copied_count      number := 0 ;
g_dce_tbl_reused_count      number := 0 ;

g_gos_tbl_copied            log_table ;
g_gos_tbl_reused            log_table ;
g_gos_tbl_copied_count      number := 0 ;
g_gos_tbl_reused_count      number := 0 ;

g_bng_tbl_copied            log_table ;
g_bng_tbl_reused            log_table ;
g_bng_tbl_copied_count      number := 0 ;
g_bng_tbl_reused_count      number := 0 ;

g_pdl_tbl_copied            log_table ;
g_pdl_tbl_reused            log_table ;
g_pdl_tbl_copied_count      number := 0 ;
g_pdl_tbl_reused_count      number := 0 ;

g_sva_tbl_copied            log_table ;
g_sva_tbl_reused            log_table ;
g_sva_tbl_copied_count      number := 0 ;
g_sva_tbl_reused_count      number := 0 ;

g_cpl_tbl_copied            log_table ;
g_cpl_tbl_reused            log_table ;
g_cpl_tbl_copied_count      number := 0 ;
g_cpl_tbl_reused_count      number := 0 ;

g_cbp_tbl_copied            log_table ;
g_cbp_tbl_reused            log_table ;
g_cbp_tbl_copied_count      number := 0 ;
g_cbp_tbl_reused_count      number := 0 ;

g_cpt_tbl_copied            log_table ;
g_cpt_tbl_reused            log_table ;
g_cpt_tbl_copied_count      number := 0 ;
g_cpt_tbl_reused_count      number := 0 ;

g_fff_tbl_copied            log_table ;
g_fff_tbl_reused            log_table ;
g_fff_tbl_copied_count      number := 0 ;
g_fff_tbl_reused_count      number := 0 ;

g_abr_tbl_copied            log_table ;
g_abr_tbl_reused            log_table ;
g_abr_tbl_copied_count      number := 0 ;
g_abr_tbl_reused_count      number := 0 ;

g_apr_tbl_copied            log_table ;
g_apr_tbl_reused            log_table ;
g_apr_tbl_copied_count      number := 0 ;
g_apr_tbl_reused_count      number := 0 ;

g_vpf_tbl_copied            log_table ;
g_vpf_tbl_reused            log_table ;
g_vpf_tbl_copied_count      number := 0 ;
g_vpf_tbl_reused_count      number := 0 ;

g_ccm_tbl_copied            log_table ;
g_ccm_tbl_reused            log_table ;
g_ccm_tbl_copied_count      number := 0 ;
g_ccm_tbl_reused_count      number := 0 ;

g_acp_tbl_copied            log_table ;
g_acp_tbl_reused            log_table ;
g_acp_tbl_copied_count      number := 0 ;
g_acp_tbl_reused_count      number := 0 ;

g_egl_tbl_copied            log_table ;
g_egl_tbl_reused            log_table ;
g_egl_tbl_copied_count      number := 0 ;
g_egl_tbl_reused_count      number := 0 ;

g_copy_effective_date       date;
g_transaction_category      pqh_transaction_categories.short_name%type;

--
--
-- ----------------------------------------------------------------------------
-- |------------------------< log_data >--------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure log_data(p_table_alias       in varchar2
                  ,p_pk_id             in number
                  ,p_new_name          in varchar2
                  ,p_copied_reused_cd  in varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< ben_chk_col_len >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure ben_chk_col_len(column_type  in varchar2
                         ,table_name   in varchar2
                         ,column_value in varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< init_log_tbl >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure init_log_tbl;
--
-- End Log additions
--

--
-- Start Performance additions
--
TYPE g_table_data_in_cer_type Is RECORD(
   table_alias    varchar2(30),
   table_route_id number
   );
--
TYPE table_data_in_cer_table is table of g_table_data_in_cer_type index by binary_integer ;
--
g_table_data_in_cer                  table_data_in_cer_table;
g_table_data_in_cer_count            number := 0;
--
-- ----------------------------------------------------------------------------
-- |------------------------< init_copy_tbl >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure init_table_data_in_cer(p_copy_entity_txn_id  in number);
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< data_exists >-----------------------------------|
-- ----------------------------------------------------------------------------
--
function data_exists_for_table(p_table_alias in varchar2) return boolean;

--
-- End Performance additions
--

-- ----------------------------------------------------------------------------
-- |------------------------< create_or_update_ff >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description: This procedure is used to perform insert/dt update of the FF.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--     As Below
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   None
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- Working :
-- This procedure will alow datetrack update of the FF records
-- The 2 Parameters p_dml_operation and  p_datetrack_mode will
-- be the deciding parameters of what will be done to the FF Table
--
-- p_dml_operation	p_datetrack_mode
-- INSERT		    N/A
-- UPDATE		UPDATE
-- UPDATE		CORRECTION
-- UPDATE		UPDATE_OVERRIDE
-- UPDATE		UPDATE_CHANGE_INSERT

-- The datetrack modes may be passed to this externalised procedure using hr_api.g_xxxx constants also.

-- As of now the p_formula_text is a long parameter and this externalized procedure as of now
-- would not support for clob p_formula_text
-- {End Of Comments}
--

PROCEDURE create_or_update_ff
(p_formula_id          in number,
p_effective_start_date in date,
p_effective_end_date   in date,
p_business_group_id    in number,
p_legislation_code     in varchar,
p_formula_type_id      in number,
p_formula_name         in varchar,
p_description          in varchar,
p_formula_text         in long,
p_sticky_flag          in varchar,
p_compile_flag         in varchar,
p_last_update_date     in date,
p_last_updated_by      in number,
p_last_update_login    in number,
p_created_by           in number,
p_creation_date        in date,
p_process_date         in date,
p_dml_operation        in varchar,
p_datetrack_mode      in varchar);





-- ----------------------------------------------------------------------------
-- |------------------------< raise_error_message >------------------------|
-- ----------------------------------------------------------------------------
--
procedure raise_error_message( p_table_alias in varchar2,
                                  p_object_name in varchar2 ) ;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_all_leaf_ben_rows >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_all_leaf_ben_rows(
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_effective_date                 in  date
  ,p_prefix_suffix_text             in  varchar2  default null
  ,p_reuse_object_flag              in  varchar2  default null
  ,p_target_business_group_id       in  varchar2  default null
  ,p_prefix_suffix_cd               in  varchar2  default null
  ,p_txn_row_type_cd		    in  varchar2  default null
 );
 --New Parameter p_txn_row_type_cd addedd for TCS PDW Integration Enhancement
-- ----------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
-- |------------------------< create_fff_rows >------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE create_fff_rows (
      p_validate                   IN   NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN   NUMBER,
      p_effective_date             IN   DATE,
      p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
   );

-- ----------------------------------------------------------------------------
-- |------------------------< create_clf_rows >------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE create_clf_rows (
      p_validate                   IN   NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN   NUMBER,
      p_effective_date             IN   DATE,
      p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
   );

-- ----------------------------------------------------------------------------
-- |------------------------< create_hwf_rows >------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE create_hwf_rows (
      p_validate                   IN   NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN   NUMBER,
      p_effective_date             IN   DATE,
      p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
   );

-- ----------------------------------------------------------------------------
-- |------------------------< create_agf_rows >------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE create_agf_rows (
      p_validate                   IN   NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN   NUMBER,
      p_effective_date             IN   DATE,
      p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
   );

-- ----------------------------------------------------------------------------
-- |------------------------< create_lsf_rows >------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE create_lsf_rows (
      p_validate                   IN   NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN   NUMBER,
      p_effective_date             IN   DATE,
      p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
   );

-- ----------------------------------------------------------------------------
-- |------------------------< create_pff_rows >------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE create_pff_rows (
      p_validate                   IN   NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN   NUMBER,
      p_effective_date             IN   DATE,
      p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
   );

-- ----------------------------------------------------------------------------
-- |------------------------< create_cla_rows >------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE create_cla_rows (
      p_validate                   IN   NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN   NUMBER,
      p_effective_date             IN   DATE,
      p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
   );

-- ----------------------------------------------------------------------------
-- |------------------------< create_elp_rows >------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE create_elp_rows (
      p_validate                   IN   NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN   NUMBER,
      p_effective_date             IN   DATE,
      p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
   );

-- ----------------------------------------------------------------------------
-- |--------------------------< create_egl_rows >------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE create_egl_rows (
      p_validate                   IN   NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN   NUMBER,
      p_effective_date             IN   DATE,
      p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
   );

end BEN_PD_COPY_TO_BEN_ONE;

 

/
