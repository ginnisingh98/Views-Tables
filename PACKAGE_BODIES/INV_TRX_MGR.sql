--------------------------------------------------------
--  DDL for Package Body INV_TRX_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRX_MGR" AS
/* $Header: INVJTRXB.pls 120.1 2005/06/21 19:45:57 appldev ship $ */



--
--      Name: PROCESS_TRX_BATCH
--
--
--
FUNCTION PROCESS_TRX_BATCH(p_header_id IN  NUMBER,
                           p_commit    IN  NUMBER,
                           p_atomic    IN  NUMBER,
                           p_business_flow_code IN NUMBER,
                           x_proc_msg  OUT NOCOPY VARCHAR2 )  RETURN NUMBER AS
    LANGUAGE JAVA NAME 'oracle.apps.inv.transaction.server.TrxProcessor.processTrxBatch(java.lang.Long,
				java.lang.Integer,
				java.lang.Integer,
				java.lang.Integer,
				java.lang.String[]) return java.lang.Integer';


--
--      Name: PROCESS_TRX_BATCH
--      Overloaded Wrapper function
--
--
FUNCTION PROCESS_TRX_BATCH(p_header_id IN  NUMBER,
                           p_commit    IN  NUMBER,
                           p_atomic    IN  NUMBER,
                           x_proc_msg  OUT NOCOPY VARCHAR2 )  RETURN NUMBER AS
BEGIN
RETURN INV_TRX_MGR.PROCESS_TRX_BATCH ( p_header_id  => p_header_id,
                           	       p_commit    => p_commit,
                           	       p_atomic    => p_atomic,
                           	       p_business_flow_code => 0,
                           	       x_proc_msg  => x_proc_msg);
END;


--     Created to fix the G-I merge issues. Do not forward  port
--     Name: GENERATE_SERIALS (Over Loaded. Version 1)
--         Wrapper for GENERATE_SERIALSJ with Autonomous Tramsaction support
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
--       x_proc_msg          Message from the Process-Manager
--       return_status       0 on Success, 1 on Error
--
--
FUNCTION GENERATE_SERIALS( p_org_id       IN  NUMBER ,
                           p_item_id      IN  NUMBER ,
                           p_qty          IN  NUMBER ,
                           p_wip_id       IN  NUMBER ,
                           p_rev          IN  VARCHAR2,
                           p_lot          IN  VARCHAR2,
                           x_start_ser   OUT NOCOPY  VARCHAR2,
                           x_end_ser     OUT NOCOPY  VARCHAR2,
                           x_proc_msg    OUT NOCOPY  VARCHAR2 ) RETURN NUMBER AS
PRAGMA AUTONOMOUS_TRANSACTION;
l_retval number;
BEGIN
                l_retval := INV_SERIAL_NUMBER_PUB.GENERATE_SERIALS( p_org_id => p_org_id,
                                                                    p_item_id =>p_item_id,
                                                                    p_qty => p_qty,
                                                                    p_wip_id=>  p_wip_id,
                                                                    p_rev =>  p_rev,
                                                                    p_lot=>p_lot,
                                                                    x_start_ser => x_start_ser,
                                                                    x_end_ser => x_end_ser,
                                                                    x_proc_msg => x_proc_msg);

        COMMIT;
        return l_retval;
END;


FUNCTION VALIDATE_SERIALS( p_org_id       IN  NUMBER ,
                           p_item_id      IN  NUMBER ,
                           p_qty          IN  NUMBER ,
                           p_rev          IN  VARCHAR2 ,
                           p_lot          IN  VARCHAR2,
                           p_start_ser    IN  VARCHAR2,
                           p_trx_src_id   IN  NUMBER,
                           p_trx_action_id IN NUMBER,
                           x_end_ser     IN OUT NOCOPY  VARCHAR2,
                           x_proc_msg    OUT NOCOPY  VARCHAR2 ) RETURN NUMBER AS
       ret_number  NUMBER := 0;
       local_locator_id NUMBER;
       l_qty NUMBER :=0 ;

BEGIN
       l_qty := p_qty;
             ret_number := INV_SERIAL_NUMBER_PUB.VALIDATE_SERIALS(
                              p_org_id => p_org_id ,
                              p_item_id => p_item_id ,
                              p_qty => l_qty ,
                              p_rev => p_rev ,
                              p_lot => p_lot,
                              p_start_ser => p_start_ser,
                              p_trx_src_id => p_trx_src_id,
                              p_trx_action_id => p_trx_action_id,
                              x_end_ser => x_end_ser,
                              x_proc_msg => x_proc_msg);
              return ret_number;

END VALIDATE_SERIALS;

END INV_TRX_MGR;

/
