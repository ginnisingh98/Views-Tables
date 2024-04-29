--------------------------------------------------------
--  DDL for Package INV_TRX_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRX_MGR" AUTHID CURRENT_USER AS
/* $Header: INVJTRXS.pls 120.1 2005/06/21 19:32:26 appldev ship $ */


--
--      Name: PROCESS_TRX_BATCH
--
--      Input parameters:
--       p_header_id       TRANSACTION_HEADER_ID column value of the records
--                           that should be processed
--       p_commit         1 - Commit after processing
--                        0 - No commit after processing
--       p_atomic         1 - Treat batch as an atomic group. Rollback all
--                            changes if any one record fails.
--                        0 - Treat each record seperately. If error, rollback
--                            only changes related to that row.
--      p_business_flow_code :  Code that determines which label to be printed
--
--      Output parameters:
--       x_proc_msg         Message from the Process-Manager
--       return_status      0 on Success, 1 on Error
--
--      Description: This is the API to the INV Transaction Manager for
--       processing a batch of transaction record in the table
--       MTL_MATERIAL_TRANSACTIONS_TEMP grouped by TRANSACTION_HEADER_ID.
--       This function implements the logic which was previously in
--       inltpu.ppc .
--
--      Example :
--        The following code inserts a transaction for a serial and lot
--        controlled item.
--
--        String lnins = "{?=call INV_TRX_UTIL_PUB.INSERT_LINE_TRX(?,?,..?)}";
--        String lotins = "{?=call INV_TRX_UTIL_PUB.INSERT_LOT_TRX(?,?,..?)}";
--        String serins = "{?=call INV_TRX_UTIL_PUB.INSERT_SER_TRX(?,?,..?)}";
--        String proctrx = "{?=call INV_TRX_MGR.PROCESS_TRX_BATCH(?,?)}";
--        long TrxTmpId, SerTrxTmpId;
--        try{
--          // First insert the Transaction Line and retrieve TrxTempId
--          CallableStatement cs = conn.createCall(lnins);
--          CallableStatement csser = conn.createCall(serins);
--          csser.registerOutParameter(1, java.sql.Types.NUMERIC);
--          cs.registerOutParameter(1, java.sql.Types.NUMERIC);
--
--          cs.registerOutParameter(18, java.sql.Types.NUMERIC);
--          cs.setInt(2, itemId);
--
--          cs.executeQuery();
--          TrxTmpId = cs.getLong(18);
--
--          // If item is lot controlled, insert Lot-Transaction records
--          cs = conn.createCall(lotins);
--          cs.registerOutParameter(1, java.sql.Types.NUMERIC);
--          for (int k=0; k < lot_entered; k++){
--            	cs.setLong(2, TrxTmpId);
--              cs.setLong(3, user_id);
--              cs.setString(4, LotVec.elementAt(k));
--
--              cs.registerOutParameter(8, java.sql.Types.NUMERIC);
--              cs.executeQuery();
--              SerTrxTmpId = cs.getLong(8);
--
--             // If item is also Serial-controlled, insert Serial Trx records
--             // If the item is also lot-controlled, provide the SerTrxTmpId
--             // returned by the INSERT_LOT_TRX call.
--             for (int k=0; k < ser_entered; k++){
--                csser.setLong(2, SerTrxTmpId);
--                csser.setLong(3, user_id);
--                csser.setString(4, SerVec.elementAt(k));
--
--                csser.executeQuery();
--             }
--          }
--
--          // Finally, execute this transaciton
--          cs = conn.createCall(proctrx);
--         	cs.setLong(2, TrxTmpId);
--          cs.executeQuery();
--          // Check status of process
--          int retstatus = cs.getInt(1);
--
--        }catch(Exception e){
--          System.out.println("Error:"+e);
--        }
--
--
FUNCTION PROCESS_TRX_BATCH(p_header_id IN  NUMBER,
                           p_commit    IN NUMBER,
                           p_atomic    IN NUMBER,
                           p_business_flow_code IN NUMBER,
                         x_proc_msg  OUT NOCOPY VARCHAR2 )  RETURN NUMBER;


-- Name: PROCESS_TRX_BATCH
-- Overload function, for backwards compatability
FUNCTION PROCESS_TRX_BATCH(p_header_id IN  NUMBER,
                           p_commit    IN NUMBER,
                           p_atomic    IN NUMBER,
                           x_proc_msg  OUT NOCOPY VARCHAR2 )  RETURN NUMBER;

--     This is created to fix the G-I merge Issue, We dont have to port this to main line
--
--     Name: GENERATE_SERIALS (Over Loaded. Version 1)
--
--     Input parameters:
--       p_org_id             Organization ID
--       p_item_id            Item ID
--       p_qty                Count of Serial Numbers
--       p_wip_id             Wip Entity ID
--       p_rev                Revision
--       p_lot                Lot Number
--
--      Output parameters:
--       x_start_serial      Starting Serial Number
--       x_end_serial        Ending Serial Number
--       x_proc_msg          Message from the Process-Manager
--       return_status       0 on Success, 1 on Error
--
--      Functions: This API generates a batch of Serial Numbers
--      in MTL_SERIAL_NUMBERS and sets their status as
--       'DEFINED_BUT_NOT_USED'. Before inserting into the table
--      it ensures that there is no clash with existing Serial Numbers
--      as per the configured Serial-Number-Uniqueness attribute.
--      Note: This API works in an autonomous transaction
--
FUNCTION GENERATE_SERIALS( p_org_id       IN  NUMBER ,
                           p_item_id      IN  NUMBER ,
                           p_qty          IN  NUMBER ,
                           p_wip_id       IN  NUMBER ,
                           p_rev          IN  VARCHAR2,
                           p_lot          IN  VARCHAR2,
                           x_start_ser   OUT NOCOPY  VARCHAR2,
                           x_end_ser     OUT NOCOPY  VARCHAR2,
                           x_proc_msg    OUT NOCOPY  VARCHAR2 ) RETURN NUMBER;

FUNCTION VALIDATE_SERIALS( p_org_id       IN  NUMBER ,
                           p_item_id      IN  NUMBER ,
                           p_qty          IN  NUMBER ,
                           p_rev          IN  VARCHAR2 ,
                           p_lot          IN  VARCHAR2,
                           p_start_ser    IN  VARCHAR2,
                           p_trx_src_id   IN  NUMBER,
                           p_trx_action_id IN NUMBER,
                           x_end_ser     IN OUT NOCOPY  VARCHAR2,
                           x_proc_msg    OUT NOCOPY  VARCHAR2 ) RETURN NUMBER;

END INV_TRX_MGR;

 

/
