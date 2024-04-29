--------------------------------------------------------
--  DDL for Package Body CN_JOB_TITLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_JOB_TITLE_PKG" AS
/*$Header: cntjobb.pls 115.4 2002/11/21 21:09:45 hlchen ship $*/

PROCEDURE Insert_Row(newrec IN OUT
                     CN_JOB_TITLE_PVT.JOB_ROLE_REC_TYPE) IS
BEGIN
   -- get the next pk from sequence
   SELECT cn_job_roles_s.nextval
     INTO newrec.job_role_id
     FROM dual;

   INSERT into cn_job_roles
     (job_role_id,
      job_title_id,
      role_id,
      start_date,
      end_date,
      default_flag,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by,
      object_version_number)
     VALUES
     (newrec.job_role_id,
      newrec.job_title_id,
      newrec.role_id,
      newrec.start_date,
      newrec.end_date,
      newrec.default_flag,
      newrec.attribute_category,
      newrec.attribute1,
      newrec.attribute2,
      newrec.attribute3,
      newrec.attribute4,
      newrec.attribute5,
      newrec.attribute6,
      newrec.attribute7,
      newrec.attribute8,
      newrec.attribute9,
      newrec.attribute10,
      newrec.attribute11,
      newrec.attribute12,
      newrec.attribute13,
      newrec.attribute14,
      newrec.attribute15,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id,
      sysdate,
      fnd_global.user_id,
      1);
END Insert_Row;

PROCEDURE Update_Row(newrec
		     CN_JOB_TITLE_PVT.JOB_ROLE_REC_TYPE) IS
   CURSOR c IS
      SELECT *
        FROM cn_job_roles
        WHERE job_role_id = newrec.job_role_id;
   oldrec c%ROWTYPE;
BEGIN
   open  c;
   fetch c into oldrec;
   close c;

   update cn_job_roles set
     job_title_id      = decode(newrec.job_title_id,       fnd_api.g_miss_num,
                                oldrec.job_title_id,
                                newrec.job_title_id),
     role_id           = decode(newrec.role_id,            fnd_api.g_miss_char,
                                oldrec.role_id,
                                newrec.role_id),
     start_date        = decode(newrec.start_date,         fnd_api.g_miss_date,
                                oldrec.start_date,
                                newrec.start_date),
     end_date          = decode(newrec.end_date,           fnd_api.g_miss_date,
                                oldrec.end_date,
                                newrec.end_date),
     default_flag      = decode(newrec.default_flag,       fnd_api.g_miss_char,
                                oldrec.default_flag,
                                newrec.default_flag),
     attribute_category= decode(newrec.attribute_category, fnd_api.g_miss_char,
                                oldrec.attribute_category,
                                newrec.attribute_category),
     attribute1        = decode(newrec.attribute1,         fnd_api.g_miss_char,
                                oldrec.attribute1,
                                newrec.attribute1),
     attribute2        = decode(newrec.attribute2,         fnd_api.g_miss_char,
                                oldrec.attribute2,
                                newrec.attribute2),
     attribute3        = decode(newrec.attribute3,         fnd_api.g_miss_char,
                                oldrec.attribute3,
                                newrec.attribute3),
     attribute4        = decode(newrec.attribute4,         fnd_api.g_miss_char,
                                oldrec.attribute4,
                                newrec.attribute4),
     attribute5        = decode(newrec.attribute5,         fnd_api.g_miss_char,
                                oldrec.attribute5,
                                newrec.attribute5),
     attribute6        = decode(newrec.attribute6,         fnd_api.g_miss_char,
                                oldrec.attribute6,
                                newrec.attribute6),
     attribute7        = decode(newrec.attribute7,         fnd_api.g_miss_char,
                                oldrec.attribute7,
                                newrec.attribute7),
     attribute8        = decode(newrec.attribute8,         fnd_api.g_miss_char,
                                oldrec.attribute8,
                                newrec.attribute8),
     attribute9        = decode(newrec.attribute9,         fnd_api.g_miss_char,
                                oldrec.attribute9,
                                newrec.attribute9),
     attribute10       = decode(newrec.attribute10,        fnd_api.g_miss_char,
                                oldrec.attribute10,
                                newrec.attribute10),
     attribute11       = decode(newrec.attribute11,        fnd_api.g_miss_char,
                                oldrec.attribute11,
                                newrec.attribute11),
     attribute12       = decode(newrec.attribute12,        fnd_api.g_miss_char,
                                oldrec.attribute12,
                                newrec.attribute12),
     attribute13       = decode(newrec.attribute13,        fnd_api.g_miss_char,
                                oldrec.attribute13,
                                newrec.attribute13),
     attribute14       = decode(newrec.attribute14,        fnd_api.g_miss_char,
                                oldrec.attribute14,
                                newrec.attribute14),
     attribute15       = decode(newrec.attribute15,        fnd_api.g_miss_char,
                                oldrec.attribute15,
                                newrec.attribute15),
     last_update_login = fnd_global.login_id,
     last_update_date  = sysdate,
     last_updated_by   = fnd_global.user_id,
     object_version_number = oldrec.object_version_number + 1
     where job_role_id = oldrec.job_role_id;
END Update_Row;

PROCEDURE LOCK_ROW
  (p_job_role_id           IN NUMBER,
   p_object_version_number IN NUMBER) IS

   cursor c is
   select object_version_number
     from cn_job_roles
    where job_role_id = p_job_role_id
      for update of job_role_id nowait;
    tlinfo c%rowtype ;
BEGIN
   open  c;
   fetch c into tlinfo;
   if (c%notfound) then
      close c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   close c;

   if (tlinfo.object_version_number <> p_object_version_number) then
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;

END LOCK_ROW;

PROCEDURE Delete_Row(p_job_role_id NUMBER) IS
BEGIN
   DELETE from cn_job_roles
     WHERE job_role_id = p_job_role_id;
   if (sql%notfound) then
      raise no_data_found;
   end if;

END Delete_Row;

END CN_JOB_TITLE_PKG;


/
