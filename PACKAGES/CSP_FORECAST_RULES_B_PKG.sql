--------------------------------------------------------
--  DDL for Package CSP_FORECAST_RULES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_FORECAST_RULES_B_PKG" AUTHID CURRENT_USER as
/* $Header: csptpfrs.pls 115.6 2003/05/29 20:30:59 sunarasi ship $ */
-- Start of Comments
-- Package name     : CSP_FORECAST_RULES_B_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_FORECAST_RULE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_RULE_NAME    VARCHAR2,
          p_PERIOD_TYPE    VARCHAR2,
		p_PERIOD_SIZE    NUMBER,
          p_FORECAST_PERIODS    NUMBER,
          p_FORECAST_METHOD    VARCHAR2,
          p_HISTORY_PERIODS    NUMBER,
          p_ALPHA    NUMBER,
          p_BETA    NUMBER,
          p_TRACKING_SIGNAL_CYCLE    NUMBER,
          p_WEIGHTED_AVG_PERIOD1    NUMBER,
          p_WEIGHTED_AVG_PERIOD2    NUMBER,
          p_WEIGHTED_AVG_PERIOD3    NUMBER,
          p_WEIGHTED_AVG_PERIOD4    NUMBER,
          p_WEIGHTED_AVG_PERIOD5    NUMBER,
          p_WEIGHTED_AVG_PERIOD6    NUMBER,
          p_WEIGHTED_AVG_PERIOD7    NUMBER,
          p_WEIGHTED_AVG_PERIOD8    NUMBER,
          p_WEIGHTED_AVG_PERIOD9    NUMBER,
          p_WEIGHTED_AVG_PERIOD10    NUMBER,
          p_WEIGHTED_AVG_PERIOD11    NUMBER,
          p_WEIGHTED_AVG_PERIOD12    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_DESCRIPTION    VARCHAR2);

PROCEDURE Update_Row(
          p_FORECAST_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_RULE_NAME    VARCHAR2,
          p_PERIOD_TYPE    VARCHAR2,
		p_PERIOD_SIZE    NUMBER,
          p_FORECAST_PERIODS    NUMBER,
          p_FORECAST_METHOD    VARCHAR2,
          p_HISTORY_PERIODS    NUMBER,
          p_ALPHA    NUMBER,
          p_BETA    NUMBER,
          p_TRACKING_SIGNAL_CYCLE    NUMBER,
          p_WEIGHTED_AVG_PERIOD1    NUMBER,
          p_WEIGHTED_AVG_PERIOD2    NUMBER,
          p_WEIGHTED_AVG_PERIOD3    NUMBER,
          p_WEIGHTED_AVG_PERIOD4    NUMBER,
          p_WEIGHTED_AVG_PERIOD5    NUMBER,
          p_WEIGHTED_AVG_PERIOD6    NUMBER,
          p_WEIGHTED_AVG_PERIOD7    NUMBER,
          p_WEIGHTED_AVG_PERIOD8    NUMBER,
          p_WEIGHTED_AVG_PERIOD9    NUMBER,
          p_WEIGHTED_AVG_PERIOD10    NUMBER,
          p_WEIGHTED_AVG_PERIOD11    NUMBER,
          p_WEIGHTED_AVG_PERIOD12    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_DESCRIPTION    VARCHAR2);

PROCEDURE Lock_Row(
          p_FORECAST_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_RULE_NAME    VARCHAR2,
          p_PERIOD_TYPE    VARCHAR2,
		p_PERIOD_SIZE    NUMBER,
          p_FORECAST_PERIODS    NUMBER,
          p_FORECAST_METHOD    VARCHAR2,
          p_HISTORY_PERIODS    NUMBER,
          p_ALPHA    NUMBER,
          p_BETA    NUMBER,
          p_TRACKING_SIGNAL_CYCLE    NUMBER,
          p_WEIGHTED_AVG_PERIOD1    NUMBER,
          p_WEIGHTED_AVG_PERIOD2    NUMBER,
          p_WEIGHTED_AVG_PERIOD3    NUMBER,
          p_WEIGHTED_AVG_PERIOD4    NUMBER,
          p_WEIGHTED_AVG_PERIOD5    NUMBER,
          p_WEIGHTED_AVG_PERIOD6    NUMBER,
          p_WEIGHTED_AVG_PERIOD7    NUMBER,
          p_WEIGHTED_AVG_PERIOD8    NUMBER,
          p_WEIGHTED_AVG_PERIOD9    NUMBER,
          p_WEIGHTED_AVG_PERIOD10    NUMBER,
          p_WEIGHTED_AVG_PERIOD11    NUMBER,
          p_WEIGHTED_AVG_PERIOD12    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_DESCRIPTION    VARCHAR2);

PROCEDURE Delete_Row(
    p_FORECAST_RULE_ID  NUMBER);

procedure ADD_LANGUAGE;

PROCEDURE Translate_Row
( p_forecast_rule_id IN  NUMBER
, p_description       IN  VARCHAR2
, p_owner             IN VARCHAR2
);

 PROCEDURE Load_Row
 ( p_forecast_rule_id IN  NUMBER
 , p_description       IN  VARCHAR2
 , p_owner             IN  VARCHAR2
 );
End CSP_FORECAST_RULES_B_PKG;

 

/
