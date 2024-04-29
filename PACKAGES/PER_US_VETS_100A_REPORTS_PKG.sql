--------------------------------------------------------
--  DDL for Package PER_US_VETS_100A_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_VETS_100A_REPORTS_PKG" AUTHID CURRENT_USER as
/* $Header: pervetsr100a.pkh 120.0.12010000.2 2009/05/29 09:16:03 pannapur noship $ */
procedure submit
          (errbuf                       out nocopy varchar2,
           retcode                      out nocopy number,
           p_business_group_id          in  number,
           p_hierarchy_id               in  number,
           p_hierarchy_version_id       in  number,
           p_date_start                 in  varchar2,
           p_date_end                   in  varchar2,
           p_state                      in  varchar2,
           p_show_new_hires             in  varchar2,
           p_show_totals                in  varchar2,
           p_audit_report               in  varchar2
          );

end per_us_vets_100a_reports_pkg;

/
