--------------------------------------------------------
--  DDL for Package Body CN_SALES_HIER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SALES_HIER_PUB" AS
--$Header: cnphierb.pls 115.3 2002/11/21 21:04:01 hlchen ship $

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SALES_HIER_PUB';
  G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnphierb.pls';
  G_LAST_UPDATE_DATE          DATE    := sysdate;
  G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
  G_CREATION_DATE             DATE    := sysdate;
  G_CREATED_BY                NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;





  PROCEDURE get_sales_hier
    (
     p_api_version           IN  NUMBER,
     p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     x_loading_status        OUT NOCOPY VARCHAR2,

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
    )


    IS

     l_api_name		CONSTANT VARCHAR2(30) := 'get_sales_hier';
     l_api_version      CONSTANT NUMBER := 1.0;
     l_comp_group_name  VARCHAR2(100);
     l_comp_group_id    NUMBER;
     l_counter          NUMBER;

    -- Comp Group Query
    -- Get comp group id and name based on the given
    -- P_SALESREP_ID
    -- P_COMP_GROUP_ID
    -- P_DATE

     CURSOR comp_group_cur(
       l_salesrep_id          IN NUMBER,
       l_comp_group_id       IN NUMBER,
       l_date                IN DATE
     ) IS

     SELECT distinct cg.name comp_group_name, cscg.comp_group_id comp_group_id
     FROM
       cn_srp_comp_groups_v cscg,
       cn_comp_groups cg
     WHERE
       ((l_salesrep_id = -9999 ) OR (cscg.salesrep_id = l_salesrep_id)) AND
       cscg.comp_group_id = l_comp_group_id AND
       cscg.start_date_active <= l_date and
       ((cscg.end_date_active is null) OR
       (cscg.end_date_active >= l_date)) AND
       cg.comp_group_id = cscg.comp_group_id ;

   --+
   -- Sub Query 1
   -- To get the manager name, role name based on
   -- the comp group id from Main Query
   --+

     CURSOR mgr_cur(
       l_comp_group_id     IN NUMBER,
       l_date              IN DATE
     )IS

     SELECT
       cs.name mgr_name,
       cs.employee_number mgr_number,
       cscg.role_name mgr_role,
       cscg.start_date_active mgr_start_date,
       cscg.end_date_active mgr_end_date

     FROM
       cn_srp_comp_groups_v cscg,
       cn_salesreps cs
     WHERE
       cscg.comp_group_id = l_comp_group_id AND -- (master-detail passed in value)
       ((cscg.end_date_active is null) OR
       (cscg.end_date_active >= l_date)) AND
       cscg.manager_flag = 'Y' AND
       cscg.salesrep_id = cs.salesrep_id;

     -- +
     -- Sub Query 2
     -- To get the salesrep name, role name based on
     -- the comp group id from Main Query
     --+
     CURSOR srp_cur(
       l_comp_group_id     IN NUMBER,
       l_date              IN DATE
     )IS
     SELECT
       cs.name srp_name ,
       cs.employee_number srp_number,
       cscg.role_name srp_role,
       cscg.start_date_active srp_start_date,
       cscg.end_date_active srp_end_date
     FROM
       cn_srp_comp_groups_v cscg,
       cn_salesreps cs
     WHERE
       cscg.comp_group_id = l_comp_group_id AND -- (master-detail passed value)
       cscg.salesrep_id = cs.salesrep_id AND
       cscg.start_date_active <= l_date AND
       ((cscg.end_date_active is null) OR
       (cscg.end_date_active >= l_date));


   -- Sub Query 3
   -- To get the direct comp group(s)


   CURSOR sub_grp_cur (
     l_comp_group_id       IN NUMBER,
     l_date                IN DATE
   ) IS
     SELECT
       hier.comp_group_id group_id, cg.name group_name
     FROM
       cn_comp_group_hier hier,
       cn_comp_groups cg
     WHERE
       hier.parent_comp_group_id = l_comp_group_id and
       hier.comp_group_id = cg.comp_group_id and
       delete_flag <> 'Y' and
       hier.start_date_active <= l_date and
       ((hier.end_date_active is null) or
       (hier.end_date_active >= l_date));





  BEGIN

  --+
   -- Standard call to check for call compatibility.
   --+
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --+
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --+
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --+
   --  Initialize API return status to success
   --+
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';

   --+
   -- API body
   --+


   x_mgr_count := 0;
   x_srp_count := 0;
   x_grp_count := 0;
   l_counter   := 0;

   -- get comp_group_id  and comp_group_name first
   FOR comp_group IN comp_group_cur(p_salesrep_id,p_comp_group_id,p_date)
   LOOP
     -- get manager_id and manager name
     FOR mgr IN mgr_cur(comp_group.comp_group_id,p_date)
     LOOP
       x_mgr_count := x_mgr_count+1;
       l_counter   := l_counter +1;
       IF (( p_increment_count = -9999) OR (l_counter BETWEEN p_start_record
	AND (p_start_record + p_increment_count -1)))
       THEN
	 x_mgr_tbl(x_mgr_count).name := mgr.mgr_name;
	 x_mgr_tbl(x_mgr_count).number :=mgr.mgr_number;
	 x_mgr_tbl(x_mgr_count).role :=mgr.mgr_role;
	 x_mgr_tbl(x_mgr_count).start_date :=mgr.mgr_start_date;
	 x_mgr_tbl(x_mgr_count).end_date :=mgr.mgr_end_date;
       END IF;
     END LOOP;

     FOR srp IN srp_cur(comp_group.comp_group_id,p_date)
     LOOP
       x_srp_count := x_srp_count+1;
       l_counter   := l_counter +1;
       IF (( p_increment_count = -9999) OR (l_counter BETWEEN p_start_record
	AND (p_start_record + p_increment_count -1)))
       THEN
	 x_srp_tbl(x_srp_count).name := srp.srp_name;
	 x_srp_tbl(x_srp_count).number :=srp.srp_number;
	 x_srp_tbl(x_srp_count).role :=srp.srp_role;
	 x_srp_tbl(x_srp_count).start_date :=srp.srp_start_date;
	 x_srp_tbl(x_srp_count).end_date :=srp.srp_end_date;
       END IF;
     END LOOP;

   END LOOP; -- for the main(comp group) cursor

   -- now get the sub group information

   FOR sub_grp IN sub_grp_cur(p_comp_group_id,p_date)
   LOOP
     x_grp_count := x_grp_count +1;
     x_grp_tbl(x_grp_count).grp_id := sub_grp.group_id;
     x_grp_tbl(x_grp_count).grp_name :=sub_grp.group_name;

     IF (( p_increment_count_grp = -9999) OR (x_grp_count BETWEEN p_start_record_grp
	AND (p_start_record_grp + p_increment_count_grp -1)))
     THEN
       FOR mgr IN mgr_cur(sub_grp.group_id,p_date) -- get manager name
       LOOP
	 x_grp_tbl(x_grp_count).mgr_name := mgr.mgr_name;
	 x_grp_tbl(x_grp_count).mgr_number := mgr.mgr_number;
       END LOOP;
     END IF;
   END LOOP; -- for the comp groups cursor


   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_loading_status := 'UNEXPECTED_ERR';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN OTHERS THEN
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

  END;
END cn_sales_hier_pub;

/
