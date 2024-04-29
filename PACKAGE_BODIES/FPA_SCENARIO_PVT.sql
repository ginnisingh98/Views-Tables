--------------------------------------------------------
--  DDL for Package Body FPA_SCENARIO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_SCENARIO_PVT" AS
/* $Header: FPAVSCEB.pls 120.1.12010000.3 2010/03/25 07:43:40 vgovvala ship $ */

-- A global variable to determine if a procedure
-- should attach, update/commit and detach the AW
-- independently.
g_attach_aw	BOOLEAN := true;

PROCEDURE create_scenario
(
        p_api_version                   IN              NUMBER,
        p_scenario_name			IN		VARCHAR2,
        p_scenario_desc			IN		VARCHAR2,
        p_pc_id                         IN              NUMBER,
        x_scenario_id                   OUT NOCOPY      NUMBER,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
)
IS

l_api_version           		CONSTANT NUMBER := 1.0;

CURSOR scenario_s_c
IS
SELECT
  fpa_scenario_s.nextval AS scenario_id
FROM
  dual;

-- A cursor to hold language code
CURSOR l_language_csr
IS
SELECT language_code
  FROM   fnd_languages
 WHERE  installed_flag IN ('I','B');

-- A variable to hold language
l_language           varchar2(4);


BEGIN

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_scenario_pvt.create_scenario.begin',
			'Entering fpa_scenario_pvt.create_scenario'
		);
	END IF;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_scenario_pvt.create_scenario',
                        'Getting next sequence value for scenario id.'
                );
        END IF;

  -- Get the next sequence value for the scenario identifier
  OPEN scenario_s_c;
  FETCH scenario_s_c INTO x_scenario_id;
  CLOSE scenario_s_c;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
  fnd_log.string
  (
    FND_LOG.LEVEL_PROCEDURE,
    'fpa.sql.fpa_scenario_pvt.create_scenario',
    'Maintaing scenario dimension with new scenario id.'
  );
  END IF;

  -- Add the new scenario to the dimension
  dbms_aw.execute('MAINTAIN scenario_d ADD ' || x_scenario_id);


  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.create_scenario',
      'Setting PC relation for new scenario.'
    );
  END IF;

  dbms_aw.execute('PUSH scenario_d');
  dbms_aw.execute('LMT scenario_d TO ' || x_scenario_id);
  -- Associate the scenario with the planning cycle
  dbms_aw.execute('planning_cycle_scenario_r = ' || p_pc_id);
  dbms_aw.execute('POP scenario_d');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.create_scenario',
      'Updating FPA_OBJECTS_TL with scenario information name not null.'
    );
  END IF;

  if (p_scenario_name is not null) then

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
          FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.fpa_scenario_pvt.create_scenario',
          'Scenario name is not null, Updating FPA_OBJECTS_TL with scenario information name not null.'
        );
      END IF;

    -- Open the cursor and insert scenario, name and description for each language code
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
                    VALUES( 'SCENARIO'
                          ,x_scenario_id
                          ,p_scenario_name
                          ,p_scenario_desc
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

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.create_scenario.end',
      'Exiting fpa_scenario_pvt.create_scenario'
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.create_scenario',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

END create_scenario;

/*******************************************************************************************
*******************************************************************************************/

PROCEDURE copy_scenario_data
(
        p_api_version                   IN              NUMBER,
        p_scenario_id_source            IN              NUMBER,
        p_scenario_id_target            IN              NUMBER,
        p_copy_proposed_proj	        IN              VARCHAR2,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
) is

l_api_version           		CONSTANT NUMBER := 1.0;

begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.copy_scenario_data.begin',
      'Entering fpa_scenario_pvt.copy_scenario_data'
    );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.copy_scenario_data.begin',
      'Calling AW program COPY_SCE_DATA_PRG for scenario source: ' || p_scenario_id_source || ' and scenario target: ' || p_scenario_id_target || ' and copy flag: ' || p_copy_proposed_proj || 'values.'
    );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.copy_scenario_data.begin',
'call copy_sce_data_prg(' || p_scenario_id_source || ' ' || p_scenario_id_target || ' ''' || p_copy_proposed_proj || ''')'
    );
  END IF;


  dbms_aw.execute('call copy_sce_data_prg(' || p_scenario_id_source || ' ' || p_scenario_id_target || ' ''' || p_copy_proposed_proj || ''')');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.copy_scenario_data.end',
      'Entering fpa_scenario_pvt.copy_scenario_data'
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.create_scenario',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

END copy_scenario_data;

/*******************************************************************************************
*******************************************************************************************/

PROCEDURE lock_scenario
(
  	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_scenario_rec           	IN              fpa_scenario_pvt.scenario_rec_type,
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
			'fpa.sql.fpa_scenario_pvt.lock_scenario.begin',
			'Entering fpa_project_pvt.lock_scenario'
		);
	END IF;

	IF g_attach_aw THEN
		-- Attach the AW space read write.
		IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
			fnd_log.string
			(
				FND_LOG.LEVEL_STATEMENT,
				'fpa.sql.fpa_scenario_pvt.lock_scenario',
				'Attaching OLAP workspace: '
			);
		END IF;

	END IF;

	dbms_aw.execute('LMT scenario_d TO '''
		|| p_scenario_rec.sce_shortname || '''');

	-- Lock the scenario
	dbms_aw.execute('is_scenario_locked_m = true');

	-- Set the last update date
	dbms_aw.execute('last_update_date_scenario_r = '''
		|| to_char(SYSDATE, 'MM-DD-YYYY') || '''');

	IF g_attach_aw THEN
		-- Update and commit our changes
		IF (p_commit = FND_API.G_TRUE) THEN
			dbms_aw.execute('UPDATE');
			COMMIT;
		END IF;

		-- Finally, detach the workspace
		IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
			fnd_log.string
			(
				FND_LOG.LEVEL_STATEMENT,
				'fpa.sql.fpa_scenario_pvt.lock_scenario',
				'Detaching OLAP workspace: '
			);
		END IF;
	END IF;

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_scenario_pvt.lock_scenario.end',
			'Exiting fpa_scenario_pvt.lock_scenario'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.fpa_scenario_pvt.lock_scenario',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
		);
		RAISE;
END lock_scenario;

function check_scenario_name
(
        p_scenario_name                 IN              VARCHAR2,
        p_pc_id                         IN              NUMBER,
        x_return_status              OUT NOCOPY      VARCHAR2,
        x_msg_count                  OUT NOCOPY      NUMBER,
        x_msg_data                   OUT NOCOPY      VARCHAR2
    ) RETURN number
is

l_sce_count				NUMBER := 0;

begin

  select count(a.scenario)
   into l_sce_count
   from fpa_sces_vl a,
        fpa_aw_sces_v b
  where a.scenario = b.scenario
    and b.planning_cycle = p_pc_id
    and upper(a.name) = upper(p_scenario_name);

  return l_sce_count;

EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (
                        FND_LOG.LEVEL_ERROR,
                        'fpa_scenario_pvt.Check_scenario_name',
                        SQLERRM
                );
                END IF;
                FND_MSG_PUB.count_and_get
                (
                        p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
                );
                RAISE;

end check_scenario_name;

/************************************************************************************
************************************************************************************/
-- This procedure updates the scenario_approved_flag_m  measure

PROCEDURE update_scen_approved_flag
(
        p_scenario_id                   IN              NUMBER,
        p_approved_flag		        IN 		VARCHAR2,
	x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
) IS

begin


        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_scenario_pvt.update_scen_approved_flag.begin',
                        'Entering fpa_scenario_pvt.update_scen_approved_flag'
                );
        END IF;

		-- Bug 4331948 . Reset apporved flag of all scenario for this planning cycle.
		-- this make sure there will be only one scenario is apporved
		-- fix start
		 dbms_aw.execute('LMT scenario_d TO '|| p_scenario_id );
     	 dbms_aw.execute('LMT planning_cycle_d to scenario_d');
     	 dbms_aw.execute('LMT scenario_d to planning_cycle_d');
     	 dbms_aw.execute('scenario_approved_flag_m = na');
		-- fix end

	      dbms_aw.execute('LMT scenario_d TO '|| p_scenario_id );

          dbms_aw.execute('scenario_approved_flag_m = ' || p_approved_flag);

		  	-- Set the last update date
	     	-- need to wite code for this

	       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                        fnd_log.string
                        (
                                FND_LOG.LEVEL_PROCEDURE,
                                'fpa.sql.fpa_scenario_pvt.update_scen_approved_flag.end',
                                'Exiting fpa_scenario_pvt.update_scen_approved_flag'
                        );
           END IF;

EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (
                        FND_LOG.LEVEL_ERROR,
                        'fpa.sql.fpa_scenario_pvt.update_scen_approved_flag',
                        SQLERRM
                );
                END IF;

                FND_MSG_PUB.count_and_get
                (
                        p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
                );
                RAISE;

end update_scen_approved_flag;

/************************************************************************************
************************************************************************************/
-- This procedure updates the discount rate for a Scenario

procedure update_scenario_disc_rate
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  p_discount_rate               IN              NUMBER,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
) is

l_api_version			CONSTANT NUMBER := 1.0;

begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_disc_rate.begin',
      'Entering fpa_scenario_pvt.update_scenario_disc_rate'
     );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_disc_rate',
      'Setting the discount rate.'
     );
  END IF;

  dbms_aw.execute('PUSH scenario_d');
  dbms_aw.execute('LMT scenario_d TO ' || p_scenario_id);
  -- Associate the scenario with the planning cycle
  dbms_aw.execute('scenario_discount_rate_m = ' || p_discount_rate/100);
  -- Update daily discount rate
  dbms_aw.execute('scenario_discount_rate_daily_m = ((1+scenario_discount_rate_m)**(1/365))-1');
  dbms_aw.execute('POP scenario_d');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_disc_rate.end',
      'Entering fpa_scenario_pvt.update_scenario_disc_rate'
     );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.create_scenario',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

end update_scenario_disc_rate;

/*******************************************************************************************
*******************************************************************************************/

procedure update_scenario_funds_avail
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  p_scenario_funds              IN              NUMBER,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
) is

l_api_version                   CONSTANT NUMBER := 1.0;
l_pc_disply_factor				VARCHAR2(30);
begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_funds_avail.begin',
      'Entering fpa_scenario_pvt.update_scenario_funds_avail'
     );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_funds_avail',
      'Setting the discount rate.'
     );
  END IF;

-- get the display factor, that will be used
-- to multiply with the funds avaialble.
  SELECT b.PC_DISPLAY_FACTOR
  INTO l_pc_disply_factor
  FROM fpa_aw_sces_v a,  fpa_aw_pc_disc_funds_v b
  WHERE a.planning_cycle = b.planning_cycle
  AND  a.scenario = p_scenario_id ;


  dbms_aw.execute('PUSH scenario_d');
  dbms_aw.execute('LMT scenario_d TO ' || p_scenario_id);
  -- Associate the scenario with the planning cycle
  dbms_aw.execute('scenario_funding_m = ' || p_scenario_funds*l_pc_disply_factor);
  dbms_aw.execute('POP scenario_d');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_funds_avail.end',
      'Entering fpa_scenario_pvt.update_scenario_funds_avail'
     );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.update_scenario_funds_avail',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

end update_scenario_funds_avail;

/*******************************************************************************************
*******************************************************************************************/
-- This procedure updates the scenario initial flag.
-- Only a single scenario per planning Cycle may hold this flag as true.
procedure update_scenario_initial_flag
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
) is

l_api_version                   CONSTANT NUMBER := 1.0;

begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_initial_flag.begin',
      'Entering fpa_scenario_pvt.update_scenario_initial_flag.'
     );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_initial_flag.begin',
      'Unsetting any previous flags and setting new flag.'
     );
  END IF;

  dbms_aw.execute('PUSH scenario_d');
  dbms_aw.execute('PUSH planning_cycle_d');
  dbms_aw.execute('oknullstatus = y');
  dbms_aw.execute('limit scenario_d to ' || p_scenario_id);
--  dbms_aw.execute('limit scenario_d to p_scenario_id');
  dbms_aw.execute('limit planning_cycle_d to planning_cycle_scenario_r');
  dbms_aw.execute('limit scenario_d to planning_cycle_d');
  dbms_aw.execute('limit scenario_d keep scenario_initial_m');
  dbms_aw.execute('scenario_initial_m = na');
  dbms_aw.execute('limit scenario_d to ' || p_scenario_id);
--  dbms_aw.execute('limit scenario_d to p_scenario_id');
  dbms_aw.execute('scenario_initial_m = yes');
  dbms_aw.execute('POP scenario_d');
  dbms_aw.execute('POP planning_cycle_d');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_initial_flag.end',
      'Entering fpa_scenario_pvt.update_scenario_initial_flag.'
     );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.update_scenario_initial_flag',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

end update_scenario_initial_flag;

/*******************************************************************************************
*******************************************************************************************/
-- This procedure updates the scenario working flag.
-- Only a single scenario per planning Cycle may hold this flag as true.
procedure update_scenario_working_flag
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
) is

l_api_version                   CONSTANT NUMBER := 1.0;

begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_working_flag.begin',
      'Entering fpa_scenario_pvt.update_scenario_working_flag.'
     );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_working_flag',
      'Unsetting any previous flags and setting new flag.'
     );
  END IF;

  dbms_aw.execute('PUSH scenario_d');
  dbms_aw.execute('PUSH planning_cycle_d');
  dbms_aw.execute('oknullstatus = y');
  dbms_aw.execute('limit scenario_d to ' || p_scenario_id);
  dbms_aw.execute('limit planning_cycle_d to planning_cycle_scenario_r');
  dbms_aw.execute('limit scenario_d to planning_cycle_d');
  dbms_aw.execute('limit scenario_d keep scenario_working_m');
  dbms_aw.execute('scenario_working_m = na');
  dbms_aw.execute('limit scenario_d to ' || p_scenario_id);
  dbms_aw.execute('scenario_working_m = yes');
  dbms_aw.execute('POP scenario_d');
  dbms_aw.execute('POP planning_cycle_d');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_working_flag.end',
      'Entering fpa_scenario_pvt.update_scenario_working_flag.'
     );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   --dbms_output.put_line(SQLERRM);
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.update_scenario_working_flag',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

end update_scenario_working_flag;

/*******************************************************************************************
*******************************************************************************************/
-- This procedure sets or unsets the recommended flag for a scenario.  The parameters are
-- p_scenario_id for the Scenario Id to be updated, and p_scenario_reccom_status holding the
-- values 'yes' for recommending the scenario, or 'na' for unrecommending the scenario.

procedure update_scenario_reccom_flag
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  p_scenario_reccom_status      IN              VARCHAR2,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
) is

l_api_version			CONSTANT NUMBER := 1.0;

begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_flag.begin',
      'Entering fpa_scenario_pvt.update_scenario_reccom_flag.'
     );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_flag',
      'Unsetting any previous flags and setting new flag.'
     );
  END IF;

  dbms_aw.execute('PUSH scenario_d');
  dbms_aw.execute('lmt scenario_d to ' ||  p_scenario_id);
  dbms_aw.execute('scenario_recommended_flag_m = ' || p_scenario_reccom_status);
  dbms_aw.execute('POP scenario_d');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_flag.end',
      'Entering fpa_scenario_pvt.update_scenario_reccom_flag.'
     );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  --dbms_output.put_line(SQLERRM);
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_flag',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

end update_scenario_reccom_flag;

-- This procedure updates the recommending funding status relation for the projects within
-- a scenario.
-- This procedure is capable of updating a single project or multiple projects.
-- The parameter p_project_d must be of the following form:
-- '10001,' for a single project or (with trailing comma)
-- '10001, 10002, 10003,' for multiple projects. (each id separated with a comma, also
-- trailing coma.
procedure update_scenario_reccom_status
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  p_project_id                  IN              VARCHAR2,
  p_scenario_reccom_value       IN              VARCHAR2,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
) is

l_api_version			CONSTANT NUMBER := 1.0;

l_project_id_string				VARCHAR2(5000);

l_project_id					VARCHAR2(10);

begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_status.begin',
      'Entering fpa_scenario_pvt.update_scenario_reccom_status'
     );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_status.begin',
      'Limiting to scenario id passed.'
     );
  END IF;

  dbms_aw.execute('PUSH scenario_d');
  dbms_aw.execute('LMT scenario_d TO ' || p_scenario_id);

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_status.begin',
      'Assing project id string passed to local string variable.'
     );
  END IF;

  l_project_id_string := p_project_id;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_status.begin',
      'Loop over project id string and update recommended funding status relation.'
     );
  END IF;

  WHILE (length(l_project_id_string) > 0) LOOP

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_PROCEDURE,
        'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_status.begin',
        'Current project string: ' || l_project_id_string || ' and project id: ' || l_project_id
       );
    END IF;

    l_project_id :=  substr(l_project_id_string, 1, instr(l_project_id_string, ',') -1);
    l_project_id_string := substr(l_project_id_string, (instr(l_project_id_string, ',') + 1));
--dbms_output.put_line('id: ' || l_project_id);
--dbms_output.put_line('string: ' || l_project_id_string);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_PROCEDURE,
        'fpa.sql.fpa_scenario_pvt.',
        'Updating FUNDING_STATUS_REC_SCENARIO_PROJECT_R relation for scenario: ' || p_scenario_id || ' and for project: ' || l_project_id
       );
    END IF;

    dbms_aw.execute('funding_status_rec_scenario_project_r(project_d ' || l_project_id || ') = ''' || p_scenario_reccom_value || '''');

  END LOOP;

  dbms_aw.execute('POP scenario_d');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_status.end',
      'Exiting fpa_scenario_pvt.update_scenario_reccom_status.'
     );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.update_scenario_reccom_status',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

end update_scenario_reccom_status;



-- Call OLAP Program to copy project data from initial scenario to current(target) scenario
-- If multiple projects are being added from UI, the p_project_id is passed as a string of project Ids.
-- delimited by space character.
-- This API is called from Add Projects page when Projects are added from Initial Scenario or Current Plan

PROCEDURE copy_sce_project_data
(
    p_api_version           IN              NUMBER,
    p_commit                IN              VARCHAR2,
    p_target_scen_id        IN              NUMBER,
    p_project_id_str        IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS
 l_str varchar2(2000);
 source_scen_id number;
BEGIN

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.copy_sce_project_data.begin',
      'Entering fpa_scenario_pvt.copy_sce_project_data'
     );
  END IF;

-- get the initial scenario id. Always required, no matter what the source/mode is.
-- if the source is pjp, project is selected from initial sce. and added to current sce.
-- if source is pjt, get the project from current plan , add it to initial sce,
-- and then invoke this api in pjp mode to add the same project to the current sce.

  select scenario
	into source_scen_id
    from fpa_aw_sce_info_v
	where planning_cycle =
  		(select planning_cycle from fpa_aw_sce_info_v where scenario = p_target_scen_id)
   	and is_initial_scenario = 1 ;

   l_str := 'call copy_proj_data_prg(' || p_target_scen_id || ', ' || source_scen_id || ', '' ' || p_project_id_str || ''')';
   dbms_aw.execute(l_str);
   --('call copy_proj_data_prg(' || p_target_scen_id || ' ' || source_scen_id || ' '' ' || p_project_id_str || ''')');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.copy_sce_project_data.end',
      'Entering fpa_scenario_pvt.copy_sce_project_data'
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.copy_sce_project_data',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

END copy_sce_project_data;

PROCEDURE remove_project_from_scenario
  (
    p_api_version           IN              NUMBER,
    p_commit                IN              VARCHAR2,
    p_scenario_id           IN              NUMBER,
    p_project_id        	IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
  ) IS

   l_str varchar2(2000);
BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.remove_project_from_scenario.begin',
      'Entering fpa_scenario_pvt.remove_project_from_scenario'
     );
   END IF;

l_str := 'call remove_proj_from_sce_prg(' || p_scenario_id || ',  ' || p_project_id || ')';

--  dbms_output.put_line(l_str);
  dbms_aw.execute(l_str);

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.remove_project_from_scenario.end',
      'Entering fpa_scenario_pvt.remove_project_from_scenario'
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.remove_project_from_scenario',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;
END;


PROCEDURE Update_Proj_User_Ranks
     ( p_api_version        IN NUMBER,
       p_proj_metrics       IN fpa_scen_proj_userrank_tbl,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS
BEGIN

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Scenario_Pvt.Update_Proj_User_Ranks.begin',
			'Entering FPA_Scenario_Pvt.Update_Proj_User_Ranks'
		);
	END IF;

    --DBMS_OUTPUT.put_line(' ..p_proj_metrics(1).scenario=' || p_proj_metrics(1).scenarioID );

	-- Update user ranking against project ID for the given scenario ID
	-- Limit Scenario ID
    IF(  p_proj_metrics.Count > 0 ) THEN
      IF( p_proj_metrics.Count > 1 ) THEN
	  dbms_aw.execute('LMT scenario_d TO ' || p_proj_metrics(1).scenarioID );
      END IF;
      FOR i IN p_proj_metrics.FIRST..p_proj_metrics.LAST
         LOOP

          -- DBMS_OUTPUT.put_line(' ..Inside For loop...p_proj_metrics(i).project=' || p_proj_metrics(i).projectID );
          -- DBMS_OUTPUT.put_line(' ..Inside For loop...p_proj_metrics(i).user_rank=' || p_proj_metrics(i).user_rank );
 	     /* IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.String
		   (
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Scenario_Pvt.Update_Proj_User_Ranks.end',
			'FPA_Scenario_Pvt.Update_Proj_User_Ranks: Inside for loop:projectID='||p_proj_metrics(i).projectID
			                                                                     ||'  user_rank='||p_proj_metrics(i).user_rank
		   );
	      END IF; */
              IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.String
		   (
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Scenario_Pvt.Update_Proj_User_Ranks.end',
			'FPA_Scenario_Pvt.Update_Proj_User_Ranks: Inside for loop:projectID='||p_proj_metrics(i).projectID);
              END IF;
	-- Limit project_d
	      dbms_aw.execute('LMT project_d TO ' || p_proj_metrics(i).projectID );

   -- Set the the user rank for each project
           IF p_proj_metrics(i).user_rank IS NULL THEN
             IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.String
		   (
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Scenario_Pvt.Update_Proj_User_Ranks.end',
			'FPA_Scenario_Pvt.Update_Proj_User_Ranks: Inside for loop:User Rank = na');
             END IF;
             dbms_aw.execute( 'scenario_project_user_rank_m = na');
           ELSE
              IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.String
		   (
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Scenario_Pvt.Update_Proj_User_Ranks.end',
			'FPA_Scenario_Pvt.Update_Proj_User_Ranks: Inside for loop:User Rank ='||p_proj_metrics(i).user_rank);
              END IF;
             dbms_aw.execute( 'scenario_project_user_rank_m = ' || p_proj_metrics(i).user_rank );
	       END IF;

         END LOOP;
         END IF;


	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Scenario_Pvt.Update_Proj_User_Ranks.end',
			'Exiting FPA_Scenario_Pvt.Update_Proj_User_Ranks'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
        --DBMS_OUTPUT.put_line('...Inside Object level API EXCEPTION block...');

		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR  THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_Scenario_Pvt.Update_Proj_User_Ranks',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Proj_User_Ranks;

/*******************************************************************************************
*******************************************************************************************/
-- This procedures call the program CALC_SCE_ALL_DATA_PRG.  This is an AW program
-- which recalculates all Scenario data.
-- The parameter p_data_to_calc to this procedure is used to tell the AW program
-- what level of data to calculate.
-- For more information on this parameter refer to the documentation for CALC_SCE_ALL_DATA_PRG
-- program.
PROCEDURE calc_scenario_data
(
        p_api_version                   IN              NUMBER,
        p_scenario_id                   IN              NUMBER,
        p_project_id                    IN              NUMBER,
        p_class_code_id                 IN              NUMBER,
        p_data_to_calc                  IN              VARCHAR2,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
) is

l_api_version                           CONSTANT NUMBER := 1.0;

begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.calc_scenario_data.begin',
      'Entering fpa_scenario_pvt.calc_scenario_data'
    );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.calc_scenario_data.',
      'Calling AW program CALC_SCE_ALL_DATA_PRG.'
    );
  END IF;

  if p_project_id is null and p_class_code_id is null
    then dbms_aw.execute('call calc_sce_all_data_prg(' || p_scenario_id || ' na na ''' || p_data_to_calc || ''')');
  elsif p_project_id is null
    then dbms_aw.execute('call calc_sce_all_data_prg(' || p_scenario_id || ' na ' || p_class_code_id || '''' || p_data_to_calc || ''')');
  elsif p_class_code_id is null
    then dbms_aw.execute('call calc_sce_all_data_prg(' || p_scenario_id || ' ' || p_project_id || ' na ''' || p_data_to_calc || ''')');
  end if;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_scenario_pvt.calc_scenario_data.end',
      'Entering fpa_scenario_pvt.calc_scenario_data'
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      (
        FND_LOG.LEVEL_ERROR,
        'fpa.sql.fpa_scenario_pvt.calc_scenario_data',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

END calc_scenario_data;


END fpa_scenario_pvt;

/
