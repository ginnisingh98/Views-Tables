--------------------------------------------------------
--  DDL for Package XLA_MPA_JLT_ADR_ASSGNS_F_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_MPA_JLT_ADR_ASSGNS_F_PVT" AUTHID CURRENT_USER AS
/* $Header: xlathmad.pkh 120.0 2005/06/24 01:29:45 eklau noship $ */

PROCEDURE Insert_Row (
    x_rowid				IN OUT NOCOPY VARCHAR2,
    x_amb_context_code			IN VARCHAR2,
    x_application_id			IN NUMBER,
    x_event_class_code			IN VARCHAR2,
    x_event_type_code			IN VARCHAR2,
    x_line_definition_owner_code	IN VARCHAR2,
    x_line_definition_code		IN VARCHAR2,
    x_accounting_line_type_code		IN VARCHAR2,
    x_accounting_line_code		IN VARCHAR2,
    x_mpa_accounting_line_type_co	IN VARCHAR2,
    x_mpa_accounting_line_code		IN VARCHAR2,
    x_flexfield_segment_code		IN VARCHAR2,
    x_segment_rule_appl_id		IN NUMBER,
    x_segment_rule_type_code		IN VARCHAR2,
    x_segment_rule_code			IN VARCHAR2,
    x_inherit_adr_flag			IN VARCHAR2,
    x_creation_date			IN DATE,
    x_created_by			IN NUMBER,
    x_last_update_date			IN DATE,
    x_last_updated_by			IN NUMBER,
    x_last_update_login			IN NUMBER
);


PROCEDURE Update_Row (
    x_amb_context_code			IN VARCHAR2,
    x_application_id			IN NUMBER,
    x_event_type_code			IN VARCHAR2,
    x_line_definition_owner_code	IN VARCHAR2,
    x_line_definition_code		IN VARCHAR2,
    x_accounting_line_type_code		IN VARCHAR2,
    x_accounting_line_code		IN VARCHAR2,
    x_mpa_accounting_line_type_co	IN VARCHAR2,
    x_mpa_accounting_line_code		IN VARCHAR2,
    x_flexfield_segment_code		IN VARCHAR2,
    x_segment_rule_appl_id		IN NUMBER,
    x_segment_rule_type_code		IN VARCHAR2,
    x_segment_rule_code			IN VARCHAR2,
    x_inherit_adr_flag			IN VARCHAR2,
    x_last_update_date			IN DATE,
    x_last_updated_by			IN NUMBER,
    x_last_update_login			IN NUMBER
);


PROCEDURE Lock_Row (
    x_amb_context_code			IN VARCHAR2,
    x_application_id			IN NUMBER,
    x_event_type_code			IN VARCHAR2,
    x_line_definition_owner_code	IN VARCHAR2,
    x_line_definition_code		IN VARCHAR2,
    x_accounting_line_type_code		IN VARCHAR2,
    x_accounting_line_code		IN VARCHAR2,
    x_mpa_accounting_line_type_co	IN VARCHAR2,
    x_mpa_accounting_line_code		IN VARCHAR2,
    x_flexfield_segment_code		IN VARCHAR2,
    x_segment_rule_appl_id		IN NUMBER,
    x_segment_rule_type_code		IN VARCHAR2,
    x_segment_rule_code			IN VARCHAR2,
    x_inherit_adr_flag			IN VARCHAR2
);


PROCEDURE Delete_Row (
    x_amb_context_code			IN VARCHAR2,
    x_application_id			IN NUMBER,
    x_event_type_code			IN VARCHAR2,
    x_line_definition_owner_code	IN VARCHAR2,
    x_line_definition_code		IN VARCHAR2,
    x_accounting_line_type_code		IN VARCHAR2,
    x_accounting_line_code		IN VARCHAR2,
    x_mpa_accounting_line_type_co	IN VARCHAR2,
    x_mpa_accounting_line_code		IN VARCHAR2,
    x_flexfield_segment_code		IN VARCHAR2
);


END XLA_MPA_JLT_ADR_ASSGNS_F_PVT;
 

/
