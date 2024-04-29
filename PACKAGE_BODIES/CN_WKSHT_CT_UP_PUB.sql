--------------------------------------------------------
--  DDL for Package Body CN_WKSHT_CT_UP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_WKSHT_CT_UP_PUB" as
-- $Header: cnvwkcdb.pls 120.2 2006/02/13 15:24:08 fmburu noship $

--============================================================================
--Modified by Julia Huang for bug 2803102.
--This procedure is modified using refresh worksheet instead of
--doing 'delete worksheet' and 'create worksheet'.
--============================================================================
Procedure Create_delete_Wrkhst
   ( p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     p_validation_level    IN   NUMBER,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     p_salesrep_id         IN   NUMBER,
     p_srp_pmt_asgn_id     IN   NUMBER,
     p_payrun_id           IN   NUMBER,
     x_status             OUT NOCOPY  VARCHAR2,
     x_loading_status     OUT NOCOPY  VARCHAR2
     )  IS

   l_api_name         CONSTANT VARCHAR2(30)  := 'Create_delete_Wrkhst';
   l_api_version      CONSTANT NUMBER        := 1.0;

  --Bug 3670308 by Julia Huang on 6/4/04
  --Cartesian join is caused by the lack of relationship between cn_payruns and cn_pmt_plans where cn_payruns
  --and cn_pmt_plans are driving tables as determined by the CBO.
  CURSOR get_wksht IS
  /*
  SELECT  pw.payment_worksheet_id,
          pw.salesrep_id
    FROM  cn_payment_worksheets pw,
          cn_payruns p,
          cn_srp_pmt_plans_v ppa
   WHERE  ppa.salesrep_id =  p_salesrep_id
     and   ppa.srp_pmt_plan_id = p_srp_pmt_asgn_id
     and   p.payrun_id  = p_payrun_id
     and   p.pay_period_id = ppa.period_id
     and pw.salesrep_id = ppa.salesrep_id
     and pw.payrun_id   = p.payrun_id
     and pw.quota_id   IS NULL
     and p.status = 'UNPAID' ;
    */
    SELECT  pw.payment_worksheet_id,
            pw.salesrep_id
    FROM  cn_payment_worksheets pw, cn_payruns p, cn_period_statuses ps
   WHERE  pw.salesrep_id = p_salesrep_id
     AND p.payrun_id  = p_payrun_id
     AND p.org_id     = ps.org_id
     AND ps.period_id = p.pay_period_id
     AND pw.payrun_id   = p.payrun_id
     AND pw.quota_id  IS NULL
     AND p.status = 'UNPAID'
     AND EXISTS (SELECT 1 FROM cn_srp_pmt_plans ppa
                 WHERE ppa.srp_pmt_plan_id = p_srp_pmt_asgn_id
                 AND ppa.salesrep_id = pw.salesrep_id
                 AND ppa.start_date <= ps.end_date
                 AND Nvl(ppa.end_date,ps.end_date) >= ps.start_date);

   wksht_recs   get_wksht%ROWTYPE;
   wksht_recs1  CN_Payment_Worksheet_PVT.worksheet_rec_type;
   l_ovn  NUMBER ;
   G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_WKSHT_CT_UP_PUB';


 BEGIN
   --
   -- Standard Start of API savepoint
   --

   SAVEPOINT    Create_delete_Wrkhst;
   --
   -- Standard call to check for call compatibility.
   --

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                         p_api_version ,
                         l_api_name    ,
                         G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body

   OPEN get_wksht;
   LOOP
   FETCH get_wksht into  wksht_recs;
   exit when get_wksht%NOTFOUND;

   x_loading_status :=  'CN_REFRESHED';


   CN_Payment_Worksheet_PVT.Update_Worksheet
  (    p_api_version     =>  p_api_version,
       p_init_msg_list   => p_init_msg_list,
       p_commit          => p_commit,
       p_validation_level=> p_validation_level,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_worksheet_id    => wksht_recs.payment_worksheet_id,
       p_operation       => 'REFRESH',
       x_status          => x_status,
       x_loading_status  => x_loading_status,
       x_ovn   => l_ovn
       );


    IF x_return_status <> fnd_api.g_ret_sts_success
    THEN
        RAISE fnd_api.g_exc_error;
    END IF;

   END LOOP;
   close get_wksht;

     -- End of API body.


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;



   --
   -- Standard call to get message count and if count is 1, get message info.
   --

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_delete_Wrkhst;

      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_delete_Wrkhst;

      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data   ,
      p_encoded => FND_API.G_FALSE
      );
      WHEN OTHERS THEN


      ROLLBACK TO Create_delete_Wrkhst;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
END   Create_delete_Wrkhst ;

--============================================================================
--Modified by Julia Huang for bug 2803102.
--This procedure is modified using refresh worksheet instead of
--doing 'delete worksheet' and 'create worksheet'.
--============================================================================

Procedure Apply_payment_plan_upd
   ( p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     p_validation_level    IN   NUMBER,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     p_salesrep_id         IN   NUMBER,
     p_srp_pmt_asgn_id     IN   NUMBER,
     p_payrun_id           IN   NUMBER,
     p_old_srp_pmt_plans_rec IN  srp_pmt_plans_rec_type,
     p_srp_pmt_plans_rec  IN  srp_pmt_plans_rec_type,
     x_status             OUT NOCOPY  VARCHAR2,
     x_loading_status     OUT NOCOPY  VARCHAR2
     )  IS

   l_api_name         CONSTANT VARCHAR2(30)  := 'Apply_Payment_Plan_Upd';
   l_api_version      CONSTANT NUMBER        := 1.0;
   oldrec   CN_SRP_PMT_PLANS_PUB.srp_pmt_plans_rec_type;
   newrec   CN_SRP_PMT_PLANS_PUB.srp_pmt_plans_rec_type;

  --Bug 3670308 by Julia Huang on 6/4/04
  CURSOR get_wksht IS
    SELECT  pw.payment_worksheet_id,
            pw.salesrep_id,
            p.object_version_number
    FROM  cn_payment_worksheets pw, cn_payruns p, cn_period_statuses ps
   WHERE  pw.salesrep_id = p_salesrep_id
     AND p.payrun_id  = p_payrun_id
     AND ps.period_id = p.pay_period_id
     AND pw.payrun_id = p.payrun_id
     AND ps.org_id    = p.org_id
     AND pw.quota_id  IS NULL
     AND p.status = 'UNPAID'
     AND EXISTS (SELECT 1 FROM cn_srp_pmt_plans ppa
                 WHERE ppa.srp_pmt_plan_id = p_srp_pmt_asgn_id
                 AND ppa.salesrep_id = pw.salesrep_id
                 AND ppa.start_date <= ps.end_date
                 AND Nvl(ppa.end_date,ps.end_date) >= ps.start_date);

   wksht_recs   get_wksht%ROWTYPE;

   G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_WKSHT_CT_UP_PUB';

 BEGIN
   --
   -- Standard Start of API savepoint
   --

   SAVEPOINT   Apply_payment_plan_upd;
   --
   -- Standard call to check for call compatibility.
   --

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                         p_api_version ,
                         l_api_name    ,
                         G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body

     oldrec.salesrep_type  := p_old_srp_pmt_plans_rec.salesrep_type;
     oldrec.emp_num        := p_old_srp_pmt_plans_rec.emp_num;
     oldrec.pmt_plan_name  := p_old_srp_pmt_plans_rec.pmt_plan_name;
     oldrec.minimum_amount := p_old_srp_pmt_plans_rec.minimum_amount;
     oldrec.maximum_amount := p_old_srp_pmt_plans_rec.maximum_amount;
     oldrec.start_date     := p_old_srp_pmt_plans_rec.start_date;
     oldrec.end_date       := p_old_srp_pmt_plans_rec.end_date;

     newrec.salesrep_type  := p_srp_pmt_plans_rec.salesrep_type;
     newrec.emp_num        := p_srp_pmt_plans_rec.emp_num;
     newrec.pmt_plan_name  := p_srp_pmt_plans_rec.pmt_plan_name;
     newrec.minimum_amount := p_srp_pmt_plans_rec.minimum_amount;
     newrec.maximum_amount := p_srp_pmt_plans_rec.maximum_amount;
     newrec.start_date     := p_srp_pmt_plans_rec.start_date;
     newrec.end_date       := p_srp_pmt_plans_rec.end_date;

     x_loading_status := 'CN_UPDATED';

     CN_SRP_PMT_PLANS_PUB.Update_Srp_Pmt_Plan
     ( p_api_version     =>  p_api_version,
       p_init_msg_list   => p_init_msg_list,
       p_commit          => p_commit,
       p_validation_level=> p_validation_level,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_old_srp_pmt_plans_rec  =>  oldrec,
       p_srp_pmt_plans_rec  =>  newrec,
       x_loading_status  => x_loading_status );

      if x_loading_status <> 'CN_UPDATED' then
       RAISE fnd_api.g_exc_error;
      end if;

      OPEN get_wksht;
      LOOP
      FETCH get_wksht into  wksht_recs;
      exit when get_wksht%NOTFOUND;

      x_loading_status :=  'CN_REFRESHED';

      CN_Payment_Worksheet_PVT.Update_Worksheet
      (    p_api_version     =>  p_api_version,
       p_init_msg_list   => p_init_msg_list,
       p_commit          => p_commit,
       p_validation_level=> p_validation_level,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_worksheet_id    => wksht_recs.payment_worksheet_id,
       p_operation       => 'REFRESH',
       x_status          => x_status,
       x_loading_status  => x_loading_status,
       x_ovn             => wksht_recs.object_version_number
       );

    IF x_return_status <> fnd_api.g_ret_sts_success
    THEN
        RAISE fnd_api.g_exc_error;
    END IF;

     END LOOP;
     close get_wksht;

     -- End of API body.
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
     END IF;

   --
   -- Standard call to get message count and if count is 1, get message info.
   --

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Apply_payment_plan_upd;

      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Apply_payment_plan_upd;

      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data   ,
      p_encoded => FND_API.G_FALSE
      );
      WHEN OTHERS THEN


      ROLLBACK TO Apply_payment_plan_upd ;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
END  Apply_payment_plan_upd;

--============================================================================
Procedure Apply_payment_plan_del
   ( p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     p_validation_level    IN   NUMBER,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     p_salesrep_id         IN   NUMBER,
     p_srp_pmt_asgn_id     IN   NUMBER,
     p_payrun_id           IN   NUMBER,
     p_srp_pmt_plans_rec IN  srp_pmt_plans_rec_type,
     x_status             OUT NOCOPY  VARCHAR2,
     x_loading_status     OUT NOCOPY  VARCHAR2
     )  IS

   l_api_name         CONSTANT VARCHAR2(30)  := 'Apply_Payment_Plan_del';
   l_api_version      CONSTANT NUMBER        := 1.0;
   newrec   CN_SRP_PMT_PLANS_PUB.srp_pmt_plans_rec_type;

  --Bug 3670308 by Julia Huang on 6/4/04
  CURSOR get_wksht IS
    SELECT  pw.payment_worksheet_id,
            pw.salesrep_id,
            p.object_version_number
    FROM  cn_payment_worksheets pw, cn_payruns p, cn_period_statuses ps
   WHERE  pw.salesrep_id = p_salesrep_id
     AND p.payrun_id  = p_payrun_id
     AND ps.period_id = p.pay_period_id
     AND ps.org_id    = p.org_id
     AND pw.payrun_id   = p.payrun_id
     AND pw.quota_id  IS NULL
     AND p.status = 'UNPAID'
     AND EXISTS (SELECT 1 FROM cn_srp_pmt_plans ppa
                 WHERE ppa.srp_pmt_plan_id = p_srp_pmt_asgn_id
                 AND ppa.salesrep_id = pw.salesrep_id
                 AND ppa.start_date <= ps.end_date
                 AND Nvl(ppa.end_date,ps.end_date) >= ps.start_date);

   wksht_recs   get_wksht%ROWTYPE;
   wksht_recs1  CN_Payment_Worksheet_PVT.worksheet_rec_type;

   G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_WKSHT_CT_UP_PUB';

 BEGIN
   --
   -- Standard Start of API savepoint
   --

   SAVEPOINT   Apply_payment_plan_del;
   --
   -- Standard call to check for call compatibility.
   --

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                         p_api_version ,
                         l_api_name    ,
                         G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';

   --
   -- API body

   OPEN get_wksht;
   LOOP
   FETCH get_wksht into  wksht_recs;
   exit when get_wksht%NOTFOUND;

   x_loading_status :=  'CN_DELETED';

   CN_Payment_Worksheet_PVT.Delete_Worksheet
    (  p_api_version     =>  p_api_version,
       p_init_msg_list   => p_init_msg_list,
       p_commit          => p_commit,
       p_validation_level=> p_validation_level,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_worksheet_id    => wksht_recs.payment_worksheet_id,
       x_status          => x_status,
       x_loading_status  => x_loading_status,
       p_validation_only => 'N',
       p_ovn             => wksht_recs.object_version_number);

    if x_loading_status <> 'CN_DELETED' then
       RAISE fnd_api.g_exc_error;
    end if;

   END LOOP;
   close get_wksht;

    wksht_recs1.payrun_id           :=  p_payrun_id  ;
    wksht_recs1.salesrep_id         :=  p_salesrep_id  ;

    x_loading_status :=  'CN_DELETED';


            newrec.salesrep_type  := p_srp_pmt_plans_rec.salesrep_type;
            newrec.emp_num        := p_srp_pmt_plans_rec.emp_num;
            newrec.pmt_plan_name  := p_srp_pmt_plans_rec.pmt_plan_name;
            newrec.minimum_amount := p_srp_pmt_plans_rec.minimum_amount;
            newrec.maximum_amount := p_srp_pmt_plans_rec.maximum_amount;
            newrec.start_date     := p_srp_pmt_plans_rec.start_date;
            newrec.end_date       := p_srp_pmt_plans_rec.end_date;

     CN_SRP_PMT_PLANS_PUB.Delete_Srp_Pmt_Plan
     ( p_api_version     =>  p_api_version,
       p_init_msg_list   => p_init_msg_list,
       p_commit          => p_commit,
       p_validation_level=> p_validation_level,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_srp_pmt_plans_rec  =>  newrec,
       x_loading_status  => x_loading_status );

      if x_loading_status <> 'CN_DELETED' then
       RAISE fnd_api.g_exc_error;
      end if;

     x_loading_status :=  'CN_INSERTED';

     CN_Payment_Worksheet_PVT.Create_Worksheet
     ( p_api_version     =>  p_api_version,
       p_init_msg_list   => p_init_msg_list,
       p_commit          => p_commit,
       p_validation_level=> p_validation_level,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
      p_worksheet_rec    => wksht_recs1,
      x_loading_status   => x_loading_status,
      x_status           => x_status );

    if x_loading_status <> 'CN_INSERTED' then
       RAISE fnd_api.g_exc_error;
    end if;
     -- End of API body.


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;



   --
   -- Standard call to get message count and if count is 1, get message info.
   --

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Apply_payment_plan_del;

      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Apply_payment_plan_del;

      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data   ,
      p_encoded => FND_API.G_FALSE
      );
      WHEN OTHERS THEN


      ROLLBACK TO Apply_payment_plan_del ;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
END  Apply_payment_plan_del;

--============================================================================
Procedure Apply_payment_plan_cre
   ( p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     p_validation_level    IN   NUMBER,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     p_salesrep_id         IN   NUMBER,
     p_srp_pmt_asgn_id     IN   NUMBER,
     p_payrun_id           IN   NUMBER,
     p_srp_pmt_plans_rec IN  srp_pmt_plans_rec_type,
     x_status             OUT NOCOPY  VARCHAR2,
     x_loading_status     OUT NOCOPY  VARCHAR2
     )  IS

   l_api_name         CONSTANT VARCHAR2(30)  := 'Apply_Payment_Plan_del';
   l_api_version      CONSTANT NUMBER        := 1.0;
   newrec   CN_SRP_PMT_PLANS_PUB.srp_pmt_plans_rec_type;

  --Bug 3670308 by Julia Huang on 6/4/04
  CURSOR get_wksht IS
  /*
  SELECT  pw.payment_worksheet_id,
          pw.salesrep_id
    FROM  cn_payment_worksheets pw,
          cn_payruns p,
          cn_srp_pmt_plans_v ppa
   WHERE  ppa.salesrep_id =  p_salesrep_id
     and   ppa.srp_pmt_plan_id = p_srp_pmt_asgn_id
     and   p.payrun_id  = p_payrun_id
     and   p.pay_period_id = ppa.period_id
     and pw.salesrep_id = ppa.salesrep_id
     and pw.payrun_id   = p.payrun_id
     AND pw.quota_id is null
     and p.status = 'UNPAID' ;
     */
    SELECT  pw.payment_worksheet_id,
            pw.salesrep_id,
            p.object_version_number
    FROM  cn_payment_worksheets pw, cn_payruns p, cn_period_statuses ps
   WHERE  pw.salesrep_id = p_salesrep_id
     AND p.payrun_id  = p_payrun_id
     AND ps.period_id = p.pay_period_id
     AND ps.org_id    = p.org_id
     AND pw.payrun_id = p.payrun_id
     AND pw.quota_id  IS NULL
     AND p.status = 'UNPAID'
     AND EXISTS (SELECT 1 FROM cn_srp_pmt_plans ppa
                 WHERE ppa.srp_pmt_plan_id = p_srp_pmt_asgn_id
                 AND ppa.salesrep_id = pw.salesrep_id
                 AND ppa.start_date <= ps.end_date
                 AND Nvl(ppa.end_date,ps.end_date) >= ps.start_date);

   wksht_recs   get_wksht%ROWTYPE;
   wksht_recs1  CN_Payment_Worksheet_PVT.worksheet_rec_type;

   G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_WKSHT_CT_UP_PUB';

   l_srp_pmt_plan_id  NUMBER;

 BEGIN
   --
   -- Standard Start of API savepoint
   --

   SAVEPOINT   Apply_payment_plan_cre;
   --
   -- Standard call to check for call compatibility.
   --

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                         p_api_version ,
                         l_api_name    ,
                         G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';

   --
   -- API body

   OPEN get_wksht;
   LOOP
   FETCH get_wksht into  wksht_recs;
   exit when get_wksht%NOTFOUND;

   x_loading_status :=  'CN_DELETED';

   CN_Payment_Worksheet_PVT.Delete_Worksheet
    (  p_api_version     =>  p_api_version,
       p_init_msg_list   => p_init_msg_list,
       p_commit          => p_commit,
       p_validation_level=> p_validation_level,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_worksheet_id    => wksht_recs.payment_worksheet_id,
       x_status          => x_status,
       x_loading_status  => x_loading_status,
       p_validation_only => 'N',
       p_ovn             => wksht_recs.object_version_number);

    if x_loading_status <> 'CN_DELETED' then
       RAISE fnd_api.g_exc_error;
    end if;

   END LOOP;
   close get_wksht;

    wksht_recs1.payrun_id           :=  p_payrun_id  ;
    wksht_recs1.salesrep_id         :=  p_salesrep_id  ;

    x_loading_status :=  'CN_INSERTED';


            newrec.salesrep_type  := p_srp_pmt_plans_rec.salesrep_type;
            newrec.emp_num        := p_srp_pmt_plans_rec.emp_num;
            newrec.pmt_plan_name  := p_srp_pmt_plans_rec.pmt_plan_name;
            newrec.minimum_amount := p_srp_pmt_plans_rec.minimum_amount;
            newrec.maximum_amount := p_srp_pmt_plans_rec.maximum_amount;
            newrec.start_date     := p_srp_pmt_plans_rec.start_date;
            newrec.end_date       := p_srp_pmt_plans_rec.end_date;

     CN_SRP_PMT_PLANS_PUB.Create_Srp_Pmt_Plan
     ( p_api_version     =>  p_api_version,
       p_init_msg_list   => p_init_msg_list,
       p_commit          => p_commit,
       p_validation_level=> p_validation_level,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_srp_pmt_plans_rec  =>  newrec,
       x_srp_pmt_plan_id   => l_srp_pmt_plan_id,
       x_loading_status  => x_loading_status );

      if x_loading_status <> 'CN_INSERTED' then
       RAISE fnd_api.g_exc_error;
      end if;

     x_loading_status :=  'CN_INSERTED';

     CN_Payment_Worksheet_PVT.Create_Worksheet
     ( p_api_version     =>  p_api_version,
       p_init_msg_list   => p_init_msg_list,
       p_commit          => p_commit,
       p_validation_level=> p_validation_level,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
      p_worksheet_rec    => wksht_recs1,
      x_loading_status   => x_loading_status,
      x_status           => x_status );

    if x_loading_status <> 'CN_INSERTED' then
       RAISE fnd_api.g_exc_error;
    end if;
     -- End of API body.


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;



   --
   -- Standard call to get message count and if count is 1, get message info.
   --

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Apply_payment_plan_cre;

      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Apply_payment_plan_cre;

      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data   ,
      p_encoded => FND_API.G_FALSE
      );
      WHEN OTHERS THEN


      ROLLBACK TO Apply_payment_plan_cre ;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
END  Apply_payment_plan_cre;

END CN_WKSHT_CT_UP_PUB;

/
