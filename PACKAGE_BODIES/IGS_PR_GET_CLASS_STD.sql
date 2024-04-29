--------------------------------------------------------
--  DDL for Package Body IGS_PR_GET_CLASS_STD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_GET_CLASS_STD" AS
/* $Header: IGSPR28B.pls 120.2 2006/04/29 02:27:11 swaghmar ship $ */

----------------------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- ddey     27-Oct-2003       Changes are done, so that the message stack is not initilized.(Bug # 3163305)
  --                            In the function Get_Class_Standing an extra parameter 'p_init_msg_list' is added.
  --prchandr    08-Jan-01       Enh Bug No: 2174101, As the Part of Change in IGSEN18B
  --                            Passing NULL as parameters  to ENRP_CLC_SUA_EFTSU
  --                            ENRP_CLC_EFTSU_TOTAL for Key course cd and version number
  --ptandon     20-Nov-03       Modified cursor c_spa in Function Get_Class_Standing to consider
  --                            class standing in term records table as per Term Based Fee Calc build.
  --                            Enh. Bug# 2829263.
  --swaghmar	15-Sep-2005	Bug# 4491456 Changed datatypes for l_gpa_value, l_gpa_cp, l_gpa_quality_points
  --swaghmar	25-Apr-2006	Bug# 5171158 Enabled FND Logging and added call to user hook procedure
  --				for the customers to customize the derivation of class standing
  ----------------------------------------------------------------------------------------------------------------
FUNCTION  Get_Class_Standing(
   p_PERSON_ID IN NUMBER,
   p_COURSE_CD IN VARCHAR2,
   p_Predictive_ind  IN VARCHAR2 DEFAULT 'N',
   p_Effective_dt IN DATE,
   p_Load_Cal_type IN VARCHAR2,
   p_Load_Ci_Sequence_Number IN NUMBER,
   p_init_msg_list  IN VARCHAR2 DEFAULT FND_API.G_FALSE
 )
 RETURN VARCHAR2 IS
   /* Define the required local variables */
   l_igs_pr_class_std_id        igs_pr_class_std.igs_pr_class_std_id%TYPE;
   l_igs_pr_cs_schdl_id         igs_pr_cs_schdl.igs_pr_cs_schdl_id%TYPE;
   l_consider_changes           igs_pr_cs_schdl.consider_changes%TYPE;
   l_class_standing_override    igs_pr_class_std.class_standing%TYPE;
   l_min_cp_count               igs_pr_css_class_std.min_cp%TYPE;
   l_acad_year_count            igs_pr_css_class_std.acad_year%TYPE;
   l_acad_year                  igs_pr_css_class_std.acad_year%TYPE;
   l_class_standing             igs_pr_class_std.class_standing%TYPE;
   l_cp                         igs_pr_css_class_std.min_cp%TYPE;
   l_dummy                      igs_pr_css_class_std.min_cp%TYPE;
   l_enrolled_cp                igs_pr_css_class_std.min_cp%TYPE;
   l_acad_cal_type              igs_ca_inst.cal_type%TYPE;
   l_acad_ci_sequence_number    igs_ca_inst.sequence_number%TYPE;
   l_Load_Cal_type              igs_ca_inst.cal_type%TYPE;
   l_Load_Ci_Sequence_Number    igs_ca_inst.sequence_number%TYPE;
   l_effective_dt               igs_pr_cs_schdl.start_dt%TYPE;
   l_earned_cp                  NUMBER;
   l_attempted_cp               NUMBER;
   l_return_status              VARCHAR2(100);
   l_msg_count                  NUMBER(6);
   l_msg_data                   VARCHAR2(1000);

   /* added jhanda bug 3843525 */
   l_gpa_value                  NUMBER;
   l_gpa_cp                     NUMBER;
   l_gpa_quality_points         NUMBER;

   l_flag	VARCHAR2(1);

    /* Cursor to get the Student Program Attempt and Class Standing Details */
    CURSOR c_spa IS
          SELECT  NVL(spat.class_standing_id,spa.igs_pr_class_std_id) igs_pr_class_std_id,
                  css.igs_pr_cs_schdl_id,
                  css.consider_changes
          FROM    IGS_EN_STDNT_PS_ATT             spa,
                  IGS_PS_VER                      pv,
                  IGS_PS_TYPE                     pt,
                  IGS_PR_CS_SCHDL                 css,
                  IGS_EN_SPA_TERMS                spat
          WHERE   spa.person_id = p_person_id
          AND     spa.course_cd = p_course_cd
          AND     spa.course_cd = pv.course_cd
          AND     spa.version_number = pv.version_number
          AND     spa.course_attempt_status IN
                     ('ENROLLED','COMPLETED','INTERMIT','INACTIVE')
          AND     pv.course_type = pt.course_type
          AND     pt.course_type = css.course_type (+)
          AND     TRUNC(css.start_dt (+) ) <= TRUNC(SYSDATE)
          AND     TRUNC(NVL(css.end_dt (+),SYSDATE) ) >= TRUNC(SYSDATE)
          AND     spat.person_id(+) = spa.person_id
          AND     spat.program_cd(+) = spa.course_cd
          AND     spat.term_cal_type(+) = p_load_cal_type
          AND     spat.term_sequence_number(+) = p_load_ci_sequence_number;

        /* Cursor to get the class standing overriden value */

         CURSOR C_cs_override(cp_igs_pr_class_std_id igs_pr_class_std.igs_pr_class_std_id%TYPE ) IS
                SELECT  class_standing
                FROM    igs_pr_class_std
                WHERE   igs_pr_class_std_id = cp_igs_pr_class_std_id;


        /* Cursors to get the class standing calculation method */
        CURSOR C_cs_min_cp(cp_igs_pr_cs_schdl_id igs_pr_cs_schdl.igs_pr_cs_schdl_id%TYPE ) IS
                SELECT  COUNT(*)
                FROM    igs_pr_css_class_std
                WHERE   igs_pr_cs_schdl_id = cp_igs_pr_cs_schdl_id
                AND     min_cp IS NOT NULL;
        CURSOR C_cs_acad_yr(cp_igs_pr_cs_schdl_id igs_pr_cs_schdl.igs_pr_cs_schdl_id%TYPE ) IS
                SELECT  COUNT(*)
                FROM    igs_pr_css_class_std
                WHERE   igs_pr_cs_schdl_id = cp_igs_pr_cs_schdl_id
                AND     acad_year IS NOT NULL;

      /* Cursor to get the academic year method details with load deatils */
      CURSOR C_acad_year (cp_load_cal_type igs_ca_inst.cal_type%TYPE,
                          cp_load_ci_sequence_number igs_ca_inst.sequence_number%TYPE ) IS
        SELECT  COUNT(*)
        FROM    igs_ca_type     ct1,
                igs_ca_inst ci1
        WHERE   ct1.s_cal_cat = 'ACADEMIC'
        AND     ct1.cal_type = ci1.cal_type
        AND     0  < (SELECT   COUNT(*)
                     FROM    igs_ca_inst     ci2a,
                             igs_ca_inst     ci2b,
                             igs_ca_type     ct2,
                             igs_ca_inst_rel cir2
                     WHERE   ci2a.cal_type = cp_load_cal_type
                     AND     ci2a.sequence_number = cp_load_ci_sequence_number
                     AND     TRUNC(ci2a.end_dt) >= TRUNC(ci2b.end_dt)
                     AND     cir2.sub_cal_type = ci2b.cal_type
                     AND     cir2.sub_ci_sequence_number = ci2b.sequence_number
                     AND     cir2.sup_cal_type = ci1.cal_type
                     AND     cir2.sup_ci_sequence_number = ci1.sequence_number
                     AND     ci2b.cal_type = ct2.cal_type
                     AND     ct2.s_cal_cat = 'LOAD')
                     AND     0 < (SELECT        COUNT(*)
                                 FROM  igs_en_su_attempt       sua3,
                                       igs_ca_inst_rel cir3
                                 WHERE sua3.person_id = p_person_id
                                 AND     sua3.course_cd = p_course_cd
                                 AND     sua3.unit_attempt_status NOT IN
                                                ('UNCONFIRM', 'DROPPED','DISCONTIN', 'WAITLISTED')
                                 AND     sua3.cal_type = cir3.sub_cal_type
                                 AND     sua3.ci_sequence_number = cir3.sub_ci_sequence_number
                                 AND     cir3.sup_cal_type = ci1.cal_type
                                 AND     cir3.sup_ci_sequence_number = ci1.sequence_number);

    /* Cursor to  Select Class Standing matching the Period Range */
        CURSOR C_Get_Cs_for_acad_yr(cp_igs_pr_cs_schdl_id   igs_pr_cs_schdl.igs_pr_cs_schdl_id%TYPE,
                                    cp_acad_year   igs_pr_css_class_std.acad_year%TYPE ) IS
                SELECT  ipcs.class_standing
                FROM    igs_pr_css_class_std    ipccs,
                        igs_pr_class_std                ipcs
                WHERE   ipccs.igs_pr_cs_schdl_id = cp_igs_pr_cs_schdl_id
                AND     ipccs.acad_year = cp_acad_year
                AND     ipccs.igs_pr_class_std_id = ipcs.igs_pr_class_std_id;

   /* Cursor to Get the details of the most recent load calendar attempted */
      CURSOR c_load_ci (cp_consider_changes  IGS_PR_CS_SCHDL.consider_changes%TYPE) IS
             SELECT  ci.cal_type,
                     ci.sequence_number
             FROM    igs_ca_type ct,
                     igs_ca_inst ci
             WHERE   ct.s_cal_cat = 'LOAD'
             AND     ct.cal_type = ci.cal_type
             AND     ((cp_consider_changes = 'IMMEDIATELY'
             AND       ((TRUNC(ci.start_dt) <= TRUNC(NVL(p_effective_dt, SYSDATE))
             AND         p_load_cal_type IS NULL)
             OR         (ci.cal_type = p_load_cal_type
             AND         ci.sequence_number = p_load_ci_sequence_number
             AND         p_load_cal_type IS NOT NULL)))
             OR       (cp_consider_changes = 'BYPERIOD'
             AND       (TRUNC(ci.end_dt) <= TRUNC(NVL(p_effective_dt, SYSDATE))
             OR         (p_load_cal_type IS NOT NULL
             AND         ci.cal_type = p_load_cal_type
             AND         ci.sequence_number = p_load_ci_sequence_number
             AND         TRUNC(ci.end_dt) <= TRUNC(SYSDATE)))))
            ORDER BY ci.end_dt DESC;

  /* Cursor to Get the academic calendar superior to the load calendar provided  */
        CURSOR C_Get_acad_cal(cp_load_cal_type igs_ca_inst.cal_type%TYPE,
                              cp_load_ci_sequence_number igs_ca_inst.sequence_number%TYPE ) IS
                SELECT  sup_cal_type,
                        sup_ci_sequence_number
                FROM    igs_ca_type     ct,
                        igs_ca_inst_rel cir
                WHERE   cir.sub_cal_type = cp_load_cal_type
                AND     cir.sub_ci_sequence_number = cp_load_ci_sequence_number
                AND     cir.sup_cal_type = ct.cal_type
                AND     ct.s_cal_cat = 'ACADEMIC';

  /*Cursor to SELECT Class Standing matching the CP RANGE */
    CURSOR C_Get_cs_cp_range( cp_igs_pr_cs_schdl_id igs_pr_cs_schdl.igs_pr_cs_schdl_id%TYPE,
                              cp_cp  igs_pr_css_class_std.min_cp%TYPE )  IS
         SELECT ipcs.class_standing
         FROM   igs_pr_css_class_std    ipccs,
                igs_pr_class_std            ipcs
         WHERE  ipccs.igs_pr_cs_schdl_id = cp_igs_pr_cs_schdl_id
         AND    ipccs.min_cp <= cp_cp
         AND    ipccs.max_cp >= cp_cp
         AND    ipccs.igs_pr_class_std_id = ipcs.igs_pr_class_std_id;

BEGIN

l_flag := IGS_PR_USER_CLASS_STD.customized_class_standing_flag;

/**
*  Logging all params
*/
IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
fnd_log.string ( fnd_log.level_procedure,
		'igs.plsql.igs_pr_get_class_std.get_class_standing' ||  '.begin',
		'Params: p_person_id  => '||p_person_id|| ';' ||
		' p_course_cd  => '||p_course_cd|| ';' ||
		' p_predictive_ind  => '||p_predictive_ind|| ';' ||
		' p_effective_dt  => '||p_effective_dt|| ';' ||
		' p_load_cal_type  => '||p_load_cal_type|| ';' ||
		' p_load_ci_sequence_number  => '||p_load_ci_sequence_number|| ';' ||
		' p_init_msg_list  => '||p_init_msg_list|| ';'
	     );
END IF;

/**
*  Logging for validating whether or not class standing calculation is
* customized
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'Customization Flag => '||l_flag
		);
END IF;

    IF (l_flag = 'Y')
      THEN                                   -- For Customized Class Standing
         /* For customized class standing, calling the customized procedure*/
	 l_class_standing :=
            IGS_PR_USER_CLASS_STD.get_customized_class_std
                                                  (p_person_id,
                                                   p_course_cd,
                                                   p_predictive_ind,
                                                   p_effective_dt,
                                                   p_load_cal_type,
                                                   p_load_ci_sequence_number,
                                                   p_init_msg_list
                                                  );
         /**
         * Customized Class Standing outcome
         */
	 RETURN l_class_standing;

      ELSE                                -- For Non Customized Class Standing
    /* Validate Parameters*/
    IF p_person_id IS NULL OR p_course_cd IS NULL THEN
        RETURN NULL;
    END IF;
    /* both load calendar attributes should be specified or both should be null */
    IF ( p_load_cal_type IS NOT NULL AND p_load_ci_sequence_number IS NULL ) OR
       ( p_load_cal_type IS NULL AND p_load_ci_sequence_number IS NOT NULL ) OR
       ( p_predictive_ind NOT IN ('Y','N' ) ) THEN
/**
*  Logging Load Calendar Set-Up
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
	'igs.plsql.igs_pr_get_class_std.get_class_standing',
	'Load Calendar attributes not set up properly'
	);
END IF;
        RETURN NULL;
    END IF;
    /*if load calendar attributes and effective dates are passed then return null */
    IF ( p_load_cal_type IS NOT NULL AND p_load_ci_sequence_number IS NOT NULL AND
         p_effective_dt IS NOT NULL )  THEN
/**
*  Logging -
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'Both load Calendar attributes and effective dates are passed, hence exiting'
		);
END IF;
         RETURN NULL;
    END IF;
    /* Get Student Program Attempt and Program Type details*/
    OPEN    c_spa;
    FETCH   c_spa INTO l_igs_pr_class_std_id,
                       l_igs_pr_cs_schdl_id,
                       l_consider_changes;
/**
*  Logging - l_igs_pr_class_std_id, l_igs_pr_cs_schdl_id, l_consider_changes
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'Student Program Attempt and Program Type details - '||
		'l_igs_pr_class_std_id => '||l_igs_pr_class_std_id||';'||
		'l_igs_pr_cs_schdl_id => '||l_igs_pr_cs_schdl_id||';'||
		'l_onsider_changes => '||l_consider_changes||';'
		);
END IF;
    CLOSE c_spa;
    /* Is the Class Standing Override values set*/
    IF l_igs_pr_class_std_id IS NOT NULL THEN
        OPEN  C_cs_override(l_igs_pr_class_std_id);
        FETCH C_cs_override INTO   l_class_standing_override;
        CLOSE C_cs_override;
/**
*  Logging - l_class_standing_override
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'Class Standing Override values set => '||l_class_standing_override
		);
END IF;
        RETURN l_class_standing_override;
    ELSIF l_igs_pr_cs_schdl_id IS NULL OR l_consider_changes IS NULL THEN
        /* Return Null if the class standing setup is not done */
/**
*  Logging -
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'Class Standing setup is not done, hence exiting'
		);
END IF;
        RETURN NULL;
    END IF;
    /* Determine the correct Load Calendar */
    OPEN   c_load_ci (l_consider_changes);
    FETCH  c_load_ci
           INTO   l_load_cal_type,
                  l_load_ci_sequence_number;
    IF c_load_ci%NOTFOUND THEN
        /* If no Load Calendars are found assume student is a new enrolment */
        l_acad_year := 1;
        l_cp := 0;
    END IF;
    CLOSE  c_load_ci;
    /* Determine the Class Standing calculation method
    A Program Type Class Standing Schedule cannot have child records
    with both start and end cp values and academic year values set. */
    OPEN    C_cs_min_cp(l_igs_pr_cs_schdl_id);
    FETCH   C_cs_min_cp INTO  l_min_cp_count;
    CLOSE   C_cs_min_cp;
    OPEN   C_cs_acad_yr(l_igs_pr_cs_schdl_id);
    FETCH  C_cs_acad_yr INTO  l_acad_year_count;
    CLOSE  C_cs_acad_yr;
    IF NVL(l_min_cp_count, 0) = 0 AND NVL(l_acad_year_count, 0) = 0 THEN
/**
*  Logging -
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'l_min_cp_count and l_acad_year_count both are NULL or 0, hence exiting'
		);
END IF;
	RETURN NULL;
    END IF;
    IF NVL(l_min_cp_count, 0) > 0 AND NVL(l_acad_year_count, 0) > 0 THEN
/**
*  Logging -
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'l_min_cp_count => '|| l_min_cp_count||';'||
		'l_acad_year_count => '||l_acad_year_count||';'
		);
END IF;
	RETURN NULL;
    END IF;
    /*  Academic Year Method*/
    IF NVL(l_acad_year_count, 0) > 0 THEN
        IF l_acad_year IS NULL THEN
            OPEN    c_acad_year(p_load_cal_type,p_load_ci_sequence_number);
            FETCH   c_acad_year INTO   l_acad_year;
            CLOSE   c_acad_year;
        END IF;
        /*  Select Class Standing matching the Period Range */
        OPEN C_Get_Cs_for_acad_yr(l_igs_pr_cs_schdl_id, l_acad_year) ;
        FETCH C_Get_Cs_for_acad_yr INTO    l_class_standing;
        CLOSE C_Get_Cs_for_acad_yr;
/**
*  Logging - l_class_standing
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'l_class_standing => '|| l_class_standing||';'
		);
END IF;
        RETURN l_class_standing;
    ELSIF  NVL(l_min_cp_count, 0) > 0  THEN   /* CP Range */
        IF l_cp IS NULL THEN
            /* Get the earned cp total */
            igs_pr_cp_gpa.get_cp_stats(
                            p_person_id,
                            p_course_cd,
                            NULL,
                            l_load_cal_type,
                            l_load_ci_sequence_number,
                            NULL,
                            'Y',
                            l_earned_cp,
                            l_attempted_cp,
                            p_init_msg_list,
                            l_return_status,
                            l_msg_count,
                            l_msg_data);
/**
*  Logging - l_earned_cp
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'l_earned_cp => '|| l_earned_cp||';'
		);
END IF;
            l_cp := NVL(l_earned_cp, 0);
        END IF;
        IF p_predictive_ind = 'Y' THEN
            /* Get the academic calendar superior to the load calendar provided*/
            OPEN C_Get_acad_cal( l_load_cal_type, l_load_ci_sequence_number);
            FETCH C_Get_acad_cal INTO     l_acad_cal_type,l_acad_ci_sequence_number;
            CLOSE C_Get_acad_cal;
            /* Get the enrolled cp total */

	    /* Removed call to Igs_En_Prc_Load.ENRP_CLC_EFTSU_TOTAL
	     for calculating the l_enrolled_cp value .
	     Jhanda
	    */
	    igs_pr_cp_gpa.get_all_stats_new(
				p_person_id               ,
				p_course_cd               ,
				NULL     		  ,
				l_load_cal_type           ,
				l_load_ci_sequence_number ,
				NULL                      ,
				'Y'			  ,
				l_earned_cp               ,
				l_attempted_cp            ,
				l_gpa_value               ,
				l_gpa_cp                  ,
				l_gpa_quality_points      ,
				p_init_msg_list           ,
				l_return_status           ,
				l_msg_count               ,
				l_msg_data                ,
				'N'			  ,
				l_enrolled_cp             );

/**
*  Logging - l_enrolled_cp
*
*/
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
fnd_log.string (fnd_log.level_statement,
	'igs.plsql.igs_pr_get_class_std.get_class_standing',
	'l_enrolled_cp => '|| l_enrolled_cp||';'
	);
END IF;
	    /* For predictive the cp total is earned cp plus enrolled cp */
            l_cp := l_cp + NVL(l_enrolled_cp, 0);
        END IF;
        /* SELECT Class Standing matching the CP RANGE */
        OPEN  C_Get_cs_cp_range( l_igs_pr_cs_schdl_id, l_cp);
        FETCH C_Get_cs_cp_range INTO  l_class_standing;
        CLOSE C_Get_cs_cp_range;
      /**
      *  Logging - l_class_standing
      *
      */
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
	 fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_pr_get_class_std.get_class_standing',
		'l_class_standing => '|| l_class_standing||';'
		);
	END IF;
	RETURN l_class_standing;
END IF;                             -- For Non Customized Class Standing
END IF;
EXCEPTION
       WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
               Fnd_Message.SET_TOKEN('NAME', 'Igs_Pr_Get_Class_Std.get_class_standing');
               Igs_Ge_Msg_Stack.ADD;
               App_Exception.Raise_Exception;
END get_class_standing;

END Igs_Pr_Get_Class_Std;

/
