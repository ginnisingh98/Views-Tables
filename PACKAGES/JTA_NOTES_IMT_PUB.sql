--------------------------------------------------------
--  DDL for Package JTA_NOTES_IMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_NOTES_IMT_PUB" AUTHID CURRENT_USER
/* $Header: jtfpntis.pls 120.1 2005/07/02 00:55:27 appldev ship $ */
AS

PROCEDURE optimize_notes_index
--------------------------------------------------------------------------
-- Start of comments
--  API name    : optimize_notes_index
--  Type        : Public
--  Function    : optimize the JTF_NOTES_TL.JTF_NOTES_TL_C1 index
--  Pre-reqs    : None.
--  Parameters  :
--     name                 direction  type       required?
--     ----                 ---------  ----       ---------
--     errbuf               out        varchar2   Yes
--     retcode              out        number     Yes
--     p_optimize_level        in      varchar2   No
--     p_runtime               in      number     No
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
-- End of comments
--------------------------------------------------------------------------
( errbuf              OUT NOCOPY VARCHAR2
, retcode             OUT NOCOPY NUMBER
, p_optimize_level IN            VARCHAR2 := ctx_ddl.optlevel_full
, p_runtime        IN            NUMBER   := ctx_ddl.maxtime_unlimited
);

PROCEDURE sync_notes_index
--------------------------------------------------------------------------
-- Start of comments
--  API name    : sync_notes_index
--  Type        : Public
--  Function    : synchronize the JTF_NOTES_TL.JTF_NOTES_TL_C1 index
--  Pre-reqs    : None.
--  Parameters  :
--     name                 direction  type       required?
--     ----                 ---------  ----       ---------
--     errbuf               out        varchar2   Yes
--     retcode              out        number     Yes
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
-- End of comments
--------------------------------------------------------------------------
( errbuf  OUT NOCOPY VARCHAR2
, retcode OUT NOCOPY NUMBER
);

END JTA_NOTES_IMT_PUB;

 

/
