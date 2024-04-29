--------------------------------------------------------
--  DDL for Package Body HR_BATCH_LOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BATCH_LOCK_PKG" as
/* $Header: pybatlck.pkb 115.0 99/07/17 05:45:21 porting ship $ */
--
/*
 Copyright (c) Oracle Corporation 1993,1994,1995.  All rights reserved

/*

 Name          : hr_batch_lock_pkg
 Description   : Process for locking a paylink batch.
 Author        : S.Toor
 Date Created  : 2-May-95
 $Version$

 Change List
 -----------
 Date	     Name            Vers     Bug No   Description
 +-----------+---------------+--------+--------+-----------------------+
  2-May-1995 S.Toor          1.0               First Created.
 +-----------+---------------+--------+--------+-----------------------+
*/
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- hr_batch_lock_pkg.batch_header_lock                                      --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- If an insert, update or delete is to be performed on              --
 -- either PAY_BATCH_CONTROL_TOTALS or PAY_BATCH_LINES this process   --
 -- will lock the batch in question i.e before the operation is       --
 -- performed.                                                        --
 -- NB : If the batch_control/batch_line record is to be either       --
 --      inserted or deleted then only the batch in question is locked--
 --      However, if the batch_control/batch_line record is to be     --
 --      updated then both the batch to be updated and the batch to   --
 --      be updated to will be locked.                                --
 -----------------------------------------------------------------------
--
procedure batch_header_lock (
p_old_batch_id	in	number,
p_new_batch_id	in 	number
) is
--
-- DECLARATIONS
--
v_batch_id		pay_batch_headers.batch_id%TYPE := null;
--
cursor c_get_header(l_old_batch_id number, l_new_batch_id number) is
       select batch_id
       from   pay_batch_headers
       where  batch_id in (l_old_batch_id,l_new_batch_id)
       for update;
--
begin
  open c_get_header(p_old_batch_id,p_new_batch_id);
  fetch c_get_header into v_batch_id;
  close c_get_header;
--
end batch_header_lock;
--
end hr_batch_lock_pkg;

/
