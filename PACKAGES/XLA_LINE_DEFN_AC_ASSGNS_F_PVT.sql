--------------------------------------------------------
--  DDL for Package XLA_LINE_DEFN_AC_ASSGNS_F_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_LINE_DEFN_AC_ASSGNS_F_PVT" AUTHID CURRENT_USER AS
/* $Header: xlathlac.pkh 120.0 2004/11/04 01:38:30 wychan noship $ */

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
  ,x_analy_criterion_type_code        IN VARCHAR2
  ,x_analy_criterion_code             IN VARCHAR2
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
  ,x_analy_criterion_type_code        IN VARCHAR2
  ,x_analy_criterion_code             IN VARCHAR2);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_line_definition_owner_code       IN VARCHAR2
  ,x_line_definition_code             IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_analy_criterion_type_code        IN VARCHAR2
  ,x_analy_criterion_code             IN VARCHAR2);

END xla_line_defn_ac_assgns_f_pvt;
 

/
