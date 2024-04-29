--------------------------------------------------------
--  DDL for Package IGS_AD_EMP_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_EMP_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI33S.pls 115.14 2003/11/11 07:17:35 gmaheswa ship $ */
/* Changed History
   Who        When         What
   Bug : 2037512
   avenkatr   08-OCT-2001  1. Added the column 'Contact' to Insert_row
                 and update_row procedures
   gmaheswa   05-Nov-2003   Added three new columns object_version_number,employed_by_party_id,reason_for_leaving for
                            HZ.K Impact Changes.
*/
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_employment_history_id  OUT NOCOPY NUMBER,
      x_PERSON_ID IN NUMBER,
      x_START_DT IN DATE,
      x_END_DT IN DATE,
      x_TYPE_OF_EMPLOYMENT IN VARCHAR2,
      x_FRACTION_OF_EMPLOYMENT IN NUMBER,
      x_TENURE_OF_EMPLOYMENT IN VARCHAR2,
      x_POSITION IN VARCHAR2,
      x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
      x_OCCUPATIONAL_TITLE IN VARCHAR2,
      x_WEEKLY_WORK_HOURS IN NUMBER,
      x_COMMENTS IN VARCHAR2,
      x_EMPLOYER IN VARCHAR2,
      x_EMPLOYED_BY_DIVISION_NAME IN VARCHAR2,
      x_BRANCH IN VARCHAR2,
      x_MILITARY_RANK IN VARCHAR2,
      x_SERVED IN VARCHAR2,
      x_STATION IN VARCHAR2,
      x_CONTACT IN VARCHAR2,       -- Bug : 2037512
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2,
      x_object_version_number IN OUT NOCOPY NUMBER,
      x_employed_by_party_id IN NUMBER,
      x_reason_for_leaving IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure UPDATE_ROW (
  X_ROWID in  VARCHAR2,
  x_employment_history_id IN NUMBER,
  x_PERSON_ID IN NUMBER,
  x_START_DT IN DATE,
  x_END_DT IN DATE,
  x_TYPE_OF_EMPLOYMENT IN VARCHAR2,
  x_FRACTION_OF_EMPLOYMENT IN NUMBER,
  x_TENURE_OF_EMPLOYMENT IN VARCHAR2,
  x_POSITION IN VARCHAR2,
  x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
  x_OCCUPATIONAL_TITLE IN VARCHAR2,
  x_WEEKLY_WORK_HOURS IN NUMBER,
  x_COMMENTS IN VARCHAR2,
  x_EMPLOYER IN VARCHAR2,
  x_EMPLOYED_BY_DIVISION_NAME IN VARCHAR2,
  x_BRANCH IN VARCHAR2,
  x_MILITARY_RANK IN VARCHAR2,
  x_SERVED IN VARCHAR2,
  x_STATION IN VARCHAR2,
  x_CONTACT IN VARCHAR2,      -- Bug : 2037512
  x_msg_data OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_object_version_number IN OUT NOCOPY NUMBER,
  x_employed_by_party_id IN NUMBER,
  x_reason_for_leaving IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;

END igs_ad_emp_dtl_pkg;

 

/
