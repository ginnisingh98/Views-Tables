--------------------------------------------------------
--  DDL for Package OKC_STATUS_CHANGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_STATUS_CHANGE_PUB" AUTHID CURRENT_USER as
/*$Header: OKCPSTSS.pls 120.0 2005/05/26 09:43:19 appldev noship $*/


Procedure change_status (
			ERRBUF      OUT NOCOPY VARCHAR2,
			RETCODE     OUT NOCOPY NUMBER,
			p_category 	IN VARCHAR2 default null,
			p_from_k 	IN VARCHAR2 default null,
			p_to_k 	IN VARCHAR2 default null,
			p_from_m 	IN VARCHAR2 default null,
			p_to_m 	IN VARCHAR2 default null,
			p_debug 	IN VARCHAR2  default 'N',
			p_last_rundate IN VARCHAR2  default null
			) ;


end OKC_STATUS_CHANGE_PUB;

 

/
