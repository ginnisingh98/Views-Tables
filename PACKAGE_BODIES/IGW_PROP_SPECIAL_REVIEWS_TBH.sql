--------------------------------------------------------
--  DDL for Package Body IGW_PROP_SPECIAL_REVIEWS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_SPECIAL_REVIEWS_TBH" AS
/* $Header: igwtrevb.pls 115.4 2002/11/15 00:45:59 ashkumar ship $ */

   ---------------------------------------------------------------------------

   G_PKG_NAME VARCHAR2(30) := 'IGW_PROP_SPECIAL_REVIEWS_TBH';

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid                  OUT NOCOPY VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_special_review_code    IN VARCHAR2,
      p_special_review_type    IN VARCHAR2,
      p_approval_type_code     IN VARCHAR2,
      p_protocol_number        IN VARCHAR2,
      p_application_date       IN DATE,
      p_approval_date          IN DATE,
      p_comments               IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      p_mode                   IN  VARCHAR2 default 'R'
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Insert_Row';

      l_last_update_date  DATE         := SYSDATE;
      l_last_updated_by   NUMBER       := Nvl(Fnd_Global.User_Id,-1);
      l_last_update_login NUMBER       := Nvl(Fnd_Global.Login_Id,-1);

      l_person_sequence   NUMBER;

      CURSOR c IS
      SELECT rowid
      FROM   igw_prop_special_reviews
      WHERE  proposal_id = p_proposal_id AND
             special_review_code = p_special_review_code;

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_mode = 'I' THEN

         l_last_updated_by := 1;
         l_last_update_login := 0;

      ELSIF p_mode <> 'R' THEN

         Fnd_Message.Set_Name('FND','SYSTEM-INVALID ARGS');
         App_Exception.Raise_Exception;

      END IF;


      INSERT INTO igw_prop_special_reviews
      (
         proposal_id,
         special_review_code,
         special_review_type,
         approval_type_code,
         protocol_number,
         application_date,
         approval_date,
         comments,
         record_version_number,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login
      )
      VALUES
      (
         p_proposal_id,                         /* proposal_id */
         p_special_review_code,                 /* special review code */
         p_special_review_type,                 /* special review type */
         p_approval_type_code,                  /* approval code */
         p_protocol_number,                     /* protocol number */
         p_application_date,                    /* application date  */
         p_approval_date,                       /* approval date */
         p_comments,                            /* comments */
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
      p_special_review_code    IN VARCHAR2,
      p_special_review_type    IN VARCHAR2,
      p_approval_type_code     IN VARCHAR2,
      p_protocol_number        IN VARCHAR2,
      p_application_date       IN DATE,
      p_approval_date          IN DATE,
      p_comments               IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      p_mode                   IN  VARCHAR2 default 'R'
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

      UPDATE igw_prop_special_reviews
      SET    proposal_id = p_proposal_id,
             special_review_code = p_special_review_code,
             special_review_type = p_special_review_type,
             approval_type_code = p_approval_type_code,
             protocol_number = p_protocol_number,
             application_date = p_application_date,
             approval_date = p_approval_date,
             comments      =p_comments,
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

      DELETE igw_prop_special_reviews
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

END Igw_Prop_Special_Reviews_Tbh;

/
