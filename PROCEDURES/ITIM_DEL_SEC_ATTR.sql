--------------------------------------------------------
--  DDL for Procedure ITIM_DEL_SEC_ATTR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."ITIM_DEL_SEC_ATTR" (
	x_api_version_number 	in  number   default 1,
	x_web_user_id 		in  number,
	x_attribute_code 	in  varchar2,
	x_attribute_appl_id 	in  number,
	x_varchar2_value 	in  varchar2,
	x_date_value 		in  date     default NULL,
	x_number_value 		in  number   default NULL,
	x_init_msg_list 	in  varchar2   default NULL,
	x_simulate 		in  varchar2   default NULL,
	x_commit 		in  varchar2 default NULL,
	x_validation_level 	in  number   default NULL,
	x_return_status 	out varchar2,
	x_msg_count 		out number,
	x_msg_data 		out varchar2
)
AS
begin
	ICX_USER_SEC_ATTR_PUB.DELETE_USER_SEC_ATTR(
		p_api_version_number 	=> x_api_version_number,
		p_web_user_id 		=> x_web_user_id,
		p_attribute_code 	=> x_attribute_code,
		p_attribute_appl_id 	=> x_attribute_appl_id,
		p_varchar2_value 	=> x_varchar2_value,
		p_date_value 		=> x_date_value,
		p_number_value 		=> x_number_value,
		p_init_msg_list 	=> x_init_msg_list,
		p_simulate 		=> x_simulate,
		p_commit 		=> x_commit,
		p_validation_level 	=> x_validation_level,
                p_return_status 	=> x_return_status,
		p_msg_count 		=> x_msg_count,
		p_msg_data 		=> x_msg_data);
end ITIM_DEL_SEC_ATTR;

/

  GRANT EXECUTE ON "APPS"."ITIM_DEL_SEC_ATTR" TO "NONAPPS";
