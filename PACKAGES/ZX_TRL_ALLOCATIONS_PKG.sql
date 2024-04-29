--------------------------------------------------------
--  DDL for Package ZX_TRL_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TRL_ALLOCATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: zxriallocatnpkgs.pls 120.13.12010000.2 2008/11/12 12:43:01 spasala ship $ */

    TYPE trx_number_tbl_type      IS TABLE OF zx_lines.trx_number%type INDEX BY BINARY_INTEGER;
    TYPE trx_id_tbl_type          IS TABLE OF zx_lines.trx_id%type INDEX BY BINARY_INTEGER;
    TYPE trx_line_id_tbl_type     IS TABLE OF zx_lines.trx_line_id%type INDEX BY BINARY_INTEGER;
    TYPE trx_level_type_tbl_type  IS TABLE OF zx_lines.trx_level_type%type INDEX BY BINARY_INTEGER;
    TYPE trx_line_date_tbl_type   IS TABLE OF zx_lines.trx_line_date%type INDEX BY BINARY_INTEGER;
    TYPE trx_line_number_tbl_type IS TABLE OF zx_lines.trx_line_number%type INDEX BY BINARY_INTEGER;
    TYPE line_amt_tbl_type        IS TABLE OF zx_lines.line_amt%type INDEX BY BINARY_INTEGER;
    TYPE trx_line_description_tbl_type  IS TABLE OF zx_transaction_lines.trx_line_description%type INDEX BY BINARY_INTEGER;
    Type trx_allocate_tbl_type IS TABLE OF VARCHAR2(10) INDEX BY VARCHAR2(1000);

    TYPE trx_record_tbl_type IS RECORD (p_trx_number      trx_number_tbl_type,
                                        p_trx_id          trx_id_tbl_type,
                                        p_trx_line_id     trx_line_id_tbl_type,
                                        p_trx_level_type  trx_level_type_tbl_type,
                                        p_trx_line_description trx_line_description_tbl_type,
                                        p_trx_line_date   trx_line_date_tbl_type,
                                        p_trx_line_number trx_line_number_tbl_type,
                                        p_line_amt        line_amt_tbl_type);

    g_trx_record_tbl   trx_record_tbl_type;
    g_trx_allocate_tbl trx_allocate_tbl_type;

  PROCEDURE Insert_Row
       (X_Rowid                    IN OUT NOCOPY VARCHAR2,
        p_summary_tax_line_id                    NUMBER,
        p_internal_organization_id               NUMBER,
        p_application_id                         NUMBER,
        p_entity_code                            VARCHAR2,
        p_event_class_code                       VARCHAR2,
        p_event_type_code                        VARCHAR2,
        p_trx_line_number                        NUMBER,--
        p_trx_id                                 NUMBER,
        p_trx_number                             VARCHAR2,--
        p_trx_line_id                            NUMBER,--
        p_trx_level_type                         VARCHAR2,
        --p_tax_line_number                        NUMBER,--
        p_line_amt                               NUMBER,--
        p_trx_line_date                          DATE,--
        --p_tax_regime_id                          NUMBER,
        p_tax_regime_code                        VARCHAR2,
        --p_tax_id                                 NUMBER,
        p_tax                                    VARCHAR2,
        p_tax_jurisdiction_code                  VARCHAR2,
        --p_tax_status_id                          NUMBER,
        p_tax_status_code                        VARCHAR2,
        p_tax_rate_id                            NUMBER,
        p_tax_rate_code                          VARCHAR2,
        p_tax_rate                               NUMBER,
        p_tax_amt                                NUMBER,
        p_enabled_record                         VARCHAR2,
        p_manually_entered_flag                  VARCHAR2,
        p_content_owner_id                       NUMBER,
        p_record_type_code                       VARCHAR2,
        p_last_manual_entry                      VARCHAR2,
        p_trx_line_amt                           NUMBER,
        p_tax_amt_included_flag                  VARCHAR2,
        p_self_assessed_flag                     VARCHAR2,
        p_tax_only_line_flag                     VARCHAR2,
        p_created_by                             NUMBER,
        p_creation_date                          DATE,
        p_last_updated_by                        NUMBER,
        p_last_update_date                       DATE,
        p_last_update_login                      NUMBER);

  PROCEDURE Update_tax_amt
       (p_summary_tax_line_id                   NUMBER,
        p_application_id                        NUMBER,
        p_entity_code                           VARCHAR2,
        p_event_class_code                      VARCHAR2,
        p_trx_id                                NUMBER);

  PROCEDURE Populate_Allocation
       (p_statement                             VARCHAR2,
        p_trx_record                 OUT NOCOPY trx_record_tbl_type);

  PROCEDURE Insert_All_Allocation
       (X_Rowid                    IN OUT NOCOPY VARCHAR2,
        p_summary_tax_line_id                    NUMBER,
        p_internal_organization_id               NUMBER,
        p_application_id                         NUMBER,
        p_entity_code                            VARCHAR2,
        p_event_class_code                       VARCHAR2,
        p_tax_regime_code                        VARCHAR2,
        p_tax                                    VARCHAR2,
        p_tax_jurisdiction_code                  VARCHAR2,
        p_tax_status_code                        VARCHAR2,
        p_tax_rate_id                            NUMBER,
        p_tax_rate_code                          VARCHAR2,
        p_tax_rate                               NUMBER,
        p_tax_amt                                NUMBER,
        p_enabled_record                         VARCHAR2,
        p_summ_tax_only                          VARCHAR2,
        p_statement                              VARCHAR2,
        p_manually_entered_flag                  VARCHAR2,
        p_content_owner_id                       NUMBER,
        p_record_type_code                       VARCHAR2,
        p_last_manual_entry                      VARCHAR2,
        p_tax_amt_included_flag                  VARCHAR2,
        p_self_assessed_flag                     VARCHAR2,
        p_tax_only_line_flag                     VARCHAR2,
        p_created_by                             NUMBER,
        p_creation_date                          DATE,
        p_last_updated_by                        NUMBER,
        p_last_update_date                       DATE,
        p_last_update_login                      NUMBER,
        p_allocate_flag            IN            VARCHAR2 DEFAULT 'N'
        );

  PROCEDURE Insert_Tax_Line
       (p_summary_tax_line_id                    NUMBER,
        p_internal_organization_id               NUMBER,
        p_application_id                         NUMBER,
        p_entity_code                            VARCHAR2,
        p_event_class_code                       VARCHAR2,
        p_trx_id                                 NUMBER,
        p_trx_number                             VARCHAR2,
        p_tax_regime_code                        VARCHAR2,
        p_tax                                    VARCHAR2,
        p_tax_jurisdiction_code                  VARCHAR2,
        p_tax_status_code                        VARCHAR2,
        p_tax_rate_id                            NUMBER,
        p_tax_rate_code                          VARCHAR2,
        p_tax_rate                               NUMBER,
        p_tax_amt                                NUMBER,
        p_line_amt                               NUMBER,
        p_trx_line_date                          DATE,
        p_summ_tax_only                          VARCHAR2,
        p_manually_entered_flag                  VARCHAR2,
        p_last_manual_entry                      VARCHAR2,
        p_tax_amt_included_flag                  VARCHAR2,
        p_self_assessed_flag                     VARCHAR2,
        p_created_by                             NUMBER,
        p_creation_date                          DATE,
        p_last_updated_by                        NUMBER,
        p_last_update_date                       DATE,
        p_last_update_login                      NUMBER,
        p_event_type_code                      VARCHAR,
        p_legal_entity_id                       NUMBER,
        p_ledger_id                              NUMBER,
        p_trx_currency_code                     VARCHAR,
        p_currency_conversion_date              DATE,
        p_currency_conversion_rate              NUMBER,
        p_currency_conversion_type              VARCHAR2,
        p_content_owner_id              NUMBER,
        p_trx_date                       DATE,
        p_minimum_accountable_unit       NUMBER,
        p_precision                      NUMBER,
        p_trx_line_gl_date               DATE);

  PROCEDURE Populate_alloc_tbl(p_key IN VARCHAR2);
END ZX_TRL_ALLOCATIONS_PKG;

/
