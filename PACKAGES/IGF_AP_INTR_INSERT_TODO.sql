--------------------------------------------------------
--  DDL for Package IGF_AP_INTR_INSERT_TODO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_INTR_INSERT_TODO" AUTHID CURRENT_USER AS
/* $Header: IGFAP21S.pls 120.1 2005/09/08 14:38:06 appldev noship $ */


PROCEDURE main ( errbuf                        IN OUT NOCOPY VARCHAR2,
                  retcode                       IN OUT NOCOPY VARCHAR2,
                  x_todo_type                   IN VARCHAR2,
                  x_todo_sub_type               IN VARCHAR2,
                  x_person_id                   IN NUMBER,
                  x_acad_ci_cal_type            IN VARCHAR2,
                  x_acad_ci_sequence_number     IN NUMBER,
                  x_key1                        IN VARCHAR2,
                  x_key2                        IN VARCHAR2,
                  x_key3                        IN VARCHAR2,
                  x_key4                        IN VARCHAR2,
                  x_key5                        IN VARCHAR2,
                  x_key6                        IN VARCHAR2,
                  x_key7                        IN VARCHAR2,
                  x_key8                        IN VARCHAR2,
                  x_old_value1                  IN VARCHAR2,
                  x_new_value1                  IN VARCHAR2,
                  x_old_value2                  IN VARCHAR2,
                  x_new_value2                  IN VARCHAR2,
                  x_old_value3                  IN VARCHAR2,
                  x_new_value3                  IN VARCHAR2,
                  x_old_value4                  IN VARCHAR2,
                  x_new_value4                  IN VARCHAR2,
                  x_old_value5                  IN VARCHAR2,
                  x_new_value5                  IN VARCHAR2,
                  p_org_id                      IN VARCHAR2);



END igf_ap_intr_insert_todo;

 

/
