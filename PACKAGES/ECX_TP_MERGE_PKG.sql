--------------------------------------------------------
--  DDL for Package ECX_TP_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_TP_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: ECXPMRGS.pls 115.6 2003/07/01 21:19:54 rdiwan ship $ */

PROCEDURE ecx_party_merge(p_Entity_name                 IN      VARCHAR2,
                           p_from_id                    IN      NUMBER,
                           x_to_id                      OUT     NOCOPY NUMBER,
                           p_From_FK_id                 IN      NUMBER,
                           p_To_FK_id                   IN      NUMBER,
                           p_Parent_Entity_name         IN      VARCHAR2,
                           p_Batch_id                   IN      NUMBER,
                           p_Batch_Party_id             IN      NUMBER,
                           x_return_status              OUT     NOCOPY VARCHAR2
                          );


PROCEDURE ecx_party_sites_merge(
                           p_Entity_name                IN      VARCHAR2,
                           p_from_id                    IN      NUMBER,
                           x_to_id                      OUT     NOCOPY NUMBER,
                           p_From_FK_id                 IN      NUMBER,
                           p_To_FK_id                   IN      NUMBER,
                           p_Parent_Entity_name         IN      VARCHAR2,
                           p_Batch_id                   IN      NUMBER,
                           p_Batch_Party_id             IN      NUMBER,
                           x_return_status              OUT     NOCOPY VARCHAR2
                          );

End;

 

/
