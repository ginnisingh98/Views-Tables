--------------------------------------------------------
--  DDL for Package IGS_EN_FUTURE_DT_TRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_FUTURE_DT_TRANS" AUTHID CURRENT_USER AS
/* $Header: IGSEN83S.pls 120.2 2005/09/02 04:55:12 appldev noship $ */

PROCEDURE cleanup_dest_program(
                               p_person_id	          IN		IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                               p_dest_course_cd		    IN	  IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                               p_term_cal_type        IN		IGS_CA_INST.cal_type%TYPE,
                               p_term_sequence_number	IN    IGS_CA_INST.sequence_number%TYPE,
                               p_mode			            IN    VARCHAR2
                               );



PROCEDURE process_fut_dt_trans(
                             errbuf	            OUT NOCOPY	VARCHAR2,
                             retcode            OUT NOCOPY NUMBER,
                             p_term_cal_comb    IN	VARCHAR2,
                             p_mode		          IN VARCHAR2,
                             p_ignore_warnings  IN	VARCHAR2,
                             p_drop_enrolled	  IN VARCHAR2
                             );
FUNCTION del_sua_for_reopen(
  p_person_id  IN   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IN  IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
  p_uoo_id      IN  IGS_EN_SU_ATTEMPT.uoo_id%TYPE
 )
RETURN BOOLEAN ;

END IGS_EN_FUTURE_DT_TRANS;

 

/
