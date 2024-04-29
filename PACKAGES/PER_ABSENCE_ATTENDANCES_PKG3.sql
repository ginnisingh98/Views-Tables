--------------------------------------------------------
--  DDL for Package PER_ABSENCE_ATTENDANCES_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABSENCE_ATTENDANCES_PKG3" AUTHID CURRENT_USER as
/* $Header: peaba03t.pkh 115.7 2004/04/05 03:16:21 kjagadee ship $ */

/*
  MODIFIED       (DD-MON-YYYY)

  btailor  110.0  28-JUN-1995   Created.
  ctredwin 110.1  01-OCT_1999   Added insert_abs_for_bee
  dcasemor 115.2  20-NOV-2001   Added commit statement.
  dcasemor 115.3  21-DEC-2001   Added dbdrv line.
  dcasemor 115.4  14-AUG-2002   GSCC compliance - added WHENEVER OSERROR...
  kjagadee 115.6  23-FEB-2004   Added overloaded proc for
                                insert_abs_for_bee
  kjagadee 115.7  05-APR-2004   Bug 3506133, Modified procedure
                                insert_abs_for_bee(one which is called from BEE)
*/

TYPE t_message_table IS TABLE OF VARCHAR2(30)
INDEX BY BINARY_INTEGER;

PROCEDURE insert_abs_for_paymix(p_session_date          in     date,
                                 p_absence_att_type_id  in     number,
                                 p_assignment_id        in     number,
                                 p_absence_days         in     number,
                                 p_absence_hours        in     number,
                                 p_date_start           in     date,
                                 p_date_end             in     date);
--
PROCEDURE insert_abs_for_bee(p_session_date          in     date,
                             p_absence_att_type_id   in     number,
                             p_assignment_id         in     number,
                             p_batch_id              in     number,
                             p_absence_days          in     number,
                             p_absence_hours         in     number,
                             p_date_start            in     date,
                             p_date_end              in     date,
                             p_absence_attendance_id out nocopy    number,
                             p_warning_table         out nocopy    t_message_table,
                             p_error_table           out nocopy    t_message_table);
--
-- Overloaded procedure
procedure insert_abs_for_bee(
   p_absence_att_type_id   in         number,
   p_batch_id              in         number,
   p_asg_act_id            in         number,
   p_entry_values_count    in         number,
   p_hours_or_days         in         varchar2,
   p_format                in         varchar2,
   p_value                 in         varchar2,
   p_date_start            in         date,
   p_date_end              in         date,
   p_line_record           in         pay_batch_lines%Rowtype,
   p_passed_inp_tbl        in         hr_entry.number_table,
   p_passed_val_tbl        in         hr_entry.varchar2_table,
   p_absence_attendance_id out nocopy number,
   p_warning_table         out nocopy t_message_table,
   p_error_table           out nocopy t_message_table);
--
END PER_ABSENCE_ATTENDANCES_PKG3;

 

/
