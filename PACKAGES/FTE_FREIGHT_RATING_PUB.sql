--------------------------------------------------------
--  DDL for Package FTE_FREIGHT_RATING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_FREIGHT_RATING_PUB" AUTHID CURRENT_USER AS
/* $Header: FTEFRPBS.pls 120.0 2005/05/26 18:18:09 appldev noship $ */

--Structures for Lane Information,made public to pass it onto TL Release 12

   TYPE lane_info_rec_type IS RECORD  --  Make these columns as %TYPE
                (lane_id                                        NUMBER ,
                 carrier_id                                     NUMBER ,
		 carrier_freight_code				VARCHAR2(30),
                 pricelist_id                                   NUMBER ,
                 mode_of_transportation_code                    VARCHAR2(30) ,
                 origin_id                                      NUMBER ,
                 destination_id                                 NUMBER ,
                 basis                                          VARCHAR2(30) ,
                 commodity_catg_id                              NUMBER ,
                 service_type_code                              VARCHAR2(30),
                 classification_code                            VARCHAR2(10),    --  To be added to fte_lanes
		 ship_method_code				VARCHAR2(30),
		 transit_time					NUMBER,
		 transit_time_uom				VARCHAR2(10)
                 );

   TYPE lane_info_tab_type IS TABLE OF lane_info_rec_type INDEX BY BINARY_INTEGER;


-- ----------------------------------------------------------------------------------------
--
-- Tables and records for input
--

PROCEDURE Get_Freight_Costs(
  p_api_version			IN 		NUMBER DEFAULT 1.0,
  p_init_msg_list		IN 		VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit			IN 		VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
  p_source_header_tab           IN OUT NOCOPY   FTE_PROCESS_REQUESTS.fte_source_header_tab,
  p_source_type			IN              VARCHAR2,
  p_action			IN	        VARCHAR2,
  x_source_line_rates_tab	OUT NOCOPY 	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
  x_source_header_rates_tab	OUT NOCOPY 	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
  x_request_id                  OUT NOCOPY      NUMBER,
  x_return_status		OUT NOCOPY 	VARCHAR2,
  x_msg_count			OUT NOCOPY 	NUMBER,
  x_msg_data			OUT NOCOPY 	VARCHAR2);

END FTE_FREIGHT_RATING_PUB;

 

/
