--------------------------------------------------------
--  DDL for Package OE_CUSTACCEPTREP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CUSTACCEPTREP_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVCARS.pls 120.1 2006/05/11 04:36:07 myerrams noship $ */
-- Start of comments
--	API name 	: Generate_ReportData
--	Type		: Private.
--	Function	: Generates XML data for Customer Acceptance Report.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--				p_init_msg_list		IN VARCHAR2 	Optional
--					                Default = FND_API.G_FALSE
--				p_sorted_by             IN VARCHAR2     Required
--				p_from_customer_name    IN VARCHAR2     Optional
--				                        Default = NULL
--				p_to_customer_name      IN VARCHAR2     Optional
--				                        Default = NULL
--				p_from_customer_no      IN VARCHAR2     Optional
--				                        Default = NULL
--				p_to_customer_no        IN VARCHAR2     Optional
--				                        Default = NULL
--				p_from_order_date       IN DATE         Optional
--				                        Default = NULL
--				p_to_order_date         IN DATE         Optional
--				                        Default = NULL
--				p_from_fulfill_date     IN DATE         Optional
--				                        Default = NULL
--				p_to_fulfill_date       IN DATE         Optional
--				                        Default = NULL
--				p_from_accepted_date    IN DATE         Optional
--				                        Default = NULL
--				p_to_accepted_date      IN DATE         Optional
--				                        Default = NULL
--                              p_acceptance_status     IN VARCHAR2     Optional
--				                        Default = NULL
--				p_item_display		IN VARCHAR2	Required
--				p_func_currency		IN VARCHAR2	Required
--
--	OUT		:	x_return_status		OUT	   VARCHAR2(1)
--				x_msg_count		OUT	   NUMBER
--				x_msg_data		OUT	   VARCHAR2(2000)
--				errbuf                  OUT NOCOPY VARCHAR2
--				retcode                 OUT NOCOPY VARCHAR2
--	Version	: Current version	1.0
--
--	Notes		: This Package is primarily created to have all the customer acceptance
--                        private procedures and functions
--
-- End of comments

PROCEDURE Generate_ReportData
( ERRBUF                  OUT NOCOPY  VARCHAR2,
  RETCODE                 OUT NOCOPY  VARCHAR2,
  p_sorted_by             IN VARCHAR2,
  p_customer_name_low     IN VARCHAR2,
  p_customer_name_high    IN VARCHAR2,
  p_customer_no_low       IN VARCHAR2,
  p_customer_no_high      IN VARCHAR2,
  p_order_type_low        IN VARCHAR2,
  p_order_type_high       IN VARCHAR2,
  p_order_number_low      IN NUMBER,
  p_order_number_high     IN NUMBER,
--myerrams, Bug: 5214119. Modified the types of all date vars to VARCHAR2 as conc prog passes VARCHAR2.
  p_order_date_low        IN VARCHAR2,
  p_order_date_high       IN VARCHAR2,
  p_fulfill_date_low      IN VARCHAR2,
  p_fulfill_date_high     IN VARCHAR2,
  p_accepted_date_low     IN VARCHAR2,
  p_accepted_date_high    IN VARCHAR2,
--myerrams, Bug: 5214119. end.
  p_acceptance_status     IN VARCHAR2,
  p_item_display          IN VARCHAR2,
  p_func_currency         IN VARCHAR2
);
END OE_CustAcceptRep_PVT;

 

/
