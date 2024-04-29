--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSON_SUPPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSON_SUPPORT_PVT" as
/* $Header: igwvppsb.pls 120.5 2005/09/12 21:05:18 vmedikon ship $ */
PROCEDURE create_prop_person_support (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_get_data     		  IN            VARCHAR2,
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
 P_SPONSOR_NAME			  IN		VARCHAR2,
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
 x_msg_data                       OUT NOCOPY 		VARCHAR2)

 is

  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;


  l_proposal_award_id		number := p_proposal_award_id;
  l_proposal_award_title        varchar2(250) := p_proposal_award_title;
  l_sponsor_id		        number := p_sponsor_id;
  l_start_date		        date := p_start_date;
  l_end_date			date := p_end_date;
  l_pi_person_id		number := p_pi_person_id;
  l_pi_party_id 		number := p_pi_party_id;
  l_project_location		varchar2(100) := p_project_location;
  l_annual_direct_cost	        number := p_annual_direct_cost;
  l_total_cost		        number := p_total_cost;
  l_major_goals		        varchar2(4000) := p_major_goals;
  l_percent_effort		number := p_percent_effort;

  l_location_party_id           number := p_location_party_id;




BEGIN
     null;

END create_prop_person_support;
--------------------------------------------------------------------------------------------------------------

Procedure update_prop_person_support (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_get_data     		  IN            VARCHAR2,
 x_rowid 		          IN 		VARCHAR2,
 P_PROP_PERSON_SUPPORT_ID	  IN            NUMBER,
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
 P_SEQUENCE_NUMBER		  IN		NUMBER,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2)  is


  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;

  l_proposal_award_id		number := p_proposal_award_id;
  l_proposal_award_title        varchar2(250) := p_proposal_award_title;
  l_sponsor_id		        number := p_sponsor_id;
  l_start_date		        date := p_start_date;
  l_end_date			date := p_end_date;
  l_pi_person_id		number := p_pi_person_id;
  l_pi_party_id 		number := p_pi_party_id ;
  l_project_location		varchar2(100) := p_project_location;
  l_annual_direct_cost	        number := p_annual_direct_cost;
  l_total_cost		        number := p_total_cost;
  l_major_goals		        varchar2(4000) := p_major_goals;
  l_percent_effort		number := p_percent_effort;

  l_location_party_id           number := p_location_party_id;

BEGIN
     null;

END  update_prop_person_support;
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_person_support (
  p_init_msg_list                IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 		VARCHAR2
 ,p_record_version_number        IN   		NUMBER
 ,x_return_status                OUT NOCOPY  		VARCHAR2
 ,x_msg_count                    OUT NOCOPY  		NUMBER
 ,x_msg_data                     OUT NOCOPY  		VARCHAR2)  is

  l_proposal_id              NUMBER;


  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_performing_org_id        NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;

BEGIN
     null;
END delete_prop_person_support;

------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2) is

 l_proposal_id		number;
 BEGIN
       null;
END CHECK_LOCK;

-------------------------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS is
 l_msg_count 	NUMBER;
 BEGIN
     null;

 END CHECK_ERRORS;
 -------------------------------------------------------------------------------------------------------

  PROCEDURE POPULATE_OTHER_SUPPORT_TABLE (p_init_msg_list     in    varchar2   := FND_API.G_FALSE,
 					  p_commit            in    varchar2   := FND_API.G_FALSE,
 					  p_validate_only     in    varchar2   := FND_API.G_FALSE,
  					  p_proposal_id	      in    number,
  					  p_person_id	      in    number,
  					  p_party_id 	      in    number,
					  x_return_status     out NOCOPY   varchar2,
					  x_msg_count         out NOCOPY   number,
 					  x_msg_data          out NOCOPY   varchar2) IS

     n				number;
     prop_person_support        igw_prop_person_support%rowtype;
     v_pi_name			per_all_people_f.FULL_NAME%TYPE;
     deadline_date              date;
     x_date			date;
     x_date_minus_three_yrs     date;
     prop_id                    number;   -- This is proposal_id in igw_awards_v
     percent_effort             number;
     x_rowid                    varchar2(30);
     x_prop_person_support_id   number;

  cursor c is
           select ipp.person_id,
                  ipp.person_party_id,
                  ipp.percent_effort,
                  ipv.proposal_id,
		  ipv.proposal_number,
                  ipv.proposal_title,
		  ipv.proposal_start_date,
                  ipv.proposal_end_date,
		  ipv.sponsor_id,
		  ipv.pi_id,
                  ipv.major_goals,
                  ipv.total_cost,
		  ipv.annual_direct_cost,
                  ipv.project_location_id
            from  igw_prop_persons    ipp,
		  igw_prop_v   ipv
           where  ipp.person_party_id = p_party_id AND
                  ipv.proposal_id = ipp.proposal_id AND
		  ipv.proposal_id <> p_proposal_id   AND
		  ipv.sponsor_action_code in ('8', '4', '5') AND
                  ipv.proposal_type_code <> 3;


   cursor d is
           select gp.person_id,
		  pa.award_id,
		  pa.funding_source_award_number,
                  pa.award_full_name,
                  pa.major_goals,
		  pa.funding_source_id,
		  pa.start_date_active,
                  pa.end_date_active,
                  pa.proposal_id
            from  gms_personnel        gp,
		  igw_awards_v        pa
           where  gp.person_id = p_person_id           AND
                  gp.award_id = pa.award_id            AND
		  pa.status = 'ACTIVE'                 AND
		  ((pa.proposal_id <> p_proposal_id)  OR (pa.proposal_id is NULL));


  cursor e is
           select gp.person_id,
		  pa.award_id,
		  pa.funding_source_award_number,
                  pa.award_full_name,
                  pa.major_goals,
		  pa.funding_source_id,
		  pa.start_date_active,
                  pa.end_date_active,
                  pa.proposal_id
            from  gms_personnel        gp,
		  igw_awards_v        pa
           where  gp.person_id = p_person_id           AND
                  gp.award_id = pa.award_id           		  AND
		  pa.close_date > x_date_minus_three_yrs	  AND
                  pa.close_date < x_date			  AND
                  pa.close_date is not null   			  AND
		  pa.status = 'CLOSED'               		  AND
		  ((pa.proposal_id <> p_proposal_id)  OR (pa.proposal_id is NULL));



BEGIN
     null;

END POPULATE_OTHER_SUPPORT_TABLE;

-------------------------------------------------------------------------------------------------------
PROCEDURE POPULATE_PROP_AWARD_INFO (p_proposal_id      		in    number,
  				    p_person_id	 		in    number,
  				    p_party_id	 		in    number,
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
				    x_return_status     	out NOCOPY   varchar2) IS

l_proposal_id     number;
BEGIN
     null;

END POPULATE_PROP_AWARD_INFO;
------------------------------------------------------------------------------------------------------
  PROCEDURE Get_Award_Id
   (
      p_context_field     IN VARCHAR2,
      p_check_id_flag     IN VARCHAR2,
      p_award_number      IN VARCHAR2,
      p_award_id          IN NUMBER,
      x_award_id       OUT NOCOPY NUMBER,
      x_return_status     OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Get_Award_Id';

     --Possible values for p_context_field
     /* AWARD_ID */

   BEGIN

         null;
   END Get_Award_id;

FUNCTION get_person_name
( p_party_id number, p_person_id number )
RETURN varchar2 IS
   o_person_name varchar2(250);
BEGIN
     null;
end;



END IGW_PROP_PERSON_SUPPORT_PVT;

/
