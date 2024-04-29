--------------------------------------------------------
--  DDL for Package Body ASG_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_PARTY_MERGE_PKG" AS
/* $Header: asgtcapb.pls 120.1 2005/08/12 02:58:17 saradhak noship $*/

--
--    OBsoleted the procedure for asg_mobile_accesses
--
-- DESCRIPTION
--   This package handles the Party Merge issue in the Table
--      1. ASG_PARTY_ACC        (Used by Service)
--           If the destination party exists then
--              add the counters of the 2 party's (TO and FROM).
--           ELSE
--              set from_party_id = to_party_id.
--
--      2. ASG_MOBILE_ACCESSES  (Used by Sales)
--           If the destination party (HZ_PARTY) exists then
--              add the counters of the 2 party's (TO and FROM).
--              IF a HZ_CUSTOMER record also exists then
--                add the counters of the 2 customers's (TO and FROM).
--           ELSE
--              set from_party_id = to_party_id for HZ_PARTY.
--              set from_party_id = to_party_id for HZ_CUSTOMER (If exists).
--

  PROCEDURE PARTY_ACC_MERGE (p_Entity_name           IN varchar2,
                             p_From_id               IN Number,
                             x_To_id                 IN OUT nocopy Number,
                             p_From_FK_id            IN Number,
                             p_To_FK_id              IN Number,
                             p_Parent_Entity_name    IN Varchar2,
                             p_batch_id              IN Number,
                             p_Batch_Party_id        IN Number,
                             x_return_status         OUT nocopy Varchar2) IS
  BEGIN
      null;
    END PARTY_ACC_MERGE;


  PROCEDURE MOBILE_ACC_PARTY_MERGE (p_Entity_name  IN varchar2,
                   p_From_id               IN Number,
                   x_To_id                 IN OUT nocopy Number,
                   p_From_FK_id            IN Number,
                   p_To_FK_id              IN Number,
                   p_Parent_Entity_name    IN Varchar2,
                   p_batch_id              IN Number,
                   p_Batch_Party_id        IN Number,
                   x_return_status         OUT nocopy Varchar) IS
  BEGIN
     null;
  END MOBILE_ACC_PARTY_MERGE;

END ASG_PARTY_MERGE_PKG;

/
