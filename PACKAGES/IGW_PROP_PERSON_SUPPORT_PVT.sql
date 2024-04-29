--------------------------------------------------------
--  DDL for Package IGW_PROP_PERSON_SUPPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PERSON_SUPPORT_PVT" AUTHID CURRENT_USER as
 /* $Header: igwvppss.pls 115.6 2002/11/15 00:42:55 ashkumar ship $ */
PROCEDURE create_prop_person_support (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_get_data			  IN            VARCHAR2,
 x_rowid 		          out NOCOPY 		VARCHAR2,
 X_PROP_PERSON_SUPPORT_ID	  OUT NOCOPY           NUMBER,
 P_PROPOSAL_ID                    IN		NUMBER,
 P_PERSON_ID                      IN		NUMBER,
 P_PARTY_ID                       IN		NUMBER,
 P_SUPPORT_TYPE                   IN		VARCHAR2,
 P_PROPOSAL_AWARD_ID              IN		NUMBER,
 P_PROPOSAL_AWARD_NUMBER          IN	 	VARCHAR2,
 P_PROPOSAL_AWARD_TITLE           IN 	 	VARCHAR2,
 P_PI_PERSON_ID                   IN		NUMBER,
 P_PI_PARTY_ID                    IN		NUMBER,
 P_PI_PERSON_NAME		  IN		VARCHAR2,
 P_SPONSOR_ID                     IN		NUMBER,
 P_SPONSOR_NAME		  	  IN 		VARCHAR2,
 P_PROJECT_LOCATION               IN		VARCHAR2,
 P_LOCATION_PARTY_ID              IN		NUMBER,
 P_PROJECT_LOCATION_NAME	  IN		VARCHAR2,
 P_START_DATE                     IN		DATE,
 P_END_DATE                       IN		DATE,
 P_PERCENT_EFFORT                 IN		NUMBER,
 P_MAJOR_GOALS                    IN		VARCHAR2,
 P_OVERLAP                        IN		VARCHAR2,
 P_ANNUAL_DIRECT_COST             IN		NUMBER,
 P_TOTAL_COST                     IN		NUMBER,
 P_CALENDAR_START_DATE            IN		DATE,
 P_CALENDAR_END_DATE              IN		DATE,
 P_ACADEMIC_START_DATE            IN		DATE,
 P_ACADEMIC_END_DATE              IN		DATE,
 P_SUMMER_START_DATE              IN		DATE,
 P_SUMMER_END_DATE                IN		DATE,
 P_ATTRIBUTE_CATEGORY             IN		VARCHAR2,
 P_ATTRIBUTE1                     IN		VARCHAR2,
 P_ATTRIBUTE2                     IN		VARCHAR2,
 P_ATTRIBUTE3                     IN		VARCHAR2,
 P_ATTRIBUTE4                     IN		VARCHAR2,
 P_ATTRIBUTE5                     IN		VARCHAR2,
 P_ATTRIBUTE6                     IN		VARCHAR2,
 P_ATTRIBUTE7                     IN		VARCHAR2,
 P_ATTRIBUTE8                     IN		VARCHAR2,
 P_ATTRIBUTE9                     IN		VARCHAR2,
 P_ATTRIBUTE10                    IN		VARCHAR2,
 P_ATTRIBUTE11                    IN		VARCHAR2,
 P_ATTRIBUTE12                    IN		VARCHAR2,
 P_ATTRIBUTE13                    IN		VARCHAR2,
 P_ATTRIBUTE14                    IN		VARCHAR2,
 P_ATTRIBUTE15                    IN		VARCHAR2,
 P_SEQUENCE_NUMBER		  IN		NUMBER,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2);
--------------------------------------------------------------------------------------------------------------

Procedure update_prop_person_support (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_get_data     		  IN            VARCHAR2,
 x_rowid 		          IN 		VARCHAR2,
 P_PROP_PERSON_SUPPORT_ID	  IN           NUMBER,
 P_PROPOSAL_ID                    IN		NUMBER,
 P_PERSON_ID                      IN		NUMBER,
 P_PARTY_ID                       IN		NUMBER,
 P_SUPPORT_TYPE                   IN		VARCHAR2,
 P_PROPOSAL_AWARD_ID              IN		NUMBER,
 P_PROPOSAL_AWARD_NUMBER          IN	 	VARCHAR2,
 P_PROPOSAL_AWARD_TITLE           IN 	 	VARCHAR2,
 P_PI_PERSON_ID                   IN		NUMBER,
 P_PI_PARTY_ID                    IN		NUMBER,
 P_PI_PERSON_NAME		  IN		VARCHAR2,
 P_SPONSOR_ID                     IN		NUMBER,
 P_SPONSOR_NAME		 	  IN		VARCHAR2,
 P_PROJECT_LOCATION               IN		VARCHAR2,
 P_LOCATION_PARTY_ID              IN		NUMBER,
 P_PROJECT_LOCATION_NAME	  IN		VARCHAR2,
 P_START_DATE                     IN		DATE,
 P_END_DATE                       IN		DATE,
 P_PERCENT_EFFORT                 IN		NUMBER,
 P_MAJOR_GOALS                    IN		VARCHAR2,
 P_OVERLAP                        IN		VARCHAR2,
 P_ANNUAL_DIRECT_COST             IN		NUMBER,
 P_TOTAL_COST                     IN		NUMBER,
 P_CALENDAR_START_DATE            IN		DATE,
 P_CALENDAR_END_DATE              IN		DATE,
 P_ACADEMIC_START_DATE            IN		DATE,
 P_ACADEMIC_END_DATE              IN		DATE,
 P_SUMMER_START_DATE              IN		DATE,
 P_SUMMER_END_DATE                IN		DATE,
 P_ATTRIBUTE_CATEGORY             IN		VARCHAR2,
 P_ATTRIBUTE1                     IN		VARCHAR2,
 P_ATTRIBUTE2                     IN		VARCHAR2,
 P_ATTRIBUTE3                     IN		VARCHAR2,
 P_ATTRIBUTE4                     IN		VARCHAR2,
 P_ATTRIBUTE5                     IN		VARCHAR2,
 P_ATTRIBUTE6                     IN		VARCHAR2,
 P_ATTRIBUTE7                     IN		VARCHAR2,
 P_ATTRIBUTE8                     IN		VARCHAR2,
 P_ATTRIBUTE9                     IN		VARCHAR2,
 P_ATTRIBUTE10                    IN		VARCHAR2,
 P_ATTRIBUTE11                    IN		VARCHAR2,
 P_ATTRIBUTE12                    IN		VARCHAR2,
 P_ATTRIBUTE13                    IN		VARCHAR2,
 P_ATTRIBUTE14                    IN		VARCHAR2,
 P_ATTRIBUTE15                    IN		VARCHAR2,
 p_record_version_number          IN 		NUMBER,
 P_SEQUENCE_NUMBER		  IN 		NUMBER,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2);
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_person_support (
  p_init_msg_list                IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 		VARCHAR2
 ,p_record_version_number        IN   		NUMBER
 ,x_return_status                OUT NOCOPY  		VARCHAR2
 ,x_msg_count                    OUT NOCOPY  		NUMBER
 ,x_msg_data                     OUT NOCOPY  		VARCHAR2);

------------------------------------------------------------------------------------------

PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2);


-------------------------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS;

-------------------------------------------------------------------------------------------------------
  PROCEDURE POPULATE_OTHER_SUPPORT_TABLE (p_init_msg_list     in    varchar2   := FND_API.G_FALSE,
 					  p_commit            in    varchar2   := FND_API.G_FALSE,
 					  p_validate_only     in    varchar2   := FND_API.G_FALSE,
  					  p_proposal_id	      in    number,
  					  p_person_id	      in    number,
  					  p_party_id 	      in    number,
					  x_return_status     out NOCOPY   varchar2,
					  x_msg_count         out NOCOPY   number,
 					  x_msg_data          out NOCOPY   varchar2);

 -------------------------------------------------------------------------------------------------------------
 PROCEDURE POPULATE_PROP_AWARD_INFO (p_proposal_id      	in    number,
  				    p_person_id	 		in    number,
  				    p_party_id 	 		in    number,
  				    p_support_type      	in    varchar2,
  				    p_proposal_award_number	in    varchar2,
  				    x_proposal_award_id		out NOCOPY   number,
  				    x_proposal_award_title      out NOCOPY   varchar2,
  				    x_sponsor_id		out NOCOPY   number,
  				    x_start_date		out NOCOPY   date,
  				    x_end_date			out NOCOPY   date,
  				    x_pi_person_id		out NOCOPY   number,
  				    x_pi_party_id 		out NOCOPY   number,
  				    x_project_location		out NOCOPY   varchar2,
  				    x_location_party_id		out NOCOPY   number,
  				    x_annual_direct_cost	out NOCOPY   number,
  				    x_total_cost		out NOCOPY   number,
  				    x_major_goals		out NOCOPY   varchar2,
  				    x_percent_effort		out NOCOPY   number,
				    x_return_status     	out NOCOPY   varchar2);
---------------------------------------------------------------------------------------------------------------
 PROCEDURE Get_Award_Id
   (
      p_context_field     IN VARCHAR2,
      p_check_id_flag     IN VARCHAR2,
      p_award_number      IN VARCHAR2,
      p_award_id          IN NUMBER,
      x_award_id       OUT NOCOPY NUMBER,
      x_return_status     OUT NOCOPY VARCHAR2
   );

FUNCTION get_person_name
( p_party_id number, p_person_id number )
RETURN varchar2;


END IGW_PROP_PERSON_SUPPORT_PVT;

 

/
