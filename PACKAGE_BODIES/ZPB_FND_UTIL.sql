--------------------------------------------------------
--  DDL for Package Body ZPB_FND_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_FND_UTIL" AS
/* $Header: ZPBFNDUB.pls 120.0.12010.2 2006/08/03 11:57:33 appldev noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'ZPB_FND_UTIL';

 /*=========================================================================+
  |                       FUNCTION get_request_status
  |
  | DESCRIPTION
  |   Wrapper function to fnd_concurrent.get_request_status
  |    parameters.
  |
 +=========================================================================*/

 FUNCTION get_request_status(request_id      IN OUT NOCOPY NUMBER,
		 	      appl_shortname  IN VARCHAR2 DEFAULT NULL,
			      program         IN VARCHAR2 DEFAULT NULL,
	    		      phase      OUT NOCOPY VARCHAR2,
			      status     OUT NOCOPY VARCHAR2,
			      dev_phase  OUT NOCOPY VARCHAR2,
			      dev_status OUT NOCOPY VARCHAR2,
			      message    OUT NOCOPY VARCHAR2) RETURN  NUMBER IS

  l_api_name       CONSTANT VARCHAR2(30)   := '.get_request_status';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  x_rtn_code NUMBER;
  l_request_status BOOLEAN;
  BEGIN
  l_request_status := fnd_concurrent.get_request_status(request_id     => request_id,
		 	      appl_shortname	=> appl_shortname,
			      program         	=> program,
	    		      phase      =>	phase  ,
			      status     =>	status,
			      dev_phase  => dev_phase,
			      dev_status => dev_status,
			      message    => message);
  IF (l_request_status) THEN
	x_rtn_code	:= 0;
  ELSE
	x_rtn_code	:= -1;
  END IF;

  RETURN x_rtn_code;

 END get_request_status;


 END ZPB_FND_UTIL ;

/
