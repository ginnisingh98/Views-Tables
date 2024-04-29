--------------------------------------------------------
--  DDL for Package AR_FLEXBUILDER_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_FLEXBUILDER_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: ARFLBMAS.pls 115.2 2002/11/15 02:34:26 anukumar ship $ */

FUNCTION SUBSTITUTE_BALANCING_SEGMENT ( X_ARFLEXNUM IN NUMBER
                                       ,X_ARORIGCCID IN NUMBER
                                       ,X_ARSUBSTICCID IN NUMBER
                                       ,X_return_ccid IN OUT NOCOPY number
                                       ,X_concat_segs IN OUT NOCOPY varchar2
                                       ,X_concat_ids  IN OUT NOCOPY varchar2
                                       ,X_concat_descrs IN OUT NOCOPY varchar2
                                       ,X_ARERROR IN OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN ;

END;



 

/
