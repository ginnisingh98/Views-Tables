--------------------------------------------------------
--  DDL for Package Body IGS_GE_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_GEN_004" AS
/* $Header: IGSGE04B.pls 115.14 2003/11/25 13:22:25 asbala ship $ */

------------------------------------------------------------------
--
-- Bug ID : 1938728
-- who        when            what
--smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_strt_end_dt removed
-- smadathi   25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS
--                            removed .
-- sjadhav    16-aug-2001     removed hardcoded reference to
--                            apps schema in cursor c_user_name
-- msrinivi   25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_bus_day
--                            removed .
-- asbala     23-JUL-2003     Changed IGS_lookup_view to igs_lookup_values in CURSOR c_lookup_meaning
--asbala      23-JUL-03       Bug No:2667343 populating x_meaning from lookup_type = Report_Type and lookup_code = A
--                            instead of hard coded string 'All'.
------------------------------------------------------------------

FUNCTION GENP_GET_WHO_NAME(p_last_updated_by   IN NUMBER)
RETURN VARCHAR2 IS
   CURSOR c_user_name is
                   SELECT user_name
                   FROM   fnd_user
                   WHERE  user_id=p_last_updated_by;
   x_user_name     VARCHAR2(100);
begin
   OPEN c_user_name;
   FETCH c_user_name INTO x_user_name;
           IF c_user_name%FOUND then
      RETURN x_user_name;
   ELSE
      RETURN NULL;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
     RETURN FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
          RAISE;
END GENP_GET_WHO_NAME;

FUNCTION GENP_GET_LOOKUP(
           p_lookup_type           IN VARCHAR2,
           p_lookup_code           IN VARCHAR2)
RETURN VARCHAR2 IS
--asbala 23-JUL-03 Changed igs_lookups_view to igs_lookup_values
   CURSOR c_lookup_meaning(cp_lookup_type  VARCHAR2,
                           cp_lookup_code  VARCHAR2) IS
                   SELECT meaning
                   FROM   IGS_LOOKUP_VALUES
                   WHERE lookup_type=cp_lookup_type        AND
                         lookup_code=cp_lookup_code;
   x_meaning       VARCHAR2(80);
BEGIN
--asbala 23-JUL-03 Bug No:2667343 populating x_meaning from lookup_type = Report_Type and lookup_code = A
-- instead of hard coded string 'All'.
   IF (p_lookup_code = '%' OR p_lookup_code IS NULL) THEN
     OPEN c_lookup_meaning('REPORT_TYPE','A');
     FETCH c_lookup_meaning INTO x_meaning;
     CLOSE c_lookup_meaning;
     RETURN x_meaning;
   END IF;
   OPEN c_lookup_meaning(p_lookup_type,p_lookup_code);
   FETCH c_lookup_meaning INTO x_meaning;
   IF c_lookup_meaning%FOUND THEN
      CLOSE c_lookup_meaning;
      RETURN x_meaning;
   END IF;
   CLOSE c_lookup_meaning;
   RETURN NULL;
EXCEPTION
   WHEN OTHERS THEN
     RETURN FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
          RAISE;
END GENP_GET_LOOKUP;

FUNCTION GENP_UPD_ST_LGC_DEL(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
	e_resource_busy_exception			EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54 );
	gv_other_details					VARCHAR2(255);
BEGIN
DECLARE
	v_st_record			IGS_PE_STD_TODO%ROWTYPE;
	CURSOR c_lock_st_records IS
		SELECT	*
		FROM	IGS_PE_STD_TODO
		WHERE	person_id = p_person_id						AND
				s_student_todo_type = p_s_student_todo_type	AND
				sequence_number = p_sequence_number
		FOR UPDATE
		NOWAIT;
	CURSOR SI_PE_TODO_CUR IS
		SELECT IGS_PE_STD_TODO.* , ROWID
		FROM IGS_PE_STD_TODO
		WHERE	person_id = p_person_id						AND
		s_student_todo_type = p_s_student_todo_type	AND
		sequence_number = p_sequence_number;


BEGIN
	-- Update the IGS_PE_STD_TODO  table with the NOWAIT option.
	OPEN c_lock_st_records;
	FETCH c_lock_st_records INTO v_st_record;
	CLOSE c_lock_st_records;
	FOR SI_RE_REC IN SI_PE_TODO_CUR LOOP
	IGS_PE_STD_TODO_PKG.UPDATE_ROW(
		x_rowid => SI_RE_REC.ROWID ,
		X_PERSON_ID  => SI_RE_REC.PERSON_ID,
		X_S_STUDENT_TODO_TYPE => SI_RE_REC.S_STUDENT_TODO_TYPE,
		X_SEQUENCE_NUMBER => SI_RE_REC.SEQUENCE_NUMBER,
		X_TODO_DT => SI_RE_REC.TODO_DT,
		X_LOGICAL_DELETE_DT => SYSDATE ,
		X_MODE=> 'R'
	);
	END LOOP;
	p_message_name := null ;
	RETURN TRUE;
END;
EXCEPTION
	WHEN e_resource_busy_exception THEN
		Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		RETURN FALSE;
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception ;
END genp_upd_st_lgc_del;


FUNCTION GENP_VAL_ADT_CRSP(
  p_addr_type  FND_LOOKUP_VALUES.lookup_code%type ,
  p_crsp_ind  IGS_PE_HZ_LOCATIONS.correspondence%TYPE )
RETURN VARCHAR2 AS
-- This modules is used to test if the passed address type
-- and correspondence indicator exists in the system. This is
-- only used for validation in the Inquiry System.
v_other_detail		VARCHAR2(255)	:= NULL;
v_found			VARCHAR2(1)	:= NULL;
CURSOR	c_adt(	cp_addr_type	IGS_CO_ADDR_TYPE.addr_type%TYPE,
		cp_crsp_ind	IGS_PE_PERSON_ADDR.correspondence_ind%TYPE)
iS
SELECT
	'x'
FROM	IGS_CO_ADDR_TYPE adt
WHERE	adt.addr_type 		=	cp_addr_type;

BEGIN
	IF c_adt%ISOPEN
	THEN
		CLOSE c_adt;
	END IF;
	OPEN c_adt( p_addr_type, p_crsp_ind);
	FETCH c_adt INTO v_found;
	IF c_adt%NOTFOUND
	THEN
		CLOSE c_adt;
		RETURN 'N';
	ELSE
		CLOSE c_adt;
		RETURN 'Y';
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF c_adt%ISOPEN
		THEN
			CLOSE c_adt;
		END IF;
			RETURN 'N';
END genp_val_adt_crsp;

FUNCTION JBSP_GET_DT_PICTURE(
  p_char_dt IN VARCHAR2 ,
  p_dt_picture OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
BEGIN
DECLARE
	v_return_dt	DATE	:= NULL;
	v_char_dt	VARCHAR2(40);
BEGIN
	-- This function accepts a date string, determines what format
	-- should be used to convert the string to a date and returns
	-- the date picture and true if a valid date picture found.
	v_char_dt := SUBSTR(REPLACE(p_char_dt, '''', ''), 1, 40);
	IF v_char_dt IS NULL THEN
		p_dt_picture := ' ';
		RETURN FALSE;
	END IF;
	v_return_dt := TO_DATE(v_char_dt, 'DD/MM/YY');
	p_dt_picture := 'DD/MM/YY';
	RETURN TRUE;
	EXCEPTION WHEN OTHERS THEN
	BEGIN
		v_return_dt := TO_DATE(v_char_dt, 'DD/MM/YYYY');
		p_dt_picture := 'DD/MM/YYYY';
		RETURN TRUE;
		EXCEPTION WHEN OTHERS THEN
		BEGIN
			v_return_dt := TO_DATE(v_char_dt, 'DD-MM-YY');
			p_dt_picture := 'DD-MM-YY';
			RETURN TRUE;
			EXCEPTION WHEN OTHERS THEN
			BEGIN
				v_return_dt := TO_DATE(v_char_dt, 'DD-MM-YYYY');
				p_dt_picture := 'DD-MM-YYYY';
				RETURN TRUE;
				EXCEPTION WHEN OTHERS THEN
				BEGIN
					v_return_dt := TO_DATE(v_char_dt, 'DD-MM-YY HH24:MI:SS');
					p_dt_picture := 'DD-MM-YY HH24:MI:SS';
					RETURN TRUE;
					EXCEPTION WHEN OTHERS THEN
					BEGIN
						v_return_dt := TO_DATE(v_char_dt, 'DD-MM-YYYY HH24:MI:SS');
						p_dt_picture := 'DD-MM-YYYY HH24:MI:SS';
						RETURN TRUE;
						EXCEPTION WHEN OTHERS THEN
						BEGIN
							v_return_dt := TO_DATE(v_char_dt, 'DD/MM/YY HH24:MI:SS');
							p_dt_picture := 'DD/MM/YY HH24:MI:SS';
							RETURN TRUE;
							EXCEPTION WHEN OTHERS THEN
							BEGIN
								v_return_dt := TO_DATE(v_char_dt, 'DD/MM/YYYY HH24:MI:SS');
								p_dt_picture := 'DD/MM/YYYY HH24:MI:SS';
								RETURN TRUE;
								EXCEPTION WHEN OTHERS THEN
									p_dt_picture := ' ';
									RETURN FALSE;
							END;
						END;
					END;
				END;
			END;
		END;
	END;
END;
END jbsp_get_dt_picture;

  FUNCTION get_day (
    p_day_short_name IN VARCHAR2
  ) RETURN VARCHAR2 IS
    CURSOR cur_day (cp_day_short_name IN VARCHAR2) IS
      SELECT    meaning
      FROM      fnd_lookups
      WHERE     lookup_type = 'DAY_NAME'
      AND       lookup_code = cp_day_short_name;
    l_day fnd_lookups.meaning%TYPE;
  BEGIN
    OPEN cur_day (p_day_short_name);
    FETCH cur_day INTO l_day;
    CLOSE cur_day;
    RETURN (l_day);
  END get_day;

  -- Created msrinivi
  -- 28 Feb, 03
  -- Returns P_QUERY_STR is > 0
  -- else returns 0. Used when we want
  -- to display zero for -ve numbers

  FUNCTION get_positive_num(
    P_NUMBER IN NUMBER
  ) RETURN VARCHAR2 IS
    l varchar2(2000) ;
  BEGIN
      IF P_NUMBER  IS NULL THEN
        RETURN P_NUMBER  ;
      END IF;

      SELECT TO_CHAR(decode(sign(to_number(P_NUMBER )),-1,0,to_number(P_NUMBER))) into l from dual;
      RETURN l;

   EXCEPTION
   WHEN OTHERS THEN
   RETURN l;
  END;

FUNCTION get_unit_set_title (p_unit_set_cd VARCHAR2) RETURN VARCHAR2 IS

  CURSOR c_title (cp_unit_set_cd  igs_en_unit_set.unit_set_cd%TYPE) IS
         SELECT us_out.abbreviation, us_out.short_title, us_out.title
	 FROM   igs_en_unit_set us_out
	 WHERE  us_out.unit_set_cd = cp_unit_set_cd
	 AND    us_out.version_number = (SELECT version_number
                                  FROM   igs_en_unit_set us_in ,
                                         igs_en_unit_set_stat uss
			          WHERE uss.unit_set_status = us_in.unit_set_status
				  AND   us_in.unit_set_cd = us_out.unit_set_cd
                                  AND   uss.s_unit_set_status = 'ACTIVE'
			          AND   rownum = 1);
  rec_title c_title%ROWTYPE;

  CURSOR c_setup IS
         SELECT wif_unit_set_title
	 FROM   igs_da_setup
	 WHERE  s_control_num = 1;
  l_wif_unit_set_title igs_da_setup.wif_unit_set_title%TYPE;
BEGIN
  -- get unit set title
  OPEN c_title (p_unit_set_cd);
  FETCH c_title INTO rec_title;
  CLOSE c_title;
  -- get the setup
  OPEN c_setup;
  FETCH c_setup INTO l_wif_unit_set_title;
  CLOSE c_setup;

  IF l_wif_unit_set_title='ABBR' THEN
     RETURN rec_title.abbreviation;
  ELSIF l_wif_unit_set_title='STIL' THEN
     RETURN rec_title.short_title;
  ELSE
     RETURN rec_title.title;
  END IF;

END get_unit_set_title;

END IGS_GE_GEN_004 ;

/
