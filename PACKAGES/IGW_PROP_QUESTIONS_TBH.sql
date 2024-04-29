--------------------------------------------------------
--  DDL for Package IGW_PROP_QUESTIONS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_QUESTIONS_TBH" AUTHID CURRENT_USER AS
/* $Header: igwtpqes.pls 115.4 2002/11/15 00:44:24 ashkumar ship $ */

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid              OUT NOCOPY VARCHAR2,
      p_proposal_id        IN NUMBER,
      p_question_number    IN VARCHAR2,
      p_answer             IN VARCHAR2,
      p_explanation        IN VARCHAR2,
      p_review_date        IN DATE,
      x_return_status      OUT NOCOPY VARCHAR2,
      p_mode               IN VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Row
   (
      p_rowid                 IN VARCHAR2,
      p_record_version_number IN NUMBER,
      p_proposal_id           IN NUMBER,
      p_question_number       IN VARCHAR2,
      p_answer                IN VARCHAR2,
      p_explanation           IN VARCHAR2,
      p_review_date           IN DATE,
      x_return_status         OUT NOCOPY VARCHAR2,
      p_mode                  IN VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Questions_Tbh;

 

/
