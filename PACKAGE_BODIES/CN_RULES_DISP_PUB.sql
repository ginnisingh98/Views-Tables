--------------------------------------------------------
--  DDL for Package Body CN_RULES_DISP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULES_DISP_PUB" AS
--$Header: cnprulb.pls 115.6 2002/11/21 21:06:23 hlchen ship $

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_RULES_DISP_PUB';
  G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnrulb.pls';
  G_LAST_UPDATE_DATE          DATE    := sysdate;
  G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
  G_CREATION_DATE             DATE    := sysdate;
  G_CREATED_BY                NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;


  PROCEDURE get_rules
    (
     p_api_version           IN  NUMBER,
     p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     x_loading_status         OUT NOCOPY VARCHAR2,

     p_ruleset_id            IN NUMBER ,
     p_parent_id             IN NUMBER ,
     p_date                  IN DATE ,
     p_start_record          IN  NUMBER := 1,
     p_increment_count       IN  NUMBER,

     x_rules_display_tbl     OUT NOCOPY  rls_dsp_tbl_type,
     x_rules_count           OUT NOCOPY NUMBER
    )


    IS

     l_api_name		CONSTANT VARCHAR2(30) := 'get_rules';
     l_api_version      CONSTANT NUMBER := 1.0;
     l_flag             NUMBER := 0;
     l_user_expression  NUMBER := 0;
     l_column_value     NUMBER;
     node_value         VARCHAR2(2000);

     -- variables 	for the lookups
     l_when            VARCHAR2(80);
     l_is_bet            VARCHAR2(80);
     l_is_not_bet            VARCHAR2(80);
     l_and            VARCHAR2(80);
     l_desc            VARCHAR2(80);
     l_not_desc            VARCHAR2(80);
     l_hier            VARCHAR2(80);

  CURSOR rules_cur1(l_parent_rule_id NUMBER, l_ruleset_id NUMBER) IS
  SELECT  0 rule_level, cnr.name rule_name, cnrc.name revenue_class,
            cnr.rule_id rule_id
         FROM cn_rules cnr, cn_revenue_classes cnrc
         WHERE cnr.rule_id = Nvl(l_parent_rule_id,-1002)
         AND   cnr.ruleset_id = Nvl(l_ruleset_id,-1002)
         AND  cnr.revenue_class_id = cnrc.revenue_class_id (+)
         AND cnr.rule_id  IN (SELECT rule_id FROM cn_rules_hierarchy);

     CURSOR rules_cur(l_parent_rule_id NUMBER, l_ruleset_id NUMBER) IS
         SELECT a.rule_level rule_level,cnr.name rule_name,
           cnrc.name revenue_class, a.rule_id rule_id
         FROM
         (
           SELECT level rule_level, rule_id, parent_rule_id, sequence_number
           FROM cn_rules_hierarchy
           WHERE ruleset_id=Nvl(l_ruleset_id,-1002)
           CONNECT BY PRIOR  rule_id =  parent_rule_id
           START WITH parent_rule_id = Nvl(l_parent_rule_id, -1002)
         )  a , cn_rules cnr, cn_revenue_classes cnrc
         WHERE  a.rule_id = cnr.rule_id
         AND cnr.ruleset_id = Nvl(l_ruleset_id,-1002)
         AND      cnr.revenue_class_id = cnrc.revenue_class_id (+);


     CURSOR expr_cur(l_rule_id NUMBER,l_ruleset_id NUMBER) IS
       SELECT cnobj.user_name object_name,
         cnh.name hierarchy_name, cnattr.column_value column_value,
         cnattr.not_flag not_flag, cnattr.high_value high_value,
         cnattr.low_value low_value , cnattr.dimension_hierarchy_id dimension_hierarchy_id
       FROM cn_attribute_rules cnattr, cn_objects cnobj,
         cn_head_hierarchies cnh
       WHERE cnattr.rule_id = l_rule_id
       AND   cnattr.ruleset_id = l_ruleset_id
       AND cnattr.column_id = cnobj.object_id (+)
       AND cnattr.dimension_hierarchy_id = cnh.head_hierarchy_id(+);




   l_record_Count  NUMBER := 0;


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

   -- Get the lookup codes


   l_when := cn_api.get_lkup_meaning('When','CLS_RULE_EXPRESSION');
   l_is_bet := cn_api.get_lkup_meaning('is_in_bet','CLS_RULE_EXPRESSION');
   l_is_not_bet := cn_api.get_lkup_meaning('is_not_in_bet','CLS_RULE_EXPRESSION');
   l_and := cn_api.get_lkup_meaning('and','CLS_RULE_EXPRESSION');
   l_desc := cn_api.get_lkup_meaning('is_decs_of','CLS_RULE_EXPRESSION');
   l_not_desc := cn_api.get_lkup_meaning('is_not_decs_of','CLS_RULE_EXPRESSION');
   l_hier := cn_api.get_lkup_meaning('in_hier','CLS_RULE_EXPRESSION');


--   l_when := ' When ';
--   l_is_bet := ' is between ';
--   l_is_not_bet := ' is not between ';
--   l_and := ' and ';
--   l_desc := ' is descendant of ' ;
--   l_not_desc := ' is not a descendent of ';
--   l_hier := ' in hierarchy ';

   x_rules_count :=0;

   FOR rules IN  rules_cur(p_parent_id,p_ruleset_id) LOOP
      l_record_count := rules_cur%ROWCOUNT;

      x_rules_count := x_rules_count + 1;

      IF (( p_increment_count = -9999) OR (x_rules_count  BETWEEN p_start_record
         AND (p_start_record + p_increment_count -1)))
      THEN
	x_rules_display_tbl(x_rules_count).rule_level :=  rules.rule_level;
	x_rules_display_tbl(x_rules_count).rule_name := rules.rule_name;
	x_rules_display_tbl(x_rules_count).rule_revenue_class :=  rules.revenue_class;

	l_flag := 0;
	l_user_expression :=0;

        -- first check if the user has created any expression
        SELECT COUNT(1)
        INTO l_user_expression
        FROM CN_RULE_ATTR_EXPRESSION
        WHERE RULE_ID = rules.rule_id ;

        IF (l_user_expression > 0) THEN

          -- for user created expressions

          SELECT DISTINCT expression
          INTO x_rules_display_tbl(x_rules_count).rule_expression
          FROM CN_ATTRIBUTE_RULES
          WHERE RULE_ID = rules.rule_id ;

        ELSE
          -- for expression not 'created' by the user
	  FOR expr IN  expr_cur(rules.rule_id,p_ruleset_id) LOOP
	    -- first decide whether this is the first expression or not.
	    IF l_flag = 0 THEN
	       x_rules_display_tbl(x_rules_count).rule_expression := ' ';
	       l_flag := 1;
	    ELSE -- not first expression, need to AND with the previous expression
	       x_rules_display_tbl(x_rules_count).rule_expression := x_rules_display_tbl(x_rules_count).rule_expression || l_and ;
	    END IF;

	    IF expr.dimension_hierarchy_id IS NOT  NULL THEN
		l_column_value := expr.column_value;
		SELECT name INTO node_value
		FROM cn_hierarchy_nodes
		WHERE value_id=l_column_value;

	      IF expr.not_flag = 'N'  THEN
		x_rules_display_tbl(x_rules_count).rule_expression :=  x_rules_display_tbl(x_rules_count).rule_expression  ||  expr.object_name || l_desc || '''' || node_value || ''''  || l_hier || '''' || expr.hierarchy_name || '''' || ' ' ;
	      ELSE
		x_rules_display_tbl(x_rules_count).rule_expression :=  x_rules_display_tbl(x_rules_count).rule_expression   ||  expr.object_name || l_not_desc ||''''||  node_value || ''''  || l_hier || '''' || expr.hierarchy_name || '''' || ' ' ;
	      END IF;

	   ELSE
	     IF expr.column_value  IS NULL THEN
	      IF expr.not_flag = 'N'  THEN
		x_rules_display_tbl(x_rules_count).rule_expression :=  x_rules_display_tbl(x_rules_count).rule_expression   ||  expr.object_name || l_is_bet ||''''|| expr.high_value || '''' || l_and  ||''''|| expr.low_value ||''''|| ' ';
	      ELSE
		x_rules_display_tbl(x_rules_count).rule_expression :=  x_rules_display_tbl(x_rules_count).rule_expression   ||   expr.object_name || l_is_not_bet || '''' || expr.high_value || '''' || l_and  || '''' || expr.low_value || '''' || ' ';
	      END IF;
	    ELSE
	      IF expr.not_flag = 'N'  THEN
		x_rules_display_tbl(x_rules_count).rule_expression := x_rules_display_tbl(x_rules_count).rule_expression   ||  expr.object_name || ' = ' ||  '''' || expr.column_value || ''''||  ' ';
	      ELSE
		x_rules_display_tbl(x_rules_count).rule_expression := x_rules_display_tbl(x_rules_count).rule_expression   ||   expr.object_name || ' <>  ' || '''' || expr.column_value ||''''|| ' ';
	      END IF;
	    END IF;
	   END IF;
	 END LOOP;

       END IF; -- this is for the user created expressions
     END IF; -- this is for the page scrolling
    END LOOP;


  if l_record_count = 0 or l_record_count is null  Then


  FOR rules IN  rules_cur1(p_parent_id,p_ruleset_id) LOOP
      l_record_count := rules_cur1%ROWCOUNT;

      x_rules_count := x_rules_count + 1;

      IF (( p_increment_count = -9999) OR (x_rules_count  BETWEEN p_start_record
         AND (p_start_record + p_increment_count -1)))
      THEN
	x_rules_display_tbl(x_rules_count).rule_level :=  rules.rule_level;
	x_rules_display_tbl(x_rules_count).rule_name := rules.rule_name;
	x_rules_display_tbl(x_rules_count).rule_revenue_class :=  rules.revenue_class;

	l_flag := 0;
	l_user_expression :=0;

        -- first check if the user has created any expression
        SELECT COUNT(1)
        INTO l_user_expression
        FROM CN_RULE_ATTR_EXPRESSION
        WHERE RULE_ID = rules.rule_id ;

        IF (l_user_expression > 0) THEN

          -- for user created expressions

          SELECT DISTINCT expression
          INTO x_rules_display_tbl(x_rules_count).rule_expression
          FROM CN_ATTRIBUTE_RULES
          WHERE RULE_ID = rules.rule_id ;

        ELSE
          -- for expression not 'created' by the user
	  FOR expr IN  expr_cur(rules.rule_id,p_ruleset_id) LOOP
	    -- first decide whether this is the first expression or not.
	    IF l_flag = 0 THEN
	       x_rules_display_tbl(x_rules_count).rule_expression := ' ';
	       l_flag := 1;
	    ELSE -- not first expression, need to AND with the previous expression
	       x_rules_display_tbl(x_rules_count).rule_expression := x_rules_display_tbl(x_rules_count).rule_expression || l_and ;
	    END IF;

	    IF expr.dimension_hierarchy_id IS NOT  NULL THEN
		l_column_value := expr.column_value;
		SELECT name INTO node_value
		FROM cn_hierarchy_nodes
		WHERE value_id=l_column_value;

	      IF expr.not_flag = 'N'  THEN
		x_rules_display_tbl(x_rules_count).rule_expression :=  x_rules_display_tbl(x_rules_count).rule_expression  ||  expr.object_name || l_desc || '''' || node_value || ''''  || l_hier || '''' || expr.hierarchy_name || '''' || ' ' ;
	      ELSE
		x_rules_display_tbl(x_rules_count).rule_expression :=  x_rules_display_tbl(x_rules_count).rule_expression   ||  expr.object_name || l_not_desc ||''''||  node_value || ''''  || l_hier || '''' || expr.hierarchy_name || '''' || ' ' ;
	      END IF;

	   ELSE
	     IF expr.column_value  IS NULL THEN
	      IF expr.not_flag = 'N'  THEN
		x_rules_display_tbl(x_rules_count).rule_expression :=  x_rules_display_tbl(x_rules_count).rule_expression   ||  expr.object_name || l_is_bet ||''''|| expr.high_value || '''' || l_and  ||''''|| expr.low_value ||''''|| ' ';
	      ELSE
		x_rules_display_tbl(x_rules_count).rule_expression :=  x_rules_display_tbl(x_rules_count).rule_expression   ||   expr.object_name || l_is_not_bet || '''' || expr.high_value || '''' || l_and  || '''' || expr.low_value || '''' || ' ';
	      END IF;
	    ELSE
	      IF expr.not_flag = 'N'  THEN
		x_rules_display_tbl(x_rules_count).rule_expression := x_rules_display_tbl(x_rules_count).rule_expression   ||  expr.object_name || ' = ' ||  '''' || expr.column_value || ''''||  ' ';
	      ELSE
		x_rules_display_tbl(x_rules_count).rule_expression := x_rules_display_tbl(x_rules_count).rule_expression   ||   expr.object_name || ' <>  ' || '''' || expr.column_value ||''''|| ' ';
	      END IF;
	    END IF;
	   END IF;
	 END LOOP;

       END IF; -- this is for the user created expressions
     END IF; -- this is for the page scrolling
    END LOOP;

end if;




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
END cn_rules_disp_pub;

/
