--------------------------------------------------------
--  DDL for Package IGW_QUESTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_QUESTIONS_PKG" AUTHID CURRENT_USER as
 -- $Header: igwstqus.pls 115.5 2002/11/15 00:47:45 ashkumar ship $

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_QUESTION_NUMBER in VARCHAR2,
  X_APPLIES_TO in VARCHAR2,
  X_EXPLANATION_FOR_YES_FLAG in VARCHAR2,
  X_EXPLANATION_FOR_NO_FLAG in VARCHAR2,
  X_DATE_FOR_YES_FLAG in VARCHAR2,
  X_DATE_FOR_NO_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_EXPLANATION in VARCHAR2,
  X_POLICY in VARCHAR2,
  X_REGULATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_QUESTION_NUMBER in VARCHAR2,
  X_APPLIES_TO in VARCHAR2,
  X_EXPLANATION_FOR_YES_FLAG in VARCHAR2,
  X_EXPLANATION_FOR_NO_FLAG in VARCHAR2,
  X_DATE_FOR_YES_FLAG in VARCHAR2,
  X_DATE_FOR_NO_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_EXPLANATION in VARCHAR2,
  X_POLICY in VARCHAR2,
  X_REGULATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_QUESTION_NUMBER in VARCHAR2,
  X_APPLIES_TO in VARCHAR2,
  X_EXPLANATION_FOR_YES_FLAG in VARCHAR2,
  X_EXPLANATION_FOR_NO_FLAG in VARCHAR2,
  X_DATE_FOR_YES_FLAG in VARCHAR2,
  X_DATE_FOR_NO_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_EXPLANATION in VARCHAR2,
  X_POLICY in VARCHAR2,
  X_REGULATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_QUESTION_NUMBER in VARCHAR2
);
procedure ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_QUESTION_NUMBER in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPLANATION in VARCHAR2,
  X_POLICY in VARCHAR2,
  X_REGULATION in VARCHAR2,
  X_OWNER in VARCHAR2);

end IGW_QUESTIONS_PKG;

 

/
