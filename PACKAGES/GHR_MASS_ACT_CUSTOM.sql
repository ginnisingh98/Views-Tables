--------------------------------------------------------
--  DDL for Package GHR_MASS_ACT_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MASS_ACT_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: ghmascus.pkh 120.0.12010000.1 2008/07/28 10:32:36 appldev ship $ */


type ghr_mass_custom_in_rec_type is record
(person_id              number,
 position_id            number,
 assignment_id          number,
 national_identifier    varchar2(30),
 mass_action_type       VARCHAR2(30),
 mass_action_id         number,
 effective_date         date
);

type ghr_mass_custom_out_rec_type is record
(user_attribute1     ghr_mass_actions_preview.user_attribute1%type
,user_attribute2     ghr_mass_actions_preview.user_attribute2%type
,user_attribute3     ghr_mass_actions_preview.user_attribute3%type
,user_attribute4     ghr_mass_actions_preview.user_attribute4%type
,user_attribute5     ghr_mass_actions_preview.user_attribute5%type
,user_attribute6     ghr_mass_actions_preview.user_attribute6%type
,user_attribute7     ghr_mass_actions_preview.user_attribute7%type
,user_attribute8     ghr_mass_actions_preview.user_attribute8%type
,user_attribute9     ghr_mass_actions_preview.user_attribute9%type
,user_attribute10    ghr_mass_actions_preview.user_attribute10%type
,user_attribute11    ghr_mass_actions_preview.user_attribute11%type
,user_attribute12    ghr_mass_actions_preview.user_attribute12%type
,user_attribute13    ghr_mass_actions_preview.user_attribute13%type
,user_attribute14    ghr_mass_actions_preview.user_attribute14%type
,user_attribute15    ghr_mass_actions_preview.user_attribute15%type
,user_attribute16    ghr_mass_actions_preview.user_attribute16%type
,user_attribute17    ghr_mass_actions_preview.user_attribute17%type
,user_attribute18    ghr_mass_actions_preview.user_attribute18%type
,user_attribute19    ghr_mass_actions_preview.user_attribute19%type
,user_attribute20    ghr_mass_actions_preview.user_attribute20%type
,user_attribute21    ghr_mass_actions_preview.user_attribute21%type
,user_attribute22    ghr_mass_actions_preview.user_attribute22%type
,user_attribute23    ghr_mass_actions_preview.user_attribute23%type
,user_attribute24    ghr_mass_actions_preview.user_attribute24%type
,user_attribute25    ghr_mass_actions_preview.user_attribute25%type
,user_attribute26    ghr_mass_actions_preview.user_attribute26%type
,user_attribute27    ghr_mass_actions_preview.user_attribute27%type
,user_attribute28    ghr_mass_actions_preview.user_attribute28%type
,user_attribute29    ghr_mass_actions_preview.user_attribute29%type
,user_attribute30    ghr_mass_actions_preview.user_attribute30%type
);

procedure pre_insert ( p_cust_in_rec in ghr_mass_custom_in_rec_type,
                       p_cust_rec in out nocopy ghr_mass_custom_out_rec_type);

procedure initialize_out_param(p_cust_rec in out nocopy ghr_mass_custom_out_rec_type);

END GHR_MASS_ACT_CUSTOM;

/
