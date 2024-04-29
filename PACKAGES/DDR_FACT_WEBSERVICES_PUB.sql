--------------------------------------------------------
--  DDL for Package DDR_FACT_WEBSERVICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_FACT_WEBSERVICES_PUB" AUTHID CURRENT_USER AS
/* $Header: ddrpfwss.pls 120.1 2008/02/16 03:49:18 vbhave noship $ */

 -- Start of comments
 -- API name     : getSalesReturnItem
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get aggregate data from DDR RETAIL SALE RETURN ITEM DAY facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_valIN VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_codeIN VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getAgrSalesReturnItem(p_api_version     IN  NUMBER,
                                 p_mfg_org_cd      IN  VARCHAR2,
                                 p_org_cd          IN  VARCHAR2,
                                 p_org_dim_lvl_cd  IN  VARCHAR2,
                                 p_org_lvl_val     IN  VARCHAR2,
                                 p_exp_org_level   IN  VARCHAR2,
                                 p_loc_dim_lvl_cd  IN  VARCHAR2,
                                 p_loc_lvl_val     IN  VARCHAR2,
                                 p_exp_loc_level   IN  VARCHAR2,
                                 p_item_dim_lvl_cd IN  VARCHAR2,
                                 p_item_lvl_val    IN  VARCHAR2,
                                 p_exp_item_level  IN  VARCHAR2,
                                 p_time_dim_lvl_cd IN  VARCHAR2,
                                 p_time_lvl_val    IN  VARCHAR2,
                                 p_exp_time_level  IN  VARCHAR2,
                                 p_attribute1      IN  VARCHAR2,
                                 p_attribute2      IN  VARCHAR2,
                                 p_attribute3      IN  VARCHAR2,
                                 p_attribute4      IN  VARCHAR2,
                                 p_attribute5      IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 x_job_id          OUT NOCOPY VARCHAR2);

 -- Start of comments
 -- API name     : getAgrMrktItemSales
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get aggregate data from DDR MARKET ITEM SALES DAY facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments


 PROCEDURE getAgrMrktItemSales(p_api_version     IN  NUMBER,
                               p_mfg_org_cd      IN  VARCHAR2,
                               p_org_cd          IN  VARCHAR2,
                               p_org_dim_lvl_cd  IN  VARCHAR2,
                               p_org_lvl_val     IN  VARCHAR2,
                               p_exp_org_level   IN  VARCHAR2,
                               p_loc_dim_lvl_cd  IN  VARCHAR2,
                               p_loc_lvl_val     IN  VARCHAR2,
                               p_exp_loc_level   IN  VARCHAR2,
                               p_item_dim_lvl_cd IN  VARCHAR2,
                               p_item_lvl_val    IN  VARCHAR2,
                               p_exp_item_level  IN  VARCHAR2,
                               p_time_dim_lvl_cd IN  VARCHAR2,
                               p_time_lvl_val    IN  VARCHAR2,
                               p_exp_time_level  IN  VARCHAR2,
                               p_attribute1      IN  VARCHAR2,
                               p_attribute2      IN  VARCHAR2,
                               p_attribute3      IN  VARCHAR2,
                               p_attribute4      IN  VARCHAR2,
                               p_attribute5      IN  VARCHAR2,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_msg_count       OUT NOCOPY NUMBER,
                               x_msg_data        OUT NOCOPY VARCHAR2,
                               x_job_id          OUT NOCOPY VARCHAR2);

 -- Start of comments
 -- API name     : getAgrPrmtinPlan
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get aggregate data from DDR PROMOTION PLAN facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments


 PROCEDURE getAgrPrmtinPlan(p_api_version     IN  NUMBER,
                            p_mfg_org_cd      IN  VARCHAR2,
                            p_org_cd          IN  VARCHAR2,
                            p_org_dim_lvl_cd  IN  VARCHAR2,
                            p_org_lvl_val     IN  VARCHAR2,
                            p_exp_org_level   IN  VARCHAR2,
                            p_loc_dim_lvl_cd  IN  VARCHAR2,
                            p_loc_lvl_val     IN  VARCHAR2,
                            p_exp_loc_level   IN  VARCHAR2,
                            p_item_dim_lvl_cd IN  VARCHAR2,
                            p_item_lvl_val    IN  VARCHAR2,
                            p_exp_item_level  IN  VARCHAR2,
                            p_time_dim_lvl_cd IN  VARCHAR2,
                            p_time_lvl_val    IN  VARCHAR2,
                            p_exp_time_level  IN  VARCHAR2,
                            p_attribute1      IN  VARCHAR2,
                            p_attribute2      IN  VARCHAR2,
                            p_attribute3      IN  VARCHAR2,
                            p_attribute4      IN  VARCHAR2,
                            p_attribute5      IN  VARCHAR2,
                            x_return_status   OUT NOCOPY  VARCHAR2,
                            x_msg_count       OUT NOCOPY  NUMBER,
                            x_msg_data        OUT NOCOPY  VARCHAR2,
                            x_job_id          OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : getAgrRtlInvItmDat
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get aggregate data from DDR INVENTORY ITEM STATE facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getAgrRtlInvItmDat (p_api_version      IN  NUMBER,
                               p_mfg_org_cd       IN  VARCHAR2,
                               p_org_cd           IN  VARCHAR2,
                               p_org_dim_lvl_cd   IN  VARCHAR2,
                               p_org_lvl_val      IN  VARCHAR2,
                               p_exp_org_level    IN  VARCHAR2,
                               p_loc_dim_lvl_cd   IN  VARCHAR2,
                               p_loc_lvl_val      IN  VARCHAR2,
                               p_exp_loc_level    IN  VARCHAR2,
                               p_item_dim_lvl_cd  IN  VARCHAR2,
                               p_item_lvl_val     IN  VARCHAR2,
                               p_exp_item_level   IN  VARCHAR2,
                               p_time_dim_lvl_cd  IN  VARCHAR2,
                               p_time_lvl_val     IN  VARCHAR2,
                               p_exp_time_level   IN  VARCHAR2,
                               p_attribute1       IN  VARCHAR2,
                               p_attribute2       IN  VARCHAR2,
                               p_attribute3       IN  VARCHAR2,
                               p_attribute4       IN  VARCHAR2,
                               p_attribute5       IN  VARCHAR2,
                               x_return_status    OUT NOCOPY  VARCHAR2,
                               x_msg_count        OUT NOCOPY  NUMBER,
                               x_msg_data         OUT NOCOPY  VARCHAR2,
                               x_job_id           OUT NOCOPY  VARCHAR2);


 -- Start of comments
 -- API name     : getAgrRetailerOrderItm
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get aggregate data from DDR RETAILER ORDER ITEM DAY facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getAgrRetailerOrderItm(p_api_version     IN  NUMBER,
                                  p_mfg_org_cd      IN  VARCHAR2,
                                  p_org_cd          IN  VARCHAR2,
                                  p_org_dim_lvl_cd  IN  VARCHAR2,
                                  p_org_lvl_val     IN  VARCHAR2,
                                  p_exp_org_level   IN  VARCHAR2,
                                  p_loc_dim_lvl_cd  IN  VARCHAR2,
                                  p_loc_lvl_val     IN  VARCHAR2,
                                  p_exp_loc_level   IN  VARCHAR2,
                                  p_item_dim_lvl_cd IN  VARCHAR2,
                                  p_item_lvl_val    IN  VARCHAR2,
                                  p_exp_item_level  IN  VARCHAR2,
                                  p_time_dim_lvl_cd IN  VARCHAR2,
                                  p_time_lvl_val    IN  VARCHAR2,
                                  p_exp_time_level  IN  VARCHAR2,
                                  p_attribute1      IN  VARCHAR2,
                                  p_attribute2      IN  VARCHAR2,
                                  p_attribute3      IN  VARCHAR2,
                                  p_attribute4      IN  VARCHAR2,
                                  p_attribute5      IN  VARCHAR2,
                                  x_return_status   OUT NOCOPY  VARCHAR2,
                                  x_msg_count       OUT NOCOPY  NUMBER,
                                  x_msg_data        OUT NOCOPY  VARCHAR2,
                                  x_job_id          OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : getAgrSaleFrecastItm
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get aggregate data from DDR SALE FORECAST ITEM BY DAY facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getAgrSaleFrecastItm(p_api_version     IN  NUMBER,
                                p_mfg_org_cd      IN  VARCHAR2,
                                p_org_cd          IN  VARCHAR2,
                                p_org_dim_lvl_cd  IN  VARCHAR2,
                                p_org_lvl_val     IN  VARCHAR2,
                                p_exp_org_level   IN  VARCHAR2,
                                p_loc_dim_lvl_cd  IN  VARCHAR2,
                                p_loc_lvl_val     IN  VARCHAR2,
                                p_exp_loc_level   IN  VARCHAR2,
                                p_item_dim_lvl_cd IN  VARCHAR2,
                                p_item_lvl_val    IN  VARCHAR2,
                                p_exp_item_level  IN  VARCHAR2,
                                p_time_dim_lvl_cd IN  VARCHAR2,
                                p_time_lvl_val    IN  VARCHAR2,
                                p_exp_time_level  IN  VARCHAR2,
                                p_attribute1      IN  VARCHAR2,
                                p_attribute2      IN  VARCHAR2,
                                p_attribute3      IN  VARCHAR2,
                                p_attribute4      IN  VARCHAR2,
                                p_attribute5      IN  VARCHAR2,
                                x_return_status   OUT NOCOPY  VARCHAR2,
                                x_msg_count       OUT NOCOPY  NUMBER,
                                x_msg_data        OUT NOCOPY  VARCHAR2,
                                x_job_id          OUT NOCOPY  VARCHAR2);


  -- Start of comments
  -- API name     : getAgrRetailerShipItem
  -- Type:  Public
  -- Pre-reqs: None.
  -- Function: to get aggregate data from DDR RETAILER SHIP ITEM DAY facts
  -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getAgrRetailerShipItem(p_api_version     IN  NUMBER,
                                  p_mfg_org_cd      IN  VARCHAR2,
                                  p_org_cd          IN  VARCHAR2,
                                  p_org_dim_lvl_cd  IN  VARCHAR2,
                                  p_org_lvl_val     IN  VARCHAR2,
                                  p_exp_org_level   IN  VARCHAR2,
                                  p_loc_dim_lvl_cd  IN  VARCHAR2,
                                  p_loc_lvl_val     IN  VARCHAR2,
                                  p_exp_loc_level   IN  VARCHAR2,
                                  p_item_dim_lvl_cd IN  VARCHAR2,
                                  p_item_lvl_val    IN  VARCHAR2,
                                  p_exp_item_level  IN  VARCHAR2,
                                  p_time_dim_lvl_cd IN  VARCHAR2,
                                  p_time_lvl_val    IN  VARCHAR2,
                                  p_exp_time_level  IN  VARCHAR2,
                                  p_attribute1      IN  VARCHAR2,
                                  p_attribute2      IN  VARCHAR2,
                                  p_attribute3      IN  VARCHAR2,
                                  p_attribute4      IN  VARCHAR2,
                                  p_attribute5      IN  VARCHAR2,
                                  x_return_status   OUT NOCOPY  VARCHAR2,
                                  x_msg_count       OUT NOCOPY  NUMBER,
                                  x_msg_data        OUT NOCOPY  VARCHAR2,
                                  x_job_id          OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : getSalesReturnItem
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get detailed data from DSR facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getSalesReturnItem(p_api_version      IN  NUMBER,
                              p_mfg_org_cd       IN  VARCHAR2,
                              p_org_cd           IN  VARCHAR2,
                              p_org_dim_lvl_cd   IN  VARCHAR2,
                              p_org_lvl_val      IN  VARCHAR2,
                              p_loc_dim_lvl_cd   IN  VARCHAR2,
                              p_loc_lvl_val      IN  VARCHAR2,
                              p_item_dim_lvl_cd  IN  VARCHAR2,
                              p_item_lvl_val     IN  VARCHAR2,
                              p_time_dim_lvl_cd  IN  VARCHAR2,
                              p_time_lvl_val     IN  VARCHAR2,
                              p_attribute1       IN  VARCHAR2,
                              p_attribute2       IN  VARCHAR2,
                              p_attribute3       IN  VARCHAR2,
                              p_attribute4       IN  VARCHAR2,
                              p_attribute5       IN  VARCHAR2,
                              x_return_status    OUT NOCOPY  VARCHAR2,
                              x_msg_count        OUT NOCOPY  NUMBER,
                              x_msg_data         OUT NOCOPY  VARCHAR2,
                              x_job_id           OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : getMrktItemSales
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get detailed data from DSR MARKET ITEM SALES DAY facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getMrktItemSales(p_api_version      IN  NUMBER,
                            p_mfg_org_cd       IN  VARCHAR2,
                            p_org_cd           IN  VARCHAR2,
                            p_org_dim_lvl_cd   IN  VARCHAR2,
                            p_org_lvl_val      IN  VARCHAR2,
                            p_loc_dim_lvl_cd   IN  VARCHAR2,
                            p_loc_lvl_val      IN  VARCHAR2,
                            p_item_dim_lvl_cd  IN  VARCHAR2,
                            p_item_lvl_val     IN  VARCHAR2,
                            p_time_dim_lvl_cd  IN  VARCHAR2,
                            p_time_lvl_val     IN  VARCHAR2,
                            p_attribute1       IN  VARCHAR2,
                            p_attribute2       IN  VARCHAR2,
                            p_attribute3       IN  VARCHAR2,
                            p_attribute4       IN  VARCHAR2,
                            p_attribute5       IN  VARCHAR2,
                            x_return_status    OUT NOCOPY  VARCHAR2,
                            x_msg_count        OUT NOCOPY  NUMBER,
                            x_msg_data         OUT NOCOPY  VARCHAR2,
                            x_job_id           OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : getPrmtinPlan
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get detailed data from DSR PROMOTION PLAN facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getPrmtinPlan(p_api_version      IN  NUMBER,
                         p_mfg_org_cd       IN  VARCHAR2,
                         p_org_cd           IN  VARCHAR2,
                         p_org_dim_lvl_cd   IN  VARCHAR2,
                         p_org_lvl_val      IN  VARCHAR2,
                         p_loc_dim_lvl_cd   IN  VARCHAR2,
                         p_loc_lvl_val      IN  VARCHAR2,
                         p_item_dim_lvl_cd  IN  VARCHAR2,
                         p_item_lvl_val     IN  VARCHAR2,
                         p_time_dim_lvl_cd  IN  VARCHAR2,
                         p_time_lvl_val     IN  VARCHAR2,
                         p_attribute1       IN  VARCHAR2,
                         p_attribute2       IN  VARCHAR2,
                         p_attribute3       IN  VARCHAR2,
                         p_attribute4       IN  VARCHAR2,
                         p_attribute5       IN  VARCHAR2,
                         x_return_status    OUT NOCOPY  VARCHAR2,
                         x_msg_count        OUT NOCOPY  NUMBER,
                         x_msg_data         OUT NOCOPY  VARCHAR2,
                         x_job_id           OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : getRtlInvItmDat
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get detailed data from DSR RETAIL INVENTORY ITEM DAY facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getRtlInvItmDat(p_api_version     IN  NUMBER,
                           p_mfg_org_cd      IN  VARCHAR2,
                           p_org_cd          IN  VARCHAR2,
                           p_org_dim_lvl_cd  IN  VARCHAR2,
                           p_org_lvl_val     IN  VARCHAR2,
                           p_loc_dim_lvl_cd  IN  VARCHAR2,
                           p_loc_lvl_val     IN  VARCHAR2,
                           p_item_dim_lvl_cd IN  VARCHAR2,
                           p_item_lvl_val    IN  VARCHAR2,
                           p_time_dim_lvl_cd IN  VARCHAR2,
                           p_time_lvl_val    IN  VARCHAR2,
                           p_attribute1      IN  VARCHAR2,
                           p_attribute2      IN  VARCHAR2,
                           p_attribute3      IN  VARCHAR2,
                           p_attribute4      IN  VARCHAR2,
                           p_attribute5      IN  VARCHAR2,
                           x_return_status   OUT NOCOPY  VARCHAR2,
                           x_msg_count       OUT NOCOPY  NUMBER,
                           x_msg_data        OUT NOCOPY  VARCHAR2,
                           x_job_id          OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : getRetailerOrderItm
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get detailed data from DSR RETAILER ORDER ITEM DAY facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARRCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getRetailerOrderItm(p_api_version      IN  NUMBER,
                               p_mfg_org_cd       IN  VARCHAR2,
                               p_org_cd           IN  VARCHAR2,
                               p_org_dim_lvl_cd   IN  VARCHAR2,
                               p_org_lvl_val      IN  VARCHAR2,
                               p_loc_dim_lvl_cd   IN  VARCHAR2,
                               p_loc_lvl_val      IN  VARCHAR2,
                               p_item_dim_lvl_cd  IN  VARCHAR2,
                               p_item_lvl_val     IN  VARCHAR2,
                               p_time_dim_lvl_cd  IN  VARCHAR2,
                               p_time_lvl_val     IN  VARCHAR2,
                               p_attribute1       IN  VARCHAR2,
                               p_attribute2       IN  VARCHAR2,
                               p_attribute3       IN  VARCHAR2,
                               p_attribute4       IN  VARCHAR2,
                               p_attribute5       IN  VARCHAR2,
                               x_return_status    OUT NOCOPY  VARCHAR2,
                               x_msg_count        OUT NOCOPY  NUMBER,
                               x_msg_data         OUT NOCOPY  VARCHAR2,
                               x_job_id           OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : getSaleFrecastItm
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get detailed data from DSR facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getSaleFrecastItm(p_api_version      IN  NUMBER,
                             p_mfg_org_cd       IN  VARCHAR2,
                             p_org_cd           IN  VARCHAR2,
                             p_org_dim_lvl_cd   IN  VARCHAR2,
                             p_org_lvl_val      IN  VARCHAR2,
                             p_loc_dim_lvl_cd   IN  VARCHAR2,
                             p_loc_lvl_val      IN  VARCHAR2,
                             p_item_dim_lvl_cd  IN  VARCHAR2,
                             p_item_lvl_val     IN  VARCHAR2,
                             p_time_dim_lvl_cd  IN  VARCHAR2,
                             p_time_lvl_val     IN  VARCHAR2,
                             p_attribute1       IN  VARCHAR2,
                             p_attribute2       IN  VARCHAR2,
                             p_attribute3       IN  VARCHAR2,
                             p_attribute4       IN  VARCHAR2,
                             p_attribute5       IN  VARCHAR2,
                             x_return_status    OUT NOCOPY  VARCHAR2,
                             x_msg_count        OUT NOCOPY  NUMBER,
                             x_msg_data         OUT NOCOPY  VARCHAR2,
                             x_job_id           OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : getRetailerShipItem
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get detailed data from DSR facts
 -- Parameters:
 -- IN:p_api_version      IN  NUMBERRequired
 --    p_mfg_org_cd       IN  VARCHAR2Required
 --          Manufaturer organization code
 --    p_org_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the organization hierarchy level code
 --    p_org_lvl_val      IN  VARCHAR2
 --          Organization hierarchy level code value
 --    p_exp_org_level    IN  VARCHAR2
 --          expected aggregation level of organization hierarchy
 --    p_loc_dim_lvl_cd   IN  VARCHAR2
 --          Identifies the location hierarchy level code
 --    p_loc_lvl_val      IN  VARCHAR2
 --          Location hierarchy level code
 --    p_exp_loc_level    IN  VARCHAR2
 --          Expected aggregation level of location hierarchy
 --    p_item_dim_lvl_cd  IN  VARCHAR2
 --    p_item_lvl_val     IN  VARCHAR2
 --    p_exp_item_level   IN  VARCHAR2
 --    p_time_dim_lvl_cd  IN  VARCHAR2
 --    p_time_lvl_val     IN  VARCHAR2
 --    p_exp_time_level   IN  VARCHAR2
 --    p_fact_code        IN  VARCHAR2
 --    p_attribute1       IN  VARCHAR2
 --    p_attribute2       IN  VARCHAR2
 --    p_attribute3       IN  VARCHAR2
 --    p_attribute4       IN  VARCHAR2
 --    p_attribute5       IN  VARCHAR2
 --    x_file_path        OUT NOCOPY  VARCHAR2
 --    Version: Current version1.0
 --    Initial version 1.0
 -- End of comments

 PROCEDURE getRetailerShipItem(p_api_version     IN  NUMBER,
                               p_mfg_org_cd      IN  VARCHAR2,
                               p_org_cd          IN  VARCHAR2,
                               p_org_dim_lvl_cd  IN  VARCHAR2,
                               p_org_lvl_val     IN  VARCHAR2,
                               p_loc_dim_lvl_cd  IN  VARCHAR2,
                               p_loc_lvl_val     IN  VARCHAR2,
                               p_item_dim_lvl_cd IN  VARCHAR2,
                               p_item_lvl_val    IN  VARCHAR2,
                               p_time_dim_lvl_cd IN  VARCHAR2,
                               p_time_lvl_val    IN  VARCHAR2,
                               p_attribute1      IN  VARCHAR2,
                               p_attribute2      IN  VARCHAR2,
                               p_attribute3      IN  VARCHAR2,
                               p_attribute4      IN  VARCHAR2,
                               p_attribute5      IN  VARCHAR2,
                               x_return_status   OUT NOCOPY   VARCHAR2,
                               x_msg_count       OUT NOCOPY   NUMBER,
                               x_msg_data        OUT NOCOPY   VARCHAR2,
                               x_job_id          OUT NOCOPY   VARCHAR2);

 -- Start of comments
 -- API name     : getFileName
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get file names based on the input job id
 -- Parameters:
 -- IN    :
 --  p_api_version           IN NUMBERRequired
 --  p_api_version           IN VARCHAR2
 --  p_api_version           IN VARCHAR2
 --  OUT  :   x_job_id       OUT NOCOPY  VARCHAR2
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments
 PROCEDURE getFileName(p_api_version   IN  NUMBER,
                       x_job_id        IN  VARCHAR2,
                       p_mfg_org_cd    IN  VARCHAR2,
                       x_return_status OUT NOCOPY  VARCHAR2,
                       x_msg_count     OUT NOCOPY  NUMBER,
                       x_msg_data      OUT NOCOPY  VARCHAR2,
                       x_file_path     OUT NOCOPY  VARCHAR2);

END;

/
