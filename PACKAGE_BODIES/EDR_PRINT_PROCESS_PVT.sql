--------------------------------------------------------
--  DDL for Package Body EDR_PRINT_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_PRINT_PROCESS_PVT" AS
/* $Header: EDRVPRTB.pls 120.0.12000000.1 2007/01/18 05:56:36 appldev ship $ */


/* Program to submit print job */

PROCEDURE SUBMIT_PRINT_JOB (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_Query_id 		IN	NUMBER,
      P_WAIT_FOR_JOB          IN      BOOLEAN,
	x_request_id		OUT	NOCOPY NUMBER,
	x_request_status	OUT	NOCOPY VARCHAR2) IS
BEGIN
return;
-- stubbed
END SUBMIT_PRINT_JOB;

PROCEDURE PROCESS_PRINTRECORDS (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_erecord_id_TBL 		IN	FND_TABLE_OF_VARCHAR2_255,
      P_INCLUDE_RELATED_RECORDS  IN      BOOLEAN,
	x_Query_id		OUT	NOCOPY NUMBER
	) IS
BEGIN
return;
 -- stubbed
END PROCESS_PRINTRECORDS;

PROCEDURE ACKNOWLEDGE_PRINT (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		      OUT	NOCOPY NUMBER,
	x_msg_data		      OUT	NOCOPY VARCHAR2,
	p_Query_id              IN	NUMBER
      ) IS
BEGIN
 -- stubbed
return;
END ACKNOWLEDGE_PRINT;


PROCEDURE GET_PARENT_ERECORD_ID(P_ERECORD_ID IN NUMBER,
                                P_PARENT_ERECORD_ID OUT NOCOPY NUMBER)
IS
BEGIN
-- stubbed
return;
END GET_PARENT_ERECORD_ID;


PROCEDURE GET_EVENT_DESCRIPTION(P_EVENT IN VARCHAR2,
                                P_DESCRIPTION OUT NOCOPY VARCHAR2)
IS
BEGIN
return;
-- stubbed
END GET_EVENT_DESCRIPTION;

end EDR_PRINT_PROCESS_PVT;

/
