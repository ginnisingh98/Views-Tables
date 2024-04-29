--------------------------------------------------------
--  DDL for Package PER_EEO_MAG_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EEO_MAG_REPORT" AUTHID CURRENT_USER as
/* $Header: peeeomag.pkh 120.0 2005/05/31 07:55:01 appldev noship $ */
--
procedure eeo_mag_report
  (errbuf                        out nocopy varchar2,
   retcode                       out nocopy number,
   --
   --l_output                      out varchar2,
   --l_string                      out varchar2,
   --
   p_start_date                  in  varchar2,
   p_end_date                    in  varchar2,
   p_hierarchy_id                in  number,
   p_hierarchy_version_id        in  number,
   p_report_mode                 in  varchar2,
   p_business_group_id           in  number);
   --
   l_output varchar2(5000);
   --p_start_date date := fnd_date.canonical_to_date(p_start_date);
   --p_end_date date := fnd_date.canonical_to_date(p_end_date);
   l_string varchar2(5000);  --1074
--
end per_eeo_mag_report;

 

/
