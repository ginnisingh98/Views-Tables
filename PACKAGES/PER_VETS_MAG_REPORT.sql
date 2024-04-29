--------------------------------------------------------
--  DDL for Package PER_VETS_MAG_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VETS_MAG_REPORT" AUTHID CURRENT_USER as
/* $Header: pevetmag.pkh 120.0.12010000.1 2008/07/28 06:06:34 appldev ship $ */
--
procedure vets_mag_report
  (errbuf                        out nocopy varchar2,
   retcode                       out nocopy number,
   p_start_date                  in  varchar2,
   p_end_date                    in  varchar2,
   p_hierarchy_id                in  number,
   p_hierarchy_version_id        in  number,
   p_business_group_id           in  number,
   p_all_establishments          in  varchar2
  );
--
end per_vets_mag_report;

/
