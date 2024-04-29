--------------------------------------------------------
--  DDL for Package GMF_FND_GET_SEGMENT_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_FND_GET_SEGMENT_DTL" AUTHID CURRENT_USER AS
/* $Header: gmfsegds.pls 115.1 2002/11/11 00:42:16 rseshadr ship $ */
        PROCEDURE proc_get_segment_dtl (sobname          IN     varchar2,
                                        segmentname      IN OUT NOCOPY varchar2,
                                        segmentnum       IN OUT NOCOPY number,
                                        segmentattr_type IN OUT NOCOPY varchar2,
                                        attributevalue   IN OUT NOCOPY varchar2,
                                        row_to_fetch     IN     number,
                                        statuscode          OUT NOCOPY number);
END GMF_FND_GET_SEGMENT_DTL;

 

/
