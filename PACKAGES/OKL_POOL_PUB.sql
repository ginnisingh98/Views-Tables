--------------------------------------------------------
--  DDL for Package OKL_POOL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_POOL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSZPS.pls 120.1 2008/02/29 10:16:08 veramach noship $ */
 /*#
 * Pool API allows user to create pool, update pool, add and clean contents
 * from the pool .
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Pool
 * @rep:category BUSINESS_ENTITY OKL_VENDOR_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:compatibility S
 */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_POOL_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 SUBTYPE polv_rec_type IS OKL_POOL_PVT.polv_rec_type;
 SUBTYPE poc_uv_tbl_type IS OKL_POOL_PVT.poc_uv_tbl_type;


 ------------------------------------------------------------------------------
  -- Program Units
 ------------------------------------------------------------------------------
/*#
 *Create Pool API allows users to create pool.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param p_polv_rec Pool Record
 * @param x_polv_rec Pool Record
 * @rep:displayname Create Pool
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_VENDOR_RELATIONSHIP
 */


 PROCEDURE create_pool(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN polv_rec_type
   ,x_polv_rec                     OUT NOCOPY polv_rec_type
 );


 /*#
 *Update Pool API allows users to update the pool.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param p_polv_rec Pool Record
 * @param x_polv_rec Pool Record
 * @rep:displayname Update Pool
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_VENDOR_RELATIONSHIP
 */

/*
  The description, short description and display in lease center fields of
  the pool are allowed to be updated in update_pool api.
*/
 PROCEDURE update_pool(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN  polv_rec_type
   ,x_polv_rec                     OUT NOCOPY polv_rec_type
 );


 /*#
 *Clean Up Pool Contents API allows users to clean up the given pool.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param p_pol_id Pool id
 * @param p_currency_code Currency Code
 * @param p_cust_object1_id1 Customer account identifier
 * @param p_sic_code  Service industry code
 * @param p_khr_id Contract Id
 * @param p_pre_tax_yield_from  Pre Tax Yield From
 * @param p_pre_tax_yield_to    Pre Tax Yield To
 * @param p_book_classification Book Classification
 * @param p_tax_owner  Tax Owner
 * @param p_pdt_id  Product Id
 * @param p_start_from_date Start From Date
 * @param p_start_to_date   Start To Date
 * @param p_end_from_date   End From Date
 * @param p_end_to_date     End To Date
 * @param p_stream_type_subclass Stream Type Subclass
 * @param p_streams_from_date Streams From Date
 * @param p_streams_to_date Streams To Date
 * @param x_poc_uv_tbl Pool Contents table
 * @rep:displayname Clean Up Pool Contents
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_VENDOR_RELATIONSHIP
 */
 PROCEDURE cleanup_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pol_id                       IN  NUMBER
   ,p_currency_code                IN VARCHAR2
   ,p_cust_object1_id1             IN NUMBER DEFAULT NULL
   ,p_sic_code                     IN VARCHAR2 DEFAULT NULL
   ,p_khr_id                       IN NUMBER DEFAULT NULL
   ,p_pre_tax_yield_from           IN NUMBER DEFAULT NULL
   ,p_pre_tax_yield_to             IN NUMBER DEFAULT NULL
   ,p_book_classification          IN VARCHAR2 DEFAULT NULL
   ,p_tax_owner                    IN VARCHAR2 DEFAULT NULL
   ,p_pdt_id                       IN NUMBER DEFAULT NULL
   ,p_start_from_date              IN DATE DEFAULT NULL
   ,p_start_to_date                IN DATE DEFAULT NULL
   ,p_end_from_date                IN DATE DEFAULT NULL
   ,p_end_to_date                  IN DATE DEFAULT NULL
   ,p_stream_type_subclass         IN VARCHAR2 DEFAULT NULL
   ,p_streams_from_date            IN DATE DEFAULT NULL
   ,p_streams_to_date              IN DATE DEFAULT NULL
   ,x_poc_uv_tbl                   OUT NOCOPY poc_uv_tbl_type);


/*#
 *Add Pool Contents API allows users to add pool contents.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param x_row_count Count of rows added to the pool
 * @param p_pol_id Pool id
 * @param p_currency_code Currency Code
 * @param p_cust_object1_id1 Customer account identifier
 * @param p_sic_code Service industry code
 * @param p_khr_id Contract Id
 * @param p_pre_tax_yield_from  Pre Tax Yield From
 * @param p_pre_tax_yield_to Pre Tax Yield To
 * @param p_book_classification Book Classification
 * @param p_tax_owner Tax Owner
 * @param p_pdt_id Product Id
 * @param p_start_from_date Start From date
 * @param p_start_to_date Start To Date
 * @param p_end_from_date End From Date
 * @param p_end_to_date  End To date
 * @param p_stream_type_subclass Stream Type Sublass
 * @param p_stream_element_from_date Stream Element From Date
 * @param p_stream_element_to_date Stream Element To Date
 * @param p_log_message flag to log the message Default is Yes
 * @rep:displayname Add Pool Contents
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_VENDOR_RELATIONSHIP
 */
 PROCEDURE add_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_row_count                    OUT NOCOPY NUMBER
   ,p_pol_id                       IN NUMBER
   ,p_currency_code                IN VARCHAR2
   ,p_cust_object1_id1             IN NUMBER
   ,p_sic_code                     IN VARCHAR2
   ,p_khr_id                       IN NUMBER
   ,p_pre_tax_yield_from           IN NUMBER
   ,p_pre_tax_yield_to             IN NUMBER
   ,p_book_classification          IN VARCHAR2
   ,p_tax_owner                    IN VARCHAR2
   ,p_pdt_id                       IN NUMBER
   ,p_start_from_date              IN DATE
   ,p_start_to_date                IN DATE
   ,p_end_from_date                IN DATE
   ,p_end_to_date                  IN DATE
   ,p_stream_type_subclass         IN VARCHAR2
   ,p_stream_element_from_date     IN DATE
   ,p_stream_element_to_date       IN DATE
   ,p_log_message 	           IN VARCHAR2 DEFAULT 'Y'
   );

END Okl_Pool_PUB;

/
