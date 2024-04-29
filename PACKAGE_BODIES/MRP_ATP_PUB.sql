--------------------------------------------------------
--  DDL for Package Body MRP_ATP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ATP_PUB" AS
/* $Header: MRPEATPB.pls 115.55 2002/12/02 22:57:00 dsting ship $  */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MRP_ATP_PUB';

-- This package contains 2 procedures : Call_ATP and Call_ATP_No_Commit.
-- Call_ATP and Call_ATP_No_Commit are almost the same except
-- Call ATP is a automonous transaction which will commit the data.
-- Call_ATP_No_Commit will be used by backlog scheduling and Call_ATP will be
-- used by OM and all the other caller.  In order to maintain this package
-- easier, Call_ATP actually calls the Call_ATP_No_Commit and then do a commit

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE Call_ATP (
               p_session_id         IN OUT NoCopy NUMBER,
               p_atp_rec            IN    MRP_ATP_PUB.ATP_Rec_Typ,
               x_atp_rec            OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
               x_atp_supply_demand  OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_atp_period         OUT   NoCopy MRP_ATP_PUB.ATP_Period_Typ,
               x_atp_details        OUT   NoCopy MRP_ATP_PUB.ATP_Details_Typ,
               x_return_status      OUT   NoCopy VARCHAR2,
               x_msg_data           OUT   NoCopy VARCHAR2,
               x_msg_count          OUT   NoCopy NUMBER
) IS
--PRAGMA AUTONOMOUS_TRANSACTION;
i                PLS_INTEGER;
counter1         NUMBER;
p_line_arr       MRP_OM_API_PK.line_id_tbl;
x_return_status1 VARCHAR2(1);

BEGIN

	MSC_ATP_PUB.Call_ATP(
               p_session_id,
               p_atp_rec,
               x_atp_rec,
               x_atp_supply_demand,
               x_atp_period,
               x_atp_details,
               x_return_status,
               x_msg_data,
               x_msg_count);

    /*------------------------------------------------------+
     | Bug # 1916037                                        |
     | Changes for Planning Manager performance improvement.|
     +------------------------------------------------------*/

    i := x_atp_rec.Action.FIRST;
    IF (NVL(x_atp_rec.Action(i), -1) <> 100) THEN

                                  -- This is NOT an ATP request.
                                  -- Insert the Line Ids into a temporary
                                  -- table to help the MRP Planning Manager
                                  -- perform better.
                                  -- Do This only if the Calling Module is OM.
                                  -- We Insert the line_id only if the
                                  -- scheduling request was successful or
                                  -- the item is not ATPable.

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Call_ATP: ' || 'this is NOT an atp request');
           END IF;
           IF (NVL(x_atp_rec.Calling_module(i), -1) = 660) THEN
             counter1 := 0;
             FOR j IN 1..x_atp_rec.Action.LAST LOOP

               IF (((NVL(x_atp_rec.Action(j), -1) = 110) OR
                    (NVL(x_atp_rec.Action(j), -1) = 120)) AND
                   ((NVL(x_atp_rec.Error_Code(j), -1) = 0 )OR
                    (NVL(x_atp_rec.Error_Code(j), -1) = 61 ) OR
                    (NVL(x_atp_rec.Error_Code(j), -1) = -99 )) ) THEN

                   counter1 := counter1 + 1;
                   p_line_arr(counter1) := x_atp_rec.identifier(j);

               END IF;
             END LOOP;
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP: ' || 'Counter1 : ' || to_char(counter1));
             END IF;
             IF (counter1 > 0) THEN
               MRP_OM_API_PK.MRP_OM_Interface (p_line_arr, x_return_status1);
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Call_ATP: ' || 'Return status from MRP_OM_Interface: '
                               || x_return_status1);
               END IF;
             END IF;
           END IF;
    END IF;


EXCEPTION

    -- Error Handling changes.
    WHEN MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND THEN
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Call_ATP: Invalid Objects found');
        END IF;

        IF (x_atp_rec.Inventory_item_id.COUNT = 0) THEN
                x_atp_rec := p_atp_rec;
        END IF;
        FOR  i IN 1..x_atp_rec.Calling_Module.LAST LOOP
                IF ((NVL(x_atp_rec.Error_Code(i), -1)) in (-1,0,61,150)) THEN
                        x_atp_rec.Error_Code(i) := MSC_ATP_PVT.ATP_INVALID_OBJECTS;
                END IF;
        END LOOP;

    WHEN others THEN
        -- something wrong so we want to rollback;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('something wrong in Call_ATP');
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Call_ATP: ' || 'Return Status in excpetion : '||x_return_status);
        END IF;
        -- Bug 2072612 : krajan : 04/03/02
        -- Commented rollback call.
         -- ROLLBACK;

        --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Call_ATP;


PROCEDURE Call_ATP_No_Commit (
               p_session_id         IN OUT NoCopy NUMBER,
               p_atp_rec            IN    MRP_ATP_PUB.ATP_Rec_Typ,
               x_atp_rec            OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
               x_atp_supply_demand  OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_atp_period         OUT   NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	       x_atp_details        OUT   NoCopy MRP_ATP_PUB.ATP_Details_Typ,
               x_return_status      OUT   NoCopy VARCHAR2,
               x_msg_data           OUT   NoCopy VARCHAR2,
               x_msg_count          OUT   NoCopy NUMBER
) IS
i                PLS_INTEGER;
counter1         NUMBER;
p_line_arr       MRP_OM_API_PK.line_id_tbl;
x_return_status1 VARCHAR2(1);

BEGIN
	MSC_ATP_PUB.Call_ATP_No_Commit(
               p_session_id,
               p_atp_rec,
               x_atp_rec,
               x_atp_supply_demand,
               x_atp_period,
               x_atp_details,
               x_return_status,
               x_msg_data,
               x_msg_count);

    /*------------------------------------------------------+
     | Bug # 1916037                                        |
     | Changes for Planning Manager performance improvement.|
     +------------------------------------------------------*/

    i := x_atp_rec.Action.FIRST;
    IF (NVL(x_atp_rec.Action(i), -1) <> 100) THEN

                                  -- This is NOT an ATP request.
                                  -- Insert the Line Ids into a temporary
                                  -- table to help the MRP Planning Manager
                                  -- perform better.
                                  -- Do This only if the Calling Module is
                                  -- Backlog Scheduling Workbench.
                                  -- We Insert the line_id only if the
                                  -- scheduling request was successful or
                                  -- the item is not ATPable.

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Call_ATP: ' || 'this is NOT an atp request');
           END IF;
           IF (NVL(x_atp_rec.Calling_module(i), -99) = -1 ) THEN
             counter1 := 0;
             FOR j IN 1..x_atp_rec.Action.LAST LOOP

               IF (((NVL(x_atp_rec.Action(j), -1) = 110) OR
                    (NVL(x_atp_rec.Action(j), -1) = 120)) AND
                   ((NVL(x_atp_rec.Error_Code(j), -1) = 0 )OR
                    (NVL(x_atp_rec.Error_Code(j), -1) = 61 ) OR
                    (NVL(x_atp_rec.Error_Code(j), -1) = -99 )) ) THEN

                   counter1 := counter1 + 1;
                   p_line_arr(counter1) := x_atp_rec.identifier(j);

               END IF;
             END LOOP;
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP: ' || 'Counter1 : ' || to_char(counter1));
             END IF;
             IF (counter1 > 0) THEN
               MRP_OM_API_PK.MRP_OM_Interface (p_line_arr, x_return_status1);
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Call_ATP: ' || 'Return status from MRP_OM_Interface: '
                               || x_return_status1);
               END IF;
             END IF;
           END IF;
    END IF;



EXCEPTION
    WHEN others THEN
         x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Error in Call_ATP_No_Commit :'||sqlcode);
            msc_sch_wb.atp_debug('Call_ATP: ' || sqlerrm);
            msc_sch_wb.atp_debug('Call_ATP: ' || 'shipset count ' ||p_atp_rec.error_code.count);
  	    msc_sch_wb.atp_debug('Call_ATP: ' || 'Exception x_return_status : '||x_return_status);
  	 END IF;
         -- Bug 2072612 : krajan : 04/03/02
         -- Commented rollback call.
          -- ROLLBACK;

END Call_ATP_No_Commit;


END MRP_ATP_PUB;

/
