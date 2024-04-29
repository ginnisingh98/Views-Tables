--------------------------------------------------------
--  DDL for Package Body EGO_GROUP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_GROUP_WF_PKG" AS
/* $Header: EGOPGWFB.pls 120.1 2006/01/31 01:40:19 vkeerthi noship $ */

  G_PACKAGE_NAME            CONSTANT  VARCHAR2(30) := 'EGO_GROUP_WF_PKG';
  G_USER_MAIL_PREFERENCE    CONSTANT  VARCHAR2(30) := 'MAILHTML';
  G_ITEM_TYPE               CONSTANT  VARCHAR2(30) := 'EGOGROUP';
  G_GROUP_OBJECT_NAME       CONSTANT  VARCHAR2(30) := 'EGO_GROUP';

--  G_OWNER_GROUP_REL_TYPE    CONSTANT  VARCHAR2(30) := 'EGO_GROUP_OWNERSHIP';
--  G_OWNER_GROUP_REL_CODE    CONSTANT  VARCHAR2(30) := 'OWNER_OF';

  G_MEMBER_GROUP_REL_TYPE   CONSTANT  VARCHAR2(30) := 'MEMBERSHIP';
  G_MEMBER_GROUP_REL_CODE   CONSTANT  VARCHAR2(30) := 'MEMBER_OF';

  ------------------------------------------------------------------------
  -- Attributes used for populating by the Unmarshall_Xml procedure
  ------------------------------------------------------------------------
  G_OWNER_ID                CONSTANT  VARCHAR2(50) :='EGO_OWNER_ID';
  G_OWNER_NAME              CONSTANT  VARCHAR2(50) :='EGO_OWNER_NAME';
  G_OWNER_USER_NAME         CONSTANT  VARCHAR2(50) :='EGO_OWNER_USER_NAME';
  G_GROUP_ID                CONSTANT  VARCHAR2(50) :='EGO_GROUP_ID';
  G_GROUP_NAME              CONSTANT  VARCHAR2(50) :='EGO_GROUP_NAME';
  G_MEMBER_ID               CONSTANT  VARCHAR2(50) :='EGO_MEMBER_ID';
  G_MEMBER_NAME             CONSTANT  VARCHAR2(50) :='EGO_MEMBER_NAME';
  G_MEMBER_USER_NAME        CONSTANT  VARCHAR2(50) :='EGO_MEMBER_USER_NAME';
  G_GROUP_MEMBER_REL_ID     CONSTANT  VARCHAR2(50) :='EGO_GROUP_MEMBER_REL_ID';
  G_MEMBER_NOTE             CONSTANT  VARCHAR2(50) :='EGO_MEMBER_NOTE';
  G_OWNER_NOTE              CONSTANT  VARCHAR2(50) :='EGO_OWNER_NOTE';
  G_RESPONDER_NAME          CONSTANT  VARCHAR2(50) :='EGO_RESPONDER_NAME';
  ------------------------------------------------------------------------
  -- Process types (used for branching in code)
  ------------------------------------------------------------------------
  G_ADD_GROUP_MEMBER_TYPE       CONSTANT  NUMBER := 0;
  G_REMOVE_GROUP_MEMBER_TYPE    CONSTANT  NUMBER := 1;
  G_DELETE_GROUP_TYPE           CONSTANT  NUMBER := 2;
  G_SUBSCR_OWNER_NOTF_TYPE      CONSTANT  NUMBER := 3;
  G_UNSUBSCR_OWNER_NOTF_TYPE    CONSTANT  NUMBER := 4;
  G_ALL_POSSIBLE_VALUES_TYPE    CONSTANT  NUMBER := 100;
  G_IDS_NAMES_USERNAMES_TYPE    CONSTANT  NUMBER := 101;

  ------------------------------------------------------------------------
  -- Process names
  ------------------------------------------------------------------------
  G_ADD_GROUP_MEMBER_PROCESS    CONSTANT  VARCHAR2(30) := 'ADD_GROUP_MEMBER_PROCESS';
  G_REMOVE_GROUP_MEMBER_PROCESS CONSTANT  VARCHAR2(30) := 'REMOVE_GROUP_MEMBER_PROCESS';
  G_DELETE_GROUP_PROCESS        CONSTANT  VARCHAR2(30) := 'DELETE_GROUP_PROCESS';
  G_SUBSCR_OWNER_NOTF_PROCESS   CONSTANT  VARCHAR2(30) := 'NOTIFY_SUBSCR_CONF_PROCESS';
  G_UNSUBSCR_OWNER_NOTF_PROCESS CONSTANT  VARCHAR2(30) := 'NOTIFY_UNSUBSCR_CONF_PROCESS';

  G_NOTE                  VARCHAR2(50) :='NOTE';
  G_COMPLETE_STATUS       VARCHAR2(50) :='COMPLETE';

  -----------------------------------------------
  --   CURSOR to get the administrators list   --
  -----------------------------------------------
--PERF TUNING :4956096
  CURSOR c_get_admin_list (cp_group_id        IN  NUMBER ) IS
 SELECT user1.user_name, user1.party_id, user1.party_name, f.grantee_key
     FROM fnd_grants f, fnd_menus m, fnd_objects o, ego_user_v user1
     WHERE f.instance_pk1_value = to_char(cp_group_id)
      AND f.start_date <= SYSDATE
      AND NVL(f.end_date, SYSDATE) >= SYSDATE
      AND (f.grantee_key like 'HZ_PARTY:%'
            AND REPLACE(f.grantee_key,'HZ_PARTY:','')  = user1.party_id)
      AND f.menu_id = m.menu_id
      AND m.menu_name = 'EGO_MANAGE_GROUP'
      AND f.object_id = o.object_id
      AND o.obj_name = 'EGO_GROUP';

----------------------------------------------------------------------------
--                   PROCEDURES THAT ARE CALLED INTERNALLY                --
--                  NO INTERFACE PROVIDED TO EXTERNAL WORLD               --
----------------------------------------------------------------------------

---------------------------------------------------------------------
   -- For debugging purposes.
   PROCEDURE mdebug (msg IN varchar2) IS
     BEGIN
--       dbms_output.put_line(msg);
--sri_debug('3354437 - '||msg);
       null;
     END mdebug;
---------------------------------------------------------------------

----------------------------------------------------------------------------
-- A. Get_Mail_Pref
----------------------------------------------------------------------------
FUNCTION get_mail_pref(p_party_id IN NUMBER)  RETURN VARCHAR2  IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Function name   : get_email_pref
    -- Type            : Private
    -- Pre-reqs        : None
    -- Functionality   : Gets the mail preferences of the user
    -- Notes           :
    --
    -- Parameters:
    --     IN          : p_party_id      IN  NUMBER   (Required)
    --                   party whose email preference is required.
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  CURSOR c_get_mail_pref (cp_party_id NUMBER) IS
    SELECT preference_value
    FROM   fnd_user_preferences user_prefs,
           fnd_user users,
	   hz_parties parties
    WHERE  user_prefs.preference_name = 'MAILTYPE'
      AND  user_prefs.user_name       = users.user_name
      AND  users.customer_id          = parties.party_id
      AND  parties.party_id           = cp_party_id;

  l_mail_pref     FND_USER_PREFERENCES.PREFERENCE_VALUE%TYPE;

  BEGIN
    --retrieve mail preference for the owner
    OPEN c_get_mail_pref(cp_party_id => p_party_id);
    FETCH c_get_mail_pref INTO l_mail_pref;
    IF c_get_mail_pref%NOTFOUND THEN
      l_mail_pref := G_USER_MAIL_PREFERENCE;
    ELSE
      IF l_mail_pref IS NULL THEN
        l_mail_pref := G_USER_MAIL_PREFERENCE;
      END IF;
    END IF;
    CLOSE c_get_mail_pref;
mdebug('mail pref : party_id '|| To_char(p_party_id) || ' is ' || l_mail_pref);
    RETURN l_mail_pref;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_get_mail_pref%ISOPEN THEN
        CLOSE c_get_mail_pref;
      END IF;
      RAISE;
  END get_mail_pref;
  ---------------------------------------------------------------------

----------------------------------------------------------------------------
-- B. Parse_Name_Value_Pairs_Msg
----------------------------------------------------------------------------
PROCEDURE Parse_Name_Value_Pairs_Msg
   (p_message      IN   VARCHAR2
   ,x_name_tbl     OUT  NOCOPY VARCHAR_TBL_TYPE
   ,x_value_tbl    OUT  NOCOPY VARCHAR_TBL_TYPE
   ) IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Function name   : Parse_Name_Value_Pairs_Msg
    -- Type            : Private
    -- Pre-reqs        : None
    -- Functionality   : Parse message into name and value tables
    --                   implements Hashtable like functionality
    -- Notes           :
    --
    -- Parameters:
    --     IN          : p_message      IN  VARCHAR2   (Required)
    --                   text whose name,value pair is desired
    --
    -- Called From:
    --      Start_Subscription_Process
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

    l_index     NUMBER;
    pos1        NUMBER;
    pos2        NUMBER;
    pos3        NUMBER;
    l_message   VARCHAR2(32767);

  BEGIN
    -- parse the payload
    -- TO DO: parse the event_payload and intialize a table of records
    -- mimicing a hashtable
    l_message := p_message;
    l_index   := 0;
    WHILE length(l_message) > 0 LOOP
      pos1:=instr(l_message,'<');
      pos2:=instr(l_message,'>');
      IF (pos1 >0) THEN
         x_name_tbl(l_index)  := substr(l_message, pos1+1, pos2- (pos1+1));
         pos3                 := instr(l_message,'</') ;
         x_value_tbl(l_index) := substr(l_message, pos2+1, pos3 - (pos2+1));
         l_message            := substr(l_message, pos2 - pos1 + pos3 + 2);
         l_index              := l_index + 1;
      ELSE
         EXIT;
      END IF;
   END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
      RAISE;
  END Parse_Name_Value_Pairs_Msg;
  ---------------------------------------------------------------------

----------------------------------------------------------------------------
-- C. Unmarshall_Xml
----------------------------------------------------------------------------
  PROCEDURE Unmarshall_Xml
  (
    p_process_type      IN   NUMBER,
    p_name_values_xml   IN   VARCHAR2,
    x_names_tbl         OUT  NOCOPY EGO_GROUP_WF_PKG.VARCHAR_TBL_TYPE,
    x_values_tbl        OUT  NOCOPY EGO_GROUP_WF_PKG.VARCHAR_TBL_TYPE
  )
  IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Unmarshall_Xml
    -- Type            : Private
    -- Pre-reqs        : None
    -- Functionality   : Returns Names and Values tables.
    --                   Contents of these tables are dictated by p_process_type
    --
    -- Notes           :
    --
    -- Parameters:
    --     IN    : process_type     IN  NUMBER   (Required)
    --             process_type

    --     IN    : p_names_values_xml IN  VARCHAR2 (Required)
    --             name value pairs combination string

    --     IN    : p_names_tbl      OUT EGO_GROUP_WF_PKG..VARCHAR_TBL_TYPE
    --             names table (generated after parsing p_names_values_xml)

    --     IN    : p_values_tbl     OUT EGO_GROUP_WF_PKG..VARCHAR_TBL_TYPE
    --             values table (generated after parsing p_values_values_xml)
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

    l_names_tbl      EGO_GROUP_WF_PKG.VARCHAR_TBL_TYPE;
    l_values_tbl     EGO_GROUP_WF_PKG.VARCHAR_TBL_TYPE;

    l_names_out_tbl      EGO_GROUP_WF_PKG.VARCHAR_TBL_TYPE;
    l_values_out_tbl     EGO_GROUP_WF_PKG.VARCHAR_TBL_TYPE;

    --index for looping
    i                              NUMBER;

    l_owner_id_exists              BOOLEAN :=FALSE;
    l_owner_name_exists            BOOLEAN :=FALSE;
    l_owner_user_name_exists       BOOLEAN :=FALSE;
    l_group_id_exists              BOOLEAN :=FALSE;
    l_group_name_exists            BOOLEAN :=FALSE;
    l_member_id_exists             BOOLEAN :=FALSE;
    l_member_name_exists           BOOLEAN :=FALSE;
    l_member_user_name_exists      BOOLEAN :=FALSE;
    l_group_member_rel_id_exists   BOOLEAN :=FALSE;
    l_note_exists                  BOOLEAN :=FALSE;

    l_owner_id                     NUMBER;
    l_owner_name                   HZ_PARTIES.PARTY_NAME%TYPE;
    l_owner_user_name              VARCHAR2(50);
    l_group_id                     NUMBER;
    l_group_name                   HZ_PARTIES.PARTY_NAME%TYPE;
    l_member_id                    NUMBER;
    l_member_name                  HZ_PARTIES.PARTY_NAME%TYPE;
    l_member_user_name             VARCHAR2(50);
    l_group_member_rel_id          NUMBER;
    l_note                         VARCHAR2(999);

  CURSOR get_user_party_names_c (p_party_id NUMBER) IS
-- fix for 3102621 changing the query
--     SELECT users.user_name, parties.party_name
--       FROM fnd_user users, hz_parties parties
--       WHERE users.customer_id = parties.party_id
--       AND   parties.party_id = p_party_id;
--PERF TUNINIG :4956096
      SELECT user_name, party_name
        FROM  ego_user_v
        WHERE party_id = p_party_id;

--  CURSOR get_owner_user_party_names_c (p_group_id NUMBER) IS
--     SELECT users.user_name, parties.party_name
--     FROM   fnd_user users, hz_parties parties, hz_relationships grp_owner
--     WHERE  grp_owner.object_id         = p_group_id
--       AND  grp_owner.relationship_type = G_OWNER_GROUP_REL_TYPE
--       AND  grp_owner.status            = 'A'
--       AND  SYSDATE BETWEEN grp_owner.start_date
--                  AND NVL(grp_owner.end_date,SYSDATE)
--       AND  parties.party_id            = grp_owner.subject_id
--       AND  users.customer_id           = parties.party_id;


  CURSOR get_group_member_rel_id_c (p_group_id NUMBER, p_member_id NUMBER) IS
     SELECT relationship_id
     FROM   hz_relationships
     WHERE  subject_id        = p_member_id
       AND  object_id         = p_group_id
       AND  status            = 'A'
       AND  relationship_type = G_MEMBER_GROUP_REL_TYPE
       AND  SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);


BEGIN
mdebug ('  UNMARSHALL_XML (UXML) : ....1.... ');

   -- Parse the attributes
   Parse_Name_Value_Pairs_Msg
       (p_message     => p_name_values_xml
       ,x_name_tbl    => l_names_tbl
       ,x_value_tbl   => l_values_tbl
       );

   IF ( l_names_tbl.count > 0) THEN
     FOR i IN l_names_tbl.first .. l_names_tbl.last LOOP
mdebug('UXML:  Name - ' || l_names_tbl(i)|| ' Value - '||l_values_tbl(i));
        IF( l_names_tbl(i) = G_OWNER_ID ) THEN
	   l_owner_id_exists := TRUE;
	   l_owner_id := To_number(l_values_tbl(i));
        ELSIF (l_names_tbl(i) = G_OWNER_NAME ) THEN
           l_owner_name_exists := TRUE;
	   l_owner_name := l_values_tbl(i);
        ELSIF (l_names_tbl(i) = G_OWNER_USER_NAME ) THEN
           l_owner_user_name_exists := TRUE;
	   l_owner_user_name := l_values_tbl(i);
        ELSIF( l_names_tbl(i) = G_GROUP_ID ) THEN
	   l_group_id_exists := TRUE;
	   l_group_id := To_number(l_values_tbl(i));
        ELSIF (l_names_tbl(i) = G_GROUP_NAME ) THEN
           l_group_name_exists := TRUE;
	   l_group_name := l_values_tbl(i);
        ELSIF( l_names_tbl(i) = G_MEMBER_ID ) THEN
	   l_member_id_exists := TRUE;
	   l_member_id := To_number(l_values_tbl(i));
        ELSIF (l_names_tbl(i) = G_MEMBER_NAME ) THEN
           l_member_name_exists := TRUE;
	   l_member_name := l_values_tbl(i);
        ELSIF (l_names_tbl(i) = G_MEMBER_USER_NAME ) THEN
           l_member_user_name_exists := TRUE;
	   l_member_user_name := l_values_tbl(i);
        ELSIF (l_names_tbl(i) = G_MEMBER_USER_NAME ) THEN
           l_member_user_name_exists := TRUE;
	   l_member_user_name := l_values_tbl(i);
        ELSIF (l_names_tbl(i) =  G_GROUP_MEMBER_REL_ID ) THEN
           l_group_member_rel_id_exists := TRUE;
	   l_group_member_rel_id := l_values_tbl(i);
        ELSIF (l_names_tbl(i) = G_NOTE  ) THEN
           l_note_exists := TRUE;
	   l_note := l_values_tbl(i);
        END IF;
      END LOOP;
    END IF;

    IF (p_process_type = G_ADD_GROUP_MEMBER_TYPE OR
        p_process_type = G_REMOVE_GROUP_MEMBER_TYPE
       ) THEN

-- while adding member or removing group member,
-- we need to set the notifications to allthe administrators
-- current functionality does not support owners
-- This is taken care by the create_grp_admin_wf_role procedure
--
--     --If owner_id exists, and owner_name and owner_user_name doesnot
--     --exist, then populate those fields
--     IF (l_owner_id_exists = TRUE AND
-- 	  (l_owner_name_exists = FALSE OR l_owner_user_name_exists = FALSE)
--	 ) THEN
--
--      OPEN get_user_party_names_c(l_owner_id);
--      FETCH get_user_party_names_c INTO l_owner_user_name, l_owner_name;
--      CLOSE get_user_party_names_c;
--      mdebug('Owner user name just retrieved : '||l_owner_user_name);
--
--     END IF;
--
--     --If owner_id doesnot exist, and group_id exists, then derive
--     --owner_name and owner_user_name doesnot from group_id
--     IF (l_owner_id_exists = FALSE AND l_group_id_exists = TRUE) THEN
--      OPEN get_owner_user_party_names_c(l_group_id);
--      FETCH get_owner_user_party_names_c INTO l_owner_user_name, l_owner_name;
--      CLOSE get_owner_user_party_names_c;
--     END IF;
--
--

     --If member_id exists, and member_name and member_user_name doesnot
     --exist, then populate those fields
     IF (l_member_id_exists = TRUE AND
 	     (l_member_name_exists = FALSE OR l_member_user_name_exists = FALSE)
	 ) THEN
mdebug(' UXML: Setting the Member User name and Name');
       OPEN get_user_party_names_c(l_member_id);
       FETCH get_user_party_names_c INTO l_member_user_name, l_member_name;
       CLOSE get_user_party_names_c;
     END IF;

   END IF; --   IF (p_process_type = G_ADD_GROUP_MEMBER_TYPE OR
           --       p_process_type = G_REMOVE_GROUP_MEMBER_TYPE) THEN

   --in case remove group member, retrieve rel id.
   IF (p_process_type = G_REMOVE_GROUP_MEMBER_TYPE) THEN
     IF (l_group_member_rel_id_exists = FALSE) THEN
        OPEN get_group_member_rel_id_c(l_group_id, l_member_id);
        FETCH get_group_member_rel_id_c INTO l_group_member_rel_id;
        CLOSE get_group_member_rel_id_c;
     END IF;
   END IF;

   --populate new tables, and return to the caller
   --NOTE: following code common to all the process_types
   --Even if some attributes are not retrieved above, the following
   --nvl / decode functions will take care of populating the output table.
   i := 0;
   l_names_out_tbl(i) := G_OWNER_ID;
   --decode can only be used in SQL stmt
   SELECT Decode (l_owner_id, null, '', To_char(l_owner_id))
     INTO l_values_out_tbl(i)
     FROM dual;

   i := i+1;
   l_names_out_tbl(i) := G_OWNER_NAME;
   l_values_out_tbl(i) := Nvl(l_owner_name,'');

   i := i+1;
   l_names_out_tbl(i) := G_OWNER_USER_NAME;
   l_values_out_tbl(i) := Nvl(l_owner_user_name,'');

   i := i+1;
   l_names_out_tbl(i) := G_GROUP_ID;
   SELECT Decode (l_group_id, null, '', To_char(l_group_id))
     INTO l_values_out_tbl(i)
     FROM dual;

   i := i+1;
   l_names_out_tbl(i) := G_GROUP_NAME;
   l_values_out_tbl(i) := Nvl(l_group_name,'');

   i := i+1;
   l_names_out_tbl(i) := G_MEMBER_ID;
   SELECT Decode (l_member_id, null, '', To_char(l_member_id))
     INTO l_values_out_tbl(i)
     FROM dual;

   i := i+1;
   l_names_out_tbl(i) := G_MEMBER_NAME;
   l_values_out_tbl(i) := Nvl(l_member_name,'');

   i := i+1;
   l_names_out_tbl(i) := G_MEMBER_USER_NAME;
   l_values_out_tbl(i) := Nvl(l_member_user_name,'');

   i := i+1;
   l_names_out_tbl(i) := G_GROUP_MEMBER_REL_ID;
   SELECT Decode (l_group_member_rel_id, null, '', To_char(l_group_member_rel_id))
     INTO l_values_out_tbl(i)
     FROM dual;

   i := i+1;
   l_names_out_tbl(i) := G_NOTE;
   l_values_out_tbl(i) := Nvl(l_note,'');

   --set OUT parameters
   x_names_tbl := l_names_out_tbl;
   x_values_tbl := l_values_out_tbl;

   EXCEPTION
     WHEN OTHERS THEN
     IF get_user_party_names_c%ISOPEN THEN
       CLOSE get_user_party_names_c;
     END IF;
--     IF get_owner_user_party_names_c%ISOPEN THEN
--       CLOSE get_owner_user_party_names_c;
--     END IF;
     IF get_group_member_rel_id_c%ISOPEN THEN
       CLOSE get_group_member_rel_id_c;
     END IF;
     RAISE;

 END Unmarshall_Xml;


----------------------------------------------------------------------------
-- D. setWFItemAttributes
----------------------------------------------------------------------------
  PROCEDURE setWFItemAttributes
  (
    p_process_type            IN   NUMBER,
    p_item_type               IN   VARCHAR2,
    p_item_key                IN   NUMBER,
    p_name_values_xml         IN   VARCHAR2
  )
  IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : setWFItemAttributes
    -- Type            : private
    -- Pre-reqs        : None
    -- Functionality   : Set Workflow Item Level attributes
    --
    -- Notes           :
    --
    -- Parameters:
    --
    --     IN    : process_type     IN  NUMBER   (Required)
    --             process_type in the workflow

    --     IN    : p_item_type      IN  VARCHAR2 (Required)
    --             Item type of the workflow

    --     IN    : p_item_key      IN  VARCHAR2 (Required)
    --             Item key of the workflow

    --     IN    : p_names_values_xml IN  VARCHAR2 (Required)
    --             name value pairs combination string

    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

    l_names_tbl      EGO_GROUP_WF_PKG.VARCHAR_TBL_TYPE;
    l_values_tbl     EGO_GROUP_WF_PKG.VARCHAR_TBL_TYPE;

    l_owner_id                     NUMBER;
    l_owner_name                   HZ_PARTIES.PARTY_NAME%TYPE;
    l_owner_user_name              FND_USER.USER_NAME%TYPE;
    l_group_id                     NUMBER;
    l_group_name                   HZ_PARTIES.PARTY_NAME%TYPE;
    l_member_id                    NUMBER;
    l_member_name                  HZ_PARTIES.PARTY_NAME%TYPE;
    l_member_user_name             FND_USER.USER_NAME%TYPE;
    l_group_member_rel_id          NUMBER;
    --used to generate plsql document
    l_msg_document_plsql_proc      VARCHAR2(9999);
    l_mail_pref                    FND_USER_PREFERENCES.PREFERENCE_VALUE%TYPE;

    l_member_note          VARCHAR2(2000);
    l_admin_note           VARCHAR2(2000);
    l_temp_message         VARCHAR2(2000);

BEGIN

mdebug ('  SET WF ITEM ATTRIBUTES (SWFIA) : ....1.... ');
   unmarshall_xml(p_process_type, p_name_values_xml, l_names_tbl, l_values_tbl);
   --assign Workflow item level attributes with the unmarshalled values
   IF (p_process_type = G_ADD_GROUP_MEMBER_TYPE OR
        p_process_type = G_REMOVE_GROUP_MEMBER_TYPE OR
        p_process_type = G_DELETE_GROUP_TYPE
       ) THEN

    IF ( l_names_tbl.count > 0) THEN
      FOR i IN l_names_tbl.first .. l_names_tbl.last LOOP
mdebug('setting attribute: '|| l_names_tbl(i) || ' value - ' || l_values_tbl(i));
        IF( l_names_tbl(i) = G_OWNER_ID ) THEN
          l_owner_id := To_number(l_values_tbl(i));
	  --set owner id as the item level attribute
          wf_engine.SetItemAttrNumber( itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_OWNER_ID,
                                       avalue   => To_number(l_values_tbl(i)));

	ELSIF (l_names_tbl(i) = G_OWNER_NAME ) THEN
          l_owner_name := l_values_tbl(i);
          --set owner name as the item level attribute
          wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_OWNER_NAME,
                                       avalue   => l_values_tbl(i));
        ELSIF (l_names_tbl(i) = G_OWNER_USER_NAME ) THEN
          l_owner_user_name := l_values_tbl(i);
          --set owner user name as the item level attribute
          wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_OWNER_USER_NAME,
                                       avalue   => l_values_tbl(i));
        ELSIF( l_names_tbl(i) = G_GROUP_ID ) THEN
          l_group_id := To_number(l_values_tbl(i));
          --set group id as the item level attribute
          wf_engine.SetItemAttrNumber( itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_GROUP_ID,
                                       avalue   => To_number(l_values_tbl(i)));
        ELSIF (l_names_tbl(i) = G_GROUP_NAME ) THEN
          l_group_name := l_values_tbl(i);
          --set group name as the item level attribute
          wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_GROUP_NAME,
                                       avalue   => l_values_tbl(i));
        ELSIF( l_names_tbl(i) = G_MEMBER_ID ) THEN
          l_member_id := To_number(l_values_tbl(i));
          --set member id as the item level attribute
          wf_engine.SetItemAttrNumber(   itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_MEMBER_ID,
                                       avalue   => To_number(l_values_tbl(i)));
        ELSIF (l_names_tbl(i) = G_MEMBER_NAME ) THEN
          l_member_name := l_values_tbl(i);
          --set member name as the item level attribute
          wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_MEMBER_NAME,
                                       avalue   => l_values_tbl(i));
        ELSIF (l_names_tbl(i) = G_MEMBER_USER_NAME ) THEN
          l_member_user_name := l_values_tbl(i);
          --set member user name as the item level attribute
          wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_MEMBER_USER_NAME,
                                       avalue   => l_values_tbl(i));
        ELSIF( l_names_tbl(i) = G_GROUP_MEMBER_REL_ID ) THEN
          l_member_id := To_number(l_values_tbl(i));
          --set member id as the item level attribute
          wf_engine.SetItemAttrNumber(   itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_GROUP_MEMBER_REL_ID,
                                       avalue   => To_number(l_values_tbl(i)));
        ELSIF (l_names_tbl(i) = G_NOTE ) THEN
          --set member user name as the item level attribute
          wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => G_MEMBER_NOTE,
                                       avalue   => l_values_tbl(i));
        END IF;
      END LOOP; --FOR i IN l_names_tbl.first .. l_names_tbl.last LOOP
    END IF; --IF ( l_names_tbl.count > 0) THEN
mdebug ('  SWFIA : All attributes sent ');

    l_member_note :=  wf_engine.GetItemAttrText( itemtype => p_item_type,
			              	         itemkey  => p_item_key,
				                 aname    => G_MEMBER_NOTE);
    IF (p_process_type = G_ADD_GROUP_MEMBER_TYPE) THEN

    --**Set the Message Subject for Owner Approval Request
    ----------------------------------------------------------------------
    fnd_message.set_name('EGO', 'EGO_ADD_GROUP_MEMBER_SUBJECT');
    fnd_message.set_token('MEMBER_NAME', l_member_name);
    fnd_message.set_token('GROUP_NAME', l_group_name);

    --set message subject as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_OWNER_APPROVAL_REQ_SUBJECT',
                                 avalue   => fnd_message.get);
    ----------------------------------------------------------------------

    --This is a call for creating a PLSQL document.
    --Add_GrpMem_Approval_Req_Doc gets the message from FND_NEW_MESSAGES
    --and stubs in the token values, and is used as a approval notification
    --for the owner
    l_msg_document_plsql_proc:='PLSQL:EGO_GROUP_WF_PKG.Add_GrpMem_Approval_Req_Doc/'
                                ||p_item_type||':'||p_item_key;
    --set Owner Approval Request body as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_OWNER_APPROVAL_REQ_BODY',
                                 avalue   => l_msg_document_plsql_proc);

    --*******Set the subsequent notifications body texts**********
    --**Set the Approval Message body
    ----------------------------------------------------------------------

    fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_CONF_SUBJ');
    fnd_message.set_token('GROUP_NAME', l_group_name);

    --set message subject as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_MEMBER_APPROVAL_SUBJECT',
                                 avalue   => fnd_message.get);

-- fix for 3096076 removing the reference of setting the attribute
-- and calling the package to dynamically create the document
    l_msg_document_plsql_proc:='PLSQL:EGO_GROUP_WF_PKG.Add_GrpMem_Approval_Msg_Doc/'
                                ||p_item_type||':'||p_item_key;
    --set Reject Notification body as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_MEMBER_APPROVAL_MSG_BODY',
                                 avalue   => l_msg_document_plsql_proc);
--
--    --get mail preference of the member bug : 1726010
--    l_mail_pref := get_mail_pref(l_member_id);
--    IF (l_mail_pref = 'MAILTEXT') THEN
--      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_CONF_BODY');
--    ELSE
--      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_CNF_HTM_BODY');
--    END IF;
--
--    fnd_message.set_token('GROUP_NAME', l_group_name);
--    --This method needs to be taken out, so that this 'NOTE' token is
--    --dynamically replaced with the Owner's Comments
----    fnd_message.set_token('NOTE', '');
--    -- currently in workflow, the comments are not comming..
--    fnd_message.set_token('GROUP_ADMIN_COMMENTS', NULL);
--    --set message body as the item level attribute
--    wf_engine.SetItemAttrText(   itemtype => p_item_type,
--                                 itemkey  => p_item_key,
--                                 aname    =>'EGO_MEMBER_APPROVAL_MSG_BODY',
--                                 avalue   => fnd_message.get);
--
    ----------------------------------------------------------------------

    --**Set the Rejection Message body
    ----------------------------------------------------------------------
    fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_REJECT_SUBJ');
    fnd_message.set_token('GROUP_NAME', l_group_name);

    --set message subject as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_MEMBER_REJECTION_SUBJECT',
                                 avalue   => fnd_message.get);

-- fix for 3096076 removing the reference of setting the attribute
-- and calling the package to dynamically create the document
    l_msg_document_plsql_proc:='PLSQL:EGO_GROUP_WF_PKG.Add_GrpMem_Reject_Msg_Doc/'
                                ||p_item_type||':'||p_item_key;
    --set Reject Notification body as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_MEMBER_REJECTION_MSG_BODY',
                                 avalue   => l_msg_document_plsql_proc);

--
--    --get mail preference of the member bug : 1726010
--
--    l_mail_pref := get_mail_pref(l_member_id);
--    IF (l_mail_pref = 'MAILTEXT') THEN
--      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_REJECT_BODY');
--     ELSE
--      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_REJ_HTM_BODY');
--    END IF;
--
--    fnd_message.set_token('GROUP_NAME', l_group_name);
--    --This method needs to be taken out, so that this 'NOTE' token is
--    --dynamically replaced with the Owner's Comments
----    fnd_message.set_token('NOTE', '');
--      fnd_message.set_token('GROUP_ADMIN_COMMENTS', NULL);
--
--    --set message subject as the item level attribute
--    wf_engine.SetItemAttrText(   itemtype => p_item_type,
--                                 itemkey  => p_item_key,
--                                 aname    =>'EGO_MEMBER_REJECTION_MSG_BODY',
--                                 avalue   => fnd_message.get);
--

    ----------------------------------------------------------------------
    --*****END: Set the subsequent notifications body texts*********

   END IF; --   IF (p_process_type = G_ADD_GROUP_MEMBER_TYPE)


   IF (p_process_type = G_REMOVE_GROUP_MEMBER_TYPE) THEN

    --**Set the Message Subject and Body for Owner Unsubscription Notf FYI
    ----------------------------------------------------------------------
    fnd_message.set_name('EGO', 'EGO_UNSUBSCR_GROUP_MEMBER_SUBJ');
    fnd_message.set_token('MEMBER_NAME', l_member_name);
    fnd_message.set_token('GROUP_NAME', l_group_name);

    --set message subject as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_OWNER_UNSUBSCR_FYI_SUBJECT',
                                 avalue   => fnd_message.get);

-- fix for 3096076 removing the reference of setting the attribute
-- and calling the package to dynamically create the document
mdebug (' Remove Group Member Subject Set '|| fnd_message.get);
    l_msg_document_plsql_proc:='PLSQL:EGO_GROUP_WF_PKG.Unsub_Member_Owner_FYI_Doc/'
                                ||p_item_type||':'||p_item_key;
    --set Reject Notification body as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_OWNER_UNSUBSCR_FYI_BODY',
                                 avalue   => l_msg_document_plsql_proc);
--
--    l_mail_pref := get_mail_pref(l_member_id);
--
--    IF (l_mail_pref = 'MAILTEXT') THEN
--      IF l_member_note IS NOT NULL THEN
--        fnd_message.set_name('EGO', 'EGO_GROUPMEM_COMMENTS');
--        fnd_message.set_token('MEMBER_NAME', l_member_name);
--        fnd_message.set_token('NOTE', l_member_note);
--        l_temp_message := fnd_message.get;
--      ELSE
--        l_temp_message := NULL;
--      END IF;
--      fnd_message.set_name('EGO', 'EGO_UNSUB_GRPMEM_FYI_BODY');
--     ELSE
--      IF l_member_note IS NOT NULL THEN
--        fnd_message.set_name('EGO', 'EGO_GROUPMEM_COMMENTS_HTM');
--        fnd_message.set_token('MEMBER_NAME', l_member_name);
--        fnd_message.set_token('NOTE', l_member_note);
--        l_temp_message := fnd_message.get;
--      ELSE
--        l_temp_message := NULL;
--      END IF;
--      fnd_message.set_name('EGO', 'EGO_UNSUB_GRPMEM_FYI_HTM_BODY');
--    END IF;
--
--    fnd_message.set_token('MEMBER_NAME', l_member_name);
--    fnd_message.set_token('GROUP_NAME', l_group_name);
--    fnd_message.set_token('GROUP_MEM_COMMENTS', l_temp_message);
--
--    --set message subject as the item level attribute
--    wf_engine.SetItemAttrText(   itemtype => p_item_type,
--                                 itemkey  => p_item_key,
--                                 aname    =>'EGO_OWNER_UNSUBSCR_FYI_BODY',
--                                 avalue   => fnd_message.get);
--   mdebug (' Remove Group Member Body Set '|| fnd_message.get);
--
    ----------------------------------------------------------------------

    --*******Set the subsequent notifications body texts**********
    --**Set the Member Unsubscription Confirmation Message Subject and Body
    ----------------------------------------------------------------------
    fnd_message.set_name('EGO', 'EGO_UNSUBSCR_GRPMEM_CONF_SUBJ');
    fnd_message.set_token('GROUP_NAME', l_group_name);

    --set message subject as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_UNSUBSCR_GRPMEM_CONF_SUBJ',
                                 avalue   => fnd_message.get);

-- fix for 3096076 removing the reference of setting the attribute
-- and calling the package to dynamically create the document
    l_msg_document_plsql_proc:='PLSQL:EGO_GROUP_WF_PKG.Unsub_Member_Conf_Mem_Doc/'
                                ||p_item_type||':'||p_item_key;
    --set Reject Notification body as the item level attribute
    wf_engine.SetItemAttrText(   itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    =>'EGO_UNSUBSCR_GRPMEM_CONF_BODY',
                                 avalue   => l_msg_document_plsql_proc);
--
--    --get mail preference of the member bug : 1726010
--
--    l_mail_pref := get_mail_pref(l_member_id);
--    IF (l_mail_pref = 'MAILTEXT') THEN
--      fnd_message.set_name('EGO', 'EGO_UNSUBSCR_GRPMEM_CONF_BODY');
--     ELSE
--      fnd_message.set_name('EGO', 'EGO_UNSUB_GRPMEM_CNF_HTM_BODY');
--    END IF;
--
--    fnd_message.set_token('GROUP_NAME', l_group_name);
--
--    --set message body as the item level attribute
--    wf_engine.SetItemAttrText(   itemtype => p_item_type,
--                                 itemkey  => p_item_key,
--                                 aname    =>'EGO_UNSUBSCR_GRPMEM_CONF_BODY',
--                                 avalue   => fnd_message.get);
--
    ----------------------------------------------------------------------
    --*****END: Set the subsequent notifications body texts*********

   END IF; --   IF (p_process_type = G_REMOVE_GROUP_MEMBER_TYPE)


   END IF; --IF (p_process_type = G_ADD_GROUP_MEMBER_TYPE OR
           --    p_process_type = G_REMOVE_GROUP_MEMBER_TYPE) THEN
           --    p_process_type = G_DELETE_GROUP_TYPE)

  EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END ;

----------------------------------------------------------------------------
-- E. Start_Subscription_Process (common to add / remove process)
----------------------------------------------------------------------------
 PROCEDURE Start_Subscription_Process
 (
   p_process_type       IN NUMBER,
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_member_id          IN NUMBER,
   p_member_name        IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
  )
 IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Start_Subscription_Process
    -- Type            : Private
    -- Pre-reqs        : None
    -- Functionality   : Starts the workflow process to Add/Remove Group Member.
    -- Notes           : Called from Start_Add_Group_Member_Process and
    --                   Start_Add_Group_Member_Process
    --
    -- Parameters:
    --     IN    : p_process_type      IN  NUMBER   (Required)
    --             mentions whether we are Add OR Remove Group Member
    --     IN    : p_group_id          IN  NUMBER   (Required)
    --             Group Id
    --     IN    : p_group_name        IN  VARCHAR2 (Required)
    --             Group Name
    --             used to set the Workflow item attribute
    --     IN    : p_member_id         IN  NUMBER   (Required)
    --             Member Id
    --     IN    : p_member_name       IN  VARCHAR2 (Required)
    --             Member Name
    --             used to set the Workflow item attribute
    --     IN    : p_name_value_pairs  IN  VARCHAR2 (Optional)
    --             Name value pairs provided as XML string
    --             This is parsed by : Parse_Name_Value_Pairs_Msg
    --             which creates a x_name_tbl and x_value_tbl
    --             These are used to set the item attributes for the
    --             IPDGROUP workflow item type
    --
    -- Called From:
    --      Start_Add_Group_Member_Process
    --      Start_Rem_Group_Member_Process
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  --workflow item type info. needed to start the workflow
  l_item_type     VARCHAR2(30) := G_ITEM_TYPE;

  l_wf_process    VARCHAR2(30);
  l_item_key_id   NUMBER;
  l_item_key      VARCHAR2(30);
  l_item_user_key VARCHAR2(30) := null;

  --xml string for name value pairs
  l_xml_str                 VARCHAR2(32767);

  CURSOR get_item_key_id_c IS
     SELECT EGO_GROUP_WF_MGMT_S.NEXTVAL
     FROM dual;
--
-- Removed as the owner is now obtained from fnd_grants
--
--  CURSOR c_get_owner_name(cp_group_id NUMBER) IS
--   SELECT users.user_name
--   FROM   fnd_user users
--           ,hz_parties parties
--         ,hz_relationships grp_owner
--     WHERE users.customer_id = parties.party_id
--     AND   parties.party_id  = grp_owner.subject_id
--   WHERE users.customer_id = grp_owner.subject_id
--   AND   grp_owner.relationship_type = G_OWNER_GROUP_REL_TYPE
--   AND   grp_owner.relationship_code = G_OWNER_GROUP_REL_CODE
--   AND   grp_owner.status = 'A'
--   AND   SYSDATE BETWEEN grp_owner.start_date
--                  AND NVL(grp_owner.end_date, SYSDATE)
--   AND   grp_owner.object_id = cp_group_id;

--  CURSOR c_get_user_name(cp_party_id NUMBER) IS
--     SELECT users.user_name
--     FROM   fnd_user users
--     WHERE users.customer_id = cp_party_id;

  l_mail_pref    wf_users.notification_preference%TYPE;
  l_owner_name   fnd_user.user_name%TYPE;
  l_user_name    fnd_user.user_name%TYPE;

  BEGIN

mdebug (' START_SUBSCRIPTION_PROCESS (SSP) : ....1.... '|| p_process_type);
    OPEN get_item_key_id_c;
    FETCH get_item_key_id_c INTO l_item_key_id;
    CLOSE get_item_key_id_c;

    l_item_key := To_char(l_item_key_id);
mdebug (' SSP:  Item Key Fetched ' || l_item_key);

    l_mail_pref := get_mail_pref(p_party_id => p_member_id);
mdebug (' SSP:  Mail Preference ' || l_mail_pref);

    --set the workflow process to be started
    IF (p_process_type = G_ADD_GROUP_MEMBER_TYPE ) THEN
      l_wf_process := G_ADD_GROUP_MEMBER_PROCESS;
    ELSE
      l_wf_process := G_REMOVE_GROUP_MEMBER_PROCESS;
    END IF;
mdebug (' SSP: setting the process type for WF ' || l_wf_process);

mdebug (' SSP: setup of parameters complete for WF Creation ');
    --create the process EGOGROUP
    wf_engine.CreateProcess (   itemtype  => l_item_type,
                                itemkey   => l_item_key,
                                process   => l_wf_process);

mdebug (' SSP:  WF process created ');
    --no delimiters specified between name value pair combinations.
    --The parser handles this scenario.
    l_xml_str := '<'||G_GROUP_ID||'>'||To_char(p_group_id)
                    ||'</'||G_GROUP_ID||'>';
    l_xml_str := l_xml_str||'<'||G_GROUP_NAME||'>'
                    ||p_group_name||'</'||G_GROUP_NAME||'>';
    l_xml_str := l_xml_str||'<'||G_MEMBER_ID||'>'
                    ||To_char(p_member_id)||'</'||G_MEMBER_ID||'>';
    --comment out member_name, because in unmarshall_xml both member_user_name
    --and member_name will be retrieved
    --l_xml_str := l_xml_str||'<'||G_MEMBER_NAME||'>'||To_char(p_member_name)||'</'||G_MEMBER_NAME||'>';

    --To parse the name value pairs, along with the prepared xml
    IF p_name_value_pairs IS NOT NULL THEN
      l_xml_str := l_xml_str||p_name_value_pairs;
    END IF;

mdebug (' SSP:  '|| substr(l_xml_str,1,100));
mdebug (' SSP:  '|| substr(l_xml_str,101,100));
    --set Workflow Item attributes
    setWFItemAttributes(p_process_type, l_item_type, l_item_key, l_xml_str);

mdebug (' SSP:  WFItemAtributes set ');
    --Now that all the above global variables are available to the process,
    --Start the process EGOGROUP
    --The first process is to request an approval from Owner of the group
    wf_engine.StartProcess (   itemtype   => l_item_type,
                               itemkey    => l_item_key );

mdebug (' SSP:  BYE - WF Process Started ');
  EXCEPTION
    WHEN OTHERS THEN
mdebug (' SSP: EXCEPTION ');
      wf_core.context(G_PACKAGE_NAME,l_wf_process,l_item_type,l_item_key);
      IF get_item_key_id_c%ISOPEN THEN
         CLOSE get_item_key_id_c;
      END IF;
    RAISE;
 END Start_Subscription_Process;

----------------------------------------------------------------------------
--                                                                        --
--                   PROCEDURES THAT ARE CALLED EXTERNALLY                --
--                                                                        --
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 1. Start_Add_Group_Member_Process
----------------------------------------------------------------------------
 PROCEDURE Start_Add_Group_Member_Process
 (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_member_id          IN NUMBER,
   p_member_name        IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
  )
 IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Start_Add_Group_Member_Process
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Starts the workflow process to Add Group Member.
    -- Notes           :
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

 BEGIN

mdebug(' Started Add_Group_Member_Process ');
    --Start Add Group Member process
    Start_Subscription_Process
      (G_ADD_GROUP_MEMBER_TYPE,
       p_group_id,
       p_group_name,
       p_member_id,
       p_member_name,
       p_name_value_pairs
       );

 END Start_Add_Group_Member_Process;


----------------------------------------------------------------------------
-- 2. Start_Rem_Group_Member_Process
----------------------------------------------------------------------------
PROCEDURE Start_Rem_Group_Member_Process
 (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_member_id          IN NUMBER,
   p_member_name        IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
  )
  IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Start_Rem_Group_Member_Process
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Starts the workflow process to Remove Group Member.
    -- Notes           :
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  BEGIN

    --Start Remove Group Member process
mdebug (' Remove Group Member:  WF Process Started ');
    Start_Subscription_Process
      (G_REMOVE_GROUP_MEMBER_TYPE,
       p_group_id,
       p_group_name,
       p_member_id,
       p_member_name,
       p_name_value_pairs
       );

 END Start_Rem_Group_Member_Process;


----------------------------------------------------------------------------
-- 4. Start_Delete_Group_Process
----------------------------------------------------------------------------
 PROCEDURE Start_Delete_Group_Process
 (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
  )
  IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Start_Delete_Group_Process
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Starts the workflow process to Delete Group.
    -- Notes           :
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  l_return_status       VARCHAR2(100);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  --workflow item type info. needed to start the workflow
  l_item_type   VARCHAR2(30) := G_ITEM_TYPE;
  l_wf_process  VARCHAR2(30) := G_DELETE_GROUP_PROCESS;
  l_item_key_id    NUMBER;
  l_item_key    VARCHAR2(30);

  --xml string for name value pairs
  l_xml_str                 VARCHAR2(32767);

  CURSOR get_item_key_id_c IS
     SELECT EGO_GROUP_WF_MGMT_S.NEXTVAL
     FROM dual;

  BEGIN
mdebug (' EGO_GROUP_WF_PKG.Start_Delete_Group_Process ');
mdebug('1');
    OPEN get_item_key_id_c;
    FETCH get_item_key_id_c INTO l_item_key_id;
    CLOSE get_item_key_id_c;
    l_item_key := To_char(l_item_key_id);

mdebug('2  --  ' || l_item_key);

    --create the process EGOGROUP
    wf_engine.CreateProcess (   itemtype  => l_item_type,
                                itemkey   => l_item_key,
                                process   => l_wf_process);
mdebug('3');
    --no delimiters specified between name value pair combinations.
    --The parser handles this scenario.
    l_xml_str := '<'||G_GROUP_ID||'>'||To_char(p_group_id)
                    ||'</'||G_GROUP_ID||'>';
    l_xml_str := l_xml_str||'<'||G_GROUP_NAME||'>'
                    ||p_group_name||'</'||G_GROUP_NAME||'>';

    --To parse the name value pairs, along with the prepared xml
mdebug('4');
    IF p_name_value_pairs IS NOT NULL THEN
      l_xml_str := l_xml_str||p_name_value_pairs;
    END IF;

    --set Workflow Item attributes
mdebug('5');
    setWFItemAttributes(G_DELETE_GROUP_TYPE, l_item_type, l_item_key, l_xml_str);

    --Now that all the above global variables are available to the process,
    --Start the process EGOGROUP
mdebug(' 6 ' || l_item_type || ' xx ' || l_item_key);
     wf_engine.StartProcess (  itemtype   => l_item_type,
                               itemkey    => l_item_key );

  EXCEPTION
  WHEN OTHERS THEN
    wf_core.context(G_PACKAGE_NAME,l_wf_process,l_item_type,l_item_key);
    IF get_item_key_id_c%ISOPEN THEN
       CLOSE get_item_key_id_c;
    END IF;
    raise;

 END Start_Delete_Group_Process;


----------------------------------------------------------------------------
-- 5. Start_Unsub_Owner_Notf_Process
----------------------------------------------------------------------------
 PROCEDURE Start_Unsub_Owner_Notf_Process
 (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_member_id          IN NUMBER,
   p_member_name        IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
  )
  IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Start_Unsub_Owner_Notf_Process
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Starts the workflow process to Notify the owner
    --                   when he is  unsubscribed as owner.
    -- Notes           :
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  l_return_status       VARCHAR2(100);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  --workflow item type info. needed to start the workflow
  l_item_type   VARCHAR2(30) := G_ITEM_TYPE;
  l_wf_process  VARCHAR2(30) := '_PROCESS';
  l_item_key_id    NUMBER;
  l_item_key    VARCHAR2(30);

  CURSOR get_item_key_id_c IS
     SELECT EGO_GROUP_WF_MGMT_S.NEXTVAL
     FROM dual;

  BEGIN

    OPEN get_item_key_id_c;
    FETCH get_item_key_id_c INTO l_item_key_id;
    CLOSE get_item_key_id_c;

    l_item_key := To_char(l_item_key_id);

  EXCEPTION
  WHEN OTHERS THEN
    wf_core.context(G_PACKAGE_NAME,l_wf_process,l_item_type,l_item_key);
  raise;

 END Start_Unsub_Owner_Notf_Process;


----------------------------------------------------------------------------
-- 6. Start_Subsc_Owner_Notf_Process
----------------------------------------------------------------------------
 PROCEDURE Start_Subsc_Owner_Notf_Process
 (
   p_group_id           IN NUMBER,
   p_group_name         IN VARCHAR2,
   p_member_id          IN NUMBER,
   p_member_name        IN VARCHAR2,
   p_name_value_pairs   IN VARCHAR2
  )
  IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Start_Subsc_Owner_Notf_Process
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Starts the workflow process to Notify the owner
    --                   when he is subscribed as owner.
    -- Notes           :
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  l_return_status       VARCHAR2(100);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  --workflow item type info. needed to start the workflow
  l_item_type   VARCHAR2(30) := G_ITEM_TYPE;
  l_wf_process  VARCHAR2(30) := '_PROCESS';
  l_item_key_id    NUMBER;
  l_item_key    VARCHAR2(30);

  CURSOR get_item_key_id_c IS
     SELECT EGO_GROUP_WF_MGMT_S.NEXTVAL
     FROM dual;

  BEGIN

    OPEN get_item_key_id_c;
    FETCH get_item_key_id_c INTO l_item_key_id;
    CLOSE get_item_key_id_c;

    l_item_key := To_char(l_item_key_id);

  EXCEPTION
  WHEN OTHERS THEN
    wf_core.context(G_PACKAGE_NAME,l_wf_process,l_item_type,l_item_key);
    IF get_item_key_id_c%ISOPEN THEN
      CLOSE get_item_key_id_c;
    END IF;
  raise;

 END Start_Subsc_Owner_Notf_Process;


----------------------------------------------------------------------------
-- 7. Add_Group_Member
----------------------------------------------------------------------------
  PROCEDURE Add_Group_Member
  (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    x_result    OUT NOCOPY VARCHAR2
  )
 IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Add_Group_Member
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Adds the group member to the group
    --                   (After approval from the owner)
    --
    -- Notes           :
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  CURSOR c_get_member(cp_group_id  NUMBER
                     ,cp_member_id NUMBER) IS
  SELECT 'Y'
  FROM   EGO_GROUP_MEMBERS_V
  WHERE  group_id          = cp_group_id
    AND  member_person_id  = cp_member_id;

  l_already_member     VARCHAR2(1):='N';

  l_member_id           NUMBER;
  l_group_id            NUMBER;
  l_return_status       VARCHAR2(100);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_group_member_rel_id     NUMBER;

BEGIN

mdebug ('  ADD_GROUP_MEMBER (AGM) : ....1.... ');
  IF ( p_funcmode = 'RUN' ) THEN

    l_group_id := wf_engine.GetItemAttrNumber( itemtype => p_item_type,
				               itemkey  => p_item_key,
				               aname    => G_GROUP_ID);

    l_member_id := wf_engine.GetItemAttrNumber( itemtype => p_item_type,
				                itemkey  => p_item_key,
				                aname    => G_MEMBER_ID);

    OPEN c_get_member(cp_group_id  => l_group_id
                     ,cp_member_id => l_member_id);
    FETCH c_get_member INTO l_already_member;
    CLOSE c_get_member;
    IF l_already_member ='Y' THEN
mdebug ('  ADD_GROUP_MEMBER (AGM) : Trying to add an already existing meber ');
      x_result := G_COMPLETE_STATUS;
      RETURN;
    END IF;

mdebug ('  AGM : Before calling EGO_PARTY_PUB.ADD_GROUP_MEMBER');
    EGO_PARTY_PUB.Add_Group_Member(
        p_api_version          => 1.0,
        p_init_msg_list        => FND_API.G_TRUE,
        p_commit               => FND_API.G_TRUE,
	p_member_id            => l_member_id,
	p_group_id             => l_group_id,
        p_start_date           => SYSDATE,
        p_end_date             => NULL,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data,
        x_relationship_id      => l_group_member_rel_id
	);

mdebug ('  AGM : Exiting out of EGO_PARTY_PUB.ADD_GROUP_MEMBER ');
     --store the relationship id generated, as item attribute
      wf_engine.SetItemAttrText(   itemtype => p_item_type,
				   itemkey  => p_item_key,
				   aname    => G_GROUP_MEMBER_REL_ID,
				   avalue   => l_group_member_rel_id);
mdebug ('  AGM : Successfully set the parameters into the workflow ');
        x_result := G_COMPLETE_STATUS;
        RETURN;
    ELSIF (p_funcmode IN ('CANCEL', 'TIMEOUT')) THEN
      x_result := G_COMPLETE_STATUS;
      RETURN;
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    wf_core.context(G_PACKAGE_NAME,'Add_Group_Member',p_item_type,p_item_key);
    IF c_get_member%ISOPEN THEN
       CLOSE c_get_member;
    END IF;
    raise;

 END Add_Group_Member;


----------------------------------------------------------------------------
-- 8. Remove_Group_Member
----------------------------------------------------------------------------
  PROCEDURE Remove_Group_Member
  (
    p_item_type IN VARCHAR2,
    p_item_key  IN VARCHAR2,
    p_actid     IN NUMBER,
    p_funcmode  IN VARCHAR2,
    x_result    OUT NOCOPY VARCHAR2
  )
 IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Remove_Group_Member
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Adds the group member from the group
    --                   (After approval from the owner)
    --
    -- Notes           :
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  l_group_id            NUMBER;
  l_return_status       VARCHAR2(100);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_group_member_rel_id    NUMBER;
  l_object_version_number  NUMBER;

  CURSOR c_get_object_ver_no  (cp_relationship_id  IN  NUMBER) IS
  SELECT object_version_number
  FROM   hz_relationships
  WHERE  relationship_id = cp_relationship_id;

  BEGIN

mdebug(' Entered Remove Group Member Process  (RGMP)');
  IF ( p_funcmode = 'RUN' ) THEN

    -- get the group member relationship id from Item attribute
    l_group_member_rel_id :=
        wf_engine.GetItemAttrNumber( itemtype => p_item_type,
	                             itemkey  => p_item_key,
				     aname    => G_GROUP_MEMBER_REL_ID);
mdebug(' RGMP ' || to_char(l_group_member_rel_id));
    --
    -- get the object version number of the relationship
    --
    OPEN c_get_object_ver_no (cp_relationship_id => l_group_member_rel_id);
    FETCH c_get_object_ver_no INTO l_object_version_number;
    IF c_get_object_ver_no%NOTFOUND THEN
      l_object_version_number := 0;
    END IF;
    CLOSE c_get_object_ver_no;

mdebug(' RGMP  Before calling  EGO_PARTY_PUB.Remove_Group_member') ;
    EGO_PARTY_PUB.Remove_Group_Member(
        p_api_version		=> 1.0,
	p_init_msg_list		=> FND_API.G_TRUE,
	p_commit		=> FND_API.G_TRUE,
	p_relationship_id	=> l_group_member_rel_id,
	p_object_version_no_rel	=> l_object_version_number,
	x_return_status		=> l_return_status,
	x_msg_count		=> l_msg_count,
	x_msg_data		=> l_msg_data
	);
mdebug(' RGMP  return status ' || l_return_status) ;
        x_result := G_COMPLETE_STATUS;
        RETURN;
    ELSIF (p_funcmode IN ('CANCEL', 'TIMEOUT')) THEN
      x_result := G_COMPLETE_STATUS;
      RETURN;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context(G_PACKAGE_NAME,'Remove_Group_Member',p_item_type,p_item_key);
    IF c_get_object_ver_no%ISOPEN THEN
      CLOSE c_get_object_ver_no;
    END IF;
  raise;

 END Remove_Group_Member;


----------------------------------------------------------------------------
-- 9. Delete_Group
----------------------------------------------------------------------------
  PROCEDURE Delete_Group
  (
    p_item_type IN VARCHAR2,
    p_item_key  IN VARCHAR2,
    p_actid     IN NUMBER,
    p_funcmode  IN VARCHAR2,
    x_result    OUT NOCOPY VARCHAR2
  )
 IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Delete_Group
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Deletes the group
    --
    -- Notes           :
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  l_group_id            NUMBER;
  l_return_status       VARCHAR2(100);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_object_version_number  NUMBER;

  CURSOR c_get_object_ver_no (cp_group_id  IN NUMBER) IS
    SELECT object_version_number
    FROM   hz_parties
    WHERE  party_id   = cp_group_id
      AND  party_type = 'GROUP'
      AND  status     = 'A';


  BEGIN
mdebug (' Entered Delete Group after sending notifications ');
  IF ( p_funcmode = 'RUN' ) THEN

    -- get the group id from Item attribute
    l_group_id := wf_engine.GetItemAttrNumber( itemtype => p_item_type,
			              	       itemkey  => p_item_key,
				               aname    => G_GROUP_ID);
mdebug (' Group to be deleted ' || to_char(l_group_id));
    OPEN c_get_object_ver_no (cp_group_id => l_group_id);
    FETCH c_get_object_ver_no INTO l_object_version_number;
    IF c_get_object_ver_no%NOTFOUND THEN
      l_object_version_number := 0;
    END IF;
    CLOSE c_get_object_ver_no;
mdebug (' Calling EGO_PARTY_PUB.Delete Group ');
    EGO_PARTY_PUB.Delete_group
       (p_api_version			=> 1.0
       ,p_init_msg_list			=> FND_API.G_TRUE
       ,p_commit			=> FND_API.G_FALSE
       ,p_group_id			=> l_group_id
       ,p_object_version_no_group	=> l_object_version_number
       ,x_return_status			=> l_return_status
       ,x_msg_count			=> l_msg_count
       ,x_msg_data			=> l_msg_data
       );
mdebug (' Exited out of EGO_PARTY_PUB.Delete Group ');
    x_result := G_COMPLETE_STATUS;
    RETURN;
  ELSIF (p_funcmode IN ('CANCEL', 'TIMEOUT') ) THEN
    x_result := G_COMPLETE_STATUS;
    RETURN;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    wf_core.context(G_PACKAGE_NAME,'Delete_Group',p_item_type,p_item_key);
    IF c_get_object_ver_no%ISOPEN THEN
      CLOSE c_get_object_ver_no;
    END IF;
  raise;

 END Delete_Group;

----------------------------------------------------------------------------
-- 10. Group_Del_Ntf_All_Members
----------------------------------------------------------------------------
  PROCEDURE Group_Del_Ntf_All_Members
(
  p_item_type IN VARCHAR2,
  p_item_key  IN VARCHAR2,
  p_actid     IN NUMBER,
  p_funcmode  IN VARCHAR2,
  x_result    OUT NOCOPY VARCHAR2
) IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Group_Del_Ntf_All_Members
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Notifies all Group Members
    --
    -- Notes           :
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  CURSOR c_get_member_party_names (cp_group_id IN  NUMBER) IS
    SELECT member_user_name, member_person_name, member_person_id
    FROM   ego_group_members_v
    WHERE  group_id = cp_group_id;

    l_group_id                     NUMBER;
    l_group_name                   HZ_PARTIES.PARTY_NAME%TYPE;
    l_msg_document_plsql_proc      VARCHAR2(9999);
    l_notification_id              NUMBER;
    l_context                      VARCHAR2(500);
    l_item_type                VARCHAR2(30) := G_ITEM_TYPE;
    l_group_del_member_notif   VARCHAR2(50) := 'GROUP_DEL_MEMBER_NOTF';


  BEGIN
mdebug (' Entered Group_Del_Ntf_All_Members   Starts...');

    l_context:=p_item_type ||':'||p_item_key ||':'|| to_char(p_actid );

    IF ( p_funcmode = 'RUN' ) THEN
mdebug (' 1 ');
      -- get the group id from Item attribute
      l_group_id := wf_engine.GetItemAttrNumber( itemtype => p_item_type,
                                                 itemkey  => p_item_key,
                                                 aname    => G_GROUP_ID);
      l_group_name := wf_engine.GetItemAttrText( itemtype => p_item_type,
                                                 itemkey  => p_item_key,
                                                 aname    => G_GROUP_NAME);
mdebug (' 2 ' || l_group_name);
      wf_engine.SetItemAttrText(itemtype => p_item_type,
                                itemkey  => p_item_key,
                                aname    => 'FROM_ROLE',
                                avalue   => fnd_global.user_name());
mdebug (' 3 ' || fnd_global.user_name());
      ------------------------------------------------
      --                                            --
      --      Set the subject outside the loop      --
      --                                            --
      ------------------------------------------------
      fnd_message.set_name('EGO', 'EGO_GROUP_DEL_MEM_NOTF_SUBJ');
      fnd_message.set_token('GROUP_NAME', l_group_name);
      --set message subject as the item level attribute
      wf_engine.SetItemAttrText(itemtype => p_item_type,
                                itemkey  => p_item_key,
                                aname    => 'EGO_GROUP_DEL_MEM_NOTF_SUBJ',
                                avalue   => fnd_message.get);

      l_msg_document_plsql_proc:='PLSQL:EGO_GROUP_WF_PKG.Del_Grp_Admin_Notif_Doc/'
                                  ||p_item_type||':'||p_item_key;

      --set Owner Group Del Message body as the item level attribute
      wf_engine.SetItemAttrText(itemtype => p_item_type,
                                itemkey  => p_item_key,
                                aname    =>'EGO_GROUP_DEL_MEM_NOTF_BODY',
                                avalue   => l_msg_document_plsql_proc);
      ------------------------------------------------
      --                                            --
      --      Send notifications to all admins      --
      --                                            --
      ------------------------------------------------
      FOR cr in c_get_admin_list (l_group_id) LOOP
mdebug (' 4 ' || cr.user_name);
        l_notification_id :=  WF_NOTIFICATION.SEND
                              (
                               role         => cr.user_name,
                               msg_type     => l_item_type,
                               msg_name     => l_group_del_member_notif,
                               due_date     => NULL,
                               callback     => 'WF_ENGINE.CB',
                               context      => l_context,
                               send_comment => NULL,
                               priority     => NULL
                               );
      END LOOP;
      ------------------------------------------------
      --                                            --
      --     Send notifications to all members      --
      --                                            --
      ------------------------------------------------
      l_msg_document_plsql_proc:='PLSQL:EGO_GROUP_WF_PKG.Del_Grp_Mem_Notif_Doc/'
                                  ||p_item_type||':'||p_item_key;
      --set Group Del Message body for Member as the item level attribute
      wf_engine.SetItemAttrText(itemtype => p_item_type,
                                itemkey  => p_item_key,
                                aname    =>'EGO_GROUP_DEL_MEM_NOTF_BODY',
                                avalue   => l_msg_document_plsql_proc);
      FOR cr in c_get_member_party_names (cp_group_id => l_group_id) LOOP
mdebug (' 5 ' || cr.member_user_name);
        l_notification_id :=  WF_NOTIFICATION.SEND
                              (
                               role         => cr.member_user_name,
                               msg_type     => l_item_type,
                               msg_name     => l_group_del_member_notif,
                               due_date     => NULL,
                               callback     => 'WF_ENGINE.CB',
                               context      => l_context,
                               send_comment => NULL,
                               priority     => NULL
			       );
      END LOOP;
    END IF;
    x_result := G_COMPLETE_STATUS;
mdebug (' Group_Del_Ntf_All_Members   Ends...');
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.context(G_PACKAGE_NAME,'Group_Del_Ntf_All_Members',p_item_type,p_item_key);
      IF c_get_member_party_names%ISOPEN THEN
        CLOSE c_get_member_party_names;
      END IF;
      IF c_get_admin_list%ISOPEN THEN
        CLOSE c_get_admin_list;
      END IF;
      RAISE;
  END Group_Del_Ntf_All_Members;


----------------------------------------------------------------------------
-- 11. Add_GrpMem_Approval_Req_Doc
----------------------------------------------------------------------------
  PROCEDURE Add_GrpMem_Approval_Req_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT  NOCOPY VARCHAR2,
    document_type IN OUT  NOCOPY VARCHAR2
  )
   IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Add_GrpMem_Approval_Req_Doc
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Prepares Message Document
    --
    -- Notes           :
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    -- History         :
    --    21-jul-2002     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

  l_group_name    hz_parties.party_name%TYPE;
--  l_owner_name  VARCHAR2(100);
  l_member_name   hz_parties.party_name%TYPE;
  l_member_note   VARCHAR2(999);

  l_item_type   VARCHAR2(30);
  l_item_key    VARCHAR2(30);

-- xxxx
-- group name is not unique in APPS
--
--  CURSOR c_get_ownerid(cp_group_name VARCHAR2) IS
--    SELECT grp_owner.subject_id
--    FROM   hz_parties grp, hz_relationships grp_owner
--    WHERE  grp.party_name      = cp_group_name
--      AND  grp.application_id  = EGO_PARTY_PUB.get_application_id
--      AND  grp.party_type      = 'GROUP'
--      AND  grp_owner.object_id = grp.party_id
--      AND  grp_owner.status    = 'A'
--      AND  SYSDATE BETWEEN grp_owner.start_date AND NVL(grp_owner.end_date, SYSDATE)
--      AND  grp_owner.relationship_type = G_OWNER_GROUP_REL_TYPE;

--  l_owner_id   NUMBER;
  l_mail_pref   FND_USER_PREFERENCES.PREFERENCE_VALUE%TYPE;
  l_temp_message   VARCHAR2(2000);

BEGIN

  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5
  l_item_type := nvl(substr(document_id, 1, instr(document_id,':')-1),G_ITEM_TYPE);
  l_item_key  := substr(document_id , instr(document_id,':')+1);

  l_group_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => G_GROUP_NAME);

--
--  l_owner_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
--                                 itemkey  => l_item_key,
--                                 aname    => G_OWNER_NAME);
--

  l_member_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => G_MEMBER_NAME);


  l_member_note := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => G_MEMBER_NOTE);

--  OPEN  c_get_ownerid(cp_group_name => l_group_name);
--  FETCH c_get_ownerid INTO l_owner_id;
--  CLOSE c_get_ownerid;

--  l_mail_pref := get_mail_pref(l_owner_id);
l_mail_pref := G_USER_MAIL_PREFERENCE;

  IF (l_mail_pref = 'MAILTEXT') THEN
     IF l_member_note IS NOT NULL THEN
       fnd_message.set_name('EGO', 'EGO_GROUPMEM_COMMENTS');
       fnd_message.set_token('MEMBER_NAME', l_member_name);
       fnd_message.set_token('NOTE', l_member_note);
       l_temp_message := fnd_message.get;
     ELSE
       l_temp_message :=  NULL;
     END IF;
     fnd_message.set_name('EGO', 'EGO_ADD_GROUP_MEMBER_BODY');
  ELSE
     -- mail preference is MAILHTML
     IF l_member_note IS NOT NULL THEN
       fnd_message.set_name('EGO', 'EGO_GROUPMEM_COMMENTS_HTM');
       fnd_message.set_token('MEMBER_NAME', l_member_name);
       fnd_message.set_token('NOTE', l_member_note);
       l_temp_message := fnd_message.get;
     ELSE
       l_temp_message :=  NULL;
     END IF;
     fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_APPR_HTM_BODY');
  END IF;
  fnd_message.set_token('MEMBER_NAME', l_member_name);
  fnd_message.set_token('GROUP_NAME', l_group_name);
  fnd_message.set_token('GROUP_MEM_COMMENTS',l_temp_message);
  document:=fnd_message.get;

  document_type := display_type;

 EXCEPTION
   WHEN OTHERS THEN
    wf_core.context(G_PACKAGE_NAME,'Add_GrpMem_Approval_Req_Doc',l_item_type,l_item_key);
--    IF c_get_ownerid%ISOPEN THEN
--       CLOSE c_get_ownerid;
--    END IF;
    RAISE;

 END Add_GrpMem_Approval_Req_Doc;


----------------------------------------------------------------------------
-- 12. Add_GrpMem_Reject_Msg_Doc
----------------------------------------------------------------------------
  PROCEDURE Add_GrpMem_Reject_Msg_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  ) IS
    ----------------------------------------------------------------------
    -- Start Of comments
    --
    -- Procedure name  : Add_GrpMem_Reject_Msg_Doc
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Prepares Message Document
    --
    -- Notes           : Created as per Bug 3096076
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    -- History         :
    --    03-SEP-2003     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------
-- PERF TUNING :4956096
    CURSOR c_get_party_name (cp_user_name IN VARCHAR2) IS
    SELECT party_name
     FROM  ego_user_v
     WHERE user_name = cp_user_name;

    l_group_name  HZ_PARTIES.PARTY_NAME%TYPE;
    l_item_type   VARCHAR2(30);
    l_item_key    VARCHAR2(30);
    l_mail_pref   FND_USER_PREFERENCES.PREFERENCE_VALUE%TYPE;
    l_respondent  HZ_PARTIES.PARTY_NAME%TYPE;
    l_user_name   FND_USER.USER_NAME%TYPE;
    l_member_id   NUMBER;

  BEGIN
    -- parse document_id for the ':' dividing item type name from item key value
    -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
    -- release 2.5
    l_item_type := nvl(substr(document_id, 1, instr(document_id,':')-1),G_ITEM_TYPE);
    l_item_key  := substr(document_id , instr(document_id,':')+1);

    l_group_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname    => G_GROUP_NAME);

    l_member_id := wf_engine.GetItemAttrNumber(itemtype => l_item_type,
				               itemkey  => l_item_key,
				               aname    => G_MEMBER_ID);
    l_mail_pref := get_mail_pref(l_member_id);
    IF (display_type = 'text/plain') THEN
      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_REJECT_BODY');
    ELSE
      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_REJ_HTM_BODY');
    END IF;

    fnd_message.set_token('GROUP_NAME', l_group_name);

    l_user_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                              itemkey  => l_item_key,
                                              aname    => G_RESPONDER_NAME);
    OPEN c_get_party_name (cp_user_name => l_user_name);
    FETCH c_get_party_name INTO l_respondent;
    CLOSE c_get_party_name;

    fnd_message.set_token('GROUP_ADMIN_REJECTOR',l_respondent);
    document:=fnd_message.get;
    document_type := display_type;
  EXCEPTION
     WHEN OTHERS THEN
      wf_core.context(G_PACKAGE_NAME,'Add_GrpMem_Reject_Msg_Doc',l_item_type,l_item_key);
      IF c_get_party_name%ISOPEN THEN
        CLOSE c_get_party_name;
      END IF;
      RAISE;
  END Add_GrpMem_Reject_Msg_Doc;


----------------------------------------------------------------------------
-- 13. Add_GrpMem_Approval_Msg_Doc
----------------------------------------------------------------------------
  PROCEDURE Add_GrpMem_Approval_Msg_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  ) IS
    ----------------------------------------------------------------------
    -- Start Of comments
    --
    -- Procedure name  : Add_GrpMem_Approval_Msg_Doc
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Prepares Message Document
    --
    -- Notes           : Created as per Bug 3096076
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    -- History         :
    --    03-SEP-2003     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

    l_group_name  HZ_PARTIES.PARTY_NAME%TYPE;
    l_item_type   VARCHAR2(30);
    l_item_key    VARCHAR2(30);
    l_mail_pref   FND_USER_PREFERENCES.PREFERENCE_VALUE%TYPE;
    l_member_id   NUMBER;

  BEGIN
    -- parse document_id for the ':' dividing item type name from item key value
    -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
    -- release 2.5
    l_item_type := nvl(substr(document_id, 1, instr(document_id,':')-1),G_ITEM_TYPE);
    l_item_key  := substr(document_id , instr(document_id,':')+1);

    l_group_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname    => G_GROUP_NAME);

    l_member_id := wf_engine.GetItemAttrNumber( itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => G_MEMBER_ID);
    l_mail_pref := get_mail_pref(l_member_id);
    IF (l_mail_pref = 'MAILTEXT') THEN
      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_CONF_BODY');
    ELSE
      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_CNF_HTM_BODY');
    END IF;


    IF (display_type = 'text/plain') THEN
      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_CONF_BODY');
    ELSE
      fnd_message.set_name('EGO', 'EGO_ADD_GROUPMEM_CNF_HTM_BODY');
    END IF;

    fnd_message.set_token('GROUP_NAME', l_group_name);
    fnd_message.set_token('GROUP_ADMIN_COMMENTS', NULL);

    document:=fnd_message.get;
    document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
      wf_core.context(G_PACKAGE_NAME,'Add_GrpMem_Approval_Msg_Doc',l_item_type,l_item_key);
      RAISE;
  END Add_GrpMem_Approval_Msg_Doc;


----------------------------------------------------------------------------
-- 14. Unsub_Member_Owner_FYI_Doc
----------------------------------------------------------------------------
  PROCEDURE Unsub_Member_Owner_FYI_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  ) IS
    ----------------------------------------------------------------------
    -- Start Of comments
    --
    -- Procedure name  : Unsub_Member_Owner_FYI_Doc
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Prepares Message Document
    --
    -- Notes           : Created as per Bug 3096076
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    -- History         :
    --    03-SEP-2003     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

    l_group_name  HZ_PARTIES.PARTY_NAME%TYPE;
    l_item_type   VARCHAR2(30);
    l_item_key    VARCHAR2(30);
    l_member_id   NUMBER;

    l_member_name          HZ_PARTIES.PARTY_NAME%TYPE;
    l_mail_pref            FND_USER_PREFERENCES.PREFERENCE_VALUE%TYPE;
    l_member_note          VARCHAR2(2000);
    l_temp_message         VARCHAR2(2000);

  BEGIN
    -- parse document_id for the ':' dividing item type name from item key value
    -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
    -- release 2.5
    l_item_type := nvl(substr(document_id, 1, instr(document_id,':')-1),G_ITEM_TYPE);
    l_item_key  := substr(document_id , instr(document_id,':')+1);

    l_group_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname    => G_GROUP_NAME);
    l_member_name := wf_engine.GetItemAttrText(itemtype => l_item_type
                                              ,itemkey  => l_item_key
                                              ,aname    => G_MEMBER_NAME);
    l_member_note := wf_engine.GetItemAttrText( itemtype => l_item_type
                                               ,itemkey  => l_item_key
                                               ,aname    => G_MEMBER_NOTE);
    l_member_id := wf_engine.GetItemAttrNumber( itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => G_MEMBER_ID);
    l_mail_pref := get_mail_pref(l_member_id);
    IF (l_mail_pref = 'MAILTEXT') THEN
      IF l_member_note IS NOT NULL THEN
        fnd_message.set_name('EGO', 'EGO_GROUPMEM_COMMENTS');
        fnd_message.set_token('MEMBER_NAME', l_member_name);
        fnd_message.set_token('NOTE', l_member_note);
        l_temp_message := fnd_message.get;
      ELSE
        l_temp_message := NULL;
      END IF;
      fnd_message.set_name('EGO', 'EGO_UNSUB_GRPMEM_FYI_BODY');
     ELSE
      IF l_member_note IS NOT NULL THEN
        fnd_message.set_name('EGO', 'EGO_GROUPMEM_COMMENTS_HTM');
        fnd_message.set_token('MEMBER_NAME', l_member_name);
        fnd_message.set_token('NOTE', l_member_note);
        l_temp_message := fnd_message.get;
      ELSE
        l_temp_message := NULL;
      END IF;
      fnd_message.set_name('EGO', 'EGO_UNSUB_GRPMEM_FYI_HTM_BODY');
    END IF;

    fnd_message.set_token('MEMBER_NAME', l_member_name);
    fnd_message.set_token('GROUP_NAME', l_group_name);
    fnd_message.set_token('GROUP_MEM_COMMENTS', l_temp_message);

    document:=fnd_message.get;
    document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
      wf_core.context(G_PACKAGE_NAME,'Unsub_Member_Owner_FYI_Doc',l_item_type,l_item_key);
      RAISE;
  END Unsub_Member_Owner_FYI_Doc;


----------------------------------------------------------------------------
-- 15. Unsub_Member_Conf_Mem_Doc
----------------------------------------------------------------------------
  PROCEDURE Unsub_Member_Conf_Mem_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  ) IS
    ----------------------------------------------------------------------
    -- Start Of comments
    --
    -- Procedure name  : Unsub_Member_Conf_Mem_Doc
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Prepares Message Document
    --
    -- Notes           : Created as per Bug 3096076
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    -- History         :
    --    03-SEP-2003     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

    l_member_id        NUMBER;
    l_group_name       HZ_PARTIES.PARTY_NAME%TYPE;
    l_item_type        VARCHAR2(30);
    l_item_key         VARCHAR2(30);
    l_mail_pref        FND_USER_PREFERENCES.PREFERENCE_VALUE%TYPE;

  BEGIN
    -- parse document_id for the ':' dividing item type name from item key value
    -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
    -- release 2.5
    l_item_type := nvl(substr(document_id, 1, instr(document_id,':')-1),G_ITEM_TYPE);
    l_item_key  := substr(document_id , instr(document_id,':')+1);

    l_group_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname    => G_GROUP_NAME);
    l_member_id := wf_engine.GetItemAttrNumber(itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname    => G_MEMBER_ID);
    l_mail_pref := get_mail_pref(l_member_id);
    IF (l_mail_pref = 'MAILTEXT') THEN
      fnd_message.set_name('EGO', 'EGO_UNSUBSCR_GRPMEM_CONF_BODY');
     ELSE
      fnd_message.set_name('EGO', 'EGO_UNSUB_GRPMEM_CNF_HTM_BODY');
    END IF;

    fnd_message.set_token('GROUP_NAME', l_group_name);

    document:=fnd_message.get;
    document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
      wf_core.context(G_PACKAGE_NAME,'Unsub_Member_Conf_Mem_Doc',l_item_type,l_item_key);
      RAISE;
  END Unsub_Member_Conf_Mem_Doc;


----------------------------------------------------------------------------
-- 16. Del_Grp_Admin_Notif_Doc
----------------------------------------------------------------------------
  PROCEDURE Del_Grp_Admin_Notif_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  ) IS
    ----------------------------------------------------------------------
    -- Start Of comments
    --
    -- Procedure name  : Del_Grp_Admin_Notif_Doc
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Prepares Message Document
    --
    -- Notes           : Created as per Bug 3096076
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    -- History         :
    --    03-SEP-2003     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

    l_group_name       HZ_PARTIES.PARTY_NAME%TYPE;
    l_item_type        VARCHAR2(30);
    l_item_key         VARCHAR2(30);
    l_mail_pref        FND_USER_PREFERENCES.PREFERENCE_VALUE%TYPE;
    l_deletion_note    VARCHAR2(999);
    l_temp_message     VARCHAR2(2000);
    l_member_id        NUMBER;

  BEGIN
    -- parse document_id for the ':' dividing item type name from item key value
    -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
    -- release 2.5
    l_item_type := nvl(substr(document_id, 1, instr(document_id,':')-1),G_ITEM_TYPE);
    l_item_key  := substr(document_id , instr(document_id,':')+1);

    l_group_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname    => G_GROUP_NAME);

    l_deletion_note := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => G_MEMBER_NOTE);

    IF l_deletion_note IS NOT NULL THEN
      fnd_message.set_name('EGO', 'EGO_GROUP_ADMIN_COMMENTS');
      fnd_message.set_token('NOTE', l_deletion_note);
      l_temp_message := fnd_message.get;
    ELSE
      l_temp_message := NULL;
    END IF;

    l_member_id := wf_engine.GetItemAttrNumber( itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => G_MEMBER_ID);
    l_mail_pref := get_mail_pref(l_member_id);
    IF (l_mail_pref = 'MAILTEXT') THEN
      fnd_message.set_name('EGO', 'EGO_GROUP_DEL_OWN_NOTF_BODY');
    ELSE
      fnd_message.set_name('EGO', 'EGO_DEL_GROUPOWN_CNF_HTM_BODY');
    END IF;
    fnd_message.set_token('GROUP_NAME', l_group_name);
    fnd_message.set_token('GROUP_ADMIN_COMMENTS', l_temp_message);

    document:= fnd_message.get;
    document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
      wf_core.context(G_PACKAGE_NAME,'Del_Grp_Admin_Notif_Doc',l_item_type,l_item_key);
      RAISE;
  END Del_Grp_Admin_Notif_Doc;


----------------------------------------------------------------------------
-- 17. Del_Grp_Mem_Notif_Doc
----------------------------------------------------------------------------
  PROCEDURE Del_Grp_Mem_Notif_Doc
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY VARCHAR2,
    document_type IN OUT NOCOPY VARCHAR2
  ) IS
    ----------------------------------------------------------------------
    -- Start Of comments
    --
    -- Procedure name  : Del_Grp_Mem_Notif_Doc
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Prepares Message Document
    --
    -- Notes           : Created as per Bug 3096076
    --
    -- Called through following format:
    -- PLSQL:<package.procedure>/<Document ID>
    --
    -- A PL/SQL Document is generated with display type of 'text/html'
    -- when the message is viewed through web page. Else it is  'text/plain'
    --
    -- History         :
    --    03-SEP-2003     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------

    l_group_name       HZ_PARTIES.PARTY_NAME%TYPE;
    l_item_type        VARCHAR2(30);
    l_item_key         VARCHAR2(30);
    l_mail_pref        FND_USER_PREFERENCES.PREFERENCE_VALUE%TYPE;
    l_deletion_note    VARCHAR2(999);
    l_temp_message     VARCHAR2(2000);
    l_member_id        NUMBER;

  BEGIN
    -- parse document_id for the ':' dividing item type name from item key value
    -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
    -- release 2.5
    l_item_type := nvl(substr(document_id, 1, instr(document_id,':')-1),G_ITEM_TYPE);
    l_item_key  := substr(document_id , instr(document_id,':')+1);

    l_group_name := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname    => G_GROUP_NAME);

    l_deletion_note := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => G_MEMBER_NOTE);

    IF l_deletion_note IS NOT NULL THEN
      fnd_message.set_name('EGO', 'EGO_GROUP_ADMIN_COMMENTS');
      fnd_message.set_token('NOTE', l_deletion_note);
      l_temp_message := fnd_message.get;
    ELSE
      l_temp_message := NULL;
    END IF;

    l_member_id := wf_engine.GetItemAttrNumber( itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => G_MEMBER_ID);
    l_mail_pref := get_mail_pref(l_member_id);
    IF (l_mail_pref = 'MAILTEXT') THEN
      fnd_message.set_name('EGO', 'EGO_GROUP_DEL_MEM_NOTF_BODY');
    ELSE
      fnd_message.set_name('EGO', 'EGO_DEL_GROUPMEM_CNF_HTM_BODY');
    END IF;

    fnd_message.set_token('GROUP_NAME', l_group_name);
    fnd_message.set_token('GROUP_ADMIN_COMMENTS', l_temp_message);

    document:= fnd_message.get;
    document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
      wf_core.context(G_PACKAGE_NAME,'Del_Grp_Mem_Notif_Doc',l_item_type,l_item_key);
      RAISE;
  END Del_Grp_Mem_Notif_Doc;

----------------------------------------------------------------------------
-- 18. Get_Responder_Name
----------------------------------------------------------------------------
  PROCEDURE Get_Responder_name
  (itemtype    IN  VARCHAR2  ,
   itemkey     IN  VARCHAR2  ,
   actid	   IN  NUMBER   ,
   funcmode    IN  VARCHAR2  ,
   resultout   OUT NOCOPY VARCHAR2
  )
 IS
    ----------------------------------------------------------------------
    -- Start OF comments
    --
    -- Procedure name  : Get_Responder_Name
    -- Type            : Public
    -- Pre-reqs        : None
    -- Functionality   : Store the approver's name
    --
    -- Notes           :
    --
    -- History         :
    --    09-sep-2003     Sridhar Rajaparthi    Creation
    --
    -- END OF comments
    ----------------------------------------------------------------------
 l_email_start_loc  NUMBER;
 l_email_end_loc    NUMBER;
 l_responder_name   VARCHAR2(32767);
 l_email_address    VARCHAR2(32767);
BEGIN

  mdebug ('  GET_RESPONDER_NAME (GRN) : ....1.... mode: ' || funcmode ||
          ' - key: '|| itemkey||' - text: '||wf_engine.context_text);
  IF (funcmode = 'RESPOND' ) THEN
    -- bug 3354437
    -- get the responder name from the email address
    l_responder_name := wf_engine.context_text;
    l_email_start_loc := INSTR(l_responder_name,'<');
    IF l_email_start_loc <> 0 THEN
      l_email_end_loc := INSTR(l_responder_name,'>');
      l_email_address := SUBSTR(l_responder_name, l_email_start_loc+1, l_email_end_loc-l_email_start_loc-1);
      mdebug ('  GET_RESPONDER_NAME (GRN) : ....5.... email: ' || l_email_address);
      BEGIN
        SELECT A.user_name
        INTO l_responder_name
        FROM wf_user_roles a, wf_users b
        WHERE a.user_name  = b.name
        AND a.role_name =  G_GROUP_OBJECT_NAME || itemkey
        AND upper(b.EMAIL_ADDRESS) = upper(l_email_address)
        AND rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    mdebug ('  GET_RESPONDER_NAME (GRN) : ....8.... responder: ' || l_responder_name);
    -- set the item attribute
    Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                               ItemKey   =>  itemkey,
                               aname     =>  G_RESPONDER_NAME,
                               avalue    =>  l_responder_name
--                               avalue    =>  wf_engine.context_text
                              );

    Resultout:= G_COMPLETE_STATUS;
    RETURN;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    mdebug ('  GET_RESPONDER_NAME (GRN) : EXCEPTION	');
    wf_core.context(G_PACKAGE_NAME,'GET_RESPONDER_NAME',itemtype,itemkey);
    raise;
  END GET_RESPONDER_NAME;


----------------------------------------------------------------------------
-- 19. Create_Grp_Admin_WF_Role
----------------------------------------------------------------------------
  PROCEDURE create_grp_admin_wf_role
      (itemtype    IN  VARCHAR2  ,
       itemkey     IN  VARCHAR2  ,
       actid	   IN  NUMBER   ,
       funcmode    IN  VARCHAR2  ,
       resultout   OUT NOCOPY VARCHAR2
       ) IS
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name        : create_wf_role
    -- TYPE            : Public
    -- Functionality   : Create the WF Roles dynamically
    -- Notes           : This procedure will create a role for all the
    --                   administrators of the group
    --
    -- Parameters:
    --     IN    : itemtype      IN  VARCHAR2 (Required)
    --             Item type of the workflow

    --     IN    : itemkey       IN  VARCHAR2 (Required)
    --             Item key of the workflow

    --     IN    : actid         IN  NUMBER (Required)
    --             action

    --     IN    : funcmode      IN  VARCHAR2 (Required)
    --             function mode

    --     OUT  :  resultout     OUT VARCHAR2
    --             Status of  the workflow activity.
    --
    --
    -- called from:
    --     Workflow - processes
    --
    -- HISTORY
    --      13-FEB-2003  Sridhar Rajaparthi       Created
    --
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

  CURSOR c_dup_user (cp_user_name VARCHAR2,
                     cp_role_name VARCHAR2) IS
     SELECT count(1)
     FROM wf_local_user_roles
     WHERE user_name = cp_user_name
       AND role_name = cp_role_name
       AND role_orig_system = 'WF_LOCAL_ROLES'
       AND role_orig_system_id = 0;

    l_dup_user           NUMBER := 0;
    l_api_name           VARCHAR2(30) := 'SET_WF_ROLES';
    l_role_name          VARCHAR2(360) ;
    l_role_display_name  VARCHAR2(100);
    l_grantee_key        fnd_grants.grantee_key%TYPE;
    l_user_name          fnd_user.user_name%TYPE;
    l_party_id           hz_parties.party_id%TYPE;
    l_group_id           hz_parties.party_id%TYPE;

    l_create_role_name   VARCHAR2(2000);
    l_num  NUMBER;
    l_group_name         hz_parties.party_name%TYPE;

  BEGIN

mdebug( ' Create group admin wf role ');
    l_role_name  :=  G_GROUP_OBJECT_NAME || itemkey ;
    l_group_name := wf_engine.GetItemAttrText( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => G_GROUP_NAME);
    fnd_message.set_name('EGO', 'EGO_GROUP_APPROVER_LIST_NAME');
    fnd_message.set_token('GROUP_NAME', l_group_name);
    l_role_display_name := fnd_message.get;
    --
    -- set notification username
    --
    wf_engine.SetItemAttrText (itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'FROM_ROLE',
                               avalue   => fnd_global.user_name() );

    IF (funcmode  = 'RUN') THEN
      -- create the adhoc role
      Wf_Directory.CreateAdHocRole (role_name          => l_role_name,
                                    role_display_name  => l_role_display_name
                                   );
      l_group_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => G_GROUP_ID);
      FOR cr in c_get_admin_list(  l_group_id    ) LOOP
  	Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                          role_users => cr.user_name);
      END LOOP; -- c_get_admin_list
      Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  G_OWNER_USER_NAME,
                                 avalue    =>  l_role_name
			        );
       Resultout:= G_COMPLETE_STATUS;
       RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.context(G_PACKAGE_NAME,'create_grp_admin_wf_role',ItemType,ItemKey);
      IF c_get_admin_list%ISOPEN THEN
        CLOSE c_get_admin_list;
      END IF;
      IF c_dup_user%ISOPEN THEN
        CLOSE c_dup_user;
      END IF;
    RAISE;
  END create_grp_admin_wf_role;

END EGO_GROUP_WF_PKG;

/
