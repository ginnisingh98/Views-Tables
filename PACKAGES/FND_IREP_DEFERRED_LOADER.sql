--------------------------------------------------------
--  DDL for Package FND_IREP_DEFERRED_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_IREP_DEFERRED_LOADER" AUTHID CURRENT_USER as
/* $Header: FNDIRLDS.pls 120.3 2005/09/15 11:41:20 mfisher noship $ */



--API

-- SubmitConcurrent
-- Submit concurrent program.
-- OUT
--   ErrBuf - Error message
--   RetCode - Return code - '0' if completed sucessfully
procedure SubmitConcurrent(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY varchar2,
  P_APPLTOP_ID in varchar2
  );


end FND_IREP_DEFERRED_LOADER;


 

/
