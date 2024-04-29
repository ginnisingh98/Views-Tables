--------------------------------------------------------
--  DDL for Package XLA_RPT_SARDLR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_RPT_SARDLR_PKG" AUTHID CURRENT_USER AS
/* $Header: xlasardlr.pkh 120.0.12010000.4 2009/09/14 10:50:01 kapkumar noship $ */
/*======================================================================+
|             Copyright (c) 2009-2010 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_rpt_sardlr_pkg                                                     |
|                                                                       |
|                                                                       |
| DESCRIPTION                                                           |
|  Package for Subledger Accounting Rules Detail Listing Report         |
|  to retrieve line-level information for ADR details                   |
|                                                                       |
| HISTORY                                                               |
|    AUG-09  Kapil Kumar                          Created               |
|                                                                       |
+======================================================================*/


--report input parameters declared as global variables:

P_APPLICATION_ID                 NUMBER;
P_SLAM_CODE                      VARCHAR2(250);
P_SLAM_TYPE_CODE                 VARCHAR2(250);
P_EVENT_CLASS_CODE               VARCHAR2(250);
P_EVENT_TYPE_CODE                VARCHAR2(250);
P_AMB_CONTEXT_CODE               VARCHAR2(250);
P_EVENT_CLASS_NAME               VARCHAR2(250);
P_EVENT_TYPE_NAME                VARCHAR2(250);

P_APPLICATION_NAME               VARCHAR2(250);
P_SLAM_NAME                      VARCHAR2(250);
P_SLAM_TYPE_NAME                 VARCHAR2(250);

FUNCTION  beforeReport  RETURN BOOLEAN;

FUNCTION populate_fields
    (value_type_code                IN  VARCHAR2,
     value_source_application_id    IN  NUMBER,
     value_source_type_code         IN  VARCHAR2,
     value_source_code              IN  VARCHAR2,
     value_mapping_set_code         IN  VARCHAR2,
     value_code_combination_id      IN  NUMBER,
     amb_context_code               IN  VARCHAR2,
     value_segment_rule_appl_id     IN  NUMBER,
     value_segment_rule_type_code   IN  VARCHAR2,
     value_segment_rule_code        IN  VARCHAR2,
     flexfield_assign_mode_code     IN  VARCHAR2,
     value_constant                 IN  VARCHAR2,
     flex_value_set_id              IN  NUMBER,
     input_source_code              IN  VARCHAR2,
     input_source_application_id    IN  NUMBER,
     input_source_type_code         IN  VARCHAR2,
     value_flexfield_segment_code   IN  VARCHAR2,
     transaction_coa_id             IN  NUMBER,
     accounting_coa_id              IN  NUMBER,
     p_mode                         IN  NUMBER
    )
RETURN VARCHAR2;

END XLA_RPT_SARDLR_PKG;

/
