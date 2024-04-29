--------------------------------------------------------
--  DDL for Package POS_BATCH_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_BATCH_IMPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: POSSUPIMPS.pls 120.0.12010000.6 2011/08/04 11:58:53 yaoli noship $ */

PROCEDURE import_batch
  (
    errbuf                   OUT NOCOPY VARCHAR2,
    retcode                  OUT NOCOPY VARCHAR2,
    p_batch_id               IN NUMBER,
    p_import_run_option      IN VARCHAR2,
    p_run_batch_dedup        IN VARCHAR2,
    p_batch_dedup_rule_id    IN NUMBER,
    p_batch_dedup_action     IN VARCHAR2,
    p_run_addr_val           IN VARCHAR2,
    p_run_registry_dedup     IN VARCHAR2,
    p_registry_dedup_rule_id IN NUMBER,
    p_run_automerge          IN VARCHAR2 := 'N',
    p_generate_fuzzy_key     IN VARCHAR2 := 'Y',
    p_import_uda_only        IN VARCHAR2 := 'N'
  );

  FUNCTION chk_vendor_num_nmbering_method RETURN VARCHAR2;

  FUNCTION get_party_id
  (
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2
  ) RETURN NUMBER;

END pos_batch_import_pkg;

/
