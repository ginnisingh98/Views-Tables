--------------------------------------------------------
--  DDL for Package Body CN_SFP_FORMULA_CMN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SFP_FORMULA_CMN_PKG" AS
  /*$Header: cnvfscmb.pls 115.19 2003/11/13 21:10:28 fmburu ship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30):='CN_SFP_FORMULA_CMN_PKG';


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
      ) IS

      l_formula_id    NUMBER;
      l_form_pkg_stmt VARCHAR2(1000);
      l_est_achievement NUMBER;

      l_formula_status VARCHAR2(30);
      l_estimated_payout NUMBER;
      l_return_status VARCHAR2(1);

      l_object_version_number NUMBER;
      l_org_id                NUMBER;

      l_api_name CONSTANT VARCHAR2(30) := 'get_payout_for_attain';

    BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT   get_payout_for_attain;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --  Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;



       -- Find the formula associated with the srp_quota_cate

       SELECT rqc.calc_formula_id
        INTO l_formula_id
        FROM cn_srp_quota_cates sqc,
             cn_role_quota_cates rqc
        WHERE sqc.role_quota_cate_id = rqc.role_quota_cate_id
        AND sqc.srp_quota_cate_id = p_srp_quota_cate_id
        ;

       IF l_formula_id IS NULL THEN
             IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                FND_MESSAGE.SET_NAME('CN', 'CN_FORMULA_NOT_ASSIGNED');
                FND_MSG_PUB.Add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
       END IF;

      SELECT formula_status, org_id
       INTO l_formula_status, l_org_id
        FROM cn_calc_formulas
        WHERE calc_formula_id = l_formula_id;

      IF l_formula_status <> 'COMPLETE' THEN
        IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
           FND_MESSAGE.SET_NAME('CN', 'CN_FORMULA_INCOMPLETE');
             FND_MSG_PUB.Add;
         END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_what_if_flag THEN -- What if scenario

      --- ISSUE: Currency convert

       SELECT
        DECODE(qc.quota_unit_code, 'REVENUE', ( ROUND(NVL(sqc.est_achievement,0)/NVL(pt.rounding_factor, 1))*NVL(pt.rounding_factor, 1)),
        'UNIT', (NVL(sqc.est_achievement,0)), ( ROUND(NVL(sqc.est_achievement,0)/NVL(pt.rounding_factor, 1))*NVL(pt.rounding_factor, 1)) ) , sqc.object_version_number
       INTO l_est_achievement, l_object_version_number
       FROM cn_srp_quota_cates sqc,
          cn_role_details_v pt,
          cn_quota_categories qc
       WHERE sqc.srp_quota_cate_id = p_srp_quota_cate_id
         AND  sqc.role_id = pt.role_id
         AND  sqc.quota_category_id = qc.quota_category_id
        ;
      ELSE
         l_est_achievement := p_est_achievement;
      END IF;


     l_form_pkg_stmt :=
         'BEGIN cn_formula_' || abs(l_formula_id) || '_' || abs(l_org_id) || '_pkg.get_estimated_payout'
         ||'(:p_srp_quota_cate_id, :p_est_achievement, :x_estimated_payout, :x_return_status) ; END ;'
       ;


      BEGIN

       EXECUTE IMMEDIATE l_form_pkg_stmt
        USING p_srp_quota_cate_id, l_est_achievement, IN OUT l_estimated_payout, IN OUT l_return_status;

      EXCEPTION
       WHEN OTHERS THEN
            IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                FND_MESSAGE.SET_NAME('CN', 'CN_FORMU_UNEXP_ERR');
                FND_MSG_PUB.Add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
      END;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = 'Z' THEN
       /*
             IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                FND_MESSAGE.SET_NAME('CN', 'CN_FORM_DIV_BY_ZERO');
                FND_MSG_PUB.Add;
             END IF;
          RAISE FND_API.G_EXC_ERROR;
       */
       -- Next line added after supressing divide by zero message
        l_estimated_payout := 0;

       END IF;

     x_return_status := l_return_status;
     x_estimated_payout := l_estimated_payout;

      -- Standard call to get message count and if count is 1, get message
      -- info.
     FND_MSG_PUB.Count_And_Get
        ( p_count                 =>      x_msg_count             ,
        p_data                   =>     x_msg_data              );


    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO get_payout_for_attain;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
           (p_count                 =>      x_msg_count             ,
           p_data                   =>      x_msg_data              );
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO get_payout_for_attain;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
           (p_count                 =>      x_msg_count             ,
           p_data                   =>      x_msg_data              );
       WHEN OTHERS THEN
         ROLLBACK TO get_payout_for_attain;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF      FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME          ,
              l_api_name           );
         END IF;
         FND_MSG_PUB.Count_And_Get
           (p_count                 =>      x_msg_count             ,
           p_data                  =>      x_msg_data               );

END;



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
      ) IS

      l_est_achievement NUMBER;
      l_api_name CONSTANT VARCHAR2(30) := 'get_payout_for_pct_attain';

 BEGIN

       -- Standard Start of API savepoint
       SAVEPOINT   get_payout_for_pct_attain;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --  Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       l_est_achievement := p_attain_percent/100*p_annual_quota;

         get_payout_for_attain
         (
           p_srp_quota_cate_id => p_srp_quota_cate_id,
           p_est_achievement => l_est_achievement,
           x_estimated_payout => x_estimated_payout,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data
         );

      -- Standard call to get message count and if count is 1, get message
      -- info.
     FND_MSG_PUB.Count_And_Get
        ( p_count                 =>      x_msg_count             ,
        p_data                   =>     x_msg_data              );

 EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO get_payout_for_pct_attain;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
           (p_count                 =>      x_msg_count             ,
           p_data                   =>      x_msg_data              );
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO get_payout_for_pct_attain;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
           (p_count                 =>      x_msg_count             ,
           p_data                   =>      x_msg_data              );
       WHEN OTHERS THEN
         ROLLBACK TO get_payout_for_pct_attain;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF      FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME          ,
              l_api_name           );
         END IF;
         FND_MSG_PUB.Count_And_Get
           (p_count                 =>      x_msg_count             ,
           p_data                  =>      x_msg_data               );


 END;



 PROCEDURE get_rates(
      p_srp_quota_cate_id    NUMBER ,
      p_split_flag          VARCHAR2 ,
      p_itd_flag              VARCHAR2,
      p_amount        IN      NUMBER,
      x_rate    OUT NOCOPY   NUMBER,
      x_rate_tier_id  OUT NOCOPY     NUMBER,
      x_tier_split    OUT NOCOPY     NUMBER) IS

--bug2731160: remove cn_rate_tiers use cn_role_quota_rates instead
    CURSOR c_rates_info IS
    SELECT rdt.maximum_amount,
        rdt.minimum_amount,
        sqr.comm_rate comm_rate,
        rd.dim_unit_code tier_unit_code
        FROM
        cn_rate_dim_tiers rdt,
        cn_rate_sch_dims rsd,
        cn_rate_dimensions rd,
        cn_srp_quota_rates sqr,
        cn_role_quota_rates rqr
        WHERE
        sqr.role_quota_rate_id = rqr.role_quota_rate_id
        AND rqr.rate_schedule_id = rsd.rate_schedule_id
        AND rsd.rate_dimension_id = rdt.rate_dimension_id
        AND rsd.rate_dimension_id = rd.rate_dimension_id
        AND sqr.rate_tier_id = rdt.tier_sequence
        AND sqr.srp_quota_cate_id = p_srp_quota_cate_id
        ORDER BY rdt.minimum_amount;

/*
    CURSOR c_rates_info IS
      SELECT rdt.maximum_amount,
        rdt.minimum_amount,
        sqr.comm_rate comm_rate,
        rd.dim_unit_code tier_unit_code
        FROM
       cn_rate_dim_tiers rdt,
        cn_rate_sch_dims rsd,
        cn_rate_tiers rt,
        cn_rate_dimensions rd,
        cn_srp_quota_rates sqr
        WHERE sqr.rate_tier_id = rt.rate_tier_id
        AND rt.rate_schedule_id = rsd.rate_schedule_id
        AND rsd.rate_dimension_id = rdt.rate_dimension_id
        AND rsd.rate_dimension_id = rd.rate_dimension_id
        AND rt.rate_sequence = rdt.tier_sequence
        AND sqr.srp_quota_cate_id = p_srp_quota_cate_id
        ORDER BY rdt.minimum_amount
       ;
*/

  i NUMBER;
  j NUMBER;
  l_rate NUMBER;
  l_rate_factor NUMBER;

  l_amount NUMBER;
  l_counter NUMBER;

  l_rates_info_tbl rates_info_tbl_type;

  l_max_exceeded BOOLEAN := FALSE ;
  l_max_rate  NUMBER ;
  l_max_tier_range NUMBER := 0 ;

  BEGIN

    l_amount := p_amount;

    i := 0;

    FOR rates_info_rec in c_rates_info LOOP
      i := i + 1;
      l_rates_info_tbl(i).comm_rate := rates_info_rec.comm_rate;
      l_rates_info_tbl(i).maximum_amount := rates_info_rec.maximum_amount;
      l_rates_info_tbl(i).minimum_amount := rates_info_rec.minimum_amount;


    END LOOP;

    IF i = 0 THEN
      null; --error
    END IF;

    IF l_amount < l_rates_info_tbl(1).minimum_amount THEN
        l_amount := l_rates_info_tbl(1).minimum_amount;
    ELSIF l_amount >= l_rates_info_tbl(i).maximum_amount THEN
        l_amount := l_rates_info_tbl(i).maximum_amount;
        l_max_exceeded := TRUE ;
        l_max_rate := l_rates_info_tbl(i).comm_rate;
        l_max_tier_range := l_rates_info_tbl(i).maximum_amount - l_rates_info_tbl(i).minimum_amount ;
    END IF;

    l_rate_factor := 0;
    FOR j IN l_rates_info_tbl.FIRST .. l_rates_info_tbl.LAST LOOP
        IF p_split_flag = 'N' THEN
          IF j = l_rates_info_tbl.LAST THEN
            IF l_amount >= l_rates_info_tbl(j).minimum_amount
              AND l_amount <= l_rates_info_tbl(j).maximum_amount THEN
               l_rate := l_rates_info_tbl(j).comm_rate;
              EXIT;
            END IF;
          ELSE
            IF l_amount >= l_rates_info_tbl(j).minimum_amount
              AND l_amount < l_rates_info_tbl(j).maximum_amount THEN
               l_rate := l_rates_info_tbl(j).comm_rate;
             EXIT;
            END IF;
          END IF;
        ELSIF p_split_flag = 'P' THEN
          IF l_amount >= l_rates_info_tbl(j).maximum_amount THEN
            l_rate_factor := l_rate_factor + l_rates_info_tbl(j).comm_rate;

          ELSE
            l_rate_factor := l_rate_factor + (l_amount - l_rates_info_tbl(j).minimum_amount)*l_rates_info_tbl(j).comm_rate
                                              / (l_rates_info_tbl(j).maximum_amount - l_rates_info_tbl(j).minimum_amount) ;
            EXIT;
          END IF;
        ELSIF p_split_flag = 'Y' THEN
          -- Added to fix bug when amount=0, BUG#3179883
          IF l_amount = 0 THEN
              l_rate_factor := l_rates_info_tbl(j).comm_rate ;
              EXIT ;
          ELSIF l_amount >= l_rates_info_tbl(j).maximum_amount THEN
            l_rate_factor := l_rate_factor + (l_rates_info_tbl(j).maximum_amount - l_rates_info_tbl(j).minimum_amount)
                                                   * l_rates_info_tbl(j).comm_rate;

          ELSE
            l_rate_factor := l_rate_factor + (l_amount - l_rates_info_tbl(j).minimum_amount)
                                                 *l_rates_info_tbl(j).comm_rate;
            EXIT;
          END IF;

        ELSE
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END LOOP;

    -- deal with the exceeding amount
    IF l_max_exceeded THEN
        IF p_split_flag = 'Y' THEN
            l_rate_factor := l_rate_factor + (p_amount - l_amount)*l_max_rate ;
            l_amount := p_amount ;
        ELSIF p_split_flag = 'P' THEN
            l_rate_factor := l_rate_factor + (p_amount - l_amount)*l_max_rate/l_max_tier_range ;
        END IF ;
    END IF ;

    -- return the rate required.
    IF p_split_flag = 'N' THEN
      x_rate := l_rate;
    ELSIF p_split_flag = 'Y' THEN
      IF l_amount = 0 THEN
          x_rate := l_rate_factor;
      ELSE
          x_rate := l_rate_factor/l_amount;
      END IF;
    ELSIF p_split_flag = 'P' THEN
       IF l_amount = 0 THEN
           x_rate := 0;
       ELSE
           x_rate := l_rate_factor;
       END IF;
    END IF;



  EXCEPTION WHEN OTHERS THEN
     cn_message_pkg.debug('Exception in get_rates ' || Sqlerrm);
     RAISE;

 END;

END CN_SFP_FORMULA_CMN_PKG;

/
