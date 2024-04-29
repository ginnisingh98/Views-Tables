--------------------------------------------------------
--  DDL for Package PER_RI_CRP_DEFAULT_SETTINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CRP_DEFAULT_SETTINGS" AUTHID CURRENT_USER AS
/* $Header: perricrpd.pkh 120.1 2006/06/28 06:02:42 pkopppac noship $ */


PROCEDURE populate (p_errbuf		OUT NOCOPY VARCHAR2,
  		    p_retcode		OUT NOCOPY NUMBER,
		    p_business_group_id       IN NUMBER,
		    p_short_code  IN VARCHAR2);

PROCEDURE write_log(p_retcode		IN NUMBER,
		    p_message_token1	IN VARCHAR2,
		    p_message_token2    IN VARCHAR2);

END;


 

/
