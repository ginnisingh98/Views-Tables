--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_INSTANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_INSTANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusi01t.pkh 115.0 99/07/17 06:44:40 porting ship $ */
--
--
  procedure insert_row(p_rowid                   in out varchar2,
		       p_user_column_instance_id in out number,
		       p_effective_start_date    in date,
		       p_effective_end_date      in date,
		       p_user_row_id		 in number,
		       p_user_column_id		 in number,
		       p_business_group_id       in number,
		       p_legislation_code        in varchar2,
		       p_legislation_subgroup    in varchar2,
		       p_value			 in varchar2 ) ;
--
 procedure update_row(p_rowid                    in varchar2,
		      p_user_column_instance_id  in number,
		      p_effective_start_date     in date,
		      p_effective_end_date       in date,
		      p_user_row_id		 in number,
		      p_user_column_id		 in number,
		      p_business_group_id        in number,
		      p_legislation_code         in varchar2,
		      p_legislation_subgroup     in varchar2,
		      p_value			 in varchar2 ) ;
--
  procedure delete_row(p_rowid   in varchar2) ;
--
  procedure lock_row (p_rowid                    in varchar2,
		      p_user_column_instance_id  in number,
		      p_effective_start_date     in date,
		      p_effective_end_date       in date,
		      p_user_row_id		 in number,
		      p_user_column_id		 in number,
		      p_business_group_id        in number,
		      p_legislation_code         in varchar2,
		      p_legislation_subgroup     in varchar2,
		      p_value			 in varchar2 ) ;
--
  -- For the given user row return the latest end date. Used by DateTrack
  -- for checking inserts and deletes
  function latest_end_date ( p_user_row_id in number ) return date ;
--
END PAY_USER_COLUMN_INSTANCES_PKG ;

 

/
