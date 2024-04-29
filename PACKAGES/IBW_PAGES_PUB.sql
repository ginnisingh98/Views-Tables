--------------------------------------------------------
--  DDL for Package IBW_PAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_PAGES_PUB" AUTHID CURRENT_USER AS
/* $Header: ibwpgs.pls 120.5 2005/09/04 23:45 apgupta noship $ */
   PROCEDURE INSERT_ROW (
      x_rowid                    IN OUT NOCOPY   VARCHAR2,
      x_page_id                  IN              NUMBER,
      x_page_code                IN              VARCHAR2,
      x_page_status              IN              VARCHAR2,
      x_application_context      IN              VARCHAR2,
      x_business_context         IN              VARCHAR2,
      x_reference                IN              VARCHAR2,
      x_page_matching_criteria   IN              VARCHAR2,
      x_site_area_id             IN              NUMBER,
      x_page_matching_value      IN              VARCHAR2,
      x_object_version_number    IN              NUMBER,
      x_program_login_id         IN              NUMBER,
      x_request_id               IN              NUMBER,
      x_page_name                IN              VARCHAR2,
      x_description              IN              VARCHAR2,
      x_creation_date            IN              DATE,
      x_created_by               IN              NUMBER,
      x_last_update_date         IN              DATE,
      x_last_updated_by          IN              NUMBER,
      x_last_update_login        IN              NUMBER
   );

   PROCEDURE LOCK_ROW (
      x_page_id                  IN   NUMBER,
      x_page_code                IN   VARCHAR2,
      x_page_status              IN   VARCHAR2,
      x_application_context      IN   VARCHAR2,
      x_business_context         IN   VARCHAR2,
      x_reference                IN   VARCHAR2,
      x_page_matching_criteria   IN   VARCHAR2,
      x_site_area_id             IN   NUMBER,
      x_page_matching_value      IN   VARCHAR2,
      x_object_version_number    IN   NUMBER,
      x_program_login_id         IN   NUMBER,
      x_request_id               IN   NUMBER,
      x_page_name                IN   VARCHAR2,
      x_description              IN   VARCHAR2
   );

   PROCEDURE UPDATE_ROW (
      x_page_id                  IN   NUMBER,
      x_page_code                IN   VARCHAR2,
      x_page_status              IN   VARCHAR2,
      x_application_context      IN   VARCHAR2,
      x_business_context         IN   VARCHAR2,
      x_reference                IN   VARCHAR2,
      x_page_matching_criteria   IN   VARCHAR2,
      x_site_area_id             IN   NUMBER,
      x_page_matching_value      IN   VARCHAR2,
      x_object_version_number    IN   NUMBER,
      x_program_login_id         IN   NUMBER,
      x_request_id               IN   NUMBER,
      x_page_name                IN   VARCHAR2,
      x_description              IN   VARCHAR2,
      x_last_update_date         IN   DATE,
      x_last_updated_by          IN   NUMBER,
      x_last_update_login        IN   NUMBER,
      x_custom_mode              IN   VARCHAR2
   );

   PROCEDURE DELETE_ROW (x_page_id IN NUMBER);

   PROCEDURE ADD_LANGUAGE;

   PROCEDURE TRANSLATE_ROW (
      x_page_id            IN   NUMBER,
      x_page_name          IN   VARCHAR2,
      x_description        IN   VARCHAR2,
      x_owner              IN   VARCHAR2,
      x_custom_mode        IN   VARCHAR2,
      x_last_update_date   IN   VARCHAR2
   );

   PROCEDURE LOAD_ROW (
      x_page_id                  IN   NUMBER,
      x_page_code                IN   VARCHAR2,
      x_page_status              IN   VARCHAR2,
      x_application_context      IN   VARCHAR2,
      x_business_context         IN   VARCHAR2,
      x_reference                IN   VARCHAR2,
      x_page_matching_criteria   IN   VARCHAR2,
      x_site_area_id             IN   NUMBER,
      x_page_matching_value      IN   VARCHAR2,
      x_page_name                IN   VARCHAR2,
      x_description              IN   VARCHAR2,
      x_owner                    IN   VARCHAR2,
      x_custom_mode              IN   VARCHAR2,
      x_last_update_date         IN   VARCHAR2
   );

   PROCEDURE LOAD_SEED_ROW (
      x_upload_mode              IN   VARCHAR2,
      x_page_id                  IN   VARCHAR2,
      x_page_name                IN   VARCHAR2,
      x_description              IN   VARCHAR2,
      x_owner                    IN   VARCHAR2,
      x_custom_mode              IN   VARCHAR2,
      x_last_update_date         IN   VARCHAR2,
      x_page_code                IN   VARCHAR2,
      x_page_status              IN   VARCHAR2,
      x_application_context      IN   VARCHAR2,
      x_business_context         IN   VARCHAR2,
      x_reference                IN   VARCHAR2,
      x_page_matching_criteria   IN   VARCHAR2,
      x_site_area_id             IN   VARCHAR2,
      x_page_matching_value      IN   VARCHAR2
   );

   FUNCTION GET_SITEAREA_STATUS (x_site_area_id IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE FORCE_UPDATE_SITEAREA (
      x_site_area_id        IN   NUMBER,
      x_last_update_date    IN   DATE,
      x_last_updated_by     IN   NUMBER,
      x_last_update_login   IN   NUMBER
   );
END IBW_PAGES_PUB;

 

/
