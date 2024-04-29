--------------------------------------------------------
--  DDL for Package Body INV_TM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TM" AS
/* $Header: INVTMB.pls 120.1 2005/07/01 13:07:05 appldev ship $ */
--  FUNCTION launch
--  This function would call the inventory concurrent manager
--  to process a transaction in synchronous mode.
--
--  Input Parameters:
--      program - the concurrent manager program name
--      args    - use to pass the transaction header id
--      put1-5  - input parameters, default value = NULL
--      get1-5  - input parameters for fnd_transactions.get_values
--      timeout - timeout limit
--      rc_field - error code with the following possible values:
--                    - 0 means success
--                    - 1 means time out
--                    - 2 means concurrent manager is not available
--                    - 3 means no concurrent manager is defined
--
--    Return:
--      a boolean               TRUE if succeed, FALSE otherwise
--

   FUNCTION launch(program in varchar2,
                   args in varchar2 default NULL,
                   put1 in varchar2 default NULL,
                   put2 in varchar2 default NULL,
                   put3 in varchar2 default NULL,
                   put4 in varchar2 default NULL,
                   put5 in varchar2 default NULL,
                   get1 in varchar2 default NULL,
                   get2 in varchar2 default NULL,
                   get3 in varchar2 default NULL,
                   get4 in varchar2 default NULL,
                   get5 in varchar2 default NULL,
                   timeout in number default NULL,
                   rc_field in varchar2 default NULL)
   RETURN BOOLEAN
   IS
     outcome VARCHAR(80);
     msg VARCHAR(255);
     rtvl NUMBER;
     args1 VARCHAR(240);
     args2 VARCHAR(240);
     args3 VARCHAR(240);
     args4 VARCHAR(240);
     args5 VARCHAR(240);
     args6 VARCHAR(240);
     args7 VARCHAR(240);
     args8 VARCHAR(240);
     args9 VARCHAR(240);
     args10 VARCHAR(240);
     args11 VARCHAR(240);
     args12 VARCHAR(240);
     args13 VARCHAR(240);
     args14 VARCHAR(240);
     args15 VARCHAR(240);
     args16 VARCHAR(240);
     args17 VARCHAR(240);
     args18 VARCHAR(240);
     args19 VARCHAR(240);
     args20 VARCHAR(240);
     prod VARCHAR(240);
     func VARCHAR(240);
     m_message VARCHAR2(2000);
     p_userid  NUMBER;
     p_respid  NUMBER;
     p_applid  NUMBER;
     rpc_timeout NUMBER;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
   -- load values for field gets;
   args12 := null;
   args13 := null;
   args14 := null;
   args15 := null;
   args16 := null;

/*
   -- initialize profile
   p_userid := 1001;  --hardcoded at vision
   p_respid := 20634; --hardcoded to inventory in 11.5
   p_applid := 401;   --hardcoded to inventory
   fnd_global.apps_initialize(p_userid, p_respid, p_applid);
*/

   if timeout is NULL then
     rpc_timeout := to_number(fnd_profile.value('INV_RPC_TIMEOUT'));
   else
     rpc_timeout := timeout;
   end if;

   prod := 'INV';
   func := program;

   rtvl := fnd_transaction.synchronous
     (
      NVL(rpc_timeout,500),outcome, msg, prod,func, args,
      put1, put2, put3, put4, put5,
      get1, get2, get3, get4, get5,
      args12,  args13,  args14,  args15,  args16,
      chr(0), '', '', '');

   /* dbms_output.put_line('fnd_transaction.synchrous return: outcome is '
          ||NVL(outcome,'NULL') || ' and rtvl is ' ||To_char(rtvl)); */

   -- handle problems

   --rc_field := rtvl;
   IF rtvl = 1 THEN
      --     FND_Message.debug('Remote Call Failed: Timed-Out');
      fnd_message.set_name('INV', 'INV_TM_TIME_OUT');
      fnd_msg_pub.add;
      -- dbms_output.put_line(fnd_message.get);
      -- dbms_output.put_line('timeout');
      RETURN (FALSE);
   ELSIF  rtvl = 2 THEN
      --     FND_Message.debug('Remote Call Failed: Manager Unavailable');
      -- dbms_output.put_line('Error in INVTM: '|| fnd_message.get);
      -- dbms_output.put_line('no meessage from dbms_pipe, manager unavailable');
      fnd_message.set_name('INV', 'INV_TM_MGR_NOT_AVAIL');
      fnd_msg_pub.add;
      RETURN (FALSE);
   ELSIF rtvl = 3 THEN
      fnd_message.set_name('FND','CONC-DG-Inactive No Manager');
      fnd_msg_pub.add;
      RETURN(FALSE);
/*
   ELSIF  rtvl = 0 THEN
      -- get info back from server and handle problems
--      rtvl := fnd_transaction.get_values
--        (args1, args2, args3, args4, args5,
--         args6, args7, args8, args9, args10, args11,
--         args12, args13, args14, args15,
--         args16, args17, args18, args19, args20);
      -- dbms_output.put_line('syn call: '||To_char(rtvl));
*/
   END IF;
/*
   IF (args1 IS NOT NULL) THEN
      dbms_output.put_line(args1);
   END IF;
   IF (args2 IS NOT NULL) THEN
      dbms_output.put_line(args2);
   END IF;
   IF (args3 IS NOT NULL) THEN
      dbms_output.put_line(args3);
   END IF;
   IF (args4 IS NOT NULL) THEN
      dbms_output.put_line(args4);
   END IF;
   IF (args5 IS NOT NULL) THEN
      dbms_output.put_line(args5);
   END IF;
   IF (args6 IS NOT NULL) THEN
      dbms_output.put_line(args6);
   END IF;
   IF (args7 IS NOT NULL) THEN
      dbms_output.put_line(args7);
   END IF;
   IF (args8 IS NOT NULL) THEN
      dbms_output.put_line(args8);
   END IF;
   IF (args9 IS NOT NULL) THEN
      dbms_output.put_line(args9);
   END IF;
   IF (args10 IS NOT NULL) THEN
      dbms_output.put_line(args10);
   END IF;
*/

   -- Kick back status
   IF (outcome = 'SUCCESS' and rtvl = 0 ) THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
   END IF;
   END launch;
END inv_tm;

/
