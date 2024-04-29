--------------------------------------------------------
--  DDL for Package BIC_LIFECYCLE_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIC_LIFECYCLE_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: biclcexs.pls 115.5 2004/05/13 15:46:24 vsegu ship $ */

  PROCEDURE extract_lifecycle_data(p_start_date date,
			          p_end_date   date,
                            p_delete_flag varchar2,
                            p_org_id number);
end bic_lifecycle_extract_pkg ;


 

/
