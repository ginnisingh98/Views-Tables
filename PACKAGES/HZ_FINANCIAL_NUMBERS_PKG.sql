--------------------------------------------------------
--  DDL for Package HZ_FINANCIAL_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_FINANCIAL_NUMBERS_PKG" AUTHID CURRENT_USER as
/* $Header: ARHOFNTS.pls 115.8 2003/02/10 09:22:44 ssmohan ship $ */


PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_number_id                   IN OUT NOCOPY NUMBER,
    x_financial_report_id                   IN     NUMBER,
    x_financial_number                      IN     NUMBER,
    x_financial_number_name                 IN     VARCHAR2,
    x_financial_units_applied               IN     NUMBER,
    x_financial_number_currency             IN     VARCHAR2,
    x_projected_actual_flag                 IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_number_id                   IN     NUMBER,
    x_financial_report_id                   IN     NUMBER,
    x_financial_number                      IN     NUMBER,
    x_financial_number_name                 IN     VARCHAR2,
    x_financial_units_applied               IN     NUMBER,
    x_financial_number_currency             IN     VARCHAR2,
    x_projected_actual_flag                 IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_number_id                   IN     NUMBER,
    x_financial_report_id                   IN     NUMBER,
    x_financial_number                      IN     NUMBER,
    x_financial_number_name                 IN     VARCHAR2,
    x_financial_units_applied               IN     NUMBER,
    x_financial_number_currency             IN     VARCHAR2,
    x_projected_actual_flag                 IN     VARCHAR2,
    x_created_by                            IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_request_id                            IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_update_date                   IN     DATE,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2
);

PROCEDURE Delete_Row (
    x_financial_number_id                   IN     NUMBER
);

PROCEDURE Select_Row (
                  x_financial_number_id           IN OUT NOCOPY NUMBER,
                  x_financial_report_id           OUT    NOCOPY NUMBER,
                  x_financial_number              OUT    NOCOPY NUMBER,
                  x_financial_number_name         OUT    NOCOPY VARCHAR2,
                  x_financial_units_applied       OUT    NOCOPY NUMBER,
                  x_financial_number_currency     OUT    NOCOPY VARCHAR2,
                  x_projected_actual_flag         OUT    NOCOPY VARCHAR2,
                  x_content_source_type           OUT    NOCOPY VARCHAR2,
                  x_status                        OUT    NOCOPY VARCHAR2,
                  x_actual_content_source         OUT    NOCOPY VARCHAR2
);

END HZ_FINANCIAL_NUMBERS_PKG;

 

/
