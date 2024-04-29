--------------------------------------------------------
--  DDL for Package PAY_KR_BAL_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_BAL_INIT_PKG" AUTHID CURRENT_USER as
/* $Header: pykrbini.pkh 115.2 2002/12/11 11:47:30 krapolu noship $ */
------------------------------------------------------------------------
procedure create_structure(
		p_batch_id		in number,
		p_classification_id	in number,
		p_element_name_prefix	in varchar2);
------------------------------------------------------------------------
procedure create_structure(
		errbuf			out NOCOPY varchar2,
		retcode			out NOCOPY number,
		p_batch_id		in number,
		p_classification_id	in number,
		p_element_name_prefix	in varchar2);
------------------------------------------------------------------------
end pay_kr_bal_init_pkg;

 

/
