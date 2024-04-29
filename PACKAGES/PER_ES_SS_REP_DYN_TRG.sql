--------------------------------------------------------
--  DDL for Package PER_ES_SS_REP_DYN_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ES_SS_REP_DYN_TRG" AUTHID CURRENT_USER AS
/* $Header: peesssdy.pkh 115.3 2004/03/16 22:49:44 srjanard noship $ */

    PROCEDURE asg_check_update(p_assignment_id                  NUMBER,
                               p_assignment_type                VARCHAR2,
                               p_effective_start_date           DATE,
                               p_effective_end_date             DATE,
                               p_asg_status_type_id             NUMBER,
                               p_employment_category            VARCHAR2,
                               p_soft_coding_keyflex_id         NUMBER,
                               p_primary_flag                   VARCHAR);
    PROCEDURE asg_check_insert(p_assignment_id                  NUMBER,
                               p_assignment_type                varchar2,
                               p_effective_start_date           DATE,
                               p_effective_end_date             DATE,
                               p_asg_status_type_id             NUMBER,
                               p_employment_category            VARCHAR2,
                               p_soft_coding_keyflex_id         NUMBER,
                               p_primary_flag                   VARCHAR);
    PROCEDURE element_check_insert
                              (p_element_entry_id               NUMBER,
                               p_effective_start_date           DATE,
                               p_effective_end_date             DATE,
                               p_epigraph_code                  VARCHAR2,
                               p_input_value_id                 NUMBER);
    PROCEDURE  element_check_update
                              (p_element_entry_id               NUMBER,
                               p_effective_start_date           DATE,
                               p_effective_end_date             DATE,
                               p_epigraph_code                  VARCHAR2,
                               p_input_value_id                 NUMBER);

    FUNCTION   get_assignment_id
                              (p_element_entry_id NUMBER) RETURN NUMBER;
    FUNCTION   get_business_group_id
                              (p_element_entry_id NUMBER) RETURN NUMBER;

END PER_ES_SS_REP_DYN_TRG;

 

/
