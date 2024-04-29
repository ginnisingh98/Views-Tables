--------------------------------------------------------
--  DDL for Package Body SSPWSMED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSPWSMED_PKG" as
 /* $Header: sspwsmed.pkb 115.2 99/07/16 23:04:08 porting ship $ */
 /*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************


    Name        : sspwsmed_pkg

    Description : This package is the server side agent for
		  SSP/SMP R10 form sspwsmed

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    22-AUG-1995 ssethi      40.0               Initial Creation
    13-SEP-1995 ssethi                         Procedures added to
					       update evidence_status to
					       SUPERCEDED from CURRENT.

  */

  PROCEDURE get_medical_sequence (p_medical_id in out number) is
    cursor c1 is
      select ssp_medicals_s.nextval
      from sys.dual;
  BEGIN
    open c1;
    fetch c1 into p_medical_id;
    close c1;
  END get_medical_sequence;

  PROCEDURE check_unique_mat_evidence
  	   (p_evidence_source in varchar2,
  	    p_evidence_date   in date,
  	    p_maternity_id    in number,
	    p_medical_id      in number) is
    cursor c1 is
      select h.rowid
      from   ssp_medicals h
      where  h.maternity_id = p_maternity_id
	and  h.medical_id <> p_medical_id
	and  upper(h.evidence_source) = p_evidence_source
	and  h.evidence_date = p_evidence_date;
    c1_rec c1%ROWTYPE;
  BEGIN
     open c1;
     fetch c1 into c1_rec;
     if c1%FOUND then
          fnd_message.set_name ('SSP','SSP_35020_NON_UNQ_MED_EVID');
          fnd_message.raise_error;
          app_exception.raise_exception;
     end if;
     close c1;
  END  check_unique_mat_evidence;


  PROCEDURE check_unique_abs_evidence
	    (p_evidence_source in varchar2,
	     p_evidence_date   in date,
	     p_absence_attendance_id in number,
	     p_medical_id      in number) is
    cursor c1 is
      select h.evidence_source, h.evidence_date
      from   ssp_medicals h
      where  h.absence_attendance_id = p_absence_attendance_id
	and  h.medical_id <> p_medical_id
	and  upper(h.evidence_source) = p_evidence_source
        and  h.evidence_date = p_evidence_date;
    c1_rec c1%ROWTYPE;
  BEGIN
    open c1;
    fetch c1 into c1_rec;
    if c1%FOUND then
         fnd_message.set_name ('SSP', 'SSP_35020_NON_UNQ_MED_EVID');
         fnd_message.raise_error;
         app_exception.raise_exception;
    end if;
    close c1;
  END check_unique_abs_evidence;

 PROCEDURE upd_prev_sick_evid (p_absence_attendance_id in number) is
 BEGIN
   update ssp_medicals
   set evidence_status='SUPERCEDED'
   where absence_attendance_id = p_absence_attendance_id
     and evidence_status = 'CURRENT';
 END upd_prev_sick_evid;

 PROCEDURE upd_prev_mat_evid (p_maternity_id in number) is
 BEGIN
    update ssp_medicals
    set evidence_status='SUPERCEDED'
    where maternity_id = p_maternity_id
      and evidence_status = 'CURRENT';
 END upd_prev_mat_evid;

END SSPWSMED_PKG;

/
