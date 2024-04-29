--------------------------------------------------------
--  DDL for Package Body CN_TSR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TSR_PVT" AS
/* $Header: cnvtsrb.pls 115.16 2002/11/21 21:19:57 hlchen ship $ */

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_TSR_PVT';
  G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvtsrb.pls';
  G_LAST_UPDATE_DATE          DATE    := sysdate;
  G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
  G_CREATION_DATE             DATE    := sysdate;
  G_CREATED_BY                NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;


-- Start of comments
-- API name    : Get_Tsr_Data
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
--                p_comp_group_id	   NUMBER
--                p_org_code          VARCHAR2
--                p_period_id         DATE
--                p_start_row         NUMBER
--                p_rows              NUMBER
-- OUT         :  x_tsr_data          tsr_tbl_type
--                x_total_rows        NUMBER
-- Version     :  Current version     1.0
--                Initial version     1.0
--
-- Notes       :  Note text
--
-- End of comments


PROCEDURE Get_Tsr_Data
  (
   p_api_version          IN    NUMBER,
   p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit               IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status        OUT NOCOPY   VARCHAR2,
   x_msg_count            OUT NOCOPY   NUMBER,
   x_msg_data             OUT NOCOPY   VARCHAR2,
   p_mgr_id               IN    NUMBER,
   p_comp_group_id        IN    NUMBER,
   p_org_code             IN    VARCHAR2,
   p_period_id            IN    DATE,
   p_start_row            IN    NUMBER,
   p_rows                 IN    NUMBER,
   x_tsr_data             OUT NOCOPY   tsr_tbl_type,
   x_total_rows           OUT NOCOPY   NUMBER,
   download               IN    VARCHAR2 := 'N'
   ) IS

     l_api_name     CONSTANT VARCHAR2(30) := 'Get_Tsr_Data';
     l_api_version  CONSTANT NUMBER  := 1.0;
     l_ctr NUMBER;
     l_inner_ctr NUMBER;
/* Nikhil: Completely restructed the cursor */
     CURSOR l_tsr_cr
       (P_SRP_ID  NUMBER, P_GROUP_ID NUMBER) IS
       SELECT
         hr1.emp_num         tsr_emp_no,
         hr1.name            tsr_name,
         hr1.srp_id          tsr_srp_id
       FROM
         cn_srp_hr_data hr1
       WHERE
	 NOT EXISTS (
		SELECT  1
	       from jtf_rs_groups_vl jg,
		jtf_rs_role_relations jrr,
		 jtf_rs_salesreps jrs,
		 jtf_rs_roles_b jr,
		 jtf_rs_group_mbr_role_vl jgm,
		 jtf_rs_group_usages u
		 WHERE jg.group_id = jgm.group_id
		 and (jgm.manager_flag = 'Y' or jgm.member_flag = 'Y')
		  and jrs.resource_id = jgm.resource_id
		  and u.group_id = jgm.group_id
		  and u.usage = 'SF_PLANNING'
		  and jrr.role_resource_type = 'RS_INDIVIDUAL'
		   and jrr.role_resource_id = jrs.resource_id
		    and jrr.role_id = jgm.role_id and jrr.role_id = jr.role_id
		     and jr.role_type_code = 'SALES_COMP'
                     and TRUNC(p_period_id) between trunc(jrr.start_date_active)
                      and  NVL(TRUNC(jrr.end_date_active), TRUNC(p_period_id))
		      and jrr.delete_flag <> 'Y' and
		       jrr.start_date_active <= jgm.start_date_active
			and (jrr.end_date_active is null
			or jrr.end_date_active >= jgm.end_date_active) AND jrs.SALESREP_ID > 0
			AND NVL(jrs.ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
			 NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))
			 = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),
			  ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
			       AND jrs.salesrep_id = P_SRP_ID
			       AND jg.group_id = P_GROUP_ID
 	               )
         and hr1.srp_id = P_SRP_ID
       UNION ALL
       SELECT
         hr1.emp_num	     tsr_emp_no,
         hr1.name            tsr_name,
         hr1.srp_id          tsr_srp_id
       FROM
         cn_srp_hr_data hr1
       WHERE
         EXISTS (
		SELECT 1
	       from jtf_rs_groups_vl jg,
		jtf_rs_role_relations jrr,
		 jtf_rs_salesreps jrs,
		 jtf_rs_roles_b jr,
		 jtf_rs_group_mbr_role_vl jgm,
		 cn_srp_role_dtls srd,
		 jtf_rs_group_usages u
		 WHERE jg.group_id = jgm.group_id
		 and (jgm.manager_flag = 'Y' or jgm.member_flag = 'Y')
		  and jrs.resource_id = jgm.resource_id
		  and u.group_id = jgm.group_id
		  and u.usage = 'SF_PLANNING'
		  and jrr.role_resource_type = 'RS_INDIVIDUAL'
		   and jrr.role_resource_id = jrs.resource_id
		    and jrr.role_id = jgm.role_id and jrr.role_id = jr.role_id
		     and jr.role_type_code = 'SALES_COMP'
                         AND TRUNC(p_period_id) between trunc(jrr.start_date_active)
                         AND NVL(TRUNC(jrr.end_date_active), TRUNC(p_period_id))
		      and jrr.delete_flag <> 'Y' and
		       jrr.start_date_active <= jgm.start_date_active
			and (jrr.end_date_active is null
			or jrr.end_date_active >= jgm.end_date_active) AND jrs.SALESREP_ID > 0
			AND NVL(jrs.ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
			 NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))
			 = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),
			  ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
			       AND jrs.salesrep_id = P_SRP_ID
			       AND jg.group_id = P_GROUP_ID
			       AND srd.srp_role_id = jrr.role_relate_id
                   AND srd.role_model_id is null -- "CHANGED FOR MODELING IMPACT"
                       AND srd.job_title_id = -99
 	        )
/*
         AND NOT EXISTS --- Check this
              (
		   SELECT s.salesrep_id
		       from jtf_rs_role_relations rr,
			jtf_rs_salesreps s,
			cn_srp_role_dtls srd,
                        jtf_rs_roles_b r
			WHERE rr.role_resource_id = s.resource_id
			 and rr.role_relate_id = srd.srp_role_id
			 and rr.role_resource_type = 'RS_INDIVIDUAL'
			  and rr.delete_flag = 'N'
			  AND NVL(S.ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),
			   ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))
			  = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
			   NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
			 AND s.salesrep_id = P_SRP_ID
			 AND TRUNC(p_period_id) between trunc(rr.start_date_active)
                         AND NVL(TRUNC(rr.end_date_active), TRUNC(p_period_id))
                         AND srd.job_title_id <> -99
                         AND r.role_id = rr.role_id
                         AND r.role_type_code = 'SALES_COMP'
             )
*/
         AND hr1.SRP_ID = P_SRP_ID
       ORDER BY
       tsr_name, tsr_emp_no;

     CURSOR l_mgr_cr
       (P_MGR_SRP_ID NUMBER) IS
     SELECT
        emp_num mgr_emp_no,
        name  mgr_name,
        srp_id tsr_mgr_id
     FROM
        cn_srp_hr_data
     WHERE srp_id = P_MGR_SRP_ID;



      l_srp_tbl              cn_srp_hier_proc_pvt.group_mbr_tbl_type;
      l_srp_rec              cn_srp_hier_proc_pvt.srp_group_rec_type;
      l_returned_rows        number;
      l_return_status VARCHAR2(1);


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Tsr_Data_SP;
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


   -- API body
   l_ctr := 1;
   l_inner_ctr := 1;
   --start by getting all people below this person
  l_srp_rec.salesrep_id := p_mgr_id;
  l_srp_rec.group_id := p_comp_group_id;
  l_srp_rec.effective_date := p_period_id;


  cn_srp_hier_proc_pvt.Get_Descendant_group_mbrs
   (p_api_version                => 1.0,
    p_init_msg_list              => FND_API.G_FALSE,
    p_commit                     => FND_API.G_FALSE,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    p_srp                        => l_srp_rec,
    x_return_status              => l_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    x_srp                        => l_srp_tbl,
    x_returned_rows              => l_returned_rows);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


-- dbms_output.put_line(to_char(l_srp_tbl.count));

IF (l_srp_tbl.count > 0) THEN
 FOR i in l_srp_tbl.first .. l_srp_tbl.last LOOP

    FOR eachrow in l_tsr_cr(l_srp_tbl(i).salesrep_id, l_srp_tbl(i).group_id) LOOP

       -- dbms_output.put_line(eachrow.tsr_emp_no || ' ' || eachrow.tsr_name);
       IF ( (l_ctr BETWEEN p_start_row AND (p_start_row + p_rows - 1)) AND (download = 'N')) THEN
         x_tsr_data(l_inner_ctr).tsr_emp_no   :=  eachrow.tsr_emp_no;
         x_tsr_data(l_inner_ctr).tsr_name     :=  eachrow.tsr_name;
         x_tsr_data(l_inner_ctr).tsr_srp_id     :=  eachrow.tsr_srp_id;

         IF l_srp_tbl(i).mgr_srp_id <> 0 THEN
         FOR mgrrow in l_mgr_cr(l_srp_tbl(i).mgr_srp_id) LOOP
            x_tsr_data(l_inner_ctr).mgr_emp_no   :=  mgrrow.mgr_emp_no;
            x_tsr_data(l_inner_ctr).mgr_name     :=  mgrrow.mgr_name;
            x_tsr_data(l_inner_ctr).tsr_mgr_id   :=  mgrrow.tsr_mgr_id;
         END LOOP;
         ELSE
          x_tsr_data(l_inner_ctr).mgr_emp_no   :=  ' - ';
          x_tsr_data(l_inner_ctr).mgr_name     :=  ' - ';
          x_tsr_data(l_inner_ctr).tsr_mgr_id   := 0;
         END IF;
         l_inner_ctr := l_inner_ctr + 1;
       END IF;

       IF (download = 'Y') THEN
         x_tsr_data(l_inner_ctr).tsr_emp_no   :=  eachrow.tsr_emp_no;
         x_tsr_data(l_inner_ctr).tsr_name     :=  eachrow.tsr_name;
         IF l_srp_tbl(i).mgr_srp_id <> 0 THEN
         FOR mgrrow in l_mgr_cr(l_srp_tbl(i).mgr_srp_id) LOOP
            x_tsr_data(l_inner_ctr).mgr_emp_no   :=  mgrrow.mgr_emp_no;
            x_tsr_data(l_inner_ctr).mgr_name     :=  mgrrow.mgr_name;
         END LOOP;
         ELSE
          x_tsr_data(l_inner_ctr).mgr_emp_no   :=  ' - ';
          x_tsr_data(l_inner_ctr).mgr_name     :=  ' - ';
         END IF;
         l_inner_ctr := l_inner_ctr + 1;
       END IF;

    l_ctr := l_ctr + 1;
    END LOOP;

 END LOOP;
END IF;

--  x_total_rows := l_tsr_cr%ROWCOUNT;
  x_total_rows := l_ctr;

--   IF l_tsr_cr%ROWCOUNT = 0 THEN
--      x_tsr_data := G_MISS_TSR_TBL ;
--   END IF;

--   CLOSE l_tsr_cr;
   -- End of API body.
   << end_api >>
     NULL;
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
      ROLLBACK TO Get_Tsr_Data_SP  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
    (
     p_count   =>  x_msg_count ,
     p_data    =>  x_msg_data  ,
     p_encoded => FND_API.G_FALSE
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Tsr_Data_SP ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
    (
     p_count   =>  x_msg_count ,
     p_data    =>  x_msg_data   ,
     p_encoded => FND_API.G_FALSE
     );
   WHEN OTHERS THEN
      ROLLBACK TO Get_Tsr_Data_SP ;
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
END Get_Tsr_Data;


END CN_TSR_PVT;


/
