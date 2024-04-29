--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSON_QUESTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSON_QUESTIONS_PVT" as
 /* $Header: igwvppqb.pls 120.3 2006/02/22 23:25:14 dsadhukh ship $*/

PROCEDURE create_prop_person_question (
  p_init_msg_list                IN 		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         OUT NOCOPY  		VARCHAR2
 ,p_proposal_id			 IN 		NUMBER
 ,p_proposal_number		 IN		VARCHAR2
 ,p_person_id               	 IN 		NUMBER
 ,p_party_id               	 IN 		NUMBER
 ,p_person_name			 IN		VARCHAR2
 ,p_question_number     	 IN		VARCHAR2
 ,p_answer       	 	 IN		VARCHAR2
 ,p_explanation		 	 IN     	VARCHAR2
 ,p_review_date   		 IN		DATE
 ,x_return_status                OUT NOCOPY 		VARCHAR2
 ,x_msg_count                    OUT NOCOPY 		NUMBER
 ,x_msg_data                     OUT NOCOPY 		VARCHAR2)

 is

BEGIN

null;

END create_prop_person_question;
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
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2)  is

BEGIN
null;

END  update_prop_person_question;
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_person_question (
  p_init_msg_list                IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 		VARCHAR2
 ,p_record_version_number        IN   		NUMBER
 ,x_return_status                OUT NOCOPY  		VARCHAR2
 ,x_msg_count                    OUT NOCOPY  		NUMBER
 ,x_msg_data                     OUT NOCOPY  		VARCHAR2)  is

BEGIN
null;


END delete_prop_person_question;

------------------------------------------------------------------------------------------
PROCEDURE EXPLANATION_OR_DATE_REQUIRED (
         		       p_question_number		IN	VARCHAR2,
         		       p_answer				IN	VARCHAR2,
         		       p_explanation			IN	VARCHAR2,
         		       p_review_date			IN	VARCHAR2,
         		       x_return_status          	OUT NOCOPY 	VARCHAR2) is



  BEGIN
null;

  END EXPLANATION_OR_DATE_REQUIRED;


--------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2) is

 BEGIN
  null;

END CHECK_LOCK;
-------------------------------------------------------------------------------------

PROCEDURE CHECK_ERRORS is
 BEGIN
    null;

END CHECK_ERRORS;
----------------------------------------------------------------------------------------

-- the following code transfers the questions pertaining to the appropriate proposal from the
-- igw_questions table to the igw_prop_person_questions table

PROCEDURE POPULATE_PROP_PERSON_QUESTIONS (  p_init_msg_list     in    varchar2   := FND_API.G_FALSE,
 					    p_commit            in    varchar2   := FND_API.G_FALSE,
 					    p_validate_only     in    varchar2   := FND_API.G_FALSE,
					    p_proposal_id  	in    number,
					    p_person_id    	in    number,
					    p_party_id    	in    number,
					    x_rowid        	out NOCOPY   varchar2,
					    x_return_status	out NOCOPY   varchar2,
					    x_msg_count         out NOCOPY   number,
 					    x_msg_data          out NOCOPY   varchar2) is


BEGIN
null;

END POPULATE_PROP_PERSON_QUESTIONS;

END IGW_PROP_PERSON_QUESTIONS_PVT;

/
