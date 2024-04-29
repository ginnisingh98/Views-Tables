--------------------------------------------------------
--  DDL for Package PER_VETS_MAG_100A_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VETS_MAG_100A_REPORT" AUTHID CURRENT_USER as
/* $Header: pevetmag100a.pkh 120.0.12010000.3 2009/10/30 07:43:54 emunisek noship $ */
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

/*Added for Bug#8974111*/
FUNCTION check_recent_or_not(l_person_id IN per_all_people_f.person_id%TYPE,
                             l_report_end_date IN date)
RETURN number;

end per_vets_mag_100a_report;

/
