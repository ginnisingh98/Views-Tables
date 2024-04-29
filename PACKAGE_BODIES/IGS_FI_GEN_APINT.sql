--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_APINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_APINT" AS
/* $Header: IGSFI79B.pls 115.10 2003/07/03 04:10:15 pathipat noship $ */


  FUNCTION chk_liability_acc (p_n_ccid IN NUMBER) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 20 Feb 2003
  --
  --Purpose: Function to check validity of Liability Account CCID combination.
  --         To check if Account CCID passed is of type Liability.
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pathipat    27-Jun-2003     Bug: 2992967 - Table based value set for segments
  --                            Removed quotes and concatenation in the vrule string
  -- SYKRISHN  06/MAR/03    Changed FND_FLEX_KEYVAL callout from validate_ccid to validate_segs
  --                        as per bug 2832607
  ------------------------------------------------------------------

   l_v_rule_string VARCHAR2(2000) :=  'GL_ACCOUNT\nGL_ACCOUNT_TYPE\nI\nAPPL=IGS;NAME=IGS_FI_ACC_LIABL\nL';

  BEGIN
    --Invoke  FND_FLEX_KEYVAL.validate_segs for validating the CCID (Concat)  with appropriate vrule string.
    --Return FALSE from this function if FND API returns FALSE.

    IF fnd_flex_keyval.validate_segs(
                       operation        =>'CHECK_COMBINATION',
                       appl_short_name  =>'SQLGL',
                       key_flex_code    =>'GL#',
                       structure_number => igs_fi_gen_007.get_coa_id,
                       concat_segments  => igs_fi_gen_007.get_ccid_concat(p_n_ccid),
                       vrule  => l_v_rule_string)    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
  END chk_liability_acc;


  FUNCTION get_rfnd_destination  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 20 Feb 2003
  --
  --Purpose: Function to fetch the value of  RFND_DESTINATION from IGS_FI_CONTROL
  --
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------
  CURSOR c_rfnd_destination IS
  SELECT rfnd_destination
  FROM   igs_fi_control;

  l_v_rfnd_destination igs_fi_control_all.rfnd_destination%TYPE := NULL;

  BEGIN
   --Select the Refund Destination field from the IGS_FI_CONTROL table
   OPEN   c_rfnd_destination;
   FETCH  c_rfnd_destination INTO l_v_rfnd_destination;
   CLOSE  c_rfnd_destination;
   RETURN l_v_rfnd_destination;

  END get_rfnd_destination ;

  FUNCTION get_unit_section_desc( p_n_uoo_id               IN PLS_INTEGER,
                                  p_v_unit_cd              IN VARCHAR2,
                                  p_n_version_number       IN PLS_INTEGER,
                                  p_v_cal_type             IN VARCHAR2,
                                  p_n_ci_sequence_number   IN PLS_INTEGER,
                                  p_v_location_cd          IN VARCHAR2,
                                  p_v_unit_class           IN VARCHAR2
                                 ) RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : vvutukur, Oracle IDC
  --Date created: 09-May-2003
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------

    --Cursor to fetch the unit section details.
    CURSOR cur_uoo_details(cp_n_uoo_id   igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
    SELECT unit_cd, version_number, cal_type, ci_sequence_number, location_cd, unit_class
    FROM   igs_ps_unit_ofr_opt_all
    WHERE  uoo_id = cp_n_uoo_id;

    l_v_unit_cd            igs_ps_unit_ofr_opt_all.unit_cd%TYPE             := p_v_unit_cd;
    l_n_version_number     igs_ps_unit_ofr_opt_all.version_number%TYPE      := p_n_version_number;
    l_v_cal_type           igs_ps_unit_ofr_opt_all.cal_type%TYPE            := p_v_cal_type;
    l_n_ci_sequence_number igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE  := p_n_ci_sequence_number;
    l_v_location_cd        igs_ps_unit_ofr_opt_all.location_cd%TYPE         := p_v_location_cd;
    l_v_unit_class         igs_ps_unit_ofr_opt_all.unit_class%TYPE          := p_v_unit_class;

    --Cursor to get the Teaching Calendar for the Calendar Type and Calendar Instance Sequence Number.
    CURSOR cur_cal_type (cp_v_cal_type   igs_ca_inst_all.cal_type%TYPE,
                         cp_n_seq_number igs_ca_inst_all.sequence_number%TYPE
                         ) IS
    SELECT alternate_code
    FROM   igs_ca_inst
    WHERE  cal_type        = cp_v_cal_type
    AND    sequence_number = cp_n_seq_number;

    l_v_alt_code        igs_ca_inst.alternate_code%TYPE;
    l_v_uoo_id_desc     VARCHAR2(4000);

  BEGIN
    --Check if a value is passed to the p_n_uoo_id parameter. If no value is passed to this parameter then return NULL from this function.
    IF p_n_uoo_id IS NULL THEN
      RETURN NULL;
    ELSE
    --If p_n_uoo_id is not null, check if value to any of the Unit Sections attributes is not provided.
      IF (l_v_unit_cd IS NULL OR
          l_n_version_number IS NULL OR
          l_v_cal_type IS NULL OR
          l_n_ci_sequence_number IS NULL OR
          l_v_location_cd IS NULL OR
          l_v_unit_class IS NULL
          )THEN
        --If any one of the unit section attributes is null, then get these details from the Unit Section Offering Options based on the Unit
        --Section Identifier(p_n_uoo_id).
        OPEN cur_uoo_details(p_n_uoo_id);
        FETCH cur_uoo_details INTO l_v_unit_cd,l_n_version_number,l_v_cal_type,l_n_ci_sequence_number,l_v_location_cd,l_v_unit_class;

        IF cur_uoo_details%NOTFOUND THEN
          CLOSE cur_uoo_details;
          RETURN NULL;
        END IF;
        CLOSE cur_uoo_details;
      END IF;

      --Get the Teaching Calendar for the Calendar Type and Calendar Instance Sequence Number.
      OPEN cur_cal_type(l_v_cal_type,l_n_ci_sequence_number);
      FETCH cur_cal_type INTO l_v_alt_code;
      CLOSE cur_cal_type;

      --Return the unit section details in concatenated string separated by comma.
      l_v_uoo_id_desc := l_v_unit_cd||', '||l_n_version_number||', '||l_v_location_cd||', '||l_v_unit_class||', '||l_v_alt_code;
      RETURN l_v_uoo_id_desc;
    END IF;

  END get_unit_section_desc;

  PROCEDURE get_segment_num(p_n_segment_num  OUT NOCOPY NUMBER) AS
  ------------------------------------------------------------------
  --Created by  : Priya Athipatla, Oracle IDC
  --Date created: 26-Jun-2003
  --
  --Purpose: To obtain the segment_num for the Natural Account Segment
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------
  CURSOR cur_segment_num IS
    SELECT fs.segment_num
    FROM fnd_segment_attribute_values av,
         fnd_id_flex_segments fs
    WHERE av.application_id = 101
    AND av.id_flex_code = 'GL#'
    AND av.id_flex_num = igs_fi_gen_007.get_coa_id
    AND fs.application_id = av.application_id
    AND fs.id_flex_code = av.id_flex_code
    AND fs.id_flex_num = av.id_flex_num
    AND fs.application_column_name = av.application_column_name
    AND av.segment_attribute_type = 'GL_ACCOUNT'
    AND av.attribute_value = 'Y';

  BEGIN

    OPEN cur_segment_num;
    FETCH cur_segment_num INTO p_n_segment_num;
    CLOSE cur_segment_num;

  END get_segment_num;

  FUNCTION get_segment_desc(p_n_segment_num      IN NUMBER,
                            p_v_natural_acc_seg  IN VARCHAR2) RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : Priya Athipatla, Oracle IDC
  --Date created: 02-Jul-2003
  --
  --Purpose: Returns the description of the natural account segment
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------
  l_b_enabled     BOOLEAN := FALSE;

  BEGIN

     l_b_enabled := fnd_flex_keyval.validate_segs( operation        => 'CHECK_SEGMENTS',
                                                   appl_short_name  => 'SQLGL',
                                                   key_flex_code    => 'GL#',
                                                   structure_number => igs_fi_gen_007.get_coa_id,
                                                   displayable      => p_n_segment_num,
                                                   allow_nulls      => TRUE,
                                                   vrule            => 'GL_ACCOUNT\nGL_ACCOUNT_TYPE\nI\nAPPL=IGS;NAME=IGS_FI_ACC_REV\nR',
                                                   concat_segments  => p_v_natural_acc_seg
                                                 );

     RETURN (fnd_flex_keyval.segment_description(p_n_segment_num)) ;

  END get_segment_desc;


END igs_fi_gen_apint;

/
