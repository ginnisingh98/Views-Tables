--------------------------------------------------------
--  DDL for Package Body IGS_GE_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_GEN_002" AS
/* $Header: IGSGE02B.pls 120.3 2006/01/25 09:13:08 skpandey ship $ */

-------------------------------------------------------------------------------------------
--  Change History
--  Who        When           What
--  pkpatel   27-MAR-2003     Bug 2261717
--  						  Tuned genp_get_mail_addr, genp_get_pdv_name, genp_get_prsn_names procedures
--  asbala    29-DEC-2003     Bug 3330997. 10GCERT
--  ssawhney                  4257183 igs_pe_person usage changed to igs_pe_person_base_v.
--                            Perf tuned genp_get_person_name,genp_get_prsn_email,genp_get_prsn_names
--------------------------------------------------------------------------------------------

FUNCTION GENP_GET_DELIMIT_STR(
  p_input_str IN VARCHAR2 ,
  p_element_num IN NUMBER ,
  p_delimiter IN VARCHAR2 DEFAULT ',')
RETURN VARCHAR2 AS
    gv_other_detail     VARCHAR2(255);
BEGIN   -- genp_get_delemit_str
    -- Parse the p_input_str, return the p_element_num_th
    -- of the string delimited by p_delimiter.
DECLARE
    v_ret_val       VARCHAR2(1000);
    v_start_position    NUMBER(5);
    v_end_position      NUMBER(5);
BEGIN
    -- Validate input parameter
    IF (p_input_str IS NULL OR p_element_num IS NULL) THEN
        RETURN NULL;
    END IF;
    IF (p_element_num = 1) THEN
        v_start_position := 1;
    ELSE
        v_start_position := INSTR(p_input_str, p_delimiter, 1,
                        p_element_num - 1) + 1;
    END IF;
    v_end_position := INSTR(p_input_str, p_delimiter, 1, p_element_num) - 1;
    IF (v_end_position = -1) THEN
        IF (v_start_position <>1) THEN
            -- The last element in the string
            v_end_position := LENGTH(p_input_str);
        ELSE
            -- There not exists this element in the string
            RETURN NULL;
        END IF;
    END IF;
    v_ret_val := SUBSTR(p_input_str, v_start_position, v_end_position - v_start_position + 1);
    RETURN v_ret_val;
END;
END genp_get_delimit_str;


FUNCTION genp_get_initials(
  p_given_names IN VARCHAR2 )
RETURN VARCHAR2 AS
    FUNCTION skip_spaces (
        p_length_str            IN NUMBER,
        p_trimmed_string        IN VARCHAR2,
        p_current_pos           IN NUMBER)
    RETURN NUMBER AS
        v_non_space_current_pos     NUMBER;
        v_letter_current_pos        NUMBER;
        v_other_detail          VARCHAR2(255);
    BEGIN
        -- if the current position of the string is filled (ie.
        -- a letter of the input names, continue looking until
        -- we find a space
        v_non_space_current_pos := p_current_pos;
        while SUBSTR(p_trimmed_string, v_non_space_current_pos, 1) <>' '
        LOOP
            v_non_space_current_pos := v_non_space_current_pos + 1;
        END LOOP;
        v_letter_current_pos := v_non_space_current_pos;
        -- if a space is found, continue until we find a letter
        while SUBSTR(p_trimmed_string, v_letter_current_pos, 1) = ' '
        LOOP
            v_letter_current_pos := v_letter_current_pos + 1;
        END LOOP;
        -- return the position of the letter found
        RETURN v_letter_current_pos;
    END skip_spaces;
BEGIN
DECLARE
    v_trimmed_string    VARCHAR2(255);
    v_string_length     NUMBER;
    v_first_letter      CHAR;
    v_returned_position NUMBER;
    v_current_position  NUMBER;
    v_next_letter       CHAR;
    v_other_detail      VARCHAR2(255);
    v_final_output      VARCHAR2(100);
BEGIN
    -- removes the leading spaces from the initial string
    v_trimmed_string := UPPER(LTRIM(p_given_names));
    -- find out the number of characters in the names
    -- entered
    v_string_length := LENGTH(v_trimmed_string);
    -- find out the letter of the first name
    v_first_letter := SUBSTR(v_trimmed_string, 1, 1);
    v_final_output := v_first_letter;
    -- the current position that we are pointing to
    -- in the string of names
    v_current_position := 1;
    -- continue until all letters of the string have
    -- been accounted for
    WHILE (v_current_position <= v_string_length)
    LOOP
        -- this call returned_position which returns the
        -- position of the next space in the the string
        v_returned_position := skip_spaces(
                    v_string_length,
                    v_trimmed_string,
                    v_current_position);
        -- this find the next letter after the space
        v_next_letter := SUBSTR(v_trimmed_string, v_returned_position, 1);
        -- this concatenates the initial to v_final_output
        v_final_output := v_final_output || v_next_letter;
        -- set the current position to the position returned from
        -- skip_spaces, so the position is now at the next non-space
        v_current_position := v_returned_position;
    END LOOP;
    RETURN v_final_output;
END;
END genp_get_initials;


FUNCTION genp_get_mail_addr(
  p_person_id  NUMBER ,
  p_org_unit_cd  VARCHAR2 ,
  p_institution_cd  VARCHAR2 ,
  p_location_cd  VARCHAR2 ,
  p_addr_type  VARCHAR2 ,
  p_case_type  VARCHAR2 DEFAULT 'UPPER',
  p_phone_no  VARCHAR2 DEFAULT 'Y',
  p_name_style  VARCHAR2 DEFAULT 'CONTEXT',
  p_inc_addr  VARCHAR2 DEFAULT 'Y')
RETURN VARCHAR2 AS
-------------------------------------------------------------------------------------------
--  Change History
--  Who        When           What
--  pkpatel   27-MAR-2003     Bug 2261717
--  						  Removed the initial_last_name from igs_pe_person_v and write specific cursor to find the value.
--  masehgal   05-June-2002   # 2382471    Added Country,State and Zip Code to Address in the
--                            local function genp_get_per_addr
--
--------------------------------------------------------------------------------------------
    v_line_1    VARCHAR2(256)  := NULL; -- first line of address
    v_line_2    VARCHAR2(256)  := NULL; -- second line of address
    v_line_3    VARCHAR2(256)  := NULL; -- third line of address
    v_line_4    VARCHAR2(256)  := NULL; -- 4th line of address
    v_line_5    VARCHAR2(256)  := NULL; -- 5th line of address
    v_addr      VARCHAR2(2000) := NULL; -- final address variable
    v_phone     VARCHAR2(100)  := NULL; -- placeholder for phone handling
    v_name      VARCHAR2(256)  := NULL; -- IGS_PE_PERSON name placeholder
-- # 2382471   Added for Country,State and Zip Code
        v_state         VARCHAR2(256)  := NULL; -- State
    v_postal_code   VARCHAR2(256)  := NULL; -- ZIP CODE
    v_country_desc  VARCHAR2(256)  := NULL; -- Country

    gv_other_detail VARCHAR2(1000) := NULL; -- global for error trapping
    -- Local IGS_GE_EXCEPTIONS
    e_addr      EXCEPTION; -- overall exception for trapping and handling errors
    e_case_error    EXCEPTION; -- case type error
    --
    -- Local Functions
    -------------------------------------------------------------------------------
    -- Module:  genp_get_per_addr
    -- Purpose: Function for returning formatted IGS_PE_PERSON names and addresses
    --      based on variations of the parameters passed
    -- Notes:
    -- p_surname_first is a boolean to place the surname before the given name
    --  TRUE formats in surname + , + IGS_PE_TITLE + given name
    --  FALSE formats in IGS_PE_TITLE + given name + surname
    --
    -- p_phone_no is used to toggle the display of the phone number
    --  Y populates the p_phone_line parameter with the phone number
    --  N populates the p_phone_line parameter with a null value
    -- Exception Handlers
    -- e_name_error: returns false and populates the p_name variable with
    -- 'IGS_PE_PERSON name not found'
    -- e_addr_error: returns false and populates p_line_1 with
    -- 'No address record found'
    --
    -- Module History
   -------------------------------------------------------------------------------
    FUNCTION genp_get_per_addr(
        p_per_id        NUMBER,
        p_adr_type      VARCHAR2,
        p_phone_num     VARCHAR2,
        p_name_style        VARCHAR2,
        p_name      OUT NOCOPY  VARCHAR2,
        p_line_1    OUT NOCOPY  VARCHAR2,
        p_line_2    OUT NOCOPY  VARCHAR2,
        p_line_3    OUT NOCOPY  VARCHAR2,
        p_line_4    OUT NOCOPY  VARCHAR2,
        p_line_5    OUT NOCOPY  VARCHAR2,
        p_phone_line    OUT NOCOPY  VARCHAR2,
--  # 2382471   Added for Country,State and Zip Code
        p_state         OUT NOCOPY     VARCHAR2,
        p_postal_code   OUT NOCOPY     VARCHAR2,
        p_country_desc  OUT NOCOPY     VARCHAR2)
    RETURN BOOLEAN    AS

    BEGIN
    DECLARE
        -- Local Cursors
        -- cursor for selection of the IGS_PE_PERSON name in seperate parts to allow
        -- construction based on the user preferences
--skpandey, Bug#4937960: Changed c_per_name cursor definition to optimize query
	CURSOR c_per_name (cp_person_id NUMBER)IS
	    SELECT p.PERSON_TITLE    per_title,
	           p.PERSON_LAST_NAME per_surname,
		   NVL(P.KNOWN_AS,p.PERSON_FIRST_NAME) per_first_name,
		   NVL(P.KNOWN_AS, SUBSTR (P.PERSON_FIRST_NAME, 1, DECODE(INSTR(P.PERSON_FIRST_NAME, ' '), 0, LENGTH(P.PERSON_FIRST_NAME), (INSTR(P.PERSON_FIRST_NAME, ' ')-1)))) || ' ' || P.PERSON_LAST_NAME  per_preferred_name ,
		   P.PERSON_TITLE || ' ' || p.PERSON_FIRST_NAME || ' ' || P.PERSON_LAST_NAME       per_title_name ,
		   p.PERSON_LAST_NAME || ',  ' || p.PERSON_TITLE || '  ' || NVL(p.KNOWN_AS,p.PERSON_FIRST_NAME)  per_context_block_name
	    FROM   hz_parties p
	    WHERE  p.party_id   =  cp_person_id;



        -- cursor for selection of the IGS_PE_PERSON address when
        -- only the person_id is supplied
	-- ssawhney, changing to hz_parties, as co=Y record is checked.

        CURSOR c_pa(
            cp_person_id NUMBER)IS
            SELECT padv.party_id      padv_person_id,
		hpsu.site_use_type  padv_addr_type,
		padv.address1    padv_addr_line_1,
                padv.address2    padv_addr_line_2,
                padv.address3    padv_addr_line_3,
                padv.address4    padv_addr_line_4,
                padv.city       padv_city,
--  # 2382471   Added for Country ,State and Zip Code
                padv.state              padv_state,
                padv.postal_code        padv_postal_code,
		fnd.TERRITORY_SHORT_NAME padv_country_desc
            FROM
	            hz_parties    padv,
		    hz_party_sites hps,
		    hz_party_site_uses hpsu,
		    fnd_territories_vl fnd
            WHERE   padv.party_id  =   cp_person_id AND
	            padv.party_type = 'PERSON' AND
		    padv.country = fnd.territory_code AND
		    hps.party_id = padv.party_id AND
		    hps.identifying_address_flag ='Y' AND
		    hps.party_site_id = hpsu.party_site_id (+)  ;

		--padv.correspondence_ind = 'Y';

        -- cursor for selection of the IGS_PE_PERSON address when
        -- only the person_id and IGS_CO_ADDR_TYPE is supplied
        CURSOR c_pat(
            cp_person_id NUMBER,
            cp_addr_type VARCHAR2)IS
            SELECT  padv.person_id      padv_person_id,
                padv.addr_type      padv_addr_type,
                padv.addr_line_1    padv_addr_line_1,
                padv.addr_line_2    padv_addr_line_2,
                padv.addr_line_3    padv_addr_line_3,
                padv.addr_line_4    padv_addr_line_4,
                padv.city       padv_city,
--   # 2382471   Added for Country ,State and Zip Code
                padv.state              padv_state,
                padv.postal_code        padv_postal_code,
                padv.country_desc       padv_country_desc
            FROM    IGS_PE_PERSON_ADDR_V    padv
            WHERE   padv.person_id      = cp_person_id AND
                padv.addr_type      = cp_addr_type;

        CURSOR initial_name_cur(cp_person_id hz_parties.party_id%TYPE) IS
		SELECT SUBSTR(igs_ge_gen_002.genp_get_initials(person_first_name), 1, 10) || ' ' || person_last_name
        FROM   hz_parties
		WHERE  party_id = cp_person_id;


        CURSOR initial_last_name_cur(cp_person_id hz_parties.party_id%TYPE) IS
		SELECT RTRIM(DECODE(person_last_name,null,'',DECODE(person_first_name,null,person_last_name,person_last_name
                             || ', ' ) ) || NVL(person_first_name,'')|| ' '||person_middle_name,' ')
        FROM   hz_parties
		WHERE  party_id = cp_person_id;

        v_name  VARCHAR2(256)   := NULL;
        v_line_1    VARCHAR2(256)   := NULL;

        e_name_error    EXCEPTION; -- IGS_PE_PERSON name exception handler
        e_addr_error    EXCEPTION; -- IGS_PE_PERSON address exception handler

    BEGIN
        -- test for open cursor, then loop and select the persons name
        IF (c_per_name%ISOPEN) THEN
            CLOSE c_per_name;
        END IF;
        FOR c_per_rec IN c_per_name(p_per_id)LOOP

            IF p_name_style = 'PREFER' THEN
                v_name := c_per_rec.per_title || ' ' ||
                        c_per_rec.per_preferred_name;
            ELSIF p_name_style = 'TITLE' THEN
                v_name := c_per_rec.per_title_name;
            ELSIF p_name_style = 'INIT_F' THEN

                  OPEN initial_name_cur(p_per_id);
                  FETCH initial_name_cur INTO v_name;
                  CLOSE initial_name_cur;

            ELSIF p_name_style = 'INIT_L' THEN

                  OPEN initial_last_name_cur(p_per_id);
                  FETCH initial_last_name_cur INTO v_name;
                  CLOSE initial_last_name_cur;

            ELSIF p_name_style = 'CONTEXT' THEN
                   v_name := c_per_rec.per_context_block_name;
            ELSIF p_name_style = 'SALUTAT' THEN

				   v_name := c_per_rec.per_title || ' ' || c_per_rec.per_surname;

            ELSE
                v_name := c_per_rec.per_context_block_name;
            END IF; -- IF p_name_style

                -- Determin if p_addr_type is passed and open correct cursor
            IF p_adr_type IS NULL THEN
                FOR c_pa_rec IN c_pa(p_per_id) LOOP
                        v_line_1 := c_pa_rec.padv_addr_line_1;
                        p_line_2 := c_pa_rec.padv_addr_line_2;
                            p_line_3 := c_pa_rec.padv_addr_line_3;
                        p_line_4 := c_pa_rec.padv_addr_line_4;
                        p_line_5 := c_pa_rec.padv_city;
--   # 2382471   Added for Country ,State and Zip Code
                        p_state        := c_pa_rec.padv_state;
                        p_postal_code  := c_pa_rec.padv_postal_code;
                        p_country_desc := c_pa_rec.padv_country_desc ;
                    END LOOP;
            ELSE
                FOR c_pat_rec IN c_pat(p_per_id, p_adr_type) LOOP
                        v_line_1 := c_pat_rec.padv_addr_line_1;
                        p_line_2 := c_pat_rec.padv_addr_line_2;
                            p_line_3 := c_pat_rec.padv_addr_line_3;
                        p_line_4 := c_pat_rec.padv_addr_line_4;
                        p_line_5 := c_pat_rec.padv_city;
--   # 2382471   Added for Country ,State and Zip Code
                        p_state        := c_pat_rec.padv_state;
                        p_postal_code  := c_pat_rec.padv_postal_code;
                        p_country_desc := c_pat_rec.padv_country_desc ;
                    END LOOP;
            END IF;
        END LOOP;
        -- test if name has been selected
        IF v_name IS NULL THEN
            RAISE e_name_error;
        ELSE
            p_name := v_name;
        END IF;
        -- test if name has been selected
        IF v_line_1 IS NULL THEN
            RAISE e_addr_error;
        ELSE
            p_line_1 := v_line_1;
        END IF;
        RETURN TRUE;
    EXCEPTION
        WHEN e_name_error THEN
            p_name := 'Person name not found';
            RETURN FALSE;
        WHEN e_addr_error THEN
            p_line_1 := 'No Address Record Found';
            RETURN TRUE;
        WHEN OTHERS THEN
            APP_EXCEPTION.RAISE_EXCEPTION ;
    END;
    EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
            RETURN FALSE;
    END genp_get_per_addr;
    -------------------------------------------------------------------------------
    -- Module:  genp_get_org_addr
    -- Purpose: Function for returning formatted IGS_OR_UNIT names and addresses
    --      based on variations of the parameters passed
    -- Notes:
    -- p_phone_no is used to toggle the display of the phone number
    --  Y populates the p_phone_line parameter with the phone number
    --  N populates the p_phone_line parameter with a null value
    -- Exception Handlers
    -- e_name_error: returns false and populates the p_name variable with
    -- 'Org IGS_PS_UNIT not found'
    -- e_addr_error: returns false and populates p_line_1 with
    -- 'No address record found'
    --
    -- Module History
    -------------------------------------------------------------------------------
    -- 03/03/1998 MSONTER Intial creation of Module
    -- 05/03/1998 MSONTER Modified cursor c_org_name to search
    -- IGS_CO_ADDR_TYPE.IGS_CO_TYPE = 'Y'
    -- 18/03/1998 YSWONG Modified code according to PLSQL-CODING standards
    -------------------------------------------------------------------------------
    FUNCTION genp_get_org_addr(
        p_org_unit_cd       VARCHAR2,
        p_addr_type     VARCHAR2,
        p_phone_no      VARCHAR2,
        p_name      OUT NOCOPY  VARCHAR2,
        p_line_1    OUT NOCOPY  VARCHAR2,
        p_line_2    OUT NOCOPY  VARCHAR2,
        p_line_3    OUT NOCOPY  VARCHAR2,
        p_line_4    OUT NOCOPY  VARCHAR2,
        p_line_5    OUT NOCOPY  VARCHAR2,
        p_phone_line    OUT NOCOPY  VARCHAR2)
    RETURN BOOLEAN
    AS
        -- cursor for selection of the IGS_OR_UNIT name
        CURSOR c_org_name (
            cp_org_unit_cd VARCHAR2)IS
            SELECT ou.description   ou_description
            FROM    IGS_OR_UNIT ou
            WHERE   ou.org_unit_cd  =   cp_org_unit_cd;
        -- cursor for selection of the IGS_OR_UNIT address when
        -- only the org_unit_cd is supplied
        CURSOR c_ou(
            cp_org_unit_cd VARCHAR2)IS
            SELECT  oadv.org_unit_cd    oadv_org_unit_cd,
                oadv.addr_type      oadv_addr_type,
                oadv.addr_line_1    oadv_addr_line_1,
                oadv.addr_line_2    oadv_addr_line_2,
                oadv.addr_line_3    oadv_addr_line_3,
                oadv.addr_line_4    oadv_addr_line_4,
                oadv.city       oadv_city
            FROM    IGS_OR_ADDR oadv
            WHERE   oadv.org_unit_cd    =   cp_org_unit_cd AND
                oadv.correspondence_ind =   'Y';

        -- cursor for selection of the IGS_OR_UNIT address when
        -- only the org_unit_cd and IGS_CO_ADDR_TYPE is supplied
        CURSOR c_out(
            cp_org_unit_cd VARCHAR2,
            cp_addr_type VARCHAR2) IS
            SELECT  oadv.org_unit_cd    oadv_org_unit_cd,
                oadv.addr_type      oadv_addr_type,
                oadv.addr_line_1    oadv_addr_line_1,
                oadv.addr_line_2    oadv_addr_line_2,
                oadv.addr_line_3    oadv_addr_line_3,
                oadv.addr_line_4    oadv_addr_line_4,
                oadv.city       oadv_city
            FROM    IGS_OR_ADDR oadv
            WHERE   oadv.org_unit_cd    =   cp_org_unit_cd AND
                oadv.addr_type      =   cp_addr_type;

        -- Local Variables
        v_name      VARCHAR2(256)   := NULL;
        v_line_1    VARCHAR2(256)   := NULL;
        -- Local IGS_GE_EXCEPTIONS
        e_name_error    EXCEPTION; -- IGS_OR_UNIT name exception handler
        e_addr_error    EXCEPTION; -- IGS_OR_UNIT address exception handler
    BEGIN
        -- test for open cursor, then loop and select the persons name
        IF c_org_name%ISOPEN THEN
            CLOSE c_org_name;
        END IF;
        FOR c_org_rec IN c_org_name(
                    p_org_unit_cd) LOOP
            v_name := c_org_rec.ou_description;
            -- Determin if p_addr_type is passed and open correct cursor
                IF p_addr_type IS NULL THEN
                FOR c_ou_rec IN c_ou(
                        p_org_unit_cd) LOOP
                        v_line_1 := c_ou_rec.oadv_addr_line_1;
                        p_line_2 := c_ou_rec.oadv_addr_line_2;
                            p_line_3 := c_ou_rec.oadv_addr_line_3;
                        p_line_4 := c_ou_rec.oadv_addr_line_4;
                        p_line_5 := c_ou_rec.oadv_city;
                END LOOP; -- FOR c_ou_rec IN c_ou(p_org_unit_cd)
                ELSE
                FOR c_out_rec IN c_out(
                            p_org_unit_cd,
                            p_addr_type) LOOP
                        v_line_1 := c_out_rec.oadv_addr_line_1;
                        p_line_2 := c_out_rec.oadv_addr_line_2;
                            p_line_3 := c_out_rec.oadv_addr_line_3;
                        p_line_4 := c_out_rec.oadv_addr_line_4;
                        p_line_5 := c_out_rec.oadv_city;
                END LOOP; --
                END IF;
        END LOOP;
        -- test if name has been selected
        IF v_name IS NULL THEN
            RAISE e_name_error;
        ELSE
            p_name := v_name;
        END IF;
        -- test if name has been selected
        IF v_line_1 IS NULL THEN
            RAISE e_addr_error;
        ELSE
            p_line_1 := v_line_1;
        END IF;
        RETURN TRUE;
    EXCEPTION
        WHEN e_name_error THEN
            p_name := 'Org Unit not found';
            RETURN FALSE;
        WHEN e_addr_error THEN
            p_line_1 := 'No Address Record Found';
            RETURN TRUE;
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception ;
    END genp_get_org_addr;
    -------------------------------------------------------------------------------
    -- Module:  genp_get_loc_addr
    -- Purpose: Function for returning formatted IGS_AD_LOCATION names and addresses
    --      based on variations of the parameters passed
    -- Notes:
    -- p_phone_no is used to toggle the display of the phone number
    --  Y populates the p_phone_line parameter with the phone number
    --  N populates the p_phone_line parameter with a null value
    -- Exception Handlers
    -- e_name_error: returns false and populates the p_name variable with
    -- 'IGS_AD_LOCATION not found'
    -- e_addr_error: returns false and populates p_line_1 with
    -- 'No address record found'
    -- Module History
    -------------------------------------------------------------------------------
    -- 04/03/1998 MSONTER Intial creation of Module
    -- 05/03/1998 MSONTER Modified cursor c_loc_name to search
    -- IGS_CO_ADDR_TYPE.IGS_CO_TYPE = 'Y'
    -- 18/03/1998 YSWONG Modified code according to PLSQL-CODING standards
    -------------------------------------------------------------------------------
    FUNCTION genp_get_loc_addr(
        p_location_cd       VARCHAR2,
        p_addr_type     VARCHAR2,
        p_phone_no      VARCHAR2,
        p_name      OUT NOCOPY  VARCHAR2,
        p_line_1    OUT NOCOPY  VARCHAR2,
        p_line_2    OUT NOCOPY  VARCHAR2,
        p_line_3    OUT NOCOPY  VARCHAR2,
        p_line_4    OUT NOCOPY  VARCHAR2,
        p_line_5    OUT NOCOPY  VARCHAR2,
        p_phone_line    OUT NOCOPY  VARCHAR2)
    RETURN BOOLEAN
    AS
        -- cursor for selection of the IGS_AD_LOCATION name
        CURSOR c_loc_name (
            cp_location_cd VARCHAR2)IS
            SELECT loc.description  loc_description
            FROM    IGS_AD_LOCATION loc
            WHERE   loc.location_cd =   cp_location_cd;
        -- cursor for selection of the IGS_AD_LOCATION address when
        -- only the loc_unit_cd is supplied
        -- skpandey, Bug#3687111, Changed definition of cursor c_loc to optimize query
	CURSOR c_loc(
            cp_location_cd VARCHAR2)IS
	    SELECT
		 LA.LOCATION_VENUE_CD  ladv_location_cd,
		 HL.ADDRESS1 ladv_addr_line_1,
		 HL.ADDRESS2 ladv_addr_line_2,
		 HL.ADDRESS3 ladv_addr_line_3,
		 HL.ADDRESS4 ladv_addr_line_4,
		 HL.CITY ladv_city
		 FROM
		 HZ_LOCATIONS HL,
		 IGS_AD_LOCVENUE_ADDR LA
		 WHERE
		 HL.LOCATION_ID = LA.LOCATION_ID
		 AND LA.SOURCE_TYPE = 'L'
		 AND LA.LOCATION_VENUE_CD = cp_location_cd
		 AND LA.IDENTIFYING_ADDRESS_FLAG =  'Y' ;

        -- cursor for selection of the IGS_AD_LOCATION address when
        -- only the location_cd and IGS_CO_ADDR_TYPE is supplied
        -- skpandey, Bug#3687111, Changed definition of cursor c_loct to optimize query
	CURSOR c_loct(
            cp_location_cd VARCHAR2,
            cp_addr_type VARCHAR2)IS
		SELECT
		LA.LOCATION_VENUE_CD  ladv_location_cd,
		HL.ADDRESS1 ladv_addr_line_1,
		HL.ADDRESS2 ladv_addr_line_2,
		HL.ADDRESS3 ladv_addr_line_3,
		HL.ADDRESS4 ladv_addr_line_4,
		HL.CITY ladv_city
		FROM
		HZ_LOCATIONS HL,
		IGS_AD_LOCVENUE_ADDR LA ,
		IGS_PE_LOCVENUE_USE PLU
		WHERE
		HL.LOCATION_ID = LA.LOCATION_ID
		AND LA.LOCATION_VENUE_ADDR_ID = PLU.LOC_VENUE_ADDR_ID
	        AND LA.SOURCE_TYPE = 'L'
		AND LA.LOCATION_VENUE_CD = cp_location_cd
		AND PLU.SITE_USE_CODE    =   cp_addr_type;

        -- Local Variables
        v_name      VARCHAR2(256)   := NULL;
        v_line_1    VARCHAR2(256)   := NULL;
        -- Local IGS_GE_EXCEPTIONS
        e_name_error    EXCEPTION; -- locationt name exception handler
        e_addr_error    EXCEPTION; -- IGS_AD_LOCATION address exception handler
    BEGIN
        -- test for open cursor, then loop and select the persons name
        IF c_loc_name%ISOPEN THEN
            CLOSE c_loc_name;
        END IF;
        FOR c_loc_rec IN c_loc_name(
                    p_location_cd) LOOP
            v_name := c_loc_rec.loc_description;
                -- Determin if p_addr_type is passed and open correct cursor
            IF p_addr_type IS NULL THEN
                FOR c_loc_rec IN c_loc(
                        p_location_cd)LOOP
                        v_line_1 := c_loc_rec.ladv_addr_line_1;
                        p_line_2 := c_loc_rec.ladv_addr_line_2;
                            p_line_3 := c_loc_rec.ladv_addr_line_3;
                        p_line_4 := c_loc_rec.ladv_addr_line_4;
                        p_line_5 := c_loc_rec.ladv_city;
                END LOOP;
                ELSE
                FOR c_loct_rec IN c_loct(
                            p_location_cd,
                            p_addr_type)LOOP
                        v_line_1 := c_loct_rec.ladv_addr_line_1;
                        p_line_2 := c_loct_rec.ladv_addr_line_2;
                            p_line_3 := c_loct_rec.ladv_addr_line_3;
                        p_line_4 := c_loct_rec.ladv_addr_line_4;
                        p_line_5 := c_loct_rec.ladv_city;
                END LOOP;
                END IF;
        END LOOP;
        -- test if name has been selected
        IF v_name IS NULL THEN
            RAISE e_name_error;
        ELSE
            p_name := v_name;
        END IF;
        -- test if name has been selected
        IF v_line_1 IS NULL THEN
            RAISE e_addr_error;
        ELSE
            p_line_1 := v_line_1;
        END IF;
        RETURN TRUE;
    EXCEPTION
        WHEN e_name_error THEN
            p_name := 'Location Code not found';
            RETURN FALSE;
        WHEN e_addr_error THEN
            p_line_1 := 'No Address Record Found';
            RETURN TRUE;
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception ;
    END genp_get_loc_addr;
    -------------------------------------------------------------------------------
    -- Module:  genp_get_inst_addr
    -- Purpose: Function for returning formatted IGS_OR_INSTITUTION names and addresses
    --      based on variations of the parameters passed
    -- Notes:
    -- p_phone_no is used to toggle the display of the phone number
    --  Y populates the p_phone_line parameter with the phone number
    --  N populates the p_phone_line parameter with a null value
    -- Exception Handlers
    -- e_name_error: returns false and populates the p_name variable with
    -- 'IGS_OR_INSTITUTION not found'
    -- e_addr_error: returns false and populates p_line_1 with
    -- 'No address record found'
    --
    -- Module History
    ----------------------------------------------------------------------
    -- 04/03/1998 MSONTER Intial creation of Module
    -- 05/03/1998 MSONTER Modified cursor c_inst_name to search
    -- IGS_CO_ADDR_TYPE.IGS_CO_TYPE = 'Y'
    -- 18/03/1998 YSWONG Modified code according to PLSQL-CODING standards
    -- 19/03/1998 MSONTER Moved to local function of genp_get_addr
    -------------------------------------------------------------------------------
    FUNCTION genp_get_inst_addr(
        p_institution_cd    VARCHAR2,
        p_addr_type     VARCHAR2,
        p_phone_no      VARCHAR2,
        p_name      OUT NOCOPY  VARCHAR2,
        p_line_1    OUT NOCOPY  VARCHAR2,
        p_line_2    OUT NOCOPY  VARCHAR2,
        p_line_3    OUT NOCOPY  VARCHAR2,
        p_line_4    OUT NOCOPY  VARCHAR2,
        p_line_5    OUT NOCOPY  VARCHAR2,
        p_phone_line    OUT NOCOPY  VARCHAR2)
    RETURN BOOLEAN
    AS
        -- cursor for selection of the IGS_OR_INSTITUTION name
        CURSOR c_inst_name (
            cp_institution_cd VARCHAR2)IS
            SELECT  inst.name   inst_name
            FROM    IGS_OR_INSTITUTION  inst
            WHERE   inst.institution_cd =   cp_institution_cd;
        -- cursor for selection of the IGS_OR_INSTITUTION address when
        -- only the loc_unit_cd is supplied
        CURSOR c_ins(
            cp_institution_cd VARCHAR2)IS
            SELECT  iadv.institution_cd iadv_institution_cd,
                iadv.addr_type  iadv_addr_type,
                iadv.addr_line_1    iadv_addr_line_1,
                iadv.addr_line_2    iadv_addr_line_2,
                iadv.addr_line_3    iadv_addr_line_3,
                iadv.addr_line_4    iadv_addr_line_4,
                iadv.city       iadv_city
            FROM    IGS_OR_INST_ADDR    iadv
            WHERE   iadv.institution_cd =   cp_institution_cd AND
                iadv.correspondence_ind =   'Y';

        -- cursor for selection of the IGS_OR_INSTITUTION address when
        -- only the institution_cd and IGS_CO_ADDR_TYPE is supplied
        CURSOR c_inst(
            cp_institution_cd VARCHAR2,
            cp_addr_type VARCHAR2)IS
            SELECT  iadv.institution_cd iadv_institution_cd,
                iadv.addr_type  iadv_addr_type,
                iadv.addr_line_1    iadv_addr_line_1,
                iadv.addr_line_2    iadv_addr_line_2,
                iadv.addr_line_3    iadv_addr_line_3,
                iadv.addr_line_4    iadv_addr_line_4,
                iadv.city       iadv_city
            FROM    IGS_OR_INST_ADDR    iadv
            WHERE   iadv.institution_cd =   cp_institution_cd AND
                iadv.addr_type      =   cp_addr_type;

        -- Local Variables
        v_name      VARCHAR2(256)   := NULL;
        v_line_1    VARCHAR2(256)   := NULL;
        -- Local IGS_GE_EXCEPTIONS
        e_name_error    EXCEPTION; -- institutiont name exception handler
        e_addr_error    EXCEPTION; -- IGS_OR_INSTITUTION address exception handler
    BEGIN
        -- test for open cursor, then loop and select the persons name
        IF c_inst_name%ISOPEN THEN
                CLOSE c_inst_name;
        END IF;
        FOR c_instit_rec IN c_inst_name(
                    p_institution_cd) LOOP
            v_name := c_instit_rec.inst_name;
            -- Determin if p_addr_type is passed and open correct cursor
            IF p_addr_type IS NULL THEN
                FOR c_ins_rec IN c_ins(
                            p_institution_cd) LOOP
                        v_line_1 := c_ins_rec.iadv_addr_line_1;
                        p_line_2 := c_ins_rec.iadv_addr_line_2;
                            p_line_3 := c_ins_rec.iadv_addr_line_3;
                        p_line_4 := c_ins_rec.iadv_addr_line_4;
                        p_line_5 := c_ins_rec.iadv_city;
                END LOOP;
                ELSE
                FOR c_inst_rec IN c_inst(
                            p_institution_cd,
                            p_addr_type)LOOP
                        v_line_1 := c_inst_rec.iadv_addr_line_1;
                        p_line_2 := c_inst_rec.iadv_addr_line_2;
                            p_line_3 := c_inst_rec.iadv_addr_line_3;
                        p_line_4 := c_inst_rec.iadv_addr_line_4;
                        p_line_5 := c_inst_rec.iadv_city;
                END LOOP;
                END IF;
        END LOOP;
        -- test if name has been selected
        IF v_name IS NULL THEN
            RAISE e_name_error;
        ELSE
            p_name := v_name;
        END IF;
        -- test if name has been selected
        IF v_line_1 IS NULL THEN
            RAISE e_addr_error;
        ELSE
            p_line_1 := v_line_1;
        END IF;
        RETURN TRUE;
    EXCEPTION
        WHEN e_name_error THEN
            p_name := 'institution Code not found';
            RETURN FALSE;
        WHEN e_addr_error THEN
            p_line_1 := 'No Address Record Found';
            RETURN TRUE;
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception ;
    END genp_get_inst_addr;
BEGIN
    IF (p_person_id      IS NOT NULL AND
        p_org_unit_cd    IS NULL AND
        p_institution_cd IS NULL AND
        p_location_cd    IS NULL) THEN
        IF NOT genp_get_per_addr(
                p_person_id,
                p_addr_type,
                p_phone_no,
                p_name_style,
                v_name,
                v_line_1,
                v_line_2,
                v_line_3,
                v_line_4,
                v_line_5,
                v_phone,
--  # 2382471   Added for Country ,State and Zip Code
                                v_state,
                v_postal_code,
                v_country_desc) THEN
            RAISE e_addr;
            END IF;
    ELSIF  (p_person_id      IS NULL     AND
        p_org_unit_cd    IS NOT NULL AND
        p_institution_cd IS NULL     AND
        p_location_cd    IS NULL) THEN
        IF NOT genp_get_org_addr(
                p_org_unit_cd,
                p_addr_type,
                p_phone_no,
                v_name,
                v_line_1,
                v_line_2,
                v_line_3,
                v_line_4,
                v_line_5,
                v_phone) THEN
            RAISE e_addr;
        END IF;
    ELSIF ( p_person_id      IS NULL     AND
        p_org_unit_cd    IS NULL     AND
        p_institution_cd IS NOT NULL AND
        p_location_cd    IS NULL) THEN
        IF NOT genp_get_inst_addr(
                p_institution_cd,
                p_addr_type,
                p_phone_no,
                v_name,
                v_line_1,
                v_line_2,
                v_line_3,
                v_line_4,
                v_line_5,
                v_phone) THEN
            RAISE e_addr;
        END IF;
    ELSIF ( p_person_id      IS NULL     AND
        p_org_unit_cd    IS NULL     AND
        p_institution_cd IS NULL     AND
        p_location_cd    IS NOT NULL) THEN
        IF NOT genp_get_loc_addr(
                p_location_cd,
                p_addr_type,
                p_phone_no,
                v_name,
                v_line_1,
                v_line_2,
                v_line_3,
                v_line_4,
                v_line_5,
                v_phone) THEN
             RAISE e_addr;
        END IF;
    ELSE
        RAISE e_addr;
    END IF;
    -- Assemble the address based on the variables passed
    v_addr := v_name;
    -- use p_phone_no to append phone number
    IF p_phone_no = 'Y' THEN
        IF v_phone IS NOT NULL THEN
            v_addr := v_addr || ' ('||v_phone||')';
        END IF;
    END IF;
    -- Use p_inc_addr to append address lnies that are not null
    IF p_inc_addr = 'Y' THEN
        IF v_line_1 IS NOT NULL THEN
            v_addr := v_addr || fnd_global.local_chr(10) || v_line_1;
        END IF;
        IF v_line_2 IS NOT NULL THEN
            v_addr := v_addr || fnd_global.local_chr(10) || v_line_2;
        END IF;
        IF v_line_3 IS NOT NULL THEN
            v_addr := v_addr || fnd_global.local_chr(10) || v_line_3;
        END IF;
        IF v_line_4 IS NOT NULL THEN
            v_addr := v_addr || fnd_global.local_chr(10) || v_line_4;
        END IF;
        IF v_line_5 IS NOT NULL THEN
            v_addr := v_addr || fnd_global.local_chr(10) || v_line_5;
        END IF;
--  # 2382471   Added for Country ,State and Zip Code
        IF v_state IS NOT NULL THEN
            v_addr := v_addr || fnd_global.local_chr(10) || v_state;
        END IF;
        IF v_country_desc IS NOT NULL THEN
            v_addr := v_addr || fnd_global.local_chr(10) || v_country_desc;
        END IF;
        IF v_postal_code IS NOT NULL THEN
            v_addr := v_addr || fnd_global.local_chr(10) || v_postal_code;
        END IF;

    END IF;
    -- Test if v_addr is null, if so then raise exception
    IF v_addr IS NULL THEN
        RAISE e_addr;
    END IF;
    -- format string based on p_case_type
    IF UPPER(p_case_type) = 'UPPER' THEN
        v_addr := UPPER(v_addr);
    ELSIF UPPER(p_case_type) = 'LOWER' THEN
        v_addr := LOWER(v_addr);
    ELSIF UPPER(p_case_type) = 'NORMAL' THEN
        v_addr := INITCAP(v_addr);
    ELSIF UPPER(p_case_type) = 'DEFAULT' THEN
        NULL;
    ELSE
        RAISE e_addr;
    END IF; -- IF UPPER(p_case_type)
    RETURN v_addr;
EXCEPTION
    WHEN e_addr THEN
        IF v_addr IS NULL THEN
            RETURN 'No Address record found';
        END IF;
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
        RETURN NULL;
END genp_get_mail_addr;

FUNCTION genp_get_nxt_prsn_id(
  p_person_id OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
    gv_other_detail     VARCHAR2(255);
BEGIN
-- Return next available IGS_PE_PERSON id value
DECLARE
    v_seq_num_str       VARCHAR(64);
    v_chk_digit     NUMBER(2);
    v_new_id            NUMBER(8);
    v_check         CHAR;
    cst_max_attemp      CONSTANT NUMBER := 5;
    v_is_right_length       BOOLEAN DEFAULT TRUE;
    v_id_generated      BOOLEAN DEFAULT FALSE;
    CURSOR c_get_nxt_seq_num IS
        SELECT  IGS_PE_PERSON_PE_ID_S.nextval
        FROM    DUAL;
--skpandey, Bug#4937960: Changed c_chk_id_exists cursor definition to optimize query
    CURSOR c_chk_id_exists (cp_person_id    IGS_PE_PERSON.person_id%TYPE) IS
        SELECT  'x'
        FROM    IGS_PE_PERSON_BASE_V
        WHERE   person_id = cp_person_id;
    FUNCTION genpl_calc_chk_digit (p_seq_num NUMBER)
    RETURN NUMBER
    AS
        v_chk_digit NUMBER(2);
        v_seq_num_str   VARCHAR2(7);
    BEGIN
        v_seq_num_str := TO_CHAR(p_seq_num);
        v_chk_digit :=  11 -
                (((SUBSTR(v_seq_num_str, 1, 1) * 64) +
                  (SUBSTR(v_seq_num_str, 2, 1) * 32) +
                  (SUBSTR(v_seq_num_str, 3, 1) * 16) +
                  (SUBSTR(v_seq_num_str, 4, 1) *  8) +
                  (SUBSTR(v_seq_num_str, 5, 1) *  4) +
                  (SUBSTR(v_seq_num_str, 6, 1) *  2) +
                  (SUBSTR(v_seq_num_str, 7, 1) *  1)) MOD 11);
        RETURN v_chk_digit;
    END genpl_calc_chk_digit;
BEGIN
    -- calculate the ID in 5 attempts
    FOR v_try_cnt IN 1 .. cst_max_attemp LOOP
        OPEN c_get_nxt_seq_num;
        FETCH c_get_nxt_seq_num INTO v_seq_num_str;
        IF (c_get_nxt_seq_num%NOTFOUND) THEN
            CLOSE c_get_nxt_seq_num;
            RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_get_nxt_seq_num;

        -- calculate the check digit
        v_chk_digit := genpl_calc_chk_digit(TO_NUMBER(v_seq_num_str));

    v_new_id := TO_NUMBER(v_seq_num_str);
    EXIT;

    END LOOP;

    -- check that id does not already exist in the IGS_PE_PERSON table
    OPEN c_chk_id_exists(v_new_id);
    FETCH c_chk_id_exists INTO v_check;
    IF (c_chk_id_exists%FOUND) THEN
        CLOSE c_chk_id_exists;
        p_message_name := 'IGS_GE_DUPLICATE_VALUE';
        RETURN FALSE;
    END IF;
    CLOSE c_chk_id_exists;
    -- New person_id is generated successfully
    p_message_name := null;
    p_person_id := v_new_id;
    RETURN TRUE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
END genp_get_nxt_prsn_id;



 FUNCTION genp_get_pdv_name(
  p_person_id IN NUMBER ,
  p_field_name IN VARCHAR2 )
RETURN VARCHAR2 AS
/*
WHO       WHEN          WHAT
pkpatel   27-MAR-2003   Bug 2261717
			Removed the initial_last_name from igs_pe_person_v and write specific cursor to find the value.
skpandey  13-JAN-2006   Bug#4937960: Changed c_person cursor definition to optimize query
*/
    -- This module returns the value of a field passed in as a parameter for a
    -- IGS_PE_PERSON.
    -- The use of this module will generally be in the order by clause for tables
    -- that retrieve person_id's but require them in an order, eg. surname
    -- order.
    -- Most common use will be the order by clause of a block on a form module.

    v_ret_val       VARCHAR2(255)   DEFAULT NULL;
    CURSOR  c_person(cp_person_id hz_parties.party_id%TYPE) IS
         SELECT  DECODE(
	 UPPER(p_field_name),
	'SURNAME',   p.PERSON_LAST_NAME ,
	'GIVEN_NAMES',    P.PERSON_FIRST_NAME ,
	'PREFERRED_GIVEN_NAME', P.KNOWN_AS ,
	'CONTEXT_BLOCK_NAME',  p.PERSON_LAST_NAME || ',  ' || p.PERSON_TITLE || '  ' || NVL(p.KNOWN_AS,p.PERSON_FIRST_NAME),
	 NULL)
	FROM   hz_parties p
	WHERE  p.party_id   =  cp_person_id;

   CURSOR initial_last_name_cur(cp_person_id hz_parties.party_id%TYPE) IS
		SELECT RTRIM(DECODE(person_last_name,null,'',DECODE(person_first_name,null,person_last_name,person_last_name
                             || ', ' ) ) || NVL(person_first_name,'')|| ' '||person_middle_name,' ')
        FROM   hz_parties
		WHERE  party_id = cp_person_id;


BEGIN
    IF p_field_name = 'INITIAL_LAST_NAME' THEN

      OPEN initial_last_name_cur(p_person_id);
      FETCH initial_last_name_cur INTO v_ret_val;
      CLOSE initial_last_name_cur;

	ELSE

      OPEN c_person(p_person_id);
      FETCH c_person INTO v_ret_val;
      CLOSE c_person;

    END IF;

    RETURN v_ret_val;

EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
END genp_get_pdv_name;


 FUNCTION genp_get_person_name(
  p_person_id IN NUMBER ,
  p_surname OUT NOCOPY VARCHAR2 ,
  p_given_names OUT NOCOPY VARCHAR2 ,
  p_title OUT NOCOPY VARCHAR2 ,
  p_oracle_username OUT NOCOPY VARCHAR2 ,
  p_preferred_given_name OUT NOCOPY VARCHAR2 ,
  p_full_name OUT NOCOPY VARCHAR2 ,
  p_preferred_name OUT NOCOPY VARCHAR2 ,
  p_title_name OUT NOCOPY VARCHAR2 ,
  p_initial_name OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )

/*---------------------------------------------------------------
  --Change History:
  --Who         When            What
  --ssawhney                   4257183 igs_pe_person usage changed to igs_pe_person_base_v.
  --                           return NULL/full_name for useless and obsolete fields like title_name,orc_user,initial_name etc.
  -------------------------------------------------------------------*/
RETURN BOOLEAN AS
BEGIN
DECLARE
    v_person_details    IGS_PE_PERSON_BASE_V%ROWTYPE;
    v_other_detail      VARCHAR(255);
    CURSOR  c_person_details IS
        SELECT  *
        FROM    IGS_PE_PERSON_BASE_V  -- IGS_PE_API_ALT_PERS_API_ID_V
        WHERE   person_id = p_person_id;
BEGIN
    OPEN    c_person_details;
    FETCH   c_person_details INTO v_person_details;
    IF (c_person_details%NOTFOUND) THEN
        CLOSE c_person_details;
        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN FALSE;
    ELSE
        CLOSE c_person_details;
        p_surname := v_person_details.last_name ;  --v_person_details.pe_surname;
        p_given_names := v_person_details.first_name ;  --v_person_details.pe_given_names;
        p_title := v_person_details.title;
        p_oracle_username := null ;  -- v_person_details.oracle_username; this should not be used
        p_preferred_given_name := v_person_details.known_as ; --preferred_given_name;
        p_full_name := v_person_details.full_name;
        p_preferred_name := v_person_details.full_name; --pe_preferred_name; --used only in tracking, hence changin
        p_title_name := v_person_details.full_name; --pe_title_name;
        p_initial_name :=v_person_details.full_name; --pe_initial_name;
        p_message_name := null;
        RETURN TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
END;
END genp_get_person_name;


FUNCTION genp_get_prsn_email(
  p_person_id IN NUMBER ,
  p_email_addr OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
BEGIN
DECLARE
    CURSOR c_email_addr IS
        SELECT  pdv. EMAIL_ADDRESS email_addr
        FROM     HZ_PARTIES pdv -- IGS_PE_PERSON_V pdv
        WHERE   pdv.party_id = p_person_id;
	--ssawhney use hz_parties instead of person_v, as single record needs to be returned
	--which can anyway be used from hz_parties.
    v_other_detail      VARCHAR2(255);
    v_email_addr        IGS_PE_PERSON_V.email_addr%TYPE;
BEGIN
    -- This module returns the selected IGS_PE_PERSON's
    -- email address
    -- select the IGS_PE_PERSON's details
    OPEN c_email_addr;
    FETCH c_email_addr INTO v_email_addr;
    -- if a record was found, return the
    -- email address selected
    IF (c_email_addr%FOUND) THEN
        CLOSE c_email_addr;
        -- set the IGS_PE_PERSON's email address to the
        -- value selected
        p_email_addr := v_email_addr;
        p_message_name := null ;
        RETURN TRUE;
    ELSE
        -- set the message number as this
        -- IGS_PE_PERSON doesn't exist
        CLOSE c_email_addr;
        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
END;
END genp_get_prsn_email;

FUNCTION genp_get_prsn_names(
  p_person_id IN NUMBER ,
  p_surname OUT NOCOPY VARCHAR2 ,
  p_given_names OUT NOCOPY VARCHAR2 ,
  p_title OUT NOCOPY VARCHAR2 ,
  p_oracle_username OUT NOCOPY VARCHAR2 ,
  p_preferred_given_name OUT NOCOPY VARCHAR2 ,
  p_full_name OUT NOCOPY VARCHAR2 ,
  p_preferred_name OUT NOCOPY VARCHAR2 ,
  p_title_name OUT NOCOPY VARCHAR2 ,
  p_initial_name OUT NOCOPY VARCHAR2 ,
  p_context_block_name OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
/*
WHO       WHEN          WHAT
pkpatel   27-MAR-2003   Bug 2261717
                        Filtered the query to be based only on IGS_PE_PERSON_V.
			Removed the initial_name and passed full_name for the OUT parameter.
ssawhney                4257183 igs_pe_person usage changed to igs_pe_person_base_v.
                        return NULL or exact view def for complex field derivations...avoid usage of person_v
  -------------------------------------------------------------------*/

    TYPE r_person_details IS RECORD (
        surname         IGS_PE_PERSON.surname%TYPE,
        given_names     IGS_PE_PERSON.given_names%TYPE,
        title           IGS_PE_PERSON.title%TYPE,
        oracle_username     IGS_PE_PERSON.oracle_username%TYPE,
        preferred_given_name    IGS_PE_PERSON.preferred_given_name%TYPE,
        full_name       IGS_PE_PERSON_V.full_name%TYPE,
        preferred_name      IGS_PE_PERSON_V.preferred_name%TYPE,
        title_name      IGS_PE_PERSON_V.title_name%TYPE,
        context_block_name  IGS_PE_PERSON_V.context_block_name%TYPE
    );
    v_person_details    r_person_details;
    v_other_detail  VARCHAR(255);
    CURSOR  c_person_details IS
        SELECT  p.last_name surname,
                p.first_name given_names,
                p.title,
                null oracle_username,
                p.known_as preferred_given_name,
                p.full_name,
                NVL(P.KNOWN_AS, SUBSTR (P.FIRST_NAME, 1, DECODE(INSTR(P.FIRST_NAME, ' '), 0, LENGTH(P.FIRST_NAME), (INSTR(P.FIRST_NAME, ' ')-1)))) || ' ' || P.LAST_NAME PREFERRED_NAME,
                null title_name,
                p.LAST_NAME || ',  ' || p.TITLE || '  ' || NVL(p.KNOWN_AS,p.FIRST_NAME) CONTEXT_BLOCK_NAME
        FROM    igs_pe_person_base_v p
        WHERE   person_id = p_person_id;
BEGIN
    OPEN    c_person_details;
    FETCH   c_person_details INTO v_person_details;
    IF (c_person_details%NOTFOUND) THEN
        CLOSE c_person_details;
        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN FALSE;
    ELSE
        CLOSE c_person_details;
        p_surname := v_person_details.surname;
        p_given_names := v_person_details.given_names;
        p_title := v_person_details.title;
        p_oracle_username := v_person_details.oracle_username;
        p_preferred_given_name := v_person_details.preferred_given_name;
        p_full_name := v_person_details.full_name;
        p_preferred_name := v_person_details.preferred_name;
        p_title_name := v_person_details.title_name;
        p_initial_name := v_person_details.full_name;
        p_context_block_name := v_person_details.context_block_name;
        p_message_name := null ;
        RETURN TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;

END genp_get_prsn_names;


END IGS_GE_GEN_002 ;

/
