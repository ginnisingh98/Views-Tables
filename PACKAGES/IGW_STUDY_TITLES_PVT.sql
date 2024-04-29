--------------------------------------------------------
--  DDL for Package IGW_STUDY_TITLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_STUDY_TITLES_PVT" AUTHID CURRENT_USER AS
--$Header: igwvstts.pls 115.5 2002/11/15 00:49:51 ashkumar ship $


PROCEDURE CREATE_STUDY_TITLE
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , x_study_title_id               OUT NOCOPY NUMBER
 , p_study_title                  IN VARCHAR2
 , p_enrollment_status		  IN VARCHAR2
 , p_protocol_number              IN VARCHAR2
 , x_rowid                        OUT NOCOPY ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_STUDY_TITLE
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_study_title_id               IN NUMBER
 , p_study_title                  IN VARCHAR2
 , p_enrollment_status		  IN VARCHAR2
 , p_protocol_number              IN VARCHAR2
 , p_rowid                        IN ROWID
 , p_record_version_number        IN NUMBER
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_STUDY_TITLE (
  p_init_msg_list                IN             VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN             VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN             VARCHAR2   := FND_API.G_FALSE
 ,p_study_title_id               IN             NUMBER
 ,p_record_version_number        IN             NUMBER
 ,x_rowid                        IN             VARCHAR2
 ,x_return_status                OUT NOCOPY            VARCHAR2
 ,x_msg_count                    OUT NOCOPY            NUMBER
 ,x_msg_data                     OUT NOCOPY            VARCHAR2);

PROCEDURE CHECK_LOCK
                (x_rowid                        IN      VARCHAR2
                ,p_record_version_number        IN      NUMBER
                ,x_return_status                OUT NOCOPY     VARCHAR2);

END IGW_STUDY_TITLES_PVT;

 

/
