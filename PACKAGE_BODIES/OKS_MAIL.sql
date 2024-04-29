--------------------------------------------------------
--  DDL for Package Body OKS_MAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_MAIL" AS
/* $Header: OKSMAILB.pls 120.0 2005/05/25 17:37:39 appldev noship $ */

  -- Return the email address in the mailbox. The format of mailbox
  -- may be in one of these formats:
  --   someone@some-domain
  --   "Someone" <someone@some-domain>
  --   Someone <someone@some-domain>
  FUNCTION get_address(mailbox IN VARCHAR2) RETURN VARCHAR2 AS
    i   PLS_INTEGER;
    str VARCHAR2(256);
  BEGIN
    i := instr(mailbox, '<', -1);
    IF (i > 0) THEN
      str := substr(mailbox, i + 1);
      RETURN substr(str, 1, instr(str, '>') - 1);
    ELSE
      RETURN mailbox;
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  -- Write a MIME header
  PROCEDURE write_mime_header(conn  IN OUT NOCOPY utl_smtp.connection,
                              name  IN VARCHAR2,
                              value IN VARCHAR2) IS
  BEGIN
    utl_smtp.write_data(conn, name || ': ' || value || CRLF);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  -- Mark a message-part boundary.  Set <last> to TRUE for the last boundary.
  PROCEDURE write_boundary(conn  IN OUT NOCOPY utl_smtp.connection,
                           last  IN            BOOLEAN DEFAULT FALSE) AS
  BEGIN
    IF (last) THEN
      utl_smtp.write_data(conn, LAST_BOUNDARY);
    ELSE
      utl_smtp.write_data(conn, FIRST_BOUNDARY);
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE mail(sender    IN VARCHAR2,
                 recipient_tbl IN recipient_rec_tbl,
                 subject   IN VARCHAR2,
                 message   IN VARCHAR2) IS
    conn utl_smtp.connection;
  BEGIN
    conn := begin_mail(sender, recipient_tbl, subject);
    write_text(conn, message);
    end_mail(conn);
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  FUNCTION begin_mail(sender    IN VARCHAR2,
                      recipient_tbl IN recipient_rec_tbl,
                      subject   IN VARCHAR2,
                      mime_type IN VARCHAR2    DEFAULT 'text/plain',
                      priority  IN PLS_INTEGER DEFAULT NULL)
                      RETURN utl_smtp.connection IS
    conn utl_smtp.connection;
  BEGIN
    conn := begin_session;
    begin_mail_in_session(conn, sender, recipient_tbl, subject, mime_type,
      priority);
    RETURN conn;

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE write_text(conn    IN OUT NOCOPY utl_smtp.connection,
                       message IN VARCHAR2) IS
  BEGIN
    utl_smtp.write_data(conn, message);
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE write_mb_text(conn    IN OUT NOCOPY utl_smtp.connection,
                          message IN            VARCHAR2) IS
    --l_message VARCHAR2(32000);
  BEGIN
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(message));
    --l_message := oks_base64.encode(message);
    --utl_smtp.write_data(conn, l_message);
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE write_raw(conn    IN OUT NOCOPY utl_smtp.connection,
                      message IN RAW) IS
    --l_message VARCHAR2(32000);
  BEGIN
    utl_smtp.write_raw_data(conn, message);
    --l_message := oks_base64.encode(message);
    --utl_smtp.write_data(conn, l_message);
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE attach_text(conn         IN OUT NOCOPY utl_smtp.connection,
                        data         IN VARCHAR2,
                        mime_type    IN VARCHAR2 DEFAULT 'text/plain',
                        inline       IN BOOLEAN  DEFAULT TRUE,
                        filename     IN VARCHAR2 DEFAULT NULL,
                        last         IN BOOLEAN  DEFAULT FALSE) IS
  BEGIN
    begin_attachment(conn, mime_type, inline, filename);
    write_text(conn, data);
    end_attachment(conn, last);
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE attach_base64(conn         IN OUT NOCOPY utl_smtp.connection,
                          data         IN RAW,
                          mime_type    IN VARCHAR2 DEFAULT 'application/pdf',
                          inline       IN BOOLEAN  DEFAULT TRUE,
                          filename     IN VARCHAR2 DEFAULT NULL,
                          last         IN BOOLEAN  DEFAULT FALSE) IS
    i   PLS_INTEGER;
    len PLS_INTEGER;
  BEGIN

    -- by MK  begin_attachment(conn, mime_type, inline, filename, 'base64');

    -- Split the Base64-encoded attachment into multiple lines
    i   := 1;
    len := utl_raw.length(data);
    WHILE (i < len) LOOP
       IF (i + MAX_BASE64_LINE_WIDTH < len) THEN
          -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          -- For Oracle 9i, replace oks_base64.encode with the native
          -- utl_encode.base64_encode:
          --
          --   utl_smtp.write_raw_data(conn,
          --     utl_encode.base64_encode(utl_raw.substr(data, i,
          --     MAX_BASE64_LINE_WIDTH)));
          --
          -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          utl_smtp.write_data(conn,
            oks_base64.encode(utl_raw.substr(data, i,
            MAX_BASE64_LINE_WIDTH)));
           -- utl_smtp.write_raw_data(conn, utl_raw.substr(data, i, MAX_BASE64_LINE_WIDTH)); -- By MK

       ELSE
          -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          -- For Oracle 9i, replace oks_base64.encode with the native
          -- utl_encode.base64_encode:
          --
          --   utl_smtp.write_raw_data(conn,
          --     utl_encode.base64_encode(utl_raw.substr(data, i)));
          --
          -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
           utl_smtp.write_data(conn,
            oks_base64.encode(utl_raw.substr(data, i)));
             --utl_smtp.write_raw_data(conn, utl_raw.substr(data, i)); -- By MK
       END IF;
       utl_smtp.write_data(conn, CRLF);
       i := i + MAX_BASE64_LINE_WIDTH;
    END LOOP;

    -- By MK -- end_attachment(conn, last);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE begin_attachment(conn         IN OUT NOCOPY utl_smtp.connection,
                             mime_type    IN VARCHAR2 DEFAULT 'text/plain',
                             inline       IN BOOLEAN  DEFAULT TRUE,
                             filename     IN VARCHAR2 DEFAULT NULL,
                             transfer_enc IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    write_boundary(conn);
    write_mime_header(conn, 'Content-Type', mime_type);

    IF (filename IS NOT NULL) THEN
       IF (inline) THEN
          write_mime_header(conn, 'Content-Disposition',
            'inline; filename="'||filename||'"');
       ELSE
          write_mime_header(conn, 'Content-Disposition',
            'attachment; filename="'||filename||'"');
       END IF;
    END IF;

    IF (transfer_enc IS NOT NULL) THEN
      write_mime_header(conn, 'Content-Transfer-Encoding', transfer_enc);
    END IF;

    utl_smtp.write_data(conn, CRLF);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE end_attachment(conn IN OUT NOCOPY utl_smtp.connection,
                           last IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    utl_smtp.write_data(conn, CRLF);
    IF (last) THEN
      write_boundary(conn, last);
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE end_mail(conn IN OUT NOCOPY utl_smtp.connection) IS
  BEGIN
    end_mail_in_session(conn);
    end_session(conn);
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  FUNCTION begin_session RETURN utl_smtp.connection IS
    conn utl_smtp.connection;
    status UTL_SMTP.REPLY;
  BEGIN
    -- open SMTP connection
    status := utl_smtp.open_connection(smtp_host, smtp_port, conn);

    -- Status code 220 - Service is ready
    IF (status.code <> 220) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, status.code || ': ' || status.text );
    END IF;

    status := utl_smtp.helo(conn, smtp_host); -- @@ or EHLO?

    -- Status code 250 - Requested mail action OKAY completed
    -- Hand shaking working
    IF (status.code <> 250) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, status.code || ': ' || status.text );
    END IF;
    RETURN conn;
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE begin_mail_in_session(conn    IN OUT NOCOPY utl_smtp.connection,
                                  sender    IN VARCHAR2,
                                  recipient_tbl IN recipient_rec_tbl,
                                  subject   IN VARCHAR2,
                                  mime_type IN VARCHAR2   DEFAULT 'text/plain',
                                  priority  IN PLS_INTEGER DEFAULT NULL) IS
    l_count NUMBER := 1;
  BEGIN

    -- Specify sender's address (our server allows bogus address
    -- as long as it is a full email address (xxx@yyy.com).
    utl_smtp.mail(conn, get_address(sender));

    -- Specify recipient(s) of the email.
    While l_count <= recipient_tbl.count
    Loop
       utl_smtp.rcpt(conn, get_address(recipient_tbl(l_count).to_email_address) );
       l_count :=  l_count + 1;
    End Loop;

    -- Start body of email
    utl_smtp.open_data(conn);

    -- Set "From" MIME header
    write_mime_header(conn, 'From', sender);

    -- Set "To" MIME header
    l_count := 1;
    While l_count <= recipient_tbl.count
    Loop

      IF UPPER(NVL(recipient_tbl(l_count).mail_type,'TO')) = 'TO' THEN
         write_mime_header(conn, 'To', recipient_tbl(l_count).to_email_address);
      ELSIF UPPER(recipient_tbl(l_count).mail_type) = 'CC' THEN
         write_mime_header(conn, 'CC', recipient_tbl(l_count).to_email_address);
      ELSIF UPPER(recipient_tbl(l_count).mail_type) = 'BCC' THEN
         write_mime_header(conn, 'Bcc', recipient_tbl(l_count).to_email_address);
      ELSIF UPPER(recipient_tbl(l_count).mail_type) = 'REPLY-TO' THEN
         write_mime_header(conn, 'Reply-To', recipient_tbl(l_count).to_email_address);
      END IF;

      l_count :=  l_count + 1;
    End Loop;

    -- Set "Subject" MIME header
    write_mime_header(conn, 'Subject', subject);

    -- Set "Content-Type" MIME header
    write_mime_header(conn, 'Content-Type', mime_type);

    -- Set "X-Mailer" MIME header
    write_mime_header(conn, 'X-Mailer', MAILER_ID);

    -- Set priority:
    --   High      Normal       Low
    --   1     2     3     4     5
    IF (priority IS NOT NULL) THEN
      write_mime_header(conn, 'X-Priority', priority);
    END IF;

    -- Send an empty line to denotes end of MIME headers and
    -- beginning of message body.
    utl_smtp.write_data(conn, CRLF);

    IF (mime_type LIKE 'multipart/mixed%') THEN
      write_text(conn, 'This is a multi-part message in MIME format.' ||
        CRLF);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE end_mail_in_session(conn IN OUT NOCOPY utl_smtp.connection) IS
  BEGIN
    utl_smtp.close_data(conn);
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  ------------------------------------------------------------------------
  PROCEDURE end_session(conn IN OUT NOCOPY utl_smtp.connection) IS
  BEGIN
    utl_smtp.quit(conn);
  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  PROCEDURE send_binary_attachment(sender    IN VARCHAR2,
                      recipient_tbl IN recipient_rec_tbl,
                      subject   IN VARCHAR2,
                      mail_text IN VARCHAR2,
                      mime_type IN VARCHAR2 DEFAULT 'application/pdf',
                      priority  IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      path_name IN VARCHAR2,
                      file_name IN VARCHAR2
                      ) IS
   conn utl_smtp.connection;
   l_file_loc BFILE;
   l_raw   RAW(32000);
   l_num   INTEGER;
   l_amount BINARY_INTEGER := 32000;
   l_offset INTEGER := 1;
  BEGIN
    conn := begin_mail(sender => sender,
                     recipient_tbl => recipient_tbl,
                     subject => subject,
                     mime_type => oks_mail.MULTIPART_MIME_TYPE,
                     priority => priority);

    attach_text(conn, mail_text, 'text/html');

    begin_attachment(conn => conn,
                            mime_type => mime_type,
                            inline => TRUE,
                            filename => file_name,
                            transfer_enc => 'base64');
------------ It will upload the physical file ----------------
l_file_loc := BFILENAME(path_name, file_name);

l_num := dbms_lob.getlength(l_file_loc);

dbms_lob.open(file_loc => l_file_loc,
              open_mode => dbms_lob.file_readonly);

while l_offset < l_num Loop
    dbms_lob.read(file_loc => l_file_loc,
                 amount => l_amount,
                 offset  => l_offset,
                 buffer => l_raw);
    attach_base64(conn, l_raw, mime_type, TRUE,  file_name, FALSE);
    l_offset := l_offset +  l_amount;
    IF  (l_offset + l_amount) > l_num Then
       l_amount := l_num - l_offset;
    End If;

 End Loop;
 dbms_lob.fileclose(file_loc => l_file_loc);
 --------------------------------------------------------------
 end_attachment(conn);
 end_mail(conn);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
END;


  --------------------------------------------------------------
  -- This Procedure takes a URL which yields a PDF document and
  -- sends the retrieved document as an attachment to the email.
  --------------------------------------------------------------

  PROCEDURE send_attachment ( sender  IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN VARCHAR2,
                      mime_type       IN VARCHAR2 DEFAULT 'application/pdf',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      url             IN VARCHAR2,
                      file_name       IN VARCHAR2
                ) IS

     conn        UTL_SMTP.CONNECTION;
     buf         RAW(32767);
     pieces      UTL_HTTP.HTML_PIECES;
     wallet_pswd VARCHAR2(2000);
     j           pls_integer;

  BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Host name: ' || smtp_host);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Port     : ' || smtp_port);

    conn := begin_mail(sender => sender,
                     recipient_tbl => recipient_tbl,
                     subject => subject,
                     mime_type => oks_mail.MULTIPART_MIME_TYPE,
                     priority => priority);

    attach_text(conn, mail_text);

    begin_attachment(conn => conn,
                            mime_type => mime_type,
                            inline => TRUE,
                            filename => file_name,
                            transfer_enc => 'base64');

    IF (UPPER(SUBSTR(URL, 1,5)) = 'HTTPS') THEN

       IF LENGTH(wallet_path) > 0 THEN

          IF INSTR(wallet_path,'$$') > 0 THEN
             wallet_pswd := SUBSTR(wallet_path, INSTR(wallet_path,'$$')+2);
             wallet_path := SUBSTR(wallet_path, 0, INSTR(wallet_path,'$$')-1);
          ELSE
             wallet_pswd := NULL;
          END IF;

          pieces := UTL_HTTP.REQUEST_PIECES(
                                     url              => URL,
                                     max_pieces       => 32767,
                                     proxy            => NULL,
                                     wallet_path      => wallet_path,
                                     wallet_password  => wallet_pswd
                                 );
       ELSE
          FND_MESSAGE.SET_NAME ('OKS', 'OKS_INVALID_WALLET_PATH');
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET );
       END IF;

    ELSE
       pieces := UTL_HTTP.REQUEST_PIECES(
                                     url              => URL,
                                     max_pieces       => 32767,
                                     proxy            => NULL,
                                     wallet_path      => NULL,
                                     wallet_password  => NULL
                                 );
    END IF;

    FOR i IN 1..pieces.count LOOP
       buf := utl_raw.concat(buf, utl_raw.cast_to_raw(pieces(i)));
       j := 1;
       WHILE ((j + 57) < utl_raw.length(buf)) LOOP
         utl_smtp.write_data(conn,
	   oks_base64.encode(utl_raw.substr(buf, j, 57)) || utl_tcp.crlf);
	 j := j + 57;
       END LOOP;
       buf := utl_raw.substr(buf, j);
    END LOOP;

    IF (buf IS NOT NULL) then
       utl_smtp.write_data(conn, oks_base64.encode(buf) || utl_tcp.crlf);
    END IF;

    --------------------------------------------------------

    end_attachment(conn);
    end_mail(conn);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  PROCEDURE send_text_attachment ( sender  IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN VARCHAR2,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      document        IN VARCHAR2,
                      file_name       IN VARCHAR2
                ) IS

     conn    UTL_SMTP.CONNECTION;
     l_raw   RAW(32767);

  BEGIN

    conn := begin_mail(sender => sender,
                     recipient_tbl => recipient_tbl,
                     subject => subject,
                     mime_type => oks_mail.MULTIPART_MIME_TYPE,
                     priority => priority);

    attach_text(
                 conn       => conn,
                 data       => mail_text,
                 mime_type  => mime_type
               );

    begin_attachment(conn => conn,
                            mime_type => mime_type,
                            inline => TRUE,
                            filename => file_name,
                            transfer_enc => 'base64');

    l_raw := UTL_RAW.CAST_TO_RAW (document);
    attach_base64(conn, l_raw, mime_type, TRUE,  file_name, FALSE);

    end_attachment(conn);
    end_mail(conn);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  PROCEDURE send_attachment ( sender  IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN VARCHAR2,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      document        IN CLOB,
                      file_name       IN VARCHAR2
                ) IS

     conn              UTL_SMTP.CONNECTION;
     l_raw             RAW(3000);
     l_str             VARCHAR2(3000);
     clob_length       INTEGER;
     offset            INTEGER;
     amount            INTEGER;

  BEGIN

    conn := begin_mail(sender => sender,
                     recipient_tbl => recipient_tbl,
                     subject => subject,
                     mime_type => oks_mail.MULTIPART_MIME_TYPE,
                     priority => priority);

    attach_text(
                 conn       => conn,
                 data       => mail_text,
                 mime_type  => mime_type
               );

    begin_attachment(conn => conn,
                            mime_type => mime_type,
                            inline => FALSE,
                            filename => file_name,
                            transfer_enc => 'base64');

    ------ It will upload the physical file ----------------

    clob_length := dbms_lob.getlength(document);
    offset := 1;

    WHILE clob_length > 0 LOOP

        IF clob_length < 3000 THEN
           amount := clob_length;
        ELSE
           amount := 3000;
        END IF;

        dbms_lob.read(document, amount, offset, l_str);

        l_raw := UTL_RAW.CAST_TO_RAW (l_str);
        attach_base64(conn, l_raw, mime_type, TRUE,  file_name, FALSE);

        clob_length := clob_length - 3000;
        offset      := offset + 3000;

    END LOOP;

    --------------------------------------------------------

    end_attachment(conn);
    end_mail(conn);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  PROCEDURE send_attachment ( sender  IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN CLOB,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      document        IN CLOB,
                      file_name       IN VARCHAR2
                ) IS

     conn              UTL_SMTP.CONNECTION;
     l_raw             RAW(32767);
     l_str             VARCHAR2(4000);
     clob_length       INTEGER;
     offset            INTEGER;
     amount            INTEGER;

  BEGIN

    conn := begin_mail(sender      => sender,
                     recipient_tbl => recipient_tbl,
                     subject       => subject,
                     mime_type     => oks_mail.MULTIPART_MIME_TYPE,
                     priority      => priority);

    begin_attachment(conn      => conn,
                     mime_type => mime_type);

    clob_length := dbms_lob.getlength(mail_text);
    offset := 1;

    WHILE clob_length > 0 LOOP

        IF clob_length < 2000 THEN
           amount := clob_length;
        ELSE
           amount := 2000;
        END IF;

        l_str := DBMS_LOB.SUBSTR(mail_text, amount, offset);
        write_text(conn      => conn,
                   message   => l_str);

        clob_length := clob_length - 2000;
        offset      := offset + 2000;

    END LOOP;
    end_attachment(conn);

    begin_attachment(conn      => conn,
                     mime_type => mime_type,
                     inline    => FALSE,
                     filename  => file_name);

    clob_length := dbms_lob.getlength(document);
    offset := 1;

    WHILE clob_length > 0 LOOP

        IF clob_length < 2000 THEN
           amount := clob_length;
        ELSE
           amount := 2000;
        END IF;

        l_str := DBMS_LOB.SUBSTR(document, amount, offset);
        write_text(conn      => conn,
                   message   => l_str );

        clob_length := clob_length - 2000;
        offset      := offset + 2000;

    END LOOP;

    end_attachment(conn);
    end_mail(conn);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  PROCEDURE send_attachment ( sender  IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN OKS_AUTO_REMINDER.message_rec_tbl,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      document        IN OKS_AUTO_REMINDER.message_rec_tbl,
                      file_name       IN VARCHAR2
                ) IS

     conn              UTL_SMTP.CONNECTION;

  BEGIN

    conn := begin_mail(sender      => sender,
                     recipient_tbl => recipient_tbl,
                     subject       => subject,
                     mime_type     => oks_mail.MULTIPART_MIME_TYPE,
                     priority      => priority);

   begin_attachment(
                      conn         => conn,
                      mime_type    => mime_type
                    );

    FOR i IN 1 .. mail_text.count LOOP
        IF mail_text(i).description IS NOT NULL THEN
           write_text(
                      conn         => conn,
                      message      => trim(mail_text(i).description)
                    );
        END IF;
    END LOOP;
    end_attachment(conn);

    begin_attachment(
                      conn         => conn,
                      mime_type    => mime_type,
                      inline       => FALSE,
                      filename     => file_name
                    );

    FOR i IN 1 .. document.count LOOP
        IF document(i).description IS NOT NULL THEN
           write_text(
                      conn         => conn,
                      message      => trim(document(i).description)
                    );
        END IF;
    END LOOP;

    end_attachment(conn);
    end_mail(conn);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

  PROCEDURE send_mail (
                      sender          IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN VARCHAR2,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY
                ) IS

     conn    UTL_SMTP.CONNECTION;

  BEGIN

    conn := begin_mail(sender => sender,
                     recipient_tbl => recipient_tbl,
                     subject => subject,
                     mime_type => oks_mail.MULTIPART_MIME_TYPE,
                     priority => priority);

    attach_text(
                 conn       => conn,
                 data       => mail_text,
                 mime_type  => mime_type
               );

    end_mail(conn);

  EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM );
  END;

END OKS_MAIL;

/
