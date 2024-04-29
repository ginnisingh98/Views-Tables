--------------------------------------------------------
--  DDL for Package Body FND_LOG_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOG_ATTACHMENT" as
  /* $Header: AFUTLGTB.pls 115.3 2004/05/05 02:06:53 kkapur noship $ */

  TYPE AttachmentsCache IS TABLE of LONG RAW
		INDEX BY BINARY_INTEGER;
  mCache AttachmentsCache;

  /**
   ** Flushes the buffered messages
   */
  PROCEDURE FLUSH(PATTACHMENT_ID IN NUMBER) is
    pragma AUTONOMOUS_TRANSACTION;
    myvar  LONG RAW := NULL;
    mylen  number;
    myblob BLOB;
    begin
      if (mCache.exists(PATTACHMENT_ID)) then
        FND_LOG_REPOSITORY.GET_BLOB_INTERNAL(PATTACHMENT_ID, myblob);
        myvar := mCache(PATTACHMENT_ID);
        mylen := UTL_RAW.length(myvar);
	if ( mylen > 0 ) then
          if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'fnd.plsql.fnd_log_attachment.flush',
                        'log_sequence=' || PATTACHMENT_ID || '; Message len=' || mylen);
          end if;
          DBMS_LOB.WRITEAPPEND(myblob, mylen, myvar);
          commit;
	end if;
      end if;
  end FLUSH;

  /**
   ** Adds the message to the buffer
   */
  PROCEDURE PUT_BUFFER(PATTACHMENT_ID IN NUMBER, PMESSAGE IN VARCHAR2) is
    myvar   LONG RAW;
    myinmsg LONG RAW;
    mylen   NUMBER;
    begin
      if (mCache.exists(PATTACHMENT_ID)) then
         myvar := mCache(PATTACHMENT_ID);
	 myinmsg := UTL_RAW.CAST_TO_RAW(CONVERT(PMESSAGE, 'US7ASCII'));
         mylen := UTL_RAW.length(myvar) + UTL_RAW.length(myinmsg);
         if ( mylen >= 10000 ) then
            flush(PATTACHMENT_ID);
	    mCache(PATTACHMENT_ID) := myinmsg;
	 else
            mCache(PATTACHMENT_ID) := UTL_RAW.CONCAT(myvar, myinmsg);
         end if;
      elsif (PATTACHMENT_ID > 0) then
 	 mCache(PATTACHMENT_ID) := UTL_RAW.CAST_TO_RAW(CONVERT(PMESSAGE, 'US7ASCII'));
      end if;
  end PUT_BUFFER;

  /**
   ** Adds the message to the buffer
   */
  PROCEDURE PUT_BUFFER_RAW(PATTACHMENT_ID IN NUMBER, PMESSAGE IN LONG RAW) is
    myvar   LONG RAW;
    mylen   NUMBER;
    begin
      if (mCache.exists(PATTACHMENT_ID)) then
         myvar := mCache(PATTACHMENT_ID);
         mylen := UTL_RAW.length(myvar) + UTL_RAW.length(PMESSAGE);
         if ( mylen >= 10000 ) then
            flush(PATTACHMENT_ID);
            mCache(PATTACHMENT_ID) := PMESSAGE;
         else
            mCache(PATTACHMENT_ID) := UTL_RAW.CONCAT(myvar, PMESSAGE);
         end if;
      elsif (PATTACHMENT_ID > 0) then
         mCache(PATTACHMENT_ID) := PMESSAGE;
      end if;
  end PUT_BUFFER_RAW;

  /**
   ** Writes PMESSAGE to the Attachment
   ** For performance, messages are buffered in memory
   ** until the buffer limit (default 10000) is reached or
   ** CLOSE(..) is called.
   */
  PROCEDURE WRITE(PATTACHMENT_ID IN NUMBER, PMESSAGE IN VARCHAR2) is
    begin
      PUT_BUFFER(PATTACHMENT_ID, PMESSAGE);
  end WRITE;

  /**
   ** Writes PMESSAGE (appended with newline) to the Attachment
   ** For performance, messages are buffered in memory
   ** until the buffer limit (default 10000) is reached or
   ** CLOSE(..) is called.
   */
  PROCEDURE WRITELN(PATTACHMENT_ID IN NUMBER, PMESSAGE IN VARCHAR2) is
    begin
      WRITE(PATTACHMENT_ID, PMESSAGE || fnd_global.newline);
  end WRITELN;

  /**
   ** Writes RAW PMESSAGE to the Attachment
   ** For performance, data is buffered in memory
   ** until the buffer limit (default 10000) is reached or
   ** CLOSE(..) is called.
   */
  PROCEDURE WRITE_RAW(PATTACHMENT_ID IN NUMBER, PMESSAGE IN LONG RAW) is
    begin
      PUT_BUFFER_RAW(PATTACHMENT_ID, PMESSAGE);
  end WRITE_RAW;

  /**
   ** Writes PMESSAGE to the Attachment.
   ** For AOL/J Internal use Only!
   ** (Called from AppsLog.java)
   */
  PROCEDURE WRITE_INTERNAL(PATTACHMENT_ID IN NUMBER, PMESSAGE IN FND_TABLE_OF_RAW_2000,
			PCHARSET IN VARCHAR2, PMIMETYPE IN VARCHAR2,
			PENCODING IN VARCHAR2, PLANG IN VARCHAR2,
                        PFILE_EXTN IN VARCHAR2, PDESC IN VARCHAR2) is
    pragma AUTONOMOUS_TRANSACTION;
    myblob BLOB;
    table_len number;
    msg_len number;
    i number;
    begin
      if ( PATTACHMENT_ID > 0 ) then
        flush(PATTACHMENT_ID);
        table_len := PMESSAGE.COUNT;
        FND_LOG_REPOSITORY.GET_BLOB_INTERNAL(PATTACHMENT_ID, myblob, PCHARSET,
			PMIMETYPE, PENCODING, PLANG, PFILE_EXTN, PDESC);
        if ( myblob is not NULL ) then
          FOR i IN 1..table_len LOOP
            msg_len := UTL_RAW.LENGTH(PMESSAGE(i));
    	    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'fnd.plsql.fnd_log_attachment.write',
        		'log_sequence=' || PATTACHMENT_ID || '; LoopCtr=' || i ||
			'; Message len=' || msg_len);
    	    end if;
            if ( msg_len > 0 ) then
	      DBMS_LOB.WRITEAPPEND(myblob, msg_len, PMESSAGE(i));
            end if;
          END LOOP;
          commit;
        end if;
      end if;
  end WRITE_INTERNAL;

  /**
   ** Flushes the Attachment buffer and closes the Attachment
   */
  PROCEDURE CLOSE(PATTACHMENT_ID IN NUMBER) is
    begin
      flush(PATTACHMENT_ID);
      mCache.delete(PATTACHMENT_ID);
  end CLOSE;

end FND_LOG_ATTACHMENT;

/
