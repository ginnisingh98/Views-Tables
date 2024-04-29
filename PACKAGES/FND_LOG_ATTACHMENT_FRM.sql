--------------------------------------------------------
--  DDL for Package FND_LOG_ATTACHMENT_FRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LOG_ATTACHMENT_FRM" AUTHID CURRENT_USER AS
  /* $Header: AFUTLGFS.pls 115.0 2003/10/23 01:20:35 jnurthen noship $ */

  TYPE    Attachment_record 	  IS RECORD (attachment VARCHAR2(4000));
  TYPE 	  Attachment_table 	  IS TABLE OF Attachment_Record INDEX BY BINARY_INTEGER;

  /**
   ** Writes Message to the Attachment.
   ** For Internal Use From Forms FND_LOG_ATTACHMENT ONLY!
   */

  procedure WRITE(WRITER_ID IN VARCHAR2, Message IN Attachment_Table, Array_start IN NUMBER, Array_end IN NUMBER);

  /**
   ** Closes the Attachment.
   ** For Internal Use From Forms FND_LOG_ATTACHMENT ONLY!
   */

  procedure CLOSE(Writer_ID IN VARCHAR2);


END FND_LOG_ATTACHMENT_FRM;

 

/
