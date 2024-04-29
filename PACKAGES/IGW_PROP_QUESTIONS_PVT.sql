--------------------------------------------------------
--  DDL for Package IGW_PROP_QUESTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_QUESTIONS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvpqes.pls 115.3 2002/11/15 00:44:09 ashkumar ship $

   ---------------------------------------------------------------------------

   PROCEDURE Populate_Prop_Questions( p_proposal_id IN NUMBER );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Question
   (
      p_init_msg_list         IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only         IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                 IN VARCHAR2,
      p_record_version_number IN NUMBER,
      p_proposal_id           IN NUMBER,
      p_proposal_number       IN VARCHAR2,
      p_question_number       IN VARCHAR2,
      p_answer                IN VARCHAR2,
      p_explanation           IN VARCHAR2,
      p_review_date           IN DATE,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Questions_Pvt;

 

/
