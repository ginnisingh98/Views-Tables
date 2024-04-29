--------------------------------------------------------
--  DDL for Package Body JTF_FM_INT_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_INT_REQUEST_PKG" AS
/* $Header: jtffmrqb.pls 120.42 2006/10/24 00:30:54 jakaur noship $ */

g_pkg_name    CONSTANT VARCHAR2(30) := 'JTF_FM_INT_REQUEST_PKG';
g_file_name   CONSTANT VARCHAR2(12) := 'bb.pls';

nodes               xmldom.DOMNodeList;
one_node            xmldom.DOMNode;
node_map            xmldom.DOMNamedNodeMap;
l_no_of_bind        NUMBER;
l_request_id        NUMBER;
var                 BLOB;
l_count             NUMBER;
l_buffer            VARCHAR2(32767);
l_email_body        VARCHAR2(30);
l_subject           VARCHAR2(2000);
l_user_history      VARCHAR2(30);
l_counter           NUMBER;
l_bind_object       VARCHAR2(2000);
l_length            NUMBER;
l_no_of_chunks      NUMBER;
l_cursor            NUMBER;
l_col_cnt           NUMBER;
l_rec_tab           DBMS_SQL.desc_tab;
l_parser            xmlparser.parser;
l_doc               xmldom.domdocument;
nl                  xmldom.DOMNodeList;
len1                NUMBER;
len2                NUMBER;
n                   xmldom.DOMNode;
n1                  xmldom.DOMNode;
e                   xmldom.DOMElement;

/*****************************************************************************
Forward declaration of private objects starts
******************************************************************************/
PROCEDURE clean_stalled_request ( p_request_id    IN         NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2
                                );

PROCEDURE get_next_partition ( x_errbuf        OUT NOCOPY VARCHAR2
                             , x_retcode       OUT NOCOPY VARCHAR2
                             , p_request_id    IN         NUMBER
                             , x_partition_id  OUT NOCOPY NUMBER);

PROCEDURE lock_partition ( x_errbuf         OUT NOCOPY  VARCHAR2
                         , x_retcode        OUT NOCOPY  VARCHAR2
                         , p_request_id     IN          NUMBER
                         , p_partition_id   IN          NUMBER
                         );

PROCEDURE unlock_partition ( x_errbuf         OUT NOCOPY  VARCHAR2
                           , x_retcode        OUT NOCOPY  VARCHAR2
                           , p_request_id     IN          NUMBER
                          );
/*****************************************************************************
Forward declaration ends
******************************************************************************/

/*---------------------------------------------------------------------------------*
 | Procedure Name : UPDATE_CONTACT_PREF                                            |
 |                                                                                 |
 | Purpose        : Updates jtf_fm_int_request_lines table for "DO NOT" contact    |
 |                  party IDs.                                                     |
 *---------------------------------------------------------------------------------*/
PROCEDURE update_contact_pref ( p_request_id IN NUMBER )
IS
TYPE l_line_id_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_line_id  l_line_id_table_type ;
CURSOR c_parties IS
       SELECT c.request_line_id
       FROM   hz_contact_preferences b  ,
              jtf_fm_int_request_lines c
       WHERE  b.preference_code                        = 'DO_NOT'
       AND    b.contact_level_table                    = 'HZ_PARTIES'
       AND    b.contact_level_table_id                 = c.party_id
       AND    c.request_id                             = p_request_id
       AND    NVL(b.preference_start_date, SYSDATE -1) < SYSDATE
       AND    NVL(b.preference_end_date, SYSDATE+1)    > SYSDATE  ;
BEGIN
  OPEN c_parties;
    FETCH c_parties BULK COLLECT INTO l_line_id      ;
  CLOSE c_parties;

  FORALL i IN l_line_id.FIRST .. l_line_id.LAST
     UPDATE jtf_fm_int_request_lines
     SET    contact_preference_flag = 'N',
            enabled_flag            = 'N'
     WHERE  request_line_id = l_line_id(i);
END update_contact_pref;


/*---------------------------------------------------------------------------------*
 | Procedure Name : VALIDATE_EMAIL                                                 |
 |                                                                                 |
 | Purpose        : Updates jtf_fm_int_request_lines table for invalid email       |
 |                  addresses.                                                     |
 *---------------------------------------------------------------------------------*/
PROCEDURE validate_email( p_request_id IN NUMBER )
IS
TYPE l_line_id_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_line_id   l_line_id_table_type ;
CURSOR c_lines IS
       SELECT c.request_line_id
       FROM   jtf_fm_int_request_lines c
       WHERE  c.request_id = p_request_id
       AND   (c.email_address IS NULL
       OR     INSTR(c.email_address,'@') < 1
       OR     INSTR(c.email_address, ':') > 0)
       AND    c.enabled_flag = 'Y';
BEGIN
  OPEN  c_lines;
    FETCH c_lines BULK COLLECT INTO l_line_id      ;
  CLOSE c_lines;

  FORALL i IN l_line_id.FIRST .. l_line_id.LAST
    UPDATE jtf_fm_int_request_lines
    SET    enabled_flag = 'N'
    WHERE  request_line_id = l_line_id(i);
END validate_email;

/*---------------------------------------------------------------------------------*
 | Procedure Name : RAISEBUSINESSEVENT                                             |
 |                                                                                 |
 | Purpose        : Allows end users to create business rules for blocking email   |
 |                  addresses.                                                     |
 *---------------------------------------------------------------------------------*/
PROCEDURE raiseBusinessEvent( p_request_id IN NUMBER )
IS
l_parameter_list  WF_PARAMETER_LIST_T;
l_new_item_key    VARCHAR2(30);
l_start_time      DATE;
BEGIN
  l_start_time      := SYSDATE;
  l_new_item_key    := p_request_id || '_'||TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list  := WF_PARAMETER_LIST_T();

  wf_event.AddParameterToList( p_name            => 'REQUEST_ID',
                               p_value           => p_request_id,
                               p_parameterlist   => l_parameter_list
                             );

  wf_event.RAISE ( p_event_name   =>  'oracle.apps.jtf.fm.int.RequestPostProcessing',
                   p_event_key    =>  l_new_item_key,
                   p_parameters   =>  l_parameter_list,
                   p_send_date    =>  l_start_time
                 );

END raiseBusinessEvent;

/*---------------------------------------------------------------------------------*
 | Procedure Name : DISPLAY_ELEMENT                                                |
 |                                                                                 |
 | Purpose        : Displays the first XML Element for a given node                |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE display_element (node IN xmldom.DOMNode )
IS
one_element   xmldom.DOMElement;
value_node    xmldom.DOMNode;
BEGIN
  one_element := xmldom.makeElement (node);
  value_node  := xmldom.getFirstChild (node);
END display_element ;

/*---------------------------------------------------------------------------------*
 | Procedure Name : GET_ELEMENT                                                    |
 |                                                                                 |
 | Purpose        : Displays the elements for a given node                         |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE get_element ( node             IN         xmldom.DOMNode
                      , value_node_value OUT NOCOPY VARCHAR2)
IS
one_element   xmldom.DOMElement;
value_node    xmldom.DOMNode;
BEGIN
  one_element      := xmldom.makeElement (node);
  value_node       := xmldom.getFirstChild (node);
  value_node_value :=  xmldom.getNodeValue (value_node);
END get_element ;

/*---------------------------------------------------------------------------------*
 | Procedure Name : DISPLAY_ATTRIBUTE                                              |
 |                                                                                 |
 | Purpose        : Displays attributes for a given node                           |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE display_attribute ( node_map     IN   xmldom.DOMNamedNodeMap,
                              attr_index   IN   PLS_INTEGER  )
IS
one_node   xmldom.DOMNode;
attrname   VARCHAR2(100);
attrval    VARCHAR2(100);
BEGIN
  one_node := xmldom.item (node_map, attr_index);
  attrname := xmldom.getNodeName (one_node);
  attrval  := xmldom.getNodeValue (one_node);
END display_attribute ;

/*---------------------------------------------------------------------------------*
 | Procedure Name : GET_ATTRIBUTE                                                  |
 |                                                                                 |
 | Purpose        : Gets the attribute for a given node map                        |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE get_attribute ( node_map     IN         xmldom.DOMNamedNodeMap
                        , attr_index   IN         PLS_INTEGER
                        , node_item    IN         VARCHAR2
                        , node_value   OUT NOCOPY VARCHAR2
                        ) IS
one_node   xmldom.DOMNode;
attrname   VARCHAR2 (100);
attrval    VARCHAR2 (100);
BEGIN
  one_node := xmldom.item (node_map, attr_index);
  attrname := xmldom.getNodeName (one_node);
  attrval  := xmldom.getNodeValue (one_node);

  IF attrname = node_item
  THEN
    node_value := attrval;
  END IF;
END get_attribute ;

/*---------------------------------------------------------------------------------*
 | Procedure Name : GET_ATTRIBUTEC                                                 |
 |                                                                                 |
 | Purpose        : Gets the attribute value for a given node map.                 |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE get_attributec ( node_map     IN         xmldom.DOMNamedNodeMap
                         , attr_index   IN         PLS_INTEGER
                         , node_item    IN         VARCHAR2
                         , node_value   OUT NOCOPY VARCHAR2
                         ) IS
one_node   xmldom.DOMNode;
attrname   VARCHAR2 (100);
attrval    VARCHAR2 (100);
BEGIN
  one_node := xmldom.item (node_map, attr_index);
  attrname := xmldom.getNodeName (one_node);
  attrval  := xmldom.getNodeValue (one_node);

   IF attrname = node_item
   THEN
     node_value := attrval;
   END IF;
END get_attributec ;

/*---------------------------------------------------------------------------------*
 | Procedure Name : PROCESS_REQUEST                                                |
 |                                                                                 |
 | Purpose        : Processes the query and XML for a given request ID. This       |
 |                  is called by MassRequstMonitor. Main functionalities are:      |
 |                  - Inserts record into jtf_fm_int_request_header table.         |
 |                  - Inserts record into jtf_fm_int_request_batches table.        |
 |                  - Creates partition and inserts records into                   |
 |                    jtff_fm_int_request_lines table.                             |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE  process_request( request_id          NUMBER
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_msg_count     OUT NOCOPY NUMBER
                          , x_msg_data      OUT NOCOPY VARCHAR2
                          ) IS
l_api_name         CONSTANT VARCHAR2(30) := 'Process_request';
l_full_name        CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;
l_bind                      CLOB;
l_amount                    NUMBER;
l_col_insert                VARCHAR2(3000);
l_party_first_name_col      VARCHAR2(200);
l_party_last_name_col       VARCHAR2(200);
l_email_address_col         VARCHAR2(200);
l_party_id_col              VARCHAR2(200);
l_create_part               VARCHAR2(1000);
l_query_id                  NUMBER;
l_temp_query_id             NUMBER;
l_batch_size                NUMBER;
l_clean_request_status      VARCHAR2(1);
l_header_count              NUMBER;
l_email_from_address        VARCHAR2(100) DEFAULT NULL;
l_email_reply_to_address    VARCHAR2(100) DEFAULT NULL;
l_sender_display_name       VARCHAR2(100) DEFAULT NULL;
l_header_name               JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_header_value              JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_bind_name                 JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_bind_value                JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_select_cols               VARCHAR2(3000);
l_insert_statement          VARCHAR2(32767);
l_fnd_query	            VARCHAR2(32767);
l_Add_columns               VARCHAR2(32767);
l_bind_variable             VARCHAR2(2000);
l_partition_id              NUMBER;
l_errbuf                    VARCHAR2(32767);
l_retcode                   VARCHAR2(1);
e_partition_not_found       EXCEPTION;
e_too_many_bind_vars        EXCEPTION;
BEGIN
  -- Standard begin of API savepoint
  SAVEPOINT  process_request;

  --Initialize message list if p_init_msg_list is TRUE.
   FND_MSG_PUB.initialize;

  IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
  THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('ARG1', l_full_name||': Start');
       FND_MSG_PUB.ADD;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT request, hist_req_id
  INTO   l_bind, l_request_id
  FROM   jtf_fm_request_history_all
  WHERE  hist_req_id = request_id;

  l_amount := DBMS_LOB.GETLENGTH(l_bind);

  DBMS_LOB.READ (l_bind, l_amount, 1, l_buffer);

  l_parser := xmlparser.newparser();
  xmlparser.parseBuffer(l_parser, l_buffer);
  l_doc    := xmlparser.getdocument(l_parser);

  -- get bind var elements
  nodes := xmldom.getElementsByTagName(l_doc,'bind_var');

  -- loop through elements
  FOR node_index IN 0 .. xmldom.getLength (nodes) - 1
  LOOP
    one_node := xmldom.item (nodes, node_index);

    IF (xmldom.getNodeName(one_node) = 'bind_var' )
    THEN
       get_element (one_node, l_bind_variable );
       node_map := xmldom.getAttributes (one_node);
       l_bind_value.extend();
       l_bind_value(node_index + 1) := l_bind_variable;

       FOR attr_index IN   0 .. xmldom.getLength (node_map) - 1
       LOOP
         get_attributec (node_map, attr_index,'bind_object',l_bind_object);
         IF (l_bind_object IS NOT NULL)
         THEN
          l_bind_name.extend();
          l_bind_name(node_index + 1) := l_bind_object ;
         END IF;
       END LOOP;
    END IF;
  END LOOP;

  nodes := xmldom.getElementsByTagName(l_doc,'file');

  -- loop through elements
  FOR node_index IN 0 .. xmldom.getLength (nodes) - 1
  LOOP
    one_node := xmldom.item (nodes, node_index);
      -- display_element (one_node);
    node_map := xmldom.getAttributes (one_node);

    FOR attr_index IN   0 .. xmldom.getLength (node_map) - 1
    LOOP
      --display_attribute (node_map, attr_index);
      get_attribute (node_map, attr_index,'query_id',l_temp_query_id);

      IF l_temp_query_id IS NOT NULL
      THEN
        l_query_id := l_temp_query_id;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;

  nodes := xmldom.getElementsByTagName(l_doc,'ffm_request');

  -- loop through elements
  FOR node_index IN 0 .. xmldom.getLength (nodes) - 1
  LOOP
    one_node := xmldom.item (nodes, node_index);

    -- display_element (one_node);
    node_map := xmldom.getAttributes (one_node);

    FOR attr_index IN   0 .. xmldom.getLength (node_map) - 1
    LOOP
      --display_attribute (node_map, attr_index);
      get_attribute (node_map, attr_index,'email_body',l_email_body);

      IF l_email_body IS NOT NULL
      THEN
        EXIT;
      END IF;
    END LOOP;
  END LOOP;

  FOR node_index IN 0 .. xmldom.getLength (nodes) - 1
  LOOP
    one_node := xmldom.item (nodes, node_index);

    -- display_element (one_node);
    node_map := xmldom.getAttributes (one_node);

    FOR attr_index IN   0 .. xmldom.getLength (node_map) - 1
    LOOP
      --display_attribute (node_map, attr_index);
      get_attribute (node_map, attr_index,'subject',l_subject);

      IF l_subject IS NOT NULL
      THEN
        EXIT;
      END IF;
    END LOOP;
  END LOOP;

  FOR node_index IN 0 .. xmldom.getLength (nodes) - 1
  LOOP
    one_node := xmldom.item (nodes, node_index);

    -- display_element (one_node);
    node_map := xmldom.getAttributes (one_node);

    FOR attr_index IN   0 .. xmldom.getLength (node_map) - 1
    LOOP
      -- display_attribute (node_map, attr_index);
      get_attribute (node_map, attr_index,'user_history',l_user_history);

      IF l_user_history IS NOT NULL
      THEN
        EXIT;
      END IF;
    END LOOP;
  END LOOP;

  nodes := xmldom.getelementsbytagname(l_doc,'header_name');

  -- loop through elements
  l_counter := 1;

  FOR node_index IN 0 .. xmldom.getlength (nodes) - 1
  LOOP
    one_node := xmldom.item (nodes, node_index);

    --display_element (one_node);
    l_header_name.extend();

    get_element (one_node, l_header_name(l_counter));

    IF l_header_name(l_counter) IS NOT NULL
    THEN
      NULL;
    END IF;

    node_map  := xmldom.getattributes (one_node);
    l_counter := l_counter +1 ;
  END LOOP;

  nodes     := xmldom.getelementsbytagname(l_doc,'header_value');
  l_counter := 1;

  FOR node_index IN 0 .. xmldom.getlength (nodes) - 1
  LOOP
    one_node := xmldom.item (nodes, node_index);
    l_header_value.extend();
    get_element (one_node, l_header_value(l_counter));

    IF l_header_name(l_counter) IS NOT NULL
    THEN
      NULL;
    END IF;

    node_map  := xmldom.getattributes (one_node);
    l_counter := l_counter +1 ;
  END LOOP;

  SELECT file_data
  INTO   var
  FROM   fnd_lobs
  WHERE  file_id = l_query_id;

  l_buffer := utl_raw.cast_to_varchar2(var);

  l_fnd_query := LTRIM(RTRIM(l_buffer)) ;

  l_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cursor, l_buffer, DBMS_SQL.NATIVE);

  DBMS_SQL.DESCRIBE_COLUMNS(l_cursor, l_col_cnt, l_rec_tab);

  FOR i IN l_col_cnt +1 .. 100
  LOOP
    l_rec_tab(i).col_name := '';
  END LOOP;

  l_count := l_header_value.COUNT();

  IF l_count > 0
  THEN
    FOR l_index IN l_header_value.FIRST .. l_header_value.LAST
    LOOP
      IF (l_header_name(l_index) = 'email_from_address')
      THEN
        l_email_from_address :=   l_header_value(l_index);
      ELSIF (l_header_name(l_index) = 'email_reply_to_address')
      THEN
        l_email_reply_to_address :=   l_header_value(l_index);
      ELSIF (l_header_name(l_index) = 'sender_display_name')
      THEN
        l_sender_display_name :=   l_header_value(l_index);
      END IF;
    END LOOP;
  END IF;

  --Checking records existence before calling the clean_stalled_request procedure.

  SELECT COUNT(ROWID)
  INTO   l_header_count
  FROM   jtf_fm_int_request_header
  WHERE  request_id     = l_request_id;


  IF ( l_header_count > 0)
  THEN
    clean_stalled_request ( p_request_id    => l_request_id
                          , x_return_status => l_clean_request_status
                          );
  END IF;

  INSERT INTO jtf_fm_int_request_header
       ( request_id
       , group_id
       , server_id
       , submit_dt_tm
       , processed_dt_tm
       , priority
       , source_code_id
       , source_code
       , object_id
       , object_type
       , outcome_desc
       , user_id
       , last_update_date
       , last_updated_by
       , creation_date
       , created_by
       , last_update_login
       , object_version_number
       , request_status
       , template_id
       , no_of_parameters
       , email_format
       , email_from_address
       , email_reply_to_address
       , sender_display_name
       , user_history
       , subject
       , parameter1
       , parameter2
       , parameter3
       , parameter4
       , parameter5
       , parameter6
       , parameter7
       , parameter8
       , parameter9
       , parameter10
       , parameter11
       , parameter12
       , parameter13
       , parameter14
       , parameter15
       , parameter16
       , parameter17
       , parameter18
       , parameter19
       , parameter20
       , parameter21
       , parameter22
       , parameter23
       , parameter24
       , parameter25
       , parameter26
       , parameter27
       , parameter28
       , parameter29
       , parameter30
       , parameter31
       , parameter32
       , parameter33
       , parameter34
       , parameter35
       , parameter36
       , parameter37
       , parameter38
       , parameter39
       , parameter40
       , parameter41
       , parameter42
       , parameter43
       , parameter44
       , parameter45
       , parameter46
       , parameter47
       , parameter48
       , parameter49
       , parameter50
       , parameter51
       , parameter52
       , parameter53
       , parameter54
       , parameter55
       , parameter56
       , parameter57
       , parameter58
       , parameter59
       , parameter60
       , parameter61
       , parameter62
       , parameter63
       , parameter64
       , parameter65
       , parameter66
       , parameter67
       , parameter68
       , parameter69
       , parameter70
       , parameter71
       , parameter72
       , parameter73
       , parameter74
       , parameter75
       , parameter76
       , parameter77
       , parameter78
       , parameter79
       , parameter80
       , parameter81
       , parameter82
       , parameter83
       , parameter84
       , parameter85
       , parameter86
       , parameter87
       , parameter88
       , parameter89
       , parameter90
       , parameter91
       , parameter92
       , parameter93
       , parameter94
       , parameter95
       , parameter96
       , parameter97
       , parameter98
       , parameter99
       , parameter100
       )
  SELECT
        l_request_id
      , group_id
      , server_id
      , submit_dt_tm
      , processed_dt_tm
      , priority
      , source_code_id
      , source_code
      , object_id
      , object_type
      , NULL
      , user_id
      , SYSDATE
      , last_updated_by
      , SYSDATE
      , created_by
      , last_update_login
      , 1
      , 'NEW'
      , template_id
      , l_col_cnt
      , l_email_body
      , l_email_from_address
      , l_email_reply_to_address
      , l_sender_display_name
      , l_user_history
      , l_subject
      , l_rec_tab(1).col_name
      , l_rec_tab(2).col_name
      , l_rec_tab(3).col_name
      , l_rec_tab(4).col_name
      , l_rec_tab(5).col_name
      , l_rec_tab(6).col_name
      , l_rec_tab(7).col_name
      , l_rec_tab(8).col_name
      , l_rec_tab(9).col_name
      , l_rec_tab(10).col_name
      , l_rec_tab(11).col_name
      , l_rec_tab(12).col_name
      , l_rec_tab(13).col_name
      , l_rec_tab(14).col_name
      , l_rec_tab(15).col_name
      , l_rec_tab(16).col_name
      , l_rec_tab(17).col_name
      , l_rec_tab(18).col_name
      , l_rec_tab(19).col_name
      , l_rec_tab(20).col_name
      , l_rec_tab(21).col_name
      , l_rec_tab(22).col_name
      , l_rec_tab(23).col_name
      , l_rec_tab(24).col_name
      , l_rec_tab(25).col_name
      , l_rec_tab(26).col_name
      , l_rec_tab(27).col_name
      , l_rec_tab(28).col_name
      , l_rec_tab(29).col_name
      , l_rec_tab(30).col_name
      , l_rec_tab(31).col_name
      , l_rec_tab(32).col_name
      , l_rec_tab(33).col_name
      , l_rec_tab(34).col_name
      , l_rec_tab(35).col_name
      , l_rec_tab(36).col_name
      , l_rec_tab(37).col_name
      , l_rec_tab(38).col_name
      , l_rec_tab(39).col_name
      , l_rec_tab(40).col_name
      , l_rec_tab(41).col_name
      , l_rec_tab(42).col_name
      , l_rec_tab(43).col_name
      , l_rec_tab(44).col_name
      , l_rec_tab(45).col_name
      , l_rec_tab(46).col_name
      , l_rec_tab(47).col_name
      , l_rec_tab(48).col_name
      , l_rec_tab(49).col_name
      , l_rec_tab(50).col_name
      , l_rec_tab(51).col_name
      , l_rec_tab(52).col_name
      , l_rec_tab(53).col_name
      , l_rec_tab(54).col_name
      , l_rec_tab(55).col_name
      , l_rec_tab(56).col_name
      , l_rec_tab(57).col_name
      , l_rec_tab(58).col_name
      , l_rec_tab(59).col_name
      , l_rec_tab(60).col_name
      , l_rec_tab(61).col_name
      , l_rec_tab(62).col_name
      , l_rec_tab(63).col_name
      , l_rec_tab(64).col_name
      , l_rec_tab(65).col_name
      , l_rec_tab(66).col_name
      , l_rec_tab(67).col_name
      , l_rec_tab(68).col_name
      , l_rec_tab(69).col_name
      , l_rec_tab(70).col_name
      , l_rec_tab(71).col_name
      , l_rec_tab(72).col_name
      , l_rec_tab(73).col_name
      , l_rec_tab(74).col_name
      , l_rec_tab(75).col_name
      , l_rec_tab(76).col_name
      , l_rec_tab(77).col_name
      , l_rec_tab(78).col_name
      , l_rec_tab(79).col_name
      , l_rec_tab(80).col_name
      , l_rec_tab(81).col_name
      , l_rec_tab(82).col_name
      , l_rec_tab(83).col_name
      , l_rec_tab(84).col_name
      , l_rec_tab(85).col_name
      , l_rec_tab(86).col_name
      , l_rec_tab(87).col_name
      , l_rec_tab(88).col_name
      , l_rec_tab(89).col_name
      , l_rec_tab(90).col_name
      , l_rec_tab(91).col_name
      , l_rec_tab(92).col_name
      , l_rec_tab(93).col_name
      , l_rec_tab(94).col_name
      , l_rec_tab(95).col_name
      , l_rec_tab(96).col_name
      , l_rec_tab(97).col_name
      , l_rec_tab(98).col_name
      , l_rec_tab(99).col_name
      , l_rec_tab(100).col_name
  FROM  jtf_fm_request_history_all
  WHERE hist_req_id = l_request_id;

  l_col_insert := '';

  FOR i IN 1 .. l_col_cnt
  LOOP
    IF UPPER(l_rec_tab(i).col_name) = 'CUSTOMER_ID'
    THEN
      l_party_id_col := 'col'||i;
    END IF;

    IF UPPER(l_rec_tab(i).col_name) = 'EMAILADDRESS'
    THEN
      l_email_address_col := 'col'||i;
    END IF;

    IF UPPER(l_rec_tab(i).col_name) = 'FIRST_NAME' THEN
      l_party_first_name_col := 'col'||i;
    END IF;

    IF UPPER(l_rec_tab(i).col_name) = 'LAST_NAME' THEN
      l_party_last_name_col := 'col'||i;
    END IF;

    l_col_insert := l_col_insert ||',col'||i ;
  END LOOP;

  l_batch_size := NVL(FND_PROFILE.value('JTF_FM_BATCH_SIZE'),1000);

  --Call to get_next_partition
  get_next_partition ( x_errbuf        => l_errbuf
                     , x_retcode       => l_retcode
                     , p_request_id    => l_request_id
                     , x_partition_id  => l_partition_id);

  IF (l_retcode <> 'S')
  THEN
    RAISE e_partition_not_found;
  END IF;

  --static columns
  l_insert_statement := 'INSERT INTO jtf_fm_int_request_lines ( request_id, request_line_id, partition_id, batch_no, last_update_date, last_updated_by, creation_date,
                                                                created_by, last_update_login, object_version_number, email_status, enabled_flag,
                                                                contact_preference_flag  ';

  --values for static columns
  l_select_cols :='SELECT ' || l_request_id ||', JTF_FM_INT_REQUEST_LINES_s.NEXTVAL,   '|| l_partition_id ||',
                   CEIL(ROWNUM/ ' || l_batch_size || '     ),
                   SYSDATE,
                   1,
                   SYSDATE,
                   1,
                   1,
                   1,
                   '||''''||'AVAILABLE'||''''||','||
                   ''''||'Y'||''''||','
                   ||''''||'Y'||''''||',';

  --adding this to the insert statement to avoid update on these rows
  IF (l_party_id_col IS NOT NULL) THEN
    l_insert_statement := l_insert_statement || ', party_id';
    l_select_cols := l_select_cols || 'UserQuery.customer_id, ';
  END IF;

  --Logic to create the party name based upon the first name and last name.
  IF (( l_party_first_name_col IS NOT NULL) AND
      ( l_party_last_name_col IS NULL))
  THEN
    l_insert_statement := l_insert_statement || ', party_name';
    l_select_cols      := l_select_cols || 'UserQuery.first_name,';
  ELSIF (( l_party_first_name_col IS NULL) AND
         ( l_party_last_name_col IS NOT NULL))
  THEN
    l_insert_statement := l_insert_statement || ', party_name';
    l_select_cols      := l_select_cols || 'UserQuery.last_name,';
  ELSIF (( l_party_first_name_col IS NOT NULL) AND
         ( l_party_last_name_col IS NOT NULL))
  THEN
    l_insert_statement := l_insert_statement || ', party_name';
    l_select_cols      := l_select_cols || 'UserQuery.first_name || '' ''||UserQuery.last_name, ';
  ELSE
    l_insert_statement := l_insert_statement;
    l_select_cols      := l_select_cols;
  END IF;

  IF (l_email_address_col IS NOT NULL) THEN
    l_insert_statement := l_insert_statement || ', email_address';
    l_select_cols := l_select_cols || 'UserQuery.emailaddress, ';
  END IF;

  --creating the l_insert_statement from the static columns, their values and the
  --query from the user
  l_insert_statement := l_insert_statement ||  l_col_insert;
  l_insert_statement := l_insert_statement || ') ' || l_select_cols || ' UserQuery.* from ('||l_fnd_query ||') UserQuery';

  l_insert_statement := 'BEGIN ' || l_insert_statement || '; END;';

  l_length := LENGTH(l_insert_statement);
  l_no_of_chunks := CEIL(l_length/255);

  --No need to create partition based upon the request_id
  --l_create_part := 'ALTER TABLE jtf_fm_int_request_lines ADD PARTITION p_'|| l_request_id  || ' VALUES ('||l_request_id || ')';
  --EXECUTE IMMEDIATE l_create_part;


  --Execute immediate requires the bind variables individually mentioned in the USING part.
  --Dynamic Statements cannot be used if the input count is not known.
  --Explored using DBMS_SQL but the performance is compromised
  --We have therefore limited the number of bind variables to 5 and mentioned each case individually
  IF l_bind_value.COUNT = 0
  THEN
    EXECUTE IMMEDIATE l_insert_statement;
  ELSIF l_bind_value.COUNT = 1 THEN
      EXECUTE IMMEDIATE l_insert_statement USING  l_bind_value(1);
  ELSIF l_bind_value.COUNT = 2 THEN
      EXECUTE IMMEDIATE l_insert_statement USING  l_bind_value(1), l_bind_value(2);
  ELSIF l_bind_value.COUNT = 3 THEN
      EXECUTE IMMEDIATE l_insert_statement USING  l_bind_value(1), l_bind_value(2),l_bind_value(3);
  ELSIF l_bind_value.COUNT = 4 THEN
      EXECUTE IMMEDIATE l_insert_statement USING  l_bind_value(1), l_bind_value(2),l_bind_value(3),l_bind_value(4);
  ELSIF l_bind_value.COUNT = 5 THEN
      EXECUTE IMMEDIATE l_insert_statement USING  l_bind_value(1), l_bind_value(2),l_bind_value(3),l_bind_value(4),l_bind_value(5);
  ELSE
      RAISE e_too_many_bind_vars;
  END IF;

  INSERT INTO jtf_fm_int_request_batches
  ( request_id,
    batch_id,
    request_line_id_start,
    request_line_id_end,
    server_instance_id,
    batch_status ,
    last_update_date
  )
  SELECT
    l_request_id,
    d.batch_no,
    MIN(d.request_line_id),
    MAX(d.request_line_id),
    '',
    'AVAILABLE',
    SYSDATE
  FROM  jtf_fm_int_request_lines  d
  WHERE d.request_id = l_request_id
  GROUP BY d.batch_no;

  COMMIT;

  IF (NVL(FND_PROFILE.value('JTF_FM_PRELOAD_TCA_PREF'), 'Y') = 'Y')
  THEN
    update_contact_pref(l_request_id );
  END IF;

  validate_email(l_request_id );

  raiseBusinessEvent(l_request_id);

  UPDATE jtf_fm_int_request_header c
  SET    c.request_status = 'AVAILABLE'
  WHERE  c.request_id  = l_request_id ;

/* -- Moved to get_next_request procedure
  UPDATE jtf_fm_status_all c
  SET    c.request_status = 'IN_PROCESS'
  WHERE  c.request_id  = l_request_id;

  UPDATE jtf_fm_request_history_all c
  SET    c.outcome_code  = 'IN_PROCESS'
  WHERE  c.hist_req_id  = l_request_id;
*/

  COMMIT;

  x_return_status := 'S';
  x_msg_count     := 0;
  x_msg_data      := '';

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_return_status := FND_API.g_ret_sts_error ;
    FND_MSG_PUB.Count_AND_Get ( p_count       =>      x_msg_count,
                                p_data        =>      x_msg_data,
                                p_encoded     =>      FND_API.G_FALSE
                              );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
          );
  WHEN e_too_many_bind_vars
  THEN
    x_return_status := FND_API.g_ret_sts_error ;
    x_msg_data := 'Error : Only 5 bind variables allowed in query';
  WHEN e_partition_not_found
  THEN
    x_return_status := FND_API.g_ret_sts_error ;
    x_msg_data      := 'Unable to locate partition';
  WHEN OTHERS
  THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    x_msg_data := SQLERRM;
END process_request;

/*---------------------------------------------------------------------------------*
 | Procedure Name : UPDATE_LINES_STATUS_BULK                                       |
 |                                                                                 |
 | Purpose        : For a given set of lines id, this procedure updates the        |
 |                  jtf_fm_int_request_lines table and sets the email status to    |
 |                  the passed email status PL/SQL table.                          |
 |                  - Updates jtf_fm_int_request_header - for request status       |
 |                  - Updates jtf_fm_status_all - for request status               |
 |                  - Updates jtf_fm_request_history_all - for outcome code        |
 |                  - Updates jtf_fm_email_stat - for email details                |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE update_lines_status_bulk ( line_ids        IN         JTF_VARCHAR2_TABLE_100
                                   , request_id      IN         NUMBER
                                   , line_status     IN         JTF_VARCHAR2_TABLE_100
                                   , p_commit        IN         VARCHAR2   := FND_API.G_FALSE
                                   , x_return_status OUT NOCOPY VARCHAR2
                                   , x_msg_count     OUT NOCOPY NUMBER
                                   , x_msg_data      OUT NOCOPY VARCHAR2
                                   ) IS
l_request_id            NUMBER;
l_complete_flag         VARCHAR2(1) := 'N';
l_contact_pref_disabled NUMBER;
l_not_delivered         NUMBER;
l_disabled_flag         NUMBER;
l_count                 NUMBER;
CURSOR c_processed IS
          SELECT 'Y'
          FROM   jtf_fm_int_request_header c
          WHERE  c.request_id = l_request_id
          AND    c.request_status = 'READYTOLOG'  ;
CURSOR c_details IS
          SELECT  SUM(DECODE(c.contact_preference_flag,'N',1,0)) ,
                  SUM(DECODE(c.email_status,'NOTDELIVERED',1,0)) ,
                  SUM(DECODE(c.enabled_flag, 'N',1,0)),
                  COUNT(1)
          FROM    jtf_fm_int_request_lines c
          WHERE   c.request_id = l_request_id ;
BEGIN
  l_request_id := request_id;

  FORALL i IN LINE_IDS.FIRST .. LINE_IDS.LAST
    UPDATE jtf_fm_int_request_lines
    SET    email_status  = line_status(i)
    WHERE  request_line_id  = line_ids(i);

  UPDATE jtf_fm_int_request_header c
  SET    c.request_status = 'READYTOLOG'
  WHERE  c.request_id =  l_request_id
  AND    NOT EXISTS ( SELECT '1'
                      FROM   jtf_fm_int_request_lines  a
                      WHERE  c.request_id = a.request_id
                      AND    a.email_status IN ('AVAILABLE', 'NEW','ASSIGNED')
                      AND    a.enabled_flag = 'Y' );
  OPEN c_processed;
    FETCH c_processed INTO l_complete_flag;
  CLOSE c_processed;

  IF l_complete_flag  = 'Y'
  THEN
    OPEN c_details;
      FETCH c_details INTO l_contact_pref_disabled ,
                           l_not_delivered ,
                           l_disabled_flag  ,
                           l_count ;
    CLOSE c_details;

    UPDATE jtf_fm_status_all c
    SET    c.request_status     = 'READYTOLOG',
           c.LAST_UPDATE_DATE   = SYSDATE,
           c.jobs_processed     = l_count
    WHERE  c.request_id         = l_request_id;

    UPDATE jtf_fm_request_history_all
    SET    outcome_code     = 'READYTOLOG',
           total_jobs       = l_count,
           process_dt_tm    = SYSDATE,
           processed_dt_tm  = SYSDATE,
           last_update_date = SYSDATE
    WHERE  hist_req_id      = l_request_id;

    UPDATE jtf_fm_email_stats
    SET    total          = l_count,
           sent           = l_count - l_not_delivered ,
           malformed      = l_disabled_flag  - l_contact_pref_disabled ,
           bounced        = 0,
           opened         = 0,
           unsubscribed   = 0,
           do_not_contact = l_contact_pref_disabled
    WHERE request_id      = l_request_id ;

  END IF;

  IF x_return_status =  fnd_api.g_ret_sts_error
  THEN
    RAISE FND_API.g_exc_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF p_commit = FND_API.g_true
  THEN
    COMMIT WORK;
  END IF;

  x_return_status := 'S';

  FND_MSG_PUB.Count_AND_Get ( p_count           =>      x_msg_count,
                              p_data            =>      x_msg_data,
                              p_encoded         =>      FND_API.G_FALSE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_return_status := FND_API.g_ret_sts_error ;
    FND_MSG_PUB.Count_AND_Get ( p_count       =>      x_msg_count,
                                p_data        =>      x_msg_data,
                                p_encoded     =>      FND_API.G_FALSE
                              );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
          );
  WHEN OTHERS
  THEN
    x_return_status := FND_API.g_ret_sts_unexp_erroR ;

    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      NULL;
    END IF;

    FND_MSG_PUB.Count_AND_Get ( p_count           =>      x_msg_count,
                                p_data            =>      x_msg_data,
                                p_encoded         =>      FND_API.G_FALSE
                              );

END;

/*---------------------------------------------------------------------------------*
 | Procedure Name : UPDATE_LINES_STATUS                                            |
 |                                                                                 |
 | Purpose        : For a given set of lines id, this procedure updates the        |
 |                  jtf_fm_int_request_lines table and sets the email status to    |
 |                  the passed email status PL/SQL table.                          |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE update_lines_status ( line_ids        IN         JTF_VARCHAR2_TABLE_100
                              , request_id      IN         NUMBER
                              , line_status     IN         VARCHAR2
                              , p_commit        IN         VARCHAR2   := FND_API.G_FALSE
                              , x_return_status OUT NOCOPY VARCHAR2
                              , x_msg_count     OUT NOCOPY NUMBER
                              , x_msg_data      OUT NOCOPY VARCHAR2
                              ) IS
BEGIN
  FORALL i IN LINE_IDS.FIRST .. LINE_IDS.LAST
    UPDATE jtf_fm_int_request_lines
    SET    email_status  = line_status
    WHERE  request_line_id  = line_ids(i);

  IF x_return_status =  fnd_api.g_ret_sts_error
  THEN
    RAISE FND_API.g_exc_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF p_commit = FND_API.g_true
  THEN
    COMMIT WORK;
  END IF;

  x_return_status := 'S';
  FND_MSG_PUB.Count_AND_Get ( p_count           =>      x_msg_count,
                              p_data            =>      x_msg_data,
                              p_encoded         =>      FND_API.G_FALSE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
     x_return_status := FND_API.g_ret_sts_error ;
     FND_MSG_PUB.Count_AND_Get ( p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data,
                                 p_encoded     =>      FND_API.G_FALSE
                               );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.Count_AND_Get ( p_count           =>      x_msg_count,
                                 p_data            =>      x_msg_data,
                                 p_encoded         =>      FND_API.G_FALSE
                               );
  WHEN OTHERS
  THEN
     x_return_status := FND_API.g_ret_sts_unexp_erroR ;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        NULL;
     END IF;

     FND_MSG_PUB.Count_AND_Get ( p_count           =>      x_msg_count,
                                 p_data            =>      x_msg_data,
                                 p_encoded         =>      FND_API.G_FALSE
                               );

END;

/*---------------------------------------------------------------------------------*
 | Procedure Name : UPDATE_INSTANCE_STATUS                                         |
 |                                                                                 |
 | Purpose        : - Updates jtf_fm_int_request_batches - for batch status        |
 |                  - Updates jtf_fm_int_request_header - for request status       |
 |                  - Updates jtf_fm_status_all - for request status               |
 |                  - Updates jtf_fm_request_history_all - for outcome code        |
 |                  - Updates jtf_fm_email_stat - for email details                |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE update_instance_status( p_request_id        IN         NUMBER
                                , p_server_id         IN         NUMBER
                                , p_instance_id       IN         NUMBER
                                , p_status            IN         VARCHAR2
                                , p_commit            IN         VARCHAR2   := FND_API.G_FALSE
                                , x_return_status     OUT NOCOPY VARCHAR2
                                , x_msg_count         OUT NOCOPY NUMBER
                                , x_msg_data          OUT NOCOPY VARCHAR2
                                ) IS
l_request_id            NUMBER;
l_complete_flag         VARCHAR2(1) := 'N';
l_contact_pref_disabled NUMBER;
l_not_delivered         NUMBER;
l_disabled_flag         NUMBER;
l_count                 NUMBER;
CURSOR c_header IS
          SELECT 'Y'
          FROM   jtf_fm_int_request_header c
          WHERE  c.request_id = l_request_id
          AND    c.request_status = 'READYTOLOG'  ;

CURSOR c_lines IS
          SELECT SUM(DECODE(c.CONTACT_PREFERENCE_FLAG,'N',1,0)) ,
                 SUM(DECODE(c.EMAIL_STATUS,'NOTDELIVERED',1,0)) ,
                 SUM(DECODE(c.enabled_flag, 'N',1,0)),
                 COUNT(1)
          FROM   jtf_fm_int_request_lines c
          WHERE  c.request_id = l_request_id ;
BEGIN
  l_request_id := p_request_id;

  UPDATE jtf_fm_int_request_batches
  SET    batch_status     = p_status,
         last_update_date = SYSDATE
  WHERE  request_id       = p_request_id;

  UPDATE jtf_fm_int_request_header c
  SET    c.request_status = 'READYTOLOG'
  WHERE  c.request_id     =  p_request_id
  AND    NOT EXISTS ( SELECT '1'
                      FROM   jtf_fm_int_request_batches a
                      WHERE  c.request_id = a.request_id
                      AND    a.batch_status IN ('AVAILABLE', 'NEW','ASSIGNED')
                    );
  OPEN c_header;
    FETCH c_header INTO l_complete_flag;
  CLOSE c_header;

  IF l_complete_flag  = 'Y' THEN
    OPEN c_lines;
       FETCH c_lines INTO l_contact_pref_disabled ,
                          l_not_delivered ,
                          l_disabled_flag  ,
                          l_count ;
    CLOSE c_lines;

    UPDATE jtf_fm_status_all c
    SET    c.request_status    = 'READYTOLOG',
           c.LAST_UPDATE_DATE  = SYSDATE,
           c.jobs_processed    = l_count
    WHERE  c.request_id        = l_request_id;

    UPDATE jtf_fm_request_history_all
    SET    outcome_code     = 'READYTOLOG',
           total_jobs       = l_count,
           process_dt_tm    = SYSDATE,
           processed_dt_tm  = SYSDATE,
           last_update_date = SYSDATE
    WHERE  hist_req_id      = l_request_id;

    UPDATE jtf_fm_email_stats
    SET    total          = l_count,
           sent           = l_count - l_not_delivered ,
           malformed      = l_disabled_flag  - l_contact_pref_disabled ,
           bounced        = 0,
           opened         = 0,
           unsubscribed   = 0,
           do_not_contact = l_contact_pref_disabled
    WHERE  request_id=l_request_id ;

  END IF;

  IF x_return_status =  fnd_api.g_ret_sts_error
   THEN
     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF p_commit = FND_API.g_true
  THEN
     COMMIT WORK;
  END IF;

  x_return_status := 'S';
  x_msg_count         := 0;
  x_msg_data          := '';

  FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_return_status := FND_API.g_ret_sts_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded     =>      FND_API.G_FALSE
          );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
          );
  WHEN OTHERS
  THEN
    x_return_status := FND_API.g_ret_sts_unexp_erroR ;

    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      NULL;
    END IF;

    FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );

END;

/*---------------------------------------------------------------------------------*
 | Procedure Name : CLEAN_UP_INSTANCE                                              |
 |                                                                                 |
 | Purpose        : - Updates jtf_fm_int_request_batches - for batch status        |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE clean_up_instance( p_request_id    IN         NUMBER
                           , p_server_id     IN         NUMBER
                           , p_instance_id   IN         NUMBER
                           , P_commit        IN         VARCHAR2   := FND_API.G_FALSE
                           , x_return_status OUT NOCOPY VARCHAR2
                           , x_msg_count     OUT NOCOPY NUMBER
                           , x_msg_data      OUT NOCOPY VARCHAR2) IS
BEGIN
  UPDATE jtf_fm_int_request_batches
  SET    batch_status       = 'NEW',
         last_update_date   = SYSDATE
  WHERE  request_ID         = p_request_id
  AND    server_instance_id = p_instance_id;

  IF x_return_status =  fnd_api.g_ret_sts_error
  THEN
    RAISE FND_API.g_exc_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF p_commit = FND_API.g_true
  THEN
    COMMIT WORK;
  END IF;

  x_return_status := 'S';

  FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_return_status := FND_API.g_ret_sts_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded     =>      FND_API.G_FALSE
          );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
          );
  WHEN OTHERS
  THEN
    x_return_status := FND_API.g_ret_sts_unexp_erroR ;

    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
        NULL;
    END IF;
    FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );

END;

/*---------------------------------------------------------------------------------*
 | Procedure Name : GET_NEXT_REQUEST                                               |
 |                                                                                 |
 | Purpose        : Selects from jtf_fm_int_request_lines , and                    |
 |                  - Updates jtf_fm_int_request_header - for request status       |
 |                  - Updates jtf_fm_status_all - for request status               |
 |                  - Updates jtf_fm_request_history_all - for outcome code        |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE get_next_request( p_server_id              IN         NUMBER
                          , p_instance_id            IN         NUMBER
                          , p_request_id             OUT NOCOPY NUMBER
                          , p_template_id            OUT NOCOPY NUMBER
                          , p_no_of_parameters       OUT NOCOPY NUMBER
                          , p_email_format           OUT NOCOPY VARCHAR2
                          , p_email_from_address     OUT NOCOPY VARCHAR2
                          , p_email_reply_to_address OUT NOCOPY VARCHAR2
                          , p_sender_display_name    OUT NOCOPY VARCHAR2
                          , p_subject                OUT NOCOPY VARCHAR2
                          , p_parameter_table        OUT NOCOPY JTF_VARCHAR2_TABLE_100
                          , x_return_status          OUT NOCOPY VARCHAR2
                          , x_msg_count              OUT NOCOPY NUMBER
                          , x_msg_data               OUT NOCOPY VARCHAR2
                          ) IS
CURSOR c_header  IS
        SELECT request_id,
               template_id,
               NO_OF_PARAMETERS,
               EMAIL_FORMAT,
               EMAIL_FROM_ADDRESS,
               EMAIL_REPLY_TO_ADDRESS,
               sender_display_name,
               subject ,
               parameter1,
               parameter2,
               parameter3,
               parameter4,
               parameter5,
               parameter6,
               parameter7,
               parameter8,
               parameter9,
               parameter10,
               parameter11,
               parameter12,
               parameter13,
               parameter14,
               parameter15,
               parameter16,
               parameter17,
               parameter18,
               parameter19,
               parameter20,
               parameter21,
               parameter22,
               parameter23,
               parameter24,
               parameter25,
               parameter26,
               parameter27,
               parameter28,
               parameter29,
               parameter30,
               parameter31,
               parameter32,
               parameter33,
               parameter34,
               parameter35,
               parameter36,
               parameter37,
               parameter38,
               parameter39,
               parameter40,
               parameter41,
               parameter42,
               parameter43,
               parameter44,
               parameter45,
               parameter46,
               parameter47,
               parameter48,
               parameter49,
               parameter50,
               parameter51,
               parameter52,
               parameter53,
               parameter54,
               parameter55,
               parameter56,
               parameter57,
               parameter58,
               parameter59,
               parameter60,
               parameter61,
               parameter62,
               parameter63,
               parameter64,
               parameter65,
               parameter66,
               parameter67,
               parameter68,
               parameter69,
               parameter70,
               parameter71,
               parameter72,
               parameter73,
               parameter74,
               parameter75,
               parameter76,
               parameter77,
               parameter78,
               parameter79,
               parameter80,
               parameter81,
               parameter82,
               parameter83,
               parameter84,
               parameter85,
               parameter86,
               parameter87,
               parameter88,
               parameter89,
               parameter90,
               parameter91,
               parameter92,
               parameter93,
               parameter94,
               parameter95,
               parameter96,
               parameter97,
               parameter98,
               parameter99,
               parameter100
        FROM   jtf_fm_int_request_header
        WHERE  request_status IN ('AVAILABLE','INPROGRESS' )
        AND    server_id = p_server_id
        ORDER BY priority, creation_date DESC;
l_header_request_id   NUMBER;
BEGIN
  p_parameter_table := jtf_varchar2_table_100();

  FOR i IN 1 .. 100
  LOOP
    p_parameter_table.extend();
  END LOOP;

  OPEN c_header ;
    FETCH c_header INTO  p_request_id,
                         p_template_id,
                         p_no_of_parameters,
                         p_email_format,
                         p_email_from_address,
                         p_email_reply_to_address,
                         p_sender_display_name,
                         p_subject ,
                         p_parameter_table(1),
                         p_parameter_table(2),
                         p_parameter_table(3),
                         p_parameter_table(4),
                         p_parameter_table(5),
                         p_parameter_table(6),
                         p_parameter_table(7),
                         p_parameter_table(8),
                         p_parameter_table(9),
                         p_parameter_table(10),
                         p_parameter_table(11),
                         p_parameter_table(12),
                         p_parameter_table(13),
                         p_parameter_table(14),
                         p_parameter_table(15),
                         p_parameter_table(16),
                         p_parameter_table(17),
                         p_parameter_table(18),
                         p_parameter_table(19),
                         p_parameter_table(20),
                         p_parameter_table(21),
                         p_parameter_table(22),
                         p_parameter_table(23),
                         p_parameter_table(24),
                         p_parameter_table(25),
                         p_parameter_table(26),
                         p_parameter_table(27),
                         p_parameter_table(28),
                         p_parameter_table(29),
                         p_parameter_table(30),
                         p_parameter_table(31),
                         p_parameter_table(32),
                         p_parameter_table(33),
                         p_parameter_table(34),
                         p_parameter_table(35),
                         p_parameter_table(36),
                         p_parameter_table(37),
                         p_parameter_table(38),
                         p_parameter_table(39),
                         p_parameter_table(40),
                         p_parameter_table(41),
                         p_parameter_table(42),
                         p_parameter_table(43),
                         p_parameter_table(44),
                         p_parameter_table(45),
                         p_parameter_table(46),
                         p_parameter_table(47),
                         p_parameter_table(48),
                         p_parameter_table(49),
                         p_parameter_table(50),
                         p_parameter_table(51),
                         p_parameter_table(52),
                         p_parameter_table(53),
                         p_parameter_table(54),
                         p_parameter_table(55),
                         p_parameter_table(56),
                         p_parameter_table(57),
                         p_parameter_table(58),
                         p_parameter_table(59),
                         p_parameter_table(60),
                         p_parameter_table(61),
                         p_parameter_table(62),
                         p_parameter_table(63),
                         p_parameter_table(64),
                         p_parameter_table(65),
                         p_parameter_table(66),
                         p_parameter_table(67),
                         p_parameter_table(68),
                         p_parameter_table(69),
                         p_parameter_table(70),
                         p_parameter_table(71),
                         p_parameter_table(72),
                         p_parameter_table(73),
                         p_parameter_table(74),
                         p_parameter_table(75),
                         p_parameter_table(76),
                         p_parameter_table(77),
                         p_parameter_table(78),
                         p_parameter_table(79),
                         p_parameter_table(80),
                         p_parameter_table(81),
                         p_parameter_table(82),
                         p_parameter_table(83),
                         p_parameter_table(84),
                         p_parameter_table(85),
                         p_parameter_table(86),
                         p_parameter_table(87),
                         p_parameter_table(88),
                         p_parameter_table(89),
                         p_parameter_table(90),
                         p_parameter_table(91),
                         p_parameter_table(92),
                         p_parameter_table(93),
                         p_parameter_table(94),
                         p_parameter_table(95),
                         p_parameter_table(96),
                         p_parameter_table(97),
                         p_parameter_table(98),
                         p_parameter_table(99),
                         p_parameter_table(100) ;
  CLOSE c_header;

  l_header_request_id := p_request_id;

  UPDATE jtf_fm_int_request_header
  SET    request_status = 'INPROGRESS'
  WHERE  request_id     = p_request_id
  AND    request_status = 'AVAILABLE';

  UPDATE jtf_fm_status_all c
  SET    c.request_status = 'IN_PROCESS'
  WHERE  c.request_id     = l_header_request_id
  AND    c.request_status <> 'READYTOLOG'
  ;

  UPDATE jtf_fm_request_history_all c
  SET    c.outcome_code  = 'IN_PROCESS'
  WHERE  c.hist_req_id   = l_header_request_id
  AND    c.outcome_code  <> 'READYTOLOG'
  ;

  COMMIT;

  x_return_status := 'S';
  x_msg_count     := 0;
  x_msg_data      := '';

END get_next_request;

/*---------------------------------------------------------------------------------*
 | Procedure Name : GET_NEXT_BATCH                                                 |
 |                                                                                 |
 | Purpose        : Selects from jtf_fm_int_request_lines , and                    |
 |                  - Updates jtf_fm_int_request_batches - for request status      |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE get_next_batch ( p_request_id     IN NUMBER
                         , p_server_id      IN NUMBER
                         , p_instance_id    IN NUMBER
                         , P_commit         IN VARCHAR2   := FND_API.G_FALSE
                         , p_line_ids       OUT NOCOPY JTF_NUMBER_TABLE
                         , p_party_id       OUT NOCOPY JTF_NUMBER_TABLE
                         , p_party_name     OUT NOCOPY JTF_VARCHAR2_TABLE_200
                         , p_email_address  OUT NOCOPY JTF_VARCHAR2_TABLE_200
                         , p_COL1           OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL2           OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL3           OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL4           OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL5           OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL6           OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL7           OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL8           OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL9           OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL10          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL11          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL12          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL13          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL14          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL15          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL16          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL17          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL18          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL19          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL20          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL21          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL22          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL23          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL24          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL25          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL26          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL27          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL28          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL29          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL30          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL31          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL32          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL33          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL34          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL35          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL36          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL37          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL38          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL39          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL40          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL41          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL42          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL43          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL44          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL45          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL46          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL47          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL48          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL49          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL50          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL51          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL52          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL53          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL54          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL55          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL56          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL57          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL58          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL59          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL60          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL61          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL62          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL63          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL64          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL65          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL66          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL67          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL68          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL69          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL70          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL71          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL72          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL73          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL74          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL75          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL76          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL77          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL78          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL79          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL80          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL81          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL82          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL83          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL84          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL85          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL86          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL87          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL88          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL89          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL90          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL91          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL92          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL93          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL94          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL95          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL96          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL97          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL98          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL99          OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , p_COL100         OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                         , x_no_of_rows     OUT NOCOPY  NUMBER
                         , x_return_status  OUT NOCOPY VARCHAR2
                         , x_msg_count      OUT NOCOPY NUMBER
                         , x_msg_data       OUT NOCOPY VARCHAR2) IS
CURSOR c_batch IS
          SELECT rb.batch_id,
                 rb.request_line_id_start ,
                 rb.request_line_id_end
          FROM  jtf_fm_int_request_batches  rb
          WHERE rb.request_id   = p_request_id
          AND   rb.batch_status = 'AVAILABLE' ;
l_batch_id                NUMBER;
l_request_line_id_start   NUMBER;
l_request_line_id_end     NUMBER;
l_batch_size              NUMBER;
BEGIN
  p_line_ids             := JTF_NUMBER_TABLE();
  p_PARTY_ID             := JTF_NUMBER_TABLE();
  p_PARTY_NAME           := JTF_VARCHAR2_TABLE_200();
  p_EMAIL_ADDRESS        := JTF_VARCHAR2_TABLE_200();
  p_COL1                 := JTF_VARCHAR2_TABLE_2000();
  p_COL2                 := JTF_VARCHAR2_TABLE_2000();
  p_COL3                 := JTF_VARCHAR2_TABLE_2000();
  p_COL4                 := JTF_VARCHAR2_TABLE_2000();
  p_COL5                 := JTF_VARCHAR2_TABLE_2000();
  p_COL6                 := JTF_VARCHAR2_TABLE_2000();
  p_COL7                 := JTF_VARCHAR2_TABLE_2000();
  p_COL8                 := JTF_VARCHAR2_TABLE_2000();
  p_COL9                 := JTF_VARCHAR2_TABLE_2000();
  p_COL10                := JTF_VARCHAR2_TABLE_2000();
  p_COL11                := JTF_VARCHAR2_TABLE_2000();
  p_COL12                := JTF_VARCHAR2_TABLE_2000();
  p_COL13                := JTF_VARCHAR2_TABLE_2000();
  p_COL14                := JTF_VARCHAR2_TABLE_2000();
  p_COL15                := JTF_VARCHAR2_TABLE_2000();
  p_COL16                := JTF_VARCHAR2_TABLE_2000();
  p_COL17                := JTF_VARCHAR2_TABLE_2000();
  p_COL18                := JTF_VARCHAR2_TABLE_2000();
  p_COL19                := JTF_VARCHAR2_TABLE_2000();
  p_COL20                := JTF_VARCHAR2_TABLE_2000();
  p_COL21                := JTF_VARCHAR2_TABLE_2000();
  p_COL22                := JTF_VARCHAR2_TABLE_2000();
  p_COL23                := JTF_VARCHAR2_TABLE_2000();
  p_COL24                := JTF_VARCHAR2_TABLE_2000();
  p_COL25                := JTF_VARCHAR2_TABLE_2000();
  p_COL26                := JTF_VARCHAR2_TABLE_2000();
  p_COL27                := JTF_VARCHAR2_TABLE_2000();
  p_COL28                := JTF_VARCHAR2_TABLE_2000();
  p_COL29                := JTF_VARCHAR2_TABLE_2000();
  p_COL30                := JTF_VARCHAR2_TABLE_2000();
  p_COL31                := JTF_VARCHAR2_TABLE_2000();
  p_COL32                := JTF_VARCHAR2_TABLE_2000();
  p_COL33                := JTF_VARCHAR2_TABLE_2000();
  p_COL34                := JTF_VARCHAR2_TABLE_2000();
  p_COL35                := JTF_VARCHAR2_TABLE_2000();
  p_COL36                := JTF_VARCHAR2_TABLE_2000();
  p_COL37                := JTF_VARCHAR2_TABLE_2000();
  p_COL38                := JTF_VARCHAR2_TABLE_2000();
  p_COL39                := JTF_VARCHAR2_TABLE_2000();
  p_COL40                := JTF_VARCHAR2_TABLE_2000();
  p_COL41                := JTF_VARCHAR2_TABLE_2000();
  p_COL42                := JTF_VARCHAR2_TABLE_2000();
  p_COL43                := JTF_VARCHAR2_TABLE_2000();
  p_COL44                := JTF_VARCHAR2_TABLE_2000();
  p_COL45                := JTF_VARCHAR2_TABLE_2000();
  p_COL46                := JTF_VARCHAR2_TABLE_2000();
  p_COL47                := JTF_VARCHAR2_TABLE_2000();
  p_COL48                := JTF_VARCHAR2_TABLE_2000();
  p_COL49                := JTF_VARCHAR2_TABLE_2000();
  p_COL50                := JTF_VARCHAR2_TABLE_2000();
  p_COL51                := JTF_VARCHAR2_TABLE_2000();
  p_COL52                := JTF_VARCHAR2_TABLE_2000();
  p_COL53                := JTF_VARCHAR2_TABLE_2000();
  p_COL54                := JTF_VARCHAR2_TABLE_2000();
  p_COL55                := JTF_VARCHAR2_TABLE_2000();
  p_COL56                := JTF_VARCHAR2_TABLE_2000();
  p_COL57                := JTF_VARCHAR2_TABLE_2000();
  p_COL58                := JTF_VARCHAR2_TABLE_2000();
  p_COL59                := JTF_VARCHAR2_TABLE_2000();
  p_COL60                := JTF_VARCHAR2_TABLE_2000();
  p_COL61                := JTF_VARCHAR2_TABLE_2000();
  p_COL62                := JTF_VARCHAR2_TABLE_2000();
  p_COL63                := JTF_VARCHAR2_TABLE_2000();
  p_COL64                := JTF_VARCHAR2_TABLE_2000();
  p_COL65                := JTF_VARCHAR2_TABLE_2000();
  p_COL66                := JTF_VARCHAR2_TABLE_2000();
  p_COL67                := JTF_VARCHAR2_TABLE_2000();
  p_COL68                := JTF_VARCHAR2_TABLE_2000();
  p_COL69                := JTF_VARCHAR2_TABLE_2000();
  p_COL70                := JTF_VARCHAR2_TABLE_2000();
  p_COL71                := JTF_VARCHAR2_TABLE_2000();
  p_COL72                := JTF_VARCHAR2_TABLE_2000();
  p_COL73                := JTF_VARCHAR2_TABLE_2000();
  p_COL74                := JTF_VARCHAR2_TABLE_2000();
  p_COL75                := JTF_VARCHAR2_TABLE_2000();
  p_COL76                := JTF_VARCHAR2_TABLE_2000();
  p_COL77                := JTF_VARCHAR2_TABLE_2000();
  p_COL78                := JTF_VARCHAR2_TABLE_2000();
  p_COL79                := JTF_VARCHAR2_TABLE_2000();
  p_COL80                := JTF_VARCHAR2_TABLE_2000();
  p_COL81                := JTF_VARCHAR2_TABLE_2000();
  p_COL82                := JTF_VARCHAR2_TABLE_2000();
  p_COL83                := JTF_VARCHAR2_TABLE_2000();
  p_COL84                := JTF_VARCHAR2_TABLE_2000();
  p_COL85                := JTF_VARCHAR2_TABLE_2000();
  p_COL86                := JTF_VARCHAR2_TABLE_2000();
  p_COL87                := JTF_VARCHAR2_TABLE_2000();
  p_COL88                := JTF_VARCHAR2_TABLE_2000();
  p_COL89                := JTF_VARCHAR2_TABLE_2000();
  p_COL90                := JTF_VARCHAR2_TABLE_2000();
  p_COL91                := JTF_VARCHAR2_TABLE_2000();
  p_COL92                := JTF_VARCHAR2_TABLE_2000();
  p_COL93                := JTF_VARCHAR2_TABLE_2000();
  p_COL94                := JTF_VARCHAR2_TABLE_2000();
  p_COL95                := JTF_VARCHAR2_TABLE_2000();
  p_COL96                := JTF_VARCHAR2_TABLE_2000();
  p_COL97                := JTF_VARCHAR2_TABLE_2000();
  p_COL98                := JTF_VARCHAR2_TABLE_2000();
  p_COL99                := JTF_VARCHAR2_TABLE_2000();
  p_COL100               := JTF_VARCHAR2_TABLE_2000();

  l_batch_size := NVL(FND_PROFILE.value('JTF_FM_BATCH_SIZE'),1000);

  FOR i IN 1 ..  l_batch_size
  LOOP
    p_line_ids .extend();
    p_PARTY_ID.extend();
    p_PARTY_NAME.extend();
    p_EMAIL_ADDRESS.extend();
    p_COL1.extend();
    p_COL2.extend();
    p_COL3.extend();
    p_COL4.extend();
    p_COL5.extend();
    p_COL6.extend();
    p_COL7.extend();
    p_COL8.extend();
    p_COL9.extend();
    p_COL10.extend();
    p_COL11.extend();
    p_COL12.extend();
    p_COL13.extend();
    p_COL14.extend();
    p_COL15.extend();
    p_COL16.extend();
    p_COL17.extend();
    p_COL18.extend();
    p_COL19.extend();
    p_COL20.extend();
    p_COL21.extend();
    p_COL22.extend();
    p_COL23.extend();
    p_COL24.extend();
    p_COL25.extend();
    p_COL26.extend();
    p_COL27.extend();
    p_COL28.extend();
    p_COL29.extend();
    p_COL30.extend();
    p_COL31.extend();
    p_COL32.extend();
    p_COL33.extend();
    p_COL34.extend();
    p_COL35.extend();
    p_COL36.extend();
    p_COL37.extend();
    p_COL38.extend();
    p_COL39.extend();
    p_COL40.extend();
    p_COL41.extend();
    p_COL42.extend();
    p_COL43.extend();
    p_COL44.extend();
    p_COL45.extend();
    p_COL46.extend();
    p_COL47.extend();
    p_COL48.extend();
    p_COL49.extend();
    p_COL50.extend();
    p_COL51.extend();
    p_COL52.extend();
    p_COL53.extend();
    p_COL54.extend();
    p_COL55.extend();
    p_COL56.extend();
    p_COL57.extend();
    p_COL58.extend();
    p_COL59.extend();
    p_COL60.extend();
    p_COL61.extend();
    p_COL62.extend();
    p_COL63.extend();
    p_COL64.extend();
    p_COL65.extend();
    p_COL66.extend();
    p_COL67.extend();
    p_COL68.extend();
    p_COL69.extend();
    p_COL70.extend();
    p_COL71.extend();
    p_COL72.extend();
    p_COL73.extend();
    p_COL74.extend();
    p_COL75.extend();
    p_COL76.extend();
    p_COL77.extend();
    p_COL78.extend();
    p_COL79.extend();
    p_COL80.extend();
    p_COL81.extend();
    p_COL82.extend();
    p_COL83.extend();
    p_COL84.extend();
    p_COL85.extend();
    p_COL86.extend();
    p_COL87.extend();
    p_COL88.extend();
    p_COL89.extend();
    p_COL90.extend();
    p_COL91.extend();
    p_COL92.extend();
    p_COL93.extend();
    p_COL94.extend();
    p_COL95.extend();
    p_COL96.extend();
    p_COL97.extend();
    p_COL98.extend();
    p_COL99.extend();
    p_COL100.extend();
  END LOOP;

  OPEN c_batch;
    FETCH c_batch INTO
        l_batch_id   ,
        l_request_line_id_start   ,
        l_request_line_id_end;
  CLOSE c_batch;

  IF l_batch_id IS NOT NULL
  THEN
    UPDATE  jtf_fm_int_request_batches  rb
    SET     rb.batch_status       = 'INPROGRESS' ,
            last_update_date      = SYSDATE,
            rb.SERVER_INSTANCE_ID = p_instance_id
    WHERE   rb.request_id         = p_request_id
    AND     rb.batch_status       = 'AVAILABLE'
    AND     rb.batch_id           = l_batch_id;

    COMMIT;
  END IF;

  SELECT
       rl.REQUEST_LINE_ID,
       rl.PARTY_ID,
       rl.PARTY_NAME,
       rl.EMAIL_ADDRESS,
       rl.COL1,
       rl.COL2,
       rl.COL3,
       rl.COL4,
       rl.COL5,
       rl.COL6,
       rl.COL7,
       rl.COL8,
       rl.COL9,
       rl.COL10,
       rl.COL11,
       rl.COL12,
       rl.COL13,
       rl.COL14,
       rl.COL15,
       rl.COL16,
       rl.COL17,
       rl.COL18,
       rl.COL19,
       rl.COL20,
       rl.COL21,
       rl.COL22,
       rl.COL23,
       rl.COL24,
       rl.COL25,
       rl.COL26,
       rl.COL27,
       rl.COL28,
       rl.COL29,
       rl.COL30,
       rl.COL31,
       rl.COL32,
       rl.COL33,
       rl.COL34,
       rl.COL35,
       rl.COL36,
       rl.COL37,
       rl.COL38,
       rl.COL39,
       rl.COL40,
       rl.COL41,
       rl.COL42,
       rl.COL43,
       rl.COL44,
       rl.COL45,
       rl.COL46,
       rl.COL47,
       rl.COL48,
       rl.COL49,
       rl.COL50,
       rl.COL51,
       rl.COL52,
       rl.COL53,
       rl.COL54,
       rl.COL55,
       rl.COL56,
       rl.COL57,
       rl.COL58,
       rl.COL59,
       rl.COL60,
       rl.COL61,
       rl.COL62,
       rl.COL63,
       rl.COL64,
       rl.COL65,
       rl.COL66,
       rl.COL67,
       rl.COL68,
       rl.COL69,
       rl.COL70,
       rl.COL71,
       rl.COL72,
       rl.COL73,
       rl.COL74,
       rl.COL75,
       rl.COL76,
       rl.COL77,
       rl.COL78,
       rl.COL79,
       rl.COL80,
       rl.COL81,
       rl.COL82,
       rl.COL83,
       rl.COL84,
       rl.COL85,
       rl.COL86,
       rl.COL87,
       rl.COL88,
       rl.COL89,
       rl.COL90,
       rl.COL91,
       rl.COL92,
       rl.COL93,
       rl.COL94,
       rl.COL95,
       rl.COL96,
       rl.COL97,
       rl.COL98,
       rl.COL99,
       rl.COL100
  BULK COLLECT INTO
       p_line_ids,
       p_party_id,
       p_party_name,
       p_email_address,
       p_COL1,
       p_COL2,
       p_COL3,
       p_COL4,
       p_COL5,
       p_COL6,
       p_COL7,
       p_COL8,
       p_COL9,
       p_COL10,
       p_COL11,
       p_COL12,
       p_COL13,
       p_COL14,
       p_COL15,
       p_COL16,
       p_COL17,
       p_COL18,
       p_COL19,
       p_COL20,
       p_COL21,
       p_COL22,
       p_COL23,
       p_COL24,
       p_COL25,
       p_COL26,
       p_COL27,
       p_COL28,
       p_COL29,
       p_COL30,
       p_COL31,
       p_COL32,
       p_COL33,
       p_COL34,
       p_COL35,
       p_COL36,
       p_COL37,
       p_COL38,
       p_COL39,
       p_COL40,
       p_COL41,
       p_COL42,
       p_COL43,
       p_COL44,
       p_COL45,
       p_COL46,
       p_COL47,
       p_COL48,
       p_COL49,
       p_COL50,
       p_COL51,
       p_COL52,
       p_COL53,
       p_COL54,
       p_COL55,
       p_COL56,
       p_COL57,
       p_COL58,
       p_COL59,
       p_COL60,
       p_COL61,
       p_COL62,
       p_COL63,
       p_COL64,
       p_COL65,
       p_COL66,
       p_COL67,
       p_COL68,
       p_COL69,
       p_COL70,
       p_COL71,
       p_COL72,
       p_COL73,
       p_COL74,
       p_COL75,
       p_COL76,
       p_COL77,
       p_COL78,
       p_COL79,
       p_COL80,
       p_COL81,
       p_COL82,
       p_COL83,
       p_COL84,
       p_COL85,
       p_COL86,
       p_COL87,
       p_COL88,
       p_COL89,
       p_COL90,
       p_COL91,
       p_COL92,
       p_COL93,
       p_COL94,
       p_COL95,
       p_COL96,
       p_COL97,
       p_COL98,
       p_COL99,
       p_COL100
  FROM  jtf_fm_int_request_lines rl
  WHERE rl.request_id = p_request_id
  AND   rl.request_line_id BETWEEN l_request_line_id_start AND l_request_line_id_end  ;

  x_no_of_rows   := SQL%ROWCOUNT;


  COMMIT;

  x_return_status := 'S';

  FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
      x_return_status := FND_API.g_ret_sts_error ;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded     =>      FND_API.G_FALSE
          );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
          );
  WHEN OTHERS
  THEN
     x_return_status := FND_API.g_ret_sts_unexp_erroR ;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        NULL;
      END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );
END get_next_batch;


/*---------------------------------------------------------------------------------*
 | Procedure Name : MOVE_REQUEST                                                   |
 |                                                                                 |
 | Purpose        : Selects from jtf_fm_int_request_lines , and                    |
 |                  - Inserts into jtf_fm_processed table                          |
 |                  - Inserts into jtf_fm_content_failures table                   |
 |                  - Drops partition for jtf_fm_int_request_lines                 |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE  move_request( p_request_id                    NUMBER
                       , x_log_interaction    OUT NOCOPY VARCHAR2
                       , x_return_status      OUT NOCOPY VARCHAR2
                       , x_msg_count          OUT NOCOPY NUMBER
                       , x_msg_data           OUT NOCOPY VARCHAR2
                       ) IS
CURSOR c_history IS
          SELECT USER_HISTORY
          FROM   jtf_fm_int_request_header
          WHERE  request_id = p_request_id ;
l_errbuf     VARCHAR2(32767);
l_retcode    VARCHAR2(1);
BEGIN
  OPEN c_history;
    FETCH c_history INTO x_log_interaction;
  CLOSE c_history;

  INSERT INTO jtf_fm_processed
  (
    request_id         ,
    job                ,
    party_id           ,
    party_name         ,
    email_address      ,
    outcome_code       ,
    created_by         ,
    creation_date      ,
    last_updated_by    ,
    last_update_date   ,
    last_update_login  ,
    email_status       ,
    col1               ,
    col2               ,
    col3               ,
    col4               ,
    col5               ,
    col6               ,
    col7               ,
    col8               ,
    col9               ,
    col10              ,
    col11              ,
    col12              ,
    col13              ,
    col14              ,
    col15              ,
    col16              ,
    col17              ,
    col18              ,
    col19              ,
    col20              ,
    col21              ,
    col22              ,
    col23              ,
    col24              ,
    col25              ,
    col26              ,
    col27              ,
    col28              ,
    col29              ,
    col30              ,
    col31              ,
    col32              ,
    col33              ,
    col34              ,
    col35              ,
    col36              ,
    col37              ,
    col38              ,
    col39              ,
    col40              ,
    col41              ,
    col42              ,
    col43              ,
    col44              ,
    col45              ,
    col46              ,
    col47              ,
    col48              ,
    col49              ,
    col50              ,
    col51              ,
    col52              ,
    col53              ,
    col54              ,
    col55              ,
    col56              ,
    col57              ,
    col58              ,
    col59              ,
    col60              ,
    col61              ,
    col62              ,
    col63              ,
    col64              ,
    col65              ,
    col66              ,
    col67              ,
    col68              ,
    col69              ,
    col70              ,
    col71              ,
    col72              ,
    col73              ,
    col74              ,
    col75              ,
    col76              ,
    col77              ,
    col78              ,
    col79              ,
    col80              ,
    col81              ,
    col82              ,
    col83              ,
    col84              ,
    col85              ,
    col86              ,
    col87              ,
    col88              ,
    col89              ,
    col90              ,
    col91              ,
    col92              ,
    col93              ,
    col94              ,
    col95              ,
    col96              ,
    col97              ,
    col98              ,
    col99              ,
    col100             ,
    partition_id       )
  SELECT
    p_request_id,
    rl.request_line_id,
    rl.party_id             ,
    rl.party_name           ,
    rl.email_address        ,
    DECODE(enabled_flag, 'N','FAILURE',
                         DECODE(email_status,'NOTDELIVERED','FAILURE','SUCCESS')),
    1,
    SYSDATE,
    1,
    SYSDATE,
    1,
    DECODE(enabled_flag, 'N','NOT_SENT',
                         DECODE(email_status,'NOTDELIVERED','NOT_SENT','SENT')),
    rl.col1                 ,
    rl.col2                 ,
    rl.col3                 ,
    rl.col4                 ,
    rl.col5                 ,
    rl.col6                 ,
    rl.col7                 ,
    rl.col8                 ,
    rl.col9                 ,
    rl.col10                ,
    rl.col11                ,
    rl.col12                ,
    rl.col13                ,
    rl.col14                ,
    rl.col15                ,
    rl.col16                ,
    rl.col17                ,
    rl.col18                ,
    rl.col19                ,
    rl.col20                ,
    rl.col21                ,
    rl.col22                ,
    rl.col23                ,
    rl.col24                ,
    rl.col25                ,
    rl.col26                ,
    rl.col27                ,
    rl.col28                ,
    rl.col29                ,
    rl.col30                ,
    rl.col31                ,
    rl.col32                ,
    rl.col33                ,
    rl.col34                ,
    rl.col35                ,
    rl.col36                ,
    rl.col37                ,
    rl.col38                ,
    rl.col39                ,
    rl.col40                ,
    rl.col41                ,
    rl.col42                ,
    rl.col43                ,
    rl.col44                ,
    rl.col45                ,
    rl.col46                ,
    rl.col47                ,
    rl.col48                ,
    rl.col49                ,
    rl.col50                ,
    rl.col51                ,
    rl.col52                ,
    rl.col53                ,
    rl.col54                ,
    rl.col55                ,
    rl.col56                ,
    rl.col57                ,
    rl.col58                ,
    rl.col59                ,
    rl.col60                ,
    rl.col61                ,
    rl.col62                ,
    rl.col63                ,
    rl.col64                ,
    rl.col65                ,
    rl.col66                ,
    rl.col67                ,
    rl.col68                ,
    rl.col69                ,
    rl.col70                ,
    rl.col71                ,
    rl.col72                ,
    rl.col73                ,
    rl.col74                ,
    rl.col75                ,
    rl.col76                ,
    rl.col77                ,
    rl.col78                ,
    rl.col79                ,
    rl.col80                ,
    rl.col81                ,
    rl.col82                ,
    rl.col83                ,
    rl.col84                ,
    rl.col85                ,
    rl.col86                ,
    rl.col87                ,
    rl.col88                ,
    rl.col89                ,
    rl.col90                ,
    rl.col91                ,
    rl.col92                ,
    rl.col93                ,
    rl.col94                ,
    rl.col95                ,
    rl.col96                ,
    rl.col97                ,
    rl.col98                ,
    rl.col99                ,
    rl.col100               ,
    rl.partition_id
  FROM  jtf_fm_int_request_lines rl
  WHERE rl.request_id = p_request_id;

  COMMIT;

  INSERT INTO jtf_fm_content_failures
  (
    request_id,
    content_number,
    job,
    media_type,
    address,
    failure,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
  )
  SELECT
    p_request_id,
    0,
    rl.request_line_id,
    'EMAIL',
    rl.email_address,
    DECODE(rl.enabled_flag, 'N',DECODE (rl.contact_preference_flag,
                                               'N','DO_NOT_CONTACT',
                                               'MALFORMED'),'FAILURE'),
    1,
    SYSDATE,
    1,
    SYSDATE,
    1
  FROM  jtf_fm_int_request_lines rl
  WHERE rl.request_id = p_request_id
  AND  (rl.enabled_flag = 'N'
  OR    rl.email_status = 'NOTDELIVERED' );

  COMMIT;

  unlock_partition ( x_errbuf         => l_errbuf
                   , x_retcode        => l_retcode
                   , p_request_id     => p_request_id
                   );


  x_return_status := 'S';
  x_msg_count     := 0;
  x_msg_data      := '';
END  move_request;

/*---------------------------------------------------------------------------------*
 | Procedure Name : CLEAN_STALLED_REQUEST                                          |
 |                                                                                 |
 | Purpose        : Selects from jtf_fm_int_request_lines , and                    |
 |                  - Truncates partition for jtf_fm_int_request_lines             |
 |                  - Deletes from jtf_fm_int_request_batches                      |
 |                  - Deletes from jtf_fm_int_request_header                       |
 |                                                                                 |
 *---------------------------------------------------------------------------------*/
PROCEDURE clean_stalled_request ( p_request_id    IN         NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2
                                ) IS
l_lines_count             NUMBER;
lc_status      CONSTANT   VARCHAR2(10) := 'AVAILABLE';
l_partition_name          VARCHAR2(50);
BEGIN
  --Getting the count from lines
  SELECT COUNT(ROWID)
  INTO   l_lines_count
  FROM   jtf_fm_int_request_lines
  WHERE  request_id   = p_request_id
  AND    email_status = lc_status
  ;

  --Check to see if record exist
  IF (l_lines_count > 0)
  THEN
   SELECT partition_name
   INTO   l_partition_name
   FROM   jtf_fm_partition_x_request
   WHERE  request_id = p_request_id;

   EXECUTE IMMEDIATE 'ALTER TABLE jtf_fm_int_request_lines TRUNCATE PARTITION '|| l_partition_name;
  END IF;

  --Deleting from batches table
  DELETE
  FROM   jtf_fm_int_request_batches
  WHERE  request_id   = p_request_id
  AND    batch_status = lc_status
  ;

  --Deleting from header table
  DELETE
  FROM   jtf_fm_int_request_header
  WHERE  request_id     = p_request_id
  ;

  COMMIT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS
 THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END clean_stalled_request;

PROCEDURE get_next_partition ( x_errbuf        OUT NOCOPY VARCHAR2
                             , x_retcode       OUT NOCOPY VARCHAR2
                             , p_request_id    IN         NUMBER
                             , x_partition_id  OUT NOCOPY NUMBER) IS
l_partition_id            NUMBER;
l_request_id              NUMBER;
l_errbuf                  VARCHAR2(32767);
l_retcode                 VARCHAR2(1);
e_partition_not_found     EXCEPTION;
--Move_Request API
l_log_interaction         VARCHAR2(100);
l_return_status           VARCHAR2(100);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(100);
CURSOR c_partition IS
       SELECT partition_id
       FROM   jtf_fm_partition_x_request
       WHERE  partition_id = ( SELECT MIN(partition_id)
                               FROM   jtf_fm_partition_x_request
                               WHERE  request_id IS NULL
                             )
       FOR UPDATE;
BEGIN
  OPEN c_partition;
    FETCH c_partition INTO l_partition_id;
  CLOSE c_partition;

  IF ( l_partition_id IS NOT NULL)
  THEN
    lock_partition ( x_errbuf         => l_errbuf
                   , x_retcode        => l_retcode
                   , p_request_id     => p_request_id
                   , p_partition_id   => l_partition_id
                   );
  ELSIF ( l_partition_id IS NULL)
  THEN
    SELECT partition_id, request_id
    INTO   l_partition_id, l_request_id
    FROM   ( SELECT part.partition_id, part.request_id
             FROM   jtf_fm_partition_x_request part, jtf_fm_request_history_all history
             WHERE  part.request_id IS NOT NULL
             AND    part.request_id = history.hist_req_id
             AND    history.outcome_code NOT IN ('IN_PROGRESS', 'PAUSED')
             ORDER BY request_id ASC )
    WHERE ROWNUM < 2
    ;

    move_request ( p_request_id         => l_request_id
                 , x_log_interaction    => l_log_interaction
                 , x_return_status      => l_return_status
                 , x_msg_count          => l_msg_count
                 , x_msg_data           => l_msg_data
                 );

    lock_partition ( x_errbuf         => l_errbuf
                   , x_retcode        => l_retcode
                   , p_request_id     => p_request_id
                   , p_partition_id   => l_partition_id
                   );
  END IF;

  IF ( l_retcode = 'S')
  THEN
    x_partition_id := l_partition_id ;
    x_retcode      := 'S';
  ELSE
    RAISE e_partition_not_found;
  END IF;

EXCEPTION
  WHEN e_partition_not_found
  THEN
    x_errbuf  := SQLERRM;
    x_retcode := FND_API.g_ret_sts_unexp_error ;
  WHEN OTHERS
  THEN
    x_errbuf  := SQLERRM;
    x_retcode := FND_API.g_ret_sts_unexp_error ;
END get_next_partition;

PROCEDURE lock_partition ( x_errbuf         OUT NOCOPY  VARCHAR2
                         , x_retcode        OUT NOCOPY  VARCHAR2
                         , p_request_id     IN          NUMBER
                         , p_partition_id   IN          NUMBER
                         ) IS
BEGIN
  UPDATE jtf_fm_partition_x_request
  SET    request_id   = p_request_id
  WHERE  partition_id = p_partition_id
  AND    request_id IS NULL
  ;

  COMMIT;

  x_retcode := 'S';

EXCEPTION
  WHEN OTHERS
  THEN
    x_errbuf  := SQLERRM;
    x_retcode := FND_API.g_ret_sts_unexp_error ;
END lock_partition;


PROCEDURE unlock_partition ( x_errbuf         OUT NOCOPY  VARCHAR2
                           , x_retcode        OUT NOCOPY  VARCHAR2
                           , p_request_id     IN          NUMBER
                          ) IS
l_partition_name   jtf_fm_partition_x_request.partition_name%TYPE;
BEGIN
  UPDATE jtf_fm_partition_x_request
  SET    request_id   = NULL
  WHERE  request_id   = p_request_id
  RETURNING partition_name INTO l_partition_name
  ;

  EXECUTE IMMEDIATE 'ALTER TABLE jtf_fm_int_request_lines TRUNCATE PARTITION '|| l_partition_name;

  x_retcode := 'S';

EXCEPTION
  WHEN OTHERS
  THEN
    x_errbuf  := SQLERRM;
    x_retcode := FND_API.g_ret_sts_unexp_error ;
END unlock_partition;


END JTF_FM_INT_REQUEST_PKG;

/
