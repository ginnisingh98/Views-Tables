--------------------------------------------------------
--  DDL for Package Body IGS_HE_FTE_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_FTE_CALC_PKG" AS
/* $Header: IGSHE21B.pls 120.8 2006/05/23 03:58:38 jtmathew ship $ */

  p_fte_start_dt igs_ca_inst.start_dt%TYPE ;
  p_fte_end_dt igs_ca_inst.end_dt%TYPE ;
  p_fte_cal_type igs_ca_inst.cal_type%TYPE ;
  p_fte_sequence_number igs_ca_inst.sequence_number%TYPE ;


  FUNCTION research_st ( p_course_cd igs_ps_ver_all.course_cd%TYPE , p_version_number igs_ps_ver_all.version_number%TYPE )
  RETURN BOOLEAN AS
  /*************************************************************
    Created By      : smaddali
    Date Created By : 15-APR-2002
    Purpose :  To find If the passed person is research candidate or not
       it can return TRUE/FALSE
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    (reverse chronological order - newest change first)
  ***************************************************************/

    l_res_st VARCHAR2(1) := 'N' ;

    --find if the passed program attempt has a candidacy details record
    CURSOR c_res_st IS
    SELECT 'Y'
    FROM igs_ps_type_all pt, igs_ps_ver_all cv
    WHERE cv.course_cd = p_course_cd  AND
          cv.version_number = p_version_number AND
          cv.course_type = pt.course_type AND
          pt.research_type_ind = 'Y' AND
          pt.closed_ind = 'N' ;

  BEGIN
        -- If the student has a candidacy details record for the passed program then
        -- the student is a research student and return TRUE , else return FALSE
        OPEN c_res_st ;
        FETCH c_res_st INTO l_res_st ;
        IF c_res_st%FOUND THEN
          CLOSE c_res_st ;
          RETURN TRUE ;
        ELSE
          CLOSE c_res_st ;
          RETURN FALSE ;
        END IF ;

  EXCEPTION
      WHEN OTHERS THEN
          RAISE  ;

  END research_st ;


  PROCEDURE coo_type (p_person_id  IN igs_pe_person.person_id%TYPE ,
                      p_unit_set_cd  IN igs_en_unit_set.unit_set_cd%TYPE,
                      p_us_version_number  IN igs_en_unit_set.version_number%TYPE,
                      p_sequence_number IN igs_as_su_setatmpt.sequence_number%TYPE ,
                      p_coo_id IN igs_ps_ofr_opt_all.coo_id%TYPE ,
                      p_coo_type  OUT NOCOPY VARCHAR2 ,
                      p_hesa_mode OUT NOCOPY VARCHAR2 ,
                      p_message OUT NOCOPY VARCHAR2 )  AS
  /*************************************************************
    Created By      : smaddali
    Date Created By : 15-APR-2002
    Purpose :  To find the If the passed program offering option is part-time or full time.
       it can return 'PT'/'FT' or NULL
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    --sarakshi   24-Feb-2003   Enh#2797116,modified cursor c_coo,c_crs_dets.Added delete_flag check in the where clause
    (reverse chronological order - newest change first)
  ***************************************************************/

    l_coo_type VARCHAR2(2)  ;
    l_oss_mode  igs_he_poous_all.mode_of_study%TYPE  ;
    l_hesa_mode igs_he_code_map_val.map1%TYPE  ;
    l_course_cd igs_ps_ver_all.course_cd%TYPE ;
    l_version_number igs_ps_ver_all.version_number%TYPE ;
    l_cal_type igs_ps_ofr_opt_all.cal_type%TYPE ;
    l_location_cd igs_ps_ofr_opt_all.location_cd%TYPE ;
    l_attendance_type igs_ps_ofr_opt_all.attendance_type%TYPE ;
    l_attendance_mode igs_ps_ofr_opt_all.attendance_mode%TYPE ;

    -- get the  mode of study at  program offering unit set level
    CURSOR c_poous IS
    SELECT mode_of_study
    FROM  igs_he_poous_all
    WHERE unit_set_cd = p_unit_set_cd AND
          us_version_number = p_us_version_number AND
          course_cd = l_course_cd AND
          crv_version_number = l_version_number AND
          cal_type = l_cal_type AND
          location_cd = l_location_cd AND
          attendance_type = l_attendance_type AND
          attendance_mode = l_attendance_mode ;

    -- get the  mode of study at student unit set attempt level
    CURSOR c_susa IS
    SELECT study_mode
    FROM  igs_he_en_susa
    WHERE person_id = p_person_id AND
          course_cd = l_course_cd AND
          unit_set_cd = p_unit_set_cd AND
          sequence_number = p_sequence_number ;

    -- get the HESA attendance type associated to the program offering option attendance mode
    CURSOR c_coo IS
    SELECT map1
    FROM  IGS_HE_CODE_MAP_VAL
    WHERE association_code = 'OSS_HESA_ATTEND_MODE_ASSOC' AND
    map2 = (SELECT attendance_type
             FROM igs_ps_ofr_opt_all
             WHERE coo_id = p_coo_id
             AND delete_flag = 'N');

    -- get the HESA mode of study associated with OSS mode of study
    CURSOR c_hesa_mode(cp_oss_mode_of_study igs_he_poous_all.mode_of_study%TYPE)  IS
    SELECT map1
    FROM IGS_HE_CODE_MAP_VAL
    WHERE map2  = cp_oss_mode_of_study AND
    association_code = 'OSS_HESA_MODE_ASSOC' ;

    -- get the course details for the program offering option passed
    CURSOR c_crs_dets IS
    SELECT course_cd , version_number, cal_type, location_cd ,attendance_type ,attendance_mode
    FROM igs_ps_ofr_opt_all
    WHERE coo_id = p_coo_id
    AND   delete_flag = 'N';


  BEGIN

      -- get the course details for the passed program offering option ID
     OPEN c_crs_dets ;
     FETCH c_crs_dets INTO l_course_cd ,l_version_number , l_cal_type ,l_location_cd ,
         l_attendance_type , l_attendance_mode ;
     CLOSE c_crs_dets ;

     -- If mode of study is defined at unit set attempt then it overrides the
     -- value at unit set level an program offering level
     OPEN c_susa ;
     FETCH c_susa INTO l_oss_mode ;
     CLOSE c_susa ;
     IF l_oss_mode IS NOT NULL THEN
         -- get the HESA mode of study for the oss mode of study value set at unit set attempt level
         OPEN c_hesa_mode (l_oss_mode) ;
         FETCH c_hesa_mode INTO l_hesa_mode ;
         CLOSE c_hesa_mode ;
     ELSE
          -- if mode of study not setup at unit set attempt level then get it from the program offering unit set level
          OPEN c_poous ;
          FETCH c_poous INTO l_oss_mode ;
          CLOSE c_poous ;
          -- get the HESA mode of study value for the OSS mode of study set at program offering unit set level
          IF l_oss_mode IS NOT NULL THEN
             OPEN c_hesa_mode (l_oss_mode) ;
             FETCH c_hesa_mode INTO l_hesa_mode ;
             CLOSE c_hesa_mode ;
          ELSE
              -- if mode of study is not setup at either unit set attempt or unit set level then
              -- get the HESA attendance type associated to the OSS attendance_type set up at
              -- the program offering option level
              OPEN c_coo ;
              FETCH c_coo INTO l_hesa_mode ;
              CLOSE c_coo ;
          END IF;
      END IF ;

      -- If hesa code is not associated to the oss mode of study then log an error message
      -- else if hesa mode lies in 31-39 or 44 it is part-time offering ,ale it is full time offering
      IF l_hesa_mode IS NULL THEN
         p_message := 'IGS_HE_NO_CODE' ;
         p_coo_type := NULL ;
      -- if hesa mode of study lies in '31' to '39' or '44' then program offering is part-time else full time
      ELSIF l_hesa_mode IN ('31','32','33','34','35','36','37','38','39','44') THEN
          p_coo_type := 'PT' ;
      p_message := NULL ;
      ELSE
          p_coo_type := 'FT' ;
      p_message := NULL ;
      END IF;
       p_hesa_mode := l_hesa_mode ;

  EXCEPTION
      WHEN OTHERS THEN
          FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.Set_Token('NAME','igs_he_fte_calc_pkg.coo_type');
          IGS_GE_MSG_STACK.ADD ;
          APP_EXCEPTION.RAISE_EXCEPTION;

  END coo_type  ;


  PROCEDURE fte_type_intensity ( p_person_id IN igs_pe_person.person_id%TYPE ,
                p_coo_id  IN igs_ps_ofr_opt_all.coo_id%TYPE ,
                p_unit_set_cd  IN igs_en_unit_set.unit_set_cd%TYPE ,
                p_us_version_number  IN igs_en_unit_set.version_number%TYPE ,
                p_sequence_number  IN igs_as_su_setatmpt.sequence_number%TYPE  ,
                P_att_prc_st_fte   IN  VARCHAR2,
                p_fte_calc_type  OUT NOCOPY igs_he_poous_all.fte_calc_type%TYPE ,
                p_fte_intensity OUT NOCOPY igs_he_poous_all.fte_intensity%TYPE ,
                p_selection_dt_from     IN  VARCHAR2,
                p_selection_dt_to       IN  VARCHAR2,
                p_message OUT NOCOPY VARCHAR2 )  AS

  /*************************************************************
    Created By      : smaddali
    Date Created By : 15-APR-2002
    Purpose :  To find the FTE calculation type . It can return 'U' /'I'/'B'
        Or to find the FTE_intensity value . If the parameters p_unit_set_cd ,p_us_version_number,p_sequence_number
        are NULL then FTE_calculation type is determined else if all are passed FTE_intensity is determined
    Know limitations, enhancements or remarks
    Change History
    Who       When          What
    jtmathew  05-Apr-2006   Changes for HE370 - Introduced 'Use Attendance Percentage for Research' functionality
    jtmathew  25-Jan-2005   Changes for HE357 - modified c_year
    smaddali  08-Oct-2003   Removed cursor c_prg_limit and its code for bug#3175107 since std_pt_completion_time and
                            std_ft_completion_time fields are obsolete
    sarakshi  24-Feb-2003   Enh#2797116,modified cursor c_coo,c_crs_dets,c_crs_off.Added delete_flag check in the where clause
    smaddali  05-Jul-2002   modified cursor c_year for bug 2448315
    (reverse chronological order - newest change first)
  ***************************************************************/

    l_hesa_att_type igs_he_code_map_val.map1%TYPE := NULL;
    l_coo_type VARCHAR2(2) := NULL ;
    l_pt VARCHAR2(1) := NULL;
    l_ft VARCHAR2(1) := NULL;
    l_message fnd_new_messages.message_name%TYPE := NULL;
    l_course_cd igs_ps_ofr_opt_all.course_cd%TYPE ;
    l_version_number igs_ps_ofr_opt_all.version_number%TYPE ;
    l_cal_type igs_ps_ofr_opt_all.cal_type%TYPE ;
    l_location_cd igs_ps_ofr_opt_all.location_cd%TYPE ;
    l_attendance_type igs_ps_ofr_opt_all.attendance_type%TYPE ;
    l_attendance_mode igs_ps_ofr_opt_all.attendance_mode%TYPE ;
    l_hesa_mode igs_he_code_map_val.map1%TYPE := NULL;

    -- Get the current year of program  which either started, completed or ended in the FTE period
    -- jtmathew modified this cursor to use optional cp_selection_dt parameters for HE370 changes
    -- jtmathew modified this cursor for end_dt selection for HE357 changes
    -- smaddali modified this cursor to modify where caluse for selection and completion_dt for bug 2448315
    CURSOR c_year IS
    SELECT susa.unit_set_cd , susa.us_version_number , susa.sequence_number
      FROM igs_as_su_setatmpt susa, igs_ps_us_prenr_cfg us
     WHERE susa.unit_set_cd = us.unit_set_cd
       AND susa.person_id = p_person_id
       AND susa.course_cd  = l_course_cd
       AND susa.selection_dt IS NOT NULL
       AND susa.selection_dt < p_fte_end_dt
       AND ((susa.rqrmnts_complete_dt > p_fte_start_dt OR susa.end_dt > p_fte_start_dt)
            OR (susa.end_dt IS NULL AND susa.rqrmnts_complete_dt IS NULL))
       AND (p_selection_dt_from IS NULL
            OR susa.selection_dt BETWEEN p_selection_dt_from AND p_selection_dt_to)
  ORDER BY NVL(susa.rqrmnts_complete_dt, susa.end_dt) DESC;
    c_year_rec  c_year%ROWTYPE;

    --get fte calc type set up at  program offering unit set level
    CURSOR c_poous (cp_unit_set_cd igs_en_unit_set.unit_set_cd%TYPE ,
                      cp_us_version_number igs_en_unit_set.version_number%TYPE
                      ) IS
    SELECT fte_calc_type , fte_intensity
    FROM  igs_he_poous_all
    WHERE unit_set_cd = cp_unit_set_cd AND
       us_version_number = cp_us_version_number AND
       course_cd = l_course_cd AND
       crv_version_number = l_version_number AND
       cal_type = l_cal_type AND
       location_cd = l_location_cd AND
       attendance_type = l_attendance_type AND
       attendance_mode = l_attendance_mode ;
    c_poous_rec  c_poous%ROWTYPE ;

    -- get fte calculation type set up at student unit set attempt level
    CURSOR c_susa (cp_unit_set_cd igs_en_unit_set.unit_set_cd%TYPE ,
                      cp_sequence_number igs_as_su_setatmpt.sequence_number%TYPE
                      )IS
    SELECT fte_calc_type , fte_intensity
    FROM  igs_he_en_susa
    WHERE person_id = p_person_id AND
           course_cd = l_course_cd AND
           unit_set_cd = cp_unit_set_cd AND
           sequence_number = cp_sequence_number ;
    c_susa_rec  c_susa%ROWTYPE ;

     -- get the HESA attendance type associated to the program offering option attendance type
    CURSOR c_coo IS
    SELECT map1
    FROM  IGS_HE_CODE_MAP_VAL
    WHERE association_code = 'OSS_HESA_ATTEND_MODE_ASSOC' AND
    map2 = (SELECT attendance_type
             FROM igs_ps_ofr_opt_all
             WHERE coo_id = p_coo_id
             AND   delete_flag = 'N');

    -- get the course details for the program offering option passed
    CURSOR c_crs_dets IS
    SELECT course_cd , version_number, cal_type, location_cd ,attendance_type ,attendance_mode
    FROM igs_ps_ofr_opt_all
    WHERE coo_id = p_coo_id
    AND   delete_flag = 'N';

    -- get the attendance percentage for the research student which will be his fte intensity
    CURSOR c_research IS
    SELECT attendance_percentage
    FROM igs_re_candidature_all
    WHERE person_id = p_person_id AND
        sca_course_cd = l_course_cd ;
    c_research_rec  c_research%ROWTYPE ;

    -- Get the FTE intensity set at program level
    CURSOR c_prog IS
    SELECT fte_intensity
    FROM igs_he_st_prog_all
    WHERE course_cd = l_course_cd AND
          version_number = l_version_number ;
    c_prog_rec  c_prog%ROWTYPE ;

    -- get all the program offering optiond for the current program
    CURSOR c_crs_off IS
    SELECT coo_id
    FROM igs_ps_ofr_opt_all
    WHERE course_cd = l_course_cd AND
         version_number = l_version_number AND
         delete_flag = 'N';


  BEGIN

        -- get the course details of the passed program offering
        OPEN c_crs_dets ;
        FETCH c_crs_dets INTO l_course_cd ,l_version_number , l_cal_type ,l_location_cd ,
              l_attendance_type , l_attendance_mode ;
        CLOSE c_crs_dets ;

    IF p_unit_set_cd IS NULL THEN
/* Finding the FTE Calculation type */


        -- For a research student fte calculation type is Intensity based
        IF research_st(l_course_cd ,l_version_number) THEN
          p_message := NULL ;
          p_fte_calc_type := 'I' ;

        ELSE
            -- Get the current Year of program for the student program attempt
            OPEN    c_year ;
            FETCH  c_year INTO c_year_rec ;
            -- If current year of program is not found then log a message
            IF c_year%NOTFOUND THEN
               p_message := 'IGS_HE_NO_YOP' ;
               p_fte_calc_type := NULL ;
            ELSE
                -- If fte calculation type is set up at Student unit set attmept level  for the current year of program
                -- then it overrides the value set at Program offering unit set level
                OPEN c_susa ( c_year_rec.unit_set_cd , c_year_rec.sequence_number );
                FETCH c_susa INTO c_susa_rec ;
                CLOSE c_susa ;

                IF c_susa_rec.fte_calc_type IS NOT NULL THEN
                     p_message := NULL ;
                     p_fte_calc_type := c_susa_rec.fte_calc_type ;
                ELSE
                    -- If fte_calc_type is not set at unit set attempt level then get the value set at
                    -- program offering unit set lelvel corresponding to the current year of program
                    OPEN c_poous (c_year_rec.unit_set_cd , c_year_rec.us_version_number ) ;
                    FETCH c_poous INTO c_poous_rec ;
                    CLOSE c_poous ;

                    IF c_poous_rec.fte_calc_type IS NOT NULL THEN
                          p_message := NULL ;
                          p_fte_calc_type := c_poous_rec.fte_calc_type ;
                    ELSE
                        -- If fte calculation type is not set up at either unit set level/ unit set attempt level then
                        -- for a part-time program offering option it is Unit based ,for others it is Intensity based
                        OPEN c_coo ;
                        FETCH c_coo INTO l_hesa_att_type ;
                        CLOSE c_coo ;

                        -- If hesa attendance type lies in '31 to 39' or '44' then the program offering is part-time ,
                        -- else it is full-time , If no hesa mapping is found then log a message
                        IF l_hesa_att_type IS NULL THEN
                            p_message := 'IGS_HE_NO_CODE' ;
                            p_fte_calc_type := NULL ;
                        ELSIF l_hesa_att_type IN ('31','32','33','34','35','36','37','38','39','44') THEN
                            p_message := NULL ;
                            p_fte_calc_type := 'U'  ;
                        ELSE
                            p_message := NULL ;
                            p_fte_calc_type := 'I';
                        END IF;
                    END IF;  -- if fte type not found at poous level

                END IF ;  -- if fte type not found at susa level

            END IF ;
            CLOSE  c_year ;

        END IF; -- if student is not a research student

/* end of finding FTE calculation type  */

    ELSE
/* Finding the FTE Intensity  */
        c_susa_rec := NULL ;
        c_poous_rec := NULL ;
        c_prog_rec := NULL;

        -- Get the fte intensity for a research student
        OPEN  c_research ;
        FETCH c_research INTO c_research_rec ;
        CLOSE c_research ;

        -- get the fte intensity at the unit set and unit set attemt levels
        OPEN c_susa ( p_unit_set_cd ,p_sequence_number );
        FETCH c_susa INTO c_susa_rec ;
        CLOSE c_susa ;

        OPEN c_poous (p_unit_set_cd , p_us_version_number ) ;
        FETCH c_poous INTO c_poous_rec ;
        CLOSE c_poous ;

        OPEN c_prog  ;
        FETCH c_prog INTO c_prog_rec ;
        CLOSE c_prog ;

        -- For a research student fte calculation type is Intensity based
        IF research_st( l_course_cd , l_version_number)  AND c_research_rec.attendance_percentage IS NOT NULL
        AND P_att_prc_st_fte = 'Y'
        THEN
            p_fte_intensity := c_research_rec.attendance_percentage ;
            p_message := NULL ;
        -- If fte calculation type is set up at Student unit set attempt level for the current year of program
        -- then it overrides the value defined at the Program Offering Option Unit Set level
        ELSIF c_susa_rec.fte_intensity IS NOT NULL THEN
                p_fte_intensity := c_susa_rec.fte_intensity ;
                p_message := NULL ;
        -- If fte_calc_type is not set at Student Unit Set Attempt level then get the value set at
        -- Program Offering Option Unit Set level corresponding to the current year of program
        ELSIF c_poous_rec.fte_intensity IS NOT NULL THEN
                 p_fte_intensity := c_poous_rec.fte_intensity ;
         p_message := NULL ;
        ELSE

                l_pt := 'N'  ;
                l_ft := 'N'  ;
                -- loop thru all the program offering options for this program and exit when you find both
                -- full-time and part-time offerings
                FOR c_crs_off_rec IN c_crs_off LOOP
                   l_coo_type  := NULL ;
                   l_hesa_mode := NULL ;

                   coo_type (p_person_id , p_unit_set_cd , p_us_version_number,
                      p_sequence_number , c_crs_off_rec.coo_id , l_coo_type, l_hesa_mode, l_message ) ;
                   IF l_coo_type = 'PT' THEN
                      l_pt  := 'Y' ;
                   ELSIF l_coo_type = 'FT' THEN
                       l_ft := 'Y' ;
                   END IF;
                   EXIT WHEN ( l_pt = 'Y' AND l_ft = 'Y' ) ;

                END LOOP ;


                -- If the program has both full-time and part-time offering then the FTE_INTENSITY
                -- should be set up at the program offering option unit set level or unit set attempt level
                -- we shouldnot pick fte intensity from program level
                IF l_pt = 'Y' AND l_FT = 'Y' THEN
                    p_message := 'IGS_HE_PT_FT' ;
                    p_fte_intensity := NULL ;
                ELSIF c_prog_rec.fte_intensity IS NOT NULL THEN
                    p_fte_intensity := c_prog_rec.fte_intensity ;
                    p_message := NULL ;
                ELSE
                    l_coo_type := NULL ;
                    -- now if fte intensity is not setup at any level then ,
                    -- if program is full-time then intensity=100  ,for part time it is calcuated as
                    -- the ratio of full time completion time and part-time completion time
                    coo_type (p_person_id , p_unit_set_cd , p_us_version_number,
                    p_sequence_number , p_coo_id , l_coo_type, l_hesa_mode , p_message ) ;
                    IF l_coo_type = 'PT' THEN
                         -- if the standard full time and part time completion periods are not set then log error message
                         -- Cannot derive fte intensity so log error
                         -- smaddali removed code to derive intensity from std_ft_completion_time , for bug#3175107
                         p_fte_intensity := NULL ;
                         p_message := 'IGS_HE_NO_COMP_PRD' ;
                    ELSE
                         p_fte_intensity := 100 ;
                    END IF;
                END IF;
        END IF ;


/* end of finding the FTE intensity  */

    END IF;



  EXCEPTION
      WHEN OTHERS THEN
          FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.Set_Token('NAME','igs_he_fte_calc_pkg.fte_type_intensity');
          IGS_GE_MSG_STACK.ADD ;
          APP_EXCEPTION.RAISE_EXCEPTION ;

  END  fte_type_intensity ;

  PROCEDURE log_messages ( p_msg_name IN VARCHAR2 ,
                           p_msg_val  IN VARCHAR2
                         ) IS
  ------------------------------------------------------------------
  --Created by  : smaddali, Oracle IDC
  --Date created:15/04/2002
  --
  --Purpose: This procedure is private to this package body .
  --         The procedure logs all the parameter values ,
  --         in the log file
  --  called from job procedure rollover_fac_task
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  BEGIN

    FND_MESSAGE.SET_NAME('IGS','IGS_FI_CAL_BALANCES_LOG');
    FND_MESSAGE.SET_TOKEN('PARAMETER_NAME',p_msg_name);
    FND_MESSAGE.SET_TOKEN('PARAMETER_VAL' ,p_msg_val) ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  END log_messages ;


  PROCEDURE fte_calculation(errbuf OUT NOCOPY VARCHAR2 ,
                            retcode OUT NOCOPY NUMBER ,
                            P_FTE_cal               IN  VARCHAR2,
                            P_Person_id             IN  NUMBER,
                            P_Person_id_grp         IN  VARCHAR2,
                            P_Course_cd             IN  VARCHAR2,
                            P_Course_cat            IN  VARCHAR2,
                            P_Coo_id                IN  NUMBER,
                            P_Selection_dt_from     IN  VARCHAR2,
                            P_Selection_dt_to       IN  VARCHAR2,
                            P_App_res_st_fte        IN  VARCHAR2,
                            P_Att_prc_st_fte        IN  VARCHAR2) IS
   /*************************************************************
    Created By      : smaddali
    Date Created By : 15-APR-2002
    Purpose : To calculate the fte and save it in igs_he_en_susa
     for each eligible student program attempt
    Know limitations, enhancements or remarks
    Change History
    Who      When           What
    sarakshi 26-jun-2003    Enh#2930935,modified cursors c_sua,c_trn_from_units to include uoo_id
                            and cursor c_unit_cp to pick enrolled credit point from unit section
                            level if exists else from unit level
    smaddali                modified cursors c_crs_year , c_year , c_sca for bug 2448315
    smaddali                modified cursors c_crs_year and c_year_cal for bug 2452785
    smaddali 08-Oct-2003    Removed cursor c_prg_limit and its code for bug#3175107 since std_pt_completion_time and
                            std_ft_completion_time fields are obsolete
    smaddali 10-Oct-2003    Modified code to apportion fte for research students ,
                            to check that commencement_dt and discontinued_dt lie in the FTE period ,
                            for bug#3177328
    smaddali 13-Oct-2003    Modified cursor c_sca , removed cursors c_trn_from and c_sca_sin for bug#3171373
    smaddali 02-Dec-2003    Modified code logic for coo_id and course_cat parameters for HECR214 build, Bug#3291656
    ayedubat 29-Apr-2004    Changed the cursors, c_intermit and c_intm_part to add a new condition to check
                            for approved intermissions, if approval is required for Bug, 3494224
    rnirwani 13-Sep-2004    changed cursor c_intermit to not consider logically deleted records and
                            also to avoid un-approved intermission records. Bug# 3885804
    jbaber   30-Nov-2004    Removed c_intermit, using isDormant instead for bug# 4037237
    jtmathew 25-Jan-2005    Changes for HE357 - modified c_sua, c_trn_from_units, c_year, c_crs_year, c_fte_prop
                            and rewrote c_year_cal. Created c_multi_yop and TYPE year_cal_type. Also modified
                            intensity based calculation algorithm.
    jtmathew 24-Oct-2005    Created c_en_hist for bug 4221427
    anwest   18-jan-2006    Bug# 4950285 R12 Disable OSS Mandate
    jchakrab 20-Feb-2006    Modified for 4251041 - removed ORDER BY from cursor c_sua query
    jtmathew 23-Feb-2006    Modified c_poous_app for bug 5051155
    jtmathew 05-Apr-2006    Changes for HE370 - Additional parameters: P_Person_id_grp, P_Selection_dts, P_att_prc_st_fte
                            Modified cursors: c_sua, c_year, c_crs_year, c_year_cal, c_multi_yop
                            c_spa has been removed and is now implemented using dynamic sql.
  ***************************************************************/
  BEGIN

    DECLARE
    cst_enrolled                 CONSTANT    VARCHAR2(10) := 'ENROLLED';
    cst_discontin                CONSTANT    VARCHAR2(10) := 'DISCONTIN';
    cst_completed                CONSTANT    VARCHAR2(10) := 'COMPLETED';
    cst_intermit                 CONSTANT    VARCHAR2(10) := 'INTERMIT';
    cst_inactive                 CONSTANT    VARCHAR2(10) := 'INACTIVE';
    cst_lapsed                   CONSTANT    VARCHAR2(10) := 'LAPSED';
    i                            NUMBER := 1;

    l_fte_calc_type              igs_he_poous_all.fte_calc_type%TYPE ;
    l_fte_intensity              igs_he_en_susa.fte_intensity%TYPE ;
    l_calculated_intensity       igs_he_en_susa.fte_intensity%TYPE ;
    l_total_credit_points        NUMBER := NULL ;
    l_unit_cp                    NUMBER := NULL ;
    l_message                    fnd_new_messages.message_name%TYPE := NULL;
    l_dummy1                     igs_he_poous_all.fte_calc_type%TYPE;
    l_dummy2                     igs_he_poous_all.fte_intensity%TYPE;
    l_calculated_FTE             igs_he_en_susa.calculated_fte%TYPE := NULL;
    l_trn_from_crs               igs_ps_ver.course_cd%TYPE := NULL;
    l_unit_ver_cp                igs_ps_unit_ver.enrolled_credit_points%TYPE := NULL;
    l_std_annual_load            igs_ps_ver.std_annual_load%TYPE := NULL;
    l_fte_perc                   igs_he_fte_proprt.fte_perc%TYPE := NULL;
    l_intm_flag                  BOOLEAN := FALSE ;
    l_intm_part_days             NUMBER ;
    l_apportion_flag             BOOLEAN := FALSE ;
    l_app_start_dt               DATE := NULL ;
    l_app_end_dt                 DATE := NULL ;
    l_actual_start_dt            DATE := NULL ;
    l_actual_end_dt              DATE := NULL ;
    l_selection_dt_to            DATE := NULL;
    l_selection_dt_from          DATE := NULL;
    l_hesa_mode                  igs_he_code_map_val.map1%TYPE ;
    l_coo_type                   VARCHAR2(2) := NULL;
    l_app_days                   NUMBER := NULL ;
    l_actual_days                NUMBER := NULL;
    l_rowid                      VARCHAR2(40) := NULL;
    l_hesa_en_susa_id            NUMBER := NULL;
    l_exit_flag                  BOOLEAN := FALSE ;
    l_multi_yop                  BOOLEAN := FALSE ;
    l_fte_prop_flag              BOOLEAN := FALSE ;

    -- Variables for dynamic sql
    l_prs_grp_sql                VARCHAR2(32767);
    l_group_type                 igs_pe_persid_group_v.group_type%TYPE;
    l_prs_grp_status             VARCHAR2(1)     := NULL;
    l_cursor_id                  NUMBER;
    l_num_rows                   NUMBER;
    l_fte_calc_sql               VARCHAR2(32767);

    TYPE spa_type IS RECORD
       (person_number              hz_parties.party_number%TYPE,
        person_id                  igs_en_stdnt_ps_att_all.person_id%TYPE,
        course_cd                  igs_en_stdnt_ps_att_all.course_cd%TYPE,
        version_number             igs_en_stdnt_ps_att_all.version_number%TYPE,
        coo_id                     igs_en_stdnt_ps_att_all.coo_id%TYPE,
        course_attempt_status      igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
        discontinued_dt            igs_en_stdnt_ps_att_all.discontinued_dt%TYPE,
        course_rqrmnts_complete_dt igs_en_stdnt_ps_att_all.course_rqrmnts_complete_dt%TYPE,
        commencement_dt            igs_en_stdnt_ps_att_all.commencement_dt%TYPE,
        course_rqrmnt_complete_ind igs_en_stdnt_ps_att_all.course_rqrmnt_complete_ind%TYPE,
        student_inst_number        igs_he_st_spa_all.student_inst_number%TYPE);
    c_sca_rec  spa_type;

    TYPE ref_spa IS REF CURSOR;
    c_ref_spa  ref_spa;

    TYPE year_cal_type IS RECORD
       (cal_type           igs_ca_inst.cal_type%TYPE,
        sequence_number    igs_ca_inst.sequence_number%TYPE,
        start_dt           igs_ca_inst.start_dt%TYPE,
        end_dt             igs_ca_inst.end_dt%TYPE);
    l_year_cal_rec year_cal_type;

    -- get the start and end dates for the passed FTE calendar
    CURSOR c_fte_prd IS
    SELECT ci.start_dt , ci.end_dt
    FROM igs_ca_inst ci
    WHERE ci.cal_type = p_fte_cal_type AND
          ci.sequence_number = p_fte_sequence_number ;

    -- check whether student has previously had an enrollment history
    CURSOR c_en_hist (cp_person_id igs_as_sc_attempt_h_all.person_id%TYPE,
                      cp_course_cd igs_as_sc_attempt_h_all.course_cd%TYPE) IS
    SELECT 'X'
    FROM igs_as_sc_attempt_h_all
    WHERE person_id = cp_person_id
    AND course_cd = cp_course_cd
    AND hist_start_dt < p_fte_end_dt + 1
    AND course_attempt_status = cst_enrolled;
    c_en_hist_rec c_en_hist%ROWTYPE;

    -- get the student unit attempts for the current program attempt
    -- jtmathew modified cursor to use unit section override start date (if exists) otherwise teaching period start date
    -- jchakrab modified for 4251041 - removed redundant ORDER BY clause
    CURSOR c_sua(cp_person_id igs_pe_person.person_id%TYPE ,
                 cp_course_cd  igs_ps_ver.course_cd%TYPE ) IS
    SELECT sua.unit_cd,
           sua.version_number,
           sua.enrolled_dt ,
           sua.override_enrolled_cp ,
           sua.cal_type,
           sua.ci_sequence_number   ,
           sua.unit_attempt_status ,
           sua.discontinued_dt         ,
           sua.uoo_id
      FROM IGS_EN_SU_ATTEMPT_ALL       sua,
           IGS_HE_ST_UNT_VS_ALL        hsu,
           IGS_PS_UNIT_OFR_OPT_ALL     uoo
     WHERE sua.person_id           = cp_person_id
       AND sua.course_cd           = cp_course_cd
       AND sua.unit_cd = hsu.unit_cd (+)
       AND sua.version_number = hsu.version_number (+)
       AND NVL(hsu.exclude_flag, 'N') = 'N'
       AND sua.unit_attempt_status IN (cst_enrolled,cst_discontin,cst_completed)
       AND sua.unit_cd = uoo.unit_cd (+)
       AND sua.version_number = uoo.version_number (+)
       AND sua.cal_type = uoo.cal_type (+)
       AND sua.ci_sequence_number = uoo.ci_sequence_number (+)
       AND sua.location_cd = uoo.location_cd (+)
       AND sua.unit_class = uoo.unit_class (+)
       AND ( NVL(uoo.unit_section_start_date, sua.ci_start_dt) BETWEEN  p_fte_start_dt AND p_fte_end_dt);

    --get the enrolled credit points for the unit
    CURSOR c_unit_cp (cp_uoo_id   IN NUMBER) IS
    SELECT NVL(cps.enrolled_credit_points,uv.enrolled_credit_points) enrolled_credit_points
    FROM igs_ps_unit_ver_all uv,
             igs_ps_unit_ofr_opt uoo,
             igs_ps_usec_cps cps
    WHERE uoo.uoo_id=cps.uoo_id(+) AND
              uoo.unit_cd=uv.unit_cd AND
              uoo.version_number=uv.version_number AND
              uoo.uoo_id=cp_uoo_id;

    -- check if the student has transferred to the current program from other program
    CURSOR c_trn_to (cp_person_id igs_pe_person.person_id%TYPE ,
                        cp_course_cd igs_ps_ver.course_cd%TYPE) IS
    SELECT  transfer_course_cd
    FROM igs_ps_stdnt_trn
    WHERE person_id = cp_person_id AND
          course_cd = cp_course_cd AND
         ( transfer_dt  BETWEEN  p_fte_start_dt AND p_fte_end_dt );

    -- get all the completed unit attempts of the program transferred from
    CURSOR c_trn_from_units (cp_person_id igs_pe_person.person_id%TYPE ,
                        cp_course_cd igs_ps_ver.course_cd%TYPE) IS
    SELECT unit_cd,
        version_number,
        ci_start_dt,
        override_enrolled_cp ,
                uoo_id
    FROM igs_en_su_attempt_all
    WHERE person_id = cp_person_id AND
    course_cd = cp_course_cd AND
    unit_attempt_status = cst_completed AND
    (ci_start_dt BETWEEN p_fte_start_dt AND p_fte_end_dt) ;

    -- get all the year of programs lying in the fte calculation period
    -- jtmathew modified this cursor to use optional cp_selection_dt parameters for HE370 changes
    -- jtmathew modified this cursor to allow for end_dts for HE357 changes
    -- smaddali modified this cursors where clause for selection and completion dates for bug 2448315
    -- smaddali modified this cursor to pick up acad_perd field from igs_ps_us_prenr_cfg instead of
    -- from igs_en_susa_year_v for bug 2452785
    CURSOR c_crs_year(cp_person_id         igs_pe_person.person_id%TYPE ,
                      cp_course_cd         igs_ps_ver.course_cd%TYPE,
                      cp_selection_dt_from igs_as_su_setatmpt.selection_dt%TYPE,
                      cp_selection_dt_to   igs_as_su_setatmpt.selection_dt%TYPE) IS
    SELECT usv.unit_set_cd , usv.us_version_number , usv.sequence_number,
           us.sequence_no acad_perd, usv.selection_dt, usv.rqrmnts_complete_dt completion_dt, usv.end_dt
      FROM igs_as_su_setatmpt usv  , igs_ps_us_prenr_cfg us
     WHERE usv.unit_set_cd = us.unit_set_cd
       AND usv.person_id = cp_person_id
       AND usv.course_cd  = cp_course_cd
       AND usv.selection_dt IS NOT NULL
       AND usv.selection_dt < p_fte_end_dt
       AND ((usv.rqrmnts_complete_dt > p_fte_start_dt OR usv.end_dt > p_fte_start_dt)
            OR (usv.end_dt IS NULL AND usv.rqrmnts_complete_dt IS NULL))
       AND (cp_selection_dt_from IS NULL
            OR usv.selection_dt BETWEEN cp_selection_dt_from AND cp_selection_dt_to)
  ORDER BY NVL(usv.rqrmnts_complete_dt, usv.end_dt) DESC;
    c_crs_year_rec  c_crs_year%ROWTYPE ;

    -- Retrieve the number of student program attempts that have more than one year of program
    -- within the FTE calculation period
    -- jtmathew modified this cursor to use optional cp_selection_dt parameters for HE370 changes
    -- jtmathew created this cursor for HE357 changes
    CURSOR c_multi_yop(cp_person_id         igs_pe_person.person_id%TYPE ,
                       cp_course_cd         igs_ps_ver.course_cd%TYPE,
                       cp_selection_dt_from igs_as_su_setatmpt.selection_dt%TYPE,
                       cp_selection_dt_to   igs_as_su_setatmpt.selection_dt%TYPE) IS
    SELECT usv.person_id, usv.course_cd, count(*) multi_yop_count
    FROM   igs_as_su_setatmpt usv  , igs_ps_us_prenr_cfg us
     WHERE usv.unit_set_cd = us.unit_set_cd
       AND usv.person_id = cp_person_id
       AND usv.course_cd  = cp_course_cd
       AND usv.selection_dt IS NOT NULL
       AND usv.selection_dt < p_fte_end_dt
       AND ((usv.rqrmnts_complete_dt > p_fte_start_dt OR usv.end_dt > p_fte_start_dt)
            OR (usv.end_dt IS NULL AND usv.rqrmnts_complete_dt IS NULL))
       AND (cp_selection_dt_from IS NULL
            OR usv.selection_dt BETWEEN cp_selection_dt_from AND cp_selection_dt_to)
  GROUP BY usv.person_id, usv.course_cd
    HAVING count(*) > 1;
    c_multi_yop_rec  c_multi_yop%ROWTYPE ;

    -- get the academic calendar instance corresponding to the passed year of program
    -- jtmathew modified this cursor to use optional cp_selection_dt parameters for HE370 changes
    -- jtmathew rewrote c_year_cal cursor to select calendar instance
    -- based on yop selection, completion and end dates for HE357 changes
    -- smaddali modified the cursor to add DISTINCT ,to eliminate duplicate records for bug 2452785
    CURSOR c_year_cal (cp_person_id         igs_pe_person.person_id%TYPE,
                       cp_course_cd         igs_ps_ver.course_cd%TYPE,
                       cp_unit_set_cd       igs_as_su_setatmpt.unit_set_cd%TYPE,
                       cp_selection_dt_from igs_as_su_setatmpt.selection_dt%TYPE,
                       cp_selection_dt_to   igs_as_su_setatmpt.selection_dt%TYPE) IS
    SELECT ci.cal_type, ci.sequence_number, ci.start_dt, ci.end_dt
      FROM igs_ca_inst ci,
           igs_ca_type cat,
           igs_ca_stat cs,
           igs_en_stdnt_ps_att_all sca,
           igs_as_su_setatmpt susa
     WHERE sca.person_id = susa.person_id
       AND sca.course_cd = susa.course_cd
       AND sca.cal_type = ci.cal_type
       AND ci.cal_type = cat.cal_type
       AND ci.cal_status = cs.cal_status
       AND cs.s_cal_status = 'ACTIVE'
       AND cat.s_cal_cat = 'ACADEMIC'
       AND sca.person_id = cp_person_id
       AND sca.course_cd = cp_course_cd
       AND susa.unit_set_cd = cp_unit_set_cd
       AND ((susa.selection_dt < ci.end_dt ) OR
           ( susa.rqrmnts_complete_dt IS NOT NULL AND
                  (ci.end_dt BETWEEN susa.selection_dt AND susa.rqrmnts_complete_dt)) OR
           ( susa.end_dt IS NOT NULL AND
                  (ci.end_dt BETWEEN susa.selection_dt AND susa.end_dt)))
       AND ci.start_dt < p_fte_end_dt
       AND (cp_selection_dt_from IS NULL
            OR susa.selection_dt BETWEEN cp_selection_dt_from AND cp_selection_dt_to)
  ORDER BY ci.start_dt DESC;
    c_year_cal_rec  c_year_cal%ROWTYPE ;

    -- get the standard annual load for the program
    CURSOR c_ann_load (cp_course_cd  igs_ps_ver.course_cd%TYPE ,
                       cp_version_number  igs_ps_ver.version_number%TYPE ) IS
    SELECT std_annual_load
    FROM igs_ps_ver_all
    WHERE course_cd = cp_course_cd AND
         version_number = cp_version_number ;

    -- get the current year of program for the passed program attempt which has
    -- either started, completed or ended in the fte period
    -- jtmathew modified this cursor to use optional cp_selection_dt parameters for HE370 changes
    -- jtmathew modified this cursor to allow for end_dts for HE357 changes
    -- smaddali modified this cursors where clause of selection_dt and completion_dt for bug 2448315
    CURSOR c_year (cp_person_id         igs_pe_person.person_id%TYPE,
                   cp_course_cd         igs_ps_ver.course_cd%TYPE,
                   cp_selection_dt_from igs_as_su_setatmpt.selection_dt%TYPE,
                   cp_selection_dt_to   igs_as_su_setatmpt.selection_dt%TYPE) IS
    SELECT susa.unit_set_cd , susa.us_version_number , susa.sequence_number
      FROM igs_as_su_setatmpt susa, igs_ps_us_prenr_cfg us
     WHERE susa.unit_set_cd = us.unit_set_cd
       AND susa.person_id = cp_person_id
       AND susa.course_cd  = cp_course_cd
       AND susa.selection_dt IS NOT NULL
       AND susa.selection_dt < p_fte_end_dt
       AND ((susa.rqrmnts_complete_dt > p_fte_start_dt OR susa.end_dt > p_fte_start_dt)
            OR (susa.end_dt IS NULL AND susa.rqrmnts_complete_dt IS NULL))
       AND (cp_selection_dt_from IS NULL
            OR susa.selection_dt BETWEEN cp_selection_dt_from AND cp_selection_dt_to)
  ORDER BY NVL(susa.rqrmnts_complete_dt, susa.end_dt) DESC;
    c_year_rec  c_year%ROWTYPE;

    -- get the HESA unit set attempt corresponding to the current year of program
    -- in which to save the calculated fte
    CURSOR c_susa_upd (cp_person_id igs_pe_person.person_id%TYPE ,
                       cp_course_cd  igs_ps_ver.course_cd%TYPE ,
           cp_unit_set_cd  igs_en_unit_set.unit_set_cd%TYPE ,
           cp_sequence_number igs_as_su_setatmpt.sequence_number%TYPE ) IS
    SELECT rowid , susa.*
    FROM igs_he_en_susa susa
    WHERE person_id = cp_person_id AND
          course_cd = cp_course_cd AND
      unit_set_cd = cp_unit_set_cd AND
      sequence_number = cp_sequence_number ;
    c_susa_upd_rec  c_susa_upd%ROWTYPE ;

    -- jtmathew modified for HE357 to avoid the selection of proportions that are closed
    -- get the apportioned fte % for the current academic calendar
    CURSOR c_fte_prop( cp_cal_type igs_ca_inst.cal_type%TYPE ,
                       cp_ci_sequence_number igs_ca_inst.sequence_number%TYPE ,
           cp_acad_perd igs_ps_us_prenr_cfg.sequence_no%TYPE )  IS
    SELECT fte_perc
    FROM   igs_he_fte_proprt
    WHERE  cal_type = cp_cal_type AND
           ci_sequence_number = cp_ci_sequence_number AND
           fte_cal_type = p_fte_cal_type AND
           fte_sequence_num = p_fte_sequence_number AND
           year_of_program = cp_acad_perd AND
           closed_ind = 'N';
    c_fte_prop_rec  c_fte_prop%ROWTYPE ;

    -- check if the program has been intermitted for some part of the fte period
    CURSOR c_intm_part (cp_person_id igs_pe_person.person_id%TYPE ,
                        cp_course_cd igs_ps_ver.course_cd%TYPE ,
                        cp_start_dt DATE ,
                        cp_end_dt DATE) IS
    SELECT  start_dt , end_dt
    FROM igs_en_stdnt_ps_intm spi
    WHERE spi.person_id = cp_person_id AND
      spi.course_cd = cp_course_cd AND
      spi.start_dt < cp_end_dt AND
      spi.end_dt > cp_start_dt AND
          spi.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY') AND
      (spi.approved = 'Y' OR
      EXISTS( SELECT 1 FROM igs_en_intm_types
              WHERE intermission_type = spi.intermission_type AND
                    appr_reqd_ind = 'N' ));

    c_intm_part_rec  c_intm_part%ROWTYPE ;

    -- get the apportionment period set up at the program level
    CURSOR c_prog_app(cp_course_cd igs_ps_ver_all.course_cd%TYPE ,
                      cp_version_number igs_ps_ver_all.version_number%TYPE )  IS
    SELECT teach_period_start_dt , teach_period_end_dt
    FROM igs_he_st_prog_all prog
    WHERE prog.course_cd = cp_course_cd AND
          prog.version_number = cp_version_number ;
    c_prog_app_rec  c_prog_app%ROWTYPE ;

    -- get the apportionment period set up at the POOUS level
    CURSOR c_poous_app(cp_coo_id igs_ps_ofr_opt_all.coo_id%TYPE ,
                       cp_unit_set_cd  igs_en_unit_set.unit_set_cd%TYPE ,
                       cp_us_version_number  igs_en_unit_set.version_number%TYPE )  IS
    SELECT teach_period_start_dt , teach_period_end_dt
    FROM igs_he_poous_all poous, igs_ps_ofr_opt_all coo
    WHERE poous.course_cd = coo.course_cd AND
          poous.crv_version_number = coo.version_number AND
          poous.cal_type = coo.cal_type AND
          poous.location_cd = coo.location_cd AND
          poous.attendance_type = coo.attendance_type AND
          poous.attendance_mode = coo.attendance_mode AND
          coo.coo_id = cp_coo_id AND
          unit_set_cd = cp_unit_set_cd AND
          us_version_number = cp_us_version_number ;
    c_poous_app_rec  c_poous_app%ROWTYPE ;

    -- get the apportionment period setup at the fte calendar level
    CURSOR c_fte_app IS
    SELECT ci.start_dt , ci.end_dt
    FROM igs_he_fte_cal_prd fp , igs_ca_inst ci
    WHERE fp.teach_cal_type = ci.cal_type AND
          fp.teach_sequence_num = ci.sequence_number AND
          fp.fte_cal_type = p_fte_cal_type AND
      fp.fte_sequence_num = p_fte_sequence_number ;


    -- get the start and end dates of the teaching calendar passed
    CURSOR c_cal_inst(cp_cal_type igs_ca_inst.cal_type%TYPE ,
                cp_sequence_number igs_ca_inst.sequence_number%TYPE ) IS
    SELECT start_dt , end_dt
    FROM igs_ca_inst
    WHERE cal_type = cp_cal_type AND
            sequence_number = cp_sequence_number ;
    c_cal_inst_rec    c_cal_inst%ROWTYPE ;

    -- smaddali added these variables and cursor for bug#3171373
    l_old_person_id  igs_he_st_spa_all.person_id%TYPE ;
    l_old_stin       igs_he_st_spa_all.student_inst_number%TYPE;
    l_trn_commencement_dt  igs_en_stdnt_ps_att_all.commencement_dt%TYPE ;

    -- Get the min commencement dt of the person with passed student instance number
    CURSOR  c_trn_commencement( cp_person_id igs_he_st_spa_all.person_id%TYPE ,
                                cp_stin   igs_he_st_spa_all.student_inst_number%TYPE) IS
    SELECT  MIN(sca.commencement_dt) trn_commencement_dt
    FROM    igs_en_stdnt_ps_att sca,
        igs_he_st_spa    hspa
    WHERE   hspa.person_id             = cp_person_id
      AND  hspa.student_inst_number   = cp_stin
      AND  sca.person_id              = hspa.person_id
      AND  sca.course_cd              = hspa.course_cd;

    -- smaddali added cursors for HECR214 - term based fees enhancement build, bug#3291656
    -- Get the latest Term record for the Leavers during which the student left
    CURSOR c_term1_lev( cp_person_id  igs_en_spa_terms.person_id%TYPE,
                        cp_course_cd  igs_en_spa_terms.program_cd%TYPE,
                        cp_lev_dt  DATE ) IS
    SELECT  tr.program_version , tr.coo_id
    FROM  igs_en_spa_terms tr , igs_ca_inst_all ca
    WHERE  tr.term_cal_type = ca.cal_type AND
           tr.term_sequence_number = ca.sequence_number AND
           tr.person_id = cp_person_id AND
           tr.program_cd = cp_course_cd AND
           cp_lev_dt BETWEEN ca.start_dt AND ca.end_dt
    ORDER BY  ca.start_dt DESC;
    c_term1_lev_rec   c_term1_lev%ROWTYPE ;

    -- Get the latest Term record for the Leavers just before the student left
    CURSOR c_term2_lev( cp_person_id  igs_en_spa_terms.person_id%TYPE,
                        cp_course_cd  igs_en_spa_terms.program_cd%TYPE,
                        cp_lev_dt  DATE ) IS
    SELECT  tr.program_version , tr.coo_id
    FROM  igs_en_spa_terms tr , igs_ca_inst_all ca
    WHERE  tr.term_cal_type = ca.cal_type AND
           tr.term_sequence_number = ca.sequence_number AND
           tr.person_id = cp_person_id AND
           tr.program_cd = cp_course_cd AND
           cp_lev_dt > ca.start_dt AND
           ca.start_dt BETWEEN p_fte_start_dt AND p_fte_end_dt
    ORDER BY  ca.start_dt DESC;
    c_term2_lev_rec    c_term2_lev%ROWTYPE ;

    -- Get the latest term record for the Continuing students
    CURSOR c_term_con ( cp_person_id  igs_en_spa_terms.person_id%TYPE,
                        cp_course_cd  igs_en_spa_terms.program_cd%TYPE) IS
    SELECT  tr.program_version , tr.coo_id
    FROM  igs_en_spa_terms tr , igs_ca_inst_all ca
    WHERE  tr.term_cal_type = ca.cal_type AND
           tr.term_sequence_number = ca.sequence_number AND
           tr.person_id = cp_person_id AND
           tr.program_cd = cp_course_cd AND
           ca.start_dt BETWEEN p_fte_start_dt AND p_fte_end_dt
    ORDER BY  ca.start_dt DESC;
    c_term_con_rec    c_term_con%ROWTYPE ;
    l_lev_dt   igs_en_stdnt_ps_att_all.discontinued_dt%TYPE ;

    -- Check if the passed course version belongs to the course category parameter
    CURSOR c_prg_cat ( cp_course_cd  igs_ps_ver_all.course_cd%TYPE,
                       cp_version_number  igs_ps_ver_all.version_number%TYPE ) IS
    SELECT course_cd,version_number
    FROM igs_ps_categorise_all ct where
      ct.course_cd = cp_course_cd AND
      ct.version_number = cp_version_number AND
      ct.course_cat = p_course_cat ;
    c_prg_cat_rec     c_prg_cat%ROWTYPE ;

    -- Determine type (static or dynamic) of person id group
    CURSOR c_group_type IS
    SELECT group_type
      FROM igs_pe_persid_group_v
    WHERE group_id = p_person_id_grp;

    BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      -- Calculate the EFTSU total for a student course attempt within a
      -- nominated FTE calendar instance.
      -- Note: p_app_res_st_fte indicates whether the FTE figures should be
      --       apportioned for research students who haven't studied the entire academic session.
      -- Note: p_credit_points is used to return the total credit point
      --       value from which the EFTSU was calculated.
      ----------

      retcode := 0;

      l_selection_dt_from := TO_DATE(p_selection_dt_from, 'yyyy/mm/dd hh24:mi:ss');
      l_selection_dt_to   := TO_DATE(p_selection_dt_to,   'yyyy/mm/dd hh24:mi:ss');

      IF (l_selection_dt_from IS NULL AND l_selection_dt_to IS NOT NULL) OR
         (l_selection_dt_from IS NOT NULL AND l_selection_dt_to IS NULL) THEN
          fnd_message.set_name('IGS','IGS_HE_FTE_US_SEL_DT_ERR');
          errbuf  := fnd_message.get;
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          retcode := 2 ;
          RETURN ;
      END IF;

      --get the following values from the passed parameters
      p_fte_cal_type := RTRIM( SUBSTR(p_fte_cal,1,10) ) ;
      p_fte_sequence_number := TO_NUMBER( RTRIM (SUBSTR(p_fte_cal,11,6) ) ) ;

      OPEN c_fte_prd ;
      FETCH c_fte_prd INTO p_fte_start_dt , p_fte_end_dt ;
      CLOSE c_fte_prd ;

       /** logs all the parameters in the LOG **/
      --
      Fnd_Message.Set_Name('IGS','IGS_FI_ANC_LOG_PARM');
      Fnd_File.Put_Line(Fnd_File.LOG,FND_MESSAGE.GET);
      log_messages('P_FTE_CAL              ',p_fte_cal);
      log_messages('P_FTE_START_DT         ',p_fte_start_dt);
      log_messages('P_FTE_END_DT           ',p_fte_end_dt);
      log_messages('P_PERSON_ID            ',p_person_id);
      log_messages('P_PERSON_ID_GRP        ',p_person_id_grp);
      log_messages('P_COURSE_CD            ',p_course_cd);
      log_messages('P_COURSE_CAT           ',p_course_cat);
      log_messages('P_COO_ID               ',p_coo_id);
      log_messages('P_SELECTION_DT_FROM    ',p_selection_dt_from);
      log_messages('P_SELECTION_DT_TO      ',p_selection_dt_to);
      log_messages('P_ASS_RES_ST_FTE       ',p_app_res_st_fte);
      log_messages('P_ATT_PRC_ST_FTE       ',p_att_prc_st_fte);

      -- initialize fnd_dsql data-structures
      fnd_dsql.init;

      -- Construct Initial SPA Selection SQL statement.
      fnd_dsql.add_text('SELECT pe.person_number,spa.person_id, spa.course_cd ,spa.version_number,spa.coo_id,');
      fnd_dsql.add_text('       spa.course_attempt_status, spa.discontinued_dt,');
      fnd_dsql.add_text('       spa.course_rqrmnts_complete_dt, spa.commencement_dt,');
      fnd_dsql.add_text('       spa.course_rqrmnt_complete_ind, hspa.student_inst_number');
      fnd_dsql.add_text('  FROM igs_en_stdnt_ps_att_all spa, igs_he_st_spa_all hspa, igs_pe_person_base_v pe ');
      fnd_dsql.add_text(' WHERE hspa.person_id = spa.person_id ');
      fnd_dsql.add_text('   AND hspa.course_cd = spa.course_cd ');
      fnd_dsql.add_text('   AND pe.person_id = spa.person_id ');

      -- Include person id criteria if required
      IF p_person_id IS NOT NULL THEN

        fnd_dsql.add_text('   AND spa.person_id = ');
        fnd_dsql.add_bind(p_person_id);

      END IF;

      -- Include program code criteria if required
      IF p_course_cd IS NOT NULL THEN

        fnd_dsql.add_text('   AND spa.course_cd = ');
        fnd_dsql.add_bind(p_course_cd);

      END IF;

      -- Include person ID group criteria if required (person_id cannot be entered)
      IF p_person_id_grp IS NOT NULL AND p_person_id IS NULL THEN

          -- Determine type (static or dynamic) of person id group
          OPEN c_group_type;
          FETCH c_group_type INTO l_group_type;
          CLOSE c_group_type;

          IF l_group_type = 'STATIC' THEN

              fnd_dsql.add_text('    AND EXISTS ' );
              fnd_dsql.add_text('       (SELECT ''X'' ');
              fnd_dsql.add_text('          FROM igs_pe_prsid_grp_mem_all a ' );
              fnd_dsql.add_text('         WHERE a.person_id = spa.person_id ' );
              fnd_dsql.add_text('           AND a.group_id = ');
              fnd_dsql.add_bind(p_person_id_grp);
              fnd_dsql.add_text('           AND (a.end_date IS NULL OR a.end_date > sysdate) ');
              fnd_dsql.add_text(       ')');

          ELSE
              -- Use library to get dynamic person id group members
              l_prs_grp_sql := IGS_PE_DYNAMIC_PERSID_GROUP.IGS_GET_DYNAMIC_SQL(p_person_id_grp, l_prs_grp_status);

              IF l_prs_grp_status <> 'S' THEN
              fnd_message.set_name('IGS','IGS_HE_UT_PRSN_ID_GRP_ERR');
              fnd_message.set_token('PRSNIDGRP',p_person_id_grp);
              errbuf := fnd_message.get();
              fnd_file.put_line(fnd_file.log, errbuf);  -- this message need to be displayed to user.
              retcode := '2';
              RETURN;
              END IF;

              fnd_dsql.add_text(  'AND spa.person_id IN (');
              fnd_dsql.add_text(l_prs_grp_sql);
              fnd_dsql.add_text(                       ')');

          END IF; -- Static / Dynamic

      END IF; -- Person ID Group Criteria

      -- Finish constructing SPA Selection SQL statement WHERE CLAUSE
      fnd_dsql.add_text('    AND spa.commencement_dt < ' );
      fnd_dsql.add_bind(p_fte_end_dt);
      fnd_dsql.add_text('    AND (spa.discontinued_dt IS NULL OR spa.discontinued_dt > ' );
      fnd_dsql.add_bind(p_fte_start_dt);
      fnd_dsql.add_text(        ')');
      fnd_dsql.add_text('    AND (spa.course_rqrmnts_complete_dt IS NULL OR  spa.course_rqrmnts_complete_dt > ' );
      fnd_dsql.add_bind(p_fte_start_dt);
      fnd_dsql.add_text(        ')');
      fnd_dsql.add_text('    AND spa.course_attempt_status IN ');
      fnd_dsql.add_text('        (''ENROLLED'',''DISCONTIN'',''COMPLETED'',''INTERMIT'',''INACTIVE'',''LAPSED'')');

      -- If Selection dates from and to are specified append additional condition to WHERE clause
      IF l_selection_dt_from IS NOT NULL THEN

        fnd_dsql.add_text('    AND EXISTS (');
        fnd_dsql.add_text('      SELECT b.person_id, b.course_cd');
        fnd_dsql.add_text('        FROM igs_as_su_setatmpt b ');
        fnd_dsql.add_text('       WHERE b.person_id = spa.person_id ');
        fnd_dsql.add_text('         AND b.course_cd = spa.course_cd ');
        fnd_dsql.add_text('         AND b.selection_dt between ');
        fnd_dsql.add_bind(l_selection_dt_from);
        fnd_dsql.add_text(        ' AND ');
        fnd_dsql.add_bind(l_selection_dt_to);
        fnd_dsql.add_text(               ')');

      END IF;

      -- Finish constructing SPA Selection SQL statement with ORDER BY
      fnd_dsql.add_text(' ORDER BY spa.person_id, hspa.student_inst_number, discontinued_dt DESC,');
      fnd_dsql.add_text('          course_rqrmnts_complete_dt DESC,  spa.commencement_dt DESC');

      l_cursor_id := DBMS_SQL.OPEN_CURSOR;
      fnd_dsql.set_cursor(l_cursor_id);

      l_fte_calc_sql := fnd_dsql.get_text(FALSE);

      DBMS_SQL.PARSE(l_cursor_id, l_fte_calc_sql, DBMS_SQL.NATIVE);
      fnd_dsql.do_binds;

      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, c_sca_rec.person_number,30);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 2, c_sca_rec.person_id);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 3, c_sca_rec.course_cd, 6);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 4, c_sca_rec.version_number);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 5, c_sca_rec.coo_id);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 6, c_sca_rec.course_attempt_status, 30);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 7, c_sca_rec.discontinued_dt);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 8, c_sca_rec.course_rqrmnts_complete_dt);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 9, c_sca_rec.commencement_dt);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 10, c_sca_rec.course_rqrmnt_complete_ind, 1);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 11, c_sca_rec.student_inst_number, 20);

      l_num_rows := DBMS_SQL.EXECUTE(l_cursor_id);

      -- check if there are no student programs satisfying the passed parameters
      -- fetch a row
      IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
         DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
         FND_MESSAGE.SET_NAME('IGS','IGS_UC_HE_NO_DATA');
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.Get) ;
         RETURN ;

      ELSE

          FND_MESSAGE.SET_NAME('IGS','IGS_HE_FTE_PROC');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.Get) ;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------') ;

          -- loop through all the student program attempts and calculate FTE for each program attempt
          LOOP

            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1,c_sca_rec.person_number);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 2,c_sca_rec.person_id);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 3,c_sca_rec.course_cd);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 4,c_sca_rec.version_number);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 5,c_sca_rec.coo_id);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 6,c_sca_rec.course_attempt_status);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 7,c_sca_rec.discontinued_dt);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 8,c_sca_rec.course_rqrmnts_complete_dt);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 9,c_sca_rec.commencement_dt);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 10,c_sca_rec.course_rqrmnt_complete_ind);
            DBMS_SQL.COLUMN_VALUE(l_cursor_id, 11,c_sca_rec.student_inst_number);

            l_exit_flag    := FALSE ;
            l_lev_dt       := NULL;

            IF c_sca_rec.course_attempt_status IN (cst_inactive, cst_lapsed) THEN
                OPEN c_en_hist(c_sca_rec.person_id, c_sca_rec.course_cd);
                FETCH c_en_hist INTO c_en_hist_rec;
                IF (c_en_hist%NOTFOUND) THEN
                    l_exit_flag := TRUE;
                END IF;
                CLOSE c_en_hist;
            END IF;

            IF NOT l_exit_flag THEN
             -- smaddali removed code to check the Transfer table for bug#3171373.
             -- check if fte has to be calculated for the current program
             -- smaddali replaced l_fet_falg with person_id , student_inst_number comparision for bug#3171373
             IF l_old_person_id     = c_sca_rec.person_id AND
                l_old_stin          = c_sca_rec.student_inst_number  THEN
                   -- this program attempt is a continuation of the Previous program attempt
                   -- because of Program transfer and hence need not calculate FTE for this program attempt
                   -- donot replace this condition with converse condition because it requires NVL check
                   NULL;
             ELSE

               -- calculate FTE for this program as this is a new person's record
               -- and also copy this student instance number and person_id to the old value parameters
               l_old_person_id :=  c_sca_rec.person_id ;
               l_old_stin      :=  c_sca_rec.student_inst_number ;

               -- smaddali added following code for HECR214 - term based fees enhancement build , Bug#3291656
               -- to get coo_id,version_number from the Term record and validate coo_id and course_cat parameters

               -- Get the Leaving date for the student to  determine if he is a continuing student or a leaver
               l_lev_dt       := NVL(c_sca_rec.course_rqrmnts_complete_dt,c_sca_rec.discontinued_dt) ;

               -- Get the coo_id and version_number for this student program attempt from the corresponding Term record
               -- The term record is obtained based on whether the student is a leaver or a continuing student
               -- The leaving dt either lies in the Fte period in which case the student is a leaver
               -- or is GT the FTE end_dt or is NULL in this case the student is a Continuing student within the FTE period
               -- If student is a Leaver then get the corresponding Term record details
               IF l_lev_dt BETWEEN p_fte_start_dt AND p_fte_end_dt THEN
                            -- get the latest term record within which the Leaving date falls
                            c_term1_lev_rec        := NULL ;
                            OPEN c_term1_lev (c_sca_rec.person_id, c_sca_rec.course_cd, l_lev_dt );
                            FETCH c_term1_lev INTO c_term1_lev_rec ;
                            IF c_term1_lev%NOTFOUND THEN
                                -- Get the latest term record just before the Leaving date
                                c_term2_lev_rec    := NULL ;
                                OPEN c_term2_lev(c_sca_rec.person_id, c_sca_rec.course_cd, l_lev_dt ) ;
                                FETCH c_term2_lev INTO c_term2_lev_rec ;
                                IF  c_term2_lev%FOUND THEN
                                    -- Override the version_number,coo_id in the SCA record with the term record values
                                    c_sca_rec.version_number   := c_term2_lev_rec.program_version ;
                                    c_sca_rec.coo_id           := c_term2_lev_rec.coo_id ;
                                END IF ;
                                CLOSE c_term2_lev ;
                            ELSE
                                -- Override the version_number,coo_id in the SCA record with the term record values
                                c_sca_rec.version_number   := c_term1_lev_rec.program_version ;
                                c_sca_rec.coo_id           := c_term1_lev_rec.coo_id ;
                            END IF ;
                            CLOSE c_term1_lev ;
               -- If student is a continuing student then get the corresponding Term record details
               ELSE
                           -- Get the latest term record which falls within the FTE period and term start date > commencement dt
                           c_term_con_rec  := NULL ;
                           OPEN c_term_con(c_sca_rec.person_id, c_sca_rec.course_cd);
                           FETCH c_term_con INTO c_term_con_rec ;
                           IF c_term_con%FOUND THEN
                                -- Override the version_number,coo_id in the SCA record with the term record values
                                c_sca_rec.version_number   := c_term_con_rec.program_version ;
                                c_sca_rec.coo_id           := c_term_con_rec.coo_id ;
                           END IF ;
                           CLOSE c_term_con ;
               END IF ;

               -- coo_id parameter filter
               -- If the current student's coo_id doesnot match the passed coo_id parameter then skip this program attempt
               IF p_coo_id IS NOT NULL AND c_sca_rec.coo_id <> p_coo_id THEN
                        l_exit_flag := TRUE ;
               END IF;

               -- course_cat paramater filter
               -- If the current student's course is not a member of the passed course category parameter then skip this program attempt
               IF p_course_cat IS NOT NULL THEN
                       c_prg_cat_rec           := NULL;
                       OPEN c_prg_cat(c_sca_rec.course_cd, c_sca_rec.version_number ) ;
                       FETCH c_prg_cat INTO c_prg_cat_rec;
                       IF c_prg_cat%NOTFOUND THEN
                           l_exit_flag := TRUE ;
                       END IF;
                       CLOSE c_prg_cat ;
               END IF ;

            END IF;
            -- end of l_exit_flag check

                -- If the course_cat and coo_id parameter validations have passed
                -- then calculate fte for this program attempt
                IF NOT l_exit_flag  THEN

                        FND_MESSAGE.SET_NAME('IGS','IGS_HE_SPA');
                        -- smaddali moved set token to after set message name for bug 2429893
                        FND_MESSAGE.SET_TOKEN('PERSON_ID',c_sca_rec.person_number);
                        FND_MESSAGE.SET_TOKEN('COURSE_CD',c_sca_rec.course_cd);
                        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.Get) ;

                        -- check if the program attempt has been intermitted for the whole FTE period then fte=0
                        IF igs_he_extract_fields_pkg.isDormant
                            (p_person_id        => c_sca_rec.person_id,
                             p_course_cd        => c_sca_rec.course_cd,
                             p_version_number   => c_sca_rec.version_number,
                             p_enrl_start_dt    => p_fte_start_dt,
                             p_enrl_end_dt      => p_fte_end_dt)
                        THEN
                            l_Calculated_FTE :=  0;
                        ELSE

                            l_Calculated_FTE := 0 ;
                            l_fte_calc_type := NULL ;
                            l_message := NULL ;

                            -- derive the fte calculation type as per the setup,
                            -- if not able to find fte calculation type then p_message will be not null
                            fte_type_intensity (p_person_id => c_sca_rec.person_id,
                                                p_unit_set_cd => NULL,
                                                p_us_version_number => NULL,
                                                p_sequence_number => NULL,
                                                p_att_prc_st_fte  => p_att_prc_st_fte,
                                                p_coo_id => c_sca_rec.coo_id ,
                                                p_fte_calc_type => l_fte_calc_type ,
                                                p_fte_intensity => l_dummy2 ,
                                                p_selection_dt_from => l_selection_dt_from,
                                                p_selection_dt_to => l_selection_dt_to,
                                                p_message => l_message) ;

                            IF l_message IS NOT NULL OR l_fte_calc_type IS NULL THEN
                              -- ie current year of program not found  / hesa mapping for attendance type not found
                              -- implies that fte calculation type could not be found

                              FND_MESSAGE.SET_NAME('IGS','IGS_HE_NO_CALC_TYPE') ;
                              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET );
                              FND_MESSAGE.SET_NAME('IGS', l_message );
                              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET) ;
                               l_exit_flag := TRUE ; -- skip this current program attempt and go to the next program attempt
                            END IF ;

                            -- start of unit based calculation
                            IF l_fte_calc_type IN ('U','B') AND NOT l_exit_flag  THEN

                               l_total_credit_points := 0 ;
                               l_std_annual_load := NULL ;

                               --  Loop through all unit attempts for the program attempt in context
                               FOR c_sua_rec IN c_sua(c_sca_rec.person_id , c_sca_rec.course_cd) LOOP
                                  l_unit_cp := NULL ;
                                  l_unit_ver_cp := NULL ;
                                  l_app_days := NULL ;
                                  l_actual_days := NULL ;


                                  IF c_sua_rec.override_enrolled_cp IS NOT NULL THEN
                                       l_unit_cp := c_sua_rec.override_enrolled_cp ;
                                  ELSE
                                       -- get the enrolled credit points defined at unit version level
                                       OPEN c_unit_cp (c_sua_rec.uoo_id);
                                       FETCH c_unit_cp INTO l_unit_ver_cp ;
                                       CLOSE c_unit_cp ;
                                       l_unit_cp := l_unit_ver_cp ;
                                  END IF;

                                  --If the program attempt is discontinued or intermitted then
                                  -- apportion the credit points
                                  IF ( c_sua_rec.unit_attempt_status = cst_discontin AND
                                        c_sca_rec.course_attempt_status IN (cst_discontin , cst_intermit) ) THEN
                                      OPEN c_cal_inst(c_sua_rec.cal_type, c_sua_rec.ci_sequence_number );
                                      FETCH c_cal_inst INTO c_cal_inst_rec ;
                                      CLOSE c_cal_inst ;
                                      -- smaddali ,modified actual_days and app_days to add 1 after subtraction
                                      -- for bug 2453209
                                      l_actual_days :=  TRUNC(c_sua_rec.discontinued_dt) - c_cal_inst_rec.start_dt + 1 ;
                                      l_app_days :=  c_cal_inst_rec.end_dt - c_cal_inst_rec.start_dt + 1 ;
                                      l_unit_cp := l_unit_cp * ( l_actual_days / l_app_days ) ;
                                  END IF ;

                                  l_total_credit_points := l_total_credit_points + l_unit_cp  ;

                               END LOOP ;

                               -- If the current program was transferred from some other program then
                               -- completed units of the from program will also incurr load
                               OPEN c_trn_to( c_sca_rec.person_id , c_sca_rec.course_cd) ;
                               FETCH c_trn_to INTO l_trn_from_crs ;
                               IF c_trn_to%FOUND THEN

                                   FOR c_trn_from_units_rec IN c_trn_from_units(c_sca_rec.person_id ,l_trn_from_crs ) LOOP
                                      l_unit_cp := NULL ;
                                      l_unit_ver_cp := NULL ;

                                      IF c_trn_from_units_rec.override_enrolled_cp IS NOT NULL THEN
                                           l_unit_cp := c_trn_from_units_rec.override_enrolled_cp ;
                                      ELSE
                                           -- get the enrolled credit points defined at unit version level
                                           OPEN c_unit_cp(c_trn_from_units_rec.uoo_id);
                                           FETCH c_unit_cp INTO l_unit_ver_cp ;
                                           CLOSE c_unit_cp ;
                                           l_unit_cp := l_unit_ver_cp ;
                                      END IF;
                                      l_total_credit_points := l_total_credit_points + l_unit_cp ;

                                   END LOOP ;

                                END IF ;
                                CLOSE c_trn_to ;

                                -- get the standard annual load for the program
                                OPEN c_ann_load (c_sca_rec.course_cd , c_sca_rec.version_number) ;
                                FETCH c_ann_load INTO l_std_annual_load ;
                                IF l_std_annual_load  IS NULL OR l_std_annual_load = 0  THEN
                                    FND_MESSAGE.SET_NAME('IGS','IGS_HE_NO_ANN_LOAD');
                                    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET );
                                     l_exit_flag := TRUE ; -- skip this current program attempt and go to the next program attempt

                                ELSE
                                  l_calculated_FTE := l_calculated_FTE + ( ( l_total_credit_points * 100 ) / l_std_annual_load );

                                END IF;
                                CLOSE c_ann_load;

                            END IF ;
                            -- end of unit based calculation

                            -- start of intensity based calculation
                            IF l_fte_calc_type IN ('I','B') AND NOT l_exit_flag  THEN

                               -- jtmathew added for for HE357
                               -- check whether there are multiple student year of programs
                               l_multi_yop := FALSE ;
                               OPEN c_multi_yop(c_sca_rec.person_id , c_sca_rec.course_cd,
                                                l_selection_dt_from,  l_selection_dt_to);
                               FETCH c_multi_yop INTO c_multi_yop_rec;
                                  IF c_multi_yop%FOUND THEN
                                     l_multi_yop := TRUE ;
                                  END IF;
                               CLOSE c_multi_yop;

                               -- for each year of program falling in the FTE period calculate FTE
                               FOR c_crs_year_rec IN c_crs_year( c_sca_rec.person_id , c_sca_rec.course_cd,
                                                                 l_selection_dt_from,  l_selection_dt_to) LOOP
                                  -- derive the fte_intensity set up '
                                  l_fte_intensity := NULL ;
                                  l_message := NULL ;

                                  fte_type_intensity (p_person_id => c_sca_rec.person_id,
                                                      p_unit_set_cd => c_crs_year_rec.unit_set_cd,
                                                      p_us_version_number => c_crs_year_rec.us_version_number,
                                                      p_sequence_number => c_crs_year_rec.sequence_number,
                                                      p_att_prc_st_fte => p_att_prc_st_fte,
                                                      p_coo_id => c_sca_rec.coo_id ,
                                                      p_fte_calc_type => l_dummy1 ,
                                                      p_fte_intensity => l_fte_intensity ,
                                                      p_selection_dt_from => l_selection_dt_from,
                                                      p_selection_dt_to => l_selection_dt_to,
                                                      p_message => l_message) ;

                                  IF l_message IS NOT NULL OR l_fte_intensity IS NULL THEN
                                      -- ie  program has both full time and part-time offerings
                                      -- implies that fte intensity could not be found

                                      FND_MESSAGE.SET_NAME('IGS','IGS_HE_NO_INTENSITY') ;
                                      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET );
                                      FND_MESSAGE.SET_NAME('IGS', l_message );
                                      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET) ;
                                      l_exit_flag := TRUE ;
                                      EXIT ; -- exit the year of program loop and go to the next program attempt

                                  ELSE
                                       l_calculated_intensity := l_fte_intensity ;
                                       l_app_start_dt := NULL ;
                                       l_app_end_dt := NULL ;
                                       l_actual_start_dt := NULL ;
                                       l_actual_end_dt := NULL ;
                                       l_intm_part_days := 0 ;
                                       l_intm_flag := FALSE ;
                                       l_actual_days := NULL ;
                                       l_app_days := NULL ;
                                       l_message := NULL ;

                                       -- get the apportionment period i.e the length of the current year of program
                                       IF   research_st(c_sca_rec.course_cd , c_sca_rec.version_number ) THEN
                                          l_app_start_dt := p_fte_start_dt ;
                                          l_app_end_dt := p_fte_end_dt ;
                                       ELSE

                                          OPEN c_poous_app(c_sca_rec.coo_id ,c_crs_year_rec.unit_set_cd ,
                                                      c_crs_year_rec.us_version_number);
                                          FETCH c_poous_app INTO c_poous_app_rec ;
                                          IF c_poous_app%FOUND AND
                                              c_poous_app_rec.teach_period_start_dt IS NOT NULL AND
                                              c_poous_app_rec.teach_period_end_dt IS NOT NULL THEN
                                              l_app_start_dt := c_poous_app_rec.teach_period_start_dt ;
                                              l_app_end_dt := c_poous_app_rec.teach_period_end_dt ;
                                          ELSE
                                            OPEN c_prog_app(c_sca_rec.course_cd,c_sca_rec.version_number);
                                            FETCH c_prog_app INTO c_prog_app_rec ;
                                            IF c_prog_app%FOUND AND
                                               c_prog_app_rec.teach_period_start_dt IS NOT NULL AND
                                               c_prog_app_rec.teach_period_end_dt IS NOT NULL THEN
                                                 l_app_start_dt := c_prog_app_rec.teach_period_start_dt ;
                                                 l_app_end_dt := c_prog_app_rec.teach_period_end_dt ;
                                            ELSE
                                                 OPEN c_fte_app ;
                                                 FETCH c_fte_app INTO l_app_start_dt , l_app_end_dt ;
                                                 CLOSE c_fte_app ;
                                            END IF;
                                            CLOSE c_prog_app ;

                                          END IF;
                                          CLOSE c_poous_app ;

                                       END IF ;
                                       -- smaddali modified app_days to add 1 after subtraction for bug 2453209
                                       l_app_days := l_app_end_dt - l_app_start_dt + 1 ;

                                       -- check if the student has periods of intermission
                                       -- in the present apportionment period
                                       FOR c_intm_part_rec IN  c_intm_part(c_sca_rec.person_id , c_sca_rec.course_cd ,
                                               l_app_start_dt , l_app_end_dt )
                                       LOOP
                                            l_intm_flag := TRUE ;
                                            IF c_intm_part_rec.start_dt < l_app_start_dt THEN
                                                  c_intm_part_rec.start_dt := l_app_start_dt ;
                                            END IF;
                                            IF (c_intm_part_rec.end_dt > l_app_end_dt OR
                                                c_intm_part_rec.end_dt > c_sca_rec.discontinued_dt )THEN
                                                c_intm_part_rec.end_dt := NVL(c_sca_rec.discontinued_dt,l_app_end_dt) ;
                                            END IF;
                                            -- smaddali modified intm_days to add 1 after subtraction for bug 2453209
                                            l_intm_part_days :=  l_intm_part_days +
                                                  (c_intm_part_rec.end_dt - c_intm_part_rec.start_dt + 1 ) ;
                                       END LOOP ;

                                       -- calculate the actual period of study of the student in the current year of program
                                       -- in the following cases
                                       -- If the research student started or completed mid apportionment session or if he
                                       --discontinued before the end of the apportionment period then
                                       IF ( research_st(c_sca_rec.course_cd , c_sca_rec.version_number)  AND
                                            (c_sca_rec.commencement_dt > l_app_start_dt OR
                                              c_sca_rec.course_rqrmnts_complete_dt < l_app_end_dt) ) OR
                                              ( c_sca_rec.course_attempt_status = cst_discontin  AND
                                             c_sca_rec.discontinued_dt < l_app_end_dt )  OR
                                              l_intm_flag THEN

                                            -- get the actual period of the student contributing to fte for apportioning
                                            -- or remove intermission period if p_app_res_st_fte is 'N'
                                            IF  research_st(c_sca_rec.course_cd , c_sca_rec.version_number)  AND
                                                  p_app_res_st_fte = 'N' THEN

                                                  -- smaddali removed the logic based on acad_perd and hesa_mode_of_study for bug#3175107
                                                  -- apportion the fte to remove student intermissions in the fte period
                                                  l_calculated_intensity := l_calculated_intensity ;
                                                  -- If student has intermission periods then apportion the intensity
                                                  IF l_intm_flag THEN
                                                        l_calculated_intensity := l_calculated_intensity * ((l_app_days - l_intm_part_days) / l_app_days ) ;
                                                  END IF ;

                                            ELSE

                                                -- smaddali added code to derive the commencement_dt of the trasnfer from program , for bug#3171373
                                                l_trn_commencement_dt  := NULL ;
                                                OPEN  c_trn_commencement(c_sca_rec.person_id, c_sca_rec.student_inst_number ) ;
                                                FETCH c_trn_commencement INTO l_trn_commencement_dt ;
                                                CLOSE c_trn_commencement ;

                                                -- smaddali added condition to check that commencement_dt and
                                                -- discontinued_dt lie in the FTE period , for bug#3177328
                                                IF research_st(c_sca_rec.course_cd , c_sca_rec.version_number) THEN
                                                   -- use the commencement_dt of the transfer FROM program for apportioning fte
                                                   --for research students if it lies in the fte period
                                                   -- smaddali added code to consider the commencement date of
                                                   -- the transfer from program also, for bug#3171373
                                                    IF l_trn_commencement_dt > l_app_start_dt THEN
                                                         l_actual_start_dt :=  l_trn_commencement_dt ;
                                                    -- else use  this program's commencement_dt if it lies in the fte period
                                                    ELSIF c_sca_rec.commencement_dt > l_app_start_dt  THEN
                                                         l_actual_start_dt := c_sca_rec.commencement_dt ;
                                                    -- else apportion period start dt is the actual start date
                                                    ELSE
                                                         l_actual_start_dt := l_app_start_dt ;
                                                    END IF;
                                                ELSE
                                                    l_actual_start_dt := l_app_start_dt ;
                                                END IF;

                                                IF (c_sca_rec.discontinued_dt < l_app_end_dt
                                                   AND c_sca_rec.course_rqrmnt_complete_ind = 'N') THEN
                                                   l_actual_end_dt := c_sca_rec.discontinued_dt ;
                                                ELSIF (c_sca_rec.course_rqrmnts_complete_dt < l_app_end_dt) THEN
                                                   l_actual_end_dt := c_sca_rec.course_rqrmnts_complete_dt;
                                                ELSE
                                                   l_actual_end_dt := l_app_end_dt ;
                                                END IF;

                                                --smaddali modified actual_days to add 1 after subtraction of dates for bug 2453209
                                                l_actual_days := ( l_actual_end_dt - l_actual_start_dt + 1 ) - l_intm_part_days ;

                                                l_calculated_intensity := l_calculated_intensity * (l_actual_days / l_app_days ) ;

                                            END IF;
                                       END IF;

                                       -- If the program's academic year does not mirror the fte calculation period then
                                       --Adjust the fte_intensity as per the Academic calendar for the current year of program
                                       c_year_cal_rec := NULL ;
                                       l_year_cal_rec := NULL ;

                                       -- get the academic calendar instance corresponding to the current year of program
                                       OPEN c_year_cal(c_sca_rec.person_id,c_sca_rec.course_cd, c_crs_year_rec.unit_set_cd,
                                                       l_selection_dt_from, l_selection_dt_to) ;

                                       LOOP

                                           FETCH c_year_cal INTO c_year_cal_rec;
                                           EXIT WHEN c_year_cal%NOTFOUND;

                                           -- if l_year_cal_rec is null, then we are at the first row in the cursor
                                           -- so store c_year_cal_rec in l_year_cal_rec
                                           IF l_year_cal_rec.cal_type IS NULL THEN
                                               l_year_cal_rec := c_year_cal_rec;
                                           END IF;

                                           IF  (c_crs_year_rec.completion_dt IS NOT NULL) AND
                                               (c_year_cal_rec.end_dt >= c_crs_year_rec.completion_dt)
                                           THEN
                                               -- If year of program has been completed then find closest
                                               -- calendar instance to the year of program
                                               IF  (l_year_cal_rec.end_dt > c_year_cal_rec.end_dt) AND
                                                   (c_year_cal_rec.end_dt - c_crs_year_rec.completion_dt >= 0) THEN
                                                   l_year_cal_rec := c_year_cal_rec;

                                               END IF;

                                           ELSIF (c_crs_year_rec.end_dt IS NOT NULL) AND
                                                 (c_year_cal_rec.end_dt >= c_crs_year_rec.end_dt) THEN
                                               -- If year of program has been ended then find closest
                                               -- calendar instance to the year of program

                                               IF  (l_year_cal_rec.end_dt > c_year_cal_rec.end_dt) AND
                                                   (c_year_cal_rec.end_dt - c_crs_year_rec.end_dt >= 0) THEN
                                                   l_year_cal_rec := c_year_cal_rec;

                                               END IF;


                                           END IF;


                                       END LOOP;

                                       CLOSE c_year_cal ;

                                       l_fte_prop_flag := FALSE;
                                       -- get the fte% contribution by the current academic calendar instance to the fte period
                                       OPEN c_fte_prop( l_year_cal_rec.cal_type, l_year_cal_rec.sequence_number ,
                                       c_crs_year_rec.acad_perd) ;
                                       FETCH c_fte_prop INTO c_fte_prop_rec ;
                                       IF c_fte_prop%FOUND THEN
                                           l_fte_perc := c_fte_prop_rec.fte_perc ;
                                           l_fte_prop_flag := TRUE;
                                       ELSE
                                           l_fte_perc := 100;
                                       END IF;
                                       CLOSE c_fte_prop ;


                                       -- If more than one year of program for student program attempt
                                       IF l_multi_yop THEN

                                           IF l_fte_prop_flag AND l_fte_perc < 100 THEN
                                              -- This is a normal calendar proportion for year of program so calculate as normal
                                               l_calculated_intensity := (l_calculated_intensity * l_fte_perc ) / 100 ;

                                           ELSIF NOT (c_crs_year_rec.selection_dt between p_fte_start_dt and p_fte_end_dt) THEN
                                               -- Ignore all year of programs that do not have a selection date within
                                               -- the FTE calculation period
                                               l_calculated_intensity := 0;
                                           END IF;

                                       ELSE
                                           -- Only one year of program for the student program attempt that fits
                                           -- within the FTE calculation period
                                           l_calculated_intensity := (l_calculated_intensity * l_fte_perc ) / 100 ;

                                       END IF;

                                       -- summation of the calculated fte
                                       l_calculated_fte := l_calculated_fte + l_calculated_intensity ;

                                  END IF;  -- if fte intensity is found
                               END LOOP ; -- for each year of program

                            END IF ;
                            -- end of  intensity based calculation

                        END IF ; -- program intermitted for whole fte period

                        -- check if the flag to skip the current program attempt has been set
                        -- if it hasn't been set then save the fte calculated for this program attempt
                        IF  NOT l_exit_flag THEN
                          -- get the current year of program record
                          -- if not found then lof an error message and go to the next program attempt record
                          OPEN c_year(c_sca_rec.person_id , c_sca_rec.course_cd,
                                      l_selection_dt_from, l_selection_dt_to);
                          FETCH c_year INTO c_year_rec ;
                          IF c_year%FOUND THEN

                            -- if hesa unit set attempt record exists then update it else create a hesa unit set attempt
                            -- record corresponding to the oss unit set attempt record
                            OPEN c_susa_upd (c_sca_rec.person_id , c_sca_rec.course_cd , c_year_rec.unit_set_cd ,
                                    c_year_rec.sequence_number) ;
                            FETCH c_susa_upd INTO c_susa_upd_rec ;
                            IF c_susa_upd%FOUND THEN
                              -- save the calculated FTE in the student hesa unit set attempt record
                              igs_he_en_susa_pkg.update_row(
                                     X_ROWID                        => c_susa_upd_rec.rowid ,
                                     X_HESA_EN_SUSA_ID              => c_susa_upd_rec.hesa_en_susa_id ,
                                     X_PERSON_ID                    => c_susa_upd_rec.person_id ,
                                     X_COURSE_CD                    => c_susa_upd_rec.course_cd ,
                                     X_UNIT_SET_CD                  => c_susa_upd_rec.unit_set_cd ,
                                     X_US_VERSION_NUMBER            => c_susa_upd_rec.us_version_number ,
                                     X_SEQUENCE_NUMBER              => c_susa_upd_rec.sequence_number ,
                                     X_NEW_HE_ENTRANT_CD            => c_susa_upd_rec.new_he_entrant_cd ,
                                     X_TERM_TIME_ACCOM              => c_susa_upd_rec.term_time_accom ,
                                     X_DISABILITY_ALLOW             => c_susa_upd_rec.disability_allow ,
                                     X_ADDITIONAL_SUP_BAND          => c_susa_upd_rec.additional_sup_band ,
                                     X_SLDD_DISCRETE_PROV           => c_susa_upd_rec.sldd_discrete_prov,
                                     X_STUDY_MODE                   => c_susa_upd_rec.study_mode ,
                                     X_STUDY_LOCATION               => c_susa_upd_rec.study_location ,
                                     X_FTE_PERC_OVERRIDE            => c_susa_upd_rec.fte_perc_override ,
                                     X_FRANCHISING_ACTIVITY         => c_susa_upd_rec.franchising_activity ,
                                     X_COMPLETION_STATUS            => c_susa_upd_rec.completion_status,
                                     X_GOOD_STAND_MARKER            => c_susa_upd_rec.good_stand_marker ,
                                     X_COMPLETE_PYR_STUDY_CD        => c_susa_upd_rec.complete_pyr_study_cd ,
                                     X_CREDIT_VALUE_YOP1            => c_susa_upd_rec.credit_value_yop1 ,
                                     X_CREDIT_VALUE_YOP2            => c_susa_upd_rec.credit_value_yop2 ,
                                     X_CREDIT_VALUE_YOP3            => c_susa_upd_rec.credit_value_yop3 ,
                                     X_CREDIT_VALUE_YOP4            => c_susa_upd_rec.credit_value_yop4 ,
                                     X_CREDIT_LEVEL_ACHIEVED1       => c_susa_upd_rec.credit_level_achieved1 ,
                                     X_CREDIT_LEVEL_ACHIEVED2       => c_susa_upd_rec.credit_level_achieved2 ,
                                     X_CREDIT_LEVEL_ACHIEVED3       => c_susa_upd_rec.credit_level_achieved3 ,
                                     X_CREDIT_LEVEL_ACHIEVED4       => c_susa_upd_rec.credit_level_achieved4 ,
                                     X_CREDIT_PT_ACHIEVED1          => c_susa_upd_rec.credit_pt_achieved1 ,
                                     X_CREDIT_PT_ACHIEVED2          => c_susa_upd_rec.credit_pt_achieved2 ,
                                     X_CREDIT_PT_ACHIEVED3          => c_susa_upd_rec.credit_pt_achieved3 ,
                                     X_CREDIT_PT_ACHIEVED4          => c_susa_upd_rec.credit_pt_achieved4 ,
                                     X_CREDIT_LEVEL1                => c_susa_upd_rec.credit_level1 ,
                                     X_CREDIT_LEVEL2                => c_susa_upd_rec.credit_level2 ,
                                     X_CREDIT_LEVEL3                => c_susa_upd_rec.credit_level3 ,
                                     X_CREDIT_LEVEL4                => c_susa_upd_rec.credit_level4 ,
                                     X_ADDITIONAL_SUP_COST          => c_susa_upd_rec.additional_sup_cost ,
                                     X_ENH_FUND_ELIG_CD             => c_susa_upd_rec.enh_fund_elig_cd ,
                                     X_DISADV_UPLIFT_FACTOR         => c_susa_upd_rec.disadv_uplift_factor ,
                                     X_YEAR_STU                     => c_susa_upd_rec.year_stu ,
                                     X_GRAD_SCH_GRADE               => c_susa_upd_rec.grad_sch_grade ,
                                     X_MARK                         => c_susa_upd_rec.mark ,
                                     X_TEACHING_INST1               => c_susa_upd_rec.teaching_inst1 ,
                                     X_TEACHING_INST2               => c_susa_upd_rec.teaching_inst2 ,
                                     X_PRO_NOT_TAUGHT               => c_susa_upd_rec.pro_not_taught ,
                                     X_FUNDABILITY_CODE             => c_susa_upd_rec.fundability_code ,
                                     X_FEE_ELIGIBILITY              => c_susa_upd_rec.fee_eligibility ,
                                     X_FEE_BAND                     => c_susa_upd_rec.fee_band ,
                                     X_NON_PAYMENT_REASON           => c_susa_upd_rec.non_payment_reason ,
                                     X_STUDENT_FEE                  => c_susa_upd_rec.student_fee ,
                                     X_FTE_INTENSITY                => c_susa_upd_rec.fte_intensity ,
                                     X_CALCULATED_FTE               => l_calculated_fte ,
                                     X_FTE_CALC_TYPE                => c_susa_upd_rec.fte_calc_type ,
                                     X_TYPE_OF_YEAR                 => c_susa_upd_rec.type_of_year ,
                                     X_MODE                         => 'R'
                                     ) ;
                            ELSE
                               igs_he_en_susa_pkg.insert_row(
                                     X_ROWID                        => l_rowid ,
                                     X_HESA_EN_SUSA_ID              => l_hesa_en_susa_id ,
                                     X_PERSON_ID                    => c_sca_rec.person_id ,
                                     X_COURSE_CD                    => c_sca_rec.course_cd ,
                                     X_UNIT_SET_CD                  => c_year_rec.unit_set_cd ,
                                     X_US_VERSION_NUMBER            => c_year_rec.us_version_number ,
                                     X_SEQUENCE_NUMBER              => c_year_rec.sequence_number ,
                                     X_NEW_HE_ENTRANT_CD            =>  NULL ,
                                     X_TERM_TIME_ACCOM              =>  NULL ,
                                     X_DISABILITY_ALLOW             =>  NULL ,
                                     X_ADDITIONAL_SUP_BAND          =>  NULL ,
                                     X_SLDD_DISCRETE_PROV           =>  NULL ,
                                     X_STUDY_MODE                   =>  NULL ,
                                     X_STUDY_LOCATION               =>  NULL ,
                                     X_FTE_PERC_OVERRIDE            =>  NULL ,
                                     X_FRANCHISING_ACTIVITY         =>  NULL ,
                                     X_COMPLETION_STATUS            =>  NULL ,
                                     X_GOOD_STAND_MARKER            =>  NULL ,
                                     X_COMPLETE_PYR_STUDY_CD        =>  NULL ,
                                     X_CREDIT_VALUE_YOP1            =>  NULL ,
                                     X_CREDIT_VALUE_YOP2            =>  NULL ,
                                     X_CREDIT_VALUE_YOP3            =>  NULL ,
                                     X_CREDIT_VALUE_YOP4            =>  NULL ,
                                     X_CREDIT_LEVEL_ACHIEVED1       =>  NULL ,
                                     X_CREDIT_LEVEL_ACHIEVED2       =>  NULL ,
                                     X_CREDIT_LEVEL_ACHIEVED3       =>  NULL ,
                                     X_CREDIT_LEVEL_ACHIEVED4       =>  NULL ,
                                     X_CREDIT_PT_ACHIEVED1          =>  NULL ,
                                     X_CREDIT_PT_ACHIEVED2          =>  NULL ,
                                     X_CREDIT_PT_ACHIEVED3          =>  NULL ,
                                     X_CREDIT_PT_ACHIEVED4          =>  NULL ,
                                     X_CREDIT_LEVEL1                =>  NULL ,
                                     X_CREDIT_LEVEL2                =>  NULL ,
                                     X_CREDIT_LEVEL3                =>  NULL ,
                                     X_CREDIT_LEVEL4                =>  NULL ,
                                     X_ADDITIONAL_SUP_COST          =>  NULL ,
                                     X_ENH_FUND_ELIG_CD             =>  NULL ,
                                     X_DISADV_UPLIFT_FACTOR         =>  NULL ,
                                     X_YEAR_STU                     =>  NULL ,
                                     X_GRAD_SCH_GRADE               =>  NULL ,
                                     X_MARK                         =>  NULL ,
                                     X_TEACHING_INST1               =>  NULL ,
                                     X_TEACHING_INST2               =>  NULL ,
                                     X_PRO_NOT_TAUGHT               =>  NULL ,
                                     X_FUNDABILITY_CODE             =>  NULL ,
                                     X_FEE_ELIGIBILITY              =>  NULL ,
                                     X_FEE_BAND                     =>  NULL ,
                                     X_NON_PAYMENT_REASON           =>  NULL ,
                                     X_STUDENT_FEE                  =>  NULL ,
                                     X_FTE_INTENSITY                =>  NULL ,
                                     X_CALCULATED_FTE               => l_calculated_fte ,
                                     X_FTE_CALC_TYPE                => l_fte_calc_type ,
                                     X_TYPE_OF_YEAR                 => NULL ,
                                     X_MODE                         => 'R'
                                     ) ;
                            END IF; -- end of hesa unit set attempt record found
                            CLOSE c_susa_upd ;
                            FND_MESSAGE.SET_NAME('IGS','IGS_HE_FTE_SUCC');
                            -- smaddali moved set token to after set message name for bug 2429893
                            FND_MESSAGE.SET_TOKEN('UNIT_SET',c_year_rec.unit_set_cd) ;
                            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET) ;
                          ELSE
                              FND_MESSAGE.SET_NAME('IGS','IGS_HE_NO_YOP');
                              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET) ;
                          END IF ; --end of current year of program found
                          CLOSE c_year ;

                        END IF; -- end of skip the current program attempt

                END IF ;  -- End of coo_id, course_cat parameter validations

              END IF ;-- fte needs to be calculated

              -- fetch a row
              IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
                EXIT;
              END IF;

          END LOOP ; -- end looping of student program attempts

          DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

      END IF;

    END;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      retcode :=2;
      Fnd_File.Put_Line(FND_FILE.LOG,SQLERRM);
      FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.Set_Token('NAME','igs_he_fte_calc_pkg.fte_calculation');
      Errbuf := FND_MESSAGE.GET;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END fte_calculation ;

END igs_he_fte_calc_pkg;

/
