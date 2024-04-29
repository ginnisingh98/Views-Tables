--------------------------------------------------------
--  DDL for Package XLA_LINE_DEFN_ADR_ASSGNS_F_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_LINE_DEFN_ADR_ASSGNS_F_PVT" AUTHID CURRENT_USER AS
/* $Header: xlathlad.pkh 120.5 2005/04/12 20:11:53 masada ship $ */

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_line_definition_owner_code       IN VARCHAR2
  ,x_line_definition_code             IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_inherit_adr_flag                 IN VARCHAR2
  ,x_segment_rule_appl_id             IN NUMBER
  ,x_segment_rule_type_code           IN VARCHAR2
  ,x_segment_rule_code                IN VARCHAR2
  ,x_side_code                        IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_line_definition_owner_code       IN VARCHAR2
  ,x_line_definition_code             IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_inherit_adr_flag                 IN VARCHAR2
  ,x_segment_rule_appl_id             IN NUMBER
  ,x_segment_rule_type_code           IN VARCHAR2
  ,x_segment_rule_code                IN VARCHAR2
  ,x_side_code                        IN VARCHAR2);

PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_amb_context_code                 IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_event_type_code                  IN VARCHAR2
 ,x_line_definition_owner_code       IN VARCHAR2
 ,x_line_definition_code             IN VARCHAR2
 ,x_accounting_line_type_code        IN VARCHAR2
 ,x_accounting_line_code             IN VARCHAR2
 ,x_flexfield_segment_code           IN VARCHAR2
 ,x_inherit_adr_flag                 IN VARCHAR2
 ,x_segment_rule_appl_id             IN NUMBER
 ,x_segment_rule_type_code           IN VARCHAR2
 ,x_segment_rule_code                IN VARCHAR2
 ,x_side_code                        IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_line_definition_owner_code       IN VARCHAR2
  ,x_line_definition_code             IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_side_code                        IN VARCHAR2);

END xla_line_defn_adr_assgns_f_pvt;
 

/
