--------------------------------------------------------
--  DDL for Package HZ_CITIZENSHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CITIZENSHIP_PKG" AUTHID CURRENT_USER as
/* $Header: ARHPCITS.pls 115.4 2003/02/10 09:35:04 ssmohan ship $ */

PROCEDURE Insert_Row(

		  x_CITIZENSHIP_ID    IN  OUT NOCOPY     NUMBER,
                  x_BIRTH_OR_SELECTED           IN       VARCHAR2,
                  x_PARTY_ID                    IN       NUMBER,
                  x_COUNTRY_CODE                IN       VARCHAR2,
                  x_DATE_DISOWNED               IN       DATE,
                  x_DATE_RECOGNIZED             IN       DATE,
                  x_DOCUMENT_REFERENCE          IN       VARCHAR2,
                  x_DOCUMENT_TYPE               IN       VARCHAR2,
                  x_END_DATE                    IN       DATE,
                  x_STATUS                      IN       VARCHAR2,
                  x_OBJECT_VERSION_NUMBER       IN       NUMBER,
                  x_CREATED_BY_MODULE           IN       VARCHAR2,
                  x_APPLICATION_ID              IN       NUMBER  );


PROCEDURE Lock_Row(
                  x_Rowid                     IN          VARCHAR2,
                  x_CITIZENSHIP_ID            IN          NUMBER,
                  x_BIRTH_OR_SELECTED         IN          VARCHAR2,
                  x_PARTY_ID                  IN          NUMBER,
                  x_COUNTRY_CODE              IN          VARCHAR2,
                  x_DATE_DISOWNED             IN          DATE,
                  x_DATE_RECOGNIZED           IN          DATE,
                  x_DOCUMENT_REFERENCE        IN          VARCHAR2,
                  x_DOCUMENT_TYPE             IN          VARCHAR2,
                  x_CREATED_BY                IN          NUMBER,
                  x_CREATION_DATE             IN          DATE,
                  x_LAST_UPDATE_LOGIN         IN          NUMBER,
                  x_LAST_UPDATE_DATE          IN          DATE,
                  x_LAST_UPDATED_BY           IN          NUMBER,
                  x_REQUEST_ID                IN          NUMBER,
                  x_PROGRAM_APPLICATION_ID    IN          NUMBER,
                  x_PROGRAM_ID                IN          NUMBER,
                  x_PROGRAM_UPDATE_DATE       IN          DATE,
                  x_WH_UPDATE_DATE            IN          DATE,
                  x_END_DATE                  IN          DATE,
                  x_STATUS                    IN          VARCHAR2);



PROCEDURE Update_Row(

                  x_Rowid              IN  OUT NOCOPY     VARCHAR2,
                  x_CITIZENSHIP_ID     IN  OUT NOCOPY     NUMBER,
                  x_BIRTH_OR_SELECTED         IN          VARCHAR2,
                  x_PARTY_ID                  IN          NUMBER,
                  x_COUNTRY_CODE              IN          VARCHAR2,
                  x_DATE_DISOWNED             IN          DATE,
                  x_DATE_RECOGNIZED           IN          DATE,
                  x_DOCUMENT_REFERENCE        IN          VARCHAR2,
                  x_DOCUMENT_TYPE             IN          VARCHAR2,
                  x_END_DATE                  IN          DATE,
                  x_STATUS                    IN          VARCHAR2,
		  x_OBJECT_VERSION_NUMBER     IN          NUMBER,
                  x_CREATED_BY_MODULE         IN          VARCHAR2,
                  x_APPLICATION_ID            IN          NUMBER
  );


PROCEDURE Select_Row (
   		 x_citizenship_id                        IN OUT NOCOPY NUMBER,
		 x_birth_or_selected                     OUT    NOCOPY VARCHAR2,
		 x_party_id                              OUT    NOCOPY NUMBER,
		 x_country_code                          OUT    NOCOPY VARCHAR2,
		 x_date_disowned                         OUT    NOCOPY DATE,
		 x_date_recognized                       OUT    NOCOPY DATE,
	         x_document_reference                    OUT    NOCOPY VARCHAR2,
                 x_end_date                              OUT    NOCOPY DATE,
                 x_document_type                         OUT    NOCOPY VARCHAR2,
                 x_status                                OUT    NOCOPY VARCHAR2,
                 x_application_id                        OUT    NOCOPY NUMBER,
                 x_created_by_module                     OUT    NOCOPY VARCHAR2
);


PROCEDURE Delete_Row(                  x_CITIZENSHIP_ID                NUMBER);

END HZ_CITIZENSHIP_PKG;

 

/
