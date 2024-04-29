--------------------------------------------------------
--  DDL for Package AD_PATCH_HIST_REPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PATCH_HIST_REPS" AUTHID CURRENT_USER as
/* $Header: adphreps.pls 115.11 2004/06/02 11:57:32 sallamse ship $ */

function get_concat_mergepatches(p_ptch_drvr_id number) return varchar2;
pragma restrict_references(get_concat_mergepatches, WNDS, WNPS);

function get_concat_minipks(p_ptch_drvr_id number) return varchar2;
pragma restrict_references(get_concat_minipks, WNDS, WNPS);

function get_level_if_one(p_app_ptch_id number) return varchar2;
pragma restrict_references(get_level_if_one, WNDS, WNPS);

function printClobOut(result IN OUT NOCOPY CLOB,line_num in number)
     return number;

function writeStrToDb(lineCounter number,
                      inStr       varchar2) return number;

function printBeginXML(line_num in number,is_patch boolean) return number;

function printEndXML(line_num in number) return number;

procedure populate_search_results
( p_query_depth       varchar2  default 1, -- PATCHES/BUGS/ACTIONS
  p_bug_num           varchar2  default NULL,
  p_bug_prod_abbr     varchar2  default NULL,
  p_end_dt_from_v     varchar2  default NULL,
  p_end_dt_to_v       varchar2  default NULL,
  p_patch_nm          varchar2  default NULL,
  p_patch_type        varchar2  default NULL,
  p_level             varchar2  default NULL,
  p_lang              varchar2  default NULL,
  p_appltop_nm        varchar2  default NULL,
  p_limit_to_forms    boolean   default FALSE,
  p_limit_to_node     boolean   default FALSE,
  p_limit_to_web      boolean   default FALSE,
  p_limit_to_admin    boolean   default FALSE,
  p_limit_to_db_drvrs boolean   default FALSE,
  p_report_format     varchar2);

end ad_patch_hist_reps;

 

/
