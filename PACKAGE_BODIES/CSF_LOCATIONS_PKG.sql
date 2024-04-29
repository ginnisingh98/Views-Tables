--------------------------------------------------------
--  DDL for Package Body CSF_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_LOCATIONS_PKG" AS
/* $Header: CSFVLOCB.pls 120.4 2006/03/28 01:55:42 abhijkum noship $ */


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
   )
   IS
      CURSOR c
      IS
         SELECT csf_ext_location_id
           FROM csf_ext_locations
          WHERE location_id = p_location_id;
   BEGIN
      INSERT INTO csf_ext_locations
                  (csf_ext_location_id ,
                   last_update_date ,
                   last_updated_by ,
                   creation_date ,
                   created_by ,
                   last_update_login ,
                   request_id ,
                   program_application_id ,
                   program_id ,
                   program_update_date ,
                   task_id ,
                   location_id ,
                   validated_flag ,
                   override_flag ,
                   log_detail_short ,
                   log_detail_long
                  )
           VALUES (p_csf_ext_location_id ,
                   p_last_update_date ,
                   p_last_updated_by ,
                   p_creation_date ,
                   p_created_by ,
                   p_last_update_login ,
                   p_request_id ,
                   p_program_application_id ,
                   p_program_id ,
                   p_program_update_date ,
                   p_task_id ,
                   p_location_id ,
                   p_validated_flag ,
                   p_override_flag ,
                   p_log_detail_short ,
                   p_log_detail_long
                  );

      OPEN c;

      FETCH c
       INTO p_csf_ext_location_id;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;

         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;
   END insert_row_ext;



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
   )
   IS
      CURSOR c1
      IS
         SELECT        csf_ext_location_id ,
                       last_update_date ,
                       last_updated_by ,
                       creation_date ,
                       created_by ,
                       last_update_login ,
                       request_id ,
                       program_application_id ,
                       program_id ,
                       program_update_date ,
                       task_id ,
                       location_id ,
                       validated_flag ,
                       override_flag ,
                       log_detail_short ,

                       log_detail_long
                  FROM csf_ext_locations
                 WHERE location_id = p_location_id
         FOR UPDATE OF location_id NOWAIT;
   BEGIN
      FOR tlinfo IN c1
      LOOP
         IF (    (   (tlinfo.csf_ext_location_id = p_csf_ext_location_id)
                  OR (    (tlinfo.csf_ext_location_id IS NULL)
                      AND (p_csf_ext_location_id IS NULL)
                     )
                 )
             AND (   (tlinfo.last_update_date = p_last_update_date)
                  OR (    (tlinfo.last_update_date IS NULL)
                      AND (p_last_update_date IS NULL)
                     )
                 )
             AND (   (tlinfo.last_updated_by = p_last_updated_by)
                  OR (    (tlinfo.last_updated_by IS NULL)
                      AND (p_last_updated_by IS NULL)
                     )
                 )
             AND (   (tlinfo.creation_date = p_creation_date)
                  OR (    (tlinfo.creation_date IS NULL)
                      AND (p_creation_date IS NULL)
                     )
                 )
             AND (   (tlinfo.created_by = p_created_by)
                  OR ((tlinfo.created_by IS NULL) AND (p_created_by IS NULL)
                     )
                 )
             AND (   (tlinfo.last_update_login = p_last_update_login)
                  OR (    (tlinfo.last_update_login IS NULL)
                      AND (p_last_update_login IS NULL)
                     )
                 )
             AND (   (tlinfo.request_id = p_request_id)
                  OR ((tlinfo.request_id IS NULL) AND (p_request_id IS NULL)
                     )
                 )
             AND (   (tlinfo.program_application_id = p_program_application_id
                     )
                  OR (    (tlinfo.program_application_id IS NULL)
                      AND (p_program_application_id IS NULL)
                     )
                 )
             AND (   (tlinfo.program_id = p_program_id)
                  OR ((tlinfo.program_id IS NULL) AND (p_program_id IS NULL)
                     )
                 )
             AND (   (tlinfo.program_update_date = p_program_update_date)
                  OR (    (tlinfo.program_update_date IS NULL)
                      AND (p_program_update_date IS NULL)
                     )
                 )
             AND (   (tlinfo.task_id = p_task_id)
                  OR ((tlinfo.task_id IS NULL) AND (p_task_id IS NULL))
                 )
             AND (   (tlinfo.location_id = p_location_id)
                  OR (    (tlinfo.location_id IS NULL)
                      AND (p_location_id IS NULL)
                     )
                 )
             AND (   (tlinfo.validated_flag = p_validated_flag)
                  OR (    (tlinfo.validated_flag IS NULL)
                      AND (p_validated_flag IS NULL)
                     )
                 )
             AND (   (tlinfo.override_flag = p_override_flag)
                  OR (    (tlinfo.override_flag IS NULL)
                      AND (p_override_flag IS NULL)
                     )
                 )
             AND (   (tlinfo.log_detail_short = p_log_detail_short)
                  OR (    (tlinfo.log_detail_short IS NULL)
                      AND (p_log_detail_short IS NULL)
                     )
                 )
             AND (   (tlinfo.log_detail_long = p_log_detail_long)
                  OR (    (tlinfo.log_detail_long IS NULL)
                      AND (p_log_detail_long IS NULL)
                     )
                 )
            )
         THEN
            NULL;
         ELSE
            fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
            app_exception.raise_exception;
         END IF;
      END LOOP;
   END lock_row_ext;

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
   )
   IS
   BEGIN
      UPDATE csf_ext_locations
         SET csf_ext_location_id = p_csf_ext_location_id,
             last_update_date = p_last_update_date,
             last_updated_by = p_last_updated_by,
             last_update_login = p_last_update_login,
             request_id = p_request_id,
             program_application_id = p_program_application_id,
             program_id = p_program_id,
             program_update_date = p_program_update_date,
             location_id =
                DECODE (p_location_id,
                        NULL, location_id,
                        fnd_api.g_miss_char, NULL,
                        p_location_id
                       ),
             override_flag =
                DECODE (p_override_flag,
                        NULL, override_flag,
                        fnd_api.g_miss_char, NULL,
                        p_override_flag
                       ),
             validated_flag =
                DECODE (p_validated_flag,
                        NULL, validated_flag,
                        fnd_api.g_miss_char, NULL,
                        p_validated_flag
                       ),
             log_detail_short =
                DECODE (p_log_detail_short,
                        NULL, log_detail_short,
                        fnd_api.g_miss_char, NULL,
                        p_log_detail_short
                       ),
             log_detail_long =
                DECODE (p_log_detail_long,
                        NULL, log_detail_long,
                        fnd_api.g_miss_char, NULL,
                        p_log_detail_long
                       )
       WHERE location_id = p_location_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END update_row_ext;

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
   )
   IS
   BEGIN
      UPDATE hz_locations
         SET last_update_date = p_last_update_date,
             last_updated_by = p_last_updated_by,
             last_update_login = p_last_update_login,
             request_id = p_request_id,
             program_application_id = p_program_application_id,
             program_id = p_program_id,
             program_update_date = p_program_update_date,
             address1 =
                DECODE (p_address1,
                        NULL, address1,
                        fnd_api.g_miss_char, NULL,
                        p_address1
                       ),
             address2 = p_address2,
             address3 = p_address3,
             address4 = p_address4,
             city = p_city,
             postal_code = p_postal_code,
             county = p_county,
             state = p_state,
             province = p_province,
             country = p_country,
             validated_flag =
                DECODE (p_validated_flag,
                        NULL, validated_flag,
                        fnd_api.g_miss_char, NULL,
                        p_validated_flag
                       ),
            timezone_id =
                DECODE (p_timezone_id,
                        NULL, timezone_id,
                        fnd_api.g_miss_num, NULL,
                        p_timezone_id)
       WHERE location_id = p_location_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END update_row_hz;



   PROCEDURE delete_row_ext (p_location_id IN NUMBER)
   IS
   BEGIN
      DELETE FROM csf_ext_locations
            WHERE location_id = p_location_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END delete_row_ext;
END csf_locations_pkg;

/
