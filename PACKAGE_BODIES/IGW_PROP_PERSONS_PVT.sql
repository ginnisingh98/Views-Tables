--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSONS_PVT" AS
--$Header: igwvperb.pls 120.4 2006/02/22 23:25:39 dsadhukh ship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROP_PERSONS_PVT';

   ---------------------------------------------------------------------------

   PROCEDURE Check_Update_Dependent_Data
   (
      p_rowid           IN VARCHAR2,
      p_proposal_id     IN NUMBER,
      p_person_party_id IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   ) IS


   BEGIN

     null;

   END Check_Update_Dependent_Data;

   ---------------------------------------------------------------------------

   PROCEDURE Check_Delete_Dependent_Data

   (
      p_rowid         IN VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   ) IS

   BEGIN

   null;

   END Check_Delete_Dependent_Data;

   ---------------------------------------------------------------------------

   PROCEDURE Check_Lock
   (
      p_rowid                  IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2
   ) IS

   BEGIN

    null;

   END Check_Lock;

   ---------------------------------------------------------------------------

   FUNCTION Get_Party_Id(p_party_type VARCHAR2,p_party_id NUMBER,p_party_name VARCHAR2)
   RETURN NUMBER IS

   BEGIN
         RETURN null;
   END Get_Party_Id;

   -----------------------------------------------------------------------------

   PROCEDURE Create_Prop_Person
   (
      p_init_msg_list          IN VARCHAR2,
      p_validate_only          IN VARCHAR2,
      p_commit                 IN VARCHAR2,
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
   ) IS

   BEGIN
       null;
   END Create_Prop_Person;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Person
   (
      p_init_msg_list          IN VARCHAR2,
      p_validate_only          IN VARCHAR2,
      p_commit                 IN VARCHAR2,
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
   ) IS

   BEGIN

   null;

   END Update_Prop_Person;

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Prop_Person
   (
      p_init_msg_list          IN VARCHAR2,
      p_validate_only          IN VARCHAR2,
      p_commit                 IN VARCHAR2,
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

   BEGIN

    null;

   END Delete_Prop_Person;

   ---------------------------------------------------------------------------

END Igw_Prop_Persons_Pvt;

/
