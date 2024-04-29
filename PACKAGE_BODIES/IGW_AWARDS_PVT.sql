--------------------------------------------------------
--  DDL for Package Body IGW_AWARDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_AWARDS_PVT" AS
--$Header: igwvawib.pls 120.12 2005/09/12 21:05:36 vmedikon ship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_AWARDS_PVT';

   ---------------------------------------------------------------------------

   PROCEDURE Check_Lock
   (
      p_rowid                  IN VARCHAR2,
      p_record_version_number  IN NUMBER
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Check_Lock';

      l_locked                 VARCHAR2(1);

   BEGIN
     null;

   END Check_Lock;

   ---------------------------------------------------------------------------

   PROCEDURE Get_Award_Numbering_Method
   (
      x_award_numbering_method OUT NOCOPY VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Award_Numbering_Method';

   BEGIN

     null;

   END Get_Award_Numbering_Method;

   ---------------------------------------------------------------------------

   FUNCTION Get_Gms_Lookup_Code( p_lookup_type VARCHAR2, p_meaning VARCHAR2 )
   RETURN varchar2 IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Gms_Lookup_Code';

      l_lookup_code   VARCHAR2(30);

   BEGIN

     null;

   END Get_Gms_Lookup_Code;

   ---------------------------------------------------------------------------

   FUNCTION Get_Funding_Source_Id(p_funding_source_name VARCHAR2,p_funding_source_id NUMBER)
   RETURN number IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Funding_Source_Id';

      l_funding_source_id      NUMBER;

   BEGIN

     null;

   END Get_Funding_Source_Id;

   ---------------------------------------------------------------------------

   FUNCTION Get_Award_Manager_Id(p_award_manager_name VARCHAR2,p_award_manager_id NUMBER)
   RETURN number IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Award_Manager_Id';

      l_award_manager_id       NUMBER;

   BEGIN

     null;

   END Get_Award_Manager_Id;

   ---------------------------------------------------------------------------

   FUNCTION Get_Allowable_Schedule_Id( p_allowable_schedule_desc VARCHAR2 )
   RETURN number IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Allowable_Schedule_Id';

      l_allowable_schedule_id  NUMBER;

   BEGIN

     null;

   END Get_Allowable_Schedule_Id;

   ---------------------------------------------------------------------------

   FUNCTION Get_Indirect_Schedule_Id( p_indirect_schedule_desc VARCHAR2 )
   RETURN number IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Indirect_Schedule_Id';

      l_indirect_schedule_id   NUMBER;

   BEGIN
     null;

   END Get_Indirect_Schedule_Id;

   ---------------------------------------------------------------------------

   FUNCTION Get_Billing_Term_Id( p_billing_term_desc VARCHAR2 )
   RETURN number IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Billing_Term_Id';

      l_billing_term_id        NUMBER;

   BEGIN
     null;

   END Get_Billing_Term_Id;

   ---------------------------------------------------------------------------

   FUNCTION Get_Billing_Cycle_Id( p_billing_cycle_desc VARCHAR2 )
   RETURN number IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Billing_Cycle_Id';

      l_billing_cycle_id       NUMBER;

   BEGIN

     null;

   END Get_Billing_Cycle_Id;

   ---------------------------------------------------------------------------

   FUNCTION Get_Invoice_Format_Id( p_invoice_format_type VARCHAR2,
   p_invoice_format_desc VARCHAR2 ) RETURN number IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Invoice_Format_Id';

      l_invoice_format_id      NUMBER;

   BEGIN

     null;

   END Get_Invoice_Format_Id;

   ---------------------------------------------------------------------------

   FUNCTION Get_Award_Organization_Id(p_award_organization_name VARCHAR2,p_award_organization_id NUMBER)
   RETURN number IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Get_Award_Organization_Id';

      l_award_organization_id NUMBER;

   BEGIN
     null;

   END Get_Award_Organization_Id;

   ---------------------------------------------------------------------------

   FUNCTION Get_Award_Role(p_proposal_role_code VARCHAR2) RETURN VARCHAR2 IS

      l_award_role VARCHAR2(30);

   BEGIN
     null;

   END Get_Award_Role;

   ---------------------------------------------------------------------------

   PROCEDURE Validate_Award_Number( p_award_number VARCHAR2 ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Validate_Award_Number';

      l_award_numbering_method VARCHAR2(30);
      l_count                  NUMBER;

      l_return_status          VARCHAR2(1);
      l_msg_data               VARCHAR2(255);
      l_msg_count              NUMBER;

   BEGIN

     null;

   END Validate_Award_Number;

   ---------------------------------------------------------------------------

   PROCEDURE Validate_Award_Type( p_award_type VARCHAR2 ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Award_Type';

      l_valid        VARCHAR2(30);

   BEGIN

     null;

   END Validate_Award_Type;

   ---------------------------------------------------------------------------

   PROCEDURE Create_Award_Installment
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      p_select_option           IN VARCHAR2,
      p_proposal_id             IN NUMBER,
      p_award_template_number   IN VARCHAR2,
      p_award_number1           IN VARCHAR2,
      p_award_number2           IN VARCHAR2,
      x_proposal_award_id       OUT NOCOPY NUMBER,
      x_proposal_installment_id OUT NOCOPY NUMBER,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Create_Award_Installment';



   BEGIN

     null;

   END Create_Award_Installment;

   ---------------------------------------------------------------------------

   PROCEDURE Create_Award
   (
      p_init_msg_list               IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only               IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                      IN VARCHAR2   := Fnd_Api.G_False,
      x_rowid                       OUT NOCOPY VARCHAR2,
      x_proposal_award_id           OUT NOCOPY NUMBER,
      p_proposal_id                 IN NUMBER,
      p_award_template_id           IN NUMBER,
      p_award_id                    IN NUMBER,
      p_award_number                IN VARCHAR2,
      p_award_short_name            IN VARCHAR2,
      p_award_full_name             IN VARCHAR2,
      p_funding_source_name         IN VARCHAR2,
      p_funding_source_id           IN NUMBER,
      p_funding_source_award_number IN VARCHAR2,
      p_start_date                  IN DATE,
      p_end_date                    IN DATE,
      p_close_date                  IN DATE,
      p_award_type                  IN VARCHAR2,
      p_award_purpose_desc          IN VARCHAR2,
      p_award_purpose_code          IN VARCHAR2,
      p_award_organization_name     IN VARCHAR2,
      p_award_organization_id       IN NUMBER,
      p_award_status_desc           IN VARCHAR2,
      p_award_status_code           IN VARCHAR2,
      p_award_manager_name          IN VARCHAR2,
      p_award_manager_id            IN NUMBER,
      p_revenue_distribution_rule   IN VARCHAR2,
      p_billing_distribution_rule   IN VARCHAR2,
      p_billing_term_desc           IN VARCHAR2,
      p_billing_term_id             IN NUMBER,
      p_billing_cycle_desc          IN VARCHAR2,
      p_billing_cycle_id            IN NUMBER,
      p_labor_invoice_format_desc   IN VARCHAR2,
      p_labor_invoice_format_id     IN NUMBER,
      p_non_labor_inv_format_desc   IN VARCHAR2,
      p_non_labor_invoice_format_id IN NUMBER,
      p_allowable_schedule_desc     IN VARCHAR2,
      p_allowable_schedule_id       IN NUMBER,
      p_indirect_schedule_desc      IN VARCHAR2,
      p_indirect_schedule_id        IN NUMBER,
      p_amount_type_desc            IN VARCHAR2,
      p_amount_type_code            IN VARCHAR2,
      p_boundary_desc               IN VARCHAR2,
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
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Create_Award';

      l_award_manager_id       NUMBER;
      l_start_date             DATE;
      l_end_date               DATE;
      l_close_date             DATE;
      l_award_id               NUMBER;
      l_award_template_id      NUMBER;
      p_award_template_number  VARCHAR2(15);

      l_count                  NUMBER;

   BEGIN

     null;

   END Create_Award;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Award
   (
      p_init_msg_list               IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only               IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                      IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                       IN VARCHAR2,
      p_proposal_award_id           IN NUMBER,
      p_record_version_number       IN NUMBER,
      p_proposal_id                 IN NUMBER,
      p_award_template_id           IN NUMBER,
      p_award_id                    IN NUMBER,
      p_award_number                IN VARCHAR2,
      p_award_short_name            IN VARCHAR2,
      p_award_full_name             IN VARCHAR2,
      p_funding_source_name         IN VARCHAR2,
      p_funding_source_id           IN NUMBER,
      p_funding_source_award_number IN VARCHAR2,
      p_start_date                  IN DATE,
      p_end_date                    IN DATE,
      p_close_date                  IN DATE,
      p_award_type                  IN VARCHAR2,
      p_award_purpose_desc          IN VARCHAR2,
      p_award_purpose_code          IN VARCHAR2,
      p_award_organization_name     IN VARCHAR2,
      p_award_organization_id       IN NUMBER,
      p_award_status_desc           IN VARCHAR2,
      p_award_status_code           IN VARCHAR2,
      p_award_manager_name          IN VARCHAR2,
      p_award_manager_id            IN NUMBER,
      p_revenue_distribution_rule   IN VARCHAR2,
      p_billing_distribution_rule   IN VARCHAR2,
      p_billing_term_desc           IN VARCHAR2,
      p_billing_term_id             IN NUMBER,
      p_billing_cycle_desc          IN VARCHAR2,
      p_billing_cycle_id            IN NUMBER,
      p_labor_invoice_format_desc   IN VARCHAR2,
      p_labor_invoice_format_id     IN NUMBER,
      p_non_labor_inv_format_desc   IN VARCHAR2,
      p_non_labor_invoice_format_id IN NUMBER,
      p_allowable_schedule_desc     IN VARCHAR2,
      p_allowable_schedule_id       IN NUMBER,
      p_indirect_schedule_desc      IN VARCHAR2,
      p_indirect_schedule_id        IN NUMBER,
      p_amount_type_desc            IN VARCHAR2,
      p_amount_type_code            IN VARCHAR2,
      p_boundary_desc               IN VARCHAR2,
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
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT      VARCHAR2(30) := 'Update_Award';

      l_funding_source_id           NUMBER(15);
      l_award_purpose_code          VARCHAR2(30);
      l_award_organization_id       NUMBER(15);
      l_award_status_code           VARCHAR2(30);
      l_award_manager_id            NUMBER(15);
      l_billing_term_id             NUMBER(15);
      l_billing_cycle_id            NUMBER(15);
      l_labor_invoice_format_id     NUMBER(15);
      l_non_labor_invoice_format_id NUMBER(15);
      l_allowable_schedule_id       NUMBER(15);
      l_indirect_schedule_id        NUMBER(15);
      l_amount_type_code            VARCHAR2(30);
      l_boundary_code               VARCHAR2(30);

      l_count                  NUMBER;

   BEGIN

     null;

   END Update_Award;

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Award
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      p_proposal_award_id      IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Award';

   BEGIN
     null;
   END Delete_Award;

   ---------------------------------------------------------------------------

   PROCEDURE Transfer_Award_Installment
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      p_proposal_award_id       IN NUMBER,
      p_proposal_installment_id IN NUMBER,
      x_award_id                OUT NOCOPY NUMBER,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

   BEGIN
     null;
   END Transfer_Award_Installment;

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Temp_Award(p_proposal_award_id IN NUMBER) IS

      l_temporary_flag   VARCHAR2(1);
      l_return_status    VARCHAR2(1);

   BEGIN

     null;

   END Delete_Temp_Award;

   ---------------------------------------------------------------------------

   PROCEDURE Make_Permanent(p_proposal_award_id IN NUMBER) IS
   BEGIN

     null;

   END Make_Permanent;

   ---------------------------------------------------------------------------

END Igw_Awards_Pvt;

/
