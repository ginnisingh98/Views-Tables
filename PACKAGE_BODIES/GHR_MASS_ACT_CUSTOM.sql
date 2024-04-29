--------------------------------------------------------
--  DDL for Package Body GHR_MASS_ACT_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MASS_ACT_CUSTOM" AS
/* $Header: ghmascus.pkb 120.0.12010000.1 2008/07/28 10:32:34 appldev ship $ */

g_package  varchar2(32) := 'GHR_MASS_ACT_CUSTOM';
l_mass_errbuf   varchar2(2000) := null;

procedure pre_insert ( p_cust_in_rec in ghr_mass_custom_in_rec_type,
                       p_cust_rec in out nocopy ghr_mass_custom_out_rec_type) is
   l_cust_rec ghr_mass_custom_out_rec_type;
BEGIN

  initialize_out_param(p_cust_rec);

exception
  when others then
	p_cust_rec := l_cust_rec;

END pre_insert;

procedure initialize_out_param(p_cust_rec in out nocopy ghr_mass_custom_out_rec_type)
is
 l_cust_rec ghr_mass_custom_out_rec_type;

begin

   --For nocopy changes.
   l_cust_rec := p_cust_rec;
   p_cust_rec.user_attribute1 := NULL;
   p_cust_rec.user_attribute2 := NULL;
   p_cust_rec.user_attribute3 := NULL;
   p_cust_rec.user_attribute4 := NULL;
   p_cust_rec.user_attribute5 := NULL;
   p_cust_rec.user_attribute6 := NULL;
   p_cust_rec.user_attribute7 := NULL;
   p_cust_rec.user_attribute8 := NULL;
   p_cust_rec.user_attribute9 := NULL;
   p_cust_rec.user_attribute10 := NULL;
   p_cust_rec.user_attribute11 := NULL;
   p_cust_rec.user_attribute12 := NULL;
   p_cust_rec.user_attribute13 := NULL;
   p_cust_rec.user_attribute14 := NULL;
   p_cust_rec.user_attribute15 := NULL;
   p_cust_rec.user_attribute16 := NULL;
   p_cust_rec.user_attribute17 := NULL;
   p_cust_rec.user_attribute18 := NULL;
   p_cust_rec.user_attribute19 := NULL;
   p_cust_rec.user_attribute20 := NULL;
   p_cust_rec.user_attribute21 := NULL;
   p_cust_rec.user_attribute22 := NULL;
   p_cust_rec.user_attribute23 := NULL;
   p_cust_rec.user_attribute24 := NULL;
   p_cust_rec.user_attribute25 := NULL;
   p_cust_rec.user_attribute26 := NULL;
   p_cust_rec.user_attribute27 := NULL;
   p_cust_rec.user_attribute28 := NULL;
   p_cust_rec.user_attribute29 := NULL;
   p_cust_rec.user_attribute30 := NULL;

exception
  when others then
	p_cust_rec := l_cust_rec;

end;

END GHR_MASS_ACT_CUSTOM;

/
