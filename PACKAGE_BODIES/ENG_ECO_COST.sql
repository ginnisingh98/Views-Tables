--------------------------------------------------------
--  DDL for Package Body ENG_ECO_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ECO_COST" AS
/* $Header: ENGCOSTB.pls 120.1 2006/01/16 03:34:54 rnarveka noship $ */

	TYPE cost_record_type IS RECORD (
                        revised_item_id NUMBER,
                        item_cost       NUMBER );

	TYPE repetative_record_type IS RECORD (
			item_cost	NUMBER,
			demand_quantity	NUMBER,
			period_name_year VARCHAR2(8)
			);

        TYPE eco_cost_table IS TABLE OF cost_record_type
                 INDEX BY BINARY_INTEGER;

	TYPE Rep_Table_Type IS TABLE OF repetative_record_type
		INDEX BY BINARY_INTEGER;

	l_repetative_cost_table Rep_Table_Type;
	l_eco_cost_table 	Eco_Cost_Table;

	/* Function: Calc_Cost_Of_Items_On_Eco

	   Description:
	   Function will calculate the material cost of the items that exist on the Eco and
	   will return this cost as the cost of the items as they exist in production.

	   Parameters: 	change_notice varchar2(10)
			org_id number;

	   Return value: Number

	*/

	FUNCTION Calc_Cost_Of_Items_On_Eco ( p_change_notice IN varchar2,
					     p_org_id 	     IN number )
		 RETURN NUMBER
	IS
	l_items_cost number;
	BEGIN

		SELECT sum(cic.material_cost)
		  INTO l_items_cost
		  FROM cst_item_costs cic,
		       eng_revised_items eri
		 WHERE eri.change_notice = p_change_notice
		   AND eri.organization_id = p_org_id
		   AND cic.inventory_item_id = eri.revised_item_id
		   AND cic.organization_id = eri.organization_id
		   AND cic.cost_type_id = 1;

		-- if no exception is raised, then return the value of l_items_cost
		RETURN l_items_cost;

		EXCEPTION
			WHEN OTHERS THEN
				return 0;
	END Calc_Cost_Of_Items_On_Eco;


	/* Procedure: Calc_Cost_Of_Changes

           Description:
	   Procedure will calculate the changes that their cost, sum it all together to
	   give the cost of changes on the ECO.
	   If there is a change operation and the existing quantity is changed from 6 to 2
	   then the final change in cost is -4 * cost of that item. If this cost is added to
	   the cost of the assembly as it exists in production it will give the cost of the
	   the item after the ECO is eimplemented. Similary when an item is added on a bill
	   the cost of that item will be added to the original bill and if an item is being
	   deleted, then the cost will be deducted from the cost of the assembly.
	   Cost of an item will be ( planning % of Quantity ) * material cost of that item.

           Parameters:  change_notice varchar2(10)
                        org_id number;

           Return value: None, but will create a pl/sql table .

        */

	PROCEDURE Calc_Cost_Of_Changes ( p_change_notice 	IN varchar2,
				        p_org_id		IN number)
	IS
		CURSOR cost_of_change IS
		SELECT eri.revised_item_id,
		       sum (cic.material_cost * (
                             ( DECODE( (bic1.planning_factor - bic2.planning_factor), 0,
                                       bic1.planning_factor,
                                       (bic1.planning_factor - bic2.planning_factor)
                                      ) *
                                      ( decode( bic1.acd_type,
                                                1, -bic1.component_quantity,
                                                2, (bic2.component_quantity - bic1.component_quantity),
                                                3, bic2.component_quantity
                                               )
                                       )
                               ) /100
                            )
       			) item_cost
		    from bom_inventory_components bic1,
			 bom_inventory_components bic2,
			 eng_revised_items eri,
			 mtl_system_items msi,
			 cst_item_costs cic
		   where eri.change_notice = p_change_notice
		     and eri.organization_id = p_org_id
		     and bic1.bill_sequence_id = eri.bill_sequence_id
		     and bic1.revised_item_sequence_id = eri.revised_item_sequence_id
		     and bic1.change_notice = eri.change_notice
		     and bic1.implementation_date is null
		     and bic2.bill_sequence_id = eri.bill_sequence_id
		     and ( ( bic1.acd_type in (2,3) and
        		     bic2.component_sequence_id = bic1.old_component_sequence_id
       			    )
       			    or
       			    bic1.acd_type = 1 and
       			    bic2.component_sequence_id = bic1.component_sequence_id
     			  )
		     and msi.inventory_item_id = bic1.component_item_id
		     and msi.organization_id   = eri.organization_id
		     and cic.inventory_item_id = bic1.component_item_id
		     and cic.organization_id   = eri.organization_id
		     and cic.cost_type_id      = 1
		    group by eri.revised_item_id;

		    idx	NUMBER;
	BEGIN

		--dbms_output.put_line('Executing calc_cost_of_changes . . .');

		-- Loop thru the cursor and calculate and store the cost of
		-- change for each of the revised items.
		-- Store the result in the pl/sql table l_eco_cost_table
		idx := 1;
		FOR c_cost_of_change in cost_of_change LOOP
			l_eco_cost_table(idx).revised_item_id := c_cost_of_change.revised_item_id;
			l_eco_cost_table(idx).item_cost := c_cost_of_change.item_cost;

			--dbms_output.put_line('Revised Item: ' || to_char(l_eco_cost_table(idx).revised_item_id) ||
			--		     ' Cost of Change: ' || to_Char(l_eco_cost_table(idx).item_cost));

			idx := idx + 1;
		END LOOP; -- Cost of change loop ends
	END Calc_Cost_Of_Changes;


	/* Function: get_cost_of_item

	   Description:
	   Will search the eco_cost_table and return the cost of the matching item

	   Return: NUMBER

	*/
	FUNCTION Get_Cost_Of_Item( p_revised_item_id	IN NUMBER )
		 RETURN NUMBER
	IS
		idx	NUMBER;
	BEGIN
		FOR idx IN 1 .. l_eco_cost_table.count LOOP
			IF l_eco_cost_table(idx).revised_item_id = p_revised_item_id THEN
				RETURN l_eco_cost_table(idx).item_cost;
			END IF;
		END LOOP;
	END Get_Cost_Of_Item;


	/* Procedure: Get_Cost_Quantity

	   Description:
	   Will return the item cost and the demand quantity for a period. This is the cost and
	   quantity for a item with repetitive demand.

	   Return: None, but set two o/p parameters x_item_cost and x_demand_quantity

	*/

	PROCEDURE Get_Cost_Quantity ( p_period_name_year IN VARCHAR2,
				      x_demand_quantity  OUT NOCOPY NUMBER,
				      x_item_cost	 OUT NOCOPY NUMBER
				    )
	IS
		idx 	NUMBER;
	BEGIN
		idx := 0;

		FOR idx IN 1 .. l_repetative_cost_table.count LOOP
			IF l_repetative_cost_table(idx).period_name_year = p_period_name_year THEN
				x_demand_quantity := l_repetative_cost_table(idx).demand_quantity;
				x_item_cost	  := l_repetative_cost_table(idx).item_cost;

				exit;
			END IF;
		END LOOP;

		IF idx <> 0 THEN
			l_repetative_cost_table.DELETE(idx);
		ELSE
			-- If procedure executes till this point i.e. no period record is found
			-- then set return values to 0
			x_demand_quantity := 0;
			x_item_cost := 0;
		END IF;

	END Get_Cost_Quantity;


	/* Procedure: Insert_Into_Temp_Table

	   Description:
	   Will insert the passed data into the ENG_BIS_ECO_COST_TEMP table.

	   Return: None

	*/

	PROCEDURE Insert_Into_Temp_Table (p_eco_cost	      IN NUMBER,
					  p_total_cost_saving IN NUMBER,
                                          p_demand_quantity   IN NUMBER,
                                          p_period_name_year  IN VARCHAR2,
                                          p_period_start_date IN DATE,
                                          p_change_notice     IN VARCHAR2,
                                          p_org_id            IN NUMBER ,
					  p_query_id	      IN NUMBER
                                          )
	IS
	BEGIN

                        INSERT INTO BOM_FORM_QUERY
                                    ( number1,
                                      number2,
				      number4,
                                      char1,
                                      date1,
                                      char2,
                                      number3,
				      query_id,
				      last_update_date,
                                      last_updated_by,
                                      creation_date,
                                      created_by
                                     )
                        VALUES ( p_eco_cost,
				 p_demand_quantity,
				 p_total_cost_saving,
				 p_period_name_year,
				 p_period_start_date,
				 p_change_notice,
				 p_org_id,
			         p_query_id,
                                 sysdate,
                                 1,
                                 sysdate,
                                 1
				);

	END Insert_Into_Temp_Table;

	/* Procedure: Calc_Repetitive_Demand

	   Description:
	   When a rate based demand exists, which spans across multiple periods, then
	   the demand needs to be split in the appropriate calendar periods with the
	   appropriate quantity.

	   Returns: None.
	*/
         PROCEDURE Calc_Repetitive_Demand( p_demand_date IN DATE,
                                 	   p_comp_date   IN DATE,
                                 	   p_req_qty	 IN NUMBER,
					   p_daily_rate	 IN NUMBER,
					   p_org_id	 IN NUMBER,
					   p_est_cost	 IN NUMBER,
					   p_cost_change IN NUMBER
					  )
	IS
		l_required_quantity	NUMBER;
		l_start_date		DATE;
		--
		-- Cursor will select periods between the demand_date and demand completion date
		-- This will then be used to spread the rate based demand.
		--
		CURSOR cal_periods IS
		SELECT period_start_date, next_date, period_name
		  FROM bom_org_cal_periods_view
		 WHERE organization_id = p_org_id
		   AND next_date > p_demand_date
		   AND period_start_date <= p_comp_date;

		idx	NUMBER;
	BEGIN
		l_required_quantity := p_req_qty;
		l_start_date	    := p_demand_date;

		--dbms_output.put_line('Calculate repetative demand . . .');

		idx := nvl(l_repetative_cost_table.count, 0) + 1;

		FOR c_cal_periods IN cal_periods LOOP
			IF p_comp_date > c_cal_periods.next_date THEN
				l_required_quantity := l_required_quantity -
						       (c_cal_periods.next_date - l_start_date) *
							p_daily_rate;
				l_start_date := c_cal_periods.next_date;

			ELSIF p_comp_date < c_cal_periods.next_date and
			      p_comp_date > c_cal_periods.period_start_date
			 THEN
				l_required_quantity := (c_cal_periods.period_start_date - p_comp_date) *
							p_daily_rate;
			END IF;

			-- Create a record in the pl/sql table and store the
			-- demand quantity and the cost for that period.

			l_repetative_cost_table(idx).demand_quantity := l_required_quantity;
			l_repetative_cost_table(idx).item_cost := p_cost_change * l_required_quantity;
			l_repetative_cost_table(idx).period_name_year := c_cal_periods.period_name || '/' ||
                                                                         to_char(c_cal_periods.period_start_date,
                                                                         'YYYY');
			idx := idx + 1;

		END LOOP;

	END Calc_Repetitive_Demand;



	PROCEDURE Eco_Cost_Calculate ( p_change_notice IN varchar2,
				       p_org_id        IN number,
				       p_plan_name     IN varchar2,
				       p_start_date    IN DATE,
				       p_end_date      IN DATE,
				       p_query_id      IN number)
	IS

		l_cost_of_eco 		number;
		l_cost_of_changes 	number;
		l_estimated_cost 	number;
		l_required_quantity 	number;
		l_mfg_exists 		boolean;
		l_eng_exists 		boolean;
		l_temp_qty		number;
		l_temp_cost		number;

		--
		-- Cursor to check which type of items exist on the ECO
		--  and decide whether to use mfg_cost or eng_cost
		--
		CURSOR check_assembly_type IS
		SELECT nvl(eco.estimated_mfg_cost, 0) mfg_cost,
		       nvl(eco.estimated_eng_cost, 0) eng_cost,
		       bom.assembly_type
		 FROM eng_engineering_changes eco,
		      eng_revised_items eri,
		      bom_bill_of_materials bom
		WHERE eco.change_notice = p_change_notice
		  AND eco.organization_id = p_org_id
		  AND eri.change_notice = eco.change_notice
		  AND eri.organization_id = eco.organization_id
		  AND bom.bill_sequence_id = eri.bill_sequence_id;

		--
		-- Cursor to get the calendar periods that lie between the
		-- given start and end dates
		--
		CURSOR calendar_periods IS
		SELECT period_start_date, next_date, period_name
		  FROM bom_org_cal_periods_view
		 WHERE organization_id = p_org_id
		   AND next_date >= p_start_date
		   AND period_start_date <= p_end_date;

		--
		-- Cursor to get the demand for all items that are planned using the
		-- plan_name and those that lie on the ECO only.
		--
		CURSOR item_demand (cp_start_date 	DATE,
				    cp_end_date   	DATE,
			            cp_change_notice	varchar2,
				    cp_org_id		number,
				    cp_plan_name	varchar2) IS
		SELECT	using_requirements_quantity,
		       	using_assembly_demand_date,
		      	assembly_demand_comp_date,
			daily_demand_rate,
			revised_item_id
		  FROM  eng_revised_items eri,
			mrp_gross_requirements mgr
		 WHERE  eri.change_notice = cp_change_notice
		   AND  eri.organization_id = cp_org_id
		   AND  mgr.compile_designator = cp_plan_name
		   AND  mgr.organization_id = eri.organization_id
		   AND  mgr.inventory_item_id = eri.revised_item_id
		   AND  mgr.using_assembly_demand_date >= cp_start_date
		   AND  mgr.using_assembly_demand_date  < cp_end_date;

	BEGIN

		 /*
		   This calculation is no longer required.

			l_cost_of_eco := Calc_Cost_Of_Items_On_Eco(p_change_notice => p_change_notice,
							   p_org_id	   => p_org_id);
		*/

		Calc_Cost_Of_Changes(p_change_notice => p_change_notice,
				     p_org_id	     => p_org_id);



		-- If the ECO has both manufacturing and engineering items, then sum both the
		-- estimated_mfg_cost and the estimated_eng_cost
		-- If the ECO has only Engineering items, then only use the estimated_eng_cost
		-- If the ECO has only Manufacturing items, then only use the estimated_mfg_cost
		l_mfg_exists := FALSE;
		l_eng_exists := FALSE;


		FOR c_assembly_type IN check_assembly_type LOOP

			IF c_assembly_type.assembly_type = 1 THEN
				l_mfg_exists := TRUE;
			ELSIF c_assembly_type.assembly_type = 2 THEN
				l_eng_exists := TRUE;
			END IF;

			IF l_mfg_exists = TRUE AND
			   l_eng_exists = TRUE THEN

			   l_estimated_cost := c_assembly_type.mfg_cost + c_assembly_type.eng_cost;

			   -- If both the values are found, then no need to continue any further
			      EXIT;

			ELSIF l_mfg_exists = TRUE AND
			      l_eng_exists = FALSE THEN

			   l_estimated_cost := c_assembly_type.mfg_cost;

			ELSE
			   l_estimated_cost := c_assembly_type.eng_cost;
			END IF;

		END LOOP;

		-- At this point you have the cost of the assemblies as they exist in production
		-- , changed cost of the ECO after the changes would be implemented
		-- estimated cost to be used depending on the type of items that exist on the ECO
		--
		-- Now calculate the demand based on the plan_name and aggregate the demand based on the
		-- Calendar periods.

		-- Store the implementation cost in the global variable so that the
		-- report can read it.
		ENG_ECO_COST.g_estimated_Cost := l_estimated_Cost;

		l_estimated_Cost := -l_estimated_Cost;
		FOR c_calendar_periods IN calendar_periods LOOP

			-- For every period initialize l_required_quantity and l_cost_of_changes before proceeding
			-- with any calculations.

			l_required_quantity := 0;
			l_cost_of_changes := 0;

			--dbms_output.put_line('Period: ' || c_calendar_periods.period_name ||
			--		     ' Estimated Cost: ' || to_char(l_estimated_Cost));

			FOR c_item_demand IN item_demand(cp_start_date => c_calendar_periods.period_start_date,
							 cp_end_date   => c_calendar_periods.next_date,
							 cp_change_notice => p_change_notice,
							 cp_org_id     => p_org_id,
							 cp_plan_name  => p_plan_name)
			LOOP

				--dbms_output.put_line('Getting demand for ' || c_calendar_periods.period_name);

				--
				-- If the demand for any item is repetitive or rate based, then
				-- calculate the quantity of the demand based on the daily_demand_rate
				--

				IF NVL(c_item_demand.daily_demand_rate,0) <> 0 THEN

					-- If the demand completion date span across multiple
					-- periods, then create records with appropriate
					-- quantity in the ENG_ECO_COSTS_TEMP table.

					Calc_Repetitive_Demand(
							p_demand_date	=> c_item_demand.using_assembly_demand_date,
							p_comp_date	=> c_item_demand.assembly_demand_comp_date,
							p_req_qty	=> c_item_demand.using_requirements_quantity,
							p_org_id	=> p_org_id,
							p_daily_rate	=> c_item_demand.daily_demand_rate,
							p_est_cost	=> l_estimated_cost,
							p_cost_change	=> Get_Cost_Of_Item(p_revised_item_id =>
									     c_item_demand.revised_item_id)
							);
				ELSE
					l_required_quantity := l_required_quantity +
							       c_item_demand.using_requirements_quantity;

					l_cost_of_changes := l_cost_of_changes +
							     c_item_demand.using_requirements_quantity *
							     Get_Cost_Of_Item(p_revised_item_id =>
										c_item_demand.revised_item_id);
				END IF;

                        END LOOP;  -- Item demand Loop Ends


			--
			-- Check if there is any demand generated for this period by any of the
			-- repetative demand items
			--
			--dbms_output.put_line('Getting cost and quantity . . .');

			Get_Cost_Quantity(p_period_name_year => (c_calendar_periods.period_name) || '/' ||
                                                                 to_char(c_calendar_periods.period_start_date,'YYYY'),
					  x_demand_quantity  => l_temp_qty,
					  x_item_cost	     => l_temp_cost
					 );
			--
			-- Cost and Quantity is found, then
			--
			IF l_temp_qty <> 0 and l_temp_cost <> 0 THEN
				l_required_quantity := l_required_quantity + l_temp_qty;
				l_cost_of_changes := l_cost_of_changes + l_temp_cost;
			END IF;
			--
                        -- quantities for all the items in a given period are calculated, then
                        -- insert records into the ENG_ECO_COSTS_TEMP table

		        IF l_required_quantity <> 0 THEN
				--dbms_output.put_line('Inserting data . . .');

			Insert_Into_Temp_Table(p_eco_cost		=> l_cost_of_changes,
					       p_total_cost_saving	=> (l_estimated_cost + l_cost_of_changes),
					       p_demand_quantity	=> l_required_quantity,
					       p_period_name_year	=> (c_calendar_periods.period_name) || '/' ||
                                     				   	   to_char(c_calendar_periods.period_start_date,
									   'YYYY'),
					       p_period_start_date	=> c_calendar_periods.period_start_date,
					       p_change_notice		=> p_change_notice,
					       p_org_id			=> p_org_id,
					       p_query_id		=> p_query_id
					      );
			END IF;

			l_estimated_cost := l_estimated_cost + l_cost_of_changes;

		END LOOP;  -- Calendar periods Loop Ends

	END Eco_Cost_Calculate;

	/* Function	: g_estimated_cost

	   Return	: number

	   Description
	   Will simply return the estimated cost to the client
	*/

	FUNCTION get_estimated_Cost RETURN NUMBER
	IS
	BEGIN
		return ENG_ECO_COST.g_estimated_cost;
	END;

END Eng_Eco_Cost;

/
