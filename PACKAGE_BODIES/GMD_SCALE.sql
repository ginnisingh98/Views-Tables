--------------------------------------------------------
--  DDL for Package Body GMD_SCALE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SCALE" AS
/* $Header: GMDSCALB.pls 120.1 2005/09/29 11:21:11 srsriran noship $ */

G_PKG_NAME VARCHAR2(32);

PROCEDURE scale
  (  p_fm_matl_dtl_tab    IN fm_matl_dtl_tab
  ,  p_scale_factor       IN NUMBER
  ,  p_primaries          IN VARCHAR2
  ,  x_fm_matl_dtl_tab    OUT NOCOPY fm_matl_dtl_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  )
  IS
    l_row_count           NUMBER;
    l_row_number          NUMBER;
    l_scale_tab           scale_tab := scale_tab();
  BEGIN
    l_row_count := p_fm_matl_dtl_tab.count;
    FOR l_row_number IN 1 .. l_row_count
    LOOP
      l_scale_tab.extend;
      l_scale_tab(l_row_number).item_id := p_fm_matl_dtl_tab(l_row_number).item_id;
      l_scale_tab(l_row_number).item_um := p_fm_matl_dtl_tab(l_row_number).item_um;
      l_scale_tab(l_row_number).qty := p_fm_matl_dtl_tab(l_row_number).qty;
      l_scale_tab(l_row_number).line_type := p_fm_matl_dtl_tab(l_row_number).line_type;
      l_scale_tab(l_row_number).line_no := p_fm_matl_dtl_tab(l_row_number).line_no;
      l_scale_tab(l_row_number).scale_type := p_fm_matl_dtl_tab(l_row_number).scale_type;
    END LOOP;
    scale(  l_scale_tab
         ,  p_scale_factor
         ,  p_primaries
         ,  l_scale_tab
         ,  x_return_status
         );
    IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      x_fm_matl_dtl_tab := p_fm_matl_dtl_tab;
      FOR l_row_number in 1 .. l_row_count
      LOOP
        x_fm_matl_dtl_tab(l_row_number).qty := l_scale_tab(l_row_number).qty;
      END LOOP;
    END IF;
  END scale;


  PROCEDURE scale
  (  p_scale_tab          IN scale_tab
  ,  p_scale_factor       IN NUMBER
  ,  p_primaries          IN VARCHAR2
  ,  x_scale_tab          OUT NOCOPY scale_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  )
IS
  l_scale_tab             scale_tab := scale_tab() ;

  l_qty                 NUMBER;
  l_tab_size            NUMBER;
  l_conv_uom            VARCHAR2(4);
  l_type_0_outputs      NUMBER:= 0;
  l_type_1_outputs      NUMBER:= 0;
  l_type_2_outputs      NUMBER:= 0;
  l_type_3_outputs      NUMBER:= 0;
  l_type_0_inputs       NUMBER:= 0;
  l_type_1_inputs       NUMBER:= 0;
  l_type_2_inputs       NUMBER:= 0;
  l_type_3_inputs       NUMBER:= 0;
  l_fixed_input_qty     NUMBER:= 0;
  l_fixed_output_qty    NUMBER:= 0;
  l_proportional_input_qty    NUMBER:= 0;
  l_proportional_output_qty   NUMBER:= 0;
  P                     NUMBER:= 0;
  S                     NUMBER:= 0;
  A                     NUMBER:= 0;
  k                     NUMBER:= 0;
  b                     NUMBER:= 0;

BEGIN

  -- Find the primary product. We will use its uom as the basis of the arithmetic
  -- that follows. Whilst we are in the loop, accumulate a few totals which will
  -- be handy later on.

  l_tab_size := p_scale_tab.count;

  FOR l_row_count IN 1 .. l_tab_size
  LOOP
    IF p_scale_tab(l_row_count).line_type = 1
    AND p_scale_tab(l_row_count).line_no = 1
    THEN
      l_conv_uom := p_scale_tab(l_row_count).item_um;
    END IF;

    IF p_scale_tab(l_row_count).line_type IN (1,2)
    THEN
      IF p_scale_tab(l_row_count).scale_type = 0
      THEN
        l_type_0_outputs := l_type_0_outputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type = 1
      THEN
        l_type_1_outputs := l_type_1_outputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type = 2
      THEN
        l_type_2_outputs := l_type_2_outputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type = 3
      THEN
        l_type_3_outputs := l_type_3_outputs+1;
      ELSE
        -- Use this branch for future scale types.
        NULL;
      END IF;
    ELSIF p_scale_tab(l_row_count).line_type = -1
    THEN
      IF p_scale_tab(l_row_count).scale_type = 0
      THEN
        l_type_0_inputs := l_type_0_inputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type = 1
      THEN
        l_type_1_inputs := l_type_1_inputs + 1;
      ELSIF p_scale_tab(l_row_count).scale_type = 2
      THEN
        l_type_2_inputs := l_type_2_inputs+1;
      ELSIF p_scale_tab(l_row_count).scale_type = 3
      THEN
        l_type_3_inputs := l_type_3_inputs+1;
      ELSE
        -- Use this branch for future scale types.
        NULL;
      END IF;
    END IF;
  END LOOP;

  -- See if we can carry on, or if the scaling is trivial (eg everything is type 1)
  -- then make an early exit after applying the factor appropriately

  IF l_type_1_inputs + l_type_3_inputs + l_type_1_outputs + l_type_3_outputs = l_tab_size

  THEN
    -- scaling is trivial, multiply all inputs and outputs by the scale factor
    -- and exit
-- *********************************
    x_scale_tab := p_scale_tab;
    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * p_scale_factor;
    END LOOP;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
-- *********************************

  ELSIF l_type_0_inputs + l_type_2_inputs + l_type_0_outputs + l_type_2_outputs = l_tab_size
  THEN
    -- Scaling is not possible as no items are scalable.
    x_scale_tab := p_scale_tab;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;

  -- If we've reached here then the fun begins. First we must convert each
  -- quantity to the primary product's unit of measure (determined above).

  l_scale_tab := p_scale_tab;
  x_scale_tab := p_scale_tab;

  FOR l_row_count IN 1 .. l_tab_size
  LOOP
    IF l_scale_tab(l_row_count).scale_type IN (0,1)
    THEN
      l_qty := GMICUOM.uom_conversion
               (  p_scale_tab(l_row_count).item_id
                , 0
                , p_scale_tab(l_row_count).qty
                , p_scale_tab(l_row_count).item_um
                , l_conv_uom
                ,0
                );
      IF l_qty < 0
      THEN
        -- Report UOM failure
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
        l_scale_tab(l_row_count).qty := l_qty;
        l_scale_tab(l_row_count).item_um := l_conv_uom;

        IF l_scale_tab(l_row_count).line_type IN (1,2)
        THEN
          IF l_scale_tab(l_row_count).scale_type = 0
          THEN
            l_fixed_output_qty := l_fixed_output_qty + l_scale_tab(l_row_count).qty;
          ELSIF l_scale_tab(l_row_count).scale_type = 1
          THEN
            l_proportional_output_qty :=  l_proportional_output_qty + l_scale_tab(l_row_count).qty;
          END IF;
        ELSE
          IF l_scale_tab(l_row_count).scale_type = 0
          THEN
            l_fixed_input_qty := l_fixed_input_qty + l_scale_tab(l_row_count).qty;
          ELSIF l_scale_tab(l_row_count).scale_type = 1
          THEN
            l_proportional_input_qty :=  l_proportional_input_qty + l_scale_tab(l_row_count).qty;

          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;

  -- So far, so good. With the above quantities we can scale the formula correctly.
  -- If the parameter p_primaries indicates that we are scaling outputs then we apply the
  -- given factor (p_scale_factor) to those outputs which can be scaled and apply the
  -- calculated factor to the scalable inputs. If p_primaries indicates that we are scaling
  -- inputs then we apply the given factor to the ingredients which can be scaled and apply the
  -- calculated factor to the scalable outputs.

  -- Calculate the factor to apply.
  IF p_primaries = 'OUTPUTS'
  THEN
    P := l_fixed_output_qty + l_proportional_output_qty;
    S := l_fixed_input_qty + l_proportional_input_qty;
    k := P/S;
    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      IF l_scale_tab(l_row_count).line_type IN (1,2)
      THEN
        IF l_scale_tab(l_row_count).scale_type = 1
        THEN
          A := A + p_scale_factor * l_scale_tab(l_row_count).qty;
        ELSIF l_scale_tab(l_row_count).scale_type = 0
        THEN
          A := A + l_scale_tab(l_row_count).qty;
        END IF;
      END IF;
    END LOOP;

    b := ((A/k) - (l_fixed_input_qty))/(l_proportional_input_qty);
    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      IF x_scale_tab(l_row_count).line_type IN (1,2)
      THEN
        IF x_scale_tab(l_row_count).scale_type IN (1,3)
        THEN
          x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * p_scale_factor;
        END IF;
      ELSE
        IF x_scale_tab(l_row_count).scale_type IN (1,3)
        THEN
          x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * b;
        END IF;
      END IF;
    END LOOP;
  ELSIF  p_primaries = 'INPUTS'
  THEN
    P := l_fixed_input_qty + l_proportional_input_qty;
    S := l_fixed_output_qty + l_proportional_output_qty;
    k := P/S;
    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      IF l_scale_tab(l_row_count).line_type = -1
      THEN
        IF l_scale_tab(l_row_count).scale_type = 1
        THEN
          A := A + p_scale_factor * l_scale_tab(l_row_count).qty;
        ELSIF l_scale_tab(l_row_count).scale_type = 0
        THEN
          A := A + l_scale_tab(l_row_count).qty;
        END IF;
      END IF;
    END LOOP;

    b := ((A/k) - (l_fixed_output_qty))/(l_proportional_output_qty);

    FOR l_row_count IN 1 .. l_tab_size
    LOOP
      IF x_scale_tab(l_row_count).line_type = -1
      THEN
        IF x_scale_tab(l_row_count).scale_type IN (1,3)
        THEN
          x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * p_scale_factor;

        END IF;
      ELSE
        IF x_scale_tab(l_row_count).scale_type IN (1,3)
        THEN
          x_scale_tab(l_row_count).qty := x_scale_tab(l_row_count).qty * b;
        END IF;
      END IF;
    END LOOP;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
  WHEN OTHERS
  THEN x_return_status := FND_API.G_RET_STS_ERROR;
  END scale;
END gmd_scale;

/
