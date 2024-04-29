--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_SYS_DT_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_SYS_DT_TYPE_PKG" AS
/* $Header: IGSCA16B.pls 120.1 2005/08/11 05:39:26 appldev noship $ */
/*****************************************************
||  Created By :  Navin Sidana
||  Created On :  11/4/2004
||  Purpose : Package for validating System date types
||  for each module.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| nsidana          10/13/2004       Created
*****************************************************/

 CURSOR chk_one_per_flag(cp_sys_date_type VARCHAR2)
 IS
 SELECT one_per_cal_flag
 FROM IGS_CA_DA_CONFIGS
 WHERE sys_date_type = cp_sys_date_type;

 l_err_msg varchar2(30);
 l_one_per_cal_flag varchar2(1);


 FUNCTION chk_one_per_cal(p_dt_alias IN VARCHAR2,
                           p_cal_type IN VARCHAR2,
			   p_seq_num IN NUMBER)  RETURN VARCHAR2
 IS
   CURSOR count_dai_ci
   IS
   SELECT count(*)
   FROM   IGS_CA_DA_INST
   WHERE  dt_alias           = p_dt_alias AND
          cal_type           = p_cal_type AND
          ci_sequence_number = p_seq_num;

   l_count NUMBER := 0;
 BEGIN
   OPEN count_dai_ci;
   FETCH count_dai_ci INTO l_count;
   CLOSE count_dai_ci;

   IF (l_count > 1)
   THEN
     return 'IGS_CA_DA_GR_THAN_ONE_INST';
   ELSE
     return NULL;
   END IF;
 END chk_one_per_cal;

  PROCEDURE execute_validation_proc(proc_name IN VARCHAR2,p_sys_date IN VARCHAR2,p_dt_alias IN VARCHAR2,p_cal_type IN VARCHAR2,p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  l_stmt varchar2(2000) := null;
  l_out varchar2(2000);
  BEGIN
    l_stmt := 'BEGIN '||proc_name||'( p_sys_date_type => :1,p_dt_alias      => :2,p_cal_type      => :3,p_seq_num       => :4,p_err_msg_list  => :5);  END;';
    EXECUTE IMMEDIATE(l_stmt) USING p_sys_date,p_dt_alias,p_cal_type,p_seq_num, OUT l_out;
    p_err_msg_list := l_out;
    RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    p_err_msg_list := NULL;
  END;

 PROCEDURE val_ad_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
 IS
 BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||'*'||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  PROCEDURE val_en_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  PROCEDURE val_rec_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  PROCEDURE val_fi_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  PROCEDURE val_ps_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  PROCEDURE val_sws_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  PROCEDURE val_rct_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  PROCEDURE val_fa_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  PROCEDURE val_ucas_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  PROCEDURE val_hesa_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   p_err_msg_list := NULL;
   l_one_per_cal_flag  := 'N';
   OPEN chk_one_per_flag(p_sys_date_type);
   FETCH chk_one_per_flag INTO l_one_per_cal_flag;
   CLOSE chk_one_per_flag;
   IF (l_one_per_cal_flag = 'Y')
   THEN
     -- check if the passed DA violates the one per cal restriction.
     l_err_msg := chk_one_per_cal(p_dt_alias,p_cal_type,p_seq_num);
     IF (l_err_msg IS NOT NULL) THEN
       p_err_msg_list := p_err_msg_list||l_err_msg;
     END IF;
   END IF;
   /*
      More logic to be coded by individual teams
   */
   RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;
END igs_ca_val_sys_dt_type_pkg;

/
