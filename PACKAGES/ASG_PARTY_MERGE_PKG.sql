--------------------------------------------------------
--  DDL for Package ASG_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: asgtcaps.pls 120.1 2005/08/12 02:58:44 saradhak noship $*/

--
-- DESCRIPTION
--   This package handles the Party Merge issue in the Table
--      1. ASG_PARTY_ACC        (Used by Service)
--      2. ASG_MOBILE_ACCESSES  (Used by Sales)
--

  PROCEDURE PARTY_ACC_MERGE (p_Entity_name           IN varchar2,
                                   p_From_id               IN Number,
                                   x_To_id                 IN OUT nocopy Number ,
                                   p_From_FK_id            IN Number,
                                   p_To_FK_id              IN Number,
                                   p_Parent_Entity_name    IN Varchar2,
                                   p_batch_id              IN Number,
                                   p_Batch_Party_id        IN Number,
                                   x_return_status         OUT nocopy Varchar2) ;

  PROCEDURE MOBILE_ACC_PARTY_MERGE (p_Entity_name           IN varchar2,
                   p_From_id               IN Number,
                   x_To_id                 IN OUT nocopy Number,
                   p_From_FK_id            IN Number,
                   p_To_FK_id              IN Number,
                   p_Parent_Entity_name    IN Varchar2,
                   p_batch_id              IN Number,
                   p_Batch_Party_id        IN Number,
                   x_return_status         OUT nocopy Varchar) ;

END ASG_PARTY_MERGE_PKG;

 

/
