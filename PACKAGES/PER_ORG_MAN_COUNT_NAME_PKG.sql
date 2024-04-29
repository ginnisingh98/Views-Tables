--------------------------------------------------------
--  DDL for Package PER_ORG_MAN_COUNT_NAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_MAN_COUNT_NAME_PKG" AUTHID CURRENT_USER as
/* $Header: pewspor1.pkh 120.0.12010000.1 2008/07/28 06:08:07 appldev ship $ */

--
  procedure manager_count_name(p_organization_id in number,
			     p_business_group_id in number,
			     p_session_date in date,
			     p_manager in out nocopy varchar2);
  --
  procedure organization_count_name
    (p_organization              in out nocopy varchar2,
     p_manager_flag_desc         in out nocopy varchar2,
     p_manager_flag              in out nocopy varchar2,
  	 	p_person_id                 in            number,
     p_session_date              in            date,
     p_organization_id           in            number,
     p_organization_structure_id in            number,
     p_business_group_id         in            number,
	    p_version_id                in            number,
     p_user_person_type             out nocopy varchar2);
  --
end per_org_man_count_name_pkg;

/
