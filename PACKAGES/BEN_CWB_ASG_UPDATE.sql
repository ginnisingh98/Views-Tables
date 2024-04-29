--------------------------------------------------------
--  DDL for Package BEN_CWB_ASG_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_ASG_UPDATE" AUTHID CURRENT_USER as
/* $Header: bencwbau.pkh 120.1.12000000.1 2007/01/19 15:19:38 appldev noship $ */
/* ===========================================================================+
 * Name
 *   Compensation Workbench Transaction Update Package
 * Purpose
 *   This package is used to insert record into ben_transaction table
 *   when performance rating or promotion details
 *   are updated on the Worksheet.
 *
 * Version Date        Author    Comment
 * -------+-----------+---------+----------------------------------------------
 * 115.0   15-Feb-2003 maagrawa   created
 * 115.1   12-Jan-2004 maagrawa   Global Budgeting change.
 * 115.2   16-Mar-2004 aprabhak   Added delete_transaction to specification
 * 115.3   25-Mar-2004 maagrawa   Add p_person_name as parameter.
 * 115.4   29-Mar-2004 maagrawa   Update ben_cwb_person_info with perf/promo
 *                                ids when called from PP.
 * 115.5   25-May-2004 maagrawa   Perf/Promo record split.
 * 115.6   10-Feb-2005 maagrawa   Pass group_pl_id as plan reference to
 *                                process_rating, process_promotions.
 * 115.7   20-Sep-2006 steotia    5531065: Using Performance Overrides (but
 *                                only if used through SS)
 * ==========================================================================+
 */
g_ws_asg_rec_type  varchar2(30) := 'CWBASG';
g_ws_perf_rec_type varchar2(30) := 'CWBPERF';

cursor g_txn(v_txn_id                 number,
             v_txn_type               varchar2) is
     select txn.attribute1
           ,txn.attribute2
           ,txn.attribute3
           ,txn.attribute4
           ,txn.attribute5
           ,txn.attribute6
           ,txn.attribute7
           ,txn.attribute8
           ,txn.attribute9
           ,txn.attribute10
           ,txn.attribute11
           ,txn.attribute12
           ,txn.attribute13
           ,txn.attribute14
           ,txn.attribute15
           ,txn.attribute16
           ,txn.attribute17
           ,txn.attribute18
           ,txn.attribute19
           ,txn.attribute20
           ,txn.attribute21
           ,txn.attribute22
           ,txn.attribute23
           ,txn.attribute24
           ,txn.attribute25
           ,txn.attribute26
           ,txn.attribute27
           ,txn.attribute28
           ,txn.attribute29
           ,txn.attribute30
           ,txn.attribute31
           ,txn.attribute32
           ,txn.attribute33
           ,txn.attribute34
           ,txn.attribute35
           ,txn.attribute36
           ,txn.attribute37
           ,txn.attribute38
           ,txn.attribute39
           ,txn.attribute40
           ,txn.transaction_id assignment_id
     from   ben_transaction txn
     where  txn.transaction_id = v_txn_id
     and    txn.transaction_type = v_txn_type;

procedure process_rating
                  (p_person_id              in  number
                  ,p_txn_rec                in  g_txn%rowtype
                  ,p_business_group_id      in  number
                  ,p_audit_log              in  varchar2 default 'N'
                  ,p_process_status         in out nocopy varchar2
                  ,p_group_per_in_ler_id    in number default null
		  ,p_effective_date         in date);

procedure process_promotions
                  (p_person_id              in  number
                  ,p_asg_txn_rec            in  g_txn%rowtype
                  ,p_business_group_id      in  number
                  ,p_audit_log              in  varchar2 default 'N'
                  ,p_process_status         in out nocopy varchar2
                  ,p_group_per_in_ler_id    in number default null
		  ,p_effective_date         in date);

procedure delete_transaction
                  (p_transaction_id in number
                  ,p_transaction_type in varchar2);


procedure process_rating
    (p_validate_data          in varchar2 default 'Y'
    ,p_assignment_id          in number
    ,p_person_id              in number
    ,p_business_group_id      in number
    ,p_perf_revw_strt_dt      in varchar2
    ,p_perf_type              in varchar2
    ,p_perf_rating            in varchar2
    ,p_person_name            in varchar2
    ,p_update_person_id       in number
    ,p_update_date            in date
    ,p_group_pl_id            in number);

procedure process_promotions
     (p_validate_data          in varchar2 default 'Y'
     ,p_assignment_id          in number
     ,p_person_id              in number
     ,p_business_group_id      in number
     ,p_asg_updt_eff_date      in varchar2
     ,p_change_reason          in varchar2
     ,p_job_id                 in number
     ,p_position_id            in number
     ,p_grade_id               in number
     ,p_people_group_id        in number
     ,p_soft_coding_keyflex_id in number
     ,p_ass_attribute1         in varchar2
     ,p_ass_attribute2         in varchar2
     ,p_ass_attribute3         in varchar2
     ,p_ass_attribute4         in varchar2
     ,p_ass_attribute5         in varchar2
     ,p_ass_attribute6         in varchar2
     ,p_ass_attribute7         in varchar2
     ,p_ass_attribute8         in varchar2
     ,p_ass_attribute9         in varchar2
     ,p_ass_attribute10        in varchar2
     ,p_ass_attribute11        in varchar2
     ,p_ass_attribute12        in varchar2
     ,p_ass_attribute13        in varchar2
     ,p_ass_attribute14        in varchar2
     ,p_ass_attribute15        in varchar2
     ,p_ass_attribute16        in varchar2
     ,p_ass_attribute17        in varchar2
     ,p_ass_attribute18        in varchar2
     ,p_ass_attribute19        in varchar2
     ,p_ass_attribute20        in varchar2
     ,p_ass_attribute21        in varchar2
     ,p_ass_attribute22        in varchar2
     ,p_ass_attribute23        in varchar2
     ,p_ass_attribute24        in varchar2
     ,p_ass_attribute25        in varchar2
     ,p_ass_attribute26        in varchar2
     ,p_ass_attribute27        in varchar2
     ,p_ass_attribute28        in varchar2
     ,p_ass_attribute29        in varchar2
     ,p_ass_attribute30        in varchar2
     ,p_person_name            in varchar2
     ,p_update_person_id       in number
     ,p_update_date            in date
     ,p_group_pl_id            in number);

end ben_cwb_asg_update;

 

/
