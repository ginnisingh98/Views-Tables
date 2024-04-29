--------------------------------------------------------
--  DDL for Package FND_FILE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FILE_UPLOAD" AUTHID CURRENT_USER as
/* $Header: AFAKFUPS.pls 115.10 2003/12/17 18:32:16 blash ship $ */


-- UploadCompleteMessage
--
--    Displays file upload compelte message.
--

procedure UploadCompleteMessage( file  IN      varchar2,
                                 access_id IN     number);

-- CancelProcess
--    Handles upload cancel situations.
--

procedure CancelProcess;

--
-- GFM Support
--
PROCEDURE DisplayGFMForm(access_id IN NUMBER, l_server_url VARCHAR2);

end FND_FILE_UPLOAD;

 

/
