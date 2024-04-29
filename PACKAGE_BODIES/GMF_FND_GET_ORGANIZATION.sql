--------------------------------------------------------
--  DDL for Package Body GMF_FND_GET_ORGANIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_FND_GET_ORGANIZATION" as
/* $Header: gmfgetob.pls 120.1 2005/10/05 07:47:57 rseshadr noship $ */
  CURSOR CUR_GMS_GET_ORGANIZATION(PORG_ID   NUMBER,
                                   PORG_NAME VARCHAR2,
                                   PSOB_NAME VARCHAR2) IS
  SELECT OU.ORGANIZATION_ID,
         OU.NAME,
         OU.DATE_FROM,
         OU.DATE_TO,
         null as OL_NAME,
         null as OL_DATE_FROM,
         null as OL_DATE_TO,
         0,
         SOB.ledger_id,
         SOB.CURRENCY_CODE,
         SOB.CHART_OF_ACCOUNTS_ID,
         SOB.NAME,
         SOB.PERIOD_SET_NAME,
         SOB.SUSPENSE_ALLOWED_FLAG,
         null as ALLOW_POSTING_WARNING_FLAG,
         SOB.ACCOUNTED_PERIOD_TYPE,
         SOB.SHORT_NAME,
         SOB.REQUIRE_BUDGET_JOURNALS_FLAG,
         SOB.ENABLE_BUDGETARY_CONTROL_FLAG,
         SOB.ALLOW_INTERCOMPANY_POST_FLAG,
         SOB.LAST_UPDATE_LOGIN,
         SOB.LATEST_ENCUMBRANCE_YEAR,
         null as EARLIEST_UNTRANS_PERIOD_NAME,
         SOB.CUM_TRANS_CODE_COMBINATION_ID,
         SOB.FUTURE_ENTERABLE_PERIODS_LIMIT,
         SOB.LATEST_OPENED_PERIOD_NAME,
         SOB.RET_EARN_CODE_COMBINATION_ID,
         SOB.RES_ENCUMB_CODE_COMBINATION_ID,
         SOB.DESCRIPTION,
         SOB.CREATED_BY,
         SOB.CREATION_DATE,
         SOB.LAST_UPDATE_DATE,
         SOB.LAST_UPDATED_BY
  FROM   HR_OPERATING_UNITS OU,
         gl_ledgers SOB
  WHERE  OU.set_of_books_id = sob.ledger_id
  AND    OU.ORGANIZATION_ID = NVL(PORG_ID, OU.ORGANIZATION_ID)
  AND    OU.NAME            = NVL(PORG_NAME, OU.NAME)
  AND    SOB.NAME           = NVL(PSOB_NAME, SOB.NAME);

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
               ERROR_STATUS                   OUT    NOCOPY NUMBER)   IS

    CREATEDBY   NUMBER;
    MODIFIEDBY  NUMBER;

    BEGIN
      IF NOT CUR_GMS_GET_ORGANIZATION%ISOPEN THEN
        OPEN CUR_GMS_GET_ORGANIZATION(PORG_ID, PORG_NAME, PSOB_NAME);
      END IF;

      FETCH CUR_GMS_GET_ORGANIZATION
      INTO     PORG_ID,                        PORG_NAME,
               OU_DATE_FROM,                   OU_DATE_TO,
               OL_NAME,                        OL_DATE_FROM,
               OL_DATE_TO,                     VAT_REGISTRATION_NUMBER,
               SET_OF_BOOKS_ID,                CURRENCY_CODE,
               CHART_OF_ACCOUNTS_ID,           PSOB_NAME,
               PERIOD_SET_NAME,                SUSPENSE_ALLOWED_FLAG,
               ALLOW_POSTING_WARNING_FLAG,     ACCOUNTED_PERIOD_TYPE,
               SHORT_NAME,                     REQUIRE_BUDGET_JOURNALS_FLAG,
               ENABLE_BUDGETARY_CONTROL_FLAG,  ALLOW_INTERCOMPANY_POST_FLAG,
               LAST_UPDATE_LOGIN,              LATEST_ENCUMBRANCE_YEAR,
               EARLIEST_UNTRANS_PERIOD_NAME,   CUM_TRANS_CODE_COMBINATION_ID,
               FUTURE_ENTERABLE_PERIODS_LIMIT, LATEST_OPENED_PERIOD_NAME,
               RET_EARN_CODE_COMBINATION_ID,   RES_ENCUMB_CODE_COMBINATION_ID,
               DESCRIPTION,                    CREATEDBY,
               CREATION_DATE,                  LAST_UPDATE_DATE,
               MODIFIEDBY;

      IF CUR_GMS_GET_ORGANIZATION%NOTFOUND THEN
        ERROR_STATUS := 100;
        CLOSE CUR_GMS_GET_ORGANIZATION;
      ELSE
        -- Bug 2499848
        -- CREATED_BY := GMF_FND_GET_USERS.FND_GET_USERS(CREATEDBY);
        -- LAST_UPDATED_BY := GMF_FND_GET_USERS.FND_GET_USERS(MODIFIEDBY);
        CREATED_BY := CREATEDBY;
        LAST_UPDATED_BY := MODIFIEDBY;
      END IF;

      IF ROW_TO_FETCH = 1 AND CUR_GMS_GET_ORGANIZATION%ISOPEN THEN
        CLOSE CUR_GMS_GET_ORGANIZATION;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          ERROR_STATUS := SQLCODE;
  END GMS_GET_ORGANIZATION;

END GMF_FND_GET_ORGANIZATION;

/
