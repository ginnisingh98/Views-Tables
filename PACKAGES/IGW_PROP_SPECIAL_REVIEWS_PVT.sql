--------------------------------------------------------
--  DDL for Package IGW_PROP_SPECIAL_REVIEWS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_SPECIAL_REVIEWS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvrevs.pls 115.2 2002/11/15 00:45:50 ashkumar ship $



   ---------------------------------------------------------------------------

   PROCEDURE Create_Prop_Special_Reviews
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      x_rowid                  OUT NOCOPY VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_proposal_number        IN VARCHAR2,
      p_special_review_code    IN VARCHAR2,
      p_special_review_desc    IN VARCHAR2,
      p_special_review_type    IN VARCHAR2,
      p_special_review_type_desc IN VARCHAR2,
      p_approval_type_code       IN VARCHAR2,
      p_approval_type_desc       IN VARCHAR2,
      p_protocol_number          IN VARCHAR2,
      p_application_date         IN DATE,
      p_approval_date            IN DATE,
      p_comments                 IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Special_Reviews
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_proposal_number        IN VARCHAR2,
      p_special_review_code      IN VARCHAR2,
      p_special_review_desc      IN VARCHAR2,
      p_special_review_type      IN VARCHAR2,
      p_special_review_type_desc IN VARCHAR2,
      p_approval_type_code       IN VARCHAR2,
      p_approval_type_desc       IN VARCHAR2,
      p_protocol_number          IN VARCHAR2,
      p_application_date         IN DATE,
      p_approval_date            IN DATE,
      p_comments                 IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Prop_Special_Reviews
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Special_Reviews_Pvt;

 

/
