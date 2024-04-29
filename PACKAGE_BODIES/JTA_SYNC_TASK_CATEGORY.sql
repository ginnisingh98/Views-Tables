--------------------------------------------------------
--  DDL for Package Body JTA_SYNC_TASK_CATEGORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_SYNC_TASK_CATEGORY" AS
/* $Header: jtavstyb.pls 115.9 2002/12/13 22:28:29 cjang ship $ */
/*======================================================================+
|  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|          jtavstyb.pls                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|          This package body is for task categories.                    |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
|                                                                       |
| Date          Developer        Change                                 |
| ------        ---------------  -------------------------------------- |
| 12-Mar-2002   arpatel          created                                |
| 16-Apr-2002   sanjeev          changed create_category()              |
|                                 for fixing bugs                       |
| 24-Jun-2002   cjang            Fix bug 2418798 :                      |
|                                Added truncate_category_name()         |
|                                Modified create_category()             |
|                                         get_category_id() to truncate |
|                                category name if it's greater than 40. |
| 04-Oct-2002   cjang            Fix bug 2540722 :                      |
|                                Increase the length of category name   |
|                                   to 240 bytes                        |
|                                   in truncate_category_name()         |
|                                    and create_category()              |
*=======================================================================*/

   FUNCTION truncate_category_name(p_category_name IN VARCHAR2)
   RETURN VARCHAR2
   IS
      l_category_name VARCHAR2(240); -- Fix bug 2540722
   BEGIN
      IF LENGTHB(p_category_name) > 240 -- Fix bug 2540722
      THEN
         l_category_name := SUBSTRB(p_category_name, 1, 237)||'...'; -- -- Fix bug 2540722
      ELSE
         l_category_name := p_category_name;
      END IF;

      RETURN l_category_name;
   END truncate_category_name;

   FUNCTION get_category_id (
      p_category_name   IN  VARCHAR2,
      p_profile_id      IN  NUMBER
   ) RETURN NUMBER
   IS
       CURSOR c_category_id (b_category_name VARCHAR2) IS -- Fix bug 2418798
       SELECT perz_data_id
         FROM JTF_PERZ_DATA
        WHERE perz_data_desc = b_category_name
          AND profile_id = p_profile_id;

     l_category_id NUMBER;
   BEGIN
     OPEN c_category_id (truncate_category_name(p_category_name)); -- Fix bug 2418798
     FETCH c_category_id INTO l_category_id;
     CLOSE c_category_id;

     RETURN l_category_id;
   END get_category_id;

   PROCEDURE create_category (
         p_category_name      IN OUT NOCOPY VARCHAR2,
         p_resource_id        IN     NUMBER
   )
   IS
       CURSOR c_categories (b_profile_id NUMBER) IS
       SELECT perz_data_id
         FROM JTF_PERZ_DATA
        WHERE profile_id = b_profile_id;

       l_category_id     NUMBER;
       l_category_name   VARCHAR2(240) := truncate_category_name(p_category_name); --Fix bug 2418798, Fix bug 2540722
       l_profile_id      NUMBER;
       l_return_status   VARCHAR2(30);
       l_msg_count       NUMBER;
       l_msg_data        VARCHAR2(30);
       category_seq      NUMBER;
       l_perz_data_id    NUMBER;
       l_unfiled         VARCHAR2(240); -- Fix bug 2540722
       l_comma_location  NUMBER;

   BEGIN
       SELECT jtf_task_utl.get_category_name(NULL)
         INTO l_unfiled
         FROM DUAL;

       IF l_category_name IS NOT NULL AND
          l_category_name <> l_unfiled
       THEN
          l_profile_id  := get_profile_id ( p_resource_id => p_resource_id );
          l_comma_location := instr(l_category_name, ',');

          IF (l_comma_location > 0) THEN
             l_category_name := substr(l_category_name, 1, l_comma_location-1);
          END IF;

          -- get the category_id of the category name if it exists for this profile
          l_category_id := get_category_id (p_category_name => l_category_name,
                                            p_profile_id    => l_profile_id );

         --Dont create duplicate categories
         IF l_category_id IS NULL
         THEN
             SELECT jtf_task_category_s.nextval
               INTO category_seq
               FROM sys.dual;

             jtf_perz_data_pub.create_perz_data
             (p_api_version_number     => 1.0,
              p_application_id         => 690,
              p_profile_id             => l_profile_id,
              p_profile_name           => NULL,
              p_perz_data_id           => l_category_id,
              p_perz_data_name         => 'JTF_TASK_CATEGORY:' || category_seq,
              p_perz_data_type         => 'JTF_TASK_CATEGORY',
              p_perz_data_desc         => l_category_name,
              x_perz_data_id           => l_perz_data_id,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data
             );
         END IF;
       END IF;
   END create_category;

   FUNCTION get_profile_id (
      p_resource_id   IN  NUMBER
   ) RETURN NUMBER
   IS
   CURSOR c_profile_id IS
     SELECT profile_id
     FROM jtf_perz_profile
     WHERE profile_name = p_resource_id || ':JTF_TASK';

     l_profile_id NUMBER;
     l_profile_name VARCHAR2(100);
     l_return_status VARCHAR2(30);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(30);
   BEGIN

    IF p_resource_id IS NOT NULL THEN

       OPEN c_profile_id;
       FETCH c_profile_id INTO l_profile_id;
       CLOSE c_profile_id;

       IF l_profile_id IS NULL THEN
         --create new profile
         jtf_perz_profile_pub.Create_Profile
            ( p_api_version_number => 1.0,
              p_profile_id         => NULL,
              p_profile_name       => p_resource_id || ':JTF_TASK',
              x_profile_name       => l_profile_name,
              x_profile_id         => l_profile_id,
              x_return_status      => l_return_status,
              x_msg_count          => l_msg_count,
              x_msg_data           => l_msg_data
            );

            --check return status
            IF l_return_status = fnd_api.g_ret_sts_error
            THEN
                RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
            THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

       END IF;
    ELSE
         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NULL_RESOURCE_ID');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_CATEGORY.GET_PROFILE_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
    END IF;

    RETURN l_profile_id;
  END get_profile_id;

END jta_sync_task_category;   -- Package spec

/
