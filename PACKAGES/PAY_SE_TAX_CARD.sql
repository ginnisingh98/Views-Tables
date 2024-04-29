--------------------------------------------------------
--  DDL for Package PAY_SE_TAX_CARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_TAX_CARD" 
/* $Header: pysetaxu.pkh 120.0 2005/05/29 08:39:10 appldev noship $ */
AUTHID CURRENT_USER AS

   	PROCEDURE upload (
			errbuf			OUT NOCOPY	VARCHAR2,
			retcode			OUT NOCOPY	NUMBER,
			p_file_name		IN		VARCHAR2,
			p_effective_date	IN		VARCHAR2,
			p_business_group_id	IN		per_business_groups.business_group_id%TYPE,
			p_batch_name		IN		VARCHAR2 DEFAULT NULL,
			p_reference		IN		VARCHAR2 DEFAULT NULL
			);

   	PROCEDURE read_record
			(
			 p_process		IN		VARCHAR2
			,p_line			IN		VARCHAR2
			,p_entry_value1		OUT NOCOPY	VARCHAR2
			,p_entry_value2		OUT NOCOPY	VARCHAR2
			,p_entry_value3		OUT NOCOPY	VARCHAR2
			,p_entry_value4		OUT NOCOPY	VARCHAR2
			,p_entry_value5		OUT NOCOPY	VARCHAR2
			,p_entry_value6		OUT NOCOPY	VARCHAR2
			,p_entry_value7		OUT NOCOPY	VARCHAR2
			,p_entry_value8		OUT NOCOPY	VARCHAR2
			,p_entry_value9		OUT NOCOPY	VARCHAR2
			,p_entry_value10	OUT NOCOPY	VARCHAR2
			,p_entry_value11	OUT NOCOPY	VARCHAR2
			,p_entry_value12	OUT NOCOPY	VARCHAR2
			,p_entry_value13	OUT NOCOPY	VARCHAR2
			,p_entry_value14	OUT NOCOPY	VARCHAR2
			,p_entry_value15	OUT NOCOPY	VARCHAR2
			,p_return_value1	OUT NOCOPY	VARCHAR2
			,p_return_value2	OUT NOCOPY	VARCHAR2
			);

	FUNCTION user_key_to_id
			(
			 p_user_key_value in varchar2
			 )
			RETURN NUMBER;

	FUNCTION get_element_link_id
			(
			 p_assignment_id	IN NUMBER
			,p_business_group_id	IN NUMBER
			,p_effective_date	IN VARCHAR2
			,p_element_name		pay_element_types_f.ELEMENT_NAME%TYPE
			)
			RETURN NUMBER ;
END	 pay_se_tax_card;

 

/
