--------------------------------------------------------
--  DDL for Package Body AR_ARATAPPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARATAPPM_PKG" AS
/*$Header: ARATAPPMB.pls 120.1.12010000.2 2009/03/30 12:12:48 vsanka noship $*/

/*
*  Automatic Cash Application Execution Report
*
*  Created by		: 	vsanka
*  Creation Date	:	03-24-09
*  Description		:	Utilities of ARATAPPM XML Pub Report.
*/

function BeforeReport return boolean is

flag VARCHAR2(10);
begin

   flag := 'N';

   select name
   into l_org_name
   from hr_operating_units
   where organization_id = p_org_id;

   select count(distinct cash_receipt_id)
   into l_no_receipts_processed
   from ar_cash_remit_refs_interim;

   select count(*)
   into l_no_remit_lines_processed
   from ar_cash_remit_refs_interim;

   select count(*)
   into l_no_remit_lines_autoapply
   FROM  ar_cash_remit_refs_interim interim, ar_cash_remit_refs refs
   where interim.remit_reference_id = refs.remit_reference_id
   and refs.auto_applied = 'Y';

   if l_no_remit_lines_processed = 0 then
      l_no_remit_lines_processed := 1;
      flag := 'Y';
   end if;

   l_hit_ratio := (l_no_remit_lines_autoapply/l_no_remit_lines_processed)*100;

   select count(*)
   into l_no_remit_lines_suggested
   from ar_cash_remit_refs_interim interim, ar_cash_remit_refs refs
   where interim.remit_reference_id = refs.remit_reference_id
   and refs.auto_applied = 'N'
   and exists ( select 'Suggestion_Created'
             from ar_cash_recos recos
             where recos.remit_reference_id = interim.remit_reference_id);

   if ( flag = 'Y' and l_no_remit_lines_processed = 1 ) THEN
    l_no_remit_lines_processed := 0;
    flag := 'N';
  end if;

  return (TRUE);
end;

function GetMessage (token VARCHAR2) return varchar2 is
mesg VARCHAR2(100);
begin
  fnd_message.set_name('AR', token);
  mesg := fnd_message.get;
  return mesg;
end;

END AR_ARATAPPM_PKG;

/
