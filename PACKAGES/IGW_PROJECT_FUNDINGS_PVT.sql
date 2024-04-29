--------------------------------------------------------
--  DDL for Package IGW_PROJECT_FUNDINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROJECT_FUNDINGS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvapfs.pls 115.2 2002/11/14 18:48:52 vmedikon noship $

   ---------------------------------------------------------------------------

   PROCEDURE Create_Project_Funding
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      x_rowid                   OUT NOCOPY VARCHAR2,
      x_proposal_funding_id     OUT NOCOPY NUMBER,
      p_proposal_installment_id IN NUMBER,
      p_project_number          IN VARCHAR2,
      p_project_id              IN NUMBER,
      p_task_number             IN VARCHAR2,
      p_task_id                 IN NUMBER,
      p_funding_amount          IN NUMBER,
      p_date_allocated          IN DATE,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Project_Funding
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                   IN VARCHAR2,
      p_proposal_funding_id     IN NUMBER,
      p_record_version_number   IN NUMBER,
      p_proposal_installment_id IN NUMBER,
      p_project_number          IN VARCHAR2,
      p_project_id              IN NUMBER,
      p_task_number             IN VARCHAR2,
      p_task_id                 IN NUMBER,
      p_funding_amount          IN NUMBER,
      p_date_allocated          IN DATE,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Project_Funding
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

END Igw_Project_Fundings_Pvt;

 

/
