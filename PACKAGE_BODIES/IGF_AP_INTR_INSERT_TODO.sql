--------------------------------------------------------
--  DDL for Package Body IGF_AP_INTR_INSERT_TODO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_INTR_INSERT_TODO" AS
/* $Header: IGFAP21B.pls 120.1 2005/09/08 14:34:46 appldev noship $ */


PROCEDURE  main ( errbuf                        IN OUT NOCOPY VARCHAR2,
                  retcode                       IN OUT NOCOPY VARCHAR2,
                  x_todo_type                   IN VARCHAR2,
                  x_todo_sub_type               IN VARCHAR2,
                  x_person_id                   IN NUMBER,
                  x_acad_ci_cal_type            IN VARCHAR2,
                  x_acad_ci_sequence_number     IN NUMBER,
                  x_key1                        IN VARCHAR2,
                  x_key2                        IN VARCHAR2,
                  x_key3                        IN VARCHAR2,
                  x_key4                        IN VARCHAR2,
                  x_key5                        IN VARCHAR2,
                  x_key6                        IN VARCHAR2,
                  x_key7                        IN VARCHAR2,
                  x_key8                        IN VARCHAR2,
                  x_old_value1                  IN VARCHAR2,
                  x_new_value1                  IN VARCHAR2,
                  x_old_value2                  IN VARCHAR2,
                  x_new_value2                  IN VARCHAR2,
                  x_old_value3                  IN VARCHAR2,
                  x_new_value3                  IN VARCHAR2,
                  x_old_value4                  IN VARCHAR2,
                  x_new_value4                  IN VARCHAR2,
                  x_old_value5                  IN VARCHAR2,
                  x_new_value5                  IN VARCHAR2,
                  p_org_id                      IN VARCHAR2)

IS


--------------------------------------------------------------------------------------
--
--      Created By : sjadhav
--	Creation date : june 29,2001
--      this package inserts into igf_ap_todo table the updated oss data attributes
--      which affect financial aid processing
--
--Chnage History:
--Who       When            What
-- rasahoo  27-Aug-2003     Removed all codes As part of Financial Aid base record history obsoletion Build.
--------------------------------------------------------------------------------------


BEGIN
-- The Concurrent job IGFAPJ010 (Base Record - Trigger Student System Data Change Workflow)
-- is obsoleted. So all codes are removed.
-- Added the message IGS_GE_OBSOLETE_JOB for logging the message 'This job is no longer in use'.
--
   fnd_message.set_name('IGS','IGS_GE_OBSOLETE_JOB');
   fnd_file.put_line(fnd_file.log,fnd_message.get);

--
END main;

END igf_ap_intr_insert_todo;

/
