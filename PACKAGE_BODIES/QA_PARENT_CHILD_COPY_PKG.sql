--------------------------------------------------------
--  DDL for Package Body QA_PARENT_CHILD_COPY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PARENT_CHILD_COPY_PKG" as
/* $Header: qapccpb.pls 120.0 2005/05/24 19:12:34 appldev noship $ */

   --this procedure copies the newest parent child relationship between source
   --parent/child to a new relationship between target parent/child. if there
   --are more than one relationship between the source plans it only takes the one with
   --the most recent creation_date. it returns the old_plan_relationship_id,
   --new plan_relationship_id as well as a return status
   PROCEDURE COPY_PLAN_REL(p_source_parent_plan_id      IN  NUMBER,
                           p_source_child_plan_id       IN  NUMBER,
                           p_target_parent_plan_id      IN  NUMBER,
                           p_target_child_plan_id       IN  NUMBER,
                           x_old_plan_relationship_id   OUT NOCOPY NUMBER,
                           x_new_plan_relationship_id   OUT NOCOPY NUMBER,
                           x_return_status              OUT NOCOPY VARCHAR2)
   IS
      CURSOR C1  (parent_id NUMBER, child_id NUMBER) IS
        SELECT   qpr.plan_relationship_id, qpr.data_entry_mode, qpr.auto_row_count,
                 qpr.plan_relationship_type,
                 qpr.default_parent_spec, qpr.layout_mode
        FROM     qa_pc_plan_relationship qpr
        WHERE    qpr.parent_plan_id = parent_id
                 AND qpr.child_plan_id = child_id
        ORDER BY qpr.creation_date DESC;
      c1_rec C1%ROWTYPE;
      x_row_id  VARCHAR2(1000);
   BEGIN
      --fetch the most recently created parent child relationship between source parent and source child
      OPEN C1(p_source_parent_plan_id, p_source_child_plan_id);

      --make sure a relationship was found
      FETCH C1 INTO c1_rec;
      IF C1%NOTFOUND THEN
         CLOSE C1;
         x_old_plan_relationship_id := -1;
         x_new_plan_relationship_id := -1;
         RETURN;
      ELSE
         CLOSE C1;
      END IF;

      --now perform the actual insert, use table handler instead of insert_plan_rel to avoid
      --calls to qa_ak_mapping_api
      /*
      QA_SS_PARENT_CHILD_PKG.insert_plan_rel(
        p_parent_plan_id         => p_target_parent_plan_id,
        p_child_plan_id          => p_target_child_plan_id,
        p_plan_relationship_type => c1_rec.plan_relationship_type,
        p_data_entry_mode        => c1_rec.data_entry_mode,
        p_auto_row_count         => c1_rec.auto_row_count,
        p_default_parent_spec    => c1_rec.default_parent_spec,
        x_plan_relationship_id   => x_new_plan_relationship_id);
      */

      QA_PC_PLAN_REL_PKG.Insert_Row(
                       X_Rowid                  => x_row_id,
                       X_Plan_Relationship_Id   => x_new_plan_relationship_id,
                       X_Parent_Plan_Id         => p_target_parent_plan_id,
                       X_Child_Plan_id          => p_target_child_plan_id,
                       X_Plan_Relationship_Type => c1_rec.plan_relationship_type,
                       X_Data_Entry_Mode        => c1_rec.data_entry_mode,
                       X_Layout_mode            => c1_rec.layout_mode,
                       X_Auto_Row_Count         => c1_rec.auto_row_count,
                       X_Default_Parent_Spec    => c1_rec.default_parent_spec,
                       X_Last_Update_Date       => SYSDATE,
                       X_Last_Updated_By        => fnd_global.user_id,
                       X_Creation_Date          => SYSDATE,
                       X_Created_By             => fnd_global.user_id,
                       X_Last_Update_Login      => fnd_global.user_id);

      --return a value of success
      x_old_plan_relationship_id := c1_rec.plan_relationship_id;
      x_return_status := fnd_api.g_true;
   END;

   --this procedure copies all element relationships pertaining to p_old_relationship_id
   --to p_new_plan_relationship_id. returns a status value to indicate success/failure.
   PROCEDURE COPY_ELEMENT_REL(
                           p_old_plan_relationship_id   IN  NUMBER,
                           p_new_plan_relationship_id   IN  NUMBER,
                           x_return_status              OUT NOCOPY VARCHAR2
                           )
   IS
      CURSOR C1 IS
         SELECT parent_char_id, child_char_id, element_relationship_type,
                decode(link_flag,1,'Y','N') as vlink_flag
         FROM   qa_pc_element_relationship
         WHERE  plan_relationship_id = p_old_plan_relationship_id;

      l_new_element_relationship_id NUMBER;
   BEGIN
      --for each element relationship, insert an identical relationship with the
      --new_plan_relationship_id also
      FOR c1_rec IN C1 LOOP
         QA_SS_PARENT_CHILD_PKG.insert_element_rel(
          p_plan_relationship_id      => p_new_plan_relationship_id,
          p_parent_char_id            => c1_rec.parent_char_id,
          p_child_char_id             => c1_rec.child_char_id,
          p_element_relationship_type => c1_rec.element_relationship_type,
          p_link_flag                 => c1_rec.vlink_flag,
          x_element_relationship_id   => l_new_element_relationship_id);
      END LOOP;

      --return a value of success if we make it this far
      x_return_status := fnd_api.g_true;
   END;

   --this procedure copies all criteria pertaining to p_old_plan_relationship_id to
   --p_new_plan_relationship_id.  returns a return_status value to indicate success/failure
   PROCEDURE COPY_CRITERIA(
                           p_old_plan_relationship_id   IN  NUMBER,
                           p_new_plan_relationship_id   IN  NUMBER,
                           x_return_status              OUT NOCOPY VARCHAR2
                           )
   IS
      CURSOR C1 IS
         SELECT char_id, operator, low_value, high_value
         FROM   qa_pc_criteria
         WHERE  plan_relationship_id = p_old_plan_relationship_id;

      l_new_criteria_id NUMBER;
   BEGIN
      --for each criteria, insert an identical one with the new_plan_relationship_id
      FOR c1_rec IN C1 LOOP
        QA_SS_PARENT_CHILD_PKG.insert_criteria_rel(
          p_plan_relationship_id => p_new_plan_relationship_id,
          p_char_id              => c1_rec.char_id,
          p_operator             => c1_rec.operator,
          p_low_value            => c1_rec.low_value,
          p_high_value           => c1_rec.high_value,
          x_criteria_id          => l_new_criteria_id);
      END LOOP;

      --return a value of success if we make it this far
      x_return_status := fnd_api.g_true;

   END;

   --this is a helper procedure that calls the UI mapping code for a given plan_id, x_return_status is
   --fnd_api.g_true on success, fnd_api.g_false on failure
   --this function assumes that fnd_global.apps_initialize has already been called

   -- anagarwa Tue Dec 24 11:44:52 PST 2002
   -- Bug 2725466
   -- The parameter plan_id is being replaced by p_plan_id to comply
   -- with coding standards

   PROCEDURE map_ui_from_plan_id(p_plan_id IN NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2)
   IS
      l_request_id NUMBER;
   BEGIN
      IF p_plan_id IS NOT NULL THEN

         l_request_id := fnd_request.submit_request(application => 'QA',
                                                    program     => 'QLTSSCPB',
                                                    argument1   => 'CREATE',
                                                    argument2   => 'PLAN',
                                                    argument3   => to_char(p_plan_id));
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              'qapccpb.pls', 'copy_all, add ak generation request #'||l_request_id);
           x_return_status := fnd_api.g_true;
        end if;
      ELSE
         x_return_status := fnd_api.g_false;
      END IF;
   END;

   PROCEDURE COPY_ALL(p_source_parent_plan_id   IN  NUMBER,
                      p_source_child_plan_id    IN  NUMBER,
                      p_target_parent_plan_id   IN  NUMBER,
                      p_target_child_plan_id    IN  NUMBER,
                      p_call_mapping            IN  VARCHAR2,
                      x_return_status           OUT NOCOPY VARCHAR2)
   IS
      l_old_plan_relationship_id NUMBER;
      l_new_plan_relationship_id NUMBER;
      l_return_status VARCHAR2(2);
   BEGIN
      --create a savepoint before copying any relationship info
      SAVEPOINT copy_all_pub;

      --attempt to copy plan relationships first
      copy_plan_rel(p_source_parent_plan_id,
                    p_source_child_plan_id,
                    p_target_parent_plan_id,
                    p_target_child_plan_id,
                    l_old_plan_relationship_id,
                    l_new_plan_relationship_id,
                    l_return_status);
      IF l_return_status <> fnd_api.g_true OR l_old_plan_relationship_id = -1 THEN
         x_return_status := fnd_api.g_false;
         RETURN;
      END IF;

      --attempt to copy element relationships next
      copy_element_rel(l_old_plan_relationship_id,
                       l_new_plan_relationship_id,
                       l_return_status);
      IF l_return_status <> fnd_api.g_true THEN
         ROLLBACK TO copy_all_pub;
         x_return_status := fnd_api.g_false;
         RETURN;
      END IF;

      --attempt to copy criteria lastly
      copy_criteria(l_old_plan_relationship_id,
                    l_new_plan_relationship_id,
                    l_return_status);
      IF l_return_status <> fnd_api.g_true THEN
         ROLLBACK TO copy_all_pub;
         x_return_status := fnd_api.g_false;
         RETURN;
      END IF;

      --see if we need to call the mapping functions
      IF p_call_mapping = fnd_api.g_true THEN
         --initialize the app for creating the UI mappings for these plans
         fnd_global.apps_initialize(user_id      => fnd_global.user_id,
                                    resp_id      => 20561,
                                    resp_appl_id => 250);


         map_ui_from_plan_id(p_target_parent_plan_id, x_return_status);
         IF x_return_status <> fnd_api.g_true THEN
            RETURN;
         END IF;

         map_ui_from_plan_id(p_target_child_plan_id, x_return_status);
         IF x_return_status <> fnd_api.g_true THEN
            RETURN;
         END IF;
      END IF;

      --otherwise everything was successfull so return TRUE
      x_return_status := fnd_api.g_true;
   END;

   --this function gets the organization_code from an org id
   FUNCTION get_org_code_from_orgid(p_orgid IN NUMBER)
      RETURN VARCHAR2
   IS
      x_orgcode mtl_parameters.organization_code%TYPE;
      CURSOR C IS
         SELECT organization_code
         FROM mtl_parameters
         WHERE organization_id = p_orgid;
   BEGIN
      OPEN C;
      FETCH C INTO x_orgcode;
      IF C%NOTFOUND THEN
         CLOSE C;
         RETURN NULL;
      ELSE
         CLOSE C;
         RETURN x_orgcode;
      END IF;
   END;

   --this function is copied from qltsswfb.plb to get the user_name from a user_id
   FUNCTION get_user_name(u_id IN NUMBER) RETURN VARCHAR2 IS
      u_name fnd_user.user_name%TYPE;
      cursor c IS
         SELECT DISTINCT fu.user_name FROM
       fnd_user fu
       WHERE
       fu.user_id = u_id;
   BEGIN
      open c;
      fetch c INTO u_name;
      IF c%notfound THEN
         close c;
         RETURN NULL;
      ELSE
         close c;
         RETURN u_name;
      END IF;
   END get_user_name;

   --get_plan_view and get_import_view are copied from qa_plans_pub to build the view names in the view_name and import_view_name
   --for a given plan name
   FUNCTION get_plan_view_name(p_name VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
      return 'Q_' || translate(substr(p_name, 1, 26), ' ''', '__') || '_V';
   END get_plan_view_name;


   FUNCTION get_import_view_name(p_name VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
      return 'Q_' || translate(substr(p_name, 1, 25), ' ''', '__') || '_IV';
   END get_import_view_name;

   --this function copied from qltssreb.plb to parse first half of planid, plan_name
   --token from a flat_string.  returns the planid as a number
   FUNCTION parse_id(x_result IN VARCHAR2, n IN INTEGER,
                     p IN INTEGER, q IN INTEGER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN to_number(substr(x_result, p, q-p));
   END parse_id;


   --this function copied from qltssreb.plb to parse the plan_name from a plan_id,
   --src_plan_name,dest_plan_name token in the flat_string.  returns the plan_name
   --with all double-separator occurrences removed
   FUNCTION parse_value(x_result IN VARCHAR2, n IN INTEGER,
                        p IN OUT NOCOPY INTEGER)
      RETURN plan_info
   IS
      new_info plan_info;
      value qa_plans.name%TYPE;
      c VARCHAR2(10);
      separator CONSTANT VARCHAR2(1) := '@';
      subseparator CONSTANT VARCHAR2(1) := ',';
   BEGIN
      --
      -- Loop until a single @ is found or x_result is exhausted.
      --
      p := p + 1;                   -- add 1 before substr to skip '='
      WHILE p <= n LOOP
         c := substr(x_result, p, 1);
         p := p + 1;
         IF (c = subseparator) THEN
            --we've completed the first name, store it in the new_info record
            new_info.src_name := value;
            value := '';
         ELSIF (c = separator) THEN
            -- take a peak at the next character, if not another @,
            -- we have reached the end so finalize the record
            -- Otherwise, skip this @
            IF substr(x_result, p, 1) <> separator THEN
               new_info.dest_name := value;
               RETURN new_info;
            ELSE
               p := p + 1;
            END IF;
            value := value || c;
         ELSE
            value := value || c;
         END IF;
      END LOOP;

      --out of characters, save the dest_name and return the record
      new_info.dest_name := value;
      RETURN new_info;
   END parse_value;


   --this function is derived from result_to_array() in qltssreb.plb.
   --it goes through the input flat_string, p_str, and parses planid=src_plan_name!dest_plan_name tokens
   --and inserts them into the plans_htable.  it returns an integer return code:
   --0 is success, -1 is failure
   FUNCTION parse_flat_string(p_str IN VARCHAR2,
                              p_replace IN BOOLEAN,
                              x_htable IN OUT NOCOPY plan_htable)
      RETURN INTEGER
   IS
      n INTEGER := length(p_str);
      p INTEGER;            -- starting string position
      q INTEGER;            -- ending string position
      x_plan_id NUMBER;
      new_info plan_info;
   BEGIN
      p := 1;
      WHILE p < n LOOP
         q := instr(p_str, '=', p);
         --
         -- found the first = sign.  To the left, must be char_id
         --
         x_plan_id := parse_id(p_str, n, p, q);
         --
         -- To the right, must be the value
         --
         new_info := parse_value(p_str, n, q);
         IF ((x_htable.exists(x_plan_id) = false) OR
             (x_htable.exists(x_plan_id) AND p_replace)) THEN
            x_htable(x_plan_id) := new_info;
         END IF;
         p := q;
      END LOOP;

      RETURN 0;
   END parse_flat_string;

   --this procedure finds the search data in the repl_htable and returns the full replacement token
   PROCEDURE execute_NCM_find_repl_text(p_search_data IN VARCHAR2,
                                        p_delim IN VARCHAR2,
                                        p_suffix_num IN NUMBER,
                                        p_repl_htable IN ncm_repl_htable,
                                        x_repl_data OUT NOCOPY VARCHAR2)
   IS
      repl_info ncm_repl_info;
      i NUMBER;
      j NUMBER;
   BEGIN
      --try to match the p_search_data to find a repl_str, default repl to p_search_data
      x_repl_data := p_search_data;
      i := p_repl_htable.FIRST;
      WHILE (i IS NOT NULL) LOOP
         repl_info := p_repl_htable(i);

         --check for match in all search strings
         IF repl_info.search_str1 = p_search_data OR
            repl_info.search_str2 = p_search_data OR
            repl_info.search_str3 = p_search_data THEN
            --if it's a match then use the p_suffix to figure out which repl string to use
            IF p_suffix_num = 1 THEN
               x_repl_data := repl_info.repl_str1;
            ELSIF p_suffix_num = 2 THEN
               x_repl_data := repl_info.repl_str2;
            ELSIF p_suffix_num = 3 THEN
               x_repl_data := repl_info.repl_str3;
            END IF;

            --exit the loop looking for a replacement
            EXIT;
         END IF;

         i := p_repl_htable.NEXT(i);
      END LOOP;

      --add delim info to replacement text
      IF x_repl_data IS NOT NULL THEN
         IF p_delim = ' ' THEN
            x_repl_data := p_delim||x_repl_data;
         ELSE
            x_repl_data := p_delim||x_repl_data||p_delim;
         END IF;
      END IF;
   END;

   --this procedure looks through the text for any of our special tokens and then uses the data before the token to do
   --a smart replacement based on the contents of the p_repl_htable
   PROCEDURE execute_NCM_repl_func(p_text IN OUT NOCOPY VARCHAR2,
                                   p_repl_htable IN ncm_repl_htable,
                                   p_ncm_suffix_list IN ncm_suffix_list_t)
   IS
      --initialize the suffix table
      suffix VARCHAR2(30);
      possible_delim VARCHAR2(1);
      i NUMBER;
      rev_search_pos NUMBER;
      token_pos NUMBER;
      delim_pos NUMBER;
      match_count NUMBER := 1;
      text_length NUMBER := length(p_text);
      match_data_token VARCHAR2(32);
      match_full_token VARCHAR2(80);
      repl_data VARCHAR2(32);
   BEGIN
      FOR i IN p_ncm_suffix_list.FIRST..p_ncm_suffix_list.LAST LOOP
         suffix := p_ncm_suffix_list(i);
         token_pos := instr(p_text, suffix, 1, match_count);
         WHILE token_pos <> 0 LOOP
            --dbms_output.put_line('suffix: ('||p_ncm_suffix_list(i)||') found('||token_pos||')');
            possible_delim := substr(p_text, token_pos-1, 1);
            rev_search_pos := token_pos - text_length - 3;
            IF (possible_delim <> SP_NCM_DELIM_CHAR1 AND possible_delim <> SP_NCM_DELIM_CHAR2) THEN
               possible_delim := ' ';
            END IF;
            delim_pos := instr(p_text, possible_delim, rev_search_pos);
            --dbms_output.put_line('possible delim: ('||possible_delim||') found('||delim_pos||')');

            --make sure we found the delim, otherwise skip this match
            IF delim_pos <> 0 THEN
               match_full_token := substr(p_text, delim_pos, token_pos - delim_pos + length(suffix));
               --figure out the data token
               IF possible_delim = ' ' THEN
                  match_data_token := substr(p_text, delim_pos+1, token_pos - delim_pos - 1);
               ELSE
                  match_data_token := substr(p_text, delim_pos+1, token_pos - delim_pos - 2);
               END IF;

               --dbms_output.put_line('match_data_token: ('||upper(match_data_token)||')');
               --try to find the replacement text and do the replacement
               execute_NCM_find_repl_text(upper(match_data_token), possible_delim, i, p_repl_htable, repl_data);
               IF repl_data IS NOT NULL THEN
                  p_text := replace(p_text, match_full_token, repl_data||suffix);
               END IF;
            END IF;
            match_count := match_count + 1;
            token_pos := instr(p_text, suffix, 1, match_count);
         END LOOP;
      END LOOP;
   END;

   --this function is one of the helper functions to execute_spec_proc_requests.  It updates all
   --the actions associated with the NCM project.  it returns either fnd_api.g_true or fnd_api.g_false
   --in x_return_status and uses x_msg_data for any return code reason.
   PROCEDURE execute_NCM_spec_proc_request(p_src_org_id         IN  VARCHAR2,
                                           p_dest_org_code      IN  VARCHAR2,
                                           p_phtable            IN  plan_htable,
                                           x_msg_data           OUT NOCOPY VARCHAR2,
                                           x_return_status      OUT NOCOPY VARCHAR2)
   IS
      i NUMBER;
      suffix VARCHAR2(30);
      l_src_plan_id NUMBER;
      l_dest_plan_id NUMBER;

      repl_info ncm_repl_info;
      repl_htable ncm_repl_htable;

      --this cursor selects all actions for a given plan_id
      CURSOR C1 (p_plan_id NUMBER) IS
         SELECT qpca.plan_char_action_id, qpca.alr_action_id, qpca.message
         FROM qa_plans qp, qa_plan_chars qpc, qa_plan_char_action_triggers qpcat, qa_plan_char_actions qpca
         WHERE qp.plan_id = qpc.plan_id AND qpc.char_id = qpcat.char_id AND qp.plan_id = qpcat.plan_id
         AND qpcat.plan_char_action_trigger_id = qpca.plan_char_action_trigger_id AND qp.plan_id=p_plan_id;
      l_message qa_plan_char_actions.message%TYPE;

      --this cursor get's the body field from alr_actions for a given action_id
      CURSOR C2 (p_alract_id NUMBER) IS
         SELECT body
         FROM alr_actions
         WHERE action_id = p_alract_id AND application_id = 250;
      l_body alr_actions.body%TYPE;

      --initialize the list of suffixes
      ncm_suffix_list ncm_suffix_list_t := ncm_suffix_list_t(SP_NCM_PLAN_NAME_SUFFIX, SP_NCM_VIEW_NAME_SUFFIX, SP_NCM_IMPORT_NAME_SUFFIX);
   BEGIN
      --as a preprocessing step, go through each plan and make the search/replacement names and put them in
      --the repl_htable
      l_src_plan_id := p_phtable.FIRST;
      WHILE (l_src_plan_id IS NOT NULL) LOOP
         repl_info.search_str1 := upper(p_phtable(l_src_plan_id).src_name);
         repl_info.repl_str1   := upper(p_phtable(l_src_plan_id).dest_name);
         repl_info.search_str2 := get_plan_view_name(p_phtable(l_src_plan_id).src_name);
         repl_info.repl_str2   := get_plan_view_name(p_phtable(l_src_plan_id).dest_name);
         repl_info.search_str3 := get_import_view_name(p_phtable(l_src_plan_id).src_name);
         repl_info.repl_str3   := get_import_view_name(p_phtable(l_src_plan_id).dest_name);

         repl_htable(l_src_plan_id) := repl_info;
         l_src_plan_id := p_phtable.NEXT(l_src_plan_id);
      END LOOP;

      --for each target plan, look up every action associated with it
      l_src_plan_id := p_phtable.FIRST;
      WHILE (l_src_plan_id IS NOT NULL) LOOP
         l_dest_plan_id := p_phtable(l_src_plan_id).dest_id;
         --dbms_output.put_line('src planid: "'||l_src_plan_id||'", dest planid: "'||l_dest_plan_id||'"');

         --get every plan_char for this target plan
         FOR c1_rec IN C1(l_dest_plan_id) LOOP
            l_message := c1_rec.message;

            --check if the action has an alr_action_id, if so we need to get the action from the alr_alerts table
            IF c1_rec.alr_action_id IS NOT NULL THEN
               FOR c2_rec IN C2(c1_rec.alr_action_id) LOOP
                  l_body := c2_rec.body;

                  --now we do the replacement function on l_body
                  execute_NCM_repl_func(l_body, repl_htable, ncm_suffix_list);

                  --and update the ALR_ACTIONS table
                  UPDATE ALR_ACTIONS SET BODY = l_body WHERE APPLICATION_ID=250 AND ACTION_ID = c1_rec.alr_action_id;
               END LOOP;
            END IF;

            --dbms_output.put_line('begin actid '||c1_rec.plan_char_action_id);
            --make sure the message has something in it
            IF l_message IS NOT NULL THEN
               --now check the message field
               execute_NCM_repl_func(l_message, repl_htable, ncm_suffix_list);

               --and update the QA_PLAN_CHAR_ACTIONS table
               UPDATE QA_PLAN_CHAR_ACTIONS SET MESSAGE = l_message WHERE PLAN_CHAR_ACTION_ID = c1_rec.plan_char_action_id;
            END IF;
            --dbms_output.put_line('done actid '||c1_rec.plan_char_action_id);
         END LOOP;
         l_src_plan_id := p_phtable.NEXT(l_src_plan_id);
      END LOOP;

      --return that we succceeded in action processing
      x_return_status := fnd_api.g_true;
   EXCEPTION
      WHEN OTHERS THEN
         x_msg_data := 'Special Processing Request "'||SP_NCM||'" encountered an error: Code('||SQLCODE||'), Message("'||SQLERRM||'")';
         x_return_status := fnd_api.g_false;
         RETURN;
   END;

   --this function takes the p_src_org_id, p_dest_org_code, and p_phtable representing
   --the source and duplicate schema information and applies all special processing requests in
   --the p_special_proc_field string and returns a success/failure indicator in x_return_status and an
   --optional failure message in x_msg_data
   --p_special_proc_field is of the form <token1>@<token2>@...
   --x_return_status = fnd_api.g_true on success, fnd_api.g_false on failure
   PROCEDURE execute_spec_proc_requests(p_src_org_id            IN  VARCHAR2,
                                        p_dest_org_code         IN  VARCHAR2,
                                        p_phtable               IN  plan_htable,
                                        p_special_proc_field    IN  VARCHAR2,
                                        x_msg_data              OUT NOCOPY VARCHAR2,
                                        x_return_status         OUT NOCOPY VARCHAR2)
   IS
      n INTEGER := length(p_special_proc_field);
      p INTEGER;            -- starting string position
      q INTEGER;            -- ending string position
      separator CONSTANT VARCHAR2(1) := '@';
      token VARCHAR2(200);
   BEGIN
      --to allow for multiple, ordered special processing requests on a schema, parse the
      --p_special_proc_field for the separator
      p := 1;
      WHILE p < n LOOP
         q := instr(p_special_proc_field, separator, p);

         --if we didn't find the separator, grab the rest of the string
         IF (q = 0) THEN
            token := substr(p_special_proc_field, p);
            p := n;
         ELSE
            token := substr(p_special_proc_field, p, (q-p));
            p := q + 1;
         END IF;

         IF (token = SP_NCM) THEN
            execute_NCM_spec_proc_request(p_src_org_id    => p_src_org_id,
                                          p_dest_org_code =>p_dest_org_code,
                                          p_phtable       => p_phtable,
                                          x_msg_data      => x_msg_data,
                                          x_return_status => x_return_status);
         ELSE
            x_return_status := fnd_api.g_false;
            x_msg_data := 'Error while executing special processing requests!  Special Processing Request Identifier "'||token||'" invalid.';
            RETURN;
         END IF;

         --see if the special processing function returned ok, if not return
         IF x_return_status <> fnd_api.g_true THEN
            RETURN;
         END IF;

      END LOOP;

      --x_msg_data := '';
      x_return_status := fnd_api.g_true;
   END;

   --this function is used by setup_plans to make sure that there isn't a duplicate plan name.
   --instead of checking the full name, however, it checks the first 25 characters since the view names
   --generated from the plan name require the first 25 characters be unique
   --returns 0 on success, -1 on failure
   FUNCTION check_plan_name(p_plan_name IN VARCHAR2)
                            RETURN INTEGER
   IS
      CURSOR C1 IS
         -- anagarwa Tue Dec 24 11:44:52 PST 2002
         -- Bug 2725466
         -- Changing SYS.DUAL to DUAL as this is the correct coding standard
         -- The code may fail in databases that do not have SYS schema
         SELECT 1 FROM DUAL
         WHERE NOT EXISTS
            (SELECT 1 FROM qa_plans
             WHERE translate(substr(upper(name),1,25),' ''','__') =
             translate(substr(upper(p_plan_name),1,25),' ''','__'));

      C1_rec C1%ROWTYPE;
   BEGIN
      --dbms_output.put_line('entered check_plan_name with name: '||p_plan_name||', mauled: '||translate(substr(upper(p_plan_name), 1, 25), ' ''', '__'));
      OPEN C1;
      FETCH C1 INTO C1_rec;
      IF C1%NOTFOUND THEN
         --dbms_output.put_line('got in the good case');
         CLOSE C1;
         RETURN -1;
      ELSE
         --dbms_output.put_line('got in the else case');
         CLOSE C1;
         RETURN 0;
      END IF;
   END;

   --To handle capturing an eSignature for each newly created plan, we have a parameter that
   --forces all new plans to be created as disabled.  This is implemented by moving the
   --Effective To and Effective From dates to something which makes sense.
   --optional failure message in x_msg_data
   --x_return_status = fnd_api.g_true on success, fnd_api.g_false on failure
   PROCEDURE disable_plans(p_phtable            IN  plan_htable,
                           x_msg_data           OUT NOCOPY VARCHAR2,
                           x_return_status      OUT NOCOPY VARCHAR2)
   IS
      i INTEGER;
      j INTEGER;
      n INTEGER := p_phtable.COUNT;
      c1 NUMBER;
      c2 NUMBER;
      fetch_count NUMBER;
      ignore NUMBER;
      indx NUMBER := 1;

      id_table          dbms_sql.Number_Table;
      from_table        dbms_sql.Date_Table;
      to_table          dbms_sql.Date_Table;
      select_string     VARCHAR2(4000);
      update_string     VARCHAR2(4000);
   BEGIN
      --sanity check
      IF p_phtable.COUNT < 1 THEN
         x_msg_data := '';
         x_return_status := fnd_api.g_true;
         RETURN;
      END IF;

      --init the sql string
      select_string := 'select plan_id, effective_from, effective_to from qa_plans where plan_id in (';
      FOR i in 1..n LOOP
         IF i <> n THEN
            select_string := select_string || ':' || to_char(i) || ', ';
         ELSE
            select_string := select_string || ':' || to_char(i) || ')';
         END IF;
      END LOOP;

      --use dbms_sql to execute the sql
      c1 := dbms_sql.open_cursor;
      dbms_sql.parse(c1, select_string, dbms_sql.native);

      --bind using the dest plan_ids from the phtable
      i := p_phtable.FIRST;
      j := 1;
      WHILE (i IS NOT NULL) LOOP
         dbms_sql.bind_variable(c1, ':' || to_char(j), p_phtable(i).dest_id);
         i := p_phtable.NEXT(i);
         j := j + 1;
      END LOOP;

      --set up the bulk collect arrays
      dbms_sql.define_array(c1, 1, id_table, 20, indx);
      dbms_sql.define_array(c1, 2, from_table, 20, indx);
      dbms_sql.define_array(c1, 3, to_table, 20, indx);

      --execute the sql and collect the results
      ignore := dbms_sql.execute(c1);
      loop
         fetch_count := dbms_sql.fetch_rows(c1);

         dbms_sql.column_value(c1, 1, id_table);
         dbms_sql.column_value(c1, 2, from_table);
         dbms_sql.column_value(c1, 3, to_table);

         exit when fetch_count <> 20;
      end loop;
      dbms_sql.close_cursor(c1);

      --make sure we got everything
      IF id_table.COUNT <> n THEN
         x_msg_data := 'Invalid fetch count('||id_table.COUNT||'), expecting('||n||').';
         x_return_status := fnd_api.g_false;
         RETURN;
      END IF;

      --now go through each plan_id and modify the dates
      FOR j in 1..n LOOP
         IF to_table(j) IS NULL OR to_table(j) >= TRUNC(SYSDATE) THEN
            to_table(j) := TRUNC(SYSDATE) - 1;
            --move the from back if it's now later than the to
            IF from_table(j) > to_table(j) THEN
               from_table(j) := to_table(j) - 1;
            END IF;
         END IF;
      END LOOP;

      --now perform the bulk DML update
      update_string := 'UPDATE QA_PLANS SET effective_from = :1, effective_to = :2 WHERE plan_id = :3';
      c2 := dbms_sql.open_cursor;
      dbms_sql.parse(c2, update_string, dbms_sql.native);
      dbms_sql.bind_array(c2, ':1', from_table);
      dbms_sql.bind_array(c2, ':2', to_table);
      dbms_sql.bind_array(c2, ':3', id_table);
      ignore := dbms_sql.execute(c2);
      dbms_sql.close_cursor(c2);

      --return success
      x_msg_data := '';
      x_return_status := fnd_api.g_true;

   exception when others then
      if dbms_sql.is_open(c1) then
         dbms_sql.close_cursor(c1);
      end if;
      if dbms_sql.is_open(c2) then
         dbms_sql.close_cursor(c2);
      end if;
      x_msg_data := 'unexpected error: Code('||SQLCODE||'), Message("'||SQLERRM||'")';
      x_return_status := fnd_api.g_false;
      RETURN;
   END;

   FUNCTION SETUP_PLANS(p_src_org_id            IN  VARCHAR2,
                        p_dest_org_code         IN  VARCHAR2,
                        p_plans_flatstring      IN  VARCHAR2,
                        p_root_plan_src_id      IN  VARCHAR2,
                        x_root_plan_dest_id     OUT NOCOPY NUMBER,
                        p_special_proc_field    IN  VARCHAR2,
                        p_disable_plans         IN  VARCHAR2,
                        x_return_msg            OUT NOCOPY VARCHAR2,
                        x_index_drop_list       OUT NOCOPY VARCHAR2)
                        RETURN INTEGER
   IS
      phtable plan_htable;
      this_plan plan_info;
      src_org_code org_organization_definitions.organization_code%TYPE;
      src_org_id NUMBER;
      ret_code INTEGER;
      row_count INTEGER := 0;
      src_id NUMBER;
      dest_id NUMBER;
      child_id NUMBER;
      l_request_id NUMBER;

      user_name fnd_user.user_name%TYPE := get_user_name(fnd_global.user_id);
      --user_name fnd_user.user_name%TYPE := 'MFG';
      CURSOR C1(parent_id NUMBER) IS
         SELECT child_plan_id
         FROM qa_pc_plan_relationship
         WHERE parent_plan_id = parent_id;

   -- Bug 3926150. Performance: searching on softcoded element improved by functional indexes.
   -- Added the cursor qa_pc, which returns char details of enabled functional indexes.
   -- Please see bugdb/design document for more details.
   -- srhariha. Tue Nov 30 11:59:20 PST 2004

       CURSOR qa_pc(p_plan_id NUMBER) IS
          SELECT qpc.char_id,qpc.result_column_name,qc.name
          FROM qa_plan_chars qpc,qa_chars qc, qa_char_indexes qci
          WHERE qpc.plan_id = p_plan_id
          AND qpc.char_id = qc.char_id
          AND qpc.char_id = qci.char_id
          AND qci.enabled_flag = 1;
          -- AND qa_char_indexes_pkg.index_exists_and_enabled(qc.char_id) = 1;
      --local variables to facilitate certain function calls
      l_return_status                   VARCHAR2(2);
      l_msg_count                       NUMBER;
      l_msg_data                        VARCHAR2(2000);
      l_msg                             VARCHAR2(2000);
      l_slog                            boolean         := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      l_plog                            boolean         := FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;

      -- Bug 3926150. Performance: searching on softcoded element improved by functional indexes.
      -- Added two local variables.
      -- Please see bugdb/design document for more details.
      -- srhariha. Tue Nov 30 11:59:20 PST 2004


      -- total message size can be 1260.
      char_id_list                      VARCHAR2(2000);
      l_temp  NUMBER;
   BEGIN
      if FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'qapccpb.pls', 'entered setup_plans');
      end if;
      --fnd_log.string(FND_LOG.LEVEL_UNEXPECTED, 'qapccpb.pls', 'entered setup_plans');

      --reinitialize the message list for this attempt at duplication
      fnd_msg_pub.initialize;

      --parse the source_plan_id, dest_plan_name tokens from the flat_string into
      --a name hash table
      ret_code := parse_flat_string(p_plans_flatstring, false, phtable);
      IF (ret_code < 0) THEN
         x_return_msg := 'setup_plans: failed to parse the provided plans_flatstring.';
         RETURN -1;
      END IF;

      --lookup the org code for this org id
      src_org_id := to_number(p_src_org_id);
      src_org_code := get_org_code_from_orgid(src_org_id);

      --make a savepoint before doing the batch of plan creations
      SAVEPOINT setup_plans_pub;

      --first, try to duplicate each involved plan and place the destination's plan id in
      --the htable
      src_id := phtable.FIRST;
      WHILE (src_id IS NOT NULL) LOOP
         --dbms_output.put_line('row'||row_count||': "'||src_id||'", "'||phtable(src_id).src_name||'", "'||phtable(src_id).dest_name||'"');

         --get a reference to this plan's info
         this_plan := phtable(src_id);

         --even though copy_collection_plan checks the destination name to make sure it's
         --unique, it doesn't tell us that it didn't copy the plan so we have to explicitly
         --check here first and make sure that we check only the first 25 chars
         ret_code := check_plan_name(this_plan.dest_name);
         IF (ret_code < 0) THEN
            ROLLBACK TO setup_plans_pub;
            fnd_message.set_name('QA', 'QA_PC_COPY_DUPLICATE_NAME');
            fnd_message.set_token('DESTPLANNAME', this_plan.dest_name);
            fnd_msg_pub.add();
            x_return_msg := 'dupilicate dest name:'||this_plan.dest_name||', retcode: '||ret_code;
            RETURN -1;
         END IF;

         --call the copy_collection_plan procedure
         qa_plans_pub.copy_collection_plan(
           p_api_version          => 1.0,
           p_user_name            => user_name,
           p_plan_name            => this_plan.src_name,
           p_organization_code    => src_org_code,
           p_to_plan_name         => this_plan.dest_name,
           p_to_organization_code => p_dest_org_code,
           x_to_plan_id           => phtable(src_id).dest_id,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data,
           x_return_status        => l_return_status);
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            ROLLBACK TO setup_plans_pub;
            x_return_msg := 'setup_plans,copy collection_plan: src_plan('||
               phtable(src_id).src_name||'), dest_plan('||phtable(src_id).dest_name||
               ') returned with an error.';
            RETURN -1;
         END IF;

         src_id := phtable.NEXT(src_id);
         row_count := row_count + 1;
      END LOOP;

      --now that all the duplicate plans exist, we go through each plan and check if the child is
      --created and if so copy the link
      src_id := phtable.FIRST;
      row_count := 0;
      WHILE (src_id IS NOT NULL) LOOP
         FOR C1_rec IN C1(src_id) LOOP
            child_id := C1_rec.child_plan_id;
            --see if we duplicated this child in the last loop
            IF (phtable.EXISTS(child_id)) THEN
               --child plan was copied so perform the copy_all between this parent and child with no mapping
               copy_all(p_source_parent_plan_id => src_id,
                                   p_source_child_plan_id  => child_id,
                                   p_target_parent_plan_id => phtable(src_id).dest_id,
                                   p_target_child_plan_id  => phtable(child_id).dest_id,
                                   p_call_mapping          => fnd_api.g_false,
                                   x_return_status         => l_return_status);
               IF l_return_status <> fnd_api.g_true THEN
                  x_return_msg := 'setup_plans, copy_all: src_parent_id('||src_id||
                     '),src_child_id('||child_id||'), dest_parent_id('||
                     phtable(src_id).dest_id||'), dest_child_id('||phtable(child_id).dest_id||
                     ') failed.';
                  ROLLBACK TO setup_plans_pub;
                  RETURN -1;
               END IF;
            END IF;
         END LOOP;
         src_id := phtable.NEXT(src_id);
         row_count := row_count + 1;
      END LOOP;


   -- Bug 3926150. Performance: searching on softcoded element improved by functional indexes.
   -- Compiling the list of char elements whose functional index must be dropped.
   -- Please see bugdb/design document for more details.
   -- srhariha. Tue Nov 30 11:59:20 PST 2004



      src_id := phtable.FIRST;
      row_count := 0;
      char_id_list := null;

      WHILE (src_id IS NOT NULL) LOOP
         FOR qa_pc_rec in qa_pc(phtable(src_id).dest_id) LOOP -- fetch all indexed softcoded chars

            if qa_pc_rec.result_column_name =
                                  qa_char_indexes_pkg.get_default_result_column(qa_pc_rec.char_id) then
                null; -- no need to drop because it is already the best fit.
            else
               l_temp := qa_char_indexes_pkg.disable_index(qa_pc_rec.char_id); -- disable the index

                -- To restrict message length to 1260. (60 is an offset for message content)
                if((nvl(length(char_id_list),0) + nvl(length(qa_pc_rec.name),0)) < 1200) then
                  char_id_list := char_id_list || ', ' || qa_pc_rec.name;
                end if;
            end if;
        END LOOP;

         src_id := phtable.NEXT(src_id);
         row_count := row_count + 1;
      END LOOP;


      --at this point, we've fully duplicated the schema. now check if any special processing needs to be done
      execute_spec_proc_requests(p_src_org_id          => p_src_org_id,
                                 p_dest_org_code       => p_dest_org_code,
                                 p_phtable             => phtable,
                                 p_special_proc_field  => p_special_proc_field,
                                 x_msg_data            => l_msg_data,
                                 x_return_status       => l_return_status);
      IF l_return_status <> fnd_api.g_true THEN
         ROLLBACK TO setup_plans_pub;
         x_return_msg := 'setup_plans,execute special processing requests: returned "'||l_msg_data||'"';
         RETURN -1;
      END IF;

      --here we put in the call to either create the dynamic views/UI mapping regions or to
      --change the effective from/to dates if p_disable_plans is enabled
      IF p_disable_plans IS NOT NULL and p_disable_plans = 'Y' THEN
         disable_plans(p_phtable        => phtable,
                       x_msg_data       => l_msg_data,
                       x_return_status  => l_return_status);
         IF l_return_status <> fnd_api.g_true THEN
            ROLLBACK TO setup_plans_pub;
            x_return_msg := 'setup_plans,execute disable_plans: returned "'||l_msg_data||'"';
            RETURN -1;
         END IF;
      ELSE
         --initialize the app for creating dynamic views
         fnd_global.apps_initialize(user_id      => fnd_global.user_id,
                                    resp_id      => 20561,
                                    resp_appl_id => 250);

         src_id := phtable.FIRST;
         WHILE (src_id IS NOT NULL) LOOP
            --get a reference to this plan's info
            this_plan := phtable(src_id);

            l_request_id := fnd_request.submit_request(application => 'QA',
                                                       program     => 'QLTPVWWB',
                                                       argument1   => get_plan_view_name(this_plan.dest_name),
                                                       argument2   => NULL,
                                                       argument3   => to_char(this_plan.dest_id),
                                                       argument4   => get_import_view_name(this_plan.dest_name),
                                                       argument5   => NULL,
                                                       argument6   => NULL);
            if FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'qapccpb.pls', 'add view generation request #'||l_request_id);
            end if;

            l_request_id := fnd_request.submit_request(application => 'QA',
                                                       program     => 'QLTSSCPB',
                                                       argument1   => 'CREATE',
                                                       argument2   => 'PLAN',
                                                       argument3   => to_char(this_plan.dest_id));
            if FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'qapccpb.pls', 'add ui generation request #'||l_request_id);
            end if;
            src_id := phtable.NEXT(src_id);
         END LOOP;
      END IF;

      --make one final call to regen the global view
      l_request_id := fnd_request.submit_request(application => 'QA',
                                                 program     => 'QLTPVWWB',
                                                 argument1   => NULL,
                                                 argument2   => NULL,
                                                 argument3   => NULL,
                                                 argument4   => NULL,
                                                 argument5   => NULL,
                                                 argument6   => 'QA_GLOBAL_RESULTS_V');
      if FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'qapccpb.pls', 'add global view generation request #'||l_request_id);
      end if;

      ret_code := 0;
      --x_return_msg := '';
      x_return_msg := l_msg_data;
      IF (p_root_plan_src_id IS NULL OR p_root_plan_src_id = '' OR p_root_plan_src_id = '-1') THEN
         x_root_plan_dest_id := 0;
      ELSE
         x_root_plan_dest_id := phtable(to_number(p_root_plan_src_id)).dest_id;
      END IF;

      -- Bug 3926150. Performance: searching on softcoded element improved by functional indexes.
      -- Put list into OUT parameter x_index_drop_list after stripping initial comma.
      -- Please see bugdb/design document for more details.
      -- srhariha. Tue Nov 30 11:59:20 PST 2004

      if(char_id_list is not null) then
         x_index_drop_list := substr(char_id_list,2);
      end if;

      RETURN ret_code;

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK TO setup_plans_pub;
         x_return_msg := 'setup_plans, unhandled exception:: Code('||SQLCODE||'), Message("'||SQLERRM||'")';
         --x_return_msg := 'setup_plans, unhandled exception occurred.';
         RETURN -1;
   END;

END QA_PARENT_CHILD_COPY_PKG;

/
