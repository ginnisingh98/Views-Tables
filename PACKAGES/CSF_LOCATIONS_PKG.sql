--------------------------------------------------------
--  DDL for Package CSF_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_LOCATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: CSFVLOCS.pls 120.3 2005/09/20 11:13:44 venjayar noship $ */

   PROCEDURE insert_row_ext (
      p_csf_ext_location_id      IN OUT NOCOPY   NUMBER,
      p_last_update_date         IN              DATE,
      p_last_updated_by          IN              NUMBER,
      p_creation_date            IN              DATE,
      p_created_by               IN              NUMBER,
      p_last_update_login        IN              NUMBER,
      p_request_id               IN              NUMBER,
      p_program_application_id   IN              NUMBER,
      p_program_id               IN              NUMBER,
      p_program_update_date      IN              DATE,
      p_task_id                  IN              NUMBER,
      p_location_id              IN              NUMBER,
      p_validated_flag           IN              VARCHAR2,
      p_override_flag            IN              VARCHAR2,
      p_log_detail_short         IN              VARCHAR2,
      p_log_detail_long          IN              VARCHAR2
   );

   PROCEDURE lock_row_ext (
      p_csf_ext_location_id      IN   NUMBER,
      p_last_update_date         IN   DATE,
      p_last_updated_by          IN   NUMBER,
      p_creation_date            IN   DATE,
      p_created_by               IN   NUMBER,
      p_last_update_login        IN   NUMBER,
      p_request_id               IN   NUMBER,
      p_program_application_id   IN   NUMBER,
      p_program_id               IN   NUMBER,
      p_program_update_date      IN   DATE,
      p_task_id                  IN   NUMBER,
      p_location_id              IN   NUMBER,
      p_validated_flag           IN   VARCHAR2,
      p_override_flag            IN   VARCHAR2,
      p_log_detail_short         IN   VARCHAR2,
      p_log_detail_long          IN   VARCHAR2
   );

   PROCEDURE update_row_ext (
      p_csf_ext_location_id      IN   NUMBER,
      p_last_update_date         IN   DATE,
      p_last_updated_by          IN   NUMBER,
      p_last_update_login        IN   NUMBER,
      p_request_id               IN   NUMBER,
      p_program_application_id   IN   NUMBER,
      p_program_id               IN   NUMBER,
      p_program_update_date      IN   DATE,
      p_location_id              IN   NUMBER,
      p_validated_flag           IN   VARCHAR2,
      p_override_flag            IN   VARCHAR2,
      p_log_detail_short         IN   VARCHAR2,
      p_log_detail_long          IN   VARCHAR2
   );

   PROCEDURE update_row_hz (
      p_last_update_date         IN   DATE,
      p_last_updated_by          IN   NUMBER,
      p_last_update_login        IN   NUMBER,
      p_request_id               IN   NUMBER,
      p_program_application_id   IN   NUMBER,
      p_program_id               IN   NUMBER,
      p_program_update_date      IN   DATE,
      p_address1                 IN   VARCHAR2,
      p_address2                 IN   VARCHAR2,
      p_address3                 IN   VARCHAR2,
      p_address4                 IN   VARCHAR2,
      p_city                     IN   VARCHAR2,
      p_postal_code              IN   VARCHAR2,
      p_county                   IN   VARCHAR2,
      p_state                    IN   VARCHAR2,
      p_province                 IN   VARCHAR2,
      p_country                  IN   VARCHAR2,
      p_validated_flag           IN   VARCHAR2 DEFAULT NULL,
      p_location_id              IN   NUMBER,
      p_timezone_id              IN   NUMBER
   );

   PROCEDURE delete_row_ext (p_location_id IN NUMBER);
END csf_locations_pkg;

 

/
