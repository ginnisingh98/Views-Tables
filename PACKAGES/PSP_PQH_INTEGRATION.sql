--------------------------------------------------------
--  DDL for Package PSP_PQH_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PQH_INTEGRATION" AUTHID CURRENT_USER as
--$Header: PSPENPQHS.pls 115.3 2002/11/19 12:26:16 ddubey ship $

TYPE t_num_15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_num_15d2_type IS TABLE OF NUMBER(15,2) INDEX BY BINARY_INTEGER;

TYPE encumbrance_table_rec_col IS RECORD
(
r_element_type_id t_num_15_type,
r_gl_enc_amount   t_num_15d2_type,
r_gms_enc_amount  t_num_15d2_type);



TYPE assignment_enc_ld_col is RECORD
(
r_assignment_id        t_num_15_type,
r_element_type_id      t_num_15_type,
r_encumbrance_amount   t_num_15d2_type,
r_begin_time_period_id t_num_15_type,
r_end_time_period_id   t_num_15_type);



PROCEDURE  get_asg_encumbrances(p_assignment_id IN NUMBER,
                                p_encumbrance_start_date IN  DATE,
                                p_encumbrance_end_date  IN  DATE,
                                p_encumbrance_table OUT NOCOPY ENCUMBRANCE_TABLE_REC_COL,
                                p_asg_psp_encumbered OUT NOCOPY BOOLEAN,
                                p_return_status OUT NOCOPY VARCHAR2);

PROCEDURE get_encumbrance_details ( p_calling_process IN VARCHAR2,
                                    p_assignment_enc_ld_table OUT NOCOPY assignment_enc_ld_col,
                                    p_psp_encumbered  OUT NOCOPY BOOLEAN,
                                    p_return_status OUT NOCOPY VARCHAR2);
END PSP_PQH_INTEGRATION;

 

/
