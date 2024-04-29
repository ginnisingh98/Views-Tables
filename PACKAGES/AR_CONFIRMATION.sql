--------------------------------------------------------
--  DDL for Package AR_CONFIRMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CONFIRMATION" AUTHID CURRENT_USER AS
/*$Header: ARCONFMS.pls 115.1 2002/09/26 00:48:42 tkoshio noship $ */

procedure initiate_confirmation_process(P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_INT_CTR_NUM in VARCHAR2);
end;

 

/
