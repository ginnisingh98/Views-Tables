--------------------------------------------------------
--  DDL for Package IGW_CREATE_PROPOSAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_CREATE_PROPOSAL_PVT" AUTHID CURRENT_USER AS
--$Header: igwvcprs.pls 120.5 2005/09/12 21:04:57 vmedikon ship $

   ---------------------------------------------------------------------------

   PROCEDURE Get_Proposal_Numbering_Method
   (x_proposal_numbering_method OUT NOCOPY VARCHAR2);

   ---------------------------------------------------------------------------

   FUNCTION Is_Positive_Integer(p_value VARCHAR2) RETURN BOOLEAN;

   ---------------------------------------------------------------------------

   FUNCTION Get_Party_Id(p_party_type VARCHAR2,p_party_id NUMBER,p_party_name VARCHAR2)
   RETURN NUMBER;

   ---------------------------------------------------------------------------

   PROCEDURE Create_Proposal
  (
      p_init_msg_list              IN VARCHAR2,
      p_commit                     IN VARCHAR2,
      p_validate_only              IN VARCHAR2,
      p_proposal_number            IN  igw_proposals_all.proposal_number%TYPE,
      p_proposal_short_title       IN  VARCHAR2,
      p_proposal_title             IN  igw_proposals_all.proposal_title%TYPE,
      p_proposal_status            IN  igw_proposals_all.proposal_status%TYPE,
      p_proposal_status_meaning    IN  fnd_lookups.meaning%TYPE,
      p_proposal_start_date        IN  igw_proposals_all.proposal_start_date%TYPE,
      p_proposal_end_date          IN  igw_proposals_all.proposal_end_date%TYPE,
      p_proposal_type_code         IN  igw_proposals_all.proposal_type_code%type,
      p_proposal_type_meaning      IN  fnd_lookups.meaning%TYPE,
      p_activity_type_code         IN  igw_proposals_all.activity_type_code%type,
      p_activity_type_meaning      IN  fnd_lookups.meaning%TYPE,
      p_proposal_category_code     IN  VARCHAR2,
      p_proposal_category_meaning  IN  fnd_lookups.meaning%TYPE,
      p_proposal_purpose_code      IN  VARCHAR2,
      p_proposal_purpose_meaning   IN  fnd_lookups.meaning%TYPE,
      p_cross_cut_type_code        IN  VARCHAR2,
      p_cross_cut_type_meaning     IN  fnd_lookups.meaning%TYPE,
      p_proposal_url               IN  VARCHAR2,
      p_grantor_id                 IN  NUMBER,
      p_grantor_name               IN  VARCHAR2,
      p_proposal_manager_id        IN  NUMBER,
      p_proposal_manager_name      IN  hz_parties.party_name%TYPE,
      p_signing_official_party_id  IN  NUMBER,
      p_signing_official_name      IN  hz_parties.party_name%TYPE,
      p_admin_official_party_id    IN  NUMBER,
      p_admin_official_name        IN  hz_parties.party_name%TYPE,
      p_submitting_organization_id IN  igw_proposals_all.submitting_organization_id%TYPE,
      p_submitting_party_id        IN  NUMBER,
      p_lead_organization_id       IN  NUMBER,
      p_applicant_unit_name        IN  VARCHAR2,
      p_org_id                     IN  igw_proposals_all.org_id%TYPE,
      p_original_proposal_id       IN  NUMBER,
      p_original_proposal_number   IN  igw_proposals_all.proposal_number%TYPE,
      p_parent_proposal_id         IN  NUMBER,
      p_parent_proposal_number     IN  igw_proposals_all.proposal_number%TYPE,
      p_sponsor_application_number IN  VARCHAR2,
      p_external_applicant_unit_id IN  NUMBER,
      p_attribute_category         IN  igw_proposals_all.attribute_category%TYPE,
      p_attribute1                 IN  igw_proposals_all.attribute1%TYPE,
      p_attribute2                 IN  igw_proposals_all.attribute2%TYPE,
      p_attribute3                 IN  igw_proposals_all.attribute3%TYPE,
      p_attribute4                 IN  igw_proposals_all.attribute4%TYPE,
      p_attribute5                 IN  igw_proposals_all.attribute5%TYPE,
      p_attribute6                 IN  igw_proposals_all.attribute6%TYPE,
      p_attribute7                 IN  igw_proposals_all.attribute7%TYPE,
      p_attribute8                 IN  igw_proposals_all.attribute8%TYPE,
      p_attribute9                 IN  igw_proposals_all.attribute9%TYPE,
      p_attribute10                IN  igw_proposals_all.attribute10%TYPE,
      p_attribute11                IN  igw_proposals_all.attribute11%TYPE,
      p_attribute12                IN  igw_proposals_all.attribute12%TYPE,
      p_attribute13                IN  igw_proposals_all.attribute13%TYPE,
      p_attribute14                IN  igw_proposals_all.attribute14%TYPE,
      p_attribute15                IN  igw_proposals_all.attribute15%TYPE,
      p_igw_mode                   IN  VARCHAR2,
      x_proposal_id                OUT NOCOPY igw_proposals_all.proposal_id%TYPE,
      x_proposal_number            OUT NOCOPY igw_proposals_all.proposal_number%TYPE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Create_Proposal_Pvt;

 

/
