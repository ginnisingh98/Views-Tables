--------------------------------------------------------
--  DDL for Package Body IGW_INSTALLMENTS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_INSTALLMENTS_TBH" AS
/* $Header: igwtinsb.pls 115.2 2002/11/15 00:52:47 ashkumar noship $ */

   ---------------------------------------------------------------------------

   G_PKG_NAME VARCHAR2(30) := 'IGW_INSTALLMENTS_TBH';

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid                   OUT NOCOPY VARCHAR2,
      x_proposal_installment_id OUT NOCOPY NUMBER,
      p_proposal_award_id       IN NUMBER,
      p_installment_id          IN NUMBER,
      p_installment_number      IN VARCHAR2,
      p_installment_type_code   IN VARCHAR2,
      p_issue_date              IN DATE,
      p_close_date              IN DATE,
      p_start_date              IN DATE,
      p_end_date                IN DATE,
      p_direct_cost             IN NUMBER,
      p_indirect_cost           IN NUMBER,
      p_billable_flag           IN VARCHAR2,
      p_description             IN VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2,
      p_mode                    IN  VARCHAR2
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Insert_Row';

      l_last_update_date  DATE         := SYSDATE;
      l_last_updated_by   NUMBER       := Nvl(Fnd_Global.User_Id,-1);
      l_last_update_login NUMBER       := Nvl(Fnd_Global.Login_Id,-1);

      CURSOR c IS
      SELECT rowid
      FROM   igw_installments
      WHERE  proposal_installment_id = x_proposal_installment_id;

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_mode = 'I' THEN

         l_last_updated_by := 1;
         l_last_update_login := 0;

      ELSIF p_mode <> 'R' THEN

         Fnd_Message.Set_Name('FND','SYSTEM-INVALID ARGS');
         App_Exception.Raise_Exception;

      END IF;

      INSERT INTO igw_installments
      (
         proposal_installment_id,
         proposal_award_id,
         installment_id,
         installment_number,
         installment_type_code,
         issue_date,
         close_date,
         start_date,
         end_date,
         direct_cost,
         indirect_cost,
         billable_flag,
         description,
         record_version_number,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login
      )
      VALUES
      (
         igw_installments_s.nextval,
         p_proposal_award_id,
         p_installment_id,
         p_installment_number,
         p_installment_type_code,
         p_issue_date,
         p_close_date,
         p_start_date,
         p_end_date,
         p_direct_cost,
         p_indirect_cost,
         p_billable_flag,
         p_description,
         1,
         l_last_update_date,
         l_last_updated_by,
         l_last_update_date,
         l_last_updated_by,
         l_last_update_login
      )
      RETURNING
         proposal_installment_id
      INTO
         x_proposal_installment_id;

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
      p_proposal_installment_id IN NUMBER,
      p_proposal_award_id       IN NUMBER,
      p_installment_id          IN NUMBER,
      p_installment_number      IN VARCHAR2,
      p_installment_type_code   IN VARCHAR2,
      p_issue_date              IN DATE,
      p_close_date              IN DATE,
      p_start_date              IN DATE,
      p_end_date                IN DATE,
      p_direct_cost             IN NUMBER,
      p_indirect_cost           IN NUMBER,
      p_billable_flag           IN VARCHAR2,
      p_description             IN VARCHAR2,
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

      UPDATE igw_installments
      SET    proposal_award_id = p_proposal_award_id,
             installment_number = p_installment_number,
             installment_type_code = p_installment_type_code,
             issue_date = p_issue_date,
             close_date = p_close_date,
             start_date = p_start_date,
             end_date = p_end_date,
             direct_cost = p_direct_cost,
             indirect_cost = p_indirect_cost,
             billable_flag = p_billable_flag,
             description = p_description,
             record_version_number = record_version_number + 1,
             last_update_date = l_last_update_date,
             last_updated_by = l_last_updated_by,
             last_update_login = l_last_update_login
      WHERE  (rowid = p_rowid OR proposal_installment_id = p_proposal_installment_id);

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

      DELETE igw_installments
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

END Igw_Installments_Tbh;

/
