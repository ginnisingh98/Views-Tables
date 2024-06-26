--------------------------------------------------------
--  DDL for Package PAY_KR_YEA20100101_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA20100101_PKG" AUTHID CURRENT_USER as
/* $Header: pykryea9.pkh 120.0.12010000.1 2010/02/22 10:14:47 pnethaga noship $ */
--
procedure yea(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_business_group_id	in number,
	p_yea_info		in out NOCOPY pay_kr_yea_pkg.t_yea_info,
        p_tax_adj_warning       out    NOCOPY boolean);

end pay_kr_yea20100101_pkg;

/
