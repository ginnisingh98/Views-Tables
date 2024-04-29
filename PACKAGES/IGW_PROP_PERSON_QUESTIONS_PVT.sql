--------------------------------------------------------
--  DDL for Package IGW_PROP_PERSON_QUESTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PERSON_QUESTIONS_PVT" AUTHID CURRENT_USER as
/* $Header: igwvppqs.pls 115.6 2002/11/15 00:42:07 ashkumar ship $*/

PROCEDURE create_prop_person_question (
  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         OUT NOCOPY  	VARCHAR2
 ,p_proposal_id			 IN 	NUMBER
 ,p_proposal_number		 IN	VARCHAR2
 ,p_person_id               	 IN 	NUMBER
 ,p_party_id               	 IN 	NUMBER
 ,p_person_name			 IN	VARCHAR2
 ,p_question_number     	 IN	VARCHAR2
 ,p_answer       	 	 IN	VARCHAR2
 ,p_explanation		 	 IN     VARCHAR2
 ,p_review_date   		 IN	DATE
 ,x_return_status                OUT NOCOPY 	VARCHAR2
 ,x_msg_count                    OUT NOCOPY 	NUMBER
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2);
--------------------------------------------------------------------------------------------------------------

Procedure update_prop_person_question (
  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         IN 	VARCHAR2
 ,p_proposal_id			 IN 	NUMBER
 ,p_proposal_number		 IN	VARCHAR2
 ,p_person_id               	 IN 	NUMBER
 ,p_party_id               	 IN 	NUMBER
 ,p_person_name			 IN	VARCHAR2
 ,p_question_number     	 IN	VARCHAR2
 ,p_answer       	 	 IN	VARCHAR2
 ,p_explanation		 	 IN     VARCHAR2
 ,p_review_date   		 IN	DATE
 ,p_record_version_number        IN 	NUMBER
 ,x_return_status                OUT NOCOPY 	VARCHAR2
 ,x_msg_count                    OUT NOCOPY 	NUMBER
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2);
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_person_question (
  p_init_msg_list                IN   	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 	VARCHAR2
 ,p_record_version_number        IN   	NUMBER
 ,x_return_status                OUT NOCOPY  	VARCHAR2
 ,x_msg_count                    OUT NOCOPY  	NUMBER
 ,x_msg_data                     OUT NOCOPY  	VARCHAR2);
 ------------------------------------------------------------------------------------------------

PROCEDURE EXPLANATION_OR_DATE_REQUIRED (
         		       p_question_number		IN	VARCHAR2,
         		       p_answer				IN	VARCHAR2,
         		       p_explanation			IN	VARCHAR2,
         		       p_review_date			IN	VARCHAR2,
         		       x_return_status			OUT NOCOPY	VARCHAR2);
---------------------------------------------------------------------------------------------

PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2);
------------------------------------------------------------------------------------------------

PROCEDURE CHECK_ERRORS;
---------------------------------------------------------------------------------------------

PROCEDURE POPULATE_PROP_PERSON_QUESTIONS (p_init_msg_list     in    varchar2 := FND_API.G_FALSE,
					  p_commit            in    varchar2 := FND_API.G_FALSE,
					  p_validate_only     in    varchar2 := FND_API.G_FALSE,
					  p_proposal_id       in    number,
					  p_person_id         in    number,
					  p_party_id          in    number,
					  x_rowid             out NOCOPY   varchar2,
					  x_return_status     out NOCOPY   varchar2,
					  x_msg_count         out NOCOPY   number,
 					  x_msg_data          out NOCOPY   varchar2);

END IGW_PROP_PERSON_QUESTIONS_PVT;

 

/
