--------------------------------------------------------
--  DDL for Package DDR_WEBSERVICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_WEBSERVICES_PUB" AUTHID CURRENT_USER AS
/* $Header: ddrpcwss.pls 120.0 2008/02/16 02:47:07 vbhave noship $ */

 -- Start of comments
 -- API name     : get_dsr_fact_aggr
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get aggregate data from DSR facts
 -- Parameters:
 -- IN    :
 --  p_api_version         IN NUMBER Required
 --  p_mfg_org_cd          IN VARCHAR2 Required
 --      Manufaturer organization code
 --  p_org_dim_lvl_cd      IN VARCHAR2
 --      Identifies the organization hierarchy level code
 --  p_org_lvl_val         IN VARCHAR2
 --      Organization hierarchy level code value
 --  p_exp_org_level       IN VARCHAR2
 --      expected aggregation level of organization hierarchy
 --  p_loc_dim_lvl_cd      IN VARCHAR2
 --      Identifies the location hierarchy level code
 --  p_loc_lvl_val         IN VARCHAR2
 --      Location hierarchy level code
 --  p_exp_loc_level       IN VARCHAR2
 --      Expected aggregation level of location hierarchy
 --  p_item_dim_lvl_cd     IN VARCHAR2
 --  p_item_lvl_val        IN VARCHAR2
 --  p_exp_item_level      IN VARCHAR2
 --  p_time_dim_lvl_cd     IN VARCHAR2
 --  p_time_lvl_val        IN VARCHAR2
 --  p_exp_time_level      IN VARCHAR2
 --  p_fact_code           IN VARCHAR2
 --  p_attribute1          IN VARCHAR2
 --  p_attribute2          IN VARCHAR2
 --  p_attribute3          IN VARCHAR2
 --  p_attribute4          IN VARCHAR2
 --  p_attribute5          IN VARCHAR2
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments

 PROCEDURE ddr_fact_aggr_prc(p_api_version      IN  NUMBER,
                             p_job_id           IN  NUMBER,
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
                             p_fact_code        IN  VARCHAR2,
                             p_attribute1       IN  VARCHAR2,
                             p_attribute2       IN  VARCHAR2,
                             p_attribute3       IN  VARCHAR2,
                             p_attribute4       IN  VARCHAR2,
                             p_attribute5       IN  VARCHAR2);

 -- Start of comments
 -- API name     : get_dsr_fact_details
 -- Type:  Public
 -- Pre-reqs: None.
 -- Function: to get detailed data from DSR facts
 -- Parameters:
 -- IN    :
 --  p_api_version       IN NUMBERRequired
 --  p_mfg_org_cd        IN VARCHAR2Required
 --       Manufaturer organization code
 --  p_org_dim_lvl_cd    IN VARCHAR2
 --       Identifies the organization hierarchy level code
 --  p_org_cd            IN VARCHAR2
 --       Organization hierarchy level code value
 --  p_loc_dim_lvl_cd    IN VARCHAR2
 --       Identifies the location hierarchy level code
 --  p_loc_cd            IN VARCHAR2
 --       Location hierarchy level code
 --  p_item_dim_lvl_cd   IN VARCHAR2
 --  p_item_cd           IN VARCHAR2
 --  p_time_dim_lvl_cd   IN VARCHAR2
 --  p_time_cd           IN VARCHAR2
 --  p_fact_code         IN VARCHAR2
 --  p_attribute1        IN VARCHAR2
 --  p_attribute2        IN VARCHAR2
 --  p_attribute3        IN VARCHAR2
 --  p_attribute4        IN VARCHAR2
 --  p_attribute5        IN VARCHAR2
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments

 PROCEDURE ddr_fact_details_prc(p_api_version     IN  NUMBER,
                                p_job_id          IN  NUMBER,
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
                                p_fact_code       IN  VARCHAR2,
                                p_attribute1      IN  VARCHAR2,
                                p_attribute2      IN  VARCHAR2,
                                p_attribute3      IN  VARCHAR2,
                                p_attribute4      IN  VARCHAR2,
                                p_attribute5      IN  VARCHAR2);

 -- Start of comments
 -- API name     : get_sys_var_val
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to wget the variable from system variable table
 -- Parameters:
 -- IN    :
 -- p_sys_var
 --       system variable name
 -- OUT      :
 -- x_sys_var_val
 --       system variable value
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments
 PROCEDURE get_sys_var_val(p_sys_var       IN  VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           x_sys_var_val   OUT NOCOPY VARCHAR2);

END;

/
