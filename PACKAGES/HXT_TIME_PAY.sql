--------------------------------------------------------
--  DDL for Package HXT_TIME_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TIME_PAY" AUTHID CURRENT_USER AS
/* $Header: hxttpay.pkh 120.1.12010000.2 2009/02/26 07:51:21 asrajago ship $ */





  -- Bug 7359347
  -- Global variable for session date
  g_pay_session_date           DATE;


  FUNCTION pay (
   g_ep_id                      IN NUMBER,
   g_ep_type                    IN VARCHAR2,
   g_egt_id                     IN NUMBER,
   g_sdf_id                     IN NUMBER,
   g_hdp_id                     IN NUMBER,
   g_hol_id                     IN NUMBER,
   g_pep_id                     IN NUMBER,
   g_pip_id                     IN NUMBER,
   g_sdovr_id                   IN NUMBER,
   g_osp_id                     IN NUMBER,
   g_hol_yn                     IN VARCHAR2,
   g_person_id                  IN NUMBER,
   g_location                   IN VARCHAR2,
   g_ID                         IN NUMBER,
   g_TIM_ID                     IN NUMBER,
   g_DATE_WORKED                IN DATE,
   g_ASSIGNMENT_ID              IN NUMBER,
   g_HOURS                      IN NUMBER,
   g_TIME_IN                    IN DATE,
   g_TIME_OUT                   IN DATE,
   g_ELEMENT_TYPE_ID            IN NUMBER,
   g_FCL_EARN_REASON_CODE       IN VARCHAR2,
   g_FFV_COST_CENTER_ID         IN NUMBER,
   g_FFV_LABOR_ACCOUNT_ID       IN NUMBER,
   g_TAS_ID                     IN NUMBER,
   g_LOCATION_ID                IN NUMBER,
   g_SHT_ID                     IN NUMBER,
   g_HRW_COMMENT                IN VARCHAR2,
   g_FFV_RATE_CODE_ID           IN NUMBER,
   g_RATE_MULTIPLE              IN NUMBER,
   g_HOURLY_RATE                IN NUMBER,
   g_AMOUNT                     IN NUMBER,
   g_FCL_TAX_RULE_CODE          IN VARCHAR2,
   g_SEPARATE_CHECK_FLAG        IN VARCHAR2,
   g_SEQNO                      IN NUMBER,
   g_CREATED_BY                 IN NUMBER,
   g_CREATION_DATE              IN DATE,
   g_LAST_UPDATED_BY            IN NUMBER,
   g_LAST_UPDATE_DATE           IN DATE,
   g_LAST_UPDATE_LOGIN          IN NUMBER,
   g_EFFECTIVE_START_DATE       IN DATE,
   g_EFFECTIVE_END_DATE         IN DATE,
   g_PROJECT_ID                 IN NUMBER,
   g_PAY_STATUS                 IN VARCHAR2,
   g_PA_STATUS                  IN VARCHAR2,
   g_RETRO_BATCH_ID             IN NUMBER,
   g_STATE_NAME                 IN VARCHAR2 DEFAULT NULL,
   g_COUNTY_NAME                IN VARCHAR2 DEFAULT NULL,
   g_CITY_NAME                  IN VARCHAR2 DEFAULT NULL,
   g_ZIP_CODE                   IN VARCHAR2 DEFAULT NULL
   -- g_GROUP_ID                   IN NUMBER
)
   RETURN NUMBER;

PROCEDURE get_retro_fields( p_tim_id         IN     NUMBER
                           ,p_batch_name     IN     VARCHAR2 DEFAULT NULL
                           ,p_batch_ref      IN     VARCHAR2 DEFAULT NULL
                           ,p_pay_status        OUT NOCOPY VARCHAR2
                           ,p_pa_status         OUT NOCOPY VARCHAR2
                           ,p_retro_batch_id    OUT NOCOPY NUMBER
                           ,p_error_status      OUT NOCOPY NUMBER
                           ,p_sqlerrm           OUT NOCOPY VARCHAR2);
END;

/
