--------------------------------------------------------
--  DDL for Package PAY_KR_YEA20050101_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA20050101_PKG" AUTHID CURRENT_USER as
/* $Header: pykryea4.pkh 120.0.12000000.1 2007/01/17 22:24:48 appldev noship $ */
--
procedure yea(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_business_group_id	in number,
	p_yea_info		in out NOCOPY pay_kr_yea_pkg.t_yea_info,
        p_tax_adj_warning       out    NOCOPY boolean);

end pay_kr_yea20050101_pkg;

 

/
