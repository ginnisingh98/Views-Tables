--------------------------------------------------------
--  DDL for Package Body GMD_COMMON_SCALE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_COMMON_SCALE" AS
/* $Header: GMDVSCLB.pls 120.2 2006/11/21 16:49:46 txdaniel noship $ */
/*****************************************************************************************************
* FILE:			GMDVSCLB.pls
* PROCEDURE:	scale
* PURPOSE:	 	Package body for GMD Common Scale Routine.
* AUTHOR:		Paul Schofield
*
* HISTORY:
* =======
* Paul Schofield		Created.
*
* E. Chen	03/21/01	Modified for 11iplus enhancements. Added new
*							integer_multiple scale_type, new yield
*							contributing indicator, error conditions.
* Shrikant Nene 04/30/2001     Added Theoretical_yield procedure.
* Bill Stearns 06/3/2001       Added Header string
* LeAta + Susan  24Aug2001     Bug 1955038.  Commented out dbms_output.  D
*                                Bug 1954995.  Changed != to <>  Bug 1954988  Removed line between CREATE and $Header
* Pawan Kumar  10/02/2001     Added validations for null input for scale tab. moved fm_yield_type_um
* Praveen Surakanti 05/22/03  Bug#2901379
*                             Do not validate the scale_rounding_variance being NULL.
* Kalyani Manda	08/28/03      Bug 3069408 Commented the code to check the
*                             scale rounding variance in order to do the
*                             integer scaling.
* P.Raghu	      10/09/03    Bug#3164299
*                             Declared a new local variable x_scale_rec_out and
*                             passed it as OUT NOCOPY variable to INTEGER_MULTIPLE_SCALE procedure.
*                             and added code in INTEGER_MULTIPLE_SCALE procedure
*                             to retain all the values of scale_rec.
* V.Anitha     03/05/2004     BUG#3018432
*                             In floor_dowm and ceil_up procedures, p_scale_multiple datatype
*                             changed to NUMBER from PLS_INTEGER to get correct value in quantity
*                             field after scaling when integer is selected as scale_type.
* S.Sriram      15Jun2004     Bug# 3680537
*                             In the ceil_up and floor_down procedures, the qty. should first be rounded off
*                             to 9 digits before integer scaling is done.
* S.Sriram      26-Nov2004    NPD Convergence.
*                             Added orgn_id in scale and theoretical_yield procedures and modified references
*                             to sy_uoms table to mtl_units_of measure and used the INV_CONVERT.inv_um_convert
*                             procedure for Qty. conversion.
* TDaniel        21-NOV-2006  Bug 5667857 - Changed unit_of_measure reference to UOM_CODE.
*****************************************************************************************************************/

/**********************************************************************
* OVERVIEW:
* ========
*
The Scale Batch procedure accepts as input the local scale table,
which includes a subset of the detail lines of the batch as
they exist in gme_material_details.
This subset is defined by scale_rec record and contains the fields
necessary for scaling of the batch.
Initially, determine the uom of the FM_YIELD_TYPE.
Then Accumulate counter
values of batch output and input, which will determine the scale
type of the items and whether they contribute to yield.
From these counters, determine whether certain conditions
exist: does a simple scaling scenario exist that
will enable early exit or do we have to scale at all.
If these conditions are not met, continue on to PHASE I and
then PHASE II of the full scaling process.
**********************************************************************/

/*  Procedure to get the standard uom for the 'fm_yield_type'
    This will be used to convert all the quantities into single
    unit of measure
*/

  PROCEDURE get_fm_yield_type
  (
    p_orgn_id           IN  NUMBER,
    x_conv_uom          OUT NOCOPY VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2)
  IS

    CURSOR sy_uoms_typ_cursor(v_yield_type VARCHAR2) IS
     SELECT  uom_code
     FROM    mtl_units_of_measure
     WHERE   uom_class = v_yield_type
     AND     base_uom_flag = 'Y';

     l_yield_type VARCHAR2(30);
     l_return_status VARCHAR2(10);

  BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- NPD Convergence
      GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => p_orgn_id		,
					P_parm_name     => 'FM_YIELD_TYPE'	,
					P_parm_value    => l_yield_type		,
					X_return_status => l_return_status	);

	OPEN sy_uoms_typ_cursor(l_yield_type);
	FETCH sy_uoms_typ_cursor INTO x_conv_uom;
	CLOSE sy_uoms_typ_cursor;

	IF (x_conv_uom IS NULL OR x_conv_uom = ' ')
	THEN
  	   fnd_message.set_name('GME','GME_STANDARD_UOM_NOT_DEFINED');
	   fnd_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
	   RETURN;
	END IF;

  END get_fm_yield_type;


  PROCEDURE scale
  (  p_scale_tab          IN scale_tab
  ,  p_orgn_id            IN NUMBER
  ,  p_scale_factor       IN NUMBER
  ,  p_primaries          IN VARCHAR2
  ,  x_scale_tab          OUT NOCOPY scale_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  )
  IS
  l_scale_tab             scale_tab ;
  x_scale_rec		  scale_rec ;
  --Begin Bug#3164299  P.Raghu
  x_scale_rec_out         scale_rec ;
  --End Bug#3164299
  l_qty                   NUMBER;
  l_tab_size              NUMBER;
  -- l_conv_uom           sy_uoms_mst.um_code%TYPE;
  l_conv_uom              mtl_units_of_measure.uom_code%TYPE;
  l_type_0_Y_outputs      NUMBER:= 0;
  l_type_1_Y_outputs      NUMBER:= 0;
  l_type_2_Y_outputs      NUMBER:= 0;
  l_type_0_N_outputs      NUMBER:= 0;
  l_type_1_N_outputs      NUMBER:= 0;
  l_type_2_N_outputs      NUMBER:= 0;
  l_type_0_Y_inputs       NUMBER:= 0;
  l_type_1_Y_inputs       NUMBER:= 0;
  l_type_2_Y_inputs       NUMBER:= 0;
  l_type_0_N_inputs       NUMBER:= 0;
  l_type_1_N_inputs       NUMBER:= 0;
  l_type_2_N_inputs       NUMBER:= 0;
  l_fixed_input_qty       NUMBER:= 0;
  l_fixed_output_qty      NUMBER:= 0;
  l_proportional_input_qty    NUMBER:= 0;
  l_proportional_output_qty   NUMBER:= 0;
  P                     NUMBER:= 0;
  S                     NUMBER:= 0;
  A                     NUMBER:= 0;
  k                     NUMBER:= 0;
  b                     NUMBER:= 0;
  b1                    NUMBER:= 0;
  l_input_total         NUMBER:= 0;
  l_output_total        NUMBER:= 0;

  CURSOR sy_uoms_typ_cursor(v_yield_type VARCHAR2) IS
     SELECT  uom_code
     FROM    mtl_units_of_measure
     WHERE   uom_class = v_yield_type
     AND     base_uom_flag = 'Y';

  l_yield_type VARCHAR2(30);
  l_return_status VARCHAR2(10);

--**********************************************************************

BEGIN
-- added by pawan kumar for intializing success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_tab_size := p_scale_tab.count;
--**********************************************************************
--Determine the uom to which the items that conbribute to yield
--must be converted.
--**********************************************************************
--Moved this out the loop

        -- NPD Convergence
        GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => p_orgn_id		,
					P_parm_name     => 'FM_YIELD_TYPE'	,
					P_parm_value    => l_yield_type		,
					X_return_status => l_return_status	);

        OPEN sy_uoms_typ_cursor(l_yield_type);
	FETCH sy_uoms_typ_cursor INTO l_conv_uom;
	CLOSE sy_uoms_typ_cursor;

-- dbms_output.put_line('l_conv_uom ' || l_conv_uom);

	IF (l_conv_uom IS NULL OR l_conv_uom = ' ')
	THEN
  	   fnd_message.set_name('GME','GME_STANDARD_UOM_NOT_DEFINED');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('No standard UOM for FM_YIELD_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
	END IF;
  FOR l_row_count IN 1 .. l_tab_size
  LOOP
	--*************************************************************
	--Initial data validation. If the data is not correct,
	--exit from scaling with an error message.
	--*************************************************************

	IF (p_scale_tab(l_row_count).inventory_item_id IS NULL
	OR p_scale_tab(l_row_count).detail_uom IS NULL)
	THEN
		fnd_message.set_name('GME','GME_INVALID_ITEM_OR_ITEM_UM');
		fnd_msg_pub.add;
      		x_return_status := FND_API.G_RET_STS_ERROR;
		-- dbms_output.put_line('INVALID_ITEM_AND_OR_ITEM_UM');
	END IF;
	-- Pawan Kumar added  check for null
	IF (p_scale_tab(l_row_count).line_type IS NULL) OR
	   (p_scale_tab(l_row_count).line_type NOT IN (-1,1,2))
      	THEN
				fnd_message.set_name('GME','GME_INVALID_LINE_TYPE');
				fnd_msg_pub.add;
		 		x_return_status := FND_API.G_RET_STS_ERROR;
				-- dbms_output.put_line('INVALID_LINE_TYPE');
	END IF;
	IF (p_scale_tab(l_row_count).line_no IS NULL
		OR p_scale_tab(l_row_count).line_no <= 0 )
   THEN
				fnd_message.set_name('GME','GME_INVALID_LINE_NUMBER');
				fnd_msg_pub.add;
      		x_return_status := FND_API.G_RET_STS_ERROR;
				-- dbms_output.put_line('INVALID_LINE_NUMBER');
	END IF ;
	-- Pawan Kumar added  check for null
	IF (p_scale_tab(l_row_count).scale_type IS NULL) OR
	(p_scale_tab(l_row_count).scale_type NOT IN (0,1,2))
   THEN
			fnd_message.set_name('GME','GME_INVALID_SCALE_TYPE');
			fnd_msg_pub.add;
     		x_return_status := FND_API.G_RET_STS_ERROR;
			-- dbms_output.put_line('INVALID_SCALE_TYPE');
	END IF;
	-- Pawan Kumar added  check for null
   IF (p_scale_tab(l_row_count).contribute_yield_ind IS NULL) OR
   (p_scale_tab(l_row_count).contribute_yield_ind NOT IN ('Y','N'))
	THEN
			fnd_message.set_name('GME','GME_INVALID_CONTRIBUTE_YIELD');
			fnd_msg_pub.add;
     		x_return_status := FND_API.G_RET_STS_ERROR;
			-- dbms_output.put_line('INVALID_CONTRIBUTE_YIELD_IND');
	END IF;
	-- Pawan Kumar added  check for scale type = 2 as the following are required then only
  IF (p_scale_tab(l_row_count).scale_type = 2) THEN
   IF (p_scale_tab(l_row_count).scale_multiple IS NULL) OR
      (p_scale_tab(l_row_count).scale_multiple < 0 )
	THEN
			fnd_message.set_name('GME','GME_INVALID_SCALE_MULTIPLE');
			fnd_msg_pub.add;
     		x_return_status := FND_API.G_RET_STS_ERROR;
			-- dbms_output.put_line('INVALID_SCALE_MULTIPLE');
	END IF;
  --BEGIN BUG#2901379
  --Do not validate the scale_rounding_variance being NULL.
    --IF (p_scale_tab(l_row_count).scale_rounding_variance IS NULL) OR
      IF   ((p_scale_tab(l_row_count).scale_rounding_variance < 0)
	OR  (p_scale_tab(l_row_count).scale_rounding_variance > 1))
	THEN
			fnd_message.set_name('GME','GME_INVALID_SCALE_VARIANCE');
			fnd_msg_pub.add;
     		x_return_status := FND_API.G_RET_STS_ERROR;
			-- dbms_output.put_line('INVALID_SCALE_ROUNDING_VARIANCE');
	END IF;
   --END BUG#2901379

IF (p_scale_tab(l_row_count).rounding_direction IS NULL) OR
   (p_scale_tab(l_row_count).rounding_direction NOT IN (0,1,2))
	THEN
				fnd_message.set_name('GME','GME_INVALID_ROUNDING_DIRECTION');
				fnd_msg_pub.add;
      		x_return_status := FND_API.G_RET_STS_ERROR;
				-- dbms_output.put_line('INVALID_ROUNDING_DIRECTION');
	END IF;
    END IF;
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		RETURN;
	END IF;


--**********************************************************************
--Here determining the scale type of the outputs and whether they
--contribute to yield. Increment appropriate counter.
--**********************************************************************
    IF p_scale_tab(l_row_count).line_type IN (1,2)
    THEN
    -- dbms_output.put_line('determining scale type of output ');
      IF p_scale_tab(l_row_count).scale_type = 0 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_0_Y_outputs := l_type_0_Y_outputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type = 1 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_1_Y_outputs := l_type_1_Y_outputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type = 2 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_2_Y_outputs := l_type_2_Y_outputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type =0 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'N'
      THEN
        l_type_0_N_outputs := l_type_0_N_outputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type =1 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'N'
      THEN
        l_type_1_N_outputs := l_type_1_N_outputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type =2 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'N'
      THEN
        l_type_2_N_outputs := l_type_2_N_outputs+1;
      ELSE
        -- Use this branch for future scale types.
        NULL;
      END IF;
      l_output_total := l_output_total +1 ;

--**********************************************************************
--Here determining the scale type of the inputs and whether they
--contribute to yield. Increment appropriate counter.
--**********************************************************************

    ELSIF p_scale_tab(l_row_count).line_type = -1
    THEN
    -- dbms_output.put_line('determining scale type of input ');
      IF p_scale_tab(l_row_count).scale_type = 0 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_0_Y_inputs := l_type_0_Y_inputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type = 1 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_1_Y_inputs := l_type_1_Y_inputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type = 2 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_2_Y_inputs := l_type_2_Y_inputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type =0 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'N'
      THEN
        l_type_0_N_inputs := l_type_0_N_inputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type =1 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'N'
      THEN
        l_type_1_N_inputs := l_type_1_N_inputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type =2 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'N'
      THEN
        l_type_2_N_inputs := l_type_2_N_inputs+1;
      ELSE
        -- Use this branch for future scale types.
        NULL;
      END IF;
      l_input_total := l_input_total +1 ;
    END IF;
  END LOOP;

-- dbms_output.put_line('l_input_total = ' || to_char(l_input_total));
-- dbms_output.put_line('l_output_total = ' || to_char(l_output_total));

--**********************************************************************
--Now that we have the output/input counters, which tell us the scale_type
--and whether the output/input contributes to yield, we can test for some
--conditions that if satisfied will allow for uncomplicated scaling and/or
--early exit from scaling routine.
--**********************************************************************

--**********************************************************************
--Condition 1:
--If all outputs and inputs are scaleable(scale_type=1,2) and regardless
--of whether they contribute to yield(contribute_yield_ind=Y or N), apply
--the same entered scale factor to all outputs and inputs. Exit.
--**********************************************************************

  IF l_type_1_Y_inputs + l_type_1_N_inputs + l_type_2_Y_inputs + l_type_2_N_inputs + l_type_1_Y_outputs + l_type_1_N_outputs + l_type_2_Y_outputs + l_type_2_N_outputs = l_tab_size
  THEN
	-- dbms_output.put_line('YES all input and output are scale=1,2 contribute=Y');
	-- dbms_output.put_line('scale by factor and get out!');

    x_scale_tab := p_scale_tab;
    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * p_scale_factor;
        --BEGIN BUG#2901379 PR
        --Commented the condition to check the boundary of scale_rounding_variance as this fails if cale_rounding_variance is NULL;
        IF x_scale_tab(l_row_count).scale_type = 2
         AND x_scale_tab(l_row_count).scale_multiple > 0
         --AND x_scale_tab(l_row_count).scale_rounding_variance > 0
         --AND x_scale_tab(l_row_count).scale_rounding_variance <= 1
         --END BUG#2901379
	THEN
	-- dbms_output.put_line('just b4 call to integer_multiple_scale');
	-- dbms_output.put_line('l_row_count  = '||to_char(l_row_count));

	  integer_multiple_scale(x_scale_tab(l_row_count)
	                         --Begin Bug#3164299 P.Raghu
                                 , x_scale_rec_out
                                 --End Bug#3164299
                                 , x_return_status);
	   -- dbms_output.put_line('just after  call to integer_multiple_scale');

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
		fnd_message.set_name('GME','GME_INTEGER_MULTIPLE_SCALE_ERR');
		fnd_msg_pub.add;
		-- dbms_output.put_line('INTEGER_MULTIPLE_SCALE_ERROR ');
	 	RETURN;
           END IF;
           --Begin Bug#3164299 P.Raghu
           x_scale_tab(l_row_count) := x_scale_rec_out;
	   --End Bug#3164299
	END IF;
    END LOOP;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;

--**********************************************************************
--Condition 2:
--If all outputs and inputs are fixed(scale_type=0) and regardless
--of whether they contribute to yield(contribute_yield_ind=Y or N),
--Exit. No items are available for scaling.
--**********************************************************************

  -- dbms_output.put_line('determine whether all input and output are fixed=0');

  ELSIF l_type_0_Y_inputs + l_type_0_N_inputs + l_type_0_Y_outputs + l_type_0_N_outputs = l_tab_size
  THEN
    x_scale_tab := p_scale_tab;

    fnd_message.set_name('GME','GME_ALL_FIXED_NO_SCALING');
    fnd_msg_pub.add;
    -- dbms_output.put_line('All items are non-scaleable. No scaling permitted');

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;

--**********************************************************************
--Condition 3:
--If all outputs or if all inputs are fixed(scale_type=0)
--or if no scaleable items that contribute to yield exist,
--scaling is not permitted.
--At least one ingredient must be scaleable and contribute to yield.
--At least one product must be scaleable and contribute to yield.

--**********************************************************************

  ELSIF (l_type_0_Y_inputs + l_type_0_N_inputs + l_type_1_N_inputs
         + l_type_2_N_inputs= l_input_total)
  THEN
	-- dbms_output.put_line('l_type_0_Y_inputs =  ' || l_type_0_Y_inputs);
	-- dbms_output.put_line('l_type_0_N_inputs =  ' || l_type_0_N_inputs);
	-- dbms_output.put_line('l_type_1_N_inputs =  ' || l_type_1_N_inputs);
	-- dbms_output.put_line('l_type_2_N_inputs =  ' || l_type_2_N_inputs);

    fnd_message.set_name('GME','GME_NO_YC_PROPORTIONAL_INPUT');
    fnd_msg_pub.add;
    -- dbms_output.put_line('At least one YC scaleable ingredient must exist.') ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;

  ELSIF (l_type_0_Y_outputs + l_type_0_N_outputs + l_type_1_N_outputs
         + l_type_2_N_outputs = l_output_total)
  THEN
	-- dbms_output.put_line('l_type_0_Y_outputs =  ' || l_type_0_Y_outputs);
	-- dbms_output.put_line('l_type_0_N_outputs =  ' || l_type_0_N_outputs);
	-- dbms_output.put_line('l_type_1_N_outputs =  ' || l_type_1_N_outputs);
	-- dbms_output.put_line('l_type_2_N_outputs =  ' || l_type_2_N_outputs);

    fnd_message.set_name('GME','GME_NO_YC_PROPORTIONAL_OUTPUT');
    fnd_msg_pub.add;
    -- dbms_output.put_line('At least one YC scaleable product must exist.') ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;


  END IF;

--**********************************************************************
--At this point, we know that at least one or more items of the batch
--differ in scale type. The items are not all scalable and they are not
--all fixed.The following phases of the scaling process begin here:

--PHASE I:
--Here regardless of scale type, all items that contribute
--to yield are passed to the uom_conversion program.
--Each qty that contributes to yield must be converted to the fm_yield_type.
--Counters are updated with the qty of the output/input
--and indicate whether the output/input is fixed or scalable.
--These qtys will be used in calculating the
--secondary scale factor(b).

--PHASE II:
--Phase II will execute two different sections of code depending
--on whether the primaries=OUTPUT or INPUT. The primary parameter is the
--one to which we will apply the entered scale factor. Both sections of
--Phase II consists of 4 parts. Within the 4 parts, we do the following:
--	Sum the item qtys that contribute to yield and store value in A.
--	Calculate the scale factor for the secondary using qty's
--	calculated in PHASE 1.
--	Apply entered scale factor to primary and calculated scale factor
--	to the secondary.
-- 	Determine whether integer_multiple scaling is required.
--**********************************************************************

  l_scale_tab := p_scale_tab;
  x_scale_tab := p_scale_tab;


--**********************************************************************
--PHASE I: UOM conversion and increment fixed and proportional
--output and input qty counters.
--Note:
--!Importance of these counters is to accumulate qty that
--contributes to yield.
--**********************************************************************

  -- dbms_output.put_line('Phase I: calling uom conv ');

  FOR l_row_count IN 1 .. l_tab_size
  LOOP
    IF l_scale_tab(l_row_count).scale_type IN (0,1,2) AND
       l_scale_tab(l_row_count).contribute_yield_ind='Y'
    THEN
     -- NPD Conv.
     l_qty := INV_CONVERT.inv_um_convert(item_id         => p_scale_tab(l_row_count).inventory_item_id
                                         ,precision      => 5
                                         ,from_quantity  => p_scale_tab(l_row_count).qty
                                         ,from_unit      => p_scale_tab(l_row_count).detail_uom
                                         ,to_unit        => l_conv_uom
                                         ,from_name      => NULL
                                         ,to_name	 => NULL);
      IF l_qty < 0
      THEN
        -- Report UOM failure
	-- dbms_output.put_line('x_return_status =  ' || x_return_status);
    	fnd_message.set_name('GMI','GMI_OPM_UOM_NOT_FOUND');
	fnd_msg_pub.add;
    	-- dbms_output.put_line('GMI UOM_CONVERSION_ERROR');
        x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      ELSE
        l_scale_tab(l_row_count).qty := l_qty;
        l_scale_tab(l_row_count).detail_uom := l_conv_uom;
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- dbms_output.put_line('x_return_status =  ' || x_return_status);

--**********************************************************************
--PHASE I:
--Importance of these counters is to accumulate prod/byprod qty that
--contributes to yield.
--If prod/byprod has a fixed scale type(scale_type=0) and contributes
--to yield, add its qty to fixed qty variable.
--If prod/byprod has a scalable scale type(scale_type=1,2) and contributes
--to yield, add its qty to proportional qty variable.
--**********************************************************************

	-- dbms_output.put_line('Phase I:increment fix/proportional output qty counter');
        IF l_scale_tab(l_row_count).line_type IN (1,2)
        THEN
          IF l_scale_tab(l_row_count).scale_type = 0 AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
          THEN
            l_fixed_output_qty := l_fixed_output_qty + l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('l_fixed_output_qty= '||to_char(l_fixed_output_qty));
          ELSIF l_scale_tab(l_row_count).scale_type IN (1,2) AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
          THEN
            l_proportional_output_qty :=  l_proportional_output_qty + l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('l_proportional_output_qty= '||to_char(l_proportional_output_qty));
          END IF;

--**********************************************************************
--PHASE I:
--Importance of these counters is to accumulate ingredient qty that
--contributes to yield.
--If ingredient has a fixed scale type(scale_type=0) and contributes
--to yield, add its qty to fixed qty variable.
--If ingredient has a scalable scale type(scale_type=1,2) and contributes
--to yield, add its qty to proportional qty variable.
--**********************************************************************
        ELSE
	-- dbms_output.put_line('Phase I:increment fix/proportional INPUT qty counter');
          IF l_scale_tab(l_row_count).scale_type = 0 AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
          THEN
            l_fixed_input_qty := l_fixed_input_qty + l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('l_fixed_input_qty= '||to_char(l_fixed_input_qty));

          ELSIF l_scale_tab(l_row_count).scale_type IN (1,2) AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
          THEN
            l_proportional_input_qty :=  l_proportional_input_qty + l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('l_proportional_input_qty= '||to_char(l_proportional_input_qty));
          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;


/*
  IF (l_fixed_output_qty + l_proportional_output_qty +
      l_fixed_input_qty +l_proportional_input_qty = 0 )
  THEN
    	fnd_message.set_name('GME','NO_YIELD_CONTR_PRIM_OR_SEC');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('NO_FIXED_OR_PROPORTIONAL_PRIMARY_OR_SECONDARY');
      x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
  END IF;
*/

-- dbms_output.put_line('PHASE I ') ;
-- dbms_output.put_line('l_fixed_output_qty= '||to_char(l_fixed_output_qty));
-- dbms_output.put_line('l_proportional_output_qty= '||to_char(l_proportional_output_qty));
-- dbms_output.put_line('l_fixed_input_qty= '||to_char(l_fixed_input_qty));
-- dbms_output.put_line('l_proportional_input_qty= '||to_char(l_proportional_input_qty));


--**********************************************************************
--PHASE II when primaries=OUTPUT:
--Part 1
--When p_primaries = 'OUTPUT', sum the prod/byprod that contribute to
--yield and store the accumulated value in variable A.
--**********************************************************************

  IF p_primaries = 'OUTPUTS'
  THEN
   -- dbms_output.put_line('PHASE II; Part 1; primaries = OUTPUT') ;
    --Sum of fixed and scalable prod/byprod that contribute to yield.
    P := l_fixed_output_qty + l_proportional_output_qty;
    IF (P = 0 )
    THEN
    	-- dbms_output.put_line('P=0');
/*
    	fnd_message.set_name('GME','NO_YIELD_CONTR_PRIMARIES');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('NO_YIELD_CONTR_PRIMARIES_EXIT');
      x_return_status := FND_API.G_RET_STS_ERROR;
*/
		RETURN;
    END IF;

    --Sum of fixed and scalable ingred that contribute to yield.
    S := l_fixed_input_qty + l_proportional_input_qty;
    --Yield Ratio of Outputs/Inputs
    IF (S = 0 )
    THEN
    	-- dbms_output.put_line('S=0');

/*
    	fnd_message.set_name('GME','NO_YIELD_CONTR_SECONDARIES');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('NO_YIELD_CONTR_SECONDARIES_EXIST');
      x_return_status := FND_API.G_RET_STS_ERROR;
*/
		RETURN;
    ELSIF (l_proportional_input_qty = 0)
    THEN
    	-- dbms_output.put_line('l_proportional_input_qty=0');

/*
    	fnd_message.set_name('GME','NO_PROPORTIONAL_SECONDARIES');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('NO_PROPORTIONAL_SECONDARIES_EXIST');
      x_return_status := FND_API.G_RET_STS_ERROR;
*/
		RETURN;

    END IF;

    k := P/S;
    -- dbms_output.put_line('P= '||to_char(P));
    -- dbms_output.put_line('S= '||to_char(S));
    -- dbms_output.put_line('k= '||to_char(k));

    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      IF l_scale_tab(l_row_count).line_type IN (1,2)
      THEN
        IF l_scale_tab(l_row_count).scale_type IN (1,2) AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
        THEN
          A := A + p_scale_factor * l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('A calc w/scale factor= '||to_char(A));
        ELSIF l_scale_tab(l_row_count).scale_type = 0 AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
        THEN
          A := A + l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('A w/o scale factor= '||to_char(A));
        END IF;
      END IF;
    END LOOP;

    -- dbms_output.put_line('A calc = '||to_char(A));
    -- dbms_output.put_line('A w/o scale factor= '||to_char(A));


--**********************************************************************
--PHASE II when primaries= OUTPUT
--Part 2
--Calcuate the scale factor(b) that will be applied to the scalable
--ingredients, which are the secondaries.
--**********************************************************************
-- dbms_output.put_line('PHASE II; Part 2') ;
-- dbms_output.put_line(' A = '||to_char(A));
-- dbms_output.put_line(' k = '||to_char(k));
-- dbms_output.put_line('l_fixed_input_qty= '||to_char(l_fixed_input_qty));
-- dbms_output.put_line('l_proportional_input_qty= '||to_char(l_proportional_input_qty));

--**********************************************************************
--Here checking for whether the l_fixed_input_qty is greater than
--the dividend of the primaries that contribute to yield and
--the yield ratio. If the value is greater, scaling would result in a
--in a negative scale factor applied to any scalable
--item that contributes to yield. As such, stop scaling.
--*********************************************************************
   b1 := ((A/k) - l_fixed_input_qty);
   -- dbms_output.put_line(' b1 = '||to_char(b1));
   IF b1 < 0
   THEN
    	fnd_message.set_name('GME','GME_NEGATIVE_SCALE_FACTOR_CALC');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('Cannot scale to a qty lower than the qty of your non-scaleable items ') ;

      x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
   ELSE
		b := b1 / l_proportional_input_qty;
   END IF;

   -- dbms_output.put_line(' b = '||to_char(b));

--**********************************************************************
--PHASE II when primaries=OUTPUT:
--Part 3
--Loop thru the structure
--	For scalable prod/byprod, apply entered scale factor regardless
--	of whether prod/byprod contributes to yield.
--	For scalable ingredients, apply calculated scale factor regardless
--	of whether ingredient contributes to yield.
--**********************************************************************
-- dbms_output.put_line('PHASE II; Part 3-Apply scale factor') ;

    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      IF x_scale_tab(l_row_count).line_type IN (1,2)
      THEN
        IF x_scale_tab(l_row_count).scale_type IN (1,2)
        THEN
          x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * p_scale_factor;
	-- dbms_output.put_line('l_row_count  = '||to_char(l_row_count));
	-- dbms_output.put_line('prod scaled qty  = '||to_char(x_scale_tab(l_row_count).qty));
      END IF;
      ELSE
        IF x_scale_tab(l_row_count).scale_type IN (1,2)
        THEN
          x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * b;
	-- dbms_output.put_line('l_row_count  = '||to_char(l_row_count));
	-- dbms_output.put_line('ingred scaled qty-b applied  = '||to_char(x_scale_tab(l_row_count).qty));
        END IF;
      END IF;

--**********************************************************************
--Determine whether integer_multiple scaling is required.
--**********************************************************************
        IF x_scale_tab(l_row_count).scale_type = 2
         AND x_scale_tab(l_row_count).scale_multiple > 0
         -- Bug 3069408 Do not check the rounding variance
         -- AND x_scale_tab(l_row_count).scale_rounding_variance > 0
         -- AND x_scale_tab(l_row_count).scale_rounding_variance <= 1
        THEN
			-- dbms_output.put_line('just b4 call to integer_multiple_scale');
			-- dbms_output.put_line('l_row_count  = '||to_char(l_row_count));

			  integer_multiple_scale(x_scale_tab(l_row_count)
	                         --Begin Bug#3164299 P.Raghu
                                 , x_scale_rec_out
                                 --End Bug#3164299
                                 , x_return_status);
				-- dbms_output.put_line('just after  call to integer_multiple_scale');

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
					fnd_message.set_name('GME','GME_INTEGER_MULTIPLE_SCALE_ERR');
					fnd_msg_pub.add;
					-- dbms_output.put_line('INTEGER_MULTIPLE_SCALE_ERROR ');
				 	RETURN;
           END IF;
           --Begin Bug#3164299 P.Raghu
           x_scale_tab(l_row_count) := x_scale_rec_out;
           --End Bug#3164299
		END IF;

    END LOOP;

--**********************************************************************
--PHASE II when primaries=INPUT:
--Part 1
--When p_primaries = 'INPUT', sum the ingredients that contribute to
--yield and store the accumulated value in variable A.
--**********************************************************************

  ELSIF  p_primaries = 'INPUTS'
  THEN
  -- dbms_output.put_line('PHASE II; Part 1; primaries = INPUT') ;
    --Sum of ingredients that contribute to yield.
    P := l_fixed_input_qty + l_proportional_input_qty;
    --Sum of fixed and scalable prod/byprod that contribute to yield.
    IF (P = 0 )
    THEN
    	-- dbms_output.put_line('P=0');
/*
    	fnd_message.set_name('GME','NO_YIELD_CONTR_PRIMARIES');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('NO_YIELD_CONTR_PRIMARIES_EXIT');
      x_return_status := FND_API.G_RET_STS_ERROR;
*/
		RETURN;
    END IF;

    S := l_fixed_output_qty + l_proportional_output_qty;
    --Yield Ratio of Inputs/Outputs
    IF (S = 0 )
    THEN
    	-- dbms_output.put_line('S=0');
/*
    	fnd_message.set_name('GME','NO_YIELD_CONTR_SECONDARIES');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('NO_YIELD_CONTR_SECONDARIES_EXIST');
      x_return_status := FND_API.G_RET_STS_ERROR;
*/
		RETURN;


    ELSIF (l_proportional_output_qty = 0)
    THEN
    	-- dbms_output.put_line('l_proportional_output_qty=0');

/*
    	fnd_message.set_name('GME','NO_PROPORTIONAL_SECONDARIES');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('NO_PROPORTIONAL_SECONDARIES_EXIST');
      x_return_status := FND_API.G_RET_STS_ERROR;
*/
		RETURN;
    END IF;

   -- dbms_output.put_line('P= '||to_char(P));
   -- dbms_output.put_line('S= '||to_char(S));

    k := P/S;

   -- dbms_output.put_line('k= '||to_char(k));
    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      IF l_scale_tab(l_row_count).line_type = -1
      THEN
        IF l_scale_tab(l_row_count).scale_type IN (1,2) AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
        THEN
          A := A + p_scale_factor * l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('A calc w/scale factor= '||to_char(A));
        ELSIF l_scale_tab(l_row_count).scale_type = 0 AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
        THEN
          A := A + l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('A calc w/o scale factor= '||to_char(A));
        END IF;
      END IF;
    END LOOP;
    -- dbms_output.put_line('A calc = '||to_char(A));
    -- dbms_output.put_line('A calc w/o scale factor= '||to_char(A));

--**********************************************************************
--PHASE II when primaries=INPUT:
--Part 2
--Calcuate the scale factor(b) that will be applied to the scalable
--products, which are the secondaries.
--**********************************************************************
-- dbms_output.put_line('PHASE II; Part 2') ;
-- dbms_output.put_line(' A = '||to_char(A));
-- dbms_output.put_line(' k = '||to_char(k));
-- dbms_output.put_line('l_fixed_output_qty= '||to_char(l_fixed_output_qty));
-- dbms_output.put_line('l_proportional_output_qty= ' || to_char(l_proportional_output_qty));

--**********************************************************************
--Here checking for whether there are scalable prods/byprods.
--If there are no scalable prods/byprods, there
--is no need to calculate the secondary scale factor(b).
--In including this check, we are eliminating the possibility
--of a divide by zero.
--**********************************************************************

   b1 := ((A/k) - l_fixed_output_qty);
  -- dbms_output.put_line(' b1 = '||to_char(b1));
   IF b1 < 0
   THEN
    	fnd_message.set_name('GME','GME_NEGATIVE_SCALE_FACTOR_CALC');
		fnd_msg_pub.add;
    	-- dbms_output.put_line('Cannot scale to a qty lower than the qty of your non-scaleable items ') ;
      x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
   ELSE
        b := b1 / l_proportional_output_qty;
   END IF;
  -- dbms_output.put_line(' b = '||to_char(b));

--**********************************************************************
--PHASE II when primaries=INPUT:
--Part 3
--Loop thru the structure
--	For scalable ingredients, apply entered scale factor regardless
--	of whether ingredient contributes to yield.
--	For scalable prod/byprod, apply calculated scale factor regardless
--	of whether prod/byprod contributes to yield.
--**********************************************************************
    -- dbms_output.put_line('PHASE II; Part 3-Apply scale factor') ;

    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      IF x_scale_tab(l_row_count).line_type = -1
      THEN
        IF x_scale_tab(l_row_count).scale_type IN (1,2)
        THEN
          x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * p_scale_factor;
	-- dbms_output.put_line('l_row_count  = '||to_char(l_row_count));
	-- dbms_output.put_line('ingred scaled qty  = '||to_char(x_scale_tab(l_row_count).qty));
       END IF;
      ELSE
        IF x_scale_tab(l_row_count).scale_type IN (1,2)
        THEN
          x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * b;
	-- dbms_output.put_line('l_row_count  = '||to_char(l_row_count));
	-- dbms_output.put_line('prod scaled qty-b applied  = '||to_char(x_scale_tab(l_row_count).qty));
       END IF;
      END IF;

--**********************************************************************
--Determine whether integer_multiple scaling is required.
--**********************************************************************
	IF x_scale_tab(l_row_count).scale_type = 2
    AND x_scale_tab(l_row_count).scale_multiple > 0
    -- Bug 3069408 Do not check the rounding variance
    -- AND x_scale_tab(l_row_count).scale_rounding_variance > 0
    -- AND x_scale_tab(l_row_count).scale_rounding_variance <= 1
   THEN
		-- dbms_output.put_line('just b4 call to integer_multiple_scale');
		-- dbms_output.put_line('l_row_count  = '||to_char(l_row_count));
		-- dbms_output.put_line('x_scale_tab(l_row_count).scale_type = '|| to_char(x_scale_tab(l_row_count).scale_type));

		  integer_multiple_scale(x_scale_tab(l_row_count)
	                         --Begin Bug#3164299 P.Raghu
                                 , x_scale_rec_out
                                 --End Bug#3164299
                                 , x_return_status);
		  -- dbms_output.put_line('just after  call to integer_multiple_scale');

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
				fnd_message.set_name('GME','GME_INTEGER_MULTIPLE_SCALE_ERR');
				fnd_msg_pub.add;
				-- dbms_output.put_line('INTEGER_MULTIPLE_SCALE_ERROR ');
			 	RETURN;
        END IF;
        --Begin Bug#3164299 P.Raghu
        x_scale_tab(l_row_count) := x_scale_rec_out;
        --End Bug#3164299
	 END IF;

   END LOOP;

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
  WHEN OTHERS
  THEN x_return_status := FND_API.G_RET_STS_ERROR;
END scale;


/**********************************************************************
*
* PROCEDURE:   integer_multiple_scale
* PURPOSE:     11iplus enhanced functionality that allows for
*					rounding in integer_increments.
* AUTHOR:      Elizabeth Chen
*
* HISTORY:
* =======
* Elizabeth Chen     Created.
*
* Praveen Surakanti  22-MAY-03 Bug#2901379
* Modified the integer_multiple_scale to handle
* the case of scale_rounding_variance being NULL
*
* P.Raghu            09-OCT-03 Bug#3164299
* Added code to retain the values of scale_rec for OUT parameter.
**********************************************************************/

/**********************************************************************
* OVERVIEW:
* =========
*
Procedure is called if scaling must be in integer increments.
The variance value(v) is crucial in the determination of whether
a value is eligible for rounding. Rounding is not permitted if the
initial scaled qty of the item would be changed more than the
variance value. The objective of the scaling procedure is to round to
the nearest multiple, unless rounding is specified as UP or DOWN.
In keeping the rounding allowance within this variance value, we
eliminate the need for a rebalancing function.

--v = Variance Value.
--v := scale_rounding_variance * scale_qty
--This value will be used in the condition to evaluate
--whether the quantity must be rounded up or down.

--a = Dividend of the initial scaled qty  and the scale_multiple.
--Through division, remove the multiple from the qty value. This
--step is necessary as the floor and ceil functions only determine
--the next integer up or down from a fractionalized value.

--floor_d = Difference between the initial scale qty and the
--floored value.

--ceil_d = Difference between the ceiled qty and the
--initial scaled qty.

********************************************************************/

  PROCEDURE integer_multiple_scale
  (  p_scale_rec          IN scale_rec
  ,  x_scale_rec          OUT NOCOPY scale_rec
  ,  x_return_status      OUT NOCOPY VARCHAR2
  )
  IS
  l_im_scale_rec          scale_rec  ;

   v				NUMBER :=0;
   a				NUMBER :=0;
   floor_qty	NUMBER :=0;
   floor_d		NUMBER :=0;
   ceil_qty		NUMBER :=0;
   ceil_d		NUMBER :=0;

  BEGIN

-- dbms_output.put_line('in integer_multiple_scale function');

--*********************************************************************
--Load fields of scale_rec into local variables.
--*********************************************************************
    --Begin Bug#3164299 P.Raghu
    x_scale_rec := p_scale_rec;
    --End Bug#3164299

   l_im_scale_rec.qty := p_scale_rec.qty;

   -- dbms_output.put_line('IN qty = ' || to_char(l_im_scale_rec.qty));
   l_im_scale_rec.scale_multiple := p_scale_rec.scale_multiple;
   -- dbms_output.put_line('IN scale_multiple = ' || to_char(l_im_scale_rec.scale_multiple));
   l_im_scale_rec.scale_rounding_variance := p_scale_rec.scale_rounding_variance;
   -- dbms_output.put_line('IN rounding_variance = ' || to_char(l_im_scale_rec.scale_rounding_variance));
   l_im_scale_rec.rounding_direction := p_scale_rec.rounding_direction;
   -- dbms_output.put_line('IN rounding_direction = ' || to_char(l_im_scale_rec.rounding_direction));

--*********************************************************************
--Determine variance value, v.
--*********************************************************************
   v := l_im_scale_rec.scale_rounding_variance *
        l_im_scale_rec.qty ;
-- dbms_output.put_line('v = ' || to_char(v));

--*********************************************************************
--Determine dividend value, a.
--*********************************************************************
   a := l_im_scale_rec.qty /
        l_im_scale_rec.scale_multiple ;
-- dbms_output.put_line('a = ' || to_char(a));

--*********************************************************************
--Evaluate rounding_direction value.
--Phase - Round DOWN
--If rounding_direction = 2 for DOWN, call floor function and
--continue with calculations and evaluations.
--*********************************************************************
  IF l_im_scale_rec.rounding_direction = 2
  THEN
	floor_down( a
		, l_im_scale_rec.scale_multiple
		, floor_qty
		, x_return_status  );
	-- dbms_output.put_line('floor_qty = ' || to_char(floor_qty));

  	floor_d := l_im_scale_rec.qty - floor_qty;
	-- dbms_output.put_line('floor_d = ' || to_char(floor_d));

	--*********************************************************************
	--Rounding down not permitted if the difference between the
	--initial scaled qty of the item and the floor_qty is greater
	--than the variance value(v) or if the floor_qty is 0.
	--*********************************************************************
	--BEGIN BUG#2901379 PR
	--Modified the condition to accommodate the NULL for the scale rounding variance.
	IF (v IS NULL OR floor_d <= v) AND floor_qty <> 0
	THEN
		x_scale_rec.qty := floor_qty;
	-- dbms_output.put_line('in IF') ;
	ELSE
		x_scale_rec.qty := l_im_scale_rec.qty;
	-- dbms_output.put_line('in ELSE') ;
	END IF;
	--END BUG#2901379 PR
	-- dbms_output.put_line('x_scale_rec.qty = ' || to_char(x_scale_rec.qty));

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	RETURN;

--*********************************************************************
--Phase - Round UP
--If rounding_direction = 1 for UP, call ceil function and
--continue with calculations and evaluations.
--*********************************************************************
  ELSIF l_im_scale_rec.rounding_direction = 1
  THEN
	ceil_up( a
              , l_im_scale_rec.scale_multiple
              , ceil_qty
              , x_return_status  );
	-- dbms_output.put_line('ceil_qty = ' || to_char(ceil_qty));

  	ceil_d := ceil_qty - l_im_scale_rec.qty ;
	-- dbms_output.put_line('ceil_d = ' || to_char(ceil_d));

	--*********************************************************************
	--Rounding UP not permitted if the difference between the
	--ceil_qty and the initial scaled qty of the item is greater
	--than the variance value(v).
	--*********************************************************************
	--BEGIN BUG# 2901379 PR
	--Modified the condition to accommodate the NULL for the scale rounding variance.
	IF (v IS NULL OR ceil_d <= v)
	THEN
		x_scale_rec.qty := ceil_qty;
	-- dbms_output.put_line('in ceil IF') ;
	ELSE
		x_scale_rec.qty := l_im_scale_rec.qty;
	-- dbms_output.put_line('in ceil ELSE') ;
	END IF;
	--END BUG#2901379 PR
	-- dbms_output.put_line('x_scale_rec.qty = ' || to_char(x_scale_rec.qty));

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	RETURN;

--*********************************************************************
--Phase - Round EITHER
--If rounding_direction = 0 for EITHER, call both floor and
--ceil functions and continue with calculations and evaluations.
--*********************************************************************

  ELSIF l_im_scale_rec.rounding_direction = 0
  THEN
	floor_down( a
		, l_im_scale_rec.scale_multiple
		, floor_qty
		, x_return_status  );
	-- dbms_output.put_line('either floor_qty = ' || to_char(floor_qty));

  	floor_d := l_im_scale_rec.qty - floor_qty;
	-- dbms_output.put_line('either floor_d = ' || to_char(floor_d));

	ceil_up( a
              , l_im_scale_rec.scale_multiple
              , ceil_qty
              , x_return_status  );
	-- dbms_output.put_line('either ceil_qty = ' || to_char(ceil_qty));

  	ceil_d := ceil_qty - l_im_scale_rec.qty ;
	-- dbms_output.put_line('either ceil_d = ' || to_char(ceil_d));

	--*********************************************************************
	--Determine wheter floor_d and ceil_d values are 0.
	--If they are, the scale_qty is on the multiple; no rounding
	--required.
	--*********************************************************************
	IF floor_d = 0 AND ceil_d = 0
	THEN
		-- dbms_output.put_line('floor_d and ceil_d = 0');
		x_scale_rec.qty := l_im_scale_rec.qty;
		-- dbms_output.put_line('x_scale_rec.qty = ' || to_char(x_scale_rec.qty));
   		x_return_status := FND_API.G_RET_STS_SUCCESS;
		RETURN;
		-- dbms_output.put_line('test to see if hits message after RETURN');
	END IF;

	--*********************************************************************
	--Since the goal is to round to the closest multiple, a
	--determination must be made as to whether the floor_d is less
	--than the ceil_d.
	--*********************************************************************
	IF floor_d < ceil_d
	THEN
		-- dbms_output.put_line('floor_d < ceil_d ');
	--*********************************************************************
	--Rounding down not permitted if the difference between the
	--initial scaled qty of the item and the floor_qty is greater
	--than the variance value(v) or if the floor_qty is 0.
	--*********************************************************************
		--BEGIN BUG#2901379PR
		--Modified the condition to accommodate the NULL for the scale rounding variance.
	        IF (v IS NULL OR floor_d <= v) AND floor_qty <> 0
		THEN
			x_scale_rec.qty := floor_qty;
		-- dbms_output.put_line('in IF for floor_d <= v or floor_qty<>0 ') ;
		ELSE
			x_scale_rec.qty := l_im_scale_rec.qty;
		-- dbms_output.put_line('in ELSE for floor_d > v or floor_qty=0 ') ;
		END IF;
		--END BUG#2901379 PR
		-- dbms_output.put_line('x_scale_rec.qty = ' || to_char(x_scale_rec.qty));
   		x_return_status := FND_API.G_RET_STS_SUCCESS;
		RETURN;

	ELSE
		-- dbms_output.put_line('ceil_d <= floor_d');
	--*********************************************************************
	--Rounding UP not permitted if the difference between the
	--ceil_qty and the initial scaled qty of the item is greater
	--than the variance value(v).
	--*********************************************************************
		--BEGIN BUG#2901379 PR
		--Modified the condition to accommodate the NULL for the scale rounding variance.
	        IF (v IS NULL OR ceil_d <= v)
		THEN
			x_scale_rec.qty := ceil_qty;
		-- dbms_output.put_line('in ceil IF if ceild_d <= v') ;
		ELSE
			x_scale_rec.qty := l_im_scale_rec.qty;
			-- dbms_output.put_line('in ceil ELSE if ceild_d >v') ;
		END IF;
		--END BUG#2901379 PR
		-- dbms_output.put_line('x_scale_rec.qty = ' || to_char(x_scale_rec.qty));
   		x_return_status := FND_API.G_RET_STS_SUCCESS;
		RETURN;
	END IF;

  END IF; --End Rounding Direction Evaluation
  EXCEPTION
  WHEN OTHERS
  THEN x_return_status := FND_API.G_RET_STS_ERROR;

  END integer_multiple_scale;


/**********************************************************************
*
* PROCEDURE:   floor_down
* PURPOSE:     Determines the floor value of the inital scaled qty.
* AUTHOR:      Elizabeth Chen
*
* HISTORY:
* =======
* Elizabeth Chen     Created.
*
* V.Anitha     5-MAR-2004   BUG#3018432
*                           Datatype of p_scale_multiple changed to NUMBER from
*                           PLS_INTEGER to store scale multiple value in decimals also.
* S.Sriram      15Jun2004   Bug# 3680537
*                           The qty. should first be rounded off to 9 digits before
*                           integer scaling is done.
**********************************************************************/

/**********************************************************************
*
* OVERVIEW:
* =========
*
The floor_down function accepts the dividend value (a) of the
initial scaled qty and the scale_multiple. From this value, the
floor function determines the previous integer down from this
dividend value. Once done, the scale multiple is applied to the
initial floored value thereby returning the floor_qty of the
initial scaled qty.

*********************************************************************/

  PROCEDURE floor_down
  (  p_a		IN NUMBER
  ,  p_scale_multiple	IN NUMBER -- BUG#3018432
  ,  x_floor_qty	OUT NOCOPY NUMBER
  ,  x_return_status	OUT NOCOPY VARCHAR2
  )
  IS

   l_floor_qty 	NUMBER := 0;
   l_p_a        NUMBER := 0;

  BEGIN
        l_p_a := ROUND(p_a,9);
	-- dbms_output.put_line('in floor_down function');
	l_floor_qty := floor(l_p_a);
	-- dbms_output.put_line('init floor_qty = ' || to_char(l_floor_qty));

	x_floor_qty :=l_floor_qty * p_scale_multiple;
	-- dbms_output.put_line('x_floor_qty send back to call= ' || to_char(x_floor_qty));

  END floor_down;


/*********************************************************************
CEIL_UP

/**********************************************************************
*
* PROCEDURE:   ceil_up
* PURPOSE:     Determines the ceil value of the inital scaled qty.
* AUTHOR:      Elizabeth Chen
*
* HISTORY:
* =======
* Elizabeth Chen     Created.
*
* V.Anitha     5-MAR-2004   BUG#3018432
*                           Datatype of p_scale_multiple changed to NUMBER from
*                           PLS_INTEGER to store scale multiple value in decimals also.
* S.Sriram      15Jun2004   Bug# 3680537
*                           The qty. should first be rounded off to 9 digits before
*                           integer scaling is done.
**********************************************************************/

/**********************************************************************
*
* OVERVIEW:
* =========
*
The ceil_up function accepts the dividend value (a) of the
initial scaled qty and the scale_multiple. From this value, the
ceil function determines the next integer up from this
dividend value. Once done, the scale multiple is applied to the
initial ceiled value thereby returning the ceil_qty of the
initial scaled qty.

*********************************************************************/

  PROCEDURE ceil_up
  (  p_a		IN NUMBER
  ,  p_scale_multiple	IN NUMBER -- BUG#3018432
  ,  x_ceil_qty		OUT NOCOPY NUMBER
  ,  x_return_status	OUT NOCOPY VARCHAR2
  )
  IS

   l_ceil_qty 	NUMBER := 0;
   l_p_a        NUMBER := 0;

  BEGIN
        l_p_a := ROUND(p_a,9);
	-- dbms_output.put_line('in ceil_up function');
	l_ceil_qty := ceil(l_p_a);
	-- dbms_output.put_line('init ceil_qty = ' || to_char(l_ceil_qty));

	x_ceil_qty :=l_ceil_qty * p_scale_multiple;
	-- dbms_output.put_line('x_ceil_qty send back to call= ' || to_char(x_ceil_qty));

  END ceil_up;
--*********************************************************************

/**********************************************************************
*
* PROCEDURE:   scale
* PURPOSE:     Wrapper for formula scaling.
* AUTHOR:      Chandrashekar Reddy
*
* HISTORY:
* =======
* Chandrashekar Reddy     Created.
* Jeff Baird              15-Sep-2004  Bug #3890191  Added l_scale_out_tab.
*
**********************************************************************/
  PROCEDURE scale
  (  p_fm_matl_dtl_tab    IN fm_matl_dtl_tab
  ,  p_orgn_id            IN NUMBER
  ,  p_scale_factor       IN NUMBER
  ,  p_primaries          IN VARCHAR2
  ,  x_fm_matl_dtl_tab    OUT NOCOPY fm_matl_dtl_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  )
  IS
    l_row_count           NUMBER;
    l_row_number          NUMBER;
    l_scale_tab           scale_tab;
    l_scale_out_tab       scale_tab;
-- Bug #3890191 (JKB) Added l_scale_out_tab above.
  BEGIN
    l_row_count := p_fm_matl_dtl_tab.count;
    FOR l_row_number IN 1 .. l_row_count
    LOOP
      -- NPD Conv. Use inventory_item_id and detail_uom instead of item_id and item_um
      l_scale_tab(l_row_number).inventory_item_id       := p_fm_matl_dtl_tab(l_row_number).inventory_item_id;
      l_scale_tab(l_row_number).detail_uom              := p_fm_matl_dtl_tab(l_row_number).detail_uom;
      l_scale_tab(l_row_number).qty                     := p_fm_matl_dtl_tab(l_row_number).qty;
      l_scale_tab(l_row_number).line_type               := p_fm_matl_dtl_tab(l_row_number).line_type;
      l_scale_tab(l_row_number).line_no                 := p_fm_matl_dtl_tab(l_row_number).line_no;
      l_scale_tab(l_row_number).scale_type              := p_fm_matl_dtl_tab(l_row_number).scale_type;
      l_scale_tab(l_row_number).scale_rounding_variance := p_fm_matl_dtl_tab(l_row_number).scale_rounding_variance;
      l_scale_tab(l_row_number).scale_multiple          := p_fm_matl_dtl_tab(l_row_number).scale_multiple;
      l_scale_tab(l_row_number).contribute_yield_ind    := p_fm_matl_dtl_tab(l_row_number).contribute_yield_ind;
    END LOOP;
    scale(  l_scale_tab
         ,  p_orgn_id      -- NPD Conv.
         ,  p_scale_factor
         ,  p_primaries
         ,  l_scale_out_tab
         ,  x_return_status
         );
-- Bug #3890191 (JKB) Added l_scale_out_tab above.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      x_fm_matl_dtl_tab := p_fm_matl_dtl_tab;
      FOR l_row_number in 1 .. l_row_count
      LOOP
        x_fm_matl_dtl_tab(l_row_number).qty := l_scale_out_tab(l_row_number).qty;
-- Bug #3890191 (JKB) Added l_scale_out_tab above.
      END LOOP;
    END IF;
  END scale;

/**********************************************************************
*
* PROCEDURE:   theoretical_yield
* PURPOSE:     To scale the formula/batch based on theoretical yield
* AUTHOR:      Shrikant Nene
*
* HISTORY:
* =======
* Shrikant Nene     Created.
*
**********************************************************************/
PROCEDURE theoretical_yield
  (  p_scale_tab          IN scale_tab
  ,  p_orgn_id            IN NUMBER
  ,  p_scale_factor       IN NUMBER
  ,  x_scale_tab          OUT NOCOPY scale_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  )
  IS
  l_scale_tab             scale_tab ;
  x_scale_rec				  scale_rec ;

  l_qty                   NUMBER;
  l_tab_size              NUMBER;
  --l_conv_uom            sy_uoms_mst.um_code%TYPE;
  l_conv_uom              mtl_units_of_measure.uom_code%TYPE;
  l_type_0_Y_outputs      NUMBER:= 0;
  l_type_1_Y_outputs      NUMBER:= 0;
  l_type_2_Y_outputs      NUMBER:= 0;
  l_type_0_Y_inputs       NUMBER:= 0;
  l_type_1_Y_inputs       NUMBER:= 0;
  l_type_2_Y_inputs       NUMBER:= 0;
  l_fixed_input_qty       NUMBER:= 0;
  l_fixed_output_qty      NUMBER:= 0;
  l_proportional_input_qty    NUMBER:= 0;
  l_proportional_output_qty   NUMBER:= 0;
  l_input_qty		NUMBER:= 0;
  l_input_total         NUMBER:= 0;
  l_output_total        NUMBER:= 0;
  scale_factor		NUMBER:= 0;

--**********************************************************************

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_tab_size := p_scale_tab.count;

  l_scale_tab := p_scale_tab;
  x_scale_tab := p_scale_tab;


  FOR l_row_count IN 1 .. l_tab_size
  LOOP
	--*************************************************************
	--Initial data validation. If the data is not correct,
	--exit from scaling with an error message.
	--*************************************************************
	IF (p_scale_tab(l_row_count).inventory_item_id IS NULL
	OR p_scale_tab(l_row_count).detail_uom IS NULL)
	THEN
		fnd_message.set_name('GME','GME_INVALID_ITEM_OR_ITEM_UM');
		fnd_msg_pub.add;
      		x_return_status := FND_API.G_RET_STS_ERROR;
		-- dbms_output.put_line('INVALID_ITEM_AND_OR_ITEM_UM');
	END IF;
	IF (p_scale_tab(l_row_count).line_type IS NULL) OR
	 (p_scale_tab(l_row_count).line_type NOT IN (-1,1,2))
      	THEN
		fnd_message.set_name('GME','GME_INVALID_LINE_TYPE');
		fnd_msg_pub.add;
 		x_return_status := FND_API.G_RET_STS_ERROR;
		-- dbms_output.put_line('INVALID_LINE_TYPE');
	END IF;
	IF (p_scale_tab(l_row_count).line_no IS NULL
		OR p_scale_tab(l_row_count).line_no <= 0 )
        THEN
		fnd_message.set_name('GME','GME_INVALID_LINE_NUMBER');
		fnd_msg_pub.add;
      		x_return_status := FND_API.G_RET_STS_ERROR;
		-- dbms_output.put_line('INVALID_LINE_NUMBER');
	END IF ;
	IF (p_scale_tab(l_row_count).scale_type IS NULL) OR
	(p_scale_tab(l_row_count).scale_type NOT IN (0,1,2))
        THEN
		fnd_message.set_name('GME','GME_INVALID_SCALE_TYPE');
		fnd_msg_pub.add;
    		x_return_status := FND_API.G_RET_STS_ERROR;
		-- dbms_output.put_line('INVALID_SCALE_TYPE');
	END IF;
   	IF (p_scale_tab(l_row_count).contribute_yield_ind IS NULL ) OR
   	(p_scale_tab(l_row_count).contribute_yield_ind NOT IN ('Y','N'))
	THEN
		fnd_message.set_name('GME','GME_INVALID_CONTRIBUTE_YIELD');
		fnd_msg_pub.add;
     		x_return_status := FND_API.G_RET_STS_ERROR;
		-- dbms_output.put_line('INVALID_CONTRIBUTE_YIELD_IND');
	END IF;
   	IF (p_scale_tab(l_row_count).scale_multiple < 0 )
	THEN
		fnd_message.set_name('GME','GME_INVALID_SCALE_MULTIPLE');
		fnd_msg_pub.add;
   		x_return_status := FND_API.G_RET_STS_ERROR;
		-- dbms_output.put_line('INVALID_SCALE_MULTIPLE');
	END IF;
   	IF ((p_scale_tab(l_row_count).scale_rounding_variance < 0)
	OR  (p_scale_tab(l_row_count).scale_rounding_variance > 1))
	THEN
		fnd_message.set_name('GME','GME_INVALID_SCALE_VARIANCE');
		fnd_msg_pub.add;
     		x_return_status := FND_API.G_RET_STS_ERROR;
		-- dbms_output.put_line('INVALID_SCALE_ROUNDING_VARIANCE');
	END IF;
   	IF (p_scale_tab(l_row_count).rounding_direction NOT IN (0,1,2))
	THEN
                fnd_message.set_name('GME','GME_INVALID_ROUNDING_DIRECTION');
		fnd_msg_pub.add;
      		x_return_status := FND_API.G_RET_STS_ERROR;
		-- dbms_output.put_line('INVALID_ROUNDING_DIRECTION');
	END IF;

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		RETURN;
	END IF;

--**********************************************************************
--Here determining the scale type of the outputs and whether they
--contribute to yield. Increment appropriate counter.
--**********************************************************************
    IF p_scale_tab(l_row_count).line_type IN (1,2)
    THEN
    -- dbms_output.put_line('determining scale type of output ');
      IF p_scale_tab(l_row_count).scale_type = 0 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_0_Y_outputs := l_type_0_Y_outputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type = 1 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_1_Y_outputs := l_type_1_Y_outputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type = 2 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_2_Y_outputs := l_type_2_Y_outputs+1;
      ELSE /* No need to get the non contributing to yield product/byproduct */
        -- Use this branch for future scale types.
        NULL;
      END IF;
      l_output_total := l_output_total +1 ;

--**********************************************************************
--Here determining the scale type of the inputs and whether they
--contribute to yield. Increment appropriate counter.
--**********************************************************************

    ELSIF p_scale_tab(l_row_count).line_type = -1
    THEN
    -- dbms_output.put_line('determining scale type of input ');
      IF p_scale_tab(l_row_count).scale_type = 0 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_0_Y_inputs := l_type_0_Y_inputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type = 1 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_1_Y_inputs := l_type_1_Y_inputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type = 2 AND
		 p_scale_tab(l_row_count).contribute_yield_ind = 'Y'
      THEN
        l_type_2_Y_inputs := l_type_2_Y_inputs + 1;
      ELSE /* No need to get the non contributing to yield ingredients*/
        -- Use this branch for future scale types.
        NULL;
      END IF;
      l_input_total := l_input_total +1 ;
    END IF;
  END LOOP;

  IF (l_type_1_Y_outputs + l_type_2_Y_outputs = 0) THEN
    	/*fnd_message.set_name('GME','NO_YIELD_CONTR_SECONDARIES');
	fnd_msg_pub.add;
    	-- dbms_output.put_line('NO_YIELD_CONTR_SECONDARIES_EXIST');
        x_return_status := FND_API.G_RET_STS_ERROR;*/
	RETURN;
  END IF;

  -- dbms_output.put_line('Phase I: calling uom conv ');

  get_fm_yield_type(p_orgn_id, l_conv_uom, x_return_status); -- NPD Convergence

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
	RETURN;
  END IF;

  FOR l_row_count IN 1 .. l_tab_size
  LOOP

    IF l_scale_tab(l_row_count).scale_type IN (0,1,2) AND
       l_scale_tab(l_row_count).contribute_yield_ind='Y'
    THEN

     l_qty := INV_CONVERT.inv_um_convert(item_id         => p_scale_tab(l_row_count).inventory_item_id
                                         ,precision      => 5
                                         ,from_quantity  => p_scale_tab(l_row_count).qty
                                         ,from_unit      => p_scale_tab(l_row_count).detail_uom
                                         ,to_unit        => l_conv_uom
                                         ,from_name      => NULL
                                         ,to_name	 => NULL);

      -- dbms_output.put_line('in the loop '||l_row_count||' line '||l_scale_tab(l_row_count).inventory_item_id||' Qty '||l_qty);

      IF l_qty < 0
      THEN
        -- Report UOM failure
	-- dbms_output.put_line('x_return_status =  ' || x_return_status);
    	fnd_message.set_name('GMI','GMI_OPM_UOM_NOT_FOUND');
	fnd_msg_pub.add;
    	-- dbms_output.put_line('GMI UOM_CONVERSION_ERROR');
        x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      ELSE
        l_scale_tab(l_row_count).qty := l_qty;
        l_scale_tab(l_row_count).detail_uom := l_conv_uom;
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- dbms_output.put_line('x_return_status =  ' || x_return_status);

--**********************************************************************
--PHASE I:
--If prod/byprod has a fixed scale type(scale_type=0) and contributes
--to yield, add its qty to fixed qty variable.
--If prod/byprod has a scalable scale type(scale_type=1,2) and contributes
--to yield, add its qty to proportional qty variable.
--**********************************************************************

	-- dbms_output.put_line('Phase I:increment fix/proportional output qty counter');
        IF l_scale_tab(l_row_count).line_type IN (1,2) AND
           l_scale_tab(l_row_count).contribute_yield_ind='Y'
        THEN
          IF l_scale_tab(l_row_count).scale_type = 0
          THEN
            l_fixed_output_qty := l_fixed_output_qty + l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('l_fixed_output_qty= '||to_char(l_fixed_output_qty));
          ELSIF l_scale_tab(l_row_count).scale_type IN (1,2) AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
          THEN
            l_proportional_output_qty :=  l_proportional_output_qty +
					  l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('l_proportional_output_qty= '||to_char(l_proportional_output_qty));
          END IF;

--**********************************************************************
--PHASE I:
--If ingredient has a fixed scale type(scale_type=0) and contributes
--to yield, add its qty to fixed qty variable.
--If ingredient has a scalable scale type(scale_type=1,2) and contributes
--to yield, add its qty to proportional qty variable.
--**********************************************************************
        ELSE
	-- dbms_output.put_line('Phase I:increment fix/proportional INPUT qty counter');
          IF l_scale_tab(l_row_count).scale_type = 0 AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
          THEN
            l_fixed_input_qty := l_fixed_input_qty + l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('l_fixed_input_qty= '||to_char(l_fixed_input_qty));

          ELSIF l_scale_tab(l_row_count).scale_type IN (1,2) AND
             l_scale_tab(l_row_count).contribute_yield_ind='Y'
          THEN
            l_proportional_input_qty :=  l_proportional_input_qty +
					 l_scale_tab(l_row_count).qty;
	-- dbms_output.put_line('l_proportional_input_qty= '||to_char(l_proportional_input_qty));
          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;


  l_input_qty := p_scale_factor * (l_proportional_input_qty + l_fixed_input_qty);
  IF l_fixed_output_qty >= l_input_qty THEN
	-- dbms_output.put_line('scale fact '||p_scale_factor||
        --			'prop inp '||l_proportional_input_qty||
        --			'fixed inp '||l_fixed_input_qty||
        --			'fixed output '||l_fixed_output_qty);
    	fnd_message.set_name('GME','GME_FIX_ITEM_GTR_YIELD');
	fnd_msg_pub.add;
        -- dbms_output.put_line('Fixed items are greater than desired yield');
        x_return_status := FND_API.G_RET_STS_ERROR;
     RETURN;
  END IF;

  IF l_proportional_output_qty <= 0 THEN
  /* If ther are no scalable outputs defined then spread the inputs equaly */
     l_proportional_output_qty := l_type_1_Y_outputs + l_type_2_Y_outputs;
  END IF;

  scale_factor := (l_input_qty - l_fixed_output_qty )/ l_proportional_output_qty;
  -- dbms_output.put_line('Scale factor is '||scale_factor);

  FOR l_row_count IN 1 .. l_tab_size
  LOOP
    IF l_scale_tab(l_row_count).scale_type IN (1,2) AND
       l_scale_tab(l_row_count).contribute_yield_ind='Y' AND
       l_scale_tab(l_row_count).line_type IN (1,2)  THEN

        IF l_proportional_output_qty <= 0 THEN
	     x_scale_tab(l_row_count).qty := scale_factor;
        ELSE
	     x_scale_tab(l_row_count).qty :=  scale_factor * x_scale_tab(l_row_count).qty;
        END IF;
    END IF;
  END LOOP;
  RETURN;

END theoretical_yield;

END gmd_common_scale;

/
