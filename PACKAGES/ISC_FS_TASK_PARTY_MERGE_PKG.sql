--------------------------------------------------------
--  DDL for Package ISC_FS_TASK_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_TASK_PARTY_MERGE_PKG" 
/* $Header: iscfshzmgs.pls 120.0 2005/08/28 14:57:41 kreardon noship $ */
AUTHID CURRENT_USER as

procedure task_merge_party
( p_entity_name        in varchar2
, p_from_id            in number
, x_to_id              out nocopy number
, p_from_fk_id         in number
, p_to_fk_id           in number
, p_parent_entity_name in varchar2
, p_batch_id           in number
, p_batch_party_id     in number
, x_return_status      out nocopy varchar2
);

procedure task_merge_address
( p_entity_name        in varchar2
, p_from_id            in number
, x_to_id              out nocopy number
, p_from_fk_id         in number
, p_to_fk_id           in number
, p_parent_entity_name in varchar2
, p_batch_id           in number
, p_batch_party_id     in number
, x_return_status      out nocopy varchar2
);

end isc_fs_task_party_merge_pkg;

 

/
