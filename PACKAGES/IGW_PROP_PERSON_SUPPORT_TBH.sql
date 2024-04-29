--------------------------------------------------------
--  DDL for Package IGW_PROP_PERSON_SUPPORT_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PERSON_SUPPORT_TBH" AUTHID CURRENT_USER as
--$Header: igwtppss.pls 115.5 2002/11/15 00:43:21 ashkumar ship $

PROCEDURE INSERT_ROW (
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
 P_SPONSOR_ID                     IN		NUMBER,
 P_PROJECT_LOCATION               IN		VARCHAR2,
 P_LOCATION_PARTY_ID              IN		NUMBER,
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
 p_mode 			  IN 		VARCHAR2 default 'R',
 p_sequence_number                IN            NUMBER,
 x_return_status                  out NOCOPY  		VARCHAR2);


PROCEDURE UPDATE_ROW (
 X_ROWID 			  IN 		VARCHAR2,
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
 P_SPONSOR_ID                     IN		NUMBER,
 P_PROJECT_LOCATION               IN		VARCHAR2,
 P_LOCATION_PARTY_ID              IN		NUMBER,
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
 P_MODE 			  IN 		VARCHAR2 default 'R',
 P_RECORD_VERSION_NUMBER          IN            NUMBER,
 P_SEQUENCE_NUMBER                IN            NUMBER,
 X_RETURN_STATUS                  OUT NOCOPY  		VARCHAR2);


PROCEDURE DELETE_ROW (
  x_rowid 		  	in 		VARCHAR2,
  p_record_version_number 	in 		NUMBER,
  x_return_status         	out NOCOPY  		VARCHAR2);


 END IGW_PROP_PERSON_SUPPORT_TBH;

 

/
