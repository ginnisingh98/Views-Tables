--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_API" AS
/* $Header: IGSEN23B.pls 120.1 2005/08/29 08:01:12 appldev ship $ */

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --npalanis    06-JAN-2002     BUG NO. 2170429 .The  cursor c_sfs removed
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function GENP_VAL_STRT_END_DT removed
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function GENP_SET_ROWID removed
  --vrathi      18-may-2003     Bug No. 2928745 : end date check cursor modified to include person_id_type
  -- ssaleem    17-Sept-2004    Bug No. 3787210 : Added Closed Ind in table IGS_PE_PERSON_ID_TYP
  -------------------------------------------------------------------------------------------


  --
  -- Validate that an entry exist in s_disable_table_trigger.
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  PROCEDURE genp_prc_clear_rowid
  AS
  BEGIN
  	-- initialise
  	gt_rowid_table := gt_empty_table;
  	gv_table_index := 1;
  END genp_prc_clear_rowid;
  --
  -- Routine to process api rowids in a PL/SQL TABLE for the current commit
  FUNCTION enrp_prc_api_rowids(
  p_inserting IN BOOLEAN ,
  p_updating IN BOOLEAN ,
  p_deleting IN BOOLEAN ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	v_index			BINARY_INTEGER;

  	r_alternate_person_id 	IGS_PE_ALT_PERS_ID%ROWTYPE;
  	cst_pay_adv_no		CONSTANT	VARCHAR2(10) := 'PAY_ADV_NO';
  	v_dummy			VARCHAR2(1);
  	CURSOR	c_pit (cp_person_id_type	IGS_PE_PERSON_ID_TYP.person_id_type%TYPE) IS
  		SELECT 	'x'
  		FROM	IGS_PE_PERSON_ID_TYP		pit
  		WHERE	pit.person_id_type 	= cp_person_id_type AND
  			pit.s_person_id_type 	= cst_pay_adv_no AND
			pit.closed_ind = 'N' ;
  BEGIN
  	-- Process saved rows.
  	FOR  v_index IN 1..gv_table_index - 1
  	LOOP
  		BEGIN
  			SELECT	*
  			INTO	r_alternate_person_id
  			FROM	IGS_PE_ALT_PERS_ID
  			WHERE	rowid = gt_rowid_table(v_index);
  			EXCEPTION
  				WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_API.enrp_prc_api_rowids');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  		END;
  		-- Validate the alternate person id when a 'PAY_ADV_NO' is unique.
  		OPEN c_pit (r_alternate_person_id.person_id_type);
  		FETCH c_pit INTO v_dummy;
  		IF (c_pit%FOUND) THEN
  			CLOSE c_pit;
  			IF IGS_EN_VAL_API.enrp_val_api_pan (
  					r_alternate_person_id.pe_person_id,
  					r_alternate_person_id.api_person_id,
  					p_message_name) = FALSE THEN
  				RETURN FALSE;
  			END IF;
  		ELSE
  			CLOSE c_pit;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END enrp_prc_api_rowids;
  --
  -- Validate the payment advice number is unique.
  FUNCTION enrp_val_api_pan(
  p_person_id  IGS_PE_ALT_PERS_ID.pe_person_id%TYPE ,
  p_pay_advice_number  IGS_PE_ALT_PERS_ID.api_person_id%TYPE ,
  p_message_name OUT NOCOPY varchar2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_api_pan
  	-- Validate that IGS_PE_ALT_PERS_ID where s_person_id_type = 'PAY_ADV_NO' is
  	-- unique to the person and that it does not clash with any payment_advice
  	-- number in IGS_FI_STDNT_FEE_SPN
  DECLARE
  	cst_pay_adv_no		CONSTANT	VARCHAR2(10) := 'PAY_ADV_NO';
  	v_dummy					VARCHAR2(1);
  	CURSOR	c_api_pit IS
  		SELECT 	'x'
  		FROM	IGS_PE_ALT_PERS_ID	api,
  			IGS_PE_PERSON_ID_TYP		pit
  		WHERE	api.api_person_id 	= p_pay_advice_number 	AND
  			api.pe_person_id 	 <>  p_person_id		AND
  			api.person_id_type 	= pit.person_id_type 	AND
  			pit.s_person_id_type 	= cst_pay_adv_no;

  BEGIN
  	-- validate IGS_PE_ALT_PERS_ID where
  	-- s_person_id_type = 'PAY_ADV_NO' is unique to this IGS_PE_PERSON
  	OPEN c_api_pit;
  	FETCH c_api_pit INTO v_dummy;
  	IF c_api_pit%FOUND THEN
  		CLOSE c_api_pit;
  		p_message_name := 'IGS_FI_PYMT_ADVICE_NUM_ALLOCA';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_api_pit;

  	-- pay advise number is valid
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_api_pit%ISOPEN) THEN
  			CLOSE c_api_pit;
  		END IF;

  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_API.enrp_val_api_pan');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_api_pan;

  FUNCTION val_overlap_api(
  p_person_id   IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID%TYPE)
  RETURN BOOLEAN AS
 ------------------------------------------------------------------------------------------
  --Created by  : pkpatel
  --Date created: 8-JUN-2002
  -- bug no: Bug No: 2402077
  --Purpose:To check Overlapping period for Person Id Types, if more than exists it returns FALSE
  --         else TRUE.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --kpadiyar	27-JAN-2003	Changed >= B.START_DT to > B.sTART_DT for bug 2726415
  --ssawhney                      end date overlapp modified to include <=
  -- vrathi     18-may-2003     Bug 2928745 : end date check cursor modified to include person_id_type
  --vrathi      20-may-2003     Changed NVL(A.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) <=
  --                            NVL(B.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) comparison to <= from <
  --askapoor    31-jan-05       Added NVL(A.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) <>  A.START_DT
  --                            in val_overlap_api
  ----------------------------------------------------------------------------------------------

    CURSOR c_validate_overlap_dates ( cp_person_id   IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID%TYPE)
    IS
    SELECT COUNT(1)
    FROM   IGS_PE_ALT_PERS_ID A,
           IGS_PE_ALT_PERS_ID B
    WHERE  A.pe_person_id   =  cp_person_id
    AND    A.pe_person_id   =  B.pe_person_id
    AND    A.person_id_type =  B.person_id_type
    AND    A.ROWID  <> B.ROWID
    AND    A.START_DT < NVL(B.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD'))
    AND    NVL(A.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) <>  A.START_DT
    AND    NVL(A.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) >  B.START_DT
    AND    (
    NVL(A.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) <= NVL(B.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD'))
    OR
    A.END_DT <= B.END_DT
    );



   ln_count NUMBER(10);

   CURSOR c_end_chk (cp_person_id   IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID%TYPE)
   IS
   SELECT  count('x')
   FROM    igs_pe_alt_pers_id
   WHERE   pe_person_id = cp_person_id
   AND     end_dt IS NULL
   GROUP BY pe_person_id,PERSON_ID_TYPE
   HAVING count('x') >1;

  BEGIN
      OPEN  c_end_chk ( p_person_id );
      FETCH c_end_chk INTO ln_count;
      CLOSE c_end_chk;

      IF ln_count > 1 THEN
       ln_count := 0;
       RETURN FALSE;
      END IF;


      OPEN c_validate_overlap_dates ( p_person_id );
      FETCH c_validate_overlap_dates INTO ln_count;
      CLOSE c_validate_overlap_dates;

	-- If ln_count is greater than then it indicates that records with overlapping dates exist in the database
    -- In such a situation display an error  message
    IF (ln_count > 0) THEN
	  RETURN FALSE;
    END IF;

	RETURN TRUE;

  END val_overlap_api;

  FUNCTION val_ssn_overlap_api(
  p_person_id   IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID%TYPE)
  RETURN BOOLEAN AS
 ------------------------------------------------------------------------------------------
  --Created by  : pkpatel
  --Date created: 8-JUN-2002
  -- bug no: Bug No: 2402077
  --Purpose:To check Overlapping period for Person Id Types associated with System Person ID type SSN, if more than exists it returns FALSE
  --         else FALSE.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --kpadiyar	27-JAN-2003	Changed >= B.START_DT to > B.START_DT for bug 2726415
  -- ssawhney                   end date voerlap modified to have <=
  -- vrathi     18-may-2003     Bug 2928745 : end date check cursor modified to include person_id_type
  --askapoor    31-jan-05       Added NVL(A.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) <>  A.START_DT
  --                            in val_ssn_overlap_api
  ----------------------------------------------------------------------------------------------
    CURSOR val_overlap_dt_ssn_cur ( cp_person_id   IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID%TYPE)
    IS
    SELECT COUNT(1)
    FROM   IGS_PE_ALT_PERS_ID A,
           IGS_PE_ALT_PERS_ID B
    WHERE  A.pe_person_id   =  cp_person_id
    AND    A.pe_person_id   =  B.pe_person_id
    AND    A.person_id_type IN (SELECT person_id_type FROM IGS_PE_PERSON_ID_TYP WHERE s_person_id_type = 'SSN')
    AND    B.person_id_type IN (SELECT person_id_type FROM IGS_PE_PERSON_ID_TYP WHERE s_person_id_type = 'SSN')
    AND    A.ROWID  <> B.ROWID
    AND    A.START_DT < NVL(B.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD'))
    AND    NVL(A.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) <>  A.START_DT
    AND    NVL(A.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) >  B.START_DT
    AND    (
    NVL(A.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD')) <= NVL(B.END_DT,TO_DATE('4712/12/31','YYYY/MM/DD'))
    OR
    A.END_DT <= B.END_DT
    );

    l_count NUMBER := 0;

   CURSOR c_end_chk (cp_person_id   IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID%TYPE)
   IS
   SELECT  count('x')
   FROM    igs_pe_alt_pers_id
   WHERE   pe_person_id = cp_person_id
   AND    PERSON_ID_TYPE IN ( select person_id_type from igs_pe_person_id_typ
                             where S_PERSON_ID_TYPE='SSN' )
   AND     end_dt IS NULL
   GROUP BY pe_person_id,PERSON_ID_TYPE;

  BEGIN

      OPEN  c_end_chk ( p_person_id );
      FETCH c_end_chk INTO l_count;
      CLOSE c_end_chk;

      IF l_count > 1 THEN
       l_count := 0;
       RETURN FALSE;
      END IF;

  	  OPEN   val_overlap_dt_ssn_cur ( p_person_id);
	  FETCH  val_overlap_dt_ssn_cur INTO l_count;
	  CLOSE  val_overlap_dt_ssn_cur;

    -- If l_count is greater than 0 then it indicates that records with overlapping dates exist in the database
    -- In such a situation display an error  message
    IF (l_count > 0) THEN
	  RETURN FALSE;
    END IF;

	RETURN TRUE;

  END val_ssn_overlap_api;

  FUNCTION fm_equal(
   p_format_mask IN igs_pe_person_id_typ.format_mask%TYPE,
   p_frmt_msk_copy IN igs_pe_person_id_typ.format_mask%TYPE)
  RETURN BOOLEAN AS
  ------------------------------------------------------------------------------------------
  --Created by  : sarakshi
  --Date created: 21-SEP-2001
  -- bug no:2000408
  --Purpose:To check that the format mask field is 9 or X or any of the special char
  --         ('-','_','+','=',')','(','*','&','^','%','$','#','@','!','`','~','/','\',' '),if it is
  --         then this function returns true else false.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------
  l_str_len   NUMBER  := LENGTH(p_format_mask);
  l_trans_s   IGS_PE_PERSON_ID_TYP.FORMAT_MASK%TYPE := NULL;
  l_chr       VARCHAR2(1);
  BEGIN
    FOR i IN 1..l_str_len LOOP
      l_chr := SUBSTR(p_format_mask,i,1);
      IF l_chr IN ('0','1','2','3','4','5','6','7','8','9') THEN
        l_trans_s :=l_trans_s||'9';
      ELSIF l_chr IN ('-','_','+','=',')','(','*','&','^','%','$','#','@','!','`','~','/','\',' ') THEN
        l_trans_s :=l_trans_s||l_chr;
      ELSE
        l_trans_s:=l_trans_s||'X';
      END IF;
    END LOOP;

    IF p_frmt_msk_copy = l_trans_s THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END fm_equal;

  FUNCTION unformat_api(
  p_api_pers_id IN igs_pe_alt_pers_id.api_person_id%TYPE)
  RETURN VARCHAR2 AS
------------------------------------------------------------------------------------------
  --Created by  : pkpatel
  --Date created: 06-JUN-2002
  --
  --Purpose: Bug No: 2402077. To unformat the formatted Alternate Person ID field from the special char
  --         ('-','_','+','=',')','(','*','&','^','%','$','#','@','!','`','~','/','\',' '). It returns the Unformatted
  --         person ID Type.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------

  l_str_len   NUMBER  := LENGTH(p_api_pers_id);
  l_api_pers_id_gen   igs_pe_alt_pers_id.api_person_id%TYPE := NULL;
  l_chr       VARCHAR2(1);

  BEGIN
    FOR i IN 1..l_str_len LOOP
      l_chr := SUBSTR(p_api_pers_id,i,1);
      IF l_chr IN ('0','1','2','3','4','5','6','7','8','9') THEN
        l_api_pers_id_gen := l_api_pers_id_gen||l_chr;
      ELSIF l_chr IN ('-','_','+','=',')','(','*','&','^','%','$','#','@','!','`','~','/','\',' ') THEN
        NULL;
      ELSE
        l_api_pers_id_gen := l_api_pers_id_gen||l_chr;
      END IF;
    END LOOP;

    RETURN l_api_pers_id_gen;

  END unformat_api;

  FUNCTION fm_equal_wrap(
   p_format_mask IN igs_pe_person_id_typ.format_mask%TYPE,
   p_frmt_msk_copy IN igs_pe_person_id_typ.format_mask%TYPE)
  RETURN NUMBER AS
 ------------------------------------------------------------------------------------------
  --Created by  : pkpatel
  --Date created: 29-Aug-2005
  --Purpose: Wrapper method to be called from Self -Service
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------
    l_result boolean;
  BEGIN
    l_result := fm_equal(p_format_mask,p_frmt_msk_copy);
    if l_result then
       return 1;
    else
       return 0;
    end if;
  END fm_equal_wrap;

END igs_en_val_api;

/
