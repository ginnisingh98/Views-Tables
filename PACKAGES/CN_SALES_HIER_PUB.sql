--------------------------------------------------------
--  DDL for Package CN_SALES_HIER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SALES_HIER_PUB" AUTHID CURRENT_USER AS
-- $Header: cnphiers.pls 115.4 2002/11/21 21:04:03 hlchen ship $

      TYPE hier_type IS RECORD
	(
         name            VARCHAR2(240),
         number          VARCHAR2(30),
         role            VARCHAR2(30),
         start_date      DATE,
         end_date        DATE
         );

      TYPE hier_tbl_type IS TABLE OF  hier_type
	INDEX BY BINARY_INTEGER;


      TYPE grp_type IS RECORD
	(
         grp_name            VARCHAR2(30),
         grp_id              NUMBER,
         mgr_name            VARCHAR2(240),
         mgr_number          VARCHAR2(30)
         );

      TYPE grp_tbl_type IS TABLE OF  grp_type
	INDEX BY BINARY_INTEGER;


  -- API name 	: Get_sales_hier
  -- Type	: Public.
  -- Pre-reqs	:
  -- Usage	:
  --+
  -- Desc 	:  Get the transaction details
  --
  --
  --+
  -- Parameters	:
  --   IN       : p_salesrep_id           Salesrep Id             : NUMBER
  --   IN       : p_comp_group_id         The compensation group id      : NUMBER
  --   IN       : p_date                  The effective date             : DATE,
  --   IN       : p_start_record          For page scrolling, the first record :  NUMBER
  --   IN       : p_increment_count       The number of records per page :  NUMBER

  --   OUT      : x_sales_hier_tbl        The output table           : sales_hier_tbl_type
  --   OUT      : x_sales_hier_count      Total records in the query : NUMBER
  -- +
  -- +
  -- +
  --
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

  PROCEDURE get_sales_hier
    (
     p_api_version           IN  NUMBER,
     p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     x_loading_status         OUT NOCOPY VARCHAR2,

     p_salesrep_id           IN NUMBER ,
     p_comp_group_id         IN NUMBER,
     p_date                  IN DATE,
     p_start_record          IN  NUMBER := 1,
     p_increment_count       IN  NUMBER,
     p_start_record_grp          IN  NUMBER := 1,
     p_increment_count_grp       IN  NUMBER,

     x_mgr_tbl               OUT NOCOPY  hier_tbl_type,
     x_mgr_count             OUT NOCOPY NUMBER,
     x_srp_tbl               OUT NOCOPY  hier_tbl_type,
     x_srp_count             OUT NOCOPY NUMBER,
     x_grp_tbl               OUT NOCOPY  grp_tbl_type,
     x_grp_count             OUT NOCOPY NUMBER

    );

END cn_sales_hier_pub ;


 

/
