--------------------------------------------------------
--  DDL for Package Body IGR_IN_JTF_INTERACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_IN_JTF_INTERACTIONS_PKG" AS
/* $Header: IGSRT05B.pls 120.0 2005/06/01 18:13:24 appldev noship $ */

PROCEDURE get_profile_values IS
 /* This procedure populates all the profile variables in either parameters
    or global variables, so that these values can be used again. Default values
    of some items are also populated here*/
    l_tmp_org_id        NUMBER;
    l_tmp_user_id       VARCHAR2(100);
    l_tmp_login_id      VARCHAR2(100);
    l_tmp_resource_id   VARCHAR2(100);

    CURSOR c_resource_id is
    SELECT resource_id
    FROM jtf_rs_resource_extns
    WHERE user_id = Igr_in_jtf_interactions_pkg.g_user_id;

    l_outcome          VARCHAR2(100);
    l_result           VARCHAR2(100);
    l_reason           VARCHAR2(100);

    CURSOR default_outcome is
    SELECT outcome_id, short_description
    FROM jtf_ih_outcomes_vl
    WHERE outcome_code = l_outcome;

    CURSOR default_result is
    SELECT result_id, short_description
    FROM jtf_ih_results_vl
    WHERE result_code = l_result;

    CURSOR default_reason is
    SELECT reason_id, short_description
    FROM jtf_ih_reasons_vl
    WHERE reason_code = l_reason;

 BEGIN
      -- Get default outcome,result and reason for activities
     fnd_profile.get('IGR_JTF_DEFAULT_OUTCOME', l_outcome);

     -- Default Outcome for Interactions and Activities in Academic Recruiting
     fnd_profile.get('IGR_JTF_DEFAULT_RESULT', l_result);
     -- Default Result for Interactions and Activities in Academic Recruiting
     fnd_profile.get('IGR_JTF_DEFAULT_REASON', l_reason);
     -- Default Reason for Interactions and Activities in Academic Recruiting

     fnd_profile.get('USER_ID', l_tmp_user_id );
     l_tmp_login_id:= FND_GLOBAL.LOGIN_ID;


     fnd_profile.get('IGR_JTF_DEFAULT_RESOURCE', l_tmp_resource_id);
     -- Default resource ID for Interactions and Activities in Academic Recruiting
     Igr_in_jtf_interactions_pkg.g_resource_id     := IGS_GE_NUMBER.TO_NUM(l_tmp_resource_id);
     Igr_in_jtf_interactions_pkg.g_login_id        := IGS_GE_NUMBER.TO_NUM(l_tmp_login_id);
     Igr_in_jtf_interactions_pkg.g_resp_appl_id    := fnd_global.resp_appl_id;
     Igr_in_jtf_interactions_pkg.g_resp_id         := fnd_global.resp_id;
     Igr_in_jtf_interactions_pkg.g_user_id         := fnd_global.user_id;

     OPEN  default_outcome;
     FETCH default_outcome INTO Igr_in_jtf_interactions_pkg.g_def_outcome_id, Igr_in_jtf_interactions_pkg.g_def_outcome;
     CLOSE default_outcome;

     OPEN  default_result;
     FETCH default_result INTO Igr_in_jtf_interactions_pkg.g_def_result_id, Igr_in_jtf_interactions_pkg.g_def_result;
     CLOSE default_result;

     OPEN  default_reason;
     FETCH default_reason INTO Igr_in_jtf_interactions_pkg.g_def_reason_id, Igr_in_jtf_interactions_pkg.g_def_reason;
     CLOSE default_reason;

 END get_profile_values;

PROCEDURE start_interaction (p_person_id IN igs_pe_person_base_v.person_id%TYPE,
                             p_ret_status OUT NOCOPY VARCHAR2,
                             p_msg_data   OUT NOCOPY VARCHAR2,
                             p_msg_count  OUT NOCOPY NUMBER,
			     p_int_id    OUT NOCOPY NUMBER) IS
/* Procedure to start an interaction */

   l_interaction_rec        jtf_ih_pub.interaction_rec_type := jtf_ih_pub.init_interaction_rec;
   x_int_id                 NUMBER;
   l_user_id                NUMBER;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_return_status          VARCHAR2(1);
   l_rec_count              NUMBER;
   l_msg_index_out          NUMBER;

BEGIN

      l_interaction_rec.party_id := p_person_id;
      -- Populate all the profile variables
      Igr_in_jtf_interactions_pkg.get_profile_values;

      -- Get the application id and pass that in handler_id
      l_interaction_rec.handler_id := Igr_in_jtf_interactions_pkg.g_resp_appl_id;
      l_interaction_rec.resource_id := Igr_in_jtf_interactions_pkg.g_resource_id;
      l_interaction_rec.outcome_id := Igr_in_jtf_interactions_pkg.g_def_outcome_id;
      l_interaction_rec.start_date_time := SYSDATE;
      l_interaction_rec.duration := 0;

      JTF_IH_PUB.OPEN_INTERACTION(p_api_version     => Igr_in_jtf_interactions_pkg.g_api_version,
				  p_init_msg_list   => Igr_in_jtf_interactions_pkg.g_true,
				  p_commit          => Igr_in_jtf_interactions_pkg.g_false,
				  p_resp_appl_id    => Igr_in_jtf_interactions_pkg.g_resp_appl_id,
				  p_resp_id         => Igr_in_jtf_interactions_pkg.g_resp_id,
				  p_user_id         => Igr_in_jtf_interactions_pkg.g_user_id,
				  p_login_id        => Igr_in_jtf_interactions_pkg.g_login_id,
				  x_return_status   => p_ret_status,
				  x_msg_count       => p_msg_count,
				  x_msg_data        => p_msg_data,
				  p_interaction_rec => l_interaction_rec,
				  x_interaction_id  => p_int_id );

	   IF p_ret_status  IN ('E','U') THEN
	      IF p_msg_count > 1 THEN
		 FOR i IN 1..p_msg_count LOOP
		   p_msg_data := p_msg_data || ' '||fnd_msg_pub.get(p_encoded => fnd_api.g_false);
		 END LOOP;
		 p_msg_data := trim(p_msg_data);
	       END IF;
	   END IF;
EXCEPTION
   WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;

END start_interaction;

PROCEDURE start_int_and_act (
			p_doc_ref	 IN VARCHAR2,
			p_person_id      IN igs_pe_person_base_v.person_id%TYPE,
			p_sales_lead_id  IN as_sales_leads.sales_lead_id%TYPE ,
			p_item_id	 IN igr_i_a_pkgitm.package_item_id%TYPE ,
			p_doc_id         IN NUMBER,
			p_action         IN jtf_ih_actions_vl.action%TYPE,
			p_action_id      IN jtf_ih_actions_vl.action_id%TYPE,
			p_action_item    IN jtf_ih_action_items_vl.action_item%TYPE,
			p_action_item_id IN jtf_ih_action_items_vl.action_item_id%TYPE,
                        p_ret_status     OUT NOCOPY VARCHAR2,
                        p_msg_data       OUT NOCOPY VARCHAR2,
                        p_msg_count      OUT NOCOPY NUMBER ) IS
/* This procedure starts and interaction and starts an activity */


   CURSOR c_person_number(p_person_id igs_pe_person_base_v.person_id%TYPE) IS
   SELECT person_number
   FROM   igs_pe_person_base_v
   WHERE  person_id = p_person_id;

   person_number_rec  c_person_number%ROWTYPE;
   p_int_id NUMBER;

BEGIN
   OPEN  c_person_number(p_person_id);
   FETCH c_person_number into person_number_rec;
   CLOSE c_person_number;
    Igr_in_jtf_interactions_pkg.start_interaction(
                        p_person_id  => p_person_id,
                        p_ret_status => p_ret_status,
                        p_msg_data   => p_msg_data,
                        p_msg_count  => p_msg_count,
			p_int_id => p_int_id);
   IF p_ret_status  IN ('E','U') THEN
      IF p_msg_count > 1 THEN
	 FOR i IN 1..p_msg_count LOOP
	   p_msg_data := p_msg_data || ' '||fnd_msg_pub.get(p_encoded => fnd_api.g_false);
	 END LOOP;
	 p_msg_data := trim(p_msg_data);
       END IF;
   ELSE
       Igr_in_jtf_interactions_pkg.add_activity(
			p_action                 => p_action,
			p_action_id              => p_action_id,
			p_action_item            => p_action_item,
			p_action_item_id         => p_action_item_id,
			p_doc_source_object_name => IGS_GE_NUMBER.TO_CANN(p_sales_lead_id),
			p_doc_ref                => p_doc_ref,
			p_doc_id                 => p_doc_id,
                        p_ret_status             => p_ret_status,
                        p_msg_data               => p_msg_data,
                        p_msg_count              => p_msg_count,
			p_int_id                 => p_int_id);
  	 IF p_ret_status  IN ('E','U') THEN
  	    IF p_msg_count > 1 THEN
	         FOR i IN 1..p_msg_count LOOP
		     p_msg_data := p_msg_data || ' '||fnd_msg_pub.get(p_encoded => fnd_api.g_false);
		 END LOOP;
		     p_msg_data := trim(p_msg_data);
  	    END IF;
         ELSE
           Igr_in_jtf_interactions_pkg.end_interaction(
                        p_ret_status             => p_ret_status,
                        p_msg_data               => p_msg_data,
                        p_msg_count              => p_msg_count);


         END IF;
   END IF;

   END start_int_and_act;

PROCEDURE add_activity(p_action                 IN VARCHAR2,
		       p_action_id              IN NUMBER,
		       p_Action_item            IN VARCHAR2,
		       p_Action_item_id         IN NUMBER,
		       p_doc_source_object_name IN VARCHAR2,
		       p_doc_id                 IN NUMBER,
		       p_doc_ref                IN VARCHAR2,
		       p_outcome_id             IN NUMBER,
		       p_result_id              IN NUMBER,
		       p_reason_id              IN NUMBER,
		       p_cust_account_id        IN NUMBER,
		       p_int_id                 IN NUMBER,
                       p_ret_status             OUT NOCOPY VARCHAR2,
                       p_msg_data               OUT NOCOPY VARCHAR2,
                       p_msg_count              OUT NOCOPY NUMBER ) IS

   CURSOR activity_action is
   SELECT action_id
   FROM jtf_ih_actions_vl
   WHERE action = p_action;

   CURSOR activity_action_item is
   SELECT action_item_id
   FROM jtf_ih_action_items_vl
   WHERE action_item = p_action_item;

   l_activity_rec           jtf_ih_pub.activity_rec_type := jtf_ih_pub.init_activity_rec;
   x_activity_id            NUMBER;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_return_status          VARCHAR2(1);
   l_rec_count              NUMBER;
   l_msg_index_out          NUMBER;

BEGIN

      l_activity_rec.interaction_id := p_int_id;
      l_activity_rec.outcome_id := Igr_in_jtf_interactions_pkg.g_def_outcome_id;
      l_activity_rec.result_id := Igr_in_jtf_interactions_pkg.g_def_result_id;
      l_activity_rec.reason_id := Igr_in_jtf_interactions_pkg.g_def_reason_id;
      -- Get the action_id and action_item_id from jtf_ih_actions_vl and jtf_ih_Action_items_vl
      IF p_action_id IS NULL THEN
	 OPEN  activity_action;
	 FETCH activity_action into l_activity_rec.action_id;
	 CLOSE activity_action;
      ELSE
	 l_activity_rec.action_id := p_action_id;
      END IF;

      IF p_action_item_id IS NULL THEN
	 open activity_action_item;
	 fetch activity_action_item into l_activity_rec.action_item_id;
	 close activity_action_item;
      ELSE
	 l_activity_rec.action_item_id := p_action_item_id;
      END IF;
      l_activity_rec.start_date_time := SYSDATE;
      l_activity_rec.end_date_time := SYSDATE;
      l_activity_rec.doc_source_object_name := p_doc_source_object_name;
      l_activity_rec.doc_id := p_doc_id;
      IF p_outcome_id IS NOT NULL THEN
	 l_activity_rec.outcome_id := p_outcome_id;
      END IF;
      IF p_result_id is NOT NULL THEN
	 l_activity_rec.result_id := p_result_id;
      END IF;
      IF p_reason_id IS NOT NULL THEN
	 l_activity_rec.reason_id := p_reason_id;
      END IF;
      IF p_cust_account_id IS NOT NULL THEN
	 l_activity_rec.cust_account_id := p_cust_account_id;
      END IF;

      JTF_IH_PUB.add_activity(p_api_version    => Igr_in_jtf_interactions_pkg.g_api_version,
			      p_init_msg_list  => Igr_in_jtf_interactions_pkg.g_true,
			      p_commit         => Igr_in_jtf_interactions_pkg.g_false,
			      p_resp_appl_id   => Igr_in_jtf_interactions_pkg.g_resp_appl_id,
			      p_resp_id        => Igr_in_jtf_interactions_pkg.g_resp_id,
			      p_user_id        => Igr_in_jtf_interactions_pkg.g_user_id,
			      p_login_id       => Igr_in_jtf_interactions_pkg.g_login_id,
			      x_return_status  => p_ret_status,
			      x_msg_count      => p_msg_count,
			      x_msg_data       => p_msg_data,
			      p_activity_rec   => l_activity_rec,
			      x_activity_id    => x_activity_id);

	   IF p_ret_status  IN ('E','U') THEN
	      IF p_msg_count > 1 THEN
		 FOR i IN 1..p_msg_count LOOP
		   p_msg_data := p_msg_data || ' '||fnd_msg_pub.get(p_encoded => fnd_api.g_false);
		 END LOOP;
		 p_msg_data := trim(p_msg_data);
	       END IF;
	   END IF;
EXCEPTION
   WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END add_activity;

PROCEDURE update_activity(p_activity_id            IN NUMBER,
			  p_action_id              IN VARCHAR2,
			  p_Action_item_id         IN VARCHAR2,
			  p_doc_source_object_name IN VARCHAR2,
			  p_outcome_id             IN NUMBER,
			  p_result_id              IN NUMBER,
			  p_reason_id              IN NUMBER,
                          p_ret_status             OUT NOCOPY VARCHAR2,
                          p_msg_data               OUT NOCOPY VARCHAR2,
                          p_msg_count              OUT NOCOPY NUMBER ) IS

   l_activity_rec               jtf_ih_pub.activity_rec_type := jtf_ih_pub.init_activity_rec;
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_return_status              VARCHAR2(1);
   l_rec_count                  NUMBER;
   l_msg_index_out              NUMBER;

BEGIN

   IF Igr_in_jtf_interactions_pkg.g_int_id is null THEN
      -- Activity cannot be updated since there is no active interaction
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
   ELSE
      l_activity_rec.interaction_id := Igr_in_jtf_interactions_pkg.g_int_id;
      l_activity_rec.activity_id := p_activity_id;
      l_activity_rec.action_id := p_action_id;
      l_activity_rec.action_item_id := p_action_item_id;
      l_activity_rec.end_date_time := SYSDATE;
      l_activity_rec.doc_source_object_name := p_doc_source_object_name;
      l_activity_rec.outcome_id := p_outcome_id;
      l_activity_rec.result_id := p_result_id;
      l_activity_rec.reason_id := p_reason_id;

      JTF_IH_PUB.update_activity(p_api_version    => Igr_in_jtf_interactions_pkg.g_api_version,
				 p_init_msg_list  => Igr_in_jtf_interactions_pkg.g_true,
				 p_commit         => Igr_in_jtf_interactions_pkg.g_false,
				 p_resp_appl_id   => Igr_in_jtf_interactions_pkg.g_resp_appl_id,
				 p_resp_id        => Igr_in_jtf_interactions_pkg.g_resp_id,
				 p_user_id        => Igr_in_jtf_interactions_pkg.g_user_id,
				 p_login_id       => Igr_in_jtf_interactions_pkg.g_login_id,
				 x_return_status  => l_return_status,
				 x_msg_count      => l_msg_count,
				 x_msg_data       => l_msg_data,
				 p_activity_rec   => l_activity_rec);

   END IF;

EXCEPTION
   WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END update_activity;

PROCEDURE end_interaction (p_ret_status OUT NOCOPY VARCHAR2,
                       p_msg_data  OUT NOCOPY VARCHAR2,
                       p_msg_count OUT NOCOPY NUMBER )  IS
/* This procedure ends the interaction */

   l_interaction_rec        jtf_ih_pub.interaction_rec_type := jtf_ih_pub.init_interaction_rec;
   l_active                 VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_return_status          VARCHAR2(1);
   l_rec_count              NUMBER;
   l_msg_index_out          NUMBER;
   l_outcome_id             NUMBER;
   l_reason_id              NUMBER;
   l_result_id              NUMBER;

   CURSOR int_active IS
   SELECT active, outcome_id, reason_id, result_id
   FROM jtf_ih_interactions
   WHERE interaction_id = Igr_in_jtf_interactions_pkg.g_int_id;

BEGIN

   IF Igr_in_jtf_interactions_pkg.g_int_id IS NOT NULL THEN
      OPEN  int_active;
      FETCH int_active INTO l_active, l_outcome_id, l_reason_id, l_result_id;
      CLOSE int_active;

      -- If outcome, result and reason are set in the database from some form other than
      -- CC form, check if value is updated in database and pass to API accordingly
      IF l_active = 'Y' THEN
	 IF (l_outcome_id IS NOT NULL) and (l_outcome_id <> fnd_api.g_miss_num) THEN
	    l_interaction_rec.outcome_id := l_outcome_id;
	 ELSE
	    l_interaction_rec.outcome_id := Igr_in_jtf_interactions_pkg.g_def_outcome_id;
	 END IF;
	 IF (l_result_id IS NOT NULL) and (l_result_id <> fnd_api.g_miss_num) THEN
	    l_interaction_rec.result_id := l_result_id;
	 ELSE
	    l_interaction_rec.result_id := Igr_in_jtf_interactions_pkg.g_def_result_id;
	 END IF;
	 IF (l_reason_id IS NOT NULL) and (l_reason_id <> fnd_api.g_miss_num) THEN
	    l_interaction_rec.reason_id := l_reason_id;
	 ELSE
	    l_interaction_rec.reason_id := Igr_in_jtf_interactions_pkg.g_def_reason_id;
	 END IF;

	 l_interaction_rec.interaction_id := Igr_in_jtf_interactions_pkg.g_int_id;
	 l_interaction_rec.end_date_time := SYSDATE;

	 JTF_IH_PUB.CLOSE_INTERACTION(p_api_version    => Igr_in_jtf_interactions_pkg.g_api_version,
				      p_init_msg_list  => Igr_in_jtf_interactions_pkg.g_true,
				      p_commit         => Igr_in_jtf_interactions_pkg.g_false,
				      p_resp_appl_id   => Igr_in_jtf_interactions_pkg.g_resp_appl_id,
				      p_resp_id        => Igr_in_jtf_interactions_pkg.g_resp_id,
				      p_user_id        => Igr_in_jtf_interactions_pkg.g_user_id,
				      p_login_id       => Igr_in_jtf_interactions_pkg.g_login_id,
				      x_return_status  => l_return_status,
				      x_msg_count      => l_msg_count,
				      x_msg_data       => l_msg_data,
				      p_interaction_rec=> l_interaction_rec);

	 IF l_return_status <>  Igr_in_jtf_interactions_pkg.g_ret_sts_success THEN
	    -- Activity cannot be updated since there is no active interaction
	    FND_MESSAGE.SET_NAME('IGS','IGS_AD_JTF_CLS_INT_FLD');
	    IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
	 END IF;
      END IF;

      -- Clear the variable value
      Igr_in_jtf_interactions_pkg.g_int_id := NULL;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END end_interaction;

END Igr_in_jtf_interactions_pkg;

/
