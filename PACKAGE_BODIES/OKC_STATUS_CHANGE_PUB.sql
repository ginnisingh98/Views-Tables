--------------------------------------------------------
--  DDL for Package Body OKC_STATUS_CHANGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_STATUS_CHANGE_PUB" as
/*$Header: OKCPSTSB.pls 120.0 2005/05/25 19:45:36 appldev noship $*/
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE change_status
			(
			ERRBUF      OUT NOCOPY VARCHAR2,
			RETCODE     OUT NOCOPY NUMBER,
			p_category 	IN VARCHAR2 ,
			p_from_k 	IN VARCHAR2 ,
			p_to_k 	IN VARCHAR2 ,
			p_from_m 	IN VARCHAR2 ,
			p_to_m 	IN VARCHAR2 ,
			p_debug 	IN VARCHAR2  ,
			p_last_rundate IN VARCHAR2
			) IS
begin
  OKC_STATUS_CHANGE_PVT.CHANGE_STATUS(errbuf, retcode, p_category, p_from_k, p_to_k,p_from_m, p_to_m, p_debug, p_last_rundate);
end;

end OKC_STATUS_CHANGE_PUB;

/
