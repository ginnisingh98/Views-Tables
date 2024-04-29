--------------------------------------------------------
--  DDL for Package PQP_GB_AD_EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_AD_EE" AUTHID CURRENT_USER AS
/* $Header: pqgbadee.pkh 120.0.12010000.5 2009/05/28 04:26:45 jvaradra ship $ */
-----------------------------------------------------------------------------
-- OPEN_CM_ELE_ENTRIES
-----------------------------------------------------------------------------
PROCEDURE  open_cm_ele_entries( p_assignment_id_o    IN NUMBER
                              ,p_effective_date     IN DATE
                              ,p_effective_end_date IN DATE
                              ,p_element_entry_id   IN NUMBER
                              ,p_datetrack_mode     IN VARCHAR2);



PROCEDURE  create_term_ele_entries ( p_assignment_id    IN NUMBER
                               ,p_effective_date        IN DATE
                               ,p_effective_start_date  IN DATE
                               ,p_effective_end_date    IN DATE
                               ,p_element_entry_id      IN NUMBER
                               ,p_element_link_id       IN NUMBER
                               ,p_element_type_id       IN NUMBER
                               );

--For bug 7013325
PROCEDURE UPDATE_PSI_ASS_DFF_COL(
                          p_effective_start_date        date,
                          p_element_entry_id            number,
                          p_assignment_id               number,
                          p_element_type_id             Number
                        );

--For bug 7294977: Start
PROCEDURE AI_VAL_REF_COURT_ORDER(
                          p_effective_start_date        IN DATE
                         ,p_element_entry_id            IN NUMBER
                         ,p_element_type_id             IN NUMBER
                        );


PROCEDURE AU_VAL_REF_COURT_ORDER(
                          p_effective_date              IN DATE
                         ,p_datetrack_mode              IN VARCHAR2
                         ,p_effective_start_date        IN DATE
                         ,p_element_entry_id            IN NUMBER
                         ,p_element_type_id_o           IN NUMBER
                        );
--For bug 7294977: End

------------------------
-- BEGIN For Bug 8485686
------------------------

g_global_paye_validation VARCHAR2(1) := 'Y';

g_first_assignment_id NUMBER :=-1;

g_first_assignment VARCHAR2(1) := 'Y';

TYPE g_element_entry_rec is record(eeid NUMBER(30),
                                   aid NUMBER(30));

TYPE g_element_entry_tab IS TABLE OF g_element_entry_rec INDEX BY BINARY_INTEGER;

g_element_entry_rec_tab g_element_entry_tab;

l_input_value_id1 number;
l_tax_code        VARCHAR2(60);
l_input_value_id2 number;
l_d_tax_basis VARCHAR2(60);
l_input_value_id3 number;
l_d_refundable VARCHAR2(60);
l_input_value_id4 number;
l_d_pay_previous VARCHAR2(60);
l_input_value_id5 number;
l_d_tax_previous VARCHAR2(60);
l_input_value_id6 number;
l_authority VARCHAR2(60);
l_ele_information1 VARCHAR2(150);
l_ele_information2 VARCHAR2(150);

------------------------
-- END For Bug 8485686
------------------------

END pqp_gb_ad_ee;

/
