--------------------------------------------------------
--  DDL for Package IGW_STUDY_TITLES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_STUDY_TITLES_TBH" AUTHID CURRENT_USER as
--$Header: igwtstts.pls 115.4 2002/11/15 00:50:13 ashkumar ship $
procedure INSERT_ROW (
  X_ROWID  out NOCOPY rowid,
  X_STUDY_TITLE_ID in NUMBER,
  X_STUDY_TITLE in VARCHAR2,
  X_ENROLLMENT_STATUS in VARCHAR2,
  X_PROTOCOL_NUMBER in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  ) ;

procedure UPDATE_ROW (
  X_ROWID IN ROWID,
  X_STUDY_TITLE_ID in NUMBER,
  X_STUDY_TITLE in VARCHAR2,
  X_ENROLLMENT_STATUS in VARCHAR2,
  X_PROTOCOL_NUMBER in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_RECORD_VERSION_NUMBER IN NUMBER,
  X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  );

procedure DELETE_ROW (
  x_rowid in rowid
  ,x_study_title_id in number
  ,x_record_version_number in number
  ,X_RETURN_STATUS   OUT NOCOPY VARCHAR2
);

end;

 

/
