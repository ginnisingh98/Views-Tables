--------------------------------------------------------
--  DDL for Package Body IBY_EMAIL_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EMAIL_REPORT" AS
/*$Header: ibyvmalb.pls 115.2 2002/11/18 22:22:17 jleybovi noship $*/

l_userinfo_tbl   UserInfo_tbl_type := UserInfo_tbl_type();

   -- Function that will return a string in parenthesis if it is
   -- negative.
   FUNCTION get_str( inputVal NUMBER
       ) RETURN VARCHAR2 IS

   returnStr VARCHAR2(200);
   l_value   NUMBER;
   BEGIN

      IF( inputVal is NULL) THEN
         RETURN '0.00';
      END IF;

      l_value := inputVal;
      IF( l_value < 0 ) THEN
         l_value := l_value * -1;
         returnStr := '(' || TO_CHAR(l_value) || ')';
      ELSE
         returnStr := TO_CHAR(l_value);
      END IF;

      RETURN returnStr;

   END get_str;

--1. populate_userinfo

   PROCEDURE populate_userinfo( email_users_str VARCHAR2
       ) IS

   c_delimiter CONSTANT VARCHAR2(1) := ',';
   c_at CONSTANT VARCHAR2(1) := '@';

   l_char_index NUMBER := 1;
   l_loop_index NUMBER := 1;
   pre_delimit_str VARCHAR2(200);
   post_delimit_str VARCHAR2(200);

   BEGIN

      post_delimit_str := TRIM(email_users_str);

      WHILE (l_char_index > 0) LOOP

         -- Check whether the email conatins a ','.
         l_char_index := INSTR( post_delimit_str, c_delimiter);

         IF (l_char_index = 0) THEN
            pre_delimit_str := post_delimit_str;
         ELSE
            pre_delimit_str := TRIM(SUBSTR(post_delimit_str, 1, l_char_index - 1));
            post_delimit_str := TRIM(SUBSTR(post_delimit_str, l_char_index + 1));
         END IF;

         IF ( LENGTH(pre_delimit_str) <> 0) THEN

             -- Extend the table by one index each time.
             l_userinfo_tbl.EXTEND;

             IF INSTR( pre_delimit_str, c_at) > 0 THEN
                l_userinfo_tbl(l_loop_index).username := NULL;
                l_userinfo_tbl(l_loop_index).emailaddr := pre_delimit_str;
                l_userinfo_tbl(l_loop_index).usertype := C_USERTYPE_ADHOC;
             ELSE
                l_userinfo_tbl(l_loop_index).username := pre_delimit_str;
                l_userinfo_tbl(l_loop_index).emailaddr := NULL;
                l_userinfo_tbl(l_loop_index).usertype := C_USERTYPE_REGISTERED;
             END IF;

             l_loop_index := l_loop_index + 1;

         END IF;

      END LOOP;

   END populate_userinfo;

--------------------------------------------------------------------------------------
        -- 2. Send_Mail
        -- Start of comments
        --   API name        : Send_Mail
        --   Type            : Public
        --   Pre-reqs        : None
        --   Function        : Sends an email report.
        --   Parameters      :
        --   IN              : p_item_key          IN    VARCHAR2
        --                     p_user_name         IN    VARCHAR2
        --
        --   OUT             : x_return_status     OUT   VARCHAR2
        --                     x_msg_count         OUT   VARCHAR2
        --   Version         :
        --                     Current version      1.0
        --                     Previous version     1.0
        --                     Initial version      1.0
        -- End of comments
--------------------------------------------------------------------------------------

--2. Send Mail

   PROCEDURE Send_Mail ( p_item_key      IN  VARCHAR2,
                         p_user_name     IN  VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER
	                 ) IS

   l_param               VARCHAR2(20);
   l_login_url           VARCHAR2(200);
   c_item_type CONSTANT  VARCHAR2(10) := 'IBYPMAIL';
   c_process   CONSTANT  VARCHAR2(15) := 'IBY_PUSH_MAIL';
   c_period    CONSTANT  VARCHAR2(15) := 'DAILY';
   summary_tbl          IBY_DBCCARD_PVT.Summary_tbl_type;
   trxnSum_tbl          IBY_DBCCARD_PVT.TrxnSum_tbl_type;

   BEGIN


      -- Get the details first.
      IBY_DBCCARD_PVT.Get_Trxn_Summary( NULL,
                                        c_period,
                                        summary_tbl,
                                        trxnSum_tbl
                                       );

      -- Create the process first.
	wf_engine.CreateProcess(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		process  	=> c_process
	);

	wf_engine.SetItemUserKey(
		itemtype	=> c_item_type,
		itemkey	=> p_item_key,
		userkey	=> p_item_key
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_TRXN',
		avalue	=> get_str(summary_tbl(1).totalTrxn)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_TRXN_AMT',
		avalue	=> get_str(summary_tbl(1).totalAmt)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_AUTH',
		avalue	=> get_str(summary_tbl(2).totalTrxn)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_AUTH_AMT',
		avalue	=> get_str(summary_tbl(2).totalAmt)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_CAPT',
		avalue	=> get_str(summary_tbl(3).totalTrxn)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_CAPT_AMT',
		avalue	=> get_str(summary_tbl(3).totalAmt)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_RC',
		avalue	=> get_str(summary_tbl(4).totalTrxn)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_RC_AMT',
		avalue	=> get_str(summary_tbl(4).totalAmt)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_AUTH_SET',
		avalue	=> get_str(summary_tbl(5).totalTrxn)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_AUTH_SET_AMT',
		avalue	=> get_str(summary_tbl(5).totalAmt)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_AUTH_OUT',
		avalue	=> get_str(summary_tbl(6).totalTrxn)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_AUTH_OUT_AMT',
		avalue	=> get_str(summary_tbl(6).totalAmt)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_CC_TRXN',
		avalue	=> get_str(summary_tbl(7).totalTrxn)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_CC_TRXN_AMT',
		avalue	=> get_str(summary_tbl(7).totalAmt)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_PC_TRXN',
		avalue	=> get_str(summary_tbl(8).totalTrxn)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'TOTAL_PC_TRXN_AMT',
		avalue	=> get_str(summary_tbl(8).totalAmt)
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'SYSDATE',
		avalue	=> TO_CHAR(SYSDATE, 'MON/DD/YYYY HH24:MI:SS')
	);

      l_login_url := FND_WEB_CONFIG.JSP_AGENT() || 'jtflogin.jsp';

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname	      => 'LOGIN_URL',
		avalue	=> l_login_url
	);

	wf_engine.SetItemAttrText(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key,
		aname   	=> 'RECIPIENT_USER',
		avalue	=> p_user_name
	);

	wf_engine.SetItemOwner(
		itemtype	=> c_item_type,
		itemkey	=> p_item_key,
		owner	=> 'SYSADMIN'
	);

	wf_engine.StartProcess(
		itemtype 	=> c_item_type,
		itemkey  	=> p_item_key
	);

      -- Commit the process trigger.
      COMMIT;


   Exception

	When OTHERS Then
		x_return_status := FND_API.g_ret_sts_error;
		x_msg_count := 0;

   END Send_Mail;

--------------------------------------------------------------------------------------
        -- 3. Send_Report
        -- Start of comments
        --   API name        : Send_Report
        --   Type            : Public
        --   Pre-reqs        : None
        --   Function        : Implements Concurrent Program.
        --   Parameters      :
        --   IN              : p_email_users       IN    VARCHAR2
        --
        --   OUT             : ERRBUF              OUT   VARCHAR2
        --                     RETCODE             OUT   NUMBER
        --   Version         :
        --                     Current version      1.0
        --                     Previous version     1.0
        --                     Initial version      1.0
        -- End of comments
--------------------------------------------------------------------------------------

-- 3. Send_Report

   Procedure Send_Report(ERRBUF              OUT NOCOPY VARCHAR2,
                         RETCODE             OUT NOCOPY NUMBER,
                         p_email_users       IN    VARCHAR2
                        ) IS

   c_notipref_html CONSTANT VARCHAR2(10) := 'MAILHTML';
   c_itemkey_prefix CONSTANT VARCHAR2(10):= 'IBYPMAIL';
   c_username_prefix CONSTANT VARCHAR2(10) := 'IBYPMAIL';

   l_key_seq       NUMBER;
   l_return_status VARCHAR2(200);
   l_msg_count     NUMBER;
   l_adhoc_name    VARCHAR2(100);

   BEGIN

      IF(l_userinfo_tbl.COUNT > 0) THEN
         l_userinfo_tbl.TRIM(l_userinfo_tbl.COUNT);
      END IF;

      -- Populate the instance table with the user details.
      populate_userinfo(p_email_users);

      FOR i IN 1..l_userinfo_tbl.COUNT LOOP

         -- Get the next value in the sequence.
         -- It will be appended to the userkey and username.
         SELECT iby_pushmail_key_s.NEXTVAL
         INTO   l_key_seq
         FROM   DUAL;

         -- Check whether we need to create adhoc user.
         -- We need to create an adhoc user only if the user is not registered already.
         -- Once created, then assign the username to the userinfo.
         IF ( l_userinfo_tbl(i).usertype = C_USERTYPE_ADHOC) THEN

            l_adhoc_name := c_username_prefix || l_key_seq;

            wf_directory.CreateAdHocUser(
	         name                    =>  l_adhoc_name,
	         display_name            =>  l_adhoc_name,
	         notification_preference =>  c_notipref_html,
               email_address	         =>  l_userinfo_tbl(i).emailaddr,
	         expiration_date         =>  SYSDATE + 1,
	         language	               =>  userenv('LANG')
		   );

            l_userinfo_tbl(i).username := l_adhoc_name;

          END IF;

          Send_Mail( c_itemkey_prefix || l_key_seq,
                     l_userinfo_tbl(i).username,
                     l_return_status,
                     l_msg_count
                   );

          -- Set the status to success.
          RETCODE := 0;

       END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         ERRBUF := SQLERRM;
         RETCODE := 2;

   END Send_Report;

END IBY_EMAIL_REPORT;


/
