--------------------------------------------------------
--  DDL for Package Body IGP_AD_USERID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGP_AD_USERID_PKG" AS
/* $Header: IGSPADAB.pls 120.7 2006/05/04 22:49:44 bmerugu noship $ */
/*
||  Created By : nsidana
||  Created On :  1/28/2004
||  Purpose :  Main package for Portfolio user creation and deactivation.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  pkpatel         21-JUN-2004     Bug 3690449 (Removed the reference of ACCOUNT_WF_STATUS and made the USER_NAME as UPPER)
||  (reverse chronological order - newest change first)
*/
PROCEDURE   RECORD_DATA(itemtype       IN              VARCHAR2,
                                                            itemkey         IN              VARCHAR2,
                                                            actid              IN              NUMBER,
                                                            funcmode     IN              VARCHAR2,
                                                            resultout       OUT NOCOPY      VARCHAR2 )
AS
/*
||  Created By : nsidana
||  Created On : 1/28/2004
||  Purpose : Records the data in the interface table.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/
-- Get the details of
CURSOR c_get_val IS
SELECT  to_char(sysdate,'dd-mm-yyyy-HH24-MI-SS')
FROM dual;

CURSOR c_get_fnd_user(cp_user_id fnd_user.user_id%TYPE) IS
SELECT user_name
FROM fnd_user
WHERE user_id=cp_user_id;

CURSOR c_get_party_name(cp_party_id hz_parties.party_id%TYPE) IS
SELECT party_name ,party_number,email_address
FROM hz_parties
WHERE party_id=cp_party_id;

-- Get the details of email of approver.
CURSOR c_get_approver_email(cp_user_name VARCHAR2) IS
SELECT email_address
FROM fnd_user
WHERE user_name=cp_user_name;

CURSOR c_get_req_dets(cp_req_id number)
is
select party_name, email_address
from hz_parties
where party_id=cp_req_id;

-- get requestor fnd user_name
CURSOR c_get_req_fnd_user_name(cp_req_id number)
is
SELECT user_name
FROM fnd_user
WHERE  PERSON_PARTY_ID=cp_req_id;


l_party_id                        hz_parties.party_id%TYPE;
l_user_id                         fnd_user.user_id%TYPE;
l_user_name                   fnd_user.user_name%TYPE;
l_email_address             fnd_user.email_address%TYPE;
l_person_name               hz_parties.party_name%TYPE;
l_org                                hz_parties.party_name%TYPE;
l_approver_email           fnd_user.email_address%TYPE;
l_item_key                      wf_items.item_key%TYPE;
l_classification_cd        igp_ac_acc_classes.acc_classification_code%TYPE;
l_expiration_dt               DATE;
l_requestor                     VARCHAR2(240);
l_approver                      VARCHAR2(240);
l_val                                 VARCHAR2(240);
l_err                                 VARCHAR2(2000);
l_message_text              VARCHAR2(2000);
l_rowid                            VARCHAR2(30);
l_result                            VARCHAR2(240);
l_approver_mail_url      VARCHAR2(1000);
l_url_part1                      VARCHAR2(1000);
l_url_part2                      VARCHAR2(1000);
l_url                                  VARCHAR2(2000);
l_party_det                     c_get_party_name%ROWTYPE;
l_req_email                     hz_parties.email_address%TYPE;
c_get_req_dets_rec              c_get_req_dets%ROWTYPE;
l_req_id                        number;

BEGIN

    IF (funcmode  = 'RUN') THEN
	l_requestor := NULL;
        l_approver := NULL;

        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_user_id.record_data','itemkey:'||itemkey);
        END IF;

        l_item_key               := itemkey;
        l_party_id                := Wf_Engine.GetItemAttrNumber(itemtype,itemkey,'P_PARTY_ID');
        l_classification_cd := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_CLASSIFICATION_CD');
        l_expiration_dt        := Wf_Engine.GetItemAttrDate(itemtype,itemkey,'P_EXPIRATION_DT');
        l_user_id                  := Wf_Engine.GetItemAttrNumber(itemtype,itemkey,'P_USER_ID');
        l_user_name             := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_USER_NAME');
        l_email_address       :=Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_EMAIL_ADDRESS');
        l_org                          :=Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ORGANIZATION');
        l_req_id                          :=Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_REQ_ID');
     	l_req_email           :=null;

        l_user_name := UPPER(l_user_name);
        wf_engine.SetItemAttrText(itemtype,itemkey,'P_USER_NAME', l_user_name);

-- Start : setting req date
     	OPEN c_get_req_dets(l_req_id);
     	FETCH c_get_req_dets INTO c_get_req_dets_rec;
     	CLOSE c_get_req_dets;
        l_req_email:='<a href=mailto:'||c_get_req_dets_rec.party_name||'>'||c_get_req_dets_rec.email_address||'</a>';
        wf_engine.SetItemAttrText(itemtype,itemkey,'P_REQ_NAME', c_get_req_dets_rec.party_name);
        wf_engine.SetItemAttrText(itemtype,itemkey,'P_REQ_EMAIL', l_req_email);
-- End : setting req date

        OPEN c_get_party_name(l_party_id);
        FETCH c_get_party_name INTO l_party_det;
        CLOSE c_get_party_name;

        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_user_id.record_data','l_party_det.name  :'||l_party_det.party_name);
        END IF;

        wf_engine.SetItemAttrText(itemtype,itemkey,'P_PERSON_NUMBER', l_party_det.party_number);
        wf_engine.SetItemAttrText(itemtype,itemkey,'P_PERSON_NAME', l_party_det.party_name);

	IF  (l_user_id IS NOT NULL) THEN

            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_user_id.record_data','UserId passed is Not Null' ||l_user_id);
            END IF;
            wf_engine.SetItemAttrText(itemtype,itemkey,'P_ACTION', 'ACCOUNT');        -- Already a FND user. Only Portfolio a/c is reqd.
        ELSE

            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_user_id.record_data','UserId passed is Null');
            END IF;
            wf_engine.SetItemAttrText(itemtype,itemkey,'P_ACTION', 'BOTH');                  -- Both FND and Portfolio a/c have to be created.
        END IF;


        IF  (l_user_id IS NULL) THEN     -- For a new FND user.
            BEGIN
            INSERT INTO igp_ac_account_ints (item_key,
                                                                              int_account_id,
                                                                              party_id,
                                                                              acc_classification_code,
                                                                              access_expiration_date,
                                                                              user_id,
                                                                              user_name,
                                                                              created_by,
                                                                              creation_date,
                                                                              last_updated_by,
                                                                              last_update_date,
                                                                              last_update_login)
                                                            VALUES(
                                                                              l_item_key,
                                                                              igp_ac_account_ints_s.NEXTVAL,
                                                                              l_party_id,
                                                                              l_classification_cd,
                                                                              l_expiration_dt,
                                                                              null,
                                                                              l_user_name,
                                                                              fnd_global.user_id,
                                                                              sysdate,
                                                                              fnd_global.user_id,
                                                                              sysdate,
                                                                              fnd_global.user_id
                                                                              );
            EXCEPTION
            WHEN OTHERS THEN
                IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_user_id.record_data','Exception while recording data in interface table.'||SQLERRM);
                END IF;
                resultout := 'COMPLETE:IGP_FAIL';
                RAISE;
            END;
-- Start : Setting requestor fnd user name
	OPEN c_get_req_fnd_user_name(l_req_id);
	FETCH c_get_req_fnd_user_name INTO l_requestor;
     	CLOSE c_get_req_fnd_user_name;
-- End : Setting requestor fnd user name

            wf_engine.SetItemAttrText(itemtype,itemkey,'P_REQUESTOR', l_requestor);  -- This attr holds the USER name to which the ntification needs to be sent.
        ELSIF  (l_user_id IS NOT NULL) THEN       -- For an existing FND user.
            BEGIN
            INSERT INTO igp_ac_account_ints (item_key,
                                                                              int_account_id,
                                                                              party_id,
                                                                              acc_classification_code,
                                                                              access_expiration_date,
                                                                              user_id,
                                                                              user_name,
                                                                              created_by,
                                                                              creation_date,
                                                                              last_updated_by,
                                                                              last_update_date,
                                                                              last_update_login)
                                                            VALUES(
                                                                              l_item_key,
                                                                              igp_ac_account_ints_s.NEXTVAL,
                                                                              l_party_id,
                                                                              l_classification_cd,
                                                                              l_expiration_dt,
                                                                              l_user_id,
                                                                              null,
                                                                              fnd_global.user_id,
                                                                              sysdate,
                                                                              fnd_global.user_id,
                                                                              sysdate,
                                                                              fnd_global.user_id
                                                                              );
            EXCEPTION
            WHEN OTHERS THEN
                IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_user_id.record_data','For User: ' || l_user_id || '  Exception while recording data in interface table.'||SQLERRM);
                END IF;
                resultout := 'COMPLETE:IGP_FAIL';
                RAISE;
            END;

            OPEN c_get_fnd_user(l_user_id);   -- Get FND user name from user_id for notifications.
            FETCH c_get_fnd_user INTO l_requestor;
            CLOSE c_get_fnd_user;

            wf_engine.SetItemAttrText(itemtype,itemkey,'P_USER_NAME', l_requestor);
            wf_engine.SetItemAttrText(itemtype,itemkey,'P_REQUESTOR', l_requestor);

            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_user_id.record_data','Fetching user name for existing user l_requestor'||l_requestor);
            END IF;

        END IF;
        -- Set the message of the approval message based on the parameters.
        IF (l_org IS NOT NULL) THEN -- ext account request
            IF (l_expiration_dt IS NOT NULL) THEN
                fnd_message.set_name('IGS','IGP_AD_EXT_NTF_WTH_EX_DT');   -- ext account request with an exp date.
                fnd_message.set_token('CONTACT_NAME',Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSON_NAME'));
                fnd_message.set_token('ORG_NAME',l_org);
                fnd_message.set_token('EXP_DT',l_expiration_dt);
                l_message_text :=  fnd_message.get;
            ELSE
                fnd_message.set_name('IGS','IGP_AD_EXT_NTF_WT_EX_DT');     -- ext account request without an exp date.
                fnd_message.set_token('CONTACT_NAME',Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSON_NAME'));
                fnd_message.set_token('ORG_NAME',l_org);
                l_message_text :=  fnd_message.get;
            END IF;
        ELSIF (l_org IS NULL) THEN -- int account.
            IF (l_expiration_dt IS NOT NULL) THEN
                fnd_message.set_name('IGS','IGP_AD_INT_NTF_WTH_EX_DT');    -- int account request with an exp date.
                fnd_message.set_token('PERSON_NAME',Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSON_NAME'));
                fnd_message.set_token('EXP_DT',l_expiration_dt);
                fnd_message.set_token('ACC_TYPE',l_classification_cd);
                l_message_text :=  fnd_message.get;
            ELSE
                fnd_message.set_name('IGS','IGP_AD_INT_NTF_WT_EX_DT');      -- int account request without an exp date.
                fnd_message.set_token('PERSON_NAME',Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSON_NAME'));
                fnd_message.set_token('ACC_TYPE',l_classification_cd);
                l_message_text :=  fnd_message.get;
            END IF;
        END IF;
        wf_engine.SetItemAttrText(itemtype,itemkey,'P_MESSAGE_TEXT', l_message_text);     -- Set the parameter of the workflow to contain the approval message text.

        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_user_id.record_data','l_message_text :'||l_message_text);
        END IF;

        l_approver:=fnd_profile.value('IGP_ADMIN_WF_APPROVER');

        IF (l_approver IS NULL) THEN
            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_user_id.record_data','approver not defined');
            END IF;
            resultout := 'COMPLETE:IGP_FAIL';   -- Approver not defined.
        ELSE
            OPEN c_get_approver_email(l_approver);
            FETCH c_get_approver_email INTO l_approver_email;
            CLOSE c_get_approver_email;
            l_approver_mail_url:='<a href=mailto:'||l_approver_email||'>'||l_approver_email||'</a>';
            wf_engine.SetItemAttrText(itemtype,itemkey,'P_APPROVER', l_approver);       -- Set the value for the approver, picked from profile.
            wf_engine.SetItemAttrText(itemtype,itemkey,'P_APPROVER_EMAIL', l_approver_mail_url);
            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_user_id.record_data','approver '||l_approver);
            END IF;
        IF (l_classification_cd = 'EXTERNAL') THEN
            fnd_message.set_name('IGS','IGP_AD_EXTERNAL_NOTE');
            wf_engine.SetItemAttrText(itemtype,itemkey,'P_ACC_TYPE',fnd_message.get);
            wf_engine.SetItemAttrText(itemtype,itemkey,'P_ACC_SUB_TYPE',null);
        ELSE
            fnd_message.set_name('IGS','IGP_AD_INTERNAL_NOTE');
            wf_engine.SetItemAttrText(itemtype,itemkey,'P_ACC_TYPE', fnd_message.get);
            wf_engine.SetItemAttrText(itemtype,itemkey,'P_ACC_SUB_TYPE', l_classification_cd);
        END IF;
           select SUBSTR(FND_PROFILE.VALUE('ICX_FORMS_LAUNCHER'),1,INSTR(FND_PROFILE.VALUE('ICX_FORMS_LAUNCHER'),'/',1,3)) INTO l_url_part1 FROM dual;
           select FND_PROFILE.VALUE('ICX_OA_HTML') INTO l_url_part2 FROM dual;
           l_url:=l_url_part1||l_url_part2||'/AppsLocalLogin.jsp';
           l_url:='<a href='||l_url||'>'||l_url||'</a>';
           wf_engine.SetItemAttrText(itemtype,itemkey,'P_URL', l_url);
           resultout := 'COMPLETE:IGP_SUCCESS';
        END IF;
    END IF;  -- for if funcmode='RUN'
EXCEPTION
WHEN others THEN
    resultout := 'COMPLETE:IGP_FAIL';
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.record_data','Unhandled Exception in Record Data ' ||sqlerrm);
    END IF;
END RECORD_DATA;

PROCEDURE   CHECK_EXISTING_ACCOUNT(itemtype       IN              VARCHAR2,
                                                                                      itemkey         IN              VARCHAR2,
                                                                                      actid              IN              NUMBER,
                                                                                      funcmode     IN              VARCHAR2,
                                                                                      resultout       OUT NOCOPY      VARCHAR2 )
AS
/*
||  Created By : nsidana
||  Created On : 1/28/2004
||  Purpose : Checks for the existance of a Portfolio a/c..
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/
-- Get the details of
CURSOR c_exists_acc(cp_acc_type VARCHAR2,cp_user_id fnd_user.user_id%TYPE)
IS
SELECT 'Y'
FROM igp_ac_accounts ac,
             igp_ac_acc_classes acc
WHERE ac.user_id=cp_user_id AND
                acc.acc_classification_code=cp_acc_type AND
                ac.account_id=acc.account_id;

l_user_id     fnd_user.user_id%TYPE;
l_acc_type  igp_ac_acc_classes.acc_classification_code%TYPE;
l_exists        VARCHAR2(1);

BEGIN
    IF (funcmode  = 'RUN') THEN
        l_exists :='N';
        l_acc_type               := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_CLASSIFICATION_CD');
        l_user_id                  := Wf_Engine.GetItemAttrNumber(itemtype,itemkey,'P_USER_ID');
        IF (l_user_id IS NOT NULL) THEN
            l_exists := 'N';
            OPEN c_exists_acc(l_acc_type,l_user_id);
            FETCH c_exists_acc INTO l_exists;
            CLOSE c_exists_acc;
            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.check_existing_account','l_exists :'||l_exists);
            END IF;
            IF (l_exists = 'Y') THEN
                resultout := 'COMPLETE:Y';
                BEGIN
                    DELETE FROM igp_ac_account_ints WHERE item_key=itemkey;
                EXCEPTION
                WHEN others THEN
                 IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.check_action','While deleting record from Interface table :'||sqlerrm);
                END IF;
                END;
            ELSE
                resultout := 'COMPLETE:N';
            END IF;
        ELSE   -- If user id is null. This is for a new FND user account.
            resultout := 'COMPLETE:N';
        END IF;
    END IF; --funcmode
EXCEPTION
WHEN others THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.check_action','Unhandled exception :'||sqlerrm);
    END IF;
END CHECK_EXISTING_ACCOUNT;

PROCEDURE   CHECK_ACTION(itemtype       IN              VARCHAR2,
                                                            itemkey         IN              VARCHAR2,
                                                            actid              IN              NUMBER,
                                                            funcmode     IN              VARCHAR2,
                                                            resultout       OUT NOCOPY      VARCHAR2 )
AS
/*
||  Created By : nsidana
||  Created On : 1/28/2004
||  Purpose : Checks the p_action and returns the lookup code for lookup type action.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/
l_action            VARCHAR2(30);

BEGIN
    IF (funcmode  = 'RUN') THEN
        l_action    := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ACTION');
        IF (l_action = 'ACCOUNT' ) THEN
                      resultout := 'COMPLETE:ACCOUNT';
        ELSIF  (l_action='BOTH')THEN
                      resultout := 'COMPLETE:BOTH';
        END IF;
        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.check_action','l_action :'||l_action);
        END IF;
    END IF;
EXCEPTION
WHEN others THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.check_action','Unhandled exception :'||sqlerrm);
    END IF;
END CHECK_ACTION;

PROCEDURE   VALIDATE_USER_NAME(itemtype       IN              VARCHAR2,
                                                                              itemkey         IN              VARCHAR2,
                                                                              actid              IN              NUMBER,
                                                                              funcmode     IN              VARCHAR2,

                                                                              resultout       OUT NOCOPY      VARCHAR2 )
AS
/*
||  Created By : nsidana
||  Created On : 1/28/2004
||  Purpose : Validates the user name and returns YES/NO.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/
l_exists          VARCHAR2(1);
l_user_name fnd_user.user_name%TYPE;
l_num				pls_integer;
l_message_text              VARCHAR2(2000);
BEGIN
    IF (funcmode  = 'RUN') THEN
        l_exists :='N';
        l_user_name :=NULL;
	l_message_text := NULL;
        l_user_name    := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_USER_NAME');
        l_exists:='N';
	if FND_SSO_MANAGER.isUserCreateUpdateAllowed() then
		IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
			fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.validate_user_name', ' User create and update allowed.');
		 END IF;

		-- test user already exist, output of testusername
		   --@ USER_OK_CREATE                 constant pls_integer := 0;
		   --@ USER_INVALID_NAME              constant pls_integer := 1;
		   --@ USER_EXISTS_IN_FND             constant pls_integer := 2;
		   --@ USER_SYNCHED                   constant pls_integer := 3;
		   --@ USER_EXISTS_NO_LINK_ALLOWED    constant pls_integer := 4;
	  	    l_num := fnd_user_pkg.testusername(x_user_name=>l_user_name);
	            if l_num = 0 then
			IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
			     fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.validate_user_name','l_exists :'||l_exists);
			END IF;
			 resultout := 'COMPLETE:Y';                 -- No FND user with this name exists.
		    elsif l_num = 1 then
			fnd_message.set_name('IGS','IGP_AD_INVALID_USR_NAME');   -- Invalid user name
			fnd_message.set_token('USERNAME',l_user_name);
			l_message_text :=  fnd_message.get;

		     resultout := 'COMPLETE:N';                   -- user name does not comply user name policy
			IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
				fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.validate_user_name','l_user_name :'||l_user_name || ' does not comply user name policy.');
			 END IF;
		    elsif l_num = 2 then
			fnd_message.set_name('IGS','IGP_AD_USR_ALREADY_REGISTERED');   -- User already registered in fnd
			fnd_message.set_token('USERNAME',l_user_name);
			l_message_text :=  fnd_message.get;

			resultout := 'COMPLETE:N';                   -- user name already exist in fnd_user.
			IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
				fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.validate_user_name','l_user_name :'||l_user_name || ' user name already exist in fnd_user.');
			END IF;
		     else -- if l_num = 3 or 4
			fnd_message.set_name('IGS','IGP_AD_USR_ALREADY_REG_IN_OID');   -- User already registered in OID
			fnd_message.set_token('USERNAME',l_user_name);
			l_message_text :=  fnd_message.get;
	                resultout := 'COMPLETE:N';                   -- user name is already in use with Oracle Internet Directory.
			IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
				fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.validate_user_name','l_user_name :'||l_user_name||' is already in use with Oracle Internet Directory.');

			END IF;
		    end if; -- FOR l_num = 0
		else
			l_num := -1;

			fnd_message.set_name('IGS','IGP_AD_USR_CRT_UPD_NOT_ALOWED');   -- Creation or updating of a user is not allowed.
			l_message_text :=  fnd_message.get;
	                 resultout := 'COMPLETE:N';                   -- Creation or updating of a user is not allowed.

			IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
				fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.validate_user_name',' Creation or updating of a user is not allowed.');
			 END IF;
		end if; -- FOR FND_SSO_MANAGER.isUserCreateUpdateAllowed()

		-- clean up the record from igp_ac_account_ints
		if l_num <> 0 then
		        BEGIN
			      DELETE FROM igp_ac_account_ints WHERE item_key=itemkey;
			EXCEPTION
			    WHEN others THEN
			      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
				fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.validate_user_name','While deleting record from Interface table :'||sqlerrm);
			      END IF;
			  END;
		 end if;

		wf_engine.SetItemAttrText(itemtype,itemkey,'P_MESSAGE_TEXT', l_message_text);     -- Set the parameter of the workflow to contain the reason of not completing the create portfolio request.


    END IF;
EXCEPTION
WHEN others THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.validate_user_name','Unhandled exception :'||sqlerrm);
    END IF;
END VALIDATE_USER_NAME;

PROCEDURE   CREATE_FND_USER(itemtype       IN              VARCHAR2,
                                                                    itemkey         IN              VARCHAR2,
                                                                    actid              IN              NUMBER,
                                                                    funcmode     IN              VARCHAR2,
                                                                    resultout       OUT NOCOPY      VARCHAR2 )
  AS
  /*
||  Created By : nsidana
||  Created On : 1/28/2004
||  Purpose : Procedure to create a new FND user.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

l_user_id                            fnd_user.user_id%TYPE;
l_user_name                      fnd_user.user_name%TYPE;
l_email_address                fnd_user.email_address%TYPE;
l_party_id                          hz_parties.party_id%TYPE;
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                       VARCHAR2(2000);
l_user_password             VARCHAR2(100);
l_classification_cd           igp_ac_acc_classes.acc_classification_code%TYPE;
l_expiration_dt                 DATE;
l_resp_exists                    VARCHAR2(1);

BEGIN
    IF (funcmode  = 'RUN') THEN
        l_resp_exists :='N';
        -- Extract the attributes from the workflow. These are required to create the FND user.
        l_party_id               := wf_engine.GetItemAttrNumber(itemtype,itemkey,'P_PARTY_ID' );
        l_user_name           := wf_engine.GetItemAttrText(itemtype,itemkey,'P_USER_NAME' );
        l_email_address     := wf_engine.GetItemAttrText(itemtype,itemkey,'P_EMAIL_ADDRESS' );
        l_user_password   := wf_engine.GetItemAttrText(itemtype,itemkey,'P_PASSWORD' );
        --Validate the password also.
        IF (l_user_password IS NULL) OR (length(l_user_password)<5) THEN
            l_user_password:=GENERATE_PASSWORD(l_party_id);
            Wf_Engine.SetItemAttrText(itemtype,itemkey,'P_PASSWORD',l_user_password);
        END IF;
        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_fnd_user','Creating user with values :'||l_party_id||' '||l_user_name||' '||l_email_address);
        END IF;
		-- Now, call FND package to create the FND user.
	    begin
		fnd_user_pkg.CreateUser (
		    x_user_name             => l_user_name,
		    x_owner                 => '',
		    x_session_number        => '0',
		    x_start_date            => sysdate,
		    x_unencrypted_password  => l_user_password,
		    x_email_address         => l_email_address,
		    x_password_date         => sysdate,
		    x_customer_id           => l_party_id);

		    select USER_ID into l_user_id
		    from FND_USER
		    where USER_NAME = l_user_name;

		    wf_engine.SetItemAttrNumber(itemtype,itemkey,'P_USER_ID', l_user_id);    -- set the FND user ID. To be used later.
		    wf_engine.SetItemAttrText(itemtype,itemkey,'P_REQUESTOR', l_user_name);
		    resultout := 'COMPLETE:IGP_SUCCESS';
		    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
			fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_fnd_user','l_user_id :'||l_user_id);
			fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_fnd_user','l_user_name :'||l_user_name);
		    END IF;
	    exception
		when others then
		    delete from  igp_ac_account_ints where item_key= itemkey;
		    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
			fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_fnd_user','error while creating FND user.');
		    END IF;
		    resultout := 'COMPLETE:IGP_FAIL';
	    end;

    END IF;  -- for funcmode='RUN'
EXCEPTION
WHEN others THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.create_fnd_user','Unhandled Exception :'||sqlerrm);
    END IF;
    resultout := 'COMPLETE:IGP_FAIL';
END CREATE_FND_USER;

PROCEDURE   CREATE_PORT_ACCOUNT(itemtype       IN              VARCHAR2,
                                                                                itemkey         IN              VARCHAR2,
                                                                                actid              IN              NUMBER,
                                                                                funcmode     IN              VARCHAR2,
                                                                                resultout       OUT NOCOPY      VARCHAR2 )
  AS
  /*
||  Created By : nsidana
||  Created On : 1/28/2004
||  Purpose : Procedure to create a new Portfolio account.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

  -- Get the details of responsibilities to be attached to the FND user because of a classification cd.
  -- the resp would be different for IGS/IGP, All IGP resp would have TAG= IGP.
CURSOR c_get_resp(cp_class_cd VARCHAR2) IS
SELECT responsibility_id
FROM igp_as_resp_mappings
WHERE  acc_classification_code=cp_class_cd
                AND  tag='IGP'
                AND enable_flag='Y';

-- Cursor to check if a resp is already attached to the user.
CURSOR  c_chk_resp(cp_user_id NUMBER,cp_resp NUMBER) IS
SELECT b.responsibility_id,b.end_date
FROM fnd_user a,
            fnd_user_resp_groups_direct b
WHERE a.user_id=cp_user_id  AND
                a.user_id=b.user_id AND
                b.responsibility_id=cp_resp;

-- Get the details of portfolio user.
CURSOR c_is_port_user(cp_party_id VARCHAR2) IS
SELECT account_id
FROM igp_ac_accounts a
WHERE party_id=cp_party_id;

CURSOR c_get_user_id(cp_user_name VARCHAR2) IS
SELECT user_id
FROM fnd_user
WHERE user_name=cp_user_name;

CURSOR c_get_resp_desc(cp_resp_id NUMBER) IS
SELECT description
FROM fnd_responsibility_tl
WHERE responsibility_id=cp_resp_id AND
                language = USERENV('LANG');

l_resp													                        NUMBER;
l_user_name																			fnd_user.user_name%TYPE;
l_user_id																						fnd_user.user_id%TYPE;
l_fnd_user_id																		fnd_user.user_id%TYPE;
l_party_id																					hz_parties.party_id%TYPE;
l_classification_cd													  igp_ac_acc_classes.acc_classification_code%TYPE;
l_account_id																			igp_ac_accounts.account_id%TYPE;
l_expiration_dt																	DATE;
l_desc																									fnd_responsibility_tl.description%TYPE;
l_exists																								VARCHAR2(1);
lv_rowid																							VARCHAR2(30);
l_acc_classification_id										igp_ac_acc_classes.acc_classification_id%TYPE;
l_fnd_resp_end_dt													DATE;
c_get_resp_rec                                 c_get_resp%ROWTYPE;
c_chk_resp_rec                               c_chk_resp%ROWTYPE;

  BEGIN
            IF (funcmode  = 'RUN') THEN
                 l_exists :='N';
                 l_party_id                 := wf_engine.GetItemAttrNumber(itemtype,itemkey,'P_PARTY_ID' );                         -- HZ party ID.
                 l_fnd_user_id          := wf_engine.GetItemAttrNumber(itemtype,itemkey,'P_USER_ID' );                             -- FND user ID.
                 l_classification_cd   := wf_engine.GetItemAttrText(itemtype,itemkey,'P_CLASSIFICATION_CD' );         -- Portfolio acc classification code...STAFF,FACULTY,STUDENT.
                 l_expiration_dt         := wf_engine.GetItemAttrDate(itemtype,itemkey,'P_EXPIRATION_DT' );                  -- Access expiration date.

                 -- check if already a Portfolio user.
                 l_exists:='N';
                 l_account_id:=null;
                 OPEN c_is_port_user(l_party_id);
                 FETCH c_is_port_user INTO l_account_id;
                 CLOSE c_is_port_user;

                  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_port_account','Existing account ID is l_account_id :'||l_account_id);
                  END IF;

                 IF  (l_account_id IS NOT NULL) THEN
                       wf_engine.SetItemAttrNumber(itemtype,itemkey,'P_ACCOUNT_ID', l_account_id);     -- Portfolio a/c exists: Set the value of the account ID in the WF.
                 ELSIF  (l_account_id IS NULL) THEN   --Call the TBH of the IGP_AC_ACCOUNTS table to insert into the table.
                 BEGIN
                             igp_ac_accounts_pkg.insert_row (
                                x_mode                                  => 'R',
                                x_rowid                                  => lv_rowid,                    -- OUT param
                                x_account_id                        => l_account_id,            -- OUT param
                                x_party_id                             => l_party_id,                 -- HZ party ID.
                                x_user_id                               => l_fnd_user_id,          -- FND user ID.
                                x_object_version_number  => 1                                   -- OVN is always 1 for a newly created record.
                                );
                   EXCEPTION
                   WHEN others THEN
                        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
                                fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.create_port_account','Unhandled exception.');
                            END IF;
                       END;
                            wf_engine.SetItemAttrNumber(itemtype,itemkey,'P_ACCOUNT_ID', l_account_id);   -- Collect the account_id for the new a/c created and set the value in WF.
                            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                                fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_port_account','Newly created account ID : l_account_id  :'||l_account_id);
                            END IF;
                 END IF;

                 FOR c_get_resp_rec  IN c_get_resp(l_classification_cd)
                 LOOP      -- For each resp, check if its already attached.
                            l_exists:='N';
                            c_chk_resp_rec:=null;
                            OPEN c_chk_resp(l_fnd_user_id,c_get_resp_rec.responsibility_id);
                            FETCH c_chk_resp INTO c_chk_resp_rec;
                            CLOSE c_chk_resp;

                            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                                fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_port_account','Resp Id  :'||c_chk_resp_rec.responsibility_id);
                            END IF;

                            IF (c_chk_resp_rec.responsibility_id IS NOT NULL) THEN --check if we need to update the end date of the FND resp.
                                  l_fnd_resp_end_dt:=c_chk_resp_rec.end_date;
                                  IF (l_fnd_resp_end_dt IS NOT NULL) THEN
                                        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                                            fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_port_account','Resp end date  :'||l_fnd_resp_end_dt);
                                        END IF;
                                        IF (l_expiration_dt IS NULL) THEN         -- Update the FNd resp to be not end dated,.
                                                                                        OPEN c_get_resp_desc(c_get_resp_rec.responsibility_id);   -- get the desc of the resp. reqd for API call.
                                                                                        FETCH c_get_resp_desc INTO l_desc;
                                                                                        CLOSE c_get_resp_desc;
                                                                                        fnd_user_resp_groups_api.update_assignment(
                                                                                            user_id                                           => l_fnd_user_id,                                        -- FND user ID.
                                                                                            responsibility_id                          =>c_get_resp_rec.responsibility_id,         -- RESP ID.
                                                                                            responsibility_application_id    =>8405,
                                                                                            security_group_id                       => 0,
                                                                                            start_date                                       => sysdate,
                                                                                            end_date                                        => l_expiration_dt,                                       -- Expiration date.
                                                                                            description                                     =>l_desc                                                         -- Description.
                                                                                              );


                                         ELSIF (l_expiration_dt IS NOT NULL) THEN
                                                   IF (l_expiration_dt > l_fnd_resp_end_dt) THEN                                                                 --Update the new FND resp end date.
                                                          OPEN c_get_resp_desc(c_get_resp_rec.responsibility_id);   -- get the desc of the resp. reqd for API call.
                                                          FETCH c_get_resp_desc INTO l_desc;
                                                          CLOSE c_get_resp_desc;
                                                          BEGIN
                                                              fnd_user_resp_groups_api.update_assignment(
                                                                  user_id                                           => l_fnd_user_id,                                                       -- FND user ID.
                                                                  responsibility_id                          =>c_get_resp_rec.responsibility_id,                       -- RESP ID.
                                                                  responsibility_application_id    =>8405,
                                                                  security_group_id                       => 0,
                                                                  start_date                                       => sysdate,
                                                                  end_date                                        => l_expiration_dt,                                                      -- Expiration date.
                                                                  description                                     =>l_desc                                                                       -- Description.
                                                                    );
                                                          EXCEPTION
                                                          WHEN OTHERS THEN
                                                          IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
                                                                  fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.create_port_account','Unhandled exception while creating user..');
                                                              END IF;
                                                          END;
                                                   END IF;
                                        END IF;
                                  END IF;
                            ELSIF  (c_chk_resp_rec.responsibility_id IS NULL) THEN            -- Attach the resp. Call the pkg fnd_user_resp_groups_api.
                                          OPEN c_get_resp_desc(c_get_resp_rec.responsibility_id);   -- get the desc of the resp. reqd for API call.
                                          FETCH c_get_resp_desc INTO l_desc;
                                          CLOSE c_get_resp_desc;

                                          IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                                              fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_port_account','Resp desc for new resp :'||l_desc);
                                          END IF;
                                          fnd_user_resp_groups_api.insert_assignment(
                                              user_id                                           => l_fnd_user_id,                                                       -- FND user ID.
                                              responsibility_id                          =>c_get_resp_rec.responsibility_id,                       -- RESP ID.
                                              responsibility_application_id    =>8405,
                                              security_group_id                       => 0,
                                              start_date                                       => sysdate,
                                              end_date                                        => l_expiration_dt,                                                      -- Expiration date.
                                              description                                     =>l_desc                                                                       -- Description.
                                              );
                            END IF;
                 END LOOP;
                 -- Insert a record in IGP_AC_ACC_CLASSES table.
                     l_account_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'P_ACCOUNT_ID');

                     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                         fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.create_port_account','Account ID :'||l_account_id);
                     END IF;

                     lv_rowid:=NULL;
                     BEGIN
                         igp_ac_acc_classes_pkg.insert_row ( x_mode                                         => 'R',
                                                                                            x_rowid                                        => lv_rowid,
                                                                                            x_acc_classification_id             => l_acc_classification_id,    -- PK of the table. OUT param.
                                                                                            x_account_id                               => l_account_id ,                     -- FK to the account ID.
                                                                                            x_acc_classification_code        => l_classification_cd,           -- Acc classification code.
                                                                                            x_access_expiration_date         => l_expiration_dt,                   -- Access expiration date.
                                                                                            x_object_version_number        => 1
                                                                                          );
                         -- Delete from interface table.
                         DELETE FROM igp_ac_account_ints
                         WHERE party_id=l_party_id
                         AND acc_classification_code=l_classification_cd;
                     EXCEPTION
                     WHEN OTHERS THEN
                      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.create_port_account','Unhandled exception while creating user..');
                          END IF;
                     END;
                     resultout:='COMPLETE';
        END IF;
EXCEPTION
WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.create_port_account','Exception :'||sqlerrm);
    END IF;
END CREATE_PORT_ACCOUNT;

FUNCTION GENERATE_PASSWORD (p_party_id NUMBER) RETURN VARCHAR2
IS
BEGIN
    DBMS_LOCK.SLEEP(1);
    return fnd_crypto.RandomString(10);
END GENERATE_PASSWORD;

PROCEDURE   SET_DATA(itemtype       IN              VARCHAR2,
                                                  itemkey         IN              VARCHAR2,
                                                  actid              IN              NUMBER,
                                                  funcmode     IN              VARCHAR2,
                                                  resultout       OUT NOCOPY      VARCHAR2 )
IS
    CURSOR c_get_per_details(cp_user_id NUMBER) IS
    SELECT hz.party_name,hz.party_number
    FROM hz_parties hz,igp_ac_accounts ac
    WHERE ac.user_id=cp_user_id AND
                   ac.party_id=hz.party_id;

    CURSOR  c_get_fnd_user(cp_user_id NUMBER) IS
    SELECT user_name
    FROM fnd_user
    WHERE user_id=cp_user_id;

    CURSOR c_get_requestor_det(cp_req_id NUMBER) IS
    SELECT hz.person_last_name||', '||hz.person_first_name req_name,
           fu.email_address req_email
    FROM
        hz_parties hz,
        fnd_user fu,
        igp_ac_Accounts acc
    WHERE
        hz.party_id=cp_req_id AND
        hz.party_id=acc.party_id AND
        acc.user_id=fu.user_id;


    l_account_id                      NUMBER;
    l_user_id                            fnd_user.user_id%TYPE;
    l_classcode                        igp_ac_acc_classes.acc_classification_code%TYPE;
    l_expiry_dt                         DATE;
    l_user_name                      fnd_user.user_name%TYPE;
    c_get_per_details_rec     c_get_per_details%ROWTYPE;
    l_requestor_id          hz_parties.party_id%TYPE;
     l_requestor_name       hz_parties.party_name%TYPE;
    l_requestor_email       fnd_user.email_address%TYPE;
    l_href_mailto           VARCHAR2(1000);
    c_get_requestor_det_rec c_get_requestor_det%ROWTYPE;


BEGIN
    IF (funcmode  = 'RUN') THEN
        l_account_id           := wf_engine.GetItemAttrNumber(itemtype,itemkey,'P_ACCOUNT_ID' );
        l_user_id                 := wf_engine.GetItemAttrNumber(itemtype,itemkey,'P_USER_ID' );
        l_classcode              := wf_engine.GetItemAttrText(itemtype,itemkey,'P_CLASS_CODE' );
        l_expiry_dt              := wf_engine.GetItemAttrDate(itemtype,itemkey,'P_EXPIRY_DATE' );
        l_requestor_id           := wf_engine.GetItemAttrText(itemtype,itemkey,'P_REQUESTOR' );

        OPEN c_get_requestor_det(l_requestor_id);
        FETCH c_get_requestor_det INTO c_get_requestor_det_rec;
        CLOSE c_get_requestor_det;

	l_href_mailto :='<a href=mailto:'||c_get_requestor_det_rec.req_email||'</a>'||c_get_requestor_det_rec.req_email;

        wf_engine.SetItemAttrText(itemtype,itemkey,'P_REQUESTOR_NAME',c_get_requestor_det_rec.req_name);
        wf_engine.SetItemAttrText(itemtype,itemkey,'P_REQUESTOR_EMAIL',l_href_mailto);

	IF (l_classcode = 'EXTERNAL') THEN
          fnd_message.set_name('IGS','IGP_AD_EXTERNAL_NOTE');
          wf_engine.SetItemAttrText(itemtype,itemkey,'P_ACC_TYPE',fnd_message.get);
        ELSE
          fnd_message.set_name('IGS','IGP_AD_INTERNAL_NOTE');
          wf_engine.SetItemAttrText(itemtype,itemkey,'P_ACC_TYPE',fnd_message.get);
          wf_engine.SetItemAttrText(itemtype,itemkey,'P_ACC_SUB_TYPE',l_classcode);
	END IF;

        OPEN c_get_per_details(l_user_id);
        FETCH c_get_per_details INTO c_get_per_details_rec;
        CLOSE c_get_per_details;

        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.set_data','person details Name :'||c_get_per_details_rec.party_name);
            fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.set_data','person details Number :'||c_get_per_details_rec.party_number);
        END IF;

        wf_engine.SetItemAttrText(itemtype,itemkey,'P_PERSON_NAME', c_get_per_details_rec.party_name);
        wf_engine.SetItemAttrText(itemtype,itemkey,'P_PERSON_NUMBER', c_get_per_details_rec.party_number);

        OPEN c_get_fnd_user(l_user_id);
        FETCH c_get_fnd_user INTO l_user_name;
        CLOSE c_get_fnd_user;

        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_procedure,'igs.plsql.igp_ad_userid_pkg.set_data','User Name :'||l_user_name);
        END IF;

        wf_engine.SetItemAttrText(itemtype,itemkey,'P_EMAIL_ADDRESS', l_user_name);
        wf_engine.SetItemAttrText(itemtype,itemkey,'P_USER_NAME',l_user_name);

    END IF;
END SET_DATA;

PROCEDURE   CLEANUP(itemtype       IN             VARCHAR2,
                                                  itemkey         IN              VARCHAR2,
                                                  actid              IN              NUMBER,
                                                  funcmode     IN              VARCHAR2,
                                                  resultout       OUT NOCOPY      VARCHAR2 )
AS
BEGIN
  IF (funcmode  = 'RUN') THEN
    BEGIN
      DELETE FROM igp_ac_account_ints WHERE item_key=itemkey;
    EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.cleanup','While deleting record from Interface table :'||sqlerrm);
      END IF;
    END;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_exception,'igs.plsql.igp_ad_userid_pkg.cleanup','Unhandled exception while deleting record from Interface table :'||sqlerrm);
  END IF;
END CLEANUP;
END igp_ad_userid_pkg;

/
