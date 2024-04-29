--------------------------------------------------------
--  DDL for Package FND_CONCURRENT_ARGUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONCURRENT_ARGUMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPPCPS.pls 115.0 2003/10/04 07:27:12 aranjeet noship $ */


procedure INSERT_ROW (
  X_ROWID in out nocopy              VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION     in VARCHAR2,
  X_APPLICATION_ID                in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME    in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD  in VARCHAR2,
  X_APPLICATION_COLUMN_NAME       in VARCHAR2,
  X_END_USER_COLUMN_NAME          in VARCHAR2,
  X_LAST_UPDATE_DATE              in DATE,
  X_LAST_UPDATED_BY               in NUMBER,
  X_CREATION_DATE                 in DATE,
  X_CREATED_BY                    in NUMBER,
  X_LAST_UPDATE_LOGIN             in NUMBER,
  X_COLUMN_SEQ_NUM                in NUMBER,
  X_ENABLED_FLAG                  in VARCHAR2,
  X_REQUIRED_FLAG                 in VARCHAR2,
  X_SECURITY_ENABLED_FLAG         in VARCHAR2,
  X_DISPLAY_FLAG                  in VARCHAR2,
  X_DISPLAY_SIZE                  in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN       in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE  in NUMBER,
  X_FLEX_VALUE_SET_ID             in NUMBER,
  X_RANGE_CODE                    in VARCHAR2,
  X_DEFAULT_TYPE                  in VARCHAR2,
  X_DEFAULT_VALUE                 in VARCHAR2,
  X_SRW_PARAM                     in VARCHAR2,
  X_FORM_LEFT_PROMPT              in VARCHAR2,
  X_FORM_ABOVE_PROMPT             in VARCHAR2,
  X_DESCRIPTION                   in VARCHAR2
);

procedure UPDATE_ROW (
  X_RUNTIME_PROPERTY_FUNCTION     in VARCHAR2,
  X_APPLICATION_ID                in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME    in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD  in VARCHAR2,
  X_APPLICATION_COLUMN_NAME       in VARCHAR2,
  X_END_USER_COLUMN_NAME          in VARCHAR2,
  X_LAST_UPDATE_DATE              in DATE,
  X_LAST_UPDATED_BY               in NUMBER,
  X_LAST_UPDATE_LOGIN             in NUMBER,
  X_COLUMN_SEQ_NUM                in NUMBER,
  X_ENABLED_FLAG                  in VARCHAR2,
  X_REQUIRED_FLAG                 in VARCHAR2,
  X_SECURITY_ENABLED_FLAG         in VARCHAR2,
  X_DISPLAY_FLAG                  in VARCHAR2,
  X_DISPLAY_SIZE                  in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN       in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE  in NUMBER,
  X_FLEX_VALUE_SET_ID             in NUMBER,
  X_RANGE_CODE                    in VARCHAR2,
  X_DEFAULT_TYPE                  in VARCHAR2,
  X_DEFAULT_VALUE                 in VARCHAR2,
  X_SRW_PARAM                     in VARCHAR2,
  X_FORM_LEFT_PROMPT              in VARCHAR2,
  X_FORM_ABOVE_PROMPT             in VARCHAR2,
  X_DESCRIPTION                   in VARCHAR2
);

procedure LOCK_ROW (
  X_RUNTIME_PROPERTY_FUNCTION     in VARCHAR2,
  X_APPLICATION_ID                in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME    in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD  in VARCHAR2,
  X_APPLICATION_COLUMN_NAME       in VARCHAR2,
  X_END_USER_COLUMN_NAME          in VARCHAR2,
  X_COLUMN_SEQ_NUM                in NUMBER,
  X_ENABLED_FLAG                  in VARCHAR2,
  X_REQUIRED_FLAG                 in VARCHAR2,
  X_SECURITY_ENABLED_FLAG         in VARCHAR2,
  X_DISPLAY_FLAG                  in VARCHAR2,
  X_DISPLAY_SIZE                  in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN       in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE  in NUMBER,
  X_FLEX_VALUE_SET_ID             in NUMBER,
  X_RANGE_CODE                    in VARCHAR2,
  X_DEFAULT_TYPE                  in VARCHAR2,
  X_DEFAULT_VALUE                 in VARCHAR2,
  X_SRW_PARAM                     in VARCHAR2,
  X_FORM_LEFT_PROMPT              in VARCHAR2,
  X_FORM_ABOVE_PROMPT             in VARCHAR2,
  X_DESCRIPTION                   in VARCHAR2
);

procedure DELETE_ROW (
  X_APPLICATION_ID                in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME    in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD  in VARCHAR2,
  X_APPLICATION_COLUMN_NAME       in VARCHAR2
);

END FND_CONCURRENT_ARGUMENTS_PKG;

 

/
