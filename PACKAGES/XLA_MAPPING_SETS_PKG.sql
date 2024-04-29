--------------------------------------------------------
--  DDL for Package XLA_MAPPING_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_MAPPING_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamdms.pkh 120.5 2004/11/02 18:59:02 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_mapping_sets_pkg                                               |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Mapping Sets package                                           |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_mapping_set_details                                            |
|                                                                       |
| Deletes all details of the mapping set                                |
|                                                                       |
+======================================================================*/

PROCEDURE delete_mapping_set_details
  (p_mapping_set_code                IN VARCHAR2
  ,p_amb_context_code                IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| mapping_set_in_use                                                    |
|                                                                       |
| Returns true if the mapping set is in use by an account derivation    |
| rule                                                                  |
|                                                                       |
+======================================================================*/

FUNCTION mapping_set_in_use
  (p_event                            IN VARCHAR2
  ,p_mapping_set_code                 IN VARCHAR2
  ,p_amb_context_code                 IN VARCHAR2
  ,p_application_id                   IN OUT NOCOPY NUMBER
  ,p_segment_rule_code                IN OUT NOCOPY VARCHAR2
  ,p_segment_rule_type_code           IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| mapping_set_is_locked                                                 |
|                                                                       |
| Returns true if the mapping set is being used by a locked product rule|
|                                                                       |
+======================================================================*/

FUNCTION mapping_set_is_locked
  (p_mapping_set_code                IN  VARCHAR2
  ,p_amb_context_code                IN  VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_product_rule                                                |
|                                                                       |
| Wrapper for uncompile_definitions                                     |
| Provided for backward-compatibility, to be obsoleted                  |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_product_rule
  (p_mapping_set_code                IN  VARCHAR2
  ,p_amb_context_code                IN  VARCHAR2
  ,p_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type               IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Sets status of assigned application accounting definitions and        |
| journal lines definitions to uncompiled                               |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_mapping_set_code                IN VARCHAR2
  ,p_amb_context_code                IN VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_tran_acct_def                                               |
|                                                                       |
|                                                                       |
| Returns true if all the tads  using the mapping set are               |
| uncompiled                                                            |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_tran_acct_def
  (p_mapping_set_code                IN  VARCHAR2
  ,p_amb_context_code                IN  VARCHAR2
  ,p_trx_acct_def                    IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type               IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_mapping_sets_pkg;
 

/
