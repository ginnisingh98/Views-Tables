--------------------------------------------------------
--  DDL for Package Body POS_GLOBAL_VARS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_GLOBAL_VARS_SV" AS
/* $Header: POSMESGB.pls 115.1 99/10/01 09:14:56 porting ship $*/






  /* -------------- Public Procedure Implementation -------------- */

  /* InitializeMessageArray
   * ----------------------
   */
  PROCEDURE InitializeMessageArray IS

    CURSOR c_messageName IS
      select distinct m.message_name
        from fnd_new_messages m,
             fnd_application a
       where m.message_name like 'ICX_POS%'
         and m.application_id = a.application_id
         and a.application_short_name = 'ICX';

    v_messageText VARCHAR2(2000);
    v_c_info      c_messageName%ROWTYPE;
    x_progress    VARCHAR2(3);

  BEGIN

    OPEN c_messageName;

    htp.p('FND_MESSAGES = new Object();');
    LOOP

      FETCH c_messageName INTO v_c_info;
      EXIT WHEN c_messageName%NOTFOUND;

      x_progress := '001';
      v_messageText := fnd_message.get_string('ICX', v_c_info.message_name);

      -- replace carriage return with \n for javascript.

      v_messageText := replace(v_messageText, '
', '\n');

      htp.p('FND_MESSAGES["' || v_c_info.message_name ||
            '"] = ' || '"' || v_messageText || '";' );

    END LOOP;

    CLOSE c_messageName;



  EXCEPTION
    WHEN OTHERS THEN
      -- should probably close the cursor if it is already open.
      -- also need some trace messages
      NULL;


  END InitializeMessageArray;



  /* InitializeOtherVars
   * -------------------
   */
  PROCEDURE InitializeOtherVars(p_scriptName VARCHAR2) IS
  BEGIN

    htp.p('var scriptName = "' || p_scriptName || '";');
    htp.p('var whereAmI = "SELECT";');
    htp.p('top.IS_TOP = true;');

  END InitializeOtherVars;


END POS_GLOBAL_VARS_SV;

/
