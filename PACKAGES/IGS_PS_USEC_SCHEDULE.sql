--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_SCHEDULE" AUTHID CURRENT_USER AS
/* $Header: IGSPS77S.pls 120.1 2005/06/29 05:23:50 appldev ship $ */
/* Change History
   Who	         When 	    What
   jbegum       12-Apr-2003	    Enh bug #2833850.
                                Added a new parameter p_c_del_flag to the procedure Prgp_Init_Prs_sched
                                Added a new public function get_enrollment_max
   (reverse chronological order - newest change first)
*/

PROCEDURE Prgp_Init_Prs_sched(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_teach_prd IN VARCHAR2,
  p_uoo_id IN NUMBER,
  p_usec_id IN NUMBER,
  p_sch_type IN VARCHAR2,
  p_org_id IN NUMBER);

  -- Hooker Procedure
 PROCEDURE prgp_init_scheduling;

-- Scheduled Status Function
 FUNCTION prgp_get_schd_status (
 p_uoo_id IN NUMBER,
 p_usec_id IN NUMBER DEFAULT NULL,
 p_message_name OUT NOCOPY VARCHAR2)
 RETURN BOOLEAN ;

--Purge Data Procedure
 PROCEDURE prgp_schd_purge_data(
 errbuf  OUT NOCOPY  VARCHAR2,
 retcode OUT NOCOPY  NUMBER,
 p_teach_prd IN VARCHAR2,
 p_org_id IN NUMBER );

 -- Unit Section Changes Update
 FUNCTION prgp_upd_usec_dtls (
  p_uoo_id IN NUMBER,
  p_location_cd IN VARCHAR2 DEFAULT NULL,
  p_usec_status IN VARCHAR2 DEFAULT NULL,
  p_max_enrollments IN NUMBER DEFAULT NULL,
  p_override_enrollment_max IN NUMBER DEFAULT NULL,
  p_enrollment_expected     IN NUMBER DEFAULT NULL,
  p_request_id OUT NOCOPY NUMBER,
  p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  -- Get Scheduled Records

  PROCEDURE prgp_get_schd_records(
  errbuf  OUT NOCOPY  varchar2,
  retcode OUT NOCOPY  number,
  p_org_id IN NUMBER
  );

 -- Export data to Flat files

PROCEDURE PRGP_WRITE_REF_FILE (
errbuf  OUT NOCOPY  VARCHAR2,
retcode OUT NOCOPY  NUMBER,
p_column_sep IN VARCHAR2,
p_org_id IN NUMBER);

--Aborts the scheduling
PROCEDURE abort_sched(
errbuf  out NOCOPY  varchar2,
retcode out NOCOPY  number,
p_teach_calendar  IN VARCHAR2 ,
p_unit_cd  IN VARCHAR2 ,
p_version_number  IN NUMBER,
p_location IN VARCHAR2,
p_unit_class IN VARCHAR2,
p_cancel_only IN VARCHAR2)
;


-- Function to return maximum enrollment for a unit section
FUNCTION get_enrollment_max(
p_n_uoo_id IN NUMBER)
RETURN NUMBER;

PROCEDURE update_occurrence_status(
p_unit_section_occurrence_id IN NUMBER,
p_scheduled_status IN VARCHAR2,
p_cancel_flag IN VARCHAR2
);

END igs_ps_usec_schedule;

 

/
