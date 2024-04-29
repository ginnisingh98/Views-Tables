--------------------------------------------------------
--  DDL for Package IGW_INSTALLMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_INSTALLMENTS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvinss.pls 115.1 2002/11/14 18:46:05 vmedikon noship $

   ---------------------------------------------------------------------------

   PROCEDURE Create_Installment
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      x_rowid                   OUT NOCOPY VARCHAR2,
      x_proposal_installment_id OUT NOCOPY NUMBER,
      p_proposal_award_id       IN NUMBER,
      p_installment_id          IN NUMBER,
      p_installment_number      IN VARCHAR2,
      p_installment_type_desc   IN VARCHAR2,
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
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Installment
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                   IN VARCHAR2,
      p_proposal_installment_id IN NUMBER,
      p_record_version_number   IN NUMBER,
      p_proposal_award_id       IN NUMBER,
      p_installment_id          IN NUMBER,
      p_installment_number      IN VARCHAR2,
      p_installment_type_desc   IN VARCHAR2,
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
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Installment
   (
      p_init_msg_list         IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only         IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                 IN VARCHAR2,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Installments_Pvt;

 

/
