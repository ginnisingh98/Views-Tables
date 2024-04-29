--------------------------------------------------------
--  DDL for Package PER_LETTER_REQUEST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_LETTER_REQUEST_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: peltl01t.pkh 115.3 2003/02/21 07:11:09 vramanai ship $ */
--
PROCEDURE check_request_line_unique(X_letter_request_line_id in number,
				    X_assignment_id          in number,
				    X_letter_request_id      in number,
				    X_business_group_id      in number,
                                    X_OTA_EVENT_ID                         number,
                                    X_OTA_BOOKING_ID                       number,
                                    X_OTA_BOOKING_STATUS_TYPE_ID           number);
--
PROCEDURE get_ota_details
          (p_letter_request_line_id in number
          ,p_event_title            in out NOCOPY varchar2
          ,p_delegate_full_name     in out NOCOPY varchar2
          ,p_course_start_date      in out NOCOPY date
          ,p_ota_booking_id         in number
          ,p_ota_event_id           in number);
--
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Letter_Request_Line_Id        IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Letter_Request_Id                    NUMBER,
                     X_Person_Id                            NUMBER,
                     X_Assignment_Id                        NUMBER,
                     X_Assignment_Status_Type_Id            NUMBER,
                     X_Date_From                            DATE,
                     X_OTA_BOOKING_STATUS_TYPE_ID           number,
                     X_OTA_BOOKING_ID                       number,
                     X_OTA_EVENT_ID                         number,
		     X_CONTRACT_ID                    IN    NUMBER DEFAULT NULL
                     );
--
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Letter_Request_Line_Id                 NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Letter_Request_Id                      NUMBER,
                   X_Person_Id                              NUMBER,
                   X_Assignment_Id                          NUMBER,
                   X_Assignment_Status_Type_Id              NUMBER,
                   X_Date_From                              DATE,
                     X_OTA_BOOKING_STATUS_TYPE_ID           number,
                     X_OTA_BOOKING_ID                       number,
                     X_OTA_EVENT_ID                         number
                   );
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
END PER_LETTER_REQUEST_LINES_PKG;

 

/
