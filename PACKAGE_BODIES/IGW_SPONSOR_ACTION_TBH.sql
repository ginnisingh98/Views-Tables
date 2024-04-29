--------------------------------------------------------
--  DDL for Package Body IGW_SPONSOR_ACTION_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_SPONSOR_ACTION_TBH" AS
/* $Header: igwtspab.pls 115.4 2003/02/19 00:35:21 ashkumar noship $ */

   ---------------------------------------------------------------------------

   G_PKG_NAME VARCHAR2(30) := 'IGW_SPONSOR_ACTION_TBH';

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Sponsor_Action(p_proposal_id NUMBER) IS

      CURSOR cur_latest_action IS
      SELECT sponsor_action_code,
             sponsor_action_date,
             comments
      FROM   igw_prop_comments
      WHERE  proposal_id = p_proposal_id
      AND    sponsor_action_code IS NOT NULL
      ORDER BY sponsor_action_date desc, creation_date desc;

      l_sponsor_action_code    Igw_Proposals_All.sponsor_action_code%type;
      l_sponsor_action_date    Igw_Proposals_All.sponsor_action_date%type;
      l_comments               Igw_Proposals_All.sponsor_action_comments%type;

   BEGIN

      OPEN  cur_latest_action;
      FETCH cur_latest_action INTO l_sponsor_action_code, l_sponsor_action_date, l_comments;

      IF cur_latest_action%FOUND THEN

         UPDATE igw_proposals_all
         SET    sponsor_action_code = l_sponsor_action_code,
                sponsor_action_date = l_sponsor_action_date,
                sponsor_action_comments = l_comments
         WHERE  proposal_id = p_proposal_id;

      END IF;

      CLOSE cur_latest_action;

   END;

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid              OUT NOCOPY VARCHAR2,
      p_proposal_id        IN NUMBER,
      p_comments           IN VARCHAR2,
      p_sponsor_action_code in varchar2,
      p_sponsor_action_date in date,
      x_return_status      OUT NOCOPY VARCHAR2,
      p_mode               IN VARCHAR2 default 'R'
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Insert_Row';

      l_last_update_date  DATE         := SYSDATE;
      l_last_updated_by   NUMBER       := Nvl(Fnd_Global.User_Id,-1);
      l_last_update_login NUMBER       := Nvl(Fnd_Global.Login_Id,-1);

      CURSOR c IS
      SELECT rowid
      FROM   igw_prop_comments
      WHERE  proposal_id = p_proposal_id AND
             trunc(last_update_date) = trunc(SYSDATE);

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_mode = 'I' THEN

         l_last_updated_by := 1;
         l_last_update_login := 0;

      ELSIF p_mode <> 'R' THEN

         Fnd_Message.Set_Name('FND','SYSTEM-INVALID ARGS');
         App_Exception.Raise_Exception;

      END IF;

      INSERT INTO igw_prop_comments
      (
         proposal_id,
         comment_id,
         comments,
         sponsor_action_code,
         sponsor_action_date,
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
         igw_prop_comments_s.nextval,                /* comment_id */
         p_comments,                                   /* comments */
         p_sponsor_action_code,
         p_sponsor_action_date,
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

      Update_Prop_Sponsor_Action(p_proposal_id);

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
      p_comment_id            IN NUMBER,
      p_comments              IN VARCHAR2,
      p_sponsor_action_code in varchar2,
      p_sponsor_action_date in date,
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

      UPDATE igw_prop_comments
      SET    sponsor_action_code = p_sponsor_action_code,
             sponsor_action_date = p_sponsor_action_date,
             comments = p_comments,
             record_version_number = record_version_number + 1,
             last_update_date = l_last_update_date,
             last_updated_by = l_last_updated_by,
             last_update_login = l_last_update_login
      WHERE  ((rowid = p_rowid) OR
              (proposal_id = p_proposal_id AND comment_id = p_comment_id))
      AND    record_version_number = p_record_version_number;

      IF SQL%NotFound THEN

         Fnd_Message.Set_Name('IGW','IGW_SS_RECORD_CHANGED');
         Fnd_Msg_Pub.Add;
         App_Exception.Raise_Exception;

      END IF;

      Update_Prop_Sponsor_Action(p_proposal_id);

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
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Delete_Row';

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      DELETE igw_prop_comments
      WHERE  rowid = p_rowid
      AND    record_version_number = p_record_version_number;

      IF SQL%NotFound THEN

         Fnd_Message.Set_Name('IGW','IGW_SS_RECORD_CHANGED');
         Fnd_Msg_Pub.Add;
         App_Exception.Raise_Exception;

      END IF;

      Update_Prop_Sponsor_Action(p_proposal_id);

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

END IGW_SPONSOR_ACTION_TBH;

/
