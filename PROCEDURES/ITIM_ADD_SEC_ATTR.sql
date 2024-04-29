--------------------------------------------------------
--  DDL for Procedure ITIM_ADD_SEC_ATTR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."ITIM_ADD_SEC_ATTR" (
	x_api_version_number      in  number   default 1,
	x_init_msg_list           in  varchar2   default NULL,
	x_simulate                in  varchar2   default NULL,
	x_commit                  in  varchar2 default NULL,
	x_validation_level        in  number   default NULL,
	x_web_user_id             in  number,
	x_attribute_code          in  varchar2,
	x_attribute_appl_id       in  number,
	x_varchar2_value          in  varchar2 default NULL,
	x_date_value              in  date     default NULL,
	x_number_value            in  number,
	x_created_by              in  number   default 0,
	x_creation_date           in  date,
	x_last_updated_by         in  number   default 0,
	x_last_update_date        in  date,
	x_last_update_login       in  number   default -1,
	x_return_status           out  varchar2,
	x_msg_count               out  number,
	x_msg_data                out  varchar2
)
AS
begin
	ICX_USER_SEC_ATTR_PUB.create_user_sec_attr(
		p_api_version_number      => x_api_version_number,
		p_init_msg_list           => x_init_msg_list,
		p_simulate                => x_simulate,
		p_commit                  => x_commit,
		p_validation_level        => x_validation_level,
		p_web_user_id             => x_web_user_id,
		p_attribute_code          => x_attribute_code,
		p_attribute_appl_id       => x_attribute_appl_id,
		p_varchar2_value          => x_varchar2_value,
		p_date_value              => x_date_value,
		p_number_value            => x_number_value,
		p_created_by              => x_created_by,
		p_creation_date           => x_creation_date,
		p_last_updated_by         => x_last_updated_by,
		p_last_update_date        => x_last_update_date,
		p_last_update_login       => x_last_update_login,
		p_return_status           => x_return_status,
		p_msg_count               => x_msg_count,
		p_msg_data                => x_msg_data );
end ITIM_ADD_SEC_ATTR;

/

  GRANT EXECUTE ON "APPS"."ITIM_ADD_SEC_ATTR" TO "NONAPPS";
