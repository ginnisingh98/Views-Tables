--------------------------------------------------------
--  DDL for Package PQP_TIAALOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_TIAALOD_PKG" AUTHID CURRENT_USER AS
/* $Header: pqtiaald.pkh 120.0.12000000.1 2007/01/16 04:34:35 appldev noship $ */
g_proc_name                varchar2(80) := ' pqp_tiaalod_pkg.';
-- ---------------------------------------------------------------------
-- |--------------------------< Load_Data >-----------------------------|
-- ---------------------------------------------------------------------
PROCEDURE load_data
           (pactid           IN VARCHAR2
           ,chnkno           IN NUMBER
           ,ppa_finder       IN VARCHAR2
           ,p_dimension_name IN VARCHAR2);

-- ---------------------------------------------------------------------
-- |--------------------------< Chk_Neg_Amt >---------------------------|
-- ---------------------------------------------------------------------
PROCEDURE Chk_Neg_Amt
           (p_payroll_action_id in number);

END pqp_tiaalod_pkg;

 

/
