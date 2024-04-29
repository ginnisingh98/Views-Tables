--------------------------------------------------------
--  DDL for Package WSH_U_GTT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_U_GTT" AUTHID CURRENT_USER AS
/* $Header: WSHUGTTS.pls 115.4 2002/11/12 02:00:10 nparikh ship $ */


TYPE  TimeInTransitOutRec IS RECORD (
				UPSOnLine				VARCHAR2(9),
				AppVersion				VARCHAR2(20),
				ReturnCode				NUMBER,
				MessageNumber			NUMBER,
				MessageText				VARCHAR2(500),
				TransitTime				VARCHAR2(16),
				OriginCity				VARCHAR2(30),
				OriginStateProv		VARCHAR2(5),
				DestinationCity		VARCHAR2(30),
				DestinationStateProv VARCHAR2(5));




PROCEDURE Time_In_Transit(
				p_api_version            IN   NUMBER,
				p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
				x_return_status         OUT NOCOPY    VARCHAR2,
				x_msg_count             OUT NOCOPY    NUMBER,
				x_msg_data              OUT NOCOPY    VARCHAR2,
				p_AppVersion				 IN	VARCHAR2,
				p_AcceptLicenseAgreement IN   VARCHAR2,
				p_ResponseType				 IN	VARCHAR2,
				p_OriginNumber				 IN	VARCHAR2,
				p_DestinationNumber		 IN	VARCHAR2,
				x_TimeInTransit_out		OUT NOCOPY 	TimeInTransitOutRec
				);



END WSH_U_GTT;

 

/
