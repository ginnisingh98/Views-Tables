--------------------------------------------------------
--  DDL for Package EDR_PRINT_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_PRINT_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: EDRVPRTS.pls 120.0.12000000.1 2007/01/18 05:56:38 appldev ship $ */

/* Global Constants */
G_PKG_NAME            CONSTANT            varchar2(30) := 'EDR_PRINT_PROCESS_PVT';

/* Program to submit print job */
/* This Procedure will submit a print job for a given Query id and also will increment the print count */
   -- Start of comments
-- API name             : SUBMIT_PRINT_JOB
-- Type                 : Private Utility.
-- Function             : Submits the print job and increments the counted
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version         API version '1.0'
--                        p_init_msg_list       Flag to indicate if the message stack has to be initialised or not
--                        P_QUERY_ID            Query id to associated to the erecords which needs to be printed
--                        P_WAIT_FOR_JOB        This falg will indicate to
--                                              API if it has to wait till the concurrent request is complete or not

-- OUT                    : X_return Status      API status
--                          X_Msg_count          Message Count
--                          X_MSG_DATA           Message DAta which will populate the message stack
--                          X_REQUEST_ID         Request Id of the concurrent request submitted
 --                         X_REQUEST_STATUS     Request Status of the concurrent Request

PROCEDURE SUBMIT_PRINT_JOB (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_Query_id 		IN	NUMBER,
        P_WAIT_FOR_JOB          IN      BOOLEAN,
	x_request_id		OUT	NOCOPY NUMBER,
	x_request_status	OUT	NOCOPY VARCHAR2);

   -- Start of comments
-- API name             : PROCESS_PRINTRECORDS
-- Type                 : Private Utility.
-- Function             : Processes the records passed as table and prepares for print/Query
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version         API version '1.0'
--                        p_init_msg_list       Flag to indicate if the message stack has to be initialised or not
--                        p_erecord_id_TBL      Table of eRecords
--                        P_INCLUDE_RELATED_RECORDS This falg will indicate to
--                                              API if child erecords needs to be included

-- OUT                    : X_return Status      API status
--                          X_Msg_count          Message Count
--                          X_MSG_DATA           Message DAta which will populate the message stack
--                          X_QUERY_ID            Query id to associated to the erecords which have been


PROCEDURE PROCESS_PRINTRECORDS (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_erecord_id_TBL        IN	FND_TABLE_OF_VARCHAR2_255,
      P_INCLUDE_RELATED_RECORDS  IN      BOOLEAN,
	x_Query_id		OUT	NOCOPY NUMBER);

   -- Start of comments
-- API name             : ACKNOWLEDGE_PRINT
-- Type                 : Private Utility.
-- Function             : Acknowledges print event if it has been raised for the event
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version         API version '1.0'
--                        p_init_msg_list       Flag to indicate if the message stack has to be initialised or not
--                        p_QUERY_ID            Query Id to be acknoweldged

-- OUT                    : X_return Status      API status
--                          X_Msg_count          Message Count
--                          X_MSG_DATA           Message DAta which will populate the message stack


PROCEDURE ACKNOWLEDGE_PRINT (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		      OUT	NOCOPY NUMBER,
	x_msg_data		      OUT	NOCOPY VARCHAR2,
	p_Query_id              IN	NUMBER
      );


/* Utility procedures for Pritn option */

   -- Start of comments
-- API name             : GET_PARENT_ERECORD_ID
-- Type                 : Private Utility.
-- Function             : fetches Parent eRecord ID for a given erecord. P_PARENT_ERECORD_ID will be NULL if not found
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_ERECORD_ID eRecord id for which parent erecord id need to be retrieved

-- OUT                  : P_PARENT_ERECORD_ID Parent eRecord id of a given eRecord


PROCEDURE GET_PARENT_ERECORD_ID(P_ERECORD_ID IN NUMBER,
                                P_PARENT_ERECORD_ID OUT NOCOPY NUMBER);

   -- Start of comments
-- API name             : GET_EVENT_DESCRIPTION
-- Type                 : Private Utility.
-- Function             : Fectches the event display name from wf_events table.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_EVENT Name of the event
-- OUT                  : P_DESCRIPTION  Display name of the Event

PROCEDURE GET_EVENT_DESCRIPTION(P_EVENT IN VARCHAR2,
                                P_DESCRIPTION OUT NOCOPY VARCHAR2);

end EDR_PRINT_PROCESS_PVT;

 

/
