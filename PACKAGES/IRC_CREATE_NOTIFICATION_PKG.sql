--------------------------------------------------------
--  DDL for Package IRC_CREATE_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CREATE_NOTIFICATION_PKG" AUTHID CURRENT_USER as
/* $Header: ircnrpkg.pkh 120.0 2006/06/22 07:40:00 narvenka noship $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< create_notification >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This file uses ad_parallel_updates to achieve parallelism.
--
procedure create_notification (errbuf  out nocopy varchar2
                              ,retcode out nocopy number
                              ,p_process_number in varchar2
                              ,p_max_number_proc in varchar2
                              ,p_table_owner in varchar2
                              ,p_batch_size in varchar2
                              );
--
end irc_create_notification_pkg;

 

/
