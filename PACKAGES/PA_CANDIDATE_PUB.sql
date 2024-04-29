--------------------------------------------------------
--  DDL for Package PA_CANDIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CANDIDATE_PUB" AUTHID CURRENT_USER AS
-- $Header: PARCANPS.pls 120.3.12010000.4 2010/03/31 09:59:47 nisinha ship $

G_ASSIGNMENT_ID                  NUMBER := 0;

FUNCTION Get_Number_Of_Candidates(p_project_status_code IN VARCHAR2)
RETURN NUMBER;

FUNCTION Get_Number_Of_Candidates(p_assignment_id IN NUMBER)
RETURN NUMBER;

FUNCTION Resource_Is_Candidate(p_resource_id   IN NUMBER,
                               p_assignment_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Is_Cand_On_Another_Assignment
(p_resource_id           IN NUMBER,
 p_assignment_id         IN NUMBER,
 p_assignment_start_date IN DATE,
 p_assignment_end_date   IN DATE)
RETURN VARCHAR2;

FUNCTION Is_Cand_On_Assignment(p_resource_id   IN NUMBER,
                               p_assignment_id IN NUMBER,
                               p_status_code   IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

PROCEDURE Add_Candidate
(p_assignment_id                IN  NUMBER,
 p_resource_name                IN  VARCHAR2,
 p_resource_id                  IN  NUMBER DEFAULT NULL,
 p_status_code                  IN  VARCHAR2 DEFAULT NULL,
 p_nomination_comments          IN  VARCHAR2,
 p_person_id                    IN  NUMBER DEFAULT NULL,
 p_privilege_name               IN  VARCHAR2 DEFAULT NULL,
 p_project_super_user           IN  VARCHAR2 DEFAULT 'N',
 p_init_msg_list		IN  VARCHAR2 DEFAULT FND_API.G_TRUE,  -- Added for Bug 5130421: PJR Enhancements for Public APIs\
 -- Added for bug 8339510
    -- start for bug#9468526 , Added default null values
 p_attribute_category           IN    pa_candidates.attribute_category%TYPE :=NULL ,
 p_attribute1                   IN    pa_candidates.attribute1%TYPE :=NULL ,
 p_attribute2                   IN    pa_candidates.attribute2%TYPE :=NULL ,
 p_attribute3                   IN    pa_candidates.attribute3%TYPE :=NULL ,
 p_attribute4                   IN    pa_candidates.attribute4%TYPE :=NULL ,
 p_attribute5                   IN    pa_candidates.attribute5%TYPE :=NULL ,
 p_attribute6                   IN    pa_candidates.attribute6%TYPE :=NULL ,
 p_attribute7                   IN    pa_candidates.attribute7%TYPE :=NULL ,
 p_attribute8                   IN    pa_candidates.attribute8%TYPE :=NULL ,
 p_attribute9                   IN    pa_candidates.attribute9%TYPE :=NULL ,
 p_attribute10                  IN    pa_candidates.attribute10%TYPE :=NULL ,
 p_attribute11                  IN    pa_candidates.attribute11%TYPE :=NULL ,
 p_attribute12                  IN    pa_candidates.attribute12%TYPE :=NULL ,
 p_attribute13                  IN    pa_candidates.attribute13%TYPE :=NULL ,
 p_attribute14                  IN    pa_candidates.attribute14%TYPE :=NULL ,
 p_attribute15                  IN    pa_candidates.attribute15%TYPE :=NULL ,
   -- start for bug#9468526 , Added default null values
 x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_No_Of_Active_Candidates(
		p_assignment_id            IN NUMBER,
		p_old_system_status_code   IN VARCHAR2,
		p_new_system_status_code   IN VARCHAR2,
		x_return_status            OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE Update_Remaining_Candidates
(p_assignment_id       IN  NUMBER,
 p_resource_id         IN  NUMBER,
 p_status_code         IN  VARCHAR2,
 p_change_reason_code  IN  VARCHAR2,
 p_init_msg_list       IN  VARCHAR2  := FND_API.G_FALSE,
-- Added for bug 8339510
    -- start for bug#9468526 , Added default null values
 p_attribute_category           IN    pa_candidates.attribute_category%TYPE :=NULL ,
 p_attribute1                   IN    pa_candidates.attribute1%TYPE :=NULL ,
 p_attribute2                   IN    pa_candidates.attribute2%TYPE :=NULL ,
 p_attribute3                   IN    pa_candidates.attribute3%TYPE :=NULL ,
 p_attribute4                   IN    pa_candidates.attribute4%TYPE :=NULL ,
 p_attribute5                   IN    pa_candidates.attribute5%TYPE :=NULL ,
 p_attribute6                   IN    pa_candidates.attribute6%TYPE :=NULL ,
 p_attribute7                   IN    pa_candidates.attribute7%TYPE :=NULL ,
 p_attribute8                   IN    pa_candidates.attribute8%TYPE :=NULL ,
 p_attribute9                   IN    pa_candidates.attribute9%TYPE :=NULL ,
 p_attribute10                  IN    pa_candidates.attribute10%TYPE :=NULL ,
 p_attribute11                  IN    pa_candidates.attribute11%TYPE :=NULL ,
 p_attribute12                  IN    pa_candidates.attribute12%TYPE :=NULL ,
 p_attribute13                  IN    pa_candidates.attribute13%TYPE :=NULL ,
 p_attribute14                  IN    pa_candidates.attribute14%TYPE :=NULL ,
 p_attribute15                  IN    pa_candidates.attribute15%TYPE :=NULL ,
   -- start for bug#9468526 , Added default null values
 x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_data            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count           OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE Add_Candidate_Log
(p_candidate_id               IN  NUMBER,
 p_status_code                IN  VARCHAR2,
 p_change_reason_code         IN  VARCHAR2,
 p_review_comments            IN  VARCHAR2,
 p_cand_record_version_number IN  NUMBER,
 p_init_msg_list              IN  VARCHAR2 DEFAULT FND_API.G_TRUE,  -- Added for Bug 5130421: PJR Enhancements for Public APIs
 x_cand_record_version_number OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
-- Added for bug 8339510
    -- start for bug#9468526 , Added default null values
 p_attribute_category           IN    pa_candidates.attribute_category%TYPE :=NULL ,
 p_attribute1                   IN    pa_candidates.attribute1%TYPE :=NULL ,
 p_attribute2                   IN    pa_candidates.attribute2%TYPE :=NULL ,
 p_attribute3                   IN    pa_candidates.attribute3%TYPE :=NULL ,
 p_attribute4                   IN    pa_candidates.attribute4%TYPE :=NULL ,
 p_attribute5                   IN    pa_candidates.attribute5%TYPE :=NULL ,
 p_attribute6                   IN    pa_candidates.attribute6%TYPE :=NULL ,
 p_attribute7                   IN    pa_candidates.attribute7%TYPE :=NULL ,
 p_attribute8                   IN    pa_candidates.attribute8%TYPE :=NULL ,
 p_attribute9                   IN    pa_candidates.attribute9%TYPE :=NULL ,
 p_attribute10                  IN    pa_candidates.attribute10%TYPE :=NULL ,
 p_attribute11                  IN    pa_candidates.attribute11%TYPE :=NULL ,
 p_attribute12                  IN    pa_candidates.attribute12%TYPE :=NULL ,
 p_attribute13                  IN    pa_candidates.attribute13%TYPE :=NULL ,
 p_attribute14                  IN    pa_candidates.attribute14%TYPE :=NULL ,
 p_attribute15                  IN    pa_candidates.attribute15%TYPE :=NULL ,
   -- start for bug#9468526 , Added default null values
 x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                   OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Candidate
(p_candidate_id            IN  NUMBER,
 p_status_code             IN  VARCHAR2,
 p_ranking                 IN  NUMBER,
 p_change_reason_code      IN  VARCHAR2,
 p_record_version_number   IN  NUMBER,
 p_init_msg_list           IN  VARCHAR2 := FND_API.G_TRUE,
 p_validate_status         IN  VARCHAR2 := FND_API.G_TRUE,
  -- Added for bug 8339510
    -- start for bug#9468526 , Added default null values
 p_attribute_category           IN    pa_candidates.attribute_category%TYPE :=NULL ,
 p_attribute1                   IN    pa_candidates.attribute1%TYPE :=NULL ,
 p_attribute2                   IN    pa_candidates.attribute2%TYPE :=NULL ,
 p_attribute3                   IN    pa_candidates.attribute3%TYPE :=NULL ,
 p_attribute4                   IN    pa_candidates.attribute4%TYPE :=NULL ,
 p_attribute5                   IN    pa_candidates.attribute5%TYPE :=NULL ,
 p_attribute6                   IN    pa_candidates.attribute6%TYPE :=NULL ,
 p_attribute7                   IN    pa_candidates.attribute7%TYPE :=NULL ,
 p_attribute8                   IN    pa_candidates.attribute8%TYPE :=NULL ,
 p_attribute9                   IN    pa_candidates.attribute9%TYPE :=NULL ,
 p_attribute10                  IN    pa_candidates.attribute10%TYPE :=NULL ,
 p_attribute11                  IN    pa_candidates.attribute11%TYPE :=NULL ,
 p_attribute12                  IN    pa_candidates.attribute12%TYPE :=NULL ,
 p_attribute13                  IN    pa_candidates.attribute13%TYPE :=NULL ,
 p_attribute14                  IN    pa_candidates.attribute14%TYPE :=NULL ,
 p_attribute15                  IN    pa_candidates.attribute15%TYPE :=NULL ,
   -- start for bug#9468526 , Added default null values
 x_record_version_number   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_return_status           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION Is_Active_Candidate(p_system_status_code IN VARCHAR2)
RETURN VARCHAR2;


FUNCTION Get_Competence_Match
( p_person_id           IN  NUMBER
, p_assignment_id       IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION Check_Availability(p_resource_id   IN NUMBER,
                            p_assignment_id IN NUMBER,
                            p_project_id    IN NUMBER)
RETURN NUMBER;

PROCEDURE Check_Candidacy
(p_assignment_id       IN  NUMBER,
 p_resource_count      IN  NUMBER,
 p_resource_list       IN  VARCHAR2,
 x_resource_list       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_invalid_candidates  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_return_status       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

Procedure Start_Workflow(p_wf_item_type         IN  VARCHAR2,
                         p_wf_process           IN  VARCHAR2,
                         p_assignment_id        IN  NUMBER,
                         p_candidate_number     IN  NUMBER,
                         p_resource_id          IN  NUMBER,
                         p_status_name          IN  VARCHAR2,
                         x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Candidates
(p_assignment_id       IN  NUMBER,
 p_status_code         IN  VARCHAR2 DEFAULT NULL,
 x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Withdraw_Candidate
(p_candidate_id        IN  NUMBER,
 x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE Copy_Candidates(p_old_requirement_id IN  NUMBER,
                          p_new_requirement_id IN  NUMBER,
                          p_new_start_date     IN  DATE,
                          x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Decline_Candidates(p_assignment_id   IN  NUMBER,
                             p_launch_wf       IN  VARCHAR2 DEFAULT 'Y',
                             x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Added for Bug 6144224
PROCEDURE Get_NF_Recipient (itemtype IN VARCHAR2
                          , itemkey IN VARCHAR2
                          , actid IN NUMBER
                          , funcmode IN VARCHAR2
                          , resultout OUT  NOCOPY VARCHAR2 );

FUNCTION Get_Review_Change_Reason(p_candidate_id IN NUMBER)
RETURN VARCHAR2;

end PA_CANDIDATE_PUB ;

/
