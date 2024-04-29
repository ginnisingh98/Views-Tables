--------------------------------------------------------
--  DDL for Package Body PO_MESSAGE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MESSAGE_S" AS
-- $Header: PO_MESSAGE_S.plb 120.5 2006/01/12 11:29:16 arusingh noship $

-- Read the profile option that enables/disables the debug log
g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;


--------------------------------------------------------------------------------
--Start of Comments
--Name: sql_error
--Pre-reqs:
--    N/A
--Modifies:
--  FND_LOG_MESSAGES
--  FND Message Stack
--Locks:
--  N/A
--Function:
--  This procedure sets a message describing a SQL error onto the
--  server-side FND message stack
--  Additionally, if debug logging is enabled, a message is also
--  recorded in the FND_LOG_MESSAGES table
--Parameters:
--IN:
--routine
--  The name of the calling procedure
--  Used to identify the FND log record
--location
--  The location within the calling procedure at which the SQL error occured
--  Used to identify the FND log record
--error_code
--  The ORA code associated with a particular SQL exception
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE SQL_ERROR(routine IN varchar2 ,
                    location IN varchar2,
                    error_code IN number) IS
BEGIN

--<ENCUMBRANCE FPJ: refactored this procedure to call new sig of SQL_ERROR>
        SQL_ERROR(
           p_package  => 'po_message_s'
        ,  p_routine  => routine
        ,  p_location => location
        ,  p_sqlcode  => error_code
        ,  p_sqlerrm  => SQLERRM(error_code)
        );

EXCEPTION
   WHEN OTHERS THEN RAISE;
END SQL_ERROR;


--------------------------------------------------------------------------------
--Start of Comments
--Name: sql_error
--Pre-reqs:
--    N/A
--Modifies:
--  FND_LOG_MESSAGES
--  FND Message Stack
--Locks:
--  N/A
--Function:
--  This procedure sets a message describing a SQL error onto the
--  server-side FND message stack
--  Additionally, if debug logging is enabled, a message is also
--  recorded in the FND_LOG_MESSAGES table
--Parameters:
--IN:
--p_package
--  The name of the calling package
--  Used to identify the FND log record
--p_procedure
--  The name of the calling procedure
--  Used to identify the FND log record
--p_location
--  The location within the calling procedure at which the SQL error occured
--  Used to identify the FND log record
--p_sqlcode
--  The ORA code associated with a particular SQL exception
--p_sqlerrm
--  The standard description associated with a particular SQL exception
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE SQL_ERROR(
  p_package  IN varchar2
, p_routine  IN varchar2
, p_location IN varchar2
, p_sqlcode  IN number
, p_sqlerrm  IN varchar
--<ENCUMBRANCE FPJ: created new, overloaded sig for this procedure>
)
IS
   l_log_head  VARCHAR2(240) := substrb('po.plsql.' || p_package
                                         || '.' || p_routine
                                       , 1, 240);
   l_error_msg VARCHAR2(240) := substrb(SQLERRM, 1, 240);
BEGIN

   IF (g_routine is NULL) THEN

      g_routine  := p_routine;
      g_location := p_location;

      FND_MESSAGE.set_name('PO', PO_ALL_SQL_ERROR);
      FND_MESSAGE.set_token(c_ROUTINE_token, p_routine);
      FND_MESSAGE.set_token(c_ERR_NUMBER_token, p_location);
      FND_MESSAGE.set_token(c_SQL_ERR_token, l_error_msg);
      FND_MESSAGE.set_token(c_LSQL_ERR_token, SQLERRM);

   END IF;

   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, p_location);
   END IF;

EXCEPTION
   WHEN OTHERS THEN RAISE;
END SQL_ERROR;


PROCEDURE APP_ERROR(error_name IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';
          FND_MESSAGE.set_name('PO',error_name);
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';

          FND_MESSAGE.set_name('PO',error_name);

          IF (token1 is not NULL and value1 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token1,value1);
          END IF;

          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2,
                    token2 IN varchar2,
                    value2 IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';

          FND_MESSAGE.set_name('PO',error_name);

          IF (token1 is not NULL and value1 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token1,value1);
          END IF;

          IF (token2 is not NULL and value2 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token2,value2);
          END IF;

          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2,
                    token2 IN varchar2,
                    value2 IN varchar2,
                    token3 IN varchar2,
                    value3 IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';

          FND_MESSAGE.set_name('PO',error_name);

          IF (token1 is not NULL and value1 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token1,value1);
          END IF;

          IF (token2 is not NULL and value2 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token2,value2);
          END IF;

          IF (token3 is not NULL and value3 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token3,value3);
          END IF;

          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2,
                    token2 IN varchar2,
                    value2 IN varchar2,
                    token3 IN varchar2,
                    value3 IN varchar2,
                    token4 IN varchar2,
                    value4 IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';

          FND_MESSAGE.set_name('PO',error_name);

          IF (token1 is not NULL and value1 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token1,value1);
          END IF;

          IF (token2 is not NULL and value2 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token2,value2);
          END IF;

          IF (token3 is not NULL and value3 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token3,value3);
          END IF;

          IF (token4 is not NULL and value4 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token4,value4);
          END IF;

          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_SET_NAME(error_name IN varchar2) IS
BEGIN
        IF (g_routine  is null) THEN
          g_routine  := 'ERROR';
          FND_MESSAGE.set_name('PO',error_name);
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_SET_NAME;

PROCEDURE clear IS
BEGIN
  g_routine  := NULL;
  g_location := NULL;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END CLEAR;

PROCEDURE SQL_SHOW_ERROR IS
BEGIN
    NULL;
/*
	dbms_output.put_line ('Error Occured in routine : ' ||
		g_routine || ' - Location : ' || g_location);
*/
EXCEPTION
  WHEN OTHERS THEN RAISE;
END SQL_SHOW_ERROR;


-- Bug 3516763: created function get_fnd_msg_pub_last
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_fnd_msg_pub_last
--Pre-reqs:
--    N/A
--Modifies:
--    N/A
--Locks:
--  N/A
--Function:
--  This function gets the string value of the last message on the
--  API message list [fnd_msg_pub].
--Parameters:
--IN:
--  N/A
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION GET_FND_MSG_PUB_LAST RETURN varchar2
IS
BEGIN
  return FND_MSG_PUB.get( p_encoded   => FND_API.G_FALSE
                        , p_msg_index => FND_MSG_PUB.G_LAST
                        );
EXCEPTION
  WHEN OTHERS THEN RAISE;
END GET_FND_MSG_PUB_LAST;



--------------------------------------------------------------------------------
--Start of Comments
--Name: add_exc_msg
--Pre-reqs:
--    N/A
--Modifies:
--    N/A
--Locks:
--  N/A
--Function:
--  Wrapper to FND_MSG_PUB.add_exc_msg. This procedure logs the same msg
--  we are putting to FND msg stack
--Parameters:
--IN:
--p_pkg_name
--  package name that logs this msg
--p_procedure_name
--  procedure name that logs this msg
--p_error_text
--  Error description
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_exc_msg
(   p_pkg_name		IN VARCHAR2,
    p_procedure_name	IN VARCHAR2,
    p_error_text	IN VARCHAR2
) IS

d_module VARCHAR2(100) := p_pkg_name || '.' || p_procedure_name;

l_msg FND_NEW_MESSAGES.message_text%TYPE;

BEGIN

  FND_MSG_PUB.add_exc_msg
  ( p_pkg_name => p_pkg_name
  , p_procedure_name => p_procedure_name
  , p_error_text => p_error_text
  );

  -- get the message just inserted
  l_msg := FND_MSG_PUB.get
           ( p_msg_index => FND_MSG_PUB.count_msg
             , p_encoded => FND_API.G_FALSE
           );

  -- no need to specify progress because d_module should have included it
  PO_LOG.exc(d_module, NULL, l_msg);


END add_exc_msg;


-- <PDOI Rewrite R12 START>
--------------------------------------------------------------------------------
--Start of Comments
--Name: concat_fnd_messages_in_stack
--Pre-reqs:
--    N/A
--Modifies:
--    N/A
--Locks:
--  N/A
--Function:
--  Concatenates all messages in FND_MSG_PUB stack with the max size specified
--  as parameter
--Parameters:
--IN:
--p_max_size
--  maximum size alloweded for the returning concatenated message text
--OUT:
--  result string to be returned
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE concat_fnd_messages_in_stack
( p_max_size IN NUMBER,
  x_message_text OUT NOCOPY VARCHAR2
) IS

l_msg_temp VARCHAR2(2000);

BEGIN
  FOR i IN 1..FND_MSG_PUB.count_msg LOOP
    l_msg_temp := FND_MSG_PUB.get
                  ( p_msg_index => i,
                    p_encoded => 'F'
                  );

    x_message_text := SUBSTRB(x_message_text || l_msg_temp || '   ',
                              p_max_size);
  END LOOP;
END concat_fnd_messages_in_stack;
-- <PDOI Rewrite R12 START>

END PO_MESSAGE_S;

/
