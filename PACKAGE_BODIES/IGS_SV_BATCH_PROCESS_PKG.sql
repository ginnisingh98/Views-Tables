--------------------------------------------------------
--  DDL for Package Body IGS_SV_BATCH_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SV_BATCH_PROCESS_PKG" AS
/* $Header: IGSSV01B.pls 120.25 2006/07/28 14:31:42 prbhardw noship $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Don Shellito

 Date Created By    : Oct-01-2002

 Purpose            : This package is to be used for the processing and
                      gathering of the SEVIS related information that is
                      to be sent for transmital.

                      The concurrent programs that are to be executed are
                      defined globally.  All other procedures are to be
                      defined internally.

 remarks            : None

 Change History

Who                   When           What
-----------------------------------------------------------
Arkadi Tereshenkov    Oct-14-2002    New Package created.
pkpatel               23-APR-2003    Bug 2908378(Solved Multiple Issues)
gmaheswa              12-Nov-2003    Bug 3227107 address related changes
pkpatel               4-Dec-2003     Bug 3227107 (Used the status column for address in Validate_Site_Info)
ssaleem               13-Apr-2005    Bug 4293911 Fnd User customer Id  replaced with person
		                     party id
******************************************************************/

/*************** Values from addresses    bug #2630743***********************************
SEVIS_PRIMARY_US - SEVIS Primary US Address/SEVIS Primary Address in  United States
SEVIS_PRIMARY_FOREIGN - SEVIS Primary Foreign Address/SEVIS Primary  Address outside of United States
SEVIS_SITE_OF_ACTIVITY - SEVIS Site of Activity/SEVIS Site of Activity
***********************************************************************************/

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'IGS_SV_BATCH_PROCESS_PKG';
g_us_addr_usage    CONSTANT VARCHAR2(30) := 'SEVIS_PRIMARY_US';
g_f_addr_usage     CONSTANT VARCHAR2(30) := 'SEVIS_PRIMARY_FOREIGN';
g_site_addr_usage  CONSTANT VARCHAR2(30) := 'SEVIS_SITE_OF_ACTIVITY';
g_school_sevis_id  CONSTANT VARCHAR2(30) := 'SV_SCH_CD';
g_person_sevis_id  CONSTANT VARCHAR2(30) := 'SEVIS_ID';
g_sch_p_sevis_id   CONSTANT VARCHAR2(30) := 'SV_PRG_CD';
g_block_mode       CONSTANT NUMBER(1)    := 1; --Insert mode 0:1. If 1 - inserts only changed optional info in the block. , if 0 - all parts of the block
g_prod             VARCHAR2(3)           := 'IGS';
g_debug_level      NUMBER(1) := 0;
g_update_login     NUMBER(15);
g_update_by        NUMBER(15);
g_delimeter        CONSTANT VARCHAR2(1) := '|';
g_create_count    NUMBER(15) := 0;     -- prbhardw CP enhancement
g_update_count    NUMBER(15) := 0;     -- prbhardw CP enhancement
g_running_create_batch NUMBER(15);     -- prbhardw CP enhancement
g_running_update_batch NUMBER(15);     -- prbhardw CP enhancement
l_prog_label CONSTANT VARCHAR2(500) :='igs.plsql.igs_sv_batch_process_pkg';
l_label VARCHAR2(4000);
l_debug_str VARCHAR2(32000);
g_person_status    VARCHAR2(6)      := 'NEW';
g_legal_status    VARCHAR2(6)      := 'NEW';
g_nonimg_form_id NUMBER(15);
TYPE g_address_rec_type IS TABLE OF IGS_SV_ADDRESSES%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE g_edu_rec_type IS TABLE OF IGS_SV_PRGMS_INFO%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE g_dependent_rec_type IS TABLE OF IGS_SV_DEPDNT_INFO%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE g_convictions_rec_type IS TABLE OF IGS_SV_CONVICTIONS%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE g_empl_rec_type IS TABLE OF IGS_SV_EMPL_INFO%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE g_parallel_batches_tbl IS TABLE OF IGS_SV_BATCHES.BATCH_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE g_running_batches_tbl IS TABLE OF IGS_SV_BATCHES.BATCH_ID%TYPE INDEX BY BINARY_INTEGER;

g_parallel_batches g_parallel_batches_tbl;
g_running_batches  g_running_batches_tbl;

TYPE c_stdnt_list IS RECORD
(
    person_id        igs_pe_nonimg_form.person_id%TYPE,
    form_id	     igs_pe_ev_form.ev_form_id%TYPE	,
    person_number    hz_parties.party_number%TYPE,
    no_show_flag     igs_pe_ev_form.no_show_flag%TYPE	,
    reprint_reason   igs_pe_ev_form.reprint_reason%TYPE
);

TYPE t_student_rec IS RECORD
(   person_id        igs_sv_persons.person_id%TYPE,
    batch_id         igs_sv_persons.batch_id%TYPE,
    record_number    igs_sv_persons.record_number%TYPE,
    record_status    igs_sv_persons.record_status%TYPE, --(N)ew  (C)hanged
    person_number    igs_sv_persons.person_number%TYPE,
    sevis_user_id    igs_sv_batches.sevis_user_id%TYPE,
    batch_type       igs_sv_batches.batch_type%TYPE,
    form_id          igs_sv_persons.form_id%TYPE,
    print_form       igs_sv_persons.print_form%TYPE,
    dep_flag         VARCHAR2(1),
    person_status    VARCHAR2(1),
    changes_found    VARCHAR2(1),
    issue_status     VARCHAR2(1),
    bio_status       VARCHAR2(1),
    empl_status      VARCHAR2(1),
    other_status     VARCHAR2(1),
    f_addr_status    VARCHAR2(1),
    us_addr_status   VARCHAR2(1),
    edu_status       VARCHAR2(1),
    dep_status       VARCHAR2(1),
    fin_status       VARCHAR2(1),
    conv_status      VARCHAR2(1),
    site_addr_status VARCHAR2(1),
    legal_status     VARCHAR2(1),
    dep_count        NUMBER(3),
    edu_count        NUMBER(3),
    no_show_flag     igs_sv_persons.no_show_flag%TYPE,
    reprint_reason   igs_sv_persons.reprint_rsn_code%TYPE		-- prbhardw
);



PROCEDURE Put_Log_Msg (
   p_message IN VARCHAR2,
   p_level   IN NUMBER
);

PROCEDURE Generate_Message;

PROCEDURE Create_Batch(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_batch_type       IN  VARCHAR2,  -- Batch type E(ev),  I(international)
   p_validate_only    IN  VARCHAR2,  -- Validate only flag  'Y'  'N'
   p_org_id           IN  VARCHAR2,
   p_dso_id	      IN  VARCHAR2,
   p_dso_party_id     IN  NUMBER,
   p_org_party_id     IN  NUMBER
) ;

PROCEDURE Purge_Batch(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_batch_type       IN  VARCHAR2  -- Batch type E(ev),  I(international)
) ;

PROCEDURE Insert_Summary_Info(
   p_batch_id  IN  igs_sv_btch_summary.batch_id%TYPE,
   p_person_id  IN  igs_sv_btch_summary.person_id%TYPE,
   p_action_code  IN  igs_sv_btch_summary.action_code%TYPE,
   p_tag_code  IN  igs_sv_btch_summary.tag_code%TYPE,
   p_adm_action IN  igs_sv_btch_summary.adm_action_code%TYPE,
   p_owner_table_name IN igs_sv_btch_summary.owner_table_name%TYPE,
   p_owner_table_id  IN  igs_sv_btch_summary.OWNER_TABLE_IDENTIFIER%TYPE
);

PROCEDURE compose_log_file;
PROCEDURE xml_log_file (p_batch_id  IN  igs_sv_btch_summary.batch_id%TYPE);
/*****************************************************************/
PROCEDURE Submit_Event (
  p_batch_type IN VARCHAR2,
  p_batch_id   IN IGS_SV_BATCHES.BATCH_ID%TYPE
)
IS

  l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
  l_event_name    VARCHAR2(255);
  l_event_key     VARCHAR2(255);
  l_party_id      HZ_PARTY_SITES.PARTY_ID%TYPE;
  l_party_site_id HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;
  l_trans_type    VARCHAR2(30) :='IGS_SV';
  l_trans_subtype VARCHAR2(30) ;
  l_debug_level   NUMBER := 0;
  l_user_id       VARCHAR2(100);
  l_party_type    VARCHAR2(30) :='C';

  CURSOR c_party_data IS
   SELECT party_id,
          party_site_id
     FROM ecx_tp_headers
    WHERE tp_header_id IN
          ( SELECT tp_header_id
              FROM ecx_tp_details
             WHERE ext_process_id IN
             ( SELECT ext_process_id
                 FROM ecx_ext_processes
                WHERE direction = 'OUT'
                      AND transaction_id IN
                ( SELECT transaction_id
                    FROM ecx_transactions
                   WHERE transaction_type=l_trans_type
                     AND transaction_subtype =l_trans_subtype
                )
              )
           );

   CURSOR c_get_user_id IS
     SELECT sevis_user_id
     FROM igs_sv_batches
     WHERE batch_id = p_batch_id;

     l_con_req_id NUMBER;
BEGIN
  /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Submit_Event';
  l_debug_str := 'Entering Submit_Event. p_batch_type is ' || p_batch_type || 'and p_batch_id is ' || p_batch_id;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

  IF p_batch_type = 'E' THEN

    l_event_name := 'oracle.apps.igs.sv.ev.submit';
    l_trans_subtype :='SEVISEVO';

  ELSE

    l_event_name := 'oracle.apps.igs.sv.ni.submit';
    l_trans_subtype :='SEVISO';
  END IF;

  --SELECT FND_GLOBAL.CONC_REQUEST_ID INTO l_con_req_id FROM DUAL;

  l_con_req_id := FND_GLOBAL.CONC_REQUEST_ID;

  OPEN c_party_data;
  FETCH c_party_data INTO l_party_id, l_party_site_id;
  CLOSE c_party_data;

  IF l_party_id IS NULL THEN
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Submit_Event';
	  l_debug_str := 'IGS_SV_PRTNR_STP_ERR error in Submit_Event.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_PRTNR_STP_ERR'); -- No trading partner setup found
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

  END IF;

  OPEN c_get_user_id;
  FETCH c_get_user_id INTO l_user_id;
  CLOSE c_get_user_id;

  l_event_key := p_batch_id  || l_con_req_id;

	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.event_parameters';
	  l_debug_str := 'batch_id= '|| p_batch_id || 'l_party_id= '|| l_party_id || ' l_party_site_id='||l_party_site_id || 'l_trans_type= ' || l_trans_type || ' l_trans_subtype= ' || l_trans_subtype || ' l_debug_level = ' || l_debug_level ;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
  /* Manoj
  wf_event.AddParameterToList(p_name=>'DOC_ID',p_value=>p_batch_id,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'PARTY_ID',p_value=>l_party_id,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'PARTY_SITE_ID',p_value=>l_party_site_id,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'TRANS_TYPE',p_value=>l_trans_type,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'TRANS_SUB_TYPE',p_value=>l_trans_subtype,p_parameterlist=>l_parameter_list);
Manoj*/
  --l_user_id := '999-999-777';
  wf_event.AddParameterToList(p_name=>'ECX_DOCUMENT_ID',p_value=>p_batch_id,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'ECX_PARTY_ID',p_value=>l_party_id,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'ECX_PARTY_SITE_ID',p_value=>l_party_site_id,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'ECX_TRANSACTION_TYPE',p_value=>l_trans_type,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'ECX_TRANSACTION_SUBTYPE',p_value=>l_trans_subtype,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'ECX_PARTY_TYPE',p_value=>l_party_type,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'ECX_DEBUG_LEVEL',p_value=>l_debug_level,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'PARAMETER1',p_value=>p_batch_id,p_parameterlist=>l_parameter_list);
  wf_event.AddParameterToList(p_name=>'PARAMETER2',p_value=>l_user_id,p_parameterlist=>l_parameter_list);


  -- Raise the Event without the message
  -- The Generate Function Callback will create the XML Document
  -- Also possible that an API might be called from here to
  -- to generate the XML document
  wf_event.raise( p_event_name => l_event_name,
                  p_event_key  => l_event_key,
                  p_parameters => l_parameter_list);


  l_parameter_list.DELETE;

 /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Submit_Event';
  l_debug_str := 'Exiting Submit_Event. l_event_key: '||l_event_key;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

END;


/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Dump_Current_Person(
   p_student_rec IN t_student_rec
) IS

   l_str VARCHAR2(2000);

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Dump_Current_Person';
	  l_debug_str := 'Entering Dump_Current_Person. p_student_rec.person_id is '|| p_student_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

  -- This is a debug procedure used to output a current person info if an error occurs
  Put_Log_Msg('****** Execution error - dumping current person *********',1);

  Put_Log_Msg(' person_id '||        p_student_rec.person_id ,1);
  Put_Log_Msg(' form_id   '||        p_student_rec.form_id ,1);
  Put_Log_Msg(' print_form   '||        p_student_rec.print_form ,1);
  Put_Log_Msg(' record_number '||    p_student_rec.record_number ,1);
  Put_Log_Msg(' record_status '||    p_student_rec.record_status ,1);
  Put_Log_Msg(' person_number '||    p_student_rec.person_number ,1);
  Put_Log_Msg(' sevis_user_id '||    p_student_rec.sevis_user_id ,1);
  Put_Log_Msg(' form_id '||          p_student_rec.form_id ,1);
  Put_Log_Msg(' person_status '||    p_student_rec.person_status ,1);
  Put_Log_Msg(' issue_status  '||    p_student_rec.issue_status ,1);
  Put_Log_Msg(' bio_status '||       p_student_rec.bio_status ,1);
  Put_Log_Msg(' other_status '||     p_student_rec.other_status ,1);
  Put_Log_Msg(' f_addr_status '||    p_student_rec.f_addr_status ,1);
  Put_Log_Msg(' us_addr_status '||   p_student_rec.us_addr_status ,1);
  Put_Log_Msg(' edu_status '||       p_student_rec.edu_status ,1);
  Put_Log_Msg(' dep_status '||       p_student_rec.dep_status ,1);
  Put_Log_Msg(' fin_status '||       p_student_rec.fin_status ,1);
  Put_Log_Msg(' dep_count '||        p_student_rec.dep_count ,1);
  Put_Log_Msg(' edu_count '||        p_student_rec.edu_count ,1);

  Put_Log_Msg('********************************************************',1);
  /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Dump_Current_Person';
	  l_debug_str := 'Exiting Dump_Current_Person.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
END Dump_Current_Person;

/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
   pkpatel              22-APR-2003     Bug No: 2908378
                                        Modified the query to select the Active local institution. Added closed_ind = 'N'
                                        while selecting the ORG_ALTERNATE_ID_TYPE
                        9-DEC-2003      Bug No: 2908378 (Used the profile for local Institution)
------------------------------------------------------------------------


FUNCTION Get_School_Sevis_Id (
  p_batch_type IN VARCHAR2
) RETURN VARCHAR2
IS

   CURSOR c_alt_id (cp_local_inst hz_parties.party_number%TYPE)
   IS
     SELECT org_alternate_id
       FROM igs_or_org_alt_ids
       WHERE org_structure_id = cp_local_inst
       AND sysdate BETWEEN NVL(start_date,sysdate-1) and NVL(end_date,sysdate+1)
       AND ( ( org_alternate_id_type =
                     ( SELECT org_alternate_id_type
                       FROM igs_or_org_alt_idtyp
                       WHERE system_id_type = g_school_sevis_id AND
                             close_ind = 'N' AND
                             inst_flag = 'Y'
                      ) AND p_batch_type ='I')
                    OR  ( org_alternate_id_type =
                         ( SELECT org_alternate_id_type
                           FROM igs_or_org_alt_idtyp
                           WHERE system_id_type = g_sch_p_sevis_id AND
                                 close_ind = 'N' AND
                                 inst_flag = 'Y'
                        )
                        AND p_batch_type ='E')
                  );

l_alt_id   VARCHAR2(255);
l_local_inst hz_parties.party_number%TYPE;

BEGIN
/* Debug
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_School_Sevis_Id';
  l_debug_str := 'Entering Get_School_Sevis_Id. p_batch_type is '|| p_batch_type;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

 l_local_inst := FND_PROFILE.VALUE('IGS_OR_LOCAL_INST');

     OPEN c_alt_id(l_local_inst);
     FETCH c_alt_id INTO l_alt_id;
     CLOSE c_alt_id;

/* Debug
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_School_Sevis_Id';
  l_debug_str := 'Exiting Get_School_Sevis_Id with return value '|| l_alt_id;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   RETURN l_alt_id;


END Get_School_Sevis_Id;
******************************************************************/
/******************************************************************
   Created By         : prbhardw

   Date Created By    : Jan 03, 2006

   Purpose            : Function to check mutually exclusive tags.

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION chk_mut_exclusive(p_batch_id igs_sv_btch_summary.batch_id%TYPE,
			    p_person_id igs_sv_btch_summary.person_id%TYPE,
			    p_action igs_sv_btch_summary.action_code%TYPE,
			    p_tag_code igs_sv_btch_summary.tag_code%TYPE
			   )
 RETURN NUMBER
IS
     l_is_mut_excl BOOLEAN := TRUE;
     l_return_batch_id NUMBER(14) := -1;
     l_num_parallel_rec NUMBER(4) := 0;
     l_rec_count NUMBER(5) := 0;
BEGIN
     l_is_mut_excl := igs_sv_util.ismutuallyexclusive(p_person_id,
						      p_batch_id,
						      p_action,
		                                      p_tag_code);
     IF l_is_mut_excl = TRUE THEN
	 IF(g_parallel_batches.COUNT >0) THEN
 	   FOR i IN g_parallel_batches.FIRST..g_parallel_batches.LAST LOOP
	       l_rec_count := l_rec_count +1;
	       l_is_mut_excl := igs_sv_util.ismutuallyexclusive(p_person_id,
						      g_parallel_batches(l_rec_count),
						      p_action,
		                                      p_tag_code);
	       IF l_is_mut_excl = FALSE THEN
	            l_return_batch_id := g_parallel_batches(l_rec_count);
	            igs_sv_util.create_Person_Rec(p_person_id,p_batch_id,l_return_batch_id);
		    EXIT;
	       END IF;
 	   END LOOP;
	 END IF;
     ELSE
	  l_return_batch_id := p_batch_id;
     END IF;

     IF l_is_mut_excl = TRUE THEN
          l_num_parallel_rec := g_parallel_batches.count + 1;
	  l_return_batch_id :=  igs_sv_util.open_new_batch(p_person_id,p_batch_id, 'CONN_JOB');
	  g_parallel_batches(l_num_parallel_rec) := l_return_batch_id;
     END IF;
     RETURN l_return_batch_id;

END chk_mut_exclusive;


/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Is_Number (
  p_num     VARCHAR2
) RETURN VARCHAR2
IS

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Is_Number';
  l_debug_str := 'Entering Is_Number. p_num is '|| p_num;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
      Put_Log_Msg('Is_Number begins',0);

  RETURN to_char(to_number(p_num));

EXCEPTION

  WHEN VALUE_ERROR THEN
    /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Is_Number';
  l_debug_str := 'Exception in Is_Number'||SQLERRM;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

    RETURN '';

END Is_Number;

/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Lookup_Name (
 p_type VARCHAR2 ,
 p_code VARCHAR2

 ) RETURN VARCHAR2
IS

  CURSOR c_blk_name IS
     SELECT meaning
      FROM fnd_lookup_values
      WHERE lookup_code = p_code
        AND view_application_id = 8405
        AND enabled_flag='Y'
        AND language = USERENV('LANG')
        AND lookup_type = p_type
        AND SYSDATE BETWEEN NVL(start_date_active,SYSDATE-1) AND NVL(end_date_active, SYSDATE + 1);

  l_block_name  VARCHAR2(255);

BEGIN
 /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Lookup_Name';
  l_debug_str := 'Entering Get_Lookup_Name. p_type is '||p_type ||' and p_code is '|| p_code;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

  OPEN c_blk_name;
  FETCH c_blk_name INTO l_block_name;
  CLOSE c_blk_name;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Lookup_Name';
  l_debug_str := 'Returning from Get_Lookup_Name with value '||l_block_name;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

  RETURN l_block_name;

END Get_Lookup_Name;



/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Convert_Country_Code (

  p_code VARCHAR2

 ) RETURN VARCHAR2
IS

 CURSOR c_blk_name IS
     SELECT SUBSTR(meaning,5,2)
      FROM fnd_lookup_values
     WHERE lookup_type = 'PQP_US_COUNTRY_TRANSLATE'
       AND view_application_id = 3
       AND lookup_code=p_code
       AND SYSDATE BETWEEN  NVL(start_date_active,SYSDATE-1)  AND NVL(end_date_active, SYSDATE + 1);

  CURSOR chk_iso_country (cp_cntry_code VARCHAR2) IS
     SELECT alternate_territory_code
     FROM   fnd_territories_vl
     WHERE  territory_code = cp_cntry_code;

  l_block_name  VARCHAR2(255);
  l_alt_code VARCHAR2(12);

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Convert_Country_Code';
  l_debug_str := 'Entering Convert_Country_Code. p_code is '||p_code;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
  --Code for non-ISO countries
    OPEN chk_iso_country(p_code);
    FETCH chk_iso_country INTO l_alt_code;
    CLOSE chk_iso_country;

    IF INSTR(l_alt_code,'IGS_') <> 0 THEN
        RETURN substr(l_alt_code,5);
    END IF;

  OPEN c_blk_name;
  FETCH c_blk_name INTO l_block_name;
  CLOSE c_blk_name;
-- change for country code inconsistency bug 3738488
  IF l_block_name IS NULL THEN
     IF p_code = 'AU' THEN
        l_block_name := 'AT';
        Put_Log_Msg('ISO Country Code (AU) converted into US Country Code (AT)',0);
     ELSIF p_code = 'UM' THEN
        l_block_name := 'BQ';
        Put_Log_Msg('ISO Country Code (UM) converted into US Country Code (BQ)',0);
     ELSIF p_code = 'RE' THEN
        l_block_name := 'JU';
        Put_Log_Msg('ISO Country Code (RE) converted into US Country Code (JU)',0);
     ELSIF p_code = 'SJ' THEN
        l_block_name := 'JN';
        Put_Log_Msg('ISO Country Code (SJ) converted into US Country Code (JN)',0);
     ELSIF p_code = 'GB' THEN
        l_block_name := 'IM';
        Put_Log_Msg('ISO Country Code (GB) converted into US Country Code (IM)',0);
     ELSIF p_code = 'PF' THEN
        l_block_name := 'IP';
        Put_Log_Msg('ISO Country Code (PF) converted into US Country Code (IP)',0);
     ELSIF p_code = 'JE' OR p_code = 'WS' THEN
        l_block_name := p_code;
        Put_Log_Msg('ISO Country Code ('||p_code||') has same value for US Country Code. No conversion.',0);
     END IF;
  END IF;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Convert_Country_Code';
  l_debug_str := 'Returning from Convert_Country_Code with value '|| l_block_name;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

  RETURN NVL(l_block_name,p_code);


END Convert_Country_Code;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate information pertaining to the
                        Legal information block of student.
                        (IGS_SV_LEGAL_INFO)

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Convert_Visa_Type (
  p_visa_meaning VARCHAR2
 ) RETURN VARCHAR2 IS

  CURSOR c_visa_type IS
     SELECT lv.lookup_code
       FROM fnd_lookup_values   lv
      WHERE lv.lookup_type = 'SV_MAP_HR_VISA_TYPES'
        AND lv.meaning     = p_visa_meaning
        AND SYSDATE BETWEEN  NVL(start_date_active,SYSDATE-1)  AND NVL(end_date_active, SYSDATE + 1);

  l_sv_visa_code  VARCHAR2(30);

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Convert_Visa_Type';
  l_debug_str := 'Entering Convert_Visa_Type. p_visa_meaning is '||p_visa_meaning;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

  OPEN c_visa_type;

  FETCH c_visa_type
   INTO l_sv_visa_code;

  CLOSE c_visa_type;
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Convert_Visa_Type';
  l_debug_str := 'Returning from Convert_Visa_Type with value '|| l_sv_visa_code;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

  RETURN l_sv_visa_code;

END Convert_Visa_Type;



/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Convert_Suffix(
   p_person_num   IN  VARCHAR2,
   p_code         IN  VARCHAR2,
   p_type         IN  VARCHAR2
) RETURN VARCHAR2
IS

   CURSOR c_name_suffix IS
      SELECT tag
        FROM fnd_lookup_values
       WHERE lookup_code         = p_code
         AND view_application_id = 8405
         AND enabled_flag        = 'Y'
         AND language            = USERENV('LANG')
         AND lookup_type         = p_type
         AND SYSDATE BETWEEN  NVL(start_date_active,SYSDATE-1)  AND NVL(end_date_active, SYSDATE + 1);

   l_name_suffix        VARCHAR2(30);

BEGIN
  /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Convert_Suffix';
  l_debug_str := 'Entering Convert_Suffix. p_person_num is '||p_person_num || ', p_code is '||p_code||' and p_type is '||p_type;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   OPEN c_name_suffix;
   FETCH c_name_suffix
    INTO l_name_suffix;

   IF (c_name_suffix%NOTFOUND) AND p_code IS NOT NULL THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_WARN_FLD_ERR'); -- Warning message for optional field
      FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'Suffix');
      FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_num);
      Put_Log_Msg(FND_MESSAGE.Get,1);

      l_name_suffix := NULL;

   END IF;
   CLOSE c_name_suffix;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Convert_Suffix';
  l_debug_str := 'Returning from Convert_Suffix with value '|| l_name_suffix;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   RETURN l_name_suffix;

END Convert_Suffix;



/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Block_Name (
 p_block VARCHAR2
 ) RETURN VARCHAR2
IS

BEGIN
 /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Block_Name';
  l_debug_str := 'Inside Get_Block_Name. p_block is '||p_block;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

  RETURN get_lookup_name ('SV_VALIDATIONS',p_block);

END Get_Block_Name;



/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Person_Sevis_Id (
   p_person_id IN NUMBER
) RETURN VARCHAR2
IS

   CURSOR c_alt_id IS
    SELECT api_person_id
      FROM igs_pe_alt_pers_id
     WHERE pe_person_id = p_person_id
           AND person_id_type
               IN (SELECT person_id_type
                     FROM igs_pe_person_id_typ
                    WHERE s_person_id_type = g_person_sevis_id)
           AND start_dt <= trunc(sysdate)
           AND NVL(end_dt,sysdate+1) >= trunc(sysdate);

l_alt_id   VARCHAR2(255);

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Person_Sevis_Id';
  l_debug_str := 'Entering Get_Person_Sevis_Id. p_person_id is '||p_person_id;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

 OPEN c_alt_id;
 FETCH c_alt_id INTO l_alt_id;
 CLOSE c_alt_id;


 IF l_alt_id IS NOT NULL AND LENGTH(l_alt_id)<=11 THEN

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Person_Sevis_Id';
  l_debug_str := 'Returning from Get_Person_Sevis_Id with value '||l_alt_id;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   RETURN l_alt_id;

 END IF;
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Person_Sevis_Id';
  l_debug_str := 'Returning from Get_Person_Sevis_Id ';
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

 RETURN '';

END Get_Person_Sevis_Id;


FUNCTION Check_US_Terr(
   p_person_num   IN  VARCHAR2,
   p_code         IN  VARCHAR2
) RETURN VARCHAR2
IS

   CURSOR c_name IS
      SELECT tag
        FROM fnd_lookup_values
       WHERE lookup_code         = p_code
         AND view_application_id = 8405
         AND enabled_flag        = 'Y'
         AND language            = USERENV('LANG')
         AND lookup_type         = 'SV_US_TERRITORY_CODES'
         AND SYSDATE BETWEEN  NVL(start_date_active,SYSDATE-1)  AND NVL(end_date_active, SYSDATE + 1);

   l_name_suffix        VARCHAR2(30);

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Check_US_Terr';
  l_debug_str := 'Entering Check_US_Terr. p_person_num is '||p_person_num ||' and p_code is '||p_code;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   OPEN c_name;
   FETCH c_name
    INTO l_name_suffix;

   IF p_code IS NOT NULL AND c_name%FOUND THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_US_TERR_CD_ERR'); -- Error
      FND_MESSAGE.SET_TOKEN('CNTRY_CODE', p_code);
      FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_num);
      Put_Log_Msg(FND_MESSAGE.Get,1);

      CLOSE c_name;
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Check_US_Terr';
  l_debug_str := 'Returning E from Check_US_Terr ';
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

      RETURN 'E';

   END IF;

   CLOSE c_name;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Check_US_Terr';
  l_debug_str := 'Returning S from Check_US_Terr ';
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   RETURN 'S';

END Check_US_Terr;

/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Prev_Dep (
   p_person_id IN NUMBER,
   p_depdnt_id  IN NUMBER,
   p_batch_id   IN NUMBER,
   p_action_type VARCHAR2
) RETURN BOOLEAN
IS

   CURSOR c_dep_exist IS
    SELECT COUNT('X')
      FROM igs_sv_depdnt_info
     WHERE person_id = p_person_id
           AND depdnt_id = p_depdnt_id
	   AND batch_id < p_batch_id;

l_dep_exists  BOOLEAN := TRUE;
l_count NUMBER := 0;
BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Prev_Dep';
  l_debug_str := 'Entering Get_Prev_Dep. p_person_id is '||p_person_id||' dependent id is'||p_depdnt_id;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

 OPEN c_dep_exist;
 FETCH c_dep_exist INTO l_count;
 CLOSE c_dep_exist;

 IF p_action_type = 'T' AND l_count = 0 THEN
     l_dep_exists := FALSE;
 END IF;

 RETURN l_dep_exists;


END Get_Prev_Dep;

/******************************************************************
   Created By         : Arkadi Tereshenkov
   Date Created By    : Oct 14, 2002
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION is_valid_addr (
  p_batch_type VARCHAR2,
  p_person_id  NUMBER,
  p_site_id    NUMBER
) RETURN BOOLEAN
IS
   l_valid_addr BOOLEAN;
   l_count NUMBER;

   CURSOR c_f_addr_exists(cp_person_id igs_sv_addresses.person_id%TYPE, cp_party_site_id igs_sv_addresses.party_site_id%TYPE)
   IS
      SELECT 1
       FROM igs_pe_addr_v adr,
            igs_pe_partysiteuse_v usg
      WHERE person_id = cp_person_id
        AND ( adr.status = 'A' AND SYSDATE BETWEEN NVL(start_dt,SYSDATE) AND NVL(end_dt, SYSDATE + 1) )
        AND usg.party_site_id  = adr.party_site_id
	AND adr.party_site_id = cp_party_site_id
        AND usg.site_use_type  = g_f_addr_usage
        AND usg.active         = 'A';

   CURSOR c_us_addr_exists(cp_person_id igs_sv_addresses.person_id%TYPE, cp_party_site_id igs_sv_addresses.party_site_id%TYPE)
   IS
      SELECT 1
       FROM igs_pe_addr_v adr,
            igs_pe_partysiteuse_v usg
      WHERE person_id = cp_person_id
	    AND ( adr.status = 'A' AND SYSDATE BETWEEN NVL(start_dt,SYSDATE) AND NVL(end_dt, SYSDATE + 1) )
            AND usg.party_site_id  = adr.party_site_id
            AND adr.party_site_id = cp_party_site_id
            AND usg.site_use_type  = g_us_addr_usage
            AND usg.active         = 'A';

   CURSOR c_soa_exists(cp_person_id igs_sv_addresses.person_id%TYPE, cp_party_site_id igs_sv_addresses.party_site_id%TYPE)
   IS
      SELECT 1
      FROM hz_locations loc,
	  hz_party_sites ps,
	  igs_pe_hz_pty_sites igsps,
	  hz_party_site_uses usg
      WHERE
         ps.location_id = loc.location_id
         AND ps.party_site_id = igsps.party_site_id (+)
	 AND ps.party_site_id = cp_party_site_id
         AND ps.party_id = cp_person_id
         AND ( ps.status = 'A' AND SYSDATE BETWEEN NVL(IGSPS.start_date,SYSDATE) AND NVL(IGSPS.end_date, SYSDATE + 1))
         AND usg.party_site_id  = ps.party_site_id
         AND usg.site_use_type  = g_site_addr_usage
         AND usg.status = 'A'
    UNION
      SELECT 1
      FROM  hz_locations adr,
            igs_pe_act_site usg
      WHERE usg.person_id = cp_person_id
        AND SYSDATE BETWEEN nvl(ADDRESS_EFFECTIVE_DATE,sysdate-1) AND NVL(ADDRESS_EXPIRATION_DATE, SYSDATE + 1)
        AND usg.location_id = adr.location_id
	AND adr.location_id = cp_party_site_id
        AND sysdate BETWEEN usg.start_date AND NVL(usg.end_date,sysdate+1);

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.is_valid_addr';
  l_debug_str := 'Entering is_valid_addr. person id: '||p_person_id ||'site id: '|| p_site_id;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
      Put_Log_Msg('is_valid_addr begins',0);

      l_valid_addr  := TRUE;
      l_count := 0;
      IF p_batch_type = 'E' THEN
          OPEN  c_us_addr_exists(p_person_id, p_site_id);
	  FETCH c_us_addr_exists INTO l_count;
	  CLOSE c_us_addr_exists;

	  IF l_count > 0 THEN
	       l_count := 0;
	       OPEN  c_soa_exists(p_person_id, p_site_id);
	       FETCH c_soa_exists INTO l_count;
	       CLOSE c_soa_exists;
               IF l_count > 0 THEN
	            l_valid_addr := FALSE;
	       END IF;
	  END IF;

      ELSE
          OPEN  c_f_addr_exists(p_person_id, p_site_id);
	  FETCH c_f_addr_exists INTO l_count;
	  CLOSE c_f_addr_exists;

	  IF l_count > 0 THEN
	       l_count := 0;
	       OPEN  c_us_addr_exists(p_person_id, p_site_id);
	       FETCH c_us_addr_exists INTO l_count;
	       CLOSE c_us_addr_exists;
               IF l_count > 0 THEN
	            l_valid_addr := FALSE;
	       END IF;
	  END IF;
      END IF;


      Put_Log_Msg('returning from is_valid_addr',0);
      RETURN l_valid_addr;

EXCEPTION

  WHEN OTHERS THEN
    /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.is_valid_addr';
  l_debug_str := 'Exception in is_valid_addr'||SQLERRM;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

    RETURN l_valid_addr;

END is_valid_addr;
/*****************  Validation procedures  *************************************

OIB Other Information
FAB Foreign Address Information
UAB US Address Information
AAB Site of Activity Address Information
EIB Education Information
FIB Financial Information
DIB Dependent Information
CIB Conviction Information
LIB Legal Information
EMB Employment Information
PIB Program Information

*******************************************************************************/

/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate the information for the block that
                        is to be used for the Person Info Block
                        (IGS_SV_PERSONS)

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_Issue_Info (
   p_person_rec IN t_student_rec,
   p_data_rec  IN OUT NOCOPY  IGS_SV_PERSONS%ROWTYPE   -- Data record
) RETURN VARCHAR2
IS

   l_api_name CONSTANT VARCHAR(30) := 'Validate_Issue_Info';

   CURSOR c_data IS
     SELECT issue_reason   ,
            curr_session_end_date ,
            next_session_start_date ,
            other_reason,
            transfer_from_school,
            prgm_start_date,
	    last_session_flag,
	    adjudicated_flag
       FROM igs_pe_nonimg_form
      WHERE nonimg_form_id = p_person_rec.form_id ;

   CURSOR c_ev_data IS
     SELECT create_reason   ,
            prgm_start_date ,
            prgm_end_date  ,
            ev_form_number ,
            init_prgm_start_date ,
	    no_show_flag
       FROM igs_pe_ev_form
      WHERE ev_form_id = p_person_rec.form_id ;


  l_not_valid  boolean  := FALSE;
  l_prog_start_date     igs_pe_nonimg_form.prgm_start_date%TYPE;

BEGIN

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Issue_Info';
  l_debug_str := 'Entering Validate_Issue_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   Put_Log_Msg(l_api_name||' starts ',0);

   p_data_rec.batch_id := NULL;  -- This will tell us if there's been any records found

   IF p_person_rec.batch_type = 'I' THEN

     FOR c_data_rec IN c_data LOOP

       p_data_rec.batch_id        := p_person_rec.batch_id;
       p_data_rec.person_id       := p_person_rec.person_id;
       p_data_rec.print_form      := p_person_rec.print_form;
       p_data_rec.record_number   := p_person_rec.record_number ;
       p_data_rec.form_id         := p_person_rec.form_id ;
       p_data_rec.record_status   := p_person_rec.record_status ;
       p_data_rec.person_number   := p_person_rec.person_number ;
       p_data_rec.sevis_user_id   := p_person_rec.sevis_user_id ;
       l_prog_start_date          := c_data_rec.prgm_start_date ;

       p_data_rec.creation_date := sysdate;
       p_data_rec.created_by := g_update_by;
       p_data_rec.last_updated_by := g_update_by;
       p_data_rec.last_update_date  := sysdate;
       p_data_rec.last_update_login := g_update_login;

       p_data_rec.issuing_reason  := c_data_rec.issue_reason;
       p_data_rec.curr_session_end_date:= to_char(c_data_rec.curr_session_end_date,'YYYY-MM-DD');
       p_data_rec.next_session_start_date:= to_char(c_data_rec.next_session_start_date,'YYYY-MM-DD');
       p_data_rec.other_reason:= c_data_rec.other_reason;
       p_data_rec.Transfer_from_school:= c_data_rec.Transfer_from_school;
       p_data_rec.last_session_flag	:= c_data_rec.last_session_flag;
       p_data_rec.adjudicated_flag   := c_data_rec.adjudicated_flag;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Issue_Info';
  l_debug_str := 'Exiting from for loop of Validate_Issue_Info';
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

       EXIT;  -- one  record is enough

     END LOOP;

   ELSE

     FOR c_data_rec IN c_ev_data LOOP

       p_data_rec.batch_id        := p_person_rec.batch_id;
       p_data_rec.person_id       := p_person_rec.person_id;
       p_data_rec.print_form      := p_person_rec.print_form;
       p_data_rec.record_number   := p_person_rec.record_number ;
       p_data_rec.form_id         := p_person_rec.form_id ;
       p_data_rec.record_status   := p_person_rec.record_status ;
       p_data_rec.person_number   := p_person_rec.person_number ;
       p_data_rec.sevis_user_id   := p_person_rec.sevis_user_id ;

       p_data_rec.creation_date := sysdate;
       p_data_rec.created_by := g_update_by;
       p_data_rec.last_updated_by := g_update_by;
       p_data_rec.last_update_date  := sysdate;
       p_data_rec.last_update_login := g_update_login;

       p_data_rec.ev_create_reason  := c_data_rec.create_reason;
       p_data_rec.ev_form_number:= c_data_rec.ev_form_number;

       --These fields are used for EV program start date

       p_data_rec.curr_session_end_date:= to_char(c_data_rec.prgm_end_date,'YYYY-MM-DD');
       p_data_rec.next_session_start_date:= to_char(c_data_rec.prgm_start_date,'YYYY-MM-DD');
       p_data_rec.init_prgm_start_date:= to_char(c_data_rec.init_prgm_start_date,'YYYY-MM-DD');
       p_data_rec.no_show_flag	:= c_data_rec.no_show_flag;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Issue_Info';
  l_debug_str := 'Exiting from for loop of Validate_Issue_Info';
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
       EXIT;  -- one  record is enough

     END LOOP;


   END IF;


   IF p_data_rec.batch_id IS NULL THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Issue_Info';
  l_debug_str := 'Returning N from Validate_Issue_Info';
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

      RETURN 'N';

   ELSE

     IF p_data_rec.issuing_reason = 'C' THEN

        IF p_data_rec.curr_session_end_date IS NULL OR p_data_rec.next_session_start_date IS NULL THEN

           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_ISSUE_C_REQ_ERR'); -- SEVIS common error
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

           Put_Log_Msg(FND_MESSAGE.Get,1);
           l_not_valid := TRUE;

        END IF;

     ELSIF p_data_rec.issuing_reason = 'T' THEN

        IF p_data_rec.Transfer_from_school IS NULL  THEN

           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_ISSUE_T_REQ_ERR'); -- SEVIS common error
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

           Put_Log_Msg(FND_MESSAGE.Get,1);
           l_not_valid := TRUE;

        END IF;

     ELSIF p_data_rec.issuing_reason = 'I'  THEN

        IF l_prog_start_date  IS NULL OR  l_prog_start_date < trunc(sysdate) THEN

           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_PRG_START_DT_ERR'); -- SEVIS common error
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );
           FND_MESSAGE.SET_TOKEN('PRGM_DATE', l_prog_start_date );

           Put_Log_Msg(FND_MESSAGE.Get,1);
           l_not_valid := TRUE;

        END IF;


     ELSIF p_data_rec.issuing_reason = 'O' THEN

        IF p_data_rec.other_reason IS NULL  THEN

           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_ISSUE_O_REQ_ERR'); -- SEVIS common error
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

           Put_Log_Msg(FND_MESSAGE.Get,1);
           l_not_valid := TRUE;

        END IF;

     ELSIF p_person_rec.batch_type = 'E' AND p_data_rec.issuing_reason = 'CONT' AND  p_data_rec.init_prgm_start_date IS NULL THEN

           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EV_PRG_RQD_FLD_ERR'); -- error - no initial date specified
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

           Put_Log_Msg(FND_MESSAGE.Get,1);
           l_not_valid := TRUE;

     ELSIF p_person_rec.batch_type = 'E'
           AND ( p_data_rec.curr_session_end_date IS NULL
                 OR p_data_rec.next_session_start_date IS NULL ) THEN

           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EV_PRG_RQD_FLD_ERR'); -- error
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

           Put_Log_Msg(FND_MESSAGE.Get,1);
           l_not_valid := TRUE;

     END IF;

     IF p_person_rec.batch_type = 'I' THEN
           IF ( p_data_rec.last_session_flag = 'Y'
                 AND p_data_rec.next_session_start_date IS NOT NULL ) THEN

		   --FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EV_LAST_SESN'); -- error
		   --FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );
		   p_data_rec.next_session_start_date := NULL;

	   END IF;
     END IF;

     IF l_not_valid THEN

        Put_Log_Msg(l_api_name||' Validation error, return E ',1);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Issue_Info';
	  l_debug_str := 'Returning E from Validate_Issue_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

        RETURN 'E';

     END IF;

   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
 /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Issue_Info';
  l_debug_str := 'Returning S from Validate_Issue_Info';
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Issue_Info';
	  l_debug_str := 'Exception in Validate_Issue_Info'||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_Issue_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validation procedure on data that is to be
                        resident in the BIO Info block.
                        (IGS_SV_BIO_INFO)

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
   pkpatel              22-APR-2003     Bug No: 2908378
                                        Modified to prevent mandatory check of position_code and category_code, for dependents
                                        Added the new cursor c_perm_res_data for retriving Legal residency country
------------------------------------------------------------------------

******************************************************************/

FUNCTION Validate_Name(p_Name IN varchar2) RETURN boolean IS
        returnVal boolean := false;
    BEGIN
    /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Name';
	  l_debug_str := 'Inside Validate_Name. p_Name is '|| p_Name;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

	FOR counter in 0..9 LOOP
	   if instr(p_Name,counter) > 0 then
		returnVal :=true;
		EXIT WHEN returnVal;
	   END IF;
	END LOOP;
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Name';
	  l_debug_str := 'Returning from Validate_Name';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

        RETURN returnVal;

END Validate_Name;

Function Validate_Bio_Info(
   p_person_rec IN t_student_rec,
   p_data_rec  IN OUT NOCOPY  IGS_SV_BIO_INFO%ROWTYPE    -- Data record
) RETURN VARCHAR2
IS

   l_api_name CONSTANT VARCHAR(30) := 'Validate_Bio_Info';


   CURSOR c_hz_data IS
      SELECT hzpp.person_last_name,
             hzpp.person_middle_name,
             hzpp.person_first_name,
             hzpp.person_name_suffix,
             hzpp.date_of_birth,
             hzpp.gender,
             prt.birth_country,
             hzc.country_code,
             prt.birth_city
        FROM hz_person_profiles    hzpp,
             hz_citizenship        hzc,
             igs_pe_hz_parties     prt
       WHERE hzpp.party_id = p_person_rec.person_id
         AND prt.party_id = hzpp.party_id
         AND hzc.party_id (+)  = hzpp.party_id
         AND sysdate between hzpp.effective_start_date AND NVL(hzpp.effective_end_date,sysdate+1);

   CURSOR c_nonimg_data IS
      SELECT peva.visa_type
        FROM igs_pe_visa   peva
       WHERE peva.person_id = p_person_rec.person_id
         AND SYSDATE BETWEEN peva.visa_issue_date AND peva.visa_expiry_date;

   CURSOR c_com_data IS
      SELECT decode(commuter_ind,'Y','1','0') commuter
        FROM igs_pe_nonimg_form
       WHERE nonimg_form_id  = p_person_rec.form_id;

   CURSOR c_perm_res_data IS
   SELECT perm_res_cntry
   FROM igs_pe_eit_perm_res_v
   WHERE person_id  = p_person_rec.person_id;

   CURSOR c_ev_data IS
      SELECT pevf.position_code,
             pevf.category_code,
             pevf.position_remarks
        FROM igs_pe_ev_form        pevf
       WHERE pevf.person_id = p_person_rec.person_id
         AND ev_form_id     = p_person_rec.form_id;

   CURSOR c_country_reason(cp_person_id number) IS
	SELECT psd.birth_cntry_resn_code
        FROM igs_pe_stat_details  psd
        WHERE psd.person_id = cp_person_id;


   l_last_name             hz_person_profiles.person_last_name%TYPE;
   l_middle_name           hz_person_profiles.person_middle_name%TYPE;
   l_first_name            hz_person_profiles.person_first_name%TYPE;
   l_suffix                hz_person_profiles.person_name_suffix%TYPE;
   l_birth_date            hz_person_profiles.date_of_birth%TYPE;
   l_birth_city            igs_pe_hz_parties.birth_city%TYPE;
   l_gender                hz_person_profiles.gender%TYPE;
   l_birth_cntry_code      VARCHAR2(30); -- ASAP need new column and table to get type
   l_citizen_cntry_code    hz_citizenship.country_code%TYPE;
   l_visa_type             IGS_PE_VISA.visa_type%TYPE;
   l_commuter              VARCHAR2(1);  -- ASAP need new column and table to get type
   l_legal_res_cntry_code  VARCHAR2(30); -- ASAP need new column and table to get type
   l_position_code         IGS_PE_EV_FORM.position_code%TYPE;
   l_category_code         IGS_PE_EV_FORM.category_code%TYPE;
   l_position_remarks      IGS_PE_EV_FORM.position_remarks%TYPE;
   l_birth_cntry_resn_code  igs_pe_stat_details.birth_cntry_resn_code%TYPE;

   l_not_valid             BOOLEAN :=FALSE;
BEGIN
  -- Visa type valies
  -- 01 F-1
  -- 02 M-1
  -- 03 J-1
  -- 04 F-2
  -- 05 M-2
  -- 06 J-2
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Bio_Info';
	  l_debug_str := 'Inside Validate_Bio_Info. p_person_rec.batch_type is '|| p_person_rec.batch_type ||' and person_id is '|| p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' starts ',0);
   p_data_rec.batch_id := NULL;  -- This will tell us if there's been any records found

   OPEN c_hz_data;
   FETCH c_hz_data
    INTO l_last_name,
         l_middle_name,
         l_first_name,
         l_suffix,
         l_birth_date,
         l_gender,
         l_birth_cntry_code,
         l_citizen_cntry_code,
         l_birth_city;

   IF (c_hz_data%FOUND) THEN

      l_suffix := convert_suffix (p_person_rec.person_number, l_suffix, 'PE_US_NAME_SUFFIX');
      p_data_rec.last_name             := SUBSTR(l_last_name, 1, 40);
      p_data_rec.middle_name           := SUBSTR(l_middle_name, 1, 40);
      p_data_rec.first_name            := SUBSTR(l_first_name, 1, 40);
      p_data_rec.suffix                := SUBSTR(l_suffix, 1, 3);
      p_data_rec.birth_date            := to_char(l_birth_date,'YYYY-MM-DD');
      p_data_rec.birth_city            := SUBSTR(l_birth_city,1,60);
      p_data_rec.gender                := SUBSTR(l_gender, 1, 1);
      p_data_rec.birth_cntry_code      := SUBSTR(l_birth_cntry_code, 1, 2);
      p_data_rec.citizen_cntry_code    := convert_country_code (l_citizen_cntry_code);
      Put_Log_Msg('ISO Country ('||l_citizen_cntry_code||') converted to US Country ('||l_citizen_cntry_code||') for person:' ||p_data_rec.first_name||' ' ||p_data_rec.last_name||'.',0);
      p_data_rec.birth_cntry_resn_code := NULL;

      OPEN c_country_reason(p_person_rec.person_id);
      FETCH c_country_reason
      INTO l_birth_cntry_resn_code;
      CLOSE c_country_reason;

      p_data_rec.birth_cntry_resn_code := l_birth_cntry_resn_code;

      OPEN c_nonimg_data;
      FETCH c_nonimg_data
      INTO l_visa_type;

      l_visa_type := Convert_Visa_Type (l_visa_type);

      CLOSE c_nonimg_data;

      IF (p_person_rec.batch_type = 'I') THEN

        OPEN c_com_data;
        FETCH c_com_data
        INTO  l_commuter;

        CLOSE c_com_data;

        p_data_rec.commuter              := SUBSTR(l_commuter, 1,1);

      END IF;

      p_data_rec.visa_type             := SUBSTR(l_visa_type, 1, 2);

     IF (p_person_rec.batch_type = 'E') THEN
         OPEN c_ev_data;
         FETCH c_ev_data
          INTO l_position_code,
               l_category_code,
               l_position_remarks;

         IF (c_ev_data%FOUND) THEN

            p_data_rec.position_code        := SUBSTR(l_position_code, 1, 3);
            p_data_rec.category_code        := l_category_code;
            p_data_rec.remarks              := l_position_remarks;

         END IF;

         CLOSE c_ev_data;

         -- 2908378 added to get the legal residency code
         OPEN c_perm_res_data;
         FETCH c_perm_res_data INTO l_legal_res_cntry_code;
         CLOSE c_perm_res_data;

      END IF;
      p_data_rec.legal_res_cntry_code := l_legal_res_cntry_code;
      p_data_rec.batch_id := p_person_rec.batch_id;
      p_data_rec.person_id := p_person_rec.person_id;
      p_data_rec.print_form := p_person_rec.print_form;
      p_data_rec.creation_date := sysdate;
      p_data_rec.created_by := g_update_by;
      p_data_rec.last_updated_by := g_update_by;
      p_data_rec.last_update_date  := sysdate;
      p_data_rec.last_update_login := g_update_login;

      -- change for country code inconsistency bug 3738488
     p_data_rec.birth_cntry_code := convert_country_code(p_data_rec.birth_cntry_code);
     p_data_rec.legal_res_cntry_code := convert_country_code(p_data_rec.legal_res_cntry_code);
   END IF;

   CLOSE c_hz_data;

   IF Validate_Name(p_data_rec.last_name) THEN
	 l_not_valid := TRUE;
	 FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_CHAR');
	 FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
	 Put_Log_Msg(FND_MESSAGE.Get,1);
   END IF;

   IF p_data_rec.birth_cntry_code = 'US' AND p_data_rec.birth_cntry_resn_code IS NULL
        THEN
	 l_not_valid := TRUE;
	 FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_CNTRY_RSN');
	 FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
	 Put_Log_Msg(FND_MESSAGE.Get,1);
   END IF;

   IF (p_data_rec.batch_id IS NULL) THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Bio_Info';
	  l_debug_str := 'Returning N from Validate_Bio_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'N';

   ELSE

      --
      -- Validate all the data for required fields for both types of students
      --
      IF (p_data_rec.last_name IS NULL        OR
          p_data_rec.birth_date IS NULL       OR
          p_data_rec.birth_cntry_code IS NULL) THEN
         l_not_valid := TRUE;
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_BIO_REQ_FLD_ERR'); -- Required fields for both Exchange Visitor or Foreign students
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
         Put_Log_Msg(FND_MESSAGE.Get,1);
      END IF;
      --
      -- Validate all the data for required fields for Foreign students
      --

      IF ( NVL(p_data_rec.visa_type,'X') NOT IN ('01','02') AND p_person_rec.dep_flag ='N' AND p_person_rec.batch_type = 'I')
         OR ( NVL(p_data_rec.visa_type,'X') NOT IN ('04','05') AND p_person_rec.dep_flag ='Y' AND p_person_rec.batch_type = 'I')
         OR ( NVL(p_data_rec.visa_type,'X') <> '03' AND p_person_rec.dep_flag ='N' AND p_person_rec.batch_type = 'E')
         OR ( NVL(p_data_rec.visa_type,'X') <> '06' AND p_person_rec.dep_flag ='Y' AND p_person_rec.batch_type = 'E')    THEN
         l_not_valid := TRUE;
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_BIO_NIMG_REQ_FLD_ERR'); -- Required Fields for Foreign students
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
         Put_Log_Msg(FND_MESSAGE.Get,1);
      END IF;

      -- 2908378 validation of legal residency code, birth city should fire for all persons
      --
      -- Validate all the data for required fields for Exchange Visitor students (even for dependants)
      --

      IF (NVL(p_person_rec.dep_flag,'N') <> 'Y' AND p_person_rec.batch_type = 'E' AND(p_data_rec.legal_res_cntry_code IS NULL OR
           p_data_rec.birth_city IS NULL
           ) ) THEN
         l_not_valid := TRUE;
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_BIO_EV_REQ_FLD_ERR'); -- Required Fields for Exchange Visitor students
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
         Put_Log_Msg(FND_MESSAGE.Get,1);
      END IF;

      -- 2908378 validation of position_code, category_code should not fire for dependants, since they need not have EV form
      --
      -- Validate all the data for required fields for Exchange Visitor students (not for dependants)
      --
      IF (p_person_rec.batch_type = 'E' AND NVL(p_person_rec.dep_flag,'N') <> 'Y' AND(
           p_data_rec.position_code IS NULL OR
           p_data_rec.category_code IS NULL
           ) ) THEN
         l_not_valid := TRUE;
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_BIO_EV_REQ_FLD_ERR'); -- Required Fields for Exchange Visitor students
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
         Put_Log_Msg(FND_MESSAGE.Get,1);
      END IF;


      IF (p_person_rec.batch_type = 'I' AND p_data_rec.citizen_cntry_code IS NULL) THEN
	  l_not_valid := TRUE;
          FND_MESSAGE.SET_NAME('IGS', 'PERSON_NUMBER'); -- Required Fields for Exchange Visitor students
          FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
          Put_Log_Msg(FND_MESSAGE.Get,1);
      END IF;


      IF Check_US_Terr(p_person_rec.person_number,p_data_rec.citizen_cntry_code) ='E' THEN

        --Error in the citizenship countries

         Put_Log_Msg('Error validation citizenship country code',1);
         l_not_valid := TRUE;
      END IF;

      IF NVL(p_person_rec.dep_flag,'N') <> 'Y' AND Check_US_Terr(p_person_rec.person_number,p_data_rec.legal_res_cntry_code) ='E' THEN

        --Error in the citizenship countries

         Put_Log_Msg('Error validation citizenship country code',1);
         l_not_valid := TRUE;
      END IF;


      IF (l_not_valid) THEN

         Put_Log_Msg(l_api_name||' Validation error, return E ',1);
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Bio_Info';
	  l_debug_str := 'Returning E from Validate_Bio_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
         RETURN 'E';

      END IF;

   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Bio_Info';
	  l_debug_str := 'Returning S from Validate_Bio_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Bio_Info';
	  l_debug_str := 'Exception in Validate_Bio_Info.'||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;
      IF c_country_reason%ISOPEN THEN
	CLOSE c_country_reason;
      END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_Bio_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validation on the data block pertaining to
                        Other information.  (IGS_SV_OTH_INFO)

   Remarks            : Return result:
                          'S' - record found and validated
                          'E' - validation error
                          'U' - Unexpected error
                          'N' - data not found

   Change History
   Who                  When            What
   pkpatel              23-APR-2003     Bug 2908378
                                        In all the 3 cursors replaced igs_pe_person_id_typ_v with igs_pe_person_id_typ
                                        Added to find the active record.
                                        In c_get_drivers the region code is to be retrieved from region_cd instead of attribute11
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_Other_Info (
   p_person_rec IN      t_student_rec,
   p_data_rec   IN OUT NOCOPY  IGS_SV_OTH_INFO%ROWTYPE    -- Data record
) RETURN VARCHAR2
IS

   l_api_name CONSTANT VARCHAR(30) := 'Validate_Other_Info';

   CURSOR c_alternate_id(cp_system_person_id_type igs_pe_person_id_typ.s_person_id_type%TYPE) IS
     SELECT palt.api_person_id_uf,
            palt.region_cd
       FROM igs_pe_alt_pers_id       palt,
            igs_pe_person_id_typ     typv
      WHERE typv.s_person_id_type        = cp_system_person_id_type
        AND palt.person_id_type          = typv.person_id_type
        AND palt.pe_person_id            = p_person_rec.person_id
        AND SYSDATE BETWEEN palt.start_dt AND NVL(palt.end_dt,SYSDATE);

   l_drivers_license          IGS_PE_ALT_PERS_ID.api_person_id%TYPE;
   l_drivers_license_state    IGS_PE_ALT_PERS_ID.region_cd%TYPE;
   l_ssn                      IGS_PE_ALT_PERS_ID.api_person_id%TYPE;
   l_new_ssn                  IGS_PE_ALT_PERS_ID.api_person_id%TYPE;
   l_taxid                    IGS_PE_ALT_PERS_ID.api_person_id%TYPE;
   l_not_valid                BOOLEAN := FALSE;
   l_region_cd                IGS_PE_ALT_PERS_ID.region_cd%TYPE;
   lv_region_cd                IGS_PE_ALT_PERS_ID.region_cd%TYPE;

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Other_Info';
	  l_debug_str := 'Entering Validate_Other_Info. Batch_id is '||p_person_rec.batch_id||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   Put_Log_Msg(l_api_name||' starts ',0);

   p_data_rec.batch_id              := NULL;  -- This will tell us if there's been any records found
   p_data_rec.drivers_license       := NULL;
   p_data_rec.drivers_license_state := NULL;
   p_data_rec.ssn                   := NULL;
   p_data_rec.tax_id                := NULL;

   --
   -- Obtain the drivers license information
   --
   OPEN c_alternate_id('DRIVER-LIC');
   FETCH c_alternate_id
    INTO l_drivers_license,
         l_drivers_license_state;

   IF (c_alternate_id%FOUND) THEN
      p_data_rec.drivers_license       := SUBSTR(l_drivers_license, 1, 30);
      p_data_rec.drivers_license_state := SUBSTR(l_drivers_license_state,2);
   END IF;
   CLOSE c_alternate_id;

   -- Obtain the SSN number information
   --
   OPEN c_alternate_id('SSN');
   FETCH c_alternate_id
    INTO l_ssn,l_region_cd;

   IF (c_alternate_id%FOUND) THEN
      p_data_rec.ssn := SUBSTR(l_ssn, 1, 9);
   END IF;
   CLOSE c_alternate_id;

   --
   -- Obtain TAX ID information
   --
   OPEN c_alternate_id('TAXID');
   FETCH c_alternate_id
    INTO l_taxid,lv_region_cd;
Put_Log_Msg('taxid pf person id '||p_person_rec.person_id ||' is '|| l_taxid,0);
   IF (c_alternate_id%FOUND) THEN
      p_data_rec.tax_id := SUBSTR(l_taxid, 1, 9);
      IF Is_Number(p_data_rec.tax_id) = '' OR Is_Number(p_data_rec.tax_id) IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_TAXID');
        FND_MESSAGE.SET_TOKEN('PERSON_NUM', p_person_rec.person_number);
        Put_Log_Msg(FND_MESSAGE.Get,1);
        l_not_valid := true;
      END IF;
   END IF;
   CLOSE c_alternate_id;

   --
   -- Need to validate that the SSN is in correct format 999999999
   --
   IF p_data_rec.ssn IS NOT NULL THEN
     FOR i IN 1 .. LENGTH (l_ssn) LOOP
        l_new_ssn := l_new_ssn || Is_Number(SUBSTR(l_ssn, i, 1));  -- Returns NULL if not numberic value
     END LOOP;
   ELSE
     l_new_ssn := NULL;
   END IF;

   IF (l_new_ssn IS NOT NULL) THEN

      IF (LENGTH(l_new_ssn) <> 9) THEN

         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_WARN_FLD_ERR'); -- Warning message for optional field
         FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'SSN');
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
         Put_Log_Msg(FND_MESSAGE.Get,1);
         p_data_rec.ssn := NULL;   -- Only warning for bad SSN.  Just NULL out value to be sent.

      ELSE

         p_data_rec.ssn := l_new_ssn;

      END IF;

   END IF;

--
-- Check to see if there is a state associated to the license
--
   IF (p_data_rec.drivers_license IS NOT NULL AND
       p_data_rec.drivers_license_state IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_WARN_FLD_ERR'); -- Warning message for optional field
      FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'Drivers License State');
      FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
      Put_Log_Msg(FND_MESSAGE.Get,1);
   END IF;

   IF (p_data_rec.tax_id           IS NOT NULL OR
       p_data_rec.ssn              IS NOT NULL OR
       p_data_rec.drivers_license IS NOT NULL) THEN

      p_data_rec.batch_id          := p_person_rec.batch_id;
      p_data_rec.person_id         := p_person_rec.person_id;
      p_data_rec.print_form        := p_person_rec.print_form;
      p_data_rec.creation_date     := sysdate;
      p_data_rec.created_by        := g_update_by;
      p_data_rec.last_updated_by   := g_update_by;
      p_data_rec.last_update_date  := sysdate;
      p_data_rec.last_update_login := g_update_login;

   END IF;

   IF p_data_rec.batch_id IS NULL THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Other_Info';
	  l_debug_str := 'Returning N from Validate_Other_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   ELSE

      IF (l_not_valid) THEN

         Put_Log_Msg(l_api_name||' Validation error, return E ',1);
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Other_Info';
	  l_debug_str := 'Returning E from Validate_Other_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

         RETURN 'E';

      END IF;

   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Other_Info';
	  l_debug_str := 'Returning S from Validate_Other_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Other_Info';
	  l_debug_str := 'Exception in Validate_Other_Info.'||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_Other_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate data pertaining to the Foreign
                        address information on the student.
                        (IGS_SV_ADDRESSES).

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_F_Addr_Info (
   p_person_rec IN t_student_rec,
   p_data_rec   IN OUT NOCOPY  g_address_rec_type ,  -- Data record
   p_records    OUT NOCOPY  NUMBER   -- number of addressees found
) RETURN VARCHAR2
IS

   l_api_name CONSTANT VARCHAR(30) := 'Validate_F_Addr_Info';

   CURSOR c_addr IS
     SELECT adr.party_site_id,
            addr_line_1,
            addr_line_2,
            addr_line_3,
            addr_line_4,
            city,
            state,
            province,
            country_cd,
            postal_code,
	    identifying_address_flag
       FROM igs_pe_addr_v adr,
            igs_pe_partysiteuse_v usg
      WHERE person_id = p_person_rec.person_id
        AND ( adr.status = 'A' AND SYSDATE BETWEEN NVL(start_dt,SYSDATE) AND NVL(end_dt, SYSDATE + 1) )
        AND usg.party_site_id  = adr.party_site_id
        AND usg.site_use_type  = g_f_addr_usage
        AND usg.active         = 'A';

   l_counter NUMBER(10):= 0;
   l_not_valid boolean  := FALSE;

BEGIN

   Put_Log_Msg(l_api_name||' Starts ',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_F_Addr_Info';
	  l_debug_str := 'Entering Validate_F_Addr_Info. batch_id is '|| p_person_rec.batch_id||' and person_id is '|| p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;


   FOR c_addr_rec IN c_addr LOOP

       l_counter := l_counter +1;

       p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
       p_data_rec(l_counter).person_id := p_person_rec.person_id;
       p_data_rec(l_counter).print_form := p_person_rec.print_form;
       p_data_rec(l_counter).party_site_id := c_addr_rec.party_site_id;
       p_data_rec(l_counter).address_type  := 'F';
       p_data_rec(l_counter).city   :=SUBSTR( c_addr_rec.city,1,60);
       p_data_rec(l_counter).state  := SUBSTR(c_addr_rec.state,1,2);
       p_data_rec(l_counter).postal_code := SUBSTR(c_addr_rec.postal_code,1,20);
       p_data_rec(l_counter).country_code := SUBSTR(c_addr_rec.country_cd,1,2);
       p_data_rec(l_counter).province  := SUBSTR(c_addr_rec.province,1,30);
       p_data_rec(l_counter).stdnt_valid_flag := '';
       p_data_rec(l_counter).creation_date := sysdate;
       p_data_rec(l_counter).created_by := g_update_by;
       p_data_rec(l_counter).last_updated_by := g_update_by;
       p_data_rec(l_counter).last_update_date  := sysdate;
       p_data_rec(l_counter).last_update_login := g_update_login;
       p_data_rec(l_counter).primary_flag := NVL(c_addr_rec.identifying_address_flag,'N');
       -- assignind adress lines
       p_data_rec(l_counter).address_line1 := SUBSTR(c_addr_rec.addr_line_1||c_addr_rec.addr_line_2||c_addr_rec.addr_line_3||c_addr_rec.addr_line_4,1,60);
       p_data_rec(l_counter).address_line2 := SUBSTR(c_addr_rec.addr_line_1||c_addr_rec.addr_line_2||c_addr_rec.addr_line_3||c_addr_rec.addr_line_4,61,120);

	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_F_Addr_Info';
	  l_debug_str := 'Exiting from for loop in Validate_F_Addr_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

       exit;  -- one address is enough

   END LOOP;

   p_records := l_counter;

   IF (l_counter = 0) THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_F_Addr_Info';
	  l_debug_str := 'Returning N from Validate_F_Addr_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   ELSE
        IF is_valid_addr(p_person_rec.batch_type, p_person_rec.person_id, p_data_rec(l_counter).party_site_id) THEN     -- bug 5405935
	     Put_Log_Msg('ISO Country Code ('||p_data_rec(l_counter).country_code||') converted to',0);

	     p_data_rec(l_counter).country_code := convert_country_code (p_data_rec(l_counter).country_code);

	     Put_Log_Msg('US Country Code ('||p_data_rec(l_counter).country_code||') for person id:'|| p_data_rec(l_counter).person_id ||'.',0);

	     IF (p_data_rec(l_counter).country_code IS NULL OR
		 p_data_rec(l_counter).address_line1 IS NULL) THEN

		 FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_F_ADDR_RQD_FLD_ERR'); -- Foreign address block error
		 FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

		 Put_Log_Msg(FND_MESSAGE.Get,1);
		 l_not_valid := TRUE;

	     END IF;
        ELSE
	  -- bug 5405935
	    FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_DUP_ADDRESS'); -- Address already exists
	    Put_Log_Msg(FND_MESSAGE.Get,1);
	    l_not_valid := TRUE;
	END IF;
   END IF;

   IF l_not_valid THEN

     Put_Log_Msg(l_api_name||' Validation error, return E ',1);
     /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_F_Addr_Info';
	  l_debug_str := 'Returning E from Validate_F_Addr_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

     RETURN 'E';

   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_F_Addr_Info';
	  l_debug_str := 'Returning S from Validate_F_Addr_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_F_Addr_Info';
	  l_debug_str := 'Exception in Validate_F_Addr_Info.'||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_F_Addr_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate the US Address block information
                        on the student.  (IGS_SV_ADDRESSES)

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
   gmaheswa            12-Nov-2003    Modified c_addr cursor to select active address records,
                                      as part of address related changes .
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_Us_Addr_Info (
   p_person_rec IN t_student_rec,
   p_data_rec  IN OUT NOCOPY  g_address_rec_type ,  -- Data record
   p_records  IN  NUMBER   -- number of addressees found
) RETURN VARCHAR2
IS

   l_api_name CONSTANT VARCHAR(30) := 'Validate_Us_Addr_Info';

   CURSOR c_addr IS
     SELECT adr.party_site_id,
            addr_line_1,
            addr_line_2,
            addr_line_3,
            addr_line_4,
            city,
            state,
            province,
            country_cd,
            postal_code,
	    adr.identifying_address_flag
       FROM igs_pe_addr_v adr,
            igs_pe_partysiteuse_v usg
      WHERE person_id = p_person_rec.person_id
        AND ( adr.status = 'A' AND SYSDATE BETWEEN NVL(start_dt,SYSDATE) AND NVL(end_dt, SYSDATE + 1) )
        AND usg.party_site_id  = adr.party_site_id
        AND usg.site_use_type  = g_us_addr_usage
        AND usg.active         = 'A';

   l_counter NUMBER(10):= 0;
   l_not_valid BOOLEAN  := FALSE;

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_US_Addr_Info';
	  l_debug_str := 'Entering Validate_US_Addr_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   Put_Log_Msg(l_api_name||' Starts ',0);

   FOR c_addr_rec IN c_addr LOOP

       l_counter := l_counter +1;

       p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
       p_data_rec(l_counter).person_id := p_person_rec.person_id;
       p_data_rec(l_counter).print_form := p_person_rec.print_form;
       p_data_rec(l_counter).party_site_id := c_addr_rec.party_site_id;
       p_data_rec(l_counter).address_type  := 'U';
       p_data_rec(l_counter).address_line1 := SUBSTR(c_addr_rec.addr_line_1||c_addr_rec.addr_line_2||c_addr_rec.addr_line_3||c_addr_rec.addr_line_4,1,60);
       p_data_rec(l_counter).address_line2 := SUBSTR(c_addr_rec.addr_line_1||c_addr_rec.addr_line_2||c_addr_rec.addr_line_3||c_addr_rec.addr_line_4,61,120);
       p_data_rec(l_counter).city   :=SUBSTR( c_addr_rec.city,1,60);
       p_data_rec(l_counter).state  := SUBSTR(c_addr_rec.state,1,2);
       p_data_rec(l_counter).postal_code := substr(c_addr_rec.postal_code,1,5);
       p_data_rec(l_counter).postal_routing_code := substr(c_addr_rec.postal_code,7,4);
       p_data_rec(l_counter).country_code := 'US';
       p_data_rec(l_counter).primary_flag := NVL(c_addr_rec.identifying_address_flag,'N');
       p_data_rec(l_counter).province  := '';
       p_data_rec(l_counter).stdnt_valid_flag := '';
       p_data_rec(l_counter).creation_date := sysdate;
       p_data_rec(l_counter).created_by := g_update_by;
       p_data_rec(l_counter).last_updated_by := g_update_by;
       p_data_rec(l_counter).last_update_date  := sysdate;
       p_data_rec(l_counter).last_update_login := g_update_login;

	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_US_Addr_Info';
	  l_debug_str := 'exiting from for loop in Validate_US_Addr_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

       EXIT;  -- one address is enough

   END LOOP;

   IF (l_counter = 0) THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_US_Addr_Info';
	  l_debug_str := 'Returning N from Validate_US_Addr_Info. ';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'N';
   ELSE

       IF is_valid_addr(p_person_rec.batch_type, p_person_rec.person_id, p_data_rec(l_counter).party_site_id) THEN  -- bug 5405935
	    IF p_data_rec(l_counter).city IS NULL
	       OR p_data_rec(l_counter).state IS NULL
	       OR p_data_rec(l_counter).postal_code IS NULL
	       OR p_data_rec(l_counter).address_line1 IS NULL THEN

		 FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_US_ADDR_RQD_FLD_ERR'); -- US address block error
		 FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

		 Put_Log_Msg(FND_MESSAGE.Get,1);
		 l_not_valid := TRUE;

	     END IF;
       ELSE
	  -- bug 5405935
	    FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_DUP_ADDRESS'); -- Address already exists
	    Put_Log_Msg(FND_MESSAGE.Get,1);
	    l_not_valid := TRUE;
	END IF;

     IF l_not_valid THEN

       Put_Log_Msg(l_api_name||' Validation error, return E ',1);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_US_Addr_Info';
	  l_debug_str := 'Returning E from Validate_US_Addr_Info. ';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

       RETURN 'E';

     END IF;


   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_US_Addr_Info';
	  l_debug_str := 'Returning S from Validate_US_Addr_Info. ';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_US_Addr_Info';
	  l_debug_str := 'Exception in Validate_US_Addr_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_Us_Addr_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate the information pertaining to the
                        Activity Site Address for the student.
                        (IGS_SV_ADDRESSES).

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
   pkpatel              23-APR-2003     Bug No 2908378
                                        Replaced IGS_PE_ADDR_V with IGS_AD_LOCVENUE_ADDR_V while joining with IGS_PE_ACT_SITE
                                        Selected LOCATION_ID instead of PARTY_SITE_ID for these cases.
                                        Added p_data_rec(l_counter).party_site_id := c_addr_rec.party_site_id
   gmaheswa             12-Nov-2003     Modified c_addr cursor to select active address records,
                                        as part of address related changes .
   pkpatel              4-Dec-2003      Bug 3227107 (Used the status column for address)
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_Site_Info (
   p_person_rec IN      t_student_rec,
   p_data_rec   IN OUT NOCOPY  g_address_rec_type ,  -- Data record
   p_records    OUT NOCOPY     NUMBER                -- number of addressees found
) RETURN VARCHAR2
IS


   l_api_name CONSTANT VARCHAR(30) := 'Validate_Site_Info';

   CURSOR c_data_add IS
   -- All addresses with active status for a person
  SELECT 'A' action_type, -- Add site action type
            ps.party_site_id,
            loc.ADDRESS1 addr_line_1 ,
            loc.ADDRESS2 addr_line_2,
            loc.ADDRESS3 addr_line_3,
            loc.ADDRESS4 addr_line_4,
            loc.city,
            loc.state,
            loc.province,
            loc.country country_code,
            loc.postal_code,
	    ps.identifying_address_flag  primary_site,
	    to_char(usg.party_site_id) activity_site_cd,
	    null remarks
       FROM	HZ_LOCATIONS loc,
	        HZ_PARTY_SITES ps,
                IGS_PE_HZ_PTY_SITES IGSPS,
		hz_party_site_uses usg
      WHERE
        PS.LOCATION_ID = Loc.LOCATION_ID
        AND PS.PARTY_SITE_ID = IGSPS.PARTY_SITE_ID (+)
        and ps.party_id = p_person_rec.person_id
        AND ( ps.status = 'A' AND SYSDATE BETWEEN NVL(IGSPS.start_date,SYSDATE) AND NVL(IGSPS.end_date, SYSDATE + 1))
        AND usg.party_site_id  = ps.party_site_id
        AND usg.site_use_type  = g_site_addr_usage
        AND usg.status = 'A'
   UNION
     -- All institution sites assigned as to a person. here location id is selected which
     -- will be stored as party_site id in IGS_SV_ADDRESSES table
     SELECT 'A' action_type, -- Add site action type
            adr.location_id party_site_id, -- this will be passed to party_site_id of IGS_SV_ADDRESSES
            ADDRESS1 addr_line_1,
            ADDRESS2 addr_line_2,
            ADDRESS3 addr_line_3,
            ADDRESS4 addr_line_4,
            city,
            state,
            province,
            country country_code,
            postal_code,
	    usg.primary_flag primary_site,
	    usg.activity_site_cd activity_site_cd,
	    usg.remarks remarks
       FROM  HZ_LOCATIONS adr,
            igs_pe_act_site usg
     WHERE usg.person_id = p_person_rec.person_id
        AND SYSDATE BETWEEN nvl(ADDRESS_EFFECTIVE_DATE,sysdate-1) AND NVL(ADDRESS_EXPIRATION_DATE, SYSDATE + 1)
        AND usg.location_id = adr.location_id
        AND sysdate BETWEEN usg.start_date AND NVL(usg.end_date,sysdate+1);

	--All deleted and previously submited sites
  CURSOR c_data_del IS
     select 'D' action_type,
            ps.party_site_id,
            loc.ADDRESS1 addr_line_1 ,
            loc.ADDRESS2 addr_line_2,
            loc.ADDRESS3 addr_line_3,
            loc.ADDRESS4 addr_line_4,
            loc.city,
            loc.state,
            loc.province,
            loc.country country_code,
            loc.postal_code,
     ps.identifying_address_flag  primary_site,
     to_char(usg.party_site_id) activity_site_cd ,
     null remarks
       from HZ_LOCATIONS loc,
     HZ_PARTY_SITES ps,
     IGS_PE_HZ_PTY_SITES IGSPS,
            hz_party_site_uses usg
      where
        PS.LOCATION_ID = Loc.LOCATION_ID
        AND PS.PARTY_SITE_ID = IGSPS.PARTY_SITE_ID (+)
        and ps.party_id = p_person_rec.person_id
        and ( (IGSPS.end_date is not null and trunc(sysdate) >= IGSPS.end_date )
              or ps.status         <> 'A'
              or usg.status         <> 'A'
             )
        and usg.party_site_id  = ps.party_site_id
        and usg.site_use_type  = g_site_addr_usage
        and usg.party_site_id in
            ( select ad.party_site_id
                from igs_sv_addresses ad,
                     igs_sv_persons pr
               where ad.person_id = pr.person_id
                     and ad.batch_id = pr.batch_id
                     and pr.record_status <> 'E'
                     and ad.person_id = p_person_rec.person_id and ad.address_type not in ('F','U')
            )
   union
     -- all institution sites assigned as to a person
     select 'D' action_type, -- delete site action type
            loc.location_id party_site_id,
            loc.ADDRESS1,
            loc.ADDRESS2,
            loc.ADDRESS3,
            loc.ADDRESS4,
            loc.city,
            loc.state,
            loc.province,
            loc.country country_code,
            loc.postal_code,
     usg.primary_flag primary_site,
     usg.activity_site_cd activity_site_cd,
     usg.remarks remarks
       from HZ_LOCATIONS loc,
            igs_pe_act_site usg
      where
        usg.person_id = p_person_rec.person_id
        and (loc.ADDRESS_EXPIRATION_DATE is not null and loc.ADDRESS_EXPIRATION_DATE <= trunc(sysdate) )
        and usg.location_id = loc.location_id
        and sysdate between usg.start_date and nvl(usg.end_date,sysdate+1)
        and usg.location_id in
            ( select adr1.location_id
              from igs_sv_addresses ad,
                   HZ_LOCATIONS  adr1,
                   igs_sv_persons pr
              where ad.person_id = pr.person_id
                     and ad.batch_id = pr.batch_id
                     and pr.record_status <> 'E'
                     and adr1.location_id = ad.party_site_id  -- in the party_side_id field of igs_sv_addresses location_id is stored for activity sites
                     and ad.person_id = p_person_rec.person_id and ad.address_type not in ('F','U')
            );

  CURSOR c_primary_site IS
	SELECT COUNT('X')
	FROM
	(
	   SELECT a.location_id
	   FROM igs_pe_act_site a
	   WHERE a.person_id = p_person_rec.person_id AND
	       a.primary_flag = 'Y' /*AND
	       (a.end_date IS NULL OR sysdate between a.start_date and a.end_date)*/
	 UNION
	    SELECT adr.party_site_id
	     FROM igs_pe_addr_v adr,
		hz_party_site_uses usg
	     WHERE person_id = p_person_rec.person_id
		AND ( adr.status = 'A' AND SYSDATE BETWEEN NVL(adr.start_dt,SYSDATE) AND NVL(adr.end_dt, SYSDATE + 1))
		AND usg.party_site_id  = adr.party_site_id
		AND usg.site_use_type  = 'SEVIS_SITE_OF_ACTIVITY'
		AND usg.status = 'A'
		AND adr.identifying_address_flag = 'Y'
        )
    ;
   /*
   CURSOR c_activity_site(cp_person_id igs_pe_act_site.activity_site_cd%TYPE) IS
	 SELECT COUNT(a.activity_site_cd)
	 FROM igs_pe_act_site a
	 WHERE a.person_id = p_person_rec.person_id AND
	       (a.end_date IS NULL OR sysdate between a.start_date and a.end_date);
   */
  l_counter  NUMBER(10) :=0;
  l_not_valid BOOLEAN := FALSE;
  l_primary_site_count  NUMBER(10) :=0;
  l_site_count  NUMBER(10) :=0;

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Site_Info';
	  l_debug_str := 'Entering Validate_Site_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' starts ',0);

   p_records := 0;

  /* OPEN c_activity_site(p_person_rec.person_id);
   FETCH c_activity_site INTO l_site_count;
   CLOSE c_activity_site;

   IF l_site_count = 0  THEN
	FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_SITE_REQ');
        FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );
        Put_Log_Msg(FND_MESSAGE.Get,1);
        l_not_valid := TRUE;
   END IF;

*/

   OPEN c_primary_site;
   FETCH c_primary_site INTO l_primary_site_count;
   CLOSE c_primary_site;

   IF l_primary_site_count <> 1  THEN
	FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_PRIMARY_IND');
        FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );
        Put_Log_Msg(FND_MESSAGE.Get,1);
        l_not_valid := TRUE;
   END IF;

   FOR c_addr_rec IN c_data_add LOOP

       l_counter := l_counter +1;

       IF l_counter > 25 AND p_person_rec.batch_id = g_running_create_batch THEN
          IF g_parallel_batches.count > 0 THEN
	       p_data_rec(l_counter).batch_id := g_parallel_batches(1);
	  ELSE
	      p_data_rec(l_counter).batch_id := igs_sv_util.open_new_batch(p_person_rec.person_id, p_person_rec.batch_id,'CONN_JOB');
	      g_parallel_batches(1) := p_data_rec(l_counter).batch_id;
	  END IF;
       ELSE
          p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
       END IF;

     --  p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
       p_data_rec(l_counter).person_id := p_person_rec.person_id;
       p_data_rec(l_counter).print_form := p_person_rec.print_form;
       p_data_rec(l_counter).creation_date := sysdate;
       p_data_rec(l_counter).created_by := g_update_by;
       p_data_rec(l_counter).last_updated_by := g_update_by;
       p_data_rec(l_counter).last_update_date  := sysdate;
       p_data_rec(l_counter).last_update_login := g_update_login;

       -- 2908378 added
       p_data_rec(l_counter).party_site_id := c_addr_rec.party_site_id;
       p_data_rec(l_counter).address_type  := c_addr_rec.action_type;
       p_data_rec(l_counter).address_line1 := SUBSTR(c_addr_rec.addr_line_1||c_addr_rec.addr_line_2||c_addr_rec.addr_line_3||c_addr_rec.addr_line_4,1,60);
       p_data_rec(l_counter).address_line2 := SUBSTR(c_addr_rec.addr_line_1||c_addr_rec.addr_line_2||c_addr_rec.addr_line_3||c_addr_rec.addr_line_4,61,120);
       p_data_rec(l_counter).city   :=SUBSTR( c_addr_rec.city,1,60);
       p_data_rec(l_counter).state  := SUBSTR(c_addr_rec.state,1,2);
       p_data_rec(l_counter).postal_code := substr(c_addr_rec.postal_code,1,5);
       p_data_rec(l_counter).postal_routing_code := substr(c_addr_rec.postal_code,7,4);
       p_data_rec(l_counter).primary_flag := NVL(c_addr_rec.primary_site,'N');
       p_data_rec(l_counter).action_type  := c_addr_rec.action_type;
       p_data_rec(l_counter).activity_site_cd := c_addr_rec.activity_site_cd;
       p_data_rec(l_counter).country_code := c_addr_rec.country_code;
       p_data_rec(l_counter).remarks := c_addr_rec.remarks;

       IF is_valid_addr(p_person_rec.batch_type, p_person_rec.person_id, p_data_rec(l_counter).party_site_id) THEN -- bug 5405935
	       IF p_data_rec(l_counter).city IS NULL
		 OR p_data_rec(l_counter).state IS NULL
		 OR p_data_rec(l_counter).postal_code IS NULL
		 OR p_data_rec(l_counter).address_line1 IS NULL THEN

		   FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_US_ADDR_RQD_FLD_ERR'); -- US address block error
		   FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

		   Put_Log_Msg(FND_MESSAGE.Get,1);
		   l_not_valid := TRUE;

	       END IF;
        ELSE
	  -- bug 5405935
	    FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_DUP_ADDRESS'); -- Address already exists
	    Put_Log_Msg(FND_MESSAGE.Get,1);
	    l_not_valid := TRUE;
	END IF;

   END LOOP;

   FOR c_addr_rec IN c_data_del LOOP

       l_counter := l_counter +1;

       IF l_counter > 25 AND p_person_rec.batch_id = g_running_create_batch THEN
          IF g_parallel_batches.count > 0 THEN
	       p_data_rec(l_counter).batch_id := g_parallel_batches(1);
	  ELSE
	      p_data_rec(l_counter).batch_id := igs_sv_util.open_new_batch(p_person_rec.person_id, p_person_rec.batch_id,'CONN_JOB');
	      g_parallel_batches(1) := p_data_rec(l_counter).batch_id;
	  END IF;
       ELSE
          p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
       END IF;

     --  p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
       p_data_rec(l_counter).person_id := p_person_rec.person_id;
       p_data_rec(l_counter).print_form := p_person_rec.print_form;
       p_data_rec(l_counter).creation_date := sysdate;
       p_data_rec(l_counter).created_by := g_update_by;
       p_data_rec(l_counter).last_updated_by := g_update_by;
       p_data_rec(l_counter).last_update_date  := sysdate;
       p_data_rec(l_counter).last_update_login := g_update_login;

       -- 2908378 added
       p_data_rec(l_counter).party_site_id := c_addr_rec.party_site_id;
       p_data_rec(l_counter).address_type  := c_addr_rec.action_type;
       p_data_rec(l_counter).address_line1 := SUBSTR(c_addr_rec.addr_line_1||c_addr_rec.addr_line_2||c_addr_rec.addr_line_3||c_addr_rec.addr_line_4,1,60);
       p_data_rec(l_counter).address_line2 := SUBSTR(c_addr_rec.addr_line_1||c_addr_rec.addr_line_2||c_addr_rec.addr_line_3||c_addr_rec.addr_line_4,61,120);
       p_data_rec(l_counter).city   :=SUBSTR( c_addr_rec.city,1,60);
       p_data_rec(l_counter).state  := SUBSTR(c_addr_rec.state,1,2);
       p_data_rec(l_counter).postal_code := substr(c_addr_rec.postal_code,1,5);
       p_data_rec(l_counter).postal_routing_code := substr(c_addr_rec.postal_code,7,4);
       p_data_rec(l_counter).primary_flag := c_addr_rec.primary_site;
       p_data_rec(l_counter).action_type  := c_addr_rec.action_type;
       p_data_rec(l_counter).activity_site_cd := c_addr_rec.activity_site_cd;
       p_data_rec(l_counter).country_code := c_addr_rec.country_code;
       p_data_rec(l_counter).remarks := c_addr_rec.remarks;


       IF p_data_rec(l_counter).city IS NULL
         OR p_data_rec(l_counter).state IS NULL
         OR p_data_rec(l_counter).postal_code IS NULL
         OR p_data_rec(l_counter).address_line1 IS NULL THEN

           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_US_ADDR_RQD_FLD_ERR'); -- US address block error
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

           Put_Log_Msg(FND_MESSAGE.Get,1);
           l_not_valid := TRUE;

       END IF;

   END LOOP;

   IF (l_counter = 0) THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Site_Info';
	  l_debug_str := 'Returning N from Validate_Site_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'N';
   ELSIF l_not_valid THEN

       Put_Log_Msg(l_api_name||' Validation error, return E ',1);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Site_Info';
	  l_debug_str := 'Returning E from Validate_Site_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
       RETURN 'E';

   END IF;

   p_records := l_counter;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Site_Info';
	  l_debug_str := 'Returning S from Validate_Site_Info. No of SOA rec: '||l_counter;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Site_Info';
	  l_debug_str := 'Exception in Validate_Site_Info.'||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';


END Validate_Site_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate the information that is pertaining
                        to the Education Block information.
                        (IGS_SV_PRGMS_INFO).

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_Edu_Info (
   p_person_rec IN t_student_rec,
   p_data_rec  IN OUT NOCOPY  IGS_SV_PRGMS_INFO%ROWTYPE
) RETURN VARCHAR2
IS

   l_api_name CONSTANT VARCHAR(30) := 'Validate_Edu_Info';

   CURSOR c_nonimg_data IS
     SELECT penf.education_level,
            penf.primary_major,
            penf.secondary_major,
            penf.minor,
            penf.length_of_study,
            penf.prgm_start_date,
            penf.prgm_end_date,
            decode(penf.english_reqd,'Y','1','0')  english_reqd,
            decode(penf.english_reqd_met,'Y','1','0')  english_reqd_met,
            penf.not_reqd_reason,
            penf.educ_lvl_remarks
       FROM igs_pe_nonimg_form     penf
      WHERE penf.person_id = p_person_rec.person_id
        AND penf.nonimg_form_id = p_person_rec.form_id;

   CURSOR c_ev_data IS
     SELECT peev.position_code,
            peev.subject_field_code,
            peev.subject_field_remarks,
	    prgm_start_date,
	    prgm_end_date
       FROM igs_pe_ev_form   peev
      WHERE peev.person_id  = p_person_rec.person_id
        AND peev.ev_form_id = p_person_rec.form_id;


   l_not_valid                  BOOLEAN := FALSE;
   l_education_level            igs_pe_nonimg_form.education_level%TYPE;
   l_primary_major              igs_pe_nonimg_form.primary_major%TYPE;
   l_secondary_major            igs_pe_nonimg_form.secondary_major%TYPE;
   l_minor                      igs_pe_nonimg_form.minor%TYPE;
   l_length_of_study            igs_pe_nonimg_form.length_of_study%TYPE;
   l_prgm_start_date            igs_pe_nonimg_form.prgm_start_date%TYPE;
   l_prgm_end_date              igs_pe_nonimg_form.prgm_end_date%TYPE;
   l_english_reqd               igs_pe_nonimg_form.english_reqd%TYPE;
   l_english_reqd_met           igs_pe_nonimg_form.english_reqd_met%TYPE;
   l_not_reqd_reason            igs_pe_nonimg_form.not_reqd_reason%TYPE;
   l_educ_lvl_remarks           igs_pe_nonimg_form.educ_lvl_remarks%TYPE;
   l_position_code              igs_pe_ev_form.position_code%TYPE;
   l_subject_field_code         igs_pe_ev_form.subject_field_code%TYPE;
   l_subject_field_remarks      igs_pe_ev_form.subject_field_remarks%TYPE;
   l_ev_prgm_start_date            igs_pe_ev_form.prgm_start_date%TYPE;
   l_ev_prgm_end_date              igs_pe_ev_form.prgm_end_date%TYPE;


BEGIN
/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Edu_Info
	  ';
	  l_debug_str := 'Entering Validate_Edu_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' starts ',0);

   p_data_rec.batch_id := NULL;  -- This will tell us if there's been any records found

--
-- Process Non Immigrant Foreign Student data
--
   IF (p_person_rec.batch_type = 'I') THEN

      OPEN c_nonimg_data;
      FETCH c_nonimg_data
       INTO l_education_level,
            l_primary_major,
            l_secondary_major,
            l_minor,
            l_length_of_study,
            l_prgm_start_date,
            l_prgm_end_date,
            l_english_reqd,
            l_english_reqd_met,
            l_not_reqd_reason,
            l_educ_lvl_remarks;

      IF (c_nonimg_data%FOUND) THEN
         p_data_rec.batch_id          := p_person_rec.batch_id;
         p_data_rec.person_id         := p_person_rec.person_id;
         p_data_rec.print_form        := p_person_rec.print_form;
         p_data_rec.creation_date     := sysdate;
         p_data_rec.created_by        := g_update_by;
         p_data_rec.last_updated_by   := g_update_by;
         p_data_rec.last_update_date  := sysdate;
         p_data_rec.last_update_login := g_update_login;
         p_data_rec.prgm_action_type := 'EP';

         p_data_rec.education_level   := l_education_level;
         p_data_rec.primary_major     := l_primary_major;
         p_data_rec.secondary_major   := l_secondary_major;
         p_data_rec.educ_lvl_remarks  := l_educ_lvl_remarks;
         p_data_rec.minor             := l_minor;
         p_data_rec.length_of_study   := ltrim(to_char(to_number(l_length_of_study),'00'));
         p_data_rec.prgm_start_date   := to_char(l_prgm_start_date, 'YYYY-MM-DD');
         p_data_rec.prgm_end_date     := to_char(l_prgm_end_date, 'YYYY-MM-DD');
         p_data_rec.english_reqd      := l_english_reqd;
         p_data_rec.english_reqd_met  := l_english_reqd_met;
         p_data_rec.not_reqd_reason   := l_not_reqd_reason;

      END IF;

      CLOSE c_nonimg_data;

   ELSE
--
-- Process Exchange Visitor Student data
--
       OPEN c_ev_data;
      FETCH c_ev_data
       INTO l_position_code,
            l_subject_field_code,
            l_subject_field_remarks,
	    l_ev_prgm_start_date,
	    l_ev_prgm_end_date;

      IF (c_ev_data%FOUND) THEN

         p_data_rec.batch_id             := p_person_rec.batch_id;
         p_data_rec.person_id            := p_person_rec.person_id;
         p_data_rec.print_form           := p_person_rec.print_form;
         p_data_rec.creation_date        := sysdate;
         p_data_rec.created_by           := g_update_by;
         p_data_rec.last_updated_by      := g_update_by;
         p_data_rec.last_update_date     := sysdate;
         p_data_rec.last_update_login    := g_update_login;
         p_data_rec.prgm_action_type     := 'EP';
         p_data_rec.position_code        := l_position_code;
         p_data_rec.subject_field_code   := l_subject_field_code;
         p_data_rec.remarks              := l_subject_field_remarks;
	 p_data_rec.prgm_start_date   := to_char(l_ev_prgm_start_date, 'YYYY-MM-DD');
         p_data_rec.prgm_end_date     := to_char(l_ev_prgm_end_date, 'YYYY-MM-DD');

      END IF;

      CLOSE c_ev_data;

   END IF;

   IF p_data_rec.batch_id IS NULL THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Edu_Info';
	  l_debug_str := 'Returning N from Validate_Edu_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'N';

   ELSE

     -- Validate all the data

     IF (p_person_rec.batch_type = 'I') THEN

--
-- Validate that the required fields for Foreign Student are available.
--
        IF (p_data_rec.education_level IS NULL     OR
            p_data_rec.primary_major IS NULL       OR
            p_data_rec.length_of_study IS NULL     OR
            p_data_rec.prgm_start_date IS NULL     OR
            p_data_rec.prgm_end_date IS NULL       OR
            p_data_rec.english_reqd IS NULL) THEN
           l_not_valid := TRUE;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EDU_NIMG_REQ_FLD_ERR'); -- Required fields for Foreign Students
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
           Put_Log_Msg(FND_MESSAGE.Get,1);
        END IF;

--
-- Make sure that there is a value for the English requirement being met or not
--
        IF ( p_data_rec.english_reqd = 'Y'  AND p_data_rec.english_reqd_met IS NULL) THEN
            l_not_valid := TRUE;
            FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EDU_NIMG_MET_ERR'); -- Required field for Foreign students if english required
            FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
            Put_Log_Msg(FND_MESSAGE.Get,1);
        END IF;

        IF ( p_data_rec.education_level = '11'  AND p_data_rec.educ_lvl_remarks IS NULL) THEN
            l_not_valid := TRUE;
            FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EDU_NIMG_REQ_FLD_ERR'); -- Required field for Foreign students if english required
            FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
            Put_Log_Msg(FND_MESSAGE.Get,1);
        END IF;

--
-- Make sure that there is a reason for the requirement not being met.
--
        IF (p_data_rec.english_reqd = 'N'    AND
            p_data_rec.not_reqd_reason IS NULL) THEN
            l_not_valid := TRUE;
            FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EDU_NIMG_NOT_MET_ERR'); -- Required field for Foreign students english not met
            FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
            Put_Log_Msg(FND_MESSAGE.Get,1);
         END IF;

     ELSE

--
-- Validate that the required fields are present for the Exchange Visitor.
--
        IF (p_data_rec.position_code IS NULL
            OR  p_data_rec.subject_field_code IS NULL
            OR p_data_rec.remarks IS NULL)  THEN
           l_not_valid := TRUE;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EDU_EV_REQ_FLD_ERR'); -- Required field for Exchange Visitor not available.
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
           Put_Log_Msg(FND_MESSAGE.Get,1);
        END IF;

     END IF;

     IF (l_not_valid) THEN

        Put_Log_Msg(l_api_name||' Validation error, return E ',1);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Edu_Info';
	  l_debug_str := 'Returning E from Validate_Edu_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
        RETURN 'E';

     END IF;

   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Edu_Info';
	  l_debug_str := 'Returning S from Validate_Edu_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Edu_Info';
	  l_debug_str := 'Exception in Validate_Edu_Info.'||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_Edu_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate information pertaining to the Program
                        information block for the student.
                        (IGS_SV_PRGMS_INFO).

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Othr_Prgm_Info(
 p_data_rec  IN OUT NOCOPY  IGS_SV_PRGMS_INFO%ROWTYPE
) RETURN VARCHAR2
IS
     l_api_name CONSTANT VARCHAR(30) := 'Get_Othr_Prgm_Info';

   CURSOR c_nonimg_data IS
     SELECT penf.education_level,
            penf.primary_major,
            penf.secondary_major,
            penf.minor,
            penf.length_of_study,
            penf.prgm_start_date,
            penf.prgm_end_date,
            decode(penf.english_reqd,'Y','1','0')  english_reqd,
            decode(penf.english_reqd_met,'Y','1','0')  english_reqd_met,
            penf.not_reqd_reason,
            penf.educ_lvl_remarks
       FROM igs_pe_nonimg_form     penf
      WHERE penf.person_id = p_data_rec.person_id
        AND penf.nonimg_form_id = g_nonimg_form_id;

   CURSOR c_ev_data IS
     SELECT peev.position_code,
            peev.subject_field_code,
            peev.subject_field_remarks,
	    prgm_start_date,
	    prgm_end_date
       FROM igs_pe_ev_form   peev
      WHERE peev.person_id  = p_data_rec.person_id
        AND peev.ev_form_id = g_nonimg_form_id;


   l_education_level            igs_pe_nonimg_form.education_level%TYPE;
   l_primary_major              igs_pe_nonimg_form.primary_major%TYPE;
   l_secondary_major            igs_pe_nonimg_form.secondary_major%TYPE;
   l_minor                      igs_pe_nonimg_form.minor%TYPE;
   l_length_of_study            igs_pe_nonimg_form.length_of_study%TYPE;
   l_prgm_start_date            igs_pe_nonimg_form.prgm_start_date%TYPE;
   l_prgm_end_date              igs_pe_nonimg_form.prgm_end_date%TYPE;
   l_english_reqd               igs_pe_nonimg_form.english_reqd%TYPE;
   l_english_reqd_met           igs_pe_nonimg_form.english_reqd_met%TYPE;
   l_not_reqd_reason            igs_pe_nonimg_form.not_reqd_reason%TYPE;
   l_educ_lvl_remarks           igs_pe_nonimg_form.educ_lvl_remarks%TYPE;
   l_position_code              igs_pe_ev_form.position_code%TYPE;
   l_subject_field_code         igs_pe_ev_form.subject_field_code%TYPE;
   l_subject_field_remarks      igs_pe_ev_form.subject_field_remarks%TYPE;
   l_ev_prgm_start_date            igs_pe_ev_form.prgm_start_date%TYPE;
   l_ev_prgm_end_date              igs_pe_ev_form.prgm_end_date%TYPE;
   l_not_valid BOOLEAN := TRUE;
BEGIN

	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Othr_Prgm_Info';
	  l_debug_str := 'Entering Get_Othr_Prgm_Info. form_id is '||g_nonimg_form_id ||' and person_id is '||p_data_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

        Put_Log_Msg(l_api_name||' starts ',0);

      OPEN c_nonimg_data;
      FETCH c_nonimg_data
       INTO l_education_level,
            l_primary_major,
            l_secondary_major,
            l_minor,
            l_length_of_study,
            l_prgm_start_date,
            l_prgm_end_date,
            l_english_reqd,
            l_english_reqd_met,
            l_not_reqd_reason,
            l_educ_lvl_remarks;

      IF (c_nonimg_data%FOUND) THEN
         p_data_rec.education_level   := l_education_level;
         p_data_rec.primary_major     := l_primary_major;
         p_data_rec.secondary_major   := l_secondary_major;
         p_data_rec.educ_lvl_remarks  := l_educ_lvl_remarks;
         p_data_rec.minor             := l_minor;
         p_data_rec.length_of_study   := ltrim(to_char(to_number(l_length_of_study),'00'));
         p_data_rec.prgm_start_date   := to_char(l_prgm_start_date, 'YYYY-MM-DD');
         p_data_rec.prgm_end_date     := to_char(l_prgm_end_date, 'YYYY-MM-DD');
         p_data_rec.english_reqd      := l_english_reqd;
         p_data_rec.english_reqd_met  := l_english_reqd_met;
         p_data_rec.not_reqd_reason   := l_not_reqd_reason;
	 l_not_valid := FALSE;
      ELSE
          OPEN c_ev_data;
          FETCH c_ev_data
	  INTO l_position_code,
	       l_subject_field_code,
	       l_subject_field_remarks,
	       l_ev_prgm_start_date,
	       l_ev_prgm_end_date;

	      IF (c_ev_data%FOUND) THEN
		 p_data_rec.position_code        := l_position_code;
		 p_data_rec.subject_field_code   := l_subject_field_code;
		 p_data_rec.remarks              := l_subject_field_remarks;
		 p_data_rec.prgm_start_date   := to_char(l_ev_prgm_start_date, 'YYYY-MM-DD');
		 p_data_rec.prgm_end_date     := to_char(l_ev_prgm_end_date, 'YYYY-MM-DD');
		 l_not_valid := FALSE;
	      END IF;

	      CLOSE c_ev_data;
      END IF;

      CLOSE c_nonimg_data;
      IF l_not_valid THEN
	  RETURN 'E';
       ELSE
          RETURN 'S'; -- Successfull validation
       END IF;

EXCEPTION

   WHEN OTHERS THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Othr_Prgm_Info';
	  l_debug_str := 'Exception in Get_Othr_Prgm_Info.'||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;
      CLOSE c_ev_data;
      CLOSE c_nonimg_data;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Get_Othr_Prgm_Info;

/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert authorization codes of the student
                        (IGS_SV_PRGMS_INFO).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Auth_Code (
   p_auth_drp_data_rec IN IGS_SV_PRGMS_INFO%ROWTYPE
)
IS

   l_api_name CONSTANT VARCHAR(30) := 'Insert_Auth_Code';
   l_count  NUMBER(10);
   l_action VARCHAR2(30);
   l_btch_id NUMBER(14);
   l_tag_code VARCHAR2(30);
   l_edu_status  VARCHAR2(10);
   l_cur_rec  IGS_SV_PRGMS_INFO%ROWTYPE;


   l_prgm_start_date            igs_Sv_prgms_info.prgm_start_date%TYPE;
   l_prgm_end_date              igs_Sv_prgms_info.prgm_end_date%TYPE;

   l_english_reqd               igs_pe_nonimg_form.english_reqd%TYPE;
   l_english_reqd_met           igs_pe_nonimg_form.english_reqd_met%TYPE;
   l_not_reqd_reason            igs_pe_nonimg_form.not_reqd_reason%TYPE;
   l_position_code              igs_pe_ev_form.position_code%TYPE;
   l_subject_field_code         igs_pe_ev_form.subject_field_code%TYPE;
   l_remarks			igs_pe_ev_form.subject_field_remarks%TYPE;
   l_education_level            igs_pe_nonimg_form.education_level%TYPE;
   l_primary_major              igs_pe_nonimg_form.primary_major%TYPE;
   l_secondary_major            igs_pe_nonimg_form.secondary_major%TYPE;
   l_educ_lvl_remarks           igs_pe_nonimg_form.educ_lvl_remarks%TYPE;
   l_minor                      igs_pe_nonimg_form.minor%TYPE;
   l_length_of_study            igs_pe_nonimg_form.length_of_study%TYPE;



BEGIN
     /* Debug */
    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Auth_Code';
	l_debug_str := 'Entering Insert_Edu_Info. person_id is '||p_auth_drp_data_rec.person_id|| ' and batch_id is '||p_auth_drp_data_rec.batch_id;
	fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

       l_remarks               := p_auth_drp_data_rec.remarks;
       l_prgm_start_date       := p_auth_drp_data_rec.prgm_start_date;
       l_prgm_end_date         := p_auth_drp_data_rec.prgm_end_date;


       /* Debug */
    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Auth_Code';
	l_debug_str := 'After assigning values to local variables';
	fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

	   IF p_auth_drp_data_rec.prgm_action_type = 'DB' THEN
	      IF p_auth_drp_data_rec.auth_action_code = 'A' THEN
                  l_action := 'ADD';
	      ELSIF p_auth_drp_data_rec.auth_action_code = 'U' THEN
                  l_action := 'EDIT';
	      ELSE
	          l_action := 'CANCEL';
	      END IF;
	      l_tag_code := 'SV_AUTH_DROP';
	   END IF;

		l_btch_id := chk_mut_exclusive(p_auth_drp_data_rec.batch_id,
				       p_auth_drp_data_rec.person_id,
				       l_action,
				       l_tag_code);
		Insert_Summary_Info(l_btch_id,
				       p_auth_drp_data_rec.person_id,
				       l_action,
				       l_tag_code,
				       'SEND',
				       'IGS_SV_PRGMS_INFO',
				       p_auth_drp_data_rec.sevis_auth_id);


          l_cur_rec.person_id := p_auth_drp_data_rec.person_id;
	  l_edu_status  := Get_Othr_Prgm_Info (p_data_rec   => l_cur_rec);
	  IF l_edu_status = 'S' THEN
	       l_position_code       := l_cur_rec.position_code;
	       l_subject_field_code  := l_cur_rec.subject_field_code ;
	       l_education_level     := l_cur_rec.education_level;
	       l_primary_major       := l_cur_rec.primary_major;
	       l_secondary_major     := l_cur_rec.secondary_major;
	       l_educ_lvl_remarks    := l_cur_rec.educ_lvl_remarks ;
	       l_minor               := l_cur_rec.minor ;
	       l_length_of_study     := l_cur_rec.length_of_study ;
	       l_english_reqd        := l_cur_rec.english_reqd;
	       l_english_reqd_met    := l_cur_rec.english_reqd_met ;
	       l_not_reqd_reason     := l_cur_rec.not_reqd_reason;

		  /* Debug */
	    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Auth_Code';
		l_debug_str := 'After assigning values received from get_othr_prgm_info to local variables';
		fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	    END IF;
	  END IF;


	   INSERT INTO igs_sv_prgms_info (
		batch_id               ,
		person_id              ,
		prgm_action_type       ,
		position_code          ,
		subject_field_code     ,
		education_level        ,
		primary_major          ,
		secondary_major        ,
		educ_lvl_remarks       ,
		minor                  ,
		length_of_study        ,
		prgm_start_date        ,
		prgm_end_date          ,
		english_reqd           ,
		english_reqd_met       ,
		not_reqd_reason        ,
		authorization_reason   ,
		remarks                ,
		creation_date          ,
		created_by             ,
		last_updated_by        ,
		last_update_date       ,
		last_update_login      ,
		auth_action_code       ,
		sevis_auth_id	       ,
		print_form
	      ) VALUES
	      ( l_btch_id                        ,
	       p_auth_drp_data_rec.person_id              ,
	       p_auth_drp_data_rec.prgm_action_type       ,
	       l_position_code				  ,
	       l_subject_field_code			  ,
	       l_education_level			  ,
	       l_primary_major				  ,
	       l_secondary_major			  ,
	       l_educ_lvl_remarks			  ,
	       l_minor					  ,
	       l_length_of_study			  ,
	       p_auth_drp_data_rec.prgm_start_date        ,
	       p_auth_drp_data_rec.prgm_end_date          ,
	       l_english_reqd				  ,
	       l_english_reqd_met			  ,
	       l_not_reqd_reason			  ,
	       p_auth_drp_data_rec.authorization_reason   ,
	       p_auth_drp_data_rec.remarks                ,
	       p_auth_drp_data_rec.creation_date          ,
	       p_auth_drp_data_rec.created_by             ,
	       p_auth_drp_data_rec.last_updated_by        ,
	       p_auth_drp_data_rec.last_update_date       ,
	       p_auth_drp_data_rec.last_update_login      ,
	       p_auth_drp_data_rec.auth_action_code       ,
	       p_auth_drp_data_rec.sevis_auth_id	  ,
	       '0'
	      );
      /* Debug */
    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Auth_Code';
	l_debug_str := 'Record inserted';
	fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Auth_Code';
   l_debug_str := 'EXCEPTION in Insert_Auth_Code. '||SQLERRM;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Insert_Auth_Code;

FUNCTION Validate_Prgm_Info (
   p_person_rec IN t_student_rec,
   p_data_rec  IN OUT NOCOPY  g_edu_rec_type,
   p_records    OUT NOCOPY     NUMBER ,      -- Number of program records found
   p_auth_drp_data_rec IN OUT NOCOPY g_edu_rec_type
) RETURN VARCHAR2
IS

   l_api_name CONSTANT VARCHAR(30) := 'Validate_Prgm_Info';

   CURSOR c_data IS
     SELECT nonimg_stat_id,
            nonimg_form_id,
            to_char(action_date,'YYYY-MM-DD') action_date,
            action_type,
            to_char(prgm_start_date,'YYYY-MM-DD') prgm_start_date,
            to_char(prgm_end_date,'YYYY-MM-DD') prgm_end_date,
            remarks,
            termination_reason,
	    print_flag, --prbhardw
	    cancel_flag
       FROM igs_pe_nonimg_stat
      WHERE nonimg_form_id = p_person_rec.form_id
            AND nonimg_stat_id NOT IN
            ( SELECT NVL(form_status_id,0)
                FROM igs_sv_prgms_info prg,
                     igs_sv_persons pr
               WHERE prg.person_id = pr.person_id
                     AND prg.batch_id = pr.batch_id
                     AND pr.record_status <> 'E'
                     AND prg.person_id = p_person_rec.person_id
               )
   ORDER BY action_date;

   CURSOR c_ev_data IS
     SELECT ev_form_stat_id    ,
            ev_form_id         ,
            to_char(action_date,'YYYY-MM-DD') action_date,
            action_type        ,
            to_char(prgm_start_date,'YYYY-MM-DD') prgm_start_date,
            to_char(prgm_end_date,'YYYY-MM-DD') prgm_end_date,
            remarks            ,
            termination_reason ,
            end_program_reason
       FROM igs_pe_ev_form_stat
      WHERE ev_form_id = p_person_rec.form_id
            AND ev_form_stat_id NOT IN
            ( SELECT NVL(form_status_id,0)
                FROM igs_sv_prgms_info prg,
                     igs_sv_persons pr
               WHERE prg.person_id = pr.person_id
                     AND pr.record_status <> 'E'
                     AND prg.batch_id = pr.batch_id
                     AND prg.person_id = p_person_rec.person_id)
   ORDER BY action_date;

  CURSOR c_ev_category_data IS
     SELECT category_code,
            prgm_start_date,
            prgm_end_date
       FROM igs_pe_ev_form
      WHERE ev_form_id = p_person_rec.form_id;

  CURSOR c_drp(cp_sevis_auth_id igs_sv_prgms_info.sevis_auth_id%TYPE) IS
   SELECT prgms.authorization_reason,
          prgms.prgm_start_date,
          prgms.prgm_end_date,
          prgms.remarks,
	  prgms.auth_action_code
     FROM igs_sv_prgms_info  prgms,
          igs_sv_persons pr
    WHERE prgms.person_id = pr.person_id
          AND pr.record_status <> 'E'
          AND prgms.person_id  = p_person_rec.person_id
          AND prgms.prgm_action_type  = 'DB'
	  AND prgms.sevis_auth_id = cp_sevis_auth_id
	  AND prgms.batch_id IN
	      ( SELECT max(prs.batch_id)
		 FROM igs_sv_prgms_info prs,
		      igs_sv_persons pr
	       WHERE prs.person_id = pr.person_id
		     AND prs.batch_id = pr.batch_id
		     AND pr.record_status <> 'E'
		     AND prs.person_id = p_person_rec.person_id
		     AND prs.prgm_action_type = 'DB'
		     AND prs.sevis_auth_id = cp_sevis_auth_id
	      );

  CURSOR c_res IS
   SELECT prgms.prgm_start_date,
          prgms.prgm_end_date,
          prgms.remarks
     FROM igs_sv_prgms_info   prgms,
          igs_sv_persons pr
    WHERE prgms.person_id = pr.person_id
          AND prgms.batch_id = pr.batch_id
          AND pr.record_status <> 'E'
          AND prgms.person_id         = p_person_rec.person_id
          AND prgms.prgm_action_type  = 'RF';


   CURSOR c_visa_type IS
    SELECT visa_type
    FROM IGS_PE_NONIMG_FORM
    WHERE nonimg_form_id = p_person_rec.form_id;

   CURSOR c_termination_reason(p_visa varchar2, p_term_reason igs_pe_nonimg_stat.termination_reason%TYPE) IS
      SELECT COUNT(1)
      FROM igs_pe_nonimg_stat
      WHERE nonimg_form_id = p_person_rec.form_id
            AND p_term_reason NOT IN
            ( SELECT lookup_code FROM igs_lookup_values
	      WHERE lookup_type ='PE_SV_TERMINATE_REASON' AND
		    enabled_flag ='Y' AND
		    (tag= p_visa OR tag= 'FM')
	     );

   --prbhardw
   CURSOR c_prev_end_date IS
     SELECT
          PRGM_END_DATE
     FROM
          IGS_PE_NONIMG_FORM_V
     WHERE
          nonimg_form_id = p_person_rec.form_id;

    CURSOR c_auth_details(cp_person_id igs_sv_prgms_info.person_id%TYPE)
     IS
       SELECT sevis_auth_id, sevis_authorization_code, start_dt, end_dt, comments, cancel_flag
       FROM igs_en_svs_auth
       WHERE person_id = cp_person_id;

    CURSOR c_prgm_dates(cp_person_id igs_sv_prgms_info.person_id%TYPE)
     IS
       SELECT prgm_start_date, prgm_end_date, visa_type
       FROM igs_pe_nonimg_form
       WHERE person_id = cp_person_id
             AND nonimg_form_id = p_person_rec.form_id;



   l_not_valid     BOOLEAN := FALSE;
   l_AUTH_CODE     igs_en_svs_auth.sevis_authorization_code%TYPE;
   l_AUTH_START_DT DATE;
   l_AUTH_END_DT   DATE;
   l_COMMENTS      VARCHAR2(500);
   l_visa_type VARCHAR2(5);
   l_termination_count NUMBER := 0;
   l_category_code  VARCHAR2(30);
   l_prgm_start_dt DATE;
   l_prgm_end_dt   DATE;
   lv_prgm_end_dt DATE;
   l_cancel_flag  VARCHAR2(1);    -- will go as fifth OUT parameter in ENRF_GET_SEVIS_AUTH_DETAILS
   l_auth_rec_count NUMBER(2) := 0;
   l_counter NUMBER(10):= 0;
   l_sevis_auth_id  igs_sv_prgms_info.sevis_auth_id%TYPE;
   c_drp_rec c_drp%ROWTYPE;
BEGIN

	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
	  l_debug_str := 'Entering Validate_Prgm_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' starts ',0);

--   p_data_rec.batch_id := NULL;  -- This will tell us if there's been any records found
   IF p_person_rec.batch_type = 'I' THEN

     -- RF Resume Full Course  STUB - doesn't exist
     -- DB Dropped Below Full Course
     --  Check for drop below FC
      --prbhardw auth_drop_below
     OPEN c_prgm_dates(p_person_rec.person_id);
     FETCH c_prgm_dates INTO l_prgm_start_dt, l_prgm_end_dt, l_visa_type;
     CLOSE c_prgm_dates;

     Put_Log_Msg('Validating NI ',0);

     FOR c_auth_details_rec IN c_auth_details(p_person_rec.person_id) LOOP
	  l_sevis_auth_id := c_auth_details_rec.sevis_auth_id;
	  l_auth_code := c_auth_details_rec.sevis_authorization_code;
	  l_auth_start_dt := c_auth_details_rec.start_dt;
	  l_auth_end_dt := c_auth_details_rec.end_dt;
	  l_comments := c_auth_details_rec.comments;
	  l_cancel_flag := c_auth_details_rec.cancel_flag;

	l_auth_rec_count := l_auth_rec_count +1;

	p_auth_drp_data_rec(l_auth_rec_count).prgm_action_type := '';
        p_auth_drp_data_rec(l_auth_rec_count).auth_action_code := '';

        p_auth_drp_data_rec(l_auth_rec_count).authorization_reason := l_auth_code; --c_auth_details_rec.sevis_authorization_code;
	p_auth_drp_data_rec(l_auth_rec_count).prgm_start_date := to_char(l_auth_start_dt,'YYYY-MM-DD');
        p_auth_drp_data_rec(l_auth_rec_count).prgm_end_date := to_char(l_auth_end_dt,'YYYY-MM-DD');
        p_auth_drp_data_rec(l_auth_rec_count).remarks := l_comments;
	p_auth_drp_data_rec(l_auth_rec_count).sevis_auth_id := l_sevis_auth_id;

	Put_Log_Msg('validating Authorization. Values srt. SEVIS auth ID: '||l_sevis_auth_id,0);
	/* Debug */
	   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
	       l_debug_str := 'Comparing values for authorization code. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	   END IF;

	  OPEN c_drp(l_sevis_auth_id);
	  FETCH c_drp INTO c_drp_rec;
          IF c_drp%FOUND THEN
	        Put_Log_Msg('validating Authorization. Record found in staging table',0);
		  IF l_cancel_flag <> 'Y' THEN
			  IF c_drp_rec.authorization_reason
			     ||g_delimeter||c_drp_rec.prgm_start_date
			     ||g_delimeter||c_drp_rec.prgm_end_date
			     ||g_delimeter||c_drp_rec.remarks <>
			     l_auth_code
			     ||g_delimeter||to_char(l_auth_start_dt,'YYYY-MM-DD')
			     ||g_delimeter||to_char(l_auth_end_dt,'YYYY-MM-DD')
			     ||g_delimeter||l_comments THEN

			     p_auth_drp_data_rec(l_auth_rec_count).auth_action_code := 'U';
			     p_auth_drp_data_rec(l_auth_rec_count).prgm_action_type :='DB';
			   --ELSE  prbhardw EN change
			    --  p_auth_drp_data_rec.auth_action_code := c_drp_rec.auth_action_code;
			   END IF;
		  ELSIF c_drp_rec.auth_action_code <> 'C' THEN
		       p_auth_drp_data_rec(l_auth_rec_count).auth_action_code := 'C';
		       p_auth_drp_data_rec(l_auth_rec_count).prgm_action_type :='DB';
		  END IF;
          ELSE
		Put_Log_Msg('validating Authorization. Record going for first time',0);
		p_auth_drp_data_rec(l_auth_rec_count).auth_action_code := 'A';
	        p_auth_drp_data_rec(l_auth_rec_count).prgm_action_type :='DB';
	  END IF;
	  CLOSE c_drp;

	  /* Debug */
	   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
	       l_debug_str := 'Authorization values set. action type is '||p_auth_drp_data_rec(l_auth_rec_count).prgm_action_type ||' and action code is '||p_auth_drp_data_rec(l_auth_rec_count).auth_action_code;
	       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	   END IF;


        IF p_auth_drp_data_rec(l_auth_rec_count).auth_action_code IS NOT NULL AND p_auth_drp_data_rec(l_auth_rec_count).prgm_action_type IS NOT NULL THEN
	        Put_Log_Msg('validations start for Authorization.',0);
		 p_auth_drp_data_rec(l_auth_rec_count).batch_id  := p_person_rec.batch_id;
		 p_auth_drp_data_rec(l_auth_rec_count).person_id := p_person_rec.person_id;
		 p_auth_drp_data_rec(l_auth_rec_count).creation_date := sysdate;
		 p_auth_drp_data_rec(l_auth_rec_count).created_by := g_update_by;
		 p_auth_drp_data_rec(l_auth_rec_count).last_updated_by := g_update_by;
		 p_auth_drp_data_rec(l_auth_rec_count).last_update_date  := sysdate;
		 p_auth_drp_data_rec(l_auth_rec_count).last_update_login := g_update_login;

		IF ADD_MONTHS(l_auth_end_dt,-12) > l_auth_start_dt AND l_visa_type = 'F-1' THEN
		    FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_ATH_DRP_BLW_DR');
		    FND_MESSAGE.SET_TOKEN('PERSON_NUM', p_person_rec.person_number );
		    FND_MESSAGE.SET_TOKEN('MON', '12');
		    FND_MESSAGE.SET_TOKEN('VISA_TYPE', 'F-1');
		    Put_Log_Msg(FND_MESSAGE.Get,1);
		    l_not_valid := TRUE;
		    /* Debug */
		   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
		       l_debug_str := 'Validation failure for Authorization. Error: Invalid authorization drop below for F-1 visa';
		       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		   END IF;
		ELSIF ADD_MONTHS(l_auth_end_dt,-5) > l_auth_start_dt AND l_visa_type = 'M-1' THEN
		    FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_AUTH_DRP_BLW');
		    FND_MESSAGE.SET_TOKEN('PERSON_NUM', p_person_rec.person_number );
		    FND_MESSAGE.SET_TOKEN('MON', '5');
		    FND_MESSAGE.SET_TOKEN('VISA_TYPE', 'M-1');
		    Put_Log_Msg(FND_MESSAGE.Get,1);
		    l_not_valid := TRUE;
		    /* Debug */
		   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
		       l_debug_str := 'Validation failure for Authorization. Error: Invalid authorization drop below for M-1 visa';
		       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		   END IF;
		END IF;


		IF p_auth_drp_data_rec(l_auth_rec_count).auth_action_code = 'A' THEN
		       Put_Log_Msg('validating Authorization in add mode',0);
			    IF ((l_auth_start_dt <= sysdate) OR (l_auth_start_dt <= l_prgm_start_dt)) THEN
				 FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_AUTH_ST_DT'); --  Invalid authorization start date
				 FND_MESSAGE.SET_TOKEN('PERSON_NUM', p_person_rec.person_number );
				 Put_Log_Msg(FND_MESSAGE.Get,1);
				 l_not_valid := TRUE;
				 /* Debug */
				   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
				       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
				       l_debug_str := 'Validation failure for Authorization. Error: Invalid authorization start date';
				       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
				   END IF;
			    END IF;
			    IF ((l_auth_end_dt <= sysdate) OR (l_auth_end_dt >= l_prgm_end_dt)) THEN
				 FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_AUTH_END_DT'); --  Invalid authorization end date
				 FND_MESSAGE.SET_TOKEN('PERSON_NUM', p_person_rec.person_number );
				 Put_Log_Msg(FND_MESSAGE.Get,1);
				 l_not_valid := TRUE;
				 /* Debug */
				   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
				       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
				       l_debug_str := 'Validation failure for Authorization. Error: Invalid authorization end date';
				       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
				   END IF;
			    END IF;

		END IF;
	END IF;
	  IF l_not_valid THEN
	      Put_Log_Msg('validating Authorization. l_not_valid is true',0);
	      Put_Log_Msg(l_api_name||' Validation error, return E ',1);
	      /* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
		  l_debug_str := 'Returning E from Validate_Prgm_Info. Authorization code failed to validate.';
		  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

	      RETURN 'E';

	END IF;
     END LOOP;
  Put_Log_Msg('validating Authorization. Number of records found '||l_auth_rec_count,0);

--prbhardw auth_drop_below
    /*
    IF p_data_rec(1).prgm_action_type = '' AND IGS_EN_SEVIS.ENRF_GET_RET_FT_NOTE_DETAILS(
           p_person_id     => p_person_rec.person_id,
           P_NOTE_TYPE     => l_auth_code,
           P_NOTE_START_DT => l_auth_start_dt,
           P_NOTE_END_DT   => l_auth_end_dt,
           P_NOTE_TEXT     => l_comments )

      THEN

        p_data_rec(1).prgm_action_type :='RF';
        p_data_rec(1).prgm_start_date := to_char(l_auth_start_dt,'YYYY-MM-DD');
        p_data_rec(1).prgm_end_date := to_char(l_auth_end_dt,'YYYY-MM-DD');
        p_data_rec(1).remarks := l_comments;


        FOR c_drp_rec IN c_res LOOP


          IF c_drp_rec.prgm_start_date
             ||g_delimeter||c_drp_rec.prgm_end_date
             ||g_delimeter||c_drp_rec.remarks =
             to_char(l_auth_start_dt,'YYYY-MM-DD')
             ||g_delimeter||to_char(l_auth_end_dt,'YYYY-MM-DD')
             ||g_delimeter||l_comments THEN

             -- already reported.
             p_data_rec(1).prgm_action_type :='';
             p_data_rec(1).authorization_reason := '';
             p_data_rec(1).prgm_start_date := '';
             p_data_rec(1).prgm_end_date := '';
             p_data_rec(1).remarks := '';
             p_data_rec(1).auth_action_code := '';

           END IF;


        END LOOP;

     END IF;
      */

       FOR c_data_rec IN c_data LOOP
	 l_counter := l_counter +1;
         p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
         p_data_rec(l_counter).person_id := p_person_rec.person_id;
         --p_data_rec.print_form := p_person_rec.print_form; prbhardw
         p_data_rec(l_counter).creation_date := sysdate;
         p_data_rec(l_counter).created_by := g_update_by;
         p_data_rec(l_counter).last_updated_by := g_update_by;
         p_data_rec(l_counter).last_update_date  := sysdate;
         p_data_rec(l_counter).last_update_login := g_update_login;

         p_data_rec(l_counter).prgm_action_type        := c_data_rec.action_type;
         p_data_rec(l_counter).print_form              := c_data_rec.print_flag; -- prbhardw
         p_data_rec(l_counter).form_status_id          := c_data_rec.nonimg_stat_id;
         p_data_rec(l_counter).prgm_start_date         := c_data_rec.prgm_start_date;
         p_data_rec(l_counter).prgm_end_date           := c_data_rec.prgm_end_date;
         p_data_rec(l_counter).effective_date          := c_data_rec.action_date  ;
         p_data_rec(l_counter).termination_reason      := c_data_rec.termination_reason  ;
         p_data_rec(l_counter).remarks                 := c_data_rec.remarks  ;
	 IF c_data_rec.cancel_flag = 'Y' THEN    -- prbhardw
	       p_data_rec(l_counter).prgm_action_type   := 'CE';
	 END IF;


	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
	  l_debug_str := 'Exiting from for loop in Validate_Prgm_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      --   EXIT;  -- one  record is enough
	-- Validate all the data
	     -- Nonimg action types:
	     -- C  Complete Program
	     -- T  Terminate Program
	     -- D  Defer program
	     -- E  Extend program

	     OPEN c_visa_type;
	     FETCH c_visa_type INTO l_visa_type;
	     CLOSE c_visa_type;

	     IF p_data_rec(l_counter).prgm_action_type  = 'C' THEN
	       -- No validation at this time

	       NULL;

	     ELSIF p_data_rec(l_counter).prgm_action_type  = 'D' AND
		   (  p_data_rec(l_counter).prgm_start_date IS NULL
		      OR p_data_rec(l_counter).prgm_end_date IS NULL)  THEN

		FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_CMP_PRG_RQD_FLD_ERR'); --  Completion block error
		FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

		Put_Log_Msg(FND_MESSAGE.Get,1);
		l_not_valid := TRUE;

	     ELSIF p_data_rec(l_counter).prgm_action_type  = 'T'  AND  p_data_rec(l_counter).termination_reason IS NULL  THEN

		FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_TRM_PRG_RQD_FLD_ERR'); -- Termination block error
		FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

		Put_Log_Msg(FND_MESSAGE.Get,1);
		l_not_valid := TRUE;
	     ELSIF p_data_rec(l_counter).prgm_action_type  = 'T'  AND l_visa_type= 'M-1' THEN
	       OPEN c_termination_reason('M', p_data_rec(l_counter).termination_reason);
	       FETCH c_termination_reason INTO l_termination_count;
	       CLOSE c_termination_reason;
	       IF l_termination_count > 0 THEN
		 FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_TERM_REASON');
		 FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );
		 Put_Log_Msg(FND_MESSAGE.Get,1);
		 l_not_valid := TRUE;
	       END IF;
	     ELSIF p_data_rec(l_counter).prgm_action_type  = 'T'  AND l_visa_type= 'F-1' THEN
		OPEN c_termination_reason('F', p_data_rec(l_counter).termination_reason);
	       FETCH c_termination_reason INTO l_termination_count;
	       CLOSE c_termination_reason;
	       IF l_termination_count > 0 THEN
		 FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_TERM_REASON');
		 FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );
		 Put_Log_Msg(FND_MESSAGE.Get,1);
		 l_not_valid := TRUE;
	       END IF;

	     ELSIF p_data_rec(l_counter).prgm_action_type  = 'E'  AND
		   (  p_data_rec(l_counter).remarks IS NULL
		      OR p_data_rec(l_counter).prgm_end_date IS NULL)  THEN

		FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EXT_PRG_RQD_FLD_ERR'); -- Extention block error
		FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

		Put_Log_Msg(FND_MESSAGE.Get,1);
		l_not_valid := TRUE;

	     END IF;

	     --prbhardw
	     IF p_data_rec(l_counter).prgm_action_type  = 'E'  THEN
		  OPEN c_prev_end_date;
		  FETCH c_prev_end_date INTO lv_prgm_end_dt;
		  CLOSE c_prev_end_date;
		  IF to_date(p_data_rec(l_counter).prgm_end_date,'YYYY-MM-DD') > ADD_MONTHS(lv_prgm_end_dt,12)  THEN
			FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_EXT_PRG_DRN'); -- Extention block error
			Put_Log_Msg(FND_MESSAGE.Get,1);
			l_not_valid := TRUE;
		  END IF;

	     END IF;
	     IF l_not_valid THEN
	        Put_Log_Msg(l_api_name||' Validation error, return E ',1);
	      /* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
		  l_debug_str := 'Returning E from Validate_Prgm_Info.';
		  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

	        RETURN 'E';

	     END IF;
       END LOOP;



   ELSE  -- BATCH TYPE IS 'E'

     FOR c_data_rec IN c_ev_data LOOP
       l_counter := l_counter +1;
       p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
       p_data_rec(l_counter).person_id := p_person_rec.person_id;
       p_data_rec(l_counter).print_form := p_person_rec.print_form;
       p_data_rec(l_counter).creation_date := sysdate;
       p_data_rec(l_counter).created_by := g_update_by;
       p_data_rec(l_counter).last_updated_by := g_update_by;
       p_data_rec(l_counter).last_update_date  := sysdate;
       p_data_rec(l_counter).last_update_login := g_update_login;

       p_data_rec(l_counter).prgm_action_type        := c_data_rec.action_type;
       p_data_rec(l_counter).form_status_id          := c_data_rec.ev_form_stat_id;
       p_data_rec(l_counter).prgm_start_date         := c_data_rec.prgm_start_date  ;
       p_data_rec(l_counter).prgm_end_date           := c_data_rec.prgm_end_date  ;
       p_data_rec(l_counter).effective_date          := c_data_rec.action_date  ;
       p_data_rec(l_counter).termination_reason      := c_data_rec.termination_reason  ;
       p_data_rec(l_counter).end_prgm_reason         := c_data_rec.end_program_reason  ;
       p_data_rec(l_counter).remarks                 := c_data_rec.remarks  ;
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
	  l_debug_str := 'Exiting from for loop in Validate_Prgm_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   --    EXIT;  -- one  record is enough
	 -- Validate EV date
     -- AP Amend Program
     -- EE Exchange Visitor Extension
     -- EF Extend Failure
     -- CF Conclude Failure
     -- AF Approve Failure
     -- OI Other Infraction
     -- TR Terminate Exchange Visitor
     -- ED End Program

     -- EM Exchange Visitor Matriculation ???
     -- US Update Subject Field
     -- RF Reprint Form
       OPEN c_ev_category_data;
       FETCH c_ev_category_data INTO
       l_category_code,
       l_prgm_start_dt,
       l_prgm_end_dt;
       CLOSE c_ev_category_data;

       IF l_category_code = '2A' AND l_prgm_end_dt > ADD_MONTHS(l_prgm_start_dt,24)  THEN
	       FND_MESSAGE.SET_NAME('IGS','IGS_SV_INV_PROG_DURN');
	       FND_MESSAGE.SET_TOKEN('PROGDURATION','not exceed 24 months');
	       Put_Log_Msg(FND_MESSAGE.Get,1);
	       l_not_valid := TRUE;
       END IF;

       IF p_data_rec(l_counter).prgm_action_type = 'EM' AND p_data_rec(l_counter).prgm_end_date < trunc(SYSDATE) THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INV_PRGM_END_DT');
          FND_MESSAGE.SET_TOKEN('PERSON_NUM', p_person_rec.person_number );
          Put_Log_Msg(FND_MESSAGE.Get,1);
          l_not_valid := TRUE;
       END IF;

       IF p_data_rec(l_counter).prgm_action_type  = 'AP' AND -- AP Amend Program
           (  p_data_rec(l_counter).prgm_start_date IS NULL
              OR p_data_rec(l_counter).prgm_end_date IS NULL)  THEN

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EV_PRG_RQD_FLD_ERR');
          FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

          Put_Log_Msg(FND_MESSAGE.Get,1);
          l_not_valid := TRUE;

        ELSIF p_data_rec(l_counter).prgm_action_type  IN ('EE','EF')  AND -- EE Exchange Visitor Extension,  EF Extend Failure
           (  p_data_rec(l_counter).prgm_end_date IS NULL)  THEN

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EV_PRG_RQD_FLD_ERR');
          FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

          Put_Log_Msg(FND_MESSAGE.Get,1);
          l_not_valid := TRUE;

       ELSIF p_data_rec(l_counter).prgm_action_type  IN ('SP')  AND
             p_data_rec(l_counter).remarks IS NULL THEN
       -- AF Approve Failure
       -- OI Other Infraction

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EV_PRG_RQD_FLD_ERR'); --  Amend program block error
          FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

          Put_Log_Msg(FND_MESSAGE.Get,1);
          l_not_valid := TRUE;


        ELSIF p_data_rec(l_counter).prgm_action_type  = 'TR'  AND       -- TR Terminate Exchange Visitor
             ( p_data_rec(l_counter).termination_reason IS NULL
               OR p_data_rec(l_counter).effective_date IS NULL ) THEN

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_TRM_PRG_RQD_FLD_ERR'); -- Termination block error
          FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

          Put_Log_Msg(FND_MESSAGE.Get,1);
          l_not_valid := TRUE;

        ELSIF p_data_rec(l_counter).prgm_action_type  = 'ED'  AND       -- ED End Program
             ( p_data_rec(l_counter).end_prgm_reason IS NULL
               OR p_data_rec(l_counter).effective_date IS NULL ) THEN

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_TRM_PRG_RQD_FLD_ERR'); -- Termination block error
          FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

          Put_Log_Msg(FND_MESSAGE.Get,1);
          l_not_valid := TRUE;


        END IF;

	IF p_data_rec(l_counter).prgm_action_type  = 'TR'  AND p_data_rec(l_counter).termination_reason = 'OTHER'
	    AND p_data_rec(l_counter).remarks IS NULL  THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_TRM_REM_RQD');
		FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );
		Put_Log_Msg(FND_MESSAGE.Get,1);
		l_not_valid := TRUE;
	END IF;

	IF l_not_valid THEN
	      Put_Log_Msg(l_api_name||' Validation error, return E ',1);
	      /* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
		  l_debug_str := 'Returning E from Validate_Prgm_Info.';
		  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

	      RETURN 'E';

	END IF;

     END LOOP;

   END IF;
   p_records := l_counter;
   IF l_counter = 0 AND l_auth_rec_count = 0 THEN
      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
	  l_debug_str := 'Returning N from validate_empl_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';
   END IF;


   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
	  l_debug_str := 'Returning S from Validate_Prgm_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Prgm_Info';
	  l_debug_str := 'Exception in Validate_Prgm_Info.'||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_Prgm_Info;

/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate information pertaining to the Finance
                        information of the student.
                        (IGS_SV_FINANCE_INFO).

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_Finance_Info (
   p_person_rec IN t_student_rec,
   p_data_rec  IN OUT NOCOPY  IGS_SV_FINANCE_INFO%ROWTYPE    -- Data record
) RETURN VARCHAR2
IS

   l_api_name CONSTANT VARCHAR(30) := 'Validate_Finance_Info';

   CURSOR c_nimg_data IS
     SELECT acad_term_length,
            tuition_amt,
            living_exp_amt,
            depdnt_exp_amt  dependent_exp_amt,
            other_exp_amt,
            other_exp_desc,
            personal_funds_amt,
            school_funds_amt,
            school_funds_desc,
            other_funds_amt,
            other_funds_desc,
            empl_funds_amt,
            remarks
       FROM igs_pe_nonimg_form     penf
      WHERE penf.person_id      = p_person_rec.person_id
        AND penf.nonimg_form_id = p_person_rec.form_id;

   CURSOR c_ev_data IS
     SELECT prgm_sponsor_amt program_sponsor,
            govt_org1_amt,
            govt_org2_amt,
            govt_org1_code,
            govt_org2_code,
            intl_org1_amt,
            intl_org2_amt,
            intl_org1_code,
            intl_org2_code,
            ev_govt_amt,
            bi_natnl_com_amt,
            other_govt_amt,
            personal_funds_amt,
            remarks,
            NVL(NVL(govt_org2_amt,govt_org1_amt),'0') recvd_us_gvt_funds_ind,
	    govt_org1_othr_name    ,
	    govt_org2_othr_name    ,
            intl_org1_othr_name    ,
            intl_org2_othr_name    ,
	    other_govt_name
       FROM igs_pe_ev_form     evf
      WHERE evf.person_id  = p_person_rec.person_id
        AND evf.ev_form_id = p_person_rec.form_id;

   l_not_valid               BOOLEAN := FALSE;
   l_acad_term_length        igs_pe_nonimg_form.acad_term_length%TYPE;
   l_tuition                 igs_pe_nonimg_form.tuition_amt%TYPE;
   l_living_exp              igs_pe_nonimg_form.living_exp_amt%TYPE;
   l_dependent_exp           igs_pe_nonimg_form.depdnt_exp_amt%TYPE;
   l_other_exp               igs_pe_nonimg_form.other_exp_amt%TYPE;
   l_other_exp_desc          igs_pe_nonimg_form.other_exp_desc%TYPE;
   l_personal_funds          igs_pe_nonimg_form.personal_funds_amt%TYPE;
   l_school_funds            igs_pe_nonimg_form.school_funds_amt%TYPE;
   l_school_funds_desc       igs_pe_nonimg_form.school_funds_desc%TYPE;
   l_other_funds             igs_pe_nonimg_form.other_funds_amt%TYPE;
   l_other_funds_desc        igs_pe_nonimg_form.other_funds_desc%TYPE;
   l_empl_funds              igs_pe_nonimg_form.empl_funds_amt%TYPE;
   l_remarks                 igs_pe_nonimg_form.remarks%TYPE;
   l_program_sponsor         igs_pe_ev_form.prgm_sponsor_amt%TYPE;
   l_govt_org1               igs_pe_ev_form.govt_org1_amt%TYPE;
   l_govt_org2               igs_pe_ev_form.govt_org2_amt%TYPE;
   l_govt_org1_code          igs_pe_ev_form.govt_org1_code%TYPE;
   l_govt_org2_code          igs_pe_ev_form.govt_org2_code%TYPE;
   l_intl_org1               igs_pe_ev_form.intl_org1_amt%TYPE;
   l_intl_org2               igs_pe_ev_form.intl_org2_amt%TYPE;
   l_intl_org1_code          igs_pe_ev_form.intl_org1_code%TYPE;
   l_intl_org2_code          igs_pe_ev_form.intl_org2_code%TYPE;
   l_ev_govt                 igs_pe_ev_form.ev_govt_amt%TYPE;
   l_bi_natnl_com            igs_pe_ev_form.bi_natnl_com_amt%TYPE;
   l_other_org               igs_pe_ev_form.other_govt_amt%TYPE;
   l_recvd_us_gvt_fund_amt   VARCHAR2(30);
   l_govt_org1_othr_name     igs_pe_ev_form.govt_org1_othr_name%TYPE;
   l_govt_org2_othr_name     igs_pe_ev_form.govt_org2_othr_name%TYPE;
   l_intl_org1_othr_name     igs_pe_ev_form.intl_org1_othr_name%TYPE;
   l_intl_org2_othr_name     igs_pe_ev_form.intl_org2_othr_name%TYPE;
   l_other_govt_name	     igs_pe_ev_form.other_govt_name%TYPE;


BEGIN

   Put_Log_Msg(l_api_name||' starts ',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Finance_Info';
	  l_debug_str := 'Entering Validate_Finance_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   p_data_rec.batch_id := NULL;  -- This will tell us if there's been any records found

--
-- Process the Foreign Student information
--
   IF (p_person_rec.batch_type = 'I') THEN

      OPEN c_nimg_data;
      FETCH c_nimg_data
       INTO l_acad_term_length,
            l_tuition,
            l_living_exp,
            l_dependent_exp,
            l_other_exp,
            l_other_exp_desc,
            l_personal_funds,
            l_school_funds,
            l_school_funds_desc,
            l_other_funds,
            l_other_funds_desc,
            l_empl_funds,
            l_remarks;

      IF (c_nimg_data%FOUND) THEN

         p_data_rec.batch_id          := p_person_rec.batch_id;
         p_data_rec.person_id         := p_person_rec.person_id;
         p_data_rec.print_form        := p_person_rec.print_form;
         p_data_rec.creation_date     := sysdate;
         p_data_rec.created_by        := g_update_by;
         p_data_rec.last_updated_by   := g_update_by;
         p_data_rec.last_update_date  := sysdate;
         p_data_rec.last_update_login := g_update_login;
         p_data_rec.acad_term_length  := ltrim(to_char(to_number(l_acad_term_length),'00'));
         p_data_rec.tuition           := l_tuition;
         p_data_rec.living_exp        := l_living_exp;
         p_data_rec.dependent_exp     := l_dependent_exp;
         p_data_rec.other_exp         := l_other_exp;
         p_data_rec.other_exp_desc    := l_other_exp_desc;
         p_data_rec.personal_funds    := l_personal_funds;
         p_data_rec.school_funds      := l_school_funds;
         p_data_rec.school_funds_desc := l_school_funds_desc;
         p_data_rec.other_funds       := l_other_funds;
         p_data_rec.other_funds_desc  := l_other_funds_desc;
         p_data_rec.empl_funds        := l_empl_funds;
         p_data_rec.remarks           := l_remarks;

      END IF;

      CLOSE c_nimg_data;

   ELSE

--
-- Process the Exchange Visitor Data
--
      OPEN c_ev_data;
      FETCH c_ev_data
       INTO l_program_sponsor,
            l_govt_org1,
            l_govt_org2,
            l_govt_org1_code,
            l_govt_org2_code,
            l_intl_org1,
            l_intl_org2,
            l_intl_org1_code,
            l_intl_org2_code,
            l_ev_govt,
            l_bi_natnl_com,
            l_other_org,
            l_personal_funds,
            l_remarks,
            l_recvd_us_gvt_fund_amt,
	    l_govt_org1_othr_name,
	    l_govt_org2_othr_name,
	    l_intl_org1_othr_name,
	    l_intl_org2_othr_name,
	    l_other_govt_name;

      IF (c_ev_data%FOUND) THEN

         IF l_recvd_us_gvt_fund_amt <> '0' THEN
           l_recvd_us_gvt_fund_amt := '1';
         END IF;

         p_data_rec.batch_id          := p_person_rec.batch_id;
         p_data_rec.person_id         := p_person_rec.person_id;
         p_data_rec.print_form        := p_person_rec.print_form;
         p_data_rec.creation_date     := sysdate;
         p_data_rec.created_by        := g_update_by;
         p_data_rec.last_updated_by   := g_update_by;
         p_data_rec.last_update_login := g_update_login;
         p_data_rec.last_update_date  := sysdate;
         p_data_rec.program_sponsor   := l_program_sponsor;
         p_data_rec.govt_org1         := l_govt_org1;
         p_data_rec.govt_org2         := l_govt_org2;
         p_data_rec.govt_org1_code    := l_govt_org1_code;
         p_data_rec.govt_org2_code    := l_govt_org2_code;
         p_data_rec.intl_org1         := l_intl_org1;
         p_data_rec.intl_org2         := l_intl_org2;
         p_data_rec.intl_org1_code    := l_intl_org1_code;
         p_data_rec.intl_org2_code    := l_intl_org2_code;
         p_data_rec.ev_govt           := l_ev_govt;
         p_data_rec.bi_natnl_com      := l_bi_natnl_com;
         p_data_rec.other_org         := l_other_org;
         p_data_rec.personal_funds    := l_personal_funds;
         p_data_rec.remarks           := l_remarks;
         p_data_rec.recvd_us_gvt_funds:= l_recvd_us_gvt_fund_amt;
	 p_data_rec.govt_org1_othr_name	:= l_govt_org1_othr_name;
	 p_data_rec.govt_org2_othr_name	:= l_govt_org2_othr_name;
	 p_data_rec.intl_org1_othr_name	:= l_intl_org1_othr_name;
	 p_data_rec.intl_org2_othr_name	:= l_intl_org2_othr_name;
	 p_data_rec.other_govt_name	:= l_other_govt_name	;

      END IF;

      CLOSE c_ev_data;

   END IF;

   IF p_data_rec.batch_id IS NULL THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Finance_Info';
	  l_debug_str := 'Returning N from Validate_Finance_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'N';

   ELSE

     -- Validate all the data required for either type of request.
     IF (p_data_rec.print_form IS NULL AND p_person_rec.batch_type = 'E') THEN
        l_not_valid := TRUE;
        FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_FIN_REQ_FLD_ERR'); -- Required Fields for Exchange Visitor students
        FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
        Put_Log_Msg(FND_MESSAGE.Get,1);
     END IF;

--
-- Validate data specific for Foreign Students
--
     IF (p_person_rec.batch_type = 'I') THEN

        IF (p_data_rec.acad_term_length IS NULL     OR
            p_data_rec.tuition          IS NULL     OR
            p_data_rec.living_exp       IS NULL     OR
            p_data_rec.personal_funds   IS NULL) THEN
           l_not_valid := TRUE;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_FIN_REQ_NIMG_ERR'); -- Required Fields for Exchange Visitor students
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
           Put_Log_Msg(FND_MESSAGE.Get,1);
        END IF;

        IF ((p_data_rec.other_exp         IS NOT NULL   AND
             p_data_rec.other_exp_desc    IS NULL)      OR
            (p_data_rec.school_funds      IS NOT NULL   AND
             p_data_rec.school_funds_desc IS NULL)      OR
            (p_data_rec.other_funds       IS NOT NULL   AND
             p_data_rec.other_funds_desc  IS NULL)) THEN
           l_not_valid := TRUE;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_FIN_REQ_NIMG_DESC_ERR'); -- Required Fields for Exchange Visitor students
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
           Put_Log_Msg(FND_MESSAGE.Get,1);
        END IF;

     ELSE

--
-- Validate data specific for Exchange Visitor Students
--
        IF ((p_data_rec.govt_org1         IS NOT NULL   AND
             p_data_rec.govt_org1_code    IS NULL)      OR
            (p_data_rec.govt_org2         IS NOT NULL   AND
             p_data_rec.govt_org2_code    IS NULL)      OR
            (p_data_rec.intl_org1         IS NOT NULL   AND
             p_data_rec.intl_org1_code    IS NULL)      OR
            (p_data_rec.intl_org2         IS NOT NULL   AND
             p_data_rec.intl_org2_code    IS NULL))     THEN
           l_not_valid := TRUE;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_FIN_REQ_EV_ERR'); -- Required Fields for Exchange Visitor students
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
           Put_Log_Msg(FND_MESSAGE.Get,1);
        END IF;


	IF ((p_data_rec.govt_org1_code     = 'OTHER' AND
             p_data_rec.govt_org1_othr_name  IS NULL)      OR
            (p_data_rec.govt_org2_code     = 'OTHER' AND
             p_data_rec.govt_org2_othr_name  IS NULL)      OR
            (p_data_rec.intl_org1_code     = 'OTHER' AND
             p_data_rec.intl_org1_othr_name  IS NULL)      OR
            (p_data_rec.intl_org2_code     = 'OTHER' AND
             p_data_rec.intl_org2_othr_name IS NULL)      OR
	     p_data_rec.other_govt_name IS NULL AND
	     p_data_rec.other_org IS NOT NULL)     THEN
           l_not_valid := TRUE;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_OTHR_ORG');
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
           Put_Log_Msg(FND_MESSAGE.Get,1);
        END IF;

     END IF;

     IF (l_not_valid) THEN

        Put_Log_Msg(l_api_name||' Validation error, return E ',1);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Finance_Info';
	  l_debug_str := 'Returning E from Validate_Finance_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;


        RETURN 'E';

     END IF;

   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Finance_Info';
	  l_debug_str := 'Returning S from Validate_Finance_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;


   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Finance_Info';
	  l_debug_str := 'Exception in Validate_Finance_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;


      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_Finance_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate information pertaining to the
                        dependent information of the student.
                        (IGS_SV_DEPDNT_INFO)

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_Dependent_Info (
   p_person_rec IN      t_student_rec,
   p_data_rec   IN OUT NOCOPY  g_dependent_rec_type,    -- Data record
   p_records    OUT NOCOPY     NUMBER                   -- Number of dependents found
) RETURN VARCHAR2
IS


   l_api_name CONSTANT VARCHAR(30) := 'Validate_Dependent_Info';

   l_dep_person_rec   t_student_rec;
   l_dep_data_rec     IGS_SV_BIO_INFO%ROWTYPE ;
   l_counter          NUMBER(10) := 0;
   l_rel_count	      NUMBER(10) := 0;
   l_dep_sevis_id VARCHAR2(30);	--PRBHARDW
   -- Dependent codes
   -- 01 Spouse
   -- 02 Child

   -- Select all dependents
   CURSOR c_data IS
     SELECT dep.relationship_id,
            rel.object_id depdnt_id,
            action_code,
            to_char(effective_date,'YYYY-MM-DD') effective_date ,
            reason_code,
            dep.REMARKS comments,
            rel.COMMENTS rel_remarks,
            decode (RELATIONSHIP_CODE,'PARENT_OF','02','SPOUSE_OF','01','XX' ) relationship
       FROM igs_pe_depd_active dep,
            HZ_RELATIONSHIPS rel
      WHERE subject_id = p_person_rec.person_id
            AND rel.relationship_id =  dep.relationship_id
            AND (p_person_rec.record_status = 'C' OR dep.action_code ='A')  --In the new mode report only about active dependents
            AND RELATIONSHIP_CODE IN ('PARENT_OF','SPOUSE_OF' )
            AND (dep.relationship_id, dep.last_update_date) IN
            ( SELECT dep1.relationship_id,
                     MAX(dep1.last_update_date)
                FROM igs_pe_depd_active dep1
		WHERE dep1.relationship_id = rel.relationship_id
		GROUP BY  dep1.relationship_id)
            AND rel.status = 'A';

   CURSOR c_person_number(p_id NUMBER) IS
    SELECT person_number
      FROM igs_pe_person
     WHERE person_id = p_id;

   CURSOR c_spouse_of_rel IS
          SELECT COUNT(1)
	 FROM igs_pe_hz_rel_v hz
	 WHERE hz.subject_id = p_person_rec.person_id AND
	 hz.relationship_code= 'SPOUSE_OF' and
	 sysdate BETWEEN hz.start_date AND NVL(hz.end_date, sysdate+1)
         AND EXISTS (SELECT 1 FROM igs_pe_depd_active pdep
                     WHERE pdep.relationship_id = hz.relationship_id AND
                           pdep.action_code <> 'T' AND
                           pdep.last_update_date = (SELECT MAX(last_update_date)
				      FROM igs_pe_depd_active
				      WHERE relationship_id =hz.relationship_id)
                     );

CURSOR c_get_sevis_user_id(c_dep_id NUMBER)
     IS
          SELECT alt.api_person_id
	  FROM  igs_pe_alt_pers_id alt
	  WHERE
	       alt.pe_person_id = c_dep_id AND
	       alt.person_id_type IN (SELECT person_id_type FROM igs_pe_person_id_typ
				    WHERE s_person_id_type = 'SEVIS_ID') AND
               sysdate between alt.start_dt and nvl(alt.end_dt, sysdate+1);
     l_rel_type_count NUMBER := 0;
BEGIN

   Put_Log_Msg(l_api_name||' starts ',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Dependent_Info';
	  l_debug_str := 'Entering Validate_Dependent_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;



   FOR c_data_rec IN c_data LOOP
	  IF Get_Prev_Dep(p_person_rec.person_id, c_data_rec.depdnt_id, p_person_rec.batch_id, c_data_rec.action_code) THEN
	       l_counter := l_counter +1;
	       IF l_counter > 25 AND p_person_rec.batch_id = g_running_create_batch THEN
		  IF g_parallel_batches.count > 0 THEN
		       p_data_rec(l_counter).batch_id := g_parallel_batches(1);
		  ELSE
		      p_data_rec(l_counter).batch_id := igs_sv_util.open_new_batch(p_person_rec.person_id, p_person_rec.batch_id,'CONN_JOB');
		      g_parallel_batches(1) := p_data_rec(l_counter).batch_id;
		  END IF;
	       ELSE
		  p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
	       END IF;
	       OPEN c_get_sevis_user_id(c_data_rec.depdnt_id);
	       FETCH c_get_sevis_user_id  INTO l_dep_sevis_id;
	       CLOSE c_get_sevis_user_id;

	       p_data_rec(l_counter).person_id := p_person_rec.person_id;
	       p_data_rec(l_counter).print_form := p_person_rec.print_form;
	       p_data_rec(l_counter).creation_date := sysdate;
	       p_data_rec(l_counter).created_by := g_update_by;
	       p_data_rec(l_counter).last_updated_by := g_update_by;
	       p_data_rec(l_counter).last_update_date  := sysdate;
	       p_data_rec(l_counter).last_update_login := g_update_login;
	       p_data_rec(l_counter).depdnt_id          := c_data_rec.depdnt_id;
	       p_data_rec(l_counter).depdnt_action_type   := c_data_rec.action_code;
	       p_data_rec(l_counter).depdnt_sevis_id    := l_dep_sevis_id; --get_person_sevis_id(c_data_rec.depdnt_id);  prbhardw
	       p_data_rec(l_counter).termination_effect_date := c_data_rec.effective_date;

	       p_data_rec(l_counter).relationship        := c_data_rec.relationship;
	       p_data_rec(l_counter).relationship_remarks := c_data_rec.rel_remarks;
	       p_data_rec(l_counter).termination_reason :=  c_data_rec.reason_code ;

	       l_dep_person_rec.batch_id   := p_person_rec.batch_id;
	       l_dep_person_rec.person_id  := c_data_rec.depdnt_id;
	       l_dep_person_rec.print_form := p_person_rec.print_form;
	       l_dep_person_rec.batch_type := p_person_rec.batch_type;

	       OPEN c_person_number (c_data_rec.depdnt_id);
	       FETCH c_person_number INTO l_dep_person_rec.person_number ;
	       CLOSE c_person_number;

	       l_dep_person_rec.dep_flag   := 'Y';

	       -------prbhardw
	       IF p_data_rec(l_counter).relationship = '01'  AND p_person_rec.batch_type = 'I' THEN  -- spouse chk is for NI only: bug 5255450
		       OPEN c_spouse_of_rel;
		       FETCH c_spouse_of_rel INTO l_rel_type_count;
		       CLOSE c_spouse_of_rel;
		       IF l_rel_type_count > 1 THEN
			    FND_MESSAGE.SET_NAME('IGS','IGS_SV_SPOUSE_REL');
			    FND_MESSAGE.SET_TOKEN('PERSON_NUM',p_person_rec.person_number);
			    Put_Log_Msg(FND_MESSAGE.Get,1);
			    RETURN 'E';   -- fix for bug 5255450
		       END IF;

	       END IF;
	       -------prbhardw

	       -- Call Validate_Dep_Info
	       l_dep_person_rec.dep_status  := Validate_Bio_Info (p_person_rec => l_dep_person_rec,
								  p_data_rec   => l_dep_data_rec);
	       IF l_dep_person_rec.dep_status = 'E' THEN -- Validation error - mark person as invalid

		  Put_Log_Msg('Validation error occurs ',1);
			/* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Dependent_Info';
		  l_debug_str := 'Returning E from Validate_Dependent_Info.';
		  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

		  RETURN 'E';

	       ELSIF l_dep_person_rec.dep_status = 'N' THEN

		 Put_Log_Msg('Dependent not found by Validate procedure ',0);
			/* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Dependent_Info';
		  l_debug_str := 'IGS_SV_UNEXP_EXCPT_ERR Error in Validate_Dependent_Info.';
		  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

		 -- probably a bug
		 FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_UNEXP_EXCPT_ERR'); -- I-20 is missing! Unexpected error
		 FND_MESSAGE.SET_TOKEN('BLOCK_ID',1);
		 FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

	       END IF;

	       p_data_rec(l_counter).person_id   :=  p_person_rec.person_id;

	       p_data_rec(l_counter).visa_type   := l_dep_data_rec.visa_type ;
	       p_data_rec(l_counter).last_name   := l_dep_data_rec.last_name;
	       p_data_rec(l_counter).first_name  := l_dep_data_rec.first_name;
	       p_data_rec(l_counter).middle_name := l_dep_data_rec.middle_name;
	       p_data_rec(l_counter).suffix      := l_dep_data_rec.suffix;
	       p_data_rec(l_counter).birth_date  := l_dep_data_rec.birth_date ;
	       p_data_rec(l_counter).person_number  := l_dep_person_rec.person_number ;
	       p_data_rec(l_counter).gender      := l_dep_data_rec.gender ;
	       p_data_rec(l_counter).birth_cntry_code := l_dep_data_rec.birth_cntry_code ;
	       p_data_rec(l_counter).citizen_cntry_code := l_dep_data_rec.citizen_cntry_code ;

	       p_data_rec(l_counter).birth_city        := l_dep_data_rec.birth_city ;
	       p_data_rec(l_counter).legal_res_cntry_code := l_dep_data_rec.legal_res_cntry_code ;
	       p_data_rec(l_counter).remarks           := l_dep_data_rec.remarks ;
	       p_data_rec(l_counter).birth_cntry_resn_code := l_dep_data_rec.birth_cntry_resn_code;

	       IF p_person_rec.record_status = 'C' THEN

		/* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Dependent_Info';
		  l_debug_str := 'Exiting from for loop in Validate_Dependent_Info.';
		  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

	       --  EXIT; -- Just one dependent in the update mode per batch	prbhardw CP enhancement

	       END IF;
          END IF;

   END LOOP;

   IF l_counter = 0 THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Dependent_Info';
	  l_debug_str := 'Returning N from Validate_Dependent_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'N';

   END IF;

   p_records := l_counter;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Dependent_Info';
	  l_debug_str := 'Returning S from Validate_Dependent_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Dependent_Info';
	  l_debug_str := 'Exception in Validate_Dependent_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';


END Validate_Dependent_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate information pertaining to the
                        convictions associated to student.
                        (IGS_SV_CONVICTIONS)

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_Convictions_Info (
   p_person_rec IN      t_student_rec,
   p_data_rec   IN OUT NOCOPY  IGS_SV_CONVICTIONS%ROWTYPE    -- Data record
) RETURN VARCHAR2
IS

   l_api_name CONSTANT VARCHAR(30) := 'Validate_Convictions_Info';

   -- Select only! unreported records since no data change is possbile.

   CURSOR c_data IS
     SELECT felony_details_id conviction_id,
            disp_action_info criminal_remarks
       FROM igs_pe_felony_dtls
      WHERE person_id = p_person_rec.person_id
            AND convict_ind ='Y'
            AND felony_details_id NOT IN
            ( SELECT conviction_id
                FROM igs_sv_convictions  prg,
                     igs_sv_persons pr
               WHERE prg.person_id = pr.person_id
                     AND prg.batch_id = pr.batch_id
                     AND pr.record_status <> 'E'
                     AND prg.person_id = p_person_rec.person_id )
    ORDER BY crime_date;

  l_not_valid BOOLEAN := FALSE;
BEGIN
/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Convictions_Info';
	  l_debug_str := 'Entering Validate_Convictions_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' starts ',0);

   p_data_rec.batch_id := NULL;  -- This will tell us if there's been any records found

   FOR c_data_rec IN c_data LOOP

       p_data_rec.batch_id := p_person_rec.batch_id;
       p_data_rec.person_id := p_person_rec.person_id;
       p_data_rec.print_form := p_person_rec.print_form;
       p_data_rec.creation_date := sysdate;
       p_data_rec.created_by := g_update_by;
       p_data_rec.last_updated_by := g_update_by;
       p_data_rec.last_update_date  := sysdate;
       p_data_rec.last_update_login := g_update_login;

       p_data_rec.conviction_id := c_data_rec.conviction_id;
       p_data_rec.remarks       :=SUBSTR(c_data_rec.criminal_remarks,1,500);
       p_data_rec.criminal_conviction :='Y' ;

       IF p_data_rec.remarks IS NULL  THEN
          l_not_valid := TRUE;
       END IF;
       EXIT;  -- one  record is enough

   END LOOP;

   IF p_data_rec.batch_id IS NULL THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Convictions_Info';
	  l_debug_str := 'Returning N from Validate_Convictions_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'N';

   ELSIF l_not_valid THEN

       FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_CONV_RQD_FLD_ERR'); -- Convictions block error
       FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

       Put_Log_Msg(FND_MESSAGE.Get,1);

       Put_Log_Msg(l_api_name||' Validation error, return E ',0);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Convictions_Info';
	  l_debug_str := 'Returning E from Validate_Convictions_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

       RETURN 'E';

   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Convictions_Info';
	  l_debug_str := 'Returning S from Validate_Convictions_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Convictions_Info';
	  l_debug_str := 'Exception in Validate_Convictions_Info '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_Convictions_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Validate information pertaining to the
                        Legal information block of student.
                        (IGS_SV_LEGAL_INFO)

   Remarks            : Return result:
                           'S' - record found and validated
                           'E' - validation error
                           'U' - Unexpected error
                           'N' - data not found

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Validate_Legal_Info (
   p_person_rec IN      t_student_rec,
   p_data_rec   IN OUT NOCOPY  IGS_SV_LEGAL_INFO%ROWTYPE    -- Data record
) RETURN VARCHAR2
IS

   l_api_name                 CONSTANT VARCHAR(30) := 'Validate_Legal_Info';
   l_visa_number              IGS_PE_VISA.visa_number%TYPE;
   l_visa_issuing_post        IGS_PE_VISA.visa_issuing_post%TYPE;
   l_visa_expiration_date     IGS_PE_VISA.visa_expiry_date%TYPE;
   l_visa_issuing_country     IGS_PE_VISA.visa_issuing_country%TYPE;
   l_I94_number               IGS_PE_VISIT_HISTRY.cntry_entry_form_num%TYPE;
   l_visa_issue_date	      IGS_PE_VISA.visa_issue_date%TYPE;
   l_port_of_entry            IGS_PE_VISIT_HISTRY.port_of_entry%TYPE;
   l_date_of_entry            IGS_PE_VISIT_HISTRY.visit_start_date%TYPE;
   l_remarks                  IGS_PE_VISIT_HISTRY.remarks%TYPE;
   l_psprt_number             IGS_PE_PASSPORT.passport_number%TYPE;
   l_psprt_issuing_cntry_code IGS_PE_PASSPORT.passport_cntry_code%TYPE;
   l_psprt_exp_date           IGS_PE_PASSPORT.passport_expiry_date%TYPE;
   l_not_valid                BOOLEAN := FALSE;

   CURSOR c_get_visa_data IS
     SELECT peva.visa_number,
            peva.visa_issuing_post,
            peva.visa_expiry_date,
            pevv.cntry_entry_form_num,
            pevv.port_of_entry,
            pevv.visit_start_date,
            pevv.remarks,
            pspt.passport_number,
            pspt.passport_cntry_code,
            pspt.passport_expiry_date,
            peva.visa_issuing_country,
	    peva.visa_issue_date
       FROM igs_pe_visa           peva,
            igs_pe_visit_histry   pevv,
            igs_pe_passport       pspt
      WHERE peva.person_id         = p_person_rec.person_id
        AND peva.visa_type         IN ('F-1', 'F-2','M-1','M-2')
        AND peva.visa_id           = pevv.visa_id (+)
        AND pspt.passport_id (+)   = peva.passport_id
        AND peva.visa_expiry_date  >= trunc(sysdate);

BEGIN
/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Legal_Info';
	  l_debug_str := 'Entering Validate_Legal_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' starts ',0);
   p_data_rec.batch_id := NULL;           -- This will tell us if there's been any records found

--
-- Obtain all information on the visa that has been made available
--
   OPEN c_get_visa_data;
   FETCH c_get_visa_data
    INTO l_visa_number,
         l_visa_issuing_post,
         l_visa_expiration_date,
         l_I94_number,
         l_port_of_entry,
         l_date_of_entry,
         l_remarks,
         l_psprt_number,
         l_psprt_issuing_cntry_code,
         l_psprt_exp_date,
         l_visa_issuing_country,
	 l_visa_issue_date;

--
-- Make sure that there was visa information found for the person
--
   IF (c_get_visa_data%FOUND) THEN

      p_data_rec.psprt_number               := SUBSTR(l_psprt_number,1,25);
      p_data_rec.psprt_issuing_cntry_code   := SUBSTR(l_psprt_issuing_cntry_code,1,3);
      p_data_rec.psprt_exp_date             := to_char(l_psprt_exp_date,'YYYY-MM-DD');
      p_data_rec.visa_number                := SUBSTR(l_visa_number,1,25);
      p_data_rec.visa_issuing_post          := SUBSTR(l_visa_issuing_post,3);
      p_data_rec.visa_expiration_date       := to_char(l_visa_expiration_date,'YYYY-MM-DD');
      p_data_rec.i94_number                 := SUBSTR(l_I94_number,1,11);
      p_data_rec.port_of_entry              := SUBSTR(l_port_of_entry,3);
      p_data_rec.visa_issuing_cntry_code    := l_visa_issuing_country;
      p_data_rec.date_of_entry              := to_char(l_date_of_entry,'YYYY-MM-DD');
      p_data_rec.visa_issue_date	    := l_visa_issue_date;
      p_data_rec.remarks                    := l_remarks;
      p_data_rec.batch_id                   := p_person_rec.batch_id;
      p_data_rec.person_id                  := p_person_rec.person_id;
      p_data_rec.print_form                 := p_person_rec.print_form;
      p_data_rec.creation_date              := sysdate;
      p_data_rec.created_by                 := g_update_by;
      p_data_rec.last_updated_by            := g_update_by;
      p_data_rec.last_update_date           := sysdate;
      p_data_rec.last_update_login          := g_update_login;

      -- change for country code inconsistency bug 3738488
     --p_data_rec.psprt_issuing_cntry_code := convert_country_code(p_data_rec.psprt_issuing_cntry_code);
     p_data_rec.visa_issuing_cntry_code := convert_country_code(p_data_rec.visa_issuing_cntry_code);

   END IF;

   CLOSE c_get_visa_data;

   IF (p_data_rec.batch_id IS NULL) THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Legal_Info';
	  l_debug_str := 'Returning N from Validate_Legal_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Legal_Info';
	  l_debug_str := 'Returning S from Validate_Legal_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Legal_Info';
	  l_debug_str := 'Exception in Validate_Legal_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_Legal_Info;

FUNCTION Validate_ev_Legal_Info (
   p_person_rec IN      t_student_rec,
   p_data_rec   IN OUT NOCOPY  IGS_SV_LEGAL_INFO%ROWTYPE    -- Data record
) RETURN VARCHAR2
IS

   l_api_name                 CONSTANT VARCHAR(30) := 'Validate_ev_Legal_Info';
   l_visa_number              IGS_PE_VISA.visa_number%TYPE;
   l_visa_issuing_post        IGS_PE_VISA.visa_issuing_post%TYPE;
   l_visa_expiration_date     IGS_PE_VISA.visa_expiry_date%TYPE;
   l_visa_issue_date          IGS_PE_VISA.visa_issue_date%TYPE;
   l_visa_issuing_country     IGS_PE_VISA.visa_issuing_country%TYPE;
   l_I94_number               IGS_PE_VISIT_HISTRY.cntry_entry_form_num%TYPE;
   l_port_of_entry            IGS_PE_VISIT_HISTRY.port_of_entry%TYPE;
   l_date_of_entry            IGS_PE_VISIT_HISTRY.visit_start_date%TYPE;
   l_remarks                  IGS_PE_VISIT_HISTRY.remarks%TYPE;
   l_psprt_number             IGS_PE_PASSPORT.passport_number%TYPE;
   l_psprt_issuing_cntry_code IGS_PE_PASSPORT.passport_cntry_code%TYPE;
   l_psprt_exp_date           IGS_PE_PASSPORT.passport_expiry_date%TYPE;
   l_not_valid                BOOLEAN := FALSE;

--to_char(peva.visa_issue_date,'YYYY-MM-DD') visa_issue_date

   CURSOR c_get_visa_data IS
     SELECT peva.visa_number,
            peva.visa_issuing_post,
            peva.visa_expiry_date,
            pevv.cntry_entry_form_num,
            pevv.port_of_entry,
            pevv.visit_start_date,
            pevv.remarks,
            pspt.passport_number,
            pspt.passport_cntry_code,
            pspt.passport_expiry_date,
            peva.visa_issuing_country,
	    peva.visa_issue_date
       FROM igs_pe_visa           peva,
            igs_pe_visit_histry   pevv,
            igs_pe_passport       pspt
      WHERE peva.person_id         = p_person_rec.person_id
        AND peva.visa_type         IN ('J-1', 'J-2')
        AND peva.visa_id           = pevv.visa_id (+)
        AND pspt.passport_id (+)   = peva.passport_id
        AND peva.visa_expiry_date  >= trunc(sysdate);

BEGIN
/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_ev_Legal_Info';
	  l_debug_str := 'Entering Validate_ev_Legal_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' starts ',0);
   p_data_rec.batch_id := NULL;           -- This will tell us if there's been any records found

--
-- Obtain all information on the visa that has been made available
--
   OPEN c_get_visa_data;
   FETCH c_get_visa_data
    INTO l_visa_number,
         l_visa_issuing_post,
         l_visa_expiration_date,
         l_I94_number,
         l_port_of_entry,
         l_date_of_entry,
         l_remarks,
         l_psprt_number,
         l_psprt_issuing_cntry_code,
         l_psprt_exp_date,
         l_visa_issuing_country,
	 l_visa_issue_date;

--
-- Make sure that there was visa information found for the person
--
   IF (c_get_visa_data%FOUND) THEN

      p_data_rec.psprt_number               := SUBSTR(l_psprt_number,1,25);
      p_data_rec.psprt_issuing_cntry_code   := SUBSTR(l_psprt_issuing_cntry_code,1,3);
      p_data_rec.psprt_exp_date             := to_char(l_psprt_exp_date,'YYYY-MM-DD');
      p_data_rec.visa_number                := SUBSTR(l_visa_number,1,25);
      p_data_rec.visa_issuing_post          := SUBSTR(l_visa_issuing_post,3);
      p_data_rec.visa_expiration_date       := to_char(l_visa_expiration_date,'YYYY-MM-DD');
      p_data_rec.i94_number                 := SUBSTR(l_I94_number,1,11);
      p_data_rec.port_of_entry              := SUBSTR(l_port_of_entry,3);
      p_data_rec.visa_issuing_cntry_code    := l_visa_issuing_country;
      p_data_rec.date_of_entry              := to_char(l_date_of_entry,'YYYY-MM-DD');
      p_data_rec.visa_issue_date            := l_visa_issue_date;
      p_data_rec.remarks                    := l_remarks;
      p_data_rec.batch_id                   := p_person_rec.batch_id;
      p_data_rec.person_id                  := p_person_rec.person_id;
      p_data_rec.print_form                 := p_person_rec.print_form;
      p_data_rec.creation_date              := sysdate;
      p_data_rec.created_by                 := g_update_by;
      p_data_rec.last_updated_by            := g_update_by;
      p_data_rec.last_update_date           := sysdate;
      p_data_rec.last_update_login          := g_update_login;

   END IF;

   CLOSE c_get_visa_data;

   IF (p_data_rec.batch_id IS NULL) THEN

      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_ev_Legal_Info';
	  l_debug_str := 'Returning N from Validate_ev_Legal_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_ev_Legal_Info';
	  l_debug_str := 'Returning S from Validate_ev_Legal_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S'; -- Successfull validation

EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_ev_Legal_Info';
	  l_debug_str := 'Exception in Validate_ev_Legal_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN 'U';

END Validate_ev_Legal_Info;

FUNCTION Get_Empl_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_EMPL_INFO%ROWTYPE     -- Data record
)   RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT VARCHAR2(25) := 'Get_Empl_Info';

   CURSOR c_data_rec IS
     SELECT nonimg_empl_id,
            empl_rec_type,
            empl_type,
            recommend_empl,
            rescind_empl,
            remarks,
            empl_start_date ,
            empl_end_date,
            course_relevance,
            empl_time,
            empl_name,
	    action_code
      FROM igs_sv_empl_info
      WHERE
            person_id = p_data_rec.person_id and
            nonimg_empl_id = p_data_rec.nonimg_empl_id and
	    batch_id IN
            (  SELECT max(emp.batch_id)
                 FROM igs_sv_empl_info emp,
                      igs_sv_persons pr
                WHERE emp.person_id = pr.person_id
                      AND emp.batch_id = pr.batch_id
                      AND pr.record_status <> 'E'
                      AND emp.person_id = p_data_rec.person_id
		      AND emp.nonimg_empl_id = p_data_rec.nonimg_empl_id
            )
    ORDER BY nonimg_empl_id;

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Empl_Info';
	  l_debug_str := 'Entering Get_Empl_Info. p_data_rec.person_id is '||p_data_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' begins ',0);

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.nonimg_empl_id  ,
         p_data_rec.empl_rec_type   ,
         p_data_rec.empl_type       ,
         p_data_rec.recommend_empl  ,
         p_data_rec.rescind_empl    ,
         p_data_rec.remarks         ,
         p_data_rec.empl_start_date ,
         p_data_rec.empl_end_date   ,
         p_data_rec.course_relevance,
         p_data_rec.empl_time     ,
         p_data_rec.empl_name     ,
         p_data_rec.action_code   ;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Empl_Info';
	  l_debug_str := 'Returning N from Get_Empl_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Empl_Info';
	  l_debug_str := 'Returning S from Get_Empl_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Empl_Info';
	  l_debug_str := 'Exception in Get_Empl_Info '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
      RETURN 'U';

   WHEN OTHERS THEN
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Empl_Info';
	  l_debug_str := 'Exception in Get_Empl_Info '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      RETURN  'U';

END Get_Empl_Info;

FUNCTION Check_emp_duration(stDate IN VARCHAR2 , endDt IN VARCHAR2 , p_visa_type IN VARCHAR2) RETURN BOOLEAN IS
        returnVal boolean := false;
	startDate Date;
	endDate Date;
	daysBetween number := 0;

    BEGIN
	startDate := TO_DATE(stDate,'YYYY-MM-DD');
	endDate := TO_DATE(endDt,'YYYY-MM-DD');
	daysBetween := endDate-startDate;

	IF p_visa_type= 'F-1' AND  daysBetween > 365 THEN
	    	returnVal := true;
	ELSIF p_visa_type= 'M-1' AND daysBetween > 183 THEN
                  returnVal := true;
        END IF;
	RETURN returnVal;
END Check_emp_duration;

-- only for validation of the input record
FUNCTION validate_employment_Info(
  p_person_rec    IN      t_student_rec,
  p_data_rec      IN OUT NOCOPY  IGS_SV_EMPL_INFO%ROWTYPE     --Data record
) RETURN BOOLEAN
IS
   l_not_valid    BOOLEAN := FALSE;
   l_visa_type VARCHAR2(5);
   l_api_name CONSTANT VARCHAR2(25) := 'validate_employment_Info';
   l_months NUMBER(2);
   CURSOR c_get_visa_type
   IS
     SELECT visa_type
     FROM igs_pe_nonimg_form
     WHERE person_id =  p_person_rec.person_id
           AND nonimg_form_id =  p_person_rec.form_id;

 BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.validate_employment_Info';
	  l_debug_str := 'Entering validate_employment_Info. p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

	OPEN c_get_visa_type;
	FETCH c_get_visa_type INTO l_visa_type;
	CLOSE c_get_visa_type;

	IF l_visa_type ='F-1' THEN
	    l_months := 12;
	ELSE
	    l_months := 6;
	END IF;


      -- Validate all the data
   IF p_data_rec.empl_rec_type = 'F'
      AND ( ( p_data_rec.recommend_empl   IS NULL
                 AND p_data_rec.rescind_empl IS NULL
               )
            OR p_data_rec.remarks IS NULL) THEN

         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EMPL_F_RQD_FLD_ERR'); -- Employment block error
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

         Put_Log_Msg(FND_MESSAGE.Get,1);
         l_not_valid := TRUE;

   ELSIF p_data_rec.empl_rec_type = 'O'
      AND ( p_data_rec.empl_time           IS NULL
            OR p_data_rec.empl_start_date  IS NULL
            OR p_data_rec.empl_end_date    IS NULL
            OR p_data_rec.course_relevance IS NULL) THEN

         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EMPL_O_RQD_FLD_ERR'); -- Employment block error
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

         Put_Log_Msg(FND_MESSAGE.Get,1);
         l_not_valid := TRUE;

   ELSIF p_data_rec.empl_rec_type = 'C'
      AND ( p_data_rec.empl_time           IS NULL
            OR p_data_rec.empl_start_date  IS NULL
            OR p_data_rec.empl_end_date    IS NULL
            OR p_data_rec.course_relevance IS NULL
            OR p_data_rec.empl_name        IS NULL
            OR p_data_rec.empl_addr_line1  IS NULL
            OR p_data_rec.city             IS NULL
            OR p_data_rec.state            IS NULL
            OR p_data_rec.postal_code      IS NULL
            ) THEN

         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_EMPL_C_RQD_FLD_ERR'); -- Employment block error
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number );

         Put_Log_Msg(FND_MESSAGE.Get,1);
         l_not_valid := TRUE;
     ELSIF p_data_rec.empl_rec_type = 'O' THEN
          IF Check_emp_duration(p_data_rec.empl_start_date, p_data_rec.empl_end_date, l_visa_type) THEN
	       FND_MESSAGE.SET_NAME('IGS','IGS_SV_EMP_INV_PRD');
	       FND_MESSAGE.SET_TOKEN('MONTHS',l_months);
	       FND_MESSAGE.SET_TOKEN('VISA_TYPE',l_visa_type);
	       Put_Log_Msg(FND_MESSAGE.Get,1);
               l_not_valid := TRUE;
          END IF;
   END IF;

   IF l_not_valid THEN

     Put_Log_Msg(l_api_name||' Validation error, return E ',1);

  --   RETURN 'E';
  ELSE
     Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);

   --  RETURN 'S'; -- Successfull validation

   END IF;
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.validate_employment_Info';
	  l_debug_str := 'Returning from validate_employment_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN l_not_valid;


END validate_employment_Info;


--Overload validate_empl_info method to accept table type argument

FUNCTION Validate_Empl_Info (
   p_person_rec    IN      t_student_rec,
   p_data_rec   IN OUT NOCOPY  g_empl_rec_type,    -- Data record
   p_records    OUT NOCOPY     NUMBER                   -- Number of dependents found
) RETURN VARCHAR2
IS

 -- Select the oldest employment record haven't been reported to INS yet.


   -- Select only! unreported records since no data change is possbile.

   CURSOR c_data(cp_person_id hz_parties.party_id%TYPE) IS
     SELECT nonimg_empl_id,
            frm.nonimg_form_id,
            decode ( empl_type,'01','O','02','C','F')  empl_rec_type,
            empl_type,
            recommend_empl,
            rescind_empl,
            em.remarks,
            to_char(empl_start_date, 'YYYY-MM-DD') empl_start_date,
            to_char(empl_end_date, 'YYYY-MM-DD') empl_end_date,
            course_relevance,
            empl_time,
            empl_party_id,
	    action_code,
	    NVL(em.print_flag, 'N') print_flag
       FROM igs_pe_nonimg_empl em,
            igs_pe_nonimg_form frm
      WHERE frm.person_id = cp_person_id
            AND frm.nonimg_form_id = em.nonimg_form_id
    ORDER BY nonimg_empl_id;


    CURSOR c_empl_name (l_party_id NUMBER) IS
     SELECT party_name
       FROM hz_parties
      WHERE party_id = l_party_id;

    CURSOR c_empl_addr (l_party_id NUMBER) IS
     SELECT SUBSTR(address1||address2||address3||address4,1,60) addr_line1,
            SUBSTR(address1||address2||address3||address4,1,60) addr_line2,
            SUBSTR(city,1,60) city    ,
            SUBSTR(state,1,2) state   ,
            postal_code
       FROM hz_locations lc, hz_party_sites st
      WHERE party_id = l_party_id
            AND lc.location_id = st.location_id
            AND identifying_address_flag  ='Y';

  l_postal_code  hz_locations.postal_code%TYPE;
  l_not_valid    BOOLEAN := FALSE;
  l_api_name CONSTANT VARCHAR(30) := 'Validate_Empl_Info';
  l_counter NUMBER(10):= 0;

BEGIN

	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Empl_Info';
	  l_debug_str := 'Entering validate_empl_Info p_person_rec.batch_id is '||p_person_rec.batch_id ||' and person_id is '||p_person_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' starts ',0);

   FOR c_data_rec IN c_data(p_person_rec.person_id) LOOP

       l_counter := l_counter +1;

       p_data_rec(l_counter).batch_id := p_person_rec.batch_id;
       p_data_rec(l_counter).person_id := p_person_rec.person_id;
       p_data_rec(l_counter).print_form := c_data_rec.print_flag; -- p_person_rec.print_form; PRBHARDW
       p_data_rec(l_counter).creation_date := sysdate;
       p_data_rec(l_counter).created_by := g_update_by;
       p_data_rec(l_counter).last_updated_by := g_update_by;
       p_data_rec(l_counter).last_update_date  := sysdate;
       p_data_rec(l_counter).last_update_login := g_update_login;

       p_data_rec(l_counter).empl_rec_type := c_data_rec.empl_rec_type; -- C(PT) O(PT) F(Off campus)
       p_data_rec(l_counter).empl_type  := c_data_rec.empl_type;
       p_data_rec(l_counter).nonimg_empl_id:= c_data_rec.nonimg_empl_id;
       p_data_rec(l_counter).recommend_empl  := c_data_rec.recommend_empl ;
       p_data_rec(l_counter).rescind_empl  := c_data_rec.rescind_empl;
       p_data_rec(l_counter).remarks   := c_data_rec.remarks;
       p_data_rec(l_counter).empl_start_date  := c_data_rec.empl_start_date;
       p_data_rec(l_counter).empl_end_date  := c_data_rec.empl_end_date;
       p_data_rec(l_counter).empl_time  := c_data_rec.empl_time;
       p_data_rec(l_counter).course_relevance  := c_data_rec.course_relevance;
       p_data_rec(l_counter).action_code := c_data_rec.action_code;

       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Empl_Info';
	  l_debug_str := 'Remarks: '||p_data_rec(l_counter).remarks||' Empl Type: '||p_data_rec(l_counter).empl_rec_type;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

       IF p_data_rec(l_counter).empl_rec_type  <> 'F' THEN
         -- Get party id and address info
         OPEN c_empl_name (c_data_rec.empl_party_id);
         FETCH c_empl_name INTO p_data_rec(l_counter).empl_name;
         CLOSE c_empl_name;

         OPEN c_empl_addr (c_data_rec.empl_party_id);
         FETCH c_empl_addr
           INTO p_data_rec(l_counter).empl_addr_line1,
                p_data_rec(l_counter).empl_addr_line2,
                p_data_rec(l_counter).city,
                p_data_rec(l_counter).state,
                l_postal_code;

         p_data_rec(l_counter).postal_code := substr(l_postal_code,1,5);
         p_data_rec(l_counter).postal_routing_code := substr(l_postal_code,7,4);
         CLOSE c_empl_addr;
       END IF;

         l_not_valid := validate_employment_Info(p_person_rec => p_person_rec,
                                                 p_data_rec  => p_data_rec(l_counter));

        IF l_not_valid THEN
           Put_Log_Msg(l_api_name||' Validation error, return E ',1);
	   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Empl_Info';
	  l_debug_str := 'Returning E from validate_empl_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
	   RETURN 'E';
	END IF;
   END LOOP;

    p_records := l_counter;
   IF l_counter = 0 THEN
      Put_Log_Msg(l_api_name||' Successfully completed, no rows found returns N ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Empl_Info';
	  l_debug_str := 'Returning N from validate_empl_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';
   END IF;

     -- Validate all the data

   Put_Log_Msg(l_api_name||' Successfully completed, returns S',0);
/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Empl_Info';
	  l_debug_str := 'Returning S from validate_empl_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S'; -- Successfull validation
EXCEPTION

   WHEN OTHERS THEN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Validate_Empl_Info';
	  l_debug_str := 'Exception in validate_empl_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      RETURN 'U';

END Validate_Empl_Info;
/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Get the person information on the student.
                        (IGS_SV_PERSONS).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Issue_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_PERSONS%ROWTYPE   -- Data record
) RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT  VARCHAR2(25) := 'Get_Issue_Info';

   CURSOR c_data_rec IS
     SELECT cr.batch_id               ,
            cr.person_id              ,
            cr.record_number          ,
            cr.form_id                ,
            decode(cr.print_form,'Y','1','0') print_form,
            cr.record_status          ,
            cr.person_number          ,
            cr.sevis_user_id          ,
            cr.issuing_reason         ,
            cr.curr_session_end_date  ,
            cr.next_session_start_date,
            cr.other_reason           ,
            cr.transfer_from_school   ,
            cr.ev_create_reason       ,
            cr.ev_form_number	      ,
	    cr.no_show_flag	      ,
	    cr.last_session_flag
       FROM igs_sv_persons cr
      WHERE cr.person_id = p_data_rec.person_id
        AND cr.batch_id IN
            (  SELECT max(mx.batch_id)
                 FROM igs_sv_persons mx
                WHERE mx.person_id = p_data_rec.person_id
                      AND mx.record_status <> 'E'
            );

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Issue_Info';
	  l_debug_str := 'Entering Get_Issue_Info. p_data_rec.person_id is '||p_data_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' begins ',0);

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.batch_id               ,
         p_data_rec.person_id              ,
         p_data_rec.record_number          ,
         p_data_rec.form_id                ,
         p_data_rec.print_form             ,
         p_data_rec.record_status          ,
         p_data_rec.person_number          ,
         p_data_rec.sevis_user_id          ,
         p_data_rec.issuing_reason         ,
         p_data_rec.curr_session_end_date  ,
         p_data_rec.next_session_start_date,
         p_data_rec.other_reason           ,
         p_data_rec.transfer_from_school   ,
         p_data_rec.ev_create_reason       ,
         p_data_rec.ev_form_number	   ,
	 p_data_rec.no_show_flag	   ,
	 p_data_rec.last_session_flag;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Issue_Info';
	  l_debug_str := 'Returning N from Get_Issue_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Issue_Info';
	  l_debug_str := 'Returning S from Get_Issue_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Issue_Info';
	  l_debug_str := 'FND_API.G_EXC_ERROR in Get_Issue_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Issue_Info';
	  l_debug_str := 'Exception in Get_Issue_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN  'U';

END Get_Issue_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Get BIO Information for the student.
                        (IGS_SV_BIO_INFO).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION  Get_Bio_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_BIO_INFO%ROWTYPE   -- Data record
) RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT VARCHAR2(25) := 'Get_Bio_Info';

   CURSOR c_data_rec IS
     SELECT birth_date             ,
            birth_cntry_code       ,
            citizen_cntry_code     ,
            last_name              ,
            middle_name            ,
            first_name             ,
            suffix                 ,
            gender                 ,
            legal_res_cntry_code   ,
            position_code          ,
            commuter               ,
            remarks		   ,
	    birth_cntry_resn_code  ,
	    birth_city
       FROM igs_sv_bio_info  cr
      WHERE cr.person_id = p_data_rec.person_id
        AND cr.batch_id IN
            (  SELECT max(prs.batch_id)
                 FROM igs_sv_bio_info prs,
                      igs_sv_persons pr
                WHERE prs.person_id = pr.person_id
                      AND prs.batch_id = pr.batch_id
                      AND pr.record_status <> 'E'
                      AND prs.person_id = p_data_rec.person_id
            );

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Bio_Info';
	  l_debug_str := 'Entering Get_Bio_Info. p_data_rec.person_id is '||p_data_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' begins ',0);

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.birth_date             ,
         p_data_rec.birth_cntry_code       ,
         p_data_rec.citizen_cntry_code     ,
         p_data_rec.last_name              ,
         p_data_rec.middle_name            ,
         p_data_rec.first_name             ,
         p_data_rec.suffix                 ,
         p_data_rec.gender                 ,
         p_data_rec.legal_res_cntry_code   ,
         p_data_rec.position_code          ,
         p_data_rec.commuter               ,
         p_data_rec.remarks		   ,
	 p_data_rec.birth_cntry_resn_code  ,
	 p_data_rec.birth_city;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Bio_Info';
	  l_debug_str := 'Returning N from Get_Bio_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
    /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Bio_Info';
	  l_debug_str := 'Returning S from Get_Bio_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
    /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Bio_Info';
	  l_debug_str := 'FND_API.G_EXC_ERROR in Get_Bio_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);

      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Bio_Info';
	  l_debug_str := 'Exception in Get_Bio_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RETURN  'U';

END Get_Bio_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Get other information on the student
                        (IGS_SV_OTH_INFO)

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Other_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_OTH_INFO%ROWTYPE   -- Data record
) RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT VARCHAR2(25) := 'Get_Other_Info';

   CURSOR c_data_rec IS
     SELECT drivers_license        ,
            drivers_license_state  ,
            ssn                    ,
            tax_id
       FROM igs_sv_oth_info cr
      WHERE cr.person_id = p_data_rec.person_id
        AND cr.batch_id IN
            (  SELECT max(prs.batch_id)
                 FROM igs_sv_oth_info prs,
                     igs_sv_persons pr
               WHERE prs.person_id = pr.person_id
                     AND prs.batch_id = pr.batch_id
                     AND pr.record_status <> 'E'
                     AND prs.person_id = p_data_rec.person_id
            );

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Other_Info';
   l_debug_str := 'Entering Get_Other_Info. p_data_rec.person_id is '||p_data_rec.person_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   Put_Log_Msg(l_api_name||' begins ',0);

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.drivers_license        ,
         p_data_rec.drivers_license_state  ,
         p_data_rec.ssn                    ,
         p_data_rec.tax_id                 ;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Other_Info';
	   l_debug_str := 'Returning N from Get_Other_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Other_Info';
	   l_debug_str := 'Returning S from Get_Other_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Other_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR in Get_Other_Info-- Returning U. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Other_Info';
	   l_debug_str := 'Exception in Get_Other_Info-- Returning U. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

      RETURN  'U';

END Get_Other_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Get Site of activity information on the student
                        (IGS_SV_ADDRESSES).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Address_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_ADDRESSES%ROWTYPE   -- Data record
)  RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT VARCHAR2(25) := 'Get_Address_Info';

   CURSOR c_data_rec IS
     SELECT action_type            ,
            address_type           ,
            address_line1          ,
            address_line2          ,
            city                   ,
            state                  ,
            postal_code            ,
            postal_routing_code    ,
            country_code           ,
            province               ,
            stdnt_valid_flag	   ,
	    primary_flag           ,
	    activity_site_cd   ,
		remarks
       FROM igs_sv_addresses cr
      WHERE cr.person_id = p_data_rec.person_id
        AND cr.party_site_id = p_data_rec.party_site_id
        AND cr.batch_id IN
            (  SELECT max(prs.batch_id)
                 FROM igs_sv_addresses prs,
                      igs_sv_persons pr
                WHERE prs.person_id = pr.person_id
                     AND prs.batch_id = pr.batch_id
                     AND pr.record_status <> 'E'
                     AND prs.person_id = p_data_rec.person_id
                     AND prs.party_site_id = p_data_rec.party_site_id
            );
BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
   /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Address_Info';
   l_debug_str := 'Entering Get_Address_Info. p_data_rec.party_site_id is '||p_data_rec.party_site_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.action_type            ,
         p_data_rec.address_type           ,
         p_data_rec.address_line1          ,
         p_data_rec.address_line2          ,
         p_data_rec.city                   ,
         p_data_rec.state                  ,
         p_data_rec.postal_code            ,
         p_data_rec.postal_routing_code    ,
         p_data_rec.country_code           ,
         p_data_rec.province               ,
         p_data_rec.stdnt_valid_flag       ,
	 p_data_rec.primary_flag	   ,
	 p_data_rec.activity_site_cd  ,
	 p_data_rec.remarks  ;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Address_Info';
	   l_debug_str := 'Returning N from Get_Address_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Address_Info';
	   l_debug_str := 'Returning S from Get_Address_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Address_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR in Get_Address_Info. Returning U... '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Address_Info';
	   l_debug_str := 'EXCEPTION in Get_Address_Info. Returning U... '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN  'U';

END Get_Address_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Get Education information on the student
                        (IGS_SV_PRGMS_INFO).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Edu_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_PRGMS_INFO%ROWTYPE    -- Data record
)  RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT VARCHAR2(25) := 'Get_Edu_Info';

   CURSOR c_data_rec IS
     SELECT position_code          ,
            subject_field_code     ,
            education_level        ,
            primary_major          ,
            secondary_major        ,
            minor                  ,
            length_of_study        ,
            prgm_start_date        ,
            prgm_end_date          ,
            english_reqd           ,
            english_reqd_met       ,
            not_reqd_reason        ,
            educ_lvl_remarks	   ,
	    remarks
       FROM igs_sv_prgms_info cr
      WHERE cr.person_id = p_data_rec.person_id
        AND cr.prgm_action_type='EP'
        AND cr.batch_id IN
            (  SELECT max(prs.batch_id)
                 FROM igs_sv_prgms_info prs,
                      igs_sv_persons pr
               WHERE prs.person_id = pr.person_id
                     AND prs.batch_id = pr.batch_id
                     AND pr.record_status <> 'E'
                     AND prs.person_id        = p_data_rec.person_id
                     AND prs.prgm_action_type = 'EP'
            );

BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
   /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Edu_Info';
   l_debug_str := 'Entering Get_Edu_Info. p_data_rec.person_id is '||p_data_rec.person_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.position_code          ,
         p_data_rec.subject_field_code     ,
         p_data_rec.education_level        ,
         p_data_rec.primary_major          ,
         p_data_rec.secondary_major        ,
         p_data_rec.minor                  ,
         p_data_rec.length_of_study        ,
         p_data_rec.prgm_start_date        ,
         p_data_rec.prgm_end_date          ,
         p_data_rec.english_reqd           ,
         p_data_rec.english_reqd_met       ,
         p_data_rec.not_reqd_reason        ,
         p_data_rec.educ_lvl_remarks       ,
	 p_data_rec.remarks;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Edu_Info';
	  l_debug_str := 'Returning N from Get_Edu_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Edu_Info';
	  l_debug_str := 'Returning S from Get_Edu_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Edu_Info';
	  l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Get_Edu_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Edu_Info';
	  l_debug_str := 'EXCEPTION: Returning U from Get_Edu_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN  'U';

END Get_Edu_Info;




/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Get Finance information on the student
                        (IGS_SV_FINANCE_INFO)

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Finance_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_FINANCE_INFO%ROWTYPE    -- Data record
)  RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT VARCHAR2(25) := 'Get_Finance_Info';

   CURSOR c_data_rec IS
     SELECT acad_term_length       ,
            tuition                ,
            living_exp             ,
            personal_funds         ,
            dependent_exp          ,
            other_exp              ,
            other_exp_desc         ,
            school_funds           ,
            school_funds_desc      ,
            other_funds            ,
            other_funds_desc       ,
            program_sponsor        ,
            govt_org1              ,
            govt_org2              ,
            govt_org1_code         ,
            govt_org2_code         ,
            intl_org1              ,
            intl_org2              ,
            intl_org1_code         ,
            intl_org2_code         ,
            ev_govt                ,
            bi_natnl_com           ,
            other_org              ,
            remarks		   ,
	    govt_org1_othr_name    ,
	    govt_org2_othr_name    ,
            intl_org1_othr_name    ,
            intl_org2_othr_name    ,
	    other_govt_name	   ,
	    empl_funds
       FROM igs_sv_finance_info cr
      WHERE cr.person_id = p_data_rec.person_id
        AND cr.batch_id IN
            (  SELECT max(prs.batch_id)
                 FROM igs_sv_finance_info prs,
                     igs_sv_persons pr
               WHERE prs.person_id = pr.person_id
                     AND prs.batch_id = pr.batch_id
                     AND pr.record_status <> 'E'
                     AND prs.person_id = p_data_rec.person_id
            );
BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Finance_Info';
	   l_debug_str := 'Entering Get_Finance_Info. p_data_rec.person_id is '||p_data_rec.person_id;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.acad_term_length       ,
         p_data_rec.tuition                ,
         p_data_rec.living_exp             ,
         p_data_rec.personal_funds         ,
         p_data_rec.dependent_exp          ,
         p_data_rec.other_exp              ,
         p_data_rec.other_exp_desc         ,
         p_data_rec.school_funds           ,
         p_data_rec.school_funds_desc      ,
         p_data_rec.other_funds            ,
         p_data_rec.other_funds_desc       ,
         p_data_rec.program_sponsor        ,
         p_data_rec.govt_org1              ,
         p_data_rec.govt_org2              ,
         p_data_rec.govt_org1_code         ,
         p_data_rec.govt_org2_code         ,
         p_data_rec.intl_org1              ,
         p_data_rec.intl_org2              ,
         p_data_rec.intl_org1_code         ,
         p_data_rec.intl_org2_code         ,
         p_data_rec.ev_govt                ,
         p_data_rec.bi_natnl_com           ,
         p_data_rec.other_org              ,
         p_data_rec.remarks                ,
	 p_data_rec.govt_org1_othr_name    ,
	 p_data_rec.govt_org2_othr_name    ,
         p_data_rec.intl_org1_othr_name    ,
         p_data_rec.intl_org2_othr_name    ,
	 p_data_rec.other_govt_name	   ,
	 p_data_rec.empl_funds	;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Finance_Info';
	  l_debug_str := 'Returning N from Get_Finance_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Finance_Info';
	  l_debug_str := 'Returning S from Get_Finance_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Finance_Info';
	  l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Get_Finance_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Finance_Info';
	  l_debug_str := 'EXCEPTION: Returning U from Get_Finance_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN  'U';

END Get_Finance_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Get the student dependent information.
                        (IGS_SV_DEPDNT_INFO)

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Dependent_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_DEPDNT_INFO%ROWTYPE     -- Data record
)   RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT VARCHAR2(25) := 'Get_Dependent_Info';

   CURSOR c_data_rec IS
     SELECT depdnt_action_type       ,
            depdnt_sevis_id        ,
            last_name              ,
            first_name             ,
            middle_name            ,
            suffix                 ,
            birth_date             ,
            gender                 ,
            birth_cntry_code       ,
            citizen_cntry_code     ,
            relationship           ,
            termination_reason     ,
            relationship_remarks   ,
            perm_res_cntry_code    ,
            termination_effect_date,
            remarks		   ,
	    birth_cntry_resn_code  ,
	    VISA_TYPE
       FROM igs_sv_depdnt_info cr
      WHERE cr.person_id = p_data_rec.person_id
        AND cr.depdnt_id = p_data_rec.depdnt_id
        AND cr.batch_id IN
            (  SELECT max(prs.batch_id)
                 FROM igs_sv_depdnt_info prs,
                     igs_sv_persons pr
               WHERE prs.person_id = pr.person_id
                     AND prs.batch_id = pr.batch_id
                     AND pr.record_status <> 'E'
                     AND prs.person_id = p_data_rec.person_id
                     AND prs.depdnt_id = p_data_rec.depdnt_id
            );

BEGIN
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Dependent_Info';
	   l_debug_str := 'Entering Get_Dependent_Info. p_data_rec.person_id is '||p_data_rec.person_id||' and p_data_rec.depdnt_id is '||p_data_rec.depdnt_id;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   Put_Log_Msg(l_api_name||' begins ',0);

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.depdnt_action_type       ,
         p_data_rec.depdnt_sevis_id        ,
         p_data_rec.last_name              ,
         p_data_rec.first_name             ,
         p_data_rec.middle_name            ,
         p_data_rec.suffix                 ,
         p_data_rec.birth_date             ,
         p_data_rec.gender                 ,
         p_data_rec.birth_cntry_code       ,
         p_data_rec.citizen_cntry_code     ,
         p_data_rec.relationship           ,
         p_data_rec.termination_reason     ,
         p_data_rec.relationship_remarks   ,
         p_data_rec.perm_res_cntry_code    ,
         p_data_rec.termination_effect_date,
         p_data_rec.remarks		   ,
	 p_data_rec.birth_cntry_resn_code  ,
	 p_data_rec.VISA_TYPE              ;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Dependent_Info';
	  l_debug_str := 'Returning N from Get_Dependent_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
   /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Dependent_Info';
	  l_debug_str := 'Returning S from Get_Dependent_Info.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Dependent_Info';
	  l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Get_Dependent_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

   WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Dependent_Info';
	  l_debug_str := 'EXCEPTION: Returning U from Get_Dependent_Info. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN  'U';

END Get_Dependent_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Get the legal information for the student.
                        (IGS_SV_LEGAL_INFO).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Get_Legal_Info (
   p_data_rec   IN OUT NOCOPY  IGS_SV_LEGAL_INFO%ROWTYPE    -- Data record
)   RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS
   l_api_name CONSTANT VARCHAR2(25) := 'Get_Legal_Info';

   CURSOR c_data_rec IS
     SELECT psprt_number           ,
            psprt_issuing_cntry_code,
            psprt_exp_date         ,
            visa_number            ,
            visa_issuing_post      ,
            visa_issuing_cntry_code,
            visa_expiration_date   ,
            i94_number             ,
            port_of_entry          ,
            date_of_entry          ,
            remarks		   ,
	    visa_issue_date
       FROM igs_sv_legal_info cr
      WHERE cr.person_id = p_data_rec.person_id
        AND cr.batch_id IN
            (  SELECT max(prs.batch_id)
                 FROM igs_sv_legal_info prs,
                     igs_sv_persons pr
               WHERE prs.person_id = pr.person_id
                     AND prs.batch_id = pr.batch_id
                     AND pr.record_status <> 'E'
                     AND prs.person_id = p_data_rec.person_id
            );

BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Legal_Info';
	   l_debug_str := 'Entering Get_Legal_Info. p_data_rec.person_id is '||p_data_rec.person_id;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.psprt_number           ,
         p_data_rec.psprt_issuing_cntry_code,
         p_data_rec.psprt_exp_date         ,
         p_data_rec.visa_number            ,
         p_data_rec.visa_issuing_post      ,
         p_data_rec.visa_issuing_cntry_code,
         p_data_rec.visa_expiration_date   ,
         p_data_rec.i94_number             ,
         p_data_rec.port_of_entry          ,
         p_data_rec.date_of_entry          ,
         p_data_rec.remarks                ,
	 p_data_rec.visa_issue_date;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Legal_Info';
	   l_debug_str := 'Returning N from Get_Legal_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
	g_legal_status := 'NEW';
      RETURN 'N';

   END IF;

   CLOSE c_data_rec;
   g_legal_status := 'EDIT';
   Put_Log_Msg(l_api_name||' ends S ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Legal_Info';
	   l_debug_str := 'Returning S from Get_Legal_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Legal_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Get_Legal_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_Legal_Info';
	   l_debug_str := 'EXCEPTION: Returning U from Get_Legal_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN  'U';

END Get_Legal_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Updating of person issue information block
                        (IGS_SV_PERSONS).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Update_Issue_Info (
   p_data_rec  IN IGS_SV_PERSONS%ROWTYPE   -- Data record
)
IS

   l_api_name CONSTANT VARCHAR(30) := 'Update_Issue_Info';

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Issue_Info';
   l_debug_str := 'Entering Update_Issue_Info. p_data_rec.person_id is '||p_data_rec.person_id|| ' and p_data_rec.batch_id is '||p_data_rec.batch_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   UPDATE IGS_SV_PERSONS
      SET issuing_reason         = p_data_rec.issuing_reason,
          curr_session_end_date  = p_data_rec.curr_session_end_date ,
          next_session_start_date= p_data_rec.next_session_start_date ,
          other_reason           = p_data_rec.other_reason ,
          transfer_from_school   = p_data_rec.transfer_from_school ,
          ev_create_reason       = p_data_rec.ev_create_reason ,
          ev_form_number         = p_data_rec.ev_form_number,
          init_prgm_start_date   = p_data_rec.init_prgm_start_date,
	  no_show_flag		 = p_data_rec.no_show_flag,
	  last_session_flag	 = p_data_rec.last_session_flag,
	  adjudicated_flag       = p_data_rec.adjudicated_flag
    WHERE batch_id = p_data_rec.batch_id
      AND person_id = p_data_rec.person_id
      AND record_number = p_data_rec.record_number;

EXCEPTION

  WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Issue_Info';
	   l_debug_str := 'EXCEPTION in Update_Issue_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Update_Issue_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert Bio information block.
                        (IGS_SV_BIO_INFO).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Bio_Info(
   p_data_rec  IN  IGS_SV_BIO_INFO%ROWTYPE    -- Data record
)
IS
   l_api_name CONSTANT VARCHAR(30) := 'Insert_Bio_Info';

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Bio_Info';
   l_debug_str := 'Entering Insert_Bio_Info. p_data_rec.person_id is '||p_data_rec.person_id|| ' and p_data_rec.batch_id is '||p_data_rec.batch_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
    Insert_Summary_Info(p_data_rec.batch_id,
		       p_data_rec.person_id,
		       g_person_status,
		       'SV_BIO',
		       'SEND',
		       'IGS_SV_BIO_INFO',
		       '');
   INSERT INTO IGS_SV_BIO_INFO (
       batch_id               ,
       person_id              ,
       print_form             ,
       birth_date             ,
       birth_cntry_code       ,
       birth_city             ,
       citizen_cntry_code     ,
       last_name              ,
       middle_name            ,
       first_name             ,
       suffix                 ,
       gender                 ,
       legal_res_cntry_code   ,
       position_code          ,
       category_code          ,
       remarks                ,
       commuter               ,
       visa_type              ,
       creation_date          ,
       created_by             ,
       last_updated_by        ,
       last_update_date       ,
       last_update_login      ,
       birth_cntry_resn_code
     ) VALUES
     (
       p_data_rec.batch_id               ,
       p_data_rec.person_id              ,
       p_data_rec.print_form             ,
       p_data_rec.birth_date             ,
       p_data_rec.birth_cntry_code       ,
       p_data_rec.birth_city             ,
       p_data_rec.citizen_cntry_code     ,
       p_data_rec.last_name              ,
       p_data_rec.middle_name            ,
       p_data_rec.first_name             ,
       p_data_rec.suffix                 ,
       p_data_rec.gender                 ,
       p_data_rec.legal_res_cntry_code   ,
       p_data_rec.position_code          ,
       p_data_rec.category_code          ,
       p_data_rec.remarks                ,
       p_data_rec.commuter               ,
       p_data_rec.visa_type              ,
       p_data_rec.creation_date          ,
       p_data_rec.created_by             ,
       p_data_rec.last_updated_by        ,
       p_data_rec.last_update_date       ,
       p_data_rec.last_update_login      ,
       p_data_rec.birth_cntry_resn_code
     );

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Bio_Info';
	   l_debug_str := 'EXCEPTION in Insert_Bio_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      RAISE;

END Insert_Bio_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert Other information block
                        (IGS_SV_OTH_INFO)

   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Other_Info (
   p_data_rec  IN IGS_SV_OTH_INFO%ROWTYPE    -- Data record
)
IS

   l_api_name CONSTANT VARCHAR(30) := 'Insert_Other_Info';

BEGIN
   /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Other_Info';
   l_debug_str := 'Entering Insert_Other_Info. p_data_rec.person_id is '||p_data_rec.person_id|| ' and p_data_rec.batch_id is '||p_data_rec.batch_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
   Insert_Summary_Info(p_data_rec.batch_id,
		       p_data_rec.person_id,
		       g_person_status,
		       'SV_OTHER',
		       'SEND',
		       'IGS_SV_OTH_INFO',
		       '');

   INSERT INTO IGS_SV_OTH_INFO (
       batch_id               ,
       person_id              ,
       print_form             ,
       drivers_license        ,
       drivers_license_state  ,
       ssn                    ,
       tax_id                 ,
       creation_date          ,
       created_by             ,
       last_updated_by        ,
       last_update_date       ,
       last_update_login
      ) VALUES
      (p_data_rec.batch_id               ,
       p_data_rec.person_id              ,
       p_data_rec.print_form             ,
       p_data_rec.drivers_license        ,
       p_data_rec.drivers_license_state  ,
       p_data_rec.ssn                    ,
       p_data_rec.tax_id                 ,
       p_data_rec.creation_date          ,
       p_data_rec.created_by             ,
       p_data_rec.last_updated_by        ,
       p_data_rec.last_update_date       ,
       p_data_rec.last_update_login
      );

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Other_Info';
   l_debug_str := 'EXCEPTION in Insert_Other_Info. '||SQLERRM;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Insert_Other_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert site of activity information.
                        (IGS_SV_ADDRESSES).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Address_Info (
   p_addr_type IN VARCHAR,  -- Address type bein inserted- US, Foreign, Site of Activity
   p_data_rec  IN  g_address_rec_type ,  -- Data record
   p_records  IN  NUMBER   -- number of addressees found
)
IS
   l_api_name CONSTANT VARCHAR(30) := 'Insert_Address_Info';
   l_count  NUMBER(10);
   l_action VARCHAR2(10);
   l_btch_id NUMBER(14);
   l_remarks  VARCHAR2(500);
BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Address_Info';
   l_debug_str := 'Entering Insert_Address_Info. Number of records: '||p_records;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   FOR l_count IN 1..p_records LOOP
     IF p_data_rec(l_count).batch_id IS NOT NULL THEN

       IF p_addr_type = 'SOA' THEN
	   IF g_person_status = 'NEW' THEN
                 l_action := g_person_status;
	   ELSIF p_data_rec(l_count).action_type = 'A' THEN
	         l_action := 'ADD';
	   ELSIF p_data_rec(l_count).action_type = 'D' THEN
	         l_action := 'DELETE';
	   ELSE
	         l_action := 'EDIT';
	   END IF;
	   l_remarks := p_data_rec(l_count).remarks;
	   l_btch_id := chk_mut_exclusive(p_data_rec(l_count).batch_id,
				       p_data_rec(l_count).person_id,
				       l_action,
				       'SV_SOA');

	   Insert_Summary_Info(l_btch_id,
				       p_data_rec(l_count).person_id,
				       l_action,
				       'SV_SOA',
				       'SEND',
				       'IGS_SV_ADDRESSES',
				       p_data_rec(l_count).party_site_id);
       ELSE
          l_remarks := null;
          l_btch_id := p_data_rec(l_count).batch_id;
	  IF p_addr_type = 'US' THEN
		Insert_Summary_Info(l_btch_id,
		       p_data_rec(l_count).person_id,
		       g_person_status,
		       'SV_US_ADDR',
		       'SEND',
		       'IGS_SV_ADDRESSES',
		       p_data_rec(l_count).party_site_id);
          ELSE
	         Insert_Summary_Info(l_btch_id,
		       p_data_rec(l_count).person_id,
		       g_person_status,
		       'SV_F_ADDR',
		       'SEND',
		       'IGS_SV_ADDRESSES',
		       p_data_rec(l_count).party_site_id);
          END IF;
       END IF;

       INSERT INTO igs_sv_addresses (
       batch_id               ,
       person_id              ,
       party_site_id          ,
       print_form             ,
       address_type           ,
       address_line1          ,
       address_line2          ,
       city                   ,
       state                  ,
       postal_code            ,
       postal_routing_code    ,
       country_code           ,
       province               ,
       stdnt_valid_flag       ,
       creation_date          ,
       created_by             ,
       last_updated_by        ,
       last_update_date       ,
       last_update_login      ,
       action_type	      ,
       primary_flag           ,
       activity_site_cd       ,
       remarks
     ) VALUES (
       l_btch_id              ,
       p_data_rec(l_count).person_id              ,
       p_data_rec(l_count).party_site_id          ,
       p_data_rec(l_count).print_form             ,
       p_data_rec(l_count).address_type           ,
       p_data_rec(l_count).address_line1          ,
       p_data_rec(l_count).address_line2          ,
       p_data_rec(l_count).city                   ,
       p_data_rec(l_count).state                  ,
       p_data_rec(l_count).postal_code            ,
       p_data_rec(l_count).postal_routing_code    ,
       p_data_rec(l_count).country_code           ,
       p_data_rec(l_count).province               ,
       p_data_rec(l_count).stdnt_valid_flag       ,
       p_data_rec(l_count).creation_date          ,
       p_data_rec(l_count).created_by             ,
       p_data_rec(l_count).last_updated_by        ,
       p_data_rec(l_count).last_update_date       ,
       p_data_rec(l_count).last_update_login	  ,
       p_data_rec(l_count).action_type		  ,
       p_data_rec(l_count).primary_flag           ,
       p_data_rec(l_count).activity_site_cd       ,
       l_remarks
     );
     END IF;

   END LOOP;

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Address_Info';
	   l_debug_str := 'EXCEPTION in Insert_Address_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      RAISE;

END Insert_Address_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert education information on the student
                        (IGS_SV_PRGMS_INFO).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Edu_Info (
   p_edu_type  IN VARCHAR2,
   p_data_rec  IN IGS_SV_PRGMS_INFO%ROWTYPE,
   p_auth_drp_data_rec IN IGS_SV_PRGMS_INFO%ROWTYPE
)
IS

   l_api_name CONSTANT VARCHAR(30) := 'Insert_Edu_Info';
   l_count  NUMBER(10);
   l_action VARCHAR2(30);
   l_btch_id NUMBER(14);
   l_tag_code VARCHAR2(30);
   l_edu_status  VARCHAR2(10);
   l_cur_rec  IGS_SV_PRGMS_INFO%ROWTYPE;

   l_education_level            igs_pe_nonimg_form.education_level%TYPE;
   l_primary_major              igs_pe_nonimg_form.primary_major%TYPE;
   l_secondary_major            igs_pe_nonimg_form.secondary_major%TYPE;
   l_minor                      igs_pe_nonimg_form.minor%TYPE;
   l_length_of_study            igs_pe_nonimg_form.length_of_study%TYPE;
   l_prgm_start_date            igs_Sv_prgms_info.prgm_start_date%TYPE;
   l_prgm_end_date              igs_Sv_prgms_info.prgm_end_date%TYPE;
   l_english_reqd               igs_pe_nonimg_form.english_reqd%TYPE;
   l_english_reqd_met           igs_pe_nonimg_form.english_reqd_met%TYPE;
   l_not_reqd_reason            igs_pe_nonimg_form.not_reqd_reason%TYPE;
   l_educ_lvl_remarks           igs_pe_nonimg_form.educ_lvl_remarks%TYPE;
   l_position_code              igs_pe_ev_form.position_code%TYPE;
   l_subject_field_code         igs_pe_ev_form.subject_field_code%TYPE;
   l_remarks			igs_pe_ev_form.subject_field_remarks%TYPE;

BEGIN
     /* Debug */
    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Edu_Info';
	l_debug_str := 'Entering Insert_Edu_Info. p_data_rec.person_id is '||p_data_rec.person_id|| ' and p_data_rec.batch_id is '||p_data_rec.batch_id;
	fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;
       l_position_code         := p_data_rec.position_code;
       l_subject_field_code    := p_data_rec.subject_field_code;
       l_remarks               := p_data_rec.remarks;
       l_education_level       := p_data_rec.education_level;
       l_primary_major         := p_data_rec.primary_major;
       l_secondary_major       := p_data_rec.secondary_major;
       l_educ_lvl_remarks      := p_data_rec.educ_lvl_remarks;
       l_minor		       := p_data_rec.minor;
       l_length_of_study       := p_data_rec.length_of_study;
       l_english_reqd	       := p_data_rec.english_reqd;
       l_english_reqd_met      := p_data_rec.english_reqd_met;
       l_not_reqd_reason       := p_data_rec.not_reqd_reason;
       l_prgm_start_date       := p_data_rec.prgm_start_date;
       l_prgm_end_date         := p_data_rec.prgm_end_date;

       /* Debug */
    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Edu_Info';
	l_debug_str := 'After assigning values to local variables';
	fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;
    -- Nonimg action types:
     -- C  Complete Program
     -- T  Terminate Program
     -- D  Defer program
     -- E  Extend program
    -- EV action types:
     -- AP  Amend Program
     -- AF  Approve Failure
     -- CF  Conclude Failure
     -- EE Exchange Visitor Extension
     -- ED End Program
     -- EM Matriculation
     -- EF Extend Failure
     -- OI Other Infraction
     -- TR Terminate Exchange Visitor
     IF p_edu_type = 'PRGM' THEN
	   IF p_data_rec.prgm_action_type = 'C' THEN
	      l_action := 'COMPLETE';
	      l_tag_code := 'SV_STATUS';
	   ELSIF p_data_rec.prgm_action_type = 'CE' THEN
	      l_action := 'CANCEL_EXTENSION';
	      l_tag_code := 'SV_PRGMS';
	   ELSIF p_data_rec.prgm_action_type = 'T' OR p_data_rec.prgm_action_type = 'TR' THEN
	      l_action := 'TERMINATE';
	      l_tag_code := 'SV_STATUS';
	   ELSIF p_data_rec.prgm_action_type = 'D' THEN
	      l_action := 'DEFER';
	      l_tag_code := 'SV_PRGMS';
	   ELSIF p_data_rec.prgm_action_type = 'E' OR p_data_rec.prgm_action_type = 'EE' THEN
	      l_action := 'EXTENSION';
	      l_tag_code := 'SV_PRGMS';
	   ELSIF p_data_rec.prgm_action_type = 'S' OR p_data_rec.prgm_action_type = 'SP' THEN
	      l_action := 'SHORTEN';
	      l_tag_code := 'SV_PRGMS';
	  /* ELSIF p_data_rec.prgm_action_type = 'EP' THEN	-- this code is used for educational info
	      l_action := 'EDIT';
	      l_tag_code := 'SV_PRGMS';*/
           ELSIF p_data_rec.prgm_action_type = 'CP' THEN
	      l_action := 'CANCEL';
	      l_tag_code := 'SV_STATUS';
	   ELSIF p_data_rec.prgm_action_type = 'AP' THEN
	      l_action := 'AMEND';
	      l_tag_code := 'SV_PRGMS';
	   ELSIF p_data_rec.prgm_action_type = 'US' THEN
	      l_action := 'EDIT_SUBJECT';
	      l_tag_code := 'SV_PRGMS';
	   ELSIF p_data_rec.prgm_action_type = 'EM' THEN
	      l_action := 'MATRICULATE';
	      l_tag_code := 'SV_PRGMS';
	   ELSIF p_data_rec.prgm_action_type = 'ED' THEN
	      l_action := 'END';
	      l_tag_code := 'SV_STATUS';
	  /* ELSIF p_data_rec.prgm_action_type = 'AF' THEN
	      l_action := 'APPROVE_FAILURE';
	      l_tag_code := 'SV_PRGMS';
	   ELSIF p_data_rec.prgm_action_type = 'CF' THEN
	      l_action := 'CONCLUDE_FAILURE';
	      l_tag_code := 'SV_PRGMS';
	   ELSIF p_data_rec.prgm_action_type = 'EF' THEN
	      l_action := 'EXTEND_FAILURE';
	      l_tag_code := 'SV_PRGMS';*/
	   ELSE
	      l_action := 'CORRECT_INFRACTION';
	      l_tag_code := 'SV_STATUS';
	   END IF;

	   IF g_person_status = 'NEW' THEN
	       l_action := g_person_status;
	   END IF;
	   l_btch_id := chk_mut_exclusive(p_data_rec.batch_id,
					       p_data_rec.person_id,
					       l_action,
					       l_tag_code);
	   Insert_Summary_Info(l_btch_id,
			       p_data_rec.person_id,
			       l_action,
			       l_tag_code,
			       'SEND',
			       'IGS_SV_PRGMS_INFO',
			       p_data_rec.prgm_action_type);

          l_cur_rec.person_id := p_data_rec.person_id;
	  l_edu_status  := Get_Othr_Prgm_Info (p_data_rec   => l_cur_rec);
	  IF l_edu_status = 'S' THEN
	       l_position_code       := l_cur_rec.position_code;
	       l_subject_field_code  := l_cur_rec.subject_field_code ;
	       l_education_level     := l_cur_rec.education_level;
	       l_primary_major       := l_cur_rec.primary_major;
	       l_secondary_major     := l_cur_rec.secondary_major;
	       l_educ_lvl_remarks    := l_cur_rec.educ_lvl_remarks ;
	       l_minor               := l_cur_rec.minor ;
	       l_length_of_study     := l_cur_rec.length_of_study ;
	       l_english_reqd        := l_cur_rec.english_reqd;
	       l_english_reqd_met    := l_cur_rec.english_reqd_met ;
	       l_not_reqd_reason     := l_cur_rec.not_reqd_reason;
	       IF p_data_rec.remarks IS NULL THEN
	            l_remarks := l_cur_rec.remarks;
	       END IF;
	       IF p_data_rec.prgm_start_date IS NULL THEN
	            l_prgm_start_date  := l_cur_rec.prgm_start_date;
	       END IF;
               IF p_data_rec.prgm_end_date IS NULL THEN
	            l_prgm_end_date  := l_cur_rec.prgm_end_date;
	       END IF;
		  /* Debug */
	    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Edu_Info';
		l_debug_str := 'After assigning values received from get_othr_prgm_info to local variables';
		fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	    END IF;
	  END IF;

     ELSE
          l_btch_id := p_data_rec.batch_id;
     END IF;
     IF p_edu_type = 'EDU' THEN
	  IF g_person_status = 'NEW' THEN
		l_action := g_person_status;
	   ELSE
	        l_action := 'EDIT';
           END IF;
	  Insert_Summary_Info(l_btch_id,
			       p_data_rec.person_id,
			       l_action,
			       'SV_PRGMS',
			       'SEND',
			       'IGS_SV_PRGMS_INFO',
			       p_data_rec.prgm_action_type);
     END IF;
	   INSERT INTO igs_sv_prgms_info (
		batch_id               ,
		person_id              ,
		prgm_action_type       ,
		print_form             ,
		form_status_id         ,
		position_code          ,
		subject_field_code     ,
		education_level        ,
		primary_major          ,
		secondary_major        ,
		educ_lvl_remarks       ,
		minor                  ,
		length_of_study        ,
		prgm_start_date        ,
		prgm_end_date          ,
		english_reqd           ,
		english_reqd_met       ,
		not_reqd_reason        ,
		matriculation          ,
		effective_date         ,
		authorization_reason   ,
		termination_reason     ,
		end_prgm_reason        ,
		reprint_reason         ,
		submit_update          ,
		remarks                ,
		creation_date          ,
		created_by             ,
		last_updated_by        ,
		last_update_date       ,
		last_update_login      ,
		auth_action_code
	      ) VALUES
	      ( l_btch_id                        ,
	       p_data_rec.person_id              ,
	       p_data_rec.prgm_action_type       ,
	       p_data_rec.print_form             ,
	       p_data_rec.form_status_id         ,
	       l_position_code          ,
	       l_subject_field_code     ,
	       l_education_level        ,
	       l_primary_major          ,
	       l_secondary_major        ,
	       l_educ_lvl_remarks       ,
	       l_minor                  ,
	       l_length_of_study        ,
	       l_prgm_start_date        ,
	       l_prgm_end_date          ,
	       l_english_reqd           ,
	       l_english_reqd_met       ,
	       l_not_reqd_reason        ,
	       p_data_rec.matriculation          ,
	       p_data_rec.effective_date         ,
	       p_data_rec.authorization_reason   ,
	       p_data_rec.termination_reason     ,
	       p_data_rec.end_prgm_reason        ,
	       p_data_rec.reprint_reason         ,
	       p_data_rec.submit_update          ,
	       l_remarks                ,
	       p_data_rec.creation_date          ,
	       p_data_rec.created_by             ,
	       p_data_rec.last_updated_by        ,
	       p_data_rec.last_update_date       ,
	       p_data_rec.last_update_login      ,
	       p_data_rec.auth_action_code
	      );

      /* Debug */
    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Edu_Info';
	l_debug_str := 'Record inserted';
	fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Edu_Info';
   l_debug_str := 'EXCEPTION in Insert_Edu_Info. '||SQLERRM;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Insert_Edu_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert Finance information on the student
                        (IGS_SV_FINANCE_INFO)

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Finance_Info (
   p_data_rec  IN IGS_SV_FINANCE_INFO %ROWTYPE    -- Data record
)
IS

   l_api_name CONSTANT VARCHAR(30) := 'Insert_Finance_Info';

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Finance_Info';
   l_debug_str := 'Entering Insert_Finance_Info. p_data_rec.person_id is '||p_data_rec.person_id|| ' and p_data_rec.batch_id is '||p_data_rec.batch_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
   Insert_Summary_Info(p_data_rec.batch_id,
		       p_data_rec.person_id,
		       g_person_status,
		       'SV_FINANCIAL',
		       'SEND',
		       'IGS_SV_FINANCE_INFO',
		       '');
   INSERT INTO igs_sv_finance_info (
       batch_id               ,
       person_id              ,
       print_form             ,
       acad_term_length       ,
       tuition                ,
       living_exp             ,
       personal_funds         ,
       dependent_exp          ,
       other_exp              ,
       other_exp_desc         ,
       school_funds           ,
       school_funds_desc      ,
       other_funds            ,
       other_funds_desc       ,
       program_sponsor        ,
       govt_org1              ,
       govt_org2              ,
       govt_org1_code         ,
       govt_org2_code         ,
       intl_org1              ,
       intl_org2              ,
       intl_org1_code         ,
       intl_org2_code         ,
       ev_govt                ,
       bi_natnl_com           ,
       other_org              ,
       recvd_us_gvt_funds     ,
       remarks                ,
       creation_date          ,
       created_by             ,
       last_updated_by        ,
       last_update_date       ,
       last_update_login      ,
       govt_org1_othr_name    ,
       govt_org2_othr_name    ,
       intl_org1_othr_name    ,
       intl_org2_othr_name    ,
       other_govt_name	      ,
       empl_funds
      ) VALUES
      (p_data_rec.batch_id               ,
       p_data_rec.person_id              ,
       p_data_rec.print_form             ,
       p_data_rec.acad_term_length       ,
       p_data_rec.tuition                ,
       p_data_rec.living_exp             ,
       p_data_rec.personal_funds         ,
       p_data_rec.dependent_exp          ,
       p_data_rec.other_exp              ,
       p_data_rec.other_exp_desc         ,
       p_data_rec.school_funds           ,
       p_data_rec.school_funds_desc      ,
       p_data_rec.other_funds            ,
       p_data_rec.other_funds_desc       ,
       p_data_rec.program_sponsor        ,
       p_data_rec.govt_org1              ,
       p_data_rec.govt_org2              ,
       p_data_rec.govt_org1_code         ,
       p_data_rec.govt_org2_code         ,
       p_data_rec.intl_org1              ,
       p_data_rec.intl_org2              ,
       p_data_rec.intl_org1_code         ,
       p_data_rec.intl_org2_code         ,
       p_data_rec.ev_govt                ,
       p_data_rec.bi_natnl_com           ,
       p_data_rec.other_org              ,
       p_data_rec.recvd_us_gvt_funds     ,
       p_data_rec.remarks                ,
       p_data_rec.creation_date          ,
       p_data_rec.created_by             ,
       p_data_rec.last_updated_by        ,
       p_data_rec.last_update_date       ,
       p_data_rec.last_update_login	 ,
       p_data_rec.govt_org1_othr_name    ,
       p_data_rec.govt_org2_othr_name    ,
       p_data_rec.intl_org1_othr_name    ,
       p_data_rec.intl_org2_othr_name    ,
       p_data_rec.other_govt_name	 ,
       p_data_rec.empl_funds
      );

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Finance_Info';
   l_debug_str := 'EXCEPTION in Insert_Finance_Info. '||SQLERRM;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Insert_Finance_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert dependent information on the student
                        (IGS_SV_DEPDNT_INFO).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Dependent_Info (
   p_data_rec  IN g_dependent_rec_type,    -- Data record
   p_records   IN NUMBER    --Number  of dependents found
)
IS

   l_api_name CONSTANT VARCHAR(30) := 'Insert_Dependent_Info';
   l_count  NUMBER(10);
   l_action VARCHAR2(10);
   l_btch_id NUMBER(14);

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Dependent_Info';
   l_debug_str := 'Entering Insert_Dependent_Info.Number of records being inserted: '||p_records;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   FOR l_count IN 1..p_records LOOP
     IF p_data_rec(l_count).depdnt_id  IS NOT NULL THEN
	   IF g_person_status = 'NEW' THEN
	       l_action := g_person_status;
	   ELSIF p_data_rec(l_count).depdnt_action_type = 'A' THEN
	      l_action := 'ADD';
	   ELSIF p_data_rec(l_count).depdnt_action_type = 'U' THEN
	      l_action := 'EDIT';
	   ELSIF p_data_rec(l_count).depdnt_action_type = 'T' THEN
	      l_action := 'TERMINATE';
	   ELSIF p_data_rec(l_count).depdnt_action_type = 'C' THEN
	      l_action := 'CANCEL';
	   ELSIF p_data_rec(l_count).depdnt_action_type = 'R' THEN
	      l_action := 'REACTIVATE';
	   ELSIF p_data_rec(l_count).depdnt_action_type = 'E' THEN
	      l_action := 'END';
	  -- ELSIF p_data_rec(l_count).print_form = 'Y' THEN
	     -- l_action := 'REPRINT';
	   ELSE
	      l_action := 'DELETE';
	   END IF;

	   l_btch_id := chk_mut_exclusive(p_data_rec(l_count).batch_id,
				       p_data_rec(l_count).person_id,
				       l_action,
				       'SV_DEPDNT');
	   Insert_Summary_Info(l_btch_id,
				       p_data_rec(l_count).person_id,
				       l_action,
				       'SV_DEPDNT',
				       'SEND',
				       'IGS_SV_DEPDNT_INFO',
				       p_data_rec(l_count).depdnt_id);

       INSERT INTO igs_sv_depdnt_info (
          batch_id               ,
          person_id              ,
          depdnt_id              ,
          print_form             ,
          person_number          ,
          depdnt_action_type     ,
          depdnt_sevis_id        ,
          visa_type              ,
          last_name              ,
          first_name             ,
          middle_name            ,
          suffix                 ,
          birth_date             ,
          gender                 ,
          birth_cntry_code       ,
          citizen_cntry_code     ,
          relationship           ,
          termination_reason     ,
          relationship_remarks   ,
          perm_res_cntry_code    ,
          termination_effect_date,
          remarks                ,
          creation_date          ,
          created_by             ,
          last_updated_by        ,
          last_update_date       ,
          last_update_login	 ,
	  birth_cntry_resn_code
         ) VALUES
         (l_btch_id              ,  -- prbhardw CP enhancement
          p_data_rec(l_count).person_id              ,
          p_data_rec(l_count).depdnt_id              ,
          p_data_rec(l_count).print_form             ,
          p_data_rec(l_count).person_number          ,
          p_data_rec(l_count).depdnt_action_type     ,
          p_data_rec(l_count).depdnt_sevis_id        ,
          p_data_rec(l_count).visa_type              ,
          p_data_rec(l_count).last_name              ,
          p_data_rec(l_count).first_name             ,
          p_data_rec(l_count).middle_name            ,
          p_data_rec(l_count).suffix                 ,
          p_data_rec(l_count).birth_date             ,
          p_data_rec(l_count).gender                 ,
          p_data_rec(l_count).birth_cntry_code       ,
          p_data_rec(l_count).citizen_cntry_code     ,
          p_data_rec(l_count).relationship           ,
          p_data_rec(l_count).termination_reason     ,
          p_data_rec(l_count).relationship_remarks   ,
          p_data_rec(l_count).perm_res_cntry_code    ,
          p_data_rec(l_count).termination_effect_date,
          p_data_rec(l_count).remarks                ,
          p_data_rec(l_count).creation_date          ,
          p_data_rec(l_count).created_by             ,
          p_data_rec(l_count).last_updated_by        ,
          p_data_rec(l_count).last_update_date       ,
          p_data_rec(l_count).last_update_login	     ,
	  p_data_rec(l_count).birth_cntry_resn_code
         );
     END IF;
   END LOOP;

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Dependent_Info';
	   l_debug_str := 'EXCEPTION in Insert_Dependent_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Insert_Dependent_Info;


PROCEDURE Insert_Dependent_Info (
   p_data_rec  IN IGS_SV_DEPDNT_INFO%ROWTYPE --g_dependent_rec_type,    -- Data record
  -- p_records   IN NUMBER    --Number  of dependents found
)
IS

   l_api_name CONSTANT VARCHAR(30) := 'Insert_Dependent_Info';
   l_count  NUMBER(10);
   l_action VARCHAR2(10);
   l_btch_id NUMBER(14);

BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Dependent_Info';
   l_debug_str := 'Entering Insert_Dependent_Info.';
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

     IF p_data_rec.depdnt_id  IS NOT NULL THEN
	   IF g_person_status = 'NEW' THEN
	       l_action := g_person_status;
	   ELSIF p_data_rec.depdnt_action_type = 'A' THEN
	      l_action := 'ADD';
	   ELSIF p_data_rec.depdnt_action_type = 'U' THEN
	      l_action := 'EDIT';
	   ELSIF p_data_rec.depdnt_action_type = 'T' THEN
	      l_action := 'TERMINATE';
	   ELSIF p_data_rec.depdnt_action_type = 'C' THEN
	      l_action := 'CANCEL';
	   ELSIF p_data_rec.depdnt_action_type = 'R' THEN
	      l_action := 'REACTIVATE';
	   ELSIF p_data_rec.depdnt_action_type = 'E' THEN
	      l_action := 'END';
	  -- ELSIF p_data_rec(l_count).print_form = 'Y' THEN
	     -- l_action := 'REPRINT';
	   ELSE
	      l_action := 'DELETE';
	   END IF;

	   l_btch_id := chk_mut_exclusive(p_data_rec.batch_id,
				       p_data_rec.person_id,
				       l_action,
				       'SV_DEPDNT');
	   Insert_Summary_Info(l_btch_id,
				       p_data_rec.person_id,
				       l_action,
				       'SV_DEPDNT',
				       'SEND',
				       'IGS_SV_DEPDNT_INFO',
				       p_data_rec.depdnt_id);

       INSERT INTO igs_sv_depdnt_info (
          batch_id               ,
          person_id              ,
          depdnt_id              ,
          print_form             ,
          person_number          ,
          depdnt_action_type     ,
          depdnt_sevis_id        ,
          visa_type              ,
          last_name              ,
          first_name             ,
          middle_name            ,
          suffix                 ,
          birth_date             ,
          gender                 ,
          birth_cntry_code       ,
          citizen_cntry_code     ,
          relationship           ,
          termination_reason     ,
          relationship_remarks   ,
          perm_res_cntry_code    ,
          termination_effect_date,
          remarks                ,
          creation_date          ,
          created_by             ,
          last_updated_by        ,
          last_update_date       ,
          last_update_login	 ,
	  birth_cntry_resn_code
         ) VALUES
         (l_btch_id              ,  -- prbhardw CP enhancement
          p_data_rec.person_id              ,
          p_data_rec.depdnt_id              ,
          p_data_rec.print_form             ,
          p_data_rec.person_number          ,
          p_data_rec.depdnt_action_type     ,
          p_data_rec.depdnt_sevis_id        ,
          p_data_rec.visa_type              ,
          p_data_rec.last_name              ,
          p_data_rec.first_name             ,
          p_data_rec.middle_name            ,
          p_data_rec.suffix                 ,
          p_data_rec.birth_date             ,
          p_data_rec.gender                 ,
          p_data_rec.birth_cntry_code       ,
          p_data_rec.citizen_cntry_code     ,
          p_data_rec.relationship           ,
          p_data_rec.termination_reason     ,
          p_data_rec.relationship_remarks   ,
          p_data_rec.perm_res_cntry_code    ,
          p_data_rec.termination_effect_date,
          p_data_rec.remarks                ,
          p_data_rec.creation_date          ,
          p_data_rec.created_by             ,
          p_data_rec.last_updated_by        ,
          p_data_rec.last_update_date       ,
          p_data_rec.last_update_login	     ,
	  p_data_rec.birth_cntry_resn_code
         );
     END IF;

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Dependent_Info';
	   l_debug_str := 'EXCEPTION in Insert_Dependent_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Insert_Dependent_Info;

/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert Conviction information on the student.
                        (IGS_SV_CONVICTIONS).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Convictions_Info (
   p_data_rec  IN IGS_SV_CONVICTIONS%ROWTYPE
) IS

   l_api_name CONSTANT VARCHAR(30) := 'Insert_Convictions_Info';
   l_count  NUMBER(10);

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Convictions_Info';
	   l_debug_str := 'Entering Insert_Convictions_Info. p_data_rec.person_id is '||p_data_rec.person_id|| ' and p_data_rec.batch_id is '||p_data_rec.batch_id;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
       Insert_Summary_Info(p_data_rec.batch_id,
		       p_data_rec.person_id,
		       g_person_status,
		       'SV_CONVICTION',
		       'SEND',
		       'IGS_SV_CONVICTIONS',
		       '');
       INSERT INTO igs_sv_convictions (
        batch_id               ,
        person_id              ,
        conviction_id          ,
        print_form             ,
        criminal_conviction    ,
        remarks                ,
        creation_date          ,
        created_by             ,
        last_updated_by        ,
        last_update_date       ,
        last_update_login
       ) VALUES
       (p_data_rec.batch_id               ,
        p_data_rec.person_id              ,
        p_data_rec.conviction_id          ,
        p_data_rec.print_form             ,
        p_data_rec.criminal_conviction    ,
        p_data_rec.remarks                ,
        p_data_rec.creation_date          ,
        p_data_rec.created_by             ,
        p_data_rec.last_updated_by        ,
        p_data_rec.last_update_date       ,
        p_data_rec.last_update_login
       );

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Convictions_Info';
	   l_debug_str := 'EXCEPTION in Insert_Convictions_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Insert_Convictions_Info;

/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert Legal information on the student.
                        (IGS_SV_LEGAL_INFO).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Legal_Info (
   p_data_rec   IN IGS_SV_LEGAL_INFO%ROWTYPE    -- Data record
)
IS
   l_api_name CONSTANT VARCHAR(30) := 'Insert_Legal_Info';

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Legal_Info';
	   l_debug_str := 'Entering Insert_Legal_Info. p_data_rec.person_id is '||p_data_rec.person_id|| ' and p_data_rec.batch_id is '||p_data_rec.batch_id;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   Insert_Summary_Info(p_data_rec.batch_id,
		       p_data_rec.person_id,
		       g_legal_status, --g_person_status, commented for bug 5253779
		       'SV_LEGAL',
		       'SEND',
		       'IGS_SV_LEGAL_INFO',
		       '');
   INSERT INTO igs_sv_legal_info (
       batch_id               ,
       person_id              ,
       print_form             ,
       psprt_number           ,
       psprt_issuing_cntry_code,
       psprt_exp_date         ,
       visa_number            ,
       visa_issuing_post      ,
       visa_issuing_cntry_code,
       visa_expiration_date   ,
       i94_number             ,
       port_of_entry          ,
       date_of_entry          ,
       remarks                ,
       creation_date          ,
       created_by             ,
       last_updated_by        ,
       last_update_date       ,
       last_update_login      ,
       VISA_ISSUE_DATE
      ) VALUES
      (p_data_rec.batch_id               ,
       p_data_rec.person_id              ,
       p_data_rec.print_form             ,
       p_data_rec.psprt_number           ,
       p_data_rec.psprt_issuing_cntry_code,
       p_data_rec.psprt_exp_date         ,
       p_data_rec.visa_number            ,
       p_data_rec.visa_issuing_post      ,
       p_data_rec.visa_issuing_cntry_code,
       p_data_rec.visa_expiration_date   ,
       p_data_rec.i94_number             ,
       p_data_rec.port_of_entry          ,
       p_data_rec.date_of_entry          ,
       p_data_rec.remarks                ,
       p_data_rec.creation_date          ,
       p_data_rec.created_by             ,
       p_data_rec.last_updated_by        ,
       p_data_rec.last_update_date       ,
       p_data_rec.last_update_login      ,
       p_data_rec.VISA_ISSUE_DATE
      );

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Legal_Info';
   l_debug_str := 'EXCEPTION in Insert_Legal_Info. '||SQLERRM;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Insert_Legal_Info;

/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Insert employment information on the student
                        (IGS_SV_EMPL_INFO).

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Empl_Info (
   p_data_rec      IN IGS_SV_EMPL_INFO%ROWTYPE     --Data record
)
IS
   l_api_name CONSTANT VARCHAR(30) := 'Insert_Empl_Info';
   l_action VARCHAR2(6);
   l_tag_code VARCHAR2(30);
   l_btch_id NUMBER(14);
BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Empl_Info';
   l_debug_str := 'Entering Insert_Empl_Info. p_data_rec.person_id is '||p_data_rec.person_id|| ' and p_data_rec.batch_id is '||p_data_rec.batch_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
   IF g_person_status = 'NEW' THEN
      l_action := g_person_status;
   ELSIF p_data_rec.action_code = 'C' THEN
      l_action := 'CANCEL';
   ELSIF p_data_rec.action_code = 'A' OR p_data_rec.empl_rec_type = 'C' OR p_data_rec.empl_rec_type = 'O' THEN
      l_action := 'ADD';
   ELSE
      l_action := 'EDIT';
   END IF;
   IF p_data_rec.empl_rec_type = 'C' THEN
      l_tag_code := 'SV_CPT_EMPL';
   ELSIF p_data_rec.empl_rec_type = 'O' THEN
      l_tag_code := 'SV_OPT_EMPL';
   ELSE
      l_tag_code := 'SV_OFF_EMPL';
   END IF;

   l_btch_id := chk_mut_exclusive(p_data_rec.batch_id,
			       p_data_rec.person_id,
			       l_action,
			       l_tag_code);
   Insert_Summary_Info(l_btch_id,
			       p_data_rec.person_id,
			       l_action,
			       l_tag_code,
			       'SEND',
			       'IGS_SV_EMPL_INFO',
			       p_data_rec.nonimg_empl_id);
   /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
          l_debug_str := 'mut_exclusive chk returns '||l_btch_id||' for batch: '||p_data_rec.batch_id||'person: '||p_data_rec.person_id||' action: '||l_action||' tag: '||l_tag_code;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;

   INSERT INTO igs_sv_empl_info (
       batch_id               ,
       person_id              ,
       nonimg_empl_id         ,
       empl_rec_type          ,
       print_form             ,
       empl_type              ,
       recommend_empl         ,
       rescind_empl           ,
       remarks                ,
       empl_start_date        ,
       empl_end_date          ,
       empl_name              ,
       empl_time              ,
       course_relevance       ,
       empl_addr_line1        ,
       empl_addr_line2        ,
       city                   ,
       state                  ,
       postal_code            ,
       creation_date          ,
       created_by             ,
       last_updated_by        ,
       last_update_date       ,
       last_update_login      ,
       action_code
      ) VALUES
      (l_btch_id               ,    --- prbhardw CP enhancement
       p_data_rec.person_id              ,
       p_data_rec.nonimg_empl_id         ,
       p_data_rec.empl_rec_type          ,
       p_data_rec.print_form             ,
       p_data_rec.empl_type              ,
       p_data_rec.recommend_empl         ,
       p_data_rec.rescind_empl           ,
       p_data_rec.remarks                ,
       p_data_rec.empl_start_date        ,
       p_data_rec.empl_end_date          ,
       p_data_rec.empl_name              ,
       p_data_rec.empl_time              ,
       p_data_rec.course_relevance       ,
       p_data_rec.empl_addr_line1        ,
       p_data_rec.empl_addr_line2        ,
       p_data_rec.city                   ,
       p_data_rec.state                  ,
       p_data_rec.postal_code            ,
       p_data_rec.creation_date          ,
       p_data_rec.created_by             ,
       p_data_rec.last_updated_by        ,
       p_data_rec.last_update_date       ,
       p_data_rec.last_update_login	 ,
       p_data_rec.action_code
      );

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
	/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Empl_Info';
   l_debug_str := 'EXCEPTION in Insert_Empl_Info. '||SQLERRM;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END Insert_Empl_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Update registration block information.

   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Update_Registration_Info (
   p_person_rec      IN OUT NOCOPY t_student_rec    --Person record
) RETURN VARCHAR2
IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Update_Registration_Info';

   l_cur_rec     IGS_SV_LEGAL_INFO%ROWTYPE;
   l_status      VARCHAR2(1);

   l_prev_rec     IGS_SV_LEGAL_INFO%ROWTYPE;


  -- Old dates
   CURSOR c_old_ses_dates IS
     SELECT pr.curr_session_end_date,
            pr.next_session_start_date,
	    pr.last_session_flag
       FROM igs_sv_persons pr
      WHERE pr.person_id = p_person_rec.person_id
        AND pr.batch_id IN
            ( SELECT max(btch.batch_id)
                FROM igs_sv_persons prs,
                     igs_sv_batches btch,
                     igs_sv_persons pr
               WHERE prs.person_id = pr.person_id
                     AND prs.batch_id = pr.batch_id
                     AND pr.record_status <> 'E'
                     AND prs.batch_id = btch.batch_id
                     AND btch.batch_type = p_person_rec.batch_type
                     AND prs.person_id = p_person_rec.person_id
                     AND pr.curr_session_end_date  IS NOT NULL
            );

  -- Select current session dates.
   CURSOR c_ses_dates IS
     SELECT to_char(curr_session_end_date,'YYYY-MM-DD') ,
            to_char(next_session_start_date ,'YYYY-MM-DD'),
	    last_session_flag
       FROM igs_pe_nonimg_form
      WHERE nonimg_form_id = p_person_rec.form_id;

   l_start_date      igs_sv_persons.curr_session_end_date%TYPE;
   l_end_date        igs_sv_persons.next_session_start_date%TYPE;
   l_old_start_date  igs_sv_persons.curr_session_end_date%TYPE;
   l_old_end_date    igs_sv_persons.next_session_start_date%TYPE;
   l_old_session_flag  igs_pe_nonimg_form.last_session_flag%TYPE;
   l_last_session_flag  igs_pe_nonimg_form.last_session_flag%TYPE;
   l_f_addr_rec      g_address_rec_type;
   l_count           NUMBER(10);
   l_changes_found   VARCHAR2(1) := 'N'; --No changes by default


BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Registration_Info';
   l_debug_str := 'Entering Update_Registration_Info. p_person_rec.person_id is '||p_person_rec.person_id|| ' and p_person_rec.batch_type is '||p_person_rec.batch_type;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   Put_Log_Msg(l_api_name||' begins ',0);


   --Get current dates
   OPEN c_ses_dates;
   FETCH c_ses_dates
    INTO l_start_date,
         l_end_date,
	 l_last_session_flag;
   CLOSE c_ses_dates;

   -- Get old dates
   OPEN c_old_ses_dates;
   FETCH c_old_ses_dates
    INTO l_old_start_date,
         l_old_end_date,
	 l_old_session_flag;
   CLOSE c_old_ses_dates;


   -- Call Validate_Legal_Info

   p_person_rec.legal_status  := Validate_Legal_Info (p_person_rec => p_person_rec,
                                                       p_data_rec   => l_cur_rec);


   IF p_person_rec.legal_status = 'E'  THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('Validation error occurs ',1);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Registration_Info';
	   l_debug_str := 'Returning S from Update_Registration_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'S';

   ELSIF p_person_rec.legal_status = 'U' THEN --Unexpected error - terminate execution

      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Registration_Info';
	   l_debug_str := 'Unexpected error in Update_Registration_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RAISE FND_API.G_EXC_ERROR;

   ELSIF p_person_rec.legal_status = 'S' THEN


     -- Compare ancial Info
     l_prev_rec.person_id := p_person_rec.person_id;

     l_status := Get_Legal_Info ( p_data_rec  => l_prev_rec);

     IF l_status = 'U' THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Registration_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_Registration_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

        RAISE FND_API.G_EXC_ERROR;

     END IF;

     IF l_status = 'N' OR
      ( l_prev_rec.psprt_number
        ||g_delimeter||l_prev_rec.psprt_issuing_cntry_code
        ||g_delimeter||l_prev_rec.psprt_exp_date
        ||g_delimeter||l_prev_rec.visa_number
        ||g_delimeter||l_prev_rec.visa_issuing_post
        ||g_delimeter||l_prev_rec.visa_issuing_cntry_code
        ||g_delimeter||l_prev_rec.visa_expiration_date
        ||g_delimeter||l_prev_rec.i94_number
        ||g_delimeter||l_prev_rec.port_of_entry
        ||g_delimeter||l_prev_rec.date_of_entry
        ||g_delimeter||l_prev_rec.remarks
	||g_delimeter||l_prev_rec.visa_issue_date  <>
        l_cur_rec.psprt_number
        ||g_delimeter||l_cur_rec.psprt_issuing_cntry_code
        ||g_delimeter||l_cur_rec.psprt_exp_date
        ||g_delimeter||l_cur_rec.visa_number
        ||g_delimeter||l_cur_rec.visa_issuing_post
        ||g_delimeter||l_cur_rec.visa_issuing_cntry_code
        ||g_delimeter||l_cur_rec.visa_expiration_date
        ||g_delimeter||l_cur_rec.i94_number
        ||g_delimeter||l_cur_rec.port_of_entry
        ||g_delimeter||l_cur_rec.date_of_entry
        ||g_delimeter||l_cur_rec.remarks
	||g_delimeter||l_cur_rec.visa_issue_date ) THEN

        p_person_rec.legal_status := 'C';  -- Changed
        p_person_rec.changes_found := 'Y';

        Put_Log_Msg('Legal info is changed  ',0);

        IF p_person_rec.person_status <> 'I' THEN

          Insert_Legal_Info ( p_data_rec  => l_cur_rec);

        END IF;
   -- Call Validate_F_Addr_Info


    END IF;

   END IF;
   IF p_person_rec.legal_status = 'C' OR
      (  l_old_start_date <> l_start_date
       OR l_old_end_date <> l_end_date
       OR ( l_old_start_date IS NULL AND l_start_date IS NOT NULL)
       OR ( l_old_end_date IS NULL AND l_end_date IS NOT NULL)
       OR (l_old_session_flag <> l_last_session_flag)) THEN		--- prbhardw

    /* IF l_start_date IS NULL OR l_end_date IS NULL THEN

       --Error dates must be not null
        Put_Log_Msg('Dates are null  return S',0);

        FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_REG_REQD_FLD_ERR'); --Dates not found
        FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
        Put_Log_Msg(FND_MESSAGE.Get,1);

        p_person_rec.person_status := 'I';
	/* Debug
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Registration_Info';
	   l_debug_str := 'Returning S from Update_Registration_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

        RETURN 'S';

     END IF;*/
     -- Update session dates for the main record required.

      UPDATE igs_sv_persons
         SET curr_session_end_date = l_start_date,
             next_session_start_date = l_end_date,
	     last_session_flag = l_last_session_flag		---prbhardw
       WHERE person_id = p_person_rec.person_id and
             batch_id  = p_person_rec.batch_id;

       -- Check if legal info is present, not changed and hasn't beet inserted yet.

      p_person_rec.changes_found := 'Y';

      Put_Log_Msg('Legal info is changed  ',0);


      -- Foreign address is required

      p_person_rec.f_addr_status  := Validate_F_Addr_Info (p_person_rec => p_person_rec,
                                                           p_data_rec   => l_f_addr_rec,
                                                           p_records    => l_count);

      IF p_person_rec.f_addr_status  = 'E' THEN -- Validation error - mark person as invalid

        p_person_rec.person_status := 'I';

        Put_Log_Msg('Validation error occurs - return S ',1);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Registration_Info';
	   l_debug_str := 'Returning S from Update_Registration_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

        RETURN 'S';

      ELSIF p_person_rec.f_addr_status  = 'U' THEN --Unexpected error - terminate execution

        Put_Log_Msg('Unexpected error returned by validation ',1);

        RAISE FND_API.G_EXC_ERROR;

      ELSIF p_person_rec.f_addr_status = 'N' THEN -- Not found

        Put_Log_Msg('F Address block is not found return S',0);

        FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_REG_REQD_FLD_ERR'); --f address is not found
        FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', p_person_rec.person_number);
        Put_Log_Msg(FND_MESSAGE.Get,1);

        p_person_rec.person_status := 'I';
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Registration_Info';
	   l_debug_str := 'Returning S from Update_Registration_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

        RETURN 'S';

     END IF;

   END IF;

   Put_Log_Msg(l_api_name||' ends ',0);

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Registration_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Update_Registration_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS return U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Registration_Info';
	   l_debug_str := 'EXCEPTION: Returning U from Update_Registration_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN  'U';

END Update_Registration_Info;


FUNCTION Update_ev_Legal_Info (
   p_person_rec      IN OUT NOCOPY t_student_rec    --Person record
) RETURN VARCHAR2
IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Update_ev_Legal_Info';

   l_cur_rec     IGS_SV_LEGAL_INFO%ROWTYPE;
   l_status      VARCHAR2(1);

   l_prev_rec     IGS_SV_LEGAL_INFO%ROWTYPE;

   l_count           NUMBER(10);
   l_changes_found   VARCHAR2(1) := 'N'; --No changes by default


BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_ev_Legal_Info';
   l_debug_str := 'Entering Update_ev_Legal_Info. p_person_rec.person_id is '||p_person_rec.person_id|| ' and p_person_rec.batch_type is '||p_person_rec.batch_type;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   Put_Log_Msg(l_api_name||' begins ',0);

   -- Call Validate_Legal_Info

   p_person_rec.legal_status  := Validate_ev_Legal_Info (p_person_rec => p_person_rec,
                                                       p_data_rec   => l_cur_rec);

   IF p_person_rec.legal_status = 'E'  THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('Validation error occurs ',1);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_ev_Legal_Info';
	   l_debug_str := 'Returning S from Update_ev_Legal_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'S';

   ELSIF p_person_rec.legal_status = 'U' THEN --Unexpected error - terminate execution

      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_ev_Legal_Info';
	   l_debug_str := 'Unexpected error in Update_ev_Legal_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RAISE FND_API.G_EXC_ERROR;

   ELSIF p_person_rec.legal_status = 'S' THEN


     -- Compare ancial Info
     l_prev_rec.person_id := p_person_rec.person_id;

     l_status := Get_Legal_Info ( p_data_rec  => l_prev_rec);
     IF l_status = 'U' THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_ev_Legal_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_ev_Legal_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

        RAISE FND_API.G_EXC_ERROR;

     END IF;

	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Previous_Legal_Info';
          l_debug_str :=  'psprt_issuing_cntry_code=' || l_prev_rec.psprt_issuing_cntry_code;
          l_debug_str := l_debug_str || 'psprt_exp_date=' || l_prev_rec.psprt_exp_date;
          l_debug_str := l_debug_str || 'visa_number=' || l_prev_rec.visa_number ;
          l_debug_str := l_debug_str || 'visa_issuing_post=' || l_prev_rec.visa_issuing_post;
          l_debug_str := l_debug_str || 'visa_issuing_cntry_code=' || l_prev_rec.visa_issuing_cntry_code;
          l_debug_str := l_debug_str || 'visa_expiration_date=' || l_prev_rec.visa_expiration_date;
          l_debug_str := l_debug_str || 'i94_number=' || l_prev_rec.i94_number;
          l_debug_str := l_debug_str || 'port_of_entry=' || l_prev_rec.port_of_entry;
          l_debug_str := l_debug_str || 'date_of_entry=' || l_prev_rec.date_of_entry;
          l_debug_str := l_debug_str || 'remarks=' || l_prev_rec.remarks;
          l_debug_str := l_debug_str || 'visa_issue_date=' || l_prev_rec.visa_issue_date ;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Current_Legal_Info';
          l_debug_str :=  'psprt_issuing_cntry_code=' || l_cur_rec.psprt_issuing_cntry_code;
          l_debug_str := l_debug_str || 'psprt_exp_date=' || l_cur_rec.psprt_exp_date;
          l_debug_str := l_debug_str || 'visa_number=' || l_cur_rec.visa_number ;
          l_debug_str := l_debug_str || 'visa_issuing_post=' || l_cur_rec.visa_issuing_post;
          l_debug_str := l_debug_str || 'visa_issuing_cntry_code=' || l_cur_rec.visa_issuing_cntry_code;
          l_debug_str := l_debug_str || 'visa_expiration_date=' || l_cur_rec.visa_expiration_date;
          l_debug_str := l_debug_str || 'i94_number=' || l_cur_rec.i94_number;
          l_debug_str := l_debug_str || 'port_of_entry=' || l_cur_rec.port_of_entry;
          l_debug_str := l_debug_str || 'date_of_entry=' || l_cur_rec.date_of_entry;
          l_debug_str := l_debug_str || 'remarks=' || l_cur_rec.remarks;
          l_debug_str := l_debug_str || 'visa_issue_date=' || l_cur_rec.visa_issue_date ;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

     IF l_status = 'N' OR
      ( l_prev_rec.psprt_number
        ||g_delimeter||l_prev_rec.psprt_issuing_cntry_code
        ||g_delimeter||l_prev_rec.psprt_exp_date
        ||g_delimeter||l_prev_rec.visa_number
        ||g_delimeter||l_prev_rec.visa_issuing_post
        ||g_delimeter||l_prev_rec.visa_issuing_cntry_code
        ||g_delimeter||l_prev_rec.visa_expiration_date
        ||g_delimeter||l_prev_rec.i94_number
        ||g_delimeter||l_prev_rec.port_of_entry
        ||g_delimeter||l_prev_rec.date_of_entry
        ||g_delimeter||l_prev_rec.remarks
	||g_delimeter||l_prev_rec.visa_issue_date <>
        l_cur_rec.psprt_number
        ||g_delimeter||l_cur_rec.psprt_issuing_cntry_code
        ||g_delimeter||l_cur_rec.psprt_exp_date
        ||g_delimeter||l_cur_rec.visa_number
        ||g_delimeter||l_cur_rec.visa_issuing_post
        ||g_delimeter||l_cur_rec.visa_issuing_cntry_code
        ||g_delimeter||l_cur_rec.visa_expiration_date
        ||g_delimeter||l_cur_rec.i94_number
        ||g_delimeter||l_cur_rec.port_of_entry
        ||g_delimeter||l_cur_rec.date_of_entry
        ||g_delimeter||l_cur_rec.remarks
	||g_delimeter||l_cur_rec.visa_issue_date) THEN

        p_person_rec.legal_status := 'C';  -- Changed
        p_person_rec.changes_found := 'Y';

        Put_Log_Msg('Legal info is changed  ',0);

        IF p_person_rec.person_status <> 'I' THEN

          Insert_Legal_Info ( p_data_rec  => l_cur_rec);

        END IF;


    END IF;

   END IF;

   Put_Log_Msg(l_api_name||' ends ',0);

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_ev_Legal_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Update_ev_Legal_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS return U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_ev_Legal_Info';
	   l_debug_str := 'EXCEPTION: Returning U from Update_ev_Legal_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN  'U';

END Update_ev_Legal_Info;

/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Update registration block information.

   remarks            :

   Change History
   Who                  When            What
   pkpatel              30-JUN-2003     Bug 2908378
                                        Checked the status of Get_Address_Info properly.
------------------------------------------------------------------------

******************************************************************/
FUNCTION Update_EV_Address_Info (
   p_person_rec      IN OUT NOCOPY t_student_rec    --Person record
) RETURN VARCHAR2
IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Update_EV_Address_Info';
   l_status      VARCHAR2(1);


  -- Old dates
   CURSOR c_valid IS
     SELECT is_valid
       FROM igs_pe_ev_form
      WHERE ev_form_id = p_person_rec.form_id;

  -- Select current session dates.

   l_valid           VARCHAR2(1);
   l_statsite        VARCHAR2(1);
   l_us_addr_rec     g_address_rec_type;
   l_count           NUMBER(10);
   l_cur             NUMBER(10);
   l_changes_found   VARCHAR2(1) := 'N'; --No changes by default
   l_prev_us_addr_rec IGS_SV_ADDRESSES%ROWTYPE;

   l_site_addr_rec     g_address_rec_type;
   l_prev_site_addr_rec IGS_SV_ADDRESSES%ROWTYPE;



BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
   /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
   l_debug_str := 'Entering Update_EV_Address_Info. p_person_rec.form_id is '||p_person_rec.form_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;


   --Get valid flag

   OPEN c_valid;
   FETCH c_valid INTO l_valid;
   CLOSE c_valid;

   -- Foreign address is required

   p_person_rec.us_addr_status  := Validate_US_Addr_Info (p_person_rec => p_person_rec,
                                                          p_data_rec   => l_us_addr_rec,
                                                          p_records    => l_count);


   IF p_person_rec.us_addr_status  = 'E' THEN -- Validation error - mark person as invalid

     p_person_rec.person_status := 'I';

     Put_Log_Msg('Validation error occurs - return S ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
	   l_debug_str := 'Returning S from Update_EV_Address_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

     RETURN 'S';

   ELSIF p_person_rec.us_addr_status  = 'U' THEN --Unexpected error - terminate execution

     Put_Log_Msg('Unexpected error returned by validation ',1);
     /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
	   l_debug_str := 'Unexpected error in Update_EV_Address_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

     RAISE FND_API.G_EXC_ERROR;

   ELSIF p_person_rec.us_addr_status = 'N' THEN -- Not found

     Put_Log_Msg('US Address block is not found return S',0);

     FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_NO_US_ADDR_FLD_ERR'); --US address is not found
     Put_Log_Msg(FND_MESSAGE.Get,1);

     p_person_rec.person_status := 'I';
     /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
	   l_debug_str := 'Returning S from Update_EV_Address_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

     RETURN 'S';

   END IF;

   -- Get old record and compare

   l_us_addr_rec(1).STDNT_VALID_FLAG := l_valid;
   l_prev_us_addr_rec.party_site_id := l_us_addr_rec(1).party_site_id ;
   l_prev_us_addr_rec.person_id := l_us_addr_rec(1).person_id ;

   l_status := Get_Address_Info ( p_data_rec  => l_prev_us_addr_rec);

   IF l_status = 'S' THEN

     IF l_prev_us_addr_rec.address_line1
        ||g_delimeter||l_prev_us_addr_rec.address_line2
        ||g_delimeter||l_prev_us_addr_rec.city
        ||g_delimeter||l_prev_us_addr_rec.state
        ||g_delimeter||l_prev_us_addr_rec.postal_code
        ||g_delimeter||l_prev_us_addr_rec.postal_routing_code
        ||g_delimeter||l_prev_us_addr_rec.country_code
        ||g_delimeter||l_prev_us_addr_rec.province
      --||g_delimeter||l_prev_us_addr_rec.stdnt_valid_flag
        ||g_delimeter||l_prev_us_addr_rec.primary_flag <>
        l_us_addr_rec(1).address_line1
        ||g_delimeter||l_us_addr_rec(1).address_line2
        ||g_delimeter||l_us_addr_rec(1).city
        ||g_delimeter||l_us_addr_rec(1).state
        ||g_delimeter||l_us_addr_rec(1).postal_code
        ||g_delimeter||l_us_addr_rec(1).postal_routing_code
        ||g_delimeter||l_us_addr_rec(1).country_code
        ||g_delimeter||l_us_addr_rec(1).province
      --||g_delimeter||l_us_addr_rec(1).stdnt_valid_flag
        ||g_delimeter||l_us_addr_rec(1).primary_flag THEN
        p_person_rec.us_addr_status := 'C';  -- Changed
        p_person_rec.changes_found := 'Y';

        Put_Log_Msg('US address is changed ',0);

     -- 2908378 this end if was placed at the end, hence the job was errored out when there is no change in address
     END IF;

   ELSIF l_status = 'N' THEN

         --Not found

         Put_Log_Msg('US info is changed - no prev record ',0);
         p_person_rec.us_addr_status := 'C';
         p_person_rec.changes_found := 'Y';

   ELSE
         --Error found l_status = 'U'
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_EV_Address_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
         RAISE FND_API.G_EXC_ERROR;

   END IF;

   IF p_person_rec.us_addr_status  = 'C' AND p_person_rec.person_status <> 'I' THEN
      Insert_Address_Info ('US', p_data_rec  => l_us_addr_rec,p_records => 1);
   END IF;
   IF p_person_rec.person_status <> 'I' THEN --Check if site of activity is changed


     --Check site of activity
     p_person_rec.us_addr_status  := Validate_Site_Info (p_person_rec => p_person_rec,
                                                         p_data_rec   => l_site_addr_rec,
                                                         p_records    => l_count);
     IF p_person_rec.us_addr_status  = 'E' THEN -- Validation error - mark person as invalid

       p_person_rec.person_status := 'I';

       Put_Log_Msg('Validation error occurs - return S ',1);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
	   l_debug_str := 'Returning S from Update_EV_Address_Info. us_addr_status is E';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

       RETURN 'S';

     ELSIF p_person_rec.us_addr_status  = 'U' THEN --Unexpected error - terminate execution

       Put_Log_Msg('Unexpected error returned by validation ',1);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
	   l_debug_str := 'ERROR in Update_EV_Address_Info. us_addr_status is U';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

       RAISE FND_API.G_EXC_ERROR;

     ELSIF p_person_rec.us_addr_status = 'N' THEN -- Not found

       Put_Log_Msg('Site of activity Address block is not found return S',0);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
	   l_debug_str := 'Returning S from Update_EV_Address_Info. us_addr_status is N';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

       RETURN 'S';

     END IF;

     -- Get old record and compare
     p_person_rec.site_addr_status := 'N';

     FOR l_cur IN 1..l_count LOOP

          l_prev_site_addr_rec.party_site_id := l_site_addr_rec(l_cur).party_site_id ;
          l_prev_site_addr_rec.person_id := l_site_addr_rec(l_cur).person_id ;

          l_statsite := Get_Address_Info ( p_data_rec  => l_prev_site_addr_rec);



--manoj starts
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Previous_Site_Info';
          l_debug_str :=		'address_line1='		|| l_prev_site_addr_rec.address_line1;
          l_debug_str := l_debug_str || 'address_line2='		|| l_prev_site_addr_rec.address_line2;
          l_debug_str := l_debug_str || 'city='			        || l_prev_site_addr_rec.city ;
          l_debug_str := l_debug_str || 'state='			|| l_prev_site_addr_rec.state;
          l_debug_str := l_debug_str || 'postal_code='			|| l_prev_site_addr_rec.postal_code;
          l_debug_str := l_debug_str || 'postal_routing_code='		|| l_prev_site_addr_rec.postal_routing_code;
          l_debug_str := l_debug_str || 'country_code='			|| l_prev_site_addr_rec.country_code;
          l_debug_str := l_debug_str || 'province='			|| l_prev_site_addr_rec.province;
          l_debug_str := l_debug_str || 'primary_flag='			|| l_prev_site_addr_rec.primary_flag;
          l_debug_str := l_debug_str || 'activity_site_cd='		|| l_prev_site_addr_rec.activity_site_cd;
          l_debug_str := l_debug_str || 'remarks='			|| l_prev_site_addr_rec.remarks ;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Current_Site_Info';
          l_debug_str :=		'address_line1='		|| l_site_addr_rec(l_cur).address_line1;
          l_debug_str := l_debug_str || 'address_line2='		|| l_site_addr_rec(l_cur).address_line2;
          l_debug_str := l_debug_str || 'city='			        || l_site_addr_rec(l_cur).city ;
          l_debug_str := l_debug_str || 'state='			|| l_site_addr_rec(l_cur).state;
          l_debug_str := l_debug_str || 'postal_code='			|| l_site_addr_rec(l_cur).postal_code;
          l_debug_str := l_debug_str || 'postal_routing_code='		|| l_site_addr_rec(l_cur).postal_routing_code;
          l_debug_str := l_debug_str || 'country_code='			|| l_site_addr_rec(l_cur).country_code;
          l_debug_str := l_debug_str || 'province='			|| l_site_addr_rec(l_cur).province;
          l_debug_str := l_debug_str || 'primary_flag='			|| l_site_addr_rec(l_cur).primary_flag;
          l_debug_str := l_debug_str || 'activity_site_cd='		|| l_site_addr_rec(l_cur).activity_site_cd;
          l_debug_str := l_debug_str || 'remarks='			|| l_site_addr_rec(l_cur).remarks ;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
--manoj ends

          IF l_statsite = 'N' THEN

		--Not found

               Put_Log_Msg('site info is changed - no prev record ',0);
               p_person_rec.site_addr_status := 'C';
               p_person_rec.changes_found := 'Y';

          ELSIF l_statsite = 'S' THEN

	       IF l_prev_site_addr_rec.action_type = 'U' THEN

		    l_prev_site_addr_rec.action_type := 'C';
		    p_person_rec.changes_found := 'Y';
	       END IF;

	       IF l_site_addr_rec(l_cur).action_type ='D' AND l_prev_site_addr_rec.action_type <> 'D' THEN
		    p_person_rec.site_addr_status := 'C';
                    p_person_rec.changes_found := 'Y';
	       ELSIF l_site_addr_rec(l_cur).action_type <> 'D' AND l_prev_site_addr_rec.action_type = 'D' THEN
		    p_person_rec.site_addr_status := 'C';
                    p_person_rec.changes_found := 'Y';
               ELSIF l_prev_site_addr_rec.address_line1
		    ||g_delimeter||l_prev_site_addr_rec.address_line2
		    ||g_delimeter||l_prev_site_addr_rec.city
		    ||g_delimeter||l_prev_site_addr_rec.state
		    ||g_delimeter||l_prev_site_addr_rec.postal_code
		    ||g_delimeter||l_prev_site_addr_rec.postal_routing_code
		    ||g_delimeter||l_prev_site_addr_rec.country_code
		    ||g_delimeter||l_prev_site_addr_rec.province
		    --||g_delimeter||l_prev_site_addr_rec.stdnt_valid_flag
		    ||g_delimeter||l_prev_site_addr_rec.primary_flag
		    ||g_delimeter||l_prev_site_addr_rec.activity_site_cd
		    ||g_delimeter||l_prev_site_addr_rec.remarks  <>
		    l_site_addr_rec(l_cur).address_line1
		    ||g_delimeter||l_site_addr_rec(l_cur).address_line2
		    ||g_delimeter||l_site_addr_rec(l_cur).city
		    ||g_delimeter||l_site_addr_rec(l_cur).state
		    ||g_delimeter||l_site_addr_rec(l_cur).postal_code
		    ||g_delimeter||l_site_addr_rec(l_cur).postal_routing_code
		    ||g_delimeter||l_site_addr_rec(l_cur).country_code
		    ||g_delimeter||l_site_addr_rec(l_cur).province
		    --||g_delimeter||l_site_addr_rec(l_cur).stdnt_valid_flag
		    ||g_delimeter||l_site_addr_rec(l_cur).primary_flag
		    ||g_delimeter||l_site_addr_rec(l_cur).activity_site_cd
		    ||g_delimeter||l_site_addr_rec(l_cur).remarks THEN

                         p_person_rec.site_addr_status := 'C';  -- Changed
			 p_person_rec.changes_found := 'Y';

			 l_site_addr_rec(l_cur).action_type := 'U';

			 Put_Log_Msg('site address is changed ',0);
	       ELSE

		    l_site_addr_rec(l_cur).batch_id :=NULL;  -- delete from insert

               END IF;

          ELSE
           --Error found l_statsite = 'U'
		/* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
		   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_EV_Address_Info.';
		   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

           RAISE FND_API.G_EXC_ERROR;

          END IF;

         /* IF p_person_rec.changes_found = 'Y' THEN
          -- one address only
		/* Debug
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
		   l_debug_str := 'changes_found is Y. Exiting Update_EV_Address_Info.';
		   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;
               EXIT;

          END IF;*/

     END LOOP;

     IF p_person_rec.site_addr_status  = 'C' AND p_person_rec.person_status <> 'I'  THEN

        Insert_Address_Info ('SOA', p_data_rec  => l_site_addr_rec,p_records => l_count);

     END IF;
   END IF;


   Put_Log_Msg(l_api_name||' ends ',0);
   /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
   l_debug_str := 'Returning S from Update_EV_Address_Info.';
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Update_EV_Address_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS return U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Address_Info';
	   l_debug_str := 'EXCEPTION: Returning U from Update_EV_Address_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN  'U';

END Update_EV_Address_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Update Personal information block.

   Remarks            : 'S' - success
                        'U' - Unexpected error

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Update_Personal_Info (
   p_person_rec      IN OUT NOCOPY  t_student_rec    --Person record
) RETURN VARCHAR2
IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Update_Personal_Info';
   l_bio_rec     IGS_SV_BIO_INFO%ROWTYPE;
   l_oth_rec     IGS_SV_OTH_INFO%ROWTYPE;
   l_f_addr_rec  g_address_rec_type;
   l_us_addr_rec g_address_rec_type;
   l_count          NUMBER(10);
   l_changes_found  VARCHAR2(1) := 'N'; --No changes by default
   l_status      VARCHAR2(1);

   l_prev_bio_rec     IGS_SV_BIO_INFO%ROWTYPE;
   l_prev_oth_rec     IGS_SV_OTH_INFO%ROWTYPE;
   l_prev_f_addr_rec  IGS_SV_ADDRESSES%ROWTYPE;
   l_prev_us_addr_rec IGS_SV_ADDRESSES%ROWTYPE;


BEGIN
   /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
   l_debug_str := 'Entering Update_Personal_Info. p_person_rec.person_id is '||p_person_rec.person_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   Put_Log_Msg(l_api_name||' begins ',0);


   -- Call Validate_Bio_Info

   p_person_rec.bio_status  := Validate_Bio_Info (p_person_rec =>p_person_rec,
                                                   p_data_rec  => l_bio_rec);

   IF p_person_rec.batch_type = 'I' THEN
     -- Call Validate_Other_Info

     p_person_rec.other_status  := Validate_Other_Info (p_person_rec => p_person_rec,
                                                        p_data_rec   => l_oth_rec);

     -- Call Validate_F_Addr_Info

     p_person_rec.f_addr_status  := Validate_F_Addr_Info (p_person_rec => p_person_rec,
                                                          p_data_rec   => l_f_addr_rec,
                                                          p_records    => l_count);


     -- Call Validate_US_address_Info

     p_person_rec.us_addr_status  := Validate_Us_Addr_Info (p_person_rec => p_person_rec,
                                                            p_data_rec   => l_us_addr_rec,
                                                            p_records   => l_count);

   ELSE

     p_person_rec.other_status  := 'N';
     p_person_rec.f_addr_status := 'N';
     p_person_rec.us_addr_status  := 'N';

   END IF;

   IF p_person_rec.bio_status = 'E'
      OR p_person_rec.other_status = 'E'
      OR p_person_rec.f_addr_status  = 'E'
      OR p_person_rec.us_addr_status = 'E' THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('UPI - Validation error occurs ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'Returning S from Update_Personal_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'S';

   END IF;

   IF ( p_person_rec.bio_status = 'U'
      OR p_person_rec.other_status = 'U'
      OR p_person_rec.f_addr_status  = 'U'
      OR p_person_rec.us_addr_status = 'U')  THEN --Unexpected error - terminate execution

      Put_Log_Msg('UPI - unexpected error returned by validation ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_Personal_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RAISE FND_API.G_EXC_ERROR;

   ELSIF p_person_rec.bio_status = 'N' THEN -- Not found

      -- These are I-20 blocks and should be found. If this happens - its a bug

      Put_Log_Msg('UPI BIO block is not found ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'IGS_SV_UNEXP_EXCPT_ERR in Update_Personal_Info. bio_status is N';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;



      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_UNEXP_EXCPT_ERR'); -- I-20 is missing! Unexpected error
      FND_MESSAGE.SET_TOKEN('BLOCK_ID',2);
      FND_MSG_PUB.Add;

      RAISE FND_API.G_EXC_ERROR;

   END IF;

   -- Compare BIO
   l_prev_bio_rec.person_id := l_bio_rec.person_id;

   l_status := Get_Bio_Info ( p_data_rec  => l_prev_bio_rec);

   IF l_status = 'U' THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR in Update_Personal_Info. l_status is U';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   IF l_prev_bio_rec.birth_date
      ||g_delimeter||l_prev_bio_rec.birth_cntry_code
      ||g_delimeter||l_prev_bio_rec.citizen_cntry_code
      ||g_delimeter||l_prev_bio_rec.last_name
      ||g_delimeter||l_prev_bio_rec.middle_name
      ||g_delimeter||l_prev_bio_rec.first_name
      ||g_delimeter||l_prev_bio_rec.suffix
      ||g_delimeter||l_prev_bio_rec.gender
      ||g_delimeter||l_prev_bio_rec.legal_res_cntry_code
      ||g_delimeter||l_prev_bio_rec.position_code
      ||g_delimeter||l_prev_bio_rec.remarks
      ||g_delimeter||l_prev_bio_rec.commuter
      ||g_delimeter||l_prev_bio_rec.birth_cntry_resn_code
      ||g_delimeter||l_prev_bio_rec.birth_city	    <>
      l_bio_rec.birth_date
      ||g_delimeter||l_bio_rec.birth_cntry_code
      ||g_delimeter||l_bio_rec.citizen_cntry_code
      ||g_delimeter||l_bio_rec.last_name
      ||g_delimeter||l_bio_rec.middle_name
      ||g_delimeter||l_bio_rec.first_name
      ||g_delimeter||l_bio_rec.suffix
      ||g_delimeter||l_bio_rec.gender
      ||g_delimeter||l_bio_rec.legal_res_cntry_code
      ||g_delimeter||l_bio_rec.position_code
      ||g_delimeter||l_bio_rec.remarks
      ||g_delimeter||l_bio_rec.commuter
      ||g_delimeter||l_bio_rec.birth_cntry_resn_code
      ||g_delimeter||l_bio_rec.birth_city      THEN

      p_person_rec.bio_status := 'C';  -- Changed
      p_person_rec.changes_found := 'Y';
      Put_Log_Msg('Bio info is changed  ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'Bio Info changed. l_prev_bio_rec.citizen_cntry_code '||l_prev_bio_rec.citizen_cntry_code||' and l_bio_rec.citizen_cntry_code:'||l_bio_rec.citizen_cntry_code;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   END IF;

   -- Get other
   IF p_person_rec.other_status = 'S' THEN --Found new info

      l_prev_oth_rec.person_id := l_oth_rec.person_id;

      l_status := Get_Other_Info ( p_data_rec  => l_prev_oth_rec);

      IF l_status = 'S' THEN

         IF l_prev_oth_rec.drivers_license
            ||g_delimeter||l_prev_oth_rec.drivers_license_state
            ||g_delimeter||l_prev_oth_rec.ssn
            ||g_delimeter||l_prev_oth_rec.tax_id  <>
            l_oth_rec.drivers_license
            ||g_delimeter||l_oth_rec.drivers_license_state
            ||g_delimeter||l_oth_rec.ssn
            ||g_delimeter||l_oth_rec.tax_id  THEN

            p_person_rec.other_status := 'C';  -- Changed
            Put_Log_Msg('Other info is changed ',0);
            p_person_rec.changes_found := 'Y';

         END IF;

      ELSIF l_status = 'N' THEN

         --Not found
         Put_Log_Msg('Other info is changed  ',0);
         p_person_rec.other_status := 'C';
         p_person_rec.changes_found := 'Y';


      ELSE

         --Error found l_status = 'U'
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR in Update_Personal_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

         RAISE FND_API.G_EXC_ERROR;

      END IF;

   END IF; --End of read and compare

   -- Compare Address

   IF p_person_rec.f_addr_status = 'S' THEN --Found new info

      l_prev_f_addr_rec.person_id := l_f_addr_rec(1).person_id ;
      l_prev_f_addr_rec.party_site_id := l_f_addr_rec(1).party_site_id ;

      l_status := Get_Address_Info ( p_data_rec  => l_prev_f_addr_rec);

      IF l_status = 'S' THEN

         IF l_prev_f_addr_rec.address_line1
            ||g_delimeter||l_prev_f_addr_rec.address_line2
            ||g_delimeter||l_prev_f_addr_rec.city
            ||g_delimeter||l_prev_f_addr_rec.state
            ||g_delimeter||l_prev_f_addr_rec.postal_code
            ||g_delimeter||l_prev_f_addr_rec.postal_routing_code
            ||g_delimeter||l_prev_f_addr_rec.country_code
            ||g_delimeter||l_prev_f_addr_rec.province
          --  ||g_delimeter||l_prev_f_addr_rec.stdnt_valid_flag
            ||g_delimeter||l_prev_f_addr_rec.primary_flag <>
            l_f_addr_rec(1).address_line1
            ||g_delimeter||l_f_addr_rec(1).address_line2
            ||g_delimeter||l_f_addr_rec(1).city
            ||g_delimeter||l_f_addr_rec(1).state
            ||g_delimeter||l_f_addr_rec(1).postal_code
            ||g_delimeter||l_f_addr_rec(1).postal_routing_code
            ||g_delimeter||l_f_addr_rec(1).country_code
            ||g_delimeter||l_f_addr_rec(1).province
           -- ||g_delimeter||l_f_addr_rec(1).stdnt_valid_flag
            ||g_delimeter||l_f_addr_rec(1).primary_flag THEN

            p_person_rec.f_addr_status := 'C';  -- Changed

            p_person_rec.changes_found := 'Y';
            Put_Log_Msg('F Address is changed',0);

         END IF;

      ELSIF l_status = 'N' THEN

         --Not found

         Put_Log_Msg('F address info is changed  ',0);
         p_person_rec.f_addr_status := 'C';
         p_person_rec.changes_found := 'Y';

      ELSE

         --Error found l_status = 'U'
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR in Update_Personal_Info. f_addr_status is S';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

         RAISE FND_API.G_EXC_ERROR;

      END IF;

   END IF; --End of read and compare


   IF p_person_rec.us_addr_status = 'S' THEN --Found new info

      l_prev_us_addr_rec.party_site_id := l_us_addr_rec(1).party_site_id ;
      l_prev_us_addr_rec.person_id := l_us_addr_rec(1).person_id ;

      l_status := Get_Address_Info ( p_data_rec  => l_prev_us_addr_rec);

      IF l_status = 'S' THEN

         IF l_prev_us_addr_rec.address_line1
            ||g_delimeter||l_prev_us_addr_rec.address_line2
            ||g_delimeter||l_prev_us_addr_rec.city
            ||g_delimeter||l_prev_us_addr_rec.state
            ||g_delimeter||l_prev_us_addr_rec.postal_code
            ||g_delimeter||l_prev_us_addr_rec.postal_routing_code
            ||g_delimeter||l_prev_us_addr_rec.country_code
            ||g_delimeter||l_prev_us_addr_rec.province
          --||g_delimeter||l_prev_us_addr_rec.stdnt_valid_flag
            ||g_delimeter||l_prev_us_addr_rec.primary_flag <>
            l_us_addr_rec(1).address_line1
            ||g_delimeter||l_us_addr_rec(1).address_line2
            ||g_delimeter||l_us_addr_rec(1).city
            ||g_delimeter||l_us_addr_rec(1).state
            ||g_delimeter||l_us_addr_rec(1).postal_code
            ||g_delimeter||l_us_addr_rec(1).postal_routing_code
            ||g_delimeter||l_us_addr_rec(1).country_code
            ||g_delimeter||l_us_addr_rec(1).province
         -- ||g_delimeter||l_us_addr_rec(1).stdnt_valid_flag
            ||g_delimeter||l_us_addr_rec(1).primary_flag THEN

            p_person_rec.us_addr_status := 'C';  -- Changed
            p_person_rec.changes_found := 'Y';

            Put_Log_Msg('US address is changed ',0);

         END IF;

      ELSIF l_status = 'N' THEN

         --Not found

         Put_Log_Msg('US info is changed - no prev record ',0);
         p_person_rec.us_addr_status := 'C';
         p_person_rec.changes_found := 'Y';

      ELSE
         --Error found l_status = 'U'
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR in Update_Personal_Info. us_addr_status is S';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

         RAISE FND_API.G_EXC_ERROR;

      END IF;

   END IF; --End of read and compare

   -- Insert
   IF p_person_rec.person_status <> 'I'
      AND (p_person_rec.bio_status = 'C'
        OR p_person_rec.other_status = 'C'
        OR p_person_rec.f_addr_status  = 'C'
        OR p_person_rec.us_addr_status = 'C') THEN

      p_person_rec.changes_found := 'Y';
      Put_Log_Msg('Info is chnaged for the block - do insert',0);

      -- There are changes need to insert data
      IF  p_person_rec.bio_status  = 'C'  THEN
          Insert_Bio_Info ( p_data_rec  => l_bio_rec);
      END IF;

      IF p_person_rec.batch_type = 'I' AND p_person_rec.other_status  = 'C' THEN

         Insert_Other_Info ( p_data_rec  => l_oth_rec);

      END IF;

      IF  p_person_rec.batch_type = 'I' AND   p_person_rec.f_addr_status  = 'C'  THEN

         Insert_Address_Info ('F', p_data_rec  => l_f_addr_rec,p_records => 1);   --- prbhardw CP enhancement

      END IF;

      IF  p_person_rec.batch_type = 'I' AND p_person_rec.us_addr_status  = 'C'  THEN

         Insert_Address_Info ( 'US',p_data_rec  => l_us_addr_rec,p_records => 1);   --- prbhardw CP enhancement

      END IF;

   END IF;

   Put_Log_Msg(l_api_name||' ends ',0);
   /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
   l_debug_str := 'Returning S from Update_Personal_Info.';
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Update_Personal_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS return U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Personal_Info';
	   l_debug_str := 'EXCEPTION: Returning U from Update_Personal_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN  'U';

END Update_Personal_Info;

FUNCTION Get_EV_Prgm_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_PRGMS_INFO%ROWTYPE     -- Data record
)   RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT VARCHAR2(25) := 'Get_EV_Prgm_Info';

   CURSOR c_data_rec IS
     SELECT  prgm_action_type,
	   prgm_start_date,
	   prgm_end_date ,
	   effective_date,
	   termination_reason,
	   end_prgm_reason,
	   remarks
     FROM igs_sv_prgms_info
     WHERE person_id = p_data_rec.person_id AND
            batch_id IN
            (  SELECT max(prg.batch_id)
                 FROM igs_sv_prgms_info prg,
                      igs_sv_persons pr
                WHERE prg.person_id = pr.person_id
                      AND prg.batch_id = pr.batch_id
                      AND pr.record_status <> 'E'
                      AND prg.person_id = p_data_rec.person_id
            )
     ORDER BY effective_date;
   BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_EV_Prgm_Info';
	  l_debug_str := 'Entering Get_EV_Prgm_Info. p_data_rec.person_id is '||p_data_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' begins ',0);

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.prgm_action_type,
         p_data_rec.prgm_start_date,
         p_data_rec.prgm_end_date ,
         p_data_rec.effective_date,
         p_data_rec.termination_reason,
         p_data_rec.end_prgm_reason,
         p_data_rec.remarks ;

   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_EV_Prgm_Info';
	  l_debug_str := 'Returning N from Get_EV_Prgm_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_EV_Prgm_Info';
	  l_debug_str := 'Returning S from Get_EV_Prgm_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_EV_Prgm_Info';
	  l_debug_str := 'Exception in Get_EV_Prgm_Info '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
      RETURN 'U';

   WHEN OTHERS THEN
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_EV_Prgm_Info';
	  l_debug_str := 'Exception in Get_EV_Prgm_Info '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      RETURN  'U';

END Get_EV_Prgm_Info;

FUNCTION Get_nonimg_Prgm_Info (
   p_data_rec  IN OUT NOCOPY  IGS_SV_PRGMS_INFO%ROWTYPE     -- Data record
)   RETURN VARCHAR2  -- 'S' Record found, 'N' - not found. 'U' - Unexpected error
IS

   l_api_name CONSTANT VARCHAR2(25) := 'Get_nonimg_Prgm_Info';

   CURSOR c_data_rec IS
     SELECT effective_date,
	   prgm_action_type,
	   prgm_start_date,
	   prgm_end_date,
	   remarks,
	   termination_reason,
	   print_form
     FROM igs_sv_prgms_info
     WHERE person_id = p_data_rec.person_id AND
            batch_id IN
            (  SELECT max(prg.batch_id)
                 FROM igs_sv_prgms_info prg,
                      igs_sv_persons pr
                WHERE prg.person_id = pr.person_id
                      AND prg.batch_id = pr.batch_id
                      AND pr.record_status <> 'E'
                      AND prg.person_id = p_data_rec.person_id
            )
     ORDER BY effective_date;
   BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_nonimg_Prgm_Info';
	  l_debug_str := 'Entering Get_nonimg_Prgm_Info. p_data_rec.person_id is '||p_data_rec.person_id;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   Put_Log_Msg(l_api_name||' begins ',0);

   OPEN c_data_rec;
   FETCH c_data_rec
    INTO p_data_rec.effective_date,
         p_data_rec.prgm_action_type,
         p_data_rec.prgm_start_date,
         p_data_rec.prgm_end_date,
         p_data_rec.remarks,
         p_data_rec.termination_reason,
         p_data_rec.print_form  ;
   IF c_data_rec%NOTFOUND THEN

      Put_Log_Msg('Record not found ',0);
      CLOSE c_data_rec;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_nonimg_Prgm_Info';
	  l_debug_str := 'Returning N from Get_nonimg_Prgm_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'N';

   END IF;

   CLOSE c_data_rec;

   Put_Log_Msg(l_api_name||' ends S ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_nonimg_Prgm_Info';
	  l_debug_str := 'Returning S from Get_nonimg_Prgm_Info';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_nonimg_Prgm_Info';
	  l_debug_str := 'Exception in Get_nonimg_Prgm_Info '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      Put_Log_Msg(l_api_name||' EXEC ERROR ',1);
      RETURN 'U';

   WHEN OTHERS THEN
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Get_nonimg_Prgm_Info';
	  l_debug_str := 'Exception in Get_nonimg_Prgm_Info '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      RETURN  'U';

END Get_nonimg_Prgm_Info;

/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Update program information block

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Update_Program_Info (
   p_person_rec      IN OUT NOCOPY  t_student_rec    --Person record
) RETURN VARCHAR2
IS

   l_api_name   CONSTANT VARCHAR2(30)   := 'Update_Program_Info';
   l_cur_rec    IGS_SV_PRGMS_INFO%ROWTYPE;
   l_status     VARCHAR2(1);
   l_prev_rec   IGS_SV_PRGMS_INFO%ROWTYPE;
   l_count      NUMBER(10);
   l_cur_prgm_rec  g_edu_rec_type;
   l_cur_authdrp_rec  g_edu_rec_type;
   l_auth_rec_count NUMBER := 0;
BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
   /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
   l_debug_str := 'Entering Update_Program_Info. p_person_rec.person_id is '||p_person_rec.person_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   -- First part - check program Info block

   p_person_rec.edu_status  := Validate_Edu_Info (p_person_rec => p_person_rec,
                                                  p_data_rec   => l_cur_rec);

   IF p_person_rec.edu_status = 'E'  THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('Validation error occurs ',1);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'Returning S from Update_Program_Info. p_person_rec.edu_status is E';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'S';

   END IF;

   IF p_person_rec.edu_status = 'U' THEN --Unexpected error - terminate execution

      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_Program_Info. p_person_rec.edu_status is U';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RAISE FND_API.G_EXC_ERROR;

   ELSIF p_person_rec.edu_status = 'N' THEN -- Not found

      -- These are I-20 blocks and should be found. If this happens - its a bug

      Put_Log_Msg('EDU block is not found ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_Program_Info. p_person_rec.edu_status is N.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_UNEXP_EXCPT_ERR'); -- I-20 is missing! Unexpected error
      FND_MESSAGE.SET_TOKEN('BLOCK_ID',3);
      FND_MSG_PUB.Add;

      RAISE FND_API.G_EXC_ERROR;

   END IF;


   -- Compare EDU Info
   l_prev_rec.person_id := p_person_rec.person_id;

   l_status := Get_Edu_Info ( p_data_rec  => l_prev_rec);

   IF l_status = 'U' OR l_status = 'N' THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_Program_Info. l_status is U or N.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   IF l_prev_rec.position_code
      ||g_delimeter||l_prev_rec.subject_field_code
      ||g_delimeter||l_prev_rec.education_level
      ||g_delimeter||l_prev_rec.primary_major
      ||g_delimeter||l_prev_rec.secondary_major
      ||g_delimeter||l_prev_rec.educ_lvl_remarks
      ||g_delimeter||l_prev_rec.minor
      ||g_delimeter||l_prev_rec.length_of_study
      ||g_delimeter||l_prev_rec.prgm_start_date
      ||g_delimeter||l_prev_rec.prgm_end_date
      ||g_delimeter||l_prev_rec.english_reqd
      ||g_delimeter||l_prev_rec.english_reqd_met
      ||g_delimeter||l_prev_rec.not_reqd_reason
        <>
      l_cur_rec.position_code
      ||g_delimeter||l_cur_rec.subject_field_code
      ||g_delimeter||l_cur_rec.education_level
      ||g_delimeter||l_cur_rec.primary_major
      ||g_delimeter||l_cur_rec.secondary_major
      ||g_delimeter||l_cur_rec.educ_lvl_remarks
      ||g_delimeter||l_cur_rec.minor
      ||g_delimeter||l_cur_rec.length_of_study
      ||g_delimeter||l_cur_rec.prgm_start_date
      ||g_delimeter||l_cur_rec.prgm_end_date
      ||g_delimeter||l_cur_rec.english_reqd
      ||g_delimeter||l_cur_rec.english_reqd_met
      ||g_delimeter||l_cur_rec.not_reqd_reason
      THEN

      p_person_rec.edu_status := 'C';  -- Changed

      p_person_rec.changes_found := 'Y';

      Put_Log_Msg('EDU info is changed  ',0);

      IF p_person_rec.person_status <> 'I'  THEN

        Insert_Edu_Info ( 'EDU', p_data_rec  => l_cur_rec, p_auth_drp_data_rec => NULL);

      END IF;

   END IF;

   -- Validate program block

   p_person_rec.edu_status  := Validate_Prgm_Info (p_person_rec =>p_person_rec, p_data_rec  => l_cur_prgm_rec, p_records => l_count, p_auth_drp_data_rec => l_cur_authdrp_rec);
   IF p_person_rec.edu_status = 'E'  THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('Validation error occurs ',1);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'Returning S from Update_Program_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'S';

   ELSIF p_person_rec.edu_status = 'U' THEN --Unexpected error - terminate execution

      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_Program_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RAISE FND_API.G_EXC_ERROR;

   END IF;

   FOR l_current IN 1.. l_count LOOP

      Put_Log_Msg('Checking NI programs  '||l_cur_prgm_rec(l_current).person_id,0);
      l_prev_rec.person_id := p_person_rec.person_id;

      p_person_rec.edu_status := 'S';  -- Changed

      l_status := Get_nonimg_Prgm_Info ( p_data_rec => l_prev_rec);

      IF l_status = 'U' THEN
       /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
          l_debug_str := 'Unexpected error in Update_Employment_Info. l_status is U.';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF  l_status = 'S' THEN
          IF
	  (
	   l_prev_rec.prgm_action_type
	   ||g_delimeter||l_prev_rec.effective_date
	   ||g_delimeter||l_prev_rec.print_form
	   ||g_delimeter||l_prev_rec.prgm_start_date
	   ||g_delimeter||l_prev_rec.prgm_end_date
	   ||g_delimeter||l_prev_rec.remarks
	   ||g_delimeter||l_prev_rec.termination_reason
	   <>
	   l_cur_prgm_rec(l_current).prgm_action_type
	   ||g_delimeter||l_cur_prgm_rec(l_current).effective_date
	   ||g_delimeter||l_cur_prgm_rec(l_current).print_form
	   ||g_delimeter||l_cur_prgm_rec(l_current).prgm_start_date
	   ||g_delimeter||l_cur_prgm_rec(l_current).prgm_end_date
	   ||g_delimeter||l_cur_prgm_rec(l_current).remarks
	   ||g_delimeter||l_cur_prgm_rec(l_current).termination_reason
	  ) THEN
		 Put_Log_Msg('Info is changed for  '||l_cur_prgm_rec(l_current).person_id,0);
		 p_person_rec.edu_status := 'C';  -- Changed
		 p_person_rec.changes_found := 'Y';
             END IF;

      ELSE   --Remove current person from the insert list
        l_cur_prgm_rec(l_current).person_id := NULL;
      END IF;

      IF p_person_rec.edu_status = 'C' AND p_person_rec.person_status <> 'I' THEN
	Insert_Edu_Info ('PRGM', p_data_rec  => l_cur_prgm_rec(l_current), p_auth_drp_data_rec => NULL);  -- prbhardw EN change
      END IF;
   END LOOP;

    -- prbhardw EN change
    l_auth_rec_count := l_cur_authdrp_rec.COUNT;
     FOR l_current IN 1.. l_auth_rec_count LOOP
	  IF l_cur_authdrp_rec(l_current).auth_action_code IS NOT NULL AND l_cur_authdrp_rec(l_current).prgm_action_type IS NOT NULL THEN
	    Put_Log_Msg('validating Authorization. going to insert record',0);
	    p_person_rec.edu_status := 'C';  -- Changed
            p_person_rec.changes_found := 'Y';
	    Put_Log_Msg('Authorization Info is changed for  '||l_cur_authdrp_rec(l_current).person_id,0);
	     Insert_Auth_Code (p_auth_drp_data_rec => l_cur_authdrp_rec(l_current));
	  END IF;
     END LOOP;

  Put_Log_Msg(l_api_name||' ends ',0);
    /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'Final Return S from Update_Program_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

    RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Update_Program_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS return U',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'EXCEPTION: Returning U from Update_Program_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN  'U';

END Update_Program_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Update EV program information block

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Update_EV_Program_Info (
   p_person_rec      IN OUT NOCOPY  t_student_rec    --Person record
) RETURN VARCHAR2
IS

   l_api_name   CONSTANT VARCHAR2(30)   := 'Update_EV_Program_Info';
   l_cur_rec    IGS_SV_PRGMS_INFO%ROWTYPE;
   l_cur_authdrp_rec  g_edu_rec_type;
   l_status     VARCHAR2(1);
   l_prev_rec   IGS_SV_PRGMS_INFO%ROWTYPE;
   l_count      NUMBER(10);
   l_cur_prgm_rec  g_edu_rec_type;

BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
   /* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Program_Info';
   l_debug_str := 'Entering Update_EV_Program_Info. p_person_rec.person_id is '||p_person_rec.person_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;


	p_person_rec.edu_status  := Validate_Edu_Info (p_person_rec => p_person_rec,
                                                  p_data_rec   => l_cur_rec);

   IF p_person_rec.edu_status = 'E'  THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('Validation error occurs ',1);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'Returning S from Update_Program_Info. p_person_rec.edu_status is E';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'S';

   END IF;

   IF p_person_rec.edu_status = 'U' THEN --Unexpected error - terminate execution

      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_Program_Info. p_person_rec.edu_status is U';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RAISE FND_API.G_EXC_ERROR;

   ELSIF p_person_rec.edu_status = 'N' THEN -- Not found

      -- These are I-20 blocks and should be found. If this happens - its a bug

      Put_Log_Msg('EDU block is not found ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_Program_Info. p_person_rec.edu_status is N.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_UNEXP_EXCPT_ERR'); -- I-20 is missing! Unexpected error
      FND_MESSAGE.SET_TOKEN('BLOCK_ID',3);
      FND_MSG_PUB.Add;

      RAISE FND_API.G_EXC_ERROR;

   END IF;


   -- Compare EDU Info
   l_prev_rec.person_id := p_person_rec.person_id;

   l_status := Get_Edu_Info ( p_data_rec  => l_prev_rec);

   IF l_status = 'U' OR l_status = 'N' THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Program_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_Program_Info. l_status is U or N.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      RAISE FND_API.G_EXC_ERROR;

   END IF;
/*
   IF l_prev_rec.position_code
      ||g_delimeter||l_prev_rec.remarks
      <>
      l_cur_rec.position_code
      ||g_delimeter||l_cur_rec.remarks
      THEN

      p_person_rec.edu_status := 'C';  -- Changed

      p_person_rec.changes_found := 'Y';

      Put_Log_Msg('EDU info is changed  ',0);

      IF p_person_rec.person_status <> 'I'  THEN

        Insert_Edu_Info ( 'EDU', p_data_rec  => l_cur_rec, p_auth_drp_data_rec => l_cur_authdrp_rec);

      END IF;

   END IF;
*/
   IF l_prev_rec.subject_field_code  <>  l_cur_rec.subject_field_code  THEN

      p_person_rec.edu_status := 'C';  -- Changed

      p_person_rec.changes_found := 'Y';

      Put_Log_Msg('EDU info is changed  ',0);

      IF p_person_rec.person_status <> 'I'  THEN
	l_cur_rec.prgm_action_type := 'US';
        Insert_Edu_Info ( 'PRGM', p_data_rec  => l_cur_rec, p_auth_drp_data_rec => NULL);

      END IF;

   END IF;




   -- Validate program block

   p_person_rec.edu_status  := Validate_Prgm_Info (p_person_rec =>p_person_rec, p_data_rec  => l_cur_prgm_rec, p_records => l_count,
						   p_auth_drp_data_rec => l_cur_authdrp_rec);
   IF p_person_rec.edu_status = 'E'  THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('Validation error occurs ',1);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Program_Info';
	   l_debug_str := 'Returning S from Update_EV_Program_Info. p_person_rec.edu_status is E.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'S';

   ELSIF p_person_rec.edu_status = 'U' THEN --Unexpected error - terminate execution

      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Program_Info';
	   l_debug_str := 'RAISE FND_API.G_EXC_ERROR in Update_EV_Program_Info. p_person_rec.edu_status is U.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RAISE FND_API.G_EXC_ERROR;

   END IF;


FOR l_current IN 1.. l_count LOOP

      Put_Log_Msg('Checking ev programs  '||l_cur_prgm_rec(l_current).person_id,0);
      l_prev_rec.person_id := p_person_rec.person_id;

      p_person_rec.edu_status := 'S';  -- Changed

      l_status := Get_EV_Prgm_Info ( p_data_rec  => l_prev_rec);

      IF l_status = 'U' THEN
       /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
          l_debug_str := 'Unexpected error in Update_Employment_Info. l_status is U.';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF  l_status = 'S' THEN
          IF
	  (
	   l_prev_rec.prgm_action_type
	   ||g_delimeter||l_prev_rec.prgm_start_date
	   ||g_delimeter||l_prev_rec.prgm_end_date
	   ||g_delimeter||l_prev_rec.effective_date
	   ||g_delimeter||l_prev_rec.termination_reason
	   ||g_delimeter||l_prev_rec.end_prgm_reason
	   ||g_delimeter||l_prev_rec.remarks
	   <>
	   l_cur_prgm_rec(l_current).prgm_action_type
	   ||g_delimeter||l_cur_prgm_rec(l_current).prgm_start_date
	   ||g_delimeter||l_cur_prgm_rec(l_current).prgm_end_date
	   ||g_delimeter||l_cur_prgm_rec(l_current).effective_date
	   ||g_delimeter||l_cur_prgm_rec(l_current).termination_reason
	   ||g_delimeter||l_cur_prgm_rec(l_current).end_prgm_reason
	   ||g_delimeter||l_cur_prgm_rec(l_current).remarks
	  ) THEN
		 Put_Log_Msg('Info is changed for  '||l_cur_prgm_rec(l_current).person_id,0);
		 p_person_rec.edu_status := 'C';  -- Changed
		 p_person_rec.changes_found := 'Y';
	     END IF;

      ELSE   --Remove current person from the insert list
        l_cur_prgm_rec(l_current).person_id := NULL;
      END IF;

      IF p_person_rec.edu_status = 'C' AND p_person_rec.person_status <> 'I' THEN
		 /* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Program_Info';
		   l_debug_str := 'inserting prgm info.';
		   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;
	Insert_Edu_Info ('PRGM', p_data_rec  => l_cur_prgm_rec(l_current), p_auth_drp_data_rec => NULL);
      END IF;
   END LOOP;

   Put_Log_Msg(l_api_name||' ends ',0);
    /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Program_Info';
	   l_debug_str := 'Returning S from Update_EV_Program_Info.';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Program_Info';
	   l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Update_EV_Program_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS return U',1);
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_EV_Program_Info';
	   l_debug_str := 'EXCEPTION: Returning U from Update_EV_Program_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;


      RETURN  'U';

END Update_EV_Program_Info;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Update Finance Information block on student

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Update_Finance_Info (
   p_person_rec      IN OUT NOCOPY  t_student_rec    --Person record
) RETURN VARCHAR2
IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Update_Finance_Info';
   l_cur_rec     IGS_SV_FINANCE_INFO%ROWTYPE;
   l_prev_rec    IGS_SV_FINANCE_INFO%ROWTYPE;
   l_status      VARCHAR2(1);


BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Finance_Info';
	   l_debug_str := 'Entering Update_Finance_Info. p_person_rec.person_id is '||p_person_rec.person_id;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   -- Call Validate_Finance_Info
   p_person_rec.fin_status  := Validate_Finance_Info (p_person_rec => p_person_rec,
                                                      p_data_rec   => l_cur_rec);
   IF p_person_rec.fin_status = 'E'  THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('Validation error occurs ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Finance_Info';
	   l_debug_str := 'Returning S from Update_Finance_Info. p_person_rec.fin_status is E';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RETURN 'S';

   ELSIF p_person_rec.fin_status = 'U' THEN --Unexpected error - terminate execution

      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Finance_Info';
	   l_debug_str := 'Raise FND_API.G_EXC_ERROR in Update_Finance_Info. fin_status is U';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RAISE FND_API.G_EXC_ERROR;

   ELSIF p_person_rec.fin_status = 'N' THEN -- Not found

      -- These are I-20 blocks and should be found. If this happens - its a bug

      Put_Log_Msg('Finance block is not found ',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Finance_Info';
	   l_debug_str := 'Raise FND_API.G_EXC_ERROR in Update_Finance_Info. fin_status is N';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;


      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_UNEXP_EXCPT_ERR'); -- I-20 is missing! Unexpected error
      FND_MESSAGE.SET_TOKEN('BLOCK_ID',4);
      FND_MSG_PUB.Add;

      RAISE FND_API.G_EXC_ERROR;

   END IF;


   -- Compare Finance Info
   l_prev_rec.person_id := p_person_rec.person_id;

   l_status := Get_Finance_Info ( p_data_rec  => l_prev_rec);

   IF l_status = 'U' OR l_status = 'N' THEN
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Finance_Info';
	   l_debug_str := 'Raise FND_API.G_EXC_ERROR in Update_Finance_Info. l_status is U or N';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      RAISE FND_API.G_EXC_ERROR;

   END IF;

   IF l_prev_rec.acad_term_length
      ||g_delimeter||l_prev_rec.tuition
      ||g_delimeter||l_prev_rec.living_exp
      ||g_delimeter||l_prev_rec.personal_funds
      ||g_delimeter||l_prev_rec.dependent_exp
      ||g_delimeter||l_prev_rec.other_exp
      ||g_delimeter||l_prev_rec.other_exp_desc
      ||g_delimeter||l_prev_rec.school_funds
      ||g_delimeter||l_prev_rec.school_funds_desc
      ||g_delimeter||l_prev_rec.other_funds
      ||g_delimeter||l_prev_rec.other_funds_desc
      ||g_delimeter||l_prev_rec.empl_funds
      ||g_delimeter||l_prev_rec.program_sponsor
      ||g_delimeter||l_prev_rec.govt_org1
      ||g_delimeter||l_prev_rec.govt_org2
      ||g_delimeter||l_prev_rec.govt_org1_code
      ||g_delimeter||l_prev_rec.govt_org2_code
      ||g_delimeter||l_prev_rec.intl_org1
      ||g_delimeter||l_prev_rec.intl_org2
      ||g_delimeter||l_prev_rec.intl_org1_code
      ||g_delimeter||l_prev_rec.intl_org2_code
      ||g_delimeter||l_prev_rec.ev_govt
      ||g_delimeter||l_prev_rec.bi_natnl_com
      ||g_delimeter||l_prev_rec.other_org
      ||g_delimeter||l_prev_rec.remarks
      ||g_delimeter||l_prev_rec.govt_org1_othr_name
      ||g_delimeter||l_prev_rec.govt_org2_othr_name
      ||g_delimeter||l_prev_rec.intl_org1_othr_name
      ||g_delimeter||l_prev_rec.intl_org2_othr_name
      ||g_delimeter||l_prev_rec.other_govt_name
      <>
      l_cur_rec.acad_term_length
      ||g_delimeter||l_cur_rec.tuition
      ||g_delimeter||l_cur_rec.living_exp
      ||g_delimeter||l_cur_rec.personal_funds
      ||g_delimeter||l_cur_rec.dependent_exp
      ||g_delimeter||l_cur_rec.other_exp
      ||g_delimeter||l_cur_rec.other_exp_desc
      ||g_delimeter||l_cur_rec.school_funds
      ||g_delimeter||l_cur_rec.school_funds_desc
      ||g_delimeter||l_cur_rec.other_funds
      ||g_delimeter||l_cur_rec.other_funds_desc
      ||g_delimeter||l_cur_rec.empl_funds
      ||g_delimeter||l_cur_rec.program_sponsor
      ||g_delimeter||l_cur_rec.govt_org1
      ||g_delimeter||l_cur_rec.govt_org2
      ||g_delimeter||l_cur_rec.govt_org1_code
      ||g_delimeter||l_cur_rec.govt_org2_code
      ||g_delimeter||l_cur_rec.intl_org1
      ||g_delimeter||l_cur_rec.intl_org2
      ||g_delimeter||l_cur_rec.intl_org1_code
      ||g_delimeter||l_cur_rec.intl_org2_code
      ||g_delimeter||l_cur_rec.ev_govt
      ||g_delimeter||l_cur_rec.bi_natnl_com
      ||g_delimeter||l_cur_rec.other_org
      ||g_delimeter||l_cur_rec.remarks
      ||g_delimeter||l_cur_rec.govt_org1_othr_name
      ||g_delimeter||l_cur_rec.govt_org2_othr_name
      ||g_delimeter||l_cur_rec.intl_org1_othr_name
      ||g_delimeter||l_cur_rec.intl_org2_othr_name
      ||g_delimeter||l_cur_rec.other_govt_name
      THEN

      p_person_rec.fin_status := 'C';  -- Changed

      Put_Log_Msg('Finance info is changed  ',0);

      p_person_rec.changes_found := 'Y';

      IF p_person_rec.person_status <> 'I'  THEN
        Insert_Finance_Info ( p_data_rec  => l_cur_rec);
      END IF;

   END IF;
   Put_Log_Msg(l_api_name||' ends ',0);
   /* Debug */
   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
      l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Finance_Info';
      l_debug_str := 'Returning S from Update_Finance_Info.';
      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
      /* Debug */
   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
      l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Finance_Info';
      l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Update_Finance_Info. '||SQLERRM;
      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS return U',1);
      /* Debug */
   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
      l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Finance_Info';
      l_debug_str := 'EXCEPTION: Returning U from Update_Finance_Info. '||SQLERRM;
      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

      RETURN  'U';

END Update_Finance_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Update Dependent block information on the student

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Update_Dependent_Info (
   p_person_rec      IN OUT NOCOPY  t_student_rec    --Person record
) RETURN VARCHAR2
IS

   l_api_name   CONSTANT VARCHAR2(30)   := 'Update_Dependent_Info';
   l_cur_rec    g_dependent_rec_type;
   l_prev_rec   IGS_SV_DEPDNT_INFO%ROWTYPE;
   l_status     VARCHAR2(1);
   l_count      NUMBER(10);
   l_current    NUMBER(10);
   l_rel_type_count NUMBER := 0;

  /* CURSOR c_spouse_of_rel IS
         SELECT COUNT(1)
	 FROM igs_pe_hz_rel_v hz, igs_pe_depd_active pdep
	 WHERE hz.subject_id = p_person_rec.person_id AND
	 hz.relationship_code= 'SPOUSE_OF' and
	 pdep.relationship_id = hz.relationship_id
	 and pdep.action_code <> 'T'
	 and pdep.last_update_date = (SELECT MAX(last_update_date)
				      FROM igs_pe_depd_active
				      WHERE relationship_id =hz.relationship_id)
	 AND sysdate BETWEEN hz.start_date AND NVL(hz.end_date, sysdate+1);

*/
BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
   /* Debug */
   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
      l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
      l_debug_str := 'Entering Update_Dependent_Info. p_person_rec.person_id is '||p_person_rec.person_id;
      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;


   -- Call Validate_Empl_Info

   p_person_rec.dep_status  := Validate_Dependent_Info (p_person_rec => p_person_rec,
                                                         p_data_rec   => l_cur_rec,
                                                         p_records    => l_count);
   IF p_person_rec.dep_status = 'E'  THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('Validation error occurs ',1);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
        l_debug_str := 'Returning S from Update_Dependent_Info. dep_status is E.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      RETURN 'S';

   ELSIF p_person_rec.dep_status = 'U' THEN --Unexpected error - terminate execution

      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
        l_debug_str := 'Raise FND_API.G_EXC_ERROR in Update_Dependent_Info. dep_status is U.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

      RAISE FND_API.G_EXC_ERROR;

   ELSIF p_person_rec.dep_status = 'N' THEN -- Not found

      Put_Log_Msg('Dependent block is not found ',0);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
        l_debug_str := 'Returning S from Update_Dependent_Info. dep_status is N.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      RETURN 'S';

   END IF;
   FOR l_current IN 1.. l_count LOOP

      -- Compare Dependent Info
      Put_Log_Msg('Checking dependent '||l_cur_rec(l_current).depdnt_id,0);

      l_prev_rec.person_id := p_person_rec.person_id;
      l_prev_rec.depdnt_id := l_cur_rec(l_current).depdnt_id;
      p_person_rec.dep_status := 'S';  -- Changed

      l_status := Get_Dependent_Info ( p_data_rec  => l_prev_rec);


--manoj stars


	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Previous_Dependent_Info';
	  l_debug_str := 'l_prev_rec action_type='||l_prev_rec.depdnt_action_type;
          l_debug_str := l_debug_str || 'visa_type=' || l_prev_rec.visa_type;
          l_debug_str := l_debug_str || 'last_name=' || l_prev_rec.last_name;
          l_debug_str := l_debug_str || 'first_name=' || l_prev_rec.first_name ;
          l_debug_str := l_debug_str || 'middle_name=' || l_prev_rec.middle_name;
          l_debug_str := l_debug_str || 'suffix=' || l_prev_rec.suffix;
          l_debug_str := l_debug_str || 'birth_date=' || l_prev_rec.birth_date;
          l_debug_str := l_debug_str || 'gender=' || l_prev_rec.gender;
          l_debug_str := l_debug_str || 'birth_cntry_code=' || l_prev_rec.birth_cntry_code;
          l_debug_str := l_debug_str || 'citizen_cntry_code=' || l_prev_rec.citizen_cntry_code;
          l_debug_str := l_debug_str || 'relationship=' || l_prev_rec.relationship;
          l_debug_str := l_debug_str || 'termination_reason=' || l_prev_rec.termination_reason ;
          l_debug_str := l_debug_str || 'relationship_remarks=' || l_prev_rec.relationship_remarks;
          l_debug_str := l_debug_str || 'perm_res_cntry_code=' || l_prev_rec.perm_res_cntry_code;
          l_debug_str := l_debug_str || 'termination_effect_date=' || l_prev_rec.termination_effect_date;
          l_debug_str := l_debug_str || 'remarks=' || l_prev_rec.remarks;
          l_debug_str := l_debug_str || 'birth_cntry_resn_code=' || l_prev_rec.birth_cntry_resn_code;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;


	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Current_Dependent_Info';
	  l_debug_str := 'cur dep action type: '||l_cur_rec(l_current).depdnt_action_type;
	  l_debug_str := l_debug_str || 'visa_type=' ||  l_cur_rec(l_current).visa_type;
          l_debug_str := l_debug_str || 'last_name=' || l_cur_rec(l_current).last_name;
          l_debug_str := l_debug_str || 'first_name=' || l_cur_rec(l_current).first_name;
          l_debug_str := l_debug_str || 'middle_name=' || l_cur_rec(l_current).middle_name;
          l_debug_str := l_debug_str || 'suffix=' || l_cur_rec(l_current).suffix;
          l_debug_str := l_debug_str || 'birth_date=' || l_cur_rec(l_current).birth_date;
          l_debug_str := l_debug_str || 'gender=' || l_cur_rec(l_current).gender;
          l_debug_str := l_debug_str || 'birth_cntry_code=' || l_cur_rec(l_current).birth_cntry_code;
          l_debug_str := l_debug_str || 'citizen_cntry_code=' || l_cur_rec(l_current).citizen_cntry_code;
          l_debug_str := l_debug_str || 'relationship=' || l_cur_rec(l_current).relationship;
          l_debug_str := l_debug_str || 'termination_reason=' || l_cur_rec(l_current).termination_reason;
          l_debug_str := l_debug_str || 'relationship_remarks=' || l_cur_rec(l_current).relationship_remarks;
          l_debug_str := l_debug_str || 'perm_res_cntry_code=' || l_cur_rec(l_current).perm_res_cntry_code;
          l_debug_str := l_debug_str || 'termination_effect_date=' || l_cur_rec(l_current).termination_effect_date;
          l_debug_str := l_debug_str || 'remarks=' || l_cur_rec(l_current).remarks ;
	  l_debug_str := l_debug_str || 'birth_cntry_resn_code=' || l_cur_rec(l_current).birth_cntry_resn_code;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
--manoj ends

      IF l_status = 'U' THEN
         /* Debug */
	 IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
		l_debug_str := 'Raise FND_API.G_EXC_ERROR in Update_Dependent_Info. l_status is U.';
		fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
         RAISE FND_API.G_EXC_ERROR;

      END IF;

      -- check if dependent sevis id is present

      IF l_status = 'S' AND l_cur_rec(l_current).depdnt_sevis_id IS NULL THEN

         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_STUDENT_ID_ERR'); -- SEVIS STUDENT id not found
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', l_cur_rec(l_current).person_number);
         Put_Log_Msg(FND_MESSAGE.Get,1);

         p_person_rec.person_status := 'I';

         Put_Log_Msg('Validation error occurs ',0);
	 /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
          l_debug_str := 'Returning S from Update_Dependent_Info. l_status is S.';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
         RETURN 'S';

      ELSIF l_status = 'N'  THEN
        -- New dependent status A;
        IF l_cur_rec(l_current).depdnt_action_type = 'A' THEN
          l_cur_rec(l_current).depdnt_action_type := 'A';
          p_person_rec.dep_status := 'C';  -- Changed
          p_person_rec.changes_found := 'Y';

          Put_Log_Msg('Dep info going first time for '||l_cur_rec(l_current).depdnt_id,0);

        END IF;

     ELSIF l_prev_rec.depdnt_action_type IN ('A','R','U') AND
           l_cur_rec(l_current).depdnt_action_type ='T' THEN

        -- Person terminated.
        l_cur_rec(l_current).depdnt_action_type := 'T';
        p_person_rec.dep_status := 'C';  -- Changed
        p_person_rec.changes_found := 'Y';

        Put_Log_Msg('Info is changed for  '||l_cur_rec(l_current).depdnt_id,0);


     ELSIF  l_prev_rec.depdnt_action_type IN ('T') AND
            l_cur_rec(l_current).depdnt_action_type ='A' THEN
          -- Person reactivated
        l_cur_rec(l_current).depdnt_action_type := 'R';
        p_person_rec.dep_status := 'C';  -- Changed
        p_person_rec.changes_found := 'Y';

        Put_Log_Msg('Info is changed for  '||l_cur_rec(l_current).depdnt_id,0);


     ELSIF (l_prev_rec.visa_type		--l_cur_rec(l_current).depdnt_action_type ='A'  AND
          ||g_delimeter||l_prev_rec.last_name
          ||g_delimeter||l_prev_rec.first_name
          ||g_delimeter||l_prev_rec.middle_name
          ||g_delimeter||l_prev_rec.suffix
          ||g_delimeter||l_prev_rec.birth_date
          ||g_delimeter||l_prev_rec.gender
          ||g_delimeter||l_prev_rec.birth_cntry_code
          ||g_delimeter||l_prev_rec.citizen_cntry_code
          ||g_delimeter||l_prev_rec.relationship
          ||g_delimeter||l_prev_rec.termination_reason
          ||g_delimeter||l_prev_rec.relationship_remarks
          ||g_delimeter||l_prev_rec.perm_res_cntry_code
          ||g_delimeter||l_prev_rec.termination_effect_date
          ||g_delimeter||l_prev_rec.remarks
	  ||g_delimeter||l_prev_rec.birth_cntry_resn_code
	 <> l_cur_rec(l_current).visa_type
         ||g_delimeter||l_cur_rec(l_current).last_name
         ||g_delimeter||l_cur_rec(l_current).first_name
         ||g_delimeter||l_cur_rec(l_current).middle_name
         ||g_delimeter||l_cur_rec(l_current).suffix
         ||g_delimeter||l_cur_rec(l_current).birth_date
         ||g_delimeter||l_cur_rec(l_current).gender
         ||g_delimeter||l_cur_rec(l_current).birth_cntry_code
         ||g_delimeter||l_cur_rec(l_current).citizen_cntry_code
         ||g_delimeter||l_cur_rec(l_current).relationship
         ||g_delimeter||l_cur_rec(l_current).termination_reason
         ||g_delimeter||l_cur_rec(l_current).relationship_remarks
         ||g_delimeter||l_cur_rec(l_current).perm_res_cntry_code
         ||g_delimeter||l_cur_rec(l_current).termination_effect_date
         ||g_delimeter||l_cur_rec(l_current).remarks
	 ||g_delimeter||l_cur_rec(l_current).birth_cntry_resn_code
	 ) THEN




         Put_Log_Msg('Info is changed for  '||l_cur_rec(l_current).depdnt_id,0);
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
	  l_debug_str := 'Update_Dependent_Info. l_prev_rec.depdnt_action_type: '||l_prev_rec.depdnt_action_type||'cur dep action type: '||l_cur_rec(l_current).depdnt_action_type;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
           --IF l_prev_rec.depdnt_action_type = l_cur_rec(l_current).depdnt_action_type THEN
	        l_cur_rec(l_current).depdnt_action_type := 'U';  --update mode for the person
	   --END IF;
        p_person_rec.dep_status := 'C';  -- Changed
        p_person_rec.changes_found := 'Y';


      ELSE   --Remove current dependent from the insert list
        l_cur_rec(l_current).depdnt_id := NULL;
      END IF;

     /* IF p_person_rec.dep_status = 'C' AND p_person_rec.record_status ='C' THEN         prbhardw CP enhancement
        -- Only one dependent in the update section.
	/* Debug
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
          l_debug_str := 'Exiting Update_Dependent_Info. dep_status and record_status is C.';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;

       -- EXIT;

      END IF;*/
      IF  p_person_rec.dep_status = 'C' AND p_person_rec.person_status <> 'I'  THEN
	Insert_Dependent_Info ( p_data_rec  => l_cur_rec(l_current));
      END IF;
   END LOOP;
  /*IF  p_person_rec.dep_status = 'C' AND p_person_rec.person_status <> 'I'  THEN
	Insert_Dependent_Info ( p_data_rec  => l_cur_rec(l_current),p_records => l_count );
      END IF; */
   Put_Log_Msg(l_api_name||' ends ',0);
   /* Debug */
   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
       l_debug_str := 'Returning S from Update_Dependent_Info.';
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
      /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
          l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Update_Dependent_Info. '||SQLERRM;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
      Put_Log_Msg(l_api_name||' OTHERS return U',1);
      /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Dependent_Info';
          l_debug_str := 'EXCEPTION: Returning U from Update_Dependent_Info. '||SQLERRM;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;

      RETURN  'U';

END Update_Dependent_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Update Employment information block

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Update_Employment_Info (
   p_person_rec      IN OUT NOCOPY  t_student_rec    -- Person record
) RETURN VARCHAR2
IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Update_Employment_Info';
   l_cur_rec    g_empl_rec_type;  ---IGS_SV_EMPL_INFO%ROWTYPE;  prbhardw
   l_prev_rec   IGS_SV_EMPL_INFO%ROWTYPE;
   l_status     VARCHAR2(1);

   l_count      NUMBER(10);
   l_current    NUMBER(10);

BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
   /* Debug */
  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
     l_debug_str := 'Entering Update_Employment_Info. p_person_rec.person_id is '||p_person_rec.person_id;
     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;

   -- Call Validate_Empl_Info

    p_person_rec.empl_status  := Validate_Empl_Info (p_person_rec => p_person_rec,
                                                    p_data_rec   => l_cur_rec,
                                                    p_records    => l_count);

   IF p_person_rec.empl_status = 'E'  THEN -- Validation error - mark person as invalid
      p_person_rec.person_status := 'I';
      Put_Log_Msg('Validation error occurs ',1);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
        l_debug_str := 'Returning S from Update_Employment_Info. empl_status is E.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      RETURN 'S';
   ELSIF p_person_rec.empl_status = 'U' THEN --Unexpected error - terminate execution
      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
        l_debug_str := 'Unexpected error in Update_Employment_Info. empl_status is U.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF p_person_rec.empl_status = 'N' THEN -- Not found
      Put_Log_Msg('Employment block is not found ',0);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
        l_debug_str := 'Returning S from Update_Employment_Info. empl_status is N.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      RETURN 'S';
   END IF;

FOR l_current IN 1.. l_count LOOP

      Put_Log_Msg('Checking employment  '||l_cur_rec(l_current).person_id,0);
      l_prev_rec.person_id := p_person_rec.person_id;
      l_prev_rec.nonimg_empl_id := l_cur_rec(l_current).nonimg_empl_id;

      p_person_rec.empl_status := 'S';  -- Changed

      l_status := Get_Empl_Info ( p_data_rec  => l_prev_rec);


--manoj starts
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Previous_empl_Info';
          l_debug_str :=		'empl_rec_type='		|| l_prev_rec.empl_rec_type;
          l_debug_str := l_debug_str || 'empl_type='			|| l_prev_rec.empl_type;
          l_debug_str := l_debug_str || 'recommend_empl='	        || l_prev_rec.recommend_empl ;
          l_debug_str := l_debug_str || 'rescind_empl='			|| l_prev_rec.rescind_empl;
          l_debug_str := l_debug_str || 'remarks='			|| l_prev_rec.remarks;
          l_debug_str := l_debug_str || 'empl_start_date='		|| l_prev_rec.empl_start_date;
          l_debug_str := l_debug_str || 'empl_end_date='		|| l_prev_rec.empl_end_date;
          l_debug_str := l_debug_str || 'course_relevance='		|| l_prev_rec.course_relevance;
          l_debug_str := l_debug_str || 'empl_time='			|| l_prev_rec.empl_time;
          l_debug_str := l_debug_str || 'empl_name='			|| l_prev_rec.empl_name;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Current_empl_Info';
          l_debug_str :=		'empl_rec_type='		|| l_cur_rec(l_current).empl_rec_type;
          l_debug_str := l_debug_str || 'empl_type='			|| l_cur_rec(l_current).empl_type;
          l_debug_str := l_debug_str || 'recommend_empl='	        || l_cur_rec(l_current).recommend_empl ;
          l_debug_str := l_debug_str || 'rescind_empl='			|| l_cur_rec(l_current).rescind_empl;
          l_debug_str := l_debug_str || 'remarks='			|| l_cur_rec(l_current).remarks;
          l_debug_str := l_debug_str || 'empl_start_date='		|| l_cur_rec(l_current).empl_start_date;
          l_debug_str := l_debug_str || 'empl_end_date='		|| l_cur_rec(l_current).empl_end_date;
          l_debug_str := l_debug_str || 'course_relevance='		|| l_cur_rec(l_current).course_relevance;
          l_debug_str := l_debug_str || 'empl_time='			|| l_cur_rec(l_current).empl_time;
          l_debug_str := l_debug_str || 'empl_name='			|| l_cur_rec(l_current).empl_name;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;


--manoj ends

	/* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
          l_debug_str := 'l_status from Get_Empl_Info: '||l_status;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
      IF l_status = 'U' THEN
       /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
          l_debug_str := 'Unexpected error in Update_Employment_Info. l_status is U.';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_status = 'N'  THEN
        -- New employment record status A;
          l_cur_rec(l_current).action_code := 'A';
          p_person_rec.empl_status := 'C';  -- Changed
          p_person_rec.changes_found := 'Y';
          Put_Log_Msg('Info is changed for  '||l_cur_rec(l_current).person_id,0);

      ELSIF  l_status = 'S' THEN

	    IF l_cur_rec(l_current).action_code IN ('Y') THEN
	        l_cur_rec(l_current).action_code := 'C';  --CANCEL
	    END IF;

        IF (l_cur_rec(l_current).action_code = 'C' AND  l_prev_rec.action_code <> 'C') OR
		    (l_cur_rec(l_current).action_code <> 'C' AND  l_prev_rec.action_code = 'C' ) THEN
		          p_person_rec.empl_status := 'C';  -- Changed
                  p_person_rec.changes_found := 'Y';
	    ELSE
				IF (l_cur_rec(l_current).empl_rec_type = 'F'  AND
				(
				   l_prev_rec.empl_rec_type
				 ||g_delimeter||l_prev_rec.empl_type
				 ||g_delimeter||l_prev_rec.recommend_empl
				 ||g_delimeter||l_prev_rec.rescind_empl
				 ||g_delimeter||l_prev_rec.remarks
				 ||g_delimeter||l_prev_rec.empl_start_date
				 ||g_delimeter||l_prev_rec.empl_end_date
				 ||g_delimeter||l_prev_rec.course_relevance
				 ||g_delimeter||l_prev_rec.empl_time
				 ||g_delimeter||l_prev_rec.empl_name
				 <>
				   l_cur_rec(l_current).empl_rec_type
				 ||g_delimeter||l_cur_rec(l_current).empl_type
				 ||g_delimeter||l_cur_rec(l_current).recommend_empl
				 ||g_delimeter||l_cur_rec(l_current).rescind_empl
				 ||g_delimeter||l_cur_rec(l_current).remarks
				 ||g_delimeter||l_cur_rec(l_current).empl_start_date
				 ||g_delimeter||l_cur_rec(l_current).empl_end_date
				 ||g_delimeter||l_cur_rec(l_current).course_relevance
				 ||g_delimeter||l_cur_rec(l_current).empl_time
				 ||g_delimeter||l_cur_rec(l_current).empl_name
				 )) THEN
							 Put_Log_Msg('Info is changed for  '||l_cur_rec(l_current).person_id,0);
							  l_cur_rec(l_current).action_code := 'E';
							  p_person_rec.empl_status := 'C';  -- Changed
							  p_person_rec.changes_found := 'Y';
					 END IF;
           END IF;
      ELSE   --Remove current person from the insert list
        l_cur_rec(l_current).person_id := NULL;
      END IF;

      IF p_person_rec.empl_status = 'C' AND p_person_rec.person_status <> 'I' THEN
	Insert_Empl_Info ( p_data_rec  => l_cur_rec(l_current));
      END IF;
   END LOOP;

   Put_Log_Msg('Employment info is changed  ',0);

   Put_Log_Msg(l_api_name||' ends ',0);
   /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
          l_debug_str := 'Returning S from Update_Employment_Info.';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
      /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
          l_debug_str := 'ND_API.G_EXC_ERROR: Returning U from Update_Employment_Info. '||SQLERRM;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS return U',1);
      /* Debug */
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Employment_Info';
          l_debug_str := 'EXCEPTION: Returning U from Update_Employment_Info. '||SQLERRM;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;

      RETURN  'U';
END Update_Employment_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Update Conviction block information.

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
FUNCTION Update_Conviction_Info (
   p_person_rec      IN OUT NOCOPY  t_student_rec    --Person record
) RETURN VARCHAR2

IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Update_Conviction_Info';
   l_cur_rec    IGS_SV_CONVICTIONS%ROWTYPE;
   l_status     VARCHAR2(1);
   l_prev_rec   IGS_SV_CONVICTIONS%ROWTYPE;

BEGIN

   Put_Log_Msg(l_api_name||' begins ',0);
   /* Debug */
  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Conviction_Info';
     l_debug_str := 'Entering Update_Conviction_Info. p_person_rec.person_id is '||p_person_rec.person_id;
     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;


   -- Call Validate_Convictions_Info

   p_person_rec.conv_status  := Validate_Convictions_Info (p_person_rec => p_person_rec,
                                                            p_data_rec   => l_cur_rec);

   IF p_person_rec.conv_status = 'E'  THEN -- Validation error - mark person as invalid

      p_person_rec.person_status := 'I';

      Put_Log_Msg('Validation error occurs ',1);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Conviction_Info';
        l_debug_str := 'Returning S from Update_Conviction_Info. conv_status is E.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

      RETURN 'S';

   ELSIF p_person_rec.conv_status = 'U' THEN --Unexpected error - terminate execution

      Put_Log_Msg('Unexpected error returned by validation ',1);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Conviction_Info';
        l_debug_str := 'Unexpected error in Update_Conviction_Info. conv_status is U.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

      RAISE FND_API.G_EXC_ERROR;

   ELSIF p_person_rec.conv_status = 'N' THEN -- Not found

      Put_Log_Msg('Convictions block is not found ',0);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Conviction_Info';
        l_debug_str := 'Returning S from Update_Conviction_Info. conv_status is N.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

      RETURN 'S';

   END IF;

   -- If something is returned by the procedure - Insert it right away.

   Put_Log_Msg('Convictions info is changed  ',0);

   p_person_rec.changes_found := 'Y';

   IF p_person_rec.person_status <> 'I'  THEN

     Insert_Convictions_Info ( p_data_rec  => l_cur_rec);

   END IF;

   Put_Log_Msg(l_api_name||' ends ',0);
   /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Conviction_Info';
        l_debug_str := 'Returning S from Update_Conviction_Info.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

   RETURN 'S';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Put_Log_Msg(l_api_name||' EXEC_ERROR returns U',1);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Conviction_Info';
        l_debug_str := 'FND_API.G_EXC_ERROR: Returning U from Update_Conviction_Info. '||SQLERRM;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      RETURN 'U';

   WHEN OTHERS THEN

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Put_Log_Msg(l_api_name||' OTHERS return U',1);
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Update_Conviction_Info';
        l_debug_str := 'EXCEPTION: Returning U from Update_Conviction_Info. '||SQLERRM;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

      RETURN  'U';

END Update_Conviction_Info;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : This procedure cleans up tables for a person
                        if part of the information is not valid.

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Remove_Person_Data (
   p_person_id IN NUMBER,
   p_batch_id  IN NUMBER
) IS

BEGIN
    /* Debug */
    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Remove_Person_Data';
       l_debug_str := 'Entering Remove_Person_Data. p_person_id is '||p_person_id||' and p_batch_id is '||p_batch_id;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;
   -- Delete from all related tables

   DELETE FROM igs_sv_addresses WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL );

   DELETE FROM igs_sv_bio_info WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL ) ;

   DELETE FROM igs_sv_convictions WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL ) ;

   DELETE FROM igs_sv_depdnt_info WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL ) ;

   DELETE FROM igs_sv_empl_info WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL ) ;

   DELETE FROM igs_sv_finance_info WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL ) ;

   DELETE FROM igs_sv_legal_info WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL ) ;

   DELETE FROM igs_sv_oth_info WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL ) ;

   DELETE FROM igs_sv_prgms_info WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL ) ;

   DELETE FROM igs_sv_persons WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL );

   DELETE FROM igs_sv_btch_summary WHERE batch_id = p_batch_id AND ( person_id = p_person_id OR p_person_id IS NULL );  -- prbhardw

    /* Debug */
    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Remove_Person_Data';
       l_debug_str := 'Exiting Remove_Person_Data.';
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

END Remove_Person_Data;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : This is the main Concurrent program that is
                        called when submitting a request for the
                        Exchange Visitors.

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
mmkumar              12-Sep-2005      Added one more parameter for p_org_id
******************************************************************/
PROCEDURE EV_Batch_Process(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_validate_only    IN  VARCHAR2,  -- Validate only flag  'Y'  'N'
   p_org_id           IN VARCHAR2,
   p_dso_id           IN VARCHAR2
)
IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'EV_Batch_Process';

   l_dso_id VARCHAR2(20) := substr(p_dso_id,1,instr(p_dso_id,'-',-1)-1) ;
   l_dso_party_id NUMBER := to_number(substr(p_dso_id,instr(p_dso_id,'-',-1)+1));

   l_org_id VARCHAR2(20) := substr(p_org_id,1,instr(p_org_id,'-',-1)-1) ;
   l_org_party_id NUMBER := to_number(substr(p_org_id,instr(p_org_id,'-',-1)+1));

BEGIN
   -- Just call the procedure
   /* Debug */
   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
      l_label := 'igs.plsql.igs_sv_batch_process_pkg.EV_Batch_Process';
      l_debug_str := 'Entering EV_Batch_Process. p_validate_only is '||p_validate_only;
      l_debug_str := l_debug_str || 'l_org_id=' || l_org_id;
      l_debug_str := l_debug_str || 'l_dso_id=' || l_dso_id;
      l_debug_str := l_debug_str || 'l_dso_party_id=' || l_dso_party_id;
      l_debug_str := l_debug_str || 'l_org_party_id=' || l_org_party_id;
      l_debug_str := l_debug_str || 'p_org_id=' || p_org_id;
      l_debug_str := l_debug_str || 'p_dso_id=' || p_dso_id;
      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;
   SAVEPOINT EV_Batch_Process;

   Create_Batch(
     errbuf           => errbuf ,
     retcode          => retcode,
     p_batch_type     => 'E',
     p_validate_only  => p_validate_only,
     p_org_id         => l_org_id,
     p_dso_id	      => l_dso_id,
     p_dso_party_id   =>  l_dso_party_id,
     p_org_party_id   =>  l_org_party_id
   );
EXCEPTION

   WHEN OTHERS THEN
     /* Debug */
   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
      l_label := 'igs.plsql.igs_sv_batch_process_pkg.EV_Batch_Process';
      l_debug_str := 'Exception in EV_Batch_Process. '||SQLERRM;
      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

     ROLLBACK TO EV_Batch_Process;

      retcode := 2;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Generate_Message;

END EV_Batch_Process;


FUNCTION Get_pre_noshow_status(p_person_id igs_sv_persons.person_id%TYPE, p_batch_id igs_sv_persons.person_id%TYPE)
RETURN VARCHAR2
IS
l_no_show_status  VARCHAR2(1);
CURSOR no_show_change(c_person_id igs_sv_persons.person_id%TYPE, c_batch_id igs_sv_persons.person_id%TYPE)
IS
SELECT old_per.no_show_flag
FROM igs_sv_persons new_per, igs_sv_persons old_per
WHERE new_per.person_id = c_person_id AND
      new_per.batch_id = c_batch_id AND
      old_per.batch_id = (SELECT max(batch_id) FROM igs_sv_persons WHERE batch_id < c_batch_id) AND
      old_per.person_id = new_per.person_id;
BEGIN

  OPEN no_show_change(p_person_id,p_batch_id);
  FETCH no_show_change INTO l_no_show_status;
  CLOSE no_show_change;

  RETURN NVL(l_no_show_status,'N');

END Get_pre_noshow_status;


FUNCTION new_batch(
     p_batch_id igs_sv_batches.batch_id%TYPE,
     p_dso_id           VARCHAR2,
     p_org_id	        VARCHAR2,
     p_batch_type       VARCHAR2,
     p_org_party_id     NUMBER,
     p_user_party_id     NUMBER
     )
RETURN NUMBER
IS
   l_batch_id   igs_sv_batches.batch_id%TYPE;
BEGIN
--   DELETE FROM igs_sv_batches WHERE batch_id = p_batch_id;

     INSERT INTO igs_sv_batches
     ( batch_id,
       schema_version,
       sevis_user_id,
       sevis_school_id,
       batch_status,
       batch_type,
       creation_date ,
       created_by ,
       last_updated_by ,
       last_update_date ,
       last_update_login,
       SEVIS_SCHOOL_ORG_ID   ,
       SEVIS_USER_PERSON_ID
     )
     VALUES
     ( igs_sv_batches_id_s.nextval,
       1,
       p_dso_id,
       p_org_id,
       'S',
       p_batch_type,
       sysdate,
       g_update_by,
       g_update_by,
       sysdate,
       g_update_login,
       p_org_party_id,
       p_user_party_id
     )
     RETURNING batch_id INTO l_batch_id;

     RETURN l_batch_id;
END new_batch;

/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : This is the main procedure to be called when
                        the request has been submitted for either the
                        Exchange Visitors or Non Immigrant students.
                        This procedure is called from the concurrent
                        requests.

   remarks            :

   Change History
   Who                  When            What
   pkpatel              22-APR-2003     Bug No 2908378
                                        Modified the action type to ('TR','ED') for EV records
                                        Added the code for inserting Site of Activity Address
------------------------------------------------------------------------
mmkumar              12-Sep-2005     SEVIS 5 uptake, Added new parameter for Org ID
******************************************************************/
PROCEDURE Create_Batch(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_batch_type       IN  VARCHAR2,  -- Batch type E(ev),  I(international),   B (both)
   p_validate_only    IN  VARCHAR2,  -- Validate only flag  'Y'  'N'
   p_org_id           IN  VARCHAR2,
   p_dso_id	      IN  VARCHAR2,
   p_dso_party_id     IN  NUMBER,
   p_org_party_id     IN  NUMBER
) IS

   l_api_name  CONSTANT VARCHAR2(25) := 'Create_Batch';
   TYPE student_list_cur IS REF CURSOR;
   c_student_list   student_list_cur;
   c_student_list_rec  c_stdnt_list;
-- select all persons from I-20 where form status is not Terminated or Completed and reported to SEVIS already



   l_batch_id         igs_sv_batches.batch_id%TYPE;
   l_person_sevis_id  IGS_SV_PERSONS.SEVIS_USER_ID%TYPE;
   l_issue_rec        IGS_SV_PERSONS%ROWTYPE;
   l_bio_rec          IGS_SV_BIO_INFO%ROWTYPE;
   l_oth_rec          IGS_SV_OTH_INFO%ROWTYPE;
   l_edu_rec          IGS_SV_PRGMS_INFO%ROWTYPE;
   l_fin_rec          IGS_SV_FINANCE_INFO %ROWTYPE;
   l_dep_rec          g_dependent_rec_type;
   l_f_addr_rec       g_address_rec_type;
   l_us_addr_rec      g_address_rec_type;
   l_site_addr_rec    g_address_rec_type;
   l_exist            NUMBER(25);
   l_submiter_id      NUMBER(25);
   l_submiter_number  hz_parties.party_number%TYPE;
   no_show_status     VARCHAR2(1);
   l_cur_authdrp_rec  IGS_SV_PRGMS_INFO%ROWTYPE;
   l_btch_id	      igs_sv_batches.batch_id%TYPE;

   CURSOR C_EV_CUR IS
   SELECT fr.person_id, min(ev_form_id) form_id, pr.party_number person_number, fr.no_show_flag, fr.reprint_reason reprint_reason
    FROM igs_pe_ev_form fr, hz_parties pr
    WHERE pr.party_id = fr.person_id  AND fr.form_effective_date <= trunc(sysdate)
    AND fr.ev_form_id NOT IN
       (SELECT st.ev_form_id  FROM igs_pe_ev_form_stat st
        WHERE st.action_type IN ('TR','ED')
              AND st.ev_form_id = fr.ev_form_id
               AND st.ev_form_stat_id IN
                   ( SELECT NVL(prs.form_status_id,0) FROM igs_sv_prgms_info prs, igs_sv_persons pr
                     WHERE prs.person_id = pr.person_id AND prs.batch_id = pr.batch_id
                           AND pr.record_status <> 'E' AND prs.person_id = fr.person_id)
       ) AND fr.sevis_school_identifier = p_org_party_id AND
          ( (p_dso_id IS NULL AND
	     (EXISTS (SELECT rel.object_id
		      FROM hz_relationships rel
		      WHERE rel.object_id =  fr.person_id AND
	                    --rel.DIRECTIONAL_FLAG = 'F' AND	fix for bug 5258405
		            sysdate between rel.start_date AND nvl(end_date, sysdate) AND
		            rel.RELATIONSHIP_CODE = 'DSO_FOR') ))
	   OR
	    fr.person_id IN (SELECT rel.object_id FROM hz_relationships rel
	                          WHERE rel.subject_id = p_dso_party_id
				  --AND rel.DIRECTIONAL_FLAG = 'F'	fix for bug 5258405
				  AND sysdate between rel.start_date AND nvl(end_date, sysdate)
	    AND rel.RELATIONSHIP_CODE = 'DSO_FOR')
	   )
  GROUP BY  pr.party_number,fr.person_id,  fr.no_show_flag, fr.reprint_reason;

  CURSOR C_NI_CUR IS
   SELECT fr.person_id, min(nonimg_form_id) form_id, pr.party_number person_number, null no_show_flag, fr.reprint_reason reprint_reason
   FROM igs_pe_nonimg_form fr, hz_parties pr
   WHERE pr.party_id = fr.person_id
   AND fr.form_effective_date <= trunc(sysdate)
   AND fr.nonimg_form_id NOT IN
        ( SELECT st.nonimg_form_id FROM IGS_PE_NONIMG_STAT st
         WHERE st.action_type IN ('T','C')
         AND st.nonimg_form_id = fr.nonimg_form_id
         AND st.nonimg_stat_id IN
              ( SELECT NVL(prs.form_status_id,0)
                FROM igs_sv_prgms_info prs, igs_sv_persons pr
                WHERE prs.person_id = pr.person_id AND prs.batch_id = pr.batch_id
                AND pr.record_status <> 'E' AND prs.person_id = fr.person_id
                ) )
   AND fr.sevis_school_identifier = p_org_party_id AND
   ( (p_dso_id IS NULL AND
      (EXISTS (SELECT rel.object_id
	      FROM hz_relationships rel
	      WHERE rel.object_id =  fr.person_id AND
	            --rel.DIRECTIONAL_FLAG = 'F' AND		fix for bug 5258405
		    sysdate between rel.start_date AND nvl(end_date, sysdate) AND
		    rel.RELATIONSHIP_CODE = 'DSO_FOR') ))
     OR
     fr.person_id IN (SELECT rel.object_id
	                    FROM hz_relationships rel
	                    WHERE rel.subject_id = p_dso_party_id and
	                    --rel.DIRECTIONAL_FLAG = 'F' AND		fix for bug 5258405
	                    sysdate between rel.start_date AND nvl(end_date, sysdate) AND
	                    rel.RELATIONSHIP_CODE = 'DSO_FOR')
 )
 GROUP BY  pr.party_number,fr.person_id, fr.reprint_reason;


   CURSOR c_submiter_id IS
     SELECT person_party_id
       FROM fnd_user
      WHERE user_id = g_update_by;

   CURSOR submiter_number_cur(cp_party_id hz_parties.party_id%TYPE) IS
   SELECT party_number
   FROM   hz_parties
   WHERE  party_id = cp_party_id;

   CURSOR c_prev_info( p_id NUMBER, f_id NUMBER) IS
     SELECT 1
      FROM igs_sv_persons a,
           igs_sv_batches b
     WHERE person_id = p_id
           AND a.batch_id = b.batch_id
           AND b.batch_type = p_batch_type
           AND a.record_status <> 'E'
           AND form_id = f_id;

   CURSOR c_active_batch IS
     SELECT batch_id
      FROM igs_sv_batches
     WHERE batch_status IN ('N')       -- prbhardw
           AND batch_type = p_batch_type;

   CURSOR c_print_form (p_form_id NUMBER) IS
     SELECT decode(print_form,'Y','1','0') print_form
       FROM igs_pe_nonimg_form
      WHERE nonimg_form_id = p_form_id
            AND p_batch_type = 'I'
      UNION
     SELECT decode(print_form,'Y','1','0') print_form
       FROM igs_pe_ev_form
      WHERE ev_form_id = p_form_id
            AND p_batch_type = 'E';


     ---prbhardw
     CURSOR c_prgm_print_flag (p_form_id NUMBER) IS
     SELECT decode(print_flag,'Y','1','0') print_form
       FROM igs_pe_nonimg_stat
      WHERE nonimg_form_id = p_form_id
            AND p_batch_type = 'I'
	    AND action_type = 'E';


     CURSOR c_get_dso_id(c_person_id igs_pe_ev_form.person_id%TYPE)
     IS
          SELECT alt.api_person_id, alt.pe_person_id
	  FROM hz_relationships rel, igs_pe_alt_pers_id alt
	  WHERE rel.subject_id = c_person_id and
	       rel.object_id = alt.pe_person_id AND
               sysdate between alt.start_dt and nvl(alt.end_dt,sysdate+1) AND
	       sysdate between rel.start_date AND nvl(end_date, sysdate) AND
	       rel.RELATIONSHIP_CODE = 'HAS_DSO' AND
	       alt.person_id_type
			       IN (SELECT person_id_type
				     FROM igs_pe_person_id_typ
				    WHERE s_person_id_type = 'SEVIS_ID');




   l_batch_status VARCHAR(1) := 'N';  -- batch status  (S)uccess, (E)rror,'N'o new students
   l_record_number igs_sv_persons.record_number%TYPE;
   l_student_rec   t_student_rec;
   l_status        VARCHAR2(1);
   l_count         NUMBER(10);
   l_soa_count	   NUMBER(5);   -- prbhardw CP enhancement

   l_sevis_user_person_id NUMBER;

   dso_id VARCHAR2(20) := p_dso_id;
   dso_party_id VARCHAR2(20) := p_dso_party_id;
   -- prbhardw

BEGIN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
	   l_debug_str := 'Entering Create_Batch. p_batch_type is '||p_batch_type;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

   FND_MSG_PUB.initialize;

   SAVEPOINT Create_Batch;
   IF fnd_profile.value('IGS_SV_ENABLED') <> 'Y' THEN
	/* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
	   l_debug_str := 'Raise ERROR: Sevis Disabled';
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_DISABLED'); -- SEVIS disabled
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;


   IF fnd_profile.value('IGS_SV_DEBUG') <> 'Y' THEN

      g_debug_level := 1;

   END IF;

   g_update_login            := FND_GLOBAL.LOGIN_ID;
   g_update_by               := FND_GLOBAL.USER_ID;

   OPEN c_submiter_id;
   FETCH c_submiter_id
    INTO l_submiter_id;
   CLOSE c_submiter_id;


   l_record_number := 1;
   IF p_dso_id IS NULL THEN

	   l_person_sevis_id  := get_person_sevis_id(l_submiter_id);
	   IF l_person_sevis_id IS NULL THEN

	      OPEN submiter_number_cur(l_submiter_id);
	      FETCH submiter_number_cur INTO l_submiter_number;
	      CLOSE submiter_number_cur;

	      /* Debug */
	      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		 l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
		 l_debug_str := 'Raise FND_API.G_EXC_ERROR: l_person_sevis_id is null';
		 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	      END IF;

	      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_SUBMITTER_ID_ERR'); -- SEVIS submitter id not found
	      FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', l_submiter_number);
	      FND_MSG_PUB.Add;
	      RAISE FND_API.G_EXC_ERROR;

	   END IF;
	   l_sevis_user_person_id := l_submiter_id;
   ELSE
	l_person_sevis_id := p_dso_id;
	l_sevis_user_person_id := p_dso_party_id;

   END IF;
   -- Check for active batch
   OPEN c_active_batch;
   FETCH c_active_batch INTO l_batch_id;
   CLOSE c_active_batch;

   IF l_batch_id IS NOT NULL AND p_validate_only = 'N' THEN
      /*Debug*/
      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	 l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
	 l_debug_str := 'Raise ERROR: message name IGS_SV_BATCH_FOUND';
	 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

     -- Active batch is found and mode not validate only - terminate current process
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_BATCH_FOUND');
      FND_MESSAGE.SET_TOKEN('BATCH_ID', l_batch_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;
   -- Create batch record
   Put_Log_Msg('Inserting batch record',0);

   INSERT INTO igs_sv_batches
     ( batch_id,
       schema_version,
       sevis_user_id,
       sevis_school_id,
       batch_status,
       batch_type,
       creation_date ,
       created_by ,
       last_updated_by ,
       last_update_date ,
       last_update_login,
       SEVIS_SCHOOL_ORG_ID,
       SEVIS_USER_PERSON_ID
     )
     VALUES
     ( igs_sv_batches_id_s.nextval,
       1,
       l_person_sevis_id,
       p_org_id,
       'S',
       p_batch_type,
       sysdate,
       g_update_by,
       g_update_by,
       sysdate,
       g_update_login,
       p_org_party_id,
       l_sevis_user_person_id
     )
     RETURNING batch_id INTO l_batch_id;
     g_running_create_batch := l_batch_id;        -- prbhardw CP enhancement
     g_running_update_batch  := l_batch_id;       -- prbhardw CP enhancement
     g_running_batches(1) := l_batch_id;
   -- Loop for each student
     IF p_batch_type ='I' THEN
         OPEN C_NI_CUR;
         FETCH C_NI_CUR INTO c_student_list_rec;
     ELSE
        OPEN C_EV_CUR;
        FETCH C_EV_CUR INTO c_student_list_rec;
     END IF;

   --FOR c_student_list_rec IN c_student_list LOOP
   LOOP			-- prbhardw
        IF p_batch_type ='I' THEN
	      EXIT WHEN C_NI_CUR%NOTFOUND;
	ELSE
	   EXIT WHEN C_EV_CUR%NOTFOUND;
	END IF;
     /*FETCH c_student_list INTO
          c_student_list_rec.person_id,
	  c_student_list_rec.form_id,
	  c_student_list_rec.person_number,
	  c_student_list_rec.no_show_flag,
	  c_student_list_rec.reprint_reason;

	  EXIT WHEN c_student_list%NOTFOUND;*/

	  -- check for total students
	  IF (MOD(g_create_count,250) = 0 AND g_create_count > 0 ) OR (MOD(g_update_count,250) = 0 AND g_update_count > 0 ) THEN
	       l_batch_id :=  new_batch(l_batch_id, l_person_sevis_id, p_org_id, p_batch_type,p_org_party_id,l_sevis_user_person_id);
	       IF MOD(g_create_count,250) = 0 THEN	-- prbhardw CP enhancement
		    g_running_create_batch := l_batch_id;
		    g_running_batches(g_running_batches.COUNT + 1) := g_running_create_batch;
	       ELSE
		    g_running_update_batch := l_batch_id;
		    g_running_batches(g_running_batches.COUNT + 1) := g_running_update_batch;
	       END IF;

	       Put_Log_Msg('count exceeded max limmit. new batch created: '||l_batch_id||' g_create_count '||g_create_count||' g_update_count '||g_update_count,0);

          END IF;



      Put_Log_Msg('Initializing student record',0);
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
	   l_debug_str := 'Setting person values in Create_Batch Person ID '||c_student_list_rec.person_id||' Person No: '||c_student_list_rec.person_number;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      --  Initialize record group for the student
      l_student_rec.person_id     := c_student_list_rec.person_id;
      l_student_rec.record_number := l_record_number;
      l_student_rec.record_status := 'N'; -- so far new
      l_student_rec.person_number := c_student_list_rec.person_number;
      l_student_rec.form_id       := c_student_list_rec.form_id;
      l_student_rec.sevis_user_id := get_person_sevis_id(l_student_rec.person_id);
      l_student_rec.person_status := 'V';
      l_student_rec.batch_type    := p_batch_type;
      l_student_rec.batch_id      := l_batch_id;
      l_student_rec.changes_found := 'N';
      l_student_rec.dep_flag      := 'N';
      l_student_rec.no_show_flag := c_student_list_rec.no_show_flag;
      l_student_rec.reprint_reason := c_student_list_rec.reprint_reason; --prbhardw

      -- Check if the student has been submitted to sevis

      OPEN c_prev_info ( l_student_rec.person_id , c_student_list_rec.form_id);
      FETCH c_prev_info
       INTO l_exist;

      -- Assign mode to the record

      Put_Log_Msg('',1);
      Put_Log_Msg('*******************Next person '||l_student_rec.person_number||'**************************',1);

      IF c_prev_info%FOUND THEN
         l_student_rec.record_status := 'C';  --change mode
         -- If mode update - check SEVIS person Id

         FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_STUDENT_UPD'); -- Student is found in Update mode
         FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', l_student_rec.person_number);
         Put_Log_Msg(FND_MESSAGE.Get,1);

         IF l_student_rec.sevis_user_id IS NULL THEN

            FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_STUDENT_ID_ERR'); -- SEVIS STUDENT id not found
            FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', l_student_rec.person_number);
            Put_Log_Msg(FND_MESSAGE.Get,1);
            Put_Log_Msg('Sevis id not found',0);

            l_student_rec.person_status := 'I';

         END IF;

      ELSE

        FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_STUDENT_CRT'); -- Student is found in Create mode
        FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', l_student_rec.person_number);
        Put_Log_Msg(FND_MESSAGE.Get,1);

      END IF;

      CLOSE c_prev_info;

      Put_Log_Msg('Person status is: '||l_student_rec.person_status,0);

      IF l_student_rec.person_status = 'V' THEN

        OPEN c_print_form(l_student_rec.form_id);
        FETCH c_print_form INTO l_student_rec.print_form;
        CLOSE c_print_form;

         -- Create main student record
	 IF p_dso_id IS NULL THEN
	       OPEN c_get_dso_id(l_student_rec.person_id);
	       FETCH c_get_dso_id INTO dso_id, dso_party_id;
	       CLOSE c_get_dso_id;
	 END IF;
	 /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
	   l_debug_str := 'Inserting in igs_sv_persons batch id: '||l_batch_id;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
         INSERT INTO igs_sv_persons (
             batch_id     ,
             person_id    ,
             record_number,
             form_id      ,
             print_form   ,
	     pdso_sevis_id,
             record_status,
             person_number,
             sevis_user_id,
             creation_date,
             created_by             ,
             last_updated_by        ,
             last_update_date       ,
             last_update_login,
	     no_show_flag,
	     reprint_rsn_code,
	     PDSO_SEVIS_PERSON_ID
            ) VALUES (
             l_batch_id,
             l_student_rec.person_id,
             l_student_rec.record_number,
             l_student_rec.form_id,
             l_student_rec.print_form,
	     dso_id,
             l_student_rec.record_status,
             l_student_rec.person_number,
             l_student_rec.sevis_user_id,
             sysdate,
             g_update_by,
             g_update_by,
             sysdate,
             g_update_login,
	     l_student_rec.no_show_flag,
	     l_student_rec.reprint_reason,
             dso_party_id
            );
      END IF;

           g_nonimg_form_id := l_student_rec.form_id;

     IF l_student_rec.record_status = 'N' THEN
      g_person_status := 'NEW';
             -- If mode new

         -- Call Validate_Issue_Info  and Insert_Issue_Info

         -- 'S' - record found and validated 'E' - validation error 'U' - Unexpected error  'N' - data not found


         l_student_rec.issue_status := Validate_Issue_Info (p_person_rec => l_student_rec,
                                                            p_data_rec  => l_issue_rec);
         -- Call Validate_Bio_Info  and Insert_Bio_Info
         l_student_rec.bio_status  := Validate_Bio_Info (p_person_rec => l_student_rec,
                                                         p_data_rec  => l_bio_rec);
         -- Call Validate_US_address_Info Insert_Address_Info
         l_student_rec.us_addr_status  := Validate_Us_Addr_Info (p_person_rec => l_student_rec,
                                                                 p_data_rec   => l_us_addr_rec,
                                                                 p_records    => l_count);
         -- Call Validate_Finance_Info Insert_Finance_Info
         l_student_rec.fin_status  := Validate_Finance_Info (p_person_rec => l_student_rec,
                                                             p_data_rec  => l_fin_rec);

         -- Call Validate_EDU_Info Insert_EDU_Info

          l_student_rec.edu_status  := Validate_Edu_Info (p_person_rec => l_student_rec,
                                                           p_data_rec   => l_edu_rec);
          IF p_batch_type = 'I' THEN

           -- 2908378 added, since site of activity is only specific to EV
           l_student_rec.site_addr_status := 'S'; -- For EV only

           -- Call Validate_Other_Info Insert_Other_Info

           l_student_rec.other_status  := Validate_Other_Info (p_person_rec => l_student_rec,
                                                               p_data_rec  => l_oth_rec);
           -- Call Validate_F_Addr_Info  Insert_Address_Info
           l_student_rec.f_addr_status  := Validate_F_Addr_Info (p_person_rec => l_student_rec,
                                                                p_data_rec   => l_f_addr_rec,
                                                                p_records    => l_count);
	  ELSE

            l_student_rec.f_addr_status := 'S'; --for Non-Img only
            l_student_rec.other_status := 'S'; --for Non-Img only

           -- 2908378 passed l_site_addr_rec for capturing the Site of Activity Address
           l_student_rec.site_addr_status  := Validate_Site_Info (p_person_rec => l_student_rec,
                                                                 p_data_rec   => l_site_addr_rec,
                                                                 p_records    => l_count);
           l_soa_count := l_count;
           IF l_student_rec.site_addr_status      = 'U'  THEN --Unexpected error - terminate execution
	      /* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
		  l_debug_str := 'Returning U from Create_Batch. site_addr_status is U.';
		  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

              RAISE FND_API.G_EXC_ERROR;

           END IF;

          END IF;

         -- Call Validate_Dependent_Info Insert_Dependent_Info

         l_student_rec.dep_status  := Validate_Dependent_Info (p_person_rec => l_student_rec,
                                                               p_data_rec   => l_dep_rec,
                                                               p_records    => l_count );

         l_student_rec.dep_count   := l_count;
         -- check all statuses
         -- 2908378 added validation with l_student_rec.site_addr_status
         IF l_student_rec.issue_status = 'E'
            OR l_student_rec.bio_status = 'E'
            OR l_student_rec.other_status = 'E'
            OR l_student_rec.f_addr_status  = 'E'
            OR l_student_rec.us_addr_status = 'E'
            OR l_student_rec.site_addr_status = 'E'
            OR l_student_rec.edu_status  = 'E'
            OR l_student_rec.fin_status  = 'E'
            OR l_student_rec.dep_status = 'E' THEN -- Validation error - mark person as invalid

            l_student_rec.person_status := 'I';

         END IF;
         IF l_student_rec.issue_status      = 'U'
            OR l_student_rec.bio_status     = 'U'
            OR l_student_rec.other_status   = 'U'
            OR l_student_rec.f_addr_status  = 'U'
            OR l_student_rec.us_addr_status = 'U'
            OR l_student_rec.site_addr_status = 'U'
            OR l_student_rec.edu_status     = 'U'
            OR l_student_rec.fin_status     = 'U'
            OR l_student_rec.dep_status     = 'U'  THEN --Unexpected error - terminate execution

            RAISE FND_API.G_EXC_ERROR;

         ELSIF l_student_rec.issue_status = 'N'
            OR l_student_rec.bio_status   = 'N'
            OR l_student_rec.edu_status   = 'N'
            OR l_student_rec.fin_status   = 'N' THEN -- Not found

            -- These are I-20 blocks and should be found. If this happens - its a bug

            FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_UNEXP_EXCPT_ERR'); -- I-20 is missing! Unexpected error
            FND_MESSAGE.SET_TOKEN('BLOCK_ID',5);
            FND_MSG_PUB.Add;
               /* Debug */
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
		  l_debug_str := 'IGS_SV_UNEXP_EXCPT_ERR in Create_Batch.';
		  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

            RAISE FND_API.G_EXC_ERROR;

         END IF;

         -- Check for required blocks

         IF l_student_rec.f_addr_status = 'N' AND p_batch_type = 'I' THEN

            FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_NO_F_ADDR_FLD_ERR'); -- Foreign address not found
            FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', l_student_rec.person_number);
            Put_Log_Msg(FND_MESSAGE.Get,1);

            l_student_rec.person_status := 'I';

         END IF;
         IF l_student_rec.us_addr_status = 'N' AND p_batch_type = 'E' THEN

            FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_NO_US_ADDR_FLD_ERR'); -- US address not found
            FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', l_student_rec.person_number);
            Put_Log_Msg(FND_MESSAGE.Get,1);

            l_student_rec.person_status := 'I';

         END IF;
         IF l_student_rec.person_status = 'V' THEN
           l_record_number := l_record_number +1;
	   g_create_count := g_create_count +1; -- prbhardw CP enhancement

	   l_student_rec.record_number := g_create_count;  -- prbhardw CP enhancement

           Put_Log_Msg(' Inserting data ',0);

           l_student_rec.changes_found := 'Y' ;

            -- Insertion of everything.

            Update_Issue_Info ( p_data_rec  => l_issue_rec);

            Insert_Bio_Info ( p_data_rec  => l_bio_rec);

            IF l_student_rec.other_status = 'S' and p_batch_type ='I' THEN

               Insert_Other_Info ( p_data_rec  => l_oth_rec);

            END IF;

            Insert_Edu_Info ('EDU', p_data_rec  => l_edu_rec, p_auth_drp_data_rec => l_cur_authdrp_rec);

            IF p_batch_type ='I' THEN

              Insert_Address_Info ('F', p_data_rec  => l_f_addr_rec,p_records => 1);   --- prbhardw CP enhancement

            END IF;

            IF l_student_rec.us_addr_status = 'S' THEN

               Insert_Address_Info ( 'US',p_data_rec  => l_us_addr_rec,p_records => 1);   --- prbhardw CP enhancement

            END IF;
            -- 2908378 added to insert site of activity
            IF  l_student_rec.site_addr_status = 'S' AND p_batch_type ='E' THEN
               Insert_Address_Info ('SOA', p_data_rec  => l_site_addr_rec,p_records => l_soa_count);   --- prbhardw CP enhancement
            END IF;

            Insert_Finance_Info ( p_data_rec  => l_fin_rec);

            IF l_student_rec.dep_status = 'S' THEN

              Insert_Dependent_Info ( p_data_rec  => l_dep_rec,p_records   => l_student_rec.dep_count  );

            END IF;

         ELSE

           Put_Log_Msg(' No insertion, person_status is:'||l_student_rec.person_status ,0);

         END IF;  -- Insertion ends here
     ELSIF l_student_rec.person_status = 'V' THEN -- prbhardw Added on 22/03/06
          g_person_status := 'EDIT';
          l_record_number := l_record_number +1;
	  g_update_count := g_update_count +1; -- prbhardw CP enhancement
	  l_student_rec.record_number := g_update_count; -- prbhardw CP enhancement
	  Put_Log_Msg(' update_count:'||g_update_count,0);
          IF p_batch_type = 'I' THEN -- If mode update for Non immigrants

               -- IF l_student_rec.changes_found <> 'Y' THEN   --- commented by prbhardw

		     -- Call Update_Employment_Info
                    l_status := Update_Employment_Info ( p_person_rec  => l_student_rec  );

		    IF l_status <> 'S' THEN
				/* Debug */
			 IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
				l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
				l_debug_str := 'ERROR in Create_Batch. l_status from Update_Employment_Info is not S';
				fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			 END IF;
			 RAISE FND_API.G_EXC_ERROR;
		    END IF;

             --  END IF;

	   -- Call Update_Registration_Info
	       l_status := Update_Registration_Info ( p_person_rec  => l_student_rec  );
               IF l_status <> 'S' THEN
	      /* Debug */
		    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		         l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
		         l_debug_str := 'ERROR in Create_Batch. l_status is not S';
		         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		    END IF;

                    RAISE FND_API.G_EXC_ERROR;
               END IF;
              -- IF l_student_rec.changes_found <> 'Y' THEN    --- commented by prbhardw

                      -- Call Update_Personal_Info
                    l_status := Update_Personal_Info ( p_person_rec  => l_student_rec  );

                    IF l_status <> 'S' THEN
				/* Debug */
		         IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		               l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
		               l_debug_str := 'ERROR in Create_Batch. changes_found <> Y and l_status is not S';
		               fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		         END IF;
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
             --  END IF;
              -- IF l_student_rec.changes_found <> 'Y' THEN   --- commented by prbhardw

			-- Call Update_Program_Info
                    l_status := Update_Program_Info ( p_person_rec  => l_student_rec  );

                    IF l_status <> 'S' THEN
				/* Debug */
		         IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		               l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
		               l_debug_str := 'ERROR in Create_Batch. l_status from Update_Program_Info is not S';
		               fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		         END IF;

                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
            --   END IF;

             --  IF l_student_rec.changes_found <> 'Y' THEN   --- commented by prbhardw

			-- Call Update_Finance_Info
                    l_status := Update_Finance_Info ( p_person_rec  => l_student_rec  );

                    IF l_status <> 'S' THEN
				/* Debug */
		         IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
				l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
				l_debug_str := 'ERROR in Create_Batch. l_status from Update_Finance_Info is not S';
				fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		         END IF;
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
              -- END IF;

             --  IF l_student_rec.changes_found <> 'Y' THEN   --- commented by prbhardw

			-- Call Update_Dependent_Info
                    l_status := Update_Dependent_Info ( p_person_rec  => l_student_rec  );

		    IF l_status <> 'S' THEN
				/* Debug */
			 IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
				l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
				l_debug_str := 'ERROR in Create_Batch. l_status from Update_Dependent_Info is not S';
				fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			 END IF;
			 RAISE FND_API.G_EXC_ERROR;
		    END IF;

	      -- END IF;

             --  IF l_student_rec.changes_found <> 'Y' THEN   --- commented by prbhardw

			-- Call Update_Conviction_Info
                    l_status := Update_Conviction_Info ( p_person_rec  => l_student_rec  );

		    IF l_status <> 'S' THEN
				/* Debug */
			 IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
				l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
				l_debug_str := 'ERROR in Create_Batch. l_status from Update_Conviction_Info is not S';
				fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			 END IF;
			 RAISE FND_API.G_EXC_ERROR;
                    END IF;

             --  END IF;

          ELSE  -- Update for EV student
         -------
	  IF l_student_rec.no_show_flag =  'Y' THEN
               IF Get_pre_noshow_status(l_student_rec.person_id,l_student_rec.batch_id) = 'Y' THEN
                    l_student_rec.changes_found := 'N';
               ELSE
	            l_student_rec.changes_found := 'Y';
		   l_btch_id := chk_mut_exclusive(l_student_rec.batch_id,
				       l_student_rec.person_id,
				       'NOSHOW',
				       'SV_STATUS');
		    Insert_Summary_Info(l_btch_id,
				       l_student_rec.person_id,
				       'NOSHOW',
				       'SV_STATUS',
				       'SEND',
				       'IGS_SV_PERSONS',
				       '');
	       END IF;
	  ELSE



	   --IF no_show_status <> l_student_rec.no_show_flag AND l_student_rec.no_show_flag <> 'Y' THEN

		   l_status := Update_Personal_Info ( p_person_rec  => l_student_rec  );

		   IF l_status <> 'S' THEN
			/* Debug */
			IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
			  l_debug_str := 'ERROR in Create_Batch. l_status from Update_Personal_Info is not S';
			  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			END IF;

		      RAISE FND_API.G_EXC_ERROR;
		   END IF;
		    l_status := Update_ev_legal_Info ( p_person_rec  => l_student_rec  );
                   IF l_status <> 'S' THEN
	               /* Debug */
		       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		            l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
		            l_debug_str := 'ERROR in Create_Batch. Update_ev_legal_Info status is not S';
		            fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		       END IF;

                       RAISE FND_API.G_EXC_ERROR;
                   END IF;

		 --  IF l_student_rec.changes_found <> 'Y' THEN   --- commented by prbhardw
		     -- Call Update_Finance_Info
		     l_status := Update_Finance_Info ( p_person_rec  => l_student_rec  );


		     IF l_status <> 'S' THEN
		       /* Debug */
			IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
			  l_debug_str := 'ERROR in Create_Batch. l_status from Update_Finance_Info is not S';
			  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			END IF;
		       RAISE FND_API.G_EXC_ERROR;
		     END IF;
		 --  END IF;

		 --  IF l_student_rec.changes_found <> 'Y' THEN   --- commented by prbhardw

		     -- Call Update_EV_Program_Info
		     l_status := Update_EV_Program_Info ( p_person_rec  => l_student_rec  );


		     IF l_status <> 'S' THEN
		       /* Debug */
			IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
			  l_debug_str := 'ERROR in Create_Batch. l_status from Update_EV_Program_Info is not S';
			  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			END IF;
		       RAISE FND_API.G_EXC_ERROR;
		     END IF;
		 --  END IF;

		 --  IF l_student_rec.changes_found <> 'Y' THEN   --- commented by prbhardw

		     -- Call Update_EV_Address_Info
		     l_status := Update_EV_Address_Info ( p_person_rec  => l_student_rec  );


		     IF l_status <> 'S' THEN
		       /* Debug */
			IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
			  l_debug_str := 'ERROR in Create_Batch. l_status from Update_EV_Address_Info is not S';
			  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			END IF;
		       RAISE FND_API.G_EXC_ERROR;
		     END IF;

		   --END IF;
		 --  IF l_student_rec.changes_found <> 'Y' THEN   --- commented by prbhardw

		     -- Call Update_Dependent_Info
		     l_status := Update_Dependent_Info ( p_person_rec  => l_student_rec  );


		     IF l_status <> 'S' THEN
		       /* Debug */
			IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
			  l_debug_str := 'ERROR in Create_Batch. l_status from Update_Dependent_Info is not S';
			  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			END IF;
		       RAISE FND_API.G_EXC_ERROR;
		     END IF;

		 --  END IF;
		    --PRBHARDW
		    IF Get_pre_noshow_status(l_student_rec.person_id,l_student_rec.batch_id) = 'Y' THEN
			    l_student_rec.changes_found := 'Y';
		    END IF;
		    IF l_student_rec.reprint_reason = '06' THEN
			l_student_rec.changes_found := 'Y';
		    END IF;
		    --PRBHARDW

		 END IF;

	      END IF;
	  END IF;
      IF l_student_rec.person_status = 'I' THEN

         --Remove all person data from tables

        Remove_Person_Data(p_person_id => l_student_rec.person_id, p_batch_id => l_batch_id);

        FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_STUDENT_INVALID'); -- Student has validation error - not processed
        Put_Log_Msg(FND_MESSAGE.Get,1);

      ELSIF l_student_rec.changes_found = 'Y' THEN

        IF  p_validate_only ='N' THEN

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_STUDENT_SUCCESS'); -- Student successfully processed
          Put_Log_Msg(FND_MESSAGE.Get,1);

        ELSE

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_STDNT_VALID_SUCC'); -- Student successfully processed
          Put_Log_Msg(FND_MESSAGE.Get,1);

        END IF;

        l_batch_status :='S';

      ELSIF l_student_rec.changes_found = 'N' THEN

         --Remove all person data from tables
        Remove_Person_Data(p_person_id => l_student_rec.person_id, p_batch_id => l_batch_id);

        FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_STUDENT_NO_CHANGE'); -- No changes found for the student
        Put_Log_Msg(FND_MESSAGE.Get,1);

      END IF;
        IF p_batch_type ='I' THEN
	      FETCH C_NI_CUR INTO c_student_list_rec;
	ELSE
	   FETCH C_EV_CUR INTO c_student_list_rec;
	END IF;
   END LOOP;

        IF p_batch_type ='I' THEN
	      CLOSE C_NI_CUR;
	ELSE
	   CLOSE C_EV_CUR ;
	END IF;



   IF l_batch_status = 'N' THEN
     -- no students for the batch - change

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_NO_STUDENTS'); -- No students found to submit
      Put_Log_Msg(FND_MESSAGE.Get,1);

      DELETE FROM igs_sv_batches WHERE batch_id = l_batch_id;

   END IF;

   /*
   IF l_record_number >=250 THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_MAX_RECORDS'); -- Too many students.
      Put_Log_Msg(FND_MESSAGE.Get,1);

   END IF;
   */



   -- Check batch validate and invalid flag

   -- Rollback since batch shouldn't be saved

   --Raise an event for WF and commit
   IF l_batch_status = 'S' AND p_validate_only ='N' THEN

    -- Submit_Event ( p_batch_type, l_batch_id);
       null;
   ELSE

      FOR i IN 1..g_parallel_batches.COUNT LOOP
	  Remove_Person_Data (p_person_id => NULL, p_batch_id => g_parallel_batches(i) );
          DELETE FROM igs_sv_batches WHERE batch_id = g_parallel_batches(i);
          Put_Log_Msg(' Removing parallel batch: ' || g_parallel_batches(i),0);
      END LOOP;

      FOR i IN 1..g_running_batches.COUNT LOOP
	   Remove_Person_Data (p_person_id => NULL, p_batch_id => g_running_batches(i) );
           DELETE FROM igs_sv_batches WHERE batch_id = g_running_batches(i);
           Put_Log_Msg(' Removing running batch: ' || g_running_batches(i),0);
      END LOOP;

   END IF;
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
  l_debug_str := 'Commiting in Create_Batch. l_batch_status: '||l_batch_status;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;
   compose_log_file;

   COMMIT;

   retcode := 0;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
	  l_debug_str := 'FND_API.G_EXC_ERROR exception in Create_Batch. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      ROLLBACK TO Create_Batch;
      retcode := 2;
      dump_current_person(l_student_rec);
        IF C_NI_CUR%ISOPEN THEN
	      CLOSE C_NI_CUR;
	ELSIF C_EV_CUR%ISOPEN THEN
	   CLOSE C_EV_CUR ;
	END IF;
      Generate_Message;

   WHEN OTHERS THEN

      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sv_batch_process_pkg.Create_Batch';
	  l_debug_str := 'Other exception in Create_Batch. '||SQLERRM;
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      ROLLBACK TO Create_Batch;
      retcode := 2;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      dump_current_person(l_student_rec);
        IF C_NI_CUR%ISOPEN THEN
	      CLOSE C_NI_CUR;
	ELSIF C_EV_CUR%ISOPEN THEN
	   CLOSE C_EV_CUR ;
	END IF;
      Generate_Message;

END Create_Batch;




/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : This is the main concurrent program called when
                        submitting request for the non immigrant students

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE NIMG_Batch_Process(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_validate_only    IN  VARCHAR2,  -- Validate only flag  'Y'  'N'
   p_org_id           IN  VARCHAR2,
   p_dso_id           IN  VARCHAR2
) IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'NIMG_Batch_Process';

   l_dso_id VARCHAR2(20) := substr(p_dso_id,1,instr(p_dso_id,'-',-1)-1) ;
   l_dso_party_id NUMBER := to_number(substr(p_dso_id,instr(p_dso_id,'-',-1)+1));

   l_org_id VARCHAR2(20) := substr(p_org_id,1,instr(p_org_id,'-',-1)-1) ;
   l_org_party_id NUMBER := to_number(substr(p_org_id,instr(p_org_id,'-',-1)+1));


BEGIN
   /* Debug */
  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sv_batch_process_pkg.NIMG_Batch_Process';
     l_debug_str := 'Entering NIMG_Batch_Process.';
      l_debug_str := l_debug_str || 'l_org_id=' || l_org_id;
      l_debug_str := l_debug_str || 'l_dso_id=' || l_dso_id;
      l_debug_str := l_debug_str || 'l_dso_party_id=' || l_dso_party_id;
      l_debug_str := l_debug_str || 'l_org_party_id=' || l_org_party_id;
      l_debug_str := l_debug_str || 'p_org_id=' || p_org_id;
      l_debug_str := l_debug_str || 'p_dso_id=' || p_dso_id;

     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;

   -- Just call the procedure
   SAVEPOINT NIMG_Batch_Process;

   Create_Batch(
     errbuf           => errbuf ,
     retcode          => retcode,
     p_batch_type     => 'I',
     p_validate_only  => p_validate_only ,
     p_org_id         => l_org_id,
     p_dso_id         => l_dso_id,
     p_dso_party_id   => l_dso_party_id,
     p_org_party_id   => l_org_party_id
     ) ;

EXCEPTION

   WHEN OTHERS THEN

      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sv_batch_process_pkg.NIMG_Batch_Process';
       l_debug_str := 'Exception in NIMG_Batch_Process. '||SQLERRM;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

      ROLLBACK TO NIMG_Batch_Process;

      retcode := 2;
      errbuf := SQLERRM;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Generate_Message;

END NIMG_Batch_Process;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : This is the main procedure to be called when
                        the request has to be purged for
                        Exchange Visitors or Non Immigrant students.
                        This procedure is called from the concurrent
                        requests.

   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Purge_Batch(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_batch_type       IN  VARCHAR2   -- Batch type E(ev),  I(international)
) IS

   l_api_name  CONSTANT VARCHAR2(25) := 'Purge_Batch';
   l_batch_id         igs_sv_batches.batch_id%TYPE;

   CURSOR c_active_batch IS
     SELECT batch_id
      FROM igs_sv_batches
     WHERE batch_status IN ('S','N')
           AND batch_type = p_batch_type;

BEGIN

   /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sv_batch_process_pkg.Purge_Batch';
       l_debug_str := 'Entering Purge_Batch. p_batch_type is '||p_batch_type;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
   FND_MSG_PUB.initialize;

   SAVEPOINT Purge_Batch;

   -- Check for active batch

   OPEN c_active_batch;
   FETCH c_active_batch INTO l_batch_id;
   CLOSE c_active_batch;

   IF l_batch_id IS NULL THEN
     -- Active batch is not found and mode not validate only - terminate current process
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_NO_BATCH_FOUND');
      Put_Log_Msg(FND_MESSAGE.Get,1);

   ELSE

     --Remove batch
     /*Remove_Person_Data (p_person_id => NULL, p_batch_id => l_batch_id );

     DELETE FROM igs_sv_batches WHERE batch_id = l_batch_id;
     DELETE FROM igs_sv_batches WHERE batch_id > l_batch_id;*/

      FOR i IN 1..g_parallel_batches.COUNT LOOP
	  Remove_Person_Data (p_person_id => NULL, p_batch_id => g_parallel_batches(i) );
          DELETE FROM igs_sv_batches WHERE batch_id = g_parallel_batches(i);
          Put_Log_Msg(' In purge batch-Removing parallel batch: ' || g_parallel_batches(i),0);
      END LOOP;

      FOR i IN 1..g_running_batches.COUNT LOOP
	   Remove_Person_Data (p_person_id => NULL, p_batch_id => g_running_batches(i) );
           DELETE FROM igs_sv_batches WHERE batch_id = g_running_batches(i);
           Put_Log_Msg(' In purge batch-Removing running batch: ' || g_running_batches(i),0);
      END LOOP;

   END IF;

   retcode := 0;
   /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sv_batch_process_pkg.NIMG_Batch_Process';
       l_debug_str := 'retcode in NIMG_Batch_Process: '||retcode;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sv_batch_process_pkg.NIMG_Batch_Process';
       l_debug_str := 'FND_API.G_EXC_ERROR Exception in NIMG_Batch_Process. '||SQLERRM;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      ROLLBACK TO Purge_Batch;

      retcode := 2;

      Generate_Message;

   WHEN OTHERS THEN

      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sv_batch_process_pkg.NIMG_Batch_Process';
       l_debug_str := 'Exception in NIMG_Batch_Process. '||SQLERRM;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      ROLLBACK TO Purge_Batch;

      retcode := 2;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Generate_Message;

END Purge_Batch;




/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : This is the main procedure to be called when
                        there is a need to purge EV data.

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE EV_Purge_Batch (
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER    -- Request standard return status
) IS
   l_api_name       CONSTANT VARCHAR2(30)   := 'EV_Purge_Batch';
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

BEGIN
   /* Debug */
  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sv_batch_process_pkg.EV_Purge_Batch';
     l_debug_str := 'Entering EV_Purge_Batch.';
     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;
   -- Just call the procedure

   Purge_Batch(
     errbuf           => errbuf ,
     retcode          => retcode,
     p_batch_type     => 'E') ;

EXCEPTION

   WHEN OTHERS THEN
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.EV_Purge_Batch';
        l_debug_str := 'EXCEPTION in EV_Purge_Batch. '||SQLERRM;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      retcode := 2;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Generate_Message;

END EV_Purge_Batch;




/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : This is the main procedure to be called when
                        there is a need to purge Non immigrant data.

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE NIMG_Purge_Batch (
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER    -- Request standard return status
) IS
   l_api_name       CONSTANT VARCHAR2(30)   := 'NIMG_Purge_Batch';
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

BEGIN

   /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.NIMG_Purge_Batch';
        l_debug_str := 'Entering NIMG_Purge_Batch.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
   -- Just call the procedure

   SAVEPOINT NIMG_Purge_Batch;

   Purge_Batch(
     errbuf           => errbuf ,
     retcode          => retcode,
     p_batch_type     => 'I') ;

EXCEPTION

   WHEN OTHERS THEN
       /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.NIMG_Purge_Batch';
        l_debug_str := 'EXCEPTION in NIMG_Purge_Batch. '||SQLERRM;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      ROLLBACK TO NIMG_Purge_Batch;

      retcode := 2;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Generate_Message;

END NIMG_Purge_Batch;


/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Used to generate messages that are to be output
                        into the concurrent request log.

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Generate_Message
IS

   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

BEGIN
   /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Generate_Message';
        l_debug_str := 'Entering Generate_Message.';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
   FND_MSg_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

   IF (l_msg_count > 0) THEN

      l_msg_data := '';

      FOR l_cur IN 1..l_msg_count LOOP

         l_msg_data := FND_MSg_PUB.GET(l_cur, FND_API.g_FALSE);
         Put_Log_Msg(l_msg_data,1);
      END LOOP;

   ELSE

         l_msg_data  := 'Error Returned but Error stack has no data';
         Put_Log_Msg(l_msg_data,1);

   END IF;
    /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.Generate_Message';
        l_debug_str := 'Exiting Generate_Message. l_msg_data is: '||l_msg_data;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
END Generate_Message;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Place the messages that have been generated into
                        the appropriate log file for viewing.

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Put_Log_Msg (
   p_message IN VARCHAR2,
   p_level         IN NUMBER
) IS

   l_api_name             CONSTANT VARCHAR2(30)   := 'Put_Log_Msg';

BEGIN

    -- This procedure outputs messages into the log file  Level 0 - System messages. 1 - user messages
    IF p_level >= g_debug_level THEN

      fnd_file.put_line (FND_FILE.LOG,p_message);

    END IF;

END Put_Log_Msg;


PROCEDURE process_person_record (
  p_BatchID        IN NUMBER,
  p_sevisID        IN VARCHAR2,
  p_person_id      IN NUMBER,
  p_Status         IN VARCHAR2,
  p_SEVIS_ErrorCode    IN VARCHAR2,
  p_SEVIS_ErrorElement IN VARCHAR2
)
IS
  l_rowid  VARCHAR2(255);
  l_alt_id igs_pe_person_id_typ.person_id_type%TYPE;


  CURSOR c_alt IS
   SELECT person_id_type
     FROM igs_pe_person_id_typ
    WHERE s_person_id_type = g_person_sevis_id AND
          closed_ind = 'N';


BEGIN
    /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.process_person_record';
        l_debug_str := 'Entering process_person_record. p_sevisID is: '||p_sevisID||' and p_person_id is: '||p_person_id;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

 IF lower(p_Status) <> 'true' THEN

    UPDATE igs_sv_persons
       SET record_status = 'E',
           sevis_error_code = p_SEVIS_ErrorCode,
           sevis_error_element = p_SEVIS_ErrorElement
     WHERE batch_id = p_BatchID
           AND person_id = p_person_id;

  -- purge the person data completely.

--    Remove_Person_Data (p_person_id => p_person_id, p_batch_id => p_BatchID );

  ELSIF  NVL(Get_Person_Sevis_Id (p_person_id),'X') <> p_sevisID THEN

   -- Update sevis id
   -- end date current one (if any)

   UPDATE igs_pe_alt_pers_id
      SET end_dt = trunc(sysdate)
    WHERE pe_person_id = p_person_id
          AND person_id_type
              IN (SELECT person_id_type
                    FROM igs_pe_person_id_typ
                   WHERE s_person_id_type = g_person_sevis_id)
           AND start_dt <= trunc(sysdate)
           AND NVL(end_dt,sysdate+1) >= trunc(sysdate) ;

      OPEN c_alt;
      FETCH c_alt INTO l_alt_id;
      CLOSE c_alt;

     -- Insert new
     IGS_PE_ALT_PERS_ID_PKG.INSERT_ROW (
         X_ROWID         => l_rowid,
         X_PE_PERSON_ID  => p_person_id,
         X_API_PERSON_ID => p_sevisID,
         X_API_PERSON_ID_UF => p_sevisID,
         X_PERSON_ID_TYPE => l_alt_id,
         X_START_DT       => trunc(sysdate),
         X_END_DT         => NULL,
         X_attribute_category => '',
         X_attribute1          => '',
         X_attribute2          => '',
         X_attribute3          => '',
         X_attribute4          => '',
         X_attribute5          => '',
         X_attribute6          => '',
         X_attribute7          => '',
         X_attribute8          => '',
         X_attribute9          => '',
         X_attribute10         => '',
         X_attribute11         => '',
         X_attribute12         => '',
         X_attribute13         => '',
         X_attribute14         => '',
         X_attribute15         => '',
         X_attribute16         => '',
         X_attribute17         => '',
         X_attribute18         => '',
         X_attribute19         => '',
         X_attribute20         => '',
         X_MODE                => 'I'
      );


  END IF;
   /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.process_person_record';
        l_debug_str := 'Exiting process_person_record';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

END process_person_record;

PROCEDURE process_trans_header (
  p_BatchID        IN NUMBER,
  p_FileErrorCode  IN VARCHAR2,
  p_FileValidation IN VARCHAR2)
IS
/*----------------------------------------------------------
p_FileErrorCode => The resultCode attribute is set to success if all submitted records process successfully.
                                Otherwise, the resultCode indicates either indicates that:

				1) file has not yet been processed or

				2) the file has been processed with at least one record failing business rules validation
				(although all other records are successfully loaded into SEVIS)

p_FileValidation => The status attribute is set to true if there are no errors associated with this batch submittal.

----------------------------------------------------------*/
   l_api_name       CONSTANT VARCHAR2(30)   := 'process_trans_header';

  CURSOR c_batch IS
    SELECT batch_status
      FROM igs_sv_batches
     WHERE batch_id = p_BatchID;

  l_status igs_sv_batches.batch_status%TYPE;


BEGIN

     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.process_trans_header';
        l_debug_str := 'Came in with p_BatchID = '||p_BatchID||'  p_FileErrorCode = '||p_FileErrorCode ||' p_FileValidation = '||p_FileValidation||' '||SQLERRM;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

  SAVEPOINT process_trans_header;

  -- S0001 - successfull download.
  -- p_FileValidation - true

  OPEN c_batch;
  FETCH c_batch INTO l_status;

  IF c_batch%NOTFOUND THEN

     CLOSE c_batch;
     FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_BATCH_NOT_FOUND'); -- Batch not found
     FND_MESSAGE.SET_TOKEN('BATCH_ID',p_BatchID);
     FND_MSG_PUB.Add;

     RAISE FND_API.G_EXC_ERROR;

  END IF;

  CLOSE c_batch;

  IF lower(p_FileValidation) = 'true' OR p_FileValidation='1' THEN
    -- successfull batch transmition.

    IF l_status <>'S' THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_INVALID_STATUS'); -- Batch is not in process
       FND_MESSAGE.SET_TOKEN('BATCH_ID',p_BatchID);
       FND_MSG_PUB.Add;

       RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- Update batch  and set success status
    UPDATE igs_sv_batches SET batch_status = 'P' WHERE batch_id = p_BatchID;

  ELSE
    -- purge the batch completely.

    Remove_Person_Data (p_person_id => NULL, p_batch_id => p_BatchID );

    UPDATE igs_sv_batches SET batch_status = 'E', SEVIS_ERROR_CODE = NVL(p_FileErrorCode,NVL(p_FileValidation,'X')) WHERE batch_id = p_BatchID;

  END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      /* Debug */
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.process_trans_header';
        l_debug_str := 'FND_API.G_EXC_ERROR in process_trans_header '||SQLERRM;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
      ROLLBACK TO process_trans_header;
   WHEN OTHERS THEN
       /* Debug */
       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sv_batch_process_pkg.process_trans_header';
          l_debug_str := 'Exiting process_trans_header '||SQLERRM;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
       END IF;
      ROLLBACK TO process_trans_header;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
END process_trans_header;

PROCEDURE process_trans_errors (
  p_BatchID        IN NUMBER,
  p_ErrorCode      IN VARCHAR2,
  p_ErrorMessage   IN VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
  NULL;
END process_trans_errors;


PROCEDURE process_student_record (
  p_BatchID        IN NUMBER,
  p_sevisID        IN VARCHAR2,
  p_PersonID   IN VARCHAR2,
  p_Status         IN VARCHAR2,
  p_SEVIS_ErrorCode    IN VARCHAR2,
  p_SEVIS_ErrorElement IN VARCHAR2)


IS
/*----------------------------------------------------------
p_SEVIS_ErrorCode => SEVIS defined error code

p_SEVIS_ErrorElement => Error message

p_PersonID => User defined field B for principal record

p_Status => The status attribute is set to true if this record is successfully loaded into SEVIS.  If the attempt failed, then the list of errors appear below this element

----------------------------------------------------------*/
  l_api_name   CONSTANT VARCHAR2(30)   := 'process_student_record';
  l_person_id  NUMBER(15);


BEGIN

     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.process_student_record';
        l_debug_str := 'Came in with p_BatchID = '||p_BatchID||'  p_sevisID = '||p_sevisID
		||'  p_PersonID = '||p_PersonID|| ' p_Status = '||p_Status
		||'  p_SEVIS_ErrorCode = '||p_SEVIS_ErrorCode||'  p_SEVIS_ErrorElement = '||p_SEVIS_ErrorElement||' '||SQLERRM;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;


    SAVEPOINT process_student_record;


  l_person_id := to_number(p_PersonID);

  process_person_record (
    p_BatchID        => p_BatchID,
    p_sevisID        => p_sevisID,
    p_person_id      => l_person_id,
    p_Status         => p_Status,
    p_SEVIS_ErrorCode    => p_SEVIS_ErrorCode,
    p_SEVIS_ErrorElement => p_SEVIS_ErrorElement
  );

update igs_sv_persons set SEVIS_USER_ID = p_sevisID ,
        SEVIS_ERROR_CODE = p_SEVIS_ErrorCode, SEVIS_ERROR_ELEMENT  = p_SEVIS_ErrorElement
        where person_id = p_PersonID;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO process_student_record;

      RAISE FND_API.G_EXC_ERROR;

   WHEN OTHERS THEN

      ROLLBACK TO process_student_record;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      RAISE FND_API.G_EXC_ERROR;


END process_student_record;

PROCEDURE process_dep_record (
  p_BatchID        IN NUMBER,
  p_DepPersonID        IN NUMBER,
  p_DepSevisID        IN VARCHAR2,
  p_PersonID   IN VARCHAR2,
  p_Status         IN VARCHAR2,
  p_SEVIS_ErrorCode    IN VARCHAR2,
  p_SEVIS_ErrorElement IN VARCHAR2

  )
IS
/*----------------------------------------------------------
p_SEVIS_ErrorCode => SEVIS defined error code

p_SEVIS_ErrorElement => Error message

p_DepPersonID => User defined field B for principal record

p_Status => The status attribute is set to true if this record is successfully loaded into SEVIS.  If the attempt failed, then the list of errors appear below this element

----------------------------------------------------------*/

  l_api_name   CONSTANT VARCHAR2(30)   := 'process_dep_record';
  l_person_id  NUMBER(15);
  l_temp VARCHAR2(1);

CURSOR c_dep IS
    SELECT  '1'
      FROM IGS_SV_DEPDNT_INFO
     WHERE PERSON_ID = p_PersonID and DEPDNT_ID  = p_DepPersonID;


BEGIN
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sv_batch_process_pkg.process_dep_record';
        l_debug_str := 'Came in with p_BatchID = '||p_BatchID||'  p_DepPersonID = '||p_DepPersonID
		||'  p_DepSevisID = '||p_DepSevisID||'  p_PersonID = '||p_PersonID
		|| ' p_Status = '||p_Status||'  p_SEVIS_ErrorCode = '
		||p_SEVIS_ErrorCode||'  p_SEVIS_ErrorElement = '||p_SEVIS_ErrorElement||' '||SQLERRM;
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

  OPEN c_dep;
  FETCH c_dep INTO l_temp;

  IF c_dep%NOTFOUND THEN

     CLOSE c_dep;

     FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_DEP_NOT_FOUND'); -- Dependent not found
     FND_MESSAGE.SET_TOKEN('PERSON_ID',p_PersonID);
     FND_MSG_PUB.Add;

     RAISE FND_API.G_EXC_ERROR;

  END IF;

  CLOSE c_dep;

  l_person_id := to_number(p_DepPersonID);
  process_person_record (
    p_BatchID        => p_BatchID,
    p_sevisID        => p_DepSevisID,
    p_person_id      => l_person_id,
    p_Status         => p_Status,
    p_SEVIS_ErrorCode    => p_SEVIS_ErrorCode,
    p_SEVIS_ErrorElement => p_SEVIS_ErrorElement
  );

    UPDATE IGS_SV_DEPDNT_INFO SET DEPDNT_SEVIS_ID = p_DepSevisID WHERE PERSON_ID = p_PersonID and DEPDNT_ID  = p_DepPersonID;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO process_dep_record;
   WHEN OTHERS THEN
      ROLLBACK TO process_dep_record;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
END process_dep_record;

/******************************************************************
   Created By         : prbhardw

   Date Created By    : Dec 30, 2005

   Purpose            : Insert batch summary into igs_sv_btch_summary before inserting in interface tables.

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Insert_Summary_Info(
   p_batch_id  IN  igs_sv_btch_summary.batch_id%TYPE,
   p_person_id  IN  igs_sv_btch_summary.person_id%TYPE,
   p_action_code  IN  igs_sv_btch_summary.action_code%TYPE,
   p_tag_code  IN  igs_sv_btch_summary.tag_code%TYPE,
   p_adm_action IN  igs_sv_btch_summary.adm_action_code%TYPE,
   p_owner_table_name IN igs_sv_btch_summary.owner_table_name%TYPE,
   p_owner_table_id  IN  igs_sv_btch_summary.OWNER_TABLE_IDENTIFIER%TYPE
)
IS
   l_api_name CONSTANT VARCHAR(30) := 'Insert_Summary_Info';
l_count NUMBER;
CURSOR c_test IS
SELECT max(batch_id) FROM IGS_SV_BTCH_SUMMARY;
l_batch NUMBER(20) := 0;
BEGIN
/* Debug */
IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Summary_Info';
   l_debug_str := 'Entering Insert_Summary_Info. p_data_rec.person_id is '||p_person_id|| ' and batch_id is '||p_batch_id;
   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

   INSERT INTO IGS_SV_BTCH_SUMMARY (
        summary_id	       ,
        batch_id               ,
        person_id              ,
        action_code            ,
	tag_code               ,
	adm_action_code        ,
	creation_date          ,
	created_by             ,
	last_updated_by        ,
	last_update_date       ,
	last_update_login      ,
	owner_table_name,
	OWNER_TABLE_IDENTIFIER         --mmkumar, owner_table_id
     ) VALUES
     (
      IGS_SV_BTCH_SUMM_ID_S.nextval    ,
       p_batch_id  ,
       p_person_id  ,
       p_action_code ,
       p_tag_code  ,
       p_adm_action ,
       sysdate,
       g_update_by,
       g_update_by,
       sysdate,
       g_update_login,
       p_owner_table_name,
       p_owner_table_id
     );

  OPEN c_test;
  FETCH c_test INTO l_batch;
  CLOSE c_test;
     /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Summary_Info';
	   l_debug_str := 'record in Insert_Summary_Info max batch_id: '||l_batch;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Insert_Summary_Info';
	   l_debug_str := 'EXCEPTION in Insert_Summary_Info. '||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);
      RAISE;

END Insert_Summary_Info;


/******************************************************************
   Created By         : prbhardw

   Date Created By    : Jan 03, 2006

   Purpose            : Code to submit event and generate XML has been seperated
                        from create_batch as part of SEVIS enhancements.

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Generate_Batch_XML(
          errbuf   OUT NOCOPY VARCHAR2,  -- Request standard error string
	  retcode  OUT NOCOPY NUMBER  ,  -- Request standard return status
	  batch_id IN NUMBER
)
IS
  CURSOR c_get_batch_type(cp_batch_id igs_sv_batches.batch_id%TYPE)
  IS
     SELECT batch_type
     FROM igs_sv_batches
     WHERE batch_id = cp_batch_id;
  l_batch_type VARCHAR2(1);
  l_batch_id   igs_sv_batches.batch_id%TYPE;
 BEGIN
       retcode := 0;
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Generate_Batch_XML';
	   l_debug_str := 'Batch_id for Generate_Batch_XML: '||batch_id;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg('Batch id for Generate Batch XML: '||batch_id, 0);

     OPEN c_get_batch_type(batch_id);
     FETCH c_get_batch_type INTO l_batch_type;
     CLOSE c_get_batch_type;
     Submit_Event ( l_batch_type, batch_id);
     /* fix for bug 5330564 */
     l_batch_id := batch_id;
     UPDATE igs_sv_batches
     SET batch_status = 'X' , xml_gen_date = trunc(sysdate)
     WHERE batch_id = l_batch_id;

     xml_log_file(batch_id);
EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK;
        retcode := 2;
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'igs_sv_batch_process_pkg.Generate_Batch_XML'|| '-' || SQLERRM);
        igs_ge_msg_stack.conc_exception_hndl;
END Generate_Batch_XML;


/******************************************************************
   Created By         : prbhardw

   Date Created By    : Jun 09, 2006

   Purpose            : Create log file for Generate_Batch_XML process.

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE xml_log_file(p_batch_id IN igs_sv_btch_summary.batch_id%TYPE)
IS

   l_api_name CONSTANT VARCHAR(30) := 'xml_log_file';
   l_per_count NUMBER(5) := 0;
   l_person_num hz_parties.party_number%TYPE;
   l_info_meaning igs_lookup_values.meaning%TYPE;

   CURSOR c_updated_pers(cp_batch_id igs_sv_btch_summary.batch_id%TYPE)
   IS
     SELECT summ.person_id, summ.tag_code
     FROM igs_sv_btch_summary summ
     WHERE summ.batch_id = cp_batch_id AND
	  summ.adm_action_code ='HOLD' AND
	  EXISTS (SELECT 1 FROM igs_sv_persons pers
		  WHERE pers.person_id = summ.person_id AND
		  pers.batch_id = summ.batch_id AND
		  pers.record_status = 'C' );

   CURSOR c_new_pers(cp_batch_id igs_sv_btch_summary.batch_id%TYPE)
   IS
     SELECT distinct person_number
     FROM igs_sv_persons pers
     WHERE pers.batch_id = cp_batch_id AND record_status = 'N'
           AND EXISTS (SELECT 1
		FROM igs_sv_btch_summary summ
		WHERE summ.person_id = pers.person_id AND
                  summ.batch_id=pers.batch_id AND
                  summ.adm_action_code ='HOLD' AND
                  summ.batch_id = pers.batch_id);
   CURSOR c_get_prsn_num(cp_party_id hz_parties.party_id%TYPE)
   IS
     SELECT party_number
     FROM hz_parties
     WHERE party_id = cp_party_id;

   CURSOR c_get_info(cp_tag_code igs_sv_btch_summary.tag_code%TYPE)
   IS
     SELECT lkp.meaning info
     FROM  igs_lookup_values lkp
     WHERE lkp.lookup_code = cp_tag_code
           AND lkp.lookup_type ='IGS_SV_COMP_TREE';
BEGIN

	FOR c_new_pers_rec IN c_new_pers(p_batch_id) LOOP
	  l_per_count := l_per_count + 1;
	  IF l_per_count = 1 THEN
	        fnd_file.put_line(FND_FILE.LOG,' ');
		fnd_message.set_name('IGS','IGS_SV_PERS_ON_HOLD');
		fnd_file.put_line(fnd_file.log,fnd_message.get());
		fnd_file.put_line(FND_FILE.LOG,' ');
		fnd_message.set_name('IGS','IGS_SV_PER_NUM');
		fnd_file.put_line(fnd_file.log,'	' || fnd_message.get());
		Put_Log_Msg('	--------------',1);
	  END IF;
          Put_Log_Msg('	' || c_new_pers_rec.person_number,1);
	END LOOP;

	l_per_count := 0;

	FOR c_updated_pers_rec IN c_updated_pers(p_batch_id) LOOP
	  l_per_count := l_per_count + 1;
	  IF l_per_count = 1 THEN
	        fnd_file.put_line(FND_FILE.LOG,' ');
		fnd_message.set_name('IGS','IGS_SV_INFO_ON_HOLD');
		fnd_file.put_line(fnd_file.log,fnd_message.get());
		fnd_file.put_line(FND_FILE.LOG,' ');
		fnd_message.set_name('IGS','IGS_SV_PER_NUM');
   	        fnd_file.put(fnd_file.log,'        ' || rpad(fnd_message.get(),30,' '));
	        fnd_message.set_name('IGS','IGS_SV_INFMN');
	        fnd_file.put_line(fnd_file.log,'		' || fnd_message.get());
                Put_Log_Msg('        --------------				------------ ',1);

	  END IF;
	  OPEN c_get_prsn_num(c_updated_pers_rec.person_id);
	  FETCH c_get_prsn_num INTO l_person_num;
	  CLOSE c_get_prsn_num;

	  OPEN c_get_info(c_updated_pers_rec.tag_code);
	  FETCH c_get_info INTO l_info_meaning;
	  CLOSE c_get_info;

          Put_Log_Msg('        ' || rpad(l_person_num,30,' ') || '          ' || l_info_meaning,1);
	END LOOP;

EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.xml_log_file';
	   l_debug_str := 'EXCEPTION in xml_log_file.'||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END xml_log_file;


/******************************************************************
   Created By         : prbhardw

   Date Created By    : Jan 03, 2006

   Purpose            : Create log file.

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE compose_log_file
IS

   l_api_name CONSTANT VARCHAR(30) := 'compose_log_file';
   l_batch_count NUMBER(5) := 1;
   l_per_count NUMBER(5) := 0;

   CURSOR c_persons_per_batch(cp_batch_id igs_sv_btch_summary.batch_id%TYPE)
   IS
     SELECT COUNT(DISTINCT person_id)
     FROM igs_sv_btch_summary
     WHERE batch_id = cp_batch_id;

   CURSOR c_get_new_persons(cp_batch_id igs_sv_btch_summary.batch_id%TYPE)
   IS
     SELECT hz.party_number prsn_num, lkp.meaning info
     FROM igs_sv_btch_summary svbs, hz_parties hz, igs_lookup_values lkp, igs_sv_persons pers
     WHERE svbs.batch_id = cp_batch_id
           AND svbs.person_id = hz.party_id
           AND svbs.tag_code = lkp.lookup_code
           AND lkp.lookup_type ='IGS_SV_COMP_TREE'
	   AND lkp.enabled_flag = 'Y'
	   AND svbs.person_id = pers.person_id
           AND svbs.batch_id = pers.batch_id
           AND pers.record_status = 'N';

   CURSOR c_get_updated_persons(cp_batch_id igs_sv_btch_summary.batch_id%TYPE)
   IS
     SELECT hz.party_number prsn_num, lkp.meaning info
     FROM igs_sv_btch_summary svbs, hz_parties hz, igs_lookup_values lkp, igs_sv_persons pers
     WHERE svbs.batch_id = cp_batch_id
           AND svbs.person_id = hz.party_id
           AND svbs.tag_code = lkp.lookup_code
           AND lkp.lookup_type ='IGS_SV_COMP_TREE'
	   AND lkp.enabled_flag = 'Y'
	   AND svbs.person_id = pers.person_id
           AND svbs.batch_id = pers.batch_id
           AND pers.record_status = 'C';

BEGIN
        fnd_message.set_name('IGS','IGS_SV_BTCH');
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(FND_FILE.LOG,' ');
	--Put_Log_Msg(' Following Batch IDs are generated: ',0);
        fnd_message.set_name('IGS','IGS_SV_BTCH_ID');
        fnd_file.put(fnd_file.log,'  ' || fnd_message.get());
	fnd_message.set_name('IGS','IGS_SV_PERS_COUNT');
        fnd_file.put_line(fnd_file.log,'     ' || fnd_message.get());
	--Put_Log_Msg('  Batch ID     No. of Persons',0);
	--Put_Log_Msg('  --------     --------------',0);
  --   g_running_batches(1) := 2020205;

   --  g_parallel_batches(1) := 1010101;

  FOR i IN 1..g_parallel_batches.COUNT LOOP
     OPEN c_persons_per_batch(g_parallel_batches(i));
     FETCH c_persons_per_batch INTO l_per_count;
     CLOSE c_persons_per_batch;
     Put_Log_Msg('  ' || g_parallel_batches(i) || '   :  ' || l_per_count,1);
     l_batch_count := l_batch_count+1;
  END LOOP;

  FOR i IN 1..g_running_batches.COUNT LOOP
     OPEN c_persons_per_batch(g_running_batches(i));
     FETCH c_persons_per_batch INTO l_per_count;
     CLOSE c_persons_per_batch;
     Put_Log_Msg('  ' || g_running_batches(i) || '   :  ' || l_per_count,1);
     l_batch_count := l_batch_count+1;
  END LOOP;

     fnd_file.put_line(FND_FILE.LOG,' ');
     fnd_message.set_name('IGS','IGS_SV_BTCH_PERS');
     fnd_file.put_line(fnd_file.log,fnd_message.get());
     fnd_file.put_line(FND_FILE.LOG,' ');
   --  Put_Log_Msg(' ',0);
   --  Put_Log_Msg(' Following are the person records included in each batch: ',0);
    -- Put_Log_Msg(' ',0);

  FOR i IN 1..g_parallel_batches.COUNT LOOP
     fnd_message.set_name('IGS','IGS_SV_BTCH_ID');
     fnd_file.put_line(fnd_file.log,'  ' || fnd_message.get() || ': ' || g_parallel_batches(i));
  --   Put_Log_Msg('  Batch ID: '||g_parallel_batches(i),0);
  --   Put_Log_Msg('  ------------------------',0);
     fnd_message.set_name('IGS','IGS_SV_NEW_PERS');
     fnd_file.put_line(fnd_file.log,'     ' || fnd_message.get());
    --- Put_Log_Msg('     New Persons: ',0);
    -- Put_Log_Msg('     ------------',0);
     fnd_message.set_name('IGS','IGS_SV_PER_NUM');
     fnd_file.put(fnd_file.log,'        ' || rpad(fnd_message.get(),30,' '));
     fnd_message.set_name('IGS','IGS_SV_INFMN');
     fnd_file.put_line(fnd_file.log,'		' || fnd_message.get());
   --  Put_Log_Msg('        Person Number			Information ',0);
     Put_Log_Msg('        --------------				------------ ',1);

     FOR new_persons IN c_get_new_persons(g_parallel_batches(i)) LOOP
          Put_Log_Msg('        ' || rpad(new_persons.prsn_num,30,' ') || '          ' || new_persons.info,1);
     END LOOP;

     fnd_message.set_name('IGS','IGS_SV_UPD_PERS');
     fnd_file.put_line(fnd_file.log,'     ' || fnd_message.get());
     --Put_Log_Msg('     Updated Persons: ',0);
     Put_Log_Msg('     ----------------',1);
     fnd_message.set_name('IGS','IGS_SV_PER_NUM');
     fnd_file.put(fnd_file.log,'        ' || rpad(fnd_message.get(),30,' '));
     fnd_message.set_name('IGS','IGS_SV_INFMN');
     fnd_file.put_line(fnd_file.log,'		' || fnd_message.get());
     --Put_Log_Msg('        Person Number			Information ',0);
     Put_Log_Msg('        --------------				------------ ',1);

     FOR updated_persons IN c_get_updated_persons(g_parallel_batches(i)) LOOP
          Put_Log_Msg('        ' || rpad(updated_persons.prsn_num,30,' ') || '          ' || updated_persons.info,1);
     END LOOP;

  END LOOP;

  FOR i IN 1..g_running_batches.COUNT LOOP
     Put_Log_Msg('  Batch ID: ' || g_running_batches(i),1);
     Put_Log_Msg('  ------------------------',1);
     fnd_message.set_name('IGS','IGS_SV_NEW_PERS');
     fnd_file.put_line(fnd_file.log,'     ' || fnd_message.get());
   --  Put_Log_Msg('     New Persons: ',0);
     Put_Log_Msg('     ------------',1);
     fnd_message.set_name('IGS','IGS_SV_PER_NUM');
     fnd_file.put(fnd_file.log,'        ' || rpad(fnd_message.get(),30,' '));
     fnd_message.set_name('IGS','IGS_SV_INFMN');
     fnd_file.put_line(fnd_file.log,'		' || fnd_message.get());
    -- Put_Log_Msg('        Person Number			Information ',0);
     Put_Log_Msg('        --------------				------------ ',1);

     FOR new_persons IN c_get_new_persons(g_running_batches(i)) LOOP
          Put_Log_Msg('        ' || rpad(new_persons.prsn_num,30,' ') || '          ' || new_persons.info,1);
     END LOOP;

     fnd_message.set_name('IGS','IGS_SV_UPD_PERS');
     fnd_file.put_line(fnd_file.log,'     ' || fnd_message.get());
    -- Put_Log_Msg('     Updated Persons: ',0);
     Put_Log_Msg('     ----------------',1);
     fnd_message.set_name('IGS','IGS_SV_PER_NUM');
     fnd_file.put(fnd_file.log,'        ' || rpad(fnd_message.get(),30,' '));
     fnd_message.set_name('IGS','IGS_SV_INFMN');
     fnd_file.put_line(fnd_file.log,'		' || fnd_message.get());
     --Put_Log_Msg('        Person Number			Information ',0);
     Put_Log_Msg('        --------------				------------ ',1);

     FOR updated_persons IN c_get_updated_persons(g_running_batches(i)) LOOP
          Put_Log_Msg('        ' || rpad(updated_persons.prsn_num,30,' ') || '          ' || updated_persons.info,1);
     END LOOP;
  END LOOP;


EXCEPTION

  WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;
      /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.compose_log_file';
	   l_debug_str := 'EXCEPTION in compose_log_file.'||SQLERRM;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg(l_api_name||' OTHERS ERROR ',1);

      RAISE;

END compose_log_file;

/******************************************************************
   Created By         : prbhardw

   Date Created By    : Apr 18, 2006

   Purpose            : Assign new DSO.

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/

 PROCEDURE Assign_DSO(
          errbuf   OUT NOCOPY VARCHAR2,
	  retcode  OUT NOCOPY NUMBER  ,
	  p_group_type IN VARCHAR2,
	  p_dummy_1 IN VARCHAR2,
	  p_dummy_2 IN VARCHAR2,
	  p_old_dso_id IN VARCHAR2,
	  p_group_id IN VARCHAR2,
	  p_new_dso_id IN VARCHAR2
)
IS

 CURSOR c_group_members IS
     SELECT person_id
     FROM igs_pe_prsid_grp_mem_all
     WHERE group_id = p_group_id AND SYSDATE BETWEEN start_date AND NVL(end_date, SYSDATE);

 CURSOR c_dso_relation(cp_person_id NUMBER) IS
     SELECT subject_id
     FROM hz_relationships
     WHERE object_id = cp_person_id AND
           SYSDATE BETWEEN start_date AND NVL(end_date, SYSDATE)
	   AND relationship_code = 'DSO_FOR';
	  -- AND directional_flag = 'F';	fix for bug 5258405

CURSOR c_old_dso_rel(cp_person_id NUMBER) IS
     SELECT object_id, relationship_id, comments, object_version_number, directional_flag
     FROM hz_relationships
     WHERE subject_id = cp_person_id AND
     SYSDATE BETWEEN start_date AND NVL(end_date, SYSDATE+1)
	   AND relationship_code = 'DSO_FOR';
	  -- AND directional_flag = 'F';	fix for bug 5258405

CURSOR c_old_rel_values(cp_rel_id HZ_RELATIONSHIPS.RELATIONSHIP_ID%TYPE, cp_dir_flag HZ_RELATIONSHIPS.DIRECTIONAL_FLAG%TYPE) IS
     SELECT directional_flag, primary, secondary, joint_salutation, next_to_kin, rep_faculty, rep_staff,
            rep_student, rep_alumni, emergency_contact_flag
     FROM igs_pe_hz_rel
     WHERE relationship_id = cp_rel_id
           AND directional_flag = cp_dir_flag;		-- fix for bug 5258405

 CURSOR c_get_person_num(cp_person_id hz_parties.party_id%TYPE) IS
     SELECT party_number person_num, person_first_name first_name, person_last_name last_name
     FROM hz_parties
     WHERE party_id = cp_person_id;

    lv_return_status VARCHAR2(1) ;
    lv_msg_count NUMBER;
    lv_msg_data VARCHAR2(2000);
    lv_party_relationship_id HZ_RELATIONSHIPS.RELATIONSHIP_ID%TYPE ;
    lv_party_id HZ_PARTIES.PARTY_ID%TYPE ;
    lv_party_number HZ_PARTIES.PARTY_NUMBER%TYPE ;
    lv_last_update_date HZ_PARTIES.LAST_UPDATE_DATE%TYPE ;
    lv_object_version_number HZ_RELATIONSHIPS.OBJECT_VERSION_NUMBER%TYPE;

    l_subject HZ_RELATIONSHIPS.SUBJECT_ID%TYPE;
    l_rel_id HZ_RELATIONSHIPS.RELATIONSHIP_ID%TYPE;
    l_old_rel_values c_old_rel_values%ROWTYPE;

    l_file_name igs_pe_persid_group_all.file_name%TYPE;
    l_str        VARCHAR2(32767);
    lv_status    VARCHAR2(1);
    --l_cursor_id  NUMBER (15);
    l_person_id HZ_PARTIES.PARTY_ID%TYPE ;
    TYPE person_rec IS REF CURSOR;
    c_person_rec person_rec;
   -- l_num_of_rows   NUMBER (15);

   l_old_dso_id VARCHAR2(20) := substr(p_old_dso_id,1,instr(p_old_dso_id,'-',-1)-1) ;
   l_old_dso_partyid NUMBER := to_number(substr(p_old_dso_id,instr(p_old_dso_id,'-',-1)+1));

   l_new_dso_id VARCHAR2(20) := substr(p_new_dso_id,1,instr(p_new_dso_id,'-',-1)-1) ;
   l_new_dso_partyid NUMBER := to_number(substr(p_new_dso_id,instr(p_new_dso_id,'-',-1)+1));

   l_obj_id  HZ_RELATIONSHIPS.OBJECT_ID%TYPE;

   TYPE c_person_det IS RECORD
   (
     person_num        hz_parties.party_number%TYPE,
     person_name       VARCHAR2(500),
     dso_person_num    hz_parties.party_number%TYPE
   );

   TYPE g_existing_rel_tbl IS TABLE OF c_person_det INDEX BY BINARY_INTEGER;

   g_existing_rel  g_existing_rel_tbl;
   l_person_num    hz_parties.party_number%TYPE;
   l_first_name    hz_parties.person_first_name%TYPE;
   l_last_name     hz_parties.person_last_name%TYPE;

   l_new_person_num    hz_parties.party_number%TYPE;
   l_new_first_name    hz_parties.person_first_name%TYPE;
   l_new_last_name     hz_parties.person_last_name%TYPE;

   l_counter NUMBER := 0;
   l_count NUMBER := 0;
   l_temp_count NUMBER := 0;

BEGIN
       retcode := 0;
       lv_last_update_date  := SYSDATE;
       lv_object_version_number := 1;
       /* Debug */
	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	   l_label := 'igs.plsql.igs_sv_batch_process_pkg.Assign_DSO';
	   l_debug_str := 'p_group_type: '||p_group_type||' p_old_dso_id: '||p_old_dso_id||' p_new_dso_id: '||p_new_dso_id||' p_group_id: '||p_group_id;
	   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;
      Put_Log_Msg('group type: '||p_group_type||'; old dso id: '||p_old_dso_id||'; new dso id: '||p_new_dso_id||'; group id: '||p_group_id, 0);
      Put_Log_Msg(' ', 0);
       IF p_group_type = 'G' THEN

	  IF p_group_id IS NULL THEN
	    -- Put_Log_Msg('Group ID cannot be left blank when new DSO is being assigned for a group', 0);
	     FND_MESSAGE.SET_NAME('IGS','IGS_SV_INV_GRP_ID');
	     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
	     FND_MSG_PUB.Add;
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;

	  l_str   := igs_pe_dynamic_persid_group.igs_get_dynamic_sql(p_group_id ,lv_status);
	  IF lv_status <> 'S' THEN
	     FND_MESSAGE.SET_NAME('IGF','IGF_AW_NO_QUERY');
	     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
	     RETURN;
	  END IF;

	  /* Debug */
	  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	     l_label := 'igs.plsql.igs_sv_batch_process_pkg.Assign_DSO';
	     l_debug_str := 'Query: '||l_str;
	     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	  END IF;

          --END IF;

	  /*l_cursor_id := DBMS_SQL.open_cursor;
          fnd_dsql.set_cursor (l_cursor_id);
          DBMS_SQL.parse (l_cursor_id, l_str, DBMS_SQL.native);
          fnd_dsql.do_binds;

	  DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_person_id
               );

	  l_num_of_rows := DBMS_SQL.EXECUTE (l_cursor_id);*/
	  OPEN c_person_rec FOR l_str ;
	  LOOP
	       FETCH c_person_rec INTO l_person_id;
	       EXIT WHEN c_person_rec%NOTFOUND;
	      /* EXIT WHEN DBMS_SQL.FETCH_ROWS (c) = 0;
               IF DBMS_SQL.fetch_rows (l_cursor_id) > 0 THEN
                    DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_person_id
                    );*/
		   OPEN c_dso_relation(l_person_id);
		   FETCH c_dso_relation INTO l_subject;
		   CLOSE c_dso_relation;

		   IF l_subject IS NULL THEN
		        l_counter := l_counter + 1;
			IGS_PE_RELATIONSHIPS_PKG.CREATUPDATE_PARTY_RELATIONSHIP (
				     P_ACTION                       => 'INSERT',
				     P_SUBJECT_ID                   => l_new_dso_partyid,
				     P_OBJECT_ID                    => l_person_id,
				     P_PARTY_RELATIONSHIP_TYPE      => 'DESIGNATED_SCHOOL_OFFICIAL',
				     P_RELATIONSHIP_CODE            => 'DSO_FOR',
				     P_COMMENTS                     => NULL,
				     P_START_DATE                   => SYSDATE,
				     P_END_DATE                     => NULL,
				     P_LAST_UPDATE_DATE             => lv_last_update_date,
				     P_RETURN_STATUS                => lv_return_status,
				     P_MSG_COUNT                    => lv_msg_count,
				     P_MSG_DATA                     => lv_msg_data,
				     P_PARTY_RELATIONSHIP_ID        => lv_party_relationship_id,
				     P_PARTY_ID                     => lv_party_id,
				     P_PARTY_NUMBER                 => lv_party_number,
				     P_CALLER                       => 'NOT_FAMILY',
				     P_OBJECT_VERSION_NUMBER        => lv_object_version_number,
				     P_PRIMARY                      => 'N',
				     P_SECONDARY                    => 'N',
				     P_JOINT_SALUTATION             => NULL,
				     P_NEXT_TO_KIN                  => 'N',
				     P_REP_FACULTY                  => 'N',
				     P_REP_STAFF                    => 'N',
				     P_REP_STUDENT                  => 'N',
				     P_REP_ALUMNI                   => 'N',
				     P_EMERGENCY_CONTACT_FLAG       => 'N'
			   );
			 OPEN c_get_person_num(l_new_dso_partyid);
			 FETCH c_get_person_num INTO l_person_num, l_first_name, l_last_name;
			 CLOSE c_get_person_num;

			 IF l_counter = 1 THEN
			     fnd_message.set_name('IGS','IGS_SV_NEW_REL');
			     fnd_message.set_token('PRSN_NAME', l_first_name||' '|| l_last_name);
		             fnd_file.put_line(fnd_file.log,fnd_message.get());
			    -- Put_Log_Msg('New DSO_OF relationship created for following persons with '||l_first_name||' '|| l_last_name, 0);
			     Put_Log_Msg(' ', 1);
			     fnd_message.set_name('IGS','IGS_SV_PRSN_NAME');
			     fnd_file.put(fnd_file.log,'  ' || rpad(fnd_message.get(),60,' '));
			     fnd_message.set_name('IGS','IGS_SV_PER_NUM');
			     fnd_file.put_line(fnd_file.log,'  ' || fnd_message.get());
			     fnd_file.put(fnd_file.log, rpad('  -----------',60,' '));
			     fnd_file.put_line(fnd_file.log,'    -------------');
			    -- Put_Log_Msg('Person Name			Person Number', 0);
			    -- Put_Log_Msg('-----------			-------------', 0);
			 END IF;
		         OPEN c_get_person_num(l_person_id);
			 FETCH c_get_person_num INTO l_person_num, l_first_name, l_last_name;
			 CLOSE c_get_person_num;
			 fnd_file.put(fnd_file.log,'  ' || rpad(l_first_name||' '|| l_last_name,60,' '));
			 fnd_file.put_line(fnd_file.log,'  ' || l_person_num);
 			 --Put_Log_Msg(l_first_name||' '|| l_last_name||'			'|| l_person_num, 0);
		   ELSE
		         l_temp_count := l_temp_count + 1;
			 OPEN c_get_person_num(l_person_id);
			 FETCH c_get_person_num INTO l_person_num, l_first_name, l_last_name;
			 CLOSE c_get_person_num;
                         g_existing_rel(l_temp_count).person_num := l_person_num;
                         g_existing_rel(l_temp_count).person_name := l_first_name ||' '||l_last_name;
			 OPEN c_get_person_num(l_subject);
			 FETCH c_get_person_num INTO l_person_num, l_first_name, l_last_name;
			 CLOSE c_get_person_num;
			 g_existing_rel(l_temp_count).dso_person_num := l_person_num;
		   END IF;
		   l_subject := NULL;
	  END LOOP;
	  --DBMS_SQL.close_cursor (l_cursor_id);
	  CLOSE c_person_rec;
	  FOR i IN 1..g_existing_rel.COUNT LOOP
	     IF i = 1 THEN
	       Put_Log_Msg(' ', 1);
	       fnd_message.set_name('IGS','IGS_SV_REL_EXISTS');
	       fnd_file.put_line(fnd_file.log,fnd_message.get());
	       Put_Log_Msg(' ', 1);
	       fnd_message.set_name('IGS','IGS_SV_PRSN_NAME');
	       fnd_file.put(fnd_file.log,'  ' || rpad(fnd_message.get(),60,' '));
	       fnd_message.set_name('IGS','IGS_SV_PER_NUM');
	       fnd_file.put(fnd_file.log,'  ' || rpad(fnd_message.get(),20,' '));
	       fnd_message.set_name('IGS','IGS_SV_DSO');
	       fnd_file.put_line(fnd_file.log,'   ' || fnd_message.get());

	       fnd_file.put(fnd_file.log, rpad('  -----------',60,' '));
	       fnd_file.put(fnd_file.log, rpad('    -----------',20,' '));
	       fnd_file.put_line(fnd_file.log,'    -------------');

	      -- Put_Log_Msg('Relationship not created for following persons:',0);
	      -- Put_Log_Msg('Person Name			Person Number		      Existing DSO',0);
	      -- Put_Log_Msg('-----------			-------------		      ------------',0);
	     END IF;
	     fnd_file.put(fnd_file.log,'  ' || rpad(g_existing_rel(i).person_name,60,' '));
             fnd_file.put(fnd_file.log,'  ' || rpad(g_existing_rel(i).person_num,20,' '));
	     fnd_file.put_line(fnd_file.log,'  ' || g_existing_rel(i).dso_person_num);
	    -- Put_Log_Msg(g_existing_rel(i).person_name || '			'||rpad(g_existing_rel(i).person_num,20,' ')||'		' || g_existing_rel(i).dso_person_num,0);
	  END LOOP;
	  Put_Log_Msg(' ', 1);
	  fnd_message.set_name('IGS','IGS_SV_REL_CREATED');
          fnd_message.set_token('COUNT', l_counter);
          fnd_file.put_line(fnd_file.log,fnd_message.get());
          Put_Log_Msg(' ', 1);
          fnd_message.set_name('IGS','IGS_SV_REL_NOT_CRTED');
          fnd_message.set_token('COUNT', g_existing_rel.COUNT);
          fnd_file.put_line(fnd_file.log,fnd_message.get());
       ELSE
		IF p_old_dso_id IS NULL THEN
		    --Put_Log_Msg('Enter the old DSO ID for which new relationships have to be created.', 0);
		    FND_MESSAGE.SET_NAME('IGS','IGS_SV_INV_DSO_ID');
		    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
		    FND_MSG_PUB.Add;
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
		IF p_old_dso_id = p_new_dso_id THEN
		    --Put_Log_Msg('Old DSO ID and new DSO ID cannot be same. Request Terminated', 0);
		    FND_MESSAGE.SET_NAME('IGS','IGS_SV_INV_PARAMS');
		    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
		    FND_MSG_PUB.Add;
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
		FOR r_old_dso_rel_rec IN c_old_dso_rel(l_old_dso_partyid) LOOP
		        l_count := l_count + 1;
		        l_rel_id := r_old_dso_rel_rec.relationship_id;
			OPEN c_old_rel_values(l_rel_id, r_old_dso_rel_rec.directional_flag);	-- fix for bug 5258405
			FETCH c_old_rel_values INTO l_old_rel_values;
			CLOSE c_old_rel_values;
			l_obj_id := r_old_dso_rel_rec.object_id;
			lv_object_version_number := r_old_dso_rel_rec.object_version_number;

			IGS_PE_RELATIONSHIPS_PKG.CREATUPDATE_PARTY_RELATIONSHIP (
				     P_ACTION                       => 'UPDATE',
				     P_SUBJECT_ID                   => l_old_dso_partyid,
				     P_OBJECT_ID                    => l_obj_id,
				     P_PARTY_RELATIONSHIP_TYPE      => 'DESIGNATED_SCHOOL_OFFICIAL',
				     P_RELATIONSHIP_CODE            => 'DSO_FOR',
				     P_COMMENTS                     => r_old_dso_rel_rec.comments,
				     P_START_DATE                   => SYSDATE,
				     P_END_DATE                     => SYSDATE,
				     P_LAST_UPDATE_DATE             => lv_last_update_date,
				     P_RETURN_STATUS                => lv_return_status,
				     P_MSG_COUNT                    => lv_msg_count,
				     P_MSG_DATA                     => lv_msg_data,
				     P_PARTY_RELATIONSHIP_ID        => l_rel_id,
				     P_PARTY_ID                     => lv_party_id,
				     P_PARTY_NUMBER                 => lv_party_number,
				     P_CALLER                       => 'NOT_FAMILY',
				     P_OBJECT_VERSION_NUMBER        => lv_object_version_number,
				     P_PRIMARY                      => l_old_rel_values.primary,
				     P_SECONDARY                    => l_old_rel_values.secondary,
				     P_JOINT_SALUTATION             => l_old_rel_values.joint_salutation,
				     P_NEXT_TO_KIN                  => l_old_rel_values.next_to_kin,
				     P_REP_FACULTY                  => l_old_rel_values.rep_faculty,
				     P_REP_STAFF                    => l_old_rel_values.rep_staff,
				     P_REP_STUDENT                  => l_old_rel_values.rep_student,
				     P_REP_ALUMNI                   => l_old_rel_values.rep_alumni,
				     P_DIRECTIONAL_FLAG             => l_old_rel_values.directional_flag,
				     P_EMERGENCY_CONTACT_FLAG       => l_old_rel_values.emergency_contact_flag
				);
			lv_object_version_number := 1;
			IGS_PE_RELATIONSHIPS_PKG.CREATUPDATE_PARTY_RELATIONSHIP (
				     P_ACTION                       => 'INSERT',
				     P_SUBJECT_ID                   => l_new_dso_partyid,
				     P_OBJECT_ID                    => l_obj_id,
				     P_PARTY_RELATIONSHIP_TYPE      => 'DESIGNATED_SCHOOL_OFFICIAL',
				     P_RELATIONSHIP_CODE            => 'DSO_FOR',
				     P_COMMENTS                     => r_old_dso_rel_rec.comments,
				     P_START_DATE                   => SYSDATE,
				     P_END_DATE                     => NULL,
				     P_LAST_UPDATE_DATE             => lv_last_update_date,
				     P_RETURN_STATUS                => lv_return_status,
				     P_MSG_COUNT                    => lv_msg_count,
				     P_MSG_DATA                     => lv_msg_data,
				     P_PARTY_RELATIONSHIP_ID        => lv_party_relationship_id,
				     P_PARTY_ID                     => lv_party_id,
				     P_PARTY_NUMBER                 => lv_party_number,
				     P_CALLER                       => 'NOT_FAMILY',
				     P_OBJECT_VERSION_NUMBER        => lv_object_version_number,
				     P_PRIMARY                      => l_old_rel_values.primary,
				     P_SECONDARY                    => l_old_rel_values.secondary,
				     P_JOINT_SALUTATION             => l_old_rel_values.joint_salutation,
				     P_NEXT_TO_KIN                  => l_old_rel_values.next_to_kin,
				     P_REP_FACULTY                  => l_old_rel_values.rep_faculty,
				     P_REP_STAFF                    => l_old_rel_values.rep_staff,
				     P_REP_STUDENT                  => l_old_rel_values.rep_student,
				     P_REP_ALUMNI                   => l_old_rel_values.rep_alumni,
				     P_EMERGENCY_CONTACT_FLAG       => l_old_rel_values.emergency_contact_flag
			);
			lv_party_relationship_id := NULL;
			IF l_count = 1 THEN
				OPEN c_get_person_num(l_old_dso_partyid);
				FETCH c_get_person_num INTO l_person_num, l_first_name, l_last_name;
				CLOSE c_get_person_num;
				--Put_Log_Msg('DSO_OF relationship of following persons is end dated with '||l_first_name||' '|| l_last_name, 0);
				OPEN c_get_person_num(l_new_dso_partyid);
				FETCH c_get_person_num INTO l_new_person_num, l_new_first_name, l_new_last_name;
				CLOSE c_get_person_num;
				fnd_message.set_name('IGS','IGS_SV_REL_UPD');
			        fnd_message.set_token('OLD_DSO_NAME', l_first_name||' '|| l_last_name);
				fnd_message.set_token('NEW_DSO_NAME', l_new_first_name||' '|| l_new_last_name);
		                fnd_file.put_line(fnd_file.log,fnd_message.get());
			        Put_Log_Msg(' ', 1);
			        fnd_message.set_name('IGS','IGS_SV_PRSN_NAME');
			        fnd_file.put(fnd_file.log,'  ' || rpad(fnd_message.get(),60,' '));
			        fnd_message.set_name('IGS','IGS_SV_PER_NUM');
			        fnd_file.put_line(fnd_file.log,'  ' || fnd_message.get());
			        fnd_file.put(fnd_file.log, rpad('  -----------',60,' '));
			        fnd_file.put_line(fnd_file.log,'    -------------');

				--Put_Log_Msg('and new relationship created with '||l_new_first_name||' '|| l_new_last_name||':', 0);
				--Put_Log_Msg('Person Name			Person Number', 0);
				--Put_Log_Msg('-----------			-------------', 0);
			END IF;
			OPEN c_get_person_num(l_obj_id);
			FETCH c_get_person_num INTO l_person_num, l_first_name, l_last_name;
			CLOSE c_get_person_num;
                       -- Put_Log_Msg(l_first_name||' '||l_last_name ||'			'||l_person_num, 0);
		         fnd_file.put(fnd_file.log,'  ' || rpad(l_first_name||' '|| l_last_name,60,' '));
			 fnd_file.put_line(fnd_file.log,'  ' || l_person_num);


		END LOOP;
		Put_Log_Msg(' ', 1);
		fnd_message.set_name('IGS','IGS_SV_REL_UPDATED');
		fnd_message.set_token('COUNT', l_count);
		fnd_file.put_line(fnd_file.log,fnd_message.get());
       END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        retcode := 2;
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'igs_sv_batch_process_pkg.Assign_DSO'|| '-' || SQLERRM);
        igs_ge_msg_stack.conc_exception_hndl;
  WHEN OTHERS THEN
        ROLLBACK;
        retcode := 2;
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'igs_sv_batch_process_pkg.Assign_DSO'|| '-' || SQLERRM);
        igs_ge_msg_stack.conc_exception_hndl;
END Assign_DSO;

END igs_sv_batch_process_pkg;

/
