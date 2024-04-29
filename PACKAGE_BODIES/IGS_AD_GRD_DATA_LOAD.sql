--------------------------------------------------------
--  DDL for Package Body IGS_AD_GRD_DATA_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GRD_DATA_LOAD" AS
/* $Header: IGSAD77B.pls 120.0 2005/06/01 20:44:33 appldev noship $ */

PROCEDURE admp_vtac_load_address (
p_vtac_addr1      IN VARCHAR2,
p_vtac_addr2	  IN VARCHAR2,
p_vtac_addr3      IN VARCHAR2,
p_vtac_addr4      IN VARCHAR2,
p_vtac_postcode   IN NUMBER,
p_vtac_home_ph    IN VARCHAR2,
p_vtac_bus_ph     IN VARCHAR2,
p_aus_addr_type	  IN VARCHAR2,
p_os_addr_type    IN VARCHAR2 );

FUNCTION admp_vtac_load_stu_off_crs
	(p_offer_round	              IN NUMBER,
         p_override_adm_cat           IN VARCHAR2,
	 p_fee_paying_appl_ind        IN VARCHAR2,
	 p_fee_paying_hpo             IN VARCHAR2,
   	 p_offer_letter_req_ind       IN VARCHAR2,
	 p_pre_enrol_ind	      IN VARCHAR2)
RETURN BOOLEAN;

PROCEDURE admp_vtac_load_sec_edu;

PROCEDURE admp_vtac_load_tert_edu;





-- Inserts a person and alternate person ID record with data from TAC
PROCEDURE admp_ins_vtac_offer  (
      errbuf  				out NOCOPY varchar2,
      retcode 				out NOCOPY number,
      p_file_name		      	IN VARCHAR2 ,
      p_offer_round			IN NUMBER,
      p_acad_perd 			IN VARCHAR2,
      p_adm_perd		        IN VARCHAR2,
      p_aus_addr_type			IN VARCHAR2,
      p_os_addr_type			IN VARCHAR2,
      p_alt_person_id_type		IN VARCHAR2,
      p_override_adm_cat		IN VARCHAR2,
      p_fee_payment			IN VARCHAR2,
      p_fee_paying_hpo  		IN VARCHAR2,
      p_pre_enrol_ind			IN VARCHAR2,
      p_offer_letter_req_ind		IN VARCHAR2,
      p_org_id			        IN NUMBER)  IS


--Personal Details Section
vtac_id_num 	    	        VARCHAR2(9);
vtac_surname		        VARCHAR2(24);
vtac_gname1			VARCHAR2(17);
vtac_gname2			VARCHAR2(17);
vtac_DateOfBirth		VARCHAR2(8);
vtac_addr1			VARCHAR2(25);
vtac_addr2			VARCHAR2(25);
vtac_addr3			VARCHAR2(3);
vtac_postcode		        VARCHAR2(4);
vtac_addr4			VARCHAR2(14);
vtac_home_ph		        VARCHAR2(12);
vtac_bus_ph			VARCHAR2(12);
vtac_sex			VARCHAR2(1);
vtac_category		        VARCHAR2(3);
v_message_name 		        VARCHAR2(30);

v_initial			VARCHAR2(1);
message_str			VARCHAR2(2000);

vtac_filehandle	        	UTL_FILE.FILE_TYPE;
vtac_filedir 		        VARCHAR2(255);
v_last_char                     VARCHAR2(1);


CURSOR	c_api (	cp_api_person_id
 		IGS_PE_ALT_PERS_ID.api_person_id%TYPE, cp_alt_person_id_type
 		IGS_PE_ALT_PERS_ID.person_id_type%TYPE) IS
     SELECT    pe_person_id
     FROM 	IGS_PE_ALT_PERS_ID
     WHERE    api_person_id = cp_api_person_id
     AND         person_id_type = cp_alt_person_id_type
     AND     start_dt < SYSDATE
     AND     NVL(end_dt,SYSDATE) >= SYSDATE;

BEGIN
igs_ge_gen_003.set_org_id(p_org_id);
retcode := 0;

-- extract academic calendar
p_acad_cal_type := RTRIM(SUBSTR(p_acad_perd, 101, 10));
p_acad_seq_num  := IGS_GE_NUMBER.TO_NUM(RTRIM(SUBSTR(p_acad_perd, 112, 6)));

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

--decode p_fee_payment to required value
IF (p_fee_payment = 'FEE-PAYING') THEN
	p_fee_paying_appl_ind := 'Y';
ELSIF (p_fee_payment = 'HECS') THEN
	p_fee_paying_appl_ind := 'N';
ELSE
	p_fee_paying_appl_ind := 'U';
END IF;

--Open the file p_file_name for reading, the directory must be specified in the                                        --(INIT.ORA) using the UTL_FILE_DIR --parameter

vtac_filedir := nvl(RTRIM(FND_PROFILE.VALUE('IGS_IN_FILE_PATH')),' ');
v_last_char  := SUBSTR(vtac_filedir,LENGTH(vtac_filedir),1);

IF v_last_char IN ('/','\') THEN    -- '/' To match UNIX & '\' for NT
   vtac_filedir := SUBSTR(vtac_filedir,1,LENGTH(vtac_filedir)-1);
END IF;


vtac_filehandle  :=   UTL_FILE.FOPEN(vtac_filedir, p_file_name,  'r');


--Process  Offers

LOOP    -- Main Loop
      BEGIN
            UTL_FILE.GET_LINE(vtac_filehandle, G_vtac_output_buffer);
      EXCEPTION
            WHEN  NO_DATA_FOUND  THEN
                  EXIT;
      END;

-- Commit the changes for the previous student

IF G_test_only  = 'TRUE'  THEN
        ROLLBACK;
ELSE
        COMMIT;
END IF;


G_read_number := G_read_number + 1;

--  Transfer the data to the host variables

vtac_id_num 	   	:=     RTRIM(SUBSTR(G_vtac_output_buffer,1,9));
vtac_surname	   	:=     RTRIM(SUBSTR(G_vtac_output_buffer,10,24));
vtac_gname1	   	:=     RTRIM(SUBSTR(G_vtac_output_buffer,34,17));
vtac_gname2	   	:=     RTRIM(SUBSTR(G_vtac_output_buffer,51,17));
vtac_DateOfBirth	:=     RTRIM(SUBSTR(G_vtac_output_buffer,68,8));
vtac_addr1		:=     RTRIM(SUBSTR(G_vtac_output_buffer,76,25));
vtac_addr2		:=     RTRIM(SUBSTR(G_vtac_output_buffer,101,25));
vtac_addr3		:=     RTRIM(SUBSTR(G_vtac_output_buffer,126,3));
vtac_addr4		:=     RTRIM(SUBSTR(G_vtac_output_buffer,129,14));
vtac_postcode		:=     RTRIM(SUBSTR(G_vtac_output_buffer,143,4));
vtac_home_ph		:=     RTRIM(SUBSTR(G_vtac_output_buffer,147,12));
vtac_bus_ph		:=     RTRIM(SUBSTR(G_vtac_output_buffer,159,12));
vtac_sex		:=     RTRIM(SUBSTR(G_vtac_output_buffer,171,1));


-- Log the student loaded
FND_FILE.PUT_LINE( FND_FILE.LOG,
    G_read_number||'-'||vtac_id_num||' '||vtac_surname||' '||vtac_DateOfBirth);


--  Check to see if the person already exists on Callista.
--  Match on surname, birth date, sex and first initial of first name.


v_initial  :=   SUBSTR(vtac_gname1,1,1);

-- admp_get_match_prsn module attempts to find a person based on surname,
-- birth date, sex and first initial.
G_match_person_id := IGS_AD_GEN_007.ADMP_GET_MATCH_PRSN(
                     			vtac_surname,
				        vtac_DateOfBirth,	-- format 'DDMMYYYY'
				        vtac_sex,
              				v_initial,
		        		v_message_name);

IF (v_message_name IS NOT NULL) THEN
  	-- vtac_DateOfBirth has wrong date format
            G_message_str := FND_MESSAGE.GET_STRING('IGS',v_message_name);
           FND_FILE.PUT_LINE( FND_FILE.LOG, vtac_id_num||'.'||RTRIM(G_message_str));
END IF;


IF G_match_person_id = 0 THEN
		OPEN	c_api (	vtac_id_num,
                 		p_alt_person_id_type);
		FETCH	c_api INTO G_match_person_id;
		IF (c_api%NOTFOUND) THEN
			G_match_person_id := 0;
		END IF;

		CLOSE c_api;
END IF;


-- Concatenate First Given Name with Second Given Name

IF vtac_gname2 IS NOT NULL THEN
          G_vtac_all_given_names := RTRIM(vtac_gname1||' '||vtac_gname2);
END IF;


-- This module uses information from the TAC offer load process
-- to create person and alternate person ID records if they
-- don't already exist.
IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_TAC_PRSN(
               		G_match_person_id,
			vtac_id_num,
			vtac_surname,
			G_vtac_all_given_names,
			vtac_sex,
			TO_DATE(vtac_DateOfBirth, 'DDMMYYYY'),
                        p_alt_person_id_type,
         		G_new_person_id,	-- OUT NOCOPY
			G_message_str) = FALSE

THEN
       ROLLBACK;
       FND_FILE.PUT_LINE( FND_FILE.LOG,RTRIM(G_message_str));
       UTL_FILE.FCLOSE(vtac_filehandle);
       retcode := 2;
       return;
END IF;


--Log the creating record message

FND_FILE.PUT_LINE( FND_FILE.LOG, RTRIM(G_message_str));

--Save the ID number we have used so far into a new variable. We can then use this
--variable from now on regardless of if  the student was new or matched.
IF G_match_person_id <> 0 THEN
          G_current_person_id  := G_match_person_id;
ELSE
          G_current_person_id  := G_new_person_id;
END IF;


-- Load the address
admp_vtac_load_address(
                       vtac_addr1,
                       vtac_addr2,
                       vtac_addr3,
                       vtac_addr4,
                       vtac_postcode,
                       vtac_home_ph,
                       vtac_bus_ph,
                       p_aus_addr_type,
                       p_os_addr_type);

-- Only continue if admission application is created

IF (admp_vtac_load_stu_off_crs( p_offer_round,
                                p_override_adm_cat,
                                p_fee_paying_appl_ind,
                                p_fee_paying_hpo,
                                p_offer_letter_req_ind,
                                p_pre_enrol_ind) = TRUE) THEN

       -- Load sec edu details and Load ter edu details

          admp_vtac_load_sec_edu;
          admp_vtac_load_tert_edu;

ELSE

   IF G_match_person_id  = 0  THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,G_current_person_id||' '||IGS_GE_GEN_004.GENP_GET_LOOKUP('REPORT','REJTD'));
   END IF;

END IF;

END LOOP;  -- End of enormous main Loop.

-- Commit any changes made for the last student
IF G_test_only  =  'TRUE'  THEN
        ROLLBACK;
ELSE
        COMMIT;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NUM_OF_RECORD_READ')||'-'||G_read_number);

UTL_FILE.FCLOSE(vtac_filehandle);

EXCEPTION
WHEN UTL_FILE.INVALID_PATH THEN
	UTL_FILE.FCLOSE(vtac_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_INVALID_PATH');
            retcode := 2;

WHEN UTL_FILE.INVALID_MODE THEN
	UTL_FILE.FCLOSE(vtac_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS', 'IGS_GE_INVALID_MODE');
            retcode := 2;

WHEN UTL_FILE.INVALID_FILEHANDLE THEN
	UTL_FILE.FCLOSE(vtac_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_INVALID_FILE_HANDLE');
            retcode := 2;

WHEN UTL_FILE.INVALID_OPERATION THEN
	UTL_FILE.FCLOSE(vtac_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_INVALID_OPER');
            retcode := 2;

WHEN UTL_FILE.READ_ERROR THEN
	UTL_FILE.FCLOSE(vtac_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_READ_ERR');
            retcode := 2;

WHEN UTL_FILE.WRITE_ERROR THEN
	UTL_FILE.FCLOSE(vtac_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_WRITE_ERR');
            retcode := 2;

WHEN UTL_FILE.INTERNAL_ERROR THEN
	UTL_FILE.FCLOSE(vtac_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_INTERNAL_ERR');
            retcode := 2;

WHEN NO_DATA_FOUND THEN
	UTL_FILE.FCLOSE(vtac_filehandle);
            ERRBUF:=  IGS_GE_GEN_004.GENP_GET_LOOKUP('REPORT','NO_DATA');
            retcode := 2;

WHEN OTHERS THEN
	UTL_FILE.FCLOSE(vtac_filehandle);
            ERRBUF:=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
            retcode := 2;
            IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END admp_ins_vtac_offer;



--Load Address

PROCEDURE admp_vtac_load_address (
              p_vtac_addr1      IN VARCHAR2,
              p_vtac_addr2	IN VARCHAR2,
              p_vtac_addr3      IN VARCHAR2,
              p_vtac_addr4      IN VARCHAR2,
              p_vtac_postcode   IN NUMBER,
              p_vtac_home_ph    IN VARCHAR2,
              p_vtac_bus_ph     IN VARCHAR2,
              p_aus_addr_type	IN VARCHAR2,
              p_os_addr_type    IN VARCHAR2 )		IS

     v_message_name	VARCHAR2(30);
     aust_address	VARCHAR2(5);
     message_str	VARCHAR2(2000);


BEGIN
          IF p_vtac_addr3 IS NOT NULL OR p_vtac_addr4 IS NULL THEN
                aust_address   :=  'TRUE';
          ELSE
                aust_address   :=  'FALSE';
          END IF;

IF aust_address = 'TRUE' THEN
		IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_PERSON_ADDR(
						G_current_person_id,
						p_aus_addr_type,
						SYSDATE,
						p_vtac_addr1,
						p_vtac_addr2,
						p_vtac_addr3,
						NULL,
						p_vtac_postcode,
						NULL,
						p_vtac_home_ph,
						p_vtac_bus_ph,
						v_message_name) = FALSE	THEN

		      G_message_str := FND_MESSAGE.GET_STRING('IGS',v_message_name);
 		      FND_FILE.PUT_LINE( FND_FILE.LOG,G_current_person_id||' '||RTRIM(G_message_str));
                END IF;

ELSE
		IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_PERSON_ADDR(
						G_current_person_id,
						p_os_addr_type,
						SYSDATE,
						p_vtac_addr1,
						p_vtac_addr2,
						NULL,
						p_vtac_addr4,
						NULL,
						p_vtac_postcode,
						p_vtac_home_ph,
						p_vtac_bus_ph,
						v_message_name) = FALSE	THEN

       	                 G_message_str :=  FND_MESSAGE.GET_STRING('IGS',v_message_name);
                         FND_FILE.PUT_LINE( FND_FILE.LOG,G_current_person_id||' '||RTRIM(G_message_str));
		END IF;
END IF;  --End of if aust_address

EXCEPTION

    WHEN OTHERS THEN
            RAISE;
END admp_vtac_load_address; --end of load address



--Load the students offered courses
FUNCTION admp_vtac_load_stu_off_crs
	(p_offer_round	                IN NUMBER,
         p_override_adm_cat		IN VARCHAR2,
   	 p_fee_paying_appl_ind          IN VARCHAR2,
	 p_fee_paying_hpo               IN VARCHAR2,
   	 p_offer_letter_req_ind         IN VARCHAR2,
	 p_pre_enrol_ind	        IN VARCHAR2)
RETURN BOOLEAN	IS

vtac_category			VARCHAR2(3);

--Course preference section (13)
vtac_inco			VARCHAR2(5);
vtac_offer_stream		VARCHAR2(1);
vtac_rank			VARCHAR2(5);
vtac_orig_rank		        VARCHAR2(4);
vtac_offer_status		VARCHAR2(1);
vtac_offer_round		VARCHAR2(1);
vtac_special_admissions	        VARCHAR2(1);

valid_pref			VARCHAR2(5)  :=  'FALSE';
course_cd			VARCHAR2(80);
attendence_mode 		VARCHAR2(80);
admission_cat			VARCHAR2(80);
admission_cd			VARCHAR2(80);
basis_for_admission_type	VARCHAR2(80);
return_type			VARCHAR2(80);
tac_course_match_ind		VARCHAR2(80);
message_str			VARCHAR2(2000);
v_message_name			VARCHAR2(30);

TYPE pref_str_table IS TABLE OF VARCHAR2( 25)
INDEX BY BINARY_INTEGER;
pref_str   pref_str_table;
j    BINARY_INTEGER  :=  1;
i    NUMBER  := 208;
k    NUMBER  := 1;

BEGIN

G_ret_val := 0;

vtac_category		:=     RTRIM(SUBSTR(G_vtac_output_buffer,172,3));

-- Get the data we need for inserting adm_course_appl record

	-- This module finds the user defined admission code and basis for
-- admission type from the admission code table.
		IF (IGS_AD_GEN_003.ADMP_GET_AC_BFA(
				vtac_category,
				admission_cd,
				basis_for_admission_type,
				v_message_name) = FALSE) THEN

			G_message_str := FND_MESSAGE.GET_STRING('IGS',v_message_name);
			FND_FILE.PUT_LINE( FND_FILE.LOG,
			RTRIM (G_message_str)||' '||vtac_category);
			RETURN FALSE;
			ROLLBACK;
		END IF;

admission_cd	          := RTRIM(admission_cd);
basis_for_admission_type  :=  RTRIM(basis_for_admission_type);

 	--Transfer the course preference section data from the VTAC file to the
--PL/SQL table  of strings

WHILE  i   < 442
LOOP
pref_str(j)  := RTRIM(SUBSTR(G_vtac_output_buffer,i,18));
i  := i  + 18;
j  := j   + 1;
END LOOP;


-- Loop through the preferences looking for Deakin  Courses(s). Validate that
-- this is an actual course.


-- << pref_loop >>
WHILE k <=13
LOOP
             vtac_inco         := RTRIM(SUBSTR(pref_str(k),1,5));
             vtac_offer_status := RTRIM(SUBSTR(pref_str(k),16,1));
             vtac_offer_round  := RTRIM(SUBSTR(pref_str(k),17,1));

IF  vtac_inco  IS NULL THEN
         GOTO pref_loop;  --Do not process this record, go to the end of the while loop
END IF;


 -- We only want to process for offered courses for the correct offer round
IF vtac_offer_status = 'O'  AND vtac_offer_round =SUBSTR(p_offer_round,1,1)
    THEN


--   Get the data we need for inserting an admission_appl

         IF  p_override_adm_cat  IS NOT NULL THEN
                   admission_cat  :=  p_override_adm_cat;
         END IF;

         G_ret_val := 0;
    -- Inserts TAC details to form an admission course
 	 IF     IGS_AD_PRC_TAC_OFFER.ADMP_INS_TAC_COURSE(
					p_acad_cal_type,
					p_acad_seq_num,
					p_adm_cal_type,
					p_adm_seq_num,
					admission_cat,
					NULL, -- fee category
					NULL, -- enrolment cat
					NULL, -- correspondence cat
					G_current_person_id,
					vtac_inco, 	-- match_course,
					1, 		-- preference number
					SYSDATE,	-- application date
					SYSDATE,	-- offer date
					basis_for_admission_type,
					admission_cd,
					p_fee_paying_appl_ind,
					p_fee_paying_hpo,
					p_offer_letter_req_ind,
						-- VTAC produces offer letter
						-- on Deakin's behalf
					p_pre_enrol_ind,
					course_cd,		    -- OUT NOCOPY
					tac_course_match_ind,   -- OUT NOCOPY
					return_type,       		-- OUT NOCOPY
					v_message_name)	= FALSE
				THEN
					G_message_str :=
					FND_MESSAGE.GET_STRING('IGS',
							v_message_name);
					G_ret_val := 1;
	END IF;



 course_cd   := RTRIM(course_cd);
 tac_course_match_ind  := RTRIM(tac_course_match_ind);
 return_type  := RTRIM(return_type);
 IF  G_ret_val = 1  THEN
       G_message_str   := RTRIM(G_message_str);

       IF  return_type = 'W'   THEN

             FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_WARNING_APPLICANT')||' '||
                                             G_current_person_id||'-'||course_cd||'-'||vtac_inco||'.'||
                                             G_message_str||'-'||
                                             FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADPS_APPL_INST_CREATIN'));
             valid_pref  :=   'TRUE';

       ELSE

              --  Process next offer if no TAC match

            IF tac_course_match_ind  = 'N' THEN
           	     --Do not process this record, go to the end of the while loop
	             GOTO   pref_loop;
            END IF;

           --There must have been an error inserting

           FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_ERR_APPLICANT')||' '||
                                             G_current_person_id||'-'||course_cd||'-'||vtac_inco||'.'||
                                             G_message_str||'-'||
                                             FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADPS_APPL_INST_CREATIN'));

           RETURN FALSE;
           ROLLBACK;

      END IF;      --End of if return_type

 ELSE
      valid_pref  :=  'TRUE';

 END IF;   -- End of if G_ret_val   	-- Course offered and correct round

END IF;	  -- End of if vtac_offer_status

<< pref_loop >>
k := k+1;
END LOOP;   --End of while loop


IF  valid_pref = 'FALSE' THEN
 FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NO_VALID_PREFERENCES')||' '||
			G_current_person_id);
END IF;


RETURN TRUE;

EXCEPTION
	WHEN OTHERS THEN
        RAISE;

END admp_vtac_load_stu_off_crs;        -- End of Load the students offered courses.

-- Load secondary education details
PROCEDURE admp_vtac_load_sec_edu  IS

--Secondary level qualifications   (4)


vtac_qual_year		VARCHAR2(4);
vtac_qual_type		VARCHAR2(1);
vtac_qual_school	VARCHAR2(3);
vtac_state_name		VARCHAR2(24);


--Results  (24)

vtac_result_year		VARCHAR2(4);
vtac_s_result_year		VARCHAR2(4);
vtac_subject_code		VARCHAR2(2);
vtac_subject_type		VARCHAR2(1);
vtac_gl_score			NUMBER(2);
vtac_est_gl_score		VARCHAR2(2);
vtac_fact_gl_score		VARCHAR2(2);
vtac_old_mark	        	VARCHAR2(3);
vtac_old_grade		        VARCHAR2(1);
vtac_unit_res_1		        VARCHAR2(1);
vtac_unit_res_2		        VARCHAR2(1);
vtac_unit_res_3		        VARCHAR2(1);
vtac_unit_res_4		        VARCHAR2(1);
vtac_average_cat_grade	        VARCHAR2(2);
vtac_s_ter	        	VARCHAR2(5);
vtac_s_est_ter 		        VARCHAR2(5);
vtac_s_factor_ter	        VARCHAR2(5);

vtac_study_count		NUMBER(2);

result_yr                       NUMBER(4);
study_cnt                       NUMBER(2);
sub_result_yr                   NUMBER(4);
score	                        NUMBER(5,2);
sub_result                      VARCHAR2(3);
ase_sequence_number             NUMBER(10);

TYPE  sec_edu_str_table  IS TABLE OF VARCHAR2(80)
     INDEX BY BINARY_INTEGER;
sec_edu_str	sec_edu_str_table;
j  BINARY_INTEGER := 1;
i  NUMBER  :=  1050;
k  NUMBER  :=  1;

message_str			VARCHAR2(2000);
v_message_name  		VARCHAR2(30);
v_dummy 			NUMBER;

CURSOR c_dup_chk is
     SELECT	1
     FROM 	IGS_AD_AUS_SEC_ED_SU ases
     WHERE 	ases.person_id		 = G_current_person_id and
                ases.ase_sequence_number = ase_sequence_number and
		ases.subject_result_yr 	= sub_result_yr and
		ases.subject_cd		= vtac_subject_code;

BEGIN

-- Take state_cd, ass_type and secondary school code data from the
 --first record of secondary level qualifications (sec_qual)
 --provided in the input file.

vtac_state_name := RTRIM(SUBSTR(G_vtac_output_buffer,608,24));

-- Check if the qualification is from a state of Australia.

IF  SUBSTR(vtac_state_name,1,3)  IN ('VIC','NSW','ACT','QLD','TAS')  OR
                      SUBSTR(vtac_state_name,1,2)   IN ('NT','WA','SA')  THEN
       G_aus_edu  := 'TRUE';

ELSE
       FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NO_SEC_QUALIFICATION')
		||'-'||G_current_person_id);
    	G_aus_edu  := 'FALSE';
END IF;

IF G_aus_edu   =  'TRUE'  THEN

      vtac_qual_type    :=  RTRIM(SUBSTR(G_vtac_output_buffer,604,1));
      vtac_qual_school  :=  RTRIM(SUBSTR(G_vtac_output_buffer,605,3));


--Take year and TER score data from the first record of result
--summary (result) provided in the input file.  See below.

      vtac_s_result_year := RTRIM(SUBSTR(G_vtac_output_buffer,1050,4));

-- Only insert aus scn edu if the result year is known

        IF vtac_s_result_year  IS NOT NULL THEN

            result_yr  :=  IGS_GE_NUMBER.TO_NUM(vtac_s_result_year);
            vtac_s_ter :=  RTRIM(SUBSTR(G_vtac_output_buffer,497,5));
	    score      :=  IGS_GE_NUMBER.TO_NUM(vtac_s_ter);

            IF  score  = 0 THEN
                  vtac_s_est_ter     := RTRIM(SUBSTR(G_vtac_output_buffer,502,5));
                  score              := IGS_GE_NUMBER.TO_NUM(vtac_s_est_ter);
            END IF;

            IF score = 0 THEN
 	          vtac_s_factor_ter  := RTRIM(SUBSTR(G_vtac_output_buffer,507,5));
                  score              := IGS_GE_NUMBER.TO_NUM(vtac_s_factor_ter);
            END IF;

            score  :=  score/100;

            G_ret_val := 0;
	    -- This procedure inserts a new aus_scndry_education record
		IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_AUS_SCN_EDU(
					G_current_person_id,
					result_yr,
					score,
					vtac_state_name,
					NULL,
					vtac_qual_type,
					vtac_qual_school,
					ase_sequence_number,	-- OUT NOCOPY
					v_message_name) = FALSE
			THEN
			G_message_str := FND_MESSAGE.GET_STRING('IGS',v_message_name);
		        FND_FILE.PUT_LINE( FND_FILE.LOG,
		                               G_message_str||' '||G_current_person_id||
                                                       ' '||vtac_state_name);
		 END IF;

            --Load the secondary education subjects if any exist.

            vtac_study_count  := RTRIM(SUBSTR(G_vtac_output_buffer,1048,2));
            study_cnt         := IGS_GE_NUMBER.TO_NUM(vtac_study_count);

            IF study_cnt  > 0  THEN

               --Transfer the secondary education subjects data form the VTAC file to the
               -- PL/SQL table of strings

               WHILE   i  <=  2658
                  LOOP
                     sec_edu_str(j)  :=  RTRIM(SUBSTR(G_vtac_output_buffer,i,67));
                     i := i + 67;
                     j := j + 1;
                  END LOOP;


              WHILE k <= study_cnt

                LOOP
                   vtac_result_year  :=  RTRIM(SUBSTR(sec_edu_str(k),1,4));
                   IF vtac_result_year IS NULL THEN
	               -- Do not process this record, go to end of the while loop
	               GOTO sec_edu_loop;
                   END IF;

                   sub_result_yr  :=  IGS_GE_NUMBER.TO_NUM(vtac_result_year);

	           -- Work out NOCOPY mark from possible mark fields

                   vtac_gl_score      := RTRIM(SUBSTR(sec_edu_str(k),8,2));
                   vtac_subject_code  := RTRIM(SUBSTR(sec_edu_str(k),5,2));
                   vtac_subject_type  := RTRIM(SUBSTR(sec_edu_str(k),7,1));

                   sub_result         :=  RTRIM(vtac_gl_score);

                   IF   sub_result IS NULL THEN
                        vtac_est_gl_score := RTRIM(SUBSTR(sec_edu_str(k),10 ,2));
                        sub_result        :=  vtac_est_gl_score;
	           END IF;

	           IF sub_result IS NULL THEN
                        vtac_fact_gl_score := RTRIM(SUBSTR(sec_edu_str(k),12,2));
                        sub_result         := vtac_fact_gl_score;
                   END IF;


                   G_ret_val := 0;
                   --check for duplicate record
		   OPEN c_dup_chk;
		   FETCH c_dup_chk into v_dummy;
                   IF (c_dup_chk%NOTFOUND)  THEN
	        	 -- Insert an Australian secondary education subject record
		        IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_AUS_SCN_SUB(
						G_current_person_id,
				  		ase_sequence_number,
						sub_result_yr,
						vtac_subject_code,
						NULL,
						sub_result,
						NULL,
						NULL,
						vtac_subject_type,
						NULL,
						v_message_name) = FALSE
		            THEN
                           G_message_str :=FND_MESSAGE.GET_STRING('IGS',v_message_name);
		           FND_FILE.PUT_LINE( FND_FILE.LOG,RTRIM(G_message_str) ||' '||G_current_person_id
                                          ||' '||vtac_state_name||' '||vtac_subject_code);
                       END IF;
		  ELSE
		       G_message_str := FND_MESSAGE.GET_STRING('IGS','IGS_GE_DUPLICATE_VALUE')||'-'
                                                                      ||IGS_GE_NUMBER.TO_CANN(sub_result_yr) ;
                       FND_FILE.PUT_LINE( FND_FILE.LOG,RTRIM(G_message_str) ||'-'||G_current_person_id
                                                      ||'-'||vtac_state_name||'-'||vtac_subject_code);

        	 END IF;   -- End of if c_dup_chk%NOTFOUND

		CLOSE c_dup_chk;

             <<sec_edu_loop>>
             k := k  +   1;
          END LOOP;  -- End sec_edu_loop while loop

       END IF;  -- End of if study_cnt

   END IF;  --End of vtac result year not null

END IF;   -- End of if G_aus_edu

EXCEPTION

WHEN OTHERS THEN
            RAISE;

END admp_vtac_load_sec_edu;  --End of Load sec edu details

--Load tert edu details

PROCEDURE admp_vtac_load_tert_edu IS

--Post Secondary levels qualifications Australia

       	vtac_post_sec_started		VARCHAR2(4);
	vtac_post_sec_completed		VARCHAR2(4);
	vtac_post_sec_level		VARCHAR2(2);
	vtac_post_sec_inst_code		VARCHAR2(4);
	vtac_post_sec_inst_name		VARCHAR2(12);
	vtac_post_sec_student_id	VARCHAR2(10);
	vtac_post_sec_compl		VARCHAR2(1);
	vtac_post_sec_gpa		VARCHAR2(3);


--Post Secondary levels qualifications Overseas

        vtac_post_sec_syear_ov	VARCHAR2(4);
	vtac_post_sec_cyear_ov	VARCHAR2(4);
	vtac_post_sec_inst_ov	VARCHAR2(17);
	vtac_post_sec_cntry_ov	VARCHAR2(12);
	vtac_post_sec_level_ov	VARCHAR2(2);
	vtac_post_sec_ccode_ov	VARCHAR2(1);


	institution_cd 		VARCHAR2(80);
	notes			VARCHAR2(80);

	start_yr		NUMBER(4);
	end_yr			NUMBER(4);
	gpa			NUMBER(3,2);

	v_message_name		VARCHAR2(30);
	v_inserted_ind		VARCHAR2(1);
	message_str		VARCHAR2(2000);

	TYPE  post_sec_str_table  IS TABLE OF VARCHAR2(50)
	     INDEX BY BINARY_INTEGER;
	po_sec_str   post_sec_str_table;

	TYPE po_sec_ov_str_table IS TABLE OF VARCHAR2(50)
    	     INDEX BY BINARY_INTEGER;
	po_sec_ov_str   po_sec_ov_str_table;

	j    BINARY_INTEGER  := 1;
	i    NUMBER          := 728;
       	k    NUMBER          := 1;


BEGIN

 --Transfer the course post secondary level qualification data from the VTAC file to
  --the PL/SQL table  of strings

        WHILE  i   < 888
          LOOP
            po_sec_str(j)  := RTRIM(SUBSTR(G_vtac_output_buffer,i,40));
                       i  := i  + 40;
                       j  := j  + 1;
          END LOOP;


--Loop through the Post secondary level qualification in Australia


     WHILE k <= 4
     LOOP
     	vtac_post_sec_compl := RTRIM(SUBSTR(po_sec_str(k),37,1));

	    IF nvl(vtac_post_sec_compl,' ') = ' '  THEN
	      --Do not process the record, got to end of the loop
		     GOTO po_sec_loop;
            END IF;


            --Do Y2K stuff for start and end years

            vtac_post_sec_started    := RTRIM(SUBSTR(po_sec_str(k),1,4));
            vtac_post_sec_completed  := RTRIM(SUBSTR(po_sec_str(k),5,4));

            start_yr  :=  IGS_GE_NUMBER.TO_NUM(vtac_post_sec_started);
            end_yr    :=  IGS_GE_NUMBER.TO_NUM(vtac_post_sec_completed);

            IF start_yr  > 50  THEN
                start_yr  :=  start_yr + 1900;
            ELSE
                start_yr  :=  start_yr + 2000;
            END IF;

            IF end_yr  > 50 THEN
                  end_yr  :=  end_yr  + 1900;
            ELSE
                  end_yr  := end_yr  + 2000;
            END IF;

           -- Get the GPA in a format we can use. It needs 2 decimal places

           vtac_post_sec_gpa  := RTRIM(SUBSTR(po_sec_str(k),38,3));
           gpa  :=  IGS_GE_NUMBER.TO_NUM(vtac_post_sec_gpa)/100;

           vtac_post_sec_student_id  := RTRIM(SUBSTR(po_sec_str(k),27,10));
           vtac_post_sec_inst_code   := RTRIM(SUBSTR(po_sec_str(k),11,4));
           vtac_post_sec_inst_name   := RTRIM(SUBSTR(po_sec_str(k),15,12));

           G_ret_val := 0;
           -- Insert a tertiary education record
 	   IF IGS_AD_PRC_TAC_OFFER.ADMP_INS_TERT_EDU(
				G_current_person_id,
				'N',
				vtac_post_sec_compl,
				start_yr,
				vtac_post_sec_inst_code,
				end_yr,
				gpa,
				NULL,
				NULL,
				vtac_post_sec_inst_name,
				NULL,
				vtac_post_sec_student_id,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				v_message_name,
				v_inserted_ind) = FALSE	THEN

	        G_message_str := FND_MESSAGE.GET_STRING('IGS',v_message_name);
                FND_FILE.PUT_LINE( FND_FILE.LOG,G_current_person_id||' '||RTRIM(G_message_str));
          END IF;

       << po_sec_loop >>
       k :=  k + 1;
    END LOOP;  --End po_sec_loop while loop



     --Transfer the course post secondary level qualification Overseas data from the
     --VTAC file to the PL/SQL table  of strings

i := 888;
j := 1;
k := 1;
WHILE  i   < 1048
  LOOP
    po_sec_ov_str(j)  := RTRIM(SUBSTR(G_vtac_output_buffer,i,40));
    i  := i  + 40;
    j  := j   + 1;
  END LOOP;



-- Loop through the Post Secondary level qualification Overseas



     WHILE k <= 4
     LOOP
	-- Find the level of completion
        vtac_post_sec_ccode_ov := RTRIM(SUBSTR(po_sec_ov_str(k),40,1));

	IF nvl(vtac_post_sec_ccode_ov,' ')  = ' '  THEN
                 --Do not process the current record, go to end of the loop
           GOTO po_sec_ov_loop;
        END IF;


	--Do Y2K stuff for start and end years

        vtac_post_sec_syear_ov  := RTRIM(SUBSTR(po_sec_ov_str(k),1,4));
        vtac_post_sec_cyear_ov  := RTRIM(SUBSTR(po_sec_ov_str(k),5,4));

        start_yr                :=  IGS_GE_NUMBER.TO_NUM(vtac_post_sec_syear_ov);
        end_yr                  :=  IGS_GE_NUMBER.TO_NUM(vtac_post_sec_cyear_ov);

        IF start_yr  > 50  THEN
                 start_yr  :=  start_yr + 1900;
        ELSE
                 start_yr  :=  start_yr + 2000;
        END IF;

        IF end_yr  > 50 THEN
                 end_yr   :=  end_yr  + 1900;
        ELSE
                 end_yr   := end_yr  + 2000;
        END IF;

       --We can't insert the overseas institution codes so we will
       --store the institution and the country in the notes field.
       --This should provide some extra info for the users.USES_ASE_FK

	vtac_post_sec_inst_ov  := RTRIM(SUBSTR(po_sec_ov_str(k),9,17));
        vtac_post_sec_cntry_ov := RTRIM(SUBSTR(po_sec_ov_str(k),26,12));
        notes  := vtac_post_sec_inst_ov||' , '||vtac_post_sec_cntry_ov;


 	G_ret_val := 0;
        -- Insert a tertiary education record
	IF (IGS_AD_PRC_TAC_OFFER.ADMP_INS_TERT_EDU(
				G_current_person_id,
				'N',
				vtac_post_sec_ccode_ov,
				start_yr,
				NULL,
				end_yr,
				NULL,
				NULL,
				NULL,
				notes,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				v_message_name,
				v_inserted_ind) = FALSE)	THEN

		G_message_str := FND_MESSAGE.GET_STRING('IGS',v_message_name);
		FND_FILE.PUT_LINE( FND_FILE.LOG,G_current_person_id||' '||RTRIM(G_message_str));

	 END IF;
        <<po_sec_ov_loop>>
      	 k := k + 1;
	END LOOP;  --End of po_sec_ov_loop while loop

EXCEPTION

WHEN OTHERS THEN
            RAISE;
END admp_vtac_load_tert_edu;  -- End of Load ter edu details


END IGS_AD_GRD_DATA_LOAD;

/
