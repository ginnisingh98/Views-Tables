--------------------------------------------------------
--  DDL for Package IGS_FI_PAY_TERM_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PAY_TERM_INT" AUTHID CURRENT_USER AS
/* $Header: IGSFI48S.pls 120.1 2005/09/08 15:39:32 appldev noship $ */

Procedure PAYMENT_TERM_INT( errbuf  OUT NOCOPY  VARCHAR2,
                            retcode OUT NOCOPY  NUMBER ,
                            p_org_id NUMBER  ) ;

END IGS_FI_PAY_TERM_INT;

 

/
