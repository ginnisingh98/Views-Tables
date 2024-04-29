--------------------------------------------------------
--  DDL for Package Body IGS_EN_NSC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_NSC_PKG" AS
/* $Header: IGSEN87B.pls 120.7 2006/08/11 10:34:37 smaddali noship $ */


G_PKG_NAME         CONSTANT VARCHAR2(30) := 'IGS_EN_NSC_PKG';
g_debug_mode       BOOLEAN := FALSE;
g_branch_id        VARCHAR2(25);
g_school_id        VARCHAR2(30);
g_include_gen  VARCHAR2(1);
g_matr_profile  VARCHAR2(20);
g_org_id           NUMBER(15);
l_doc_inst_params  igs_en_doc_instances.doc_inst_params%TYPE;
l_ant_grad_date    DATE;
l_grad_type        VARCHAR2(25);
l_load_term_cd     VARCHAR2(20);
l_load_cal_type     igs_ca_inst.cal_type%TYPE;
l_load_cal_seq     igs_ca_inst.sequence_number%TYPE;
l_acad_cal_type    igs_ca_inst.cal_type%TYPE;
l_found               BOOLEAN := FALSE;
TYPE t_counts IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
g_counts           t_counts ;

/*pl/sql table to hold valid programs*/
TYPE t_pgms_table IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
t_valid_pgms t_pgms_table;
l_valid_pgm_index BINARY_INTEGER := 1;

/*pl/sql table to hold processed students*/
TYPE t_pers_table IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
     t_valid_pers t_pers_table;
      l_valid_per_index BINARY_INTEGER := 1;

--Calendar data
CURSOR c_cal_data (l_c_cal_type VARCHAR2,l_c_seq_number NUMBER) IS
    SELECT start_dt ,
           end_dt ,
           alternate_code
      FROM igs_ca_inst
     WHERE cal_type = l_c_cal_type
           AND sequence_number = l_c_seq_number;

-- Type of student record

TYPE student_data_type IS RECORD (
  student_id  NUMBER(20)   , --Student id for the version
  ssn         VARCHAR2(50) , -- Student SSN
  f_name      VARCHAR2(150) , -- First Name
  m_name      VARCHAR2(80) , -- Middle Initial
  l_name      VARCHAR2(150) , -- Last Name
  suffix      VARCHAR2(50) , -- Name Suffix
  prev_ssn    VARCHAR2(50) , -- Previous SSN
  prev_l_name VARCHAR2(150) , -- Previous Last Name
  enr_status  VARCHAR2(80) , -- Enrollment Status
  status_date DATE         , -- Status Start Date
  addr1       VARCHAR2(240), -- Street Line 1
  addr2       VARCHAR2(240), -- Street Line 2
  city        VARCHAR2(80) , -- City
  state       VARCHAR2(60)  , -- State
  zip         VARCHAR2(60) , -- Zip
  country     VARCHAR2(80) , -- Country
  grad_date   DATE         , -- Graduation Date
  birth_date  DATE         , -- Birth Date
  term_s_date DATE         , -- Term Begin Date
  term_e_date DATE         , -- Term End Date
  grad_level  VARCHAR2(1)  , -- Graduate Level Indicator
  data_block  VARCHAR2(1)    -- Data Block Indicator
);

/*
  This procedure generates the error message for the
  concurrent program and writes it into the log file.
*/
PROCEDURE Generate_message;

/*
   Function to determine the current enrollment status of the student.
   It takes the student id as the input parameter.
   Source API which returns system enrollment status is:
   Based on the system status the NSLC status should be derived, using set up table.
   The set up option names are: ENR_STAT_H, ENR_STAT_F and ENR_STAT_L.
   Also this function returns the status change date for the W, D, A and G statuses.
*/

FUNCTION Get_Enrollment_Status (
 p_snapshot_id       IN igs_en_doc_instances.doc_inst_id%TYPE,
 p_student_id        IN  igs_pe_person.person_id%TYPE ,
 p_load_cal_type     IN  igs_ca_inst.cal_type%TYPE,
 p_load_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_acad_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_acad_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_prev_snapshot_id  IN igs_en_doc_instances.doc_inst_id%TYPE,
 x_credit_points     OUT NOCOPY NUMBER,
 x_status_date       OUT NOCOPY DATE,
 x_grad_level        OUT NOCOPY VARCHAR2,
 x_ant_grad_date     OUT NOCOPY DATE,
 p_student_data      IN OUT NOCOPY student_data_type,
 p_nslc_condition    IN varchar2
) RETURN VARCHAR2;




/*
  This function is used to determine the status change date
  Its called only if the enrollment status is changed
  from F to H or L, or  from H to L
*/

FUNCTION Get_Status_Change_Date (
 p_student_id        IN igs_pe_person.person_id%TYPE,
 p_old_status        IN VARCHAR2,
 p_new_status        IN VARCHAR2,
 p_load_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_load_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_acad_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_acad_cal_seq      IN igs_ca_inst.sequence_number%TYPE
) RETURN DATE;



/*
  Create snapshot instance record and save main parameters (header record)
*/
PROCEDURE Create_Header_Record (
  p_school_code       IN  VARCHAR2,
  p_branch_code       IN  VARCHAR2,
  p_load_cal_type     IN  igs_ca_inst.cal_type%TYPE,
  p_load_cal_seq      IN  igs_ca_inst.sequence_number%TYPE,
  p_report_flag       IN  VARCHAR2,
  p_prev_snapshot_id  IN  igs_en_doc_instances.doc_inst_id%TYPE,
  x_snapshot_id       OUT NOCOPY igs_en_doc_instances.doc_inst_id%TYPE
) ;



/*
  This procedure determines the trailer records values,
  based on the information from the snapshot.
  Then it stores the trailer record in the EDS.
*/
PROCEDURE Create_Trailer_Record (
  p_snapshot_id  IN igs_en_doc_instances.doc_inst_id%TYPE
);


/*
  This procedure takes the record with the student information,
  instantiated before and stores it in the EDS calling the APIs.
*/

PROCEDURE Save_Student_Record (
  p_snapshot_id  IN igs_en_doc_instances.doc_inst_id%TYPE,
  p_student_data IN student_data_type
);


/*
  This procedure deletes all non-numeric characters from SSN
*/
FUNCTION process_ssn (
   p_ssn VARCHAR2
) RETURN VARCHAR2;

/*
  This iprocedure retrieves the data for the particular student.
  PL/SQL record type is used to store the student information.
*/

PROCEDURE Get_Student_Data (
 p_snapshot_id       IN igs_en_doc_instances.doc_inst_id%TYPE,
 p_load_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_load_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_acad_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_acad_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_prev_snapshot_id  IN igs_en_doc_instances.doc_inst_id%TYPE,
 p_student_data      IN OUT NOCOPY student_data_type,
 p_nslc_condition    IN varchar2
);


/*
  This function is called from the concurrent request
*/
FUNCTION Create_Snapshot(
  p_comment      IN  VARCHAR2,  -- Runtime Comments
  p_school_id    IN  VARCHAR2,  -- School code
  p_branch_id    IN  VARCHAR2,  -- Branch code
  p_cal_inst_id  IN  VARCHAR2,  -- Calendar instance concatenated ID
  p_std_rep_flag IN  VARCHAR2,  -- Standard report flag
  p_non_std_rpt_type IN VARCHAR2, --Non standard report type like GRADUATE
  p_prev_inst_id IN  igs_en_doc_instances.doc_inst_id%TYPE,   -- Previous snapshot Id (if any)
  p_dirpath      IN  VARCHAR2,  -- Output directory name
  p_file_name    IN  VARCHAR2,  -- Output file name
  p_debug_mode   IN  VARCHAR2
) RETURN BOOLEAN ;


PROCEDURE Put_Debug_Msg (
   p_debug_message IN VARCHAR2
);

/******************************************************************************/
PROCEDURE Add_To_Cache (
  p_cache        IN OUT NOCOPY VARCHAR2,
  p_new_id       IN NUMBER)
IS
BEGIN
  IF p_cache IS NULL THEN
    p_cache:=',';
  END IF;
  IF length(p_cache)<30000  THEN --Maximum is 32767. This is the limit, if more add is called for more entries, nothing is done
              p_cache:=p_cache||p_new_id||',';
     END IF;
END Add_To_Cache ;


FUNCTION Create_Snapshot(
  p_comment      IN  VARCHAR2,  -- Runtime Comments
  p_school_id    IN  VARCHAR2,  -- School code
  p_branch_id    IN  VARCHAR2,  -- Branch code
  p_cal_inst_id  IN  VARCHAR2,  -- Calendar instance concatenated ID
  p_std_rep_flag IN  VARCHAR2,  -- Standard report flag
  p_non_std_rpt_type IN VARCHAR2, --Non standard report type like GRADUATE
  p_prev_inst_id IN  igs_en_doc_instances.doc_inst_id%TYPE,   -- Previous snapshot Id (if any)
  p_dirpath      IN  VARCHAR2,  -- Output directory name
  p_file_name    IN  VARCHAR2,  -- Output file name
  p_debug_mode   IN  VARCHAR2
) RETURN BOOLEAN
 -------------------------------------------------------------------------------------------
 --Change History:
 --   Who         When            What
 --  svanukur     20-jan-2004     changed the cursor c_validate_person_id_grad to check if
 --                               student does has not already been processed to fix bug 3345173
 --svanukur       05-MAY-2004     changed the cursor c_persons_for_course to include students whose
 --                               discontinuation date falls within the term even if they do not have unit
 --                               attempts in the term. BUG 3611841
 --somasekar   13-apr-2005      bug# 4179106 modified to neglect the transfer cancelled programs also
 --somasekar   07-Jun-2005      BUG#  4415651
   -------------------------------------------------------------------------------------------
IS

 l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Snapshot';
 cst_valid             CONSTANT VARCHAR2(30)   := 'VALID';
 l_student_data        student_data_type;
 l_load_cal_type       igs_ca_inst.cal_type%TYPE;
 l_acad_cal_seq        igs_ca_inst.sequence_number%TYPE;
 l_snapshot_id         igs_en_doc_instances.doc_inst_id%TYPE :=NULL;
 l_branch_code         VARCHAR2(20);
 l_load_term_s_date    DATE;
 l_load_term_e_date    DATE;
 l_req                 NUMBER;

 CURSOR c_acad_term IS
   SELECT sup_cal_type,
          sup_ci_sequence_number
     FROM igs_ca_inst_rel
    WHERE sub_cal_type = l_load_cal_type
          AND sub_ci_sequence_number = l_load_cal_seq
          AND sup_cal_type IN
              (SELECT cal_type
                 FROM igs_ca_type_v
                WHERE s_cal_cat='ACADEMIC');


  CURSOR c_grad_type IS
    SELECT opt_val
    FROM igs_en_nsc_options
    WHERE opt_type = 'DATE_GRAD';


 --First get a list of active programs which are attempted by a student
 --such that they belong to the local institution .

    CURSOR c_course (cp_nslc_condition VARCHAR2 )IS
    SELECT DISTINCT spa.course_cd, spa.version_number, hp.party_id org_id, ihp.oss_org_unit_cd org_unit_cd
    FROM igs_en_stdnt_ps_Att spa , igs_ps_ver vers, hz_parties hp, igs_pe_hz_parties ihp,
          igs_or_status os
    WHERE vers.course_cd=spa.course_cd
    AND vers.version_number=spa.version_number
    AND spa.cal_type = l_acad_cal_type
    AND  (
                 (spa.course_attempt_status NOT IN ('DELETED','UNCONFIRM')
                   AND  cp_nslc_condition = '3' )
               OR (cp_nslc_condition <> '3' AND spa.course_attempt_status = 'COMPLETED')
         )
    AND  spa.future_dated_trans_flag NOT IN ('Y','C')
    AND (vers.generic_course_ind = g_include_gen OR g_include_gen = 'Y')
    AND ihp.oss_org_unit_cd = vers.responsible_org_unit_cd
    AND ihp.party_id = hp.party_id
    AND ihp.institution_cd=g_school_id
    AND hp.party_id = ihp.party_id AND ihp.inst_org_ind = 'O'
    AND ihp.ou_org_status = os.org_status AND os.s_org_status='ACTIVE';




 --get a list of persons who attempted the program
 --added the condition to fetch list of students who have discontinued date within the term BUG 3550778
 ----IF cp_nslc_condition is 1 then consider only completed program attempts
 --such that course_rqrmnts_complete_dt falls within the term.
 --IF cp_nslc_condition is 2 then consider only completed program attempts whose conferral date lies in the term.
 --IF cp_nslc_condition is 3 then check for all program attempts such that
-- either the completion date or discontinuation date falls within the term
--or a unit_attempt  exists for a given term, or a lapsed date exists within the
--term. The inactive and intermit status records are fetched irrespective of
--the d.ates

 CURSOR c_persons_for_course (cp_course_cd igs_ps_ver.course_cd%TYPE,cp_course_ver igs_ps_ver.version_number%TYPE, cp_nslc_condition VARCHAR2,  l_grd_type VARCHAR2) IS
  SELECT spa.person_id FROM igs_en_stdnt_ps_att spa
    WHERE course_cd=cp_course_cd
    AND version_number=cp_course_ver
    AND spa.cal_type = l_acad_cal_type
      AND
    (
       (cp_nslc_condition = '3' AND discontinued_dt BETWEEN l_load_term_s_date AND l_load_term_e_date)
       OR
       (cp_nslc_condition IN ('1','3') AND l_grd_type = 'CRS_RQMNTS_COMPL_DATE'
        AND course_rqrmnts_complete_dt BETWEEN l_load_term_s_date AND l_load_term_e_date)
       OR
       (cp_nslc_condition = '3' AND lapsed_dt BETWEEN l_load_term_s_date AND l_load_term_e_date)

        OR
      (cp_nslc_condition = '3' AND course_attempt_status  = 'INTERMIT'
        And (EXISTS ( SELECT spi.person_id,spi.course_cd
                      FROM igs_en_stdnt_ps_intm spi
                      WHERE spi.person_id = spa.person_id
                       AND spi.course_cd = cp_course_cd
                       AND spi.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
                       AND(
                            ( spi.start_dt <= l_load_term_e_date  AND spi.end_dt   >=l_load_term_e_date)
                            OR
                            ( spi.start_dt <= l_load_term_e_date AND spi.end_dt   >= SYSDATE AND spi.end_dt   >= l_load_term_s_date)
                           )
                      )
              )
      )
     OR
       (cp_nslc_condition in( '2','3') AND l_grd_type = 'CONFERRAL_DATE' AND
          (EXISTS (select gr.person_id
                          FROM igs_gr_graduand_all gr,igs_en_spa_awd_aim spaa,  igs_gr_stat grs
                          WHERE gr.graduand_status =grs. graduand_status
                          AND grs. s_graduand_status = 'GRADUATED'
                         AND gr.person_id = spaa.person_id  AND gr.course_cd = spaa.course_cd
                         AND spa.person_id = spaa.person_id
                         AND spa.course_cd = spaa.course_cd
                         AND gr.award_cd = spaa.award_cd
                         AND spaa.conferral_date BETWEEN l_load_term_s_date AND l_load_term_e_date
                       )
           )
        )
        OR
       (cp_nslc_condition = '3'
            AND course_attempt_status IN('ENROLLED','DISCONTIN', 'LAPSED','COMPLETED', 'INACTIVE')
            AND (EXISTS (SELECT 'X' FROM igs_en_su_attempt b, igs_ca_load_to_teach_v lod
                  WHERE  b.person_id = spa.person_id
                  and b.course_cd = spa.course_cd
                  and b.cal_type = lod.teach_cal_type
                  AND  b.ci_sequence_number = lod.teach_ci_sequence_number
                  AND lod.load_cal_type = l_load_cal_type AND lod.load_ci_sequence_number = l_load_cal_seq
                  and b.unit_Attempt_Status <> 'UNCONFIRM'
                        )
                )
        )
    );


 --Check if the person has already been added by checking if an SSN entry has been made .
 --The SSN Attribute is mandatory (attrib_id=20)
 CURSOR c_person_already_in_report(cp_person_id igs_pe_person.person_id%TYPE,cp_snapshot_id igs_en_doc_instances.doc_inst_id%TYPE) IS
     SELECT cst_valid FROM igs_en_attrib_values
     WHERE obj_type_id = 1
     AND obj_id = cp_snapshot_id
     AND attrib_id = 20
     AND version = cp_person_id;

 --Checks the res_status and SSN of the person
 CURSOR c_validate_person_id (cp_person_id igs_pe_person.person_id%type) IS
        SELECT cst_valid
        FROM  igs_pe_eit perv
        WHERE perv.person_id=cp_person_id
        AND information_type = 'PE_STAT_RES_STATUS'
        AND perv.pei_information1 NOT IN
          (SELECT opt_val
           FROM igs_en_nsc_options
           WHERE opt_type = 'NC_STAT_CD'
          )
        AND EXISTS
          (SELECT 'X'
           FROM  igs_pe_alt_pers_id pit,igs_pe_person_id_typ  ppit
           WHERE cp_person_id=pit.pe_person_id
           AND pit.person_id_type = ppit.person_id_type
           AND ppit.s_person_id_type = 'SSN'
           AND pit.start_dt <= SYSDATE
           AND NVL(pit.end_dt,SYSDATE) >= SYSDATE
          );


 --if g_branch_id<>'00'
--this cursor returns 'Valid' only if there is path from the program org to the branch org with no orgs with alt_ids
--the only condition where this cursor return wrong result is if g_branch_id=cp_org_unit_cd and and alt_id is defined.
--this is checked before calling the cursor.
--The condition after the connect by stops the recursion when the Branch org is reached and prunes branches with alt ids
--The where clause filters the final hierarchy to see if te Branch org has been reached.
CURSOR c_validate_org_branch (cp_org_unit_cd igs_or_unit_v.org_unit_cd%TYPE) IS
        SELECT cst_valid
        FROM igs_or_unit_rel
        WHERE parent_org_unit_cd=g_branch_id
        CONNECT BY child_org_unit_cd=PRIOR parent_org_unit_cd
        AND child_org_unit_cd<>g_branch_id AND igs_en_nsc_pkg.org_alt_check(child_org_unit_cd) IS NULL
        START WITH child_org_unit_cd=cp_org_unit_cd
        AND igs_en_nsc_pkg.org_alt_check(cp_org_unit_cd) IS NULL;


--org needs to satisfy either c_validate_org_all or c_validate_org_all_inst if g_branch_id='00'
--c_validate_org_all returns 'Valid' only if there is path from the program org to the
--one of orgs in the institution (with none of the orgs in the pat having alt_ids)
--The condition after the connect by prunes branches with alt ids
--The where clause filters the final hierarchy to see if a branch org under the institution has been reached.
CURSOR c_validate_org_all (cp_org_unit_cd igs_or_unit_v.org_unit_cd%TYPE) IS
        SELECT cst_valid
        FROM igs_or_unit_rel
        WHERE parent_org_unit_cd IN (SELECT ihp.oss_org_unit_cd org_unit_cd FROM hz_parties hp, igs_pe_hz_parties ihp
                                     WHERE hp.party_id = ihp.party_id AND ihp.inst_org_ind = 'O'
                                     AND ihp.institution_cd = g_school_id)
        CONNECT BY child_org_unit_cd=PRIOR parent_org_unit_cd
        AND igs_en_nsc_pkg.org_alt_check(child_org_unit_cd) IS NULL
        START WITH child_org_unit_cd=cp_org_unit_cd
        AND igs_en_nsc_pkg.org_alt_check(cp_org_unit_cd) IS NULL;

--c_validate_org_all_inst returns valid if org is directly under the institution
CURSOR c_validate_org_all_inst (cp_org_unit_cd igs_or_unit_v.org_unit_cd%TYPE) IS
       SELECT cst_valid FROM hz_parties hp, igs_pe_hz_parties ihp
       WHERE hp.party_id = ihp.party_id AND ihp.inst_org_ind = 'O'
       AND ihp.oss_org_unit_cd = cp_org_unit_cd
       AND ihp.party_id = hp.party_id
       AND ihp.institution_cd = g_school_id
       AND igs_en_nsc_pkg.org_alt_check(cp_org_unit_cd) IS NULL;



 CURSOR c_org_unit_cd(g_branch_id VARCHAR2, l_branch_code VARCHAR2) IS
         SELECT DISTINCT org_structure_id
         FROM igs_or_org_alt_ids alt
         WHERE NVL(alt.end_date, SYSDATE) >= SYSDATE
           AND NVL(alt.start_date,SYSDATE) <= SYSDATE
           AND org_alternate_id = g_branch_id
           AND org_alternate_id_type = l_branch_code
           AND alt.org_structure_type = 'ORG_UNIT';

     -- Cursor to get the org_structure_id for the passed alternate code
 CURSOR c_school_code IS
       SELECT alt.org_structure_id
       FROM   igs_or_org_alt_ids alt, igs_or_institution inst
       WHERE  alt.org_structure_id   = inst.institution_cd
         AND  alt.org_structure_type = 'INSTITUTE'
         AND  NVL(alt.end_date, SYSDATE) >= SYSDATE
         AND  inst.local_institution_ind = 'Y'
         AND  alt.org_alternate_id = p_school_id
       ORDER BY 1;

       l_nslc_condition   VARCHAR2(10);
       l_check            VARCHAR2(20);
       l_succ_orgs        VARCHAR2(32000):=NULL;
       l_fail_orgs        VARCHAR2(32000):=NULL;
       l_per_done         BOOLEAN:=FALSE;
       l_course_cd igs_ps_ver.course_cd%TYPE;
       l_version_number igs_ps_ver.version_number%TYPE;

  CURSOR c_rowid(p_inst_id IGS_EN_DOC_INSTANCES.doc_inst_id%TYPE) IS
   SELECT rowid
   FROM   igs_en_doc_instances
   WHERE doc_inst_id = p_inst_id;
    l_rowid rowid;
       BEGIN

  -- Standard Start of API savepoint
  g_debug_mode := TRUE;

BEGIN
  IF (g_debug_mode) THEN
      Put_Debug_Msg(substr('**************************************************************************************************',1,70));
      Put_Debug_Msg(substr('*********Starting NSC Snapshot creation proccess '||to_char(sysdate,'DD-MON-YY:MI:SS')||' *********************',1,70));
      Put_Debug_Msg(substr('**************************************************************************************************',1,70));
  END IF;

  -- Init term data
  l_load_cal_type := rtrim(substr(p_cal_inst_id,1,10));
  l_load_cal_seq  := to_number(substr(p_cal_inst_id,101,6));

  OPEN c_acad_term;
  FETCH c_acad_term INTO l_acad_cal_type,l_acad_cal_seq;
  CLOSE c_acad_term;

  -- Getting branch code and branch id. The first twenty characters holds the id and the rest of the string holds the code.

  g_branch_id    := rtrim(substr(p_branch_id,1,20));
  l_branch_code  := substr(p_branch_id,22,10);

  IF g_branch_id <> '00' THEN

     OPEN c_org_unit_cd(g_branch_id,l_branch_code);
     FETCH c_org_unit_cd INTO g_branch_id;
     CLOSE c_org_unit_cd;

  END IF;

   --  Get the school code for the passed alternate code
  OPEN c_school_code;
  FETCH c_school_code INTO g_school_id;
  CLOSE c_school_code;

  OPEN  c_cal_data(l_load_cal_type,l_load_cal_seq);
  FETCH c_cal_data INTO l_load_term_s_date ,
                        l_load_term_e_date ,
                        l_load_term_cd;
  CLOSE c_cal_data;

  -- Storing the values in Doc instances parameters
  l_doc_inst_params := l_load_term_cd||TO_CHAR(SYSDATE,'DD/MON/YYYY')||p_dirpath||'/'||p_file_name;
  g_matr_profile := NVL(FND_PROFILE.VALUE('IGS_PE_MATR_TERM'),'ALL');
  IF g_matr_profile = 'ALL' THEN
     g_include_gen := 'Y';
  ELSE
     g_include_gen := 'N';
  END IF;

  g_org_id := NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99);


  -- Open student cursor
  OPEN c_grad_type;
  FETCH c_grad_type INTO l_grad_type;
  CLOSE c_grad_type;

  IF (g_debug_mode) THEN
      Put_Debug_Msg('Input parameters: Load term '||l_load_cal_type ||':'||l_load_cal_seq||' Acad term '|| l_acad_cal_type
        ||':'||l_acad_cal_seq||' Branch code '|| l_branch_code ||' ID '||g_branch_id ||' Term S date '|| l_load_term_s_date
        ||' Term E date '||l_load_term_e_date ||' Term code '||l_load_term_cd ||' Include gen programs '||g_include_gen
        ||' Org Id '||g_org_id ||' Prev snapshot Id '||p_prev_inst_id||' g_school_id '||g_school_id ||
        ' p_non_std_rpt_type '||p_non_std_rpt_type||' p_std_rep_flag '||p_std_rep_flag) ;
      Put_Debug_Msg('Creating student loop');
  END IF;

  --The nslc query behaves in different ways for these 3 conditions
  --the variable l_nslc_condition is passed to all the relevant cursors.
  IF l_grad_type= 'CRS_RQMNTS_COMPL_DATE'  AND p_non_std_rpt_type = 'G' THEN
    l_nslc_condition :='1';
  ELSIF l_grad_type= 'CONFERRAL_DATE' AND p_non_std_rpt_type = 'G' THEN
    l_nslc_condition :='2';
  ELSIF  p_non_std_rpt_type <> 'G' AND p_std_rep_flag <> 'N' THEN
    l_nslc_condition :='3';
  ELSE
    IF (g_debug_mode) THEN
      Put_Debug_Msg('NSC condition error');
    END IF;
    FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_NSC_NO_STUDENTS');
    FND_MSG_PUB.Add;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  l_student_data.student_id:=NULL;

  --Loop through the list of courses satisfying the program attempt validations
  FOR l_course IN c_course (l_nslc_condition) LOOP
       l_check:=NULL;
    --Get the org unit of the program if it satisfies further course validations
    --course validations was split into c_course and c_get_org_if_valid for performance
    --(both space and time) reasons

      IF INSTR (l_succ_orgs,','||l_course.org_id||',') <>0 THEN
        --if in cache of successful orgs
        l_check:=cst_valid;

      ELSIF INSTR (l_fail_orgs,','||l_course.org_id||',') <>0 THEN
        --if in cache of failed orgs
        l_check:='INVALID';

      ELSE
        --Not found in either cache...Proceed with actual org hierarchy validations
        IF g_branch_id = '00' THEN

          --check if program org is one of the branches in the institution
          --If it is, the org is valid and no other org validations are required

          OPEN c_validate_org_all_inst(l_course.org_unit_cd);
          FETCH c_validate_org_all_inst INTO l_check;
          CLOSE c_validate_org_all_inst;

          IF NVL(l_check,' ')<>cst_valid THEN
            --check if there is a path from program org to one of the branches in the institution

            OPEN  c_validate_org_all(l_course.org_unit_cd);
            FETCH c_validate_org_all INTO l_check;
            CLOSE c_validate_org_all;
          END IF;

        ELSE
          --g_branchid<>'00' validate the program against the given Branch Org
          IF g_branch_id=l_course.org_unit_cd THEN
             l_check:=cst_valid;
          ELSE
            --check if there is a path from program org to the branch org
            OPEN c_validate_org_branch(l_course.org_unit_cd);
            FETCH  c_validate_org_branch INTO l_check;
            CLOSE c_validate_org_branch;
          END IF;
        END IF;

        --Add the org to the appropriate cache depending
        -- on whether or not the validation was succesfull
        --If validation failed, skip to next course.
        IF NVL(l_check,' ')<>cst_valid THEN
          --this org failed validation .. skip course
          Add_To_Cache (l_fail_orgs,l_course.org_id);
put_debug_msg('Invalid org unit code :'|| l_course.org_id);
          l_check:='INVALID';
        ELSE
          l_check:=cst_valid;
          Add_To_Cache (l_succ_orgs,l_course.org_id);
        END IF;
      END IF;

        IF l_check=cst_valid THEN
        --  add program to pl/sql table

        t_valid_pgms(l_valid_pgm_index) := rpad(l_course.course_cd,6,' ')||'-'||l_course.version_number;
        l_valid_pgm_index := l_valid_pgm_index+1;
Put_Debug_Msg('Adding program '||rpad(l_course.course_cd,6,' ')||' with version ' ||l_course.version_number);
        END IF;
END LOOP;

--for each of the program fetched in teh above cursor fetch the list of students.
IF t_valid_pgms.count > 0 THEN
FOR i in 1 .. t_valid_pgms.count LOOP

BEGIN
SAVEPOINT SP_PROGRAM;
Put_Debug_Msg('t_valid_pgms(i)'||t_valid_pgms(i));

   l_course_cd := rtrim(substr(t_valid_pgms(i),1,6));
   l_version_number := to_number(rtrim(substr(t_valid_pgms(i),8)));
Put_Debug_Msg('Processing program ' || l_course_cd ||' version_number '||l_version_number);

        FOR l_person IN c_persons_for_course (l_course_cd,l_version_number,l_nslc_condition,l_grad_type) LOOP
          l_per_done:=FALSE;
          l_check:=NULL;
        --check if the student has already been processed.
        IF l_snapshot_id IS NOT NULL THEN
        IF t_valid_pers.count > 0 THEN
                FOR i in 1 .. t_valid_pers.count LOOP
                    IF t_valid_pers(i) = l_person.person_id THEN
                        l_per_done := TRUE;
                      exit;
                      END IF;
                 END LOOP;
         END IF;
         END IF;


          IF l_per_done=FALSE THEN

            --check if the person satisfies person validation
            l_check:=NULL;
            OPEN c_validate_person_id(l_person.person_id);
            FETCH c_validate_person_id INTO l_check ;
            CLOSE c_validate_person_id ;


            --If person has failed...skip

            IF NVL(l_check,' ')<>cst_valid THEN
              --add to student cache.
             t_valid_pers(l_valid_per_index) := l_person.person_id;
             l_valid_per_index := l_valid_per_index +1;
              l_per_done:=TRUE;
            END IF;
          END IF; --l_per_done=FALSE

          IF l_per_done=FALSE THEN

            IF l_student_data.student_id IS NULL THEN
              --First student is being saved...create header first

              IF (g_debug_mode) THEN
                 Put_Debug_Msg('Creating header record');
              END IF;

              --Initialise counts for statuses for use in trailer.
              g_counts(10):=0;g_counts(11):=0;g_counts(12):=0;g_counts(13):=0;
              g_counts(14):=0;g_counts(15):=0;g_counts(16):=0;g_counts(17):=0;

              --Call to Header creation
              Create_Header_Record (
                            p_school_code       => p_school_id,
                            p_branch_code       => l_branch_code,
                            p_load_cal_type     => l_load_cal_type,
                            p_load_cal_seq      => l_load_cal_seq,
                            p_report_flag       => p_std_rep_flag,
                            p_prev_snapshot_id  => p_prev_inst_id,
                            x_snapshot_id       => l_snapshot_id );
              IF (g_debug_mode) THEN
                Put_Debug_Msg('Done. Snapshot id: '||l_snapshot_id);
              END IF;
            END IF;

            -- Assigning id to a record
            IF (g_debug_mode) THEN
              Put_Debug_Msg('Proccessing student: '||l_person.person_id);
            END IF;

            l_student_data.student_id := l_person.person_id;
               --  Get student data
                    Get_Student_Data (
                            p_snapshot_id       => l_snapshot_id,
                            p_load_cal_type     => l_load_cal_type,
                            p_load_cal_seq      => l_load_cal_seq ,
                            p_acad_cal_type     => l_acad_cal_type,
                            p_acad_cal_seq      => l_acad_cal_seq ,
                            p_prev_snapshot_id  => p_prev_inst_id ,
                            p_student_data      => l_student_data,
                            p_nslc_condition    => l_nslc_condition
                        );


            -- Save student data
            IF (g_debug_mode) THEN
              Put_Debug_Msg('End Get_Student_Date');
            END IF;

            IF l_student_data.ssn IS NOT NULL THEN --person details were retrieved successfully
            --add to student cache.
             t_valid_pers(l_valid_per_index) := l_person.person_id;
             l_valid_per_index := l_valid_per_index +1;

             IF l_student_data.enr_status IS NOT NULL THEN
                 l_found := TRUE;
              Save_Student_Record (p_snapshot_id   => l_snapshot_id,
                                              p_student_data  => l_student_data);
              IF (g_debug_mode) THEN
                Put_Debug_Msg('Record saved');
              END IF;
              END IF;
           END IF;

              l_student_data.ssn          := NULL;
              l_student_data.f_name       := NULL;
              l_student_data.m_name       := NULL;
              l_student_data.l_name       := NULL;
              l_student_data.suffix       := NULL;
              l_student_data.prev_ssn     := NULL;
              l_student_data.prev_l_name  := NULL;
              l_student_data.enr_status   := NULL;
              l_student_data.status_date  := NULL;
              l_student_data.addr1        := NULL;
              l_student_data.addr2        := NULL;
              l_student_data.city         := NULL;
              l_student_data.state        := NULL;
              l_student_data.zip          := NULL;
              l_student_data.country      := NULL;
              l_student_data.grad_date    := NULL;
              l_student_data.birth_date   := NULL;
              l_student_data.term_s_date  := NULL;
              l_student_data.term_e_date  := NULL;
              l_student_data.grad_level   := NULL;
              l_student_data.data_block   := NULL;
         END IF;--l_per_done=TRUE
        END LOOP; --person loop

    EXCEPTION
    WHEN OTHERS THEN
       Put_Debug_Msg('exception raised, rolling back data');
    ROLLBACK to SP_PROGRAM;
    RAISE;
    END;
COMMIT;
  END LOOP; --program loop
 END IF; --count;
  -- Check if there are any records found
  IF NOT l_found  THEN

    IF (g_debug_mode) THEN
       Put_Debug_Msg('Raising exception NO_STUDENTS_FOUND');
    END IF;

    FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_NSC_NO_STUDENTS');
    --FND_MSG_PUB.Add;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    RAISE FND_API.G_EXC_ERROR;

  END IF;

  -- Create trailer record
  Create_Trailer_Record (p_snapshot_id   => l_snapshot_id) ;

  IF (g_debug_mode) THEN
      Put_Debug_Msg('Trailer record created');
  END IF;

  COMMIT;
EXCEPTION
WHEN OTHERS THEN
--delete the records with this snapshot ID
begin
savepoint delete_snapshot;
       Put_Debug_Msg('deleting snapshot id ' ||l_snapshot_id);
    OPEN c_rowid(l_snapshot_id);
    FETCH c_rowid INTO l_rowid;
    CLOSE c_rowid;

   -- Deleting the instance record and all attribute values
   if l_rowid is not null then
       Put_Debug_Msg('calling delete row for  ' ||l_rowid);
   IGS_EN_DOC_INSTANCES_PKG.Delete_Row(
    x_rowid    => l_rowid
   );

   end if;
 IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
 END IF;
COMMIT;
Put_Debug_Msg('returning false');
RETURN FALSE;

EXCEPTION
WHEN OTHERS THEN
ROLLBACK TO DELETE_SNAPSHOT;
       Put_Debug_Msg('ERROR while deleting snapshot id ' ||l_snapshot_id);
 IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
RETURN FALSE;
END;
END;
  -- Print snapshot
 Put_Debug_Msg('calling print job');
  SAVEPOINT     Print_Snapshot;

   -- Raising the request to create a text file in the specified format
  l_req := FND_REQUEST.SUBMIT_REQUEST
                          ('IGS',
                           'IGSENJ09',
                           NULL,
                           NULL,
                           FALSE,
                           p_comment,
                           to_char(l_snapshot_id),
                           p_dirpath,
                           p_file_name );


   IF (l_req > 0) THEN
        IF (g_debug_mode) THEN
            Put_Debug_Msg('Text file creation request submitted');
        END IF;
   ELSE
      IF (g_debug_mode) THEN
          Put_Debug_Msg('Error during request submition');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   COMMIT;
   RETURN TRUE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Print_Snapshot;
      Put_Debug_Msg('G_EXC_ERROR'||sqlerrm);
      RETURN FALSE;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Print_Snapshot;
           Put_Debug_Msg('UNEXPECTED_ERROR'||sqlerrm);
     RETURN FALSE;

  WHEN OTHERS THEN
     ROLLBACK TO Print_Snapshot;
Put_Debug_Msg('OTHERS'||sqlerrm);
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;

     RETURN FALSE;


END Create_Snapshot;

/******************************************************************************/
/*
  This is the main procedure which prints the data into the text file.
  Its called from the concurent request form or from the Create_Snapshot procedure.
*/

PROCEDURE Print_Snapshot_Request (
  /*************************************************************
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ckasu           17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) as a part of bug#4958173.
  ***************************************************************/
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER  ,  -- Request standard return status
  p_comment  IN  VARCHAR2, -- Runtime comments
  p_inst_id      IN  igs_en_doc_instances.doc_inst_id%TYPE,   -- Snapshot Id to create a file
  p_dirpath      IN  VARCHAR2 ,  -- Output directory name
  p_file_name    IN  VARCHAR2 ,  -- Output file name
  p_debug_mode   IN  VARCHAR2 := FND_API.G_FALSE
)
IS

   l_api_name       CONSTANT VARCHAR2(30)   := 'Print_Snapshot_Request';
   l_Return_Status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);
   l_dirpath        VARCHAR2(100);
   l_file_name      VARCHAR2(100);

BEGIN
    -- Printing file
   igs_ge_gen_003.set_org_id(NULL);
   IGS_EN_NSC_FILE_PRNT_PKG.Generate_file(
     p_api_version       => 1.0 ,
     x_return_status     => l_Return_Status,
     x_msg_count         => l_msg_count,
     x_msg_data          => l_msg_data,
     p_obj_type_id       => 1,
     p_doc_inst_id       => p_inst_id,
     p_dirpath           => p_dirpath,
     p_file_name         => p_file_name,
     p_form_id           => 1 ,
     p_debug_mode        => p_debug_mode
   );


   -- Checking the status

   IF (l_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
      fnd_file.put_line(FND_FILE.LOG,'File Successfully Printed ');
      --Successfull completion
      retcode := 0;
   ELSE
      -- Error: generating message and returning the error code
      retcode := 2;
   END IF;

EXCEPTION

   WHEN OTHERS THEN

      retcode := 2;

      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Generate_Message;

END Print_Snapshot_Request;


/******************************************************************************/

PROCEDURE Create_Snapshot_Request(
  /*************************************************************
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ckasu           17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) as a part of bug#4958173.
  ***************************************************************/
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER  ,  -- Request standard return status
  p_comment      IN  VARCHAR2,  -- Runtime Comments
  p_school_id    IN  VARCHAR2,  -- School code
  p_branch_id    IN  VARCHAR2,  -- Branch code
  p_cal_inst_id  IN  VARCHAR2,  -- Calendar instance concatenated ID
  p_std_rep_flag IN  VARCHAR2,  -- Standard report flag
  p_dummy        IN  VARCHAR2,   /* Dummy Parameter used for validation of non_std_rpt_type Value Set, it is nowhere used in the procedure. */
  p_non_std_rpt_typ IN VARCHAR2,  -- Non Standard report type like 'GRADUATE'
  p_prev_inst_id IN  igs_en_doc_instances.doc_inst_id%TYPE,   -- Previous snapshot Id (if any)
  p_dirpath      IN  VARCHAR2,  -- Output directory name
  p_file_name    IN  VARCHAR2,  -- Output file name
  p_debug_mode   IN  VARCHAR2 := FND_API.G_FALSE
)IS
   l_api_name       CONSTANT VARCHAR2(30)   := 'Create_Snapshot_Request';
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);
   p_non_std_rpt_type VARCHAR2(20);
BEGIN

   igs_ge_gen_003.set_org_id(NULL);
   -- If the parameter non standard report type is passed as null
   -- then it is assigned with a value 'Y'
   IF p_non_std_rpt_typ IS NULL THEN
      p_non_std_rpt_type := 'Y';
   ELSE
      p_non_std_rpt_type := p_non_std_rpt_typ;
   END IF;

  -- Calling create snapshot procedure
  IF Create_Snapshot(
       p_comment      => p_comment,
       p_school_id    => p_school_id   ,
       p_branch_id    => p_branch_id   ,
       p_cal_inst_id  => p_cal_inst_id ,
       p_std_rep_flag => p_std_rep_flag,
       p_non_std_rpt_type => p_non_std_rpt_type,
       p_prev_inst_id => p_prev_inst_id,
       p_dirpath      => p_dirpath     ,
       p_file_name    => p_file_name   ,
       p_debug_mode   => p_debug_mode)
  THEN
      --Successfull completion
      retcode := 0;
  ELSE
      -- Error: generating message and returning the error code
      --Generate_Message;
      retcode := 2;
  END IF;
EXCEPTION

   WHEN OTHERS THEN

      retcode := 2;

      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Generate_Message;

END Create_Snapshot_Request;

/******************************************************************************/
/*
  This is the procedure which deletes the snapshot from the database.
*/

PROCEDURE Delete_Snapshot_Request (
 /*************************************************************
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ckasu           17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) as a part of bug#4958173.
  ***************************************************************/
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER  ,  -- Request standard return status
  p_comment  IN  VARCHAR2,  -- Runtime comments
  p_inst_id      IN  igs_en_doc_instances.doc_inst_id%TYPE ,   -- Snapshot Id to delete
  p_debug_mode   IN  VARCHAR2 := FND_API.G_FALSE
)IS
   l_api_name       CONSTANT VARCHAR2(30)   := 'Delete_Snapshot_Request';
   l_return_status  CONSTANT VARCHAR2(1) := 'S';
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);
   l_rowid      VARCHAR2(255);

 CURSOR c_rowid IS
   SELECT rowid
   FROM   igs_en_doc_instances
   WHERE doc_inst_id = p_inst_id;

 BEGIN

    igs_ge_gen_003.set_org_id(NULL);
    OPEN c_rowid;
    FETCH c_rowid INTO l_rowid;
    CLOSE c_rowid;

   -- Deleting the instance record and all attribute values

   IGS_EN_DOC_INSTANCES_PKG.Delete_Row(
    x_rowid    => l_rowid
   );

   -- Checking the status
   IF (l_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
      --Successfull completion
      fnd_file.put_line(FND_FILE.LOG,'File deleted successfully.');
      retcode := 0;
   ELSE
      -- Error: generating message and returning the error code
      retcode := 2;
   END IF;

EXCEPTION

   WHEN OTHERS THEN

      retcode := 2;

      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Generate_Message;

END Delete_Snapshot_Request;

/******************************************************************************/

PROCEDURE Generate_Message
IS
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

BEGIN

   FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

   IF (l_msg_count > 0) THEN
      l_msg_data := '';
      FOR l_cur IN 1..l_msg_count LOOP
        l_msg_data := FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
        put_debug_msg(l_msg_data);
        fnd_file.put_line (FND_FILE.LOG,  l_msg_data);
      END LOOP;
   ELSE
     FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_ERR_STACK_DATA');
     l_msg_data  := FND_MESSAGE.GET;
     put_debug_msg(l_msg_data);
     fnd_file.put_line (FND_FILE.LOG,  l_msg_data);
   END IF;

END Generate_Message;

/******************************************************************************/

PROCEDURE Check_Result (p_code VARCHAR2)
IS
BEGIN

  IF substr(p_code,1,1) <> 'S' THEN
     Put_Debug_Msg('Error during EDS insertion: '||p_code);
     RAISE FND_API.G_EXC_ERROR;
  END IF;

END Check_Result;

/******************************************************************************/

PROCEDURE Create_Header_Record (
  p_school_code       IN  VARCHAR2,
  p_branch_code       IN  VARCHAR2,
  p_load_cal_type     IN  igs_ca_inst.cal_type%TYPE,
  p_load_cal_seq      IN  igs_ca_inst.sequence_number%TYPE,
  p_report_flag       IN  VARCHAR2,
  p_prev_snapshot_id  IN  igs_en_doc_instances.doc_inst_id%TYPE,
  x_snapshot_id       OUT NOCOPY igs_en_doc_instances.doc_inst_id%TYPE
) IS

   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(2000);
   l_Return_Status    VARCHAR2(1);
   l_rowid            VARCHAR2(255);
   l_inst_id          igs_en_doc_instances.doc_inst_id%TYPE;
   l_code             VARCHAR2(3);
BEGIN

  -- Creating instance

    IGS_EN_DOC_INSTANCES_PKG.Insert_row (
       x_rowid               =>     l_rowid,
       x_doc_inst_id         =>     l_inst_id,
       x_doc_inst_name       =>     'NSCL Interface instance' ,
       x_doc_inst_params     =>     l_doc_inst_params
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_snapshot_id := l_inst_id;

    -- Saving values :p_obj_type_id,p_obj_id p_attrib_id p_version p_value x_return_code.
    IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,l_inst_id,1,0,p_school_code,l_code);
    Check_Result(l_code);   --Checking the result code

    IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,l_inst_id,2,0,p_branch_code,l_code);
    Check_Result(l_code);   --Checking the result code

    IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,l_inst_id,3,0,p_load_cal_type,l_code);
    Check_Result(l_code);   --Checking the result code

    IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,l_inst_id,4,0,p_load_cal_seq,l_code);
    Check_Result(l_code);   --Checking the result code

    IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,l_inst_id,5,0,p_report_flag,l_code);
    Check_Result(l_code);   --Checking the result code

    IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,l_inst_id,6,0,to_char(sysdate,'YYYYMMDD'),l_code);
    Check_Result(l_code);   --Checking the result code

    IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,l_inst_id,7,0,p_prev_snapshot_id,l_code);
    Check_Result(l_code);   --Checking the result code

END Create_Header_Record;


/******************************************************************************/

PROCEDURE Create_Trailer_Record (
  p_snapshot_id  IN igs_en_doc_instances.doc_inst_id%TYPE
)IS
--Statuses mapping
--10,'F',11,'H',12,'L',13,'W',14,'G',15,'A',16,'X',17,'D','?')

l_code             VARCHAR2(3);
BEGIN

    g_counts(18):=0;
    --Making loop through attributes to get counts for the trailer record
    FOR l_cur_count IN 10..17 LOOP
         --Store value in the EDS
          IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,l_cur_count,0,g_counts(l_cur_count),l_code);
          Check_Result(l_code);   --Checking the result code
          g_counts(18):=g_counts(18)+g_counts(l_cur_count);
    END LOOP;

    IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,18,0,g_counts(18),l_code);
    Check_Result(l_code);   --Checking the result code

END Create_Trailer_Record;

/******************************************************************************/




PROCEDURE Save_Student_Record (
  p_snapshot_id  IN igs_en_doc_instances.doc_inst_id%TYPE,
  p_student_data IN student_data_type
)IS
  l_code          VARCHAR2(3);

BEGIN
   --Saving value;
   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,20,p_student_data.student_id,p_student_data.ssn,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,21,p_student_data.student_id,p_student_data.f_name,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,22,p_student_data.student_id,p_student_data.m_name,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,23,p_student_data.student_id,p_student_data.l_name,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,24,p_student_data.student_id,p_student_data.suffix,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,25,p_student_data.student_id,p_student_data.prev_ssn,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,26,p_student_data.student_id,p_student_data.prev_l_name,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,27,p_student_data.student_id,p_student_data.enr_status,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,28,p_student_data.student_id,to_char(p_student_data.status_date,'YYYYMMDD'),l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,29,p_student_data.student_id,p_student_data.addr1,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,30,p_student_data.student_id,p_student_data.addr2,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,31,p_student_data.student_id,p_student_data.city,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,32,p_student_data.student_id,p_student_data.state,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,33,p_student_data.student_id,p_student_data.zip,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,34,p_student_data.student_id,p_student_data.country,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,35,p_student_data.student_id,to_char(p_student_data.grad_date,'YYYYMMDD'),l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,36,p_student_data.student_id,to_char(p_student_data.birth_date,'YYYYMMDD'),l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,37,p_student_data.student_id,to_char(p_student_data.term_s_date,'YYYYMMDD'),l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,38,p_student_data.student_id,to_char(p_student_data.term_e_date,'YYYYMMDD'),l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,39,p_student_data.student_id,p_student_data.grad_level,l_code);
   Check_Result(l_code);   --Checking the result code

   IGS_EN_GS_ATTRIB_VAL.SET_VALUE(1,p_snapshot_id,40,p_student_data.student_id,p_student_data.data_block,l_code);
   Check_Result(l_code);   --Checking the result code

 END Save_Student_Record;



 /******************************************************************************/


FUNCTION process_ssn (
   p_ssn VARCHAR2
) RETURN VARCHAR2
IS
   l_new_val  VARCHAR2(25);
   l_char     VARCHAR2(1);
   l_len      NUMBER;
BEGIN

   l_len := NVL(length(p_ssn),0);

   FOR i IN 1..l_len LOOP

      l_char := substr(p_ssn,i,1);

      IF l_char between '0' and '9' THEN
         l_new_val := l_new_val||l_char;
      END IF;

   END LOOP;

   RETURN l_new_val;

END process_ssn;

/******************************************************************************/
/* Get previous academic term  */

FUNCTION get_prev_acad_term(p_person_id NUMBER)
  RETURN DATE AS

  -- Cursor to fetch the Units
  CURSOR c_units(p_person_id NUMBER) IS
    SELECT cal_type,ci_sequence_number
    FROM igs_en_su_attempt
    WHERE person_id = p_person_id
      AND unit_attempt_status IN ('COMPLETED','ENROLLED','DUPLICATE')
      AND ci_start_dt <= SYSDATE
    ORDER by ci_end_dt DESC;

  l_cal_type igs_en_su_attempt.cal_type%TYPE;
  l_ci_seq_num igs_en_su_attempt.ci_sequence_number%TYPE;

  CURSOR c_prev_acad_term(p_cal_type VARCHAR2, p_ci_sequence_number NUMBER) IS
    SELECT load_end_dt
    FROM igs_ca_teach_to_load_v
    WHERE teach_cal_type = p_cal_type
      AND teach_ci_Sequence_number = p_ci_sequence_number
    ORDER by load_end_dt DESC;

  l_load_end_dt DATE;

BEGIN

  /* open the cursor and fetching all the units in descending order of ci_end_dt
     which is in status COMPLETED,ENROLLED and DUPLICATE */

  OPEN c_units(p_person_id);
  FETCH c_units INTO l_cal_type,l_ci_seq_num;
  CLOSE c_units;

  /* open the cursor and fetch the end date of the load calendar type
     of the corresponding teaching periods return from above cursor */

  OPEN c_prev_acad_term(l_cal_type,l_ci_seq_num);
  FETCH c_prev_acad_term INTO l_load_end_dt;
  CLOSE c_prev_acad_term;

  RETURN l_load_end_dt;

END get_prev_acad_term;



PROCEDURE Get_Student_Data (
 p_snapshot_id       IN igs_en_doc_instances.doc_inst_id%TYPE,
 p_load_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_load_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_acad_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_acad_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_prev_snapshot_id  IN igs_en_doc_instances.doc_inst_id%TYPE,
 p_student_data      IN OUT NOCOPY student_data_type,
 p_nslc_condition    IN VARCHAR2
)IS

   l_prev_stat   VARCHAR2(1);
   l_student_id  NUMBER;
   l_code        VARCHAR2(80);
   l_comp_period VARCHAR2(30);
   l_comp_year   NUMBER(4);
   l_acad_cal_cd VARCHAR2(80);
   l_date        DATE;
   l_credit_points NUMBER;
   l_student_data student_data_type;

   -- Cursor to get the SSN
   CURSOR c_ssn_num IS
    SELECT api_person_id
      FROM igs_pe_alt_pers_id
     WHERE pe_person_id = p_student_data.student_id
           AND person_id_type
               IN (SELECT person_id_type
                     FROM igs_pe_person_id_typ
                    WHERE s_person_id_type = 'SSN')
           AND start_dt <= sysdate
           AND end_dt IS NULL;

   -- Cursor to get the person details..cursor is changed from igs_pe_person to underlying tables
   CURSOR c_name IS
    SELECT p.person_last_name surname,
           p.person_first_name given_names,
           p.person_middle_name middle_name,
           p.person_name_suffix suffix,
           pp.date_of_birth birth_dt
     FROM hz_parties P,  hz_person_profiles PP
     WHERE p.party_id = p_student_data.student_id
     AND p.party_id = pp.party_id
     AND pp.content_source_type = 'USER_ENTERED'
     AND SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date,SYSDATE);

   -- Cursor to get the previous SSN
   CURSOR c_prev_ssn_num IS
    SELECT api_person_id
      FROM igs_pe_alt_pers_id
     WHERE pe_person_id = p_student_data.student_id
           AND person_id_type
               IN (SELECT person_id_type
                     FROM igs_pe_person_id_typ
                    WHERE s_person_id_type = 'SSN')
           AND start_dt <= sysdate
           AND end_dt IS NOT NULL
           AND start_dt <> end_dt
           ORDER BY end_dt DESC;


  -- Check for previous last name
   CURSOR c_prev_last_name IS
    SELECT ppa.surname
        FROM  igs_pe_person_alias ppa,
              igs_en_nsc_options eno
        WHERE ppa.person_id = p_student_data.student_id
          AND ppa.alias_type = eno.opt_val
          AND eno.opt_type = 'LAST_NAME'
          AND ppa.start_dt <= SYSDATE
          AND (ppa.end_dt IS NULL OR ppa.end_dt > SYSDATE )
          ORDER BY priority ASC, start_dt DESC;

   -- Check for address
   CURSOR c_address IS
    SELECT addr_line_1    ,
           addr_line_2    ,
           city           ,
           decode(country,'US',state,'FO') state,
           decode(country,'US',postal_code,' ' ) postal_code,
           decode(country,'US','',country)
      FROM igs_pe_person_addr
     WHERE person_id = p_student_data.student_id
           AND addr_type
               IN (SELECT opt_val
                     FROM igs_en_nsc_options
                    WHERE opt_type = 'ADDR_TYPE')
           AND (status = 'A'
               AND SYSDATE BETWEEN NVL(start_dt,SYSDATE) AND NVL(end_dt,SYSDATE+1))
           ORDER BY start_dt DESC;


   CURSOR c_priv_block IS
          SELECT 'Y'
          FROM igs_pe_priv_level pl,igs_en_nsc_options op
          WHERE pl.person_id = p_student_data.student_id
              AND to_char(pl.data_group_id)=op.opt_val
              AND op.opt_type = 'BLK_IND'
              AND pl.start_date <= SYSDATE
              AND pl.end_date IS NULL;

   -- Cursor returns the most recent compeltion period and year from all program attempts

   CURSOR c_program_data IS
    SELECT nominated_completion_yr  ,
           nominated_completion_perd
      FROM igs_en_stdnt_ps_att_all
     WHERE person_id = p_student_data.student_id
           AND cal_type = p_acad_cal_type
           AND course_attempt_status IN ('COMPLETED', 'ENROLLED', 'INACTIVE', 'INTERMIT')
           ORDER BY NVL(nominated_completion_yr,-1) desc, decode(nominated_completion_perd,'E',1,'S',2,'M',3,0) desc;


BEGIN

   IF (g_debug_mode) THEN
       Put_Debug_Msg('|   Begin Get student data..');
   END IF;

   -- Get ssn and delete all non numeric characters: c_ssn_num
   OPEN c_ssn_num;
   FETCH c_ssn_num INTO p_student_data.ssn;
   CLOSE c_ssn_num;

   IF p_student_data.ssn IS NULL THEN
      --SSN not found - don't include into the snapshot
      IF (g_debug_mode) THEN
          Put_Debug_Msg('|   SSN not found - return');
      END IF;
      RETURN;
   END IF;

   -- Delete all non numeric characters
   p_student_data.ssn := process_ssn (p_student_data.ssn);

   IF (g_debug_mode) THEN
      Put_Debug_Msg('|   SSN processed');
   END IF;

   -- Get f_name, birth_date, m_name, l_name, suffix: c_name
    IF (g_debug_mode) THEN
      Put_Debug_Msg('| Processing Name');
   END IF;
   OPEN c_name;
   FETCH c_name INTO p_student_data.l_name,
                     p_student_data.f_name,
                     p_student_data.m_name,
                     p_student_data.suffix,
                     p_student_data.birth_date;
   CLOSE c_name;
IF (g_debug_mode) THEN
        IF length(p_student_data.l_name) > 80 then
            Put_Debug_Msg('Last name :'|| p_student_data.l_name ||'is too long, data truncated to 80 characters on report ');
        end if;

        IF length(p_student_data.f_name) > 80 then
            Put_Debug_Msg('First name : '||p_student_data.f_name ||'is too long, data truncated to 80 characters on report ');
        end if;

    END IF;


   -- Get prev_ssn and delete all non numeric characters: c_prev_ssn_num
   OPEN c_prev_ssn_num;
   FETCH c_prev_ssn_num INTO p_student_data.prev_ssn;
   CLOSE c_prev_ssn_num;


   -- Delete all non numeric characters
   p_student_data.prev_ssn := process_ssn (p_student_data.prev_ssn);

   IF (g_debug_mode) THEN
      Put_Debug_Msg('|   Previous SSN processed');
   END IF;


   -- Get prev_l_name: c_prev_last_name
   OPEN c_prev_last_name;
   FETCH c_prev_last_name INTO p_student_data.prev_l_name;
   CLOSE c_prev_last_name;

IF (g_debug_mode) THEN
      Put_Debug_Msg('|  Previous last name processed');
        IF length(p_student_data.prev_l_name) > 80 then
            Put_Debug_Msg('previous Last name :'|| p_student_data.prev_l_name ||'is too long, data truncated to 80 characters on report ');
        end if;

    END IF;
   -- Get enr_status  and start date (if any):
   IF (g_debug_mode) THEN
       Put_Debug_Msg('|   Calculating enrollment status..');
   END IF;

   p_student_data.enr_status  := Get_Enrollment_Status (
                  p_snapshot_id      => p_snapshot_id,
                                  p_student_id       => p_student_data.student_id,
                                  p_load_cal_type    => p_load_cal_type,
                                  p_load_cal_seq     => p_load_cal_seq,
                                  p_acad_cal_type    => p_acad_cal_type,
                                  p_acad_cal_seq     => p_acad_cal_seq,
                                  p_prev_snapshot_id => p_prev_snapshot_id,
                                  x_credit_points    => l_credit_points,
                                  x_status_date      => p_student_data.status_date,
                                  x_grad_level       => p_student_data.grad_level,
                                  x_ant_grad_date    => l_ant_grad_date,
                                  p_student_data     => l_student_data,
                                  p_nslc_condition   =>p_nslc_condition
                                );

   IF (g_debug_mode) THEN
       Put_Debug_Msg('|   Enrollment status: '||p_student_data.enr_status||' date: '||p_student_data.status_date );
   END IF;

   -- if falling below full time then derive status change date based on previous snapshot value
   IF p_prev_snapshot_id IS NOT NULL AND p_student_data.enr_status IN ('L','H') THEN

      --Get previous status if current is H or L and snapshot is provided.
      l_prev_stat := IGS_EN_GS_ATTRIB_VAL.GET_VALUE(1,p_prev_snapshot_id,27,p_student_data.student_id);

      -- Get status_date (if reqiured)
      IF (g_debug_mode) THEN
          Put_Debug_Msg('|   Previous enrollemt status found: '||l_prev_stat);
      END IF;

      IF (p_student_data.enr_status = 'L' AND l_prev_stat IN ('F','H') )
         OR (p_student_data.enr_status = 'H' AND l_prev_stat ='F')  THEN

         --Status has been chaged - get the date
         IF (g_debug_mode) THEN
             Put_Debug_Msg('|   Status change date required, calculating..');
         END IF;

         p_student_data.status_date := Get_Status_Change_Date (
                                         p_student_id    => p_student_data.student_id,
                                         p_old_status    => l_prev_stat,
                                         p_new_status    => p_student_data.enr_status,
                                         p_load_cal_type => p_load_cal_type,
                                         p_load_cal_seq  => p_load_cal_seq,
                                         p_acad_cal_type => p_acad_cal_type,
                                         p_acad_cal_seq  => p_acad_cal_seq);


         IF (g_debug_mode) THEN
             Put_Debug_Msg('|   Done, date is '||p_student_data.status_date);
         END IF;

      END IF;

   END IF;

   -- Get addr1,addr2,city,state,zip,country: c_address
IF (g_debug_mode) THEN
             Put_Debug_Msg('Processing address');
  END IF;
   OPEN c_address;
   FETCH c_address INTO p_student_data.addr1   ,
                        p_student_data.addr2   ,
                        p_student_data.city    ,
                        p_student_data.state   ,
                        p_student_data.zip     ,
                        p_student_data.country ;
   CLOSE c_address;
IF (g_debug_mode) THEN
         IF length(p_student_data.addr1) > 100 then
            Put_Debug_Msg('Address Line 1 is too long, data truncated to 100 characters on report ');
        end if;

        IF length(p_student_data.addr2) > 100 then
            Put_Debug_Msg('Address Line 2 is too long, data truncated to 100 characters on report ');
        end if;
        IF length(p_student_data.zip) > 10 then
            Put_Debug_Msg('Zip code  is too long, data truncated to 10 characters on report ');
        end if;

        IF length(p_student_data.state) > 2 then
            Put_Debug_Msg('State  is too long. Please change to 2 character state code and rerun the report');
           RAISE FND_API.G_EXC_ERROR;
        end if;


    END IF;
   IF p_student_data.enr_status IN ('F','H','A') THEN

      -- Get graduation date

      IF (g_debug_mode) THEN
          Put_Debug_Msg('|   Calculating graduation date..');
      END IF;

      p_student_data.grad_date := l_ant_grad_date;

      IF (g_debug_mode) THEN
          Put_Debug_Msg('|   Done, Date is: '||p_student_data.grad_date );
      END IF;

   END IF;

   -- Get term_s_date, term_e_date: c_cal_data

   OPEN  c_cal_data(p_load_cal_type,p_load_cal_seq);
   FETCH c_cal_data INTO p_student_data.term_s_date   ,
                         p_student_data.term_e_date   ,
                         l_code;
   CLOSE c_cal_data;

   -- No need to set grad_level  -it's NULL for the current release

   p_student_data.grad_level :=p_student_data.grad_level;

   -- Get data_block: c_priv_block

   OPEN c_priv_block;
   FETCH c_priv_block INTO p_student_data.data_block ;

   --Check if notfound - then privacy block not requested

   IF c_priv_block%NOTFOUND THEN
      p_student_data.data_block := 'N';
   END IF;

   CLOSE c_priv_block;

   IF (g_debug_mode) THEN
       Put_Debug_Msg('|   Get student data exit' );
   END IF;

END Get_Student_Data;

/******************************************************************************/

FUNCTION Get_Enrollment_Status (
 p_snapshot_id       IN igs_en_doc_instances.doc_inst_id%TYPE,
 p_student_id        IN igs_pe_person.person_id%TYPE ,
 p_load_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_load_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_acad_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_acad_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_prev_snapshot_id  IN igs_en_doc_instances.doc_inst_id%TYPE,
 x_credit_points     OUT NOCOPY NUMBER,
 x_status_date       OUT NOCOPY DATE,
 x_grad_level        OUT NOCOPY VARCHAR2,
 x_ant_grad_date     OUT NOCOPY DATE,
 p_student_data      IN OUT NOCOPY student_data_type,
 p_nslc_condition    IN varchar2
) RETURN VARCHAR2 IS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Modified the c_outcome_dt cursor where clause due to change in
  --                            pk of student unit attempt w.r.t. bug number 2829262
  -- rnirwani   16-Sep-2004    changed cursor cur_intermission_details,c_latest_intrm (Enrp_Get_Sca_Elgbl) to not consider logically deleted records Bug# 3885804
  --svanukur    30-dec-2004    BUG 4095287 :Modified the function get_enrollment_status to check for the
  --                           attendance type only if the student's enrollment status is not 'A', 'G' or 'W'.
  --                             BUG 4095278 : passed  c_stud_courses_rec.course_cd as parameter to the cursor
  --                             c_outcome_dt, so that the outcome date of the correspondance program is fetched.
  --somasekar   13-apr-2005     bug# 4179106 modified to neglect the transfer cancelled programs also
  -- smaddali   11-aug-2006    Modified logic for bug#5440823
  -------------------------------------------------------------------------------------------
  l_A_prev_term_s_dt DATE;
  l_A_prev_term_e_dt DATE;
  l_A_stat_F      BOOLEAN := FALSE;
  l_W_stat        BOOLEAN := FALSE;
  l_A_stat        BOOLEAN := FALSE;
  l_D_stat        BOOLEAN := FALSE;
  l_G_stat        BOOLEAN := FALSE;
  l_s_date        DATE;
  l_e_date        DATE;
  l_load_term_cd  VARCHAR2(10);
  l_W_date        DATE;
  l_G_date        DATE;     -- For deceased date
  l_A_date        DATE;
  l_temp_date     DATE;
  l_A_temp_date     DATE;
  l_interm_start_dt DATE;
  l_tot_points    NUMBER := 0;
  l_tot_eftsu     NUMBER := 0;
  l_eftsu_points  NUMBER := 0;
  l_credit_points NUMBER := 0;
  l_stat          VARCHAR2(1);
  l_enr_status    VARCHAR2(5);
  l_temp_ant_grad_date  DATE;
  l_interm_end_dt DATE;
  l_study_another_inst VARCHAR2(1);

  l_A_prev_stat VARCHAR2(1);
  l_grad_date   DATE;
  l_W_temp_date  DATE;
  l_lp_temp_date DATE;
  l_message_name VARCHAR2(100);
  l_attendance_type  igs_en_stdnt_ps_att_all.attendance_type%TYPE;
  l_code          VARCHAR2(3);
  l_career_profile VARCHAR2(1);

  CURSOR c_enr_status (l_status VARCHAR2) IS
    SELECT substr(opt_type,10,1)
      FROM igs_en_nsc_options
     WHERE opt_val = l_status
           AND opt_type IN
               ('ENR_STAT_F','ENR_STAT_H','ENR_STAT_L');

 /* For deceased date..cursor is changed from igs_pe_person to underlying tables */
  CURSOR c_decease_date IS
    SELECT NVL(pp.date_of_death,SYSDATE)
    FROM igs_pe_hz_parties pd, hz_person_profiles pp
    WHERE DECODE(pp.date_of_death,NULL,NVL(pd.deceased_ind,'N'),'Y')='Y'
    AND pp.party_id = p_student_id
    AND pp.party_id = pd.party_id (+)
    AND pp.content_source_type = 'USER_ENTERED'
    AND SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date,SYSDATE);

/* Intermission */

  CURSOR c_interm_date (l_c_course_cd VARCHAR2,p_student_id NUMBER,p_s_date DATE,p_e_date DATE)  IS
    SELECT spi.start_dt,spi.end_dt,spi.intermission_type
      FROM igs_en_stdnt_ps_intm spi,igs_en_intm_types spt
      WHERE spi.person_id = p_student_id
           AND spi.course_cd = l_c_course_cd
           AND spi.intermission_type = spt.intermission_type
           AND spi.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
           AND (
                (spt.APPR_REQD_IND = 'Y' AND spi.approved = 'Y')
                OR
                spt.APPR_REQD_IND = 'N'
                )
           AND(
                ( spi.start_dt <= p_e_date  AND spi.end_dt   >= p_e_date)
                OR
                ( spi.start_dt <= p_e_date AND spi.end_dt   >= SYSDATE AND spi.end_dt   >= p_s_date)
               )
       ORDER by 2 DESC;

 l_interm_type VARCHAR2(25);


/* Cursor to find whether the student is studying at another institution or not */

  CURSOR c_interm_date_study (l_intm_type VARCHAR2)  IS
    SELECT 'x'
      FROM igs_en_intm_types
      WHERE intermission_type = l_intm_type
      AND study_antr_inst_ind = 'Y'
      AND APPR_REQD_IND = 'Y';

  l_study_at_another_inst  VARCHAR2(1);


/* For getting conferral date */

 CURSOR c_conferral_dt(p_course_cd VARCHAR,p_s_date DATE,p_e_date DATE) IS
   SELECT spaa.conferral_date
   FROM igs_gr_graduand_all gr,igs_en_spa_awd_aim spaa
   WHERE gr.person_id = p_student_id
   AND gr.course_cd = p_course_cd
   AND gr. graduand_status IN
                        ( SELECT graduand_status
                          FROM igs_gr_stat
                          WHERE s_graduand_status = 'GRADUATED'
                        )
   AND gr.person_id = spaa.person_id AND gr.course_cd = spaa.course_cd AND gr.award_cd = spaa.award_cd
   AND spaa.conferral_date BETWEEN p_s_date AND p_e_date;



/* To check whether all the programs of the student are of type GRADUATE i.e required for Graduate Level Indicator Field */

CURSOR c_grad_lvl(p_course_cd VARCHAR2, p_version_number NUMBER) IS
SELECT 'x'
FROM igs_en_nsc_options
WHERE opt_type='GR_LVL_IND'
AND opt_val IN (SELECT course_type_group_cd FROM igs_ps_type
        WHERE course_type = ( SELECT course_type
                      FROM igs_ps_ver_all
                          WHERE course_cd = p_course_cd
                      AND version_number = p_version_number
                     )
             );

c_grad_lvl_rec c_grad_lvl%ROWTYPE;



/* Checking whether the student is enrolled in any correspondence programs */

CURSOR c_corresp_prg(p_course_cd VARCHAR2, p_version_number NUMBER) IS
  SELECT 'x'
  FROM igs_en_nsc_options
  WHERE opt_type='CO_PRG_TG'
  AND opt_val IN (SELECT course_type_group_cd FROM igs_ps_type
          WHERE course_type = (SELECT course_type
                                       FROM igs_ps_ver_all
                           WHERE course_cd = p_course_cd
                       AND version_number=p_version_number
                      )
              );

l_corresp_prg VARCHAR2(1);


/* Checking for assessment items */
-- smaddali modified for performance bug#4914052
CURSOR c_outcome_dt(p_corresp_prg VARCHAR2) IS
SELECT DISTINCT asv.outcome_dt
FROM igs_as_su_atmpt_itm asv, igs_en_su_attempt asav,
     igs_en_stdnt_ps_att pr,igs_ps_ver  vers,igs_ca_load_to_teach_v lt
WHERE asv.person_id = asav.person_id
  AND asv.course_cd = asav.course_cd
  AND asv.uoo_id    = asav.uoo_id
  AND asav.person_id = pr.person_id
  AND asav.course_cd = pr.course_cd
  AND pr.course_cd = vers.course_cd
  AND  pr.version_number = vers.version_number
  AND asv.person_id = p_student_id
  AND asav.course_cd = p_corresp_prg
  AND asv.logical_delete_dt IS NULL
  AND  lt.teach_cal_type = asav.cal_type
AND lt.teach_ci_sequence_number = asav.ci_sequence_number
AND lt.load_cal_type = p_load_cal_type
AND lt.load_ci_sequence_number = p_load_cal_seq
AND pr.cal_type  = p_acad_cal_type
AND pr.course_attempt_status IN ('COMPLETED', 'ENROLLED', 'INACTIVE', 'INTERMIT','DISCONTIN','LAPSED')
AND asav.unit_attempt_status IN ('DISCONTIN','DROPPED')
AND (vers.generic_course_ind = g_include_gen OR g_include_gen = 'Y')
 ORDER by 1 DESC;

l_outcome_dt DATE;
c_outcome_dt_rec c_outcome_dt%ROWTYPE;


/* List of all course attempts for the person.
The cursor fetches all course attemmpts if run in standard mode
and only completed program attempts if run in non standard
Also takes into account the career profile of the university*/

  CURSOR c_stud_courses(cp_nslc_condition VARCHAR2,cp_career_profile VARCHAR2,cp_grad_type VARCHAR2,p_s_date DATE,p_e_date DATE) IS
    SELECT pr.course_cd,
           pr.discontinued_dt disc_dt,
           pr.course_rqrmnts_complete_dt comp_dt,
           pr.version_number vers,
           pr.course_attempt_status  status,
           pr.lapsed_dt lapsed_dt
     FROM  igs_en_stdnt_ps_att pr,
           igs_ps_ver vers
     WHERE pr.person_id = p_student_id
           AND pr.cal_type = p_acad_cal_type
                          AND
        (
           (cp_nslc_condition = '3' AND discontinued_dt BETWEEN p_s_date AND p_e_date)
           OR
           (cp_nslc_condition IN ('1','3') AND cp_grad_type = 'CRS_RQMNTS_COMPL_DATE'
            AND course_rqrmnts_complete_dt BETWEEN p_s_date AND p_e_date)
           OR
           (cp_nslc_condition = '3' AND lapsed_dt BETWEEN p_s_date AND p_e_date)
   OR
          (cp_nslc_condition = '3' AND course_attempt_status  = 'INTERMIT'
            And (EXISTS ( SELECT spi.person_id,spi.course_cd
                          FROM igs_en_stdnt_ps_intm spi
                          WHERE spi.person_id = pr.person_id
                           AND spi.course_cd = pr.course_cd
                           AND spi.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
                           AND(
                                ( spi.start_dt <= p_e_date  AND spi.end_dt   >=p_e_date)
                                OR
                                ( spi.start_dt <= p_e_date AND spi.end_dt   >= SYSDATE AND spi.end_dt   >= p_s_date)
                               )
                          )
                  )
          )
        OR
           (cp_nslc_condition in( '2','3') AND
                ( cp_grad_type = 'CONFERRAL_DATE' AND
                                (EXISTS (select gr.person_id
                                  FROM igs_gr_graduand_all gr,igs_en_spa_awd_aim spaa,  igs_gr_stat grs
                                  WHERE gr.person_id = pr.person_id and
                                  gr.graduand_status =grs. graduand_status
                                  AND grs. s_graduand_status = 'GRADUATED'
                                 AND gr.person_id = spaa.person_id  AND gr.course_cd = spaa.course_cd
                                 AND pr.person_id = spaa.person_id
                                 AND pr.course_cd = spaa.course_cd
                                 AND gr.award_cd = spaa.award_cd
                                 AND spaa.conferral_date BETWEEN p_s_date AND p_e_date)
                                )
                )
           )
           OR
           (cp_nslc_condition = '3'
                AND course_attempt_status IN('ENROLLED','DISCONTIN', 'LAPSED','COMPLETED','INACTIVE')
                AND (EXISTS (SELECT 'X'  FROM igs_en_su_attempt b, igs_ca_load_to_teach_v lod
                      WHERE  b.person_id = pr.person_id
                      AND b.course_cd = pr.course_cd
                      AND b.cal_type = lod.teach_cal_type
                      AND b.ci_sequence_number = lod.teach_ci_sequence_number
                      AND lod.load_cal_type = p_load_cal_type
                      AND lod.load_ci_sequence_number = p_load_cal_seq
                      and b.unit_attempt_status <> 'UNCONFIRM'
                       )
                       )
            )
        )      AND pr.future_dated_trans_flag NOT IN('Y', 'C')
               AND pr.course_cd = vers.course_cd
               AND vers.version_number = pr.version_number
               AND (vers.generic_course_ind = g_include_gen OR g_include_gen = 'Y')
               AND (
                    (cp_career_profile = 'Y' AND igs_en_spa_terms_api.get_spat_primary_prg(p_student_id, pr.course_cd,p_load_cal_type,p_load_cal_seq) = 'PRIMARY')
                    OR
                    (cp_career_profile = 'N')
                    );

/* Previous Intermission */
l_interm_prv_start_dt igs_en_stdnt_ps_intm.start_dt%TYPE;
l_interm_prv_end_dt igs_en_stdnt_ps_intm.end_dt%TYPE;

--fetch the latest intermission of a student
CURSOR c_latest_intrm(cp_course_cd VARCHAR2,cp_wthdrn_dt DATE) IS
SELECT sci.start_dt , sci.end_dt
FROM igs_en_stdnt_ps_intm sci,
     IGS_EN_INTM_TYPES eit
WHERE sci.person_id = p_student_id
AND sci.course_cd = cp_course_cd
AND sci.end_dt <= cp_wthdrn_dt
AND sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
AND sci.approved  = eit.appr_reqd_ind
AND eit.intermission_type = sci.intermission_type
ORDER BY end_dt DESC;

/*fetch unit attempts that were discntinued between teh student's
latest intermission and the program discontinuation/ lapsed date. */

CURSOR c_sua_disc(cp_course_cd VARCHAR2,cp_intrm_end_dt DATE, cp_wthdrn_dt DATE) IS
SELECT uoo_id, cal_type ,  ci_sequence_number,  discontinued_dt ,administrative_unit_status,
       unit_attempt_status,  no_assessment_ind
FROM igs_En_Su_Attempt
WHERE person_id = p_student_id
AND course_cd = cp_course_cd
AND unit_attempt_status = 'DISCONTIN'
AND discontinued_dt BETWEEN cp_intrm_end_dt AND cp_wthdrn_dt;

l_load_incur VARCHAR2(1);

l_start_date VARCHAR2(20);
l_start_year VARCHAR2(10);
l_non_grad_lvl VARCHAR2(1);
cst_active CONSTANT igs_ca_stat.s_cal_status%TYPE := 'ACTIVE';
cst_load CONSTANT igs_ca_type.s_cal_cat%TYPE := 'LOAD';
l_valid_pgm VARCHAR2(1);

--fetch start dateof the academic calendar for which the job is run
CURSOR cur_strt_date(cp_cal_type igs_ca_inst.cal_type%TYPE, cp_seq_number igs_ca_inst.sequence_number%TYPE) is
SELECT to_char(start_dt,'mm-dd-yyyy')
FROM igs_ca_inst
WHERE cal_type = cp_cal_type
AND sequence_number = cp_seq_number;

-- fetch all acad calendars that start or end in the calendar year of the
-- acad cal for which the job is run .
CURSOR acad_cal(cp_start_year  VARCHAR2
                ) IS
SELECT ci.cal_type, ci.SEQUENCE_NUMBER
FROM igs_ca_type ct,
     igs_ca_inst ci,
     igs_ca_stat cs
WHERE ci.cal_type = ct.cal_type
AND ct.s_cal_cat = 'ACADEMIC'
AND ct.closed_ind = 'N'
AND ci.cal_status = cs.cal_status
AND cs.s_cal_status = cst_active
AND (
(substr(to_char(start_dt, 'mm-dd-yyyy') ,7) = cp_start_year)
OR(substr(to_char(end_dt, 'mm-dd-yyyy') ,7) = cp_start_year)
);

--for all acad calendars that are in teh calendar year, get teh subordinate load cals.
CURSOR  c_load_cal_instance(
                cp_cal_type IGS_CA_INST.cal_type%TYPE,
                cp_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  ci.cal_type,
                        ci.sequence_number
                FROM    igs_ca_type ct,
                        igs_ca_inst ci,
                        igs_ca_stat cs,
                        igs_ca_inst_rel cir
                WHERE   ct.closed_ind = 'N' AND
                        cs.s_cal_status = cst_active AND
                        ci.cal_status = cs.cal_status AND
                        ct.s_cal_cat = cst_load AND
                        ci.cal_type = ct.cal_type AND
                        ci.cal_type = cir.sub_cal_type AND
                        ci.sequence_number = cir.sub_ci_sequence_number AND
                        cir.sup_cal_type = cp_cal_type AND
                        cir.sup_ci_sequence_number = cp_sequence_number;

     --fetch course that have unit attempts in the term .
      -- smaddali modified cursor form perf bug#4914052
          CURSOR cur_spa(cp_acad_cal_type igs_ca_inst.cal_type%TYPE,cp_load_cal_type igs_ca_inst.cal_type%TYPE,
          cp_load_cal_seq igs_ca_inst.sequence_number%TYPE) IS
          SELECT  DISTINCT spa.course_cd, spa.version_number
          FROM 	  igs_en_su_Attempt sua,igs_en_stdnt_ps_Att spa ,
                igs_ca_load_to_teach_v lod
          WHERE  spa.person_id = p_student_id
          AND spa.cal_type = cp_acad_cal_type
	      AND spa.person_id = sua.person_id
          AND spa.course_cd = sua.course_cd
	      AND sua.cal_type = lod.teach_cal_type
          AND sua.ci_sequence_number = lod.teach_ci_sequence_number
	      AND lod.load_cal_type = cp_load_cal_type
          AND lod.load_ci_sequence_number = cp_load_cal_seq;

     -- smaddali added these cursors for but#5440823
     CURSOR c_other_sua ( cp_course_cd igs_en_stdnt_ps_att_all.course_cd%TYPE ) IS
     SELECT  sua.discontinued_dt
     FROM         igs_en_su_attempt sua
     WHERE  sua.person_id = p_student_id
          AND sua.course_cd = cp_course_cd
          AND sua.unit_attempt_status NOT IN ('DROPPED','DISCONTIN')
          AND (sua.cal_type,sua.ci_sequence_number) IN
            ( SELECT teach_cal_type,teach_ci_sequence_number FROM igs_ca_load_to_teach_v
              WHERE load_cal_type = p_load_cal_type AND load_ci_sequence_number = p_load_cal_seq
         );
    c_other_sua_rec c_other_sua%ROWTYPE;

    CURSOR c_disc_units(cp_course_cd igs_en_stdnt_ps_att_all.course_cd%TYPE) IS
    SELECT sua.discontinued_dt
    FROM igs_En_Su_Attempt  sua
    WHERE person_id = p_student_id
    AND course_cd = cp_course_cd
    AND unit_attempt_status IN ( 'DROPPED','DISCONTIN')
    AND sua.no_assessment_ind = 'N'
    AND (sua.cal_type,sua.ci_sequence_number) IN
            ( SELECT teach_cal_type,teach_ci_sequence_number FROM igs_ca_load_to_teach_v
              WHERE load_cal_type = p_load_cal_type AND load_ci_sequence_number = p_load_cal_seq )
    ORDER BY sua.discontinued_dt DESC   ;
    c_disc_units_rec c_disc_units%ROWTYPE;
    l_inac_temp_date DATE;

  BEGIN

   l_career_profile := NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N');

  -- Check for deceased status first,as this status overrides all statuses
  -- If Decease is active
  -- fetch date and RETURN;
  OPEN c_decease_date;
  FETCH c_decease_date INTO l_G_date;
  IF c_decease_date%FOUND THEN
    -- Person is deceased
    IF (g_debug_mode) THEN
      Put_Debug_Msg('|      Returning D status and date: '||l_G_date);
    END IF;
    CLOSE c_decease_date;
    x_status_date := l_G_date;
    g_counts(17):=g_counts(17)+1;  --Increment status specific count
    RETURN 'D';
  END IF;

  CLOSE c_decease_date;


  -- Get term dates
  OPEN  c_cal_data(p_load_cal_type,p_load_cal_seq);
  FETCH c_cal_data INTO l_s_date ,
                        l_e_date ,
                        l_load_term_cd;
  CLOSE c_cal_data;


  IF (g_debug_mode) THEN
       Put_Debug_Msg('|      Calculating  enrollment status for student: '||p_student_id);
  END IF;

  -- Loop through all courses for the given acad instance and student.
   FOR c_stud_courses_rec IN c_stud_courses(p_nslc_condition,l_career_profile,l_grad_type,l_s_date, l_e_date) LOOP

        --check if pragram is valid
        l_valid_pgm := 'N';
        IF t_valid_pgms.count > 0 THEN
                FOR i in 1 .. t_valid_pgms.count LOOP
                        IF t_valid_pgms(i) = rpad(c_stud_courses_rec.course_cd,6,' ')||'-'||c_stud_courses_rec.vers THEN
                                 l_valid_pgm := 'Y';
                                 EXIT;
                        END IF;
                END LOOP;
        END IF;


        IF l_valid_pgm = 'Y' THEN

     -- Get current EFTSU points for each course and summarize , including research units.
      l_eftsu_points := IGS_EN_PRC_LOAD.ENRP_CLC_EFTSU_TOTAL(
                           p_person_id => p_student_id,
                           p_course_cd => c_stud_courses_rec.course_cd ,
                           p_acad_cal_type => p_acad_cal_type ,
                           p_acad_sequence_number => p_acad_cal_seq,
                           p_load_cal_type => p_load_cal_type,
                           p_load_sequence_number => p_load_cal_seq,
                           p_include_research_ind => 'Y' ,
                           p_key_course_cd => NULL,
                           p_key_version_number => NULL,
                           p_credit_points => l_credit_points );


     IF (g_debug_mode) THEN
         Put_Debug_Msg('|      Calculated points for course: '||c_stud_courses_rec.course_cd ||' eftsu '
                        ||l_eftsu_points ||' points: '|| l_credit_points||' course stat: '||c_stud_courses_rec.status
                        ||' compl date: '||c_stud_courses_rec.comp_dt ||' discount date: '|| c_stud_courses_rec.disc_dt);
     END IF;

     l_tot_eftsu  := l_tot_eftsu + NVL(l_eftsu_points,0);
     l_tot_points := l_tot_points + NVL(l_credit_points,0);

     -- Flags used:
     -- l_A_stat_F = Intermission with Full time at another institution
     -- l_A_stat = Intermission
     IF (NOT l_A_stat_F) THEN
             l_interm_start_dt := NULL;
             l_interm_end_dt := NULL;
             l_interm_type := NULL;
             l_A_temp_date := NULL;

                -- Step 1. (intermission)
                -- Check if an intermission exists which started in the reference term
                -- If yes then check that the student is full time at another institute. l_A_stat_F
                -- else its a simple intermission l_A_stat.
                -- status date = intermission start date.

                  -- fetch the latest intermission of the student.
                  OPEN c_interm_date (c_stud_courses_rec.course_cd, p_student_id, l_s_date, l_e_date);
                  FETCH c_interm_date INTO l_interm_start_dt, l_interm_end_dt, l_interm_type;
                  CLOSE c_interm_date;

                  IF (g_debug_mode) THEN
                    Put_Debug_Msg('|      Intermission date calculated current: '||l_interm_start_dt);
                  END IF;

                  /* Check if the student is studying in another institution.
                  If yes then return the enrollment status as 'F' */
                  IF l_interm_start_dt IS NOT NULL THEN
                        OPEN c_interm_date_study(l_interm_type);
                        FETCH c_interm_date_study INTO l_study_another_inst;
                        IF c_interm_date_study%FOUND THEN
                        --implies student is studying at another inst hence set the status to 'F'
                                l_A_stat_F := TRUE;
                        ELSE
                        --implies student is on intermission set the status to 'A'
                                 l_A_stat := TRUE;
                                 l_A_temp_date := l_interm_start_dt;
                        END IF;
                        CLOSE c_interm_date_study;
                 END IF;

                  IF l_A_date IS NULL OR (l_A_temp_date IS NOT NULL AND l_A_temp_date > l_A_date) THEN
                           l_A_date := l_A_temp_date;        --Store the date
                  END IF;


              IF ( NOT l_A_stat AND c_stud_courses_rec.status = 'COMPLETED') THEN

                -- Step 2.(Completed)
                -- Based up NSLC setup completion date will be
                ---- Course completion date
                ---- Conferral date.
                -- set l_G_Stat

                  /* Graduated status (G): COMPLETED If Completion date lies within calendar instance dates return Latest completion date */
                  /* Pickup the graduation date based on the value set in the configuration form  */
                        l_grad_date := NULL;
                          IF (l_grad_type = 'CRS_RQMNTS_COMPL_DATE' AND
                                (c_stud_courses_rec.comp_dt BETWEEN l_s_date AND l_e_date)) THEN
                             l_grad_date := c_stud_courses_rec.comp_dt;
                          ELSIF (l_grad_type = 'CONFERRAL_DATE') THEN
                            OPEN c_conferral_dt (c_stud_courses_rec.course_cd,l_s_date,l_e_date);
                            FETCH c_conferral_dt INTO l_grad_date;
                            CLOSE c_conferral_dt;
                          END IF;

                          IF l_G_date IS NULL OR (l_grad_date IS NOT NULL AND l_G_date < l_grad_date)  THEN
                                IF (g_debug_mode) THEN
                                Put_Debug_Msg('|      Setting completion date');
                                 END IF;
                                --Store the completion date
                                    l_G_date := l_grad_date;

                          END IF;

                           --set the 'G' status
                           IF l_G_date IS NOT NULL THEN
                              l_G_stat := TRUE;
                            END IF;

            -- step 3.1 (withdrawn) when status is discontinued.
            -- if student has an earlier intermission
            ---- If load was not incurred for any unit since the intermission end date
            ---- then withdrawn date will be equal to intermission start date.
            -- if student has corresspondence programs then equal to their outcome date.
            -- if no date set then equal to discontinuation date.

             ELSIF (NOT l_A_stat AND NOT l_G_stat AND
                    (c_stud_courses_rec.status ='DISCONTIN' AND c_stud_courses_rec.disc_dt
                        BETWEEN l_s_date AND l_e_date))

                THEN
                        l_W_temp_date := NULL;
                          /*Withdrawn status (W): DISCONTIN Withdrawn date within calendar instance dates
                          return latest withdrawn date */

                         /* Checking for correspondence programs and discontinued */
                         --check if the student had a previous intermission
                         OPEN c_latest_intrm(c_stud_courses_rec.course_cd,c_stud_courses_rec.disc_dt);
                         FETCH c_latest_intrm INTO l_interm_prv_start_dt,l_interm_prv_end_dt;
                         IF c_latest_intrm%FOUND THEN

                                 --student had previous intermission prior to discontinuation; chk for discontinued date
                                 --of units . If it falls between the intermission end date and prgm disc date
                                        l_load_incur := 'N';
                                     FOR c_sua_disc_rec IN c_sua_disc(c_stud_courses_rec.course_cd,l_interm_prv_end_dt,
                                                  c_stud_courses_rec.disc_dt) LOOP

                                 --check if even a single unit incurred load; if yes it implies the student returned
                                 --from intermission.
                                 --If no unit incurred load, implies there was no enrollment activity after intermission, hence student
                                --has not retnd from intermission

                                        IF IGS_EN_PRC_LOAD.ENRP_GET_LOAD_INCUR(p_cal_type =>c_sua_disc_rec.cal_type ,
                                                      p_sequence_number => c_sua_disc_rec.ci_sequence_number,
                                                      p_discontinued_dt =>c_sua_disc_rec.discontinued_dt,
                                                      p_administrative_unit_status => c_sua_disc_rec.administrative_unit_status ,
                                                      p_unit_attempt_status => c_sua_disc_rec.unit_attempt_status,
                                                      p_no_assessment_ind => c_sua_disc_rec.no_assessment_ind,
                                                      p_load_cal_type => p_load_cal_type,
                                                      p_load_sequence_number =>p_load_cal_seq,
                                                      p_uoo_id => c_sua_disc_rec.uoo_id,
                                                      p_include_audit => 'Y') = 'Y' THEN

                                                         l_load_incur := 'Y';
                                                         EXIT;
                                        END IF;
                                     END LOOP;

                                    IF l_load_incur = 'N' THEN
                                      l_W_temp_date := l_interm_prv_start_dt;
                                    END IF;
                        END IF;
                        CLOSE c_latest_intrm;


                         IF l_W_temp_date IS  NULL THEN
                               ----implies student had no intermission or retnd from intermission hence set the
                                 --'w' date as the discontin date. check for correspondance pgms.
                                OPEN c_corresp_prg(c_stud_courses_rec.course_cd,c_stud_courses_rec.vers);
                                FETCH c_corresp_prg INTO l_corresp_prg;
                                CLOSE c_corresp_prg;

                                IF l_corresp_prg IS NOT NULL THEN
                                        c_outcome_dt_rec := NULL;
                                        OPEN c_outcome_dt(c_stud_courses_rec.course_cd);
                                        FETCH  c_outcome_dt INTO c_outcome_dt_rec ;
                                        CLOSE c_outcome_dt;

                                        IF l_outcome_dt IS NULL OR l_outcome_dt < c_outcome_dt_rec.outcome_dt THEN
                                         l_outcome_dt := nvl(c_outcome_dt_rec.outcome_dt,c_stud_courses_rec.disc_dt);

                                        END IF;


                                        l_W_temp_date := l_outcome_dt;
                                /* for all other casees return discontinued date */
                                ELSE
                                        l_W_temp_date := c_stud_courses_rec.disc_dt;
                                END IF;
                           END IF;


                        IF l_W_date IS NULL OR(l_W_temp_date is NOT NULL AND l_W_date < l_W_temp_date ) THEN
                           IF (g_debug_mode) THEN
                              Put_Debug_Msg('|      Withdrawn date calculated : '||l_W_date);
                            END IF;
                       --Store the completion date
                               l_W_date := l_W_temp_date;
                        END IF;
                        --set the W status
                        IF l_W_date  is not null then
                                l_W_stat := TRUE;
                         END IF;
                        l_corresp_prg := NULL;

            -- step 3.2 (withdrawn) when status is Lapsed
            -- if student has an earlier intermission
            ---- If load was not incurred for any unit since the intermission end date
            ---- then withdrawn date will be equal to intermission start date.
            -- if no date set then equal to Lapsed date.

             ELSIF (NOT l_A_stat AND NOT l_G_stat AND
                  (c_stud_courses_rec.status ='LAPSED' AND c_stud_courses_rec.lapsed_dt BETWEEN l_s_date AND l_e_date)) THEN

                        l_lp_temp_date := NULL;

                 --check if the student had a previous intermission
                 OPEN c_latest_intrm(c_stud_courses_rec.course_cd,c_stud_courses_rec.lapsed_dt);
                 FETCH c_latest_intrm INTO l_interm_prv_start_dt,l_interm_prv_end_dt;
                 IF c_latest_intrm%FOUND THEN

                         --student had previous intermission prior to lapse; chk for discontinued date
                         --of units . If it falls between the intermission end date and prgm lapse date

                                l_load_incur := 'N';

                        FOR c_sua_disc_rec IN c_sua_disc(c_stud_courses_rec.course_cd,l_interm_end_dt,
                                        c_stud_courses_rec.lapsed_dt) LOOP

                         -- chk if any unit incurred load implying the student has returned from intermission.
                          IF IGS_EN_PRC_LOAD. ENRP_GET_LOAD_INCUR(p_cal_type =>c_sua_disc_rec.cal_type ,
                                p_sequence_number => c_sua_disc_rec.ci_sequence_number,
                                p_discontinued_dt =>c_sua_disc_rec.discontinued_dt,
                                p_administrative_unit_status => c_sua_disc_rec.administrative_unit_status ,
                                p_unit_attempt_status => c_sua_disc_rec.unit_attempt_status,
                                p_no_assessment_ind => c_sua_disc_rec.no_assessment_ind,
                                p_load_cal_type => p_load_cal_type,
                                p_load_sequence_number =>p_load_cal_seq,
                                p_uoo_id => c_sua_disc_rec.uoo_id,
                                p_include_audit => 'Y') = 'Y' THEN

                                l_load_incur := 'Y';
                                 EXIT;
                          END IF;
                          END LOOP;

                        IF l_load_incur = 'N' THEN
                          l_lp_temp_date := l_interm_prv_start_dt;
                         END IF;
                 END IF;
                 CLOSE c_latest_intrm;

                         --implies student retnd from intermission
                         IF l_lp_temp_date IS NULL THEN
                            l_lp_temp_date := c_stud_courses_rec.lapsed_dt;
                         END IF;



                        IF l_W_date IS NULL OR l_W_date < l_lp_temp_date  THEN
                           IF (g_debug_mode) THEN
                              Put_Debug_Msg('|      Withdrawn date calculated: '||l_W_date);
                           END IF;

                         --Store the completion date
                                l_W_date := l_lp_temp_date;
                        END IF;
                      IF l_W_date  is not null then
                        l_W_stat := TRUE;
                        END IF;

            -- step 3.3 (withdrawn)
            -- no enrolled attempts in it.
            -- date when the last unit was discontinued

            ELSIF (NOT l_A_stat AND NOT l_G_stat  ) THEN

                l_inac_temp_date := NULL;

		        -- if there are non audited dropped/discontinued unit attempts in this term
                  OPEN c_disc_units (c_stud_courses_rec.course_cd);
                  FETCH c_disc_units INTO c_disc_units_rec;
                  IF c_disc_units%FOUND  THEN
                      l_inac_temp_date := c_disc_units_rec.discontinued_dt ;
                    -- if there are no other non dropped unit attempts in this term
                    OPEN c_other_sua(c_stud_courses_rec.course_cd);
                    FETCH c_other_sua INTO c_other_sua_rec;
                    IF c_other_sua%NOTFOUND THEN
                         IF l_W_date IS NULL OR l_W_date < l_inac_temp_date  THEN
                           -- since all units have been dropped, this program is withdrawn
                                IF (g_debug_mode) THEN
                                          Put_Debug_Msg('|      Inactive Withdrawn date calculated: '||l_inac_temp_date);
                                 END IF;
                                l_W_date := l_inac_temp_date ;
                            -- set the withdrawn status
                          END IF;
                          IF l_W_date  IS NOT NULL THEN
                                l_W_stat := TRUE;
                          END IF;
                    END IF;
                    CLOSE c_other_sua;
                  END IF;
                  CLOSE c_disc_units;


              END IF; --end of prgram attempt status conditions

     END IF ;/* l_A_stat_F */

     /* Anticipated Graduation Date */

       l_temp_ant_grad_date := igs_en_gen_015.enrf_drv_cmpl_dt (
          p_person_id       => p_student_id,
          p_course_cd       => c_stud_courses_rec.course_cd,
          p_achieved_cp     => l_credit_points,
          p_attendance_type => l_attendance_type,
          p_load_cal_type   => l_load_cal_type,
          p_load_ci_seq_num => l_load_cal_seq,
          p_load_ci_alt_code => l_load_term_cd,
          p_load_ci_start_dt => l_s_date,
          p_load_ci_end_dt  => l_e_date,
          p_message_name    => l_message_name
        );


             IF l_ant_grad_date IS NULL OR  l_ant_grad_date < l_temp_ant_grad_date THEN
                l_ant_grad_date := l_temp_ant_grad_date;
             END IF;
       END IF; -- end of if that checks for valid programs
   END LOOP; -- pgms loop

/* Graduate Level Indicator */
-- A student is sonsidered as graduate if all his prpgram attempts in the
--CALENDAR year in which the acad cal for which the job is run are
--graduate programs.

--first fetch the year in which the acad cal falls
open cur_strt_date(p_acad_cal_type,p_acad_cal_seq );
fetch cur_strt_date INTO l_start_date;
close cur_strt_date;

l_start_year := substr(l_start_date,7);
l_non_grad_lvl := 'N';
--fetch all the academic calendars that start or end in the calendar year

FOR acad_cal_rec in acad_cal(l_start_year) loop
    --fetch all subordinate load calendars
    FOR load_cal_rec in c_load_cal_instance(acad_cal_rec.cal_type,acad_cal_rec.sequence_number) loop
          --fetch all progrms from spa_terms for the cal inst and person id
          --check if any program is not of type graduate. if found hten return fals for graduate ind.
           FOR cur_spa_rec in cur_spa(acad_cal_rec.cal_type,load_cal_rec.cal_type,load_cal_rec.sequence_number) loop
               IF   l_non_grad_lvl <> 'Y' THEN
                 OPEN c_grad_lvl(cur_spa_rec.course_cd, cur_spa_rec.version_number);
                 FETCH c_grad_lvl INTO c_grad_lvl_rec;
                 IF c_grad_lvl%NOTFOUND THEN
                    l_non_grad_lvl := 'Y';
                END IF;
                CLOSE c_grad_lvl;
              END IF;
           END LOOP;
     END LOOP;
  END LOOP;

  IF l_non_grad_lvl = 'Y' THEN
    --implies undergraduate pgms attempted hence not a graduate.
    x_grad_level := 'N';
 ELSE
 x_grad_level := 'Y';
 END IF;

   x_credit_points := l_tot_points;
   x_ant_grad_date := l_ant_grad_date;

   IF (g_debug_mode) THEN
       Put_Debug_Msg('|      Calculating attendance type eftsu: '||l_tot_eftsu);
   END IF;

   l_enr_status := IGS_EN_PRC_LOAD.ENRP_GET_LOAD_ATT (
                           p_load_cal_type => p_load_cal_type ,
                           p_load_figure => l_tot_eftsu
                   );

   IF (g_debug_mode) THEN
       Put_Debug_Msg('|      Status returned: '||l_enr_status);
   END IF;

   -- Convert enrollment status according to the set up table: c_enr_status

   OPEN c_enr_status (l_enr_status) ;
   FETCH c_enr_status INTO l_stat;
   CLOSE c_enr_status;

   IF (g_debug_mode) THEN
       Put_Debug_Msg('|      Enrollemt type returned: '||l_stat);
   END IF;



  IF l_A_stat_F THEN
     g_counts(10):=g_counts(10)+1;  --Increment status specific count
     RETURN 'F';

   ELSIF l_A_stat THEN
     IF (g_debug_mode) THEN
        Put_Debug_Msg('|      Returning A status and date: '||l_A_date);
     END IF;
     x_status_date := l_A_date;
     g_counts(15):=g_counts(15)+1;  --Increment status specific count
     RETURN 'A';

   -- Check if one of the statuses is still applicable
   ELSIF l_G_stat THEN
     IF (g_debug_mode) THEN
        Put_Debug_Msg('|      Returning G status and date: '||l_G_date);
     END IF;
     x_status_date := l_G_date;
     g_counts(14):=g_counts(14)+1;  --Increment status specific count
     RETURN 'G';

   ELSIF l_W_stat THEN
     IF (g_debug_mode) THEN
        Put_Debug_Msg('|      Returning W status and date: '||l_W_date);
     END IF;
     x_status_date := l_W_date;
     g_counts(13):=g_counts(13)+1;  --Increment status specific count
     RETURN 'W';
   ELSIF l_stat IS NOT NULL THEN

     IF l_stat = 'F' THEN
        g_counts(10):=g_counts(10)+1;  --Increment status specific count
     ELSIF l_stat = 'H' THEN
        g_counts(11):=g_counts(11)+1;  --Increment status specific count
     ELSIF l_stat = 'L' THEN
        g_counts(12):=g_counts(12)+1;  --Increment status specific count
     END IF;
     RETURN l_stat;

   END IF;

   RETURN NULL;

END Get_Enrollment_Status;



/******************************************************************************/

FUNCTION Get_Status_Change_Date (
 p_student_id        IN igs_pe_person.person_id%TYPE,
 p_old_status        IN VARCHAR2,
 p_new_status        IN VARCHAR2,
 p_load_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_load_cal_seq      IN igs_ca_inst.sequence_number%TYPE,
 p_acad_cal_type     IN igs_ca_inst.cal_type%TYPE,
 p_acad_cal_seq      IN igs_ca_inst.sequence_number%TYPE
) RETURN DATE
-------------------------------------------------------------------------------------------
--Change History:
--Who         When            What
--jbegum      25-Jun-2003     BUG#2930935
--                            Modified cursor c_unit_cp
--kkillams    02-05-2003      Modified c_hist_units and c_orig_units cursor where clause due
--                            to change in pk of the student unit attempt w.r.t. bug number 2829262
--svanukur       09-jan-2005    Modified the logic of the procedure to calculate teh status change date.
-- ckasu      06-MAR-2006     Modified cursor c_drop_units as a prt of bug 5073484 inorder to resolve
--                            Sharabale Memory issue.
-- The procedure first determines the current eftsu of all unit attempts of a student excluding unconfirm
--SUA. It then loops through each history record and compares with the previous history record. The change in CP
--and eftsu is determined and the diff is calculated. This diff is then progressively subtracted from the current eftsu
--and the the record for which the difference exceeds the threshold is the record that caused the status change.
-- The history end date of this record is the status change date.
-------------------------------------------------------------------------------------------
IS

 l_thresh_eftsu   NUMBER;
 l_prev_eftsu     NUMBER;
 l_cur_eftsu      NUMBER := 0;
 l_loc_eftsu      NUMBER;
 l_loc_point      NUMBER;
 l_new_eftsu      NUMBER;
 l_new_points     NUMBER;
 l_old_eftsu      NUMBER;
 l_old_points     NUMBER;
 l_diff_eftsu     NUMBER;
 l_diff_points    NUMBER;
 l_sign           NUMBER;
 l_status         VARCHAR2(20);

 l_teach_cal_type igs_en_su_attempt.cal_type%TYPE;
 l_ci_seq_num     igs_en_su_attempt.ci_sequence_number%TYPE;
 l_discont_dt     igs_en_su_attempt.discontinued_dt%TYPE;
 l_adm_status     igs_en_su_attempt.administrative_unit_status%TYPE;
 l_unt_atmpt_stat igs_en_su_attempt.unit_attempt_status%TYPE;


 CURSOR c_thresh_limit IS
  SELECT lower_enr_load_range
     FROM igs_en_atd_type_load
    WHERE
    cal_type = p_load_cal_type
      AND attendance_type in (select opt_val from
      igs_En_nsc_options where opt_type = 'ENR_STAT_'||p_old_status)
      order by lower_enr_load_range;

 --List of all courses for the given load term
 CURSOR c_all_units IS
    SELECT DISTINCT
           ut.course_cd ,
           pr.version_number cr_ver_number ,
           ut.unit_cd ,
           ut.version_number unit_ver_number,
           ut.cal_type teach_cal_type,
           ut.ci_sequence_number teach_seq_number ,
           ut.uoo_id  uoo_id,
           ut.override_enrolled_cp override_enrolled_cp,
           ut.override_eftsu override_eftsu
      FROM igs_en_su_attempt ut,
       igs_en_stdnt_ps_att pr,
       igs_ps_ver vers
     WHERE (ut.cal_type,ut.ci_sequence_number) IN
              (SELECT teach_cal_type,
                      teach_ci_sequence_number
                 FROM igs_ca_load_to_teach_v
                WHERE load_cal_type = p_load_cal_type
                      AND load_ci_sequence_number = p_load_cal_seq
               )
           AND ut.person_id = p_student_id
           AND ut.course_cd = pr.course_cd
           AND ut.person_id = pr.person_id
           AND pr.cal_type = p_acad_cal_type
           AND pr.course_attempt_status IN ('COMPLETED', 'ENROLLED', 'INACTIVE', 'INTERMIT','DISCONTIN')
           AND (vers.generic_course_ind = g_include_gen OR g_include_gen = 'Y')
           AND pr.course_cd = vers.course_cd
           AND vers.version_number = pr.version_number ;
  --       AND vers.responsible_org_unit_cd = pr_branch_id;

 -- added by ckasu as a prt of bug 5073484.
 CURSOR c_get_teach_cal_dtls IS
 SELECT teach_cal_type,
        teach_ci_sequence_number
 FROM   igs_ca_load_to_teach_v
 WHERE  load_cal_type = p_load_cal_type
 AND load_ci_sequence_number = p_load_cal_seq;


  -- modified by ckasu as a prt of bug 5073484.
  -- List of all history units

 CURSOR c_drop_units(p_teach_cal_type  IGS_CA_INST.cal_type%TYPE,
                     p_teach_ci_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
 SELECT ut.course_cd ,
           pr.version_number cr_ver_number ,
           ut.unit_cd ,
           ut.version_number unit_ver_number,
           ut.cal_type teach_cal_type,
           ut.ci_sequence_number teach_seq_number ,
           ut.override_enrolled_cp ,
           ut.override_eftsu ,
           ut.hist_end_dt,
           ut.no_assessment_ind,
           ut.uoo_id,
           ut.administrative_unit_status,
           ut.unit_attempt_status,
           ut.discontinued_dt
 FROM igs_en_su_attempt_h ut,
           igs_en_stdnt_ps_att pr,
           igs_ps_ver vers
 WHERE ut.cal_type = p_teach_cal_type
       AND ut.ci_sequence_number = p_teach_ci_sequence_number
       AND ut.person_id = p_student_id
       AND ut.course_cd = pr.course_cd
       AND ut.person_id = pr.person_id
       AND pr.cal_type = p_acad_cal_type
       AND pr.course_attempt_status IN ('COMPLETED', 'ENROLLED', 'INACTIVE', 'INTERMIT','DISCONTIN')
       AND (vers.generic_course_ind = g_include_gen OR g_include_gen = 'Y')
       AND pr.course_cd = vers.course_cd
       AND vers.version_number = pr.version_number
 ORDER BY hist_end_dt DESC;


 -- This cursor selects next history record from the table (if any) to compare enrollment points.

 CURSOR c_hist_units(p_c_course_cd      VARCHAR2,
                     p_c_uoo_id         NUMBER,
                     p_c_hist_end_dt    DATE ) IS
    SELECT ut.override_eftsu,
    ut.override_enrolled_cp ,
    ut.cal_type,
         ut.ci_sequence_number  ,
          ut.discontinued_dt,
          ut.administrative_unit_status,
          ut.unit_attempt_status,
          ut.no_assessment_ind,
	  ut.hist_end_dt
      FROM igs_en_su_attempt_h ut
     WHERE     ut.person_id = p_student_id
           AND ut.course_cd = p_c_course_cd
           AND ut.uoo_id = p_c_uoo_id
           AND ut.hist_end_dt > p_c_hist_end_dt
     ORDER BY ut.hist_end_dt;
  old_hist_end_dt igs_en_su_attempt_h.hist_end_dt%TYPE;
 -- get the next history record whose assessment_ind is not null
 CURSOR c_next_ass_ind (p_c_course_cd      VARCHAR2,
                     p_c_uoo_id         NUMBER,
                     p_c_hist_end_dt    DATE  ) IS
     SELECT    ut.no_assessment_ind
     FROM igs_en_su_attempt_h ut
     WHERE     ut.person_id = p_student_id
           AND ut.course_cd = p_c_course_cd
           AND ut.uoo_id = p_c_uoo_id
           AND ut.hist_end_dt > p_c_hist_end_dt
	   AND ut.no_assessment_ind IS NOT NULL
     ORDER BY ut.hist_end_dt;
	old_next_ass_ind igs_en_su_attempt_all.no_assessment_ind%TYPE;
	new_next_ass_ind igs_en_su_attempt_all.no_assessment_ind%TYPE;

 -- This cursor selects current record to compare enrollment points.

 CURSOR c_orig_units(p_c_course_cd VARCHAR2,
                     p_c_uoo_id VARCHAR2) IS
    SELECT  ut.override_eftsu ,
            ut.override_enrolled_cp ,
            ut.cal_type,
            ut.ci_sequence_number  ,
           ut.discontinued_dt,
           ut.administrative_unit_status,
           ut.unit_attempt_status,
           ut.no_assessment_ind
      FROM igs_en_su_attempt ut
     WHERE     ut.person_id = p_student_id
           AND ut.course_cd = p_c_course_cd
           AND ut.uoo_id = p_c_uoo_id;
   c_sua_rec c_orig_units%ROWTYPE;
  --Credit points at the unit level - need to get and compare.

  CURSOR c_unit_cp( cp_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
    SELECT NVL(cps.enrolled_credit_points,uv.enrolled_credit_points)
    FROM igs_ps_unit_ver uv,
         igs_ps_usec_cps cps,
         igs_ps_unit_ofr_opt uoo
    WHERE uoo.uoo_id = cps.uoo_id(+) AND
          uoo.unit_cd = uv.unit_cd AND
          uoo.version_number = uv.version_number AND
          uoo.uoo_id = cp_uoo_id;

CURSOR c_uv( cp_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
SELECT uoo.version_number
FROM igs_ps_unit_ofr_opt uoo
WHERE uoo.uoo_id = cp_uoo_id;

l_unit_version NUMBER;
old_load_incur varchar2(1);
new_load_incur varchar2(1);

          old_teach_cal_type igs_en_su_Attempt.cal_type%TYPE;
          old_teach_seq_number  igs_en_su_Attempt.ci_sequence_number%TYPE;
          old_discontinued_dt igs_en_su_Attempt.discontinued_dt%TYPE;
          old_administrative_unit_status igs_en_su_Attempt.administrative_unit_status%TYPE;
          old_unit_attempt_status igs_en_su_Attempt.unit_attempt_status%TYPE;
          old_no_assessment_ind igs_en_su_Attempt.no_assessment_ind%TYPE;

BEGIN

   -- Get the current status minimum - this is the threshold level.
   OPEN c_thresh_limit;
   FETCH c_thresh_limit INTO l_thresh_eftsu;
   CLOSE c_thresh_limit;

   IF (g_debug_mode) THEN
       Put_Debug_Msg('|      Calculating status change date, threshhold is: '||l_thresh_eftsu);
   END IF;


   FOR c_all_units_rec IN c_all_units LOOP
   -- Get current eftsu and calculate

      IF (g_debug_mode) THEN
          Put_Debug_Msg('|      Calculating EFTSU for unit:  course: '||c_all_units_rec.course_cd
                         ||' c vers '||c_all_units_rec.cr_ver_number
                         ||' unit '||c_all_units_rec.unit_cd
                         ||' u vers '||c_all_units_rec.unit_ver_number
                         ||' teach cal '||c_all_units_rec.teach_cal_type
                         ||' seq '||c_all_units_rec.teach_seq_number
                         ||' uoo '||c_all_units_rec.uoo_id
                         ||' enr points '||c_all_units_rec.override_enrolled_cp
                         ||' eftsu '||c_all_units_rec.override_eftsu );
      END IF;

      l_cur_eftsu := l_cur_eftsu +
                    NVL(IGS_EN_PRC_LOAD.ENRP_CLC_SUA_EFTSU(
                        p_person_id => p_student_id ,
                        p_course_cd => c_all_units_rec.course_cd ,
                        p_crv_version_number => c_all_units_rec.cr_ver_number ,
                        p_unit_cd => c_all_units_rec.unit_cd ,
                        p_unit_version_number => c_all_units_rec.unit_ver_number,
                        p_teach_cal_type =>  c_all_units_rec.teach_cal_type,
                        p_teach_sequence_number => c_all_units_rec.teach_seq_number ,
                        p_uoo_id => c_all_units_rec.uoo_id  ,
                        p_load_cal_type => p_load_cal_type,
                        p_load_sequence_number => p_load_cal_seq,
                        p_override_enrolled_cp => c_all_units_rec.override_enrolled_cp ,
                        p_override_eftsu => c_all_units_rec.override_eftsu ,
                        p_sca_cp_total => NULL ,
                        p_key_course_cd   => NULL,
                        p_key_version_number  => NULL,
                        p_credit_points => l_loc_point,
                        p_include_audit =>'N'),0);

      IF (g_debug_mode) THEN
          Put_Debug_Msg('|      Returned EFTSU: '||l_cur_eftsu);
      END IF;

   END LOOP;

   FOR c_get_teach_cal_dtls_rec IN c_get_teach_cal_dtls LOOP

    FOR c_drop_units_rec IN c_drop_units(c_get_teach_cal_dtls_rec.teach_cal_type,c_get_teach_cal_dtls_rec.teach_ci_sequence_number) LOOP

      IF (g_debug_mode) THEN
          Put_Debug_Msg('|      History loop unit found: course'||c_drop_units_rec.course_cd
                         ||' c vers '||c_drop_units_rec.cr_ver_number
                         ||' unit '||c_drop_units_rec.unit_cd
                         ||' u vers '||c_drop_units_rec.unit_ver_number
                         ||' teach cal '||c_drop_units_rec.teach_cal_type
                         ||' seq '||c_drop_units_rec.teach_seq_number
                         ||' uoo id '||c_drop_units_rec.uoo_id
                         ||' enr points '||c_drop_units_rec.override_enrolled_cp
                         ||' eftsu '||c_drop_units_rec.override_eftsu);
      END IF;

         -- Checking the current record
         OPEN c_orig_units(c_drop_units_rec.course_cd ,
                           c_drop_units_rec.uoo_id);

         FETCH c_orig_units INTO c_sua_rec;
	 CLOSE c_orig_units;

      --Initalize status
      l_status := '';

      --Checking if there is a history record available
      OPEN c_hist_units(c_drop_units_rec.course_cd ,
                        c_drop_units_rec.uoo_id,
                        c_drop_units_rec.hist_end_dt);

      FETCH c_hist_units INTO l_old_eftsu,l_old_points,old_teach_cal_type,
          old_teach_seq_number  ,
          old_discontinued_dt,
          old_administrative_unit_status,
          old_unit_attempt_status,
          old_no_assessment_ind,
	  old_hist_end_dt;

      IF (g_debug_mode) THEN
          Put_Debug_Msg('|      Fetching prev history eftsu: '||l_old_eftsu||' cred points'||l_old_points||' date '||c_drop_units_rec.hist_end_dt);
      END IF;

      IF c_hist_units%NOTFOUND THEN

         -- override with the sua record values
          l_old_eftsu := c_sua_rec.override_eftsu ;
	      l_old_points := c_sua_rec.override_enrolled_cp ;
	      old_teach_cal_type := c_sua_rec.cal_type ;
          old_teach_seq_number := c_sua_rec.ci_sequence_number ;
          old_discontinued_dt := c_sua_rec.discontinued_dt ;
          old_administrative_unit_status := c_sua_rec.administrative_unit_status ;
          old_unit_attempt_status:= c_sua_rec.unit_attempt_status ;
          old_no_assessment_ind := c_sua_rec.no_assessment_ind ;



         IF (g_debug_mode) THEN
             Put_Debug_Msg('|      Fetching prev NON history eftsu: '||l_old_eftsu||' cred points'||l_old_points||' status '||old_unit_attempt_status);
         END IF;

      END IF;

      CLOSE c_hist_units;

      l_new_eftsu := c_drop_units_rec.override_eftsu;
      l_new_points := c_drop_units_rec.override_enrolled_cp;

      --IF any of them nulls we need to get amount from unit level to compare

      IF l_new_eftsu IS NULL AND l_new_points IS NULL THEN
        IF c_drop_units_rec.no_assessment_ind IS NULL THEN
        --get the non null ass_id from history . If all history records
        --are null then assign the sua value
	        new_next_ass_ind := NULL;
             OPEN c_next_ass_ind(c_drop_units_rec.course_cd ,c_drop_units_rec.uoo_id,c_drop_units_rec.hist_end_dt);
	        FETCH c_next_ass_ind INTO new_next_ass_ind;
	        CLOSE c_next_ass_ind;
	        -- if no other later history records exist with not null value for assessment_ind
	        -- then use SUA which is the latest value
	        new_next_ass_ind := NVL(new_next_ass_ind,c_sua_rec.no_assessment_ind);
	    END IF;

        IF NVL(c_drop_units_rec.no_assessment_ind, new_next_ass_ind) = 'Y' OR
            c_drop_units_rec.unit_attempt_status = 'DROPPED'THEN
	        l_new_points := 0;
            Put_Debug_Msg('|      Assigning 0 to new points: '||l_new_points);
	    ELSE
             OPEN c_unit_cp (c_drop_units_rec.uoo_id);
             FETCH c_unit_cp INTO l_new_points;
             CLOSE c_unit_cp;
             IF (g_debug_mode) THEN
                Put_Debug_Msg('|      Assigning points from unit level to new points: '||l_new_points);
             END IF;
         END IF;

      END IF;

      IF l_old_eftsu IS NULL AND l_old_points IS NULL THEN
        IF old_no_assessment_ind IS NULL THEN
        --get the non null ass_id from history . If all history records
        --are null then assign the sua value
	        old_next_ass_ind := NULL;
             OPEN c_next_ass_ind(c_drop_units_rec.course_cd ,c_drop_units_rec.uoo_id,old_hist_end_dt);
	        FETCH c_next_ass_ind INTO old_next_ass_ind;
	        CLOSE c_next_ass_ind;
	         -- if no other later history records exist with not null value for assessment_ind
	         -- then use SUA which is the latest value
	         old_next_ass_ind := NVL(old_next_ass_ind,c_sua_rec.no_assessment_ind);
	    END IF;
	    IF NVL(old_no_assessment_ind, old_next_ass_ind) = 'Y' OR
           old_unit_attempt_status = 'DROPPED' THEN
	        l_old_points := 0;
            Put_Debug_Msg('|      Assigning 0 to old points: '||l_old_points);
	    ELSE
             OPEN c_unit_cp (c_drop_units_rec.uoo_id);
             FETCH c_unit_cp INTO l_old_points;
             CLOSE c_unit_cp;
             IF (g_debug_mode) THEN
                 Put_Debug_Msg('|      Assigning points from unit level to old points: '||l_old_points);
             END IF;
         END IF;

      END IF;

      l_diff_eftsu  := NVL(l_old_eftsu,0) - NVL(l_new_eftsu,0);
      l_diff_points  := NVL(l_old_points,0) - NVL(l_new_points,0);

























      IF l_diff_eftsu = 0 and l_diff_points = 0 then
        -- Comparing original value with the current one
--if diff between cp and eftsu is null, check if the units incur load.
--in both the cases, if the current record has a null value for no_Assessment_ind
--or unit_Attempt_Status , pass the value derived above by looping thru history or SUA.


         new_load_incur :=   igs_en_prc_load.enrp_get_load_incur(
          c_drop_units_rec.teach_cal_type,
          c_drop_units_rec.teach_seq_number  ,
          c_drop_units_rec.discontinued_dt,
          c_drop_units_rec.administrative_unit_status,
          nvl(c_drop_units_rec.unit_attempt_status,old_unit_attempt_status),
          NVL(c_drop_units_rec.no_assessment_ind, new_next_ass_ind),
          p_load_cal_type,
          p_load_cal_seq,
          c_drop_units_rec.uoo_id
                    ) ;

         old_load_incur := igs_en_prc_load.enrp_get_load_incur(
          old_teach_cal_type,
          old_teach_seq_number  ,
          old_discontinued_dt,
          old_administrative_unit_status,
          old_unit_attempt_status,
          NVL(old_no_assessment_ind, old_next_ass_ind),
          p_load_cal_type,
          p_load_cal_seq,
          c_drop_units_rec.uoo_id
                    ) ;

          Put_Debug_Msg('new_load_incur'|| new_load_incur);
          Put_Debug_Msg('old_load_incur'|| old_load_incur);

           IF old_load_incur = 'Y' and new_load_incur = 'N' THEN
            l_diff_eftsu := l_new_eftsu;
            l_diff_points := l_new_points;
           ELSIF  old_load_incur = 'N' and new_load_incur = 'Y' THEN
            l_diff_eftsu := 0 - l_new_eftsu;
            l_diff_points := 0 - l_new_points;
           END if;

      END IF;

      IF (g_debug_mode) THEN
          Put_Debug_Msg('|      Amount of changed because of action: eftsu '||l_diff_eftsu||' points '|| l_diff_points );
      END IF;

      -- Get changes in eftsu and calculate

      IF l_diff_eftsu <> 0 OR l_diff_points <> 0 THEN

         --Make null values to avoid confusion in the function

         IF l_diff_eftsu = 0 THEN
            l_diff_eftsu := NULL;
         END IF;

         IF l_diff_points = 0 THEN
            l_diff_points := NULL;
         END IF;

        IF c_drop_units_rec.unit_ver_number IS NULL THEN
                OPEN c_uv(c_drop_units_rec.uoo_id);
                FETCH c_uv into l_unit_version;
                CLOSE c_uv;
        END IF;

--calculate eftsu of the difference and subtract this from the current eftsu
--calculated at the beginning. Progressively subtract the difference
-- and check with the threshold value to determine the date on which the eftsu exceeded the
--threshold
         l_loc_eftsu := NVL(IGS_EN_PRC_LOAD.ENRP_CLC_SUA_EFTSU(
                            p_person_id => p_student_id ,
                            p_course_cd => c_drop_units_rec.course_cd ,
                            p_crv_version_number => c_drop_units_rec.cr_ver_number ,
                            p_unit_cd => c_drop_units_rec.unit_cd ,
                            p_unit_version_number => nvl(c_drop_units_rec.unit_ver_number,l_unit_version),
                            p_teach_cal_type => c_drop_units_rec.teach_cal_type,
                            p_teach_sequence_number => c_drop_units_rec.teach_seq_number ,
                            p_uoo_id => c_drop_units_rec.uoo_id ,
                            p_load_cal_type => p_load_cal_type,
                            p_load_sequence_number => p_load_cal_seq,
                            p_override_enrolled_cp => l_diff_points ,
                            p_override_eftsu => l_diff_eftsu ,
                            p_sca_cp_total => NULL ,
                            p_key_course_cd   => NULL,
                            p_key_version_number  => NULL,
                            p_credit_points => l_loc_point,
                            p_include_audit =>'N'),0);

         IF (g_debug_mode) THEN
             Put_Debug_Msg('|      Calculated by API eftsu '||l_loc_eftsu||' points '|| l_loc_point);
         END IF;

         -- Decrease the total amount of the enrolled credit points for the student by the current unit EFTSU change.
        l_cur_eftsu := l_cur_eftsu - l_loc_eftsu;







         -- Compare the new amount to the threshold level. If its greater then continue the loop

         IF (g_debug_mode) THEN
             Put_Debug_Msg('|      New eftsu value eftsu '||l_cur_eftsu);
         END IF;

         IF l_cur_eftsu > l_thresh_eftsu THEN
            IF (g_debug_mode) THEN
                Put_Debug_Msg('|      Threshhold reached, returning date: '||c_drop_units_rec.hist_end_dt);
            END IF;
            RETURN c_drop_units_rec.hist_end_dt;
         END IF;
      END IF; -- end of IF l_diff_eftsu <> 0 OR l_diff_points <> 0

    END LOOP;

   END LOOP;-- end of c_get_teach_cal_dtls_rec FOR LOOP
   RETURN NULL;

END Get_Status_Change_Date;



  PROCEDURE Put_Debug_Msg (
    p_debug_message IN VARCHAR2
  ) IS
   l_api_name             CONSTANT VARCHAR2(30)   := 'Put_Debug_Msg';

  BEGIN

    fnd_file.put_line(FND_FILE.LOG,p_debug_message);
    END Put_Debug_Msg;

FUNCTION org_alt_check (p_org_id VARCHAR2)
RETURN VARCHAR2 IS

  CURSOR c_alt_id IS
    SELECT org_structure_id
    FROM igs_or_org_alt_ids alt, igs_or_org_alt_idtyp types
    WHERE alt.org_structure_id=p_org_id
    AND NVL(alt.end_date, SYSDATE) >= SYSDATE
    AND NVL(alt.start_date,SYSDATE) <= SYSDATE
    AND alt.org_alternate_id_type = types.org_alternate_id_type
    AND types.system_id_type ='NSC_BRANCH';

  l_alt_id c_alt_id%ROWTYPE ;

BEGIN
  l_alt_id.org_structure_id:=NULL;
  OPEN c_alt_id;
  FETCH c_alt_id INTO l_alt_id;
  CLOSE c_alt_id;
  RETURN l_alt_id.org_structure_id;
END org_alt_check ;

END IGS_EN_NSC_PKG;

/
