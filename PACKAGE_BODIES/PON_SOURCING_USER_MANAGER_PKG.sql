--------------------------------------------------------
--  DDL for Package Body PON_SOURCING_USER_MANAGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_SOURCING_USER_MANAGER_PKG" as
/*$Header: PONSURMB.pls 120.1 2005/07/25 14:52:55 snatu noship $ */

PROCEDURE validate_user_data(p_username                        IN VARCHAR2,        --  1
			     x_dummy_data                      OUT NOCOPY VARCHAR2,--  2
			     x_extra_info                      OUT NOCOPY VARCHAR2,--  3
			     x_row_in_hr                       OUT NOCOPY VARCHAR2,--  4
			     x_vendor_relationship             OUT NOCOPY VARCHAR2,--  5
			     x_enterprise_relationship         OUT NOCOPY VARCHAR2,--  6
			     x_status                          OUT NOCOPY VARCHAR2,--  7
			     x_exception_msg                   OUT NOCOPY VARCHAR2 --  8
			     ) IS

PRAGMA autonomous_transaction;

v_user_party_id                   NUMBER;
v_user_name_prefix                VARCHAR2(50);
v_user_name_f                     VARCHAR2(50);
v_user_name_m                     VARCHAR2(50);
v_user_name_l                     VARCHAR2(50);
v_user_name_suffix                VARCHAR2(50);
v_user_title                      VARCHAR2(50);
v_user_email                      VARCHAR2(50);
v_user_country_code               VARCHAR2(50);
v_user_area_code                  VARCHAR2(50);
v_user_phone                      VARCHAR2(50);
v_user_extension                  VARCHAR2(50);
v_user_fax_country_code           VARCHAR2(50);
v_user_fax_area_code              VARCHAR2(50);
v_user_fax                        VARCHAR2(50);
v_user_fax_extension              VARCHAR2(50);
v_user_encodingoption             VARCHAR2(50);

BEGIN

   pon_user_profile_pkg.retrieve_user_data(p_username,
					   v_user_party_id,
					   v_user_name_prefix,
					   v_user_name_f,
					   v_user_name_m,
					   v_user_name_l,
					   v_user_name_suffix,
					   v_user_title,
					   v_user_email,
					   v_user_country_code,
					   v_user_area_code,
					   v_user_phone,
					   v_user_extension,
					   v_user_fax_country_code,
					   v_user_fax_area_code,
					   v_user_fax,
					   v_user_fax_extension,
					   v_user_encodingoption,
					   x_dummy_data,
					   x_extra_info,
					   x_row_in_hr,
					   x_vendor_relationship,
					   x_enterprise_relationship,
					   x_status,
					   x_exception_msg);

   COMMIT;

END validate_user_data;

END PON_SOURCING_USER_MANAGER_PKG;

/
