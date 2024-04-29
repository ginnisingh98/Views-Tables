--------------------------------------------------------
--  DDL for Package Body IGW_PROJECT_FUNDINGS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROJECT_FUNDINGS_TBH" AS
/* $Header: igwtapfb.pls 115.6 2002/11/15 00:52:35 ashkumar noship $ */

   ---------------------------------------------------------------------------

   G_PKG_NAME VARCHAR2(30) := 'IGW_PROJECT_FUNDINGS_TBH';

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid                   OUT NOCOPY VARCHAR2,
      x_proposal_funding_id     OUT NOCOPY NUMBER,
      p_proposal_installment_id IN NUMBER,
      p_project_id              IN NUMBER,
      p_task_id                 IN NUMBER,
      p_funding_amount          IN NUMBER,
      p_date_allocated          IN DATE,
      x_return_status           OUT NOCOPY VARCHAR2,
      p_mode                    IN  VARCHAR2
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Insert_Row';

      l_last_update_date  DATE         := SYSDATE;
      l_last_updated_by   NUMBER       := Nvl(Fnd_Global.User_Id,-1);
      l_last_update_login NUMBER       := Nvl(Fnd_Global.Login_Id,-1);

      CURSOR c IS
      SELECT rowid
      FROM   igw_project_fundings
      WHERE  proposal_funding_id = x_proposal_funding_id;

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_mode = 'I' THEN

         l_last_updated_by := 1;
         l_last_update_login := 0;

      ELSIF p_mode <> 'R' THEN

         Fnd_Message.Set_Name('FND','SYSTEM-INVALID ARGS');
         App_Exception.Raise_Exception;

      END IF;

      INSERT INTO igw_project_fundings
      (
         proposal_funding_id,
         proposal_installment_id,
         project_id,
         task_id,
         funding_amount,
         date_allocated,
         record_version_number,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login
      )
      VALUES
      (
         igw_project_fundings_s.nextval,
         p_proposal_installment_id,
         p_project_id,
         p_task_id,
         p_funding_amount,
         p_date_allocated,
         1,
         l_last_update_date,
         l_last_updated_by,
         l_last_update_date,
         l_last_updated_by,
         l_last_update_login
      )
      RETURNING
         proposal_funding_id
      INTO
         x_proposal_funding_id;

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
      p_rowid                   IN VARCHAR2,
      p_proposal_funding_id     IN NUMBER,
      p_proposal_installment_id IN NUMBER,
      p_project_id              IN NUMBER,
      p_task_id                 IN NUMBER,
      p_funding_amount          IN NUMBER,
      p_date_allocated          IN DATE,
      x_return_status           OUT NOCOPY VARCHAR2,
      p_mode                    IN  VARCHAR2
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

      UPDATE igw_project_fundings
      SET    proposal_installment_id = p_proposal_installment_id,
             project_id = p_project_id,
             task_id = p_task_id,
             funding_amount = p_funding_amount,
             date_allocated = p_date_allocated,
             record_version_number = record_version_number + 1,
             last_update_date = l_last_update_date,
             last_updated_by = l_last_updated_by,
             last_update_login = l_last_update_login
      WHERE  (rowid = p_rowid OR proposal_funding_id = p_proposal_funding_id);

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
      x_return_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Delete_Row';

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      DELETE igw_project_fundings
      WHERE  rowid = p_rowid;

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

END Igw_Project_Fundings_Tbh;

/
