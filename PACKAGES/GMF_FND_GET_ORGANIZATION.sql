--------------------------------------------------------
--  DDL for Package GMF_FND_GET_ORGANIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_FND_GET_ORGANIZATION" AUTHID CURRENT_USER AS
/* $Header: gmfgetos.pls 115.3 2002/11/11 00:37:34 rseshadr ship $ */
  PROCEDURE GMS_GET_ORGANIZATION
              (PORG_ID                        IN OUT NOCOPY NUMBER,
               PORG_NAME                      IN OUT NOCOPY VARCHAR2,
               PSOB_NAME                      IN OUT NOCOPY VARCHAR2,
               OU_DATE_FROM                   OUT    NOCOPY VARCHAR2,
               OU_DATE_TO                     OUT    NOCOPY VARCHAR2,
               OL_NAME                        OUT    NOCOPY VARCHAR2,
               OL_DATE_FROM                   OUT    NOCOPY VARCHAR2,
               OL_DATE_TO                     OUT    NOCOPY VARCHAR2,
               VAT_REGISTRATION_NUMBER        OUT    NOCOPY NUMBER,
               SET_OF_BOOKS_ID                OUT    NOCOPY NUMBER,
               CURRENCY_CODE                  OUT    NOCOPY VARCHAR2,
               CHART_OF_ACCOUNTS_ID           OUT    NOCOPY NUMBER,
               PERIOD_SET_NAME                OUT    NOCOPY VARCHAR2,
               SUSPENSE_ALLOWED_FLAG          OUT    NOCOPY VARCHAR2,
               ALLOW_POSTING_WARNING_FLAG     OUT    NOCOPY VARCHAR2,
               ACCOUNTED_PERIOD_TYPE          OUT    NOCOPY VARCHAR2,
               SHORT_NAME                     OUT    NOCOPY VARCHAR2,
               REQUIRE_BUDGET_JOURNALS_FLAG   OUT    NOCOPY VARCHAR2,
               ENABLE_BUDGETARY_CONTROL_FLAG  OUT    NOCOPY VARCHAR2,
               ALLOW_INTERCOMPANY_POST_FLAG   OUT    NOCOPY VARCHAR2,
               LAST_UPDATE_LOGIN              OUT    NOCOPY VARCHAR2,
               LATEST_ENCUMBRANCE_YEAR        OUT    NOCOPY VARCHAR2,
               EARLIEST_UNTRANS_PERIOD_NAME   OUT    NOCOPY VARCHAR2,
               CUM_TRANS_CODE_COMBINATION_ID  OUT    NOCOPY VARCHAR2,
               FUTURE_ENTERABLE_PERIODS_LIMIT OUT    NOCOPY VARCHAR2,
               LATEST_OPENED_PERIOD_NAME      OUT    NOCOPY VARCHAR2,
               RET_EARN_CODE_COMBINATION_ID   OUT    NOCOPY VARCHAR2,
               RES_ENCUMB_CODE_COMBINATION_ID OUT    NOCOPY VARCHAR2,
               DESCRIPTION                    OUT    NOCOPY VARCHAR2,
               CREATED_BY                     OUT    NOCOPY VARCHAR2,
               CREATION_DATE                  OUT    NOCOPY DATE,
               LAST_UPDATE_DATE               OUT    NOCOPY DATE,
               LAST_UPDATED_BY                OUT    NOCOPY VARCHAR2,
               ROW_TO_FETCH                   IN OUT NOCOPY NUMBER,
               ERROR_STATUS                   OUT    NOCOPY NUMBER);

END GMF_FND_GET_ORGANIZATION;

 

/
