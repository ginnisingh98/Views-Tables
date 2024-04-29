--------------------------------------------------------
--  DDL for Package Body IGP_WZ_PUBLISH_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGP_WZ_PUBLISH_TEMPLATE_PKG" AS
/* $Header: IGSPWZAB.pls 120.1 2005/12/23 02:47:06 jnalam noship $ */

/******************************************************************
 Created By         : Prabhat Patel
 Date Created By    : 20-Feb-2004
 Purpose            : Procedures for workflow template approval to publish
 remarks            :
 Change History
 Who      When        What
******************************************************************/

  PROCEDURE submit_approval( p_template_id igp_wz_templates.template_id%TYPE,
                             p_template_name igp_wz_templates.template_name%TYPE,
                             p_user_id     fnd_user.user_id%TYPE) AS
 /******************************************************************
   Created By         : Prabhat Patel
   Date Created By    : 20-Feb-2004
   Purpose            : Procedure for raising the business event for template approval
   remarks            :
   Change History
   Who      When        What
  ******************************************************************/
    CURSOR c_seq_num IS
    SELECT igp_wz_temp_approve_s.NEXTVAL
    FROM dual;
    ln_seq_val            NUMBER;
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;

  BEGIN

     -- initialize the parameter list.
     wf_event_t.Initialize(l_event_t);

     -- set the parameters.
     wf_event.AddParameterToList ( p_name => 'P_TEMPLATE_ID', p_value => p_template_id, p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'P_USER_ID' , p_value => p_user_id, p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'P_TEMPLATE_NAME' , p_value => p_template_name, p_parameterlist  => l_parameter_list_t);

     -- get the sequence value to be added to EVENT KEY to make it unique.
     OPEN  c_seq_num;
     FETCH c_seq_num INTO ln_seq_val ;
     CLOSE c_seq_num ;

     -- raise event
     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.igp.wz.publish_template',
      p_event_key  => 'IGPWZ001'|| p_template_name ||ln_seq_val,
      p_parameters => l_parameter_list_t
     );

  END submit_approval;

PROCEDURE update_template (
    p_template_id igp_wz_templates.template_id%TYPE,
	p_status VARCHAR2) IS
 /******************************************************************
   Created By         : Prabhat Patel
   Date Created By    : 25-Feb-2004
   Purpose            : Procedure for Updating status of the Template
   remarks            :
   Change History
   Who      When        What
  ******************************************************************/
	 l_var  NUMBER;

	 CURSOR lock_temp_cur(cp_template_id igp_wz_templates.template_id%TYPE) IS
	 SELECT 1
	 FROM igp_wz_templates
	 WHERE template_id = cp_template_id;
BEGIN

    OPEN lock_temp_cur(p_template_id);
	FETCH lock_temp_cur INTO l_var;
	CLOSE lock_temp_cur;

	UPDATE igp_wz_templates
	SET    template_status_code = p_status
	WHERE  template_id = p_template_id;

END update_template;

PROCEDURE pending_status (
    p_template_id igp_wz_templates.template_id%TYPE) IS
 /******************************************************************
   Created By         : Prabhat Patel
   Date Created By    : 25-Feb-2004
   Purpose            : Procedure for updating to Pending status.
   remarks            :
   Change History
   Who      When        What
  ******************************************************************/
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    update_template(p_template_id, 'PENDING');
	COMMIT;
END pending_status;

PROCEDURE draft_status (itemtype       IN              VARCHAR2,
                        itemkey        IN              VARCHAR2,
                        actid          IN              NUMBER,
                        funcmode       IN              VARCHAR2,
                        resultout      OUT NOCOPY      VARCHAR2) AS
 /******************************************************************
   Created By         : Prabhat Patel
   Date Created By    : 25-Feb-2004
   Purpose            : Procedure for updating to Draft status.
   remarks            :
   Change History
   Who      When        What
  ******************************************************************/
    l_template_id igp_wz_templates.template_id%TYPE;
    l_error_message  VARCHAR2(500);
BEGIN
	l_template_id := wf_engine.GetItemAttrText( itemtype => itemtype,
												itemkey  => itemkey,
												aname    => 'P_TEMPLATE_ID');
    update_template(l_template_id, 'DRAFT');

EXCEPTION
  WHEN OTHERS THEN
      l_error_message := SQLERRM;
      wf_core.context('igp_wz_publish_template_pkg','draft_status',itemtype,itemkey ,l_error_message);
      RAISE;
END draft_status;

PROCEDURE publish_status (itemtype       IN              VARCHAR2,
                          itemkey        IN              VARCHAR2,
                          actid          IN              NUMBER,
                          funcmode       IN              VARCHAR2,
                          resultout      OUT NOCOPY      VARCHAR2) AS
 /******************************************************************
   Created By         : Prabhat Patel
   Date Created By    : 25-Feb-2004
   Purpose            : Procedure for updating to Publish status.
   remarks            :
   Change History
   Who      When        What
  ******************************************************************/
    l_template_id igp_wz_templates.template_id%TYPE;
    l_error_message  VARCHAR2(500);
BEGIN
	l_template_id := wf_engine.GetItemAttrText( itemtype => itemtype,
												itemkey  => itemkey,
												aname    => 'P_TEMPLATE_ID');
    update_template(l_template_id, 'PUBLISH');

EXCEPTION
  WHEN OTHERS THEN
      l_error_message := SQLERRM;
      wf_core.context('igp_wz_publish_template_pkg','publish_status',itemtype,itemkey ,l_error_message);
      RAISE;
END publish_status;

PROCEDURE create_tempdtl_message(
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2
  ) AS
 /******************************************************************
   Created By         : Prabhat Patel
   Date Created By    : 20-Feb-2004
   Purpose            : Procedure for creating the CLOB message body
   remarks            :
   Change History
   Who      When        What
  ******************************************************************/

  BEGIN
      null;
   END create_tempdtl_message;

  PROCEDURE template_preprocess (itemtype       IN              VARCHAR2,
                                 itemkey        IN              VARCHAR2,
                                 actid          IN              NUMBER,
                                 funcmode       IN              VARCHAR2,
                                 resultout      OUT NOCOPY      VARCHAR2) AS
  /******************************************************************
   Created By         : Prabhat Patel
   Date Created By    : 20-Feb-2004
   Purpose            : Procedure for setting all the item attributes and validating all the error conditions
   remarks            :
   Change History
   Who      When        What
  ******************************************************************/
    l_approver       fnd_user.user_name%TYPE;
	l_approver_name  hz_parties.party_name%TYPE;
	l_login_user_id  fnd_user.user_id%TYPE;
	l_login_user_name fnd_user.user_name%TYPE;
    l_item_key       wf_items.item_key%TYPE;
    l_item_exists    VARCHAR2(1);
	l_template_id    igp_wz_templates.template_id%TYPE;
	l_template_name  igp_wz_templates.template_name%TYPE;
    l_error_message  VARCHAR2(500);

    nbsp VARCHAR2(10);
	l_preview_link   VARCHAR2(500);
	l_protocol_port  VARCHAR2(240);
	l_virtual_path   VARCHAR2(240);
	l_protocol_port_value VARCHAR2(240);

	CURSOR login_person_cur (cp_user_id fnd_user.user_id%TYPE) IS
	SELECT usr.user_name, hz.person_last_name||', '||hz.person_first_name person_name, usr.email_address
	FROM   fnd_user usr, hz_parties hz
	WHERE  usr.user_id = cp_user_id AND
	       usr.person_party_id = hz.party_id;

    CURSOR approver_name_cur (cp_approver fnd_user.user_name%TYPE) IS
	SELECT hz.party_name
	FROM   fnd_user usr, hz_parties hz
	WHERE  usr.user_name = cp_approver AND
	       usr.person_party_id = hz.party_id;

    CURSOR temp_dtl_cur(cp_template_id IN NUMBER, cp_lookup_type IN VARCHAR2) IS
    SELECT temp.template_name name,
           NVL(temp.template_title,nbsp) title,
           lk.meaning type,
           NVL(temp.description,nbsp) description,
           NVL(TO_CHAR(temp.expiry_date),nbsp) expiry_date,
		   created_by
    FROM   igp_wz_templates temp, igp_lookup_values lk
    WHERE  temp.template_id = cp_template_id AND
	       temp.template_type_code = lk.lookup_code AND
		   lk.lookup_type = cp_lookup_type;

    temp_dtl_rec temp_dtl_cur%ROWTYPE;
    login_person_rec login_person_cur%ROWTYPE;
    l_email_address  VARCHAR2(500);
  BEGIN

  IF (funcmode  = 'RUN') THEN

        nbsp := fnd_global.local_chr(38) || 'nbsp;';

		l_login_user_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'P_USER_ID');

        l_template_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'P_TEMPLATE_ID');

        l_template_name := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'P_TEMPLATE_NAME');

        OPEN login_person_cur(l_login_user_id);
		FETCH login_person_cur INTO login_person_rec;
		CLOSE login_person_cur;

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'REQUESTOR_NAME',
			  avalue    =>  login_person_rec.person_name);

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'REQUESTOR',
			  avalue    =>  login_person_rec.user_name);

       OPEN temp_dtl_cur(l_template_id,'IGP_WZ_TEMP_TYPE');
	   FETCH temp_dtl_cur INTO temp_dtl_rec;
	   CLOSE temp_dtl_cur;

	   l_protocol_port := FND_PROFILE.VALUE('ICX_FORMS_LAUNCHER');
       l_virtual_path  := FND_PROFILE.VALUE('ICX_OA_HTML');

         -- Create the preview template link dynamically from the profiles
/*        l_protocol_port_value := SUBSTR(l_protocol_port,1,INSTR(l_protocol_port,'/',1,3));
        l_preview_link := l_protocol_port_value || l_virtual_path ||'/'||'OA.jsp?OAFunc=IGP_WZ_PREVIEW_TEMP_PAGE'||l_var||'tempId='||l_template_id;

        l_preview_link :=  '<a href='''||l_preview_link||'''>'||temp_dtl_rec.name||'</a>';*/

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'P_TEMPLATE_NAME',
			  avalue    =>  temp_dtl_rec.name);

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'LINK_TEMP_NAME',
			  avalue    =>  temp_dtl_rec.name);

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'TEMP_TITLE',
			  avalue    =>  temp_dtl_rec.title);

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'TEMP_TYPE',
			  avalue    =>  temp_dtl_rec.type);

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'TEMP_DESC',
			  avalue    =>  temp_dtl_rec.description);

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'TEMP_EXP_DT',
			  avalue    =>  temp_dtl_rec.expiry_date);

        OPEN login_person_cur(temp_dtl_rec.created_by);
		FETCH login_person_cur INTO login_person_rec;
		CLOSE login_person_cur;

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'TEMP_AUTHOR',
			  avalue    =>  login_person_rec.person_name);

        l_email_address := '<a href=mailto:'||login_person_rec.email_address||'>'||login_person_rec.email_address||'</a>';

        wf_engine.setitemattrtext(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'TEMP_AUTHOR_EMAIL',
			  avalue    =>  l_email_address);

        -- Check that the profile for approver is set properly.
		-- If not set throw an error
        l_approver := FND_PROFILE.VALUE('IGP_WZ_TEMP_APPROVER');

        IF l_approver IS NULL THEN

           FND_MESSAGE.SET_NAME('IGS','IGP_WZ_TEMP_APPROVE_NO_PROF');

		   Wf_Engine.SetItemAttrText(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'ERROR_MSG',
			  avalue    =>  FND_MESSAGE.GET());

		   resultout := 'COMPLETE:F';
		   RETURN;
        END IF;

		   Wf_Engine.SetItemAttrText(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'APPROVER',
			  avalue    =>  l_approver);

           OPEN approver_name_cur(l_approver);
		   FETCH approver_name_cur INTO l_approver_name;
		   CLOSE approver_name_cur;

		   Wf_Engine.SetItemAttrText(
			  itemType  =>  itemtype,
			  itemKey   =>  itemkey,
			  aname     =>  'APPROVER_NAME',
			  avalue    =>  l_approver_name);

		-- If everything is fine call the procedure to update the status to pending
		pending_status (l_template_id);

		resultout := 'COMPLETE:S';

    END IF;
  EXCEPTION
   WHEN OTHERS THEN
      l_error_message := SQLERRM;
      wf_core.context('igp_wz_publish_template_pkg','publish_status',itemtype,itemkey ,l_error_message);
      RAISE;

  END template_preprocess;

END igp_wz_publish_template_pkg;

/
