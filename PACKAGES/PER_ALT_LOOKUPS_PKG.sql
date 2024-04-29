--------------------------------------------------------
--  DDL for Package PER_ALT_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ALT_LOOKUPS_PKG" AUTHID CURRENT_USER AS
/*$Header: peraltlk.pkh 115.1 2002/12/05 17:25:09 eumenyio noship $*/

procedure run_process   (errbuf	         out nocopy varchar2,
			 retcode	 out nocopy number,
			 P_BUSINESS_GROUP_ID    in number,
	    	         P_APPLICATION_ID       in number,
		         P_LOOKUP_TYPE          in varchar2,
		         P_ROW_TITLE            in varchar2,
		         P_FUNCTION_TYPE        in varchar2,
		         P_REQUIRED_DEFAULTS    in varchar2,
		         P_DEFAULT_VALUE        in varchar2,
		         P_LEGISLATION_CODE      in varchar2 default null);


-- Procedure clean_pay_tables
-- Parameters are : Business_group_id (mandatory)
--                : (lookup) table_name (mandatory)
procedure clean_pay_tables
            (cn_business_group_id IN per_business_groups.business_group_id%TYPE,
             cp_user_table_name   IN pay_user_tables.user_table_name%TYPE);



-- Procedure Update_instance_value
-- parameters are : Business_group (optional)
--                  Legislation_Code (optional)
--                  (Lookup) table_name
--                  Alternative Lookup column_name
--                  Instance_name
--                  value to be updated for the instance
Procedure Update_Instance_value
      (cn_business_group_id  IN per_business_groups.business_group_id%TYPE,
       cp_legislation_code   IN per_business_groups.legislation_code%TYPE,
       cp_user_table_name    IN pay_user_tables.user_table_name%TYPE       ,
       cp_user_column_name   IN pay_user_columns.user_column_name%TYPE     ,
       cp_row_name           IN pay_user_rows_f.row_low_range_or_name%TYPE ,
       cp_value              IN pay_user_column_instances_f.value%TYPE);

end PER_ALT_LOOKUPS_PKG;

 

/
