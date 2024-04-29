--------------------------------------------------------
--  DDL for Package Body MWA_NOTIFICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MWA_NOTIFICATION_API" as
/* $Header: MWANOTB.pls 120.1 2005/06/10 11:38:55 appldev  $ */

-- Global constant holding package name
g_pkg_name constant varchar2(50) := 'MWA_NOTIFICATION_API';

   procedure replaceChars(url IN OUT nocopy varchar2) as
   begin
     for v_counter in 1..NUM_RECORDS loop
       url := REPLACE(url,
               escapeRecord(v_counter).replace_char,
               escapeRecord(v_counter).replacement_char);
     end loop;
   end replaceChars;

   function  calculateLength (str IN varchar2) return varchar2 as
     len number;
     counter number;
     encoded_length varchar2(8);
     padding varchar2(1);
   begin
     padding := chr(0);
     len := length(str);
     if len <= 127 then
       encoded_length := fnd_global.local_chr(len);
     else
       encoded_length := fnd_global.local_chr(127);
     end if;
     counter := 7;
     len := len - 127;
     if len > 0 then
       loop
         counter := counter -1;
         if len <= 127 then
           encoded_length := encoded_length || fnd_global.local_chr(len);
           exit;
         else
           encoded_length := encoded_length || fnd_global.local_chr(127);
           len := len - 127;
         end if;
       end loop;
     end if;
     encoded_length := rpad(encoded_length, 8, padding);
     return encoded_length;
   end calculateLength;

   function decodedLength (str in varchar2) return number as
     counter number;
     loopcounter number;
     onechar varchar2(1);
   begin
     counter := 0;
     loopcounter := 1;
     loop
       onechar := substr (str,loopcounter, 1);
       if ascii(onechar) = 0 then
         exit;
       else
         counter := counter + ascii(onechar);
       end if;
       loopcounter := loopcounter + 1;
       if loopcounter = 9 then
         exit;
       end if;
     end loop;
     return counter;
   end decodedLength;

  procedure fireNotification(subject IN varchar2,
                             username IN varchar2,
                             type IN varchar2,
                             content IN varchar2) as
  returnval varchar(2000);
  url varchar(500);
  temp_number number;
  encodedcontent varchar(500);
  encodedsubject varchar(500);
  servername varchar2(100);

  begin

    encodedcontent := content;
    replaceChars (encodedcontent);
    encodedsubject := subject;
    replaceChars (encodedsubject);

    fnd_profile.get('MWA_NOTIFICATION_SERVER', servername);
    url := 'http://' || servername || ':9040/ptg/not?req=notification' || fnd_global.local_chr(38)
            || 'subject=' || encodedsubject ||  fnd_global.local_chr(38) || 'content=' || encodedcontent
            || fnd_global.local_chr(38) || 'username=' || username ||  fnd_global.local_chr(38) || 'type=' || type;

    returnval := utl_http.request(url);


  end fireNotification;

  function mwaNotify (p_subscription_guid  IN raw,
                   p_event IN OUT nocopy WF_EVENT_T) return varchar2 as


    eventData clob;

    failedRequest exception;

    -- these will be extracted out of the clob from the event data
    subject varchar2(30);
    username varchar2(50);
    content varchar2(500);

    subject_size number;
    username_size number;
    content_size number;

    temp_string varchar2(8);

    temp_number number;
  begin

    eventData := WF_EVENT_T.getEventData(p_event);

    temp_number := 8;
    dbms_lob.read (eventData, temp_number, 1 ,temp_string);
    username_size := decodedLength(temp_string);

    temp_number := 8;
    dbms_lob.read (eventData, temp_number, 9 ,temp_string);
    subject_size := decodedLength(temp_string);

    temp_number := 8;
    dbms_lob.read (eventData, temp_number, 17 ,temp_string);
    content_size := decodedLength(temp_string);

    dbms_lob.read (eventData, username_size, 25, username);
    dbms_lob.read (eventData, subject_size, 25 + username_size, subject);
    dbms_lob.read (eventData, content_size, 25 + username_size + subject_size,
                   content);

    --finally fire the notification
    fireNotification(subject, username, 'EMAIL', content);


    return 'SUCCESS';


  exception
    when others then
      wf_core.context('mwa_notification_api', 'mwaNotify', p_event.getEventName(),
                      p_subscription_guid);
      wf_event.setErrorInfo(p_event, 'ERROR');
	return 'ERROR';

 --when utl_http.request_failed,utl_http.init_failed


  end mwaNotify;

  procedure raiseNotification (username IN varchar2,
                               subject IN varchar2,
                               content IN varchar2) as
    eventData  clob;
    username_size number;
    subject_size number;
    content_size number;
    username_encoded varchar2(8);
    subject_encoded varchar2(8);
    content_encoded varchar2(8);

    -- error info
    errorCode number;
    errorText varchar2(600);
    mesg varchar2(15);

  begin

    dbms_lob.createTemporary(eventData, FALSE, DBMS_LOB.CALL);

    username_size := length (username);
    subject_size := length (subject);
    content_size := length (content);

    username_encoded := calculateLength (username);
    subject_encoded := calculateLength (subject);
    content_encoded := calculateLength (content);

    dbms_lob.write (eventData, 8 , 1, username_encoded);
    dbms_lob.write (eventData, 8 , 9, subject_encoded);
    dbms_lob.write (eventData, 8 , 17, content_encoded);

    dbms_lob.write (eventData, username_size , 25, username);
    dbms_lob.write (eventData, subject_size , 25 + username_size, subject);
    dbms_lob.write (eventData, content_size , 25 + username_size + subject_size,
                    content);


    WF_EVENT.Raise('oracle.apps.mwa.notification', 'notification', eventData );

    EXCEPTION
      when others then
        errorCode := SQLCODE;
        errorText := SQLERRM;

  end raiseNotification;



-- initializtion of the char escape table
BEGIN
  escapeRecord(1).replace_char := '%';
  escapeRecord(1).replacement_char := '%25';
  escapeRecord(2).replace_char := ' ';
  escapeRecord(2).replacement_char := '+';
  escapeRecord(3).replace_char := '!';
  escapeRecord(3).replacement_char := '%21';
  escapeRecord(4).replace_char := '"';
  escapeRecord(4).replacement_char := '%22';
  escapeRecord(5).replace_char := '#';
  escapeRecord(5).replacement_char := '%23';
  escapeRecord(6).replace_char := '$';
  escapeRecord(6).replacement_char := '%24';
  escapeRecord(7).replace_char := '&';
  escapeRecord(7).replacement_char := '%26';
  escapeRecord(8).replace_char := fnd_global.local_chr(39);
  escapeRecord(8).replacement_char := '%27';
  escapeRecord(9).replace_char := '(';
  escapeRecord(9).replacement_char := '%28';
  escapeRecord(10).replace_char := ')';
  escapeRecord(10).replacement_char := '%29';
  escapeRecord(11).replace_char := '*';
  escapeRecord(11).replacement_char := '*';
  escapeRecord(12).replace_char := '+';
  escapeRecord(12).replacement_char := '%2B';
  escapeRecord(13).replace_char := ',';
  escapeRecord(13).replacement_char := '%2C';
  escapeRecord(14).replace_char := '-';
  escapeRecord(14).replacement_char := '-';
  escapeRecord(15).replace_char := '.';
  escapeRecord(15).replacement_char := '.';
  escapeRecord(16).replace_char := '/';
  escapeRecord(16).replacement_char := '%2F';
  escapeRecord(17).replace_char := ':';
  escapeRecord(17).replacement_char := '%3A';
  escapeRecord(18).replace_char := ';';
  escapeRecord(18).replacement_char := '%3B';
  escapeRecord(19).replace_char := '<';
  escapeRecord(19).replacement_char := '%3C';
  escapeRecord(20).replace_char := '=';
  escapeRecord(20).replacement_char := '%3D';
  escapeRecord(21).replace_char := '>';
  escapeRecord(21).replacement_char := '%3E';
  escapeRecord(22).replace_char := '?';
  escapeRecord(22).replacement_char := '%3F';
  escapeRecord(23).replace_char := '@';
  escapeRecord(23).replacement_char := '%40';
  escapeRecord(24).replace_char := '[';
  escapeRecord(24).replacement_char := '%5B';
  escapeRecord(25).replace_char := '\';
  escapeRecord(25).replacement_char := '%5C';
  escapeRecord(26).replace_char := ']';
  escapeRecord(26).replacement_char := '%5D';
  escapeRecord(27).replace_char := '^';
  escapeRecord(27).replacement_char := '%5E';
  escapeRecord(28).replace_char := '_';
  escapeRecord(28).replacement_char := '_';
  escapeRecord(29).replace_char := '`';
  escapeRecord(29).replacement_char := '%60';
  escapeRecord(30).replace_char := '{';
  escapeRecord(30).replacement_char := '%7B';
  escapeRecord(31).replace_char := '|';
  escapeRecord(31).replacement_char := '%7C';
  escapeRecord(32).replace_char := '}';
  escapeRecord(32).replacement_char := '%7D';
  escapeRecord(33).replace_char := '~';
  escapeRecord(33).replacement_char := '%7E';

END MWA_NOTIFICATION_API;

/
