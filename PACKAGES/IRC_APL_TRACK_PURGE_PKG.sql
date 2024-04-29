--------------------------------------------------------
--  DDL for Package IRC_APL_TRACK_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APL_TRACK_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: ircapltrackpurge.pkh 120.0.12000000.1 2007/03/26 13:02:47 vboggava noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< purge_record_process >------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure will be called from the concurrent program.
--
procedure purge_record_process
(
   errbuf           out nocopy varchar2
  ,retcode          out nocopy varchar2
  ,p_months         in number
);
--
--
end irc_apl_track_purge_pkg;

 

/
