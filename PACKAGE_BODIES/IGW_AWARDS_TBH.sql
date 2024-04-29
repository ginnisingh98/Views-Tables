--------------------------------------------------------
--  DDL for Package Body IGW_AWARDS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_AWARDS_TBH" AS
/* $Header: igwtawib.pls 115.3 2002/11/15 18:23:02 vmedikon noship $ */

   ---------------------------------------------------------------------------

   G_PKG_NAME VARCHAR2(30) := 'IGW_AWARDS_TBH';

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid                       OUT NOCOPY VARCHAR2,
      x_proposal_award_id           OUT NOCOPY NUMBER,
      p_proposal_id                 IN NUMBER,
      p_award_template_id           IN NUMBER,
      p_award_id                    IN NUMBER,
      p_award_number                IN VARCHAR2,
      p_award_short_name            IN VARCHAR2,
      p_award_full_name             IN VARCHAR2,
      p_funding_source_id           IN NUMBER,
      p_funding_source_award_number IN VARCHAR2,
      p_start_date                  IN DATE,
      p_end_date                    IN DATE,
      p_close_date                  IN DATE,
      p_award_type                  IN VARCHAR2,
      p_award_purpose_code          IN VARCHAR2,
      p_award_organization_id       IN NUMBER,
      p_award_status_code           IN VARCHAR2,
      p_award_manager_id            IN NUMBER,
      p_revenue_distribution_rule   IN VARCHAR2,
      p_billing_distribution_rule   IN VARCHAR2,
      p_billing_term_id             IN NUMBER,
      p_billing_cycle_id            IN NUMBER,
      p_labor_invoice_format_id     IN NUMBER,
      p_non_labor_invoice_format_id IN NUMBER,
      p_allowable_schedule_id       IN NUMBER,
      p_indirect_schedule_id        IN NUMBER,
      p_amount_type_code            IN VARCHAR2,
      p_boundary_code               IN VARCHAR2,
      p_transfer_as                 IN VARCHAR2,
      p_transferred_flag            IN VARCHAR2,
      p_attribute_category          IN VARCHAR2,
      p_attribute1                  IN VARCHAR2,
      p_attribute2                  IN VARCHAR2,
      p_attribute3                  IN VARCHAR2,
      p_attribute4                  IN VARCHAR2,
      p_attribute5                  IN VARCHAR2,
      p_attribute6                  IN VARCHAR2,
      p_attribute7                  IN VARCHAR2,
      p_attribute8                  IN VARCHAR2,
      p_attribute9                  IN VARCHAR2,
      p_attribute10                 IN VARCHAR2,
      p_attribute11                 IN VARCHAR2,
      p_attribute12                 IN VARCHAR2,
      p_attribute13                 IN VARCHAR2,
      p_attribute14                 IN VARCHAR2,
      p_attribute15                 IN VARCHAR2,
      x_return_status               OUT NOCOPY VARCHAR2,
      p_mode                        IN  VARCHAR2
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Insert_Row';

      l_last_update_date  DATE         := SYSDATE;
      l_last_updated_by   NUMBER       := Nvl(Fnd_Global.User_Id,-1);
      l_last_update_login NUMBER       := Nvl(Fnd_Global.Login_Id,-1);

      CURSOR c IS
      SELECT rowid
      FROM   igw_awards
      WHERE  proposal_award_id = x_proposal_award_id;

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_mode = 'I' THEN

         l_last_updated_by := 1;
         l_last_update_login := 0;

      ELSIF p_mode <> 'R' THEN

         Fnd_Message.Set_Name('FND','SYSTEM-INVALID ARGS');
         App_Exception.Raise_Exception;

      END IF;

      INSERT INTO igw_awards
      (
         proposal_award_id,
         proposal_id,
         award_template_id,
         award_id,
         award_number,
         award_short_name,
         award_full_name,
         funding_source_id,
         funding_source_award_number,
         start_date,
         end_date,
         close_date,
         award_type,
         award_purpose_code,
         award_organization_id,
         award_status_code,
         award_manager_id,
         revenue_distribution_rule,
         billing_distribution_rule,
         billing_term_id,
         billing_cycle_id,
         labor_invoice_format_id,
         non_labor_invoice_format_id,
         allowable_schedule_id,
         indirect_schedule_id,
         amount_type_code,
         boundary_code,
         transfer_as,
         transferred_flag,
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
         igw_awards_s.nextval,
         p_proposal_id,
         p_award_template_id,
         p_award_id,
         p_award_number,
         p_award_short_name,
         p_award_full_name,
         p_funding_source_id,
         p_funding_source_award_number,
         p_start_date,
         p_end_date,
         p_close_date,
         p_award_type,
         p_award_purpose_code,
         p_award_organization_id,
         p_award_status_code,
         p_award_manager_id,
         p_revenue_distribution_rule,
         p_billing_distribution_rule,
         p_billing_term_id,
         p_billing_cycle_id,
         p_labor_invoice_format_id,
         p_non_labor_invoice_format_id,
         p_allowable_schedule_id,
         p_indirect_schedule_id,
         p_amount_type_code,
         p_boundary_code,
         p_transfer_as,
         p_transferred_flag,
         p_attribute_category,
         p_attribute1,
         p_attribute2,
         p_attribute3,
         p_attribute4,
         p_attribute5,
         p_attribute6,
         p_attribute7,
         p_attribute8,
         p_attribute9,
         p_attribute10,
         p_attribute11,
         p_attribute12,
         p_attribute13,
         p_attribute14,
         p_attribute15,
         1,
         l_last_update_date,
         l_last_updated_by,
         l_last_update_date,
         l_last_updated_by,
         l_last_update_login
      )
      RETURNING
         proposal_award_id
      INTO
         x_proposal_award_id;

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
      p_rowid                       IN VARCHAR2,
      p_proposal_award_id           IN NUMBER,
      p_proposal_id                 IN NUMBER,
      p_award_template_id           IN NUMBER,
      p_award_id                    IN NUMBER,
      p_award_number                IN VARCHAR2,
      p_award_short_name            IN VARCHAR2,
      p_award_full_name             IN VARCHAR2,
      p_funding_source_id           IN NUMBER,
      p_funding_source_award_number IN VARCHAR2,
      p_start_date                  IN DATE,
      p_end_date                    IN DATE,
      p_close_date                  IN DATE,
      p_award_type                  IN VARCHAR2,
      p_award_purpose_code          IN VARCHAR2,
      p_award_organization_id       IN NUMBER,
      p_award_status_code           IN VARCHAR2,
      p_award_manager_id            IN NUMBER,
      p_revenue_distribution_rule   IN VARCHAR2,
      p_billing_distribution_rule   IN VARCHAR2,
      p_billing_term_id             IN NUMBER,
      p_billing_cycle_id            IN NUMBER,
      p_labor_invoice_format_id     IN NUMBER,
      p_non_labor_invoice_format_id IN NUMBER,
      p_allowable_schedule_id       IN NUMBER,
      p_indirect_schedule_id        IN NUMBER,
      p_amount_type_code            IN VARCHAR2,
      p_boundary_code               IN VARCHAR2,
      p_transfer_as                 IN VARCHAR2,
      p_transferred_flag            IN VARCHAR2,
      p_attribute_category          IN VARCHAR2,
      p_attribute1                  IN VARCHAR2,
      p_attribute2                  IN VARCHAR2,
      p_attribute3                  IN VARCHAR2,
      p_attribute4                  IN VARCHAR2,
      p_attribute5                  IN VARCHAR2,
      p_attribute6                  IN VARCHAR2,
      p_attribute7                  IN VARCHAR2,
      p_attribute8                  IN VARCHAR2,
      p_attribute9                  IN VARCHAR2,
      p_attribute10                 IN VARCHAR2,
      p_attribute11                 IN VARCHAR2,
      p_attribute12                 IN VARCHAR2,
      p_attribute13                 IN VARCHAR2,
      p_attribute14                 IN VARCHAR2,
      p_attribute15                 IN VARCHAR2,
      x_return_status               OUT NOCOPY VARCHAR2,
      p_mode                        IN  VARCHAR2
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

      UPDATE igw_awards
      SET    proposal_id = p_proposal_id,
             award_template_id = p_award_template_id,
             award_number = p_award_number,
             award_short_name = p_award_short_name,
             award_full_name = p_award_full_name,
             funding_source_id = p_funding_source_id,
             funding_source_award_number = p_funding_source_award_number,
             start_date = p_start_date,
             end_date = p_end_date,
             close_date = p_close_date,
             award_type = p_award_type,
             award_purpose_code = p_award_purpose_code,
             award_organization_id = p_award_organization_id,
             award_status_code = p_award_status_code,
             award_manager_id = p_award_manager_id,
             revenue_distribution_rule = p_revenue_distribution_rule,
             billing_distribution_rule = p_billing_distribution_rule,
             billing_term_id = p_billing_term_id,
             billing_cycle_id = p_billing_cycle_id,
             labor_invoice_format_id = p_labor_invoice_format_id,
             non_labor_invoice_format_id = p_non_labor_invoice_format_id,
             allowable_schedule_id = p_allowable_schedule_id,
             indirect_schedule_id = p_indirect_schedule_id,
             amount_type_code = p_amount_type_code,
             boundary_code = p_boundary_code,
             transfer_as = p_transfer_as,
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
      WHERE  (rowid = p_rowid OR proposal_award_id = p_proposal_award_id);

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
      p_proposal_award_id IN NUMBER,
      x_return_status     OUT NOCOPY VARCHAR2
   ) IS

      l_api_name CONSTANT VARCHAR2(30) := 'Delete_Row';

   BEGIN

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      DELETE igw_project_fundings
      WHERE  proposal_installment_id IN
             ( SELECT proposal_installment_id
               FROM   igw_installments
               WHERE  proposal_award_id = p_proposal_award_id );

      DELETE igw_installments
      WHERE  proposal_award_id = p_proposal_award_id;

      DELETE igw_awards
      WHERE  proposal_award_id = p_proposal_award_id;

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

END Igw_Awards_Tbh;

/
