--------------------------------------------------------
--  DDL for Package Body HZ_BES_BO_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BES_BO_GEN_PKG" AS
/*$Header: ARHBESGB.pls 120.5 2006/06/28 07:11:20 smattegu noship $ */

--
-- Purpose:
--  To generate the Site specific package (HZ_BES_BO_SITE_UTIL_PKG) body
--    that satifies the need to check the completeness and event type
--    of the business object.
-- Note:
--  As the Completeness and Event Type checks are needed for only the
--  for PERSON, ORGANIZATION, PERSON CUSTOMER and ORGANIZATION CUSTOMER
--  business objects, any reference to BOs or All BOs implies, only the
--  above four business objects.
--

  -- declaration of private global varibles
  --------------------------------------
g_indent CONSTANT VARCHAR2(2) := '  ';

G_PER_BO_CODE       CONSTANT VARCHAR2(20):= HZ_BES_BO_RAISE_PKG.G_PER_BO_CODE;
G_ORG_BO_CODE       CONSTANT VARCHAR2(20):= HZ_BES_BO_RAISE_PKG.G_ORG_BO_CODE;
G_PER_CUST_BO_CODE  CONSTANT VARCHAR2(20):= HZ_BES_BO_RAISE_PKG.G_PER_CUST_BO_CODE;
G_ORG_CUST_BO_CODE  CONSTANT VARCHAR2(20):= HZ_BES_BO_RAISE_PKG.G_ORG_CUST_BO_CODE;

  --------------------------------------
  -- forward referencing of private procedures
/*
*/

/*
 **************************************************************************
 helper procedures and functions that facilitate in generating a plsql pkg
 **************************************************************************
*/
----------------------------------------------
/**
* Procedure to write a message to the out file
**/
----------------------------------------------
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;
----------------------------------------------
----------------------------------------------
/**
* Procedure to write text to the log file
**/
----------------------------------------------
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
   l_prefix VARCHAR2(20) := 'BES_BO_RAISE';
BEGIN
/*
	FND_FILE.LOG = 1 - means log file
	FND_FILE.LOG = 2 - means out file
*/
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.DEBUG (
				p_message=>message,
		    p_prefix=>l_prefix,
	    	p_msg_level=>fnd_log.level_procedure);
	END IF ;

  IF newline THEN
    FND_FILE.put_line(FND_FILE.LOG,message);
     FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSE
    FND_FILE.put_line(FND_FILE.LOG,message);
  END IF;
END log;
----------------------------------------------
/**
* Procedure to write a message to the out and log files
**/
----------------------------------------------
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message, newline);
END outandlog;

----------------------------------------------
/**
* procedure to fetch messages of the stack and log the error

----------------------------------------------

PROCEDURE logerr IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;
  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;
 -- FND_MSG_PUB.Delete_Msg;
END logerr;
**/
----------------------------------------------
/**
* Function to fetch messages of the stack and log the error
* Also returns the error
**/
----------------------------------------------
FUNCTION logerror RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || ' ' || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

----------------------------------------------
/*
  this procedure takes a message_name and enters into the message stack
  and writes into the log file also.
*/
----------------------------------------------

PROCEDURE mesglog(
   p_message      IN      VARCHAR2,
   p_tkn1_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn1_val     IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_val     IN      VARCHAR2 DEFAULT NULL
   ) IS
BEGIN
  FND_MESSAGE.SET_NAME('AR', p_message);
  IF (p_tkn1_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn1_name, p_tkn1_val);
  END IF;
  IF (p_tkn2_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn2_name, p_tkn2_val);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;

END mesglog;

----------------------------------------------
/*
  this procedure takes a message_name and enters into the message stack
  and writes into the out file also.
*/
----------------------------------------------

PROCEDURE mesgout(
   p_message      IN      VARCHAR2,
   p_tkn1_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn1_val     IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_val     IN      VARCHAR2 DEFAULT NULL
   ) IS
BEGIN
  FND_MESSAGE.SET_NAME('AR', p_message);
  IF (p_tkn1_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn1_name, p_tkn1_val);
  END IF;
  IF (p_tkn2_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn2_name, p_tkn2_val);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;

END mesgout;

----------------------------------------------
/*
  this procedure takes a message_name and enters into the message stack
  and writes into the out and log file also.
*/
----------------------------------------------

PROCEDURE mesgoutlog(
   p_message      IN      VARCHAR2,
   p_tkn1_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn1_val     IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_val     IN      VARCHAR2 DEFAULT NULL
   ) IS
BEGIN
  FND_MESSAGE.SET_NAME('AR', p_message);
  IF (p_tkn1_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn1_name, p_tkn1_val);
  END IF;
  IF (p_tkn2_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn2_name, p_tkn2_val);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    outandlog(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;

END mesgoutlog;
---------------------------------------------------------------------

  --------------------------------------
  -- This would write a line in the buffer.
  -- This would also introduce a new line char at the end of line.
  PROCEDURE l(
    str IN     VARCHAR2
  ) IS
  BEGIN
    HZ_GEN_PLSQL.add_line(str);
  END l;
  --------------------------------------
  -- This would write a line preceeded by an indent and line ends with
  -- a new line char.
  PROCEDURE li(
    str IN     VARCHAR2
  ) IS
  BEGIN
    HZ_GEN_PLSQL.add_line(g_indent||str);
  END li;
  --------------------------------------
  -- This would write a line preceeded by two indentations and line ends with
  -- a new line char.
  PROCEDURE l2i(
    str IN     VARCHAR2
  ) IS
  BEGIN
    HZ_GEN_PLSQL.add_line(g_indent||g_indent||str);
  END l2i;
  --------------------------------------

  -- This would write the line in the buffer WITHOUT NEW LINE CHAR at
  -- the end of line.
  PROCEDURE ll(
    str IN     VARCHAR2
  ) IS
  BEGIN
    HZ_GEN_PLSQL.add_line(str, false);
  END ll;
  --------------------------------------
  -- This would write a line by preceeding with an indent and NO NEW LINE char
  -- at the end.
  PROCEDURE lli(
    str IN     VARCHAR2
  ) IS
  BEGIN
      HZ_GEN_PLSQL.add_line(g_indent||str, false);
  END lli;
  --------------------------------------
  -- This would write a line by preceeding with two indentations
  -- and NO NEW LINE char at the end.
  PROCEDURE ll2i(
    str IN     VARCHAR2
  ) IS
  BEGIN
      HZ_GEN_PLSQL.add_line(g_indent||g_indent||str, false);
  END ll2i;

/*
	 Procedure name: genPkgBdyHdr()
	 Scope: Internal
	 Purpose: This procedure writes the pckage header for
	          HZ_BES_BO_SITE_UTIL_PKG package body.
	 Called From: This package
	 Called By: genPkgBdyHdr()
	 Paramaters - brief desc of each parameter:
	  In:
	  Out:
	  In-Out:
*/

  PROCEDURE genPkgBdyHdr (
	  p_package_name IN VARCHAR2
  ) IS
    l_prefix    VARCHAR2(15) := 'GENPKGHDR:';
		l_schema_name VARCHAR2(30);
		l_tmp NUMBER;

	BEGIN -- gen_pkg_body
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.DEBUG (
				p_message=>'genPkgBdyHdr()+',
		    p_prefix=>l_prefix,
	    	p_msg_level=>fnd_log.level_procedure);
	  END IF ;
	  -- for any reason if the
    -- new a package body object package body exists and is invalid, the create or replace is not working.
    -- then we may have to do the following:

	  BEGIN
            -- get the schema name that owns the pkg bdy
	    SELECT ORACLE_USERNAME
	    INTO l_schema_name
	    FROM FND_ORACLE_USERID WHERE
	    READ_ONLY_FLAG = 'U';

            -- get the schema name that owns the pkg bdy

	    SELECT 1
	    INTO l_tmp
	    FROM ALL_PLSQL_OBJECT_SETTINGS
	    WHERE NAME = 'HZ_BES_BO_SITE_UTIL_PKG'
	    AND TYPE = 'PACKAGE BODY' AND OWNER = l_schema_name ;

	    IF l_tmp = 1 THEN
		execute immediate 'DROP PACKAGE BODY HZ_BES_BO_SITE_UTIL_PKG';
	    END IF;
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.DEBUG (
		p_message=>'pkg body does not exist.',
		p_prefix=>l_prefix,
		p_msg_level=>fnd_log.level_procedure);
	      END IF ;
	    WHEN OTHERS THEN
	     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.DEBUG (
		p_message=>sqlerrm,
		p_prefix=>l_prefix,
		p_msg_level=>fnd_log.level_procedure);
	     END IF ;
	END;
    HZ_GEN_PLSQL.new(p_package_name, 'PACKAGE BODY');
    l('CREATE OR REPLACE PACKAGE BODY '||p_package_name||' AS');
    l('');
    l('/*=======================================================================+');
    l(' |  Copyright (c) 2006 Oracle Corporation Redwood Shores, California, USA|');
    l(' |                          All rights reserved.                         |');
    l(' +=======================================================================+');
    l(' | NAME '||p_package_name);
    l(' |');
    l(' | DESCRIPTION');
    l(' |   This package body is generated by HZ_BES_GEN_PKG. ');
    l(' |   This package contains site specific completeness check and event type ');
    l(' |    check for PERSON, ORG, PERSON CUSTOMER and ORG CUSTOMER Business objects');
    l(' |');
    l(' | HISTORY');
    l(' |  '||TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS')||'      Generated.');
    l(' |');
    l(' *=======================================================================*/');
    l(' ');

	  if fnd_log.level_procedure>=fnd_log.g_current_runtime_level then
		hz_utility_v2pub.debug(p_message=>'genPkgBdyHdr()-',
		                       p_prefix=>l_prefix,
	    			               p_msg_level=>fnd_log.level_procedure);
	  end if;

  END genPkgBdyHdr;
  --------------------------------------
    PROCEDURE genPkgHdr (
	  p_package_name IN VARCHAR2
  ) IS
    l_prefix    VARCHAR2(15) := 'GENPKGHDR:';
		l_schema_name VARCHAR2(30);
		l_tmp NUMBER;

	BEGIN -- gen_pkg_hdr
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.DEBUG (
				p_message=>'genPkgHdr()+',
		    p_prefix=>l_prefix,
	    	p_msg_level=>fnd_log.level_procedure);
	  END IF ;

    HZ_GEN_PLSQL.new(p_package_name, 'PACKAGE');
    l('CREATE OR REPLACE PACKAGE '||p_package_name||' AS');
    l('');
    l('/*=======================================================================+');
    l(' |  Copyright (c) 2006 Oracle Corporation Redwood Shores, California, USA|');
    l(' |                          All rights reserved.                         |');
    l(' +=======================================================================+');
    l(' | NAME '||p_package_name);
    l(' |');
    l(' | DESCRIPTION');
    l(' |   This package is generated by HZ_BES_GEN_PKG. ');
    l(' |');
    l(' | HISTORY');
    l(' |  '||TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS')||'      Generated.');
    l(' |');
    l(' *=======================================================================*/');
    l(' ');

	  if fnd_log.level_procedure>=fnd_log.g_current_runtime_level then
		hz_utility_v2pub.debug(p_message=>'genPkgHdr()-',
		                       p_prefix=>l_prefix,
	    			               p_msg_level=>fnd_log.level_procedure);
	  end if;

  END genPkgHdr;
  --------------------------------------

/*
	 Procedure name: genPkgBdyTail()
	 Scope: Internal
	 Purpose: This procedure writes the end section for
	          HZ_BES_BO_SITE_UTIL_PKG package body.
	 Called From: This package
	 Called By: genPkgBdyTail()
	 Paramaters - brief desc of each parameter:
	  In: p_package_name
	  Out:
	  In-Out:
*/

  --------------------------------------
  PROCEDURE genPkgBdyTail (
      p_package_name   IN     VARCHAR2
  ) IS
      l_debug_prefix    VARCHAR2(15) := 'PKGTAIL:';
  BEGIN

	  if fnd_log.level_procedure>=fnd_log.g_current_runtime_level then
		hz_utility_v2pub.debug(p_message=>'genPkgBdyTail()+',
		                       p_prefix=>l_debug_prefix,
	    			               p_msg_level=>fnd_log.level_procedure);
	  end if;


    l('END '||p_package_name||';');
    -- compile the package.
    HZ_GEN_PLSQL.compile_code;

	  if fnd_log.level_procedure>=fnd_log.g_current_runtime_level then
		hz_utility_v2pub.debug(p_message=>'genPkgBdyTail()-',
		                       p_prefix=>l_debug_prefix,
	    			               p_msg_level=>fnd_log.level_procedure);
	  end if;


  END genPkgBdyTail;
  --------------------------------------

/*
	purpose of procBegin() is to generate the procedure begin section.
*/
	--------------------------------------
  PROCEDURE procBegin (
      p_procName IN     VARCHAR2,
      p_comment  IN     VARCHAR2
  ) IS
  BEGIN
    li('--------------------------------------');
    li('/**');
    li(' * PROCEDURE '||p_procName);
    li(' *');
    li(' * DESCRIPTION');
    li(' *     '||p_comment);
    li(' *');
    li(' */');
    l(' ');
    li('PROCEDURE '||p_procName||' IS');
  END procBegin;
  --------------------------------------

/*
	purpose of procBegin() is to generate the procedure begin section.
*/
	--------------------------------------
  PROCEDURE procBegin (
      p_procName IN     VARCHAR2,
      p_comment  IN     VARCHAR2,
      p_param1_name IN VARCHAR2
  ) IS
  BEGIN
    li('--------------------------------------');
    li('/**');
    li(' * PROCEDURE '||p_procName);
    li(' *');
    li(' * DESCRIPTION');
    li(' *     '||p_comment);
    li(' *');
    li(' */');
    l(' ');
    li('PROCEDURE '||p_procName||' (');
    lli(p_param1_name||' IN VARCHAR2');
--    lli(p_param2_name);
    lli(' ) IS');
  END procBegin;
  --------------------------------------
/*
	purpose of procEnd() to generate the procedure end section.
*/
  --------------------------------------
  PROCEDURE procEnd (
    p_procName IN     VARCHAR2
  ) IS
  BEGIN
    l(' ');
    li('END '||p_procName||';');
  END procEnd;
  --------------------------------------
/*
	purpose of writeDebugMesg() is to generate the debug messages if-end if section
*/

  --------------------------------------
  PROCEDURE 	writeDebugMesg(
	  p_msg IN     VARCHAR2,
		p_prefix IN     VARCHAR2) IS
  BEGIN
    l(' ');
	  l2i('IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN');
    l(' ');
		l2i('		HZ_UTILITY_V2PUB.DEBUG(');
		l2i('			p_message=>'''||p_msg||''',');
		l2i('			p_prefix=>'''||p_prefix||''',');
		l2i('			p_msg_level=>fnd_log.level_procedure);');
		l2i('END IF;');
    l(' ');
  END writeDebugMesg;
  --------------------------------------


/*
 **************************************************************************
 functional procedures and functions that are needed
 **************************************************************************
*/
---------------------------------------------------------------------------
/*
Procedure Name: genBOSQL
Purpose: This procedure generates the SQL needed to check the
Completeness of the business object and writes to the buffer.
This SQL thus generated will be teh cursor for actual completeness check procedure.
  Flow for generating the SQL:
  . Select all the user mandated node for a given BO
  . Write the procedure body until cursor definition
  . Write the root node SQL
  . For all the child nodes
       . Figure out the number or right paranthesis for the parent and write them
       . Write AND EXISTS
       . Identify the exact SQL for the current node and write it.
  . Write the necessary right paranthesis remaining
  . Complete the sql stmt with ;

*/
PROCEDURE genBOSQL
     ( P_BO_CODE IN VARCHAR2,
 			 P_SQL_FOR IN VARCHAR2, -- conveys if the sql is for completeness check or to figure out the event type.
       P_STATUS OUT NOCOPY BOOLEAN)
IS
-- cursor to get the user mandated hierarchy for a given BO
-- This cursor result set is used to identify the nodes in the order so
-- that the SQL can be generated.
CURSOR c_bo (c_p_bo_code IN VARCHAR2) IS
 SELECT
--   ROWNUM,
   lvl, bo_code, root_node_flag rnf, ENTITY_NAME,
  DECODE(lvl,1,
    DECODE(entity_name,'HZ_PARTIES',NULL,SUBSTRB(node_path,2,LENGTH(node_path))),
    SUBSTRB(node_path, INSTR(node_path,'/', -1, 2)+1,
      (INSTR(node_path,'/', -1, 1)-INSTR(node_path,'/', -1, 2)-1))) parent_node
 FROM
  (SELECT
    sys_connect_by_path(BUSINESS_OBJECT_CODE, '/') node_path,
    LEVEL lvl, CONNECT_BY_ISLEAF isleaf,
    BUSINESS_OBJECT_CODE bo_code, CHILD_BO_CODE,ENTITY_NAME, root_node_flag
   FROM hz_bus_obj_definitions
   START WITH BUSINESS_OBJECT_CODE = c_p_bo_code AND
              user_mandated_flag = 'Y'
   CONNECT BY PRIOR CHILD_BO_CODE  =  BUSINESS_OBJECT_CODE AND
                    user_mandated_flag = 'Y'
   ORDER BY LEVEL ASC)
 WHERE isleaf = 1
 ORDER BY node_path ASC, rnf desc;

  -- local variables
/*
  l_rownum          NUMBER_COLUMN;
  l_lvl             NUMBER_COLUMN;
  l_bo_code         BO_CODE;
  l_entity_name     ENTITY_NAME;
  l_parent_node     BO_CODE;
  l_rnf             root_node_flag;
*/
  l_debug_prefix    VARCHAR2(30) := 'GENSQL:';
  l_ex              VARCHAR2(14) := ' AND EXISTS ';
  l_rp              VARCHAR2(3)  := ' ) ';
  l_node_tbl        NODE_TBL_TYPE;
  l_node_count      NUMBER;
  l_rp_tbl          RP_TBL_TYPE;
  l_rpc             NUMBER := 0;
  l_rp_ct           NUMBER := 0;
  l_var             NUMBER := 0;
  l_gpvar           VARCHAR2(80);
  l_chk_node        NUMBER;

BEGIN

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'GENBOSQL()+',
	                       p_prefix=>l_debug_prefix,
  			               p_msg_level=>fnd_log.level_procedure);
  END IF;
  -- set the retun status to false. If the SQL generation is successfull, this
  -- will set to TRUE
  P_STATUS := FALSE;
  OPEN c_bo(p_bo_code);
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.debug(
        p_message=>'cursor opened',
        p_prefix=>l_debug_prefix,
        p_msg_level=>fnd_log.level_procedure);
  END IF;
  -- read the entire hierarchy of the BO into a collection
  FETCH c_bo  BULK COLLECT INTO l_node_tbl;
  CLOSE c_bo;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.debug(
        p_message=>'bulk collected and cursor closed',
        p_prefix=>l_debug_prefix,
        p_msg_level=>fnd_log.level_procedure);
  END IF;
  l_node_count := l_node_tbl.COUNT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.debug(
        p_message=>'number of nodes in the tree are:'||l_node_count,
        p_prefix=>l_debug_prefix,
        p_msg_level=>fnd_log.level_procedure);
  END IF;
  FOR i IN l_node_tbl.FIRST..l_node_tbl.LAST
  LOOP
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
       hz_utility_v2pub.debug(
        p_message=>'--node '||i||':BO:'||l_node_tbl(i).bo_code||':ent:'||l_node_tbl(i).entity_name||':parent:'||l_node_tbl(i).parent_bo_code,
        p_prefix=>l_debug_prefix,
        p_msg_level=>fnd_log.level_procedure);
    END IF;
  END LOOP;

  -- for the level 1 node, write the SQL statement to buffer.
  -- For all the BOs with entity name as HZ_PARTIES at level 1 would be the root node.

  CASE l_node_tbl(1).BO_CODE
  WHEN 'PERSON' THEN
    IF (P_SQL_FOR = 'EVENT') THEN
  	  li(G_EVT_RT_NODE_0||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_1);
  	  li(G_EVT_RT_NODE_2||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_3||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_4);
    ELSE
      li(G_RT_NODE_1_PO||''''||l_node_tbl(1).BO_CODE||'''');
      li(G_RT_NODE_2_PO||'''PERSON_CUST''');
      li(G_RT_NODE_3_PO||''''||l_node_tbl(1).BO_CODE||'''');
      li(G_RT_NODE_4_PO);
      li(G_RT_NODE_2);
  	  li(G_RT_NODE_BOCODE||''''||l_node_tbl(1).BO_CODE||'''');
    /*
  	  li(G_RT_NODE_1);
  	  li(G_RT_NODE_BOCODE2||''''||l_node_tbl(1).BO_CODE||''',''PERSON_CUST'')');
  	  li(G_RT_NODE_2);
  	  li(G_RT_NODE_BOCODE||''''||l_node_tbl(1).BO_CODE||'''');
*/
  	END IF;
  WHEN 'ORG' THEN
    IF (P_SQL_FOR = 'EVENT') THEN
  	  li(G_EVT_RT_NODE_0||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_1);
  	  li(G_EVT_RT_NODE_2||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_3||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_4);
    ELSE
      li(G_RT_NODE_1_PO||''''||l_node_tbl(1).BO_CODE||'''');
      li(G_RT_NODE_2_PO||'''ORG_CUST''');
      li(G_RT_NODE_3_PO||''''||l_node_tbl(1).BO_CODE||'''');
      li(G_RT_NODE_4_PO);
      li(G_RT_NODE_2);
  	  li(G_RT_NODE_BOCODE||''''||l_node_tbl(1).BO_CODE||'''');

/*
  	  li(G_RT_NODE_1);
  	  li(G_RT_NODE_BOCODE2||''''||l_node_tbl(1).BO_CODE||''',''ORG_CUST'')');
  	  li(G_RT_NODE_2);
  	  li(G_RT_NODE_BOCODE||''''||l_node_tbl(1).BO_CODE||'''');
*/
  	END IF;
  WHEN 'PERSON_CUST' THEN
    IF (P_SQL_FOR = 'EVENT') THEN
  	  li(G_EVT_RT_NODE_0||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_1);
  	  li(G_EVT_RT_NODE_2||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_3||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_4);
    ELSE
  	  li(G_RT_NODE_1);
  		li(G_RT_NODE_BOCODE||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_RT_NODE_2);
  	  li(G_RT_NODE_BOCODE||''''||l_node_tbl(1).BO_CODE||'''');
  	END IF;
  WHEN 'ORG_CUST' THEN
    IF (P_SQL_FOR = 'EVENT') THEN
  	  li(G_EVT_RT_NODE_0||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_1);
  	  li(G_EVT_RT_NODE_2||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_3||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_EVT_RT_NODE_4);
    ELSE
  	  li(G_RT_NODE_1);
  	  li(G_RT_NODE_BOCODE||''''||l_node_tbl(1).BO_CODE||'''');
  	  li(G_RT_NODE_2);
  	  li(G_RT_NODE_BOCODE||''''||l_node_tbl(1).BO_CODE||'''');
  	END IF;
  ELSE
  	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	   hz_utility_v2pub.debug(
  	    p_message=>'invalid first node a.k.a invalid root_node node ',
  	    p_prefix=>l_debug_prefix,
  	    p_msg_level=>fnd_log.level_procedure);
  	END IF;
  END CASE;
/*
	Now figuring out when to write right parenthesis.

	First Record selected will always be root node of one of the four
	business objects (Org, Person, Org Customer and Person Customer).

	As there are no predecessors to first record, no need to write
	the right paranthesis.

	For the second record in collection, there is no need to do elaborate checking.
	This is because, ALWAYS, previous record is the root node of the current record.

	So for both first and second records, the only operatio that must be done is
	to figure out the correct SQL.

  From 3rd row onwards, figure out whether to write the right paranthesis
	for the previous record or not. Example - at 3rd node, you will figure out
	whether to write the right paranthesis for 2nd node or not.
  If it must be written, how many rigt paranthesis must be written.
	  Then write them.
		Figure out the correct SQL and write them to buffer.
	If right paranthesis must not be written,
	   store it in hash map.
	   write the correct SQL to the buffer.
 Note - the collection, which is called hash map here contains the
       following pieces of information.
       1. node for which the right paranthesis is stored
       2. BO of the node
       3. Parent BO of the node
       4. right paranthesis
*/

  FOR i IN 2..l_node_count LOOP
   IF i >2 THEN
	    -- for the second node in the hierarchy, there is no need to
			-- figure out right paranthesis. This is because, There are atleast two
			-- mandatory nodes in any object. Org (hz_parties, org profiles).
			-- Person (hz_parties, person profiles). Org Cust (hz_parties, one acct, one org)
			-- Person Cust (hz_parties, one acct, one person)
			-- So, the first node in an hierarchy never needs a right paranthesis at it's end.
			-- Hence, when processing second node SQL, we do not need to process the
			-- first node right paranthisis. Hence, we skip part to figure out the
			-- right paranthesis for the second node and go directly to figuring out the
			-- SQL for second node.
			IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			   hz_utility_v2pub.debug(
			    p_message=>'the node that is being processed is: '||i,
			    p_prefix=>l_debug_prefix,
			    p_msg_level=>fnd_log.level_procedure);
			END IF;
	   -- figuring out the right paranthesis
	   /* Some of the definitions that are useful to know to
	      code this section are:
	      Parent:
	        1. Prev rec is parent of current rec if it's BO
	           is the current nodes parent BO.
	        2. Prev rec is parent of the current rec if prev and current records
	           belongs to the same BO and has same parent BO, but prev record
	           is the root node.
	      Sibling:
	        1. Prev and Current recs belong to same BO and parent BO, and the
	           prev rec is NOT the root node.
	        2. Prev belongs to the parent BO of the current record, but it (prev rec)
	           is NOT the root node.
	        3. Prev and current recs belong to different BOs, but has same
	           parent BO and the prev rec is the root node.

         If and when previous record is either type1 or type 2 parent of the
           current record, then store the right paranthesis in hash map.
         If the previoous record is one of the siblings,
					 then right paranthesis will be written.
	       If the previous record is neither the parent nor the sibling, then
	         write all the right paranthesis stored so far in the hasp map.
	   */
	   CASE
			------------------------------------
	    -- type 1 parent -- Prev rec is parent of current rec .
	    ------------------------------------
	    WHEN ((l_node_tbl(i-1).BO_CODE = l_node_tbl(i).PARENT_BO_CODE) AND
	          (l_node_tbl(i-1).RNF = 'Y')) THEN
	    -- Build hashmap containing
	    --   right paranthesis, bo name (curr.parent_node),
	    --   grand parent node (prev.parent_node)
	    	-- As a speacial case, skip the node that represents the org or person
	    	-- in the context of org or person customer as the parent.
	    	-- This is needed as a performance improvement.
	    	-- without this performance improvement, there will be two party_id bind variables
	    	-- and the query generated is not correlated. Hence, CBO chooses
	    	-- expensive execution path.

	    	IF ((l_node_tbl(i-1).PARENT_BO_CODE = 'ORG_CUST' OR
				l_node_tbl(i-1).PARENT_BO_CODE = 'PERSON_CUST') AND
				(l_node_tbl(i-1).BO_CODE = 'ORG' OR
				l_node_tbl(i-1).BO_CODE = 'PERSON') AND
   			(l_node_tbl(i-1).ENTITY_NAME = 'HZ_PARTIES') AND
				(l_node_tbl(i-1).RNF = 'Y')) THEN
					NULL;
				ELSE
		     l_rpc := l_rpc +1;
 		     l_rp_tbl(l_rpc).node := (i-1); --right paranthesis is ALWAYS stored for prev node
		     l_rp_tbl(l_rpc).rp := l_rp;
		     l_rp_tbl(l_rpc).BO_CODE := l_node_tbl(i).PARENT_BO_CODE;
		     l_rp_tbl(l_rpc).PARENT_BO_CODE := l_node_tbl(i-1).PARENT_BO_CODE;
					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					   hz_utility_v2pub.debug(
					    p_message=>'The prev node is type 1 parent of the current node '||i,
					    p_prefix=>l_debug_prefix,
					    p_msg_level=>fnd_log.level_procedure);
					   hz_utility_v2pub.debug(
					    p_message=>'storing the right paranthesis. details of the hashmap',
					    p_prefix=>l_debug_prefix,
					    p_msg_level=>fnd_log.level_procedure);
					   hz_utility_v2pub.debug(
					    p_message=>'rec:'||l_rpc||'BOCODE:'||l_node_tbl(i).PARENT_BO_CODE||':parent node:'||(i-1)||':PARENTBO:'||l_node_tbl(i-1).PARENT_BO_CODE,
					    p_prefix=>l_debug_prefix,
					    p_msg_level=>fnd_log.level_procedure);
					END IF;
				END IF;	-- end of if stmt for skipping the ) collection
			------------------------------------
/*
	        2. Prev rec is parent of the current rec if prev and current records
	           belongs to the same BO and has same parent BO, but prev record
	           is the root node.
*/
	    -- type 2 parent
	    ------------------------------------
	    WHEN ((l_node_tbl(i).PARENT_BO_CODE = l_node_tbl(i-1).PARENT_BO_CODE) AND
	         (l_node_tbl(i-1).BO_CODE = l_node_tbl(i).BO_CODE) AND
	         (l_node_tbl(i-1).RNF = 'Y')) THEN
	    -- Build hashmap containing
	    --   right paranthesis, bo name (curr.bo_node),
	    --   grand parent node (curr.parent_node)
	    	-- As a speacial case, skip the node that represents the org or person
	    	-- in the context of org or person customer as the parent.
	    	-- This is needed as a performance improvement.
	    	IF ((l_node_tbl(i-1).PARENT_BO_CODE = 'ORG_CUST' OR
				l_node_tbl(i-1).PARENT_BO_CODE = 'PERSON_CUST') AND
				(l_node_tbl(i-1).BO_CODE = 'ORG' OR
				l_node_tbl(i-1).BO_CODE = 'PERSON') AND
   			(l_node_tbl(i-1).ENTITY_NAME = 'HZ_PARTIES') AND
				(l_node_tbl(i-1).RNF = 'Y')) THEN
					NULL;
				ELSE
		     l_rpc := l_rpc +1;
 		     l_rp_tbl(l_rpc).node := (i-1); -- right paranthesis is stored for prev node -ALWAYS
		     l_rp_tbl(l_rpc).rp := l_rp;
		     l_rp_tbl(l_rpc).BO_CODE := l_node_tbl(i).BO_CODE;
		     l_rp_tbl(l_rpc).PARENT_BO_CODE := l_node_tbl(i).PARENT_BO_CODE;
					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					   hz_utility_v2pub.debug(
					    p_message=>'The prev node is type 2 parent of the current node '||i,
					    p_prefix=>l_debug_prefix,
					    p_msg_level=>fnd_log.level_procedure);
					   hz_utility_v2pub.debug(
					    p_message=>'storing the right paranthesis. details of the hashmap',
					    p_prefix=>l_debug_prefix,
					    p_msg_level=>fnd_log.level_procedure);
					   hz_utility_v2pub.debug(
					    p_message=>'rec:'||l_rpc||'BOCODE:'||l_node_tbl(i).BO_CODE||':parentnode: '||(i-1)||':PARENTBO:'||l_node_tbl(i).PARENT_BO_CODE,
					    p_prefix=>l_debug_prefix,
					    p_msg_level=>fnd_log.level_procedure);
					END IF;
				END IF;-- end of if stmt for skipping the ) collection for typ2 parent
      ---------------------------------------
      /*
	        1. Prev and Current recs belong to same BO and parent BO, and the
	           prev rec is NOT the root node.
	    -- type 1 sibling
	       For the siblings, we will not collect the right paranthesis.
	    */
	    ---------------------------------------
	    WHEN ((l_node_tbl(i-1).BO_CODE = l_node_tbl(i).PARENT_BO_CODE) AND
	          (l_node_tbl(i-1).RNF = 'N' )) THEN
	      l2i(l_rp||'--'||l_node_tbl(i-1).entity_name);
					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					   hz_utility_v2pub.debug(
					    p_message=>'for node: '||i|| 'is the type 1 sibling of:'||l_node_tbl(i).PARENT_BO_CODE,
					    p_prefix=>l_debug_prefix,
					    p_msg_level=>fnd_log.level_procedure);
					END IF;
      ---------------------------------------
/*
	        2. Prev belongs to the parent BO of the current record, but it (prev rec)
	           is NOT the root node.

	    -- type 2 sibling
*/
      ---------------------------------------
	    WHEN ((l_node_tbl(i).PARENT_BO_CODE = l_node_tbl(i-1).PARENT_BO_CODE) AND
	         (l_node_tbl(i-1).BO_CODE = l_node_tbl(i).BO_CODE) AND
	         (l_node_tbl(i-1).RNF = 'N')) THEN
	      l2i(l_rp||'--'||l_node_tbl(i-1).entity_name);
					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					   hz_utility_v2pub.debug(
					    p_message=>'node: '||i|| 'is the type 2 sibling of node:'||(i-1)||'and its parent bo is:'||l_node_tbl(i).PARENT_BO_CODE,
					    p_prefix=>l_debug_prefix,
					    p_msg_level=>fnd_log.level_procedure);
					END IF;
      ---------------------------------------
/*
	        3. Prev and current recs belong to different BOs, but has same
	           parent BO and the prev rec is the root node.

	    -- type 3 sibling
*/
      ---------------------------------------

	    WHEN ((l_node_tbl(i).PARENT_BO_CODE = l_node_tbl(i-1).PARENT_BO_CODE) AND
	         (l_node_tbl(i-1).BO_CODE <> l_node_tbl(i).BO_CODE) AND
	         (l_node_tbl(i-1).RNF = 'Y')) THEN
	      l2i(l_rp||'--'||l_node_tbl(i-1).entity_name);
					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					   hz_utility_v2pub.debug(
					    p_message=>'node: '||i||' is the type 3 sibling of:'||(i-1)||' and its parent bo is:'||l_node_tbl(i).PARENT_BO_CODE,
					    p_prefix=>l_debug_prefix,
					    p_msg_level=>fnd_log.level_procedure);
					END IF;
	    -- when neither parent nor sibling
	    ELSE
	      -- this section of code is executed when we need to write the
	      -- right paranthesis when the prev rec is neither parent nor sibling.
					-- Before dumping the right paranthesis that were stored in the hashmap,
					-- write a right paranthesis for the previous node.
					-- This is needed because:
					-- 1. previous node is niether parent nor sibling of the current nodes
					-- 2. the hashmap does not contain the right paranthesis for the previous
					--    node.
					-- 3. every sql segment for any given entity barring the first node
					--    in node_tbl will have left parnthesis in its global variable
	        l2i(l_rp||' --'||l_node_tbl(i-1).entity_name);

				  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				     hz_utility_v2pub.debug(
				        p_message=>'previous node is neither the parent nor sibling of node:'||i,
				        p_prefix=>l_debug_prefix,
				        p_msg_level=>fnd_log.level_procedure);
				     hz_utility_v2pub.debug(
				        p_message=>'node: '||i|| 'is not a parent or sibling of node:'||(i-1)||' and its parent bo:'||l_node_tbl(i).PARENT_BO_CODE,
				        p_prefix=>l_debug_prefix,
				        p_msg_level=>fnd_log.level_procedure);
				     hz_utility_v2pub.debug(
				        p_message=>'number of right paranthesis collected so far:'||l_rpc,
				        p_prefix=>l_debug_prefix,
				        p_msg_level=>fnd_log.level_procedure);
				  END IF;
	        -- now, start writing the stored right paranthesis to the buffer.
		      l_gpvar := NULL; -- temporarily stores grand-parent of the prev rec
		      l_rp_ct := l_rpc;
		      l_var   := 1; -- initializing the l_var such that the code will loop
		                    -- through all the rows in the right paranthesis hashmap.
	        l_chk_node := 0; -- initializing this temp var
		     LOOP
		       l_chk_node := l_rp_tbl(l_rp_ct).node;

		      IF l_gpvar IS NULL THEN
		      -- This will run only the first time when traversing the hierarchy
		      -- and it is identified that the previous record is neither a sibling nor
		      -- a parent.
		      -- now, check to see if the node stored in the hash map is
					-- in any way releated (type 1 or 2 parent)to that of
					-- the previous record in the node hierrachy. If so, write the right paranthesis.

		      -- Here, checking the previous node because, writing of right paranthesis
		      -- is always for previous record.

		       IF (l_node_tbl(i-1).bo_code = l_rp_tbl(l_rp_ct).bo_code) OR
					     (l_node_tbl(i-1).PARENT_BO_CODE = l_rp_tbl(l_rp_ct).bo_code)
				   THEN
		         l2i(l_rp||' --'||l_node_tbl(i-1).bo_code); -- writing right parantheis to buffer
		         -- once the row from current collection (l_rp_tbl) is deleted,
		         -- then we loose the parent BO of the row. we need this to
		         -- tie this (going to be deleted rec) to the previous rec in
		         -- collection to compare and see if it must be deleted or not.
		         -- So, l_gpvar acts as a temp store for storing the parent BO
		         l_gpvar := l_rp_tbl(l_rp_ct).PARENT_BO_CODE;
		         l_rp_tbl.DELETE(l_rp_ct);
		         l_rp_ct := l_rp_ct-1;
		       END IF;
		      ELSE

		        IF l_gpvar = l_rp_tbl(l_rp_ct).bo_code THEN

							-- This piece of code ensures that all the right paranthesis are
							-- written to buffer for all collected nodes until,
							--  any one of the previously stored node (in l_rp_tbl) is
							-- type1 or type2 parent of the current node (in l_node_tbl)

		         -- before writing the right paranthesis,
		         -- check if (l_rp_tbl) collection rec getting deleted is not the
		         -- the parent of current node (in l_node_tbl) that is being processed.
		         -- If it is, do not delete the record from (l_rp_tbl) collection
		         -- and exit from this loop. This is because, current node, being
		         -- a child of the node in l_rp_tbl collection, it must not write
		         -- the rparanthesis.
/*
*/
	           EXIT WHEN (((l_node_tbl(i).PARENT_BO_CODE = l_node_tbl(l_chk_node).PARENT_BO_CODE) AND
                          (l_node_tbl(i).BO_CODE = l_node_tbl(l_chk_node).BO_CODE) AND
	                        (l_node_tbl(l_chk_node).RNF = 'Y')) OR
                         ((l_node_tbl(l_chk_node).BO_CODE = l_node_tbl(i).PARENT_BO_CODE) AND
                           (l_node_tbl(l_chk_node).RNF = 'Y'))
												);
  	         l2i(l_rp||' --'||l_gpvar); -- writing right parantheis to buffer
		         l_gpvar := l_rp_tbl(l_rp_ct).PARENT_BO_CODE;
		         l_rp_tbl.DELETE(l_rp_ct);
		         l_rp_ct := l_rp_ct-1;

		        END IF;
		      END IF;
		      EXIT WHEN l_var > l_rp_ct;
		     END LOOP;
		     -- to ensure not to over write the node info in l_rp_tbl collection,
		     -- set the counter to the last available record in l_rp_tbl table.
		     l_rpc := l_rp_tbl.count;
	   END CASE; -- end of CASE for figuring out if previous record is current recs
	             -- parent or sibling, to write the right paranthesis.
   END IF; -- check for >2 node or not

   -- write the 'AND EXISTS' and the appropriate sql for the current node.
   CASE l_node_tbl(i).entity_name
     WHEN 'HZ_CERTIFICATIONS' THEN
		-- can have Org or Person as Parent
    	IF (l_node_tbl(i).BO_CODE = 'ORG' OR l_node_tbl(i).BO_CODE = 'PERSON') THEN
           IF P_SQL_FOR = 'EVENT' THEN
	      l2i(G_HZ_CERT_P);
	      l2i(G_LUD);
  	   ELSE
		l2i(G_HZ_CERT_P);
  	   END IF;
	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
		fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
		fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
		fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
		fnd_msg_pub.ADD;
		RAISE FND_API.G_EXC_ERROR;
	      ELSE
		fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
		fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
		fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
		fnd_msg_pub.ADD;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;
	END IF;
     WHEN 'HZ_CITIZENSHIP' THEN
		 -- can have Person as parent
    	IF (l_node_tbl(i).BO_CODE = 'PERSON') THEN
  			IF P_SQL_FOR = 'EVENT' THEN
					l2i(G_HZ_CITIZEN_P);
					l2i(G_LUD);
  			ELSE
					l2i(G_HZ_CITIZEN_P);
  			END IF;
			ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
			END IF;
		WHEN 'HZ_CODE_ASSIGNMENTS' THEN
		-- can have Org or Person as Parent
    	IF (l_node_tbl(i).BO_CODE = 'ORG' OR l_node_tbl(i).BO_CODE = 'PERSON') THEN
  			IF P_SQL_FOR = 'EVENT' THEN
					l2i(G_HZ_CODE_ASSIGN_P);
					l2i(G_LUD);
  			ELSE
					l2i(G_HZ_CODE_ASSIGN_P);
  			END IF;
			ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
			END IF;
		WHEN 'HZ_CONTACT_POINTS' THEN
		-- contact points can have Org, Person, Contact, PS
			CASE l_node_tbl(i).PARENT_BO_CODE
				WHEN 'ORG' THEN
				-- contact point types are EDI, EFT, EMAIL, PHONE, WEB, TLX
				  CASE l_node_tbl(i).BO_CODE
				    WHEN 'EFT' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
					      l2i(G_CP_EFT);
			  			ELSE
					      ll2i(G_CP_P1);
					      l2i(G_CP_EFT);
			  			END IF;
				    WHEN 'EDI' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
					      l2i(G_CP_EDI);
			  			ELSE
					      ll2i(G_CP_P1);
					      l2i(G_CP_EDI);
			  			END IF;
				    WHEN 'EMAIL' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
					      l2i(G_CP_EMAIL);
			  			ELSE
					      ll2i(G_CP_P1);
					      l2i(G_CP_EMAIL);
			  			END IF;
				    WHEN 'PHONE' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
					      l2i(G_CP_PHONE);
			  			ELSE
					      ll2i(G_CP_P1);
					      l2i(G_CP_PHONE);
			  			END IF;
				    WHEN 'WEB' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
					      l2i(G_CP_WEB);
			  			ELSE
					      ll2i(G_CP_P1);
					      l2i(G_CP_WEB);
			  			END IF;
				    WHEN 'TLX' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
					      l2i(G_CP_TLX);
			  			ELSE
					      ll2i(G_CP_P1);
					      l2i(G_CP_TLX);
			  			END IF;
				    ELSE
				      IF  P_SQL_FOR = 'EVENT' THEN
								fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_BOCODE');
								fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
								fnd_message.set_token('BO_CODE' ,l_node_tbl(i).BO_CODE);
								fnd_msg_pub.ADD;
								RAISE FND_API.G_EXC_ERROR;
				      ELSE
								fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_BOCODE');
								fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
								fnd_message.set_token('BO_CODE' ,l_node_tbl(i).BO_CODE);
								fnd_msg_pub.ADD;
								RAISE FND_API.G_EXC_ERROR;
				      END IF;
				  END CASE;
				WHEN 'PERSON' THEN
        -- contact point types are EMAIL, PHONE, WEB, SMS
          CASE l_node_tbl(i).BO_CODE
            WHEN 'EMAIL' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
					      l2i(G_CP_EMAIL);
			  			ELSE
					      ll2i(G_CP_P1);
					      l2i(G_CP_EMAIL);
			  			END IF;
            WHEN 'PHONE' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
					      l2i(G_CP_PHONE);
			  			ELSE
					      ll2i(G_CP_P1);
					      l2i(G_CP_PHONE);
			  			END IF;
            WHEN 'WEB' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
					      l2i(G_CP_WEB);
			  			ELSE
					      ll2i(G_CP_P1);
					      l2i(G_CP_WEB);
			  			END IF;
            WHEN 'SMS' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
					      ll2i(G_CP_P1_ET1);
	              l2i(G_CP_SMS);
			  			ELSE
					      ll2i(G_CP_P1);
	              l2i(G_CP_SMS);
			  			END IF;
            ELSE
				      IF  P_SQL_FOR = 'EVENT' THEN
								fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_BOCODE');
								fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
								fnd_message.set_token('BO_CODE' ,l_node_tbl(i).BO_CODE);
								fnd_msg_pub.ADD;
								RAISE FND_API.G_EXC_ERROR;
				      ELSE
								fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_BOCODE');
								fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
								fnd_message.set_token('BO_CODE' ,l_node_tbl(i).BO_CODE);
								fnd_msg_pub.ADD;
								RAISE FND_API.G_EXC_ERROR;
				      END IF;
          END CASE;
        WHEN 'ORG_CONTACT' THEN
        -- contact point types are EMAIL, PHONE, WEB, TLX
          CASE l_node_tbl(i).BO_CODE
            WHEN 'PHONE' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
	              ll2i(G_CP_REL1_ET1);
	              ll2i(G_CP_REL1_ET2);
	              l2i(G_CP_PHONE);
			  			ELSE
	              ll2i(G_CP_REL1);
	              l2i(G_CP_PHONE);
			  			END IF;
            WHEN 'TLX' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
	              ll2i(G_CP_REL1_ET1);
	              ll2i(G_CP_REL1_ET2);
	              l2i(G_CP_TLX);
			  			ELSE
	              ll2i(G_CP_REL1);
	              l2i(G_CP_TLX);
			  			END IF;
            WHEN 'EMAIL' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
	              ll2i(G_CP_REL1_ET1);
	              ll2i(G_CP_REL1_ET2);
	              l2i(G_CP_EMAIL);
			  			ELSE
	              ll2i(G_CP_REL1);
	              l2i(G_CP_EMAIL);
			  			END IF;
            WHEN 'WEB' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
	              ll2i(G_CP_REL1_ET1);
	              ll2i(G_CP_REL1_ET2);
	              l2i(G_CP_WEB);
			  			ELSE
	              ll2i(G_CP_REL1);
	              l2i(G_CP_WEB);
			  			END IF;
            WHEN 'SMS' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
	              ll2i(G_CP_REL1_ET1);
	              ll2i(G_CP_REL1_ET2);
	              l2i(G_CP_SMS);
			  			ELSE
	              ll2i(G_CP_REL1);
	              l2i(G_CP_SMS);
			  			END IF;
            ELSE
				      IF  P_SQL_FOR = 'EVENT' THEN
								fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_BOCODE');
								fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
								fnd_message.set_token('BO_CODE' ,l_node_tbl(i).BO_CODE);
								fnd_msg_pub.ADD;
								RAISE FND_API.G_EXC_ERROR;
				      ELSE
								fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_BOCODE');
								fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
								fnd_message.set_token('BO_CODE' ,l_node_tbl(i).BO_CODE);
								fnd_msg_pub.ADD;
								RAISE FND_API.G_EXC_ERROR;
				      END IF;
          END CASE;
        WHEN 'PARTY_SITE' THEN
        -- contact point types are EMAIL, PHONE, WEB, TLX
          CASE l_node_tbl(i).BO_CODE
            WHEN 'PHONE' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
	              ll2i(G_CP_PS1_ET1);
	              l2i(G_CP_PHONE);
			  			ELSE
	              ll2i(G_CP_PS1);
	              l2i(G_CP_PHONE);
			  			END IF;
            WHEN 'TLX' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
	              ll2i(G_CP_PS1_ET1);
	              l2i(G_CP_TLX);
			  			ELSE
	              ll2i(G_CP_PS1);
	              l2i(G_CP_TLX);
			  			END IF;
            WHEN 'EMAIL' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
	              ll2i(G_CP_PS1_ET1);
	              l2i(G_CP_EMAIL);
			  			ELSE
	              ll2i(G_CP_PS1);
	              l2i(G_CP_EMAIL);
			  			END IF;
            WHEN 'WEB' THEN
			  			IF P_SQL_FOR = 'EVENT' THEN
	              ll2i(G_CP_PS1_ET1);
	              l2i(G_CP_WEB);
			  			ELSE
	              ll2i(G_CP_PS1);
	              l2i(G_CP_WEB);
			  			END IF;
            ELSE
				      IF  P_SQL_FOR = 'EVENT' THEN
								fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_BOCODE');
								fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
								fnd_message.set_token('BO_CODE' ,l_node_tbl(i).BO_CODE);
								fnd_msg_pub.ADD;
								RAISE FND_API.G_EXC_ERROR;
				      ELSE
								fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_BOCODE');
								fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
								fnd_message.set_token('BO_CODE' ,l_node_tbl(i).BO_CODE);
								fnd_msg_pub.ADD;
								RAISE FND_API.G_EXC_ERROR;
				      END IF;
          END CASE;
        ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
	    END CASE; -- CP
    WHEN 'HZ_CONTACT_PREFERENCES' THEN
    	-- contact preference can have Org, Person, Contact, PS, CP as parents
    	CASE l_node_tbl(i).BO_CODE
	    	WHEN 'ORG' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
	  	  		l2i(G_HZ_CONT_PREF_P);
	  	  		l2i(G_LUD);
	  			ELSE
	  	  		l2i(G_HZ_CONT_PREF_P);
	  			END IF;
	    	WHEN 'PERSON' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
	  	  		l2i(G_HZ_CONT_PREF_P);
	  	  		l2i(G_LUD);
	  			ELSE
	  	  		l2i(G_HZ_CONT_PREF_P);
	  			END IF;
	    	WHEN 'ORG_CONTACT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
	  	  		l2i(G_HZ_CONT_PREF_REL_ET1);
	  	  		l2i(G_HZ_CONT_PREF_REL_ET2);
	  			ELSE
		    		l2i(G_HZ_CONT_PREF_REL);
	  			END IF;
	    	WHEN 'PARTY_SITE' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		    		l2i(G_HZ_CONT_PREF_PS);
	  	  		l2i(G_LUD);
	  			ELSE
		    		l2i(G_HZ_CONT_PREF_PS);
	  			END IF;
	    	WHEN 'PHONE' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		    		l2i(G_HZ_CONT_PREF_CP);
	  	  		l2i(G_LUD);
	  			ELSE
		    		l2i(G_HZ_CONT_PREF_CP);
	  			END IF;
        WHEN 'EMAIL' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		    		l2i(G_HZ_CONT_PREF_CP);
	  	  		l2i(G_LUD);
	  			ELSE
		    		l2i(G_HZ_CONT_PREF_CP);
	  			END IF;
        WHEN 'WEB' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		    		l2i(G_HZ_CONT_PREF_CP);
	  	  		l2i(G_LUD);
	  			ELSE
		    		l2i(G_HZ_CONT_PREF_CP);
	  			END IF;
        WHEN 'TLX' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		    		l2i(G_HZ_CONT_PREF_CP);
	  	  		l2i(G_LUD);
	  			ELSE
		    		l2i(G_HZ_CONT_PREF_CP);
	  			END IF;
        WHEN 'SMS' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		    		l2i(G_HZ_CONT_PREF_CP);
	  	  		l2i(G_LUD);
	  			ELSE
		    		l2i(G_HZ_CONT_PREF_CP);
	  			END IF;
        WHEN 'EDI' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		    		l2i(G_HZ_CONT_PREF_CP);
	  	  		l2i(G_LUD);
	  			ELSE
		    		l2i(G_HZ_CONT_PREF_CP);
	  			END IF;
        WHEN 'EFT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		    		l2i(G_HZ_CONT_PREF_CP);
	  	  		l2i(G_LUD);
	  			ELSE
		    		l2i(G_HZ_CONT_PREF_CP);
	  			END IF;
	    	ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
    	END CASE; --cpp
    WHEN 'HZ_CREDIT_RATINGS' THEN
    -- CR is only for Org
      IF l_node_tbl(i).BO_CODE = 'ORG' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
			    	l2i(G_HZ_CREDIT_RATINGS_P);
	  	  		l2i(G_LUD);
	  			ELSE
			    	l2i(G_HZ_CREDIT_RATINGS_P);
	  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF;
    WHEN 'HZ_CUST_ACCOUNT_ROLES' THEN
    -- HZ_CUST_ACCOUNT_ROLES Can have Account, Account Site as parent
      CASE l_node_tbl(i).PARENT_BO_CODE
      	WHEN 'CUST_ACCT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_CUST_ACCT_ROLES_A);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_CUST_ACCT_ROLES_A);
	  			END IF;
      	WHEN 'CUST_ACCT_SITE' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_CUST_ACCT_ROLES_AS);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_CUST_ACCT_ROLES_AS);
	  			END IF;
      	ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
  					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
  					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
    	END CASE; -- cust_acct_roles
    WHEN 'HZ_CUST_ACCOUNTS' THEN
		--HZ_CUST_ACCOUNTS can have only Org or Person as parent
		  IF (l_node_tbl(i).PARENT_BO_CODE = 'ORG_CUST' OR l_node_tbl(i).PARENT_BO_CODE = 'PERSON_CUST') THEN
  			IF P_SQL_FOR = 'EVENT' THEN
					l2i(G_HZ_CUST_ACCTS_P);
  	  		l2i(G_LUD);
  			ELSE
					l2i(G_HZ_CUST_ACCTS_P);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- cust_acct
    WHEN 'HZ_CUST_ACCT_RELATE_ALL' THEN
    -- HZ_CUST_ACCT_RELATE_ALL can only have cust account as parent
      IF l_node_tbl(i).BO_CODE = 'CUST_ACCT' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_CUST_ACCT_REL_P);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_CUST_ACCT_REL_P);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- cust_acct_relate_all
    WHEN 'HZ_CUST_ACCT_SITES_ALL' THEN
    -- HZ_CUST_ACCT_SITES_ALL have Cust Account as parent
      IF l_node_tbl(i).PARENT_BO_CODE = 'CUST_ACCT' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_CUST_ACCT_SITES_A);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_CUST_ACCT_SITES_A);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- cust_acct_sites_all
    WHEN 'HZ_CUST_PROFILE_AMTS' THEN
    -- HZ_CUST_PROFILE_AMTS Can have Account Profile as parent
      IF l_node_tbl(i).BO_CODE = 'CUST_PROFILE' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_CUST_PROF_AMTS_AP);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_CUST_PROF_AMTS_AP);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- cust_profile_amts
    WHEN 'HZ_CUST_SITE_USES_ALL' THEN
    -- HZ_CUST_SITE_USES_ALL can only have Account Site as parent
      IF l_node_tbl(i).PARENT_BO_CODE = 'CUST_ACCT_SITE' THEN
--      IF l_node_tbl(i).BO_CODE = 'CUST_ACCT_SITE' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_CUST_SITE_USES_AS);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_CUST_SITE_USES_AS);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- cust_site_uses
    WHEN 'HZ_CUSTOMER_PROFILES' THEN
    -- HZ_CUSTOMER_PROFILES Can have Cust Account, Account Site Use as parents
      CASE l_node_tbl(i).PARENT_BO_CODE
      	WHEN 'CUST_ACCT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_CUST_PROF_A);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_CUST_PROF_A);
	  			END IF;
      	WHEN 'CUST_ACCT_SITE_USE' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_CUST_PROF_ASU);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_CUST_PROF_ASU);
	  			END IF;
      	ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
  					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
  					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
    	END CASE; -- cust_prof
    WHEN 'HZ_EDUCATION' THEN
    -- HZ_EDUCATION Can have Person as parent
      IF l_node_tbl(i).BO_CODE = 'PERSON' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
		   		l2i(G_HZ_EDU_P);
  	  		l2i(G_LUD);
  			ELSE
		   		l2i(G_HZ_EDU_P);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- edu
    WHEN 'HZ_EMPLOYMENT_HISTORY' THEN
    -- HZ_EMPLOYMENT_HISTORY Can have Person as parent
      IF l_node_tbl(i).PARENT_BO_CODE = 'PERSON' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_EMP_HIST_P);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_EMP_HIST_P);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- emp_hist
    WHEN 'HZ_FINANCIAL_NUMBERS' THEN
    -- HZ_FINANCIAL_NUMBERS can have financial reports as parent
	    IF l_node_tbl(i).BO_CODE = 'FIN_REPORT' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_FIN_NUM_FR);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_FIN_NUM_FR);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- fin_num
    WHEN 'HZ_FINANCIAL_PROFILE' THEN
		-- HZ_FINANCIAL_PROFILE Can have Person,Org as parent
		-- can have Org or Person as Parent
    	IF (l_node_tbl(i).BO_CODE = 'ORG' OR l_node_tbl(i).BO_CODE = 'PERSON') THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_FIN_PROF_P);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_FIN_PROF_P);
  			END IF;
			ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
			END IF; -- fin_prof
    WHEN 'HZ_FINANCIAL_REPORTS' THEN
    -- HZ_FINANCIAL_REPORTS can only have Org as parent
      IF l_node_tbl(i).PARENT_BO_CODE = 'ORG' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_FIN_REP_P);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_FIN_REP_P);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- fin_rep
    WHEN 'HZ_LOCATIONS' THEN
    -- HZ_LOCATIONS can only have PS as parent
      IF l_node_tbl(i).PARENT_BO_CODE = 'PARTY_SITE' THEN
--		  IF l_node_tbl(i).BO_CODE = 'PARTY_SITE' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_LOC_PS);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_LOC_PS);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- loc
		WHEN 'HZ_ORG_CONTACT_ROLES' THEN
    -- HZ_ORG_CONTACT_ROLES can only have Org Contact as parent
    -- for Org Contact as parent
      IF l_node_tbl(i).BO_CODE = 'ORG_CONTACT' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_ORG_CONT_ROLE_OC);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_ORG_CONT_ROLE_OC);
  			END IF;
			ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- cont_roles
    WHEN 'HZ_ORG_CONTACTS' THEN
    -- HZ_ORG_CONTACTS Can have Org, Cust Acct Contact as parent
      CASE l_node_tbl(i).PARENT_BO_CODE
      	WHEN 'ORG' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_ORG_CONT_P1);
		   			l2i(G_HZ_ORG_CONT_P1_ORG);
		   			l2i(G_HZ_ORG_CONT_P2_ET1);
--		   			l2i(G_HZ_ORG_CONT_P3);
	  			ELSE
		   			l2i(G_HZ_ORG_CONT_P1);
		   			l2i(G_HZ_ORG_CONT_P1_ORG);
		   			l2i(G_HZ_ORG_CONT_P2);
--		   			l2i(G_HZ_ORG_CONT_P3);
	  			END IF;
      	WHEN 'PERSON' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_ORG_CONT_P1);
		   			l2i(G_HZ_ORG_CONT_P1_PER);
		   			l2i(G_HZ_ORG_CONT_P2_ET1);
--		   			l2i(G_HZ_ORG_CONT_P3);
	  			ELSE
		   			l2i(G_HZ_ORG_CONT_P1);
		   			l2i(G_HZ_ORG_CONT_P1_PER);
		   			l2i(G_HZ_ORG_CONT_P2);
--		   			l2i(G_HZ_ORG_CONT_P3);
	  			END IF;
/*
	     	WHEN 'CUST_ACCT_CONTACT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_ORG_CONT_AC1);
		   			l2i(G_HZ_ORG_CONT_AC2_ET1);
		   			l2i(G_HZ_ORG_CONT_AC3);
		   			l2i(G_HZ_ORG_CONT_AC4);
	  			ELSE
		   			l2i(G_HZ_ORG_CONT_AC1);
		   			l2i(G_HZ_ORG_CONT_AC2);
		   			l2i(G_HZ_ORG_CONT_AC3);
		   			l2i(G_HZ_ORG_CONT_AC4);
 	  			END IF;
*/
	     	ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
    	END CASE; -- org_contact
    WHEN 'HZ_ORGANIZATION_PROFILES' THEN
    -- HZ_ORGANIZATION_PROFILES can only have Org as parent
      IF l_node_tbl(i).BO_CODE = 'ORG' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_ORG_PROF_P);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_ORG_PROF_P);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- org_profiles
    WHEN 'HZ_PARTIES' THEN
    -- HZ_PARTIES is the parent - in the context of Person and Org
    -- P_PARTY_ID is the parameter that would be passed by the caller
      CASE l_node_tbl(i).PARENT_BO_CODE
      	WHEN 'ORG' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_PARTIES);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_PARTIES);
	  			END IF;
      	WHEN 'PERSON' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_PARTIES);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_PARTIES);
	  			END IF;
	      -- HZ_PARTIES is the child enetiy for Person Customer BO
	      -- P_PARTY_ID is the parameter that would be passed by the caller
      	WHEN 'PERSON_CUST' THEN
	    	-- As a speacial case, skip the node that represents the org or person
	    	-- in the context of org or person customer as the parent.
	    	-- This is needed as a performance improvement.
/*	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_PARTIES_PCUST);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_PARTIES_PCUST);
	  			END IF;
*/
					NULL;
	      -- HZ_PARTIES is the child enetiy for Org Customer BO
	      -- P_PARTY_ID is the parameter that would be passed by the caller
      	WHEN 'ORG_CUST' THEN
	    	-- As a speacial case, skip the node that represents the org or person
	    	-- in the context of org or person customer as the parent.
	    	-- This is needed as a performance improvement.
/*	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_PARTIES_OCUST);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_PARTIES_OCUST);
	  			END IF;
*/
					NULL;
		    -- HZ_PARTIES (person) as the child of Org Contact
		    -- for Org Contact as the parent
      	WHEN 'ORG_CONTACT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_PARTIES_OC_ET1);
	  			ELSE
		   			l2i(G_HZ_PARTIES_OC);
	  			END IF;
      	ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
    	END CASE; -- parties
    WHEN 'HZ_PARTY_PREFERENCES' THEN
    -- HZ_PARTY_PREFERENCES Org and Person as parents
      IF(l_node_tbl(i).BO_CODE = 'ORG' OR l_node_tbl(i).BO_CODE = 'PERSON') THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_PARTY_PREF_P);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_PARTY_PREF_P);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- party_pref
    WHEN 'HZ_PARTY_SITE_USES' THEN
    -- HZ_PARTY_SITE_USES can have only Party Site as parent
      IF l_node_tbl(i).BO_CODE = 'PARTY_SITE' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_PS_USE_PS);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_PS_USE_PS);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- party_site_use
    WHEN 'HZ_PARTY_SITES' THEN
    -- HZ_PARTY_SITES Can have Org, Person, Contact and Account Site as parents
      CASE l_node_tbl(i).PARENT_BO_CODE
      	WHEN 'ORG' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_PS_P);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_PS_P);
	  			END IF;
      	WHEN 'PERSON' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_PS_P);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_PS_P);
	  			END IF;
      	WHEN 'ORG_CONTACT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_PS_OC_ET1);
	  			ELSE
		   			l2i(G_HZ_PS_OC);
	  			END IF;
/*
      	WHEN 'CUST_ACCT_SITE' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_PS_AS);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_PS_AS);
	  			END IF;
*/
      	ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
    	END CASE; -- PS
     WHEN 'HZ_PARTY_USG_ASSIGNMENTS' THEN
	-- can have Org or Person as Parent
    	IF (l_node_tbl(i).BO_CODE = 'ORG' OR l_node_tbl(i).BO_CODE = 'PERSON') THEN
           IF P_SQL_FOR = 'EVENT' THEN
	      l2i(G_HZ_PARTY_USG_ASSIN_P);
	      l2i(G_LUD);
  	   ELSE
		l2i(G_HZ_PARTY_USG_ASSIN_P);
  	   END IF;
	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
		fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
		fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
		fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
		fnd_msg_pub.ADD;
		RAISE FND_API.G_EXC_ERROR;
	      ELSE
		fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
		fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
		fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
		fnd_msg_pub.ADD;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;
	END IF;        -- end of 'HZ_PARTY_USG_ASSIGNMENTS'
    WHEN 'HZ_PERSON_INTEREST' THEN
    -- HZ_PERSON_INTEREST can only have Person as parent
      IF l_node_tbl(i).BO_CODE = 'PERSON' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_PER_INT_P);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_PER_INT_P);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- per_int
    WHEN 'HZ_PERSON_LANGUAGE' THEN
    -- HZ_PERSON_LANGUAGE can only have Person as parent
      IF l_node_tbl(i).BO_CODE = 'PERSON' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
					l2i(G_HZ_PER_LANG_P);
  	  		l2i(G_LUD);
  			ELSE
					l2i(G_HZ_PER_LANG_P);
  			END IF;
      ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; --PL
    WHEN 'HZ_PERSON_PROFILES' THEN
    -- HZ_PERSON_PROFILES can only have Person or Person Contact as parent
      IF ((l_node_tbl(i).BO_CODE = 'PERSON') OR
	        (l_node_tbl(i).BO_CODE = 'PERSON_CONTACT')) THEN
  			IF P_SQL_FOR = 'EVENT' THEN
					l2i(G_HZ_PER_PROF_P);
  	  		l2i(G_LUD);
  			ELSE
					l2i(G_HZ_PER_PROF_P);
  			END IF;
      ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- per_prof
    WHEN 'HZ_RELATIONSHIPS' THEN
    -- HZ_RELATIONSHIPS can have Org, Person as parents
      CASE l_node_tbl(i).BO_CODE
      	WHEN 'ORG' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_REL_P);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_REL_P);
	  			END IF;
      	WHEN 'PERSON' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_REL_P);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_REL_P);
	  			END IF;
      	WHEN 'ORG_CONTACT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_HZ_REL_OC);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_HZ_REL_OC);
	  			END IF;
      	ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
 					  fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
			END CASE; -- rel
    WHEN 'HZ_ROLE_RESPONSIBILITY' THEN
    -- HZ_ROLE_RESPONSIBILITY can only have customer account contact as parent
      IF l_node_tbl(i).BO_CODE = 'CUST_ACCT_CONTACT' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
	   			l2i(G_HZ_ROLE_RESP_AC);
  	  		l2i(G_LUD);
  			ELSE
	   			l2i(G_HZ_ROLE_RESP_AC);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- role_resp
    WHEN 'HZ_WORK_CLASS' THEN
    -- HZ_WORK_CLASS can only have Employement History as parent
      IF l_node_tbl(i).PARENT_BO_CODE = 'EMP_HIST' THEN
  			IF P_SQL_FOR = 'EVENT' THEN
		   		l2i(G_HZ_WORK_CLASS_EH);
  	  		l2i(G_LUD);
  			ELSE
		   		l2i(G_HZ_WORK_CLASS_EH);
  			END IF;
     	ELSE
	      IF  P_SQL_FOR = 'EVENT' THEN
					fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      ELSE
					fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
					fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
					fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
					fnd_msg_pub.ADD;
					RAISE FND_API.G_EXC_ERROR;
	      END IF;
    	END IF; -- wrk_class
    WHEN 'RA_CUST_RECEIPT_METHODS' THEN
    -- RA_CUST_RECEIPT_METHODS can have Cust Account, Account Site Use as parents
      CASE l_node_tbl(i).PARENT_BO_CODE
      	WHEN 'CUST_ACCT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_CUST_RECEIPT_METHODS_AC);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_CUST_RECEIPT_METHODS_AC);
	  			END IF;
      	WHEN 'CUST_ACCT_SITE_USE' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_CUST_RECEIPT_METHODS_ASU);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_CUST_RECEIPT_METHODS_ASU);
	  			END IF;
      	ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
    	END CASE; -- ra_cust
    -- For Bank Account Use
    WHEN 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V' THEN
    -- IBY_FNDCPT_PAYER_ASSGN_INSTR_V can have Cust Account, Account Site Use as parents
      CASE l_node_tbl(i).PARENT_BO_CODE
      	WHEN 'CUST_ACCT' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_BANK_ACCT_USE_AC);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_BANK_ACCT_USE_AC);
	  			END IF;
      	WHEN 'CUST_ACCT_SITE_USE' THEN
	  			IF P_SQL_FOR = 'EVENT' THEN
		   			l2i(G_BANK_ACCT_USE_ASU);
	  	  		l2i(G_LUD);
	  			ELSE
		   			l2i(G_BANK_ACCT_USE_ASU);
	  			END IF;
      	ELSE
		      IF  P_SQL_FOR = 'EVENT' THEN
						fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      ELSE
						fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_PARENT');
						fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
						fnd_message.set_token('PARENT_BO_CODE' ,l_node_tbl(i).PARENT_BO_CODE);
						fnd_msg_pub.ADD;
						RAISE FND_API.G_EXC_ERROR;
		      END IF;
    	END CASE; -- bank_assign
    ELSE
      IF  P_SQL_FOR = 'EVENT' THEN
				fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_BAD_ENTITY');
				fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
				fnd_msg_pub.ADD;
				RAISE FND_API.G_EXC_ERROR;
      ELSE
				fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_BAD_ENTITY');
				fnd_message.set_token('ENTITY_NAME' ,l_node_tbl(i).ENTITY_NAME);
				fnd_msg_pub.ADD;
				RAISE FND_API.G_EXC_ERROR;
      END IF;
/*
*/
   END CASE; -- end of CASE for figuring out the entity name to get right SQL
  END LOOP; -- end of looping through hierarchy of collection.

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.debug(
        p_message=>'all the sql segments were identified',
        p_prefix=>l_debug_prefix,
        p_msg_level=>fnd_log.level_procedure);
  END IF;
	-- writing one right paranthesis for the last SQL.
	-- this is because, each sql has left paranthesis as part of its global var
	l2i(l_rp||' --for last sql segment');

	-- Writing the remaining right paranthesis in the hashmap
     -- loop through the hashmap and write the remaining.
	IF l_rp_tbl.COUNT >0 THEN
		FOR i IN l_rp_tbl.FIRST .. l_rp_tbl.LAST LOOP
		  l2i(l_rp||'--'||l_rp_tbl(i).BO_CODE);
		END LOOP;
	END IF;

	IF (P_SQL_FOR = 'COMPLETE') THEN
	  l2i(l_rp||'-- for not in clause in delete statement');
	ELSE
	  l2i(l_rp||'-- for in clause in update statement');
	END IF;

/*	-- If the object for which completeness procedure is being generated is,
	-- Person Customer or Org Customer BO, then write an extra right paranthesis.
	-- This extra paranthesis is needed because, the hz_party sql section for
	-- Org or Person - as child of per or Org customer O, starts with a left paranthesis.

  IF ((P_BO_CODE = 'ORG_CUST') OR (P_BO_CODE	= 'PERSON_CUST')) THEN
	  l2i(l_rp||'-- for org or person');
  END IF;

*/
	-- Write ; at the end of select statemenet.
	-- this is needed as so far, only cursor sql statement is generated.
	l2i('; -- cursor for '||P_SQL_FOR||' SQL');

  COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'GENBOSQL()-',
	                       p_prefix=>l_debug_prefix,
  			               p_msg_level=>fnd_log.level_procedure);
  END IF;
  P_STATUS := TRUE; -- this means sql generation is successfull
/*
EXCEPTION
WHEN others THEN
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
   		hz_utility_v2pub.debug(
			 p_message=>'in excp block of genBOSQL()'||SQLERRM,
		   p_prefix=>l_debug_prefix,
	  	p_msg_level=>fnd_log.level_procedure);
	  END IF;
    P_STATUS := FALSE;
*/
END; -- genBOSQL()
----------------------------------------------------------------------------
/* 	PROCEDURE: genCompletenessProc
   Purpose: This procedure is to generate the completeness procedure for all
		the high level business objects - ORG, PERSON, ORG_CUST, PERSON_CUST.
	 Called from: This package
	 Called by: gen_pkg_body()

*/
PROCEDURE genCompletenessProc IS

-- local variable for procedure name
l_procName VARCHAR2(30) := 'BO_COMPLETE_CHECK';
l_comment  VARCHAR2(100) := 'To determine completeness of BOs. Non-complete BOs will be deleted';
l_msg      VARCHAR2(150);
l_prefix   VARCHAR2(15) := 'GENCOMPSQL'; -- holds the debug prefix for this procedure
l_gen_prefix VARCHAR2(15) := 'COMPSQL';  -- holds the debug prefix for generated procedure
l_ret_status  BOOLEAN := TRUE;
l_sql_for VARCHAR2(30) := 'COMPLETE';
l_param_name VARCHAR2(30) := 'P_BO_CODE';

BEGIN
  if fnd_log.level_procedure>=fnd_log.g_current_runtime_level then
	hz_utility_v2pub.debug(p_message=>'genCompletenessProc ()+',
	                       p_prefix=>l_prefix,
    			               p_msg_level=>fnd_log.level_procedure);
  end if;
	/*
	This procedure will take P_BO_CODE as a parameter.
  For each BO, a separate delete statement must be generated.
	Flow:
	  . generate procedure header by calling procBegin()
	  . generate debug mesg
		. get BO Codes
		. generate if statement to check if the parameter passed = G_PER_BO_CODE
		  . generate delete statements (by calling genBOSQL(G_PER_BO_CODE));
		  . if previous delete statement generation is successfull
			  . generate commit statement
			  . generate debug mesg
		  . if previous delete statement generation is un-successfull
			  . debug mesg
			  . generate debug mesg
			  . raise exception
		. generate if statement to check if the parameter passed = G_ORG_BO_CODE
		  . generate delete statements (by calling genBOSQL(G_ORG_BO_CODE));
		  . if previous delete statement generation is successfull
			  . generate commit statement
			  . generate debug mesg
		  . if previous delete statement generation is un-successfull
			  . debug mesg
			  . generate debug mesg
			  . raise exception
		. generate if statement to check if the parameter passed = G_PER_CUST_BO_CODE
		  . generate delete statements (by calling genBOSQL(G_PER_CUST_BO_CODE));
		  . if previous delete statement generation is successfull
			  . generate commit statement
			  . generate debug mesg
		  . if previous delete statement generation is un-successfull
			  . debug mesg
			  . generate debug mesg
			  . raise exception
		. generate if statement to check if the parameter passed = G_ORG_CUST_BO_CODE
		  . generate delete statements (by calling genBOSQL(G_ORG_CUST_BO_CODE));
		  . if previous delete statement generation is successfull
			  . generate commit statement
			  . generate debug mesg
		  . if previous delete statement generation is un-successfull
			  . debug mesg
			  . generate debug mesg
			  . raise exception
	  . generate procedure tail by calling procEnd()
	*/
	-- To write the procedure header
	procBegin (l_procName, l_comment, l_param_name);
	li(' ');
	li('-- local variables');
	li(' ');
	l('BEGIN');
	-- write the code to get BO codes.
	l_msg := l_procName||'()+';
	writeDebugMesg(l_msg, l_gen_prefix);

	li('-- delete root nodes for BOs that are not complete');
	l2i('-- delete statement for '||G_PER_BO_CODE||' BO');
	li(' ');
	-- generate delete statement for Person BO
	li('IF P_BO_CODE ='''||G_PER_BO_CODE||''' THEN');
	-- generate delete statements by calling
	genBOSQL(G_PER_BO_CODE, l_sql_for, l_ret_status);
  IF l_ret_status THEN
	  -- generate a commit statement after each delete stmt
		l2i('   COMMIT; -- commiting the deletes done so far. ');
  	l_msg := 'completeness del stmt executed for '||G_PER_BO_CODE||' BO';
  	writeDebugMesg(l_msg, l_gen_prefix);
		li('END IF; -- end of check for '||G_PER_BO_CODE);
	ELSE
		l_msg := 'Unable to generate the completeness() del stmt for PERSON BO';
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(
			   p_message=>l_msg,
			   p_prefix=>l_prefix,
		     p_msg_level=>fnd_log.level_procedure);
	   END IF;
		-- raise to calling program, in this case BOD API
  	l_msg := 'error generating completeness del stmt for '||G_PER_BO_CODE||' BO';
  	writeDebugMesg(l_msg||sqlerrm, l_gen_prefix);
		fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_DEL_ERROR');
		fnd_message.set_token('BO_CODE', G_PER_BO_CODE);
		fnd_msg_pub.ADD;
		RAISE FND_API.G_EXC_ERROR;
	--		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	li(' ');
	l2i('-- delete statement for '||G_ORG_BO_CODE||' BO');
	-- generate delete statement for Org BO
	li('IF P_BO_CODE ='''||G_ORG_BO_CODE||''' THEN');
	li(' ');
	genBOSQL(G_ORG_BO_CODE, l_sql_for, l_ret_status);
  IF l_ret_status THEN
	  -- generate a commit statement after each delete stmt
		l2i('   COMMIT; -- commiting the deletes done so far.');
  	l_msg := 'completeness del stmt executed for '||G_ORG_BO_CODE||' BO';
  	writeDebugMesg(l_msg, l_gen_prefix);
		li('END IF; -- end of check for '||G_ORG_BO_CODE);
	ELSE
		l_msg := 'Unable to generate the completeness() del stmt for '||G_ORG_BO_CODE||' BO';
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(
			   p_message=>l_msg,
			   p_prefix=>l_prefix,
		     p_msg_level=>fnd_log.level_procedure);
	   END IF;
			-- raise to calling program, in this case BOD API
	  	l_msg := 'error generating completeness del stmt for '||G_ORG_BO_CODE||' ';
	  	writeDebugMesg(l_msg||sqlerrm, l_gen_prefix);
			fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_DEL_ERROR');
			fnd_message.set_token('BO_CODE', G_ORG_BO_CODE);
			fnd_msg_pub.ADD;
			RAISE FND_API.G_EXC_ERROR;
--		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	li(' ');
	l2i('-- delete statement for '||G_PER_CUST_BO_CODE||' BO');
	-- generate delete statement for Person Cust BO
	li('IF P_BO_CODE ='''||G_PER_CUST_BO_CODE||''' THEN');
	li(' ');
	genBOSQL(G_PER_CUST_BO_CODE, l_sql_for, l_ret_status);
  IF l_ret_status THEN
	  -- generate a commit statement after each delete stmt
		l2i('   COMMIT; -- commiting the deletes done so far.');
  	l_msg := 'completeness del stmt executed for '||G_PER_CUST_BO_CODE||' BO';
  	writeDebugMesg(l_msg, l_gen_prefix);
		li('END IF; -- end of check for '||G_PER_CUST_BO_CODE);
	ELSE
		l_msg := 'Unable to generate the completeness() del stmt for '||G_PER_CUST_BO_CODE||' BO';
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(
			   p_message=>l_msg,
			   p_prefix=>l_prefix,
		     p_msg_level=>fnd_log.level_procedure);
	   END IF;
			-- raise to calling program, in this case BOD API
	  	l_msg := 'error generating completeness del stmt for '||G_PER_CUST_BO_CODE||' ';
	  	writeDebugMesg(l_msg||sqlerrm, l_gen_prefix);
			fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_DEL_ERROR');
			fnd_message.set_token('BO_CODE', G_PER_CUST_BO_CODE);
			fnd_msg_pub.ADD;
			RAISE FND_API.G_EXC_ERROR;
--		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	li(' ');
	l2i('-- delete statement for '||G_ORG_CUST_BO_CODE||' BO');
	-- generate delete statement for Org Cust BO
	li('IF P_BO_CODE ='''||G_ORG_CUST_BO_CODE||''' THEN');
	li(' ');
	genBOSQL(G_ORG_CUST_BO_CODE, l_sql_for, l_ret_status);
  IF l_ret_status THEN
	  -- generate a commit statement after each delete stmt
		l2i('   COMMIT; -- commiting the deletes done so far.');
  	l_msg := 'completeness del stmt executed for '||G_ORG_CUST_BO_CODE||' BO';
  	writeDebugMesg(l_msg, l_gen_prefix);
		li('END IF; -- end of check for '||G_PER_CUST_BO_CODE);
	ELSE
		l_msg := 'Unable to generate the completeness() del stmt for '||G_ORG_CUST_BO_CODE||' BO';
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(
			   p_message=>l_msg,
			   p_prefix=>l_prefix,
		     p_msg_level=>fnd_log.level_procedure);
	   END IF;
		-- raise to calling program, in this case BOD API
  	l_msg := 'error generating completeness del stmt for '||G_ORG_CUST_BO_CODE||' ';
  	writeDebugMesg(l_msg||sqlerrm, l_gen_prefix);
			fnd_message.set_name('AR', 'HZ_BES_BO_COMPLETE_DEL_ERROR');
			fnd_message.set_token('BO_CODE', G_ORG_CUST_BO_CODE);
			fnd_msg_pub.ADD;
			RAISE FND_API.G_EXC_ERROR;
--		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	l_msg := l_procName||'()-';
	writeDebugMesg(l_msg, l_gen_prefix);

	procEnd(l_procName);
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.DEBUG (
			p_message=>'genCompletenessProc()-',
	    p_prefix=>l_prefix,
    	p_msg_level=>fnd_log.level_procedure);
  END IF;
END genCompletenessProc;

----------------------------------------------------------------------------
/* 	PROCEDURE: genEvtTypeProc
   Purpose: This procedure is to generate the event type check procedure(s) for
	 	high level business objects - ORG, PERSON, ORG_CUST, PERSON_CUST.
	 Called from: This package
	 Called by: gen_pkg_body()

*/
PROCEDURE genEvtTypeProc IS
-- local variable for procedure name
l_procName VARCHAR2(30) := 'BO_EVENT_CHECK';
l_comment  VARCHAR2(100) := 'To determine event type of BOs.';
l_msg      VARCHAR2(150);
l_prefix   VARCHAR2(15) := 'GENEVTSQL'; -- holds the debug prefix for this procedure
l_gen_prefix VARCHAR2(15) := 'EVTSQL';  -- holds the debug prefix for generated proc
l_ret_status  BOOLEAN := TRUE;
l_sql_for VARCHAR2(30) := 'EVENT';
l_param_name VARCHAR2(30) := 'P_BO_CODE';

BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'genEvtTypeProc()+',
	                       p_prefix=>l_prefix,
    			               p_msg_level=>fnd_log.level_procedure);
  END IF;

/*
This procedure will generate BO_EVT_CHECK() procedure in HZ_BES_BO_SITE_UTIL_PKG
package. The BO_EVT_CHECK() procedure will take P_BO_CODE as a parameter.
For each BO, a separate Update statement must be generated. Each of this update
statement will update all those rows that are candidates for Update event.
This update statement will go after all those records for which the event type
must be identified.
 Flow:
  . generate procedure header by calling procBegin()
  . generate debug mesg
  . get BO Codes
 . generate if condition on P_BO_CODE = PERSON
	 . For PERSON BO generate the update statement
	 . add debug mesg
	 . generate COMMIT statement
	 . add debug mesg
 . generate else if condition on P_BO_CODE = ORG
	 . For ORG BO generate the update statement
	 . add debug mesg
	 . generate COMMIT statement
	 . add debug mesg
 . generate else if condition on P_BO_CODE = PERSON_CUST
	 . For PERSON_CUST BO generate the update statement
	 . add debug mesg
	 . generate COMMIT statement
	 . add debug mesg
 . generate else if condition on P_BO_CODE = ORG_CUST
	 . For ORG_CUST BO generate the update statement
	 . add debug mesg
	 . generate COMMIT statement
	 . add debug mesg
 . generate else condition
	 . add debug mesg
	 . generate raise exception statement.
 . generate end if statement
 . generate the procedure tail

*/
	-- To write the procedure header
	procBegin (l_procName, l_comment, l_param_name);
	li(' ');
	l('BEGIN');
	-- write the code to get BO codes.
	l_msg := l_procName||'()+';
	writeDebugMesg(l_msg, l_gen_prefix);
	-- generate delete statements by calling
	li('-- update nodes for BOs that are already complete');
	li('-- update statement for '||G_PER_BO_CODE||' BO');
	li(' ');
	-- generate update statement for Person BO
	li('IF P_BO_CODE ='''||G_PER_BO_CODE||''' THEN');
	genBOSQL(G_PER_BO_CODE, l_sql_for, l_ret_status);
  IF l_ret_status THEN
	  -- generate a commit statement after each delete stmt
		li(' COMMIT; -- commiting the updates done so far for '||G_PER_BO_CODE);
  	l_msg := 'evt type update stmt executed for '||G_PER_BO_CODE||' BO';
  	writeDebugMesg(l_msg, l_gen_prefix);
		li('END IF; -- end of check for '||G_PER_BO_CODE);
	ELSE
		l_msg := 'Unable to generate the evt type upd stmt for PERSON BO';
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(
			   p_message=>l_msg,
			   p_prefix=>l_prefix,
		     p_msg_level=>fnd_log.level_procedure);
	   END IF;
		-- raise to calling program, in this case BOD API
  	l_msg := 'error generating evt type upd stmt for '||G_PER_BO_CODE||' BO';
  	writeDebugMesg(l_msg||sqlerrm, l_gen_prefix);
			fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_UPDATE_ERROR');
			fnd_message.set_token('BO_CODE', G_PER_BO_CODE);
			fnd_msg_pub.ADD;
			RAISE FND_API.G_EXC_ERROR;
--		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- generate update statement for Org BO
	li(' ');
	li('IF P_BO_CODE ='''||G_ORG_BO_CODE||''' THEN');
	genBOSQL(G_ORG_BO_CODE, l_sql_for, l_ret_status);
  IF l_ret_status THEN
	  -- generate a commit statement after each delete stmt
		li(' COMMIT; -- commiting the updates done so far for '||G_ORG_BO_CODE);
  	l_msg := 'evt type update stmt executed for '||G_ORG_BO_CODE||' BO';
  	writeDebugMesg(l_msg, l_gen_prefix);
		li('END IF; -- end of check for '||G_ORG_BO_CODE);
	ELSE
		l_msg := 'Unable to generate the evt type upd stmt for Org BO';
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(
			   p_message=>l_msg,
			   p_prefix=>l_prefix,
		     p_msg_level=>fnd_log.level_procedure);
	   END IF;
		-- raise to calling program, in this case BOD API
  	l_msg := 'error generating evt type upd stmt for '||G_ORG_BO_CODE||' BO';
  	writeDebugMesg(l_msg||sqlerrm, l_gen_prefix);
			fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_UPDATE_ERROR');
			fnd_message.set_token('BO_CODE', G_ORG_BO_CODE);
			fnd_msg_pub.ADD;
			RAISE FND_API.G_EXC_ERROR;
	END IF;
	-- generate update statement for Person Customer BO
	li('IF P_BO_CODE ='''||G_PER_CUST_BO_CODE||''' THEN');
	genBOSQL(G_PER_CUST_BO_CODE, l_sql_for, l_ret_status);
  IF l_ret_status THEN
	  -- generate a commit statement after each delete stmt
		li(' COMMIT; -- commiting the updates done so far for '||G_PER_CUST_BO_CODE);
  	l_msg := 'evt type update stmt executed for '||G_PER_CUST_BO_CODE||' BO';
  	writeDebugMesg(l_msg, l_gen_prefix);
		li('END IF; -- end of check for '||G_PER_CUST_BO_CODE);
	ELSE
		l_msg := 'Unable to generate the evt type upd stmt for Person Customer BO';
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(
			   p_message=>l_msg,
			   p_prefix=>l_prefix,
		     p_msg_level=>fnd_log.level_procedure);
	   END IF;
		-- raise to calling program, in this case BOD API
  	l_msg := 'error generating evt type upd stmt for '||G_PER_CUST_BO_CODE||' BO';
  	writeDebugMesg(l_msg||sqlerrm, l_gen_prefix);
			fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_UPDATE_ERROR');
			fnd_message.set_token('BO_CODE', G_PER_CUST_BO_CODE);
			fnd_msg_pub.ADD;
			RAISE FND_API.G_EXC_ERROR;
	END IF;
	-- generate update statement for Org Customer BO
	li('IF P_BO_CODE ='''||G_ORG_CUST_BO_CODE||''' THEN');
	genBOSQL(G_ORG_CUST_BO_CODE, l_sql_for, l_ret_status);
  IF l_ret_status THEN
	  -- generate a commit statement after each delete stmt
		li(' COMMIT; -- commiting the updates done so far for '||G_ORG_CUST_BO_CODE);
  	l_msg := 'evt type update stmt executed for '||G_ORG_CUST_BO_CODE||' BO';
  	writeDebugMesg(l_msg, l_gen_prefix);
		li('END IF; -- end of check for '||G_ORG_CUST_BO_CODE);
	ELSE
		l_msg := 'Unable to generate the evt type upd stmt for Person Customer BO';
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(
			   p_message=>l_msg,
			   p_prefix=>l_prefix,
		     p_msg_level=>fnd_log.level_procedure);
	   END IF;
		-- raise to calling program, in this case BOD API
  	l_msg := 'error generating evt type upd stmt for '||G_ORG_CUST_BO_CODE||' BO';
  	writeDebugMesg(l_msg||sqlerrm, l_gen_prefix);
			fnd_message.set_name('AR', 'HZ_BES_BO_EVTYPE_UPDATE_ERROR');
			fnd_message.set_token('BO_CODE', G_ORG_CUST_BO_CODE);
			fnd_msg_pub.ADD;
			RAISE FND_API.G_EXC_ERROR;
	END IF;
	l_msg := l_procName||'()-';
	writeDebugMesg(l_msg, l_gen_prefix);

	procEnd(l_procName);
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.DEBUG (
			p_message=>'genEvtTypeProc()-',
	    p_prefix=>l_prefix,
    	p_msg_level=>fnd_log.level_procedure);
  END IF;
END genEvtTypeProc;


----------------------------------------------------------------------------
/* 	PROCEDURE: gen_pkg_body
   Purpose: this is the umbrella procedure which gets called
	 from the BOD API.
	 This procedure is used to create the entire package and compile it.
	 Called from: Both BOD update and create APIs will calls this.
	 Called by: bo_gen_main()

*/
	PROCEDURE gen_pkg_body
     (P_STATUS OUT  NOCOPY BOOLEAN)
	IS
  l_debug_prefix    VARCHAR2(15) := 'GENPKG:';
  l_pkg_name        VARCHAR2(30) := 'HZ_BES_BO_SITE_UTIL_PKG';
	BEGIN -- gen_pkg_body
  if fnd_log.level_procedure>=fnd_log.g_current_runtime_level then
	hz_utility_v2pub.debug(p_message=>'gen_pkg_body()+',
	                       p_prefix=>l_debug_prefix,
    			               p_msg_level=>fnd_log.level_procedure);
  end if;

	/*
	Flow:
	  . Generate the genPkgBdyHdr()
	  . Generate the completeness procedure()
	  . Generate the event type procedure()
	  . Generate the pkg body() and compile
	*/
  P_STATUS := FALSE; -- assigning the retun status to error.
  genPkgBdyHdr(l_pkg_name);
	genCompletenessProc();
	genEvtTypeProc();
	genPkgBdyTail(l_pkg_name);

  COMMIT;
  P_STATUS := TRUE; -- assigning the return status to success
  if fnd_log.level_procedure>=fnd_log.g_current_runtime_level then
	hz_utility_v2pub.debug(p_message=>'gen_pkg_body()-',
	                       p_prefix=>l_debug_prefix,
    			               p_msg_level=>fnd_log.level_procedure);
  END IF;

	END ; -- gen_pkg_body()
------------------------------------------------------------------------------

PROCEDURE gen_pkg_main (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2) IS
	-- local variables
	l_ret_status BOOLEAN;

BEGIN

  gen_pkg_body(l_ret_status);

  IF l_ret_status THEN
    retcode := 0; -- setting the return code to success
  ELSE
	  retcode := 2;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    outandlog('Error: Aborting concurrent program');
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    outandlog('Error: Aborting concurrent program');
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
  WHEN OTHERS THEN
    outandlog('Error: Aborting concurrent program');
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
END gen_pkg_main;

END HZ_BES_BO_GEN_PKG; -- end of pkg body

/
