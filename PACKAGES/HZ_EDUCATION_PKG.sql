--------------------------------------------------------
--  DDL for Package HZ_EDUCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EDUCATION_PKG" AUTHID CURRENT_USER as
/* $Header: ARHPEDTS.pls 115.4 2003/02/10 09:38:28 ssmohan ship $ */


PROCEDURE Insert_Row(
                  x_EDUCATION_ID                IN   OUT NOCOPY    NUMBER,
                  x_COURSE_MAJOR                IN        VARCHAR2,
                  x_PARTY_ID                    IN        NUMBER,
                  x_DEGREE_RECEIVED             IN        VARCHAR2,
                  x_LAST_DATE_ATTENDED          IN        DATE,
                  x_SCHOOL_ATTENDED_NAME        IN        VARCHAR2,
                  x_TYPE_OF_SCHOOL              IN        VARCHAR2,
                  x_START_DATE_ATTENDED         IN        DATE,
                  x_STATUS                      IN        VARCHAR2,
                  x_SCHOOL_PARTY_ID             IN        NUMBER,
    		  x_OBJECT_VERSION_NUMBER       IN        NUMBER,
    		  x_CREATED_BY_MODULE           IN        VARCHAR2,
    		  x_APPLICATION_ID              IN        NUMBER
               );



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_EDUCATION_ID                  NUMBER,
                  x_COURSE_MAJOR                  VARCHAR2,
                  x_PARTY_ID                      NUMBER,
                  x_SCHOOL_PARTY_ID               NUMBER,
                  x_DEGREE_RECEIVED               VARCHAR2,
                  x_LAST_DATE_ATTENDED            DATE,
                  x_SCHOOL_ATTENDED_NAME          VARCHAR2,
                  x_TYPE_OF_SCHOOL                VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_START_DATE_ATTENDED           DATE,
                  x_STATUS                        VARCHAR2
		);



PROCEDURE Update_Row(
                  x_Rowid      IN  OUT NOCOPY            VARCHAR2,
		  x_EDUCATION_ID                IN   OUT NOCOPY    NUMBER,
		  x_COURSE_MAJOR                IN        VARCHAR2,
		  x_PARTY_ID                    IN        NUMBER,
		  x_SCHOOL_PARTY_ID             IN        NUMBER,
		  x_DEGREE_RECEIVED             IN        VARCHAR2,
		  x_LAST_DATE_ATTENDED          IN        DATE,
		  x_SCHOOL_ATTENDED_NAME        IN        VARCHAR2,
		  x_TYPE_OF_SCHOOL              IN        VARCHAR2,
		  x_START_DATE_ATTENDED         IN        DATE,
		  x_STATUS                      IN        VARCHAR2,
		  x_OBJECT_VERSION_NUMBER       IN        NUMBER,
		  x_CREATED_BY_MODULE           IN        VARCHAR2,
    		  x_APPLICATION_ID              IN        NUMBER
          );


PROCEDURE Select_Row (
		      x_education_id                          IN OUT NOCOPY NUMBER,
		      x_course_major                          OUT    NOCOPY VARCHAR2,
		      x_party_id                              OUT    NOCOPY NUMBER,
		      x_school_party_id                       OUT    NOCOPY NUMBER,
		      x_degree_received                       OUT    NOCOPY VARCHAR2,
		      x_last_date_attended                    OUT    NOCOPY DATE,
		      x_start_date_attended                   OUT    NOCOPY DATE,
		      x_school_attended_name                  OUT    NOCOPY VARCHAR2,
		      x_type_of_school                        OUT    NOCOPY VARCHAR2,
		      x_status                                OUT    NOCOPY VARCHAR2,
		      x_application_id                        OUT    NOCOPY NUMBER,
		      x_created_by_module                     OUT    NOCOPY VARCHAR2

);


PROCEDURE Delete_Row(
                  x_EDUCATION_ID               NUMBER);

END HZ_EDUCATION_PKG;

 

/
