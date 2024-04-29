--------------------------------------------------------
--  DDL for Package Body IGS_AD_PG_DATA_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PG_DATA_LOAD" AS
/* $Header: IGSAD78B.pls 115.9 2003/09/04 06:46:28 akadam ship $ */
PROCEDURE  admp_vtac_pg_load_address   (
p_vtac_street_name     IN  VARCHAR2,
p_vtac_suburb          IN  VARCHAR2,
p_vtac_state           IN  VARCHAR2,
p_vtac_country         IN  VARCHAR2,
p_vtac_postcode        IN  NUMBER,
p_vtac_home_ph         IN  VARCHAR2,
p_vtac_bus_ph          IN  VARCHAR2,
p_aus_addr_type	       IN  VARCHAR2,
p_os_addr_type	       IN  VARCHAR2);

FUNCTION admp_vtac_pg_load_stu_off_crs (p_offer_round 		 IN NUMBER,
					p_override_adm_cat	 IN VARCHAR2,
					p_offer_letter_req_ind	 IN VARCHAR2,
					p_pre_enrol_ind		 IN VARCHAR2,
					basis_for_admission_type IN VARCHAR2)


RETURN BOOLEAN;

PROCEDURE admp_vtac_pg_load_tert_edu;

PROCEDURE admp_ins_vtac_pg_off  (
		errbuf	  				out NOCOPY varchar2,
    		retcode 				out NOCOPY number,
 		p_file_name				IN VARCHAR2 ,
       		p_offer_round				IN NUMBER,
      		p_acad_perd 				IN VARCHAR2,
      		p_adm_perd				IN VARCHAR2,
      		p_aus_addr_type				IN VARCHAR2,
      		p_os_addr_type				IN VARCHAR2,
      		p_alt_person_id_type			IN VARCHAR2,
      		p_override_adm_cat			IN VARCHAR2,
      		p_pre_enrol_ind				IN VARCHAR2,
      		p_offer_letter_req_ind			IN VARCHAR2,
      		p_org_id			        IN NUMBER)	IS

--Personal Details Section

vtac_id_num 	            	VARCHAR2(9);
vtac_surname			VARCHAR2(24);
vtac_gname1			VARCHAR2(17);
vtac_gname2			VARCHAR2(17);
vtac_DateOfBirth		VARCHAR2(8);
vtac_street_name		VARCHAR2(25);
vtac_suburb			VARCHAR2(25);
vtac_state			VARCHAR2(3);
vtac_postcode			VARCHAR2(4);
vtac_country			VARCHAR2(14);
vtac_home_ph			VARCHAR2(12);
vtac_bus_ph			VARCHAR2(12);
vtac_sex			VARCHAR2(1);
vtac_prev_surname 		VARCHAR2(24);
vtac_prev_gname1 		VARCHAR2(17);
vtac_prev_gname2  		VARCHAR2(17);
vtac_category			VARCHAR2(3);
vtac_residency			VARCHAR2(1);
v_message_name 			VARCHAR2(30);
message_str			VARCHAR2(2000);
v_initial			VARCHAR2(1);
admission_cd			VARCHAR2(80);
basis_for_admission_type	VARCHAR2(80);
v_last_char                     VARCHAR2(1);

vtac_pg_filehandle       	UTL_FILE.FILE_TYPE;
vtac_filedir 		        VARCHAR2(100);
CURSOR  c_api (cp_api_person_id                IGS_PE_ALT_PERS_ID.api_person_id%TYPE,
	       cp_alt_person_id_type           IGS_PE_ALT_PERS_ID.person_id_type%TYPE) IS
     	SELECT  pe_person_id
          FROM  IGS_PE_ALT_PERS_ID
         WHERE  api_person_id = cp_api_person_id
           AND  person_id_type = cp_alt_person_id_type
           AND  start_dt < SYSDATE
           AND  NVL(end_dt,SYSDATE) >= SYSDATE;

BEGIN

	retcode := 0;
	igs_ge_gen_003.set_org_id(p_org_id);

-- extract academic calendar
p_acad_cal_type := RTRIM(SUBSTR(p_acad_perd, 101, 10));
p_acad_seq_num := IGS_GE_NUMBER.TO_NUM(RTRIM(SUBSTR(p_acad_perd, 112, 6)));

-- extract admission calendar
p_adm_cal_type := RTRIM(SUBSTR(p_adm_perd, 101, 10));
p_adm_seq_num := IGS_GE_NUMBER.TO_NUM(RTRIM(SUBSTR(p_adm_perd, 112, 6)));



IF (IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
			p_acad_cal_type,
			p_acad_seq_num,
			p_adm_cal_type,
			p_adm_seq_num,
			'N') = 'N') THEN

                  ERRBUF :=  FND_MESSAGE.GET_STRING('IGS','IGS_AD_CAL_DOES_NOT_EXIST');
                  retcode := 2;
                  Return;
END IF;

-- The VTAC admission code E41 is assumed for all students.  There is
-- no value given in the file.

G_pg_ret_val := 0;
--Get the data we need for inserting adm_course_appl record

	IF (IGS_AD_GEN_003.ADMP_GET_AC_BFA(
				'E41',
				admission_cd,
				basis_for_admission_type,
				v_message_name) = FALSE)   THEN

	       G_pg_message_str := FND_MESSAGE.GET_STRING('IGS',v_message_name);
	       FND_FILE.PUT_LINE( FND_FILE.LOG,vtac_id_num||'.'||RTRIM(G_pg_message_str));
               ROLLBACK;
               RETCODE := 2;
               RETURN;
        END IF;

admission_cd	          :=  RTRIM(admission_cd);
basis_for_admission_type  :=  RTRIM(basis_for_admission_type);



-- Open the file p_file_name for reading, the directory must be specified in the                                       	 -- instance parameter initialization file(INIT.ORA) using the UTL_FILE_DIR
-- parameter

vtac_filedir := nvl(RTRIM(FND_PROFILE.VALUE('IGS_IN_FILE_PATH')),' ');
v_last_char  := SUBSTR(vtac_filedir,LENGTH(vtac_filedir),1);

IF v_last_char IN ('/','\') THEN    -- '/' To match UNIX & '\' for NT
   vtac_filedir := SUBSTR(vtac_filedir,1,LENGTH(vtac_filedir)-1);
END IF;

vtac_pg_filehandle  :=   UTL_FILE.FOPEN(vtac_filedir, p_file_name,  'r');



--Process  Offers

LOOP    -- Main Loop
      BEGIN
          UTL_FILE.GET_LINE(vtac_pg_filehandle,G_vtac_pg_output_buffer);
      EXCEPTION
            	WHEN  NO_DATA_FOUND  THEN
             	EXIT;
      END;

--Commit the changes for the previous student

IF G_pg_test_only  = 'TRUE'  THEN
        ROLLBACK;
ELSE
        COMMIT;
END IF;


G_pg_read_number := G_pg_read_number + 1;

-- Transfer the data to the host variables

vtac_id_num 	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,1,9));
vtac_surname 	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,10,24));
vtac_gname1	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,34,17));
vtac_gname2	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,51,17));
vtac_DateOfBirth     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,68,8));
vtac_street_name     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,76,25));
vtac_suburb	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,101,25));
vtac_state	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,126,3));
vtac_postcode	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,129,4));
vtac_country	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,133,14));
vtac_home_ph	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,147,12));
vtac_bus_ph	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,159,12));
vtac_sex	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,171,1));
vtac_prev_surname    :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,172,24));
vtac_prev_gname1     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,196,17));
vtac_prev_gname2     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,213,17));
vtac_residency	     :=     RTRIM(SUBSTR(G_vtac_pg_output_buffer,274,1));

--  Log the student loaded
FND_FILE.PUT_LINE( FND_FILE.LOG,
    G_pg_read_number||'-'||vtac_id_num||' '||vtac_surname||' '||vtac_DateOfBirth);

--  Check to see if the person already exists on Callista.
 -- Match on surname, birth date, sex and first initial of first name.

v_initial  :=   SUBSTR(vtac_gname1,1,1);

-- This module attempts to find a person based on surname, birth date,
-- sex and first initial
G_pg_match_person_id := IGS_AD_GEN_007.ADMP_GET_MATCH_PRSN(
				        vtac_surname,
					vtac_DateOfBirth,	-- format 'DDMMYYYY'
					vtac_sex,
					v_initial,
					v_message_name);

IF (v_message_name IS NOT NULL) THEN

	-- vtac_DateOfBirth has wrong date format
	G_pg_message_str := FND_MESSAGE.GET_STRING('IGS', v_message_name);
	FND_FILE.PUT_LINE( FND_FILE.LOG,vtac_id_num||'.'||RTRIM(G_pg_message_str));
END IF;

IF G_pg_match_person_id = 0 THEN
	OPEN    c_api (vtac_id_num,
         	       p_alt_person_id_type);
	FETCH   c_api INTO G_pg_match_person_id;
	IF (c_api%NOTFOUND) THEN
         	      G_pg_match_person_id := 0;
	END IF;

	CLOSE c_api;
END IF;


-- Concatenate First Given Name with Second Given Name

IF vtac_gname2 IS NOT NULL THEN
          G_vtac_pg_all_given_names := RTRIM(vtac_gname1||' '||vtac_gname2);
END IF;

G_pg_ret_val := 0;


	-- This module uses information from the TAC offer load process
  	-- to create person and alternate person ID records if they
  	-- don't already exist
	IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_TAC_PRSN(
					G_pg_match_person_id,
					vtac_id_num,
					vtac_surname,
					G_vtac_pg_all_given_names,
					vtac_sex,
					TO_DATE(vtac_DateOfBirth,'DDMMYYYY'),
					p_alt_person_id_type,
					G_pg_new_person_id,	-- OUT NOCOPY
					G_pg_message_str) = FALSE
	THEN
		ROLLBACK;
                FND_FILE.PUT_LINE( FND_FILE.LOG, RTRIM(G_pg_message_str));
       		UTL_FILE.FCLOSE(vtac_pg_filehandle);
      		retcode := 2;
                return;
	END IF;



--Log the creating record message
FND_FILE.PUT_LINE( FND_FILE.LOG, RTRIM(G_pg_message_str));



--Save the ID number we have used so far into a new variable. We can then use this
--variable from now on regardless of if  the student was new or matched.

IF G_pg_match_person_id <> 0 THEN
          G_pg_current_person_id  := G_pg_match_person_id;
ELSE
          G_pg_current_person_id  := G_pg_new_person_id;
END IF;


--Load the address


admp_vtac_pg_load_address(
			vtac_street_name,
			vtac_suburb,
			vtac_state,
			vtac_country,
			vtac_postcode,
			vtac_home_ph,
			vtac_bus_ph,
			p_aus_addr_type,
			p_os_addr_type);


-- Only continue if admission application is created


IF (admp_vtac_pg_load_stu_off_crs( p_offer_round,
				   p_override_adm_cat,
				   p_offer_letter_req_ind,
				   p_pre_enrol_ind,
				   basis_for_admission_type) = TRUE)  THEN

                           --Load ter edu details
                           admp_vtac_pg_load_tert_edu;

ELSE
  IF G_pg_match_person_id  = 0  THEN
       FND_FILE.PUT_LINE( FND_FILE.LOG,G_pg_current_person_id||
                                             ' '||IGS_GE_GEN_004.GENP_GET_LOOKUP('REPORT','REJTD'));
  END IF;

END IF;

END LOOP;  -- End of enormous main Loop.

-- Commit any changes made for the last student

IF G_pg_test_only  =  'TRUE'  THEN
        ROLLBACK;
ELSE
        COMMIT;
END IF;

FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NUM_OF_RECORD_READ')||' - '||G_pg_read_number);

UTL_FILE.FCLOSE(vtac_pg_filehandle);

EXCEPTION
WHEN UTL_FILE.INVALID_PATH THEN
	UTL_FILE.FCLOSE(vtac_pg_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_INVALID_PATH');
            retcode := 2;

WHEN UTL_FILE.INVALID_MODE THEN
	UTL_FILE.FCLOSE(vtac_pg_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS', 'IGS_GE_INVALID_MODE');
            retcode := 2;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
	UTL_FILE.FCLOSE(vtac_pg_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_INVALID_FILE_HANDLE');
            retcode := 2;

WHEN UTL_FILE.INVALID_OPERATION THEN
	UTL_FILE.FCLOSE(vtac_pg_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_INVALID_OPER');
            retcode := 2;

WHEN UTL_FILE.READ_ERROR THEN
	UTL_FILE.FCLOSE(vtac_pg_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_READ_ERR');
            retcode := 2;

WHEN UTL_FILE.WRITE_ERROR THEN
	UTL_FILE.FCLOSE(vtac_pg_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_WRITE_ERR');
            retcode := 2;

WHEN UTL_FILE.INTERNAL_ERROR THEN
	UTL_FILE.FCLOSE(vtac_pg_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_INTERNAL_ERR');
            retcode := 2;

WHEN NO_DATA_FOUND THEN
	UTL_FILE.FCLOSE(vtac_pg_filehandle);
            ERRBUF:=  IGS_GE_GEN_004.GENP_GET_LOOKUP('REPORT','NO_DATA');
            retcode := 2;

WHEN OTHERS THEN
	UTL_FILE.FCLOSE(vtac_pg_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
            retcode := 2;
            IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END admp_ins_vtac_pg_off;


--Load Address

PROCEDURE admp_vtac_pg_load_address (
             p_vtac_street_name IN VARCHAR2 ,
             p_vtac_suburb	IN VARCHAR2 ,
             p_vtac_state       IN VARCHAR2 ,
             p_vtac_country     IN VARCHAR2 ,
             p_vtac_postcode    IN NUMBER ,
             p_vtac_home_ph     IN VARCHAR2 ,
             p_vtac_bus_ph      IN VARCHAR2,
             p_aus_addr_type	IN VARCHAR2,
             p_os_addr_type	IN VARCHAR2)		IS

      v_message_name 		VARCHAR2(30);
      aust_address		VARCHAR2(5);
      message_str		VARCHAR2(2000);


BEGIN

-- Have to work out NOCOPY if the address is Australian or overseas.
-- If an Australian address then STATE always has the state.


 IF  SUBSTR(p_vtac_state,1,3)  IN ('VIC','NSW','ACT','QLD','TAS')  OR
       SUBSTR(p_vtac_state,1,2)  IN ('NT','WA','SA')  THEN

	aust_address	:=  'TRUE';

ELSE

	aust_address	:=  'FALSE';

END IF;


IF aust_address = 'TRUE' THEN

G_pg_ret_val := 0;

--Procedure inserts a new person address record
		IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_PERSON_ADDR(
						G_pg_current_person_id,
						p_aus_addr_type,
						SYSDATE,
						p_vtac_street_name,
						p_vtac_suburb,
						p_vtac_state,
						NULL,
						p_vtac_postcode,
						NULL,
						p_vtac_home_ph,
						p_vtac_bus_ph,
						v_message_name) = FALSE	THEN


			G_pg_message_str := FND_MESSAGE.GET_STRING('IGS', v_message_name);
			FND_FILE.PUT_LINE(FND_FILE.LOG,
                              FND_MESSAGE.GET_STRING('IGS','IGS_GE_INVALID_VALUE')||'-'||p_vtac_postcode);
			FND_FILE.PUT_LINE( FND_FILE.LOG, G_pg_current_person_id||' '||RTRIM(G_pg_message_str));

		END IF;

ELSE

        G_pg_ret_val := 0;
         --Procedure inserts a new person address record
	IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_PERSON_ADDR(
						G_pg_current_person_id,
						p_os_addr_type,
						SYSDATE,
						p_vtac_street_name,
						p_vtac_suburb,
						NULL,
						p_vtac_country,
						NULL,
						p_vtac_postcode,
						p_vtac_home_ph,
						p_vtac_bus_ph,
						v_message_name) = FALSE	THEN
		G_pg_message_str := FND_MESSAGE.GET_STRING('IGS', v_message_name);
		FND_FILE.PUT_LINE( FND_FILE.LOG,G_pg_current_person_id||' '||RTRIM(G_pg_message_str));

      	END IF;


END  IF;  --End of if aust_address


EXCEPTION

WHEN OTHERS THEN
            	RAISE;
END admp_vtac_pg_load_address;     --end of load address



--Load the students offered courses


FUNCTION admp_vtac_pg_load_stu_off_crs (
			p_offer_round		IN NUMBER,
			p_override_adm_cat 	IN VARCHAR2,
			p_offer_letter_req_ind	IN VARCHAR2,
			p_pre_enrol_ind		IN VARCHAR2,
			basis_for_admission_type IN VARCHAR2)
RETURN BOOLEAN	IS


--Course preference section (13)

vtac_inco			VARCHAR2(5);
vtac_offer_status		VARCHAR2(1);
vtac_offer_round		VARCHAR2(1);

valid_pref			VARCHAR2(5)  :=  'FALSE';
course_cd			VARCHAR2(80);
attendence_mode 		VARCHAR2(80);
admission_cat			VARCHAR2(80);
admission_cd			VARCHAR2(80);
basis_for_admision_type 	VARCHAR2(80);
return_type			VARCHAR2(80);
tac_course_match_ind		VARCHAR2(80);
v_message_name		        VARCHAR2(30);
message_str			VARCHAR2(2000);

TYPE pref_str_table IS TABLE OF VARCHAR2( 40)
INDEX BY BINARY_INTEGER;
pref_str   pref_str_table;
j    BINARY_INTEGER  :=  1;
i    NUMBER  := 310;
k   NUMBER  := 1;

BEGIN

--Transfer the course preference section data from the VTAC PG offer file to the
-- PL/SQL table  of strings

      WHILE  i   < 470
      LOOP
          pref_str(j)  := RTRIM(SUBSTR(G_vtac_pg_output_buffer,i,32));
          i  := i  + 32;
          j  := j   + 1;
      END LOOP;


-- Loop through the preferences looking for Deakin  Courses(s). Validate that
-- this is an actual course.



WHILE k <=5
LOOP
     vtac_inco  :=  RTRIM(SUBSTR(pref_str(k),1,5));
     vtac_offer_round	:= RTRIM(SUBSTR(pref_str(k),17,1));
     vtac_offer_status := RTRIM(SUBSTR(pref_str(k),18,1));


IF  vtac_inco  IS NULL THEN
    GOTO pref_loop; --Do not process this record, go to the end of the while loop
END IF;


-- We only want to process for offered courses for the correct offer round
IF vtac_offer_status = 'O'  AND vtac_offer_round = SUBSTR(p_offer_round,1,1)
     THEN
	 --   Get the data we need for inserting an admission_appl
         IF  p_override_adm_cat  IS NOT NULL THEN
              admission_cat  :=  p_override_adm_cat;
	 END IF;

G_pg_ret_val := 0;

-- Inserts TAC details to form an admission course
         IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_TAC_COURSE(
		        	p_acad_cal_type,
				p_acad_seq_num,
				p_adm_cal_type,
				p_adm_seq_num,
				admission_cat,
				NULL, -- fee category
				NULL, -- enrolment cat
				NULL, -- correspondence cat
				G_pg_current_person_id,
				vtac_inco, 	-- match_course,
				NULL,		-- preference number
				SYSDATE,	-- application date
				SYSDATE,	-- offer date
				basis_for_admission_type,
				admission_cd,
				'N',
				 NULL,
				p_offer_letter_req_ind,
					-- VTAC produces offer letter
					-- on Deakin's behalf
				p_pre_enrol_ind,
				course_cd,		    -- OUT NOCOPY
				tac_course_match_ind,   -- OUT NOCOPY
				return_type,       		-- OUT NOCOPY
				v_message_name)	= FALSE
			THEN
				G_pg_message_str := FND_MESSAGE.GET_STRING('IGS', v_message_name);
				G_pg_ret_val := 1;
	END IF;

 course_cd             := RTRIM(course_cd);
 tac_course_match_ind  := RTRIM(tac_course_match_ind);
 return_type           := RTRIM(return_type);



IF  G_pg_ret_val = 1  THEN
       G_pg_message_str   := RTRIM(G_pg_message_str);

       IF  return_type = 'W'   THEN

        	FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_WARNING_APPLICANT')||' '||          																																					                                  G_pg_current_person_id||'-'||course_cd||'-'||G_pg_message_str||'-'||
                                  FND_MESSAGE.GET_STRING('IGS','IGS_AD_CREATE_PENDING_OC_STAT'));

	        valid_pref  :=   'TRUE';

	ELSE

	      -- Process next offer if no TAC match


	      IF tac_course_match_ind  = 'N' THEN
		   GOTO   pref_loop;
	      END IF;


		--There must have been an error inserting
	     FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_ERR_APPLICANT')||' '|| G_pg_current_person_id||' '||course_cd||'-'||G_pg_message_str);

	     RETURN FALSE;

	     ROLLBACK;

        END IF;      --End of if return_type

ELSE
                valid_pref  :=  'TRUE';

END IF;   -- End of if G_pg_ret_val

END IF;   --End of if vtac_offer_status   -- Course offered and correct round   ******/

 <<pref_loop>>
k := k + 1;
END LOOP;   -- End of while loop


IF  valid_pref = 'FALSE' THEN
 FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NO_VALID_PREFERENCES')||' '||
			G_pg_current_person_id);
END IF;


RETURN  TRUE;

EXCEPTION

WHEN OTHERS THEN
     RAISE;

END admp_vtac_pg_load_stu_off_crs;        -- End of Load the students offered courses.


--Load tert edu details

PROCEDURE admp_vtac_pg_load_tert_edu IS

--Tertiary study detail.

	vtac_tert_year_commence		VARCHAR2(4);
	vtac_tert_year_finish		VARCHAR2(4);
	vtac_tert_institute		VARCHAR2(14);
	vtac_tert_qual			VARCHAR2(10);
	vtac_tert_status	      	VARCHAR2(1);
	vtac_tert_student_idnum		VARCHAR2(9);
	vtac_tert_inst_code		VARCHAR2(4);

	start_yr	        	NUMBER(4);
        end_yr		        	NUMBER(4);

        v_message_name	                VARCHAR2(30);
	v_inserted_ind  		VARCHAR2(1);
        message_str		        VARCHAR2(2000);


TYPE po_sec_str_table IS TABLE OF VARCHAR2(50)
    	     INDEX BY BINARY_INTEGER;
po_sec_str   po_sec_str_table;

	j    BINARY_INTEGER;
       	i    NUMBER;
	k   NUMBER;

BEGIN

--Transfer the course post secondary level qualification data from the VTAC PG
--offer file to the PL/SQL table  of strings

       i  := 609;
       j  := 1;
       k  :=  1;
WHILE  i   < 793
   LOOP
            po_sec_str(j)  := RTRIM(SUBSTR(G_vtac_pg_output_buffer,i,46));
             i  := i  + 46;
             j  := j   + 1;
  END LOOP;


--Loop through the Tertiary study details

WHILE k <= 4
  LOOP
    vtac_tert_status := RTRIM(SUBSTR(po_sec_str(k),33,1));

    -- If the record is blank then get the next one
    IF nvl(vtac_tert_status,' ') = ' '  THEN
	GOTO tert_edu_loop;
    END IF;

vtac_tert_year_commence  := RTRIM(SUBSTR(po_sec_str(k),1,4));
vtac_tert_year_finish    := RTRIM(SUBSTR(po_sec_str(k),5,4));

start_yr                 :=  IGS_GE_NUMBER.TO_NUM(vtac_tert_year_commence);
end_yr                   :=  IGS_GE_NUMBER.TO_NUM(vtac_tert_year_finish);


vtac_tert_student_idnum  := RTRIM(SUBSTR(po_sec_str(k),34,9));
vtac_tert_inst_code      := RTRIM(SUBSTR(po_sec_str(k),43,4));
vtac_tert_institute      := RTRIM(SUBSTR(po_sec_str(k),9,14));
vtac_tert_qual	       := RTRIM(SUBSTR(po_sec_str(k),23,10));

G_pg_ret_val := 0;
-- Insert a tertiary education record
 	IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_TERT_EDU(
				G_pg_current_person_id,
				'N',	--exclusion indiacator
				vtac_tert_status,
				start_yr,
				vtac_tert_inst_code,
				end_yr,
				NULL,		--grade point average
				NULL,		--language of tuition
				NULL,		--qualification
				UPPER(vtac_tert_institute),
						-- vtac may send inst names in mixed case
				NULL,		--equv full time yrs enr
				vtac_tert_student_idnum,
				NULL,		--course cd
				NULL,		--course title
				NULL,		--state cd
				NULL,		--level of achievement type
				NULL,		--field of study
				NULL,		--language component
				NULL,		--country cd
				vtac_tert_qual,
				NULL,		-- honours level
				NULL,		--notes
				v_message_name,
				v_inserted_ind) = FALSE	THEN

				G_pg_message_str := FND_MESSAGE.GET_STRING('IGS', v_message_name);
         	FND_FILE.PUT_LINE( FND_FILE.LOG,G_pg_current_person_id||'-'||RTRIM(G_pg_message_str));

END IF;


  << tert_edu_loop >>
  k := k + 1;
END LOOP;  --End tert_edu_loop while loop


EXCEPTION

WHEN OTHERS THEN
	RAISE;

END admp_vtac_pg_load_tert_edu;  -- End of Load ter edu details

END IGS_AD_PG_DATA_LOAD;	--End of Package Specification

/
