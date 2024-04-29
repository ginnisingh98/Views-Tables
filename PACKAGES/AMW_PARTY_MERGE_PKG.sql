--------------------------------------------------------
--  DDL for Package AMW_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: amwhzmrs.pls 120.0 2006/05/31 16:05:17 yreddy noship $ */
/*===========================================================================*/


PROCEDURE party_merge
    (p_entity_name        in  varchar2,
     p_from_id            in  number,
     p_to_id              out nocopy number,
     p_from_fk_id         in  number,
     p_to_fk_id           in  number,
     p_parent_entity_name in  varchar2,
     p_batch_id           in  number,
     p_batch_party_id     in  number,
     p_return_status      out nocopy varchar2);

END AMW_PARTY_MERGE_PKG;

 

/
