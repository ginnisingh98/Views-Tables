--------------------------------------------------------
--  DDL for Package Body IGW_PROPOSALS_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROPOSALS_ALL_PVT" AS
--$Header: igwvbasb.pls 120.4 2005/09/12 21:04:43 vmedikon ship $


PROCEDURE CHECK_AO_SO_USER_VALIDITY
(p_signing_official_id	   IN  number
,p_admin_official_id	   IN  number
,x_return_status           OUT NOCOPY VARCHAR2
,x_error_msg_code          OUT NOCOPY VARCHAR2) is



  o_user_id  number(15);
BEGIN
  null;
END; --CHECK_AO_SO_USER_VALIDITY

---------------------------------------------------------------------------------------


PROCEDURE UPDATE_PROPOSAL_BASIC_INFO
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_proposal_title               IN VARCHAR2
 , p_proposal_start_date          IN DATE
 , p_proposal_end_date            IN DATE
 , p_proposal_status_code         IN VARCHAR2
 , p_proposal_status              IN VARCHAR2
 , p_proposal_type_code           IN VARCHAR2
 , p_proposal_type                IN VARCHAR2
 , p_activity_type_code           IN VARCHAR2
 , p_activity_type                IN VARCHAR2
 , p_lead_organization_id         IN NUMBER
 , p_lead_organization_name       IN VARCHAR2
 , p_submitting_organization_id   IN NUMBER
 , p_submitting_organization_name IN VARCHAR2
 , p_sponsor_id                   IN NUMBER
 , p_sponsor_name                 IN VARCHAR2
 , p_proposal_manager_id          IN NUMBER
 , p_proposal_manager_name        IN VARCHAR2
 , p_funding_sponsor_unit         IN VARCHAR2
 , p_original_sponsor_id          IN NUMBER
 , p_original_sponsor_name        IN VARCHAR2
 , p_original_proposal_number     IN VARCHAR2
 , p_original_award_number        IN VARCHAR2
 , p_original_proposal_start_date IN DATE
 , p_original_proposal_end_date   IN DATE
 , p_user_id                      IN NUMBER
 , p_user_name                    IN VARCHAR2
 , p_signing_official_id          IN NUMBER
 , p_signing_official_name        IN VARCHAR2
 , p_admin_official_id            IN NUMBER
 , p_admin_official_name          IN VARCHAR2
 , p_record_version_number        IN NUMBER
 , p_rowid                        IN ROWID
 , p_attribute_category	          IN VARCHAR2 := null
 , p_attribute1                   IN VARCHAR2 := null
 , p_attribute2                   IN VARCHAR2 := null
 , p_attribute3                   IN VARCHAR2 := null
 , p_attribute4                   IN VARCHAR2 := null
 , p_attribute5                   IN VARCHAR2 := null
 , p_attribute6                   IN VARCHAR2 := null
 , p_attribute7                   IN VARCHAR2 := null
 , p_attribute8                   IN VARCHAR2 := null
 , p_attribute9                   IN VARCHAR2 := null
 , p_attribute10                  IN VARCHAR2 := null
 , p_attribute11                  IN VARCHAR2 := null
 , p_attribute12                  IN VARCHAR2 := null
 , p_attribute13                  IN VARCHAR2 := null
 , p_attribute14                  IN VARCHAR2 := null
 , p_attribute15                  IN VARCHAR2 := null
 , x_sponsor_id                   OUT NOCOPY NUMBER
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2) IS


  l_proposal_id              igw_proposals_all.proposal_id%TYPE := p_proposal_id;
  l_original_proposal_id     NUMBER;
  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_err_msg_code             VARCHAR2(250);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;
  l_proposal_status_code     VARCHAR2(30)        := p_proposal_status_code ;
  l_proposal_type_code       VARCHAR2(30)        := p_proposal_type_code;
  l_activity_type_code       VARCHAR2(30)        := p_activity_type_code;
  l_lead_organization_id     NUMBER              := p_lead_organization_id;
  l_submitting_organization_id  NUMBER           := p_submitting_organization_id;
  l_sponsor_id               NUMBER              := p_sponsor_id;
  l_original_sponsor_id      NUMBER              := p_original_sponsor_id;
  l_proposal_manager_id      NUMBER              := p_proposal_manager_id;
  l_signing_official_id      NUMBER              := p_signing_official_id;
  l_admin_official_id        NUMBER              := p_admin_official_id;
  l_dummy                    VARCHAR2(1);
  l_proposal_numbering_method  VARCHAR2(10);
  l_party_id                 NUMBER(15);
  l_address_id               NUMBER(15);
  l_count                    NUMBER(10);
  l_address_count            NUMBER(10);
  l_rowid                    ROWID;

BEGIN
  null;

END UPDATE_PROPOSAL_BASIC_INFO;


-------------------------------------------------------------------------------------------
PROCEDURE UPDATE_PROPOSAL_PROGRAM
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_notice_opportunity_code      IN VARCHAR2
 , p_notice_opportunity           IN VARCHAR2
 , p_program_number               IN VARCHAR2
 , p_program_title                IN VARCHAR2
 , p_program_url                  IN VARCHAR2
 , p_deadline_date                IN DATE
 , p_deadline_type                IN VARCHAR2
 , p_letter_of_intent_due_date    IN DATE
 , p_record_version_number        IN NUMBER
 , p_rowid                        IN ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2) IS

  l_proposal_id              igw_proposals_all.proposal_id%TYPE   := p_proposal_id;
  l_notice_opportunity_code  VARCHAR2(30)                         := p_notice_opportunity_code;
  l_deadline_type            VARCHAR2(1)                          := 'P';
  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;
  l_dummy                    VARCHAR2(1);

BEGIN
    null;

END; --UPDATE PPROPOSAL PROGRAM



PROCEDURE DELETE_PROPOSAL
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_rowid                        IN ROWID
 , p_proposal_id                  IN NUMBER
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2) IS

  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;
  l_dummy                    VARCHAR2(1);

BEGIN

  null;

END Delete_Proposal;


PROCEDURE UPDATE_SPONSOR_ACTION
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_sponsor_action_date          IN DATE
 , p_sponsor_action_code          IN VARCHAR2
 , p_award_number                 IN VARCHAR2
 , p_award_amount                 IN NUMBER
 , p_record_version_number        IN NUMBER
 , p_rowid                        IN ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2) IS

  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_err_msg_code             VARCHAR2(250);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;
  l_dummy                    VARCHAR2(1);

BEGIN

  null;
END UPDATE_SPONSOR_ACTION;

END IGW_PROPOSALS_ALL_PVT;

/
