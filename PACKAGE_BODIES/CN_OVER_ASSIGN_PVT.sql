--------------------------------------------------------
--  DDL for Package Body CN_OVER_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OVER_ASSIGN_PVT" AS
-- $Header: cnvoasgb.pls 115.15 2003/03/20 22:13:36 sbadami ship $

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_OVER_ASSIGN_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvoasgb.pls';
G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;

TYPE quota_amount_rec_type IS RECORD
  ( quota_category_id       cn_srp_quota_cates.quota_category_id%TYPE,
    quota_amount            cn_srp_quota_cates.amount%TYPE,
    planning_amt            cn_srp_quota_cates.planning_amt%TYPE,
    prorated_amount         cn_srp_quota_cates.prorated_amount%TYPE);

TYPE quota_amount_tbl_type IS TABLE OF quota_amount_rec_type
  INDEX BY BINARY_INTEGER;

--======================================================================
--   Start of private procedure
--======================================================================
-- Procedure : add_quota
-- ========================
PROCEDURE add_quota
  (p_srp_role_id      IN NUMBER,
   p_start_date       IN DATE ,
   p_end_date         IN DATE ,
   x_quota            IN OUT NOCOPY quota_amount_tbl_type) IS

      CURSOR srp_role_info IS
	 SELECT Trunc(start_date) start_date,
	   Nvl(Trunc(end_date),p_end_date) end_date
	   FROM cn_srp_role_dtls_v
	   WHERE srp_role_id = p_srp_role_id;

      CURSOR c_quota_amount
	(c_srp_role_id  NUMBER,
	 c_quota_category_id NUMBER) IS
	    SELECT Nvl(amount,0) amount,Nvl(planning_amt,0) planning_amt,Nvl(prorated_amount,0) prorated_amount
	      FROM cn_srp_quota_cates
	      WHERE srp_role_id = c_srp_role_id
	      AND quota_category_id = c_quota_category_id;

      l_sr_start_date DATE;
      l_sr_end_date   DATE;
      l_quota_amount  cn_srp_quota_cates.amount%TYPE;
      l_planning_amt  cn_srp_quota_cates.planning_amt%TYPE;
      l_prorated_amount cn_srp_quota_cates.prorated_amount%TYPE;
BEGIN

   -- Get plan assign start/end period
   OPEN srp_role_info;
   FETCH srp_role_info INTO l_sr_start_date , l_sr_end_date;

   -- cn_qm_mgr_srp_groups(cn_srp_role) end_date cannot be null
   IF l_sr_end_date IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_QM_SR_ED_NULL');
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF srp_role_info%notfound THEN
      -- invalid srp_role_id
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE srp_role_info;

   IF x_quota.COUNT > 0 THEN
      FOR i IN x_quota.first..x_quota.last LOOP

	 OPEN c_quota_amount(p_srp_role_id,
			     x_quota(i).quota_category_id);
	 FETCH c_quota_amount INTO l_quota_amount,l_planning_amt,l_prorated_amount;

	 IF (c_quota_amount%notfound) THEN

	    -- This plan doesn't have this category
	    -- do nothing
	    NULL;

	  ELSE
	    -- add pro-rated quota
	    x_quota(i).quota_amount := x_quota(i).quota_amount
	      + Trunc((p_end_date - p_start_date + 1),0)/Trunc((l_sr_end_date - l_sr_start_date + 1),0) * l_quota_amount;
	    x_quota(i).planning_amt := x_quota(i).planning_amt
	      + Trunc((p_end_date - p_start_date + 1),0)/Trunc((l_sr_end_date - l_sr_start_date + 1),0) * l_planning_amt;
   	    x_quota(i).prorated_amount := x_quota(i).prorated_amount
	      + Trunc((p_end_date - p_start_date + 1),0)/Trunc((l_sr_end_date - l_sr_start_date + 1),0) * l_prorated_amount;
	 END IF;


	 CLOSE c_quota_amount;

      END LOOP; -- end of each quota category
   END IF;
END add_quota;

-- =======================================
-- Procedure : down_one_level
-- =======================================
PROCEDURE down_one_level
  (p_srp_id           IN NUMBER,
   p_comp_group_id    IN NUMBER,
   p_start_date       IN DATE ,
   p_end_date         IN DATE ,
   p_org_code         IN VARCHAR2,
   p_parent_direct_exist    IN NUMBER,
   x_child_street_exist     OUT NOCOPY NUMBER,
   x_quota            IN OUT NOCOPY quota_amount_tbl_type) IS

     CURSOR direct_comp_group
       (c_parent_comp_group_id NUMBER,c_start_date DATE ,c_end_date DATE ) IS
	  SELECT comp_group_id,
	    Greatest(Trunc(start_date_active), c_start_date) start_date,
	    Least(Nvl(Trunc(end_date_active),c_end_date), c_end_date) end_date
	  FROM cn_qm_group_hier
	    WHERE parent_comp_group_id = c_parent_comp_group_id
	    AND   Greatest(Trunc(start_date_active), c_start_date) <=
	    Least(Nvl(Trunc(end_date_active),c_end_date), c_end_date)
	    ;

     CURSOR direct_reps
       (c_srp_id NUMBER,c_comp_group_id NUMBER,
	c_start_date DATE ,c_end_date DATE ) IS
	   SELECT
	     msg.qm_mgr_srp_group_id ,
	     msg.srp_id,
	     msg.resource_id ,
	     msg.comp_group_id ,
	     msg.srp_role_id,
	     Greatest(Trunc(msg.start_date_active), c_start_date) start_date,
	     Least(Nvl(Trunc(msg.end_date_active),c_end_date),
		   c_end_date) end_date,
	     msg.manager_flag,
	     msg.member_flag
	     FROM
	     cn_qm_mgr_srp_groups msg
	     WHERE
	     msg.comp_group_id = c_comp_group_id
	     AND Greatest(Trunc(msg.start_date_active), c_start_date) <=
	     Least(Nvl(Trunc(msg.end_date_active),c_end_date), c_end_date)
	     AND msg.srp_id <> c_srp_id
	     ORDER BY msg.manager_flag
	     ;

     CURSOR plan_assign
       (c_srp_id NUMBER,c_start_date DATE,c_end_date DATE) IS

	  SELECT srp_role_id,
	    Greatest(c_start_date,Trunc(start_date)) start_date,
	    Least(Nvl(Trunc(end_date),c_end_date),c_end_date) end_date
	    FROM cn_srp_role_dtls_v
	    WHERE srp_id = c_srp_id
        AND role_model_id is null -- "CHANGED FOR MODELING IMPACT"
	    AND overlay_flag = 'N'
	    AND Greatest(Trunc(start_date),c_start_date) <=
	    Least(Nvl(Trunc(end_date),c_end_date),c_end_date);

     l_direct_exist   NUMBER;
     l_street_exist   NUMBER;
     l_check          NUMBER;

BEGIN

   l_direct_exist := 0;
   l_street_exist := 0;
   x_child_street_exist := 0;
   -- find all all direct comp group
   FOR eachcg IN direct_comp_group (p_comp_group_id,p_start_date,p_end_date)
     LOOP

	-- find out all directs
	FOR eachdirect IN direct_reps
	  (p_srp_id,eachcg.comp_group_id,
	   eachcg.start_date,eachcg.end_date)LOOP
	      l_check := 0;
	      BEGIN
		 SELECT 1 INTO l_check
		   FROM cn_srp_role_dtls
		   WHERE srp_role_id = eachdirect.srp_role_id
		   AND org_code = p_org_code
		   AND overlay_flag = 'N'
		   ;
	      EXCEPTION
		 WHEN no_data_found THEN
		    l_check := 0;
	      END;
	      IF (l_check = 1) THEN
		 FOR eachplan IN plan_assign
		   (eachdirect.srp_id,eachdirect.start_date,
		    eachdirect.end_date) LOOP

		       IF (eachdirect.manager_flag = 'Y') THEN
			  down_one_level(eachdirect.srp_id,
					 eachdirect.comp_group_id,
					 eachdirect.start_date,
					 eachdirect.end_date,
					 p_org_code,
				      l_direct_exist,
					 x_child_street_exist,
				      x_quota);
			  IF x_child_street_exist = 1 THEN
			     l_street_exist := 1;
			  END IF;
			ELSE
			  -- This is a street rep, add his quota to x_quota
			  -- add quota to x_quota
			  add_quota(eachplan.srp_role_id,
				    eachplan.start_date,
				    eachplan.end_date,
				    x_quota);
			  l_direct_exist := 1;
		       END IF;

		    END LOOP;
	      END IF;
	   END LOOP; -- end of eachdirect
     END LOOP; -- end of eachcg

     IF l_direct_exist = 0 AND p_parent_direct_exist = 0 THEN
	-- This is a street rep, add his quota to x_quota
	FOR eachplan IN plan_assign(p_srp_id,p_start_date,p_end_date) LOOP
	   -- add quota to x_quota
	   add_quota(eachplan.srp_role_id,
		     eachplan.start_date,
		     eachplan.end_date,
		     x_quota);
	   l_direct_exist := 1;
	END LOOP; -- End of eachplan
     END IF; -- end of street rep check

     SELECT Greatest(l_street_exist,l_direct_exist)
       INTO x_child_street_exist
       FROM dual;

END down_one_level;

--======================================================================
--   End of private procedure
--======================================================================

-- API name 	: Get_overassign
-- Type	: Public.
-- Pre-reqs	:
-- Usage	:
--
-- Desc 	:
--
--
--
-- Parameters	:
--  IN	:  p_api_version       NUMBER      Require
-- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	:  x_return_status     VARCHAR2(1)
-- 		   x_msg_count	       NUMBER
-- 		   x_msg_data	       VARCHAR2(2000)
--  IN	:  p_srp_role_id  NUMBER,     Required
--		   p_org_code          VARCHAR2,   Required
--         p_cal_field             IN  VARCHAR2,
--  OUT	:  x_quota_overassign_tbl quota_overassign_tbl_type
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_overassign
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_qm_mgr_srp_group_id   IN  NUMBER ,
    p_org_code              IN  VARCHAR2,
    x_quota_overassign_tbl  OUT NOCOPY quota_overassign_tbl_type

    ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'Get_Overassign';
     l_api_version    CONSTANT NUMBER :=1.0;

     l_counter         NUMBER(15);
     l_match           NUMBER(15);

     l_multi_mgr_cnt   NUMBER ;

     l_mgr_quota       quota_amount_tbl_type;
     l_direct_quota    quota_amount_tbl_type;
     l_street_quota    quota_amount_tbl_type;

     CURSOR c_srp_info IS

	SELECT srp_role_id,srp_id,role_id,
	  Trunc(start_date_active) start_date,
	  Trunc(end_date_active) end_date,comp_group_id ,
	  manager_flag,member_flag ,group_name
	  FROM cn_qm_mgr_srp_groups
	  WHERE qm_mgr_srp_group_id = p_qm_mgr_srp_group_id ;

     l_srp_info c_srp_info%ROWTYPE;

     -- the prorate_rate is not complete yet. Complete in the code below.
     -- because cannot join with cn_srp_role_dtls_v here for performance issue
     CURSOR mgr_srp_role_list
       (c_comp_group_id NUMBER,c_start_date DATE, c_end_date DATE) IS
	  SELECT msg.srp_role_id,
	    (Least(Nvl(Trunc(msg.end_date_active),c_end_date), c_end_date) -
	     Greatest(Trunc(msg.start_date_active), c_start_date)) prorate_rate
	    FROM cn_qm_mgr_srp_groups msg
	    WHERE msg.manager_flag = 'Y'
	    AND   msg.comp_group_id = c_comp_group_id
	    AND  Greatest(Trunc(msg.start_date_active), c_start_date) <=
	    Least(Nvl(Trunc(msg.end_date_active),c_end_date), c_end_date)
	    ;

     CURSOR  mgr_quota
       (c_srp_role_id NUMBER,c_prorate_rate NUMBER) IS
	  SELECT sqc.quota_category_id,
	    SUM(Nvl(sqc.amount,0) * c_prorate_rate) amount,
	    SUM(Nvl(sqc.planning_amt,0) * c_prorate_rate) planning_amt,
   	    SUM(Nvl(sqc.prorated_amount,0) * c_prorate_rate) prorated_amount
	    FROM cn_srp_quota_cates sqc,cn_quota_categories qc
	    WHERE sqc.quota_category_id = qc.quota_category_id
	    AND qc.TYPE = 'VAR_QUOTA'
	    AND sqc.srp_role_id = c_srp_role_id
	    GROUP BY sqc.quota_category_id
	    ;

     CURSOR direct_comp_group
       (c_parent_comp_group_id NUMBER,c_start_date DATE ,c_end_date DATE ) IS
	  SELECT comp_group_id,
	    Greatest(Trunc(start_date_active), c_start_date) start_date,
	    Least(Nvl(Trunc(end_date_active),c_end_date), c_end_date) end_date
	  FROM cn_qm_group_hier
	    WHERE parent_comp_group_id = c_parent_comp_group_id
	    AND   Greatest(Trunc(start_date_active), c_start_date) <=
	    Least(Nvl(Trunc(end_date_active),c_end_date), c_end_date)
	    ;

     CURSOR direct_reps
       (c_srp_id NUMBER,c_comp_group_id NUMBER,
	c_start_date DATE ,c_end_date DATE ) IS
	   SELECT
	     msg.qm_mgr_srp_group_id ,
	     msg.srp_id,
	     msg.resource_id ,
	     msg.comp_group_id ,
	     msg.srp_role_id,
	     Greatest(Trunc(msg.start_date_active), c_start_date) start_date,
	     Least(Nvl(Trunc(msg.end_date_active),c_end_date),
		   c_end_date) end_date,
	     msg.manager_flag,
	     msg.member_flag
	     FROM
	     cn_qm_mgr_srp_groups msg
	     WHERE
	     msg.comp_group_id = c_comp_group_id
	     AND Greatest(Trunc(msg.start_date_active), c_start_date) <=
	     Least(Nvl(Trunc(msg.end_date_active),c_end_date), c_end_date)
	     AND msg.srp_id <> c_srp_id
	     ORDER BY msg.manager_flag
	     ;

     CURSOR plan_assign
       (c_srp_id NUMBER,c_start_date DATE,c_end_date DATE) IS

	  SELECT srp_role_id,
	    Greatest(c_start_date,Trunc(start_date)) start_date,
	    Least(Nvl(Trunc(end_date),c_end_date),c_end_date) end_date
	    FROM cn_srp_role_dtls_v
	    WHERE srp_id = c_srp_id
        AND role_model_id is null -- "CHANGED FOR MODELING IMPACT"
	    AND overlay_flag = 'N'
	    AND Greatest(Trunc(start_date),c_start_date) <=
	    Least(Nvl(Trunc(end_date),c_end_date),c_end_date);

     l_direct_exist   NUMBER;
     l_street_exist   NUMBER;
     l_check          NUMBER;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version ,p_api_version ,
				       l_api_name    ,G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- get related information about this salesrep
   OPEN c_srp_info;
   FETCH c_srp_info INTO l_srp_info;

   -- cn_qm_mgr_srp_groups(cn_srp_role) end_date cannot be null
   IF l_srp_info.end_date IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_QM_SR_ED_NULL');
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF c_srp_info%notfound THEN
      -- invalid srp_role_id
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_QM_INVALID_SRPROLE');
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_srp_info;

   -- Check if this srp is manager
   IF l_srp_info.manager_flag = 'Y' THEN

      -- get manager's quota for each category
      l_counter := 0;
      -- get all manager's srp_role_id,may have multiple manager in same groip
      FOR eachmgr IN mgr_srp_role_list
	(l_srp_info.comp_group_id,
	 l_srp_info.start_date,l_srp_info.end_date) LOOP
        BEGIN
	   SELECT
	     (eachmgr.prorate_rate+1)/
	     (Nvl(Trunc(srd.end_date),l_srp_info.end_date) + 1 -
	     Trunc(srd.start_date))  prorate_rate
	     INTO eachmgr.prorate_rate
	     FROM cn_srp_role_dtls_v srd
	     WHERE srd.srp_role_id = eachmgr.srp_role_id
	     ;
	END;

	-- for each manager, get his/he quota categories
	FOR eachq IN mgr_quota
	  (eachmgr.srp_role_id,eachmgr.prorate_rate) LOOP
	     l_check := 0;
	     BEGIN
		SELECT 1 INTO l_check
		  FROM cn_srp_role_dtls
		  WHERE srp_role_id = eachmgr.srp_role_id
		  AND org_code = p_org_code
		  ;
	     EXCEPTION
		WHEN no_data_found THEN
		   l_check := 0;
	     END;
	     IF l_check = 0 THEN
		eachq.amount := 0;
		eachq.planning_amt := 0;
        eachq.prorated_amount := 0;
	     END IF;

	     l_match := 0;
	     IF l_mgr_quota.COUNT > 0 THEN
		-- build l_mgr_quota table for existing qc
		FOR i IN 0 .. l_counter-1 LOOP
		   IF l_mgr_quota(i).quota_category_id=eachq.quota_category_id
		     THEN
		      l_mgr_quota(i).quota_amount:= l_mgr_quota(i).quota_amount
			+ eachq.amount;
		      l_mgr_quota(i).planning_amt:= l_mgr_quota(i).planning_amt
			+ eachq.planning_amt;
   		      l_mgr_quota(i).prorated_amount := l_mgr_quota(i).prorated_amount
			+ eachq.prorated_amount;

		      l_match := 1;
		      EXIT WHEN l_match = 1;
		   END IF;
		END LOOP;
	     END IF;
	     -- build l_mgr_quota table for new qc
	     IF l_match = 0 THEN
		l_mgr_quota(l_counter).quota_category_id
		  := eachq.quota_category_id;
		l_mgr_quota(l_counter).quota_amount := eachq.amount;
		l_mgr_quota(l_counter).planning_amt := eachq.planning_amt;
		l_mgr_quota(l_counter).prorated_amount := eachq.prorated_amount;

		l_direct_quota(l_counter).quota_category_id
		  := eachq.quota_category_id;
		l_direct_quota(l_counter).quota_amount     := 0;
		l_direct_quota(l_counter).planning_amt     := 0;
        l_direct_quota(l_counter).prorated_amount  := 0;

		l_street_quota(l_counter).quota_category_id
		  := eachq.quota_category_id;
		l_street_quota(l_counter).quota_amount     := 0;
		l_street_quota(l_counter).planning_amt     := 0;
		l_street_quota(l_counter).prorated_amount  := 0;

		l_counter := l_counter + 1;
	     END IF;
	  END LOOP; -- end of eachq
	 END LOOP; -- end of eachmgr

	 -- check if have any srp in the same group
	 -- find out all directs
	 FOR eachdirect IN direct_reps
	   (l_srp_info.srp_id,l_srp_info.comp_group_id,
	    l_srp_info.start_date,l_srp_info.end_date)
	   LOOP
	      l_check := 0;
	      BEGIN
		 SELECT 1 INTO l_check
		   FROM cn_srp_role_dtls
		   WHERE srp_role_id = eachdirect.srp_role_id
		   AND org_code = p_org_code
		   AND overlay_flag = 'N'
		   ;
	      EXCEPTION
		 WHEN no_data_found THEN
		    l_check := 0;
	      END;
	      IF (l_check = 1) THEN
		 -- need to find out the plan types assigned to the direct for
		 -- the time reporting to this mgr
		 IF (eachdirect.member_flag = 'Y') THEN
		    FOR eachplan IN plan_assign
		      (eachdirect.srp_id,eachdirect.start_date,
		       eachdirect.end_date)
		      LOOP
			 -- add quota to l_direct_quota
			 add_quota(eachplan.srp_role_id,
				   eachplan.start_date,
				   eachplan.end_date,
				   l_direct_quota);

			 --  srp in this comp group, treat as street level
			 add_quota(eachplan.srp_role_id,
				   eachplan.start_date,
				   eachplan.end_date,
				   l_street_quota);
		      END LOOP; -- End of eachplan
		 END IF;
	      END IF;
	   END LOOP; -- End of eachdirect
	   l_street_exist := 0;
	   -- find all all direct comp group
	   FOR eachcg IN direct_comp_group
	     (l_srp_info.comp_group_id,
	      l_srp_info.start_date,l_srp_info.end_date)
	     LOOP
		l_direct_exist := 0;

		-- find out all directs
		FOR eachdirect IN direct_reps
		  (l_srp_info.srp_id,eachcg.comp_group_id,
		   eachcg.start_date,eachcg.end_date)
		  LOOP
		     l_check := 0;
	          BEGIN
		     SELECT 1 INTO l_check
		       FROM cn_srp_role_dtls
		       WHERE srp_role_id = eachdirect.srp_role_id
		       AND org_code = p_org_code
		       AND overlay_flag = 'N'
		       ;
		  EXCEPTION
		     WHEN no_data_found THEN
			l_check := 0;
		  END;
		  IF (l_check = 1) THEN
		     -- need to find out the plan types assigned to the direct
		     -- for the time reporting to this mgr

		     FOR eachplan IN plan_assign
		       (eachdirect.srp_id,eachdirect.start_date,
			eachdirect.end_date)
		       LOOP
			  IF (eachdirect.manager_flag = 'Y') THEN
			     -- add quota to l_direct_quota
			     add_quota(eachplan.srp_role_id,
				       eachplan.start_date,
				       eachplan.end_date,
				       l_direct_quota);
			     -- Need to go down to the street level
			     down_one_level(eachdirect.srp_id,
					    eachdirect.comp_group_id,
					    eachdirect.start_date,
					    eachdirect.end_date,
					    p_org_code,
					    l_direct_exist,
					    l_street_exist,
					    l_street_quota);
			   ELSE
			     --  srp in this comp group, treat as street level
			     add_quota(eachplan.srp_role_id,
				       eachplan.start_date,
				       eachplan.end_date,
				       l_street_quota);
			     l_direct_exist := 1;
			  END IF;

		       END LOOP; -- End of eachplan
		  END IF;

		  END LOOP; -- End of eachdirect
	     END LOOP; -- End of eachcg
   END IF; -- end if l_srp_info.manager_flag = 'Y'

   -- Check if this srp is street node
   IF l_srp_info.member_flag = 'Y' THEN
      -- get manager's quota for each category
      l_counter := 0;
      -- for each manager, get his/he quota categories
      FOR eachq IN mgr_quota
	(l_srp_info.srp_role_id,1) LOOP
	   l_match := 0;
	   IF l_mgr_quota.COUNT > 0 THEN
	      -- build l_mgr_quota table for existing qc
	      FOR i IN 0 .. l_counter-1 LOOP
		 IF l_mgr_quota(i).quota_category_id=eachq.quota_category_id
		   THEN
		    l_mgr_quota(i).quota_amount:= l_mgr_quota(i).quota_amount
		      + eachq.amount;
		    l_mgr_quota(i).planning_amt:= l_mgr_quota(i).planning_amt
		      + eachq.planning_amt;

              -- ************************************
              -- SUN : START ADDED FOR Sun
              -- ************************************
   		    l_mgr_quota(i).prorated_amount:= l_mgr_quota(i).prorated_amount
		      + eachq.prorated_amount;

		    l_match := 1;
		    EXIT WHEN l_match = 1;
		 END IF;
	      END LOOP;
	   END IF;
	   -- build l_mgr_quota table for new qc
	   IF l_match = 0 THEN
	      l_mgr_quota(l_counter).quota_category_id
  		:= eachq.quota_category_id;
	      l_mgr_quota(l_counter).quota_amount := eachq.amount;
	      l_mgr_quota(l_counter).planning_amt := eachq.planning_amt;
          l_mgr_quota(l_counter).prorated_amount := eachq.prorated_amount;

	      l_direct_quota(l_counter).quota_category_id
		:= eachq.quota_category_id;
	      l_direct_quota(l_counter).quota_amount     := 0;
	      l_direct_quota(l_counter).planning_amt     := 0;
          -- ************************************
          -- SUN : START ADDED FOR Sun
          -- ************************************
          l_direct_quota(l_counter).prorated_amount  := 0;

	      l_street_quota(l_counter).quota_category_id
		:= eachq.quota_category_id;
	      l_street_quota(l_counter).quota_amount     := 0;
	      l_street_quota(l_counter).planning_amt     := 0;
          -- ************************************
          -- SUN : START ADDED FOR Sun
          -- ************************************
          l_street_quota(l_counter).prorated_amount  := 0;

	      l_counter := l_counter + 1;
	   END IF;
	END LOOP; -- end of eachq
   END IF;

   -- At this point, get everything for calculating overassign
   IF l_mgr_quota.COUNT > 0 THEN
      FOR i IN l_mgr_quota.first .. l_mgr_quota.last LOOP

	 x_quota_overassign_tbl(i).quota_category_id
	   := l_mgr_quota(i).quota_category_id;

	 IF (l_mgr_quota(i).quota_amount IS NULL) OR
	   (l_mgr_quota(i).quota_amount = 0) THEN

	    x_quota_overassign_tbl(i).direct_overassign_pct := 0;
	    x_quota_overassign_tbl(i).street_overassign_pct := 0;

	  ELSE

	    x_quota_overassign_tbl(i).direct_overassign_pct :=
	      (l_direct_quota(i).quota_amount/l_mgr_quota(i).quota_amount)*
	      100;
	    x_quota_overassign_tbl(i).street_overassign_pct :=
	      (l_street_quota(i).quota_amount/l_mgr_quota(i).quota_amount)*
	      100;

	 END IF; -- end if zero check for quota amount

	 IF (l_mgr_quota(i).planning_amt IS NULL) OR
	   (l_mgr_quota(i).planning_amt = 0) THEN

	    x_quota_overassign_tbl(i).direct_pln_oasg_pct := 0;
	    x_quota_overassign_tbl(i).street_pln_oasg_pct := 0;

	  ELSE

	    x_quota_overassign_tbl(i).direct_pln_oasg_pct :=
	      (l_direct_quota(i).planning_amt/l_mgr_quota(i).planning_amt)*
	      100;
	    x_quota_overassign_tbl(i).street_pln_oasg_pct :=
	      (l_street_quota(i).planning_amt/l_mgr_quota(i).planning_amt)*
	      100;

	 END IF; -- end if zero check for planning amount

     -- ************************************
     -- SUN : START ADDED FOR Sun
     -- ************************************
	 IF (l_mgr_quota(i).prorated_amount IS NULL) OR
	   (l_mgr_quota(i).prorated_amount = 0) THEN

	    x_quota_overassign_tbl(i).direct_pro_oasg_pct := 0;
	    x_quota_overassign_tbl(i).street_pro_oasg_pct := 0;

	  ELSE

	    x_quota_overassign_tbl(i).direct_pro_oasg_pct :=
	      (l_direct_quota(i).prorated_amount/l_mgr_quota(i).prorated_amount)*
	      100;
	    x_quota_overassign_tbl(i).street_pro_oasg_pct :=
	      (l_street_quota(i).prorated_amount/l_mgr_quota(i).prorated_amount)*
	      100;

	 END IF; -- end if zero check for planning amount
      -- ************************************
      -- SUN : STOP ADDED FOR Sun
      -- ************************************

      END LOOP; -- end of each quota category
   END IF;
   -- Standard call to get message count and if count is 1 get message info.
   FND_MSG_PUB.Count_And_Get
     ( p_count   =>  x_msg_count ,
       p_data    =>  x_msg_data  ,
       p_encoded => FND_API.G_FALSE
       );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END;

END cn_over_assign_pvt;


/
