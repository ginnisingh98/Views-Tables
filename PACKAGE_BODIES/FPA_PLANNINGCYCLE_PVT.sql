--------------------------------------------------------
--  DDL for Package Body FPA_PLANNINGCYCLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_PLANNINGCYCLE_PVT" as
/* $Header: FPAVPCPB.pls 120.4.12010000.4 2010/02/15 17:21:40 rthumma ship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Monika
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

PROCEDURE Create_Pc
(
  	p_api_version        IN NUMBER,
    p_pc_all_obj         IN fpa_pc_all_obj,
    x_planning_cycle_id  OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER
)
IS
	-- A cursor to get the new unique id for the Pc
	CURSOR l_pc_s_csr
	IS
	SELECT 	fpa_planning_cycle_s.nextval AS l_pc_id
	FROM dual;

	-- A record to hold the new sequence value
	l_pc_s_r 	l_pc_s_csr%ROWTYPE;

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
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Create_Pc.begin',
			'Entering FPA_PlanningCycle_Pvt.Create_Pc'
		);
	END IF;


	-- Get the next sequence value for the PC identifier
	OPEN l_pc_s_csr;
	FETCH l_pc_s_csr INTO l_pc_s_r;
	CLOSE l_pc_s_csr;

	-- We return the id of the new PC to the caller
    x_planning_cycle_id := l_pc_s_r.l_pc_id;


    -- Close the Cursor
     IF (l_language_csr%ISOPEN) THEN
       CLOSE l_language_csr;
     END IF;

   --DBMS_OUTPUT.put_line('Before Inserting Pc Name and Desc.....');

    -- Open the cursor and insert pc_name, pc_desc for each language code
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
                    VALUES( 'PLANNING_CYCLE'
                          ,l_pc_s_r.l_pc_id
                          ,p_pc_all_obj.pc_desc_fields.name
                          ,p_pc_all_obj.pc_desc_fields.description
                          ,l_language
                          ,USERENV('LANG')
                          ,fnd_global.user_id
                          ,sysdate()
                          ,fnd_global.user_id
                          ,sysdate()
                          ,0);

     END LOOP;
     CLOSE l_language_csr;

   --DBMS_OUTPUT.put_line('Before Maintain ID.....');

	-- Add the new scenario to the dimension
	dbms_aw.execute('MAINTAIN planning_cycle_d ADD ' || l_pc_s_r.l_pc_id );

   --DBMS_OUTPUT.put_line('Before Limit ID.....');
	dbms_aw.execute('PUSH planning_cycle_d');

	dbms_aw.execute('LMT planning_cycle_d TO ' || l_pc_s_r.l_pc_id );

   --DBMS_OUTPUT.put_line('Before setting the Portfolio relation.....portfolio_id=' || p_pc_all_obj.pc_info.portfolio);

	-- Associate the planning cycle with the portfolio
	dbms_aw.execute('portfolio_pc_r =  ' || p_pc_all_obj.pc_info.portfolio );

	dbms_aw.execute('POP planning_cycle_d');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Create_Pc.end',
			'Exiting FPA_PlanningCycle_Pvt.Create_Pc'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
		IF l_pc_s_csr%ISOPEN THEN
			CLOSE l_pc_s_csr;
		END IF;
		IF l_language_csr%ISOPEN THEN
			CLOSE l_language_csr;
		END IF;

		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Create_Pc',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Create_Pc;


PROCEDURE Update_Pc_Invest_Mix
     ( p_api_version        IN NUMBER,
       p_inv_matrix         IN fpa_pc_inv_matrix_tbl,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS
l_pc_catg number;
l_aw_call varchar2(50);
BEGIN
	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Invest_Mix.begin',
			'Entering FPA_PlanningCycle_Pvt.Update_Pc_Invest_Mix'
		);
	END IF;

      --DBMS_OUTPUT.put_line(' ..Inside if in Update_Pc_Invest_Mix...');

      --DBMS_OUTPUT.put_line(' ..p_inv_matrix(1).planning_cycle=' || p_inv_matrix(1).planning_cycle );

      --DBMS_OUTPUT.put_line(' ..p_inv_matrix(1).pc_category from input parameter =' || p_inv_matrix(1).pc_category );


   BEGIN
      SELECT distinct(pc_category) INTO l_pc_catg
      FROM fpa_aw_pc_inv_matrices_v
      WHERE planning_cycle =  p_inv_matrix(1).planning_cycle;
   EXCEPTION when others then
       null;
      --DBMS_OUTPUT.put_line(' ..p_inv_matrix(1).pc_category from fpa view =' || l_pc_catg );
   END;

   --DBMS_OUTPUT.put_line(' ..outside .. p_inv_matrix(1).pc_category from fpa view =' || l_pc_catg );

   IF p_inv_matrix(1).pc_category = l_pc_catg THEN
          NULL;
   ELSE
          --DBMS_OUTPUT.put_line(' ..... STARTING EXECUTION OF AW PROGRAMS ..... ');
          dbms_aw.execute('CALL set_pc_class_code_valid_prg('|| p_inv_matrix(1).planning_cycle ||' ,'|| p_inv_matrix(1).pc_category ||')');
   END IF;

	-- Update the InvestMix
	-- Limit PCID
	  dbms_aw.execute('LMT planning_cycle_d TO ' || p_inv_matrix(1).planning_cycle );

      FOR i IN p_inv_matrix.FIRST..p_inv_matrix.LAST
         LOOP
         --DBMS_OUTPUT.put_line(' ..Inside For loop...p_inv_matrix(i).class_code=' || p_inv_matrix(i).class_code );
         --DBMS_OUTPUT.put_line(' ..Inside For loop...p_inv_matrix(i).investment_mix=' || p_inv_matrix(i).investment_mix );

	-- Limit Class_code_d
	     dbms_aw.execute('LMT class_code_d TO ' || p_inv_matrix(i).class_code );
	-- Set the funds percentage for each class code
         dbms_aw.execute('pc_class_code_target_mix_m = ' || p_inv_matrix(i).investment_mix );

         END LOOP;


	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Invest_Mix.end',
			'Exiting FPA_PlanningCycle_Pvt.Update_Pc_Invest_Mix'
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
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Invest_Mix',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Pc_Invest_Mix;

PROCEDURE Update_Pc_Fin_Targets
     ( p_api_version        IN NUMBER,
       p_fin_targets_tbl    IN fpa_pc_fin_targets_tbl,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS
l_pc_catg number;
l_aw_call varchar2(50);
l_pc_disply_factor				VARCHAR2(30);
l_target_name					VARCHAR2(80);
l_financial_target_from_c VARCHAR2(100);
l_financial_target_to_c   VARCHAR2(100);
l_decimal_marker          VARCHAR2(1);
BEGIN

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Fin_Targets.begin',
			'Entering FPA_PlanningCycle_Pvt.Update_Pc_Fin_Targets'
		);
	END IF;

      --DBMS_OUTPUT.put_line(' ..Inside if in Update_Pc_Fin_Targets...');

      --DBMS_OUTPUT.put_line(' ..p_fin_targets_tbl(1).planning_cycle=' || p_fin_targets_tbl(1).planning_cycle );

      --DBMS_OUTPUT.put_line(' ..p_fin_targets_tbl(1).pc_category from input parameter =' || p_fin_targets_tbl(1).financial_metrics );

 -- get the display factor, that will be used
 -- to multiply with the funds avaialble.
  SELECT b.PC_DISPLAY_FACTOR
  INTO l_pc_disply_factor
  FROM  fpa_aw_pc_disc_funds_v b
  WHERE b.planning_cycle = p_fin_targets_tbl(1).planning_cycle;

  -- Bug Ref : 8882256
  SELECT SUBSTR(VALUE,1,1)
    INTO l_decimal_marker
    FROM NLS_SESSION_PARAMETERS
   WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';

	-- Update the financial targets
	-- Limit PCID
	  dbms_aw.execute('LMT planning_cycle_d TO ' || p_fin_targets_tbl(1).planning_cycle );

      FOR i IN p_fin_targets_tbl.FIRST..p_fin_targets_tbl.LAST
         LOOP
           --DBMS_OUTPUT.put_line(' ..Inside For loop...p_fin_targets_tbl(i).financial_target_from=' || p_fin_targets_tbl(i).financial_target_from );
           --DBMS_OUTPUT.put_line(' ..Inside For loop...p_fin_targets_tbl(i).financial_target_to=' || p_fin_targets_tbl(i).financial_target_to );
        -- Check to make sure TO target is greater than FROM target
        if p_fin_targets_tbl(i).financial_target_from > p_fin_targets_tbl(i).financial_target_to
          then
            -- get translatable value of Financial metric in order to display appropriate error.
            SELECT meaning
              INTO l_target_name
              FROM fpa_lookups_v
             WHERE lookup_type = 'FPA_PC_FIN_TARGETS'
               AND lookup_code = p_fin_targets_tbl(i).financial_metrics;
            --  Set error message.
            FND_MESSAGE.SET_NAME('FPA','FPA_TARGET_FROM_GT_TO');
            FND_MESSAGE.SET_TOKEN('FINMETRIC', l_target_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

	-- Limit financial_metrics_d
              l_financial_target_from_c := REPLACE( To_Char(p_fin_targets_tbl(i).financial_target_from*l_pc_disply_factor), l_decimal_marker,'.');
 	      l_financial_target_to_c := REPLACE( To_Char(p_fin_targets_tbl(i).financial_target_to*l_pc_disply_factor), l_decimal_marker,'.');

	      dbms_aw.execute('LMT financial_metrics_d TO ''' || p_fin_targets_tbl(i).financial_metrics || '''' );
	-- Set the targets from for each fin matric
          --dbms_aw.execute('pc_fintargets_range_from_m = ' || p_fin_targets_tbl(i).financial_target_from*l_pc_disply_factor );
            dbms_aw.execute('pc_fintargets_range_from_m = ' || l_financial_target_from_c );
	-- Set the targets to for each fin matric
          --dbms_aw.execute('pc_fintargets_range_to_m = ' || p_fin_targets_tbl(i).financial_target_to*l_pc_disply_factor );
            dbms_aw.execute('pc_fintargets_range_to_m = ' || l_financial_target_to_c );
         END LOOP;


	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Fin_Targets.end',
			'Exiting FPA_PlanningCycle_Pvt.Update_Pc_Fin_Targets'
		);
	END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
  	WHEN OTHERS THEN
        --DBMS_OUTPUT.put_line('...Inside Object level API EXCEPTION block...');

		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR  THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Fin_Targets',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Pc_Fin_Targets;

PROCEDURE Update_Pc_Inv_Criteria_Data
     ( p_api_version        IN NUMBER,
       p_inv_crit_tbl       IN fpa_pc_inv_criteria_tbl,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS
l_pc_obj varchar2(3);

BEGIN

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		( FND_LOG.LEVEL_PROCEDURE,
	       	'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data.begin',
		'Entering FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data'
		);
	END IF;

      --DBMS_OUTPUT.put_line(' ..Inside if in Update_Pc_Inv_Criteria_Data...');

      --DBMS_OUTPUT.put_line(' ..p_inv_crit_tbl(1).planning_cycle=' || p_inv_crit_tbl(1).planning_cycle );
      --DBMS_OUTPUT.put_line(' ..p_inv_crit_tbl(1).pc_project_score_source=' || p_inv_crit_tbl(1).pc_project_score_source );
      --DBMS_OUTPUT.put_line(' ..p_inv_crit_tbl(1).pc_project_score_scale=' || p_inv_crit_tbl(1).pc_project_score_scale );

	-- Update the investment criteria data
	-- Limit PCID
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
                'Limit pc dimension to ' || p_inv_crit_tbl(1).planning_cycle || ' value.'
                );
        END IF;
	  dbms_aw.execute('LMT planning_cycle_d TO ' || p_inv_crit_tbl(1).planning_cycle);

 	-- Set the score source
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
                'Setting score_type_pc_r to: ' || p_inv_crit_tbl(1).pc_project_score_source || ' value.'
                );
        END IF;
        dbms_aw.execute('score_type_pc_r = ''' || p_inv_crit_tbl(1).pc_project_score_source || '''');

    -- Set the score scale
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
                'Setting pc_project_score_scale_m to: ' || p_inv_crit_tbl(1).pc_project_score_scale || ' value.'
                );
        END IF;
          dbms_aw.execute('pc_project_score_scale_m = ' || p_inv_crit_tbl(1).pc_project_score_scale );


      FOR i IN p_inv_crit_tbl.FIRST..p_inv_crit_tbl.LAST
        LOOP

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
                'Debugging, we are in ' || i || ' value.'
                );
        END IF;


	-- Limit strategic_obj_d
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
                'Limit strategic_obj_d dimension to ' || p_inv_crit_tbl(i).investment_criteria || ' value.'
                );
        END IF;
	dbms_aw.execute('LMT strategic_obj_d TO ' || p_inv_crit_tbl(i).investment_criteria );

          --DBMS_OUTPUT.put_line(' ..Inside For loop...after setting p_inv_crit_tbl(i).investment_criteria' );

	-- Set the weights for each strategic_obj
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
                'Setting pc_strategic_obj_weights_m: ' || p_inv_crit_tbl(i).pc_inv_criteria_weight || ' value.'
                );
        END IF;
        dbms_aw.execute('pc_strategic_obj_weights_m = ' || p_inv_crit_tbl(i).pc_inv_criteria_weight );

          --DBMS_OUTPUT.put_line(' ..Inside For loop...after setting p_inv_crit_tbl(i).pc_inv_criteria_weight' );

	-- Set the target from for each strategic_obj
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
                'Setting pc_obj_wscore_targets_from_m: ' || p_inv_crit_tbl(i).pc_inv_crit_score_target_from || ' value.'
                );
        END IF;

	-- If the target_from value from UI is null, update it in AW with NA

        IF p_inv_crit_tbl(i).pc_inv_crit_score_target_from IS NULL THEN
          dbms_aw.execute('pc_obj_wscore_targets_from_m = NA');
        ELSE
          dbms_aw.execute('pc_obj_wscore_targets_from_m = ' || p_inv_crit_tbl(i).pc_inv_crit_score_target_from );
        END IF;

         --DBMS_OUTPUT.put_line(' ..Inside For loop...after setting p_inv_crit_tbl(i).pc_inv_crit_score_target_from' );

	-- Set the target to for each strategic_obj
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
                'Setting pc_obj_wscore_targets_to_m: ' || p_inv_crit_tbl(i).pc_inv_crit_score_target_to || ' value.'
                );
        END IF;
	-- If the target_to value from UI is null, update it in AW with NA

        IF p_inv_crit_tbl(i).pc_inv_crit_score_target_to IS NULL THEN
          dbms_aw.execute('pc_obj_wscore_targets_to_m = NA');
		ELSE
          dbms_aw.execute('pc_obj_wscore_targets_to_m = ' || p_inv_crit_tbl(i).pc_inv_crit_score_target_to );
        END IF;
         --DBMS_OUTPUT.put_line(' ..Inside For loop...after setting p_inv_crit_tbl(i).pc_inv_crit_score_target_to' );

        END LOOP;

/*
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
                'Calling AW program: set_pc_invest_criteria_prg( ' || p_inv_crit_tbl(1).planning_cycle || ').'
                );
        END IF;
        dbms_aw.execute('call set_pc_invest_criteria_prg(' || p_inv_crit_tbl(1).planning_cycle || ')');
*/


	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data.end',
			'Exiting FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data'
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
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Pc_Inv_Criteria_Data;


PROCEDURE Update_Pc_Desc_Fields
     ( p_api_version        IN NUMBER,
       p_pc_all_obj         IN fpa_pc_all_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS

BEGIN

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Desc_Fields.begin',
			'Entering FPA_PlanningCycle_Pvt.Update_Pc_Desc_Fields'
		);
	END IF;

	-- Update name and description

    --DBMS_OUTPUT.put_line('Before Updating Update_Pc_Desc_Fields...');

    UPDATE FPA_OBJECTS_TL
    SET  name = p_pc_all_obj.pc_desc_fields.name
        ,description = p_pc_all_obj.pc_desc_fields.description
        ,SOURCE_LANG     = userenv('LANG')
        ,last_update_date = sysdate()
    WHERE id = p_pc_all_obj.pc_desc_fields.id
    AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
    AND OBJECT = 'PLANNING_CYCLE'; --Added for bug 6142322

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Desc_Fields.end',
			'Exiting FPA_PlanningCycle_Pvt.Update_Pc_Desc_Fields'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR  THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Desc_Fields',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Pc_Desc_Fields;

PROCEDURE Set_Pc_Status
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       p_pc_status_code     IN VARCHAR2,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS

BEGIN
    --DBMS_OUTPUT.put_line('Inside Set_Pc_Status....');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Status.begin',
			'Entering FPA_PlanningCycle_Pvt.Set_Pc_Status'
		);
	END IF;
    --DBMS_OUTPUT.put_line('Before limiting planning_cycle_d to: ' || p_pc_id );

	-- Update the status
	dbms_aw.execute('LMT planning_cycle_d TO ' || p_pc_id );

    --DBMS_OUTPUT.put_line('Before setting status_pc_r ....');
	-- Set the new staus
	dbms_aw.execute('status_pc_r = ''' || p_pc_status_code || '''');


	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Status.end',
			'Exiting FPA_PlanningCycle_Pvt.Set_Pc_Status'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Status',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Set_Pc_Status;

PROCEDURE Set_Pc_Initiate_Date
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS
BEGIN
    --DBMS_OUTPUT.put_line('Inside Set_Pc_Initiate_Date....');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Initiate_Date.begin',
			'Entering FPA_PlanningCycle_Pvt.Set_Pc_Initiate_Date'
		);
	END IF;
    --DBMS_OUTPUT.put_line('Before limiting planning_cycle_d to: ' || p_pc_id );

	-- Limit the PC ID
	dbms_aw.execute('LMT planning_cycle_d TO ' || p_pc_id );

	-- Set the new Initiate Date

    BEGIN
	-- Add new Day to the Day_d dimension
/*	dbms_aw.execute('MAINTAIN day_d ADD '''
        || to_char(to_date(p_pc_init_date, 'DD-MON-YYYY'), 'DDMONYYYY' || ''''));
*/
    dbms_aw.execute('MAINTAIN day_d ADD ''' || to_char(SYSDATE, 'MMDDYYYY') || '''' );   -- Bug 9264707
    EXCEPTION
   	    WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLCODE);
  	    -- Check for existing dim values, if it already exists during MAINTAIN, then ignore it.
  	        IF SQLCODE = -34034 THEN
			    NULL;
            END IF;
     END;
    -- Set the new Initiate Date
    --DBMS_OUTPUT.PUT_LINE('....pc_initiate_date:' || SYSDATE);



    dbms_aw.execute('pc_initiate_date_r = ''' || to_char(SYSDATE, 'MMDDYYYY') || '''');   -- Bug 9264707

/*
    dbms_aw.execute('pc_initiate_date_r = '''
        || to_char(to_date(p_pc_init_date, 'DD-MON-YYYY'), 'DDMONYYYY' || ''''));
*/

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Initiate_Date.end',
			'Exiting FPA_PlanningCycle_Pvt.Set_Pc_Initiate_Date'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Initiate',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Set_Pc_Initiate_Date;


PROCEDURE Update_Pc_Class_Category
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       p_catg_id            IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS

BEGIN
    --DBMS_OUTPUT.put_line('Inside Update_Pc_Class_Category....');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Class_Category.begin',
			'Entering FPA_PlanningCycle_Pvt.Update_Pc_Class_Category'
		);
	END IF;
    --DBMS_OUTPUT.put_line('Before limiting planning_cycle_d to: ' || p_pc_id );

	-- Update the Basic Info
	-- Limit PCID
	dbms_aw.execute('LMT planning_cycle_d TO ' || p_pc_id );

    --DBMS_OUTPUT.put_line('Before setting pc_class_code_m ....');
	-- Set the new class category
	dbms_aw.execute('pc_category_m = ''' || p_catg_id || '''');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Class_Category.end',
			'Exiting FPA_PlanningCycle_Pvt.Update_Pc_Class_Category'
		);
	END IF;

EXCEPTION
   	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Class_Category',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Pc_Class_Category;

PROCEDURE Update_Pc_Calendar
     ( p_api_version        IN NUMBER,
       p_pc_info            IN fpa_pc_info_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS

BEGIN
    --DBMS_OUTPUT.put_line('Inside Update_Pc_Calendar....');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Calendar.begin',
			'Entering FPA_PlanningCycle_Pvt.Update_Pc_Calendar'
		);
	END IF;
    --DBMS_OUTPUT.put_line('Before limiting planning_cycle_d to: ' || p_pc_info.planning_cycle );

	-- Update the Calendar
	-- Limit PCID
	dbms_aw.execute('LMT planning_cycle_d TO ' || p_pc_info.planning_cycle );

    --DBMS_OUTPUT.put_line('Before setting Update_Pc_Calendar ....');
    BEGIN
	-- Add new calendar to the dimension
	    dbms_aw.execute('MAINTAIN calendar_d ADD ''' || p_pc_info.calendar_name || '''');
    EXCEPTION
   	    WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLCODE);
  	    -- Check for existing dim values, if it already exists during MAINTAIN, then ignore it.
  	        IF SQLCODE = -34034 THEN
			    NULL;
            END IF;
     END;
	-- Set the new calendar
	dbms_aw.execute('calendar_pc_r = ''' || p_pc_info.calendar_name || '''');

    BEGIN
	-- Add new Period Type to the dimension
	dbms_aw.execute('MAINTAIN period_type_d ADD ''' || p_pc_info.period_type || '''');
    EXCEPTION
   	    WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLCODE);
  	    -- Check for existing dim values, if it already exists during MAINTAIN, then ignore it.
  	        IF SQLCODE = -34034 THEN
			    NULL;
            END IF;
     END;
    -- Set the new Period Type
	dbms_aw.execute('period_type_pc_r = ''' || p_pc_info.period_type || '''');

    BEGIN
        -- Add new Calendar Period Type to the dimension
	    dbms_aw.execute('MAINTAIN cal_period_type_d ADD ''' || p_pc_info.calendar_name || '.' || p_pc_info.period_type || '''');
    EXCEPTION
   	    WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLCODE);
  	    -- Check for existing dim values, if it already exists during MAINTAIN, then ignore it.
  	        IF SQLCODE = -34034 THEN
			    NULL;
            END IF;
     END;
    -- Set the new Calendar Period Type
	dbms_aw.execute('cal_period_type_pc_r = ''' || p_pc_info.calendar_name || '.' || p_pc_info.period_type || '''');

	dbms_aw.execute('pc_funding_period_from_m = ''' || p_pc_info.funding_period_from || '''');

	dbms_aw.execute('pc_funding_period_to_m = ''' || p_pc_info.funding_period_to || '''');

	dbms_aw.execute('pc_effective_period_to_m = ''' || p_pc_info.effective_period_to || '''');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Calendar.end',
			'Exiting FPA_PlanningCycle_Pvt.Update_Pc_Calendar'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
        ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Calendar',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Pc_Calendar;

PROCEDURE Update_Pc_Currency
     ( p_api_version        IN NUMBER,
       p_pc_info            IN fpa_pc_info_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS

BEGIN
    --DBMS_OUTPUT.put_line('Inside Update_Pc_Currency....');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(FND_LOG.LEVEL_PROCEDURE,
		 'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Currency.begin',
		 'Entering FPA_PlanningCycle_Pvt.Update_Pc_Currency'
		);
	END IF;
    --DBMS_OUTPUT.put_line('Before limiting planning_cycle_d to: ' || p_pc_info.planning_cycle );

	-- Update the Currency
	-- Limit PCID
	dbms_aw.execute('LMT planning_cycle_d TO ' || p_pc_info.planning_cycle );

    --DBMS_OUTPUT.put_line('Before setting Update_Pc_Currency ....');
	-- Set the new Currency

	dbms_aw.execute('pc_currency_m = ''' || p_pc_info.currency_code || '''');

	dbms_aw.execute('pc_conversion_rate_type_m = ''' || p_pc_info.conversion_rate_type || '''');

--    BEGIN
	-- Add new Day to the dimension
--	    dbms_aw.execute('MAINTAIN day_d ADD ''' || p_pc_info.conversion_rate_date || '''');
--    EXCEPTION
 --  	    WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLCODE);
  	    -- Check for existing dim values, if it already exists during MAINTAIN, then ignore it.
  --	        IF SQLCODE = -34034 THEN
--			    NULL;
 --           END IF;
         -- RAISE ;  -- need to put this later
 --    END;

    --DBMS_OUTPUT.PUT_LINE('....conversion_rate_date:' || p_pc_info.conversion_rate_date);

    -- If conversion rate date is not null then set relation to that value
    -- else set it to todays date.
    if p_pc_info.conversion_rate_date is not null
      then
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (FND_LOG.LEVEL_PROCEDURE,
                 'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Currency',
                 'Setting currency_date_pc_r to : ' || to_char(fnd_date.chardate_to_date(p_pc_info.conversion_rate_date), 'MMDDYYYY' || '''') || ' value.'  -- Bug 9264707
                );
        END IF;

	--Bug 4254274 : Applying to_date function on variable of type character i.e p_pc_info.conversion_rate_date
	--              was raising error 'literal does not match format string'

        dbms_aw.execute('currency_date_pc_r = '''
        ||  to_char(fnd_date.chardate_to_date(p_pc_info.conversion_rate_date), 'MMDDYYYY' || ''''));  -- Bug 9264707

        /*dbms_aw.execute('currency_date_pc_r = '''
        || to_char(to_date(p_pc_info.conversion_rate_date,
                        'DD-MON-YYYY'), 'DDMONYYYY' || ''''));*/
    else
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (FND_LOG.LEVEL_PROCEDURE,
                 'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Currency',
                 'Setting currency_date_pc_r to sysdate value.'||to_char(sysdate,'MMDDYYYY' || '''')  -- Bug 9264707
                );
        END IF;

      --Bug 4254274 : Applying hard coded format for to_date function on sysdate which is in nls_date_format
      --              was raising error 'literal does not match format string'

      dbms_aw.execute('currency_date_pc_r = '''
        || to_char(sysdate,'MMDDYYYY' || ''''));  -- Bug 9264707

      /*dbms_aw.execute('currency_date_pc_r = '''
        || to_char(to_date(sysdate,
                        'DD-MON-YYYY'), 'DDMONYYYY' || ''''));*/
    end if;

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Currency.end',
			'Exiting FPA_PlanningCycle_Pvt.Update_Pc_Currency'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Currency',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Pc_Currency;


PROCEDURE Update_Pc_Sub_Due_Date
     ( p_api_version        IN NUMBER,
       p_pc_info            IN fpa_pc_info_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS

BEGIN
    --DBMS_OUTPUT.put_line('Inside Update_Pc_Sub_Due_Date....');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Sub_Due_Date.begin',
			'Entering FPA_PlanningCycle_Pvt.Update_Pc_Sub_Due_Date'
		);
	END IF;
    --DBMS_OUTPUT.put_line('Before limiting planning_cycle_d to: ' || p_pc_info.planning_cycle );

	-- Update the Currency
	-- Limit PCID
	dbms_aw.execute('LMT planning_cycle_d TO ' || p_pc_info.planning_cycle );

    --DBMS_OUTPUT.put_line('Before setting submission_due_date ....');

    BEGIN
	-- Add new Day to the dimension
	    dbms_aw.execute('MAINTAIN day_d ADD ''' || to_char(p_pc_info.submission_due_date, 'MMDDYYYY' || ''''));  -- Bug 9264707
    EXCEPTION
   	    WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLCODE);
  	    -- Check for existing dim values, if it already exists during MAINTAIN, then ignore it.
  	        IF SQLCODE = -34034 THEN
			    NULL;
            END IF;
         -- RAISE ;  -- need to put this later
     END;

    --DBMS_OUTPUT.PUT_LINE('....submission_due_date:' || p_pc_info.submission_due_date);

    --Bug 4254274 : Applying to_date function on variable of type character i.e p_pc_info.submission_due_date
    --              was raising error 'literal does not match format string'

    dbms_aw.execute('pc_submission_due_date_r = '''
        || to_char(fnd_date.chardate_to_date(p_pc_info.submission_due_date), 'MMDDYYYY' || ''''));  -- Bug 9264707

    /*dbms_aw.execute('pc_submission_due_date_r = '''
        || to_char(to_date(p_pc_info.submission_due_date,
			'DD-MON-YYYY'), 'DDMONYYYY' || ''''));*/

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Sub_Due_Date.end',
			'Exiting FPA_PlanningCycle_Pvt.Update_Pc_Sub_Due_Date'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Sub_Due_Date',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Pc_Sub_Due_Date;



PROCEDURE Update_Pc_Discount_funds
     ( p_api_version        IN NUMBER,
       p_disc_funds         IN fpa_pc_discount_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS
l_decimal_marker VARCHAR2(1) ;
l_thousands_marker VARCHAR2(1) ;
l_pc_discount_rate_c VARCHAR2(100) ;
l_pc_funding_c VARCHAR2(100);

BEGIN
    --DBMS_OUTPUT.put_line('Inside Update_Pc_Discount_funds....');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Discount_funds.begin',
			'Entering FPA_PlanningCycle_Pvt.Update_Pc_Discount_funds'
		);
	END IF;

    --DBMS_OUTPUT.put_line('Before limiting planning_cycle_d to: ' || p_disc_funds.planning_cycle );

  	-- Update the Discount
    -- Limit PCID
    dbms_aw.execute('LMT planning_cycle_d TO ' || p_disc_funds.planning_cycle);

    --DBMS_OUTPUT.put_line('Before setting pc_discount_rate ....'|| p_disc_funds.pc_discount_rate);
    -- Set the new pc_discount_rate
    -- Bug Ref : 8882256
     SELECT SUBSTR(VALUE,1,1)
       INTO l_decimal_marker
       FROM NLS_SESSION_PARAMETERS
      WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';
    l_pc_discount_rate_c := REPLACE( To_Char(p_disc_funds.pc_discount_rate/100), l_decimal_marker,'.');
    dbms_aw.execute('pc_discount_rate_m = ' || l_pc_discount_rate_c);

    --DBMS_OUTPUT.put_line('Before setting pc funding....' || p_disc_funds.pc_funding);

  	-- Set the new funds
    l_pc_funding_c := REPLACE( To_Char(p_disc_funds.pc_funding), l_decimal_marker,'.');
    dbms_aw.execute('pc_funding_m = ' || l_pc_funding_c );
    --DBMS_OUTPUT.put_line('Before setting factor_d and factor_pc_r....' || p_disc_funds.pc_display_factor);

    dbms_aw.execute('factor_pc_r = ''' || p_disc_funds.pc_display_factor || '''' );


    --DBMS_OUTPUT.put_line('Outside IF p_disc_funds IS NOT NULL .... ');

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Discount_funds.end',
			'Exiting FPA_PlanningCycle_Pvt.Update_Pc_Discount_funds'
		);
	END IF;

EXCEPTION
   	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Discount_funds',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Update_Pc_Discount_funds;


FUNCTION Check_Pc_Name
     ( p_api_version        IN NUMBER,
       p_portfolio_id       IN NUMBER,
       p_pc_name            IN VARCHAR2,
       p_pc_id              IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER)
RETURN number

IS

l_pcName_Count NUMBER;

BEGIN

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Check_Pc_Name.begin',
			'Entering FPA_PlanningCycle_Pvt.Check_Pc_Name'
		);
	END IF;

	IF (p_pc_id is null) THEN
        SELECT count(p.name)
        INTO l_pcName_Count
        FROM fpa_aw_pc_info_v a, fpa_pcs_vl p
        WHERE a.planning_cycle = p.planning_cycle
        AND portfolio = p_portfolio_id
        AND p.name = p_pc_name ;
        --DBMS_OUTPUT.put_line('Inside pc_id = null');
	ELSE
        SELECT count(p.name)
        INTO l_pcName_Count
        FROM fpa_aw_pc_info_v a, fpa_pcs_vl p
        WHERE a.planning_cycle = p.planning_cycle
        AND portfolio = p_portfolio_id
        AND p.name = p_pc_name
        AND a.planning_cycle <> p_pc_id ;
	END IF;

RETURN l_pcName_Count;

	IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE  THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_PlanningCycle_Pvt.Check_Pc_Name.end',
			'Exiting FPA_PlanningCycle_Pvt.Check_Pc_Name'
		);
	END IF;

EXCEPTION
  	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR  THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_PlanningCycle_Pvt.Check_Pc_Name',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Check_Pc_Name;


PROCEDURE Pa_Distrb_Lists_Insert_Row (
       p_api_version    IN NUMBER,
       p_distr_list     IN fpa_pc_distr_list_obj,
       p_list_id 	    IN OUT NOCOPY NUMBER,
       x_return_status  OUT NOCOPY VARCHAR2,
       x_msg_data       OUT NOCOPY VARCHAR2,
       x_msg_count      OUT NOCOPY NUMBER )

IS
l_list_id NUMBER;
l_obj_name VARCHAR2(80);
BEGIN
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Process_Pvt.Pa_Distrb_Lists_Insert_Row.begin',
			'Entering FPA_Process_Pvt.Pa_Distrb_Lists_Insert_Row'
		);
	END IF;

    l_obj_name := p_distr_list.name || '_' ||p_distr_list.object_id;

     PA_DISTRIBUTION_LISTS_PKG.INSERT_ROW
            (
                P_LIST_ID => l_list_id,
                P_NAME => l_obj_name,
                P_DESCRIPTION => p_distr_list.description,
                P_RECORD_VERSION_NUMBER => NULL,
                P_CREATED_BY =>	fnd_global.user_id,
                P_CREATION_DATE => sysdate,
                P_LAST_UPDATED_BY => fnd_global.user_id,
                P_LAST_UPDATE_DATE => sysdate,
                P_LAST_UPDATE_LOGIN => fnd_global.user_id
            );

     p_list_id := l_list_id;


     PA_OBJECT_DIST_LISTS_PKG.INSERT_ROW
            (
                P_LIST_ID => l_list_id,
                P_OBJECT_TYPE => p_distr_list.object_type,
                P_OBJECT_ID => p_distr_list.object_id,
                P_RECORD_VERSION_NUMBER => NULL,
                P_CREATED_BY =>	fnd_global.user_id,
                P_CREATION_DATE => sysdate,
                P_LAST_UPDATED_BY => fnd_global.user_id,
                P_LAST_UPDATE_DATE => sysdate,
                P_LAST_UPDATE_LOGIN => fnd_global.user_id
            );


     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Process_Pvt.Pa_Distrb_Lists_Insert_Row.end',
			'Exiting FPA_Process_Pvt.Pa_Distrb_Lists_Insert_Row'
		);
	 END IF;


EXCEPTION
  	WHEN OTHERS THEN
     ----DBMS_OUTPUT.put_line('...Inside EXCEPTION block...');
		ROLLBACK;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_Process_Pvt.Pa_Distrb_Lists_Insert_Row',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Pa_Distrb_Lists_Insert_Row;


PROCEDURE Pa_Dist_List_Items_Update_Row (
       p_api_version           IN NUMBER,
       p_distr_list_items_tbl  fpa_pc_distr_list_items_tbl,
       x_return_status         OUT NOCOPY VARCHAR2,
       x_msg_data              OUT NOCOPY VARCHAR2,
       x_msg_count             OUT NOCOPY NUMBER )
IS
l_list_item_id NUMBER;
l_list_id NUMBER;
BEGIN
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row.begin',
			'Entering FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row'
		);
	END IF;


    -- If you don't get the list id from java, get it from pa_object_dist_lists
    IF p_distr_list_items_tbl(1).list_id IS NULL THEN
       BEGIN
         SELECT list_id INTO l_list_id
   	     FROM  pa_object_dist_lists
         WHERE object_id = p_distr_list_items_tbl(1).planning_cycle
		 AND object_type = 'PJP_PLANNING_CYCLE';
       EXCEPTION
         WHEN others THEN
          l_list_id := -1;
       END;
    ELSE
       l_list_id := p_distr_list_items_tbl(1).list_id ;
    END IF;


     IF p_distr_list_items_tbl IS NOT NULL THEN

      FOR i IN p_distr_list_items_tbl.FIRST..p_distr_list_items_tbl.LAST
        LOOP

          IF p_distr_list_items_tbl(i).list_item_id IS NOT NULL THEN

          --   call update
              --DBMS_OUTPUT.put_line('... before update in Pa_Dist_List_Items_Update_Row...update row..');

              PA_DIST_LIST_ITEMS_PKG.Update_Row
                (
                    P_LIST_ITEM_ID   => p_distr_list_items_tbl(i).list_item_id,
                    P_LIST_ID        => l_list_id,
                    P_RECIPIENT_TYPE => p_distr_list_items_tbl(i).recipient_type,
                    P_RECIPIENT_ID   => p_distr_list_items_tbl(i).recipient_id,
                    P_ACCESS_LEVEL   => NULL,
                    P_MENU_ID        => NULL,
                    P_EMAIL          => p_distr_list_items_tbl(i).email_exists,
                    P_RECORD_VERSION_NUMBER => NULL,
                    P_LAST_UPDATED_BY   => fnd_global.user_id,
                    P_LAST_UPDATE_DATE  => sysdate,
                    P_LAST_UPDATE_LOGIN => fnd_global.user_id
                );

          ELSE

             -- call insert , set listItemId
                --DBMS_OUTPUT.put_line('... before insert in Pa_Dist_List_Items_Update_Row...insert row..');

                PA_DIST_LIST_ITEMS_PKG.INSERT_ROW
                 (
                    P_LIST_ITEM_ID => l_list_item_id,
                    P_LIST_ID => l_list_id,
                    P_RECIPIENT_TYPE => p_distr_list_items_tbl(i).recipient_type,
                    P_RECIPIENT_ID => p_distr_list_items_tbl(i).recipient_id,
                    P_ACCESS_LEVEL => NULL,
                    P_MENU_ID => NULL,
                    P_EMAIL => p_distr_list_items_tbl(i).email_exists,
                    P_RECORD_VERSION_NUMBER => NULL,
                    P_CREATED_BY =>	fnd_global.user_id,
                    P_CREATION_DATE => sysdate,
                    P_LAST_UPDATED_BY => fnd_global.user_id,
                    P_LAST_UPDATE_DATE => sysdate,
                    P_LAST_UPDATE_LOGIN => fnd_global.user_id
                 );


          END IF;

       END LOOP;

     END IF;

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row.end',
			'Exiting FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row'
		);
	 END IF;


EXCEPTION
  	WHEN OTHERS THEN
     --DBMS_OUTPUT.put_line('...Inside EXCEPTION block...');
		ROLLBACK;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.String
		(
			FND_LOG.LEVEL_ERROR,
			'fpa.sql.FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row',
			SQLERRM
		);
		END IF;

		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Pa_Dist_List_Items_Update_Row;

PROCEDURE Set_Pc_Investment_Criteria (
       p_api_version           IN NUMBER,
       p_pc_id                  IN NUMBER,
       x_return_status         OUT NOCOPY VARCHAR2,
       x_msg_data              OUT NOCOPY VARCHAR2,
       x_msg_count             OUT NOCOPY NUMBER ) is

l_api_version			CONSTANT NUMBER := 1.0;

begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_planningcycle_pvt.Set_Pc_Investment_Criteria.begin',
      'Entering fpa_planningcycle_pvt.Set_Pc_Investment_Criteria.'
     );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_planningcycle_pvt.Set_Pc_Investment_Criteria.begin',
      'Calling AW Program SET_PC_INVEST_CRITERIA_PRG.'
     );
  END IF;

  dbms_aw.execute('call SET_PC_INVEST_CRITERIA_PRG(' || p_pc_id || ')');

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
      FND_LOG.LEVEL_PROCEDURE,
      'fpa.sql.fpa_planningcycle_pvt.Set_Pc_Investment_Criteria.end',
      'Entering fpa_planningcycle_pvt.Set_Pc_Investment_Criteria.'
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
        'fpa.sql.fpa_planningcycle_pvt.Set_Pc_Investment_Criteria',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

end Set_Pc_Investment_Criteria;

PROCEDURE Set_Pc_Approved_Flag
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
is

l_api_version                   CONSTANT NUMBER := 1.0;

begin

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag.begin',
                        'Entering FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag'
                );
        END IF;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag',
                        'Limiting to passed PC id'
                );
        END IF;

        dbms_aw.execute('push planning_cycle_d');
        dbms_aw.execute('push portfolio_d');
        dbms_aw.execute('oknullstatus = y');
        dbms_aw.execute('limit planning_cycle_d to ' || p_pc_id);

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag',
                        'Limiting to portfolio for passed PC id'
                );
        END IF;
        dbms_aw.execute('limit portfolio_d to portfolio_pc_r');

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag',
                        'Limiting to planning cycles for the same portfolio'
                );
        END IF;
        dbms_aw.execute('limit planning_cycle_d to portfolio_d');

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag',
                        'Reset last approved flag'
                );
        END IF;
        dbms_aw.execute('pc_last_approved_flag_m = na');

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag',
                        'Setting last approved flag to passed pc ID'
                );
        END IF;
        dbms_aw.execute('limit planning_cycle_d to ' || p_pc_id);
        dbms_aw.execute('pc_last_approved_flag_m = yes');
        dbms_aw.execute('pop planning_cycle_d');
        dbms_aw.execute('pop portfolio_d');

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag.end',
                        'Exiting fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag.end'
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
        'fpa.sql.fpa_planningcycle_pvt.Set_Pc_Approved_Flag',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

end Set_Pc_Approved_Flag;

PROCEDURE Set_Pc_Last_Flag
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
is

l_api_version                   CONSTANT NUMBER := 1.0;

begin

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag.begin',
                        'Entering FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag'
                );
        END IF;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag',
                        'Limiting to passed PC id'
                );
        END IF;

        dbms_aw.execute('push planning_cycle_d');
        dbms_aw.execute('push portfolio_d');
        dbms_aw.execute('oknullstatus = y');
        dbms_aw.execute('limit planning_cycle_d to ' || p_pc_id);

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag',
                        'Limiting to portfolio for passed PC id'
                );
        END IF;
        dbms_aw.execute('limit portfolio_d to portfolio_pc_r');

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag',
                        'Limiting to planning cycles for the same portfolio'
                );
        END IF;
        dbms_aw.execute('limit planning_cycle_d to portfolio_d');

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag',
                        'Reset last approved flag'
                );
        END IF;
        dbms_aw.execute('pc_last_flag_m = na');

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag',
                        'Setting last approved flag to passed pc ID'
                );
        END IF;
        dbms_aw.execute('limit planning_cycle_d to ' || p_pc_id);
        dbms_aw.execute('pc_last_flag_m = yes');
        dbms_aw.execute('pop planning_cycle_d');
        dbms_aw.execute('pop portfolio_d');

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag.end',
                        'Exiting fpa.sql.FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag'
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
        'fpa.sql.fpa_planningcycle_pvt.Set_Pc_Approved_Flag',
        SQLERRM
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_count    =>      x_msg_count,
      p_data     =>      x_msg_data
    );
    RAISE;

end Set_Pc_Last_Flag;

/*************************************************************************************
*************************************************************************************/

-- Procedure Update_Pc_Annual_Disc_Rates updates annual discount rates for any planning
-- cycle.

PROCEDURE Update_Pc_Annual_Disc_Rates
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       p_period             IN VARCHAR2,
       p_rate               IN VARCHAR2,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
is

  l_api_version            CONSTANT NUMBER    := 1.0;

begin

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (FND_LOG.LEVEL_PROCEDURE,
     'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Annual_Disc_Rates.begin',
     'Entering FPA_PlanningCycle_Pvt.Update_Pc_Annual_Disc_Rates');
  END IF;

  IF l_api_version <> p_api_version THEN
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING
      ( FND_LOG.LEVEL_PROCEDURE,
       'FPA.SQL.FPA_PlanningCycle_Pvt.Update_Pc_Annual_Disc_Rates.',
       'Checking API version.');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (FND_LOG.LEVEL_PROCEDURE,
     'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Annual_Disc_Rates.',
     'Updating Annual discount rates for the PC in AW.');
  END IF;

  dbms_aw.execute('lmt planning_cycle_d to ' || p_pc_id);
  dbms_aw.execute('lmt time_d to ''' || p_period || '''');
  dbms_aw.execute('pc_discount_rate_t_m = ' ||  p_rate);

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (FND_LOG.LEVEL_PROCEDURE,
     'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Annual_Disc_Rates.',
     'Done Updating  Annual discount rates for the PC in AW.');
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (FND_LOG.LEVEL_PROCEDURE,
     'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Annual_Disc_Rates.end',
     'Entering FPA_PlanningCycle_Pvt.Update_Pc_Annual_Disc_Rates');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.String
      ( FND_LOG.LEVEL_ERROR,
        'fpa.sql.FPA_PlanningCycle_Pvt.Update_Pc_Annual_Disc_Rates',
        SQLERRM);
    END IF;

    FND_MSG_PUB.count_and_get
    ( p_count    =>      x_msg_count,
      p_data     =>      x_msg_data);

    RAISE;

END Update_Pc_Annual_Disc_Rates;


END FPA_PLANNINGCYCLE_PVT;


/
