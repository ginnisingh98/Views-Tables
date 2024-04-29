--------------------------------------------------------
--  DDL for Package Body CN_PAY_GROUP_DTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAY_GROUP_DTLS_PVT" AS
  /*$Header: cnvpgdtb.pls 115.7 2003/09/15 12:01:06 bpradhan ship $*/

G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_PAY_GROUP_DTLS_PVT';



PROCEDURE Get_Pay_Group_Dtls
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_pay_group_id                IN      NUMBER,
   x_pay_group_dtls              OUT NOCOPY     pay_group_dtls_tbl_type,
   x_total_record                OUT NOCOPY     NUMBER,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2
 ) IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Get_Pay_Group_Dtls';
     l_api_version        CONSTANT NUMBER       := 1.0;

     l_counter      NUMBER;

     CURSOR l_pay_group_dtls_cr IS
        select cpg.pay_group_id, cpg.name,  cs.period_set_name, cpg.period_type, cps.period_name, cps.period_year, cps.quarter_num, cps.start_date, cps.end_date
        from cn_pay_groups cpg, cn_period_statuses cps, cn_period_sets cs
        where (cpg.period_set_id = cps.period_set_id) and
              (cpg.period_type_id = cps.period_type_id) and
              (cpg.start_date <= cps.start_date) and
              ( nvl(cpg.end_date, cps.end_date) >= cps.end_date) and
              (cpg.period_set_id = cs.period_set_id) and
              (cpg.pay_group_id = p_pay_group_id) order by cps.period_id;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Pay_Group_Dtls;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

--   x_pay_group_dtls := G_MISS_PAY_GROUP_DTLS_REC_TB ;

   l_counter := 0;
   x_total_record := 0;

   FOR l_pay_group_dtls IN l_pay_group_dtls_cr LOOP

      x_total_record := x_total_record +1;
      IF (p_fetch_size = -1) OR (x_total_record >= p_start_record
	AND x_total_record <= (p_start_record + p_fetch_size - 1)) THEN
	 -- assign values of the row to x_srp_list






         x_pay_group_dtls(l_counter).pay_group_id := l_pay_group_dtls.pay_group_id;


         x_pay_group_dtls(l_counter).name := l_pay_group_dtls.name;

         x_pay_group_dtls(l_counter).period_set_name := l_pay_group_dtls.period_set_name;

         x_pay_group_dtls(l_counter).period_type := l_pay_group_dtls.period_type;

         x_pay_group_dtls(l_counter).period_name := l_pay_group_dtls.period_name;

         x_pay_group_dtls(l_counter).period_year := l_pay_group_dtls.period_year;

         x_pay_group_dtls(l_counter).quarter_num := l_pay_group_dtls.quarter_num;

         x_pay_group_dtls(l_counter).start_date := l_pay_group_dtls.start_date;

         x_pay_group_dtls(l_counter).end_date := l_pay_group_dtls.end_date;

    l_counter := l_counter + 1;


      END IF;
   END LOOP;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Pay_Group_Dtls;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Pay_Group_Dtls;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Pay_Group_Dtls;
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
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Get_Pay_Group_Dtls;


PROCEDURE Get_Pay_Group_Sales
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_pay_group_id                IN      NUMBER,
   x_pay_group_sales              OUT NOCOPY     pay_group_sales_tbl_type,
   x_total_record                OUT NOCOPY     NUMBER,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2
 ) IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Get_Pay_Group_Sales';
     l_api_version        CONSTANT NUMBER       := 1.0;

     l_counter      NUMBER;

     CURSOR l_pay_group_sales_cr IS
        select cpg.pay_group_id a,
               cpg.name b,
               cs.period_set_name c,
               cpg.period_type d,
               csr.name e,
               csr.employee_number f,
               cspg.start_date g,
               nvl(cspg.end_date, cpg.end_date) h
         from cn_pay_groups cpg,
              cn_salesreps csr,
              cn_srp_pay_groups cspg,
              cn_period_sets cs
        where (cpg.pay_group_id = cspg.pay_group_id) and
              (csr.salesrep_id = cspg.salesrep_id) and
              (cpg.period_set_id = cs.period_set_id) and
              (cpg.pay_group_id = p_pay_group_id);


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Pay_Group_Sales;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

--   x_pay_group_sales := G_MISS_PAY_GROUP_DTLS_REC_TB ;

   l_counter := 0;
   x_total_record := 0;

   FOR l_pay_group_sales IN l_pay_group_sales_cr LOOP

      x_total_record := x_total_record +1;
      IF (p_fetch_size = -1) OR (x_total_record >= p_start_record
	AND x_total_record <= (p_start_record + p_fetch_size - 1)) THEN
	 -- assign values of the row to x_srp_list






         x_pay_group_sales(l_counter).pay_group_id := l_pay_group_sales.a;


         x_pay_group_sales(l_counter).name := l_pay_group_sales.b;

         x_pay_group_sales(l_counter).period_set_name := l_pay_group_sales.c;

         x_pay_group_sales(l_counter).period_type := l_pay_group_sales.d;

         x_pay_group_sales(l_counter).salesrep_name := l_pay_group_sales.e;
         x_pay_group_sales(l_counter).employee_number := l_pay_group_sales.f;

         x_pay_group_sales(l_counter).start_date := l_pay_group_sales.g;

         x_pay_group_sales(l_counter).end_date := l_pay_group_sales.h;

    l_counter := l_counter + 1;


      END IF;
   END LOOP;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Pay_Group_Sales;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Pay_Group_Sales;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Pay_Group_Sales;
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
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Get_Pay_Group_Sales;



PROCEDURE Get_Pay_Group_Roles
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_pay_group_id                IN      NUMBER,
   x_pay_group_roles             OUT  NOCOPY   pay_group_roles_tbl_type,
   x_total_record                OUT  NOCOPY  NUMBER,
   x_return_status               OUT  NOCOPY  VARCHAR2,
   x_msg_count                   OUT  NOCOPY  NUMBER,
   x_msg_data                    OUT  NOCOPY  VARCHAR2
 ) IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Get_Pay_Group_Roles';
     l_api_version        CONSTANT NUMBER       := 1.0;

     l_counter      NUMBER;

    -- removed the NVL condition for the end date for the bug fix 3138828 and 3138774

     CURSOR l_pay_group_roles_cr IS
        select cpg.pay_group_id a,
               cpg.name b,
               cs.period_set_name c,
               cpg.period_type d,
               csr.name e,
               csr.role_id f,
               cspg.start_date g,
               cspg.end_date h
         from cn_pay_groups cpg,
              cn_roles csr,
              cn_role_pay_groups cspg,
              cn_period_sets cs
        where (cpg.pay_group_id = cspg.pay_group_id) and
              (csr.role_id = cspg.role_id) and
              (cpg.pay_group_id = p_pay_group_id);






BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Pay_Group_Roles;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

--   x_pay_group_sales := G_MISS_PAY_GROUP_DTLS_REC_TB ;

   l_counter := 0;
   x_total_record := 0;

   FOR l_pay_group_roles IN l_pay_group_roles_cr LOOP

      x_total_record := x_total_record +1;







         x_pay_group_roles(l_counter).pay_group_id := l_pay_group_roles.a;


         x_pay_group_roles(l_counter).name := l_pay_group_roles.b;

         x_pay_group_roles(l_counter).period_set_name := l_pay_group_roles.c;

         x_pay_group_roles(l_counter).period_type := l_pay_group_roles.d;

         x_pay_group_roles(l_counter).role_name := l_pay_group_roles.e;
         x_pay_group_roles(l_counter).role_id := l_pay_group_roles.f;

         x_pay_group_roles(l_counter).start_date := l_pay_group_roles.g;

         x_pay_group_roles(l_counter).end_date := l_pay_group_roles.h;

    l_counter := l_counter + 1;




   END LOOP;

   --IF l_counter = 0 THEN

     -- SELECT name INTO x_pay_group_roles(l_counter).name FROM CN_PAY_GROUPS WHERE PAY_GROUP_ID= p_pay_group_id;

    -- END IF;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Pay_Group_Roles;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Pay_Group_Roles;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Pay_Group_Roles;
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
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Get_Pay_Group_Roles;





END CN_PAY_GROUP_DTLS_PVT;

/
