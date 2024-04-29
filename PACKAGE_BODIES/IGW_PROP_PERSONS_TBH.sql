--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSONS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSONS_TBH" AS
/* $Header: igwtperb.pls 115.6 2002/11/15 00:40:41 ashkumar ship $ */

   ---------------------------------------------------------------------------

   G_PKG_NAME VARCHAR2(30) := 'IGW_PROP_PERSONS_TBH';

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid                  OUT NOCOPY VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_person_id              IN NUMBER,
      p_person_party_id        IN NUMBER,
      p_proposal_role_code     IN VARCHAR2,
      p_pi_flag                IN VARCHAR2,
      p_key_person_flag        IN VARCHAR2,
      p_percent_effort         IN NUMBER,
      p_person_organization_id IN NUMBER,
      p_org_party_id           IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      p_mode                   IN  VARCHAR2
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Insert_Row';

      l_last_update_date  DATE         := SYSDATE;
      l_last_updated_by   NUMBER       := Nvl(Fnd_Global.User_Id,-1);
      l_last_update_login NUMBER       := Nvl(Fnd_Global.Login_Id,-1);

      l_person_sequence   NUMBER;

      CURSOR c IS
      SELECT rowid
      FROM   igw_prop_persons
      WHERE  proposal_id = p_proposal_id AND
             person_party_id = p_person_party_id;

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_mode = 'I' THEN

         l_last_updated_by := 1;
         l_last_update_login := 0;

      ELSIF p_mode <> 'R' THEN

         Fnd_Message.Set_Name('FND','SYSTEM-INVALID ARGS');
         App_Exception.Raise_Exception;

      END IF;

      SELECT Nvl(Max(person_sequence) + 1,1)
      INTO   l_person_sequence
      FROM   igw_prop_persons
      WHERE  proposal_id = p_proposal_id;

      INSERT INTO igw_prop_persons
      (
         proposal_id,
         person_id,
         person_party_id,
         person_sequence,
         proposal_role_code,
         pi_flag,
         key_person_flag,
         percent_effort,
         person_organization_id,
         org_party_id,
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
         p_person_id,                                 /* person_id */
         p_person_party_id,                     /* person_party_id */
         l_person_sequence,                     /* person_sequence */
         p_proposal_role_code,               /* proposal_role_code */
         p_pi_flag,                                     /* pi_flag */
         p_key_person_flag,                     /* key_person_flag */
         p_percent_effort,                       /* percent_effort */
         p_person_organization_id,       /* person_organization_id */
         p_org_party_id,                           /* org_party_id */
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
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_person_id              IN NUMBER,
      p_person_party_id        IN NUMBER,
      p_proposal_role_code     IN VARCHAR2,
      p_pi_flag                IN VARCHAR2,
      p_key_person_flag        IN VARCHAR2,
      p_percent_effort         IN NUMBER,
      p_person_organization_id IN NUMBER,
      p_org_party_id           IN NUMBER,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      p_mode                   IN  VARCHAR2
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

      UPDATE igw_prop_persons
      SET    proposal_id = p_proposal_id,
             person_id = p_person_id,
             person_party_id = p_person_party_id,
             proposal_role_code = p_proposal_role_code,
             pi_flag = p_pi_flag,
             key_person_flag = p_key_person_flag,
             percent_effort = p_percent_effort,
             person_organization_id = p_person_organization_id,
             org_party_id = p_org_party_id,
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

   PROCEDURE Delete_Row
   (
      p_rowid                 IN VARCHAR2,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Delete_Row';

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      DELETE igw_prop_persons
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

   END Delete_Row;

   ---------------------------------------------------------------------------

END Igw_Prop_Persons_Tbh;

/
