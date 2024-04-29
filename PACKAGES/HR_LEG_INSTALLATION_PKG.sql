--------------------------------------------------------
--  DDL for Package HR_LEG_INSTALLATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEG_INSTALLATION_PKG" AUTHID CURRENT_USER as
/* $Header: hrlegins.pkh 115.3 2002/07/29 13:26:52 divicker ship $*/
--
/*
 Copyright (c) Oracle Corporation 1993,1994,1995.  All rights reserved

/*

 Name          : hrlegins.pkh
 Description   : procedures required for installation of legislations
 Author        : T.Battoo
 Date Created  : 19-May-1999

 Change List
 -----------
 Date        Name           Vers     Bug No    Description
 +-----------+--------------+--------+---------+-----------------------+
 19-May-1999 T.Battoo        115.0              created
*/





 procedure insert_row(p_application_short_name varchar2,
                      p_legislation_code varchar2,
                      p_status varchar2,
                      p_action varchar2,
		      p_pi_steps_exist varchar2,
                      p_view_name varchar2,
                      p_created_by varchar2,
                      p_creation_date date,
                      p_last_update_login varchar2,
                      p_last_update_date date,
                      p_last_updated_by varchar2);

 procedure update_row(p_application_short_name varchar2,
		      p_legislation_code varchar2,
		      p_status varchar2,
		      p_action varchar2,
                      p_created_by varchar2,
                      p_creation_date date,
                      p_last_update_login varchar2,
                      p_last_update_date date,
                      p_last_updated_by varchar2);


 procedure drop_view(p_product varchar2,p_legislation varchar2);


 procedure create_view(p_product varchar2,p_legislation varchar2);

 procedure check_existing_data;
 procedure set_existing_data;
end;

 

/
