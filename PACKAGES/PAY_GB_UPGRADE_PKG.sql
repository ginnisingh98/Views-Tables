--------------------------------------------------------
--  DDL for Package PAY_GB_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: pygbgupd.pkh 120.1.12000000.2 2007/02/20 09:27:48 npershad noship $ */

PROCEDURE upg_disability_status(p_person_id in number);



PROCEDURE qualify_disability_status(p_person_id	 in number,
				    p_qualifier  out nocopy varchar2);

END pay_gb_upgrade_pkg;

 

/
