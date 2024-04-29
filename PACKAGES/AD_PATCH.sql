--------------------------------------------------------
--  DDL for Package AD_PATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PATCH" AUTHID CURRENT_USER as
/* $Header: adphpchs.pls 120.5 2007/12/14 13:09:13 diverma ship $ */

/* Public constants for AOL or any caller to use, as well */

NOT_APPLIED   CONSTANT varchar2(30) := 'NOT_APPLIED';
IMPLICITLY_APPLIED   CONSTANT varchar2(30) := 'IMPLICIT';
EXPLICITLY_APPLIED   CONSTANT varchar2(30) := 'EXPLICIT';
MANUALLY_APPLIED   CONSTANT varchar2(30) := 'MANUAL';
AD_UNKNOWN   CONSTANT varchar2(30) := 'UNKNOWN';
AD_FILES_ONLY   CONSTANT varchar2(30) := 'FILES_ONLY';

function  is_patch_applied (p_release_name  in varchar2,
                            p_appl_top_id   in number,
                            p_bug_number    in varchar2,
                            p_bug_language  in varchar2)
                            return varchar2;

function  is_patch_applied (p_release_name  in varchar2,
                            p_appl_top_id   in number,
                            p_bug_number    in varchar2)
                            return varchar2;

function  is_codeline_patch_applied (p_release_name in varchar2,
                                p_baseline_name in varchar2,
                                p_appl_top_id in number,
                                p_bug_number in varchar2 )
                                return varchar2;

function is_codeline_patch_applied ( p_release_name in varchar2,
                                     p_baseline_name  in varchar2,
                                     p_appl_top_id   in number,
                                     p_bug_number    in varchar2,
                                     p_language     in varchar2)
                                    return varchar2;

function is_file_copied (p_application_short_name in varchar2,
                         p_appl_top_id in number,
                         p_object_location in varchar2,
                         p_object_name in varchar2,
                         p_object_version in varchar2)
                         return varchar2;

procedure mark_patch_succ(p_patch_run_id in NUMBER ,
                          p_appl_top_id in number,
                          p_release_name in varchar2,
                          p_flag in varchar2,
                          p_reason_text in varchar2);

procedure mark_bug_succ(p_patch_run_id in NUMBER ,
                        p_appl_top_id in number,
                        p_release_name in varchar2,
                        p_bug_number in varchar2,
                        p_flag in varchar2,
                        p_reason_text in varchar2);

procedure set_patch_status(p_release_name in varchar2,
                           p_appl_top_id in number,
                           p_bug_number in varchar2,
                           p_bug_status in varchar2);

function getAppltopID(p_appl_top_name in varchar2,
                      p_app_sys_name in varchar2,
                      p_appl_top_type in varchar2)
                      return number;

/*****************************************************************************
  Compare passed versions of files to determine which is greater,
  the one requested by caller or the one in database.

  Returns:
    Returns TRUE if p_version_indb >= p_version.
*****************************************************************************/
function compare_versions(p_version      in varchar2,
                          p_version_indb in varchar2)
         return boolean;

end ad_patch;

/
