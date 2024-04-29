--------------------------------------------------------
--  DDL for Package XLA_LINE_DEFN_JLT_ASSGNS_F_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_LINE_DEFN_JLT_ASSGNS_F_PVT" AUTHID CURRENT_USER AS
/* $Header: xlathljl.pkh 120.4 2005/07/06 20:45:18 eklau ship $ */

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
  ,x_inherit_desc_flag                IN VARCHAR2
  ,x_description_type_code            IN VARCHAR2
  ,x_description_code                 IN VARCHAR2
  ,x_active_flag                      IN VARCHAR2
  ,x_mpa_header_desc_code             IN VARCHAR2
  ,x_mpa_header_desc_type_code        IN VARCHAR2
  ,x_mpa_num_je_code                  IN VARCHAR2
  ,x_mpa_gl_dates_code                IN VARCHAR2
  ,x_mpa_proration_code               IN VARCHAR2
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
  ,x_inherit_desc_flag                IN VARCHAR2
  ,x_description_type_code            IN VARCHAR2
  ,x_description_code                 IN VARCHAR2
  ,x_active_flag                      IN VARCHAR2
  ,x_mpa_header_desc_code             IN VARCHAR2
  ,x_mpa_header_desc_type_code        IN VARCHAR2
  ,x_mpa_num_je_code                  IN VARCHAR2
  ,x_mpa_gl_dates_code                IN VARCHAR2
  ,x_mpa_proration_code               IN VARCHAR2);

PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_amb_context_code                 IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_event_type_code                  IN VARCHAR2
 ,x_line_definition_owner_code       IN VARCHAR2
 ,x_line_definition_code             IN VARCHAR2
 ,x_accounting_line_type_code        IN VARCHAR2
 ,x_accounting_line_code             IN VARCHAR2
 ,x_inherit_desc_flag                IN VARCHAR2
 ,x_description_type_code            IN VARCHAR2
 ,x_description_code                 IN VARCHAR2
 ,x_active_flag                      IN VARCHAR2
 ,x_mpa_header_desc_code             IN VARCHAR2
 ,x_mpa_header_desc_type_code        IN VARCHAR2
 ,x_mpa_num_je_code                  IN VARCHAR2
 ,x_mpa_gl_dates_code                IN VARCHAR2
 ,x_mpa_proration_code               IN VARCHAR2
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
  ,x_accounting_line_code             IN VARCHAR2);

END xla_line_defn_jlt_assgns_f_pvt;
 

/
