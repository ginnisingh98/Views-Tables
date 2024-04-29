--------------------------------------------------------
--  DDL for Package HR_ABSUTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ABSUTIL_SS" AUTHID CURRENT_USER AS
/* $Header: hrabsutlss.pkh 120.3.12010000.2 2009/10/14 09:43:08 ckondapi ship $ */
-- Package Variables
--
function getStartDate(p_transaction_id in number,
                       p_absence_attendance_id in number) return date;

function getEndDate(p_transaction_id in number,
                       p_absence_attendance_id in number) return date;

function getAbsenceType(p_transaction_id in number,
                            p_absence_attendance_id in number) return varchar2;

function getAbsenceCategory(p_transaction_id in number,
                            p_absence_attendance_id in number) return varchar2;

function getAbsenceHoursDuration(p_transaction_id in number,
                            p_absence_attendance_id in number) return number;

function getAbsenceDaysDuration(p_transaction_id in number,
                            p_absence_attendance_id in number) return number;

function getApprovalStatus(p_transaction_id in number,
                            p_absence_attendance_id in number) return varchar2;

function getAbsenceStatus(p_transaction_id in number,
                            p_absence_attendance_id in number) return varchar2;

function isUpdateAllowed(p_transaction_id in number,
                         p_absence_attendance_id in number,
                         p_transaction_status in varchar2) return varchar2;

function isConfirmAllowed(p_transaction_id in number,
                          p_absence_attendance_id in number) return varchar2;

function isCancelAllowed(p_transaction_id in number,
                            p_absence_attendance_id in number,
                         p_transaction_status in varchar2) return varchar2;

function hasSupportingDocuments(p_transaction_id in number,
                            p_absence_attendance_id in number) return varchar2;

procedure getAbsenceNotificationDetails(p_transaction_id in number
                                       ,p_notification_subject out nocopy varchar2);

function getApprovalStatusCode(p_transaction_id in number,
                           p_absence_attendance_id in number) return varchar2;

function getAbsDurHours(
  p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2)
  return number;

function getAbsDurDays(
  p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2)
 return number;

function getAbsenceStatusValue(p_transaction_id in Varchar2) return varchar2;

procedure delete_transaction
(p_transaction_id in	   number);

procedure remove_absence_transaction(p_absence_attendance_id in number);

END HR_ABSUTIL_SS;

/
