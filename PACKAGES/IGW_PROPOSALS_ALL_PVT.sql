--------------------------------------------------------
--  DDL for Package IGW_PROPOSALS_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROPOSALS_ALL_PVT" AUTHID CURRENT_USER AS
--$Header: igwvbass.pls 120.3 2005/10/30 05:50:33 appldev ship $

/*
PROCEDURE CREATE_PROPOSAL
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
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
 , p_user_id                      IN NUMBER
 , p_user_name                    IN VARCHAR2
 , p_signing_official_id          IN NUMBER
 , p_signing_official_name        IN VARCHAR2
 , p_admin_official_id            IN NUMBER
 , p_admin_official_name          IN VARCHAR2
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
 , x_proposal_id                  OUT NOCOPY NUMBER
 , x_rowid                        OUT NOCOPY ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2) ;
*/

--

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
 , x_msg_data                     OUT NOCOPY VARCHAR2);




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
 , x_msg_data                     OUT NOCOPY VARCHAR2);


PROCEDURE DELETE_PROPOSAL
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_rowid                        IN ROWID
 , p_proposal_id                  IN NUMBER
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2);




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
 , x_msg_data                     OUT NOCOPY VARCHAR2);


END IGW_PROPOSALS_ALL_PVT;

 

/
