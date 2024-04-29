--------------------------------------------------------
--  DDL for Package Body IGS_PE_USERID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_USERID_PKG" AS
/* $Header: IGSPE11B.pls 120.14 2006/09/21 13:06:35 gmaheswa ship $ */

/* +=======================================================================+
   |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
   |                         All rights reserved.                          |
   +=======================================================================+
   |  NAME                                                                 |
   |    IGSVTFPB.pls                                                       |
   |                                                                       |
   |  DESCRIPTION                                                          |
   |    This package provides service functions and procedures to          |
   |   support user name generation WF                                     |
   |                                                                       |
   |  NOTES                                                                |
   |                                                                       |
   |  DEPENDENCIES                                                         |
   |                                                                       |
   |  USAGE                                                                |
   |                                                                       |
   |  HISTORY                                                              |
   |    04-APR-2001  A Tereshenkov Created                                 |
   |    Dec 19, 02   Sreedhar changed the process_group_id proc to add the |
   |                 person_id as cursor paramter to c_email_info and      |
   |                 c_fnd_user_present. Also changed the c_email_info     |
   |                 to pick up the primary email address. bug 2712258     |
   |                                                                       |
   |    27-JAN-2003  pkpatel (changed for Bug No 2753318, 2753728 )
   |                 Create_Fnd_User, copy the password back to the workflow
   |                 Generate_User, Added the validation that the password if entered should be at least 5 characters.
   |				 Generate_Password, added the call of fnd_user_pkg.update_user if the primary email of the person has been changed.
   |				 Create_Party, IGS_PE_TYP_INSTANCES_PKG.INSERT_row was commented
   |    24-APR-2003  pkpatel   Bug No: 2908802
   |                           Modified Create_Fnd_User procedure
   |    01-jul-2003  KUMMA,    2803555, Added the code to set the tokens for message IGS_PE_WF_EXISTS
   |                           added statement to add the blank lines between successive messages inside procedure Process_Group_ID
   |    23-JUL-2003  asbala    Bug No:2667343 Replaced Hard coded strings populating l_msg_data and errbuf with
   |                           new messages
   |    28-OCT-2003  ssaleem   Bug : 3198795 Part of the Dynamic/Static Person Groups modifications,
   |			       Procedure Process_Group_ID is modified.
   |    14-DEC-2004  pkpatel   Bug 3316053 (Modified the logic for person number/alt id in generate_user.
   |                           Set and Retrieve the new workflow item attribute in generate_user and ceate_party procedures.
   |    23-APR-2003  asbala    3528702: Modified cursor c_resp. The job can now assign responsibilities other than those mapped too 'OTHER'.
   |    23-JUN-2003  ssawhney  bug 3713297 ..need to always select primary address and primary will always be ACTIVE
   |    13-Apr-2005  ssaleem   Bug 4293911 Fnd User customer Id  replaced with person
   |			       party id
   |    21-SEP-2005  skpandey  Bug: 3663505
   |                           Description: Added ATTRIBUTES 21 TO 24 in create_party procedure to store additional information
   |    19-Jan-06    gmaheswa  4869740: random number generators: dbms_random package is replaced by FND_CRYPTO for generating random numbers.
   |    02-FEB-2006  skpandey  Bug#4937960: Changed call from igs_get_dynamic_sql to get_dynamic_sql as a part of literal fix
   |    04-May-2006  pkpatel   Bug 5081932(Used the sequence IGS_PE_GEN_USER_S in AUTO_GENERATE_USERNAME method to pass unique value to the event_key)
   |    17-May-2006  gmaheswa  Bug#5250820, modified Validate_Person to remove the Mutual Exclusive logic of Party number and prefered alternate id
                               Also modified Dup_Person_Check to process applicant, alumni  match not found condition, Multiple match.
			       Also created new function process_alumni_nomatch_event,generate_party_number.
			       introduced validate_password logic
   |	21-Sep-2006  gmaheswa  Bug 5546771 Modified generate_password logic to repeat for 500 times.
   +=======================================================================+  */

 l_prog_label CONSTANT VARCHAR2(500) :='igs.plsql.igs_pe_userid_pkg';
 l_label VARCHAR2(4000);
 l_debug_str VARCHAR2(32000);


FUNCTION Generate_Message RETURN VARCHAR2
IS
l_cur                     NUMBER;
l_msg_count               NUMBER ;
l_msg_data                VARCHAR2(32000) ;

BEGIN


  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                              p_data  => l_msg_data );

  IF l_msg_count >0 THEN
     l_msg_data :='';

     FOR l_cur IN 1..l_msg_count LOOP
        l_msg_data :=l_msg_data||' '||l_cur||' '||FND_MSG_PUB.GET(l_cur,FND_API.G_FALSE);
     END LOOP;
  ELSE
     l_msg_data := FND_MESSAGE.GET_STRING('IGS', 'IGS_PE_ERR_STACK_NO_DATA');
  END IF;

  RETURN l_msg_data;


END Generate_Message;

FUNCTION generate_password (
  p_username IN VARCHAR2
  ) RETURN VARCHAR2 IS

  l_result varchar2(10);
  v_counter BINARY_INTEGER := 1;
  l_password_len int := 6;
  x_password     varchar2(40);
  ascii_offset   int := 65;
  l_profile_pwd_len int;

BEGIN
   l_profile_pwd_len := FND_PROFILE.VALUE('SIGNON_PASSWORD_LENGTH');
   IF (l_profile_pwd_len IS NOT NULL) THEN
       IF l_profile_pwd_len > l_password_len THEN
           l_password_len :=  l_profile_pwd_len;
       END IF;
   END IF;

   -- using the profile, determine the length of the random number
   LOOP
       x_password := null;
       -- generate a random number to determine where to use an alphabet or a
       -- numeric character for a given position in the password
       FOR j IN 1..l_password_len LOOP
          IF (MOD(ABS(FND_CRYPTO.RANDOMNUMBER),2) = 1) THEN
		-- generate number
		x_password := x_password || MOD(ABS(FND_CRYPTO.SMALLRANDOMNUMBER),10);
	  ELSE
		-- generate character
		x_password := x_password || FND_GLOBAL.LOCAL_CHR(MOD(ABS(FND_CRYPTO.SMALLRANDOMNUMBER),26)
		    + ascii_offset);
	  END IF;
       END LOOP;
       -- loop till password clears the validations
       l_result := FND_WEB_SEC.VALIDATE_PASSWORD (p_username, x_password);
       v_counter := v_counter + 1;
       EXIT WHEN ((l_result = 'Y') OR (v_counter > 501));
   END LOOP;

   IF (v_counter > 500) THEN
      -- return last generated passowrd conacteneted with 101 if generated password is not valid for 1000 times
      RETURN x_password||'501';
   ELSE
        RETURN x_password;
   END IF;

END generate_password;

/*
 This procedure provides the default functionality for user name generation
 */

FUNCTION GENERATE_USERNAME (
 P_SUBSCRIPTION_GUID	in	raw,
 P_EVENT		in out NOCOPY	wf_event_t
) return varchar2 is
------------------------------------------------------------------------------
l_result	varchar2(100);

l_wf_name                 VARCHAR2(8)   ;
l_process_name            VARCHAR2(255) ;
l_item_key                VARCHAR(255);
l_party_id                hz_parties.party_id%TYPE;
--skpandey Bug#4937960, changed c_name cursor definition to optimize query
CURSOR c_name(cp_party_id hz_parties.party_id%TYPE) IS
SELECT upper(substr(person_last_name,1,12)||'.'||substr(person_first_name,1,14))
FROM hz_parties
WHERE party_id = cp_party_id;

l_name                    VARCHAR2(30);
l_user_name		  FND_USER.USER_NAME%TYPE;
l_person_number		  HZ_PARTIES.PARTY_NUMBER%TYPE;
l_first_name		  HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
l_last_name		  HZ_PARTIES. PERSON_LAST_NAME%TYPE;
l_middle_name		  HZ_PARTIES. PERSON_MIDDLE_NAME%TYPE;
l_pref_name		  HZ_PARTIES.KNOWN_AS%TYPE;
l_pref_alt_id		  IGS_PE_ALT_PERS_ID.API_PERSON_ID%TYPE;
l_title			  HZ_PERSON_PROFILES.PERSON_TITLE%TYPE;
l_prefix		  HZ_PERSON_PROFILES.PERSON_PRE_NAME_ADJUNCT%TYPE;
l_suffix		  HZ_PARTIES.PERSON_NAME_SUFFIX%TYPE;
l_gender		  HZ_PERSON_PROFILES.GENDER%TYPE;
l_birth_date		  DATE;
l_email_address	          HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
l_email_format		  HZ_CONTACT_POINTS.EMAIL_FORMAT%TYPE;
l_test_user_name	  FND_USER.USER_NAME%TYPE;
l_number		  NUMBER;
l_init_user_name	  FND_USER.USER_NAME%TYPE;
l_count			  NUMBER := 0;
BEGIN
  l_wf_name                    :='IGSPEGEN';
  l_process_name               :='MAIN_PROCESS';

  l_item_key := P_EVENT.GetValueForParameter('ITEM_KEY');
  l_party_id := P_EVENT.GetValueForParameter('PARTY_ID');

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
         l_label := 'igs.plsql.igs_pe_userid_pkg.GENERATE_USERNAME';
         l_debug_str := 'Begin for Party ID:'||l_party_id;
         fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
  END IF;

  /*
   If l_party_id IS null that means the event is raised for Self-Service Registration
   If l_party_id IS not Null then that means the event is raised from the Batch user creation process
  */
  IF l_party_id IS NULL THEN

          l_user_name           :=  P_EVENT.GetValueForParameter('USER_NAME');
          l_person_number       :=  P_EVENT.GetValueForParameter('PERSON_NUMBER');
          l_first_name          :=  P_EVENT.GetValueForParameter('GIVEN_NAME');
          l_last_name           :=  P_EVENT.GetValueForParameter('SURNAME');
          l_middle_name         :=  P_EVENT.GetValueForParameter('MIDDLE_NAME');
          l_pref_name           :=  P_EVENT.GetValueForParameter('PREF_NAME');
          l_pref_alt_id         :=  P_EVENT.GetValueForParameter('ALT_ID');
          l_title               :=  P_EVENT.GetValueForParameter('TITLE');
          l_prefix              :=  P_EVENT.GetValueForParameter('PREFIX');
          l_suffix              :=  P_EVENT.GetValueForParameter('SUFFIX');
          l_gender              :=  P_EVENT.GetValueForParameter('GENDER');
          l_birth_date          :=  P_EVENT.GetValueForParameter('BIRTH_DATE');
          l_email_address       :=  P_EVENT.GetValueForParameter('USER_EMAIL');
          l_email_format        :=  P_EVENT.GetValueForParameter('EMAIL_FORMAT');
          l_init_user_name := UPPER(SUBSTR(l_last_name,1,12)||'.'||SUBSTR(l_first_name,1,14));
  ELSE
    OPEN c_name(l_party_id);
    FETCH c_name INTO l_init_user_name;
    CLOSE c_name;
  END IF;

  l_init_user_name := replace(l_init_user_name, '/','');
  l_init_user_name := replace(l_init_user_name, '"','');
  l_init_user_name := replace(l_init_user_name, '(','');
  l_init_user_name := replace(l_init_user_name, ')','');
  l_init_user_name := replace(l_init_user_name, '*','');
  l_init_user_name := replace(l_init_user_name, '+','');
  l_init_user_name := replace(l_init_user_name, ',','');
  l_init_user_name := replace(l_init_user_name, ';','');
  l_init_user_name := replace(l_init_user_name, '<','');
  l_init_user_name := replace(l_init_user_name, '>','');
  l_init_user_name := replace(l_init_user_name, '\','');
  l_init_user_name := replace(l_init_user_name, '~','');
  l_init_user_name := replace(l_init_user_name, ':','');

  l_user_name := l_init_user_name;
  l_test_user_name := fnd_user_pkg.TestUserName(l_user_name);

  WHILE (l_test_user_name <> fnd_user_pkg.USER_OK_CREATE AND l_count <= 100)
  LOOP
	l_number := FND_CRYPTO.RANDOMNUMBER;
        IF l_number<0 THEN
            l_number:=-l_number;
        END IF;
        l_user_name := SUBSTR(l_init_user_name||SUBSTR(l_number,1,5),1,100);
        l_test_user_name := fnd_user_pkg.TestUserName(l_user_name);
        l_count := l_count+1;
  END LOOP;

  IF (l_count > 100) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_PE_UNAME_GEN_FAIL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_party_id IS NULL THEN
       IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	    l_label := 'igs.plsql.igs_pe_userid_pkg.GENERATE_USERNAME';
	    l_debug_str := 'Self Service Reg, User Name: '||l_user_name;
            fnd_log.string(fnd_log.level_procedure,l_label,l_debug_str);
       END IF;
       p_event.addParametertoList('USER_NAME', l_user_name);
  ELSE
      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
             l_label := 'igs.plsql.igs_pe_userid_pkg.GENERATE_USERNAME';
             l_debug_str := 'Batch user creation, User Name: '||l_user_name;
             fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
      END IF;

     wf_engine.SetItemAttrText(l_wf_name,l_item_key,'USER_NAME',l_user_name);
  END IF;

  l_result := wf_rule.default_rule(p_subscription_guid, p_event);

  return(l_result);

EXCEPTION
  WHEN OTHERS THEN
   IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
         l_label := 'igs.plsql.igs_pe_userid_pkg.GENERATE_USERNAME';
         l_debug_str := 'EXCEPTION: '||SQLERRM;
         fnd_log.string(fnd_log.level_procedure,l_label,l_debug_str);
   END IF;

  WF_CORE.CONTEXT('IGS_PE_USERID_PKG','GENERATE_USERNAME',p_event.event_name,p_event.event_key, sqlerrm,sqlcode);
  wf_event.setErrorInfo(p_event,'ERROR');
  RAISE;
  return('ERROR');
end;



PROCEDURE Check_Setup
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)IS
 l_api_name                VARCHAR2(30)    ;
 l_return_status           VARCHAR2(1);

  l_count                   NUMBER(9);

/* Select not defined person types */
 CURSOR c_setup IS
  SELECT 1
    FROM igs_lookup_values
   WHERE lookup_type = 'SYSTEM_PERSON_TYPES'
     AND lookup_code NOT IN
       ( SELECT s_person_type
           FROM igs_pe_typ_rsp_dflt );


BEGIN
 l_api_name   := 'Check_Setup' ;


  IF ( funcmode = 'RUN'  ) THEN

    OPEN c_setup;
    FETCH c_setup INTO l_count;

    IF c_setup%FOUND THEN

      resultout := 'COMPLETE:N' ;

    ELSE

      resultout := 'COMPLETE:Y' ;

    END IF;

    CLOSE c_setup;
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    wf_core.context('IGS_PE_USERID_PKG', l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode,Generate_Message());
    RAISE ;

END Check_Setup ;

PROCEDURE get_person_number(p_person_number OUT NOCOPY VARCHAR2)
IS

 l_return_status       VARCHAR2(1);
 l_count               NUMBER(9);
 l_event_t             wf_event_t;
 l_parameter_list_t    wf_parameter_list_t;
 l_wf_name             VARCHAR2(8)   ;
 itemkey               VARCHAR2(100);

BEGIN
    itemkey :=substr(FND_CRYPTO.RANDOMNUMBER,1,5);
    l_wf_name                    :='IGSPEGEN';
    -- initialize the parameter list.
    wf_event_t.Initialize(l_event_t);

    -- set the parameters. This parameter is added with null value to initialize the parameter list.
    wf_event.AddParameterToList ( p_name => 'PARAMETER_DUMMY',
  			    		p_value => NULL,
				        p_parameterlist  => l_parameter_list_t);

    WF_EVENT.RAISE3(p_event_name => 'oracle.apps.igs.pe.party_number.generate',
		     p_event_key  => 'GEN_PARTY_NUM'||itemkey,
		     p_event_data => NULL,
		     p_parameter_list => l_parameter_list_t,
		     p_send_date  => sysdate
    );
    p_person_number :=  UPPER(WF_EVENT.getValueForParameter('PERSON_NUMBER',l_parameter_list_t));
    l_parameter_list_t.delete;

END get_person_number ;

FUNCTION generate_party_number (
 P_SUBSCRIPTION_GUID	in	raw,
 P_EVENT		in out NOCOPY	wf_event_t
) return varchar2 is
   /*
      ||  Created By : GMAHESWA
      ||  Created On : 4-May-2006
      ||  Purpose : to generate party number when HZ: Generate Party Number profile is Set to 'N'
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
   */

CURSOR c_party_number(cp_party_num VARCHAR2) IS
SELECT 'X'
FROM hz_parties
WHERE party_number = cp_party_num;

l_party_found VARCHAR2(1);
l_person_number VARCHAR2(30);
l_count         NUMBER := 0;
l_result	VARCHAR2(100);

BEGIN
l_person_number := 'IGS-'||SUBSTR(FND_CRYPTO.RANDOMNUMBER,1,5);

OPEN c_party_number(l_person_number);
FETCH c_party_number INTO l_party_found;
CLOSE c_party_number;
WHILE (l_party_found IS NOT NULL AND l_count <= 10)
LOOP
    l_party_found := NULL;
    l_person_number := 'IGS-'||SUBSTR(FND_CRYPTO.RANDOMNUMBER,1,5);
    l_count := l_count+1;
    OPEN c_party_number(l_person_number);
    FETCH c_party_number INTO l_party_found;
    CLOSE c_party_number;
END LOOP;

IF l_count > 10 THEN
	l_person_number := NULL;
END IF;
P_EVENT.addParametertoList('PERSON_NUMBER', l_person_number);

l_result := wf_rule.default_rule(p_subscription_guid, p_event);
RETURN(l_result);

EXCEPTION
  WHEN OTHERS THEN
  WF_CORE.CONTEXT('IGS_PE_USERID_PKG','GENERATE_PARTY_NUMBER',p_event.event_name,p_event.event_key, sqlerrm,sqlcode);
  wf_event.setErrorInfo(p_event,'ERROR');
  RAISE;
  RETURN('ERROR');
END generate_party_number;

-- Stubbed as part of UMX uptake
PROCEDURE Create_Party
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS

BEGIN

   NULL;

END Create_Party ;

PROCEDURE Create_Fnd_User
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)  IS
   /*
      ||  Created By :
      ||  Created On :
      ||  Purpose :
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      ||  pkpatel        15-JAN-2003     Bug NO: 2753728
      ||                                 Passed the password back to the workflow once it is generated.
      ||  pkpatel        24-APR-2003     Bug No: 2908802
      ||                                 Modified the cursor c_resp for performance. Since the responsibility to be attached are the only mapped to 'OTHER'.
      ||                                 No need to verify the existing responsibility attached.
      ||  asbala         23-APR-2003     3528702: Modified cursor c_resp. The job can now assign responsibilities other than those mapped too 'OTHER'.
      ||                                 This bug resulted in a regression in funtionality.
      ||                                 Combinedly c_get_Sys_typ, c_resp and c_get_assigned_resp achieve the same functionality as c_resp did before 2908802 changes.
      ||  gmaheswa       19-Jan-06       4869740: depreciated api's: fnd_user_pvt package is replaced by fnd_user_pkg.
   */
 l_api_name                CONSTANT VARCHAR2(30)   := 'Create_Fnd_User' ;
 l_return_status           VARCHAR2(1);
 l_user_id                 fnd_user.user_id%TYPE;
 l_user_name               VARCHAR2(255);
 l_user_password           VARCHAR2(255);
 l_email_address           VARCHAR2(255);
 l_party_id                hz_parties.party_id%TYPE;

BEGIN


  IF ( funcmode = 'RUN'  ) THEN

    l_user_name := upper(wf_engine.GetItemAttrText(itemtype,itemkey,'USER_NAME'  ));
    l_user_password := wf_engine.GetItemAttrText(itemtype,itemkey,'USER_PASSWORD'  );
    l_email_address := wf_engine.GetItemAttrText(itemtype,itemkey,'USER_EMAIL' );
    l_party_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'PARTY_ID' );

    IF l_user_password IS NULL OR length(l_user_password) <5 THEN
      l_user_password := generate_password(l_user_name);
    END IF;

    -- Pass the password back to the workflow.
    wf_engine.SetItemAttrText(itemtype,itemkey,'USER_PASSWORD', l_user_password );

	-- Create a user
    l_user_id := fnd_user_pkg.CreateUserIdParty (
			  x_user_name                  => l_user_name,
			  x_owner                      => 'CUST',
			  x_unencrypted_password       => l_user_password,
			  x_email_address              => l_email_address,
			  x_person_party_id            => l_party_id
		 );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
     END IF;

-- This logic assigns responsibilities to the user depending on the person_types he is assigned.

     IF l_party_id IS NOT NULL THEN

       assign_responsibility(l_party_id, l_user_id);

     END IF;

    UPDATE igs_pe_hz_parties
    SET oracle_username =l_user_name
    WHERE party_id = l_party_id;

    resultout := 'COMPLETE:S' ;
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    wf_core.context('IGS_PE_USERID_PKG', l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode,Generate_Message(),l_user_name,sqlerrm,fnd_message.get);
    RAISE ;

END Create_Fnd_User ;


-- Stubbed as part of UMX uptake
PROCEDURE Validate_Username
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS
BEGIN

   NULL;

END Validate_Username ;



PROCEDURE Generate_User
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 ,
  p_commit                    IN       VARCHAR2 ,
  p_validation_level          IN       NUMBER   ,
  x_return_status             OUT NOCOPY      VARCHAR2 ,
  x_msg_count                 OUT NOCOPY      NUMBER   ,
  x_msg_data                  OUT NOCOPY      VARCHAR2 ,
  p_title                     IN       VARCHAR2 ,
  p_number                    IN       VARCHAR2 ,
  p_prefix                    IN       VARCHAR2 ,
  p_alt_id                    IN       VARCHAR2 ,
  p_given_name                IN       VARCHAR2 ,
  p_pref_name                 IN       VARCHAR2 ,
  p_middle_name               IN       VARCHAR2 ,
  p_gender                    IN       VARCHAR2 ,
  p_surname                   IN       VARCHAR2 ,
  p_birth                     IN       VARCHAR2 ,
  p_suffix                    IN       VARCHAR2 ,
  p_user_name                 IN       VARCHAR2 ,
  p_user_password             IN       VARCHAR2 ,
  p_email_format              IN       VARCHAR2 ,
  p_email_address             IN       VARCHAR2
)
IS
/******************************************************************
      Created By         :
      Date Created By    :
      Purpose            : Combined call to all Inquiry related procedure
      Known limitations,
      enhancements,
      remarks            :
      Change History
      Who      When         What
      pkpatel  21-JAN-2003  Bug No: 2753728
	                        Added the validation that the password if entered should be at least 5 characters.
      pkpatel  6-JAn-2004   Bug No: 3316053 (Modified the validation for passing Person Number/Preferred Alternate ID)
      gmaheswa 23-Jan-2006  Bug: 4869740. Modified cursor c_hz_parties to use igs_pe_pers_base_v instead of igs_pe_person_v. Performan issue.
******************************************************************/
  l_api_name                CONSTANT VARCHAR2(30)   := 'Generate_User' ;
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_item_key                VARCHAR2(255);
  l_party_id                hz_parties.party_id%TYPE;
  l_user_name               VARCHAR2(30);
  l_wf_name                 VARCHAR2(8)   ;
  l_process_name            VARCHAR2(255) ;

  l_local_inst  VARCHAR2(30) ;
  l_user_id     NUMBER;
  l_test_user_name          pls_integer;

  --Find if there is an incomplete request filed
  CURSOR c_check_wf (cp_wf_name VARCHAR2, cp_item_key VARCHAR2) IS
   SELECT 1
     FROM wf_items
    WHERE item_type = item_type
      AND item_key like cp_item_key||'%'
      AND END_DATE IS NULL;

  -- Find the unique name
  CURSOR c_get_wf_name(cp_wf_name VARCHAR2, cp_item_key VARCHAR2) IS
   SELECT l_item_key||(max(NVL(substr(item_key,length(l_item_key)+1,10),0))+1)
     FROM wf_items
    WHERE item_type = cp_wf_name
      AND item_key like cp_item_key||'%' ;

  CURSOR c_hz_parties(cp_person_number VARCHAR2) IS
  SELECT party_id
  FROM hz_parties
  WHERE party_number = cp_person_number;

   CURSOR c_inst(cp_party_number hz_parties.party_number%TYPE) IS
   SELECT party_name
     FROM igs_or_inst_org_base_v
    WHERE party_number = cp_party_number
    AND   inst_org_ind = 'I';

 BEGIN
  l_wf_name                 :='IGSPEGEN';
  l_process_name            :='MAIN_PROCESS';
  l_user_name               := UPPER(p_user_name);
  l_local_inst              := FND_PROFILE.VALUE('IGS_OR_LOCAL_INST');

  SAVEPOINT Generate_User;
  --
  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Create a unique WF process key

  l_item_key := p_given_name||'.'|| p_surname||'.'||p_birth||'.'||NVL(p_alt_id,p_number)||'.'||p_gender;
  -- Check if the process with this name exists:
  OPEN c_check_wf(l_wf_name, l_item_key);
  FETCH c_check_wf INTO l_party_id;
  CLOSE c_check_wf;

  IF l_party_id IS NOT NULL THEN

    -- Active WF for the given user found
    --kumma, 2803555, Added code to set the tokens for the following message

    FND_MESSAGE.SET_NAME('IGS', 'IGS_PE_WF_EXISTS');
    FND_MESSAGE.SET_TOKEN('GIVEN_NAME', p_given_name);
    FND_MESSAGE.SET_TOKEN('LAST_NAME', p_surname);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

  END IF;

  --Generate WF name

  OPEN c_get_wf_name(l_wf_name, l_item_key);
  FETCH c_get_wf_name INTO l_item_key;
  CLOSE c_get_wf_name;


  -- Check HZ parties
  OPEN c_hz_parties(p_number);
  FETCH c_hz_parties INTO l_party_id;
  CLOSE c_hz_parties;

  --Everything is ok - proceed to submition

  wf_engine.CreateProcess ( ItemType => l_wf_name,
                            ItemKey  => l_item_key,
                            Process  => l_process_name );


  WF_Engine.SetItemUserKey
  (
     ItemType => l_wf_name        ,
     ItemKey  => l_item_key       ,
     UserKey  => l_item_key
  );


  FOR c_inst_rec IN c_inst(l_local_inst) LOOP
    wf_engine.SetItemAttrText(l_wf_name,l_item_key,'INSTITUTION_NAME', c_inst_rec.party_name );
  END LOOP;

  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'TITLE', p_title );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'PREFIX', p_prefix );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'ALT_ID', p_alt_id );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'PERSON_NUMBER', p_number );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'GIVEN_NAME', p_given_name );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'PREF_NAME', p_pref_name );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'MIDDLE_NAME', p_middle_name );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'GENDER', p_gender );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'SURNAME', p_surname );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'BIRTH_DATE', p_birth );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'SUFFIX', p_suffix );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'USER_NAME', l_user_name );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'USER_PASSWORD', p_user_password );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'EMAIL_FORMAT', p_email_format );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'USER_EMAIL', p_email_address );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'ITEM_KEY', l_item_key );
  wf_engine.SetItemAttrNumber(l_wf_name,l_item_key,'PARTY_ID', l_party_id );

  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'APPROVER', FND_PROFILE.VALUE('IGS_PE_USER_APPROVER') );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'EVENTKEY',l_item_key );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'APPROVAL_REQ', NVL(FND_PROFILE.VALUE('IGS_PE_APPROVAL_REQUIRED'),'N') );
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'GENERATE_USER', 'Y'); --NVL(FND_PROFILE.VALUE('IGS_PE_GENERATE_USER'),'N'));
  wf_engine.SetItemAttrText(l_wf_name,l_item_key,'ADMIN_USERNAME',FND_PROFILE.VALUE('IGS_PE_USER_ADMIN'));


  wf_engine.StartProcess ( ItemType => l_wf_name,
                           ItemKey  => l_item_key   );


  COMMIT WORK;


  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     Rollback to Generate_User;
     x_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     Rollback to Generate_User;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

   WHEN OTHERS THEN


       Rollback to Generate_User;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg ('IGS_PE_USERID_PKG', l_api_name);
       END IF;

       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

END Generate_User ;


FUNCTION get_id_name RETURN VARCHAR2
IS

 CURSOR c_id_type IS
  SELECT description
    FROM igs_pe_person_id_typ
   WHERE preferred_ind ='Y';

 l_id_type                 igs_pe_person_id_typ.description%TYPE;


BEGIN

   OPEN c_id_type;
   FETCH c_id_type INTO l_id_type;
   CLOSE c_id_type;

   RETURN l_id_type;

END get_id_name;



PROCEDURE Generate_Password
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 ,
  p_commit                    IN       VARCHAR2 ,
  p_validation_level          IN       NUMBER   ,
  x_return_status             OUT NOCOPY      VARCHAR2 ,
  x_msg_count                 OUT NOCOPY      NUMBER   ,
  x_msg_data                  OUT NOCOPY      VARCHAR2 ,
  p_user_name                 IN       VARCHAR2
)
IS
   /*
      ||  Created By :
      ||  Created On :
      ||  Purpose :
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      ||  pkpatel        23-JAN-2003     Bug NO: 2753318
      ||                                 The fnd user was updated with the primary email address from hz_contact points
      ||                                 so that the mail will go to the person's primary email.
      ||  gmaheswa	 19-Jna-06       4869740: Stubbed
   */
BEGIN
NULL;
END  Generate_Password;

PROCEDURE Process_Group_ID (p_api_version        IN NUMBER,
                            p_init_msg_list      IN VARCHAR2   ,
                            p_commit             IN VARCHAR2   ,
                            p_valid_lvl          IN NUMBER     ,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            p_person_group_id    IN NUMBER
);

/******************************************************************
 Created By         : Don Shellito

 Date Created By    : 27-Jan-2002

 Purpose            : The following procedures are created for the
                      purpose of creating user IDs based upon the
                      Person ID Group that has been chosen by the
                      user of the Concurrent Request.

 remarks            :

 Change History

Who                  When            What
---------------------------------------------------------------
Don Shellito         27-Jan-2002     New Package Created.
gmaheswa	     5-Jan-2006      4869737: Added call to igs_ge_gen_003.set_org_id to disable OSS from R12.
******************************************************************/
PROCEDURE Create_Batch_Users (errbuf        OUT NOCOPY VARCHAR2,
                              retcode       OUT NOCOPY NUMBER,
                              p_group_id     IN NUMBER,
                              p_org_id       IN VARCHAR2
) IS

   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(20000);
   l_error_text        VARCHAR2(20000);
   l_api_name          CONSTANT VARCHAR2(30) := 'Create_Batch_Users';
   l_api_version       NUMBER ;
   l_return_status     VARCHAR2 (1);
   l_group_cd          VARCHAR2(10);

   CURSOR c_person_id_group (cp_group_id NUMBER) IS
      SELECT pe.group_cd
      FROM   igs_pe_persid_group_all   pe
      WHERE  pe.group_id         = cp_group_id
      AND    pe.closed_ind       = 'N'
      AND    pe.create_dt       <= SYSDATE;

BEGIN

   igs_ge_gen_003.set_org_id;
   l_api_version       := 1.0;
--
-- Initialize the message stack for any messages that could be created prior to the processing
--
   Fnd_Msg_Pub.Initialize;

-- If as per customer setup User provisioning(user creation/updation) is not allowed in any instances in any of the
-- product interfaces then log the error message in the log file and return
   IF NOT FND_SSO_MANAGER.IsUserCreateUpdateAllowed THEN

     FND_MESSAGE.SET_NAME('IGS', 'IGS_PE_USER_CRT_N_ALLOWED');
     l_error_text := FND_MESSAGE.GET;
     FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_text);
     errbuf  := l_error_text;
     retcode := 2;

     RETURN;
   END IF;
--
-- Validate that the Person ID group is valid and exists
--
   OPEN c_person_id_group(p_group_id);
   FETCH c_person_id_group
   INTO  l_group_cd;

   IF (c_person_id_group%FOUND) THEN

      CLOSE c_person_id_group;
--
-- Begin the processing of the users in the Group ID given
--
      Process_Group_ID (p_api_version     => l_api_version,
                        p_init_msg_list   => Fnd_Api.G_FALSE,
                        p_commit          => Fnd_Api.G_FALSE,
                        p_valid_lvl       => Fnd_Api.G_VALID_LEVEL_FULL,
                        x_return_status   => l_return_status,
                        p_person_group_id => p_group_id);

--
-- Determine if the processing of the group ID was successful
--
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         errbuf  := FND_MESSAGE.GET_STRING('IGS', 'IGS_PE_NRML_CMPLTN_REQ');
         retcode := 0;
      ELSE
         errbuf  := FND_MESSAGE.GET_STRING('IGS', 'IGS_PE_ERR_ON_COMPLETION');
         retcode := 2;
      END IF;

   ELSE

--
-- Person ID group could not be found.  Log message invalid value given
--
      CLOSE c_person_id_group;
      Fnd_Message.SET_NAME ('IGS','IGS_PE_NO_GROUP_ID');
      Fnd_Message.SET_TOKEN('PERSON_GROUP_ID',p_group_id);
      Fnd_Msg_Pub.ADD;

   END IF;

--
-- Determine if there are messages that need to be output into the request log file
-- for the user to view.
--
   FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

   IF (l_msg_count > 0 AND retcode <> 0 ) THEN

      l_error_text := '';
      FOR l_cur IN 1..l_msg_count LOOP
         l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
         fnd_file.put_line (FND_FILE.LOG, l_error_text);
      END LOOP;

   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Archive_Purge_CBC_Request procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN OTHERS THEN
      errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_PE_ABNRML_CMPLTN_REQ');
      retcode := 2;
      IF (c_person_id_group%ISOPEN) THEN
         CLOSE c_person_id_group;
      END IF;
      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSG_PUB.Add_Exc_Msg ('IGS_PE_USERID_PKG',
                                  l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                  p_data  => l_msg_data );

      IF (l_msg_count > 0) THEN

         l_error_text := '';
         FOR l_cur IN 1..l_msg_count LOOP
            l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
            fnd_file.put_line (FND_FILE.LOG, l_error_text);
         END LOOP;

      END IF;
      RETURN;

END Create_Batch_Users;


PROCEDURE Process_Group_ID (p_api_version        IN NUMBER,
                            p_init_msg_list      IN VARCHAR2   ,
                            p_commit             IN VARCHAR2   ,
                            p_valid_lvl          IN NUMBER     ,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            p_person_group_id    IN NUMBER
) IS

   l_api_name              CONSTANT VARCHAR2(30) := 'Process_Group_ID';
   l_api_version           NUMBER                ;
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(20000);
   l_error_text            VARCHAR2(20000);
   l_email_address         igs_pe_contacts_v.email_address%TYPE;
   l_email_format          igs_pe_contacts_v.email_format%TYPE;
   l_user_name             fnd_user.user_name%TYPE;
   l_user_end_date         fnd_user.end_date%TYPE;

   l_commit                VARCHAR2(100);
   l_init_msg_list         VARCHAR2(100);
   l_valid_lvl             NUMBER;
   -- changed the cursor to pick up only active members of the group

   CURSOR cur_person_grp_desc(cp_group_id igs_pe_persid_group_all.group_id%TYPE) IS
      SELECT description
      FROM   igs_pe_persid_group_all
      WHERE  group_id = cp_group_id;

   l_select VARCHAR2(32767);
   l_str VARCHAR2(32767);
   l_status VARCHAR2(1);
   grp_desc_rec cur_person_grp_desc%ROWTYPE;
   l_group_type IGS_PE_PERSID_GROUP_V.group_type%TYPE;
   TYPE pgroup_query IS REF CURSOR;
   pgroup_refcur pgroup_query;

   TYPE member_type IS RECORD( person_id         igs_pe_person_base_v.person_id%TYPE,
                              person_number     igs_pe_person_base_v.person_number%TYPE,
  			      full_name         igs_pe_person_base_v.full_name%TYPE,
                              sex               igs_pe_person_base_v.gender%TYPE,
     			      birth_date        igs_pe_person_base_v.birth_date%TYPE,
			      title             igs_pe_person_base_v.title%TYPE,
			      surname           igs_pe_person_base_v.last_name%TYPE,
			      given_name        igs_pe_person_base_v.first_name%TYPE,
       			      preferred_name    igs_pe_person_base_v.known_as%TYPE,
			      suffix            igs_pe_person_base_v.suffix%TYPE,
			      prefix            igs_pe_person_base_v.pre_name_adjunct%TYPE,
			      middle_name       igs_pe_person_base_v.middle_name%TYPE,
			      alternate_id      igs_pe_person_id_type_v.api_person_id%TYPE);

   l_member_rec  member_type;

   -- changed the cursor to pick up the primary email and removed the
   -- active clause, since the primary email is always active.

   CURSOR c_email_info(cp_person_id IGS_PE_PERSON.PERSON_ID%TYPE) IS
      SELECT email_address
      FROM   hz_parties
      WHERE  party_id     = cp_person_id;

   CURSOR c_fnd_user_present(p_person_id IGS_PE_PERSON.PERSON_ID%TYPE) IS
      SELECT fnd.user_name,end_date
      FROM   fnd_user      fnd
      WHERE  fnd.person_party_id = p_person_id;

BEGIN
   -- use local variables instead of the parameters (since parameters cannot be initialised here)
   l_init_msg_list := FND_API.G_FALSE;
   IF p_commit IS NULL THEN
     l_commit := Fnd_Api.G_FALSE;
   ELSE
     l_commit := p_commit;
   END IF;
   IF p_valid_lvl IS NULL THEN
     l_valid_lvl := Fnd_Api.G_VALID_LEVEL_FULL;
   ELSE
     l_valid_lvl := p_valid_lvl;
   END IF;

   l_api_version           := 1.0;
   l_select := ' SELECT ' ||
		  ' p.person_id , ' ||
		  ' p.person_number , ' ||
		  ' p.full_name, ' ||
		  ' p.gender sex , ' ||
		  ' p.birth_date, ' ||
		  ' p.title, ' ||
		  ' p.last_name surname, ' ||
		  ' p.first_name given_name , ' ||
		  ' p.known_as preferred_name , ' ||
		  ' p.suffix, ' ||
		  ' p.pre_name_adjunct prefix, ' ||
		  ' p.middle_name, ' ||
		  ' pit.api_person_id alternate_id ' ||
		' FROM  ' ||
		  ' igs_pe_person_base_v p, ' ||
		  ' igs_pe_person_id_type_v pit ' ||
		' WHERE ' ||
		  ' p.person_id = pit.pe_person_id (+)  AND ' ||
		  ' p.person_id IN ';

   l_str := igs_pe_dynamic_persid_group.get_dynamic_sql(p_person_group_id, l_status, l_group_type);

   OPEN cur_person_grp_desc(p_person_group_id);
   FETCH cur_person_grp_desc INTO grp_desc_rec;
   CLOSE cur_person_grp_desc;

   l_select := l_select || '(' || l_str || ')';

   IF l_status <> 'S' THEN
     RAISE NO_DATA_FOUND;
   END IF;

--
-- Set the return status as success for the api
--
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

--
-- Savepoint initialization
--
   SAVEPOINT Process_Group_ID_PVT;

--
-- Make sure that the appropriate version is being used and initialize
-- the message stack if required.
--
   IF (NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         'IGS_PE_USERID_PKG' )) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

--
-- Obtain all the user or members of the group ID given
--
   --skpandey, Bug#4937960: Added logic as a part of Literal Fix
   IF l_group_type = 'STATIC' THEN
    OPEN pgroup_refcur FOR l_select USING p_person_group_id ;
   ELSIF l_group_type = 'DYNAMIC' THEN
    OPEN pgroup_refcur FOR l_select;
   END IF;

   LOOP
      FETCH pgroup_refcur INTO l_member_rec;
      EXIT WHEN pgroup_refcur%NOTFOUND;

      FND_MSG_PUB.initialize;
--
-- Check to determine if the person already has a user name assigned in fnd_user
--
      l_user_name := NULL;
      l_user_end_date := NULL;

      OPEN c_fnd_user_present(l_member_rec.person_id);
      FETCH c_fnd_user_present
      INTO l_user_name, l_user_end_date;

      IF (c_fnd_user_present%NOTFOUND) THEN

--
-- Ensure that the person has email information setup.
--
         l_email_address := NULL;

         OPEN c_email_info(l_member_rec.person_id);
         FETCH c_email_info
         INTO  l_email_address;

	 IF (c_email_info%FOUND) THEN

--
--  Call the appropriate procedure that will handle the user creation
--

            Generate_User (p_api_version      => l_api_version,
                           p_init_msg_list    => FND_API.G_TRUE,
                           p_commit           => FND_API.G_TRUE,
                           p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data,
                           p_title            => l_member_rec.title,
                           p_number           => l_member_rec.person_number,
                           p_prefix           => l_member_rec.prefix,
                           p_alt_id           => l_member_rec.alternate_id,
                           p_given_name       => l_member_rec.given_name,
                           p_pref_name        => l_member_rec.preferred_name,
                           p_middle_name      => l_member_rec.middle_name,
                           p_gender           => l_member_rec.sex,
                           p_surname          => l_member_rec.surname,
                           p_birth            => TO_CHAR(l_member_rec.birth_date,'DD/MM/RRRR'),
                           p_suffix           => l_member_rec.suffix,
                           p_user_name        => NULL,
                           p_user_password    => NULL,
                           p_email_format     => l_email_format,
                           p_email_address    => l_email_address
                          );

	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               Fnd_Message.SET_NAME ('IGS','IGS_PE_PRSN_ACCT_NOT_CREATED');
               Fnd_Message.SET_TOKEN('USERNAME', l_member_rec.full_name);
               Fnd_Msg_Pub.ADD;
            ELSE
               Fnd_Message.SET_NAME ('IGS','IGS_PE_PRSN_ACCT_CREATED');
               Fnd_Message.SET_TOKEN('USERNAME', l_member_rec.full_name);
               Fnd_Message.SET_TOKEN('GRP_DESCRIPTION', grp_desc_rec.description);
               Fnd_Msg_Pub.ADD;
            END IF;

         ELSE
            Fnd_Message.SET_NAME ('IGS','IGS_PE_PRSN_NO_EMAIL_INFO');
            Fnd_Message.SET_TOKEN('USERNAME', l_member_rec.full_name);
            Fnd_Msg_Pub.ADD;
         END IF;

      ELSE
      -- this section for user account found
      -- if the user account has been inactivated for any reasons indicate in the log
         IF l_user_end_date IS NOT NULL AND l_user_end_date < sysdate THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_PE_USERID_EXIST_INACTIVE');
            FND_MESSAGE.SET_TOKEN('USERNAME',l_member_rec.full_name);
            FND_MSG_PUB.ADD;
         ELSE
      -- the user account exists and is active as on the date this job is run
      -- so the user is not re-processed
            Fnd_Message.SET_NAME ('IGS','IGS_PE_USERID_NOT_PROCESSED');
            Fnd_Message.SET_TOKEN('USERNAME', l_member_rec.full_name);
            Fnd_Message.SET_TOKEN('GRP_DESCRIPTION', grp_desc_rec.description);
            Fnd_Msg_Pub.ADD;
         END IF;
      END IF;

--
-- Make sure that all messages are taken from the stack to be output to the log file.
-- The message stack is initialized for each loop iteration.
--
      FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                 p_data  => l_msg_data );


      IF (l_msg_count > 0) THEN

         l_error_text := '';
         FOR l_cur IN 1..l_msg_count LOOP
            l_error_text := ' ' || FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
            fnd_file.put_line (FND_FILE.LOG, l_error_text);
            FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
         END LOOP;

      END IF;

--
-- Ensure that all the cursors used are closed
--
      IF (c_email_info%ISOPEN) THEN
         CLOSE c_email_info;
      END IF;
      IF (c_fnd_user_present%ISOPEN) THEN
         CLOSE c_fnd_user_present;
      END IF;

   END LOOP;
   CLOSE pgroup_refcur;

   RETURN;

--
-- Exception handler section for the Process_Group_ID procedure.
--
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          fnd_message.set_name('IGS','IGS_PE_PERSID_GROUP_EXP');
          fnd_file.put_line (FND_FILE.LOG,fnd_message.get);
       END IF;
       IF (pgroup_refcur%ISOPEN) THEN
         CLOSE pgroup_refcur;
       END IF;
       RETURN;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ROLLBACK TO Process_Group_ID_PVT;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg ('IGS_PE_USERID_PKG', l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                  p_data  => l_msg_data );

       IF (l_msg_count > 0) THEN

          l_error_text := '';
          FOR l_cur IN 1..l_msg_count LOOP
             l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
             fnd_file.put_line (FND_FILE.LOG, l_error_text);
          END LOOP;

       END IF;
       RETURN;

END Process_Group_ID;

PROCEDURE assign_responsibility (p_person_id NUMBER, p_user_id NUMBER)
IS
/******************************************************************
 Created By         : Prabhat Patel
 Date Created By    : 21-Mar-2006
 Purpose            : This procedure checks the person types assigned to a person. Then the responsibilities are
                      assigned to the user associated to the person as per OSS Person Type/Responsibility mapping
Change History
Who                  When            What
******************************************************************/

   -- Cursor to get all the active person types associated with the person
   CURSOR c_get_sys_typ(cp_party_id hz_parties.party_id%TYPE, cp_sysdate DATE) IS
   SELECT c.system_type
   FROM   igs_pe_typ_instances c
   WHERE c.person_id = cp_party_id
   AND   cp_sysdate BETWEEN c.start_date AND NVL(c.end_date, cp_sysdate);

   -- Cursor to get the responsibilities associated with a particular person type
   CURSOR c_resp(cp_system_type igs_pe_person_types.system_type%TYPE) IS
   SELECT st.responsibility_key resp_name,
          st.application_short_name apps_name,
          rsp.application_id  apps_id,
          rsp.responsibility_id resp_id
   FROM igs_pe_typ_rsp_dflt st,
        fnd_responsibility rsp,
        fnd_application ap
   WHERE st.s_person_type = cp_system_type
   AND st.responsibility_key=rsp.responsibility_key
   AND ap.application_id =rsp.application_id
   AND ap.application_short_name = st.application_short_name;

   -- Cursor to check whether a particular responsibility is assigned to a person
   CURSOR c_get_assigned_resp (cp_user_id fnd_user_resp_groups_direct.user_id%TYPE,
                               cp_responsibility_id fnd_user_resp_groups_direct.responsibility_id%TYPE,
			       cp_resp_app_id fnd_user_resp_groups_direct.responsibility_application_id%TYPE) IS
   SELECT responsibility_id
   FROM fnd_user_resp_groups_direct
   WHERE user_id = cp_user_id
   AND responsibility_id = cp_responsibility_id
   AND responsibility_application_id = cp_resp_app_id;

  c_get_sys_typ_rec c_get_sys_typ%ROWTYPE;
  c_get_assigned_resp_rec c_get_assigned_resp%ROWTYPE;
  l_sysdate DATE;

BEGIN
  l_sysdate := TRUNC(SYSDATE);

	-- Check the person type assigned
	OPEN c_get_sys_typ(p_person_id, l_sysdate);
	LOOP
	 FETCH c_get_sys_typ INTO c_get_sys_typ_rec;
	 EXIT WHEN c_get_sys_typ%NOTFOUND;

	 -- Check the responsibilities mapped with the person type
	 FOR c_resp_rec IN c_resp(c_get_sys_typ_rec.system_type) LOOP

	   -- Check whether the responsibility is already assigned to the person
	   OPEN c_get_assigned_resp(p_user_id, c_resp_rec.resp_id, c_resp_rec.apps_id);
	   FETCH c_get_assigned_resp INTO c_get_assigned_resp_rec;
	     IF c_get_assigned_resp%NOTFOUND THEN

		  --Create a resp
		 FND_USER_RESP_GROUPS_API.INSERT_ASSIGNMENT(
			     user_id => p_user_id,
			     responsibility_id => c_resp_rec.resp_id,
			     responsibility_application_id => c_resp_rec.apps_id,
			     security_group_id => 0,
			     start_date => l_sysdate,
			     end_date => null,
			     description => 'IGS WF autoassign');
	     END IF;
	     CLOSE c_get_assigned_resp;
	   END LOOP;
	 END LOOP;
	 CLOSE c_get_sys_typ;

END assign_responsibility;

FUNCTION umx_business_logic(
 p_subscription_guid IN	RAW,
 p_event	IN OUT NOCOPY WF_EVENT_T
) RETURN VARCHAR2
IS

l_result	VARCHAR2(100);
l_event_key     VARCHAR(255);
l_event_context VARCHAR2(30);
l_person_id     NUMBER;
l_user_id       NUMBER;

 l_api_name                CONSTANT VARCHAR2(30)   := 'Create_Party' ;
 l_return_status           VARCHAR2(1);
 l_person_number           VARCHAR2(255);
 l_title                   VARCHAR2(255);
 l_number                  VARCHAR2(255);
 l_prefix                  VARCHAR2(255);
 l_alt_id                  VARCHAR2(255);
 l_given_name              VARCHAR2(255);
 l_pref_name               VARCHAR2(255);
 l_middle_name             VARCHAR2(255);
 l_gender                  VARCHAR2(255);
 l_surname                 VARCHAR2(255);
 l_birth                   VARCHAR2(255);
 l_birth_dt		   DATE;
 l_suffix                  VARCHAR2(255);
 l_user_name               VARCHAR2(255);
 l_email_format            VARCHAR2(255);
 l_email_address           VARCHAR2(255);
 l_new_address             VARCHAR2(255);
 l_rowid                   VARCHAR2(255);
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(255);
 l_contact_point_id        hz_contact_points.contact_point_id%TYPE;
 l_date                    DATE;
 l_id_type                 igs_pe_person_id_typ.person_id_type%TYPE;
 l_count                   NUMBER(9);

 CURSOR c_id_type IS
  SELECT person_id_type
  FROM igs_pe_person_id_typ
  WHERE preferred_ind ='Y';

 CURSOR c_email(cp_person_id NUMBER) IS
 SELECT email_address
 FROM hz_parties
 WHERE party_id = cp_person_id;

 l_default_date  DATE  := TRUNC(SYSDATE);

 CURSOR c_dt_format(cp_date VARCHAR2) IS
 SELECT     fnd_date.canonical_to_date(cp_date)
 FROM       DUAL;

l_object_version_number NUMBER;
l_contact_point_ovn NUMBER;

BEGIN
  l_event_context := p_event.getvalueforparameter ('UMX_CUSTOM_EVENT_CONTEXT');

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
         l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic';
         l_debug_str := 'Begin for UMX_CUSTOM_EVENT_CONTEXT:'||l_event_context;
         fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
  END IF;

  IF l_event_context = UMX_PUB.BEFORE_ACT_ACTIVATION THEN
    l_title := p_event.getvalueforparameter ('IGS_TITLE');
    l_prefix := p_event.getvalueforparameter ('IGS_PREFIX');
    l_alt_id := p_event.getvalueforparameter ('IGS_PREF_ALT_ID');
    l_person_number := p_event.getvalueforparameter ('IGS_PERSON_NUMBER');
    l_given_name := p_event.getvalueforparameter ('FIRST_NAME');
    l_pref_name := p_event.getvalueforparameter ('IGS_PREF_NAME');
    l_middle_name := p_event.getvalueforparameter ('MIDDLE_NAME' );
    l_gender := p_event.getvalueforparameter ('IGS_GENDER');
    l_surname := p_event.getvalueforparameter ('LAST_NAME');
    l_birth := p_event.getvalueforparameter ('IGS_BIRTH_DATE');
    l_suffix := p_event.getvalueforparameter ('PERSON_SUFFIX'  );
    l_user_name := p_event.getvalueforparameter ('REQUESTED_USERNAME');
    l_email_format := p_event.getvalueforparameter ('EMAIL_FORMAT');
    l_email_address := p_event.getvalueforparameter ('EMAIL_ADDRESS' );
    l_person_id := p_event.getvalueforparameter ('PERSON_PARTY_ID');

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
         l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic: UMX_PUB.BEFORE_ACT_ACTIVATION';
         l_debug_str := 'Event Parameters: IGS_TITLE: '||l_title||' IGS_PREFIX: '||l_prefix||' IGS_PREF_ALT_ID: '||l_alt_id
			||' IGS_PERSON_NUMBER: '||l_person_number||' FIRST_NAME: '||l_given_name||' IGS_PREF_NAME: '||l_pref_name
			||' MIDDLE_NAME: '||l_middle_name||' IGS_GENDER: '||l_gender||' LAST_NAME: '||l_surname
			||' IGS_BIRTH_DATE: '||l_birth||' PERSON_SUFFIX: '||l_suffix||' REQUESTED_USERNAME: '||l_user_name
			||' EMAIL_FORMAT: '||l_email_format||' EMAIL_ADDRESS: '||l_email_address||' PERSON_PARTY_ID: '||l_person_id;
         fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
    END IF;

    IF l_birth IS NOT NULL THEN
	       OPEN c_dt_format(l_birth);
	       FETCH c_dt_format INTO l_birth_dt;
               CLOSE c_dt_format;
    END IF;

    IF l_person_id IS NULL THEN

     OPEN  c_id_type;
     FETCH c_id_type INTO l_id_type;
     CLOSE c_id_type;

     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
         l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic: person_id IS NULL';
         l_debug_str := 'Before Person Insert';
         fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
     END IF;

     igs_pe_person_pkg.insert_row(
       x_msg_count              => l_msg_count,
       x_msg_data               => l_msg_data,
       x_rowid                  => l_rowid,
       x_return_status          => l_return_status,
       x_person_id              => l_person_id,
       x_person_number          => l_person_number,
       x_surname                => l_surname,
       x_middle_name            => l_middle_name,
       x_given_names            => l_given_name,
       x_sex                    => l_gender,
       x_title                  => l_title,
       x_staff_member_ind       => '',
       x_deceased_ind           => 'N',
       x_suffix                 => l_suffix,
       x_pre_name_adjunct       => l_prefix,
       x_archive_exclusion_ind  => '',
       x_archive_dt             => '',
       x_purge_exclusion_ind    => '',
       x_purge_dt               => '',
       x_deceased_date          => null,
       x_proof_of_ins           => '',
       x_proof_of_immu          => '',
       x_birth_dt               => l_birth_dt,
       x_salutation             => '',
       x_oracle_username        => l_user_name,
       x_preferred_given_name   => l_pref_name,
       x_email_addr             => l_email_address,
       x_level_of_qual_id       => '',
       x_military_service_reg   => '',
       x_veteran                => '',
       x_hz_parties_ovn         => l_object_version_number,
       x_attribute_category     => '',
       x_attribute1             => '',
       x_attribute2             => '',
       x_attribute3             => '',
       x_attribute4             => '',
       x_attribute5             => '',
       x_attribute6             => '',
       x_attribute7             => '',
       x_attribute8             => '',
       x_attribute9             => '',
       x_attribute10            => '',
       x_attribute11            => '',
       x_attribute12            => '',
       x_attribute13            => '',
       x_attribute14            => '',
       x_attribute15            => '',
       x_attribute16            => '',
       x_attribute17            => '',
       x_attribute18            => '',
       x_attribute19            => '',
       x_attribute20            => '',
       x_person_id_type         => l_id_type,
       x_api_person_id          => l_alt_id,
       x_status                 => 'A',
       x_attribute21            => '',
       x_attribute22            => '',
       x_attribute23            => '',
       x_attribute24            => ''
       );

       IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
         l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic: person_id IS NULL';
         l_debug_str := 'After Person Insert Call: l_return_status: '||l_return_status||'***l_person_id: '||l_person_id||'****l_msg_data/sqlerrm/l_msg_count:'||l_msg_data||'/'||l_msg_count;
         fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
       END IF;
       IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 UMX_PUB.updateWfAttribute (p_event => p_event,
                                P_ATTR_NAME    => 'PERSON_PARTY_ID',
                                P_ATTR_VALUE   => l_person_id);
       END IF;
     ELSE
       IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
          l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic: person_id IS NOT NULL';
          l_debug_str := 'l_person_id: '||l_person_id;
          fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
        END IF;
        UMX_PUB.updateWfAttribute (p_event => p_event,
                                P_ATTR_NAME    => 'PERSON_PARTY_ID',
                                P_ATTR_VALUE   => l_person_id);
     END IF;

     -- Check if contact point exist for the user.

     IF l_return_status IS NULL or l_return_status = FND_API.G_RET_STS_SUCCESS THEN
  	     OPEN c_email(l_person_id);
	     FETCH c_email INTO l_new_address;
	     CLOSE c_email;
	     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	          l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic: After Successful Insert of Person';
		  l_debug_str := 'Before insert/update of Email Address: l_new_address: '||l_new_address||'***l_email_address: '||l_email_address;
	          fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
	     END IF;

	     IF l_new_address IS NULL OR l_email_address <> l_new_address THEN
	       IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKE(
		    p_action                 => 'INSERT',
		    p_rowid                  => l_rowid ,
		    p_status                 => 'A',
		    p_owner_table_name       => 'HZ_PARTIES',
		    p_owner_table_id         => l_person_id,
		    P_primary_flag           => 'Y',
		    p_email_format           => l_email_format,
		    p_email_address          => l_email_address,
		    p_return_status          => l_return_status,
		    p_msg_data               => l_msg_data,
		    p_last_update_date       => l_date,
		    p_contact_point_id       => l_contact_point_id,
		    p_contact_point_ovn      => l_contact_point_ovn
		 ) ;
	        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
		      l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic';
		      l_debug_str := 'After IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKE: l_return_status: '||l_return_status||'***l_msg_data/sqlerrm:'||l_msg_data;
	              fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
		 END IF;
	    END IF;

   END IF;
   IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic';
        l_debug_str := 'END OF UMX_PUB.BEFORE_ACT_ACTIVATION';
        fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
   END IF;

  ELSIF l_event_context = UMX_PUB.AFTER_ACT_ACTIVATION THEN

     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic';
        l_debug_str := 'Start Of UMX_PUB.AFTER_ACT_ACTIVATION';
        fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
    END IF;

    l_person_id := p_event.getvalueforparameter ('PERSON_PARTY_ID');
    l_user_id   := p_event.getvalueforparameter ('REQUESTED_FOR_USER_ID');

    assign_responsibility(l_person_id, l_user_id);
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic';
        l_debug_str := 'End Of UMX_PUB.AFTER_ACT_ACTIVATION: l_person_id: '||l_person_id||'***l_user_id: '||l_user_id;
        fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
    END IF;
  END IF;

  l_result := wf_rule.default_rule(p_subscription_guid, p_event);

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic';
        l_debug_str := 'End Of umx_business_logic: l_result: '||l_result;
        fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
  END IF;

  RETURN(l_result);

EXCEPTION
  WHEN OTHERS THEN

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        l_label := 'igs.plsql.igs_pe_userid_pkg.umx_business_logic';
        l_debug_str := 'Exception: SQLERRM :'||SQLERRM||'***TRACE : '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
    END IF;
  WF_CORE.CONTEXT('IGS_PE_USERID_PKG','UMX_BUSINESS_LOGIC',p_event.geteventname, p_subscription_guid, sqlerrm, sqlcode);
  wf_event.setErrorInfo(p_event,'ERROR');
  RAISE;
  RETURN('ERROR');
END umx_business_logic;

PROCEDURE TestUserName
(
  p_user_name		IN       VARCHAR2,
  x_return_status	OUT NOCOPY      VARCHAR2 ,
  x_message_app_name	OUT NOCOPY      VARCHAR2 ,
  x_message_name	OUT NOCOPY      VARCHAR2 ,
  x_message_text	OUT NOCOPY      VARCHAR2
) IS

l_encoded_message VARCHAR2 (32100);

BEGIN
  x_return_status := fnd_user_pkg.TestUserName (x_user_name => p_user_name);
  IF NOT (x_return_status = fnd_user_pkg.USER_OK_CREATE) THEN
      l_encoded_message := fnd_message.get_encoded;
      fnd_message.parse_encoded (encoded_message => l_encoded_message,
                                 app_short_name  => x_message_app_name,
                                 message_name    => x_message_name);
      fnd_message.set_encoded (l_encoded_message);
      x_message_text := fnd_message.get;
  END IF;
END TestUserName;

PROCEDURE Dup_Person_Check
(
  p_first_name		IN		VARCHAR2,
  p_last_name		IN		VARCHAR2,
  p_birth_date		IN		DATE,
  p_gender		IN		VARCHAR2,
  p_person_num		IN		VARCHAR2,
  p_pref_alt_id		IN		VARCHAR2,
  p_isApplicant		IN		VARCHAR2,
  p_Zipcode		IN  		VARCHAR2,
  p_phoneCountry	IN		VARCHAR2,
  p_phoneArea		IN		VARCHAR2,
  p_phoneNumber		IN		VARCHAR2,
  p_email_address	IN		VARCHAR2,
  x_return_status	OUT NOCOPY      VARCHAR2,
  x_message_name	OUT NOCOPY      VARCHAR2,
  p_person_id		OUT NOCOPY	NUMBER
) AS
/*
      ||  Created By :
      ||  Created On :
      ||  Purpose :
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      || vskumar	12-Jun-2006	 added  p_isApplicant, p_Zipcode , p_phoneCountry, p_phoneArea,
      ||				 p_phoneNumber,p_person_id. wrote new curser c_dup_zip and logic to
      ||				 check duplicate person. include new validations depending upon zip code.
   */
PRAGMA AUTONOMOUS_TRANSACTION;
l_default_date  DATE  := TRUNC(SYSDATE);

-- Hz parties check
CURSOR cur_hz_parties (cp_first_name VARCHAR2, cp_last_name VARCHAR2,cp_birth_date DATE,
		     cp_gender VARCHAR2, cp_person_num VARCHAR2, cp_pref_alt_id VARCHAR2) IS
SELECT count(*), max(person_id)
FROM igs_pe_person_base_v PE, IGS_PE_PERSON_ID_TYPE_V ALT
WHERE pe.person_id = alt.pe_person_id(+)
AND UPPER(pe.first_name) = UPPER(cp_first_name)
AND UPPER(pe.last_name) = UPPER(cp_last_name)
AND NVL(pe.birth_date,l_default_date) = NVL(cp_birth_date,l_default_date)
AND (cp_pref_alt_id IS NULL OR alt.api_person_id = cp_pref_alt_id )
AND (cp_person_num IS NULL OR pe.person_number = cp_person_num )
AND NVL(pe.gender,'X') = NVL(cp_gender,'X');

-- FND user check
CURSOR c_fnd_user(cp_party_id NUMBER) IS
SELECT user_id
FROM fnd_user
WHERE person_party_id = cp_party_id;

l_count NUMBER;
l_user_id FND_USER.USER_ID%TYPE;
l_party_id HZ_PARTIES.PARTY_ID%TYPE;

l_zip_count NUMBER;
l_zip_exact_match BOOLEAN;
l_zip_no_match BOOLEAN;
l_zip_party_id HZ_PARTIES.PARTY_ID%TYPE;

 CURSOR c_pref_alt_id(cp_alt_id VARCHAR2) IS
 SELECT 1
 FROM igs_pe_alt_pers_id alt, igs_pe_person_id_typ typ
 WHERE alt.api_person_id = cp_alt_id
 AND typ.person_id_type = alt.person_id_type
 AND typ.preferred_ind = 'Y';
 l_alt_id_found NUMBER;

 CURSOR c_dup_zip(cp_first_name VARCHAR2, cp_last_name VARCHAR2, cp_birth_date VARCHAR2, cp_pref_alt_id VARCHAR2,
		  cp_person_num VARCHAR2, cp_gender VARCHAR2, cp_zipcode VARCHAR2) IS
 SELECT count(*), max(hz.party_id)
 FROM igs_pe_person_id_type_v alt, hz_parties hz, hz_person_profiles hzp
 WHERE hz.party_id = alt.pe_person_id(+)
 AND UPPER(hz.person_first_name) = UPPER(cp_first_name)
 AND UPPER(hz.person_last_name) = UPPER(cp_last_name)
 AND NVL(hzp.date_of_birth,l_default_date) = NVL(cp_birth_date,l_default_date)
 AND (cp_pref_alt_id IS NULL OR alt.api_person_id = cp_pref_alt_id )
 AND (cp_person_num IS NULL OR hz.party_number = cp_person_num )
 AND NVL(hzp.gender,'X') = NVL(cp_gender,'X')
 AND hzp.party_id = hz.party_id
 AND SYSDATE BETWEEN hzp.effective_start_date
 AND NVL(hzp.effective_end_date,sysdate)
 AND hz.POSTAL_CODE= cp_zipcode;

 l_wf_event_t              WF_EVENT_T;
 l_wf_parameter_list_t     WF_PARAMETER_LIST_T;

CURSOR c_seq_num IS
SELECT IGS_PE_GEN_USER_S.nextval
FROM DUAL;

ln_seq_val            NUMBER;

 BEGIN
  l_count :=0;
  l_zip_exact_match := FALSE;
  l_zip_no_match := FALSE;

  OPEN cur_hz_parties(p_first_name,p_last_name,p_birth_date, p_gender,p_person_num, p_pref_alt_id);
  FETCH cur_hz_parties INTO l_count, l_party_id;
  CLOSE cur_hz_parties;

  IF l_count > 1 THEN
     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	l_label := 'igs.plsql.igs_pe_userid_pkg.Validate_Person.Dup_Person_Check';
	l_debug_str := 'Multiple Matche records found with out considering ZipCode.';
	fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
     END IF;
      -- Too many users
     IF p_Zipcode IS NULL THEN
	x_return_status := 'E';
	FND_MESSAGE.SET_NAME('IGS', 'IGS_PE_ENTER_ZIPCODE');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     ELSE
	OPEN c_dup_zip(p_first_name, p_last_name, p_birth_date,
			p_pref_alt_id, p_person_num, p_gender, p_zipcode);
	FETCH c_dup_zip INTO l_zip_count, l_party_id;
	CLOSE c_dup_zip;
	IF l_zip_count = 1 THEN
		l_zip_exact_match := TRUE;
	ELSE -- No match found or Multiple matche found. Both the cases processing is same.
		l_zip_no_match := TRUE;
	END IF;
     END IF;
  END IF;

  IF (l_count = 1 OR l_zip_exact_match = TRUE) THEN
     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	l_label := 'igs.plsql.igs_pe_userid_pkg.Validate_Person.Dup_Person_Check';
	l_debug_str := 'Exact match found: Person_Id = '||l_party_id;
	fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
     END IF;
     OPEN c_fnd_user(l_party_id);
     FETCH c_fnd_user INTO l_user_id;
     CLOSE c_fnd_user;

     p_person_id := l_party_id;
     IF l_user_id IS NOT NULL THEN
	 assign_responsibility(l_party_id, l_user_id);
         x_return_status := 'W';
         x_message_name := 'IGS_PE_USER_NAME_EXISTS';
	 COMMIT;
         RETURN;
     ELSE
         x_return_status := 'S';
         RETURN;
     END IF;
  END IF;

  IF (l_count = 0 OR l_zip_no_match) THEN
      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
  	l_label := 'igs.plsql.igs_pe_userid_pkg.Validate_Person.Dup_Person_Check';
	l_debug_str := 'Exact match not found for '||p_isApplicant;
	fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
      END IF;

      IF p_isApplicant = 'APPLICANT_YES' THEN
	 RETURN;
      ELSE
	 -- Raise business event 'oracle.apps.igs.pe.accountrequest.alumni_nomatch' setting all parameters.
         WF_EVENT_T.Initialize(l_wf_event_t);
	 l_wf_event_t.setEventName( pEventName => 'oracle.apps.igs.pe.accountrequest.alumni_nomatch');
	 wf_event.AddParameterToList ( p_name => 'PERSON_NUMBER',
	 			       p_value => p_person_num,
				       p_parameterlist => l_wf_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'ALT_ID',
			     	       p_value => p_pref_alt_id,
				       p_parameterlist => l_wf_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'GENDER',
				       p_value => p_gender,
				       p_parameterlist => l_wf_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'BIRTH_DATE',
				       p_value => p_birth_date,
				       p_parameterlist => l_wf_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'SURNAME',
				       p_value => p_last_name,
				       p_parameterlist => l_wf_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'GIVEN_NAME',
				       p_value => p_first_name,
				       p_parameterlist => l_wf_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'USER_EMAIL',
				       p_value => p_email_address,
                 		       p_parameterlist => l_wf_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'ZIP_CODE',
				       p_value => p_Zipcode,
				       p_parameterlist => l_wf_parameter_list_t);
	 wf_event.AddParameterToList ( p_name => 'PHONE_COUNTRY_CODE',
				       p_value => p_phoneCountry,
				       p_parameterlist => l_wf_parameter_list_t);
	 wf_event.AddParameterToList ( p_name => 'PHONE_AREA_CODE',
				       p_value => p_phoneArea,
				       p_parameterlist => l_wf_parameter_list_t);
	 wf_event.AddParameterToList ( p_name => 'PHONE_NUMBER',
				       p_value => p_phoneNumber,
				       p_parameterlist => l_wf_parameter_list_t);
	 wf_event.AddParameterToList ( p_name => 'ADMIN_USERNAME',
				       p_value => FND_PROFILE.VALUE('IGS_PE_USER_ADMIN'),
				       p_parameterlist => l_wf_parameter_list_t);

         -- get the sequence value to be added to EVENT KEY to make it unique.
   	 OPEN  c_seq_num;
         FETCH c_seq_num INTO ln_seq_val;
         CLOSE c_seq_num ;

	 wf_event.raise (
			 p_event_name => 'oracle.apps.igs.pe.accountrequest.alumni_nomatch',
			 p_event_key  => ln_seq_val,
			 p_parameters => l_wf_parameter_list_t,
			 p_event_data => NULL
	 );

	 x_return_status := 'W';
         x_message_name := 'IGS_PE_NO_MATCH_FOUND';
 	 COMMIT;
	 RETURN;
      END IF;
 END IF;

END Dup_Person_Check;

PROCEDURE Validate_Person
(
  p_first_name		IN		VARCHAR2,
  p_last_name		IN		VARCHAR2,
  p_birth_date		IN		DATE,
  p_gender		IN		VARCHAR2,
  p_person_num		IN OUT NOCOPY	VARCHAR2,
  p_pref_alt_id		IN		VARCHAR2,
  p_isApplicant		IN		VARCHAR2,
  p_Zipcode		IN  		VARCHAR2,
  p_phoneCountry	IN		VARCHAR2,
  p_phoneArea		IN		VARCHAR2,
  p_phoneNumber		IN		VARCHAR2,
  p_email_address	IN		VARCHAR2,
  x_return_status	OUT NOCOPY      VARCHAR2,
  x_message_name	OUT NOCOPY      VARCHAR2,
  p_person_id		OUT NOCOPY	NUMBER
) AS
/*
      ||  Created By :
      ||  Created On :
      ||  Purpose :
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      || vskumar	12-Jun-2006	 added  p_isApplicant, p_Zipcode , p_phoneCountry, p_phoneArea,
      ||				 p_phoneNumber,p_person_id
   */
CURSOR c_pref_alt_type IS
SELECT  person_id_type, unique_ind, description, format_mask
FROM igs_pe_person_id_typ
WHERE preferred_ind ='Y';

CURSOR c_seq_num IS
SELECT IGS_PE_GEN_USER_S.nextval
FROM DUAL;

lv_UniqueInd igs_pe_person_id_typ.UNIQUE_IND%TYPE;
l_person_number     hz_parties.party_number%TYPE;

l_person_id_typ igs_pe_person_id_typ.PERSON_ID_TYPE%TYPE;
l_format igs_pe_person_id_typ.format_mask%type;
l_exists VARCHAR2(1);
l_alt_id_desc igs_pe_person_id_typ.description%TYPE;

 l_event_t             wf_event_t;
 l_parameter_list_t    wf_parameter_list_t;
 l_wf_name                 VARCHAR2(8)   ;
 ln_seq_val	NUMBER;

BEGIN
  FND_MSG_PUB.INITIALIZE;
  Dup_Person_Check(
	  p_first_name,
	  p_last_name,
	  p_birth_date,
	  p_gender,
	  p_person_num,
	  p_pref_alt_id,
	  p_isApplicant,
	  p_Zipcode,
	  p_phoneCountry,
	  p_phoneArea,
	  p_phoneNumber,
	  p_email_address,
	  x_return_status,
	  x_message_name,
	  p_person_id
  );

  /*
  -- The return value of Dup_Person_Check is Not Null means further processing is not required since
  -- either with the entered values Multiple Matched persons were found in the System
  -- OR an exactly matched person is found.
  -- The further validation on the entered data data should be done in the case there is no duplicate
  -- person record is found and a new person needs to be created.
  */
  IF x_return_status IS NOT NULL THEN
	RETURN;
  END IF;

  OPEN c_pref_alt_type;
  FETCH c_pref_alt_type INTO l_person_id_typ, lv_UniqueInd, l_alt_id_desc,  l_format;
  CLOSE c_pref_alt_type;

  IF TRUNC(p_birth_date) > TRUNC(SYSDATE) THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_BIRTH_DT');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_isApplicant = 'APPLICANT_YES') AND (FND_PROFILE.VALUE('HZ_GENERATE_PARTY_NUMBER') = 'N') THEN
	-- initialize the parameter list.
	wf_event_t.Initialize(l_event_t);

	OPEN  c_seq_num;
        FETCH c_seq_num INTO ln_seq_val;
	CLOSE c_seq_num ;
        -- set the parameters. This parameter is added with null value to initialize the parameter list.
	wf_event.AddParameterToList ( p_name => 'PARAMETER_DUMMY',
		        		p_value => NULL,
				        p_parameterlist  => l_parameter_list_t);

        WF_EVENT.RAISE3(p_event_name => 'oracle.apps.igs.pe.party_number.generate',
		     p_event_key  => ln_seq_val,
		     p_event_data => NULL,
		     p_parameter_list => l_parameter_list_t,
		     p_send_date  => sysdate
	);

        p_person_num :=  UPPER(WF_EVENT.getValueForParameter('PERSON_NUMBER',l_parameter_list_t));
        l_parameter_list_t.delete;
        IF (p_person_num IS NULL) THEN
	      x_return_status := 'E';
	      FND_MESSAGE.SET_NAME('IGS', 'IGS_PE_ACCREQ_SETUP_N_COMPL');
	      FND_MSG_PUB.Add;
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
	IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
		l_label := 'igs.plsql.igs_pe_userid_pkg.Validate_Person';
	        l_debug_str := 'Auto Generated Person Number is '||p_person_num;
		fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
	END IF;
  END IF;

  x_return_status := 'S';
  x_message_name := NULL;
EXCEPTION
WHEN OTHERS THEN
	x_return_status := 'E';
	x_message_name := SQLERRM;
	RAISE;
END Validate_Person;

PROCEDURE AUTO_GENERATE_USERNAME
(
  p_user_name		OUT NOCOPY      VARCHAR2 ,
  p_person_number	IN       VARCHAR2,
  p_first_name		IN       VARCHAR2,
  p_last_name		IN       VARCHAR2,
  p_middle_name		IN       VARCHAR2,
  p_pref_name		IN       VARCHAR2,
  p_pref_alt_id		IN       VARCHAR2,
  p_title		IN       VARCHAR2,
  p_prefix		IN       VARCHAR2,
  p_suffix		IN       VARCHAR2,
  p_gender		IN       VARCHAR2,
  p_birth_date		IN	 DATE,
  p_email_address	IN       VARCHAR2,
  p_email_format	IN       VARCHAR2
) AS

CURSOR c_seq_num IS
SELECT IGS_PE_GEN_USER_S.nextval
FROM DUAL;

ln_seq_val            NUMBER;
l_event_t             wf_event_t;
l_parameter_list_t    wf_parameter_list_t;

BEGIN
     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            l_label := 'igs.plsql.igs_pe_userid_pkg.auto_generate_username';
            l_debug_str := 'p_person_number: '||p_person_number||' p_first_name: '||p_first_name||' p_last_name: '||p_last_name
			   ||' p_middle_name: '||p_middle_name||' p_pref_name: '||p_pref_name||'p_pref_alt_id: '||p_pref_alt_id
			   ||' p_title: '||p_title||' p_prefix: '||p_prefix||' p_suffix: '||p_suffix||'p_gender'||p_gender
			   ||' p_birth_date: '||p_birth_date||' p_email_address: '||p_email_address||' p_email_format: '||p_email_format;
            fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
     END IF;

     -- initialize the parameter list.
     wf_event_t.Initialize(l_event_t);

     -- set the parameters.
     wf_event.AddParameterToList ( p_name => 'PERSON_NUMBER',
				   p_value => p_person_number,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'GIVEN_NAME',
				   p_value => p_first_name,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'SURNAME',
				   p_value => p_last_name,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'MIDDLE_NAME',
				   p_value => p_middle_name,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'PREF_NAME',
				   p_value => p_pref_name,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'ALT_ID',
				   p_value => p_pref_alt_id,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'TITLE',
				   p_value => p_title,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'PREFIX',
				   p_value => p_prefix,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'SUFFIX',
				   p_value => p_suffix,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'GENDER',
				   p_value => p_gender,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'BIRTH_DATE',
				   p_value => p_birth_date,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'USER_EMAIL',
				   p_value => p_email_address,
				   p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'EMAIL_FORMAT',
				   p_value => p_email_format,
				   p_parameterlist  => l_parameter_list_t);

     -- get the sequence value to be added to EVENT KEY to make it unique.
     OPEN  c_seq_num;
     FETCH c_seq_num INTO ln_seq_val;
     CLOSE c_seq_num ;

     WF_EVENT.RAISE3(p_event_name => 'oracle.apps.igs.pe.genusr',
		     p_event_key  => 'GENERATE_USERNAME'||ln_seq_val,
		     p_event_data => NULL,
		     p_parameter_list => l_parameter_list_t,
		     p_send_date  => sysdate
     );

     p_user_name :=  UPPER(WF_EVENT.getValueForParameter ('USER_NAME',l_parameter_list_t));

     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            l_label := 'igs.plsql.igs_pe_userid_pkg.auto_generate_username: End';
            l_debug_str := 'p_user_name: '||p_user_name;
            fnd_log.string( fnd_log.level_procedure,l_label,l_debug_str);
     END IF;
END AUTO_GENERATE_USERNAME;

PROCEDURE process_alumni_nomatch_event
(	  itemtype       IN              VARCHAR2,
          itemkey        IN              VARCHAR2,
          actid          IN              NUMBER,
          funcmode       IN              VARCHAR2,
          resultout      OUT NOCOPY      VARCHAR
) IS

CURSOR cur_gender (cp_gender VARCHAR2) IS
SELECT meaning
FROM fnd_lookup_values
WHERE lookup_type = 'HZ_GENDER'
AND view_application_id = 222
AND language = USERENV('LANG')
AND security_group_id = 0
AND lookup_code = cp_gender;

CURSOR cur_person_id_type (cp_pers_id_type VARCHAR2) IS
SELECT description
FROM igs_pe_person_id_typ
WHERE person_id_type = cp_pers_id_type;

l_gender		FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE;
l_phone_area_code	HZ_CONTACT_POINTS.PHONE_AREA_CODE%TYPE;
l_phone_country_code    HZ_CONTACT_POINTS.PHONE_COUNTRY_CODE%TYPE;
l_phone_number		HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE;
l_gender_meaning	FND_LOOKUP_VALUES.MEANING%TYPE;
l_person_id_type	IGS_PE_PERSON_ID_TYP.DESCRIPTION%TYPE;
l_formatted_phone	VARCHAR2(100);
x_return_status		VARCHAR2(1);
x_msg_count		NUMBER;
x_msg_data		VARCHAR2(2000);

BEGIN
   l_gender := wf_engine.GetItemAttrText (itemtype => itemtype,
					  itemkey => itemkey,
					  aname => 'GENDER');
   l_phone_area_code := wf_engine.GetItemAttrText (itemtype => itemtype,
					  itemkey => itemkey,
					  aname => 'PHONE_AREA_CODE');
   l_phone_country_code := wf_engine.GetItemAttrText (itemtype => itemtype,
					  itemkey => itemkey,
					  aname => 'PHONE_COUNTRY_CODE');
   l_phone_number := wf_engine.GetItemAttrText (itemtype => itemtype,
					  itemkey => itemkey,
					  aname => 'PHONE_NUMBER');
   OPEN cur_gender(l_gender);
   FETCH cur_gender INTO l_gender_meaning;
   CLOSE cur_gender;

   OPEN cur_person_id_type(FND_PROFILE.VALUE('IGS_PE_ACC_REG_PERS_IDTYPE'));
   FETCH cur_person_id_type INTO l_person_id_type;
   CLOSE cur_person_id_type;

   HZ_FORMAT_PHONE_V2PUB.phone_display (
	  p_phone_country_code => l_phone_country_code,
	  p_phone_area_code => l_phone_area_code,
	  p_phone_number => l_phone_number,
	  x_formatted_phone_number => l_formatted_phone,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
	  x_msg_data => x_msg_data );


   wf_engine.SetItemAttrText (itemtype => itemtype,
				 itemkey => itemkey,
				 aname => 'GENDER_MEANING',
				 avalue => l_gender_meaning);

   wf_engine.SetItemAttrText (itemtype => itemtype,
				 itemkey => itemkey,
				 aname => 'PERSON_ID_TYPE',
				 avalue => l_person_id_type );

   wf_engine.SetItemAttrText (itemtype => itemtype,
				 itemkey => itemkey,
				 aname => 'FORMATTED_PHONE',
				 avalue => l_formatted_phone);

END process_alumni_nomatch_event;

PROCEDURE validate_password
(
  p_user_name		IN		VARCHAR2,
  p_password		IN		VARCHAR2,
  x_return_status	OUT NOCOPY      VARCHAR2 ,
  x_message_text	OUT NOCOPY      VARCHAR2
) IS

l_result VARCHAR2(1);
l_user_name fnd_user.user_name%TYPE;
BEGIN
   IF p_user_name IS NULL THEN
	l_user_name := '-1';
   ELSE
	l_user_name := p_user_name;
   END IF;
   l_result := FND_WEB_SEC.validate_password (l_user_name, p_password);
   IF l_result <> 'Y' THEN
      x_message_text := fnd_message.get;
      x_return_status := 'E';
   END IF;
END validate_password;

END IGS_PE_USERID_PKG;

/
