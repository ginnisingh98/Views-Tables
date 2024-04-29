--------------------------------------------------------
--  DDL for Package Body IGF_AP_AWD_YR_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_AWD_YR_SETUP" AS
/* $Header: IGFAP31B.pls 115.1 2003/06/16 14:34:08 brajendr noship $ */
/*
  ||  Created By :  cdcruz
  ||  Created On :  01 Jun 2003
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)

*/

 PROCEDURE  p_validate_aw_year ( p_sys_awd_yr       IN           VARCHAR2,  -- System award year
                                 p_return_val       OUT NOCOPY   VARCHAR2)
 AS
  /*
  ||  Created By :  cdcruz
  ||  Created On :  01 Jun 2003
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||
  ||  (reverse chronological order - newest change first)
 */
       -- Initialize the local variables


  CURSOR cur_award IS
  SELECT
   SUBSTR(sys_award_year,4) code,
   award_year_status_code status,
   sys_award_year_mean
  FROM
   igf_ap_batch_aw_map_v
  WHERE
   sys_award_year like 'LI%'
  UNION
  SELECT
   '20'||SUBSTR(sys_award_year,0,2) code,
   award_year_status_code status,
   sys_award_year_mean
  FROM
   igf_ap_batch_aw_map_v
  WHERE
   Sys_award_year NOT LIKE 'LI%'
  ORDER BY 1;

    lv_cur_rec cur_award%rowtype;

    lv_prev_year     NUMBER;
    lv_curr_year     NUMBER;
    lv_prev_status   igf_ap_batch_aw_map.award_year_status_code%TYPE;
    lv_curr_status   igf_ap_batch_aw_map.award_year_status_code%TYPE;
    l_valid          BOOLEAN ;
    l_profile_set    VARCHAR2(30);
    l_school         VARCHAR2(10) := 'US';

  BEGIN

    lv_prev_year    := 0;
    lv_curr_year    := 0;
    lv_prev_status  := NULL;
    lv_curr_status  := NULL;
    l_valid         := TRUE;
    p_return_val    := 'VALID' ;

    l_profile_set := igf_ap_gen.check_profile ;

    IF NVL(l_profile_set,'N') <> 'Y' THEN
       l_school  := 'UK';
    END IF;

    OPEN cur_award;
    LOOP
      FETCH cur_award INTO lv_cur_rec;
      EXIT WHEN cur_award%NOTFOUND;

      lv_curr_year   := TO_NUMBER(lv_cur_rec.code);
      lv_curr_status := lv_cur_rec.status;

      IF lv_curr_status IS NOT NULL AND
        lv_prev_status IS NOT NULL THEN

        IF (lv_curr_year - 1) <> lv_prev_year THEN

          fnd_message.set_name('IGF','IGF_AW_SETUP_GAP_E1');
          fnd_message.set_token('SYS_AWD_YEAR',lv_cur_rec.sys_award_year_mean);
          fnd_msg_pub.add;
          l_valid := FALSE;
          CLOSE cur_award;
          EXIT;
        END IF;

      END IF;

      IF l_school = 'UK' THEN
         l_valid := TRUE;
      ELSE

        IF lv_curr_year < 2002 AND lv_curr_status NOT IN ('LE','LA') THEN
          fnd_message.set_name('IGF','IGF_AW_SETUP_DET_E1');
          fnd_message.set_token('SYS_AWD_YEAR',lv_cur_rec.sys_award_year_mean);
          fnd_msg_pub.add;
          l_valid := FALSE;
          CLOSE cur_award;
          EXIT;
        END IF;

        IF lv_prev_status = 'LE' THEN

          IF lv_curr_status = 'LE' THEN
            fnd_message.set_name('IGF','IGF_AW_SETUP_LE_DUP');
            fnd_message.set_token('SYS_AWD_YEAR',lv_cur_rec.sys_award_year_mean);
            fnd_msg_pub.add;
            l_valid := FALSE;
            CLOSE cur_award;
            EXIT;

          END IF;

        ELSIF lv_prev_status = 'LA' THEN

          IF lv_curr_status = 'LE' THEN
            fnd_message.set_name('IGF','IGF_AW_SETUP_ORD_E1');
            fnd_message.set_token('SYS_AWD_YEAR',lv_cur_rec.sys_award_year_mean);
            fnd_msg_pub.add;
            l_valid := FALSE;
            CLOSE cur_award;
            EXIT;

          END IF;

        ELSIF lv_prev_status =  'LD' THEN
          --
          -- Current Status should not be in ('LA','LE')
          --
          IF lv_curr_status IN ('LA') THEN
            fnd_message.set_name('IGF','IGF_AW_SETUP_ORD_E2');
            fnd_message.set_token('SYS_AWD_YEAR',lv_cur_rec.sys_award_year_mean);
            fnd_msg_pub.add;
            l_valid := FALSE;
            CLOSE cur_award;
            EXIT;
          END IF;

           IF lv_curr_status IN ('LE') THEN
              fnd_message.set_name('IGF','IGF_AW_SETUP_ORD_E1');
              fnd_message.set_token('SYS_AWD_YEAR',lv_cur_rec.sys_award_year_mean);
              fnd_msg_pub.add;
              l_valid := FALSE;
              CLOSE cur_award;
              EXIT;
           END IF;

        ELSIF lv_prev_status = 'O' THEN
          --
          -- Current Status should not be in ('LA','LE','LD')
          --
          IF lv_curr_status IN ('LA','LE','LD') THEN

            IF lv_curr_status IN ('LE') THEN
              fnd_message.set_name('IGF','IGF_AW_SETUP_ORD_E1');
            ELSIF lv_curr_status IN ('LA') THEN
              fnd_message.set_name('IGF','IGF_AW_SETUP_ORD_E2');
            ELSIF lv_curr_status IN ('LD') THEN
              fnd_message.set_name('IGF','IGF_AW_SETUP_ORD_E3');
            END IF;

            fnd_message.set_token('SYS_AWD_YEAR',lv_cur_rec.sys_award_year_mean);
            fnd_msg_pub.add;
            l_valid := FALSE;
            CLOSE cur_award;
            EXIT;

          END IF;

        ELSIF lv_prev_status =  'C' THEN
          --
          -- Current Status should not be in ('LA','LE','LD')
          --
          IF lv_curr_status IN ('LA','LE','LD') THEN

            IF lv_curr_status IN ('LE') THEN
              fnd_message.set_name('IGF','IGF_AW_SETUP_ORD_E1');
            ELSIF lv_curr_status IN ('LA') THEN
              fnd_message.set_name('IGF','IGF_AW_SETUP_ORD_E2');
            ELSIF lv_curr_status IN ('LD') THEN
              fnd_message.set_name('IGF','IGF_AW_SETUP_ORD_E3');
            END IF;

            fnd_message.set_token('SYS_AWD_YEAR',lv_cur_rec.sys_award_year_mean);
            fnd_msg_pub.add;
            l_valid := FALSE;
            CLOSE cur_award;
            EXIT;
          END IF;

        END IF;
      END IF;

      lv_prev_status := lv_curr_status;
      lv_prev_year   := lv_curr_year;

    END LOOP;

    IF l_valid THEN
      p_return_val := 'VALID' ;
    ELSE
      p_return_val := 'INVALID' ;
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','p_validate_aw_year');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END p_validate_aw_year;

END igf_ap_awd_yr_setup;

/
