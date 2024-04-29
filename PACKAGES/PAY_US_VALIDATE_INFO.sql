--------------------------------------------------------
--  DDL for Package PAY_US_VALIDATE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_VALIDATE_INFO" AUTHID CURRENT_USER as
 /* $Header: pymwsval.pkh 115.0 99/07/17 06:17:36 porting ship $ */

 l_code		number(5);
 l_sui_no	varchar2(150);
 l_run		varchar2(150);

 procedure validate_worksite_transmitter
 (
  p_business_group_id   in  number ,
  p_context		in  varchar2,
  p_err_code  		out number,
  p_err_msg		out varchar2
 );

 procedure validate_worksite
 (
  p_business_group_id   in  number ,
  p_context		in  varchar2,
  p_err_code  		out number,
  p_err_msg		out varchar2
 );

 procedure validate
 (
  p_business_group_id   in  number ,
  p_context		in  varchar2,
  p_legislative_code    in varchar2 default 'US',
  p_err_code  		out number,
  p_err_msg		out varchar2
 );

end; /* end of package */

 

/
