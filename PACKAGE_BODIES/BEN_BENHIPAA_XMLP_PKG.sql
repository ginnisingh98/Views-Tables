--------------------------------------------------------
--  DDL for Package Body BEN_BENHIPAA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENHIPAA_XMLP_PKG" AS
/* $Header: BENHIPAAB.pls 120.1.12010000.3 2009/02/04 15:02:14 sagnanas ship $ */

function CF_STANDARD_HEADERFormula return Number is
begin


  return 1;
end;

function cf_wait_start_dtformula(coverage_end_date in date, orgnl_enrt_dt in date, wait_perd_strt_dt in date, per_cm_prvdd_id in number) return char is
  l_date  varchar(20)  := 'N/A' ;
begin
   begin
     update_pcd_sent_dt(p_per_cm_prvdd_id  => per_cm_prvdd_id
               ,p_effective_Date   => p_effective_Date );

   if (coverage_end_date - orgnl_enrt_dt) < 365 then
       l_date := to_char(wait_perd_strt_dt,'MM/DD/RR') ;
   end if ;
   Return l_date ;
   end;
end;

function cf_wait_perd_cmpltn_dtformula(coverage_end_date in date, orgnl_enrt_dt in date, wait_ped_cmpln_dt in date) return char is
 l_date  varchar2(20) ;
begin
   if (coverage_end_date - orgnl_enrt_dt) < 365 then
       l_date := to_char(wait_ped_cmpln_dt,'MM/DD/RR') ;
   end if ;
   Return l_date ;
end;

PROCEDURE update_pcd_sent_dt(p_per_cm_prvdd_id in number
                             ,p_effective_Date in date ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   update ben_per_cm_prvdd_f
     set sent_Dt = p_effective_Date
      where per_cm_prvdd_id = p_per_cm_prvdd_id
        and  sent_dt is null
        and   p_effective_Date between
              effective_Start_date and
              effective_end_Date  ;
   commit;
END;

function AfterReport return boolean is
begin
   -- hr_standard.event('AFTER REPORT');
   return (TRUE);
end;

function BeforeReport return boolean is
begin
   -- hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END BEN_BENHIPAA_XMLP_PKG ;

/
