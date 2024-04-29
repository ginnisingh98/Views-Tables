--------------------------------------------------------
--  DDL for Package Body IGF_AP_OSS_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_OSS_PROCESS" AS
/* $Header: IGFAP22B.pls 120.1 2005/09/08 14:31:23 appldev noship $ */

PROCEDURE  process_todo ( errbuf                        IN OUT NOCOPY VARCHAR2,
                          retcode                       IN OUT NOCOPY NUMBER)


AS
--------------------------------------------------------------------------------------
--
--      Created By    : sjadhav
--	Creation date : Jul 06,2001
--
--      this is the callable prcoedure from concurrent program
--
--Chnage History:
--Who       When            What
-- rasahoo  27-Aug-2003     Removed all codes As part of Financial Aid base record history obsoletion Build.
--------------------------------------------------------------------------------------
BEGIN
-- The Concurrent job IGFAPJ011 (Base Record - Initiate Student System Data Change Workflow)
-- is obsoleted. So all codes are removed.
-- Added the message IGS_GE_OBSOLETE_JOB for logging the message 'This job is no longer in use'.
--
   fnd_message.set_name('IGS','IGS_GE_OBSOLETE_JOB');
   fnd_file.put_line(fnd_file.log,fnd_message.get);
--
END process_todo;

END igf_ap_oss_process;

/
