--------------------------------------------------------
--  DDL for Package IGW_INSTALLMENTS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_INSTALLMENTS_TBH" AUTHID CURRENT_USER AS
/* $Header: igwtinss.pls 115.1 2002/11/14 18:46:34 vmedikon noship $ */

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
      p_mode                    IN  VARCHAR2 default 'R'
   );

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
      p_mode                    IN  VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Row
   (
      p_rowid                  IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Installments_Tbh;

 

/
