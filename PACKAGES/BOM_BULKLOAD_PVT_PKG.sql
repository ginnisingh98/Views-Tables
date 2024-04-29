--------------------------------------------------------
--  DDL for Package BOM_BULKLOAD_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BULKLOAD_PVT_PKG" AUTHID CURRENT_USER AS
/* $Header: BOMBBLPS.pls 120.1 2005/07/10 01:05:15 snelloli noship $ */
 /*#
  * API for Bulkloading data into the BOM interface tables from the Item Interface Tables.
  * The data will be in a particular result format.The API will be called after the item interface
  * tables are populated through the EGO Bulkload Concurrent program.The API then either calls the Open Interface
  * API or hte Java Concurrent Program for reading and processing Structure rows.
  * @rep:scope private
  * @rep:product BOM
  * @rep:displayname Bulkload API
  * @rep:lifecycle active
  * @rep:compatibility S
  * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
  */


 /*#
  * Method for populating the interface tables with data in a particular result format.
  * This method will be called after Item interface tables are populated with data.
  * It returns the status of data through the error messages and return code.
  * @param p_resultfmt_usage_id IN Identifier for the result format used for populating the data
  * @param p_user_id IN User Id for Authentication Check
  * @param p_conc_request_id IN Identifier of the EGO Bulkload Concurrent Program
  * @param p_language_code IN Language Code
  * @param x_errbuff IN OUT NOCOPY Error Buffer for writing error messagges
  * @param x_retcode IN OUT NOCOPY Return Status of the record processed
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:compatibility S
  * @rep:displayname Process Interface Lines
  */
  PROCEDURE PROCESS_BOM_INTERFACE_LINES
  (
    p_batch_id              IN         NUMBER,
    p_resultfmt_usage_id    IN         NUMBER,
    p_user_id               IN         NUMBER,
    p_conc_request_id       IN         NUMBER,
    p_language_code         IN         VARCHAR2,
    p_is_pdh_batch          IN         VARCHAR2,
    x_errbuff               IN OUT NOCOPY VARCHAR2,
    x_retcode               IN OUT NOCOPY VARCHAR2
  );


PROCEDURE Check_DeReference_Structure
  (
    p_request_id                IN NUMBER
  , p_batch_id                  IN NUMBER
  , p_assembly_item_id          IN NUMBER
  , p_organization_id           IN NUMBER
  , p_alternate_bom_designator  IN VARCHAR2
  , x_errbuff        OUT   NOCOPY VARCHAR2
  , x_retcode        OUT   NOCOPY VARCHAR2
    );

-- Data seperation logic for component user attributes.
PROCEDURE load_comp_usr_attr_interface
  (
    p_resultfmt_usage_id    IN         NUMBER
  , p_data_set_id           IN         NUMBER
  , x_errbuff               OUT NOCOPY VARCHAR2
  , x_retcode               OUT NOCOPY VARCHAR2
  );

END BOM_BULKLOAD_PVT_PKG; -- Package spec

 

/
