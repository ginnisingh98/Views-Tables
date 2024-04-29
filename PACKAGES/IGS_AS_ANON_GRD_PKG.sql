--------------------------------------------------------
--  DDL for Package IGS_AS_ANON_GRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ANON_GRD_PKG" AUTHID CURRENT_USER as
 /* $Header: IGSAS39S.pls 120.0 2005/07/05 12:18:02 appldev noship $ */

/*
  ||  Created By : pkpatel
  ||  Created On : 28-JAN-2002
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
FUNCTION  chk_anon_graded (
              p_uoo_id    IN   igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
			  p_ass_id    IN   igs_as_assessmnt_itm_all.ass_id%TYPE
    ) RETURN VARCHAR2;

PROCEDURE  mnt_anon_id (
     errbuf                OUT NOCOPY	  VARCHAR2,  -- Standard Error Buffer Variable
     retcode               OUT NOCOPY	  NUMBER,    -- Standard Concurrent Return code
     p_load_calendar       IN     VARCHAR2,  -- Award Year ( Concatenated value of Calandar Type and Sequence Number )
     p_min_number          IN     NUMBER,    -- Minimum Number for the Range of Anonymous ID
     p_max_number          IN     NUMBER,    -- Maximum Number for the Range of Anonymous ID
     p_reallocate_anon_id  IN     VARCHAR2   -- Y/N value to choose whether to reallocate Anonymous ID OR assign the existing ones.
);

FUNCTION   get_anon_id (
     p_person_id           IN    hz_parties.party_id%TYPE,              -- Person ID
     p_course_cd           IN    igs_en_su_attempt_all.course_cd%TYPE,  -- Course Code
     p_unit_cd             IN    igs_en_su_attempt_all.unit_cd%TYPE,    -- Unit Code
     p_teach_cal_type      IN    igs_ca_inst_all.cal_type%TYPE,         -- Teach calander Type
     p_teach_ci_sequence_number  IN  igs_ca_inst_all.sequence_number%TYPE, -- Teach Sequence Number
     p_uoo_id              IN    igs_ps_unit_ofr_opt_all.uoo_id%TYPE,   -- Unit Ofering Option ID
     p_ass_id              IN    igs_as_assessmnt_itm_all.ass_id%TYPE,      -- Assessment ID
     p_unit_grading_ind    IN    VARCHAR2                               -- Unit Grading Indicator
)RETURN VARCHAR2;


FUNCTION   get_person_id (
     p_anonymous_id        IN    igs_as_anon_id_ps.anonymous_id%TYPE,  -- Anonymous ID
     p_teach_cal_type      IN    igs_ca_inst_all.cal_type%TYPE,        -- Teach calander Type
     p_teach_ci_sequence_number  IN  igs_ca_inst_all.sequence_number%TYPE -- Teach Sequence Number
) RETURN NUMBER;


FUNCTION   user_anon_id (
     p_anonymous_number      varchar2,
     p_method                igs_as_anon_method.METHOD%TYPE,
     p_person_id             hz_parties.party_id%TYPE,
     p_course_cd             igs_en_su_attempt_all.course_cd%TYPE,
     p_unit_cd               igs_en_su_attempt_all.unit_cd%TYPE,
     p_teach_cal_type        igs_ca_inst_all.cal_type%TYPE,
     p_teach_ci_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
     p_uoo_id                igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
     p_assessment_type       igs_as_assessmnt_typ.assessment_type%TYPE,
     p_load_cal_type         igs_ca_inst_all.cal_type%TYPE,
     p_load_ci_sequence_number  igs_ca_inst_all.sequence_number%TYPE
) RETURN VARCHAR2;

END igs_as_anon_grd_pkg;

 

/
