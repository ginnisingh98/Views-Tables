--------------------------------------------------------
--  DDL for Package IEU_UWQM_WS_ASSCT_PROPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQM_WS_ASSCT_PROPS_PKG" AUTHID CURRENT_USER as
/* $Header: IEUWRAPS.pls 120.1 2005/06/15 22:12:56 appldev  $ */

procedure insert_row(
x_rowid in out NOCOPY Varchar2,
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_tasks_rules_function IN varchar2
);

procedure lock_row(
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_tasks_rules_function IN varchar2,
p_object_version_number in number
);

procedure update_row(
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_tasks_rules_function IN varchar2
);

procedure delete_row(
p_ws_association_prop_id in number
);

procedure load_row(
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_owner in varchar2,
p_tasks_rules_function IN varchar2
);

procedure load_seed_row(
p_upload_mode in varchar2,
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_owner in varchar2,
p_tasks_rules_function IN varchar2
);

END IEU_UWQM_WS_ASSCT_PROPS_PKG;

 

/
