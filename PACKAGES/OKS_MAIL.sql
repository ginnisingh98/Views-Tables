--------------------------------------------------------
--  DDL for Package OKS_MAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_MAIL" AUTHID CURRENT_USER AS
/* $Header: OKSMAILS.pls 120.0 2005/05/25 18:02:36 appldev noship $ */
  ----------------------- Customizable Section -----------------------

  -- Customize the SMTP host, port and your domain name below.
  smtp_host   VARCHAR2(256) := FND_PROFILE.VALUE('OKS_SMTP_HOST');
  smtp_port   PLS_INTEGER   := FND_PROFILE.VALUE('OKS_SMTP_PORT');
  wallet_path VARCHAR2(256) := FND_PROFILE.VALUE('OKS_SMTP_DOMAIN');

  -- smtp_host   VARCHAR2(256) := 'gmsmtp02.oraclecorp.com';
  -- smtp_port   PLS_INTEGER   := 25;
  -- smtp_domain VARCHAR2(256) := 'oracle.com';

  -- Customize signature that will appear in the email's MIME header.
  -- Useful for versioning.
  -- MAILER_ID   CONSTANT VARCHAR2(256) := 'Mailer by Oracle 9i UTL_SMTP';
  MAILER_ID   CONSTANT VARCHAR2(256) := 'Oracle Contracts for Service';

  -- A unique string that demarcates boundaries of parts in a multi-part
  -- email. The string should not appear inside the body of any part of the
  -- email. Customize this if needed or generate this randomly dynamically.
  BOUNDARY        CONSTANT VARCHAR2(256) := '-----7D81B75CCC90D2974F7A1CBD';

  CRLF CONSTANT VARCHAR2(10) := FND_GLOBAL.LOCAL_CHR(13) ||
                                FND_GLOBAL.LOCAL_CHR(10);

  --------------------- End Customizable Section ---------------------

  FIRST_BOUNDARY  CONSTANT VARCHAR2(256) := '--' || BOUNDARY || CRLF;
  LAST_BOUNDARY   CONSTANT VARCHAR2(256) := '--' || BOUNDARY || '--' || CRLF;

  -- A MIME type that denotes multi-part email (MIME) messages.
  MULTIPART_MIME_TYPE CONSTANT VARCHAR2(256) := 'multipart/mixed; boundary="'||
                                                  BOUNDARY || '"';
  MAX_BASE64_LINE_WIDTH CONSTANT PLS_INTEGER   := 76 / 4 * 3;
  NORMAL_PRIORITY   PLS_INTEGER   := 3;

  TYPE recipient_rec IS RECORD
       (
          mail_type                VARCHAR2(10),
          to_email_address         VARCHAR2(3000)
       );
  TYPE recipient_rec_tbl IS TABLE OF recipient_rec INDEX BY BINARY_INTEGER;

  FUNCTION get_address(mailbox IN VARCHAR2) RETURN VARCHAR2;

  -- Mark a message-part boundary.  Set <last> to TRUE for the last boundary.
  PROCEDURE write_boundary(conn  IN OUT NOCOPY utl_smtp.connection,
                           last  IN            BOOLEAN DEFAULT FALSE);

  -- Write a MIME header
  PROCEDURE write_mime_header(conn  IN OUT NOCOPY utl_smtp.connection,
                              name  IN VARCHAR2,
                              value IN VARCHAR2);

  -- A simple email API for sending email in plain text in a single call.
  PROCEDURE mail(sender    IN VARCHAR2,
                 recipient_tbl IN recipient_rec_tbl,
                 subject   IN VARCHAR2,
                 message   IN VARCHAR2);

  -- Extended email API to send email in HTML or plain text with no size limit.
  -- First, begin the email by begin_mail(). Then, call write_text() repeatedly
  -- to send email in ASCII piece-by-piece. Or, call write_mb_text() to send
  -- email in non-ASCII or multi-byte character set. End the email with
  -- end_mail().
  FUNCTION begin_mail(sender    IN VARCHAR2,
                      recipient_tbl IN recipient_rec_tbl,
                      subject   IN VARCHAR2,
                      mime_type IN VARCHAR2    DEFAULT 'text/plain',
                      priority  IN PLS_INTEGER DEFAULT NULL)
                      RETURN utl_smtp.connection;

  -- Write email body in ASCII
  PROCEDURE write_text(conn    IN OUT NOCOPY utl_smtp.connection,
                       message IN VARCHAR2);

  -- Write email body in non-ASCII (including multi-byte). The email body
  -- will be sent in the database character set.
  PROCEDURE write_mb_text(conn    IN OUT NOCOPY utl_smtp.connection,
                          message IN            VARCHAR2);

  -- Write email body in binary
  PROCEDURE write_raw(conn    IN OUT NOCOPY utl_smtp.connection,
                      message IN RAW);

  -- APIs to send email with attachments. Attachments are sent by sending
  -- emails in "multipart/mixed" MIME format. Specify that MIME format when
  -- beginning an email with begin_mail().

  -- Send a single text attachment.
  PROCEDURE attach_text(conn         IN OUT NOCOPY utl_smtp.connection,
                        data         IN VARCHAR2,
                        mime_type    IN VARCHAR2 DEFAULT 'text/plain',
                        inline       IN BOOLEAN  DEFAULT TRUE,
                        filename     IN VARCHAR2 DEFAULT NULL,
                        last         IN BOOLEAN  DEFAULT FALSE);

  -- Send a binary attachment. The attachment will be encoded in Base-64
  -- encoding format.
  PROCEDURE attach_base64(conn         IN OUT NOCOPY utl_smtp.connection,
                          data         IN RAW,
                          mime_type    IN VARCHAR2 DEFAULT 'application/pdf',
                          inline       IN BOOLEAN  DEFAULT TRUE,
                          filename     IN VARCHAR2 DEFAULT NULL,
                          last         IN BOOLEAN  DEFAULT FALSE);

  -- Send an attachment with no size limit. First, begin the attachment
  -- with begin_attachment(). Then, call write_text repeatedly to send
  -- the attachment piece-by-piece. If the attachment is text-based but
  -- in non-ASCII or multi-byte character set, use write_mb_text() instead.
  -- To send binary attachment, the binary content should first be
  -- encoded in Base-64 encoding format using the demo package for 8i,
  -- or the native one in 9i. End the attachment with end_attachment.
  PROCEDURE begin_attachment(conn         IN OUT NOCOPY utl_smtp.connection,
                             mime_type    IN VARCHAR2 DEFAULT 'text/plain',
                             inline       IN BOOLEAN  DEFAULT TRUE,
                             filename     IN VARCHAR2 DEFAULT NULL,
                             transfer_enc IN VARCHAR2 DEFAULT NULL);

  -- End the attachment.
  PROCEDURE end_attachment(conn IN OUT NOCOPY utl_smtp.connection,
                           last IN BOOLEAN DEFAULT FALSE);

  -- End the email.
  PROCEDURE end_mail(conn IN OUT NOCOPY utl_smtp.connection);

  -- Extended email API to send multiple emails in a session for better
  -- performance. First, begin an email session with begin_session.
  -- Then, begin each email with a session by calling begin_mail_in_session
  -- instead of begin_mail. End the email with end_mail_in_session instead
  -- of end_mail. End the email session by end_session.
  FUNCTION begin_session RETURN utl_smtp.connection;

  -- Begin an email in a session.
  PROCEDURE begin_mail_in_session(conn      IN OUT NOCOPY utl_smtp.connection,
                                  sender    IN VARCHAR2,
                                  recipient_tbl IN recipient_rec_tbl,
                                  subject   IN VARCHAR2,
                                  mime_type IN VARCHAR2   DEFAULT 'text/plain',
                                  priority  IN PLS_INTEGER DEFAULT NULL);

  -- End an email in a session.
  PROCEDURE end_mail_in_session(conn IN OUT NOCOPY utl_smtp.connection);

  -- End an email session.
  PROCEDURE end_session(conn IN OUT NOCOPY utl_smtp.connection);

  -- This is the main program. It will call the other procedures to send the
  -- attachment over.
  PROCEDURE send_binary_attachment(sender    IN VARCHAR2,
                      recipient_tbl IN recipient_rec_tbl,
                      subject   IN VARCHAR2,
                      mail_text IN VARCHAR2,
                      mime_type IN VARCHAR2    DEFAULT 'application/pdf',
                      priority  IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      path_name IN VARCHAR2,
                      file_name IN VARCHAR2
                      );


  ------------------------------------------------------------------------
  -- This procedure takes a URL which yields a PDF document and sends the
  -- retrieved document as an attachment to the email.
  ------------------------------------------------------------------------
  PROCEDURE send_attachment(sender    IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN VARCHAR2,
                      mime_type       IN VARCHAR2    DEFAULT 'application/pdf',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      url             IN VARCHAR2,
                      file_name       IN VARCHAR2
                      );

  PROCEDURE send_attachment ( sender  IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN VARCHAR2,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      document        IN CLOB,
                      file_name       IN VARCHAR2
                );

  PROCEDURE send_attachment ( sender  IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN CLOB,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      document        IN CLOB,
                      file_name       IN VARCHAR2
                );

  PROCEDURE send_attachment ( sender  IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN OKS_AUTO_REMINDER.message_rec_tbl,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      document        IN OKS_AUTO_REMINDER.message_rec_tbl,
                      file_name       IN VARCHAR2
                );

  PROCEDURE send_text_attachment ( sender  IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN VARCHAR2,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY,
                      document        IN VARCHAR2,
                      file_name       IN VARCHAR2
                );

  PROCEDURE send_mail (
                      sender          IN VARCHAR2,
                      recipient_tbl   IN recipient_rec_tbl,
                      subject         IN VARCHAR2,
                      mail_text       IN VARCHAR2,
                      mime_type       IN VARCHAR2 DEFAULT 'text/plain',
                      priority        IN PLS_INTEGER DEFAULT NORMAL_PRIORITY
                );

END OKS_MAIL;

 

/
