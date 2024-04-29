--------------------------------------------------------
--  DDL for Package Body FPA_PORTFOLIO_PROJECT_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_PORTFOLIO_PROJECT_SETS_PVT" AS
/* $Header: FPAVPRSB.pls 120.2 2006/06/16 22:27:49 sishanmu noship $ */

    PROCEDURE create_project_set
     ( p_api_version    IN      NUMBER,
       p_pc_id          IN      fpa_aw_pc_info_v.planning_cycle%TYPE,
	   x_return_status  OUT     NOCOPY VARCHAR2,
       x_msg_data       OUT     NOCOPY VARCHAR2,
       x_msg_count      OUT     NOCOPY NUMBER) IS
        cursor c_project_sets(p_portfolio_id in number) is
            SELECT  init_project_set_id, appr_project_set_id
            FROM    FPA_AW_PROJECT_SETS_V
            WHERE   portfolio = p_portfolio_id;

        l_project_sets c_project_sets%ROWTYPE;

        l_portfolio_id                     fpa_aw_portfs_v.portfolio%TYPE;
        l_init_project_set_id       fpa_aw_project_sets_v.init_project_set_id%TYPE;
        l_appr_project_set_id       fpa_aw_project_sets_v.appr_project_set_id%TYPE;
        l_project_set_name          pa_project_sets_v.name%TYPE;
        l_project_set_id            fpa_aw_project_sets_v.init_project_set_id%TYPE;
        l_appr_scen_id              fpa_aw_sce_info_v.scenario%TYPE;
        l_project_id_tbl		    SYSTEM.pa_num_tbl_type;
		l_portfolio_name			fpa_portfs_vl.name%TYPE;
		l_pc_name					fpa_pcs_vl.NAME%TYPE;
--        l_pset_attr                 fpa_project_sets_v.status%TYPE;
--        l_count number;

	l_count number(15);

	cursor c_portfolio_owner is
	  select hzp.party_id
	    from pa_project_parties ppp, pa_project_role_types pprt, hz_parties hzp, per_people_f per, fpa_aw_pc_info_v pc
	    where ppp.object_type = 'PJP_PORTFOLIO'
	    and ppp.project_role_id = pprt.project_role_id
	    and pprt.project_role_type = 'PORTFOLIO_OWNER'
	    and ppp.resource_source_id = per.person_id
	    and per.party_id = hzp.party_id
	    and ppp.object_id = pc.portfolio
	    and pc.planning_cycle = p_pc_id;

	  l_portfolio_owner_id number(15);


-- This is a local procedure since there is no need to call this API separately
    PROCEDURE delete_project_set_lines
     ( p_api_version    IN      NUMBER,
       p_project_set_id IN      fpa_aw_project_sets_v.init_project_set_id%TYPE,
       x_return_status  OUT     NOCOPY VARCHAR2,
       x_msg_data       OUT     NOCOPY VARCHAR2,
       x_msg_count      OUT     NOCOPY NUMBER)
    IS

        l_project_id_tbl    SYSTEM.pa_num_tbl_type;
        NO_PROJECTS_FOUND EXCEPTION;

    BEGIN

        FND_MSG_PUB.Initialize;
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets_pvt.delete_project_set_lines.begin',
                'Entering FPA_PORTF_PROJECT_SETS.delete_project_set_lines'
            );
        END IF;


      IF PA_PROJECT_SET_UTILS.do_lines_exist(p_project_set_id) = 'Y' then   -- check if lines exist for this project Set
            SELECT project_id BULK COLLECT
            INTO   l_project_id_tbl
            FROM   pa_project_set_lines
            WHERE  project_set_id = p_project_set_id;

        -- Call API to delete one row at at a time
        FOR i in l_project_id_tbl.FIRST..l_project_id_tbl.LAST
        LOOP
            PA_PROJECT_SETS_PUB.delete_project_set_line
            (
             p_project_set_id   => p_project_set_id
             ,p_project_id      => l_project_id_tbl(i)
             ,x_return_status   => x_return_status
             ,x_msg_count       => x_msg_count
             ,x_msg_data        => x_msg_data
            );
        END LOOP;
	   END IF;

       -- reset boolean variable to NA for all the projects that were deleted from the project set
	dbms_aw.execute('PUSH project_d');
        dbms_aw.execute('LMT project_set_d to  ' || p_project_set_id);
        dbms_aw.execute('LMT project_d to project_set_project_m eq yes');
        dbms_aw.execute('project_set_project_m = na');
        dbms_aw.execute('POP project_d');

/*  	    IF (p_commit = FND_API.G_TRUE) THEN
  	   	  COMMIT;
 	   	  dbms_aw.execute('UPDATE');
      	END IF;
*/

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
            (
    	   		  FND_LOG.LEVEL_PROCEDURE,
                  'FPA.SQL.fpa_portfolio_project_sets.delete_project_set_lines.end',
                  'Exiting fpa_portfolio_project_sets.delete_project_set_lines'
            );
      END IF;

    EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.STRING
		(
			FND_LOG.LEVEL_ERROR,
			'FPA.SQL.fpa_portfolio_project_sets.delete_project_set_lines',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

    END delete_project_set_lines;


       BEGIN

--       l_project_set_name := 'Project_set_1'||TO_CHAR(SYSDATE,'HHMISS');

       /* Temp code ends*/
	-- Get the Portfolio ownerId. This is used to set owner for project set.

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set',
                'Fetch Portfolio Owner Id'
            );
        END IF;

	open c_portfolio_owner;
	fetch c_portfolio_owner into l_portfolio_owner_id;
	close c_portfolio_owner;

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set',
                'Portfolio Owner ID ='||l_portfolio_owner_id
            );
        END IF;

        FND_MSG_PUB.Initialize;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set.begin',
                'Entering fpa_portfolio_project_sets.create_project_set'
            );
        END IF;

        SELECT      portfolio
        INTO        l_portfolio_id
        FROM        fpa_aw_pc_info_v
        WHERE       planning_cycle = p_pc_id;

--Select portfolio name, to be part of the project_set name.
		SELECT name
		INTO   l_portfolio_name
		FROM   fpa_portfs_vl
		WHERE  portfolio = l_portfolio_id;

--Select pc name, to be part of the project_set name.
		SELECT name
		INTO   l_pc_name
		FROM   fpa_pcs_vl
		WHERE  planning_cycle = p_pc_id;

--Coin the ProjectSet name.
       l_project_set_name := l_portfolio_name||' - '||l_pc_name||' - ';

        open c_project_sets(l_portfolio_id);
         fetch c_project_sets into l_project_sets;
          if l_project_sets.init_project_set_id is not null then
		 null;
		       -- Cursor returned a row. that is, project sets exist for this portfolio.
               -- clean up the project sets; 1. Rename the project set to reflect current PC and 2. Delete projects

            -- initial Project set
            delete_project_set_lines
             ( p_api_version    => p_api_version,
               p_project_set_id => l_project_sets.init_project_set_id,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data);
            -- approved project set
            delete_project_set_lines
             ( p_api_version    => p_api_version,
               p_project_set_id => l_project_sets.appr_project_set_id,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data);

          ELSE

		 -- Should create Project sets for the first time for this portfolio
                                         -- create empty proj. sets - each for initial and approved scenario

         -- Start Project Set creation
            -- Create Project set for initial scenario
            PA_PROJECT_SETS_PUB.create_project_set
             (p_project_set_name        => l_project_set_name||Fnd_message.get_string('FPA','FPA_PROJECT_SET_INIT'),
              p_party_id                => l_portfolio_owner_id,
              p_effective_start_date    => TRUNC(SYSDATE),
              p_access_level            => 1,
              p_party_name              => NULL,
              x_project_set_id          => l_init_project_set_id,
              x_return_status           => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data);

			  Fnd_message.CLEAR;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS then  -- Project Set creation failed
                raise PROGRAM_ERROR;
            end if;
            -- project set created successfully

            -- l_project_set_id returned here is project_set_id for initial scenario.
            -- set portfolio_project_set_submitted_r
            -- New project set. so maintain project_set_d and set the relation
            IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING
              (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set.',
                'Maintaining project_set_d with value ' || l_init_project_set_id
              );
            END IF;
            dbms_aw.execute('MAINTAIN project_set_d ADD ' || l_init_project_set_id);

            --Limit the values of portfolio, project_set_id
            IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING
              (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set.',
                'Limiting portfolio to ' || l_portfolio_id
              );
            END IF;
            dbms_aw.execute('LMT portfolio_d TO ' || l_portfolio_id);

            IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING
              (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set.',
                'Setting PORTFOLIO_PROJECT_SET_SUBMITTED_R with value ' || l_init_project_set_id
              );
            END IF;
            dbms_aw.execute('PORTFOLIO_PROJECT_SET_SUBMITTED_R =  ' ||l_init_project_set_id);

            IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING
              (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set.',
                'Calling PA_PROJECT_SETS_PUB.create_project_set.'
              );
            END IF;
            -- Create Project set for approved scenario
            PA_PROJECT_SETS_PUB.create_project_set
             (p_project_set_name        => l_project_set_name||Fnd_message.get_string('FPA','FPA_PROJECT_SET_APPR'),
              p_party_id                => l_portfolio_owner_id,
              p_effective_start_date    => TRUNC(SYSDATE),
              p_access_level            => 1,
              p_party_name              => NULL,
              x_project_set_id          => l_appr_project_set_id,
              x_return_status           => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data);

			  Fnd_message.CLEAR;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS then  -- Project Set creation failed
                raise PROGRAM_ERROR;
            end if;

            -- project set created successfully
            -- l_project_set_id returned here is project_set_id for approved scenario.
            -- set portfolio_project_set_approved_r
            -- New project set. so maintain project_set_d and set the relation
            IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING
              (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set.begin',
                'Maintaining project_set_d with value ' || l_appr_project_set_id
              );
            END IF;
            dbms_aw.execute('MAINTAIN project_set_d ADD ' || l_appr_project_set_id);

            IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING
              (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set.begin',
                'Limiting portfolio to value '  || l_portfolio_id
              );
            END IF;
            --Limit the values of portfolio, project_set_id
            dbms_aw.execute('LMT portfolio_d TO ' || l_portfolio_id);

            IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING
              (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.fpa_portfolio_project_sets.create_project_set.begin',
                'Setting PORTFOLIO_PROJECT_SET_APPROVED_R with value ' || l_appr_project_set_id
              );
            END IF;
            dbms_aw.execute('PORTFOLIO_PROJECT_SET_APPROVED_R =  ' ||l_appr_project_set_id);

         -- End Project Set creation

          END IF;
         close c_project_sets;

/* 	     IF (p_commit = FND_API.G_TRUE) THEN
           dbms_aw.execute('UPDATE');
           COMMIT;
         END IF;
*/

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
        		(
    	   		  FND_LOG.LEVEL_PROCEDURE,
                  'FPA.SQL.fpa_portfolio_project_sets.Create_project_set.end',
                  'Exiting fpa_portfolio_project_sets.Create_project_set'
                );
        END IF;


    EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;


		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.STRING
		(
			FND_LOG.LEVEL_ERROR,
			'FPA.SQL.fpa_portfolio_project_sets.Create_project_set',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;



    END create_project_set;



    PROCEDURE add_project_set_lines
     ( p_api_version    IN      NUMBER,
       p_scen_id        IN      fpa_aw_sce_info_v.scenario%TYPE,
       x_return_status  OUT     NOCOPY VARCHAR2,
       x_msg_data       OUT     NOCOPY VARCHAR2,
       x_msg_count      OUT     NOCOPY NUMBER)
    IS

        cursor c_scenario_project_set_det is
         select sc.scenario, sc.planning_cycle, is_initial_scenario,
		 		sc.approved_flag, pc.portfolio, pset.INIT_PROJECT_SET_ID, pset.APPR_PROJECT_SET_ID
		  from fpa_aw_sce_info_v sc, fpa_aw_pc_info_v pc, fpa_aw_project_sets_v pset
          where sc.planning_cycle = pc.planning_cycle
		  and pc.portfolio = pset.portfolio
		  and sc.scenario = p_scen_id;

        l_scenario_project_set_rec  c_scenario_project_set_det%rowtype;

        l_is_appr_scenario  fpa_aw_sce_info_v.approved_flag%TYPE;
        l_project_set_id    fpa_aw_project_sets_v.init_project_set_id%TYPE;
        l_pc_id             fpa_aw_sce_info_v.planning_cycle%TYPE;
        l_exists            VARCHAR2(4);
        l_proj_list         SYSTEM.pa_num_tbl_type;

    BEGIN

        FND_MSG_PUB.Initialize;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
           (
               FND_LOG.LEVEL_PROCEDURE,
               'FPA.SQL.fpa_portfolio_project_sets.add_projects_project_set.begin',
               'Entering fpa_portfolio_project_sets.add_projects_project_set'
           );
        END IF;

        open c_scenario_project_set_det;

         fetch c_scenario_project_set_det into l_scenario_project_set_rec;

          IF c_scenario_project_set_det%FOUND then

           if l_scenario_project_set_rec.approved_flag = 1 then
             l_project_set_id :=  l_scenario_project_set_rec.APPR_PROJECT_SET_ID;

            elsif l_scenario_project_set_rec.is_initial_scenario = 1 then
             l_project_set_id :=  l_scenario_project_set_rec.INIT_PROJECT_SET_ID;

           end if;

          END IF;

   		  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      		fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     'fpa.sql.fpa_main_process_pvt.add_project_set_lines',
                     'processing project_set_id = '|| l_project_set_id);
   		  END IF;

        CLOSE c_scenario_project_set_det;

        -- a scenario can have both initial and approved flags set.
-- Bug 5208493 - Add only approved projects from Approved Project set

       IF l_scenario_project_set_rec.approved_flag = 1 then
            BEGIN
                SELECT  project BULK COLLECT
                INTO    l_proj_list
                FROM    fpa_aw_proj_info_v
                WHERE   scenario = p_scen_id and
                recommended_funding_status = 'FUNDING_APPROVED';
            EXCEPTION
                WHEN OTHERS THEN
                null;
            END;
         ELSIF  l_scenario_project_set_rec.is_initial_scenario = 1 then
            BEGIN
                SELECT  project BULK COLLECT
                INTO    l_proj_list
                FROM    fpa_aw_proj_info_v
                WHERE   scenario = p_scen_id;
            EXCEPTION
                WHEN OTHERS THEN
                null;
            END;
       END IF;

       IF l_proj_list.count > 0 then   -- If there are no projects in Initial scenario, do nothing.
	   								 --  just exit the procedure.

   		  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      		fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     'fpa.sql.fpa_main_process_pvt.add_project_set_lines',
                     'Number of projects in this scenario = '|| l_proj_list.count);
   		  END IF;

        FOR i in l_proj_list.FIRST..l_proj_list.LAST
        LOOP
              l_exists := PA_PROJECT_SET_UTILS.check_projects_in_set(l_project_set_id, l_proj_list(i));
              IF l_exists = 'N' THEN
               -- add the project to the project set, if it does not yet exist
                  PA_PROJECT_SETS_PUB.create_project_set_line
                  ( p_project_set_id  => l_project_set_id
                   ,p_project_id      => l_proj_list(i)
                   ,x_return_status   => x_return_status
                   ,x_msg_count       => x_msg_count
                   ,x_msg_data        => x_msg_data
                  );
              END IF;
        END LOOP;


        --Limit the value of project_set_id
        dbms_aw.execute('LMT project_set_d TO ' ||l_project_set_id);

        --Set the measure value between the project_set_id and each of
        --the new projects added to the project_set_id

        FOR i in l_proj_list.FIRST..l_proj_list.LAST
        LOOP
                dbms_aw.execute('LMT project_d TO ' || l_proj_list(i));
                dbms_aw.execute('project_set_project_m = yes');
        END LOOP;
      END IF;
/*      	IF (p_commit = FND_API.G_TRUE) THEN
          	dbms_aw.execute('UPDATE');
    	   	COMMIT;
      	END IF;
*/

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
           (
    	   		  FND_LOG.LEVEL_PROCEDURE,
                  'FPA.SQL.fpa_portfolio_project_sets.add_projects_project_set.end',
                  'Exiting fpa_portfolio_project_sets.add_projects_project_set'
           );
        END IF;

    EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.STRING
		(
			FND_LOG.LEVEL_ERROR,
			'FPA.SQL.fpa_portfolio_project_sets.add_projects_project_set',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;
    END add_project_set_lines;


END fpa_portfolio_project_sets_pvt;

/
