--------------------------------------------------------
--  DDL for Package IGS_PE_DUP_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_DUP_PERSON" AUTHID CURRENT_USER AS
/* $Header: IGSPE04S.pls 120.1 2005/09/08 15:25:30 appldev noship $ */

  PROCEDURE FIND_DUPLICATES (
     X_MATCH_SET_ID  		 IN  VARCHAR2,
     X_SURNAME               IN  VARCHAR2,
     X_GIVEN_NAMES           IN  VARCHAR2,
     X_BIRTH_DT              IN  DATE,
     X_SEX                   IN  VARCHAR2,
     X_DUP_FOUND             OUT NOCOPY VARCHAR2,
     X_WHERE_CLAUSE          OUT NOCOPY VARCHAR2,
     X_EXACT_PARTIAL        IN OUT NOCOPY VARCHAR2,
     X_PERSON_ID            IN NUMBER DEFAULT NULL,
     X_PREF_ALTERNATE_ID    IN VARCHAR2 DEFAULT NULL
  );
END Igs_Pe_Dup_Person;

 

/
