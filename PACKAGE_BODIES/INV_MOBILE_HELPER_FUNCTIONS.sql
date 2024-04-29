--------------------------------------------------------
--  DDL for Package Body INV_MOBILE_HELPER_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MOBILE_HELPER_FUNCTIONS" AS
/* $Header: INVMTXHB.pls 120.1 2005/06/17 09:52:21 appldev  $*/

--  Global constant holding the package name
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'inv_mobile_helper_functions';

g_debug_init                  BOOLEAN := FALSE;
g_fd                          utl_file.file_type;
g_trace_on                    NUMBER := 0;          -- Log ON state


PROCEDURE tracelog (p_err_msg IN VARCHAR2,
		    p_module IN VARCHAR2,
		    p_level IN NUMBER := 9)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  -- Consolidated to one trace log api
  IF (l_debug = 1) THEN
     INV_LOG_UTIL.TRACE(p_err_msg, p_module, p_level);
  END IF;
END TraceLog;




PROCEDURE SQL_ERROR(routine IN varchar2 ,
                    location IN varchar2,
                    error_code IN number) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   FND_MESSAGE.set_name('INV', 'INV_ALL_SQL_ERROR');
   FND_MESSAGE.set_token('ROUTINE', routine);
   FND_MESSAGE.set_token('ERR_NUMBER', location);
   FND_MESSAGE.set_token('SQL_ERR', SQLERRM(error_code));
   fnd_msg_pub.ADD;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END SQL_ERROR;


PROCEDURE get_stacked_messages(x_message OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
  IS
     l_message VARCHAR2(2000);
     l_msg_count NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   fnd_msg_pub.Count_And_Get
     (p_encoded	=> FND_API.g_false,
      p_count => l_msg_count,
      p_data => l_message
      );

   IF l_msg_count > 1 THEN
      FOR i IN 1..l_msg_count LOOP
	 l_message := substr((l_message || '|' || FND_MSG_PUB.GET(p_msg_index => l_msg_count - i + 1,
							  p_encoded	=> FND_API.g_false)),1,2000);
      END LOOP;
   END IF;

   fnd_msg_pub.delete_msg;

   x_message := l_message;

EXCEPTION
   WHEN OTHERS THEN
      NULL;
END get_stacked_messages;


END inv_mobile_helper_functions;

/
