--------------------------------------------------------
--  DDL for Package IGW_PROJECT_FUNDINGS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROJECT_FUNDINGS_TBH" AUTHID CURRENT_USER AS
/* $Header: igwtapfs.pls 115.3 2002/11/14 18:49:10 vmedikon noship $ */

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
      p_mode                    IN  VARCHAR2 default 'R'
   );

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
      p_mode                    IN  VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Row
   (
      p_rowid                  IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Project_Fundings_Tbh;

 

/
