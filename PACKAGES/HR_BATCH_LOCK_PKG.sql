--------------------------------------------------------
--  DDL for Package HR_BATCH_LOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BATCH_LOCK_PKG" AUTHID CURRENT_USER as
/* $Header: pybatlck.pkh 115.0 99/07/17 05:45:24 porting ship $ */
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
procedure batch_header_lock
(
p_old_batch_id	in	number,
p_new_batch_id	in	number
);
--
end hr_batch_lock_pkg;

 

/
