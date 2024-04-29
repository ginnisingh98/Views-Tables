--------------------------------------------------------
--  DDL for Package Body PAY_USER_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_CHECK" as
/* $Header: pyusrchk.pkb 115.0 99/07/17 06:46:01 porting ship $ */
--
/*
 Copyright (c) Oracle Corporation 1993,1994,1995.  All rights reserved

/*

 Name         : pay_user_check
 Description  : Process for allowing the user to carry out any
                additional checks on the uploaded element entries.
 Author       : S.Toor
 Date Created : 27-Apr-95
 $Version$

 Change List
 -----------
 Date        Name            Vers     Bug No   Description
 +-----------+---------------+--------+--------+-----------------------+
  27-Apr-1995 S.Toor          1.0               First Created.
  10-Jul-1997 mfender         110.1             Corrected error check
                                                condition
 +-----------+---------------+--------+--------+-----------------------+
*/
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- pay_user_check.validate_header                                        --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id it will carry out any additional user defined    --
 -- checks on the batch header.  Depending upon the outcome of the    --
 -- checks an appropriate status and if necessary a message will be   --
 -- returned for the batch header.                                    --
 -----------------------------------------------------------------------
--
procedure validate_header
(
p_batch_id	in	number,
p_status	in out	varchar2,
p_message	out	varchar2
) is
--
begin
  null;
end validate_header;
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- pay_user_check.check_control                                          --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id it will carry out any user defined control checks--
 -- on the batch. Depending upon the outcome of the checks an         --
 -- appropriate status and if necessary a message will be returned for--
 -- each type of control check carried out on the batch.              --
 -----------------------------------------------------------------------
--
procedure check_control
(
p_batch_id		in	number,
p_control_type		in	varchar2,
p_control_total		in	varchar2,
p_status		in out	varchar2,
p_message		out	varchar2
) is
--
begin
  null;
end check_control;
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- pay_user_check.validate_line                                          --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch line id it will carry out any additional            --
 -- user defined checks for each line associated with the batch.      --
 -- Depending upon the outcome of the checks an appropriate status    --
 -- and if necessary a message will be returned for each batch line.  --
 -----------------------------------------------------------------------
--
procedure validate_line
(
p_batch_line_id	in	number,
p_status	in out	varchar2,
p_message	out	varchar2
) is
--
begin
  null;
end validate_line;
--
end pay_user_check;

/
