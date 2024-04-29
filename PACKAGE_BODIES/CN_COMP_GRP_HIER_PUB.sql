--------------------------------------------------------
--  DDL for Package Body CN_COMP_GRP_HIER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMP_GRP_HIER_PUB" AS
--$Header: cnpcghrb.pls 115.7 2002/05/20 13:01:28 pkm ship     $
   --
   G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_COMP_GRP_HIER_PUB';
   G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnpcghrb.pls';
   G_LAST_UPDATE_DATE          DATE    := sysdate;
   G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
   G_CREATION_DATE             DATE    := sysdate;
   G_CREATED_BY                NUMBER  := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
   --
PROCEDURE get_comp_group_hier(
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
     p_validation_level         IN   VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
     p_salesrep_id              IN   NUMBER ,
     p_comp_group_id            IN   NUMBER,
     p_focus_cg_id		IN   NUMBER,
     p_expand			IN   CHAR,
     p_date                  	IN   DATE,
     x_mgr_tbl                  OUT  comp_group_tbl,
     l_mgr_count                OUT  NUMBER,
     x_period_year		OUT  VARCHAR2,
     x_return_status            OUT  VARCHAR2,
     x_msg_count                OUT  NUMBER,
     x_msg_data                 OUT  VARCHAR2,
     x_loading_status           OUT  VARCHAR2) IS

     l_api_name			CONSTANT VARCHAR2(30) := 'get_comp_group_hier';
     l_api_version      	CONSTANT NUMBER := 1.0;
     l_comp_group_name  	VARCHAR2(100);
     l_comp_group_id    	NUMBER;
     l_counter          	NUMBER;
     l_grp_count		NUMBER := 0;
     l_parent_cg_id		NUMBER;
     l_child_cg_id		NUMBER;
     l_top_hier_tbl		cn_comp_grp_hier_pub.comp_group_tbl;
     l_top_hier			CHAR(1);
     l_out_counter		NUMBER;
     l_image_start		CHAR(1);

-- For getting the sibling records for the first cursor.
CURSOR sibling_grp_cur(
     l_parent_cg_id        IN NUMBER,
     l_date                IN DATE) IS
   SELECT hier.comp_group_id group_id, cg.name group_name,
          hier.start_date_active,hier.end_date_active
     FROM cn_comp_group_hier hier,
          cn_comp_groups cg
    WHERE hier.parent_comp_group_id = l_parent_cg_id
      AND hier.comp_group_id = cg.comp_group_id
      AND hier.comp_group_id <> DECODE(p_focus_cg_id,'0',p_comp_group_id,p_focus_cg_id)
      AND delete_flag <> 'Y'
      AND hier.start_date_active <= l_date
      AND ((hier.end_date_active is null) OR
           (hier.end_date_active >= l_date));

-- For getting the child records for the first cursor.
CURSOR child_grp_cur(
     l_parent_cg_id        IN NUMBER,
     l_date                IN DATE) IS
   SELECT hier.comp_group_id group_id, cg.name group_name,
          hier.start_date_active,hier.end_date_active
     FROM cn_comp_group_hier hier,
          cn_comp_groups cg
    WHERE hier.parent_comp_group_id = l_parent_cg_id
      AND hier.comp_group_id = cg.comp_group_id
      AND delete_flag <> 'Y'
      AND hier.start_date_active <= l_date
      AND ((hier.end_date_active is null) OR
           (hier.end_date_active >= l_date));

-- To get the manager/salesrep names based on the comp group id
-- from the main query
CURSOR mgr_cur(
       l_comp_group_id     IN NUMBER,
       l_date              IN DATE) IS
   SELECT cs.name mgr_name,
       	  cs.employee_number mgr_number,
	  cs.salesrep_id salesrep_id,
       	  cscg.role_name mgr_role,
       	  cscg.start_date_active mgr_start_date,
       	  cscg.end_date_active mgr_end_date,
	  cscg.role_id mgr_role_id,
	  cscg.srp_role_id mgr_srp_role_id
     FROM cn_srp_comp_groups_v cscg,
          cn_salesreps cs
    WHERE cscg.comp_group_id = l_comp_group_id
      AND cscg.salesrep_id = cs.salesrep_id
      AND cscg.start_date_active <= l_date
      AND ((cscg.end_date_active is null) OR
           (cscg.end_date_active >= l_date));

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status 	:= FND_API.G_RET_STS_SUCCESS;
   x_loading_status 	:= 'CN_INSERTED';
   l_mgr_count 		:= 0;
   l_counter   		:= 0;
   -- Before doing anything, check whether the comp_group_id
   -- is available in the cn_cg_hier table
   -- Changed by Zack at May-06-2002 to add checking for p_date is within the
   -- effective date range of srp comp group assignment
   SELECT count(*)
     INTO l_counter
     FROM cn_comp_groups cg, cn_srp_comp_groups_v cscg
    WHERE cg.comp_group_id = p_comp_group_id
      AND cg.start_date_active <= p_date
      AND ((cg.end_date_active is null) OR
	   (cg.end_date_active >= p_date))
      AND  cscg.comp_group_id= cg.comp_group_id
      and cscg.salesrep_id = p_salesrep_id
      and cscg.start_date_active <= p_date
      AND ((cscg.end_date_active is null) OR
	   (cscg.end_date_active >= p_date));


   --
   IF (l_counter <> 0) THEN
   -- Get the period year which will be passed to YTD Summary
   BEGIN
      SELECT period_year
        INTO x_period_year
        FROM cn_repositories r, cn_period_statuses ps
       WHERE r.period_type_id 	= ps.period_type_id
         AND r.period_set_id 	= ps.period_set_id
         AND period_status IN ('O','C')
         AND p_date BETWEEN start_date AND end_date;
   EXCEPTION
      WHEN OTHERS THEN
         x_period_year := TO_CHAR(SYSDATE,'RRRR');
   END;
   --
   -- check whether it is called from submit button or
   -- PLUS/MINUS symbol(drill down link)
   IF (NVL(p_focus_cg_id,0) <> 0) THEN
	 l_comp_group_id := p_focus_cg_id;
   ELSE
	 l_comp_group_id := p_comp_group_id;
   END IF;

   -- l_comp_group_id need to be remembered, since its value
   -- will be changed in the following WHILE loop
   l_child_cg_id := l_comp_group_id;

   l_counter 	:= 1;
   l_top_hier	:= 'N';

   -- This block will find the hierarchy from the selected
   -- comp group to the top most.
   BEGIN
      WHILE l_top_hier = 'N'
      LOOP
         BEGIN
	    SELECT comp_group_id,
	           parent_comp_group_id,
		   start_date_active,
		   end_date_active
              INTO l_top_hier_tbl(l_counter).cg_salesrep_id,
		   l_top_hier_tbl(l_counter).parent_comp_group_id,
		   l_top_hier_tbl(l_counter).start_date_active,
		   l_top_hier_tbl(l_counter).end_date_active
              FROM cn_comp_group_hier cgh
	     WHERE comp_group_id = l_comp_group_id
	       AND cgh.start_date_active <= p_date
	       AND ((cgh.end_date_active is null) OR
		    (cgh.end_date_active >= p_date));
	    l_top_hier_tbl(l_counter).level := l_counter;
	    l_comp_group_id := l_top_hier_tbl(l_counter).parent_comp_group_id;
	    l_counter := l_counter + 1;
         EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       l_top_hier := 'Y';
	       BEGIN
	          SELECT comp_group_id,
	                 NULL,
		         start_date_active,
		         end_date_active
                    INTO l_top_hier_tbl(l_counter).cg_salesrep_id,
		         l_top_hier_tbl(l_counter).parent_comp_group_id,
		         l_top_hier_tbl(l_counter).start_date_active,
		         l_top_hier_tbl(l_counter).end_date_active
                    FROM cn_comp_groups cg
	           WHERE comp_group_id = l_comp_group_id
	             AND cg.start_date_active <= p_date
	             AND ((cg.end_date_active is null) OR
		          (cg.end_date_active >= p_date));
	       EXCEPTION
	          WHEN OTHERS THEN
		     EXIT;
	       END;
            WHEN OTHERS THEN
	       EXIT;
         END;
      END LOOP;
   END;
   l_counter 		:= l_top_hier_tbl.COUNT;
   l_out_counter 	:= 0;

   -- To get the comp group names for the above IDs
   FOR i IN 1..l_top_hier_tbl.COUNT
   LOOP
      l_out_counter := l_out_counter+1;
      IF (l_counter = 2) THEN
         -- This ID is required to get the siblings for the selected
         -- comp group ID.
         l_parent_cg_id := l_top_hier_tbl(l_counter).cg_salesrep_id;
      END IF;
      BEGIN
         SELECT name
	   INTO x_mgr_tbl(l_out_counter).cg_salesrep_name
	   FROM cn_comp_groups
	  WHERE comp_group_id = l_top_hier_tbl(l_counter).cg_salesrep_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    NULL;
      END;
      x_mgr_tbl(l_out_counter).cg_salesrep_id := l_top_hier_tbl(l_counter).cg_salesrep_id;
      x_mgr_tbl(l_out_counter).start_date_active := l_top_hier_tbl(l_counter).start_date_active;
      x_mgr_tbl(l_out_counter).end_date_active := l_top_hier_tbl(l_counter).end_date_active;
      x_mgr_tbl(l_out_counter).level := i;
      x_mgr_tbl(l_out_counter).grp_or_name_flag := 'GROUP';

      IF (l_top_hier_tbl(l_counter).cg_salesrep_id = p_comp_group_id) THEN
         l_image_start := 'Y';
      END IF;

      -- This logic will set the PLUS/MINUS symbol based on the drilldown.
      IF (NVL(l_image_start,'N') = 'Y') THEN
         IF (l_top_hier_tbl(l_counter).cg_salesrep_id = l_child_cg_id) THEN
            IF (p_expand = 'Y') THEN
               x_mgr_tbl(l_out_counter).image 	:= 'MINUS';
               x_mgr_tbl(l_out_counter).expand 	:= 'N';
            ELSE
               x_mgr_tbl(l_out_counter).image 	:= 'PLUS';
               x_mgr_tbl(l_out_counter).expand 	:= 'Y';
            END IF;
         ELSE
	    x_mgr_tbl(l_out_counter).image   := 'MINUS';
            x_mgr_tbl(l_out_counter).expand  := 'N';
	 END IF;
      ELSE
         x_mgr_tbl(l_out_counter).image     := 'NONE';
         x_mgr_tbl(l_out_counter).expand    := 'N';
      END IF;

      -- For each comp group ID, get the corresponding members.
      FOR mgr IN mgr_cur(l_top_hier_tbl(l_counter).cg_salesrep_id,p_date)
      LOOP
         l_out_counter := l_out_counter+1;
         x_mgr_tbl(l_out_counter).cg_salesrep_name  := mgr.mgr_name;
         x_mgr_tbl(l_out_counter).cg_salesrep_id    := mgr.salesrep_id;
         x_mgr_tbl(l_out_counter).grp_or_name_flag  := 'NAME';
         x_mgr_tbl(l_out_counter).role_name         := mgr.mgr_role;
         x_mgr_tbl(l_out_counter).role_id           := mgr.mgr_role_id;
         x_mgr_tbl(l_out_counter).start_date_active := mgr.mgr_start_date;
         x_mgr_tbl(l_out_counter).end_date_active   := mgr.mgr_end_date;
      END LOOP;
      l_counter := l_counter - 1;

   END LOOP;

   -- Fetching children comp group IDs and the corresponding memebers
   IF (p_expand = 'Y') THEN
   FOR child_grp IN child_grp_cur(l_child_cg_id,p_date)
   LOOP
      l_out_counter := l_out_counter+1;
      x_mgr_tbl(l_out_counter).cg_salesrep_name   	:= child_grp.group_name;
      x_mgr_tbl(l_out_counter).cg_salesrep_id     	:= child_grp.group_id;
      x_mgr_tbl(l_out_counter).grp_or_name_flag   	:= 'GROUP';
      x_mgr_tbl(l_out_counter).start_date_active  	:= child_grp.start_date_active;
      x_mgr_tbl(l_out_counter).end_date_active    	:= child_grp.end_date_active;
      x_mgr_tbl(l_out_counter).level              	:= l_top_hier_tbl.COUNT + 1;
      x_mgr_tbl(l_out_counter).image 			:= 'PLUS';
      x_mgr_tbl(l_out_counter).expand 			:= 'Y';
      --
      FOR mgr IN mgr_cur(child_grp.group_id,p_date)
      LOOP
         l_out_counter := l_out_counter+1;
         x_mgr_tbl(l_out_counter).cg_salesrep_name  := mgr.mgr_name;
         x_mgr_tbl(l_out_counter).cg_salesrep_id    := mgr.salesrep_id;
         x_mgr_tbl(l_out_counter).grp_or_name_flag  := 'NAME';
         x_mgr_tbl(l_out_counter).role_name         := mgr.mgr_role;
         x_mgr_tbl(l_out_counter).role_id           := mgr.mgr_role_id;
         x_mgr_tbl(l_out_counter).start_date_active := mgr.mgr_start_date;
         x_mgr_tbl(l_out_counter).end_date_active   := mgr.mgr_end_date;
      END LOOP;
      --
   END LOOP;
   END IF;
   -- Fetching sibling records and their corresponding members
   FOR sibling_grp IN sibling_grp_cur(l_parent_cg_id,p_date)
   LOOP
      l_out_counter := l_out_counter+1;
      x_mgr_tbl(l_out_counter).cg_salesrep_name		:= sibling_grp.group_name;
      x_mgr_tbl(l_out_counter).cg_salesrep_id    	:= sibling_grp.group_id;
      x_mgr_tbl(l_out_counter).grp_or_name_flag  	:= 'GROUP';
      x_mgr_tbl(l_out_counter).start_date_active 	:= sibling_grp.start_date_active;
      x_mgr_tbl(l_out_counter).end_date_active   	:= sibling_grp.end_date_active;
      x_mgr_tbl(l_out_counter).level 			:= l_top_hier_tbl.COUNT;
      x_mgr_tbl(l_out_counter).image              	:= 'PLUS';
      x_mgr_tbl(l_out_counter).expand             	:= 'Y';
      --
      FOR mgr IN mgr_cur(sibling_grp.group_id,p_date)
      LOOP
         l_out_counter := l_out_counter+1;
         x_mgr_tbl(l_out_counter).cg_salesrep_name  := mgr.mgr_name;
         x_mgr_tbl(l_out_counter).cg_salesrep_id    := mgr.salesrep_id;
         x_mgr_tbl(l_out_counter).grp_or_name_flag  := 'NAME';
         x_mgr_tbl(l_out_counter).role_name         := mgr.mgr_role;
         x_mgr_tbl(l_out_counter).role_id           := mgr.mgr_role_id;
         x_mgr_tbl(l_out_counter).start_date_active := mgr.mgr_start_date;
         x_mgr_tbl(l_out_counter).end_date_active   := mgr.mgr_end_date;
      END LOOP;
      --
   END LOOP;
   l_mgr_count := x_mgr_tbl.COUNT;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count,
           p_data    =>  x_msg_data ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count,
           p_data    =>  x_msg_data,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);

END;
--
END cn_comp_grp_hier_pub;

/
