--------------------------------------------------------
--  DDL for Package PAY_GB_PAYROLL_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_PAYROLL_RULES" AUTHID CURRENT_USER AS
/* $Header: pygbprlr.pkh 120.3.12000000.1 2007/02/19 10:35:12 ajeyam noship $ */

   PROCEDURE validate_update(p_effective_date IN DATE
                             ,p_datetrack_mode IN VARCHAR2
                             ,p_payroll_id IN NUMBER
                             ,p_payroll_name IN VARCHAR2
                             ,p_soft_coding_keyflex_id_in in NUMBER);

   PROCEDURE validate_delete(p_effective_date IN DATE
                             ,p_datetrack_mode IN VARCHAR2
                             ,p_payroll_id IN NUMBER);
END;

 

/
