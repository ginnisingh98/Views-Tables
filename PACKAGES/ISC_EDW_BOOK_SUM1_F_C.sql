--------------------------------------------------------
--  DDL for Package ISC_EDW_BOOK_SUM1_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_EDW_BOOK_SUM1_F_C" AUTHID CURRENT_USER AS
/* $Header: ISCSCF2S.pls 115.5 2002/12/19 01:46:17 scheung ship $ */

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------

 PROCEDURE PUSH(Errbuf      		IN OUT NOCOPY  VARCHAR2,
                Retcode     		IN OUT NOCOPY  VARCHAR2,
                p_from_date  		IN 	VARCHAR2,
                p_to_date    		IN 	VARCHAR2,
                p_from_booked_date  	IN 	VARCHAR2,
                p_to_booked_date    	IN 	VARCHAR2);


END ISC_EDW_BOOK_SUM1_F_C;

 

/
