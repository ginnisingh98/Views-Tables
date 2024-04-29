--------------------------------------------------------
--  DDL for Package Body IGS_PS_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GEN_006" AS
/* $Header: IGSPS06B.pls 120.4 2006/02/13 01:18:50 sommukhe ship $ */
--  Who                  When                             What
--sarakshi               30-Apr-2004                      Bug#3568858, Added parameters ovrd_wkld_val_flag, workload_val_code to crsp_ins_uv_hist .
--sarakshi               03-Nov-2003                      Enh#3116171,Modified the procedure crsp_ins_uv_hist to include a new parameter p_billing_credit_points
--sarakshi               02-Sep-2003                      Enh#3052452,removed the reference of the column sup_unit_allowed_ind and sub_unit_allowed_ind
-- shtatiko             03-FEB-2003                      Bug# 2550411, Modified crsp_ins_ci_uop_uoo procedure and added
--                                                       the procedure, log_parameters.
-- shtatiko             25-OCT-2002                      Added auditable_ind, audit_permission_ind and max_auditors_allowed
--                                                       parameters to igs_ps_unit_ver_hist_pkg.insert_row call in
--                                                       crsp_ins_uv_hist procedure. This has been done as part of Bug# 2636716.
-- jbegum               11 Sep   02                      As part of bug fix of bug #2563596
--                                                       removed the space present at the end of message string
--                                                       during the assignment of message IGS_PS_SUCCESSROLL_UOO_UAI
--                                                       to local variable gv_message
--                                                       Also replaced message name OSS_CRS_PAR_ROLL_UOP_UO_UAI with
--                                                       IGS_PS_PAR_ROLL_UOP_UO_UAI and message name OSS_CRS_PARROLL_UOP_UO_UAI
--                                                       with IGS_PS_PARROLL_UOP_UO_UAI
-- jbegum               18 April 02                      As part of bug fix of bug #2322290 and bug#2250784
--                                                       Removed the following 4 columns
--                                                       BILLING_CREDIT_POINTS,BILLING_HRS,FIN_AID_CP,FIN_AID_HRS
--                                                       from crsp_ins_uv_hist procedure.
-- rgangara 03-May-2001 modified by adding 2 more parameters as per DLD Unit Section Enrollment Info.

PROCEDURE log_parameters ( p_c_param_name    VARCHAR2 ,
                           p_c_param_value   VARCHAR2
                         ) IS
/***********************************************************************************************

  Created By     :  SHTATIKO
  Date Created By:  31-JAN-2003

  Purpose        :  To log the parameters. This has been added as part of Bug Fix 2550411.

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
  smvk   09-Jul-2004 Bug # 3676145. Modified the cursor c_ucl to select active (not closed) unit classes.
********************************************************************************************** */
BEGIN
  fnd_message.set_name('IGS','IGS_PS_DEL_PRIORITY_LOG');
  fnd_message.set_token('PARAMETER_NAME', p_c_param_name );
  fnd_message.set_token('PARAMETER_VAL' , p_c_param_value ) ;
  fnd_file.put_line(fnd_file.LOG,FND_MESSAGE.GET);
END log_parameters  ;


FUNCTION crsp_get_ucl_mode(
  p_unit_class IN VARCHAR2 )
RETURN VARCHAR2 AS
        CURSOR c_ucl (cp_unit_class     IGS_AS_UNIT_CLASS.unit_class%TYPE) IS
        SELECT  unit_mode
        FROM    IGS_AS_UNIT_CLASS
        WHERE unit_class = cp_unit_class
	AND   closed_ind = 'N';
        v_unit_mode     IGS_AS_UNIT_CLASS.unit_mode%TYPE;
BEGIN
        IF p_unit_class IS NULL THEN
                RETURN NULL;
        ELSE
                OPEN c_ucl (p_unit_class);
                FETCH c_ucl INTO v_unit_mode;
                IF c_ucl%NOTFOUND THEN
                        CLOSE c_ucl;
                        RETURN NULL;
                ELSE
                        CLOSE c_ucl;
                        RETURN v_unit_mode;
                END IF;
        END IF;
END crsp_get_ucl_mode;

FUNCTION crsp_get_uoo_id(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 )
RETURN NUMBER AS
BEGIN
DECLARE
        v_uoo_id                igs_ps_unit_ofr_opt.uoo_id%TYPE;
        -- this cursor used when primary key is passed
        CURSOR  c_uoo IS
                SELECT  IGS_PS_UNIT_OFR_OPT.uoo_id
                FROM    IGS_PS_UNIT_OFR_OPT
                WHERE   IGS_PS_UNIT_OFR_OPT.unit_cd = p_unit_cd AND
                        IGS_PS_UNIT_OFR_OPT.version_number = p_version_number AND
                        IGS_PS_UNIT_OFR_OPT.cal_type = p_cal_type AND
                        IGS_PS_UNIT_OFR_OPT.ci_sequence_number = p_ci_sequence_number AND
                        IGS_PS_UNIT_OFR_OPT.location_cd = p_location_cd AND
                        IGS_PS_UNIT_OFR_OPT.unit_class = p_unit_class;
BEGIN
        -- This module returns the IGS_PS_UNIT offering option ID for the specified
        -- IGS_PS_UNIT offering option.
        OPEN c_uoo;
        FETCH c_uoo INTO v_uoo_id;
        IF c_uoo%NOTFOUND THEN
                CLOSE c_uoo;
                RETURN NULL;
        END IF;
        CLOSE c_uoo;
        RETURN v_uoo_id;
END;
END crsp_get_uoo_id;

PROCEDURE crsp_get_uoo_key(
  p_unit_cd IN OUT NOCOPY VARCHAR2 ,
  p_version_number IN OUT NOCOPY NUMBER ,
  p_cal_type IN OUT NOCOPY VARCHAR2 ,
  p_ci_sequence_number IN OUT NOCOPY NUMBER ,
  p_location_cd IN OUT NOCOPY VARCHAR2 ,
  p_unit_class IN OUT NOCOPY VARCHAR2 ,
  p_uoo_id IN OUT NOCOPY NUMBER )
AS
BEGIN
DECLARE
        lv_param_values                 VARCHAR2(1080);
        gv_unit_offering_option_rec     IGS_PS_UNIT_OFR_OPT%ROWTYPE;
        -- this cursor used when primary key is passed
        CURSOR  c_unit_offering_option_prim(
                        cp_unit_cd IGS_PS_UNIT_OFR_OPT.unit_cd%TYPE,
                        cp_version_number IGS_PS_UNIT_OFR_OPT.version_number%TYPE,
                        cp_cal_type IGS_PS_UNIT_OFR_OPT.cal_type%TYPE,
                        cp_ci_sequence_number IGS_PS_UNIT_OFR_OPT.ci_sequence_number%TYPE,
                        cp_location_cd IGS_PS_UNIT_OFR_OPT.location_cd%TYPE,
                        cp_unit_class IGS_PS_UNIT_OFR_OPT.unit_class%TYPE) IS
                SELECT  IGS_PS_UNIT_OFR_OPT.uoo_id
                FROM    IGS_PS_UNIT_OFR_OPT
                WHERE   IGS_PS_UNIT_OFR_OPT.unit_cd = cp_unit_cd AND
                        IGS_PS_UNIT_OFR_OPT.version_number = cp_version_number AND
                        IGS_PS_UNIT_OFR_OPT.cal_type= cp_cal_type AND
                        IGS_PS_UNIT_OFR_OPT.ci_sequence_number = cp_ci_sequence_number AND
                        IGS_PS_UNIT_OFR_OPT.location_cd = cp_location_cd AND
                        IGS_PS_UNIT_OFR_OPT.unit_class = cp_unit_class;
        -- this cursor is used when unique key is passed
        CURSOR  c_unit_offering_option_uniq(
                        cp_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
                SELECT  *
                FROM    IGS_PS_UNIT_OFR_OPT
                WHERE   IGS_PS_UNIT_OFR_OPT.uoo_id = cp_uoo_id;
BEGIN
        -- This module returns IGS_PS_UNIT_OFR_OPT primary key
        -- or unique key depending on the parameters
        IF (p_unit_cd IS NOT NULL) THEN
                OPEN c_unit_offering_option_prim(p_unit_cd,
                                                 p_version_number,
                                                 p_cal_type,
                                                 p_ci_sequence_number,
                                                 p_location_cd,
                                                 p_unit_class);
                FETCH c_unit_offering_option_prim INTO p_uoo_id;
                CLOSE c_unit_offering_option_prim;
        ELSIF p_uoo_id IS NOT NULL THEN
                OPEN c_unit_offering_option_uniq(p_uoo_id);
                FETCH c_unit_offering_option_uniq INTO gv_unit_offering_option_rec;
                p_unit_cd := gv_unit_offering_option_rec.unit_cd;
                p_version_number := gv_unit_offering_option_rec.version_number;
                p_cal_type := gv_unit_offering_option_rec.cal_type;
                p_ci_sequence_number := gv_unit_offering_option_rec.ci_sequence_number;
                p_location_cd := gv_unit_offering_option_rec.location_cd;
                p_unit_class := gv_unit_offering_option_rec.unit_class;
                CLOSE c_unit_offering_option_uniq;
        ELSE
                -- Do nothing
                NULL;
        END IF;
EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_006.crsp_get_uoo_key');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values := p_unit_cd||','||to_char(p_version_number)||','||p_cal_type
                                        ||','||to_char(p_ci_sequence_number)||','||p_location_cd
                                        ||','||p_unit_class||','||to_char(p_uoo_id);
                Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                Fnd_Message.Set_Token('VALUE',lv_param_values);
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END;
END crsp_get_uoo_key;

FUNCTION crsp_get_us_admin(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2 AS
        lv_param_values                 VARCHAR2(1080);
BEGIN   -- crsp_get_us_admin
        -- This module fetches the value for the administrative_ind for a
        -- IGS_PS_UNIT set from the unit_set_table.
DECLARE

        v_administrative_ind            IGS_EN_UNIT_SET.administrative_ind%TYPE;
        CURSOR c_us IS
                SELECT  us.administrative_ind
                FROM    IGS_EN_UNIT_SET us
                WHERE   us.unit_set_cd          = p_unit_set_cd AND
                        us.version_number       = p_version_number;
BEGIN
        -- 1. Fetch the administrative indicator
        OPEN c_us;
        FETCH c_us INTO v_administrative_ind;
        IF (c_us%FOUND) THEN
                CLOSE c_us;
                RETURN v_administrative_ind;
        END IF;
        CLOSE c_us;
        RETURN NULL;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_us%ISOPEN) THEN
                        CLOSE c_us;
                END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_006.crsp_get_us_admin');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values := p_unit_set_cd||','||to_char(p_version_number);
                Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                Fnd_Message.Set_Token('VALUE',lv_param_values);
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END crsp_get_us_admin;

FUNCTION crsp_get_us_sys_sts(
  p_unit_set_status IN VARCHAR2 )
RETURN VARCHAR2 AS
lv_param_values                 VARCHAR2(1080);
BEGIN

        -- crsp_get_us_sys_sts
        -- This module fetches the value for the system IGS_PS_UNIT set status for a
        -- IGS_PS_UNIT set from the IGS_EN_UNIT_SET_STAT table.
DECLARE

        v_uss_s_unit_set_status         IGS_EN_UNIT_SET.unit_set_status%TYPE;
        CURSOR c_uss IS
                SELECT  uss.s_unit_set_status
                FROM    IGS_EN_UNIT_SET_STAT            uss
                WHERE   uss.unit_set_status     = p_unit_set_status;
BEGIN
        -- Get the system IGS_PS_UNIT set status
        OPEN c_uss;
        FETCH c_uss INTO v_uss_s_unit_set_status;
        IF (c_uss%FOUND) THEN
                CLOSE c_uss;
                RETURN v_uss_s_unit_set_status;
        END IF;
        CLOSE c_uss;
        RETURN NULL;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_uss%ISOPEN) THEN
                        CLOSE c_uss;
                END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_006.crsp_get_us_sys_sts');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values := p_unit_set_status;
                Fnd_Message.Set_Token('VALUE',lv_param_values);
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END crsp_get_us_sys_sts;




PROCEDURE crsp_ins_ci_uop_uoo(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  p_source_cal  IN VARCHAR2 ,
  p_dest_cal  IN VARCHAR2 ,
  p_org_unit   IN VARCHAR2,
  p_org_id IN NUMBER )

AS
-------------------------------------------------------------------------------------------
--Change History:
--Who             When             What
--sarakshi        17-Oct-2005      Bug#4657596, added fnd logging and corrected  ERRBUF setting in the exception
--sarakshi        14-Oct-2005      BUg#4657596, modified the exception such that get_string is called appropriately.
--sommukhe        01-SEP-2005      Bug# 4538540 , removed  p_org_unit_cd and used Rollback in when others of the Exception Block.
--shtatiko        3-FEB-2003       Bug# 2550411, Added code to log information wherever needed to make
--                                 log file more informative.
-------------------------------------------------------------------------------------------

  p_source_cal_type                       igs_ca_inst.cal_type%type ;
  p_source_sequence_number                igs_ca_inst.sequence_number%type;
  p_dest_cal_type                         igs_ca_inst.cal_type%type;
  p_dest_sequence_number                  igs_ca_inst.sequence_number%type;
  gv_check                                VARCHAR2(1);
  gv_uoo_rec                              igs_ps_unit_ofr_opt%ROWTYPE;
  gv_cal_instance_rec                     igs_ca_inst%ROWTYPE;
  gv_start_dt                             igs_ca_inst.start_dt%TYPE;
  gv_end_dt                               igs_ca_inst.end_dt%TYPE;
  gv_uv_rec                               igs_ps_unit_ver%ROWTYPE;
  gv_message                              VARCHAR2(255);
  gv_rec_inserted_cnt                     NUMBER(4);
  v_uop_identifier                        VARCHAR2(255);
  v_message                               VARCHAR2(255);
  v_uoo_uai_error_flag                    BOOLEAN ;
  v_none_uoo_uai_recs_inserted            BOOLEAN ;
  v_some_uoo_uai_recs_inserted            BOOLEAN ;
  v_all_uoo_uai_recs_inserted             BOOLEAN ;
  v_total_none_uoo_uai_inserted           BOOLEAN ;
  v_total_some_uoo_uai_inserted           BOOLEAN ;
  v_total_all_uoo_uai_inserted            BOOLEAN ;
  v_none_uop_recs_inserted                BOOLEAN ;
  v_some_uop_recs_inserted                BOOLEAN ;
  v_all_uop_recs_inserted                 BOOLEAN ;
  v_uap_insert_error                      BOOLEAN ;
  lv_out_date                             DATE;

  CURSOR gc_cal_type_exists IS
  SELECT  'x'
  FROM    igs_ca_type
  WHERE   cal_type = p_source_cal_type;

  CURSOR gc_cal_instance_exists(cp_cal_type             igs_ca_inst.cal_type%TYPE,
                                cp_sequence_number      igs_ca_inst.sequence_number%TYPE) IS
  SELECT  *
  FROM    igs_ca_inst
  WHERE   cal_type        = cp_cal_type
  AND     sequence_number = cp_sequence_number;

  CURSOR gc_unit_offering_pattern IS
  SELECT  uop.unit_cd,
          uop.version_number,
          uop.cal_type,
          uop.ci_sequence_number,
          uop.ci_start_dt,
          uop.ci_end_dt,
          uop.waitlist_allowed,
          uop.max_students_per_waitlist,
	  uop.delete_flag
  FROM    igs_ps_unit_ofr_pat     uop,
          igs_ps_unit_ver         uv
  WHERE   uop.cal_type            = p_source_cal_type
  AND     uop.ci_sequence_number  = p_source_sequence_number
  AND     uv.unit_cd              = uop.unit_cd
  AND     uv.version_number       = uop.version_number
  AND     uv.expiry_dt            IS NULL
  AND     uv.owner_org_unit_cd    = NVL(p_org_unit,uv.owner_org_unit_cd)
  AND     uop.delete_flag = 'N';
  gv_uop_rec                              gc_unit_offering_pattern%ROWTYPE;

  CURSOR gc_check_dest_uo_exists(cp_unit_cd              igs_ps_unit_ofr.unit_cd%TYPE,
                                 cp_version_number       igs_ps_unit_ofr.version_number%TYPE,
                                 cp_dest_cal_type        igs_ps_unit_ofr.cal_type%TYPE) IS
  SELECT 'x' FROM igs_ps_unit_ofr
  WHERE   unit_cd                 = cp_unit_cd
  AND     version_number          = cp_version_number
  AND     cal_type                = cp_dest_cal_type;
  gv_uo_rec                       gc_check_dest_uo_exists%ROWTYPE;

  CURSOR gc_check_uop_exists (cp_unit_cd              igs_ps_unit_ofr_pat.unit_cd%TYPE,
                              cp_version_number       igs_ps_unit_ofr_pat.version_number%TYPE) IS
  SELECT  'x'
  FROM    igs_ps_unit_ofr_pat
  WHERE   unit_cd                 = cp_unit_cd
  AND     version_number          = cp_version_number
  AND     cal_type                = p_dest_cal_type
  AND     ci_sequence_number      = p_dest_sequence_number
  AND     delete_flag = 'N';

  x_rowid         VARCHAR2(25);
  INVALID         EXCEPTION;
  VALID           EXCEPTION;

  l_start_dt      igs_ca_inst.start_dt%TYPE;
  l_end_dt        igs_ca_inst.end_dt%TYPE;

BEGIN

  igs_ge_gen_003.set_org_id(p_org_id);

  retcode:=0;

  -- Assigning initial values to local variables which were being initialised using DEFAULT
  -- clause.Done as part of bug #2563596 to remove GSCC warning.

  gv_rec_inserted_cnt             := 0;
  v_uoo_uai_error_flag            := FALSE;
  v_none_uoo_uai_recs_inserted    := FALSE;
  v_some_uoo_uai_recs_inserted    := FALSE;
  v_all_uoo_uai_recs_inserted     := FALSE;
  v_total_none_uoo_uai_inserted   := FALSE;
  v_total_some_uoo_uai_inserted   := FALSE;
  v_total_all_uoo_uai_inserted    := FALSE;
  v_none_uop_recs_inserted        := FALSE;
  v_some_uop_recs_inserted        := FALSE;
  v_all_uop_recs_inserted         := FALSE;
  v_uap_insert_error              := FALSE;


  -- Extract source calendar
  p_source_cal_type        := RTRIM(SUBSTR(p_source_cal, 102, 10));
  p_source_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_source_cal, 113, 8)));

  -- Extract destination calendar
  p_dest_cal_type          := RTRIM(SUBSTR(p_dest_cal, 102, 10));
  p_dest_sequence_number   := TO_NUMBER(RTRIM(SUBSTR(p_dest_cal, 113, 8)));


  -- Log all the parameters passed. This has been added as part of Bug# 2550411 by shtatiko
  l_start_dt := TO_DATE ( RTRIM(SUBSTR(p_source_cal, 12, 10)), 'DD/MM/YYYY' ) ;
  l_end_dt := TO_DATE ( RTRIM(SUBSTR(p_source_cal, 23, 10)), 'DD/MM/YYYY' );

  fnd_file.put_line ( fnd_file.LOG,  ' ' );
  log_parameters ( p_c_param_name  => igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'SOURCE_CAL' ),
                   p_c_param_value => TO_CHAR ( l_start_dt, 'DD-MON-YYYY' ) || ' - ' ||
                                      TO_CHAR ( l_end_dt, 'DD-MON-YYYY' ) || ' - ' ||
                                      p_source_cal_type );

  l_start_dt := TO_DATE ( RTRIM(SUBSTR(p_dest_cal, 12, 10)), 'DD/MM/YYYY' ) ;
  l_end_dt := TO_DATE ( RTRIM(SUBSTR(p_dest_cal, 23, 10)), 'DD/MM/YYYY' );

  log_parameters ( p_c_param_name  => igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'DEST_CAL' ),
                   p_c_param_value => TO_CHAR ( l_start_dt, 'DD-MON-YYYY' ) || ' - ' ||
                                      TO_CHAR ( l_end_dt, 'DD-MON-YYYY' ) || ' - ' ||
                                      p_dest_cal_type );

  log_parameters ( p_c_param_name  => igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'ORG_UNIT_CD' ),
                   p_c_param_value =>  NVL(p_org_unit,'%') );

  fnd_file.put_line ( fnd_file.LOG,  ' ' );
  fnd_file.put_line ( fnd_file.LOG,  ' ' );

  v_message          := NULL;
  v_uap_insert_error := FALSE;

  /* DO NOT REMOVE THIS COMMENTED CODE TO TRACK THE BUG WHICH HAS REMOVED THIS VALIDATION
   Enhancement Bug : 1298281
   Now, Allowing roll-over between 2 difft calender types.
   -- Check calendar type for source and destination is the same
   -- If not, records can't be rolled over
   IF (p_source_cal_type <> p_dest_cal_type) THEN
           v_message := 'IGS_PS_ONLY_ROLLOVER_UO';
           RAISE invalid;
   END IF;
  */


  -- validating that the calendar type is open and of type 'TEACHING'
  -- As part of the bug# 1956374 changed to the below call from igs_ps_val_uop.crsp_val_uo_cal_type
  IF (igs_as_val_uai.crsp_val_uo_cal_type (p_source_cal_type,v_message) = FALSE) THEN
      RAISE invalid;
  END IF;

  -- validating that the source calendar instance exists
  OPEN gc_cal_instance_exists(p_source_cal_type,
                              p_source_sequence_number);
  FETCH gc_cal_instance_exists INTO gv_cal_instance_rec;
  IF (gc_cal_instance_exists%NOTFOUND) THEN
    CLOSE gc_cal_instance_exists;
    v_message  := 'IGS_PS_SRC_CALINST_NOT_EXIST';
    RAISE invalid;
  END IF;
  CLOSE gc_cal_instance_exists;

  -- validating that the destination calendar instance exists
  OPEN gc_cal_instance_exists(p_dest_cal_type,
                              p_dest_sequence_number);
  FETCH gc_cal_instance_exists INTO gv_cal_instance_rec;
  IF (gc_cal_instance_exists%NOTFOUND) THEN
    CLOSE gc_cal_instance_exists;
    v_message:= 'IGS_PS_DEST_CAL_INST_NOT_EXIS';
    RAISE invalid;
  END IF;
  -- get start and end dates
  gv_start_dt := gv_cal_instance_rec.start_dt;
  gv_end_dt := gv_cal_instance_rec.end_dt;
  CLOSE gc_cal_instance_exists;

  -- validating that the destination calendar instance is active
  IF (igs_as_val_uai.crsp_val_crs_ci (p_dest_cal_type,
                                      p_dest_sequence_number,
                                      v_message) = FALSE) THEN
    RAISE invalid;
  END IF;
  --End of Parameter Validation


  --Enhancement bug no 1800179, pmarada. Insert a record in log entry table.
  --This will be used in failure report IGSPS11

  igs_ge_gen_003.genp_ins_log ('USEC-ROLL' ,
                               ' ',
                               lv_out_date );

  -- selecting IGS_PS_UNIT_OFR_PAT records from IGS_PS_UNIT_OFR_PAT and IGS_PS_UNIT_VER
  OPEN gc_unit_offering_pattern;
  LOOP
    FETCH gc_unit_offering_pattern INTO gv_uop_rec;
    EXIT WHEN gc_unit_offering_pattern%NOTFOUND;

    -- This logging Unit information has been added as part of Bug# 2550411 by shtatiko
    fnd_file.put_line ( fnd_file.LOG, ' ');
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CD' )
                                      || '           : ' || gv_uop_rec.unit_cd );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_VER_NUM' )
                                      || ' : ' || TO_CHAR (gv_uop_rec.version_number) );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'CAL_TYPE' )
                                      || '       : ' || p_dest_cal_type );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_FI_LOCKBOX', 'START_DT' )
                                      || '          : ' || fnd_date.date_to_displaydate (gv_start_dt) );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_FI_LOCKBOX', 'END_DT' )
                                      || '            : ' || fnd_date.date_to_displaydate (gv_end_dt) );
    fnd_file.put_line ( fnd_file.LOG, ' ');

    -- Check that IGS_PS_UNIT version in not inactive, otherwise
    -- it can't be updated
    IF (igs_ps_val_unit.crsp_val_iud_uv_dtl( gv_uop_rec.unit_cd,
                                             gv_uop_rec.version_number,
                                             gv_message) = TRUE) THEN

      -- Check if the Destination Calender Type for this Unit_cd and Version number exists
      -- in IGS_PS_UNIT_OFR
      OPEN gc_check_dest_uo_exists(gv_uop_rec.unit_cd,
                                   gv_uop_rec.version_number,
                                   p_dest_cal_type);
      FETCH gc_check_dest_uo_exists INTO gv_uo_rec;
      IF (gc_check_dest_uo_exists%NOTFOUND) THEN
        -- This message has been added as part of Bug# 2550411 by shtatiko to log more specific message in case
        -- Destination Calendar is not defined for the current Unit.
        fnd_message.set_name ( 'IGS', 'IGS_PS_NO_DEST_CAL_UNIT' );
        fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get );
      ELSE
        OPEN gc_check_uop_exists (gv_uop_rec.unit_cd,
                                  gv_uop_rec.version_number);
        FETCH gc_check_uop_exists INTO gv_check;
        IF (gc_check_uop_exists%NOTFOUND) THEN

          igs_ps_unit_ofr_pat_pkg.Insert_Row(
            x_rowid                     => x_rowid,
            x_unit_cd                   => gv_uop_rec.unit_cd,
            x_version_number            => gv_uop_rec.version_number,
            x_ci_sequence_number        => p_dest_sequence_number,
            x_cal_type                  => p_dest_cal_type,
            x_ci_start_dt               => gv_start_dt,
            x_ci_end_dt                 => gv_end_dt,
            x_waitlist_allowed          => gv_uop_rec.waitlist_allowed,
            x_max_students_per_waitlist => gv_uop_rec.max_students_per_waitlist,
            x_mode                      => 'R',
            x_org_id                    => p_org_id,
	    x_delete_flag               => gv_uop_rec.delete_flag,
	    x_abort_flag                => 'N');

          gv_rec_inserted_cnt := gv_rec_inserted_cnt + 1;
          -- This message has been added as part of Bug# 2550411 by shtatiko
          fnd_message.set_name ( 'IGS', 'IGS_PS_ROLL_UOP_SUCCESS' );
          fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get );
        ELSE
          -- This message has been added as part of Bug# 2550411 by shtatiko
          fnd_message.set_name ( 'IGS', 'IGS_PS_ROLL_UOP_EXISTS' );
          fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get );
        END IF;
        CLOSE gc_check_uop_exists;

        --Enhancement bug no 1800179
        -- insert IGS_PS_UNIT_OFR_OPT and IGS_AS_UNITASS_ITEM records for
        -- the IGS_PS_UNIT_OFR_PAT record
        IF (igs_ps_gen_008.crsp_ins_uop_uoo( gv_uop_rec.unit_cd,
                                             gv_uop_rec.version_number,
                                             p_dest_cal_type,
                                             p_source_sequence_number,
                                             p_dest_sequence_number,
                                             p_source_cal_type,
                                             gv_message,
                                             lv_out_date) = TRUE) THEN
          -- This logging of message returned by the function has been added to log the
          -- status of importing Unit Offering Pattern and other details. This has been done
          -- as per Bug fix 2550411 by shtatiko
          fnd_message.set_name ( 'IGS', gv_message );
          fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get );

          IF (gv_message = 'IGS_PS_NO_UOO_AND_UAI_ROLLED'  OR
              gv_message = 'IGS_PS_UOO_NO_UOO_TOBE_ROLLED' OR
              gv_message = 'IGS_PS_UOO_NO_UAI_TOBE_ROLLED' OR
              gv_message ='IGS_PS_NO_UOO_UAI_ROLLED') THEN
            v_none_uoo_uai_recs_inserted := TRUE;
          ELSIF (gv_message = 'IGS_PS_PARROLL_UOO_UAI' ) THEN
            v_some_uoo_uai_recs_inserted := TRUE;
          ELSIF (gv_message = 'IGS_PS_PARTIALROLL_UOO_USI' ) THEN
            v_some_uoo_uai_recs_inserted := TRUE;
            v_uap_insert_error := TRUE;
          ELSIF (gv_message ='IGS_PS_SUCCESSROLL_UOO_UAI') THEN
            v_all_uoo_uai_recs_inserted := TRUE;
          ELSIF (gv_message = 'IGS_PS_SUCCESS_ROLL_UOO_UAI') THEN
            v_all_uoo_uai_recs_inserted := TRUE;
            v_uap_insert_error := TRUE;
          END IF;
        ELSE
          -- crsp_ins_uop_uoo returns FALSE
          -- Then insert record into run log using rjr details and
          -- error message details

          -- This logging of message returned by the function has been added to log the
          -- status of importing Unit Offering Pattern and other details. This has been done
          -- as per Bug fix 2550411 by shtatiko
          fnd_message.set_name ( 'IGS', gv_message );
          fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get );

          v_uoo_uai_error_flag := TRUE;
          IF ( gv_message='IGS_PS_INV_NO_UOO_ROLLED' OR
               gv_message = 'IGS_PS_INV_UOO_ROLLED'  OR
               gv_message = 'IGS_PS_INV_NO_UAI_TOBE_ROLLED' OR
               gv_message = 'IGS_PS_INV_NO_UAI_OBS_DATA'  OR
               gv_message ='IGS_PS_NO_UOO_UA_ROL_INVALID') THEN
            v_none_uoo_uai_recs_inserted := TRUE;
          ELSIF (gv_message = 'IGS_PS_PRINV_NO_UOO_ROLLED'  OR
                 gv_message ='IGS_PS_PRINV_NO_UOO_OBS_DATA'  OR
                 gv_message = 'IGS_PS_INV_UAI_PAR_ROLL'  OR
                 gv_message = 'IGS_PS_PRINV_NO_UOO_INVALID' OR
                 gv_message = 'IGS_PS_INV_ALL_UAI_ROLLED'  OR
                 gv_message='IGS_PS_INV_PARROLL_UOO_OBSDAT' OR
                 gv_message = 'IGS_PS_PRINV_PARROL_UOO_OBS'  OR
                 gv_message = 'IGS_PS_PRINV_NO_UAI_ROLLED' OR
                 gv_message = 'IGS_PS_PRINV_NO_UAI_ROL_OBS' OR
                 gv_message ='IGS_PS_PRINV_NO_UAI_INVALID'  OR
                 gv_message = 'IGS_PS_PRINV_PARROLL_UAI'  OR
                 gv_message= 'IGS_PS_PRINV_UOO_UAI'  OR
                 gv_message = 'IGS_PS_PRINV_ALL_UAI_ROLLED' OR
                 gv_message = 'IGS_PS_INV_ALL_UOO_ROLLED' OR
                 gv_message = 'IGS_PS_PRINV_ALL_UOO_ROLLED') THEN
            v_some_uoo_uai_recs_inserted := TRUE;
          ELSIF (gv_message = 'IGS_PS_PARTILROLL_USI'  OR
                 gv_message = 'IGS_PS_PARROLL_UAI_INVLD_DATA' OR
                 gv_message='IGS_PS_INVALID_DATA' OR
                 gv_message = 'IGS_PS_PARROLL_USI_INVALID'  OR
                 gv_message = 'IGS_PS_NOTROLLED_INVALID_DATA' OR
                 gv_message = 'IGS_PS_PARTIALROLL_UAI'  OR
                 gv_message = 'IGS_PS_PARTIALROLL_UOO_INVALI' OR
                 gv_message = 'IGS_PS_PARROLL_UOO_AND_UAI'  OR
                 gv_message = 'IGS_PS_PARTIALROLL_UOO_INVDAT' OR
                 gv_message = 'IGS_PS_PARTIALROLL_UAI_UAIINV') THEN
              v_some_uoo_uai_recs_inserted := TRUE;
              v_uap_insert_error := TRUE;
          END IF;
        END IF;
      END IF;   -- cursor gc_check_dest_uo_exists
      CLOSE gc_check_dest_uo_exists;
    END IF;
  END LOOP;

  IF ((v_none_uoo_uai_recs_inserted = TRUE AND
       v_some_uoo_uai_recs_inserted = TRUE AND
       v_all_uoo_uai_recs_inserted = TRUE)    OR
      (v_none_uoo_uai_recs_inserted = TRUE AND
       v_some_uoo_uai_recs_inserted = TRUE AND
       v_all_uoo_uai_recs_inserted = FALSE)   OR
      (v_none_uoo_uai_recs_inserted = TRUE  AND
       v_some_uoo_uai_recs_inserted = FALSE AND
       v_all_uoo_uai_recs_inserted = TRUE)    OR
      (v_none_uoo_uai_recs_inserted = FALSE AND
       v_some_uoo_uai_recs_inserted = TRUE  AND
       v_all_uoo_uai_recs_inserted = TRUE)    OR
      (v_none_uoo_uai_recs_inserted = FALSE AND
       v_some_uoo_uai_recs_inserted = TRUE  AND
       v_all_uoo_uai_recs_inserted = FALSE))  THEN
    v_total_some_uoo_uai_inserted := TRUE;
  ELSIF ((v_none_uoo_uai_recs_inserted = TRUE  AND
          v_some_uoo_uai_recs_inserted = FALSE AND
          v_all_uoo_uai_recs_inserted = FALSE)   OR
         (v_none_uoo_uai_recs_inserted = FALSE AND
          v_some_uoo_uai_recs_inserted = FALSE AND
          v_all_uoo_uai_recs_inserted = FALSE)) THEN
    v_total_none_uoo_uai_inserted := TRUE;
  ELSIF ( v_none_uoo_uai_recs_inserted = FALSE AND
          v_some_uoo_uai_recs_inserted = FALSE AND
          v_all_uoo_uai_recs_inserted = TRUE) THEN
    v_total_all_uoo_uai_inserted := TRUE;
  END IF;

  -- set uop indicate flag
  -- if no IGS_PS_UNIT_OFR_PAT records were inserted
  IF (gv_rec_inserted_cnt = 0) THEN
    v_none_uop_recs_inserted := TRUE;
  -- if all IGS_PS_UNIT_OFR_PAT records were inserted
  ELSIF (gv_rec_inserted_cnt = gc_unit_offering_pattern%ROWCOUNT) THEN
    v_all_uop_recs_inserted := TRUE;
  -- if some IGS_PS_UNIT_OFR_PAT records were inserted
  ELSE
    v_some_uop_recs_inserted := TRUE;
  END IF;
  CLOSE gc_unit_offering_pattern;

  IF v_none_uop_recs_inserted = TRUE THEN
    IF v_total_none_uoo_uai_inserted = TRUE THEN
      IF v_uoo_uai_error_flag = FALSE THEN
        v_message := 'IGS_PS_NO_UOP_UO_UAI';
        RAISE valid;
      ELSE
        v_message := 'IGS_PS_NO_UOP_HAVE_BEEN_ROLL';
        COMMIT;
        RAISE invalid;
      END IF;
    ELSIF v_total_some_uoo_uai_inserted = TRUE THEN
      IF v_uoo_uai_error_flag = FALSE THEN
        IF v_uap_insert_error = FALSE THEN
          v_message := 'IGS_PS_PAR_ROLL_UOP_UO_UAI';
        ELSE
          v_message :='IGS_PS_PARROLL_UOP_UO_UAI';
        END IF;
        RAISE valid;
      ELSE
        IF v_uap_insert_error = FALSE THEN
          v_message :='IGS_PS_NO_UOP_HAVE_BEEN_ROLL';
        ELSE
          v_message:='IGS_PS_NO_UOP_HAVEBEEN_ROLLED';
        END IF;
        COMMIT;
        RAISE invalid;
      END IF;
    ELSIF v_total_all_uoo_uai_inserted = TRUE THEN
      IF v_uap_insert_error = FALSE THEN
        v_message := 'IGS_PS_PAR_ROLL_UOP_UO_UAI';
      ELSE
        v_message := 'IGS_PS_PARROLL_UOP_UO_UAI';
      END IF;
      RAISE valid;
    END IF;
  ELSIF v_some_uop_recs_inserted = TRUE THEN
    IF v_total_none_uoo_uai_inserted = TRUE THEN
      IF v_uoo_uai_error_flag = FALSE THEN
        v_message := 'IGS_PS_PAR_ROLL_UOP_UO_UAI';
        RAISE valid;
      ELSE
        v_message := 'IGS_PS_PARTIAL_ROLL_UOP';
        COMMIT;
        RAISE invalid;
      END IF;
    ELSIF v_total_some_uoo_uai_inserted = TRUE THEN
      IF v_uoo_uai_error_flag = FALSE THEN
        IF v_uap_insert_error = FALSE THEN
          v_message := 'IGS_PS_PAR_ROLL_UOP_UO_UAI';
        ELSE
          v_message :='IGS_PS_PARROLL_UOP_UO_UAI';
        END IF;
        RAISE valid;
      ELSE
        IF v_uap_insert_error = FALSE THEN
          v_message :='IGS_PS_PAR_ROLL_UOP_UO_UAI';
        ELSE
          v_message := 'IGS_PS_PARROLL_UOP';
        END IF;
        COMMIT;
        RAISE invalid;
      END IF;
    ELSIF v_total_all_uoo_uai_inserted = TRUE THEN
      IF v_uap_insert_error = FALSE THEN
        v_message := 'IGS_PS_PAR_ROLL_UOP_UO_UAI';
      ELSE
        v_message :='IGS_PS_PARROLL_UOP_UO_UAI';
      END IF;
      RAISE VALID;
    END IF;
  ELSIF v_all_uop_recs_inserted = TRUE THEN
    IF v_total_none_uoo_uai_inserted = TRUE THEN
      IF v_uoo_uai_error_flag = FALSE THEN
        v_message := 'IGS_PS_SUCCESSROLL_UOP_UO_UAI';
        RAISE valid;
      ELSE
        v_message := 'IGS_PS_SUCCESSFUL_ROLL_UOP';
        COMMIT;
        RAISE invalid;
      END IF;
    ELSIF v_total_some_uoo_uai_inserted = TRUE THEN
      IF v_uoo_uai_error_flag = FALSE THEN
        IF v_uap_insert_error = FALSE THEN
          v_message := 'IGS_PS_SUCCESSROLL_UOP_UO_UAI';
        ELSE
          v_message :='IGS_PS_SUCCESS_ROLL_UOP_UO_UA';
        END IF;
        RAISE VALID;
      ELSE
        IF v_uap_insert_error = FALSE THEN
          v_message := 'IGS_PS_SUCCESSFUL_ROLL_UOP';
        ELSE
          v_message :='IGS_PS_SUCCESS_ROLL_UOP';
        END IF;
        COMMIT;
        RAISE invalid;
      END IF;
    ELSIF v_total_all_uoo_uai_inserted = TRUE THEN
      IF v_uap_insert_error = FALSE THEN
        v_message := 'IGS_PS_SUCCESSROLL_UOP_UO_UAI';
      ELSE
        v_message :='IGS_PS_SUCCESS_ROLL_UOP_UO_UA';
      END IF;
      RAISE VALID;
    END IF;
  END IF;

EXCEPTION
  WHEN VALID THEN
    COMMIT;
    RETCODE:=0;
    -- Code has been changed to log the error message instead of assigning it to ERRBUF (Bug# 2550411)
    fnd_file.put_line ( fnd_file.LOG, ' ');
    fnd_file.put_line ( fnd_file.LOG, fnd_message.get_string('IGS',v_message) );
  WHEN INVALID THEN
    RETCODE:=2;
    -- Code has been changed to log the error message instead of assigning it to ERRBUF (Bug# 2550411)
    fnd_file.put_line ( fnd_file.LOG, ' ');
    fnd_file.put_line ( fnd_file.LOG, fnd_message.get_string('IGS',v_message) );
  WHEN OTHERS THEN
    RETCODE:=2;
    ROLLBACK;
    -- SQLERRM has been added as per Bug Fux 2550411
    ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
    --Fnd log implementation
    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_006.crsp_ins_ci_uop_uoo.in_exception_section_OTHERS.err_msg',
      SUBSTRB(SQLERRM,1,4000));
    END IF;

END crsp_ins_ci_uop_uoo;

--sommukhe 13-Feb-2006 bug#3306014 modified cursor c_ou for performance reason
PROCEDURE crsp_ins_us_hist(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_new_unit_set_status IN VARCHAR2 ,
  p_old_unit_set_status IN VARCHAR2 ,
  p_new_unit_set_cat IN VARCHAR2 ,
  p_old_unit_set_cat IN VARCHAR2 ,
  p_new_start_dt IN DATE ,
  p_old_start_dt IN DATE ,
  p_new_review_dt IN DATE ,
  p_old_review_dt IN DATE ,
  p_new_expiry_dt IN DATE ,
  p_old_expiry_dt IN DATE ,
  p_new_end_dt IN DATE ,
  p_old_end_dt IN DATE ,
  p_new_title IN VARCHAR2 ,
  p_old_title IN VARCHAR2 ,
  p_new_short_title IN VARCHAR2 ,
  p_old_short_title IN VARCHAR2 ,
  p_new_abbreviation IN VARCHAR2 ,
  p_old_abbreviation IN VARCHAR2 ,
  p_new_responsible_org_unit_cd IN VARCHAR2 ,
  p_old_responsible_org_unit_cd IN VARCHAR2 ,
  p_new_responsible_ou_start_dt IN DATE ,
  p_old_responsible_ou_start_dt IN DATE ,
  p_new_administrative_ind IN VARCHAR2 ,
  p_old_administrative_ind IN VARCHAR2 ,
  p_new_authorisation_rqrd_ind IN VARCHAR2 ,
  p_old_authorisation_rqrd_ind IN VARCHAR2 ,
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE )
AS
lv_param_values                 VARCHAR2(1080);
BEGIN   -- crsp_ins_us_hist
        -- Insert a IGS_EN_UNIT_SET_HIST record. This routine also gets descriptions from
        -- relevant reference data records for historical purposes.
DECLARE

        v_ush_rec                       IGS_EN_UNIT_SET_HIST%ROWTYPE;
        v_create_history                BOOLEAN := FALSE;
        v_hist_start_dt                 IGS_EN_UNIT_SET.LAST_UPDATE_DATE%TYPE;
        v_hist_end_dt                   IGS_EN_UNIT_SET.LAST_UPDATE_DATE%TYPE;
        v_hist_who                      IGS_EN_UNIT_SET.LAST_UPDATED_BY%TYPE;
        CURSOR  c_ou IS
                SELECT  ou.party_name  description
                FROM    IGS_OR_INST_ORG_BASE_V  ou
                WHERE   ou.party_number   = p_old_responsible_org_unit_cd AND
                        ou.start_dt     = p_old_responsible_ou_start_dt;

                x_rowid         VARCHAR2(25);
                l_org_id        NUMBER(15);
BEGIN
        -- If any of the old IGS_EN_UNIT_SET values (p_old_<column_name>) are different from
        -- the associated new IGS_EN_UNIT_SET values (p_new_<column_name>) (with the
        -- exception of the LAST_UPDATED_BY and LAST_UPDATE_DATE columns) then create a
        -- IGS_EN_UNIT_SET_HIST history record with the old IGS_EN_UNIT_SET values
        -- (p_old_<column_name>).  Only write the changed values to the history
        -- record.  Do not set the LAST_UPDATED_BY and LAST_UPDATE_DATE columns when creating the
        -- history record.
        IF p_new_unit_set_status <> p_old_unit_set_status THEN
                v_ush_rec.unit_set_status := p_old_unit_set_status;
                v_create_history := TRUE;
        END IF;
        IF p_new_unit_set_cat <> p_old_unit_set_cat THEN
                v_ush_rec.unit_set_cat := p_old_unit_set_cat;
                v_create_history := TRUE;
        END IF;
        IF p_new_start_dt <> p_old_start_dt OR
                        (p_new_start_dt         IS NULL AND
                        p_old_start_dt          IS NOT NULL) OR
                        (p_new_start_dt         IS NOT NULL AND
                        p_old_start_dt          IS NULL) THEN
                v_ush_rec.start_dt := p_old_start_dt;
                v_create_history := TRUE;
        END IF;
        IF (p_new_review_dt <> p_old_review_dt) OR
                        (p_new_review_dt        IS NULL AND
                        p_old_review_dt         IS NOT NULL) OR
                        (p_new_review_dt        IS NOT NULL AND
                        p_old_review_dt         IS NULL) THEN
                v_ush_rec.review_dt := p_old_review_dt;
                v_create_history := TRUE;
        END IF;
        IF (p_new_expiry_dt <> p_old_expiry_dt) OR
                        (p_new_expiry_dt        IS NULL AND
                        p_old_expiry_dt         IS NOT NULL) OR
                        (p_new_expiry_dt        IS NOT NULL AND
                        p_old_expiry_dt         IS NULL) THEN
                v_ush_rec.expiry_dt := p_old_expiry_dt;
                v_create_history := TRUE;
        END IF;
        IF (p_new_end_dt <> p_old_end_dt) OR
                        (p_new_end_dt           IS NULL AND
                        p_old_end_dt            IS NOT NULL) OR
                        (p_new_end_dt           IS NOT NULL AND
                        p_old_end_dt            IS NULL) THEN
                v_ush_rec.end_dt := p_old_end_dt;
                v_create_history := TRUE;
        END IF;
        IF p_new_title <> p_old_title THEN
                v_ush_rec.title:= p_old_title;
                v_create_history := TRUE;
        END IF;
        IF p_new_short_title <> p_old_short_title THEN
                v_ush_rec.short_title := p_old_short_title;
                v_create_history := TRUE;
        END IF;
        IF p_new_abbreviation <> p_old_abbreviation THEN
                v_ush_rec.abbreviation := p_old_abbreviation;
                v_create_history := TRUE;
        END IF;
        IF (p_new_responsible_org_unit_cd <> p_old_responsible_org_unit_cd) OR
                        (p_new_responsible_org_unit_cd  IS NULL AND
                        p_old_responsible_org_unit_cd   IS NOT NULL) OR
                        (p_new_responsible_org_unit_cd  IS NOT NULL AND
                        p_old_responsible_org_unit_cd   IS NULL) THEN
                v_ush_rec.responsible_org_unit_cd := p_old_responsible_org_unit_cd;
                v_create_history := TRUE;
        END IF;
        IF (p_new_responsible_ou_start_dt <> p_old_responsible_ou_start_dt) OR
                        (p_new_responsible_ou_start_dt  IS NULL AND
                        p_old_responsible_ou_start_dt   IS NOT NULL) OR
                        (p_new_responsible_ou_start_dt  IS NOT NULL AND
                        p_old_responsible_ou_start_dt   IS NULL)THEN
                v_ush_rec.responsible_ou_start_dt := p_old_responsible_ou_start_dt;
                v_create_history := TRUE;
        END IF;
        IF p_new_administrative_ind <> p_old_administrative_ind THEN
                v_ush_rec.administrative_ind := p_old_administrative_ind;
                v_create_history := TRUE;
        END IF;
        IF p_new_authorisation_rqrd_ind <> p_old_authorisation_rqrd_ind THEN
                v_ush_rec.authorisation_rqrd_ind := p_old_authorisation_rqrd_ind;
                v_create_history := TRUE;
        END IF;
        -- create a history record if any column has changed
        IF v_create_history = TRUE THEN
                v_ush_rec.unit_set_cd           := p_unit_set_cd;
                v_ush_rec.version_number        := p_version_number;
                v_ush_rec.hist_start_dt         := p_old_update_on;
                v_ush_rec.hist_end_dt           := p_new_update_on;
                v_ush_rec.hist_who              := p_old_update_who;
                IF p_new_responsible_org_unit_cd <> p_old_responsible_org_unit_cd OR
                                (p_new_responsible_ou_start_dt <> p_old_responsible_ou_start_dt OR
                                (p_new_responsible_ou_start_dt  IS NULL AND
                                p_old_responsible_ou_start_dt   IS NOT NULL) OR
                                (p_new_responsible_ou_start_dt  IS NOT NULL AND
                                p_old_responsible_ou_start_dt   IS NULL))       THEN
                        OPEN c_ou;
                        FETCH c_ou INTO v_ush_rec.ou_description;
                        CLOSE c_ou;
                ELSE
                        v_ush_rec.ou_description := NULL;
                END IF;

                l_org_id := igs_ge_gen_003.get_org_id;

                IGS_EN_UNIT_SET_HIST_PKG.Insert_Row(
                                                X_ROWID                  =>             x_rowid,
                                                X_UNIT_SET_CD            =>             v_ush_rec.unit_set_cd,
                                                X_VERSION_NUMBER         =>             v_ush_rec.version_number,
                                                X_HIST_START_DT          =>             v_ush_rec.hist_start_dt,
                                                X_HIST_END_DT            =>             v_ush_rec.hist_end_dt,
                                                X_HIST_WHO               =>             v_ush_rec.hist_who,
                                                X_UNIT_SET_STATUS        =>             v_ush_rec.unit_set_status,
                                                X_UNIT_SET_CAT           =>             v_ush_rec.unit_set_cat,
                                                X_START_DT               =>             v_ush_rec.start_dt,
                                                X_REVIEW_DT              =>             v_ush_rec.review_dt,
                                                X_EXPIRY_DT              =>             v_ush_rec.expiry_dt,
                                                X_END_DT                 =>             v_ush_rec.end_dt,
                                                X_TITLE                  =>             v_ush_rec.title,
                                                X_SHORT_TITLE            =>             v_ush_rec.short_title,
                                                X_ABBREVIATION           =>             v_ush_rec.abbreviation,
                                                X_RESPONSIBLE_ORG_UNIT_CD=>             v_ush_rec.responsible_org_unit_cd,
                                                X_RESPONSIBLE_OU_START_DT=>             v_ush_rec.responsible_ou_start_dt,
                                                X_OU_DESCRIPTION         =>             v_ush_rec.ou_description,
                                                X_ADMINISTRATIVE_IND     =>             v_ush_rec.administrative_ind,
                                                X_AUTHORISATION_RQRD_IND =>             v_ush_rec.authorisation_rqrd_ind,
                                                X_MODE                   =>             'R',
                                                X_ORG_ID                 =>             l_org_id);
        END IF;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_ou%ISOPEN) THEN
                        CLOSE c_ou;
                END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_006.crsp_ins_us_hist');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values := p_unit_set_cd||','||to_char(p_version_number)||','||p_new_unit_set_status||','
                ||p_old_unit_set_status||','||p_new_unit_set_cat||','||p_old_unit_set_cat||','
                ||fnd_date.date_to_displaydate(p_new_start_dt)||','
                ||fnd_date.date_to_displaydate(p_old_start_dt)||','||fnd_date.date_to_displaydate(p_new_review_dt)||','
                ||fnd_date.date_to_displaydate(p_old_review_dt)||','||
                fnd_date.date_to_displaydate(p_new_expiry_dt)||','||fnd_date.date_to_displaydate(p_old_expiry_dt)||','
                ||fnd_date.date_to_displaydate(p_new_end_dt)||','||fnd_date.date_to_displaydate(p_old_end_dt)
                ||','||p_new_title||','||p_old_title||','||p_new_short_title||','||p_old_short_title||','||p_new_abbreviation
                ||','||p_old_abbreviation||','||p_new_responsible_org_unit_cd||','||p_old_responsible_org_unit_cd||','||
                fnd_date.date_to_displaydate(p_new_responsible_ou_start_dt)||','||
                fnd_date.date_to_displaydate(p_old_responsible_ou_start_dt)||','||p_new_administrative_ind
                ||','||p_old_administrative_ind||','||p_new_authorisation_rqrd_ind||','||p_old_authorisation_rqrd_ind||','||
                p_new_update_who||','||p_old_update_who||','||
                fnd_date.date_to_displaydate(p_new_update_on)||','||fnd_date.date_to_displaydate(p_old_update_on);
                Fnd_Message.Set_Token('VALUE',lv_param_values);
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END crsp_ins_us_hist;

-- sommukhe 13-Feb-2006 Bug#3306014, modified cursors c_org_unit for performance reason.
-- rgangara 03-May-2001 added 2 cols i.e. ss_enrol_ind and ivr_enrol_ind as per DLD Unit Section Enrollment DLD
-- rbezawad 24-May-2001 added 47 cols as per DLD PSP001-US
-- apelleti 14-JUN-2001 renamed column registration_exclusion_flag to ss_display_ind as per DLD PSP001-US

PROCEDURE crsp_ins_uv_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_review_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_end_dt IN DATE ,
  p_unit_status IN VARCHAR2 ,
  p_title IN VARCHAR2 ,
  p_short_title IN VARCHAR2 ,
  p_title_override_ind IN VARCHAR2 ,
  p_abbreviation IN VARCHAR2 ,
  p_unit_level IN VARCHAR2 ,
  p_credit_point_descriptor IN VARCHAR2 ,
  p_achievable_credit_points IN NUMBER ,
  p_enrolled_credit_points IN NUMBER ,
  p_supp_exam_permitted_ind IN VARCHAR2 ,
  p_points_increment IN NUMBER ,
  p_points_min IN NUMBER ,
  p_points_max IN NUMBER ,
  p_points_override_ind IN VARCHAR2 ,
  p_coord_person_id IN NUMBER ,
  p_owner_org_unit_cd IN VARCHAR2 ,
  p_owner_ou_start_dt IN DATE ,
  p_award_course_only_ind IN VARCHAR2 ,
  p_research_unit_ind IN VARCHAR2 ,
  p_industrial_ind IN VARCHAR2 ,
  p_practical_ind IN VARCHAR2 ,
  p_repeatable_ind IN VARCHAR2 ,
  p_assessable_ind IN VARCHAR2 ,
  p_unit_int_course_level_cd IN VARCHAR2,
  p_ss_enrol_ind IN VARCHAR2 ,
  p_ivr_enrol_ind IN VARCHAR2 ,
  -- Added by rbezawad as per PSP001-US DLD on 24-May-2001
  p_advance_maximum IN NUMBER,
  p_approval_date IN DATE,
  p_cal_type_enrol_load_cal IN VARCHAR2,
  p_cal_type_offer_load_cal IN VARCHAR2,
  p_clock_hours IN NUMBER,
  p_contact_hrs_lab IN NUMBER,
  p_contact_hrs_lecture IN NUMBER,
  p_contact_hrs_other IN NUMBER,
  p_continuing_education_units IN NUMBER,
  p_curriculum_id IN VARCHAR2 ,
  p_enrollment_expected IN NUMBER,
  p_enrollment_maximum IN NUMBER,
  p_enrollment_minimum IN NUMBER,
  p_exclude_from_max_cp_limit IN VARCHAR2 ,
  p_federal_financial_aid IN VARCHAR2 ,
  p_institutional_financial_aid IN VARCHAR2 ,
  p_lab_credit_points IN NUMBER,
  p_lecture_credit_points IN NUMBER,
  p_max_repeat_credit_points IN NUMBER,
  p_max_repeats_for_credit IN NUMBER,
  p_max_repeats_for_funding IN NUMBER,
  p_non_schd_required_hrs IN NUMBER,
  p_other_credit_points IN NUMBER,
  p_override_enrollment_max IN NUMBER,
  p_record_exclusion_flag IN VARCHAR2 ,
  p_ss_display_ind IN VARCHAR2 ,
  p_rpt_fmly_id IN NUMBER,
  p_same_teach_period_repeats IN NUMBER ,
  p_same_teach_period_repeats_cp IN NUMBER,
  p_same_teaching_period IN VARCHAR2,
  p_sequence_num_enrol_load_cal IN NUMBER,
  p_sequence_num_offer_load_cal IN NUMBER,
  p_special_permission_ind IN VARCHAR2 ,
  p_state_financial_aid IN VARCHAR2 ,
  p_subtitle_id IN NUMBER,
  p_subtitle_modifiable_flag IN VARCHAR2 ,
  p_unit_type_id IN NUMBER,
  p_work_load_cp_lab IN NUMBER,
  p_work_load_cp_lecture IN NUMBER,
  p_work_load_other IN NUMBER,
  p_claimable_hours IN NUMBER ,
  p_auditable_ind IN VARCHAR2,
  p_audit_permission_ind IN VARCHAR2,
  p_max_auditors_allowed IN NUMBER,
  p_billing_credit_points IN NUMBER,
  p_ovrd_wkld_val_flag IN VARCHAR2,
  p_workload_val_code IN VARCHAR2,
  p_billing_hrs IN NUMBER )
AS
        lv_param_values         VARCHAR2(1080);
        v_ul_description        IGS_PS_UNIT_LEVEL.description%TYPE;
        v_ou_description        IGS_OR_UNIT.description%TYPE;
        v_uicl_description      IGS_PS_UNIT_INT_LVL.description%TYPE;
        v_level_code            IGS_PS_UNIT_TYPE_LVL.LEVEL_CODE%TYPE;
        v_repeat_code           IGS_PS_RPT_FMLY_ALL.REPEAT_CODE%TYPE;
        v_subtitle              IGS_PS_UNIT_SUBTITLE.SUBTITLE%TYPE;

        CURSOR  c_unit_level(
                        cp_unit_level IGS_PS_UNIT_LEVEL.unit_level%TYPE) IS
                SELECT  description
                FROM    IGS_PS_UNIT_LEVEL
                WHERE   unit_level = cp_unit_level;
        CURSOR  c_org_unit(
                        cp_org_unit_cd IGS_OR_UNIT.org_unit_cd%TYPE,
                        cp_start_dt IGS_OR_UNIT.start_dt%TYPE) IS
                SELECT  party_name description
                FROM    IGS_OR_INST_ORG_BASE_V
                WHERE   party_number  = cp_org_unit_cd AND
                        start_dt = cp_start_dt;
        CURSOR  c_unit_int_course_level(
                        cp_unit_int_course_level_cd
                                IGS_PS_UNIT_INT_LVL.unit_int_course_level_cd%TYPE) IS
                SELECT  description
                FROM    IGS_PS_UNIT_INT_LVL
                WHERE   unit_int_course_level_cd = cp_unit_int_course_level_cd;

        CURSOR c_unit_type_level ( cp_unit_type_id IGS_PS_UNIT_TYPE_LVL.UNIT_TYPE_ID%TYPE ) IS
          SELECT level_code
          FROM   IGS_PS_UNIT_TYPE_LVL
          WHERE  UNIT_TYPE_ID = cp_unit_type_id;

        CURSOR c_repeat_family ( cp_rpt_fmly_id IGS_PS_RPT_FMLY_ALL.RPT_FMLY_ID%TYPE ) IS
          SELECT repeat_code
          FROM   IGS_PS_RPT_FMLY_ALL
          WHERE  RPT_FMLY_ID= cp_rpt_fmly_id;

        CURSOR c_unit_subtitle ( cp_subtitle_id IGS_PS_UNIT_SUBTITLE.SUBTITLE_ID%TYPE ) IS
          SELECT subtitle
          FROM   igs_ps_unit_subtitle
          WHERE  subtitle_id = cp_subtitle_id;

                x_rowid                 VARCHAR2(25);
                l_org_id                NUMBER(15);
BEGIN
        IF(p_unit_level IS NOT NULL) THEN
                OPEN c_unit_level(
                        p_unit_level);
                FETCH c_unit_level INTO v_ul_description;
                CLOSE c_unit_level;
        ELSE
                v_ul_description := NULL;
        END IF;
        IF(p_owner_org_unit_cd IS NOT NULL) THEN
                OPEN c_org_unit(
                        p_owner_org_unit_cd,
                        p_owner_ou_start_dt);
                FETCH c_org_unit INTO v_ou_description;
                CLOSE c_org_unit;
        ELSE
                v_ou_description := NULL;
        END IF;
        IF(p_unit_int_course_level_cd IS NOT NULL) THEN
                OPEN c_unit_int_course_level(
                        p_unit_int_course_level_cd);
                FETCH c_unit_int_course_level INTO v_uicl_description;
                CLOSE c_unit_int_course_level;
        ELSE
                v_uicl_description := NULL;
        END IF;
        IF(p_unit_type_id IS NOT NULL) THEN
                OPEN c_unit_type_level(p_unit_type_id);
                FETCH c_unit_type_level INTO v_level_code;
                CLOSE c_unit_type_level;
        ELSE
                v_level_code := NULL;
        END IF;

        IF(p_rpt_fmly_id IS NOT NULL) THEN
                OPEN c_repeat_family(
                        p_rpt_fmly_id);
                FETCH c_repeat_family INTO v_repeat_code;
                CLOSE c_repeat_family;
        ELSE
                v_repeat_code := NULL;
        END IF;

        IF(p_subtitle_id IS NOT NULL) THEN
                OPEN c_unit_subtitle(
                        p_subtitle_id);
                FETCH c_unit_subtitle INTO v_subtitle;
                CLOSE c_unit_subtitle;
        ELSE
                v_subtitle := NULL;
        END IF;


        l_org_id := igs_ge_gen_003.get_org_id;

        IGS_PS_UNIT_VER_HIST_PKG.Insert_Row(
                        X_ROWID                         =>      x_rowid,
                        X_UNIT_CD                     =>        p_unit_cd,
                        X_VERSION_NUMBER              =>        p_version_number,
                        X_HIST_START_DT               =>        p_last_update_on,
                        X_HIST_END_DT                 =>        p_update_on,
                        X_HIST_WHO                    =>        p_last_update_who,
                        X_START_DT                    =>        p_start_dt,
                        X_REVIEW_DT                   =>        p_review_dt,
                        X_EXPIRY_DT                   =>        p_expiry_dt,
                        X_END_DT                      =>        p_end_dt,
                        X_UNIT_STATUS                 =>        p_unit_status,
                        X_TITLE                       =>        p_title,
                        X_SHORT_TITLE                 =>        p_short_title,
                        X_TITLE_OVERRIDE_IND          =>        p_title_override_ind,
                        X_ABBREVIATION                =>        p_abbreviation,
                        X_UNIT_LEVEL                  =>        p_unit_level,
                        X_UL_DESCRIPTION              =>        v_ul_description,
                        X_CREDIT_POINT_DESCRIPTOR     =>        p_credit_point_descriptor,
                        X_ENROLLED_CREDIT_POINTS      =>        p_enrolled_credit_points,
                        X_POINTS_OVERRIDE_IND         =>        p_points_override_ind,
                        X_SUPP_EXAM_PERMITTED_IND     =>        p_supp_exam_permitted_ind,
                        X_COORD_PERSON_ID             =>        p_coord_person_id,
                        X_OWNER_ORG_UNIT_CD           =>        p_owner_org_unit_cd,
                        X_OWNER_OU_START_DT           =>        p_owner_ou_start_dt,
                        X_OU_DESCRIPTION              =>        v_ou_description,
                        X_AWARD_COURSE_ONLY_IND       =>        p_award_course_only_ind,
                        X_RESEARCH_UNIT_IND           =>        p_research_unit_ind,
                        X_INDUSTRIAL_IND              =>        p_industrial_ind,
                        X_PRACTICAL_IND               =>        p_practical_ind,
                        X_REPEATABLE_IND              =>        p_repeatable_ind,
                        X_ASSESSABLE_IND              =>        p_assessable_ind,
                        X_ACHIEVABLE_CREDIT_POINTS      =>      p_achievable_credit_points,
                        X_POINTS_INCREMENT            =>        p_points_increment,
                        X_POINTS_MIN                  =>        p_points_min,
                        X_POINTS_MAX                  =>        p_points_max,
                        X_UNIT_INT_COURSE_LEVEL_CD      =>      p_unit_int_course_level_cd,
                        X_UICL_DESCRIPTION            =>        v_uicl_description,
                        X_MODE                        =>        'R',
                        X_ORG_ID                      =>         l_org_id,
                        X_SS_ENROL_IND                =>        p_ss_enrol_ind,
                        X_IVR_ENROL_IND               =>        p_ivr_enrol_ind,
                        -- Added By rbezawad as per PSP001-US DLD on 24-May-2001
                        X_ADVANCE_MAXIMUM                 =>     p_advance_maximum,
                        X_APPROVAL_DATE                   =>     p_approval_date,
                        X_CAL_TYPE_ENROL_LOAD_CAL         =>     p_cal_type_enrol_load_cal,
                        X_CAL_TYPE_OFFER_LOAD_CAL         =>     p_cal_type_offer_load_cal,
                        X_CLOCK_HOURS                     =>     p_clock_hours,
                        X_CONTACT_HRS_LAB                 =>     p_contact_hrs_lab,
                        X_CONTACT_HRS_LECTURE             =>     p_contact_hrs_lecture,
                        X_CONTACT_HRS_OTHER               =>     p_contact_hrs_other,
                        X_CONTINUING_EDUCATION_UNITS      =>     p_continuing_education_units,
                        X_CURRICULUM_ID                   =>     p_curriculum_id,
                        X_ENROLLMENT_EXPECTED             =>     p_enrollment_expected,
                        X_ENROLLMENT_MAXIMUM              =>     p_enrollment_maximum,
                        X_ENROLLMENT_MINIMUM              =>     p_enrollment_minimum,
                        X_EXCLUDE_FROM_MAX_CP_LIMIT       =>     p_exclude_from_max_cp_limit,
                        X_FEDERAL_FINANCIAL_AID           =>     p_federal_financial_aid,
                        X_INSTITUTIONAL_FINANCIAL_AID     =>     p_institutional_financial_aid,
                        X_LAB_CREDIT_POINTS               =>     p_lab_credit_points,
                        X_LECTURE_CREDIT_POINTS           =>     p_lecture_credit_points,
                        X_LEVEL_CODE                      =>     v_level_code,
                        X_MAX_REPEAT_CREDIT_POINTS        =>     p_max_repeat_credit_points,
                        X_MAX_REPEATS_FOR_CREDIT          =>     p_max_repeats_for_credit,
                        X_MAX_REPEATS_FOR_FUNDING         =>     p_max_repeats_for_funding,
                        X_NON_SCHD_REQUIRED_HRS           =>     p_non_schd_required_hrs,
                        X_OTHER_CREDIT_POINTS             =>     p_other_credit_points,
                        X_OVERRIDE_ENROLLMENT_MAX         =>     p_override_enrollment_max,
                        X_RECORD_EXCLUSION_FLAG           =>     p_record_exclusion_flag,
                        X_SS_DISPLAY_IND                  =>     p_ss_display_ind,
                        X_REPEAT_CODE                     =>     v_repeat_code,
                        X_RPT_FMLY_ID                     =>     p_rpt_fmly_id,
                        X_SAME_TEACH_PERIOD_REPEATS       =>     p_same_teach_period_repeats,
                        X_SAME_TEACH_PERIOD_REPEATS_CP    =>     p_same_teach_period_repeats_cp,
                        X_SAME_TEACHING_PERIOD            =>     p_same_teaching_period,
                        X_SEQUENCE_NUM_ENROL_LOAD_CAL     =>     p_sequence_num_enrol_load_cal,
                        X_SEQUENCE_NUM_OFFER_LOAD_CAL     =>     p_sequence_num_offer_load_cal,
                        X_SPECIAL_PERMISSION_IND          =>     p_special_permission_ind,
                        X_STATE_FINANCIAL_AID             =>     p_state_financial_aid,
                        X_SUBTITLE                        =>     v_subtitle,
                        X_SUBTITLE_ID                     =>     p_subtitle_id,
                        X_SUBTITLE_MODIFIABLE_FLAG        =>     p_subtitle_modifiable_flag,
                        X_UNIT_TYPE_ID                    =>     p_unit_type_id,
                        X_WORK_LOAD_CP_LAB                =>     p_work_load_cp_lab,
                        X_WORK_LOAD_CP_LECTURE            =>     p_work_load_cp_lecture,
                        X_WORK_LOAD_OTHER                 =>     p_work_load_other,
                        x_claimable_hours                 =>     p_claimable_hours ,
                        x_auditable_ind                   =>     p_auditable_ind,
                        x_audit_permission_ind            =>     p_audit_permission_ind,
                        x_max_auditors_allowed            =>     p_max_auditors_allowed,
			x_billing_credit_points           =>     p_billing_credit_points,
			x_ovrd_wkld_val_flag              =>     p_ovrd_wkld_val_flag,
			x_workload_val_code               =>     p_workload_val_code,
			x_billing_hrs                     =>     p_billing_hrs);

EXCEPTION
        WHEN OTHERS THEN

                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_006.crsp_ins_uv_hist');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values := p_unit_cd||','||to_char(p_version_number)||','||fnd_date.date_to_displaydate(p_last_update_on)||','||fnd_date.date_to_displaydate(p_update_on)||','
                                        ||p_last_update_who||','
                                        ||fnd_date.date_to_displaydate(p_start_dt)||','||fnd_date.date_to_displaydate(p_review_dt)||','||fnd_date.date_to_displaydate(p_expiry_dt)||','
                                        ||fnd_date.date_to_displaydate(p_end_dt)||','||p_unit_status||','||p_title||','||p_short_title||
                                        ','||p_title_override_ind||','||p_abbreviation||','||p_unit_level||','||
                                        p_credit_point_descriptor||','||to_char(p_achievable_credit_points)||','||
                                        to_char(p_enrolled_credit_points)||','||p_supp_exam_permitted_ind||','||
                                        to_char(p_points_increment)||','||to_char(p_points_min)||','||to_char(p_points_max)
                                        ||','||p_points_override_ind ||','||to_char(p_coord_person_id )||','|| p_owner_org_unit_cd
                                        ||','||fnd_date.date_to_displaydate(p_owner_ou_start_dt)||','||p_award_course_only_ind ||','||p_research_unit_ind
                                        ||','|| p_industrial_ind
                                        ||','||p_practical_ind||','||p_repeatable_ind||','||p_assessable_ind||','||p_unit_int_course_level_cd||','||TO_CHAR(p_billing_credit_points)||','||p_ovrd_wkld_val_flag||','||p_workload_val_code
					||',' || to_char(p_billing_hrs);

                Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                Fnd_Message.Set_Token('VALUE',lv_param_values);
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END crsp_ins_uv_hist;


END IGS_PS_GEN_006;

/
