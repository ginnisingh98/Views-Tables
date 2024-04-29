--------------------------------------------------------
--  DDL for Package Body IGW_PROP_ABSTRACTS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_ABSTRACTS_TBH" AS
/* $Header: igwtabsb.pls 115.6 2002/11/14 18:51:19 vmedikon ship $ */

   ---------------------------------------------------------------------------

   G_PKG_NAME VARCHAR2(30) := 'IGW_PROP_ABSTRACTS_TBH';

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid              OUT NOCOPY VARCHAR2,
      p_proposal_id        IN NUMBER,
      p_abstract_type      IN VARCHAR2,
      p_abstract_type_code IN VARCHAR2,
      p_abstract           IN VARCHAR2,
      p_attribute_category IN VARCHAR2,
      p_attribute1         IN VARCHAR2,
      p_attribute2         IN VARCHAR2,
      p_attribute3         IN VARCHAR2,
      p_attribute4         IN VARCHAR2,
      p_attribute5         IN VARCHAR2,
      p_attribute6         IN VARCHAR2,
      p_attribute7         IN VARCHAR2,
      p_attribute8         IN VARCHAR2,
      p_attribute9         IN VARCHAR2,
      p_attribute10        IN VARCHAR2,
      p_attribute11        IN VARCHAR2,
      p_attribute12        IN VARCHAR2,
      p_attribute13        IN VARCHAR2,
      p_attribute14        IN VARCHAR2,
      p_attribute15        IN VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2,
      p_mode               IN VARCHAR2 default 'R'
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Insert_Row';

      l_last_update_date  DATE         := SYSDATE;
      l_last_updated_by   NUMBER       := Nvl(Fnd_Global.User_Id,-1);
      l_last_update_login NUMBER       := Nvl(Fnd_Global.Login_Id,-1);

      CURSOR c IS
      SELECT rowid
      FROM   igw_prop_abstracts
      WHERE  proposal_id = p_proposal_id AND
             abstract_type = p_abstract_type AND
             abstract_type_code = p_abstract_type_code;

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_mode = 'I' THEN

         l_last_updated_by := 1;
         l_last_update_login := 0;

      ELSIF p_mode <> 'R' THEN

         Fnd_Message.Set_Name('FND','SYSTEM-INVALID ARGS');
         App_Exception.Raise_Exception;

      END IF;

      INSERT INTO igw_prop_abstracts
      (
         proposal_id,
         abstract_type,
         abstract_type_code,
         abstract,
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
         record_version_number,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login
      )
      VALUES
      (
         p_proposal_id,                             /* proposal_id */
         p_abstract_type,                         /* abstract_type */
         p_abstract_type_code,               /* abstract_type_code */
         p_abstract,                                   /* abstract */
         p_attribute_category,               /* attribute_category */
         p_attribute1,                               /* attribute1 */
         p_attribute2,                               /* attribute2 */
         p_attribute3,                               /* attribute3 */
         p_attribute4,                               /* attribute4 */
         p_attribute5,                               /* attribute5 */
         p_attribute6,                               /* attribute6 */
         p_attribute7,                               /* attribute7 */
         p_attribute8,                               /* attribute8 */
         p_attribute9,                               /* attribute9 */
         p_attribute10,                             /* attribute10 */
         p_attribute11,                             /* attribute11 */
         p_attribute12,                             /* attribute12 */
         p_attribute13,                             /* attribute13 */
         p_attribute14,                             /* attribute14 */
         p_attribute15,                             /* attribute15 */
         1,                               /* record_version_number */
         l_last_update_date,                      /* creation_date */
         l_last_updated_by,                          /* created_by */
         l_last_update_date,                   /* last_update_date */
         l_last_updated_by,                     /* last_updated_by */
         l_last_update_login                  /* last_update_login */
      );

      OPEN c;
      FETCH c INTO x_rowid;

      IF c%NotFound THEN

         CLOSE c;
         RAISE no_data_found;

      END IF;

      CLOSE c;

   EXCEPTION

      WHEN others THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Insert_Row;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Row
   (
      p_rowid                 IN VARCHAR2,
      p_proposal_id           IN NUMBER,
      p_abstract_type         IN VARCHAR2,
      p_abstract_type_code    IN VARCHAR2,
      p_abstract              IN VARCHAR2,
      p_attribute_category    IN VARCHAR2,
      p_attribute1            IN VARCHAR2,
      p_attribute2            IN VARCHAR2,
      p_attribute3            IN VARCHAR2,
      p_attribute4            IN VARCHAR2,
      p_attribute5            IN VARCHAR2,
      p_attribute6            IN VARCHAR2,
      p_attribute7            IN VARCHAR2,
      p_attribute8            IN VARCHAR2,
      p_attribute9            IN VARCHAR2,
      p_attribute10           IN VARCHAR2,
      p_attribute11           IN VARCHAR2,
      p_attribute12           IN VARCHAR2,
      p_attribute13           IN VARCHAR2,
      p_attribute14           IN VARCHAR2,
      p_attribute15           IN VARCHAR2,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      p_mode                  IN VARCHAR2 default 'R'
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Update_Row';

      l_last_update_date  DATE         := SYSDATE;
      l_last_updated_by   NUMBER       := Nvl(Fnd_Global.User_Id,-1);
      l_last_update_login NUMBER       := Nvl(Fnd_Global.Login_Id,-1);

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_mode = 'I' THEN

         l_last_updated_by := 1;
         l_last_update_login := 0;

      ELSIF p_mode <> 'R' THEN

         Fnd_Message.Set_Name('FND','SYSTEM-INVALID ARGS');
         Fnd_Msg_Pub.Add;
         App_Exception.Raise_Exception;

      END IF;

      UPDATE igw_prop_abstracts
      SET    proposal_id = p_proposal_id,
             abstract_type = p_abstract_type,
             abstract_type_code = p_abstract_type_code,
             abstract = p_abstract,
             attribute_category = p_attribute_category,
             attribute1 = p_attribute1,
             attribute2 = p_attribute2,
             attribute3 = p_attribute3,
             attribute4 = p_attribute4,
             attribute5 = p_attribute5,
             attribute6 = p_attribute6,
             attribute7 = p_attribute7,
             attribute8 = p_attribute8,
             attribute9 = p_attribute9,
             attribute10 = p_attribute10,
             attribute11 = p_attribute11,
             attribute12 = p_attribute12,
             attribute13 = p_attribute13,
             attribute14 = p_attribute14,
             attribute15 = p_attribute15,
             record_version_number = record_version_number + 1,
             last_update_date = l_last_update_date,
             last_updated_by = l_last_updated_by,
             last_update_login = l_last_update_login
      WHERE  rowid = p_rowid
      AND    record_version_number = p_record_version_number;

      IF SQL%NotFound THEN

         Fnd_Message.Set_Name('IGW','IGW_SS_RECORD_CHANGED');
         Fnd_Msg_Pub.Add;
         App_Exception.Raise_Exception;

      END IF;

   EXCEPTION

      WHEN others THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Update_Row;

   ---------------------------------------------------------------------------

END Igw_Prop_Abstracts_Tbh;

/
