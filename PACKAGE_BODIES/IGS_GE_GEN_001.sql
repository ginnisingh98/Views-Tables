--------------------------------------------------------
--  DDL for Package Body IGS_GE_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_GEN_001" AS
/* $Header: IGSGE01B.pls 120.3 2006/01/25 09:11:03 skpandey noship $ */
	/* change history
     WHO       WHEN         WHAT
     pkpatel   17-APR-2003  Bug 2261717
	                        Modified the FUNCTION genp_get_per_addr
     vrathi    03-JUN-2003  Bug 2940810
             				Modified procedure genp_get_audit. Added SQL bind variables.
     asbala    29-DEC-2003  Bug 3330996. 10GCERT
     gmaheswa	5-Jan-2004	Bug 4869737 Added a call to SET_ORG_ID in GENP_DEL_LOG to disable OSS for R12.
	*/

FUNCTION GENP_CHK_COL_UPPER(
  p_column_name  VARCHAR2 ,
  p_table_name  VARCHAR2 )
RETURN BOOLEAN AS
    gv_other_detail VARCHAR2(255);
BEGIN
DECLARE
    cst_table       CONSTANT    user_objects.object_type%TYPE := 'TABLE';
    cst_view        CONSTANT    user_objects.object_type%TYPE := 'VIEW';
    v_object_type       user_objects.object_type%TYPE;
    v_col_comment       user_col_comments.comments%TYPE;
    v_table_name        user_col_comments.table_name%TYPE;
    v_column_name       user_col_comments.column_name%TYPE;
    v_search_condition  VARCHAR2(10000);
    v_full_stop_pos     INTEGER;
    CURSOR c_uo (
        cp_object_name  user_objects.object_name%TYPE) IS
        SELECT  uo.object_type
        FROM    user_objects uo
        WHERE   uo.object_name = cp_object_name AND
            uo.object_type IN (cst_table, cst_view);
    CURSOR c_ucc (
        cp_view_name    user_col_comments.table_name%TYPE,
        cp_column_name  user_col_comments.column_name%TYPE) IS
        SELECT  ucc.comments
        FROM    user_col_comments ucc
        WHERE   ucc.table_name = cp_view_name AND
            ucc.column_name = cp_column_name;
    CURSOR c_uc (
        cp_table_name   user_constraints.table_name%TYPE) IS
        SELECT  uc.search_condition
        FROM    user_constraints uc
        WHERE   uc.constraint_type = 'C' AND
            uc.table_name = cp_table_name AND
            uc.status = 'ENABLED' AND
            uc.constraint_name like '%UCASE_CK%';
BEGIN
    -- This routine checks if a table column is forced
    -- to be upper case via a table constraint.
    -- Check if table is a view. If the table is a view
    -- need to determine the real table and column
    OPEN c_uo (p_table_name);
    FETCH c_uo INTO v_object_type;
    IF (c_uo%NOTFOUND) THEN
        CLOSE c_uo;
        RETURN FALSE;
    END IF;
    CLOSE c_uo;
    IF v_object_type = cst_table THEN
        v_table_name := p_table_name;
        v_column_name := p_column_name;
    ELSE
        -- Columns comments are being used to store the
        -- real table.column for the view column.
        OPEN c_ucc (
            p_table_name,
            p_column_name);
        FETCH c_ucc INTO v_col_comment;
        IF (c_ucc%NOTFOUND) THEN
            CLOSE c_ucc;
            RETURN FALSE;
        END IF;
        CLOSE c_ucc;
        v_table_name := p_table_name;
        v_column_name := p_column_name;
        v_full_stop_pos := INSTR(v_col_comment, '.', 1, 1);
        IF v_full_stop_pos = 0 THEN
            RETURN FALSE;
        END IF;
        v_table_name := SUBSTR(v_col_comment, 1, v_full_stop_pos - 1);
        v_column_name := SUBSTR(v_col_comment, v_full_stop_pos + 1);
    END IF;
    OPEN c_uc (v_table_name);
    LOOP
        FETCH c_uc INTO v_search_condition;
        IF c_uc%NOTFOUND THEN
            CLOSE c_uc;
            EXIT;
        END IF;
        -- Check if the column is constained to uppercase.
        -- Search for: column_name=UPPER(column_name)
        -- Eg. SURNAME=UPPER(SURNAME)
        -- Spaces and tabs are removed from the search string.
        IF INSTR(UPPER(REPLACE(REPLACE(v_search_condition, fnd_global.local_chr(32)), fnd_global.local_chr(09))),
                v_column_name || '=UPPER(' || v_column_name || ')') > 0 THEN
            CLOSE c_uc;
            RETURN TRUE;
        END IF;
    END LOOP;
    -- All rows have been processed and no matches were found.
    -- Column is not constrained to upper case.
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        IF c_uo%ISOPEN THEN
            CLOSE c_uo;
        END IF;
        IF c_ucc%ISOPEN THEN
            CLOSE c_ucc;
        END IF;
        IF c_uc%ISOPEN THEN
            CLOSE c_uc;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
END genp_chk_col_upper;


FUNCTION genp_clc_dt_diff(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN NUMBER AS
v_other_detail  VARCHAR2(255);
v_days      NUMBER;
BEGIN
    p_message_name := null;
    IF (p_end_dt < p_start_dt) THEN
        p_message_name := 'IGS_CA_ENDDT_LT_STARTDT';
        RETURN 0;
    END IF;
    v_days := p_end_dt - p_start_dt;
    RETURN v_days;
    EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
--      App_Exception.Raise_Exception;
END genp_clc_dt_diff;


 FUNCTION GENP_CLC_WEEK_END_DT(
  p_date IN DATE ,
  p_day_week_end IN VARCHAR2 DEFAULT 'FRIDAY')
RETURN DATE AS
    gv_other_detail     VARCHAR2(255);
BEGIN   -- genp_clc_week_end_dt
    -- This module will accept a date and return the week ending date.
    -- The default for the end day of the week is FRIDAY.
DECLARE
BEGIN
    -- If the date passed in is already the last day of the week, return it.
    IF RTRIM(TO_CHAR(p_date, 'DAY')) = p_day_week_end THEN
        RETURN p_date;
    ELSE
        -- otherwise calculate the date of the last day of the week.
        RETURN NEXT_DAY(p_date, p_day_week_end);
    END IF;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
END genp_clc_week_end_dt;


PROCEDURE GENP_DEL_LOG(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY number ,
  p_s_log_type IN VARCHAR2 ,
  p_days_old IN NUMBER )
AS
    gv_other_detail     VARCHAR2(255);
    e_resource_busy_exception       EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
BEGIN   -- genp_del_log
      igs_ge_gen_003.set_org_id;
    --Find and delete log records requiring cleanup.
    -- Remove s_log and s_log_entry records older than a specified number of days.
    retcode:=0;
DECLARE
    CURSOR c_sl (
            cp_s_log_type       IGS_GE_S_LOG.s_log_type%TYPE,
            cp_days_old_dt      IGS_GE_S_LOG.creation_dt%TYPE) IS
        SELECT  creation_dt , rowid
        FROM    IGS_GE_S_LOG
        WHERE   s_log_type = cp_s_log_type AND
            creation_dt < cp_days_old_dt
        FOR UPDATE of s_log_type NOWAIT;
    CURSOR c_sle (
            cp_s_log_type       IGS_GE_S_LOG_ENTRY.s_log_type%TYPE,
            cp_creation_dt      IGS_GE_S_LOG.creation_dt%TYPE) IS
        SELECT  creation_dt , rowid
        FROM    IGS_GE_S_LOG_ENTRY
        WHERE   s_log_type = cp_s_log_type  AND
            creation_dt = cp_creation_dt
        FOR UPDATE of s_log_type NOWAIT;
    v_record_found      BOOLEAN := FALSE;
BEGIN
    BEGIN   -- inner block
        SAVEPOINT sp_before_delete;
        FOR v_sl_rec IN c_sl(
                    p_s_log_type,
                    SYSDATE - p_days_old)
        LOOP
            v_record_found := TRUE;
            -- Clean up any log entries, they shouldn't exist
            FOR v_sle_rec IN c_sle(
                    p_s_log_type,
                    v_sl_rec.creation_dt)
            LOOP
                IGS_GE_S_LOG_ENTRY_PKG.DELETE_ROW(x_rowid => v_sle_rec.rowid)   ;
            END LOOP;
            -- Remove the current log record
            IGS_GE_S_LOG_PKG.DELETE_ROW(x_rowid => v_sl_rec.rowid);
        END LOOP;
    EXCEPTION
        WHEN e_resource_busy_exception THEN
            RETCODE := 2 ;
            ERRBUF := FND_MESSAGE.GET_STRING('IGS' , 'IGS_GE_RECORD_LOCKED');
    END; -- inner block
    IF v_record_found = FALSE THEN
        ERRBUF := FND_MESSAGE.GET_STRING('IGS' , 'IGS_GE_NO_LOG_ENTRIES');
    END IF;
    RETURN;
END;
EXCEPTION
    WHEN OTHERS THEN
        /*RETCODE := 2 ;
        ERRBUF := FND_MESSAGE.GET_STRING('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
         commented for the exception handler related chnages*/
         RETCODE := 2;
         ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                 IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END genp_del_log;


FUNCTION GENP_DEL_NOTE(
  p_reference_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
    gv_other_detail     VARCHAR2(255);
BEGIN   -- genp_del_note
    -- Delete a note record.
DECLARE
    e_resource_busy     EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
    CURSOR  c_del_note IS
        SELECT  IGS_GE_NOTE.* , ROWID
        FROM    IGS_GE_NOTE
        WHERE   reference_number = p_reference_number
        FOR UPDATE OF reference_number NOWAIT;
BEGIN
    SAVEPOINT   sp_before_delete;
    p_message_name:= null ;
    BEGIN
        FOR v_note_rec IN c_del_note LOOP
            IGS_GE_NOTE_PKG.DELETE_ROW(X_ROWID => V_NOTE_REC.ROWID );
        END LOOP;
    EXCEPTION
        WHEN e_resource_busy THEN
            ROLLBACK TO sp_before_delete;
            p_message_name := 'IGS_GE_NOTE_RECORD_LOCKED';
            RETURN FALSE;
    END;
    RETURN TRUE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        App_Exception.Raise_Exception ;
END genp_del_note;


FUNCTION genp_get_addr(
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

    v_line_1    VARCHAR2(256)  := NULL; -- first line of address
    v_line_2    VARCHAR2(256)  := NULL; -- second line of address
    v_line_3    VARCHAR2(256)  := NULL; -- third line of address
    v_line_4    VARCHAR2(256)  := NULL; -- 4th line of address
    v_line_5    VARCHAR2(256)  := NULL; -- 5th line of address
    v_addr      VARCHAR2(2000) := NULL; -- final address variable
    v_phone     VARCHAR2(100)  := NULL; -- placeholder for phone handling
    v_name      VARCHAR2(256)  := NULL; -- person name placeholder
    gv_other_detail VARCHAR2(1000) := NULL; -- global for error trapping
    -- Local Exceptions
    e_addr      EXCEPTION; -- overall exception for trapping and handling errors
    e_case_error    EXCEPTION; -- case type error
    --
    -- Local Functions
    -------------------------------------------------------------------------------
    -- Module:  genp_get_per_addr
    -- Purpose: Function for returning formatted person names and addresses
    --      based on variations of the parameters passed
    -- Notes:
    -- p_surname_first is a boolean to place the surname before the given name
    --  TRUE formats in surname + , + title + given name
    --  FALSE formats in title + given name + surname
    --
    -- p_phone_no is used to toggle the display of the phone number
    --  Y populates the p_phone_line parameter with the phone number
    --  N populates the p_phone_line parameter with a null value
    -- Exception Handlers
    -- e_name_error: returns false and populates the p_name variable with
    -- 'Person name not found'
    -- e_addr_error: returns false and populates p_line_1 with
    -- 'No address record found'
    --
    -- Module History
    -------------------------------------------------------------------------------
    -- 03/03/1998 MSONTER Intial creation of Module
    -- 05/03/1998 MSONTER Modified cursor c_pa to search
    -- IGS_CO_ADDR_TYPE.correspondence_type = 'Y'
    -- 18/03/1998 YSWONG Modified code according to PLSQL-CODING standards
    -- 19/03/1998 MSONTER Modified p_surname to p_name_style to use predefined
    -- naming standards
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
        p_phone_line    OUT NOCOPY  VARCHAR2)
    RETURN BOOLEAN
    AS
    /* change history
     WHO       WHEN         WHAT
     pkpatel   17-APR-2003  Bug 2261717
                            Removed selection of initial_last_name, initial_name from igs_pe_person_v.
		    				Instead the direct logic to retrieve it from hz_parties was introduced.
     skpandey  13-JAN-2006  Bug#4937960
                            Changed c_per_name cursor definition to optimize query
    */
    BEGIN
    DECLARE
        -- Local Cursors
        -- cursor for selection of the person name in seperate parts to allow
        -- construction based on the user preferences
        CURSOR c_per_name (cp_person_id hz_parties.party_id%TYPE)IS
		SELECT p.PERSON_TITLE    per_title,
		       p.PERSON_LAST_NAME per_surname,
		       NVL(P.KNOWN_AS,p.PERSON_FIRST_NAME) per_first_name,
		       NVL(P.KNOWN_AS, SUBSTR (P.PERSON_FIRST_NAME, 1, DECODE(INSTR(P.PERSON_FIRST_NAME, ' '), 0, LENGTH(P.PERSON_FIRST_NAME), (INSTR(P.PERSON_FIRST_NAME, ' ')-1)))) || ' ' || P.PERSON_LAST_NAME  per_preferred_name ,
		       P.PERSON_TITLE || ' ' || p.PERSON_FIRST_NAME || ' ' || P.PERSON_LAST_NAME       per_title_name ,
		       p.PERSON_LAST_NAME || ',  ' || p.PERSON_TITLE || '  ' || NVL(p.KNOWN_AS,p.PERSON_FIRST_NAME)  per_context_block_name
		FROM   hz_parties p
		WHERE  p.party_id   =  cp_person_id;


        -- cursor for selection of the person address when
        -- only the person_id is supplied
        CURSOR c_pa(cp_person_id NUMBER)IS
            SELECT padv.person_id      padv_person_id,
                padv.addr_type      padv_addr_type,
                padv.addr_line_1    padv_addr_line_1,
                padv.addr_line_2    padv_addr_line_2,
                padv.addr_line_3    padv_addr_line_3,
                padv.addr_line_4    padv_addr_line_4,
                padv.city       padv_city
            FROM    IGS_PE_PERSON_ADDR_V    padv
            WHERE   padv.person_id  =   cp_person_id AND
                padv.correspondence_ind = 'Y';

        -- cursor for selection of the person address when
        -- only the person_id and addr_type is supplied
        CURSOR c_pat(
            cp_person_id NUMBER,
            cp_addr_type VARCHAR2)IS
            SELECT  padv.person_id      padv_person_id,
                padv.addr_type      padv_addr_type,
                padv.addr_line_1    padv_addr_line_1,
                padv.addr_line_2    padv_addr_line_2,
                padv.addr_line_3    padv_addr_line_3,
                padv.addr_line_4    padv_addr_line_4,
                padv.city       padv_city
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


        -- Local Variables
        v_name  VARCHAR2(256)   := NULL;
        v_line_1    VARCHAR2(256)   := NULL;

        e_name_error    EXCEPTION; -- person name exception handler
        e_addr_error    EXCEPTION; -- person address exception handler
    BEGIN
        -- test for open cursor, then loop and select the persons name
        IF (c_per_name%ISOPEN) THEN
            CLOSE c_per_name;
        END IF;

        FOR c_per_rec IN c_per_name(p_per_id)LOOP
            -- Determine if surname should be displayed first
            IF p_name_style = 'PREFER' THEN

                v_name := c_per_rec.per_title || ' ' || c_per_rec.per_preferred_name;

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
                    END LOOP;
            ELSE
                FOR c_pat_rec IN c_pat(p_per_id, p_adr_type) LOOP
                        v_line_1 := c_pat_rec.padv_addr_line_1;
                        p_line_2 := c_pat_rec.padv_addr_line_2;
                            p_line_3 := c_pat_rec.padv_addr_line_3;
                        p_line_4 := c_pat_rec.padv_addr_line_4;
                        p_line_5 := c_pat_rec.padv_city;
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
            RAISE;
    END;
    EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
            RETURN FALSE;
    END genp_get_per_addr;

    -------------------------------------------------------------------------------
    -- Module:  genp_get_org_addr
    -- Purpose: Function for returning formatted org_unit names and addresses
    --      based on variations of the parameters passed
    -- Notes:
    -- p_phone_no is used to toggle the display of the phone number
    --  Y populates the p_phone_line parameter with the phone number
    --  N populates the p_phone_line parameter with a null value
    -- Exception Handlers
    -- e_name_error: returns false and populates the p_name variable with
    -- 'Org Unit not found'
    -- e_addr_error: returns false and populates p_line_1 with
    -- 'No address record found'
    --
    -- Module History
    -------------------------------------------------------------------------------
    -- 03/03/1998 MSONTER Intial creation of Module
    -- 05/03/1998 MSONTER Modified cursor c_org_name to search
    -- IGS_CO_ADDR_TYPE.correspondence_type = 'Y'
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
        -- cursor for selection of the org_unit name
        CURSOR c_org_name (
            cp_org_unit_cd VARCHAR2)IS
            SELECT ou.description   ou_description
            FROM    IGS_OR_UNIT ou
            WHERE   ou.org_unit_cd  =   cp_org_unit_cd;
        -- cursor for selection of the org_unit address when
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

        -- cursor for selection of the org_unit address when
        -- only the org_unit_cd and addr_type is supplied
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
        -- Local Exceptions
        e_name_error    EXCEPTION; -- org_unit name exception handler
        e_addr_error    EXCEPTION; -- org_unit address exception handler
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
    END genp_get_org_addr;
    -------------------------------------------------------------------------------
    -- Module:  genp_get_loc_addr
    -- Purpose: Function for returning formatted location names and addresses
    --      based on variations of the parameters passed
    -- Notes:
    -- p_phone_no is used to toggle the display of the phone number
    --  Y populates the p_phone_line parameter with the phone number
    --  N populates the p_phone_line parameter with a null value
    -- Exception Handlers
    -- e_name_error: returns false and populates the p_name variable with
    -- 'Location not found'
    -- e_addr_error: returns false and populates p_line_1 with
    -- 'No address record found'
    -- Module History
    -------------------------------------------------------------------------------
    -- 04/03/1998 MSONTER Intial creation of Module
    -- 05/03/1998 MSONTER Modified cursor c_loc_name to search
    -- IGS_CO_ADDR_TYPE.correspondence_type = 'Y'
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
        -- cursor for selection of the location name
        CURSOR c_loc_name (
            cp_location_cd VARCHAR2)IS
            SELECT loc.description  loc_description
            FROM    IGS_AD_LOCATION loc
            WHERE   loc.location_cd =   cp_location_cd;
        -- cursor for selection of the location address when
        -- only the loc_unit_cd is supplied
        --skpandey Bug#3687099, Changed definition of cursor c_loc to optimize query
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

        -- cursor for selection of the location address when
        -- only the location_cd and addr_type is supplied
        --skpandey Bug#3687099, Changed definition of cursor c_loct to optimize query
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
        -- Local Exceptions
        e_name_error    EXCEPTION; -- locationt name exception handler
        e_addr_error    EXCEPTION; -- location address exception handler
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
    END genp_get_loc_addr;
    -------------------------------------------------------------------------------
    -- Module:  genp_get_inst_addr
    -- Purpose: Function for returning formatted institution names and addresses
    --      based on variations of the parameters passed
    -- Notes:
    -- p_phone_no is used to toggle the display of the phone number
    --  Y populates the p_phone_line parameter with the phone number
    --  N populates the p_phone_line parameter with a null value
    -- Exception Handlers
    -- e_name_error: returns false and populates the p_name variable with
    -- 'Institution not found'
    -- e_addr_error: returns false and populates p_line_1 with
    -- 'No address record found'
    --
    -- Module History
    ----------------------------------------------------------------------
    -- 04/03/1998 MSONTER Intial creation of Module
    -- 05/03/1998 MSONTER Modified cursor c_inst_name to search
    -- IGS_CO_ADDR_TYPE.correspondence_type = 'Y'
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
        -- cursor for selection of the institution name
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
        -- Local Exceptions
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
            p_name := 'Institution Code not found';
            RETURN FALSE;
        WHEN e_addr_error THEN
            p_line_1 := 'No Address Record Found';
            RETURN TRUE;
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
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
                v_phone) THEN
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
            v_addr := v_addr || ' ' || v_line_3;
        END IF;
        IF v_line_4 IS NOT NULL THEN
            v_addr := v_addr || ' ' || v_line_4;
        END IF;
        IF v_line_5 IS NOT NULL THEN
            v_addr := v_addr || ' ' || v_line_5;
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
        RETURN NULL;
END genp_get_addr;

--skpandey, Bug#4937960: Stubbed genp_get_appl_owner, nowhere used
FUNCTION genp_get_appl_owner
RETURN VARCHAR2 AS
BEGIN
    RETURN NULL;
END;


 PROCEDURE genp_get_audit(
  p_table_name IN VARCHAR2 ,
  p_rowid IN VARCHAR2 ,
  p_update_who OUT NOCOPY VARCHAR2 ,
  p_update_on OUT NOCOPY DATE )
AS
	/* change history
     WHO       WHEN          WHAT
     vrathi    10-JUN-2003   BUG:2940810 Added SQL bind variable
	*/
    v_cursor        integer;
    v_no_rows   integer;
    v_update_who    varchar2(100);
    v_update_on date;
    v_select_string varchar2(255);
BEGIN
    v_cursor := dbms_sql.open_cursor;
    v_select_string := 'SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE FROM '||p_table_name||' WHERE rowid=:row_id';

    dbms_sql.parse(v_cursor, v_select_string, dbms_sql.native);

    dbms_sql.bind_variable(v_cursor,'row_id',p_rowid);

    dbms_sql.define_column(v_cursor,1,v_update_who,30);
    dbms_sql.define_column(v_cursor,2,v_update_on);
    v_no_rows := dbms_sql.execute_and_fetch(v_cursor, false);
    dbms_sql.column_value(v_cursor,1,v_update_who);
    dbms_sql.column_value(v_cursor,2,v_update_on);
    p_update_who := v_update_who;
    p_update_on := v_update_on;
    dbms_sql.close_cursor(v_cursor);
END genp_get_audit;


 FUNCTION genp_get_cmp_cutoff(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER )
RETURN DATE AS
    gv_other_detail     VARCHAR2(255);
BEGIN   -- genp_get_cmp_cutoff
    -- This module gets the IGS_PS_COURSE completion cutoff date.
DECLARE
    v_alias_val     IGS_CA_DA_INST_V.alias_val%TYPE;
    CURSOR c_daiv_sgcc (
        cp_acad_cal_type        IGS_CA_INST.cal_type%TYPE,
        cp_acad_ci_sequence_number  IGS_CA_INST.sequence_number%TYPE) IS
        SELECT  daiv.alias_val
        FROM    IGS_CA_DA_INST_V    daiv,
            IGS_GE_S_GEN_CAL_CON        sgcc
        WHERE   daiv.cal_type       = cp_acad_cal_type AND
            daiv.ci_sequence_number = cp_acad_ci_sequence_number AND
            daiv.dt_alias       = sgcc.crs_completion_cutoff_dt_alias
        ORDER BY    daiv.alias_val ASC;
BEGIN
    OPEN c_daiv_sgcc(
            p_acad_cal_type,
            p_acad_ci_sequence_number);
    FETCH c_daiv_sgcc INTO v_alias_val;
    IF c_daiv_sgcc%FOUND THEN
        CLOSE c_daiv_sgcc;
        RETURN v_alias_val;
    END IF;
    CLOSE c_daiv_sgcc;
    RETURN NULL;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_daiv_sgcc%ISOPEN) THEN
            CLOSE c_daiv_sgcc;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
END genp_get_cmp_cutoff;

FUNCTION adm_get_name(
    x_person_id in NUMBER)
RETURN VARCHAR2 AS

l_name VARCHAR2(450);
CURSOR name IS
-- change the reference from igs_pe_person_v to igs_pe_person_base_v --rghosh
SELECT full_name FROM igs_pe_person_base_v
WHERE  person_id = x_person_id;
BEGIN
IF x_person_id IS NULL THEN
  return NULL;
ELSE
  OPEN name;
  FETCH name INTO l_name;
  CLOSE name;
  RETURN l_name;
END IF;

END adm_get_name;

FUNCTION adm_get_unit_title(
    x_person_id             NUMBER,
    x_admission_appl_number NUMBER,
        x_nominated_course_cd  VARCHAR2)
RETURN VARCHAR2 AS
l_title VARCHAR2(90);
CURSOR title IS
SELECT title FROM igs_ad_unit_sets_v
WHERE  person_id         = x_person_id AND
       admission_appl_number = x_admission_appl_number AND
       nominated_course_cd   = x_nominated_course_cd;
BEGIN
  OPEN title;
  FETCH title INTO l_title;
  CLOSE title;
  RETURN l_title;

END adm_get_unit_title;

END IGS_GE_GEN_001 ;

/
