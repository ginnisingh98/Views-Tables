--------------------------------------------------------
--  DDL for Package Body IGS_PS_WF_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_WF_EVENT_PKG" AS
/* $Header: IGSPS82B.pls 120.2 2006/01/09 06:32:48 sommukhe ship $ */

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 19-JUL-2001
  --
  --Purpose:  Created as part of the build for DLD Unit Section Enrollment Information
  --          This package deals with raising of Business Event. This package has the
  --          following procedure:
  --             i)  wf_create_event - Raises the event
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --jbegum      26-Apr-2003     For Enh Bug# 2833850
  --                            Added columns preferred_region_code and no_set_day_ind to
  --                            the the call to igs_ps_usec_occurs_pkg.update_row
  -------------------------------------------------------------------------------------

 PROCEDURE wf_create_event(
                              p_uoo_id                       IN  NUMBER,
                              p_usec_occur_id                IN  NUMBER DEFAULT NULL,
                              p_event_type                   IN  VARCHAR2,
                              p_message                     OUT NOCOPY  VARCHAR2
                            )
 IS
   l_wf_event_t            WF_EVENT_T;
   l_wf_parameter_list_t   WF_PARAMETER_LIST_T;

   --
   -- cursor to fetch the usec_occur_id
   --
   CURSOR c_usec_occur_id (cp_uoo_id   igs_ps_usec_occurs.uoo_id%TYPE) IS
          SELECT unit_section_occurrence_id
          FROM   igs_ps_usec_occurs
          WHERE  uoo_id = cp_uoo_id;

    --
    -- procedure to define_event
    --
    PROCEDURE  raise_event (p_event_name     IN   VARCHAR2,
                            p_event_key      IN   VARCHAR2,
                            p_event_type     IN   VARCHAR2,
                            p_uoo_id         IN   NUMBER,
                            p_usec_occur_id  IN   NUMBER)
         ------------------------------------------------------------------------------------
          --Created by  : smanglm ( Oracle IDC)
          --Date created: 19-JUL-2001
          --
          --Purpose:  local procedure to raise_event
          --          local to  wf_create_event
          --
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
          -------------------------------------------------------------------------------------
    IS
         l_key                   NUMBER;
    BEGIN
         --
         -- initialize the wf_event_t object
         --
         WF_EVENT_T.Initialize(l_wf_event_t);
         --
         -- set the event name
         --
         l_wf_event_t.setEventName( pEventName => p_event_name);
         --
         -- set the event key but before the select a number from sequenec
         --
         SELECT IGS_PS_USEC_WF_ITEM_KEY_S.NEXTVAL INTO l_key FROM dual;
         l_wf_event_t.setEventKey ( pEventKey => p_event_key||l_key );
         --
         -- set the parameter list
         --
         l_wf_event_t.setParameterList ( pParameterList => l_wf_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --
         l_wf_event_t.AddParameterToList ( pName => 'ORG_ID',  pValue => FND_PROFILE.VALUE('ORG_ID'));
         l_wf_event_t.AddParameterToList ( pName => 'USER_ID', pValue => FND_PROFILE.VALUE('USER_ID'));
         l_wf_event_t.AddParameterToList ( pName => 'RESP_ID', pValue => FND_PROFILE.VALUE('RESP_ID'));
         l_wf_event_t.AddParameterToList ( pName => 'RESP_APPL_ID', pValue => FND_PROFILE.VALUE('RESP_APPL_ID'));
         l_wf_event_t.AddParameterToList ( pName => 'UOO_ID',  pValue => p_uoo_id);
         l_wf_event_t.AddParameterToList ( pName => 'USEC_OCCUR_ID',  pValue => p_usec_occur_id);
         l_wf_event_t.AddParameterToList ( pName => 'EVENT_TYPE',  pValue => p_event_type);

         --
         -- raise the event
         --
         WF_EVENT.RAISE (p_event_name => p_event_name,
                         p_event_key  => p_event_key||l_key,
                         p_event_data => NULL,
                         p_parameters => l_wf_parameter_list_t);
    END raise_event;

    --
    -- procedure to update igs_ps_usec_occurs
    --
    PROCEDURE update_usec_occurs  (p_usec_occur_id IN NUMBER)
         ------------------------------------------------------------------------------------
          --Created by  : smanglm ( Oracle IDC)
          --Date created: 19-JUL-2001
          --
          --Purpose:  local procedure  update_usec_occurs for updating notify_status
          --          local to  wf_create_event
          --
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
          --smvk        25-jun-2003     Enh bug#2918094. Added column cancel_flag.
          -------------------------------------------------------------------------------------

    IS
         --
         -- cursor to get the usec details
         --
         CURSOR c_usec_details (cp_usec_occur_id   igs_ps_usec_occurs.unit_section_occurrence_id%TYPE) IS
                SELECT *
                FROM   igs_ps_usec_occurs
                WHERE  unit_section_occurrence_id = cp_usec_occur_id;

        l_cst_complete    CONSTANT VARCHAR2(10) DEFAULT 'COMPLETE';
    BEGIN
      --
      -- open the cursor and call update row of
      --
      FOR rec_usec_details IN c_usec_details (p_usec_occur_id)
      LOOP
         igs_ps_usec_occurs_pkg.update_row
             (
                X_ROWID                                          =>     rec_usec_details.ROW_ID,
                X_UNIT_SECTION_OCCURRENCE_ID                     =>     rec_usec_details.UNIT_SECTION_OCCURRENCE_ID,
                X_UOO_ID                                         =>     rec_usec_details.UOO_ID,
                X_MONDAY                                         =>     rec_usec_details.MONDAY,
                X_TUESDAY                                        =>     rec_usec_details.TUESDAY,
                X_WEDNESDAY                                      =>     rec_usec_details.WEDNESDAY,
                X_THURSDAY                                       =>     rec_usec_details.THURSDAY,
                X_FRIDAY                                         =>     rec_usec_details.FRIDAY,
                X_SATURDAY                                       =>     rec_usec_details.SATURDAY,
                X_SUNDAY                                         =>     rec_usec_details.SUNDAY,
                X_START_TIME                                     =>     rec_usec_details.START_TIME,
                X_END_TIME                                       =>     rec_usec_details.END_TIME,
                X_BUILDING_CODE                                  =>     rec_usec_details.BUILDING_CODE,
                X_ROOM_CODE                                      =>     rec_usec_details.ROOM_CODE,
                X_SCHEDULE_STATUS                                =>     rec_usec_details.SCHEDULE_STATUS,
                X_STATUS_LAST_UPDATED                            =>     rec_usec_details.STATUS_LAST_UPDATED,
                X_INSTRUCTOR_ID                                  =>     rec_usec_details.INSTRUCTOR_ID,
                X_ATTRIBUTE_CATEGORY                             =>     rec_usec_details.ATTRIBUTE_CATEGORY,
                X_ATTRIBUTE1                                     =>     rec_usec_details.ATTRIBUTE1,
                X_ATTRIBUTE2                                     =>     rec_usec_details.ATTRIBUTE2,
                X_ATTRIBUTE3                                     =>     rec_usec_details.ATTRIBUTE3,
                X_ATTRIBUTE4                                     =>     rec_usec_details.ATTRIBUTE4,
                X_ATTRIBUTE5                                     =>     rec_usec_details.ATTRIBUTE5,
                X_ATTRIBUTE6                                     =>     rec_usec_details.ATTRIBUTE6,
                X_ATTRIBUTE7                                     =>     rec_usec_details.ATTRIBUTE7,
                X_ATTRIBUTE8                                     =>     rec_usec_details.ATTRIBUTE8,
                X_ATTRIBUTE9                                     =>     rec_usec_details.ATTRIBUTE9,
                X_ATTRIBUTE10                                    =>     rec_usec_details.ATTRIBUTE10,
                X_ATTRIBUTE11                                    =>     rec_usec_details.ATTRIBUTE11,
                X_ATTRIBUTE12                                    =>     rec_usec_details.ATTRIBUTE12,
                X_ATTRIBUTE13                                    =>     rec_usec_details.ATTRIBUTE13,
                X_ATTRIBUTE14                                    =>     rec_usec_details.ATTRIBUTE14,
                X_ATTRIBUTE15                                    =>     rec_usec_details.ATTRIBUTE15,
                X_ATTRIBUTE16                                    =>     rec_usec_details.ATTRIBUTE16,
                X_ATTRIBUTE17                                    =>     rec_usec_details.ATTRIBUTE17,
                X_ATTRIBUTE18                                    =>     rec_usec_details.ATTRIBUTE18,
                X_ATTRIBUTE19                                    =>     rec_usec_details.ATTRIBUTE19,
                X_ATTRIBUTE20                                    =>     rec_usec_details.ATTRIBUTE20,
                X_ERROR_TEXT                                     =>     rec_usec_details.ERROR_TEXT,
                X_MODE                                           =>     'R',
                X_START_DATE                                     =>     rec_usec_details.START_DATE,
                X_END_DATE                                       =>     rec_usec_details.END_DATE,
                X_TO_BE_ANNOUNCED                                =>     rec_usec_details.TO_BE_ANNOUNCED,
                X_INST_NOTIFY_IND                                =>     rec_usec_details.INST_NOTIFY_IND,
                X_NOTIFY_STATUS                                  =>     l_cst_complete,
                X_DEDICATED_BUILDING_CODE                        =>     rec_usec_details.DEDICATED_BUILDING_CODE,
                X_DEDICATED_ROOM_CODE                            =>     rec_usec_details.DEDICATED_ROOM_CODE,
                X_PREFERRED_BUILDING_CODE                        =>     rec_usec_details.PREFERRED_BUILDING_CODE,
                X_PREFERRED_ROOM_CODE                            =>     rec_usec_details.PREFERRED_ROOM_CODE,
                  X_PREFERRED_REGION_CODE                        =>     rec_usec_details.PREFERRED_REGION_CODE,
                X_NO_SET_DAY_IND                                 =>     rec_usec_details.NO_SET_DAY_IND,
                X_cancel_flag                                    =>     rec_usec_details.cancel_flag,
		x_occurrence_identifier                          =>     rec_usec_details.occurrence_identifier,
		x_abort_flag                                     =>     rec_usec_details.abort_flag

            );
         --
         -- now nullify the column in the shadow table igs_ps_sh_usec_occurs
         -- direct update statement is used as there is no TBH for shadow tables
         --
         UPDATE igs_ps_sh_usec_occurs SET
                monday           = NULL,
                tuesday          = NULL,
                wednesday        = NULL,
                thursday         = NULL,
                friday           = NULL,
                saturday         = NULL,
                sunday           = NULL,
                room_code        = NULL,
                building_code    = NULL,
                start_time       = NULL,
                end_time         = NULL,
                instructor_id    = NULL
         WHERE  unit_section_occurrence_id = p_usec_occur_id;

      END LOOP;
    END update_usec_occurs;

 --
 -- main begin
 --
 BEGIN
   --
   -- check for the parameters, if both p_uoo_id and p_usec_occur_id are null, return
   -- with error message
   --
   IF p_uoo_id IS NULL AND p_usec_occur_id IS NULL THEN
      p_message := 'IGS_GE_NOT_ENGH_PARAM';
      RETURN;
   END IF;

   --
   -- check for the value of p_event_type
   -- if it is MOD, the proc is called from IGSPS084 and there has been some
   -- change in the uoo_id details, the event to be raised in this case is
   -- oracle.apps.igs.ps.wfus_md
   -- if it is CNCL, the proc is called from the backend when the unit section
   -- status has been changed to CANCELLED. In this case the event raised will
   -- be oracle.apps.igs.ps.wfus_cn
   --

   --
   -- check if p_usec_occur_id is null,
   -- raise the event for all the usec_occur_id available for the passed uoo_id
   --
   IF p_usec_occur_id IS NULL THEN
      --
      -- fetch all the usec_occur_id for the passed uoo_id
      --
      FOR rec_usec_occur_id IN c_usec_occur_id (p_uoo_id)
      LOOP
           IF p_event_type = 'MOD' THEN
              --
              --  raise oracle.apps.igs.ps.wfus_md
              --
              raise_event (p_event_name    => 'oracle.apps.igs.ps.wfus_md',
                           p_event_key     => 'wfus_md',
                           p_event_type    => 'MOD',
                           p_uoo_id        => p_uoo_id,
                           p_usec_occur_id => rec_usec_occur_id.unit_section_occurrence_id);
           ELSIF p_event_type = 'CNCL' THEN
              --
              --  raise oracle.apps.igs.ps.wfus_cn
              --
              raise_event (p_event_name    => 'oracle.apps.igs.ps.wfus_cn',
                           p_event_key     => 'wfus_cn',
                           p_event_type    => 'CNCL',
                           p_uoo_id        => p_uoo_id,
                           p_usec_occur_id => rec_usec_occur_id.unit_section_occurrence_id);
           END IF;
           --
           -- on successful raising of events update notify status to COMPLETE
           -- in igs_ps_usec_occurs and change field values to null in the shadow
           -- table
           --
           update_usec_occurs (p_usec_occur_id => rec_usec_occur_id.unit_section_occurrence_id);
      END LOOP;
   ELSE
      IF p_event_type = 'MOD' THEN
      --
      --  raise oracle.apps.igs.ps.wfus_md
      --
         raise_event (p_event_name    => 'oracle.apps.igs.ps.wfus_md',
                      p_event_key     => 'wfus_md',
                      p_event_type    => 'MOD',
                      p_uoo_id        => p_uoo_id,
                      p_usec_occur_id => p_usec_occur_id);
      ELSIF p_event_type = 'CNCL' THEN
      --
      --  raise oracle.apps.igs.ps.wfus_cn
      --
         raise_event (p_event_name    => 'oracle.apps.igs.ps.wfus_cn',
                      p_event_key     => 'wfus_cn',
                      p_event_type    => 'CNCL',
                      p_uoo_id        => p_uoo_id,
                      p_usec_occur_id => p_usec_occur_id);
      END IF;
      --
      -- on successful raising of events update notify status to COMPLETE
      -- in igs_ps_usec_occurs and change field values to null in the shadow
      -- table
      --
      update_usec_occurs (p_usec_occur_id =>  p_usec_occur_id);
   END IF; -- end of check for  p_usec_occur_id
 END wf_create_event;

  PROCEDURE fac_exceed_wl_event(errbuf OUT NOCOPY VARCHAR2,
                               retcode OUT NOCOPY NUMBER,
                               p_c_cal_inst IN VARCHAR2)
    ------------------------------------------------------------------------------------
          --Created by  : jdeekoll ( Oracle IDC)
          --Date created: 06-May-2003
          --
          --Purpose:  HR Integration build(# 2833853)
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
	  --sommukhe   9-JAN-2006       Bug# 4869737,included call to igs_ge_gen_003.set_org_id.
   -------------------------------------------------------------------------------------
   AS
     l_n_key                   NUMBER;
     l_wf_event_t              WF_EVENT_T;
     l_wf_parameter_list_t     WF_PARAMETER_LIST_T;

           l_c_user_name           fnd_user.user_name%TYPE:=fnd_global.user_name;
           l_c_cal_type            igs_ca_inst.cal_type%TYPE;
           l_n_cal_seq_num         igs_ca_inst.sequence_number%TYPE;

        /* Cursor to find the setup in the Employment Category*/

         CURSOR c_emp_cat_setup IS
           SELECT 'x' FROM igs_ps_emp_cats_wl
           WHERE rownum = 1;

        /* Cursor for Sequence */

         CURSOR c_seq IS
            SELECT IGS_PS_EXCEED_FAC_WL_S.NEXTVAL
            FROM DUAL;

          l_c_emp_cat_setup VARCHAR2(1);

   BEGIN

	 igs_ge_gen_003.set_org_id (NULL);
         -- Set the default status as success
                retcode := 0;

        /* Workload setup done or not */

         OPEN c_emp_cat_setup;
         FETCH c_emp_cat_setup INTO l_c_emp_cat_setup;
         IF c_emp_cat_setup%NOTFOUND THEN
           fnd_message.set_name('IGS','IGS_PS_NO_EMP_CAT_SETUP');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           close c_emp_cat_setup;
           RETURN;
         END IF;
         close c_emp_cat_setup;

        -- Get the calendar sequence number and calendar type

        l_c_cal_type := RTRIM(SUBSTR(p_c_cal_inst,1,10));
        l_n_cal_seq_num := TO_NUMBER(RTRIM(SUBSTR(p_c_cal_inst,14,19)));

         -- initialize the wf_event_t object
         --
         WF_EVENT_T.Initialize(l_wf_event_t);
         --
         -- set the event name
         --
         l_wf_event_t.setEventName( pEventName => 'oracle.apps.igs.ps.exceed.fac_workload');
         --
         -- event key to identify uniquely
         --
         OPEN c_seq;
         FETCH c_seq INTO l_n_key;
         CLOSE c_seq;
         --
         -- set the parameter list
         --
         l_wf_event_t.setParameterList ( pParameterList => l_wf_parameter_list_t );
         --
         -- now add the parameters to the parameter list

         wf_event.AddParameterToList ( p_name => 'IA_USER', p_value =>l_c_user_name , p_parameterlist => l_wf_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'IA_CAL_TYPE', p_value =>l_c_cal_type, p_parameterlist => l_wf_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'IA_CAL_SEQ_NUM', p_value =>l_n_cal_seq_num, p_parameterlist => l_wf_parameter_list_t);
         --
         -- raise the event

            wf_event.raise (
                             p_event_name => 'oracle.apps.igs.ps.fac_workload.exceed',
                             p_event_key  =>  'FACEXCEEDWL'||l_n_key,
                             p_parameters => l_wf_parameter_list_t
                          );
   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       retcode:=2;
       fnd_file.put_line(fnd_file.log,sqlerrm);
       errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') ;
       igs_ge_msg_stack.conc_exception_hndl;
   END fac_exceed_wl_event;

  PROCEDURE generate_faculty_list(itemtype        in varchar2,
                                  itemkey         in varchar2,
                                  actid           in number,
                                  funcmode        in varchar2,
                                  resultout       out NOCOPY varchar2
                                )
    ------------------------------------------------------------------------------------
          --Created by  : jdeekoll ( Oracle IDC)
          --Date created: 06-May-2003
          --
          --Purpose:  HR Integration build(# 2833853)
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
   -------------------------------------------------------------------------------------
   AS
   BEGIN

     IF (funcmode  = 'RUN') THEN

       wf_engine.SetItemAttrText(itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'IA_FAC_HEADER',
                                 avalue          => 'PLSQLCLOB:igs_ps_wf_event_pkg.generate_faculty_header/'|| itemtype || ':' || itemkey);

       wf_engine.SetItemAttrText(itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'IA_FAC_BODY',
                                 avalue          => 'PLSQLCLOB:igs_ps_wf_event_pkg.generate_faculty_body/'|| itemtype || ':' || itemkey);


     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;

   END generate_faculty_list;

  PROCEDURE generate_faculty_header(document_id in varchar2,
                                    display_type in Varchar2,
                                    document      in out NOCOPY clob,
                                    document_type       in out NOCOPY  varchar2
                                     )
    ------------------------------------------------------------------------------------
          --Created by  : jdeekoll ( Oracle IDC)
          --Date created: 06-May-2003
          --
          --Purpose:  HR Integration build(# 2833853) - Header for faculty list
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
   -------------------------------------------------------------------------------------
   AS

    l_c_document     VARCHAR2(400);

   BEGIN

     /* Header in HTML format */

     l_c_document := '<table BORDER COLS=3 WIDTH="100%"><tr>'||'<th width=80%>Name</th>'||'<th width=10%>Expected/Override Workload</th>'||'<th width=10%>Actual Workload</th></tr>';

     /* Write the header doc into CLOB variable */

     WF_NOTIFICATION.WriteToClob(document, l_c_document);

   END generate_faculty_header;

  PROCEDURE generate_faculty_body(document_id in varchar2,
                                  display_type in  Varchar2,
                                  document      in out NOCOPY clob,
                                  document_type in out NOCOPY  varchar2
                                  )
    ------------------------------------------------------------------------------------
          --Created by  : jdeekoll ( Oracle IDC)
          --Date created: 06-May-2003
          --
          --Purpose:  HR Integration build(# 2833853)
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
   -------------------------------------------------------------------------------------
   AS
    l_c_document     VARCHAR2(32000);
    l_c_itemtype     VARCHAR2(100);
    l_c_itemkey      WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE;
    l_c_cal_type     igs_ca_inst.cal_type%TYPE;
    l_n_cal_seq_num  igs_ca_inst.sequence_number%TYPE;
    l_n_tot_fac_wl   NUMBER:=0;
    l_n_exp_wl       NUMBER(10,2):=0;
    l_n_cntr         NUMBER(5):=0;

     /* Cursor to get the list of faculty/Staff */

     /* Due to performance issues with igs_pe_typ_instances view, broke the view in 2 different views as shown below */

       CURSOR c_igs_person IS
         SELECT pti.person_id
         FROM   igs_pe_typ_instances_all pti, igs_pe_person_types pt
         WHERE  NVL (pti.org_id, NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))
                = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
         AND    pt.person_type_code = pti.person_type_code
         AND    pt.system_type IN ('STAFF','FACULTY')
         AND    SYSDATE BETWEEN pti.start_date AND NVL(pti.end_date,SYSDATE);

       CURSOR c_hr_person IS
         SELECT peo.party_id
         FROM per_person_type_usages_f usg,per_people_f peo,
             igs_pe_per_type_map map
         WHERE  usg.person_id = peo.person_id  AND
                usg.person_type_id = map.per_person_type_id AND
                SYSDATE BETWEEN usg.effective_start_date and usg.effective_end_date AND
                TRUNC(SYSDATE) BETWEEN peo.effective_start_date AND peo.effective_end_date;

        l_n_person_id hz_parties.party_id%TYPE;

   PROCEDURE print_fac_list(p_n_person_id hz_parties.party_id%TYPE,p_c_cal_type igs_ca_inst.cal_type%TYPE,p_n_cal_seq_num igs_ca_inst.sequence_number%TYPE) AS

       /* Cursor to get the person name */

        CURSOR c_person_name(cp_n_person_id hz_parties.party_id%TYPE)  IS
          SELECT hz.party_name
          FROM  hz_parties hz
          WHERE party_id = cp_n_person_id AND
          hz.status = 'A';

         l_c_person_name hz_parties.party_name%TYPE;

   BEGIN

       /* Getting Person name */

       OPEN c_person_name(p_n_person_id);
       FETCH c_person_name INTO l_c_person_name;
       CLOSE c_person_name;

           /* Check for Faculty workload exceeded expected workload */

             IF igs_ps_gen_001.fac_exceed_exp_wl(
                                                  p_c_cal_type,
                                                  p_n_cal_seq_num,
                                                  p_n_person_id,
                                                  0,
                                                  l_n_tot_fac_wl,
                                                  l_n_exp_wl
                                                 )THEN

                IF l_n_exp_wl = 0 THEN
                  fnd_message.set_name('IGS', 'IGS_PS_NO_SETUP_FAC_EXCEED');
                  l_c_document := l_c_document||'<TR><TD>'||l_c_person_name ||'</TD><TD colspan=2>'||fnd_message.get||'</TD></TR>';
                ELSE
                  l_c_document := l_c_document||'<TR><TD>'||l_c_person_name||'</TD><TD>'|| l_n_exp_wl ||'</TD><TD>'|| l_n_tot_fac_wl ||'</TD></TR>';
                END IF;
                l_n_cntr := l_n_cntr + 1;
              END IF;

             IF l_n_cntr = 100 THEN
                WF_NOTIFICATION.WriteToClob(document, l_c_document);
                l_c_document := null;
                l_n_cntr := 1;
             END IF;


   END print_fac_list;

   BEGIN

      /* Get item type and item key */

     l_c_itemtype := SUBSTR(document_id, 1, instr(document_id, ':') - 1);
     l_c_itemkey := SUBSTR(document_id, instr(document_id, ':') + 1, length(document_id));

     /* Get the cal type and sequence number from attributes i.e. being passed from concurrent job */

     l_c_cal_type  := wf_engine.GetItemAttrText (itemtype => l_c_itemtype,
                                                 itemkey  => l_c_itemkey,
                                                 aname    => 'IA_CAL_TYPE'
                                                );
     l_n_cal_seq_num  := wf_engine.GetItemAttrNumber (itemtype => l_c_itemtype,
                                                      itemkey  => l_c_itemkey,
                                                      aname    => 'IA_CAL_SEQ_NUM'
                                                     );



       /* Process HR cursor */

       l_n_person_id := NULL;

       OPEN c_hr_person;
       LOOP
         FETCH c_hr_person INTO l_n_person_id;
         EXIT WHEN c_hr_person%NOTFOUND;
         print_fac_list(l_n_person_id,l_c_cal_type,l_n_cal_seq_num);
       END LOOP;
       CLOSE c_hr_person;

       /* Process OSS cursor, that are not present in HR */

         OPEN c_igs_person;
         LOOP
         FETCH c_igs_person INTO l_n_person_id;
           EXIT WHEN c_igs_person%NOTFOUND;
           print_fac_list(l_n_person_id,l_c_cal_type,l_n_cal_seq_num);
         END LOOP;
         CLOSE c_igs_person;

        /* If no records exist, then print No data found message */

        IF l_n_cntr = 0 THEN
        fnd_message.set_name('IGS','IGS_GE_NO_DATA_FOUND');
         l_c_document := '<TR><TD>'||fnd_message.get||'</TD></TR>';
        END IF;

        l_c_document := l_c_document||'</table>';
        WF_NOTIFICATION.WriteToClob(document, l_c_document);

   END generate_faculty_body;

END IGS_PS_WF_EVENT_PKG;

/
