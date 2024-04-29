--------------------------------------------------------
--  DDL for Package IGC_CC_COMMON_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_COMMON_UTILS_PVT" AUTHID CURRENT_USER AS
/*$Header: IGCUTILS.pls 120.1.12010000.2 2008/08/29 13:02:11 schakkin ship $*/

/*=======================================================================+
 |                      PROCEDURE Get_Header_Desc
 |                                                                       |
 | Note : This procedure is designed to get the descriptions of all the  |
 |        coded fields stored at the header level in igc_cc_headers      |
 |        It is used by forms like IGCCSUMM to get the descriptions      |
 |        of the field to be displayed to the user.                      |
 |                                                                       |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |   p_cc_header_id       igc_cc_headers.cc_header_id                    |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Get_Header_Desc
(
   p_api_version         IN NUMBER,
   p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status      OUT NOCOPY VARCHAR2,
   p_msg_count          OUT NOCOPY NUMBER,
   p_msg_data           OUT NOCOPY VARCHAR2,

   p_cc_header_id        IN NUMBER,
   p_type_desc          OUT NOCOPY VARCHAR2,
   p_state_desc         OUT NOCOPY VARCHAR2,
   p_apprvl_status_desc OUT NOCOPY VARCHAR2,
   p_ctrl_status_desc   OUT NOCOPY VARCHAR2,
   p_cc_owner_name      OUT NOCOPY VARCHAR2,
   p_cc_preparer_name   OUT NOCOPY VARCHAR2,
   p_cc_access_level    OUT NOCOPY VARCHAR2,
   p_vendor_name        OUT NOCOPY VARCHAR2,
   p_bill_to_location   OUT NOCOPY VARCHAR2,
   p_vendor_site_code   OUT NOCOPY VARCHAR2,
   p_vendor_contact     OUT NOCOPY VARCHAR2,
   p_vendor_number      OUT NOCOPY VARCHAR2,
   p_term_name          OUT NOCOPY VARCHAR2,
   p_parent_cc_num      OUT NOCOPY VARCHAR2,
   p_vendor_hold_flag   OUT NOCOPY VARCHAR2
);


/*=======================================================================+
 |                      FUNCTION Date_Is_Valid
 |                                                                       |
 | Note : This procedure is designed to check whether the fiscal year of |
 |        the invoice and that of the payment forecast line of a CC are  |
 |        the same or not.                                               |
 |                                                                       |
 |                                                                       |
 | Parameters :                                                          |
 |     x_gl_date                   GL Date of the invoice                |
 |     x_po_header_id                                                    |
 |     x_po_line_id
 |     x_po_dist_num	                                                 |
 |     x_shipment_num                                                    |
 +=======================================================================*/

FUNCTION DATE_IS_VALID(x_form_name VARCHAR2,
				x_gl_date gl_period_statuses.start_date%type,
				x_po_header_id po_headers_all.po_header_id%type,
				x_po_line_id   po_lines_all.po_line_id%type,
				x_line_location_id po_line_locations_all.line_location_id%type,
				x_po_distribution_id po_distributions_all.po_distribution_id%type,
				x_po_dist_num  po_distributions_all.distribution_num%type,
				x_shipment_num po_line_locations_all.shipment_num%type,
				x_line_num po_lines_all.line_num%type)
RETURN BOOLEAN;



/*=======================================================================+
 |                      FUNCTION XML_REPORT_ENABLED
 |                                                                       |
 | Note : This function is designed to decide if the xml report(s) is    |
 |        to be triggered or not. Presently it returns true. In future   |
 |        the function can be modified to incorporate profile options    |
	  and return true/false based on conditions.                     |
 +=======================================================================*/

FUNCTION XML_REPORT_ENABLED

RETURN BOOLEAN;



/*=======================================================================+
 |                      PROCEDURE GET_XML_LAYOUT_INFO
 |                                                                       |
 | Note : This procedure is designed to get layout information of the    |
 |        xml report that is to be generated.                            |
 |									                   |
 | Parameters :                                                          |
 |                                                                       |
 |   p_lang                     Language, Takes the default value        |
 |                              when no value is obtained                |
 |   p_terr                     Territory, Takes the default value       |
 |                              when no value is obtained                |
 |   p_lob_code                 BiPubllisher Code for the XML Report     |
 |   p_application_short_name   Short Name of the Application            |
 |   p_template_code            Template Code for the XML Report         |
 +=======================================================================*/

PROCEDURE GET_XML_LAYOUT_INFO
(
    p_lang                   IN OUT NOCOPY VARCHAR2,
    p_terr                   IN OUT NOCOPY VARCHAR2,
    p_lob_code               IN VARCHAR2,
    p_application_short_name IN VARCHAR2,
    p_template_code          IN VARCHAR2
);




END IGC_CC_COMMON_UTILS_PVT;

/
