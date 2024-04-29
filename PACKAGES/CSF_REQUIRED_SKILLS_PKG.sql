--------------------------------------------------------
--  DDL for Package CSF_REQUIRED_SKILLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_REQUIRED_SKILLS_PKG" AUTHID CURRENT_USER AS
/* $Header: CSFPRQSS.pls 120.1.12010000.3 2009/09/04 11:30:12 ramchint ship $ */

g_package_name         Constant varchar2(30) := 'csf_required_skills_pkg';
g_called_from_hook     varchar2(1);

PROCEDURE create_row
( p_api_version      in  number
, p_init_msg_list    in  varchar2 default NULL
, p_commit           in  varchar2 default NULL
, p_validation_level in  number default NULL
, x_return_status    out nocopy varchar2
, x_msg_count        out nocopy number
, x_msg_data         out nocopy varchar2
, p_task_id          in  number
, p_skill_type_id    in  number
, p_skill_id         in  number
, p_skill_level_id   in  number
, p_disabled_flag    in varchar2 default null); --new parameter added for bug 6978751

PROCEDURE create_row_from_tpl
( x_return_status    out nocopy varchar2 );

PROCEDURE create_row_based_on_product
( x_return_status    out nocopy varchar2 );

--
   --new procedure added for bug 6978751
   --
   PROCEDURE create_row_for_child_tasks
   ( x_return_status    out nocopy varchar2 );


END CSF_REQUIRED_SKILLS_PKG;

/
