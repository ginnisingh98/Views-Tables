--------------------------------------------------------
--  DDL for Package IEU_FRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_FRM_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUFRMS.pls 120.0 2005/06/02 15:49:27 appldev noship $ */

TYPE v_ieu_media_data IS RECORD ( PARAM_NAME	VARCHAR2(4000),
					    PARAM_VALUE	VARCHAR2(4000),
					    PARAM_TYPE	VARCHAR2(4000));

TYPE t_ieu_media_data IS TABLE of v_ieu_media_data
INDEX BY BINARY_INTEGER;


PROCEDURE uwq_get_media_func( p_apps_proc		IN  varchar2,
					 p_ieu_media_data IN  t_ieu_media_data ,
				    	 p_action_type 	OUT NOCOPY number,
				       p_action_name 	OUT NOCOPY varchar2,
				    	 p_action_param  	OUT NOCOPY varchar2 );

PROCEDURE uwq_get_action_func(p_apps_proc		IN  varchar2,
					    p_ieu_action_data  IN  t_ieu_media_data,
				    	p_action_type 	OUT NOCOPY number,
				    	p_action_name 	OUT NOCOPY varchar2,
				    	p_action_param  	OUT NOCOPY varchar2,
                        p_msg_name          OUT NOCOPY varchar2,
                        p_msg_param         OUT NOCOPY varchar2,
                        p_dialog_style      OUT NOCOPY number,
                        p_msg_appl_short_name OUT NOCOPY varchar2);

END IEU_FRM_PVT ;
 

/
