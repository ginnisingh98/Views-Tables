--------------------------------------------------------
--  DDL for Package XLA_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TRANSFER_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaaptrn.pkh 120.4.12010000.2 2008/08/06 21:03:38 sbhaskar ship $ */
-------------------------------------------------------------------------------
-- constants for caller routines
-------------------------------------------------------------------------------
C_ACCTPROG_BATCH      CONSTANT VARCHAR2(80) := 'ACCTPROG_BATCH';
C_ACCTPROG_DOCUMENT   CONSTANT VARCHAR2(80) := 'ACCTPROG_DOCUMENT';
C_TP_MERGE            CONSTANT VARCHAR2(80) := 'THIRD_PARTY_MERGE';
C_MPA_COMPLETE        CONSTANT VARCHAR2(80) := 'MPA_COMPLETE';

g_arr_group_id        xla_ae_journal_entry_pkg.t_array_Num;

PROCEDURE gl_transfer_main(p_application_id         NUMBER
                          ,p_transfer_mode          VARCHAR2
                          ,p_ledger_id              NUMBER
                          ,p_securiy_id_int_1       NUMBER     DEFAULT NULL
                          ,p_securiy_id_int_2       NUMBER     DEFAULT NULL
                          ,p_securiy_id_int_3       NUMBER     DEFAULT NULL
                          ,p_securiy_id_char_1      VARCHAR2   DEFAULT NULL
                          ,p_securiy_id_char_2      VARCHAR2   DEFAULT NULL
                          ,p_securiy_id_char_3      VARCHAR2   DEFAULT NULL
                          ,p_valuation_method       VARCHAR2   DEFAULT NULL
                          ,p_process_category       VARCHAR2   DEFAULT null
                          ,p_accounting_batch_id    NUMBER     DEFAULT NULL
                          ,p_entity_id              NUMBER     DEFAULT NULL
                          ,p_batch_name             VARCHAR2   DEFAULT NULL
                          ,p_end_date               DATE       DEFAULT NULL
                          ,p_submit_gl_post         VARCHAR2   DEFAULT 'N'
                          ,p_caller                 VARCHAR2   DEFAULT C_ACCTPROG_BATCH
                         );
END xla_transfer_pkg;

/
