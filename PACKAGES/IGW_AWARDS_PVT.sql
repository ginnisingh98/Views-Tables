--------------------------------------------------------
--  DDL for Package IGW_AWARDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_AWARDS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvawis.pls 120.5 2005/10/30 05:50:32 appldev ship $

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
   );

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
   );

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
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Award
   (
      p_init_msg_list     IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only     IN VARCHAR2   := Fnd_Api.G_False,
      p_commit            IN VARCHAR2   := Fnd_Api.G_False,
      p_proposal_award_id IN NUMBER,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2
   );

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
   );

   ---------------------------------------------------------------------------

   PROCEDURE Get_Award_Numbering_Method
   (
      x_award_numbering_method OUT NOCOPY VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Temp_Award(p_proposal_award_id IN NUMBER);

   ---------------------------------------------------------------------------

   PROCEDURE Make_Permanent(p_proposal_award_id IN NUMBER);

   ---------------------------------------------------------------------------

END Igw_Awards_Pvt;

 

/
