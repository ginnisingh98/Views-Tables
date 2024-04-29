--------------------------------------------------------
--  DDL for Package PAY_SE_ALECTA_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_ALECTA_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pyseaaru.pkh 120.0.12010000.1 2010/02/08 09:37:47 vijranga noship $ */

	PROCEDURE upload (
		errbuf			OUT NOCOPY	VARCHAR2,
		retcode			OUT NOCOPY	NUMBER,
		p_file_name		IN		VARCHAR2,
		p_effective_date	IN		VARCHAR2 default sysdate,
		p_business_group_id	IN		per_business_groups.business_group_id%TYPE
		);

   	PROCEDURE compare_record (
		 p_line			IN		VARCHAR2,
         p_record_found OUT NOCOPY NUMBER
		);

	FUNCTION get_token(
   		the_string  VARCHAR2,
   		the_index NUMBER,
   		delim  VARCHAR2 := ';'
	) RETURN VARCHAR2;

END PAY_SE_ALECTA_UPLOAD;

/
