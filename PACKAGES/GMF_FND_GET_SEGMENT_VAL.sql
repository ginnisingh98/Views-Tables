--------------------------------------------------------
--  DDL for Package GMF_FND_GET_SEGMENT_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_FND_GET_SEGMENT_VAL" AUTHID CURRENT_USER AS
/* $Header: gmfsegls.pls 115.1 2002/11/11 00:42:39 rseshadr ship $ */
 PROCEDURE proc_get_segment_val (startdate    IN OUT NOCOPY date,
                                 enddate      IN OUT NOCOPY date,
                                 sobname      IN     varchar2,
                                 segmentname  IN OUT NOCOPY varchar2,
                                 segmentnum   IN OUT NOCOPY number,
                                 segmentval   IN OUT NOCOPY varchar2,
                                 segmentdesc  IN OUT NOCOPY varchar2,
                                 row_to_fetch IN     number,
                                 statuscode      OUT NOCOPY number,
                                 segmentuom   IN OUT NOCOPY varchar2);
 END GMF_FND_GET_SEGMENT_VAL;

 

/
