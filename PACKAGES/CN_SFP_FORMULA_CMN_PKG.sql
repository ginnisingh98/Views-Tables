--------------------------------------------------------
--  DDL for Package CN_SFP_FORMULA_CMN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SFP_FORMULA_CMN_PKG" AUTHID CURRENT_USER AS
  /*$Header: cnvfscms.pls 115.4 2002/11/21 21:13:23 hlchen ship $*/

 TYPE rates_info_rec_type IS RECORD
    (
     comm_rate    NUMBER,
     minimum_amount   NUMBER,
     maximum_amount   NUMBER
     );

 TYPE rates_info_tbl_type IS TABLE OF rates_info_rec_type INDEX BY BINARY_INTEGER;

 TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

 PROCEDURE get_payout_for_attain
    (
     p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE    ,
     p_validation_level              IN      NUMBER  :=
                  FND_API.G_VALID_LEVEL_FULL,
     p_srp_quota_cate_id IN NUMBER,
     p_est_achievement IN NUMBER,
     p_what_if_flag IN BOOLEAN := FALSE,
     x_estimated_payout OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count  OUT NOCOPY     NUMBER,
     x_msg_data   OUT NOCOPY     VARCHAR2
     );

 PROCEDURE get_payout_for_pct_attain
    (
     p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE    ,
     p_validation_level              IN      NUMBER  :=
                                             FND_API.G_VALID_LEVEL_FULL,
     p_srp_quota_cate_id IN NUMBER,
     p_attain_percent IN NUMBER,
     p_annual_quota IN NUMBER,
     p_what_if_flag IN BOOLEAN := FALSE,
     x_estimated_payout OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count  OUT NOCOPY     NUMBER,
     x_msg_data   OUT NOCOPY     VARCHAR2
    ) ;

  PROCEDURE get_rates
 (
    p_srp_quota_cate_id    NUMBER ,
    p_split_flag		    VARCHAR2 ,
    p_itd_flag              VARCHAR2,
    p_amount        IN     NUMBER,
    x_rate	 OUT NOCOPY 	NUMBER,
    x_rate_tier_id  OUT NOCOPY     NUMBER,
    x_tier_split    OUT NOCOPY     NUMBER
 );


END; -- Package spec

 

/
