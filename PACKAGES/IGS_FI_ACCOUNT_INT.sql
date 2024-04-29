--------------------------------------------------------
--  DDL for Package IGS_FI_ACCOUNT_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ACCOUNT_INT" AUTHID CURRENT_USER AS
/* $Header: IGSFI47S.pls 120.1 2005/09/08 14:19:46 appldev noship $ */

PROCEDURE ACCOUNT_INT( errbuf  OUT NOCOPY  VARCHAR2,
                       retcode OUT NOCOPY  NUMBER,
                       p_org_id NUMBER) ;


END IGS_FI_ACCOUNT_INT;

 

/
