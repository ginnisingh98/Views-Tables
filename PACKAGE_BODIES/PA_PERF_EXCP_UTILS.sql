--------------------------------------------------------
--  DDL for Package Body PA_PERF_EXCP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_EXCP_UTILS" AS
/* $Header: PAPEUTLB.pls 120.1 2005/08/19 16:40:11 mwasowic noship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

	Procedure get_kpa_color_indicator_list
	(
	  p_object_type in varchar2
	, p_object_id in number
	, p_kpa_codes  in SYSTEM.PA_VARCHAR2_30_TBL_TYPE
	, x_indicators  out NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE --File.Sql.39 bug 4440895
	, x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	, x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
	, x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	, x_ind_meaning  out NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE  --Added for bug 4064923 --File.Sql.39 bug 4440895
	 ) IS

	    l_return_code           varchar2(200);


	    l_meaning VARCHAR2(80);
	    l_icon VARCHAR2(150);



	     CURSOR get_indicator (l_kpa_code IN VARCHAR2)
	       IS
		  SELECT meaning, attribute1
		    FROM pa_perf_kpa_summary ppks, pa_perf_kpa_summary_det ppksd,
		    pa_lookups pl
		    WHERE
		    ppks.object_type = p_object_type
		    AND ppks.object_id = p_object_id
		    AND ppks.current_flag = 'Y'
		    AND ppks.kpa_summary_id = ppksd.kpa_summary_id
		    AND ppksd.kpa_code = l_kpa_code
		    AND pl.lookup_type = 'PA_PERF_INDICATORS'
		    AND pl.lookup_code = ppksd.indicator_code
		    ;

	     CURSOR
	       get_overall_indicator
	       IS
		  SELECT meaning, attribute1
		    FROM pa_perf_kpa_summary ppks,
		    pa_lookups pl
		    WHERE
		    ppks.object_type = p_object_type
		    AND ppks.object_id = p_object_id
		    AND ppks.current_flag = 'Y'
		    AND pl.lookup_type = 'PA_PERF_INDICATORS'
		    AND pl.lookup_code = ppks.perf_status_code
		    ;

	BEGIN

	   x_return_status := FND_API.G_RET_STS_SUCCESS;

	   x_indicators := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
	   x_ind_meaning := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();	     --Added for bug 4064923
	   x_indicators.extend(p_kpa_codes.count);
	   x_ind_meaning.extend(p_kpa_codes.count);                  --Added for bug 4064923
	   pa_security_pvt.check_user_privilege(x_ret_code      => l_return_code,
						  x_return_status  => x_return_status,
						  x_msg_count      => x_msg_count,
						  x_msg_data       => x_msg_data,
						  p_privilege      => 'PA_PERF_EXCEPTIONS',
						  p_object_name    => p_object_type,
						  p_object_key     => p_object_id);



	   IF l_return_code <> fnd_api.g_true THEN
	      RETURN;


	    ELSE

	      --x_indicators.DELETE;

	      FOR  i IN p_kpa_codes.first..p_kpa_codes.last LOOP
		 IF p_kpa_codes(i) <> 'STATUS' THEN

		    OPEN get_indicator(p_kpa_codes(i));
		    FETCH get_indicator  INTO l_meaning, l_icon;

		    IF (get_indicator%found) THEN

		       /* Commented for bug# 4169188
		       x_indicators(i) :=  '<a href="OA.jsp?page=/oracle/apps/pa/excp/webui/ExceptionListPG&akRegionApplicationId=275&paKPACode='
			 || p_kpa_codes(i) || '&paProjectId=' || p_object_id
		      || '"><p align="center"><img ALT="'|| l_meaning || '" src="/OA_MEDIA/'
			 || l_icon ||'" border="0" align="middle"></p></a> ';	--Changed for bug# 3841535*/
		       x_indicators(i) := l_icon;   --added for bug# 4169188
		       x_ind_meaning(i) :=	l_meaning;	  --Added for bug 4064923
		     ELSE

		       x_indicators(i) := NULL;
		       x_ind_meaning(i) := NULL;                  --Added for bug 4064923
		    END IF;

		    CLOSE get_indicator;


		  ELSE
		    --- get overall status indicator

		    OPEN get_overall_indicator;
		    FETCH get_overall_indicator  INTO l_meaning, l_icon;

		    IF (get_overall_indicator%found) THEN

		       /* Commented for bug# 4169188
		       x_indicators(i) :=  '<a href="OA.jsp?akRegionCode=PA_PROJECT_HOME_LAYOUT&addBreadCrumb=RS&OAPB=PA_BRAND&akRegionApplicationId=275'
			 || '&paProjectId=' || p_object_id
		      || '"><p align="center"><img ALT="'|| l_meaning || '" src="/OA_MEDIA/'
			 || l_icon ||'" border="0" align="middle"></p></a> ';	   --Changed for bug# 3841535*/
		       x_indicators(i) := l_icon; --added for bug# 4169188

		       x_ind_meaning(i) :=	l_meaning;        --Added for bug 4064923
		     ELSE

		       x_indicators(i) := NULL;
		       x_ind_meaning(i) := NULL;	          --Added for bug 4064923
		    END IF;
		    CLOSE get_overall_indicator;
		 END IF;

	      END LOOP;



	   END IF;

	EXCEPTION
	   WHEN OTHERS THEN
	      	      --
	      -- Set the excetption Message and the stack
	      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PERF_EXCP_UTILS.get_kpa_name_list'
					,p_procedure_name => PA_DEBUG.G_Err_Stack );
	      --
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


	END;


	Procedure get_kpa_name_list
	(
	 p_kpa_codes  in SYSTEM.PA_VARCHAR2_30_TBL_TYPE
	 , x_kpa_names  out NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE --File.Sql.39 bug 4440895
	 , x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	 , x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
	 , x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	 )  IS

	    CURSOR get_kpa_name (l_kpa_code IN VARCHAR2)
	      IS
		 SELECT meaning
		   FROM pa_lookups pl
		   WHERE  pl.lookup_code = l_kpa_code
		   AND pl.lookup_type = 'PA_PERF_KEY_AREAS'
		   AND pl.enabled_flag = 'Y' ;

	    CURSOR get_kpa_count IS
	      SELECT COUNT(*) FROM pa_lookups
	      WHERE lookup_type = 'PA_PERF_KEY_AREAS'
		AND lookup_code <> 'ALL';

	    l_count NUMBER;


	BEGIN

	   x_return_status := FND_API.G_RET_STS_SUCCESS;

	   x_kpa_names := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();

	   x_kpa_names.extend(p_kpa_codes.count);

	   FOR  i IN p_kpa_codes.first..p_kpa_codes.last loop
	      OPEN get_kpa_name(p_kpa_codes(i));
	      FETCH get_kpa_name INTO x_kpa_names(i);
	      IF get_kpa_name%notfound THEN
		 x_kpa_names(i) := NULL;
	      END IF;

	      CLOSE get_kpa_name;

	   END LOOP;


	EXCEPTION
	   WHEN OTHERS THEN
	      	      --
	      -- Set the excetption Message and the stack
	      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PERF_EXCP_UTILS.get_kpa_name_list'
					,p_procedure_name => PA_DEBUG.G_Err_Stack );
	      --
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	END;


	Function get_kpa_color_indicator
	(
	  p_object_type in varchar2
	  ,p_object_id in number
	  , p_kpa_code in varchar2
	  ) return VARCHAR2
	  IS

	     l_ret VARCHAR2(1);
	     l_meaning VARCHAR2(80);
	     l_icon VARCHAR2(150);
	     x_indicator VARCHAR2(2000) := null;

	     CURSOR get_indicator
	       IS
		  SELECT meaning, attribute1
		    FROM pa_perf_kpa_summary ppks, pa_perf_kpa_summary_det ppksd,
		    pa_lookups pl
		    WHERE
		    ppks.object_type = p_object_type
		    AND ppks.object_id = p_object_id
		    AND ppks.current_flag = 'Y'
		    AND ppks.kpa_summary_id = ppksd.kpa_summary_id
		    AND ppksd.kpa_code = p_kpa_code
		    AND pl.lookup_type = 'PA_PERF_INDICATORS'
		    AND pl.lookup_code = ppksd.indicator_code
		    ;

	BEGIN


	   l_ret := pa_security_pvt.check_user_privilege(
						p_privilege => 'PA_PERF_EXCEPTIONS',
						p_object_name => p_object_type,
							 p_object_key => p_object_id);


	   IF l_ret <> fnd_api.g_true THEN

	      RETURN NULL;

	   END IF;


	   OPEN get_indicator;
	   FETCH get_indicator INTO l_meaning, l_icon;
	   IF (get_indicator%found) THEN
	      x_indicator :=
	        '<a href="OA.jsp?page=/oracle/apps/pa/excp/webui/ExceptionListPG&akRegionApplicationId=275&paKPACode='
		|| p_kpa_code || '&paProjectId=' || p_object_id ||
		'"><img ALT="'|| l_meaning || '" src="/OA_MEDIA/' || l_icon
		||'" border="0" align="middle"></a> ';
	      ELSE
	      x_indicator := NULL;

	   END IF;

	   CLOSE get_indicator;

	   RETURN x_indicator;


	END;



	Function get_measure_indicator
	(
	  p_object_type in varchar2
	  ,p_object_id in number
	  ,p_measure_id in number
       	 ,p_period_type in varchar2 DEFAULT NULL
	  ,p_period_name in VARCHAR2 DEFAULT NULL
	  ,p_raw_text_flag in VARCHAR2 DEFAULT 'Y'
	  ,x_perf_txn_id out NOCOPY NUMBER --File.Sql.39 bug 4440895
	  ,x_excp_meaning out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	  ) return VARCHAR2
	  IS

	     l_meaning VARCHAR2(80);
	     l_icon VARCHAR2(150);
	     l_flag VARCHAR2(1);
	     l_tran_id NUMBER;
	     l_indicator VARCHAR2(2000) := null;

	     CURSOR get_indicator
	       IS
		  SELECT
		    meaning, attribute1, ppt.perf_txn_id, ppt.exception_flag
		    FROM pa_perf_transactions ppt, pa_lookups pl
		    WHERE
		    ppt.perf_txn_obj_type = p_object_type
		    AND ppt.perf_txn_obj_id = p_object_id
		    AND ppt.period_type = Nvl(p_period_type, ppt.period_type)
		    AND nvl(ppt.period_name, '-9999')
		    = Nvl(p_period_name, '-9999')
		    AND ppt.measure_id = p_measure_id
		    AND ppt.current_flag = 'Y'
		    AND ppt.indicator_code = pl.lookup_code
		    AND pl.lookup_type = 'PA_PERF_INDICATORS'
		    AND ROWNUM = 1
		    ;

	     l_ret VARCHAR2(1);


	BEGIN

	   l_ret := pa_security_pvt.check_user_privilege(
						p_privilege => 'PA_PERF_EXCEPTIONS',
						p_object_name => p_object_type,
							 p_object_key => p_object_id);

	   IF l_ret <> fnd_api.g_true THEN

	      RETURN NULL;

	   END IF;



	   OPEN get_indicator;

	   FETCH get_indicator INTO l_meaning, l_icon, l_tran_id, l_flag;

	   IF get_indicator%notfound THEN

	      l_indicator := NULL;
	   ELSE
              x_perf_txn_id := l_tran_id;
              x_excp_meaning := l_meaning;

	      IF l_flag = 'N' THEN
		 l_indicator :=
		'<img ALT="'|| l_meaning || '" src="/OA_MEDIA/' || l_icon
		   ||'" border="0" align="middle"> ';
		 x_perf_txn_id := NULL;  -- Added for bug# 3979802
	       ELSE
		 if p_raw_text_flag = 'Y' then
		      l_indicator :=
			'<a href="OA.jsp?page=/oracle/apps/pa/excp/webui/ExceptionDetailsPG&akRegionApplicationId=275&paPerfTransId='
			|| l_tran_id || '&paProjectId=' || p_object_id ||
			'"><img ALT="'|| l_meaning || '" src="/OA_MEDIA/' || l_icon
			||'" border="0" align="middle"></a> ';

 		 else
		      l_indicator :=
			'<img ALT="'|| l_meaning || '" src="/OA_MEDIA/' || l_icon
			   ||'" border="0" align="middle"> ';

	  	 end if;

	      END IF;
	   END IF;

	   CLOSE get_indicator;

	   RETURN l_indicator;

	END;


	Function get_measure_indicator_list
	(
	  p_object_type in varchar2
	  ,p_object_id in number
	  ,p_measure_id in SYSTEM.PA_NUM_TBL_TYPE
	  ,p_period_type in varchar2 DEFAULT NULL
	  ,p_period_name in VARCHAR2 DEFAULT NULL
	  ,p_raw_text_flag in VARCHAR2 DEFAULT 'Y'
	  ,x_perf_txn_id out NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
	  ,x_excp_meaning out NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE --File.Sql.39 bug 4440895
	  ) return SYSTEM.pa_varchar2_2000_tbl_type

	  IS

	     l_meaning VARCHAR2(80);
	     l_icon VARCHAR2(150);
	     l_tran_id NUMBER;
	     l_flag VARCHAR2(1);
	     l_meaning_tbl   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
	     l_icon_tbl      SYSTEM.pa_varchar2_2000_tbl_type;
	     l_perf_txn_id_tbl 	    SYSTEM.PA_NUM_TBL_TYPE;
	     l_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
	     l_meaure_id_tbl  SYSTEM.PA_NUM_TBL_TYPE;
	     l_indicators SYSTEM.pa_varchar2_2000_tbl_type;

	     CURSOR get_indicator (l_measure_id IN NUMBER)
	       IS
		  SELECT
		    meaning, attribute1, ppt.perf_txn_id, ppt.exception_flag
		    FROM pa_perf_transactions ppt, pa_lookups pl
		    WHERE
		    ppt.perf_txn_obj_type = p_object_type
		    AND ppt.perf_txn_obj_id = p_object_id
		    AND ppt.period_TYPE = Nvl(p_period_type, ppt.period_type)
		    AND nvl(ppt.period_name, '-9999')
		    = Nvl(p_period_name, '-9999')
		    AND ppt.measure_id = (l_measure_id)
		    AND ppt.current_flag = 'Y'
		    AND ppt.indicator_code = pl.lookup_code
		    AND pl.lookup_type = 'PA_PERF_INDICATORS'
		    AND ROWNUM = 1
		    ;

	      CURSOR get_measure_index(l_measure_id IN NUMBER)
	      IS
	        SELECT measure_index
		FROM   PA_PERF_EXCP_MSR_TEMP
		WHERE measure_id= l_measure_id;

	      l_ret VARCHAR2(1);
	      j   BINARY_INTEGER;
	BEGIN


	   l_ret := pa_security_pvt.check_user_privilege(
						p_privilege => 'PA_PERF_EXCEPTIONS',
						p_object_name => p_object_type,
							 p_object_key => p_object_id);

	   IF l_ret <> fnd_api.g_true THEN

	      RETURN NULL;

	   END IF;


	   l_indicators := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();

	   l_indicators.extend(p_measure_id.count);

           /* Code added for bug#3894113, starts here */

           x_perf_txn_id := SYSTEM.PA_NUM_TBL_TYPE();
           x_perf_txn_id.extend(p_measure_id.count);

           x_excp_meaning := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
           x_excp_meaning.extend(p_measure_id.count);

           /* Code added for bug#3894113, ends here */

	   /*
	     Code fix for BUG#:4053713 starts
	     For perfmance issue now using a global temporary table PA_PERF_EXCP_MSR_TEMP
	     In this table we are storing the measure ids and their corresponding index in
	     the table type parameter p_measure_id.
	     This is required for using the bulk fetch instead of the cursor get_indicator
	   */

           --Purging the previous data from PA_PERF_EXCP_MSR_TEMP, if any
	   delete from PA_PERF_EXCP_MSR_TEMP;

	   --Inserting the measure id and thier corresponding index in p_measure_id parameter in the temporary table
           FOR i IN p_measure_id.FIRST..p_measure_id.LAST LOOP
           INSERT INTO PA_PERF_EXCP_MSR_TEMP(measure_index,measure_id)
 	   VALUES(to_number(i),p_measure_id(i));
	   END LOOP;

	   -- Executing the bulk fetch query to get the indicators icon
	   SELECT meaning, attribute1, ppt.perf_txn_id, ppt.exception_flag,ppt.measure_id
	   BULK COLLECT INTO  l_meaning_tbl, l_icon_tbl, l_perf_txn_id_tbl, l_flag_tbl,l_meaure_id_tbl
           FROM pa_perf_transactions ppt, pa_lookups pl
	   WHERE ppt.perf_txn_obj_type = p_object_type
           AND ppt.perf_txn_obj_id = p_object_id
	   AND ppt.period_TYPE = Nvl(p_period_type, ppt.period_type)
	   AND nvl(ppt.period_name, '-9999')
	       = Nvl(p_period_name, '-9999')
	   AND ppt.measure_id in (select measure_id from PA_PERF_EXCP_MSR_TEMP)
	   AND ppt.current_flag = 'Y'
	   AND ppt.indicator_code = pl.lookup_code
	   AND pl.lookup_type = 'PA_PERF_INDICATORS'
	   ;

	   if  l_meaure_id_tbl.count > 0 then
	   FOR  k IN l_meaure_id_tbl.FIRST..l_meaure_id_tbl.LAST loop

	       --Fetching the index of the measure_id in the parameter p_measure_id
	       --which we have stored in the PA_PERF_EXCP_MSR_TEMP.MEASURE_INDEX
	       --This is required as we need to l_indicators the icon name corresponding to the measure
	       --in l_indicators at the same index as the index of the measure id in the input parameter p_measure_id
	       open get_measure_index(l_meaure_id_tbl(k));
	       fetch get_measure_index into j;
	       close get_measure_index;

	       x_perf_txn_id(j) := l_perf_txn_id_tbl(k);
               x_excp_meaning(j) := l_meaning_tbl(k);

	       if l_flag_tbl(k) = 'N' then
	          if p_raw_text_flag = 'Y' then
		      l_indicators(j) :='<img ALT="'|| l_meaning_tbl(k) || '" src="/OA_MEDIA/' ||l_icon_tbl(k)||'" border="0" align="middle"> ';
                  else
		      l_indicators(j) := l_icon_tbl(k); -- Added for bug# 3922850
  	          end if;
		  x_perf_txn_id(j) := NULL;  -- Added for bug# 3979802
	       else
	         if p_raw_text_flag = 'Y' then
		    l_indicators(j) :=
			   '<img ALT="'|| l_meaning_tbl(k) || '" src="/OA_MEDIA/' || l_icon_tbl(k)
			   ||'" border="0" align="middle">';
                 else
		    l_indicators(j) := l_icon_tbl(k);   -- Added for bug# 3922850

                 end if;
	       end if;

	   end loop;
	   end if;

/*  Commented the lines below for bug# 4053713
    Since now bulk fetch is being used instead of the cursor get_indicator query*/
--	   FOR  i IN p_measure_id.first..p_measure_id.last loop
--	      OPEN get_indicator(p_measure_id(i));
--	      FETCH get_indicator INTO l_meaning, l_icon, l_tran_id,  l_flag;
--
--	      IF get_indicator%notfound THEN
--
--		 l_indicators(i) := NULL;
--	       ELSE
--                 x_perf_txn_id(i) := l_tran_id;
--                 x_excp_meaning(i) := l_meaning;

--		 IF l_flag = 'N' THEN
--		    -- Added the below if condition for bug 3979906
--		    if p_raw_text_flag = 'Y' then
--		    -- Commented for bug# 3922850
--		      l_indicators(i) := 	'<img ALT="'|| l_meaning || '" src="/OA_MEDIA/' ||l_icon||'" border="0" align="middle"> ';
--                   else
--                     l_indicators(i) := l_icon; -- Added for bug# 3922850
--		    end if;
--		    x_perf_txn_id(i) := NULL;  -- Added for bug# 3979802
--		 ELSE
--		   if p_raw_text_flag = 'Y' then
--		            -- Commented for bug# 3922850
--			    /*l_indicators(i) :=
--			   '<a href="OA.jsp?page=/oracle/apps/pa/excp/webui/ExceptionDetailsPG&akRegionApplicationId=275&paPerfTransId='
--			   || l_tran_id || '&paProjectId=' || p_object_id ||
--			   '"><img ALT="'|| l_meaning || '" src="/OA_MEDIA/' || l_icon
--			   ||'" border="0" align="middle"></a> ';*/
--
--			   -- Added for bug# 3922850
--			   l_indicators(i) :=
--			   '<img ALT="'|| l_meaning || '" src="/OA_MEDIA/' || l_icon
--			   ||'" border="0" align="middle">';
--                  else
--		           -- Commented for bug# 3922850
--			    /*l_indicators(i) :=
--			'<img ALT="'|| l_meaning || '" src="/OA_MEDIA/' || l_icon
--			   ||'" border="0" align="middle"> ';*/
--
--			   l_indicators(i) := l_icon;   -- Added for bug# 3922850
--
--                 end if;
--		 END IF;


--	      END IF;

--	      CLOSE get_indicator;


--	   END LOOP;

/*    End of code changes for BUG# 4053713  */


	   RETURN l_indicators;

	END;


Procedure copy_object_rule_assoc
         ( p_from_object_type in  varchar2
          ,p_from_object_id   in  number
          ,p_to_object_type   in  varchar2
          ,p_to_object_id     in  number
          ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_return_status    OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  CURSOR perf_score_rules IS
   SELECT Object_rule_id,
	  Object_type,
	  Object_id,
	  rule_id
     FROM pa_perf_object_rules
    WHERE object_type = p_from_object_type
      AND object_id = p_from_object_id;

  l_object_rule_id  NUMBER;
  l_rowid           ROWID;
BEGIN

   PA_DEBUG.init_err_stack('PA_PERF_EXCP_UTILS.copy_object_rule_assoc');
   x_return_status:=fnd_api.g_ret_sts_success;

   savepoint copy_object_rule_assoc;

   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
       -- Insert the perf/score rules for the new object

     FOR c_rec in perf_score_rules LOOP

        select PA_PERF_OBJECT_RULES_S1.nextval into l_object_rule_id from dual;

        PA_PERF_OBJECT_RULES_PKG.insert_row(
          X_ROWID => l_rowid,
          X_OBJECT_RULE_ID => l_object_rule_id,
          X_OBJECT_TYPE => P_TO_OBJECT_TYPE,
          X_OBJECT_ID => P_TO_OBJECT_ID,
          X_RULE_ID => c_rec.RULE_ID,
          X_RECORD_VERSION_NUMBER => 1,
          X_CREATION_DATE => sysdate,
          X_CREATED_BY => fnd_global.user_id,
          X_LAST_UPDATE_DATE => sysdate,
          X_LAST_UPDATED_BY => fnd_global.user_id,
          X_LAST_UPDATE_LOGIN => fnd_global.login_id);

     END LOOP;

   END IF;

  PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
    WHEN OTHERS THEN
          ROLLBACK TO copy_object_rule_assoc;
          FND_MSG_PUB.add_exc_msg ( p_pkg_name    => 'PA_PERF_EXCP_UTILS.copy_object_rule_assoc',
                                    p_procedure_name => PA_DEBUG.G_Err_Stack );

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END copy_object_rule_assoc;


Procedure delete_object_exceptions
          ( p_object_type     in  varchar2
           ,p_object_id       in  number
           , x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           , x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           , x_return_status  OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

BEGIN

   PA_DEBUG.init_err_stack('PA_PERF_EXCP_UTILS.delete_object_exceptions');
   x_return_status:=fnd_api.g_ret_sts_success;

   savepoint delete_object_exceptions;

   delete pa_perf_object_rules
    where object_type = p_object_type
      and object_id = p_object_id;


   delete pa_perf_kpa_trans
    where perf_txn_id in (select perf_txn_id from pa_perf_transactions
                           where project_id = p_object_id)
      and kpa_summary_det_id in (select kpa_summary_det_id from pa_perf_kpa_summary_det
                                  where object_type = p_object_type
                                    and object_id = p_object_id);

   delete pa_perf_kpa_summary_det
    where object_type = p_object_type
      and object_id = p_object_id;

   delete pa_perf_kpa_summary
    where object_type = p_object_type
      and object_id = p_object_id;

   delete pa_perf_comments
    where perf_txn_id in (select perf_txn_id from pa_perf_transactions
                           where project_id = p_object_id);

   delete pa_perf_transactions
    where project_id = p_object_id;

  PA_DEBUG.Reset_Err_Stack;

EXCEPTION
    WHEN OTHERS THEN
          ROLLBACK TO delete_object_exceptions;
          FND_MSG_PUB.add_exc_msg ( p_pkg_name    => 'PA_PERF_EXCP_UTILS.copy_object_rule_assoc',
                                    p_procedure_name => PA_DEBUG.G_Err_Stack );

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END delete_object_exceptions;


	  Procedure start_exception_engine
	    (
				   p_project_id in NUMBER DEFAULT NULL
				   ,p_generate_exceptions   IN      VARCHAR2 DEFAULT 'Y'
				   ,p_generate_scoring      IN      VARCHAR2 DEFAULT 'Y'
				   ,p_generate_notification IN      VARCHAR2 DEFAULT 'N'
				   ,p_purge                 IN      VARCHAR2 DEFAULT 'N'
				   ,p_daysold               IN      NUMBER   DEFAULT NULL
				   ,x_request_id     OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
				   ,x_msg_count      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
				   ,x_msg_data       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				   ,x_return_status  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				   )
	    IS

	       v_err_msg VARCHAR2(1000);

	  BEGIN

	     x_return_Status := FND_API.g_ret_sts_success;


	      x_request_id := FND_REQUEST.submit_request
             (application                =>   'PA',
              program                    =>   'PAPFEXCP',
              description                =>   '',
              start_time                 =>   '',
              sub_request                =>   false,
              argument1                  =>   NULL,
              argument2                  =>   NULL,
              argument3                  =>   NULL,
              argument4                  =>   NULL,
              argument5                  =>   p_project_id,
              argument6                  =>   p_project_id,
              argument7                  =>   p_generate_exceptions,
	      argument8                  =>   p_generate_scoring,
	      argument9                  =>   p_generate_notification,
	      argument10                  =>  p_purge,
	      argument11                  =>  p_daysold
	      );


	      IF x_request_id = 0 then
		 IF P_PA_DEBUG_MODE = 'Y' THEN
		    PA_DEBUG.g_err_stage := 'Error while submitting Request [PAPFEXCP]';
		    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
		 END IF;
		 fnd_message.retrieve(v_err_msg);

		 PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
				       p_msg_name       => 'PA_PERF_EXCP_UTILS');
		 x_return_status := FND_API.G_RET_STS_ERROR;

		 PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_EXCP_REQUEST_FAILURE',
				p_token1         => 'PA_SYS_ERR',
                                p_value1         =>  v_err_msg
				);

		 ROLLBACK;
		 RETURN;
	       ELSE
		 COMMIT;

		   PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_EXCP_REQUEST_SUCCESS',
                                p_token1         => 'REQUEST_ID',
                                p_value1         =>  x_request_id
				);

	      END IF;


	  EXCEPTION
	     WHEN OTHERS THEN
		FND_MSG_PUB.add_exc_msg(
					p_pkg_name => 'PA_PERF_EXCP_UTILS.start_exception_engine'
					,p_procedure_name => PA_DEBUG.G_Err_Stack);

		IF P_PA_DEBUG_MODE = 'Y' THEN
		   pa_debug.write_file('start_exception_engine: ' || SQLERRM);
		END IF;
		pa_debug.reset_err_stack;
		RAISE;



	  END ;


END PA_PERF_EXCP_UTILS;

/
