--------------------------------------------------------
--  DDL for Package ISC_EDW_BACKLOGS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_EDW_BACKLOGS_F_C" AUTHID CURRENT_USER AS
/* $Header: ISCSCF1S.pls 115.5 2002/12/19 01:46:04 scheung ship $ */

      -- --------------
      -- PROCEDURE PUSH
      -- --------------

PROCEDURE PUSH( errbuf      	IN OUT NOCOPY  VARCHAR2,
                retcode     	IN OUT NOCOPY  VARCHAR2,
                p_from_date  	IN 	VARCHAR2,
                p_to_date    	IN 	VARCHAR2,
		p_coll_flag	IN	VARCHAR2);


END ISC_EDW_BACKLOGS_F_C;

 

/
