--------------------------------------------------------
--  DDL for Package IEU_UWQM_WORK_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQM_WORK_SOURCES_PKG" AUTHID CURRENT_USER as
/* $Header: IEUWRWSS.pls 120.1 2005/06/15 22:15:58 appldev  $ */

procedure insert_row(
x_rowid in out NOCOPY Varchar2,
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_ws_code in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_active_flag varchar2 DEFAULT NULL
);

procedure lock_row(
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_object_version_number in number
);

procedure update_row(
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_active_flag varchar2 DEFAULT NULL
);

procedure delete_row(
p_ws_id in number
);

procedure add_language;

procedure load_row(
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_owner in varchar2,
p_ws_code in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_active_flag varchar2 DEFAULT NULL
);

procedure translate_row(
p_ws_id in number,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_owner in varchar2
);

procedure load_seed_row(
p_upload_mode in varchar2,
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_owner in varchar2,
p_ws_code in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_active_flag varchar2 DEFAULT NULL
);


END IEU_UWQM_WORK_SOURCES_PKG;

 

/
