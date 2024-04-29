--------------------------------------------------------
--  DDL for Package PER_PERSON_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERSON_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: pedpt01t.pkh 115.6 2002/12/05 10:20:58 pkakar ship $ */
------------------------------------------------------------------------------
/*
==============================================================================

         26-MAR-96       AForte        Added check_duplicate_system_name which
                                       is used in Form PERWSDPT - Define Person
                                       Type and checks to make sure a user
                                       does not enter two rows with the same
                                       system name and a default of yes.
                                       Bug 338753.

         22-DEC-98       VTreiger      Added ADD_LANGUAGE procedure.

         21-APR-99       VTreiger      Added MLS validation procedures.

         07-JUL-99       JPBard        Added LOAD_ROW and TRANSLATE_ROW procs.
         14-NOV-00       SBirnage      Added Check_Default procedure for Bug
                                       1494778.
115.5    20-AUG-02       skota	       Added dbdrv commands
115.6    05-DEC-02       pkakar        Added nocopy changes
==============================================================================
                                                                            */
------------------------------------------------------------------------------
PROCEDURE check_duplicate_name(p_business_group_id  in     number,
			       p_user_person_type   in     varchar2,
			       p_rowid              in     varchar2);
-------------------------------------------------------------------------------
/*Check user doesn't set default to yes when entering a duplicate system name*/

PROCEDURE check_duplicate_system_name (p_business_group_id in number,
                                       p_system_name       in varchar2,
                                       p_default_flag      in varchar2,
                                       p_rowid             in varchar2);
-------------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Person_Type_Id               IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Active_Flag                         VARCHAR2,
                     X_Default_Flag                        VARCHAR2,
		     X_System_Person_Type                  VARCHAR2,
		     X_System_Name                         VARCHAR2,
                     X_User_Person_Type                    VARCHAR2);

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Person_Type_Id                        NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Active_Flag                           VARCHAR2,
                   X_Default_Flag                          VARCHAR2,
                   X_System_Person_Type                    VARCHAR2,
                   X_User_Person_Type                      VARCHAR2);

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Person_Type_Id                      NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Active_Flag                         VARCHAR2,
                     X_Default_Flag                        VARCHAR2,
		     X_System_Person_Type                  VARCHAR2,
		     X_System_Name                         VARCHAR2,
                     X_User_Person_Type                    VARCHAR2);

PROCEDURE Delete_Row(X_Rowid          VARCHAR2,
		     X_Default_flag   varchar2,
		     X_Person_type_Id number);

PROCEDURE Check_Delete (X_Business_Group_Id  NUMBER);

PROCEDURE Check_Default (X_Business_Group_Id IN NUMBER);

PROCEDURE Check_System_Delete(X_Person_Type_Id in NUMBER);

PROCEDURE LOAD_ROW
  (X_PERSON_TYPE         in VARCHAR2
  ,X_BUSINESS_GROUP_NAME in VARCHAR2
  ,X_ACTIVE_FLAG         in VARCHAR2
  ,X_DEFAULT_FLAG        in VARCHAR2
  ,X_SYSTEM_PERSON_TYPE  in VARCHAR2
  ,X_USER_PERSON_TYPE    in VARCHAR2
  ,X_OWNER               in VARCHAR2
  );

PROCEDURE TRANSLATE_ROW
  (X_PERSON_TYPE         in VARCHAR2
  ,X_BUSINESS_GROUP_NAME in VARCHAR2
  ,X_USER_PERSON_TYPE    in VARCHAR2
  ,X_OWNER               in VARCHAR2
  );

PROCEDURE ADD_LANGUAGE;

--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure validate_TRANSLATION (person_type_id IN    number,
				language IN             varchar2,
                                user_person_type IN  varchar2,
				p_business_group_id IN NUMBER DEFAULT NULL);
--------------------------------------------------------------------------------
END PER_PERSON_TYPES_PKG;

 

/
