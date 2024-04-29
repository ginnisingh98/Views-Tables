--------------------------------------------------------
--  DDL for Package Body FPA_INVESTMENT_CRITERIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_INVESTMENT_CRITERIA_PVT" as
/* $Header: FPAVINVB.pls 120.7 2007/11/29 05:44:02 kjai ship $ */

-- The procedure Create_StrategicObj_Objects_AW creates the AW objects related to
-- strategic objectives:	strategic_obj_d
--				strategic_obj_h
--				strategic_obj_weight_m
-- However, this procedure may not be used at all since the objects above must be seeded
-- in order to have the necessary views on top of them.
/*
PROCEDURE create_strategicobj_objects_AW
(
  	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_Investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
)
IS

BEGIN

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_resourcetype_pvt.create_resourcetype.begin',
			'Entering fpa_resourcetype_pvt.create_resourcetype'
		);
	END IF;

	-- if flag eq 'Y' create the strategic objective dimension.
	IF (p_Investment_rec_type.create_strategic_obj_d = 'Y') THEN
		dbms_aw.execute('define strategic_obj_d dimension text');
	END IF;

	-- if flag eq 'Y' create the strategic objective relation.
	IF (p_Investment_rec_type.create_strategic_obj_h = 'Y') THEN
		dbms_aw.execute('define strategic_obj_h relation strategic_obj_d <strategic_obj_d>');
	END IF;

	-- if flag eq 'Y' create the strategic_obj_weight_m measure.
	IF (p_Investment_rec_type.create_strategic_obj_weight_m = 'Y') THEN
		dbms_aw.execute('define strategic_obj_weight_m <strategic_obj_d> decimal');
	END IF;

	-- if flag eq 'Y' create the strategic_obj_score_m measure.
	IF (p_Investment_rec_type.create_strategic_obj_score_m = 'Y') THEN
		dbms_aw.Execute('define strategic_obj_score_m <strategic_obj_d> decimal');
	END IF;

	-- if flag eq 'Y' create the strategic_obj_wscore_m measure.
	IF (p_investment_rec_type.create_strategic_obj_wscore_m = 'Y') THEN
		dbms_aw.xecute('define strategic_obj_wscore_m <strategic_obj_d> decimal');
	END IF;

	-- if flag eq 'Y' create the strategic_obj_status_r measure.
	IF (p_Investment_rec_type.create_strategic_obj_status_r = 'Y') THEN
		DBMS_AW.Execute('define strategic_obj_status_r relation attribute_library_d <strategic_obj_d>');
	END IF;

	IF (p_commit = FND_API.G_TRUE) THEN
		DBMS_AW.Execute('UPDATE');
		COMMIT;
	END IF;


EXCEPTION
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

END Create_StrategicObj_Objects_AW;
*/
/*******************************************************************************************
*******************************************************************************************/

-- The procedure Create_StrategicObj_AW creates dimension values into strategic_obj_d
-- dimension in AW.
-- In release 1 this procedure will mainly be used at installation, where a sql script
-- will call this procedure to create the necessary strategic objectives.
-- This procedure only creates the strategic objective in AW, in order to create the
-- same object if RDBMS a different procedure must be called.
-- This procedure also updates the strategic objective hierarchy.
-- This procedure is used for SEEDING values at implementation and for creating values at
-- run time.  When SEEDING values we do not use the sequence generator.  Thus we need to
-- if procedure called for SEEDING or for run time use.  We use the p_seeding parameter
-- for this purpose.
PROCEDURE create_strategicobj_aw
(
  	p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
        p_seeding		      IN	      VARCHAR2,
        x_strategic_obj_id            OUT NOCOPY      VARCHAR2,
	x_return_status               OUT NOCOPY      VARCHAR2,
	x_msg_count                   OUT NOCOPY      NUMBER,
	x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS

    -- A cursor to get the new unique id for the Strategic Objective.
    CURSOR l_strobj_s_csr
    IS
    SELECT 	fpa_strategic_obj_s.nextval AS l_strobj_id
    FROM dual;

    -- A record to hold the new sequence value
    l_strobj_s_r 	l_strobj_s_csr%ROWTYPE;

    -- A variable to hold language
    l_language           varchar2(4);

    -- A cursor to hold language code
    CURSOR l_language_csr
    IS
    SELECT language_code
    FROM   fnd_languages
    WHERE  installed_flag IN ('I','B');

BEGIN

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_investment_criteria_pvt.create_strategicobj_aw.begin',
			'Entering fpa_investment_criteria_pvt.create_strategicobj_aw'
		);
	END IF;


        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (FND_LOG.LEVEL_PROCEDURE,
                 'fpa.sql.fpa_investment_criteria_pvt.create_strategicobj_aw',
                 'Evaluating p_seeding parameter'
                );
        END IF;

        if (upper(p_seeding) = 'Y') then
          x_strategic_obj_id :=  p_investment_rec_type.strategic_obj_shortname;
        else
	  -- Get the next sequence value for the strategic objective identifier
	  OPEN l_strobj_s_csr;
	  FETCH l_strobj_s_csr INTO l_strobj_s_r;
	  CLOSE l_strobj_s_csr;

          -- We return the id of the new Strategic Objective to the caller
          x_strategic_obj_id := l_strobj_s_r.l_strobj_id;
        end if;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (FND_LOG.LEVEL_PROCEDURE,
                 'fpa.sql.fpa_investment_criteria_pvt.create_strategicobj_aw',
                 'Inserting into FPA_OBJECTS_TL'
                );
        END IF;

    -- Open the cursor and insert p_strategic_obj_name, pc_desc for each language code
    -- insert into fpa_objects_tl only when user creates str. obj from the UI.
	-- Seed data insertion should happen using ldt files. Do not execute this insert in seed data mode
	if (upper(p_seeding) <> 'Y') then
     OPEN l_language_csr;
     LOOP
     FETCH l_language_csr INTO l_language;
     EXIT WHEN l_language_csr%NOTFOUND;

                   INSERT INTO FPA_OBJECTS_TL( object
                          ,id
                          ,name
                          ,description
                          ,LANGUAGE
                          ,SOURCE_LANG
                          ,created_by
                          ,creation_date
                          ,last_updated_by
                          ,last_update_date
                          ,last_update_login)
                    VALUES( 'INVESTMENT_CRITERIA'
                          ,x_strategic_obj_id
                          ,p_investment_rec_type.strategic_obj_name
                          ,p_investment_rec_type.strategic_obj_desc
                          ,l_language
                          ,USERENV('LANG')
                          ,0
                          ,sysdate()
                          ,0
                          ,sysdate()
                          ,0);

     END LOOP;
     CLOSE l_language_csr;
   end if;
	-- add the strategic objective to the strategic objective dimension.
	dbms_aw.execute('maintain strategic_obj_d add '
		|| x_strategic_obj_id);

	-- if parent value is not null then add the parent to the
	-- strategic objective hierarchy.
	IF (p_investment_rec_type.strategic_obj_parent IS NOT NULL) THEN
		dbms_aw.Execute('strategic_obj_h(strategic_obj_d '
			|| x_strategic_obj_id || ') = '
			|| p_Investment_rec_type.strategic_obj_parent);
	END IF;

EXCEPTION
 	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
		);
		RAISE;

END create_strategicobj_aw;

/*******************************************************************************************
*******************************************************************************************/

-- The procedure Delete_StrategicObj_AW deletes the individual Strategic Objectives from
-- the AW space.
PROCEDURE delete_strategicobj_aw
(
  	p_api_version                 IN              NUMBER,
	p_investment_rec_type         IN              fpa_investment_criteria_pvt.investment_rec_type,
	x_return_status               OUT NOCOPY      VARCHAR2,
	x_msg_count                   OUT NOCOPY      NUMBER,
	x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS

    l_api_version            CONSTANT NUMBER    := 1.0;

BEGIN

  	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_resourcetype_pvt.create_resourcetype.begin',
			'Entering fpa_resourcetype_pvt.create_resourcetype'
		);
	END IF;

  	-- Delete the Strategic Objective from the AW space.
	dbms_aw.Execute('maintain strategic_obj_d delete ' || p_Investment_rec_type.strategic_obj_shortname);

  --Delete from FPA_OBJECTS_TL
  delete from FPA_OBJECTS_TL
   where object = 'INVESTMENT_CRITERIA'
     and id = p_Investment_rec_type.strategic_obj_shortname;


EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
		);
		RAISE;

END delete_strategicobj_aw;

/*******************************************************************************************
*******************************************************************************************/

-- The procedure Update_StrategicObj updates the name and description for the
-- investment criteria.

PROCEDURE update_strategicobj
(
  	p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               OUT NOCOPY      VARCHAR2,
	x_msg_count                   OUT NOCOPY      NUMBER,
	x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS

BEGIN

  	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		( FND_LOG.LEVEL_PROCEDURE,
		 'fpa.sql.fpa_investment_criteria_pvt.update_strategicobj.begin',
		 'Entering fpa_investment_criteria_pvt.update_strategicobj');
	END IF;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (FND_LOG.LEVEL_PROCEDURE,
                 'fpa.sql.fpa_investment_criteria_pvt.update_strategicobj.begin',
                 'Updating FPA_OBJECTS_TL for the investment criteria');
        END IF;

  update FPA_OBJECTS_TL
     set  name = p_investment_rec_type.strategic_obj_name
         ,description = p_investment_rec_type.strategic_obj_desc
         ,SOURCE_LANG     = userenv('LANG')
         ,last_update_date = sysdate
   where id = p_investment_rec_type.strategic_obj_shortname
     and object = 'INVESTMENT_CRITERIA'
     and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                ( FND_LOG.LEVEL_PROCEDURE,
                 'fpa.sql.fpa_investment_criteria_pvt.update_strategicobj.end',
                 'Exiting fpa_investment_criteria_pvt.update_strategicobj');
        END IF;



EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
		);
		RAISE;

end Update_StrategicObj;

/*******************************************************************************************
*******************************************************************************************/

-- The procedure Update_StrategicObj_Status_AW updates the status of the strategic
-- objectives in AW.  This used mainly to tell Portfolio which objectives have been seeded.
-- Used by UI for the switcher bean for Add and Delete.

PROCEDURE update_strategicobj_status_aw
(
        p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
        p_investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
        x_return_status               OUT NOCOPY      VARCHAR2,
        x_msg_count                   OUT NOCOPY      NUMBER,
        x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS

BEGIN

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_resourcetype_pvt.create_resourcetype.begin',
                        'Entering fpa_resourcetype_pvt.create_resourcetype'
                );
        END IF;


        -- Set the strategic_obj_status_r relation according to passed values.
        dbms_aw.execute('strategic_obj_status_r(strategic_obj_d '
                || p_Investment_rec_type.strategic_obj_shortname || ') = '''
                || p_Investment_rec_type.strategic_obj_status || '''');

EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                (
                        p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
                );
                RAISE;

end update_strategicobj_status_aw;

/*******************************************************************************
*******************************************************************************/

PROCEDURE update_strategicobj_level_aw
(
        p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
        p_investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
        x_return_status               OUT NOCOPY      VARCHAR2,
        x_msg_count                   OUT NOCOPY      NUMBER,
        x_msg_data                    OUT NOCOPY      VARCHAR2
) is

begin

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_Investment_Criteria_PVT.update_strategicobj_level_aw.begin',
                        'Entering FPA_Investment_Criteria_PVT.update_strategicobj_level_aw'
                );
        END IF;


        -- Set the invest_criteria_level_r relation according to passed values.
        dbms_aw.execute('invest_criteria_level_r(strategic_obj_d '
                || p_Investment_rec_type.strategic_obj_shortname || ') = '''
                || p_Investment_rec_type.strategic_obj_level || '''');

EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                (
                        p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
                );
                RAISE;

end update_strategicobj_level_aw;

/*******************************************************************************
*******************************************************************************/

-- The procedure Update_StrategicObj_Weight_AW updates the Strategic Objective
-- Weight measure in AW.Update_StrategicObj_Weight_AW. (strategic_obj_weight_m)
PROCEDURE update_strategicobj_weight_aw
(
	  p_Investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	  x_return_status               OUT NOCOPY      varchar2,
	  x_msg_count                   OUT NOCOPY      number,
	  x_msg_data                    OUT NOCOPY      varchar2
)
IS

	l_api_version                   CONSTANT NUMBER := 1.0;

	l_investment_rec_type           FPA_Investment_Criteria_PVT.Investment_rec_type;

	l_objective_string              VARCHAR2(5000); -- used to hold current obj string.
	l_temp_string                   VARCHAR2(500);  -- string to hold current obj and score.

	l_temp				VARCHAR2(1000);

BEGIN

  	-- copy passed record into local record.
	l_Investment_rec_type := p_Investment_rec_type;

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_resourcetype_pvt.create_resourcetype.begin',
			'Entering fpa_resourcetype_pvt.create_resourcetype'
		);
	END IF;

	-- Attach the AW space read write.
	IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_STATEMENT,
			'fpa.sql.fpa_resourcetype_pvt.create_resourcetype',
			'Attaching OLAP workspace: '
		);
	END IF;

	-- At this point we parse the string containing all Objective shortnames and
	-- their respective weights.
	l_objective_string := l_investment_rec_type.strategic_scores_string;
	WHILE (length(l_objective_string) > 0) LOOP

		-- Get first objective and weight.
		l_temp_string := substr(l_objective_string, 1, instr(l_objective_string, ';'));

		-- Get the shortname for the objective.
		l_Investment_rec_type.strategic_obj_shortname :=
			substr(l_temp_string, 1, (instr(l_temp_string, ':')-1));

    		-- Get the weight for this objective.
		l_Investment_rec_type.strategic_obj_weight :=
			replace(rtrim(substr(l_temp_string,
			(instr(l_temp_string,':')+1)), ';'), '%', '');

		-- limit the strategic objective dimension
		DBMS_AW.Execute('lmt strategic_obj_d to '
			|| l_Investment_rec_type.strategic_obj_shortname);

		-- Set the strategic_obj_weight_m value equal to the one passed.
		-- First check if there is a valid score.
		if (l_Investment_rec_type.strategic_obj_weight is null) then
			l_Investment_rec_type.strategic_obj_weight := 0;
		end if;
		DBMS_AW.Execute('strategic_obj_weight_m = ' || l_Investment_rec_type.strategic_obj_weight);

		l_objective_string := substr(l_objective_string, (instr(l_objective_string, ';') + 1));
	END LOOP;

EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
		);
		RAISE;

END update_strategicobj_weight_aw;

-- This procedure updates the Strategic Objective Scores for the Project Type
-- We will add all scores for all Projects and then we will take the average.
PROCEDURE Update_ProjectTypeObjScore_AW
(
  	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_Investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
)
IS

BEGIN

  	-- Attach the AW space read write.

	-- limit the project dimension to the current project
	DBMS_AW.Execute('lmt project_type_d to '''
		|| p_Investment_rec_type.project_type_shortname || '''');

	-- limit the project dimension to the current project
	DBMS_AW.Execute('lmt scenario_d to '''
		|| p_Investment_rec_type.scenario_shortname || '''');

	-- limit the project to the ones under the same project type.
	DBMS_AW.Execute('lmt project_d to project_type_d');
	-- keep projects which belong to the current scenario.
	DBMS_AW.Execute('lmt project_d keep scenario_project_m');
	-- limit strategic objective dimension to all.
	DBMS_AW.Execute('limit strategic_obj_d to all');
	-- sum all scores into current project type and then divide it by
	-- the number of projects in status.
	DBMS_AW.Execute('scenario_project_type_obj_score_m = '
		|| ' total(scenario_project_obj_score_m, strategic_obj_d)/statlen(project_d)');

	IF (p_commit = FND_API.G_TRUE) THEN
		DBMS_AW.Execute('update');
		COMMIT;
	END IF;


EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
		);
		RAISE;

END update_projecttypeobjscore_aw;

/*******************************************************************************************
*******************************************************************************************/
/*
-- The procedure Update_StrategicObj_WScore_AW updates the Strategic Weighted Score measure
-- in AW. (strategic_obj_wscore_m).
PROCEDURE update_strategicobj_wscore_aw
(
  	p_api_version			IN		NUMBER,
	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_Investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
)
IS

	l_api_version			CONSTANT	number := 1.0;

BEGIN

  	-- Attach the AW space read write.

	-- limit the project dimension to the current project
	DBMS_AW.Execute('lmt project_d to ''' || p_Investment_rec_type.project_shortname || '''');

	-- limit the project dimension to the current project
	DBMS_AW.Execute('lmt scenario_d to ''' || p_Investment_rec_type.scenario_shortname || '''');

	-- Set the strategic_obj_weight_m value equal to the one passed.
	DBMS_AW.Execute('scenario_project_obj_wscore_m = (strategic_obj_weight_m/100) * (scenario_project_obj_score_m)');

	IF (p_commit = FND_API.G_TRUE) THEN
		DBMS_AW.Execute('update');
		COMMIT;
	END IF;


EXCEPTION
 	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
		);
		RAISE;

END update_strategicobj_wscore_aw;
*/
/*******************************************************************************************
*******************************************************************************************/
/*
-- This procedure Updates the Weighted Objective Scores for Project Types.
PROCEDURE Update_ProjectTypeObjWScore_AW
(
  	p_api_version                 	IN              NUMBER,
	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
)
IS

	l_api_version                   CONSTANT NUMBER := 1.0;

BEGIN

  	-- Attach the AW space read write

	-- limit scenario to the one passed.
	DBMS_AW.Execute('lmt scenario_d to '''
		|| p_Investment_rec_type.scenario_shortname || '''');

	-- limit project to the one passed.
	DBMS_AW.Execute('lmt project_d to '''
		|| p_Investment_rec_type.project_shortname || '''');

	-- limit project type to the one for the given project.
	DBMS_AW.Execute('lmt project_type_d to project_d');

	-- limit projects to the ones belonging to the current project type.
	DBMS_AW.Execute('lmt project_d to project_type_d');

	-- keep those projects belonging to the current scenario.
	DBMS_AW.Execute('lmt project_d keep scenario_project_m');

	-- limit strategic objectives to all.
	DBMS_AW.Execute('lmt strategic_obj_d to all');

	-- Get the Weighted Score for all projects into the project type and divide by the number of
	-- projects.
	DBMS_AW.Execute('scenario_project_type_obj_wscore_m =
		total(scenario_project_obj_wscore_m, strategic_obj_d)/statlen(project_d)');

	IF (p_commit = FND_API.G_TRUE) THEN
		DBMS_AW.Execute('update');
		COMMIT;
	END IF;


EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
		);
		RAISE;

END update_projecttypeobjwscore_aw;
*/
/*******************************************************************************************
*******************************************************************************************/
/*
-- The procedure Update_StrategicObj_AScore_AW updates the Strategic Objective Average Score
-- for the Groups.  We use the same variable as the individual objectives since the
-- individual scores are not entered at the Group level.
PROCEDURE Update_StrategicObj_AScore_AW
(
  	p_api_version			IN		number,
	p_commit                      	IN              varchar2 := FND_API.G_FALSE,
	p_Investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      varchar2,
	x_msg_count                   	OUT NOCOPY      number,
	x_msg_data                    	OUT NOCOPY      varchar2
)
IS

	l_api_version			CONSTANT	number := 1.0;

	-- Define Cursor type.
	TYPE obj_csr_type              			IS REF CURSOR;
	l_obj_csr					obj_csr_type;

	l_sql						varchar2(1000);
	l_obj_member_name				varchar2(30);

	l_obj_group_tab_id				number;
	l_temp_tab_id					number;
	l_obj_count					number;

BEGIN

  	-- Get the tab id for the Top Level Tab - Strategic Alignment.  We know the shortname
	-- for this tab because it is seeded.
	select tab_id
	into l_obj_group_tab_id
	from fpa_inv_criteria_vl
	where shortname = 'FPASTRALIGN';

	-- build query to get children of FPASTRALIGN
	l_sql := 'select tab_id ' ||
           '  from fpa_inv_criteria_vl ' ||
           ' where parent_tab_id = ' || l_obj_group_tab_id;

	   -- Attach the AW space read write.

	   -- limit the project dimension to the current project
	   DBMS_AW.Execute('lmt project_d to ''' || p_Investment_rec_type.project_shortname || '''');

	   -- limit the scnearioproject dimension to the current project
	   DBMS_AW.Execute('lmt scenario_d to ''' || p_Investment_rec_type.scenario_shortname || '''');

	   -- execute cursor.
	   open l_obj_csr for l_sql;
	   loop
	   	-- fetch values into the variable.
	   	fetch l_obj_csr into l_temp_tab_id;
		exit when l_obj_csr%NOTFOUND;

      		-- execute another query to get number of children of current Strategic group
		-- and name of Strategic group.
		select distinct count(a.tab_id), b.shortname
		into l_obj_count, l_obj_member_name
		from fpa_inv_criteria_vl a, fpa_inv_criteria_vl b
		where a.parent_tab_id = l_temp_tab_id
		and b.tab_id = l_temp_tab_id
		group by b.shortname;

      		-- limit strategic objective to the children of the current Group.
		DBMS_AW.Execute('limit strategic_obj_d to ''' || l_obj_member_name || '''');
		DBMS_AW.Execute('limit strategic_obj_d to children using strategic_obj_h');
		-- set the average score of the Group
		DBMS_AW.Execute('scenario_project_obj_score_m(strategic_obj_d ''' || l_obj_member_name || ''') = total(scenario_project_obj_score_m)/' || l_obj_count || '');

		-- set the sum of weighted scores
		DBMS_AW.Execute('scenario_project_obj_wscore_m(strategic_obj_d ''' || l_obj_member_name || ''') = total(scenario_project_obj_wscore_m)');

		-- We must set the status of the dimension equal to all.  Views based on AW use the current
		-- dimension status.
		DBMS_AW.Execute('limit strategic_obj_d to all');

	end loop;

	-- Now we get the average of all five strategic objectives.
	DBMS_AW.Execute('lmt strategic_obj_d to ''FPASTRALIGN''');
	DBMS_AW.Execute('limit strategic_obj_d to children using strategic_obj_h');
	DBMS_AW.Execute('scenario_project_obj_score_m(strategic_obj_d ''FPASTRALIGN'') = total(scenario_project_obj_score_m)/5');

	DBMS_AW.Execute('update');

	if (p_commit = FND_API.G_TRUE) then
		commit;
	end if;


EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
		RAISE;

END update_strategicobj_ascore_aw;
*/
/*******************************************************************************************
*******************************************************************************************/

/*
-- Update the Average Score for the Project Type for the particular Objective Group.
procedure Update_ProjectTypeObjAScore_AW(
  p_commit                      IN              varchar2 := FND_API.G_FALSE
 ,p_Investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type
 ,x_return_status               OUT NOCOPY      varchar2
 ,x_msg_count                   OUT NOCOPY      number
 ,x_msg_data                    OUT NOCOPY      varchar2
) is

begin

  -- Attach the AW space read write
  DBMS_AW.Execute('aw attach ' || p_Investment_rec_type.AW_space || ' rw first');

  -- limit project type to the one passed.
  DBMS_AW.Execute('lmt project_type_d to ''' || p_Investment_rec_type.project_type_shortname || '''');

  -- limit scenario to the one passed.
  DBMS_AW.Execute('lmt scenario_d to ''' || p_Investment_rec_type.scenario_shortname || '''');

  -- limit projects to the ones belonging to the current project type.
  DBMS_AW.Execute('lmt project_d to project_type_d');

  -- keep those projects belonging to the current scenario.
  DBMS_AW.Execute('lmt project_d keep scenario_project_m');

  -- limit strategic objectives to all.
  DBMS_AW.Execute('lmt strategic_obj_d to all');

  -- Get the average score of all projects into the project type and divide it by the
  -- number of projects in status.
  DBMS_AW.Execute('scenario_project_type_obj


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    DBMS_AW.Execute('aw detach ' || p_Investment_rec_type.AW_space);
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    DBMS_AW.Execute('aw detach ' || p_Investment_rec_type.AW_space);
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    DBMS_AW.Execute('aw detach ' || p_Investment_rec_type.AW_space);
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    DBMS_AW.Execute('aw detach ' || p_Investment_rec_type.AW_space);
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Update_ProjectTypeObjAScore_AW;

*/
/*******************************************************************************************
*******************************************************************************************/
/*
PROCEDURE Rollup_StrategicObj_WScore_AW
(
  	p_api_version                 	IN              NUMBER,
	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_Investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
)
IS

	l_api_version                   CONSTANT        number := 1.0;

BEGIN

  	-- Attach the AW space read write.

	-- limit the project dimension to the current project
	DBMS_AW.Execute('lmt project_d to ''' || p_Investment_rec_type.project_shortname || '''');

	-- limit the project dimension to the current project
	DBMS_AW.Execute('lmt scenario_d to ''' || p_Investment_rec_type.scenario_shortname || '''');

	-- get the leaf nodes only
	DBMS_AW.Execute('lmt strategic_obj_d to all');
	DBMS_AW.Execute('lmt strategic_obj_d remove ancestors using strategic_obj_h');

	-- get the next level parents.
	DBMS_AW.Execute('lmt strategic_obj_d add parents using strategic_obj_h');

	-- rollup the weighted score
	DBMS_AW.Execute('rollup scenario_project_obj_wscore_m over strategic_obj_d using strategic_obj_h');

	-- remove the leaf nodes to weight the rolled up weighted scores.
	DBMS_AW.Execute('lmt strategic_obj_d remove descendants using strategic_obj_h');

	-- weight the score
	DBMS_AW.Execute('scenario_project_obj_wscore_m = scenario_project_obj_wscore_m * (strategic_obj_weight_m/100)');

	-- Now we will calculate the next level
	-- get the next level parents.
	DBMS_AW.Execute('lmt strategic_obj_d add parents using strategic_obj_h');

	-- rollup the weighted score
	DBMS_AW.Execute('rollup scenario_project_obj_wscore_m over strategic_obj_d using strategic_obj_h');

	-- At this point we are done rolling up data and weighting it.  If by some
	-- reason more levels are added to the hierarchy this will have to be
	-- revistited.

  	IF (p_commit = FND_API.G_TRUE) THEN
		DBMS_AW.Execute('update');
		COMMIT;
	END IF;


EXCEPTION
 	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
		);
		RAISE;

END rollup_strategicobj_wscore_aw;
*/
/*******************************************************************************
*******************************************************************************/
-------------------------------------------------------------------------------
-- API create_strategicobj_aw , Overloaded API which does not take
-- FPA_Investment_Criteria_PVT.Investment_rec_type as a parameter
--
-- Params
--              p_commit                      IN              VARCHAR2
--              p_seeding                     IN              VARCHAR2
--              x_strategic_obj_id	      OUT NOCOPY      VARCHAR2
--              x_return_status               OUT NOCOPY      VARCHAR2
--              x_msg_count                   OUT NOCOPY      NUMBER
--              x_msg_data                    OUT NOCOPY      VARCHAR2
--              p_strategic_obj_shortname     IN              NUMBER
-- 	        p_strategic_obj_desc          IN              VARCHAR2
-- 		p_strategic_obj_name          IN              VARCHAR2
-- 		p_strategic_obj_level         IN              VARCHAR2
--              p_strategic_obj_parent        IN              VARCHAR2
-------------------------------------------------------------------------------
PROCEDURE create_strategicobj_aw
(
    p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
    p_seeding                     IN              VARCHAR2,
    p_strategic_obj_shortname     IN              NUMBER,
    p_strategic_obj_desc          IN              VARCHAR2,
    p_strategic_obj_name          IN              VARCHAR2,
    p_strategic_obj_level         IN              VARCHAR2,
    p_strategic_obj_parent        IN              VARCHAR2,
    x_strategic_obj_id	          OUT NOCOPY      VARCHAR2,
    x_return_status               OUT NOCOPY      VARCHAR2,
    x_msg_count                   OUT NOCOPY      NUMBER,
    x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS
  l_Investment_rec_type  FPA_Investment_Criteria_PVT.Investment_rec_type;
BEGIN
  l_Investment_rec_type.strategic_obj_shortname := p_strategic_obj_shortname;
  l_Investment_rec_type.strategic_obj_desc      := p_strategic_obj_desc;
  l_Investment_rec_type.strategic_obj_name      := p_strategic_obj_name;
  l_Investment_rec_type.strategic_obj_level     := p_strategic_obj_level;
  l_investment_rec_type.strategic_obj_parent    := p_strategic_obj_parent;
  create_strategicobj_aw (  p_commit               => p_commit,
	                    p_investment_rec_type  => l_investment_rec_type,
                            p_seeding		   => p_commit,
                            x_strategic_obj_id     => x_strategic_obj_id,
	                    x_return_status        => x_return_status,
	                    x_msg_count            => x_msg_count,
	                    x_msg_data             => x_msg_data );
END create_strategicobj_aw;

--------------------------------------------------------------------------------
-- API update_strategicobj_status_aw , Overloaded API which does not take
-- FPA_Investment_Criteria_PVT.Investment_rec_type as a parameter
--
-- Params
--              p_commit                      IN              VARCHAR2
--              x_return_status               OUT NOCOPY      VARCHAR2
--              x_msg_count                   OUT NOCOPY      NUMBER
--              x_msg_data                    OUT NOCOPY      VARCHAR2
--              p_strategic_obj_shortname     IN              NUMBER
-- 		p_strategic_obj_desc          IN              VARCHAR2
-- 	        p_strategic_obj_name          IN              VARCHAR2
-- 		p_strategic_obj_level         IN              VARCHAR2
--              p_strategic_obj_parent        IN              VARCHAR2
--              p_strategic_obj_status        IN              VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE update_strategicobj_status_aw
(
    p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
    p_strategic_obj_shortname     IN              NUMBER,
    p_strategic_obj_desc          IN              VARCHAR2,
    p_strategic_obj_name          IN              VARCHAR2,
    p_strategic_obj_level         IN              VARCHAR2,
    p_strategic_obj_parent        IN              VARCHAR2,
    p_strategic_obj_status        IN              VARCHAR2,
    x_return_status               OUT NOCOPY      VARCHAR2,
    x_msg_count                   OUT NOCOPY      NUMBER,
    x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS
  l_Investment_rec_type  FPA_Investment_Criteria_PVT.Investment_rec_type;
BEGIN
  l_Investment_rec_type.strategic_obj_shortname := p_strategic_obj_shortname;
  l_Investment_rec_type.strategic_obj_desc      := p_strategic_obj_desc;
  l_Investment_rec_type.strategic_obj_name      := p_strategic_obj_name;
  l_Investment_rec_type.strategic_obj_level     := p_strategic_obj_level;
  l_investment_rec_type.strategic_obj_parent    := p_strategic_obj_parent;
  l_investment_rec_type.strategic_obj_status    := p_strategic_obj_status;
  update_strategicobj_status_aw( p_commit              => p_commit,
                                 p_investment_rec_type => l_Investment_rec_type,
                                 x_return_status       => x_return_status,
                                 x_msg_count           => x_msg_count,
                                 x_msg_data            => x_msg_data);
END update_strategicobj_status_aw;

-------------------------------------------------------------------------------
-- API update_strategicobj_status_aw , Overloaded API which does not take
-- FPA_Investment_Criteria_PVT.Investment_rec_type as a parameter
--
-- Params
--              p_commit                      IN              VARCHAR2
--              x_return_status               OUT NOCOPY      VARCHAR2
--              x_msg_count                   OUT NOCOPY      NUMBER
--              x_msg_data                    OUT NOCOPY      VARCHAR2
--              p_strategic_obj_shortname     IN              NUMBER
-- 	        p_strategic_obj_desc          IN              VARCHAR2
-- 		p_strategic_obj_name          IN              VARCHAR2
-- 		p_strategic_obj_level         IN              VARCHAR2
--              p_strategic_obj_parent        IN              VARCHAR2
-------------------------------------------------------------------------------
PROCEDURE update_strategicobj_level_aw
(
        p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
        p_strategic_obj_shortname     IN              NUMBER,
        p_strategic_obj_desc          IN              VARCHAR2,
        p_strategic_obj_name          IN              VARCHAR2,
        p_strategic_obj_level         IN              VARCHAR2,
        p_strategic_obj_parent        IN              VARCHAR2,
        x_return_status               OUT NOCOPY      VARCHAR2,
        x_msg_count                   OUT NOCOPY      NUMBER,
        x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS
  l_Investment_rec_type  FPA_Investment_Criteria_PVT.Investment_rec_type;
  BEGIN
    l_Investment_rec_type.strategic_obj_shortname := p_strategic_obj_shortname;
    l_Investment_rec_type.strategic_obj_desc      := p_strategic_obj_desc;
    l_Investment_rec_type.strategic_obj_name      := p_strategic_obj_name;
    l_Investment_rec_type.strategic_obj_level     := p_strategic_obj_level;
    l_investment_rec_type.strategic_obj_parent    := p_strategic_obj_parent;
    update_strategicobj_level_aw ( p_commit              => p_commit,
                                   p_investment_rec_type => l_Investment_rec_type,
                                   x_return_status       => x_return_status,
                                   x_msg_count           => x_msg_count,
                                   x_msg_data            => x_msg_data);
END update_strategicobj_level_aw;

END fpa_investment_criteria_pvt;

/
