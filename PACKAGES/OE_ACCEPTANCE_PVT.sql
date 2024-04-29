--------------------------------------------------------
--  DDL for Package OE_ACCEPTANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ACCEPTANCE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVACCS.pls 120.2 2006/09/20 09:24:32 serla noship $ */

-- Datatype for bulk update of acceptance details
TYPE NUMBER_TYPE        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VARCHAR_240_TYPE   IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE VARCHAR_30_TYPE    IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE VARCHAR_2000_TYPE  IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE FLAG_TYPE          IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
TYPE DATE_TYPE          IS TABLE OF DATE INDEX BY BINARY_INTEGER;

--This procedure is called by Process_Order_Actions for processing actions 'ACCEPT_FULFILLMENT' and 'REJECT FULFILLMENT'.
Procedure Process_Acceptance(p_request_tbl IN OUT NOCOPY OE_ORDER_PUB.request_tbl_type
			     ,p_index IN NUMBER DEFAULT 1
			     ,x_return_status OUT NOCOPY Varchar2);

--This procedure builds the line table for all eligible lines when the entity passed in request_rec is 'HEADER'
Procedure Build_Header_Acceptance_table(p_request_rec IN OUT NOCOPY OE_ORDER_PUB.request_rec_type
					,x_return_status OUT NOCOPY Varchar2);

--This procedure will check if the given line is eligible for acceptance and then adds that line to line_tbl
Procedure Build_Line_Acceptance_table(p_request_rec IN OUT NOCOPY OE_ORDER_PUB.request_rec_type
				      ,p_line_id    IN NUMBER DEFAULT NULL
                                      ,x_return_status OUT NOCOPY Varchar2);

--This procedure progress the workflow for each of the lines that were processed for acceptance or rejection.
Procedure Progress_Accepted_Lines(x_return_status OUT NOCOPY Varchar2);

END OE_ACCEPTANCE_PVT;

 

/
