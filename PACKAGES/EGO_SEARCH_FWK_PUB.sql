--------------------------------------------------------
--  DDL for Package EGO_SEARCH_FWK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_SEARCH_FWK_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPSFWS.pls 120.2.12000000.2 2007/05/03 12:39:12 ksathupa ship $ */
/*---------------------------------------------------------------------------+
 | This package contains public API for Search Framework                     |
 +---------------------------------------------------------------------------*/


  PROCEDURE create_criteria_template
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_NAME                         IN     VARCHAR2,
     X_DESCRIPTION                  IN     VARCHAR2,
     X_VERTICALIZATION_ID           IN     VARCHAR2,
     X_LOCALIZATION_CODE            IN     VARCHAR2,
     X_ORG_ID                       IN     NUMBER,
     X_SITE_ID                      IN     NUMBER,
     X_RESPONSIBILITY_ID            IN     NUMBER,
     X_WEB_USER_ID                  IN     NUMBER,
     X_DEFAULT_CUSTOMIZATION_FLAG   IN     VARCHAR2,
     X_CUSTOMIZATION_LEVEL_ID       IN     NUMBER,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_START_DATE_ACTIVE            IN     DATE,
     X_END_DATE_ACTIVE              IN     DATE,
     X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
     X_RF_CUSTOMIZATION_APPL_ID     IN     NUMBER DEFAULT NULL,
     X_RF_CUSTOMIZATION_CODE        IN     VARCHAR2 DEFAULT NULL,
     X_RF_REGION_APPLICATION_ID     IN     NUMBER DEFAULT NULL,
     X_RF_REGION_CODE               IN     VARCHAR2 DEFAULT NULL,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

  PROCEDURE update_criteria_template
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_NAME                         IN     VARCHAR2,
     X_DESCRIPTION                  IN     VARCHAR2,
     X_VERTICALIZATION_ID           IN     VARCHAR2,
     X_LOCALIZATION_CODE            IN     VARCHAR2,
     X_ORG_ID                       IN     NUMBER,
     X_SITE_ID                      IN     NUMBER,
     X_RESPONSIBILITY_ID            IN     NUMBER,
     X_WEB_USER_ID                  IN     NUMBER,
     X_DEFAULT_CUSTOMIZATION_FLAG   IN     VARCHAR2,
     X_CUSTOMIZATION_LEVEL_ID       IN     NUMBER,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_START_DATE_ACTIVE            IN     DATE,
     X_END_DATE_ACTIVE              IN     DATE,
     X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
     X_RF_CUSTOMIZATION_APPL_ID     IN     NUMBER DEFAULT NULL,
     X_RF_CUSTOMIZATION_CODE        IN     VARCHAR2 DEFAULT NULL,
     X_RF_REGION_APPLICATION_ID     IN     NUMBER DEFAULT NULL,
     X_RF_REGION_CODE               IN     VARCHAR2 DEFAULT NULL,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

 PROCEDURE delete_criteria_template
  (
     X_CUSTOMIZATION_APPLICATION_ID IN  NUMBER,
     X_CUSTOMIZATION_CODE           IN  VARCHAR2,
     X_REGION_APPLICATION_ID        IN  NUMBER,
     X_REGION_CODE                  IN  VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  );

  PROCEDURE translate_criteria_template
  (  p_customization_application_id  IN   NUMBER
    ,p_customization_code            IN   VARCHAR2
    ,p_region_application_id         IN   NUMBER
    ,p_region_code                   IN   VARCHAR2
    ,p_customization_level_id        IN   NUMBER
    ,p_last_update_date              IN   VARCHAR2
    ,p_last_updated_by               IN   NUMBER
    ,p_name                          IN   VARCHAR2
    ,p_description                   IN   VARCHAR2
    ,x_return_status                 OUT  NOCOPY VARCHAR2
    ,x_msg_data                      OUT  NOCOPY VARCHAR2
  );

---------------------------------------------------------
  PROCEDURE create_criteria_template_rf
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_RF_CUSTOMIZATION_APPL_ID     IN     NUMBER,
     X_RF_CUSTOMIZATION_CODE        IN     VARCHAR2,
     X_RF_REGION_APPLICATION_ID     IN     NUMBER,
     X_RF_REGION_CODE               IN     VARCHAR2,
     X_RF_TAG                       IN     VARCHAR2,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

  PROCEDURE update_criteria_template_rf
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_RF_CUSTOMIZATION_APPL_ID     IN     NUMBER,
     X_RF_CUSTOMIZATION_CODE        IN     VARCHAR2,
     X_RF_REGION_APPLICATION_ID     IN     NUMBER,
     X_RF_REGION_CODE               IN     VARCHAR2,
     X_RF_TAG                       IN     VARCHAR2,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

  PROCEDURE delete_criteria_template_rf
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_RF_TAG                       IN     VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

---------------------------------------------------------

  PROCEDURE create_result_format
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_NAME                         IN     VARCHAR2,
     X_DESCRIPTION                  IN     VARCHAR2,
     X_NUM_ROWS_DISPLAYED           IN     NUMBER,
     X_DEFAULT_RESULT_FLAG          IN     VARCHAR2,
     X_SITE_ID                      IN     NUMBER,
     X_WEB_USER_ID                  IN     NUMBER,
     X_CUSTOMIZATION_LEVEL_ID       IN     NUMBER,
     X_IMPORT_FLAG                  IN     VARCHAR2 DEFAULT NULL,
     X_DATA_LEVEL                   IN     VARCHAR2 DEFAULT NULL,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

  PROCEDURE update_result_format
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_NAME                         IN     VARCHAR2,
     X_DESCRIPTION                  IN     VARCHAR2,
     X_NUM_ROWS_DISPLAYED           IN     NUMBER,
     X_DEFAULT_RESULT_FLAG          IN     VARCHAR2,
     X_SITE_ID                      IN     NUMBER,
     X_WEB_USER_ID                  IN     NUMBER,
     X_CUSTOMIZATION_LEVEL_ID       IN     NUMBER,
     X_IMPORT_FLAG                  IN     VARCHAR2 DEFAULT NULL,
     X_DATA_LEVEL		    IN	   VARCHAR2 DEFAULT NULL, --Bug 6011948
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

 PROCEDURE delete_result_format
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  );

  PROCEDURE translate_result_format
  (  p_customization_application_id  IN   NUMBER
    ,p_customization_code            IN   VARCHAR2
    ,p_region_application_id         IN   NUMBER
    ,p_region_code                   IN   VARCHAR2
    ,p_last_update_date              IN   VARCHAR2
    ,p_last_updated_by               IN   NUMBER
    ,p_name                          IN   VARCHAR2
    ,p_description                   IN   VARCHAR2
    ,x_return_status                 OUT  NOCOPY VARCHAR2
    ,x_msg_data                      OUT  NOCOPY VARCHAR2
  );

---------------------------------------------------------

  PROCEDURE create_result_column
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_ORDER_SEQUENCE               IN     NUMBER,
     X_ORDER_DIRECTION              IN     VARCHAR2,
     X_COLUMN_NAME                  IN     VARCHAR2 := NULL,
     X_SHOW_TOTAL                   IN     VARCHAR2 := NULL,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

  PROCEDURE update_result_column
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_ORDER_SEQUENCE               IN     NUMBER,
     X_ORDER_DIRECTION              IN     VARCHAR2,
     X_COLUMN_NAME                  IN     VARCHAR2 := NULL,
     X_SHOW_TOTAL                   IN     VARCHAR2 := NULL,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

 PROCEDURE delete_result_column
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  );

---------------------------------------------------------

 PROCEDURE insert_criterion
  (
     X_ROWID                        IN OUT NOCOPY VARCHAR2,
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_SEQUENCE_NUMBER              IN     NUMBER,
     X_OPERATION                    IN     VARCHAR2,
     X_VALUE_VARCHAR2               IN     VARCHAR2,
     X_SECOND_VALUE_VARCHAR2        IN     VARCHAR2,
     X_VALUE_NUMBER                 IN     NUMBER,
     X_SECOND_VALUE_NUMBER          IN     NUMBER,
     X_VALUE_DATE                   IN     DATE,
     X_SECOND_VALUE_DATE            IN     DATE,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_START_DATE_ACTIVE            IN     DATE,
     X_END_DATE_ACTIVE              IN     DATE,
     X_USE_KEYWORD_SEARCH           IN     VARCHAR2 := 'Y',
     X_MATCH_CONDITION              IN     VARCHAR2 := 'ALL',
     X_FUZZY                        IN     VARCHAR2 := 'N',
     X_STEMMING                     IN     VARCHAR2 := 'N',
     X_SYNONYMS                     IN     VARCHAR2 := 'N',
     X_INIT_MSG_LIST                IN     VARCHAR2 := FND_API.G_FALSE
  );

  PROCEDURE update_criterion
  (
     X_ROWID                        IN OUT NOCOPY VARCHAR2,
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_SEQUENCE_NUMBER              IN NUMBER,
     X_OPERATION                    IN VARCHAR2,
     X_VALUE_VARCHAR2               IN VARCHAR2,
     X_SECOND_VALUE_VARCHAR2        IN VARCHAR2,
     X_VALUE_NUMBER                 IN NUMBER,
     X_SECOND_VALUE_NUMBER          IN NUMBER,
     X_VALUE_DATE                   IN DATE,
     X_SECOND_VALUE_DATE            IN DATE,
     X_LAST_UPDATED_BY              IN NUMBER,
     X_LAST_UPDATE_DATE             IN DATE,
     X_LAST_UPDATE_LOGIN            IN NUMBER,
     X_START_DATE_ACTIVE            IN DATE,
     X_END_DATE_ACTIVE              IN DATE,
     X_USE_KEYWORD_SEARCH           IN     VARCHAR2 := 'Y',
     X_MATCH_CONDITION              IN     VARCHAR2 := 'ALL',
     X_FUZZY                        IN     VARCHAR2 := 'N',
     X_STEMMING                     IN     VARCHAR2 := 'N',
     X_SYNONYMS                     IN     VARCHAR2 := 'N',
     X_INIT_MSG_LIST                IN VARCHAR2   := FND_API.G_FALSE
  );

  PROCEDURE delete_criterion
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_SEQUENCE_NUMBER              IN NUMBER,
     X_INIT_MSG_LIST                IN VARCHAR2   := FND_API.G_FALSE
  );

  PROCEDURE create_result_section
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

  PROCEDURE update_result_section
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  );

 PROCEDURE delete_result_section
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  );

  PROCEDURE Check_Result_Format_Deletion
  (
    X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
    X_CUSTOMIZATION_CODE           IN VARCHAR2,
    X_REGION_APPLICATION_ID        IN NUMBER,
    X_REGION_CODE                  IN VARCHAR2,
    X_INIT_MSG_LIST                IN VARCHAR2   := FND_API.G_FALSE,
    X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
    X_ERRORCODE                    OUT NOCOPY NUMBER
  );

END EGO_SEARCH_FWK_PUB;

 

/
