--------------------------------------------------------
--  DDL for Package ICX_TAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_TAG" AUTHID CURRENT_USER as
/* $Header: ICXTAGS.pls 115.2 99/07/17 03:29:37 porting ship $ */

PROCEDURE tag_maint ;



PROCEDURE tag_det(p_tag IN varchar2 default NULL,
		  p_copy IN varchar2 default NULL) ;

PROCEDURE update_tag_det(p_tag_name  IN varchar2,
			 p_application_id IN number := null,
			 p_tag_description IN varchar2 := null,
			 p_replacement_text IN varchar2 := null,
		         p_protected IN varchar2 := null);


end icx_tag;

 

/
