--------------------------------------------------------
--  DDL for Package Body IGS_PR_CP_GPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_CP_GPA" AS
/* $Header: IGSPR32B.pls 120.11 2006/07/07 05:28:26 swaghmar ship $ */

/*
  Created By : prchandr,Nishikanth,Rajesh
  Created On : 24-NOV-2001
  Purpose :
  Known limitations, enhancements or remarks :
  Change History :
  Who      When        What

  nalkumar 22-Apr-2004 Modified get_cp_stats, get_gpa_stats, get_sua_gpa, get_sua_cp and get_sua_all
                       procedures and added p_use_released_grade parameter.
                       This is to fix Bug# 3547126
  ddey     27-Oct-2003 Changes are done, so that the message stack is not initilized.(Bug # 3163305)
  smanglm  06-Oct-2003 bug 3161343
                       Consider all Outcomes for the Attempted Credit Points
           including WITHDRAWN in get_sua_stats
  smanglm  10-Jul-2003 changed get_all_stats for If no value is found for
                       STORED stats the function should then return null
  jhanda   28-May-2003 Changed gpa , gpa_quality points , gpa_credit_points
                       procedure parameter types.
  anilk    27-Dec-2002 Removed prefixed apps in the fnd calls. Bug# 2413841
                       ex: apps.fnd_message.setname --> fnd_message.setname
  prraj    18-Feb-2002 Removed parameter p_uc_achievable_credit_points from
                       the parameter list of procedures get_cp and get_gpa.
                       Also removed the functionality to obtain the achievable
                       credit points from the unit section level (Bug# 2224366)
  kdande   20-Sep-2002 Removed the references to columns progression_ind and
                       fin_aid_ind from the c_org_stat cursor and c_inst_stat
                       cursor for Bug# 2560160 in get_stat_dtls and
                       get_unitstat_dtls procedures.
                       Removed all the default values from the program
                       units' parameters and replaced DEFAULT with := in the
                       declaration sections of the program units.
  prchandr 16-JUL-2002 Bug No. 2463175  Removed package and package body
                       mismatch by adding default FND_API.G_TRUE FOR get_sua_cp
  nalkumar 05-Dec-2002 Modified get_stat_dtls procedure as per the Bug# 2685741
  jhanda   19-Dec-2002 Bug Fix 2707516 wrong GPA being calculated, changes
                       specified in Bug Description in Bug DB.
  kdande   26-Jul-2004 Changed the of get_sua_stats to return proper value for
                       attempted_cp instead of NULL in those cases where the
                       Student's Unit Attempt Outcome is not available.
  jhanda   25-feb-2005     Bug 3843525 Added parameter p_enrolled_cp to GET_SUA_STATS
  swaghmar 06-Jun-2005 Bug 4327987 Added chk_sua_ref_cd function
  (reverse chronological order - newest change first)
  jhanda   20-June-05   Build 4327991 -- check reference codes for adv standing units
  swaghmar 15-Sep-05	Bug 4491456 - Modified the signature
*/
--
-- Forward Declaration of Local procedures
--
  PROCEDURE get_stat_dtls(
    p_person_id         IN            igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd         IN            igs_en_stdnt_ps_att.course_cd%TYPE,
    p_system_stat       IN            VARCHAR2,
    p_cumulative_ind    IN            VARCHAR2,
    p_stat_type         IN OUT NOCOPY igs_pr_stat_type.stat_type%TYPE,
    p_org_unit_cd       OUT NOCOPY    igs_pr_org_stat.org_unit_cd%TYPE,
    p_include_std_ind   OUT NOCOPY    igs_pr_org_stat.include_standard_ind%TYPE,
    p_include_local_ind OUT NOCOPY    igs_pr_org_stat.include_local_ind%TYPE,
    p_include_other_ind OUT NOCOPY    igs_pr_org_stat.include_other_ind%TYPE,
    p_derivation        OUT NOCOPY    igs_pr_stat_type.derivation%TYPE,
    p_init_msg_list     IN            VARCHAR2,
    p_return_status     OUT NOCOPY    VARCHAR2,
    p_msg_count         OUT NOCOPY    NUMBER,
    p_msg_data          OUT NOCOPY    VARCHAR2);

  FUNCTION chk_unit_ref_cd(
    p_unit_cd             IN            igs_ps_unit_ver.unit_cd%TYPE,
    p_unit_version_number IN            igs_ps_unit_ver.version_number%TYPE,
    p_org_unit_cd         IN            igs_pr_org_stat.org_unit_cd%TYPE,
    p_stat_type           IN            igs_pr_stat_type.stat_type%TYPE,
    p_init_msg_list       IN            VARCHAR2,
    p_return_status       OUT NOCOPY    VARCHAR2,
    p_msg_count           OUT NOCOPY    NUMBER,
    p_msg_data            OUT NOCOPY    VARCHAR2)
    RETURN VARCHAR2;

    FUNCTION chk_sua_ref_cd(
    P_person_id IN igs_en_su_attempt_ALL.person_id%TYPE,
    P_course_cd IN igs_en_su_attempt_ALL.course_cd%TYPE,
    P_uoo_id IN  NUMBER,
    p_org_unit_cd         IN            igs_pr_org_stat.org_unit_cd%TYPE,
    p_stat_type           IN            igs_pr_stat_type.stat_type%TYPE,
    p_init_msg_list       IN            VARCHAR2,
    p_return_status       OUT NOCOPY    VARCHAR2,
    p_msg_count           OUT NOCOPY    NUMBER,
    p_msg_data            OUT NOCOPY    VARCHAR2)
    RETURN VARCHAR2 ;
  --
  -- swaghmar; 15-Sep-2005; Bug 4491456
  --	Modified the signature

  PROCEDURE get_adv_stats(
    p_person_id               IN            igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd               IN            igs_en_stdnt_ps_att.course_cd%TYPE,
    p_stat_type               IN            igs_pr_stat_type.stat_type%TYPE,
    p_org_unit_cd             IN            igs_pr_org_stat.org_unit_cd%TYPE,
    p_load_cal_type           IN            igs_ca_inst.cal_type%TYPE,
    p_load_ci_sequence_number IN            igs_ca_inst.sequence_number%TYPE,
    p_cumulative_ind          IN            VARCHAR2,
    p_include_local_ind       IN            VARCHAR2,
    p_include_other_ind       IN            VARCHAR2,
    p_earned_cp     OUT NOCOPY    NUMBER,
    p_attempted_cp  OUT NOCOPY    NUMBER,
    p_gpa_cp                  OUT NOCOPY    NUMBER,
    p_gpa_quality_points      OUT NOCOPY    NUMBER,
    p_init_msg_list           IN            VARCHAR2,
    p_return_status           OUT NOCOPY    VARCHAR2,
    p_msg_count               OUT NOCOPY    NUMBER,
    p_msg_data                OUT NOCOPY    VARCHAR2);

  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the local PROCEDURE get_sua_stats
  -- swaghmar; 15-Sep-2005; Bug 4491456
  --	Modified the signature
  --
  PROCEDURE get_sua_stats(
    p_person_id                IN         igs_en_su_attempt_ALL.person_id%TYPE,
    p_course_cd                IN         igs_en_su_attempt_ALL.course_cd%TYPE,
    p_unit_cd                  IN         igs_en_su_attempt_ALL.unit_cd%TYPE,
    p_unit_version_number      IN         igs_en_su_attempt_ALL.version_number%TYPE,
    p_teach_cal_type           IN         igs_en_su_attempt_ALL.cal_type%TYPE,
    p_teach_ci_sequence_number IN         igs_en_su_attempt_ALL.ci_sequence_number%TYPE,
    p_earned_cp                OUT NOCOPY NUMBER,
    p_attempted_cp             OUT NOCOPY NUMBER,
    p_gpa_value                OUT NOCOPY NUMBER,
    p_gpa_cp                   OUT NOCOPY NUMBER,
    p_gpa_quality_points       OUT NOCOPY NUMBER,
    p_init_msg_list            IN         VARCHAR2,
    p_return_status            OUT NOCOPY VARCHAR2,
    p_msg_count                OUT NOCOPY NUMBER,
    p_msg_data                 OUT NOCOPY VARCHAR2,
    p_uoo_id                   IN         NUMBER,
    p_use_released_grade       IN         VARCHAR2,
    p_enrolled_cp	       OUT NOCOPY igs_pr_stu_acad_stat.gpa_quality_points%TYPE);


   FUNCTION chk_av_unit_ref_cd (
      p_av_stnd_unit_id   IN              igs_av_stnd_unit_all.av_stnd_unit_id%TYPE,
      p_org_unit_cd       IN              igs_pr_org_stat.org_unit_cd%TYPE,
      p_stat_type         IN              igs_pr_stat_type.stat_type%TYPE,
      p_init_msg_list     IN              VARCHAR2,
      p_return_status     OUT NOCOPY      VARCHAR2,
      p_msg_count         OUT NOCOPY      NUMBER,
      p_msg_data          OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2
   AS

--------------------------------------------------------------------------
--  Created By : Jitendra
--  Date Created On : 06-04-2005
--  Purpose: To check whether a unit is Excluded or Included by a reference code
--           for advanced standing
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
--  (reverse chronological order - newest change first)
--------------------------------------------------------------------------

      CURSOR c_org_setup
      IS
         SELECT ostr1.include_or_exclude
           FROM igs_pr_org_stat_ref ostr1
          WHERE ostr1.stat_type = p_stat_type
            AND ostr1.org_unit_cd = p_org_unit_cd;

      CURSOR c_org_included
      IS
         SELECT 'X'
           FROM igs_av_unt_ref_cds urc,
                igs_ge_ref_cd refcd,
                igs_ge_ref_cd_type rct
          WHERE urc.av_stnd_unit_id = p_av_stnd_unit_id
            AND urc.reference_code_id = refcd.reference_code_id
            AND refcd.reference_cd_type = rct.reference_cd_type
            AND rct.s_reference_cd_type = 'STATS'
	    AND urc.deleted_date IS NULL
            AND EXISTS ( SELECT 'X'
                           FROM igs_pr_org_stat_ref ostr1
                          WHERE ostr1.stat_type = p_stat_type
                            AND ostr1.org_unit_cd = p_org_unit_cd
                            AND ostr1.unit_ref_cd = refcd.reference_cd
                            AND ostr1.include_or_exclude = 'INCLUDE');

      CURSOR c_org_excluded
      IS
         SELECT 'X'
           FROM igs_av_unt_ref_cds urc,
                igs_ge_ref_cd refcd,
                igs_ge_ref_cd_type rct
          WHERE urc.av_stnd_unit_id = p_av_stnd_unit_id
            AND urc.reference_code_id = refcd.reference_code_id
            AND refcd.reference_cd_type = rct.reference_cd_type
            AND rct.s_reference_cd_type = 'STATS'
	    AND urc.deleted_date IS NULL
            AND EXISTS ( SELECT 'X'
                           FROM igs_pr_org_stat_ref ostr1
                          WHERE ostr1.stat_type = p_stat_type
                            AND ostr1.org_unit_cd = p_org_unit_cd
                            AND ostr1.unit_ref_cd = refcd.reference_cd
                            AND ostr1.include_or_exclude = 'EXCLUDE');

      CURSOR c_inst_setup
      IS
         SELECT INSTR.include_or_exclude
           FROM igs_pr_inst_sta_ref INSTR
          WHERE INSTR.stat_type = p_stat_type;

      CURSOR c_inst_included
      IS
         SELECT 'X'
           FROM igs_av_unt_ref_cds urc,
                igs_ge_ref_cd refcd,
                igs_ge_ref_cd_type rct
          WHERE urc.av_stnd_unit_id = p_av_stnd_unit_id
            AND urc.reference_code_id = refcd.reference_code_id
            AND refcd.reference_cd_type = rct.reference_cd_type
            AND rct.s_reference_cd_type = 'STATS'
	    AND urc.deleted_date IS NULL
            AND EXISTS ( SELECT 'X'
                           FROM igs_pr_inst_sta_ref instr1
                          WHERE instr1.stat_type = p_stat_type
                            AND instr1.unit_ref_cd = refcd.reference_cd
                            AND instr1.include_or_exclude = 'INCLUDE');

      CURSOR c_inst_excluded
      IS
         SELECT 'X'
           FROM igs_av_unt_ref_cds urc,
                igs_ge_ref_cd refcd,
                igs_ge_ref_cd_type rct
          WHERE urc.av_stnd_unit_id = p_av_stnd_unit_id
            AND urc.reference_code_id = refcd.reference_code_id
            AND refcd.reference_cd_type = rct.reference_cd_type
            AND rct.s_reference_cd_type = 'STATS'
	    AND urc.deleted_date IS NULL
            AND EXISTS ( SELECT 'X'
                           FROM igs_pr_inst_sta_ref instr1
                          WHERE instr1.stat_type = p_stat_type
                            AND instr1.unit_ref_cd = refcd.reference_cd
                            AND instr1.include_or_exclude = 'EXCLUDE');

      l_include_or_exclude   VARCHAR2 (20);
      l_include              VARCHAR2 (1);
      l_dummy                VARCHAR2 (1);
      l_message              VARCHAR2 (1000);
   BEGIN
      l_include := 'Y';
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (NVL (p_init_msg_list, fnd_api.g_true))
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- The following parameters should not be null
      IF (   p_av_stnd_unit_id IS NULL
          OR p_stat_type IS NULL
         )
      THEN
         l_message := 'IGS_GE_INSUFFICIENT_PARAM_VAL';
         fnd_message.set_name ('IGS', l_message);
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      -- If the Organizational Unit is not null then statistic type is
      -- defined at Organizational level.  Check if any unit reference
      -- codes are included or excluded at Org level.

      IF p_org_unit_cd IS NOT NULL
      THEN
         -- When no Unit Reference Codes are specifically included or excluded all
         -- units should be included.
         OPEN c_org_setup;
         FETCH c_org_setup INTO l_include_or_exclude;

         IF (c_org_setup%FOUND)
         THEN
            IF (l_include_or_exclude = 'INCLUDE')
            THEN
               -- When Unit Reference Codes are specifically included then only those
               -- units with the included Unit Refernce Code should be included
               OPEN c_org_included;
               FETCH c_org_included INTO l_dummy;

               IF (c_org_included%NOTFOUND)
               THEN
                  l_include := 'N';
               END IF;

               CLOSE c_org_included;
            ELSE
               -- When Unit Reference Codes are specifically excluded all units except
               -- those units with the excluded Unit Refernce Code should be included
               OPEN c_org_excluded;
               FETCH c_org_excluded INTO l_dummy;

               IF (c_org_excluded%FOUND)
               THEN
                  l_include := 'N';
               END IF;

               CLOSE c_org_excluded;
            END IF;
         END IF;

         CLOSE c_org_setup;
      -- If the Organizational Unit is null then statistic type must be
      -- defined at Institution level.  Check if any unit reference
      -- codes are included or excluded at Inst level.
      ELSE
         -- When no Unit Reference Codes are specifically included or excluded all
         -- units should be included.

         OPEN c_inst_setup;
         FETCH c_inst_setup INTO l_include_or_exclude;

         IF (c_inst_setup%FOUND)
         THEN
            IF (l_include_or_exclude = 'INCLUDE')
            THEN
               -- When Unit Reference Codes are specifically included then only those
               -- units with the included Unit Refernce Code should be included
               OPEN c_inst_included;
               FETCH c_inst_included INTO l_dummy;

               IF (c_inst_included%NOTFOUND)
               THEN
                  l_include := 'N';
               END IF;

               CLOSE c_inst_included;
            ELSE
               -- When Unit Reference Codes are specifically excluded all units except
               -- those units with the excluded Unit Refernce Code should be included
               OPEN c_inst_excluded;
               FETCH c_inst_excluded INTO l_dummy;

               IF (c_inst_excluded%FOUND)
               THEN
                  l_include := 'N';
               END IF;

               CLOSE c_inst_excluded;
            END IF;
         END IF;
         CLOSE c_inst_setup;
      END IF;

      -- Initialize API return status to success.
      p_return_status := fnd_api.g_ret_sts_success;
      -- Standard call to get message count and if count is 1, get message info
      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false,
         p_count=> p_msg_count,
         p_data=> p_msg_data
      );
      RETURN l_include;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         p_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false,
            p_count=> p_msg_count,
            p_data=> p_msg_data
         );
         RETURN NULL;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         p_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false,
            p_count=> p_msg_count,
            p_data=> p_msg_data
         );
         RETURN NULL;
      WHEN OTHERS
      THEN
         p_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
         fnd_message.set_token ('NAME',    'chk_av_unit_ref_cd: '
                                        || SQLERRM);
         fnd_msg_pub.ADD;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false,
            p_count=> p_msg_count,
            p_data=> p_msg_data
         );
         RETURN NULL;
   END chk_av_unit_ref_cd;




  PROCEDURE get_stat_dtls(
    p_person_id         IN            igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd         IN            igs_en_stdnt_ps_att.course_cd%TYPE,
    p_system_stat       IN            VARCHAR2,
    p_cumulative_ind    IN            VARCHAR2,
    p_stat_type         IN OUT NOCOPY igs_pr_stat_type.stat_type%TYPE,
    p_org_unit_cd       OUT NOCOPY    igs_pr_org_stat.org_unit_cd%TYPE,
    p_include_std_ind   OUT NOCOPY    igs_pr_org_stat.include_standard_ind%TYPE,
    p_include_local_ind OUT NOCOPY    igs_pr_org_stat.include_local_ind%TYPE,
    p_include_other_ind OUT NOCOPY    igs_pr_org_stat.include_other_ind%TYPE,
    p_derivation        OUT NOCOPY    igs_pr_stat_type.derivation%TYPE,
    p_init_msg_list     IN            VARCHAR2,
    p_return_status     OUT NOCOPY    VARCHAR2,
    p_msg_count         OUT NOCOPY    NUMBER,
    p_msg_data          OUT NOCOPY    VARCHAR2) IS
    /*
    ||Created By : Prajeesh Chandran
    ||Created On : 6-Nov-2001
    ||Purpose : Gets the Program and Statistics Details(Org or Institution)
    ||Known limitations, enhancements or remarks :
    ||Change History :
    ||Who      When        What
    ||(reverse chronological order - newest change first)
    ||ddey     27-Oct-2003 Changes are done, so that the message stack is not initilized.(Bug # 3163305)
    ||kdande   20-Sep-2002 Removed the references to columns progression_ind and
    ||                    fin_aid_ind from the c_org_stat cursor and c_inst_stat
    ||                     cursor for Bug# 560160. Defaulted the p_init_msg_list
    ||                     parameter in the code since default value is removed
    ||                     from the procedure signature
    */
    --
    -- Cursor to get the Details at the Organization Level
    --
    CURSOR c_org_stat IS
      SELECT orst.org_unit_cd,
             st.stat_type,
             st.derivation,
             orst.include_standard_ind,
             orst.include_local_ind,
             orst.include_other_ind
        FROM igs_en_stdnt_ps_att spa,
             igs_ps_ver crv,
             igs_pr_stat_type st,
             igs_pr_org_stat orst
       WHERE spa.person_id = p_person_id
         AND spa.course_cd = p_course_cd
         AND spa.course_cd = crv.course_cd
         AND spa.version_number = crv.version_number
         AND st.stat_type = orst.stat_type
         AND orst.org_unit_cd = crv.responsible_org_unit_cd
         AND (orst.stat_type = p_stat_type
              OR p_stat_type IS NULL
                 AND ((p_system_stat IS NULL AND orst.standard_ind = 'Y')
                      OR (p_system_stat = 'STANDARD' AND orst.standard_ind = 'Y'))
                 AND ((p_cumulative_ind = 'Y'
                       AND (orst.timeframe = 'CUMULATIVE'
                            OR orst.timeframe = 'BOTH'))
                      OR (p_cumulative_ind = 'N' AND orst.timeframe = 'PERIOD'
                          OR orst.timeframe = 'BOTH')));

    --
    -- Cursor to retrieve records at the Institution Level.
    --
    CURSOR c_inst_stat IS
      SELECT st.stat_type,
             st.derivation,
             inst.include_standard_ind,
             inst.include_local_ind,
             inst.include_other_ind
        FROM igs_pr_stat_type st, igs_pr_inst_stat inst
       WHERE st.stat_type = inst.stat_type
         AND (inst.stat_type = p_stat_type
              OR p_stat_type IS NULL
                 AND ((p_system_stat IS NULL AND inst.standard_ind = 'Y')
                      OR (p_system_stat = 'STANDARD' AND inst.standard_ind =
                                                                           'Y'))
                 AND ((p_cumulative_ind = 'Y'
                       AND (inst.timeframe = 'CUMULATIVE'
                            OR inst.timeframe = 'BOTH'))
                      OR (p_cumulative_ind = 'N' AND inst.timeframe = 'PERIOD'
                          OR inst.timeframe = 'BOTH'))); -- Bug Fix 2707516

    lc_org_stat  c_org_stat%ROWTYPE;
    lc_inst_stat c_inst_stat%ROWTYPE;
    l_message    VARCHAR2(1000);
  BEGIN
    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF fnd_api.to_boolean(NVL(p_init_msg_list, fnd_api.g_true)) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    -- Check for the Parameters which are mandatory. If the parameters are
    -- sent as NULL then raise an error
    --
    IF (p_person_id IS NULL
        OR p_course_cd IS NULL) THEN
      l_message := 'IGS_GE_INSUFFICIENT_PARAM_VAL';
      fnd_message.set_name('IGS', l_message);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    -- Check whether the system stat is not within the given values
    -- i.e standard,fin_aid or progession
    -- If not raise an error
    --
    IF (p_system_stat IS NOT NULL
        AND p_system_stat NOT IN ('STANDARD', 'FIN_AID', 'PROGRESSION')) THEN
      l_message := 'IGS_PR_SYSTEM_STAT_INCORRECT';
      fnd_message.set_name('IGS', l_message);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    -- ## Check if there records at Organization Level.
    --
    OPEN c_org_stat;
    FETCH c_org_stat INTO lc_org_stat;

    IF c_org_stat%NOTFOUND THEN
      NULL;
    ELSE
      p_stat_type := lc_org_stat.stat_type;
      p_derivation := lc_org_stat.derivation;
      p_org_unit_cd := lc_org_stat.org_unit_cd;
      p_include_std_ind := lc_org_stat.include_standard_ind;
      p_include_local_ind := lc_org_stat.include_local_ind;
      p_include_other_ind := lc_org_stat.include_other_ind;
    END IF;

    --
    -- If there are No records at Organization Level then check for the same
    -- at the Institutional Level.
    -- If there are no records at the Institutional Level too then Raise
    -- message saying No records exists
    --
    IF c_org_stat%NOTFOUND THEN
      OPEN c_inst_stat;
      FETCH c_inst_stat INTO lc_inst_stat;

      IF c_inst_stat%NOTFOUND THEN
        -- p_stat_type  := NULL;
        -- Added to fix Bug# 2685741
        --
        CLOSE c_inst_stat;
        fnd_message.set_name('IGS', 'IGS_PR_INVALID_STAT_TYPE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      --
      -- End of new code added as per Bug# 2685741
      --
      ELSE
        p_stat_type := lc_inst_stat.stat_type;
        p_derivation := lc_inst_stat.derivation;
        p_org_unit_cd := NULL;
        p_include_std_ind := lc_inst_stat.include_standard_ind;
        p_include_local_ind := lc_inst_stat.include_local_ind;
        p_include_other_ind := lc_inst_stat.include_other_ind;
      END IF;

      CLOSE c_inst_stat;
    END IF;

    CLOSE c_org_stat;
    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'GET_STAT_DTLS: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
  END get_stat_dtls;

  FUNCTION chk_unit_ref_cd(
    p_unit_cd             IN            igs_ps_unit_ver.unit_cd%TYPE,
    p_unit_version_number IN            igs_ps_unit_ver.version_number%TYPE,
    p_org_unit_cd         IN            igs_pr_org_stat.org_unit_cd%TYPE,
    p_stat_type           IN            igs_pr_stat_type.stat_type%TYPE,
    p_init_msg_list       IN            VARCHAR2,
    p_return_status       OUT NOCOPY    VARCHAR2,
    p_msg_count           OUT NOCOPY    NUMBER,
    p_msg_data            OUT NOCOPY    VARCHAR2)
    RETURN VARCHAR2 AS

--------------------------------------------------------------------------
--  Created By : Nishikant
--  Date Created On : 06-11-2001
--  Purpose: To check whether a unit is Excluded or Included by a reference code
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
--  (reverse chronological order - newest change first)
--  kdande   20-Sep-2002 Bug# 2560160: Defaulted the p_init_msg_list parameter
--                       in the code since default value is removed from the
--                       function signature.
--------------------------------------------------------------------------

    CURSOR c_org_setup IS
      SELECT ostr1.include_or_exclude
        FROM igs_pr_org_stat_ref ostr1
       WHERE ostr1.stat_type = p_stat_type AND ostr1.org_unit_cd =
                                                                  p_org_unit_cd;

    CURSOR c_org_included IS
      SELECT 'X'
        FROM igs_ps_unit_ref_cd urc, igs_ge_ref_cd_type rct
       WHERE urc.unit_cd = p_unit_cd
         AND urc.version_number = p_unit_version_number
         AND urc.reference_cd_type = rct.reference_cd_type
         AND rct.s_reference_cd_type = 'STATS'
         AND EXISTS( SELECT 'X'
                       FROM igs_pr_org_stat_ref ostr1
                      WHERE ostr1.stat_type = p_stat_type
                        AND ostr1.org_unit_cd = p_org_unit_cd
                        AND ostr1.unit_ref_cd = urc.reference_cd
                        AND ostr1.include_or_exclude = 'INCLUDE');

    CURSOR c_org_excluded IS
      SELECT 'X'
        FROM igs_ps_unit_ref_cd urc, igs_ge_ref_cd_type rct
       WHERE urc.unit_cd = p_unit_cd
         AND urc.version_number = p_unit_version_number
         AND urc.reference_cd_type = rct.reference_cd_type
         AND rct.s_reference_cd_type = 'STATS'
         AND EXISTS( SELECT 'X'
                       FROM igs_pr_org_stat_ref ostr1
                      WHERE ostr1.stat_type = p_stat_type
                        AND ostr1.org_unit_cd = p_org_unit_cd
                        AND ostr1.unit_ref_cd = urc.reference_cd
                        AND ostr1.include_or_exclude = 'EXCLUDE');

    CURSOR c_inst_setup IS
      SELECT INSTR.include_or_exclude
        FROM igs_pr_inst_sta_ref INSTR
       WHERE INSTR.stat_type = p_stat_type;

    CURSOR c_inst_included IS
      SELECT 'X'
        FROM igs_ps_unit_ref_cd urc, igs_ge_ref_cd_type rct
       WHERE urc.unit_cd = p_unit_cd
         AND urc.version_number = p_unit_version_number
         AND urc.reference_cd_type = rct.reference_cd_type
         AND rct.s_reference_cd_type = 'STATS'
         AND EXISTS( SELECT 'X'
                       FROM igs_pr_inst_sta_ref instr1
                      WHERE instr1.stat_type = p_stat_type
                        AND instr1.unit_ref_cd = urc.reference_cd
                        AND instr1.include_or_exclude = 'INCLUDE');

    CURSOR c_inst_excluded IS
      SELECT 'X'
        FROM igs_ps_unit_ref_cd urc, igs_ge_ref_cd_type rct
       WHERE urc.unit_cd = p_unit_cd
         AND urc.version_number = p_unit_version_number
         AND urc.reference_cd_type = rct.reference_cd_type
         AND rct.s_reference_cd_type = 'STATS'
         AND EXISTS( SELECT 'X'
                       FROM igs_pr_inst_sta_ref instr1
                      WHERE instr1.stat_type = p_stat_type
                        AND instr1.unit_ref_cd = urc.reference_cd
                        AND instr1.include_or_exclude = 'EXCLUDE');

    l_include_or_exclude VARCHAR2(20);
    l_include            VARCHAR2(1);
    l_dummy              VARCHAR2(1);
    l_message            VARCHAR2(1000);
  BEGIN
    l_include := 'Y';
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(NVL(p_init_msg_list, fnd_api.g_true)) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- The following parameters should not be null
    IF (p_unit_cd IS NULL
        OR p_unit_version_number IS NULL
        OR p_stat_type IS NULL) THEN
      l_message := 'IGS_GE_INSUFFICIENT_PARAM_VAL';
      fnd_message.set_name('IGS', l_message);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- If the Organizational Unit is not null then statistic type is
    -- defined at Organizational level.  Check if any unit reference
    -- codes are included or excluded at Org level.

    IF p_org_unit_cd IS NOT NULL THEN
      -- When no Unit Reference Codes are specifically included or excluded all
      -- units should be included.
      OPEN c_org_setup;
      FETCH c_org_setup INTO l_include_or_exclude;

      IF (c_org_setup%FOUND) THEN
        IF (l_include_or_exclude = 'INCLUDE') THEN
          -- When Unit Reference Codes are specifically included then only those
          -- units with the included Unit Refernce Code should be included
          OPEN c_org_included;
          FETCH c_org_included INTO l_dummy;

          IF (c_org_included%NOTFOUND) THEN
            l_include := 'N';
          END IF;

          CLOSE c_org_included;
        ELSE
          -- When Unit Reference Codes are specifically excluded all units except
          -- those units with the excluded Unit Refernce Code should be included
          OPEN c_org_excluded;
          FETCH c_org_excluded INTO l_dummy;

          IF (c_org_excluded%FOUND) THEN
            l_include := 'N';
          END IF;

          CLOSE c_org_excluded;
        END IF;
      END IF;

      CLOSE c_org_setup;
    -- If the Organizational Unit is null then statistic type must be
    -- defined at Institution level.  Check if any unit reference
    -- codes are included or excluded at Inst level.
    ELSE
      -- When no Unit Reference Codes are specifically included or excluded all
      -- units should be included.
      OPEN c_inst_setup;
      FETCH c_inst_setup INTO l_include_or_exclude;

      IF (c_inst_setup%FOUND) THEN
        IF (l_include_or_exclude = 'INCLUDE') THEN
          -- When Unit Reference Codes are specifically included then only those
          -- units with the included Unit Refernce Code should be included
          OPEN c_inst_included;
          FETCH c_inst_included INTO l_dummy;

          IF (c_inst_included%NOTFOUND) THEN
            l_include := 'N';
          END IF;

          CLOSE c_inst_included;
        ELSE
          -- When Unit Reference Codes are specifically excluded all units except
          -- those units with the excluded Unit Refernce Code should be included
          OPEN c_inst_excluded;
          FETCH c_inst_excluded INTO l_dummy;

          IF (c_inst_excluded%FOUND) THEN
            l_include := 'N';
          END IF;

          CLOSE c_inst_excluded;
        END IF;
      END IF;

      CLOSE c_inst_setup;
    END IF;

    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);
    RETURN l_include;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
      RETURN NULL;
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
      RETURN NULL;
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'chk_unit_ref_cd: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
      RETURN NULL;
  END chk_unit_ref_cd;

  PROCEDURE get_adv_stats(
    p_person_id               IN            igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd               IN            igs_en_stdnt_ps_att.course_cd%TYPE,
    p_stat_type               IN            igs_pr_stat_type.stat_type%TYPE,
    p_org_unit_cd             IN            igs_pr_org_stat.org_unit_cd%TYPE,
    p_load_cal_type           IN            igs_ca_inst.cal_type%TYPE,
    p_load_ci_sequence_number IN            igs_ca_inst.sequence_number%TYPE,
    p_cumulative_ind          IN            VARCHAR2,
    p_include_local_ind       IN            VARCHAR2,
    p_include_other_ind       IN            VARCHAR2,
    p_earned_cp     OUT NOCOPY    NUMBER,
    p_attempted_cp  OUT NOCOPY    NUMBER,
    p_gpa_cp                  OUT NOCOPY    NUMBER,
    p_gpa_quality_points      OUT NOCOPY    NUMBER,
    p_init_msg_list           IN            VARCHAR2,
    p_return_status           OUT NOCOPY    VARCHAR2,
    p_msg_count               OUT NOCOPY    NUMBER,
    p_msg_data                OUT NOCOPY    VARCHAR2) IS
    /*
    ||Created By : Prajeesh Chandran
    ||Created On : 6-NOV-2001
    ||Purpose : Gets the GPA AND Credit points incase of Advanced Standing
    ||          (Org or Institution)
    ||Known limitations, enhancements or remarks :
    ||Change History :
    ||Who      When       What
    ||smanglm  25-06-2002 as per bug 2430606 modified
    ||         asu.institution_cd = inst.institution_cd(+) in cursor c_asu to
    ||         asu.exemption_institution_cd = inst.institution_cd(+) and
    ||         asul.institution_cd = inst.institution_cd(+) in cursor c_asul to
    ||         asul.exemption_institution_cd = inst.institution_cd(+)
    ||         This is done to see Advanced Standing granted from the loca
    ||         institution in the academic statistics calculation.
    ||(reverse chronological order - newest change first)
    ||kdande   20-Sep-2002 Bug# 2560160: Defaulted the p_init_msg_list parameter
    ||         in the code since default value is removed from the procedure
    ||         signature.
    ||swaghmar 15-Sep-2005; Bug 4491456 - Modified the signature and variable datatypes
    ||				for the fix
    ||swaghmar 20-Jun-2006; Bug 5260180
    */

    -- Cursor to get the Credit Point,Course code and Unitcode details with the
    -- achievable and enrolled credit Points
    CURSOR c_asu IS
      SELECT asu.unit_cd,
             asu.version_number,
             asu.achievable_credit_points,
             asu.grading_schema_cd,
             asu.grd_sch_version_number,
             asu.grade,
             asu.av_stnd_unit_id
        FROM igs_av_stnd_unit asu, igs_or_inst_org_base_v inst, igs_ca_inst ci
       WHERE asu.person_id = p_person_id
         AND asu.as_course_cd = p_course_cd
         AND asu.s_adv_stnd_granting_status IN ('GRANTED', 'APPROVED')
         AND asu.s_adv_stnd_recognition_type = 'CREDIT'
         AND NVL(asu.expiry_dt, SYSDATE + 1) > SYSDATE
         AND asu.exemption_institution_cd = inst.party_number(+) --swaghmar change
         AND ((p_include_local_ind = 'Y' AND inst.oi_local_institution_ind = 'Y')
              OR (p_include_other_ind = 'Y' AND inst.oi_local_institution_ind =
                                                                           'N'))
         AND asu.cal_type = ci.cal_type
         AND asu.ci_sequence_number = ci.sequence_number
	 AND inst.inst_org_ind = 'I'
         AND ((p_cumulative_ind = 'N'
               AND p_load_cal_type = asu.cal_type
               AND p_load_ci_sequence_number = asu.ci_sequence_number)
              OR (p_cumulative_ind = 'Y'
                  AND 0 < (SELECT COUNT(*)
                             FROM igs_ca_inst ci2
                            WHERE p_load_cal_type = ci2.cal_type
                              AND p_load_ci_sequence_number =
                                                            ci2.sequence_number
                              AND ci.start_dt <= ci2.start_dt)));

    CURSOR c_gsg(
      cp_grading_schema_cd igs_as_grd_sch_grade.grading_schema_cd%TYPE,
      cp_gs_version_number igs_as_grd_sch_grade.version_number%TYPE,
      cp_grade             igs_as_grd_sch_grade.grade%TYPE) IS
      SELECT s_result_type,
             gpa_val
        FROM igs_as_grd_sch_grade gsg
       WHERE gsg.grading_schema_cd = cp_grading_schema_cd
         AND gsg.version_number = cp_gs_version_number
         AND gsg.grade = cp_grade;

    CURSOR c_asul IS
      SELECT SUM(NVL(asul.credit_points, 0)) sumvalue
        FROM igs_av_stnd_unit_lvl asul, igs_or_inst_org_base_v inst, igs_ca_inst ci
       WHERE asul.person_id = p_person_id
         AND asul.as_course_cd = p_course_cd
         AND asul.s_adv_stnd_granting_status IN ('GRANTED', 'APPROVED')
         AND NVL(asul.expiry_dt, SYSDATE + 1) > SYSDATE
         AND asul.exemption_institution_cd = inst.ou_institution_cd(+)
         AND ((p_include_local_ind = 'Y' AND inst.oi_local_institution_ind = 'Y')
              OR (p_include_other_ind = 'Y' AND inst.oi_local_institution_ind =
                                                                           'N'))
         AND asul.cal_type = ci.cal_type
         AND asul.ci_sequence_number = ci.sequence_number
         AND inst.inst_org_ind = 'I'
	 AND ((p_cumulative_ind = 'N'
               AND p_load_cal_type = asul.cal_type
               AND p_load_ci_sequence_number = asul.ci_sequence_number)
              OR (p_cumulative_ind = 'Y'
                  AND 0 < (SELECT COUNT(*)
                             FROM igs_ca_inst ci2
                            WHERE p_load_cal_type = ci2.cal_type
                              AND p_load_ci_sequence_number =
                                                            ci2.sequence_number
                              AND ci.start_dt <= ci2.start_dt)));

    lc_asul              c_asul%ROWTYPE;
    lc_gsg               c_gsg%ROWTYPE;
    l_earned_cp_total    NUMBER   := 0;
    l_attempted_cp_total NUMBER   := 0;
    l_gpa_cp             NUMBER   := 0;
    l_gpa_quality_points NUMBER   := 0;
    l_init_msg_list      VARCHAR2(20);
    l_return_status      VARCHAR2(30);
    l_msg_count          NUMBER(2);
    l_msg_data           VARCHAR2(30);
  BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(NVL(p_init_msg_list, fnd_api.g_true)) THEN
      fnd_msg_pub.initialize;
    END IF;
    -- Unit Advanced Standing
    FOR lc_asu IN c_asu LOOP
      -- If achievable credit points is greater than zero, call Sub Function to
      -- check included or excluded unit reference codes

      IF  NVL(lc_asu.achievable_credit_points, 0) > 0
          AND (chk_unit_ref_cd(
                lc_asu.unit_cd,
                lc_asu.version_number,
                p_org_unit_cd,
                p_stat_type,
                l_init_msg_list,
                l_return_status,
                l_msg_count,
                l_msg_data) = 'Y'
	--jhanda
           OR chk_av_unit_ref_cd (
                  lc_asu.av_stnd_unit_id   ,
                  p_org_unit_cd       ,
                  p_stat_type         ,
                  fnd_api.g_true      ,
                  l_return_status     ,
                  l_msg_count         ,
                  l_msg_data
                  )= 'Y' )
           -- jhanda
	THEN
        IF  lc_asu.grading_schema_cd IS NOT NULL
            AND lc_asu.grd_sch_version_number IS NOT NULL
            AND lc_asu.grade IS NOT NULL THEN
          OPEN c_gsg(
            lc_asu.grading_schema_cd,
            lc_asu.grd_sch_version_number,
            lc_asu.grade);
          FETCH c_gsg INTO lc_gsg;
          CLOSE c_gsg;

          -- Add credit points to the totals
          IF lc_gsg.s_result_type = 'PASS' THEN
            l_earned_cp_total :=
                            l_earned_cp_total + lc_asu.achievable_credit_points;
          END IF;

            l_attempted_cp_total :=
                         l_attempted_cp_total + lc_asu.achievable_credit_points;

          -- Add values to the GPA totals
          IF  lc_gsg.gpa_val IS NOT NULL
              AND lc_gsg.s_result_type NOT IN ('WITHDRAWN', 'INCOMP') THEN
            l_gpa_cp := l_gpa_cp + NVL(lc_asu.achievable_credit_points, 0);
            l_gpa_quality_points :=   l_gpa_quality_points
                                    + (  lc_gsg.gpa_val
                                       * NVL(
                                           lc_asu.achievable_credit_points,
                                           0));
          END IF;
        ELSE
          l_earned_cp_total :=
                     l_earned_cp_total + NVL(
                                           lc_asu.achievable_credit_points,
                                           0);
          l_attempted_cp_total :=
                  l_attempted_cp_total + NVL(
                                           lc_asu.achievable_credit_points,
                                           0);
        END IF;
      END IF;
    END LOOP;

    -- Unit Level Advanced Standing
    OPEN c_asul;
    FETCH c_asul INTO lc_asul;
    l_attempted_cp_total := l_attempted_cp_total + NVL(lc_asul.sumvalue, 0);
    l_earned_cp_total := l_earned_cp_total + NVL(lc_asul.sumvalue, 0);
    -- Set out NOCOPY parameter values
    p_gpa_cp := l_gpa_cp;
    p_gpa_quality_points := l_gpa_quality_points;
    p_attempted_cp := l_attempted_cp_total;
    p_earned_cp := l_earned_cp_total;
    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'GET_ADV_STATS: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
  END get_adv_stats;

  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the local PROCEDURE get_sua_stats
  -- swaghmar; 15-Sep-2005; Bug 4491456
  --	Modified the signature
  --
  PROCEDURE get_sua_stats (
    p_person_id                IN         igs_en_su_attempt_ALL.person_id%TYPE,
    p_course_cd                IN         igs_en_su_attempt_ALL.course_cd%TYPE,
    p_unit_cd                  IN         igs_en_su_attempt_ALL.unit_cd%TYPE,
    p_unit_version_number      IN         igs_en_su_attempt_ALL.version_number%TYPE,
    p_teach_cal_type           IN         igs_en_su_attempt_ALL.cal_type%TYPE,
    p_teach_ci_sequence_number IN         igs_en_su_attempt_ALL.ci_sequence_number%TYPE,
    p_earned_cp                OUT NOCOPY NUMBER,
    p_attempted_cp             OUT NOCOPY NUMBER,
    p_gpa_value                OUT NOCOPY NUMBER,
    p_gpa_cp                   OUT NOCOPY NUMBER,
    p_gpa_quality_points       OUT NOCOPY NUMBER,
    p_init_msg_list            IN         VARCHAR2,
    p_return_status            OUT NOCOPY VARCHAR2,
    p_msg_count                OUT NOCOPY NUMBER,
    p_msg_data                 OUT NOCOPY VARCHAR2,
    p_uoo_id                   IN         NUMBER,
    p_use_released_grade       IN         VARCHAR2,
    p_enrolled_cp	       OUT NOCOPY igs_pr_stu_acad_stat.gpa_quality_points%TYPE) IS
    --------------------------------------------------------------------------
    --  Created By : David Larsen
    --  Date Created On : 06-11-2002
    --  Purpose:  To derive all of the statistic values for a given
    --            Statistic Type for a Student Unit Attempt.
    --  Know limitations, enhancements or remarks
    --  Change History
    --------------------------------------------------------------------------
    --  Who             When            What
    --------------------------------------------------------------------------
    --  Nalin Kumar     17-Feb-2004     Modified the SELECT part of C_SUA_UV CURSOR to fix Bug# 3419920;
    --  sarakshi        25-jun-2003     Enh#2930935,modified cursor c_sua_uv to select unit section enrolled and
    --                                  achievable credit points if exist else unit level
    --  kdande          23-Apr-2003     Bug# 2829262 Added uoo_id field to the WHERE clause of cursor c_sua_uv
    --  jhanda          25-feb-2005     Bug 3843525 Added parameter p_enrolled_cp
    -- swaghmar		15-Sep-2005	Bug# 4491456 - Modified the signature
    --------------------------------------------------------------------------
      CURSOR c_sua_uv IS
      SELECT sua.unit_attempt_status,
             NVL(sua.override_achievable_cp , sua.override_enrolled_cp ) sua_override_cp,
             NVL(uc.achievable_credit_points, uc.enrolled_credit_points) uc_credit_points,
             NVL(uv.achievable_credit_points, uv.enrolled_credit_points) uv_credit_points
          FROM igs_en_stdnt_ps_att spa,
               igs_ps_ver pv,
               igs_en_su_attempt_ALL sua,
               igs_ps_unit_ver uv,
               igs_ps_usec_cps uc
         WHERE spa.person_id = p_person_id
           AND spa.course_cd = p_course_cd
           AND spa.course_cd = pv.course_cd
           AND spa.version_number = pv.version_number
           AND sua.person_id = spa.person_id
           AND sua.course_cd = spa.course_cd
           AND sua.uoo_id = p_uoo_id
           AND sua.unit_cd = p_unit_cd
           AND sua.version_number = p_unit_version_number
           AND sua.cal_type = p_teach_cal_type
           AND sua.ci_sequence_number = p_teach_ci_sequence_number
           AND sua.unit_attempt_status IN
                             ('COMPLETED', 'DUPLICATE', 'ENROLLED', 'DISCONTIN')
           AND uv.unit_cd = sua.unit_cd
           AND uv.version_number = sua.version_number
           AND sua.uoo_id = uc.uoo_id(+)
           AND (   (sua.student_career_transcript = 'Y')
        OR (    NOT EXISTS (SELECT 'Y'
                              FROM igs_ps_prg_unit_rel pur
                             WHERE pur.unit_type_id = uv.unit_type_id
                               AND pur.student_career_level = pv.course_type
                               AND pur.student_career_transcript = 'N')
            AND NVL (sua.student_career_transcript, 'X') <> 'N'
           )
       )
      ORDER BY sua.unit_cd ASC, sua.ci_end_dt ASC;

    -- This cursor fetches the gpa_value for the Grading Schema Code
    -- ijeddy, bug 3489388 added show_in_earned_crdt_indto the cursor.
    CURSOR c_grad_schema_gpa(
      cp_grading_schema_cd igs_as_grd_sch_grade.grading_schema_cd%TYPE,
      cp_gs_version_number igs_as_grd_sch_grade.version_number%TYPE,
      cp_grade             igs_as_grd_sch_grade.grade%TYPE) IS
      SELECT gsg.gpa_val,
             NVL (gsg.show_in_earned_crdt_ind, 'N') show_in_earned_crdt_ind
        FROM igs_as_grd_sch_grade gsg
       WHERE gsg.grading_schema_cd = cp_grading_schema_cd
         AND gsg.version_number = cp_gs_version_number
         AND gsg.grade = cp_grade;


    l_init_msg_list               VARCHAR2(20);
    l_return_status               VARCHAR2(30);
    l_msg_count                   NUMBER(2);
    l_msg_data                    VARCHAR2(30);
    l_unit_attempt_status         igs_en_su_attempt_ALL.unit_attempt_status%TYPE;
    l_sua_override_cp             igs_ps_unit_ver.achievable_credit_points%TYPE;
    l_uc_credit_points            igs_ps_unit_ver.achievable_credit_points%TYPE;
    l_uv_credit_points            igs_ps_unit_ver.achievable_credit_points%TYPE;
    l_unit_cp                     NUMBER                                   := 0;
    l_result_type                 VARCHAR2(20);
    l_outcome_dt                  igs_as_su_stmptout.outcome_dt%TYPE;
    l_grading_schema_cd           igs_as_grd_sch_grade.grading_schema_cd%TYPE;
    l_gs_version_number           igs_as_grd_sch_grade.version_number%TYPE;
    l_grade                       igs_as_grd_sch_grade.grade%TYPE;
    l_mark                        igs_as_su_stmptout.mark%TYPE;
    l_gsg_gpa_value               NUMBER;
    l_gsg_show                    igs_as_grd_sch_grade.show_in_earned_crdt_ind%TYPE;
    l_origin_course_cd            igs_ps_stdnt_unt_trn.transfer_course_cd%TYPE;
  BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(NVL(p_init_msg_list, fnd_api.g_true)) THEN
      fnd_msg_pub.initialize;
    END IF;
    --
    -- Getting the Student Unit Attempt details
    -- Modified the Fetch statment to fix Bug# 3419920; Nalin Kumar; 17-Feb-2004;
    --
    OPEN c_sua_uv;
    FETCH c_sua_uv INTO l_unit_attempt_status,
                        l_sua_override_cp,
                        l_uc_credit_points,
                        l_uv_credit_points;
      IF c_sua_uv%NOTFOUND THEN
        CLOSE c_sua_uv;
        -- Initialize API return status to success.
        p_return_status := fnd_api.g_ret_sts_success;
        RETURN;
      END IF;
    CLOSE c_sua_uv;
    --
    -- kdande; 23-Apr-2003; Bug# 2829262
    -- Added uoo_id parameter to the igs_as_gen_003.assp_get_sua_outcome FUNCTION call
    --
    -- Get the Student Unit Attempt Outcome details
    --
    l_result_type :=
        igs_as_gen_003.assp_get_sua_outcome(
          p_person_id,
          p_course_cd,
          p_unit_cd,
          p_teach_cal_type,
          p_teach_ci_sequence_number,
          l_unit_attempt_status,
          'Y',
          l_outcome_dt,
          l_grading_schema_cd,
          l_gs_version_number,
          l_grade,
          l_mark,
          l_origin_course_cd,
          p_uoo_id,
	  NVL (p_use_released_grade, 'N'));

    ---deleted the condition for checking the released grade as it is
    ---already handled in the GEN 003 package,hence deleting the variable
    ---l_reased_ind.


    -- Determine the CP value for the Student Unit Attempt
    -- Modified the next statment as per the Bug# 3419920; Nalin Kumar; 17-Feb-2004;
    --
    l_unit_cp := NVL(l_sua_override_cp, NVL(l_uc_credit_points, l_uv_credit_points));
    --
    -- Getting the GPA value for the grading scema code
    --
    OPEN c_grad_schema_gpa(l_grading_schema_cd, l_gs_version_number, l_grade);
    FETCH c_grad_schema_gpa INTO l_gsg_gpa_value, l_gsg_show;
    IF c_grad_schema_gpa%FOUND THEN
    ---removed the if condition for checking the value of l_reased_ind as it is no more required.
        IF l_gsg_gpa_value IS NOT NULL AND
           l_result_type NOT IN ('WITHDRAWN', 'INCOMP') THEN
          p_gpa_cp := l_unit_cp;
          p_gpa_quality_points := l_gsg_gpa_value * l_unit_cp;
          IF NVL(p_gpa_cp, 0) = 0 THEN
            p_gpa_value := 0;
          ELSE
            p_gpa_value := p_gpa_quality_points / p_gpa_cp;
          END IF;
        END IF;
    END IF;
    CLOSE c_grad_schema_gpa;
    --
    -- Only Consider the PASS Outcomes for the Earned Credit Points.
    -- ijeddy, bug 3489388.
    IF ((l_result_type = 'PASS') AND (l_gsg_show = 'Y')) THEN
      p_earned_cp := l_unit_cp;
    ELSE
      p_earned_cp := NULL;
    END IF;
    --
    -- Consider all Outcomes for the Attempted Credit Points
    -- Return the Unit CP when there is no outcome for the SUA
    -- ijeddy, bug 3489388.
    IF (((l_gsg_show = 'Y') AND (l_grade IS NOT NULL)) OR (l_grade IS NULL)) THEN
      p_attempted_cp  := l_unit_cp;
    ELSE -- Rest all cases
      p_attempted_cp  := NULL;
    END IF;

    -- Consider all Outcomes for the enrolled Credit Points
    -- Return the Unit CP when there is SUA is in ENROLLED status
    -- jhanda  3843525

    IF l_unit_attempt_status = 'ENROLLED' THEN
       p_enrolled_cp := l_unit_cp;
    END IF;

    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'GET_SUA_STATS: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
  END get_sua_stats;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the PROCEDURE get_sua_all
  --

  PROCEDURE get_sua_all (
    p_person_id                IN  igs_en_su_attempt.person_id%TYPE,
    p_course_cd                IN  igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                  IN  igs_en_su_attempt.unit_cd%TYPE,
    p_unit_version_number      IN  igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type           IN  igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number IN  igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                IN  igs_pr_org_stat.stat_type%TYPE,
    p_system_stat              IN  VARCHAR2,
    p_earned_cp                OUT NOCOPY NUMBER,
    p_attempted_cp             OUT NOCOPY NUMBER,
    p_gpa_value                OUT NOCOPY NUMBER,
    p_gpa_cp                   OUT NOCOPY NUMBER,
    p_gpa_quality_points       OUT NOCOPY NUMBER,
    p_init_msg_list            IN  VARCHAR2,
    p_return_status            OUT NOCOPY VARCHAR2,
    p_msg_count                OUT NOCOPY NUMBER,
    p_msg_data                 OUT NOCOPY VARCHAR2,
    p_uoo_id                   IN  NUMBER,
    p_use_released_grade       IN  VARCHAR2) IS

-- Note param p_enrolled_cp needs to be added for bug 3843525

--------------------------------------------------------------------------
--  Created By : David Larsen
--  Date Created On : 06-11-2002
--  Purpose:  To check the statistic configuration, check if the unit is
--            included or excluded and the derive all of the statistic
--            values for a given Statistic Type for a Student Unit Attempt.
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
-- swaghmar; 15-Sep-2005; Bug 4491456 Modified the signature
-- swaghmar;  15-Jun-2006;  Bug 5260180
--------------------------------------------------------------------------

    l_stat_type          igs_pr_stat_type.stat_type%TYPE;
    l_org_unit_cd        igs_pr_org_stat.org_unit_cd%TYPE;
    l_include_std_ind    igs_pr_org_stat.include_standard_ind%TYPE;
    l_include_local_ind  igs_pr_org_stat.include_local_ind%TYPE;
    l_include_other_ind  igs_pr_org_stat.include_other_ind%TYPE;
    l_derivation         igs_pr_stat_type.derivation%TYPE;
    l_earned_cp          NUMBER;
    l_attempted_cp       NUMBER;
    l_gpa_cp             NUMBER;
    l_gpa_quality_points NUMBER;
    l_gpa_value          NUMBER;
    l_return_status      VARCHAR2(30);
    l_msg_count          NUMBER(2);
    l_msg_data           VARCHAR2(30);
    l_org_id             NUMBER(4);
    p_enrolled_cp        igs_ps_unit_ver.achievable_credit_points%TYPE :=0;

    -- Added as part of fix for Bug# 5260180
    v_inc_exc_ul         VARCHAR2(1) := 'Y';
    v_inc_exc_sua        VARCHAR2(1) := 'Y';

  BEGIN
    l_org_id := igs_ge_gen_003.get_org_id;
    igs_ge_gen_003.set_org_id(l_org_id);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(NVL(p_init_msg_list, fnd_api.g_true)) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Validate the Parameters, so that must not be NULL
    IF (p_person_id IS NULL
        OR p_course_cd IS NULL
        OR p_unit_cd IS NULL
        OR p_unit_version_number IS NULL
        OR p_teach_cal_type IS NULL
        OR p_teach_ci_sequence_number IS NULL) THEN
      fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAM_VAL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    p_gpa_value := NULL;
    p_gpa_cp := NULL;
    p_gpa_quality_points := NULL;
    p_attempted_cp := NULL;
    p_earned_cp := NULL;
    l_stat_type := p_stat_type;
    -- Call the Statistic Details Procedure to get the Statistic Details
    get_stat_dtls(  --**
      p_person_id,
      p_course_cd,
      p_system_stat,
      'N', -- Changed from NULL Bug Fix 2707516
      l_stat_type,
      l_org_unit_cd,
      l_include_std_ind,
      l_include_local_ind,
      l_include_other_ind,
      l_derivation,
      fnd_api.g_true,
      l_return_status,
      l_msg_count,
      l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      p_gpa_value := NULL;
      p_gpa_cp := NULL;
      p_gpa_quality_points := NULL;
      p_earned_cp := NULL;
      p_attempted_cp := NULL;
      p_return_status := l_return_status;
      p_msg_count := l_msg_count;
      p_msg_data := l_msg_data;
      RETURN;
    END IF;

    -- If the Statistic Type is NULL then return the earned and attempted
    -- credit points as NULL
    IF l_stat_type IS NULL THEN
      p_gpa_value := NULL;
      p_gpa_cp := NULL;
      p_gpa_quality_points := NULL;
      p_earned_cp := NULL;
      p_attempted_cp := NULL;
      p_return_status := l_return_status;
      p_msg_count := l_msg_count;
      p_msg_data := l_msg_data;
      RETURN;
    END IF;

    -- Check for the Standard Indicator Flag then loop thru Student Unit Attempts
    IF l_include_std_ind = 'Y' THEN
      -- Check if the Unit Reference Code is included/excluded for this Stat Type
      IF chk_unit_ref_cd(
           p_unit_cd,
           p_unit_version_number,
           l_org_unit_cd,
           l_stat_type,
           fnd_api.g_true,
           l_return_status,
           l_msg_count,
           l_msg_data) = 'Y' THEN
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          p_return_status := l_return_status;
          p_msg_count := l_msg_count;
          p_msg_data := l_msg_data;
          RETURN;
        END IF;
        v_inc_exc_ul := 'Y';
      ELSE -- Added as part of fix for Bug# 5260180
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          p_return_status := l_return_status;
          p_msg_count := l_msg_count;
          p_msg_data := l_msg_data;
          RETURN;
        END IF;
        v_inc_exc_ul := 'N';
      END IF;

	-- Calling the chk_sua_ref_cd() here and progress further only if the function returns 'Y'
        -- Check if Student Unit Attempt Reference Code is included/excluded for this Stat Type
        IF chk_sua_ref_cd(
             p_person_id,
             p_course_cd,
             p_uoo_id,
             l_org_unit_cd,
             l_stat_type,
             fnd_api.g_true,
             l_return_status,
             l_msg_count,
             l_msg_data) = 'Y' THEN
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            p_return_status := l_return_status;
            p_msg_count := l_msg_count;
            p_msg_data := l_msg_data;
            RETURN;
          END IF;
	   v_inc_exc_sua := 'Y';
        ELSE -- Added as part of fix for Bug# 5260180
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          p_return_status := l_return_status;
          p_msg_count := l_msg_count;
          p_msg_data := l_msg_data;
          RETURN;
        END IF;
        v_inc_exc_sua := 'N';
      END IF;

         IF (v_inc_exc_sua = 'Y' OR v_inc_exc_ul = 'Y') THEN -- Added as part of fix for Bug# 5260180
	-- Call GET_SUA_ALL to calculate the GPA and CP values for the Student
        -- Unit Attempt
        get_sua_stats(  --**
          p_person_id,
          p_course_cd,
          p_unit_cd,
          p_unit_version_number,
          p_teach_cal_type,
          p_teach_ci_sequence_number,
          l_earned_cp,
          l_attempted_cp,
          l_gpa_value,
          l_gpa_cp,
          l_gpa_quality_points,
          fnd_api.g_true,
          l_return_status,
          l_msg_count,
          l_msg_data,
          p_uoo_id,
          p_use_released_grade,
	  p_enrolled_cp);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          p_gpa_value := NULL;
          p_gpa_cp := NULL;
          p_gpa_quality_points := NULL;
          p_earned_cp := NULL;
          p_attempted_cp := NULL;
          p_return_status := l_return_status;
          p_msg_count := l_msg_count;
          p_msg_data := l_msg_data;
          RETURN;
        END IF;
      END IF;
    -- END IF;
    END IF;

    -- Set out NOCOPY parameters
    p_gpa_value := l_gpa_value;
    p_gpa_cp := l_gpa_cp;
    p_gpa_quality_points := l_gpa_quality_points;
    p_earned_cp := l_earned_cp;
    p_attempted_cp := l_attempted_cp;
    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'GET_SUA_ALL: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
  END get_sua_all;

  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_cp
  --
  PROCEDURE get_sua_cp(
    p_person_id                IN            igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd                IN            igs_en_stdnt_ps_att.course_cd%TYPE,
    p_unit_cd                  IN            igs_ps_unit_ver.unit_cd%TYPE,
    p_unit_version_number      IN            igs_ps_unit_ver.version_number%TYPE,
    p_teach_cal_type           IN            igs_ca_inst.cal_type%TYPE,
    p_teach_ci_sequence_number IN            igs_ca_inst.sequence_number%TYPE,
    p_stat_type                IN            igs_pr_stat_type.stat_type%TYPE,
    p_system_stat              IN            VARCHAR2,
    p_earned_cp     OUT NOCOPY    NUMBER,
    p_attempted_cp  OUT NOCOPY    NUMBER,
    p_init_msg_list            IN            VARCHAR2,
    p_return_status            OUT NOCOPY    VARCHAR2,
    p_msg_count                OUT NOCOPY    NUMBER,
    p_msg_data                 OUT NOCOPY    VARCHAR2,
    p_uoo_id                   IN  NUMBER,
    p_use_released_grade       IN  VARCHAR2) AS
    /***************************************************************************
     Created By : rbezawad
     Date Created By : 31-Oct-2001
     Purpose : This procedure used to derive the Credit Point value for a given
               Statistics Type for a Student Unit Attempt
               1. Validate the Parameters if any of the required parameters Null
                  If any one is null then error out.
               2. Call get_unitstat_dtls() procedure to get the Statistic Type
                  Definition from Org Unit level or Inistitution Level.
               3. If there is no Static Type details available at Org Unit Level
                  or Inistitution Level then Error out.
               4. Get the Student Unit Attempt Details to calculate Credit Points
                  If there no Student Unit Attempt data then Error out.
               5. Call get_cp() procedure to Calculate Earned and Attempted
                  Credit points and return.

    Known limitations,enhancements,remarks:
    Change History
    Who      When      What
    ayedubat 24-1-2002 Changed the cursor c_sua_uv to consider the
                       Student_career_statics overriden at the Student Unit
                       Attempt Level
    swaghmar 15-9-2005 Bug 4491456 - Modified the signature
    ***************************************************************************/

    l_earned_cp          NUMBER;
    l_attempted_cp       NUMBER;
    l_gpa_cp             NUMBER;
    l_gpa_quality_points NUMBER;
    l_gpa_value          NUMBER;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_org_id             NUMBER(4);
  BEGIN
    l_org_id := igs_ge_gen_003.get_org_id;
    igs_ge_gen_003.set_org_id(l_org_id);

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Validate the Parameters, so that must not be NULL
    IF (p_person_id IS NULL
        OR p_course_cd IS NULL
        OR p_unit_cd IS NULL
        OR p_unit_version_number IS NULL
        OR p_teach_cal_type IS NULL
        OR p_teach_ci_sequence_number IS NULL) THEN
      fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAM_VAL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Call GET_SUA_ALL to calculate the GPA and CP values for the Student Unit
    -- Attempt
    get_sua_all(
      p_person_id,
      p_course_cd,
      p_unit_cd,
      p_unit_version_number,
      p_teach_cal_type,
      p_teach_ci_sequence_number,
      p_stat_type,
      p_system_stat,
      l_earned_cp,
      l_attempted_cp,
      l_gpa_value,
      l_gpa_cp,
      l_gpa_quality_points,
      fnd_api.g_true,
      l_return_status,
      l_msg_count,
      l_msg_data,
      p_uoo_id,
      p_use_released_grade);

    -- If any Error is occurred in get_cp procedure Then return.
    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      p_return_status := l_return_status;
      p_msg_count := l_msg_count;
      p_msg_data := l_msg_data;
      RETURN;
    END IF;

    -- Set out NOCOPY parameters
    p_earned_cp := l_earned_cp;
    p_attempted_cp := l_attempted_cp;
    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'get_sua_cp: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
  END get_sua_cp;

  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_gpa
  -- swaghmar; 15-Sep-2005; Bug 4491456 - Modified the signature
  --
  PROCEDURE get_sua_gpa(
    p_person_id                IN            igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd                IN            igs_en_stdnt_ps_att.course_cd%TYPE,
    p_unit_cd                  IN            igs_ps_unit_ver.unit_cd%TYPE,
    p_unit_version_number      IN            igs_ps_unit_ver.version_number%TYPE,
    p_teach_cal_type           IN            igs_ca_inst.cal_type%TYPE,
    p_teach_ci_sequence_number IN            igs_ca_inst.sequence_number%TYPE,
    p_stat_type                IN            igs_pr_stat_type.stat_type%TYPE,
    p_system_stat              IN            VARCHAR2,
    p_init_msg_list            IN            VARCHAR2,
    p_gpa_value                OUT NOCOPY    NUMBER,
    p_gpa_cp                   OUT NOCOPY    NUMBER,
    p_gpa_quality_points       OUT NOCOPY    NUMBER,
    p_return_status            OUT NOCOPY    VARCHAR2,
    p_msg_count                OUT NOCOPY    NUMBER,
    p_msg_data                 OUT NOCOPY    VARCHAR2,
    p_uoo_id                   IN            NUMBER,
    p_use_released_grade       IN            VARCHAR2) IS

--------------------------------------------------------------------------
--  Created By : Nishikant
--  Date Created On : 06-11-2001
--  Purpose:  To derive the GPA valua for a given Statistic Type for
--            a Student Unit Attempt.
--  Know limitations, enhancements or remarks
--  Change History
--  Who         When        What
-- swaghmar; 15-Sep-2005; Bug 4491456 - Modified the signature
--  ayedubat    24-1-2002   Changed the cursor c_sua_uv to consider
--                          the Student_career_statics overriden
--                          at the Student Unit Attempt Level
--  (reverse chronological order - newest change first)
--------------------------------------------------------------------------

    l_earned_cp          igs_ps_unit_ver.achievable_credit_points%TYPE;
    l_attempted_cp       igs_ps_unit_ver.achievable_credit_points%TYPE;
    l_gpa_cp             NUMBER;
    l_gpa_quality_points NUMBER;
    l_gpa_value          NUMBER;
    l_return_status      VARCHAR2(30);
    l_msg_count          NUMBER(2);
    l_msg_data           VARCHAR2(30);
    l_org_id             NUMBER(4);
  BEGIN
    l_org_id := igs_ge_gen_003.get_org_id;
    igs_ge_gen_003.set_org_id(l_org_id);

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Validate the Parameters, so that must not be NULL
    IF (p_person_id IS NULL
        OR p_course_cd IS NULL
        OR p_unit_cd IS NULL
        OR p_unit_version_number IS NULL
        OR p_teach_cal_type IS NULL
        OR p_teach_ci_sequence_number IS NULL) THEN
      fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAM_VAL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Call GET_SUA_ALL to calculate the GPA and CP values for the Student Unit
    -- Attempt
    get_sua_all(
      p_person_id,
      p_course_cd,
      p_unit_cd,
      p_unit_version_number,
      p_teach_cal_type,
      p_teach_ci_sequence_number,
      p_stat_type,
      p_system_stat,
      l_earned_cp,
      l_attempted_cp,
      l_gpa_value,
      l_gpa_cp,
      l_gpa_quality_points,
      fnd_api.g_true,
      l_return_status,
      l_msg_count,
      l_msg_data,
      p_uoo_id,
      p_use_released_grade);

    -- If any Error is occurred in get_cp procedure Then return.
    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      p_return_status := l_return_status;
      p_msg_count := l_msg_count;
      p_msg_data := l_msg_data;
      RETURN;
    END IF;

    -- Set out NOCOPY parameters
    p_gpa_value := l_gpa_value;
    p_gpa_cp := l_gpa_cp;
    p_gpa_quality_points := l_gpa_quality_points;
    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'GET_SUA_GPA: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
  END get_sua_gpa;

 --
 -- swaghmar; 15-Sep-2005; Bug 4491456
 --	Modified the signature
 --

  PROCEDURE get_all_stats(
    p_person_id                   IN         igs_en_stdnt_ps_att.person_id%TYPE ,
    p_course_cd                   IN         igs_en_stdnt_ps_att.course_cd%TYPE ,
    p_stat_type                   IN         igs_pr_stat_type.stat_type%TYPE ,
    p_load_cal_type               IN         igs_ca_inst.cal_type%TYPE ,
    p_load_ci_sequence_number     IN         igs_ca_inst.sequence_number%TYPE ,
    p_system_stat                 IN         VARCHAR2,
    p_cumulative_ind              IN         VARCHAR2,
    p_earned_cp                   OUT NOCOPY NUMBER,
    p_attempted_cp                OUT NOCOPY NUMBER,
    p_gpa_value                   OUT NOCOPY NUMBER,
    p_gpa_cp                      OUT NOCOPY NUMBER,
    p_gpa_quality_points          OUT NOCOPY NUMBER,
    p_init_msg_list               IN         VARCHAR2,
    p_return_status               OUT NOCOPY VARCHAR2,
    p_msg_count                   OUT NOCOPY NUMBER,
    p_msg_data                    OUT NOCOPY VARCHAR2,
    p_use_released_grade          IN         VARCHAR2) IS


    p_enrolled_cp    igs_pr_stu_acad_stat.gpa_quality_points%TYPE;
  BEGIN
    ----  This procedure is being stubbed for the time being to reduce the impact of change for
    ----  Bug 3843525
	get_all_stats_new(
	    p_person_id                   ,
	    p_course_cd                   ,
	    p_stat_type                   ,
	    p_load_cal_type               ,
	    p_load_ci_sequence_number     ,
	    p_system_stat                 ,
	    p_cumulative_ind              ,
	    p_earned_cp                   ,
	    p_attempted_cp                ,
	    p_gpa_value                   ,
	    p_gpa_cp                      ,
	    p_gpa_quality_points          ,
	    p_init_msg_list               ,
	    p_return_status               ,
	    p_msg_count                   ,
	    p_msg_data                    ,
	    p_use_released_grade          ,
	    p_enrolled_cp );

  END get_all_stats;

 --
 -- swaghmar; 15-Sep-2005; Bug 4491456
 --	Modified the signature
 --

  PROCEDURE get_all_stats_new(
    p_person_id                   IN         igs_en_stdnt_ps_att.person_id%TYPE ,
    p_course_cd                   IN         igs_en_stdnt_ps_att.course_cd%TYPE ,
    p_stat_type                   IN         igs_pr_stat_type.stat_type%TYPE ,
    p_load_cal_type               IN         igs_ca_inst.cal_type%TYPE ,
    p_load_ci_sequence_number     IN         igs_ca_inst.sequence_number%TYPE ,
    p_system_stat                 IN         VARCHAR2,
    p_cumulative_ind              IN         VARCHAR2,
    p_earned_cp                   OUT NOCOPY NUMBER,
    p_attempted_cp                OUT NOCOPY NUMBER,
    p_gpa_value                   OUT NOCOPY NUMBER,
    p_gpa_cp                      OUT NOCOPY NUMBER,
    p_gpa_quality_points          OUT NOCOPY NUMBER,
    p_init_msg_list               IN         VARCHAR2,
    p_return_status               OUT NOCOPY VARCHAR2,
    p_msg_count                   OUT NOCOPY NUMBER,
    p_msg_data                    OUT NOCOPY VARCHAR2,
    p_use_released_grade          IN         VARCHAR2,
    p_enrolled_cp                 OUT NOCOPY igs_pr_stu_acad_stat.gpa_quality_points%TYPE) IS

    -- Note param p_enrolled_cp  added for bug 3843525  jhanda
    /*
    ||==============================================================================||
    ||  Created By : Prajeesh Chandran                                              ||
    ||  Created On : 6-NOV-2001                                                     ||
    ||  Purpose : Gets the Cumulative CreditPoints or GPA                           ||
    ||  Known limitations, enhancements or remarks :                                ||
    ||  Change History :                                                            ||
    ||  Who      When        What                                                   ||
    ||  (reverse chronological order - newest change first)                         ||
    ||==============================================================================||
    ||  ayedubat    24-Jan-2002 Changed the cursor c_sua_uv to consider the         ||
    ||                       Student_career_statics overriden at the                ||
    ||                       Student Unit Attempt Level                             ||
    ||  kdande     20-Sep-2002 Bug# 2560160:Defaulted the p_init_msg_list parameter ||
    ||                       in the code since default value is removed from the    ||
    ||                       procedure signature.                                   ||
    ||==============================================================================||
    */

    -- Cursor to find the Student Unit Attempts for the Load Calendar
    --
    -- kdande; 23-Apr-2003; Bug# 2829262
    -- Added uoo_id field to the SELECT clause of cursor c_sua_uv
    --
    CURSOR c_sua_uv IS
	SELECT   sua.person_id,sua.course_cd, sua.unit_cd, sua.version_number, sua.cal_type, sua.ci_sequence_number,
		 sua.uoo_id ,sua.unit_attempt_status
	    FROM igs_en_su_attempt_ALL sua, igs_ca_inst ci1
	   WHERE sua.person_id = p_person_id
	     AND sua.course_cd = p_course_cd
	     AND sua.unit_attempt_status IN
				     ('COMPLETED', 'DUPLICATE', 'ENROLLED', 'DISCONTIN')
	     AND ci1.cal_type = sua.cal_type
	     AND ci1.sequence_number = sua.ci_sequence_number
	     AND (   (    p_cumulative_ind = 'N'
		      AND EXISTS ( SELECT 'X'
				     FROM igs_ca_load_to_teach_v ltt1
				    WHERE p_load_cal_type = ltt1.load_cal_type
				      AND p_load_ci_sequence_number =
							  ltt1.load_ci_sequence_number
				      AND sua.cal_type = ltt1.teach_cal_type
				      AND sua.ci_sequence_number =
							 ltt1.teach_ci_sequence_number)
		     )
		  OR (    p_cumulative_ind = 'Y'
		      AND EXISTS ( SELECT 'X'
				     FROM igs_ca_inst ci2, igs_ca_load_to_teach_v ltt2
				    WHERE ci2.cal_type = p_load_cal_type
				      AND ci2.sequence_number =
							     p_load_ci_sequence_number
				      AND sua.cal_type = ltt2.teach_cal_type
				      AND sua.ci_sequence_number =
							 ltt2.teach_ci_sequence_number
				      AND ltt2.load_end_dt <= ci2.end_dt)
		     )
		 )
	ORDER BY sua.unit_cd ASC, sua.ci_end_dt ASC;


    CURSOR c_sas(cp_stat_type igs_pr_stat_type.stat_type%TYPE) IS
      SELECT sas.earned_credit_points,
             sas.attempted_credit_points,
             sas.gpa,
             sas.gpa_credit_points,
             sas.gpa_quality_points
        FROM igs_pr_stu_acad_stat sas
       WHERE sas.person_id = p_person_id
         AND sas.course_cd = p_course_cd
         AND sas.cal_type = p_load_cal_type
         AND sas.ci_sequence_number = p_load_ci_sequence_number
         AND sas.stat_type = cp_stat_type
         AND ((sas.timeframe IN ('CUMULATIVE','BOTH') AND p_cumulative_ind = 'Y')
              OR (sas.timeframe IN ('PERIOD','BOTH') AND p_cumulative_ind = 'N'));

    lc_sua_uv            c_sua_uv%ROWTYPE;
    lc_sas               c_sas%ROWTYPE;
    l_earned_cp          NUMBER   := 0;
    l_attempted_cp       NUMBER   := 0;
    l_gpa_cp             NUMBER     := 0;
    l_gpa_quality_points NUMBER   := 0;
    l_earned_cp_total    NUMBER   := 0;
    l_attempted_cp_total NUMBER   := 0;
    l_gpa_cp_total       NUMBER   := 0;
    l_gpa_qp_total       NUMBER   := 0;
    l_gpa_value          NUMBER   := 0;
    l_stat_type          igs_pr_stat_type.stat_type%TYPE;
    l_org_unit_cd        igs_pr_org_stat.org_unit_cd%TYPE;
    l_include_std_ind    igs_pr_org_stat.include_standard_ind%TYPE;
    l_include_local_ind  igs_pr_org_stat.include_local_ind%TYPE;
    l_include_other_ind  igs_pr_org_stat.include_other_ind%TYPE;
    l_derivation         igs_pr_stat_type.derivation%TYPE;
    l_init_msg_list      VARCHAR2(20);
    l_return_status      VARCHAR2(30);
    l_msg_count          NUMBER(2);
    l_msg_data           VARCHAR2(30);
    l_org_id             NUMBER(4);
    l_enrolled_cp       igs_pr_stu_acad_stat.gpa_credit_points%TYPE   := 0;
    l_enrolled_cp_total  igs_ps_unit_ver.achievable_credit_points%TYPE   := 0;

    -- Added as part of fix for Bug# 5260180
    v_inc_exc_ul         VARCHAR2(1) := 'Y';
    v_inc_exc_sua        VARCHAR2(1) := 'Y';

  BEGIN
    l_org_id := igs_ge_gen_003.get_org_id;
    igs_ge_gen_003.set_org_id(l_org_id);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(NVL(p_init_msg_list, fnd_api.g_true)) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Validate the Parameters, so that must not be NULL
    IF (p_person_id IS NULL
        OR p_course_cd IS NULL
        OR p_load_cal_type IS NULL
        OR p_load_ci_sequence_number IS NULL) THEN
      fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAM_VAL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    p_gpa_value := NULL;
    p_gpa_cp := NULL;
    p_gpa_quality_points := NULL;
    p_attempted_cp := NULL;
    p_earned_cp := NULL;
    l_stat_type := p_stat_type;
    -- Call the Statistic Details Procedure to get the Statistic Details
    get_stat_dtls(
      p_person_id,
      p_course_cd,
      p_system_stat,
      p_cumulative_ind,
      l_stat_type,
      l_org_unit_cd,
      l_include_std_ind,
      l_include_local_ind,
      l_include_other_ind,
      l_derivation,
      fnd_api.g_true,
      l_return_status,
      l_msg_count,
      l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      p_gpa_value := NULL;
      p_gpa_cp := NULL;
      p_gpa_quality_points := NULL;
      p_earned_cp := NULL;
      p_attempted_cp := NULL;
      p_return_status := l_return_status;
      p_msg_count := l_msg_count;
      p_msg_data := l_msg_data;
      p_enrolled_cp := NULL;
      RETURN;
    END IF;

    -- If the Statistic Type is NULL then return the earned and attempted
    -- credit points as NULL
    IF l_stat_type IS NULL THEN
      p_gpa_value := NULL;
      p_gpa_cp := NULL;
      p_gpa_quality_points := NULL;
      p_earned_cp := NULL;
      p_attempted_cp := NULL;
      p_return_status := l_return_status;
      p_msg_count := l_msg_count;
      p_msg_data := l_msg_data;
      p_enrolled_cp := NULL;
      RETURN;
    END IF;

    -- If the Stat Type can be stored check for stored values.
    IF l_derivation IN ('STORED') THEN
      OPEN c_sas(l_stat_type);
      FETCH c_sas INTO lc_sas;

      IF c_sas%FOUND THEN
        CLOSE c_sas;
        -- Assign the returned values to the Output parameters
        p_earned_cp := lc_sas.earned_credit_points;
        p_attempted_cp := lc_sas.attempted_credit_points;
        p_gpa_value := lc_sas.gpa;
        p_gpa_cp := lc_sas.gpa_credit_points;
        p_gpa_quality_points := lc_sas.gpa_quality_points;
        -- Initialize API return status to success.
        p_return_status := fnd_api.g_ret_sts_success;
        -- Standard call to get message count and if count is 1, get message info
        fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false,
          p_count => p_msg_count,
          p_data => p_msg_data);
        RETURN;
      ELSE
        -- that is no value found for STORED stats
        -- set out params to NULL as per bug 3042490
        p_earned_cp           :=NULL;
        p_attempted_cp        :=NULL;
        p_gpa_value           :=NULL;
        p_gpa_cp              :=NULL;
        p_gpa_quality_points  :=NULL;

        -- Initialize API return status to success.
        p_return_status := fnd_api.g_ret_sts_success;
        -- Standard call to get message count and if count is 1, get message info
        fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false,
          p_count => p_msg_count,
          p_data => p_msg_data);

        RETURN;
      END IF;

      CLOSE c_sas;
    END IF;


    IF l_derivation IN ('BOTH') THEN
      OPEN c_sas(l_stat_type);
      FETCH c_sas INTO lc_sas;

      IF c_sas%FOUND THEN
        CLOSE c_sas;
        -- Assign the returned values to the Output parameters
        p_earned_cp := lc_sas.earned_credit_points;
        p_attempted_cp := lc_sas.attempted_credit_points;
        p_gpa_value := lc_sas.gpa;
        p_gpa_cp := lc_sas.gpa_credit_points;
        p_gpa_quality_points := lc_sas.gpa_quality_points;
        -- Initialize API return status to success.
        p_return_status := fnd_api.g_ret_sts_success;
        -- Standard call to get message count and if count is 1, get message info
        fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false,
          p_count => p_msg_count,
          p_data => p_msg_data);
        RETURN;
      END IF;

      CLOSE c_sas;
    END IF;


    -- Check for the Standard Indicator Flag then loop through Student Unit
    -- Attempts
    IF l_include_std_ind = 'Y' THEN
      -- Loop through all of the Student Unit Attempts records (SUA)
      FOR lc_sua_uv IN c_sua_uv LOOP
        -- Check if Unit Reference Code is included/excluded for this Stat Type
        IF chk_unit_ref_cd(
             lc_sua_uv.unit_cd,
             lc_sua_uv.version_number,
             l_org_unit_cd,
             l_stat_type,
             fnd_api.g_true,
             l_return_status,
             l_msg_count,
             l_msg_data) = 'Y' THEN
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            p_return_status := l_return_status;
            p_msg_count := l_msg_count;
            p_msg_data := l_msg_data;
            RETURN;
	  END IF;
        ELSE  -- Added as part of fix for Bug# 5260180
             v_inc_exc_ul := 'N';
             IF l_return_status <> fnd_api.g_ret_sts_success THEN
                p_return_status := l_return_status;
                p_msg_count := l_msg_count;
                p_msg_data := l_msg_data;
                RETURN;
             END IF;
        END IF;

        -- Calling the chk_sua_ref_cd() here and progress further only if the function returns 'Y'
        -- Check if Student Unit Attempt Reference Code is included/excluded for this Stat Type

        IF chk_sua_ref_cd(
             lc_sua_uv.person_id,
             lc_sua_uv.course_cd,
             lc_sua_uv.uoo_id,
             l_org_unit_cd,
             l_stat_type,
             fnd_api.g_true,
             l_return_status,
             l_msg_count,
             l_msg_data) = 'Y' THEN
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            p_return_status := l_return_status;
            p_msg_count := l_msg_count;
            p_msg_data := l_msg_data;
            RETURN;
	    END IF;
         ELSE -- Added as part of fix for Bug# 5260180
             v_inc_exc_sua := 'N';
             IF l_return_status <> fnd_api.g_ret_sts_success THEN
               p_return_status := l_return_status;
               p_msg_count := l_msg_count;
               p_msg_data := l_msg_data;
               RETURN;
             END IF;
        END IF;
          -- Call GET_SUA_STATS to calculate the GPA and CP values for the
          -- Student Unit Attempt
          IF (v_inc_exc_sua = 'Y' OR v_inc_exc_ul = 'Y') THEN -- Added as part of fix for Bug# 5260180
	  get_sua_stats(
            p_person_id,
            p_course_cd,
            lc_sua_uv.unit_cd,
            lc_sua_uv.version_number,
            lc_sua_uv.cal_type,
            lc_sua_uv.ci_sequence_number,
            l_earned_cp,
            l_attempted_cp,
            l_gpa_value,
            l_gpa_cp,
            l_gpa_quality_points,
            fnd_api.g_true,
            l_return_status,
            l_msg_count,
            l_msg_data,
            lc_sua_uv.uoo_id,
            p_use_released_grade,
	    l_enrolled_cp);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            p_gpa_value := NULL;
            p_gpa_cp := NULL;
            p_gpa_quality_points := NULL;
            p_earned_cp := NULL;
            p_attempted_cp := NULL;
            p_return_status := l_return_status;
            p_msg_count := l_msg_count;
            p_msg_data := l_msg_data;
            RETURN;
          END IF;

          --Total the Credit Points for all the Student Unit Attempts.
          l_attempted_cp_total := l_attempted_cp_total + NVL(l_attempted_cp, 0);
          l_earned_cp_total := l_earned_cp_total + NVL(l_earned_cp, 0);
          l_gpa_cp_total := l_gpa_cp_total + NVL(l_gpa_cp, 0);
          l_gpa_qp_total := l_gpa_qp_total + NVL(l_gpa_quality_points, 0);
	  IF lc_sua_uv.unit_attempt_status = 'ENROLLED' THEN
         	  l_enrolled_cp_total := l_enrolled_cp_total +  NVL(l_enrolled_cp,0);
	  END IF;
    --    END IF;
        END IF;
      END LOOP;
    END IF;
    -- Check the flag for Advanced Standing then call the Advanced Standing
    -- Procedure
    IF l_include_local_ind = 'Y'
       OR l_include_other_ind = 'Y' THEN
      get_adv_stats(
        p_person_id,
        p_course_cd,
        l_stat_type,
        l_org_unit_cd,
        p_load_cal_type,
        p_load_ci_sequence_number,
        p_cumulative_ind,
        l_include_local_ind,
        l_include_other_ind,
        l_earned_cp,
        l_attempted_cp,
        l_gpa_cp,
        l_gpa_quality_points,
        fnd_api.g_true,
        l_return_status,
        l_msg_count,
        l_msg_data);
      --Total the Credit Points for all the Student Unit Attempts.
      l_attempted_cp_total := l_attempted_cp_total + NVL(l_attempted_cp, 0);
      l_earned_cp_total := l_earned_cp_total + NVL(l_earned_cp, 0);
      l_gpa_cp_total := l_gpa_cp_total + NVL(l_gpa_cp, 0);
      l_gpa_qp_total := l_gpa_qp_total + NVL(l_gpa_quality_points, 0);
    END IF;

    -- Calculate the GPA Value
    IF NVL(l_gpa_cp_total, 0) > 0 THEN
      l_gpa_value := l_gpa_qp_total / l_gpa_cp_total;
    END IF;

    -- Assign the Output parameters
    p_gpa_value := l_gpa_value;
    p_gpa_cp := l_gpa_cp_total;
    p_gpa_quality_points := l_gpa_qp_total;
    p_attempted_cp := l_attempted_cp_total;
    p_earned_cp := l_earned_cp_total;
    p_enrolled_cp :=l_enrolled_cp_total;
    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message
    -- info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'GET_ALL_STATS: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
  END get_all_stats_new;
  --
  -- swaghmar; 15-Sep-2005; Bug 4491456
  --	Modified the signature
  --
  PROCEDURE get_cp_stats(
    p_person_id               IN         igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd               IN         igs_en_stdnt_ps_att.course_cd%TYPE,
    p_stat_type               IN         igs_pr_stat_type.stat_type%TYPE,
    p_load_cal_type           IN         igs_ca_inst.cal_type%TYPE,
    p_load_ci_sequence_number IN         igs_ca_inst.sequence_number%TYPE,
    p_system_stat             IN         VARCHAR2,
    p_cumulative_ind          IN         VARCHAR2,
    p_earned_cp               OUT NOCOPY NUMBER,
    p_attempted_cp            OUT NOCOPY NUMBER,
    p_init_msg_list           IN         VARCHAR2,
    p_return_status           OUT NOCOPY VARCHAR2,
    p_msg_count               OUT NOCOPY NUMBER,
    p_msg_data                OUT NOCOPY VARCHAR2,
    p_use_released_grade      IN         VARCHAR2) IS
    /*
    ||  Created By : Prajeesh Chandran
    ||  Created On : 6-NOV-2001
    ||  Purpose : Main Procedure for Credit Point Calculation
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    l_earned_cp          NUMBER   := 0;
    l_attempted_cp       NUMBER   := 0;
    l_gpa_value          NUMBER   := 0;
    l_gpa_cp             NUMBER   := 0;
    l_gpa_quality_points NUMBER   := 0;
    l_return_status      VARCHAR2(30);
    l_msg_count          NUMBER(2);
    l_msg_data           VARCHAR2(30);
    l_org_id             NUMBER(4);
  BEGIN
    l_org_id := igs_ge_gen_003.get_org_id;
    igs_ge_gen_003.set_org_id(l_org_id);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Validate the Parameters, so that must not be NULL
    IF (p_person_id IS NULL
        OR p_course_cd IS NULL
        OR p_load_cal_type IS NULL
        OR p_load_ci_sequence_number IS NULL) THEN
      fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAM_VAL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Call GET_ALL_STATS to calculate the GPA and CP values for the Student
    -- Unit Attempt
    get_all_stats(
      p_person_id               => p_person_id,
      p_course_cd               => p_course_cd,
      p_stat_type               => p_stat_type,
      p_load_cal_type           => p_load_cal_type,
      p_load_ci_sequence_number => p_load_ci_sequence_number,
      p_system_stat             => p_system_stat,
      p_cumulative_ind          => p_cumulative_ind,
      p_earned_cp               => l_earned_cp,
      p_attempted_cp            => l_attempted_cp,
      p_gpa_value               => l_gpa_value,
      p_gpa_cp                  => l_gpa_cp,
      p_gpa_quality_points      => l_gpa_quality_points,
      p_init_msg_list           => p_init_msg_list,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data,
      p_use_released_grade      => p_use_released_grade);

    -- If any Error is occurred in get_cp procedure Then return.
    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      p_return_status := l_return_status;
      p_msg_count := l_msg_count;
      p_msg_data := l_msg_data;
      RETURN;
    END IF;

    -- Set out NOCOPY parameters
    p_earned_cp := l_earned_cp;
    p_attempted_cp := l_attempted_cp;
    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'GET_CP_STATS: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
  END get_cp_stats;

  PROCEDURE get_gpa_stats(
    p_person_id               IN         igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd               IN         igs_en_stdnt_ps_att.course_cd%TYPE,
    p_stat_type               IN         igs_pr_stat_type.stat_type%TYPE,
    p_load_cal_type           IN         igs_ca_inst.cal_type%TYPE,
    p_load_ci_sequence_number IN         igs_ca_inst.sequence_number%TYPE,
    p_system_stat             IN         VARCHAR2,
    p_cumulative_ind          IN         VARCHAR2,
    p_gpa_value               OUT NOCOPY NUMBER,
    p_gpa_cp                  OUT NOCOPY NUMBER,
    p_gpa_quality_points      OUT NOCOPY NUMBER,
    p_init_msg_list           IN         VARCHAR2,
    p_return_status           OUT NOCOPY VARCHAR2,
    p_msg_count               OUT NOCOPY NUMBER,
    p_msg_data                OUT NOCOPY VARCHAR2,
    p_use_released_grade      IN         VARCHAR2) IS
    /*
    ||  Created By : Prajeesh Chandran
    ||  Created On : 6-NOV-2001
    ||  Purpose : Main Procedure for GPA
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  swaghmar 15-Sep-2005 Bug 4491456 Modified the signature
    */

    l_earned_cp          NUMBER   := 0;
    l_attempted_cp       NUMBER   := 0;
    l_gpa_value          NUMBER   := 0;
    l_gpa_cp             NUMBER   := 0;
    l_gpa_quality_points NUMBER   := 0;
    l_return_status      VARCHAR2(30);
    l_msg_count          NUMBER(2);
    l_msg_data           VARCHAR2(30);
    l_org_id             NUMBER(4);
  BEGIN
    l_org_id := igs_ge_gen_003.get_org_id;
    igs_ge_gen_003.set_org_id(l_org_id);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Validate the Parameters, so that must not be NULL
    IF (p_person_id IS NULL
        OR p_course_cd IS NULL
        OR p_load_cal_type IS NULL
        OR p_load_ci_sequence_number IS NULL) THEN
      fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAM_VAL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Call GET_ALL_STATS to calculate the GPA and CP values for the
    -- Student Unit Attempt
    get_all_stats(
      p_person_id               => p_person_id,
      p_course_cd               => p_course_cd,
      p_stat_type               => p_stat_type,
      p_load_cal_type           => p_load_cal_type,
      p_load_ci_sequence_number => p_load_ci_sequence_number,
      p_system_stat             => p_system_stat,
      p_cumulative_ind          => p_cumulative_ind,
      p_earned_cp               => l_earned_cp,
      p_attempted_cp            => l_attempted_cp,
      p_gpa_value               => l_gpa_value,
      p_gpa_cp                  => l_gpa_cp,
      p_gpa_quality_points      => l_gpa_quality_points,
      p_init_msg_list           => p_init_msg_list,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data,
      p_use_released_grade      => p_use_released_grade);

    -- If any Error is occurred in get_cp procedure Then return.
    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      p_return_status := l_return_status;
      p_msg_count := l_msg_count;
      p_msg_data := l_msg_data;
      RETURN;
    END IF;

    -- Set out NOCOPY parameters
    p_gpa_value := to_number(to_char(l_gpa_value,'99D999'));
    p_gpa_cp := l_gpa_cp;
    p_gpa_quality_points := l_gpa_quality_points;
    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'GET_GPA_STATS: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
  END get_gpa_stats;

--
-- swaghmar; 24-Jun-2005; Bug# 4327987
-- Added chk_sua_ref_cd function
--

  FUNCTION chk_sua_ref_cd(
    P_person_id IN igs_en_su_attempt_ALL.person_id%TYPE,
    P_course_cd IN igs_en_su_attempt_ALL.course_cd%TYPE,
    P_uoo_id IN  NUMBER,
    p_org_unit_cd         IN            igs_pr_org_stat.org_unit_cd%TYPE,
    p_stat_type           IN            igs_pr_stat_type.stat_type%TYPE,
    p_init_msg_list       IN            VARCHAR2,
    p_return_status       OUT NOCOPY    VARCHAR2,
    p_msg_count           OUT NOCOPY    NUMBER,
    p_msg_data            OUT NOCOPY    VARCHAR2)
    RETURN VARCHAR2 AS

    CURSOR c_org_setup IS
      SELECT ostr1.include_or_exclude
        FROM igs_pr_org_stat_ref ostr1
       WHERE ostr1.stat_type = p_stat_type AND ostr1.org_unit_cd = p_org_unit_cd;

    CURSOR c_org_included IS
      SELECT 'X'
        FROM igs_as_sua_ref_cds urc,
             igs_ge_ref_cd_type rct
       WHERE urc.person_id = p_person_id
       AND   urc.uoo_id = p_uoo_id
       AND   urc.course_cd = p_course_cd
         AND urc.reference_cd_type = rct.reference_cd_type
	 AND   urc.deleted_date IS NULL
         AND rct.s_reference_cd_type = 'STATS'
         AND EXISTS (
               SELECT 'X'
                 FROM igs_pr_org_stat_ref ostr1
                WHERE ostr1.stat_type = p_stat_type
                  AND ostr1.org_unit_cd = p_org_unit_cd
                  AND ostr1.unit_ref_cd = urc.reference_cd
                  AND ostr1.include_or_exclude = 'INCLUDE');


    CURSOR c_org_excluded IS
      SELECT 'X'
        FROM igs_as_sua_ref_cds urc, igs_ge_ref_cd_type rct
        WHERE urc.person_id = p_person_id
        AND   urc.uoo_id = p_uoo_id
        AND   urc.course_cd = p_course_cd
        AND urc.reference_cd_type = rct.reference_cd_type
	AND   urc.deleted_date IS NULL
        AND rct.s_reference_cd_type = 'STATS'
        AND EXISTS( SELECT 'X'
                       FROM igs_pr_org_stat_ref ostr1
                      WHERE ostr1.stat_type = p_stat_type
                        AND ostr1.org_unit_cd = p_org_unit_cd
                        AND ostr1.unit_ref_cd = urc.reference_cd
                        AND ostr1.include_or_exclude = 'EXCLUDE');

    CURSOR c_inst_setup IS
      SELECT INSTR.include_or_exclude
        FROM igs_pr_inst_sta_ref INSTR
       WHERE INSTR.stat_type = p_stat_type;

    CURSOR c_inst_included IS
      SELECT 'X'
        FROM igs_as_sua_ref_cds urc, igs_ge_ref_cd_type rct
       WHERE urc.person_id = p_person_id
       AND   urc.uoo_id = p_uoo_id
       AND   urc.course_cd = p_course_cd
         AND urc.reference_cd_type = rct.reference_cd_type
	 AND   urc.deleted_date IS NULL
         AND rct.s_reference_cd_type = 'STATS'
         AND EXISTS( SELECT 'X'
                       FROM igs_pr_inst_sta_ref instr1
                      WHERE instr1.stat_type = p_stat_type
                        AND instr1.unit_ref_cd = urc.reference_cd
                        AND instr1.include_or_exclude = 'INCLUDE');


    CURSOR c_inst_excluded IS
      SELECT 'X'
        FROM igs_as_sua_ref_cds src, igs_ge_ref_cd_type rct
       WHERE src.person_id = p_person_id
       AND   src.uoo_id = p_uoo_id
       AND   src.course_cd = p_course_cd
         AND src.reference_cd_type = rct.reference_cd_type
	 AND   src.deleted_date IS NULL
         AND rct.s_reference_cd_type = 'STATS'
         AND EXISTS( SELECT 'X'
                       FROM igs_pr_inst_sta_ref instr1
                      WHERE instr1.stat_type = p_stat_type
                        AND instr1.unit_ref_cd = src.reference_cd
                        AND instr1.include_or_exclude = 'EXCLUDE');

    l_include_or_exclude VARCHAR2(20);
    l_include            VARCHAR2(1);
    l_dummy              VARCHAR2(1);
    l_message            VARCHAR2(1000);
  BEGIN
    l_include := 'Y';
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(NVL(p_init_msg_list, fnd_api.g_true)) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- The following parameters should not be null
    IF (p_person_id IS NULL
        OR p_uoo_id IS NULL
        OR p_course_cd IS NULL
        OR p_stat_type IS NULL) THEN
      l_message := 'IGS_GE_INSUFFICIENT_PARAM_VAL';
      fnd_message.set_name('IGS', l_message);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- If the Organizational Unit is not null then statistic type is
    -- defined at Organizational level.  Check if any unit reference
    -- codes are included or excluded at Org level.
    IF p_org_unit_cd IS NOT NULL THEN
      -- When no Unit Reference Codes are specifically included or excluded, all
      -- units should be included.
      OPEN c_org_setup;
      FETCH c_org_setup INTO l_include_or_exclude;

      IF (c_org_setup%FOUND) THEN
        IF (l_include_or_exclude = 'INCLUDE') THEN

        -- When Unit Reference Codes are specifically included then only those
        -- units with the included Unit Refernce Code should be included
        OPEN c_org_included;
          FETCH c_org_included INTO l_dummy;

          IF (c_org_included%NOTFOUND) THEN
            l_include := 'N';
          END IF;
          CLOSE c_org_included;

        ELSE
        -- When Unit Reference Codes are specifically excluded all units Except
        -- those units with the excluded Unit Refernce Code should be included
          OPEN c_org_excluded;
          FETCH c_org_excluded INTO l_dummy;

          IF (c_org_excluded%FOUND) THEN
            l_include := 'N';
          END IF;
          CLOSE c_org_excluded;
        END IF;
      END IF;

      CLOSE c_org_setup;
    -- If the Organizational Unit is null then statistic type must be
    -- defined at Institution level.  Check if any unit reference
    -- codes are included or excluded at Inst level.
    ELSE
      -- When no Unit Reference Codes are specifically included or excluded all
      -- units should be included.
      OPEN c_inst_setup;
      FETCH c_inst_setup INTO l_include_or_exclude;

      IF (c_inst_setup%FOUND) THEN
        IF (l_include_or_exclude = 'INCLUDE') THEN
          -- When Unit Reference Codes are specifically included then only those
          -- units with the included Unit Refernce Code should be included
          OPEN c_inst_included;
          FETCH c_inst_included INTO l_dummy;

          IF (c_inst_included%NOTFOUND) THEN
            l_include := 'N';
          END IF;

          CLOSE c_inst_included;
        ELSE
          -- When Unit Reference Codes are specifically excluded all units except
          -- those units with the excluded Unit Refernce Code should be included
          OPEN c_inst_excluded;
          FETCH c_inst_excluded INTO l_dummy;

          IF (c_inst_excluded%FOUND) THEN
            l_include := 'N';
          END IF;

          CLOSE c_inst_excluded;
        END IF;
      END IF;

      CLOSE c_inst_setup;
    END IF;

    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => p_msg_count,
      p_data => p_msg_data);
    RETURN l_include;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
      RETURN NULL;
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
      RETURN NULL;
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME', 'chk_sua_ref_cd: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => p_msg_count,
        p_data => p_msg_data);
     RETURN NULL;
    END chk_sua_ref_cd;
END igs_pr_cp_gpa;

/
