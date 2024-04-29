--------------------------------------------------------
--  DDL for Package Body IEU_FRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_FRM_PVT" AS
/* $Header: IEUFRMB.pls 115.5 2003/08/07 17:01:47 fsuthar ship $ */

PROCEDURE uwq_get_media_func(p_apps_proc		IN  varchar2,
					p_ieu_media_data  IN  t_ieu_media_data,
				    	p_action_type 	OUT NOCOPY number,
				    	p_action_name 	OUT NOCOPY varchar2,
				    	p_action_param  	OUT NOCOPY varchar2 ) IS

	v_media_data SYSTEM.IEU_UWQ_MEDIA_DATA_NST;

	l_name  varchar2(120);
	l_param varchar2(4000);
	l_type  number;

BEGIN

	v_media_data := SYSTEM.IEU_UWQ_MEDIA_DATA_NST();

	FOR i IN p_ieu_media_data.first..p_ieu_media_data.last
	LOOP

	v_media_data.EXTEND;
	v_media_data(v_media_data.LAST) := SYSTEM.IEU_UWQ_MEDIA_DATA_OBJ(p_ieu_media_data(i).param_name,
							p_ieu_media_data(i).param_value,
							p_ieu_media_data(i).param_type);

	END LOOP;


	EXECUTE IMMEDIATE 'BEGIN '||p_apps_proc||'( :1, :2, :3, :4 );  END;'
	USING IN v_media_data, OUT l_type, OUT l_name, OUT l_param;

	p_action_type 	:= l_type;
	p_action_name 	:= l_name;
	p_action_param	:= l_param;

  END;


PROCEDURE uwq_get_action_func(p_apps_proc IN  varchar2,
                             p_ieu_action_data  IN  t_ieu_media_data,
			     p_action_type 	OUT NOCOPY number,
			     p_action_name 	OUT NOCOPY varchar2,
			     p_action_param  	OUT NOCOPY varchar2,
                             p_msg_name          OUT NOCOPY varchar2,
                             p_msg_param         OUT NOCOPY varchar2,
                             p_dialog_style      OUT NOCOPY number ,
                             p_msg_appl_short_name OUT NOCOPY varchar2) IS

	v_media_data SYSTEM.IEU_UWQ_MEDIA_DATA_NST;

	l_name  varchar2(120);
	l_param varchar2(4000);
	l_type  number;
        l_msg_name varchar2(1000);
        l_msg_param  varchar2(100);
        l_dialog_style number;
        l_msg_appl_short_name varchar2(100);
BEGIN


	v_media_data := SYSTEM.IEU_UWQ_MEDIA_DATA_NST();

	FOR i IN p_ieu_action_data.first..p_ieu_action_data.last
	LOOP

	v_media_data.EXTEND;
	v_media_data(v_media_data.LAST) :=                           SYSTEM.IEU_UWQ_MEDIA_DATA_OBJ(p_ieu_action_data(i).param_name,
							p_ieu_action_data(i).param_value,
							p_ieu_action_data(i).param_type);

	END LOOP;


	EXECUTE IMMEDIATE 'BEGIN '||p_apps_proc||'( :1, :2, :3, :4 ,:5, :6, :7, :8);  END;'
	USING IN v_media_data, OUT l_type, OUT l_name, OUT l_param, out l_msg_name, out l_msg_param,               out l_dialog_style, out l_msg_appl_short_name;



	p_action_type 	:= l_type;
	p_action_name 	:= l_name;
	p_action_param	:= l_param;
        p_msg_name      := l_msg_name;
        p_msg_param     := l_msg_param;
        p_dialog_style  := l_dialog_style;
        p_msg_appl_short_name := l_msg_appl_short_name;

  END;

END IEU_FRM_PVT;

/
