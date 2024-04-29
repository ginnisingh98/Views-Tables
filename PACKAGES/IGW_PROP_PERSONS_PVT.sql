--------------------------------------------------------
--  DDL for Package IGW_PROP_PERSONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PERSONS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvpers.pls 120.3 2005/10/30 05:53:41 appldev ship $

   ---------------------------------------------------------------------------

   PROCEDURE Create_Prop_Person
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      x_rowid                  OUT NOCOPY VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_proposal_number        IN VARCHAR2,
      p_person_id              IN NUMBER,
      p_person_party_id        IN NUMBER,
      p_full_name              IN VARCHAR2,
      p_user_id                IN NUMBER,
      p_proposal_role_code     IN VARCHAR2,
      p_proposal_role_desc     IN VARCHAR2,
      p_key_person_flag        IN VARCHAR2,
      p_person_organization_id IN NUMBER,
      p_org_party_id           IN NUMBER,
      p_person_unit_name       IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Person
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_proposal_number        IN VARCHAR2,
      p_person_id              IN NUMBER,
      p_person_party_id        IN NUMBER,
      p_full_name              IN VARCHAR2,
      p_user_id                IN NUMBER,
      p_proposal_role_code     IN VARCHAR2,
      p_proposal_role_desc     IN VARCHAR2,
      p_pi_flag                IN VARCHAR2,
      p_key_person_flag        IN VARCHAR2,
      p_percent_effort         IN NUMBER,
      p_person_organization_id IN NUMBER,
      p_org_party_id           IN NUMBER,
      p_person_unit_name       IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Prop_Person
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

END Igw_Prop_Persons_Pvt;

 

/
