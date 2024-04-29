--------------------------------------------------------
--  DDL for Package Body FND_LOG_ATTACHMENT_FRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOG_ATTACHMENT_FRM" AS
  /* $Header: AFUTLGFB.pls 115.1 2004/05/05 01:21:57 kkapur noship $ */


  /**
   ** Writes Message to the Attachment.
   ** For Internal Use From Forms FND_LOG_ATTACHMENT ONLY!
   */

  procedure WRITE(WRITER_ID IN VARCHAR2, Message IN Attachment_Table, Array_start IN NUMBER, array_end in NUMBER) IS
  BEGIN
    if ( writer_id > 0 ) then
      for i in Array_start..array_end LOOP
        if ( message(i).attachment is not NULL ) THEN
	  FND_LOG_ATTACHMENT.WRITE(WRITER_ID, message(i).attachment);
        end if;
      end LOOP;
      FND_LOG_ATTACHMENT.CLOSE(WRITER_ID);
    end if;
  END WRITE;

  procedure CLOSE(Writer_ID IN VARCHAR2) IS
  BEGIN
    null;
	-- Close is a stub for now. we inisist on it being called but
	-- it is not used in the clob case. It may be in the file case.
  END CLOSE;



END FND_LOG_ATTACHMENT_FRM;

/
