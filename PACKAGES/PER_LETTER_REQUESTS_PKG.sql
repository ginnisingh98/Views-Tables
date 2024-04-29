--------------------------------------------------------
--  DDL for Package PER_LETTER_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_LETTER_REQUESTS_PKG" AUTHID CURRENT_USER as
/* $Header: peltr01t.pkh 115.1 2003/01/15 09:59:44 pkakar ship $ */
--
PROCEDURE check_request_unique(X_letter_request_id   in number,
			       X_business_group_id   in number,
			       X_vacancy_id          in number,
                               X_event_id   	     in number,
			       X_letter_type_id      in number,
			       X_date_from           in date,
			       X_request_status      in varchar2);
--
PROCEDURE check_request_lines(X_letter_request_id    in     NUMBER);
--
PROCEDURE confirm_delete_lines(X_letter_request_id    in     NUMBER,
			       X_business_group_id    in     NUMBER,
			       X_request_lines_exist  in out nocopy BOOLEAN);
--
PROCEDURE Insert_Row(X_Rowid                         IN OUT nocopy VARCHAR2,
                     X_Letter_Request_Id             IN OUT nocopy NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Letter_Type_Id                       NUMBER,
                     X_Date_From                            DATE,
                     X_Request_Status                       VARCHAR2,
                     X_Auto_Or_Manual                       VARCHAR2,
		     x_vacancy_id                           NUMBER,
                     x_event_id                             NUMBER
                     );
--
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Letter_Request_Id                      NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Letter_Type_Id                         NUMBER,
                   X_Date_From                              DATE,
                   X_Request_Status                         VARCHAR2,
                   X_Auto_Or_Manual                         VARCHAR2,
                   x_vacancy_id                           NUMBER,
                   x_event_id                             NUMBER
                   );
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Letter_Request_Id                   NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Letter_Type_Id                      NUMBER,
                     X_Date_From                           DATE,
                     X_Request_Status                      VARCHAR2,
                     X_Auto_Or_Manual                      VARCHAR2,
                     x_vacancy_id                           NUMBER,
                     x_event_id                             NUMBER
                     );
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2,
		     X_Letter_Request_Id NUMBER);
--
PROCEDURE concurrent_program_call(p_application       varchar2,
				  p_program           varchar2,
				  p_argument1         varchar2,
				  p_argument2         varchar2,
				  p_request_id in out nocopy  number);
END PER_LETTER_REQUESTS_PKG;

 

/
