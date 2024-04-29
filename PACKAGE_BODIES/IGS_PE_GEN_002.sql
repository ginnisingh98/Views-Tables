--------------------------------------------------------
--  DDL for Package Body IGS_PE_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_GEN_002" AS
/* $Header: IGSPE14B.pls 120.1 2006/01/18 22:32:51 skpandey noship $ */
/* Change Hisotry
   Who          When        What
    kumma      11-MAR-2003    2841566, Removed the statement close c_user from procedure Receive_External_Hold when the p_admin is passed null
    asbala     22-AUG-2003    3071111: GSCC FILE.DATE.5 Compliance
    ssawhney   17 Aug         3690580, for perf reasons changed cursor hr_record, in get_hr_installed.
*/
PROCEDURE apply_admin_hold
/*
  ||  Created By : ssawhney
  ||  Created On : 17-feb-2003
  ||  Purpose : This Procedure will apply admin holds on a person. There were 3 steps while applying admin hold and not just a call to the TBH
  ||            Hence created an API that all the 3 process are kept together and can be used
  ||            The API will return DECODED messages.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

		(P_PERSON_ID		IN	hz_parties.party_id%TYPE,
		P_ENCUMBRANCE_TYPE    	IN	igs_pe_pers_encumb.encumbrance_type%TYPE,
		P_START_DT		IN	Date,
		P_END_DT		IN	Date,
		P_AUTHORISING_PERSON_ID	IN	hz_parties.party_id%TYPE,
		P_COMMENTS		IN	igs_pe_pers_encumb.comments%TYPE,
		P_SPO_COURSE_CD		IN	igs_pe_pers_encumb.spo_course_cd%TYPE,
		P_SPO_SEQUENCE_NUMBER	IN	igs_pe_pers_encumb.spo_sequence_number%TYPE,
		P_CAL_TYPE		IN	igs_pe_pers_encumb.cal_type%TYPE,
		P_SEQUENCE_NUMBER	IN	igs_pe_pers_encumb.sequence_number%TYPE,
		P_AUTH_RESP_ID		IN	igs_pe_pers_encumb.auth_resp_id%TYPE,
		P_EXTERNAL_REFERENCE	IN	igs_pe_pers_encumb.external_reference%TYPE,
		P_MESSAGE_NAME		OUT	NOCOPY varchar2,
		P_MESSAGE_STRING	OUT	NOCOPY Varchar2
			) IS

l_rowid varchar2(30);
l_message_name varchar2(2000);
l_message_string varchar2(2000);
l_err_raised BOOLEAN;
l_app fnd_new_messages.application_id%TYPE;
ln_msg_index number;

BEGIN

l_message_name := NULL;
l_message_string := NULL;
l_err_raised :=FALSE;
      BEGIN

     SAVEPOINT hold_insert;

     -- issue a savepoint and start the insertion directly.

	igs_pe_pers_encumb_pkg.insert_row
        (
              x_mode                     =>   'R'                     ,
     	      x_rowid                    =>   l_rowid                 ,
	      x_person_id                =>   p_person_id   ,
	      x_encumbrance_type         =>   p_encumbrance_type             ,
	      x_start_dt                 =>   p_start_dt            ,
	      x_expiry_dt                =>   p_end_dt                    ,
	      x_authorising_person_id    =>   p_authorising_person_id,  -- let the tbh handle this,
	      x_comments                 =>   p_comments                    ,
	      x_spo_course_cd            =>   p_spo_course_cd                    ,
              x_spo_sequence_number      =>   p_spo_sequence_number                    ,
              x_cal_type                 =>   p_cal_type              ,
              x_sequence_number          =>   p_sequence_number ,
	      x_auth_resp_id             =>   p_auth_resp_id,
	      x_external_reference       =>   p_external_reference
        ) ;

      EXCEPTION
        WHEN OTHERS THEN
	ROLLBACK to hold_insert;
    	  l_err_raised := TRUE ;

          -- get the exception raised from the STACK
	  IGS_GE_MSG_STACK.GET(-1, 'F', l_message_name, ln_msg_index);

	  IF l_message_name is NOT NULL  THEN
		p_message_name := l_message_name;
		p_message_string := null;
		RETURN;
	  END IF;
      END ;

      IF NOT (l_err_raised) THEN

      -- if exception is not raised continue on applying the default effects.

        BEGIN
          --check if the encumbrance has effects which require that the active
          -- enrolments be dicontinued , validate that SCA'S are inactive
          IF igs_en_val_pen.finp_val_encmb_eff ( p_person_id ,
                                                 p_encumbrance_type          ,
	                                         p_start_dt          ,
		                   		 NULL                 ,
					         l_message_name
                    					        ) = FALSE
          THEN
	        -- get the exception raised from the STACK
	        IGS_GE_MSG_STACK.GET(-1, 'F', l_message_name, ln_msg_index);
                p_message_name := l_message_name;
		p_message_string := null;
		RETURN;
          END IF;

          -- call the procedure which creates the default effects for the encumbrance type .
          igs_en_gen_009.enrp_ins_dflt_effect ( p_person_id ,
                                                p_encumbrance_type   ,
	                                        p_start_dt  ,
					        NULL                 ,
                    				NULL                 ,
					        l_message_name       ,
                    				l_message_string
	                                           ) ;
          IF l_message_name IS NOT NULL THEN

	        -- get the exception raised from the STACK
	        IGS_GE_MSG_STACK.GET(-1, 'F', l_message_name, ln_msg_index);
    	        p_message_name := l_message_name;
	        p_message_string := l_message_string;
	        RETURN;
          END IF;

	-- do not trap any exception, let them get raised directly.

	END ;  --inside BEGIN
      END IF;
END  apply_admin_hold;

PROCEDURE raise_success_event
 (
     p_person_number IN VARCHAR2,
     p_hold_type     IN VARCHAR2,
     p_start_dt      IN VARCHAR2,
     p_end_dt        IN VARCHAR2
 ) IS
/*
  ||  Created By : kumma
  ||  Created On : 17-feb-2003
  ||  Purpose : This is a local procedure called when event has to be raised.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
     CURSOR c_seq_num IS
          SELECT
               IGS_PE_PE003_WF_S.nextval
          FROM
               DUAL;

     ln_seq_val            NUMBER;
     l_event_t             wf_event_t;
     l_parameter_list_t    wf_parameter_list_t;

 BEGIN

     -- initialize the parameter list.
     wf_event_t.Initialize(l_event_t);

     -- set the parameters.
     wf_event.AddParameterToList ( p_name => 'P_PERSON_NUMBER' , p_value => p_person_number , p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'P_HOLD_TYPE'     , p_Value => p_hold_type     , p_ParameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'P_START_DT'      , p_Value => p_start_dt      , p_ParameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'P_END_DT'        , p_Value => p_end_dt        , p_ParameterList  => l_parameter_list_t);

     -- get the sequence value to be added to EVENT KEY to make it unique.
     OPEN  c_seq_num;
     FETCH c_seq_num INTO ln_seq_val ;
     CLOSE c_seq_num ;


     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pe.extholdss',
	  p_event_key  => 'PE003C'||ln_seq_val,
	  p_parameters => l_parameter_list_t
     );
 END raise_success_event;

 PROCEDURE Receive_External_Hold (
     itemtype       IN              VARCHAR2,
     itemkey        IN              VARCHAR2,
     actid          IN              NUMBER,
     funcmode       IN              VARCHAR2,
     resultout      OUT NOCOPY      VARCHAR2
 )IS
/*
  ||  Created By : kumma
  ||  Created On : 17-feb-2003
  ||  Purpose : This Procedure will be called from WF, IGSPE003. This will be doing the processing of external holds.
  ||            and will raise failure events/notifications if required.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || ssawhney                      Incorrect check while cheking for SUSPENSION effect.
  ||                               BUG : 2832973. message stack initialzied and record already exists added
  ||                               check for 'IGS_EN_ENCMBR_HAS_SPECIFIED' also added explicity
  || kumma           11-MAR-2003   2841566, Removed the close c_user statement from the else clause when the p_admin is null
  || ssaleem         13-Apr-2005   Bug 4293911 Fnd User customer Id  replaced with person
  ||                                           party id
*/



   -- fnd user check cursor.
     CURSOR c_user (cp_user fnd_user.user_name%TYPE) IS
          SELECT
	       'X'
	  FROM
	       fnd_user
          WHERE
	       user_name = cp_user AND
               email_address IS NOT NULL AND
	       person_party_id IS NOT NULL;

   -- student check cursor
     CURSOR c_student_chk (cp_person_number igs_pe_person_base_v.person_number%TYPE) IS
          SELECT
	       person_id,NVL(full_name,person_number) full_name
	  FROM
	       igs_pe_person_base_v
          WHERE
	       person_number = cp_person_number;

   -- hold type exists check cursor
     CURSOR c_hold_typ_exst(cp_encumbrance_type igs_fi_encmb_type.encumbrance_type%TYPE) IS
          SELECT
	       'X'
	  FROM
	       igs_fi_encmb_type
          WHERE
	       encumbrance_type = cp_encumbrance_type AND
	       s_encumbrance_cat = 'ADMIN';

    -- check whether release hold should be called or apply hold should be called
    -- change view IGS_PE_PERS_ENCUMB from igs_pe_pers_pen_encumb_v
     CURSOR c_hold_alrdy_exst(cp_person_id igs_pe_person_base_v.person_id%TYPE,
			      cp_encumbrance_type igs_pe_pers_encumb_v.encumbrance_type%TYPE,
                              cp_start_dt DATE) IS
          SELECT
	       expiry_dt
	  FROM
	       IGS_PE_PERS_ENCUMB
          WHERE
               person_id = cp_person_id AND
	       encumbrance_type = cp_encumbrance_type AND
	       start_dt = cp_start_dt;

    -- check for mismatch of external ref passed
    -- remove reference to the view.
     CURSOR c_external_hold_exst(cp_person_id igs_pe_person_base_v.person_id%TYPE,
                                 cp_encumbrance_type igs_pe_pers_encumb_v.encumbrance_type%TYPE,
                                 cp_start_dt DATE,
				 cp_external_reference igs_pe_pers_encumb_v.external_reference%TYPE) IS
          SELECT
	       'X'
	  FROM
	       igs_pe_pers_encumb
          WHERE
               person_id = cp_person_id AND
	       encumbrance_type = cp_encumbrance_type AND
	       start_dt = cp_start_dt AND
	       external_reference = cp_external_reference;

    -- cursor to check if the hold has an effect of SUS_COURSE.
    CURSOR c_hold_eff(cp_hold_type igs_pe_pers_encumb_v.encumbrance_type%TYPE) IS
    SELECT 'X'
    FROM igs_fi_enc_dflt_eft
    WHERE encumbrance_type = cp_hold_type AND
          s_encmb_effect_type = 'SUS_COURSE';



     l_exist_exp_dt DATE;
     l_exist VARCHAR2(1);
     ln_msg_index NUMBER;
     l_person_number VARCHAR2(30);
     l_hold_type igs_pe_pers_encumb.encumbrance_type%TYPE;
     l_start_dt VARCHAR2(30);
     l_d_start_dt DATE := NULL;

     l_expiry_date  VARCHAR2(30);
     l_d_expiry_date DATE := NULL;

     l_external_ref  igs_pe_pers_encumb.external_reference%TYPE;
     l_admin fnd_user.user_name%TYPE;
     l_person_name igs_pe_person_base_v.full_name%TYPE;


     l_student_rec c_student_chk%ROWTYPE;
     l_message_name  VARCHAR2(2000);
     l_message_string VARCHAR2(2000);

     l_role_name  VARCHAR2(320);
     l_role_display_name    VARCHAR2(320);

     l_error  VARCHAR2(30);
     l_app fnd_new_messages.application_id%TYPE;
     v_message_name VARCHAR2(30);


PROCEDURE Message_Get(
     p_message_name IN VARCHAR2,
     p_message_text OUT NOCOPY VARCHAR2) IS

 /* local procedure to get the text of the message.
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
     asbala         22-AUG-2003     3071111: GSCC FILE.DATE.5 Compliance
 */

 CURSOR c_text (cp_message_name fnd_new_messages.message_name%TYPE) IS
 SELECT message_text
 FROM fnd_new_messages
 WHERE message_name = cp_message_name AND
       application_id=8405 AND
       LANGUAGE_CODE = USERENV('LANG');

 l_text fnd_new_messages.message_text%TYPE;
 BEGIN

 OPEN c_text (p_message_name);
 FETCH c_text into l_text;
 CLOSE c_text;

 IF l_text IS NOT NULL THEN
    p_message_text := l_text;
    RETURN;
 END IF;

 p_message_text := '';
 EXCEPTION
 WHEN OTHERS THEN
   IF c_text%ISOPEN THEN
      CLOSE c_text;
      p_message_text :='Null';
      RETURN;
   END IF;
 END  Message_Get;

 BEGIN

     IF funcmode = 'RUN' THEN

     l_role_display_name   := 'Adhoc Role for External Holds IGSPE003';

	  -- initalize the message stacks and the variables.
          l_message_name := null;
          l_message_string := null;
	  FND_MSG_PUB.initialize;

          -- Fetch all the parameters from Event
	  l_person_number := wf_engine.GetItemAttrText(itemtype,itemkey,'P_PERSON_NUMBER'  );
  	  l_hold_type     := wf_engine.GetItemAttrText(itemtype,itemkey,'P_HOLD_TYPE');
	  l_start_dt := wf_engine.GetItemAttrText(itemtype,itemkey,'P_START_DT' );
	  l_expiry_date := wf_engine.GetItemAttrText(itemtype,itemkey,'P_EXPIRATION_DATE' );
	  l_external_ref := wf_engine.GetItemAttrText(itemtype,itemkey,'P_EXTERNAL_REFERENCE' );
	  l_admin := wf_engine.GetItemAttrText(itemtype,itemkey,'P_ADMIN' );


          --Check that l_admin is not null, if it is not null then create the role else return with 'E'
          IF l_admin IS NOT NULL THEN
	       OPEN c_user(l_admin);
	       FETCH c_user INTO l_exist;

	      -- set error
	      l_error :='IGS_PE_FND_USR_INCOMP';
	      message_get(l_error,l_message_name);
      	       IF c_user%NOTFOUND THEN
   		    Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'P_ERROR',
		       avalue    =>  l_message_name
		    );

                    resultout := 'COMPLETE:E';
	            CLOSE c_user;
	            return;
               ELSE
		    CLOSE c_user;
                    --Create the role
		   l_role_name := 'IGS'||itemkey;

		     Wf_Directory.CreateAdHocRole (
			  role_name         => l_role_name,
			  role_display_name => l_role_display_name
		     );

		     Wf_Directory.AddUsersToAdHocRole (
			  role_name  => l_role_name,
			  role_users => l_admin
		     );

		     Wf_Engine.SetItemAttrText(
			  ItemType  =>  itemtype,
			  ItemKey   =>  itemkey,
			  aname     =>  'P_ADMIN',
			  avalue    =>  l_role_name
		     );

               END IF;
          ELSE

	   -- set error
	      l_error :='IGS_FI_PARAMETER_NULL';
	      message_get(l_error,l_message_name);
	            Wf_Engine.SetItemAttrText(
				    ItemType  =>  itemtype,
				    ItemKey   =>  itemkey,
				    aname     =>  'P_ERROR',
				    avalue    =>  l_message_name
		    );

                    resultout := 'COMPLETE:E';
		    --kumma,2841566, removed the line "CLOSE c_user" Commented the following line as this cursor will not get open for this case.
	            return;
	  END IF;


	  --Validate that none of the paramater except expiry_date and person_name is null
	  IF l_person_number IS NULL OR l_hold_type IS NULL OR
	     l_start_dt IS NULL OR l_external_ref IS NULL THEN
		 -- set error
	           l_error :='IGS_FI_PARAMETER_NULL';
	           message_get(l_error,l_message_name);
		    Wf_Engine.SetItemAttrText(
				    ItemType  =>  itemtype,
				    ItemKey   =>  itemkey,
				    aname     =>  'P_ERROR',
				    avalue    =>  l_message_name
		     );

	            resultout := 'COMPLETE:F';
		    return;
	  END IF;

          --check if the person is a student
	  OPEN c_student_chk(l_person_number);
          FETCH c_student_chk INTO l_student_rec;

          IF c_student_chk%NOTFOUND THEN
               CLOSE c_student_chk;
	       	 -- set error
	           l_error :='IGS_GE_INVALID_PERSON_NUMBER';
	           message_get(l_error,l_message_name);
	       Wf_Engine.SetItemAttrText(
		    ItemType  =>  itemtype,
                    ItemKey   =>  itemkey,
                    aname     =>  'P_ERROR',
                    avalue    =>  l_message_name
               );
               resultout := 'COMPLETE:F';
	       return;
          ELSE
	       CLOSE c_student_chk;
		    Wf_Engine.SetItemAttrText(
				    ItemType  =>  itemtype,
				    ItemKey   =>  itemkey,
				    aname     =>  'P_PERSON_NAME',
				    avalue    =>  l_student_rec.full_name
		     );

     	       l_person_name := wf_engine.GetItemAttrText(itemtype,itemkey,'P_PERSON_NAME' );
	  END IF;


	  --check if the hold type exists
          OPEN c_hold_typ_exst(l_hold_type);
          FETCH c_hold_typ_exst INTO l_exist;

          IF c_hold_typ_exst%NOTFOUND THEN
               CLOSE c_hold_typ_exst;

	       l_error := 'IGS_PE_INVALID_HOLD';
	       message_get(l_error,l_message_name);
	       Wf_Engine.SetItemAttrText(
		    ItemType  =>  itemtype,
                    ItemKey   =>  itemkey,
                    aname     =>  'P_ERROR',
                    avalue    =>  l_message_name
               );

               resultout := 'COMPLETE:F';
	       return;
          ELSE
	       CLOSE c_hold_typ_exst;
               l_exist := NULL;
	       -- this means hold exists, now check if it has an effect of SUS_COURSE
	       OPEN  c_hold_eff(l_hold_type);
	       FETCH c_hold_eff INTO l_exist;
	       -- if suspension effect exists then raise the error else do nothing.
	       IF c_hold_eff%FOUND THEN
	          CLOSE c_hold_eff;
                  l_error := 'IGS_PE_INVALID_HOLD';
	          message_get(l_error,l_message_name);
	          Wf_Engine.SetItemAttrText(
		    ItemType  =>  itemtype,
                    ItemKey   =>  itemkey,
                    aname     =>  'P_ERROR',
                    avalue    =>  l_message_name
                  );

                  resultout := 'COMPLETE:F';
	          return;
               ELSE
	          CLOSE c_hold_eff;
	       END IF;

	  END IF;



          --check the date format of the start date
	  DECLARE
	       CURSOR c_dt_format(cp_date VARCHAR2) IS
	            SELECT     igs_ge_date.igsdate(igs_ge_date.igschar(cp_date))
                    FROM       DUAL;


	  BEGIN

	       OPEN c_dt_format(l_start_dt);
	       FETCH c_dt_format INTO l_d_start_dt;
               CLOSE c_dt_format;

	       IF l_expiry_date IS NOT NULL THEN
		       OPEN c_dt_format(l_expiry_date);
		       FETCH c_dt_format INTO l_d_expiry_date;
		       CLOSE c_dt_format;
	       END IF;
          EXCEPTION
	       WHEN OTHERS THEN
                    IF c_dt_format%ISOPEN THEN
	               CLOSE c_dt_format;
		    END IF;
		    l_error := 'IGS_PE_INVLD_DATE_FRMT';
		    message_get(l_error,l_message_name);
		    Wf_Engine.SetItemAttrText(
			    ItemType  =>  itemtype,
			    ItemKey   =>  itemkey,
			    aname     =>  'P_ERROR',
			    avalue    =>  l_message_name
		    );
		    resultout := 'COMPLETE:F';
		    return;
	  END;

          --Check whether the hold already exists on the student
	  OPEN c_hold_alrdy_exst(l_student_rec.person_id,l_hold_type, igs_ge_date.igsdate(igs_ge_date.igschar(l_start_dt)));
	  FETCH c_hold_alrdy_exst INTO l_exist_exp_dt;

	  IF c_hold_alrdy_exst%NOTFOUND THEN
	       CLOSE c_hold_alrdy_exst;
	       --apply the hold

	   -- ELSIF (( l_exist_exp_dt IS NULL) AND (l_expiry_date IS NOT NULL)) THEN
	     -- this is the case where there exists a hold of the same type and is NOT end date
	     -- and the user is trying to apply the similar hold on a different dates and is providing an exipry for the new hold.
	     -- this is NOT allowed.
	     -- in the TBH this error is trapped only when inserting and exp_dt null, but explicitly trapped in the form
	     -- hence trapping it here...SSAWHNEY

	     IF IGS_EN_VAL_PEN.enrp_val_pen_open (
                     l_student_rec.person_id,
                     l_hold_type,
                     igs_ge_date.igsdate(igs_ge_date.igschar(l_start_dt)),
                     v_message_name) = FALSE THEN

                     IF v_message_name IS NOT NULL then


                        l_error :='IGS_EN_ENCMBR_HAS_SPECIFIED';
			message_get(l_error,l_message_name);
			Wf_Engine.SetItemAttrText(
					ItemType  =>  itemtype,
					ItemKey   =>  itemkey,
					aname     =>  'P_ERROR',
					avalue    =>  l_message_name
					 );
					resultout := 'COMPLETE:F';
					return;
                    END IF;
              END IF;

	       -- initialize message variables.
	       l_message_name := NULL;
	       l_message_string := NULL;
	       igs_pe_gen_002.apply_admin_hold
	       (
	            p_person_id                =>    l_student_rec.person_id,
	            p_encumbrance_type         =>    l_hold_type,
	            p_start_dt                 =>    igs_ge_date.igsdate(igs_ge_date.igschar(l_start_dt)),
		    p_end_dt                   =>    l_d_expiry_date,
		    p_authorising_person_id    =>    NULL,
		    p_comments                 =>    NULL,
		    p_spo_course_cd            =>    NULL,
		    p_spo_sequence_number      =>    NULL,
		    p_cal_type                 =>    NULL,
		    p_sequence_number          =>    NULL,
		    p_auth_resp_id             =>    NULL,
		    p_external_reference       =>    l_external_ref,
		    p_message_name             =>    l_message_name,
		    p_message_string           =>    l_message_string
	       );

	       IF (l_message_name IS NULL AND l_message_string IS NULL ) THEN
	            --Hold was applied successfully

                    resultout := 'COMPLETE:S';

		    --raise the event to communicate it to the external system
                    raise_success_event(l_person_number, l_hold_type, l_start_dt, l_expiry_date);

   	            return;

	       ELSE

	            --Hold was NOT applied successfully
		    Wf_Engine.SetItemAttrText(
			    ItemType  =>  itemtype,
			    ItemKey   =>  itemkey,
			    aname     =>  'P_ERROR',
			    avalue    =>  l_message_name || ',' || l_message_string
		    );
		    resultout := 'COMPLETE:F';
		    return;
	       END IF;

	  ELSE
	       CLOSE c_hold_alrdy_exst;
	       --release the hold

	     -- ELSIF (( l_exist_exp_dt IS NULL) AND (l_expiry_date IS NOT NULL)) THEN
	     -- this is the case where there exists a hold of the same type and is NOT end date
	     -- and the user is trying to apply the similar hold on a different dates and is providing an exipry for the new hold.
	     -- this is NOT allowed.
	     -- in the TBH this error is trapped only when inserting and exp_dt null, but explicitly trapped in the form
	     -- hence trapping it here...SSAWHNEY

	     IF IGS_EN_VAL_PEN.enrp_val_pen_open (
                     l_student_rec.person_id,
                     l_hold_type,
                     igs_ge_date.igsdate(igs_ge_date.igschar(l_start_dt)),
                     v_message_name) = FALSE THEN

                     IF v_message_name IS NOT NULL then


                        l_error :='IGS_EN_ENCMBR_HAS_SPECIFIED';
			message_get(l_error,l_message_name);
			Wf_Engine.SetItemAttrText(
					ItemType  =>  itemtype,
					ItemKey   =>  itemkey,
					aname     =>  'P_ERROR',
					avalue    =>  l_message_name
					 );
					resultout := 'COMPLETE:F';
					return;
                    END IF;
              END IF;



               --Before releasing check the end date with the sysdate
	     IF l_expiry_date IS NOT NULL THEN
               IF igs_ge_date.igsdate(igs_ge_date.igschar(l_expiry_date)) < TRUNC(SYSDATE) THEN
	       	    l_error :='IGS_EN_DT_NOT_LT_CURR_DT';
	            message_get(l_error,l_message_name);
		    Wf_Engine.SetItemAttrText(
			    ItemType  =>  itemtype,
			    ItemKey   =>  itemkey,
			    aname     =>  'P_ERROR',
			    avalue    =>  l_message_name
		    );
		    resultout := 'COMPLETE:F';
		    return;
	       ELSIF igs_ge_date.igsdate(igs_ge_date.igschar(l_expiry_date)) < igs_ge_date.igsdate(igs_ge_date.igschar(l_start_dt))  THEN
		    l_error := 'IGS_EN_EXPDT_GE_STDT';
	            message_get(l_error,l_message_name);
		    Wf_Engine.SetItemAttrText(
			    ItemType  =>  itemtype,
			    ItemKey   =>  itemkey,
			    aname     =>  'P_ERROR',
			    avalue    =>  l_message_name
		    );
		    resultout := 'COMPLETE:F';
		    return;
	       END IF;

             -- else trying to make the expiry date of a hold already set to NULL
             ELSIF l_exist_exp_dt IS NOT NULL THEN
	            l_error :='IGS_PE_EXP_DATE_NT_NULL';
	            message_get(l_error,l_message_name);
		    Wf_Engine.SetItemAttrText(
			    ItemType  =>  itemtype,
			    ItemKey   =>  itemkey,
			    aname     =>  'P_ERROR',
			    avalue    =>  l_message_name
		    );
		    resultout := 'COMPLETE:F';
		    return;
             -- ie, the expiry date is passed BUT there exists a similar hold on the student with same start date AND OPEN.
	     -- need to trap this here, as it was by passing all and going into release hold, which raises an error invalid parameter combo
	     -- which will not make much sense for the user.

	     ELSIF (( l_exist_exp_dt IS NULL) AND (l_expiry_date IS NULL)) THEN
                    l_error :='IGS_GE_RECORD_ALREADY_EXISTS';
	            message_get(l_error,l_message_name);
		    Wf_Engine.SetItemAttrText(
			    ItemType  =>  itemtype,
			    ItemKey   =>  itemkey,
			    aname     =>  'P_ERROR',
			    avalue    =>  l_message_name
		    );
		    resultout := 'COMPLETE:F';
		    return;


	     END IF;

               OPEN c_external_hold_exst(l_student_rec.person_id,l_hold_type,igs_ge_date.igsdate(igs_ge_date.igschar(l_start_dt)),l_external_ref);
   	       FETCH c_external_hold_exst INTO l_exist;

	       IF c_external_hold_exst%NOTFOUND THEN
	            -- External reference does not match
		    l_error := 'IGS_PE_EXT_REF_MISMATCH';
	            message_get(l_error,l_message_name);
		    CLOSE c_external_hold_exst;
		    Wf_Engine.SetItemAttrText(
			    ItemType  =>  itemtype,
			    ItemKey   =>  itemkey,
			    aname     =>  'P_ERROR',
			    avalue    =>  l_message_name
		    );
		    resultout := 'COMPLETE:F';
		    return;
	       ELSE
	            -- External reference matches

   		    CLOSE c_external_hold_exst;
	       END IF;


	       BEGIN
	       l_message_name := NULL;

	            igs_pe_gen_001.release_hold
	            (
	                    p_resp_id		=>	NULL,
			    p_fnd_user_id	=>	NULL,
			    p_person_id         =>	l_student_rec.person_id,
			    p_encumbrance_type  =>      l_hold_type,
			    p_start_dt          =>      igs_ge_date.igsdate(igs_ge_date.igschar(l_start_dt)),
			    p_expiry_dt         =>      igs_ge_date.igsdate(igs_ge_date.igschar(l_expiry_date)),
			    p_override_resp     =>      'X',
			    p_message_name      =>      l_message_name
	            );

                    IF l_message_name IS NULL THEN
		      --commit;
  	              --Hold was released successfully
                       resultout := 'COMPLETE:S';

		       --raise the event to communicate it to the external system
                       raise_success_event(l_person_number, l_hold_type, l_start_dt, l_expiry_date);

   	               return;
	            END IF;
	       EXCEPTION

	            WHEN OTHERS THEN
                    --always overriding the value of the l_message_name as it will always be present on the stack
		    -- any TBH excpetion will be present on the stack so get it from there.
		    IGS_GE_MSG_STACK.GET(-1, 'F', l_message_name, ln_msg_index);

		    IF l_message_name IS NOT NULL THEN

			    --Hold was NOT released successfully
			    Wf_Engine.SetItemAttrText(
				    ItemType  =>  itemtype,
				    ItemKey   =>  itemkey,
				    aname     =>  'P_ERROR',
				    avalue    =>  l_message_name
			    );
			    resultout := 'COMPLETE:F';
			    return;
		    ELSE
		           l_error := 'IGS_GE_UNHANDLED_EXCEPTION';
	                   message_get(l_error,l_message_name);
			    Wf_Engine.SetItemAttrText(
				    ItemType  =>  itemtype,
				    ItemKey   =>  itemkey,
				    aname     =>  'P_ERROR',
				    avalue    =>  l_message_name
			    );
			    resultout := 'COMPLETE:F';
			    return;
		    END IF;

	       END;
	  END IF;
     END IF;  -- funcmode is RUN

     IF funcmode = 'CANCEL' THEN

          resultout := 'COMPLETE' ;
          return;
     END IF;


 EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('IGS_PE_GEN_002', 'IGSPE003' , itemtype, itemkey, to_char(actid), funcmode,'ERROR');
          RAISE ;
 END Receive_External_Hold;

FUNCTION get_hr_installed
  RETURN VARCHAR2 AS
  /*************************************************************
  Created By :npalanis
  Date Created By :10-JUN-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  skpandey        12-JAN-2006    Bug#4937960
                                 Changed hr_record cursor definition to optimize query
  ssawhney        17 Aug         3690580, for perf reasons changed cursor hr_record.
  ***************************************************************/
  CURSOR hr_status IS
  SELECT STATUS FROM
  FND_PRODUCT_INSTALLATIONS
  WHERE APPLICATION_ID = 800;

  -- ssawhney for perf reasons, using pk>1 rather than rownum
  CURSOR hr_record IS
  SELECT 'Y' FROM PER_ALL_ASSIGNMENTS_F WHERE assignment_id > 1 AND ROWNUM = 1;

  l_status FND_PRODUCT_INSTALLATIONS.STATUS%TYPE;
  l_var VARCHAR2(1);
  BEGIN

  OPEN hr_status;
  FETCH hr_status INTO l_status;
  CLOSE hr_status;

  IF l_status = 'I' THEN
     OPEN hr_record;
     FETCH hr_record INTO l_var;
     IF hr_record%FOUND THEN
        CLOSE hr_record;
        RETURN 'Y';
     ELSE
        CLOSE hr_record;
        RETURN 'N';
     END IF;
  ELSE
     RETURN 'N';
  END IF;
 END get_hr_installed;

 FUNCTION get_active_emp_cat(P_PERSON_ID IN IGS_PE_TYP_INSTANCES_ALL.PERSON_ID%TYPE)
RETURN VARCHAR2 IS
  /*************************************************************
  Created By :npalanis
  Date Created By :10-JUN-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR hr_emp_cat(cp_person_id igs_pe_typ_instances_all.person_id%TYPE) IS
  SELECT emplmnt_category_code FROM
  IGS_PE_HR_EMP_CAT_V
  WHERE person_id = cp_person_id;

  CURSOR typ_emp_cat(cp_person_id igs_pe_typ_instances_all.person_id%TYPE) IS
  SELECT emplmnt_category_code FROM
  IGS_PE_TYP_EMP_CAT_V
  WHERE person_id = cp_person_id;

  l_emplmnt_category_code igs_pe_typ_emp_cat_v.emplmnt_category_code%TYPE;
BEGIN
  IF IGS_PE_GEN_002.GET_HR_INSTALLED = 'Y' THEN
     OPEN hr_emp_cat(p_person_id);
     FETCH hr_emp_cat INTO l_emplmnt_category_code;
     CLOSE hr_emp_cat;
     RETURN l_emplmnt_category_code;
  ELSIF IGS_PE_GEN_002.GET_HR_INSTALLED = 'N'  THEN
     OPEN typ_emp_cat(p_person_id);
     FETCH typ_emp_cat INTO l_emplmnt_category_code;
     CLOSE typ_emp_cat;
     RETURN l_emplmnt_category_code;
  END IF;
END get_active_emp_cat;

END igs_pe_gen_002;

/
