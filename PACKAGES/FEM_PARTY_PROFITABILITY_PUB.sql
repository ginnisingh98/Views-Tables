--------------------------------------------------------
--  DDL for Package FEM_PARTY_PROFITABILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_PARTY_PROFITABILITY_PUB" AUTHID CURRENT_USER AS
-- $Header: femprfSS.pls 120.0 2005/06/15 18:21:51 appldev noship $

TYPE profitability_rec_type IS RECORD(
party_id                        NUMBER,
profit                          NUMBER,
profit_pct                      NUMBER,
relationship_expense            NUMBER,
total_equity                    NUMBER,
total_gross_contrib             NUMBER,
total_roe                       NUMBER,
contrib_after_cptl_chg          NUMBER,
partner_value_index             NUMBER,
iso_currency_cd                 VARCHAR2(3),
last_update_date                DATE,
last_updated_by                 NUMBER,
creation_date                   DATE,
created_by                      NUMBER,
last_update_login               NUMBER,
REVENUE1                        NUMBER,
REVENUE2                        NUMBER,
REVENUE3                        NUMBER,
REVENUE4                        NUMBER,
REVENUE5                        NUMBER,
REVENUE_TOTAL                   NUMBER,
EXPENSE1                        NUMBER,
EXPENSE2                        NUMBER,
EXPENSE3                        NUMBER,
EXPENSE4                        NUMBER,
EXPENSE5                        NUMBER,
EXPENSE_TOTAL                   NUMBER,
PROFIT1                         NUMBER,
PROFIT2                         NUMBER,
PROFIT3                         NUMBER,
PROFIT4                         NUMBER,
PROFIT5                         NUMBER,
PROFIT_TOTAL                    NUMBER,
CACC1                           NUMBER,
CACC2                           NUMBER,
CACC3                           NUMBER,
CACC4                           NUMBER,
CACC5                           NUMBER,
CACC_TOTAL                      NUMBER,
BALANCE1                        NUMBER,
BALANCE2                        NUMBER,
BALANCE3                        NUMBER,
BALANCE4                        NUMBER,
BALANCE5                        NUMBER,
ACCOUNTS1                       NUMBER,
ACCOUNTS2                       NUMBER,
ACCOUNTS3                       NUMBER,
ACCOUNTS4                       NUMBER,
ACCOUNTS5                       NUMBER,
TRANSACTION1                    NUMBER,
TRANSACTION2                    NUMBER,
TRANSACTION3                    NUMBER,
TRANSACTION4                    NUMBER,
TRANSACTION5                    NUMBER,
RATIO1                          NUMBER,
RATIO2                          NUMBER,
RATIO3                          NUMBER,
RATIO4                          NUMBER,
RATIO5                          NUMBER,
VALUE1                          NUMBER,
VALUE2                          NUMBER,
VALUE3                          NUMBER,
VALUE4                          NUMBER,
VALUE5                          NUMBER,
YTD1                            NUMBER,
YTD2                            NUMBER,
YTD3                            NUMBER,
YTD4                            NUMBER,
YTD5                            NUMBER,
LTD1                            NUMBER,
LTD2                            NUMBER,
LTD3                            NUMBER,
LTD4                            NUMBER,
LTD5                            NUMBER
);


procedure create_profitability (
        p_api_version           IN      NUMBER:=1.0,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_TRUE,
        p_validation_level      IN      NUMBER:= FND_API.G_VALID_LEVEL_FULL,
        p_profitability_rec     IN      PROFITABILITY_REC_TYPE,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2,
        x_party_id              OUT NOCOPY     NUMBER

);


procedure update_profitability (
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:=FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:=FND_API.G_TRUE,
        p_validation_level      IN      NUMBER:=FND_API.G_VALID_LEVEL_FULL,
        p_profitability_rec     IN      PROFITABILITY_REC_TYPE,
        p_last_update_date      IN OUT NOCOPY  DATE,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2
);

END FEM_PARTY_PROFITABILITY_PUB;

 

/
