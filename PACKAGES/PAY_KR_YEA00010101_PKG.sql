--------------------------------------------------------
--  DDL for Package PAY_KR_YEA00010101_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA00010101_PKG" AUTHID CURRENT_USER as
/* $Header: pykryea0.pkh 120.0 2005/05/29 06:33:57 appldev noship $ */
--
procedure yea(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_business_group_id	in number,
	p_yea_info		in out NOCOPY pay_kr_yea_pkg.t_yea_info
	);

end pay_kr_yea00010101_pkg;

 

/
