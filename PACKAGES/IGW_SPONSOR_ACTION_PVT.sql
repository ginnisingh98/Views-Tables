--------------------------------------------------------
--  DDL for Package IGW_SPONSOR_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_SPONSOR_ACTION_PVT" AUTHID CURRENT_USER AS
--$Header: igwvspas.pls 115.2 2002/11/15 00:49:08 ashkumar noship $

   ---------------------------------------------------------------------------

   PROCEDURE Create_Sponsor_Action
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      x_rowid                  OUT NOCOPY VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_proposal_number        IN VARCHAR2,
      p_comments               IN VARCHAR2,
      p_sponsor_action_code    IN VARCHAR2,
      p_sponsor_action_date    IN DATE,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Sponsor_Action
   (
      p_init_msg_list         IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only         IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                 IN VARCHAR2,
      p_proposal_id           IN NUMBER,
      p_proposal_number       IN VARCHAR2,
      p_comment_id            IN NUMBER,
      p_comments              IN VARCHAR2,
      p_sponsor_action_code    IN VARCHAR2,
      p_sponsor_action_date    IN DATE,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Sponsor_Action
   (
      p_init_msg_list         IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only         IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                 IN VARCHAR2,
      p_proposal_id           IN NUMBER,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END IGW_SPONSOR_ACTION_PVT;

 

/
