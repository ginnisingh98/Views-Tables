--------------------------------------------------------
--  DDL for Package HR_NAVIGATION_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NAVIGATION_UNITS_PKG" AUTHID CURRENT_USER as
/* $Header: pewfl01t.pkh 115.5 2003/06/18 15:49:34 pkakar ship $ */

procedure OWNER_TO_WHO (  X_OWNER                           in VARCHAR2,
                          X_CREATION_DATE                   out nocopy DATE,
                          X_CREATED_BY                      out nocopy NUMBER,
                          X_LAST_UPDATE_DATE                out nocopy DATE,
                          X_LAST_UPDATED_BY                 out nocopy NUMBER,
                          X_LAST_UPDATE_LOGIN               out nocopy NUMBER
);

PROCEDURE Insert_Row(X_Rowid                               IN OUT nocopy VARCHAR2,
                     X_Nav_Unit_Id                         IN OUT nocopy NUMBER,
                     X_Default_Workflow_Id                 NUMBER,
                     X_Application_Abbrev                  VARCHAR2,
                     X_Default_Label                       VARCHAR2,
                     X_Form_Name                           VARCHAR2,
                     X_Max_Number_Of_Nav_Buttons           NUMBER,
                     X_Block_Name                          VARCHAR2,
  		     X_LANGUAGE_CODE in varchar2 default hr_api.userenv_lang
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Nav_Unit_Id                            NUMBER,
                   X_Default_Workflow_Id                    NUMBER,
                   X_Application_Abbrev                     VARCHAR2,
                   X_Default_Label                          VARCHAR2,
                   X_Form_Name                              VARCHAR2,
                   X_Max_Number_Of_Nav_Buttons              NUMBER,
                   X_Block_Name                             VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Nav_Unit_Id                         NUMBER,
                     X_Default_Workflow_Id                 NUMBER,
                     X_Application_Abbrev                  VARCHAR2,
                     X_Default_Label                       VARCHAR2,
                     X_Form_Name                           VARCHAR2,
                     X_Max_Number_Of_Nav_Buttons           NUMBER,
                     X_Block_Name                          VARCHAR2,
                     X_Language_Code varchar2 default hr_api.userenv_lang
                     );

Procedure UPDATE_ROW (X_NAV_UNIT_ID                      NUMBER,
  		X_DEFAULT_WORKFLOW_ID  			 NUMBER,
  		X_APPLICATION_ABBREV  			 VARCHAR2,
  		X_DEFAULT_LABEL  			 VARCHAR2,
  		X_FORM_NAME  			 	 VARCHAR2,
  		X_MAX_NUMBER_OF_NAV_BUTTONS  		 NUMBER,
  		X_BLOCK_NAME  				 VARCHAR2,
                X_LANGUAGE_CODE	 in varchar2 default hr_api.userenv_lang
);

PROCEDURE Delete_Row(X_Nav_unit_id VARCHAR2, x_rowid varchar2);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_WORKFLOW_NAME in VARCHAR2,
  X_APPLICATION_ABBREV in VARCHAR2,
  X_DEFAULT_LABEL in VARCHAR2,
  X_MAX_NUMBER_OF_NAV_BUTTONS in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_DEFAULT_LABEL in VARCHAR2
);

END HR_NAVIGATION_UNITS_PKG;

 

/
