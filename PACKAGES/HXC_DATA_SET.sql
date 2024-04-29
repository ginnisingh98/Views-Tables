--------------------------------------------------------
--  DDL for Package HXC_DATA_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DATA_SET" AUTHID CURRENT_USER as
/* $Header: hxcdataset.pkh 120.1 2005/10/04 05:38:20 sechandr noship $ */

--
-- validate_data_set_range function
--
FUNCTION validate_data_set_range
		(p_data_set_name 	IN VARCHAR2,
		 p_start_date 		IN DATE,
		 p_stop_date 		IN DATE)
RETURN BOOLEAN;


--
-- show data set
--
PROCEDURE show_data_set;

--
-- insert into data set
--
PROCEDURE insert_into_data_set(p_data_set_id   out NOCOPY number,
			       p_data_set_name in varchar2,
			       p_description   in varchar2,
                               p_start_date    in DATE,
                               p_stop_date     in DATE,
                               p_status	       in varchar2);

--
-- Mark main tables with data set id
--
PROCEDURE mark_tables_with_data_set(p_data_set_id in number,
				    p_start_date  in DATE,
                                    p_stop_date   in DATE);

--
-- Get data set information
--
PROCEDURE get_data_set_info(p_data_set_id 	IN NUMBER,
			    p_data_set_name 	OUT NOCOPY VARCHAR2,
			    p_description 	OUT NOCOPY VARCHAR2,
                            p_start_date 	OUT NOCOPY DATE,
                            p_stop_date 	OUT NOCOPY DATE,
                            p_data_set_mode	OUT NOCOPY VARCHAR2,
                            p_status		OUT NOCOPY VARCHAR2,
                            p_validation_status	OUT NOCOPY VARCHAR2,
                            p_found_data_set	OUT NOCOPY BOOLEAN);


--
-- Undo define Data Set
--
PROCEDURE undo_define_data_set(p_data_set_id 	IN NUMBER);

--
-- Validate Data Set
--
PROCEDURE validate_data_set (p_data_set_id in  number,
                             p_error_count out NOCOPY number,
                             p_all_errors in boolean default FALSE);

--
-- Lock Data Set
--
PROCEDURE lock_data_set (p_data_set_id 		in number,
			 p_start_date  		in date,
			 p_stop_date   		in date,
			 p_data_set_lock	out NOCOPY BOOLEAN);


--
-- Release Lock Data Set
--
PROCEDURE release_lock_data_set(p_data_set_id in number);


END hxc_data_set;

 

/
