--------------------------------------------------------
--  DDL for Package BEN_EXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_UTIL" AUTHID CURRENT_USER as
/* $Header: benxutil.pkh 120.3.12010000.2 2008/08/05 15:02:07 ubhat ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract Utility.
Purpose:
    This is used for utility style processes for the Benefits Extract System.
History:
    Date             Who        Version    What?
    ----             ---        -------    -----
    24 Oct 98        Ty Hayden  115.0      Created.
    25 Oct 98        Ty Hayden  115.1      Added request_id as input.
    04 Feb 99        Pulak Das  115.2      Added procedure
                                           get_rec_nam_num,
                                           get_rec_statistics,
                                           get_per_statistics,
                                           get_err_warn_statitics.
    08 Feb 99        Pulak Das  115.3      Added function
                                           get_value (from benxsttl.pkh)
    15 Feb 99        Ty Hayden  115.4      Added ff function
                                           get_extract_value
    09 Mar 99        G Perry    115.5      IS to AS.
    13 May 99        I Sen      115.6      Added cal_ext_date function
                                           (earlier in benxthrd)
    16 Jun 99        I Sen      115.7      Added foreign key ref ext_rslt_id
    03 Sep 99        Ty Hayden  115.8      Added procedure get_chg_dates.
    13 Sep 99        Ty Hayden  115.9      Added get_cm_dates.
    15 Nov 99        Ty Hayden  115.10     Added get_ext_dates.
    30 Dec 99        Ty Hayden  115.11     Remove get_extract_value.
    22 dec 02        tjesumic   115.12     dbdrv added
    24-Dec-02         bmanyam   115.13     NOCOPY Changes
    15-Dec-04        tjesumic   115.14     pl_pl_id added to calc_ext_dates
    01-Nov-06        tjesumic   115.15     entries_affected procedire moved from pqp to ben
    30-Apr-08        vkodedal   115.16     entries_affected - added one parameter for penserver
*/
-----------------------------------------------------------------------------------
--
  g_package  varchar2(33)	:= 'ben_ext_util';  -- Global package name
--
  Type g_rec_nam_num_rec_typ is record
  (name        ben_ext_rcd.name%type
  ,num         number);
--
  Type g_rec_nam_num_tab_typ is table
  of g_rec_nam_num_rec_typ
  Index by binary_integer;
--
  g_err_name     varchar2(50);
  g_job_failure  exception;
--
PROCEDURE write_err
    (p_err_num                        in  number    default null,
     p_err_name                       in  varchar2  default null,
     p_typ_cd                         in  varchar2  default null,
     p_person_id                      in  number    default null,
     p_request_id                     in  number    default null,
     p_business_group_id              in  number    default null,
     p_ext_rslt_id                    in  number    default null);
--
-- This procedure will return a data structure containing the name and number
-- of all extracted records corresponding to a ext_rslt_id or request_id or both.
-- If no records are found then one record with value null, 0 will be returned.
-- If both ext_rslt_id and request_id are passed and if they do not correspond
-- to each other then one record with value null, 0 will be returned.
--
Procedure get_rec_nam_num
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_rec_tab            out nocopy    g_rec_nam_num_tab_typ
          );
--
-- This procedure will return total header records, total detail records,
-- total trailer records corresponding to a ext_rslt_id or request_id or both.
-- If both ext_rslt_id and request_id are passed and if they do not correspond
-- to each other then 0, 0, 0 will be returned.
--
procedure get_rec_statistics
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_header_rec         out nocopy    number
          ,p_detail_rec         out nocopy    number
          ,p_trailer_rec        out nocopy    number
          );
--
-- This procedure will return total people extracted, total people not
-- extracted due to error corresponding to a ext_rslt_id or request_id or both.
-- If both ext_rslt_id and request_id are passed and if they do not correspond
-- to each other then 0, 0, 0 will be returned.
--
procedure get_per_statistics
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_per_xtrctd         out nocopy    number
          ,p_per_not_xtrctd     out nocopy    number
          );
--
-- This procedure will return total job failures, total errors,
-- total warnings corresponding to a ext_rslt_id or request_id or both.
-- If both ext_rslt_id and request_id are passed and if they do not correspond
-- to each other then 0, 0, 0 will be returned.
--
procedure get_err_warn_statistics
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_job_failure        out nocopy    number
          ,p_error              out nocopy    number
          ,p_warning            out nocopy    number
          );
--
procedure get_statistics_text
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_text               out nocopy    varchar2
          );
--
Function get_value(p_ext_rcd_id       number,
                   p_ext_rslt_dtl_id  number,
                   p_seq_num          number)
RETURN varchar2;
--
procedure get_chg_dates
          (p_ext_dfn_id       in number,
           p_effective_date   in date,
           p_chg_actl_strt_dt out nocopy date,
           p_chg_actl_end_dt  out nocopy date,
           p_chg_eff_strt_dt  out nocopy date,
           p_chg_eff_end_dt   out nocopy date);
--
procedure get_cm_dates
          (p_ext_dfn_id       in number,
           p_effective_date   in date,
           p_to_be_sent_strt_dt out nocopy date,
           p_to_be_sent_end_dt  out nocopy date);
--
procedure get_ext_dates
          (p_ext_dfn_id       in number,
           p_data_typ_cd      in varchar2,
           p_effective_date   in date,
           p_person_ext_dt out nocopy date,
           p_benefits_ext_dt out nocopy date
           );
--
-- This function is for converting relative date to absolute date
--
Function calc_ext_date
   (p_ext_date_cd    in varchar2,
    p_abs_date       in date,
    p_ext_dfn_id     in number,
    p_pl_id         in number default null
   ) return date;
--
PROCEDURE entries_affected
    (p_assignment_id          IN  NUMBER DEFAULT NULL
    ,p_event_group_id         IN  NUMBER DEFAULT NULL
    ,p_mode                   IN  VARCHAR2 DEFAULT NULL
    ,p_start_date             IN  DATE  DEFAULT hr_api.g_sot
    ,p_end_date               IN  DATE  DEFAULT hr_api.g_eot
    ,p_business_group_id      IN  NUMBER
    ,p_detailed_output        OUT NOCOPY  pay_interpreter_pkg.t_detailed_output_table_type
    ,p_process_mode           IN  VARCHAR2 DEFAULT 'ENTRY_CREATION_DATE'
    ,p_penserv_mode           IN  VARCHAR2 DEFAULT 'N'    --vkodedal changes for penserver - 30-apr-2008
    );

END; -- Package spec

/
