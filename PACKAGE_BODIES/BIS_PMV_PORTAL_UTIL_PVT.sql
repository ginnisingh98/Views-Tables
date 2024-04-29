--------------------------------------------------------
--  DDL for Package Body BIS_PMV_PORTAL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_PORTAL_UTIL_PVT" AS
/* $Header: BISPMVPB.pls 120.2 2006/03/31 14:57:00 serao noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.12=120.2):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPMVPB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This is the utility package for Oracle Portal                     |
REM |                                                                       |
REM | HISTORY                                                               |
REM | kiprabha	02/27/03	Initial Creation                            |
REM | ansingh	08/01/03	Delete Hanging Related Links                |
REM | nkishore	03/02/03        Get page_id based on function_id            |
REM +=======================================================================+
*/

 -- **************** GLOBAL VARIABLES *********************
g_user_id NUMBER := -1 ;


-- OA Pages
-- Added p_page_name
PROCEDURE clean_portlets (
  p_user_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
 ,p_page_id in NUMBER DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
 ,p_page_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_msg_count   OUT NOCOPY NUMBER
 ,x_msg_data    OUT NOCOPY VARCHAR2
 ,p_function_name in VARCHAR2 DEFAULT NULL -- jprabhud - 04/23/04 - Bug 3573468
)

IS

	l_schedule_id_arr BISVIEWER.t_num;
	l_ref_path_tbl BIS_PMV_PORTAL_UTIL_PVT.BIS_PMV_REF_PATH_TBL_TYPE ;
	l_return_status VARCHAR2(100) ;
	l_msg_data VARCHAR2(1000) ;
	l_msg_count NUMBER;
	l_schedule_id NUMBER ;
    	l_sched_index NUMBER := 1 ;
	l_user_id NUMBER := -1 ;
	l_page_id NUMBER := p_page_id ;
        l_page_name VARCHAR2(100);

    --Hanging Related Links -ansingh
	l_plug_id NUMBER;
	l_plugId_Array BISVIEWER.t_num;

	--Added plug_id for Hanging Related Links -ansingh, BugFix 3123327 Removed Into clause
	CURSOR c_all_schedules(p_ref_path IN VARCHAR2) IS
      SELECT  bs.schedule_id, bs.plug_id
      FROM
                       	 icx_portlet_customizations ipc,
                       	 bis_schedule_preferences bs
      WHERE
                       	 bs.plug_id = ipc.plug_id and
                       	 ipc.reference_path = p_ref_path ;

    --Added plug_id for Hanging Related Links -ansingh, BugFix 3123327 Removed Into clause
	CURSOR c_user_schedules(p_ref_path IN VARCHAR2) IS
      SELECT bs.schedule_id, bs.user_id, bs.plug_id
      FROM
                       	 icx_portlet_customizations ipc,
                       	 bis_schedule_preferences bs
      WHERE
        bs.plug_id = ipc.plug_id AND
        ipc.reference_path = p_ref_path AND
			 bs.user_id =  g_user_id ;

      --BugFix 3417849
      -- jprabhud - 04/23/04 - Bug 3573468
      CURSOR get_page_id(c_pageName IN VARCHAR2) IS
       SELECT function_id FROM fnd_form_functions
       WHERE  type ='JSP'
       AND    web_html_call = 'OA.jsp?akRegionCode=BIS_COMPONENT_PAGE&akRegionApplicationId=191'
       AND    upper(parameters) like upper(c_pageName);


BEGIN
	-- Get the FND user_id if the user_name is passed
	IF p_user_name IS NOT NULL THEN
		SELECT user_id INTO g_user_id FROM fnd_user
		WHERE user_name = p_user_name;
	END IF;

	-- Find the reference paths corresponding to p_user_name, p_page_id
	-- OA Pages enhancement
/*
	IF ((p_page_id < 0) OR (p_page_name is not null)) THEN
		IF (p_page_name IS NOT NULL) THEN
			l_page_id := get_oa_page_id( p_page_name      => p_page_name,
                                         x_return_status  => l_return_status,
                                         x_msg_count      => l_msg_count,
                                         x_msg_data       => l_msg_data
					) ;
		ELSE
			l_page_id := p_page_id ;
        END IF;
*/
       -- jprabhud - 04/23/04 - Bug 3573468
       IF ( (p_page_id IS NULL) AND (p_function_name IS NOT NULL)) THEN
          l_page_id := get_oa_page_id( p_function_name      => p_function_name,
                                         x_return_status  => l_return_status,
                                         x_msg_count      => l_msg_count,
                                         x_msg_data       => l_msg_data
					) ;
       END IF;


       --BugFix 3417849 Get page_id based on function_id
       -- jprabhud - 04/23/04 - Bug 3573468
       --IF ( (p_page_id <0) AND (p_page_name IS NULL) ) THEN
       IF ( (l_page_id <0) AND (p_page_name IS NULL) ) THEN
			--l_page_id := p_page_id ;
			get_oa_reference_paths( p_page_id        => l_page_id,
                                x_ref_path_tbl   => l_ref_path_tbl,
                                x_return_status  => l_return_status,
                                x_msg_count      => l_msg_count,
                                x_msg_data       => l_msg_data
			) ;
        ELSIF ( p_page_name IS NOT NULL) THEN
          IF (get_page_id%ISOPEN) THEN
	   CLOSE get_page_id;
          END IF;
          l_page_name := '%'||p_page_name||'%';
          open get_page_id(l_page_name);
          LOOP
            fetch get_page_id into l_page_id;
	    if get_page_id%NOTFOUND then
               CLOSE get_page_id;
            EXIT;
            end if;
            l_page_id := (-1) * l_page_id;
  	    get_oa_reference_paths( p_page_id        => l_page_id,
                                x_ref_path_tbl   => l_ref_path_tbl,
                                x_return_status  => l_return_status,
                                x_msg_count      => l_msg_count,
                                x_msg_data       => l_msg_data
				) ;
          END LOOP;

	ELSE
		get_reference_paths( p_user_name => p_user_name,
                             p_page_id => p_page_id,
                             x_ref_path_tbl => l_ref_path_tbl,
                             x_return_status  => l_return_status,
                             x_msg_count => l_msg_count,
                             x_msg_data => l_msg_data
		) ;
	END IF;

IF (l_return_status = FND_API.G_RET_STS_ERROR OR l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := l_return_status ;
		x_msg_count := l_msg_count ;
		x_msg_data := l_msg_data ;
      RETURN;
    ELSE
	-- Do a bulk operation here

	IF l_ref_path_tbl.COUNT > 0 THEN

	FOR i in l_ref_path_tbl.FIRST..l_ref_path_tbl.LAST LOOP
			IF (p_user_name is null)  THEN
				IF (c_all_schedules%ISOPEN) THEN
					CLOSE c_all_schedules;
				END IF;
	   FOR l_sched in c_all_schedules(l_ref_path_tbl(i).ref_path) LOOP

 	     BEGIN

		l_schedule_id := l_sched.schedule_id ;
                    IF l_schedule_id IS NOT NULL THEN
            		l_schedule_id_arr(l_sched_index) := l_schedule_id ;
					  l_plugId_Array(l_sched_index) := l_sched.plug_id;			--hanging related links
            		l_sched_index := l_sched_index + 1 ;
                    END IF;
             EXCEPTION
            	WHEN OTHERS THEN
					    NULL;
             END ;

	    END LOOP ;
	         ELSE   --user_id is not null
	           IF (c_user_schedules%ISOPEN) THEN
			     CLOSE c_user_schedules;
	           END IF;
	  FOR l_sched in c_user_schedules(l_ref_path_tbl(i).ref_path) LOOP

	   BEGIN
                   IF (l_sched.schedule_id is not null AND l_sched.user_id = g_user_id)  then
           	l_schedule_id_arr(l_sched_index) := l_sched.schedule_id ;
					 l_plugId_Array(l_sched_index) := l_sched.plug_id;			--hanging related links
            	l_sched_index := l_sched_index + 1 ;
                   END IF;
           EXCEPTION
            	WHEN OTHERS THEN
               	       NULL;
           END ;

	  END LOOP ;
	         END IF;
	END LOOP ; /* Reference Path loop */

	-- Need to take care of the situation where
	-- the result of this query is a large set
	IF l_schedule_id_arr.COUNT > 0 THEN
		  bulk_delete_schedules (p_schedule_ids => l_schedule_id_arr) ;
		  bulk_delete_attributes (p_schedule_ids => l_schedule_id_arr, p_page_id => l_page_id);
    END IF;
    	--hanging related links
    IF l_plugId_Array.COUNT > 0 THEN
    		DELETE_HANGING_RELATED_LINKS(pUserId=>g_user_id, pPlugIdArray=>l_plugId_Array);
	END IF ;


	-- Fix for bug 3006533
	-- Update the caching_key in icx_portlet_customizations

	FOR k in l_ref_path_tbl.FIRST..l_ref_path_tbl.LAST LOOP

		BIS_PMV_UTIL.stale_portlet_by_refPath(l_ref_path_tbl(k).ref_path) ;

	END LOOP ;

	COMMIT ;

	END IF ; -- IF l_ref_path.COUNT > 0

	END IF ; -- return_status is not error


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

END clean_portlets ;



FUNCTION get_oa_page_id (
  p_page_name in VARCHAR2 DEFAULT NULL
 , p_function_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_msg_count   OUT NOCOPY NUMBER
 ,x_msg_data    OUT NOCOPY VARCHAR2
) RETURN NUMBER
is

	l_menu_id NUMBER;
	l_page_id NUMBER;
	l_return_status VARCHAR2(100) ;
	l_msg_data VARCHAR2(1000) ;
	l_msg_count NUMBER;
	-- jprabhud - 04/23/04 - Bug 3573468
	l_function_id NUMBER;


BEGIN

        -- jprabhud - 04/23/04 - Bug 3573468
        IF (p_function_name is null) THEN
	  select menu_id
	  into l_menu_id
	  from fnd_menus
	  where menu_name = p_page_name ;

	  l_page_id := (-1) * l_menu_id ;

	ELSE
	  select function_id into l_function_id
	  from fnd_form_functions
	  where function_name = p_function_name;

	  l_page_id := (-1) * l_function_id;
	END IF;




	return l_page_id ;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

END get_oa_page_id ;

PROCEDURE bulk_delete_schedules
(
  p_schedule_ids IN BISVIEWER.t_num
)

IS
BEGIN
	IF p_schedule_ids.COUNT > 0 THEN

		IF (g_user_id = -1) OR (g_user_id IS NULL) THEN

			FORALL i in p_schedule_ids.FIRST..p_schedule_ids.LAST
			delete from bis_schedule_preferences
			where schedule_id = p_schedule_ids(i) ;

			FORALL i in p_schedule_ids.FIRST..p_schedule_ids.LAST
			delete from bis_scheduler
			where schedule_id = p_schedule_ids(i) ;
		ELSE

			FORALL i in p_schedule_ids.FIRST..p_schedule_ids.LAST
			delete from bis_schedule_preferences
			where schedule_id = p_schedule_ids(i)
			and user_id = g_user_id;

			FORALL i in p_schedule_ids.FIRST..p_schedule_ids.LAST
			delete from bis_scheduler
			where schedule_id = p_schedule_ids(i)
			and user_id = g_user_id;

		END IF ;

	END IF ;

-- I believe we should not have any EXCEPTION blocks
-- to ensure that either all the actions are completed or
-- none at all

END bulk_delete_schedules ;


-- OA Pages : added p_page_id
-- Delete schedule records as well as page-level records
PROCEDURE bulk_delete_attributes (p_schedule_ids IN BISVIEWER.t_num,
																	p_page_id IN NUMBER)

IS
BEGIN
	IF p_schedule_ids.COUNT > 0 THEN
		IF (g_user_id = -1) OR (g_user_id IS NULL)  THEN
			FORALL i in p_schedule_ids.FIRST..p_schedule_ids.LAST
        -- split this for bug 5130341
        delete from bis_user_attributes
        where schedule_id = p_schedule_ids(i) ;

        delete from bis_user_attributes
        where page_id = p_page_id
        and user_id > -2; --to use the index
		ELSE
			FORALL i in p_schedule_ids.FIRST..p_schedule_ids.LAST
        -- split this for bug 5130341
        delete from bis_user_attributes
        where
          (schedule_id = p_schedule_ids(i)
          and user_id = g_user_id);

         delete from bis_user_attributes
         where
          (page_id = p_page_id
          and user_id = g_user_id) ;

		END IF ;
	END IF ;

END bulk_delete_attributes ;

-- Note : 1. 	USER_ID IN wwpob_portlet_instance$ IS ACTUALLY THE USER_NAME
-- 		IN FND_USER
--        2. 	This procedure has a PORTAL dependency. On the long run,
--		this should be replaced by a centralized BIA API that will
--		access the Portal schema
	-- Fix for bug 3006533
        -- Check for p_user_name
PROCEDURE get_reference_paths(
  p_user_name IN VARCHAR2
 ,p_page_id IN NUMBER
 ,x_ref_path_tbl OUT NOCOPY BIS_PMV_PORTAL_UTIL_PVT.BIS_PMV_REF_PATH_TBL_TYPE
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_msg_count   OUT NOCOPY NUMBER
 ,x_msg_data    OUT NOCOPY VARCHAR2
)
IS

	l_ref_path_rec BIS_PMV_PORTAL_UTIL_PVT.BIS_PMV_REF_PATH_REC_TYPE ;
	l_index NUMBER := 1;

  --jprabhud - 07/16/03- Make this a dynamic sql to remove portal dependency
  TYPE All_Ref_Paths IS REF CURSOR;
  c_all_ref_paths All_Ref_Paths;
  l_all_ref_paths_stmt varchar2(2000);

  --jprabhud - 07/16/03- Make this a dynamic sql to remove portal dependency
  -- Removed cursor c_user_ref_paths as it is not being used, and has reference to portal table

BEGIN
    --jprabhud - 07/16/03- Make this a dynamic sql to remove portal dependency
    if c_all_ref_paths%ISOPEN then
      close c_all_ref_paths;
  	end if;
    l_all_ref_paths_stmt := 'select name from wwpob_portlet_instance$	where page_id = :1';
    OPEN c_all_ref_paths FOR l_all_ref_paths_stmt USING p_page_id;

     --jprabhud - 07/16/03- Make this a dynamic sql to remove portal dependency
     LOOP
        FETCH c_all_ref_paths INTO l_ref_path_rec.ref_path;
        x_ref_path_tbl(l_index) := l_ref_path_rec ;
        l_index := l_index + 1 ;
        EXIT WHEN c_all_ref_paths%NOTFOUND;
     END LOOP;
     CLOSE c_all_ref_paths;



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        --jprabhud - 07/16/03- Make this a dynamic sql to remove portal dependency
        if c_all_ref_paths%ISOPEN then
          close c_all_ref_paths;
  	    end if;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --jprabhud - 07/16/03- Make this a dynamic sql to remove portal dependency
        if c_all_ref_paths%ISOPEN then
          close c_all_ref_paths;
  	    end if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;
  WHEN OTHERS THEN
        --jprabhud - 07/16/03- Make this a dynamic sql to remove portal dependency
        if c_all_ref_paths%ISOPEN then
          close c_all_ref_paths;
  	    end if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END get_reference_paths ;


-- Note : 1. 	PAGE_ID for OA pages is of the form
-- 		 	-{MENU_ID}
--		Notice the '-' sign
--	  2.	REFERENCE_PATHS present in ICX_PORTLET_CUSTOMIZATIONS are
-- 		of the form
--			%PAGE_ID%
--		where '%' represents a string of alpha-numeric characters
--BugFix 3417849 make ref_path_tbl as IN OUT
PROCEDURE get_oa_reference_paths(
  p_page_id IN NUMBER
 ,x_ref_path_tbl IN OUT NOCOPY BIS_PMV_PORTAL_UTIL_PVT.BIS_PMV_REF_PATH_TBL_TYPE
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_msg_count   OUT NOCOPY NUMBER
 ,x_msg_data    OUT NOCOPY VARCHAR2
)
IS

	l_ref_path_rec BIS_PMV_PORTAL_UTIL_PVT.BIS_PMV_REF_PATH_REC_TYPE ;
	l_index NUMBER := 1;

	CURSOR c_all_ref_paths(p_page_id IN NUMBER) IS
		select reference_path
  		from icx_portlet_customizations
  		where reference_path like  '%' || p_page_id || '%'  ;


BEGIN
                if (x_ref_path_tbl is not null) then
                   l_index := x_ref_path_tbl.COUNT + 1;
                end if;

		if c_all_ref_paths%ISOPEN then
    			close c_all_ref_paths;
  		end if;



			for l_ref_path in c_all_ref_paths(p_page_id) loop
               			l_ref_path_rec.ref_path := l_ref_path.reference_path ;
	 			x_ref_path_tbl(l_index) := l_ref_path_rec ;
	 			l_index := l_index + 1 ;
			end loop ;



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
null ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;
  WHEN OTHERS THEN
null ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END get_oa_reference_paths ;


----------------------Delete Hanging Related Links-------------------------------

--bulk delete the related links that have been left hanging
--as a result of refresh portal page. -ansingh


PROCEDURE DELETE_HANGING_RELATED_LINKS (pUserId IN NUMBER, pPlugIdArray IN BISVIEWER.t_num)
IS
BEGIN

  IF (pUserId = -1) OR (pUserId IS NULL) THEN
    FORALL i IN pPlugIdArray.FIRST..pPlugIdArray.LAST
      DELETE FROM BIS_RELATED_LINKS
      WHERE FUNCTION_ID = pPlugIdArray(i);
  ELSE
    FORALL i IN pPlugIdArray.FIRST..pPlugIdArray.LAST
      DELETE FROM BIS_RELATED_LINKS
      WHERE FUNCTION_ID = pPlugIdArray(i)
      AND USER_ID = pUserId;
  END IF;

END DELETE_HANGING_RELATED_LINKS;
----------------------Delete Hanging Related Links-------------------------------

END bis_pmv_portal_util_pvt;


/
