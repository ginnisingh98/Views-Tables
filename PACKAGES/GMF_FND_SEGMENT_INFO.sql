--------------------------------------------------------
--  DDL for Package GMF_FND_SEGMENT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_FND_SEGMENT_INFO" AUTHID CURRENT_USER AS
/* $Header: gmfsegns.pls 115.2 2002/11/11 00:43:01 rseshadr ship $ */
      PROCEDURE get_segment_info(  startdate in date,
                          enddate in date,
                          sobname in varchar2,
                          segmentname in out NOCOPY varchar2,
                          segmentnum out NOCOPY number,
                          statuscode out NOCOPY number);
  END GMF_FND_SEGMENT_INFO;

 

/
