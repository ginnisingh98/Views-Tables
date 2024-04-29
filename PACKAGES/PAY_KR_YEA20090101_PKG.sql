--------------------------------------------------------
--  DDL for Package PAY_KR_YEA20090101_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA20090101_PKG" AUTHID CURRENT_USER as
/* $Header: pykryea8.pkh 120.0.12010000.1 2009/01/02 12:35:24 vaisriva noship $ */
--
procedure yea(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_business_group_id	in number,
	p_yea_info		in out NOCOPY pay_kr_yea_pkg.t_yea_info,
        p_tax_adj_warning       out    NOCOPY boolean);

end pay_kr_yea20090101_pkg;

/
