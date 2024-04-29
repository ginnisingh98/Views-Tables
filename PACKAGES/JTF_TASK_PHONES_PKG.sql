--------------------------------------------------------
--  DDL for Package JTF_TASK_PHONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_PHONES_PKG" AUTHID CURRENT_USER AS
/* $Header: jtftkphs.pls 115.18 2002/12/04 21:48:58 cjang ship $ */
   PROCEDURE insert_row (
      x_rowid                IN OUT NOCOPY  VARCHAR2,
      x_task_phone_id        IN       NUMBER,
      x_attribute5           IN       VARCHAR2,
      x_attribute6           IN       VARCHAR2,
      x_attribute7           IN       VARCHAR2,
      x_attribute8           IN       VARCHAR2,
      x_attribute9           IN       VARCHAR2,
      x_attribute10          IN       VARCHAR2,
      x_attribute11          IN       VARCHAR2,
      x_attribute12          IN       VARCHAR2,
      x_attribute13          IN       VARCHAR2,
      x_attribute14          IN       VARCHAR2,
      x_attribute15          IN       VARCHAR2,
      x_attribute_category   IN       VARCHAR2,
      x_attribute4           IN       VARCHAR2,
      x_attribute3           IN       VARCHAR2,
      x_task_contact_id      IN       NUMBER,
      x_attribute1           IN       VARCHAR2,
      x_attribute2           IN       VARCHAR2,
      x_phone_id             IN       NUMBER,
      x_creation_date        IN       DATE,
      x_created_by           IN       NUMBER,
      x_last_update_date     IN       DATE,
      x_last_updated_by      IN       NUMBER,
      x_last_update_login    IN       NUMBER,
      x_owner_table_name     IN       VARCHAR2 DEFAULT 'JTF_TASK_CONTACTS',
      x_primary_flag         IN       VARCHAR2 DEFAULT NULL
   );

   PROCEDURE lock_row (
      x_task_phone_id           IN   NUMBER,
      x_object_version_number   IN   NUMBER
   );

   PROCEDURE update_row (
      x_task_phone_id           IN   NUMBER,
      x_object_version_number   IN   NUMBER,
      x_attribute5              IN   VARCHAR2,
      x_attribute6              IN   VARCHAR2,
      x_attribute7              IN   VARCHAR2,
      x_attribute8              IN   VARCHAR2,
      x_attribute9              IN   VARCHAR2,
      x_attribute10             IN   VARCHAR2,
      x_attribute11             IN   VARCHAR2,
      x_attribute12             IN   VARCHAR2,
      x_attribute13             IN   VARCHAR2,
      x_attribute14             IN   VARCHAR2,
      x_attribute15             IN   VARCHAR2,
      x_attribute_category      IN   VARCHAR2,
      x_attribute4              IN   VARCHAR2,
      x_attribute3              IN   VARCHAR2,
      x_task_contact_id         IN   NUMBER,
      x_attribute1              IN   VARCHAR2,
      x_attribute2              IN   VARCHAR2,
      x_phone_id                IN   NUMBER,
      x_last_update_date        IN   DATE,
      x_last_updated_by         IN   NUMBER,
      x_last_update_login       IN   NUMBER,
      x_owner_table_name        IN   VARCHAR2 DEFAULT 'JTF_TASK_CONTACTS',
      x_primary_flag            IN   VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   );

   PROCEDURE delete_row (x_task_phone_id IN NUMBER);
END jtf_task_phones_pkg;

 

/
