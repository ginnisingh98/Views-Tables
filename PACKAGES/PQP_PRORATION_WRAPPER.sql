--------------------------------------------------------
--  DDL for Package PQP_PRORATION_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PRORATION_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: pqprowiz.pkh 115.14 2002/03/11 11:47:57 pkm ship        $ */
PROCEDURE standard_proc
(
    business_group     IN VARCHAR2 DEFAULT NULL ,
    pay_mode_grade     IN VARCHAR2 DEFAULT NULL ,
    pay_mode_scale     IN VARCHAR2 DEFAULT NULL ,
    pay_mode_salary    IN VARCHAR2 DEFAULT NULL ,
    teacher_england    IN VARCHAR2 DEFAULT NULL ,
    teacher_scotland   IN VARCHAR2 DEFAULT NULL ,
    startdate          IN VARCHAR2 DEFAULT NULL ,
    basename           IN VARCHAR2 DEFAULT NULL ,
    sal_rep_name       IN VARCHAR2 DEFAULT NULL ,
    grade_rep_name     IN VARCHAR2 DEFAULT NULL ,
    ps_rep_name        IN VARCHAR2 DEFAULT NULL ,
    p_ele_gr_name      IN VARCHAR2 DEFAULT NULL ,
    p_ele_psr_name     IN VARCHAR2 DEFAULT NULL

) ;
PROCEDURE proration_group_proc
(
    p_pgname             IN VARCHAR2   DEFAULT NULL,
    p_pg_startdate       IN VARCHAR2   DEFAULT NULL,
    p_pggrd              IN VARCHAR2   DEFAULT NULL,
    p_pggrdrt            IN VARCHAR2   DEFAULT NULL,
    p_pgchgpysc          IN VARCHAR2   DEFAULT NULL,
    p_pgchrtpysc         IN VARCHAR2   DEFAULT NULL,
    p_pgchgsal           IN VARCHAR2   DEFAULT NULL,
    p_pgtermemp          IN VARCHAR2   DEFAULT NULL,
    p_pgnewhre           IN VARCHAR2   DEFAULT NULL,
    p_pgstchenea         IN VARCHAR2   DEFAULT NULL,
    p_pgstchended        IN VARCHAR2   DEFAULT NULL,
    p_pgchgloc           IN VARCHAR2   DEFAULT NULL,
    p_business_group_pg  IN VARCHAR2   DEFAULT NULL
);
PROCEDURE element_proc
(
    p_ele_startdate       IN VARCHAR2   DEFAULT NULL,
    p_business_group      IN VARCHAR2   DEFAULT NULL,
    p_ele_name            IN VARCHAR2   DEFAULT NULL,
    p_ele_desc            IN VARCHAR2   DEFAULT NULL,
    p_ele_terminate       IN VARCHAR2   DEFAULT NULL,
    p_ele_uenterable      IN VARCHAR2   DEFAULT NULL,
    p_ele_addentry        IN VARCHAR2   DEFAULT NULL,
    p_ele_payment         IN VARCHAR2   DEFAULT NULL,
    p_ele_recur           IN VARCHAR2   DEFAULT NULL,
    p_ele_priclass        IN VARCHAR2   DEFAULT NULL,
    p_ele_multientry      IN VARCHAR2   DEFAULT NULL,
    p_ele_repname         IN VARCHAR2   DEFAULT NULL,
    p_ele_pg              IN VARCHAR2   DEFAULT NULL,
    p_ele_teach_eng       IN VARCHAR2   DEFAULT NULL,
    p_ele_teach_scot      IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_td        IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_psv       IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_qualifier IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_fte       IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_sh        IN VARCHAR2   DEFAULT NULL

);
PROCEDURE input_value_proc
(
    p_ipvalue_name        IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_uom         IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_required    IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_uenterble   IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_dfltval     IN VARCHAR2      DEFAULT NULL,
    p_ipvalue_lkpval      IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_hotdflt     IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_formula     IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_minimum     IN VARCHAR2     DEFAULT NULL,
    p_ipvalue_maximum     IN VARCHAR2     DEFAULT NULL,
    p_ipvalue_error       IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_dispseq     IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_dbitem      IN VARCHAR2   DEFAULT NULL,
    p_business_group_ipv  IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_startdate   IN VARCHAR2   DEFAULT NULL,
    p_ele_name_ipv        IN VARCHAR2   DEFAULT NULL
);
PROCEDURE formula_proc
(
    p_business_group_fr     IN VARCHAR2   DEFAULT NULL,
    p_ele_name_fr           IN VARCHAR2   DEFAULT NULL,
    p_ele_payment_fr        IN VARCHAR2   DEFAULT NULL,
    p_ele_startdate_fr      IN VARCHAR2   DEFAULT NULL,
    p_ele_teach_eng_fr      IN VARCHAR2   DEFAULT NULL,
    p_ele_teach_scot_fr     IN VARCHAR2   DEFAULT NULL,
    p_ele_priclass_fr       IN VARCHAR2   DEFAULT NULL
);
FUNCTION get_contract_type
(
    p_assignment_id        IN NUMBER,
    p_effective_date       IN DATE
) RETURN VARCHAR;
END pqp_proration_wrapper;

 

/
