--------------------------------------------------------
--  DDL for Package INV_PRINT_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PRINT_REQUEST" AUTHID CURRENT_USER AS
/* $Header: INVPRRQS.pls 115.7 2003/10/31 23:56:04 qxliu ship $ */
G_PKG_NAME	CONSTANT VARCHAR2(50) := 'INV_PRINT_REQUEST';

PROCEDURE SYNC_PRINT_REQUEST
(
	p_xml_content 		IN LONG
,	x_job_status 		OUT NOCOPY VARCHAR2
,	x_printer_status	OUT NOCOPY VARCHAR2
,	x_status_type		OUT	NOCOPY NUMBER
);

PROCEDURE WRITE_XML
(
	p_xml_content 		IN LONG
,	p_request_id		IN NUMBER
,	x_return_status		OUT NOCOPY VARCHAR2
,	x_msg_count			OUT NOCOPY NUMBER
,	x_msg_data			OUT NOCOPY VARCHAR2
);

PROCEDURE GET_REQUEST_STATUS
(
	p_request_id		IN	NUMBER
,	x_job_status		OUT NOCOPY VARCHAR2
,	x_printer_status	OUT NOCOPY VARCHAR2
,	x_status_type		OUT	NOCOPY NUMBER
);

/*
 * Method for sending the label XML file to a TCP-IP address when profile
 * WMS:Label Print Mode is set to Synchronous TCP/IP. The TCP-IP address
 * is derived by first retrieving the printer specified in the XML file,
 * and then doing a lookup for this printer in the Printer-IP table.
 */
PROCEDURE SYNC_PRINT_TCPIP
(
	p_xml_content 		IN LONG
,	x_job_status 		OUT NOCOPY VARCHAR2
,	x_printer_status	OUT NOCOPY VARCHAR2
,	x_status_type		OUT	NOCOPY NUMBER
,	x_return_status		OUT NOCOPY VARCHAR2
,	x_return_msg		OUT NOCOPY VARCHAR2
);

/*
 * Method for sending a string to a TCP-IP address. Used to send the
 * label-XML file to a print-server. The x_return_msg returns any
 * message send back from this TCP-IP address. This function returns
 * 0 if the file was send successfully. It returns -1 if there was
 * any error.
 */
FUNCTION SEND_XML_TCPIP
(
        p_ip_address            IN  VARCHAR2
,       p_port                  IN  VARCHAR2
,       p_xml_content           IN  VARCHAR2
,       x_return_msg            OUT  NOCOPY VARCHAR2
,		x_printer_status        OUT  NOCOPY VARCHAR2
) return NUMBER;

END INV_PRINT_REQUEST;

 

/
