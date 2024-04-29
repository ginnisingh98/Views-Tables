--------------------------------------------------------
--  DDL for Package HR_DE_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pedevald.pkh 120.1 2007/04/05 09:28:14 spendhar noship $ */


   PROCEDURE create_element_entry_validate
	(p_effective_date		IN		DATE
	,p_assignment_id		IN		NUMBER
	,p_entry_information_category	IN		VARCHAR2
	,p_entry_information1		IN		VARCHAR2
	);

   PROCEDURE update_element_entry_validate
	(p_effective_date		IN		DATE
	,p_element_entry_id		IN		NUMBER
	,p_entry_information_category	IN		VARCHAR2
	,p_entry_information1		IN		VARCHAR2
	);

END hr_de_validate_pkg;

/
