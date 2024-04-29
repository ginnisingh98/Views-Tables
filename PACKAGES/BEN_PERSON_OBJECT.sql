--------------------------------------------------------
--  DDL for Package BEN_PERSON_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_OBJECT" AUTHID CURRENT_USER as
/* $Header: benperde.pkh 120.0.12000000.1 2007/01/19 18:39:39 appldev noship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Person Object Caching Routine
Purpose
	This package is used to return person object information.
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      11-Jun-99  gperry     Created(arcsed in by bbulusu)
  115.1      18-Jun-99  gperry     Added in person_date_info structure to store
                                   the minimum effective date of the person
                                   and the assignment.
                                   Added in fte info structure to store
                                   the total fte for a persons primary
                                   assignment.
                                   Added cache structure to store active
                                   life event.
                                   Added cache structure to store persons
                                   benefits balance.
  115.2      23-Jun-99  gperry     Added in assignment extra info cache.
  115.3      24-Jun-99  gperry     Added in contacts cache.
  115.4      24-Jun-99  gperry     Removed css cache.
  115.5      05-Aug-99  gperry     Added last cached record logic.
  115.6      09-Aug-99  gperry     Added new cache routines.
                                   assignment_status_types
                                   soft_coding_keyflex
                                   person_type_info
  115.7      16-Aug-99  gperry     Added nocopy compiler directive.
  115.8      17-Aug-99  gperry     Removed business group id from
                                   set_ast_object.
  115.9      18-Aug-99  gperry     Added cache for ben_bnfts_bal_f
  115.10     23-Aug-99  gperry     Cache full time info using assignment id.
  115.11     26-Aug-99  gperry     Added cache for benefits assignment.
                                   Added cache for applicants assignment.
                                   Made assignment cache get employee
                                   assignment.
  115.12     26-Aug-99  gperry     Made applicants assignment cache multirow.
  115.22     02 May 00  RChase     Performance NOCOPY changes
  115.14     10 Jul 00  gperry     Added firstass cache for WWBUG 1350997.
  115.15     20 Jul 00  gperry     Removed firstass cache and added allass
                                   cache for WWBUG 1350997.
  115.16     05 Oct 00  gperry     Added ord_id to person type cache.
  115.17     05 Jan 01  kmahendr   Added parameter per_in_ler_id to get_object
  115.18     20-Mar-02  vsethi     added dbdrv lines
  115.19     29-Apr-02  pabodla    Bug 1631182 : Added person_type_id to
                                   g_person_typ_info_rec
  115.20     13 Feb 03  mhoyes   - Fixed PGA memory growth bug 2800680.
  -----------------------------------------------------------------------------
*/
--
type g_person_date_info_rec is record
  (person_id                    number,
   min_per_effective_start_date date,
   min_ass_effective_start_date date);
--
type g_person_fte_info_rec is record
  (assignment_id                number,
   total_fte                    number,
   fte                          number);
--
--Bug 1631182 - Added person_type_id
--
type g_person_typ_info_rec is record
   (person_id                   number,
    person_type_id              number,
    user_person_type            varchar2(80),
    system_person_type          varchar2(30),
    ord_id                      number);
--
-- Global type declarations.
--
type g_cache_per_table is table of per_all_people_f%rowtype index
  by binary_integer;
--
type g_cache_ass_table is table of per_all_assignments_f%rowtype index
  by binary_integer;
--
type g_cache_ast_table is table of per_assignment_status_types%rowtype index
  by binary_integer;
--
type g_cache_aei_table is table of per_assignment_extra_info%rowtype index
  by binary_integer;
--
type g_cache_pps_table is table of per_periods_of_service%rowtype index
  by binary_integer;
--
type g_cache_pad_table is table of per_addresses%rowtype index
  by binary_integer;
--
type g_cache_pil_table is table of ben_per_in_ler%rowtype index
  by binary_integer;
--
type g_cache_bal_table is table of ben_per_bnfts_bal_f%rowtype index
  by binary_integer;
--
type g_cache_bnb_table is table of ben_bnfts_bal_f%rowtype index
  by binary_integer;
--
type g_cache_hsc_table is table of hr_soft_coding_keyflex%rowtype index
  by binary_integer;
--
type g_cache_bal_per_table is table of ben_cache.g_cache_lookup index
  by binary_integer;
--
type g_cache_typ_per_table is table of ben_cache.g_cache_lookup index
  by binary_integer;
--
type g_cache_con_table is table of per_contact_relationships%rowtype index
  by binary_integer;
--
type g_cache_con_per_table is table of ben_cache.g_cache_lookup index
  by binary_integer;
--
type g_cache_app_ass_table is table of ben_cache.g_cache_lookup index
  by binary_integer;
--
type g_cache_all_ass_table is table of ben_cache.g_cache_lookup index
  by binary_integer;
--
type g_cache_date_table is table of g_person_date_info_rec index
  by binary_integer;
--
type g_cache_fte_table is table of g_person_fte_info_rec index
  by binary_integer;
--
type g_cache_typ_table is table of g_person_typ_info_rec index
  by binary_integer;
--
g_cache_per_rec         g_cache_per_table;
g_cache_ass_rec         g_cache_ass_table;
g_cache_benass_rec      g_cache_ass_table;
g_cache_ast_rec         g_cache_ast_table;
g_cache_aei_rec         g_cache_aei_table;
g_cache_pps_rec         g_cache_pps_table;
g_cache_pad_rec         g_cache_pad_table;
g_cache_hsc_rec         g_cache_hsc_table;
g_cache_pil_rec         g_cache_pil_table;
g_cache_bal_rec         g_cache_bal_table;
g_cache_bnb_rec         g_cache_bnb_table;
g_cache_bal_per_rec     g_cache_bal_per_table;
g_cache_typ_rec         g_cache_typ_table;
g_cache_typ_per_rec     g_cache_typ_per_table;
g_cache_con_rec         g_cache_con_table;
g_cache_con_per_rec     g_cache_con_per_table;
g_cache_appass_rec      g_cache_ass_table;
g_cache_app_ass_rec     g_cache_app_ass_table;
g_cache_allass_rec      g_cache_ass_table;
g_cache_all_ass_rec     g_cache_all_ass_table;
g_cache_date_rec        g_cache_date_table;
g_cache_fte_rec         g_cache_fte_table;
--
-- Latest record caches
--
g_cache_last_per_rec      per_all_people_f%rowtype;
g_cache_last_benass_rec   per_all_assignments_f%rowtype;
g_cache_last_ass_rec      per_all_assignments_f%rowtype;
g_cache_last_ast_rec      per_assignment_status_types%rowtype;
g_cache_last_aei_rec      per_assignment_extra_info%rowtype;
g_cache_last_pps_rec      per_periods_of_service%rowtype;
g_cache_last_pad_rec      per_addresses%rowtype;
g_cache_last_hsc_rec      hr_soft_coding_keyflex%rowtype;
g_cache_last_pil_rec      ben_per_in_ler%rowtype;
g_cache_last_date_rec     g_person_date_info_rec;
g_cache_last_fte_rec      g_person_fte_info_rec;
g_cache_last_con_rec      g_cache_con_table;
g_cache_last_appass_rec   g_cache_ass_table;
g_cache_last_allass_rec   g_cache_ass_table;
g_cache_last_typ_rec      g_cache_typ_table;
g_cache_last_bal_rec      ben_per_bnfts_bal_f%rowtype;
g_cache_last_bnb_rec      ben_bnfts_bal_f%rowtype;
--
-- Set object routines
--
procedure set_object
  (p_rec in out nocopy per_all_assignments_f%rowtype);
procedure set_benass_object
  (p_rec in out nocopy per_all_assignments_f%rowtype);
procedure set_appass_object
  (p_rec in out nocopy per_all_assignments_f%rowtype);
procedure set_allass_object
  (p_rec in out nocopy per_all_assignments_f%rowtype);
procedure set_object
  (p_rec in out nocopy per_assignment_status_types%rowtype);
procedure set_object
  (p_rec in out nocopy per_assignment_extra_info%rowtype);
procedure set_object
  (p_rec in out nocopy per_all_people_f%rowtype);
procedure set_object
  (p_rec in out nocopy per_periods_of_service%rowtype);
procedure set_object
  (p_rec in out nocopy per_addresses%rowtype);
procedure set_object
  (p_rec in out nocopy hr_soft_coding_keyflex%rowtype);
procedure set_object
  (p_rec in out nocopy ben_per_in_ler%rowtype);
procedure set_object
  (p_rec in out nocopy ben_bnfts_bal_f%rowtype);
procedure set_object
  (p_rec in out nocopy ben_per_bnfts_bal_f%rowtype);
procedure set_object
  (p_rec in out nocopy per_contact_relationships%rowtype);
procedure set_object
  (p_rec in out nocopy g_person_date_info_rec);
procedure set_object
  (p_rec in out nocopy g_person_fte_info_rec);
procedure set_object
  (p_rec in out nocopy g_person_typ_info_rec);
procedure set_bal_per_object
  (p_rec in out nocopy ben_cache.g_cache_lookup);
procedure set_con_per_object
  (p_rec in out nocopy ben_cache.g_cache_lookup);
procedure set_app_ass_object
  (p_rec in out nocopy ben_cache.g_cache_lookup);
procedure set_all_ass_object
  (p_rec in out nocopy ben_cache.g_cache_lookup);
procedure set_typ_per_object
  (p_rec in out nocopy ben_cache.g_cache_lookup);
--
procedure set_ass_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_all_assignments_f%rowtype);
procedure set_benass_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_all_assignments_f%rowtype);
procedure set_appass_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy g_cache_ass_table);
procedure set_allass_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy g_cache_ass_table);
procedure set_ast_object
  (p_assignment_status_type_id in number,
   p_rec                       in out nocopy per_assignment_status_types%rowtype);
procedure set_bnb_object
  (p_bnfts_bal_id      in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy ben_bnfts_bal_f%rowtype);
procedure set_ass_object
  (p_assignment_id     in number,
   p_rec               in out nocopy per_assignment_extra_info%rowtype);
procedure set_hsc_object
  (p_soft_coding_keyflex_id in number,
   p_rec                    in out nocopy hr_soft_coding_keyflex%rowtype);
procedure set_per_object
  (p_person_id         in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               in out nocopy per_all_people_f%rowtype);
procedure set_pps_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_periods_of_service%rowtype);
procedure set_pad_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_addresses%rowtype);
procedure set_pil_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_per_in_ler_id     in number default null,
   p_rec               in out nocopy ben_per_in_ler%rowtype);
procedure set_bal_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date);
procedure set_con_object
  (p_person_id         in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               in out nocopy g_cache_con_table);
procedure set_typ_object
  (p_person_id         in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               in out nocopy g_cache_typ_table);
procedure set_per_dates_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy g_person_date_info_rec);
procedure set_per_fte_object
  (p_assignment_id     in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy g_person_fte_info_rec);
--
-- Get object routines
--
procedure get_object
  (p_person_id in  number,
   p_rec      in out nocopy per_all_people_f%rowtype);
procedure get_object
  (p_person_id in  number,
   p_rec       in out nocopy per_all_assignments_f%rowtype);
procedure get_benass_object
  (p_person_id in  number,
   p_rec       in out nocopy per_all_assignments_f%rowtype);
procedure get_object
  (p_bnfts_bal_id in  number,
   p_rec          in out nocopy ben_bnfts_bal_f%rowtype);
procedure get_object
  (p_assignment_status_type_id in  number,
   p_rec                       in out nocopy per_assignment_status_types%rowtype);
procedure get_object
  (p_assignment_id in  number,
   p_rec           in out nocopy per_assignment_extra_info%rowtype);
procedure get_object
  (p_person_id in  number,
   p_rec       in out nocopy per_periods_of_service%rowtype);
procedure get_object
  (p_person_id in  number,
   p_rec       in out nocopy per_addresses%rowtype);
procedure get_object
  (p_person_id in  number,
   p_rec       in out nocopy g_cache_con_table);
procedure get_object
  (p_person_id in  number,
   p_rec       in out nocopy g_cache_ass_table);
procedure get_allass_object
  (p_person_id in  number,
   p_rec       in out nocopy g_cache_ass_table);
procedure get_object
  (p_person_id in  number,
   p_rec       in out nocopy g_cache_typ_table);
procedure get_object
  (p_person_id in  number,
-- added per_in_ler_id for unrestricted enhancement
  p_per_in_ler_id in number default null,
   p_rec       in out nocopy ben_per_in_ler%rowtype);
procedure get_object
  (p_soft_coding_keyflex_id in  number,
   p_rec                    in out nocopy hr_soft_coding_keyflex%rowtype);
procedure get_object
  (p_person_id      in  number,
   p_bnfts_bal_id   in number,
   p_effective_date in date,
   p_rec            in out nocopy ben_per_bnfts_bal_f%rowtype);
procedure get_object
  (p_person_id in  number,
   p_rec       in out nocopy g_person_date_info_rec);
procedure get_object
  (p_assignment_id in  number,
   p_rec           in out nocopy g_person_fte_info_rec);
procedure get_bal_per_object
  (p_person_id      in  number,
   p_bnfts_bal_id   in  number,
   p_effective_date in  date,
   p_rec            in out nocopy ben_per_bnfts_bal_f%rowtype);
--
procedure clear_down_cache;
--
procedure defrag_caches;
--
end ben_person_object;

 

/
