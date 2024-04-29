--------------------------------------------------------
--  DDL for Package IEU_UWQ_FORM_ROUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_FORM_ROUTE" AUTHID CURRENT_USER AS
/* $Header: IEUFOOS.pls 120.0 2005/06/02 15:42:05 appldev noship $ */

PROCEDURE ieu_uwq_form_obj(p_ieu_media_data  IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST  default null,
				    	p_action_type 	OUT NOCOPY number,
				    	p_action_name 	OUT NOCOPY varchar2,
				    	p_action_param  	OUT NOCOPY varchar2 );

END IEU_UWQ_FORM_ROUTE;

 

/
