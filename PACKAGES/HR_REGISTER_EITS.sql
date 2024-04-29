--------------------------------------------------------
--  DDL for Package HR_REGISTER_EITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_REGISTER_EITS" AUTHID CURRENT_USER AS
/* $Header: peregeit.pkh 120.3 2006/03/08 04:00:34 rvarshne noship $ */

PROCEDURE CREATE_EIT(errbuf       OUT nocopy VARCHAR2,
                 retcode          OUT nocopy VARCHAR2,
                 p_table_name     IN  varchar2,
                 p_info_type_name IN  varchar2,
                 p_active_flag    IN  varchar2,
                 p_multi_row      IN  varchar2,
                 p_leg_code       IN  varchar2 default null,
 		 p_desc           IN  varchar2,
                 p_org_class      IN  varchar2,
		 p_category_code  IN  varchar2 default null,
		 p_sub_category_code      IN varchar2 default null,
		 p_authorization_required IN varchar2 default null,
		 p_warning_period IN number default null,
        	 p_application_id IN NUMBER default null
                 );


END;

 

/
