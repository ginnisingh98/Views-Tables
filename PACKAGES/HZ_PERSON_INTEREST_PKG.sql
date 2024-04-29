--------------------------------------------------------
--  DDL for Package HZ_PERSON_INTEREST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PERSON_INTEREST_PKG" AUTHID CURRENT_USER as
/* $Header: ARHPINTS.pls 115.4 2003/02/10 09:48:04 ssmohan ship $ */

PROCEDURE Insert_Row(
                  x_PERSON_INTEREST_ID         IN   OUT NOCOPY   NUMBER,
                  x_LEVEL_OF_INTEREST          IN     VARCHAR2,
                  x_PARTY_ID                   IN     NUMBER,
                  x_LEVEL_OF_PARTICIPATION     IN     VARCHAR2,
                  x_INTEREST_TYPE_CODE         IN     VARCHAR2,
                  x_SPORT_INDICATOR            IN     VARCHAR2,
                  x_INTEREST_NAME              IN     VARCHAR2,
                  x_COMMENTS                   IN     VARCHAR2,
                  x_SUB_INTEREST_TYPE_CODE     IN     VARCHAR2,
                  x_TEAM                       IN     VARCHAR2,
                  x_SINCE                      IN     DATE,
                  x_OBJECT_VERSION_NUMBER      IN     NUMBER,
                  x_STATUS                     IN     VARCHAR2,
                  x_CREATED_BY_MODULE          IN     VARCHAR2,
                  x_APPLICATION_ID             IN     NUMBER
                  );



PROCEDURE Lock_Row(
                  x_Rowid                       IN      VARCHAR2,
                  x_PERSON_INTEREST_ID          IN      NUMBER,
                  x_LEVEL_OF_INTEREST           IN      VARCHAR2,
                  x_PARTY_ID                    IN      NUMBER,
                  x_LEVEL_OF_PARTICIPATION      IN      VARCHAR2,
                  x_INTEREST_TYPE_CODE          IN      VARCHAR2,
                  x_SPORT_INDICATOR             IN      VARCHAR2,
                  x_INTEREST_NAME               IN      VARCHAR2,
                  x_CREATED_BY                  IN      NUMBER,
                  x_CREATION_DATE               IN      DATE,
                  x_LAST_UPDATE_LOGIN           IN      NUMBER,
                  x_LAST_UPDATE_DATE            IN      DATE,
                  x_LAST_UPDATED_BY             IN      NUMBER,
                  x_REQUEST_ID                  IN      NUMBER,
                  x_PROGRAM_APPLICATION_ID      IN      NUMBER,
                  x_PROGRAM_ID                  IN      NUMBER,
                  x_PROGRAM_UPDATE_DATE         IN      DATE,
                  x_COMMENTS                    IN      VARCHAR2,
                  x_SUB_INTEREST_TYPE_CODE      IN      VARCHAR2,
                  x_TEAM                        IN      VARCHAR2,
                  x_SINCE                       IN      DATE,
                  x_STATUS                      IN      VARCHAR2,
                  x_CREATED_BY_MODULE           IN      VARCHAR2
                  );



PROCEDURE Update_Row(
                   x_Rowid         IN OUT NOCOPY          VARCHAR2,
                   x_PERSON_INTEREST_ID         IN     NUMBER,
		   x_LEVEL_OF_INTEREST          IN     VARCHAR2,
		   x_PARTY_ID                   IN     NUMBER,
		   x_LEVEL_OF_PARTICIPATION     IN     VARCHAR2,
		   x_INTEREST_TYPE_CODE         IN     VARCHAR2,
		   x_SPORT_INDICATOR            IN     VARCHAR2,
		   x_INTEREST_NAME              IN     VARCHAR2,
		   x_COMMENTS                   IN     VARCHAR2,
		   x_SUB_INTEREST_TYPE_CODE     IN     VARCHAR2,
		   x_TEAM                       IN     VARCHAR2,
		   x_SINCE                      IN     DATE,
		   x_OBJECT_VERSION_NUMBER      IN     NUMBER,
		   x_STATUS                     IN     VARCHAR2,
		   x_CREATED_BY_MODULE          IN     VARCHAR2,
                   x_APPLICATION_ID             IN     NUMBER
                  );



PROCEDURE Delete_Row(                  x_PERSON_INTEREST_ID            NUMBER);


PROCEDURE Select_Row (
    		  x_person_interest_id                    IN OUT NOCOPY NUMBER,
    		  x_level_of_interest                     OUT    NOCOPY VARCHAR2,
		  x_party_id                              OUT    NOCOPY NUMBER,
		  x_level_of_participation                OUT    NOCOPY VARCHAR2,
		  x_interest_type_code                    OUT    NOCOPY VARCHAR2,
		  x_comments                              OUT    NOCOPY VARCHAR2,
		  x_sport_indicator                       OUT    NOCOPY VARCHAR2,
		  x_sub_interest_type_code                OUT    NOCOPY VARCHAR2,
		  x_interest_name                         OUT    NOCOPY VARCHAR2,
		  x_team                                  OUT    NOCOPY VARCHAR2,
		  x_since                                 OUT    NOCOPY DATE,
		  x_status                                OUT    NOCOPY VARCHAR2,
		  x_application_id                        OUT    NOCOPY NUMBER,
		  x_created_by_module                     OUT    NOCOPY VARCHAR2
);



END HZ_PERSON_INTEREST_PKG;

 

/
