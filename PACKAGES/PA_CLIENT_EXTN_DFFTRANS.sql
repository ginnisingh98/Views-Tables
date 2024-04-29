--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_DFFTRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_DFFTRANS" AUTHID CURRENT_USER AS
--$Header: PAPDFFCS.pls 120.4 2006/07/25 19:40:17 skannoji noship $
/*#
 * This extension is used to map segments of descriptive flexfield that are transferred from Payables to
 * Oracle Projects or from Oracle Projects to Payables.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname  Descriptive Flexfield Mapping Client Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PAYABLE_INV_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
TYPE attribute_a IS TABLE of pa_expenditure_items_all.attribute1%TYPE
	INDEX BY BINARY_INTEGER;


/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : DFF_map_segments_f
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Function
-- Function      : Given the attribute number, returns the attribute value
-- Parameters    :
-- IN
--            p_attribute_number          NUMBER
--            p_calling_module            VARCHAR2
--            p_trx_ref_1                 NUMBER
--            p_trx_ref_2                 NUMBER
--            p_trx_type                  VARCHAR2
--            p_system_linkage_function   VARCHAR2
--            p_submodule                 VARCHAR2
--            p_expenditure_type          VARCHAR2
--            p_set_of_books_id           NUMBER
--            p_org_id                    NUMBER
--            p_attribute_category        VARCHAR2
--            p_attribute_1               VARCHAR2
--            p_attribute_2               VARCHAR2
--            p_attribute_3               VARCHAR2
--            p_attribute_4               VARCHAR2
--            p_attribute_5               VARCHAR2
--            p_attribute_6               VARCHAR2
--            p_attribute_7               VARCHAR2
--            p_attribute_8               VARCHAR2
--            p_attribute_9               VARCHAR2
--            p_attribute_10              VARCHAR2

/*----------------------------------------------------------------------------*/



/*#
 * This API provides the mapping logic for the descriptive flex fields.The default logic maps segment n in the originating  application
 * to segment n in the receiving application. You can change this function to map the segments according to your business rules
 * @return Returns the mapping of Descriptive FlexField segments.
 * @param p_attribute_number  The identifier of the attribute to be mapped.
 * @rep:paraminfo {@rep:required}
 * @param p_calling_module The module that calls the extension.
 * @rep:paraminfo {@rep:required}
 * @param p_trx_ref_1 Reference information passed to the extension.
 * @rep:paraminfo {@rep:required}
 * @param p_trx_ref_2 Reference information passed to the extension.
 * @rep:paraminfo {@rep:required}
 * @param p_trx_type Type of transaction .
 * @rep:paraminfo {@rep:required}
 * @param p_system_linkage_function  The expenditure type class function.
 * @rep:paraminfo {@rep:required}
 * @param p_submodule  Name of the calling submodule.
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_type The expenditure type.
 * @rep:paraminfo {@rep:required}
 * @param p_set_of_books_id  The identifier of the set of books.
 * @rep:paraminfo {@rep:required}
 * @param p_org_id The identifier of the organization.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category The attribute category for the descriptive flexfield.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_1  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_2   The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_3  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_4   The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_5   The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_6   The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_7   The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_8   The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_9   The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_10   The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Descriptive Flexfields Mapping Logic
 * @rep:compatibility S
*/

FUNCTION DFF_map_segments_f(
				p_attribute_number	      IN NUMBER,
				p_calling_module	         IN VARCHAR2,
				p_trx_ref_1    		      IN NUMBER,
				p_trx_ref_2		            IN NUMBER,
				p_trx_type		            IN VARCHAR2,
				p_system_linkage_function  IN VARCHAR2,
				p_submodule             	IN VARCHAR2,
				p_expenditure_type    	   IN VARCHAR2,
				p_set_of_books_id 	      IN NUMBER,
				p_org_id		               IN NUMBER,
				p_attribute_category	      IN VARCHAR2,
				p_attribute_1		         IN VARCHAR2,
				p_attribute_2		         IN VARCHAR2,
            p_attribute_3              IN VARCHAR2,
            p_attribute_4              IN VARCHAR2,
            p_attribute_5              IN VARCHAR2,
            p_attribute_6              IN VARCHAR2,
            p_attribute_7              IN VARCHAR2,
            p_attribute_8              IN VARCHAR2,
            p_attribute_9              IN VARCHAR2,
				p_attribute_10		         IN VARCHAR2)
		RETURN pa_expenditure_items_all.attribute1%TYPE;
pragma RESTRICT_REFERENCES ( DFF_map_segments_f, WNDS, WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : DFF_map_segments_PA_and_AP
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : Provide the DFF segments mapping logic
-- Parameters    :
-- IN
--            p_attribute_number          NUMBER
--            p_calling_module            VARCHAR2
--            p_trx_ref_1                 NUMBER
--            p_trx_ref_2                 NUMBER
--            p_trx_type                  VARCHAR2
--            p_system_linkage_function   VARCHAR2
--            p_submodule                 VARCHAR2
--            p_expenditure_type          VARCHAR2
--            p_set_of_books_id           NUMBER
--            p_org_id                    NUMBER
-- IN/OUT
--            p_attribute_category        VARCHAR2
--            p_attribute_1               VARCHAR2
--            p_attribute_2               VARCHAR2
--            p_attribute_3               VARCHAR2
--            p_attribute_4               VARCHAR2
--            p_attribute_5               VARCHAR2
--            p_attribute_6               VARCHAR2
--            p_attribute_7               VARCHAR2
--            p_attribute_8               VARCHAR2
--            p_attribute_9               VARCHAR2
--            p_attribute_10              VARCHAR2
-- OUT
--            x_status_code               VARCHAR2

/*----------------------------------------------------------------------------*/


/*#
 * This API provides the procedure calls the function dff_map_segments_f, and stores the mapped segments in the
 * parameters p_attribute_1 through p_attribute_10.
 * @param p_calling_module The module that calls theextension.
 * @rep:paraminfo {@rep:required}
 * @param p_trx_ref_1 Reference information passed to the extension.
 * @rep:paraminfo {@rep:required}
 * @param p_trx_ref_2 Reference information passed to the extension.
 * @rep:paraminfo {@rep:required}
 * @param p_trx_type Type of transaction .
 * @rep:paraminfo {@rep:required}
 * @param p_system_linkage_function  The expenditure type class function.
 * @rep:paraminfo {@rep:required}
 * @param p_submodule  Name of the calling submodule.
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_type The expenditure type.
 * @rep:paraminfo {@rep:required}
 * @param p_set_of_books_id  The identifier of the set of books.
 * @rep:paraminfo {@rep:required}
 * @param p_org_id The identifier of the organization.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category The attribute category for the descriptive flexfield.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_1  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_2  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_3  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_4  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_5  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_6  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_7  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_8  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_9  The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_10 The descriptive flexfield segment.
 * @rep:paraminfo {@rep:required}
 * @param x_status_code Status of the procedure.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Descriptive Flexfields Mapping Segments
 * @rep:compatibility S
*/

PROCEDURE DFF_map_segments_PA_and_AP (
				p_calling_module	         IN VARCHAR2,
				p_trx_ref_1		            IN NUMBER,
				p_trx_ref_2		            IN NUMBER,
				p_trx_type		            IN VARCHAR2,
				p_system_linkage_function  IN VARCHAR2,
				p_submodule             	IN VARCHAR2,
				p_expenditure_type    	   IN VARCHAR2,
				p_set_of_books_id 	      IN NUMBER,
				p_org_id		               IN NUMBER,
				p_attribute_category	      IN OUT NOCOPY VARCHAR2,
				p_attribute_1		         IN OUT NOCOPY VARCHAR2,
				p_attribute_2		         IN OUT NOCOPY VARCHAR2,
            p_attribute_3              IN OUT NOCOPY VARCHAR2,
            p_attribute_4              IN OUT NOCOPY VARCHAR2,
            p_attribute_5              IN OUT NOCOPY VARCHAR2,
            p_attribute_6              IN OUT NOCOPY VARCHAR2,
            p_attribute_7              IN OUT NOCOPY VARCHAR2,
            p_attribute_8              IN OUT NOCOPY VARCHAR2,
            p_attribute_9              IN OUT NOCOPY VARCHAR2,
				p_attribute_10		         IN OUT NOCOPY VARCHAR2,
            x_status_code		         OUT NOCOPY VARCHAR2);

END PA_CLIENT_EXTN_DFFTRANS;


 

/
