--------------------------------------------------------
--  DDL for Package Body MRP_OM_API_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_OM_API_PK" AS
/* $Header: MRPOAPIB.pls 115.5 2002/11/22 01:19:05 schaudha noship $  */


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE MRP_OM_Interface (
               p_line_tbl        IN  line_id_tbl ,
               x_return_status  OUT NOCOPY varchar2
) IS
    pvalue                           boolean;
BEGIN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Begin MRP_OM_Interface');
               END IF;
               FORALL i IN p_line_tbl.FIRST..p_line_tbl.LAST
                   INSERT INTO mrp_so_lines_temp
                      (
                      LAST_UPDATED_BY ,
                      LAST_UPDATE_DATE,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_LOGIN,
                      line_id,
                      process_status
                      )
                   VALUES
                      (
                      FND_GLOBAL.USER_ID,
                      SYSDATE,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      FND_GLOBAL.USER_ID,
                      p_line_tbl(i),
                      2             -- To Be Processed.
                      ) ;
               x_return_status := FND_API.G_RET_STS_SUCCESS;
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('End MRP_OM_Interface');
               END IF;
       EXCEPTION
           WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Error occured in MRP_OM_Interface'||
                               sqlcode);
                   msc_sch_wb.atp_debug('MRP_OM_Interface: ' || sqlerrm);
                END IF;
                              -- Reset the profile option MRP Planning Manager
                              -- First Time to Yes.
                              -- This will make the compute sales order
                              -- changes function to do a full table scan
                              -- of the table oe_order_lines_all to maintain
                              -- a consistent picture of demand as the insert
                              -- into the temporary table has failed!
                pvalue := fnd_profile.save('MRP_PLNG_MGR_FIRST_TIME',
                                            'Y', 'SITE');
                x_return_status := FND_API.G_RET_STS_ERROR;
                               -- It would be a better idea to send a
                               -- notification to a system manager at this point
                               -- as this will make the planning manager to
                               -- go very slow.
                               -- But I am leaving that as an enhancement for
                               -- the moment.
END MRP_OM_Interface;


END MRP_OM_API_PK;

/
