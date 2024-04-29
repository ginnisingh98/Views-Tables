--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_INTERNAL" AUTHID CURRENT_USER as
/* $Header: hrorgbsi.pkh 120.3.12000000.1 2007/01/21 17:39:43 appldev ship $ */

procedure HR_ORG_OPERATING_UNIT_UPLOAD
      (
       p_name				in varchar2
      ,p_organization_id		in out nocopy number
      ,p_date_from            		in date
      ,p_date_to 	      	    	in date
      ,p_internal_external_flag		in varchar2
      ,p_operating_unit   		in varchar2
       );
end HR_ORGANIZATION_INTERNAL;

 

/
