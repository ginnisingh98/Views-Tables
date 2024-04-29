--------------------------------------------------------
--  DDL for Package HXC_CREATE_FLEX_MAPPINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_CREATE_FLEX_MAPPINGS" AUTHID CURRENT_USER AS
/* $Header: hxcflxdn.pkh 120.0.12010000.2 2009/08/08 14:18:33 sabvenug ship $ */

/* Added for 8645021 HR OTL ABSENCE INTEGRATION
*/
--change start
Type hxc_abs_rec is record (
 			ABSENCE_ATTENDANCE_TYPE_ID  	number(9),
 		  	ELEMENT_TYPE_ID  		number(9),
                        EDIT_FLAG   			VARCHAR2(1),
     			UOM    				VARCHAR2(10),
     			ABSENCE_CATEGORY		VARCHAR2(30)
     			 );

Type hxc_abs_tab_type is  table of hxc_abs_rec
		index by binary_integer;

Type abs_elem_exists_type is  table of NUMBER
    index by BINARY_INTEGER;


 g_abs_incl_flag VARCHAR2(1):= 'N';
--change end

procedure run_process(
           p_errmsg OUT NOCOPY VARCHAR2
          ,p_errcode OUT NOCOPY NUMBER
          ,p_undo in VARCHAR2 default 'N'
          ,p_element_set_id in NUMBER default null
          ,p_effective_date in VARCHAR2
          ,p_generate_cost in VARCHAR2 default 'Y'
          ,p_generate_group in VARCHAR2 default 'Y'
          ,p_generate_job in VARCHAR2 default 'Y'
          ,p_generate_pos in VARCHAR2 default 'Y'
          ,p_generate_prj in VARCHAR2 default 'Y'
          ,p_business_group_id in VARCHAR2
          ,p_incl_abs_flg  in  VARCHAR2 default 'N'); -- Added for 8645021 HR OTL ABSENCE INTEGRATION

END hxc_create_flex_mappings;

/
