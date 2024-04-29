--------------------------------------------------------
--  DDL for Package Body PA_PRC_PROJECT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PRC_PROJECT_PUB" AS
/*$Header: PAXPRCPB.pls 115.1 99/07/16 15:30:30 porting ship  $*/
--Global constants to be used in error messages
--
-- ================================================
--
--Name       : PRC_Row_Exists
--Type       : Function
--Description:	This function can be used to check against PRC
--             tables for given PRC Assignment Id.
--
--         This function returns 1 if row exists for Assignment id or
--         and returns 0 if no row is found.
--
--Called subprograms: N/A
--
--History:
--    	24-SEP-1998        Sakthivel     	Created
--
--  HISTORY
--   21-SEP-98      Sakthivel       Created
--
Function PRC_Row_exists (x_assignment_id  IN number) return number
is
   x_assign_id number;

   cursor c1 is
      select 1
      from sys.dual
      where exists (select prc_assignment_id
      from pa_mc_exp_items_all
         where prc_assignment_id = x_assignment_id);

   c1_rec c1%rowtype;

   cursor c2 is
      select 1
      from sys.dual
      where exists (select prc_assignment_id
      from pa_mc_cost_dist_lines_all
         where prc_assignment_id = x_assignment_id);

   c2_rec c2%rowtype;

   cursor c3 is
      select 1
      from sys.dual
      where exists (select prc_assignment_id
      from pa_mc_cust_rdl_all
         where prc_assignment_id = x_assignment_id);

   c3_rec c3%rowtype;

   cursor c4 is
      select 1
      from sys.dual
      where exists (select prc_assignment_id
      from pa_mc_cust_event_rdl_all
         where prc_assignment_id = x_assignment_id);

   c4_rec c4%rowtype;

   cursor c5 is
      select 1
      from sys.dual
      where exists (select prc_assignment_id
      from pa_mc_events
         where prc_assignment_id = x_assignment_id);

   c5_rec c5%rowtype;
/*
   cursor c6 is
      select 1
      from sys.dual
      where exists (select prc_assignment_id
      from pa_mc_budget_lines
         where prc_assignment_id = x_assignment_id);

   c6_rec c6%rowtype;

   cursor c7 is
      select 1
      from sys.dual
      where exists (select prc_assignment_id
      from pa_mc_commitment_txns
         where prc_assignment_id = x_assignment_id);

   c7_rec c7%rowtype;
*/

begin

   if (x_assignment_id is null) then
      return(null);
   end if;

   open c1;
   fetch c1 into c1_rec;
   if c1%found then
      close c1;
      return(1);
   end if;

   close c1;

   open c2;
   fetch c2 into c2_rec;
   if c2%found then
      close c2;
      return(1);
   end if;

   close c2;

   open c3;
   fetch c3 into c3_rec;
   if c3%found then
      close c3;
      return(1);
   end if;

   close c3;

   open c4;
   fetch c4 into c4_rec;
   if c4%found then
      close c4;
      return(1);
   end if;

   close c4;

   open c5;
   fetch c5 into c5_rec;
   if c5%found then
      close c5;
      return(1);
   end if;

   close c5;
/*
   open c6;
   fetch c6 into c6_rec;
   if c6%found then
      close c6;
      return(1);
   end if;

   close c6;

   open c7;
   fetch c7 into c7_rec;
   if c7%found then
      close c7;
      return(1);
   end if;

   close c7;
*/
   return(0);

exception
   when others then
         return (SQLCODE);
end PRC_Row_exists;
--------------------------------------------------------------------------------
end PA_PRC_PROJECT_PUB;

/
