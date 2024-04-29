--------------------------------------------------------
--  DDL for Package Body IGS_CA_COMPUTE_DA_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_COMPUTE_DA_VAL_PKG" 
/* $Header: IGSCA15B.pls 120.1 2005/08/16 22:19:44 appldev noship $ */
/*****************************************************
||  Created By :  Navin Sidana
||  Created On : 10/13/2004
||  Purpose : Package for computing date alias values.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| nsidana          10/13/2004       Created
*****************************************************/
AS

FUNCTION cal_da_elt_val(p_sys_date_type    IN VARCHAR2,
		        p_cal_type         IN VARCHAR2,
		        p_seq_number       IN NUMBER,
	  	        p_org_unit         IN VARCHAR2,
		        p_prog_type        IN VARCHAR2,
		        p_prog_ver         IN VARCHAR2,
			p_app_type         IN VARCHAR2
		       ) RETURN DATE
/*****************************************************
||  Created By :  Navin Sidana
||  Created On : 10/13/2004
||  Purpose : Main proc to compute the date alias value.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| nsidana          10/13/2004       Created
*****************************************************/
IS

  CURSOR get_site_da(cp_sys_date VARCHAR2)
  IS
  SELECT date_alias
  FROM   IGS_CA_DA_CONFIGS
  WHERE  sys_date_type = cp_sys_date;

  l_org_unit VARCHAR2(30) := NULL;
  l_prg_type VARCHAR2(30) := NULL;
  l_prd_cd   VARCHAR2(30) := NULL;
  l_app_type VARCHAR2(30) := NULL;
  l_dt_alias VARCHAR2(30) := NULL;
  l_dt_val   DATE         := NULL;
  l_found    BOOLEAN      := FALSE;
  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(500);
  l_debug_str VARCHAR2(4000);
  l_seq_num NUMBER;

  FUNCTION chk_da_ovrd(p_sys_date_type IN VARCHAR2,
                       p_elt_level     IN VARCHAR2,
                       p_elt_code      IN VARCHAR2,
		       p_dt_alias      OUT NOCOPY VARCHAR2) RETURN BOOLEAN
  /*****************************************************
  ||  Created By :  Navin Sidana
  ||  Created On : 10/13/2004
  ||  Purpose : Local function to check if the DA has been
  ||            overridden at a level.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || nsidana          10/13/2004       Created
  *****************************************************/
  IS

    CURSOR cur_da_ovrd(cp_sys_date_type VARCHAR2,cp_elt_level VARCHAR2,cp_elt_code VARCHAR2)
    IS
    SELECT date_alias
    FROM   IGS_CA_DA_OVD_VALS
    WHERE  sys_date_type       = cp_sys_date_type AND
           element_code        = cp_elt_level AND
           element_code_value  = cp_elt_code;

    l_dt_alias VARCHAR2(30) := NULL;

  BEGIN

    OPEN cur_da_ovrd(p_sys_date_type,p_elt_level,p_elt_code);
    FETCH cur_da_ovrd INTO l_dt_alias;
    CLOSE cur_da_ovrd;

    IF (l_dt_alias IS NOT NULL)
    THEN
      p_dt_alias := l_dt_alias;
      RETURN TRUE;
    ELSE
      p_dt_alias := null;
      RETURN FALSE;
    END IF;
  END chk_da_ovrd;

  FUNCTION get_da_inst(p_dt_alias    IN VARCHAR2,
                       p_cal_type    IN VARCHAR2,
                       p_seq_num     IN NUMBER,
		       p_da_inst_val OUT NOCOPY DATE) RETURN BOOLEAN
  /*****************************************************
  ||  Created By :  Navin Sidana
  ||  Created On : 10/13/2004
  ||  Purpose : Local function to compute the DAI in a
  ||            calendar instance.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  nsidana         10/13/2004      Created
  ||  skpandey        17-AUG-2005     Bug:4356272
  ||                                  Added an additional level "APP_TYPE" to find the next available DA value
  *****************************************************/
  IS

    CURSOR count_dai_in_ci(cp_dt_alias VARCHAR2, cp_cal_type VARCHAR2, cp_seq_num NUMBER)
    IS
    SELECT count(*)
    FROM   IGS_CA_DA_INST
    WHERE  dt_alias           = cp_dt_alias AND
           cal_type           = cp_cal_type AND
           ci_sequence_number = cp_seq_num;


    CURSOR get_da_inst_val(cp_dt_alias VARCHAR2, cp_cal_type VARCHAR2, cp_seq_num NUMBER)
    IS
    SELECT alias_val
    FROM   IGS_CA_DA_INST_V
    WHERE  dt_alias           = cp_dt_alias AND
           cal_type           = cp_cal_type AND
           ci_sequence_number = cp_seq_num;

     l_count              NUMBER;
     l_da_inst_val        DATE;

  BEGIN
     l_count              := 0;

    OPEN count_dai_in_ci(p_dt_alias,p_cal_type,p_seq_num);
    FETCH count_dai_in_ci INTO l_count;
    CLOSE count_dai_in_ci;

    IF (l_count > 1) OR (l_count = 0)
    THEN
      p_da_inst_val := NULL;
      RETURN FALSE;    -- As multiple DAI exists in the CI and we are not sure which one to return back.
    ELSE
      -- One instance exists, return that.

      OPEN get_da_inst_val(p_dt_alias,p_cal_type,p_seq_num);
      FETCH get_da_inst_val INTO l_da_inst_val;
      CLOSE get_da_inst_val;

      IF (l_da_inst_val IS NOT NULL)
      THEN
        p_da_inst_val := l_da_inst_val;
        RETURN TRUE;
      ELSE
        p_da_inst_val := NULL;
        RETURN FALSE;
      END IF;
    END IF;
  END get_da_inst; -- <End of local function.>

BEGIN /* Main Procedure begins here */

  l_prog_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val';
  l_label      := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.start';

  l_org_unit   := p_org_unit;
  l_prg_type   := p_prog_type;
  l_prd_cd     := p_prog_ver;
  l_app_type   := p_app_type;

  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
    l_debug_str := 'Starting values : Sys Date Type ='||p_sys_date_type||'Cal Type =' || p_cal_type || 'Seq Num ='||p_seq_number ||
                   'Org Unit ='|| l_org_unit||'Prog Type ='||l_prg_type || 'Prog Ver ='||l_prd_cd || 'App_Type = '|| l_app_type;
    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
  END IF;


IF ((l_app_type IS NOT NULL) AND (NOT l_found))
  THEN
     l_dt_alias := NULL;

    IF chk_da_ovrd(p_sys_date_type,'APP_TYPE',l_app_type,l_dt_alias)
    THEN
      l_found := TRUE;
      l_dt_val := NULL;

      IF  get_da_inst(l_dt_alias,p_cal_type,p_seq_number,l_dt_val)
      THEN
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_found_for_overd_DA_at_app_type_lvl';
	  l_debug_str := 'Computed DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
	RETURN l_dt_val;
      ELSE
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_not_found_for_overd_DA_at_prog_type_lvl';
	  l_debug_str := 'Tried computing DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
        l_found   := FALSE;  -- Go up the heirarchy and try to find the next available DA value.
      END IF;
    END IF;
  END IF;


  IF ((l_prd_cd IS NOT NULL) AND (NOT l_found))
  THEN
     l_dt_alias := NULL;

    IF chk_da_ovrd(p_sys_date_type,'PRG_VER',l_prd_cd,l_dt_alias)
    THEN
      l_found   := TRUE;
      l_dt_val  := NULL;

      IF get_da_inst(l_dt_alias,p_cal_type,p_seq_number,l_dt_val)
      THEN
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_found_for_overd_DA_at_prog_ver_lvl';
	  l_debug_str := 'Computed DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
	RETURN l_dt_val;
      ELSE
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_not_found_for_overd_DA_at_prog_ver_lvl';
	  l_debug_str := 'Tried computing DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
        l_found   := FALSE;  -- Go up the heirarchy and try to find the next available DA value.
      END IF;
    END IF;
  END IF;

  IF ((l_prg_type IS NOT NULL) AND (NOT l_found))
  THEN
     l_dt_alias := NULL;

    IF chk_da_ovrd(p_sys_date_type,'PRG_TYPE',l_prg_type,l_dt_alias)
    THEN
      l_found := TRUE;
      l_dt_val := NULL;

      IF  get_da_inst(l_dt_alias,p_cal_type,p_seq_number,l_dt_val)
      THEN
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_found_for_overd_DA_at_prog_type_lvl';
	  l_debug_str := 'Computed DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
	RETURN l_dt_val;
      ELSE
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_not_found_for_overd_DA_at_prog_type_lvl';
	  l_debug_str := 'Tried computing DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
        l_found   := FALSE;  -- Go up the heirarchy and try to find the next available DA value.
      END IF;
    END IF;
  END IF;

  IF ((l_org_unit IS NOT NULL) AND (NOT l_found))
  THEN
     l_dt_alias := NULL;

    IF chk_da_ovrd(p_sys_date_type,'ORG_UNIT',l_org_unit,l_dt_alias)
    THEN
      l_found := TRUE;
      l_dt_val := NULL;

      IF  get_da_inst(l_dt_alias,p_cal_type,p_seq_number,l_dt_val)
      THEN
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_found_for_overd_DA_at_org_unit_lvl';
	  l_debug_str := 'Computed DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
	RETURN l_dt_val;
      ELSE
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_not_found_for_overd_DA_at_org_unit_lvl';
	  l_debug_str := 'Tried computing DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
        l_found   := FALSE;  -- Go up the heirarchy and try to find the next available DA value.
      END IF;
    END IF;
  END IF;

  IF (NOT l_found)
  THEN
     -- Get the SITE level default DA for the SDA.
    l_dt_alias := NULL;
    OPEN get_site_da(p_sys_date_type);
    FETCH get_site_da INTO l_dt_alias;
    CLOSE get_site_da;

    IF (l_dt_alias IS NOT NULL)
    THEN
      l_dt_val := NULL;

      IF  get_da_inst(l_dt_alias,p_cal_type,p_seq_number,l_dt_val)
      THEN
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_found_for_default_DA_at_site_lvl';
	  l_debug_str := 'Computed DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
 	RETURN l_dt_val;
      ELSE
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.DAI_not_found_for_default_DA_at_site_lvl';
	  l_debug_str := 'Tried computing DAI for values : Date Alias ='||l_dt_alias||' Cal Type ='||p_cal_type||' Seq Num ='||p_seq_number;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
        RETURN NULL;   -- NO DAI could be found out. Return NULL;
      END IF;
    ELSE
      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.No_default_DA_found_at_site_lvl';
	l_debug_str :=  null;
	fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
      END IF;
      RETURN NULL;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
    l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_val.exception_occured';
    l_debug_str :=  sqlerrm;
    fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
  END IF;
END cal_da_elt_val;

FUNCTION cal_da_elt_ofst_val(p_dt_alias     IN  VARCHAR2,
			     p_da_seq_num   IN NUMBER,
			     p_cal_type     IN  VARCHAR2,
			     p_seq_number   IN  NUMBER,
			     p_org_unit     IN VARCHAR2,
			     p_prog_type    IN VARCHAR2,
			     p_prog_ver     IN VARCHAR2,
			     p_app_type     IN VARCHAR2
			     ) RETURN DATE
/*****************************************************
||  Created By :  Navin Sidana
||  Created On : 10/13/2004
||  Purpose : Main proc to compute the date alias value
||            for FA module, considering offsets.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| nsidana          10/15/2004       Created
*****************************************************/
IS

  CURSOR cp_get_ofst_dt(cp_dt_alias VARCHAR2,cp_da_seq_num NUMBER,cp_cal_type VARCHAR2,cp_seq_num NUMBER) IS
  SELECT offset_dt_alias,offset_dai_sequence_number,offset_cal_type,offset_ci_sequence_number,ofst_override
  FROM   IGS_CA_DA_INST_OFST
  WHERE  dt_alias            = cp_dt_alias AND
         dai_sequence_number = cp_da_seq_num AND
         cal_type            = cp_cal_type AND
         ci_sequence_number  = cp_seq_num;

  l_da_ofst_level_rec	t_ofst_rec;
  l_dt_alias		VARCHAR2(30);
  l_cal_type		VARCHAR2(30);
  l_seq_num		NUMBER;
  l_da_used		VARCHAR2(30);
  l_err_msg		VARCHAR2(30);
  l_dai_val		DATE := NULL;
  l_da_seq_num		NUMBER;
  l_msg			VARCHAR2(30);
  l_final_val		DATE;
  l_org_unit		VARCHAR2(30);
  l_prog_type		VARCHAR2(30);
  l_prog_ver		VARCHAR2(30);
  l_app_type		VARCHAR2(30);
  l_prog_label		VARCHAR2(100);
  l_label		VARCHAR2(500);
  l_debug_str		VARCHAR2(4000);
  cp_get_ofst_dt_rec	cp_get_ofst_dt%ROWTYPE;

FUNCTION chk_da_ofst_lvl(p_dt_alias VARCHAR2,
			 p_da_seq_num NUMBER,
                         p_cal_type VARCHAR2,
			 p_seq_num  NUMBER) RETURN t_ofst_rec
/*****************************************************
||  Created By :  Navin Sidana
||  Created On : 10/13/2004
||  Purpose : Checks the level at which the DA has an offset.
||            Return values : 'DATE_ALIAS_INST' -- Date Alias Instance.
||                            'DATE_ALIAS'      -- Date Alais.
||                            NULL -- no offset defined.
||
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| nsidana          10/15/2004       Created
*****************************************************/
IS

-- Cursor to check if the DAI has an offset.
CURSOR chk_dai_ofst(cp_dt_alias VARCHAR2,cp_da_seq_num NUMBER,cp_cal_type VARCHAR2,cp_seq_num NUMBER)
IS
SELECT offset_dt_alias,offset_dai_sequence_number,offset_cal_type,offset_ci_sequence_number,day_offset,week_offset,month_offset,year_offset,ofst_override
FROM   IGS_CA_DA_INST_OFST
WHERE  dt_alias            = cp_dt_alias AND
       dai_sequence_number = cp_da_seq_num AND
       cal_type            = cp_cal_type AND
       ci_sequence_number  = cp_seq_num;

-- Cursor to check if the DA has an offset.
CURSOR chk_da_ofst(cp_dt_alias VARCHAR2)
IS
SELECT offset_dt_alias,day_offset,week_offset,month_offset,year_offset
FROM   IGS_CA_DA_OFST
WHERE  dt_alias = cp_dt_alias;

  chk_dai_ofst_rec     chk_dai_ofst%ROWTYPE := NULL;
  chk_da_ofst_rec      chk_da_ofst%ROWTYPE  := NULL ;
  l_da_ofst_level_rec  t_ofst_rec;

BEGIN
  OPEN chk_dai_ofst(p_dt_alias,p_da_seq_num,p_cal_type,p_seq_num);
  FETCH chk_dai_ofst INTO chk_dai_ofst_rec;

  IF (chk_dai_ofst%FOUND)
  THEN
    -- Offset found at DAI level. Record the offset relationship.
    l_da_ofst_level_rec.ofst_lvl                   := 'DATE_ALIAS_INST';
    l_da_ofst_level_rec.dt_alias		   := chk_dai_ofst_rec.offset_dt_alias;
    l_da_ofst_level_rec.da_seq_num		   := chk_dai_ofst_rec.offset_dai_sequence_number;
    l_da_ofst_level_rec.offset_cal_type            := chk_dai_ofst_rec.offset_cal_type;
    l_da_ofst_level_rec.offset_ci_sequence_number  := chk_dai_ofst_rec.offset_ci_sequence_number;
    l_da_ofst_level_rec.day_offset		   := chk_dai_ofst_rec.day_offset;
    l_da_ofst_level_rec.week_offset		   := chk_dai_ofst_rec.week_offset;
    l_da_ofst_level_rec.month_offset		   := chk_dai_ofst_rec.month_offset;
    l_da_ofst_level_rec.year_offset		   := chk_dai_ofst_rec.year_offset;
    l_da_ofst_level_rec.ofst_override		   := chk_dai_ofst_rec.ofst_override;
  ELSE
    OPEN chk_da_ofst(p_dt_alias);
    FETCH chk_da_ofst INTO chk_da_ofst_rec;

    IF (chk_da_ofst%FOUND)
    THEN
    -- Offset found at DA level. Record the offset relationship.
      l_da_ofst_level_rec.ofst_lvl		     := 'DATE_ALIAS';
      l_da_ofst_level_rec.dt_alias		     := chk_da_ofst_rec.offset_dt_alias;
--      l_da_ofst_level_rec.da_seq_num		     := chk_da_ofst_rec.offset_dai_sequence_number;
    --  l_da_ofst_level_rec.offset_cal_type            := chk_da_ofst_rec.offset_cal_type;
     -- l_da_ofst_level_rec.offset_ci_sequence_number  := chk_da_ofst_rec.offset_ci_sequence_number;
      l_da_ofst_level_rec.day_offset		     := chk_da_ofst_rec.day_offset;
      l_da_ofst_level_rec.week_offset		     := chk_da_ofst_rec.week_offset;
      l_da_ofst_level_rec.month_offset		     := chk_da_ofst_rec.month_offset;
      l_da_ofst_level_rec.year_offset		     := chk_da_ofst_rec.year_offset;
      l_da_ofst_level_rec.ofst_override		     := null;
    ELSE
    -- No offset found at any level.
      l_da_ofst_level_rec.ofst_lvl                   := null;
      l_da_ofst_level_rec.dt_alias                   := null;
      l_da_ofst_level_rec.da_seq_num		     := null;
      l_da_ofst_level_rec.offset_cal_type            := null;
      l_da_ofst_level_rec.offset_ci_sequence_number  := null;
      l_da_ofst_level_rec.day_offset                 := null;
      l_da_ofst_level_rec.week_offset                := null;
      l_da_ofst_level_rec.month_offset               := null;
      l_da_ofst_level_rec.year_offset                := null;
      l_da_ofst_level_rec.ofst_override              := null;
    END IF;
  END IF;

    IF (chk_dai_ofst%ISOPEN) THEN
      CLOSE chk_dai_ofst;
    END IF;
    IF (chk_da_ofst%ISOPEN) THEN
	CLOSE chk_da_ofst;
    END IF;
    RETURN l_da_ofst_level_rec;
END chk_da_ofst_lvl;

FUNCTION chk_da_alias_used_sda(p_dt_alias IN VARCHAR2) RETURN VARCHAR2
/*****************************************************
||  Created By :  Navin Sidana
||  Created On : 10/13/2004
||  Purpose : Checks if the DA has been used in a SDA setup.
||            Return values : 'USED_MORE_THAN_ONE' -- DA used in more than one SDA.
||                            'NOT_USED_AT_ALL'    -- DA not used in any SDA.
||                            l_sys_dt_type        -- SDA for which the DA is used in setup.
||
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| nsidana          10/15/2004       Created
*****************************************************/
AS
  CURSOR get_sda(cp_dt_alias VARCHAR2)
  IS
  SELECT sys_date_type
  FROM   IGS_CA_DA_CONFIGS
  WHERE  date_alias = cp_dt_alias;

  CURSOR get_count(cp_dt_alias VARCHAR2)
  IS
  SELECT count(*)
  FROM IGS_CA_DA_CONFIGS
  WHERE  date_alias = cp_dt_alias;

  l_sys_dt_type VARCHAR2(30);
  l_count       NUMBER;

BEGIN
  l_count := 0;
  OPEN  get_count(p_dt_alias);
  FETCH get_count INTO l_count;
  CLOSE get_count;
  IF (l_count = 1)
  THEN
    OPEN  get_sda(p_dt_alias);
    FETCH get_sda INTO l_sys_dt_type;
    CLOSE get_sda;
    RETURN l_sys_dt_type;
  ELSIF(l_count = 0)
  THEN
    RETURN 'NOT_USED_AT_ALL';
  ELSE
    RETURN 'USED_MORE_THAN_ONE';
  END IF;
END chk_da_alias_used_sda;

FUNCTION add_offset(p_dai_val           IN DATE,
                    l_da_ofst_level_rec IN t_ofst_rec) RETURN DATE
/*****************************************************
||  Created By :  Navin Sidana
||  Created On : 10/13/2004
||  Purpose : Function to add offsets to a DATE.
||
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| nsidana          10/15/2004       Created
*****************************************************/
IS
 l_ret_date DATE := NULL;
BEGIN
   l_ret_date := p_dai_val;

  IF (NVL(l_da_ofst_level_rec.year_offset,0) <> 0)
  THEN
  	l_ret_date := add_months(l_ret_date, (l_da_ofst_level_rec.year_offset * 12));
  END IF;

  IF (NVL(l_da_ofst_level_rec.month_offset,0) <> 0)
  THEN
	l_ret_date := add_months(l_ret_date, l_da_ofst_level_rec.month_offset);
  END IF;

  IF (NVL(l_da_ofst_level_rec.week_offset,0) <> 0)
  THEN
	l_ret_date := l_ret_date + (l_da_ofst_level_rec.week_offset * 7);
  END IF;

  IF (NVL(l_da_ofst_level_rec.day_offset,0) <> 0)
  THEN
	l_ret_date := l_ret_date + l_da_ofst_level_rec.day_offset;
  END IF;

  RETURN l_ret_date;
END;

BEGIN /* Main */

  l_prog_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val';
  l_label      := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.start';

  l_dt_alias    :=  p_dt_alias;
  l_da_seq_num  :=  p_da_seq_num;
  l_cal_type    :=  p_cal_type;
  l_seq_num     :=  p_seq_number;
  l_org_unit    :=  p_org_unit;
  l_prog_type   :=  p_prog_type;
  l_prog_ver    :=  p_prog_ver;
  l_app_type    :=  p_app_type;
  l_dai_val     :=  NULL;                -- To be returned by the function call.

  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
    l_debug_str := 'Starting values : Date Alias ='||l_dt_alias||' DAI seq num ='||l_da_seq_num||' Cal Type ='||l_cal_type||' Seq Num ='||l_seq_num||
                   ' Org Unit ='||l_org_unit||' Prog Type ='||l_prog_type||' Prog Ver ='||l_prog_ver || ' App_Type = '|| l_app_type;
    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
  END IF;

  l_da_ofst_level_rec := chk_da_ofst_lvl(l_dt_alias,l_da_seq_num,l_cal_type,l_seq_num);

  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
    l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.offset_level_info';
    l_debug_str := 'Offset Level ='||l_da_ofst_level_rec.ofst_lvl    ||
		    'Offset DA =   '||l_da_ofst_level_rec.dt_alias||
		    'Offset DAI Seq num ='||l_da_ofst_level_rec.da_seq_num	||
		    'Offset DA Cal Type ='||l_da_ofst_level_rec.offset_cal_type ||
		    'Offset DA Seq Num ='||l_da_ofst_level_rec.offset_ci_sequence_number ||
		    'Day Offset ='||l_da_ofst_level_rec.day_offset	  ||
		    'Week Offset ='||l_da_ofst_level_rec.week_offset||
		    'Month Offset ='||l_da_ofst_level_rec.month_offset||
		    'Year Offset ='||l_da_ofst_level_rec.year_offset ||
		   'Offset override flag ='||l_da_ofst_level_rec.ofst_override;
    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
  END IF;

  IF (l_da_ofst_level_rec.ofst_lvl IS NULL)
  THEN
     -- No offset defined at any level.
    l_da_used     := chk_da_alias_used_sda(l_dt_alias);

    IF (l_da_used = 'NOT_USED_AT_ALL')
    THEN
 	-- Call old API directly and return the value of the DAI.
	l_dai_val := IGS_CA_GEN_001.calp_get_alias_val(l_dt_alias,l_da_seq_num,l_cal_type,l_seq_num);
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.DA_not_used_in_SDA';
          l_debug_str :=  'Computing DAI using values : Date Alias ='||l_dt_alias||' DAI Seq num ='||l_da_seq_num||' Cal Type ='||l_cal_type||' Seq num ='||l_seq_num;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;
        RETURN l_dai_val;
    ELSIF (l_da_used = 'USED_MORE_THAN_ONE')
    THEN
 	-- Call old API directly and return the value of the DAI.
	l_dai_val := IGS_CA_GEN_001.calp_get_alias_val(l_dt_alias,l_da_seq_num,l_cal_type,l_seq_num);

	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label       := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.DA_used_in_more_than_one_SDA';
          l_debug_str :=  'Computing DAI for original DAI : Date Alias ='||l_dt_alias||' DAI Seq num ='||l_da_seq_num||' Cal Type ='||l_cal_type||' Seq num ='||l_seq_num;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
      END IF;

      RETURN l_dai_val;
    ELSE
      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.DA_used_in_single_SDA';
       l_debug_str := 'Calling generic function with values : Sys Date Type ='||l_da_used||
	              'Cal Type ='||l_cal_type||' Seq Num ='||l_seq_num||' Org Unit ='||l_org_unit||' Prog Type ='||l_prog_type||' Prog Ver ='||l_prog_ver || ' App_Type = '|| l_app_type;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
      END IF;
      l_dai_val := cal_da_elt_val(l_da_used,l_cal_type,l_seq_num,l_org_unit,l_prog_type,l_prog_ver, l_app_type);
      IF (l_dai_val IS NOT NULL)
      THEN
        RETURN l_dai_val;
      ELSE
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.No_value_returned_by_generic_function ';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,null, NULL,NULL,NULL,NULL,NULL,null);
        END IF;
        RETURN null;
      END IF;
    END IF;
  ELSIF (l_da_ofst_level_rec.ofst_lvl = 'DATE_ALIAS') OR (l_da_ofst_level_rec.ofst_lvl = 'DATE_ALIAS_INST')
  THEN
     IF ((l_da_ofst_level_rec.ofst_lvl = 'DATE_ALIAS_INST')  AND (l_da_ofst_level_rec.ofst_override = 'N' ))
    THEN
      -- Override flag set to 'N', compute the DAI for the offset DA and add the offset and return the value.
      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.ofst_ovrd_uncheck_computing_DAI_value_for_passed_DA';
       l_debug_str := 'Using : Ofst DA ='||l_da_ofst_level_rec.dt_alias||' Ofst DA seq num ='||l_da_ofst_level_rec.da_seq_num||
                      'Ofst Cal Type ='||l_da_ofst_level_rec.offset_cal_type||' Ofst CI seq num ='||l_da_ofst_level_rec.offset_ci_sequence_number;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
      END IF;
      l_dai_val   := IGS_CA_GEN_001.calp_get_alias_val(l_da_ofst_level_rec.dt_alias,l_da_ofst_level_rec.da_seq_num,l_da_ofst_level_rec.offset_cal_type,l_da_ofst_level_rec.offset_ci_sequence_number);
      l_dai_val   := add_offset(l_dai_val,l_da_ofst_level_rec);

      -- Last step : resolve constraints if any, using IGS_CA_GEN_002.calp_clc_daio_cnstrt.

      l_msg := NULL;

      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.resolving_constraints';
       l_debug_str := 'Resolving cnstrt on : Date Alias ='||l_dt_alias||'Date Alias seq num ='||l_da_seq_num||'Cal type ='||l_cal_type||'Seq num ='||l_seq_num||'DAI value ='||l_dai_val;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
      END IF;

      l_final_val := IGS_CA_GEN_002.calp_clc_daio_cnstrt(l_dt_alias,
				                         l_da_seq_num,
							 l_cal_type,
						         l_seq_num,
						         l_dai_val,
						         l_msg);
     IF (l_msg IS NOT NULL)
     THEN
       -- Could not resolve constrints, return the computed date value with the constraints unresolved.
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.constraints_not_resolved_returning_unresolved';
          l_debug_str :=  l_msg;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;
       RETURN l_dai_val;
     ELSE
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.constraints_resolved_returning_value';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,null, NULL,NULL,NULL,NULL,NULL,null);
        END IF;
       RETURN l_final_val;
     END IF;
    END IF;

    -- Offset override is 'Y'. Go for the element level override logic.

    l_da_used := chk_da_alias_used_sda(l_da_ofst_level_rec.dt_alias);

    IF (l_da_used = 'NOT_USED_AT_ALL')
    THEN
      -- DA not used in any SDA, return the value for the initial DAI passsed.
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.ovrd_DA_not_used_in_sda';
          l_debug_str :=  'Computing DAI for initial values : Date Alias ='||l_dt_alias||'Seq num ='|| l_da_seq_num || ' Cal Type ='||l_cal_type || ' Seq num ='||l_seq_num;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;

      l_dai_val := IGS_CA_GEN_001.calp_get_alias_val(l_dt_alias,l_da_seq_num,l_cal_type,l_seq_num);
      RETURN l_dai_val;
    ELSIF (l_da_used = 'USED_MORE_THAN_ONE')
    THEN
       -- DA not used in any SDA, return the value for the initial DAI passsed.
      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.ovrd_DA_used_in_more_than_one_SDA';
        l_debug_str :=  'Returning DAI for original values : Date Alias ='||l_dt_alias||'Seq num ='|| l_da_seq_num || ' Cal Type ='||l_cal_type || ' Seq num ='||l_seq_num;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
      END IF;
      l_dai_val := IGS_CA_GEN_001.calp_get_alias_val(l_dt_alias,l_da_seq_num,l_cal_type,l_seq_num);
      RETURN l_dai_val;
    ELSE
       -- Call generic to return the date value. If it returns add the offset and return.
      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.ovrd_DA_used_in_single_SDA';
        l_debug_str :=  'Calling generic function with values : Date Alias ='||l_da_used|| ' Cal Type ='||l_cal_type||' Seq num ='||l_seq_num|| ' Org Unit ='||l_org_unit||
                        'Prog Type ='||l_prog_type||' Prog Ver ='||l_prog_ver||' App Type ='||l_app_type;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
      END IF;

      l_dai_val  := cal_da_elt_val(l_da_used,l_cal_type,l_seq_num,l_org_unit,l_prog_type,l_prog_ver, l_app_type);

      IF (l_dai_val IS NULL)
      THEN
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.generic_function_returned_null';
          l_debug_str :=  null;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;
        RETURN null;
      ELSE
         l_dai_val := add_offset(l_dai_val,l_da_ofst_level_rec);
 	 l_msg := NULL;

        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
         l_label     := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.got_DAI_resolving_constraints';
         l_debug_str := 'Resolving cnstrt on : Date Alias ='||l_dt_alias||'Date Alias seq num ='||l_da_seq_num||'Cal type ='||l_cal_type||'Seq num ='||l_seq_num||'DAI value ='||l_dai_val;
         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;
        l_final_val := IGS_CA_GEN_002.calp_clc_daio_cnstrt(l_dt_alias,
				                            l_da_seq_num,
							    l_cal_type,
						            l_seq_num,
						            l_dai_val,
						            l_msg);
        IF (l_msg IS NOT NULL)
        THEN
          -- Could not resolve constrints, return the computed date value with the constraints unresolved.
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.constraints_not_resolved_returning_unresolved';
          l_debug_str :=  l_msg;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;
           RETURN l_dai_val;
        ELSE
          IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
            l_label := 'igs.plsql.igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val.constraints_resolved';
            l_debug_str :=  null;
            fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
          END IF;
          RETURN l_final_val;
        END IF;
      END IF;
    END IF;
  END IF;
END cal_da_elt_ofst_val;
END IGS_CA_COMPUTE_DA_VAL_PKG;

/
