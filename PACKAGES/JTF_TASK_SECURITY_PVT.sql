--------------------------------------------------------
--  DDL for Package JTF_TASK_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_SECURITY_PVT" AUTHID CURRENT_USER AS
/* $Header: jtftktts.pls 115.13 2003/03/07 01:01:26 cjang ship $ */

  ----
  -- Constants for Task Data Security
  -- Added on August 1, 2002 by mmarovic
  ----
  TASK_OBJECT    CONSTANT VARCHAR2(30) := 'JTF_TASKS';

  READ_ROLE      CONSTANT VARCHAR2(30) := 'JTF_TASK_READ_ONLY';
  FULL_ROLE      CONSTANT VARCHAR2(30) := 'JTF_TASK_FULL_ACCESS';

  READ_PRIVILEGE CONSTANT VARCHAR2(30) := 'JTF_TASK_READ_ONLY';
  FULL_PRIVILEGE CONSTANT VARCHAR2(30) := 'JTF_TASK_FULL_ACCESS';

  RESOURCE_TASKS_SET    CONSTANT VARCHAR2(30) := 'JTF_TASK_RESOURCE_TASKS';

  ----
  -- Creted on July 22, 2002 by mmarovic
  -- This is a wrapper around FND function created to support Java API.
  -- Please do not use it before ask Milan or Girish.
  ----
  PROCEDURE get_privileges (
   p_api_version         IN  NUMBER,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value  IN  VARCHAR2 DEFAULT NULL, -- NULL= only chk global gnts
   p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_user_name           IN  VARCHAR2 DEFAULT NULL,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_privileges          OUT NOCOPY FND_TABLE_OF_VARCHAR2_30
   );

   FUNCTION check_privelege_for_task (
      p_task_id              NUMBER,
      p_resource_id          NUMBER,
      p_resource_type   IN   VARCHAR2
      )
      RETURN VARCHAR2;

   FUNCTION get_object_name (p_object_code IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_default_query (
      profilename        IN   VARCHAR2,
      p_parameter_name   IN   VARCHAR2
      )
      RETURN NUMBER;

   FUNCTION get_category_id (
      p_task_id              IN   NUMBER,
      p_resource_id          IN   NUMBER,
      p_resource_type_code   IN   VARCHAR2
      )
      RETURN NUMBER;

   FUNCTION check_private_task_privelege (
      p_task_id              IN   NUMBER,
      p_resource_id          IN   NUMBER,
      p_resource_type_code   IN   VARCHAR2
      )
      RETURN VARCHAR2;

   PROCEDURE delete_category (p_category_name IN VARCHAR2);

   FUNCTION priveleges_from_other_resource (
      logged_in_resource              IN   NUMBER,
      priveleges_from_resource_id     IN   NUMBER,
      priveleges_from_resource_type   IN   VARCHAR2
      )
      RETURN VARCHAR2;
END;

 

/
