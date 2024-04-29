--------------------------------------------------------
--  DDL for Package HZ_ORG_INFO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORG_INFO_PUB" AUTHID CURRENT_USER as
/* $Header: ARHORISS.pls 120.3 2005/06/24 16:00:57 sponnamb ship $ */

G_MISS_CONTENT_SOURCE_TYPE               CONSTANT VARCHAR2(30) := 'USER_ENTERED';

----------------------------------------------------------------
------------------ #1 stock_markets_rec_type -------------------
----------------------------------------------------------------

TYPE stock_markets_rec_type IS RECORD(
stock_exchange_id                        NUMBER        := FND_API.G_MISS_NUM,
country_of_residence                     VARCHAR2(60)  := FND_API.G_MISS_CHAR,
stock_exchange_code                      VARCHAR2(60)  := FND_API.G_MISS_CHAR,
stock_exchange_name                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
wh_update_date                           DATE          := FND_API.G_MISS_DATE);


----------------------------------------------------------------
------------------ #2 security_issued_rec_type  ----------------
----------------------------------------------------------------


TYPE security_issued_rec_type IS RECORD(
security_issued_id                       NUMBER        := FND_API.G_MISS_NUM,
estimated_total_amount                   NUMBER        := FND_API.G_MISS_NUM,
stock_exchange_id                        NUMBER        := FND_API.G_MISS_NUM,
security_issued_class                    VARCHAR2(30)  := FND_API.G_MISS_CHAR,
security_issued_name                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
total_amount_in_a_currency               VARCHAR2(240) := FND_API.G_MISS_CHAR,
stock_ticker_symbol                      VARCHAR2(60)  := FND_API.G_MISS_CHAR,
security_currency_code                   VARCHAR2(15)  := FND_API.G_MISS_CHAR,
begin_date                               DATE          := FND_API.G_MISS_DATE,
party_id                                 NUMBER        := FND_API.G_MISS_NUM,
end_date                                 DATE          := FND_API.G_MISS_DATE,
wh_update_date                           DATE          := FND_API.G_MISS_DATE,
status                                   VARCHAR2(1)   := FND_API.G_MISS_CHAR);

----------------------------------------------------------------
------------------ #3 financial_reports_rec_type ---------------
----------------------------------------------------------------

TYPE financial_reports_rec_type IS RECORD(
financial_report_id                      NUMBER        := FND_API.G_MISS_NUM,
date_report_issued                       DATE          := FND_API.G_MISS_DATE,
party_id                                 NUMBER        := FND_API.G_MISS_NUM,
document_reference                       VARCHAR2(120) := FND_API.G_MISS_CHAR,
issued_period                            VARCHAR2(60)  := FND_API.G_MISS_CHAR,
requiring_authority                      VARCHAR2(60)  := FND_API.G_MISS_CHAR,
type_of_financial_report                 VARCHAR2(60)  := FND_API.G_MISS_CHAR,
wh_udpate_id                             DATE          := FND_API.G_MISS_DATE,
report_start_date                        DATE          := FND_API.G_MISS_DATE,
report_end_date                          DATE          := FND_API.G_MISS_DATE,
audit_ind                                VARCHAR2(5)   := FND_API.G_MISS_CHAR,
consolidated_ind                         VARCHAR2(5)   := FND_API.G_MISS_CHAR,
estimated_ind                            VARCHAR2(5)   := FND_API.G_MISS_CHAR,
fiscal_ind                               VARCHAR2(5)   := FND_API.G_MISS_CHAR,
final_ind                                VARCHAR2(5)   := FND_API.G_MISS_CHAR,
forecast_ind                             VARCHAR2(5)   := FND_API.G_MISS_CHAR,
opening_ind                              VARCHAR2(5)   := FND_API.G_MISS_CHAR,
proforma_ind                             VARCHAR2(5)   := FND_API.G_MISS_CHAR,
qualified_ind                            VARCHAR2(5)   := FND_API.G_MISS_CHAR,
restated_ind                             VARCHAR2(5)   := FND_API.G_MISS_CHAR,
signed_by_principals_ind                 VARCHAR2(5)   := FND_API.G_MISS_CHAR,
trial_balance_ind                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
unbalanced_ind                           VARCHAR2(5)   := FND_API.G_MISS_CHAR,
content_source_type                      VARCHAR2(30)  := G_MISS_CONTENT_SOURCE_TYPE,
status                                   VARCHAR2(1)   := FND_API.G_MISS_CHAR,
actual_content_source                    VARCHAR2(30)  := FND_API.G_MISS_CHAR
);




----------------------------------------------------------------
------------------ #4 financial_numbers_rec_type ---------------
----------------------------------------------------------------


TYPE financial_numbers_rec_type IS RECORD(
financial_number_id                    NUMBER        := FND_API.G_MISS_NUM,
financial_report_id                    NUMBER        := FND_API.G_MISS_NUM,
financial_number                       NUMBER        := FND_API.G_MISS_NUM,
financial_number_name                  VARCHAR2(60)  := FND_API.G_MISS_CHAR,
financial_units_applied                NUMBER        := FND_API.G_MISS_NUM,
financial_number_currency              VARCHAR2(240) := FND_API.G_MISS_CHAR,
projected_actual_flag                  VARCHAR2(1)   := FND_API.G_MISS_CHAR,
wh_update_date                         DATE          := FND_API.G_MISS_DATE,
content_source_type                    VARCHAR2(30)  := G_MISS_CONTENT_SOURCE_TYPE,
status                                 VARCHAR2(1)   := FND_API.G_MISS_CHAR
);


----------------------------------------------------------------
------------------ #5 certifications_rec_type    ---------------
----------------------------------------------------------------


TYPE certifications_rec_type IS RECORD(
certification_id                        NUMBER        := FND_API.G_MISS_NUM,
certification_name                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
party_id                                NUMBER        := FND_API.G_MISS_NUM,
current_status                          VARCHAR2(30)  := FND_API.G_MISS_CHAR,
expires_on_date                         DATE          := FND_API.G_MISS_DATE,
grade                                   VARCHAR2(30)  := FND_API.G_MISS_CHAR,
issued_by_authority                     VARCHAR2(60)  := FND_API.G_MISS_CHAR,
issued_on_date                          DATE          := FND_API.G_MISS_DATE,
wh_update_date                          DATE          := FND_API.G_MISS_DATE,
status                                  VARCHAR2(1)   := FND_API.G_MISS_CHAR);

----------------------------------------------------------------
------------------ #6  industrial_reference_rec_type   ---------
----------------------------------------------------------------

TYPE industrial_reference_rec_type IS RECORD(
industry_reference_id                    NUMBER        := FND_API.G_MISS_NUM,
industry_reference                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
party_id                                 NUMBER        := FND_API.G_MISS_NUM,
issued_by_authority                      VARCHAR2(60)  := FND_API.G_MISS_CHAR,
name_of_reference                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
recognized_as_of_date                    DATE          := FND_API.G_MISS_DATE,
wh_update_date                           DATE          := FND_API.G_MISS_DATE,
status                                    VARCHAR2(1)  := FND_API.G_MISS_CHAR);

----------------------------------------------------------------
------------------ #7  industrial_classes_rec_typ   ------------
----------------------------------------------------------------


TYPE industrial_classes_rec_type IS RECORD(
industrial_class_id                     NUMBER         := FND_API.G_MISS_NUM,
industrial_code_name                    VARCHAR2(60)   := FND_API.G_MISS_CHAR,
code_primary_segment                    VARCHAR2(60)   := FND_API.G_MISS_CHAR,
industrial_class_source                 VARCHAR2(60)   := FND_API.G_MISS_CHAR,
code_description                        VARCHAR2(2000) := FND_API.G_MISS_CHAR,
wh_update_date                          DATE           := FND_API.G_MISS_DATE);

----------------------------------------------------------------
------------------ #8  industrial_class_app_rec_type   ---------
----------------------------------------------------------------

TYPE industrial_class_app_rec_type IS RECORD(
code_applied_id                         NUMBER        := FND_API.G_MISS_NUM,
begin_date                              DATE          := FND_API.G_MISS_DATE,
party_id                                NUMBER        := FND_API.G_MISS_NUM,
end_date                                DATE          := FND_API.G_MISS_DATE,
industrial_class_id                     NUMBER        := FND_API.G_MISS_NUM,
wh_update_date                          DATE          := FND_API.G_MISS_DATE,
content_source_type                     VARCHAR2(60)  := FND_API.G_MISS_CHAR,
importance_ranking                      VARCHAR2(240) := FND_API.G_MISS_CHAR);


--------------------- #1 -----------------------------

procedure create_stock_markets(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_stock_markets_rec     IN      STOCK_MARKETS_REC_TYPE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_stock_exchange_id     OUT     NOCOPY NUMBER,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);

procedure update_stock_markets(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_stock_markets_rec     IN      STOCK_MARKETS_REC_TYPE,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);

--------------------- #2 -----------------------------
procedure create_security_issued(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_security_issued_rec   IN      SECURITY_ISSUED_REC_TYPE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_security_issued_id    OUT     NOCOPY NUMBER,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure update_security_issued(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_security_issued_rec   IN      SECURITY_ISSUED_REC_TYPE,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);

--------------------- #3 -----------------------------
/* Obsolete V1 API
procedure create_financial_reports(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_reports_rec IN      FINANCIAL_REPORTS_REC_TYPE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_financial_report_id   OUT     NOCOPY NUMBER,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure update_financial_reports(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_reports_rec IN      FINANCIAL_REPORTS_REC_TYPE,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);

--------------------- #4 -----------------------------

procedure create_financial_numbers(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_numbers_rec IN      FINANCIAL_NUMBERS_REC_TYPE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_financial_number_id   OUT     NOCOPY NUMBER,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure update_financial_numbers(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_numbers_rec IN      FINANCIAL_NUMBERS_REC_TYPE,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);
*/

--------------------- #5 -----------------------------

procedure create_certifications(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_certifications_rec    IN      CERTIFICATIONS_REC_TYPE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_certification_id      OUT     NOCOPY NUMBER,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure update_certifications(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_certifications_rec    IN      CERTIFICATIONS_REC_TYPE,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);

--------------------- #6 -----------------------------

procedure create_industrial_reference(
        p_api_version               IN      NUMBER,
        p_init_msg_list             IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                    IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_reference_rec  IN      INDUSTRIAL_REFERENCE_REC_TYPE,
        x_return_status             OUT     NOCOPY VARCHAR2,
        x_msg_count                 OUT     NOCOPY NUMBER,
        x_msg_data                  OUT     NOCOPY VARCHAR2,
        x_industry_reference_id     OUT     NOCOPY NUMBER,
        p_validation_level          IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure update_industrial_reference(
        p_api_version               IN      NUMBER,
        p_init_msg_list             IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                    IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_reference_rec  IN      INDUSTRIAL_REFERENCE_REC_TYPE,
        p_last_update_date          IN OUT  NOCOPY DATE,
        x_return_status             OUT     NOCOPY VARCHAR2,
        x_msg_count                 OUT     NOCOPY NUMBER,
        x_msg_data                  OUT     NOCOPY VARCHAR2,
        p_validation_level          IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);

--------------------- #7 -----------------------------

procedure create_industrial_classes(
        p_api_version             IN      NUMBER,
        p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                  IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_classes_rec  IN      INDUSTRIAL_CLASSES_REC_TYPE,
        x_return_status           OUT     NOCOPY VARCHAR2,
        x_msg_count               OUT     NOCOPY NUMBER,
        x_msg_data                OUT     NOCOPY VARCHAR2,
        x_industrial_class_id     OUT     NOCOPY NUMBER,
        p_validation_level        IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure update_industrial_classes(
        p_api_version             IN      NUMBER,
        p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                  IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_classes_rec  IN      INDUSTRIAL_CLASSES_REC_TYPE,
        p_last_update_date        IN OUT  NOCOPY DATE,
        x_return_status           OUT     NOCOPY VARCHAR2,
        x_msg_count               OUT     NOCOPY NUMBER,
        x_msg_data                OUT     NOCOPY VARCHAR2,
        p_validation_level        IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);

--------------------- #8 -----------------------------

procedure create_industrial_class_app(
        p_api_version               IN      NUMBER,
        p_init_msg_list             IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                    IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_class_app_rec  IN      INDUSTRIAL_CLASS_APP_REC_TYPE,
        x_return_status             OUT     NOCOPY VARCHAR2,
        x_msg_count                 OUT     NOCOPY NUMBER,
        x_msg_data                  OUT     NOCOPY VARCHAR2,
        x_code_applied_id           OUT     NOCOPY NUMBER,
        p_validation_level          IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);

procedure update_industrial_class_app(
        p_api_version               IN      NUMBER,
        p_init_msg_list             IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                    IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_class_app_rec  IN      INDUSTRIAL_CLASS_APP_REC_TYPE,
        p_last_update_date          IN OUT  NOCOPY DATE,
        x_return_status             OUT     NOCOPY VARCHAR2,
        x_msg_count                 OUT     NOCOPY NUMBER,
        x_msg_data                  OUT     NOCOPY VARCHAR2,
        p_validation_level          IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure get_current_financial_report(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_report_id   IN      NUMBER,
        x_financial_reports_rec OUT     NOCOPY FINANCIAL_REPORTS_REC_TYPE,
        x_return_status         IN OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

procedure get_current_financial_number(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_number_id   IN      NUMBER,
        x_financial_numbers_rec OUT     NOCOPY FINANCIAL_NUMBERS_REC_TYPE,
        x_return_status         IN OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);


end HZ_ORG_INFO_PUB;

 

/
