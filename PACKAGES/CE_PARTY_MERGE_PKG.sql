--------------------------------------------------------
--  DDL for Package CE_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: ceptymrs.pls 120.0 2005/09/29 23:41:50 lkwan ship $ */


PROCEDURE bank_merge(
            p_Entity_name            IN       VARCHAR2,
            p_from_id                IN       NUMBER,
            p_to_id                  IN OUT NOCOPY  NUMBER,
            p_From_FK_id             IN       NUMBER,
            p_To_FK_id               IN       NUMBER,
            p_Parent_Entity_name     IN       VARCHAR2,
            p_batch_id               IN       NUMBER,
            p_Batch_Party_id         IN       NUMBER,
            x_return_status          IN OUT NOCOPY  VARCHAR2    )   ;

PROCEDURE branch_merge(
            p_Entity_name            IN       VARCHAR2,
            p_from_id                IN       NUMBER,
            p_to_id                  IN OUT NOCOPY  NUMBER,
            p_From_FK_id             IN       NUMBER,
            p_To_FK_id               IN       NUMBER,
            p_Parent_Entity_name     IN       VARCHAR2,
            p_batch_id               IN       NUMBER,
            p_Batch_Party_id         IN       NUMBER,
            x_return_status          IN OUT NOCOPY  VARCHAR2    )   ;

END CE_PARTY_MERGE_PKG;

 

/
