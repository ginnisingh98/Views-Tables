--------------------------------------------------------
--  DDL for Package Body DDR_FACT_WEBSERVICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DDR_FACT_WEBSERVICES_PUB" AS
/* $Header: ddrpfwsb.pls 120.4 2008/03/18 05:50:19 vkohli noship $ */

   -- Start of comments
   --    API name     : invoke_aggr_prc
   --    Type     :  Public
   --    Pre-reqs : None.
   --    Function : to invoke the procedure to write the data to xml file
   --    Parameters  :
   --    IN        :p_api_version            IN NUMBER   Required
   --              p_mfg_org_cd              IN VARCHAR2 Required
   --                   Manufaturer organization code
   --               p_org_dim_lvl_cd         IN VARCHAR2
   --                   Identifies the organization hierarchy level code
   --              p_org_cd                  IN VARCHAR2
   --                    Organization hierarchy level code value
   --              p_loc_dim_lvl_cd          IN VARCHAR2
   --                   Identifies the location hierarchy level code
   --              p_loc_cd                  IN VARCHAR2
   --                   Location hierarchy level code
   --              p_item_dim_lvl_cd         IN VARCHAR2
   --              p_item_cd                 IN VARCHAR2
   --              p_time_dim_lvl_cd         IN VARCHAR2
   --              p_time_cd                 IN VARCHAR2
   --              p_fact_code               IN VARCHAR2
   --              p_attribute1              IN VARCHAR2
   --              p_attribute2              IN VARCHAR2
   --              p_attribute3              IN VARCHAR2
   --              p_attribute4              IN VARCHAR2
   --              p_attribute5              IN VARCHAR2
   --  OUT         x_job_id              OUT NOCOPY  VARCHAR2
   --    Version  : Current version 1.0
   --            Initial version    1.0
   -- End of comments
   PROCEDURE invoke_aggr_prc (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_exp_org_level     IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_exp_loc_level     IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_exp_item_level    IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_exp_time_level    IN              VARCHAR2,
      p_fact_code         IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   );

   PROCEDURE invoke_detail_prc (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_fact_code         IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   );

   FUNCTION get_ddr_ws_job_id_seq_nextval
      RETURN NUMBER;

   PROCEDURE getAgrSalesReturnItem (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_exp_org_level     IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_exp_loc_level     IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_exp_item_level    IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_exp_time_level    IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_aggr_prc (p_api_version,
                       p_mfg_org_cd,
                       p_org_cd,
                       p_org_dim_lvl_cd,
                       p_org_lvl_val,
                       p_exp_org_level,
                       p_loc_dim_lvl_cd,
                       p_loc_lvl_val,
                       p_exp_loc_level,
                       p_item_dim_lvl_cd,
                       p_item_lvl_val,
                       p_exp_item_level,
                       p_time_dim_lvl_cd,
                       p_time_lvl_val,
                       p_exp_time_level,
                       ddr_webservices_constants.g_rsrid_cd,
                       p_attribute1,
                       p_attribute2,
                       p_attribute3,
                       p_attribute4,
                       p_attribute5,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       x_job_id
                      );
   END getAgrSalesReturnItem;


   PROCEDURE getAgrMrktItemSales (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_exp_org_level     IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_exp_loc_level     IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_exp_item_level    IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_exp_time_level    IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_aggr_prc (p_api_version,
                       p_mfg_org_cd,
                       p_org_cd,
                       p_org_dim_lvl_cd,
                       p_org_lvl_val,
                       p_exp_org_level,
                       p_loc_dim_lvl_cd,
                       p_loc_lvl_val,
                       p_exp_loc_level,
                       p_item_dim_lvl_cd,
                       p_item_lvl_val,
                       p_exp_item_level,
                       p_time_dim_lvl_cd,
                       p_time_lvl_val,
                       p_exp_time_level,
                       ddr_webservices_constants.g_misd_cd,
                       p_attribute1,
                       p_attribute2,
                       p_attribute3,
                       p_attribute4,
                       p_attribute5,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       x_job_id
                      );
   END getAgrMrktItemSales;


   PROCEDURE getAgrPrmtinPlan (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_exp_org_level     IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_exp_loc_level     IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_exp_item_level    IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_exp_time_level    IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_aggr_prc (p_api_version,
                       p_mfg_org_cd,
                       p_org_cd,
                       p_org_dim_lvl_cd,
                       p_org_lvl_val,
                       p_exp_org_level,
                       p_loc_dim_lvl_cd,
                       p_loc_lvl_val,
                       p_exp_loc_level,
                       p_item_dim_lvl_cd,
                       p_item_lvl_val,
                       p_exp_item_level,
                       p_time_dim_lvl_cd,
                       p_time_lvl_val,
                       p_exp_time_level,
                       ddr_webservices_constants.g_pp_cd,
                       p_attribute1,
                       p_attribute2,
                       p_attribute3,
                       p_attribute4,
                       p_attribute5,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       x_job_id
                      );
   END getAgrPrmtinPlan;

   PROCEDURE getAgrRtlInvItmDat (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_exp_org_level     IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_exp_loc_level     IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_exp_item_level    IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_exp_time_level    IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_aggr_prc (p_api_version,
                       p_mfg_org_cd,
                       p_org_cd,
                       p_org_dim_lvl_cd,
                       p_org_lvl_val,
                       p_exp_org_level,
                       p_loc_dim_lvl_cd,
                       p_loc_lvl_val,
                       p_exp_loc_level,
                       p_item_dim_lvl_cd,
                       p_item_lvl_val,
                       p_exp_item_level,
                       p_time_dim_lvl_cd,
                       p_time_lvl_val,
                       p_exp_time_level,
                       ddr_webservices_constants.g_riid_cd,
                       p_attribute1,
                       p_attribute2,
                       p_attribute3,
                       p_attribute4,
                       p_attribute5,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       x_job_id
                      );
   END getAgrRtlInvItmDat;


   PROCEDURE getAgrRetailerOrderItm (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_exp_org_level     IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_exp_loc_level     IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_exp_item_level    IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_exp_time_level    IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_aggr_prc (p_api_version,
                       p_mfg_org_cd,
                       p_org_cd,
                       p_org_dim_lvl_cd,
                       p_org_lvl_val,
                       p_exp_org_level,
                       p_loc_dim_lvl_cd,
                       p_loc_lvl_val,
                       p_exp_loc_level,
                       p_item_dim_lvl_cd,
                       p_item_lvl_val,
                       p_exp_item_level,
                       p_time_dim_lvl_cd,
                       p_time_lvl_val,
                       p_exp_time_level,
                       ddr_webservices_constants.g_roid_cd,
                       p_attribute1,
                       p_attribute2,
                       p_attribute3,
                       p_attribute4,
                       p_attribute5,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       x_job_id
                      );
   END getAgrRetailerOrderItm;

   PROCEDURE getAgrSaleFrecastItm (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_exp_org_level     IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_exp_loc_level     IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_exp_item_level    IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_exp_time_level    IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_aggr_prc (p_api_version,
                       p_mfg_org_cd,
                       p_org_cd,
                       p_org_dim_lvl_cd,
                       p_org_lvl_val,
                       p_exp_org_level,
                       p_loc_dim_lvl_cd,
                       p_loc_lvl_val,
                       p_exp_loc_level,
                       p_item_dim_lvl_cd,
                       p_item_lvl_val,
                       p_exp_item_level,
                       p_time_dim_lvl_cd,
                       p_time_lvl_val,
                       p_exp_time_level,
                       ddr_webservices_constants.g_sfid_cd,
                       p_attribute1,
                       p_attribute2,
                       p_attribute3,
                       p_attribute4,
                       p_attribute5,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       x_job_id
                      );
   END getAgrSaleFrecastItm;

   PROCEDURE getAgrRetailerShipItem (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_exp_org_level     IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_exp_loc_level     IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_exp_item_level    IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_exp_time_level    IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_aggr_prc (p_api_version,
                       p_mfg_org_cd,
                       p_org_cd,
                       p_org_dim_lvl_cd,
                       p_org_lvl_val,
                       p_exp_org_level,
                       p_loc_dim_lvl_cd,
                       p_loc_lvl_val,
                       p_exp_loc_level,
                       p_item_dim_lvl_cd,
                       p_item_lvl_val,
                       p_exp_item_level,
                       p_time_dim_lvl_cd,
                       p_time_lvl_val,
                       p_exp_time_level,
                       ddr_webservices_constants.g_rsid_cd,
                       p_attribute1,
                       p_attribute2,
                       p_attribute3,
                       p_attribute4,
                       p_attribute5,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       x_job_id
                      );
   END getAgrRetailerShipItem;

   PROCEDURE getSalesReturnItem (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      --    DBMS_OUT NOCOPY PUT.put_line (' Inside getSalesReturnItem');
      invoke_detail_prc (p_api_version,
                         p_mfg_org_cd,
                         p_org_cd,
                         p_org_dim_lvl_cd,
                         p_org_lvl_val,
                         p_loc_dim_lvl_cd,
                         p_loc_lvl_val,
                         p_item_dim_lvl_cd,
                         p_item_lvl_val,
                         p_time_dim_lvl_cd,
                         p_time_lvl_val,
                         ddr_webservices_constants.g_rsrid_cd,
                         p_attribute1,
                         p_attribute2,
                         p_attribute3,
                         p_attribute4,
                         p_attribute5,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         x_job_id
                        );
--                DBMS_OUT NOCOPY PUT.put_line (' x_return_status ' || x_return_status);
--                   x_return_status := x_return_status;
--                          x_msg_count := x_msg_count;
--                          x_msg_data := x_msg_data ;
   END getSalesReturnItem;

   PROCEDURE getMrktItemSales (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_detail_prc (p_api_version,
                         p_mfg_org_cd,
                         p_org_cd,
                         p_org_dim_lvl_cd,
                         p_org_lvl_val,
                         p_loc_dim_lvl_cd,
                         p_loc_lvl_val,
                         p_item_dim_lvl_cd,
                         p_item_lvl_val,
                         p_time_dim_lvl_cd,
                         p_time_lvl_val,
                         ddr_webservices_constants.g_misd_cd,
                         p_attribute1,
                         p_attribute2,
                         p_attribute3,
                         p_attribute4,
                         p_attribute5,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         x_job_id
                        );
   END getMrktItemSales;

   PROCEDURE getPrmtinPlan (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_detail_prc (p_api_version,
                         p_mfg_org_cd,
                         p_org_cd,
                         p_org_dim_lvl_cd,
                         p_org_lvl_val,
                         p_loc_dim_lvl_cd,
                         p_loc_lvl_val,
                         p_item_dim_lvl_cd,
                         p_item_lvl_val,
                         p_time_dim_lvl_cd,
                         p_time_lvl_val,
                         ddr_webservices_constants.g_pp_cd,
                         p_attribute1,
                         p_attribute2,
                         p_attribute3,
                         p_attribute4,
                         p_attribute5,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         x_job_id
                        );
   END getPrmtinPlan;

   PROCEDURE getRtlInvItmDat (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_detail_prc (p_api_version,
                         p_mfg_org_cd,
                         p_org_cd,
                         p_org_dim_lvl_cd,
                         p_org_lvl_val,
                         p_loc_dim_lvl_cd,
                         p_loc_lvl_val,
                         p_item_dim_lvl_cd,
                         p_item_lvl_val,
                         p_time_dim_lvl_cd,
                         p_time_lvl_val,
                         ddr_webservices_constants.g_riid_cd,
                         p_attribute1,
                         p_attribute2,
                         p_attribute3,
                         p_attribute4,
                         p_attribute5,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         x_job_id
                        );
   END getRtlInvItmDat;

   PROCEDURE getRetailerOrderItm (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_detail_prc (p_api_version,
                         p_mfg_org_cd,
                         p_org_cd,
                         p_org_dim_lvl_cd,
                         p_org_lvl_val,
                         p_loc_dim_lvl_cd,
                         p_loc_lvl_val,
                         p_item_dim_lvl_cd,
                         p_item_lvl_val,
                         p_time_dim_lvl_cd,
                         p_time_lvl_val,
                         ddr_webservices_constants.g_roid_cd,
                         p_attribute1,
                         p_attribute2,
                         p_attribute3,
                         p_attribute4,
                         p_attribute5,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         x_job_id
                        );
   END getRetailerOrderItm;

   PROCEDURE getSaleFrecastItm (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_detail_prc (p_api_version,
                         p_mfg_org_cd,
                         p_org_cd,
                         p_org_dim_lvl_cd,
                         p_org_lvl_val,
                         p_loc_dim_lvl_cd,
                         p_loc_lvl_val,
                         p_item_dim_lvl_cd,
                         p_item_lvl_val,
                         p_time_dim_lvl_cd,
                         p_time_lvl_val,
                         ddr_webservices_constants.g_sfid_cd,
                         p_attribute1,
                         p_attribute2,
                         p_attribute3,
                         p_attribute4,
                         p_attribute5,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         x_job_id
                        );
   END getSaleFrecastItm;

   PROCEDURE getRetailerShipItem (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   AS
   BEGIN
      invoke_detail_prc (p_api_version,
                         p_mfg_org_cd,
                         p_org_cd,
                         p_org_dim_lvl_cd,
                         p_org_lvl_val,
                         p_loc_dim_lvl_cd,
                         p_loc_lvl_val,
                         p_item_dim_lvl_cd,
                         p_item_lvl_val,
                         p_time_dim_lvl_cd,
                         p_time_lvl_val,
                         ddr_webservices_constants.g_rsid_cd,
                         p_attribute1,
                         p_attribute2,
                         p_attribute3,
                         p_attribute4,
                         p_attribute5,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         x_job_id
                        );
   END getRetailerShipItem;

   PROCEDURE invoke_aggr_prc (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_exp_org_level     IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_exp_loc_level     IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_exp_item_level    IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_exp_time_level    IN              VARCHAR2,
      p_fact_code         IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   IS
      l_job_id     NUMBER          := NULL;
      l_proc_str   VARCHAR2 (1000) := NULL;
   BEGIN

      --get the job id from sequence
  l_job_id := get_ddr_ws_job_id_seq_nextval;

  INSERT INTO ddr_ws_job(job_id, status, SRC_SYS_IDNT,SRC_SYS_DT, CRTD_BY_DSR, LAST_UPDT_BY_DSR, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,   LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
  VALUES (l_job_id, ddr_webservices_constants.g_ret_sts_initialize,'-1', sysdate, '-1', '-1', -1,sysdate, -1, sysdate,-1);


  --triggere the DBMS_SCHEDULER to run the job which writes data to xml file
  l_proc_str := 'BEGIN ddr_webservices_pub.ddr_fact_aggr_prc(';
  l_proc_str := l_proc_str || p_api_version || ', ';
  l_proc_str := l_proc_str || '''' || l_job_id || ''', ';
  l_proc_str := l_proc_str || '''' || p_mfg_org_cd || ''', ';
  l_proc_str := l_proc_str || '''' || p_org_cd || ''', ';
  l_proc_str := l_proc_str || '''' || p_org_dim_lvl_cd || ''', ';
  l_proc_str := l_proc_str || '''' || p_org_lvl_val || ''', ';
  l_proc_str := l_proc_str || '''' || p_exp_org_level || ''', ';
  l_proc_str := l_proc_str || '''' || p_loc_dim_lvl_cd || ''', ';
  l_proc_str := l_proc_str || '''' || p_loc_lvl_val || ''', ';
  l_proc_str := l_proc_str || '''' || p_exp_loc_level || ''', ';
  l_proc_str := l_proc_str || '''' || p_item_dim_lvl_cd || ''', ';
  l_proc_str := l_proc_str || '''' || p_item_lvl_val || ''', ';
  l_proc_str := l_proc_str || '''' || p_exp_item_level || ''', ';
  l_proc_str := l_proc_str || '''' || p_time_dim_lvl_cd || ''', ';
  l_proc_str := l_proc_str || '''' || p_time_lvl_val || ''', ';
  l_proc_str := l_proc_str || '''' || p_exp_time_level || ''', ';
  l_proc_str := l_proc_str || '''' || p_fact_code || ''', ';
  l_proc_str := l_proc_str || '''' || p_attribute1 || ''', ';
  l_proc_str := l_proc_str || '''' || p_attribute2 || ''', ';
  l_proc_str := l_proc_str || '''' || p_attribute3 || ''', ';
  l_proc_str := l_proc_str || '''' || p_attribute4 || ''', ';
  l_proc_str := l_proc_str || '''' || p_attribute5 || ''' ); END;';


  dbms_scheduler.create_job (job_name =>    'DDR_AGGR_WS_JOB_' || l_job_id,
                                 job_type             => 'PLSQL_BLOCK',
                                 job_action           => l_proc_str,
                                 start_date           => NULL,
                                 repeat_interval      => NULL,
                                 auto_drop            => TRUE,
                                 enabled              => TRUE);
  x_job_id := TO_CHAR (l_job_id);
  EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_return_status := ddr_webservices_constants.g_ret_sts_error;
            x_msg_count := 1;
            x_msg_data := 'NO DATA FOUND'||sqlcode||' Error message:'||sqlerrm;
         WHEN OTHERS THEN
            x_return_status := ddr_webservices_constants.g_ret_sts_unexp_error;
            x_msg_count := 1;
            x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
   END invoke_aggr_prc;

   PROCEDURE invoke_detail_prc (
      p_api_version       IN              NUMBER,
      p_mfg_org_cd        IN              VARCHAR2,
      p_org_cd            IN              VARCHAR2,
      p_org_dim_lvl_cd    IN              VARCHAR2,
      p_org_lvl_val       IN              VARCHAR2,
      p_loc_dim_lvl_cd    IN              VARCHAR2,
      p_loc_lvl_val       IN              VARCHAR2,
      p_item_dim_lvl_cd   IN              VARCHAR2,
      p_item_lvl_val      IN              VARCHAR2,
      p_time_dim_lvl_cd   IN              VARCHAR2,
      p_time_lvl_val      IN              VARCHAR2,
      p_fact_code         IN              VARCHAR2,
      p_attribute1        IN              VARCHAR2,
      p_attribute2        IN              VARCHAR2,
      p_attribute3        IN              VARCHAR2,
      p_attribute4        IN              VARCHAR2,
      p_attribute5        IN              VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_job_id            OUT NOCOPY      VARCHAR2
   )
   IS
      l_job_id     NUMBER          := NULL;
      l_proc_str   VARCHAR2 (32767) := NULL;
   BEGIN
      l_job_id := get_ddr_ws_job_id_seq_nextval;

   INSERT INTO ddr_ws_job(job_id, status, SRC_SYS_IDNT,SRC_SYS_DT, CRTD_BY_DSR, LAST_UPDT_BY_DSR, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,     LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
   VALUES (l_job_id, ddr_webservices_constants.g_ret_sts_initialize,'-1', sysdate, '-1', '-1', -1,sysdate, -1, sysdate,-1);

      --triggere the DBMS_SCHEDULER to run the job which writes data to xml file
      l_proc_str := 'BEGIN ddr_webservices_pub.ddr_fact_details_prc (';
      l_proc_str := l_proc_str || p_api_version|| ', ';
      l_proc_str := l_proc_str || '''' || l_job_id || ''', ';
      l_proc_str := l_proc_str || '''' || p_mfg_org_cd || ''', ';
      l_proc_str := l_proc_str || '''' || p_org_cd || ''', ';
      l_proc_str := l_proc_str || '''' || p_org_dim_lvl_cd || ''', ';
      l_proc_str := l_proc_str || '''' || p_org_lvl_val || ''', ';
      l_proc_str := l_proc_str || '''' || p_loc_dim_lvl_cd || ''', ';
      l_proc_str := l_proc_str || '''' || p_loc_lvl_val || ''', ';
      l_proc_str := l_proc_str || '''' || p_item_dim_lvl_cd || ''', ';
      l_proc_str := l_proc_str || '''' || p_item_lvl_val || ''', ';
      l_proc_str := l_proc_str || '''' || p_time_dim_lvl_cd || ''', ';
      l_proc_str := l_proc_str || '''' || p_time_lvl_val || ''', ';
      l_proc_str := l_proc_str || '''' || p_fact_code || ''', ';
      l_proc_str := l_proc_str || '''' || p_attribute1 || ''', ';
      l_proc_str := l_proc_str || '''' || p_attribute2 || ''', ';
      l_proc_str := l_proc_str || '''' || p_attribute3 || ''', ';
      l_proc_str := l_proc_str || '''' || p_attribute4 || ''', ';
      l_proc_str := l_proc_str || '''' || p_attribute5 || ''' ); END;';


  dbms_scheduler.create_job (job_name =>    'DDR_DETAIL_WS_JOB_' || l_job_id,
                                 job_type             => 'PLSQL_BLOCK',
                                 job_action           => l_proc_str,
                                 start_date           => NULL,
                                 repeat_interval      => NULL,
                                 auto_drop            => TRUE,
                                 enabled              => TRUE);
  x_job_id := TO_CHAR (l_job_id);
  EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_return_status := ddr_webservices_constants.g_ret_sts_error;
            x_msg_count := 1;
            x_msg_data := 'NO DATA FOUND'||sqlcode||' Error message:'||sqlerrm;
         WHEN OTHERS THEN
            x_return_status := ddr_webservices_constants.g_ret_sts_unexp_error;
            x_msg_count := 1;
            x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
   END invoke_detail_prc;

   FUNCTION get_ddr_ws_job_id_seq_nextval
      RETURN NUMBER
   IS
      l_next_val   NUMBER := NULL;
   BEGIN
      SELECT ddr_ws_job_seq.NEXTVAL
        INTO l_next_val
        FROM DUAL;

      RETURN l_next_val;
   END get_ddr_ws_job_id_seq_nextval;

   PROCEDURE getFileName (
      p_api_version     IN              NUMBER,
      x_job_id          IN              VARCHAR2,
      p_mfg_org_cd      IN              VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_file_path       OUT NOCOPY      VARCHAR2
   )
   IS
      l_file_path     VARCHAR2 (32767)        := NULL;
      l_job_status    VARCHAR2 (10)           := NULL;
      l_job_error     VARCHAR2 (100)          := NULL;
      l_dir_path      VARCHAR2 (250)          := NULL;
      --Bug 6880404 change start
      l_xml_file_path VARCHAR2 (250)          := NULL;
      --Bug 6880404 change end
      l_dir_name      VARCHAR2 (250)          := NULL;
      l_api_ver EXCEPTION;
      l_job_id EXCEPTION;
      l_mfg_code_null  EXCEPTION;
      CURSOR file_name_cur (job_id_in NUMBER) IS
         SELECT file_name FROM ddr_ws_job_file_dls WHERE job_id = job_id_in;
      file_name_rec   file_name_cur%ROWTYPE;
   BEGIN
         IF p_api_version IS NULL THEN
             RAISE l_api_ver;
         END IF;
         IF x_job_id IS NULL THEN
             RAISE l_job_id;
         END IF;
         IF p_mfg_org_cd IS NULL THEN
             RAISE l_mfg_code_null;
         END IF;
         SELECT status,ERR_MESSAGE INTO l_job_status,l_job_error FROM ddr_ws_job WHERE job_id = x_job_id;
         IF l_job_status = ddr_webservices_constants.g_ret_sts_error THEN
            x_return_status := ddr_webservices_constants.g_ret_sts_error;
            x_msg_count := 1;
            x_msg_data := l_job_error;
            x_file_path:=l_job_error;
         ELSIF l_job_status = ddr_webservices_constants.g_ret_sts_unexp_error THEN
            x_return_status := ddr_webservices_constants.g_ret_sts_unexp_error;
            x_msg_count := 1;
            x_msg_data := l_job_error;
            x_file_path:=l_job_error;
        ELSIF l_job_status = ddr_webservices_constants.g_ret_sts_initialize THEN
            x_return_status := ddr_webservices_constants.g_ret_sts_initialize;
            x_msg_count := 1;
            x_msg_data := l_job_error;
            x_file_path:='Initialized';
        ELSIF l_job_status = ddr_webservices_constants.g_ret_sts_running THEN
            x_return_status := ddr_webservices_constants.g_ret_sts_running;
            x_msg_count := 1;
            x_msg_data := l_job_error;
            x_file_path:='Running';
        ELSIF l_job_status = ddr_webservices_constants.g_ret_sts_success THEN
        --get the path to the directory where xml files are stored
        --Bug 6880404 change start
        ddr_webservices_pub.get_sys_var_val('DDR_WS_FILE_PATH',x_return_status, x_msg_count,x_msg_data,l_xml_file_path);
        --Bug 6880404 change start
        --get logical directory name from system variable table
        --ddr_webservices_pub.get_sys_var_val('OUTPUT_DIR_PATH',x_return_status, x_msg_count,x_msg_data,l_dir_name);
        --l_dir_path := l_db_ip_address || '\'||l_dir_name||'\';
        l_dir_path := l_xml_file_path;
        OPEN file_name_cur (x_job_id);

           LOOP
              FETCH file_name_cur INTO file_name_rec;

              EXIT WHEN file_name_cur%NOTFOUND;
              --l_file_path := l_file_path || '<FILE_PATH>'||l_dir_path||file_name_rec.file_name||'</FILE_PATH>'||chr(10);
              -- use of chr function is not allowed by GSCC. The following code uses newline inserted in the string edit
              l_file_path := l_file_path || '<FILE_PATH>'||l_dir_path||file_name_rec.file_name||'</FILE_PATH>'||'
'||NULL;
           END LOOP;
           x_file_path := l_file_path;
           CLOSE file_name_cur;
           x_return_status:=ddr_webservices_constants.g_ret_sts_success;
           x_msg_count:=null;
           x_msg_data:=null;
       END IF;
     EXCEPTION
       WHEN l_api_ver THEN
         x_return_status:=ddr_webservices_constants.g_ret_sts_error;
         x_msg_count:=1;
         x_msg_data:='API version number should not be null';
       WHEN l_job_id THEN
         x_return_status:=ddr_webservices_constants.g_ret_sts_error;
         x_msg_count:=1;
         x_msg_data:='Job id should not be null';
       WHEN l_mfg_code_null THEN
         x_return_status:=ddr_webservices_constants.g_ret_sts_error;
         x_msg_count:=1;
         x_msg_data:='Manufacturer Organization code should not be null';
       WHEN NO_DATA_FOUND THEN
         x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
         x_msg_count:=1;
         x_msg_data:='No Data Found. Error code:'||sqlcode||' Error message:'||sqlerrm;
       WHEN OTHERS THEN
         x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
         x_msg_count:=1;
         x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
   END getFileName;
END;

/
