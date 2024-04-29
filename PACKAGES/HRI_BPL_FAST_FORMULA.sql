--------------------------------------------------------
--  DDL for Package HRI_BPL_FAST_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_FAST_FORMULA" AUTHID CURRENT_USER AS
/* $Header: hribffl.pkh 120.0 2005/05/29 06:53:03 appldev noship $ */
--
-- Exceptions created to handle errors in spawned sub processes.
--
  sub_process_not_found           EXCEPTION;
  sub_process_failed              EXCEPTION;
--
PROCEDURE gnrt_bg_ss_prfrmnce_apprsl_ff (p_business_group_id IN NUMBER);
--
FUNCTION gnrt_ss_prfrmnce_apprsl_ff
  (
   p_business_group_id IN NUMBER DEFAULT NULL
  ) RETURN BOOLEAN;
--
PROCEDURE gnrt_ss_prfrmnce_apprsl_ff
  (
   errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  ,p_business_group_id IN NUMBER DEFAULT NULL
  );
--
FUNCTION check_fast_formula_exists (
                             p_business_group_id NUMBER
                            ,p_formula_name VARCHAR2) RETURN BOOLEAN;
--
PROCEDURE delete_performance_formula(p_business_group_id IN NUMBER);
--
PROCEDURE delete_all_prfrmnc_formulas;
--
PROCEDURE fastformula_check_full
  (
   errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  );
--
PROCEDURE fastformula_check_incr
  (
   errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  );
--
END hri_bpl_fast_formula;

 

/
