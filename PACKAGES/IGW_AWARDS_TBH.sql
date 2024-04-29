--------------------------------------------------------
--  DDL for Package IGW_AWARDS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_AWARDS_TBH" AUTHID CURRENT_USER AS
/* $Header: igwtawis.pls 115.2 2002/11/15 18:22:50 vmedikon noship $ */

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
      p_mode                        IN  VARCHAR2 default 'R'
   );

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
      p_mode                        IN  VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Row
   (
      p_proposal_award_id IN NUMBER,
      x_return_status     OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Awards_Tbh;

 

/
