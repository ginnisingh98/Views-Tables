--------------------------------------------------------
--  DDL for Package Body INL_LANDEDCOST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_LANDEDCOST_PUB" AS
/* $Header: INLPLCOB.pls 120.6.12010000.8 2014/01/02 14:25:36 anandpra ship $ */

-- API name   : Get_LandedCost
-- Type       : Public
-- Function   :
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version         IN NUMBER           Required
--              p_init_msg_list       IN VARCHAR2         Optional  Default = FND_API.G_FALSE
--              p_commit              IN VARCHAR2         Optional  Default = FND_API.G_FALSE
--              p_ship_header_id      IN NUMBER           Required
--
-- OUT        : x_return_status       OUT NOCOPY VARCHAR2
--              x_msg_count           OUT NOCOPY NUMBER
--              x_msg_data            OUT NOCOPY VARCHAR2
--              x_landed_cost_tbl     OUT NOCOPY landed_cost_tbl
--
-- Version    : Current version 1.0
--
-- Notes      :


--Bug#14158274 Procedure has been redesigned
PROCEDURE Get_LandedCost(
    p_api_version     IN NUMBER,
    p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
    p_commit          IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_header_id  IN NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2,
    x_landed_cost_tbl OUT NOCOPY landed_cost_tbl
) IS

  l_proc_name       CONSTANT VARCHAR2(30) := 'Get_LandedCost';
  l_api_version    CONSTANT NUMBER := 1.0;

  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_debug_info     VARCHAR2(200);
  l_lc_ln_index    NUMBER := NVL(x_landed_cost_tbl.last,0); --Bug#14158274 + 1;
  l_first_ln       NUMBER:=0;

/*
  CURSOR c_landed_cost IS
    SELECT sl.ship_line_id
    FROM inl_ship_lines sl
    WHERE sl.ship_header_id = p_ship_header_id
    AND sl.adjustment_num = 0
    ORDER BY sl.ship_line_id;
  l_landed_cost c_landed_cost%ROWTYPE;
*/
    CURSOR c_landed_cost IS
    SELECT
        NVL(sl.parent_ship_line_id,sl.ship_line_id) parent_ship_line_id,
        lc.organization_id,
        sl.inventory_item_id,
        sl.primary_qty,
        sl.primary_uom_code,
        lc.component_type,
        SUM(lc.allocated_amt) ALC,
        SUM(lc.estimated_allocated_amt) ELC
    FROM
        inl_ship_lines sl,
        inl_det_landed_costs_v lc
    WHERE lc.ship_header_id   = p_ship_header_id
    AND lc.adjustment_num = (SELECT MAX(alloc.adjustment_num)
                             FROM inl_allocations alloc
                             WHERE alloc.ship_header_id = p_ship_header_id)
    AND sl.ship_line_id     = lc.ship_line_id
    GROUP BY  NVL(sl.parent_ship_line_id,sl.ship_line_id),
        lc.organization_id,
        sl.inventory_item_id,
        sl.primary_qty,
        sl.primary_uom_code,
        lc.component_type
    ORDER BY NVL(sl.parent_ship_line_id,sl.ship_line_id);
    TYPE l_landed_cost_tp IS TABLE OF c_landed_cost%ROWTYPE INDEX BY BINARY_INTEGER;
    l_landed_cost_lst l_landed_cost_tp;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name);
    -- Standard Start of API savepoint
    SAVEPOINT Get_LandedCost_PVT2;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
                    l_api_version,
                    p_api_version,
                    l_proc_name,
                    g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
        l_debug_info := 'Get landed cost info for ship_header_id: ' || p_ship_header_id;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info);

        OPEN c_landed_cost;
        FETCH c_landed_cost BULK COLLECT INTO l_landed_cost_lst;
        CLOSE c_landed_cost;

        l_debug_info := l_landed_cost_lst.LAST||' line(s) have been retrieved (l_landed_cost_lst).';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info
        ) ;
        IF NVL (l_landed_cost_lst.LAST, 0) > 0 THEN

            FOR j IN NVL (l_landed_cost_lst.FIRST, 0)..NVL (l_landed_cost_lst.LAST, 0)
            LOOP
              INL_LOGGING_PVT.Log_Variable (
                  p_module_name => g_module_name,
                  p_procedure_name => l_proc_name,
                  p_var_name => 'l_landed_cost_lst('||j||').parent_ship_line_id',
                  p_var_value => l_landed_cost_lst(j).parent_ship_line_id
              ) ;
              IF l_first_ln = 0
              OR NVL(x_landed_cost_tbl(l_lc_ln_index).ship_line_id,-1) <> l_landed_cost_lst(j).parent_ship_line_id
              THEN
                  l_first_ln := 1;
                  l_lc_ln_index:=l_lc_ln_index+1;
                  INL_LOGGING_PVT.Log_Variable (
                      p_module_name => g_module_name,
                      p_procedure_name => l_proc_name,
                      p_var_name => 'l_lc_ln_index',
                      p_var_value => l_lc_ln_index
                  ) ;
                  INL_LOGGING_PVT.Log_Variable (
                      p_module_name => g_module_name,
                      p_procedure_name => l_proc_name,
                      p_var_name => 'l_landed_cost_lst('||j||').parent_ship_line_id',
                      p_var_value => l_landed_cost_lst(j).parent_ship_line_id
                  ) ;
                  x_landed_cost_tbl(l_lc_ln_index).ship_line_id       := l_landed_cost_lst(j).parent_ship_line_id;
                  x_landed_cost_tbl(l_lc_ln_index).organization_id    := l_landed_cost_lst(j).organization_id;
                  x_landed_cost_tbl(l_lc_ln_index).inventory_item_id  := l_landed_cost_lst(j).inventory_item_id;
                  x_landed_cost_tbl(l_lc_ln_index).primary_qty        := l_landed_cost_lst(j).primary_qty;
                  x_landed_cost_tbl(l_lc_ln_index).primary_uom_code   := l_landed_cost_lst(j).primary_uom_code;

                  x_landed_cost_tbl(l_lc_ln_index).estimated_item_price := 0;
                  x_landed_cost_tbl(l_lc_ln_index).estimated_charges := 0;
                  x_landed_cost_tbl(l_lc_ln_index).estimated_taxes := 0;
                  x_landed_cost_tbl(l_lc_ln_index).estimated_unit_landed_cost := 0;
                  x_landed_cost_tbl(l_lc_ln_index).actual_item_price := 0;
                  x_landed_cost_tbl(l_lc_ln_index).actual_charges := 0;
                  x_landed_cost_tbl(l_lc_ln_index).actual_taxes := 0;
                  x_landed_cost_tbl(l_lc_ln_index).actual_unit_landed_cost := 0;
              END IF;
              INL_LOGGING_PVT.Log_Variable (
                  p_module_name => g_module_name,
                  p_procedure_name => l_proc_name,
                  p_var_name => 'l_landed_cost_lst('||j||').component_type',
                  p_var_value => l_landed_cost_lst(j).component_type
              ) ;
              INL_LOGGING_PVT.Log_Variable (
                  p_module_name => g_module_name,
                  p_procedure_name => l_proc_name,
                  p_var_name => 'l_landed_cost_lst('||j||').ELC',
                  p_var_value => l_landed_cost_lst(j).ELC
              ) ;
              INL_LOGGING_PVT.Log_Variable (
                  p_module_name => g_module_name,
                  p_procedure_name => l_proc_name,
                  p_var_name => 'l_landed_cost_lst('||j||').ALC',
                  p_var_value => l_landed_cost_lst(j).ALC
              ) ;

              x_landed_cost_tbl(l_lc_ln_index).estimated_unit_landed_cost :=
                  x_landed_cost_tbl(l_lc_ln_index).estimated_unit_landed_cost + (l_landed_cost_lst(j).ELC/l_landed_cost_lst(j).primary_qty);
              x_landed_cost_tbl(l_lc_ln_index).actual_unit_landed_cost :=
                  x_landed_cost_tbl(l_lc_ln_index).actual_unit_landed_cost + (l_landed_cost_lst(j).ALC/l_landed_cost_lst(j).primary_qty);
              IF l_landed_cost_lst(j).component_type = 'ITEM PRICE' THEN
                  x_landed_cost_tbl(l_lc_ln_index).estimated_item_price :=
                    x_landed_cost_tbl(l_lc_ln_index).estimated_item_price + NVL(l_landed_cost_lst(j).ELC,0);

                  x_landed_cost_tbl(l_lc_ln_index).actual_item_price :=
                    x_landed_cost_tbl(l_lc_ln_index).actual_item_price + NVL(l_landed_cost_lst(j).ALC,0);
              ELSIF l_landed_cost_lst(j).component_type = 'CHARGE' THEN
                  x_landed_cost_tbl(l_lc_ln_index).estimated_charges :=
                    x_landed_cost_tbl(l_lc_ln_index).estimated_charges + NVL(l_landed_cost_lst(j).ELC,0);

                  x_landed_cost_tbl(l_lc_ln_index).actual_charges :=
                    x_landed_cost_tbl(l_lc_ln_index).actual_charges + NVL(l_landed_cost_lst(j).ALC,0);
              ELSIF l_landed_cost_lst(j).component_type = 'TAX' THEN
                  x_landed_cost_tbl(l_lc_ln_index).estimated_taxes :=
                    x_landed_cost_tbl(l_lc_ln_index).estimated_taxes + NVL(l_landed_cost_lst(j).ELC,0);

                  x_landed_cost_tbl(l_lc_ln_index).actual_taxes :=
                    x_landed_cost_tbl(l_lc_ln_index).actual_taxes + NVL(l_landed_cost_lst(j).ALC,0);
              ELSE
                  INL_LOGGING_PVT.Log_Statement (
                      p_module_name    => g_module_name,
                      p_procedure_name => l_proc_name,
                      p_debug_info     => 'unexpected component_type: '||l_landed_cost_lst(j).component_type);
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          END LOOP;
      END IF;
    END;
    l_debug_info := 'End Loop ';
    INL_LOGGING_PVT.Log_Statement
        (p_module_name => g_module_name,
         p_procedure_name => l_proc_name,
         p_debug_info => l_debug_info);

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.g_false,
    p_count => x_msg_count,
    p_data  => x_msg_data);

  -- Standard End of Procedure/Function Logging
  INL_LOGGING_PVT.Log_EndProc (
    p_module_name => g_module_name,
    p_procedure_name => l_proc_name);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    INL_LOGGING_PVT.Log_Statement
        (p_module_name => g_module_name,
         p_procedure_name => l_proc_name,
         p_debug_info => 'G_EXC_ERROR:'||SQLERRM);
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name);
    ROLLBACK TO Get_LandedCost_PVT2;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_Statement
        (p_module_name => g_module_name,
         p_procedure_name => l_proc_name,
         p_debug_info => 'G_EXC_UNEXPECTED_ERROR:'||SQLERRM);
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name);
    ROLLBACK TO Get_LandedCost_PVT2;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);
  WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_Statement
        (p_module_name => g_module_name,
         p_procedure_name => l_proc_name,
         p_debug_info => 'OTHERS:'||SQLERRM);
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name);
    ROLLBACK TO Get_LandedCost_PVT2;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
            g_pkg_name,
            l_proc_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);
END Get_LandedCost;

-- API name   : Get_LandedCost
-- Type       : Public
-- Function   :
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version                IN NUMBER           Required
--              p_init_msg_list              IN VARCHAR2         Optional  Default = FND_API.G_FALSE
--              p_commit                     IN VARCHAR2         Optional  Default = FND_API.G_FALSE
--              p_ship_line_id               IN NUMBER,          Required
-- Bug 17536452
--				      p_transaction_date			     IN DATE             Default = SYSDATE
-- Bug 17536452
--
-- OUT        : x_return_status              OUT NOCOPY VARCHAR2
--              x_msg_count                  OUT NOCOPY NUMBER
--              x_msg_data                   OUT NOCOPY VARCHAR2
--              x_organization_id            OUT NOCOPY NUMBER,
--              x_inventory_item_id          OUT NOCOPY NUMBER,
--              x_primary_qty                OUT NOCOPY NUMBER,
--              x_primary_uom_code           OUT NOCOPY VARCHAR2,
--              x_estimated_item_price       OUT NOCOPY NUMBER,
--              x_estimated_charges          OUT NOCOPY NUMBER,
--              x_estimated_taxes            OUT NOCOPY NUMBER,
--              x_estimated_unit_landed_cost OUT NOCOPY NUMBER,
--              x_actual_item_price          OUT NOCOPY NUMBER,
--              x_actual_charges             OUT NOCOPY NUMBER,
--              x_actual_taxes               OUT NOCOPY NUMBER,
--              x_actual_unit_landed_cost    OUT NOCOPY NUMBER,
--              x_ajustment_num              OUT NOCOPY NUMBER   -- OPM Integration
--
-- Version    : Current version 1.0
--
-- Notes      :
--Bug#14158274 Procedure has been redesigned
PROCEDURE Get_LandedCost(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_line_id               IN NUMBER,
-- Bug 17536452
	  p_transaction_date           IN DATE DEFAULT SYSDATE,
-- Bug 17536452
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    x_organization_id            OUT NOCOPY NUMBER,
    x_inventory_item_id          OUT NOCOPY NUMBER,
    x_primary_qty                OUT NOCOPY NUMBER,
    x_primary_uom_code           OUT NOCOPY VARCHAR2,
    x_estimated_item_price       OUT NOCOPY NUMBER,
    x_estimated_charges          OUT NOCOPY NUMBER,
    x_estimated_taxes            OUT NOCOPY NUMBER,
    x_estimated_unit_landed_cost OUT NOCOPY NUMBER,
    x_actual_item_price          OUT NOCOPY NUMBER,
    x_actual_charges             OUT NOCOPY NUMBER,
    x_actual_taxes               OUT NOCOPY NUMBER,
    x_actual_unit_landed_cost    OUT NOCOPY NUMBER,
    x_adjustment_num             OUT NOCOPY NUMBER   -- opm integration
) IS


  l_proc_name              CONSTANT VARCHAR2(30) := 'Get_LandedCost-2';
  l_api_version           CONSTANT NUMBER := 1.0;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_debug_info            VARCHAR2(200);

    CURSOR c_landed_cost IS
    SELECT
        NVL(sl0.parent_ship_line_id,sl0.ship_line_id) parent_ship_line_id,
        lc.organization_id,
        sl0.inventory_item_id,
        sl0.primary_qty,
        sl0.primary_uom_code,
        lc.component_type,
        SUM(lc.allocated_amt) ALC,
        SUM(lc.estimated_allocated_amt) ELC,
        lc.adjustment_num
    FROM
        inl_ship_lines_all sl0,  --access to table (performance)
        inl_det_landed_costs_v lc
    WHERE sl0.ship_line_id  = p_ship_line_id
    AND lc.ship_header_id   = sl0.ship_header_id
-- Bug 17536452
--
--    AND lc.adjustment_num = (SELECT MAX(alloc.adjustment_num)
--                             FROM inl_allocations alloc
--                             WHERE alloc.ship_header_id = sl0.ship_header_id)
--    AND lc.adjustment_num = (SELECT MAX(alloc.adjustment_num)
--                             FROM inl_allocations alloc
--                             WHERE alloc.ship_header_id = sl0.ship_header_id
--                             AND alloc.creation_date <= p_transaction_date)
--
    AND lc.adjustment_num = (SELECT NVL(MAX(alloc.adjustment_num),0)
                             FROM inl_allocations alloc
                             WHERE alloc.ship_header_id = sl0.ship_header_id
                             AND alloc.creation_date <= p_transaction_date)
-- Bug 17536452

    AND lc.ship_line_id = (SELECT MAX(sl.ship_line_id)
                          FROM inl_ship_lines_all sl --synon removed Bug 17536452
                          WHERE sl.ship_header_id     = sl0.ship_header_id
                          AND  sl.ship_line_group_id  = sl0.ship_line_group_id
                          AND sl.ship_line_num        = sl0.ship_line_num
                          AND sl.adjustment_num      <= lc.adjustment_num
                          )
    GROUP BY  NVL(sl0.parent_ship_line_id,sl0.ship_line_id),
        lc.organization_id,
        sl0.inventory_item_id,
        sl0.primary_qty,
        sl0.primary_uom_code,
        lc.component_type,
        lc.adjustment_num
    ;
    TYPE l_landed_cost_tp IS TABLE OF c_landed_cost%ROWTYPE INDEX BY BINARY_INTEGER;
    l_landed_cost_lst l_landed_cost_tp;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
      p_module_name    => g_module_name,
      p_procedure_name => l_proc_name
    );
    -- Standard Start of API savepoint
    SAVEPOINT Get_LandedCost_PVT3;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
                      l_api_version,
                      p_api_version,
                      l_proc_name,
                      g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN

        l_debug_info := 'p_transaction_date: ' || p_transaction_date;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info);

        OPEN c_landed_cost;
        FETCH c_landed_cost BULK COLLECT INTO l_landed_cost_lst;
        CLOSE c_landed_cost;

        l_debug_info := l_landed_cost_lst.LAST||' line(s) have been retrieved (l_landed_cost_lst).';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info
        ) ;
        IF NVL (l_landed_cost_lst.LAST, 0) > 0 THEN

            x_organization_id            := l_landed_cost_lst(l_landed_cost_lst.FIRST).organization_id;
            x_inventory_item_id          := l_landed_cost_lst(l_landed_cost_lst.FIRST).inventory_item_id;
            x_primary_qty                := l_landed_cost_lst(l_landed_cost_lst.FIRST).primary_qty;
            x_primary_uom_code           := l_landed_cost_lst(l_landed_cost_lst.FIRST).primary_uom_code;
            x_adjustment_num             := l_landed_cost_lst(l_landed_cost_lst.FIRST).adjustment_num;
            x_estimated_item_price       := 0;
            x_estimated_charges          := 0;
            x_estimated_taxes            := 0;
            x_estimated_unit_landed_cost := 0;
            x_actual_item_price          := 0;
            x_actual_charges             := 0;
            x_actual_taxes               := 0;
            x_actual_unit_landed_cost    := 0;
            FOR j IN NVL (l_landed_cost_lst.FIRST, 0)..NVL (l_landed_cost_lst.LAST, 0)
            LOOP
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_landed_cost_lst('||j||').component_type',
                    p_var_value => l_landed_cost_lst(j).component_type
                ) ;
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_landed_cost_lst('||j||').ELC',
                    p_var_value => l_landed_cost_lst(j).ELC
                ) ;
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_landed_cost_lst('||j||').ALC',
                    p_var_value => l_landed_cost_lst(j).ALC
                ) ;

                x_estimated_unit_landed_cost :=
                    x_estimated_unit_landed_cost + (l_landed_cost_lst(j).ELC/l_landed_cost_lst(j).primary_qty);
                x_actual_unit_landed_cost :=
                    x_actual_unit_landed_cost + (l_landed_cost_lst(j).ALC/l_landed_cost_lst(j).primary_qty);
                IF l_landed_cost_lst(j).component_type = 'ITEM PRICE' THEN
                    x_estimated_item_price :=
                      x_estimated_item_price + NVL(l_landed_cost_lst(j).ELC,0);

                    x_actual_item_price :=
                      x_actual_item_price + NVL(l_landed_cost_lst(j).ALC,0);
                ELSIF l_landed_cost_lst(j).component_type = 'CHARGE' THEN
                    x_estimated_charges :=
                      x_estimated_charges + NVL(l_landed_cost_lst(j).ELC,0);

                    x_actual_charges :=
                      x_actual_charges + NVL(l_landed_cost_lst(j).ALC,0);
                ELSIF l_landed_cost_lst(j).component_type = 'TAX' THEN
                    x_estimated_taxes :=
                      x_estimated_taxes + NVL(l_landed_cost_lst(j).ELC,0);

                    x_actual_taxes :=
                      x_actual_taxes + NVL(l_landed_cost_lst(j).ALC,0);
                ELSE
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name    => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info     => 'unexpected component_type: '||l_landed_cost_lst(j).component_type);
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;
        END IF;
    END;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => g_module_name,
        p_var_name => 'x_actual_unit_landed_cost',
        p_var_value => x_actual_unit_landed_cost);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => g_module_name,
        p_var_name => 'x_adjustment_num',
        p_var_value => x_adjustment_num);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
      p_module_name    => g_module_name,
      p_procedure_name => l_proc_name);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name);
    ROLLBACK TO Get_LandedCost_PVT3;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name);
    ROLLBACK TO Get_LandedCost_PVT3;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data);
  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name);
    ROLLBACK TO Get_LandedCost_PVT3;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
            g_pkg_name,
            l_proc_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data);
END Get_LandedCost;

END INL_LANDEDCOST_PUB;

/
