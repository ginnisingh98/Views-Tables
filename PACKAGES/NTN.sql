--------------------------------------------------------
--  DDL for Package NTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."NTN" AUTHID CURRENT_USER as
/* $Header: PONSENDS.pls 115.2 2002/11/25 19:50:56 sbull ship $ */

type char_array is table of varchar2(300) index by binary_integer;


procedure Send_Notification(
   p_employee_id number,
   p_message_name varchar2,
   object_id number,
   priority number default 3,
   deletable     varchar2 default 'Y',
   from_id       number default NULL,
   p_application_id number default 0,
   doc_type        varchar2 default NULL,
   doc_number        varchar2 default NULL,
   amount          number default NULL,
   currency        varchar2 default NULL,
   note            varchar2 default NULL,
   start_effective_date date default NULL,
   end_effective_date date default NULL,
   doc_creation_date date default NULL,
   date1  date default NULL,
   date2  date default NULL,
   date3  date default NULL,
   attribute_array char_array,
   array_lb number,
   array_ub number,
   return_code out NOCOPY number,
   notification_id      out NOCOPY number);


procedure Delete_Notification(
   p_notification_id number,
   return_code out NOCOPY number);

/*
procedure  Get_Notification_Attribute(
   p_notification_id number,
   attribute_name varchar2,
   attribute_value out NOCOPY varchar2);
*/


procedure Delete_Notif_By_ID_Type(
   p_object_id number,
   p_doc_type  varchar2);

procedure Forward_Notification(
   p_notification_id number,
   p_new_recip       number,
   p_note	     varchar2 default NULL);


/*===========================================================================

  PROCEDURE NAME:	notif_current

===========================================================================*/

FUNCTION notif_current (x_notification_id NUMBER) RETURN BOOLEAN;

procedure test_in(i number);

end ntn;

 

/
