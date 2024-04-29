--------------------------------------------------------
--  DDL for Package Body POGMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POGMS_PKG" AS
-- $Header: poxgms1b.pls 115.8 2002/11/23 00:02:33 sbull noship $

/*  Declare procedure update_adls.
      REQ_LINE_ID	IN      NUMBER
      ERR_CODE        IN OUT  VARCHAR2,
      ERR_MSG	        IN OUT  VARCHAR2
*/
PROCEDURE UPDATE_ADLS(p_req_line_id	IN 	NUMBER,
		        err_code	IN OUT	NOCOPY VARCHAR2,
		        err_msg		IN OUT	NOCOPY VARCHAR2 ) is

BEGIN

   IF gms_install.enabled THEN

     gms_po_adl_pkg.update_adls(p_req_line_id => p_req_line_id,
                                err_code      => err_code,
                                err_msg       => err_msg);

  ELSE

     err_code := 'S';

  END IF ;

EXCEPTION

 WHEN OTHERS THEN
err_code := 'F' ;
err_msg := substr(SQLERRM,1,200) ;

END UPDATE_ADLS;

END POGMS_PKG;

/
