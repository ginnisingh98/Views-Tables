--------------------------------------------------------
--  DDL for Package ISC_DEPOT_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DEPOT_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: iscdepotetlps.pls 120.0 2005/05/25 17:23:27 appldev noship $ */
procedure REPAIR_ORDERS_F_M(
                        p_entity_name in varchar2,
                        p_from_id in number,
                        p_to_id in out nocopy number,
                        p_from_fk_id in number,
                        p_to_fk_id in number,
                        p_parent_entity_name in varchar2,
                        p_batch_id in number,
                        p_batch_party_id in number,
                        p_return_status in out nocopy varchar2);
end ISC_DEPOT_PARTY_MERGE_PKG;

 

/
