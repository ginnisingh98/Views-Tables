--------------------------------------------------------
--  DDL for Package IGW_SUBJECT_INFORMATION_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_SUBJECT_INFORMATION_TBH" AUTHID CURRENT_USER as
 /* $Header: igwtsuis.pls 115.3 2002/11/15 00:51:13 ashkumar ship $ */
procedure INSERT_ROW (
  X_ROWID                           out NOCOPY rowid,
  X_STUDY_TITLE_ID                  IN  NUMBER,
  X_SUBJECT_TYPE_CODE               IN  VARCHAR2,
  X_SUBJECT_RACE_CODE               IN  VARCHAR2,
  X_SUBJECT_ETHNICITY_CODE	    IN  VARCHAR2,
  X_NO_OF_SUBJECTS                  IN  NUMBER,
  X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  );
-----------------------------------------------------------------------
procedure UPDATE_ROW (
  X_ROWID                           IN ROWID,
  X_STUDY_TITLE_ID                  IN  NUMBER,
  X_SUBJECT_TYPE_CODE               IN  VARCHAR2,
  X_SUBJECT_RACE_CODE               IN  VARCHAR2,
  X_SUBJECT_ETHNICITY_CODE	    IN  VARCHAR2,
  X_NO_OF_SUBJECTS                  IN  NUMBER,
  X_RECORD_VERSION_NUMBER           IN NUMBER,
  X_RETURN_STATUS                   OUT NOCOPY VARCHAR2
  );
---------------------------------------------------------------------------------
procedure DELETE_ROW (
  x_rowid in rowid
  ,x_record_version_number in number
  ,X_RETURN_STATUS   OUT NOCOPY VARCHAR2
);
end IGW_SUBJECT_INFORMATION_TBH;

 

/
