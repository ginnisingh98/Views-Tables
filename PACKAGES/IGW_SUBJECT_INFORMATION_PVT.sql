--------------------------------------------------------
--  DDL for Package IGW_SUBJECT_INFORMATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_SUBJECT_INFORMATION_PVT" AUTHID CURRENT_USER AS
--$Header: igwvsuis.pls 115.3 2002/11/15 00:50:45 ashkumar ship $


PROCEDURE CREATE_SUBJECT_INFORMATION
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_study_title_id               IN NUMBER
 , p_subject_type_code            IN VARCHAR2
 , p_subject_race_code            IN VARCHAR2
 , p_subject_ethnicity_code       IN VARCHAR2
 , p_no_of_subjects               IN NUMBER
 , x_rowid                        OUT NOCOPY ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_SUBJECT_INFORMATION
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_study_title_id               IN NUMBER
 , p_subject_type_code            IN VARCHAR2
 , p_subject_race_code            IN VARCHAR2
 , p_subject_ethnicity_code       IN VARCHAR2
 , p_no_of_subjects               IN NUMBER
 , p_rowid                        IN ROWID
 , p_record_version_number        IN NUMBER
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------------------
PROCEDURE DELETE_SUBJECT_INFORMATION (
  p_init_msg_list                IN             VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN             VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN             VARCHAR2   := FND_API.G_FALSE
 ,x_rowid                        IN             VARCHAR2
 ,p_study_title_id               IN             NUMBER
 ,p_record_version_number        IN             NUMBER
 ,x_return_status                OUT NOCOPY            VARCHAR2
 ,x_msg_count                    OUT NOCOPY            NUMBER
 ,x_msg_data                     OUT NOCOPY            VARCHAR2);

-------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
                (x_rowid                        IN      VARCHAR2
                ,p_record_version_number        IN      NUMBER
                ,x_return_status                OUT NOCOPY     VARCHAR2);

END IGW_SUBJECT_INFORMATION_PVT;

 

/
