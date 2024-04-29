--------------------------------------------------------
--  DDL for Package HZ_FINANCIAL_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_FINANCIAL_REPORTS_PKG" AUTHID CURRENT_USER as
/* $Header: ARHOFRTS.pls 115.9 2003/05/03 07:32:47 ssmohan ship $ */


PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_report_id                   IN OUT NOCOPY NUMBER,
    x_date_report_issued                    IN     DATE,
    x_party_id                              IN     NUMBER,
    x_document_reference                    IN     VARCHAR2,
    x_issued_period                         IN     VARCHAR2,
    x_requiring_authority                   IN     VARCHAR2,
    x_type_of_financial_report              IN     VARCHAR2,
    x_report_start_date                     IN     DATE,
    x_report_end_date                       IN     DATE,
    x_audit_ind                             IN     VARCHAR2,
    x_consolidated_ind                      IN     VARCHAR2,
    x_estimated_ind                         IN     VARCHAR2,
    x_fiscal_ind                            IN     VARCHAR2,
    x_final_ind                             IN     VARCHAR2,
    x_forecast_ind                          IN     VARCHAR2,
    x_opening_ind                           IN     VARCHAR2,
    x_proforma_ind                          IN     VARCHAR2,
    x_qualified_ind                         IN     VARCHAR2,
    x_restated_ind                          IN     VARCHAR2,
    x_signed_by_principals_ind              IN     VARCHAR2,
    x_trial_balance_ind                     IN     VARCHAR2,
    x_unbalanced_ind                        IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_report_id                   IN     NUMBER,
    x_date_report_issued                    IN     DATE,
    x_party_id                              IN     NUMBER,
    x_document_reference                    IN     VARCHAR2,
    x_issued_period                         IN     VARCHAR2,
    x_requiring_authority                   IN     VARCHAR2,
    x_type_of_financial_report              IN     VARCHAR2,
    x_report_start_date                     IN     DATE,
    x_report_end_date                       IN     DATE,
    x_audit_ind                             IN     VARCHAR2,
    x_consolidated_ind                      IN     VARCHAR2,
    x_estimated_ind                         IN     VARCHAR2,
    x_fiscal_ind                            IN     VARCHAR2,
    x_final_ind                             IN     VARCHAR2,
    x_forecast_ind                          IN     VARCHAR2,
    x_opening_ind                           IN     VARCHAR2,
    x_proforma_ind                          IN     VARCHAR2,
    x_qualified_ind                         IN     VARCHAR2,
    x_restated_ind                          IN     VARCHAR2,
    x_signed_by_principals_ind              IN     VARCHAR2,
    x_trial_balance_ind                     IN     VARCHAR2,
    x_unbalanced_ind                        IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_report_id                   IN     NUMBER,
    x_date_report_issued                    IN     DATE,
    x_party_id                              IN     NUMBER,
    x_document_reference                    IN     VARCHAR2,
    x_issued_period                         IN     VARCHAR2,
    x_requiring_authority                   IN     VARCHAR2,
    x_type_of_financial_report              IN     VARCHAR2,
    x_report_start_date                     IN     DATE,
    x_report_end_date                       IN     DATE,
    x_audit_ind                             IN     VARCHAR2,
    x_consolidated_ind                      IN     VARCHAR2,
    x_estimated_ind                         IN     VARCHAR2,
    x_fiscal_ind                            IN     VARCHAR2,
    x_final_ind                             IN     VARCHAR2,
    x_forecast_ind                          IN     VARCHAR2,
    x_opening_ind                           IN     VARCHAR2,
    x_proforma_ind                          IN     VARCHAR2,
    x_qualified_ind                         IN     VARCHAR2,
    x_restated_ind                          IN     VARCHAR2,
    x_signed_by_principals_ind              IN     VARCHAR2,
    x_trial_balance_ind                     IN     VARCHAR2,
    x_unbalanced_ind                        IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_created_by                            IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_request_id                            IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_update_date                   IN     DATE,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2
);

PROCEDURE Delete_Row (
    x_financial_report_id                   IN     NUMBER
);

PROCEDURE Select_Row (
                  x_financial_report_id            IN OUT NOCOPY NUMBER,
                  x_date_report_issued             OUT    NOCOPY DATE,
                  x_party_id                       OUT    NOCOPY NUMBER,
                  x_document_reference             OUT    NOCOPY VARCHAR2,
                  x_issued_period                  OUT    NOCOPY VARCHAR2,
                  x_requiring_authority            OUT    NOCOPY VARCHAR2,
                  x_type_of_financial_report       OUT    NOCOPY VARCHAR2,
                  x_report_start_date              OUT    NOCOPY DATE,
                  x_report_end_date                OUT    NOCOPY DATE,
                  x_audit_ind                      OUT    NOCOPY VARCHAR2,
                  x_consolidated_ind               OUT    NOCOPY VARCHAR2,
                  x_estimated_ind                  OUT    NOCOPY VARCHAR2,
                  x_fiscal_ind                     OUT    NOCOPY VARCHAR2,
                  x_final_ind                      OUT    NOCOPY VARCHAR2,
                  x_forecast_ind                   OUT    NOCOPY VARCHAR2,
                  x_opening_ind                    OUT    NOCOPY VARCHAR2,
                  x_proforma_ind                   OUT    NOCOPY VARCHAR2,
                  x_qualified_ind                  OUT    NOCOPY VARCHAR2,
                  x_restated_ind                   OUT    NOCOPY VARCHAR2,
                  x_signed_by_principals_ind       OUT    NOCOPY VARCHAR2,
                  x_trial_balance_ind              OUT    NOCOPY VARCHAR2,
                  x_unbalanced_ind                 OUT    NOCOPY VARCHAR2,
                  x_content_source_type            OUT    NOCOPY VARCHAR2,
                  x_status                         OUT    NOCOPY VARCHAR2,
                  x_actual_content_source          OUT    NOCOPY VARCHAR2,
                  x_created_by_module              OUT    NOCOPY VARCHAR2
);

END HZ_FINANCIAL_REPORTS_PKG;

 

/
