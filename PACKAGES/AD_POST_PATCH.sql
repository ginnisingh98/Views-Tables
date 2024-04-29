--------------------------------------------------------
--  DDL for Package AD_POST_PATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_POST_PATCH" AUTHID CURRENT_USER as
/* $Header: adpostps.pls 120.1 2005/10/17 05:15:48 rahkumar noship $ */

procedure get_patched_files
(
  p_appltop_id          number,
  p_file_extension_list varchar2 default NULL,
  p_applsys_user_name   varchar2
);

procedure get_files
(
  p_appltop_id          number,
  p_start_date          varchar2
);

procedure get_all_files
(
  p_appltop_id          number
);

procedure get_all_files
(
  p_appltop_id          number,
  p_start_date          varchar2,
  p_end_date            varchar2,
  p_file_extension_list varchar2 default NULL
);

procedure set_gathered_flag
(
  p_appltop_id          number
);


end ad_post_patch;

 

/
