--------------------------------------------------------
--  DDL for Package Body CN_PSUM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PSUM_PVT" AS
/* $Header: cnvpsumb.pls 115.5 2002/11/21 21:15:53 hlchen ship $ */
g_pkg_name CONSTANT VARCHAR2(30) := 'CN_psum_PVT';

-- Start of comments
-- API name    : Get_psum_Data
-- Type        : Private.
-- Pre-reqs    : None.
-- Usage       :
--
-- Desc        :
--
--
--
-- Parameters  :
-- IN          :  p_api_version       NUMBER      Require
--                p_init_msg_list     VARCHAR2    Optional
--                    Default = FND_API.G_FALSE
--                p_commit            VARCHAR2    Optional
--                    Default = FND_API.G_FALSE
--                p_validation_level  NUMBER      Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     VARCHAR2(1)
--                x_msg_count         NUMBER
--                x_msg_data          VARCHAR2(2000)
-- IN          :  p_mgr_id            NUMBER
--                p_comp_group_id     NUMBER
--                p_org_code          VARCHAR2
--                p_period_id         NUMBER
--                p_start_row         NUMBER
--                p_rows              NUMBER
-- OUT         :  x_psum_data          psum_tbl_type
--                x_totarows        NUMBER
-- Version     :  Current version     1.0
--                Initial version     1.0
--
-- Notes       :  Note text
--
-- End of comments


PROCEDURE Get_Psum_Data
  (
   p_api_version               IN    NUMBER,
   p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status             OUT NOCOPY   VARCHAR2,
   x_msg_count                 OUT NOCOPY   NUMBER,
   x_msg_data                  OUT NOCOPY   VARCHAR2,
   p_mgr_id                    IN    NUMBER,
   p_comp_group_id             IN    NUMBER,
   p_mgr_dtl_flag              IN    VARCHAR2,
   p_effective_date            IN    DATE,
   x_psum_data                 OUT NOCOPY   psum_tbl_type,
   x_total_rows                OUT NOCOPY   NUMBER
   )
IS

l_api_name     CONSTANT VARCHAR2(30) := 'Get_Psum_Data';
l_api_version  CONSTANT NUMBER  := 1.0;
l_srp_group_rec CN_SRP_HIER_PROC_PVT.SRP_GROUP_REC_TYPE;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_srp_role_info_tbl CN_SRP_HIER_PROC_PVT.SRP_ROLE_INFO_TBL_TYPE;
l_returned_rows NUMBER;
l_mgr_name VARCHAR2(360);
l_srp CN_SRP_HIER_PROC_PVT.group_mbr_tbl_type;
l_agg_counter NUMBER := 0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Psum_Data_SP;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_total_rows := 0;

   -- API body
   IF (p_mgr_dtl_flag = 'N') THEN

	/* Setting the input variables */
	l_srp_group_rec.salesrep_id := p_mgr_id;
	l_srp_group_rec.group_id := p_comp_group_id;
	l_srp_group_rec.effective_date := p_effective_date;


	CN_SRP_HIER_PROC_PVT.Get_desc_role_info
	(  p_api_version          => 1.0,
	   p_init_msg_list         => FND_API.G_FALSE,
	   p_commit               => FND_API.G_FALSE,
	   p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	   p_srp                  => l_srp_group_rec,
	   p_return_current       => 'N',
	   x_return_status        => l_return_status,
	   x_msg_count            => l_msg_count,
	   x_msg_data             => l_msg_data,
	   x_srp                  => l_srp_role_info_tbl,
	   x_returned_rows        => l_returned_rows
	);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


      SELECT name
       INTO l_mgr_name
       FROM cn_srp_hr_data
        WHERE srp_id = p_mgr_id
      ;


      IF l_srp_role_info_tbl.COUNT > 0 THEN
      FOR lcount IN l_srp_role_info_tbl.FIRST .. l_srp_role_info_tbl.LAST LOOP

             x_psum_data(lcount).mgr_id := p_mgr_id   ;
             x_psum_data(lcount).mgr_name := l_mgr_name  ;

             x_psum_data(lcount).srp_role_id := l_srp_role_info_tbl(lcount).srp_role_id   ;
             x_psum_data(lcount).srp_id  := l_srp_role_info_tbl(lcount).srp_id           ;
             x_psum_data(lcount).overlay_flag := l_srp_role_info_tbl(lcount).overlay_flag      ;
             x_psum_data(lcount).non_std_flag := l_srp_role_info_tbl(lcount).non_std_flag      ;
             x_psum_data(lcount).role_id := l_srp_role_info_tbl(lcount).role_id           ;
             x_psum_data(lcount).role_name := l_srp_role_info_tbl(lcount).role_name         ;
             x_psum_data(lcount).job_title_id := l_srp_role_info_tbl(lcount).job_title_id      ;
             x_psum_data(lcount).job_discretion := l_srp_role_info_tbl(lcount).job_discretion    ;
             x_psum_data(lcount).status := l_srp_role_info_tbl(lcount).status            ;
             x_psum_data(lcount).plan_activate_status := l_srp_role_info_tbl(lcount).plan_activate_status;
             x_psum_data(lcount).club_eligible_flag := l_srp_role_info_tbl(lcount).club_eligible_flag;
             x_psum_data(lcount).org_code := l_srp_role_info_tbl(lcount).org_code          ;
             x_psum_data(lcount).start_date := l_srp_role_info_tbl(lcount).start_date        ;
             x_psum_data(lcount).end_date := l_srp_role_info_tbl(lcount).end_date          ;
             -- change made here
             x_psum_data(lcount).group_id := p_comp_group_id          ;

     END LOOP;
     END IF;
     x_total_rows := x_psum_data.count;
   ELSE

      -- DBMS_OUTPUT.PUT_LINE('************** Entered in the Else ************' || p_mgr_id || ',' || p_comp_group_id || ',' || p_effective_date);
      /* Getting the managers */
      l_srp_group_rec.salesrep_id := p_mgr_id;
   	  l_srp_group_rec.group_id := p_comp_group_id;
	  l_srp_group_rec.effective_date := p_effective_date;

      CN_SRP_HIER_PROC_PVT.Get_Descendant_group_mbrs(
        p_api_version          => 1.0,
	    p_init_msg_list        => FND_API.G_FALSE,
	    p_commit               => FND_API.G_FALSE,
	    p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
        p_srp                  => l_srp_group_rec,
        p_first_level_only     => 'Y',
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data,
        x_srp                  => l_srp,
        x_returned_rows        => l_returned_rows
      );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

      l_agg_counter := 1;
      -- dbms_output.put_line('Count from Get_Descendant_group_mbrs is : ' || l_srp.COUNT);
      IF l_srp.COUNT > 0 THEN
      FOR i in l_srp.FIRST..l_srp.LAST LOOP
      	   l_srp_group_rec.salesrep_id := l_srp(i).salesrep_id;
   	       l_srp_group_rec.group_id := l_srp(i).group_id;
	       l_srp_group_rec.effective_date := p_effective_date;

           IF p_mgr_id <> l_srp(i).salesrep_id THEN
           CN_SRP_HIER_PROC_PVT.Get_desc_role_info
           (p_api_version          => 1.0,
	       p_init_msg_list         => FND_API.G_FALSE,
    	   p_commit               => FND_API.G_FALSE,
	       p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	       p_srp                  => l_srp_group_rec,
    	   p_return_current       => 'N',
	       x_return_status        => l_return_status,
    	   x_msg_count            => l_msg_count,
	       x_msg_data             => l_msg_data,
    	   x_srp                  => l_srp_role_info_tbl,
	       x_returned_rows        => l_returned_rows
           );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


          SELECT name INTO l_mgr_name FROM cn_srp_hr_data WHERE srp_id = l_srp_group_rec.salesrep_id;
          -- DBMS_OUTPUT.PUT_LINE('************** Entered For Manager  ************ ' || l_srp_group_rec.salesrep_id || ',' || l_mgr_name || ' Status is : ' || l_return_status || ' ROWS : ' || l_srp_role_info_tbl.count);

          IF l_srp_role_info_tbl.COUNT > 0 THEN
          FOR lcount IN l_srp_role_info_tbl.FIRST .. l_srp_role_info_tbl.LAST LOOP
             -- DBMS_OUTPUT.PUT_LINE('Entered in the inner most loop ');
             x_psum_data(l_agg_counter).mgr_id := l_srp_group_rec.salesrep_id;
             x_psum_data(l_agg_counter).mgr_name := l_mgr_name;
             x_psum_data(l_agg_counter).srp_role_id := l_srp_role_info_tbl(lcount).srp_role_id;
             x_psum_data(l_agg_counter).srp_id  := l_srp_role_info_tbl(lcount).srp_id;
             x_psum_data(l_agg_counter).overlay_flag := l_srp_role_info_tbl(lcount).overlay_flag      ;
             x_psum_data(l_agg_counter).non_std_flag := l_srp_role_info_tbl(lcount).non_std_flag      ;
             x_psum_data(l_agg_counter).role_id := l_srp_role_info_tbl(lcount).role_id           ;
             x_psum_data(l_agg_counter).role_name := l_srp_role_info_tbl(lcount).role_name         ;
             x_psum_data(l_agg_counter).job_title_id := l_srp_role_info_tbl(lcount).job_title_id      ;
             x_psum_data(l_agg_counter).job_discretion := l_srp_role_info_tbl(lcount).job_discretion    ;
             x_psum_data(l_agg_counter).status := l_srp_role_info_tbl(lcount).status            ;
             x_psum_data(l_agg_counter).plan_activate_status := l_srp_role_info_tbl(lcount).plan_activate_status;
             x_psum_data(l_agg_counter).club_eligible_flag := l_srp_role_info_tbl(lcount).club_eligible_flag;
             x_psum_data(l_agg_counter).org_code := l_srp_role_info_tbl(lcount).org_code          ;
             x_psum_data(l_agg_counter).start_date := l_srp_role_info_tbl(lcount).start_date        ;
             x_psum_data(l_agg_counter).end_date := l_srp_role_info_tbl(lcount).end_date          ;
             -- change made here
             x_psum_data(l_agg_counter).group_id := l_srp(i).group_id          ;
             l_agg_counter := l_agg_counter + 1;
          END LOOP;
          END IF;
          END IF;
          -- dbms_output.put_line('Finishing the iteration');
      END LOOP;
      END IF;
      x_total_rows := x_psum_data.count;
   END IF;



   -- End of API body.

   << end_api >>

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Psum_Data_SP  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
    (
     p_count   =>  x_msg_count ,
     p_data    =>  x_msg_data  ,
     p_encoded => FND_API.G_FALSE
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Psum_Data_SP ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
    (
     p_count   =>  x_msg_count ,
     p_data    =>  x_msg_data   ,
     p_encoded => FND_API.G_FALSE
     );
   WHEN OTHERS THEN
      ROLLBACK TO Get_Psum_Data_SP ;
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
END Get_Psum_Data;

-- ***********************************
-- TBD : MO
-- ***********************************
PROCEDURE Get_MO_Psum_Data
  (
   p_api_version               IN    NUMBER,
   p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status             OUT NOCOPY   VARCHAR2,
   x_msg_count                 OUT NOCOPY   NUMBER,
   x_msg_data                  OUT NOCOPY   VARCHAR2,
   p_mgr_id                    IN    NUMBER,
   p_comp_group_id             IN    NUMBER,
   p_mgr_dtl_flag              IN    VARCHAR2,
   p_effective_date            IN    DATE,
   p_is_multiorg               IN    VARCHAR2,
   x_psum_data                 OUT NOCOPY   psum_tbl_type,
   x_total_rows                OUT NOCOPY   NUMBER
   )
IS

l_api_name     CONSTANT VARCHAR2(30) := 'Get_Psum_Data';
l_api_version  CONSTANT NUMBER  := 1.0;
l_srp_group_rec CN_SRP_HIER_PROC_PVT.SRP_GROUP_REC_TYPE;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_srp_role_info_tbl CN_SRP_HIER_PROC_PVT.SRP_ROLE_INFO_TBL_TYPE;
l_returned_rows NUMBER;
l_mgr_name VARCHAR2(360);
l_srp CN_SRP_HIER_PROC_PVT.group_mbr_tbl_type;
l_agg_counter NUMBER := 0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_MO_Psum_Data_SP;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_total_rows := 0;

   -- API body
   IF (p_mgr_dtl_flag = 'N') THEN

	/* Setting the input variables */
	l_srp_group_rec.salesrep_id := p_mgr_id;
	l_srp_group_rec.group_id := p_comp_group_id;
	l_srp_group_rec.effective_date := p_effective_date;


	CN_SRP_HIER_PROC_PVT.Get_MO_desc_role_info
	(  p_api_version          => 1.0,
	   p_init_msg_list         => FND_API.G_FALSE,
	   p_commit               => FND_API.G_FALSE,
	   p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	   p_srp                  => l_srp_group_rec,
	   p_return_current       => 'N',
       p_is_multiorg          => p_is_multiorg,
	   x_return_status        => l_return_status,
	   x_msg_count            => l_msg_count,
	   x_msg_data             => l_msg_data,
	   x_srp                  => l_srp_role_info_tbl,
	   x_returned_rows        => l_returned_rows
	);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

      IF p_is_multiorg = 'Y' THEN
         SELECT  RE.RESOURCE_NAME INTO l_mgr_name
         FROM JTF_RS_RESOURCE_EXTNS_VL RE, JTF_RS_SALESREPS S
         WHERE RE.RESOURCE_ID = S.RESOURCE_ID AND TO_NUMBER(S.SALESREP_ID) > 0 AND
         S.SALESREP_ID = p_mgr_id;
      ELSE
         SELECT name INTO l_mgr_name
         FROM cn_srp_hr_data
         WHERE srp_id = p_mgr_id;
      END IF;


      IF l_srp_role_info_tbl.COUNT > 0 THEN
      FOR lcount IN l_srp_role_info_tbl.FIRST .. l_srp_role_info_tbl.LAST LOOP

             x_psum_data(lcount).mgr_id := p_mgr_id   ;
             x_psum_data(lcount).mgr_name := l_mgr_name  ;

             x_psum_data(lcount).srp_role_id := l_srp_role_info_tbl(lcount).srp_role_id   ;
             x_psum_data(lcount).srp_id  := l_srp_role_info_tbl(lcount).srp_id           ;
             x_psum_data(lcount).overlay_flag := l_srp_role_info_tbl(lcount).overlay_flag      ;
             x_psum_data(lcount).non_std_flag := l_srp_role_info_tbl(lcount).non_std_flag      ;
             x_psum_data(lcount).role_id := l_srp_role_info_tbl(lcount).role_id           ;
             x_psum_data(lcount).role_name := l_srp_role_info_tbl(lcount).role_name         ;
             x_psum_data(lcount).job_title_id := l_srp_role_info_tbl(lcount).job_title_id      ;
             x_psum_data(lcount).job_discretion := l_srp_role_info_tbl(lcount).job_discretion    ;
             x_psum_data(lcount).status := l_srp_role_info_tbl(lcount).status            ;
             x_psum_data(lcount).plan_activate_status := l_srp_role_info_tbl(lcount).plan_activate_status;
             x_psum_data(lcount).club_eligible_flag := l_srp_role_info_tbl(lcount).club_eligible_flag;
             x_psum_data(lcount).org_code := l_srp_role_info_tbl(lcount).org_code          ;
             x_psum_data(lcount).start_date := l_srp_role_info_tbl(lcount).start_date        ;
             x_psum_data(lcount).end_date := l_srp_role_info_tbl(lcount).end_date          ;
             -- change made here
             x_psum_data(lcount).group_id := p_comp_group_id          ;

     END LOOP;
     END IF;
     x_total_rows := x_psum_data.count;
   ELSE

      -- DBMS_OUTPUT.PUT_LINE('************** Entered in the Else ************' || p_mgr_id || ',' || p_comp_group_id || ',' || p_effective_date);
      /* Getting the managers */
      l_srp_group_rec.salesrep_id := p_mgr_id;
   	  l_srp_group_rec.group_id := p_comp_group_id;
	  l_srp_group_rec.effective_date := p_effective_date;

      CN_SRP_HIER_PROC_PVT.Get_MO_Descendant_group_mbrs(
        p_api_version          => 1.0,
	    p_init_msg_list        => FND_API.G_FALSE,
	    p_commit               => FND_API.G_FALSE,
	    p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
        p_srp                  => l_srp_group_rec,
        p_first_level_only     => 'Y',
        p_is_multiorg          => p_is_multiorg,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data,
        x_srp                  => l_srp,
        x_returned_rows        => l_returned_rows
      );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

      l_agg_counter := 1;
      -- dbms_output.put_line('Count from Get_Descendant_group_mbrs is : ' || l_srp.COUNT);
      IF l_srp.COUNT > 0 THEN
      FOR i in l_srp.FIRST..l_srp.LAST LOOP
      	   l_srp_group_rec.salesrep_id := l_srp(i).salesrep_id;
   	       l_srp_group_rec.group_id := l_srp(i).group_id;
	       l_srp_group_rec.effective_date := p_effective_date;

           IF p_mgr_id <> l_srp(i).salesrep_id THEN
           CN_SRP_HIER_PROC_PVT.Get_MO_desc_role_info
           (p_api_version          => 1.0,
	       p_init_msg_list         => FND_API.G_FALSE,
    	   p_commit               => FND_API.G_FALSE,
	       p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	       p_srp                  => l_srp_group_rec,
    	   p_return_current       => 'N',
           p_is_multiorg          => p_is_multiorg,
           x_return_status        => l_return_status,
    	   x_msg_count            => l_msg_count,
	       x_msg_data             => l_msg_data,
    	   x_srp                  => l_srp_role_info_tbl,
	       x_returned_rows        => l_returned_rows
           );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


      IF p_is_multiorg = 'Y' THEN
         SELECT  RE.RESOURCE_NAME INTO l_mgr_name
         FROM JTF_RS_RESOURCE_EXTNS_VL RE, JTF_RS_SALESREPS S
         WHERE RE.RESOURCE_ID = S.RESOURCE_ID AND TO_NUMBER(S.SALESREP_ID) > 0 AND
         S.SALESREP_ID = l_srp_group_rec.salesrep_id;
      ELSE
         SELECT name INTO l_mgr_name
         FROM cn_srp_hr_data
         WHERE srp_id = l_srp_group_rec.salesrep_id;
      END IF;

          IF l_srp_role_info_tbl.COUNT > 0 THEN
          FOR lcount IN l_srp_role_info_tbl.FIRST .. l_srp_role_info_tbl.LAST LOOP
             -- DBMS_OUTPUT.PUT_LINE('Entered in the inner most loop ');
             x_psum_data(l_agg_counter).mgr_id := l_srp_group_rec.salesrep_id;
             x_psum_data(l_agg_counter).mgr_name := l_mgr_name;
             x_psum_data(l_agg_counter).srp_role_id := l_srp_role_info_tbl(lcount).srp_role_id;
             x_psum_data(l_agg_counter).srp_id  := l_srp_role_info_tbl(lcount).srp_id;
             x_psum_data(l_agg_counter).overlay_flag := l_srp_role_info_tbl(lcount).overlay_flag      ;
             x_psum_data(l_agg_counter).non_std_flag := l_srp_role_info_tbl(lcount).non_std_flag      ;
             x_psum_data(l_agg_counter).role_id := l_srp_role_info_tbl(lcount).role_id           ;
             x_psum_data(l_agg_counter).role_name := l_srp_role_info_tbl(lcount).role_name         ;
             x_psum_data(l_agg_counter).job_title_id := l_srp_role_info_tbl(lcount).job_title_id      ;
             x_psum_data(l_agg_counter).job_discretion := l_srp_role_info_tbl(lcount).job_discretion    ;
             x_psum_data(l_agg_counter).status := l_srp_role_info_tbl(lcount).status            ;
             x_psum_data(l_agg_counter).plan_activate_status := l_srp_role_info_tbl(lcount).plan_activate_status;
             x_psum_data(l_agg_counter).club_eligible_flag := l_srp_role_info_tbl(lcount).club_eligible_flag;
             x_psum_data(l_agg_counter).org_code := l_srp_role_info_tbl(lcount).org_code          ;
             x_psum_data(l_agg_counter).start_date := l_srp_role_info_tbl(lcount).start_date        ;
             x_psum_data(l_agg_counter).end_date := l_srp_role_info_tbl(lcount).end_date          ;
             -- change made here
             x_psum_data(l_agg_counter).group_id := l_srp(i).group_id          ;
             l_agg_counter := l_agg_counter + 1;
          END LOOP;
          END IF;
          END IF;
          -- dbms_output.put_line('Finishing the iteration');
      END LOOP;
      END IF;
      x_total_rows := x_psum_data.count;
   END IF;



   -- End of API body.

   << end_api >>

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_MO_Psum_Data_SP  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
    (
     p_count   =>  x_msg_count ,
     p_data    =>  x_msg_data  ,
     p_encoded => FND_API.G_FALSE
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_MO_Psum_Data_SP ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
    (
     p_count   =>  x_msg_count ,
     p_data    =>  x_msg_data   ,
     p_encoded => FND_API.G_FALSE
     );
   WHEN OTHERS THEN
      ROLLBACK TO Get_MO_Psum_Data_SP ;
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
END Get_MO_Psum_Data;


END CN_psum_PVT;


/
