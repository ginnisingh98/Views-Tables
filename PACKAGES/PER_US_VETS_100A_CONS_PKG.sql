--------------------------------------------------------
--  DDL for Package PER_US_VETS_100A_CONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_VETS_100A_CONS_PKG" AUTHID CURRENT_USER as
/* $Header: pervetsc100a.pkh 120.0.12010000.4 2009/10/30 07:41:27 emunisek noship $ */

procedure GET_VETS100A_DATA (
           errbuf                       out nocopy varchar2,
           retcode                      out nocopy number,
           p_business_group_id          in  number,
           p_hierarchy_id               in  number,
           p_hierarchy_version_id       in  number,
           p_date_start                 in  varchar2,
           p_date_end                   in  varchar2,
           p_state                      in  varchar2,
           p_show_new_hires             in  varchar2,
           p_show_totals                in  varchar2,
           p_audit_report               in  varchar2) ;


FUNCTION convert_into_xml( p_name  IN VARCHAR2,
                           p_value IN VARCHAR2,
                           p_type  IN char)
RETURN VARCHAR2  ;

/*Added for Bug#8974111*/
FUNCTION check_recent_or_not(l_person_id IN per_all_people_f.person_id%TYPE,
                             l_report_end_date IN date)
RETURN number;

PROCEDURE write_to_concurrent_out (p_text VARCHAR2)  ;

PROCEDURE write_to_concurrent_log (p_text VARCHAR2)  ;

End per_us_vets_100a_cons_pkg ;

/
