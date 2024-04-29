--------------------------------------------------------
--  DDL for Package PAY_KR_YEA20070101_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA20070101_PKG" AUTHID CURRENT_USER as
/* $Header: pykryea6.pkh 120.0.12010000.1 2008/07/27 23:06:31 appldev ship $ */
--
procedure yea(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_business_group_id	in number,
	p_yea_info		in out NOCOPY pay_kr_yea_pkg.t_yea_info,
        p_tax_adj_warning       out    NOCOPY boolean);

end pay_kr_yea20070101_pkg;

/
