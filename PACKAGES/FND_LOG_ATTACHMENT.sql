--------------------------------------------------------
--  DDL for Package FND_LOG_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LOG_ATTACHMENT" AUTHID CURRENT_USER as
  /* $Header: AFUTLGTS.pls 115.3 2004/05/05 02:07:10 kkapur noship $ */

  /**
   ** Writes ASCII PMESSAGE to the Attachment
   ** For performance, messages are buffered in memory
   ** until the buffer limit (default 10000) is reached or
   ** CLOSE(..) is called.
   */
  PROCEDURE WRITE(PATTACHMENT_ID IN NUMBER, PMESSAGE IN VARCHAR2);

  /**
   ** Writes ASCII PMESSAGE (appended with newline) to the Attachment
   ** For performance, messages are buffered in memory
   ** until the buffer limit (default 10000) is reached or
   ** CLOSE(..) is called.
   */
  PROCEDURE WRITELN(PATTACHMENT_ID IN NUMBER, PMESSAGE IN VARCHAR2);

  /**
   ** Writes RAW PMESSAGE to the Attachment
   ** For performance, data is buffered in memory
   ** until the buffer limit (default 10000) is reached or
   ** CLOSE(..) is called.
   */
  PROCEDURE WRITE_RAW(PATTACHMENT_ID IN NUMBER, PMESSAGE IN LONG RAW);

  /**
   ** Writes PMESSAGE to the Attachment.
   ** For AOL/J Internal use Only!
   ** (Called from AppsLog.java)
   */
  PROCEDURE WRITE_INTERNAL(PATTACHMENT_ID IN NUMBER, PMESSAGE IN FND_TABLE_OF_RAW_2000,
			PCHARSET IN VARCHAR2, PMIMETYPE IN VARCHAR2,
			PENCODING IN VARCHAR2, PLANG IN VARCHAR2,
			PFILE_EXTN IN VARCHAR2, PDESC IN VARCHAR2);

  /**
   ** Flushes the Attachment buffer and closes the Attachment
   */
  PROCEDURE CLOSE(PATTACHMENT_ID IN NUMBER);

end FND_LOG_ATTACHMENT;

 

/
