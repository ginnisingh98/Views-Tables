--------------------------------------------------------
--  DDL for Package ISC_EDW_BOOKINGS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_EDW_BOOKINGS_F_C" AUTHID CURRENT_USER AS
/* $Header: ISCSCF0S.pls 115.6 2002/12/19 01:45:51 scheung ship $ */

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------

 PROCEDURE PUSH(Errbuf      	IN OUT NOCOPY  VARCHAR2,
                Retcode     	IN OUT NOCOPY  VARCHAR2,
                p_from_date  	IN 	VARCHAR2,
                p_to_date    	IN 	VARCHAR2,
		p_coll_flag	IN	VARCHAR2);


END ISC_EDW_BOOKINGS_F_C;

 

/
