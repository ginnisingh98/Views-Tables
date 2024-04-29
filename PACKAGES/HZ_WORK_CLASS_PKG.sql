--------------------------------------------------------
--  DDL for Package HZ_WORK_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORK_CLASS_PKG" AUTHID CURRENT_USER as
/* $Header: ARHPWCTS.pls 115.5 2003/02/10 09:56:56 ssmohan ship $ */


PROCEDURE Insert_Row(
                  x_WORK_CLASS_ID             IN OUT NOCOPY    NUMBER,
	          x_LEVEL_OF_EXPERIENCE       IN    VARCHAR2,
	          x_WORK_CLASS_NAME           IN    VARCHAR2,
	          x_EMPLOYMENT_HISTORY_ID     IN    NUMBER,
	          x_STATUS                    IN    VARCHAR2,
	          x_OBJECT_VERSION_NUMBER     IN    NUMBER,
    		  x_CREATED_BY_MODULE         IN    VARCHAR2,
    		  x_application_id            IN    NUMBER
    		  );



PROCEDURE Lock_Row(
                  x_Rowid                       IN  VARCHAR2,
                  x_WORK_CLASS_ID               IN  NUMBER,
                  x_LEVEL_OF_EXPERIENCE         IN  VARCHAR2,
                  x_WORK_CLASS_NAME             IN  VARCHAR2,
                  x_CREATED_BY                  IN  NUMBER,
                  x_EMPLOYMENT_HISTORY_ID       IN  NUMBER,
                  x_CREATION_DATE               IN  DATE,
                  x_LAST_UPDATE_LOGIN           IN  NUMBER,
                  x_LAST_UPDATE_DATE            IN  DATE,
                  x_LAST_UPDATED_BY             IN  NUMBER,
                  x_REQUEST_ID                  IN  NUMBER,
                  x_PROGRAM_APPLICATION_ID      IN  NUMBER,
                  x_PROGRAM_ID                  IN  NUMBER,
                  x_PROGRAM_UPDATE_DATE         IN  DATE,
                  x_STATUS                      IN  VARCHAR2);



PROCEDURE Update_Row(
                  x_Rowid         IN  OUT NOCOPY         VARCHAR2,
                  x_WORK_CLASS_ID             IN     NUMBER,
		  x_LEVEL_OF_EXPERIENCE       IN    VARCHAR2,
		  x_WORK_CLASS_NAME           IN    VARCHAR2,
		  x_EMPLOYMENT_HISTORY_ID     IN    NUMBER,
		  x_STATUS                    IN    VARCHAR2,
		  x_OBJECT_VERSION_NUMBER     IN    NUMBER,
		  x_CREATED_BY_MODULE         IN    VARCHAR2,
    		  x_application_id            IN    NUMBER
    		  );


PROCEDURE Select_Row (
		x_work_class_id                         IN OUT NOCOPY NUMBER,
		x_level_of_experience                   OUT    NOCOPY VARCHAR2,
		x_work_class_name                       OUT    NOCOPY VARCHAR2,
		x_employment_history_id                 OUT    NOCOPY NUMBER,
		x_status                                OUT    NOCOPY VARCHAR2,
		x_application_id                        OUT    NOCOPY NUMBER,
		x_created_by_module                     OUT    NOCOPY VARCHAR2
);



PROCEDURE Delete_Row(                  x_WORK_CLASS_ID           IN      NUMBER);

END HZ_WORK_CLASS_PKG;

 

/
