--------------------------------------------------------
--  DDL for Package AR_CREATE_ACCTING_SRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CREATE_ACCTING_SRS" AUTHID CURRENT_USER AS
/*$Header: ARSACCTS.pls 120.3.12000000.2 2007/08/22 13:19:05 sgnagara ship $*/

PROCEDURE submission (
 errbuf           OUT NOCOPY VARCHAR2
,retcode          OUT NOCOPY NUMBER
--
,p_report_mode    IN  VARCHAR2 DEFAULT 'S'
,p_max_workers    IN  NUMBER   DEFAULT 2
,p_interval       IN  NUMBER   DEFAULT 60
,p_max_wait       IN  NUMBER   DEFAULT 180
---
,p_request_id     IN  NUMBER   DEFAULT NULL
,p_entity_id      IN  NUMBER   DEFAULT NULL
,p_src_app        IN  NUMBER   DEFAULT NULL
,p_app            IN  NUMBER   DEFAULT NULL
,p_dummy_param0   IN  VARCHAR2 DEFAULT NULL
,p_ledger         IN  NUMBER
,p_proc_categ     IN  VARCHAR2 DEFAULT NULL
,p_end_date       IN  VARCHAR2
,p_create_acct    IN  VARCHAR2
,p_dummy_param1   IN  VARCHAR2 DEFAULT NULL
,p_acct_mode      IN  VARCHAR2
,p_dummy_param2   IN  VARCHAR2 DEFAULT NULL
,p_errors_only    IN  VARCHAR2
,p_report         IN  VARCHAR2
,p_transf_gl      IN  VARCHAR2
,p_dummy_param3   IN  VARCHAR2 DEFAULT NULL
,p_post_to_gl     IN  VARCHAR2
,p_gl_batch_name  IN  VARCHAR2 DEFAULT NULL
,p_mixed_currency IN  NUMBER   DEFAULT NULL
,p_val_meth       IN  VARCHAR2 DEFAULT NULL
,p_sec_id_int_1   IN  NUMBER   DEFAULT NULL
,p_sec_id_int_2   IN  NUMBER   DEFAULT NULL
,p_sec_id_int_3   IN  NUMBER   DEFAULT NULL
,p_sec_id_char_1  IN  VARCHAR2 DEFAULT NULL
,p_sec_id_char_2  IN  VARCHAR2 DEFAULT NULL
,p_sec_id_char_3  IN  VARCHAR2 DEFAULT NULL
--BUG#5391740
,p_include_user_trx_id_flag     IN VARCHAR2 DEFAULT 'N'
,p_include_user_trx_identifiers IN VARCHAR2 DEFAULT NULL
,p_debug_flag                   IN VARCHAR2 DEFAULT NULL
,p_user_id                      IN NUMBER   DEFAULT fnd_profile.value('USER_ID')
);

END;

 

/
